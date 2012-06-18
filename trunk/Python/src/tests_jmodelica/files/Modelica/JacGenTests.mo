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
  model JacTestWhenElse
	discrete Real x[3];
    Real z[3] = {1,2,3};
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
  
  
  model JacTestWhenPre
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
  end JacTestWhenPre;
  
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
  
  model JacTestWhenFunction
	function F
		input Real x;
		output Real y1;
		output Real y2;
	algorithm
		y1 := 1;
		y2 := 2;
	end F;
	Real x(start = 1);
	Real y(start = 1);
	Real z;
	Real xx;
  equation
	0 = x+y+z;
	der(xx) = x*y*z;
	when sample(0,1) then
		(x,y) = F(time);
	end when;
  end JacTestWhenFunction;

  model JacTestIfExpression1
	Real x[3] = 7:9;
	Real z(start=1);
  equation
	if false then
		x = 1:3;
	elseif false then
		x = 4:6;
	end if;
	der(z) = z + sum(x);
  end JacTestIfExpression1; 
  
  
  model JacTestIfExpression2
	Real x[3] = 7:9;
	Real z(start=1);
	Boolean y[2] = {false, 	true};
  equation
	if y[1] then
		x = 1:3;
	elseif y[2] then
		if false then
			x = 1:3;
		else
			x = 4:6;
		end if;
	end if;
	der(z) = sum(x); 
  end JacTestIfExpression2;
  
  
  model JacTestIfExpression3
      Real x(start =1);
      Real y(start = 2);
      Real z1(start = 3);
      Real z2(start = 4);
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
  end JacTestIfExpression3;
  

  // Example from Petter Lindholms (see above) thesis.
  model JacTestIfEquation1
	Real x(start=1);
	Real u(start=2);
  equation
	u = if time<=Modelica.Constants.pi /2 then sin(time) elseif
	time<= Modelica.Constants.pi  then 1 else sin(time -Modelica.Constants.pi /2);
	der(x) = u ;
  end JacTestIfEquation1;
  
  model JacTestIfEquation2
    Real x(start = 3);
	input Real u(start = 10);
	output Real y;
  equation
    der(x) = if(x < 2) then 0.3 else u;
	y = x;
  end JacTestIfEquation2;
  
  
  model JacTestIfFunctionRecord
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
	
    Real x(start=1);
    Real y = 2;
    R r;
  equation
	der(x) = log(x);
    if time > 1 then
        r=F(x,y);
    else
        r = F(x+y,y);
    end if;
  end JacTestIfFunctionRecord;
  
  model JacTestFunction1
	function F
		input Real x;
		output Real y;
	algorithm
		y := x^2;
	end F;
	Real a(start=5);
	equation
		der(a) = F(a)+a;
  end JacTestFunction1;
  
  
  model JacTestFunction2
	function F
		input Real x;
		output Real y;
	algorithm
		y := x^2;
	end F;
	function F2
		input Real x;
		output Real y;
	algorithm
		y := x^2;
	end F2;
	Real a(start=5);
	equation
		der(a) = F(a)+F2(a);
  end JacTestFunction2;
  
end JacGenTests;