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

namespace ModelicaCasADi {

// used to keep track of local function variables 
std::map<string, ModelicaCasADi::Variable*> funcVars;

// used for keeping the dimensions of array variables
std::map<string, std::vector<int> > dimensionMap;

/**
 * Parses an XML document representing an Modelica model and then
 * construct an Model object from the XML and return this Model.
 */
Ref<Model> transferXmlModel (Ref<Model> m, string modelName, const std::vector<string> &modelFiles) {
	m->initializeModel(modelName);
	string fullPath;
	for (int i=0; i < modelFiles.size(); i++) {
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
		// add function headers first so all functions can be imported
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
			} else {
				// do nothing
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
				std::stringstream errorMessage;
				errorMessage << "Variables of type string is not supported in CasADiInterface";
				throw std::runtime_error(errorMessage.str());
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
		} else if (!strcmp(child->Value(), "class") && !strcmp(child->Attribute("kind"), "record")) {
			// store information about record so that it can be used in import, how?
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
			MX finalLhs = MX();
			MX finalRhs = MX();
			XMLElement* lhs = initEquation->FirstChildElement();
			XMLElement* rhs = lhs->NextSiblingElement();
			MX left = expressionToMx(m, lhs);
			MX right = expressionToMx(m, rhs);
			for (int i=0; i < left.size(); i++) {
				if (left.at(i).getName() != "dummy") {
					finalLhs.append(left.at(i));
					finalRhs.append(right.at(i));
				}
			}
			m->addInitialEquation(new ModelicaCasADi::Equation (finalLhs, finalRhs));
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
			MX finalLhs = MX();
			MX finalRhs = MX();
			XMLElement* lhs = equation->FirstChildElement();
			XMLElement* rhs = lhs->NextSiblingElement();
			MX left = expressionToMx(m, lhs);
			MX right = expressionToMx(m, rhs);
			if (left.size() > 1) {
				for (int i=0; i < left.size(); i++) {
					if (left.at(i).getName() != "dummy") {
						finalLhs.append(left.at(i));
						finalRhs.append(right.at(i));
					}
				}
			} else {
				finalLhs = left;
				finalRhs = right;
			}
			m->addDaeEquation(new ModelicaCasADi::Equation (finalLhs, finalRhs));
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
			MX left = expressionToMx(m, lhs);
			MX right = expressionToMx(m, rhs);
			for (int i=0; i< right.size(); i++) {
				if (left.at(i).getName() != "dummy") {
					Ref<Variable> var = m->getVariable(left.at(i).getName());
					if (var == NULL) {
						// should not happen since all parameter variables are added to model
					} else {
						var->setAttribute("bindingExpression", right.at(i));
					}
				}
			}
		}
	}
}

/**
 * Construct an MXFunction from the XML and adds it to the model
 * TODO: Split up in several smaller parts, one for handling assignments and one for functioncalls
 */
