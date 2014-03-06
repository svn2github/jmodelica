/*
Copyright (C) 2014 Modelon AB
	
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

#include "transferXML.hpp"

using ModelicaCasADi::Model;
using ModelicaCasADi::Ref;
using std::string;
using tinyxml2::XMLElement;

/**
* Parses an XML document representing an Modelica model and then
* construct an Model object from the XML.
*/
Ref<Model> transferXmlModel (Ref<Model> m, string modelName, const std::vector<string> &modelFiles) {
	m->initializeModel(modelName);
	string fullPath;
	for (int i=0;i<modelFiles.size();++i) {
		fullPath += modelFiles[i];
	}
	const char* fileName = fullPath.c_str();
	tinyxml2::XMLDocument doc;
	if (doc.LoadFile(fileName)) {
		std::stringstream errorMessage;
		errorMessage << "Could not load XML document";
		throw std::runtime_error(errorMessage.str());
	}
	XMLElement* root = doc.FirstChildElement();
	if (root != NULL) {
		for (XMLElement* elem = root->FirstChildElement(); elem != NULL; elem = elem->NextSiblingElement()) {
			if (!strcmp(elem->Value(), "component") || !strcmp(elem->Value(), "classDefinition") 
				|| !strcmp(elem->Value(), "extends")) {
				// handle variables
				transferVariables(m, elem);
			} else if (!strcmp(elem->Value(), "equation")) {
				const char* equType = elem->Attribute("kind");
				if (equType != NULL) {
					if (!strcmp(equType, "initial")) {
						// handle initial equations
						transferInitialEquations(m, elem);
					} else if (!strcmp(equType, "parameter")) {
						transferParameters(m, elem);
					}
				} else {
					// handle equations
					transferEquations(m, elem);
				}
			}
		}
	} else {
		std::stringstream errorMessage;
		errorMessage << "XML document does not have any root node";
		throw std::runtime_error(errorMessage.str());
	}
	return m;
}

/*
* Takes an model and an pointer to the start of the variables in the DOM, traverse all variables
* ín the DOM and construct a Variable object from each variable and add them to the model m
*/
void transferVariables(Ref<Model> m, XMLElement* elem) {
	if (!strcmp(elem->Value(), "component")) {
		XMLElement* child = elem->FirstChildElement();
		if (!strcmp(child->Value(), "builtin")) {
			const char* type = child->Attribute("name");
			if (!strcmp(type, "Real")) {
				addRealVariable(m, elem);
			} else if (!strcmp(type, "Integer")) {
				addIntegerVariable(m, elem);
			} else if (!strcmp(type, "Boolean")) {
				addBooleanVariable(m, elem);
			} else {
				// string variable which is not supported in the casadi interface
			}
		} else if (!strcmp(child->Value(), "local")) {
			Ref<ModelicaCasADi::UserType> userType = (ModelicaCasADi::UserType*) m->getVariableType(child->Attribute("name")).getNode();
			Ref<ModelicaCasADi::PrimitiveType> prim = userType->getBaseType();
			if (prim->getName() == "Real") {
				addRealVariable(m, elem);
			} else if (prim->getName() == "Integer") {
				addIntegerVariable(m, elem);
			} else if (prim->getName() == "Boolean") {
				addBooleanVariable(m, elem);
			}
		}
	} else if(!strcmp(elem->Value(), "classDefinition")) {
		// maybe put in separate method for clearer code
		XMLElement* child = elem->FirstChildElement();
		if (strcmp(child->Value(), "enumeration")) {
			std::string typeName = elem->Attribute("name");
			std::string baseTypeName = child->Attribute("name");
			Ref<ModelicaCasADi::UserType> userType = new ModelicaCasADi::UserType(typeName, getBaseType(m, baseTypeName));
			for (child = child->NextSiblingElement(); child != NULL; child = child->NextSiblingElement()) {
				if (!strcmp(child->Value(), "modifier")) {
					for (XMLElement* item = child->FirstChildElement(); item != NULL; item = item->NextSiblingElement()) {
						XMLElement* itemExpression = item->FirstChildElement();
						userType->setAttribute(item->Attribute("name"), expressionToMx(m, itemExpression));
					}
				}
			}
			m->addNewVariableType(userType);
		}
	} else {
		// extends clause, not supported in casadiinterface
	}
}

