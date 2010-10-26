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
 p1: number of uses: 3, isLinear: true, evaluated binding exp: 1
 p2: number of uses: 1, isLinear: false
 startTime: number of uses: 0, isLinear: true, evaluated binding exp: 0
 finalTime: number of uses: 1, isLinear: true, evaluated binding exp: 1
Dependent parameters: 

Differentiated variables: 
 cost: number of uses: 0, isLinear: true

Derivative variables: 
 der(cost): number of uses: 1, isLinear: true

Discrete variables: 

Algebraic real variables: 
 x1: number of uses: 3, isLinear: true, alias: no
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
	x1 = 1;

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
startTime:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
  3.0, isLinear: true
  4.0, isLinear: true
  5.0, isLinear: true
finalTime:
  0.0, isLinear: true
  1.0, isLinear: true
  2.0, isLinear: true
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

     constraint
        x = y(t0)+y(t1)^2 + sin(y(t2));
        x = 3;
        x(t3) >= 1;
        x(t4)*x(t4) <= 1;

  end LinearityTest2;	

  optimization ArrayTest1 (objective=cost(finalTime),startTime=0,finalTime=2)
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest1",
        description="Test arrays in Optimica",
                                               flatModel=
"optimization OptimicaTransformCanonicalTests.ArrayTest1(objective = cost(finalTime),startTime = 0,finalTime = 2)
 Real cost(start = 0,fixed = true);
 Real x[1](start = 1,fixed = true);
 Real x[2](start = 1,fixed = true);
 Real y;
 input Real u;
 parameter Real A[1,1] =  - ( 1 ) ;
 parameter Real A[1,2] = 0;
 parameter Real A[2,1] = 1 ;
 parameter Real A[2,2] =  - ( 1 );
 parameter Real B[1] = 1;
 parameter Real B[2] = 2;
 parameter Real C[1] = 1;
 parameter Real C[2] = 1;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
 Real der(x[1]);
 Real der(x[2]);
 Real der(cost);
initial equation 
 cost = 0;
 x[1] = 1;
 x[2] = 1;
equation 
 der(x[1]) = ( A[1,1] ) * ( x[1] ) + ( A[1,2] ) * ( x[2] ) + ( B[1] ) * ( u );
 der(x[2]) = ( A[2,1] ) * ( x[1] ) + ( A[2,2] ) * ( x[2] ) + ( B[2] ) * ( u );
 y = ( C[1] ) * ( x[1] ) + ( C[2] ) * ( x[2] );
 der(cost) = y ^ 2 + u ^ 2;
constraint 
 u >= - ( 1 );
 u <= 1;
 x[1](finalTime) = 0;
 x[2](finalTime) = 0;
 x[1] <= 1;
 x[2] <= 1;
 x[1] >= - ( 1 );
 x[2] >= - ( 1 );
end OptimicaTransformCanonicalTests.ArrayTest1;
")})));

    Real cost(start=0,fixed=true);
    Real x[2](start={1,1},each fixed=true);
    Real y;
    input Real u;
    parameter Real A[2,2] = {{-1,0},{1,-1}};
    parameter Real B[2] = {1,2};
    parameter Real C[2] = {1,1};
  equation 
    der(x) = A*x+B*u;
    y = C*x;
    der(cost) = y^2 + u^2;
  constraint
    u >= -1;
    u <= 1;
    x(finalTime) = {0,0};
    x <= {1,1}; // This constraint has no effect but is added for testing
    x >= {-1,-1}; // This constraint has no effect but is added for testing
  end ArrayTest1;

  optimization ArrayTest2 (objective=cost(finalTime)+x[1](finalTime)^2 + x[2](finalTime)^2,startTime=0,finalTime=2)

	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="ArrayTest2",
        description="Test arrays in Optimica",
                                               flatModel=
"
optimization OptimicaTransformCanonicalTests.ArrayTest2(objective = cost(finalTime) + ( x[1](finalTime) ) ^ 2 + ( x[2](finalTime) ) ^ 2,startTime = 0,finalTime = 2)
 Real cost(start = 0,fixed = true);
 Real x[1](start = 1,fixed = true);
 Real x[2](start = 1,fixed = true);
 Real y;
 input Real u;
 parameter Real A[1,1] =  - ( 1 );
 parameter Real A[1,2] = 0;
 parameter Real A[2,1] = 1;
 parameter Real A[2,2] =  - ( 1 );
 parameter Real B[1] = 1 ;
 parameter Real B[2] = 2 ;
 parameter Real C[1] = 1 ;
 parameter Real C[2] = 1 ;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
 Real der(x[1]);
 Real der(x[2]);
 Real der(cost);
