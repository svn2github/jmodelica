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
model RecordConstructorTest1 

/*
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


*/
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
  
end FunctionTests;