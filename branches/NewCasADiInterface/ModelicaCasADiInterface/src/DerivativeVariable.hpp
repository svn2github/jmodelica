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

#ifndef _MODELICACASADI_DER_VAR
#define _MODELICACASADI_DER_VAR
#include "RealVariable.hpp"
namespace ModelicaCasADi
{
class DerivativeVariable : public RealVariable {
    public:
        /**
         * Create a derivative variable. A derivative variable takes a pointer to
         * its corresponding state variable as argument.
         * @param A symbolic MX
         * @param A pointer to a Variable
         * @param A pointer to a VariableType, default is NULL
         */
        DerivativeVariable(CasADi::MX var, Variable* diffVar, VariableType* = NULL); 
        /** @return A pointer to a Variable */
        const Variable* getMyDifferentiatedVariable() const;
        /** @return True */
        bool isDerivative() const;
    private:
        Variable* myDifferentiatedVariable;
};
inline bool DerivativeVariable::isDerivative() const { return true; }
inline const Variable* DerivativeVariable::getMyDifferentiatedVariable() const { return myDifferentiatedVariable; }
}; // End namespace
#endif
