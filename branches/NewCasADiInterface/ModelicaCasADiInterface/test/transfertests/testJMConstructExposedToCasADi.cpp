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

#include "jni.h"    
#include <iostream>
#include <cassert>

// CasADi
#include <symbolic/casadi.hpp>

// JCC wrappers
#include "casadi/MX.h"
#include "casadi/MXFunction.h"

// Optimica compiler
#include "org/jmodelica/util/OptionRegistry.h"
#include "org/jmodelica/modelica/compiler/ModelicaCompiler.h"
#include "org/jmodelica/modelica/compiler/SourceRoot.h"
#include "org/jmodelica/modelica/compiler/InstClassDecl.h"
#include "org/jmodelica/modelica/compiler/FClass.h"
#include "org/jmodelica/modelica/compiler/List.h"
#include "org/jmodelica/modelica/compiler/FEquationBlock.h"
#include "org/jmodelica/modelica/compiler/FEquation.h"
#include "org/jmodelica/modelica/compiler/FFunctionCallEquation.h"
#include "org/jmodelica/modelica/compiler/FVariable.h"
#include "org/jmodelica/modelica/compiler/FExp.h"
#include "org/jmodelica/modelica/compiler/FFunctionCall.h"
#include "org/jmodelica/modelica/compiler/FFunctionDecl.h"


// Java lib
#include "java/lang/System.h"
#include "java/lang/String.h"
#include "java/util/ArrayList.h"

#include "initjcc.h"
#include "jccutils.h"
#include "mxwrap.hpp" // Must be included after FExp.h
#include "mxfunctionwrap.hpp" 

#include "sharedTransferFunctionality.hpp"

// Paths needed to run the test
#include "modelicacasadi_paths.h"

#include "jccutils.h"


using org::jmodelica::util::OptionRegistry;
namespace mc = org::jmodelica::modelica::compiler;
namespace jl = java::lang;
using java::util::ArrayList;
using mc::List;
using std::cout; using std::endl;
using std::vector; using std::string;

using namespace CasADi;

void assertNear(double val1, double val2, double error) {
    assert( std::abs(val1-val2) < std::abs(error) );
}


mc::FClass compileModelicaModelFromAtomicModelicaModelsToFclass(string modelName) {
    OptionRegistry::initializeClass(false);
    mc::ModelicaCompiler::initializeClass(false);
    mc::SourceRoot::initializeClass(false);
    mc::InstClassDecl::initializeClass(false);
    mc::FClass::initializeClass(false);
    mc::List::initializeClass(false);
    mc::FEquationBlock::initializeClass(false);
    mc::FEquation::initializeClass(false);
    mc::FExp::initializeClass(false);
    jl::System::initializeClass(false);
    jl::String::initializeClass(false);
    
    OptionRegistry optr;
    optr.addStringOption(StringFromUTF("inline_functions"), StringFromUTF("none"));
    mc::ModelicaCompiler compiler(optr);
    try {
        mc::SourceRoot sourceRoot = compiler.parseModel(new_JArray(StringFromUTF(string(MODELICACASADI_MODELPATH "/atomicModelicaModels.mo").c_str())));
        mc::InstClassDecl instance = compiler.instantiateModel(sourceRoot, StringFromUTF(modelName.c_str()));
        return compiler.flattenModel(instance);
    }
        catch (JavaError e) {
        cout << "Java error occurred: " << endl;
        describeJavaException();
        clearJavaException();
    }
}

