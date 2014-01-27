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

#ifndef _MODELICACASADI_CONSTRAINT
#define _MODELICACASADI_CONSTRAINT
#include <iostream>
#include "symbolic/casadi.hpp"
#include "SharedNode.hpp"
namespace ModelicaCasADi{
class Constraint : public SharedNode {
    public:
        enum Type {
            EQ,
            LEQ,
            GEQ
        };
        /// Default constructor needed by Swig
        Constraint();
        /**
         * Create a constraint from MX for the left and right hand side, 
         * and a relation type (<, >, ==).
         * @param A MX
         * @param A MX
         * @param A Type enum
         */
        Constraint(CasADi::MX lhs, CasADi::MX rhs, Type ct);
        /** @return A MX */                   
        const CasADi::MX getLhs() const;
        /** @return A MX */
        const CasADi::MX getRhs() const;
        /**
         * Returns the residual of the constraint as: right-hand-side - left-hand-side.
         * @return A MX
         */
        const CasADi::MX getResidual() const; 
        /** @return An enum Type */
        Type getType() const;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        CasADi::MX lhs;
        CasADi::MX rhs;
        Type ct;
};
inline Constraint::Constraint() {}
inline const CasADi::MX Constraint::getLhs() const{ return lhs; }
inline const CasADi::MX Constraint::getRhs() const { return rhs; }
inline const CasADi::MX Constraint::getResidual() const{ return rhs-lhs; }
inline Constraint::Type Constraint::getType() const{ return ct; }
}; // End namespace
#endif
