#ifndef _MODELICACASADI_ATTRIBUTE_EXPRESSION
#define _MODELICACASADI_ATTRIBUTE_EXPRESSION
#include <symbolic/casadi.hpp>
namespace ModelicaCasADi
{
struct AttributeProxy {
    CasADi::MX mxVal;
    std::string stringVal;
    operator CasADi::MX()  const { return mxVal; }
    operator std::string() const { return stringVal; }
};

class AttributeExpression {
	public: 
		AttributeExpression(CasADi::MX expression);
		AttributeExpression(std::string expression);
		AttributeProxy getValue() const;
	protected:
		AttributeProxy expressionProxy;
};
inline AttributeExpression::AttributeExpression(CasADi::MX expression)  : expressionProxy() {
		expressionProxy.mxVal = expression;
	}
inline AttributeExpression::AttributeExpression(std::string expression) : expressionProxy() {
		expressionProxy.stringVal = expression;
	}
inline AttributeProxy AttributeExpression::getValue() const { return expressionProxy; }
}; // End namespace
#endif
