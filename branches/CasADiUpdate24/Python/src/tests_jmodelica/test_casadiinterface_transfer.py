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
try:
    import casadi
    from casadi import isEqual
    from modelicacasadi_transfer import *
    # Common variables used in the tests
    x1 = MX.sym("x1")
    x2 = MX.sym("x2")
    x3 = MX.sym("x3")
    der_x1 = MX.sym("der(x1)")
except (NameError, ImportError):
    pass

modelFile = os.path.join(get_files_path(), 'Modelica', 'TestModelicaModels.mo')
optproblemsFile = os.path.join(get_files_path(), 'Modelica', 'TestOptimizationProblems.mop')
import platform

## In this file there are tests for transferModelica, transferOptimica and tests for
## the correct transfer of the MX representation of expressions and various Modelica constructs
## from JModelica.org.

def load_optimization_problem(*args, **kwargs):
    ocp = OptimizationProblem()
    transfer_optimization_problem(ocp, *args, **kwargs)
    return ocp

def strnorm(StringnotNorm):
    caracters = ['\n','\t',' ']
    StringnotNorm = str(StringnotNorm)
    for c in caracters:
        StringnotNorm = StringnotNorm.replace(c, '')
    return StringnotNorm

def check_strnorm(got, expected):
    got, expected = str(got), str(expected)
    if strnorm(got) != strnorm(expected):
        raise AssertionError("Expected:\n" + expected + "\ngot:\n" + got + "\n");

def assertNear(val1, val2, tol):
    assert abs(val1 - val2) < tol
    
##############################################
#                                            # 
#          MODELICA TRANSFER TESTS           #
#                                            #
##############################################

