/*
    Copyright (C) 2009 Modelon AB

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


package FunctionTests 

/* Functions used in tests. */
function TestFunction0
 output Real o1 = 0;
algorithm
 return;
end TestFunction0;

function TestFunction1
 input Real i1 = 0;
 output Real o1 = i1;
algorithm
end TestFunction1;

function TestFunction2
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = 0;
 output Real o2 = i2;
algorithm
 o1 := i1;
end TestFunction2;

function TestFunction3
 input Real i1;
 input Real i2;
 input Real i3 = 0;
 output Real o1 = i1 + i2 + i3;
 output Real o2 = i2 + i3;
 output Real o3 = i1 + i2;
algorithm
end TestFunction3;

function TestFunctionString
 input String i1;
 output String o1 = i1;
algorithm
end TestFunctionString;

function TestFunctionCallingFunction
 input Real i1;
 output Real o1;
algorithm
 o1 := TestFunction1(i1);
end TestFunctionCallingFunction;

function TestFunctionRecursive
 input Integer i1;
 output Integer o1;
algorithm
 if i1 < 3 then
  o1 := 1;
 else
  o1 := TestFunctionRecursive(i1 - 1) + TestFunctionRecursive(i1 - 2);
 end if;
end TestFunctionRecursive;

function TestFunctionWithConst
 input Real x = 1;
 output Real y = x + A + B + C;
protected
 constant Real A = 1;
 constant Real B = 2;
 constant Real C = 3;
algorithm
end TestFunctionWithConst;


/* Temporary functions for manual C-tests */

function Func00
algorithm
 return;
end Func00;

function Func10
 input Real i1 = 0;
algorithm
 return;
end Func10;

function Func01
 output Real o1 = 0;
algorithm
 return;
end Func01;

function Func11
 input Real i1 = 0;
 output Real o1 = i1;
algorithm
 return;
end Func11;

function Func21
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = i1 + i2;
algorithm
 return;
end Func21;

function Func02
 output Real o1 = 0;
 output Real o2 = 1;
algorithm
 return;
end Func02;

function Func12
 input Real i1 = 0;
 output Real o1 = i1;
 output Real o2 = 1;
algorithm
 return;
end Func12;

function Func22
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = i1 + i2;
 output Real o2 = 1;
algorithm
 for i in 1:3 loop
   o1 := o1 + 1;
   o2 := o2 - o1;
 end for;
 return;
end Func22;


/* ====================== Functions ====================== */

model FunctionFlatten1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionFlatten1",
          description="Flattening functions: simple function call",
          flatModel="
fclass FunctionTests.FunctionFlatten1
 Real x;
equation
 x = FunctionTests.TestFunction1(1);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionFlatten1;
")})));

 Real x;
equation
 x = TestFunction1(1);
end FunctionFlatten1;


model FunctionFlatten2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionFlatten2",
          description="Flattening functions: two calls to same function",
          flatModel="
fclass FunctionTests.FunctionFlatten2
 Real x;
 Real y = FunctionTests.TestFunction2(2, 3);
equation
 x = FunctionTests.TestFunction2(1, 0);

 function FunctionTests.TestFunction2
  input Real i1 := 0;
  input Real i2 := 0;
  output Real o1 := 0;
  output Real o2 := i2;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;
end FunctionTests.FunctionFlatten2;
")})));

 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction2(1);
end FunctionFlatten2;


model FunctionFlatten3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionFlatten3",
          description="Flattening functions: calls to two functions",
          flatModel="
fclass FunctionTests.FunctionFlatten3
 Real x;
 Real y = FunctionTests.TestFunction2(2, 3);
equation
 x = FunctionTests.TestFunction1(( y ) * ( 2 ));

 function FunctionTests.TestFunction2
  input Real i1 := 0;
  input Real i2 := 0;
  output Real o1 := 0;
  output Real o2 := i2;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionFlatten3;
")})));

 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction1(y * 2);
end FunctionFlatten3;


model FunctionFlatten4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionFlatten4",
         description="Flattening functions: function containing constants",
         flatModel="
fclass FunctionTests.FunctionFlatten4
 Real x = FunctionTests.TestFunctionWithConst(2);

 function FunctionTests.TestFunctionWithConst
  input Real x := 1;
  output Real y := x + 1.0 + 2.0 + 3.0;
 algorithm
  return;
 end FunctionTests.TestFunctionWithConst;
end FunctionTests.FunctionFlatten4;
")})));

 Real x = TestFunctionWithConst(2);
end FunctionFlatten4;


model FunctionFlatten5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionFlatten5",
         description="Flattening functions: function called in extended class",
         flatModel="
fclass FunctionTests.FunctionFlatten5
 Real y.x;
equation
 y.x = FunctionTests.TestFunction1(1);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionFlatten5;
")})));

	model A
		Real x;
	equation
		x = TestFunction1(1);
	end A;
	
	model B
		extends A;
	end B;
	
	B y;
end FunctionFlatten5;


model FunctionFlatten6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionFlatten6",
         description="Flattening functions: function called in class modification",
         flatModel="
fclass FunctionTests.FunctionFlatten6
 Real y.x = FunctionTests.TestFunction1(1);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionFlatten6;
")})));

	model A
		Real x;
	end A;
	
	model B = A(x = TestFunction1(1));
	
	B y;
end FunctionFlatten6;


model FunctionFlatten7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionFlatten7",
         description="Calling different inherited versions of same function",
         flatModel="
fclass FunctionTests.FunctionFlatten7
 Real x = FunctionTests.FunctionFlatten7.A.f();
 Real y = FunctionTests.FunctionFlatten7.B.f();
 Real z = FunctionTests.FunctionFlatten7.C.f();

 function FunctionTests.FunctionFlatten7.A.f
  output Real a := 1.0;
 algorithm
  return;
 end FunctionTests.FunctionFlatten7.A.f;

 function FunctionTests.FunctionFlatten7.B.f
  output Real a := 2.0;
 algorithm
  return;
 end FunctionTests.FunctionFlatten7.B.f;

 function FunctionTests.FunctionFlatten7.C.f
  output Real a := 3.0;
 algorithm
  return;
 end FunctionTests.FunctionFlatten7.C.f;
end FunctionTests.FunctionFlatten7;
")})));

	package A
		constant Real c = 1;
		function f
			output Real a = c;
		algorithm
		end f;
	end A;
	
	package B
		extends A(c = 2);
	end B;
	
	package C
		extends A(c = 3);
	end C;
	
	Real x = A.f();
	Real y = B.f();
	Real z = C.f();
end FunctionFlatten7;


model FunctionFlatten8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="FunctionFlatten8",
         description="Calling function from parallel class",
         flatModel="
fclass FunctionTests.FunctionFlatten8
 Real y.x;
equation
 y.x = FunctionTests.FunctionFlatten8.f();

 function FunctionTests.FunctionFlatten8.f
  output Real x := 1;
 algorithm
  return;
 end FunctionTests.FunctionFlatten8.f;
end FunctionTests.FunctionFlatten8;
")})));

	function f
		output Real x = 1;
	algorithm
	end f;
	
	model A
		Real x;
	equation
		x = f();
	end A;
	
	A y;
end FunctionFlatten8;



/* ====================== Function calls ====================== */

model FunctionBinding1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionBinding1",
          description="Binding function arguments: 1 input, use default",
          flatModel="
fclass FunctionTests.FunctionBinding1
 Real x = FunctionTests.TestFunction1(0);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionBinding1;
")})));

 Real x = TestFunction1();
end FunctionBinding1;

model FunctionBinding2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionBinding2",
          description="Binding function arguments: 1 input, 1 arg",
          flatModel="
fclass FunctionTests.FunctionBinding2
 Real x = FunctionTests.TestFunction1(1);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionBinding2;
")})));

 Real x = TestFunction1(1);
end FunctionBinding2;

model FunctionBinding3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding3",
          description="Function call with too many arguments",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction1(): too many positional arguments
")})));
 Real x = TestFunction1(1, 2);
end FunctionBinding3;

model FunctionBinding4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding4",
          description="Function call with too few arguments: no arguments",
          errorMessage=
"
2 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): missing argument for required input i1
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): missing argument for required input i2
")})));

 Real x = TestFunction3();
end FunctionBinding4;

model FunctionBinding5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding5",
          description="Function call with too few arguments: one positional argument",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): missing argument for required input i2
")})));

 Real x = TestFunction3(1);
end FunctionBinding5;

model FunctionBinding6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionBinding6",
          description="Binding function arguments: 3 inputs, 2 args, 1 default",
          flatModel="
fclass FunctionTests.FunctionBinding6
 Real x = FunctionTests.TestFunction3(1, 2, 0);

 function FunctionTests.TestFunction3
  input Real i1;
  input Real i2;
  input Real i3 := 0;
  output Real o1 := i1 + i2 + i3;
  output Real o2 := i2 + i3;
  output Real o3 := i1 + i2;
 algorithm
  return;
 end FunctionTests.TestFunction3;
end FunctionTests.FunctionBinding6;
")})));

 Real x = TestFunction3(1, 2);
end FunctionBinding6;

model FunctionBinding7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionBinding7",
          description="Binding function arguments: 3 inputs, 2 args, 1 default",
          flatModel="
fclass FunctionTests.FunctionBinding7
 Real x = FunctionTests.TestFunction0();

 function FunctionTests.TestFunction0
  output Real o1 := 0;
 algorithm
  return;
 end FunctionTests.TestFunction0;
end FunctionTests.FunctionBinding7;
")})));

 Real x = TestFunction0();
end FunctionBinding7;

model FunctionBinding8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionBinding8",
          description="Binding function arguments: 1 input, 1 named arg",
          flatModel="
fclass FunctionTests.FunctionBinding8
 Real x = FunctionTests.TestFunction1(1);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionBinding8;
")})));

 Real x = TestFunction1(i1=1);
end FunctionBinding8;

model FunctionBinding9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionBinding9",
          description="Binding function arguments: 2 inputs, 2 named arg (inverted order)",
          flatModel="
fclass FunctionTests.FunctionBinding9
 Real x = FunctionTests.TestFunction2(1, 2);

 function FunctionTests.TestFunction2
  input Real i1 := 0;
  input Real i2 := 0;
  output Real o1 := 0;
  output Real o2 := i2;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;
end FunctionTests.FunctionBinding9;
")})));

 Real x = TestFunction2(i2=2, i1=1);
end FunctionBinding9;

model FunctionBinding10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding10",
          description="Function call with too few arguments: missing middle argument",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): missing argument for required input i2
")})));

 Real x = TestFunction3(1, i3=2);
end FunctionBinding10;

model FunctionBinding11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding11",
          description="Function call with named arguments: non-existing input",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): no input matching named argument i3 found
")})));

 Real x = TestFunction2(i3=1);
end FunctionBinding11;

model FunctionBinding12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding12",
          description="Function call with named arguments: using output as input",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): no input matching named argument o1 found
")})));

 Real x = TestFunction2(o1=1);
end FunctionBinding12;

model FunctionBinding13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding13",
          description="Function call with named arguments: giving an input value twice",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): multiple arguments matches input i1
")})));

 Real x = TestFunction2(1, 2, i1=3);
end FunctionBinding13;

model FunctionBinding14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionBinding14",
          description="Function call with named arguments: giving an input value four times",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): multiple arguments matches input i1
")})));

 Real x = TestFunction2(1, 2, i1=3, i1=3, i1=3);
end FunctionBinding14;

model FunctionBinding15
 /* Should bind to TestFunction1(1.0)? */
 parameter Real a = 1;
 Real x = TestFunction1(a);
end FunctionBinding15;


model BadFunctionCall1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BadFunctionCall1",
          description="Call to non-existing function",
          errorMessage=
"
2 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The function NonExistingFunction() is undeclared
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The function NonExistingFunction() is undeclared
")})));

  Real x = NonExistingFunction(1, 2);
  Real y = NonExistingFunction();
end BadFunctionCall1;

model BadFunctionCall2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BadFunctionCall2",
          description="Call to component as function",
          errorMessage=
"
2 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The function notAFunction() is undeclared
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The function notAFunction() is undeclared
")})));

  Real notAFunction = 0;
  Real x = notAFunction(1, 2);
  Real y = notAFunction();
