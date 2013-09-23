#include "jni.h"    
#include <iostream>

// Optimizer
#include <Optimizer.cpp>
#include "../common/genPythonScript.cpp"

// The ModelicaCasADiModel
#include <OptimizationProblem.hpp>

// Transfer method
#include <transferOptimica.hpp>


int main(int argc, char *argv[])
{
    // Use together with make OptModel to change the model for a compiled program
    std::string model     = (argc >= 3 ? argv[2] : "optimizationOneWithMessyFunction");
    std::string modelFile = (argc >= 4 ? argv[3] : "../common/optimizationProblems.mop");
    
    setUpJVM(argv[1]);
    
    // Compile and transfer, argv[1] = <classpath>
    ModelicaCasADi::OptimizationProblem* om = transferOptimizationProblem(modelFile, model);
    std::vector<double> sol;
    if (om!=NULL){
        std::cout << *om << std::endl;
        optimizer::optimize(*om, 100, sol);
        genScript(*om, 100, sol);
    }
    
    tearDownJVM();
    return 0;
}