/**
* Takes an model and an pointer to the start of the initial equation section in the DOM,
* traverses the equations in the DOM and add the equations to the model object.
*/
void transferInitialEquations (Ref<Model> m, XMLElement* elem) {
	for (XMLElement* initEquation = elem->FirstChildElement(); initEquation != NULL; initEquation = initEquation->NextSiblingElement()) {
		if (!strcmp(initEquation->Value(), "equal")) {
			XMLElement* lhs = initEquation->FirstChildElement();
			XMLElement* rhs = lhs->NextSiblingElement();
			m->addInitialEquation(new ModelicaCasADi::Equation (expressionToMx(m, lhs), expressionToMx(m, rhs)));
		}
	}
}

/**
* Takes an model and an pointer to the start of the equations in the DOM, traverses
* all equations in the DOM and add the equations to the model object. Only handles
* equality equations until support for other equation types are added.
*/
void transferEquations(Ref<Model> m, XMLElement* elem) {
	for (XMLElement* equation = elem->FirstChildElement(); equation != NULL; equation = equation->NextSiblingElement()) {
		if (!strcmp(equation->Value(), "equal")) {
			XMLElement* lhs = equation->FirstChildElement();
			XMLElement* rhs = lhs->NextSiblingElement();
			m->addDaeEquation(new ModelicaCasADi::Equation (expressionToMx(m, lhs), expressionToMx(m, rhs)));
		}
	}
}

/**
* Takes an parameter equation and get the variable on the lefthand side from the model object.
* The righthand side expression is then set as a bindingexpression to the lhs variable.
*/
void transferParameters(Ref<Model> m, XMLElement* elem) {
	for (XMLElement* parameter = elem->FirstChildElement(); parameter != NULL; parameter = parameter->NextSiblingElement()) {
		if (!strcmp(parameter->Value(), "equal")) {
			XMLElement* lhs = parameter->FirstChildElement();
			XMLElement* rhs = lhs->NextSiblingElement();
			Ref<ModelicaCasADi::Variable> var =  m->getVariable(lhs->Attribute("name"));
			var->setAttribute("bindingExpression", expressionToMx(m, rhs));
		}
	}
}

/**
* Add an variable of type real and its attributes to the Model object
*/
void addRealVariable(Ref<Model> m, XMLElement* variable) {
	CasADi::MX var = CasADi::MX(variable->Attribute("name"));
	const char* causality = variable->Attribute("causality");
	const char* variability = variable->Attribute("variability");
	const char* comment = variable->Attribute("comment");
	Ref<ModelicaCasADi::RealVariable> realVar = new ModelicaCasADi::RealVariable(m.getNode(), var, getCausality(causality), 
		getVariability(variability), getUserType(m, variable->FirstChildElement()));
	if (comment != NULL) {
		realVar->setAttribute("comment", CasADi::MX(comment));
	}
	for (XMLElement* child = variable->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
		if (!strcmp(child->Value(), "bindingExpression")) {
			XMLElement* expression = child->FirstChildElement();
			realVar->setAttribute("bindingExpression", expressionToMx(m, expression));
		} else if (!strcmp(child->Value(), "modifier")) {
			for (XMLElement* item = child->FirstChildElement(); item != NULL; item = item->NextSiblingElement()) {
				XMLElement* itemExpression = item->FirstChildElement();
				realVar->setAttribute(item->Attribute("name"), expressionToMx(m, itemExpression));
			}
		}
	}
	m->addVariable(realVar);
}

