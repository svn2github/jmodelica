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

#include "jccutils.h"
#include "transferOptimica.hpp"

// CasADi
#include "symbolic/casadi.hpp"

// Wrapped classes from the Optimica compiler
#include "java/lang/System.h"
#include "java/util/ArrayList.h"
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
#include "org/jmodelica/optimica/compiler/FTimedVariable.h"
#include "org/jmodelica/optimica/compiler/FIdUse.h"
#include "org/jmodelica/optimica/compiler/FExp.h"
#include "org/jmodelica/optimica/compiler/FFunctionDecl.h"
#include "org/jmodelica/optimica/compiler/Root.h"
#include "org/jmodelica/optimica/compiler/BaseNode.h"
#include "org/jmodelica/util/OptionRegistry.h"

// The ModelicaCasADi program
#include "Model.hpp"
#include "Constraint.hpp"
#include "TimedVariable.hpp"

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

namespace ModelicaCasADi {

vector< Ref<Constraint> >* transferPointConstraints(oc::FOptClass &fc){
    java::util::ArrayList pointConstraintsJM;
    vector< Ref<Constraint> >* pointConstraints = new vector< Ref<Constraint> >();
    Constraint::Type type;
    for(int i = 0; i < 3; ++i){
        pointConstraintsJM = (i==0 ? fc.pointLeqConstraints() : (i==1 ? fc.pointGeqConstraints() : fc.pointEqConstraints()));
        type = (i==0? Constraint::LEQ: (i==1? Constraint::GEQ : Constraint::EQ));
        for(int j = 0; j < pointConstraintsJM.size(); ++j){
            oc::FRelationConstraint fr = oc::FRelationConstraint(pointConstraintsJM.get(j).this$);
            pointConstraints->push_back(new Constraint(toMX(fr.getLeft()), toMX(fr.getRight()),type));
        }
    }
    return pointConstraints;
}


vector< Ref<Constraint> >* transferPathConstraints(oc::FOptClass &fc){
    java::util::ArrayList pathConstraintsJM;
    vector< Ref<Constraint> >* pathConstraints = new vector< Ref<Constraint> >();
    Constraint::Type type;
    for(int i = 0; i < 3; ++i){
        pathConstraintsJM = (i==0 ? fc.pathLeqConstraints() : (i==1 ? fc.pathGeqConstraints() : fc.pathEqConstraints()));
        type = (i==0? Constraint::LEQ: (i==1? Constraint::GEQ : Constraint::EQ));
        for(int j = 0; j < pathConstraintsJM.size(); ++j){
            oc::FRelationConstraint fr = oc::FRelationConstraint(pathConstraintsJM.get(j).this$);
            pathConstraints->push_back(new Constraint(toMX(fr.getLeft()), toMX(fr.getRight()),type));
        }
    }
    return pathConstraints;
}

vector< Ref<TimedVariable> > transferTimedVariables(Ref<Model> m, oc::FOptClass &fc) {
    java::util::ArrayList timedVarList = fc.timedRealVariables();
    vector< Ref< TimedVariable > > timedModelVariables;
    vector< Ref<Variable> > allVars = m->getAllVariables();
    vector< MX > timedMXVars;
    vector< MX > timedMXTimePoints;
    vector< MX > timedMXFVars;
    oc::FTimedVariable timedVar;
    for (int i = 0; i < timedVarList.size(); ++i) {
        timedVar = oc::FTimedVariable(timedVarList.get(i).this$);
        timedMXVars.push_back(toMX(timedVar));
        timedMXTimePoints.push_back(toMX(timedVar.getArg()));
        timedMXFVars.push_back(toMX(timedVar.getName().myFV().asMXVariable()));
    }
    for (int i = 0; i < timedMXFVars.size(); ++i) {
        bool foundCorrespondingVar = false;
        for  (int j = 0; j < allVars.size(); ++j) {
            if (timedMXFVars[i].isEqual(allVars[j]->getVar()) && !foundCorrespondingVar) {
                timedModelVariables.push_back(new TimedVariable(m.getNode(), timedMXVars[i], allVars[j], timedMXTimePoints[i]));
                foundCorrespondingVar = true;
            }
        }
        if (!foundCorrespondingVar) {
            throw std::runtime_error("Could not find base variable for timed variable");
        }
    }
    return timedModelVariables;
}

void transferOptimizationProblem(Ref<OptimizationProblem> optProblem,
    string modelName, const vector<string> &modelFiles, Ref<CompilerOptionsWrapper> options, string log_level)
{
    try {
        // initalizeClass is needed on classes where static variables are acessed. 
        // See: http://mail-archives.apache.org/mod_mbox/lucene-pylucene-dev/201309.mbox/%3CBE880522-159F-4590-BC4D-9C5979A3594E@apache.org%3E
        jl::System::initializeClass(false);
        oc::OptimicaCompiler::initializeClass(false);
        
        // Create Optimica compiler and compile to flat class
        oc::OptimicaCompiler compiler(options->getOptionRegistry());
        
        java::lang::String fileVecJava[modelFiles.size()];
        for (int i = 0; i < modelFiles.size(); ++i) {
            fileVecJava[i] = StringFromUTF(modelFiles[i].c_str());
        }
        compiler.setLogger(StringFromUTF(log_level.c_str()));
        oc::FOptClass fclass = oc::FOptClass(compiler.compileModelNoCodeGen(
            new_JArray<java::lang::String>(fileVecJava, modelFiles.size()), 
            StringFromUTF(modelName.c_str())).this$);

        std::string identfier = env->toString(fclass.nameUnderscore().this$);
        std::string option = "normalize_minimum_time_problems";
        bool normalizedTime = fclass.root()._get_options().getBooleanOption(StringFromUTF(option.c_str()));
            
        // Initialize the model with the model identfier and normalizedTime flag. 
        optProblem->initializeProblem(identfier, normalizedTime);
       
        if (!env->isInstanceOf(fclass.this$, oc::FOptClass::initializeClass)) {
            throw std::runtime_error("An OptimizationProblem can not be created from a Modelica model");
        }
        
        
        
        
        /***** ModelicaCasADi::Model *****/
        // Transfer time variable
        transferTime<oc::FClass>(optProblem, fclass);
        
        // Transfer user defined types (also generates base types for the user types). 
        transferUserDefinedTypes<oc::FClass, oc::List, oc::FDerivedType, oc::FAttribute, oc::FType>(optProblem, fclass);
        
        // Variables template
        transferVariables<java::util::ArrayList, oc::FVariable, oc::FDerivativeVariable, oc::FRealVariable, oc::List, oc::FAttribute, oc::FStringComment> (optProblem, fclass.allVariables());
        // Transfer timed variables. Depends on that other variables are transferred. 
        vector< Ref<TimedVariable> > timedVars = transferTimedVariables(optProblem, fclass);
        
        // Equations
        transferDaeEquations<java::util::ArrayList, oc::FAbstractEquation>(optProblem, fclass.equations());
        transferInitialEquations<java::util::ArrayList, oc::FAbstractEquation>(optProblem, fclass.initialEquations());
        
        // Functions
        transferFunctions<oc::FOptClass, oc::List, oc::FFunctionDecl>(optProblem, fclass);
        
        /***** OptimizationProblem *****/
        
        // Mayer and Lagrange
        MX lagrangeTerm = fclass.objectiveIntegrandExp().this$ == NULL ? MX(0) : toMX(fclass.objectiveIntegrandExp());
        MX mayerTerm = fclass.objectiveExp().this$ == NULL ? MX(0) : toMX(fclass.objectiveExp());
        
        optProblem->setPathConstraints(*(transferPathConstraints(fclass)));
        optProblem->setPointConstraints(*(transferPointConstraints(fclass)));
        optProblem->setStartTime(MX(fclass.startTimeAttribute()));
        optProblem->setFinalTime(MX(fclass.finalTimeAttribute()));
        optProblem->setTimedVariables(timedVars);
        optProblem->setLagrangeTerm(lagrangeTerm);
        optProblem->setMayerTerm(mayerTerm);
    }
    catch (JavaError e) {
        rethrowJavaException(e);
    }
}

}; // End namespace
