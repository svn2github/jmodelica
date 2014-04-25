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

using ModelicaCasADi::Model;
using ModelicaCasADi::Ref;
using ModelicaCasADi::OptimizationProblem;
using CasADi::MX;
using tinyxml2::XMLElement;
using std::string;

namespace ModelicaCasADi {

void transferXmlOptimization(Ref<OptimizationProblem> optProblem, string modelName,
	const std::vector<string> &modelFiles) {
		// transfer model parts first
		transferXmlModel(optProblem, modelName, modelFiles);
		optProblem->initializeProblem(modelName, true);
		optProblem->setTimeVariable(MX("time"));

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
		bool lagrangeSet = false;
		bool mayerSet = false;
		for (XMLElement* rootChild = root->FirstChildElement(); rootChild != NULL; rootChild = rootChild->NextSiblingElement()) {
			if (!strcmp(rootChild->Value(), "objective")) {
				mayerSet = true;
				transferObjective(optProblem, rootChild);
			} else if(!strcmp(rootChild->Value(), "objectiveIntegrand")) {
				lagrangeSet = true;
				transferObjectiveIntegrand(optProblem, rootChild);
			} else if(!strcmp(rootChild->Value(), "startTime")) {
				transferStartTime(optProblem, rootChild);
			} else if (!strcmp(rootChild->Value(), "finalTime")) {
				transferFinalTime(optProblem, rootChild);
			} else if (!strcmp(rootChild->Value(), "constraint")) {
				transferConstraints(optProblem, rootChild);
			} else if (!strcmp(rootChild->Value(), "timedVariable")) {
				transferTimedVariable(optProblem, rootChild);
			}
		}
		if (!lagrangeSet) {
			optProblem->setLagrangeTerm(MX(0));
		}
		if (!mayerSet) {
			optProblem->setMayerTerm(MX(0));
		}
}

void transferObjective(Ref<OptimizationProblem> optProblem, XMLElement* objective) {
	optProblem->setMayerTerm(expressionToMx(optProblem, objective->FirstChildElement()));
}

void transferObjectiveIntegrand(Ref<OptimizationProblem> optProblem, XMLElement* objectiveIntegrand) {
	optProblem->setLagrangeTerm(expressionToMx(optProblem, objectiveIntegrand->FirstChildElement()));
}

void transferStartTime(Ref<OptimizationProblem> optProblem, XMLElement* startTime) {
	MX start = MX(atoi(startTime->FirstChildElement()->Attribute("value")));
	optProblem->setStartTime(start);
}

void transferFinalTime(Ref<OptimizationProblem> optProblem, XMLElement* finalTime) {
	MX final = MX(atoi(finalTime->FirstChildElement()->Attribute("value")));
	optProblem->setFinalTime(final);
}

void transferConstraints(Ref<OptimizationProblem> optProblem, XMLElement* constraints) {
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
					lhsMx = expressionToMx(optProblem, lhs);
				}
				if (!strcmp(rhs->Value(), "operator") && !strcmp(rhs->Attribute("name"), "at")) {
					rhsMx = timedVarToMx(optProblem, rhs);
				} else {
					rhsMx = expressionToMx(optProblem, rhs);
				}
				pathConstraints->push_back(new Constraint(lhsMx, rhsMx, type));
			} else {
				MX lhsMx = MX();
				MX rhsMx = MX();
				if (!strcmp(lhs->Value(), "operator") && !strcmp(lhs->Attribute("name"), "at")) {
					lhsMx = timedVarToMx(optProblem, lhs);
				} else {
					lhsMx = expressionToMx(optProblem, lhs);
				}
				if (!strcmp(rhs->Value(), "operator") && !strcmp(rhs->Attribute("name"), "at")) {
					rhsMx = timedVarToMx(optProblem, rhs);
				} else {
					rhsMx = expressionToMx(optProblem, rhs);
				}
				pointConstraints->push_back(new Constraint(lhsMx, rhsMx, type));
			}
		}
	}
	optProblem->setPathConstraints(*(pathConstraints));
	optProblem->setPointConstraints(*(pointConstraints));
}

void transferTimedVariable(Ref<OptimizationProblem> optProblem, XMLElement* timedVar) {
	// transfer timedvariables
	std::vector<Ref<Variable> > allVars = optProblem->getAllVariables();
	XMLElement* timedName = timedVar->FirstChildElement();
	string name = timedName->Attribute("name");
	name += "(";
	name += timedVarArgsToString(timedName->NextSiblingElement());
	name += ")";
	MX timedMXVar = MX(name);
	MX timedMxTimePoint = MX(expressionToMx(optProblem, timedName->NextSiblingElement()));
	if (optProblem->getVariable(timedName->Attribute("name")) != NULL) {
		optProblem->addTimedVariable(new TimedVariable(optProblem.getNode(), timedMXVar, optProblem->getVariable(timedName->Attribute("name")), timedMxTimePoint));
	} else {
		throw std::runtime_error("Basetype for timed variable could not be found");
	}
}

Constraint::Type getConstraintType(string name) {
	if (name == "lessThan") {
		return Constraint::LEQ;
	} else if (name == "equal") {
		return Constraint::EQ;
	} else {
		return Constraint::GEQ;
	}
}

MX timedVarToMx(Ref<OptimizationProblem> optProblem, XMLElement* timedVar) {
	XMLElement* timedName = timedVar->FirstChildElement();
	string name = timedName->Attribute("name");
	name += "(";
	name += timedVarArgsToString(timedName->NextSiblingElement());
	name += ")";
	/*std::vector<Ref <TimedVariable> > timedVars = getTimedVariables();
	for (int i=0; i < timedVars.size(); i++) {
		if (!strcmp(timedVars.at(i)->getVar().getBaseVariable().getName(), timedName->Attribute("name"))) {
			if (!strcmp(timedVars.at(i)->getVar().getTimePoint().getName(), timedVarArgsToString(timedName->))) {
				return timedVars.at(i);
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