class ModelicaTransfer(object):
    """Base class for Modelica transfer tests. Subclasses define load_model"""

    @testattr(casadi = True)
    def test_ModelicaAliasVariables(self):
        model = self.load_model("atomicModelAlias", modelFile)
        assert not model.getVariable("x").isNegated()
        assert model.getVariable("z").isNegated()
        check_strnorm(model.getVariable("x"), "Real x(alias: y);")
        check_strnorm(model.getModelVariable("x"), "Real y;")
        check_strnorm(model.getVariable("y"), "Real y;")
        check_strnorm(model.getModelVariable("y"), "Real y;")
        check_strnorm(model.getVariable("z"), "Real z(alias: y);")
        check_strnorm(model.getModelVariable("z"), "Real y;")
    

    @testattr(casadi = True)
    def test_ModelicaSimpleEquation(self):
        check_strnorm(self.load_model("AtomicModelSimpleEquation", modelFile).getDaeResidual(), der_x1 - x1) 

    @testattr(casadi = True)
    def test_ModelicaSimpleInitialEquation(self):
        check_strnorm(self.load_model("AtomicModelSimpleInitialEquation", modelFile).getInitialResidual(), x1 - MX(1))

    @testattr(casadi = True)
    def test_ModelicaFunctionCallEquations(self):
        check_strnorm(repr(self.load_model("AtomicModelFunctionCallEquation", modelFile, compiler_options={"inline_functions":"none"}).getDaeResidual()),
            "MX(@1=AtomicModelFunctionCallEquation.f(der(x1)), vertcat((der(x1)-x1), (vertcat(x2, x3)-vertcat(@1{0}, @1{1}))))")

    @testattr(casadi = True)
    def test_ModelicaBindingExpression(self):
        model =  self.load_model("AtomicModelAttributeBindingExpression", modelFile)
        dependent =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
        independent =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
        actual =  str(independent[0].getAttribute("bindingExpression")) + str(dependent[0].getAttribute("bindingExpression"))
        expected = str(MX(2)) + str(MX.sym("p1"))
        check_strnorm(actual, expected)

    @testattr(casadi = True)
    def test_ModelicaUnit(self):
        model =  self.load_model("AtomicModelAttributeUnit", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("unit"), MX.sym("kg"))

    @testattr(casadi = True)
    def test_ModelicaQuantity(self):
        model =  self.load_model("AtomicModelAttributeQuantity", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("quantity"), MX.sym("kg")) 

    @testattr(casadi = True)
    def test_ModelicaDisplayUnit(self):
        model =  self.load_model("AtomicModelAttributeDisplayUnit", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("displayUnit"), MX.sym("kg")) 

    @testattr(casadi = True)
    def test_ModelicaMin(self):
        model =  self.load_model("AtomicModelAttributeMin", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm((diffs[0].getAttribute("min")), MX(0)) 

    @testattr(casadi = True)
    def test_ModelicaMax(self):
        model =  self.load_model("AtomicModelAttributeMax", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("max"), MX(100))

    @testattr(casadi = True)
    def test_ModelicaStart(self):
        model =  self.load_model("AtomicModelAttributeStart", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("start"), MX(0.0005))

    @testattr(casadi = True)
    def test_ModelicaFixed(self):
        model =  self.load_model("AtomicModelAttributeFixed", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("fixed"), MX(True))

    @testattr(casadi = True)
    def test_ModelicaNominal(self):
        model =  self.load_model("AtomicModelAttributeNominal", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("nominal"), MX(0.1))

    @testattr(casadi = True)
    def test_ModelicaComment(self):
        model =  self.load_model("AtomicModelComment", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diffs[0].getAttribute("comment"), MX.sym("I am x1's comment"))

    @testattr(casadi = True)
    def test_ModelicaRealDeclaredType(self):
        model =  self.load_model("AtomicModelDerivedRealTypeVoltage", modelFile)
        check_strnorm(model.getVariableType("Voltage"), "Voltage type = Real (quantity = ElectricalPotential, unit = V);")

    @testattr(casadi = True)
    def test_ModelicaDerivedTypeDefaultType(self):
        model =  self.load_model("AtomicModelDerivedTypeAndDefaultType", modelFile)
        diffs =  model.getVariables(Model.DIFFERENTIATED)
        assert int(diffs[0].getDeclaredType().this) == int(model.getVariableType("Voltage").this)
        assert int(diffs[1].getDeclaredType().this) == int(model.getVariableType("Real").this)

    @testattr(casadi = True)
    def test_ModelicaIntegerDeclaredType(self):
        model =  self.load_model("AtomicModelDerivedIntegerTypeSteps", modelFile)
        check_strnorm(model.getVariableType("Steps"), "Steps type = Integer (quantity = steps);")

    @testattr(casadi = True)
    def test_ModelicaBooleanDeclaredType(self):
        model =  self.load_model("AtomicModelDerivedBooleanTypeIsDone", modelFile)
        check_strnorm(model.getVariableType("IsDone"), "IsDone type = Boolean (quantity = Done);")

    @testattr(casadi = True)
    def test_ModelicaRealConstant(self):
        model =  self.load_model("atomicModelRealConstant", modelFile)
        constVars =  model.getVariables(Model.REAL_CONSTANT)
        check_strnorm(constVars[0].getVar(), MX.sym("pi"))
        assertNear(float(constVars[0].getAttribute("bindingExpression")), 3.14, 0.0000001)

    @testattr(casadi = True)
    def test_ModelicaRealIndependentParameter(self):
        model =  self.load_model("atomicModelRealIndependentParameter", modelFile)
        indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
        check_strnorm(indepParam[0].getVar(), MX.sym("pi"))
        assertNear(float(indepParam[0].getAttribute("bindingExpression")), 3.14, 0.0000001)

    @testattr(casadi = True)
    def test_ModelicaRealDependentParameter(self):
        model =  self.load_model("atomicModelRealDependentParameter", modelFile)
        depParam =  model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
        indepParam =  model.getVariables(Model.REAL_PARAMETER_INDEPENDENT)
        check_strnorm(2*(indepParam[0].getVar()), depParam[0].getAttribute("bindingExpression"))

    @testattr(casadi = True)
    def test_ModelicaDerivative(self):
        model =  self.load_model("atomicModelRealDerivative", modelFile)
        check_strnorm(model.getVariables(Model.DERIVATIVE)[0].getVar(), der_x1)

    @testattr(casadi = True)
    def test_ModelicaDifferentiated(self):
        model = self.load_model("atomicModelRealDifferentiated", modelFile)
        diff = model.getVariables(Model.DIFFERENTIATED)
        check_strnorm(diff[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaRealInput(self):
        model =  self.load_model("atomicModelRealInput", modelFile)
        ins =  model.getVariables(Model.REAL_INPUT)
        check_strnorm(ins[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaAlgebraic(self):
        model =  self.load_model("atomicModelRealAlgebraic", modelFile)
        alg =  model.getVariables(Model.REAL_ALGEBRAIC)
        check_strnorm(alg[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaRealDisrete(self):
        model =  self.load_model("atomicModelRealDiscrete", modelFile)
        realDisc =  model.getVariables(Model.REAL_DISCRETE)
        check_strnorm(realDisc[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaIntegerConstant(self):
        model =  self.load_model("atomicModelIntegerConstant", modelFile)
        constVars =  model.getVariables(Model.INTEGER_CONSTANT)
        check_strnorm(constVars[0].getVar(), MX.sym("pi"))
        assertNear( float(constVars[0].getAttribute("bindingExpression")), 3, 0.0000001)

    @testattr(casadi = True)
    def test_ModelicaIntegerIndependentParameter(self):
        model =  self.load_model("atomicModelIntegerIndependentParameter", modelFile)
        indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
        check_strnorm(indepParam[0].getVar(), MX.sym("pi"))
        assertNear( float(indepParam[0].getAttribute("bindingExpression")), 3, 0.0000001 )

    @testattr(casadi = True)
    def test_ModelicaIntegerDependentConstants(self):
        model =  self.load_model("atomicModelIntegerDependentParameter", modelFile)    
        depParam =  model.getVariables(Model.INTEGER_PARAMETER_DEPENDENT)
        indepParam =  model.getVariables(Model.INTEGER_PARAMETER_INDEPENDENT)
        check_strnorm(2*(indepParam[0].getVar()), depParam[0].getAttribute("bindingExpression"))

    @testattr(casadi = True)
    def test_ModelicaIntegerDiscrete(self):
        model =  self.load_model("atomicModelIntegerDiscrete", modelFile)
        intDisc =  model.getVariables(Model.INTEGER_DISCRETE)
        check_strnorm(intDisc[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaIntegerInput(self):
        model =  self.load_model("atomicModelIntegerInput", modelFile)    
        intIns =  model.getVariables(Model.INTEGER_INPUT)
        check_strnorm(intIns[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaBooleanConstant(self):
        model =  self.load_model("atomicModelBooleanConstant", modelFile)
        constVars =  model.getVariables(Model.BOOLEAN_CONSTANT)
        check_strnorm(constVars[0].getVar(), MX.sym("pi"))
        assertNear( float(constVars[0].getAttribute("bindingExpression")), float(MX(True)), 0.0000001 )

    @testattr(casadi = True)
    def test_ModelicaBooleanIndependentParameter(self):
        model =  self.load_model("atomicModelBooleanIndependentParameter", modelFile)
        indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
        check_strnorm(indepParam[0].getVar(), MX.sym("pi"))
        assertNear( float(indepParam[0].getAttribute("bindingExpression")), float(MX(True)), 0.0000001 )

    @testattr(casadi = True)
    def test_ModelicaBooleanDependentParameter(self):
        model =  self.load_model("atomicModelBooleanDependentParameter", modelFile)    
        depParam =  model.getVariables(Model.BOOLEAN_PARAMETER_DEPENDENT)  
        indepParam =  model.getVariables(Model.BOOLEAN_PARAMETER_INDEPENDENT)
        check_strnorm( casadi.logic_and(indepParam[0].getVar(), (MX(True))), depParam[0].getAttribute("bindingExpression"))

    @testattr(casadi = True)
    def test_ModelicaBooleanDiscrete(self):
        model =  self.load_model("atomicModelBooleanDiscrete", modelFile)        
        boolDisc =  model.getVariables(Model.BOOLEAN_DISCRETE)
        check_strnorm(boolDisc[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaBooleanInput(self):
        model =  self.load_model("atomicModelBooleanInput", modelFile)
        boolIns =  model.getVariables(Model.BOOLEAN_INPUT)
        check_strnorm(boolIns[0].getVar(), x1)

    @testattr(casadi = True)
    def test_ModelicaModelFunction(self):
        model =  self.load_model("simpleModelWithFunctions", modelFile)
        expected = """
            ModelFunction : simpleModelWithFunctions.f
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = input[1][0]
            {@2, @3} = simpleModelWithFunctions.f2(@0, @1)
            output[0] = @2
            output[1] = @3

            ModelFunction : simpleModelWithFunctions.f2
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = 0.5
            @1 = input[0][0]
            @0 = (@0*@1)
            output[0] = @0
            @1 = input[1][0]
            @1 = (@1+@0)
            output[1] = @1
            """
        mf_1 = model.getModelFunction("simpleModelWithFunctions.f")
        mf_2 = model.getModelFunction("simpleModelWithFunctions.f2")
        actual = str(mf_1) + str(mf_2)
        check_strnorm(actual, expected)

    @testattr(casadi = True)
    def test_ModelicaDependentParametersCalculated(self):
        model =  self.load_model("atomicModelDependentParameter", modelFile)
        model.calculateValuesForDependentParameters()
        depVars = model.getVariables(Model.REAL_PARAMETER_DEPENDENT)
        assert float(depVars[0].getAttribute("evaluatedBindingExpression")) == 20
        assert float(depVars[1].getAttribute("evaluatedBindingExpression")) == 20
        assert float(depVars[2].getAttribute("evaluatedBindingExpression")) == 200

    @testattr(casadi = True)
    def test_ModelicaFunctionCallEquationForParameterBinding(self):
        model =  self.load_model("atomicModelPolyOutFunctionCallForDependentParameter", modelFile, compiler_options={"inline_functions":"none"})
        model.calculateValuesForDependentParameters()
        expected = """
            parameter Real p2[1](bindingExpression = atomicModelPolyOutFunctionCallForDependentParameter.f(p1){0}, evaluatedBindingExpression = 2) = atomicModelPolyOutFunctionCallForDependentParameter.f(p1){0}/* 2 */;
            parameter Real p2[2](bindingExpression = atomicModelPolyOutFunctionCallForDependentParameter.f(p1){1}, evaluatedBindingExpression = 4) = atomicModelPolyOutFunctionCallForDependentParameter.f(p1){1}/* 4 */;
            """        
        actual = ""
        for var in model.getVariables(Model.REAL_PARAMETER_DEPENDENT):
            actual += str(var) + "\n"
        check_strnorm(actual, expected)


    @testattr(casadi = True)
    def test_ModelicaTimeVariable(self):
        model = self.load_model("atomicModelTime", modelFile)
        t = model.getTimeVariable()
        eq = model.getDaeResidual()
        assert isEqual(eq[1].getDep(1).getDep(1), t) and isEqual(eq[0].getDep(1), t)

    ##############################################
    #                                            # 
    #         CONSTRUCTS TRANSFER TESTS          #
    #                                            #
    ##############################################

    @testattr(casadi = True)
    def test_ConstructElementaryExpression(self):
        dae = self.load_model("AtomicModelElementaryExpressions", modelFile).getDaeResidual()
        expected ="MX(vertcat((der(x1)-(2+x1)), (der(x2)-(x2-x1)), (der(x3)-(x3*x2)), (der(x4)-(x4/x3))))"
        check_strnorm(repr(dae), expected) 

    @testattr(casadi = True)
    def test_ConstructElementaryFunctions(self):
        dae = self.load_model("AtomicModelElementaryFunctions", modelFile).getDaeResidual()
        expected = ("MX(vertcat((der(x1)-pow(x1,5)), (der(x2)-fabs(x2)), (der(x3)-fmin(x3,x2)), (der(x4)-fmax(x4,x3)), (der(x5)-sqrt(x5)), (der(x6)-sin(x6)), (der(x7)-cos(x7)), (der(x8)-tan(x8)), (der(x9)-asin(x9)), (der(x10)-acos(x10)), (der(x11)-atan(x11)), (der(x12)-atan2(x12,x11)), (der(x13)-sinh(x13)), (der(x14)-cosh(x14)), (der(x15)-tanh(x15)), (der(x16)-exp(x16)), (der(x17)-log(x17)), (der(x18)-(0.434294*log(x18))), (der(x19)+x18)))")# CasADi converts log10 to log with constant.
        check_strnorm(repr(dae), expected)

    @testattr(casadi = True)
    def test_ConstructBooleanExpressions(self):
        dae = self.load_model("AtomicModelBooleanExpressions", modelFile).getDaeResidual()
#        expected = ("MX(vertcat((der(x1)-if_else(x2,1,2){0}, " +
        expected = ("MX(vertcat((der(x1)-if_else(x2){0}), " + # expecting this instead because of CasADi #1618
                    "(x2-(0<x1)), (x3-(0<=x1)), (x4-(x1<0)), " +
                    "(x5-(x1<=0)), (x6-(x5==x4)), (x7-(x6!=x5)), (x8-(x6&&x5)), (x9-(x6||x5))))")
        check_strnorm(repr(dae), expected)

    @testattr(casadi = True)
    def test_ConstructMisc(self):
        model = self.load_model("AtomicModelMisc", modelFile)
#        expected = ("MX(vertcat((der(x1)-1.11), (x2-if_else((1<x1),3,4){0}), " +
        expected = ("MX(vertcat((der(x1)-1.11), (x2-if_else((1<x1)){0}), " + # expecting this instead because of CasADi #1618
            "(x3-(1||(1<x2))), (x4-(0||x3))))MX(vertcat(repmat(x1, 1), repmat(pre(x2), 1), repmat(pre(x3), 1), repmat(pre(x4), 1)))")
        check_strnorm(repr(model.getDaeResidual()) + repr(model.getInitialResidual()), expected)



    @testattr(casadi = True)
    def test_ConstructVariableLaziness(self):
        model = self.load_model("AtomicModelVariableLaziness", modelFile)
        x2_eq = model.getDaeResidual()[0].getDep(1)
        x1_eq = model.getDaeResidual()[1].getDep(1)
        x1_var = model.getVariables(Model.DIFFERENTIATED)[0].getVar()
        x2_var = model.getVariables(Model.DIFFERENTIATED)[1].getVar()
        assert isEqual(x1_var, x1_eq) and isEqual(x2_var, x2_eq)

    @testattr(casadi = True)
    def test_ConstructArrayInOutFunction1(self):
        model = self.load_model("AtomicModelVector1", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelVector1.f
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @0 = (-@0)
            output[0] = @0
            @0 = input[1][0]
            @0 = (-@0)
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelVector1.f"), expected)
        expected = "@1=AtomicModelVector1.f(A[1], A[2]), vertcat((vertcat(temp_1[1], temp_1[2])-vertcat(@1{0}, @1{1})), (der(A[1])-temp_1[1]), (der(A[2])-temp_1[2]))"
        check_strnorm(model.getDaeResidual(), expected)

    @testattr(casadi = True)
    def test_ConstructArrayInOutFunction2(self):
        model = self.load_model("AtomicModelVector2", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelVector2.f
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = input[1][0]
            {@2, @3} = AtomicModelVector2.f2(@0, @1)
            output[0] = @2
            output[1] = @3
            """
        check_strnorm(model.getModelFunction("AtomicModelVector2.f"), expected)
        expected = "@1=AtomicModelVector2.f(A[1], A[2]), vertcat((vertcat(temp_1[1], temp_1[2])-vertcat(@1{0}, @1{1})), (der(A[1])-temp_1[1]), (der(A[2])-temp_1[2]))"
        check_strnorm(model.getDaeResidual(), expected)

    @testattr(casadi = True)
    def test_ConstructArrayInOutFunctionCallEquation(self):
        model = self.load_model("AtomicModelVector3", modelFile, compiler_options={"inline_functions":"none", "variability_propagation":False})
        expected = """
            ModelFunction : AtomicModelVector3.f
             Number of inputs: 4
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
              Input 2, a.k.a. "i2", 1-by-1 (dense), No description available
              Input 3, a.k.a. "i3", 1-by-1 (dense), No description available
             Number of outputs: 4
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @0 = (-@0)
            output[0] = @0
            @0 = input[1][0]
            @0 = (-@0)
            output[1] = @0
            @0 = input[2][0]
            @0 = (2.*@0)
            output[2] = @0
            @0 = input[3][0]
            @0 = (2.*@0)
            output[3] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelVector3.f"), expected)
        expected = "@1=AtomicModelVector3.f(A[1], A[2], 1, 2), (vertcat(A[1], A[2], B[1], B[2])-vertcat(@1{0}, @1{1}, @1{2}, @1{3}))"
        check_strnorm(model.getDaeResidual(), expected)

    @testattr(casadi = True)
    def test_FunctionCallEquationOmittedOuts(self):
        model = self.load_model("atomicModelFunctionCallEquationIgnoredOuts", modelFile, compiler_options={"inline_functions":"none", "variability_propagation":False})
        expected = "@1=atomicModelFunctionCallEquationIgnoredOuts.f(1, x3), vertcat((der(x2)-(x1+x2)), (vertcat(x1, x2)-vertcat(@1{0}, @1{2})))"
        check_strnorm(model.getDaeResidual(), expected)  

    @testattr(casadi = True)
    def test_FunctionCallStatementOmittedOuts(self):
        model = self.load_model("atomicModelFunctionCallStatementIgnoredOuts", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : atomicModelFunctionCallStatementIgnoredOuts.f2
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = 10
            @1 = input[0][0]
            {NULL, NULL, @2} = atomicModelFunctionCallStatementIgnoredOuts.f(@0, @1)
            output[0] = @2"""
        check_strnorm(model.getModelFunction("atomicModelFunctionCallStatementIgnoredOuts.f2"), expected)

    @testattr(casadi = True)
    def test_OmittedArrayRecordOuts(self):
        model = self.load_model("atomicModelFunctionCallStatementIgnoredArrayRecordOuts", modelFile, compiler_options={"inline_functions":"none"})
        expectedFunction = """
            ModelFunction : atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 6
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
              Output 4, a.k.a. "o4", 1-by-1 (dense), No description available
              Output 5, a.k.a. "o5", 1-by-1 (dense), No description available
            @0 = 10
            @1 = input[0][0]
            {@2, @3, @4, NULL, NULL, @5, @6, @7} = atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f(@0, @1)
            output[0] = @2
            output[1] = @3
            output[2] = @4
            output[3] = @5
            output[4] = @6
            output[5] = @7
            """
        expectedResidual = "@1=atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2(x1), (vertcat(x1, x2)-vertcat(@1{2}, @1{5}))"
        check_strnorm(model.getModelFunction("atomicModelFunctionCallStatementIgnoredArrayRecordOuts.f2"), expectedFunction)
        check_strnorm(model.getDaeResidual(), expectedResidual)

    @testattr(casadi = True)
    def test_ConstructFunctionMatrix(self):
        model = self.load_model("AtomicModelMatrix", modelFile, compiler_options={"inline_functions":"none","variability_propagation":False})
        expected = """ModelFunction : AtomicModelMatrix.f
             Number of inputs: 4
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
              Input 2, a.k.a. "i2", 1-by-1 (dense), No description available
              Input 3, a.k.a. "i3", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[2][0]
            output[0] = @0
            @0 = input[3][0]
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelMatrix.f"), expected)
        expected = "@1=AtomicModelMatrix.f(A[1,1], A[1,2], X[1,1], X[2,1]), @2=AtomicModelMatrix.f2(dx[1,1], dx[1,2], dx[2,1], dx[2,2]), vertcat((vertcat(temp_1[1,1], temp_1[1,2])-vertcat(@1{0}, @1{1})), (der(A[1,1])+temp_1[1,1]), (der(A[1,2])+temp_1[1,2]), (vertcat(temp_2[1,1], temp_2[1,2], temp_2[2,1], temp_2[2,2])-vertcat(@2{0}, @2{1}, @2{2}, @2{3})), (der(dx[1,1])+temp_2[1,1]), (der(dx[1,2])+temp_2[1,2]), (der(dx[2,1])+temp_2[2,1]), (der(dx[2,2])+temp_2[2,2]), (X[1,1]-0.1), (X[2,1]-0.3))"
        check_strnorm(model.getDaeResidual(), expected)

    @testattr(casadi = True)
    def test_ConstructFunctionMatrixDimsGreaterThanTwo(self):
        model = self.load_model("AtomicModelLargerThanTwoDimensionArray", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelLargerThanTwoDimensionArray.f
             Number of inputs: 6
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
              Input 2, a.k.a. "i2", 1-by-1 (dense), No description available
              Input 3, a.k.a. "i3", 1-by-1 (dense), No description available
              Input 4, a.k.a. "i4", 1-by-1 (dense), No description available
              Input 5, a.k.a. "i5", 1-by-1 (dense), No description available
             Number of outputs: 6
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
              Output 4, a.k.a. "o4", 1-by-1 (dense), No description available
              Output 5, a.k.a. "o5", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @0 = (-@0)
            output[0] = @0
            @0 = input[1][0]
            @0 = (-@0)
            output[1] = @0
            @0 = input[2][0]
            @0 = (-@0)
            output[2] = @0
            @0 = input[3][0]
            @0 = (-@0)
            output[3] = @0
            @0 = input[4][0]
            @0 = (-@0)
            output[4] = @0
            @0 = 10
            output[5] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelLargerThanTwoDimensionArray.f"), expected)
        expected = "@1=AtomicModelLargerThanTwoDimensionArray.f(A[1,1,1], A[1,1,2], A[1,1,3], A[1,2,1], A[1,2,2], A[1,2,3]), vertcat((vertcat(temp_1[1,1,1], temp_1[1,1,2], temp_1[1,1,3], temp_1[1,2,1], temp_1[1,2,2], temp_1[1,2,3])-vertcat(@1{0}, @1{1}, @1{2}, @1{3}, @1{4}, @1{5})), (der(A[1,1,1])-temp_1[1,1,1]), (der(A[1,1,2])-temp_1[1,1,2]), (der(A[1,1,3])-temp_1[1,1,3]), (der(A[1,2,1])-temp_1[1,2,1]), (der(A[1,2,2])-temp_1[1,2,2]), (der(A[1,2,3])-temp_1[1,2,3]))"
        check_strnorm(model.getDaeResidual(), expected)

    @testattr(casadi = True)
    def test_ConstructNestedRecordFunctions(self):
        model = self.load_model("AtomicModelRecordNestedArray",  modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelRecordNestedArray.generateCurves
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 8
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
              Output 4, a.k.a. "o4", 1-by-1 (dense), No description available
              Output 5, a.k.a. "o5", 1-by-1 (dense), No description available
              Output 6, a.k.a. "o6", 1-by-1 (dense), No description available
              Output 7, a.k.a. "o7", 1-by-1 (dense), No description available
            @0 = 0
            output[0] = @0
            @0 = input[0][0]
            output[1] = @0
            @0 = 2
            output[2] = @0
            @1 = 3
            output[3] = @1
            @2 = 6
            output[4] = @2
            @2 = 7
            output[5] = @2
            output[6] = @0
            output[7] = @1
            """        
        check_strnorm(model.getModelFunction("AtomicModelRecordNestedArray.generateCurves"), expected)
        expected ="@1=AtomicModelRecordNestedArray.generateCurves(a), vertcat((vertcat(compCurve.curves[1].path[1].point[1], compCurve.curves[1].path[1].point[2], compCurve.curves[1].path[2].point[1], compCurve.curves[1].path[2].point[2], compCurve.curves[2].path[1].point[1], compCurve.curves[2].path[1].point[2], compCurve.curves[2].path[2].point[1], compCurve.curves[2].path[2].point[2])-vertcat(@1{0}, @1{1}, @1{2}, @1{3}, @1{4}, @1{5}, @1{6}, @1{7})), (der(a)-compCurve.curves[1].path[1].point[2]))"
        check_strnorm(model.getDaeResidual(), expected)


    @testattr(casadi = True)
    def test_ConstructRecordInFunctionInFunction(self):
        model = self.load_model("AtomicModelRecordInOutFunctionCallStatement", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelRecordInOutFunctionCallStatement.f1
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = 2
            @1 = input[0][0]
            @0 = (@0+@1)
            {@2, @3} = AtomicModelRecordInOutFunctionCallStatement.f2(@1, @0)
            @2 = (@2*@3)
            output[0] = @2

            ModelFunction : AtomicModelRecordInOutFunctionCallStatement.f2
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = 10
            @1 = input[1][0]
            @0 = (@0*@1)
            output[1] = @0
            """
        funcStr = str(model.getModelFunction("AtomicModelRecordInOutFunctionCallStatement.f1")) + str(model.getModelFunction("AtomicModelRecordInOutFunctionCallStatement.f2"))
        check_strnorm(funcStr, expected)
        check_strnorm(model.getDaeResidual(), "(der(a)+AtomicModelRecordInOutFunctionCallStatement.f1(a){0})")



    @testattr(casadi = True)
    def test_ConstructRecordArbitraryDimension(self):
        model = self.load_model("AtomicModelRecordArbitraryDimension", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelRecordArbitraryDimension.f
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 8
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
              Output 4, a.k.a. "o4", 1-by-1 (dense), No description available
              Output 5, a.k.a. "o5", 1-by-1 (dense), No description available
              Output 6, a.k.a. "o6", 1-by-1 (dense), No description available
              Output 7, a.k.a. "o7", 1-by-1 (dense), No description available
            @0 = 1
            output[0] = @0
            @0 = 2
            output[1] = @0
            @0 = 3
            output[2] = @0
            @0 = 4
            output[3] = @0
            @0 = 5
            output[4] = @0
            @0 = 6
            output[5] = @0
            @0 = input[0][0]
            output[6] = @0
            @0 = (2.*@0)
            output[7] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelRecordArbitraryDimension.f"), expected)
        expected = "@1=AtomicModelRecordArbitraryDimension.f(a), vertcat((der(a)+a), (vertcat(r.A[1,1,1], r.A[1,1,2], r.A[1,2,1], r.A[1,2,2], r.A[2,1,1], r.A[2,1,2], r.A[2,2,1], r.A[2,2,2])-vertcat(@1{0}, @1{1}, @1{2}, @1{3}, @1{4}, @1{5}, @1{6}, @1{7})))"
        check_strnorm(model.getDaeResidual(), expected)



    @testattr(casadi = True)
    def test_ConstructArrayFlattening(self):
        model =  self.load_model("atomicModelSimpleArrayIndexing", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : atomicModelSimpleArrayIndexing.f
             Number of inputs: 0
             Number of outputs: 4
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
            @0 = 1
            output[0] = @0
            @0 = 2
            output[1] = @0
            @0 = 3
            output[2] = @0
            @0 = 4
            output[3] = @0
            """
        check_strnorm(model.getModelFunction("atomicModelSimpleArrayIndexing.f"), expected)

    @testattr(casadi = True)
    def test_ConstructRecordNestedSeveralVars(self):
        model = self.load_model("AtomicModelRecordSeveralVars", modelFile, compiler_options={"inline_functions":"none"})
        expected = """
            ModelFunction : AtomicModelRecordSeveralVars.f
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 10
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
              Output 2, a.k.a. "o2", 1-by-1 (dense), No description available
              Output 3, a.k.a. "o3", 1-by-1 (dense), No description available
              Output 4, a.k.a. "o4", 1-by-1 (dense), No description available
              Output 5, a.k.a. "o5", 1-by-1 (dense), No description available
              Output 6, a.k.a. "o6", 1-by-1 (dense), No description available
              Output 7, a.k.a. "o7", 1-by-1 (dense), No description available
              Output 8, a.k.a. "o8", 1-by-1 (dense), No description available
              Output 9, a.k.a. "o9", 1-by-1 (dense), No description available
            @0 = 1
            output[0] = @0
            @0 = 2
            output[1] = @0
            @0 = 3
            output[2] = @0
            @0 = 4
            output[3] = @0
            @0 = 5
            output[4] = @0
            @0 = 6
            output[5] = @0
            @0 = 7
            output[6] = @0
            @0 = 8
            output[7] = @0
            @0 = 9
            output[8] = @0
            @0 = input[0][0]
            output[9] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelRecordSeveralVars.f"), expected)
        expected = "@1=AtomicModelRecordSeveralVars.f(a), vertcat((der(a)+a), (vertcat(r.r1.A, r.r1.B, r.rArr[1].A, r.rArr[1].B, r.rArr[2].A, r.rArr[2].B, r.matrix[1,1], r.matrix[1,2], r.matrix[2,1], r.matrix[2,2])-vertcat(@1{0}, @1{1}, @1{2}, @1{3}, @1{4}, @1{5}, @1{6}, @1{7}, @1{8}, @1{9})))"
        check_strnorm(model.getDaeResidual(), expected)



    @testattr(casadi = True)
    def test_ConstructFunctionsInRhs(self):
        model = self.load_model("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"})
        expected = "@1=AtomicModelAtomicRealFunctions.monoInPolyOut(x2), @2=AtomicModelAtomicRealFunctions.polyInPolyOut(x1, x2), @3=AtomicModelAtomicRealFunctions.polyInPolyOutInternal(x9, x10), vertcat((der(x1)-sin(AtomicModelAtomicRealFunctions.monoInMonoOut(x1){0})), (der(x2)-AtomicModelAtomicRealFunctions.polyInMonoOut(x1, x2){0}), (vertcat(x3, x4)-vertcat(@1{0}, @1{1})), (vertcat(x5, x6)-vertcat(@2{0}, @2{1})), (der(x7)-AtomicModelAtomicRealFunctions.monoInMonoOutReturn(x7){0}), (der(x8)-AtomicModelAtomicRealFunctions.functionCallInFunction(x8){0}), (der(x9)-AtomicModelAtomicRealFunctions.functionCallEquationInFunction(x9){0}), (der(x10)-AtomicModelAtomicRealFunctions.monoInMonoOutInternal(x10){0}), (vertcat(x11, x12)-vertcat(@3{0}, @3{1})))"
        check_strnorm(model.getDaeResidual(), expected)


        model = self.load_model("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"})
        expected = "@1=AtomicModelAtomicIntegerFunctions.monoInPolyOut(u2), @2=AtomicModelAtomicIntegerFunctions.polyInPolyOut(u1, u2), @3=AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal(u1, u2), vertcat((x1-AtomicModelAtomicIntegerFunctions.monoInMonoOut(u1){0}), (x2-AtomicModelAtomicIntegerFunctions.polyInMonoOut(u1, u2){0}), (vertcat(x3, x4)-vertcat(@1{0}, @1{1})), (vertcat(x5, x6)-vertcat(@2{0}, @2{1})), (x7-AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn(u1){0}), (x8-AtomicModelAtomicIntegerFunctions.functionCallInFunction(u2){0}), (x9-AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction(u1){0}), (x10-AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal(u2){0}), (vertcat(x11, x12)-vertcat(@3{0}, @3{1})))"
        check_strnorm(model.getDaeResidual(), expected) 


        model = self.load_model("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"})
        expected = "@1=AtomicModelAtomicBooleanFunctions.monoInPolyOut(u2), @2=AtomicModelAtomicBooleanFunctions.polyInPolyOut(u1, u2), @3=AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal(u1, u2), vertcat((x1-AtomicModelAtomicBooleanFunctions.monoInMonoOut(u1){0}), (x2-AtomicModelAtomicBooleanFunctions.polyInMonoOut(u1, u2){0}), (vertcat(x3, x4)-vertcat(@1{0}, @1{1})), (vertcat(x5, x6)-vertcat(@2{0}, @2{1})), (x7-AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn(u1){0}), (x8-AtomicModelAtomicBooleanFunctions.functionCallInFunction(u2){0}), (x9-AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction(u1){0}), (x10-AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal(u2){0}), (vertcat(x11, x12)-vertcat(@3{0}, @3{1})))"
        check_strnorm(model.getDaeResidual(), expected) 



    @testattr(casadi = True)
    def test_ConstructVariousRealValuedFunctions(self):
        model = self.load_model("AtomicModelAtomicRealFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
        #function monoInMonoOut
            #input Real x
            #output Real y
        #algorithm
            #y := x
        #end monoInMonoOut
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.monoInMonoOut
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOut"), expected) 

        #function polyInMonoOut
            #input Real x1
            #input Real x2
            #output Real y
        #algorithm
            #y := x1+x2
        #end polyInMonoOut
        #end monoInMonoOut
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.polyInMonoOut
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = input[1][0]
            @0 = (@0+@1)
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInMonoOut"), expected) 

        #function monoInPolyOut
            #input Real x
            #output Real y1
            #output Real y2
        #algorithm
            #y1 := if(x > 2) then 1 else 5
            #y2 := x
        #end monoInPolyOut
        expected = ("""
            ModelFunction : AtomicModelAtomicRealFunctions.monoInPolyOut
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = 2
            @1 = input[0][0]
            @0 = (@0<@1)
""" +
#"@2 = if_else(@0,5,1)" +
"@2 = if_else(@0)" + # expecting this instead because of CasADi #1618
"""
            output[0] = @2
            output[1] = @1
""")
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInPolyOut"), expected)

        #function polyInPolyOut
            #input Real x1
            #input Real x2
            #output Real y1
            #output Real y2
        #algorithm
            #y1 := x1
            #y2 := x2
        #end polyInPolyOut
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.polyInPolyOut
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = input[1][0]
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInPolyOut"), expected)

        #function monoInMonoOutReturn
            #input Real x
            #output Real y
        #algorithm
            #y := x
            #return
            #y := 2*x
        #end monoInMonoOutReturn
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.monoInMonoOutReturn
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOutReturn"), expected)

        #function functionCallInFunction
            #input Real x
            #output Real y
        #algorithm
            #y := monoInMonoOut(x)
        #end functionCallInFunction
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.functionCallInFunction
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = AtomicModelAtomicRealFunctions.monoInMonoOut(@0)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.functionCallInFunction"), expected)

        #function functionCallEquationInFunction
            #input Real x
            #Real internal
            #output Real y
        #algorithm
            #(y,internal) := monoInPolyOut(x)
        #end functionCallEquationInFunction
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.functionCallEquationInFunction
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            {@1, NULL} = AtomicModelAtomicRealFunctions.monoInPolyOut(@0)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.functionCallEquationInFunction"), expected)

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
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.monoInMonoOutInternal
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = sin(@0)
            @1 = (@0*@1)
            @1 = sin(@1)
            @0 = (@0+@1)
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.monoInMonoOutInternal"), expected)

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
        expected = """
            ModelFunction : AtomicModelAtomicRealFunctions.polyInPolyOutInternal
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = 1
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicRealFunctions.polyInPolyOutInternal"), expected)


    @testattr(casadi = True)
    def test_ConstructVariousIntegerValuedFunctions(self):
        model = self.load_model("AtomicModelAtomicIntegerFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
        #function monoInMonoOut
            #input Integer x
            #output Integer y
        #algorithm
            #y := x
        #end monoInMonoOut
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.monoInMonoOut
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOut"), expected) 

        #function polyInMonoOut
            #input Integer x1
            #input Integer x2
            #output Integer y
        #algorithm
            #y := x1+x2
        #end polyInMonoOut
        #end monoInMonoOut
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.polyInMonoOut
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = input[1][0]
            @0 = (@0+@1)
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInMonoOut"), expected) 

        #function monoInPolyOut
            #input Integer x
            #output Integer y1
            #output Integer y2
        #algorithm
            #y1 := if(x > 2) then 1 else 5
            #y2 := x
        #end monoInPolyOut
        expected = ("""
            ModelFunction : AtomicModelAtomicIntegerFunctions.monoInPolyOut
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = 2
            @1 = input[0][0]
            @0 = (@0<@1)
""" +
#"@2 = if_else(@0,5,1)" +
"@2 = if_else(@0)" + # expecting this instead because of CasADi #1618
"""
            output[0] = @2
            output[1] = @1
""")
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInPolyOut"), expected)

        #function polyInPolyOut
            #input Integer x1
            #input Integer x2
            #output Integer y1
            #output Integer y2
        #algorithm
            #y1 := x1
            #y2 := x2
        #end polyInPolyOut
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.polyInPolyOut
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = input[1][0]
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInPolyOut"), expected)

        #function monoInMonoOutReturn
            #input Integer x
            #output Integer y
        #algorithm
            #y := x
            #return
            #y := 2*x
        #end monoInMonoOutReturn
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOutReturn"), expected)

        #function functionCallInFunction
            #input Integer x
            #output Integer y
        #algorithm
            #y := monoInMonoOut(x)
        #end functionCallInFunction
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.functionCallInFunction
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = AtomicModelAtomicIntegerFunctions.monoInMonoOut(@0)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.functionCallInFunction"), expected)

        #function functionCallEquationInFunction
            #input Integer x
            #Integer internal
            #output Integer y
        #algorithm
            #(y,internal) := monoInPolyOut(x)
        #end functionCallEquationInFunction
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            {@1, NULL} = AtomicModelAtomicIntegerFunctions.monoInPolyOut(@0)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.functionCallEquationInFunction"), expected)

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
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = 3
            @1 = input[0][0]
            @0 = (@0*@1)
            @0 = (@1*@0)
            @2 = 1
            @2 = (@2+@0)
            @1 = (@1+@2)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.monoInMonoOutInternal"), expected)

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
        expected = """
            ModelFunction : AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = 1
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicIntegerFunctions.polyInPolyOutInternal"), expected)


    @testattr(casadi = True)
    def test_ConstructVariousBooleanValuedFunctions(self):
        model = self.load_model("AtomicModelAtomicBooleanFunctions", modelFile, compiler_options={"inline_functions":"none"},compiler_log_level="e")
        #function monoInMonoOut
            #input Boolean x
            #output Boolean y
        #algorithm
            #y := x
        #end monoInMonoOut
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.monoInMonoOut
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0"""
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOut"), expected) 

        #function polyInMonoOut
            #input Boolean x1
            #input Boolean x2
            #output Boolean y
        #algorithm
            #y := x1 and x2
        #end polyInMonoOut
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.polyInMonoOut
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = input[1][0]
            @0 = (@0&&@1)
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInMonoOut"), expected) 

        #function monoInPolyOut
            #input Boolean x
            #output Boolean y1
            #output Boolean y2
        #algorithm
            #y1 := if(x) then false else (x or false)
            #y2 := x
        #end monoInPolyOut
        expected = ("""
            ModelFunction : AtomicModelAtomicBooleanFunctions.monoInPolyOut
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            """ +
            #"@1 = if_else(@0, 0, @0)" +
            "@1 = if_else(@0, @0)" + # expecting this instead because of CasADi #1618
            """
            output[0] = @1
            output[1] = @0
            """)
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInPolyOut"), expected)

        #function polyInPolyOut
            #input Boolean x1
            #input Boolean x2
            #output Boolean y1
            #output Boolean y2
        #algorithm
            #y1 := x1
            #y2 := x2
        #end polyInPolyOut
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.polyInPolyOut
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = input[1][0]
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInPolyOut"), expected)

        #function monoInMonoOutReturn
            #input Boolean x
            #output Boolean y
        #algorithm
            #y := x
            #return
            #y := x or false
        #end monoInMonoOutReturn
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOutReturn"), expected)

        #function functionCallInFunction
            #input Boolean x
            #output Boolean y
        #algorithm
            #y := monoInMonoOut(x)
        #end functionCallInFunction
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.functionCallInFunction
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @1 = AtomicModelAtomicBooleanFunctions.monoInMonoOut(@0)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.functionCallInFunction"), expected)

        #function functionCallEquationInFunction
            #input Boolean x
            #Boolean internal
            #output Boolean y
        #algorithm
            #(y,internal) := monoInPolyOut(x)
        #end functionCallEquationInFunction
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            {@1, NULL} = AtomicModelAtomicBooleanFunctions.monoInPolyOut(@0)
            output[0] = @1
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.functionCallEquationInFunction"), expected)

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
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal
             Number of inputs: 1
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
             Number of outputs: 1
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
            @0 = input[0][0]
            @0 = (@0&&@0)
            @1 = 0
            @1 = (@1||@0)
            @0 = 0
            @0 = (@0||@1)
            output[0] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.monoInMonoOutInternal"), expected)

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
        expected = """
            ModelFunction : AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal
             Number of inputs: 2
              Input 0, a.k.a. "i0", 1-by-1 (dense), No description available
              Input 1, a.k.a. "i1", 1-by-1 (dense), No description available
             Number of outputs: 2
              Output 0, a.k.a. "o0", 1-by-1 (dense), No description available
              Output 1, a.k.a. "o1", 1-by-1 (dense), No description available
            @0 = input[0][0]
            output[0] = @0
            @0 = 1
            output[1] = @0
            """
        check_strnorm(model.getModelFunction("AtomicModelAtomicBooleanFunctions.polyInPolyOutInternal"), expected)

    @testattr(casadi = True)
    def test_TransferVariableType(self):
        model = self.load_model("AtomicModelMisc", modelFile)
        x1 = model.getVariable('x1')
        assert isinstance(x1, RealVariable)
        assert isinstance(x1.getMyDerivativeVariable(), DerivativeVariable)
        assert isinstance(model.getVariable('x2'), IntegerVariable)
        assert isinstance(model.getVariable('x3'), BooleanVariable)
        assert isinstance(model.getVariable('x4'), BooleanVariable)

    @testattr(casadi = True)
    def test_ModelIdentifier(self):
        model = self.load_model("identifierTest.identfierTestModel", modelFile)
        assert model.getIdentifier().replace('\n','') ==\
               "identifierTest_identfierTestModel".replace('\n','')


class TestModelicaTransfer(ModelicaTransfer):
    """Modelica transfer tests that use transfer_model to load the model"""
    def load_model(self, *args, **kwargs):
        model = Model()
        transfer_model(model, *args, **kwargs)
        return model

class TestModelicaTransferOpt(ModelicaTransfer):
    """Modelica transfer tests that use transfer_model to load the model"""
    def load_model(self, *args, **kwargs):
        model = OptimizationProblem()
        transfer_model(model, *args, **kwargs)
        return model


##############################################
#                                            # 
#          OPTIMICA TRANSFER TESTS           #
#                                            #
##############################################

def computeStringRepresentationForContainer(myContainer):
    stringRepr = ""
    for index in range(len(myContainer)):
        stringRepr += str(myContainer[index])
    return stringRepr
    
    
@testattr(casadi = True)    
def test_OptimicaLessThanPathConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationLEQ", optproblemsFile)
    expected = str(x1.getName()) + " <= " + str(1)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints()), expected)

@testattr(casadi = True)
def test_OptimicaGreaterThanPathConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationGEQ", optproblemsFile)
    expected = str(x1.getName()) + " >= " + str(1)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints()), expected)
    
@testattr(casadi = True)    
def test_OptimicaSevaralPathConstraints():
    optProblem =  load_optimization_problem("atomicOptimizationGEQandLEQ", optproblemsFile)
    expected = str(x2.getName()) + " <= " + str(1) +  str(x1.getName()) + " >= " + str(1) 
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints()), expected)    

@testattr(casadi = True)
def test_OptimicaEqualityPointConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationEQpoint", optproblemsFile)
    expected = str(MX.sym("x1(finalTime)").getName()) + " = " + str(1)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints()), expected)
    
@testattr(casadi = True)    
def test_OptimicaLessThanPointConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationLEQpoint", optproblemsFile)
    expected = str(MX.sym("x1(finalTime)").getName()) + " <= " + str(1)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints()), expected)

@testattr(casadi = True)
def test_OptimicaGreaterThanPointConstraint():
    optProblem =  load_optimization_problem("atomicOptimizationGEQpoint", optproblemsFile)
    expected = str(MX.sym("x1(finalTime)").getName()) + " >= " + str(1)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints()), expected)
    
@testattr(casadi = True)    
def test_OptimicaSevaralPointConstraints():
    optProblem =  load_optimization_problem("atomicOptimizationGEQandLEQandEQpoint", optproblemsFile)
    expected = str(MX.sym("x2(startTime + 1)").getName()) + " <= " + str(1) +  str(MX.sym("x1(startTime + 1)").getName()) + " >= " + str(1) + str(MX.sym("x2(finalTime + 1)").getName()) + " = " + str(1)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints()), expected)
    
@testattr(casadi = True)    
def test_OptimicaMixedConstraints():
    optProblem =  load_optimization_problem("atomicOptimizationMixedConstraints", optproblemsFile)
    expectedPath = str(MX.sym("x3(startTime + 1)").getName()) + " <= " + str(x1.getName())
    expectedPoint =  str(MX.sym("x2(startTime + 1)").getName()) + " <= " + str(1) +  str(MX.sym("x1(startTime + 1)").getName()) + " >= " + str(1) 
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPathConstraints()), expectedPath)
    check_strnorm(computeStringRepresentationForContainer(optProblem.getPointConstraints()), expectedPoint)
    
@testattr(casadi = True)    
def test_OptimicaTimedVariables():
    optProblem =  load_optimization_problem("atomicOptimizationTimedVariables", optproblemsFile)
    # test there are 3 timed
    timedVars = optProblem.getTimedVariables()
    assert len(timedVars) == 4

    # test they contain model vars
    x1 = optProblem.getVariable("x1")
    x2 = optProblem.getVariable("x2")
    x3 = optProblem.getVariable("x3")

    assert x1 == timedVars[0].getBaseVariable()
    assert x2 == timedVars[1].getBaseVariable()
    assert x3 == timedVars[2].getBaseVariable()
    assert x1 == timedVars[3].getBaseVariable()
        
        
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

    assert isEqual(tp1.getDep(1), startTime.getVar())
    assert isEqual(tp2.getDep(1), startTime.getVar())
    assert isEqual(tp3.getDep(0), finalTime.getVar())
    assert isEqual(tp4, finalTime.getVar())

    assert isEqual(tv1, point_constraints[0].getLhs())
    assert isEqual(tv2, path_constraints[0].getLhs())
    assert isEqual(tv3, path_constraints[1].getLhs())
    assert isEqual(tv4, optProblem.getObjective())

@testattr(casadi = True)
def test_OptimicaStartTime():
    optProblem =  load_optimization_problem("atomicOptimizationStart5", optproblemsFile)
    assert( float(optProblem.getStartTime()) == 5)
    
@testattr(casadi = True)    
def test_OptimicaFinalTime():
    optProblem =  load_optimization_problem("atomicOptimizationFinal10", optproblemsFile)
    assert( float(optProblem.getFinalTime()) == 10)

@testattr(casadi = True)
def test_OptimicaObjectiveIntegrand():
    optProblem =  load_optimization_problem("atomicLagrangeX1", optproblemsFile)
    assert str(optProblem.getObjectiveIntegrand()) == str(x1) 
    optProblem =  load_optimization_problem("atomicLagrangeNull", optproblemsFile)
    assert str(optProblem.getObjectiveIntegrand()) == str(MX(0))  

@testattr(casadi = True)
def test_OptimicaObjective():
    optProblem =  load_optimization_problem("atomicMayerFinalTime", optproblemsFile)
    assert str(optProblem.getObjective()) == str(MX.sym("finalTime")) 
    optProblem =  load_optimization_problem("atomicMayerNull", optproblemsFile)
    assert str(optProblem.getObjective()) == str(MX(0))

@testattr(casadi = True)
def test_OptimicaFree():
    model =  load_optimization_problem("atomicWithFree", optproblemsFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str((diffs[0].getAttribute("free"))) == str(MX(False))

@testattr(casadi = True)
def test_OptimicaInitialGuess():
    model =  load_optimization_problem("atomicWithInitialGuess", optproblemsFile)
    diffs =  model.getVariables(Model.DIFFERENTIATED)
    assert str(diffs[0].getAttribute("initialGuess")) == str(MX(5))

@testattr(casadi = True)
def test_OptimicaNormalizedTimeFlag():
    optProblem = load_optimization_problem("atomicWithInitialGuess", optproblemsFile)
    assert optProblem.getNormalizedTimeFlag()
    optProblem = load_optimization_problem("atomicWithInitialGuess", optproblemsFile, compiler_options={"normalize_minimum_time_problems":True})
    assert optProblem.getNormalizedTimeFlag()
    optProblem = load_optimization_problem("atomicWithInitialGuess", optproblemsFile, compiler_options={"normalize_minimum_time_problems":False})
    assert not optProblem.getNormalizedTimeFlag()
    

@testattr(casadi = True)    
def test_ModelIdentifier():
    optProblem = load_optimization_problem("identifierTest.identfierTestModel", optproblemsFile)
    check_strnorm(optProblem.getIdentifier(), "identifierTest_identfierTestModel")
