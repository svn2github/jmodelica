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
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.BasicInline6
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real temp_6;
 Real temp_8;
 Real temp_10;
 Real temp_13;
 Real temp_15;
 Real temp_18;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 temp_6 = y[1] .+ 2;
 temp_8 = y[2] .+ 2;
 temp_10 = y[3] .+ 2;
 temp_13 = 0.0 + ( y[1] ) * ( temp_6 );
 temp_15 = temp_13 + ( y[2] ) * ( temp_8 );
 temp_18 = temp_15 + ( y[3] ) * ( temp_10 );
 x[1] = ( temp_18 ) * ( y[1] + temp_6 );
 x[2] = ( temp_18 ) * ( y[2] + temp_8 );
 x[3] = ( temp_18 ) * ( y[3] + temp_10 );
end FunctionInlining.BasicInline6;
")})));

        function f
            input Real[:] a;
            output Real[size(a,1)] b;
        protected
            Real[size(a,1)] c;
            Real d;
        algorithm
            c := a .+ 2;
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
    

// TODO: error in scalarization causes function to be inlined too many times
    model BasicInline8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline8",
         description="Inlining function with both function calls and arrays",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.BasicInline8
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real temp_13;
 Real temp_14;
 Real temp_15;
 Real temp_16;
 Real temp_17;
 Real temp_18;
 Real temp_21;
 Real temp_22;
 Real temp_23;
 Real temp_24;
 Real temp_25;
 Real temp_26;
 Real temp_29;
 Real temp_30;
 Real temp_31;
 Real temp_32;
 Real temp_33;
 Real temp_34;
 Real temp_40;
 Real temp_42;
 Real temp_44;
 Real temp_47;
 Real temp_49;
 Real temp_52;
 Real temp_59;
 Real temp_60;
 Real temp_61;
 Real temp_63;
 Real temp_65;
 Real temp_67;
 Real temp_70;
 Real temp_72;
 Real temp_75;
 Real temp_86;
 Real temp_88;
 Real temp_90;
 Real temp_93;
 Real temp_95;
 Real temp_98;
 Real temp_109;
 Real temp_111;
 Real temp_113;
 Real temp_116;
 Real temp_118;
 Real temp_121;
 Real temp_132;
 Real temp_134;
 Real temp_136;
 Real temp_139;
 Real temp_141;
 Real temp_144;
 Real temp_155;
 Real temp_157;
 Real temp_159;
 Real temp_162;
 Real temp_164;
 Real temp_167;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 temp_59 = ( y[1] ) * ( 2 );
 temp_60 = ( y[2] ) * ( 2 );
 temp_61 = ( y[3] ) * ( 2 );
 x[1] = temp_13 + temp_16;
 x[2] = temp_22 + temp_25;
 x[3] = temp_31 + temp_34;
 temp_40 = y[1] .+ 1;
 temp_42 = y[2] .+ 1;
 temp_44 = y[3] .+ 1;
 temp_47 = 0.0 + ( y[1] ) * ( temp_40 );
 temp_49 = temp_47 + ( y[2] ) * ( temp_42 );
 temp_52 = temp_49 + ( y[3] ) * ( temp_44 );
 temp_13 = ( temp_52 ) * ( y[1] + temp_40 );
 temp_14 = ( temp_52 ) * ( y[2] + temp_42 );
 temp_15 = ( temp_52 ) * ( y[3] + temp_44 );
 temp_63 = temp_59 .+ 1;
 temp_65 = temp_60 .+ 1;
 temp_67 = temp_61 .+ 1;
 temp_70 = 0.0 + ( temp_59 ) * ( temp_63 );
 temp_72 = temp_70 + ( temp_60 ) * ( temp_65 );
 temp_75 = temp_72 + ( temp_61 ) * ( temp_67 );
 temp_16 = ( temp_75 ) * ( temp_59 + temp_63 );
 temp_17 = ( temp_75 ) * ( temp_60 + temp_65 );
 temp_18 = ( temp_75 ) * ( temp_61 + temp_67 );
 temp_86 = y[1] .+ 1;
 temp_88 = y[2] .+ 1;
 temp_90 = y[3] .+ 1;
 temp_93 = 0.0 + ( y[1] ) * ( temp_86 );
 temp_95 = temp_93 + ( y[2] ) * ( temp_88 );
 temp_98 = temp_95 + ( y[3] ) * ( temp_90 );
 temp_21 = ( temp_98 ) * ( y[1] + temp_86 );
 temp_22 = ( temp_98 ) * ( y[2] + temp_88 );
 temp_23 = ( temp_98 ) * ( y[3] + temp_90 );
 temp_109 = temp_59 .+ 1;
 temp_111 = temp_60 .+ 1;
 temp_113 = temp_61 .+ 1;
 temp_116 = 0.0 + ( temp_59 ) * ( temp_109 );
 temp_118 = temp_116 + ( temp_60 ) * ( temp_111 );
 temp_121 = temp_118 + ( temp_61 ) * ( temp_113 );
 temp_24 = ( temp_121 ) * ( temp_59 + temp_109 );
 temp_25 = ( temp_121 ) * ( temp_60 + temp_111 );
 temp_26 = ( temp_121 ) * ( temp_61 + temp_113 );
 temp_132 = y[1] .+ 1;
 temp_134 = y[2] .+ 1;
 temp_136 = y[3] .+ 1;
 temp_139 = 0.0 + ( y[1] ) * ( temp_132 );
 temp_141 = temp_139 + ( y[2] ) * ( temp_134 );
 temp_144 = temp_141 + ( y[3] ) * ( temp_136 );
 temp_29 = ( temp_144 ) * ( y[1] + temp_132 );
 temp_30 = ( temp_144 ) * ( y[2] + temp_134 );
 temp_31 = ( temp_144 ) * ( y[3] + temp_136 );
 temp_155 = temp_59 .+ 1;
 temp_157 = temp_60 .+ 1;
 temp_159 = temp_61 .+ 1;
 temp_162 = 0.0 + ( temp_59 ) * ( temp_155 );
 temp_164 = temp_162 + ( temp_60 ) * ( temp_157 );
 temp_167 = temp_164 + ( temp_61 ) * ( temp_159 );
 temp_32 = ( temp_167 ) * ( temp_59 + temp_155 );
 temp_33 = ( temp_167 ) * ( temp_60 + temp_157 );
 temp_34 = ( temp_167 ) * ( temp_61 + temp_159 );
