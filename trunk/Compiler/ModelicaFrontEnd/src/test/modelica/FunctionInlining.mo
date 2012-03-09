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
         flatModel="
fclass FunctionInlining.BasicInline1
 Real x;
equation
 x = 1;
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
         flatModel="
fclass FunctionInlining.BasicInline2
 Real x;
 constant Real y = 2;
equation
 x = 2.0;
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
 temp_2[1] = temp_1[3];
 temp_2[2] = temp_1[2];
 temp_2[3] = temp_1[1];
 temp_3 = ( temp_1[1] ) * ( temp_2[1] ) + ( temp_1[2] ) * ( temp_2[2] ) + ( temp_1[3] ) * ( temp_2[3] );
 temp_4[1] = ( temp_3 ) * ( temp_1[1] + temp_2[1] );
 temp_4[2] = ( temp_3 ) * ( temp_1[2] + temp_2[2] );
 temp_4[3] = ( temp_3 ) * ( temp_1[3] + temp_2[3] );
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
 temp_5[1] = temp_4[3];
 temp_5[2] = temp_4[2];
 temp_5[3] = temp_4[1];
 temp_6 = ( temp_4[1] ) * ( temp_5[1] ) + ( temp_4[2] ) * ( temp_5[2] ) + ( temp_4[3] ) * ( temp_5[3] );
 temp_7[1] = ( temp_6 ) * ( temp_4[1] + temp_5[1] );
 temp_7[2] = ( temp_6 ) * ( temp_4[2] + temp_5[2] );
 temp_7[3] = ( temp_6 ) * ( temp_4[3] + temp_5[3] );
 temp_8[1] = temp_2[1];
 temp_8[2] = temp_2[2];
 temp_8[3] = temp_2[3];
 temp_9[1] = temp_8[3];
 temp_9[2] = temp_8[2];
 temp_9[3] = temp_8[1];
 temp_10 = ( temp_8[1] ) * ( temp_9[1] ) + ( temp_8[2] ) * ( temp_9[2] ) + ( temp_8[3] ) * ( temp_9[3] );
 temp_11[1] = ( temp_10 ) * ( temp_8[1] + temp_9[1] );
 temp_11[2] = ( temp_10 ) * ( temp_8[2] + temp_9[2] );
 temp_11[3] = ( temp_10 ) * ( temp_8[3] + temp_9[3] );
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


    model BasicInline10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline10",
         description="Using array indices",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline10
 parameter Integer e = 2 /* 2 */;
 Real x;
 Real y;
 Real z[1];
 Real z[2];
 Real z[3];
 Real temp_1;
 Real temp_2[1];
 Real temp_2[2];
 Real temp_2[3];
 parameter Integer temp_3;
 Real temp_4;
parameter equation
 temp_3 = e;
equation
 x = temp_4;
 y = 2.2;
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;
 temp_1 = y;
 temp_2[1] = z[1];
 temp_2[2] = z[2];
 temp_2[3] = z[3];
 temp_4 = ( temp_1 ) * ( temp_2[2] );
end FunctionInlining.BasicInline10;
")})));

        function f
            input Real a;
            input Real[:] b;
            input Integer c;
            output Real d;
        algorithm
            d := a * b[c];
            end f;
        
        parameter Integer e = 2;
        Real x = f(y, z, e);
        Real y = 2.2;
        Real[:] z = { 1, 2, 3 };
    end BasicInline10;


    model BasicInline11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline11",
         description="Function call as array index",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.BasicInline11
 parameter Integer e = 1 /* 1 */;
 Real x;
 Real y[1];
 Real y[2];
 Real y[3];
 parameter Integer temp_1;
 parameter Integer temp_2;
parameter equation
 temp_1 = e;
 temp_2 = 4 - ( temp_1 );
