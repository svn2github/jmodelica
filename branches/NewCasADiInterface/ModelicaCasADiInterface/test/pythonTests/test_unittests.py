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

from casadi_interface import *

""" 
As there is no function to check equality of variables this
function provides a substitute. Check that the MX of the kept variables
are equal and that the print of the variables are equal
"""
def heurestic_MC_variables_equal(MC_var1, MC_var2):
    return MC_var1.getVar().isEqual(MC_var2.getVar()) and str(MC_var1) == str(MC_var2)
    

def test_VariableAlias():
    realVar1 = RealVariable(MX("node1"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar2 = RealVariable(MX("node2"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    # Default values
    assert not realVar1.isAlias()
    assert realVar1.getAlias() == None
    assert not realVar1.isNegated()
    
    # Try to set negated attribute, even though it is not an alias variable yet. 
    import sys
    errorString = ""
    try:
        realVar1.setNegated(True)
    except:
        errorString = sys.exc_info()[1].message 
    assert errorString == "Only alias variables may be negated";
    
    
    # Make realVar1 an AliasVariables
    realVar1.setAlias(realVar2)
    # Check updated attributes, results of getters etc. 
    assert realVar1.isAlias()
    assert not realVar2.isAlias()
    assert heurestic_MC_variables_equal(realVar1.getAlias(), realVar2)
    assert not realVar1.isNegated()
    # Set negated, and check
    realVar1.setNegated(True)
    assert realVar1.isNegated()
    
    # Set and check attributes. 
    # Attributes that are set in an alias variable are propagated to its model variable. 
    # Attributes that are set in a model variable are accessed by its alias.
    anMX = MX("mx")
    realVar1.setAttribute("attr", anMX)
    assert realVar1.getAttribute("attr").isEqual(anMX)
    assert realVar2.getAttribute("attr").isEqual(anMX)
    anotherMX = MX("mx2")
    realVar2.setAttribute("anotherAttr", anotherMX)
    assert realVar1.getAttribute("anotherAttr").isEqual(anotherMX)
    assert realVar2.getAttribute("anotherAttr").isEqual(anotherMX)
    
    # Add the variables to a Model and make sure that the distinction between the 
    # function getVariableByName and getModelVariableByName works.
    model = Model()
    model.addVariable(realVar1)
    model.addVariable(realVar2)
    assert heurestic_MC_variables_equal(model.getVariableByName("node1"), realVar1)
    assert heurestic_MC_variables_equal(model.getVariableByName("node2"), realVar2)
    assert heurestic_MC_variables_equal(model.getModelVariableByName("node1"), realVar2)
    assert heurestic_MC_variables_equal(model.getModelVariableByName("node2"), realVar2)

def test_NegatedAliasAttributes():
    realVar1 = RealVariable(MX("node1"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar2 = RealVariable(MX("node2"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar3 = RealVariable(MX("node3"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar1.setAlias(realVar3)
    realVar2.setAlias(realVar3)
    realVar1.setNegated(True)
    attr1 = MX("attr1")
    attr2 = MX("attr2")
    attr3 = MX("attr3")
    attr4 = MX("attr4")

    # Set attributes affected by negation on model variable
    realVar3.setAttribute("min", attr1)
    realVar3.setAttribute("max", attr2)
    realVar3.setAttribute("start", attr3)
    realVar3.setAttribute("nominal", attr4)

    # Check correctness for negated and non-negated alias. 
    assert isEqual(realVar1.getAttribute("min"), -attr2)
    assert isEqual(realVar1.getAttribute("max"), -attr1)
    assert isEqual(realVar1.getAttribute("start"), -attr3)
    assert isEqual(realVar1.getAttribute("nominal"), -attr4)

    assert isEqual(realVar2.getAttribute("min"), attr1)
    assert isEqual(realVar2.getAttribute("max"), attr2)
    assert isEqual(realVar2.getAttribute("start"), attr3)
    assert isEqual(realVar2.getAttribute("nominal"), attr4)

    # Set attributes on negated alias
    realVar1.setAttribute("min", attr1)
    realVar1.setAttribute("max", attr2)
    realVar1.setAttribute("start", attr3)
    realVar1.setAttribute("nominal", attr4)

    # Check that the attributes are propagated correctly
    assert isEqual(realVar1.getAttribute("min"), attr1)
    assert isEqual(realVar1.getAttribute("max"), attr2)
    assert isEqual(realVar1.getAttribute("start"), attr3)
    assert isEqual(realVar1.getAttribute("nominal"), attr4)

    assert isEqual(realVar2.getAttribute("min"), -attr2)
    assert isEqual(realVar2.getAttribute("max"), -attr1)
    assert isEqual(realVar2.getAttribute("start"), -attr3)
    assert isEqual(realVar2.getAttribute("nominal"), -attr4)

    assert isEqual(realVar3.getAttribute("min"), -attr2)
    assert isEqual(realVar3.getAttribute("max"), -attr1)
    assert isEqual(realVar3.getAttribute("start"), -attr3)
    assert isEqual(realVar3.getAttribute("nominal"), -attr4)

def test_ModelAliasAndModelGetters():
    model = Model()
    realVar1 = RealVariable(MX("node1"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar2 = RealVariable(MX("node2"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar3 = RealVariable(MX("node3"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar1.setAlias(realVar3)
    realVar2.setAlias(realVar3)
    realVar1.setNegated(True)
    model.addVariable(realVar1)
    model.addVariable(realVar2)
    model.addVariable(realVar3)
    modelVars = model.getModelVariables()
    aliasVars = model.getAliasVariables()
    assert isEqual(modelVars[0].getVar(), realVar3.getVar())
    assert isEqual(aliasVars[0].getVar(), realVar1.getVar())
    assert isEqual(aliasVars[1].getVar(), realVar2.getVar())

def test_DependentParameters():
    a = MX("a")
    b = MX("b")
    c = MX("c")
    d = MX("d")
    funcVar = MX("funcVar")
    f = MXFunction([funcVar], [funcVar*2])
    f.init()
    
    
    eq1 = MX(10)
    eq2 = a + MX(2)
    eq3 = a*b
    eq4 = f.call([a])[0]
    
    r1 = RealVariable(a, MyVariable.INTERNAL, MyVariable.PARAMETER)
    r2 = RealVariable(b, MyVariable.INTERNAL, MyVariable.PARAMETER)
    r3 = RealVariable(c, MyVariable.INTERNAL, MyVariable.PARAMETER)
    r4 = RealVariable(d, MyVariable.INTERNAL, MyVariable.PARAMETER)
    
    r1.setAttribute("bindingExpression", eq1)
    r2.setAttribute("bindingExpression", eq2)
    r3.setAttribute("bindingExpression", eq3)
    r4.setAttribute("bindingExpression", eq4)
    
    model = Model()
    
    model.addVariable(r1)
    model.addVariable(r2)
    model.addVariable(r3)
    model.addVariable(r4)
    
    model.calculateValuesForDependentParameters()
    
    assert r2.getAttribute("evaluatedBindingExpression").getValue() == 12
    assert r3.getAttribute("evaluatedBindingExpression").getValue() == 120
    assert r4.getAttribute("evaluatedBindingExpression").getValue() == 20

def test_NumericalEvaluation():
    a = MX("a")
    b = MX("b")
    c = MX("c")
    d = MX("d")
    funcVar = MX("funcVar")
    f = MXFunction([funcVar], [funcVar*2])
    f.init()
    
    eq1 = MX(10)
    eq2 = a + MX(2)
    eq3 = a*b
    eq4 = f.call([a])[0]
    
    r1 = RealVariable(a, MyVariable.INTERNAL, MyVariable.PARAMETER)
    r2 = RealVariable(b, MyVariable.INTERNAL, MyVariable.PARAMETER)
    r3 = RealVariable(c, MyVariable.INTERNAL, MyVariable.PARAMETER)
    r4 = RealVariable(d, MyVariable.INTERNAL, MyVariable.PARAMETER)
    
    r1.setAttribute("bindingExpression", eq1)
    r2.setAttribute("bindingExpression", eq2)
    r2.setAttribute("max", a * 2);
    r3.setAttribute("bindingExpression", eq3)
    r3.setAttribute("start", b)
    r4.setAttribute("bindingExpression", eq4)
    r4.setAttribute("nominal", c);
    model = Model()
    
    model.addVariable(r1)
    model.addVariable(r2)
    model.addVariable(r3)
    model.addVariable(r4)
    
    assert model.evaluateExpression(r2.getAttribute("max")) == 20
    assert model.evaluateExpression(r3.getAttribute("start")) == 12
    assert model.evaluateExpression(r4.getAttribute("nominal")) == 120
    
    # Try to evaluate an expression that can't be evaluated using the information
    # in the Model. 
    import sys
    errorThrown = False # The exception string is platform dependent. 
    try:
        model.evaluateExpression(MX("notInTheModel"))
    except:
        errorThrown = True
    assert errorThrown
    
def test_equationGetter():
    lhs = MX("lhs")
    rhs = MX("rhs")
    eq = Equation(lhs, rhs)
    assert( isEqual(eq.getLhs(), lhs) )
    assert( isEqual(eq.getRhs(), rhs) )
    assert( isEqual(eq.getResidual(), rhs - lhs) )
    
def test_equationPrinting(): 
    eq = Equation(MX("lhs"), MX("rhs"));
    assert( str(eq) == "lhs = rhs" );

def test_RealTypePrinting():
    realType = RealType()
    expectedPrint = ("Real type (displayUnit = , fixed = 0, max = inf, min = -inf, nominal = 1, quantity = , start = 0, unit = );")
    assert( str(realType) == expectedPrint )
    assert( realType.getAttribute("start").getValue() == 0 )
    assert( realType.hasAttribute("quantity") )
    assert( not realType.hasAttribute("not") )
    assert( realType.getName() == "Real" )
    
def test_RealVariableAttributes():
    attributeNode1 = MX(1)
    attributeNode2 = MX(2)
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)

    realVar.setAttribute("myAttribute", attributeNode1)
    assert( isEqual(realVar.getAttribute("myAttribute"), attributeNode1) )
    realVar.setAttribute("myAttribute", attributeNode2)
    assert( isEqual(realVar.getAttribute("myAttribute"), attributeNode2) )
    assert( realVar.hasAttributeSet("myAttribute"))
    assert( not realVar.hasAttributeSet("iDontHaveThisAttribute"))
    assert( realVar.getName() == "node" )
    realVar.setAttribute("start", 1)
    assert( abs(realVar.getAttribute("start").getValue() - 1) < 0.000001)

def test_RealVariableConstants():
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    assert( realVar.getCausality() == MyVariable.INTERNAL )
    assert( realVar.getVariability() == MyVariable.CONTINUOUS )
    assert( realVar.getType() == MyVariable.REAL)
    assert( not realVar.isDerivative() )
    
def test_RealVariableNode():
    node = MX("var")
    realVar = RealVariable(node, MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    assert( isEqual(realVar.getVar(), node) )
    
def test_RealVariableVariableType():
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    assert( realVar.getDeclaredType() == None )
    realType = RealType()
    realVar.setDeclaredType(realType)
    # Has attribute looks at the variable. getAttribute gets the attribute even if it is in 
    # the declared type. 
    assert( (not realVar.hasAttributeSet("nominal")) and (realVar.getAttribute("nominal") is not None)) 
    assert( int(realType.this) == int(realVar.getDeclaredType().this) )
    userType = UserType("typeName", realType)
    realVar.setDeclaredType(userType)
    assert( int(userType.this) == int(realVar.getDeclaredType().this) )
    
def test_RealVariableDerivativeVariable():
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    derVar = DerivativeVariable(MX("node"), realVar)
    assert( realVar.getMyDerivativeVariable() == None )
    realVar.setMyDerivativeVariable(derVar)
    assert( int(realVar.getMyDerivativeVariable().this) == int(derVar.this) )

def test_RealVariableNonSymbolicError():
    import sys
    errorString = ""
    try:
        realVar = RealVariable(MX(1), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "A variable must have a symbolic MX");
    
def test_RealVariableInvalidDerivativeVariable():
    import sys
    realVar1 = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar2 = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    notARealVariable = IntegerVariable(MX("node"), MyVariable.INPUT, MyVariable.DISCRETE)
    errorString = ""
    try:
        realVar1.setMyDerivativeVariable(notARealVariable)
    except:
        errorString = sys.exc_info()[1].message 
    print errorString
    assert(errorString == "A Variable that is set as a derivative variable must be a DerivativeVariable");
    
    errorString = ""
    try:
        realVar1.setMyDerivativeVariable(realVar2)
    except:
        errorString = sys.exc_info()[1].message 
    print errorString
    assert(errorString == "A Variable that is set as a derivative variable must be a DerivativeVariable");
    
def test_RealVariableInvalidAsStateVariable():
    import sys
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    derVar = DerivativeVariable(MX("node"), None)
    
    errorString = ""
    try:
        realVar.setMyDerivativeVariable(derVar)
    except:
        errorString = sys.exc_info()[1].message 
    print errorString
    assert(errorString == "A RealVariable that is a state variable must have continuous variability, and may not be a derivative variable.");
    
def test_RealVariablePrinting():
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar.setAttribute("myAttribute", MX(2))
    assert( str(realVar) == "Real node(myAttribute = 2);" );
    
def test_DerivativeVariableAttributes():
    attributeNode1 = MX(1)
    attributeNode2 = MX(2)
    derVar = DerivativeVariable(MX("node"), None)

    derVar.setAttribute("myAttribute", attributeNode1)
    assert( isEqual(derVar.getAttribute("myAttribute"), attributeNode1) )
    derVar.setAttribute("myAttribute", attributeNode2)
    assert( isEqual(derVar.getAttribute("myAttribute"), attributeNode2) )
    assert( derVar.hasAttributeSet("myAttribute"))
    assert( not derVar.hasAttributeSet("iDontHaveThisAttribute"))
    assert( derVar.getName() == "node" )

def test_DerivativeVariableConstants():
    derVar = DerivativeVariable(MX("node"), None)
    assert( derVar.getCausality() == MyVariable.INTERNAL )
    assert( derVar.getVariability() == MyVariable.CONTINUOUS )
    assert( derVar.getType() == MyVariable.REAL)
    assert( derVar.isDerivative() )

def test_DerivativeVariableNode():
    node = MX("var")
    derVar = DerivativeVariable(node, None)
    assert( isEqual(derVar.getVar(), node) )
    
def test_DerivativeVariableVariableType():
    derVar = DerivativeVariable(MX("node"), None)
    assert( derVar.getDeclaredType() == None )
    realType = RealType()
    derVar.setDeclaredType(realType)
    assert( int(realType.this) == int(derVar.getDeclaredType().this) )
    userType = UserType("typeName", realType)
    derVar.setDeclaredType(userType)
    assert( int(userType.this) == int(derVar.getDeclaredType().this) )
    
def test_DerivativeVariableDifferentiatedVariable():
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    derVar = DerivativeVariable(MX("node"), realVar)
    #assert( int(derVar.getMyDifferentiatedVariable().this) == int(realVar.this) )

def test_DerivativeVariableInvalidStateVariable():
    import sys
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    intVar = IntegerVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    
    errorString = ""
    try:
        derVar = DerivativeVariable(MX("node"), realVar)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "A state variable must have real type and continuous variability");
    errorString = ""
    try:
        derVar = DerivativeVariable(MX("node"), intVar)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "A state variable must have real type and continuous variability");

def test_DerivativeVariablePrinting():
    derVar = DerivativeVariable(MX("node"), None)
    derVar.setAttribute("myAttribute", MX(2))
    assert( str(derVar) == "Real node(myAttribute = 2);" )

def test_IntegerVariableAttributes():
    attributeNode1 = MX(1)
    attributeNode2 = MX(2)
    intVar = IntegerVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)

    intVar.setAttribute("myAttribute", attributeNode1)
    assert( isEqual(intVar.getAttribute("myAttribute"), attributeNode1) )
    intVar.setAttribute("myAttribute", attributeNode2)
    assert( isEqual(intVar.getAttribute("myAttribute"), attributeNode2) )
    assert( intVar.hasAttributeSet("myAttribute"))
    assert( not intVar.hasAttributeSet("iDontHaveThisAttribute"))
    assert( intVar.getName() == "node")
    
def test_IntegerVariableConstants():
    intVar = IntegerVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    assert( intVar.getCausality() == MyVariable.INTERNAL )
    assert( intVar.getVariability() == MyVariable.DISCRETE )
    assert( intVar.getType() == MyVariable.INTEGER)

def test_IntegerVariableNode():
    node = MX("var")
    intVar = IntegerVariable(node, MyVariable.INTERNAL, MyVariable.DISCRETE)
    assert( isEqual(intVar.getVar(), node) )
    
def test_IntegerVariableVariableType():
    intVar = IntegerVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    assert( intVar.getDeclaredType() == None )
    intType = IntegerType()
    intVar.setDeclaredType(intType)
    assert( int(intType.this) == int(intVar.getDeclaredType().this) )
    userType = UserType("typeName", intType)
    intVar.setDeclaredType(userType)
    assert( int(userType.this) == int(intVar.getDeclaredType().this) )
   
def test_IntegerVariablePrinting():
    intVar = IntegerVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    intVar.setAttribute("myAttribute", MX(2))
    assert( str(intVar) == "Discrete Integer node(myAttribute = 2);" )
    
def test_IntegerVariableContinuousError():
    import sys
    errorString = ""
    try:
        intVar = IntegerVariable(MX("var"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "An integer variable can not have continuous variability");
    
def test_BooleanVariableAttributes():
    attributeNode1 = MX(1)
    attributeNode2 = MX(2)
    boolVar = BooleanVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)

    boolVar.setAttribute("myAttribute", attributeNode1)
    assert( isEqual(boolVar.getAttribute("myAttribute"), attributeNode1) )
    boolVar.setAttribute("myAttribute", attributeNode2)
    assert( isEqual(boolVar.getAttribute("myAttribute"), attributeNode2) )
    assert( boolVar.hasAttributeSet("myAttribute"))
    assert( not boolVar.hasAttributeSet("iDontHaveThisAttribute"))
    assert( boolVar.getName() == "node")
    
def test_BooleanVariableConstants():
    boolVar = BooleanVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    assert( boolVar.getCausality() == MyVariable.INTERNAL )
    assert( boolVar.getVariability() == MyVariable.DISCRETE )
    assert( boolVar.getType() == MyVariable.BOOLEAN)

def test_BooleanVariableNode():
    node = MX("var")
    boolVar = BooleanVariable(node, MyVariable.INTERNAL, MyVariable.DISCRETE)
    assert( isEqual(boolVar.getVar(), node) )
    
def test_BooleanVariableVariableType():
    boolVar = BooleanVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    assert( boolVar.getDeclaredType() == None )
    boolType = BooleanType()
    boolVar.setDeclaredType(boolType)
    assert( int(boolType.this) == int(boolVar.getDeclaredType().this) )
    userType = UserType("typeName", boolType)
    boolVar.setDeclaredType(userType)
    assert( int(userType.this) == int(boolVar.getDeclaredType().this) )
    
def test_BooleanVariableContinuousError():
    import sys
    errorString = ""
    try:
        boolVar = BooleanVariable(MX("var"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "A boolean variable can not have continuous variability");
    
def test_BooleanVariablePrinting():
    boolVar = BooleanVariable(MX("node"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    boolVar.setAttribute("myAttribute", MX(2))
    assert( str(boolVar) == "Discrete Boolean node(myAttribute = 2);" )
    
def test_ModelFunctionGetName():
    funcVar = MX("node")
    functionName = "myFunction"
    function = MXFunction([funcVar],[funcVar+2])
    function.setOption("name", functionName)
    function.init()
    modelFunction = ModelFunction(function)
    assert( modelFunction.getName() == functionName )

def test_ModelFunctionGetNameCall():
    funcVar = MX("node")
    functionName = "myFunction"
    function = MXFunction([funcVar],[funcVar+2])
    function.setOption("name", functionName)
    function.init()
    modelFunction = ModelFunction(function)
    arg = MX("arg")
    manualCall = function.call([arg])[0]
    assert( isEqual( modelFunction.call([arg])[0].getDep(0).getDep(0),arg) )
    assert( str(manualCall) == str(modelFunction.call([arg])[0]) )

def test_ModelFunctionCallAndUse():
    funcVar = MX("node")
    functionName = "myFunction"
    function = MXFunction([funcVar],[funcVar+2])
    function.setOption("name", functionName)
    function.init()
    modelFunction = ModelFunction(function)
    arg = MX("arg")
    call = modelFunction.call([arg])[0]
    evaluateCall = MXFunction([arg], [call])
    evaluateCall.init()
    evaluateCall.setInput(0.0)
    evaluateCall.evaluate()        
    assert( evaluateCall.output().elem(0) == 2 )
    
def test_ModelFunctionPrinting():
    funcVar = MX("node")
    functionName = "myFunction"
    function = MXFunction([funcVar],[funcVar+2])
    function.setOption("name", functionName)
    function.init()
    modelFunction = ModelFunction(function)
    expectedPrint = ("ModelFunction : function(\"myFunction\")\n" +
                    " Input: 1-by-1 (dense)\n" +
                    " Output: 1-by-1 (dense)\n" +
                    "@0 = 2\n" +
                    "@1 = input[0]\n" +
                    "@0 = (@0+@1)\n" +
                    "output[0] = @0\n")
    assert( str(modelFunction) == expectedPrint )

def test_Constraint():
    lhs = MX("lhs")
    rhs = MX("rhs")
    equalityConstraint = Constraint(lhs, rhs, Constraint.EQ)
    lessThanConstraint = Constraint(lhs, rhs, Constraint.LEQ)
    greaterThanConstraint = Constraint(lhs, rhs, Constraint.GEQ)
    
    # Equality constraint
    assert( isEqual(equalityConstraint.getLhs(), lhs) )
    assert( isEqual(equalityConstraint.getRhs(), rhs) )
    assert( isEqual(equalityConstraint.getResidual(), rhs - lhs) )
    assert( equalityConstraint.getType() == Constraint.EQ)
    # Less than or equal to constraint
    assert( isEqual(lessThanConstraint.getLhs(), lhs) )
    assert( isEqual(lessThanConstraint.getRhs(), rhs) )
    assert( isEqual(equalityConstraint.getResidual(), rhs - lhs) )
    assert( lessThanConstraint.getType() == Constraint.LEQ )
    # Greater than or equal to constraint
    assert( isEqual(greaterThanConstraint.getLhs(), lhs) )
    assert( isEqual(greaterThanConstraint.getRhs(), rhs) )
    assert( isEqual(greaterThanConstraint.getResidual(), rhs - lhs) )
    assert( greaterThanConstraint.getType() == Constraint.GEQ )

def test_ConstraintPrinting():
    lhs = MX("lhs")
    rhs = MX("rhs")
    equalityConstraint = Constraint(lhs, rhs, Constraint.EQ)
    lessThanConstraint = Constraint(lhs, rhs, Constraint.LEQ)
    greaterThanConstraint = Constraint(lhs, rhs, Constraint.GEQ)
    actual = str(equalityConstraint) + str(lessThanConstraint) + str(greaterThanConstraint)
    assert( actual == "lhs == rhslhs <= rhslhs >= rhs" )

def test_OptimizationProblemConstructors():
    model = Model()
    constraintsEmpty = ConstraintVector()
    optBothMayerAndLagrange = OptimizationProblem(model, constraintsEmpty, MX(0), MX(0), MX(0), MX(0))
    optOnlyLagrange = OptimizationProblem(model, constraintsEmpty, MX(0), MX(0), MX(0))
    optNeitherLagrangreOrMayer = OptimizationProblem(model, constraintsEmpty, MX(0), MX(0))

    assert( int(model.this) == int(optBothMayerAndLagrange.getModel().this) )
    assert( int(model.this) == int(optOnlyLagrange.getModel().this) )
    assert( int(model.this) == int(optNeitherLagrangreOrMayer.getModel().this) )

def test_OptimizationProblemTime():
    start = MX (0)
    final = MX(1)
    constraintsEmpty = ConstraintVector()
    model = Model()
    optBothMayerAndLagrange = OptimizationProblem(model, constraintsEmpty, start, final, MX(0), MX(0))
    optOnlyLagrange = OptimizationProblem(model, constraintsEmpty, start, final, MX(0))
    optNeitherLagrangreOrMayer = OptimizationProblem(model, constraintsEmpty, start, final)

    assert( isEqual(start, optBothMayerAndLagrange.getStartTime()) )
    assert( isEqual(final, optBothMayerAndLagrange.getFinalTime()) )
    assert( isEqual(start, optOnlyLagrange.getStartTime()) )
    assert( isEqual(final, optOnlyLagrange.getFinalTime()) )
    assert( isEqual(start, optNeitherLagrangreOrMayer.getStartTime()) )
    assert( isEqual(final, optNeitherLagrangreOrMayer.getFinalTime()) )
    # Set and check
    start = MX(2)
    final = MX(4)
    optBothMayerAndLagrange.setStartTime(start)
    optBothMayerAndLagrange.setFinalTime(final)
    assert( isEqual(start, optBothMayerAndLagrange.getStartTime()) )
    assert( isEqual(final, optBothMayerAndLagrange.getFinalTime()) )
    
def test_OptimizationProblemLagrangeMayer():
    lagrange = MX("lagrange")
    mayer = MX("mayer")
    constraintsEmpty = ConstraintVector()
    model = Model()
    optBothMayerAndLagrange = OptimizationProblem(model, constraintsEmpty,  MX(0),  MX(0), lagrange, mayer)
    optOnlyLagrange = OptimizationProblem(model, constraintsEmpty,  MX(0),  MX(0), lagrange)
    optNeitherLagrangreOrMayer = OptimizationProblem(model, constraintsEmpty,  MX(0),  MX(0))

    assert( isEqual(lagrange, optBothMayerAndLagrange.getLagrangeTerm()) )
    assert( isEqual(mayer, optBothMayerAndLagrange.getMayerTerm()) )
    assert( isEqual(lagrange, optOnlyLagrange.getLagrangeTerm()) )
    assert( optOnlyLagrange.getMayerTerm().getValue() == 0 )
    assert( optNeitherLagrangreOrMayer.getLagrangeTerm().getValue() == 0 )
    assert( optNeitherLagrangreOrMayer.getMayerTerm().getValue() == 0 )
    # Set and check
    optNeitherLagrangreOrMayer.setMayerTerm(mayer)
    optNeitherLagrangreOrMayer.setLagrangeTerm(lagrange)
    assert( isEqual(lagrange, optNeitherLagrangreOrMayer.getLagrangeTerm()) )
    assert( isEqual(mayer, optNeitherLagrangreOrMayer.getMayerTerm()) )

def test_OptimizationProblemConstraints():
    constraintsEmpty = ConstraintVector()
    constraintsLessThan = ConstraintVector()
    constraintsGreaterThan = ConstraintVector()
    lhs = MX("lhs")
    rhs = MX("rhs")
    lessThanConstraint = Constraint(lhs, rhs, Constraint.LEQ)
    greaterThanConstraint = Constraint(lhs, rhs, Constraint.GEQ)
    constraintsLessThan.push_back(lessThanConstraint)
    constraintsGreaterThan.push_back(greaterThanConstraint)
    
    model = Model()
    
    optBothMayerAndLagrange = OptimizationProblem(model, constraintsEmpty, MX(0), MX(0), MX(0), MX(0))
    optOnlyLagrange = OptimizationProblem(model, constraintsLessThan, MX(0), MX(0), MX(0))
    optNeitherLagrangreOrMayer = OptimizationProblem(model, constraintsGreaterThan, MX(0), MX(0))
    
    assert( len(optBothMayerAndLagrange.getPathConstraints()) == 0 )
    assert( isEqual(optOnlyLagrange.getPathConstraints()[0].getResidual(), lessThanConstraint.getResidual()) )
    assert( isEqual(optNeitherLagrangreOrMayer.getPathConstraints()[0].getResidual(), greaterThanConstraint.getResidual()) )
    # Set and check
    optBothMayerAndLagrange.setPathConstraint(constraintsLessThan)
    assert( isEqual(optBothMayerAndLagrange.getPathConstraints()[0].getResidual(), lessThanConstraint.getResidual()) )

def test_OptimizationProblemPrinting():
    constraintsEmpty = ConstraintVector()
    model = Model()
    simpleOptProblem = OptimizationProblem(model, constraintsEmpty, MX(0), MX(1))
    expectedPrint = ("Model contained in OptimizationProblem:\n\n" +
                     "------------------------------- Variables -------------------------------\n\n\n" +
                     "---------------------------- Variable types  ----------------------------\n\n\n" +
                     "------------------------------- Functions -------------------------------\n\n\n" +
                     "------------------------------- Equations -------------------------------\n\n\n" +
                     "-- Optimization information  --\n\n" +
                     "Start time = 0\n\nFinal time = 1\n" +
                     "-- Lagrange term --\n0\n-- Mayer term --\n0")
    print simpleOptProblem
    assert( str(simpleOptProblem) == expectedPrint )

def test_ModelVariableKindsEmpty():
    model = Model()
    for kind in range(Model.NUM_OF_VARIABLE_KIND):
        assert( len(model.getVariableByKind(kind)) == 0)

def test_ModelVariableSorting():
    model = Model()
    var1 = MX("node1")
    var2 = MX("node2")
    
    def checkVariablesEqualToInOrder(varTuple, varVec):
        for i in range(len(varTuple)):
            assert( int(varTuple[i].this) == int(varVec[i].this))
    def addVariableVectorToModel(varVec, model):
        for i in range(len(varVec)):
            model.addVariable(varVec[i])
    
    #Create different kinds of variables
    outputVariables = MyVariableVector()
    inputRealVariables = MyVariableVector()
    inputIntegerVariables = MyVariableVector()
    inputBooleanVariables = MyVariableVector()
    algebraicVariables = MyVariableVector()
    differentiatedVariables = MyVariableVector()
    derivativeVariables = MyVariableVector()
    discreteRealVariables = MyVariableVector()
    discreteIntegerVariables = MyVariableVector()
    discreteBooleanVariables = MyVariableVector()
    constantRealVariables = MyVariableVector()
    constantIntegerVariables = MyVariableVector()
    constantBooleanVariables = MyVariableVector()
    indepenentRealParameterVariables = MyVariableVector()
    depenentRealParameterVariables = MyVariableVector()
    indepenentIntegerParameterVariables = MyVariableVector()
    depenentIntegerParameterVariables = MyVariableVector()
    indepenentBooleanParameterVariables = MyVariableVector()
    depenentBooleanParameterVariables = MyVariableVector()
    
    # Real variables
    rIn1 = RealVariable(var1, MyVariable.INPUT, MyVariable.CONTINUOUS)
    rIn2 = RealVariable(var1, MyVariable.INPUT, MyVariable.DISCRETE)
    rIn3 = RealVariable(var1, MyVariable.INPUT, MyVariable.PARAMETER)
    rIn4 = RealVariable(var1, MyVariable.INPUT, MyVariable.CONSTANT)
    rOut1 = RealVariable(var1, MyVariable.OUTPUT, MyVariable.CONTINUOUS)
    rOut2 = RealVariable(var1, MyVariable.OUTPUT, MyVariable.DISCRETE)
    rOut3 = RealVariable(var1, MyVariable.OUTPUT, MyVariable.PARAMETER)
    rOut4 = RealVariable(var1, MyVariable.OUTPUT, MyVariable.CONSTANT)
    inputRealVariables.push_back(rIn1)
    inputRealVariables.push_back(rIn2)
    inputRealVariables.push_back(rIn3)
    inputRealVariables.push_back(rIn4)
    outputVariables.push_back(rOut1)
    outputVariables.push_back(rOut2)
    outputVariables.push_back(rOut3)
    outputVariables.push_back(rOut4)
    
    rAlg = RealVariable(var1,  MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    algebraicVariables.push_back(rAlg)
    
    rDiff = RealVariable(var1,  MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    differentiatedVariables.push_back(rDiff)
    rDer = DerivativeVariable(var1, rDiff)
    derivativeVariables.push_back(rDer)
    rDisc = RealVariable(var1,  MyVariable.INTERNAL, MyVariable.DISCRETE)
    discreteRealVariables.push_back(rDisc)
    rConst = RealVariable(var1,  MyVariable.INTERNAL, MyVariable.CONSTANT)
    constantRealVariables.push_back(rConst)
    rIndep = RealVariable(var1,  MyVariable.INTERNAL, MyVariable.PARAMETER)
    indepenentRealParameterVariables.push_back(rIndep)
    rDep =  RealVariable(var1,  MyVariable.INTERNAL, MyVariable.PARAMETER)
    rDep.setAttribute("bindingExpression", var2)
    depenentRealParameterVariables.push_back(rDep)
    
    
    # Integer variables
    iIn1 = IntegerVariable(var1, MyVariable.INPUT, MyVariable.DISCRETE)
    iIn2 = IntegerVariable(var1, MyVariable.INPUT, MyVariable.PARAMETER)
    iIn3 = IntegerVariable(var1, MyVariable.INPUT, MyVariable.CONSTANT)
    iOut1 = IntegerVariable(var1, MyVariable.OUTPUT, MyVariable.DISCRETE)
    iOut2 = IntegerVariable(var1, MyVariable.OUTPUT, MyVariable.PARAMETER)
    iOut3 = IntegerVariable(var1, MyVariable.OUTPUT, MyVariable.CONSTANT)
    inputIntegerVariables.push_back(iIn1)
    inputIntegerVariables.push_back(iIn2)
    inputIntegerVariables.push_back(iIn3)
    outputVariables.push_back(iOut1)
    outputVariables.push_back(iOut2)
    outputVariables.push_back(iOut3)
    
    iDisc = IntegerVariable(var1,  MyVariable.INTERNAL, MyVariable.DISCRETE)
    discreteIntegerVariables.push_back(iDisc)
    iConst = IntegerVariable(var1,  MyVariable.INTERNAL, MyVariable.CONSTANT)
    constantIntegerVariables.push_back(iConst)
    iIndep = IntegerVariable(var1,  MyVariable.INTERNAL, MyVariable.PARAMETER)
    indepenentIntegerParameterVariables.push_back(iIndep)
    iDep = IntegerVariable(var1,  MyVariable.INTERNAL, MyVariable.PARAMETER)
    iDep.setAttribute("bindingExpression", var2)
    depenentIntegerParameterVariables.push_back(iDep)
    
    
    # Boolean variables
    bIn1 = BooleanVariable(var1, MyVariable.INPUT, MyVariable.DISCRETE)
    bIn2 = BooleanVariable(var1, MyVariable.INPUT, MyVariable.PARAMETER)
    bIn3 = BooleanVariable(var1, MyVariable.INPUT, MyVariable.CONSTANT)
    bOut1 = BooleanVariable(var1, MyVariable.OUTPUT, MyVariable.DISCRETE)
    bOut2 = BooleanVariable(var1, MyVariable.OUTPUT, MyVariable.PARAMETER)
    bOut3 = BooleanVariable(var1, MyVariable.OUTPUT, MyVariable.CONSTANT)
    inputBooleanVariables.push_back(bIn1)
    inputBooleanVariables.push_back(bIn2)
    inputBooleanVariables.push_back(bIn3)
    outputVariables.push_back(bOut1)
    outputVariables.push_back(bOut2)
    outputVariables.push_back(bOut3)
    
    bDisc = BooleanVariable(var1,  MyVariable.INTERNAL, MyVariable.DISCRETE)
    bConst = BooleanVariable(var1,  MyVariable.INTERNAL, MyVariable.CONSTANT)
    discreteBooleanVariables.push_back(bDisc)
    constantBooleanVariables.push_back(bConst)
    bIndep = BooleanVariable(var1,  MyVariable.INTERNAL, MyVariable.PARAMETER)
    bDep = BooleanVariable(var1,  MyVariable.INTERNAL, MyVariable.PARAMETER)
    indepenentBooleanParameterVariables.push_back(bIndep)
    bDep.setAttribute("bindingExpression", var2)
    depenentBooleanParameterVariables.push_back(bDep)
    
    
    
    
    # Add differentiated variable, but without its corresponding derivative variable
    # => should be sorted as algebraic. Then add derivative variable and check again
    addVariableVectorToModel(differentiatedVariables, model)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_ALGEBRAIC), differentiatedVariables)
    addVariableVectorToModel(derivativeVariables, model)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.DIFFERENTIATED), differentiatedVariables) 
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.DERIVATIVE), derivativeVariables) 
    
    # Add the rest of the variables and check that they are sorted correctly
    addVariableVectorToModel(outputVariables, model)
    addVariableVectorToModel(inputRealVariables, model)
    addVariableVectorToModel(inputIntegerVariables, model)
    addVariableVectorToModel(inputBooleanVariables, model)
    addVariableVectorToModel(algebraicVariables, model)
    addVariableVectorToModel(discreteRealVariables, model)
    addVariableVectorToModel(discreteIntegerVariables, model)
    addVariableVectorToModel(discreteBooleanVariables, model)
    addVariableVectorToModel(constantRealVariables, model)
    addVariableVectorToModel(constantIntegerVariables, model)
    addVariableVectorToModel(constantBooleanVariables, model)
    addVariableVectorToModel(indepenentRealParameterVariables, model)
    addVariableVectorToModel(indepenentIntegerParameterVariables, model)
    addVariableVectorToModel(indepenentBooleanParameterVariables, model)
    addVariableVectorToModel(depenentRealParameterVariables, model)
    addVariableVectorToModel(depenentIntegerParameterVariables, model)
    addVariableVectorToModel(depenentBooleanParameterVariables, model)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.OUTPUT), outputVariables) 
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_INPUT), inputRealVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.INTEGER_INPUT), inputIntegerVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.BOOLEAN_INPUT), inputBooleanVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_ALGEBRAIC), algebraicVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.DIFFERENTIATED), differentiatedVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.DERIVATIVE), derivativeVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_DISCRETE), discreteRealVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.INTEGER_DISCRETE), discreteIntegerVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.BOOLEAN_DISCRETE), discreteBooleanVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_CONSTANT), constantRealVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.INTEGER_CONSTANT), constantIntegerVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.BOOLEAN_CONSTANT), constantBooleanVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_PARAMETER_INDEPENDENT), indepenentRealParameterVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.INTEGER_PARAMETER_INDEPENDENT), indepenentIntegerParameterVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.BOOLEAN_PARAMETER_INDEPENDENT), indepenentBooleanParameterVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.REAL_PARAMETER_DEPENDENT), depenentRealParameterVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.INTEGER_PARAMETER_DEPENDENT), depenentIntegerParameterVariables)
    checkVariablesEqualToInOrder(model.getVariableByKind(Model.BOOLEAN_PARAMETER_DEPENDENT), depenentBooleanParameterVariables)

