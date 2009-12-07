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


/* Temporary functions for C-tests */

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

model Test
 Real a1 = Func01();
 Real a2 = Func11();
 Real a3 = Func21();
 Real a4 = Func02();
 Real a5 = Func12();
 Real a6 = Func22();
end Test;


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
  Too many positional arguments
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
  Missing argument for required input i1
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Missing argument for required input i2
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
  Missing argument for required input i2
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
  Missing argument for required input i2
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
  No input matching named argument i3 found
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
  No input matching named argument o1 found
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
  Multiple arguments matches input i1
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
  Multiple arguments matches input i1
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
  The function NonExistingFunction is undeclared
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The function NonExistingFunction is undeclared
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
  The function notAFunction is undeclared
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  The function notAFunction is undeclared
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
  Types of positional argument 2 and input i2 are not compatible
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
  Types of positional argument 2 and input i2 are not compatible
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
  Types of positional argument 1 and input i1 are not compatible
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
  Types of positional argument 1 and input i1 are not compatible
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
  Types of component y and output o2 are not compatible
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
  Types of component x and output o1 are not compatible
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Types of component z and output o3 are not compatible
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
  Types of component z and output o3 are not compatible
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


model BuiltInCallType1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType1",
          description="Built-in type checks: passing Boolean literal to sin()",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Types of positional argument 1 and input u are not compatible
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
  Types of positional argument 1 and input x are not compatible
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
  Missing argument for required input u
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
  Missing argument for required input u2
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
  Types of positional argument 2 and input u2 are not compatible
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
  Argument of zeros() is not compatible with Integer
")})));

   Real x[3] = zeros(3.0);
end BuiltInCallType9;

model BuiltInCallType10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="BuiltInCallType10",
          description="Built-in type checks: calling ones() with String literal as second argument",
          errorMessage=
"
1 error(s) found...
In file 'FunctionTests.mo':
Semantic error at line 1, column 1:
  Argument of ones() is not compatible with Integer
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
 Real x;
 Real y;
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

 Real x;
 Real y;
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
 Real x;
 Real y;
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

 Real x;
 Real y;
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

/* =========================== Records =========================== */
/*
model RecordConstructorTest1 
model FunctionTests.RecordConstructorTest1

Real c1.re = 1;
Real c1.im = 1;
Real c2.re;
Real c2.im;
Real c3.re;
Real c3.im;
Real c4.re;
Real c4.im;

function FunctionTests.RecordConstructorTest1.Complex
  input Real re;
  input Real im;
  output FunctionTests.RecordConstructorTest1.Complex _out := FunctionTests.RecordConstructorTest1.Complex
    (
    re = re, 
    im = im
  );

algorithm 
end FunctionTests.RecordConstructorTest1.Complex;
function FunctionTests.RecordConstructorTest1.RestrictedComplex
  input Real re;
  input Real im := 0;
  output FunctionTests.RecordConstructorTest1.RestrictedComplex _out := 
    FunctionTests.RecordConstructorTest1.RestrictedComplex(
    re = re, 
    im = im
  );

algorithm 
end FunctionTests.RecordConstructorTest1.RestrictedComplex;
function FunctionTests.RecordConstructorTest1.add
  input FunctionTests.RecordConstructorTest1.Complex u;
  input FunctionTests.RecordConstructorTest1.Complex v;
  output FunctionTests.RecordConstructorTest1.Complex w := FunctionTests.RecordConstructorTest1.Complex
    (
    re = u.re+v.re, 
    im = u.im+v.im
  );

algorithm 
end FunctionTests.RecordConstructorTest1.add;
equation
c2 = FunctionTests.RecordConstructorTest1.add(
  c1, 
  FunctionTests.RecordConstructorTest1.Complex(sin(time), cos(time)));
c3 = FunctionTests.RecordConstructorTest1.add(
  c1, 
  c1);

end FunctionTests.RecordConstructorTest1;


  record Complex 
     Real re;
     Real im;
  end Complex;
    
  record RestrictedComplex = Complex(im=0);
    
  function add 
     input Complex u;
     input Complex v;
     output Complex w(re=u.re+v.re, im=u.im+v.im);
  algorithm 
  end add;
    
  Complex c1(re=1,im=1);
  Complex c2;
  Complex c3;
  Complex c4 = RestrictedComplex(re=0);
equation 
  c2=add(c1,Complex(sin(time),cos(time)));
c3=add(c1,c1);
end RecordConstructorTest1;
*/
  
end FunctionTests;
