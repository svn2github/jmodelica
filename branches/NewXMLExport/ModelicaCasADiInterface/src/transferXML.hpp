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
#include "Ref.hpp"

// XML parser include
#include "tinyxml2.h"

namespace ModelicaCasADi {
CasADi::MX expressionToMX(Ref<Model> m, tinyxml2::XMLElement* expression, std::map<std::string, Variable*> &funcVars);
Ref<Model> transferXMLModel(Ref<Model> m,
	std::string modelName, const std::vector<std::string> &modelFiles);
};

#endif