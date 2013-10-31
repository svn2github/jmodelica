#include <Constraint.hpp>
using std::ostream; using CasADi::MX;
namespace ModelicaCasADi{
Constraint::Constraint(MX lhs, MX rhs,
                   Constraint::Type ct) : lhs(lhs), rhs(rhs), ct(ct){ }

/** Allows the use of the operator << to print this class to a stream, through Printable */
void Constraint::print(std::ostream& os) const {
	using std::endl;
    switch(ct) {
        case Constraint::EQ:  {
            lhs.print(os);
            os << " == ";
            rhs.print(os);
            break;
        }
        case Constraint::LEQ: {
            lhs.print(os);
            os << " <= ";
            rhs.print(os);
            break;
        } 
        case Constraint::GEQ:  {
            lhs.print(os);
            os << " >= ";
            rhs.print(os);
            break;
        }
    }
}
}; // End namespace
