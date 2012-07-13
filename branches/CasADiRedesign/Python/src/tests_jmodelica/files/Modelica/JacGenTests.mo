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
  
  model JacTestAbs1
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
  end JacTestAbs1; 
  
  model JacTestAbs2
    Real x1(start=1);
    Real x2(start=5);
	Real x3(start=-5);
    input Real u;
    output Real y;
  equation
    der(x1) = abs(x1);
    der(x2) = abs(x2);
	der(x3) = abs(x3);
    y =   abs(x1);
  end JacTestAbs2;  
  
  // TODO: incorporate these tests, the first one is fine, the other one fails.
   model JacTestAbs2
    Real x1(start=-2);
    Real x2(start=3);
  equation
    0 = abs(x1) + x2;
    der(x1) = abs(x2);
  end JacTestAbs2;
  
    model JacTest2
    Real x1(start=2);
    Real x2(start=3);
  equation
    0 = x1 + abs(x2);
    der(x1) = x2;
  end JacTest2;
  
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
  
  
   model Unsolved_blocks1
	Real x(start=.5);
	Real y(start=10);
	Real a(start=15);
	output Real b(start=2);
	equation
		x = sin(x);
		0 = a+y;
		der(y) = a+x;
		der(b) = a+log(x*y);
 end Unsolved_blocks1;
 
 
  model Unsolved_blocks2
	Real x(start=5);
	Real y(start=10);
	Real a(start=15);
	equation
		a = 2*a+y;
		der(y) = a+x;
		der(x) = a;
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
		der(a) = log(x*y);
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
			a := sin(x1);
			b := cos(x1);
			c := tan(x2);
			d := sin(x3);
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
		der(e) = log(x1*x2)*e;
		der(f) = sin(x2*x3)*f;
		der(g) = log(x1*x2*x3*x4)*g+e+f;
		der(Y) = x1+x2+x3+x4+e+f+g;
 end Unsolved_blocks6;
 
 
  model JacTestInput
	Real x(start=1);
	input Real u;
  equation
	der(x) = if(u>5) then x else u;
  
  end JacTestInput;
  
  
end JacGenTests;