end BadFunctionCall2;

class NotAFunctionClass
 Real x;
end NotAFunctionClass;

model BadFunctionCall3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BadFunctionCall3",
          description="Call to non-function class as function",
          errorMessage=
"
2 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The class NotAFunctionClass is not a function
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The class NotAFunctionClass is not a function
")})));

  Real x = NotAFunctionClass(1, 2);
  Real y = NotAFunctionClass();
end BadFunctionCall3;

model MultipleOutput1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="MultipleOutput1",
          description="Functions with multiple outputs: flattening of equation",
          flatModel="
fclass FunctionTests.MultipleOutput1
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.TestFunction2(1, 2);

 function FunctionTests.TestFunction2
  input Real i1 := 0;
  input Real i2 := 0;
  output Real o1 := 0;
  output Real o2 := i2;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;
end FunctionTests.MultipleOutput1;
")})));

  Real x;
  Real y;
equation
  (x, y) = TestFunction2(1, 2);
end MultipleOutput1;

model MultipleOutput2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="MultipleOutput2",
          description="Functions with multiple outputs: flattening, fewer components assigned than outputs",
          flatModel="
fclass FunctionTests.MultipleOutput2
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.TestFunction3(1, 2, 3);

 function FunctionTests.TestFunction3
  input Real i1;
  input Real i2;
  input Real i3 := 0;
  output Real o1 := i1 + i2 + i3;
  output Real o2 := i2 + i3;
  output Real o3 := i1 + i2;
 algorithm
  return;
 end FunctionTests.TestFunction3;
end FunctionTests.MultipleOutput2;
")})));

  Real x;
  Real y;
equation
  (x, y) = TestFunction3(1, 2, 3);
end MultipleOutput2;

model MultipleOutput3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="MultipleOutput3",
          description="Functions with multiple outputs: flattening, one output skipped",
          flatModel="
fclass FunctionTests.MultipleOutput3
 Real x;
 Real z;
equation
 (x, , z) = FunctionTests.TestFunction3(1, 2, 3);

 function FunctionTests.TestFunction3
  input Real i1;
  input Real i2;
  input Real i3 := 0;
  output Real o1 := i1 + i2 + i3;
  output Real o2 := i2 + i3;
  output Real o3 := i1 + i2;
 algorithm
  return;
 end FunctionTests.TestFunction3;
end FunctionTests.MultipleOutput3;
")})));

  Real x;
  Real z;
equation
  (x, , z) = TestFunction3(1, 2, 3);
end MultipleOutput3;

model MultipleOutput4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="MultipleOutput4",
          description="Functions with multiple outputs: flattening, no components assigned",
          flatModel="
fclass FunctionTests.MultipleOutput4
 Real x;
 Real y;
equation
 FunctionTests.TestFunction2(1, 2);

 function FunctionTests.TestFunction2
  input Real i1 := 0;
  input Real i2 := 0;
  output Real o1 := 0;
  output Real o2 := i2;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;
end FunctionTests.MultipleOutput4;
")})));

  Real x;
  Real y;
equation
  TestFunction2(1, 2);
end MultipleOutput4;

model RecursionTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RecursionTest1",
          description="Flattening function calling other function",
          flatModel="
fclass FunctionTests.RecursionTest1
 Real x = FunctionTests.TestFunctionCallingFunction(1);

 function FunctionTests.TestFunctionCallingFunction
  input Real i1;
  output Real o1;
 algorithm
  o1 := FunctionTests.TestFunction1(i1);
  return;
 end FunctionTests.TestFunctionCallingFunction;

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.RecursionTest1;
")})));

 Real x = TestFunctionCallingFunction(1);
end RecursionTest1;

model RecursionTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="RecursionTest2",
          description="Flattening function calling other function",
          flatModel="
fclass FunctionTests.RecursionTest2
 Real x = FunctionTests.TestFunctionRecursive(5);

 function FunctionTests.TestFunctionRecursive
  input Integer i1;
  output Integer o1;
 algorithm
  if i1 < 3 then
   o1 := 1;
  else
   o1 := FunctionTests.TestFunctionRecursive(i1 - ( 1 )) + FunctionTests.TestFunctionRecursive(i1 - ( 2 ));
  end if;
  return;
 end FunctionTests.TestFunctionRecursive;
end FunctionTests.RecursionTest2;
")})));

 Real x = TestFunctionRecursive(5);
end RecursionTest2;

/* ====================== Function call type checks ====================== */

model FunctionType0
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType0",
          description="Function type checks: Real literal arg, Real input",
          flatModel="
fclass FunctionTests.FunctionType0
 Real x = FunctionTests.TestFunction1(1.0);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionType0;
")})));

 Real x = TestFunction1(1.0);
end FunctionType0;

model FunctionType1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType1",
          description="Function type checks: Integer literal arg, Real input",
          flatModel="
fclass FunctionTests.FunctionType1
 Real x = FunctionTests.TestFunction1(1);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionType1;
")})));

 Real x = TestFunction1(1);
end FunctionType1;

model FunctionType2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType2",
          description="Function type checks: function with Real output as binding exp for Integer component",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x = TestFunction1(1.0);
end FunctionType2;

model FunctionType3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType3",
          description="Function type checks: Real component arg, Real input",
          flatModel="
fclass FunctionTests.FunctionType3
 parameter Real a = 1.0 /* 1.0 */;
 Real x = FunctionTests.TestFunction1(a);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionType3;
")})));

 parameter Real a = 1.0;
 Real x = TestFunction1(a);
end FunctionType3;

model FunctionType4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType4",
          description="Function type checks: Integer component arg, Real input",
          flatModel="
fclass FunctionTests.FunctionType4
 parameter Integer a = 1 /* 1 */;
 Real x = FunctionTests.TestFunction1(a);

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionType4;
")})));

 parameter Integer a = 1;
 Real x = TestFunction1(a);
end FunctionType4;

model FunctionType5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType5",
          description="Function type checks: Boolean literal arg, Real input",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): types of positional argument 2 and input i2 are not compatible
")})));

 Real x = TestFunction2(1, true);
end FunctionType5;

model FunctionType6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType6",
          description="Function type checks: Boolean component arg, Real input",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): types of positional argument 2 and input i2 are not compatible
")})));

 parameter Boolean a = true;
 Real x = TestFunction2(1, a);
end FunctionType6;

model FunctionType7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType7",
          description="Function type checks: nestled function calls",
          flatModel="
fclass FunctionTests.FunctionType7
 parameter Integer a = 1 /* 1 */;
 Real x = FunctionTests.TestFunction2(FunctionTests.TestFunction2(0, 0), FunctionTests.TestFunction2(1, 0));

 function FunctionTests.TestFunction2
  input Real i1 := 0;
  input Real i2 := 0;
  output Real o1 := 0;
  output Real o2 := i2;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction2;
end FunctionTests.FunctionType7;
")})));

 parameter Integer a = 1;
 Real x = TestFunction2(TestFunction2(), TestFunction2(1));
end FunctionType7;

model FunctionType8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType8",
          description="Function type checks: nestled function calls, type mismatch in inner",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction1(): types of positional argument 1 and input i1 are not compatible
")})));

 parameter Integer a = 1;
 Real x = TestFunction2(TestFunction1(true), TestFunction2(1));
end FunctionType8;

model FunctionType9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType9",
          description="Function type checks: String literal arg, String input",
          flatModel="
fclass FunctionTests.FunctionType9
 String x = FunctionTests.TestFunctionString(\"test\");

 function FunctionTests.TestFunctionString
  input String i1;
  output String o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunctionString;
end FunctionTests.FunctionType9;
")})));

 String x = TestFunctionString("test");
end FunctionType9;

model FunctionType10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="FunctionType10",
          description="Function type checks: String component arg, String input",
          flatModel="
fclass FunctionTests.FunctionType10
 parameter String a = \"test\" /* test */;
 String x = FunctionTests.TestFunctionString(a);

 function FunctionTests.TestFunctionString
  input String i1;
  output String o1 := i1;
 algorithm
  return;
 end FunctionTests.TestFunctionString;
end FunctionTests.FunctionType10;
")})));

 parameter String a = "test";
 String x = TestFunctionString(a);
end FunctionType10;

model FunctionType11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType11",
          description="Function type checks: Integer literal arg, String input",
          errorMessage="
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunctionString(): types of positional argument 1 and input i1 are not compatible
")})));

 String x = TestFunctionString(1);
end FunctionType11;

model FunctionType12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType12",
          description="Function type checks: 2 outputs, 2nd wrong type",
          errorMessage="
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction2(): types of component y and output o2 are not compatible
")})));

 Real x;
 Integer y;
equation
 (x, y) = TestFunction2(1, 2);
end FunctionType12;

model FunctionType13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType13",
          description="Function type checks: 3 outputs, 1st and 3rd wrong type",
          errorMessage="
2 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): types of component x and output o1 are not compatible
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): types of component z and output o3 are not compatible
")})));

 Integer x;
 Real y;
 Integer z;
equation
 (x, y, z) = TestFunction3(1, 2);
end FunctionType13;

model FunctionType14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType14",
          description="Function type checks: 2 outputs, 3 components assigned",
          errorMessage="
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Too many components assigned from function call: TestFunction2() has 2 output(s)
")})));

 Real x;
 Real y;
 Real z;
equation
 (x, y, z) = TestFunction2(1, 2);
end FunctionType14;

model FunctionType15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType15",
          description="Function type checks: 3 outputs, 2nd skipped, 3rd wrong type",
          errorMessage="
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function TestFunction3(): types of component z and output o3 are not compatible
")})));

 Real x;
 Integer z;
equation
 (x, , z) = TestFunction3(1, 2);
end FunctionType15;

model FunctionType16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="FunctionType16",
          description="Function type checks: assigning 2 components from sin()",
          errorMessage="
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Too many components assigned from function call: sin() has 1 output(s)
")})));

 Real x;
 Real y;
equation
 (x, y) = sin(1);
end FunctionType16;

model FunctionType17
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="FunctionType17",
         description="Function type checks: combining known and unknown types",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1094, column 8:
  Type error in expression
")})));

 function f
  input Real x[:,:];
  input Real y[2,:];
  output Real z[size(x,1),size(x,2)];
 algorithm
  z := x + y;
 end f;
  
 Real x[2,2] = f({{1,2},{3,4}}, {{5,6},{7,8}});
end FunctionType17;


model BuiltInCallType1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType1",
          description="Built-in type checks: passing Boolean literal to sin()",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function sin(): types of positional argument 1 and input u are not compatible
")})));

  Real x = sin(true);
end BuiltInCallType1;

model BuiltInCallType2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType2",
          description="Built-in type checks: passing String literal to sqrt()",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function sqrt(): types of positional argument 1 and input x are not compatible
")})));

  Real x = sqrt("test");
end BuiltInCallType2;

model BuiltInCallType3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="BuiltInCallType3",
          description="Built-in type checks: passing Integer literal to sqrt()",
          flatModel="
fclass FunctionTests.BuiltInCallType3
 Real x = sqrt(1);
end FunctionTests.BuiltInCallType3;
")})));

  Real x = sqrt(1);
end BuiltInCallType3;

model BuiltInCallType4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType4",
          description="Built-in type checks: using return value from sqrt() as Integer",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The binding expression of the variable x does not match the declared type of the variable
")})));

  Integer x = sqrt(9.0);
end BuiltInCallType4;

model BuiltInCallType5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType5",
          description="Built-in type checks: calling sin() without arguments",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function sin(): missing argument for required input u
")})));

  Real x = sin();
end BuiltInCallType5;

model BuiltInCallType6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType6",
          description="Built-in type checks: calling atan2() with only one argument",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function atan2(): missing argument for required input u2
")})));

  Real x = atan2(9.0);
end BuiltInCallType6;

model BuiltInCallType7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType7",
          description="Built-in type checks: calling atan2() with String literal as second argument",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Calling function atan2(): types of positional argument 2 and input u2 are not compatible
")})));

  Real x = atan2(9.0, "test");
end BuiltInCallType7;

model BuiltInCallType8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="BuiltInCallType8",
          description="Built-in type checks: using ones and zeros",
          flatModel="
fclass FunctionTests.BuiltInCallType8
 Real x[3] = zeros(3);
 Real y[3,2] = ones(3, 2);
