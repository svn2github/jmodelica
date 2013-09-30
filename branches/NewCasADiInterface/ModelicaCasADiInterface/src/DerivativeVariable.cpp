#include <DerivativeVariable.hpp>
namespace ModelicaCasADi {
using CasADi::MX;
DerivativeVariable::DerivativeVariable(MX var, Variable* diffVar, VariableType* varType) :
                           RealVariable(var, Variable::INTERNAL, Variable::CONTINUOUS, varType /* = NULL */) { 
    if( diffVar != NULL) {
        if (diffVar->getType() != Variable::REAL || diffVar->getVariability() != Variable::CONTINUOUS ) {
            throw std::runtime_error("A state variable must have real type and continuous variability");
        }
    }
    myDifferentiatedVariable = diffVar;                               
}
}; // End namespace
