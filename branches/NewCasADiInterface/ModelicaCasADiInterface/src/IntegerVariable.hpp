#ifndef _MODELICACASADI_INTEGER_VAR
#define _MODELICACASADI_INTEGER_VAR
#include <Variable.hpp>
namespace ModelicaCasADi
{
class IntegerVariable : public Variable {
    public:
        /**
         * Create an Integer Variable. 
         * An integer Variable may not have continuous variability. 
         * @param A symbolic MX
         * @param A Causality enum
         * @param A Variability enum
         * @param A pointer to a VariableType, dafault is NULL. 
         */ 
        IntegerVariable(CasADi::MX var, Causality causality, 
                     Variability variability,
                     VariableType* declaredType = NULL);
        /** @param The Integer Type enum */
        const Type getType() const;
};
inline const Variable::Type IntegerVariable::getType() const { return Variable::INTEGER; }
}; // End namespace
#endif
