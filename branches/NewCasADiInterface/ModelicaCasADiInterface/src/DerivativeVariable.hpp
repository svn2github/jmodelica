#ifndef _MODELICACASADI_DER_VAR
#define _MODELICACASADI_DER_VAR
#include "RealVariable.hpp"
namespace ModelicaCasADi
{
class DerivativeVariable : public RealVariable {
    public:
        /**
         * Create a derivative variable. A derivative variable takes a pointer to
         * its corresponding state variable as argument.
         * @param A symbolic MX
         * @param A pointer to a Variable
         * @param A pointer to a VariableType, default is NULL
         */
        DerivativeVariable(CasADi::MX var, Variable* diffVar, VariableType* = NULL); 
        /** @return A pointer to a Variable */
        const Variable* getMyDifferentiatedVariable() const;
        /** @return True */
        bool isDerivative() const;
    private:
        Variable* myDifferentiatedVariable;
};
inline bool DerivativeVariable::isDerivative() const { return true; }
inline const Variable* DerivativeVariable::getMyDifferentiatedVariable() const { return myDifferentiatedVariable; }
}; // End namespace
#endif
