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

#include "TimedVariable.hpp"
using std::ostream; using CasADi::MX;
using ModelicaCasADi::Variable;
namespace ModelicaCasADi 
{
TimedVariable::TimedVariable(Model *owner, MX var, Ref<Variable> baseVariable, MX timePoint) :
  Variable(owner, var, Variable::INTERNAL, Variable::PARAMETER) {
    
    if (baseVariable->getType() != Variable::REAL) {
        throw std::runtime_error("Timed variables only supported for real variables");
    }
    this->baseVariable = baseVariable;
    this->timePoint = timePoint;
}
}; // End namespace