end FunctionTests.BuiltInCallType8;
")})));

  Real x[3] = zeros(3);
  Real y[3,2] = ones(3,2);
end BuiltInCallType8;

model BuiltInCallType9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType9",
          description="Built-in type checks: calling zeros() with Real literal as argument",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Argument of zeros() is not compatible with Integer: 3.0
")})));

   Real x[3] = zeros(3.0);
end BuiltInCallType9;

model BuiltInCallType10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="BuiltInCallType10",
         description="Built-in type checks: calling ones() with String literal as second argument",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1234, column 9:
  Array size mismatch in declaration of x, size of declaration is [3] and size of binding expression is [3, \"test\"]
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1223, column 24:
  Argument of ones() is not compatible with Integer: \"test\"
")})));

   Real x[3] = ones(3, "test");
end BuiltInCallType10;


/* ====================== Algorithm flattening ====================== */

model AlgorithmFlatten1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="AlgorithmFlatten1",
                                               description="Flattening algorithms: assign stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten1
 Real x;
algorithm
 x := 5;
 x := x + 2;
end FunctionTests.AlgorithmFlatten1;
")})));

 Real x;
algorithm
 x := 5;
 x := x + 2;
end AlgorithmFlatten1;

model AlgorithmFlatten2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="AlgorithmFlatten2",
                                               description="Flattening algorithms: break stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten2
 Real x;
algorithm
 break;
end FunctionTests.AlgorithmFlatten2;
")})));

 Real x;
algorithm
 break;
end AlgorithmFlatten2;

model AlgorithmFlatten3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="AlgorithmFlatten3",
                                               description="Flattening algorithms: if stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten3
 Integer x;
 Integer y;
algorithm
 if x == 4 then
  x := 1;
  y := 2;
 elseif x == 3 then
  if y == 0 then
   y := 1;
  end if;
  x := 2;
  y := 3;
 else
  x := 3;
 end if;
end FunctionTests.AlgorithmFlatten3;
")})));

 Integer x;
 Integer y;
algorithm
 if x == 4 then
  x := 1;
  y := 2;
 elseif x == 3 then
  if y == 0 then
   y := 1;
  end if;
  x := 2;
  y := 3;
 else
  x := 3;
 end if;
end AlgorithmFlatten3;

model AlgorithmFlatten4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="AlgorithmFlatten4",
                                               description="Flattening algorithms: when stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten4
 Integer x;
 Integer y;
algorithm
 when x == 4 then
  x := 1;
  y := 2;
 elsewhen x == 3 then
  x := 2;
  y := 3;
  if x == 2 then
   x := 3;
  end if;
 end when;
end FunctionTests.AlgorithmFlatten4;
")})));

 Integer x;
 Integer y;
algorithm
 when x == 4 then
  x := 1;
  y := 2;
 elsewhen x == 3 then
  x := 2;
  y := 3;
  if x == 2 then
   x := 3;
  end if;
 end when;
end AlgorithmFlatten4;

model AlgorithmFlatten5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="AlgorithmFlatten5",
                                               description="Flattening algorithms: while stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten5
 Real x;
algorithm
 while x < 1 loop
  while x < 2 loop
   while x < 3 loop
    x := x - ( 1 );
   end while;
  end while;
 end while;
end FunctionTests.AlgorithmFlatten5;
")})));

 Real x;
algorithm
 while x < 1 loop
  while x < 2 loop
   while x < 3 loop
    x := x - 1;
   end while;
  end while;
 end while;
end AlgorithmFlatten5;

model AlgorithmFlatten6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmFlatten6",
         description="Flattening algorithms: for stmts",
         flatModel="
fclass FunctionTests.AlgorithmFlatten6
 Real x;
algorithm
 for i in {1,2,4} loop
  for j in 1:3 loop
   x := x + ( i ) * ( j );
  end for;
 end for;
end FunctionTests.AlgorithmFlatten6;
")})));

 Real x;
algorithm
 for i in {1, 2, 4}, j in 1:3 loop
  x := x + i * j;
 end for;
end AlgorithmFlatten6;


/* ====================== Algorithm type checks ====================== */

/* ----- if ----- */

model AlgorithmTypeIf1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeIf1",
         description="Type checks in algorithms: Integer literal as test in if",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1363, column 5:
  Type of test expression of if statement is not Boolean
")})));

 Real x;
algorithm
 if 1 then
  x := 1.0;
 end if;
end AlgorithmTypeIf1;

model AlgorithmTypeIf2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeIf2",
         description="Type checks in algorithms: Integer component as test in if",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1382, column 5:
  Type of test expression of if statement is not Boolean
")})));

 Integer a = 1;
 Real x;
algorithm
 if a then
  x := 1.0;
 end if;
end AlgorithmTypeIf2;

model AlgorithmTypeIf3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeIf3",
         description="Type checks in algorithms: arithmetic expression as test in if",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1403, column 5:
  Type of test expression of if statement is not Boolean
")})));

 Integer a = 1;
 Real x;
algorithm
 if a + x then
  x := 1.0;
 end if;
end AlgorithmTypeIf3;

model AlgorithmTypeIf4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeIf4",
         description="Type checks in algorithms: Boolean vector as test in if",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1422, column 5:
  Type of test expression of if statement is not Boolean
")})));

 Real x;
algorithm
 if { true, false } then
  x := 1.0;
 end if;
end AlgorithmTypeIf4;

model AlgorithmTypeIf5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmTypeIf5",
         description="Type checks in algorithms: Boolean literal as test in if",
         flatModel="
fclass FunctionTests.AlgorithmTypeIf5
 Real x;
algorithm
 if true then
  x := 1.0;
 end if;
end FunctionTests.AlgorithmTypeIf5;
")})));

 Real x;
algorithm
 if true then
  x := 1.0;
 end if;
end AlgorithmTypeIf5;

/* ----- when ----- */

model AlgorithmTypeWhen1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhen1",
         description="Type checks in algorithms: Integer literal as test in when",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1469, column 7:
  Test expression of when statement isn't Boolean scalar or vector expression
")})));

 Real x;
algorithm
 when 1 then
  x := 1.0;
 end when;
end AlgorithmTypeWhen1;

model AlgorithmTypeWhen2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhen2",
         description="Type checks in algorithms: Integer component as test in when",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1489, column 7:
  Test expression of when statement isn't Boolean scalar or vector expression
")})));

 Integer a = 1;
 Real x;
algorithm
 when a then
  x := 1.0;
 end when;
end AlgorithmTypeWhen2;

model AlgorithmTypeWhen3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhen3",
         description="Type checks in algorithms: arithmetic expression as test in when",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1509, column 7:
  Test expression of when statement isn't Boolean scalar or vector expression
")})));

 Integer a = 1;
 Real x;
algorithm
 when a + x then
  x := 1.0;
 end when;
end AlgorithmTypeWhen3;

model AlgorithmTypeWhen4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmTypeWhen4",
         description="Type checks in algorithms: Boolean vector as test in when",
         flatModel="
fclass FunctionTests.AlgorithmTypeWhen4
 Real x;
algorithm
 when {true,false} then
  x := 1.0;
 end when;
end FunctionTests.AlgorithmTypeWhen4;
")})));

 Real x;
algorithm
 when { true, false } then
  x := 1.0;
 end when;
end AlgorithmTypeWhen4;

model AlgorithmTypeWhen5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmTypeWhen5",
         description="Type checks in algorithms: Boolean literal as test in when",
         flatModel="
fclass FunctionTests.AlgorithmTypeWhen5
 Real x;
algorithm
 when true then
  x := 1.0;
 end when;
end FunctionTests.AlgorithmTypeWhen5;
")})));

 Real x;
algorithm
 when true then
  x := 1.0;
 end when;
end AlgorithmTypeWhen5;

/* ----- while ----- */

model AlgorithmTypeWhile1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhile1",
         description="Type checks in algorithms: Integer literal as test in while",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1363, column 5:
  Type of test expression of while statement is not Boolean
")})));

 Real x;
algorithm
 while 1 loop
  x := 1.0;
 end while;
end AlgorithmTypeWhile1;

model AlgorithmTypeWhile2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhile2",
         description="Type checks in algorithms: Integer component as test in while",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1382, column 5:
  Type of test expression of while statement is not Boolean
")})));

 Integer a = 1;
 Real x;
algorithm
 while a loop
  x := 1.0;
 end while;
end AlgorithmTypeWhile2;

model AlgorithmTypeWhile3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhile3",
         description="Type checks in algorithms: arithmetic expression as test in while",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1403, column 5:
  Type of test expression of while statement is not Boolean
")})));

 Integer a = 1;
 Real x;
algorithm
 while a + x loop
  x := 1.0;
 end while;
end AlgorithmTypeWhile3;

model AlgorithmTypeWhile4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeWhile4",
         description="Type checks in algorithms: Boolean vector as test in while",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1422, column 5:
  Type of test expression of while statement is not Boolean
")})));

 Real x;
algorithm
 while { true, false } loop
  x := 1.0;
 end while;
end AlgorithmTypeWhile4;

model AlgorithmTypeWhile5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmTypeWhile5",
         description="Type checks in algorithms: Boolean literal as test in while",
         flatModel="
fclass FunctionTests.AlgorithmTypeWhile5
 Real x;
algorithm
 while true loop
  x := 1.0;
 end while;
end FunctionTests.AlgorithmTypeWhile5;
")})));

 Real x;
algorithm
 while true loop
  x := 1.0;
 end while;
end AlgorithmTypeWhile5;

model AlgorithmTypeAssign1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeAssign1",
         description="Type checks in algorithms: assign Real to Integer component",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1674, column 2:
  Types of right and left side of assignment are not compatible
")})));

 Integer x;
algorithm
 x := 1.0;
end AlgorithmTypeAssign1;

model AlgorithmTypeAssign2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmTypeAssign2",
         description="Type checks in algorithms: assign Integer to Real component",
         flatModel="
fclass FunctionTests.AlgorithmTypeAssign2
 Real x;
algorithm
 x := 1;
end FunctionTests.AlgorithmTypeAssign2;
")})));

 Real x;
algorithm
 x := 1;
end AlgorithmTypeAssign2;

model AlgorithmTypeAssign3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AlgorithmTypeAssign3",
         description="Type checks in algorithms: assign Real to Real component",
         flatModel="
fclass FunctionTests.AlgorithmTypeAssign3
 Real x;
algorithm
 x := 1.0;
end FunctionTests.AlgorithmTypeAssign3;
")})));

 Real x;
algorithm
 x := 1.0;
end AlgorithmTypeAssign3;

model AlgorithmTypeAssign4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeAssign4",
         description="Type checks in algorithms: assign String to Real component",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1715, column 2:
  Types of right and left side of assignment are not compatible
")})));

 Real x;
algorithm
 x := "foo";
end AlgorithmTypeAssign4;


model AlgorithmTypeForIndex1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeForIndex1",
         description="Type checks in algorithms: assigning to for index",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1794, column 3:
  Can not assign a value to a for loop index
")})));

 Real x;
algorithm
 for i in 1:3 loop
  i := 2;
  x := i;
 end for;
end AlgorithmTypeForIndex1;


model AlgorithmTypeForIndex2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AlgorithmTypeForIndex2",
         description="Type checks in algorithms: assigning to for index (FunctionCallStmt)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 1815, column 3:
  Can not assign a value to a for loop index
")})));

 Real x;
algorithm
 for i in 1:3 loop
  (i, x) := TestFunction2(1, 2);
 end for;
end AlgorithmTypeForIndex2;


/* ====================== Algorithm transformations ===================== */

model AlgorithmTransformation1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation1",
         description="Generating functions from algorithms: simple algorithm",
         flatModel="
fclass FunctionTests.AlgorithmTransformation1
 Real a;
 Real b;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation1.algorithm_1(a, b);
 a = 1;
 b = 2;

 function FunctionTests.AlgorithmTransformation1.algorithm_1
  output Real x;
  output Real y;
  input Real a;
  input Real b;
 algorithm
  x := a;
  y := b;
  return;
 end FunctionTests.AlgorithmTransformation1.algorithm_1;
end FunctionTests.AlgorithmTransformation1;
")})));

 Real a = 1;
 Real b = 2;
 Real x;
 Real y;
algorithm
 x := a;
 y := b;
end AlgorithmTransformation1;


model AlgorithmTransformation2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation2",
         description="Generating functions from algorithms: vars used several times",
         flatModel="
fclass FunctionTests.AlgorithmTransformation2
 Real a;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation2.algorithm_1(a);
 a = 1;

 function FunctionTests.AlgorithmTransformation2.algorithm_1
  output Real x;
  output Real y;
  input Real a;
 algorithm
  x := a;
  y := a;
  x := a;
  y := a;
  return;
 end FunctionTests.AlgorithmTransformation2.algorithm_1;
end FunctionTests.AlgorithmTransformation2;
")})));

 Real a = 1;
 Real x;
 Real y;
algorithm
 x := a;
 y := a;
 x := a;
 y := a;
end AlgorithmTransformation2;


model AlgorithmTransformation3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation3",
         description="Generating functions from algorithms: complex algorithm",
         flatModel="
fclass FunctionTests.AlgorithmTransformation3
 Real a;
 Real b;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation3.algorithm_1(a, b);
 a = 1;
 b = 2;

 function FunctionTests.AlgorithmTransformation3.algorithm_1
  output Real x;
  output Real y;
  input Real a;
  input Real b;
 algorithm
  x := a + 1;
  if b > 1 then
   y := a + 2;
  end if;
  return;
 end FunctionTests.AlgorithmTransformation3.algorithm_1;
end FunctionTests.AlgorithmTransformation3;
")})));

 Real a = 1;
 Real b = 2;
 Real x;
 Real y;
algorithm
 x := a + 1;
 if b > 1 then
  y := a + 2;
 end if;
end AlgorithmTransformation3;


model AlgorithmTransformation4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation4",
         description="Generating functions from algorithms: complex algorithm",
         flatModel="
fclass FunctionTests.AlgorithmTransformation4
 Real a;
 Real b;
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation4.algorithm_1(b, a);
 a = 1;
 b = 2;

 function FunctionTests.AlgorithmTransformation4.algorithm_1
  output Real x;
  output Real y;
  input Real b;
  input Real a;
 algorithm
  while b > 1 loop
   x := a;
   if a < 2 then
    y := b;
   else
    y := a + 2;
   end if;
  end while;
  return;
 end FunctionTests.AlgorithmTransformation4.algorithm_1;
end FunctionTests.AlgorithmTransformation4;
")})));

 Real a = 1;
 Real b = 2;
 Real x;
 Real y;
algorithm
 while b > 1 loop
  x := a;
  if a < 2 then
   y := b;
  else
   y := a + 2;
  end if;
 end while;
end AlgorithmTransformation4;


model AlgorithmTransformation5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation5",
         description="Generating functions from algorithms: no used variables",
         flatModel="
fclass FunctionTests.AlgorithmTransformation5
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation5.algorithm_1();

 function FunctionTests.AlgorithmTransformation5.algorithm_1
  output Real x;
  output Real y;
 algorithm
  x := 1;
  y := 2;
  return;
 end FunctionTests.AlgorithmTransformation5.algorithm_1;
end FunctionTests.AlgorithmTransformation5;
")})));

 Real x;
 Real y;
algorithm
 x := 1;
 y := 2;
end AlgorithmTransformation5;


model AlgorithmTransformation6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation6",
         description="Generating functions from algorithms: 2 algorithms",
         flatModel="
fclass FunctionTests.AlgorithmTransformation6
 Real x;
 Real y;
equation
 (x) = FunctionTests.AlgorithmTransformation6.algorithm_1();
 (y) = FunctionTests.AlgorithmTransformation6.algorithm_2();

 function FunctionTests.AlgorithmTransformation6.algorithm_1
  output Real x;
 algorithm
  x := 1;
  return;
 end FunctionTests.AlgorithmTransformation6.algorithm_1;

 function FunctionTests.AlgorithmTransformation6.algorithm_2
  output Real y;
 algorithm
  y := 2;
  return;
 end FunctionTests.AlgorithmTransformation6.algorithm_2;
end FunctionTests.AlgorithmTransformation6;
")})));

 Real x;
 Real y;
algorithm
 x := 1;
algorithm
 y := 2;
end AlgorithmTransformation6;


model AlgorithmTransformation7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation7",
         description="Generating functions from algorithms: generated name exists - function",
         flatModel="
fclass FunctionTests.AlgorithmTransformation7
 Real x;
equation
 (x) = FunctionTests.AlgorithmTransformation7.algorithm_2();

 function FunctionTests.AlgorithmTransformation7.algorithm_1
  input Real i;
  output Real o;
 algorithm
  o := ( i ) * ( 2 );
  return;
 end FunctionTests.AlgorithmTransformation7.algorithm_1;

 function FunctionTests.AlgorithmTransformation7.algorithm_2
  output Real x;
 algorithm
  x := FunctionTests.AlgorithmTransformation7.algorithm_1(2);
  return;
 end FunctionTests.AlgorithmTransformation7.algorithm_2;
end FunctionTests.AlgorithmTransformation7;
")})));

 function algorithm_1
  input Real i;
  output Real o = i * 2;
  algorithm
 end algorithm_1;
 
 Real x;
algorithm
 x := algorithm_1(2);
end AlgorithmTransformation7;


model AlgorithmTransformation8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation8",
         description="Generating functions from algorithms: generated name exists - model",
         flatModel="
fclass FunctionTests.AlgorithmTransformation8
 Real x.a;
 Real x.b;
equation
 (x.a, x.b) = FunctionTests.AlgorithmTransformation8.algorithm_1();

 function FunctionTests.AlgorithmTransformation8.algorithm_1
  output Real x.a;
  output Real x.b;
 algorithm
  x.a := 2;
  x.b := 3;
  return;
 end FunctionTests.AlgorithmTransformation8.algorithm_1;
end FunctionTests.AlgorithmTransformation8;
")})));

 model algorithm_1
  Real a;
  Real b;
 end algorithm_1;
 
 algorithm_1 x;
algorithm
 x.a := 2;
 x.b := 3;
end AlgorithmTransformation8;


model AlgorithmTransformation9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation9",
         description="Generating functions from algorithms: generated name exists - component",
         flatModel="
fclass FunctionTests.AlgorithmTransformation9
 Real algorithm_1;
 Real algorithm_3;
equation
 (algorithm_1) = FunctionTests.AlgorithmTransformation9.algorithm_2();
 (algorithm_3) = FunctionTests.AlgorithmTransformation9.algorithm_4();

 function FunctionTests.AlgorithmTransformation9.algorithm_2
  output Real algorithm_1;
 algorithm
  algorithm_1 := 1;
  return;
 end FunctionTests.AlgorithmTransformation9.algorithm_2;

 function FunctionTests.AlgorithmTransformation9.algorithm_4
  output Real algorithm_3;
 algorithm
  algorithm_3 := 3;
  return;
 end FunctionTests.AlgorithmTransformation9.algorithm_4;
end FunctionTests.AlgorithmTransformation9;
")})));

 Real algorithm_1;
 Real algorithm_3;
algorithm
 algorithm_1 := 1;
algorithm
 algorithm_3 := 3;
end AlgorithmTransformation9;


model AlgorithmTransformation10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation10",
         description="Generating functions from algorithms: generated arg name exists",
         flatModel="
fclass FunctionTests.AlgorithmTransformation10
 Real x;
 Real x_0;
 Real x_1;
equation
 x_0 = 0;
 (x, x_1) = FunctionTests.AlgorithmTransformation10.algorithm_1(x_0, 0);

 function FunctionTests.AlgorithmTransformation10.algorithm_1
  output Real x;
  output Real x_1;
  input Real x_0;
  input Real x_2;
 algorithm
  x := x_2;
  x := x_0;
  x_1 := x;
  return;
 end FunctionTests.AlgorithmTransformation10.algorithm_1;
end FunctionTests.AlgorithmTransformation10;
")})));

 Real x;
 Real x_0;
 Real x_1;
algorithm
 x := x_0;
 x_1 := x;
equation
 x_0 = 0;
end AlgorithmTransformation10;


model AlgorithmTransformation11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation11",
         description="Generating functions from algorithms: assigned variable used",
         flatModel="
fclass FunctionTests.AlgorithmTransformation11
 Real x;
 Real y;
equation
 (x, y) = FunctionTests.AlgorithmTransformation11.algorithm_1(0);

 function FunctionTests.AlgorithmTransformation11.algorithm_1
  output Real x;
  output Real y;
  input Real x_0;
 algorithm
  x := x_0;
  x := 1;
  y := x;
  return;
 end FunctionTests.AlgorithmTransformation11.algorithm_1;
end FunctionTests.AlgorithmTransformation11;
")})));

 Real x;
 Real y;
algorithm
 x := 1;
 y := x;
end AlgorithmTransformation11;


model AlgorithmTransformation12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation12",
         description="Generating functions from algorithms: assigned variables used, different start values",
         flatModel="
fclass FunctionTests.AlgorithmTransformation12
 Real x0;
 Real x1(start = 1);
 Real x2(start = 2);
 Real y;
equation
 (x0, x1, x2, y) = FunctionTests.AlgorithmTransformation12.algorithm_1(0, 1, 2);

 function FunctionTests.AlgorithmTransformation12.algorithm_1
  output Real x0;
  output Real x1;
  output Real x2;
  output Real y;
  input Real x0_0;
  input Real x1_0;
  input Real x2_0;
 algorithm
  x0 := x0_0;
  x1 := x1_0;
  x2 := x2_0;
  x0 := 1;
  x1 := x0;
  x2 := x1;
  y := x2;
  return;
 end FunctionTests.AlgorithmTransformation12.algorithm_1;
end FunctionTests.AlgorithmTransformation12;
")})));

 Real x0;
 Real x1(start=1);
 Real x2(start=2);
 Real y;
algorithm
 x0 := 1;
 x1 := x0;
 x2 := x1;
 y := x2;
end AlgorithmTransformation12;


model AlgorithmTransformation13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation13",
         description="Generating functions from algorithms: no assignments",
         flatModel="
fclass FunctionTests.AlgorithmTransformation13
 Real x;
equation
 FunctionTests.AlgorithmTransformation13.algorithm_1(x);
 x = 2;

 function FunctionTests.TestFunction1
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1;
  return;
 end FunctionTests.TestFunction1;

 function FunctionTests.AlgorithmTransformation13.algorithm_1
  input Real x;
 algorithm
  if x < 3 then
   FunctionTests.TestFunction1(x);
  end if;
  return;
 end FunctionTests.AlgorithmTransformation13.algorithm_1;
end FunctionTests.AlgorithmTransformation13;
")})));

 Real x = 2;
algorithm
 if x < 3 then
  TestFunction1(x);
 end if;
end AlgorithmTransformation13;


model AlgorithmTransformation14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="AlgorithmTransformation14",
         description="Generating functions from algorithms: using for index",
         flatModel="
fclass FunctionTests.AlgorithmTransformation14
 Real x;
equation
 (x) = FunctionTests.AlgorithmTransformation14.algorithm_1(0);

 function FunctionTests.AlgorithmTransformation14.algorithm_1
  output Real x;
  input Real x_0;
 algorithm
  x := x_0;
  x := 0;
  for i in 1:3 loop
   x := x + i;
  end for;
  return;
 end FunctionTests.AlgorithmTransformation14.algorithm_1;
end FunctionTests.AlgorithmTransformation14;
")})));

 Real x;
algorithm
 x := 0;
 for i in 1:3 loop
  x := x + i;
 end for;
end AlgorithmTransformation14;



/* =========================== Arrays in functions =========================== */

model ArrayExpInFunc1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc1",
         description="Scalarization of functions: assign from array",
         flatModel="
fclass FunctionTests.ArrayExpInFunc1
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc1.f();

 function FunctionTests.ArrayExpInFunc1.f
  output Real o;
  Real[3] x;
 algorithm
  o := 1.0;
  x[1] := 1;
  x[2] := 2;
  x[3] := 3;
  return;
 end FunctionTests.ArrayExpInFunc1.f;
end FunctionTests.ArrayExpInFunc1;
")})));

 function f
  output Real o = 1.0;
  protected Real x[3];
 algorithm
  x := { 1, 2, 3 };
 end f;
 
 Real x = f();
end ArrayExpInFunc1;


model ArrayExpInFunc2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc2",
         description="Scalarization of functions: assign from array exp",
         flatModel="
fclass FunctionTests.ArrayExpInFunc2
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc2.f();

 function FunctionTests.ArrayExpInFunc2.f
  output Real o;
  Real[2, 2] x;
 algorithm
  o := 1.0;
  x[1,1] := ( 1 ) * ( 1 ) + ( 2 ) * ( 3 );
  x[1,2] := ( 1 ) * ( 2 ) + ( 2 ) * ( 4 );
  x[2,1] := ( 3 ) * ( 1 ) + ( 4 ) * ( 3 );
  x[2,2] := ( 3 ) * ( 2 ) + ( 4 ) * ( 4 );
  return;
 end FunctionTests.ArrayExpInFunc2.f;
end FunctionTests.ArrayExpInFunc2;
")})));

 function f
  output Real o = 1.0;
  protected Real x[2,2];
 algorithm
  x := {{1,2},{3,4}} * {{1,2},{3,4}};
 end f;
 
 Real x = f();
end ArrayExpInFunc2;


model ArrayExpInFunc3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc3",
         description="Scalarization of functions: assign to slice",
         flatModel="
fclass FunctionTests.ArrayExpInFunc3
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc3.f();

 function FunctionTests.ArrayExpInFunc3.f
  output Real o;
  Real[2, 2] x;
 algorithm
  o := 1.0;
  x[1,1] := 1;
  x[1,2] := 2;
  x[2,1] := 3;
  x[2,2] := 4;
  return;
 end FunctionTests.ArrayExpInFunc3.f;
end FunctionTests.ArrayExpInFunc3;
")})));

 function f
  output Real o = 1.0;
  protected Real x[2,2];
 algorithm
  x[1,:] := {1,2};
  x[2,:] := {3,4};
 end f;
 
 Real x = f();
end ArrayExpInFunc3;


model ArrayExpInFunc4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc4",
         description="Scalarization of functions: binding exp to array var",
         flatModel="
fclass FunctionTests.ArrayExpInFunc4
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc4.f();

 function FunctionTests.ArrayExpInFunc4.f
  output Real o;
  Real[2, 2] x;
 algorithm
  o := 1.0;
  x[1,1] := ( 1 ) * ( 1 ) + ( 2 ) * ( 3 );
  x[1,2] := ( 1 ) * ( 2 ) + ( 2 ) * ( 4 );
  x[2,1] := ( 3 ) * ( 1 ) + ( 4 ) * ( 3 );
  x[2,2] := ( 3 ) * ( 2 ) + ( 4 ) * ( 4 );
  return;
 end FunctionTests.ArrayExpInFunc4.f;
end FunctionTests.ArrayExpInFunc4;
")})));

 function f
  output Real o = 1.0;
  protected Real x[2,2] = {{1,2},{3,4}} * {{1,2},{3,4}};
 algorithm
 end f;
 
 Real x = f();
end ArrayExpInFunc4;


model ArrayExpInFunc5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc5",
         description="Scalarization of functions: (x, y) := f(...) syntax",
         flatModel="
fclass FunctionTests.ArrayExpInFunc5
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc5.f(( 1 ) * ( 1 ) + ( 2 ) * ( 2 ) + ( 3 ) * ( 3 ));

 function FunctionTests.ArrayExpInFunc5.f
  input Real a;
  output Real o;
  Real x;
  Real y;
 algorithm
  (x, y) := FunctionTests.ArrayExpInFunc5.f2(( 1 ) * ( 1 ) + ( 2 ) * ( 2 ) + ( 3 ) * ( 3 ));
  o := a + x + y;
  return;
 end FunctionTests.ArrayExpInFunc5.f;

 function FunctionTests.ArrayExpInFunc5.f2
  input Real a;
  output Real b;
  output Real c;
 algorithm
  b := a;
  c := a;
  return;
 end FunctionTests.ArrayExpInFunc5.f2;
end FunctionTests.ArrayExpInFunc5;
")})));

 function f
  input Real a;
  output Real o;
  protected Real x;
  protected Real y;
 algorithm
  (x, y) := f2({1,2,3} * {1,2,3});
  o := a + x + y;
 end f;
 
 function f2
  input Real a;
  output Real b = a;
  output Real c = a;
 algorithm
 end f2;
 
 Real x = f({1,2,3} * {1,2,3});
end ArrayExpInFunc5;


model ArrayExpInFunc6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc6",
         description="Scalarization of functions: if statements",
         flatModel="
fclass FunctionTests.ArrayExpInFunc6
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc6.f();

 function FunctionTests.ArrayExpInFunc6.f
  output Real o;
  Real[3] x;
 algorithm
  o := 1.0;
  if o < 2.0 then
   x[1] := 1;
   x[2] := 2;
   x[3] := 3;
  elseif o < 1.5 then
   x[1] := 4;
   x[2] := 5;
   x[3] := 6;
  else
   x[1] := 7;
   x[2] := 8;
   x[3] := 9;
  end if;
  return;
 end FunctionTests.ArrayExpInFunc6.f;
end FunctionTests.ArrayExpInFunc6;
")})));

 function f
  output Real o = 1.0;
  protected Real x[3];
 algorithm
  if o < 2.0 then
   x := { 1, 2, 3 };
  elseif o < 1.5 then
   x := { 4, 5, 6 };
  else
   x := { 7, 8, 9 };
  end if;
 end f;
 
 Real x = f();
end ArrayExpInFunc6;


model ArrayExpInFunc7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc7",
         description="Scalarization of functions: when statements",
         flatModel="
fclass FunctionTests.ArrayExpInFunc7
 Real o;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 ({x[1], x[2], x[3]}) = FunctionTests.ArrayExpInFunc7.algorithm_1(o);
 o = 1.0;

 function FunctionTests.ArrayExpInFunc7.algorithm_1
  output Real[3] x;
  input Real o;
 algorithm
  when o < 2.0 or o > 3.0 then
   x[1] := 1;
   x[2] := 2;
   x[3] := 3;
  elsewhen o < 1.5 then
   x[1] := 4;
   x[2] := 5;
   x[3] := 6;
  end when;
  return;
 end FunctionTests.ArrayExpInFunc7.algorithm_1;
end FunctionTests.ArrayExpInFunc7;
")})));

 Real o = 1.0;
 Real x[3];
algorithm
 when {o < 2.0, o > 3.0} then
  x := { 1, 2, 3 };
 elsewhen o < 1.5 then
  x := { 4, 5, 6 };
 end when;
end ArrayExpInFunc7;


model ArrayExpInFunc8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc8",
         description="Scalarization of functions: for statements",
         flatModel="
fclass FunctionTests.ArrayExpInFunc8
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc8.f();

 function FunctionTests.ArrayExpInFunc8.f
  output Real o;
  Real[3] x;
  Real[3] y;
 algorithm
  o := 1.0;
  for i in 1:3 loop
   x[i] := i;
   y[1] := ( 1 ) * ( 1 );
   y[2] := ( 2 ) * ( 2 );
   y[3] := ( 3 ) * ( 3 );
  end for;
  return;
 end FunctionTests.ArrayExpInFunc8.f;
end FunctionTests.ArrayExpInFunc8;
")})));

 function f
  output Real o = 1.0;
  protected Real x[3];
  protected Real y[3];
 algorithm
  for i in 1:3 loop
   x[i] := i;
   y := {i*i for i in 1:3};
  end for;
 end f;
 
 Real x = f();
end ArrayExpInFunc8;


model ArrayExpInFunc9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayExpInFunc9",
         description="Scalarization of functions: while statements",
         flatModel="
fclass FunctionTests.ArrayExpInFunc9
 Real x;
equation
 x = FunctionTests.ArrayExpInFunc9.f();

 function FunctionTests.ArrayExpInFunc9.f
  output Real o;
  Real[3] x;
  Integer y;
 algorithm
  o := 1.0;
  y := 3;
  while y > 0 loop
   x[1] := 1;
   x[2] := 2;
   x[3] := 3;
   x[y] := y;
   y := y - ( 1 );
  end while;
  return;
 end FunctionTests.ArrayExpInFunc9.f;
end FunctionTests.ArrayExpInFunc9;
")})));

 function f
  output Real o = 1.0;
  protected Real x[3];
  protected Integer y = 3;
 algorithm
  while y > 0 loop
   x := 1:3;
   x[y] := y;
   y := y - 1;
  end while;
 end f;
 
 Real x = f();
end ArrayExpInFunc9;



model ArrayOutputScalarization1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization1",
         description="Scalarization of array function outputs: function call equation",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization1
 Real x[1];
 Real x[2];
 Real y[1];
 Real y[2];
equation
 ({x[1],x[2]}, {y[1],y[2]}) = FunctionTests.ArrayOutputScalarization1.f();

 function FunctionTests.ArrayOutputScalarization1.f
  output Real[2] x;
  output Real[2] y;
 algorithm
  x[1] := 1;
  x[2] := 2;
  y[1] := 1;
  y[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization1.f;
end FunctionTests.ArrayOutputScalarization1;
")})));

 function f
  output Real x[2] = {1,2};
  output Real y[2] = {1,2};
 algorithm
 end f;
 
 Real x[2];
 Real y[2];
equation
 (x,y) = f();
end ArrayOutputScalarization1;


model ArrayOutputScalarization2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization2",
         description="Scalarization of array function outputs: expression with func call",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization2
 Real x[1];
 Real x[2];
 Real temp_1[1];
 Real temp_1[2];
equation
 ({temp_1[1],temp_1[2]}) = FunctionTests.ArrayOutputScalarization2.f();
 x[1] = 3 + temp_1[1];
 x[2] = 4 + temp_1[2];

 function FunctionTests.ArrayOutputScalarization2.f
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization2.f;
end FunctionTests.ArrayOutputScalarization2;
")})));

 function f
  output Real x[2] = {1,2};
 algorithm
 end f;
 
 Real x[2];
equation
 x = {3,4} + f();
end ArrayOutputScalarization2;


model ArrayOutputScalarization3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization3",
         description="Scalarization of array function outputs: finding free temp name",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization3
 Real x[1];
 Real x[2];
 Real temp;
 Real temp_1;
 Real temp_3;
 Real temp_2[1];
 Real temp_2[2];
equation
 ({temp_2[1],temp_2[2]}) = FunctionTests.ArrayOutputScalarization3.f();
 x[1] = 1 + temp_2[1];
 x[2] = 2 + temp_2[2];
 temp = 1;
 temp_1 = 2;
 temp_3 = 3;

 function FunctionTests.ArrayOutputScalarization3.f
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization3.f;
end FunctionTests.ArrayOutputScalarization3;
")})));

 function f
  output Real x[2] = {1, 2};
 algorithm
 end f;
 
 Real x[2];
 Real temp = 1;
 Real temp_1 = 2;
 Real temp_3 = 3;
equation
 x = {1,2} + f();
end ArrayOutputScalarization3;


model ArrayOutputScalarization4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization4",
         description="Scalarization of array function outputs: function call statement",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization4
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization4.f2();

 function FunctionTests.ArrayOutputScalarization4.f2
  output Real x;
  Real[2] y;
  Real[2] z;
 algorithm
  (y, z) := FunctionTests.ArrayOutputScalarization4.f1();
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization4.f2;

 function FunctionTests.ArrayOutputScalarization4.f1
  output Real[2] x;
  output Real[2] y;
 algorithm
  x[1] := 1;
  x[2] := 2;
  y[1] := 1;
  y[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization4.f1;
end FunctionTests.ArrayOutputScalarization4;
")})));

 function f1
  output Real x[2] = {1,2};
  output Real y[2] = {1,2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
  protected Real z[2];
 algorithm
  (y,z) := f1();
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization4;


model ArrayOutputScalarization5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization5",
         description="Scalarization of array function outputs: assign statement with expression",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization5
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization5.f2();

 function FunctionTests.ArrayOutputScalarization5.f2
  output Real x;
  Real[2] y;
  Real[2] temp_1;
 algorithm
  (temp_1) := FunctionTests.ArrayOutputScalarization5.f1();
  y[1] := 1 + temp_1[1];
  y[2] := 2 + temp_1[2];
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization5.f2;

 function FunctionTests.ArrayOutputScalarization5.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization5.f1;
end FunctionTests.ArrayOutputScalarization5;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
 algorithm
  y := {1,2} + f1();
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization5;


model ArrayOutputScalarization6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization6",
         description="Scalarization of array function outputs: finding free temp name",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization6
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization6.f2();

 function FunctionTests.ArrayOutputScalarization6.f2
  output Real x;
  Real[2] y;
  Real temp_1;
  Real[2] temp_2;
 algorithm
  (temp_2) := FunctionTests.ArrayOutputScalarization6.f1();
  y[1] := temp_2[1];
  y[2] := temp_2[2];
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization6.f2;

 function FunctionTests.ArrayOutputScalarization6.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization6.f1;
end FunctionTests.ArrayOutputScalarization6;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
  protected Real temp_1;
 algorithm
  y := f1();
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization6;


model ArrayOutputScalarization7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization7",
         description="Scalarization of array function outputs: if statement",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization7
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization7.f2();

 function FunctionTests.ArrayOutputScalarization7.f2
  output Real x;
  Real[2] y;
  Real[2] temp_1;
  Real[2] temp_2;
  Real[2] temp_3;
  Real[2] temp_4;
 algorithm
  (temp_1) := FunctionTests.ArrayOutputScalarization7.f1();
  (temp_2) := FunctionTests.ArrayOutputScalarization7.f1();
  if temp_1[1] + temp_1[2] < 4 then
   x := 1;
   (temp_3) := FunctionTests.ArrayOutputScalarization7.f1();
   y[1] := 1 + temp_3[1];
   y[2] := 2 + temp_3[2];
  elseif temp_2[1] + temp_2[2] < 5 then
   y[1] := 3;
   y[2] := 4;
  else
   x := 1;
   (temp_4) := FunctionTests.ArrayOutputScalarization7.f1();
   y[1] := temp_4[1];
   y[2] := temp_4[2];
  end if;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization7.f2;

 function FunctionTests.ArrayOutputScalarization7.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization7.f1;
end FunctionTests.ArrayOutputScalarization7;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
 algorithm
  if sum(f1()) < 4 then
   x := 1;
   y := {1,2} + f1();
  elseif sum(f1()) < 5 then
   y := {3,4};
  else
   x := 1;
   y := f1();
  end if;
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization7;


model ArrayOutputScalarization8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization8",
         description="Scalarization of array function outputs: for statement",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization8
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization8.f2();

 function FunctionTests.ArrayOutputScalarization8.f2
  output Real x;
  Real[2] y;
  Real[2] temp_1;
  Real[2] temp_2;
 algorithm
  (temp_1) := FunctionTests.ArrayOutputScalarization8.f1();
  for i in {temp_1[1],temp_1[2]} loop
   y[1] := i;
   (temp_2) := FunctionTests.ArrayOutputScalarization8.f1();
   y[1] := temp_2[1];
   y[2] := temp_2[2];
  end for;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization8.f2;

 function FunctionTests.ArrayOutputScalarization8.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization8.f1;
end FunctionTests.ArrayOutputScalarization8;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2];
 algorithm
  for i in f1() loop
   y[1] := i;
   y := f1();
  end for;
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization8;


// TODO: Redo test to run without alias elimination once there is support for that in test framework.
model ArrayOutputScalarization9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization9",
         description="Scalarization of array function outputs: equation without expression",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization9
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.ArrayOutputScalarization9.f();

 function FunctionTests.ArrayOutputScalarization9.f
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization9.f;
end FunctionTests.ArrayOutputScalarization9;
")})));

 function f
  output Real x[2] = {1, 2};
 algorithm
 end f;
 
 Real x[2];
equation
 x = f();
end ArrayOutputScalarization9;


model ArrayOutputScalarization10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization10",
         description="Scalarization of array function outputs: while statement",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization10
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization10.f2();

 function FunctionTests.ArrayOutputScalarization10.f2
  output Real x;
  Real[2] temp_1;
 algorithm
  x := 0;
  (temp_1) := FunctionTests.ArrayOutputScalarization10.f1();
  while x < temp_1[1] + temp_1[2] loop
   x := x + 1;
   (temp_1) := FunctionTests.ArrayOutputScalarization10.f1();
  end while;
  return;
 end FunctionTests.ArrayOutputScalarization10.f2;

 function FunctionTests.ArrayOutputScalarization10.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization10.f1;
end FunctionTests.ArrayOutputScalarization10;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x = 0;
 algorithm
  while x < sum(f1()) loop
   x := x + 1;
  end while;
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization10;


model ArrayOutputScalarization11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization11",
         description="Scalarization of array function outputs: binding expression",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization11
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization11.f2();

 function FunctionTests.ArrayOutputScalarization11.f2
  output Real x;
  Real[2] temp_1;
  Real[2] y;
 algorithm
  (temp_1) := FunctionTests.ArrayOutputScalarization11.f1();
  y[1] := temp_1[1];
  y[2] := temp_1[2];
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization11.f2;

 function FunctionTests.ArrayOutputScalarization11.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization11.f1;
end FunctionTests.ArrayOutputScalarization11;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2] = f1();
 algorithm
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization11;


model ArrayOutputScalarization12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization12",
         description="Scalarization of array function outputs: part of binding expression",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization12
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization12.f2();

 function FunctionTests.ArrayOutputScalarization12.f2
  output Real x;
  Real[2] temp_1;
  Real[2] y;
 algorithm
  (temp_1) := FunctionTests.ArrayOutputScalarization12.f1();
  y[1] := temp_1[1] + 3;
  y[2] := temp_1[2] + 4;
  x := y[1];
  return;
 end FunctionTests.ArrayOutputScalarization12.f2;

 function FunctionTests.ArrayOutputScalarization12.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization12.f1;
end FunctionTests.ArrayOutputScalarization12;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y[2] = f1() + {3, 4};
 algorithm
  x := y[1];
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization12;


model ArrayOutputScalarization13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization13",
         description="Scalarization of array function outputs: part of scalar binding exp",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization13
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization13.f2();

 function FunctionTests.ArrayOutputScalarization13.f2
  output Real x;
  Real[2] temp_1;
  Real y;
 algorithm
  (temp_1) := FunctionTests.ArrayOutputScalarization13.f1();
  y := temp_1[1] + temp_1[2];
  x := y;
  return;
 end FunctionTests.ArrayOutputScalarization13.f2;

 function FunctionTests.ArrayOutputScalarization13.f1
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization13.f1;
end FunctionTests.ArrayOutputScalarization13;
")})));

 function f1
  output Real x[2] = {1, 2};
 algorithm
 end f1;
 
 function f2
  output Real x;
  protected Real y = sum(f1());
 algorithm
  x := y;
 end f2;
 
 Real x = f2();
end ArrayOutputScalarization13;


model ArrayOutputScalarization14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization14",
         description="Scalarization of array function outputs: part of scalar expression",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization14
 Real x;
 Real temp_1[1];
 Real temp_1[2];
equation
 ({temp_1[1],temp_1[2]}) = FunctionTests.ArrayOutputScalarization14.f();
 x = ( temp_1[1] ) * ( 3 ) + ( temp_1[2] ) * ( 4 );

 function FunctionTests.ArrayOutputScalarization14.f
  output Real[2] x;
 algorithm
  x[1] := 1;
  x[2] := 2;
  return;
 end FunctionTests.ArrayOutputScalarization14.f;
end FunctionTests.ArrayOutputScalarization14;
")})));

 function f
  output Real x[2] = {1, 2};
 algorithm
 end f;
 
 Real x = f() * {3, 4};
end ArrayOutputScalarization14;


model ArrayOutputScalarization15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.GenericCodeGenTestCase(
         name="ArrayOutputScalarization15",
         description="Scalarization of array function outputs: number of equations",
         template="$n_equations$",
         generatedCode="3"
)})));

 function f
  output Real x[2] = {1,2};
  output Real y = 2;
 algorithm
 end f;
 
 Real x[2];
 Real y;
