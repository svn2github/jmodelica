#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
from tests_jmodelica import testattr, get_files_path
from modelicacasadi_transfer import *
modelFile = os.path.join(get_files_path(), 'XML')#'TestModelicaModels.mo')
optproblemsFile = os.path.join(get_files_path(), 'Modelica', 'TestOptimizationProblems.mop')

## In this file there are tests for transferModelica, transferOptimica and tests for
## the correct transfer of the MX representation of expressions and various Modelica constructs
## from JModelica.org.

def load_model(*args, **kwargs):
    model = Model()
    arglist = []
    for arg in args:
        arglist.append(arg)
    modelname = os.path.join(modelFile, arglist[0])
    modelname += '.xml'
    modelname = modelname.replace("/", "\\")
    print modelname
    transfer_model(model, arglist[0], modelname, **kwargs)
    return model

def load_optimization_problem(*args, **kwargs):
    ocp = OptimizationProblem()
    transfer_optimization_problem(ocp, *args, **kwargs)
    return ocp

# Common variables used in the tests
x1 = MX("x1")
x2 = MX("x2")
x3 = MX("x3")
der_x1 = MX("der(x1)")

def assertNear(val1, val2, tol):
    assert abs(val1 - val2) < tol
    
##############################################
#                                            # 
#          MODELICA TRANSFER TESTS           #
#                                            #
##############################################

@testattr(xml = True)    
def test_ModelicaSimpleEquation():
    assert str(load_model("AtomicModelSimpleEquation", modelFile).getDaeResidual()) == str(der_x1 - x1)
    
@testattr(xml = True)    
def test_ModelicaSimpleInitialEquation():
    assert str(load_model("AtomicModelSimpleInitialEquation", modelFile).getInitialResidual())  == str(x1 - MX(1))
    
@testattr(xml = True)    
def test_ModelicaFunctionCallEquations():
    assert( repr(load_model("AtomicModelFunctionCallEquation", modelFile, compiler_options={"inline_functions":"none"}).getDaeResidual()) == 
                ("MX(vertcat((der(x1)-x1),(vertcat(x2,x3)-vertcat(function(\"AtomicModelFunctionCallEquation.f\")" + 
                ".call([x1]){0},function(\"AtomicModelFunctionCallEquation.f\").call([x1]){1}))))"))
                
@testattr(xml = True)    
def test_ModelicaBindingExpression():
    model =  load_model("AtomicModelAttributeBindingExpression", modelFile)
    dependent =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
    independent =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
    actual =  str(independent[0].getAttribute("bindingExpression")) + str(dependent[0].getAttribute("bindingExpression"))
    expected = str(MX(2)) + str(MX("p1"))
    assert actual == expected
    
@testattr(xml = True)    
def test_ModelicaUnit():
    model =  load_model("AtomicModelAttributeUnit", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("unit")) == str(MX("kg")) 
    
@testattr(xml = True)    
def test_ModelicaQuantity():
    model =  load_model("AtomicModelAttributeQuantity", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("quantity")) == str(MX("kg")) 
    
@testattr(xml = True)    
def test_ModelicaDisplayUnit():
    model =  load_model("AtomicModelAttributeDisplayUnit", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("displayUnit")) == str(MX("kg"))
    
