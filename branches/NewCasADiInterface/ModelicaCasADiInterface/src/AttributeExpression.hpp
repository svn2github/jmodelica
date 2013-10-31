/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
