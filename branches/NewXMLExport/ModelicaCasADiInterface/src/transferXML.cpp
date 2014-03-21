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
using ModelicaCasADi::Variable;
using ModelicaCasADi::RealVariable;
using ModelicaCasADi::IntegerVariable;
using ModelicaCasADi::BooleanVariable;
using std::string;
using tinyxml2::XMLElement;
using CasADi::MX;
using CasADi::MXVector;

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
		addFunctionHeaders(m, root);
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
		XMLElement* child = elem->FirstChildElement();
		if (!strcmp(child->Value(), "class") && !strcmp(child->Attribute("kind"), "function")) {
			// function transfers are handled in its own method for clarity
			transferFunction(m, elem);
		} else if (strcmp(child->Value(), "enumeration")) {
			string typeName = elem->Attribute("name");
			string baseTypeName = child->Attribute("name");
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
		std::stringstream errorMessage;
		errorMessage << "Extends clauses are not supported in the CasADiInterface";
		throw std::runtime_error(errorMessage.str());
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
			Ref<Variable> var =  m->getVariable(lhs->Attribute("name"));
			var->setAttribute("bindingExpression", expressionToMx(m, rhs));
		}
	}
}

/**
* Construct an MXFunction from the XML and adds it to the model
*/
void transferFunction(Ref<Model> m, XMLElement* elem) {
	XMLElement* child = elem->FirstChildElement();
	MXVector expressions = getFuncVars(m, child);
	MXVector vars = getFuncVars(m, child);
	MXVector inputVars = getInputVector(m, child);
	for (XMLElement* var = child->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (!strcmp(var->Value(), "algorithm")) {
			for (XMLElement* stmt = var->FirstChildElement(); stmt != NULL; stmt = stmt->NextSiblingElement()) {
				if (!strcmp(stmt->Value(), "return")) {
					break;
				}
				if (!strcmp(stmt->Value(), "assign")) {
					MXVector lhs = MXVector();
					XMLElement* left = stmt->FirstChildElement()->FirstChildElement();
					if (strcmp(left->Value(), "tuple")) {
						MX leftCas;
						int index = findIndex(vars, left->Attribute("name"));
						if (index != -1) {
							leftCas = vars.at(index);
						} else {
							leftCas = MX(left->Attribute("name"));
						}
						lhs.push_back(leftCas);
						MXVector rhs = MXVector();
						XMLElement* right = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement();
						MX rightCas = expressionToMx(m, right);
						rhs.push_back(rightCas);
						MX updated = CasADi::substitute(rhs, vars, expressions).at(0);
						index = findIndex(vars, lhs.at(0).getName());
						expressions.at(index) = updated;
					} else {
						for (XMLElement* tupleChild = left->FirstChildElement(); tupleChild != NULL; tupleChild = tupleChild->NextSiblingElement()) {
							MX leftCas;
							int index = findIndex(vars, tupleChild->Attribute("name"));
							if (index != -1) {
								leftCas = vars.at(index);
							} else {
								leftCas = MX(tupleChild->Attribute("name"));
							}
							lhs.push_back(leftCas);
						}
						XMLElement* right = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement()->FirstChildElement();
						string funcName = right->FirstChildElement()->Attribute("name");
						CasADi::MXFunction f = m->getModelFunction(funcName)->getMx();
						MXVector argVec = MXVector();
						for (XMLElement* arg = right->NextSiblingElement(); arg != NULL; arg = arg->NextSiblingElement()) {
							argVec.push_back(expressionToMx(m, arg));
						}
						MXVector outputs = f.call(argVec);
						MXVector updatedVec = CasADi::substitute(outputs, vars, expressions);
						for (int i=0; i < lhs.size(); ++i) {
							int index = findIndex(vars, lhs.at(i).getName());
							expressions.at(index) = updatedVec.at(i);
						}
					}
				}
			}
		}
	}
	MXVector outputVars = MXVector();
	int i=0;
	for (XMLElement* var = child->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (var->Attribute("causality") != NULL) {
			if (!strcmp(var->Attribute("causality"), "output")) {
				outputVars.push_back(expressions.at(i));
			}
		}
		i++;
	}
	CasADi::MXFunction f = CasADi::MXFunction(inputVars, outputVars);
	f.setOption("name", elem->Attribute("name"));
	f.init();
	m->setModelFunctionByItsName(new ModelicaCasADi::ModelFunction(f));
}

/**
* Construct the input vector used in a function and add input variables to the model
*/
MXVector getInputVector(Ref<Model> m, XMLElement* elem) {
	MXVector inputVars = MXVector();
	for (XMLElement* var = elem->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (!strcmp(var->Value(), "component")) {
			const char* causality = var->Attribute("causality");
			const char* variability = var->Attribute("variability");
			if (causality != NULL) {
				if (!strcmp(causality, "input")) {
					MX casVar = MX(var->Attribute("name"));
					inputVars.push_back(casVar);
					Ref<Variable> input = m->getVariable(var->Attribute("name"));
					if (input == NULL) {
						Ref<RealVariable> inputVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
							getVariability(variability), getUserType(m, var->FirstChildElement()));
						m->addVariable(inputVar);
					} else {
						input->setVar(casVar);
					}
				}
			}
		}
	}
	return inputVars;
}

