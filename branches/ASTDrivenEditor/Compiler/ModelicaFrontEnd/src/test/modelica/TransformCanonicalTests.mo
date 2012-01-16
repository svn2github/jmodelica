package TransformCanonicalTests


	model TransformCanonicalTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest1",
        description="Test basic canonical transformations",
                                               flatModel=
"
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

		Real x(start=1,fixed=true);
		Real y(start=3,fixed=true);
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
                y + v = 1;
	end TransformCanonicalTest1;
	
  model TransformCanonicalTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p1;
  	parameter Real p1 = 4;
  end TransformCanonicalTest2;

  model TransformCanonicalTest3_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TransformCanonical3_Err",
                                               description="Test parameter sorting.",
                                               errorMessage=
" 3 errors found...
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 79, column 19:
  Could not evaluate binding expression for parameter 'p4' due to circularity: '( p3 ) * ( p3 )'
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 80, column 19:
  Could not evaluate binding expression for parameter 'p3' due to circularity: 'p2 + p1'
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 81, column 19:
  Could not evaluate binding expression for parameter 'p2' due to circularity: '( p4 ) * ( p1 )'

")})));
    
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p4*p1;
  	parameter Real p1 = 4;
  end TransformCanonicalTest3_Err;

  model TransformCanonicalTest4_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TransformCanonical4_Err",
                                               description="Test parameter sorting.",
                                               errorMessage=
" 3 errors found...
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 103, column 19:
  Could not evaluate binding expression for parameter 'p4' due to circularity: '( p3 ) * ( p3 )'
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 104, column 19:
  Could not evaluate binding expression for parameter 'p3' due to circularity: 'p2 + p1'
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 105, column 19:
  Could not evaluate binding expression for parameter 'p2' due to circularity: '( p1 ) * ( p2 )'

")})));

    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p2;
  	parameter Real p1 = 4;
  end TransformCanonicalTest4_Err;

  model TransformCanonicalTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

    parameter Real p10 = p11*p3;
  	parameter Real p9 = p11*p8;
  	parameter Real p2 = p11;
  	parameter Real p11 = p7*p5;
  	parameter Real p8 = p7*p3;
  	parameter Real p7 = 1;
  	parameter Real p5 = 1;
    parameter Real p3 = 1;
  	
  end TransformCanonicalTest5;


  model TransformCanonicalTest6
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest6",
        description="Built-in functions.",
                                               flatModel=
"
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
  end TransformCanonicalTest6;


  model EvalTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="EvalTest1",
      methodName="variableDiagnostics",
        description="Test evaluation of independent parameters", methodResult=
        "Independent constants: 
        
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


  	
  end EvalTest1;

  model EvalTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="EvalTest2",
      methodName="variableDiagnostics",
        description="Test evaluation of independent parameters", methodResult=
        "Independent constants: 

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


    parameter Real p1 = 1*10^4;
  	
  end EvalTest2;




  model LinearityTest1
  
  	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="LinearityTest1",
      methodName="variableDiagnostics",
        description="Test linearity of variables.", methodResult=
        "  

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
  
  end LinearityTest1;

  model AliasTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest1",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x3,-x4}
{x2,-x5,-x6}
4 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2 = 1;
    Real x3,x4,x5,x6;
  equation
    x1 = -x3;
    -x1 = x4;
    x2 = -x5;
    x5 = x6;  
   
  end AliasTest1;

  model AliasTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest2",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,x2,x3,x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    x3 = x4;
    x1 = x3;

  end AliasTest2;

  model AliasTest3
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest3",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,x2,-x3,-x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    x3 = x4;
    x1 = -x3;

  end AliasTest3;

  model AliasTest4
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest4",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,x3,x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    x3 = x4;
    x1 = x3;

  end AliasTest4;

  model AliasTest5
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest5",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,-x3,-x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    x3 = x4;
    x1 = -x3;

  end AliasTest5;

  model AliasTest6
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest6",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,x2,x3,-x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    -x3 = x4;
    x1 = x3;

  end AliasTest6;

  model AliasTest7
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest7",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,x2,-x3,x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    x1 = x2;
    -x3 = x4;
    x1 = -x3;

  end AliasTest7;

  model AliasTest8
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest8",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,x3,-x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    -x3 = x4;
    x1 = x3;

  end AliasTest8;

  model AliasTest9
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest9",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,-x3,x4}
3 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3,x4;
  equation
    -x1 = x2;
    -x3 = x4;
    x1 = -x3;

  end AliasTest9;

  model AliasTest10
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest10",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,x2,x3}
2 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x3 = x1;

  end AliasTest10;

  model AliasTest11
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest11",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,x2,-x3}
2 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x3 = -x1;

  end AliasTest11;

  model AliasTest12
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest12",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,x3}
2 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = -x2;
    x3 = x1;

  end AliasTest12;

  model AliasTest13
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest13",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,-x3}
2 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = -x2;
    x3 = -x1;

  end AliasTest13;

  model AliasTest14
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest14",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,x3}
2 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x3 = x1;

  end AliasTest14;

  model AliasTest15
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest15",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2,-x3}
2 variables can be eliminated
")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x3 = -x1;

  end AliasTest15;

  model AliasTest16_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AliasTest16_Err",
                                               description="Test alias error.",
                                               errorMessage=
" 1 error found...
Semantic error at line 0, column 0:
  Alias error: trying to add the negated alias pair (x3,-x1) to the alias set {x1,x2,x3}

")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x2 = x3;
    x3=-x1;

  end AliasTest16_Err;

  model AliasTest17_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AliasTest17_Err",
                                               description="Test alias error.",
                                               errorMessage=
" 
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  Alias error: trying to add the alias pair (x3,x1) to the alias set {x1,x2,-x3}

")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    x1 = x2;
    x2 = -x3;
    x3=x1;

  end AliasTest17_Err;

  model AliasTest18_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AliasTest18_Err",
                                               description="Test alias error.",
                                               errorMessage=
" 
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  Alias error: trying to add the alias pair (x3,x1) to the alias set {x1,-x2,-x3}

")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = x3;
    x3=x1;

  end AliasTest18_Err;

  model AliasTest19_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AliasTest19_Err",
                                               description="Test alias error.",
                                               errorMessage=
" 
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  Alias error: trying to add the negated alias pair (x3,-x1) to the alias set {x1,-x2,x3}

")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = -x3;
    x3=-x1;

  end AliasTest19_Err;

  model AliasTest20
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest20",
        description="Test elimination of alias variables",
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest20
 Real x1;
