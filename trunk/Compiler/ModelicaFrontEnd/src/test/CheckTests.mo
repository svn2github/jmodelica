/*
    Copyright (C) 2011-2013 Modelon AB

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

package CheckTests
	
model InnerOuter1
    outer Real x;
equation
    x = true; // To generate another error to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuterTest14_Err",
            description="Check that error is not generated for outer without inner in check mode",
            checkType="check",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 22, column 5:
  The right and left expression types of equation are not compatible
")})));
end InnerOuter1;


model InnerOuter2
	model A
		function f
			input Real x;
			output Real y;
		algorithm
			y := x + 1;
		end f;
	end A;
	
	outer A a;
	Real z = a.f(time);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="InnerOuter2",
			description="Check that no extra errors are generated for function called through outer withour inner",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 46, column 7:
  Cannot find inner declaration for outer a
")})));
end InnerOuter2;


model ConditionalError1
	model A
		Real x = true;
	end A;
	
	A a if b;
	parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalError1",
			description="Check that errors in conditional components are found in check mode",
            checkType="check",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 40, column 12:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ConditionalError1;


model ConditionalError2
    model A
        Real x = true;
    end A;
    
    A a if b;
    parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalError2",
			description="Check that inactive conditional components aren't error checked in compile mode",
			flatModel="
fclass CheckTests.ConditionalError2
 parameter Boolean b = false /* false */;
end CheckTests.ConditionalError2;
")})));
end ConditionalError2;


model ConditionalError3
	type B = enumeration(c, d);
	
	function f
		input Real x;
		output Real y;
	algorithm
		y := x * x;
	end f;
	
    model A
        B x = if f(time) > 2 then B.c else B.d;
    end A;
    
    A a if b;
    parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalError3",
			description="Check that inactive conditional components aren't searched for used functions and enums when flattening in compile mode",
			flatModel="
fclass CheckTests.ConditionalError3
 parameter Boolean b = false /* false */;
end CheckTests.ConditionalError3;
")})));
end ConditionalError3;


model ConditionalError4
    model A
        Real x = true;
    end A;
    
    A a if b;
    parameter Boolean b = false;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ConditionalError4",
            description="Check that errors in conditional components are found in compile mode when using the check_inactive_contitionals option",
            check_inactive_contitionals=true,
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 111, column 12:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ConditionalError4;


model ParamBinding1
	type B = enumeration(a,b,c);
	model A
	    parameter B b;
	    Real x;
		parameter Real z[if b == B.b then 2 else 1] = ones(size(z,1));
	equation
		if b == B.b then
			x = z[2];
	    else
		    x = time;
		end if;
	end A;
	
    parameter B b2;
	A a(b = b2);
	Integer y = 1.2; // Generate an error to be able to use error test case

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ParamBinding1",
			description="Check that no error messages are generated for structural parameters without binding expression in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 173, column 14:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end ParamBinding1;


model ParamBinding2
	replaceable function f
		input Real x;
		output real y; 
	end f;
	
	constant Real p = f(1);
    Integer y = 1.2; // Generate an error to be able to use error test case

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ParamBinding2",
			description="Check that no error messages are generated for structural parameters that can't be evaluated in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 197, column 17:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end ParamBinding2;


model ArraySize1
	parameter Integer n = size(x, 1);
    Real x[:];
    Real y[n];
    Real z[size(x, 1)];
	
    Integer e = 1.2; // Generate an error to be able to use error test case

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ArraySize1",
			description="Check that no error message is generated for incomplete array size in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 219, column 17:
  The binding expression of the variable e does not match the declared type of the variable
")})));
end ArraySize1;


model FunctionNoAlgorithm1
    replaceable function f
        input Real x;
        output Real y;
    end f;
    
    Real z = f(time);
    Integer y = 1.2; // Generate an error to be able to use error test case

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="FunctionNoAlgorithm1",
			description="Check that no error message is generated replaceable incomplete function in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 214, column 17:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FunctionNoAlgorithm1;


model FunctionNoAlgorithm2
    replaceable package A
		function f
	        input Real x;
	        output Real y;
	    end f;
    end A;
    
    Real z = A.f(time);
    Integer y = 1.2; // Generate an error to be able to use error test case

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="FunctionNoAlgorithm2",
			description="Check that no error message is generated incomplete function in replaceable package in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 239, column 17:
  The binding expression of the variable y does not match the declared type of the variable
")})));
end FunctionNoAlgorithm2;


model FunctionNoAlgorithm3
    function f
        input Real x;
        output Real y;
    end f;
    
    Real z = f(time);

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="FunctionNoAlgorithm3",
			description="Check that errors are generated for use of incomplete non-replaceable function in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 261, column 14:
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));
end FunctionNoAlgorithm3;

model IfEquationElse1
  Real x;
equation
  der(x) = time;
  if time > 1 then
    assert(time > 2, "msg");
  else
  end if;
  when time > 2 then
    if time > 1 then
      reinit(x,1);
    else
    end if;
  end when;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationElse1",
			description="Test empty else",
			flatModel="