/**
* Construct vector containing all variables in the function and add non-input variables
* to the model variable list
*/
MXVector getFuncVars(Ref<Model> m, XMLElement *elem) {
	MXVector vars = MXVector();
	for (XMLElement* var = elem->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (!strcmp(var->Value(), "component")) {
			const char* causality = var->Attribute("causality");
			const char* variability = var->Attribute("variability");
			MX casVar = MX(var->Attribute("name"));
			vars.push_back(casVar);
			if (causality != NULL) {
				// only add to model if it isn't an input
				if (strcmp(causality, "input")) {
					Ref<Variable> funcVar = m->getVariable(var->Attribute("name"));
					if (funcVar == NULL) {
						Ref<RealVariable> globalVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
							getVariability(variability), getUserType(m, var->FirstChildElement()));
						m->addVariable(globalVar);
					} else {
						funcVar->setVar(casVar);
					}
				}
			} else {
				Ref<Variable> funcVar = m->getVariable(var->Attribute("name"));
				if (funcVar == NULL) {
					Ref<RealVariable> globalVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
						getVariability(variability), getUserType(m, var->FirstChildElement()));
					m->addVariable(globalVar);
				} else {
					funcVar->setVar(casVar);
				}
			}
		}
	}
	return vars;
}

/**
* Add an variable of type real and its attributes to the Model object
*/
void addRealVariable(Ref<Model> m, XMLElement* variable) {
	MX var = MX(variable->Attribute("name"));
	const char* causality = variable->Attribute("causality");
	const char* variability = variable->Attribute("variability");
	const char* comment = variable->Attribute("comment");
	Ref<RealVariable> realVar = new RealVariable(m.getNode(), var, getCausality(causality), 
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
	MX var = MX(variable->Attribute("name"));
	const char* causality = variable->Attribute("causality");
	const char* variability = variable->Attribute("variability");
	const char* comment = variable->Attribute("comment");
	Ref<IntegerVariable> intVar = new IntegerVariable(m.getNode(), var, getCausality(causality), 
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
	MX var = MX(variable->Attribute("name"));
	const char* causality = variable->Attribute("causality");
	const char* variability = variable->Attribute("variability");
	const char* comment = variable->Attribute("comment");
	Ref<BooleanVariable> boolVar = new BooleanVariable(m.getNode(), var, getCausality(causality), 
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

/**
* Add an derivative variable to the model, no attributes are added in this case since 
* these are not accesible with the current way that imports works.
*/
void addDerivativeVar (Ref<Model> m, Ref<RealVariable> realVar, string name) {
	string derName = "der(";
	derName += name;
	derName += ")";
	MX derMx = MX(derName);
	ModelicaCasADi::Ref<ModelicaCasADi::DerivativeVariable> derVar = new ModelicaCasADi::DerivativeVariable(m.getNode(), derMx, realVar, NULL);
	realVar->setMyDerivativeVariable(derVar);
	// no attributes added since we can't access them
	m->addVariable(derVar);
}

/**
* Takes an XML node containing an expression and then returns a corresponding MX expression.
*/
CasADi::MX expressionToMx(Ref<Model> m, XMLElement* expression) {
	const char* name = expression->Value();
	if (!strcmp(name, "integer") || !strcmp(name, "real")) {
		return MX(atof(expression->Attribute("value")));
	} else if (!strcmp(name, "string")) {
		return MX(expression->Attribute("value"));
	} else if (!strcmp(name, "true")) {
		return MX(1);
	} else if (!strcmp(name, "false")) {
		return CasADi::MX(0);
	} else if (!strcmp(name, "local")) {
		if (m->getVariable(expression->Attribute("name")) != NULL) {
			return m->getVariable(expression->Attribute("name"))->getVar();
		}
		return MX(expression->Attribute("name"));
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
			XMLElement* func = expression->FirstChildElement();
			string funcName = func->FirstChildElement()->Attribute("name");
			CasADi::MXFunction f = m->getModelFunction(funcName)->getMx();
			MXVector argVec = MXVector();
			for (XMLElement* arg = func->NextSiblingElement(); arg != NULL; arg = arg->NextSiblingElement()) {
				argVec.push_back(expressionToMx(m, arg));
			}
			MXVector outputs = f.call(argVec);
			MX returnMx = MX();
			for (int i=0; i < outputs.size(); ++i) {
				returnMx.append(outputs.at(i));
			}
			return returnMx;
		}
	} else if (!strcmp(name, "builtin")) {
		// time variable
		if (!strcmp(expression->Attribute("name"), "time")) {
			if (m->getTimeVariable().isNull()) {
				MX timeMx = MX(expression->Attribute("name"));
				m->setTimeVariable(timeMx);
				return timeMx;
			} else {
				return m->getTimeVariable();
			}
		}
	} else if (!strcmp(name, "operator")) {
		if (!strcmp(expression->Attribute("name"), "der")) {
			// handle calls to the der operator, lookup if we have introduced a differentiated variable 
			// for this der call, if we have proceed as with all others functions calls if not continue by
			// adding a diff variable and add it to the lookup table
			XMLElement* derChild = expression->FirstChildElement();
			if (!strcmp(derChild->Value(), "local")) {
				const char* name = derChild->Attribute("name");
				string derCall = "der(";
				derCall.append(name);
				derCall.append(")");
				Ref<Variable> var = m->getVariable(name);
				Ref<RealVariable> realVar = (RealVariable*)var.getNode();
				if (!hasDerivativeVar(m, realVar)) {
					addDerivativeVar(m, realVar, name);
				}
				return MX(derCall);
			} else {
				string derCall = "der(";
				derCall.append(derChild->Attribute("value"));
				derCall.append(")");
				return MX(derCall);
			}
		} else if (!strcmp(expression->Attribute("name"), "pre")) {
			XMLElement* preChild = expression->FirstChildElement();
			string preCall = "pre(";
			preCall.append(preChild->Attribute("name"));
			preCall.append(")");
			return MX(preCall);
		} else if (!strcmp(expression->Attribute("name"), "assert")) {
			// ignore asserts
		} else if (!strcmp(expression->Attribute("name"), "time")) {
			return MX("time");
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
		XMLElement* elseBranch = branching->NextSiblingElement()->NextSiblingElement()->FirstChildElement();
		return CasADi::if_else(expressionToMx(m, condition), expressionToMx(m, thenBranch), expressionToMx(m, elseBranch));
	} else if (!strcmp(name, "tuple")) {
		MX left = MX();
		for (XMLElement* child = expression->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
			left.append(MX(child->Attribute("name")));
		}
		return left;
	} else {
		// unsupported expressions come here, throw an error for now
		std::stringstream errorMessage;
		errorMessage << "Unsupported expression: " << expression->Value();
		throw std::runtime_error(errorMessage.str());
	}
	return MX();
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
* Applies an builtin unary function to an MX expression and returns the result
*/
MX builtinUnaryToMx(MX exp, const char* builtinName) {
	if (!strcmp(builtinName, "sin")) {
		return exp.sin();
	} else if (!strcmp(builtinName, "sinh")) {
		return exp.sinh();
	} else if (!strcmp(builtinName, "asin")) {
		return exp.arcsin();
	} else if (!strcmp(builtinName, "cos")) {
		return exp.cos();
	} else if (!strcmp(builtinName, "cosh")) {
		return exp.cosh();
	} else if (!strcmp(builtinName, "acos")) {
		return exp.arccos();
	} else if (!strcmp(builtinName, "tan")) {
		return exp.tan();
	} else if (!strcmp(builtinName, "tanh")) {
		return exp.tanh();
	} else if (!strcmp(builtinName, "atan")) {
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
* Applies an builtin binary function to two MX expressions and returns the result
*/
MX builtinBinaryToMx(MX lhs, MX rhs, const char* builtinName) {
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
	} else if (!strcmp(builtinName, "atan2")) {
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
bool hasDerivativeVar(Ref<Model> m, Ref<RealVariable> realVar) {
	if (realVar->getMyDerivativeVariable() != NULL) {
		return true;
	}
	return false;
}

/**
* Convert an basetype string to the actual object type
*/
Ref<ModelicaCasADi::PrimitiveType> getBaseType(Ref<Model> m, string baseTypeName) {
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

/**
* Takes an model and an XMLElement that points to an variable, retrieve
* the derived type of the variable from the model.
*/
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

/**
* Helper function used when transferring functions to find the index of MX element
* in an MXVector
*/
int findIndex(MXVector vector, string elem) {
	for (int i=0; i < vector.size(); ++i) {
		if (elem == vector.at(i).getName()) {
			return i;
		}
	}
	return -1;
}

/**
* Method that adds function headers to the model object so that import of
* functions with function calls to other functions will work properly
* if the other function is not already imported.
*/
void addFunctionHeaders(Ref<Model> m, XMLElement* elem) {
	for (XMLElement* child = elem->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
		if (!strcmp(child->Value(), "classDefinition")) {
			XMLElement* function = child->FirstChildElement();
			if (!strcmp(function->Value(), "class") && !strcmp(function->Attribute("kind"), "function")) {
				MXVector inputVars = MXVector();
				MXVector expressions = MXVector();
				MXVector outputVars = MXVector();
				int i=0;
				for (XMLElement* var = function->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
					if (!strcmp(var->Value(), "component")) {
						MX casVar = MX(var->Attribute("name"));
						const char* causality = var->Attribute("causality");
						expressions.push_back(casVar);
						if (causality != NULL) {
							if (!strcmp(causality, "output")) {
								outputVars.push_back(expressions.at(i));
							} else if (!strcmp(causality, "input")) {
								inputVars.push_back(casVar);
							}
						}
					}
					i++;
				}
				CasADi::MXFunction f = CasADi::MXFunction(inputVars, outputVars);
				f.setOption("name", child->Attribute("name"));
				f.init();
				m->setModelFunctionByItsName(new ModelicaCasADi::ModelFunction(f));
			}
		}
	}
}
