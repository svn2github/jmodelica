#ifndef _MODELICACASADI_BOOLEAN_VAR
#define _MODELICACASADI_BOOLEAN_VAR
#include <Variable.hpp>
namespace ModelicaCasADi
{
class BooleanVariable : public Variable {
    public:
        /**
         * Create a Boolean variable. Boolean variables may not have
         * continuous variability. 
         * @param A symbolic MX
         * @param A Causality enum
         * @param A Variability enum
         * @param A pointer to a VariableType, dafault is NULL. 
         */
        BooleanVariable(CasADi::MX var, Causality causality, 
                     Variability variability,
                     VariableType* declaredType = NULL);
        /** @return The Boolean Type enum */
        const Type getType() const;
};
inline const Variable::Type BooleanVariable::getType() const { return Variable::BOOLEAN; }
}; // End namespace
#endif
