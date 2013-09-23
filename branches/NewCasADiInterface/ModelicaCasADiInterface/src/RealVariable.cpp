#include <RealVariable.hpp>
namespace ModelicaCasADi 
{
RealVariable::RealVariable(CasADi::MX var, Variable::Causality causality,
                           Variable::Variability variability, VariableType* declaredType /* = NULL */) :
                           Variable(var, causality, variability) { 
    myDerivativeVariable = NULL;
    this->declaredType = declaredType;
}
}; // End namespace
