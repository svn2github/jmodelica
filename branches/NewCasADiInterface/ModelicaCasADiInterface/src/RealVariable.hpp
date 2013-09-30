#ifndef _MODELICACASADI_REAL_VAR
#define _MODELICACASADI_REAL_VAR
#include "Variable.hpp"
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
inline void RealVariable::setMyDerivativeVariable(Variable* diffVar) { 
	RealVariable* dVar = dynamic_cast<RealVariable*>(diffVar);
	if (dVar != NULL ) {
		if( !dVar->isDerivative()) {
			throw std::runtime_error("A Variable that is set as a derivative variable must be a DerivativeVariable");
		}
	} else {
		throw std::runtime_error("A Variable that is set as a derivative variable must be a DerivativeVariable");
	}
    if (getVariability() != Variable::CONTINUOUS || isDerivative()) {
        throw std::runtime_error("A RealVariable that is a state variable must have continuous variability, and may not be a derivative variable.");
    }
    myDerivativeVariable = diffVar; 	
}
inline const Variable* RealVariable::getMyDerivativeVariable() const { return myDerivativeVariable; }
inline bool RealVariable::isDerivative() const { return false; }
}; // End namespace
#endif
