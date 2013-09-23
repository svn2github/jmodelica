#ifndef _MODELICACASADI_REAL_VAR
#define _MODELICACASADI_REAL_VAR
#include <Variable.hpp>
namespace ModelicaCasADi
{
class RealVariable : public Variable {
    public:
        /**
         * Create a RealVariable.
         * @param A symbolic MX.
         * @param An entry of the enum Causality
         * @param An entry of the enum Variability
         * @param A pointer to a VariableType, default is NULL.
         */
        RealVariable(CasADi::MX var, Causality causality, 
                     Variability variability,
                     VariableType* declaredType = NULL);
        /**
         * @return The type Real.
         */
        const Type getType() const;
        /**
         * If this is a state variable, set its derivative variable
         * @param A pointer to a Variable. 
         */
        void setMyDerivativeVariable(Variable* derVar);
        /**
         * @return Returns a pointer, which may be NULL, to the derivative variable
         */
        const Variable* getMyDerivativeVariable() const;
        /** @return False */
        virtual bool isDerivative() const;
    private:
        Variable* myDerivativeVariable;
};
inline const Variable::Type RealVariable::getType() const { return Variable::REAL; }
inline void RealVariable::setMyDerivativeVariable(Variable* diffVar) { myDerivativeVariable = diffVar; }
inline const Variable* RealVariable::getMyDerivativeVariable() const { return myDerivativeVariable; }
inline bool RealVariable::isDerivative() const { return false; }
}; // End namespace
#endif