/**
* Add an variable of type integer and its attributes to the Model object
*/
void addIntegerVariable(Ref<Model> m, XMLElement* variable) {
	CasADi::MX var = CasADi::MX(variable->Attribute("name"));
	const char* causality = variable->Attribute("causality");
	const char* variability = variable->Attribute("variability");
	const char* comment = variable->Attribute("comment");
	Ref<ModelicaCasADi::IntegerVariable> intVar = new ModelicaCasADi::IntegerVariable(m.getNode(), var, getCausality(causality), 
		getVariability(variability), getUserType(m, variable->FirstChildElement()));
	if (comment != NULL) {
		intVar->setAttribute("comment", CasADi::MX(comment));
	}
	for (XMLElement* child = variable->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
		if (!strcmp(child->Value(), "bindingExpression")) {
			XMLElement* expression = child->FirstChildElement();
			intVar->setAttribute("bindingExpression", expressionToMx(m, expression));
		} else if (!strcmp(child->Value(), "modifier")) {
			for (XMLElement* item = child->FirstChildElement(); item != NULL; item = item->NextSiblingElement()) {
				XMLElement* itemExpression = item->FirstChildElement();
				intVar->setAttribute(item->Attribute("name"), expressionToMx(m, itemExpression));
			}
		}
	}
	m->addVariable(intVar);
}

/**
* Add an variable of type boolean and its attributes to the Model object
*/
void addBooleanVariable(Ref<Model> m, XMLElement* variable) {
	CasADi::MX var = CasADi::MX(variable->Attribute("name"));
	const char* causality = variable->Attribute("causality");
	const char* variability = variable->Attribute("variability");
	const char* comment = variable->Attribute("comment");
	Ref<ModelicaCasADi::BooleanVariable> boolVar = new ModelicaCasADi::BooleanVariable(m.getNode(), var, getCausality(causality), 
		getVariability(variability), getUserType(m, variable->FirstChildElement()));
	if (comment != NULL) {
		boolVar->setAttribute("comment", CasADi::MX(comment));
	}
	for (XMLElement* child = variable->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
		if (!strcmp(child->Value(), "bindingExpression")) {
			XMLElement* expression = child->FirstChildElement();
			boolVar->setAttribute("bindingExpression", expressionToMx(m, expression));
		} else if (!strcmp(child->Value(), "modifier")) {
			for (XMLElement* item = child->FirstChildElement(); item != NULL; item = item->NextSiblingElement()) {
				XMLElement* itemExpression = item->FirstChildElement();
				boolVar->setAttribute(item->Attribute("name"), expressionToMx(m, itemExpression));
			}
		}
	}
	m->addVariable(boolVar);
}


void addDerivativeVar (Ref<Model> m, Ref<ModelicaCasADi::RealVariable> realVar, string name) {
	string derName = "der(";
	derName += name;
	derName += ")";
	CasADi::MX derMx = CasADi::MX(derName);
	ModelicaCasADi::Ref<ModelicaCasADi::DerivativeVariable> derVar = new ModelicaCasADi::DerivativeVariable(m.getNode(), derMx, realVar, NULL);
	realVar->setMyDerivativeVariable(derVar);
	// no attributes added since we can't access them
	m->addVariable(derVar);
}

