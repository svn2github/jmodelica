#ifndef TRANSFER_MODELICA
#define TRANSFER_MODELICA

// Much of the transfer functionality lies here, shared with transferOptimica
// and implemented with templates.
#include "sharedTransferFunctionality.hpp"

// The ModelicaCasADiModel
#include "Model.hpp"

// Optimica compiler
#include "org/jmodelica/util/OptionRegistry.h"

// Creates an optimica compiler and transfers the model modelName in the file modelFile. Optional compiler options.
ModelicaCasADi::Model* transferModelicaModel(std::string modelName, std::string modelFile, org::jmodelica::util::OptionRegistry optr = org::jmodelica::util::OptionRegistry());

// Transfers a model without inlining. Temporary solution before the options passing functionality in Python has matured. 
ModelicaCasADi::Model* transferModelicaModelWithoutInlining(std::string modelName, std::string modelFile);

#endif
