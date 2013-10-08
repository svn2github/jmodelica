#include "Variable.hpp"
using std::ostream; using CasADi::MX;
namespace ModelicaCasADi 
{
Variable::Variable() : negated(false) {
    var = MX();
    aliasVariable = NULL;
	declaredType = NULL;
}

Variable::Variable(MX var, Variable::Causality causality, 
                 Variable::Variability variability,
                 VariableType* declaredType) : 
                 causality(causality),
                 variability(variability),
                 negated(false) {
    if (var.isConstant()) {
		throw std::runtime_error("A variable must have a symbolic MX");
	}
    aliasVariable = NULL;
	this->var = var;
	this->declaredType = declaredType;
}

const Variable::AttributeValue* Variable::getAttribute(AttributeKey key) const { 
    if (!isAlias()) {
        return hasAttribute(key) ? &attributes.find(AttributeKeyInternal(key))->second :
                                  (declaredType != NULL ? declaredType->getAttribute(key) : NULL);
    } else {
        return aliasVariable->getAttribute(key);
    }
}

bool Variable::hasAttribute(AttributeKey key) const { 
    if (!isAlias()) {
        return attributes.find(AttributeKeyInternal(key))!=attributes.end(); 
    } else {
        return aliasVariable->hasAttribute(key);
    }
}

void Variable::setAttribute(AttributeKey key, AttributeValue val) { 
    if (!isAlias()) {
        attributes[AttributeKeyInternal(key)]=val; 
    } else {
        aliasVariable->setAttribute(key, val);
    }
}


void Variable::print(ostream& os) const {
    os << var;
    os << (isAlias() ? (std::string(", alias: ") + aliasVariable->getName()) : "");
    os << (declaredType != NULL ? (std::string(", declaredType : ") + declaredType->getName()) : "");
    if (!attributes.empty()) {
        std::string lineBreak = "";
        os <<", attributes:\n";
        for (attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it) {
            os << lineBreak <<"\t"<<it->first<<" = "<<it->second;
            lineBreak = "\n";
        }
    }
}
}; // End namespace
