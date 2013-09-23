#include <DerivativeVariable.hpp>
namespace ModelicaCasADi {
using CasADi::MX;
DerivativeVariable::DerivativeVariable(MX var, Variable* diffVar, VariableType* varType) :
                           RealVariable(var, Variable::INTERNAL, Variable::CONTINUOUS, varType /* = NULL */) { 
    myDifferentiatedVariable = diffVar;                               
}
}; // End namespace