fclass CheckTests.IfEquationElse1
 Real x(stateSelect = StateSelect.always);
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = time;
 if time > 1 then
  assert(time > 2, \"msg\");
 end if;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  if time > 1 then
   reinit(x, 1);
  end if;
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end CheckTests.IfEquationElse1;
")})));
end IfEquationElse1;

model IfEquationElse2
  Real x;
equation
  der(x) = time;
  if time > 1 then
    assert(time > 2, "msg");
  end if;
  when time > 2 then
    if time > 1 then
      reinit(x,1);
    end if;
  end when;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationElse2",
			description="Test no else",
			flatModel="
fclass CheckTests.IfEquationElse2
 Real x(stateSelect = StateSelect.always);
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = time;
 if time > 1 then
  assert(time > 2, \"msg\");
 end if;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  if time > 1 then
   reinit(x, 1);
  end if;
 end if;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end CheckTests.IfEquationElse2;
")})));
end IfEquationElse2;

model IfEquationElse3
  Real x;
equation
  if time > 2 then
  else
    assert(time < 2, "msg");
    x = 1;
  end if;
  x = 2;
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="IfEquationElse3",
            description="Check error for imbalanced else clause with empty if clause.",
            errorMessage="
1 errors found:
Error: in file '...':
Semantic error at line 384, column 3:
  All branches in if equation with non-parameter tests must have the same number of equations
")})));
end IfEquationElse3;

model BreakWithoutLoop
    Real[2] x;
algorithm
    for i in 1:2 loop
        break;
        x[i] := i;
    end for;
    break;
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="BreakWithoutLoop",
            description="Test errors for break statement without enclosing loop",
            errorMessage="
Error: in file '...':
Semantic error at line 16, column 5:
  Break statement must be inside while- or for-statement
")})));
end BreakWithoutLoop;

model ComponentNameError1
    model A
        Real x = true;
    end A;
    
    A a;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentNameError1",
            description="Check so that the option component_names_in_errors shows components names in errors",
            component_names_in_errors=true,
            errorMessage="
1 errors found:

Error: in file '...',
In component a
Semantic error at line 1, column 1:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ComponentNameError1;

model ComponentNameError2
    model A
        Real x = true;
    end A;
    
    A a1;
    A a2;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ComponentNameError2",
            description="Check so that the option component_names_in_errors shows components names in errors",
            component_names_in_errors=true,
            errorMessage="
1 errors found:

Error: in file '...',
In components:
  a1
  a2
Semantic error at line 1, column 1:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ComponentNameError2;

model ExtObjConstructor
  model EO
    extends ExternalObject;
    function constructor
        output EO o;
        external;
    end constructor;
    
    function destructor
        input EO o;
        external;
    end destructor;
  end EO;
  
  function wrap
    input  EO eo1 = EO(); // EO default input not allowed
    output EO eo2 = EO(); // EO output not allowed
    protected
      EO eo3 = EO(); // Ok
      Real x1 = use(eo3); // Ok
      Real x2 = use(EO()); // Non-bound constructor not allowed
    algorithm
  end wrap;
  
  function use
    input EO eo; // Ok
    output Real x = 1;
    algorithm
  end use;
    
  EO eo1 = EO(); // Ok
  EO eo2 = wrap(); // Type error or error generated in wrap
  
  Real x1 = use(eo1); // Ok
  Real x2 = use(EO()); // Non-bound constructor not allowed
    
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ExtObjConstructor",
            description="Check that external object constructor is only allowed as binding expression",
            errorMessage="
2 errors found:
Error: in file '...':
Semantic error at line 497, column 21:
  Constructors for external objects can only be used as binding expressions
Error: in file '...':
Semantic error at line 511, column 17:
  Constructors for external objects can only be used as binding expressions
")})));
end ExtObjConstructor;



package Functional

model PartialCall1
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      algorithm
        y := pf(x);
    end usePartFunc;
    
    Real y1 = usePartFunc(fullFunc(), time);
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="PartialCall1",
            description="Check error when leaving out function key word",
            errorMessage="
2 errors found:
Error: in file '...':
Semantic error at line 554, column 27:
  Calling function fullFunc(): missing argument for required input x
Error: in file '...':
Semantic error at line 554, column 27:
  Calling function usePartFunc(): types of positional argument 1 and input pf are not compatible
    type of 'fullFunc()' is Real
")})));
end PartialCall1;

model PartialCall2
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      algorithm
        y := partFunc(x);
    end usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(), time) + partFunc(time);
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="PartialCall2",
            description="Check error when calling partial function declaration directly",
            errorMessage="
2 errors found:
Error: in file '...':
Semantic error at line 570, column 15:
  Calling function partFunc(): can only call functions that have one algorithm section or external function specification
Error: in file '...':
Semantic error at line 570, column 15:
  Calling function partFunc(): can only call functions that have one algorithm section or external function specification
")})));
end PartialCall2;

model NumArgs1
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x2;
        output Real y2;
      algorithm
        y := x*x2;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      algorithm
        y := pf(x,x) + pf();
    end usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(), time);
    Real y2 = usePartFunc(function fullFunc(x=y1,x2=y1), y1);
    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="NumArgs1",
            description="Check missing and extra arguments for functional inputs",
            errorMessage="
3 errors found:
Error: in file '...':
Semantic error at line 551, column 19:
  Calling function pf(): too many positional arguments
Error: in file '...':
Semantic error at line 551, column 24:
  Calling function pf(): missing argument for required input x
Error: in file '...':
Semantic error at line 554, column 26:
  Creating functional input argument fullFunc(): missing argument for required input x2
 Error: in file '...':
Semantic error at line 555, column 45:
  Creating functional input argument fullFunc(): no input matching named argument x found
")})));
end NumArgs1;

model Array1
    partial function partFunc
        input Real x;
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        output Real y2;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc[1] pf;
        input Real x;
        output Real y;
      algorithm
        y := pf(x);
    end usePartFunc;
    
    Real y1 = usePartFunc({function fullFunc()}, time);
    
    annotation(__JModelica(UnitTesting(tests={
        ComplianceErrorTestCase(
            name="Array1",
            description="Check error when declaring as array",
            errorMessage="
2 errors found:
Error: in file '...':
Compliance error at line 738, column 24:
  Arrays of functional input arguments is currently not supported
")})));
end Array1;

end Functional;

end CheckTests;
