package JacGenTests
// Models used to test different aspects of the Jacobian generation.
  
  // Elementary functions, implemented by JModelica.org according to Petter Lindholms 
  // master thesis: "Efficient implementation of Jacobians using automatic differentiation", p. 35
   
  model JacTestAdd
	Real x1(start=0);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = x1 + x2;
    der(x2) = x2 + x3;
	der(x3) = x3 + x1;
    y =   x1;
  end JacTestAdd;
  
  model JacTestSub
	Real x1(start=0);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = x1 - x2;
    der(x2) = x2 - x3;
	der(x3) = x3 - x1;
    y =   x1;
  end JacTestSub;  
  
  model JacTestMult
    Real x1(start=0);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = x1 * x2;
    der(x2) = x2 * x3 + x2*x2;
	der(x3) = x3 * x1 + x3*x3;
    y =   x1;
  end JacTestMult;
  
  model JacTestDiv
    Real x1(start=1);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = x1 / x2;
    der(x2) = x2 / x3;
	der(x3) = x3 / x1;
    y =   x1;
  end JacTestDiv;  
  
  
  model JacTestPow
    Real x1(start=0);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = x1 ^ x2;
    der(x2) = x2 ^ x3;
	der(x3) = x3 ^ x1;
    y =   x3^x1;
  end JacTestPow;
  
  // Fails.
  model JacTestAbs
    Real x1(start=0);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = abs(x1);
    der(x2) = abs(x2);
	der(x3) = abs(x3);
    y =   abs(x1);
  end JacTestAbs;  
  
  model JacTestSqrt
    Real x1(start=0);
    Real x2(start=5);
	Real x3(start=1);
    input Real u;
    output Real y;
  equation
    der(x1) = sqrt(x1);
    der(x2) = sqrt(x2);
	der(x3) = abs(x3+x2);
    y =   sqrt(x1);
  end JacTestSqrt;  
  
  model JacTestSin
	Real x1(start=3.141592653589793238);
    Real x2(start=-3.141592653589793238/2.0);
	Real x3(start=0);
    input Real u;
    output Real y;
  equation
    der(x1) = sin(x1);
    der(x2) = sin(x2);
	der(x3) = sin(x3);
    y =   x1;
  end JacTestSin;
  
  model JacTestCos
	Real x1(start=3.141592653589793238);
    Real x2(start=-3.141592653589793238/2.0);
	Real x3(start=0);
    input Real u;
    output Real y;
  equation
    der(x1) = cos(x1);
    der(x2) = cos(x2);
	der(x3) = cos(x3);
    y =   x1;
  end JacTestCos;
  
  model JacTestTan
    Real x1(start=3.141592653589793238/4);
    Real x2(start=-3.141592653589793238/2.2);
	Real x3(start=0);
    input Real u;
    output Real y;
  equation
    der(x1) = tan(x1);
	der(x2) = tan(x2);
	der(x3) = tan(x3);
    y =   x1;
  end JacTestTan;
  
  model JacTestCoTan
    Real x1(start=3.141592653589793238/4);
    Real x2(start=-3.141592653589793238/2.2);
	Real x3(start=0);
    input Real u;
    output Real y;
  equation
    der(x1) = tan(x1);
	der(x2) = tan(x2);
	der(x3) = tan(x3);
    y =   x1;
  end JacTestCoTan;
  
  model JacTestAsin
	Real x1(start=-1);
    Real x2(start=0);
	Real x3(start=1);
    input Real u;
    output Real y;
  equation
    der(x1) = asin(x1);
    der(x2) = asin(x2);
	der(x3) = asin(x3);
    y =   x1;
  end JacTestAsin;
  
  model JacTestAcos
    Real x1(start=-1);
    Real x2(start=0);
	Real x3(start=1);
    input Real u;
    output Real y;
  equation
    der(x1) = acos(x1);
    der(x2) = acos(x2);
	der(x3) = acos(x3);
    y =   x1;
  end JacTestAcos;
  
  model JacTestAtan
    Real x1(start=-10);
    Real x2(start=0);
	Real x3(start=10);
    input Real u;
    output Real y;
  equation
    der(x1) = atan(x1);
    der(x2) = atan(x2);
	der(x3) = atan(x3);
    y =   x1;
  end JacTestAtan;
  
  model JacTestAtan2
    Real x1(start=-200);
    Real x2(start=200);
	Real x3(start=0);
    input Real u;
    output Real y;
  equation
    der(x1) = atan2(x1, x2);
    der(x2) = atan2(x2, x1);
	der(x2) = atan2(x2, x3);
    y =   x1;
  end JacTestAtan2;
  
  model JacTestSinh
    Real x1(start=-10);
    Real x2(start=0);
	Real x3(start=10);
    input Real u;
    output Real y;
  equation
    der(x1) = sinh(x1);
    der(x2) = sinh(x2);
	der(x3) = sinh(x3);
    y =   x1;
  end JacTestSinh;
  
  model JacTestCosh
    Real x1(start=1);
    Real x2(start=2);
	Real x3(start=3);
    input Real u;
    output Real y;
  equation
    der(x1) = cosh(x1);
    der(x2) = cosh(x2);
	der(x3) = cosh(x3);
    y =   x1;
  end JacTestCosh;
  
  model JacTestTanh
    Real x1(start=-10);
    Real x2(start=0);
	Real x3(start=10);
    input Real u;
    output Real y;
  equation
    der(x1) = tanh(x1);
    der(x2) = tanh(x2);
	der(x3) = tanh(x3);
    y = x1;
  end JacTestTanh;
  
  model JacTestExp
    Real x1(start=-10);
    Real x2(start=0);
	Real x3(start=10);
    input Real u;
    output Real y;
  equation
    der(x1) = exp(x1);
    der(x2) = exp(x2);
	der(x3) = exp(x3);
    y =   x1;
  end JacTestExp;
  
  model JacTestLog
    Real x1(start=0.00005);
    Real x2(start=1);
	Real x3(start=10);
    input Real u;
    output Real y;
  equation
    der(x1) = log(x1);
    der(x2) = log(x2);
	der(x3) = log(x3);
    y =   x1;
  end JacTestLog;
  
  model JacTestLog10
    Real x1(start=0.0005);
    Real x2(start=1);
	Real x3(start=10);
    input Real u;
    output Real y;
  equation
    der(x1) = log10(x1);
    der(x2) = log10(x2);
	der(x3) = log10(x3);
    y =   x2;
  end JacTestLog10;
  
  
  // Models for testing Jacobian generation for harder case involving if, when etc. follows
  
  
  // Raises compliance error: "Else clauses in when equations are currently not supported". 
  // Even if generate_ode_jacobian is set to false. 
  model JacTestWhenElse
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
  end JacTestWhenElse;
  
  // Raises the following error
  /*
	CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	C file location: C:\Users\BJRN~1\AppData\Local\Temp\jmc1482706606785370032out\sources\JacGenTests_JacTestWhenSimple.c
	Stacktrace: org.jmodelica.modelica.compiler.CcodeCompilationException: Compilation of generated C code failed.
	C file location: C:\Users\BJRN~1\AppData\Local\Temp\jmc1482706606785370032out\sources\JacGenTests_JacTestWhenSimple.c
	at org.jmodelica.modelica.compiler.GccCompilerDelegator.compileCCode(GccCompilerDelegator.java:231)
	at org.jmodelica.modelica.compiler.ModelicaCompiler.compileUnit(ModelicaCompiler.java:1116)
	at org.jmodelica.modelica.compiler.ModelicaCompiler.compileFMU(ModelicaCompiler.java:1057)
	*/
  
  model JacTestWhenSimple
	Real xx(start=10);
	discrete Real x; 
	input Real u;
	output Real y;
  equation
	der(xx) =  log10(xx) + x; 
	when u > 1 then
		x = 0;
	end when;
	y = xx;
  end JacTestWhenSimple; 
  
  // Raises the following error:
    /*
	CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	C file location: C:\Users\BJRN~1\AppData\Local\Temp\jmc6823091668054956466out\sources\JacGenTests_JacTestWhenSample.c
	Stacktrace: org.jmodelica.modelica.compiler.CcodeCompilationException: Compilation of generated C code failed.
	C file location: C:\Users\BJRN~1\AppData\Local\Temp\jmc6823091668054956466out\sources\JacGenTests_JacTestWhenSample.c
	at org.jmodelica.modelica.compiler.GccCompilerDelegator.compileCCode(GccCompilerDelegator.java:231)
	at org.jmodelica.modelica.compiler.ModelicaCompiler.compileUnit(ModelicaCompiler.java:1116)
	at org.jmodelica.modelica.compiler.ModelicaCompiler.compileFMU(ModelicaCompiler.java:1057)
    */
  
  model JacTestWhenSample 
	discrete Real x,y;
	Real dummy(start = 1);
  equation
    der(dummy) = dummy;
    when sample(0,1/3) then
		x = pre(x) + 1;
	end when;
	when sample(0,2/3) then
		y = pre(y) + 1;
	end when;
  end JacTestWhenSample; 

 // Fails, raises the following error:
 /*
	CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	C file location: C:\Users\BJRN~1\AppData\Local\Temp\jmc2325151140567958547out\sources\JacGenTests_JacTestWhenSample.c
	Stacktrace: org.jmodelica.modelica.compiler.CcodeCompilationException: Compilation of generated C code failed.
	C file location: C:\Users\BJRN~1\AppData\Local\Temp\jmc2325151140567958547out\sources\JacGenTests_JacTestWhenSample.c
	at org.jmodelica.modelica.compiler.GccCompilerDelegator.compileCCode(GccCompilerDelegator.java:231)
	at org.jmodelica.modelica.compiler.ModelicaCompiler.compileUnit(ModelicaCompiler.java:1116)
	at org.jmodelica.modelica.compiler.ModelicaCompiler.compileFMU(ModelicaCompiler.java:1057)
*/
  model JacTestIfSimple1
	Real x[3] = 7:9;
	Real z(start=1);
  equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	end if;
	der(z) = sum(x);
  end JacTestIfSimple1; 

  // Example from Petter Lindholms (see above) thesis.
  model JacTestIfSimple2
	Real x(start=1);
	Real u(start=2);
  equation
	u = if time<=Modelica.Constants.pi /2 then sin(time) elseif
	time<= Modelica.Constants.pi  then 1 else sin(time -Modelica.Constants.pi /2);
	der(x) = u ;
  end JacTestIfSimple2;
  
end JacGenTests;





















































