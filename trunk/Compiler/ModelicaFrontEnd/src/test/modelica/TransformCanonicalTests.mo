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
 der(x) =  - ( x );
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
 parameter Real p5 = 5 /* 5.0 */;
 parameter Real p2;
 parameter Real p3;
 parameter Real p4;
 parameter Real p1 = 4 /* 4.0 */;
parameter equation
 p6 = p5;
 p2 = ( p1 ) * ( p1 );
 p3 = p2 + p1;
 p4 = ( p3 ) * ( p3 );

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
3 errors found...
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 86, column 24:
  Circularity in binding expression of parameter: p4 = ( p3 ) * ( p3 )
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 87, column 24:
  Circularity in binding expression of parameter: p3 = p2 + p1
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 88, column 24:
  Circularity in binding expression of parameter: p2 = ( p4 ) * ( p1 )
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
			errorMessage=" 3 errors found...
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 112, column 24:
  Circularity in binding expression of parameter: p4 = ( p3 ) * ( p3 )
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 113, column 24:
  Circularity in binding expression of parameter: p3 = p2 + p1
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 114, column 24:
  Circularity in binding expression of parameter: p2 = ( p1 ) * ( p2 )
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
 parameter Real p7 = 1 /* 1.0 */;
 parameter Real p5 = 1 /* 1.0 */;
 parameter Real p3 = 1 /* 1.0 */;
parameter equation
 p11 = ( p7 ) * ( p5 );
 p8 = ( p7 ) * ( p3 );
 p10 = ( p11 ) * ( p3 );
 p2 = p11;
 p9 = ( p11 ) * ( p8 );

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
			generate_ode_jacobian=true,
			description="Test that derivative functions are included in the flattened model if Jacobians are to be generated.",
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
  y := ( TransformCanonicalTests.TransformCanonicalTest8.f1(x) ) * ( 2 );
  return;
 end TransformCanonicalTests.TransformCanonicalTest8.f;

 function TransformCanonicalTests.TransformCanonicalTest8.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := ( ( 2 ) * ( x ) ) * ( der_x );
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
 x3 = (  - ( x1 ) ) ^ 2;

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
  - ( der(x1) ) = 0;

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
 parameter Real p = 1 /* 1.0 */;
equation
 y =  - ( p ) + 1;

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
 pml3 + ( pml1 ) * ( pml1 ) = 0;
 cos(pml1) + ( pml3 ) * ( pml3 ) = 0;
 mpl3 + ( mpl1 ) * ( mpl1 ) = 0;
 cos(mpl1) + ( mpl3 ) * ( mpl3 ) = 0;
 mml3 + (  - ( mml1 ) ) * (  - ( mml1 ) ) = 0;
 cos(mml1) + ( mml3 ) * ( mml3 ) = 0;
 pmr3 + ( pmr1 ) * ( pmr1 ) = 0;
 cos(pmr1) + ( pmr3 ) * ( pmr3 ) = 0;
 mpr3 + ( mpr1 ) * ( mpr1 ) = 0;
 cos(mpr1) + ( mpr3 ) * ( mpr3 ) = 0;
 mmr3 + (  - ( mmr1 ) ) * (  - ( mmr1 ) ) = 0;
 cos(mmr1) + ( mmr3 ) * ( mmr3 ) = 0;

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
 parameter Boolean f = true;
 Real y;
 parameter Real p = 5;
equation
 0.0 =  - ( y );

end TransformCanonicalTests.AliasTest30;
")})));
end AliasTest30;


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
 der(x2) = x1 - ( x2 ) + y2;
 y1 = ( 3 ) * ( x1 );
 y2 = ( 4 ) * ( x2 );

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
 der(x2) = x1 - ( x2 ) + y2;
 y1 = ( 3 ) * ( x1 );
 y2 = ( 4 ) * ( x2 );

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
 der(x2) = x1 - ( x2 ) + y2;
 y1 = ( 3 ) * ( x1 );
 y2 = ( 4 ) * ( x2 );

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
 der(x2) = x1 - ( x2 ) + y2;
 y1 = ( 3 ) * ( x1 );
 y2 = ( 4 ) * ( x2 );

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
 der(x2) = x1 - ( x2 ) + y2;
 y1 = ( 3 ) * ( x1 );
 y2 = ( 4 ) * ( x2 );

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
 der(x) =  - ( x );
 der(y) =  - ( y );

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
 ({x[1],x[2],x[3]}, {y[1],y[2],y[3],y[4]}) = TransformCanonicalTests.f2({1,1,1}, {1,1,1,1});
equation
 der(x[1]) =  - ( x[1] );
 der(x[2]) =  - ( x[2] );
 der(x[3]) =  - ( x[3] );
 der(y[1]) =  - ( y[1] );
 der(y[2]) =  - ( y[2] );
 der(y[3]) =  - ( y[3] );
 der(y[4]) =  - ( y[4] );

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
 ({x[1],x[2],x[3]}, ) = TransformCanonicalTests.f2({1,1,1}, {1,1,1,1});
