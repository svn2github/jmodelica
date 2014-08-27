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

#include "transferXMLOptimization.hpp"
#include "transferXML.hpp"
#include "transferXML_impl.hpp"

namespace ModelicaCasADi {

using ModelicaCasADi::Model;
using ModelicaCasADi::Ref;
using ModelicaCasADi::OptimizationProblem;
using CasADi::MX;
using tinyxml2::XMLElement;
using std::string;

// forward declarations
void transferObjective(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);
void transferObjectiveIntegrand(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);

void transferStartTime(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);
void transferFinalTime(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);

void transferConstraints(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);
void transferTimedVariable(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);

ModelicaCasADi::Constraint::Type getConstraintType(std::string name);
CasADi::MX timedVarToMx(Ref<OptimizationProblem> optProblem, tinyxml2::XMLElement* timedVar);
std::string timedVarArgsToString(tinyxml2::XMLElement* timedVarArg);
// end forward declarations

void transferXMLOptimization(Ref<OptimizationProblem> optProblem, string modelName,
	const std::vector<string> &modelFiles) {
		// transfer model parts first
		//transferXMLModel(optProblem, modelName, modelFiles);
		optProblem->initializeProblem(modelName, true);
		optProblem->setTimeVariable(MX("time"));
        tinyxml2::XMLDocument doc;
        parseXML(modelName, modelFiles, doc);
        XMLElement *root = doc.FirstChildElement();
        if (root == NULL) {
            throw std::runtime_error("XML document does not have any root node");
        }
		for (XMLElement* rootChild = root->FirstChildElement(); rootChild != NULL; rootChild = rootChild->NextSiblingElement()) {
            if (isElement(rootChild, "component") || isElement(rootChild, "classDefinition")) {
                transferDeclarations(optProblem, rootChild);
			} else if (isElement(rootChild, "equation")) {
                const char *equType = rootChild->Attribute("kind");
                if (hasAttribute(rootChild, "kind", "initial") || hasAttribute(rootChild, "kind", "default") || !hasAttribute(rootChild, "kind")) {
                    transferEquations(optProblem, rootChild, equType);
                } else if (hasAttribute(rootChild, "kind", "parameter")) {
                    transferParameterEquations(optProblem, rootChild);
                } else {
                    std::stringstream errorMessage;
                    errorMessage << "Unsupported equation type: " << equType;
                    throw std::runtime_error(errorMessage.str());
                }
            } else if (!strcmp(rootChild->Value(), "objective")) {
                transferObjective(optProblem, rootChild);
			} else if(!strcmp(rootChild->Value(), "objectiveIntegrand")) {
				transferObjectiveIntegrand(optProblem, rootChild);
			} else if(!strcmp(rootChild->Value(), "startTime")) {
				transferStartTime(optProblem, rootChild);
			} else if (!strcmp(rootChild->Value(), "finalTime")) {
				transferFinalTime(optProblem, rootChild);
			} else if (!strcmp(rootChild->Value(), "constraint")) {
				transferConstraints(optProblem, rootChild);
			} else if (!strcmp(rootChild->Value(), "timedVariable")) {
				transferTimedVariable(optProblem, rootChild);
			} else {
                //std::stringstream errorMessage;
                //errorMessage << "Unsupported XML element: " << rootChild->Value();
                //throw std::runtime_error(errorMessage.str());
            }
		}
}

void transferObjective(Ref<OptimizationProblem> optProblem, XMLElement* objective) {
	std::map<string, ModelicaCasADi::Variable*> funcVars;
	optProblem->setObjective(expressionToMX(optProblem, objective->FirstChildElement(), funcVars));
}

void transferObjectiveIntegrand(Ref<OptimizationProblem> optProblem, XMLElement* objectiveIntegrand) {
	std::map<string, ModelicaCasADi::Variable*> funcVars;
	optProblem->setObjectiveIntegrand(expressionToMX(optProblem, objectiveIntegrand->FirstChildElement(), funcVars));
}

void transferStartTime(Ref<OptimizationProblem> optProblem, XMLElement* startTime) {
	MX start = MX(atof(startTime->FirstChildElement()->Attribute("value")));
	optProblem->setStartTime(start);
}

void transferFinalTime(Ref<OptimizationProblem> optProblem, XMLElement* finalTime) {
	MX final = MX(atof(finalTime->FirstChildElement()->Attribute("value")));
	optProblem->setFinalTime(final);
}

void transferConstraints(Ref<OptimizationProblem> optProblem, XMLElement* constraints) {
	std::map<string, ModelicaCasADi::Variable*> funcVars;
	std::vector<Ref<Constraint> >* pointConstraints = new std::vector<Ref<Constraint> >();
	std::vector<Ref<Constraint> >* pathConstraints = new std::vector<Ref<Constraint> >();
	for (XMLElement* constraint = constraints->FirstChildElement(); constraint != NULL; constraint = constraint->NextSiblingElement()) {
		Constraint::Type type = getConstraintType(constraint->Value());
		XMLElement* lhs = constraint->FirstChildElement();
		XMLElement* rhs = lhs->NextSiblingElement();
		if (constraint->Attribute("kind") != NULL) {
			if (!strcmp(constraint->Attribute("kind"), "pathConstraint")) {
				MX lhsMx = MX();
				MX rhsMx = MX();
				if (!strcmp(lhs->Value(), "operator") && !strcmp(lhs->Attribute("name"), "at")) {
					lhsMx = timedVarToMx(optProblem, lhs);
				} else {
					lhsMx = expressionToMX(optProblem, lhs, funcVars);
				}
				if (!strcmp(rhs->Value(), "operator") && !strcmp(rhs->Attribute("name"), "at")) {
					rhsMx = timedVarToMx(optProblem, rhs);
				} else {
					rhsMx = expressionToMX(optProblem, rhs, funcVars);
				}
				pathConstraints->push_back(new Constraint(lhsMx, rhsMx, type));
			} else {
				MX lhsMx = MX();
				MX rhsMx = MX();
				if (!strcmp(lhs->Value(), "operator") && !strcmp(lhs->Attribute("name"), "at")) {
					lhsMx = timedVarToMx(optProblem, lhs);
				} else {
					lhsMx = expressionToMX(optProblem, lhs, funcVars);
				}
				if (!strcmp(rhs->Value(), "operator") && !strcmp(rhs->Attribute("name"), "at")) {
					rhsMx = timedVarToMx(optProblem, rhs);
				} else {
					rhsMx = expressionToMX(optProblem, rhs, funcVars);
				}
				pointConstraints->push_back(new Constraint(lhsMx, rhsMx, type));
			}
		} else {
            std::stringstream errorMessage;
			errorMessage << "Invalid type of constraint: " << constraint->Attribute("kind");
			throw std::runtime_error(errorMessage.str());
        }
	}
	optProblem->setPathConstraints(*(pathConstraints));
	optProblem->setPointConstraints(*(pointConstraints));
}

void transferTimedVariable(Ref<OptimizationProblem> optProblem, XMLElement* timedVar) {
	std::map<string, ModelicaCasADi::Variable*> funcVars;
	// transfer timedvariables
	XMLElement* timedName = timedVar->FirstChildElement();
	string name = timedName->Attribute("name");
	name += "(";
	name += timedVarArgsToString(timedName->NextSiblingElement());
	name += ")";
	MX timedMXVar = MX(name);
	MX timedMxTimePoint = MX(expressionToMX(optProblem, timedName->NextSiblingElement(), funcVars));
	if (optProblem->getVariable(timedName->Attribute("name")) != NULL) {
		optProblem->addTimedVariable(new TimedVariable(optProblem.getNode(), timedMXVar, optProblem->getVariable(timedName->Attribute("name")), timedMxTimePoint));
	} else {
        std::stringstream errorMessage;
        errorMessage << "Base variable for timed variable " << name << " could not be found";
		throw std::runtime_error(errorMessage.str());
	}
}

Constraint::Type getConstraintType(string name) {
	if (name == "lessThan") {
		return Constraint::LEQ;
	} else if (name == "equal") {
		return Constraint::EQ;
	} else if (name == "greaterThan") {
		return Constraint::GEQ;
	}
    std::stringstream errorMessage;
    errorMessage << "Invalid constraint type: " << name;
	throw std::runtime_error(errorMessage.str());
}

MX timedVarToMx(Ref<OptimizationProblem> optProblem, XMLElement* timedVar) {
	XMLElement* timedName = timedVar->FirstChildElement();
	string name = timedName->Attribute("name");
	name += "(";
	name += timedVarArgsToString(timedName->NextSiblingElement());
	name += ")";
	/*std::vector<Ref <TimedVariable> > timedVars = optProblem->getTimedVariables();
	for (int i=0; i < timedVars.size(); i++) {
		if (!strcmp(timedVars.at(i)->getVar().getBaseVariable().getName(), timedName->Attribute("name"))) {
			if (!strcmp(timedVars.at(i)->getVar().getTimePoint().getName(), timedVarArgsToString(timedName->NextSiblingElement()))) {
				return timedVars.at(i)->getVar().getTimePoint();
			}
		}
	}*/
	return MX(name);
}

string timedVarArgsToString(XMLElement* timedVarArg) {
	if (!strcmp(timedVarArg->Value(), "call") && timedVarArg->Attribute("builtin") != NULL) {
		XMLElement* lhs = timedVarArg->FirstChildElement();
		XMLElement* rhs = lhs->NextSiblingElement();
		if (rhs != NULL) {
			return (timedVarArgsToString(lhs) + " " + timedVarArg->Attribute("builtin") + " " + timedVarArgsToString(rhs));
		}
	} else if (!strcmp(timedVarArg->Value(), "local")) {
		return timedVarArg->Attribute("name");
	} else if (!strcmp(timedVarArg->Value(), "integer") || !strcmp(timedVarArg->Value(), "real")) {
		return timedVarArg->Attribute("value");
	}
	return "";
}

};