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

#include "OptimizationProblem.hpp"
using std::ostream; using casadi::MX;

namespace ModelicaCasADi{

OptimizationProblem::~OptimizationProblem() {
    // Delete all the OptimizationProblem's variables, since they are OwnedNodes with the OptimizationProblem as owner.
    for (std::vector< TimedVariable * >::iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
        delete *it;
        *it = NULL;
    }
}

void OptimizationProblem::initializeProblem(std::string identifier /* = "" */, 
                                            bool normalizedTime /* = true */ ) {
    Model::initializeModel(identifier);
    this->normalizedTime = normalizedTime;
}

std::vector< Ref<TimedVariable> > OptimizationProblem::getTimedVariables() const
{
    std::vector< Ref<TimedVariable> > result;
    for (std::vector< TimedVariable * >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
        result.push_back(*it);
    }
    return result;
}

void OptimizationProblem::print(ostream& os) const { 
//    os << "OptimizationProblem<" << this << ">"; return;

    using namespace std;
    os << "Model contained in OptimizationProblem:\n" << endl;
    Model::print(os);
    os << "----------------------- Optimization information ------------------------\n\n";
    os << "Start time = ";
    if (startTime.isEmpty()) {
        os << "not set";
    } else {
        startTime.print(os);
    }
    
    os << "\nFinal time = ";
    if (finalTime.isEmpty()) {
        os << "not set";
    } else {
        finalTime.print(os);
    }
    
    os << "\n\n";
    for (vector< Ref<Constraint> >::const_iterator it = pathConstraints.begin(); it != pathConstraints.end(); ++it) {
        if (it == pathConstraints.begin()) {
            os << "-- Path constraints --" << endl;
        }
        os << *it << endl;
    }
    for (vector< Ref<Constraint> >::const_iterator it = pointConstraints.begin(); it != pointConstraints.end(); ++it) {
        if (it == pointConstraints.begin()) {
            os << "-- Point constraints --" << endl;
        }
        os << *it << endl;
    }
    for (vector< TimedVariable * >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
        if (it == timedVariables.begin()) {
            os << "\n-- Timed variables --\n";
        }
        os << **it << endl;
    }
    
    os << "\n-- Objective integrand term --\n";
    if (objectiveIntegrand.isEmpty()) {
        os << "not set";
    } else {
        objectiveIntegrand.print(os);
    }
    
    os << "\n-- Objective term --\n";
    if (objective.isEmpty()) {
        os << "not set";
    } else {
        objective.print(os);
    }
}

void OptimizationProblem::eliminateAlgebraics(){
    Model::eliminateAlgebraics();
    std::vector<casadi::MX> eliminatedMXs;
    std::vector<casadi::MX> subtitutes;
    for(std::map<const Variable*,casadi::MX>::const_iterator it=eliminatedVariableToSolution.begin();
	it!=eliminatedVariableToSolution.end();++it){
	    eliminatedMXs.push_back(it->first->getVar());
	    subtitutes.push_back(it->second);
    }
    std::vector<casadi::MX> expressions;
    expressions.push_back(startTime);
    expressions.push_back(finalTime);
    expressions.push_back(objectiveIntegrand);
    expressions.push_back(objective);

    std::vector<casadi::MX> subtitutedExpressions = casadi::substitute(expressions,eliminatedMXs,subtitutes); 
    
    std::vector<casadi::MX>::const_iterator it =subtitutedExpressions.begin();
    startTime = *(it++);
    finalTime = *(it++);
    objectiveIntegrand = *(it++);
    objective = *(it++);
    //Still missing path and point constraints
    
}

void OptimizationProblem::substituteAllEliminateables(){
    std::set<const Variable*> eliminateables = equationContainer_->eliminateableVariables();
    std::map<const Variable*,casadi::MX> tmpMap;
    equationContainer_->getSubstitues(eliminateables, tmpMap);
    std::vector<casadi::MX> eliminatedMXs;
    std::vector<casadi::MX> subtitutes;
    for(std::map<const Variable*,casadi::MX>::const_iterator it=tmpMap.begin();
	it!=tmpMap.end();++it){
	    eliminatedMXs.push_back(it->first->getVar());
	    subtitutes.push_back(it->second);
	    std::cout<<it->first->getVar()<<"  "<<it->second<<"\n";
    }
    
    //Substitutes in the optimization expressions
    std::vector<casadi::MX> expressions;
    expressions.push_back(startTime);
    expressions.push_back(finalTime);
    expressions.push_back(objectiveIntegrand);
    expressions.push_back(objective);

    std::vector<casadi::MX> subtitutedExpressions = casadi::substitute(expressions,eliminatedMXs,subtitutes); 
    startTime = subtitutedExpressions[0];
    finalTime = subtitutedExpressions[1];
    objectiveIntegrand = subtitutedExpressions[2];
    objective = subtitutedExpressions[3];
    
    std::cout<<objectiveIntegrand<<"  "<<objective<<"\n";
    //Substitutes in DAE    
    equationContainer_->substituteAllEliminateables();
    //Still missing path and point constraints
}

}; // End namespace