@testattr(xml = True)    
def test_ModelicaMin():
    model =  load_model("AtomicModelAttributeMin", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str((diffs[0].getAttribute("min"))) == str(MX(0)) 

@testattr(xml = True)    
def test_ModelicaMax():
    model =  load_model("AtomicModelAttributeMax", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("max")) == str(MX(100))
    
@testattr(xml = True)    
def test_ModelicaStart():
    model =  load_model("AtomicModelAttributeStart", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("start"))  == str(MX(0.0005))
    
@testattr(xml = True)    
def test_ModelicaFixed():
    model =  load_model("AtomicModelAttributeFixed", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("fixed")) == str(MX(True))

@testattr(xml = True)    
def test_ModelicaNominal():
    model =  load_model("AtomicModelAttributeNominal", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("nominal")) == str(MX(0.1))
    
@testattr(xml = True)    
def test_ModelicaComment():
    model =  load_model("AtomicModelComment", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    print str(diffs[0].getAttribute("comment"))
    print str(MX("I am x1's comment"))
    assert str(diffs[0].getAttribute("comment")) == str(MX("I am x1's comment"))

@testattr(xml = True)    
def test_ModelicaRealDeclaredType():
    model =  load_model("AtomicModelDerivedRealTypeVoltage", modelFile)
    assert str(model.getVariableType("Voltage")) == ("Voltage type = Real (quantity = ElectricalPotential, unit = V);")
   
@testattr(xml = True)    
def test_ModelicaDerivedTypeDefaultType():
    model =  load_model("AtomicModelDerivedTypeAndDefaultType", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert int(diffs[0].getDeclaredType().this) == int(model.getVariableType("Voltage").this)
    assert int(diffs[1].getDeclaredType().this) == int(model.getVariableType("Real").this)
    
@testattr(xml = True)    
def test_ModelicaIntegerDeclaredType():
    model =  load_model("AtomicModelDerivedIntegerTypeSteps", modelFile)
    assert str(model.getVariableType("Steps")) == ("Steps type = Integer (quantity = steps);")
    
@testattr(xml = True)    
def test_ModelicaBooleanDeclaredType():
    model =  load_model("AtomicModelDerivedBooleanTypeIsDone", modelFile)
    assert str(model.getVariableType("IsDone")) == ("IsDone type = Boolean (quantity = Done);")

@testattr(xml = True)    
def test_ModelicaRealConstant():
    model =  load_model("atomicModelRealConstant", modelFile)
    constVars =  model.getVariables(Model.REAL_CONSTANT)
    assert str(constVars[0].getVar()) == str(MX("pi"))
    assertNear(constVars[0].getAttribute("bindingExpression").getValue(), 3.14, 0.0000001)

@testattr(xml = True)    
def test_ModelicaRealIndependentParameter():
    model =  load_model("atomicModelRealIndependentParameter", modelFile)
    indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
    assert str(indepParam[0].getVar()) == str(MX("pi"))
    assertNear(indepParam[0].getAttribute("bindingExpression").getValue(), 3.14, 0.0000001)
        
@testattr(xml = True)    
def test_ModelicaRealDependentParameter():
    model =  load_model("atomicModelRealDependentParameter", modelFile)
    depParam =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
    indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
    assert str(2*(indepParam[0].getVar())) == str(depParam[0].getAttribute("bindingExpression"))
    
@testattr(xml = True)    
def test_ModelicaDerivative():
    model =  load_model("atomicModelRealDerivative", modelFile)
    assert str(model.getVariables(Model.DERIVATIVE)[0].getVar()) == str(der_x1)
    
@testattr(xml = True)    
def test_ModelicaDifferentiated():
    model = load_model("atomicModelRealDifferentiated", modelFile)
    diff = model.getVariables(Model.DIFFERENTIATED)
    assert str(diff[0].getVar()) == str(x1)
        
@testattr(xml = True)    
def test_ModelicaRealInput():
    model =  load_model("atomicModelRealInput", modelFile)
    ins =  model.getVariables(Model.REAL_INPUT)
    assert str(ins[0].getVar()) == str(x1)

@testattr(xml = True)    
def test_ModelicaAlgebraic():
    model =  load_model("atomicModelRealAlgebraic", modelFile)
    alg =  model.getVariables(Model.REAL_ALGEBRAIC)
    assert str(alg[0].getVar()) == str(x1)
    
@testattr(xml = True)    
def test_ModelicaRealDisrete():
    model =  load_model("atomicModelRealDiscrete", modelFile)
    realDisc =  model.getVariables(Model.REAL_DISCRETE)
    assert str(realDisc[0].getVar()) == str(x1)

@testattr(xml = True)    
def test_ModelicaIntegerConstant():
    model =  load_model("atomicModelIntegerConstant", modelFile)
    constVars =  model.getVariables(Model.INTEGER_CONSTANT)
    assert str(constVars[0].getVar()) == str(MX("pi"))
    assertNear( constVars[0].getAttribute("bindingExpression").getValue(), 3, 0.0000001)
    
@testattr(xml = True)    
def test_ModelicaIntegerIndependentParameter():
    model =  load_model("atomicModelIntegerIndependentParameter", modelFile)
    indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
    assert str(indepParam[0].getVar()) == str(MX("pi"))
    assertNear( indepParam[0].getAttribute("bindingExpression").getValue(), 3, 0.0000001 )
    
@testattr(xml = True)    
def test_ModelicaIntegerDependentConstants():
    model =  load_model("atomicModelIntegerDependentParameter", modelFile)    
    depParam =  model.getVariables(Model.INTEGER_PARAMETER_DEPENDENT)
    indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
    assert str(2*(indepParam[0].getVar())) == str(depParam[0].getAttribute("bindingExpression"))

@testattr(xml = True)    
def test_ModelicaIntegerDiscrete():
    model =  load_model("atomicModelIntegerDiscrete", modelFile)
    intDisc =  model.getVariables(Model.INTEGER_DISCRETE)
    assert str(intDisc[0].getVar()) == str(x1)
    
@testattr(xml = True)    
def test_ModelicaIntegerInput():
    model =  load_model("atomicModelIntegerInput", modelFile)    
    intIns =  model.getVariables(Model.INTEGER_INPUT)
    assert str(intIns[0].getVar()) == str(x1)
    
@testattr(xml = True)    
def test_ModelicaBooleanConstant():
    model =  load_model("atomicModelBooleanConstant", modelFile)
    constVars =  model.getVariables(Model.BOOLEAN_CONSTANT)
    assert str(constVars[0].getVar()) == str(MX("pi"))
    assertNear( constVars[0].getAttribute("bindingExpression").getValue(), MX(True).getValue(), 0.0000001 )
    
@testattr(xml = True)    
def test_ModelicaBooleanIndependentParameter():
    model =  load_model("atomicModelBooleanIndependentParameter", modelFile)
    indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
    assert str(indepParam[0].getVar()) == str(MX("pi"))
    assertNear( indepParam[0].getAttribute("bindingExpression").getValue(), MX(True).getValue(), 0.0000001 )
    
@testattr(xml = True)    
def test_ModelicaBooleanDependentParameter():
    model =  load_model("atomicModelBooleanDependentParameter", modelFile)    
    depParam =  model.getVariables(Model.BOOLEAN_PARAMETER_DEPENDENT)  
    indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
    assert str( indepParam[0].getVar().logic_and(MX(True)) ) == str(depParam[0].getAttribute("bindingExpression"))
    
@testattr(xml = True)    
def test_ModelicaBooleanDiscrete():
    model =  load_model("atomicModelBooleanDiscrete", modelFile)        
    boolDisc =  model.getVariables(Model.BOOLEAN_DISCRETE)
    assert str(boolDisc[0].getVar()) == str(x1)

@testattr(xml = True)
def test_ModelicaBooleanInput():
    model =  load_model("atomicModelBooleanInput", modelFile)
    boolIns =  model.getVariables(Model.BOOLEAN_INPUT)
    assert str(boolIns[0].getVar()) == str(x1)

@testattr(xml = True)    
def test_ModelicaModelFunction():
    model =  load_model("simpleModelWithFunctions", modelFile)
    expectedPrint = ("ModelFunction : function(\"simpleModelWithFunctions.f\")\n Inputs (2):\n"
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
                            "@0 = 0.5\n"
                            "@1 = input[0]\n"
                            "@0 = (@0*@1)\n"
                            "output[0] = @0\n"
                            "@1 = input[1]\n"
                            "@1 = (@1+@0)\n"
                            "output[1] = @1\n")
    mf_1 = model.getModelFunction("simpleModelWithFunctions.f")
    mf_2 = model.getModelFunction("simpleModelWithFunctions.f2")
    actual = str(mf_1) + str(mf_2)
    assert expectedPrint == actual

@testattr(xml = True)
def test_ModelicaDependentParametersCalculated():
    model =  load_model("atomicModelDependentParameter", modelFile)
    model.calculateValuesForDependentParameters()
    depVars = model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
    assert depVars[0].getAttribute("evaluatedBindingExpression").getValue() == 20
    assert depVars[1].getAttribute("evaluatedBindingExpression").getValue() == 20
    assert depVars[2].getAttribute("evaluatedBindingExpression").getValue() == 200

@testattr(xml = True)
def test_ModelicaFunctionCallEquationForParameterBinding():
    model =  load_model("atomicModelPolyOutFunctionCallForDependentParameter", modelFile, compiler_options={"inline_functions":"none"})
    model.calculateValuesForDependentParameters()
    expected = ("parameter Real temp_1[1](bindingExpression = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){0}, evaluatedBindingExpression = 2) = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){0}/* 2 */;\n"
                "parameter Real temp_1[2](bindingExpression = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){1}, evaluatedBindingExpression = 4) = function(\"atomicModelPolyOutFunctionCallForDependentParameter.f\").call([p1]){1}/* 4 */;\n"
                "parameter Real p2[1](bindingExpression = temp_1[1], evaluatedBindingExpression = 2) = temp_1[1]/* 2 */;\n"
                "parameter Real p2[2](bindingExpression = temp_1[2], evaluatedBindingExpression = 4) = temp_1[2]/* 4 */;\n")
    actual = ""
    for var in model.getVariables(Model.REAL_PARAMETER_DEPENDENT):
        actual += str(var) + "\n"
    print expected, "\n", actual
    assert actual == expected
    
@testattr(xml = True)
def test_ModelicaTimeVariable():
    model = load_model("atomicModelTime", modelFile)
    t = model.getTimeVariable()
    eq = model.getDaeResidual()
    assert eq[1].getDep(1).getDep(1).isEqual(t) and eq[0].getDep(1).isEqual(t)
    
@testattr(xml = True)
def test_ConstructElementaryExpression():
    dae = load_model("AtomicModelElementaryExpressions", modelFile).getDaeResidual()
    expected ="MX(vertcat((der(x1)-(2+x1)),(der(x2)-(x2-x1)),(der(x3)-(x3*x2)),(der(x4)-(x4/x3))))"
    assert repr(dae) == expected 
    
@testattr(xml = True)    
def test_ConstructElementaryFunctions():
    dae = load_model("AtomicModelElementaryFunctions", modelFile).getDaeResidual()
    expected = ("MX(vertcat((der(x1)-pow(x1,5)),(der(x2)-fabs(x2)),(der(x3)-fmin(x3,x2))," +
                "(der(x4)-fmax(x4,x3)),(der(x5)-sqrt(x5)),(der(x6)-sin(x6)),(der(x7)-cos(x7)),(der(x8)-tan(x8))," +"(der(x9)-asin(x9)),(der(x10)-acos(x10)),(der(x11)-atan(x11)),(der(x12)-atan2(x12,x11))," + "(der(x13)-sinh(x13)),(der(x14)-cosh(x14)),(der(x15)-tanh(x15)),(der(x16)-exp(x16)),(der(x17)-log(x17)),(der(x18)-(0.434294*log(x18))),(der(x19)+x18)))")# CasADi converts log10 to log with constant.
    assert repr(dae) == expected
    
@testattr(xml = True)    
def test_ConstructBooleanExpressions():
    dae = load_model("AtomicModelBooleanExpressions", modelFile).getDaeResidual()
    expected = ("MX(vertcat((der(x1)-((x2?1:0)+((!x2)?2:0)))," + 
                "(x2-(0<x1)),(x3-(0<=x1)),(x4-(x1<0))," + 
                "(x5-(x1<=0)),(x6-(x5==x4)),(x7-(x6!=x5)),(x8-(x6&&x5)),(x9-(x6||x5))))")
    assert repr(dae) == expected
    
@testattr(xml = True)    
def test_ConstructMisc():
    model = load_model("AtomicModelMisc", modelFile)
    expected = (
    "MX(vertcat((der(x1)-1.11),(x2-(((1<x1)?3:0)+((!(1<x1))?4:0))),(x3-(1||(1<x2))),(x4-(0||x3))))"     
     "MX(vertcat(x1,pre(x2),pre(x3),pre(x4)))")
    assert (repr(model.getDaeResidual()) + repr(model.getInitialResidual()))  == expected
    
@testattr(xml = True)    
def test_ConstructVariableLaziness():
    model = load_model("AtomicModelVariableLaziness", modelFile)
    x2_eq = model.getDaeResidual()[0].getDep(1)
    x1_eq = model.getDaeResidual()[1].getDep(1)
    x1_var = model.getVariables(Model.DIFFERENTIATED)[0].getVar()
    x2_var = model.getVariables(Model.DIFFERENTIATED)[1].getVar()
    assert x1_var.isEqual(x1_eq) and x2_var.isEqual(x2_eq)
    
@testattr(xml = True)
def test_ConstructFunctionsInRhs():
    model = load_model("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"})
    expected = "vertcat((der(x1)-sin(function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([x1]){0})),(der(x2)-function(\"AtomicModelAtomicRealFunctions.polyInMonoOut\").call([x1,x2]){0}),(vertcat(x3,x4)-vertcat(function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){0},function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){1})),(vertcat(x5,x6)-vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1,x2]){0},function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1,x2]){1})),(der(x7)-function(\"AtomicModelAtomicRealFunctions.monoInMonoOutReturn\").call([x7]){0}),(der(x8)-function(\"AtomicModelAtomicRealFunctions.functionCallInFunction\").call([x8]){0}),(der(x9)-function(\"AtomicModelAtomicRealFunctions.functionCallEquationInFunction\").call([x9]){0}),(der(x10)-function(\"AtomicModelAtomicRealFunctions.monoInMonoOutInternal\").call([x10]){0}),(vertcat(x11,x12)-vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9,x10]){0},function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9,x10]){1})))"
    assert str(model.getDaeResidual()) == expected 


    model = load_model("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"})
    expected = "vertcat((x1-function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([u1]){0}),(x2-function(\"AtomicModelAtomicIntegerFunctions.polyInMonoOut\").call([u1,u2]){0}),(vertcat(x3,x4)-vertcat(function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([u2]){0},function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([u2]){1})),(vertcat(x5,x6)-vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([u1,u2]){0},function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([u1,u2]){1})),(x7-function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn\").call([u1]){0}),(x8-function(\"AtomicModelAtomicIntegerFunctions.functionCallInFunction\").call([u2]){0}),(x9-function(\"AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction\").call([u1]){0}),(x10-function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal\").call([u2]){0}),(vertcat(x11,x12)-vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([u1,u2]){0},function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([u1,u2]){1})))"
    assert str(model.getDaeResidual()) == expected 

      
    model = load_model("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"})
    expected = "vertcat((x1-function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([u1]){0}),(x2-function(\"AtomicModelAtomicBooleanFunctions.polyInMonoOut\").call([u1,u2]){0}),(vertcat(x3,x4)-vertcat(function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([u2]){0},function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([u2]){1})),(vertcat(x5,x6)-vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([u1,u2]){0},function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([u1,u2]){1})),(x7-function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn\").call([u1]){0}),(x8-function(\"AtomicModelAtomicBooleanFunctions.functionCallInFunction\").call([u2]){0}),(x9-function(\"AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction\").call([u1]){0}),(x10-function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal\").call([u2]){0}),(vertcat(x11,x12)-vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([u1,u2]){0},function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([u1,u2]){1})))"
    assert str(model.getDaeResidual()) == expected 
    