initial equation 
 cost = 0;
 x[1] = 1;
 x[2] = 1;
equation 
 der(x[1]) = ( A[1,1] ) * ( x[1] ) + ( A[1,2] ) * ( x[2] ) + ( B[1] ) * ( u );
 der(x[2]) = ( A[2,1] ) * ( x[1] ) + ( A[2,2] ) * ( x[2] ) + ( B[2] ) * ( u );
 y = ( C[1] ) * ( x[1] ) + ( C[2] ) * ( x[2] );
 der(cost) = y ^ 2 + u ^ 2;
constraint 
 u >= - ( 1 );
 u <= 1;
end OptimicaTransformCanonicalTests.ArrayTest2;
")})));

    Real cost(start=0,fixed=true);
    Real x[2](start={1,1},each fixed=true);
    Real y;
    input Real u;
    parameter Real A[2,2] = {{-1,0},{1,-1}};
    parameter Real B[2] = {1,2};
    parameter Real C[2] = {1,1};
  equation 
    der(x) = A*x+B*u;
    y = C*x;
    der(cost) = y^2 + u^2;
  constraint
    u >= -1;
    u <= 1;
  end ArrayTest2;

  optimization ArrayTest3_Err (objective=x(finalTime),startTime=0,startTime=3)

   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ArrayTest3_Err",
                                               description="Test type checking of class attributes in Optimica.",
                                               errorMessage=
"
1 Error(s) found
Error: in file '/Users/jakesson/projects/JModelica/Compiler/OptimicaFrontEnd/src/test/modelica/OptimicaTransformCanonicalTests.mo':
Semantic error at line 271, column 27:
  Array size mismatch for the attribute objective, size of declaration is [] and size of objective expression is [2]
  
")})));

    Real x[2](each start=1,each fixed=true);
  equation
    der(x) = -x;
  end ArrayTest3_Err;


optimization TimedArrayTest1 (objective=y(finalTime),startTime=0,finalTime=2)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="TimedArrayTest1",
         description="Timed array variables: basic test",
         flatModel="
optimization OptimicaTransformCanonicalTests.TimedArrayTest1(objective = y(finalTime),startTime = 0,finalTime = 2)
 Real x[2];
 Real y;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
equation 
 y = 1;
 x[2] = 2;
constraint 
 y <= x[2](0);
end OptimicaTransformCanonicalTests.TimedArrayTest1;
")})));

 Real x[2] = {1,2};
 Real y = x[1];
constraint
 y <= x[2](0);
end TimedArrayTest1;


optimization TimedArrayTest2 (objective=y(finalTime),startTime=0,finalTime=2)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="TimedArrayTest2",
         description="Timed array variables: scalarizing vector multiplication",
         flatModel="
optimization OptimicaTransformCanonicalTests.TimedArrayTest2(objective = y(finalTime),startTime = 0,finalTime = 2)
 Real x[1];
 Real x[2];
 Real y;
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
equation 
 x[1] = 1;
 x[2] = 2;
 y = x[1] + 3;
constraint 
 y <= ( x[1](0) ) * ( 2 ) + ( x[2](0) ) * ( 3 );
end OptimicaTransformCanonicalTests.TimedArrayTest2;
")})));

 Real x[2] = {1,2};
 Real y = x[1] + 3;
constraint
 y <= x(0) * {2,3};
end TimedArrayTest2;


optimization TimedArrayTest3 (objective=y(finalTime),startTime=0,finalTime=2)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="TimedArrayTest3",
         description="Type checking timed variables: string arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/OptimicaFrontEnd/src/test/modelica/OptimicaTransformCanonicalTests.mo':
Semantic error at line 347, column 7:
  Type error in expression
")})));

 Real x[2] = {1,2};
 Real y = x[1] + 3;
constraint
 y <= x("0") * {2,3};
end TimedArrayTest3;


