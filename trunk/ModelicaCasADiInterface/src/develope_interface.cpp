#include <iostream>
#include <string>
#include <vector>
#include <stdlib.h>
#include "initjcc.h" // for env
#include "JCCEnv.h"
#include "jccutils.h"
#include "ifcasadi/MX.h"
#include "ifcasadi/ifcasadi.h"

#include "Ref.hpp"
#include "CompilerOptionsWrapper.hpp"
#include "sharedTransferFunctionality.hpp"
#include "casadi/casadi.hpp"

// Wrapped classes from the Modelica compiler
#include "java/lang/String.h"
#include "java/lang/System.h"
#include "java/util/ArrayList.h"
#include "java/util/Collection.h"
#include "java/util/LinkedHashMap.h"
#include "java/util/Set.h"
#include "java/util/Iterator.h"
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
#include "org/jmodelica/modelica/compiler/FEquation.h"
#include "org/jmodelica/modelica/compiler/FVariable.h"
#include "org/jmodelica/modelica/compiler/FRealVariable.h"
#include "org/jmodelica/modelica/compiler/FDerivativeVariable.h"
#include "org/jmodelica/modelica/compiler/FExp.h"
#include "org/jmodelica/modelica/compiler/FFunctionDecl.h"
#include "org/jmodelica/optimica/compiler/BLT.h"
#include "org/jmodelica/modelica/compiler/StructuredBLT.h"
#include "org/jmodelica/modelica/compiler/AbstractEquationBlock.h"
#include "org/jmodelica/modelica/compiler/SimpleEquationBlock.h"
#include "org/jmodelica/modelica/compiler/ScalarEquationBlock.h"
#include "org/jmodelica/modelica/compiler/SolvedScalarEquationBlock.h"
#include "org/jmodelica/modelica/compiler/EquationBlock.h"
#include "org/jmodelica/modelica/compiler/TornEquationBlock.h"

// Wrapped classes from the Optimica compiler
/*
#include "org/jmodelica/optimica/compiler/AliasManager.h"
#include "org/jmodelica/optimica/compiler/OptimicaCompiler.h"
#include "org/jmodelica/optimica/compiler/FStringComment.h"
#include "org/jmodelica/optimica/compiler/FAttribute.h"
#include "org/jmodelica/optimica/compiler/FDerivedType.h"
#include "org/jmodelica/optimica/compiler/FType.h"
#include "org/jmodelica/optimica/compiler/SourceRoot.h"
#include "org/jmodelica/optimica/compiler/InstClassDecl.h"
#include "org/jmodelica/optimica/compiler/FClass.h"
#include "org/jmodelica/optimica/compiler/FOptClass.h"
#include "org/jmodelica/optimica/compiler/FRelationConstraint.h"
#include "org/jmodelica/optimica/compiler/List.h"
#include "org/jmodelica/optimica/compiler/FAbstractEquation.h"
#include "org/jmodelica/optimica/compiler/FEquation.h"
#include "org/jmodelica/optimica/compiler/FVariable.h"
#include "org/jmodelica/optimica/compiler/FRealVariable.h"
#include "org/jmodelica/optimica/compiler/FDerivativeVariable.h"
#include "org/jmodelica/optimica/compiler/FTimedVariable.h"
#include "org/jmodelica/optimica/compiler/FIdUse.h"
#include "org/jmodelica/optimica/compiler/FExp.h"
#include "org/jmodelica/optimica/compiler/FFunctionDecl.h"
#include "org/jmodelica/optimica/compiler/Root.h"
#include "org/jmodelica/optimica/compiler/BaseNode.h"
#include "org/jmodelica/util/OptionRegistry.h"
#include "org/jmodelica/optimica/compiler/AbstractEquationBlock.h"
#include "org/jmodelica/optimica/compiler/SimpleEquationBlock.h"
#include "org/jmodelica/optimica/compiler/ScalarEquationBlock.h"
#include "org/jmodelica/optimica/compiler/SolvedScalarEquationBlock.h"
#include "org/jmodelica/optimica/compiler/EquationBlock.h"
#include "org/jmodelica/optimica/compiler/TornEquationBlock.h"
*/

#include "Block.hpp"

#include "Ref.hpp"
#include "Equation.hpp"
#include <iterator>
#include <algorithm>

