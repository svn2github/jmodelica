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


model ArraySize1
    Real x[:];
    Integer y = 1.2; // Generate an error to be able to use error test case

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ArraySize1",
			description="Check that no error message is generated for incomplete array size in check mode",
			checkType=check,
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 191, column 17:
  The binding expression of the variable y does not match the declared type of the variable
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

end CheckTests;
