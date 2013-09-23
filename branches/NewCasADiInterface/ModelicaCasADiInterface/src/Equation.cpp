#include <Equation.hpp>
using CasADi::MX;
namespace ModelicaCasADi 
{
Equation::Equation(MX lhs, MX rhs) : lhs(lhs), rhs(rhs) {}
}; // End namespace
