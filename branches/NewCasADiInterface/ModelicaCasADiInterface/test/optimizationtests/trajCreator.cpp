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

#include "jni.h"    

// std dependencies
#include <iostream>
#include <sstream>
#include <fstream>
#include <ctime>
#include <numeric>

// Optimizer
#include <Optimizer.cpp>

// The ModelicaCasADiModel
#include <OptimizationProblem.hpp>
#include <Model.hpp>
#include <Variable.hpp>

// Transfer method
#include <transferOptimica.hpp>

// Paths needed to run the test
#include "modelicacasadi_paths.h"


using std::string;

// Forward declaration
void genTraj(ModelicaCasADi::OptimizationProblem &myOptProblem, int numSteps, vector<double> &sol, string filename);



int main(int argc, char *argv[])
{
    setUpJVM();
    
    string problem = "vdp";
    string problemFile = MODELICACASADI_MODELPATH "/optimizationProblems.mop";
    string filename = "mc_transfer_vdp_traj.txt";
    std::vector<double> solutionVector;
    ModelicaCasADi::OptimizationProblem* optProblem = transferOptimizationProblem(problem, problemFile);
    
    optimizer::optimize(*optProblem, 100, solutionVector);
    genTraj(*optProblem, 100, solutionVector, filename);
    
    
    problem = "optimizationOne";
    optProblem = transferOptimizationProblem(problem, problemFile);
    
    optimizer::optimize(*optProblem, 100, solutionVector);
    filename = "mc_transfer_optOne_traj.txt";
    genTraj(*optProblem, 100, solutionVector, filename);
    
    tearDownJVM();
    return 0;
}


void genTraj(ModelicaCasADi::OptimizationProblem &myOptProblem, int numSteps, vector<double> &sol, string filename) {
    using std::vector; using ModelicaCasADi::Model; using ModelicaCasADi::Variable;
    ModelicaCasADi::Model* model = myOptProblem.getModel();
    vector<int> nVar(4,0);
    vector<int> nVarCsum;
    
    // Number of vars. 
    nVar[0] = model->getVariables(Model::DIFFERENTIATED).size();
    nVar[1] = model->getVariables(Model::DERIVATIVE).size();
    nVar[2] = model->getVariables(Model::REAL_ALGEBRAIC).size();
    nVar[3] = model->getVariables(Model::REAL_INPUT).size();
    
    nVarCsum.push_back(0);
    std::partial_sum(nVar.begin(), nVar.end()-1, std::back_inserter(nVarCsum));
    int totalVars = nVarCsum[3]+nVar[3];
    int totalNumNlpVars = (numSteps+1)*totalVars;
    
    // Create textfile with trajectories, sorted as: [x][x'][w][u]
    std::ofstream file;
    file.open(filename.c_str());

    int index = 0;
    for (int i = 0; i < nVar.size(); ++i) {
        for (int j = 0; j < nVar[i]; ++j) {
            for (int k = index; k < sol.size(); k+=totalVars) {
                if(k+1 == sol.size()) {
                    file <<sol[k];
                } else {
                    file <<sol[k] <<",";
                }
            }
            index++;
        }
    }
    file.close();
}
