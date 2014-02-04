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


## In this file there are tests for transferModelica, transferOptimica and tests for
## the correct transfer of the MX representation of expressions and various Modelica constructs
## from JModelica.org.


# Common variables used in the tests
x1 = MX("x1")
x2 = MX("x2")
x3 = MX("x3")
der_x1 = MX("der(x1)")
modelFile = os.path.join(get_files_path(), 'Modelica', 'TestModelicaModels.mo')
    
def assertNear(val1, val2, tol):
    assert abs(val1 - val2) < tol
    
##############################################
#                                            # 
#          MODELICA TRANSFER TESTS           #
#                                            #
##############################################
    
@testattr(casadi = True)    
def test_ModelicaAliasVariables():
    model = transfer_to_casadi_interface("atomicModelAlias", modelFile)
    assert not model.getVariable("x").isNegated()
    assert model.getVariable("z").isNegated()
    assert str(model.getVariable("x")) == "Real x(alias: y);"
    assert str(model.getModelVariable("x")) == "Real y;"
    assert str(model.getVariable("y")) == "Real y;"
    assert str(model.getModelVariable("y")) == "Real y;"
    assert str(model.getVariable("z")) == "Real z(alias: y);"
    assert str(model.getModelVariable("z")) == "Real y;"
    

@testattr(casadi = True)    
def test_ModelicaSimpleEquation():
    assert str(transfer_to_casadi_interface("AtomicModelSimpleEquation", modelFile).getDaeResidual()) == str(x1 - der_x1) 

@testattr(casadi = True)    
def test_ModelicaSimpleInitialEquation():
    assert str(transfer_to_casadi_interface("AtomicModelSimpleInitialEquation", modelFile).getInitialResidual())  == str(MX(1)-x1)

@testattr(casadi = True)    
def test_ModelicaFunctionCallEquations():
    assert( repr(transfer_to_casadi_interface("AtomicModelFunctionCallEquation", modelFile, compiler_options={"inline_functions":"none"}).getDaeResidual()) == 
                ("MX(vertcat((x1-der(x1)),(vertcat(function(\"AtomicModelFunctionCallEquation.f\")" + 
                ".call([x1]){0},function(\"AtomicModelFunctionCallEquation.f\").call([x1]){1})-vertcat(x2,x3))))") )  
                
@testattr(casadi = True)    
def test_ModelicaBindingExpression():
    model =  transfer_to_casadi_interface("AtomicModelAttributeBindingExpression", modelFile)
    dependent =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
    independent =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
    actual =  str(independent[0].getAttribute("bindingExpression")) + str(dependent[0].getAttribute("bindingExpression"))
    expected = str(MX(2)) + str(MX("p1"))
    assert actual == expected

@testattr(casadi = True)    
def test_ModelicaUnit():
    model =  transfer_to_casadi_interface("AtomicModelAttributeUnit", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("unit")) == str(MX("kg")) 

@testattr(casadi = True)    
def test_ModelicaQuantity():
    model =  transfer_to_casadi_interface("AtomicModelAttributeQuantity", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("quantity")) == str(MX("kg")) 

@testattr(casadi = True)    
def test_ModelicaDisplayUnit():
    model =  transfer_to_casadi_interface("AtomicModelAttributeDisplayUnit", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("displayUnit")) == str(MX("kg")) 

