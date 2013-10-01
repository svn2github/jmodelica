#include <Variable.hpp>
using std::ostream; using CasADi::MX;
namespace ModelicaCasADi 
{

Variable::Variable(MX var, Variable::Causality causality, 
                 Variable::Variability variability,
                 VariableType* declaredType) : 
                 causality(causality),
                 variability(variability) {
    if (var.isConstant()) {
		throw std::runtime_error("A variable must have a symbolic MX");
	}
	this->var = var;
	this->declaredType = declaredType;
}

const Variable::AttributeValue* Variable::getAttribute(AttributeKey key) const { 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second :
           (declaredType != NULL ? declaredType->getAttribute(key) : NULL);
}

void Variable::print(ostream& os) const {
    os << var;
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
