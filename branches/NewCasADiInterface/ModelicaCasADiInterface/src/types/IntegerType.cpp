#include <types/IntegerType.hpp>
namespace ModelicaCasADi 
{
using std::string; using std::ostream; using CasADi::MX;
IntegerType::IntegerType(){
    // Default attributes for non parameter/constant Integer type, according to
    // Modelica specification.
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("quantity"), MX("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("min"), MX(-std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("max"),  MX(std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("start"), MX(0)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("fixed"), MX(false)));
}

const VariableType::AttributeValue* IntegerType::getAttribute(const AttributeKey key) const { 
    // If the attribute is in the map, return, otherwise return null. 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : NULL;
}

void IntegerType::print(std::ostream& os) const { 
    os <<"Type name: Integer, attributes:";
    for(attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it) {
        os <<"\n\t"<<it->first<<" = "<<it->second;
    }
}
}; // End namespace
