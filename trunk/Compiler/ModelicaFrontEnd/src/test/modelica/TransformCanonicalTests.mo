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
 y = 3;
 w = 2;
end TransformCanonicalTests.TransformCanonicalTest1;
")})));

		Real x(start=1,fixed=true);
		Real y(start=3,fixed=true)=3;
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
	end TransformCanonicalTest1;
	
  model TransformCanonicalTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest2",
        description="Test parameter sorting",
                                               flatModel=
"
fclass TransformCanonicalTests.TransformCanonicalTest2
 parameter Real p5 = 5;
 parameter Real p1 = 4;
 parameter Real p6 = p5;
 parameter Real p2 = ( p1 ) * ( p1 );
 parameter Real p3 = p2 + p1;
 parameter Real p4 = ( p3 ) * ( p3 );
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
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest5",
        description="Test parameter sorting",
                                               flatModel=
"
fclass TransformCanonicalTests.TransformCanonicalTest5
 parameter Real p7 = 1;
 parameter Real p5 = 1;
 parameter Real p3 = 1;
 parameter Real p11 = ( p7 ) * ( p5 );
 parameter Real p8 = ( p7 ) * ( p3 );
 parameter Real p10 = ( p11 ) * ( p3 );
 parameter Real p2 = p11;
 parameter Real p9 = ( p11 ) * ( p8 );
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
 p1: number of uses: 0, isLinear: true evaluated binding exp: 0.8414709848078965
 p2: number of uses: 0, isLinear: true evaluated binding exp: 0.5403023058681398
 p3: number of uses: 0, isLinear: true evaluated binding exp: 1.5574077246549023
 p4: number of uses: 0, isLinear: true evaluated binding exp: 0.3046926540153975
 p5: number of uses: 0, isLinear: true evaluated binding exp: 1.2661036727794992
 p6: number of uses: 0, isLinear: true evaluated binding exp: 0.2914567944778671
 p7: number of uses: 0, isLinear: true evaluated binding exp: 0.5404195002705842
 p8: number of uses: 0, isLinear: true evaluated binding exp: 1.1752011936438014
 p9: number of uses: 0, isLinear: true evaluated binding exp: 1.543080634815244
 p10: number of uses: 0, isLinear: true evaluated binding exp: 0.7615941559557649
 p11: number of uses: 0, isLinear: true evaluated binding exp: 2.7182818284590455
 p12: number of uses: 0, isLinear: true evaluated binding exp: 0.0
 p13: number of uses: 0, isLinear: true evaluated binding exp: 0.0

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
 p1: number of uses: 0, isLinear: true evaluated binding exp: 10000.0

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
 p1: number of uses: 3, isLinear: true evaluated binding exp: 1.0

Dependent parameters: 

Differentiated variables: 

Derivative variables: 

Discrete variables:

Algebraic real variables: 
 x1: number of uses: 2, isLinear: true, alias: no
 x2: number of uses: 2, isLinear: true, alias: no
 x3: number of uses: 2, isLinear: false, alias: no
 x4: number of uses: 2, isLinear: true, alias: no
 x5: number of uses: 2, isLinear: false, alias: no
 x6: number of uses: 3, isLinear: true, alias: no
 x7: number of uses: 1, isLinear: false, alias: no

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
      JModelica.UnitTesting.ErrorTestCase(name="ParameterBindingExpTest3_Warn",
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


end TransformCanonicalTests;