equation
 x = y[3];
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
end FunctionInlining.BasicInline11;
")})));

        function f
            input Integer a;
            output Integer b;
        algorithm
            b := 4 - a;
            end f;
        
        parameter Integer e = 1;
        Real x = y[f(e)];
        Real[:] y = { 1, 2, 3 };
    end BasicInline11;


    model BasicInline12
        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
		Real[2] y = {1,2};
        Real x(start=1);
	equation
		if x > 3 then
			der(x) = f(y[1]);
	    else
            der(x) = f(y[2]);
		end if;
    end BasicInline12;
    
    
    model RecordInline1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline1",
         description="Inlining function taking constant record arg",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline1
 Real x;
equation
 x = 10;

 record FunctionInlining.RecordInline1.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline1.R;
end FunctionInlining.RecordInline1;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input R c;
            output Real d;
        algorithm
            d := c.b + sum(c.a);
        end f;
        
        Real x = f(R({1,2,3}, 4));
    end RecordInline1;
    
    
    model RecordInline2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline2",
         description="Inlining function returning recor, constant args",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline2
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
initial equation 
 x.pre(b) = 0;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.a[3] = 3;
 x.b = 2;

 record FunctionInlining.RecordInline2.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline2.R;
end FunctionInlining.RecordInline2;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input Real c;
            output R d;
        algorithm
            d := R({1,2,3} * c, 2);
        end f;
        
        R x = f(1);
    end RecordInline2;
    
    
    model RecordInline3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline3",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline3
 Real x;
equation
 x = 10;

 record FunctionInlining.RecordInline3.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline3.R;
end FunctionInlining.RecordInline3;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input Real c;
            output Real d;
        protected
            R e;
        algorithm
            e := R({1,2,3} * c, 4);
            d := sum(e.a) + c * e.b;
        end f;
        
        Real x = f(1);
    end RecordInline3;
    
    
    model RecordInline4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline4",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.RecordInline4
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real x;
 Real temp_1.a[1];
 Real temp_1.a[2];
 Real temp_1.a[3];
 discrete Integer temp_1.b;
 Real temp_2;
initial equation 
 temp_1.pre(b) = 0;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;
 x = temp_2;
 temp_1.a[1] = y[1];
 temp_1.a[2] = y[2];
 temp_1.a[3] = y[3];
 temp_1.b = integer(y[4]);
 temp_2 = temp_1.b + temp_1.a[1] + temp_1.a[2] + temp_1.a[3];

 record FunctionInlining.RecordInline4.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline4.R;
end FunctionInlining.RecordInline4;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input R c;
            output Real d;
        algorithm
            d := c.b + sum(c.a);
        end f;
        
		Real y[4] = {1,2,3,4};
        Real x = f(R(y[1:3], integer(y[4])));
    end RecordInline4;
    
    
    model RecordInline5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline5",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.RecordInline5
 Real y;
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
 Real temp_1;
 Real temp_2.a[1];
 Real temp_2.a[2];
 Real temp_2.a[3];
 discrete Integer temp_2.b;
initial equation 
 x.pre(b) = 0;
 temp_2.pre(b) = 0;
equation
 y = 1;
 x.a[1] = temp_2.a[1];
 x.a[2] = temp_2.a[2];
 x.a[3] = temp_2.a[3];
 x.b = temp_2.b;
 temp_1 = y;
 temp_2.a[1] = ( 1 ) * ( temp_1 );
 temp_2.a[2] = ( 2 ) * ( temp_1 );
 temp_2.a[3] = ( 3 ) * ( temp_1 );
 temp_2.b = 2;

 record FunctionInlining.RecordInline5.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline5.R;
end FunctionInlining.RecordInline5;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input Real c;
            output R d;
        algorithm
            d := R({1,2,3} * c, 2);
        end f;
        
		Real y = 1;
        R x = f(y);
    end RecordInline5;
    
    
    model RecordInline6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline6",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.RecordInline6
 Real y;
 Real x;
 Real temp_1;
 Real temp_2.a[1];
 Real temp_2.a[2];
 Real temp_2.a[3];
 discrete Integer temp_2.b;
 Real temp_3;