equation 
 x1 = 1;
end TransformCanonicalTests.AliasTest20;

")})));

    Real x1 = 1;
    Real x2,x3;
  equation
    -x1 = x2;
    x2 = -x3;
  end AliasTest20;

  model AliasTest21
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="AliasTest21",
      methodName="aliasDiagnostics",
        description="Test computation of alias sets.", methodResult=
        "Alias sets:
{x1,-x2}
1 variables can be eliminated
")})));

    Real x1,x2,x3;
  equation
    0 = x1 + x2;
    x1 = 1;   
    x3 = x2^2;
  end AliasTest21;

  model AliasTest22
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest22",
        description="Test elimination of alias variables",
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest22
 Real x1;
 Real x3;
equation 
 x1 = 1;
 x3 = (  - ( x1 ) ) ^ 2;
end TransformCanonicalTests.AliasTest22;
")})));

    Real x1,x2,x3;
  equation
    0 = x1 + x2;
    x1 = 1;   
    x3 = x2^2;
  end AliasTest22;


  model AliasTest23
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest23",
        description="Test elimination of alias variables",
        automatic_add_initial_equations = false,
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest23
 Real x1;
equation 
  - ( der(x1) ) = 0;
end TransformCanonicalTests.AliasTest23;
")})));

    Real x1,x2;
  equation
    x1 = -x2;
    der(x2) = 0;
  end AliasTest23;

  model AliasTest24
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest24",
        description="Test elimination of alias variables",
        automatic_add_initial_equations = false,
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest24
 Real x1;
 input Real u;
equation 
 der(x1) = u;
end TransformCanonicalTests.AliasTest24;
")})));

    Real x1,x2;
    input Real u;
  equation
    x2 = u;
    der(x1) = u;
end AliasTest24;


  model AliasTest25
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest25",
        description="Test elimination of alias variables",
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest25
 Real x2(fixed = true);
initial equation 
 x2 = 0.0;
equation 
 der(x2) = 1;
end TransformCanonicalTests.AliasTest25;
")})));

    Real x1(fixed=false);
    Real x2(fixed =true);
    Real x3;
  equation
    der(x3) = 1;
    x1 = x3;
    x2 = x1;	
end AliasTest25;

model AliasTest26
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest26",
        description="Test elimination of alias variables",
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest26
 parameter Real p = 1 /* 1.0 */;
 Real y;
equation
 y = p + 3;
end TransformCanonicalTests.AliasTest26;
")})));

 parameter Real p = 1;
 Real x,y;
equation
 x = p;
 y = x+3;
end AliasTest26;

model AliasTest27
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest27",
        description="Test elimination of alias variables.",
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest27
 Real x1;
equation
 x1 = 1;
end TransformCanonicalTests.AliasTest27;
")})));

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

end AliasTest27;

model AliasTest28
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="AliasTest28",
        description="Test elimination of alias variables.",
                                               flatModel=
"
fclass TransformCanonicalTests.AliasTest28
 Real y;
 parameter Real p = 1 /* 1.0 */;
equation
 y =  - ( p ) + 1;
end TransformCanonicalTests.AliasTest28;
")})));

 Real x,y;
 parameter Real p = 1;
equation
 x = -p;
 y = x + 1;
end AliasTest28;

model AliasTest29
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
end AliasTest29;



model ParameterBindingExpTest1_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ParameterBindingExpTest1_Err",
                                               description="Test error in dependent parameter binding expression.",
                                               errorMessage=
" 1 error found...
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 650, column 17:
  Could not evaluate binding expression for parameter 'p': 'x'

")})));

	Real x = 2;
	parameter Real p = x;
end ParameterBindingExpTest1_Err;

model ParameterBindingExpTest2_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ParameterBindingExpTest2_Err",
                                               description="Test error in dependent parameter binding expression.",
                                               errorMessage=
" 2 errors found...
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 654, column 17:
  Could not evaluate binding expression for parameter 'p': 'x'
Error: in file '/work/jakesson/svn_projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 654, column 21:
  Cannot find class or component declaration for x

")})));
	parameter Real p = x;
end ParameterBindingExpTest2_Err;


