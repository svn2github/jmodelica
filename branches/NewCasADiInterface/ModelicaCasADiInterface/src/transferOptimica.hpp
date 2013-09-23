#ifndef TRANSFER_OPTIMICA
#define TRANSFER_OPTIMICA

// Much of the transfer functionality lies here, shared with transferModelica
// and implemented with templates.
#include "sharedTransferFunctionality.hpp"

#include "OptimizationProblem.hpp"

#include "org/jmodelica/util/OptionRegistry.h"

// Creates an optimica compiler and transfers the model modelName in the file modelFile. Optional compiler options.
ModelicaCasADi::OptimizationProblem* transferOptimizationProblem(std::string modelName, std::string modelFile, org::jmodelica::util::OptionRegistry optr = org::jmodelica::util::OptionRegistry());

// Transfers an optimization problem without inlining. Temporary solution before the options passing functionality in Python has matured. 
ModelicaCasADi::OptimizationProblem* transferOptimizationProblemWithoutInlining(std::string modelName, std::string modelFile);

#endif