equation
 (x, y) = f();
end ArrayOutputScalarization15;


model ArrayOutputScalarization16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization16",
         description="Scalarization of array function outputs: using original arrays",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization16
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization16.f1();

 function FunctionTests.ArrayOutputScalarization16.f1
  output Real o;
  Real[2] x;
  Real[2] y;
  Real[2] temp_1;
 algorithm
  o := 2;
  x[1] := 1;
  x[2] := 2;
  (temp_1) := FunctionTests.ArrayOutputScalarization16.f2(x);
  y[1] := temp_1[1];
  y[2] := temp_1[2];
  return;
 end FunctionTests.ArrayOutputScalarization16.f1;

 function FunctionTests.ArrayOutputScalarization16.f2
  input Real[2] x;
  output Real[2] y;
 algorithm
  y[1] := x[1];
  y[2] := x[2];
  return;
 end FunctionTests.ArrayOutputScalarization16.f2;
end FunctionTests.ArrayOutputScalarization16;
")})));

 function f1
  output Real o = 2;
  protected Real x[2] = {1,2};
  protected Real y[2];
 algorithm
  y := f2(x);
 end f1;
 
 function f2
  input Real x[2];
  output Real y[2] = x;
 algorithm
 end f2;
 
 Real x = f1();
end ArrayOutputScalarization16;


