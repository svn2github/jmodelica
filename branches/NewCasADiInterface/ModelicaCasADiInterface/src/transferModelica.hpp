#ifndef TRANSFER_MODELICA
#define TRANSFER_MODELICA

// Much of the transfer functionality lies here, shared with transferOptimica
// and implemented with templates.
#include "sharedTransferFunctionality.hpp"

// The ModelicaCasADiModel
#include "Model.hpp"
#include "CompilerOptionsWrapper.hpp"

ModelicaCasADi::Model* transferModelicaModel(std::string modelName,
                                             std::vector<std::string> modelFiles, 
                                             ModelicaCasADi::CompilerOptionsWrapper options, 
                                             std::string log_level);

#endif