void transferFunction(Ref<Model> m, XMLElement* elem) {
	string functionName = elem->Attribute("name");
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
					XMLElement* left = stmt->FirstChildElement()->FirstChildElement();
					XMLElement* checkRight = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement();
					// update function variables to reflect function call
					if (left != NULL && !strcmp(checkRight->Value(), "call") && !(checkRight->Attribute("builtin") != NULL &&
						strcmp(checkRight->Attribute("builtin"), "array"))) {
							updateFunctionCall(m, stmt, expressions, vars, functionName);
					} else if (left != NULL) {
						MXVector lhs = MXVector();
						MX leftCas;
						if (!strcmp(left->Value(), "reference")) {
							int flatIndex = calculateFlatArrayIndex(m, left, functionName);
							string varName(left->FirstChildElement()->Attribute("name"));
							std::stringstream ss;
							ss << flatIndex;
							varName += "_" + ss.str();
							int index = findIndex(vars, varName);
							if (index != -1) {
								leftCas = vars.at(index);
							} else {
								leftCas = MX(varName);
							}
						} else {
							int index = findIndex(vars, left->Attribute("name"));
							if (index != -1) {
								leftCas = vars.at(index);
							} else {
								leftCas = MX(left->Attribute("name"));	
							}
						}
						lhs.push_back(leftCas);
						MXVector rhs = MXVector();
						XMLElement* right = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement();
						MX rightCas = expressionToMx(m, right);
						rhs.push_back(rightCas);
						MX updated = CasADi::substitute(rhs, vars, expressions).at(0);
						int index = findIndex(vars, lhs.at(0).getName());
						expressions.at(index) = updated;
					}
				}
			}
		}
	}
	MXVector outputVars = MXVector();
	int index=0;
	for (XMLElement* var = child->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (var->Attribute("causality") != NULL && !strcmp(var->Attribute("causality"), "output")) {
			XMLElement* outputElem = var->FirstChildElement()->NextSiblingElement();
			if (outputElem != NULL && !strcmp(outputElem->Value(), "dimension")) {
				std::vector<int> dimensions = dimensionMap.find((functionName + var->Attribute("name")))->second;
				int nbrOutputVars = 1;
				for (int j=0; j < dimensions.size(); j++) {
					nbrOutputVars *= dimensions.at(j);
				}
				for (int j=0; j < nbrOutputVars; j++) {
					outputVars.push_back(expressions.at(index));
					index++;
				}
			} else {
				outputVars.push_back(expressions.at(index));
				index++;
			}
		} else {
			XMLElement* indexElem = var->FirstChildElement()->NextSiblingElement();
			if (indexElem != NULL && !strcmp(indexElem->Value(), "dimension")) {
				std::vector<int> dimensions = dimensionMap.find((functionName + var->Attribute("name")))->second;
				int nbrVars = 1;
				for (int j=0; j < dimensions.size(); j++) {
					nbrVars *= dimensions.at(j);
				}
				index += nbrVars;
			} else {
				index++;
			}
		}
	}
	CasADi::MXFunction f = CasADi::MXFunction(inputVars, outputVars);
	f.setOption("name", elem->Attribute("name"));
	f.init();
	m->setModelFunctionByItsName(new ModelicaCasADi::ModelFunction(f));
}

/**
 * Handles the updating of function calls in functions. The expression vector which
 * contains the current MX for all variables in the functions is updated by
 * running the function call and then substitute in the outputs.
 */
void updateFunctionCall(Ref<Model> m, XMLElement* stmt, MXVector &expressions, MXVector &vars, string functionName) {
	XMLElement* left = stmt->FirstChildElement()->FirstChildElement();
	MXVector lhs = MXVector();
	if (!strcmp(left->Value(), "tuple")) {
		for (XMLElement* tupleChild = left->FirstChildElement(); tupleChild != NULL; tupleChild = tupleChild->NextSiblingElement()) {
			if (!strcmp(tupleChild->Value(), "nothing")) {
				// add an emtpy mx if there are an empty spot in the tuple
				lhs.push_back(MX());
			} else {
				MX leftCas;
				int index = findIndex(vars, tupleChild->Attribute("name"));
				if (index != -1) {
					leftCas = vars.at(index);
				} else {
					leftCas = MX(tupleChild->Attribute("name"));
				}
				lhs.push_back(leftCas);
			}
		}
	} else if (!strcmp(left->Value(), "local")) {
		string varName = left->Attribute("name");
		for (XMLElement* leftChild = left->FirstChildElement(); leftChild != NULL; leftChild = leftChild->NextSiblingElement()) {
			// add members to name
			if (!strcmp(leftChild->Value(), "member")) {
				varName += ".";
				varName += leftChild->Attribute("name");
			}
		}
		int index = findIndex(vars, varName);
		if (index != -1) {
			lhs.push_back(vars.at(index));
		} else {
			// check if this local variable is an array by looking it up in the dimensions map
			// if it is we need to handle it by constructing the scalar variable names
			// and lookup them in the vars so that the correct variables are swapped
			if (dimensionMap.count((functionName + varName)) != 0) {
				std::vector<string> arrayVars = getArrayVariables(left, functionName);
				for (int i=0; i < arrayVars.size(); i++) {
					int index = findIndex(vars, arrayVars.at(i));
					lhs.push_back(vars.at(index));
				}
			} else {
				lhs.push_back(MX(varName));	
			}
		}
	}
	XMLElement* right = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement()->FirstChildElement();
	string funcName = right->FirstChildElement()->Attribute("name");
	CasADi::MXFunction f = m->getModelFunction(funcName)->getMx();
	MXVector argVec = MXVector();
	for (XMLElement* arg = right->NextSiblingElement(); arg != NULL; arg = arg->NextSiblingElement()) {
		if (!strcmp(arg->Value(), "call")) {
			if (arg->Attribute("builtin") != NULL && !strcmp(arg->Attribute("builtin"), "array")) {
				// array constructor
				for (XMLElement* arr = arg->FirstChildElement(); arr != NULL; arr = arr->NextSiblingElement()) {
					MX arrCall = expressionToMx(m, arr);
					for (int i=0; i < arrCall.size(); i++) {
						argVec.push_back(arrCall.at(i));
					}
				}
			} else if (arg->Attribute("builtin") != NULL) {
				// builtin function
				argVec.push_back(expressionToMx(m, arg));
			} else {
				// regular function call
				MX func = expressionToMx(m, arg);
				for (int i=0; i < func.size(); i++) {
					argVec.push_back(func.at(i));
				}
			}
		} else {
			// check if array var
			if (arg->Attribute("name") != NULL && dimensionMap.count((functionName + arg->Attribute("name"))) != 0) {
				std::vector<string> arrayVars = getArrayVariables(arg, functionName);
				for (int i=0; i < arrayVars.size(); i++) {
					MX arg = funcVars.find(arrayVars.at(i))->second->getVar();
					argVec.push_back(arg);
				}
			} else {
				argVec.push_back(expressionToMx(m, arg));
			}
		}
	}
	MXVector outputs = f.call(argVec);
	MXVector updatedVec = CasADi::substitute(outputs, vars, expressions);
	for (int i=0; i < lhs.size(); i++) {
		if (!lhs.at(i).isNull()) {
			int index = findIndex(vars, lhs.at(i).getName());
			expressions.at(index) = updatedVec.at(i);
		}
	}
}