model ArrayOutputScalarization17
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayOutputScalarization17",
         description="Scalarization of array function outputs: using original arrays",
         flatModel="
fclass FunctionTests.ArrayOutputScalarization17
 Real x;
equation
 x = FunctionTests.ArrayOutputScalarization17.f1();

 function FunctionTests.ArrayOutputScalarization17.f1
  output Real o;
  Real[2] y;
  Real[2] temp_1;
  Real[2] temp_2;
 algorithm
  o := 2;
  (temp_1) := FunctionTests.ArrayOutputScalarization17.f2({1,2});
  (temp_2) := FunctionTests.ArrayOutputScalarization17.f2(temp_1);
  y[1] := temp_2[1];
  y[2] := temp_2[2];
  return;
 end FunctionTests.ArrayOutputScalarization17.f1;

 function FunctionTests.ArrayOutputScalarization17.f2
  input Real[2] x;
  output Real[2] y;
 algorithm
  y[1] := x[1];
  y[2] := x[2];
  return;
 end FunctionTests.ArrayOutputScalarization17.f2;
end FunctionTests.ArrayOutputScalarization17;
")})));

 function f1
  output Real o = 2;
  protected Real y[2];
 algorithm
  y := f2(f2({1,2}));
 end f1;
 
 function f2
  input Real x[2];
  output Real y[2] = x;
 algorithm
 end f2;
 
 Real x = f1();
