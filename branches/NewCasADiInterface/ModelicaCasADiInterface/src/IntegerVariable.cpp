#include <IntegerVariable.hpp>
namespace ModelicaCasADi 
{
using CasADi::MX;
IntegerVariable::IntegerVariable(MX var, Variable::Causality causality,
                           Variable::Variability variability, VariableType* declaredType /* = NULL */) :
                           Variable(var, causality, variability) { 
    if (variability == Variable::CONTINUOUS) {
		throw std::runtime_error("An integer variable can not have continuous variability");
	}
    this->declaredType = declaredType;
}
}; // End namespace