end FunctionInlining.BasicInline8;
")})));

        function f1
            input Real[:] a;
            output Real[size(a,1)] b;
        protected
            Real[size(a,1)] c;
            Real d;
        algorithm
            c := a .+ 1;
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
         flatModel="
fclass FunctionInlining.BasicInline10
 parameter Integer e = 2 /* 2 */;
 Real x;
 Real y;
 Real z[1];
 Real z[2];
 Real z[3];
 parameter Integer temp_5;
parameter equation
 temp_5 = e;
equation
 y = 2.2;
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;
 x = ( y ) * ( z[2] );
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


    model BasicInline13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="BasicInline13",
         description="Inlining of function using enumeration",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.BasicInline13
 discrete FunctionInlining.BasicInline13.E p1;
 discrete FunctionInlining.BasicInline13.E p2;
initial equation 
 pre(p1) = false;
 pre(p2) = false;
equation
 p1 = FunctionInlining.BasicInline13.E.b;
 p2 = noEvent((if p1 == FunctionInlining.BasicInline13.E.a then FunctionInlining.BasicInline13.E.b else FunctionInlining.BasicInline13.E.c));

 type FunctionInlining.BasicInline13.E = enumeration(a, b, c);
end FunctionInlining.BasicInline13;
")})));

		type E = enumeration(a, b, c);
		
        function next
            input E x;
            output E y;
        algorithm
            y := if x == E.a then E.b else E.c;
        end next;
        
        E p1 = next(E.a);
		E p2 = next(p1);
    end BasicInline13;
    
    
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
         flatModel="
