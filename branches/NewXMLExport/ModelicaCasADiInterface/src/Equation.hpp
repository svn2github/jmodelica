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

#ifndef _MODELICACASADI_EQUATION
#define _MODELICACASADI_EQUATION

#include <iostream>
#include "symbolic/casadi.hpp"
#include "RefCountedNode.hpp"
namespace ModelicaCasADi 
{
class Equation: public RefCountedNode {
    public:
        /** 
         * Create an equation with MX expressions for the left and right hand side
         * @param A MX
         * @param A MX
         */
        Equation(CasADi::MX lhs, CasADi::MX rhs); 
        /** @return A MX */
        const CasADi::MX getLhs() const;
        /** @return A MX */
        const CasADi::MX getRhs() const;
        /** 
         * Returns the residual on the form: left-hand-side - right-hand-side
         * @return A MX 
         */
        const CasADi::MX getResidual() const; 
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        CasADi::MX lhs;
        CasADi::MX rhs;
};

inline const CasADi::MX Equation::getLhs() const { return lhs; }
inline const CasADi::MX Equation::getRhs() const { return rhs; }
inline const CasADi::MX Equation::getResidual() const { return lhs - rhs; }
inline void Equation::print(std::ostream& os) const { 
    lhs.print(os);
    os << " = ";
    rhs.print(os); 
}

}; // End namespace
#endif
