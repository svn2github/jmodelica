#include <types/UserType.hpp>
using std::string; using std::ostream;
namespace ModelicaCasADi 
{
UserType::UserType(string name, PrimitiveType* baseType) : name(name), baseType(baseType) {
}

VariableType::AttributeValue* UserType::getAttribute(const AttributeKey key) { 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : baseType->getAttribute(key);
}


bool UserType::hasAttribute(const AttributeKey key) const { 
    return (attributes.find(AttributeKeyInternal(key))!=attributes.end() || baseType->hasAttribute(key));
}

void UserType::print(ostream& os) const { 
    os << getName() << " type = " << baseType->getName() << " (";
    std::string sep("");
    for(attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it){
        os << sep << (it->first) << " = ";
        (it->second).print(os);
        sep = ", ";
    }
    os << ");";
}

}; 
