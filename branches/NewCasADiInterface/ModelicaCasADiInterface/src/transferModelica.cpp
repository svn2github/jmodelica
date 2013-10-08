// System includes
#include <iostream>

// Other transfer functionality, including shared with transferModelica. 
#include "jccutils.h"
#include "transferModelica.hpp"

// Wrapped classes from the Modelica compiler
#include "org/jmodelica/modelica/compiler/AliasManager.h"
#include "org/jmodelica/modelica/compiler/ModelicaCompiler.h"
#include "org/jmodelica/modelica/compiler/FDerivedType.h"
#include "org/jmodelica/modelica/compiler/FType.h"
#include "org/jmodelica/modelica/compiler/FAttribute.h"
#include "org/jmodelica/modelica/compiler/FStringComment.h"
#include "org/jmodelica/modelica/compiler/SourceRoot.h"
#include "org/jmodelica/modelica/compiler/InstClassDecl.h"
#include "org/jmodelica/modelica/compiler/FClass.h"
#include "org/jmodelica/modelica/compiler/List.h"
#include "org/jmodelica/modelica/compiler/FAbstractEquation.h"
#include "org/jmodelica/modelica/compiler/FVariable.h"
#include "org/jmodelica/modelica/compiler/FRealVariable.h"
#include "org/jmodelica/modelica/compiler/FDerivativeVariable.h"
#include "org/jmodelica/modelica/compiler/FExp.h"
#include "org/jmodelica/modelica/compiler/FFunctionDecl.h"

// For transforming output from JCC-wrapped classes to CasADi objects. 
// Must be included after FExp.h
#include "mxwrap.hpp" 
#include "mxfunctionwrap.hpp" 
#include "mxvectorwrap.hpp" 

namespace mc = org::jmodelica::modelica::compiler;
namespace jl = java::lang;
using org::jmodelica::util::OptionRegistry;
using std::cout;  using std::endl; using std::string;
using std::vector;
using CasADi::MX;
using ModelicaCasADi::Model;

Model* transferModelicaModelWithoutInlining(std::string modelName, std::string modelFile) {
    org::jmodelica::util::OptionRegistry optr;    
    optr.addStringOption(StringFromUTF("inline_functions"), StringFromUTF("none"));
    return transferModelicaModel(modelName, modelFile, optr);
}

Model* transferModelicaModel(std::string modelName, std::string modelFile, OptionRegistry optr /*= OptionRegistry()*/) {
    // initalizeClass is needed on classes where static variables are acessed. 
    // See: http://mail-archives.apache.org/mod_mbox/lucene-pylucene-dev/201309.mbox/%3CBE880522-159F-4590-BC4D-9C5979A3594E@apache.org%3E
    jl::System::initializeClass(false); 
    
    Model* m = new Model();
    mc::ModelicaCompiler compiler(optr);

    try {
        mc::SourceRoot sourceRoot = compiler.parseModel(new_JArray(StringFromUTF(modelFile.c_str())));
        mc::InstClassDecl instance = compiler.instantiateModel(sourceRoot, StringFromUTF(modelName.c_str()));
        mc::FClass fclass =  compiler.flattenModel(instance);
        /***** ModelicaCasADi::Model *****/
            
        // Transfer user defined types (also generates base types for the user types). 
        transferUserDefinedTypes<mc::FClass, mc::List, mc::FDerivedType, 
                                 mc::FAttribute, mc::FType>(m, fclass);
        
        // Variables
        transferVariables<java::util::ArrayList, mc::FVariable, mc::FDerivativeVariable, 
                          mc::FRealVariable, mc::List, mc::FAttribute, mc::FStringComment> (m, fclass.allVariables());
        
        // Equations
        transferDaeEquations<java::util::ArrayList, mc::FAbstractEquation>(m, fclass.equations());
        transferInitialEquations<java::util::ArrayList, mc::FAbstractEquation>(m, fclass.initialEquations());
        
        // Functions
        transferFunctions<mc::FClass, mc::List, mc::FFunctionDecl>(m, fclass);
        
        // Done
        return m;                   
    }
        catch (JavaError e) {
        cout << "Java error occurred: " << endl;
        describeJavaException();
        clearJavaException();
    }
    return NULL;
    
}
