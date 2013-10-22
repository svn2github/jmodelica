#include <types/RealType.hpp>
namespace ModelicaCasADi 
{
using std::string; using std::ostream; using CasADi::MX;
RealType::RealType(){
    // Default attributes for non parameter/constant Real type, according to
    // Modelica specification.
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("quantity"), MX("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("nominal"), MX(1)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("unit"), MX("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("displayUnit"), MX("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("min"), MX(-std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("max"), MX(std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("start"), MX(0)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("fixed"), MX(false)));
    //attributes["stateSelect"] = NULL; // TODO
}

VariableType::AttributeValue* RealType::getAttribute(const AttributeKey key) { 
    // If the attribute is in the map, return, otherwise return null. 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : NULL;
}


void RealType::print(ostream& os) const { 
    os <<"Type name: Real, attributes:";
    for(attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it){
        os <<"\n\t"<<it->first<<" = "<<it->second;
    }
}
}; // End namespace
