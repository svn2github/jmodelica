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

package ComplianceTests


/*
model String_ComplErr

 String str1="s1";
 parameter String str2="s2";


	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="String_ComplErr",
			description="Compliance error for String variables",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 73, column 9:
  String variables are not supported
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 74, column 19:
  String variables are not supported
")})));
end String_ComplErr;
*/

model IntegerVariable_ComplErr

Integer i=1;


	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="IntegerVariable_ComplErr",
			description="Compliance error for integer variables",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 42, column 30:
  Integer variables are supported only when compiling FMUs (constants and parameters are always supported)
")})));
end IntegerVariable_ComplErr;

model BooleanVariable_ComplErr
 Boolean b=true;


	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="BooleanVariable_ComplErr",
			description="Compliance error for boolean variables",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 60, column 30:
  Boolean variables are supported only when compiling FMUs (constants and parameters are always supported)
")})));
end BooleanVariable_ComplErr;

model EnumVariable_ComplErr
 type A = enumeration(a, b, c);
 A x = A.b;


	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="EnumVariable_ComplErr",
			description="Compliance error for enumeration variables",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 78, column 31:
  Enumeration variables are supported only when compiling FMUs (constants and parameters are always supported)
")})));
end EnumVariable_ComplErr;

model ArrayOfRecords_Warn
 function f
  input Real i;
  output R[2] a;
 algorithm
  a := {R(1,2), R(3,4)};
  a[integer(i)].a := 0;
 end f;

 record R
  Real a;
  Real b;
 end R;
 
 R x[2] = f(1);

	annotation(__JModelica(UnitTesting(tests={
		WarningTestCase(
			name="ArrayOfRecords_Warn",
			description="Compliance warning for arrays of records with index variability > parameter",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
At line 79, column 3:
  Using arrays of records with indices of higher than parameter variability is currently not supported when compiling with CppAD
")})));
end ArrayOfRecords_Warn;


//model ExternalFunction_ComplErr
// annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
//     JModelica.UnitTesting.ComplianceErrorTestCase(
//         name="ExternalFunction_ComplErr",
//         description="Compliance error for external functions",
//         errorMessage="
//1 errors found:
//Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
//Compliance error at line 105, column 3:
//  External functions are not supported
//")})));

// function f
//  output Real x;
//  external "C";
// end f;
 
// Real x = f();
//end ExternalFunction_ComplErr;


model WhenStmt_ComplErr
 Real x;
algorithm
 when (time < 2) then
  x := 5;
 end when;

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="WhenStmt_ComplErr",
			description="Compliance error for when statements",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 126, column 2:
  When statements are not supported
")})));
end WhenStmt_ComplErr;

model ElseWhenEq_ComplErr
 Real x;
equation
 when (time < 2) then
  x = 5;
 elsewhen time >5 then
  x = 6;
 end when;	

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ElseWhen_ComplErr",
			description="Compliance error for else clauses in when equations",
			errorMessage="
0 error(s), 1 compliance error(s) and 0 warning(s) found:
Error: in file '/Users/jakesson/svn_projects/JModelica.org/Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 167, column 2:
  Else clauses in when equations are currently not supported
")})));
end ElseWhenEq_ComplErr;

model UnsupportedBuiltins1_ComplErr
 equation
  symmetric(1 + "2");

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnsupportedBuiltins1_ComplErr",
			description="Compliance error for unsupported builtins",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 171, column 3:
  The symmetric() function-like operator is not supported
")})));
end UnsupportedBuiltins1_ComplErr;


model UnsupportedBuiltins2_ComplErr
 equation
  String();
  div(1);
  mod();
  rem(1);
  delay(1);
  cardinality();

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnsupportedBuiltins2_ComplErr",
			description="Compliance error for unsupported builtins",
			errorMessage="
8 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 212, column 3:
  The class String is not a function
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 213, column 3:
  The div() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 214, column 3:
  The mod() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 215, column 3:
  The rem() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 218, column 3:
  The delay() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 219, column 3:
  The cardinality() function-like operator is not supported
")})));
end UnsupportedBuiltins2_ComplErr;


model UnsupportedBuiltins3_ComplErr
  parameter Boolean x;
 equation
  sign(1);
  integer(1);
  ceil(1);
  floor(1);
  semiLinear();
  initial();
  sample(1,1);
  pre(x);
  edge(x);
  change(x);
  reinit(1);
  terminate("");

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnsupportedBuiltins3_ComplErr",
			description="Compliance error for unsupported builtins",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
9 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 280, column 3:
  The sign() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 289, column 3:
  The integer() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 280, column 3:
  The ceil() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 280, column 3:
  The floor() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 280, column 3:
  The semiLinear() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 281, column 3:
  The initial() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 284, column 3:
  The sample() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 285, column 3:
  The pre() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 286, column 3:
  The edge() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 286, column 3:
  The change() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 287, column 3:
  The reinit() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 288, column 3:
  The terminate() function-like operator is currently only supported when compiling FMUs
")})));
end UnsupportedBuiltins3_ComplErr;


model ArrayCellMod_ComplErr
 model A
  Real b[2];
 end A;
 
 A a(b[1] = 1, b[1](start=2));

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ArrayCellMod_ComplErr",
			description="Compliance error for modifiers of specific array elements",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 361, column 8:
  Modifiers of specific array elements are not allowed
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 364, column 5:
  Array size mismatch in declaration of b, size of declaration is [2] and size of binding expression is scalar
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 364, column 14:
  Modifiers of specific array elements are not allowed
")})));
end ArrayCellMod_ComplErr;


model DuplicateVariables_Warn
  Real x(start=1) = 1;
  Real x = 1;

	annotation(__JModelica(UnitTesting(tests={
		WarningTestCase(
			name="DuplicateVariables_Warn",
			description="",
			errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
At line 0, column 0:
  The variable x is declared multiple times and can not be verified to be identical to other declaration(s) with the same name.
")})));
end DuplicateVariables_Warn;


model HybridNonFMU1
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true); 
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when x > 2 then 
z = false; 
end when; 
when sample(0,1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="HybridNonFMU1",
			description="Test that compliance warnings for hybrid elements are issued when not compiling FMU",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
11 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 450, column 18:
  Boolean variables are supported only when compiling FMUs (constants and parameters are always supported)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 451, column 18:
  Boolean variables are supported only when compiling FMUs (constants and parameters are always supported)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 452, column 18:
  Boolean variables are supported only when compiling FMUs (constants and parameters are always supported)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 455, column 1:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 455, column 16:
  The pre() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 458, column 1:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 461, column 1:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 464, column 1:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 464, column 6:
  The sample() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 465, column 5:
  The pre() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 466, column 5:
  The pre() function-like operator is currently only supported when compiling FMUs
")})));
end HybridNonFMU1;


model HybridFMU1
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true);
parameter Real p1 = 1.2; 
parameter Real p2 = floor(p1);
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when x > 2 then 
z = false; 
end when; 
when sample(0,1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="HybridFMU1",
			description="Test that compliance warnings for hybrid elements aren't issued when compiling FMU",
			generate_ode=true,
			checkAll=true,
			flatModel="
fclass ComplianceTests.HybridFMU1
 Real xx(start = 2);
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
 parameter Real p1 = 1.2 /* 1.2 */;
 parameter Real p2;
initial equation 
 xx = 2;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
parameter equation
 p2 = floor(p1);
equation
 der(xx) = - x;
 when y > 2 and pre(z) then
  w = false;
 end when;
 when y > 2 and z then
  v = false;
 end when;
 when x > 2 then
  z = false;
 end when;
 when sample(0, 1) then
  x = pre(x) + 1.1;
 end when;
 when sample(0, 1) then
  y = pre(y) + 1.1;
 end when;
end ComplianceTests.HybridFMU1;
")})));
end HybridFMU1;


model HybridNonFMU2 
 discrete Real x, y, z;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when initial() then
   y = pre(y) + 1;
 end when;
 z = floor(dummy);

	annotation(__JModelica(UnitTesting(tests={ 
		ComplianceErrorTestCase(
			name="HybridNonFMU2",
			description="",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
7 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 537, column 2:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 537, column 7:
  The sample() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 538, column 8:
  The pre() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 540, column 2:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 540, column 7:
  The initial() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 541, column 8:
  The pre() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 543, column 6:
  The floor() function-like operator is currently only supported when compiling FMUs
")})));
end HybridNonFMU2; 


model HybridFMU2 
 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when initial() then
   y = pre(y) + 1;
 end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="HybridFMU2",
			description="Test that compliance warnings for hybrid elements aren't issued when compiling FMU",
			generate_ode=true,
			checkAll=true,
			flatModel="
fclass ComplianceTests.HybridFMU2
 discrete Real x;
 discrete Real y;
 Real dummy;
initial equation 
 dummy = 0.0;
 pre(x) = 0.0;
 pre(y) = 0.0;
equation
 der(dummy) = 0;
 when sample(0, 1 / 3) then
  x = pre(x) + 1;
 end when;
 when initial() then
  y = pre(y) + 1;
 end when;
end ComplianceTests.HybridFMU2;
")})));
end HybridFMU2;


model String2
    parameter String a = "1";
    parameter String b = a + "2";
	parameter String c = b + "3";

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="String2",
			description="Make sure uses of String parameters are evaluated",
			flatModel="
fclass ComplianceTests.String2
 parameter String a = \"1\" /* \"1\" */;
 parameter String b = \"12\" /* \"12\" */;
 parameter String c = \"123\" /* \"123\" */;
end ComplianceTests.String2;
")})));
end String2;



end ComplianceTests;
