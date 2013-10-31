#include <types/VariableType.hpp>
using std::ostream;
namespace ModelicaCasADi 
{
void VariableType::print(ostream& os) const { 
    os << getName() << " type (";
    std::string sep("");
    for(attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it){
        os << sep << (it->first) << " = ";
        (it->second).print(os);
        sep = ", ";
    }
    os << ");";
}
}; // End namespace