@testattr(casadi = True)    
def test_ModelicaMin():
    model =  transfer_to_casadi_interface("AtomicModelAttributeMin", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str((diffs[0].getAttribute("min"))) == str(MX(0)) 

@testattr(casadi = True)    
def test_ModelicaMax():
    model =  transfer_to_casadi_interface("AtomicModelAttributeMax", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("max")) == str(MX(100))
    
@testattr(casadi = True)    
def test_ModelicaStart():
    model =  transfer_to_casadi_interface("AtomicModelAttributeStart", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("start"))  == str(MX(0.0005))
    
@testattr(casadi = True)    
def test_ModelicaFixed():
    model =  transfer_to_casadi_interface("AtomicModelAttributeFixed", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("fixed")) == str(MX(True))

@testattr(casadi = True)    
def test_ModelicaNominal():
    model =  transfer_to_casadi_interface("AtomicModelAttributeNominal", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("nominal")) == str(MX(0.1))
        
@testattr(casadi = True)    
def test_ModelicaComment():
    model =  transfer_to_casadi_interface("AtomicModelComment", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("comment")) == str(MX("I am x1's comment"))
        
@testattr(casadi = True)    
def test_ModelicaRealDeclaredType():
    model =  transfer_to_casadi_interface("AtomicModelDerivedRealTypeVoltage", modelFile)
    assert str(model.getVariableType("Voltage")) == ("Voltage type = Real (quantity = ElectricalPotential, unit = V);")
   
@testattr(casadi = True)    
def test_ModelicaDerivedTypeDefaultType():
    model =  transfer_to_casadi_interface("AtomicModelDerivedTypeAndDefaultType", modelFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert int(diffs[0].getDeclaredType().this) == int(model.getVariableType("Voltage").this)
    assert int(diffs[1].getDeclaredType().this) == int(model.getVariableType("Real").this)
    
@testattr(casadi = True)    
def test_ModelicaIntegerDeclaredType():
    model =  transfer_to_casadi_interface("AtomicModelDerivedIntegerTypeSteps", modelFile)
    assert str(model.getVariableType("Steps")) == ("Steps type = Integer (quantity = steps);")
    
@testattr(casadi = True)    
def test_ModelicaBooleanDeclaredType():
    model =  transfer_to_casadi_interface("AtomicModelDerivedBooleanTypeIsDone", modelFile)
    assert str(model.getVariableType("IsDone")) == ("IsDone type = Boolean (quantity = Done);")

@testattr(casadi = True)    
def test_ModelicaRealConstant():
    model =  transfer_to_casadi_interface("atomicModelRealConstant", modelFile)
    constVars =  model.getVariables(Model.REAL_CONSTANT)
    assert str(constVars[0].getVar()) == str(MX("pi"))
    assertNear(constVars[0].getAttribute("bindingExpression").getValue(), 3.14, 0.0000001)

@testattr(casadi = True)    
def test_ModelicaRealIndependentParameter():
    model =  transfer_to_casadi_interface("atomicModelRealIndependentParameter", modelFile)
    indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
    assert str(indepParam[0].getVar()) == str(MX("pi"))
    assertNear(indepParam[0].getAttribute("bindingExpression").getValue(), 3.14, 0.0000001)
        
@testattr(casadi = True)    
def test_ModelicaRealDependentParameter():
    model =  transfer_to_casadi_interface("atomicModelRealDependentParameter", modelFile)
    depParam =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
    indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
    assert str(2*(indepParam[0].getVar())) == str(depParam[0].getAttribute("bindingExpression"))
    
@testattr(casadi = True)    
def test_ModelicaDerivative():
    model =  transfer_to_casadi_interface("atomicModelRealDerivative", modelFile)
    assert str(model.getVariables(Model.DERIVATIVE)[0].getVar()) == str(der_x1)
    
@testattr(casadi = True)    
def test_ModelicaDifferentiated():
    model = transfer_to_casadi_interface("atomicModelRealDifferentiated", modelFile)
    diff = model.getVariables(Model.DIFFERENTIATED)
    assert str(diff[0].getVar()) == str(x1)
        
@testattr(casadi = True)    
def test_ModelicaRealInput():
    model =  transfer_to_casadi_interface("atomicModelRealInput", modelFile)
    ins =  model.getVariables(Model.REAL_INPUT)
    assert str(ins[0].getVar()) == str(x1)

@testattr(casadi = True)    
def test_ModelicaAlgebraic():
    model =  transfer_to_casadi_interface("atomicModelRealAlgebraic", modelFile)
    alg =  model.getVariables(Model.REAL_ALGEBRAIC)
    assert str(alg[0].getVar()) == str(x1)
    
@testattr(casadi = True)    
def test_ModelicaRealDisrete():
    model =  transfer_to_casadi_interface("atomicModelRealDiscrete", modelFile)
    realDisc =  model.getVariables(Model.REAL_DISCRETE)
    assert str(realDisc[0].getVar()) == str(x1)
    
@testattr(casadi = True)    
def test_ModelicaIntegerConstant():
    model =  transfer_to_casadi_interface("atomicModelIntegerConstant", modelFile)
    constVars =  model.getVariables(Model.INTEGER_CONSTANT)
    assert str(constVars[0].getVar()) == str(MX("pi"))
    assertNear( constVars[0].getAttribute("bindingExpression").getValue(), 3, 0.0000001)
    
@testattr(casadi = True)    
def test_ModelicaIntegerIndependentParameter():
    model =  transfer_to_casadi_interface("atomicModelIntegerIndependentParameter", modelFile)
    indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
    assert str(indepParam[0].getVar()) == str(MX("pi"))
    assertNear( indepParam[0].getAttribute("bindingExpression").getValue(), 3, 0.0000001 )
    
@testattr(casadi = True)    
def test_ModelicaIntegerDependentConstants():
    model =  transfer_to_casadi_interface("atomicModelIntegerDependentParameter", modelFile)    
    depParam =  model.getVariables(Model.INTEGER_PARAMETER_DEPENDENT)
    indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
    assert str(2*(indepParam[0].getVar())) == str(depParam[0].getAttribute("bindingExpression"))

def test_ModelicaIntegerDiscrete():
    model =  transfer_to_casadi_interface("atomicModelIntegerDiscrete", modelFile)
    intDisc =  model.getVariables(Model.INTEGER_DISCRETE)
    assert str(intDisc[0].getVar()) == str(x1)
    
@testattr(casadi = True)    
def test_ModelicaIntegerInput():
    model =  transfer_to_casadi_interface("atomicModelIntegerInput", modelFile)    
    intIns =  model.getVariables(Model.INTEGER_INPUT)
    assert str(intIns[0].getVar()) == str(x1)
    
@testattr(casadi = True)    
def test_ModelicaBooleanConstant():
    model =  transfer_to_casadi_interface("atomicModelBooleanConstant", modelFile)
    constVars =  model.getVariables(Model.BOOLEAN_CONSTANT)
    assert str(constVars[0].getVar()) == str(MX("pi"))
    assertNear( constVars[0].getAttribute("bindingExpression").getValue(), MX(True).getValue(), 0.0000001 )
    
@testattr(casadi = True)    
def test_ModelicaBooleanIndependentParameter():
    model =  transfer_to_casadi_interface("atomicModelBooleanIndependentParameter", modelFile)
    indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
    assert str(indepParam[0].getVar()) == str(MX("pi"))
    assertNear( indepParam[0].getAttribute("bindingExpression").getValue(), MX(True).getValue(), 0.0000001 )
    
@testattr(casadi = True)    
def test_ModelicaBooleanDependentParameter():
    model =  transfer_to_casadi_interface("atomicModelBooleanDependentParameter", modelFile)    
    depParam =  model.getVariables(Model.BOOLEAN_PARAMETER_DEPENDENT)  
    indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
    assert str( indepParam[0].getVar().logic_and(MX(True)) ) == str(depParam[0].getAttribute("bindingExpression"))
    
@testattr(casadi = True)    
def test_ModelicaBooleanDiscrete():
    model =  transfer_to_casadi_interface("atomicModelBooleanDiscrete", modelFile)        
    boolDisc =  model.getVariables(Model.BOOLEAN_DISCRETE)
    assert str(boolDisc[0].getVar()) == str(x1)

def test_ModelicaBooleanInput():
    model =  transfer_to_casadi_interface("atomicModelBooleanInput", modelFile)
    boolIns =  model.getVariables(Model.BOOLEAN_INPUT)
    assert str(boolIns[0].getVar()) == str(x1)
        
@testattr(casadi = True)    
def test_ModelicaModelFunction():
    model =  transfer_to_casadi_interface("simpleModelWithFunctions", modelFile)
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

def test_ModelicaDependentParametersCalculated():
    model =  transfer_to_casadi_interface("atomicModelDependentParameter", modelFile)
    model.calculateValuesForDependentParameters()
    depVars = model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
    assert depVars[0].getAttribute("evaluatedBindingExpression").getValue() == 20
    assert depVars[1].getAttribute("evaluatedBindingExpression").getValue() == 20
    assert depVars[2].getAttribute("evaluatedBindingExpression").getValue() == 200

def test_ModelicaFunctionCallEquationForParameterBinding():
    model =  transfer_to_casadi_interface("atomicModelPolyOutFunctionCallForDependentParameter", modelFile, compiler_options={"inline_functions":"none"})
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
    
    
@testattr(casadi = True)    
def test_ModelicaStart():
    model = transfer_to_casadi_interface("atomicModelTime", modelFile)
    t = model.getTimeVariable()
    eq = model.getDaeResidual()
    assert eq[1].getDep(0).getDep(1).isEqual(t) and eq[0].getDep(0).isEqual(t)

##############################################
#                                            # 
#          OPTIMICA TRANSFER TESTS           #
#                                            #
##############################################

optproblemsFile = os.path.join(get_files_path(), 'Modelica', 'TestOptimizationProblems.mop')

def computeStringRepresentationForContainer(myContainer):
    stringRepr = ""
    for index in range(len(myContainer)):
        stringRepr += str(myContainer[index])
    return stringRepr
    
    
@testattr(casadi = True)    
def test_OptimicaLessThanPathConstraint():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationLEQ", optproblemsFile)
    expected = str(x1) + " <= " + str(MX(1.0))
    assert( computeStringRepresentationForContainer(optProblem.getPathConstraints()) == expected)

def test_OptimicaGreaterThanPathConstraint():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationGEQ", optproblemsFile)
    expected = str(x1) + " >= " + str(MX(1.0))
    assert( computeStringRepresentationForContainer(optProblem.getPathConstraints()) == expected)
    
@testattr(casadi = True)    
def test_OptimicaSevaralPathConstraints():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationGEQandLEQ", optproblemsFile)
    expected = str(x2) + " <= " + str(MX(1.0)) +  str(x1) + " >= " + str(MX(1.0)) 
    assert( computeStringRepresentationForContainer(optProblem.getPathConstraints()) == expected)    

def test_OptimicaEqualityPointConstraint():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationEQpoint", optproblemsFile)
    expected = str(MX("x1(finalTime)")) + " = " + str(MX(1.0))
    assert( computeStringRepresentationForContainer(optProblem.getPointConstraints()) == expected)
    
@testattr(casadi = True)    
def test_OptimicaLessThanPointConstraint():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationLEQpoint", optproblemsFile)
    expected = str(MX("x1(finalTime)")) + " <= " + str(MX(1.0))
    assert( computeStringRepresentationForContainer(optProblem.getPointConstraints()) == expected)

def test_OptimicaGreaterThanPointConstraint():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationGEQpoint", optproblemsFile)
    expected = str(MX("x1(finalTime)")) + " >= " + str(MX(1.0))
    assert( computeStringRepresentationForContainer(optProblem.getPointConstraints()) == expected)
    
@testattr(casadi = True)    
def test_OptimicaSevaralPointConstraints():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationGEQandLEQandEQpoint", optproblemsFile)
    expected = str(MX("x2(startTime + 1)")) + " <= " + str(MX(1.0)) +  str(MX("x1(startTime + 1)")) + " >= " + str(MX(1.0)) + str(MX("x2(finalTime + 1)")) + " = " + str(MX(1.0))
    assert( computeStringRepresentationForContainer(optProblem.getPointConstraints()) == expected)
    
@testattr(casadi = True)    
def test_OptimicaMixedConstraints():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationMixedConstraints", optproblemsFile)
    expectedPath = str(MX("x3(startTime + 1)")) + " <= " + str(x1)
    expectedPoint =  str(MX("x2(startTime + 1)")) + " <= " + str(MX(1.0)) +  str(MX("x1(startTime + 1)")) + " >= " + str(MX(1.0)) 
    assert( computeStringRepresentationForContainer(optProblem.getPathConstraints()) == expectedPath)
    assert( computeStringRepresentationForContainer(optProblem.getPointConstraints()) == expectedPoint)
    
@testattr(casadi = True)    
def test_OptimicaTimedVariables():
    def heurestic_MC_variables_equal(MC_var1, MC_var2):
        return MC_var1.getVar().isEqual(MC_var2.getVar()) and str(MC_var1) == str(MC_var2)

    optProblem =  transfer_to_casadi_interface("atomicOptimizationTimedVariables", optproblemsFile)
    # test there are 3 timed
    timedVars = optProblem.getTimedVariables()
    assert len(timedVars) == 4

    # test they contain model vars
    x1 = optProblem.getVariable("x1")
    x2 = optProblem.getVariable("x2")
    x3 = optProblem.getVariable("x3")

    assert heurestic_MC_variables_equal(x1, timedVars[0].getBaseVariable())
    assert heurestic_MC_variables_equal(x2, timedVars[1].getBaseVariable())
    assert heurestic_MC_variables_equal(x3, timedVars[2].getBaseVariable())
    assert heurestic_MC_variables_equal(x1, timedVars[3].getBaseVariable())
        
        
    # Test their time expression has start/final parameter MX in them and
    # that timed variables are lazy.
    startTime = optProblem.getVariable("startTime")
    finalTime = optProblem.getVariable("finalTime")
    path_constraints = optProblem.getPathConstraints()
    point_constraints = optProblem.getPointConstraints()

    tp1 = timedVars[0].getTimePoint()
    tp2 = timedVars[1].getTimePoint()
    tp3 = timedVars[2].getTimePoint()
    tp4 = timedVars[3].getTimePoint()

    tv1 = timedVars[0].getVar()
    tv2 = timedVars[1].getVar()
    tv3 = timedVars[2].getVar()
    tv4 = timedVars[3].getVar()

    assert tp1.getDep(1).isEqual(startTime.getVar())
    assert tp2.getDep(1).isEqual(startTime.getVar())
    assert tp3.getDep(0).isEqual(finalTime.getVar())
    assert tp4.isEqual(finalTime.getVar())

    assert tv1.isEqual(point_constraints[0].getLhs())
    assert tv2.isEqual(path_constraints[0].getLhs())
    assert tv3.isEqual(path_constraints[1].getLhs())
    assert tv4.isEqual(optProblem.getMayerTerm())

def test_OptimicaStartTime():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationStart5", optproblemsFile)
    assert( optProblem.getStartTime().getValue() == 5)
    
@testattr(casadi = True)    
def test_OptimicaFinalTime():
    optProblem =  transfer_to_casadi_interface("atomicOptimizationFinal10", optproblemsFile)
    assert( optProblem.getFinalTime().getValue() == 10)

def test_OptimicaLagrangeTerm():
    optProblem =  transfer_to_casadi_interface("atomicLagrangeX1", optproblemsFile)
    assert str(optProblem.getLagrangeTerm()) == str(x1) 
    optProblem =  transfer_to_casadi_interface("atomicLagrangeNull", optproblemsFile)
    assert str(optProblem.getLagrangeTerm()) == str(MX(0))  

def test_OptimicaMayerTerm():
    optProblem =  transfer_to_casadi_interface("atomicMayerFinalTime", optproblemsFile)
    assert str(optProblem.getMayerTerm()) == str(MX("finalTime")) 
    optProblem =  transfer_to_casadi_interface("atomicMayerNull", optproblemsFile)
    assert str(optProblem.getMayerTerm()) == str(MX(0))

def test_OptimicaFree():
    model =  transfer_to_casadi_interface("atomicWithFree", optproblemsFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str((diffs[0].getAttribute("free"))) == str(MX(False))

def test_OptimicaInitialGuess():
    model =  transfer_to_casadi_interface("atomicWithInitialGuess", optproblemsFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("initialGuess")) == str(MX(5))


def test_OptimicaInvalidCompiler():
    import sys
    errorString = ""
    try:
        transfer_to_casadi_interface("AtomicModelSimpleEquation", modelFile, compiler = "OPTIMICA")
    except:
        errorString = sys.exc_info()[1].message 
    assert errorString == "An OptimizationProblem can not be created from a Modelica model";
   
##############################################
#                                            # 
#         CONSTRUCTS TRANSFER TESTS          #
#                                            #
##############################################


def test_ConstructElementaryExpression():
    dae = transfer_to_casadi_interface("AtomicModelElementaryExpressions", modelFile).getDaeResidual()
    expected = "MX(vertcat(((2+x1)-der(x1)),((x2-x1)-der(x2)),((x3*x2)-der(x3)),((x4/x3)-der(x4))))"
    assert repr(dae) == expected 
    
@testattr(casadi = True)    
def test_ConstructElementaryFunctions():
    dae = transfer_to_casadi_interface("AtomicModelElementaryFunctions", modelFile).getDaeResidual()
    expected = ("MX(vertcat((pow(x1,5)-der(x1)),(fabs(x2)-der(x2)),(fmin(x3,x2)-der(x3))," +
                "(fmax(x4,x3)-der(x4)),(sqrt(x5)-der(x5)),(sin(x6)-der(x6)),(cos(x7)-der(x7)),(tan(x8)-der(x8))," +
                "(asin(x9)-der(x9)),(acos(x10)-der(x10)),(atan(x11)-der(x11)),(atan2(x12,x11)-der(x12))," +
                "(sinh(x13)-der(x13)),(cosh(x14)-der(x14)),(tanh(x15)-der(x15)),(exp(x16)-der(x16)),(log(x17)-der(x17))," +
                "((0.434294*log(x18))-der(x18)),((-x18)-der(x19))))" ) # CasADi converts log10 to log with constant.
    assert repr(dae) == expected
    
@testattr(casadi = True)    
def test_ConstructBooleanExpressions():
    dae = transfer_to_casadi_interface("AtomicModelBooleanExpressions", modelFile).getDaeResidual()
    expected = ("MX(vertcat((((x2?1:0)+((!x2)?2:0))-der(x1))," + 
                "((0<x1)-x2),((0<=x1)-x3),((x1<0)-x4)" +
                ",((x1<=0)-x5),((x5==x4)-x6),((x6!=x5)-x7),((x6&&x5)-x8),((x6||x5)-x9)))" )
    assert repr(dae) == expected
     
@testattr(casadi = True)    
def test_ConstructMisc():
    model = transfer_to_casadi_interface("AtomicModelMisc", modelFile)
    expected = ("MX(vertcat((1.11-der(x1)),((((1<x1)?3:0)+((!(1<x1))?4:0))-x2)," +
                "((1||(1<x2))-x3),((0||x3)-x4)))" + 
                "MX(vertcat((-x1),(-pre(x2)),(-pre(x3)),(-pre(x4))))")
    assert (repr(model.getDaeResidual()) + repr(model.getInitialResidual()))  == expected
     
@testattr(casadi = True)    
def test_ConstructVariableLaziness():
    model = transfer_to_casadi_interface("AtomicModelVariableLaziness", modelFile)
    x2_eq = model.getDaeResidual()[0].getDep(0)
    x1_eq = model.getDaeResidual()[1].getDep(0)
    x1_var = model.getVariables(Model.DIFFERENTIATED)[0].getVar()
    x2_var = model.getVariables(Model.DIFFERENTIATED)[1].getVar()
    assert x1_var.isEqual(x1_eq) and x2_var.isEqual(x2_eq)
    
@testattr(casadi = True)    
def test_ConstructArrayInOutFunction1():
    model = transfer_to_casadi_interface("AtomicModelVector1", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelVector1.f\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@0 = (-@0)\n"
                "output[0] = @0\n"
                "@0 = input[1]\n"
                "@0 = (-@0)\n"
                "output[1] = @0\n")
    assert str(model.getModelFunction("AtomicModelVector1.f")) == expected
    expected = ("vertcat((vertcat(function(\"AtomicModelVector1.f\").call([A[1],A[2]]){0}," +                                                             
                "function(\"AtomicModelVector1.f\").call([A[1],A[2]]){1})-vertcat(temp_1[1],temp_1[2]))," +
                "(temp_1[1]-der(A[1])),(temp_1[2]-der(A[2])))")
    assert str(model.getDaeResidual()) == expected
 
def test_ConstructArrayInOutFunction2():
    model = transfer_to_casadi_interface("AtomicModelVector2", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelVector2.f\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "@1 = input[1]\n"
                "{@2,@3} = function(\"AtomicModelVector2.f2\").call([@0,@1])\n"
                "output[0] = @2\n"
                "output[1] = @3\n")
    assert str(model.getModelFunction("AtomicModelVector2.f")) == expected
    expected = ("vertcat((vertcat(function(\"AtomicModelVector2.f\").call([A[1],A[2]]){0}," +
                "function(\"AtomicModelVector2.f\").call([A[1],A[2]]){1})-vertcat(temp_1[1],temp_1[2]))," +
                "(temp_1[1]-der(A[1])),(temp_1[2]-der(A[2])))")
    assert str(model.getDaeResidual()) == expected
    
@testattr(casadi = True)    
def test_ConstructArrayInOutFunctionCallEquation():
    model = transfer_to_casadi_interface("AtomicModelVector3", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelVector3.f\")\n"
                " Inputs (4):\n"
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
                "@0 = input[1]\n"
                "@0 = (-@0)\n"
                "output[1] = @0\n"
                "@0 = input[2]\n"
                "@0 = (2.*@0)\n"
                "output[2] = @0\n"
                "@0 = input[3]\n"
                "@0 = (2.*@0)\n"
                "output[3] = @0\n")
    assert str(model.getModelFunction("AtomicModelVector3.f")) == expected
    expected = ("(vertcat(function(\"AtomicModelVector3.f\").call([A[1],A[2],1,2])" +
                "{0},function(\"AtomicModelVector3.f\").call([A[1],A[2],1,2])" +
                "{1},function(\"AtomicModelVector3.f\").call([A[1],A[2],1,2]){2}," +
                "function(\"AtomicModelVector3.f\").call([A[1],A[2],1,2]){3})-vertcat(A[1],A[2],B[1],B[2]))")
    assert str(model.getDaeResidual()) == expected
    
@testattr(casadi = True)    
def test_FunctionCallEquationOmittedOuts():
    model = transfer_to_casadi_interface("atomicModelFunctionCallEquationIgnoredOuts", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("vertcat(((x1+x2)-der(x2)),"
                "(vertcat("
                "function(\"atomicModelFunctionCallEquationIgnoredOuts.f\").call([1,x3]){0},"
                "function(\"atomicModelFunctionCallEquationIgnoredOuts.f\").call([1,x3]){2})"
                "-vertcat(x1,x2)))")
    assert str(model.getDaeResidual()) == expected  

     
@testattr(casadi = True)    
def test_FunctionCallStatementOmittedOuts():
    model = transfer_to_casadi_interface("atomicModelFunctionCallStatementIgnoredOuts", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"atomicModelFunctionCallStatementIgnoredOuts.f2\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = 10\n"
                "@1 = input[0]\n"
                "{NULL,NULL,@2} = function(\"atomicModelFunctionCallStatementIgnoredOuts.f\").call([@0,@1])\n"
                "output[0] = @2\n")
    assert str(model.getModelFunction("atomicModelFunctionCallStatementIgnoredOuts.f2")) == expected
    
@testattr(casadi = True)    
def test_OmittedArrayRecordOuts():
    model = transfer_to_casadi_interface("atomicModelFunctionCallStatementIgnoredArrayRecordOuts", modelFile, compiler_options={"inline_functions":"none"})
    expectedFunctionPrint = ("ModelFunction : function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2\")\n"
                            " Input: 1-by-1 (dense)\n"
                            " Outputs (6):\n"
                            "  0. 1-by-1 (dense)\n"
                            "  1. 1-by-1 (dense)\n"
                            "  2. 1-by-1 (dense)\n"
                            "  3. 1-by-1 (dense)\n"
                            "  4. 1-by-1 (dense)\n"
                            "  5. 1-by-1 (dense)\n"
                            "@0 = 10\n"
                            "@1 = input[0]\n"
                            "{@2,@3,@4,NULL,NULL,@5,@6,@7} = function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f\").call([@0,@1])\n"
                            "output[0] = @2\n"
                            "output[1] = @3\n"
                            "output[2] = @4\n"
                            "output[3] = @5\n"
                            "output[4] = @6\n"
                            "output[5] = @7\n")
    expectedResidualPrint = "(vertcat(function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2\").call([x1]){2},function(\"atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2\").call([x1]){5})-vertcat(x1,x2))"
    assert str(model.getModelFunction("atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2")) == expectedFunctionPrint
    assert str(model.getDaeResidual()) == expectedResidualPrint
    
@testattr(casadi = True)    
def test_ConstructFunctionMatrix():
    model = transfer_to_casadi_interface("AtomicModelMatrix", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelMatrix.f\")\n"
                " Inputs (4):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "  2. 1-by-1 (dense)\n"
                "  3. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[2]\n"
                "output[0] = @0\n"
                "@0 = input[3]\n"
                "output[1] = @0\n"
                "@0 = input[0]\n"
                "@1 = input[1]\n")
    assert str(model.getModelFunction("AtomicModelMatrix.f")) == expected
    expected = ("vertcat((vertcat(function(\"AtomicModelMatrix.f\").call([A[1,1],A[1,2],0.1," +
                "0.3]){0},function(\"AtomicModelMatrix.f\").call([A[1,1],A[1,2],0.1" +
                ",0.3]){1})-vertcat(temp_1[1,1],temp_1[1,2])),((-temp_1[1,1])-der(A[1,1])),((-temp_1[1,2])-der(A[1,2]))," +
                "(vertcat(function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){0}," +
                "function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){1}," +
                "function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){2}," +
                "function(\"AtomicModelMatrix.f2\").call([dx[1,1],dx[1,2],dx[2,1],dx[2,2]]){3})-" +
                "vertcat(temp_2[1,1],temp_2[1,2],temp_2[2,1],temp_2[2,2])),((-temp_2[1,1])-der(dx[1,1]))," +
                "((-temp_2[1,2])-der(dx[1,2])),((-temp_2[2,1])-der(dx[2,1])),((-temp_2[2,2])-der(dx[2,2])))")
    assert str(model.getDaeResidual()) == expected
        
@testattr(casadi = True)    
def test_ConstructFunctionMatrixDimsGreaterThanTwo():
    model = transfer_to_casadi_interface("AtomicModelLargerThanTwoDimensionArray", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelLargerThanTwoDimensionArray.f\")\n"
                " Inputs (6):\n"
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
                "@0 = input[1]\n"
                "@0 = (-@0)\n"
                "output[1] = @0\n"
                "@0 = input[2]\n"
                "@0 = (-@0)\n"
                "output[2] = @0\n"
                "@0 = input[3]\n"
                "@0 = (-@0)\n"
                "output[3] = @0\n"
                "@0 = input[4]\n"
                "@0 = (-@0)\n"
                "output[4] = @0\n"
                "@0 = 10\n"
                "output[5] = @0\n"
                "@0 = input[5]\n")
    assert str(model.getModelFunction("AtomicModelLargerThanTwoDimensionArray.f")) == expected
    expected = ("vertcat((vertcat("
                "function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){0}," 
                "function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){1}," 
                "function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){2}," 
                "function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){3},"  
                "function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){4}," 
                "function(\"AtomicModelLargerThanTwoDimensionArray.f\").call([A[1,1,1],A[1,1,2],A[1,1,3],A[1,2,1],A[1,2,2],A[1,2,3]]){5})" 
                "-vertcat(temp_1[1,1,1],temp_1[1,1,2],temp_1[1,1,3],temp_1[1,2,1],temp_1[1,2,2],temp_1[1,2,3]))," +
                "(temp_1[1,1,1]-der(A[1,1,1])),(temp_1[1,1,2]-der(A[1,1,2])),(temp_1[1,1,3]-der(A[1,1,3])),(temp_1[1,2,1]-der(A[1,2,1])),(temp_1[1,2,2]-der(A[1,2,2])),(temp_1[1,2,3]-der(A[1,2,3])))")
    assert str(model.getDaeResidual()) == expected
        
@testattr(casadi = True)    
def test_ConstructNestedRecordFunctions():
    model = transfer_to_casadi_interface("AtomicModelRecordNestedArray", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelRecordNestedArray.generateCurves\")\n"
                " Input: 1-by-1 (dense)\n"
                " Outputs (8):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "  2. 1-by-1 (dense)\n"
                "  3. 1-by-1 (dense)\n"
                "  4. 1-by-1 (dense)\n"
                "  5. 1-by-1 (dense)\n"
                "  6. 1-by-1 (dense)\n"
                "  7. 1-by-1 (dense)\n"
                "@0 = 0\n"
                "output[0] = @0\n"
                "@0 = input[0]\n"
                "output[1] = @0\n"
                "@0 = 2\n"
                "output[2] = @0\n"
                "@1 = 3\n"
                "output[3] = @1\n"
                "@2 = 6\n"
                "output[4] = @2\n"
                "@2 = 7\n"
                "output[5] = @2\n"
                "output[6] = @0\n"
                "output[7] = @1\n")
    assert str(model.getModelFunction("AtomicModelRecordNestedArray.generateCurves")) == expected
    expected = ("vertcat((vertcat(" +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){0}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){1}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){2}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){3}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){4}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){5}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){6}," +
                "function(\"AtomicModelRecordNestedArray.generateCurves\").call([a]){7})" +
                "-vertcat(" +
                "compCurve.curves[1].path[1].point[1],compCurve.curves[1].path[1].point[2]," + 
                "compCurve.curves[1].path[2].point[1],compCurve.curves[1].path[2].point[2]," +
                "compCurve.curves[2].path[1].point[1],compCurve.curves[2].path[1].point[2]," +
                "compCurve.curves[2].path[2].point[1],compCurve.curves[2].path[2].point[2]))," +
                "(compCurve.curves[1].path[1].point[2]-der(a)))")
    assert str(model.getDaeResidual()) == expected
        