initial equation 
 temp_2.pre(b) = 0;
equation
 y = 1;
 x = temp_3;
 temp_1 = y;
 temp_2.a[1] = ( 1 ) * ( temp_1 );
 temp_2.a[2] = ( 2 ) * ( temp_1 );
 temp_2.a[3] = ( 3 ) * ( temp_1 );
 temp_2.b = 4;
 temp_3 = temp_2.a[1] + temp_2.a[2] + temp_2.a[3] + ( temp_1 ) * ( temp_2.b );

 record FunctionInlining.RecordInline6.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline6.R;
end FunctionInlining.RecordInline6;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input Real c;
            output Real d;
        protected
            R e;
        algorithm
            e := R({1,2,3} * c, 4);
            d := sum(e.a) + c * e.b;
        end f;
        
        Real y = 1;
        Real x = f(y);
    end RecordInline6;
    
    
    model RecordInline7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline7",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.RecordInline7
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
 Real temp_1.a[1];
 Real temp_1.a[2];
 Real temp_1.a[3];
 discrete Integer temp_1.b;
 Real temp_2.a[1];
 Real temp_2.a[2];
 Real temp_2.a[3];
 discrete Integer temp_2.b;
 Real temp_3.a[1];
 Real temp_3.a[2];
 Real temp_3.a[3];
 discrete Integer temp_3.b;
 Real temp_4.a[1];
 Real temp_4.a[2];
 Real temp_4.a[3];
 discrete Integer temp_4.b;
 Real temp_5.a[1];
 Real temp_5.a[2];
 Real temp_5.a[3];
 discrete Integer temp_5.b;
initial equation 
 x.pre(b) = 0;
 temp_1.pre(b) = 0;
 temp_2.pre(b) = 0;
 temp_3.pre(b) = 0;
 temp_4.pre(b) = 0;
 temp_5.pre(b) = 0;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;
 x.a[1] = temp_5.a[1];
 x.a[2] = temp_5.a[2];
 x.a[3] = temp_5.a[3];
 x.b = temp_5.b;
 temp_1.a[1] = y[1];
 temp_1.a[2] = y[2];
 temp_1.a[3] = y[3];
 temp_1.b = integer(y[4]);
 temp_2.a[1] = temp_1.a[1];
 temp_2.a[2] = temp_1.a[2];
 temp_2.a[3] = temp_1.a[3];
 temp_2.b = temp_1.b;
 temp_3.a[1] = temp_2.a[1] + temp_1.a[1];
 temp_3.a[2] = temp_2.a[2] + temp_1.a[2];
 temp_3.a[3] = temp_2.a[3] + temp_1.a[3];
 temp_3.b = temp_2.b - ( temp_1.b );
 temp_4.a[1] = ( ( temp_1.a[1] ) * ( temp_2.a[1] ) + ( temp_1.a[2] ) * ( temp_2.a[2] ) + ( temp_1.a[3] ) * ( temp_2.a[3] ) ) * ( temp_3.a[1] );
 temp_4.a[2] = ( ( temp_1.a[1] ) * ( temp_2.a[1] ) + ( temp_1.a[2] ) * ( temp_2.a[2] ) + ( temp_1.a[3] ) * ( temp_2.a[3] ) ) * ( temp_3.a[2] );
 temp_4.a[3] = ( ( temp_1.a[1] ) * ( temp_2.a[1] ) + ( temp_1.a[2] ) * ( temp_2.a[2] ) + ( temp_1.a[3] ) * ( temp_2.a[3] ) ) * ( temp_3.a[3] );
 temp_4.b = 3;
 temp_5.a[1] = temp_4.a[1] - ( temp_1.a[1] );
 temp_5.a[2] = temp_4.a[2] - ( temp_1.a[2] );
 temp_5.a[3] = temp_4.a[3] - ( temp_1.a[3] );
 temp_5.b = temp_4.b + temp_3.b;

 record FunctionInlining.RecordInline7.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline7.R;