int main(int argc, char *argv[])
{
    cout << " ===================="
            " Running JM constructs transfer tests  ====================" << endl;
        
    setUpJVM();
    
    /* Atomic expressions */  
    {  // Algebra
        //der(x1) = x1+2;
        //der(x2) = x2-x1;
        //der(x3) = x3*x2;
        //der(x4) = x4/x3
        ArrayList equations = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelElementaryExpressions").equations();
        const string expected = "MX((Const<2>(scalar)+x1))"
                                "MX((x2-x1))"
                                "MX((x3*x2))"
                                "MX((x4/x3))";
        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX((mc::FEquation(equations.get(i).this$)).getRight());
        }
        assert( expected == actual.str() );
    }
    { // Elementary function
        //der(x1) = x1^5;
        //der(x2) = abs(x2);
        //der(x3) = min(x3,x2);
        //der(x4) = max(x4,x3);
        //der(x5) = sqrt(x5);
        //der(x6) = sin(x6);
        //der(x7) = cos(x7);
        //der(x8) = tan(x8);
        //der(x9) = asin(x9);
        //der(x10) = acos(x10);
        //der(x11) = atan(x11);
        //der(x12) = atan2(x12, x11);
        //der(x13) = sinh(x13);
        //der(x14) = cosh(x14);
        //der(x15) = tanh(x15);
        //der(x16) = exp(x16);
        //der(x17) = log(x17);
        //der(x18) = log10(x18);
        //der(x19) = -x18;;
        ArrayList equations = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelElementaryFunctions").equations();
        const string expected = "MX(pow(x1,Const<5>(scalar)))MX(fabs(x2))MX(fmin(x3,x2))MX(fmax(x4,x3))MX(sqrt(x5))"
                                "MX(sin(x6))MX(cos(x7))MX(tan(x8))MX(asin(x9))MX(acos(x10))"
                                "MX(atan(x11))MX(atan2(x12,x11))MX(sinh(x13))MX(cosh(x14))MX(tanh(x15))"
                                "MX(exp(x16))MX(log(x17))MX((Const<0.434294>(scalar)*log(x18)))MX((-x18))"; // CasADi converts log10 to log with constant.
        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX((mc::FEquation(equations.get(i).this$)).getRight());
        }
        assert( expected == actual.str() );
    }
    { // Boolean expressions
        //der(x1) = if(x2) then 1 else 2;
        //x2 = x1 > 0;
        //x3 = x1 >= 0;
        //x4 = x1 < 0;
        //x5 = x1 <= 0;
        //x6 = x5 == x4;
        //x7 = x6 <> x5;
        //x8 = x6 and x5;
        //x9 = x6 or x5;
        ArrayList equations = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelBooleanExpressions").equations();
        const string expected = "MX(((x2?Const<1>(scalar):0)+((!x2)?Const<2>(scalar):0)))MX((Const<0>(scalar)<x1))"
                                 "MX((Const<0>(scalar)<=x1))MX((x1<Const<0>(scalar)))MX((x1<=Const<0>(scalar)))"
                                 "MX((x5==x4))MX((x6!=x5))MX((x6&&x5))MX((x6||x5))";
        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX((mc::FEquation(equations.get(i).this$)).getRight());
        }
        assert( expected == actual.str() );
    }
    { // Misc expressions and variables.
        // Tests literals, derivative variable, pre variable, FVariable, 
        // Model equations:
        //der(x1) = 1.11;
        //x2 =if(x3) then 3 else 4;
        //x3 = true or (x2 > 1);
        //x4 = false and x3;
        // Flat class initial equations:
        //x1 = 0.0;
        //pre(x2) = 0;
        //pre(x3) = false;
        //pre(x4) = false;


        ArrayList equations = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelMisc").equations();
        const string expected = "MX(der_x1)MX(Const<1.11>(scalar))MX(x2)MX(((x3?Const<3>(scalar):0)"
                                "+((!x3)?Const<4>(scalar):0)))MX(x3)MX((Const<1>(scalar)||(Const<1>"
                                "(scalar)<x2)))MX(x4)MX((Const<0>(scalar)||x3))"
                                "MX(x1)MX(Const<0>(scalar))MX(pre_x2)MX(Const<0>(scalar))"
                                "MX(pre_x3)MX(Const<0>(scalar))MX(pre_x4)MX(Const<0>(scalar))";
        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX((mc::FEquation(equations.get(i).this$)).getLeft());
            actual << toMX((mc::FEquation(equations.get(i).this$)).getRight());
        }
        equations = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelMisc").initialEquations();
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX((mc::FEquation(equations.get(i).this$)).getLeft());
            actual << toMX((mc::FEquation(equations.get(i).this$)).getRight());
        }
        assert( expected == actual.str() );
    }
    { // Variable laziness
        //  Real x1;
        //  Real x2;
        //equation
        //  der(x1) = x2;
        //  der(x2) = x1;
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelVariableLaziness");
        ArrayList equations = fc.equations();
        ArrayList variables =  fc.allVariables();
        MX rhsEq1 = toMX((mc::FEquation(equations.get(0).this$)).getRight());
        MX rhsEq2 = toMX((mc::FEquation(equations.get(1).this$)).getRight());
        MX var1 = toMX(mc::FVariable(variables.get(0).this$).asMXVariable());
        MX var2 = toMX(mc::FVariable(variables.get(1).this$).asMXVariable());
        assert(var1.isEqual(rhsEq2) && var2.isEqual(rhsEq1));
    }
    /* Arrays */
    { // Vectors, in and out of function. 
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelVector1");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@0 = (-@0)\n"
                    "output[0] = @0\n"
                    "@1 = input[1]\n"
                    "@1 = (-@1)\n"
                    "output[1] = @1\n"
                    "MX(vertcat(temp_1[1],temp_1[2]))"
                    "MX(vertcat(function(\"AtomicModelVector1.f\").call([A[1],A[2]]){0},function(\"AtomicModelVector1.f\").call([A[1],A[2]]){1}))"
                    "MX(der_A[1])"
                    "MX(temp_1[1])"
                    "MX(der_A[2])"
                    "MX(temp_1[2])";
        assert( actual.str() == expected );
    }
    { // Vectors, function call with vector output in function
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelVector2");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Inputs (2):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            " Outputs (2):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "@0 = input[0]\n"
                            "@1 = input[1]\n"
                            "{@2,@3} = function(\"AtomicModelVector2.f2\").call([@0,@1])\n"
                            "output[0] = @2\n"
                            "output[1] = @3\n"
                            "MX(vertcat(temp_1[1],temp_1[2]))MX(vertcat(function(\"AtomicModelVector2.f\").call([A[1],A[2]]){0},function(\"AtomicModelVector2.f\").call([A[1],A[2]]){1}))"
                            "MX(der_A[1])MX(temp_1[1])MX(der_A[2])MX(temp_1[2])";
        assert( actual.str() == expected );
    }
    { // Vectors, function call with vector output in function
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelVector3");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Inputs (4):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    " Outputs (4):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "  2. 1-by-1 (dense)\n"
                    "  3. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@0 = (-@0)\n"
                    "output[0] = @0\n"
                    "@1 = input[1]\n"
                    "@1 = (-@1)\n"
                    "output[1] = @1\n"
                    "@2 = input[2]\n"
                    "@2 = (2.*@2)\n"
                    "output[2] = @2\n"
                    "@3 = input[3]\n"
                    "@3 = (2.*@3)\n"
                    "output[3] = @3\n"
                    "MX(vertcat(A[1],A[2],B[1],B[2]))"
                    "MX(vertcat(function(\"AtomicModelVector3.f\").call([A[1],A[2],Const<1>(scalar),Const<2>(scalar)]){0},function(\"AtomicModelVector3.f\").call([A[1],A[2],Const<1>(scalar),Const<2>(scalar)]){1},function(\"AtomicModelVector3.f\").call([A[1],A[2],Const<1>(scalar),Const<2>(scalar)]){2},function(\"AtomicModelVector3.f\").call([A[1],A[2],Const<1>(scalar),Const<2>(scalar)]){3}))";
        assert( actual.str() == expected );
    }
    { // Matrix, misc
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelMatrix");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Inputs (4):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "  2. 1-by-1 (dense)\n"
                            "  3. 1-by-1 (dense)\n"
                            " Outputs (2):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "@0 = input[2]\n"
                            "output[0] = @0\n"
                            "@1 = input[3]\n"
                            "output[1] = @1\n"
                            "@2 = input[0]\n"
                            "@3 = input[1]\n"
                            "MX(vertcat(temp_1[1,1],temp_1[1,2]))"
                            "MX(vertcat(function(\"AtomicModelMatrix.f\").call([A[1,1],A[1,2],Const<0.1>(scalar),Const<0.3>(scalar)]){0},function(\"AtomicModelMatrix.f\").call([A[1,1],A[1,2],Const<0.1>(scalar),Const<0.3>(scalar)]){1}))"
                            "MX(der_A[1,1])"
                            "MX((-temp_1[1,1]))"
                            "MX(der_A[1,2])"
                            "MX((-temp_1[1,2]))"
                            "MX(vertcat(temp_2[1,1],temp_2[1,2],temp_2[2,1],temp_2[2,2]))"
                            "MX(vertcat(function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){0},function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){1},function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){2},function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){3}))"
                            "MX(der_dx[1,1])"
                            "MX((-temp_2[1,1]))"
                            "MX(der_dx[1,2])"
                            "MX((-temp_2[1,2]))"
                            "MX(der_dx[2,1])"
                            "MX((-temp_2[2,1]))"
                            "MX(der_dx[2,2])"
                            "MX((-temp_2[2,2]))";
        assert( actual.str() == expected );
    }
    { // Arrays with with ndims > 2
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelLargerThanTwoDimensionArray");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Inputs (6):\n"
                        "  0. 1-by-1 (dense)\n"
                        "  1. 1-by-1 (dense)\n"
                        "  2. 1-by-1 (dense)\n"
                        "  3. 1-by-1 (dense)\n"
                        "  4. 1-by-1 (dense)\n"
                        "  5. 1-by-1 (dense)\n"
                        " Outputs (6):\n"
                        "  0. 1-by-1 (dense)\n"
                        "  1. 1-by-1 (dense)\n"
                        "  2. 1-by-1 (dense)\n"
                        "  3. 1-by-1 (dense)\n"
                        "  4. 1-by-1 (dense)\n"
                        "  5. 1-by-1 (dense)\n"
                        "@0 = input[0]\n"
                        "@0 = (-@0)\n"
                        "output[0] = @0\n"
                        "@1 = input[1]\n"
                        "@1 = (-@1)\n"
                        "output[1] = @1\n"
                        "@2 = input[2]\n"
                        "@2 = (-@2)\n"
                        "output[2] = @2\n"
                        "@3 = input[3]\n"
                        "@3 = (-@3)\n"
                        "output[3] = @3\n"
                        "@4 = input[4]\n"
                        "@4 = (-@4)\n"
                        "output[4] = @4\n"
                        "@5 = Const<10>(scalar)\n"
                        "output[5] = @5\n"
                        "@6 = input[5]\n"
                        "MX(vertcat(temp_1[1,1,1],temp_1[1,1,2],temp_1[1,1,3],temp_1[1,2,1],temp_1[1,2,2],temp_1[1,2,3]))"
                        "MX(vertcat(function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){0},function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){1},function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){2},function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){3},function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){4},function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){5}))"
                        "MX(der_A[1,1,1])MX(temp_1[1,1,1])"
                        "MX(der_A[1,1,2])MX(temp_1[1,1,2])"
                        "MX(der_A[1,1,3])MX(temp_1[1,1,3])"
                        "MX(der_A[1,2,1])MX(temp_1[1,2,1])"
                        "MX(der_A[1,2,2])MX(temp_1[1,2,2])"
                        "MX(der_A[1,2,3])MX(temp_1[1,2,3])";
        assert( actual.str() == expected );
    }
    /* Records */
    { // Nested with single array variable in each record. 
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelRecordNestedArray");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Input: 1-by-1 (dense)\n"
                            " Outputs (8):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "  2. 1-by-1 (dense)\n"
                            "  3. 1-by-1 (dense)\n"
                            "  4. 1-by-1 (dense)\n"
                            "  5. 1-by-1 (dense)\n"
                            "  6. 1-by-1 (dense)\n"
                            "  7. 1-by-1 (dense)\n"
                            "@0 = Const<0>(scalar)\n"
                            "output[0] = @0\n"
                            "@1 = input[0]\n"
                            "output[1] = @1\n"
                            "@2 = Const<2>(scalar)\n"
                            "output[2] = @2\n"
                            "@3 = Const<3>(scalar)\n"
                            "output[3] = @3\n"
                            "@4 = Const<6>(scalar)\n"
                            "output[4] = @4\n"
                            "@5 = Const<7>(scalar)\n"
                            "output[5] = @5\n"
                            "output[6] = @2\n"
                            "output[7] = @3\n"
                            "MX(vertcat(compCurve.curves[1].path[1].point[1],compCurve.curves[1].path[1].point[2],compCurve.curves[1].path[2].point[1],compCurve.curves[1].path[2].point[2],compCurve.curves[2].path[1].point[1],compCurve.curves[2].path[1].point[2],compCurve.curves[2].path[2].point[1],compCurve.curves[2].path[2].point[2]))"
                            "MX(vertcat(function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){0},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){1},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){2},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){3},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){4},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){5},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){6},function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){7}))"
                            "MX(der_a)"
                            "MX(compCurve.curves[1].path[1].point[2])";
        assert(actual.str() == expected);
    }
    { // Record in and out inside functions. 
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelRecordInOutFunctionCallStatement");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        for (int i = 0; i < fl.getNumChild(); ++i) {
            toMXFunction(mc::FFunctionDecl(fl.getChild(i).this$)).print(actual);    
        }
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Input: 1-by-1 (dense)\n"
                            " Output: 1-by-1 (dense)\n"
                            "@0 = Const<2>(scalar)\n"
                            "@1 = input[0]\n"
                            "@0 = (@0+@1)\n"
                            "{@2,@3} = function(\"AtomicModelRecordInOutFunctionCallStatement.f2\").call([@1,@0])\n"
                            "@3 = (@2*@3)\n"
                            "output[0] = @3\n"
                            " Inputs (2):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            " Outputs (2):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "@0 = input[0]\n"
                            "output[0] = @0\n"
                            "@1 = Const<10>(scalar)\n"
                            "@2 = input[1]\n"
                            "@2 = (@1*@2)\n"
                            "output[1] = @2\n"
                            "MX(der_a)MX((-function(\"AtomicModelRecordInOutFunctionCallStatement.f1\").call([a]){0}))";
        assert(actual.str() == expected);
    }
    { // Records with array with ndims > 2
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelRecordArbitraryDimension");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        for (int i = 0; i < fl.getNumChild(); ++i) {
            toMXFunction(mc::FFunctionDecl(fl.getChild(i).this$)).print(actual);    
        }
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Input: 1-by-1 (dense)\n"
                            " Outputs (8):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "  2. 1-by-1 (dense)\n"
                            "  3. 1-by-1 (dense)\n"
                            "  4. 1-by-1 (dense)\n"
                            "  5. 1-by-1 (dense)\n"
                            "  6. 1-by-1 (dense)\n"
                            "  7. 1-by-1 (dense)\n"
                            "@0 = Const<1>(scalar)\n"
                            "output[0] = @0\n"
                            "@1 = Const<2>(scalar)\n"
                            "output[1] = @1\n"
                            "@2 = Const<3>(scalar)\n"
                            "output[2] = @2\n"
                            "@3 = Const<4>(scalar)\n"
                            "output[3] = @3\n"
                            "@4 = Const<5>(scalar)\n"
                            "output[4] = @4\n"
                            "@5 = Const<6>(scalar)\n"
                            "output[5] = @5\n"
                            "@6 = input[0]\n"
                            "output[6] = @6\n"
                            "@6 = (2.*@6)\n"
                            "output[7] = @6\n"
                            "MX(der_a)MX((-a))MX(vertcat(r.A[1,1,1],r.A[1,1,2],r.A[1,2,1],r.A[1,2,2],r.A[2,1,1],r.A[2,1,2],r.A[2,2,1],r.A[2,2,2]))MX(vertcat(function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){0},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){1},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){2},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){3},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){4},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){5},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){6},function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){7}))";
        assert(actual.str() == expected);
    }
    { // Nested records, where the records may contain several variables. 
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelRecordSeveralVars");
        std::stringstream actual;
        List fl = fc.getFFunctionDecls();
        ArrayList equations = fc.equations();
        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForLhs());
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        string expected = " Input: 1-by-1 (dense)\n"
                            " Outputs (10):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "  2. 1-by-1 (dense)\n"
                            "  3. 1-by-1 (dense)\n"
                            "  4. 1-by-1 (dense)\n"
                            "  5. 1-by-1 (dense)\n"
                            "  6. 1-by-1 (dense)\n"
                            "  7. 1-by-1 (dense)\n"
                            "  8. 1-by-1 (dense)\n"
                            "  9. 1-by-1 (dense)\n"
                            "@0 = Const<1>(scalar)\n"
                            "output[0] = @0\n"
                            "@1 = Const<2>(scalar)\n"
                            "output[1] = @1\n"
                            "@2 = Const<3>(scalar)\n"
                            "output[2] = @2\n"
                            "@3 = Const<4>(scalar)\n"
                            "output[3] = @3\n"
                            "@4 = Const<5>(scalar)\n"
                            "output[4] = @4\n"
                            "@5 = Const<6>(scalar)\n"
                            "output[5] = @5\n"
                            "@6 = Const<7>(scalar)\n"
                            "output[6] = @6\n"
                            "@7 = Const<8>(scalar)\n"
                            "output[7] = @7\n"
                            "@8 = Const<9>(scalar)\n"
                            "output[8] = @8\n"
                            "@9 = input[0]\n"
                            "output[9] = @9\n"
                            "MX(der_a)MX((-a))MX(vertcat(r.r1.A,r.r1.B,r.rArr[1].A,r.rArr[1].B,r.rArr[2].A,r.rArr[2].B,r.matrix[1,1],r.matrix[1,2],r.matrix[2,1],r.matrix[2,2]))MX(vertcat(function(\"AtomicModelRecordSeveralVars.f\").call([a]){0},function(\"AtomicModelRecordSeveralVars.f\").call([a]){1},function(\"AtomicModelRecordSeveralVars.f\").call([a]){2},function(\"AtomicModelRecordSeveralVars.f\").call([a]){3},function(\"AtomicModelRecordSeveralVars.f\").call([a]){4},function(\"AtomicModelRecordSeveralVars.f\").call([a]){5},function(\"AtomicModelRecordSeveralVars.f\").call([a]){6},function(\"AtomicModelRecordSeveralVars.f\").call([a]){7},function(\"AtomicModelRecordSeveralVars.f\").call([a]){8},function(\"AtomicModelRecordSeveralVars.f\").call([a]){9}))";
        assert(actual.str() == expected);
    }
    
    
    /* Functions */
    /* Real valued functions */
    {  // Check that different kinds of function are able to be transferred and called in equations, 
        //der(x1) = sin(monoInMonoOut(x1));
        //der(x2) = polyInMonoOut(x1,x2);
        //(x3,x4) = monoInPolyOut(x2);
        //(x5,x6) = polyInPolyOut(x1,x2);
        //der(x7) = monoInMonoOutReturn(x7);
        //der(x8) = functionCallInFunction(x8);
        //der(x9) = functionCallEquationInFunction(x9);
        //der(x10) = monoInMonoOutInternal(x10);
        //(x11,x12) = polyInPolyOutInternal(x9,x10);
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelAtomicRealFunctions");
        ArrayList equations = fc.equations();
        string expected = "MX(sin(function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([x1]){0}))"
        "MX(function(\"AtomicModelAtomicRealFunctions.polyInMonoOut\").call([x1,x2]){0})"
        "MX(vertcat(function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){0},function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){1}))"
        "MX(vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1,x2]){0},function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1,x2]){1}))"
        "MX(function(\"AtomicModelAtomicRealFunctions.monoInMonoOutReturn\").call([x7]){0})"
        "MX(function(\"AtomicModelAtomicRealFunctions.functionCallInFunction\").call([x8]){0})"
        "MX(function(\"AtomicModelAtomicRealFunctions.functionCallEquationInFunction\").call([x9]){0})"
        "MX(function(\"AtomicModelAtomicRealFunctions.monoInMonoOutInternal\").call([x10]){0})"
        "MX(vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9,x10]){0},function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9,x10]){1}))";
        
        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        assert( expected == actual.str() );
    }
    { // Check that the MXFunctions give correct prints
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelAtomicRealFunctions");
        List fl = fc.getFFunctionDecls();
        std::stringstream actual;
        string expected;
        
        //function monoInMonoOut
            //input Real x;
            //output Real y;
        //algorithm
            //y := x;
        //end monoInMonoOut;
        expected =  " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str(""); 
        
        //function polyInMonoOut
            //input Real x1;
            //input Real x2;
            //output Real y;
        //algorithm
            //y := x1+x2;
        //end polyInMonoOut;
        //end monoInMonoOut;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n"
                    "@1 = (@0+@1)\n"
                    "output[0] = @1\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(1).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInPolyOut
            //input Real x;
            //output Real y1;
            //output Real y2;
        //algorithm
            //y1 := if(x > 2) then 1 else 5;
            //y2 := x;
        //end monoInPolyOut;
        expected = " Input: 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = Const<2>(scalar)\n"
                    "@1 = input[0]\n"
                    "@2 = (@0<@1)\n"
                    "@3 = Const<1>(scalar)\n"
                    "@3 = (@2?@3:0)\n"
                    "@2 = (!@2)\n"
                    "@4 = Const<5>(scalar)\n"
                    "@4 = (@2?@4:0)\n"
                    "@4 = (@3+@4)\n"
                    "output[0] = @4\n"
                    "output[1] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(2).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function polyInPolyOut
            //input Real x1;
            //input Real x2;
            //output Real y1;
            //output Real y2;
        //algorithm
            //y1 := x1;
            //y2 := x2;
        //end polyInPolyOut;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@1 = input[1]\n"
                    "output[1] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(3).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInMonoOutReturn
            //input Real x;
            //output Real y;
        //algorithm
            //y := x;
            //return;
            //y := 2*x;
        //end monoInMonoOutReturn;
        expected =  " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(4).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function functionCallInFunction
            //input Real x;
            //output Real y;
        //algorithm
            //y := monoInMonoOut(x);
        //end functionCallInFunction;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([@0])\n"
                    "output[0] = @1\n";


        toMXFunction(mc::FFunctionDecl(fl.getChild(5).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function functionCallEquationInFunction
            //input Real x;
            //Real internal;
            //output Real y;
        //algorithm
            //(y,internal) := monoInPolyOut(x);
        //end functionCallEquationInFunction;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "{@1,NULL} = function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([@0])\n"
                    "output[0] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(6).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInMonoOutInternal
            //input Real x;
            //Real internal;
            //output Real y;
        //algorithm
            //internal := sin(x);
            //y := x*internal;
            //internal := sin(y);
            //y := x + internal;
        //end monoInMonoOutInternal;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = sin(@0)\n"
                    "@1 = (@0*@1)\n"
                    "@1 = sin(@1)\n"
                    "@0 = (@0+@1)\n"
                    "output[0] = @0\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(7).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function polyInPolyOutInternal
            //input Real x1;
            //input Real x2;
            //Real internal1;
            //Real internal2;
            //output Real y1;
            //output Real y2;
        //algorithm
            //internal1 := x1;
            //internal2 := x2 + internal1;
            //y1 := internal1;
            //y2 := internal2 + x1;
            //y2 := 1;
        //end polyInPolyOutInternal;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@1 = Const<1>(scalar)\n"
                    "output[1] = @1\n"
                    "@2 = input[1]\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(8).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
    }
    /* Integer valued functions */
    {  // Check that different kinds of function are able to be transferred and called in equations, 
        //x1 = monoInMonoOut(x1);
        //x2 = polyInMonoOut(x1,x2);
        //(x3,x4) = monoInPolyOut(x2);
        //(x5,x6) = polyInPolyOut(x1,x2);
        //x7 = monoInMonoOutReturn(x7);
        //x8 = functionCallInFunction(x8);
        //x9 = functionCallEquationInFunction(x9);
        //x10 = monoInMonoOutInternal(x10);
        //(x11,x12) = polyInPolyOutInternal(x9,x10);
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelAtomicIntegerFunctions");
        ArrayList equations = fc.equations();
        string expected = "MX(function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([x1]){0})"
        "MX(function(\"AtomicModelAtomicIntegerFunctions.polyInMonoOut\").call([x1,x2]){0})"
        "MX(vertcat(function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([x2]){0},function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([x2]){1}))"
        "MX(vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([x1,x2]){0},function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([x1,x2]){1}))"
        "MX(function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn\").call([x7]){0})"
        "MX(function(\"AtomicModelAtomicIntegerFunctions.functionCallInFunction\").call([x8]){0})"
        "MX(function(\"AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction\").call([x9]){0})"
        "MX(function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal\").call([x10]){0})"
        "MX(vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([x9,x10]){0},function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([x9,x10]){1}))";

        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        assert( expected == actual.str() );
    }
    
    
    {
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelAtomicIntegerFunctions");
        List fl = fc.getFFunctionDecls();
        std::stringstream actual;
        string expected;

        //function monoInMonoOut
            //input Integer x;
            //output Integer y;
        //algorithm
            //y := x;
        //end monoInMonoOut;
        expected =  " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str(""); 
        
        //function polyInMonoOut
            //input Integer x1;
            //input Integer x2;
            //output Integer y;
        //algorithm
            //y := x1+x2;
        //end polyInMonoOut;
        //end monoInMonoOut;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = input[1]\n"
                    "@1 = (@0+@1)\n"
                    "output[0] = @1\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(1).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInPolyOut
            //input Integer x;
            //output Integer y1;
            //output Integer y2;
        //algorithm
            //y1 := if(x > 2) then 1 else 5;
            //y2 := x;
        //end monoInPolyOut;
        expected = " Input: 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = Const<2>(scalar)\n"
                    "@1 = input[0]\n"
                    "@2 = (@0<@1)\n"
                    "@3 = Const<1>(scalar)\n"
                    "@3 = (@2?@3:0)\n"
                    "@2 = (!@2)\n"
                    "@4 = Const<5>(scalar)\n"
                    "@4 = (@2?@4:0)\n"
                    "@4 = (@3+@4)\n"
                    "output[0] = @4\n"
                    "output[1] = @1\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(2).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function polyInPolyOut
            //input Integer x1;
            //input Integer x2;
            //output Integer y1;
            //output Integer y2;
        //algorithm
            //y1 := x1;
            //y2 := x2;
        //end polyInPolyOut;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@1 = input[1]\n"
                    "output[1] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(3).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInMonoOutReturn
            //input Integer x;
            //output Integer y;
        //algorithm
            //y := x;
            //return;
            //y := 2*x;
        //end monoInMonoOutReturn;
        expected =  " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(4).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function functionCallInFunction
            //input Integer x;
            //output Integer y;
        //algorithm
            //y := monoInMonoOut(x);
        //end functionCallInFunction;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([@0])\n"
                    "output[0] = @1\n";


        toMXFunction(mc::FFunctionDecl(fl.getChild(5).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function functionCallEquationInFunction
            //input Integer x;
            //Integer internal;
            //output Integer y;
        //algorithm
            //(y,internal) := monoInPolyOut(x);
        //end functionCallEquationInFunction;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "{@1,NULL} = function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([@0])\n"
                    "output[0] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(6).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInMonoOutInternal
            //input Integer x;
            //Integer internal;
            //output Integer y;
        //algorithm
            //internal := 3*x;
            //y := x*internal;
            //internal := 1+y;
            //y := x + internal;
        //end monoInMonoOutInternal;
        expected = 
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = Const<3>(scalar)\n"
                "@1 = input[0]\n"
                "@2 = (@0*@1)\n"
                "@2 = (@1*@2)\n"
                "@3 = Const<1>(scalar)\n"
                "@2 = (@3+@2)\n"
                "@1 = (@1+@2)\n"
                "output[0] = @1\n";


        toMXFunction(mc::FFunctionDecl(fl.getChild(7).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function polyInPolyOutInternal
            //input Integer x1;
            //input Integer x2;
            //Integer internal1;
            //Integer internal2;
            //output Integer y1;
            //output Integer y2;
        //algorithm
            //internal1 := x1;
            //internal2 := x2 + internal1;
            //y1 := internal1;
            //y2 := internal2 + x1;
            //y2 := 1;
        //end polyInPolyOutInternal;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@1 = Const<1>(scalar)\n"
                    "output[1] = @1\n"
                    "@2 = input[1]\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(8).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
    }
    /* Boolean valued functions */
    {  // Check that different kinds of function are able to be transferred and called in equations, 
        //x1 = monoInMonoOut(x1);
        //x2 = polyInMonoOut(x1,x2);
        //(x3,x4) = monoInPolyOut(x2);
        //(x5,x6) = polyInPolyOut(x1,x2);
        //x7 = monoInMonoOutReturn(x7);
        //x8 = functionCallInFunction(x8);
        //x9 = functionCallEquationInFunction(x9);
        //x10 = monoInMonoOutInternal(x10);
        //(x11,x12) = polyInPolyOutInternal(x9,x10);
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelAtomicBooleanFunctions");
        ArrayList equations = fc.equations();
        string expected = "MX(function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([x1]){0})"
        "MX(function(\"AtomicModelAtomicBooleanFunctions.polyInMonoOut\").call([x1,x2]){0})"
        "MX(vertcat(function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([x2]){0},function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([x2]){1}))"
        "MX(vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([x1,x2]){0},function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([x1,x2]){1}))"
        "MX(function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn\").call([x7]){0})"
        "MX(function(\"AtomicModelAtomicBooleanFunctions.functionCallInFunction\").call([x8]){0})"
        "MX(function(\"AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction\").call([x9]){0})"
        "MX(function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal\").call([x10]){0})"
        "MX(vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([x9,x10]){0},function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([x9,x10]){1}))";
        
        std::stringstream actual;
        for (int i = 0; i < equations.size(); ++i) {
            actual << toMX(mc::FAbstractEquation(equations.get(i).this$).toMXForRhs());
        }
        assert( expected == actual.str() );
    }
    
    {
        mc::FClass fc = compileModelicaModelFromAtomicModelicaModelsToFclass("AtomicModelAtomicBooleanFunctions");
        List fl = fc.getFFunctionDecls();
        std::stringstream actual;
        string expected;
        
        //function monoInMonoOut
            //input Boolean x;
            //output Boolean y;
        //algorithm
            //y := x;
        //end monoInMonoOut;
        expected =  " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(0).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str(""); 
        
        //function polyInMonoOut
            //input Boolean x1;
            //input Boolean x2;
            //output Boolean y;
        //algorithm
            //y := x1 and x2;
        //end polyInMonoOut;
        expected = " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = input[1]\n"
                "@1 = (@0&&@1)\n"
                "output[0] = @1\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(1).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInPolyOut
            //input Boolean x;
            //output Boolean y1;
            //output Boolean y2;
        //algorithm
            //y1 := if(x) then false else (x or false);
            //y2 := x;
        //end monoInPolyOut;
        expected = " Input: 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = Const<0>(scalar)\n"
                    "@1 = input[0]\n"
                    "@0 = (@0||@1)\n"
                    "@2 = (!@1)\n"
                    "@0 = (@2?@0:0)\n"
                    "output[0] = @0\n"
                    "output[1] = @1\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(2).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function polyInPolyOut
            //input Boolean x1;
            //input Boolean x2;
            //output Boolean y1;
            //output Boolean y2;
        //algorithm
            //y1 := x1;
            //y2 := x2;
        //end polyInPolyOut;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@1 = input[1]\n"
                    "output[1] = @1\n";


        toMXFunction(mc::FFunctionDecl(fl.getChild(3).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function monoInMonoOutReturn
            //input Boolean x;
            //output Boolean y;
        //algorithm
            //y := x;
            //return;
            //y := x or false;
        //end monoInMonoOutReturn;
        expected =  " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(4).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function functionCallInFunction
            //input Boolean x;
            //output Boolean y;
        //algorithm
            //y := monoInMonoOut(x);
        //end functionCallInFunction;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "@1 = function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([@0])\n"
                    "output[0] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(5).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function functionCallEquationInFunction
            //input Boolean x;
            //Boolean internal;
            //output Boolean y;
        //algorithm
            //(y,internal) := monoInPolyOut(x);
        //end functionCallEquationInFunction;
        expected = " Input: 1-by-1 (dense)\n"
                    " Output: 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "{@1,NULL} = function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([@0])\n"
                    "output[0] = @1\n";

        toMXFunction(mc::FFunctionDecl(fl.getChild(6).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        
        //function monoInMonoOutInternal
            //input Boolean x;
            //Boolean internal;
            //output Boolean y;
        //algorithm
            //internal := x;
            //y := x and internal;
            //internal := false or y;
            //y := false or internal;
        //end monoInMonoOutInternal;
        expected = 
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@0 = (@0&&@0)\n"
                "@1 = Const<0>(scalar)\n"
                "@0 = (@1||@0)\n"
                "@2 = Const<0>(scalar)\n"
                "@0 = (@2||@0)\n"
                "output[0] = @0\n";
        toMXFunction(mc::FFunctionDecl(fl.getChild(7).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
        
        //function polyInPolyOutInternal
            //input Boolean x1;
            //input Boolean x2;
            //Boolean internal1;
            //Boolean internal2;
            //output Boolean y1;
            //output Boolean y2;
        //algorithm
            //internal1 := x1;
            //internal2 := x2  or internal1;
            //y1 := internal1;
            //y2 := internal2 or x1;
            //y2 := true;
        //end polyInPolyOutInternal;
        expected = " Inputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    " Outputs (2):\n"
                    "  0. 1-by-1 (dense)\n"
                    "  1. 1-by-1 (dense)\n"
                    "@0 = input[0]\n"
                    "output[0] = @0\n"
                    "@1 = Const<1>(scalar)\n"
                    "output[1] = @1\n"
                    "@2 = input[1]\n";


        toMXFunction(mc::FFunctionDecl(fl.getChild(8).this$)).print(actual);
        assert( actual.str() == expected );
        actual.str("");
    }

    cout << "... All tests passed!" << endl;
    tearDownJVM();
    return 0;
}