@testattr(casadi = True)    
def test_ConstructRecordInFunctionInFunction():
    model = transfer_to_casadi_interface("AtomicModelRecordInOutFunctionCallStatement", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelRecordInOutFunctionCallStatement.f1\")\n"
                " Input: 1-by-1 (dense)\n"
                " Output: 1-by-1 (dense)\n"
                "@0 = 2\n"
                "@1 = input[0]\n"
                "@0 = (@0+@1)\n"
                "{@2,@3} = function(\"AtomicModelRecordInOutFunctionCallStatement.f2\").call([@1,@0])\n"
                "@2 = (@2*@3)\n"
                "output[0] = @2\n"
                "ModelFunction : function(\"AtomicModelRecordInOutFunctionCallStatement.f2\")\n"
                " Inputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                " Outputs (2):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "@0 = input[0]\n"
                "output[0] = @0\n"
                "@0 = 10\n"
                "@1 = input[1]\n"
                "@0 = (@0*@1)\n" 
                "output[1] = @0\n")
    funcStr = str(model.getModelFunction("AtomicModelRecordInOutFunctionCallStatement.f1")) + str(model.getModelFunction("AtomicModelRecordInOutFunctionCallStatement.f2"))
    assert funcStr == expected
    assert str(model.getDaeResidual()) == "((-function(\"AtomicModelRecordInOutFunctionCallStatement.f1\").call([a]){0})-der(a))"

