#include "jni.h"    
#include <iostream>

// The ModelicaCasADiModel
#include <Model.hpp>

// Transfer method
#include <transferModelica.hpp>


int main(int argc, char *argv[])
{
    // Use together with make OptModel to change the model for a compiled program
    std::string model     = (argc >= 3 ? argv[2] : "simpleModelWithFunctions");
    std::string modelFile = (argc >= 4 ? argv[3] : "../common/modelicaModels.mo");
    
    setUpJVM(argv[1]);
    
    // Compile and transfer, argv[1] = <classpath>
    ModelicaCasADi::Model* m = transferModelicaModel(modelFile, model);
    
    if(m!=NULL){
        std::cout << *m << std::endl;
    }
    
    tearDownJVM();
    return 0;
}