fclass FunctionInlining.RecordInline4
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real x;
 discrete Integer temp_4;
initial equation 
 pre(temp_4) = 0;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;
 temp_4 = integer(y[4]);
 x = temp_4 + y[1] + y[2] + y[3];

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
         flatModel="
fclass FunctionInlining.RecordInline5
 Real y;
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
initial equation 
 x.pre(b) = 0;
equation
 y = 1;
 x.b = 2;
 x.a[1] = ( 1 ) * ( y );
 x.a[2] = ( 2 ) * ( y );
 x.a[3] = ( 3 ) * ( y );

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
         flatModel="
fclass FunctionInlining.RecordInline6
 Real y;
 Real x;
 Real temp_2;
 Real temp_3;
 Real temp_4;
equation
 y = 1;
 temp_2 = ( 1 ) * ( y );
 temp_3 = ( 2 ) * ( y );
 temp_4 = ( 3 ) * ( y );
 x = temp_2 + temp_3 + temp_4 + ( y ) * ( 4 );

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
 discrete Integer temp_9;
 Real temp_10;
 Real temp_11;
 Real temp_12;
 discrete Integer temp_13;
 Real temp_14;
 Real temp_15;
 Real temp_16;
initial equation 
 x.pre(b) = 0;
 pre(temp_9) = 0;
 pre(temp_13) = 0;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;
 temp_9 = integer(y[4]);
 temp_10 = y[1] + y[1];
 temp_11 = y[2] + y[2];
 temp_12 = y[3] + y[3];
 temp_13 = temp_9 - ( temp_9 );
 temp_14 = ( ( y[1] ) * ( y[1] ) + ( y[2] ) * ( y[2] ) + ( y[3] ) * ( y[3] ) ) * ( temp_10 );
 temp_15 = ( ( y[1] ) * ( y[1] ) + ( y[2] ) * ( y[2] ) + ( y[3] ) * ( y[3] ) ) * ( temp_11 );
 temp_16 = ( ( y[1] ) * ( y[1] ) + ( y[2] ) * ( y[2] ) + ( y[3] ) * ( y[3] ) ) * ( temp_12 );
 x.a[1] = temp_14 - ( y[1] );
 x.a[2] = temp_15 - ( y[2] );
 x.a[3] = temp_16 - ( y[3] );
 x.b = 3 + temp_13;

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
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline8",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline8
 Real y;
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
initial equation 
 x.pre(b) = 0;
equation
 y = 1;
 x.a[1] = ( 2 ) / ( y );
 x.a[2] = 3 + y;
 x.a[3] = ( 4 ) * ( y );
 x.b = integer(5 - ( y ));

 record FunctionInlining.RecordInline8.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline8.R;
end FunctionInlining.RecordInline8;
")})));

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
            d.a[3] := 4 * c;
            d.b := integer(5 - c);
        end f;
        
        Real y = 1;
        R x = f(y);
    end RecordInline8;
    
    
    model RecordInline9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline9",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline9
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
initial equation 
 x.pre(b) = 0;
equation
 x.a[1] = 2.0;
 x.a[2] = 4;
 x.a[3] = 4;
 x.b = 4;

 record FunctionInlining.RecordInline9.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline9.R;
end FunctionInlining.RecordInline9;
")})));

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
            d.a[3] := 4 * c;
            d.b := integer(5 - c);
        end f;
        
        R x = f(1);
    end RecordInline9;
    
    
    model RecordInline10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline10",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline10
 Real x;
 Real y;
 Real temp_7;
 Real temp_8;
 Real temp_9;
 discrete Integer temp_10;
initial equation 
 pre(temp_10) = 0;