/**
* Takes an XML node containing an expression and then returns a corresponding MX expression
*/
CasADi::MX expressionToMx(Ref<Model> m, XMLElement* expression) {
	const char* name = expression->Value();
	if (!strcmp(name, "integer") || !strcmp(name, "real")) {
		return CasADi::MX(atof(expression->Attribute("value")));
	} else if (!strcmp(name, "string")) {
		return CasADi::MX(expression->Attribute("value"));
	} else if (!strcmp(name, "true")) {
		return CasADi::MX(1);
	} else if (!strcmp(name, "false")) {
		return CasADi::MX(0);
	} else if (!strcmp(name, "local")) {
		return CasADi::MX(expression->Attribute("name"));
	} else if (!strcmp(name, "call")) {
		const char* builtinAttr = expression->Attribute("builtin");
		if (builtinAttr != NULL) {
			// builtin function call, e.g. sin, +...
			XMLElement* lhs = expression->FirstChildElement();
			XMLElement* rhs = lhs->NextSiblingElement();
			if (rhs != NULL) { // binary
				return builtinBinaryToMx(expressionToMx(m, lhs), expressionToMx(m, rhs), builtinAttr);
			} else { // unary
				return builtinUnaryToMx(expressionToMx(m, lhs), builtinAttr);
			}
		} else {
			// regular function calls, how to handle these?
		}
	} else if (!strcmp(name, "operator")) {
		if (!strcmp(expression->Attribute("name"), "der")) {
			// handle calls to the der operator, lookup if we have introduced a differentiated variable 
			// for this der call, if we have proceed as with all others functions calls if not continue by
			// adding a diff variable and add it to the lookup table
			XMLElement* derChild = expression->FirstChildElement();
			if (!strcmp(derChild->Value(), "local")) {
				const char* name = derChild->Attribute("name");
				std::string derCall = "der(";
				derCall.append(name);
				derCall.append(")");
				Ref<ModelicaCasADi::Variable> var = m->getVariable(name);
				Ref<ModelicaCasADi::RealVariable> realVar = (ModelicaCasADi::RealVariable*)var.getNode();
				if (!hasDerivativeVar(m, realVar)) {
					addDerivativeVar(m, realVar, name);
				}
				return CasADi::MX(derCall);
			} else {
				std::string derCall = "der(";
				derCall.append(derChild->Attribute("value"));
				derCall.append(")");
				return CasADi::MX(derCall);
			}
		} else if (!strcmp(expression->Attribute("name"), "pre")) {
			XMLElement* preChild = expression->FirstChildElement();
			std::string preCall = "pre(";
			preCall.append(preChild->Attribute("name"));
			preCall.append(")");
			return CasADi::MX(preCall);
		} else if (!strcmp(expression->Attribute("name"), "assert")) {
			// ignore asserts
		} else if (!strcmp(expression->Attribute("name"), "time")) {
			return CasADi::MX("time");
		} else {
			// unsupported operators
			std::stringstream errorMessage;
			errorMessage << "Unsupported operator: " <<  expression->Attribute("name");
			throw std::runtime_error(errorMessage.str());
		}
	} else if (!strcmp(name, "if")) {
		XMLElement* branching = expression->FirstChildElement();
		XMLElement* condition = branching->FirstChildElement();
		XMLElement* thenBranch = branching->NextSiblingElement()->FirstChildElement();
		XMLElement* elseBranch = branching->NextSiblingElement()->FirstChildElement();
		return CasADi::if_else(expressionToMx(m, condition), expressionToMx(m, thenBranch), expressionToMx(m, elseBranch));
	} else {
		// unsupported expressions come here, throw an error for now
		std::stringstream errorMessage;
		errorMessage << "Unsupported expression: " << expression->Attribute("name");
		throw std::runtime_error(errorMessage.str());
	}
	return CasADi::MX();
}

/**
* Takes an causality string and returns a corresponding causality enum value.
*/
ModelicaCasADi::Variable::Causality getCausality(const char* causality) {
	if (causality == NULL) {
		return ModelicaCasADi::Variable::INTERNAL;
	}
	
	if (!strcmp(causality, "input")) {
		return ModelicaCasADi::Variable::INPUT;
	} else {
		return ModelicaCasADi::Variable::OUTPUT;
	}
}

/**
* Takes an variability string and returns a corresponding variability enum value.
*/
ModelicaCasADi::Variable::Variability getVariability(const char* variability) {
	if (variability == NULL) {
		return ModelicaCasADi::Variable::CONTINUOUS;
	}

	if (!strcmp(variability, "parameter")) {
		return ModelicaCasADi::Variable::PARAMETER;
	} else if (!strcmp(variability, "discrete")) {
		return ModelicaCasADi::Variable::DISCRETE;
	} else {
		return ModelicaCasADi::Variable::CONSTANT;
	}
}

/**
* Applies an builtin unary function to an casadi expression and returns the result
*/
CasADi::MX builtinUnaryToMx(CasADi::MX exp, const char* builtinName) {
	if (!strcmp(builtinName, "sin")) {
		return exp.sin();
	} else if (!strcmp(builtinName, "sinh")) {
		return exp.sinh();
	} else if (!strcmp(builtinName, "arcsin")) {
		return exp.arcsin();
	} else if (!strcmp(builtinName, "cos")) {
		return exp.cos();
	} else if (!strcmp(builtinName, "cosh")) {
		return exp.cosh();
	} else if (!strcmp(builtinName, "arccos")) {
		return exp.arccos();
	} else if (!strcmp(builtinName, "tan")) {
		return exp.tan();
	} else if (!strcmp(builtinName, "tanh")) {
		return exp.tanh();
	} else if (!strcmp(builtinName, "arctan")) {
		return exp.arctan();
	} else if (!strcmp(builtinName, "log")) {
		return exp.log();
	} else if (!strcmp(builtinName, "log10")) {
		return exp.log10();
	} else if (!strcmp(builtinName, "sqrt")) {
		return exp.sqrt();
	} else if (!strcmp(builtinName, "abs")) {
		return exp.fabs();
	} else if (!strcmp(builtinName, "exp")) {
		return exp.exp();
	} else if (!strcmp(builtinName, "-")) {
		return -exp;
	} else {
		std::stringstream errorMessage;
		errorMessage << "Unsupported unary expression: " << builtinName;
		throw std::runtime_error(errorMessage.str());
	}
	// should not happen
	return exp;
}

