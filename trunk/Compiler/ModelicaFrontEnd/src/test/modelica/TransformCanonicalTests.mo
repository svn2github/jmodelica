/*
    Copyright (C) 2009-2011 Modelon AB

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


package TransformCanonicalTests

	model TransformCanonicalTest1
		Real x(start=1,fixed=true);
		Real y(start=3,fixed=true);
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
                y + v = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest1",
			description="Test basic canonical transformations",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest1
 Real x(start = 1,fixed = true);
 Real y(start = 3,fixed = true);
 Real w(start = 1);
 Real v;
initial equation 
 x = 1;
 y = 3;
equation
 der(x) = - x;
 der(v) = 4;
 y + v = 1;
 w = 2;
end TransformCanonicalTests.TransformCanonicalTest1;
")})));
	end TransformCanonicalTest1;
	
  model TransformCanonicalTest2
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p1;
  	parameter Real p1 = 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest2",
			description="Test parameter sorting",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest2
 parameter Real p6;
 parameter Real p5 = 5 /* 5 */;
 parameter Real p2;
 parameter Real p3;
 parameter Real p4;
 parameter Real p1 = 4 /* 4 */;
parameter equation
 p6 = p5;
 p2 = p1 * p1;
 p3 = p2 + p1;
 p4 = p3 * p3;
end TransformCanonicalTests.TransformCanonicalTest2;
")})));
  end TransformCanonicalTest2;

  model TransformCanonicalTest3_Err
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p4*p1;
  	parameter Real p1 = 4;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TransformCanonical3_Err",
			description="Test parameter sorting.",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 69, column 24:
  Circularity in binding expression of parameter: p4 = p3 * p3
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 70, column 24:
  Circularity in binding expression of parameter: p3 = p2 + p1
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 71, column 24:
  Circularity in binding expression of parameter: p2 = p4 * p1
")})));
  end TransformCanonicalTest3_Err;

  model TransformCanonicalTest4_Err
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p2;
  	parameter Real p1 = 4;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TransformCanonical4_Err",
			description="Test parameter sorting.",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 95, column 24:
  Circularity in binding expression of parameter: p4 = p3 * p3
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 96, column 24:
  Circularity in binding expression of parameter: p3 = p2 + p1
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 97, column 24:
  Circularity in binding expression of parameter: p2 = p1 * p2
")})));
  end TransformCanonicalTest4_Err;

  model TransformCanonicalTest5
    parameter Real p10 = p11*p3;
  	parameter Real p9 = p11*p8;
  	parameter Real p2 = p11;
  	parameter Real p11 = p7*p5;
  	parameter Real p8 = p7*p3;
  	parameter Real p7 = 1;
  	parameter Real p5 = 1;
    parameter Real p3 = 1;
  	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest5",
			description="Test parameter sorting",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest5
 parameter Real p11;
 parameter Real p8;
 parameter Real p10;
 parameter Real p2;
 parameter Real p9;
 parameter Real p7 = 1 /* 1 */;
 parameter Real p5 = 1 /* 1 */;
 parameter Real p3 = 1 /* 1 */;
parameter equation
 p11 = p7 * p5;
 p8 = p7 * p3;
 p10 = p11 * p3;
 p2 = p11;
 p9 = p11 * p8;
end TransformCanonicalTests.TransformCanonicalTest5;
")})));
  end TransformCanonicalTest5;


  model TransformCanonicalTest6

    parameter Real p1 = sin(1);
    parameter Real p2 = cos(1);
    parameter Real p3 = tan(1); 
    parameter Real p4 = asin(0.3);
    parameter Real p5 = acos(0.3);
    parameter Real p6 = atan(0.3); 
    parameter Real p7 = atan2(0.3,0.5); 	
    parameter Real p8 = sinh(1);
    parameter Real p9 = cosh(1);
    parameter Real p10 = tanh(1); 
    parameter Real p11 = exp(1);
    parameter Real p12 = log(1);
    parameter Real p13 = log10(1);   	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest6",
			description="Built-in functions.",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest6
 parameter Real p1 = sin(1) /* 0.8414709848078965 */;
 parameter Real p2 = cos(1) /* 0.5403023058681398 */;
 parameter Real p3 = tan(1) /* 1.5574077246549023 */;
 parameter Real p4 = asin(0.3) /* 0.3046926540153975 */;
 parameter Real p5 = acos(0.3) /* 1.2661036727794992 */;
 parameter Real p6 = atan(0.3) /* 0.2914567944778671 */;
 parameter Real p7 = atan2(0.3, 0.5) /* 0.5404195002705842 */;
 parameter Real p8 = sinh(1) /* 1.1752011936438014 */;
 parameter Real p9 = cosh(1) /* 1.543080634815244 */;
 parameter Real p10 = tanh(1) /* 0.7615941559557649 */;
 parameter Real p11 = exp(1) /* 2.7182818284590455 */;
 parameter Real p12 = log(1) /* 0.0 */;
 parameter Real p13 = log10(1) /* 0.0 */;

end TransformCanonicalTests.TransformCanonicalTest6;
")})));
  end TransformCanonicalTest6;
  
  
  model TransformCanonicalTest7
	  parameter Integer p1 = 2;
	  parameter Integer p2 = p1;
	  Real x[p2] = 1:p2;
	  Real y = x[p2]; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest7",
			description="Provokes a former bug that was due to tree traversals befor the flush after scalarization",
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest7
 parameter Integer p1 = 2 /* 2 */;
 parameter Integer p2;
 Real x[1];
 Real y;
parameter equation
 p2 = p1;
equation
 x[1] = 1;
 y = 2;

end TransformCanonicalTests.TransformCanonicalTest7;
")})));
  end TransformCanonicalTest7;

model TransformCanonicalTest8
  function f
	input Real x;
	output Real y;
  algorithm
	y := f1(x)*2;
  end f;
	
  function f1
	input Real x;
	output Real y;
  algorithm
	y := x^2;
	annotation(derivative=f_der);
  end f1;
		
  function f_der
	input Real x;
	input Real der_x;
	output Real der_y;
  algorithm
	der_y := 2*x*der_x;
  end f_der;

  Real x1,x2;