def test_ConstructRecordArbitraryDimension():
    model = transfer_to_casadi_interface("AtomicModelRecordArbitraryDimension", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelRecordArbitraryDimension.f\")\n"
                " Input: 1-by-1 (dense)\n"
                " Outputs (8):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "  2. 1-by-1 (dense)\n"
                "  3. 1-by-1 (dense)\n"
                "  4. 1-by-1 (dense)\n"
                "  5. 1-by-1 (dense)\n"
                "  6. 1-by-1 (dense)\n"
                "  7. 1-by-1 (dense)\n"
                "@0 = 1\n"
                "output[0] = @0\n"
                "@0 = 2\n"
                "output[1] = @0\n"
                "@0 = 3\n"
                "output[2] = @0\n"
                "@0 = 4\n"
                "output[3] = @0\n"
                "@0 = 5\n"
                "output[4] = @0\n"
                "@0 = 6\n"
                "output[5] = @0\n"
                "@0 = input[0]\n"
                "output[6] = @0\n"
                "@0 = (2.*@0)\n"
                "output[7] = @0\n")
    assert str(model.getModelFunction("AtomicModelRecordArbitraryDimension.f")) == expected
    expected = ("vertcat(((-a)-der(a)),(vertcat(" + 
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){0}," +
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){1}," +
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){2}," + 
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){3}," +
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){4}," +
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){5}," +
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){6}," +
                "function(\"AtomicModelRecordArbitraryDimension.f\").call([a]){7})" +
                "-vertcat(r.A[1,1,1],r.A[1,1,2],r.A[1,2,1],r.A[1,2,2],r.A[2,1,1],r.A[2,1,2],r.A[2,2,1],r.A[2,2,2])))")
    assert str(model.getDaeResidual()) == expected
    
