#include <Constraint.hpp>
using std::ostream; using CasADi::MX;
namespace ModelicaCasADi{
Constraint::Constraint(MX lhs, MX rhs,
                   Constraint::Type ct) : lhs(lhs), rhs(rhs), ct(ct){ }

/** Allows the use of the operator << to print this class to a stream, through Printable */
void Constraint::print(std::ostream& os) const {
	using std::endl;
    switch(ct) {
        case Constraint::EQ:  os<< lhs << " == " << rhs; break;
        case Constraint::LEQ: os<< lhs << " <= " << rhs; break;
        case Constraint::GEQ: os<< lhs << " >= " << rhs; break;
    }
}
}; // End namespace
