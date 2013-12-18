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

#include <cassert>
#include <iostream>
#include <sstream>
#include <boost/flyweight.hpp>

#include <AttributeExpression.hpp>
#include <types/UserType.hpp>
#include <types/RealType.hpp>
#include <types/PrimitiveType.hpp>
#include <types/VariableType.hpp>
#include <types/IntegerType.hpp>
#include <types/BooleanType.hpp>
#include <Equation.hpp>
#include <Variable.hpp>
#include <RealVariable.hpp>
#include <IntegerVariable.hpp>
#include <BooleanVariable.hpp>
#include <DerivativeVariable.hpp>
#include <ModelFunction.hpp>
#include <Constraint.hpp>
#include <Model.hpp>
#include <OptimizationProblem.hpp>


#include <map>
using std::cout; using std::endl;
using std::vector; using std::string;

using namespace CasADi;
using namespace ModelicaCasADi;


bool testAllVariableKindsEmpty(Model &model){
    for (int i = 0; i < Model::NUM_OF_VARIABLE_KIND; i++){
        if (!model.getVariables((Model::VariableKind)i).empty()) {
            return false;
        }
    }
    return true;
}

bool checkVariablesEqualToInOrder(std::vector<Variable*> variables, std::vector<Variable*> equalTo) {
    int index = 0;
    for (int i = 0; i < variables.size(); ++i) {
        if (variables[i] != equalTo[i]) {
            return false;
        }
    }
    return true;
}

void addVariableVectorToModel(std::vector<Variable*> varsToAdd, Model &model) {
    for (std::vector<Variable*>::iterator it = varsToAdd.begin(); it != varsToAdd.end(); ++it) {
        model.addVariable(*it);
    }
}