end ArrayOutputScalarization17;



/* ======================= Unknown array sizes ======================*/

model UnknownArray1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="UnknownArray1",
         description="Using functions with unknown array sizes: basic type test",
         flatModel="
fclass FunctionTests.UnknownArray1
 Real x[3] = FunctionTests.UnknownArray1.f({1,2,3});
 Real y[2] = FunctionTests.UnknownArray1.f({4,5});

 function FunctionTests.UnknownArray1.f
  input Real[:] a;
  output Real[size(a, 1)] b;
 algorithm
  b := a;
  return;
 end FunctionTests.UnknownArray1.f;
end FunctionTests.UnknownArray1;
")})));

 function f
  input Real a[:];
  output Real b[size(a,1)];
 algorithm
  b := a;
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});
end UnknownArray1;


model UnknownArray2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="UnknownArray2",
         description="Using functions with unknown array sizes: size from binding exp",
         flatModel="
fclass FunctionTests.UnknownArray2
 Real x[3] = FunctionTests.UnknownArray2.f({1,2,3});
 Real y[2] = FunctionTests.UnknownArray2.f({4,5});

 function FunctionTests.UnknownArray2.f
  input Real[:] a;
  output Real[size(a, 1)] b := a;
 algorithm
  return;
 end FunctionTests.UnknownArray2.f;
end FunctionTests.UnknownArray2;
")})));

 function f
  input Real a[:];
  output Real b[:] = a;
 algorithm
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});
end UnknownArray2;


model UnknownArray3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="UnknownArray3",
         description="Using functions with unknown array sizes: indirect dependency",
         flatModel="