@testattr(casadi = True)    
def test_ConstructArrayFlattening():
    model =  transfer_to_casadi_interface("atomicModelSimpleArrayIndexing", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"atomicModelSimpleArrayIndexing.f\")\n"
                " Inputs (0):\n"
                " Outputs (4):\n"
                "  0. 1-by-1 (dense)\n"
                "  1. 1-by-1 (dense)\n"
                "  2. 1-by-1 (dense)\n"
                "  3. 1-by-1 (dense)\n"
                "@0 = 1\n"
                "output[0] = @0\n"
                "@0 = 2\n"
                "output[1] = @0\n"
                "@0 = 3\n"
                "output[2] = @0\n"
                "@0 = 4\n"
                "output[3] = @0\n")
    assert str(model.getModelFunction("atomicModelSimpleArrayIndexing.f")) == expected
    
@testattr(casadi = True)    
def test_ConstructRecordNestedSeveralVars():
    model = transfer_to_casadi_interface("AtomicModelRecordSeveralVars", modelFile, compiler_options={"inline_functions":"none"})
    expected = ("ModelFunction : function(\"AtomicModelRecordSeveralVars.f\")\n"
                " Input: 1-by-1 (dense)\n"
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
                "@0 = 1\n"
                "output[0] = @0\n"
                "@0 = 2\n"
                "output[1] = @0\n"
                "@0 = 3\n"
                "output[2] = @0\n"
                "@0 = 4\n"
                "output[3] = @0\n"
                "@0 = 5\n"
                "output[4] = @0\n"
                "@0 = 6\n"
                "output[5] = @0\n"
                "@0 = 7\n"
                "output[6] = @0\n"
                "@0 = 8\n"
                "output[7] = @0\n"
                "@0 = 9\n"
                "output[8] = @0\n"
                "@0 = input[0]\n"
                "output[9] = @0\n")
    assert str(model.getModelFunction("AtomicModelRecordSeveralVars.f")) == expected
    expected = ("vertcat(((-a)-der(a)),(vertcat(" +  
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){0}," + 
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){1}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){2}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){3}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){4}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){5}," + 
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){6}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){7}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){8}," +
                "function(\"AtomicModelRecordSeveralVars.f\").call([a]){9})" +
                "-vertcat(r.r1.A,r.r1.B,r.rArr[1].A,r.rArr[1].B,r.rArr[2].A,r.rArr[2].B,r.matrix[1,1],r.matrix[1,2],r.matrix[2,1],r.matrix[2,2])))")
    assert str(model.getDaeResidual()) == expected

