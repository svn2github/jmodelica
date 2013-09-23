#include <ModelFunction.hpp>
using std::ostream; using std::vector; using std::string;
using CasADi::MX;  using CasADi::MXFunction;

namespace ModelicaCasADi 
{
 
vector<MX> ModelFunction::call(vector<MX> arg) {
    MX argSingle;
    for (vector<MX>::const_iterator it = arg.begin(); it != arg.end(); ++it) {
            argSingle.append(*it);
    }
    return myFunction.call(argSingle);
}

string ModelFunction::getName() const {
    return myFunction.getOption("name");
}

void ModelFunction::print(ostream& os) const { 
    os << "ModelFunction : " << myFunction << "\n";
    myFunction.print(os);
}

}; // End namespace
