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
    os << (getCausality() == INPUT ? "Input " : (getCausality() == OUTPUT ? "Output " : "" ));
    os << (getVariability() == CONTINUOUS ? "" : (getVariability() == DISCRETE ? "Discrete " : (getVariability() == PARAMETER ? "Parameter " : 
           (getVariability() == CONSTANT ? "Constant " : ""))));
    if (declaredType != NULL) {
        os << declaredType->getName() << " ";
    } else {
        os << (getType() == REAL ? "Real " : (getType() == INTEGER ? "Integer " : (getType() == BOOLEAN ? "Boolean " : 
              (getType() == STRING ? "String " : ""))));
    }
    var.print(os);
    if (!attributes.empty() || isAlias()) {
        std::string sep = "";
        os <<"(";
        for (attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it) {
            os << sep <<it->first<<" = ";
            (it->second).print(os);
            sep = ", ";
        }
        if (isAlias()) {
            os << sep << "alias: " <<  myModelVariable->getName();
        }
        os << ")";
    }
    if (attributes.find(AttributeKeyInternal("bindingExpression")) != attributes.end()) { 
        os << " = ";
        (attributes.find(AttributeKeyInternal("bindingExpression"))->second).print(os);
    } 
    if (attributes.find(AttributeKeyInternal("comment")) != attributes.end()) { 
        os << " \"";
        (attributes.find(AttributeKeyInternal("comment"))->second).print(os);
        os << "\"";
    }
    if (attributes.find(AttributeKeyInternal("bindingExpression")) != attributes.end()) {
        if (attributes.find(AttributeKeyInternal("bindingExpression"))->second.isConstant()) {
            os << " /* ";
            (attributes.find(AttributeKeyInternal("bindingExpression"))->second).print(os);
            os << " */";
        } else if (attributes.find(AttributeKeyInternal("evaluatedBindingExpression")) != attributes.end()) {
            os << "/* ";
            (attributes.find(AttributeKeyInternal("evaluatedBindingExpression"))->second).print(os);
            os << " */";
        }
    } 
    os << ";";
}
}; // End namespace
