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

OptimizationProblem::OptimizationProblem(Model* model, 
                                        std::vector<Constraint> pathConstraints,
                                        MX startTime, MX finalTime,
                                        MX lagrangeTerm  /*= MX(0)*/,
                                        MX mayerTerm  /*= MX(0)*/) : model(model)  {
    this->pathConstraints = pathConstraints;
    this->startTime = startTime;
    this->finalTime = finalTime;
    this->lagrangeTerm = lagrangeTerm;
    this->mayerTerm = mayerTerm;
} 
void OptimizationProblem::print(ostream& os) const { 
    using namespace std;
    os << "Model contained in OptimizationProblem:\n" << endl;
    os << *model;
    os << "-- Optimization information  --\n" << endl;
    os << "Start time = ";
    startTime.print(os);
    os << endl;
    os << "\nFinal time = ";
    finalTime.print(os);
    os << endl;
    for (vector<Constraint>::const_iterator it = pathConstraints.begin(); it != pathConstraints.end(); ++it) {
        if (it == pathConstraints.begin()) {
            os << "-- Constraints --" << endl;
        }
        os << *it << endl;
    }
    os << "-- Lagrange term --\n";
    lagrangeTerm.print(os);
    os << endl;
    os << "-- Mayer term --\n";
    mayerTerm.print(os);
}

}; // End namespace