/**
 * Construct the input vector used in a function and add input variables to the model
 */
MXVector getInputVector(Ref<Model> m, XMLElement* elem) {
	MXVector inputVars = MXVector();
	string functionName = elem->Parent()->ToElement()->Attribute("name");
	for (XMLElement* var = elem->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (!strcmp(var->Value(), "component")) {
			const char* causality = var->Attribute("causality");
			const char* variability = var->Attribute("variability");
			if (causality != NULL) {
				if (!strcmp(causality, "input")) {
					XMLElement* dimensionChild = var->FirstChildElement()->NextSiblingElement();
					if (dimensionChild != NULL && !strcmp(dimensionChild->Value(), "dimension")) {
						std::vector<int> dimensions;
						int arrayIndices = 1;
						for (XMLElement* arrayElem = var->FirstChildElement(); arrayElem != NULL; arrayElem = arrayElem->NextSiblingElement()) {
							if (!strcmp(arrayElem->Value(), "dimension")) {
								dimensions.push_back(atoi(arrayElem->FirstChildElement()->Attribute("value")));
								arrayIndices *= atoi(arrayElem->FirstChildElement()->Attribute("value"));
							}
						}
						dimensionMap.insert(std::pair<string, std::vector<int> >((functionName + var->Attribute("name")), dimensions));
						for (int i=0; i < arrayIndices; i++) {
							string varName (var->Attribute("name"));
							std::stringstream ss;
							ss << i;
							varName += "_" + ss.str();
							MX casVar = MX(varName);
							inputVars.push_back(casVar);
							Ref<Variable> input = funcVars.find(varName)->second;
							if (input == NULL) {
								// should check types here since it can be other than real
								Ref<RealVariable> inputVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
									getVariability(variability), NULL);
								funcVars.insert(std::pair<string, ModelicaCasADi::Variable*>(inputVar->getName(), inputVar.getNode()));
							} else {
								input->setVar(casVar);
							}
						}
					} else {
						MX casVar = MX(var->Attribute("name"));
						inputVars.push_back(casVar);
						Ref<Variable> input = funcVars.find(var->Attribute("name"))->second;
						if (input == NULL) {
							// should check types here since it can be other than real
							Ref<RealVariable> inputVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
								getVariability(variability), getUserType(m, var->FirstChildElement()));
							funcVars.insert(std::pair<string, ModelicaCasADi::Variable*>(inputVar->getName(), inputVar.getNode()));
						} else {
							input->setVar(casVar);
						}
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
	string functionName = elem->Parent()->ToElement()->Attribute("name");
	for (XMLElement* var = elem->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (!strcmp(var->Value(), "component")) {
			const char* causality = var->Attribute("causality");
			const char* variability = var->Attribute("variability");
			XMLElement* dimensionChild = var->FirstChildElement()->NextSiblingElement();
			if (dimensionChild != NULL && !strcmp(dimensionChild->Value(), "dimension")) {
				// handle arrays
				std::vector<int> dimensions;
				int arrayIndices = 1;
				for (XMLElement* arrayElem = var->FirstChildElement(); arrayElem != NULL; arrayElem = arrayElem->NextSiblingElement()) {
					if (!strcmp(arrayElem->Value(), "dimension")) {
						dimensions.push_back(atoi(arrayElem->FirstChildElement()->Attribute("value")));
						arrayIndices *= atoi(arrayElem->FirstChildElement()->Attribute("value"));
					}
				}
				dimensionMap.insert(std::pair<string, std::vector<int> >((functionName + var->Attribute("name")), dimensions));
				for (int i=0; i < arrayIndices; i++) {
					string varName (var->Attribute("name"));
					std::stringstream ss;
					ss << i;
					varName += "_" + ss.str();
					MX casVar = MX(varName);
					vars.push_back(casVar);
					Ref<Variable> funcVar = funcVars.find(varName)->second;
					if (funcVar == NULL) {
						// should check types here since it can be other than real
						Ref<RealVariable> globalVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
							getVariability(variability), NULL);
						funcVars.insert(std::pair<string, ModelicaCasADi::Variable*>(globalVar->getName(), globalVar.getNode()));
					} else {
						funcVar->setVar(casVar);
					}
				}
			} else {
				MX casVar = MX(var->Attribute("name"));
				vars.push_back(casVar);
				Ref<Variable> funcVar = funcVars.find(var->Attribute("name"))->second;
				if(funcVar == NULL) {
					// should check types here since it can be other than real
					Ref<RealVariable> globalVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
						getVariability(variability), getUserType(m, var->FirstChildElement()));
					funcVars.insert(std::pair<string, ModelicaCasADi::Variable*>(globalVar->getName(), globalVar.getNode()));
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
MX expressionToMx(Ref<Model> m, XMLElement* expression) {
	const char* name = expression->Value();
	if (!strcmp(name, "integer") || !strcmp(name, "real")) {
		return MX(atof(expression->Attribute("value")));
	} else if (!strcmp(name, "string")) {
		return MX(expression->Attribute("value"));
	} else if (!strcmp(name, "true")) {
		return MX(1);
	} else if (!strcmp(name, "false")) {
		return MX(0);
	} else if (!strcmp(name, "local")) {
		string varName = expression->Attribute("name");
		for (XMLElement* memberElem = expression->FirstChildElement(); memberElem != NULL; memberElem = memberElem->NextSiblingElement()) {
			if (!strcmp(memberElem->Value(), "member")) {
				varName += ".";
				varName += memberElem->Attribute("name");
			}
		}
		if (funcVars.find(varName)->second != NULL) {
			return funcVars.find(varName)->second->getVar();
		} else if (m->getVariable(varName) != NULL) {
			return m->getVariable(varName)->getVar();
		}
		return MX(varName);
	} else if (!strcmp(name, "call")) {
		return functionCallToMx(m, expression);
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
		return operatorToMx(m, expression);
	} else if (!strcmp(name, "if")) {
		return ifExpToMx(m, expression);
	} else if (!strcmp(name, "tuple")) {
		MX left = MX();
		for (XMLElement* child = expression->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
			if (!strcmp(child->Value(), "local")) {
				left.append(MX(child->Attribute("name")));
			} else if (!strcmp(child->Value(), "call")) {
				left.append(expressionToMx(m, child));
			} else {
				left.append(MX("dummy"));
			}
		}
		return left;
	} else if (!strcmp(name, "reference")) {
		return referenceToMx(m, expression);
	} else if (!strcmp(name, "nothing")) {
		return MX();
	} else {
		std::stringstream errorMessage;
		errorMessage << "Unsupported expression: " << expression->Value();
		throw std::runtime_error(errorMessage.str());
	}
	return MX();
}

/**
 * Construct a MX expression from a function call
 */
MX functionCallToMx(Ref<Model> m, XMLElement* call) {
	const char* builtinAttr = call->Attribute("builtin");
	if (builtinAttr != NULL) {
		// array constructor, return a stacked mx with variables
		if (!strcmp(builtinAttr, "array")) {
			MX stackedArr = MX();
			for (XMLElement* arr = call->FirstChildElement(); arr != NULL; arr = arr->NextSiblingElement()) {
				stackedArr.append(expressionToMx(m, arr));
			}
			return stackedArr;
		}
		// builtin function call, e.g. sin, +...
		XMLElement* lhs = call->FirstChildElement();
		XMLElement* rhs = lhs->NextSiblingElement();
		if (rhs != NULL) { // binary
			MX lhsExp = expressionToMx(m, lhs);
			MX rhsExp = expressionToMx(m, rhs);
			if (lhsExp.size() > 1) {
				lhsExp = lhsExp.at(0);
			}
			if (rhsExp.size() > 1) {
				rhsExp = rhsExp.at(0);
			}
			return builtinBinaryToMx(lhsExp, rhsExp, builtinAttr);
		} else { // unary
			return builtinUnaryToMx(expressionToMx(m, lhs), builtinAttr);
		}
	} else {
		XMLElement* func = call->FirstChildElement();
		string funcName = func->FirstChildElement()->Attribute("name");
		CasADi::MXFunction f = m->getModelFunction(funcName)->getMx();
		MXVector argVec = MXVector();
		for (XMLElement* arg = func->NextSiblingElement(); arg != NULL; arg = arg->NextSiblingElement()) {
			if (!strcmp(arg->Value(), "call")) {
				if (arg->Attribute("builtin") != NULL && !strcmp(arg->Attribute("builtin"), "array")) {
					for (XMLElement* arr = arg->FirstChildElement(); arr != NULL; arr = arr->NextSiblingElement()) {
						MX arrCall = expressionToMx(m, arr);
						for (int i=0; i < arrCall.size(); i++) {
							argVec.push_back(arrCall.at(i));
						}
					}
				} else if (arg->Attribute("builtin") != NULL) {
					argVec.push_back(expressionToMx(m, arg->FirstChildElement()));
				}
			} else {
				argVec.push_back(expressionToMx(m, arg));
			}
		}
		MXVector outputs = f.call(argVec);
		MX returnMx = MX();
		for (int i=0; i < outputs.size(); i++) {
			returnMx.append(outputs.at(i));
		}
		return returnMx;
	}
}

MX operatorToMx(Ref<Model> m, XMLElement* op) {
	if (!strcmp(op->Attribute("name"), "der")) {
		// handle calls to the der operator, lookup if we have introduced a differentiated variable 
		// for this der call, if we have proceed as with all others functions calls if not continue by
		// adding a diff variable and add it to the lookup table
		XMLElement* derChild = op->FirstChildElement();
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
	} else if (!strcmp(op->Attribute("name"), "pre")) {
		XMLElement* preChild = op->FirstChildElement();
		string preCall = "pre(";
		preCall.append(preChild->Attribute("name"));
		preCall.append(")");
		return MX(preCall);
	} else if (!strcmp(op->Attribute("name"), "assert")) {
		return MX(0);
		// ignore asserts
	} else if (!strcmp(op->Attribute("name"), "time")) {
		return MX("time");
	} else if (!strcmp(op->Attribute("name"), "noevent")) {
		// ignore noevent
		return expressionToMx(m, op->FirstChildElement());
	} else {
		// unsupported operators
		std::stringstream errorMessage;
		errorMessage << "Unsupported operator: " <<  op->Attribute("name");
		throw std::runtime_error(errorMessage.str());
	}
}

/**
 * Takes a reference tag and converts it to a MX expression
 */
MX referenceToMx(Ref<Model> m, XMLElement* ref) {
	// get the name of the function since this is needed to look up array dimensions
	string functionName = "";
	for (XMLElement* parent = ref->Parent()->ToElement(); parent != NULL; parent = parent->Parent()->ToElement()) {
		if (!strcmp(parent->Value(), "class") && !strcmp(parent->Attribute("kind"), "function")) {
			functionName = parent->Parent()->ToElement()->Attribute("name");
		}
	}
	XMLElement* varName = ref->FirstChildElement();
	int flatIndex = calculateFlatArrayIndex(m, ref, functionName);
	string var (varName->Attribute("name"));
	std::stringstream ss;
	ss << flatIndex;
	var += "_" + ss.str();
	if (funcVars.find(var)->second != NULL) {
		return funcVars.find(var)->second->getVar();
	}
	return MX(var);
}

/**
 * Convert if expression to MX
 */
MX ifExpToMx(Ref<Model> m, XMLElement* expression) {
	XMLElement* branching = expression->FirstChildElement();
	XMLElement* condition = branching->FirstChildElement();
	XMLElement* thenBranch = branching->NextSiblingElement()->FirstChildElement();
	XMLElement* elseBranch = branching->NextSiblingElement()->NextSiblingElement()->FirstChildElement();
	return CasADi::if_else(expressionToMx(m, condition), expressionToMx(m, thenBranch), expressionToMx(m, elseBranch));
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
	for (int i=0; i < vector.size(); i++) {
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
			string functionName = child->Attribute("name");
			XMLElement* function = child->FirstChildElement();
			if (!strcmp(function->Value(), "class") && !strcmp(function->Attribute("kind"), "function")) {
				MXVector expressions = getFuncVars(m, function);
				MXVector inputVars = getInputVector(m, function);
				MXVector outputVars = MXVector();
				int index=0;
				for (XMLElement* var = function->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
					if (var->Attribute("causality") != NULL && !strcmp(var->Attribute("causality"), "output")) {
						XMLElement* outputElem = var->FirstChildElement()->NextSiblingElement();
						if (outputElem != NULL && !strcmp(outputElem->Value(), "dimension")) {
							std::vector<int> dimensions = dimensionMap.find((functionName + var->Attribute("name")))->second;
							int nbrOutputVars = 1;
							for (int j=0; j < dimensions.size(); j++) {
								nbrOutputVars *= dimensions.at(j);
							}
							for (int j=0; j < nbrOutputVars; j++) {
								outputVars.push_back(expressions.at(index));
								index++;
							}
						} else {
							outputVars.push_back(expressions.at(index));
							index++;
						}
					} else {
						XMLElement* indexElem = var->FirstChildElement()->NextSiblingElement();
						if (indexElem != NULL && !strcmp(indexElem->Value(), "dimension")) {
							std::vector<int> dimensions = dimensionMap.find((functionName + var->Attribute("name")))->second;
							int nbrVars = 1;
							for (int j=0; j < dimensions.size(); j++) {
								nbrVars *= dimensions.at(j);
							}
							index += nbrVars;
						} else {
							index++;
						}
					}
				}
				CasADi::MXFunction f = CasADi::MXFunction(inputVars, outputVars);
				f.setOption("name", child->Attribute("name"));
				f.init();
				m->setModelFunctionByItsName(new ModelicaCasADi::ModelFunction(f));
			}
		}
	}
}

/**
 * Takes an XMLElement that contains an arbitrary number of dimensions and 
 * calculate a flat index from these dimensions
 */
int calculateFlatArrayIndex(Ref<Model> m, XMLElement* reference, string functionName) {
	XMLElement* varName = reference->FirstChildElement();
	std::vector<int> dimensions = dimensionMap.find((functionName + varName->Attribute("name")))->second;
	std::vector<int> subscripts;
	for (XMLElement* sub = varName->NextSiblingElement(); sub != NULL; sub = sub->NextSiblingElement()) {
		if (!strcmp(sub->FirstChildElement()->Value(), "call")) {
			MX tmp = expressionToMx(m, sub->FirstChildElement());
			subscripts.push_back(tmp.getValue()-1);
		} else if (!strcmp(sub->FirstChildElement()->Value(), "integer") || !strcmp(sub->FirstChildElement()->Value(), "real")) {
			subscripts.push_back(atoi(sub->FirstChildElement()->Attribute("value"))-1);
		} else {
			throw std::runtime_error("Only integer expressions and constants are supported as array indices");
		}
	}
	// convert subscripts to flat index
	int flatIndex = 0;
	int multiplier = 1;
	for (int i=subscripts.size()-1; i >= 0; i--) {
		if (i == subscripts.size()-1) {
			flatIndex += subscripts.at(i);
			multiplier *= dimensions.at(i);
		} else {
			flatIndex += subscripts.at(i) * multiplier;
			multiplier *= dimensions.at(i);
		}
	}
	return flatIndex;
}

/**
 * Constructs the scalar variable names from an array name and returns
 * a vector containing them
 */
std::vector<string> getArrayVariables(XMLElement* elem, string functionName) {
	std::vector<string> arrayVars;
	std::vector<int> arrayDim = dimensionMap.find((functionName + elem->Attribute("name")))->second;
	int varNumbers = 1;
	for (int i=0; i < arrayDim.size(); i++) {
		varNumbers *= arrayDim.at(i);
	}
	for (int i=0; i < varNumbers; i++) {
		string varName(elem->Attribute("name"));
		std::stringstream ss;
		ss << i;
		varName += "_" + ss.str();
		arrayVars.push_back(varName);
	}
	return arrayVars;
}
}; // end namespace