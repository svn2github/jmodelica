/*
    Copyright (C) 2011 Modelon AB

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


package FunctionInlining
    
    model BasicInline1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline1",
         description="Most basic inlining case",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline1
 Real x;
 constant Integer temp_1 = 1;
 constant Integer temp_2 = 1;
equation
 x = 1;

 function FunctionInlining.BasicInline1.f
  input Real a;
  output Real b;
 algorithm
  b := a;
  return;
 end FunctionInlining.BasicInline1.f;
end FunctionInlining.BasicInline1;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
	        end f;
        
        Real x = f(1);
    end BasicInline1;
       
	   
    model BasicInline2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline2",
         description="More complicated inlining case with only assignments and constant argument",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline2
 Real x;
 constant Real y = 2;
 constant Real temp_1 = 1.0;
 constant Real temp_2 = 1.0;
 constant Real temp_3 = 3.0;
 constant Real temp_4 = 2.0;
 constant Real temp_5 = 8.0;
 constant Real temp_6 = 1.0;
 constant Real temp_7 = 2.0;
equation
 x = 2.0;

 function FunctionInlining.BasicInline2.f
  input Real a;
  output Real b;
  Real c;
  Real d;
  Real e;
  Real f;
 algorithm
  c := a;
  d := ( 2 ) * ( c ) + a;
  c := ( d ) / ( 3 ) + 1;
  e := c ^ d;
  f := e - ( c ) - ( d ) - ( c );
  b := f + 1;
  return;
 end FunctionInlining.BasicInline2.f;
end FunctionInlining.BasicInline2;
")})));

        function f
            input Real a;
            output Real b;
        protected
            Real c;
            Real d;
            Real e;
            Real f;
        algorithm
            c := a;
            d := 2 * c + a;
            c := d / 3 + 1;
            e := c ^ d;
            f := e - c - d - c;
            b := f + 1;
        end f;
        
        Real x = f(y - 1);
        constant Real y = 2;
    end BasicInline2;
       
	   
    model BasicInline3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline3",
         description="More complicated inlining case with only assignments and continous argument",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline3
 Real x;
 Real y;
 Real temp_1;
 Real temp_2;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
equation
 x = temp_7;
 y = time;
 temp_1 = y + 1;
 temp_2 = temp_1;
 temp_3 = ( 2 ) * ( temp_2 ) + temp_1;
 temp_4 = ( temp_3 ) / ( 3 ) + 1;
 temp_5 = temp_4 ^ temp_3;
 temp_6 = temp_5 - ( temp_4 ) - ( temp_3 ) - ( temp_4 );
 temp_7 = temp_6 + 1;

 function FunctionInlining.BasicInline3.f
  input Real a;
  output Real b;
  Real c;
  Real d;
  Real e;
  Real f;
 algorithm
  c := a;
  d := ( 2 ) * ( c ) + a;
  c := ( d ) / ( 3 ) + 1;
  e := c ^ d;
  f := e - ( c ) - ( d ) - ( c );
  b := f + 1;
  return;
 end FunctionInlining.BasicInline3.f;
end FunctionInlining.BasicInline3;
")})));

        function f
            input Real a;
            output Real b;
        protected
            Real c;
            Real d;
            Real e;
            Real f;
        algorithm
            c := a;
            d := 2 * c + a;
            c := d / 3 + 1;
            e := c ^ d;
            f := e - c - d - c;
            b := f + 1;
        end f;
        
        Real x = f(y + 1);
        Real y = time;
    end BasicInline3;
       
	   
    model BasicInline4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline4",
         description="Test of alias elimination after inlining",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.BasicInline4
 Real x;
 Real y;
equation
 y = time;
 x = y + y;

 function FunctionInlining.BasicInline4.f
  input Real a;
  output Real b;
  Real c;
  Real d;
  Real e;
  Real f;
 algorithm
  c := a;
  d := c;
  c := d;
  e := c + d;
  f := e;
  b := f;
  return;
 end FunctionInlining.BasicInline4.f;
end FunctionInlining.BasicInline4;
")})));

        function f
            input Real a;
            output Real b;
        protected
            Real c;
            Real d;
            Real e;
            Real f;
        algorithm
            c := a;
            d := c;
            c := d;
            e := c + d;
            f := e;
            b := f;
        end f;
        
        Real x = f(y);
        Real y = time;
    end BasicInline4;
       
	   
    model BasicInline5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline5",
         description="Test of inlining of function that would be aggresively alias eliminated, 
		              to make sure that all vars are generated properly",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline5
 Real x;
 Real y;
 Real temp_1;
 Real temp_2;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
equation
 x = temp_7;
 y = time;
 temp_1 = y;
 temp_2 = temp_1;
 temp_3 = temp_2;
 temp_4 = temp_3;
 temp_5 = temp_4 + temp_3;
 temp_6 = temp_5;
 temp_7 = temp_6;

 function FunctionInlining.BasicInline5.f
  input Real a;
  output Real b;
  Real c;
  Real d;
  Real e;
  Real f;
 algorithm
  c := a;
  d := c;
  c := d;
  e := c + d;
  f := e;
  b := f;
  return;
 end FunctionInlining.BasicInline5.f;
end FunctionInlining.BasicInline5;
")})));

        function f
            input Real a;
            output Real b;
        protected
            Real c;
            Real d;
            Real e;
            Real f;
        algorithm
            c := a;
            d := c;
            c := d;
            e := c + d;
            f := e;
            b := f;
        end f;
        
        Real x = f(y);
        Real y = time;
    end BasicInline5;
    
	
    model BasicInline6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline6",
         description="Inlining of function using arrays and only assignments",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline6
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 Real temp_2[1];
 Real temp_2[2];
 Real temp_2[3];
 Real temp_3;
 Real temp_4[1];
 Real temp_4[2];
 Real temp_4[3];
equation
 x[1] = temp_4[1];
 x[2] = temp_4[2];
 x[3] = temp_4[3];
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 temp_1[1] = y[1];
 temp_1[2] = y[2];
 temp_1[3] = y[3];
 temp_2[1] = temp_1[1];
 temp_2[2] = temp_1[2];
 temp_2[3] = temp_1[3];
 temp_3 = ( temp_1[1] ) * ( temp_2[1] ) + ( temp_1[2] ) * ( temp_2[2] ) + ( temp_1[3] ) * ( temp_2[3] );
 temp_4[1] = ( temp_3 ) * ( temp_1[1] + temp_2[1] );
 temp_4[2] = ( temp_3 ) * ( temp_1[2] + temp_2[2] );
 temp_4[3] = ( temp_3 ) * ( temp_1[3] + temp_2[3] );

 function FunctionInlining.BasicInline6.f
  input Real[:] a;
  output Real[size(a, 1)] b;
  Real[size(a, 1)] c;
  Real d;
  Real temp_1;
 algorithm
  for i1 in 1:size(c, 1) loop
   c[i1] := a[i1];
  end for;
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + ( a[i1] ) * ( c[i1] );
  end for;
  d := temp_1;
  for i1 in 1:size(b, 1) loop
   b[i1] := ( d ) * ( a[i1] + c[i1] );
  end for;
  return;
 end FunctionInlining.BasicInline6.f;
end FunctionInlining.BasicInline6;
")})));

        function f
            input Real[:] a;
            output Real[size(a,1)] b;
        protected
            Real[size(a,1)] c;
            Real d;
        algorithm
            c := a[end:-1:1];
            d := a * c;
            b := d * (a + c);
        end f;
        
        Real x[:] = f(y);
        Real y[3] = { 1, 2, 3 };
    end BasicInline6;
    
	
    model BasicInline7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline7",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline7
 Real x;
 Real y;
 Real temp_1;
 Real temp_2;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
 Real temp_8;
 Real temp_9;
equation
 x = temp_3;
 y = 1;
 temp_1 = y;
 temp_2 = ( temp_1 ) * ( 2 );
 temp_3 = temp_6 + temp_9;
 temp_4 = temp_1;
 temp_5 = ( temp_4 ) * ( 2 );
 temp_6 = temp_4 + temp_5;
 temp_7 = temp_2;
 temp_8 = ( temp_7 ) * ( 2 );
 temp_9 = temp_7 + temp_8;

 function FunctionInlining.BasicInline7.f2
  input Real a;
  output Real b;
  Real c;
 algorithm
  c := ( a ) * ( 2 );
  b := FunctionInlining.BasicInline7.f1(a) + FunctionInlining.BasicInline7.f1(c);
  return;
 end FunctionInlining.BasicInline7.f2;

 function FunctionInlining.BasicInline7.f1
  input Real a;
  output Real b;
  Real c;
 algorithm
  c := ( a ) * ( 2 );
  b := a + c;
  return;
 end FunctionInlining.BasicInline7.f1;
end FunctionInlining.BasicInline7;
")})));

        function f1
            input Real a;
            output Real b;
        protected
            Real c;
        algorithm
            c := a * 2;
            b := (a + c);
        end f1;
        
	    function f2
            input Real a;
            output Real b;
        protected
            Real c;
        algorithm
            c := a * 2;
            b := f1(a) + f1(c);
        end f2;
        
	    Real x = f2(y);
        Real y = 1;
    end BasicInline7;
    
	
    model BasicInline8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline8",
         description="Inlining function with both function calls and arrays",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline8
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 Real temp_2[1];
 Real temp_2[2];
 Real temp_2[3];
 Real temp_3[1];
 Real temp_3[2];
 Real temp_3[3];
 Real temp_4[1];
 Real temp_4[2];
 Real temp_4[3];
 Real temp_5[1];
 Real temp_5[2];
 Real temp_5[3];
 Real temp_6;
 Real temp_7[1];
 Real temp_7[2];
 Real temp_7[3];
 Real temp_8[1];
 Real temp_8[2];
 Real temp_8[3];
 Real temp_9[1];
 Real temp_9[2];
 Real temp_9[3];
 Real temp_10;
 Real temp_11[1];
 Real temp_11[2];
 Real temp_11[3];
equation
 x[1] = temp_3[1];
 x[2] = temp_3[2];
 x[3] = temp_3[3];
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 temp_1[1] = y[1];
 temp_1[2] = y[2];
 temp_1[3] = y[3];
 temp_2[1] = ( temp_1[1] ) * ( 2 );
 temp_2[2] = ( temp_1[2] ) * ( 2 );
 temp_2[3] = ( temp_1[3] ) * ( 2 );
 temp_3[1] = temp_7[1] + temp_11[1];
 temp_3[2] = temp_7[2] + temp_11[2];
 temp_3[3] = temp_7[3] + temp_11[3];
 temp_4[1] = temp_1[1];
 temp_4[2] = temp_1[2];
 temp_4[3] = temp_1[3];
 temp_5[1] = temp_4[1];
 temp_5[2] = temp_4[2];
 temp_5[3] = temp_4[3];
 temp_6 = ( temp_4[1] ) * ( temp_5[1] ) + ( temp_4[2] ) * ( temp_5[2] ) + ( temp_4[3] ) * ( temp_5[3] );
 temp_7[1] = ( temp_6 ) * ( temp_4[1] + temp_5[1] );
 temp_7[2] = ( temp_6 ) * ( temp_4[2] + temp_5[2] );
 temp_7[3] = ( temp_6 ) * ( temp_4[3] + temp_5[3] );
 temp_8[1] = temp_2[1];
 temp_8[2] = temp_2[2];
 temp_8[3] = temp_2[3];
 temp_9[1] = temp_8[1];
 temp_9[2] = temp_8[2];
 temp_9[3] = temp_8[3];
 temp_10 = ( temp_8[1] ) * ( temp_9[1] ) + ( temp_8[2] ) * ( temp_9[2] ) + ( temp_8[3] ) * ( temp_9[3] );
 temp_11[1] = ( temp_10 ) * ( temp_8[1] + temp_9[1] );
 temp_11[2] = ( temp_10 ) * ( temp_8[2] + temp_9[2] );
 temp_11[3] = ( temp_10 ) * ( temp_8[3] + temp_9[3] );

 function FunctionInlining.BasicInline8.f2
  input Real[:] a;
  output Real[size(a, 1)] b;
  Real[size(a, 1)] c;
  Real[size(a, 1)] temp_1;
  Real[size(c, 1)] temp_2;
 algorithm
  for i1 in 1:size(c, 1) loop
   c[i1] := ( a[i1] ) * ( 2 );
  end for;
  for i1 in 1:size(b, 1) loop
   (temp_1) := FunctionInlining.BasicInline8.f1(a);
   (temp_2) := FunctionInlining.BasicInline8.f1(c);
   b[i1] := temp_1[i1] + temp_2[i1];
  end for;
  return;
 end FunctionInlining.BasicInline8.f2;

 function FunctionInlining.BasicInline8.f1
  input Real[:] a;
  output Real[size(a, 1)] b;
  Real[size(a, 1)] c;
  Real d;
  Real temp_1;
 algorithm
  for i1 in 1:size(c, 1) loop
   c[i1] := a[i1];
  end for;
  temp_1 := 0.0;
  for i1 in 1:size(a, 1) loop
   temp_1 := temp_1 + ( a[i1] ) * ( c[i1] );
  end for;
  d := temp_1;
  for i1 in 1:size(b, 1) loop
   b[i1] := ( d ) * ( a[i1] + c[i1] );
  end for;
  return;
 end FunctionInlining.BasicInline8.f1;
end FunctionInlining.BasicInline8;
")})));

        function f1
            input Real[:] a;
            output Real[size(a,1)] b;
        protected
            Real[size(a,1)] c;
            Real d;
        algorithm
            c := a[end:-1:1];
            d := a * c;
            b := d * (a + c);
        end f1;
        
        function f2
            input Real[:] a;
            output Real[size(a,1)] b;
        protected
            Real[size(a,1)] c;
        algorithm
            c := a * 2;
            b := f1(a) + f1(c);
        end f2;
        
        Real x[:] = f2(y);
        Real y[3] = { 1, 2, 3 };
    end BasicInline8;
    
    
    model BasicInline9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline9",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline9
 parameter Real temp_1;
 parameter Real y = 2 /* 2 */;
 parameter Real temp_2;
 parameter Real temp_3;
 parameter Real temp_4;
 parameter Real temp_5;
 parameter Real temp_6;
 parameter Real temp_7;
 parameter Real x;
