/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "Variable.hpp"
using std::ostream; using CasADi::MX;
namespace ModelicaCasADi 
{
Variable::Variable() : negated(false) {
    var = MX();
    myModelVariable = Ref<Variable>(NULL);
    declaredType = Ref<VariableType>(NULL);
}

Variable::Variable(MX var, Variable::Causality causality, 
                 Variable::Variability variability,
                 Ref<VariableType> declaredType /* Ref<VariableType>() */) : 
                 causality(causality),
                 variability(variability),
                 negated(false) {
    if (var.isConstant()) {
        throw std::runtime_error("A variable must have a symbolic MX");
    }
    myModelVariable = Ref<Variable>(NULL);
    this->var = var;
    this->declaredType = declaredType;
}




Variable::AttributeValue* Variable::getAttribute(AttributeKey key) { 
    if (isAlias()) {
        return getAttributeForAlias(key);
    } else {
        return hasAttributeSet(key) ? &attributes.find(AttributeKeyInternal(key))->second :
                                  (declaredType != Ref<VariableType>(NULL) ? declaredType->getAttribute(key) : NULL);
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
    os << (getCausality() == INPUT ? "input " : (getCausality() == OUTPUT ? "output " : "" ));
    os << (getVariability() == CONTINUOUS ? "" : (getVariability() == DISCRETE ? "discrete " : (getVariability() == PARAMETER ? "parameter " : 
           (getVariability() == CONSTANT ? "constant " : ""))));
    if (declaredType != Ref<VariableType>(NULL)) {
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
