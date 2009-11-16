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
algorithm
end TestFunction3;

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
 end FunctionTests.TestFunction2;

 function FunctionTests.TestFunction1
  input Real i1 := 0;
  output Real o1 := i1;
 algorithm
 end FunctionTests.TestFunction1;
end FunctionTests.FunctionFlatten3;
")})));

 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction1(y * 2);
end FunctionFlatten3;


model FunctionBinding1
 /* Should bind as TestFunction1(0) */
 Real x = TestFunction1();
end FunctionBinding1;

model FunctionBinding2
 /* Should bind as TestFunction1(1) */
 Real x = TestFunction1(1);
end FunctionBinding2;

model FunctionBinding3
 /* Should generate error (too many args) */
 Real x = TestFunction1(1, 2);
end FunctionBinding3;

model FunctionBinding4
 /* Should generate error (i1 has no value, i2 has no value) */
 Real x = TestFunction3();
end FunctionBinding4;

model FunctionBinding5
 /* Should generate error (i2 has no value) */
 Real x = TestFunction3(1);
end FunctionBinding5;

model FunctionBinding6
 /* Should bind as TestFunction3(1, 2, 0) */
 Real x = TestFunction3(1, 2);
end FunctionBinding6;

model FunctionBinding7
 /* Should bind as TestFunction0() */
 Real x = TestFunction0();
end FunctionBinding7;

model FunctionBinding8
 /* Should bind as TestFunction1(1) */
 Real x = TestFunction1(i1=1);
end FunctionBinding8;

model FunctionBinding9
 /* Should bind as TestFunction2(1, 2) */
 Real x = TestFunction2(i2=2, i1=1);
end FunctionBinding9;

model FunctionBinding10
 /* Should generate error (i2 has no value) */
 Real x = TestFunction3(1, i3=2);
end FunctionBinding10;

model FunctionBinding11
 /* Should generate error (no input "i3") */
 Real x = TestFunction2(i3=1);
end FunctionBinding11;

model FunctionBinding12
 /* Should generate error (no input "o1") */
 Real x = TestFunction2(o1=1);
end FunctionBinding12;

model FunctionBinding13
 /* Should generate error (i1 given value twice) */
 Real x = TestFunction2(1, 2, i1=3);
end FunctionBinding13;


model FunctionType1
 /* Should go through */
 Real x = TestFunction1(1.0);
end FunctionType1;

model FunctionType2
 /* Should go through? */
 Integer x = TestFunction1(1.0);
end FunctionType2;

model FunctionType3
 /* Should go through */
 Real a = 1.0;
 Real x = TestFunction1(a);
end FunctionType3;

model FunctionType4
 /* Should go through */
 Integer a = 1;
 Real x = TestFunction1(a);
end FunctionType3;

model FunctionType5
 /* Should generate error (type mismatch: i2) */
 Real x = TestFunction2(1, true);
end FunctionType5;

model FunctionType6
 /* Should generate error (type mismatch: i2) */
 Boolean a;
 Real x = TestFunction2(1, a);
end FunctionType6;

model FunctionType7
 /* Should go through */
 Integer a = 1;
 Real x = TestFunction2(TestFunction2(), TestFunction2(1));
end FunctionType7;

model FunctionType8
 /* Should generate error (type mismatch: TestFunction1.i1) */
 Integer a = 1;
 Real x = TestFunction2(TestFunction1(True), TestFunction2(1));
end FunctionType8;


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
                                               description="Flattening algorithms: break & return stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten2
 Real x;
algorithm
 break;
 return;
end FunctionTests.AlgorithmFlatten2;
")})));

 Real x;
algorithm
 break;
 return;
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
    x := x - 1;
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
      JModelica.UnitTesting.FlatteningTestCase(name="AlgorithmFlatten6",
                                               description="Flattening algorithms: for stmts",
                                               flatModel="
fclass FunctionTests.AlgorithmFlatten6
 Real x;
algorithm
 for i in {1, 2, 4}, j in 1:3 loop
  x := x + ( i ) * ( j );
 end for;
end FunctionTests.AlgorithmFlatten6;
")})));

 Real x;
algorithm
 for i in {1, 2, 4}, j in 1:3 loop
  x := x + i * j;
 end for;
end AlgorithmFlatten6;


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
