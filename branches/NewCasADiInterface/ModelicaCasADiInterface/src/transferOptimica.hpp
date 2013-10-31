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

#ifndef TRANSFER_OPTIMICA
#define TRANSFER_OPTIMICA

// Much of the transfer functionality lies here, shared with transferModelica
// and implemented with templates.
#include "sharedTransferFunctionality.hpp"

#include "OptimizationProblem.hpp"
#include "CompilerOptionsWrapper.hpp"

// Creates an optimica compiler and transfers the model modelName in the file modelFile. Optional compiler options.
ModelicaCasADi::OptimizationProblem* transferOptimizationProblem(std::string modelName,
                                                                 std::vector<std::string> modelFiles, 
                                                                 ModelicaCasADi::CompilerOptionsWrapper options, 
                                                                 std::string log_level);

#endif
