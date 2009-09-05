package OptimicaTransformCanonicalTests

  optimization LinearityTest1 (objective = cost(finalTime)^2,
                               startTime=0,
                               finalTime=1)

  	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="LinearityTest1",
      methodName="variableDiagnostics",
        description="Test linearity of variables.", methodResult=
        "  
Independent constants: 

Dependent constants: 

Independent parameters: 
 p1: number of uses: 3, isLinear: true evaluated binding exp: 1.0
 p2: number of uses: 1, isLinear: false

Dependent parameters: 

Differentiated variables: 
 cost: number of uses: 0, isLinear: true

Derivative variables: 
 der(cost): number of uses: 1, isLinear: true

Algebraic variables: 
 x1: number of uses: 2, isLinear: true, alias: no
 x2: number of uses: 2, isLinear: true, alias: no
 x3: number of uses: 2, isLinear: false, alias: no
 x4: number of uses: 2, isLinear: true, alias: no
 x5: number of uses: 2, isLinear: false, alias: no
 x6: number of uses: 3, isLinear: true, alias: no
 x7: number of uses: 2, isLinear: false, alias: no
 x8: number of uses: 1, isLinear: false, alias: no

Input variables: 

  ")})));

        Real cost;
  
  	Real x1;
  	Real x2;
  	Real x3;
  	Real x4;
  	Real x5;
  	Real x6;
  	Real x7;
	Real x8;
  	
  	parameter Real p1 = 1;
        parameter Real p2(free=true,initialGuess=3);
  	  
  equation
	der(cost) = 1;
  	x1 = x1*p1 + x2;
  	x2 = x3^2;
  	x3 = x4/p1;
  	x4 = p1/x5;
  	x5 = x6-x6;
  	x6 = sin(x7);
	x7 = x8*p2;  

  end LinearityTest1;


  optimization LinearityTest2 (objective = x(finalTime)^2,
                               startTime=0,
                               finalTime=5)

  	annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FClassMethodTestCase(name="LinearityTest2",
      methodName="timedVariablesLinearityDiagnostics",
        description="Test linearity of variables.", methodResult=
        "  
Linearity of time points:
t0:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t1:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t2:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t3:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t4:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
t5:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
x:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: false
  5.0, isLinear: false
y:
  0.0, isLinear: true
  1.0, isLinear: false
  2.0, isLinear: false
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
  ")})));

	parameter Real t0 = 0;
	parameter Real t1 = 1;
	parameter Real t2 = 2;
	parameter Real t3 = 3;
	parameter Real t4 = 4;
	parameter Real t5 = 5;
	
	Real x;
        Real y;

     equation
        x = y(t0)+y(t1)^2 + sin(y(t2));

     constraint
        x(t3) >= 1;
        x(t4)*x(t4) <= 1;

  end LinearityTest2;	

end OptimicaTransformCanonicalTests;