end FunctionInlining.RecordInline7;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input R c;
            output R d;
        protected
            R e;
            R g;
            R h;
        algorithm
			e := c;
			g := R(e.a + c.a, e.b - c.b);
			h := R(c.a * e.a * g.a, 3);
			d := R(h.a - c.a, h.b + g.b);
        end f;
        
        Real y[4] = {1,2,3,4};
        R x = f(R(y[1:3], integer(y[4])));
    end RecordInline7;
    
    
    model RecordInline8
        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input Real c;
            output R d;
        algorithm
            d.a[1] := 2 / c;
            d.a[2] := 3 + c;
            d.a[2] := 4 * c;
            d.b := integer(5 - c);
        end f;
        
        Real y = 1;
        R x = f(y);
    end RecordInline8;
    
    
    model RecordInline9
        record R
            Real a[3];
            Integer b;
        end R;
        
        function f
            input Real c;
            output R d;
        algorithm
            d.a[1] := 2 / c;
            d.a[2] := 3 + c;
            d.a[2] := 4 * c;
            d.b := integer(5 - c);
        end f;
        
        R x = f(1);
    end RecordInline9;
	
	
	model UninlinableFunction1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="UninlinableFunction1",
         description="Make sure that only unused functions are removed",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.UninlinableFunction1
 Real z[1];
 Real z[2];
 Real z[3];
 Real w[1];
 Real w[2];
 Real temp_1;
 Real temp_2;
equation
 w[1] = FunctionInlining.UninlinableFunction1.f1(z[2], z[3]);
 w[2] = temp_2;
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;
 temp_1 = z[1];
 temp_2 = temp_1;

 function FunctionInlining.UninlinableFunction1.f4
  input Real x;
  output Real y;
 algorithm
  y := x;
  return;
 end FunctionInlining.UninlinableFunction1.f4;

 function FunctionInlining.UninlinableFunction1.f1
  input Real x1;
  input Real x2;
  output Real y;
 algorithm
  y := FunctionInlining.UninlinableFunction1.f4(x1);
  while y < x2 loop
   y := y + FunctionInlining.UninlinableFunction1.f3(x1, x2);
  end while;
  return;
 end FunctionInlining.UninlinableFunction1.f1;

 function FunctionInlining.UninlinableFunction1.f3
  input Real x1;
  input Real x2;
  output Real y;
 algorithm
  y := 0;
  while y < x2 loop
   y := y + x1;
  end while;
  return;
 end FunctionInlining.UninlinableFunction1.f3;
end FunctionInlining.UninlinableFunction1;
")})));

		function f1
			input Real x1;
			input Real x2;
			output Real y = f4(x1);
		algorithm
            while y < x2 loop
				y := y + f3(x1, x2);
            end while;
		end f1;
		
		function f2
			input Real x;
			output Real y = x;
		algorithm
		end f2;
		
        function f3
            input Real x1;
            input Real x2;
            output Real y;
        algorithm
            y := 0;
            while y < x2 loop
                y := y + x1;
            end while;
        end f3;
        
        function f4
            input Real x;
            output Real y = x;
        algorithm
        end f4;
        
		Real z[3] = 1:size(z,1);
		Real w[2];
	equation
		w[1] = f1(z[2], z[3]);
		w[2] = f2(z[1]);
	end UninlinableFunction1;
    
    
    model IfStatementInline1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfStatementInline1",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfStatementInline1
 Real z1;
 Real z2;
equation
 z1 = 5;
 z2 = 3;
end FunctionInlining.IfStatementInline1;
")})));

        function f
            input Real x;
            output Real y;
        protected
            Real w1;
            Real w2;
        algorithm
            w1 := 1;
            w2 := 2;
            if x > 2 then
                w1 := x;
            end if;
            y := w1 + w2;
        end f;
        
        Real z1 = f(3);
        Real z2 = f(1);
    end IfStatementInline1;
    
    
    model IfStatementInline2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfStatementInline2",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.IfStatementInline2
 Real v;
 Real z;
 Real temp_1;
 constant Integer temp_2 = 1;
 constant Integer temp_3 = 2;
 Real temp_4;
 Real temp_5;
