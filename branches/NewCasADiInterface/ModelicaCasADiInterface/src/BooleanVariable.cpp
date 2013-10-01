#include <BooleanVariable.hpp>
namespace ModelicaCasADi 
{
BooleanVariable::BooleanVariable(CasADi::MX var, Variable::Causality causality,
                           Variable::Variability variability, VariableType* declaredType /* = NULL */) :
                           Variable(var, causality, variability, declaredType) { 
    if (variability == Variable::CONTINUOUS) {
		throw std::runtime_error("A boolean variable can not have continuous variability");
	}
}
}; // End namespace