optimization TimedArrayTest4 (objective=y(finalTime),startTime=0,finalTime=2)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="TimedArrayTest4",
         description="Type checking timed variables: continuous arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/OptimicaFrontEnd/src/test/modelica/OptimicaTransformCanonicalTests.mo':
Semantic error at line 366, column 7:
  Type error in expression
")})));

 Real x[2] = {1,2};
 Real y = x[1] + 3;
constraint
 y <= x(y) * {2,3};
end TimedArrayTest4;


optimization ForConstraint1 (objective=sum(y(finalTime)),startTime=0,finalTime=2)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForConstraint1",
         description="Scalarization of for constraints",
         flatModel="
optimization OptimicaTransformCanonicalTests.ForConstraint1(objective = y[1](finalTime) + y[2](finalTime),startTime = 0,finalTime = 2)
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
 parameter Real startTime = 0 /* 0 */;
 parameter Real finalTime = 2 /* 2 */;
equation 
 x[1] = 1;
 x[2] = 2;
 y[1] = 3 + x[1];
 y[2] = 4 + x[2];
constraint 
 y[1] <= x[1];
 y[1] <= x[2];
 y[2] <= x[1];
 y[2] <= x[2];
end OptimicaTransformCanonicalTests.ForConstraint1;
")})));

 Real x[2] = {1,2};
 Real y[2] = {3,4} + x;
constraint
 for i in 1:2, j in 1:2 loop
  y[i] <= x[j];
 end for;
end ForConstraint1;

optimization MinTimeTest1 (objective=finalTime,finalTime(free=true,start=1,initialGuess=3)=4)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinTimeTest1",
         description="Test normalization of minimum time problems",
         flatModel="
optimization OptimicaTransformCanonicalTests.MinTimeTest1(objective = finalTime,finalTime = 1.0)
 Real x(start = 1,fixed = true);
 Real dx(start = 0,fixed = true);
 input Real u;
 parameter Real startTime = 0.0 /* 0.0 */;
 parameter Real finalTime(free = true,start = 1,initialGuess = 3);
 Real der(x);
 Real der(dx);
initial equation 
 x = 1;
 dx = 0;
equation 
 ( der(x) ) / ( finalTime - ( startTime ) ) = dx;
 ( der(dx) ) / ( finalTime - ( startTime ) ) = u;
constraint 
 u <= 1;
 u >=  - ( 1 );
 x(finalTime) = 0;
 dx(finalTime) = 0;
end OptimicaTransformCanonicalTests.MinTimeTest1;
")})));

  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;
end MinTimeTest1;

optimization MinTimeTest2 (objective=-startTime,
                          startTime(free=true,initialGuess=-1)=2)
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinTimeTest2",
         description="Test normalization of minimum time problems",
         flatModel="
optimization OptimicaTransformCanonicalTests.MinTimeTest2(objective =  - ( startTime ),startTime = 0.0)
 Real x(start = 1,fixed = true);
 Real dx(start = 0,fixed = true);
 input Real u;
 parameter Real startTime(free = true,initialGuess =  - ( 1 ),start =  - ( 1 ));
 parameter Real finalTime = 1.0 /* 1.0 */;
 Real der(x);
 Real der(dx);
initial equation 
 x = 1;
 dx = 0;
equation 
 ( der(x) ) / ( finalTime - ( startTime ) ) = dx;
 ( der(dx) ) / ( finalTime - ( startTime ) ) = u;
constraint 
 u <= 1;
 u >=  - ( 1 );
 x(finalTime) = 0;
 dx(finalTime) = 0;
end OptimicaTransformCanonicalTests.MinTimeTest2;
")})));


  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;
end MinTimeTest2;

optimization MinTimeTest3 (objective=finalTime,
                          startTime(free=true,initialGuess=-1), finalTime(free=true,initialGuess = 2))
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MinTimeTest3",
         description="Test normalization of minimum time problems",
         flatModel="
optimization OptimicaTransformCanonicalTests.MinTimeTest3(objective = finalTime,startTime = 0.0,finalTime = 1.0)
 Real x(start = 1,fixed = true);
 Real dx(start = 0,fixed = true);
 input Real u;
 parameter Real startTime(free = true,initialGuess =  - ( 1 ),start =  - ( 1 ));
 parameter Real finalTime(free = true,initialGuess = 2,start = 2);
 Real der(x);
 Real der(dx);