equation
 y = 1;
 temp_7 = ( 1 ) * ( y );
 temp_8 = ( 2 ) * ( y );
 temp_9 = ( 3 ) * ( y );
 temp_10 = integer(5 - ( y ));
 x = temp_7 + temp_8 + temp_9 + temp_10;

 record FunctionInlining.RecordInline10.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline10.R;
end FunctionInlining.RecordInline10;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f1
            input Real c;
            output Real d;
        protected
            R e;
        algorithm
            e.a := { 1, 2, 3 } * c;
            e.b := integer(5 - c);
            d := f2(e);
        end f1;
        
        function f2
            input R f;
            output Real g;
        algorithm
            g := sum(f.a) + f.b;
        end f2;
        
        Real x = f1(y);
        Real y = 1;
    end RecordInline10;
    
    
    model RecordInline11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordInline11",
         description="",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.RecordInline11
 Real x;
 Real y;
 Real temp_3;
 Real temp_4;
 Real temp_5;
 Integer temp_6;
initial equation 
 pre(temp_6) = 0;
equation
 y = 1;
 x = temp_3 + temp_4 + temp_5 + temp_6;
 temp_3 = ( 1 ) * ( y );
 temp_4 = ( 2 ) * ( y );
 temp_5 = ( 3 ) * ( y );
 temp_6 = integer(5 - ( y ));

 record FunctionInlining.RecordInline11.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline11.R;
end FunctionInlining.RecordInline11;
")})));

        record R
            Real a[3];
            Integer b;
        end R;
        
        function f1
            input Real f;
            output Real g;
        protected
            R e;
        algorithm
			e := f2(f);
            g := sum(e.a) + e.b;
	    end f1;
        
        function f2
            input Real c;
            output R d;
        algorithm
            d.a := { 1, 2, 3 } * c;
            d.b := integer(5 - c);
        end f2;
        
        Real x = f1(y);
        Real y = 1;
    end RecordInline11;
	
	
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
         flatModel="
fclass FunctionInlining.ForStatementInline3
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_6;
 Real temp_8;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 temp_6 = 0 + ( v[1] ) * ( v[1] );
 temp_8 = temp_6 + ( v[2] ) * ( v[2] );
 z = temp_8 + ( v[3] ) * ( v[3] );
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
         flatModel="
fclass FunctionInlining.ForStatementInline5
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_6;
 Real temp_7;
 Real temp_9;
 Real temp_10;
 Real temp_12;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 temp_6 = noEvent((if v[1] > 2 then 0 + ( v[1] ) * ( v[1] ) else 0));
 temp_7 = noEvent((if v[1] > 2 then temp_6 else temp_6 + v[1]));
 temp_9 = noEvent((if v[2] > 2 then temp_7 + ( v[2] ) * ( v[2] ) else temp_7));
 temp_10 = noEvent((if v[2] > 2 then temp_9 else temp_9 + v[2]));
 temp_12 = noEvent((if v[3] > 2 then temp_10 + ( v[3] ) * ( v[3] ) else temp_10));
 z = noEvent((if v[3] > 2 then temp_12 else temp_12 + v[3]));
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
         flatModel="
fclass FunctionInlining.ForStatementInline7
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_7;
 Real temp_9;
 Real temp_12;
 Real temp_18;
 Real temp_19;
 Real temp_22;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 temp_7 = 0.0 + ( v[1] ) * ( v[1] );
 temp_9 = temp_7 + ( v[2] ) * ( v[2] );
 temp_12 = temp_9 + ( v[3] ) * ( v[3] );
 temp_18 = 0 + temp_12;
 temp_19 = temp_18 + temp_12;
 temp_22 = temp_19 + ( 3 ) * ( temp_12 );
 z = temp_22 + ( 4 ) * ( temp_12 );
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
         flatModel="