equation
 v = 2;
 z = temp_5;
 temp_1 = v;
 temp_4 = noEvent((if temp_1 > 2 then temp_1 else 1));
 temp_5 = temp_4 + 2;
end FunctionInlining.IfStatementInline2;
")})));

        function f
            input Real x;
            output Real y;
        protected
            Real w1;
            Real w2;
        algorithm
            w1 := 1;
            w2 := 2;
            if x > 2 then
                w1 := x;
            end if;
            y := w1 + w2;
        end f;
        
        Real v = 2;
        Real z = f(v);
    end IfStatementInline2;
    
    
    model IfStatementInline3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfStatementInline3",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.IfStatementInline3
 Real v1;
 Real v2;
 Real v3;
 Real z;
 Real temp_1;
 Real temp_2;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
 Real temp_8;
equation
 v1 = 1;
 v2 = 2;
 v3 = 3;
 z = temp_8;
 temp_1 = v1;
 temp_2 = v2;
 temp_3 = v3;
 temp_4 = temp_2;
 temp_5 = temp_3;
 temp_6 = noEvent((if temp_1 > 2 then temp_1 else temp_4));
 temp_7 = noEvent((if temp_1 > 2 then temp_5 else temp_1));
 temp_8 = temp_6 + temp_7;
end FunctionInlining.IfStatementInline3;
")})));

        function f
            input Real x1;
            input Real x2;
            input Real x3;
            output Real y;
        protected
            Real w1;
            Real w2;
        algorithm
            w1 := x2;
            w2 := x3;
            if x1 > 2 then
                w1 := x1;
            else
                w2 := x1;
            end if;
            y := w1 + w2;
        end f;
        
        Real v1 = 1;
        Real v2 = 2;
        Real v3 = 3;
        Real z = f(v1, v2, v3);
    end IfStatementInline3;
    
    
    model IfStatementInline4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfStatementInline4",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.IfStatementInline4
 Real v;
 Real z;
 Real temp_1;
 Real temp_2;
 Real temp_3;
equation
 v = 1;
 z = temp_3;
 temp_1 = v;
 temp_2 = noEvent((if temp_1 > 2 then temp_1 else 0.0));
 temp_3 = noEvent((if temp_1 > 2 then temp_2 else temp_1 + 1));
end FunctionInlining.IfStatementInline4;
")})));

        function f
            input Real x;
            output Real y;
        algorithm
            if x > 2 then
                y := x;
            else
                y := x + 1;
            end if;
        end f;
        
        Real v = 1;
        Real z = f(v);
    end IfStatementInline4;
    
    
    model ForStatementInline1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline1",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.ForStatementInline1
 Real v;
 Real z;
 Real temp_1;
 constant Integer temp_2 = 0;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
 Real temp_8;
 Real temp_9;
 Real temp_10;
equation
 v = 3;
 z = temp_10;
 temp_1 = v;
 temp_3 = 1 + ( 0 ) * ( ( temp_1 - ( 1 ) ) / ( 3 ) );
 temp_4 = 0 + ( temp_3 ) * ( temp_3 );
 temp_5 = 1 + ( 1 ) * ( ( temp_1 - ( 1 ) ) / ( 3 ) );
 temp_6 = temp_4 + ( temp_5 ) * ( temp_5 );
 temp_7 = 1 + ( 2 ) * ( ( temp_1 - ( 1 ) ) / ( 3 ) );
 temp_8 = temp_6 + ( temp_7 ) * ( temp_7 );
 temp_9 = 1 + ( 3 ) * ( ( temp_1 - ( 1 ) ) / ( 3 ) );
 temp_10 = temp_8 + ( temp_9 ) * ( temp_9 );
