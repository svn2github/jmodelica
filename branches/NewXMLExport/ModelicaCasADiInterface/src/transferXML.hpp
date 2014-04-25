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

#ifndef TRANSFER_XML
#define TRANSFER_XML

#include <string>
#include <stdlib.h>
#include <vector>

// casadi include
#include "symbolic/casadi.hpp"

// ModelicaCasadi interface includes
#include "Model.hpp"
#include "Variable.hpp"
#include "Equation.hpp"
#include "ModelFunction.hpp"
#include "RealVariable.hpp"
#include "IntegerVariable.hpp"
#include "BooleanVariable.hpp"
#include "DerivativeVariable.hpp"
#include "Ref.hpp"

//types
#include "types/VariableType.hpp"
#include "types/UserType.hpp"
#include "types/PrimitiveType.hpp"
#include "types/RealType.hpp"
#include "types/IntegerType.hpp"
#include "types/BooleanType.hpp"

// XML parser include
#include "tinyxml2.h"

namespace ModelicaCasADi {

ModelicaCasADi::Ref<ModelicaCasADi::Model> transferXmlModel(ModelicaCasADi::Ref<ModelicaCasADi::Model> m,
	std::string modelName, const std::vector<std::string> &modelFiles);

void transferVariables(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);
void transferInitialEquations(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);
void transferEquations(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);
void transferParameters(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);

void transferFunction(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);
void updateFunctionCall(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* stmt,
	CasADi::MXVector &expressions, CasADi::MXVector &vars, std::string functionName);
CasADi::MXVector getInputVector(ModelicaCasADi::Ref<ModelicaCasADi::Model>, tinyxml2::XMLElement* elem);
CasADi::MXVector getFuncVars(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement *elem);

void addRealVariable(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* variable);
void addIntegerVariable(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* variable);
void addBooleanVariable(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* variable);
void addDerivativeVar(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, ModelicaCasADi::Ref<ModelicaCasADi::RealVariable> realVar, std::string name);

CasADi::MX expressionToMx(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* expression);
CasADi::MX functionCallToMx(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* call);
CasADi::MX operatorToMx(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* op);
CasADi::MX referenceToMx(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* ref);
CasADi::MX ifExpToMx(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* expression);

ModelicaCasADi::Variable::Causality getCausality(const char* causality);
ModelicaCasADi::Variable::Variability getVariability(const char* variability);

CasADi::MX builtinUnaryToMx(CasADi::MX exp, const char* builtinName);
CasADi::MX builtinBinaryToMx(CasADi::MX lhs, CasADi::MX rhs, const char* builtinName);

bool hasDerivativeVar(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, ModelicaCasADi::Ref<ModelicaCasADi::RealVariable> realVar);
ModelicaCasADi::Ref<ModelicaCasADi::PrimitiveType> getBaseType(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, std::string baseTypeName);
ModelicaCasADi::Ref<ModelicaCasADi::UserType> getUserType(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);

int findIndex(CasADi::MXVector vector, std::string elem);
void addFunctionHeaders(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* elem);

int calculateFlatArrayIndex(ModelicaCasADi::Ref<ModelicaCasADi::Model> m, tinyxml2::XMLElement* reference, std::string functionName);
std::vector<std::string> getArrayVariables(tinyxml2::XMLElement* elem, std::string functionName);
//void addFunc(std::string funcName, tinyxml2::XMLElement* elem, ModelicaCasADi::Ref<ModelicaCasADi::Model> m);

};

#endif