initial equation 
 x = 1;
 dx = 0;
equation 
 ( der(x) ) / ( finalTime - ( startTime ) ) = dx;
 ( der(dx) ) / ( finalTime - ( startTime ) ) = u;
constraint 
 startTime =  - ( 1 );
 u <= 1;
 u >=  - ( 1 );
 x(finalTime) = 0;
 dx(finalTime) = 0;
end OptimicaTransformCanonicalTests.MinTimeTest3;
")})));

  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  startTime=-1;
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;
end MinTimeTest3;


  model DAETest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="DAETest1",
         description="Fixed set from parameter with parameter equation",
         flatModel="
fclass OptimicaTransformCanonicalTests.DAETest1
 parameter Integer N = 5 \"Number of linear ODEs/DAEs\" /* 5 */;
 parameter Integer N_states = 3 \"Number of states: < N\" /* 3 */;
 Real x[1](start = 3,fixed = dynamic[1]) \"States/algebraics\";
 Real x[2](start = 3,fixed = dynamic[2]) \"States/algebraics\";
 Real x[3](start = 3,fixed = dynamic[3]) \"States/algebraics\";
 Real x[4](start = 3,fixed = dynamic[4]) \"States/algebraics\";
 Real x[5](start = 3,fixed = dynamic[5]) \"States/algebraics\";
 input Real u \"Control input\";
 parameter Real a[1] = 3.0 \"Time constants\" /* 3.0 */;
 parameter Real a[2] = 2.5 \"Time constants\" /* 2.5 */;
 parameter Real a[3] = 2.0 \"Time constants\" /* 2.0 */;
 parameter Real a[4] = 1.5 \"Time constants\" /* 1.5 */;
 parameter Real a[5] = 1.0 \"Time constants\" /* 1.0 */;
 parameter Boolean dynamic[1] \"Switches for turning ODEs into DAEs\";
 parameter Boolean dynamic[2] \"Switches for turning ODEs into DAEs\";
 parameter Boolean dynamic[3] \"Switches for turning ODEs into DAEs\";
 parameter Boolean dynamic[4] \"Switches for turning ODEs into DAEs\";
 parameter Boolean dynamic[5] \"Switches for turning ODEs into DAEs\";
initial equation 
 x[1] = 3;
 x[2] = 3;
 x[3] = 3;
parameter equation
 dynamic[1] = (if 1 <= N_states then true else false);
 dynamic[2] = (if 2 <= N_states then true else false);
 dynamic[3] = (if 3 <= N_states then true else false);
 dynamic[4] = (if 4 <= N_states then true else false);
 dynamic[5] = (if 5 <= N_states then true else false);
equation
 der(x[1]) = (  - ( a[1] ) ) * ( x[1] ) + ( a[1] ) * ( x[2] );
 der(x[2]) = (  - ( a[2] ) ) * ( x[2] ) + ( a[2] ) * ( x[3] );
 der(x[3]) = (  - ( a[3] ) ) * ( x[3] ) + ( a[3] ) * ( x[4] );
 0 = (  - ( a[4] ) ) * ( x[4] ) + ( a[4] ) * ( x[5] );
 0 = (  - ( a[5] ) ) * ( x[5] ) + ( a[5] ) * ( u );
end OptimicaTransformCanonicalTests.DAETest1;
")})));

	parameter Integer N = 5 "Number of linear ODEs/DAEs";
	parameter Integer N_states = 3 "Number of states: < N";
	Real x[N](each start=3,fixed=dynamic) "States/algebraics";
	input Real u "Control input";
	output Real y = x[1] "Output";
	parameter Real a[N] = (0.5*(N+1):-0.5:1) "Time constants";
	parameter Boolean dynamic[N] = array((if i<=N_states then true else false) for i in 1:N) "Switches for turning ODEs into DAEs";    
  equation
	// ODE equations
	for i in 1:N_states loop
		der(x[i]) = -a[i]*x[i] + a[i]*x[i+1];
	end for;
	// DAE equations
	for i in N_states+1:N-1 loop
		0 = -a[i]*x[i] + a[i]*x[i+1];
	end for;
	// The last equation is assumed to be algebraic
	0 = -a[N]*x[N] + a[N]*u;
  end DAETest1;


end OptimicaTransformCanonicalTests;