equation
 der(x[1]) =  - ( x[1] );
 der(x[2]) =  - ( x[2] );
 der(x[3]) =  - ( x[3] );
 (, {y[1],y[2],y[3],y[4]}) = TransformCanonicalTests.f2({1,1,1}, {1,1,1,1});

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
 der(x[1]) =  - ( x[1] );
 der(x[2]) =  - ( x[2] );
 der(x[3]) =  - ( x[3] );
 (, {y[1],y[2],y[3],y[4]}) = TransformCanonicalTests.f2({1,1,1}, {1,1,1,1});

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
 der(x1) =  - ( x1 );
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
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
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
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
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
  The system is structurally singuar. The following equation(s) could not be matched to any variable:
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
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
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
  The system is structurally singuar. The following equation(s) could not be matched to any variable:
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
 der(z[1:3]) = ( z[1:3] ) .* ( {0.1,0.2,0.3} );
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
 der(z[1]) = ( z[1] ) .* ( 0.1 );
 der(z[2]) = ( z[2] ) .* ( 0.2 );
 der(z[3]) = ( z[3] ) .* ( 0.3 );
 when {z[1] > 2,z[2] > 2,z[3] > 2} then
  x[1] = 1;
 elsewhen {z[1] < 0,z[2] < 0,z[3] < 0} then
  x[1] = 4;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[1] = 7;
 end when;
 when {z[1] > 2,z[2] > 2,z[3] > 2} then
  x[2] = 2;
 elsewhen {z[1] < 0,z[2] < 0,z[3] < 0} then
  x[2] = 5;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[2] = 8;
 end when;
 when {z[1] > 2,z[2] > 2,z[3] > 2} then
  x[3] = 3;
 elsewhen {z[1] < 0,z[2] < 0,z[3] < 0} then
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
 der(xx) =  - ( x );
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
 der(xx) =  - ( x );
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
der(x) = ( a ) * ( x );
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
 when dummy >  - ( 1 ) then
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
 when sample(0, ( 1 ) / ( 3 )) then
  x = pre(x) + 1;
 end when;
 when sample(0, ( 2 ) / ( 3 )) then
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
 der(x) =  - ( x ) + u;
 when sample(0, h) then
  I = pre(I) + ( h ) * ( ref - ( x ) );
 end when;
 when sample(0, h) then
  u = ( K ) * ( ref - ( x ) ) + ( ( 1 ) / ( Ti ) ) * ( I );
 end when;
 ref = (if time < 1 then 0 else 1);

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
 Real x_p(start = 1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p =  - ( 1 ) /* -1 */;
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
 der(x_p) = ( a_p ) * ( x_p ) + ( b_p ) * ( u_p );
 u_p = ( c_c ) * ( x_c );
 sampleTrigger = sample(0, h);
 when {initial(),sampleTrigger} then
  u_c = ( c_p ) * ( x_p );
 end when;
 when {initial(),sampleTrigger} then
  x_c = ( a_c ) * ( pre(x_c) ) + ( b_c ) * ( u_c );
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
 parameter Real a_p =  - ( 1 ) /* -1 */;
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
 der(x_p) = ( a_p ) * ( x_p ) + ( b_p ) * ( u_p );
 u_p = ( c_c ) * ( x_c );
 sampleTrigger = sample(0, h);
 when {atInit,sampleTrigger} then
  u_c = ( c_p ) * ( x_p );
 end when;
 when {atInit,sampleTrigger} then
  x_c = ( a_c ) * ( pre(x_c) ) + ( b_c ) * ( u_c );
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
 x[1] = (if y[1] then 1 elseif y[2] then 4 else 7);
 x[2] = (if y[1] then 2 elseif y[2] then 5 else 8);
 x[3] = (if y[1] then 3 elseif y[2] then 6 else 9);
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
 x[1] = (if y[1] then 1 elseif y[2] then 4 else 7);
 x[2] = (if y[1] then 2 elseif y[2] then 5 else 8);
 x[3] = (if y[1] then 3 elseif y[2] then 6 else 9);
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
 x[1] = (if y then 3 else 7);
 x[2] = (if y then 4 else 8);
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
 x[1] = (if y then 3 else 5);
 x[2] = (if y then 4 else 6);
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
 u = (if time >= 1 then  - ( 1 ) else 1);
 der(x) =  - ( x ) + u;
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
 der(x) = (if time >= 1 then (  - ( 3 ) ) * ( x ) + u else ( 3 ) * ( x ) + u);
 u = (if time >= 1 then  - ( 1 ) else 1);
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
 der(x) = (if time >= 1 then (if time >= 3 then (  - ( 3 ) ) * ( x ) + u else 0) else ( 3 ) * ( x ) + u);
 u = (if time >= 1 then (if time >= 3 then  - ( 1 ) else 4) else 1);
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
 x = (if time < 1 then ( y ) * ( y ) elseif time < 3 then y + 4 else 4);
 y = (if time < 1 then z2 - ( 1 ) elseif time < 3 then 2 else x + 2);
 0.0 = (if time < 1 then z1 - ( 2 ) else z2 - ( (if time < 3 then ( y ) * ( x ) else ( 4 ) * ( x )) ));
 0.0 = (if time < 1 then z1 + z2 - ( x + y ) elseif time < 3 then z1 - ( z2 ) - ( x + y ) else z1 + z2 - ( x - ( y ) ));
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
 x = (if time < 1 then ( y ) * ( y ) else 4);
 y = (if time < 1 then z2 - ( 1 ) elseif time < 3 then 2 else x + 2);
 0.0 = (if time < 1 then z1 - ( 2 ) elseif time < 3 then z1 - ( ( y ) * ( x ) ) else z2 - ( ( 4 ) * ( x ) ));
 0.0 = (if time < 1 then z1 + z2 - ( x + y ) else z1 + z2 - ( x - ( y ) ));
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
  x = (if time >= 3 then pre(x) + 1 else pre(x) + 5);
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
 der(x) =  - ( x );
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
 x = (if time >= 3 then 3 else 4);
equation
 der(x) =  - ( x );
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
 x[1] = (if b then temp_1[1] else 0);
 x[2] = (if b then temp_1[2] else 0);
 ({temp_1[1],temp_1[2]}) = TransformCanonicalTests.IfEqu22.f({1,2});
 b = true;

public
 function TransformCanonicalTests.IfEqu22.f
  input Real[2] u;
  output Real[2] y;
 algorithm
  u[1] := ( 2 ) * ( y[1] );
  u[2] := ( 2 ) * ( y[2] );
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
 r.x = (if time > 1 then temp_1.x else temp_2.x);
 r.y = (if time > 1 then temp_1.y else temp_2.y);
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
 0 = x1 - ( x2 ) + 2;
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
 (if time >= 1 then 1 else 0) = x;
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

  model IndexReduction1_PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction1_PlanarPendulum",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction1_PlanarPendulum
parameter Real L = 1 \"Pendulum length\" /* 1 */;
parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
Real x \"Cartesian x coordinate\";
Real y \"Cartesian x coordinate\";
Real vx \"Velocity in x coordinate\";
Real lambda \"Lagrange multiplier\";
Real der_y;
Real der_vx;
Real _der_x;
Real der_2_y;
initial equation 
x = 0.0;
_der_x = 0.0;
equation
der(x) = vx;
der_vx = ( lambda ) * ( x );
der_2_y = ( lambda ) * ( y ) - ( g );
x ^ 2 + y ^ 2 = L;
( ( 2 ) * ( x ) ) * ( der(x) ) + ( ( 2 ) * ( y ) ) * ( der_y ) = 0.0;
( ( 2 ) * ( x ) ) * ( der(_der_x) ) + ( ( 2 ) * ( der(x) ) ) * ( der(x) ) + ( ( 2 ) * ( y ) ) * ( der_2_y ) + ( ( 2 ) * ( der_y ) ) * ( der_y ) = 0.0;
der(_der_x) = der_vx;
_der_x = der(x);
end TransformCanonicalTests.IndexReduction1_PlanarPendulum;
")})));
  end IndexReduction1_PlanarPendulum;

  model IndexReduction2_Mechanical
    extends Modelica.Mechanics.Rotational.Examples.First(freqHz=5,amplitude=10,
    damper(phi_rel(stateSelect=StateSelect.always),w_rel(stateSelect=StateSelect.always)));


	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction2_Mechanical",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction2_Mechanical
 parameter Modelica.SIunits.Torque amplitude = 10 \"Amplitude of driving torque\" /* 10 */;
 parameter Modelica.SIunits.Frequency freqHz = 5 \"Frequency of driving torque\" /* 5 */;
 parameter Modelica.SIunits.Inertia Jmotor(min = 0) = 0.1 \"Motor inertia\" /* 0.1 */;
 parameter Modelica.SIunits.Inertia Jload(min = 0) = 2 \"Load inertia\" /* 2 */;
 parameter Real ratio = 10 \"Gear ratio\" /* 10 */;
 parameter Real damping = 10 \"Damping in bearing of gear\" /* 10 */;
 parameter Modelica.SIunits.Angle fixed.phi0 = 0 \"Fixed offset angle of housing\" /* 0 */;
 Modelica.SIunits.Torque fixed.flange.tau \"Cut torque in the flange\";
 parameter Boolean torque.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 Modelica.SIunits.Torque torque.flange.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.Inertia inertia1.J(min = 0,start = 1) \"Moment of inertia\";
 parameter StateSelect inertia1.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia1.phi(stateSelect = inertia1.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia1.w(stateSelect = inertia1.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia1.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Real idealGear.ratio(start = 1) \"Transmission ratio (flange_a.phi/flange_b.phi)\";
 Modelica.SIunits.Angle idealGear.phi_a \"Angle between left shaft flange and support\";
 Modelica.SIunits.Angle idealGear.phi_b \"Angle between right shaft flange and support\";
 parameter Boolean idealGear.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
 Modelica.SIunits.Torque idealGear.flange_a.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque idealGear.flange_b.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque idealGear.support.tau \"Reaction torque in the support/housing\";
 Modelica.SIunits.Torque inertia2.flange_b.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.Inertia inertia2.J(min = 0,start = 1) = 2 \"Moment of inertia\" /* 2 */;
 parameter StateSelect inertia2.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia2.phi(fixed = true,start = 0,stateSelect = inertia2.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia2.w(fixed = true,stateSelect = inertia2.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia2.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.RotationalSpringConstant spring.c(final min = 0,start = 100000.0) = 10000.0 \"Spring constant\" /* 10000.0 */;
 parameter Modelica.SIunits.Angle spring.phi_rel0 = 0 \"Unstretched spring angle\" /* 0 */;
 Modelica.SIunits.Angle spring.phi_rel(fixed = true,start = 0) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.Torque spring.flange_b.tau \"Cut torque in the flange\";
 Modelica.SIunits.Torque inertia3.flange_b.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.Inertia inertia3.J(min = 0,start = 1) \"Moment of inertia\";
 parameter StateSelect inertia3.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
 Modelica.SIunits.Angle inertia3.phi(stateSelect = inertia3.stateSelect) \"Absolute rotation angle of component\";
 Modelica.SIunits.AngularVelocity inertia3.w(fixed = true,stateSelect = inertia3.stateSelect) \"Absolute angular velocity of component (= der(phi))\";
 Modelica.SIunits.AngularAcceleration inertia3.a \"Absolute angular acceleration of component (= der(w))\";
 parameter Modelica.SIunits.RotationalDampingConstant damper.d(final min = 0,start = 0) \"Damping constant\";
 Modelica.SIunits.Angle damper.phi_rel(stateSelect = StateSelect.always,start = 0,nominal = damper.phi_nominal) \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
 Modelica.SIunits.AngularVelocity damper.w_rel(stateSelect = StateSelect.always,start = 0) \"Relative angular velocity (= der(phi_rel))\";
 Modelica.SIunits.AngularAcceleration damper.a_rel(start = 0) \"Relative angular acceleration (= der(w_rel))\";
 Modelica.SIunits.Torque damper.flange_b.tau \"Cut torque in the flange\";
 parameter Modelica.SIunits.Angle damper.phi_nominal(displayUnit = \"rad\") = 1.0E-4 \"Nominal value of phi_rel (used for scaling)\" /* 1.0E-4 */;
 parameter StateSelect damper.stateSelect = StateSelect.prefer \"Priority to use phi_rel and w_rel as states\" /* StateSelect.prefer */;
 parameter Real sine.amplitude \"Amplitude of sine wave\";
 parameter Modelica.SIunits.Frequency sine.freqHz(start = 1) \"Frequency of sine wave\";
 parameter Modelica.SIunits.Angle sine.phase = 0 \"Phase of sine wave\" /* 0 */;
 parameter Real sine.offset = 0 \"Offset of output signal\" /* 0 */;
 parameter Modelica.SIunits.Time sine.startTime = 0 \"Output = offset for time < startTime\" /* 0 */;
 constant Real sine.pi = 3.141592653589793;
initial equation 
 inertia2.phi = 0;
 inertia2.w = 0.0;
 inertia3.w = 0.0;
 spring.phi_rel = 0;
parameter equation
 inertia1.J = Jmotor;
 idealGear.ratio = ratio;
 inertia3.J = Jload;
 damper.d = damping;
 sine.amplitude = amplitude;
 sine.freqHz = freqHz;
equation
 ( inertia1.J ) * ( inertia1.a ) =  - ( torque.flange.tau ) - ( idealGear.flange_a.tau );
 idealGear.phi_a = inertia1.phi - ( fixed.phi0 );
 idealGear.phi_b = inertia2.phi - ( fixed.phi0 );
 idealGear.phi_a = ( idealGear.ratio ) * ( idealGear.phi_b );
 0 = ( idealGear.ratio ) * ( idealGear.flange_a.tau ) + idealGear.flange_b.tau;
 ( inertia2.J ) * ( inertia2.a ) =  - ( idealGear.flange_b.tau ) + inertia2.flange_b.tau;
 spring.flange_b.tau = ( spring.c ) * ( spring.phi_rel - ( spring.phi_rel0 ) );
 spring.phi_rel = inertia3.phi - ( inertia2.phi );
 inertia3.w = inertia3.der(phi);
 inertia3.a = inertia3.der(w);
 ( inertia3.J ) * ( inertia3.a ) =  - ( spring.flange_b.tau ) + inertia3.flange_b.tau;
 damper.flange_b.tau = ( damper.d ) * ( damper.w_rel );
 damper.phi_rel = fixed.phi0 - ( inertia2.phi );
 damper.w_rel = damper.der(phi_rel);
 damper.a_rel = damper.der(w_rel);
  - ( torque.flange.tau ) = sine.offset + (if time < sine.startTime then 0 else ( sine.amplitude ) * ( sin(( ( ( 2 ) * ( 3.141592653589793 ) ) * ( sine.freqHz ) ) * ( time - ( sine.startTime ) ) + sine.phase) ));
  - ( damper.flange_b.tau ) + inertia2.flange_b.tau - ( spring.flange_b.tau ) = 0;
 damper.flange_b.tau + fixed.flange.tau + idealGear.support.tau - ( torque.flange.tau ) = 0;
 inertia3.flange_b.tau = 0;
 idealGear.support.tau =  - ( idealGear.flange_a.tau ) - ( idealGear.flange_b.tau );
 inertia1.w = ( idealGear.ratio ) * ( inertia2.w );
 inertia1.a = ( idealGear.ratio ) * ( inertia2.a );
 damper.der(phi_rel) =  - ( inertia2.w );
 damper.der(w_rel) =  - ( inertia2.a );

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

 type Modelica.SIunits.Torque = Real(final quantity = \"Torque\",final unit = \"N.m\");
 type Modelica.SIunits.Frequency = Real(final quantity = \"Frequency\",final unit = \"Hz\");
 type Modelica.SIunits.Inertia = Real(final quantity = \"MomentOfInertia\",final unit = \"kg.m2\");
 type Modelica.SIunits.Angle = Real(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\");
 type Modelica.Blocks.Interfaces.RealInput = Real;
 type Modelica.SIunits.AngularVelocity = Real(final quantity = \"AngularVelocity\",final unit = \"rad/s\");
 type Modelica.SIunits.AngularAcceleration = Real(final quantity = \"AngularAcceleration\",final unit = \"rad/s2\");
 type Modelica.SIunits.RotationalSpringConstant = Real(final quantity = \"RotationalSpringConstant\",final unit = \"N.m/rad\");
 type Modelica.SIunits.RotationalDampingConstant = Real(final quantity = \"RotationalDampingConstant\",final unit = \"N.m.s/rad\");
 type Modelica.SIunits.Time = Real(final quantity = \"Time\",final unit = \"s\");
 type Modelica.Blocks.Interfaces.RealOutput = Real;
end TransformCanonicalTests.IndexReduction2_Mechanical;
")})));
  end IndexReduction2_Mechanical;

  model IndexReduction3_Electrical
  parameter Real omega=100;
  parameter Real R[2]={10,5};
  parameter Real L=1;
  parameter Real C=0.05;
  Real iL (start=1);
  Real uC (start=1);
  Real u0,u1,u2,uL;
  Real i0,i1,i2,iC;
equation
  u0=220*sin(time*omega);
  u1=R[1]*i1;
  u2=R[2]*i2;
  uL=L*der(iL);
  iC=C*der(uC);
  u0= u1+uL;
  uC=u1+u2;
  uL=u2;
  i0=i1+iC;
  i1=i2+iL;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction3_Electrical",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction3_Electrical
 parameter Real omega = 100 /* 100 */;
 parameter Real R[1] = 10 /* 10 */;
 parameter Real R[2] = 5 /* 5 */;
 parameter Real L = 1 /* 1 */;
 parameter Real C = 0.05 /* 0.05 */;
 Real iL(start = 1);
 Real uC(start = 1);
 Real u0;
 Real u1;
 Real uL;
 Real i0;
 Real i1;
 Real i2;
 Real iC;
 Real der_uC;
 Real der_u1;
 Real der_i1;
 Real der_i2;
 Real der_uL;
 Real der_u0;
initial equation 
 iL = 1;
equation
 u0 = ( 220 ) * ( sin(( time ) * ( omega )) );
 u1 = ( R[1] ) * ( i1 );
 uL = ( R[2] ) * ( i2 );
 uL = ( L ) * ( der(iL) );
 iC = ( C ) * ( der_uC );
 u0 = u1 + uL;
 uC = u1 + uL;
 i0 = i1 + iC;
 i1 = i2 + iL;
 der_uC = der_u1 + der_uL;
 der_u1 = ( R[1] ) * ( der_i1 );
 der_i1 = der_i2 + der(iL);
 der_uL = ( R[2] ) * ( der_i2 );
 der_u0 = der_u1 + der_uL;
 der_u0 = ( 220 ) * ( ( cos(( time ) * ( omega )) ) * ( ( 1.0 ) * ( omega ) ) );
end TransformCanonicalTests.IndexReduction3_Electrical;
		  
")})));
  end IndexReduction3_Electrical;

model IndexReduction4_Err
  function F
    input Real x;
    output Real y;
  algorithm
    y := sin(x);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  x1 + F(x2) = 1; 

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="IndexReduction4_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc8802960033354722744out/sources/TransformCanonicalTests.IndexReduction4_Err.mof':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative annotation 'TransformCanonicalTests.IndexReduction4_Err.F(x2)' in equation:
   x1 + TransformCanonicalTests.IndexReduction4_Err.F(x2) = 1

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc8802960033354722744out/sources/TransformCanonicalTests.IndexReduction4_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
   der(x2)

  The follwowing equation(s) could not be matched to any variable:
   x1 + TransformCanonicalTests.IndexReduction4_Err.F(x2) = 1
")})));
end IndexReduction4_Err;

model IndexReduction5_Err
  function F
    input Real x;
    output Real y1;
    output Real y2;
  algorithm
    y1 := sin(x);
    y1 := cos(x);
  end F;
  Real x1;
  Real x2;
equation
  der(x1) + der(x2) = 1;
  (x1,x2) = F(x2); 

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="IndexReduction5_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="
3 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file 'TransformCanonicalTests.IndexReduction5_Err.mof':
Semantic error at line 0, column 0:
  Cannot differentiate call to function without derivative annotation 'TransformCanonicalTests.IndexReduction5_Err.F(x2)' in equation:
   (x1, x2) = TransformCanonicalTests.IndexReduction5_Err.F(x2)

Error: in file 'TransformCanonicalTests.IndexReduction5_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 3 equations and 2 free variables.

Error: in file 'TransformCanonicalTests.IndexReduction5_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
   der(x2)

  The follwowing equation(s) could not be matched to any variable:
   (x1, x2) = TransformCanonicalTests.IndexReduction5_Err.F(x2)
   (x1, x2) = TransformCanonicalTests.IndexReduction5_Err.F(x2)
")})));
end IndexReduction5_Err;

  model IndexReduction6_Cos
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + cos(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction6_Cos",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction6_Cos
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + cos(x2) = 0;
 der_x1 - ( ( sin(x2) ) * ( der(x2) ) ) = 0.0;
end TransformCanonicalTests.IndexReduction6_Cos;
")})));
  end IndexReduction6_Cos;

  model IndexReduction7_Sin
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + sin(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction7_Sin",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction7_Sin
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + sin(x2) = 0;
 der_x1 + ( cos(x2) ) * ( der(x2) ) = 0.0;
end TransformCanonicalTests.IndexReduction7_Sin;
")})));
  end IndexReduction7_Sin;

  model IndexReduction8_Neg
  Real x1,x2(stateSelect=StateSelect.prefer);
equation
  der(x1) + der(x2) = 1;
- x1 + 2*x2 = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction8_Neg",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction8_Neg		 
Real x1;
Real x2(stateSelect=StateSelect.prefer);
Real der_x1;
initial equation 
x2 = 0.0;
equation
der_x1 + der(x2) = 1;
- ( x1 ) + ( 2 ) * ( x2 ) = 0;
- ( der_x1 ) + ( 2 ) * ( der(x2) ) = 0.0;

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction8_Neg;
")})));
  end IndexReduction8_Neg;

  model IndexReduction9_Exp
  Real x1,x2(stateSelect=StateSelect.prefer);
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + exp(x2*p*time) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction9_Exp",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction9_Exp
Real x1;
Real x2(stateSelect=StateSelect.prefer);
parameter Real p = 2 /* 2 */;
Real der_x1;
initial equation 
x2 = 0.0;
equation
der_x1 + der(x2) = 1;
x1 + exp(( ( x2 ) * ( p ) ) * ( time )) = 0;
der_x1 + ( exp(( ( x2 ) * ( p ) ) * ( time )) ) * ( ( ( x2 ) * ( p ) ) * ( 1.0 ) + ( ( der(x2) ) * ( p ) ) * ( time ) ) = 0.0;

public
type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction9_Exp;
")})));
  end IndexReduction9_Exp;

  model IndexReduction10_Tan
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + tan(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction10_Tan",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction10_Tan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + tan(x2) = 0;
 der_x1 + ( der(x2) ) / ( ( cos(x2) ) ^ 2 ) = 0.0;
end TransformCanonicalTests.IndexReduction10_Tan;
")})));
  end IndexReduction10_Tan;

  model IndexReduction11_Asin
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + asin(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction11_Asin",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction11_Asin
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + asin(x2) = 0;
 der_x1 + ( der(x2) ) / ( sqrt(1 - ( x2 ^ 2 )) ) = 0.0;
end TransformCanonicalTests.IndexReduction11_Asin;
")})));
  end IndexReduction11_Asin;

  model IndexReduction12_Acos
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + acos(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction12_Acos",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction12_Acos
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + acos(x2) = 0;
 der_x1 + (  - ( der(x2) ) ) / ( sqrt(1 - ( x2 ^ 2 )) ) = 0.0;
end TransformCanonicalTests.IndexReduction12_Acos;
")})));
  end IndexReduction12_Acos;

  model IndexReduction13_Atan
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + atan(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction13_Atan",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction13_Atan
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + atan(x2) = 0;
 der_x1 + ( der(x2) ) / ( 1 + x2 ^ 2 ) = 0.0;
end TransformCanonicalTests.IndexReduction13_Atan;
")})));
  end IndexReduction13_Atan;
/*
  model IndexReduction14_Atan2
  Real x1,x2,x3;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + atan2(x2,x3) = 0;
  

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction14_Atan2",
			description="Test of index reduction",
			flatModel="
")})));
  end IndexReduction14_Atan2;
*/
  model IndexReduction15_Sinh
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + sinh(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction15_Sinh",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction15_Sinh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + sinh(x2) = 0;
 der_x1 + ( cosh(x2) ) * ( der(x2) ) = 0.0;
end TransformCanonicalTests.IndexReduction15_Sinh;
")})));
  end IndexReduction15_Sinh;

  model IndexReduction16_Cosh
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + cosh(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction16_Cosh",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction16_Cosh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + cosh(x2) = 0;
 der_x1 + ( sinh(x2) ) * ( der(x2) ) = 0.0;
end TransformCanonicalTests.IndexReduction16_Cosh;
")})));
  end IndexReduction16_Cosh;

  model IndexReduction17_Tanh
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + tanh(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction17_Tanh",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction17_Tanh
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + tanh(x2) = 0;
 der_x1 + ( der(x2) ) / ( ( cosh(x2) ) ^ 2 ) = 0.0;
end TransformCanonicalTests.IndexReduction17_Tanh;
")})));
  end IndexReduction17_Tanh;

  model IndexReduction18_Log
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + log(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction18_Log",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction18_Log
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + log(x2) = 0;
 der_x1 + ( der(x2) ) / ( x2 ) = 0.0;
end TransformCanonicalTests.IndexReduction18_Log;
")})));
  end IndexReduction18_Log;

  model IndexReduction19_Log10
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + log10(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction19_Log10",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction19_Log10
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + log10(x2) = 0;
 der_x1 + ( der(x2) ) / ( ( x2 ) * ( log(10) ) ) = 0.0;
end TransformCanonicalTests.IndexReduction19_Log10;
")})));
  end IndexReduction19_Log10;

  model IndexReduction20_Sqrt
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + sqrt(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction20_Sqrt",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction20_Sqrt
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + sqrt(x2) = 0;
 der_x1 + ( der(x2) ) / ( ( 2 ) * ( sqrt(x2) ) ) = 0.0;
end TransformCanonicalTests.IndexReduction20_Sqrt;
")})));
  end IndexReduction20_Sqrt;

  model IndexReduction21_If
  Real x1,x2(stateSelect=StateSelect.prefer);
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + (if p>3 then 3*x2 else if p<=3 then sin(x2) else 2*x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction21_If",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction21_If
Real x1;
Real x2(stateSelect=StateSelect.prefer);
parameter Real p = 2 /* 2 */;
Real der_x1;
initial equation 
x2 = 0.0;
equation
der_x1 + der(x2) = 1;
x1 + (if p > 3 then ( 3 ) * ( x2 ) elseif p <= 3 then sin(x2) else ( 2 ) * ( x2 )) = 0;
der_x1 + (if p > 3 then ( 3 ) * ( der(x2) ) elseif p <= 3 then ( cos(x2) ) * ( der(x2) ) else ( 2 ) * ( der(x2) )) = 0.0;

public
type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction21_If;
")})));
  end IndexReduction21_If;

  model IndexReduction22_Pow
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + x2^p + x2^1.4 = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction22_Pow",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction22_Pow
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + x2 ^ p + x2 ^ 1.4 = 0;
 der_x1 + ( ( p ) * ( x2 ^ ( p - ( 1 ) ) ) ) * ( der(x2) ) + ( ( 1.4 ) * ( x2 ^ 0.3999999999999999 ) ) * ( der(x2) ) = 0.0;
end TransformCanonicalTests.IndexReduction22_Pow;
")})));
  end IndexReduction22_Pow;

  model IndexReduction23_BasicVolume_Err
import Modelica.SIunits.*;
parameter SpecificInternalEnergy u_0 = 209058;
parameter SpecificHeatCapacity c_v = 717;
parameter Temperature T_0 = 293;
parameter Mass m_0 = 0.00119;
parameter SpecificHeatCapacity R = 287;
Pressure P;
Volume V;
Mass m(start=m_0);
Temperature T;
MassFlowRate mdot_in;
MassFlowRate mdot_out;
SpecificEnthalpy h_in, h_out;
SpecificEnthalpy h;
Enthalpy H;
SpecificInternalEnergy u;
InternalEnergy U(start=u_0*m_0);
equation

// Boundary equations
V=1e-3;
T=293;
mdot_in=0.1e-3;
mdot_out=0.01e-3;
h_in = 300190;
h_out = h;

// Conservation of mass
der(m) = mdot_in-mdot_out;

// Conservation of energy
der(U) = h_in*mdot_in - h_out*mdot_out;

// Specific internal energy (ideal gas)
u = U/m;
u = u_0+c_v*(T-T_0);

// Specific enthalpy
H = U+P*V;
h = H/m;

// Equation of state (ideal gas)
P*V=m*R*T;  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="IndexReduction23_BasicVolume_Err",
			description="Test error messages for unbalanced systems.",
			errorMessage="2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc2815301804134878885out/resources/BasicVolume.mof':
Semantic error at line 0, column 0:
  The DAE system has 12 equations and 11 free variables.

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc2815301804134878885out/resources/BasicVolume.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following equation(s) could not be matched to any variable:
   u = u_0 + ( c_v ) * ( T - ( T_0 ) )
")})));
  end IndexReduction23_BasicVolume_Err;

model IndexReduction24_DerFunc
function f
  input Real x;
  output Real y;
algorithm
  y := x^2;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x;
  input Real der_x;
  output Real der_y;
algorithm
  der_y := 2*x*der_x;
end f_der;

  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + f(x2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction24_DerFunc",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction24_DerFunc
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + TransformCanonicalTests.IndexReduction24_DerFunc.f(x2) = 0;
 der_x1 + TransformCanonicalTests.IndexReduction24_DerFunc.f_der(x2, der(x2)) = 0.0;

public
 function TransformCanonicalTests.IndexReduction24_DerFunc.f_der
  input Real x;
  input Real der_x;
  output Real der_y;
 algorithm
  der_y := ( ( 2 ) * ( x ) ) * ( der_x );
  return;
 end TransformCanonicalTests.IndexReduction24_DerFunc.f_der;

 function TransformCanonicalTests.IndexReduction24_DerFunc.f
  input Real x;
  output Real y;
 algorithm
  y := x ^ 2;
  return;
 end TransformCanonicalTests.IndexReduction24_DerFunc.f;

end TransformCanonicalTests.IndexReduction24_DerFunc;
")})));
end IndexReduction24_DerFunc;

model IndexReduction25_DerFunc
function f
  input Real x[2];
  input Real A[2,2];
  output Real y;
algorithm
  y := x*A*x;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output Real der_y;
algorithm
  der_y := 2*x*A*der_x + x*der_A*x;
end f_der;
  parameter Real A[2,2] = {{1,2},{3,4}};
  Real x1[2],x2[2];
equation
  der(x1) + der(x2) = {1,2};
  x1[1] + f(x2,A) = 0;
  x1[2] = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction25_DerFunc",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction25_DerFunc
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real der_x1_1;
 Real der_x1_2;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 1;
 der_x1_2 + der(x2[2]) = 2;
 x1[1] + TransformCanonicalTests.IndexReduction25_DerFunc.f({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}}) = 0;
 x1[2] = 0;
 der_x1_1 + TransformCanonicalTests.IndexReduction25_DerFunc.f_der({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}}, {der(x2[1]),der(x2[2])}, {{0.0,0.0},{0.0,0.0}}) = 0.0;
 der_x1_2 = 0.0;

public
 function TransformCanonicalTests.IndexReduction25_DerFunc.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output Real der_y;
 algorithm
  der_y := ( ( ( 2 ) * ( x[1] ) ) * ( A[1,1] ) + ( ( 2 ) * ( x[2] ) ) * ( A[2,1] ) ) * ( der_x[1] ) + ( ( ( 2 ) * ( x[1] ) ) * ( A[1,2] ) + ( ( 2 ) * ( x[2] ) ) * ( A[2,2] ) ) * ( der_x[2] ) + ( ( x[1] ) * ( der_A[1,1] ) + ( x[2] ) * ( der_A[2,1] ) ) * ( x[1] ) + ( ( x[1] ) * ( der_A[1,2] ) + ( x[2] ) * ( der_A[2,2] ) ) * ( x[2] );
  return;
 end TransformCanonicalTests.IndexReduction25_DerFunc.f_der;

 function TransformCanonicalTests.IndexReduction25_DerFunc.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real y;
 algorithm
  y := ( ( x[1] ) * ( A[1,1] ) + ( x[2] ) * ( A[2,1] ) ) * ( x[1] ) + ( ( x[1] ) * ( A[1,2] ) + ( x[2] ) * ( A[2,2] ) ) * ( x[2] );
  return;
 end TransformCanonicalTests.IndexReduction25_DerFunc.f;

end TransformCanonicalTests.IndexReduction25_DerFunc;
")})));
end IndexReduction25_DerFunc;

model IndexReduction26_DerFunc
function f
  input Real x[2];
  output Real y;
algorithm
  y := x[1]^2 + x[2]^3;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real der_x[2];
  output Real der_y;
algorithm
  der_y := 2*x[1]*der_x[1] + 3*x[2]^2*der_x[2];
end f_der;

  Real x1[2],x2[2];
equation
  der(x1) + der(x2) = {1,2};
  x1[1] + f(x2) = 0;
  x1[2] = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction26_DerFunc",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction26_DerFunc
 Real x1[1];
 Real x1[2];
 Real x2[1];
 Real x2[2];
 Real der_x1_1;
 Real der_x1_2;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 1;
 der_x1_2 + der(x2[2]) = 2;
 x1[1] + TransformCanonicalTests.IndexReduction26_DerFunc.f({x2[1],x2[2]}) = 0;
 x1[2] = 0;
 der_x1_1 + TransformCanonicalTests.IndexReduction26_DerFunc.f_der({x2[1],x2[2]}, {der(x2[1]),der(x2[2])}) = 0.0;
 der_x1_2 = 0.0;

public
 function TransformCanonicalTests.IndexReduction26_DerFunc.f_der
  input Real[2] x;
  input Real[2] der_x;
  output Real der_y;
 algorithm
  der_y := ( ( 2 ) * ( x[1] ) ) * ( der_x[1] ) + ( ( 3 ) * ( x[2] ^ 2 ) ) * ( der_x[2] );
  return;
 end TransformCanonicalTests.IndexReduction26_DerFunc.f_der;

 function TransformCanonicalTests.IndexReduction26_DerFunc.f
  input Real[2] x;
  output Real y;
 algorithm
  y := x[1] ^ 2 + x[2] ^ 3;
  return;
 end TransformCanonicalTests.IndexReduction26_DerFunc.f;

end TransformCanonicalTests.IndexReduction26_DerFunc;
")})));
end IndexReduction26_DerFunc;


model IndexReduction27_DerFunc
function f
  input Real x[2];
  input Real A[2,2];
  output Real y[2];
algorithm
  y := A*x;
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output Real der_y[2];
algorithm
  der_y := A*der_x;
end f_der;
  parameter Real A[2,2] = {{1,2},{3,4}};
  Real x1[2],x2[2](each stateSelect=StateSelect.prefer);
equation
  der(x1) + der(x2) = {2,3};
  x1 + f(x2,A) = {0,0};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction27_DerFunc",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction27_DerFunc
 parameter Real A[1,1] = 1 /* 1 */;
 parameter Real A[1,2] = 2 /* 2 */;
 parameter Real A[2,1] = 3 /* 3 */;
 parameter Real A[2,2] = 4 /* 4 */;
 Real x1[1];
 Real x1[2];
 Real x2[1](stateSelect=StateSelect.prefer);
 Real x2[2](stateSelect=StateSelect.prefer);
 Real der_x1_1;
 Real der_x1_2;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 2;
 der_x1_2 + der(x2[2]) = 3;
 ({ - ( x1[1] ), - ( x1[2] )}) = TransformCanonicalTests.IndexReduction27_DerFunc.f({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}});
 ({ - ( der_x1_1 ), - ( der_x1_2 )}) = TransformCanonicalTests.IndexReduction27_DerFunc.f_der({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}}, {der(x2[1]),der(x2[2])}, {{0.0,0.0},{0.0,0.0}});

public
 function TransformCanonicalTests.IndexReduction27_DerFunc.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output Real[2] der_y;
 algorithm
  der_y[1] := ( A[1,1] ) * ( der_x[1] ) + ( A[1,2] ) * ( der_x[2] );
  der_y[2] := ( A[2,1] ) * ( der_x[1] ) + ( A[2,2] ) * ( der_x[2] );
  return;
 end TransformCanonicalTests.IndexReduction27_DerFunc.f_der;

 function TransformCanonicalTests.IndexReduction27_DerFunc.f
  input Real[2] x;
  input Real[2, 2] A;
  output Real[2] y;
 algorithm
  y[1] := ( A[1,1] ) * ( x[1] ) + ( A[1,2] ) * ( x[2] );
  y[2] := ( A[2,1] ) * ( x[1] ) + ( A[2,2] ) * ( x[2] );
  return;
 end TransformCanonicalTests.IndexReduction27_DerFunc.f;
 
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction27_DerFunc;
")})));
end IndexReduction27_DerFunc;


model IndexReduction28_Record
record R
	Real[2] a;
end R;

function f
  input Real x[2];
  input Real A[2,2];
  output R y;
algorithm
  y := R(A*x);
  annotation(derivative=f_der);
end f;

function f_der
  input Real x[2];
  input Real A[2,2];
  input Real der_x[2];
  input Real der_A[2,2];
  output R der_y;
algorithm
  der_y := R(A*der_x);
end f_der;

  parameter Real A[2,2] = {{1,2},{3,4}};
  R x1(a(stateSelect={StateSelect.prefer,StateSelect.default})),x2(a(stateSelect={StateSelect.prefer,StateSelect.default})),x3;
equation
  der(x1.a) + der(x2.a) = {2,3};
  x1.a + x3.a = {0,0};
  x3 = f(x2.a,A);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction28_Record",
			description="Index reduction: function with record input & output",
			flatModel="
fclass TransformCanonicalTests.IndexReduction28_Record
parameter Real A[1,1] = 1 /* 1 */;
parameter Real A[1,2] = 2 /* 2 */;
parameter Real A[2,1] = 3 /* 3 */;
parameter Real A[2,2] = 4 /* 4 */;
Real x1.a[1](stateSelect = StateSelect.prefer);
Real x1.a[2](stateSelect = StateSelect.default);
Real x2.a[1](stateSelect = StateSelect.prefer);
Real x2.a[2](stateSelect = StateSelect.default);
Real der_x1_a_2;
Real der_x2_a_2;
initial equation 
x1.a[1] = 0.0;
x2.a[1] = 0.0;
equation
x1.der(a[1]) + x2.der(a[1]) = 2;
der_x1_a_2 + der_x2_a_2 = 3;
(TransformCanonicalTests.IndexReduction28_Record.R({ - ( x1.a[1] ), - ( x1.a[2] )})) = TransformCanonicalTests.IndexReduction28_Record.f({x2.a[1],x2.a[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}});
(TransformCanonicalTests.IndexReduction28_Record.R({ - ( x1.der(a[1]) ), - ( der_x1_a_2 )})) = TransformCanonicalTests.IndexReduction28_Record.f_der({x2.a[1],x2.a[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}}, {x2.der(a[1]),der_x2_a_2}, {{0.0,0.0},{0.0,0.0}});

public
 function TransformCanonicalTests.IndexReduction28_Record.f_der
  input Real[2] x;
  input Real[2, 2] A;
  input Real[2] der_x;
  input Real[2, 2] der_A;
  output TransformCanonicalTests.IndexReduction28_Record.R der_y;
 algorithm
  der_y.a[1] := ( A[1,1] ) * ( der_x[1] ) + ( A[1,2] ) * ( der_x[2] );
  der_y.a[2] := ( A[2,1] ) * ( der_x[1] ) + ( A[2,2] ) * ( der_x[2] );
  return;
 end TransformCanonicalTests.IndexReduction28_Record.f_der;

 function TransformCanonicalTests.IndexReduction28_Record.f
  input Real[2] x;
  input Real[2, 2] A;
  output TransformCanonicalTests.IndexReduction28_Record.R y;
 algorithm
  y.a[1] := ( A[1,1] ) * ( x[1] ) + ( A[1,2] ) * ( x[2] );
  y.a[2] := ( A[2,1] ) * ( x[1] ) + ( A[2,2] ) * ( x[2] );
  return;
 end TransformCanonicalTests.IndexReduction28_Record.f;

 record TransformCanonicalTests.IndexReduction28_Record.R
  Real a[2];
 end TransformCanonicalTests.IndexReduction28_Record.R;

 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

 end TransformCanonicalTests.IndexReduction28_Record;
")})));
end IndexReduction28_Record;

model IndexReduction29_FunctionNoDerivative
function der_F
  import SI = Modelica.SIunits;

 input SI.Pressure p;
 input SI.SpecificEnthalpy h;
 input Integer phase=0;
 input Real z;
 input Real der_p;
 input Real der_h;
 output Real der_rho;

algorithm
     der_rho := der_p + der_h;
end der_F;

function F 
  import SI = Modelica.SIunits;

  input SI.Pressure p;
  input SI.SpecificEnthalpy h;
  input Integer phase=0;
  input Real z;
  output SI.Density rho;

algorithm
	rho := p + h;
  annotation(derivative(noDerivative=phase, noDerivative=z)=der_F);
  
end F;

  Real x,y;
equation
  der(x) + der(y) = 0;
  x + F(y,x,0,x) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction29_FunctionNoDerivative",
			description="Index reduction: function with record input & output",
			flatModel="
fclass TransformCanonicalTests.IndexReduction29_FunctionNoDerivative
 Real x;
 Real y;
 Real der_x;
initial equation 
 y = 0.0;
equation
 der_x + der(y) = 0;
 x + TransformCanonicalTests.IndexReduction29_FunctionNoDerivative.F(y, x, 0, x) = 0;
 der_x + TransformCanonicalTests.IndexReduction29_FunctionNoDerivative.der_F(y, x, 0, x, der(y), der_x) = 0.0;

public
 function TransformCanonicalTests.IndexReduction29_FunctionNoDerivative.der_F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  input Real der_p;
  input Real der_h;
  output Real der_rho;
 algorithm
  der_rho := der_p + der_h;
  return;
 end TransformCanonicalTests.IndexReduction29_FunctionNoDerivative.der_F;

 function TransformCanonicalTests.IndexReduction29_FunctionNoDerivative.F
  input Real p;
  input Real h;
  input Integer phase;
  input Real z;
  output Real rho;
 algorithm
  rho := p + h;
  return;
 end TransformCanonicalTests.IndexReduction29_FunctionNoDerivative.F;

end TransformCanonicalTests.IndexReduction29_FunctionNoDerivative;
")})));
end IndexReduction29_FunctionNoDerivative;

  model IndexReduction30_PlanarPendulum_StatePrefer
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction30_PlanarPendulum_StatePrefer",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction30_PlanarPendulum_StatePrefer
parameter Real L = 1 \"Pendulum length\" /* 1 */;
parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
Real y \"Cartesian x coordinate\";
Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
Real lambda \"Lagrange multiplier\";
Real der_y;
Real der_2_x;
Real der_2_y;
initial equation 
x = 0.0;
vx = 0.0;
equation
der(x) = vx;
der(vx) = ( lambda ) * ( x );
der_2_y = ( lambda ) * ( y ) - ( g );
x ^ 2 + y ^ 2 = L;
( ( 2 ) * ( x ) ) * ( der(x) ) + ( ( 2 ) * ( y ) ) * ( der_y ) = 0.0;
( ( 2 ) * ( x ) ) * ( der_2_x ) + ( ( 2 ) * ( der(x) ) ) * ( der(x) ) + ( ( 2 ) * ( y ) ) * ( der_2_y ) + ( ( 2 ) * ( der_y ) ) * ( der_y ) = 0.0;
der_2_x = der(vx);

public
type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction30_PlanarPendulum_StatePrefer; 		 
")})));
  end IndexReduction30_PlanarPendulum_StatePrefer;

model IndexReduction31_PlanarPendulum_StateAlways
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real y "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.always) "Velocity in x coordinate";
    Real vy "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;
	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction31_PlanarPendulum_StateAlways",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction31_PlanarPendulum_StateAlways
parameter Real L = 1 \"Pendulum length\" /* 1 */;
parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
Real x(stateSelect = StateSelect.always) \"Cartesian x coordinate\";
Real y \"Cartesian x coordinate\";
Real vx(stateSelect = StateSelect.always) \"Velocity in x coordinate\";
Real lambda \"Lagrange multiplier\";
Real der_y;
Real der_2_x;
Real der_2_y;
initial equation 
x = 0.0;
vx = 0.0;
equation
der(x) = vx;
der(vx) = ( lambda ) * ( x );
der_2_y = ( lambda ) * ( y ) - ( g );
x ^ 2 + y ^ 2 = L;
( ( 2 ) * ( x ) ) * ( der(x) ) + ( ( 2 ) * ( y ) ) * ( der_y ) = 0.0;
( ( 2 ) * ( x ) ) * ( der_2_x ) + ( ( 2 ) * ( der(x) ) ) * ( der(x) ) + ( ( 2 ) * ( y ) ) * ( der_2_y ) + ( ( 2 ) * ( der_y ) ) * ( der_y ) = 0.0;
der_2_x = der(vx);

public
type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction31_PlanarPendulum_StateAlways;	
")})));
  end IndexReduction31_PlanarPendulum_StateAlways;

  model IndexReduction32_PlanarPendulum_StatePreferAlways
    parameter Real L = 1 "Pendulum length";
    parameter Real g =9.81 "Acceleration due to gravity";
    Real x(stateSelect=StateSelect.prefer) "Cartesian x coordinate";
    Real y(stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real vx(stateSelect=StateSelect.prefer) "Velocity in x coordinate";
    Real vy(stateSelect=StateSelect.always) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";
  equation
    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction32_PlanarPendulum_StatePreferAlways",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction32_PlanarPendulum_StatePreferAlways
parameter Real L = 1 \"Pendulum length\" /* 1 */;
parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
Real x(stateSelect = StateSelect.prefer) \"Cartesian x coordinate\";
Real y(stateSelect = StateSelect.always) \"Cartesian x coordinate\";
Real vx(stateSelect = StateSelect.prefer) \"Velocity in x coordinate\";
Real vy(stateSelect = StateSelect.always) \"Velocity in y coordinate\";
Real lambda \"Lagrange multiplier\";
Real der_2_x;
Real der_2_y;
initial equation 
y = 0.0;
vy = 0.0;
equation
der(y) = vy;
der_2_x = ( lambda ) * ( x );
der(vy) = ( lambda ) * ( y ) - ( g );
x ^ 2 + y ^ 2 = L;
( ( 2 ) * ( x ) ) * ( vx ) + ( ( 2 ) * ( y ) ) * ( der(y) ) = 0.0;
( ( 2 ) * ( x ) ) * ( der_2_x ) + ( ( 2 ) * ( vx ) ) * ( vx ) + ( ( 2 ) * ( y ) ) * ( der_2_y ) + ( ( 2 ) * ( der(y) ) ) * ( der(y) ) = 0.0;
der_2_y = der(vy);

public
 type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");

end TransformCanonicalTests.IndexReduction32_PlanarPendulum_StatePreferAlways;
")})));
  end IndexReduction32_PlanarPendulum_StatePreferAlways;

 model IndexReduction33_Div
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 (x1 + x2)/(x1 + p) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction33_Div",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction33_Div
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 ( x1 + x2 ) / ( x1 + p ) = 0;
 ( ( der_x1 + der(x2) ) * ( x1 + p ) - ( ( x1 + x2 ) * ( der_x1 ) ) ) / ( ( x1 + p ) ^ 2 ) = 0.0;
end TransformCanonicalTests.IndexReduction33_Div;
		 ")})));
  end IndexReduction33_Div;

 model IndexReduction34_Div
  Real x1,x2;
  parameter Real p1 = 2;
  parameter Real p2 = 5;
equation
  der(x1) + der(x2) = 1;
 (x1 + x2)/(p1*p2) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction34_Div",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction34_Div
 Real x1;
 Real x2;
 parameter Real p1 = 2 /* 2 */;
 parameter Real p2 = 5 /* 5 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 ( x1 + x2 ) / ( ( p1 ) * ( p2 ) ) = 0;
 ( der_x1 + der(x2) ) / ( ( p1 ) * ( p2 ) ) = 0.0;
end TransformCanonicalTests.IndexReduction34_Div;
		 ")})));
  end IndexReduction34_Div;

model IndexReduction35_Boolean
    Real x,y;
    Boolean b = false;
equation
    x = if b then 1 else 2 + y;
    der(x) + der(y) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction35_Boolean",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction35_Boolean
 Real x;
 Real y;
 discrete Boolean b;
 Real der_x;
initial equation 
 y = 0.0;
 pre(b) = false;
equation
 x = (if b then 1 else 2 + y);
 der_x + der(y) = 0;
 b = false;
 der_x = (if b then 0.0 else der(y));
end TransformCanonicalTests.IndexReduction35_Boolean;
		 ")})));	
end IndexReduction35_Boolean;

model IndexReduction36_Integer
    Real x,y;
    Integer b = 2;
equation
    x = if b==2 then 1 else 2 + y;
    der(x) + der(y) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction36_Integer",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction36_Integer
 Real x;
 Real y;
 discrete Integer b;
 Real der_x;
initial equation 
 y = 0.0;
 pre(b) = 0;
equation
 x = (if b == 2 then 1 else 2 + y);
 der_x + der(y) = 0;
 b = 2;
 der_x = (if b == 2 then 0.0 else der(y));
end TransformCanonicalTests.IndexReduction36_Integer;
		 ")})));		
end IndexReduction36_Integer;

model IndexReduction37_noEvent
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IndexReduction37_noEvent",
			description="Test of index reduction",
			flatModel="
fclass TransformCanonicalTests.IndexReduction37_noEvent
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 noEvent(x1 + sin(x2)) = 0;
 noEvent(der_x1 + ( cos(x2) ) * ( der(x2) )) = 0.0;
end TransformCanonicalTests.IndexReduction37_noEvent;
")})));
  end IndexReduction37_noEvent;

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
 der(x) =  - ( x );
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
 der(x) =  - ( x );
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
 der(x) =  - ( x );
 der(y) =  - ( y ) + z;
 z + ( 2 ) * ( y ) = 0;
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
 der(x) =  - ( x );
 der(y) =  - ( y ) + z;
 z + ( 2 ) * ( y ) = 0;
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
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
  x - ( y )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
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
  ( x + 3 ) / (  - ( 1.0 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / (  - ( 1.0 ) )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
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
  ( x + 3 ) / ( 2 )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / ( x )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
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
  ( x + 3 ) / ( ( 1.0 ) / ( 2 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / ( ( 1.0 ) / ( x ) )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
"
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
  ( x + 3 ) / ( 1.0 - ( 3 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / ( 1.0 - ( x + 3 ) )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
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
  ( 2 ) / ( y ) = x + 3
-------------------------------
Non-solved block of 1 variables:
Unknown variables:
  z
Equations:
  ( x ) / ( z ) = x - ( y )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
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
  ( x + 3 ) / (  - ( 1.0 ) + 1.0 - ( 4 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / (  - ( 1.0 ) + 1.0 + 5 )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test solution of equations", methodResult=
        "
-------------------------------
Solved block of 1 variables:
Computed variable:
  der(x)
Solution:
  (  - ( x ) ) / (  - ( 1.0 ) - (  - ( 1.0 ) ) + ( (  - ( 1.0 ) ) * (  - ( 1.0 ) ) ) * (  - ( 1.0 ) ) )
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
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 tearing variables and 3 solved variables.
Solved variables:
  u2
  i1
  u1
Tearing variables:
  i3
  i2
Solved equations:
  u2 = ( R3 ) * ( i3 )
  i1 = i2 + i3
  u1 = ( R1 ) * ( i1 )
Residual equations:
  u0 = u1 + u2
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
  end TearingTest1;

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
Torn block of 1 tearing variables and 1 solved variables.
Solved variables:
  r.x
Tearing variables:
  x
Solved equations:
  (TransformCanonicalTests.RecordTearingTest2.R(r.x, r.y)) = TransformCanonicalTests.RecordTearingTest2.F(x, y)
Residual equations:
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
Torn block of 2 tearing variables and 0 solved variables.
Solved variables:
Tearing variables:
  x
  y
Solved equations:
Residual equations:
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
Torn block of 1 tearing variables and 2 solved variables.
Solved variables:
  x
  y
Tearing variables:
  v
Solved equations:
  (x, y) = TransformCanonicalTests.RecordTearingTest4.F(v, v)
Residual equations:
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
Torn block of 3 tearing variables and 3 solved variables.
Solved variables:
  c
  d
  e
Tearing variables:
  f
  a
  b
Solved equations:
  (c, d) = TransformCanonicalTests.RecordTearingTest5.F(a, b)
  (e, f) = TransformCanonicalTests.RecordTearingTest5.F(c, d)
Residual equations:
  (e, f) = TransformCanonicalTests.RecordTearingTest5.F(c, d)
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
  u1 = R1*i1 annotation(__JModelica(residue={"i3"}));
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
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 tearing variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Tearing variables:
  i3
  i2
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
  u1 = ( R1 ) * ( i1 )
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
  u0 = u1 + u3 annotation(__JModelica(residue={"i2"}));
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3 annotation(__JModelica(residue={"i1"}));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing2",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 tearing variables and 2 solved variables.
Solved variables:
  u2
  u1
Tearing variables:
  i2
  i1
  i3
Solved equations:
  u2 = ( R2 ) * ( i2 )
  u1 = ( R1 ) * ( i1 )
Residual equations:
  u0 = u1 + u2
  i1 = i2 + i3
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
  u0 = u1 + u3 annotation(__JModelica(residue={"i2"}));
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3 annotation(__JModelica(residue={"i3"}));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing3",
			methodName="printDAEBLT",
			equation_sorting=true,
			enable_tearing=true,
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 tearing variables and 3 solved variables.
Solved variables:
  u2
  i1
  u1
Tearing variables:
  i2
  i3
Solved equations:
  u2 = ( R2 ) * ( i2 )
  i1 = i2 + i3
  u1 = ( R1 ) * ( i1 )
Residual equations:
  u0 = u1 + u2
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
end HandGuidedTearing3;

model HandGuidedTearing4
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,iL;
  Real i3 annotation(__JModelica(tearVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__JModelica(residue));
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
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 tearing variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Tearing variables:
  i3
  i2
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
  u1 = ( R1 ) * ( i1 )
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
end HandGuidedTearing4;

model HandGuidedTearing5
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  Real i4 annotation(__JModelica(tearVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  i3 = i4;
  u0 = sin(time);
  u1 = R1*i1 annotation(__JModelica(residue));
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
			description="Test of hand guided tearing",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 tearing variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Tearing variables:
  i3
  i2
Solved equations:
  u2 = ( R3 ) * ( i3 )
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
  u1 = ( R1 ) * ( i1 )
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
end HandGuidedTearing5;

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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test of linear systems of equations", methodResult="
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
  x1 - ( x2 ) = ( z ) * ( w )
  x2 = ( w ) * ( z ) + 1 + w
Jacobian:
|1.0, - ( 1.0 ), 1.0|
|1.0, - ( ( 1.0 ) * ( w ) ), - ( 1.0 )|
|0.0, - ( ( w ) * ( 1.0 ) ), 1.0|
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test of linear systems of equations", methodResult="
-------------------------------
Non-solved linear block of 3 variables:
Coefficient variability: Constant
Unknown variables:
  x1
  z
  x2
Equations:
  x1 + x2 = z
  x1 - ( x2 ) = z
  x2 = z + 1
Jacobian:
|1.0, - ( 1.0 ), 1.0|
|1.0, - ( 1.0 ), - ( 1.0 )|
|0.0, - ( 1.0 ), 1.0|
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
			methodName="printDAEBLT",
			equation_sorting=true,
			description="
Test of linear systems of equations", methodResult="
-------------------------------
Non-solved linear block of 3 variables:
Coefficient variability: Parameter
Unknown variables:
  x1
  z
  x2
Equations:
  x1 + x2 = z
  x1 - ( x2 ) = ( z ) * ( p )
  x2 = z + p
Jacobian:
|1.0, - ( 1.0 ), 1.0|
|1.0, - ( ( 1.0 ) * ( p ) ), - ( 1.0 )|
|0.0, - ( 1.0 ), 1.0|
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

end TransformCanonicalTests;
