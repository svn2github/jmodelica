#include "Variable.hpp"
using std::ostream; using CasADi::MX;
namespace ModelicaCasADi 
{
Variable::Variable() : negated(false) {
    var = MX();
    myModelVariable = NULL;
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
    myModelVariable = NULL;
    this->var = var;
    this->declaredType = declaredType;
}




Variable::AttributeValue* Variable::getAttribute(AttributeKey key) { 
    if (isAlias()) {
        return getAttributeForAlias(key);
    } else {
        return hasAttributeSet(key) ? &attributes.find(AttributeKeyInternal(key))->second :
                                  (declaredType != NULL ? declaredType->getAttribute(key) : NULL);
    }
}

bool Variable::hasAttributeSet(AttributeKey key) const { 
    if (isAlias()) {
        return myModelVariable->hasAttributeSet(key);
    } else {
        return attributes.find(AttributeKeyInternal(key)) != attributes.end(); 
    }
}


/// Assumes that this is an alias, and that the attribute should be retrieved from
/// the alias variable. 
Variable::AttributeValue* Variable::getAttributeForAlias(AttributeKey key) {
    AttributeValue* val = myModelVariable->getAttribute(keyForAlias(key)); // Note that keyForAlias can change key for min/max. 
    bool shoulNegateAttribute = ((key == "start" || key == "min" || key == "max" || key == "nominal") && isNegated());
    if (val != NULL && shoulNegateAttribute) {
        val = new MX(val->operator-());
    }
    return val;
}

/// Helper method for handling of alias variables. Assumes that this is an alias.
/// The attributes min and max needs to be interchanged for negated alias variables. 
Variable::AttributeKey Variable::keyForAlias(AttributeKey key)  const{
    if (isNegated()) {
        if (key == "min") {
            key = "max";
        } else if (key == "max") {
            key = "min";
        }
    }
    return key;
}

/// Assumes that this is an alias, and propagates the attribute to its alias variable.
void Variable::setAttributeForAlias(AttributeKey key, AttributeValue val) {
    if (isNegated() && (key == "start" || key == "min" || key == "max" || key == "nominal")) {
        key = keyForAlias(key);
        val = -val;
    }
    myModelVariable->setAttribute(key, val);
}

void Variable::setAttribute(AttributeKey key, AttributeValue val) { 
    if (isAlias()) {
        setAttributeForAlias(key, val);
    } else {
        attributes[AttributeKeyInternal(key)]=val; 
    }
}
void Variable::setAttribute(AttributeKey key, double val) { 
    if (isAlias()) {
        setAttributeForAlias(key, val);
    } else {
        attributes[AttributeKeyInternal(key)]=MX(val); 
    }
}


void Variable::print(ostream& os) const {
    os << var;
    os << (isAlias() ? (std::string(", alias: ") + myModelVariable->getName()) : "");
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