end FunctionInlining.ForStatementInline1;
")})));

        function f
            input Real x;
            output Real y;
        algorithm
            y := 0;
            for w in linspace(1, x, 4) loop
                y := y + w * w;
            end for;
        end f;
        
        Real v = 3;
        Real z = f(v);
    end ForStatementInline1;
    
    
    model ForStatementInline2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline2",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.ForStatementInline2
 Real z;
equation
 z = 18.22222222222222;
end FunctionInlining.ForStatementInline2;
")})));

        function f
            input Real x;
            output Real y;
        algorithm
            y := 0;
            for w in linspace(1, x, 4) loop
                y := y + w * w;
            end for;
        end f;
        
        Real z = f(3);
    end ForStatementInline2;
    
    
    model ForStatementInline3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline3",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.ForStatementInline3
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 constant Integer temp_2 = 0;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
 Real temp_8;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = temp_8;
 temp_1[1] = v[1];
 temp_1[2] = v[2];
 temp_1[3] = v[3];
 temp_3 = temp_1[1];
 temp_4 = 0 + ( temp_3 ) * ( temp_3 );
 temp_5 = temp_1[2];
 temp_6 = temp_4 + ( temp_5 ) * ( temp_5 );
 temp_7 = temp_1[3];
 temp_8 = temp_6 + ( temp_7 ) * ( temp_7 );
end FunctionInlining.ForStatementInline3;
")})));

        function f
            input Real[:] x;
            output Real y;
        algorithm
            y := 0;
            for w in x loop
                y := y + w * w;
            end for;
        end f;
        
        Real v[3] = {1,2,3};
        Real z = f(v);
    end ForStatementInline3;
    
    
    model ForStatementInline4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline4",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.ForStatementInline4
 Real z;
equation
 z = 14;
end FunctionInlining.ForStatementInline4;
")})));

        function f
            input Real[:] x;
            output Real y;
        algorithm
            y := 0;
            for w in x loop
                y := y + w * w;
            end for;
        end f;
        
        Real z = f({1,2,3});
    end ForStatementInline4;


    model ForStatementInline5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline5",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.ForStatementInline5
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 constant Integer temp_2 = 0;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
 Real temp_8;
 Real temp_9;
 Real temp_10;
 Real temp_11;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = temp_11;
 temp_1[1] = v[1];
 temp_1[2] = v[2];
 temp_1[3] = v[3];
 temp_3 = temp_1[1];
 temp_4 = noEvent((if temp_3 > 2 then 0 + ( temp_3 ) * ( temp_3 ) else 0));
 temp_5 = noEvent((if temp_3 > 2 then temp_4 else temp_4 + temp_3));
 temp_6 = temp_1[2];
 temp_7 = noEvent((if temp_6 > 2 then temp_5 + ( temp_6 ) * ( temp_6 ) else temp_5));
 temp_8 = noEvent((if temp_6 > 2 then temp_7 else temp_7 + temp_6));
 temp_9 = temp_1[3];
 temp_10 = noEvent((if temp_9 > 2 then temp_8 + ( temp_9 ) * ( temp_9 ) else temp_8));
 temp_11 = noEvent((if temp_9 > 2 then temp_10 else temp_10 + temp_9));
end FunctionInlining.ForStatementInline5;
")})));

        function f
            input Real[:] x;
            output Real y;
        algorithm
            y := 0;
            for w in x loop
                if w > 2 then
                    y := y + w * w;
                else
                    y := y + w;
                end if;
            end for;
        end f;
        
        Real v[3] = {1,2,3};
        Real z = f(v);
    end ForStatementInline5;


    model ForStatementInline6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline6",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.ForStatementInline6
 Real z;
equation
 z = 12;