def test_ConstructFunctionsInRhs():
    model = transfer_to_casadi_interface("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
    expected = ("vertcat((sin(function(\"AtomicModelAtomicRealFunctions.monoInMonoOut\").call([x1]){0})-der(x1)),"
                "(function(\"AtomicModelAtomicRealFunctions.polyInMonoOut\").call([x1,x2]){0}-der(x2)),"
                "(vertcat(function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){0},function(\"AtomicModelAtomicRealFunctions.monoInPolyOut\").call([x2]){1})-vertcat(x3,x4)),"
                "(vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1,x2]){0},function(\"AtomicModelAtomicRealFunctions.polyInPolyOut\").call([x1,x2]){1})-vertcat(x5,x6)),"
                "(function(\"AtomicModelAtomicRealFunctions.monoInMonoOutReturn\").call([x7]){0}-der(x7)),"
                "(function(\"AtomicModelAtomicRealFunctions.functionCallInFunction\").call([x8]){0}-der(x8)),"
                "(function(\"AtomicModelAtomicRealFunctions.functionCallEquationInFunction\").call([x9]){0}-der(x9)),"
                "(function(\"AtomicModelAtomicRealFunctions.monoInMonoOutInternal\").call([x10]){0}-der(x10)),"
                "(vertcat(function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9,x10]){0},function(\"AtomicModelAtomicRealFunctions.polyInPolyOutInternal\").call([x9,x10]){1})-vertcat(x11,x12)))")
    assert str(model.getDaeResidual()) == expected 
    
    model = transfer_to_casadi_interface("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
    expected = ("vertcat(("
                "function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOut\").call([u1]){0}-x1),"
                "(function(\"AtomicModelAtomicIntegerFunctions.polyInMonoOut\").call([u1,u2]){0}-x2),"
                "(vertcat(function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([u2]){0},function(\"AtomicModelAtomicIntegerFunctions.monoInPolyOut\").call([u2]){1})-vertcat(x3,x4)),"
                "(vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([u1,u2]){0},function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOut\").call([u1,u2]){1})-vertcat(x5,x6)),"
                "(function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn\").call([u1]){0}-x7),"
                "(function(\"AtomicModelAtomicIntegerFunctions.functionCallInFunction\").call([u2]){0}-x8),"
                "(function(\"AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction\").call([u1]){0}-x9),"
                "(function(\"AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal\").call([u2]){0}-x10),"
                "(vertcat(function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([u1,u2]){0},function(\"AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal\").call([u1,u2]){1})-vertcat(x11,x12)))")
    assert str(model.getDaeResidual()) == expected 
      
    model = transfer_to_casadi_interface("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
    expected = ("vertcat(("
                "function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOut\").call([u1]){0}-x1),"
                "(function(\"AtomicModelAtomicBooleanFunctions.polyInMonoOut\").call([u1,u2]){0}-x2),"
                "(vertcat(function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([u2]){0},function(\"AtomicModelAtomicBooleanFunctions.monoInPolyOut\").call([u2]){1})-vertcat(x3,x4)),"
                "(vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([u1,u2]){0},function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOut\").call([u1,u2]){1})-vertcat(x5,x6)),"
                "(function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn\").call([u1]){0}-x7),"
                "(function(\"AtomicModelAtomicBooleanFunctions.functionCallInFunction\").call([u2]){0}-x8),"
                "(function(\"AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction\").call([u1]){0}-x9),"
                "(function(\"AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal\").call([u2]){0}-x10),"
                "(vertcat(function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([u1,u2]){0},function(\"AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal\").call([u1,u2]){1})-vertcat(x11,x12)))")
    assert str(model.getDaeResidual()) == expected 
     
@testattr(casadi = True)    
def test_ConstructVariousRealValuedFunctions():
    model = transfer_to_casadi_interface("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
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
     
     
@testattr(casadi = True)    
def test_ConstructVariousIntegerValuedFunctions():
    model = transfer_to_casadi_interface("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
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
     
     
@testattr(casadi = True)    
def test_ConstructVariousBooleanValuedFunctions():
    model = transfer_to_casadi_interface("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
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
     
@testattr(casadi = True)    
def test_TransferVariableType():
    model = transfer_to_casadi_interface("AtomicModelMisc", modelFile)
    x1 = model.getVariable('x1')
    assert isinstance(x1, RealVariable)
    assert isinstance(x1.getMyDerivativeVariable(), DerivativeVariable)
    assert isinstance(model.getVariable('x2'), IntegerVariable)
    assert isinstance(model.getVariable('x3'), BooleanVariable)
    assert isinstance(model.getVariable('x4'), BooleanVariable)
     
@testattr(casadi = True)    
def test_ModelIdentifier():
    model = transfer_to_casadi_interface("identifierTest.identfierTestModel", modelFile)
    assert model.getIdentifier() == "identifierTest_identfierTestModel"
    optProblem = transfer_to_casadi_interface("identifierTest.identfierTestModel", optproblemsFile)
    assert optProblem.getIdentifier() == "identifierTest_identfierTestModel"
