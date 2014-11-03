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
    initializeModel(identifier);
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

}; // End namespace
