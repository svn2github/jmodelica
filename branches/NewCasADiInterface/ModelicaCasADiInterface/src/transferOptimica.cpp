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

// System includes
#include <iostream>

// Other transfer functionality, including shared with transferModelica. 
#include "jccutils.h"
#include "transferOptimica.hpp"

// Wrapped classes from the Optimica compiler
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
#include "org/jmodelica/optimica/compiler/FVariable.h"
#include "org/jmodelica/optimica/compiler/FRealVariable.h"
#include "org/jmodelica/optimica/compiler/FDerivativeVariable.h"
#include "org/jmodelica/optimica/compiler/FExp.h"
#include "org/jmodelica/optimica/compiler/FFunctionDecl.h"

// The ModelicaCasADi program
#include "Model.hpp"
#include "Constraint.hpp"

// For transforming output from JCC-wrapped classes to CasADi objects. 
// Must be included after FExp.h
#include "mxwrap.hpp"
#include "mxvectorwrap.hpp" 
#include "mxfunctionwrap.hpp" 

namespace oc = org::jmodelica::optimica::compiler;
namespace jl = java::lang;
using std::vector; using std::string;
using org::jmodelica::util::OptionRegistry;
using CasADi::MX;
using ModelicaCasADi::Model;
using ModelicaCasADi::Constraint;
using ModelicaCasADi::OptimizationProblem;
using ModelicaCasADi::CompilerOptionsWrapper;



vector<Constraint>* transferConstraints(oc::FOptClass &fc){
    java::util::ArrayList pcsList;
    vector<Constraint>* pcs = new vector<Constraint>();
    Constraint::Type type;
    for(int i = 0; i < 3; ++i){
        pcsList = (i==0 ? fc.pathLeqConstraints() : (i==1 ? fc.pathGeqConstraints() : fc.pathEqConstraints()));
        type = (i==0? Constraint::LEQ: (i==1? Constraint::GEQ : Constraint::EQ));
        for(int j = 0; j < pcsList.size(); ++j){
            oc::FRelationConstraint fr = oc::FRelationConstraint(pcsList.get(j).this$);
            Constraint c(toMX(fr.getLeft()), toMX(fr.getRight()),type); 
            pcs->push_back(c);
        }
    }
    return pcs;
}

OptimizationProblem* transferOptimizationProblem(string modelName, vector<string> modelFiles, CompilerOptionsWrapper options, string log_level) {
    // initalizeClass is needed on classes where static variables are acessed. 
    // See: http://mail-archives.apache.org/mod_mbox/lucene-pylucene-dev/201309.mbox/%3CBE880522-159F-4590-BC4D-9C5979A3594E@apache.org%3E
    jl::System::initializeClass(false);
    oc::OptimicaCompiler::initializeClass(false);
    
    // Create a model and optimica compiler
    Model* m = new Model();
    oc::OptimicaCompiler compiler(options.getOptionRegistry());
    
    java::lang::String fileVecJava[modelFiles.size()];
    for (int i = 0; i < modelFiles.size(); ++i) {
        fileVecJava[i] = StringFromUTF(modelFiles[i].c_str());
    }
    compiler.setLogger(StringFromUTF(log_level.c_str()));
    
    try {
        oc::FOptClass fclass =  oc::FOptClass(compiler.compileModel(new_JArray<java::lang::String>(fileVecJava, modelFiles.size()), 
                                                                    StringFromUTF(modelName.c_str())).this$);
       
       if (!env->isInstanceOf(fclass.this$, oc::FOptClass::initializeClass)) {
            throw std::runtime_error("An OptimizationProblem can not be created from a Modelica model");
        }
        
        /***** ModelicaCasADi::Model *****/
        // Transfer time variable
        transferTime<oc::FClass>(m, fclass);
        
        // Transfer user defined types (also generates base types for the user types). 
        transferUserDefinedTypes<oc::FClass, oc::List, oc::FDerivedType, oc::FAttribute, oc::FType>(m, fclass);
        
        // Variables template
        transferVariables<java::util::ArrayList, oc::FVariable, oc::FDerivativeVariable, oc::FRealVariable, oc::List, oc::FAttribute, oc::FStringComment> (m, fclass.allVariables());
        
        // Equations
        transferDaeEquations<java::util::ArrayList, oc::FAbstractEquation>(m, fclass.equations());
        transferInitialEquations<java::util::ArrayList, oc::FAbstractEquation>(m, fclass.initialEquations());
        
        // Functions
        transferFunctions<oc::FOptClass, oc::List, oc::FFunctionDecl>(m, fclass);
        
        /***** OptimizationProblem *****/
        
        // Mayer and Lagrange
        MX lagrangeTerm = fclass.objectiveIntegrandExp().this$ == NULL ? MX(0) : toMX(fclass.objectiveIntegrandExp());
        MX mayerTerm = fclass.objectiveExp().this$ == NULL ? MX(0) : toMX(fclass.objectiveExp());
        
        return new OptimizationProblem(m, *(transferConstraints(fclass)),  MX(fclass.startTimeAttribute()), 
                                       MX(fclass.finalTimeAttribute()), lagrangeTerm, mayerTerm);                   
    }
        catch (JavaError e) {
        std::cout << "Java error occurred: " << std::endl;
        describeJavaException();
        clearJavaException();
    }
    return NULL;
}
