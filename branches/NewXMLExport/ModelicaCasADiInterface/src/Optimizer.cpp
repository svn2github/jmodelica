/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _MODELICACASADI_OPTIMIZER
#define _MODELICACASADI_OPTIMIZER
#include <numeric>

#include "symbolic/casadi.hpp"
#include "interfaces/ipopt/ipopt_solver.hpp"

#include "Model.hpp"
#include "Constraint.hpp"
#include "Equation.hpp"
#include "Variable.hpp"
#include "RealVariable.hpp"
#include "DerivativeVariable.hpp"
#include "OptimizationProblem.hpp"


using std::vector; using std::cout; using std::endl;
using CasADi::MX; using ModelicaCasADi::Variable; using ModelicaCasADi::Constraint; using ModelicaCasADi::Model;

namespace optimizer{
vector<MX> getMX( vector<Variable*> vars){
    vector<MX> temp;
    for (vector<Variable*>::iterator it = vars.begin(); it != vars.end(); ++it) {
        temp.push_back((*it)->getVar());
    }
    return temp;
}

vector<MX> retrieveCurrNlpVars(int index, int numVar, vector<int> &numVarList, MX nlp_vars){
    vector<MX> returnVec;
    int offset = 0;
    for(int i = 0; i < numVarList.size(); ++i){
        for(int j =0; j < numVarList[i]; ++j){
            returnVec.push_back(nlp_vars[numVar*index + offset]);
            offset++;
        }
    }
    return returnVec;
}
    
void optimize(ModelicaCasADi::OptimizationProblem &myOptProblem, int numSteps, vector<double> &sol) {
    using namespace CasADi;
    
    
    double h = (myOptProblem.getFinalTime().getValue() - myOptProblem.getStartTime().getValue()) / ( (double) numSteps);
    
    vector<double> ub_g;  // Upper and lower bound for constraints. To handle inequalities occurring in the model. 
    vector<double> lb_g;
		
    Model* model = myOptProblem.getModel();
    
    // MX variables
    vector<MX> x_var  = getMX(model->getVariables(Model::DIFFERENTIATED));
    vector<MX> dx_var = getMX(model->getVariables(Model::DERIVATIVE));
    vector<MX> z_var  = getMX(model->getVariables(Model::REAL_ALGEBRAIC));
    vector<MX> u_var  = getMX(model->getVariables(Model::REAL_INPUT));
    vector<MX> vars;
    vars.insert(vars.end(), x_var.begin(), x_var.end() );
    vars.insert(vars.end(), dx_var.begin(), dx_var.end());
    vars.insert(vars.end(), z_var.begin(), z_var.end());
    vars.insert(vars.end(), u_var.begin(), u_var.end());

    vector<int> nVar;
    vector<int> nVarCsum;
    nVar.push_back(x_var.size());
    nVar.push_back(dx_var.size());
    nVar.push_back(z_var.size());
    nVar.push_back(u_var.size());
    nVarCsum.push_back(0);
    std::partial_sum(nVar.begin(), nVar.end()-1, std::back_inserter(nVarCsum));
    int totalVars = nVarCsum[3]+nVar[3];
    MX nlp_vars  = msym("nlp_var", (numSteps+1)*totalVars) ;
    
    /////////////////////////////////////
    // Build objective and constraints //
    ///////////////////////////////////// 
    
    MX constraints = MX(); // Empty MX for storage of all constraints

     //Initial conditions 
    vector<MX> initial; 
    initial.push_back(model->getInitialResidual());
    vector<MX> initial_conditions;
    
    initial_conditions  = substitute(initial, vars, retrieveCurrNlpVars(0,totalVars,nVar,nlp_vars));
    for(int i = 0; i < initial_conditions.size(); ++i){        
        constraints.append( initial_conditions[i] );
        if(!constraints.isNull()) { // If there are no initial conditions in the list, this is false.
            for (int j = 0; j < constraints.size(); ++j) {
                ub_g.push_back(0.0); // Equality constraint
                lb_g.push_back(0.0);   
            }
        }
    }
    // Interpolation of inputs for first element 
    constraints.append(nlp_vars[nVarCsum[3]] - nlp_vars[totalVars+nVarCsum[3]]);
    ub_g.push_back(0.0); // Equality constraint
    lb_g.push_back(0.0);    
        
    // DAE equations
    vector<MX> dae;
    vector<MX> temp;
    dae.push_back(model->getDaeResidual());
    for(int i = 0; i <= numSteps; i++){ 
        temp = substitute(dae,vars,retrieveCurrNlpVars(i,totalVars,nVar,nlp_vars));
        constraints.append(temp[0]);
        for(int j = 0; j < temp[0].size(); ++j){
            ub_g.push_back(0.0); // Equality constraint
            lb_g.push_back(0.0);
        }
    }
    
    // Collocation constraints (implicit Euler: dx_i = (x_i - x_{i - 1}) / h)
    MX collocation;
    for (int i = 1; i <= numSteps; i++){
        for(int j = 0; j < nVar[1]; ++j){ // Number of derivative variables
            collocation = nlp_vars[totalVars*i + nVarCsum[1]+j]  - (nlp_vars[totalVars*i + nVarCsum[0]+j] - nlp_vars[totalVars*(i-1) + nVarCsum[0]+j])/h;
            constraints.append(collocation) ;
            ub_g.push_back(0.0); // Equality constraint
            lb_g.push_back(0.0);   
        }
    }
    
    // Objective (implicit Euler: \int_t^{t + h} f(x(t)) dt = h * f(x(t + h)))
    vector<MX> lagrange;
    lagrange.push_back(myOptProblem.getLagrangeTerm());
    vector<MX> lterm;
    MX objective = 0;
    for (int i = 1; i <= numSteps; i++){
        lterm = substitute(lagrange, vars, retrieveCurrNlpVars(i,totalVars,nVar,nlp_vars));
        objective += h * lterm.back();
    }
    
    
    // Inequality constrains.
    vector<MX> inq;
    vector<MX> pc;
    vector<Constraint>  ir = myOptProblem.getPathConstraints();

    for (vector<Constraint>::iterator ConstraintIter = ir.begin(); ConstraintIter != ir.end(); ++ConstraintIter) {
        for (int i = 0; i <= numSteps; i++){
            pc.clear();
            pc.push_back(ConstraintIter->getResidual()); // Get constraint residual (e.q for LEQ: lhs - rhs <= 0)
            inq = substitute(pc, vars, retrieveCurrNlpVars(i, totalVars, nVar, nlp_vars));
            for(vector<MX>::iterator it = inq.begin(); it != inq.end(); ++it){    
                constraints.append( (*it) );
                switch(ConstraintIter->getType()){
                    case Constraint::EQ:
                        ub_g.push_back(0.0); // Equality constraint
                        lb_g.push_back(0.0);
                    break;
                    case Constraint::LEQ:
                        ub_g.push_back(std::numeric_limits<double>::infinity()); // Inequality constraint
                        lb_g.push_back(0);
                    break;
                    case Constraint::GEQ:
                        ub_g.push_back(0.0); // Inequality constraint
                        lb_g.push_back(-std::numeric_limits<double>::infinity());
                    break;
                }
            }
        }
    }
    MXFunction objective_fcn = MXFunction(nlp_vars, objective);
    objective_fcn.init();
    MXFunction constraint_fcn = MXFunction(nlp_vars, constraints);
    constraint_fcn.init();
    
    // Initialize a solver with said functions
    IpoptSolver solver = IpoptSolver(objective_fcn, constraint_fcn);
    solver.init();
    // Set upper and lower bounds for constraints.
    solver.setInput(lb_g,"lbg");
    solver.setInput(ub_g,"ubg");
    // Solve
    solver.solve();
    // Return the solution vec.
    sol.resize(nlp_vars.size());
    solver.getOutput(sol,"x");
}
}; // End namespace
#endif
