fclass FunctionInlining.ForStatementInline8
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_7;
 Real temp_9;
 Real temp_11;
 Real temp_14;
 Real temp_16;
 Real temp_18;
 Real temp_21;
 Real temp_23;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 temp_7 = 0 + ( v[1] ) * ( v[1] );
 temp_9 = temp_7 + ( v[1] ) * ( v[2] );
 temp_11 = temp_9 + ( v[1] ) * ( v[3] );
 temp_14 = temp_11 + ( v[2] ) * ( v[1] );
 temp_16 = temp_14 + ( v[2] ) * ( v[2] );
 temp_18 = temp_16 + ( v[2] ) * ( v[3] );
 temp_21 = temp_18 + ( v[3] ) * ( v[1] );
 temp_23 = temp_21 + ( v[3] ) * ( v[2] );
 z = temp_23 + ( v[3] ) * ( v[3] );
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
	
    
    
    model MultipleOutputsInline1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MultipleOutputsInline1",
         description="Inlining function call using multiple outputs",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.MultipleOutputsInline1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real x[5];
 Real x[6];
 Real x[7];
 Real x[8];
equation
 x[1] = 2;
 x[2] = 6;
 x[3] = 3;
 x[4] = 3 + x[2];
 x[5] = x[3] + 1;
 x[6] = x[5] + 3;
 x[7] = x[5] + 1;
 x[8] = x[7] + x[6];
end FunctionInlining.MultipleOutputsInline1;
")})));

        function f
            input Real a;
            input Real b;
            output Real c;
            output Real d;
        algorithm
            c := a + 1;
            d := c + b;
        end f;
        
        Real x[8];
    equation
        (x[1], x[2]) = f(1, 2 * 2);
        (x[3], x[4]) = f(2, x[2]);
        (x[5], x[6]) = f(x[3], 3);
        (x[7], x[8]) = f(x[5], x[6]);
    end MultipleOutputsInline1;
    
    
    model MultipleOutputsInline2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MultipleOutputsInline2",
         description="Inlining function call using multiple (but not all) outputs",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.MultipleOutputsInline2
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real x[5];
 Real x[6];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real y[5];
 Real y[6];
 Real temp_4;
 Real temp_10;
 Real temp_13;
equation
 y[1] = 1;
 y[2] = 1;
 y[3] = 1;
 y[4] = 1;
 y[5] = 1;
 y[6] = 1;
 x[1] = y[1] + y[2];
 temp_4 = y[1] - ( y[2] );
 x[2] = ( y[1] ) * ( y[2] );
 x[3] = y[3] + y[4];
 x[4] = y[3] - ( y[4] );
 temp_10 = ( y[3] ) * ( y[4] );
 temp_13 = y[5] + y[6];
 x[5] = y[5] - ( y[6] );
 x[6] = ( y[5] ) * ( y[6] );
end FunctionInlining.MultipleOutputsInline2;
")})));

        function f
            input Real a;
            input Real b;
            output Real c;
            output Real d;
            output Real e;
        algorithm
            c := a + b;
            d := a - b;
            e := a * b;
        end f;
        
        Real x[6];
		Real y[6] = ones(6);
    equation
        (x[1], , x[2]) = f(y[1], y[2]);
        (x[3], x[4])   = f(y[3], y[4]);
        (, x[5], x[6]) = f(y[5], y[6]);
    end MultipleOutputsInline2;


    model MultipleOutputsInline3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="MultipleOutputsInline3",
         description="Inlining function call using multiple (but not all) outputs",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.MultipleOutputsInline3
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real x[5];
 Real x[6];
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real y[5];
 Real y[6];
 Real temp_4;
 Real temp_10;
 Real temp_13;
equation
 y[1] = 1;
 y[2] = 1;
 y[3] = 1;
 y[4] = 1;
 y[5] = 1;
 y[6] = 1;
 x[1] = y[1] + y[2];
 temp_4 = y[1] - ( y[2] );
 x[2] = ( y[1] ) * ( y[2] );
 x[3] = y[3] + y[4];
 x[4] = y[3] - ( y[4] );
 temp_10 = ( y[3] ) * ( y[4] );
 temp_13 = y[5] + y[6];
 x[5] = y[5] - ( y[6] );
 x[6] = ( y[5] ) * ( y[6] );