parameter equation
 temp_1 = y - ( 1 );
 temp_2 = temp_1;
 temp_3 = ( 2 ) * ( temp_2 ) + temp_1;
 temp_4 = ( temp_3 ) / ( 3 ) + 1;
 temp_5 = temp_4 ^ temp_3;
 temp_6 = temp_5 - ( temp_4 ) - ( temp_3 ) - ( temp_4 );
 temp_7 = temp_6 + 1;
 x = temp_7;

 function FunctionInlining.BasicInline9.f
  input Real a;
  output Real b;
  Real c;
  Real d;
  Real e;
  Real f;
 algorithm
  c := a;
  d := ( 2 ) * ( c ) + a;
  c := ( d ) / ( 3 ) + 1;
  e := c ^ d;
  f := e - ( c ) - ( d ) - ( c );
  b := f + 1;
  return;
 end FunctionInlining.BasicInline9.f;
end FunctionInlining.BasicInline9;
")})));

        function f
            input Real a;
            output Real b;
        protected
            Real c;
            Real d;
            Real e;
            Real f;
        algorithm
            c := a;
            d := 2 * c + a;
            c := d / 3 + 1;
            e := c ^ d;
            f := e - c - d - c;
            b := f + 1;
		end f;
		
        parameter Real x = f(y - 1);
        parameter Real y = 2;
    end BasicInline9;
	
end FunctionInlining;
