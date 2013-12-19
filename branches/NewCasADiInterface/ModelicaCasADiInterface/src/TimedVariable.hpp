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

#ifndef _MODELICACASADI_TIMED_VAR
#define _MODELICACASADI_TIMED_VAR

#include "Variable.hpp"
namespace ModelicaCasADi
{
/** 
 * A timed variable keeps a reference to its base variable (e.g. a refernce to X
 * for X(1)), and a time point (e.g. 1). 
 */
class TimedVariable : public Variable {
    public:
        /**
         * The Variable class should not be used, use subclasses such 
         * as RealVariable instead.
         * @param A symbolic MX.
         * @param Ref<Variable> baseVariable, a reference to its base varible.
         * @param MX Timepoint, this variable's timepoint
         */
        TimedVariable(CasADi::MX var, Ref<Variable> baseVariable, CasADi::MX timepoint);
        
        /**
         * The timepoint for this TimedVariable
         * @return MX, a MX expression for the time point
         */
        const CasADi::MX getTimepoint();
        
        /**
         * The base variable for this variable, e.g. a refernce to model variable for X 
         * if this variable is for X(1)
         * @ Ref<Variable> baseVariable, a reference to its base varible.
         */
        const Ref<Variable> getBaseVariable();
        
        /**
         * @return The type Real.
         */
        const Type getType() const;
        
        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        Ref<Variable> baseVariable;
        CasADi::MX timepoint;
};
inline const Variable::Type TimedVariable::getType() const { return Variable::REAL; }
inline const Ref<Variable> TimedVariable::getBaseVariable() { return this->baseVariable; }
inline const CasADi::MX TimedVariable::getTimepoint() { return this->timepoint; }
}; // End namespace
#endif
