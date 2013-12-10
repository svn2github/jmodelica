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

#include <iostream>
#include <cassert>

// The ModelicaCasADiModel
#include "Model.hpp"
#include "Variable.hpp"
#include "OptimizationProblem.hpp"
#include "Ref.hpp"

// Transfer method
#include "transferOptimica.hpp"
#include "sharedTransferFunctionality.hpp"

// Paths needed to run the test
#include "modelicacasadi_paths.h"

#include "org/jmodelica/util/OptionRegistry.h"

#include "jni.h"    
#include "jccutils.h"

using std::cout; using std::endl;
using std::vector; using std::string;

using namespace CasADi;
using namespace ModelicaCasADi;

bool checkMXPrintEqual(MX expectedMX, MX actualMX) {
    std::stringstream expected, actual;
    expected << expectedMX;
    actual << actualMX;
    return expected.str() == actual.str();
}

template <class T> 
string computeString(vector<T> &makeStringOf)
{
    std::stringstream result;
    typename vector<T>::iterator it;
    for ( it = makeStringOf.begin(); it < makeStringOf.end(); ++it) {
         result << *(it->getNode());
    }
    return result.str();
}
void assertNear(double val1, double val2, double error) {
    assert( std::abs(val1 - val2) < std::abs(error) );
}

