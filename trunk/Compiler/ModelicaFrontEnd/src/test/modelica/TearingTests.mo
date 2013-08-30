/*
    Copyright (C) 2009-2011 Modelon AB

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


package TearingTests

model Test1
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
			name="Test1",
			description="Test of tearing",
			equation_sorting=true,
			automatic_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  i1
  u1
  u2
Iteration variables:
  i2()
  i3()
Solved equations:
  i1 = i2 + i3
  u1 = R1 * i1
  u0 = u1 + u2
Residual equations:
 Iteration variables: i2
  u2 = R3 * i3
 Iteration variables: i3
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
  end Test1;

model WarningTest1
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
		WarningTestCase(
			name="WarningTest1",
			description="",
			equation_sorting=true,
			automatic_tearing=true,
			errorMessage="
2 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
At line 0, column 0:
  Iteration variable \"i2\" is missing start value!
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
At line 0, column 0:
  Iteration variable \"i3\" is missing start value!
")})));
end WarningTest1;

model WarningTest2
	Real u0,u1,u2,u3,uL;
	Real i0,i1,i2(start=1),i3,iL;
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
		WarningTestCase(
			name="WarningTest2",
			description="",
			equation_sorting=true,
			automatic_tearing=true,
			errorMessage="
1 errors found:
Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
At line 0, column 0:
  Iteration variable \"i3\" is missing start value!
")})));
end WarningTest2;

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
			variability_propagation=false,
			inline_functions="none",
			automatic_tearing=true,
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
  (TearingTests.RecordTearingTest1.R(r.x, r.y)) = TearingTests.RecordTearingTest1.F(x, y)
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
			description="Test of record tearing",
			equation_sorting=true,
			automatic_tearing=true,
			inline_functions="none",
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  y
Solution:
  sin(time)
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  r.x
Iteration variables:
  x()
Solved equations:
  (TearingTests.RecordTearingTest2.R(r.x, r.y)) = TearingTests.RecordTearingTest2.F(x, y)
Residual equations:
 Iteration variables: x
  (TearingTests.RecordTearingTest2.R(r.x, r.y)) = TearingTests.RecordTearingTest2.F(x, y)
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
			automatic_tearing=true,
			inline_functions="none",
			description="Test of record tearing",
			methodResult="
-------------------------------
Torn block of 2 iteration variables and 0 solved variables.
Solved variables:
Iteration variables:
  y()
  x()
Solved equations:
Residual equations:
 Iteration variables: y
                      x
  (x, y) = TearingTests.RecordTearingTest3.F(y, x)
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
			automatic_tearing=true,
			inline_functions="none",
			description="Test of record tearing",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  x
  y
Iteration variables:
  v()
Solved equations:
  (x, y) = TearingTests.RecordTearingTest4.F(v, v)
Residual equations:
 Iteration variables: v
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
			automatic_tearing=true,
			inline_functions="none",
			description="Test of record tearing",
			methodResult="
-------------------------------
Torn block of 3 iteration variables and 3 solved variables.
Solved variables:
  c
  d
  e
Iteration variables:
  f()
  a()
  b()
Solved equations:
  (c, d) = TearingTests.RecordTearingTest5.F(a, b)
  (e, f) = TearingTests.RecordTearingTest5.F(c, d)
Residual equations:
 Iteration variables: f
  (e, f) = TearingTests.RecordTearingTest5.F(c, d)
 Iteration variables: a
                      b
  (a, b) = TearingTests.RecordTearingTest5.F(e, f)
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
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(iterationVariable=i3)));
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
			description="Test of hand guided tearing",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
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
  u0 = u1 + u3 annotation(__Modelon(ResidualEquation(iterationVariable=i2)));
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3 annotation(__Modelon(ResidualEquation(iterationVariable=i1)));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing2",
			description="Test of hand guided tearing",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 iteration variables and 2 solved variables.
Solved variables:
  u2
  u1
Iteration variables:
  i2()
  i1()
  i3()
Solved equations:
  u2 = R2 * i2
  u1 = R1 * i1
Residual equations:
 Iteration variables: i2
  u0 = u1 + u2
 Iteration variables: i1
  i1 = i2 + i3
 Iteration variables: i3
  u2 = R3 * i3
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
  (- uL) / (- L)
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
  u0 = u1 + u3 annotation(__Modelon(ResidualEquation(iterationVariable=i2)));
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3 annotation(__Modelon(ResidualEquation(iterationVariable=i3)));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing3",
			description="Test of hand guided tearing",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 3 iteration variables and 2 solved variables.
Solved variables:
  u2
  u1
Iteration variables:
  i2()
  i3()
  i1()
Solved equations:
  u2 = R3 * i3
  u1 = R1 * i1
Residual equations:
 Iteration variables: i2
  u0 = u1 + u2
 Iteration variables: i3
  i1 = i2 + i3
 Iteration variables: i1
  u2 = R2 * i2
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
  (- uL) / (- L)
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
  Real i3 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
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
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing, unmatched variable and equation",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
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
  Real i4 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  i3 = i4;
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
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
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing, unmatched variable and equation, alias variable",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i4()
  i2()
Solved equations:
  u2 = R3 * i4
  u0 = u1 + u2
  i1 = i2 + i4
Residual equations:
 Iteration variables: i4
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing5;

model HandGuidedTearing6
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,iL;
  Real i3 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=true)));
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
			name="HandGuidedTearing6",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to true",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing6;

model HandGuidedTearing7
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=false)));
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
			name="HandGuidedTearing7",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to false",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  i1
  u1
  u2
Iteration variables:
  i2()
  i3()
Solved equations:
  i1 = i2 + i3
  u1 = R1 * i1
  u0 = u1 + u2
Residual equations:
 Iteration variables: i2
  u2 = R3 * i3
 Iteration variables: i3
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing7;

model HandGuidedTearing8
  parameter Boolean isResidual = true;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,iL;
  Real i3 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=isResidual)));
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
			name="HandGuidedTearing8",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to true through a parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing8;

model HandGuidedTearing9
  parameter Boolean isResidual = false;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(enabled=isResidual)));
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
			name="HandGuidedTearing9",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with enable set to false through a parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  i1
  u1
  u2
Iteration variables:
  i2()
  i3()
Solved equations:
  i1 = i2 + i3
  u1 = R1 * i1
  u0 = u1 + u2
Residual equations:
 Iteration variables: i2
  u2 = R3 * i3
 Iteration variables: i3
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
")})));
end HandGuidedTearing9;

model HandGuidedTearing10
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable));
  Real i3 annotation(__Modelon(IterationVariable));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="HandGuidedTearing10",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables and only one equation, should give error.",
			errorMessage="
1 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 0, column 0:
  Unable to apply hand-guided tearing selections on block 2. The number of unmatched hand guided equations and variables are not equal.
  Unmatched hand guided equations(1):
    u1 = R1 * i1

  Unmatched hand guided variables(2):
    i3
    i2
")})));
end HandGuidedTearing10;

model HandGuidedTearing11
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=true)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=false)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
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
			name="HandGuidedTearing11",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i2()
  i3()
Solved equations:
  u2 = R2 * i2
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i2
  u1 = R1 * i1
 Iteration variables: i3
  u2 = R3 * i3
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing11;

model HandGuidedTearing12
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=false)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=true)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
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
			name="HandGuidedTearing12",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing12;

model HandGuidedTearing13
  parameter Boolean isIteration = true;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=isIteration)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=not isIteration)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
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
			name="HandGuidedTearing13",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables, set through parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i2()
  i3()
Solved equations:
  u2 = R2 * i2
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i2
  u1 = R1 * i1
 Iteration variables: i3
  u2 = R3 * i3
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing13;

model HandGuidedTearing14
  parameter Boolean isIteration = false;
  Real u0,u1,u2,u3,uL;
  Real i0,i1,iL;
  Real i2 annotation(__Modelon(IterationVariable(enabled=isIteration)));
  Real i3 annotation(__Modelon(IterationVariable(enabled=not isIteration)));
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation));
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
			name="HandGuidedTearing14",
			methodName="printDAEBLT",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			description="Test of hand guided tearing with annotation on two iteration variables, set through parameter",
			methodResult="
-------------------------------
Solved block of 1 variables:
Computed variable:
  u0
Solution:
  sin(time)
-------------------------------
Torn block of 2 iteration variables and 3 solved variables.
Solved variables:
  u2
  u1
  i1
Iteration variables:
  i3()
  i2()
Solved equations:
  u2 = R3 * i3
  u0 = u1 + u2
  i1 = i2 + i3
Residual equations:
 Iteration variables: i3
  u1 = R1 * i1
 Iteration variables: i2
  u2 = R2 * i2
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
  (- uL) / (- L)
-------------------------------
Solved block of 1 variables:
Computed variable:
  i0
Solution:
  i1 + iL
-------------------------------
      ")})));
end HandGuidedTearing14;

model HandGuidedTearing15

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3;
	end for;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing15",
			description="Test of hand guided tearing of vectors and indices whit no annotation, base case.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[1]
  a[1]
Iteration variables:
  b[1]()
Solved equations:
  c[1] = b[1] - 3
  a[1] = c[1] + 1
Residual equations:
 Iteration variables: b[1]
  a[1] = b[1] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[2]
  a[2]
Iteration variables:
  b[2]()
Solved equations:
  c[2] = b[2] - 3
  a[2] = c[2] + 1
Residual equations:
 Iteration variables: b[2]
  a[2] = b[2] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[3]
  a[3]
Iteration variables:
  b[3]()
Solved equations:
  c[3] = b[3] - 3
  a[3] = c[3] + 1
Residual equations:
 Iteration variables: b[3]
  a[3] = b[3] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[4]
  a[4]
Iteration variables:
  b[4]()
Solved equations:
  c[4] = b[4] - 3
  a[4] = c[4] + 1
Residual equations:
 Iteration variables: b[4]
  a[4] = b[4] + 2
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  c[5]
  a[5]
Iteration variables:
  b[5]()
Solved equations:
  c[5] = b[5] - 3
  a[5] = c[5] + 1
Residual equations:
 Iteration variables: b[5]
  a[5] = b[5] + 2
-------------------------------
")})));
end HandGuidedTearing15;

model HandGuidedTearing16

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3 annotation(__Modelon(ResidualEquation(enabled=true,iterationVariable=c[i])));
	end for;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing16",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] + 1
  a[1] = b[1] + 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  b[2]
Iteration variables:
  c[2]()
Solved equations:
  a[2] = c[2] + 1
  a[2] = b[2] + 2
Residual equations:
 Iteration variables: c[2]
  c[2] = b[2] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  b[3]
Iteration variables:
  c[3]()
Solved equations:
  a[3] = c[3] + 1
  a[3] = b[3] + 2
Residual equations:
 Iteration variables: c[3]
  c[3] = b[3] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[4]
  b[4]
Iteration variables:
  c[4]()
Solved equations:
  a[4] = c[4] + 1
  a[4] = b[4] + 2
Residual equations:
 Iteration variables: c[4]
  c[4] = b[4] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[5]
  b[5]
Iteration variables:
  c[5]()
Solved equations:
  a[5] = c[5] + 1
  a[5] = b[5] + 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] - 3
-------------------------------
")})));
end HandGuidedTearing16;

model HandGuidedTearing17

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3 annotation(__Modelon(ResidualEquation(enabled=true,iterationVariable=c[i])));
	end for;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing17",
			description="Test of hand guided tearing of vectors and indices with handguided annotation and blt merge.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 5 iteration variables and 10 solved variables.
Solved variables:
  a[1]
  b[1]
  a[2]
  b[2]
  a[3]
  b[3]
  a[4]
  b[4]
  a[5]
  b[5]
Iteration variables:
  c[5]()
  c[4]()
  c[3]()
  c[2]()
  c[1]()
Solved equations:
  a[1] = c[1] + 1
  a[1] = b[1] + 2
  a[2] = c[2] + 1
  a[2] = b[2] + 2
  a[3] = c[3] + 1
  a[3] = b[3] + 2
  a[4] = c[4] + 1
  a[4] = b[4] + 2
  a[5] = c[5] + 1
  a[5] = b[5] + 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] - 3
 Iteration variables: c[4]
  c[4] = b[4] - 3
 Iteration variables: c[3]
  c[3] = b[3] - 3
 Iteration variables: c[2]
  c[2] = b[2] - 3
 Iteration variables: c[1]
  c[1] = b[1] - 3
-------------------------------
")})));
end HandGuidedTearing17;

model HandGuidedTearing18
	model A
		Real x;
		Real y;
	equation
		x = y + 1 annotation(__Modelon(name=eq));
	end A;
	
	model B
		Real x;
		Real y;
	equation
		x = y + 2;
	end B;
	
	A a;
	B b;
equation
	a.x = b.y + 2;
	a.y = b.x - 3;
	annotation(__Modelon(tearingPairs={
		Pair(residualEquation=a.eq, iterationVariable=b.x)
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing18",
			description="Test of hand guided tearing with pairs defined on system level.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  a.y
  b.y
  a.x
Iteration variables:
  b.x()
Solved equations:
  a.y = b.x - 3
  b.x = b.y + 2
  a.x = b.y + 2
Residual equations:
 Iteration variables: b.x
  a.x = a.y + 1
-------------------------------
")})));
end HandGuidedTearing18;

model HandGuidedTearing19
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(residualEquation=a.eq, iterationVariable=b.x)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing19",
			description="Test of hand guided tearing with pairs defined on system level, but in sub class.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing19;

model HandGuidedTearing20
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq, ResidualEquation(iterationVariable=x)));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(residualEquation=a.eq, iterationVariable=b.x)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing20",
			description="Test of hand guided tearing with pairs defined on system level and in sub class.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing20;

model HandGuidedTearing21
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
			annotation(__Modelon(tearingPairs={
				Pair(residualEquation=eq, iterationVariable=x)
			}));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(residualEquation=a.eq, iterationVariable=b.x)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing21",
			description="Test of hand guided tearing with pairs defined on system level and sub class.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing21;

model HandGuidedTearing22
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		parameter Boolean useFirst = true;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(enabled=useFirst, residualEquation=a.eq, iterationVariable=b.x),
			Pair(enabled=not useFirst, residualEquation=a.eq, iterationVariable=b.y)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing22",
			description="Test of hand guided tearing with pairs defined on system level.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.a.y
  c.b.y
  c.a.x
Iteration variables:
  c.b.x()
Solved equations:
  c.a.y = c.b.x - 3
  c.b.x = c.b.y + 2
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.x
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing22;

model HandGuidedTearing23
	model C
		model A
			Real x;
			Real y;
		equation
			x = y + 1 annotation(__Modelon(name=eq));
		end A;
		
		model B
			Real x;
			Real y;
		equation
			x = y + 2;
		end B;
		
		parameter Boolean useFirst = false;
		
		A a;
		B b;
	equation
		a.x = b.y + 2;
		a.y = b.x - 3;
		annotation(__Modelon(tearingPairs={
			Pair(enabled=useFirst, residualEquation=a.eq, iterationVariable=b.x),
			Pair(enabled=not useFirst, residualEquation=a.eq, iterationVariable=b.y)
		}));
	end C;
	C c;

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing23",
			description="Test of hand guided tearing with pairs defined on system level.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			merge_blt_blocks=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 3 solved variables.
Solved variables:
  c.b.x
  c.a.y
  c.a.x
Iteration variables:
  c.b.y()
Solved equations:
  c.b.x = c.b.y + 2
  c.a.y = c.b.x - 3
  c.a.x = c.b.y + 2
Residual equations:
 Iteration variables: c.b.y
  c.a.x = c.a.y + 1
-------------------------------
")})));
end HandGuidedTearing23;

model HandGuidedTearing24

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	a=c .+ 1;
	a=b .+ 2;
	c=b .- 3 annotation(__Modelon(ResidualEquation(enabled=true,iterationVariable=c)));

	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing24",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] .+ 1
  a[1] = b[1] .+ 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  b[2]
Iteration variables:
  c[2]()
Solved equations:
  a[2] = c[2] .+ 1
  a[2] = b[2] .+ 2
Residual equations:
 Iteration variables: c[2]
  c[2] = b[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  b[3]
Iteration variables:
  c[3]()
Solved equations:
  a[3] = c[3] .+ 1
  a[3] = b[3] .+ 2
Residual equations:
 Iteration variables: c[3]
  c[3] = b[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[4]
  b[4]
Iteration variables:
  c[4]()
Solved equations:
  a[4] = c[4] .+ 1
  a[4] = b[4] .+ 2
Residual equations:
 Iteration variables: c[4]
  c[4] = b[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[5]
  b[5]
Iteration variables:
  c[5]()
Solved equations:
  a[5] = c[5] .+ 1
  a[5] = b[5] .+ 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] .- 3
-------------------------------
")})));
end HandGuidedTearing24;

model HandGuidedTearing25

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	a=c .+ 1;
	a=b .+ 2;
	c=b .- 3 annotation(__Modelon(name=res));
	annotation(
	__Modelon(tearingPairs={Pair(residualEquation=res,iterationVariable=c)}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing25",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] .+ 1
  a[1] = b[1] .+ 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  b[2]
Iteration variables:
  c[2]()
Solved equations:
  a[2] = c[2] .+ 1
  a[2] = b[2] .+ 2
Residual equations:
 Iteration variables: c[2]
  c[2] = b[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  b[3]
Iteration variables:
  c[3]()
Solved equations:
  a[3] = c[3] .+ 1
  a[3] = b[3] .+ 2
Residual equations:
 Iteration variables: c[3]
  c[3] = b[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[4]
  b[4]
Iteration variables:
  c[4]()
Solved equations:
  a[4] = c[4] .+ 1
  a[4] = b[4] .+ 2
Residual equations:
 Iteration variables: c[4]
  c[4] = b[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[5]
  b[5]
Iteration variables:
  c[5]()
Solved equations:
  a[5] = c[5] .+ 1
  a[5] = b[5] .+ 2
Residual equations:
 Iteration variables: c[5]
  c[5] = b[5] .- 3
-------------------------------
")})));
end HandGuidedTearing25;

model HandGuidedTearing26
	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];
equation
	a=c .+ 1;
	a=b .+ 2;
	c=b .- 3 annotation(__Modelon(name=res));
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=res[1],iterationVariable=c[1]),
		Pair(residualEquation=res[2:3],iterationVariable=b[2:3]),
		Pair(residualEquation=res[4:5],iterationVariable=a[4:5])
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing26",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] .+ 1
  a[1] = b[1] .+ 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  c[2]
Iteration variables:
  b[2]()
Solved equations:
  a[2] = b[2] .+ 2
  a[2] = c[2] .+ 1
Residual equations:
 Iteration variables: b[2]
  c[2] = b[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  c[3]
Iteration variables:
  b[3]()
Solved equations:
  a[3] = b[3] .+ 2
  a[3] = c[3] .+ 1
Residual equations:
 Iteration variables: b[3]
  c[3] = b[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[4]
  c[4]
Iteration variables:
  a[4]()
Solved equations:
  a[4] = b[4] .+ 2
  a[4] = c[4] .+ 1
Residual equations:
 Iteration variables: a[4]
  c[4] = b[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[5]
  c[5]
Iteration variables:
  a[5]()
Solved equations:
  a[5] = b[5] .+ 2
  a[5] = c[5] .+ 1
Residual equations:
 Iteration variables: a[5]
  c[5] = b[5] .- 3
-------------------------------
")})));
end HandGuidedTearing26;

model HandGuidedTearing27

	parameter Integer n = 5;
	Real a[n];
	Real b[n];
	Real c[n];

equation
	for i in 1:n loop
		a[i]=c[i] + 1;
		a[i]=b[i] + 2;
		c[i]=b[i] - 3 annotation(__Modelon(name=res));
	end for;
	
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=res[1],iterationVariable=c[1]),
		Pair(residualEquation=res[2:3],iterationVariable=b[2:3]),
		Pair(residualEquation=res[4:5],iterationVariable=a[4:5])
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing27",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[1]
  b[1]
Iteration variables:
  c[1]()
Solved equations:
  a[1] = c[1] + 1
  a[1] = b[1] + 2
Residual equations:
 Iteration variables: c[1]
  c[1] = b[1] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[2]
  c[2]
Iteration variables:
  b[2]()
Solved equations:
  a[2] = b[2] + 2
  a[2] = c[2] + 1
Residual equations:
 Iteration variables: b[2]
  c[2] = b[2] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a[3]
  c[3]
Iteration variables:
  b[3]()
Solved equations:
  a[3] = b[3] + 2
  a[3] = c[3] + 1
Residual equations:
 Iteration variables: b[3]
  c[3] = b[3] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[4]
  c[4]
Iteration variables:
  a[4]()
Solved equations:
  a[4] = b[4] + 2
  a[4] = c[4] + 1
Residual equations:
 Iteration variables: a[4]
  c[4] = b[4] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b[5]
  c[5]
Iteration variables:
  a[5]()
Solved equations:
  a[5] = b[5] + 2
  a[5] = c[5] + 1
Residual equations:
 Iteration variables: a[5]
  c[5] = b[5] - 3
-------------------------------
")})));
end HandGuidedTearing27;

model HandGuidedTearing28
	model A
		parameter Integer n = 5;
		Real a[n];
		Real b[n];
		Real c[n];
	
	equation
		for i in 1:n loop
			a[i]=c[i] + 1;
			a[i]=b[i] + 2;
			c[i]=b[i] - 3 annotation(__Modelon(name=res));
		end for;
	end A;
	
	A a;
	
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=a.res,iterationVariable=a.c)
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing28",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[1]
  a.b[1]
Iteration variables:
  a.c[1]()
Solved equations:
  a.a[1] = a.c[1] + 1
  a.a[1] = a.b[1] + 2
Residual equations:
 Iteration variables: a.c[1]
  a.c[1] = a.b[1] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[2]
  a.b[2]
Iteration variables:
  a.c[2]()
Solved equations:
  a.a[2] = a.c[2] + 1
  a.a[2] = a.b[2] + 2
Residual equations:
 Iteration variables: a.c[2]
  a.c[2] = a.b[2] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[3]
  a.b[3]
Iteration variables:
  a.c[3]()
Solved equations:
  a.a[3] = a.c[3] + 1
  a.a[3] = a.b[3] + 2
Residual equations:
 Iteration variables: a.c[3]
  a.c[3] = a.b[3] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[4]
  a.b[4]
Iteration variables:
  a.c[4]()
Solved equations:
  a.a[4] = a.c[4] + 1
  a.a[4] = a.b[4] + 2
Residual equations:
 Iteration variables: a.c[4]
  a.c[4] = a.b[4] - 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.a[5]
  a.b[5]
Iteration variables:
  a.c[5]()
Solved equations:
  a.a[5] = a.c[5] + 1
  a.a[5] = a.b[5] + 2
Residual equations:
 Iteration variables: a.c[5]
  a.c[5] = a.b[5] - 3
-------------------------------
")})));
end HandGuidedTearing28;

model HandGuidedTearing29
	model A
		B b;
		annotation(
		__Modelon(tearingPairs={
			Pair(residualEquation=b.res[1],iterationVariable=b.x[1]),
			Pair(residualEquation=b.res[2],iterationVariable=b.z[2])
		}));
	end A;
	model B
		parameter Integer n = 5;
		Real x[n];
		Real y[n];
		Real z[n];
	equation
		x=z .+ 1;
		x=y .+ 2;
		z=y .- 3 annotation(__Modelon(name=res));
		annotation(
		__Modelon(tearingPairs={
			Pair(residualEquation=res[1],iterationVariable=z[1]),
			Pair(residualEquation=res[2:3],iterationVariable=y[2:3])
		}));
	end B;
	A a;
	annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=a.b.res[1],iterationVariable=a.b.y[1]),
		Pair(residualEquation=a.b.res[4:5],iterationVariable=a.b.x[4:5])
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing29",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.x[1]
  a.b.z[1]
Iteration variables:
  a.b.y[1]()
Solved equations:
  a.b.x[1] = a.b.y[1] .+ 2
  a.b.x[1] = a.b.z[1] .+ 1
Residual equations:
 Iteration variables: a.b.y[1]
  a.b.z[1] = a.b.y[1] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.x[2]
  a.b.y[2]
Iteration variables:
  a.b.z[2]()
Solved equations:
  a.b.x[2] = a.b.z[2] .+ 1
  a.b.x[2] = a.b.y[2] .+ 2
Residual equations:
 Iteration variables: a.b.z[2]
  a.b.z[2] = a.b.y[2] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.x[3]
  a.b.z[3]
Iteration variables:
  a.b.y[3]()
Solved equations:
  a.b.x[3] = a.b.y[3] .+ 2
  a.b.x[3] = a.b.z[3] .+ 1
Residual equations:
 Iteration variables: a.b.y[3]
  a.b.z[3] = a.b.y[3] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.y[4]
  a.b.z[4]
Iteration variables:
  a.b.x[4]()
Solved equations:
  a.b.x[4] = a.b.y[4] .+ 2
  a.b.x[4] = a.b.z[4] .+ 1
Residual equations:
 Iteration variables: a.b.x[4]
  a.b.z[4] = a.b.y[4] .- 3
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  a.b.y[5]
  a.b.z[5]
Iteration variables:
  a.b.x[5]()
Solved equations:
  a.b.x[5] = a.b.y[5] .+ 2
  a.b.x[5] = a.b.z[5] .+ 1
Residual equations:
 Iteration variables: a.b.x[5]
  a.b.z[5] = a.b.y[5] .- 3
-------------------------------
")})));
end HandGuidedTearing29;

model HandGuidedTearing30
	model B
		Real x, y;
	equation
		x = y + 1 annotation(__Modelon(name=res));
		y = x - 1;
	end B;
	extends B;
annotation(
	__Modelon(tearingPairs={
		Pair(residualEquation=res, iterationVariable=x)
	}),
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing30",
			description="Test of hand guided tearing of vectors and indices with hand guided annotation.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  y
Iteration variables:
  x()
Solved equations:
  y = x - 1
Residual equations:
 Iteration variables: x
  x = y + 1
-------------------------------
")})));
end HandGuidedTearing30;

model HandGuidedTearing31
	Real x[2](each start=1), y[2](each start=2), z[2];
equation
	x = -y;
	y = z .+ 1 annotation(__Modelon(ResidualEquation(iterationVariable=y)));
	z = x .- 1;
annotation(
	__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			name="HandGuidedTearing31",
			description="Test of hand guided tearing and alias elimination.",
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  z[1]
Iteration variables:
  y[1](start=2)
Solved equations:
  z[1] = - y[1] .- 1
Residual equations:
 Iteration variables: y[1]
  y[1] = z[1] .+ 1
-------------------------------
Torn block of 1 iteration variables and 1 solved variables.
Solved variables:
  z[2]
Iteration variables:
  y[2](start=2)
Solved equations:
  z[2] = - y[2] .- 1
Residual equations:
 Iteration variables: y[2]
  y[2] = z[2] .+ 1
-------------------------------
")})));
end HandGuidedTearing31;

model HandGuidedTearingError1
	Real x;
	Real y;
	Real z annotation(__Modelon(IterationVariable(enabled=1)));
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(enabled=1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=x, residualEquation=res, enabled=1)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError1",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8432, column 56:
  Cannot evaluate boolean enabled expression: 1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8436, column 56:
  Cannot evaluate boolean enabled expression: 1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8439, column 59:
  Cannot evaluate boolean enabled expression: 1
")})));
end HandGuidedTearingError1;

model HandGuidedTearingError2
	Real x;
	Real y;
	Real z annotation(__Modelon(IterationVariable(enabled=unknownParameter1)));
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(enabled=unknownParameter2)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=x, residualEquation=res, enabled=unknownParameter3)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError2",
			description="Test hand guided tearing errors",
			errorMessage="
6 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8464, column 56:
  Cannot evaluate boolean enabled expression: unknownParameter1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8464, column 56:
  Cannot find class or component declaration for unknownParameter1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8468, column 56:
  Cannot evaluate boolean enabled expression: unknownParameter2

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8468, column 56:
  Cannot find class or component declaration for unknownParameter2

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8471, column 59:
  Cannot evaluate boolean enabled expression: unknownParameter3

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8471, column 59:
  Cannot find class or component declaration for unknownParameter3
")})));
end HandGuidedTearingError2;

model HandGuidedTearingError3
	Real x;
	Real y;
	Real z;
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=2, residualEquation=3)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError3",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8504, column 66:
  Expression \"1\" is not a legal iteration variable reference

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8507, column 26:
  Expression \"2\" is not a legal iteration variable reference

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8507, column 46:
  Expression \"3\" is not a legal residual equation reference
")})));
end HandGuidedTearingError3;

model HandGuidedTearingError4
	Real x;
	Real y;
	Real z;
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=unknownVariable1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=unknownVariable2, residualEquation=unknownEquation)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError4",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8532, column 66:
  Cannot find class or component declaration for unknownVariable1

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8535, column 26:
  Cannot find class or component declaration for unknownVariable2

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8535, column 61:
  Cannot find equation declaration for unknownEquation
")})));
end HandGuidedTearingError4;

model HandGuidedTearingError5
	parameter Real p1 = 1;
	parameter Real p2 = 2;
	Real x;
	Real y;
	Real z;
equation
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=p1)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=p2, residualEquation=res)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError5",
			description="Test hand guided tearing errors",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8566, column 2:
  Iteration variable should have continuous variability, p1 has parameter variability

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8569, column 26:
  Iteration variable should have continuous variability, p2 has parameter variability
")})));
end HandGuidedTearingError5;

model HandGuidedTearingError6
	Real x;
	Real y;
	Real z;
	Real v[2];
equation
	v[1] = v[2] + 1;
	x=3 + v[2];
	x=y + 1;
	y=z + 2 annotation(__Modelon(name=res));
	z=x - 3 annotation(__Modelon(ResidualEquation(iterationVariable=v)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=v, residualEquation=res)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError6",
			description="Test hand guided tearing errors",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8597, column 2:
  Size of iteration variable v is not the same size as the surrounding equation, size of variable [2], size of equation scalar

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8599, column 24:
  Size of the iteration variable is not the same size as the size of the residual equation, size of variable [2], size of equation scalar
")})));
end HandGuidedTearingError6;

model HandGuidedTearingError7
	Real x[2];
	Real y[2];
	Real z[2];
	Real v;
equation
	v = 1;
	x=y .+ 1;
	y=z .+ 2 annotation(__Modelon(name=res));
	z=x .- 3 annotation(__Modelon(ResidualEquation(iterationVariable=v)));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=v, residualEquation=res)
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError7",
			description="Test hand guided tearing errors",
			errorMessage="
2 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8627, column 2:
  Size of iteration variable v is not the same size as the surrounding equation, size of variable scalar, size of equation [2]

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8629, column 24:
  Size of the iteration variable is not the same size as the size of the residual equation, size of variable scalar, size of equation [2]
")})));
end HandGuidedTearingError7;

model HandGuidedTearingError8
	Real x[2];
	Real y[2];
	Real z[2];
	Real v[2,2] = {{1,2},{3,4}};
equation
	x=y .+ 1;
	y=z .+ 2 annotation(__Modelon(name=res));
	z=x .- 3 annotation(__Modelon(ResidualEquation(iterationVariable=v[3,:])));
	annotation(
	__Modelon(tearingPairs(
		Pair(iterationVariable=x[3], residualEquation=res[3])
	)),
	__JModelica(UnitTesting(tests={
		ErrorTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingError8",
			description="Test hand guided tearing errors",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8705, column 69:
  Array index out of bounds: 3, index expression: 3

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8708, column 28:
  Array index out of bounds: 3, index expression: 3

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 8708, column 53:
  Array index out of bounds: 3, index expression: 3
")})));
end HandGuidedTearingError8;

model HandGuidedTearingError9
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1 annotation(__Modelon(ResidualEquation(iterationVariable=i3)));
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="HandGuidedTearingError9",
			description="Test of hand guided tearing error when hgt is unable to solve the block",
			equation_sorting=true,
			hand_guided_tearing=true,
			errorMessage="
1 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
Semantic error at line 0, column 0:
  Hand guided tearing selections in block 2 does not result in a torn system. Consider adding additional selections of hand guided equations and variables, or enable automatic tearing.
")})));

end HandGuidedTearingError9;

model HandGuidedTearingWarning1
	Real x(start=1), y(start=2), z;
equation
	x = -y;
	y = z + 1 annotation(__Modelon(ResidualEquation(iterationVariable=y)));
	z = x - 1 annotation(__Modelon(ResidualEquation(iterationVariable=x)));
	annotation(
	__JModelica(UnitTesting(tests={
		WarningTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			name="HandGuidedTearingWarning1",
			description="Test hand guided tearing warnings",
			errorMessage="
2 warnings found:

Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
At line 0, column 0:
  Can not use hand guided tearing pair, equation and variable resides in different blocks. Variable: x. Equation: - x = z + 1

Warning: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TearingTests.mo':
At line 0, column 0:
  Hand guided tearing variable 'y' has been alias eliminated
")})));
end HandGuidedTearingWarning1;

model TearingLocalLoopTest1
	Real a, b, c;
equation
	20 = c * a;
	23 = c * b;
	c = a + b;
	annotation(__JModelica(UnitTesting(tests={
		FClassMethodTestCase(
			equation_sorting=true,
			automatic_tearing=true,
			hand_guided_tearing=true,
			local_iteration_in_tearing=true,
			name="TearingLocalLoopTest1",
			methodName="printDAEBLT",
			methodResult="
-------------------------------
Torn block of 1 iteration variables and 2 solved variables.
Solved variables:
  b()
  a
Iteration variables:
  c()
Solved equations:
 Iteration variables: b
  23 = c * b
  c = a + b
Residual equations:
 Iteration variables: c
  20 = c * a
-------------------------------
")})));
end TearingLocalLoopTest1;

end TearingTests;