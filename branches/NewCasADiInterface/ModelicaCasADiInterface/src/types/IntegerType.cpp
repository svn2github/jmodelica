#include <types/IntegerType.hpp>
namespace ModelicaCasADi 
{
using std::string; using CasADi::MX;
IntegerType::IntegerType(){
    // Default attributes for non parameter/constant Integer type, according to
    // Modelica specification.
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("quantity"), MX("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("min"), MX(-std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("max"),  MX(std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("start"), MX(0)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("fixed"), MX(false)));
}

VariableType::AttributeValue* IntegerType::getAttribute(const AttributeKey key) { 
    // If the attribute is in the map, return, otherwise return null. 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : NULL;
}

}; // End namespace
