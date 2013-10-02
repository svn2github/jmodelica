#include "RealVariable.hpp"
namespace ModelicaCasADi 
{
RealVariable::RealVariable(CasADi::MX var, Variable::Causality causality,
                           Variable::Variability variability, VariableType* declaredType /* = NULL */) :
                           Variable(var, causality, variability, declaredType) { 
    myDerivativeVariable = NULL;
}
}; // End namespace