int main(int argc, char *argv[])
{
    cout << " ======================="
            " Running Optimica transfer tests =======================" << endl;
    std::string modelFile = (MODELICACASADI_MODELPATH "/atomicOptimizationProblems.mop");
    Ref<OptimizationProblem> optProblem;
    Ref<Model> model;
    
    // Common variables in the atomic tests
    MX x1("x1");
    MX x2("x2");
    MX der_x1("der_x1");
    MX der_x2("der_x2");
    
    
    setUpJVM();

   
    { // Less than constraint
        //a <=  1.00
        optProblem =  transferOptimizationProblem("atomicOptimizationLEQ", modelFile);
        std::stringstream expected;
        expected << x1 << " <= " << MX(1.0);
        vector< Ref<Constraint> > constraints = optProblem->getPathConstraints();
        assert( computeString(constraints) == expected.str());
    }
    
    { // Greater than constraint
        //a >=  1.00
        optProblem =  transferOptimizationProblem("atomicOptimizationGEQ", modelFile);
        std::stringstream expected;
        expected << x1 << " >= " << MX(1.0);
        vector< Ref<Constraint> > constraints = optProblem->getPathConstraints();
        assert( computeString(constraints) == expected.str());
    }
    
    { // Start time
        optProblem =  transferOptimizationProblem("atomicOptimizationStart5", modelFile);
        assert( optProblem->getStartTime().getValue() == 5);
    }
    
    { // Final time
        optProblem =  transferOptimizationProblem("atomicOptimizationFinal10", modelFile);
        assert( optProblem->getFinalTime().getValue() == 10);
    }
    
    { // Lagrange term
        optProblem =  transferOptimizationProblem("atomicLagrangeX1", modelFile);
        assert(checkMXPrintEqual(optProblem->getLagrangeTerm(), x1));
        optProblem =  transferOptimizationProblem("atomicLagrangeNull", modelFile);
        assert(checkMXPrintEqual(optProblem->getLagrangeTerm(), MX(0)));
    }
    
    { // Mayer term
        optProblem =  transferOptimizationProblem("atomicMayerFinalTime", modelFile);
        assert( checkMXPrintEqual(optProblem->getMayerTerm(), MX("finalTime")) );
        optProblem =  transferOptimizationProblem("atomicMayerNull", modelFile);
        assert( checkMXPrintEqual(optProblem->getMayerTerm(), MX(0)) );
        //optProblem =  transferOptimizationProblem("atomicMayerX1AtFinalTime", modelFile);
        //assert(...); // TODO: Needs point constraint framework
    }
    
    { // User defined types
        optProblem =  transferOptimizationProblem("atomicWithVoltageType", modelFile);
        vector< Ref<Variable> > diffs =  optProblem->getModel()->getVariableByKind(Model::DIFFERENTIATED);
        assert( diffs[0]->getDeclaredType().getNode() != NULL );
        assert( diffs[0]->getDeclaredType() == optProblem->getModel()->getVariableTypeByName("Voltage"));
    }
    
    { // Optimization variable free attribute
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("atomicWithFree", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("free"));
        expected << MX(false);
        assert( actual.str() == expected.str() );
    }
    { // Optimization variable initial guess attribute
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("atomicWithInitialGuess", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("initialGuess"));
        expected << MX(5);
        assert( actual.str() == expected.str() );
    }
    
    
    /* The following tests uses prexisting modelicaTransferTests to tests transferOptimica's model 
     * transfer functionality
     * */
    modelFile = MODELICACASADI_MODELPATH "/atomicModelicaModels.mo";
    
    /* Equations */
    { // Simple equation
        //der(x1) = x1;
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelSimpleEquation", modelFile)->getModel();
        actual <<  model->getDaeResidual();
        expected << (x1 - der_x1);
        assert( actual.str() == expected.str() );
    }
    { // Simple initial equation
        //Real x1(start = 1);
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelSimpleInitialEquation", modelFile)->getModel();
        actual <<  model->getInitialResidual();
        expected << (MX(1) - x1);
        assert( actual.str() == expected.str() );
    }
    { // Function call equations
        //der(x1) = x1;
        //(x2,x3) = f(x1);
        std::stringstream actual, expected;
        org::jmodelica::util::OptionRegistry optr;    
        optr.addStringOption(StringFromUTF("inline_functions"), StringFromUTF("none"));
        model =  transferOptimizationProblem("AtomicModelFunctionCallEquation", modelFile, optr)->getModel();
        actual <<  model->getDaeResidual();
        assert( actual.str() == "MX(vertcat((x1-der_x1),(vertcat(function(\"AtomicModelFunctionCallEquation.f\").call([x1]){0},"
                                 "function(\"AtomicModelFunctionCallEquation.f\").call([x1]){1})-vertcat(x2,x3))))" );
    }
    
    
    { // bindingExpression
        //parameter Real  p1 = 2;
        //parameter Real  p2 = p1;
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeBindingExpression", modelFile)->getModel();
        vector< Ref<Variable> > dependent =  model->getVariableByKind(Model::REAL_PARAMETER_DEPENDENT);
        vector< Ref<Variable> > independent =  model->getVariableByKind(Model::REAL_PARAMETER_INDEPENDENT);
        actual << *(independent[0]->getAttribute("bindingExpression")) << *(dependent[0]->getAttribute("bindingExpression"));
        expected << MX(2) << MX("p1");
        assert( actual.str() == expected.str() );
    }
    
    { // stateSelect
        // TODO
    }
    
    { // unit
        //Real x1(start=0.0005, unit = "kg");
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeUnit", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("unit"));
        expected << MX("kg");
        assert( actual.str() == expected.str() );
    }
    
    { // quantity
        //Real x1(start=0.0005, quantity = "kg");
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeQuantity", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        expected << MX("kg");
        actual << *(diffs[0]->getAttribute("quantity"));
        assert( actual.str() == expected.str() );
    }
    
    { // displayUnit
        //Real x1(start=0.0005, displayUnit = "kg");
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeDisplayUnit", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("displayUnit"));
        expected << MX("kg");
        assert( actual.str() == expected.str() );
    }
    
    { // min
        // Real x1(start=0.0005, min = 0.0);
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeMin", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("min"));
        expected << MX(0);
        assert( actual.str() == expected.str() );
    }
    
    { // max
        // Real x1(start=0.0005, max = 100.0);
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeMax", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("max"));
        expected << MX(100);
        assert( actual.str() == expected.str() );
    }
    
    { // start
        // Real x1(start=0.0005);
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeStart", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("start"));
        expected << MX(0.0005);
        assert( actual.str() == expected.str() );
    }
    
    
    { // fixed
        // Real x1(start=0.0005, fixed = true);
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeFixed", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("fixed"));
        expected << MX(true);
        assert( actual.str() == expected.str() );
    }
    
    { // nominal
        //  Real x1(start=0.0005, nominal = 0.1);
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelAttributeNominal", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("nominal"));
        expected << MX(0.1);
        assert( actual.str() == expected.str() );
    }
    { // comment
        // Real x1(start = 3) "I am x1's comment";;
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelComment", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        actual << *(diffs[0]->getAttribute("comment"));
        expected << MX("I am x1's comment");
        assert( actual.str() == expected.str() );
    }
    
   
    { // Variable types, check that user type is transferred correctly
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelDerivedRealTypeVoltage", modelFile)->getModel();
        actual << (model->getVariableTypeByName("Voltage"));
        expected << "Type name: Voltage, base type: Real, attributes:"
                    "\n\tquantity = MX(ElectricalPotential)\n\tunit = MX(V)";
        assert( actual.str() == expected.str() );
    }
    { // Variable types, check that Variables get the correct type
        std::stringstream actual, expected;
        model =  transferOptimizationProblem("AtomicModelDerivedTypeAndDefaultType", modelFile)->getModel();
        vector< Ref<Variable> > diffs =  model->getVariableByKind(Model::DIFFERENTIATED);
        assert( diffs[0]->getDeclaredType() == model->getVariableTypeByName("Voltage"));
        assert( diffs[1]->getDeclaredType() == model->getVariableTypeByName("Real"));
    }
    
    
    /* Variable kinds */
    // Real variable kinds //
    { // Real constants
        //constant Real pi = 3.14;
        model =  transferOptimizationProblem("atomicModelRealConstant", modelFile)->getModel();
        vector< Ref<Variable> > constVars =  model->getVariableByKind(Model::REAL_CONSTANT);
        assertNear(constVars[0]->getAttribute("bindingExpression")->getValue(), 3.14, 0.0000001);
    }
    { // Real independent parameter
        //parameter Real pi = 3.14;
        model =  transferOptimizationProblem("atomicModelRealIndependentParameter", modelFile)->getModel();
        vector< Ref<Variable> > indepParam =  model->getVariableByKind(Model::REAL_PARAMETER_INDEPENDENT);
        assertNear(indepParam[0]->getAttribute("bindingExpression")->getValue(), 3.14, 0.0000001);
    }
    { // Real independent parameter
        //parameter Real pi = 3.14;
        //parameter Real pi2 = 2*pi;
        model =  transferOptimizationProblem("atomicModelRealDependentParameter", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > depParam =  model->getVariableByKind(Model::REAL_PARAMETER_DEPENDENT);
        vector< Ref<Variable> > indepParam =  model->getVariableByKind(Model::REAL_PARAMETER_INDEPENDENT);
        expected << (2*(indepParam[0]->getVar()));
        actual << (*depParam[0]->getAttribute("bindingExpression"));
        assert( expected.str() == actual.str() );
    }
    { // Real derivative
        //der(x1) = -x1;
        model =  transferOptimizationProblem("atomicModelRealDerivative", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > der =  model->getVariableByKind(Model::DERIVATIVE);
        expected << (der_x1 );
        actual << (der[0]->getVar());
        assert( expected.str() == actual.str() );
    }
    { // Real differentiated
        //der(x1) = -x1;
        model =  transferOptimizationProblem("atomicModelRealDifferentiated", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > diff =  model->getVariableByKind(Model::DIFFERENTIATED);
        expected << (x1 );
        actual << (diff[0]->getVar());
        assert( expected.str() == actual.str() );
    }
    { // Real input
        //Real input x1;
        model =  transferOptimizationProblem("atomicModelRealInput", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > ins =  model->getVariableByKind(Model::REAL_INPUT);
        expected << (x1 );
        actual << (ins[0]->getVar());
        assert( expected.str() == actual.str() );
    }
    { // Real algebraic
        //x1 = sin(x1);
        model =  transferOptimizationProblem("atomicModelRealAlgebraic", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > alg =  model->getVariableByKind(Model::REAL_ALGEBRAIC);
        expected << (x1 );
        actual << (alg[0]->getVar());
        assert( expected.str() == actual.str() );
    }
    { // Real discrete
        //discrete Real  x1 (start = 1);
        model =  transferOptimizationProblem("atomicModelRealDiscrete", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > realDisc =  model->getVariableByKind(Model::REAL_DISCRETE);
        expected << (x1 );
        actual << (realDisc[0]->getVar());
        assert( expected.str() == actual.str() );
    }
    
    // Integer variable kinds //
    { // Integer constants
        //constant Integer pi = 3;
        model =  transferOptimizationProblem("atomicModelIntegerConstant", modelFile)->getModel();
        vector< Ref<Variable> > constVars =  model->getVariableByKind(Model::INTEGER_CONSTANT);
        assertNear( constVars[0]->getAttribute("bindingExpression")->getValue(), 3, 0.0000001);
    }
    { // Integer independent parameter
        //parameter Integer pi = 3;
        model =  transferOptimizationProblem("atomicModelIntegerIndependentParameter", modelFile)->getModel();
        vector< Ref<Variable> > indepParam =  model->getVariableByKind(Model::INTEGER_PARAMETER_INDEPENDENT);
        assertNear( indepParam[0]->getAttribute("bindingExpression")->getValue(), 3, 0.0000001 );
    }
    { // Integer independent parameter
        //parameter Integer pi = 3;
        //parameter Integer pi2 = 2*pi;
        model =  transferOptimizationProblem("atomicModelIntegerDependentParameter", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > depParam =  model->getVariableByKind(Model::INTEGER_PARAMETER_DEPENDENT);
        vector< Ref<Variable> > indepParam =  model->getVariableByKind(Model::INTEGER_PARAMETER_INDEPENDENT);
        expected << (2*(indepParam[0]->getVar()));
        actual << (*depParam[0]->getAttribute("bindingExpression"));
        assert( expected.str() == actual.str() );
    }
    { // Integer discrete
        //Integer x1;
        model =  transferOptimizationProblem("atomicModelIntegerDiscrete", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > intDisc =  model->getVariableByKind(Model::INTEGER_DISCRETE);
        expected << x1;
        actual << intDisc[0]->getVar();
        assert( expected.str() == actual.str() );
    }
    { // Integer input
        //input Integer x1;
        model =  transferOptimizationProblem("atomicModelIntegerInput", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > intIns =  model->getVariableByKind(Model::INTEGER_INPUT);
        expected << x1;
        actual << intIns[0]->getVar();
        assert( expected.str() == actual.str() );
    }
    
    // Boolean variable kinds //
    { // Boolean constants
        //constant Boolean pi = true;
        model =  transferOptimizationProblem("atomicModelBooleanConstant", modelFile)->getModel();
        vector< Ref<Variable> > constVars =  model->getVariableByKind(Model::BOOLEAN_CONSTANT);
        assertNear( constVars[0]->getAttribute("bindingExpression")->getValue(), MX(true).getValue(), 0.0000001 );
    }
    { // Boolean independent parameter
        //parameter Boolean pi = true;
        model =  transferOptimizationProblem("atomicModelBooleanIndependentParameter", modelFile)->getModel();
        vector< Ref<Variable> > indepParam =  model->getVariableByKind(Model::BOOLEAN_PARAMETER_INDEPENDENT);
        assertNear( indepParam[0]->getAttribute("bindingExpression")->getValue(), MX(true).getValue(), 0.0000001 );
    }
    { // Boolean independent parameter
        //parameter Boolean pi = true;
        //parameter Boolean pi2 = pi and true;
        model =  transferOptimizationProblem("atomicModelBooleanDependentParameter", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > depParam =  model->getVariableByKind(Model::BOOLEAN_PARAMETER_DEPENDENT);
        vector< Ref<Variable> > indepParam =  model->getVariableByKind(Model::BOOLEAN_PARAMETER_INDEPENDENT);
        expected << ((indepParam[0]->getVar()) && MX(true));
        actual << (*depParam[0]->getAttribute("bindingExpression"));
        assert( expected.str() == actual.str() );
    }
    { // Boolean discrete
        //Booleanv x1;
        model =  transferOptimizationProblem("atomicModelBooleanDiscrete", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > boolDisc =  model->getVariableByKind(Model::BOOLEAN_DISCRETE);
        expected << x1;
        actual << boolDisc[0]->getVar();
        assert( expected.str() == actual.str() );
    }
    { // Boolean input
        //input Boolean x1;
        model =  transferOptimizationProblem("atomicModelBooleanInput", modelFile)->getModel();
        std::stringstream expected, actual;
        vector< Ref<Variable> > boolIns =  model->getVariableByKind(Model::BOOLEAN_INPUT);
        expected << x1;
        actual << boolIns[0]->getVar();
        assert( expected.str() == actual.str() );
    }
    /* Functions */ 
    {
        model =  transferOptimizationProblem( "simpleModelWithFunctions", MODELICACASADI_MODELPATH "/modelicaModels.mo")->getModel();
        string expectedPrint = "ModelFunction : function(\"simpleModelWithFunctions.f\")\n Inputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                " Outputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                "@0 = input[0]\n"
                                "@1 = input[1]\n"
                                "{@2,@3} = function(\"simpleModelWithFunctions.f2\").call([@0,@1])\n"
                                "output[0] = @2\n"
                                "output[1] = @3\n"
                                "ModelFunction : function(\"simpleModelWithFunctions.f2\")\n Inputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                " Outputs (2):\n"
                                "  0. 1-by-1 (dense)\n"
                                "  1. 1-by-1 (dense)\n"
                                "@0 = Const<0.5>(scalar)\n"
                                "@1 = input[0]\n"
                                "@0 = (@0*@1)\n"
                                "output[0] = @0\n"
                                "@2 = input[1]\n"
                                "@0 = (@2+@0)\n"
                                "output[1] = @0\n";              
        std::stringstream actual;
        Ref<ModelFunction> mf_1 = model->getModelFunctionByName("simpleModelWithFunctions.f");
        Ref<ModelFunction> mf_2 = model->getModelFunctionByName("simpleModelWithFunctions.f2");
        actual << mf_1 << mf_2;
        assert( expectedPrint == actual.str() );
    }
    /* Dependent parameters */
    {
        org::jmodelica::util::OptionRegistry optr;    
        optr.addStringOption(StringFromUTF("inline_functions"), StringFromUTF("none"));
        model =  transferOptimizationProblem("atomicModelDependentParameter", modelFile,  optr)->getModel();
        model->calculateValuesForDependentParameters();
        vector< Ref<Variable> > depVars = model->getVariableByKind(Model::REAL_PARAMETER_DEPENDENT);
        assert((*depVars[0]->getAttribute("evaluatedBindingExpression")).getValue() == 20);
        assert((*depVars[1]->getAttribute("evaluatedBindingExpression")).getValue() == 20);
        assert((*depVars[2]->getAttribute("evaluatedBindingExpression")).getValue() == 200);
    }
    
    
    cout << "... All tests passed!" << endl;
    tearDownJVM();
    return 0;
}
