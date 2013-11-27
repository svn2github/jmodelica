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
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 107, column 3:
  Using arrays of records with indices of higher than parameter variability is currently only supported when compiling FMUs

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 107, column 5:
  The integer() function-like operator is currently only supported when compiling FMUs
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
  delay(1);
  spatialDistribution();

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnsupportedBuiltins1_ComplErr",
			description="Compliance error for unsupported builtins",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 214, column 3:
  The delay() function-like operator is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 216, column 3:
  The spatialDistribution() function-like operator is not supported
")})));
end UnsupportedBuiltins1_ComplErr;


model UnsupportedBuiltins2_ComplErr
  parameter Boolean x;
  parameter Real y;
 equation
  sign(1);
  div(1,1);
  mod(1,1);
  rem(1,1);
  ceil(1.0);
  floor(1.0);
  integer(1.0);
  semiLinear(1,1,1);
  initial();
  sample(1,1);
  pre(x);
  edge(x);
  change(x);
  terminate("");
  der(y) = time;
  when y > time then
    reinit(y, 2);
end when;

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnsupportedBuiltins2_ComplErr",
			description="Compliance error for builtins that are only supported for FMUs",
			generate_ode=false,
			generate_dae=true,
			errorMessage="
16 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 193, column 3:
  The sign() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 194, column 3:
  The div() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 195, column 3:
  The mod() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 196, column 3:
  The rem() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 197, column 3:
  The ceil() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 198, column 3:
  The floor() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 199, column 3:
  The integer() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 200, column 3:
  The semiLinear() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 201, column 3:
  The initial() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 202, column 3:
  The sample() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 203, column 3:
  The pre() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 204, column 3:
  The edge() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 205, column 3:
  The change() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 206, column 3:
  The terminate() function-like operator is currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 208, column 3:
  When equations are currently only supported when compiling FMUs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 209, column 5:
  The reinit() function-like operator is currently only supported when compiling FMUs
")})));
end UnsupportedBuiltins2_ComplErr;