/**
* Applies an builtin binary function to two expressions and returns the result
*/
CasADi::MX builtinBinaryToMx(CasADi::MX lhs, CasADi::MX rhs, const char* builtinName) {
	if (!strcmp(builtinName, "+")) {
		return lhs.__add__(rhs);
	} else if (!strcmp(builtinName, "-")) {
		return lhs.__sub__(rhs);
	} else if (!strcmp(builtinName, "*")) {
		return lhs.__mul__(rhs);
	} else if (!strcmp(builtinName, "/")) {
		return lhs.__div__(rhs);
	} else if (!strcmp(builtinName, "^")) {
		return lhs.__pow__(rhs);
	} else if (!strcmp(builtinName, "min")) {
		return lhs.fmin(rhs);
	} else if (!strcmp(builtinName, "max")) {
		return lhs.fmax(rhs);
	} else if (!strcmp(builtinName, "arctan2")) {
		return lhs.arctan2(rhs);
	} else if (!strcmp(builtinName, ">")) {
		return rhs.__lt__(lhs);
	} else if (!strcmp(builtinName, "<")) {
		return lhs.__lt__(rhs);
	} else if (!strcmp(builtinName, ">=")) {
		return rhs.__le__(lhs);
	} else if (!strcmp(builtinName, "<=")) {
		return lhs.__le__(rhs);
	} else if (!strcmp(builtinName, "==")) {
		return lhs.__eq__(rhs);
	} else if (!strcmp(builtinName, "<>")) {
		return lhs.__ne__(rhs);
	} else if (!strcmp(builtinName, "and")) {
		return lhs.logic_and(rhs);
	} else if (!strcmp(builtinName, "or")) {
		return lhs.logic_or(rhs);
	} else {
		std::stringstream errorMessage;
		errorMessage << "Unsupported binary expression: " << builtinName;
		throw std::runtime_error(errorMessage.str());
	}
	// should not happen
	return lhs;
}

/**
* Check if an variable has an derivative variable linked to it
*/
bool hasDerivativeVar(Ref<Model> m, Ref<ModelicaCasADi::RealVariable> realVar) {
	if (realVar->getMyDerivativeVariable() != NULL) {
		return true;
	}
	return false;
}

Ref<ModelicaCasADi::PrimitiveType> getBaseType(Ref<Model> m, std::string baseTypeName) {
	if (m->getVariableType(baseTypeName).getNode() == NULL) {
		if (baseTypeName == "Real") {
			m->addNewVariableType(new ModelicaCasADi::RealType);
		} else if (baseTypeName == "Integer") {
			m->addNewVariableType(new ModelicaCasADi::IntegerType);
		} else if (baseTypeName == "Boolean") {
			m->addNewVariableType(new ModelicaCasADi::BooleanType);
		}
	}
	return (ModelicaCasADi::PrimitiveType*) m->getVariableType(baseTypeName).getNode();
}

Ref<ModelicaCasADi::UserType> getUserType(Ref<Model> m, XMLElement* elem) {
	if (!strcmp(elem->Value(), "local")) {
		Ref<ModelicaCasADi::UserType> userType = (ModelicaCasADi::UserType*) m->getVariableType(elem->Attribute("name")).getNode();
		if (userType.getNode() == NULL) {
			throw std::runtime_error("Variables derived type is not present in Model");
		}
		return userType;
	}
	return NULL;
}
