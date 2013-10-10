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