int main(int argc, char **argv) {
    cout << " ============================="
            " Running unit tests =============================" << endl;
    /* Calculate values for dependent parameters */
    { 
        MX a("a");
        MX b("b");
        MX c("c");
        MX d("d");
        
        MX funcVar("funcVar");
        vector<MX> ins;
        vector<MX> eq;
        ins.push_back(funcVar);
        eq.push_back((funcVar) * 2);
        MXFunction f = MXFunction(ins, eq);
        f.init();
        
        
        MX eq1 = MX(10);
        MX eq2 = a + MX(2);
        MX eq3 = a*b;
        ins.clear();
        ins.push_back(a);
        MX eq4 = f.call(ins).at(0);
        
        RealVariable* v1 = new RealVariable(a, Variable::INTERNAL, Variable::PARAMETER);
        RealVariable* v2 = new RealVariable(b, Variable::INTERNAL, Variable::PARAMETER);
        RealVariable* v3 = new RealVariable(c, Variable::INTERNAL, Variable::PARAMETER);
        RealVariable* v4 = new RealVariable(d, Variable::INTERNAL, Variable::PARAMETER);
        
        v1->setAttribute("bindingExpression", eq1);
        v2->setAttribute("bindingExpression", eq2);
        v3->setAttribute("bindingExpression", eq3);
        v4->setAttribute("bindingExpression", eq4);
        
        Model model;
        
        model.addVariable(v1);
        model.addVariable(v2);
        model.addVariable(v3);
        model.addVariable(v4);
        
        model.calculateValuesForDependentParameters();
        
        assert((*v2->getAttribute("evaluatedBindingExpression")).getValue() == 12);
        assert((*v3->getAttribute("evaluatedBindingExpression")).getValue() == 120);
        assert((*v4->getAttribute("evaluatedBindingExpression")).getValue() == 20);
    }


    /* Attribute expression */
    {       
        MX mxExpression("node");
        string stringExpression;
        AttributeExpression myAttribute1(mxExpression);
        AttributeExpression myAttribute2(stringExpression);
        MX mx1 = myAttribute1.getValue();
        MX mx2 = myAttribute2.getValue();
        string s1 = myAttribute1.getValue();
        string s2 = myAttribute2.getValue();
        assert( mx1.isEqual(mxExpression) && mx2.isNull() );
        assert( (s2 == stringExpression) && s1.empty() );
        //cout << (MX)myAttribute1.getValue() << endl; Gives the following errors:
        // test.cpp: In function ‘int main(int, char**)’:
        // test.cpp:76:43: error: call of overloaded ‘MX(ModelicaCasADi::AttributeProxy)’ is ambiguous
        // test.cpp:76:43: note: candidates are:
        // /home/bjorn/casadi/symbolic/mx/mx.hpp:75:5: note: CasADi::MX::MX(const CasADi::MX&)
        // /home/bjorn/casadi/symbolic/mx/mx.hpp:60:14: note: CasADi::MX::MX(const string&, int, int)
        // --- Which is a bit of information about whether this spike could be useful or not. 
        
    }   
    /* Equation unit tests */
    { // Equation getters
        MX lhs("lhs");
        MX rhs("rhs");
        Equation eq(lhs, rhs);
        assert( isEqual(eq.getLhs(), lhs) );
        assert( isEqual(eq.getRhs(), rhs) );
        assert( isEqual(eq.getResidual(), rhs - lhs) );
    }
    { // Equation printing
        Equation eq(MX("lhs"), MX("rhs"));
        std::stringstream actual;
        actual << eq;
        assert( actual.str() == "MX(lhs) = MX(rhs)" );
    }
    
    /* Types */
    { // Create and test RealType
        RealType realType;
        std::stringstream actual;
        actual << realType;
        string expectedPrint = "Type name: Real, attributes:\n\tdisplayUnit = MX()\n\tfixed = MX(Const<0>(scalar))"
                               "\n\tmax = MX(Const<inf>(scalar))\n\tmin = MX(Const<-inf>(scalar))"
                               "\n\tquantity = MX()\n\tstart = MX(Const<0>(scalar))\n\tunit = MX()";
        assert( actual.str() == expectedPrint );
        assert( realType.getAttribute("start")->getValue() == 0 );
        assert( realType.hasAttribute("quantity") );
        assert( !realType.hasAttribute("not") );
        assert( realType.getName() == "Real" );
    }
    { // Create and test IntegerType
        IntegerType intType;
        std::stringstream actual;
        actual << intType;
        string expectedPrint = "Type name: Integer, attributes:\n"
                                "\tfixed = MX(Const<0>(scalar))\n"
                                "\tmax = MX(Const<inf>(scalar))\n"
                                "\tmin = MX(Const<-inf>(scalar))\n"
                                "\tquantity = MX()\n"
                                "\tstart = MX(Const<0>(scalar))";
        assert( intType.getAttribute("start")->getValue() == 0 );
        assert( intType.hasAttribute("quantity") );
        assert( !intType.hasAttribute("not") );
        assert( actual.str() == expectedPrint );
        assert( intType.getName() == "Integer" );
    }
    { // Create and test BooleanType
        BooleanType boolType;
        std::stringstream actual;
        actual << boolType;
        string expectedPrint = "Type name: Boolean, attributes:\n"
                                "\tfixed = MX(Const<0>(scalar))\n"
                                "\tquantity = MX()\n"
                                "\tstart = MX(Const<0>(scalar))";
        assert( boolType.getAttribute("start")->getValue() == 0 );
        assert( boolType.hasAttribute("quantity") );
        assert( !boolType.hasAttribute("not") );
        assert( actual.str() == expectedPrint );
        assert( boolType.getName() == "Boolean" );
    }
    { // Create and test UserType
        RealType* realType = new RealType();
        UserType userType("My type",realType);
        assert( userType.hasAttribute("start") );
        assert( isEqual((*userType.getAttribute("start")), (*realType->getAttribute("start"))) );
        assert( (*userType.getAttribute("start")).getValue() == 0);
        userType.setAttribute("start", MX(100));
        assert( (*userType.getAttribute("start")).getValue() == 100 );
        assert( userType.getName() == "My type" );
    }
   
    
    /* RealVariable unit tests */
    { // RealVariable attributes
        MX attributeNode1(1);
        MX attributeNode2(2);
        RealVariable realVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        
        realVar.setAttribute("myAttribute", attributeNode1);
        assert( isEqual(*realVar.getAttribute("myAttribute"), attributeNode1) );
        realVar.setAttribute("myAttribute", attributeNode2);
        assert( isEqual(*realVar.getAttribute("myAttribute"), attributeNode2) );
        assert( realVar.hasAttribute("myAttribute"));
        assert( !realVar.hasAttribute("iDontHaveThisAttribute"));
    }
    { // RealVariable constants
        RealVariable realVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        assert( realVar.getCausality() == Variable::INTERNAL );
        assert( realVar.getVariability() == Variable::CONTINUOUS );
        assert( realVar.getType() == Variable::REAL);
        assert( !realVar.isDerivative() );
    }
    { // RealVariable MX node
        MX node("var");
        RealVariable realVar(node, Variable::INTERNAL, Variable::CONTINUOUS);
        assert( isEqual(realVar.getVar(), node) );
    }
    { // RealVariable's DerivativeVariable
        RealVariable realVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        DerivativeVariable derVar(MX("node"), &realVar);
        assert( realVar.getMyDerivativeVariable() == NULL );
        realVar.setMyDerivativeVariable(&derVar);
        assert( realVar.getMyDerivativeVariable() == &derVar );
    }
    { // RealVariable VariableType
        RealVariable realVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        assert( realVar.getDeclaredType() == NULL );
        RealType realType;
        realVar.setDeclaredType(&realType);
        assert( &realType == realVar.getDeclaredType() );
        UserType userType("typeName", &realType);
        realVar.setDeclaredType(&userType);
        assert( &userType == realVar.getDeclaredType() );
    }
    { // Try to create a RealVariable with a non-symbolic MX.
        std::string errorMessage("");
        std::string expectedErrorMessage("A variable must have a symbolic MX");
        try 
        {
            RealVariable realVar(MX(1), Variable::INTERNAL, Variable::CONTINUOUS);
        }
        catch(std::exception& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    } 
    { // RealVariable printing
        RealVariable realVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        realVar.setAttribute("myAttribute", MX(2));
        std::stringstream actual;
        actual << realVar;
        assert( actual.str() == "MX(node), attributes:\n\tmyAttribute = MX(Const<2>(scalar))" );
    }
    
    /* DerivativeVariable unit tests */
    { // DerivativeVariable attributes
        MX attributeNode1(1);
        MX attributeNode2(2);
        DerivativeVariable derVar(MX("node"), NULL);
        
        derVar.setAttribute("myAttribute", attributeNode1);
        assert( isEqual(*derVar.getAttribute("myAttribute"), attributeNode1) );
        derVar.setAttribute("myAttribute", attributeNode2);
        assert( isEqual(*derVar.getAttribute("myAttribute"), attributeNode2) );
        assert( derVar.hasAttribute("myAttribute"));
        assert( !derVar.hasAttribute("iDontHaveThisAttribute"));
    }
    { // DerivativeVariable constants
        DerivativeVariable derVar(MX("node"), NULL);
        assert( derVar.getCausality() == Variable::INTERNAL );
        assert( derVar.getVariability() == Variable::CONTINUOUS );
        assert( derVar.getType() == Variable::REAL);
        assert( derVar.isDerivative() );
    }
    { // DerivativeVariable MX node
        MX node("var");
        DerivativeVariable derVar(node, NULL);
        assert( isEqual(derVar.getVar(), node) );
    }
    { // DerivativeVariable's differentiated variable 
        RealVariable realVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        DerivativeVariable derVar(MX("node"), &realVar);
        assert( derVar.getMyDifferentiatedVariable() == &realVar );
    }
    { // DerivativeVariable VariableType
        DerivativeVariable derVar(MX("node"), NULL);
        assert( derVar.getDeclaredType() == NULL );
        RealType realType;
        derVar.setDeclaredType(&realType);
        assert( &realType == derVar.getDeclaredType() );
        UserType userType("typeName", &realType);
        derVar.setDeclaredType(&userType);
        assert( &userType == derVar.getDeclaredType() );
    }
    { // DerivativeVariable printing
        DerivativeVariable derVar(MX("node"), NULL);
        derVar.setAttribute("myAttribute", MX(2));
        std::stringstream actual;
        actual << derVar;
        assert( actual.str() == "MX(node), attributes:\n\tmyAttribute = MX(Const<2>(scalar))" );
    }
    
    /* IntegerVariable unit tests */
     { // IntegerVariable attributes
        MX attributeNode1(1);
        MX attributeNode2(2);
        IntegerVariable intVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        
        intVar.setAttribute("myAttribute", attributeNode1);
        assert( isEqual(*intVar.getAttribute("myAttribute"), attributeNode1) );
        intVar.setAttribute("myAttribute", attributeNode2);
        assert( isEqual(*intVar.getAttribute("myAttribute"), attributeNode2) );
        assert( intVar.hasAttribute("myAttribute"));
        assert( !intVar.hasAttribute("iDontHaveThisAttribute"));
    }
    { // IntegerVariable constants
        IntegerVariable intVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        assert( intVar.getCausality() == Variable::INTERNAL );
        assert( intVar.getVariability() == Variable::DISCRETE );
        assert( intVar.getType() == Variable::INTEGER);
    }
    { // IntegerVariable MX node
        MX node("var");
        IntegerVariable intVar(node, Variable::INTERNAL, Variable::DISCRETE);
        assert( isEqual(intVar.getVar(), node) );
    }
    { // IntegerVariable VariableType
        IntegerVariable intVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        assert( intVar.getDeclaredType() == NULL );
        IntegerType intType;
        intVar.setDeclaredType(&intType);
        assert( &intType == intVar.getDeclaredType() );
        UserType userType("typeName", &intType);
        intVar.setDeclaredType(&userType);
        assert( &userType == intVar.getDeclaredType() );
    }
    { // Try to create a continuous integer variable
        std::string errorMessage("");
        std::string expectedErrorMessage("An integer variable can not have continuous variability");
        try 
        {
            IntegerVariable intVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        }
        catch(std::exception& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    } 
    { // IntegerVariable printing
        IntegerVariable intVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        intVar.setAttribute("myAttribute", MX(2));
        std::stringstream actual;
        actual << intVar;
        assert( actual.str() == "MX(node), attributes:\n\tmyAttribute = MX(Const<2>(scalar))" );
    }
    /* BooleanVariable unit tests */
     { // BooleanVariable attributes
        MX attributeNode1(1);
        MX attributeNode2(2);
        BooleanVariable boolVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        
        boolVar.setAttribute("myAttribute", attributeNode1);
        assert( isEqual(*boolVar.getAttribute("myAttribute"), attributeNode1) );
        boolVar.setAttribute("myAttribute", attributeNode2);
        assert( isEqual(*boolVar.getAttribute("myAttribute"), attributeNode2) );
        assert( boolVar.hasAttribute("myAttribute"));
        assert( !boolVar.hasAttribute("iDontHaveThisAttribute"));
    }
    { // BooleanVariable constants
        BooleanVariable boolVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        assert( boolVar.getCausality() == Variable::INTERNAL );
        assert( boolVar.getVariability() == Variable::DISCRETE );
        assert( boolVar.getType() == Variable::BOOLEAN);
    }
    { // BooleanVariable MX node
        MX node("var");
        BooleanVariable boolVar(node, Variable::INTERNAL, Variable::DISCRETE);
        assert( isEqual(boolVar.getVar(), node) );
    }
    { // BooleanVariable VariableType
        BooleanVariable boolVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        assert( boolVar.getDeclaredType() == NULL );
        BooleanType boolType;
        boolVar.setDeclaredType(&boolType);
        assert( &boolType == boolVar.getDeclaredType() );
        UserType userType("typeName", &boolType);
        boolVar.setDeclaredType(&userType);
        assert( &userType == boolVar.getDeclaredType() );
    }
    { // Try to create a continuous boolean variable
        std::string errorMessage("");
        std::string expectedErrorMessage("A boolean variable can not have continuous variability");
        try 
        {
            BooleanVariable boolVar(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS);
        }
        catch(std::exception& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    } 
    { // BooleanVariable printing
        BooleanVariable boolVar(MX("node"), Variable::INTERNAL, Variable::DISCRETE);
        boolVar.setAttribute("myAttribute", MX(2));
        std::stringstream actual;
        actual << boolVar;
        assert( actual.str() == "MX(node), attributes:\n\tmyAttribute = MX(Const<2>(scalar))" );
    }
    
    /* ModelFunction unit tests */
    { // Modelfunction name
        MX funcVar("node");
        string functionName = "myFunction";
        MXFunction function(funcVar,funcVar+2);
        function.setOption("name", functionName);
        function.init();
        ModelFunction modelFunction(function);
        assert( modelFunction.getName() == functionName );
    }
    { // ModelFunction make calls
        MX funcVar("node");
        string functionName = "myFunction";
        MXFunction function(funcVar,funcVar+2);
        function.setOption("name", functionName);
        function.init();
        ModelFunction modelFunction(function);
        MX arg("arg");
        vector<MX> argVec;
        argVec.push_back(arg);
        /*
         * The following test would have been better, CasADi does not evaluate it to true even though the function calls
         * are identical. 
        MX manualCall = function.call(arg).at(0);
        assert( manualCall.isEqual(modelFunction.call(arg), 2));
        */
        assert( isEqual( modelFunction.call(argVec)[0].getDep(0).getDep(0),arg) );
    }
    { // ModelFunction make and use function calls
        MX funcVar("node");
        string functionName = "myFunction";
        MXFunction function(funcVar,funcVar+2);
        function.setOption("name", functionName);
        function.init();
        ModelFunction modelFunction(function);
        MX arg("arg");
        vector<MX> argVec;
        argVec.push_back(arg);
        MX call = modelFunction.call(argVec)[0];
        MXFunction evaluateCall(arg, call);
        evaluateCall.init();
        evaluateCall.setInput(0.0);
        evaluateCall.evaluate();        
        assert( evaluateCall.output().elem(0) == 2 );
    }
    { // ModelFunction printing
        MX funcVar("node");
        string functionName = "myFunction";
        MXFunction function(funcVar,funcVar+2);
        function.setOption("name", functionName);
        function.init();
        ModelFunction modelFunction(function);
        std::stringstream actual;
        actual << modelFunction;
        std::string expectedPrint = "ModelFunction : function(\"myFunction\")\n"
                                    " Input: 1-by-1 (dense)\n"
                                    " Output: 1-by-1 (dense)\n"
                                    "@0 = Const<2>(scalar)\n"
                                    "@1 = input[0]\n"
                                    "@0 = (@0+@1)\n"
                                    "output[0] = @0\n";
        assert( actual.str() == expectedPrint );
    }
    
    /* Constraint unit testing */
    { // Getters for the different constraint types
        MX lhs("lhs");
        MX rhs("rhs");
        Constraint equalityConstraint(lhs, rhs, Constraint::EQ);
        Constraint lessThanConstraint(lhs, rhs, Constraint::LEQ);
        Constraint greaterThanConstraint(lhs, rhs, Constraint::GEQ);
        
        // Equality constraint
        assert( isEqual(equalityConstraint.getLhs(), lhs) );
        assert( isEqual(equalityConstraint.getRhs(), rhs) );
        assert( isEqual(equalityConstraint.getResidual(), rhs - lhs) );
        assert( equalityConstraint.getType() == Constraint::EQ);
        // Less than or equal to constraint
        assert( isEqual(lessThanConstraint.getLhs(), lhs) );
        assert( isEqual(lessThanConstraint.getRhs(), rhs) );
        assert( isEqual(equalityConstraint.getResidual(), rhs - lhs) );
        assert( lessThanConstraint.getType() == Constraint::LEQ );
        // Greater than or equal to constraint
        assert( isEqual(greaterThanConstraint.getLhs(), lhs) );
        assert( isEqual(greaterThanConstraint.getRhs(), rhs) );
        assert( isEqual(greaterThanConstraint.getResidual(), rhs - lhs) );
        assert( greaterThanConstraint.getType() == Constraint::GEQ );
    } 
    { // Constraint printing
        MX lhs("lhs");
        MX rhs("rhs");
        Constraint equalityConstraint(lhs, rhs, Constraint::EQ);
        Constraint lessThanConstraint(lhs, rhs, Constraint::LEQ);
        Constraint greaterThanConstraint(lhs, rhs, Constraint::GEQ);
        std::stringstream actual;
        actual << equalityConstraint << lessThanConstraint << greaterThanConstraint;
        assert( actual.str() == "MX(lhs) == MX(rhs)MX(lhs) <= MX(rhs)MX(lhs) >= MX(rhs)" );
    }
    
    /* OptimizationProblem unit testing */
    { // Getter for model
        Model* model = new Model();
        vector<Constraint> constraintsEmpty;
        OptimizationProblem optBothMayerAndLagrange(model, constraintsEmpty, MX(0), MX(0), MX(0), MX(0));
        OptimizationProblem optOnlyLagrange(model, constraintsEmpty, MX(0), MX(0), MX(0));
        OptimizationProblem optNeitherLagrangreOrMayer(model, constraintsEmpty, MX(0), MX(0));
        
        assert( model == optBothMayerAndLagrange.getModel() );
        assert( model == optOnlyLagrange.getModel() );
        assert( model == optNeitherLagrangreOrMayer.getModel() );
    }
    { // Getters and setters for start/final-time
        MX start(0);
        MX final(1);
        vector<Constraint> constraintsEmpty;
        OptimizationProblem optBothMayerAndLagrange(new Model(), constraintsEmpty, start, final, MX(0), MX(0));
        OptimizationProblem optOnlyLagrange(new Model(), constraintsEmpty, start, final, MX(0));
        OptimizationProblem optNeitherLagrangreOrMayer(new Model(), constraintsEmpty, start, final);
        
        assert( isEqual(start, optBothMayerAndLagrange.getStartTime()) );
        assert( isEqual(final, optBothMayerAndLagrange.getFinalTime()) );
        assert( isEqual(start, optOnlyLagrange.getStartTime()) );
        assert( isEqual(final, optOnlyLagrange.getFinalTime()) );
        assert( isEqual(start, optNeitherLagrangreOrMayer.getStartTime()) );
        assert( isEqual(final, optNeitherLagrangreOrMayer.getFinalTime()) );
        // Set and check
        start = MX(2);
        final = MX(4);
        optBothMayerAndLagrange.setStartTime(start);
        optBothMayerAndLagrange.setFinalTime(final);
        assert( isEqual(start, optBothMayerAndLagrange.getStartTime()) );
        assert( isEqual(final, optBothMayerAndLagrange.getFinalTime()) );
    }
    { // Getters and setters for lagrange and mayer terms
        MX lagrange("lagrange");
        MX mayer("mayer");
        vector<Constraint> constraintsEmpty;
        OptimizationProblem optBothMayerAndLagrange(new Model(), constraintsEmpty,  MX(0),  MX(0), lagrange, mayer);
        OptimizationProblem optOnlyLagrange(new Model(), constraintsEmpty,  MX(0),  MX(0), lagrange);
        OptimizationProblem optNeitherLagrangreOrMayer(new Model(), constraintsEmpty,  MX(0),  MX(0));
        
        assert( isEqual(lagrange, optBothMayerAndLagrange.getLagrangeTerm()) );
        assert( isEqual(mayer, optBothMayerAndLagrange.getMayerTerm()) );
        assert( isEqual(lagrange, optOnlyLagrange.getLagrangeTerm()) );
        assert( optOnlyLagrange.getMayerTerm().getValue() == 0 );
        assert( optNeitherLagrangreOrMayer.getLagrangeTerm().getValue() == 0 );
        assert( optNeitherLagrangreOrMayer.getMayerTerm().getValue() == 0 );
        // Set and check
        optNeitherLagrangreOrMayer.setMayerTerm(mayer);
        optNeitherLagrangreOrMayer.setLagrangeTerm(lagrange);
        assert( isEqual(lagrange, optNeitherLagrangreOrMayer.getLagrangeTerm()) );
        assert( isEqual(mayer, optNeitherLagrangreOrMayer.getMayerTerm()) );
    }
    { // Constraints
        vector<Constraint>  constraintsEmpty, constraintsLessThan, constraintsGreaterThan;
        MX lhs("lhs");
        MX rhs("rhs");
        Constraint lessThanConstraint(lhs, rhs, Constraint::LEQ);
        Constraint greaterThanConstraint(lhs, rhs, Constraint::GEQ);
        constraintsLessThan.push_back(lessThanConstraint);
        constraintsGreaterThan.push_back(greaterThanConstraint);
        OptimizationProblem optBothMayerAndLagrange(new Model(), constraintsEmpty, MX(0), MX(0), MX(0), MX(0));
        OptimizationProblem optOnlyLagrange(new Model(), constraintsLessThan, MX(0), MX(0), MX(0));
        OptimizationProblem optNeitherLagrangreOrMayer(new Model(), constraintsGreaterThan, MX(0), MX(0));
        
        assert( optBothMayerAndLagrange.getPathConstraints().size() == 0 );
        assert( isEqual(optOnlyLagrange.getPathConstraints()[0].getResidual(), lessThanConstraint.getResidual()) );
        assert( isEqual(optNeitherLagrangreOrMayer.getPathConstraints()[0].getResidual(), greaterThanConstraint.getResidual()) );
        // Set and check
        optBothMayerAndLagrange.setPathConstraint(constraintsLessThan);
        assert( isEqual(optBothMayerAndLagrange.getPathConstraints()[0].getResidual(), lessThanConstraint.getResidual()) );
    }
    { // OptimizationProblem printing
        vector<Constraint>  constraintsEmpty;
        OptimizationProblem simpleOptProblem(new Model(), constraintsEmpty, MX(0), MX(1));
        std::stringstream actual;
        actual << simpleOptProblem;
        std::string expectedPrint = "Model contained in OptimizationProblem:\n\n"
                                     "------------------------------- Variables -------------------------------\n\n\n"
                                     "---------------------------- Variable types  ----------------------------\n\n\n"
                                     "------------------------------- Functions -------------------------------\n\n\n"
                                     "------------------------------- Equations -------------------------------\n\n\n"
                                     "-- Optimization information  --\n\n"
                                     "Start time = MX(Const<0>(scalar))\nEnd time = MX(Const<1>(scalar))\n"
                                     "-- Lagrange term --\nMX(Const<0>(scalar))\n-- Mayer term --\nMX(Const<0>(scalar))\n";
        assert( actual.str() == expectedPrint );
    }
    
    /*  Model unit testing */
    { // Equation functionality
        Model model;
        MX var1("var1");
        MX var2("var2");
        MX var3("var3");
        MX var4("var4");
        MX res1 = var2 - var1;
        MX res2 = var4 - var3;
        Equation eq1(var1, var2);
        Equation eq2(var3, var4);
        
        // Should return an MX with a null node (default MX value 
        // for default/empty constructor), if there are no equations
        assert( model.getDaeResidual().isNull() );
         // Add equations and check residuals
        model.addDaeEquation(&eq1);
        model.addDaeEquation(&eq2);
        model.addInitialEquation(&eq1);
        assert( isEqual(res1, model.getInitialResidual()) );
        // Also test residuals with more than one residual equation
        res1.append(res2);
        // isEqual in the casadi namespace gives a false negative 
        // (which is warned for in the casadi source) if used, 
        // so MX.isEqual is used instead.
        assert( res1.isEqual(model.getDaeResidual(), 2) );
    }
    { // Test ModelFunction
        using std::vector;
        Model model;
        MX funcVar("node");
        string functionName = "myFunction";
        MXFunction f(funcVar,funcVar+2);
        f.setOption("name", functionName);
        f.init();
        ModelFunction modelFunction(f);
        assert( model.getModelFunction(functionName) == NULL );
        model.setModelFunctionByItsName(&modelFunction);
        assert( model.getModelFunction(functionName) == &modelFunction );
        assert( model.getModelFunction("iDontExist") == NULL );
    }
    { // Test variables empty in empty model
        Model model;
        assert( testAllVariableKindsEmpty(model) );
    }
    { // Test variable sorting (categorization)
        using std::vector;
        Model model;
        MX var1("node1");
        MX var2("node2");
        
        //Create different kinds of variables
        vector<Variable*> outputVariables, inputRealVariables, inputIntegerVariables, inputBooleanVariables,  
                                           algebraicVariables, differentiatedVariables, derivativeVariables, 
                                           discreteRealVariables, discreteIntegerVariables, discreteBooleanVariables, 
                                           constantRealVariables, constantIntegerVariables, constantBooleanVariables,
                                           indepenentRealParameterVariables, depenentRealParameterVariables,
                                           indepenentIntegerParameterVariables, depenentIntegerParameterVariables,
                                           indepenentBooleanParameterVariables, depenentBooleanParameterVariables;
        // Real variables
        inputRealVariables.push_back(new RealVariable(var1, Variable::INPUT, Variable::CONTINUOUS));
        inputRealVariables.push_back(new RealVariable(var1, Variable::INPUT, Variable::DISCRETE));
        inputRealVariables.push_back(new RealVariable(var1, Variable::INPUT, Variable::PARAMETER));
        inputRealVariables.push_back(new RealVariable(var1, Variable::INPUT, Variable::CONSTANT));
        algebraicVariables.push_back(new RealVariable(var1,  Variable::INTERNAL, Variable::CONTINUOUS));
        RealVariable differentiated(var1,  Variable::INTERNAL, Variable::CONTINUOUS);
        differentiatedVariables.push_back(&differentiated);
        derivativeVariables.push_back(new DerivativeVariable(var1, &differentiated));
        discreteRealVariables.push_back(new RealVariable(var1,  Variable::INTERNAL, Variable::DISCRETE));
        constantRealVariables.push_back(new RealVariable(var1,  Variable::INTERNAL, Variable::CONSTANT));
        indepenentRealParameterVariables.push_back(new RealVariable(var1,  Variable::INTERNAL, Variable::PARAMETER));
        RealVariable dependentRealParameter(var1,  Variable::INTERNAL, Variable::PARAMETER);
        dependentRealParameter.setAttribute("bindingExpression", var2);
        depenentRealParameterVariables.push_back(&dependentRealParameter);
        // Integer variables
        inputIntegerVariables.push_back(new IntegerVariable(var1, Variable::INPUT, Variable::DISCRETE));
        inputIntegerVariables.push_back(new IntegerVariable(var1, Variable::INPUT, Variable::PARAMETER));
        inputIntegerVariables.push_back(new IntegerVariable(var1, Variable::INPUT, Variable::CONSTANT));
        discreteIntegerVariables.push_back(new IntegerVariable(var1,  Variable::INTERNAL, Variable::DISCRETE));
        constantIntegerVariables.push_back(new IntegerVariable(var1,  Variable::INTERNAL, Variable::CONSTANT));
        indepenentIntegerParameterVariables.push_back(new IntegerVariable(var1,  Variable::INTERNAL, Variable::PARAMETER));
        IntegerVariable dependentIntegerParameter(var1,  Variable::INTERNAL, Variable::PARAMETER);
        dependentIntegerParameter.setAttribute("bindingExpression", var2);
        depenentIntegerParameterVariables.push_back(&dependentIntegerParameter);
        // Boolean variables
        inputBooleanVariables.push_back(new BooleanVariable(var1, Variable::INPUT, Variable::DISCRETE));
        inputBooleanVariables.push_back(new BooleanVariable(var1, Variable::INPUT, Variable::PARAMETER));
        inputBooleanVariables.push_back(new BooleanVariable(var1, Variable::INPUT, Variable::CONSTANT));
        discreteBooleanVariables.push_back(new BooleanVariable(var1,  Variable::INTERNAL, Variable::DISCRETE));
        constantBooleanVariables.push_back(new BooleanVariable(var1,  Variable::INTERNAL, Variable::CONSTANT));
        indepenentBooleanParameterVariables.push_back(new BooleanVariable(var1,  Variable::INTERNAL, Variable::PARAMETER));
        BooleanVariable dependentBooleanParameter(var1,  Variable::INTERNAL, Variable::PARAMETER);
        dependentBooleanParameter.setAttribute("bindingExpression", var2);
        depenentBooleanParameterVariables.push_back(&dependentBooleanParameter);
        
        // Non-forced type variables
        outputVariables.push_back(new RealVariable(var1, Variable::OUTPUT, Variable::CONTINUOUS));
        outputVariables.push_back(new RealVariable(var1, Variable::OUTPUT, Variable::DISCRETE));
        outputVariables.push_back(new RealVariable(var1, Variable::OUTPUT, Variable::PARAMETER));
        outputVariables.push_back(new RealVariable(var1, Variable::OUTPUT, Variable::CONSTANT));
        outputVariables.push_back(new BooleanVariable(var1, Variable::OUTPUT, Variable::DISCRETE));
        outputVariables.push_back(new BooleanVariable(var1, Variable::OUTPUT, Variable::PARAMETER));
        outputVariables.push_back(new BooleanVariable(var1, Variable::OUTPUT, Variable::CONSTANT));
        outputVariables.push_back(new IntegerVariable(var1, Variable::OUTPUT, Variable::DISCRETE));
        outputVariables.push_back(new IntegerVariable(var1, Variable::OUTPUT, Variable::PARAMETER));
        outputVariables.push_back(new IntegerVariable(var1, Variable::OUTPUT, Variable::CONSTANT));
        
        // Add differentiated variable, but without its corresponding derivative variable
        // => should be sorted as algebraic. Then add derivative variable and check again
        addVariableVectorToModel(differentiatedVariables, model);
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_ALGEBRAIC), differentiatedVariables) );
        addVariableVectorToModel(derivativeVariables, model);
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::DIFFERENTIATED), differentiatedVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::DERIVATIVE), derivativeVariables) );
        
        // Add the rest of the variables and check that they are sorted correctly
        addVariableVectorToModel(outputVariables, model);
        addVariableVectorToModel(inputRealVariables, model);
        addVariableVectorToModel(inputIntegerVariables, model);
        addVariableVectorToModel(inputBooleanVariables, model);
        addVariableVectorToModel(algebraicVariables, model);
        addVariableVectorToModel(discreteRealVariables, model);
        addVariableVectorToModel(discreteIntegerVariables, model);
        addVariableVectorToModel(discreteBooleanVariables, model);
        addVariableVectorToModel(constantRealVariables, model);
        addVariableVectorToModel(constantIntegerVariables, model);
        addVariableVectorToModel(constantBooleanVariables, model);
        addVariableVectorToModel(indepenentRealParameterVariables, model);
        addVariableVectorToModel(indepenentIntegerParameterVariables, model);
        addVariableVectorToModel(indepenentBooleanParameterVariables, model);
        addVariableVectorToModel(depenentRealParameterVariables, model);
        addVariableVectorToModel(depenentIntegerParameterVariables, model);
        addVariableVectorToModel(depenentBooleanParameterVariables, model);
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::OUTPUT), outputVariables) ); 
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_INPUT), inputRealVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::INTEGER_INPUT), inputIntegerVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::BOOLEAN_INPUT), inputBooleanVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_ALGEBRAIC), algebraicVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::DIFFERENTIATED), differentiatedVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::DERIVATIVE), derivativeVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_DISCRETE), discreteRealVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::INTEGER_DISCRETE), discreteIntegerVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::BOOLEAN_DISCRETE), discreteBooleanVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_CONSTANT), constantRealVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::INTEGER_CONSTANT), constantIntegerVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::BOOLEAN_CONSTANT), constantBooleanVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_PARAMETER_INDEPENDENT), indepenentRealParameterVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::INTEGER_PARAMETER_INDEPENDENT), indepenentIntegerParameterVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::BOOLEAN_PARAMETER_INDEPENDENT), indepenentBooleanParameterVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::REAL_PARAMETER_DEPENDENT), depenentRealParameterVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::INTEGER_PARAMETER_DEPENDENT), depenentIntegerParameterVariables) );
        assert( checkVariablesEqualToInOrder(model.getVariables(Model::BOOLEAN_PARAMETER_DEPENDENT), depenentBooleanParameterVariables) );
    }
    { // Test to add invalid (non-symbolic) variable
        Model model;
        MX nonSymbolicVar = MX("var") + 2;
        std::string errorMessage("");
        std::string expectedErrorMessage("The supplied variable is not symbolic and can not be variable");
        try 
        {
            model.addVariable(new RealVariable(nonSymbolicVar, Variable::INTERNAL, Variable::CONTINUOUS));
        }
        catch(std::exception& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    }
    { // Test non-existing VariableType
        Model model;
        assert( model.getVariableType("I'mNotATypeInModel") == NULL );
    }
    { // Test VariableType, default for Real Variables
        Model model;
        model.addVariable(new RealVariable(MX("var"), Variable::INTERNAL, Variable::CONTINUOUS));
        std::stringstream actual;
        actual << *(model.getVariableType("Real"));
        string expectedPrint = "Type name: Real, attributes:\n\tdisplayUnit = MX()\n\tfixed = MX(Const<0>(scalar))"
                               "\n\tmax = MX(Const<inf>(scalar))\n\tmin = MX(Const<-inf>(scalar))"
                               "\n\tquantity = MX()\n\tstart = MX(Const<0>(scalar))\n\tunit = MX()";
        assert( actual.str() == expectedPrint );
    }
    { // Test Model Variabletype: Variables, with the same properties, should be assigned
      // the same default VariableType if they do not have on set already. 
        Model model;
        RealVariable realVar1(MX("var"), Variable::INTERNAL, Variable::CONTINUOUS);
        RealVariable realVar2(MX("var2"), Variable::INTERNAL, Variable::CONTINUOUS);
        IntegerVariable intVar1(MX("var"), Variable::INTERNAL, Variable::DISCRETE);
        IntegerVariable intVar2(MX("var2"), Variable::INTERNAL, Variable::DISCRETE);
        BooleanVariable boolVar1(MX("var"), Variable::INTERNAL, Variable::DISCRETE);
        BooleanVariable boolVar2(MX("var2"), Variable::INTERNAL, Variable::DISCRETE);
        model.addVariable(&realVar1);
        model.addVariable(&realVar2);
        model.addVariable(&intVar1);
        model.addVariable(&intVar2);
        model.addVariable(&boolVar1);
        model.addVariable(&boolVar2);
        assert( realVar1.getDeclaredType() == realVar2.getDeclaredType() ) ;
        assert( intVar1.getDeclaredType() == intVar2.getDeclaredType() ) ;
        assert( boolVar1.getDeclaredType() == boolVar2.getDeclaredType() ) ;
    }
    { // Test Model VariableType, set own PrimitiveType and retrieve it
        Model model;
        VariableType* realVarType = new RealType();
        model.addVariable(new RealVariable(MX("var"), Variable::INTERNAL, Variable::CONTINUOUS, realVarType));
        assert( realVarType == model.getVariableType("Real") );
        
        VariableType* boolVarType = new BooleanType();
        model.addVariable(new BooleanVariable(MX("var"), Variable::INTERNAL, Variable::DISCRETE, boolVarType));
        assert( boolVarType == model.getVariableType("Boolean") );
        
        VariableType* intVarType = new IntegerType();
        model.addVariable(new IntegerVariable(MX("var"), Variable::INTERNAL, Variable::DISCRETE, intVarType));
        assert( intVarType == model.getVariableType("Integer") );
    }
    { // Test Model, set variable with VariableType name equal to existing type, but where the types are not equal
        Model model;
        std::string errorMessage("");
        std::string expectedErrorMessage("A VariableType with the same name as a type in the Model can not be "
                                         "added if those types are not the same object");
        VariableType* varType = new RealType();
        model.addNewVariableType(varType);
        try 
        {
            model.addVariable(new RealVariable(MX("var"), Variable::INTERNAL, Variable::CONTINUOUS, new RealType()));
        }
        catch(std::runtime_error& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    }
    { // Test to add and sort invalid variability real variable.
        Model model;
        std::string errorMessage("");
        std::string expectedErrorMessage("Invalid variable variability when sorting for internal " 
                                          "real variable: MX(var), declaredType : Real");
        try 
        {
            model.addVariable(new RealVariable(MX("var"), Variable::INTERNAL, Variable::Variability(10)));
            model.getVariables(Model::REAL_ALGEBRAIC);
        }
        catch(std::runtime_error& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    }
    { // Test to add and sort invalid variability integer variable.
        Model model;
        std::string errorMessage("");
        std::string expectedErrorMessage("Invalid variable variability when sorting for internal " 
                                          "integer variable: MX(var), declaredType : Integer");
        try 
        {
            model.addVariable(new IntegerVariable(MX("var"), Variable::INTERNAL, (Variable::Variability)10));
            model.getVariables(Model::INTEGER_DISCRETE);
        }
        catch(std::runtime_error& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    }
    { // Test to add and sort invalid variability boolean variable.
        Model model;
        std::string errorMessage("");
        std::string expectedErrorMessage("Invalid variable variability when sorting for internal " 
                                          "boolean variable: MX(var), declaredType : Boolean");
        try 
        {
            model.addVariable(new BooleanVariable(MX("var"), Variable::INTERNAL, (Variable::Variability)10));
            model.getVariables(Model::BOOLEAN_DISCRETE);
        }
        catch(std::runtime_error& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    }
    { // Test to add and sort invalid causality and variability variable
        Model model;
        std::string errorMessage("");
        std::string expectedErrorMessage("Invalid variable causality when sorting for variable: "
                                         "MX(var), declaredType : Real");
        try 
        {
            model.addVariable(new RealVariable(MX("var"), (Variable::Causality)10, (Variable::Variability)10));
            model.getVariables(Model::REAL_ALGEBRAIC);
        }
        catch(std::runtime_error& ex)
        { 
            errorMessage = string(ex.what());
        }
        assert( errorMessage==expectedErrorMessage );
    }
    { // Model printing
        Model model;
        model.addVariable(new RealVariable(MX("node"), Variable::INTERNAL, Variable::CONTINUOUS));
        model.addDaeEquation(new Equation(MX("node1"), MX("node2")));
        model.addInitialEquation(new Equation(MX("node3"), MX("node4")));
        std::string expectedPrint = "------------------------------- Variables -------------------------------\n\n"
                                    "MX(node), declaredType : Real\n\n"
                                    "---------------------------- Variable types  ----------------------------\n\n"
                                    "Type name: Real, attributes:\n\tdisplayUnit = MX()\n\tfixed = MX(Const<0>(scalar))"
                                    "\n\tmax = MX(Const<inf>(scalar))\n\tmin = MX(Const<-inf>(scalar))"
                                    "\n\tquantity = MX()\n\tstart = MX(Const<0>(scalar))\n\tunit = MX()\n\n"
                                    "------------------------------- Functions -------------------------------\n\n\n"
                                    "------------------------------- Equations -------------------------------\n\n"
                                    " -- Initial equations -- \nMX(node3) = MX(node4)\n -- DAE equations -- \n"
                                    "MX(node1) = MX(node2)\n\n";
        std::stringstream actual;
        actual << model;
        assert( actual.str() == expectedPrint );
    }
    
    
    cout << "... All tests passed!" << endl;
}