fclass FunctionTests.UnknownArray3
 Real x[3] = FunctionTests.UnknownArray3.f({1,2,3});
 Real y[2] = FunctionTests.UnknownArray3.f({4,5});

 function FunctionTests.UnknownArray3.f
  input Real[:] a;
  output Real[size(c, 1)] b;
  Real[size(a, 1)] c;
 algorithm
  b := a;
  return;
 end FunctionTests.UnknownArray3.f;
end FunctionTests.UnknownArray3;
")})));

 function f
  input Real a[:];
  output Real b[size(c,1)];
  protected Real c[size(a,1)];
 algorithm
  b := a;
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});
end UnknownArray3;


model UnknownArray4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="UnknownArray4",
         description="Using functions with unknown array sizes: indirect dependency from binding exp",
         flatModel="
fclass FunctionTests.UnknownArray4
 Real x[3] = FunctionTests.UnknownArray4.f({1,2,3});
 Real y[2] = FunctionTests.UnknownArray4.f({4,5});

 function FunctionTests.UnknownArray4.f
  input Real[:] a;
  output Real[size(a, 1)] b := c;
  Real[size(a, 1)] c := a;
 algorithm
  return;
 end FunctionTests.UnknownArray4.f;
end FunctionTests.UnknownArray4;
")})));

 function f
  input Real a[:];
  output Real b[:] = c;
  protected Real c[:] = a;
 algorithm
 end f;
 
 Real x[3] = f({1,2,3});
 Real y[2] = f({4,5});
end UnknownArray4;


model UnknownArray5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="UnknownArray5",
         description="Using functions with unknown array sizes: multiple outputs",
         flatModel="
fclass FunctionTests.UnknownArray5
 Real x[3];
 Real y[3];
equation
 (x[1:3], y[1:3]) = FunctionTests.UnknownArray5.f({1,2,3});

 function FunctionTests.UnknownArray5.f
  input Real[:] a;
  output Real[size(a, 1)] b := c;
  output Real[size(a, 1)] c := a;
 algorithm
  return;
 end FunctionTests.UnknownArray5.f;
end FunctionTests.UnknownArray5;
")})));

 function f
  input Real a[:];
  output Real b[:] = c;
  output Real c[:] = a;
 algorithm
 end f;
 
 Real x[3];
 Real y[3];
equation
 (x, y) = f({1,2,3});
end UnknownArray5;


model UnknownArray6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownArray6",
         description="Using functions with unknown array sizes: wrong size",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 3747, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [3]
")})));

 function f
  input Real a[:];
  output Real b[:] = c;
  output Real c[:] = a;
 algorithm
 end f;
 
 Real x[2] = f({1,2,3});
end UnknownArray6;


model UnknownArray7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownArray7",
         description="Using functions with unknown array sizes: wrong size",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 3773, column 2:
  Calling function f(): types of component y and output c are not compatible
")})));

 function f
  input Real a[:];
  output Real b[:] = c;
  output Real c[:] = a;
 algorithm
 end f;
 
 Real x[3];
 Real y[2];
equation
 (x, y) = f({1,2,3});
end UnknownArray7;


model UnknownArray8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownArray8",
         description="Using functions with unknown array sizes: circular size",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 3796, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [size(b, 1)]
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 3796, column 14:
  Could not evaluate array size of output b
")})));

 function f
  input Real a[:];
  output Real b[size(b,1)];
 algorithm
  b := {1,2};
 end f;
 
 Real x[2] = f({1,2,3});
end UnknownArray8;


model UnknownArray9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="UnknownArray9",
         description="Unknown size calculated by adding sizes",
         flatModel="
fclass FunctionTests.UnknownArray9
 Real x[5,2] = FunctionTests.UnknownArray9.f({{1,2},{3,4}}, {{5,6},{7,8},{9,0}});

 function FunctionTests.UnknownArray9.f
  input Real[:, :] a;
  input Real[:, size(a, 2)] b;
  output Real[size(d, 1), size(d, 2)] c;
  Real[size(cat(1, a, b), 1), size(cat(1, a, b), 2)] d := cat(1, a, b);
 algorithm
  c := d;
  return;
 end FunctionTests.UnknownArray9.f;
end FunctionTests.UnknownArray9;
")})));

 function f
  input Real a[:,:];
  input Real b[:,size(a,2)];
  output Real c[size(d,1), size(d,2)];
  protected Real d[:,:] = cat(1, a, b);
 algorithm
  c := d;
 end f;
 
 Real x[5,2] = f({{1,2},{3,4}}, {{5,6},{7,8},{9,0}});
end UnknownArray9;


model UnknownArray10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray10",
         description="Scalarization of operations on arrays of unknown size: assignment",
         flatModel="
fclass FunctionTests.UnknownArray10
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.UnknownArray10.f({1,2});

 function FunctionTests.UnknownArray10.f
  input Real[:] a;
  output Real[size(a, 1)] b;
 algorithm
  for i1 in 1:size(b, 1) loop
   b[i1] := a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray10.f;
end FunctionTests.UnknownArray10;
")})));

 function f
  input Real a[:];
  output Real b[size(a,1)];
 algorithm
  b := a;
 end f;
 
 Real x[2] = f({1,2});
end UnknownArray10;


model UnknownArray11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray11",
         description="Scalarization of operations on arrays of unknown size: binding expression",
         flatModel="
fclass FunctionTests.UnknownArray11
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.UnknownArray11.f({1,2});

 function FunctionTests.UnknownArray11.f
  input Real[:] a;
  output Real[size(a, 1)] b;
 algorithm
  for i1 in 1:size(b, 1) loop
   b[i1] := a[i1];
  end for;
  return;
 end FunctionTests.UnknownArray11.f;
end FunctionTests.UnknownArray11;
")})));

 function f
  input Real a[:];
  output Real b[size(a,1)] = a;
 algorithm
 end f;
 
 Real x[2] = f({1,2});
end UnknownArray11;


model UnknownArray12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray12",
         description="Scalarization of operations on arrays of unknown size: element-wise expression",
         flatModel="
fclass FunctionTests.UnknownArray12
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.UnknownArray12.f({1,2}, {3,4}, 5);

 function FunctionTests.UnknownArray12.f
  input Real[:] a;
  input Real[:] b;
  input Real c;
  output Real[size(a, 1)] o;
 algorithm
  for i1 in 1:size(o, 1) loop
   o[i1] := ( c ) * ( a[i1] ) + ( 2 ) * ( b[i1] );
  end for;
  return;
 end FunctionTests.UnknownArray12.f;
end FunctionTests.UnknownArray12;
")})));

 function f
  input Real a[:];
  input Real b[:];
  input Real c;
  output Real o[size(a,1)];
 algorithm
  o := c * a + 2 * b;
 end f;
 
 Real x[2] = f({1,2}, {3,4}, 5);
end UnknownArray12;


model UnknownArray13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray13",
         description="Scalarization of operations on arrays of unknown size: element-wise binding expression",
         flatModel="
fclass FunctionTests.UnknownArray13
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.UnknownArray13.f({1,2}, {3,4}, 5);

 function FunctionTests.UnknownArray13.f
  input Real[:] a;
  input Real[:] b;
  input Real c;
  output Real[size(a, 1)] o;
 algorithm
  for i1 in 1:size(o, 1) loop
   o[i1] := ( c ) * ( a[i1] ) + ( 2 ) * ( b[i1] );
  end for;
  return;
 end FunctionTests.UnknownArray13.f;
end FunctionTests.UnknownArray13;
")})));

 function f
  input Real a[:];
  input Real b[:];
  input Real c;
  output Real o[size(a,1)] = c * a + 2 * b;
 algorithm
 end f;
 
 Real x[2] = f({1,2}, {3,4}, 5);
end UnknownArray13;


model UnknownArray14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray14",
         description="Scalarization of operations on arrays of unknown size: matrix multiplication",
         flatModel="
fclass FunctionTests.UnknownArray14
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 ({{x[1,1],x[1,2]},{x[2,1],x[2,2]}}) = FunctionTests.UnknownArray14.f({{1,2},{3,4}}, {{5,6},{7,8}});

 function FunctionTests.UnknownArray14.f
  input Real[:, :] a;
  input Real[size(a, 2), :] b;
  Real temp_1;
  output Real[size(a, 1), size(b, 2)] o;
 algorithm
  for i1 in 1:size(o, 1) loop
   for i2 in 1:size(o, 2) loop
    temp_1 := 0.0;
    for i3 in 1:size(a, 2) loop
     temp_1 := temp_1 + ( a[i1,i3] ) * ( b[i3,i2] );
    end for;
    o[i1,i2] := temp_1;
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray14.f;
end FunctionTests.UnknownArray14;
")})));

 function f
  input Real a[:,:];
  input Real b[size(a,2),:];
  output Real o[size(a,1),size(b,2)] = a * b;
 algorithm
 end f;
 
 Real x[2,2] = f({{1,2},{3,4}}, {{5,6},{7,8}});
end UnknownArray14;


model UnknownArray15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray15",
         description="Scalarization of operations on arrays of unknown size: vector multiplication",
         flatModel="
fclass FunctionTests.UnknownArray15
 Real x;
equation
 x = FunctionTests.UnknownArray15.f({1,2}, {3,4});

 function FunctionTests.UnknownArray15.f
  input Real[:] a;
  input Real[size(a, 1)] b;
  Real temp_1;
  output Real o;
 algorithm
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + ( a[i1] ) * ( b[i1] );
  end for;
  o := temp_1;
  return;
 end FunctionTests.UnknownArray15.f;
end FunctionTests.UnknownArray15;
")})));

 function f
  input Real a[:];
  input Real b[size(a,1)];
  output Real o = a * b;
 algorithm
 end f;
 
 Real x = f({1,2}, {3,4});
end UnknownArray15;


model UnknownArray16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray16",
         description="Scalarization of operations on arrays of unknown size: outside assignment",
         flatModel="
fclass FunctionTests.UnknownArray16
 Real x;
equation
 x = FunctionTests.UnknownArray16.f({1,2}, {3,4});

 function FunctionTests.UnknownArray16.f
  input Real[:] a;
  input Real[size(a, 1)] b;
  output Real o;
  Real temp_1;
 algorithm
  o := 1;
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + ( a[i1] ) * ( b[i1] );
  end for;
  if temp_1 < 4 then
   o := 2;
  end if;
  return;
 end FunctionTests.UnknownArray16.f;
end FunctionTests.UnknownArray16;
")})));

 function f
  input Real a[:];
  input Real b[size(a,1)];
  output Real o = 1;
 algorithm
  if a * b < 4 then
   o := 2;
  end if;
 end f;
 
 Real x = f({1,2}, {3,4});
end UnknownArray16;


model UnknownArray17
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray17",
         description="Scalarization of operations on arrays of unknown size: nestled multiplications",
         flatModel="
fclass FunctionTests.UnknownArray17
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 y[1,1] = 1;
 y[1,2] = 2;
 y[2,1] = 3;
 y[2,2] = 4;
 ({{x[1,1],x[1,2]},{x[2,1],x[2,2]}}) = FunctionTests.UnknownArray17.f({{y[1,1],y[1,2]},{y[2,1],y[2,2]}}, {{y[1,1],y[1,2]},{y[2,1],y[2,2]}}, {{y[1,1],y[1,2]},{y[2,1],y[2,2]}});

 function FunctionTests.UnknownArray17.f
  input Real[:, :] a;
  input Real[size(a, 2), :] b;
  input Real[size(b, 2), :] c;
  Real temp_1;
  Real temp_2;
  output Real[size(a, 1), size(c, 2)] o;
 algorithm
  for i1 in 1:size(o, 1) loop
   for i2 in 1:size(o, 2) loop
    temp_1 := 0.0;
    for i3 in 1:size(b, 2) loop
     temp_2 := 0.0;
     for i4 in 1:size(a, 2) loop
      temp_2 := temp_2 + ( a[i1,i4] ) * ( b[i4,i3] );
     end for;
     temp_1 := temp_1 + ( temp_2 ) * ( c[i3,i2] );
    end for;
    o[i1,i2] := temp_1;
   end for;
  end for;
  return;
 end FunctionTests.UnknownArray17.f;
end FunctionTests.UnknownArray17;
")})));

 function f
  input Real a[:,:];
  input Real b[size(a,2),:];
  input Real c[size(b,2),:];
  output Real[size(a, 1), size(c, 2)] o = a * b * c;
 algorithm
 end f;
 
 Real y[2,2] = {{1,2}, {3,4}};
 Real x[2,2] = f(y, y, y);
