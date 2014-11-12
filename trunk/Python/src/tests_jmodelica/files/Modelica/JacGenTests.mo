/*
    Copyright (C) 2012 Modelon AB

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
    Real x1(start=1);
    Real x2(start=5);
	Real x3(start=2);
    input Real u;
    output Real y;
  equation
    der(x1) = x1 ^ x2;
    der(x2) = x2 ^ x3;
	der(x3) = x3 ^ x1;
    y =   x3^x1;
  end JacTestPow;

  
  model JacTestAbs1
    Real x1(start=1);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = abs(x1);
    der(x2) = abs(-x2)*2;
	der(x3) = -abs(x3);
    y =   abs(x1*x2)+x3;
  end JacTestAbs1;  
  
  model JacTestMin
    Real x1(start=1);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = min(x1,x2);
    der(x2) = min(x1,x3);
	der(x3) = min(x3,x2);
    der(y) =   min(min(x1,x2),x3);
  end JacTestMin;  
  
  model JacTestMax
    Real x1(start=1);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = max(x1,x2);
    der(x2) = max(x1,x3);
	der(x3) = max(x3,x2);
    y =   max(max(x1,x2),x3);
  end JacTestMax;  
  
  model JacTestSqrt
    Real x1(start=0.5);
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
	Real x1(start=-0.9);
    Real x2(start=0);
	Real x3(start=0.9);
    input Real u;
    output Real y;
  equation
    der(x1) = asin(x1);
    der(x2) = asin(x2);
	der(x3) = asin(x3);
    y =   x1;
  end JacTestAsin;
  
  model JacTestAcos
    Real x1(start=-0.9);
    Real x2(start=0);
	Real x3(start=0.9);
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
	der(x3) = atan2(x2, x3);
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
  
	model SmoothTest1
		Real x;
		Real y;
	equation
		x = time;
		y = smooth(1, if x <= 0 then 0 else x ^ 2);
	end SmoothTest1;
	
	model NotTest1
		Real x;
		Real y;
	equation
		x = time;
		y = noEvent(if not x < 0 then 0 else x ^ 2);
	end NotTest1;
  
  
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
		Real x1(start = 7);
		Real x2(start = 8);
		Real z(start=2);
		Boolean y = true;
	equation
		if not y then
			der(x1) = 2;
			der(x2) = 3;
		elseif y then
			if y then
				der(x1) = 4;
				der(x2) = 5;
			else
				der(x1) = 6;
				der(x2) = 7;
			end if;
		else 
			der(x1) = 1;
			der(x2) = 1;
		end if;
		der(z) = x1+x2; 
	end JacTestIfExpression2;
  
  
  model JacTestIfExpression3
      Real x(start =1);
      Real y(start = 2);
      Real z1(start = 3);
      Real z2(start = 4);
  equation
	if time < 1 then
	  der(x)=y;
	  der(y)=y;
	  der(z1)=y;
	  der(z2)=y;
	else
	  der(x) = x;
	  if time < 3 then
		  der(y) = x;
		  der(z1) = y * x;
	  else
		  der(y) = x;
		  der(z1) = y * x;
	  end if;
	  der(z2) = x;
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
  
    model JacTestIfEquation3
    Real x(start = 3);
	input Real u(start = 10);
	output Real y;
  equation
    der(x) = if(time < 1) then 
				if(x < 2) then 0.3 else u
			else
				if(x > 1) then 0.8 else 2*u;
	y = x;
  end JacTestIfEquation3;
  
  model JacTestIfEquation4
	Real x(start=1);
	Real u(start=2);
  equation
    u = if(x > 3) then noEvent(if time<=Modelica.Constants.pi/2 then sin(time) elseif 
              noEvent(time<=Modelica.Constants.pi) then 1 else sin(time-Modelica.Constants.pi/2)) else noEvent(sin(3*x));
    der(x) = u;
  end JacTestIfEquation4;
  
  
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
		y := x;
	end F;
	Real a(start=2);
	equation
		der(a) = F(a);
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
  
  model JacTestFunction3
	function F
		input Real x;
		output Real y;
	algorithm
		y := log(x);
	end F;
	function F2
		input Real x;
		output Real y;
	algorithm
		y := F(x);
	end F2;
	Real x(start=5);
	equation
		der(x) = F2(x);
  end JacTestFunction3; 
  
  model JacTestFunction4
	function F
		input Real x;
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2;
		b := x*4;
		c := x*8;
	end F;
	Real x(start=5);
	equation
		der(x) = log(F(x));
  end JacTestFunction4; 
  
  
  model JacTestFunction5
	function F
		input Real x;
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2;
		b := x*4;
		c := x*8;
	end F;
	function F2
		input Real x;
		output Real a;
		output Real b;
	algorithm
		(a,b) := F(x);
	end F2;
	Real x(start=5);
	Real y(start=2);
	output Real a(start=2);
	equation
		(x,y)  = F2(a);
		der(a) = x+y;
  end JacTestFunction5; 
  
  model JacTestFunction6
	function F
		input Real x;
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2;
		b := x*4;
		c := x*8;
	end F;
	Real x(start=5);
	Real y(start=10);
	Real z(start=10);
	Real a(start=15);
	equation
		(x,y,z) = F(a);
		der(a)  = x+y+z;
  end JacTestFunction6; 
  
  model JacTestFunction7
	function F
		input Real x;
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2;
		b := x*4;
		c := x*8;
	end F;
	Real x(start=5);
	Real y(start=10);
	Real a(start=15);
	equation
		a 	  = x+y;
		(x,y) = F(a);
  end JacTestFunction7; 
  
  
  model JacTestExpInFuncArg1
  	function f
		input Real x;
		output Real y1;
		output Real y2;
	algorithm
		(y1,y2) := f3(x+100,x^2);
	end f;

	function f1
		input Real x;
		output Real y;
	algorithm
		y := f2(sin(x))^(-2);
	end f1;


	function f2
		input Real x;
		output Real y;
	algorithm
		y := x^(-3);
	end f2;
	
	function f3
		input Real x1;
		input Real x2;
		output Real y1;
		output Real y2;
	algorithm
		y1 := x1^(-3);
		y2 := x2^(-5);
	end f3;

	Real x1(start=.1),x2(start=.2);
	Real u1,u2;
	Real v1,v2;
equation
	der(x1) = f(sin(x2));
	der(x2) = f1(x1);
	(u1,u2) = f(sin(x1));
	der(v1) = u1;
	der(v2) = u2;
  end JacTestExpInFuncArg1;
  
model JacTestDiscreteFunction1
	function F
		input Integer f;
		input Real x;
		output Real a;
	algorithm
		a := x ^ f;
	end F;
	Real x(start=5);
	Real y(start=10);
	Real a(start=15);
equation
	x = F(2, x);
	der(y) = x*a;
	der(a) = x*y;
end JacTestDiscreteFunction1;

 model Unsolved_blocks1
	Real x(start=.5);
	Real y(start=10);
	Real a(start=15);
	output Real b(start=2);
	equation
		x-0.1 = cos(x);
		0 = a+y;
		der(y) = a+x;
		der(b) = a+x*y;
 end Unsolved_blocks1;
 
 
  model Unsolved_blocks2
  Real x_1(start=1.29533105933, nominal=1e-3);
  output Real w_ode_1_1(nominal=1e-3);
  Real w_ode_1_2;
  input Real ur_1;
  input Real ur_2;
  input Real ur_3;
equation
	w_ode_1_1*20 + (1.30*w_ode_1_2 + sin(w_ode_1_2) ) + (-2.01*x_1 + sin(x_1) ) + (-1.18*x_1) + (1.45*x_1) + (1.09*ur_2 + sin(ur_2) ) + (-1.24*ur_2) + (2.16*ur_3 + sin(ur_3) ) = 0;
	w_ode_1_2*20 + (-2.10*w_ode_1_1 + sin(w_ode_1_1) ) + (1.63*x_1 + sin(x_1) ) + (2.59*x_1 + sin(x_1) ) - (2.05*x_1) = 0;
	der(x_1) = (1.58*w_ode_1_1 + sin(w_ode_1_1) ) + (-2.51*w_ode_1_2 + sin(w_ode_1_2) ) + (2.15*x_1 + sin(x_1) ) - (2.19*x_1 + sin(x_1) ) - (-2.89*x_1) + (2.99*ur_1 + sin(ur_1) ) + (-2.34*ur_3 + sin(ur_3) ) + (-1.23*ur_2);	
 end Unsolved_blocks2;
 
 
  model Unsolved_blocks3
 	function F
		input Real x;
		output Real a;
	algorithm
		a := x^2;
	end F;
	Real x(start=5);
	Real y(start=10);
	Real a(start=15);
	equation
		x = F(x);
		der(y) = x*a;
		der(a) = x*y;
 end Unsolved_blocks3;
  
  
 model Unsolved_blocks4
 	function F
		input Real x;
		input Real y;
		output Real a;
		output Real b;
	algorithm
		a := x*2*x;
		b := y*4*x;
	end F;
	Real x(start=5);
	Real y(start=10);
	Real a(start=15);
	equation
		(x,y)  = F(x,y);
		der(a) = x+y;
 end Unsolved_blocks4;
  
  
 model Unsolved_blocks5
 	function F
		input Real x;
		input Real y;
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2*x;
		b := y*4*x;
		c := y*4*x;
	end F;
	Real x(start=5);
	Real y(start=10);
	Real a(start=15);
	equation
		(x,y)  = F(x,y);
		der(a) = x+y;
 end Unsolved_blocks5;
 
 model Unsolved_blocks6
	function F
			input Real x1;
			input Real x2;
			input Real x3;
			input Real x4;
			output Real a;
			output Real b;
			output Real c;
			output Real d;
		algorithm
			a := cos(x1)+0.1;
			b := tan(x2)+0.1;
			c := sin(x3)+0.1;
			d := x4^2+0.1;
		end F;
		Real x1(start=.1);
		Real x2(start=.2);
		Real x3(start=.3);
		Real x4(start=.4);
		Real e(start=1);
		Real f(start=2);
		Real g(start=3);
		output Real Y;
	equation
		(x1,x2,x3,x4) = F(x1,x2,x3,x4);
		der(e) = (x1*x2 + 2)*e;
		der(f) = sin(x2*x3)*f;
		der(g) = cos(x1*x2*x3*x4 + 3)*g+e+f;
		der(Y) = x1+x2+x3+x4+e+f+g;
 end Unsolved_blocks6;
 
 model Unsolved_blocks_torn_1
  Real x_1(start=1.29533105933, nominal=1e-3);
  output Real w_ode_1_1(nominal=1e-3);
  Real w_ode_1_2;
  input Real ur_1;
  input Real ur_2;
  input Real ur_3;
equation
	w_ode_1_1*20 + (1.30*w_ode_1_2 + sin(w_ode_1_2) ) + (-2.01*x_1 + sin(x_1) ) + (-1.18*x_1) + (1.45*x_1) + (1.09*ur_2 + sin(ur_2) ) + (-1.24*ur_2) + (2.16*ur_3 + sin(ur_3) ) = 0;
	w_ode_1_2*20 + (-2.10*w_ode_1_1 + sin(w_ode_1_1) ) + (1.63*x_1 + sin(x_1) ) + (2.59*x_1 + sin(x_1) ) - (2.05*x_1) = 0;
	der(x_1) = (1.58*w_ode_1_1 + sin(w_ode_1_1) ) + (-2.51*w_ode_1_2 + sin(w_ode_1_2) ) + (2.15*x_1 + sin(x_1) ) - (2.19*x_1 + sin(x_1) ) - (-2.89*x_1) + (2.99*ur_1 + sin(ur_1) ) + (-2.34*ur_3 + sin(ur_3) ) + (-1.23*ur_2);		 
 end Unsolved_blocks_torn_1;
 
 model Unsolved_blocks_torn_2
	 function F
			input Real x1;
			input Real x2;
			input Real x3;
			input Real x4;
			output Real a;
			output Real b;
			output Real c;
			output Real d;
		algorithm
			a := cos(x1)+0.1;
			b := cos(x2);
			c := x3*x3;
			d := x4^3;
		end F;
		Real x1(start=.1);
		Real x2(start=.2);
		Real x3(start=.3);
		Real x4(start=.4);
		Real e(start=1);
		Real f(start=2);
		Real g(start=3);
		output Real Y;
	equation
		(x1,x2,x3,x4) = F(x1,x2,x3,x4);
		der(e) = (x1*x2 + 2)*e;
		der(f) = sin(x2*x3)*f;
		der(g) = (x1*x2*x3*x4 + 3)*g+e+f;
		der(Y) = x1+x2+x3+x4+e+f+g;
 end Unsolved_blocks_torn_2;
 
 
  model JacTestInput
	Real x(start=1);
	input Real u;
  equation
	der(x) = if(u>5) then x else u;
  
  end JacTestInput;
  
  
  model JacTestRecord1
	record Complex 
		Real re;
		Real im;
	end Complex;
	
	function add
		input Complex u, v;
		output Complex w;
	algorithm
		w := Complex(u.re - v.re,u.im - v.re);
	end add;
		Complex c1, c2;
		Real x(start=10);
		Real y(start=0.78);
	equation
		c1 = Complex(re = cos(y+time),im = 2.0);
		c2 = add(c1,Complex(4, time)); 
		y  = c1.re+0.1;
		der(x) = x*y;

  end JacTestRecord1;
 
 model JacTestArray1
	Real A[2,2] (start={{1,2},{4,5}});
	Real X[2,2] = {{0.1,0.5},{0.3,0.2}};
	Real dx[1,2] (start={{4,5}});
	function f
		input  Real A[2,2];
		input  Real X[2,2];
		output Real B[2,2];
	algorithm
		B := A*X;
	end f;
equation
	der(A)  = -f(A,X);
	der(dx) = -dx*A;
  end  JacTestArray1;
  
end JacGenTests;