def test_ModelEqutionFunctionality():
    model = Model()
    var1 = MX("var1")
    var2 = MX("var2")
    var3 = MX("var3")
    var4 = MX("var4")
    res1 = var2 - var1
    res2 = var4 - var3
    eq1 = Equation(var1, var2)
    eq2 = Equation(var3, var4)

    # Should return an MX with a null node (default MX value 
    # for default/empty constructor), if there are no equations
    assert( model.getDaeResidual().isNull() )
     # Add equations and check residuals
    model.addDaeEquation(eq1)
    model.addDaeEquation(eq2)
    model.addInitialEquation(eq1)
    assert( isEqual(res1, model.getInitialResidual()) )
    # Also test residuals with more than one residual equation
    res1.append(res2)
    # isEqual in the casadi namespace gives a false negative 
    # (which is warned for in the casadi source) if used, 
    # so MX.isEqual is used instead.
    assert( res1.isEqual(model.getDaeResidual(), 2) )

def test_ModelWithModelFunction():
    model = Model()
    funcVar = MX("node")
    functionName = "myFunction"
    f = MXFunction([funcVar],[funcVar+2])
    f.setOption("name", functionName)
    f.init()
    modelFunction = ModelFunction(f)
    assert( model.getModelFunctionByName(functionName) == None )
    model.setModelFunctionByItsName(modelFunction)
    assert( int(model.getModelFunctionByName(functionName).this) == int(modelFunction.this) )
    assert( model.getModelFunctionByName("iDontExist") == None )

