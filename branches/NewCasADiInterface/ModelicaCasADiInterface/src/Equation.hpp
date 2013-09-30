#ifndef _MODELICACASADI_EQUATION
#define _MODELICACASADI_EQUATION
#include <symbolic/casadi.hpp>
#include <iostream>

#include "Printable.hpp"

namespace ModelicaCasADi 
{
class Equation: public Printable {
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
         * Returns the residual on the form: right-hand-side - left-hand-side
         * @return A MX 
         */
        const CasADi::MX getResidual() const; 
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
    private:
        CasADi::MX lhs;
        CasADi::MX rhs;
};

inline const CasADi::MX Equation::getLhs() const { return lhs; }
inline const CasADi::MX Equation::getRhs() const { return rhs; }
inline const CasADi::MX Equation::getResidual() const { return rhs-lhs; }
inline void Equation::print(std::ostream& os) const { os << lhs << " = " << rhs; }

}; // End namespace
#endif
