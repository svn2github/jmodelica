#include <iostream>
#include <string>
#include <vector>
#include <stdlib.h>
#include "initjcc.h" // for env
#include "JCCEnv.h"
#include "jccutils.h"
#include "ifcasadi/MX.h"
#include "ifcasadi/ifcasadi.h"
#include "mxwrap.hpp"

#include "Ref.hpp"
#include "CompilerOptionsWrapper.hpp"

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
#include "BLTHandler.hpp"
#include "Ref.hpp"
#include "Equation.hpp"
#include <iterator>
#include <algorithm>

namespace mc = org::jmodelica::modelica::compiler;
namespace jl = java::lang;
using org::jmodelica::util::OptionRegistry;


void setUpJVM() {
   std::cout << "Creating JVM" << std::endl;
   jint version = initJVM();
   std::cout << "Created JVM, JNI version " << (version>>16) << "." << (version&0xffff) << '\n' << std::endl;
}

void tearDownJVM() {
   // Make sure that no JCC proxy objects live in this scope, as they will then  
   // try to free their java objects after the JVM has been destroyed. 
   std::cout << "\nDestroying JVM" << std::endl;
   destroyJVM();
   std::cout << "Destroyed JVM" << std::endl;
}


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
         
   
      
      //Plain BLT
      mc::BLT blt = fclass.getDAEBLT();
      
      ModelicaCasADi::BLTHandler blocksHandler = ModelicaCasADi::BLTHandler();
      
      blocksHandler.setBLT<mc::BLT,
                          mc::AbstractEquationBlock,
                          java::util::Collection,
                          java::util::Iterator,
                          mc::FVariable,
                          mc::FAbstractEquation,
                          mc::FEquation,
                          mc::FExp,
                          JArray>(blt, true, false);
      blocksHandler.printBLT(std::cout, true);
      
      std::cout<<"\nModel Eliminatable Variables\n";                    
      std::vector<casadi::MX> eliminateables = blocksHandler.getAllEliminatableVariables();      
      std::copy(eliminateables.begin(), eliminateables.end(), std::ostream_iterator<casadi::MX>(std::cout, " "));
      std::cout<<"\n\nModel Equations\n";
      std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> > modelDAEequations = blocksHandler.getAllEquations4Model();      
      for(std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> >::const_iterator it=modelDAEequations.begin(); 
        it != modelDAEequations.end();++it){
           std::cout<< (*it)->getLhs() <<" = "<< (*it)->getRhs() << "\n";
      }
      std::cout<<"\n Model Equations After substitution of all eliminateables\n";
      blocksHandler.substituteAllEliminateables();
      modelDAEequations = blocksHandler.getAllEquations4Model();      
      for(std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> >::const_iterator it=modelDAEequations.begin(); 
        it != modelDAEequations.end();++it){
           std::cout<< (*it)->getLhs() <<" = "<< (*it)->getRhs() << "\n";
      }
      
      /*blocksHandler.printBLT(std::cout, true);
      ModelicaCasADi::Block* b1 = blockHandler.getBlock(1);
      b1->printBlock(std::cout,true);
      casadi::MX toSubstitute = b1->getInactiveVarByName("der(x3)");
      std::vector<casadi::MX> v(1,toSubstitute);
      std::vector<casadi::MX> s(1,casadi::MX(3));
      b1->substituteVariablesInExpressions(v,s);
      b1->printBlock(std::cout,true);*/
      
      /*for(int i=0;i<blt.size();++i)
      {
         //Block
         mc::AbstractEquationBlock* block = new mc::AbstractEquationBlock(blt.get(i).this$);
         ModelicaCasADi::Block* blockCI = new ModelicaCasADi::Block();
         
         std::cout<<"BlockType "<<env->toString(block->getClass().this$)<<"\n";
         blockCI->setBlock<mc::AbstractEquationBlock,
                              java::util::Collection,
                              java::util::Iterator,
                              mc::FVariable,
                              mc::FAbstractEquation,
                              mc::FEquation,
                              mc::FExp,
                              JArray>(block,false);
         blockCI->printBlock(std::cout,true);
         
         //Equations
         java::util::Collection block_equations(block->allEquations().this$);
         java::util::Collection block_variables(block->allVariables().this$);
         std::cout<<"Block_"<<i<<"\n";//<<env->toString(block->toString().this$)<<"\n";
         std::cout<<"BlockType "<<env->toString(block->getClass().this$)<<"\n";
         
         //Help iterator         
         java::util::Iterator iter(block_equations.iterator().this$);
         int k=0;
         while(iter.hasNext()){
            std::cout<<"\tEquation_"<<k<<":\t"<<env->toString(iter.next().toString().this$)<<"\n";
            k=k+1;
         } 
         
         k=0;
         java::util::Collection unsolved_eq(block->unsolvedEquations().this$);
         iter = java::util::Iterator(unsolved_eq.iterator().this$);
         while(iter.hasNext()){
            std::cout<<"\tUnsolved_Equation_"<<k<<":\t"<<env->toString(iter.next().toString().this$)<<"\n";
            k=k+1;
         }  
         
         iter = java::util::Iterator(block_variables.iterator().this$);
         std::cout<<"\n\tVariables: ";
         while(iter.hasNext()){
              std::cout<<env->toString(iter.next().toString().this$)<<" ";
         }
         std::cout<<std::endl;
         
         java::util::Collection unsolved_vars(block->unsolvedVariables().this$);
         iter = java::util::Iterator(unsolved_vars.iterator().this$);
         std::cout<<"\n\tUnsolved variables: ";
         while(iter.hasNext()){
              std::cout<<env->toString(iter.next().toString().this$)<<" ";
         }
         
         java::util::Collection block_inactive_var(block->inactiveVariables().this$);
         iter = java::util::Iterator(block_inactive_var.iterator().this$);
         std::cout<<"\n\tInactive variables: ";
         while(iter.hasNext()){
              std::cout<<env->toString(iter.next().toString().this$)<<" ";
         }
         std::cout<<std::endl;
         
         java::util::Collection block_trajectories_var(block->dependsOn().this$);
         iter = java::util::Iterator(block_trajectories_var.iterator().this$);
         std::cout<<"\n\tTrajectory variables: ";
         while(iter.hasNext()){
              std::cout<<env->toString(iter.next().toString().this$)<<" ";
         }
         std::cout<<std::endl;
         
         java::util::Collection block_independent_var(block->independentVariables().this$);
         iter = java::util::Iterator(block_independent_var.iterator().this$);
         std::cout<<"\n\tIndependent variables: ";
         while(iter.hasNext()){
              std::cout<<env->toString(iter.next().toString().this$)<<" ";
         }
         std::cout<<std::endl;
         
         if(block->isSolvable()){
            std::cout<<"\n\tisSolvableBlock\n";
         }
         delete block;
         delete blockCI;
      }*/
      /*mc::AbstractEquationBlock* block = new mc::AbstractEquationBlock(blt.get(1).this$);
      ModelicaCasADi::Block* blockCI2 = new ModelicaCasADi::Block();
      blockCI2->setBlock<mc::AbstractEquationBlock,
                              java::util::Collection,
                              java::util::Iterator,
                              mc::FVariable,
                              mc::FAbstractEquation,
                              mc::FEquation,
                              mc::FExp>(block);
      
      blockCI2->setBlock<mc::AbstractEquationBlock,
                              java::util::Collection,
                              java::util::Iterator,
                              mc::FVariable,
                              mc::FAbstractEquation,
                              mc::FEquation
                              mc::FExp>(block);*/
      
      //std::cout<<"\nBLT_Printed\n "<<blt.size()<<"\n"<<env->toString(fclass.printDAEBLT().this$)<<"\n";
      
      
      //Structured
      //mc::StructuredBLT structured_blt = fclass.getDAEStructuredBLT();
      //std::cout<<"Structured_BLT\n "<<env->toString(fclass.getDAEStructuredBLT().this$)<<"\n";
      
      

   }
   tearDownJVM();
   std::cout<<"DONE\n";  
   return 0;
}