end UnknownArray17;


model UnknownArray18
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray18",
         description="Scalarization of operations on arrays of unknown size: already expressed as loop",
         flatModel="
fclass FunctionTests.UnknownArray18
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.UnknownArray18.f({1,2});

 function FunctionTests.UnknownArray18.f
  input Real[:] a;
  output Real[size(a, 1)] o;
 algorithm
  for i in 1:size(a, 1) loop
   o[i] := a[i] + i;
  end for;
  return;
 end FunctionTests.UnknownArray18.f;
end FunctionTests.UnknownArray18;
")})));

 function f
  input Real a[:];
  output Real o[size(a,1)];
 algorithm
  for i in 1:size(a,1) loop
   o[i] := a[i] + i;
  end for;
 end f;
 
  Real x[2] = f({1,2});
end UnknownArray18;


model UnknownArray19
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownArray19",
         description="Function inputs of unknown size: using size() of non-existent component",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 4226, column 7:
  Array size mismatch in declaration of x, size of declaration is [2, 2] and size of binding expression is [2, size(zeros(), 2)]
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 4226, column 16:
  Could not evaluate array size of output c
")})));

 function f
  input Real a[:,:];
  output Real[size(a, 1), size(b, 2)] c = a;
 algorithm
 end f;
 
 Real x[2,2] = f({{1,2}, {3,4}});
end UnknownArray19;


model UnknownArray20
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UnknownArray20",
         description="Function inputs of unknown size: scalarizing end",
         flatModel="
fclass FunctionTests.UnknownArray20
 Real x[1];
 Real x[2];
equation
 ({x[1],x[2]}) = FunctionTests.UnknownArray20.f({{1,2},{3,4}});

 function FunctionTests.UnknownArray20.f
  input Real[:, :] a;
  output Real[2] c;
 algorithm
  c[1] := a[1,1];
  c[2] := a[size(a, 1),size(a, 2)];
  return;
 end FunctionTests.UnknownArray20.f;
end FunctionTests.UnknownArray20;
")})));

 function f
  input Real a[:,:];
  output Real[2] c;
 algorithm
  c[1] := a[1,1];
  c[end] := a[end,end];
 end f;
 
 Real x[2] = f({{1,2}, {3,4}});
end UnknownArray20;



model IncompleteFunc1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="IncompleteFunc1",
         description="Wrong contents of called function: neither algorithm nor external",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 4251, column 11:
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));

 function f
  input Real x;
  output Real y = x;
 end f;
 
 Real x = f(2);
end IncompleteFunc1;


model IncompleteFunc2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="IncompleteFunc2",
         description="Wrong contents of called function: 2 algorithm",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 4276, column 11:
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));

 function f
  input Real x;
  output Real y = x;
 algorithm
  y := y + 1;
 algorithm
  y := y + 1;
 end f;
 
 Real x = f(2);
end IncompleteFunc2;


model IncompleteFunc3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="IncompleteFunc3",
         description="Wrong contents of called function: both algorithm and external",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 4300, column 11:
  Calling function f(): can only call functions that have one algorithm section or external function specification
")})));

 function f
  input Real x;
  output Real y = x;
 algorithm
  y := y + 1;
 external;
 end f;
 
 Real x = f(2);
end IncompleteFunc3;



model ExternalFunc1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExternalFunc1",
         description="External functions: simple func, all default",
         flatModel="
fclass FunctionTests.ExternalFunc1
 Real x = FunctionTests.ExternalFunc1.f(2);

 function FunctionTests.ExternalFunc1.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end FunctionTests.ExternalFunc1.f;
end FunctionTests.ExternalFunc1;
")})));

 function f
  input Real x;
  output Real y;
 external;
 end f;
 
 Real x = f(2);
end ExternalFunc1;


model ExternalFunc2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExternalFunc2",
         description="External functions: complex func, all default",
         flatModel="
fclass FunctionTests.ExternalFunc2
 Real x = FunctionTests.ExternalFunc2.f({{1,2},{3,4}}, 5);

 function FunctionTests.ExternalFunc2.f
  input Real[:, 2] x;
  input Real y;
  output Real z;
  output Real q;
  Real a := y + 2;
 algorithm
  external \"C\" f(x, size(x, 1), size(x, 2), y, z, q, a);
  return;
 end FunctionTests.ExternalFunc2.f;
end FunctionTests.ExternalFunc2;
")})));

 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
  protected Real a = y + 2;
 external;
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);
end ExternalFunc2;


model ExternalFunc3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExternalFunc3",
         description="External functions: complex func, call set",
         flatModel="
fclass FunctionTests.ExternalFunc3
 Real x = FunctionTests.ExternalFunc3.f({{1,2},{3,4}}, 5);

 function FunctionTests.ExternalFunc3.f
  input Real[:, 2] x;
  input Real y;
  output Real z;
  output Real q;
 algorithm
  external \"C\" foo(size(x, 1), 2, x, z, y, q);
  return;
 end FunctionTests.ExternalFunc3.f;
end FunctionTests.ExternalFunc3;
")})));

 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
 external foo(size(x,1), 2, x, z, y, q);
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);
end ExternalFunc3;


model ExternalFunc4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExternalFunc4",
         description="External functions: complex func, call and return set",
         flatModel="
fclass FunctionTests.ExternalFunc4
 Real x = FunctionTests.ExternalFunc4.f({{1,2},{3,4}}, 5);

 function FunctionTests.ExternalFunc4.f
  input Real[:, 2] x;
  input Real y;
  output Real z;
  output Real q;
 algorithm
  external \"C\" q = foo(size(x, 1), 2, x, z, y);
  return;
 end FunctionTests.ExternalFunc4.f;
end FunctionTests.ExternalFunc4;
")})));

 function f
  input Real x[:,2];
  input Real y;
  output Real z;
  output Real q;
 external q = foo(size(x,1), 2, x, z, y);
 end f;
 
 Real x = f({{1,2},{3,4}}, 5);
end ExternalFunc4;


model ExternalFunc5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExternalFunc5",
         description="External functions: simple func, language \"C\"",
         flatModel="
fclass FunctionTests.ExternalFunc5
 Real x = FunctionTests.ExternalFunc5.f(2);

 function FunctionTests.ExternalFunc5.f
  input Real x;
  output Real y;
 algorithm
  external \"C\" y = f(x);
  return;
 end FunctionTests.ExternalFunc5.f;
end FunctionTests.ExternalFunc5;
")})));

 function f
  input Real x;
  output Real y;
 external "C";
 end f;
 
 Real x = f(2);
end ExternalFunc5;


model ExternalFunc6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExternalFunc6",
         description="External functions: simple func, language \"FORTRAN 77\"",
         flatModel="
fclass FunctionTests.ExternalFunc6
 Real x = FunctionTests.ExternalFunc6.f(2);

 function FunctionTests.ExternalFunc6.f
  input Real x;
  output Real y;
 algorithm
  external \"FORTRAN 77\" y = f(x);
  return;
 end FunctionTests.ExternalFunc6.f;
end FunctionTests.ExternalFunc6;
")})));

 function f
  input Real x;
  output Real y;
 external "FORTRAN 77";
 end f;
 
 Real x = f(2);
end ExternalFunc6;


model ExternalFunc7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ExternalFunc7",
         description="External functions: simple func, language \"C++\"",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/FunctionTests.mo':
Semantic error at line 4508, column 2:
  The external language specification \"C++\" is not supported
")})));

 function f
  input Real x;
  output Real y;
 external "C++";
 end f;
 
 Real x = f(2);
end ExternalFunc7;



model ExternalFuncLibs1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs1",
         description="External function annotations, Library",
         methodName="externalLibraries",
         methodResult="[foo, m, bar]"
 )})));

 function f1
  input Real x;
  output Real y;
 external annotation(Library="foo");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="bar");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library={"bar", "m"});
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);
end ExternalFuncLibs1;


model ExternalFuncLibs2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs2",
         description="External function annotations, Include",
         methodName="externalIncludes",
         methodResult="[#include \"bar.h\", #include \"foo.h\"]"
 )})));

 function f1
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"");
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);
end ExternalFuncLibs2;


model ExternalFuncLibs3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs3",
         description="External function annotations, LibraryDirectory",
         methodName="externalLibraryDirectories",
         methodResult="[/c:/bar/lib, /c:/foo/lib]"
 )})));

 function f1
  input Real x;
  output Real y;
 external annotation(LibraryDirectory="file:///c:/foo/lib");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external;
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Library="bar", 
                     LibraryDirectory="file:///c:/bar/lib");
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
end ExternalFuncLibs3;


model ExternalFuncLibs4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs4",
         description="External function annotations, LibraryDirectory",
         methodName="externalLibraryDirectories",
		 filter=true, 
         methodResult="[%dir%/Resources/Library]"
 )})));
 function f1
  input Real x;
  output Real y;
 external annotation(Library="foo");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="bar");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
end ExternalFuncLibs4;


model ExternalFuncLibs5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs5",
         description="External function annotations, IncludeDirectory",
         methodName="externalIncludeDirectories",
	     filter=true, 
         methodResult="[/c:/foo/inc, /c:/bar/inc]"
 )})));

 function f1
  input Real x;
  output Real y;
 external annotation(IncludeDirectory="file:///c:/foo/inc");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"", 
                     IncludeDirectory="file:///c:/bar/inc");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
end ExternalFuncLibs5;


model ExternalFuncLibs6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs6",
         description="External function annotations, IncludeDirectory",
         methodName="externalIncludeDirectories",
		 filter=true, 
         methodResult="[%dir%/Resources/Include]"
 )})));

 function f1
  input Real x;
  output Real y;
 external annotation(Include="#include \"foo.h\"");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external;
 end f3;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
end ExternalFuncLibs6;


model ExternalFuncLibs7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs7",
         description="External function annotations, compiler args",
         methodName="externalCompilerArgs",
         methodResult=" -lfoo -lbar -L/c:/bar/lib -L/c:/std/lib -L/c:/foo/lib -I/c:/foo/inc -I/c:/std/inc -I/c:/bar/inc"
 )})));

 function f1
  input Real x;
  output Real y;
 external annotation(LibraryDirectory="file:///c:/std/lib", 
                     IncludeDirectory="file:///c:/std/inc");
 end f1;
 
 function f2
  input Real x;
  output Real y;
 external annotation(Library="foo",
                     LibraryDirectory="file:///c:/foo/lib",  
                     Include="#include \"foo.h\"", 
                     IncludeDirectory="file:///c:/foo/inc");
 end f2;
 
 function f3
  input Real x;
  output Real y;
 external annotation(Include="#include \"bar.h\"", 
                     IncludeDirectory="file:///c:/bar/inc", 
                     Library="bar", 
                     LibraryDirectory="file:///c:/bar/lib");
 end f3;
 
 function f4
  input Real x;
  output Real y;
 external;
 end f4;
 
 Real x1 = f1(1);
 Real x2 = f2(2);
 Real x3 = f3(3);
 Real x4 = f4(4);
end ExternalFuncLibs7;


model ExternalFuncLibs8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FClassMethodTestCase(
         name="ExternalFuncLibs8",
         description="External function annotations, compiler args",
         methodName="externalCompilerArgs",
	     filter=true, 
         methodResult=" -lfoo -L%dir%/Resources/Library -I%dir%/Resources/Include"
 )})));
 
 function f
  input Real x;
  output Real y;
 external annotation(Library="foo", 
                     Include="#include \"foo.h\"");
 end f;
 
 Real x = f(1);
end ExternalFuncLibs8;



model ExtendFunc1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="ExtendFunc1",
         description="Flattening of function extending other function",
         flatModel="
fclass FunctionTests.ExtendFunc1
 Real x = FunctionTests.ExtendFunc1.f2(1.0);

 function FunctionTests.ExtendFunc1.f2
  input Real a;
  output Real b;
 algorithm
  b := a;
  return;
 end FunctionTests.ExtendFunc1.f2;
end FunctionTests.ExtendFunc1;
")})));

    function f1
        input Real a;
        output Real b;
    end f1;
    
    function f2
        extends f1;
    algorithm
        b := a;
    end f2;
    
    Real x = f2(1.0);
end ExtendFunc1;



end FunctionTests;