equation
  x1 = f(x2);
  x2 = f1(x1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TransformCanonicalTest8",
			description="Test that derivative functions are included in the flattened model if Jacobians are to be generated.",
			generate_block_jacobian=true,
			generate_ode_jacobian=true,
			flatModel="
fclass TransformCanonicalTests.TransformCanonicalTest8
 Real x1;
 Real x2;
equation
 x1 = TransformCanonicalTests.TransformCanonicalTest8.f(x2);
 x2 = TransformCanonicalTests.TransformCanonicalTest8.f1(x1);

public
 function TransformCanonicalTests.TransformCanonicalTest8.f
  input Real x;
  output Real y;
 algorithm
  y := TransformCanonicalTests.TransformCanonicalTest8.f1(x) * 2;
  return;
 end TransformCanonicalTests.TransformCanonicalTest8.f;

 function TransformCanonicalTests.TransformCanonicalTest8.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := 2 * x * der_x;
  return;
 end TransformCanonicalTests.TransformCanonicalTest8.f_der;

 function TransformCanonicalTests.TransformCanonicalTest8.f1
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 end TransformCanonicalTests.TransformCanonicalTest8.f1;

end TransformCanonicalTests.TransformCanonicalTest8;
")})));
end TransformCanonicalTest8;

  model EvalTest1

    parameter Real p1 = sin(1);
    parameter Real p2 = cos(1);
    parameter Real p3 = tan(1); 
    parameter Real p4 = asin(0.3);
    parameter Real p5 = acos(0.3);
    parameter Real p6 = atan(0.3); 
    parameter Real p7 = atan2(0.3,0.5); 	
    parameter Real p8 = sinh(1);
    parameter Real p9 = cosh(1);
    parameter Real p10 = tanh(1); 
    parameter Real p11 = exp(1);
    parameter Real p12 = log(1);
    parameter Real p13 = log10(1); 


  	

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="EvalTest1",
			methodName="variableDiagnostics",
			description="Test evaluation of independent parameters",
			methodResult="
Independent constants: 
        
Dependent constants: 

Independent parameters: 
 p1: number of uses: 0, isLinear: true, evaluated binding exp: 0.8414709848078965
 p2: number of uses: 0, isLinear: true, evaluated binding exp: 0.5403023058681398
 p3: number of uses: 0, isLinear: true, evaluated binding exp: 1.5574077246549023
 p4: number of uses: 0, isLinear: true, evaluated binding exp: 0.3046926540153975
 p5: number of uses: 0, isLinear: true, evaluated binding exp: 1.2661036727794992
 p6: number of uses: 0, isLinear: true, evaluated binding exp: 0.2914567944778671
 p7: number of uses: 0, isLinear: true, evaluated binding exp: 0.5404195002705842
 p8: number of uses: 0, isLinear: true, evaluated binding exp: 1.1752011936438014
 p9: number of uses: 0, isLinear: true, evaluated binding exp: 1.543080634815244
 p10: number of uses: 0, isLinear: true, evaluated binding exp: 0.7615941559557649
 p11: number of uses: 0, isLinear: true, evaluated binding exp: 2.7182818284590455
 p12: number of uses: 0, isLinear: true, evaluated binding exp: 0.0
 p13: number of uses: 0, isLinear: true, evaluated binding exp: 0.0

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 

Input variables: 
")})));
  end EvalTest1;

  model EvalTest2

    parameter Real p1 = 1*10^4;
  	

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="EvalTest2",
			methodName="variableDiagnostics",
			description="Test evaluation of independent parameters",
			methodResult="
Independent constants: 

Dependent constants: 

Independent parameters: 
 p1: number of uses: 0, isLinear: true, evaluated binding exp: 10000.0

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 

Input variables: 

")})));
  end EvalTest2;




  model LinearityTest1
  
  	Real x1;
  	Real x2;
  	Real x3;
  	Real x4;
  	Real x5;
  	Real x6;
  	Real x7;
  	
  	parameter Real p1 = 1;
  	  
  equation
  	x1 = x1*p1 + x2;
  	x2 = x3^2;
  	x3 = x4/p1;
  	x4 = p1/x5;
  	x5 = x6-x6;
  	x6 = sin(x7);
  	x7 = x3*x5;
  

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="LinearityTest1",
			methodName="variableDiagnostics",
			description="Test linearity of variables.",
			methodResult="  

Independent constants: 

Dependent constants: 

Independent parameters: 
 p1: number of uses: 3, isLinear: true, evaluated binding exp: 1

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 
 x1: number of uses: 2, isLinear: true, alias: no
 x2: number of uses: 2, isLinear: true, alias: no
 x3: number of uses: 3, isLinear: false, alias: no
 x4: number of uses: 2, isLinear: true, alias: no
 x5: number of uses: 3, isLinear: false, alias: no
 x6: number of uses: 3, isLinear: true, alias: no
 x7: number of uses: 2, isLinear: false, alias: no

Input variables: 
  ")})));
  end LinearityTest1;

  model AliasTest1
    Real x1 = 1;
    Real x2 = 1;
    Real x3,x4,x5,x6;
  equation
    x1 = -x3;
    -x1 = x4;
    x2 = -x5;
    x5 = x6;  
   

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest1",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x3,-x4}
{x2,-x5,-x6}
4 variables can be eliminated
")})));
  end AliasTest1;

  model AliasTest2
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest2",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,x3,x4}
3 variables can be eliminated
")})));
  end AliasTest2;

  model AliasTest3
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest3",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,-x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest3;

  model AliasTest4
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest4",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3,x4}
3 variables can be eliminated
")})));
  end AliasTest4;

  model AliasTest5
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest5",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest5;

  model AliasTest6
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    -x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest6",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest6;

  model AliasTest7
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    -x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest7",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,-x3,x4}
3 variables can be eliminated
")})));
  end AliasTest7;

  model AliasTest8
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    -x3 = x4;
    x1 = x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest8",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3,-x4}
3 variables can be eliminated
")})));
  end AliasTest8;

  model AliasTest9
    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    -x3 = x4;
    x1 = -x3;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest9",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3,x4}
3 variables can be eliminated
")})));
  end AliasTest9;

  model AliasTest10
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x3 = x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest10",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,x3}
2 variables can be eliminated
")})));
  end AliasTest10;

  model AliasTest11
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x3 = -x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest11",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,x2,-x3}
2 variables can be eliminated
")})));
  end AliasTest11;

  model AliasTest12
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = -x2;
    x3 = x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest12",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3}
2 variables can be eliminated
")})));
  end AliasTest12;

  model AliasTest13
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = -x2;
    x3 = -x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest13",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3}
2 variables can be eliminated
")})));
  end AliasTest13;

  model AliasTest14
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x3 = x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest14",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,x3}
2 variables can be eliminated
")})));
  end AliasTest14;

  model AliasTest15
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x3 = -x1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest15",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3}
2 variables can be eliminated
")})));
  end AliasTest15;

  model AliasTest16_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x2 = x3;
    x3=-x1;


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AliasTest16_Err",
			description="Test alias error.",
			errorMessage=" 1 error found...
Semantic error at line 0, column 0:
  Alias error: trying to add the negated alias pair (x3,-x1) to the alias set {x1,x2,x3}

")})));
  end AliasTest16_Err;

  model AliasTest17_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x2 = -x3;
    x3=x1;


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AliasTest17_Err",
			description="Test alias error.",
			errorMessage=" 
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  Alias error: trying to add the alias pair (x3,x1) to the alias set {x1,x2,-x3}

")})));
  end AliasTest17_Err;

  model AliasTest18_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = x3;
    x3=x1;


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AliasTest18_Err",
			description="Test alias error.",
			errorMessage=" 
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  Alias error: trying to add the alias pair (x3,x1) to the alias set {x1,-x2,-x3}

")})));
  end AliasTest18_Err;

  model AliasTest19_Err
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = -x3;
    x3=-x1;


	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AliasTest19_Err",
			description="Test alias error.",
			errorMessage=" 
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  Alias error: trying to add the negated alias pair (x3,-x1) to the alias set {x1,-x2,x3}

")})));
  end AliasTest19_Err;

  model AliasTest20
    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = -x3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest20",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest20
 Real x1;
equation 
 x1 = 1;

end TransformCanonicalTests.AliasTest20;

")})));
  end AliasTest20;

  model AliasTest21
    Real x1,x2,x3;
  equation
    0 = x1 + x2;
    x1 = 1;   
    x3 = x2^2;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest21",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2}
1 variables can be eliminated
")})));
  end AliasTest21;

  model AliasTest22
    Real x1,x2,x3;
  equation
    0 = x1 + x2;
    x1 = 1;   
    x3 = x2^2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest22",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest22
 Real x1;
 Real x3;
equation
 x1 = 1;
 x3 = (- x1) ^ 2;
end TransformCanonicalTests.AliasTest22;
")})));
  end AliasTest22;


  model AliasTest23
    Real x1,x2;
  equation
    x1 = -x2;
    der(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest23",
			description="Test elimination of alias variables",
			automatic_add_initial_equations=false,
			flatModel="
fclass TransformCanonicalTests.AliasTest23
 Real x1;
equation
 - der(x1) = 0;
end TransformCanonicalTests.AliasTest23;
")})));
  end AliasTest23;

  model AliasTest24
    Real x1,x2;
    input Real u;
  equation
    x2 = u;
    der(x1) = u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest24",
			description="Test elimination of alias variables",
			automatic_add_initial_equations=false,
			flatModel="
fclass TransformCanonicalTests.AliasTest24
 Real x1;
 input Real u;
equation 
 der(x1) = u;

end TransformCanonicalTests.AliasTest24;
")})));
end AliasTest24;


  model AliasTest25
    Real x1(fixed=false);
    Real x2(fixed =true);
    Real x3;
  equation
    der(x3) = 1;
    x1 = x3;
    x2 = x1;	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest25",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest25
 Real x2(fixed = true);
initial equation 
 x2 = 0.0;
equation 
 der(x2) = 1;

end TransformCanonicalTests.AliasTest25;
")})));
end AliasTest25;

model AliasTest26
 parameter Real p = 1;
 Real x,y;
equation
 x = p;
 y = x+3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest26",
			description="Test elimination of alias variables",
			flatModel="
fclass TransformCanonicalTests.AliasTest26
 parameter Real p = 1 /* 1.0 */;
 Real y;
equation
 y = p + 3;

end TransformCanonicalTests.AliasTest26;
")})));
end AliasTest26;

model AliasTest27
 Real x1;
 Real x2;
 Real x3;
 Real x4;
 Real x5;
equation
 x4 = x5;
 x1 = x3;
 x2 = x4;
 x3 = x5;
 x3 =1;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest27",
			description="Test elimination of alias variables.",
			flatModel="
fclass TransformCanonicalTests.AliasTest27
 Real x1;
equation
 x1 = 1;

end TransformCanonicalTests.AliasTest27;
")})));
end AliasTest27;

model AliasTest28
 Real x,y;
 parameter Real p = 1;
equation
 x = -p;
 y = x + 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest28",
			description="Test elimination of alias variables.",
			flatModel="
fclass TransformCanonicalTests.AliasTest28
 Real y;
 parameter Real p = 1 /* 1 */;
equation
 y = - p + 1;
end TransformCanonicalTests.AliasTest28;
")})));
end AliasTest28;

model AliasTest29
 Real pml1;
 Real pml2;
 Real pml3;
 Real mpl1;
 Real mpl2;
 Real mpl3;
 Real mml1;
 Real mml2;
 Real mml3;
 Real pmr1;
 Real pmr2;
 Real pmr3;
 Real mpr1;
 Real mpr2;
 Real mpr3;
 Real mmr1;
 Real mmr2;
 Real mmr3;
equation
 pml1-pml2=0;
 pml3+pml2*pml2=0;
 cos(pml1)+pml3*pml3=0;

 -mpl1+mpl2=0;
 mpl3+mpl2*mpl2=0;
 cos(mpl1)+mpl3*mpl3=0;

 -mml1-mml2=0;
 mml3+mml2*mml2=0;
 cos(mml1)+mml3*mml3=0;

 0=pmr1-pmr2;
 pmr3+pmr2*pmr2=0;
 cos(pmr1)+pmr3*pmr3=0;

 0=-mpr1+mpr2;
 mpr3+mpr2*mpr2=0;
 cos(mpr1)+mpr3*mpr3=0;

 0=-mmr1-mmr2;
 mmr3+mmr2*mmr2=0;
  cos(mmr1)+mmr3*mmr3=0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest29",
			description="",
			flatModel="
fclass TransformCanonicalTests.AliasTest29
 Real pml1;
 Real pml3;
 Real mpl1;
 Real mpl3;
 Real mml1;
 Real mml3;
 Real pmr1;
 Real pmr3;
 Real mpr1;
 Real mpr3;
 Real mmr1;
 Real mmr3;
equation
 pml3 + pml1 * pml1 = 0;
 cos(pml1) + pml3 * pml3 = 0;
 mpl3 + mpl1 * mpl1 = 0;
 cos(mpl1) + mpl3 * mpl3 = 0;
 mml3 + (- mml1) * (- mml1) = 0;
 cos(mml1) + mml3 * mml3 = 0;
 pmr3 + pmr1 * pmr1 = 0;
 cos(pmr1) + pmr3 * pmr3 = 0;
 mpr3 + mpr1 * mpr1 = 0;
 cos(mpr1) + mpr3 * mpr3 = 0;
 mmr3 + (- mmr1) * (- mmr1) = 0;
 cos(mmr1) + mmr3 * mmr3 = 0;
end TransformCanonicalTests.AliasTest29;
")})));
end AliasTest29;

model AliasTest30
  parameter Boolean f = true;
  Real x(start=3,fixed=f);
  Real y;
  parameter Real p = 5;
equation
 der(x) = -y;
  x= p;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AliasTest30",
			description="",
			flatModel="
fclass TransformCanonicalTests.AliasTest30
 parameter Boolean f = true /* true */;
 Real y;
 parameter Real p = 5 /* 5 */;
equation
 0.0 = - y;
end TransformCanonicalTests.AliasTest30;
")})));
end AliasTest30;

model AliasTest31
 Real x1;
 Real x2;
 Real x3;
 Real x4;
equation
 x1 = -x2;
 x3 = -x4;
 x2 = -x4;
 x3 =1;


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="AliasTest31",
			methodName="aliasDiagnostics",
			description="Test computation of alias sets.",
			methodResult="
Alias sets:
{x1,-x2,-x3,x4}
3 variables can be eliminated
")})));
end AliasTest31;

model AliasFuncTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AliasFuncTest1",
         description="",
         flatModel="
fclass TransformCanonicalTests.AliasFuncTest1
 Real y[1].x;
 Real y[2].x;
 Real y[3].x;
 Real z;
 Real temp_1[2];
 Real temp_1[3];
 Real temp_2[1];
 Real temp_2[3];
 Real temp_3[1];
 Real temp_3[2];
equation
 ({y[1].x,temp_1[2],temp_1[3]}) = TransformCanonicalTests.AliasFuncTest1.f(z);
 ({temp_2[1],y[2].x,temp_2[3]}) = TransformCanonicalTests.AliasFuncTest1.f(z);
 ({temp_3[1],temp_3[2],y[3].x}) = TransformCanonicalTests.AliasFuncTest1.f(z);
 z = 1;

public
 function TransformCanonicalTests.AliasFuncTest1.f
  input Real a;
  output Real[3] b;
 algorithm
  b[1] := ( 1 ) * ( a );
  b[2] := ( 2 ) * ( a );
  b[3] := ( 3 ) * ( a );
  return;
 end TransformCanonicalTests.AliasFuncTest1.f;

end TransformCanonicalTests.AliasFuncTest1;
")})));

	function f
		input Real a;
		output Real[3] b;
	algorithm
		b := {1, 2, 3} * a;
	end f;
	
	model A
		Real x;
	end A;
	
	A[3] y(x=f(z));
	Real z = 1;
end AliasFuncTest1;


model ParameterBindingExpTest3_Warn

  parameter Real p;

	annotation(__JModelica(UnitTesting(tests={
		WarningTestCase(
			name="ParameterBindingExpTest3_Warn",
			description="Test errors in binding expressions.",
			errorMessage="
Warning: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ConstantEvalTests.mo':
At line 110, column 18:
  The parameter p does not have a binding expression.
")})));
end ParameterBindingExpTest3_Warn;


model AttributeBindingExpTest1_Err

  Real p1;
  Real x(start=p1);
equation
  der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AttributeBindingExpTest1_Err",
			description="Test errors in binding expressions.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1057, column 16:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1
")})));
end AttributeBindingExpTest1_Err;

model AttributeBindingExpTest2_Err


  Real p1;
  Real x(start=p1+2);
equation
  der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AttributeBindingExpTest2_Err",
			description="Test errors in binding expressions..",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1079, column 16:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1 + 2
")})));
end AttributeBindingExpTest2_Err;

model AttributeBindingExpTest3_Err

  Real p1;
  Real x(start=p1+2+p);
equation
  der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AttributeBindingExpTest3_Err",
			description="Test errors in binding expressions..",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1099, column 16:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1 + 2 + p
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1099, column 21:
  Cannot find class or component declaration for p
")})));
end AttributeBindingExpTest3_Err;

model AttributeBindingExpTest4_Err

  parameter Real p1 = p2;
  parameter Real p2 = p1;

  Real x(start=p1);
equation
  der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AttributeBindingExpTest4_Err",
			description="Test errors in binding expressions..",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1122, column 23:
  Circularity in binding expression of parameter: p1 = p2
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1127, column 23:
  Circularity in binding expression of parameter: p2 = p1
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1123, column 25:
  Could not evaluate binding expression for attribute 'start' due to circularity: p1
")})));
end AttributeBindingExpTest4_Err;

model AttributeBindingExpTest5_Err

  model A
    Real p1;
    Real x(start=p1) = 2;
  end A;

  Real p2;	
  A a(x(start=p2));

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AttributeBindingExpTest5_Err",
			description="Test errors in binding expressions..",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1147, column 18:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p1
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 1151, column 15:
  Variability of binding expression for attribute 'start' is not less than or equal to parameter variability: p2
")})));
end AttributeBindingExpTest5_Err;

model IncidenceTest1

 Real x(start=1);
 Real y;
 input Real u;
equation
 der(x) = -x + u;
 y = x^2;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="IncidenceTest1",
			methodName="incidence",
			description="Test computation of incidence information",
			methodResult="
Incidence:
 eq 0: der(x) 
 eq 1: y 
")})));
end IncidenceTest1;


model IncidenceTest2
 Real x(start=1);
 Real y,z;
 input Real u;
equation
 z+der(x) = -sin(x) + u;
 y = x^2;
 z = 4;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="IncidenceTest2",
			methodName="incidence",
			description="Test computation of incidence information",
			methodResult="
Incidence:
 eq 0: der(x) z 
 eq 1: y 
 eq 2: z 
")})));
end IncidenceTest2;

model IncidenceTest3

 Real x[2](each start=1);
 Real y;
 input Real u;

 parameter Real A[2,2] = {{-1,0},{1,-1}};
 parameter Real B[2] = {1,2};
 parameter Real C[2] = {1,-1};
 parameter Real D = 0;
equation
 der(x) = A*x+B*u;
 y = C*x + D*u;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="IncidenceTest3",
			methodName="incidence",
			description="Test computation of incidence information",
			methodResult="
Incidence:
 eq 0: der(x[1]) 
 eq 1: der(x[2]) 
 eq 2: y 
")})));
end IncidenceTest3;

model DiffsAndDersTest1

 Real x[2](each start=1);
 Real y;
 input Real u;

 parameter Real A[2,2] = {{-1,0},{1,-1}};
 parameter Real B[2] = {1,2};
 parameter Real C[2] = {1,-1};
 parameter Real D = 0;
equation
 der(x) = A*x+B*u;
 y = C*x + D*u;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="DiffsAndDersTest1",
			methodName="dersAndDiffs",
			description="Test that derivatives and differentiated variables can be cross referenced",
			methodResult="
Derivatives and differentiated variables:
 der(x[1]), x[1]
 der(x[2]), x[2]
Differentiated variables and derivatives:
 x[1], der(x[1])
 x[2], der(x[2])
")})));
end DiffsAndDersTest1;

  model InitialEqTest1
    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest1",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest1
 Real x1(start = 1);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest1;
")})));
  end InitialEqTest1;

  model InitialEqTest2

    Real v1;
    Real v2;
    Real v3;
    Real v4;
    Real v5;
    Real v6;
    Real v7;
    Real v8;
    Real v9;	
    Real v10;	
  equation
    v1 + v2 + v3 + v4 + v5 = 1;
    v1 + v2 + v3 + v4 + v6 = 1;
    v1 + v2 + v3 + v4 = 1;
    v1 + v2 + v3 + v4 = 1;
    v5 + v6 + v8 + v7 + v9 = 1;
    v5 + v6 + v8 = 0;
    v1 = 1;
    v2 = 1;
    v9 + v10 = 1;
    v10 = 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest2",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest2
 Real v1;
 Real v2;
 Real v3;
 Real v4;
 Real v5;
 Real v6;
 Real v7;
 Real v8;
 Real v9;
 Real v10;
equation
 v1 + v2 + v3 + v4 + v5 = 1;
 v1 + v2 + v3 + v4 + v6 = 1;
 v1 + v2 + v3 + v4 = 1;
 v1 + v2 + v3 + v4 = 1;
 v5 + v6 + v8 + v7 + v9 = 1;
 v5 + v6 + v8 = 0;
 v1 = 1;
 v2 = 1;
 v9 + v10 = 1;
 v10 = 1;

end TransformCanonicalTests.InitialEqTest2;
")})));
  end InitialEqTest2;

  model InitialEqTest3

    Real x1(start=1,fixed=true);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest3",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest3
 Real x1(start = 1,fixed = true);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest3;
")})));
  end InitialEqTest3;

  model InitialEqTest4
    Real x1(start=1,fixed=true);
    Real x2(start=2,fixed=true);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest4",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest4
 Real x1(start = 1,fixed = true);
 Real x2(start = 2,fixed = true);
 Real y1;
 Real y2;
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest4;
")})));
  end InitialEqTest4;

  model InitialEqTest5
    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
   initial equation
    der(x1) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest5",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest5
 Real x1(start = 1);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 der(x1) = 0;
 x2 = 2;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest5;
")})));
  end InitialEqTest5;

  model InitialEqTest6
    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
   initial equation
    der(x1) = 0;
    y2 = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest6",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest6
 Real x1(start = 1);
 Real x2(start = 2);
 Real y1;
 Real y2;
initial equation 
 der(x1) = 0;
 y2 = 0;
equation
 der(x1) = x1 + x2 + y1;
 der(x2) = x1 - x2 + y2;
 y1 = 3 * x1;
 y2 = 4 * x2;
end TransformCanonicalTests.InitialEqTest6;
")})));
  end InitialEqTest6;

  function f1
    input Real x;
    input Real y;
    output Real w;
    output Real z;
  algorithm
   w := x;
   z := y;
  end f1;

  model InitialEqTest7
    Real x, y;
  equation
    (x,y) = f1(1,2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest7",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest7
 Real x;
 Real y;
equation
 (x, y) = TransformCanonicalTests.f1(1, 2);

public
 function TransformCanonicalTests.f1
  input Real x;
  input Real y;
  output Real w;
  output Real z;
 algorithm
  w := x;
  z := y;
  return;
 end TransformCanonicalTests.f1;

end TransformCanonicalTests.InitialEqTest7;
")})));
  end InitialEqTest7;

  model InitialEqTest8
    Real x, y;
  equation
    der(x) = -x;
    der(y) = -y;
  initial equation
    (x,y) = f1(1,2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest8",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest8
 Real x;
 Real y;
initial equation 
 (x, y) = TransformCanonicalTests.f1(1, 2);
equation
 der(x) = - x;
 der(y) = - y;

public
 function TransformCanonicalTests.f1
  input Real x;
  input Real y;
  output Real w;
  output Real z;
 algorithm
  w := x;
  z := y;
  return;
 end TransformCanonicalTests.f1;

end TransformCanonicalTests.InitialEqTest8;
")})));
  end InitialEqTest8;

  function f2
    input Real x[3];
    input Real y[4];
    output Real w[3];
    output Real z[4];
  algorithm
   w := x;
   z := y;
  end f2;

  model InitialEqTest9
    Real x[3], y[4];
  equation
    (x,y) = f2(ones(3),ones(4));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest9",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest9
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
equation
 ({x[1],x[2],x[3]}, {y[1],y[2],y[3],y[4]}) = TransformCanonicalTests.f2({1,1,1}, {1,1,1,1});

public
 function TransformCanonicalTests.f2
  input Real[3] x;
  input Real[4] y;
  output Real[3] w;
  output Real[4] z;
 algorithm
  w[1] := x[1];
  w[2] := x[2];
  w[3] := x[3];
  z[1] := y[1];
  z[2] := y[2];
  z[3] := y[3];
  z[4] := y[4];
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest9;
")})));
  end InitialEqTest9;

  model InitialEqTest10
    Real x[3], y[4];
  initial equation
    (x,y) = f2(ones(3),ones(4));
  equation
    der(x) = -x;
    der(y) = -y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest10",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest10
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
initial equation 
 ({x[1], x[2], x[3]}, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
 der(y[1]) = - y[1];
 der(y[2]) = - y[2];
 der(y[3]) = - y[3];
 der(y[4]) = - y[4];

public
 function TransformCanonicalTests.f2
  input Real[3] x;
  input Real[4] y;
  output Real[3] w;
  output Real[4] z;
 algorithm
  w[1] := x[1];
  w[2] := x[2];
  w[3] := x[3];
  z[1] := y[1];
  z[2] := y[2];
  z[3] := y[3];
  z[4] := y[4];
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest10;
")})));
  end InitialEqTest10;

  model InitialEqTest11
    Real x[3], y[4];
  initial equation
    (x,) = f2(ones(3),ones(4));
  equation
    der(x) = -x;
    (,y) = f2(ones(3),ones(4));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest11",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest11
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
initial equation 
 ({x[1], x[2], x[3]}, ) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
 (, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});

public
 function TransformCanonicalTests.f2
  input Real[3] x;
  input Real[4] y;
  output Real[3] w;
  output Real[4] z;
 algorithm
  w[1] := x[1];
  w[2] := x[2];
  w[3] := x[3];
  z[1] := y[1];
  z[2] := y[2];
  z[3] := y[3];
  z[4] := y[4];
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest11;
")})));
  end InitialEqTest11;

  model InitialEqTest12
    Real x[3](each start=3), y[4];
  equation
    der(x) = -x;
    (,y) = f2(ones(3),ones(4));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest12",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest12
 Real x[1](start = 3);
 Real x[2](start = 3);
 Real x[3](start = 3);
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
initial equation 
 x[1] = 3;
 x[2] = 3;
 x[3] = 3;
equation
 der(x[1]) = - x[1];
 der(x[2]) = - x[2];
 der(x[3]) = - x[3];
 (, {y[1], y[2], y[3], y[4]}) = TransformCanonicalTests.f2({1, 1, 1}, {1, 1, 1, 1});

public
 function TransformCanonicalTests.f2
  input Real[3] x;
  input Real[4] y;
  output Real[3] w;
  output Real[4] z;
 algorithm
  w[1] := x[1];
  w[2] := x[2];
  w[3] := x[3];
  z[1] := y[1];
  z[2] := y[2];
  z[3] := y[3];
  z[4] := y[4];
  return;
 end TransformCanonicalTests.f2;

end TransformCanonicalTests.InitialEqTest12;
")})));
  end InitialEqTest12;

  model InitialEqTest13
    Real x1 (start=1);
    Real x2 (start=2);
  equation
    der(x1) = -x1;
    der(x2) = x1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest13",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest13
 Real x1(start = 1);
 Real x2(start = 2);
initial equation 
 x1 = 1;
 x2 = 2;
equation
 der(x1) = - x1;
 der(x2) = x1;
end TransformCanonicalTests.InitialEqTest13;
")})));
  end InitialEqTest13;

  model InitialEqTest14
  model M
    Real t(start=0);
    discrete Real x1 (start=1,fixed=true);
    discrete Boolean b1 (start=false,fixed=true);
    input Boolean ub1;
    discrete Integer i1 (start=4,fixed=true);
    input Integer ui1;
    discrete Real x2 (start=2);
  equation
    der(t) = 1;
    when time>1 then
      b1 = true;
      i1 = 3;
      x1 = pre(x1) + 1;
      x2 = pre(x2) + 1;
    end when;
  end M;
  input Boolean ub1;
  input Integer ui1;
  M m(ub1=ub1,ui1=ui1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest14",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
fclass TransformCanonicalTests.InitialEqTest14
 discrete input Boolean ub1;
 discrete input Integer ui1;
 Real m.t(start = 0);
 discrete Real m.x1(start = 1,fixed = true);
 discrete Boolean m.b1(start = false,fixed = true);
 discrete Integer m.i1(start = 4,fixed = true);
 discrete Real m.x2(start = 2);
initial equation 
 m.pre(x1) = 1;
 m.pre(i1) = 4;
 m.pre(b1) = false;
 m.t = 0;
 m.pre(x2) = 2;
equation
 m.der(t) = 1;
 when time > 1 then
  m.b1 = true;
 end when;
 when time > 1 then
  m.i1 = 3;
 end when;
 when time > 1 then
  m.x1 = m.pre(x1) + 1;
 end when;
 when time > 1 then
  m.x2 = m.pre(x2) + 1;
 end when;

end TransformCanonicalTests.InitialEqTest14;
")})));
  end InitialEqTest14;

/*
  model InitialEqTest15
  function F
    input Integer x1;
    input Integer x2;
    output Integer y1;
    output Integer y2;
  algorithm
    y1 := 2*x1;
    y2 := 3*x2;
  end F;

  model M
    Real t(start=0);
    discrete Real x1 (start=1,fixed=true);
    discrete Boolean b1 (start=false,fixed=true);
    discrete input Boolean ub1;
    discrete Integer i1 (start=4,fixed=true);
    discrete Integer i2 (start=4);
    discrete Integer i3 (start=4);
    discrete input Integer ui1;
    discrete Real x2 (start=2);
  equation
    der(t) = 1;
    when time>1 then
      b1 = true;
      i1 = 3;
      x1 = pre(x1) + 1;
      x2 = pre(x2) + 1;
      (i2,i3) = F(pre(i1)+1,pre(i2)+1);
    end when;
  end M;
  discrete input Boolean ub1;
  discrete input Integer ui1;
  M m(ub1=ub1,ui1=ui1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InitialEqTest15",
			description="Test algorithm for adding additional initial equations.",
			flatModel="
")})));
  end InitialEqTest15;
*/

model ParameterDerivativeTest
 Real x(start=1);
 Real y;
 parameter Real p = 2;
equation
 y = der(x) + der(p);
 x = p;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ParameterDerivativeTest",
			description="Test that derivatives of parameters are translated into zeros.",
			flatModel="
fclass TransformCanonicalTests.ParameterDerivativeTest
 Real y;
 parameter Real p = 2 /* 2 */;
equation
 y = 0.0 + 0.0;

end TransformCanonicalTests.ParameterDerivativeTest;
")})));
end ParameterDerivativeTest;

model UnbalancedTest1_Err
  Real x = 1;
  Real y;
  Real z;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnbalancedTest1_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
Error: in file 'TransformCanonicalTests.UnbalancedTest1_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 1 equations and 3 free variables.

Error: in file 'TransformCanonicalTests.UnbalancedTest1_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singular. The following varible(s) could not be matched to any equation:
   y
   z
")})));
end UnbalancedTest1_Err;

model UnbalancedTest2_Err
  Real x;
  Real y;
equation
  x = 1;
  x = 1+2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnbalancedTest2_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
Error: in file 'TransformCanonicalTests.UnbalancedTest2_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singular. The following varible(s) could not be matched to any equation:
   y

  The follwowing equation(s) could not be matched to any variable:
   x = 1 + 2
")})));
end UnbalancedTest2_Err;

model UnbalancedTest3_Err
  Real x;
equation
  x = 4;
  x = 5;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnbalancedTest3_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
Error: in file 'TransformCanonicalTests.UnbalancedTest3_Err.mof':
Semantic error at line 0, column 0:
  The DAE initialization system has 2 equations and 1 free variables.

Error: in file 'TransformCanonicalTests.UnbalancedTest3_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 2 equations and 1 free variables.

Error: in file 'TransformCanonicalTests.UnbalancedTest3_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singular. The following equation(s) could not be matched to any variable:
   x = 5
")})));
end UnbalancedTest3_Err;

model UnbalancedTest4_Err
  Real x;
equation

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnbalancedTest4_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file 'TransformCanonicalTests.UnbalancedTest4_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 0 equations and 1 free variables.

Error: in file 'TransformCanonicalTests.UnbalancedTest4_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singular. The following varible(s) could not be matched to any equation:
   x
")})));
end UnbalancedTest4_Err;

model UnbalancedTest5_Err
    Real x = 0;
    Boolean y = false;
equation
    x = if y then 1 else 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnbalancedTest5_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc3729100224648595936out/sources/TransformCanonicalTests.UnbalancedTest5_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 3 equations and 2 free variables.

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc3729100224648595936out/sources/TransformCanonicalTests.UnbalancedTest5_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singular. The following equation(s) could not be matched to any variable:
   x = 0
")})));
end UnbalancedTest5_Err;

model WhenEqu15
	discrete Real x[3];
        Real z[3];
equation
	der(z) = z .* { 0.1, 0.2, 0.3 };
	when { z[i] > 2 for i in 1:3 } then
		x = 1:3;
	elsewhen { z[i] < 0 for i in 1:3 } then
		x = 4:6;
	elsewhen sum(z) > 4.5 then
		x = 7:9;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="WhenEqu15",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu15
 discrete Real x[3];
 Real z[3];
equation
 der(z[1:3]) = z[1:3] .* {0.1, 0.2, 0.3};
 when {z[i] > 2 for i in 1:3} then
  x[1:3] = 1:3;
 elsewhen {z[i] < 0 for i in 1:3} then
  x[1:3] = 4:6;
 elsewhen sum(z[1:3]) > 4.5 then
  x[1:3] = 7:9;
 end when;
end TransformCanonicalTests.WhenEqu15;
")})));
end WhenEqu15;

model WhenEqu1
	discrete Real x[3];
        Real z[3];
equation
	der(z) = z .* { 0.1, 0.2, 0.3 };
	when { z[i] > 2 for i in 1:3 } then
		x = 1:3;
	elsewhen { z[i] < 0 for i in 1:3 } then
		x = 4:6;
	elsewhen sum(z) > 4.5 then
		x = 7:9;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu1",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu1
 discrete Real x[1];
 discrete Real x[2];
 discrete Real x[3];
 Real z[1];
 Real z[2];
 Real z[3];
initial equation 
 z[1] = 0.0;
 z[2] = 0.0;
 z[3] = 0.0;
 pre(x[1]) = 0.0;
 pre(x[2]) = 0.0;
 pre(x[3]) = 0.0;
equation
 der(z[1]) = z[1] .* 0.1;
 der(z[2]) = z[2] .* 0.2;
 der(z[3]) = z[3] .* 0.3;
 when {z[1] > 2, z[2] > 2, z[3] > 2} then
  x[1] = 1;
 elsewhen {z[1] < 0, z[2] < 0, z[3] < 0} then
  x[1] = 4;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[1] = 7;
 end when;
 when {z[1] > 2, z[2] > 2, z[3] > 2} then
  x[2] = 2;
 elsewhen {z[1] < 0, z[2] < 0, z[3] < 0} then
  x[2] = 5;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[2] = 8;
 end when;
 when {z[1] > 2, z[2] > 2, z[3] > 2} then
  x[3] = 3;
 elsewhen {z[1] < 0, z[2] < 0, z[3] < 0} then
  x[3] = 6;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[3] = 9;
 end when;
end TransformCanonicalTests.WhenEqu1;
")})));
end WhenEqu1;

model WhenEqu2
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
when (time>1 and time<1.1) or  (time>2 and time<2.1) or  (time>3 and time<3.1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu2",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu2
 Real xx(start = 2);
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
initial equation 
 xx = 2;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
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
 when time > 1 and time < 1.1 or time > 2 and time < 2.1 or time > 3 and time < 3.1 then
  x = pre(x) + 1.1;
 end when;
 when time > 1 and time < 1.1 or time > 2 and time < 2.1 or time > 3 and time < 3.1 then
  y = pre(y) + 1.1;
 end when;
end TransformCanonicalTests.WhenEqu2;
")})));
end WhenEqu2;

model WhenEqu3
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true);
discrete Boolean b1; 
equation
der(xx) = -x; 
when b1 and pre(z) then 
w = false; 
end when; 
when b1 and z then 
v = false; 
end when; 
when b1 then 
z = false; 
end when; 
when (time>1 and time<1.1) or  (time>2 and time<2.1) or  (time>3 and time<3.1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 
b1 = y>2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu3",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu3
 Real xx(start = 2);
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
 discrete Boolean b1;
initial equation 
 xx = 2;
 pre(x) = 0.0;
 pre(y) = 0.0;
 pre(w) = true;
 pre(v) = true;
 pre(z) = true;
 pre(b1) = false;
equation
 der(xx) = - x;
 when b1 and pre(z) then
  w = false;
 end when;
 when b1 and z then
  v = false;
 end when;
 when b1 then
  z = false;
 end when;
 when time > 1 and time < 1.1 or time > 2 and time < 2.1 or time > 3 and time < 3.1 then
  x = pre(x) + 1.1;
 end when;
 when time > 1 and time < 1.1 or time > 2 and time < 2.1 or time > 3 and time < 3.1 then
  y = pre(y) + 1.1;
 end when;
 b1 = y > 2;
end TransformCanonicalTests.WhenEqu3;
")})));
end WhenEqu3;

model WhenEqu4
  discrete Real x,y,z,v;
  Real t;
equation
  der(t) = 1;
  when time>3 then 
    x = 1;
    y = 2;
    z = 3;
    v = 4;
  elsewhen time>4 then
    v = 1;
    z = 2;
    y = 3;
    x = 4;
  end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu4",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
fclass TransformCanonicalTests.WhenEqu4
discrete Real x;
discrete Real y;
discrete Real z;
discrete Real v;
Real t;
initial equation 
t = 0.0;
pre(x) = 0.0;
pre(y) = 0.0;
pre(z) = 0.0;
pre(v) = 0.0;
equation
der(t) = 1;
when time > 3 then
x = 1;
elsewhen time > 4 then
x = 4;
end when;
when time > 3 then
y = 2;
elsewhen time > 4 then
y = 3;
end when;
when time > 3 then
z = 3;
elsewhen time > 4 then
z = 2;
end when;
when time > 3 then
v = 4;
elsewhen time > 4 then
v = 1;
end when;

end TransformCanonicalTests.WhenEqu4;
")})));
end WhenEqu4;


model WhenEqu45
  type E = enumeration(a,b,c);
  discrete E e (start=E.b);
  Real t(start=0);
equation
  der(t) = 1;
  when time>1 then
    e = E.c;
  end when;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu45",
			description="Basic test of when equations",
			equation_sorting=true,
			flatModel="
		 
fclass TransformCanonicalTests.WhenEqu45
 discrete TransformCanonicalTests.WhenEqu45.E e(start = TransformCanonicalTests.WhenEqu45.E.b);
 Real t(start = 0);
initial equation 
 t = 0;
 pre(e) = TransformCanonicalTests.WhenEqu45.E.b;
equation
 der(t) = 1;
 when time > 1 then
  e = TransformCanonicalTests.WhenEqu45.E.c;
 end when;

public
 type TransformCanonicalTests.WhenEqu45.E = enumeration(a, b, c);

end TransformCanonicalTests.WhenEqu45;
		 
")})));
end WhenEqu45;

model WhenEqu5 

Real x(start = 1); 
discrete Real a(start = 1.0); 
discrete Boolean z(start = false); 
discrete Boolean y(start = false); 
discrete Boolean h1,h2; 
equation 
der(x) = a * x; 
h1 = x >= 2; 
h2 = der(x) >= 4; 
when h1 then 
y = true; 
end when; 
when y then 
a = 2; 
end when; 
when h2 then 
z = true; 
end when; 

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu5",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu5
 Real x(start = 1);
 discrete Real a(start = 1.0);
 discrete Boolean z(start = false);
 discrete Boolean y(start = false);
 discrete Boolean h1;
 discrete Boolean h2;
initial equation 
 x = 1;
 pre(a) = 1.0;
 pre(z) = false;
 pre(y) = false;
 pre(h1) = false;
 pre(h2) = false;
equation
 der(x) = a * x;
 h1 = x >= 2;
 h2 = der(x) >= 4;
 when h1 then
  y = true;
 end when;
 when y then
  a = 2;
 end when;
 when h2 then
  z = true;
 end when;
end TransformCanonicalTests.WhenEqu5;
")})));
end WhenEqu5; 

model WhenEqu7 

 discrete Real x(start=0);
 Real dummy;
equation
 der(dummy) = 0;
 when dummy>-1 then
   x = pre(x) + 1;
 end when;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu7",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu7
 discrete Real x(start = 0);
 Real dummy;
initial equation 
 dummy = 0.0;
 pre(x) = 0;
equation
 der(dummy) = 0;
 when dummy > - 1 then
  x = pre(x) + 1;
 end when;
end TransformCanonicalTests.WhenEqu7;
")})));
end WhenEqu7; 

model WhenEqu8 

 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when sample(0,2/3) then
   y = pre(y) + 1;
 end when;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu8",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu8
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
 when sample(0, 2 / 3) then
  y = pre(y) + 1;
 end when;
end TransformCanonicalTests.WhenEqu8;
")})));
end WhenEqu8; 

model WhenEqu9 

 Real x,ref;
 discrete Real I;
 discrete Real u;

 parameter Real K = 1;
 parameter Real Ti = 0.1;
 parameter Real h = 0.05;

equation
 der(x) = -x + u;
 when sample(0,h) then
   I = pre(I) + h*(ref-x);
   u = K*(ref-x) + 1/Ti*I;
 end when;
 ref = if time <1 then 0 else 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu9",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu9
 Real x;
 Real ref;
 discrete Real I;
 discrete Real u;
 parameter Real K = 1 /* 1 */;
 parameter Real Ti = 0.1 /* 0.1 */;
 parameter Real h = 0.05 /* 0.05 */;
initial equation 
 x = 0.0;
 pre(I) = 0.0;
 pre(u) = 0.0;
equation
 der(x) = - x + u;
 when sample(0, h) then
  I = pre(I) + h * (ref - x);
 end when;
 when sample(0, h) then
  u = K * (ref - x) + 1 / Ti * I;
 end when;
 ref = if time < 1 then 0 else 1;
end TransformCanonicalTests.WhenEqu9;
")})));
end WhenEqu9; 

model WhenEqu10

 discrete Boolean sampleTrigger;
 Real x_p(start=1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
initial equation
 x_c = pre(x_c); 	
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {initial(),sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu10",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu10
 discrete Boolean sampleTrigger;
 Real x_p(start = 1,fixed = true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = - 1 /* -1 */;
 parameter Real b_p = 1 /* 1 */;
 parameter Real c_p = 1 /* 1 */;
 parameter Real a_c = 0.8 /* 0.8 */;
 parameter Real b_c = 1 /* 1 */;
 parameter Real c_c = 1 /* 1 */;
 parameter Real h = 0.1 /* 0.1 */;
initial equation 
 x_c = pre(x_c);
 x_p = 1;
 pre(sampleTrigger) = false;
 pre(u_c) = 0.0;
equation
 der(x_p) = a_p * x_p + b_p * u_p;
 u_p = c_c * x_c;
 sampleTrigger = sample(0, h);
 when {initial(), sampleTrigger} then
  u_c = c_p * x_p;
 end when;
 when {initial(), sampleTrigger} then
  x_c = a_c * pre(x_c) + b_c * u_c;
 end when;
end TransformCanonicalTests.WhenEqu10;
")})));
end WhenEqu10;

model WhenEqu11	
		
 discrete Boolean sampleTrigger;
 Real x_p(start=1);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
 discrete Boolean atInit = true and initial();
initial equation
 x_c = pre(x_c); 	
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {atInit,sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu11",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu11
 discrete Boolean sampleTrigger;
 Real x_p(start = 1);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = - 1 /* -1 */;
 parameter Real b_p = 1 /* 1 */;
 parameter Real c_p = 1 /* 1 */;
 parameter Real a_c = 0.8 /* 0.8 */;
 parameter Real b_c = 1 /* 1 */;
 parameter Real c_c = 1 /* 1 */;
 parameter Real h = 0.1 /* 0.1 */;
 discrete Boolean atInit;
initial equation 
 x_c = pre(x_c);
 x_p = 1;
 pre(sampleTrigger) = false;
 pre(u_c) = 0.0;
 pre(atInit) = false;
equation
 der(x_p) = a_p * x_p + b_p * u_p;
 u_p = c_c * x_c;
 sampleTrigger = sample(0, h);
 when {atInit, sampleTrigger} then
  u_c = c_p * x_p;
 end when;
 when {atInit, sampleTrigger} then
  x_c = a_c * pre(x_c) + b_c * u_c;
 end when;
 atInit = true and initial();
end TransformCanonicalTests.WhenEqu11;
")})));
end WhenEqu11;

model WhenEqu12
	
	function F
		input Real x;
		output Real y1;
		output Real y2;
	algorithm
		y1 := 1;
		y2 := 2;
	end F;
	Real x,y;
	equation
	when sample(0,1) then
		(x,y) = F(time);
	end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu12",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu12
 discrete Real x;
 discrete Real y;
initial equation 
 pre(x) = 0.0;
 pre(y) = 0.0;
equation
 when sample(0, 1) then
  (x, y) = TransformCanonicalTests.WhenEqu12.F(time);
 end when;

public
 function TransformCanonicalTests.WhenEqu12.F
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := 1;
  y2 := 2;
  return;
 end TransformCanonicalTests.WhenEqu12.F;
 end TransformCanonicalTests.WhenEqu12;
")})));		
end WhenEqu12;

model WhenEqu13
Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
initial equation
 v1 = if 0<=0 then 0 else 1;
 v2 = if 0<0 then 0 else 1;
 v3 = if 0>=0 then 0 else 1;
 v4 = if 0>0 then 0 else 1;
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = if y<=0 then 0 else 1;
 der(v2) = if y<0 then 0 else 1;
 der(v3) = if y>=0 then 0 else 1;
 der(v4) = if y>0 then 0 else 1;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEqu13",
			description="Basic test of when equations",
			flatModel="
fclass TransformCanonicalTests.WhenEqu13
 Real v1(start = - 1);
 Real v2(start = - 1);
 Real v3(start = - 1);
 Real v4(start = - 1);
 discrete Real y(start = 1);
 discrete Integer i(start = 0);
 discrete Boolean up(start = true);
initial equation 
 v1 = 0;
 v2 = 1;
 v3 = 0;
 v4 = 1;
 pre(y) = 1;
 pre(i) = 0;
 pre(up) = true;
equation
 when sample(0.1, 1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
 end when;
 when sample(0.1, 1) then
  up = if pre(i) == 2 then false elseif pre(i) == - 2 then true else pre(up);
 end when;
 when sample(0.1, 1) then
  y = i;
 end when;
 der(v1) = if y <= 0 then 0 else 1;
 der(v2) = if y < 0 then 0 else 1;
 der(v3) = if y >= 0 then 0 else 1;
 der(v4) = if y > 0 then 0 else 1;
end TransformCanonicalTests.WhenEqu13;
")})));		
end WhenEqu13;

model IfEqu1
	Real x[3];
equation
	if true then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="IfEqu1",
			description="If equations: flattening",
			flatModel="
fclass TransformCanonicalTests.IfEqu1
 Real x[3];
equation
 if true then
  x[1:3] = 1:3;
 elseif true then
  x[1:3] = 4:6;
 else
  x[1:3] = 7:9;
 end if;
end TransformCanonicalTests.IfEqu1;
")})));
end IfEqu1;


model IfEqu2
	Real x[3];
equation
	if true then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu2",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu2
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
end TransformCanonicalTests.IfEqu2;
")})));
end IfEqu2;


model IfEqu3
	Real x[3];
equation
	if false then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu3",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu3
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 4;
 x[2] = 5;
 x[3] = 6;
end TransformCanonicalTests.IfEqu3;
")})));
end IfEqu3;


model IfEqu4
	Real x[3];
equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu4",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu4
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 7;
 x[2] = 8;
 x[3] = 9;
end TransformCanonicalTests.IfEqu4;
")})));
end IfEqu4;


model IfEqu5
	Real x[3] = 7:9;
equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu5",
			description="If equations: branch elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu5
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = 7;
 x[2] = 8;
 x[3] = 9;
end TransformCanonicalTests.IfEqu5;
")})));
end IfEqu5;


model IfEqu6
	Real x[3];
	Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	else
		x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu6",
			description="If equations: scalarization without elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu6
 Real x[1];
 Real x[2];
 Real x[3];
 discrete Boolean y[1];
 discrete Boolean y[2];
initial equation 
 pre(y[1]) = false;
 pre(y[2]) = false;
equation
 x[1] = if y[1] then 1 elseif y[2] then 4 else 7;
 x[2] = if y[1] then 2 elseif y[2] then 5 else 8;
 x[3] = if y[1] then 3 elseif y[2] then 6 else 9;
 y[1] = false;
 y[2] = true;
end TransformCanonicalTests.IfEqu6;
")})));
end IfEqu6;


model IfEqu7
	Real x[3];
	Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
    else
	   	x = 7:9;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu7",
			description="If equations: scalarization without elimination",
			flatModel="
fclass TransformCanonicalTests.IfEqu7
 Real x[1];
 Real x[2];
 Real x[3];
 discrete Boolean y[1];
 discrete Boolean y[2];
initial equation 
 pre(y[1]) = false;
 pre(y[2]) = false;
equation
 x[1] = if y[1] then 1 elseif y[2] then 4 else 7;
 x[2] = if y[1] then 2 elseif y[2] then 5 else 8;
 x[3] = if y[1] then 3 elseif y[2] then 6 else 9;
 y[1] = false;
 y[2] = true;
end TransformCanonicalTests.IfEqu7;
")})));
end IfEqu7;


model IfEqu8
	Real x[3];
	parameter Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	else
		x = 7:9;
		x[2] = 10;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu8",
			description="If equations: branch elimination with parameter test expressions",
			flatModel="
fclass TransformCanonicalTests.IfEqu8
 Real x[1];
 Real x[2];
 Real x[3];
 parameter Boolean y[1] = false;
 parameter Boolean y[2] = true;
equation
 x[1] = 4;
 x[2] = 5;
 x[3] = 6;
end TransformCanonicalTests.IfEqu8;
")})));
end IfEqu8;


model IfEqu9
	Real x[2];
	Boolean y = true;
equation
	if false then
		x = 1:2;
	elseif y then
		x = 3:4;
	elseif false then
		x = 5:6;
	else
		x = 7:8;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu9",
			description="If equations: branch elimination with one test non-parameter",
			flatModel="
fclass TransformCanonicalTests.IfEqu9
 Real x[1];
 Real x[2];
 discrete Boolean y;
initial equation 
 pre(y) = false;
equation
 x[1] = if y then 3 else 7;
 x[2] = if y then 4 else 8;
 y = true;
end TransformCanonicalTests.IfEqu9;
")})));
end IfEqu9;


model IfEqu10
	Real x[2];
	Boolean y = true;
equation
	if false then
		x = 1:2;
	elseif y then
		x = 3:4;
	elseif true then
		x = 5:6;
	else
		x = 7:8;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu10",
			description="If equations: branch elimination with one test non-parameter",
			flatModel="
fclass TransformCanonicalTests.IfEqu10
 Real x[1];
 Real x[2];
 discrete Boolean y;
initial equation 
 pre(y) = false;
equation
 x[1] = if y then 3 else 5;
 x[2] = if y then 4 else 6;
 y = true;
end TransformCanonicalTests.IfEqu10;
")})));
end IfEqu10;


model IfEqu11
	Real x[2];
	Boolean y = true;
equation
	if true then
		x = 1:2;
	elseif y then
		x = 3:4;
	elseif false then
		x = 5:6;
	else
		x = 7:8;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu11",
			description="If equations: branch elimination with one test non-parameter",
			flatModel="
fclass TransformCanonicalTests.IfEqu11
 Real x[1];
 Real x[2];
 discrete Boolean y;
initial equation 
 pre(y) = false;
equation
 x[1] = 1;
 x[2] = 2;
 y = true;
end TransformCanonicalTests.IfEqu11;
")})));
end IfEqu11;

  model IfEqu12
	Real x(start=1);
    Real u;
  equation
    if time>=1 then
      u = -1;
    else
      u = 1;
    end if;
    der(x) = -x + u;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu12",
			description="Test of if equations.",
			flatModel="
fclass TransformCanonicalTests.IfEqu12
 Real x(start = 1);
 Real u;
initial equation 
 x = 1;
equation
 u = if time >= 1 then - 1 else 1;
 der(x) = - x + u;
end TransformCanonicalTests.IfEqu12;
")})));
  end IfEqu12;

  model IfEqu13
    Real x(start=1);
    Real u;
  equation
    if time>=1 then
      u = -1;
      der(x) = -3*x + u;
    else
      u = 1;
      der(x) = 3*x + u;
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu13",
			description="Test of if equations.",
			flatModel="
fclass TransformCanonicalTests.IfEqu13
 Real x(start = 1);
 Real u;
initial equation 
 x = 1;
equation
 der(x) = if time >= 1 then (- 3) * x + u else 3 * x + u;
 u = if time >= 1 then - 1 else 1;
end TransformCanonicalTests.IfEqu13;
")})));
  end IfEqu13;

  model IfEqu14
    Real x(start=1);
    Real u;
  equation
    if time>=1 then
      if time >=3then
        u = -1;
        der(x) = -3*x + u;
      else
        u=4;
        der(x) = 0;
      end if;
    else
      u = 1;
      der(x) = 3*x + u;
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu14",
			description="Test of if equations.",
			flatModel="
fclass TransformCanonicalTests.IfEqu14
 Real x(start = 1);
 Real u;
initial equation 
 x = 1;
equation
 der(x) = if time >= 1 then if time >= 3 then (- 3) * x + u else 0 else 3 * x + u;
 u = if time >= 1 then if time >= 3 then - 1 else 4 else 1;
end TransformCanonicalTests.IfEqu14;
")})));
  end IfEqu14;


  model IfEqu15
      Real x;
      Real y;
      Real z1;
      Real z2;
  equation
      if time < 1 then
          y = z2 - 1;
          z1 = 2;
          x = y * y;
          z1 + z2 = x + y;
      elseif time < 3 then
          x = y + 4;
          y = 2;
          z2 = y * x;
          z1 - z2 = x + y;
      else
          z2 = 4 * x;
          x = 4;
          y = x + 2;
          z1 + z2 = x - y;
      end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu15",
			description="If equation with mixed assignment equations and non-assignment equations",
			flatModel="
fclass TransformCanonicalTests.IfEqu15
 Real x;
 Real y;
 Real z1;
 Real z2;
equation
 x = if time < 1 then y * y elseif time < 3 then y + 4 else 4;
 y = if time < 1 then z2 - 1 elseif time < 3 then 2 else x + 2;
 0.0 = if time < 1 then z1 - 2 else z2 - (if time < 3 then y * x else 4 * x);
 0.0 = if time < 1 then z1 + z2 - (x + y) elseif time < 3 then z1 - z2 - (x + y) else z1 + z2 - (x - y);
end TransformCanonicalTests.IfEqu15;
")})));
  end IfEqu15;


  model IfEqu16
      Real x;
      Real y;
      Real z1;
      Real z2;
  equation
      if time < 1 then
          y = z2 - 1;
          z1 = 2;
          x = y * y;
          z1 + z2 = x + y;
      else
          x = 4;
          if time < 3 then
              y = 2;
              z1 = y * x;
          else
              y = x + 2;
              z2 = 4 * x;
          end if;
          z1 + z2 = x - y;
      end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu16",
			description="Nestled if equations with mixed assignment equations and non-assignment equations",
			flatModel="
fclass TransformCanonicalTests.IfEqu16
 Real x;
 Real y;
 Real z1;
 Real z2;
equation
 x = if time < 1 then y * y else 4;
 y = if time < 1 then z2 - 1 elseif time < 3 then 2 else x + 2;
 0.0 = if time < 1 then z1 - 2 elseif time < 3 then z1 - y * x else z2 - 4 * x;
 0.0 = if time < 1 then z1 + z2 - (x + y) else z1 + z2 - (x - y);
end TransformCanonicalTests.IfEqu16;
")})));
  end IfEqu16;


  model IfEqu17
      function f
          output Real x1 = 1;
          output Real x2 = 2;
	  algorithm
      end f;
      
      Real y1;
      Real y2;
      parameter Boolean p = false; 
  equation
      if p then
          y1 = 3;
          y2 = 3;
      else
          (y1, y2) = f();
      end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu17",
			description="Check that if equations with function call equations are eliminated",
			flatModel="
fclass TransformCanonicalTests.IfEqu17
 Real y1;
 Real y2;
 parameter Boolean p = false /* false */;
equation
 (y1, y2) = TransformCanonicalTests.IfEqu17.f();

public
 function TransformCanonicalTests.IfEqu17.f
  output Real x1;
  output Real x2;
 algorithm
  x1 := 1;
  x2 := 2;
  return;
 end TransformCanonicalTests.IfEqu17.f;

end TransformCanonicalTests.IfEqu17;
")})));
  end IfEqu17;


  model IfEqu18
      function f
          output Real x1 = 1;
          output Real x2 = 2;
      algorithm
      end f;
      
      Real y1;
      Real y2;
  equation
      if time > 1 then
          y1 = 3;
          y2 = 3;
      else
          (y1, y2) = f();
      end if;

	annotation(__JModelica(UnitTesting(tests={
		ComplianceErrorTestCase(
			name="IfEqu18",
			description="Check that if equations with function call equations and non-param tests are rejected",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Compliance error at line 3263, column 15:
  Boolean variables are supported only when compiling FMUs (constants and parameters are always supported)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Compliance error at line 3265, column 7:
  If equations that has non-parameter tests and contains function calls using multiple outputs are not supported
")})));
  end IfEqu18;

  model IfEqu19
    Real x;
  equation
	when sample(1,0) then
		if time>=3 then
			x = pre(x) + 1;
        else
	        x = pre(x) + 5;
		end if;
	end when;
			

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu19",
			description="Check that if equations inside when equations are treated correctly.",
			flatModel="
fclass TransformCanonicalTests.IfEqu19
 discrete Real x;
initial equation 
 pre(x) = 0.0;
equation
 when sample(1, 0) then
  x = if time >= 3 then pre(x) + 1 else pre(x) + 5;
 end when;
end TransformCanonicalTests.IfEqu19;
")})));
  end IfEqu19;

model IfEqu20
	Real x;
initial equation
    if true then
		x = 3;
	end if;
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu20",
			description="Check that parameter if equations are rewritten in initial equation sections.",
			flatModel="
fclass TransformCanonicalTests.IfEqu20
 Real x;
initial equation 
 x = 3;
equation
 der(x) = - x;
end TransformCanonicalTests.IfEqu20;
")})));
end IfEqu20;

model IfEqu21
	Real x;
initial equation
    if  time>=3 then
		x = 3;
	else
		x = 4;
	end if;
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu21",
			description="Check that variable if equations are rewritten in initial equation sections.",
			flatModel="
fclass TransformCanonicalTests.IfEqu21
 Real x;
initial equation 
 x = if time >= 3 then 3 else 4;
equation
 der(x) = - x;
end TransformCanonicalTests.IfEqu21;
")})));
end IfEqu21;


model IfEqu22
  function f
    input Real u[2];
    output Real y[2];
  algorithm
    u:=2*y;
  end f;

  Boolean b = true;
  parameter Integer nX = 2;
  Real x[nX];
  equation
  if b then
    if nX>=0 then
      x = f({1,2});
    end if;
  else
   x = zeros(nX);
  end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu22",
			description="Function call equation generated by scalarization inside if equation",
			flatModel="
fclass TransformCanonicalTests.IfEqu22
 discrete Boolean b;
 parameter Integer nX = 2 /* 2 */;
 Real x[1];
 Real x[2];
 Real temp_1[1];
 Real temp_1[2];
initial equation 
 pre(b) = false;
equation
 x[1] = if b then temp_1[1] else 0;
 x[2] = if b then temp_1[2] else 0;
 ({temp_1[1], temp_1[2]}) = TransformCanonicalTests.IfEqu22.f({1, 2});
 b = true;

public
 function TransformCanonicalTests.IfEqu22.f
  input Real[2] u;
  output Real[2] y;
 algorithm
  u[1] := 2 * y[1];
  u[2] := 2 * y[2];
  return;
 end TransformCanonicalTests.IfEqu22.f;

end TransformCanonicalTests.IfEqu22;
")})));
end IfEqu22;


model IfEqu23
    record R
        Real x;
        Real y;
    end R;
	
    function F
        input Real x;
        input Real y;
        output R r;
    algorithm
        r.x := x;
        r.y := y;
    end F;
	
    Real x=1;
    Real y=2;
    R r;
equation
    if time > 1 then
        r=F(x,y);
    else
        r = F(x+y,y);
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu23",
			description="Function call equation generated by scalarization inside else branch of if equation",
			flatModel="
fclass TransformCanonicalTests.IfEqu23
 Real x;
 Real y;
 Real r.x;
 Real r.y;
 Real temp_1.x;
 Real temp_1.y;
 Real temp_2.x;
 Real temp_2.y;
equation
 r.x = if time > 1 then temp_1.x else temp_2.x;
 r.y = if time > 1 then temp_1.y else temp_2.y;
 (TransformCanonicalTests.IfEqu23.R(temp_1.x, temp_1.y)) = TransformCanonicalTests.IfEqu23.F(x, y);
 (TransformCanonicalTests.IfEqu23.R(temp_2.x, temp_2.y)) = TransformCanonicalTests.IfEqu23.F(x + y, y);
 x = 1;
 y = 2;

public
 function TransformCanonicalTests.IfEqu23.F
  input Real x;
  input Real y;
  output TransformCanonicalTests.IfEqu23.R r;
 algorithm
  r.x := x;
  r.y := y;
  return;
 end TransformCanonicalTests.IfEqu23.F;

 record TransformCanonicalTests.IfEqu23.R
  Real x;
  Real y;
 end TransformCanonicalTests.IfEqu23.R;

end TransformCanonicalTests.IfEqu23;
")})));
end IfEqu23;

model IfEqu24  "Test delay equation"
  parameter Boolean use_delay=false;
  Real x1(start = 1); 
  Real x2(start = 1);
equation
  der(x1) = sin(time);
  if use_delay then
    der(x2) = (x1 - x2) /100;
  else
    0 = x1 - x2 + 2;
  end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEqu24",
			description="Check correct elimination of if equation branches.",
			flatModel="
fclass TransformCanonicalTests.IfEqu24
 parameter Boolean use_delay = false /* false */;
 Real x1(start = 1);
 Real x2(start = 1);
initial equation 
 x1 = 1;
equation
 der(x1) = sin(time);
 0 = x1 - x2 + 2;
end TransformCanonicalTests.IfEqu24;
")})));
end IfEqu24;

model IfExpLeft1
	Real x;
equation
	if time>=1 then 1 else 0 = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfExpLeft1",
			description="If expression as left side of equation",
			flatModel="
fclass TransformCanonicalTests.IfExpLeft1
 Real x;
equation
 if time >= 1 then 1 else 0 = x;
end TransformCanonicalTests.IfExpLeft1;
")})));
end IfExpLeft1;



model WhenVariability1
	Real x(start=1);
equation
	when time > 2 then
		x = 2;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenVariability1",
			description="Variability of variable assigned in when clause",
			flatModel="
fclass TransformCanonicalTests.WhenVariability1
 discrete Real x(start = 1);
initial equation 
 pre(x) = 1;
equation
 when time > 2 then
  x = 2;
 end when;
end TransformCanonicalTests.WhenVariability1;
")})));
end WhenVariability1;


model StateInitialPars1
	Real x(start=3);
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars1",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars1
 Real x(start = 3);
 parameter Real _start_x = 3 /* 3 */;
initial equation 
 x = _start_x;
equation
 der(x) = - x;
end TransformCanonicalTests.StateInitialPars1;
")})));
end StateInitialPars1;

model StateInitialPars2
	Real x(start=3, fixed = true);
equation
	der(x) = -x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars2",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars2
 Real x(start = 3,fixed = true);
 parameter Real _start_x = 3 /* 3 */;
initial equation 
 x = _start_x;
equation
 der(x) = - x;
end TransformCanonicalTests.StateInitialPars2;
")})));
end StateInitialPars2;
	
model StateInitialPars3
	Real x(start=3, fixed = true);
	Real y(start = 4);
	Real z(start = 6, fixed = true);
equation
	der(x) = -x;
	der(y) = -y + z;
	z + 2*y = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars3",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars3
 Real x(start = 3,fixed = true);
 Real y(start = 4);
 Real z(start = 6,fixed = true);
 parameter Real _start_x = 3 /* 3 */;
 parameter Real _start_y = 4 /* 4 */;
initial equation 
 x = _start_x;
 y = _start_y;
equation
 der(x) = - x;
 der(y) = - y + z;
 z + 2 * y = 0;
end TransformCanonicalTests.StateInitialPars3;
")})));
end StateInitialPars3;	
	
model StateInitialPars4
	Real x(start=3);
	Real y(start = 4);
	Real z(start = 6);
initial equation
	x = 3;
	z = 5;
equation
	der(x) = -x;
	der(y) = -y + z;
	z + 2*y = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StateInitialPars4",
			description="Test the state initial equations option",
			state_initial_equations=true,
			flatModel="
fclass TransformCanonicalTests.StateInitialPars4
 Real x(start = 3);
 Real y(start = 4);
 Real z(start = 6);
 parameter Real _start_x = 3 /* 3 */;
 parameter Real _start_y = 4 /* 4 */;
initial equation 
 x = _start_x;
 y = _start_y;
equation
 der(x) = - x;
 der(y) = - y + z;
 z + 2 * y = 0;
end TransformCanonicalTests.StateInitialPars4;
")})));
end StateInitialPars4;		
	
model DuplicateVariables1
  model A
    Real x(start=1, min=2) = 3;
  end A;
  Real x(start=1, min=2) = 3;
  extends A;


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="DuplicateVariables1",
			description="Test that identical variables in base classes are handled correctly.",
			flatModel="
fclass TransformCanonicalTests.DuplicateVariables1
 Real x(start = 1,min = 2);
equation
 x = 3;
end TransformCanonicalTests.DuplicateVariables1;
")})));
end DuplicateVariables1;


  model SolveEqTest1
    Real x, y, z;
  equation
    x = 1;
    y = x + 3;
    z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest1",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  x + 3
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  x + (- y)
-------------------------------
")})));
  end SolveEqTest1;

  model SolveEqTest2
    Real x, y, z;
  equation
    x = 1;
    - y = x + 3;
    - z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest2",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (x + 3) / (- 1.0)
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  (x + (- y)) / (- 1.0)
-------------------------------
")})));
  end SolveEqTest2;

  model SolveEqTest3
    Real x, y, z;
  equation
    x = 1;
    2*y = x + 3;
    x*z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest3",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (x + 3) / 2
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  (x + (- y)) /x
-------------------------------
")})));
  end SolveEqTest3;

  model SolveEqTest4
    Real x, y, z;
  equation
    x = 1;
    y/2 = x + 3;
    z/x = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest4",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (x + 3) / (1.0 / 2)
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  (x + (- y)) / (1.0 / x)
-------------------------------
")})));
  end SolveEqTest4;

  model SolveEqTest5
    Real x, y, z;
  equation
    x = 1;
    y = x + 3 + 3*y;
    z = x - y + (x+3)*z ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest5",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (x + 3) / (1.0 - 3)
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  (x + (- y)) / (1.0 - (x + 3))
-------------------------------
")})));
  end SolveEqTest5;

  model SolveEqTest6

    Real x, y, z;
  equation
    x = 1;
    2/y = x + 3;
    x/z = x - y ;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest6",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Non-solved block of 1 variables:
Unknown variables:
  y
Equations:
  2 / y = x + 3
-------------------------------
Non-solved block of 1 variables:
Unknown variables:
  z
Equations:
  x / z = x - y
-------------------------------
")})));
  end SolveEqTest6;

   model SolveEqTest7

    Real x, y, z;
  equation
    x = 1;
    - y = x + 3 - y + 4*y;
    - z = x - y -z - 5*z;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest7",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  (x + 3) / (- 1.0 + 1.0 - 4)
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  (x + (- y)) / (- 1.0 + 1.0 + 5)
-------------------------------
")})));
  end SolveEqTest7;
  

  model SolveEqTest8
    Real x;
  equation
   -der(x) + x = -der(x) - (-(-(-der(x))));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="SolveEqTest8",
			description="Test solution of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(x)
Solution:
  (- x) / (- 1.0 - (- 1.0) + (- 1.0) * (- 1.0) * (- 1.0))
-------------------------------
")})));
 end SolveEqTest8;
  
 model TearingTest1
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="TearingTest1",
			description="Test of tearing",
			equation_sorting=true,
			enable_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  i1
  u1
  u2
Iteration variables:
  i2()
  i3()
Solved equations:
  i1 = i2 + i3
  u1 = R1 * i1
  u0 = u1 + u2
Residual equations:
 Iteration variables: i2
  u2 = R3 * i3
 Iteration variables: i3
  u2 = R2 * i2
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
  end TearingTest1;

model TearingWarningTest1
	Real u0,u1,u2,u3,uL;
	Real i0,i1,i2,i3,iL;
	parameter Real R1 = 1;
	parameter Real R2 = 1;
	parameter Real R3 = 1;
	parameter Real L = 1;
equation
	u0 = sin(time);
	u1 = R1*i1;
	u2 = R2*i2;
	u3 = R3*i3;
	uL = L*der(iL);
	u0 = u1 + u3;
	uL = u1 + u2;
	u2 = u3;
	i0 = i1 + iL;
	i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={ 
		WarningTestCase(
			name="TearingWarningTest1",
			description="",
			equation_sorting=true,
			enable_tearing=true,
			errorMessage="
2 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
At line 0, column 0:
  Tearing variable \"i2\" is missing start value!
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
At line 0, column 0:
  Tearing variable \"i3\" is missing start value!
")})));
end TearingWarningTest1;

model TearingWarningTest2
	Real u0,u1,u2,u3,uL;
	Real i0,i1,i2(start=1),i3,iL;
	parameter Real R1 = 1;
	parameter Real R2 = 1;
	parameter Real R3 = 1;
	parameter Real L = 1;
equation
	u0 = sin(time);
	u1 = R1*i1;
	u2 = R2*i2;
	u3 = R3*i3;
	uL = L*der(iL);
	u0 = u1 + u3;
	uL = u1 + u2;
	u2 = u3;
	i0 = i1 + iL;
	i1 = i2 + i3;
	
	annotation(__JModelica(UnitTesting(tests={ 
		WarningTestCase(
			name="TearingWarningTest2",
			description="",
			equation_sorting=true,
			enable_tearing=true,
			errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
At line 0, column 0:
  Tearing variable \"i3\" is missing start value!
")})));
end TearingWarningTest2;

model RecordTearingTest1
  record R
    Real x;
    Real y;
  end R;
  function F
    input Real a;
    input Real b;
    output R r;
  algorithm
    r := R(a + b, a - b);
  end F;
  Real x, y;
  R r;
equation
  x = 1;
  y = x + 2;
  r = F(x, y);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest1",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of record tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  1
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  x + 2
-------------------------------
Solved block of 2 variables:
Unknown variables:
  r.x
  r.y
Equations:
  (TransformCanonicalTests.RecordTearingTest1.R(r.x, r.y)) = TransformCanonicalTests.RecordTearingTest1.F(x, y)
-------------------------------
      ")})));
end RecordTearingTest1;

model RecordTearingTest2
  record R
    Real x;
    Real y;
  end R;
  function F
    input Real a;
    input Real b;
    output R r;
  algorithm
    r := R(a + b, a - b);
  end F;
  Real x,y;
  R r;
equation
  y = sin(time);
  r.y = 2;
  r = F(x,y);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest2",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of record tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  sin(time)
-------------------------------
Solved block of 1 variables:
Computed variable:
  r.y
Solution:
  2
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  r.x
Iteration variables:
  x()
Solved equations:
  (TransformCanonicalTests.RecordTearingTest2.R(r.x, r.y)) = TransformCanonicalTests.RecordTearingTest2.F(x, y)
Residual equations:
 Iteration variables: x
  (TransformCanonicalTests.RecordTearingTest2.R(r.x, r.y)) = TransformCanonicalTests.RecordTearingTest2.F(x, y)
-------------------------------
      ")})));
end RecordTearingTest2;

model RecordTearingTest3
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real x, y;
equation
  (x, y) = F(y, x);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest3",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of record tearing",
			methodResult="
-------------------------------
Torn block of 2 iteration variables and 0 solved variables.
Solved variables:
Iteration variables:
  x()
  y()
Solved equations:
Residual equations:
 Iteration variables: x
                      y
  (x, y) = TransformCanonicalTests.RecordTearingTest3.F(y, x)
-------------------------------
      ")})));
end RecordTearingTest3;

model RecordTearingTest4
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real x, y;
  Real v;
equation
   (x, y) = F(v, v);
   v = x + y;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest4",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of record tearing",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  x
  y
Iteration variables:
  v()
Solved equations:
  (x, y) = TransformCanonicalTests.RecordTearingTest4.F(v, v)
Residual equations:
 Iteration variables: v
  v = x + y
-------------------------------
      ")})));
end RecordTearingTest4;

model RecordTearingTest5
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real a;
  Real b;
  Real c;
  Real d;
  Real e;
  Real f;
equation
  (c,d) = F(a,b);
  (e,f) = F(c,d);
  (a,b) = F(e,f);

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="RecordTearingTest5",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of record tearing",
			methodResult="
-------------------------------
Torn block of 3 iteration variables and 3 solved variables.
Solved variables:
  c
  d
  e
Iteration variables:
  f()
  a()
  b()
Solved equations:
  (c, d) = TransformCanonicalTests.RecordTearingTest5.F(a, b)
  (e, f) = TransformCanonicalTests.RecordTearingTest5.F(c, d)
Residual equations:
 Iteration variables: f
  (e, f) = TransformCanonicalTests.RecordTearingTest5.F(c, d)
 Iteration variables: a
                      b
  (a, b) = TransformCanonicalTests.RecordTearingTest5.F(e, f)
-------------------------------
      ")})));
end RecordTearingTest5;

model HandGuidedTearing1
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(iterationVariable=i3)));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing1",
			description="Test of hand guided tearing",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing1;

model HandGuidedTearing2
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3 annotation(__Modelon(ResidualEquation(iterationVariable=i2)));
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3 annotation(__Modelon(ResidualEquation(iterationVariable=i1)));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing2",
			description="Test of hand guided tearing",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 iteration variables and 2 solved variables.
Solved variables:
  u2
  u1
Iteration variables:
  i2()
  i1()
  i3()
Solved equations:
  u2 = R2 * i2
  u1 = R1 * i1
Residual equations:
 Iteration variables: i2
  u0 = u1 + u2
 Iteration variables: i1
  i1 = i2 + i3
 Iteration variables: i3
  u2 = R3 * i3
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing2;

model HandGuidedTearing3
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3 annotation(__Modelon(ResidualEquation(iterationVariable=i2)));
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3 annotation(__Modelon(ResidualEquation(iterationVariable=i3)));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing3",
			description="Test of hand guided tearing",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 iteration variables and 2 solved variables.
Solved variables:
  u2
  u1
Iteration variables:
  i2()
  i3()
  i1()
Solved equations:
  u2 = R3 * i3
  u1 = R1 * i1
Residual equations:
 Iteration variables: i2
  u0 = u1 + u2
 Iteration variables: i3
  i1 = i2 + i3
 Iteration variables: i1
  u2 = R2 * i2
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing3;

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing4
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,iL;
  Real i3 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing4",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing4;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing5
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  Real i4 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  i3 = i4;
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing5",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing5;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing6
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=true)));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing6",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to true",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 iteration variables and 2 solved variables.
Solved variables:
  u2
  i1
Iteration variables:
  u1()
  i2()
  i3()
Solved equations:
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: u1
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R3 ) * ( i3 )
 Iteration variables: i3
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing6;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing7
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=false)));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing7",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to false",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  i1
  u1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  i1 = i2 + i3
  u1 = ( R1 ) * ( i1 )
Residual equations:
 Iteration variables: i3
  u0 = u1 + u2
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing7;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing8
  parameter Boolean isResidual = true;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=isResidual)));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing8",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to true through a parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 iteration variables and 2 solved variables.
Solved variables:
  u2
  i1
Iteration variables:
  u1()
  i2()
  i3()
Solved equations:
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: u1
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R3 ) * ( i3 )
 Iteration variables: i3
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing8;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing9
  parameter Boolean isResidual = false;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=isResidual)));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing9",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to false through a parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  i1
  u1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  i1 = i2 + i3
  u1 = ( R1 ) * ( i1 )
Residual equations:
 Iteration variables: i3
  u0 = u1 + u2
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing9;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing10
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable));
  Real i3 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing10",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing10;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing11
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=true)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=false)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing11",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i2()
  i3()
Solved equations:
  u2 = ( R2 ) * ( i2 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i2
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i3
  u2 = ( R3 ) * ( i3 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing11;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing12
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=false)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=true)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing12",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing12;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing13
  parameter Boolean isIteration = true;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=isIteration)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=not isIteration)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing13",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables, set through parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i2()
  i3()
Solved equations:
  u2 = ( R2 ) * ( i2 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i2
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i3
  u2 = ( R3 ) * ( i3 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing13;*/

//TODO: Remake when new tearing algorithm is done
/*model HandGuidedTearing14
  parameter Boolean isIteration = false;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=isIteration)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=not isIteration)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing14",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables, set through parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = ( R1 ) * ( i1 )
 Iteration variables: i2
  u2 = ( R2 ) * ( i2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  uL
Solution:
  u1 + u2
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(iL)
Solution:
  (  - ( uL ) ) / (  - ( L ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing14;*/

model HandGuidedTearing15

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3;
	end for;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing15",
			description="Test of hand guided tearing of vectors and indices whit no annotation, base case.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[1]
  a[1]
Iteration variables:
  b[1]()
Solved equations:
  c[1] = b[1] - 3
  a[1] = c[1] + 1
Residual equations:
 Iteration variables: b[1]
  a[1] = b[1] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[2]
  a[2]
Iteration variables:
  b[2]()
Solved equations:
  c[2] = b[2] - 3
  a[2] = c[2] + 1
Residual equations:
 Iteration variables: b[2]
  a[2] = b[2] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[3]
  a[3]
Iteration variables:
  b[3]()
Solved equations:
  c[3] = b[3] - 3
  a[3] = c[3] + 1
Residual equations:
 Iteration variables: b[3]
  a[3] = b[3] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[4]
  a[4]
Iteration variables:
  b[4]()
Solved equations:
  c[4] = b[4] - 3
  a[4] = c[4] + 1
Residual equations:
 Iteration variables: b[4]
  a[4] = b[4] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[5]
  a[5]
Iteration variables:
  b[5]()
Solved equations:
  c[5] = b[5] - 3
  a[5] = c[5] + 1
Residual equations:
 Iteration variables: b[5]
  a[5] = b[5] + 2
-------------------------------
")})));
end HandGuidedTearing15;

model HandGuidedTearing16

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3 annotation(__Modelon(ResidualEquation(enabled=true,iterationVariable=c[i])));
	end for;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing16",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] + 1
  a[1] = b[1] + 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  b[2]
Iteration variables:
  c[2]()
Solved equations:
  a[2] = c[2] + 1
  a[2] = b[2] + 2
Residual equations:
 Iteration variables: c[2]
  c[2] = b[2] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  b[3]
Iteration variables:
  c[3]()
Solved equations:
  a[3] = c[3] + 1
  a[3] = b[3] + 2
Residual equations:
 Iteration variables: c[3]
  c[3] = b[3] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[4]
  b[4]
Iteration variables:
  c[4]()
Solved equations:
  a[4] = c[4] + 1
  a[4] = b[4] + 2
Residual equations:
 Iteration variables: c[4]
  c[4] = b[4] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[5]
  b[5]
Iteration variables:
  c[5]()
Solved equations:
  a[5] = c[5] + 1
  a[5] = b[5] + 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] - 3
-------------------------------
")})));
end HandGuidedTearing16;

model HandGuidedTearing17

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3 annotation(__Modelon(ResidualEquation(enabled=true,iterationVariable=c[i])));
	end for;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing17",
			description="Test of hand guided tearing of vectors and indices with handguided annotation and blt merge.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 5 iteration variables and 10 solved variables.
Solved variables:
  a[1]
  b[1]
  a[2]
  b[2]
  a[3]
  b[3]
  a[4]
  b[4]
  a[5]
  b[5]
Iteration variables:
  c[5]()
  c[4]()
  c[3]()
  c[2]()
  c[1]()
Solved equations:
  a[1] = c[1] + 1
  a[1] = b[1] + 2
  a[2] = c[2] + 1
  a[2] = b[2] + 2
  a[3] = c[3] + 1
  a[3] = b[3] + 2
  a[4] = c[4] + 1
  a[4] = b[4] + 2
  a[5] = c[5] + 1
  a[5] = b[5] + 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] - 3
 Iteration variables: c[4]
  c[4] = b[4] - 3
 Iteration variables: c[3]
  c[3] = b[3] - 3
 Iteration variables: c[2]
  c[2] = b[2] - 3
 Iteration variables: c[1]
  c[1] = b[1] - 3
-------------------------------
")})));
end HandGuidedTearing17;

model HandGuidedTearing18
	model A
		Real x;
		Real y;
	equation
		x = y + 1 annotation(__Modelon(name=eq));
	end A;
	
	model B
		Real x;
		Real y;
	equation
		x = y + 2;
	end B;
	
	A a;
	B b;
equation
	a.x = b.y + 2;
	a.y = b.x - 3;
	annotation(__Modelon(tearingPairs={
		Pair(residualEquation=a.eq, iterationVariable=b.x)
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing18",
			description="Test of hand guided tearing with pairs defiend on system level.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  a.y
  b.y
  a.x
Iteration variables:
  b.x()
Solved equations:
  a.y = b.x - 3
  b.x = b.y + 2
  a.x = b.y + 2
Residual equations:
 Iteration variables: b.x
  a.x = a.y + 1
-------------------------------
")})));
end HandGuidedTearing18;

model HandGuidedTearing19
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(residualEquation=a.eq, iterationVariable=b.x)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing19",
			description="Test of hand guided tearing with pairs defiend on system level, but in sub class.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing19;

model HandGuidedTearing20
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq, ResidualEquation(iterationVariable=x)));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(residualEquation=a.eq, iterationVariable=b.x)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing20",
			description="Test of hand guided tearing with pairs defiend on system level and in sub class.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing20;

model HandGuidedTearing21
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
			annotation(__Modelon(tearingPairs={
				Pair(residualEquation=eq, iterationVariable=x)
			}));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(residualEquation=a.eq, iterationVariable=b.x)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing21",
			description="Test of hand guided tearing with pairs defiend on system level and sub class.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing21;

model HandGuidedTearing22
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		parameter Boolean useFirst = true;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(enabled=useFirst, residualEquation=a.eq, iterationVariable=b.x),
			Pair(enabled=not useFirst, residualEquation=a.eq, iterationVariable=b.y)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing22",
			description="Test of hand guided tearing with pairs defiend on system level.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing22;

model HandGuidedTearing23
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		parameter Boolean useFirst = false;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(enabled=useFirst, residualEquation=a.eq, iterationVariable=b.x),
			Pair(enabled=not useFirst, residualEquation=a.eq, iterationVariable=b.y)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing23",
			description="Test of hand guided tearing with pairs defiend on system level.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.b.x
  c.a.y
  c.a.x
Iteration variables:
  c.b.y()
Solved equations:
  c.b.x = c.b.y + 2
  c.a.y = c.b.x - 3
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.y
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing23;

model HandGuidedTearing24

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	a=c .+ 1;
	a=b .+ 2;
	c=b .- 3 annotation(__Modelon(ResidualEquation(enabled=true,iterationVariable=c)));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing24",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] .+ 1
  a[1] = b[1] .+ 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  b[2]
Iteration variables:
  c[2]()
Solved equations:
  a[2] = c[2] .+ 1
  a[2] = b[2] .+ 2
Residual equations:
 Iteration variables: c[2]
  c[2] = b[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  b[3]
Iteration variables:
  c[3]()
Solved equations:
  a[3] = c[3] .+ 1
  a[3] = b[3] .+ 2
Residual equations:
 Iteration variables: c[3]
  c[3] = b[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[4]
  b[4]
Iteration variables:
  c[4]()
Solved equations:
  a[4] = c[4] .+ 1
  a[4] = b[4] .+ 2
Residual equations:
 Iteration variables: c[4]
  c[4] = b[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[5]
  b[5]
Iteration variables:
  c[5]()
Solved equations:
  a[5] = c[5] .+ 1
  a[5] = b[5] .+ 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] .- 3
-------------------------------
")})));
end HandGuidedTearing24;

model HandGuidedTearing25

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	a=c .+ 1;
	a=b .+ 2;
	c=b .- 3 annotation(__Modelon(name=res));
	annotation(
	__Modelon(tearingPairs={Pair(residualEquation=res,iterationVariable=c)}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing25",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] .+ 1
  a[1] = b[1] .+ 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  b[2]
Iteration variables:
  c[2]()
Solved equations:
  a[2] = c[2] .+ 1
  a[2] = b[2] .+ 2
Residual equations:
 Iteration variables: c[2]
  c[2] = b[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  b[3]
Iteration variables:
  c[3]()
Solved equations:
  a[3] = c[3] .+ 1
  a[3] = b[3] .+ 2
Residual equations:
 Iteration variables: c[3]
  c[3] = b[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[4]
  b[4]
Iteration variables:
  c[4]()
Solved equations:
  a[4] = c[4] .+ 1
  a[4] = b[4] .+ 2
Residual equations:
 Iteration variables: c[4]
  c[4] = b[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[5]
  b[5]
Iteration variables:
  c[5]()
Solved equations:
  a[5] = c[5] .+ 1
  a[5] = b[5] .+ 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] .- 3
-------------------------------
")})));
end HandGuidedTearing25;

model HandGuidedTearing26
	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];
equation
	a=c .+ 1;
	a=b .+ 2;
	c=b .- 3 annotation(__Modelon(name=res));
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=res[1],iterationVariable=c[1]),
		Pair(residualEquation=res[2:3],iterationVariable=b[2:3]),
		Pair(residualEquation=res[4:5],iterationVariable=a[4:5])
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing26",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] .+ 1
  a[1] = b[1] .+ 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  c[2]
Iteration variables:
  b[2]()
Solved equations:
  a[2] = b[2] .+ 2
  a[2] = c[2] .+ 1
Residual equations:
 Iteration variables: b[2]
  c[2] = b[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  c[3]
Iteration variables:
  b[3]()
Solved equations:
  a[3] = b[3] .+ 2
  a[3] = c[3] .+ 1
Residual equations:
 Iteration variables: b[3]
  c[3] = b[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[4]
  c[4]
Iteration variables:
  a[4]()
Solved equations:
  a[4] = b[4] .+ 2
  a[4] = c[4] .+ 1
Residual equations:
 Iteration variables: a[4]
  c[4] = b[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[5]
  c[5]
Iteration variables:
  a[5]()
Solved equations:
  a[5] = b[5] .+ 2
  a[5] = c[5] .+ 1
Residual equations:
 Iteration variables: a[5]
  c[5] = b[5] .- 3
-------------------------------
")})));
end HandGuidedTearing26;

model HandGuidedTearing27

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3 annotation(__Modelon(name=res));
	end for;
	
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=res[1],iterationVariable=c[1]),
		Pair(residualEquation=res[2:3],iterationVariable=b[2:3]),
		Pair(residualEquation=res[4:5],iterationVariable=a[4:5])
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing27",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] + 1
  a[1] = b[1] + 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  c[2]
Iteration variables:
  b[2]()
Solved equations:
  a[2] = b[2] + 2
  a[2] = c[2] + 1
Residual equations:
 Iteration variables: b[2]
  c[2] = b[2] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  c[3]
Iteration variables:
  b[3]()
Solved equations:
  a[3] = b[3] + 2
  a[3] = c[3] + 1
Residual equations:
 Iteration variables: b[3]
  c[3] = b[3] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[4]
  c[4]
Iteration variables:
  a[4]()
Solved equations:
  a[4] = b[4] + 2
  a[4] = c[4] + 1
Residual equations:
 Iteration variables: a[4]
  c[4] = b[4] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[5]
  c[5]
Iteration variables:
  a[5]()
Solved equations:
  a[5] = b[5] + 2
  a[5] = c[5] + 1
Residual equations:
 Iteration variables: a[5]
  c[5] = b[5] - 3
-------------------------------
")})));
end HandGuidedTearing27;

model HandGuidedTearing28
	model A
		parameter Integer n = 5;
		Real a[n];
		Real b[n];
		Real c[n];
	
	equation
		for i in 1:n loop
			a[i]=c[i] + 1;
			a[i]=b[i] + 2;
			c[i]=b[i] - 3 annotation(__Modelon(name=res));
		end for;
	end A;
	
	A a;
	
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=a.res,iterationVariable=a.c)
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing28",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[1]
  a.b[1]
Iteration variables:
  a.c[1]()
Solved equations:
  a.a[1] = a.c[1] + 1
  a.a[1] = a.b[1] + 2
Residual equations:
 Iteration variables: a.c[1]
  a.c[1] = a.b[1] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[2]
  a.b[2]
Iteration variables:
  a.c[2]()
Solved equations:
  a.a[2] = a.c[2] + 1
  a.a[2] = a.b[2] + 2
Residual equations:
 Iteration variables: a.c[2]
  a.c[2] = a.b[2] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[3]
  a.b[3]
Iteration variables:
  a.c[3]()
Solved equations:
  a.a[3] = a.c[3] + 1
  a.a[3] = a.b[3] + 2
Residual equations:
 Iteration variables: a.c[3]
  a.c[3] = a.b[3] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[4]
  a.b[4]
Iteration variables:
  a.c[4]()
Solved equations:
  a.a[4] = a.c[4] + 1
  a.a[4] = a.b[4] + 2
Residual equations:
 Iteration variables: a.c[4]
  a.c[4] = a.b[4] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[5]
  a.b[5]
Iteration variables:
  a.c[5]()
Solved equations:
  a.a[5] = a.c[5] + 1
  a.a[5] = a.b[5] + 2
Residual equations:
 Iteration variables: a.c[5]
  a.c[5] = a.b[5] - 3
-------------------------------
")})));
end HandGuidedTearing28;

model HandGuidedTearing29
	model A
		B b;
		annotation(
		__Modelon(tearingPairs={
			Pair(residualEquation=b.res[1],iterationVariable=b.x[1]),
			Pair(residualEquation=b.res[2],iterationVariable=b.z[2])
		}));
	end A;
	model B
		parameter Integer n = 5;
		Real x[n];
		Real y[n];
		Real z[n];
	equation
		x=z .+ 1;
		x=y .+ 2;
		z=y .- 3 annotation(__Modelon(name=res));
		annotation(
		__Modelon(tearingPairs={
			Pair(residualEquation=res[1],iterationVariable=z[1]),
			Pair(residualEquation=res[2:3],iterationVariable=y[2:3])
		}));
	end B;
	A a;
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=a.b.res[1],iterationVariable=a.b.y[1]),
		Pair(residualEquation=a.b.res[4:5],iterationVariable=a.b.x[4:5])
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing29",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.x[1]
  a.b.z[1]
Iteration variables:
  a.b.y[1]()
Solved equations:
  a.b.x[1] = a.b.y[1] .+ 2
  a.b.x[1] = a.b.z[1] .+ 1
Residual equations:
 Iteration variables: a.b.y[1]
  a.b.z[1] = a.b.y[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.x[2]
  a.b.y[2]
Iteration variables:
  a.b.z[2]()
Solved equations:
  a.b.x[2] = a.b.z[2] .+ 1
  a.b.x[2] = a.b.y[2] .+ 2
Residual equations:
 Iteration variables: a.b.z[2]
  a.b.z[2] = a.b.y[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.x[3]
  a.b.z[3]
Iteration variables:
  a.b.y[3]()
Solved equations:
  a.b.x[3] = a.b.y[3] .+ 2
  a.b.x[3] = a.b.z[3] .+ 1
Residual equations:
 Iteration variables: a.b.y[3]
  a.b.z[3] = a.b.y[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.y[4]
  a.b.z[4]
Iteration variables:
  a.b.x[4]()
Solved equations:
  a.b.x[4] = a.b.y[4] .+ 2
  a.b.x[4] = a.b.z[4] .+ 1
Residual equations:
 Iteration variables: a.b.x[4]
  a.b.z[4] = a.b.y[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.y[5]
  a.b.z[5]
Iteration variables:
  a.b.x[5]()
Solved equations:
  a.b.x[5] = a.b.y[5] .+ 2
  a.b.x[5] = a.b.z[5] .+ 1
Residual equations:
 Iteration variables: a.b.x[5]
  a.b.z[5] = a.b.y[5] .- 3
-------------------------------
")})));
end HandGuidedTearing29;

model HandGuidedTearing30
	model B
		Real x, y;
	equation
		x = y + 1 annotation(__Modelon(name=res));
		y = x - 1;
	end B;
	extends B;
annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=res, iterationVariable=x)
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing30",
			description="Test of hand guided tearing of vectors and indices with handguided annotation.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  y
Iteration variables:
  x()
Solved equations:
  y = x - 1
Residual equations:
 Iteration variables: x
  x = y + 1
-------------------------------
")})));
end HandGuidedTearing30;

model HandGuidedTearing31
	Real x[2](each start=1), y[2](each start=2), z[2];
equation
	x = -y;
	y = z .+ 1 annotation(__Modelon(ResidualEquation(iterationVariable=y)));
	z = x .- 1;
annotation(
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing31",
			description="Test of hand guided tearing and alias elimination.",
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  z[1]
Iteration variables:
  y[1](start=2)
Solved equations:
  z[1] = - y[1] .- 1
Residual equations:
 Iteration variables: y[1]
  y[1] = z[1] .+ 1
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  z[2]
Iteration variables:
  y[2](start=2)
Solved equations:
  z[2] = - y[2] .- 1
Residual equations:
 Iteration variables: y[2]
  y[2] = z[2] .+ 1
-------------------------------
")})));
end HandGuidedTearing31;

model HandGuidedTearingError1
	Real x;
	Real y;
	Real z annotation(__Modelon(IterationVariable(enabled=1)));
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(enabled=1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=x, residualEquation=res, enabled=1)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError1",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8432, column 56:
  Cannot evaluate boolean enabled expression: 1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8436, column 56:
  Cannot evaluate boolean enabled expression: 1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8439, column 59:
  Cannot evaluate boolean enabled expression: 1
")})));
end HandGuidedTearingError1;

model HandGuidedTearingError2
	Real x;
	Real y;
	Real z annotation(__Modelon(IterationVariable(enabled=unknownParameter1)));
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(enabled=unknownParameter2)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=x, residualEquation=res, enabled=unknownParameter3)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError2",
			description="Test hand guided tearing errors",
			errorMessage="
6 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8464, column 56:
  Cannot evaluate boolean enabled expression: unknownParameter1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8464, column 56:
  Cannot find class or component declaration for unknownParameter1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8468, column 56:
  Cannot evaluate boolean enabled expression: unknownParameter2

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8468, column 56:
  Cannot find class or component declaration for unknownParameter2

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8471, column 59:
  Cannot evaluate boolean enabled expression: unknownParameter3

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8471, column 59:
  Cannot find class or component declaration for unknownParameter3
")})));
end HandGuidedTearingError2;

model HandGuidedTearingError3
	Real x;
	Real y;
	Real z;
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=2, residualEquation=3)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError3",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8504, column 66:
  Expression \"1\" is not a legal iteration variable reference

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8507, column 26:
  Expression \"2\" is not a legal iteration variable reference

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8507, column 46:
  Expression \"3\" is not a legal residual equation reference
")})));
end HandGuidedTearingError3;

model HandGuidedTearingError4
	Real x;
	Real y;
	Real z;
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=unknownVariable1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=unknownVariable2, residualEquation=unknownEquation)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError4",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8532, column 66:
  Cannot find class or component declaration for unknownVariable1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8535, column 26:
  Cannot find class or component declaration for unknownVariable2

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8535, column 61:
  Cannot find equation declaration for unknownEquation
")})));
end HandGuidedTearingError4;

model HandGuidedTearingError5
	parameter Real p1 = 1;
	parameter Real p2 = 2;
	Real x;
	Real y;
	Real z;
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=p1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=p2, residualEquation=res)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError5",
			description="Test hand guided tearing errors",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8566, column 2:
  Iteration variable should have continuous variability, p1 has parameter variability

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8569, column 26:
  Iteration variable should have continuous variability, p2 has parameter variability
")})));
end HandGuidedTearingError5;

model HandGuidedTearingError6
	Real x;
	Real y;
	Real z;
	Real v[2];
equation
	v[1] = v[2] + 1;
	x=3 + v[2];
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=v)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=v, residualEquation=res)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError6",
			description="Test hand guided tearing errors",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8597, column 2:
  Size of iteration variable v is not the same size as the surrounding equation, size of variable [2], size of equation scalar

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8599, column 24:
  Size of the iteration variable is not the same size as the size of the residual equation, size of variable [2], size of equation scalar
")})));
end HandGuidedTearingError6;

model HandGuidedTearingError7
	Real x[2];
	Real y[2];
	Real z[2];
	Real v;
equation
	v = 1;
	x=y .+ 1;
	y=z .+ 2 annotation(__Modelon(name=res));
	z=x .- 3 annotation(__Modelon(ResidualEquation(iterationVariable=v)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=v, residualEquation=res)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError7",
			description="Test hand guided tearing errors",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8627, column 2:
  Size of iteration variable v is not the same size as the surrounding equation, size of variable scalar, size of equation [2]

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8629, column 24:
  Size of the iteration variable is not the same size as the size of the residual equation, size of variable scalar, size of equation [2]
")})));
end HandGuidedTearingError7;

model HandGuidedTearingError8
	Real x[2];
	Real y[2];
	Real z[2];
	Real v[2,2] = {{1,2},{3,4}};
equation
	x=y .+ 1;
	y=z .+ 2 annotation(__Modelon(name=res));
	z=x .- 3 annotation(__Modelon(ResidualEquation(iterationVariable=v[3,:])));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=x[3], residualEquation=res[3])
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingError8",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8705, column 69:
  Array index out of bounds: 3, index expression: 3

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8708, column 28:
  Array index out of bounds: 3, index expression: 3

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 8708, column 53:
  Array index out of bounds: 3, index expression: 3
")})));
end HandGuidedTearingError8;

model HandGuidedTearingWarning1
	Real x(start=1), y(start=2), z;
equation
	x = -y;
	y = z + 1 annotation(__Modelon(ResidualEquation(iterationVariable=y)));
	z = x - 1 annotation(__Modelon(ResidualEquation(iterationVariable=x)));
	annotation(
	__JModelica(UnitTesting(tests={
		WarningTestCase(
			equation_sorting=true,
			enable_tearing=true,
			enable_hand_guided_tearing=true,
			name="HandGuidedTearingWarning1",
			description="Test hand guided tearing warnings",
			errorMessage="
2 warnings found:

Warning: in file '':
At line 0, column 0:
  Can not use hand guided tearing pair, equation and variable resides in different blocks. Variable: x. Equation: - x = z + 1

Warning: in file '':
At line 0, column 0:
  Hand guided tearing variable 'y' has been alias eliminated
")})));
end HandGuidedTearingWarning1;

model BlockTest1
record R
  Real x,y;
end R;

function f1
  input Real x;
  output R r;
algorithm 
  r.x :=x;
  r.y :=x*x;
end f1;

function f2
  input Real x;
  output Real y1;
  output Real y2;
algorithm
  y1:=x*2;
  y2:=x*4;
end f2;

  R r;
  Real x;
  Real y1,y2;
equation
  x = sin(time);
  r = f1(x + r.x);
  (y1,y2) = f2(x + y1);


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest1",
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test of correct creation of blocks containing functions returning records", methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  sin(time)
-------------------------------
Non-solved block of 2 variables:
Unknown variables:
  r.x
  r.y
Equations:
  (TransformCanonicalTests.BlockTest1.R(r.x, r.y)) = TransformCanonicalTests.BlockTest1.f1(x + r.x)
-------------------------------
Non-solved block of 2 variables:
Unknown variables:
  y1
  y2
Equations:
  (y1, y2) = TransformCanonicalTests.BlockTest1.f2(x + y1)
-------------------------------
      ")})));
end BlockTest1;

model BlockTest2
record R
  Real x,y;
end R;

record R2
  Real x;
  R r;
end R2;

function f1
  input Real x;
  output R r;
algorithm 
  r.x :=x;
  r.y :=x*x;
end f1;

function f2
  input Real x;
  output Real y1;
  output Real y2;
algorithm
  y1:=x*2;
  y2:=x*4;
end f2;

function f3
  input Real x;
  output R2 r;
algorithm 
  r.x :=x;
  r.r :=R(x*x,x);
end f3;

  R r;
  R2 r2;
  Real x;
  Real y1,y2;
equation
  x = sin(time);
  r = f1(x + r.x);
  r2 = f3(x + r2.x);
  (y1,y2) = f2(x + y1);


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest2",
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test of correct creation of blocks containing functions returning records", methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  sin(time)
-------------------------------
Non-solved block of 2 variables:
Unknown variables:
  r.x
  r.y
Equations:
  (TransformCanonicalTests.BlockTest2.R(r.x, r.y)) = TransformCanonicalTests.BlockTest2.f1(x + r.x)
-------------------------------
Non-solved block of 3 variables:
Unknown variables:
  r2.x
  r2.r.x
  r2.r.y
Equations:
  (TransformCanonicalTests.BlockTest2.R2(r2.x, TransformCanonicalTests.BlockTest2.R(r2.r.x, r2.r.y))) = TransformCanonicalTests.BlockTest2.f3(x + r2.x)
-------------------------------
Non-solved block of 2 variables:
Unknown variables:
  y1
  y2
Equations:
  (y1, y2) = TransformCanonicalTests.BlockTest2.f2(x + y1)
-------------------------------
      ")})));
end BlockTest2;

model BlockTest3
  record R
    Real x;
    Real y;
  end R;
  function F
    input Real a;
    output R r;
  algorithm
    r := R(a*2, a*3);
  end F;
  R r1, r2;
  Real x;
equation
  x = sin(time);
  r1 = F(x + r2.x);
  r2 = F(x + r1.x);  

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest3",
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test of correct creation of blocks containing functions returning records", methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  x
Solution:
  sin(time)
-------------------------------
Non-solved block of 4 variables:
Unknown variables:
  r2.y
  r2.x
  r1.x
  r1.y
Equations:
  (TransformCanonicalTests.BlockTest3.R(r2.x, r2.y)) = TransformCanonicalTests.BlockTest3.F(x + r1.x)
  (TransformCanonicalTests.BlockTest3.R(r1.x, r1.y)) = TransformCanonicalTests.BlockTest3.F(x + r2.x)
-------------------------------
      ")})));
end BlockTest3;

model BlockTest4
 Real x1,x2,z,w;
equation
w=1;
x2 = w*z + 1 + w;
x1 + x2 = z + sin(w);
x1 - x2 = z*w;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest4",
			description="Test of linear systems of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  w
Solution:
  1
-------------------------------
Non-solved linear block of 3 variables:
Coefficient variability: Continuous
Unknown variables:
  x1
  z
  x2
Equations:
  x1 + x2 = z + sin(w)
  x1 - x2 = z * w
  x2 = w * z + 1 + w
Jacobian:
  |1.0, - 1.0, 1.0|
  |1.0, (- 1.0 * w), - 1.0|
  |0.0, - w * 1.0, 1.0|
-------------------------------
")})));
end BlockTest4;

model BlockTest5
 Real x1,x2,z;
equation
x2 = z + 1 ;
x1 + x2 = z;
x1 - x2 = z;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest5",
			description="Test of linear systems of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Non-solved linear block of 3 variables:
Coefficient variability: Constant
Unknown variables:
  x1
  z
  x2
Equations:
  x1 + x2 = z
  x1 - x2 = z
  x2 = z + 1
Jacobian:
  |1.0, - 1.0, 1.0|
  |1.0, - 1.0, - 1.0|
  |0.0, - 1.0, 1.0|
-------------------------------
")})));
end BlockTest5;

model BlockTest6
 Real x1,x2,z;
 parameter Real p;
equation
x2 = z + p;
x1 + x2 = z;
x1 - x2 = z*p;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="BlockTest6",
			description="Test of linear systems of equations",
			equation_sorting=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Non-solved linear block of 3 variables:
Coefficient variability: Parameter
Unknown variables:
  x1
  z
  x2
Equations:
  x1 + x2 = z
  x1 - x2 = z * p
  x2 = z + p
Jacobian:
  |1.0, - 1.0, 1.0|
  |1.0, (- 1.0 * p), - 1.0|
  |0.0, - 1.0, 1.0|
-------------------------------
")})));
end BlockTest6;

model VarDependencyTest1
  Real x[15];
  input Real u[4];
equation
  x[1] = u[1];
  x[2] = u[2];
  x[3] = u[3];
  x[4] = u[4];
  x[5] = x[1];
  x[6] = x[1] + x[2];
  x[7] = x[3];
  x[8] = x[3];
  x[9] = x[4];
  x[10] = x[5];
  x[11] = x[5];
  x[12] = x[1] + x[6];
  x[13] = x[7] + x[8];
  x[14] = x[8] + x[9];
  x[15] = x[12] + x[3];


	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="VarDependencyTest1",
			methodName="dependencyDiagnostics",
			equation_sorting=true,
			eliminate_alias_variables=false,
			description="Test computation of direct dependencies",
			methodResult="
Variable dependencies:
Derivative variables: 

Differentiated variables: 

Algebraic real variables: 
 x[1]
    u[1]
 x[2]
    u[2]
 x[3]
    u[3]
 x[4]
    u[4]
 x[5]
    u[1]
 x[6]
    u[1]
    u[2]
 x[7]
    u[3]
 x[8]
    u[3]
 x[9]
    u[4]
 x[10]
    u[1]
 x[11]
    u[1]
 x[12]
    u[1]
    u[2]
 x[13]
    u[3]
 x[14]
    u[3]
    u[4]
 x[15]
    u[1]
    u[2]
    u[3]
")})));
end VarDependencyTest1;

model VarDependencyTest2
  Real x[2](each start=2);
  input Real u[3];
  Real y[3];
equation
  der(x[1]) = x[1] + x[2] + u[1];
  der(x[2]) = x[2] + u[2] + u[3];
  y[1] = x[2] + u[1];
  y[2] = x[1] + x[2] + u[2] + u[3];
  y[3] = x[1] + u[1] + u[3];

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="VarDependencyTest2",
			methodName="dependencyDiagnostics",
			equation_sorting=true,
			eliminate_alias_variables=false,
			description="Test computation of direct dependencies",
			methodResult="
Variable dependencies:
Derivative variables: 
 der(x[1])
    u[1]
    x[1]
    x[2]
 der(x[2])
    u[2]
    u[3]
    x[2]

Differentiated variables: 
 x[1]
 x[2]

Algebraic real variables: 
 y[1]
    u[1]
    x[2]
 y[2]
    u[2]
    u[3]
    x[1]
    x[2]
 y[3]
    u[1]
    u[3]
    x[1]
")})));
end VarDependencyTest2;

model StringFuncTest
  function f
    input String s;
    output String t;
  algorithm
   t := s;
  end f;

  parameter String p1 = f("a");
  parameter String p2 = "a";

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="StringFuncTest",
			description="Test that string parameters and string parameters goes through front-end.",
			flatModel="
fclass TransformCanonicalTests.StringFuncTest
 parameter String p1 = TransformCanonicalTests.StringFuncTest.f(\"a\") /* \"a\" */;
 parameter String p2 = \"a\" /* \"a\" */;
public
 function TransformCanonicalTests.StringFuncTest.f
  input String s;
  output String t;
 algorithm
  t := s;
  return;
 end TransformCanonicalTests.StringFuncTest.f;

end TransformCanonicalTests.StringFuncTest;
")})));

end StringFuncTest;


class MyExternalObject
 extends ExternalObject;
 
 function constructor
	 output MyExternalObject eo;
	 external "C" init_myEO();
 end constructor;
 
 function destructor
	 input MyExternalObject eo;
	 external "C" destroy_myEO(eo);
 end destructor;
end MyExternalObject;


model TestExternalObj1
 MyExternalObject myEO = MyExternalObject();

	annotation(__JModelica(UnitTesting(tests={ 
		TransformCanonicalTestCase(
			name="TestExternalObj1",
			description="",
			flatModel="
fclass TransformCanonicalTests.TestExternalObj1
 parameter TransformCanonicalTests.MyExternalObject myEO = TransformCanonicalTests.MyExternalObject.constructor() /* (unknown value) */;

public
 function TransformCanonicalTests.MyExternalObject.destructor
  input ExternalObject eo;
 algorithm
  external \"C\" destroy_myEO(eo);
  return;
 end TransformCanonicalTests.MyExternalObject.destructor;

 function TransformCanonicalTests.MyExternalObject.constructor
  output ExternalObject eo;
 algorithm
  external \"C\" init_myEO();
  return;
 end TransformCanonicalTests.MyExternalObject.constructor;

 type TransformCanonicalTests.MyExternalObject = ExternalObject;
end TransformCanonicalTests.TestExternalObj1;
")})));
end TestExternalObj1;


model TestExternalObj2
	extends MyExternalObject;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj2",
			description="Extending from external object",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9268, column 2:
  Classed derived from ExternalObject can neither be used in an extends-clause nor in a short class defenition
")})));
end TestExternalObj2;


model TestExternalObj3
    class NoConstructor
        extends ExternalObject;
     
        function destructor
            input NoConstructor eo;
            external "C" destroy_myEO(eo);
        end destructor;
    end NoConstructor;
    
    NoConstructor eo = NoConstructor();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj3",
			description="Non-complete external object",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9293, column 24:
  Cannot find function declaration for NoConstructor.constructor()
")})));
end TestExternalObj3;


model TestExternalObj4
    class NoDestructor
        extends ExternalObject;
     
        function constructor
            output NoDestructor eo;
            external "C" init_myEO();
        end constructor;
    end NoDestructor;
    
    NoDestructor eo = NoDestructor();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj4",
			description="Non-complete external object",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9316, column 21:
  Cannot find function declaration for NoDestructor.destructor()
")})));
end TestExternalObj4;


model TestExternalObj5
    class BadConstructor
        extends ExternalObject;
		
		record constructor
			Real x;
		end constructor;
     
        function destructor
            input BadConstructor eo;
            external "C" destroy_myEO(eo);
        end destructor;
    end BadConstructor;
    
    BadConstructor eo = BadConstructor();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj5",
			description="Non-complete external object",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9337, column 3:
  An external object constructor must have exactly one output of the same type as the constructor
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9347, column 25:
  The class BadConstructor.constructor is not a function
")})));
end TestExternalObj5;


model TestExternalObj6
    class BadDestructor
        extends ExternalObject;
     
        function constructor
            output BadDestructor eo;
            external "C" init_myEO();
        end constructor;
        
        model destructor
            Real x;
        end destructor;
     end BadDestructor;
    
    BadDestructor eo = BadDestructor();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj6",
			description="Non-complete external object",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9374, column 9:
  An external object destructor must have exactly one input of the same type as the constructor, and no outputs
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9377, column 23:
  The class BadDestructor.destructor is not a function
")})));
end TestExternalObj6;


model TestExternalObj7
    class ExtraContent
        extends ExternalObject;
        
        function constructor
            output ExtraContent eo;
            external "C" init_myEO();
        end constructor;
     
        function destructor
            input ExtraContent eo;
            external "C" destroy_myEO(eo);
        end destructor;
		
		function extra
			input Real x;
			output Real y;
		algorithm
			y := x;
		end extra;
    end ExtraContent;
    
    ExtraContent eo = ExtraContent();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj7",
			description="External object with extra elements",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9392, column 5:
  External object classes may not contain any elements except the constructor and destructor
")})));
end TestExternalObj7;


model TestExternalObj8
    class ExtraContent
        extends ExternalObject;
        
        function constructor
            output ExtraContent eo;
            external "C" init_myEO();
        end constructor;
     
        function destructor
            input ExtraContent eo;
            external "C" destroy_myEO(eo);
        end destructor;
		
		Real x;
    end ExtraContent;
    
    ExtraContent eo = ExtraContent();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj8",
			description="External object with extra elements",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9418, column 5:
  External object classes may not contain any elements except the constructor and destructor
")})));
end TestExternalObj8;


model TestExternalObj9
    class BadArgs
        extends ExternalObject;
        
        function constructor
            output BadArgs eo;
			output Real x;
            external "C" init_myEO();
        end constructor;
     
        function destructor
            input BadArgs eo;
			input Real y;
            external "C" destroy_myEO(eo);
        end destructor;
    end BadArgs;
    
    BadArgs eo = BadArgs();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj9",
			description="Extra inputs/outputs to constructor/destructor",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9464, column 9:
  An external object constructor must have exactly one output of the same type as the constructor
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9470, column 9:
  An external object destructor must have exactly one input of the same type as the constructor, and no outputs
")})));
end TestExternalObj9;


model TestExternalObj10
	MyExternalObject myEO = MyExternalObject.constructor();
equation
	MyExternalObject.constructor();
	MyExternalObject.destructor(myEO);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TestExternalObj10",
			description="",
			errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9477, column 26:
  Constructors and destructors for ExternalObjects can not be used directly
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9479, column 2:
  Constructors and destructors for ExternalObjects can not be used directly
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 9480, column 2:
  Constructors and destructors for ExternalObjects can not be used directly
")})));
end TestExternalObj10;

model TestRuntimeOptions1
	Real x = 1;

	annotation(__JModelica(UnitTesting(tests={ 
		TransformCanonicalTestCase(
			name="TestRuntimeOptions1",
			description="Test that parameters for runtime options are generated properly",
			generate_runtime_option_parameters=true,
			nle_solver_tol_factor=1e-3,
			generate_ode=true,
			flatModel="
fclass TransformCanonicalTests.TestRuntimeOptions1
 Real x;
 parameter Boolean _enforce_bounds = false /* false */;
 parameter Real _events_default_tol = 1.0E-10 /* 1.0E-10 */;
 parameter Real _events_tol_factor = 1.0E-4 /* 1.0E-4 */;
 parameter Integer _log_level = 3 /* 3 */;
 parameter Boolean _nle_solver_check_jac_cond = false /* false */;
 parameter Real _nle_solver_default_tol = 1.0E-10 /* 1.0E-10 */;
 parameter Integer _nle_solver_log_level = 0 /* 0 */;
 parameter Real _nle_solver_min_tol = 1.0E-12 /* 1.0E-12 */;
 parameter Real _nle_solver_tol_factor = 1.0E-3 /* 1.0E-3 */;
 parameter Boolean _rescale_after_singular_jac = true /* true */;
 parameter Boolean _rescale_each_step = false /* false */;
 parameter Boolean _use_Brent_in_1d = false /* false */;
 parameter Boolean _use_automatic_scaling = true /* true */;
 parameter Boolean _use_jacobian_scaling = false /* false */;
 parameter Boolean _use_manual_equation_scaling = false /* false */;
equation
 x = 1;
end TransformCanonicalTests.TestRuntimeOptions1;
")})));
end TestRuntimeOptions1;


end TransformCanonicalTests;