end FunctionInlining.ForStatementInline6;
")})));

        function f
            input Real[:] x;
            output Real y;
        algorithm
            y := 0;
            for w in x loop
                if w > 2 then
                    y := y + w * w;
                else
                    y := y + w;
                end if;
            end for;
        end f;
        
        Real z = f({1,2,3});
    end ForStatementInline6;


    model ForStatementInline7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline7",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.ForStatementInline7
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 Real temp_2;
 constant Integer temp_3 = 0;
 constant Integer temp_4 = 1;
 constant Integer temp_5 = 0;
 Real temp_6;
 constant Integer temp_7 = 2;
 Real temp_8;
 Real temp_9;
 constant Integer temp_10 = 3;
 Real temp_11;
 Real temp_12;
 constant Integer temp_13 = 4;
 Real temp_14;
 Real temp_15;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = temp_15;
 temp_1[1] = v[1];
 temp_1[2] = v[2];
 temp_1[3] = v[3];
 temp_2 = ( temp_1[1] ) * ( temp_1[1] ) + ( temp_1[2] ) * ( temp_1[2] ) + ( temp_1[3] ) * ( temp_1[3] );
 temp_6 = 0 + temp_2;
 temp_8 = temp_6;
 temp_9 = temp_8 + temp_2;
 temp_11 = temp_9 + ( 3 ) * ( temp_2 );
 temp_12 = temp_11;
 temp_14 = temp_12 + ( 4 ) * ( temp_2 );
 temp_15 = temp_14;
end FunctionInlining.ForStatementInline7;
")})));

        function f
            input Real[:] x;
            output Real y;
		protected
			Real t;
        algorithm
			t := x * x;
            y := 0;
            for w in 1:4 loop
                if w > 2 then
                    y := y + w * t;
                else
                    y := y + t;
                end if;
            end for;
        end f;
        
        Real v[3] = {1,2,3};
        Real z = f(v);
    end ForStatementInline7;


    model ForStatementInline8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ForStatementInline8",
         description="",
         inline_functions=true,
         eliminate_alias_variables=false,
         flatModel="
fclass FunctionInlining.ForStatementInline8
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
 constant Integer temp_2 = 0;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Real temp_6;
 Real temp_7;
 Real temp_8;
 Real temp_9;
 Real temp_10;
 Real temp_11;
 Real temp_12;
 Real temp_13;
 Real temp_14;
 Real temp_15;
 Real temp_16;
 Real temp_17;
 Real temp_18;
 Real temp_19;
 Real temp_20;
 Real temp_21;
 Real temp_22;
 Real temp_23;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = temp_23;
 temp_1[1] = v[1];
 temp_1[2] = v[2];
 temp_1[3] = v[3];
 temp_3 = temp_1[1];
 temp_4 = temp_1[1];
 temp_5 = 0 + ( temp_3 ) * ( temp_4 );
 temp_6 = temp_1[2];
 temp_7 = temp_5 + ( temp_3 ) * ( temp_6 );
 temp_8 = temp_1[3];
 temp_9 = temp_7 + ( temp_3 ) * ( temp_8 );
 temp_10 = temp_1[2];
 temp_11 = temp_1[1];
 temp_12 = temp_9 + ( temp_10 ) * ( temp_11 );
 temp_13 = temp_1[2];
 temp_14 = temp_12 + ( temp_10 ) * ( temp_13 );
 temp_15 = temp_1[3];
 temp_16 = temp_14 + ( temp_10 ) * ( temp_15 );
 temp_17 = temp_1[3];
 temp_18 = temp_1[1];
 temp_19 = temp_16 + ( temp_17 ) * ( temp_18 );
 temp_20 = temp_1[2];
 temp_21 = temp_19 + ( temp_17 ) * ( temp_20 );
 temp_22 = temp_1[3];
 temp_23 = temp_21 + ( temp_17 ) * ( temp_22 );
end FunctionInlining.ForStatementInline8;
")})));

        function f
            input Real[:] x;
            output Real y;
        algorithm
            y := 0;
            for w in x loop
                for t in x loop
                    y := y + w * t;
                end for;
            end for;
        end f;
        
        Real v[3] = {1,2,3};
        Real z = f(v);
    end ForStatementInline8;

	
end FunctionInlining;
