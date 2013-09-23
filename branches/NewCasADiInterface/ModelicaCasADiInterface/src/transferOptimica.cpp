// Other transfer functionality, including shared with transferModelica. 
#include "jccutils.h"
#include "transferOptimica.hpp"

// System includes
#include <iostream>

// Wrapped classes from the Optimica compiler
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



ModelicaCasADi::OptimizationProblem* transferOptimizationProblemWithoutInlining(std::string modelName, std::string modelFile) {
	org::jmodelica::util::OptionRegistry optr;    
    optr.addStringOption(StringFromUTF("inline_functions"), StringFromUTF("none"));
    return transferOptimizationProblem(modelName, modelFile, optr);
}

OptimizationProblem* transferOptimizationProblem(string modelName, string modelFile, OptionRegistry optr /*= OptionRegistry()*/) {
    // initalizeClass is needed on classes where static variables are acessed. 
    // See: http://mail-archives.apache.org/mod_mbox/lucene-pylucene-dev/201309.mbox/%3CBE880522-159F-4590-BC4D-9C5979A3594E@apache.org%3E
    jl::System::initializeClass(false);
    
    // Create a model and optimica compiler
    Model* m = new Model();
    oc::OptimicaCompiler compiler(optr);
    
    try {
        oc::SourceRoot sourceRoot = compiler.parseModel(new_JArray(StringFromUTF(modelFile.c_str())));
        oc::InstClassDecl instance = compiler.instantiateModel(sourceRoot, StringFromUTF(modelName.c_str()));
        oc::FOptClass fclass = oc::FOptClass(compiler.flattenModel(instance).this$);
        
        
        /***** ModelicaCasADi::Model *****/
        // Transfer user defined types (generates base types for the user types). 
        transferUserDefinedTypes<oc::FClass, oc::List, oc::FDerivedType, oc::FAttribute, oc::FType>(m, fclass);
        
        // Variables template <class ArrayList, class FVar, class JMDerivativeVariable, class JMRealVariable>
        transferVariables<java::util::ArrayList, oc::FVariable, oc::FDerivativeVariable, oc::FRealVariable, oc::List, oc::FAttribute, oc::FStringComment> (m, fclass.allVariables());
        
        // Equations
        transferDaeEquations<java::util::ArrayList, oc::FAbstractEquation>(m, fclass.equations());
        transferInitialEquations<java::util::ArrayList, oc::FAbstractEquation>(m, fclass.initialEquations());
        
        // Functions
        transferFunctions<oc::FOptClass, oc::List, oc::FFunctionDecl>(m, fclass);
        
        /***** OptimizationProblem *****/
        // If transferOptimica was used to transfer a Modelica model
        // then just return an empty OptimizationProblem with the model in it. 
        if (!env->isInstanceOf(fclass.this$, oc::FOptClass::initializeClass)) {
            std::vector<Constraint> cons;
            return new OptimizationProblem(m, cons, MX(0), MX(0), MX(0), MX(0)); 
        }
        
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