model UnsupportedBuiltins_WarnErr
 equation
  homotopy(1,1);

	annotation(__JModelica(UnitTesting(tests={
		WarningTestCase(
			name="UnsupportedBuiltins_WarnErr",
			description="Compliance error for unsupported builtins",
			errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
At line 306, column 3:
  The 'homotopy' setting of the homotopy option is not supported. Setting to 'actual'.

")})));
end UnsupportedBuiltins_WarnErr;

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
 discrete Boolean temp_1;
 discrete Boolean temp_2;
 discrete Boolean temp_3;
 discrete Boolean temp_4;
initial equation 
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
 xx = 2;
 pre(temp_1) = false;
 pre(temp_2) = false;
 pre(temp_3) = false;
 pre(temp_4) = false;
parameter equation
 p2 = floor(p1);
equation
 der(xx) = - x;
 temp_1 = y > 2 and pre(z);
 w = if temp_1 and not pre(temp_1) then false else pre(w);
 temp_2 = y > 2 and z;
 v = if temp_2 and not pre(temp_2) then false else pre(v);
 temp_3 = x > 2;
 z = if temp_3 and not pre(temp_3) then false else pre(z);
 temp_4 = sample(0, 1);
 x = if temp_4 and not pre(temp_4) then pre(x) + 1.1 else pre(x);
 y = if temp_4 and not pre(temp_4) then pre(y) + 1.1 else pre(y);
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
 discrete Boolean temp_1;
initial equation 
 pre(x) = 0.0;
 pre(y) = 0.0;
 dummy = 0.0;
 pre(temp_1) = false;
equation
 der(dummy) = 0;
 temp_1 = sample(0, 0.3333333333333333);
 x = if temp_1 and not pre(temp_1) then pre(x) + 1 else pre(x);
 y = if initial() then pre(y) + 1 else pre(y);
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



package UnknownArraySizes
/* Tests compliance errors for array exps 
   of unknown size in functions. #2155 #698 */

model Error1
	
record R
	Real[2] x;
end R;
  function f
    input Real x[2,:];
	input R[:] recsIn; 
	Boolean b[size(x,2)];
    Real c[2,size(x,2)*2];
	Real known[2,4];
    output Real y[size(x,2),2];
	output R[size(recsIn,1)] recsOut;
  algorithm
    c := cat(2,x,x); // Concat unknown size.
	known := x; // Assign unknown to known size.
	x := known; // Assign known to unknown size.
	recsOut := recsIn;
	recsOut[1] := R(x[1,:]);
	
	for i in x[2,:] loop // In exp is unknown size array.
		b[i] := x[i] > 4;
	end for;
	for i in 1:size(x,2) loop // Shouldn't trigger, range exp allowed
		b[i] := x[i] > 4;
	end for;
	
/*	when b then // Array guard, unknown size.
		x := x;
	end when;*/
  end f;
  
  Real x[4,2] = f({{1,2,3,4},{5,6,7,8}}, {R({1,1})});

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnknownArraySizes_Error1",
			description="Test that compliance errors are given.",
			errorMessage="
6 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 684, column 10:
  Unknown size arg in operator cat() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 686, column 2:
  Assigning an expression of unknown size to an operand of known size is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 687, column 2:
  Assigning an expression of known size to an operand of unknown size is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 647, column 2:
  Record arrays of unknown sizes are not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 648, column 16:
  Unknown sizes in record constructors is not supported
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 689, column 6:
  Unknown size array as a for index is not supported in functions
")})));
end Error1;

model Error2
  function f
    input Real x[:,:];
	input Integer n;
    Real a;
	Real b[n,n];
	Real c[n];
    output Real y[size(x,2),size(x,1)];
  algorithm
	y := symmetric(x);
	b := identity(n);
	c := linspace(1,5,n);
	a := min(c);
	a := max(c);
	b := b^2;
	a := scalar(x);
	c := vector(x);
	b := matrix(x);
  end f;
  
  Real x[4,2] = f({{1,2,3,4},{5,6,7,8}}, 4);

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnknownArraySizes_Error2",
			description="Test that compliance errors are given.",
			errorMessage="
10 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 736, column 7:
  Unknown sizes in operator symmetric() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 737, column 7:
  Unknown size arg in operator identity() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 738, column 7:
  Unknown size arg in operator linspace() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 739, column 7:
  Unknown sizes in operator min() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 740, column 7:
  Unknown sizes in operator max() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 741, column 7:
  Unknown sizes in operator ^ is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 742, column 7:
  Unknown sizes in operator scalar() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 742, column 14:
  Calling function scalar(): types of positional argument 1 and input A are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 743, column 7:
  Unknown sizes in operator vector() is not supported in functions
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Semantic error at line 743, column 14:
  Calling function vector(): types of positional argument 1 and input A are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ComplianceTests.mo':
Compliance error at line 744, column 7:
  Unknown sizes in operator matrix() is not supported in functions
")})));
end Error2;

model ArrayIterTest
 Real x[1,1] = { i * j for i, j };

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="ArrayIterTest",
			description="Array constructor with iterators: without in",
			errorMessage="
Error: in file '...':
Semantic error at line 0, column 0:
  Array size mismatch in declaration of x, size of declaration is [1, 1] and size of binding expression is [:, :]

Error: in file '...':
Compliance error at line 0, column 0:
  Unknown size array expressions are not supported

Error: in file '...':
Compliance error at line 0, column 0:
  For index without in expression isn't supported

Error: in file '...':
Compliance error at line 0, column 0:
  For index without in expression isn't supported
")})));
end ArrayIterTest;

end UnknownArraySizes;

model UnknownArrayIndex
	Real[2] x1,x2;
equation
	for i in 1:integer(time) loop
		x1[i] = i;
	end for;
algorithm
	for i in 1:integer(time) loop
		x2[i] := i;
	end for;
	
	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="UnknownArrayIndex",
			description="Test errors for unknown array for indices in algorithms and equations.",
			errorMessage="
Error: in file '...':
Compliance error at line 0, column 0:
  For index with higher than parameter variability is not supported in equations and algorithms.

Error: in file '...':
Compliance error at line 0, column 0:
  For index with higher than parameter variability is not supported in equations and algorithms.
			
")})));
end UnknownArrayIndex;

model BreakInFor
	Real[2] x;
algorithm
	for i in 1:2 loop
		break;
		x[i] := i;
	end for;
	
	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="BreakInFor",
			description="Test errors for break statement in scalarized for",
			errorMessage="
Error: in file '...':
Compliance error at line 0, column 0:
  Break statement in algorithm only supported in while loops

")})));
end BreakInFor;

model WhileStmt
	Real x;
algorithm
	while x > time loop
		x := x - 1;
	end while;
	
	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="WhileStmt",
			description="Test while statement in algorithm",
			algorithms_as_functions=false,
			errorMessage="
Error: in file '...':
Compliance error at line 0, column 0:
  Event generating expressions are not supported in while statements: x > time

")})));
end WhileStmt;


end ComplianceTests;
