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
//types
#include "types/VariableType.hpp"
#include "types/UserType.hpp"
#include "types/PrimitiveType.hpp"
#include "types/RealType.hpp"
#include "types/IntegerType.hpp"
#include "types/BooleanType.hpp"

#include "Equation.hpp"
#include "ModelFunction.hpp"
#include "RealVariable.hpp"
#include "IntegerVariable.hpp"
#include "BooleanVariable.hpp"
#include "DerivativeVariable.hpp"

#include "transferXML.hpp"
#include "transferXML_impl.hpp"

using std::string;
using tinyxml2::XMLElement;
using CasADi::MX;
using CasADi::MXVector;

namespace ModelicaCasADi {

// not used for now but should be passed around instead of the model
struct Context {
    Ref<Model> m;
    std::map<string, std::vector<int> > dimensionMap;
    std::map<string, Variable*> funcVars;
};

void transferFunction(Ref<Model> m, tinyxml2::XMLElement *elem);
void transferAlgorithm(Ref<Model> m, tinyxml2::XMLElement *alg, const string &functionName, MXVector &expressions, MXVector &vars, std::map<string, Variable*> &funcVars);
void updateFunctionCall(Ref<Model> m, tinyxml2::XMLElement *stmt,
	MXVector &expressions, MXVector &vars, std::string functionName, std::map<std::string, Variable*> &funcVars);
MXVector getInputVector(Ref<Model>, tinyxml2::XMLElement *elem, std::map<std::string, Variable*> &funcVars);
MXVector getFuncVars(Ref<Model> m, tinyxml2::XMLElement *elem, std::map<std::string, Variable*> &funcVars);

void addVariable(Ref<Model> m, XMLElement *variable, const char *type);
void addDerivativeVar(Ref<Model> m, Ref<RealVariable> realVar, std::string name);

MX functionCallToMx(Ref<Model> m, tinyxml2::XMLElement *call, std::map<std::string, Variable*> &funcVars);
MX operatorToMx(Ref<Model> m, tinyxml2::XMLElement *op, std::map<std::string, Variable*> &funcVars);
MX referenceToMx(Ref<Model> m, tinyxml2::XMLElement *ref, std::map<std::string, Variable*> &funcVars);
MX ifExpToMx(Ref<Model> m, tinyxml2::XMLElement *expression, std::map<std::string, Variable*> &funcVars);

Variable::Causality getCausality(const char *causality);
Variable::Variability getVariability(const char *variability);

MX builtinUnaryToMx(MX exp, const char *builtinName);
MX builtinBinaryToMx(MX lhs, MX rhs, const char *builtinName);

bool hasDerivativeVar(Ref<Model> m, Ref<RealVariable> realVar);
Ref<PrimitiveType> getBaseType(Ref<Model> m, std::string baseTypeName);
Ref<UserType> getUserType(Ref<Model> m, tinyxml2::XMLElement *type);

int findIndex(MXVector vector, std::string elem);
int calculateFlatArrayIndex(Ref<Model> m, tinyxml2::XMLElement *reference, 
	std::string functionName, std::map<std::string, Variable*> &funcVars);
std::vector<std::string> getArrayVariables(tinyxml2::XMLElement *elem, std::string functionName);
void addFunc(std::string funcName, tinyxml2::XMLElement *elem, Ref<Model> m);
XMLElement* expect(XMLElement *elem, const char *name);
// end forward declarations

// used for keeping the dimensions of array variables
std::map<string, std::vector<int> > dimensionMap;

/**
 * Parses an XML document representing an Modelica model and then
 * construct a Model object from the XML and fill up this object, 
 * finally return this Model.
 */
Ref<Model> transferXMLModel (Ref<Model> m, string modelName, const std::vector<string> &modelFiles) {
	m->setTimeVariable(MX("time"));
	m->initializeModel(modelName);
	tinyxml2::XMLDocument doc;
    parseXML(modelName, modelFiles, doc);
    XMLElement *root = doc.FirstChildElement();
	if (root == NULL) {
		throw std::runtime_error("XML document does not have any root node");
	}
	for (XMLElement *elem = root->FirstChildElement(); elem != NULL; elem = elem->NextSiblingElement()) {
		if (isElement(elem, "component") || isElement(elem, "classDefinition")) {
			// transfer variables, functions are also handled here
			transferDeclarations(m, elem);
		} else if (isElement(elem, "equation")) {
			const char *equType = elem->Attribute("kind");
            if (hasAttribute(elem, "kind", "initial") || hasAttribute(elem, "kind", "default") || !hasAttribute(elem, "kind")) {
                transferEquations(m, elem, equType);
			} else if (hasAttribute(elem, "kind", "parameter")) {
				transferParameterEquations(m, elem);
			} else {
                std::stringstream errorMessage;
                errorMessage << "Unsupported equation type: " << equType;
                throw std::runtime_error(errorMessage.str());
            }
		} else {
			std::stringstream errorMessage;
			errorMessage << "Unsupported XML element: " << elem->Value();
			throw std::runtime_error(errorMessage.str());
		}
	}
	return m;
}

/**
 * Take a model and a pointer to the start of the variables in the DOM, traverse all variables
 * ín the DOM and construct a Variable object from each variable and add them to the model m.
 */
void transferDeclarations(Ref<Model> m, XMLElement *decl) {
	if (isElement(decl, "component")) {
		transferComponent(m, decl);
	} else if(isElement(decl, "classDefinition")) {
        transferClassDefinition(m, decl);
	} else {
		std::stringstream errorMessage;
		errorMessage << decl->Value() << " clauses are not supported in the CasADiInterface";
		throw std::runtime_error(errorMessage.str());
	}
}

/**
 * Take a model and a pointer to a component and add this component to the model.
 */
void transferComponent(Ref<Model> m, XMLElement *component) {
    XMLElement *child = component->FirstChildElement();
	if (isElement(child, "builtin")) {
		const char *type = child->Attribute("name");
		if (strcmp(type, "Real") == 0 || strcmp(type, "Boolean") == 0 || strcmp(type, "Integer") == 0) {
            addVariable(m, component, type);
		} else {
			std::stringstream errorMessage;
			errorMessage << "Variables of type " << component->Value() << " is not supported in CasADiInterface";
			throw std::runtime_error(errorMessage.str());
		}
	} else if (isElement(child, "local")) {
		Ref<UserType> userType = (UserType*) m->getVariableType(child->Attribute("name")).getNode();
		Ref<PrimitiveType> prim = userType->getBaseType();
		if (prim->getName() == "Real") {
            addVariable(m, component, "Real");
		} else if (prim->getName() == "Integer") {
            addVariable(m, component, "Integer");
		} else if (prim->getName() == "Boolean") {
            addVariable(m, component, "Boolean");
		}
	} else {
        std::stringstream errorMessage;
		errorMessage << "Component " << child->Value() << " is not a valid component construct";
		throw std::runtime_error(errorMessage.str());
    }
}

void transferClassDefinition(Ref<Model> m, XMLElement *classDef) {
	XMLElement *child = classDef->FirstChildElement();
	if (isElement(child, "class") && hasAttribute(child, "kind", "function")) {
        // if function does not exist we add it
		if (m->getModelFunction(classDef->Attribute("name")) == NULL) {
			transferFunction(m, classDef);
		}
	} else if (isElement(child, "class") && hasAttribute(child, "kind", "record")) {
		// store information about record so that it can be used in import, how?
        throw std::runtime_error("Record types are not supported");
	} else if (!isElement(child, "enumeration")) {
		string typeName = classDef->Attribute("name");
		string baseTypeName = child->Attribute("name");
		Ref<UserType> userType = new UserType(typeName, getBaseType(m, baseTypeName));
		for (child = child->NextSiblingElement(); child != NULL; child = child->NextSiblingElement()) {
			if (isElement(child, "modifier")) {
				for (XMLElement* item = child->FirstChildElement(); item != NULL; item = item->NextSiblingElement()) {
                    XMLElement *itemExpression = item->FirstChildElement();
                    std::map<string, Variable*> funcVars;
					userType->setAttribute(item->Attribute("name"), expressionToMX(m, itemExpression, funcVars));
				}
			} else {
                std::stringstream errorMessage;
                errorMessage << child->Value() << " are not supported within a classDefinition";
                throw std::runtime_error(errorMessage.str());
            }
		}
		m->addNewVariableType(userType);
	} else {
        throw std::runtime_error("Enumerations are not supported in CasADiInterface");
    }
}

/**
 * Take a model and a pointer to the start of the equations in the DOM, traverse
 * all equations in the DOM and add the equations to the model object.
 */
void transferEquations(Ref<Model> m, XMLElement *elem, const char *equType) {
	for (XMLElement *equation = elem->FirstChildElement(); equation != NULL; equation = equation->NextSiblingElement()) {
		if (isElement(equation, "equal")) {
			MX finalLhs;
			MX finalRhs;
			XMLElement *lhs = equation->FirstChildElement();
			XMLElement *rhs = lhs->NextSiblingElement();
			std::map<string, Variable*> funcVars;
			MX left = expressionToMX(m, lhs, funcVars);
			MX right = expressionToMX(m, rhs, funcVars);
			if (left.size() > 1) {
				for (int i=0; i < left.size(); i++) {
					if (left.at(i).getName() != "<nothing>") {
						finalLhs.append(left.at(i));
						finalRhs.append(right.at(i));
					}
				}
			} else {
				finalLhs = left;
				finalRhs = right.at(0);
			}
            if (equType == NULL || strcmp(equType, "default") == 0 ) {
                m->addDaeEquation(new Equation(finalLhs, finalRhs));
            } else {
                m->addInitialEquation(new Equation(finalLhs, finalRhs));
            }
		} else {
            std::stringstream errorMessage;
            errorMessage << equation->Value() << " clause not supported in equation";
            throw std::runtime_error(errorMessage.str());
        }
	}
}

/**
 * Take a parameter equation and get the variable on the left hand side from the model object.
 * The righthand side expression is then set as a binding expression to the lhs variable.
 */
void transferParameterEquations(Ref<Model> m, XMLElement *elem) {
	for (XMLElement *parameter = elem->FirstChildElement(); parameter != NULL; parameter = parameter->NextSiblingElement()) {
		if ((parameter, "equal")) {
			XMLElement *lhs = parameter->FirstChildElement();
			XMLElement *rhs = lhs->NextSiblingElement();
			std::map<string, Variable*> funcVars;
			MX left = expressionToMX(m, lhs, funcVars);
			MX right = expressionToMX(m, rhs, funcVars);
			for (int i=0; i< right.size(); i++) {
				if (left.at(i).getName() != "<nothing>") {
					Ref<Variable> var = m->getVariable(left.at(i).getName());
					if (var == NULL) {
                        throw std::runtime_error("Variable in parameter equation could not be found");
					} else {
                        // if the variable exist the value is added as its binding expression
						var->setAttribute("bindingExpression", right.at(i));
					}
				}
			}
		} else {
            std::stringstream errorMessage;
            errorMessage << parameter->Value() << " clause not supported in parameter equation";
            throw std::runtime_error(errorMessage.str());
        }
	}
}

/**
 * Construct an MXFunction from the XML and adds it to the model.
 * Takes a pointer to the root node of the function in the DOM. First all variables
 * are added to two MXVectors. The expressions vector is used to store the actual
 * value of the variable.
 */
void transferFunction(Ref<Model> m, XMLElement *elem) {
	std::map<string, Variable*> funcVars;
	const string functionName = elem->Attribute("name");
	XMLElement *function = elem->FirstChildElement();
	MXVector expressions = getFuncVars(m, function, funcVars);
	MXVector vars = getFuncVars(m, function, funcVars);
	MXVector inputVars = getInputVector(m, function, funcVars);
	for (XMLElement *var = function->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (isElement(var, "algorithm")) {
			transferAlgorithm(m, var, functionName, expressions, vars, funcVars);
		}
	}
	MXVector outputVars;
	int index=0;
	// find output variables and add to output vector
	for (XMLElement *var = function->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (hasAttribute(var, "causality", "output")) {
			XMLElement *outputElem = var->FirstChildElement()->NextSiblingElement();
			if (outputElem != NULL && isElement(outputElem, "dimension")) {
				std::vector<int> dimensions;
				std::map<string, std::vector<int> >::iterator it = dimensionMap.find(functionName + var->Attribute("name"));
				if (it != dimensionMap.end()) {
					dimensions = it->second;
				}
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
			XMLElement *indexElem = var->FirstChildElement()->NextSiblingElement();
			if (indexElem != NULL && isElement(indexElem, "dimension")) {
				std::vector<int> dimensions;
				std::map<string, std::vector<int> >::iterator it = dimensionMap.find(functionName + var->Attribute("name"));
				if (it != dimensionMap.end()) {
					dimensions = it->second;
				}
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
	m->setModelFunctionByItsName(new ModelFunction(f));
}

/**
 * Handle algorithm sections of the function transfer are handled by substituting the right-hand side
 * value into the expressions vector.
 */
void transferAlgorithm(Ref<Model> m, tinyxml2::XMLElement *alg, const string &functionName, MXVector &expressions, MXVector &vars, std::map<string, Variable*> &funcVars) {
    for (XMLElement *stmt = alg->FirstChildElement(); stmt != NULL; stmt = stmt->NextSiblingElement()) {
		if (isElement(stmt, "return")) {
			break;
		}
		if (isElement(stmt, "assign")) {
			XMLElement *left = stmt->FirstChildElement()->FirstChildElement();
			XMLElement *checkRight = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement();
			// update function variables to reflect function call
			if (left != NULL && isElement(checkRight, "call") && !(checkRight->Attribute("builtin") != NULL &&
				!hasAttribute(checkRight, "builtin", "array"))) {
					updateFunctionCall(m, stmt, expressions, vars, functionName, funcVars);
			} else if (left != NULL) {
				MXVector lhs;
				MX leftCas;
				if (isElement(left, "reference")) {
					int flatIndex = calculateFlatArrayIndex(m, left, functionName, funcVars);
					string varName(left->FirstChildElement()->Attribute("name"));
					std::stringstream ss;
					ss << flatIndex;
					varName += "[" + ss.str() + "]";
					int index = findIndex(vars, varName);
					if (index != -1) {
						leftCas = vars.at(index);
					} else {
                        std::stringstream errorMessage;
                        errorMessage << "No variable with name " << varName << " found in function";
                        throw std::runtime_error(errorMessage.str());
					}
				} else {
					int index = findIndex(vars, left->Attribute("name"));
					if (index != -1) {
						leftCas = vars.at(index);
					} else {
                        std::stringstream errorMessage;
                        errorMessage << "No variable with name " << left->Attribute("name") << " found in function";
                        throw std::runtime_error(errorMessage.str());
					}
				}
				lhs.push_back(leftCas);
				MXVector rhs;
				XMLElement *right = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement();
				MX rightCas = expressionToMX(m, right, funcVars);
				rhs.push_back(rightCas);
				MX updated = CasADi::substitute(rhs, vars, expressions).at(0);
				int index = findIndex(vars, lhs.at(0).getName());
				expressions.at(index) = updated;
			} else {
                throw std::runtime_error("Left hand side of algorithm is not allowed to be empty");
            }
		}
	}
}


/**
 * Handles the updating of function calls in functions. The expression vector which
 * contains the current MX for all variables in the functions is updated by
 * running the function call and then substitute in the outputs.
 */
void updateFunctionCall(Ref<Model> m, XMLElement *stmt, MXVector &expressions, MXVector &vars, string functionName, std::map<string, Variable*> &funcVars) {
	XMLElement *left = stmt->FirstChildElement()->FirstChildElement();
	MXVector lhs;
	if (isElement(left, "tuple")) {
		for (XMLElement *tupleChild = left->FirstChildElement(); tupleChild != NULL; tupleChild = tupleChild->NextSiblingElement()) {
			if (isElement(tupleChild, "nothing")) {
				// add an emtpy mx if there are an empty spot in the tuple
				lhs.push_back(MX());
			} else {
				MX leftCas;
				int index = findIndex(vars, tupleChild->Attribute("name"));
				if (index != -1) {
					leftCas = vars.at(index);
				} else {
                    std::stringstream errorMessage;
                    errorMessage << "Tuple with name " << tupleChild->Attribute("name") << " not found";
                    throw std::runtime_error(errorMessage.str());
				}
				lhs.push_back(leftCas);
			}
		}
	} else if (isElement(left, "local")) {
		string varName = left->Attribute("name");
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
                std::stringstream errorMessage;
                errorMessage << "Variable " << varName << " not found in function lookup";
                throw std::runtime_error(errorMessage.str());
			}
		}
	} else {
        std::stringstream errorMessage;
        errorMessage << "Invalid statement " << left << " in function call";
        throw std::runtime_error(errorMessage.str());
    }
    // ensure that right hand side really is a function call
    if (!isElement(stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement(), "call")) {
        std::stringstream errorMessage;
        errorMessage << "Invalid entrypoint to function call " << stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement()->Value();
        throw std::runtime_error(errorMessage.str());
    }
	XMLElement *right = stmt->FirstChildElement()->NextSiblingElement()->FirstChildElement()->FirstChildElement();
	string funcName = right->FirstChildElement()->Attribute("name");
	if (m->getModelFunction(funcName) == NULL) {
		addFunc(funcName, stmt, m);
	}
	CasADi::MXFunction f = m->getModelFunction(funcName)->getMx();
	MXVector argVec;
	for (XMLElement *arg = right->NextSiblingElement(); arg != NULL; arg = arg->NextSiblingElement()) {
		if (isElement(arg, "call")) {
			if (hasAttribute(arg, "builtin", "array")) {
				// array constructor
				for (XMLElement *arr = arg->FirstChildElement(); arr != NULL; arr = arr->NextSiblingElement()) {
					MX arrCall = expressionToMX(m, arr, funcVars);
					for (int i=0; i < arrCall.size(); i++) {
						argVec.push_back(arrCall.at(i));
					}
				}
			} else if (arg->Attribute("builtin") != NULL) {
				// builtin function
				argVec.push_back(expressionToMX(m, arg, funcVars));
			} else {
				// regular function call
				MX func = expressionToMX(m, arg, funcVars);
				for (int i=0; i < func.size(); i++) {
					argVec.push_back(func.at(i));
				}
			}
		} else {
			// check if array var
			if (arg->Attribute("name") != NULL && dimensionMap.count((functionName + arg->Attribute("name"))) != 0) {
				std::vector<string> arrayVars = getArrayVariables(arg, functionName);
				for (int i=0; i < arrayVars.size(); i++) {
					std::map<std::string, Variable*>::iterator it = funcVars.find(arrayVars.at(i));
					if (it != funcVars.end()) {
						MX arg = it->second->getVar();
						argVec.push_back(arg);
					} else {
                        throw std::runtime_error("Array variable not found");
                    }
				}
			} else {
				argVec.push_back(expressionToMX(m, arg, funcVars));
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
MXVector getInputVector(Ref<Model> m, XMLElement *elem, std::map<string, Variable*> &funcVars) {
	MXVector inputVars;
	string functionName = elem->Parent()->ToElement()->Attribute("name");
	for (XMLElement *var = elem->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (isElement(var, "component")) {
			const char *causality = var->Attribute("causality");
			const char *variability = var->Attribute("variability");
				if (hasAttribute(var, "causality", "input")) {
					XMLElement *dimensionChild = var->FirstChildElement()->NextSiblingElement();
					if (dimensionChild != NULL && isElement(dimensionChild, "dimension")) {
						std::vector<int> dimensions;
						int arrayIndices = 1;
						for (XMLElement *arrayElem = var->FirstChildElement(); arrayElem != NULL; arrayElem = arrayElem->NextSiblingElement()) {
							if (isElement(arrayElem, "dimension")) {
								dimensions.push_back(atoi(arrayElem->FirstChildElement()->Attribute("value")));
								arrayIndices *= atoi(arrayElem->FirstChildElement()->Attribute("value"));
							}
						}
						dimensionMap.insert(std::pair<string, std::vector<int> >((functionName + var->Attribute("name")), dimensions));
						for (int i=0; i < arrayIndices; i++) {
							string varName (var->Attribute("name"));
							std::stringstream ss;
							ss << i;
							varName += "[" + ss.str() + "]";
							MX casVar = MX(varName);
							inputVars.push_back(casVar);
							std::map<std::string, Variable*>::iterator it = funcVars.find(varName);
							if (it == funcVars.end()) {
								// should check types here since it can be other than real
								Ref<RealVariable> inputVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
									getVariability(variability), NULL);
								funcVars.insert(std::pair<string, Variable*>(inputVar->getName(), inputVar.getNode()));
							} else {
								Ref<Variable> input = it->second;
								input->setVar(casVar);
							}
						}
					} else {
						MX casVar = MX(var->Attribute("name"));
						inputVars.push_back(casVar);
						std::map<std::string, Variable*>::iterator it = funcVars.find(var->Attribute("name"));
						if (it == funcVars.end()) {
							// should check types here since it can be other than real
							Ref<RealVariable> inputVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
								getVariability(variability), getUserType(m, var->FirstChildElement()));
							funcVars.insert(std::pair<string, Variable*>(inputVar->getName(), inputVar.getNode()));
						} else {
							Ref<Variable> input = it->second;
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
MXVector getFuncVars(Ref<Model> m, XMLElement *elem, std::map<string, Variable*> &funcVars) {
	MXVector vars;
	string functionName = elem->Parent()->ToElement()->Attribute("name");
	for (XMLElement *var = elem->FirstChildElement(); var != NULL; var = var->NextSiblingElement()) {
		if (isElement(var, "component")) {
			const char *causality = var->Attribute("causality");
			const char *variability = var->Attribute("variability");
			XMLElement *dimensionChild = var->FirstChildElement()->NextSiblingElement();
			if (dimensionChild != NULL && isElement(dimensionChild, "dimension")) {
				// handle arrays
				std::vector<int> dimensions;
				int arrayIndices = 1;
				for (XMLElement *arrayElem = var->FirstChildElement(); arrayElem != NULL; arrayElem = arrayElem->NextSiblingElement()) {
					if (isElement(arrayElem, "dimension")) {
						dimensions.push_back(atoi(arrayElem->FirstChildElement()->Attribute("value")));
						arrayIndices *= atoi(arrayElem->FirstChildElement()->Attribute("value"));
					}
				}
				dimensionMap.insert(std::pair<string, std::vector<int> >((functionName + var->Attribute("name")), dimensions));
				for (int i=0; i < arrayIndices; i++) {
					string varName (var->Attribute("name"));
					std::stringstream ss;
					ss << i;
					varName += "[" + ss.str() + "]";
					MX casVar = MX(varName);
					vars.push_back(casVar);
					std::map<std::string, Variable*>::iterator it = funcVars.find(varName);
					if (it == funcVars.end()) {
						// should check types here since it can be other than real
						Ref<RealVariable> globalVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
							getVariability(variability), NULL);
						funcVars.insert(std::pair<string, Variable*>(globalVar->getName(), globalVar.getNode()));
					} else {
						Ref<Variable> funcVar = it->second;
						funcVar->setVar(casVar);
					}
				}
			} else {
				MX casVar = MX(var->Attribute("name"));
				vars.push_back(casVar);
				std::map<std::string, Variable*>::iterator it = funcVars.find(var->Attribute("name"));
				if(it == funcVars.end()) {
					// should check types here since it can be other than real
					Ref<RealVariable> globalVar = new RealVariable(m.getNode(), casVar, getCausality(causality),
						getVariability(variability), getUserType(m, var->FirstChildElement()));
					funcVars.insert(std::pair<string, Variable*>(globalVar->getName(), globalVar.getNode()));
				} else {
					Ref<Variable> funcVar = it->second;
					funcVar->setVar(casVar);
				}
			}
		}
	}
	return vars;
}

/**
 * Add a variable to the model, uses a template function to add the attributes.
 */
void addVariable(Ref<Model> m, XMLElement *variable, const char *type) {
    MX var = MX(variable->Attribute("name"));
    const char *causality = variable->Attribute("causality");
    const char *variability = variable->Attribute("variability");
	const char *comment = variable->Attribute("comment");
    if (strcmp(type, "Real") == 0) {
        Ref<RealVariable> realVar = new RealVariable(m.getNode(), var, getCausality(causality), 
		getVariability(variability), getUserType(m, variable->FirstChildElement()));
        addAttributes<Ref<RealVariable> >(m, variable, realVar);
    } else if (strcmp(type, "Integer") == 0) {
        Ref<IntegerVariable> intVar = new IntegerVariable(m.getNode(), var, getCausality(causality), 
		getVariability(variability), getUserType(m, variable->FirstChildElement()));
        addAttributes<Ref<IntegerVariable> >(m, variable, intVar);
    } else if (strcmp(type, "Boolean") == 0) {
        Ref<BooleanVariable> boolVar = new BooleanVariable(m.getNode(), var, getCausality(causality), 
		getVariability(variability), getUserType(m, variable->FirstChildElement()));
        addAttributes<Ref<BooleanVariable> >(m, variable, boolVar);
    } else {
        std::stringstream errorMessage;
        errorMessage << "Variables of type " << type << " are not supported";
        throw std::runtime_error(errorMessage.str());
    }    
}

/**
 * Add a derivative variable to the model, no attributes are added in this case since 
 * these are not accesible with the current way that imports works.
 */
void addDerivativeVar (Ref<Model> m, Ref<RealVariable> realVar, string name) {
	string derName = "der(" + name + ")";
	MX derMx = MX(derName);
	Ref<DerivativeVariable> derVar = new DerivativeVariable(m.getNode(), derMx, realVar, NULL);
	realVar->setMyDerivativeVariable(derVar);
	// no attributes added since we cannot access them
	m->addVariable(derVar);
}

/**
 * Take an XML node containing an expression and return a corresponding MX expression.
 */
MX expressionToMX(Ref<Model> m, XMLElement *expression, std::map<string, Variable*> &funcVars) {
	if (isElement(expression, "integer") || isElement(expression, "real")) {
		return MX(atof(expression->Attribute("value")));
	} else if (isElement(expression, "string")) {
		return MX(expression->Attribute("value"));
	} else if (isElement(expression, "true")) {
		return MX(1);
	} else if (isElement(expression, "false")) {
		return MX(0);
	} else if (isElement(expression, "local")) {
		// handle variable name
		string varName = expression->Attribute("name");
		std::map<std::string, Variable*>::iterator it = funcVars.find(varName);
		if (it != funcVars.end()) {
			return it->second->getVar();
		} else if (m->getVariable(varName) != NULL) {
			return m->getVariable(varName)->getVar();
		}
		std::stringstream errorMessage;
		errorMessage << "Variable " << varName << " not found in lookup";
		throw std::runtime_error(errorMessage.str());
	} else if (isElement(expression, "call")) {
		return functionCallToMx(m, expression, funcVars);
	} else if (isElement(expression, "builtin")) {
		if (hasAttribute(expression, "name", "time")) {
			// builtin variable time
			return m->getTimeVariable();
		} else {
            std::stringstream errorMessage;
            errorMessage << "Unsupported builtin construct: " << expression->Attribute("name");
            throw std::runtime_error(errorMessage.str());
        }
	} else if (isElement(expression, "operator")) {
		return operatorToMx(m, expression, funcVars);
	} else if (isElement(expression, "if")) {
		return ifExpToMx(m, expression, funcVars);
	} else if (isElement(expression, "tuple")) {
		MX left;
		for (XMLElement *child = expression->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
			if (isElement(child, "local")) {
				left.append(expressionToMX(m, child, funcVars));
			} else if (isElement(child, "call")) {
				left.append(expressionToMX(m, child, funcVars));
			} else if (isElement(child, "nothing")) {
				left.append(MX("<nothing>"));
			} else {
                std::stringstream errorMessage;
                errorMessage << "Invalid tuple element: " << child->Value();
                throw std::runtime_error(errorMessage.str());
            }
		}
		return left;
	} else if (isElement(expression, "reference")) {
		return referenceToMx(m, expression, funcVars);
	}
	std::stringstream errorMessage;
	errorMessage << "Unsupported expression: " << expression->Value();
	throw std::runtime_error(errorMessage.str());
}

/**
 * Construct an MX expression from a function call
 */
MX functionCallToMx(Ref<Model> m, XMLElement *call, std::map<string, Variable*> &funcVars) {
	const char *builtinAttr = call->Attribute("builtin");
	if (builtinAttr != NULL) {
		if (hasAttribute(call, "builtin", "array")) {
            // array constructor, return a stacked MX with variables
			MX stackedArr;
			for (XMLElement *arr = call->FirstChildElement(); arr != NULL; arr = arr->NextSiblingElement()) {
				stackedArr.append(expressionToMX(m, arr, funcVars));
			}
			return stackedArr;
		}
		// builtin function call, e.g. sin, +...
		XMLElement *lhs = call->FirstChildElement();
		XMLElement *rhs = lhs->NextSiblingElement();
		if (rhs != NULL) { // binary
            if (rhs->NextSiblingElement() != NULL) {
                throw std::runtime_error("To many sibling elements in function call");
            }
			MX lhsExp = expressionToMX(m, lhs, funcVars);
			MX rhsExp = expressionToMX(m, rhs, funcVars);
			/*if (lhsExp.size() > 1) {
				lhsExp = lhsExp.at(0);
			}
			if (rhsExp.size() > 1) {
				rhsExp = rhsExp.at(0);
			}*/
			return builtinBinaryToMx(lhsExp, rhsExp, builtinAttr);
		} else { // unary
			return builtinUnaryToMx(expressionToMX(m, lhs, funcVars), builtinAttr);
		}
	} else {
		XMLElement *func = call->FirstChildElement();
		string funcName = func->FirstChildElement()->Attribute("name");
		if (m->getModelFunction(funcName) == NULL) {
			addFunc(funcName, call, m);
		}
		CasADi::MXFunction f = m->getModelFunction(funcName)->getMx();
		MXVector argVec;
		for (XMLElement *arg = func->NextSiblingElement(); arg != NULL; arg = arg->NextSiblingElement()) {
			if (isElement(arg, "call") && hasAttribute(arg, "builtin", "array")) {
				// special handling for array arguments, each array element is handled as a regular variable
				for (XMLElement *arr = arg->FirstChildElement(); arr != NULL; arr = arr->NextSiblingElement()) {
					MX arrCall = expressionToMX(m, arr, funcVars);
					for (int i=0; i < arrCall.size(); i++) {
						argVec.push_back(arrCall.at(i));
					}
				}
			} else {
				argVec.push_back(expressionToMX(m, arg, funcVars));
			}
		}
		MXVector outputs = f.call(argVec);
		MX returnMx;
		for (int i=0; i < outputs.size(); i++) {
			returnMx.append(outputs.at(i));
		}
		return returnMx;
	}
}

/**
 * Take a reference to an operator in the XML document and convert this
 * operator to a corresponding MX expression. If the operator is not supported throws an error
 */
MX operatorToMx(Ref<Model> m, XMLElement *op, std::map<string, Variable*> &funcVars) {
	if (hasAttribute(op, "name", "der")) {
		// handle calls to the der operator, lookup if we have introduced a differentiated variable 
		// for this der call, if we have proceed as with all others functions call. If not continue by
		// adding a diff variable and add it to the lookup table
		XMLElement *derChild = op->FirstChildElement();
		if (isElement(derChild, "local")) {
			const char *name = derChild->Attribute("name");
			Ref<Variable> var = m->getVariable(name);
			Ref<RealVariable> realVar = (RealVariable*)var.getNode();
			if (!hasDerivativeVar(m, realVar)) {
				addDerivativeVar(m, realVar, name);
			}
            return realVar->getMyDerivativeVariable()->getVar();
		} else {
            throw std::runtime_error("Der operator are only supported on locals");
		}
	} else if (hasAttribute(op, "name", "pre")) {
		XMLElement *preChild = op->FirstChildElement();
		string preCall = "pre(";
		preCall.append(preChild->Attribute("name"));
		preCall.append(")");
		return MX(preCall);
	} else if (hasAttribute(op, "name", "assert")) {
		return MX(0);
		// ignore asserts
	} else if (hasAttribute(op, "name", "noevent")) {
		// ignore noevent
		return expressionToMX(m, op->FirstChildElement(), funcVars);
	} else {
		// unsupported operators
		std::stringstream errorMessage;
		errorMessage << "Unsupported operator: " <<  op->Attribute("name");
		throw std::runtime_error(errorMessage.str());
	}
}

/**
 * Take a reference tag and convert it to an MX expression
 */
MX referenceToMx(Ref<Model> m, XMLElement *ref, std::map<string, Variable*> &funcVars) {
	// get the name of the function since this is needed to look up array dimensions
	string functionName = "";
	for (XMLElement *parent = ref->Parent()->ToElement(); parent != NULL; parent = parent->Parent()->ToElement()) {
		if (isElement(parent, "class") && hasAttribute(parent, "kind", "function")) {
			functionName = parent->Parent()->ToElement()->Attribute("name");
		}
	}
	XMLElement *varName = ref->FirstChildElement();
    if (isElement(varName, "local")) {
        int flatIndex = calculateFlatArrayIndex(m, ref, functionName, funcVars);
        string var (varName->Attribute("name"));
        std::stringstream ss;
        ss << flatIndex;
        var += "[" + ss.str() + "]";
        std::map<std::string, Variable*>::iterator it = funcVars.find(var);
        if (it != funcVars.end()) {
            return it->second->getVar();
        }
        std::stringstream errorMessage;
        errorMessage << "Reference to variable " << var << " not found";
        throw std::runtime_error(errorMessage.str());
    } else {
        std::stringstream errorMessage;
        errorMessage << "Expected local but got " << varName->Value() << " in reference tag";
        throw std::runtime_error(errorMessage.str());
    }
}

MX ifExpToMx(Ref<Model> m, XMLElement *expression, std::map<string, Variable*> &funcVars) {
	XMLElement *branching = expect(expression->FirstChildElement(), "cond");
	XMLElement *condition = branching->FirstChildElement();
	XMLElement *thenBranch = branching->NextSiblingElement()->FirstChildElement();
	XMLElement *elseBranch = branching->NextSiblingElement()->NextSiblingElement()->FirstChildElement();
	return CasADi::if_else(expressionToMX(m, condition, funcVars), expressionToMX(m, thenBranch, funcVars), expressionToMX(m, elseBranch, funcVars));
}

/**
 * Apply a builtin unary function to an MX expression and return the result
 */
MX builtinUnaryToMx(MX exp, const char *builtinName) {
	if (strcmp(builtinName, "sin") == 0) {
		return exp.sin();
	} else if (strcmp(builtinName, "sinh") == 0) {
		return exp.sinh();
	} else if (strcmp(builtinName, "asin") == 0) {
		return exp.arcsin();
	} else if (strcmp(builtinName, "cos") == 0) {
		return exp.cos();
	} else if (strcmp(builtinName, "cosh") == 0) {
		return exp.cosh();
	} else if (strcmp(builtinName, "acos") == 0) {
		return exp.arccos();
	} else if (strcmp(builtinName, "tan") == 0) {
		return exp.tan();
	} else if (strcmp(builtinName, "tanh") == 0) {
		return exp.tanh();
	} else if (strcmp(builtinName, "atan") == 0) {
		return exp.arctan();
	} else if (strcmp(builtinName, "log") == 0) {
		return exp.log();
	} else if (strcmp(builtinName, "log10") == 0) {
		return exp.log10();
	} else if (strcmp(builtinName, "sqrt") == 0) {
		return exp.sqrt();
	} else if (strcmp(builtinName, "abs") == 0) {
		return exp.fabs();
	} else if (strcmp(builtinName, "exp") == 0) {
		return exp.exp();
	} else if (strcmp(builtinName, "-") == 0) {
		return -exp;
	}
	std::stringstream errorMessage;
	errorMessage << "Unsupported unary expression: " << builtinName;
	throw std::runtime_error(errorMessage.str());
}

/**
 * Apply a builtin binary function to two MX expressions and return the result
 */
MX builtinBinaryToMx(MX lhs, MX rhs, const char *builtinName) {
	if (strcmp(builtinName, "+") == 0) {
		return lhs.__add__(rhs);
	} else if (strcmp(builtinName, "-") == 0) {
		return lhs.__sub__(rhs);
	} else if (strcmp(builtinName, "*") == 0) {
		return lhs.__mul__(rhs);
	} else if (strcmp(builtinName, "/") == 0) {
		return lhs.__div__(rhs);
	} else if (strcmp(builtinName, "^") == 0) {
		return lhs.__pow__(rhs);
	} else if (strcmp(builtinName, "min") == 0) {
		return lhs.fmin(rhs);
	} else if (strcmp(builtinName, "max") == 0) {
		return lhs.fmax(rhs);
	} else if (strcmp(builtinName, "atan2") == 0) {
		return lhs.arctan2(rhs);
	} else if (strcmp(builtinName, ">") == 0) {
		return rhs.__lt__(lhs);
	} else if (strcmp(builtinName, "<") == 0) {
		return lhs.__lt__(rhs);
	} else if (strcmp(builtinName, ">=") == 0) {
		return rhs.__le__(lhs);
	} else if (strcmp(builtinName, "<=") == 0) {
		return lhs.__le__(rhs);
	} else if (strcmp(builtinName, "==") == 0) {
		return lhs.__eq__(rhs);
	} else if (strcmp(builtinName, "<>") == 0) {
		return lhs.__ne__(rhs);
	} else if (strcmp(builtinName, "and") == 0) {
		return lhs.logic_and(rhs);
	} else if (strcmp(builtinName, "or") == 0) {
		return lhs.logic_or(rhs);
	}
	std::stringstream errorMessage;
	errorMessage << "Unsupported binary expression: " << builtinName;
	throw std::runtime_error(errorMessage.str());
}


/************************* Helper functions *************************/

/**
 * Check if a variable has a derivative variable linked to it
 */
bool hasDerivativeVar(Ref<Model> m, Ref<RealVariable> realVar) {
	return (realVar->getMyDerivativeVariable() != NULL);
}

/**
 * Convert a basetype string to the actual object type
 */
Ref<PrimitiveType> getBaseType(Ref<Model> m, const string baseTypeName) {
	if (m->getVariableType(baseTypeName) == NULL) {
		if (baseTypeName == "Real") {
			m->addNewVariableType(new RealType);
		} else if (baseTypeName == "Integer") {
			m->addNewVariableType(new IntegerType);
		} else if (baseTypeName == "Boolean") {
			m->addNewVariableType(new BooleanType);
		}
	}
	return (PrimitiveType*) m->getVariableType(baseTypeName).getNode();
}

/**
 * Take a causality string and return a corresponding causality enum value.
 */
Variable::Causality getCausality(const char *causality) {
	if (causality == NULL) {
		return Variable::INTERNAL;
	}
	if (strcmp(causality, "input") == 0) {
		return Variable::INPUT;
	} else if (strcmp(causality, "output") == 0) {
		return Variable::OUTPUT;
	}
	std::stringstream errorMessage;
	errorMessage << "Unsupported causality value: " << causality;
	throw std::runtime_error(errorMessage.str());
}

/**
 * Take a variability string and return a corresponding variability enum value.
 */
Variable::Variability getVariability(const char *variability) {
	if (variability == NULL) {
		return Variable::CONTINUOUS;
	}
	if (strcmp(variability, "parameter") == 0) {
		return Variable::PARAMETER;
	} else if (strcmp(variability, "discrete") == 0) {
		return Variable::DISCRETE;
	} else if (strcmp(variability, "constant") == 0) {
		return Variable::CONSTANT;
	}
	std::stringstream errorMessage;
	errorMessage << "Unsupported variability value: " << variability;
	throw std::runtime_error(errorMessage.str());
}

/**
 * Take a model and an XMLElement that points to a variable, retrieve
 * the derived type of the variable from the model.
 */
Ref<UserType> getUserType(Ref<Model> m, XMLElement *type) {
	if (isElement(type, "local")) {
		Ref<UserType> userType = (UserType*) m->getVariableType(type->Attribute("name")).getNode();
		if (userType.getNode() == NULL) {
            std::stringstream errorMessage;
            errorMessage << type->Attribute("name") << " derived type is not present in Model";
            throw std::runtime_error(errorMessage.str());
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
 * Take an XMLElement that contains an arbitrary number of dimensions and 
 * calculate a flat index from these dimensions
 */
int calculateFlatArrayIndex(Ref<Model> m, XMLElement *reference, string functionName, std::map<string, Variable*> &funcVars) {
	XMLElement *varName = reference->FirstChildElement();
	std::vector<int> dimensions;
	std::map<string, std::vector<int> >::iterator it = dimensionMap.find(functionName + varName->Attribute("name"));
	if (it != dimensionMap.end()) {
		dimensions = it->second;
	} else {
        std::stringstream errorMessage;
        errorMessage << " Dimensions for " << functionName << varName  << " could not be found";
        throw std::runtime_error(errorMessage.str());
    }
	//std::vector<int> dimensions = dimensionMap.find((functionName + varName->Attribute("name")))->second;
	std::vector<int> subscripts;
	for (XMLElement *sub = varName->NextSiblingElement(); sub != NULL; sub = sub->NextSiblingElement()) {
        if (isElement(sub->FirstChildElement(), "integer") || isElement(sub->FirstChildElement(), "real")) {
			subscripts.push_back(atoi(sub->FirstChildElement()->Attribute("value"))-1);
		} else {
			throw std::runtime_error("Only integer expressions and constants are supported as array indices");
		}
	}
	// convert subscripts to flat index
	int flatIndex = 0;
	int multiplier = 1;
	for (int i=subscripts.size()-1; i >= 0; i--) {
		flatIndex += subscripts.at(i) * multiplier;
		multiplier *= dimensions.at(i);
	}
	return flatIndex;
}

/**
 * Construct the scalar variable names from an array name and return
 * a vector containing them
 */
std::vector<string> getArrayVariables(XMLElement *elem, string functionName) {
	std::vector<string> arrayVars;
	std::vector<int> arrayDim;
	std::map<string, std::vector<int> >::iterator it = dimensionMap.find(functionName + elem->Attribute("name"));
	if (it != dimensionMap.end()) {
		arrayDim = it->second;
	} else {
        std::stringstream errorMessage;
        errorMessage << " Dimensions for array variable " << elem->Attribute("name") << " could not be found";
        throw std::runtime_error(errorMessage.str());
    }
	int varNumbers = 1;
	for (int i=0; i < arrayDim.size(); i++) {
		varNumbers *= arrayDim.at(i);
	}
	for (int i=0; i < varNumbers; i++) {
		string varName(elem->Attribute("name"));
		std::stringstream ss;
		ss << i;
		varName += "[" + ss.str() + "]";
		arrayVars.push_back(varName);
	}
	return arrayVars;
}

/**
 * Find a specific function in the XML and add it to the model. Used to 
 * ensure that all functions are added before they are called.
 */
void addFunc(string funcName, XMLElement *elem, Ref<Model> m) {
	// get to rootnode of document and then find the function
	XMLElement *function;
	for (XMLElement *parent = elem->Parent()->ToElement(); parent != NULL; parent = parent->Parent()->ToElement()) {
		function = parent;
	}

	for (XMLElement *func = function->FirstChildElement(); func != NULL; func = func->NextSiblingElement()) {
		if (isElement(func, "classDefinition") && hasAttribute(func, "name", funcName.c_str())) {
				transferFunction(m, func);
				return;
		}
	}
    std::stringstream errorMessage;
    errorMessage << "Function " << funcName << " could not be found";
    throw std::runtime_error(errorMessage.str());
}

/**
 * Check if an element matches the given name
 */
bool isElement(XMLElement *elem, const char *name){
    return (strcmp(elem->Value(), name) == 0);
}

/**
 * Check if an element has the given attribute
 */
bool hasAttribute(XMLElement *elem, const char *attrName) {
    const char *attr = elem->Attribute(attrName);
    if (attr != NULL) {
        return true;
    }
    return false;
}

bool hasAttribute(XMLElement *elem, const char *attrName, const char *attrValue) {
    if (elem->Attribute(attrName) != NULL) {
        return (strcmp(elem->Attribute(attrName), attrValue) == 0);
    }
    return false;
}

/**
 * Check if an element matches the given name, if not an error is throwed.
 */
XMLElement* expect(XMLElement *elem, const char *name) {
    if (isElement(elem, name)) {
        return elem;
    }
    std::stringstream errorMessage;
    errorMessage << "Expected element " << name << " but element was of type " << elem->Value();
	throw std::runtime_error(errorMessage.str());
}

/**
 * Parses the XML and throw an error if the parsing fails
 */
void parseXML(string modelName, const std::vector<string> &modelFiles, tinyxml2::XMLDocument &doc) {
    string fullPath;
	for (int i=0; i < modelFiles.size(); i++) {
		fullPath += modelFiles[i];
	}
	const char *fileName = fullPath.c_str();
    int errorCode = doc.LoadFile(fileName);
	if (errorCode != 0) {
        std::stringstream errorMessage;
        errorMessage << "Could not load XML document. TinyXML errorcode: " << errorCode;
		throw std::runtime_error(errorMessage.str());
	}
}

}; // end namespace