def test_ModelNonExistingVariableType():
    model = Model()
    assert( model.getVariableTypeByName("IAmNotATypeInModel") == None )
    
def test_ModelDefaultVariableTypeAssignment():
    model = Model()
    realVar = RealVariable(MX("var"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    model.addVariable(realVar)
    expectedPrint = ("Real type (displayUnit = , fixed = 0, max = inf, min = -inf, nominal = 1, quantity = , start = 0, unit = );")
    assert( str(model.getVariableTypeByName("Real")) == expectedPrint )
    
def test_ModelDefaultVariableTypeAssignmentSingletons():
    model = Model()
    realVar1 = RealVariable(MX("var"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    realVar2 = RealVariable(MX("var2"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    intVar1 = IntegerVariable(MX("var"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    intVar2 = IntegerVariable(MX("var2"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    boolVar1 = BooleanVariable(MX("var"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    boolVar2 = BooleanVariable(MX("var2"), MyVariable.INTERNAL, MyVariable.DISCRETE)
    model.addVariable(realVar1)
    model.addVariable(realVar2)
    model.addVariable(intVar1)
    model.addVariable(intVar2)
    model.addVariable(boolVar1)
    model.addVariable(boolVar2)
    assert( int(realVar1.getDeclaredType().this) == int(realVar2.getDeclaredType().this) ) 
    assert( int(intVar1.getDeclaredType().this) == int(intVar2.getDeclaredType().this) ) 
    assert( int(boolVar1.getDeclaredType().this) == int(boolVar2.getDeclaredType().this) ) 
    
def test_ModelVariableTypeGettersSetters():
    model = Model()
    realVarType = RealType()
    model.addVariable(RealVariable(MX("var"), MyVariable.INTERNAL, MyVariable.CONTINUOUS, realVarType))
    assert( int(realVarType.this) == int(model.getVariableTypeByName("Real").this) )
    
    boolVarType = BooleanType()
    model.addVariable(BooleanVariable(MX("var"), MyVariable.INTERNAL, MyVariable.DISCRETE, boolVarType))
    assert( int(boolVarType.this) == int(model.getVariableTypeByName("Boolean").this) )
    
    intVarType = IntegerType()
    model.addVariable(IntegerVariable(MX("var"), MyVariable.INTERNAL, MyVariable.DISCRETE, intVarType))
    assert( int(intVarType.this) == int(model.getVariableTypeByName("Integer").this) )
      
def test_ModelTrySettingExistingVariableType():
    import sys
    model = Model()
    errorMessage = ""
    expectedErrorMessage = ("A VariableType with the same name as a type in the Model can not be " +
                                     "added if those types are not the same object")
    varType1 = RealType()
    varType2 = RealType()
    model.addNewVariableType(varType1)
    try:
        model.addNewVariableType(varType2)
    except:
        errorMessage = sys.exc_info()[1].message 
    assert( errorMessage==expectedErrorMessage )
       
def test_ModelInvalidVariabilityRealVariable():
    import sys
    errorString = ""
    model = Model()
    realVar = RealVariable(MX("var"), MyVariable.INTERNAL, 10)
    model.addVariable(realVar)
    try:
        model.getVariableByKind(Model.REAL_ALGEBRAIC)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid variable variability when sorting for internal real variable: Real var;");
    
def test_ModelInvalidVariabilityIntegerVariable():
    import sys
    errorString = ""
    model = Model()
    intVar = IntegerVariable(MX("var"), MyVariable.INTERNAL, 10)
    model.addVariable(intVar)
    try:
        model.getVariableByKind(Model.INTEGER_DISCRETE)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid variable variability when sorting for internal integer variable: Integer var;");
    
def test_ModelInvalidVariabilityBooleanVariable():
    import sys
    errorString = ""
    model = Model()
    boolVar = BooleanVariable(MX("var"), MyVariable.INTERNAL, 10)
    model.addVariable(boolVar)
    try:
        model.getVariableByKind(Model.BOOLEAN_DISCRETE)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid variable variability when sorting for internal boolean variable: Boolean var;");
    
def test_ModelInvalidCausalityRealVariable():
    import sys
    errorString = ""
    model = Model()
    realVar = RealVariable(MX("var"), 10, 10)
    model.addVariable(realVar)
    try:
        model.getVariableByKind(Model.REAL_ALGEBRAIC)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid variable causality when sorting for variable: Real var;")
    
def test_ModelInvalidCausalityIntegerVariable():
    import sys
    errorString = ""
    model = Model()
    intVar = IntegerVariable(MX("var"), 10, 10)
    model.addVariable(intVar)
    try:
        model.getVariableByKind(Model.INTEGER_DISCRETE)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid variable causality when sorting for variable: Integer var;");
    
def test_ModelInvalidCausalityBooleanVariable():
    import sys
    errorString = ""
    model = Model()
    boolVar = BooleanVariable(MX("var"), 10, 10)
    model.addVariable(boolVar)
    try:
        model.getVariableByKind(Model.BOOLEAN_DISCRETE)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid variable causality when sorting for variable: Boolean var;");
 
def test_ModelInvalidVariableKindInGetter():
    import sys
    errorString = ""
    model = Model()
    try:
        model.getVariableByKind(-1)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid VariableKind");
    try:
        model.getVariableByKind(Model.NUM_OF_VARIABLE_KIND)
    except:
        errorString = sys.exc_info()[1].message 
    assert(errorString == "Invalid VariableKind");
        
def test_ModelPrinting():
    model = Model()
    realVar = RealVariable(MX("node"), MyVariable.INTERNAL, MyVariable.CONTINUOUS)
    eq1 = Equation(MX("node1"), MX("node2"))
    eq2 = Equation(MX("node3"), MX("node4"))
    model.addVariable(realVar)
    model.addDaeEquation(eq1)
    model.addInitialEquation(eq2)
    expectedPrint = ("------------------------------- Variables -------------------------------\n\n" +
                    "Real node;\n\n" +
                    "---------------------------- Variable types  ----------------------------\n\n" +
                    "Real type (displayUnit = , fixed = 0, max = inf, min = -inf, nominal = 1, quantity = , start = 0, unit = );\n\n" +
                    "------------------------------- Functions -------------------------------\n\n\n" +
                    "------------------------------- Equations -------------------------------\n\n" +
                    " -- Initial equations -- \nnode3 = node4\n -- DAE equations -- \n" +
                    "node1 = node2\n\n")
    print model, expectedPrint
    assert( str(model) == expectedPrint )
