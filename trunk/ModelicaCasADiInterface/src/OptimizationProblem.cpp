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
using std::ostream; using CasADi::MX;

namespace ModelicaCasADi{

OptimizationProblem::OptimizationProblem(Ref<Model> model, 
                                        const std::vector< Ref<Constraint> > &pathConstraints,
                                        const std::vector< Ref<Constraint> > &pointConstraints,
                                        MX startTime, MX finalTime,
                                        const std::vector< Ref<TimedVariable> > &timedVariables,
                                        MX lagrangeTerm  /*= MX(0)*/,
                                        MX mayerTerm  /*= MX(0)*/) : model(model)  {
    this->pathConstraints = pathConstraints;
    this->pointConstraints = pointConstraints;
    this->startTime = startTime;
    this->finalTime = finalTime;
    this->timedVariables = timedVariables;
    this->lagrangeTerm = lagrangeTerm;
    this->mayerTerm = mayerTerm;
} 
void OptimizationProblem::print(ostream& os) const { 
    using namespace std;
    os << "Model contained in OptimizationProblem:\n" << endl;
    os << model;
    os << "----------------------- Optimization information ------------------------\n\n";
    os << "Start time = ";
    startTime.print(os);
    os << "\nFinal time = ";
    finalTime.print(os);
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
    for (vector< Ref<TimedVariable> >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
        if (it == timedVariables.begin()) {
            os << "\n-- Timed variables --\n";
        }
        os << *it << endl;
    }
    
    os << "\n-- Lagrange term --\n";
    lagrangeTerm.print(os);
    os << endl;
    os << "-- Mayer term --\n";
    mayerTerm.print(os);
}

}; // End namespace