end FunctionInlining.MultipleOutputsInline3;
")})));

        function f1
            input Real a;
            input Real b;
            output Real c;
            output Real d;
            output Real e;
        algorithm
            c := a + b;
            d := a - b;
            e := a * b;
        end f1;
		
		function f2
            input Real y1;
            input Real y2;
            output Real x1;
	        output Real x2;
            output Real x3;
	    algorithm
	        (x1, x2, x3) := f1(y1, y2);
		end f2;
        
        Real x[6];
        Real y[6] = ones(6);
    equation
        (x[1], , x[2]) = f2(y[1], y[2]);
        (x[3], x[4])   = f2(y[3], y[4]);
        (, x[5], x[6]) = f2(y[5], y[6]);
    end MultipleOutputsInline3;
    
    
    model IfEquationInline1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEquationInline1",
         description="Test inlining of function calls in if equations",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfEquationInline1
 Real x;
 Real y;
equation
 y = (if time > 1 then x else 0);
 x = 1;
end FunctionInlining.IfEquationInline1;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
        Real x = 1;
        Real y;
    equation
        if (time > 1) then
            y = f(x);
        else
            y = 0;
        end if;
    end IfEquationInline1;
    
    
    model IfEquationInline2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEquationInline2",
         description="Test inlining of function calls in if equations",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfEquationInline2
 parameter Boolean b = true /* true */;
 Real y;
equation
 y = 1;
end FunctionInlining.IfEquationInline2;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
		parameter Boolean b = true;
        Real x = 1;
        Real y;
    equation
        if (b) then
            y = f(x);
        end if;
    end IfEquationInline2;
    
    
    model IfEquationInline3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEquationInline3",
         description="Test inlining of function calls in if equations",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfEquationInline3
 parameter Boolean b = false /* false */;
 Real x;
 Real y;
equation
 y = 0;
 x = 1;
end FunctionInlining.IfEquationInline3;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
        parameter Boolean b = false;
        Real x = 1;
        Real y;
    equation
        if (b) then
            y = f(x);
        end if;
		if (not b) then
			y = 0;
		end if;
    end IfEquationInline3;
    
    
    model IfEquationInline4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEquationInline4",
         description="Test inlining of function calls in if equations",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfEquationInline4
 Real x1;
 Real x2;
 Real y;
equation
 y = (if time > 1 then x1 else x2);
 x1 = 1;
 x2 = 2;
end FunctionInlining.IfEquationInline4;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
        Real x1 = 1;
        Real x2 = 2;
        Real y;
    equation
        if (time > 1) then
            y = f(x1);
        else
            y = f(x2);
        end if;
    end IfEquationInline4;
    
    
    model IfEquationInline5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEquationInline5",
         description="Test inlining of function calls in if equations",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfEquationInline5
 constant Boolean b = true;
 Real x2;
 Real y;
equation
 y = 1;
 x2 = 2;
end FunctionInlining.IfEquationInline5;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
        constant Boolean b = true;
        Real x1 = 1;
        Real x2 = 2;
        Real y;
    equation
        if (b) then
            y = f(x1);
        else
            y = f(x2);
        end if;
    end IfEquationInline5;
    
    
    model IfEquationInline6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IfEquationInline6",
         description="Test inlining of function calls in if equations",
         inline_functions=true,
         flatModel="
fclass FunctionInlining.IfEquationInline6
 constant Boolean b = false;
 Real x1;
 Real y;
equation
 x1 = 1;
 y = 2;
end FunctionInlining.IfEquationInline6;
")})));

        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
        end f;
        
        constant Boolean b = false;
        Real x1 = 1;
        Real x2 = 2;
        Real y;
    equation
        if (b) then
            y = f(x1);
        else
            y = f(x2);
        end if;
    end IfEquationInline6;

	
end FunctionInlining;