#include "BaseModel.hpp"
#include "EquationContainer.hpp"
#include "FlatEquationList.hpp"
#include "BLTContainer.hpp"

// For transforming output from JCC-wrapped classes to CasADi objects. 
// Must be included after FExp.h
#include "mxwrap.hpp" 
#include "mxfunctionwrap.hpp" 
#include "mxvectorwrap.hpp" 

namespace mc = org::jmodelica::modelica::compiler;
namespace jl = java::lang;
using org::jmodelica::util::OptionRegistry;


int main(int argc, char ** argv)
{
   //Class
   std::string modelName("BLTExample");
   //std::string modelName("CombinedCycle.Substances.Gas");
   //std::string modelName("Modelica.Mechanics.Rotational.Examples.CoupledClutches");
   //Files
   std::vector<std::string> modelFiles;
   modelFiles.push_back("./example_blt.mo");
   //modelFiles.push_back("./CombinedCycle.mo");   
   //modelFiles.push_back("./MSL/Modelica");
   //modelFiles.push_back("./MSL/ModelicaServices");

   // Start java vitual machine  
   setUpJVM();
   {
      //OptionWrapper
      ModelicaCasADi::Ref<ModelicaCasADi::CompilerOptionsWrapper> options = new ModelicaCasADi::CompilerOptionsWrapper();
      options->setStringOption("inline_functions", "none");
      options->setBooleanOption("automatic_tearing", false);
      options->setBooleanOption("generate_html_diagnostics", true);
      //options->printCompilerOptions(std::cout);
      //Compiler      
      mc::ModelicaCompiler compiler(options->getOptionRegistry());
      java::lang::String fileVecJava[modelFiles.size()];
      for (int i = 0; i < modelFiles.size(); ++i) {
         fileVecJava[i] = StringFromUTF(modelFiles[i].c_str());
      }
      mc::FClass fclass = compiler.compileModelNoCodeGen(
         new_JArray<java::lang::String>(fileVecJava, modelFiles.size()),
         StringFromUTF(modelName.c_str()));
       
      std::string identfier = env->toString(fclass.nameUnderscore().this$);
      
      ModelicaCasADi::Ref<ModelicaCasADi::BaseModel> model = new ModelicaCasADi::BaseModel();
      model->initializeModel(identfier);
      // Transfer time variable
      transferTime<mc::FClass>(model, fclass);
      
      // Variables template
      transferVariables<java::util::ArrayList,
                        mc::FVariable,
                        mc::FDerivativeVariable,
                        mc::FRealVariable,
                        mc::List,
                        mc::FAttribute,
                        mc::FStringComment>(model, fclass.allVariables());
                        
      // Transfer user defined types (also generates base types for the user types). 
      transferUserDefinedTypes<mc::FClass,
                              mc::List,
                              mc::FDerivedType,
                              mc::FAttribute,
                              mc::FType>(model, fclass);
                              
      ModelicaCasADi::Ref<ModelicaCasADi::EquationContainer> eqContainer = new ModelicaCasADi::BLTContainer();
      
      if(eqContainer->hasBLT()){
            mc::BLT jblt =fclass.getDAEBLT();
            transferBLTToContainer<mc::BLT,
                        mc::AbstractEquationBlock,
                        java::util::Collection,
                        java::util::Iterator,
                        mc::FVariable,
                        mc::FAbstractEquation,
                        mc::FEquation,
                        mc::FExp,
                        JArray>(&jblt, eqContainer, model->getNodeToVariableMap(), true, false);
      }
      else{
            transferDaeEquationsToContainer<java::util::ArrayList, mc::FAbstractEquation>(eqContainer, fclass.equations());
      }
      
      model->setEquationContainer(eqContainer);
      
      transferInitialEquations<java::util::ArrayList,
                              mc::FAbstractEquation>(model, fclass.initialEquations());
                              
      // Functions
      transferFunctions<mc::FClass,
                        mc::List,
                        mc::FFunctionDecl>(model, fclass);
                        
      model->print(std::cout);
      
      model->eliminateAlgebraics();
      
      std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Variable> > eliminated = model->getEliminatedVariables();
      std::cout<<std::endl;
      model->print(std::cout);      
      model->BaseModel::substituteAllEliminateables();
      model->print(std::cout);  
      

   }
   tearDownJVM();
   std::cout<<"DONE\n";  
   return 0;
}