model ParameterBindingExpTest3_Warn

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.WarningTestCase(name="ParameterBindingExpTest3_Warn",
        description="Test errors in binding expressions.",
                                               errorMessage=
"
Warning: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ConstantEvalTests.mo':
At line 110, column 18:
  The parameter p does not have a binding expression.
")})));

  parameter Real p;
end ParameterBindingExpTest3_Warn;

model ParameterBindingExpTest4_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ParameterBindingExpTest4_Err",
        description="Test errors in binding expressions.",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 712, column 18:
  Could not evaluate binding expression for parameter 'p3': 'p1 + p2'
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 712, column 21:
  Type error in expression: p1 + p2
")})));

  parameter Boolean p1=true;
  parameter Real p2 = 3;
  parameter Real p3=p1+p2;
end ParameterBindingExpTest4_Err;

model ParameterBindingExpTest5_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ParameterBindingExpTest5_Err",
        description="Test errors in binding expressions.",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 736, column 18:
  Could not evaluate binding expression for parameter 'p2': 'p1 + 2'
")})));

  Real p1;
  parameter Real p2=p1+2;
end ParameterBindingExpTest5_Err;

model AttributeBindingExpTest1_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AttributeBindingExpTest1_Err",
        description="Test errors in binding expressions.",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 756, column 8:
  Could not evaluate binding expression for attribute 'start': 'p1'
")})));


  Real p1;
  Real x(start=p1);
equation
  der(x) = -x;
end AttributeBindingExpTest1_Err;

model AttributeBindingExpTest2_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AttributeBindingExpTest2_Err",
        description="Test errors in binding expressions..",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 775, column 8:
  Could not evaluate binding expression for attribute 'start': 'p1 + 2'

")})));


  Real p1;
  Real x(start=p1+2);
equation
  der(x) = -x;
end AttributeBindingExpTest2_Err;

model AttributeBindingExpTest3_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AttributeBindingExpTest3_Err",
        description="Test errors in binding expressions..",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 795, column 8:
  Could not evaluate binding expression for attribute 'start': 'p1 + 2 + p'
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 795, column 21:
  Cannot find class or component declaration for p
")})));

  Real p1;
  Real x(start=p1+2+p);
equation
  der(x) = -x;
end AttributeBindingExpTest3_Err;

model AttributeBindingExpTest4_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AttributeBindingExpTest4_Err",
        description="Test errors in binding expressions..",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 815, column 18:
  Could not evaluate binding expression for parameter 'p1' due to circularity: 'p2'
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 816, column 18:
  Could not evaluate binding expression for parameter 'p2' due to circularity: 'p1'
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 818, column 8:
  Could not evaluate binding expression for attribute 'start' due to circularity: 'p1'
")})));

  parameter Real p1 = p2;
  parameter Real p2 = p1;

  Real x(start=p1);
equation
  der(x) = -x;
end AttributeBindingExpTest4_Err;

model AttributeBindingExpTest5_Err

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="AttributeBindingExpTest5_Err",
        description="Test errors in binding expressions..",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 843, column 10:
  Could not evaluate binding expression for attribute 'start': 'p1'
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 843, column 10:
  Could not evaluate binding expression for attribute 'start': 'p2'
")})));

  model A
    Real p1;
    Real x(start=p1) = 2;
  end A;

  Real p2;	
  A a(x(start=p2));
end AttributeBindingExpTest5_Err;

model IncidenceTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="IncidenceTest1",
      methodName="incidence",
        description="Test computation of incidence information", methodResult=
        "Incidence:
 eq 0: der(x) 
 eq 1: y 
")})));


 Real x(start=1);
 Real y;
 input Real u;
equation
 der(x) = -x + u;
 y = x^2;
end IncidenceTest1;


model IncidenceTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="IncidenceTest2",
      methodName="incidence",
        description="Test computation of incidence information", methodResult=
        "Incidence:
 eq 0: der(x) z 
 eq 1: y 
 eq 2: z 
")})));

 Real x(start=1);
 Real y,z;
 input Real u;
equation
 z+der(x) = -sin(x) + u;
 y = x^2;
 z = 4;
end IncidenceTest2;

model IncidenceTest3
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="IncidenceTest3",
      methodName="incidence",
        description="Test computation of incidence information", methodResult=
        "Incidence:
 eq 0: der(x[1]) 
 eq 1: der(x[2]) 
 eq 2: y 
")})));


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
end IncidenceTest3;

model DiffsAndDersTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="DiffsAndDersTest1",
      methodName="dersAndDiffs",
        description="Test that derivatives and differentiated variables can be cross referenced", methodResult=
        "Derivatives and differentiated variables:
 der(x[1]), x[1]
 der(x[2]), x[2]
Differentiated variables and derivatives:
 x[1], der(x[1])
 x[2], der(x[2])
")})));


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
end DiffsAndDersTest1;

  model InitialEqTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

    Real x1(start=1);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
  end InitialEqTest1;

  model InitialEqTest2

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
  end InitialEqTest2;

  model InitialEqTest3

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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

    Real x1(start=1,fixed=true);
    Real x2(start=2);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
  end InitialEqTest3;

  model InitialEqTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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
    Real x1(start=1,fixed=true);
    Real x2(start=2,fixed=true);
    Real y1;
    Real y2;
  equation
    der(x1) = x1 + x2 + y1;
    der(x2) = x1 - x2 + y2;
    y1 = 3*x1;
    y2 = 4*x2;
  end InitialEqTest4;

  model InitialEqTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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
  end InitialEqTest5;

  model InitialEqTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
         name="InitialEqTest7",
         description="Test algorithm for adding additional initial equations.",
         flatModel="
fclass TransformCanonicalTests.InitialEqTest7
 Real x;
 Real y;
equation
 (x, y) = TransformCanonicalTests.f1(1, 2);

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

    Real x, y;
  equation
    (x,y) = f1(1,2);
  end InitialEqTest7;

  model InitialEqTest8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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

    Real x, y;
  equation
    der(x) = -x;
    der(y) = -y;
  initial equation
    (x,y) = f1(1,2);
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
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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

    Real x[3], y[4];
  equation
    (x,y) = f2(ones(3),ones(4));
  end InitialEqTest9;

  model InitialEqTest10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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

    Real x[3], y[4];
  initial equation
    (x,y) = f2(ones(3),ones(4));
  equation
    der(x) = -x;
    der(y) = -y;
  end InitialEqTest10;

  model InitialEqTest11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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

    Real x[3], y[4];
  initial equation
    (x,) = f2(ones(3),ones(4));
  equation
    der(x) = -x;
    (,y) = f2(ones(3),ones(4));
  end InitialEqTest11;

  model InitialEqTest12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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
    Real x[3](each start=3), y[4];
  equation
    der(x) = -x;
    (,y) = f2(ones(3),ones(4));
  end InitialEqTest12;

  model InitialEqTest13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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
    Real x1 (start=1);
    Real x2 (start=2);
  equation
    der(x1) = -x1;
    der(x2) = x1;
  end InitialEqTest13;

  model InitialEqTest14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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
  end InitialEqTest14;

/*
  model InitialEqTest15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
         name="InitialEqTest15",
         description="Test algorithm for adding additional initial equations.",
         flatModel="
")})));
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
  end InitialEqTest15;
*/

model ParameterDerivativeTest
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={ 
    JModelica.UnitTesting.TransformCanonicalTestCase(
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

 Real x(start=1);
 Real y;
 parameter Real p = 2;
equation
 y = der(x) + der(p);
 x = p;
end ParameterDerivativeTest;

model UnbalancedTest1_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="UnbalancedTest1_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"
Error: in file 'TransformCanonicalTests.UnbalancedTest1_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 1 equations and 3 free variables.

Error: in file 'TransformCanonicalTests.UnbalancedTest1_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
   y
   z
")})));

  Real x = 1;
  Real y;
  Real z;
end UnbalancedTest1_Err;

model UnbalancedTest2_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="UnbalancedTest2_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"
Error: in file 'TransformCanonicalTests.UnbalancedTest2_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
   y

  The follwowing equation(s) could not be matched to any variable:
   x = 1 + 2
")})));

  Real x;
  Real y;
equation
  x = 1;
  x = 1+2;
end UnbalancedTest2_Err;

model UnbalancedTest3_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="UnbalancedTest3_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"
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

  Real x;
equation
  x = 4;
  x = 5;
end UnbalancedTest3_Err;

model UnbalancedTest4_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="UnbalancedTest4_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file 'TransformCanonicalTests.UnbalancedTest4_Err.mof':
Semantic error at line 0, column 0:
  The DAE system has 0 equations and 1 free variables.

Error: in file 'TransformCanonicalTests.UnbalancedTest4_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
   x
")})));

  Real x;
equation
end UnbalancedTest4_Err;

model WhenEqu15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="WhenEqu15",
         description="Basic test of when equations",
         equation_sorting = true,
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
end WhenEqu15;

model WhenEqu1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu1",
         description="Basic test of when equations",
         equation_sorting = true,
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
end WhenEqu1;

model WhenEqu2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu2",
         description="Basic test of when equations",
         equation_sorting = true,
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
end WhenEqu2;

model WhenEqu3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu3",
         description="Basic test of when equations",
         equation_sorting = true,
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
end WhenEqu3;

model WhenEqu4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu4",
         description="Basic test of when equations",
         equation_sorting = true, 
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
end WhenEqu4;

/*
model WhenEqu5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu5",
         description="Basic test of when equations",
         equation_sorting = true,         
         flatModel="
fclass TransformCanonicalTests.WhenEqu5
 discrete TransformCanonicalTests.WhenEqu5.E e(start = TransformCanonicalTests.WhenEqu5.E.b);
 Real t(start = 0);
initial equation 
 t = 0;
equation
 der(t) = 1;
 when time > 1 then
  e = TransformCanonicalTests.WhenEqu5.E.c;
 end when;

 type TransformCanonicalTests.WhenEqu5.E = enumeration(a, b, c);
end TransformCanonicalTests.WhenEqu5;
")})));
  type E = enumeration(a,b,c);
  discrete E e (start=E.b);
  Real t(start=0);
equation
  der(t) = 1;
  when time>1 then
    e = E.c;
  end when;

end WhenEqu5;
*/

model WhenEqu5 

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
end WhenEqu5; 

model WhenEqu7 

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

 discrete Real x(start=0);
 Real dummy;
equation
 der(dummy) = 0;
 when dummy>-1 then
   x = pre(x) + 1;
 end when;

end WhenEqu7; 

model WhenEqu8 

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

end WhenEqu8; 

model WhenEqu9 

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
end WhenEqu9; 

model WhenEqu10

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu10",
         description="Basic test of when equations",
         flatModel="
fclass TransformCanonicalTests.WhenEqu10
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
end WhenEqu10;

model WhenEqu11

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
end WhenEqu11;

/* // TODO: add these test when more support is implemented in the middle end
model IfEqu1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
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

	Real x[3];
equation
	if true then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;
end IfEqu1;


model IfEqu2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

	Real x[3];
equation
	if true then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;
end IfEqu2;


model IfEqu3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

	Real x[3];
equation
	if false then
		x = 1:3;
	elseif true then
		x = 4:6;
	else
		x = 7:9;
	end if;
end IfEqu3;


model IfEqu4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

	Real x[3];
equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	else
		x = 7:9;
	end if;
end IfEqu4;


model IfEqu5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

	Real x[3] = 7:9;
equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	end if;
end IfEqu5;


model IfEqu6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEqu6",
         description="If equations: scalarization without elimination",
         flatModel="
fclass TransformCanonicalTests.IfEqu6
 Real x[1];
 Real x[2];
 Real x[3];
 Boolean y[1];
 Boolean y[2];
equation
 if y[1] then
  x[1] = 1;
  x[2] = 2;
  x[3] = 3;
 elseif y[2] then
  x[1] = 4;
  x[2] = 5;
  x[3] = 6;
 else
  x[1] = 7;
  x[2] = 8;
  x[3] = 9;
 end if;
 x[1] = 0;
 x[2] = 0;
 x[3] = 0;
 y[1] = false;
 y[2] = true;
end TransformCanonicalTests.IfEqu6;
")})));

	Real x[3] = zeros(3);
	Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	else
		x = 7:9;
	end if;
end IfEqu6;


model IfEqu7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEqu7",
         description="If equations: scalarization without elimination",
         flatModel="
fclass TransformCanonicalTests.IfEqu7
 Real x[1];
 Real x[2];
 Real x[3];
 Boolean y[1];
 Boolean y[2];
equation
 if y[1] then
  x[1] = 1;
  x[2] = 2;
  x[3] = 3;
 elseif y[2] then
  x[1] = 4;
  x[2] = 5;
  x[3] = 6;
 end if;
 x[1] = 0;
 x[2] = 0;
 x[3] = 0;
 y[1] = false;
 y[2] = true;
end TransformCanonicalTests.IfEqu7;
")})));

	Real x[3]= zeros(3);
	Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	end if;
end IfEqu7;


model IfEqu8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEqu8",
         description="If equations: branch elimination with parameter test expressions",
         flatModel="
fclass TransformCanonicalTests.IfEqu8
 Real x[1];
 Real x[2];
 Real x[3];
 parameter Boolean y[1] = false ;
 parameter Boolean y[2] = true ;
equation
 x[1] = 4;
 x[2] = 5;
 x[3] = 6;
end TransformCanonicalTests.IfEqu8;
")})));

	Real x[3];
	parameter Boolean y[2] = { false, true };
equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		x = 4:6;
	else
		x = 7:9;
	end if;
end IfEqu8;


model IfEqu9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEqu9",
         description="If equations: branch elimination with one test non-parameter",
         flatModel="
fclass TransformCanonicalTests.IfEqu9
 Real x[1];
 Real x[2];
 Boolean y;
equation
 if y then
  x[1] = 3;
  x[2] = 4;
 else
  x[1] = 7;
  x[2] = 8;
 end if;
 x[1] = 0;
 x[2] = 0;
 y = true;
end TransformCanonicalTests.IfEqu9;
")})));

	Real x[2] = zeros(2);
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
end IfEqu9;


model IfEqu10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEqu10",
         description="If equations: branch elimination with one test non-parameter",
         flatModel="
fclass TransformCanonicalTests.IfEqu10
 Real x[1];
 Real x[2];
 Boolean y;
equation
 if y then
  x[1] = 3;
  x[2] = 4;
 else
  x[1] = 5;
  x[2] = 6;
 end if;
 x[1] = 0;
 x[2] = 0;
 y = true;
end TransformCanonicalTests.IfEqu10;
")})));

	Real x[2] = zeros(2);
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
end IfEqu10;


model IfEqu11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEqu11",
         description="If equations: branch elimination with one test non-parameter",
         flatModel="
fclass TransformCanonicalTests.IfEqu11
 Real x[1];
 Real x[2];
 Boolean y;
equation
 x[1] = 1;
 x[2] = 2;
 y = true;
end TransformCanonicalTests.IfEqu11;
")})));

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
end IfEqu11;

*/


model IfExpLeft1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfExpLeft1",
         description="If expression as left side of equation",
         flatModel="
fclass TransformCanonicalTests.IfExpLeft1
 Real x;
equation
 (if time >= 1 then 1 else 0) = x;
end TransformCanonicalTests.IfExpLeft1;
")})));

	Real x;
equation
	if time>=1 then 1 else 0 = x;
end IfExpLeft1;



model WhenVariability1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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

	Real x(start=1);
equation
	when time > 2 then
		x = 2;
	end when;
end WhenVariability1;

  model IndexReduction1_PlanarPendulum
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IndexReduction1_PlanarPendulum",
         description="Test of index reduction",
         flatModel="
fclass TransformCanonicalTests.IndexReduction1_PlanarPendulum
parameter Real L = 1 \"Pendulum length\" /* 1 */;
parameter Real g = 9.81 \"Acceleration due to gravity\" /* 9.81 */;
Real x \"Cartesian x coordinate\";
Real y \"Cartesian x coordinate\";
Real vy \"Velocity in y coordinate\";
Real lambda \"Lagrange multiplier\";
Real der_x;
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
( ( 2 ) * ( x ) ) * ( der_x ) + ( ( 2 ) * ( y ) ) * ( der(y) ) = 0;
( ( 2 ) * ( x ) ) * ( der_2_x ) + ( ( 2 ) * ( der_x ) + ( 0 ) * ( x ) ) * ( der_x ) + ( ( 2 ) * ( y ) ) * ( der_2_y ) + ( ( 2 ) * ( der(y) ) + ( 0 ) * ( y ) ) * ( der(y) ) = 0;
der_2_y = der(vy);
end TransformCanonicalTests.IndexReduction1_PlanarPendulum;
")})));

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
  end IndexReduction1_PlanarPendulum;

  model IndexReduction2_Mechanical
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IndexReduction2_Mechanical",
         description="Test of index reduction",
         flatModel="
fclass TransformCanonicalTests.IndexReduction2_Mechanical
parameter Real amplitude(final quantity = \"Torque\",final unit = \"N.m\") = 10 \"Amplitude of driving torque\" /* 10 */;
parameter Real freqHz(final quantity = \"Frequency\",final unit = \"Hz\") = 5 \"Frequency of driving torque\" /* 5 */;
parameter Real Jmotor(min = 0,final quantity = \"MomentOfInertia\",final unit = \"kg.m2\") = 0.1 \"Motor inertia\" /* 0.1 */;
parameter Real Jload(min = 0,final quantity = \"MomentOfInertia\",final unit = \"kg.m2\") = 2 \"Load inertia\" /* 2 */;
parameter Real ratio = 10 \"Gear ratio\" /* 10 */;
parameter Real damping = 10 \"Damping in bearing of gear\" /* 10 */;
parameter Real fixed.phi0(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") = 0 \"Fixed offset angle of housing\" /* 0 */;
Real fixed.flange.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
parameter Boolean torque.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
Real torque.flange.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
parameter Real inertia1.J(min = 0,start = 1,final quantity = \"MomentOfInertia\",final unit = \"kg.m2\") \"Moment of inertia\";
parameter StateSelect inertia1.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
Real inertia1.phi(stateSelect = inertia1.stateSelect,final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Absolute rotation angle of component\";
Real inertia1.w(stateSelect = inertia1.stateSelect,final quantity = \"AngularVelocity\",final unit = \"rad/s\") \"Absolute angular velocity of component (= der(phi))\";
Real inertia1.a(final quantity = \"AngularAcceleration\",final unit = \"rad/s2\") \"Absolute angular acceleration of component (= der(w))\";
parameter Real idealGear.ratio(start = 1) \"Transmission ratio (flange_a.phi/flange_b.phi)\";
Real idealGear.phi_a(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Angle between left shaft flange and support\";
Real idealGear.phi_b(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Angle between right shaft flange and support\";
parameter Boolean idealGear.useSupport = true \"= true, if support flange enabled, otherwise implicitly grounded\" /* true */;
Real idealGear.flange_a.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
Real idealGear.flange_b.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
Real idealGear.support.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Reaction torque in the support/housing\";
Real inertia2.flange_b.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
parameter Real inertia2.J(min = 0,start = 1,final quantity = \"MomentOfInertia\",final unit = \"kg.m2\") = 2 \"Moment of inertia\" /* 2 */;
parameter StateSelect inertia2.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
Real inertia2.phi(fixed = true,start = 0,stateSelect = inertia2.stateSelect,final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Absolute rotation angle of component\";
Real inertia2.w(fixed = true,stateSelect = inertia2.stateSelect,final quantity = \"AngularVelocity\",final unit = \"rad/s\") \"Absolute angular velocity of component (= der(phi))\";
Real inertia2.a(final quantity = \"AngularAcceleration\",final unit = \"rad/s2\") \"Absolute angular acceleration of component (= der(w))\";
parameter Real spring.c(final min = 0,start = 1.0e5,final quantity = \"RotationalSpringConstant\",final unit = \"N.m/rad\") = 1.e4 \"Spring constant\" /* 10000.0 */;
parameter Real spring.phi_rel0(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") = 0 \"Unstretched spring angle\" /* 0 */;
Real spring.phi_rel(fixed = true,start = 0,final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
Real spring.flange_b.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
Real inertia3.flange_b.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
parameter Real inertia3.J(min = 0,start = 1,final quantity = \"MomentOfInertia\",final unit = \"kg.m2\") \"Moment of inertia\";
parameter StateSelect inertia3.stateSelect = StateSelect.default \"Priority to use phi and w as states\" /* StateSelect.default */;
Real inertia3.phi(stateSelect = inertia3.stateSelect,final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Absolute rotation angle of component\";
Real inertia3.w(fixed = true,stateSelect = inertia3.stateSelect,final quantity = \"AngularVelocity\",final unit = \"rad/s\") \"Absolute angular velocity of component (= der(phi))\";
Real inertia3.a(final quantity = \"AngularAcceleration\",final unit = \"rad/s2\") \"Absolute angular acceleration of component (= der(w))\";
parameter Real damper.d(final min = 0,start = 0,final quantity = \"RotationalDampingConstant\",final unit = \"N.m.s/rad\") \"Damping constant\";
Real damper.phi_rel(stateSelect = StateSelect.always,start = 0,nominal = damper.phi_nominal,final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") \"Relative rotation angle (= flange_b.phi - flange_a.phi)\";
Real damper.w_rel(stateSelect = StateSelect.always,start = 0,final quantity = \"AngularVelocity\",final unit = \"rad/s\") \"Relative angular velocity (= der(phi_rel))\";
Real damper.a_rel(start = 0,final quantity = \"AngularAcceleration\",final unit = \"rad/s2\") \"Relative angular acceleration (= der(w_rel))\";
Real damper.flange_b.tau(final quantity = \"Torque\",final unit = \"N.m\") \"Cut torque in the flange\";
parameter Real damper.phi_nominal(displayUnit = \"rad\",final quantity = \"Angle\",final unit = \"rad\") = 1e-4 \"Nominal value of phi_rel (used for scaling)\" /* 1.0E-4 */;
parameter StateSelect damper.stateSelect = StateSelect.prefer \"Priority to use phi_rel and w_rel as states\" /* StateSelect.prefer */;
parameter Real sine.amplitude \"Amplitude of sine wave\";
parameter Real sine.freqHz(start = 1,final quantity = \"Frequency\",final unit = \"Hz\") \"Frequency of sine wave\";
parameter Real sine.phase(final quantity = \"Angle\",final unit = \"rad\",displayUnit = \"deg\") = 0 \"Phase of sine wave\" /* 0 */;
parameter Real sine.offset = 0 \"Offset of output signal\" /* 0 */;
parameter Real sine.startTime(final quantity = \"Time\",final unit = \"s\") = 0 \"Output = offset for time < startTime\" /* 0 */;
constant Real sine.pi = 3.141592653589793;
Real der_idealGear_phi_a;
Real der_idealGear_phi_b;
Real der_2_idealGear_phi_a;
Real der_2_idealGear_phi_b;
Real der_2_damper_phi_rel;
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
( inertia1.J ) * ( inertia1.a ) = - ( torque.flange.tau ) - ( idealGear.flange_a.tau );
idealGear.phi_a = inertia1.phi - ( fixed.phi0 );
idealGear.phi_b = inertia2.phi - ( fixed.phi0 );
idealGear.phi_a = ( idealGear.ratio ) * ( idealGear.phi_b );
0 = ( idealGear.ratio ) * ( idealGear.flange_a.tau ) + idealGear.flange_b.tau;
( inertia2.J ) * ( inertia2.a ) = - ( idealGear.flange_b.tau ) + inertia2.flange_b.tau;
spring.flange_b.tau = ( spring.c ) * ( spring.phi_rel - ( spring.phi_rel0 ) );
spring.phi_rel = inertia3.phi - ( inertia2.phi );
inertia3.w = inertia3.der(phi);
inertia3.a = inertia3.der(w);
( inertia3.J ) * ( inertia3.a ) = - ( spring.flange_b.tau ) + inertia3.flange_b.tau;
damper.flange_b.tau = ( damper.d ) * ( damper.w_rel );
damper.phi_rel = fixed.phi0 - ( inertia2.phi );
damper.w_rel = damper.der(phi_rel);
damper.a_rel = damper.der(w_rel);
- ( torque.flange.tau ) = sine.offset + (if time < sine.startTime then 0 else ( sine.amplitude ) * ( sin(( ( ( 2 ) * ( 3.141592653589793 ) ) * ( sine.freqHz ) ) * ( time - ( sine.startTime ) ) + sine.phase) ));
- ( damper.flange_b.tau ) + inertia2.flange_b.tau - ( spring.flange_b.tau ) = 0;
damper.flange_b.tau + fixed.flange.tau + idealGear.support.tau - ( torque.flange.tau ) = 0;
inertia3.flange_b.tau = 0;
idealGear.support.tau = - ( idealGear.flange_a.tau ) - ( idealGear.flange_b.tau );
der_idealGear_phi_a = ( idealGear.ratio ) * ( der_idealGear_phi_b ) + ( 0 ) * ( idealGear.phi_b );
der_idealGear_phi_a = inertia1.w - ( 0 );
der_idealGear_phi_b = inertia2.w - ( 0 );
der_2_idealGear_phi_a = ( idealGear.ratio ) * ( der_2_idealGear_phi_b ) + ( 0 ) * ( der_idealGear_phi_b ) + ( 0 ) * ( der_idealGear_phi_b ) + ( 0 ) * ( idealGear.phi_b );
der_2_idealGear_phi_a = inertia1.a - ( 0 );
der_2_idealGear_phi_b = inertia2.a - ( 0 );
damper.der(phi_rel) = 0 - ( inertia2.w );
der_2_damper_phi_rel = 0 - ( inertia2.a );
damper.der(w_rel) = der_2_damper_phi_rel;

type StateSelect = enumeration(never \"Do not use as state at all.\", avoid \"Use as state, if it cannot be avoided (but only if variable appears differentiated and no other potential state with attribute default, prefer, or always can be selected).\", default \"Use as state if appropriate, but only if variable appears differentiated.\", prefer \"Prefer it as state over those having the default value (also variables can be selected, which do not appear differentiated). \", always \"Do use it as a state.\");
end TransformCanonicalTests.IndexReduction2_Mechanical;
")})));

    extends Modelica.Mechanics.Rotational.Examples.First(freqHz=5,amplitude=10,
    damper(phi_rel(stateSelect=StateSelect.always),w_rel(stateSelect=StateSelect.always)));

  end IndexReduction2_Mechanical;

  model IndexReduction3_Electrical
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
der_u1 = ( R[1] ) * ( der_i1 ) + ( 0 ) * ( i1 );
der_i1 = der_i2 + der(iL);
der_uL = ( R[2] ) * ( der_i2 ) + ( 0 ) * ( i2 );
der_u0 = der_u1 + der_uL;
der_u0 = ( 220 ) * ( ( cos(( time ) * ( omega )) ) * ( ( time ) * ( 0 ) + ( 1 ) * ( omega ) ) ) + ( 0 ) * ( sin(( time ) * ( omega )) );
end TransformCanonicalTests.IndexReduction3_Electrical;
")})));
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
  end IndexReduction3_Electrical;

model IndexReduction4_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="IndexReduction4_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"
2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc8802960033354722744out/sources/TransformCanonicalTests.IndexReduction4_Err.mof':
Semantic error at line 0, column 0:
  Cannot differentate the equation 
   TransformCanonicalTests.IndexReduction4_Err.F(x2)
  since the function TransformCanonicalTests.IndexReduction4_Err.F does not have a derivative annotation.

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc8802960033354722744out/sources/TransformCanonicalTests.IndexReduction4_Err.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following varible(s) could not be matched to any equation:
   der(x2)

  The follwowing equation(s) could not be matched to any variable:
   x1 + TransformCanonicalTests.IndexReduction4_Err.F(x2) = 1
")})));

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
end IndexReduction4_Err;

model IndexReduction5_Err
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="IndexReduction5_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"
3 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file 'TransformCanonicalTests.IndexReduction5_Err.mof':
Semantic error at line 0, column 0:
  Cannot differentate the equation 
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
end IndexReduction5_Err;

  model IndexReduction6_Cos
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 - ( ( sin(x2) ) * ( der(x2) ) ) = 0;
end TransformCanonicalTests.IndexReduction6_Cos;
")})));
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + cos(x2) = 0;
  end IndexReduction6_Cos;

  model IndexReduction7_Sin
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( cos(x2) ) * ( der(x2) ) = 0;
end TransformCanonicalTests.IndexReduction7_Sin;
")})));
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
  x1 + sin(x2) = 0;
  end IndexReduction7_Sin;

  model IndexReduction8_Neg
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IndexReduction8_Neg",
         description="Test of index reduction",
         flatModel="
fclass TransformCanonicalTests.IndexReduction8_Neg
 Real x1;
 Real x2;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
  - ( x1 ) + ( 2 ) * ( x2 ) = 0;
  - ( der_x1 ) + ( 2 ) * ( der(x2) ) + ( 0 ) * ( x2 ) = 0;
end TransformCanonicalTests.IndexReduction8_Neg;
")})));
  Real x1,x2;
equation
  der(x1) + der(x2) = 1;
- x1 + 2*x2 = 0;
  end IndexReduction8_Neg;

  model IndexReduction9_Exp
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IndexReduction9_Exp",
         description="Test of index reduction",
         flatModel="
fclass TransformCanonicalTests.IndexReduction9_Exp
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + exp(( ( x2 ) * ( p ) ) * ( time )) = 0;
 der_x1 + ( exp(( ( x2 ) * ( p ) ) * ( time )) ) * ( ( ( x2 ) * ( p ) ) * ( 1 ) + ( ( x2 ) * ( 0 ) + ( der(x2) ) * ( p ) ) * ( time ) ) = 0;
end TransformCanonicalTests.IndexReduction9_Exp;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + exp(x2*p*time) = 0;
  end IndexReduction9_Exp;

  model IndexReduction10_Tan
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( ( cos(x2) ) ^ 2 ) = 0;
end TransformCanonicalTests.IndexReduction10_Tan;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + tan(x2) = 0;
  end IndexReduction10_Tan;

  model IndexReduction11_Asin
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( sqrt(1 - ( x2 ^ 2 )) ) = 0;
end TransformCanonicalTests.IndexReduction11_Asin;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + asin(x2) = 0;
  end IndexReduction11_Asin;

  model IndexReduction12_Acos
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + (  - ( der(x2) ) ) / ( sqrt(1 - ( x2 ^ 2 )) ) = 0;
end TransformCanonicalTests.IndexReduction12_Acos;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + acos(x2) = 0;
  end IndexReduction12_Acos;

  model IndexReduction13_Atan
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( 1 + x2 ^ 2 ) = 0;
end TransformCanonicalTests.IndexReduction13_Atan;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + atan(x2) = 0;
  end IndexReduction13_Atan;
/*
  model IndexReduction14_Atan2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IndexReduction14_Atan2",
         description="Test of index reduction",
         flatModel="
")})));
  Real x1,x2,x3;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + atan2(x2,x3) = 0;
  
  end IndexReduction14_Atan2;
*/
  model IndexReduction15_Sinh
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( cosh(x2) ) * ( der(x2) ) = 0;
end TransformCanonicalTests.IndexReduction15_Sinh;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + sinh(x2) = 0;
  end IndexReduction15_Sinh;

  model IndexReduction16_Cosh
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( sinh(x2) ) * ( der(x2) ) = 0;
end TransformCanonicalTests.IndexReduction16_Cosh;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + cosh(x2) = 0;
  end IndexReduction16_Cosh;

  model IndexReduction17_Tanh
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( ( cosh(x2) ) ^ 2 ) = 0;
end TransformCanonicalTests.IndexReduction17_Tanh;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + tanh(x2) = 0;
  end IndexReduction17_Tanh;

  model IndexReduction18_Log
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( x2 ) = 0;
end TransformCanonicalTests.IndexReduction18_Log;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + log(x2) = 0;
  end IndexReduction18_Log;

  model IndexReduction19_Log10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( ( x2 ) * ( log(10) ) ) = 0;
end TransformCanonicalTests.IndexReduction19_Log10;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + log10(x2) = 0;
  end IndexReduction19_Log10;

  model IndexReduction20_Sqrt
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( der(x2) ) / ( ( 2 ) * ( sqrt(x2) ) ) = 0;
end TransformCanonicalTests.IndexReduction20_Sqrt;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + sqrt(x2) = 0;
  end IndexReduction20_Sqrt;

  model IndexReduction21_If
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IndexReduction21_If",
         description="Test of index reduction",
         flatModel="
fclass TransformCanonicalTests.IndexReduction21_If
 Real x1;
 Real x2;
 parameter Real p = 2 /* 2 */;
 Real der_x1;
initial equation 
 x2 = 0.0;
equation
 der_x1 + der(x2) = 1;
 x1 + (if p > 3 then ( 3 ) * ( x2 ) elseif p <= 3 then sin(x2) else ( 2 ) * ( x2 )) = 0;
 der_x1 + (if p > 3 then ( 3 ) * ( der(x2) ) + ( 0 ) * ( x2 ) elseif p <= 3 then ( cos(x2) ) * ( der(x2) ) else ( 2 ) * ( der(x2) ) + ( 0 ) * ( x2 )) = 0;
end TransformCanonicalTests.IndexReduction21_If;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + (if p>3 then 3*x2 else if p<=3 then sin(x2) else 2*x2) = 0;
  end IndexReduction21_If;

  model IndexReduction22_Pow
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + ( ( p ) * ( x2 ^ ( p - ( 1 ) ) ) ) * ( der(x2) ) + ( ( 1.4 ) * ( x2 ^ 0.3999999999999999 ) ) * ( der(x2) ) = 0;
end TransformCanonicalTests.IndexReduction22_Pow;
")})));
  Real x1,x2;
  parameter Real p = 2;
equation
  der(x1) + der(x2) = 1;
 x1 + x2^p + x2^1.4 = 0;
  end IndexReduction22_Pow;

  model IndexReduction23_BasicVolume_Err
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="IndexReduction23_BasicVolume_Err",
        description="Test error messages for unbalanced systems.",
                                               errorMessage=
"2 error(s), 0 compliance error(s) and 0 warning(s) found:

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc2815301804134878885out/resources/BasicVolume.mof':
Semantic error at line 0, column 0:
  The DAE system has 12 equations and 11 free variables.

Error: in file '/var/folders/vr/vrYe4eKOEZa+6nbQYkr8vU++-ZQ/-Tmp-/jmc2815301804134878885out/resources/BasicVolume.mof':
Semantic error at line 0, column 0:
  The system is structurally singuar. The following equation(s) could not be matched to any variable:
   u = u_0 + ( c_v ) * ( T - ( T_0 ) )
")})));

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
  end IndexReduction23_BasicVolume_Err;

model IndexReduction24_DerFunc
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1 + TransformCanonicalTests.IndexReduction24_DerFunc.f_der(x2, der(x2)) = 0;

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
end IndexReduction24_DerFunc;

model IndexReduction25_DerFunc
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1_1 + TransformCanonicalTests.IndexReduction25_DerFunc.f_der({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}}, {der(x2[1]),der(x2[2])}, {{0,0},{0,0}}) = 0;
 der_x1_2 = 0;

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
end IndexReduction25_DerFunc;

model IndexReduction26_DerFunc
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 der_x1_1 + TransformCanonicalTests.IndexReduction26_DerFunc.f_der({x2[1],x2[2]}, {der(x2[1]),der(x2[2])}) = 0;
 der_x1_2 = 0;

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
end IndexReduction26_DerFunc;


model IndexReduction27_DerFunc
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
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
 Real x2[1];
 Real x2[2];
 Real der_x1_1;
 Real der_x1_2;
initial equation 
 x2[1] = 0.0;
 x2[2] = 0.0;
equation
 der_x1_1 + der(x2[1]) = 2;
 der_x1_2 + der(x2[2]) = 3;
 ({ - ( x1[1] ), - ( x1[2] )}) = TransformCanonicalTests.IndexReduction27_DerFunc.f({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}});
 ({ - ( der_x1_1 ), - ( der_x1_2 )}) = TransformCanonicalTests.IndexReduction27_DerFunc.f_der({x2[1],x2[2]}, {{A[1,1],A[1,2]},{A[2,1],A[2,2]}}, {der(x2[1]),der(x2[2])}, {{0,0},{0,0}});

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
end TransformCanonicalTests.IndexReduction27_DerFunc;
")})));

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
  Real x1[2],x2[2];
equation
  der(x1) + der(x2) = {2,3};
  x1 + f(x2,A) = {0,0};
end IndexReduction27_DerFunc;


model DuplicateVariables1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="DuplicateVariables1",
         description="Test that identical variables in base classes are handled correctly.",
         flatModel="
fclass TransformCanonicalTests.DuplicateVariables1
 Real x(start = 1,min = 2);
equation
 x = 3;
end TransformCanonicalTests.DuplicateVariables1;
")})));

  model A
    Real x(start=1, min=2) = 3;
  end A;
  Real x(start=1, min=2) = 3;
  extends A;

end DuplicateVariables1;


  model SolveEqTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest1",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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

    Real x, y, z;
  equation
    x = 1;
    y = x + 3;
    z = x - y ;
  end SolveEqTest1;

  model SolveEqTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest2",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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
  ( x + 3 ) / (  - ( 1 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / (  - ( 1 ) )
-------------------------------
")})));

    Real x, y, z;
  equation
    x = 1;
    - y = x + 3;
    - z = x - y ;
  end SolveEqTest2;

  model SolveEqTest3
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest3",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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

    Real x, y, z;
  equation
    x = 1;
    2*y = x + 3;
    x*z = x - y ;
  end SolveEqTest3;

  model SolveEqTest4
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest4",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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
  ( x + 3 ) / ( ( 1 ) / ( 2 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / ( ( 1 ) / ( x ) )
-------------------------------
")})));

    Real x, y, z;
  equation
    x = 1;
    y/2 = x + 3;
    z/x = x - y ;
  end SolveEqTest4;

  model SolveEqTest5
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest5",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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
  ( x + 3 ) / ( 1 - ( 3 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / ( 1 - ( x + 3 ) )
-------------------------------
")})));

    Real x, y, z;
  equation
    x = 1;
    y = x + 3 + 3*y;
    z = x - y + (x+3)*z ;
  end SolveEqTest5;

  model SolveEqTest6
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest6",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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


    Real x, y, z;
  equation
    x = 1;
    2/y = x + 3;
    x/z = x - y ;
  end SolveEqTest6;

  model SolveEqTest7
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="SolveEqTest7",
      methodName="printDAEBLT",
	equation_sorting = true,         
        description="Test solution of equations", methodResult=
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
  ( x + 3 ) / (  - ( 1 ) + 1 - ( 4 ) )
-------------------------------
Solved block of 1 variables:
Computed variable:
  z
Solution:
  ( x - ( y ) ) / (  - ( 1 ) + 1 + 5 )
-------------------------------
        ")})));


    Real x, y, z;
  equation
    x = 1;
    - y = x + 3 - y + 4*y;
    - z = x - y -z - 5*z;
  end SolveEqTest7;

model VarDependencyTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="VarDependencyTest1",
      methodName="dependencyDiagnostics",
	equation_sorting = true,        
        eliminate_alias_variables = false, 
        description="Test computation of direct dependencies", methodResult=
        "
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

end VarDependencyTest1;

model VarDependencyTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="VarDependencyTest2",
      methodName="dependencyDiagnostics",
	equation_sorting = true,         
        eliminate_alias_variables = false, 
        description="Test computation of direct dependencies", methodResult=
        "
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
  Real x[2](each start=2);
  input Real u[3];
  Real y[3];
equation
  der(x[1]) = x[1] + x[2] + u[1];
  der(x[2]) = x[2] + u[2] + u[3];
  y[1] = x[2] + u[1];
  y[2] = x[1] + x[2] + u[2] + u[3];
  y[3] = x[1] + u[1] + u[3];
end VarDependencyTest2;

end TransformCanonicalTests;
