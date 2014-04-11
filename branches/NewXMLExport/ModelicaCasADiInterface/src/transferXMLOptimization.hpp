
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

#ifndef TRANSFER_XML_OPT
#define TRANSFER_XML_OPT

#include <string>
#include <vector>

// include casadi
#include "symbolic/casadi.hpp"

#include "OptimizationProblem.hpp"
#include "Model.hpp"
// XML parser include
#include "tinyxml2.h"

namespace ModelicaCasADi {

void transferXmlOptimization(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, 
	std::string modelName, const std::vector<std::string> &modelFiles);

void transferObjective(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);
void transferObjectiveIntegrand(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);

void transferStartTime(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);
void transferFinalTime(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);

void transferConstraints(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);
void transferTimedVariable(ModelicaCasADi::Ref<ModelicaCasADi::OptimizationProblem> m, tinyxml2::XMLElement* elem);

ModelicaCasADi::Constraint::Type getConstraintType(std::string name);
CasADi::MX timedVarToMx(Ref<OptimizationProblem> optProblem, tinyxml2::XMLElement* timedVar);
std::string timedVarArgsToString(tinyxml2::XMLElement* timedVarArg);
};

#endif