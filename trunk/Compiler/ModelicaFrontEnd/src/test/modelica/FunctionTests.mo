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

function Test
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = 0;
 output Real o2 = i2;
algorithm
 o1 := i1;
end Test;

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
