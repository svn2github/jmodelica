#include <types/BooleanType.hpp>
namespace ModelicaCasADi 
{
using std::string; using std::ostream; using CasADi::MX;
BooleanType::BooleanType() {
    // Default attributes for non parameter/constant Boolean type, according to
    // Modelica specification.
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("quantity"), MX("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("start"), MX(false)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("fixed"), MX(false)));
}

VariableType::AttributeValue* BooleanType::getAttribute(const AttributeKey key) { 
    // If the attribute is in the map, return, otherwise return null. 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : NULL;
}

void BooleanType::print(ostream& os) const { 
    os <<"Type name: Boolean, attributes:";
    for (attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it) {
        os <<"\n\t"<<it->first<<" = "<<it->second;
    }
}
}; // End namespace