@testattr(xml = True)
def test_ConstructVariousRealValuedFunctions():
    model = load_model("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
    #function monoInMonoOut
        #input Real x
        #output Real y
    #algorithm
        #y := x
    #end monoInMonoOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOut")) == expected 

    #function polyInMonoOut
        #input Real x1
        #input Real x2
        #output Real y
    #algorithm
        #y := x1+x2
    #end polyInMonoOut
    #end monoInMonoOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.polyInMonoOut\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = input[1]\n"
                "@0 = (@0+@1)\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInMonoOut")) == expected 

    #function monoInPolyOut
        #input Real x
        #output Real y1
        #output Real y2
    #algorithm
        #y1 := if(x > 2) then 1 else 5
        #y2 := x
    #end monoInPolyOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\")\n"
                " Input: 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = 2\n"
                "@1 = input[0]\n"
                "@0 = (@0<@1)\n"
                "@2 = 1\n"
                "@2 = (@0?@2:0)\n"
                "@0 = (!@0)\n"
                "@3 = 5\n"
                "@0 = (@0?@3:0)\n"
                "@2 = (@2+@0)\n"
                "output[0] = @2\n"
                "output[1] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInPolyOut")) == expected
    
    #function polyInPolyOut
        #input Real x1
        #input Real x2
        #output Real y1
        #output Real y2
    #algorithm
        #y1 := x1
        #y2 := x2
    #end polyInPolyOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = input[1]\n"
                "output[1] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInPolyOut")) == expected
    
    #function monoInMonoOutReturn
        #input Real x
        #output Real y
    #algorithm
        #y := x
        #return
        #y := 2*x
    #end monoInMonoOutReturn
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInMonoOutReturn\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOutReturn")) == expected

    #function functionCallInFunction
        #input Real x
        #output Real y
    #algorithm
        #y := monoInMonoOut(x)
    #end functionCallInFunction
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.functionCallInFunction\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([@0])\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.functionCallInFunction")) == expected
    
    #function functionCallEquationInFunction
        #input Real x
        #Real internal
        #output Real y
    #algorithm
        #(y,internal) := monoInPolyOut(x)
    #end functionCallEquationInFunction
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.functionCallEquationInFunction\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "{@1,NULL} = function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([@0])\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.functionCallEquationInFunction")) == expected

    #function monoInMonoOutInternal
        #input Real x
        #Real internal
        #output Real y
    #algorithm
        #internal := sin(x)
        #y := x*internal
        #internal := sin(y)
        #y := x + internal
    #end monoInMonoOutInternal
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.monoInMonoOutInternal\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = sin(@0)\n"
                "@1 = (@0*@1)\n"
                "@1 = sin(@1)\n"
                "@0 = (@0+@1)\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOutInternal")) == expected

    #function polyInPolyOutInternal
        #input Real x1
        #input Real x2
        #Real internal1
        #Real internal2
        #output Real y1
        #output Real y2
    #algorithm
        #internal1 := x1
        #internal2 := x2 + internal1
        #y1 := internal1
        #y2 := internal2 + x1
        #y2 := 1
    #end polyInPolyOutInternal
    expected = ("ModelFunction : function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = 1\n"
                "output[1] = @0\n"
                "@0 = input[1]\n")
    assert str(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInPolyOutInternal")) == expected
     
     
@testattr(xml = True)    
def test_ConstructVariousIntegerValuedFunctions():
    model = load_model("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
    #function monoInMonoOut
        #input Integer x
        #output Integer y
    #algorithm
        #y := x
    #end monoInMonoOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOut")) == expected 

    #function polyInMonoOut
        #input Integer x1
        #input Integer x2
        #output Integer y
    #algorithm
        #y := x1+x2
    #end polyInMonoOut
    #end monoInMonoOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.polyInMonoOut\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = input[1]\n"
                "@0 = (@0+@1)\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInMonoOut")) == expected 

    #function monoInPolyOut
        #input Integer x
        #output Integer y1
        #output Integer y2
    #algorithm
        #y1 := if(x > 2) then 1 else 5
        #y2 := x
    #end monoInPolyOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\")\n"
                " Input: 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = 2\n"
                "@1 = input[0]\n"
                "@0 = (@0<@1)\n"
                "@2 = 1\n"
                "@2 = (@0?@2:0)\n"
                "@0 = (!@0)\n"
                "@3 = 5\n"
                "@0 = (@0?@3:0)\n"
                "@2 = (@2+@0)\n"
                "output[0] = @2\n"
                "output[1] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInPolyOut")) == expected
    
    #function polyInPolyOut
        #input Integer x1
        #input Integer x2
        #output Integer y1
        #output Integer y2
    #algorithm
        #y1 := x1
        #y2 := x2
    #end polyInPolyOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = input[1]\n"
                "output[1] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInPolyOut")) == expected
    
    #function monoInMonoOutReturn
        #input Integer x
        #output Integer y
    #algorithm
        #y := x
        #return
        #y := 2*x
    #end monoInMonoOutReturn
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn")) == expected

    #function functionCallInFunction
        #input Integer x
        #output Integer y
    #algorithm
        #y := monoInMonoOut(x)
    #end functionCallInFunction
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.functionCallInFunction\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([@0])\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.functionCallInFunction")) == expected
    
    #function functionCallEquationInFunction
        #input Integer x
        #Integer internal
        #output Integer y
    #algorithm
        #(y,internal) := monoInPolyOut(x)
    #end functionCallEquationInFunction
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "{@1,NULL} = function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([@0])\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction")) == expected

    #function monoInMonoOutInternal
        #input Integer x
        #Integer internal
        #output Integer y
    #algorithm
        #internal := 3*x
        #y := x*internal
        #internal := 1+y
        #y := x + internal
    #end monoInMonoOutInternal
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = 3\n"
                "@1 = input[0]\n"
                "@0 = (@0*@1)\n"
                "@0 = (@1*@0)\n"
                "@2 = 1\n"
                "@2 = (@2+@0)\n"
                "@1 = (@1+@2)\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal")) == expected

    #function polyInPolyOutInternal
        #input Integer x1
        #input Integer x2
        #Integer internal1
        #Integer internal2
        #output Integer y1
        #output Integer y2
    #algorithm
        #internal1 := x1
        #internal2 := x2 + internal1
        #y1 := internal1
        #y2 := internal2 + x1
        #y2 := 1
    #end polyInPolyOutInternal
    expected = ("ModelFunction : function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = 1\n"
                "output[1] = @0\n"
                "@0 = input[1]\n")
    assert str(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal")) == expected
     
     
@testattr(xml = True)    
def test_ConstructVariousBooleanValuedFunctions():
    model = load_model("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
    #function monoInMonoOut
        #input Boolean x
        #output Boolean y
    #algorithm
        #y := x
    #end monoInMonoOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOut")) == expected 

    #function polyInMonoOut
        #input Boolean x1
        #input Boolean x2
        #output Boolean y
    #algorithm
        #y := x1 and x2
    #end polyInMonoOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.polyInMonoOut\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = input[1]\n"
                "@0 = (@0&&@1)\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInMonoOut")) == expected 

    #function monoInPolyOut
        #input Boolean x
        #output Boolean y1
        #output Boolean y2
    #algorithm
        #y1 := if(x) then false else (x or false)
        #y2 := x
    #end monoInPolyOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\")\n"
                " Input: 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = 0\n"
                "@1 = input[0]\n"
                "@0 = (@0||@1)\n"
                "@2 = (!@1)\n"
                "@2 = (@2?@0:0)\n"
                "output[0] = @2\n"
                "output[1] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInPolyOut")) == expected
    
    #function polyInPolyOut
        #input Boolean x1
        #input Boolean x2
        #output Boolean y1
        #output Boolean y2
    #algorithm
        #y1 := x1
        #y2 := x2
    #end polyInPolyOut
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = input[1]\n"
                "output[1] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInPolyOut")) == expected
    
    #function monoInMonoOutReturn
        #input Boolean x
        #output Boolean y
    #algorithm
        #y := x
        #return
        #y := x or false
    #end monoInMonoOutReturn
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn")) == expected

    #function functionCallInFunction
        #input Boolean x
        #output Boolean y
    #algorithm
        #y := monoInMonoOut(x)
    #end functionCallInFunction
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.functionCallInFunction\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([@0])\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.functionCallInFunction")) == expected
    
    #function functionCallEquationInFunction
        #input Boolean x
        #Boolean internal
        #output Boolean y
    #algorithm
        #(y,internal) := monoInPolyOut(x)
    #end functionCallEquationInFunction
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "{@1,NULL} = function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([@0])\n"
                "output[0] = @1\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction")) == expected

    #function monoInMonoOutInternal
        #input Boolean x
        #Boolean internal
        #output Boolean y
    #algorithm
        #internal := x
        #y := x and internal
        #internal := false or y
        #y := false or internal
    #end monoInMonoOutInternal
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@0 = (@0&&@0)\n"
                "@1 = 0\n"
                "@1 = (@1||@0)\n"
                "@0 = 0\n"
                "@0 = (@0||@1)\n"
                "output[0] = @0\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal")) == expected

    #function polyInPolyOutInternal
        #input Boolean x1
        #input Boolean x2
        #Boolean internal1
        #Boolean internal2
        #output Boolean y1
        #output Boolean y2
    #algorithm
        #internal1 := x1
        #internal2 := x2  or internal1
        #y1 := internal1
        #y2 := internal2 or x1
        #y2 := true
    #end polyInPolyOutInternal
    expected = ("ModelFunction : function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = 1\n"
                "output[1] = @0\n"
                "@0 = input[1]\n")
    assert str(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal")) == expected

    
    
@testattr(xml = True)    
def test_TransferVariableType():
    model = load_model("AtomicModelMisc", modelFile)
    x1 = model.getVariable('x1')
    assert isinstance(x1, RealVariable)
    assert isinstance(x1.getMyDerivativeVariable(), DerivativeVariable)
    assert isinstance(model.getVariable('x2'), IntegerVariable)
    assert isinstance(model.getVariable('x3'), BooleanVariable)
    assert isinstance(model.getVariable('x4'), BooleanVariable)
