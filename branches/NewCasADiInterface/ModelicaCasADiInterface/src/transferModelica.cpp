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
using ModelicaCasADi::CompilerOptionsWrapper;
using ModelicaCasADi::Ref;

Ref<Model> transferModelicaModel(string modelName, const vector<string> &modelFiles, Ref<CompilerOptionsWrapper> options, string log_level) {
    // initalizeClass is needed on classes where static variables are acessed. 
    // See: http://mail-archives.apache.org/mod_mbox/lucene-pylucene-dev/201309.mbox/%3CBE880522-159F-4590-BC4D-9C5979A3594E@apache.org%3E
    jl::System::initializeClass(false); 
    mc::ModelicaCompiler::initializeClass(false); 
    
    Ref<Model> m = new Model();
    mc::ModelicaCompiler compiler(options->getOptionRegistry());
    
    java::lang::String fileVecJava[modelFiles.size()];
    for (int i = 0; i < modelFiles.size(); ++i) {
        fileVecJava[i] = StringFromUTF(modelFiles[i].c_str());
    }
    compiler.setLogger(StringFromUTF(log_level.c_str()));

    try {
        mc::FClass fclass = compiler.compileModelNoCodeGen(
            new_JArray<java::lang::String>(fileVecJava, modelFiles.size()),
            StringFromUTF(modelName.c_str()));
        
        /***** ModelicaCasADi::Model *****/
        // Transfer time variable
        transferTime<mc::FClass>(m, fclass);
            
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
