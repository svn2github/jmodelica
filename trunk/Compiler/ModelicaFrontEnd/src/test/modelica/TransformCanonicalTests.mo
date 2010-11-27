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
  Type error in expression
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
  The system is structurally singuar (or of high index). The following varible(s) could not be matched to any equation:
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
  The system is structurally singuar (or of high index). The following varible(s) could not be matched to any equation:
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
  The system is structurally singuar (or of high index). The following equation(s) could not be matched to any variable:
   x = 5
")})));

  Real x;
equation
  x = 4;
  x = 5;
end UnbalancedTest3_Err;

model WhenEqu1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu1",
         description="Basic test of when equations",
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
equation
 der(z[1]) = ( z[1] ) .* ( 0.1 );
 der(z[2]) = ( z[2] ) .* ( 0.2 );
 der(z[3]) = ( z[3] ) .* ( 0.3 );
 when z[1] > 2 or z[2] > 2 or z[3] > 2 then
  x[1] = 1;
 elsewhen z[1] < 0 or z[2] < 0 or z[3] < 0 then
  x[1] = 4;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[1] = 7;
 end when;
 when z[1] > 2 or z[2] > 2 or z[3] > 2 then
  x[2] = 2;
 elsewhen z[1] < 0 or z[2] < 0 or z[3] < 0 then
  x[2] = 5;
 elsewhen z[1] + z[2] + z[3] > 4.5 then
  x[2] = 8;
 end when;
 when z[1] > 2 or z[2] > 2 or z[3] > 2 then
  x[3] = 3;
 elsewhen z[1] < 0 or z[2] < 0 or z[3] < 0 then
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
         flatModel="
fclass TransformCanonicalTests.WhenEqu2
 discrete Real x;
 discrete Real y;
 discrete Boolean w(start = true);
 discrete Boolean v(start = true);
 discrete Boolean z(start = true);
equation
 when y > 2 and pre(z) then
  w = false;
 end when;
 when y > 2 and z then
  v = false;
 end when;
 when x > 2 then
  z = false;
 end when;
 when time > 1 then
  x = pre(x) + 1;
 end when;
 when time > 1 then
  y = pre(y) + 1;
 end when;
end TransformCanonicalTests.WhenEqu2;
")})));

discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true); 
equation 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when x > 2 then 
z = false; 
end when; 
when time>1 then 
x = pre(x) + 1; 
y = pre(y) + 1; 
end when; 
end WhenEqu2;


model WhenEqu3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="WhenEqu3",
         description="Basic test of when equations",
         flatModel="
fclass TransformCanonicalTests.WhenEqu3
 discrete Real x;
 discrete Real y;
 discrete Real z;
 discrete Real v;
equation
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
end TransformCanonicalTests.WhenEqu3;
")})));
  discrete Real x,y,z,v;
equation
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
end WhenEqu3;

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

end TransformCanonicalTests;
