/*
    Copyright (C) 2011-2013 Modelon AB

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
        function f
            input Real a;
            output Real b;
        algorithm
            b := a;
	        end f;
        
        Real x = f(1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline1",
			description="Most basic inlining case",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.BasicInline1
 Real x;
equation
 x = 1;
end FunctionInlining.BasicInline1;
")})));
    end BasicInline1;
       
	   
    model BasicInline2
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline2",
			description="More complicated inlining case with only assignments and constant argument",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.BasicInline2
 Real x;
 constant Real y = 2;
equation
 x = 2.0;
end FunctionInlining.BasicInline2;
")})));
    end BasicInline2;
       
	   
    model BasicInline3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline3",
			description="More complicated inlining case with only assignments and continous argument",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.BasicInline3
 Real x;
 Real y;
 Real temp_1;
 Real temp_3;
 Real temp_4;
equation
 x = temp_4 ^ temp_3 - temp_4 - temp_3 - temp_4 + 1;
 y = time;
 temp_1 = y + 1;
 temp_3 = 2 * temp_1 + temp_1;
 temp_4 = temp_3 / 3 + 1;
end FunctionInlining.BasicInline3;
")})));
    end BasicInline3;
       
	   
    model BasicInline4
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline4",
			description="Test of alias elimination after inlining",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.BasicInline4
 Real x;
 Real y;
equation
 x = y + y;
 y = time;
end FunctionInlining.BasicInline4;
")})));
    end BasicInline4;
    
	
    model BasicInline6
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline6",
			description="",
			variability_propagation=false,
			inline_functions="all",
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
 Real temp_18;
equation
 x[1] = temp_18 * (y[1] + temp_6);
 x[2] = temp_18 * (y[2] + temp_8);
 x[3] = temp_18 * (y[3] + temp_10);
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 temp_6 = y[1] .+ 2;
 temp_8 = y[2] .+ 2;
 temp_10 = y[3] .+ 2;
 temp_18 = y[1] * temp_6 + y[2] * temp_8 + y[3] * temp_10;
end FunctionInlining.BasicInline6;
")})));
    end BasicInline6;
    
	
    model BasicInline7
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline7",
			description="",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.BasicInline7
 Real x;
 Real y;
 Real temp_1;
 Real temp_4;
 Real temp_7;
equation
 x = temp_4 + temp_4 * 2 + (temp_7 + temp_7 * 2);
 y = 1;
 temp_1 = y;
 temp_4 = temp_1;
 temp_7 = temp_1 * 2;
end FunctionInlining.BasicInline7;
")})));
    end BasicInline7;
    

    model BasicInline8
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline8",
			description="Inlining function with both function calls and arrays",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.BasicInline8
 Real x[1];
 Real x[2];
 Real x[3];
 Real y[1];
 Real y[2];
 Real y[3];
 Real temp_40;
 Real temp_59;
 Real temp_60;
 Real temp_61;
 Real temp_63;
 Real temp_88;
 Real temp_111;
 Real temp_136;
 Real temp_159;
equation
 x[1] = (y[1] * temp_40 + y[2] * (y[2] .+ 1) + y[3] * (y[3] .+ 1)) * (y[1] + temp_40) + (temp_59 * temp_63 + temp_60 * (temp_60 .+ 1) + temp_61 * (temp_61 .+ 1)) * (temp_59 + temp_63);
 x[2] = (y[1] * (y[1] .+ 1) + y[2] * temp_88 + y[3] * (y[3] .+ 1)) * (y[2] + temp_88) + (temp_59 * (temp_59 .+ 1) + temp_60 * temp_111 + temp_61 * (temp_61 .+ 1)) * (temp_60 + temp_111);
 x[3] = (y[1] * (y[1] .+ 1) + y[2] * (y[2] .+ 1) + y[3] * temp_136) * (y[3] + temp_136) + (temp_59 * (temp_59 .+ 1) + temp_60 * (temp_60 .+ 1) + temp_61 * temp_159) * (temp_61 + temp_159);
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 temp_59 = y[1] * 2;
 temp_60 = y[2] * 2;
 temp_61 = y[3] * 2;
 temp_40 = y[1] .+ 1;
 temp_63 = temp_59 .+ 1;
 temp_88 = y[2] .+ 1;
 temp_111 = temp_60 .+ 1;
 temp_136 = y[3] .+ 1;
 temp_159 = temp_61 .+ 1;
end FunctionInlining.BasicInline8;
")})));
    end BasicInline8;
    
    
    model BasicInline9
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline9",
			description="",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.BasicInline9
 parameter Real temp_1;
 parameter Real y = 2 /* 2 */;
 parameter Real temp_3;
 parameter Real temp_4;
 parameter Real x;
parameter equation
 temp_1 = y - 1;
 temp_3 = 2 * temp_1 + temp_1;
 temp_4 = temp_3 / 3 + 1;
 x = temp_4 ^ temp_3 - temp_4 - temp_3 - temp_4 + 1;
end FunctionInlining.BasicInline9;
")})));
    end BasicInline9;


    model BasicInline10
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline10",
			description="Using array indices",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.BasicInline10
 parameter Integer e = 2 /* 2 */;
 Real x;
 Real y;
 Real z[1];
 Real z[2];
 Real z[3];
equation
 x = y * z[2];
 y = 2.2;
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;
end FunctionInlining.BasicInline10;
")})));
    end BasicInline10;


    model BasicInline11
        function f
            input Integer a;
            output Integer b;
        algorithm
            b := 4 - a;
            end f;
        
        parameter Integer e = 1;
        Real x = y[f(e)];
        Real[:] y = { 1, 2, 3 };

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline11",
			description="Function call as array index",
			variability_propagation=false,
			inline_functions="all",
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
		type E = enumeration(a, b, c);
		
        function next
            input E x;
            output E y;
        algorithm
            y := if x == E.a then E.b else E.c;
        end next;
        
        E p1 = next(E.a);
		E p2 = next(p1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BasicInline13",
			description="Inlining of function using enumeration",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.BasicInline13
 discrete FunctionInlining.BasicInline13.E p1;
 discrete FunctionInlining.BasicInline13.E p2;
initial equation 
 pre(p1) = FunctionInlining.BasicInline13.E.a;
 pre(p2) = FunctionInlining.BasicInline13.E.a;
equation
 p1 = FunctionInlining.BasicInline13.E.b;
 p2 = noEvent(if p1 == FunctionInlining.BasicInline13.E.a then FunctionInlining.BasicInline13.E.b else FunctionInlining.BasicInline13.E.c);

public
 type FunctionInlining.BasicInline13.E = enumeration(a, b, c);

end FunctionInlining.BasicInline13;
")})));
    end BasicInline13;
	
	
	model MatrixInline1
		function f
			input Real[2,2] a;
            input Real[2,2] b;
			output Real[2,2] c;
		algorithm
			c := a + b;
		end f;
		
		parameter Real[2,2] p = [1,2; 3,4];
        Real[2,2] x = p .+ time;
        Real[2,2] y = p * time;
		Real[2,2] z = f(x, y);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MatrixInline1",
			description="Inline function with matrix as input and output",
			inline_functions="all",
			flatModel="
fclass FunctionInlining.MatrixInline1
 parameter Real p[1,1] = 1 /* 1 */;
 parameter Real p[1,2] = 2 /* 2 */;
 parameter Real p[2,1] = 3 /* 3 */;
 parameter Real p[2,2] = 4 /* 4 */;
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y[1,1];
 Real y[1,2];
 Real y[2,1];
 Real y[2,2];
 Real z[1,1];
 Real z[1,2];
 Real z[2,1];
 Real z[2,2];
equation
 x[1,1] = p[1,1] .+ time;
 x[1,2] = p[1,2] .+ time;
 x[2,1] = p[2,1] .+ time;
 x[2,2] = p[2,2] .+ time;
 y[1,1] = p[1,1] * time;
 y[1,2] = p[1,2] * time;
 y[2,1] = p[2,1] * time;
 y[2,2] = p[2,2] * time;
 z[1,1] = x[1,1] + y[1,1];
 z[1,2] = x[1,2] + y[1,2];
 z[2,1] = x[2,1] + y[2,1];
 z[2,2] = x[2,2] + y[2,2];
end FunctionInlining.MatrixInline1;
")})));
	end MatrixInline1;
    
    
    model RecordInline1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline1",
			description="Inlining function taking constant record arg",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline1
 Real x;
equation
 x = 10;

public
 record FunctionInlining.RecordInline1.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline1.R;

end FunctionInlining.RecordInline1;
")})));
    end RecordInline1;
    
    
    model RecordInline2
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline2",
			description="Inlining function returning recor, constant args",
			variability_propagation=false,
			inline_functions="all",
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

public
 record FunctionInlining.RecordInline2.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline2.R;

end FunctionInlining.RecordInline2;
")})));
    end RecordInline2;
    
    
    model RecordInline3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline3",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline3
 Real x;
equation
 x = 10;

public
 record FunctionInlining.RecordInline3.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline3.R;

end FunctionInlining.RecordInline3;
")})));
    end RecordInline3;
    
    
    model RecordInline4
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline4",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline4
 Real y[1];
 Real y[2];
 Real y[3];
 Real y[4];
 Real x;
 discrete Integer temp_1;
initial equation 
 pre(temp_1) = 0;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;
 x = temp_1 + (y[1] + y[2] + y[3]);
 temp_1 = if y[4] < pre(temp_1) or y[4] >= pre(temp_1) + 1 or initial() then integer(y[4]) else pre(temp_1);

public
 record FunctionInlining.RecordInline4.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline4.R;

end FunctionInlining.RecordInline4;
			
")})));
    end RecordInline4;
    
    
    model RecordInline5
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline5",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline5
 Real x.a[1];
 Real x.a[2];
 Real x.a[3];
 discrete Integer x.b;
initial equation 
 x.pre(b) = 0;
equation
 x.a[1] = 1;
 x.a[2] = 2 * x.a[1];
 x.a[3] = 3 * x.a[1];
 x.b = 2;

public
 record FunctionInlining.RecordInline5.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline5.R;

end FunctionInlining.RecordInline5;
")})));
    end RecordInline5;
    
    
    model RecordInline6
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline6",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline6
 Real y;
 Real x;
equation
 y = 1;
 x = y + 2 * y + 3 * y + y * 4;

public
 record FunctionInlining.RecordInline6.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline6.R;

end FunctionInlining.RecordInline6;
")})));
    end RecordInline6;
    
    
    model RecordInline7
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline7",
			description="",
			variability_propagation=false,
			inline_functions="all",
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
 discrete Integer temp_2;
initial equation 
 pre(temp_2) = 0;
 x.pre(b) = 0;
equation
 y[1] = 1;
 y[2] = 2;
 y[3] = 3;
 y[4] = 4;
 x.a[1] = (y[1] * y[1] + y[2] * y[2] + y[3] * y[3]) * (y[1] + y[1]) - y[1];
 x.a[2] = (y[1] * y[1] + y[2] * y[2] + y[3] * y[3]) * (y[2] + y[2]) - y[2];
 x.a[3] = (y[1] * y[1] + y[2] * y[2] + y[3] * y[3]) * (y[3] + y[3]) - y[3];
 x.b = 3 + (temp_2 - temp_2);
 temp_2 = if y[4] < pre(temp_2) or y[4] >= pre(temp_2) + 1 or initial() then integer(y[4]) else pre(temp_2);

public
 record FunctionInlining.RecordInline7.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline7.R;

end FunctionInlining.RecordInline7;
			
")})));
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
            d.a[3] := 4 * c;
            d.b := integer(5 - c);
        end f;
        
        Real y = 1;
        R x = f(y);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline8",
			description="",
			variability_propagation=false,
			inline_functions="all",
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
 x.a[1] = 2 / y;
 x.a[2] = 3 + y;
 x.a[3] = 4 * y;
 x.b = noEvent(integer(5 - y));

public
 record FunctionInlining.RecordInline8.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline8.R;

end FunctionInlining.RecordInline8;
")})));
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
            d.a[3] := 4 * c;
            d.b := integer(5 - c);
        end f;
        
        R x = f(1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline9",
			description="",
			variability_propagation=false,
			inline_functions="all",
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

public
 record FunctionInlining.RecordInline9.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline9.R;

end FunctionInlining.RecordInline9;
")})));
    end RecordInline9;
    
    
    model RecordInline10
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline10",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline10
 Real x;
 Real y;
equation
 x = y + 2 * y + 3 * y + noEvent(integer(5 - y));
 y = 1;

public
 record FunctionInlining.RecordInline10.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline10.R;

end FunctionInlining.RecordInline10;
")})));
    end RecordInline10;
    
    
    model RecordInline11
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RecordInline11",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.RecordInline11
 Real x;
 Real y;
equation
 x = y + 2 * y + 3 * y + noEvent(integer(5 - y));
 y = 1;

public
 record FunctionInlining.RecordInline11.R
  Real a[3];
  discrete Integer b;
 end FunctionInlining.RecordInline11.R;

end FunctionInlining.RecordInline11;
")})));
    end RecordInline11;
	
	
	model ExternalInline1
		class O
			extends ExternalObject;
            function constructor
                output O o;
                external "C";
            end constructor;
            function destructor
                input O o;
                external "C";
            end destructor;
		end O;
		
		function f
			input O o;
			input Real y;
			output Real x;
			external "C";
		end f;
		
		function g
			input Real y;
			input O o;
			output Real x;
		algorithm
			x := y + f(o, y);
		end g;
		
		O o1 = O();
		Real x = g(time, o1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ExternalInline1",
			description="Inlining function with external object",
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ExternalInline1
 parameter FunctionInlining.ExternalInline1.O o1 = FunctionInlining.ExternalInline1.O.constructor() /* (unknown value) */;
 Real x;
 Real temp_1;
equation
 x = temp_1 + FunctionInlining.ExternalInline1.f(o1, temp_1);
 temp_1 = time;

public
 function FunctionInlining.ExternalInline1.O.destructor
  input ExternalObject o;
 algorithm
  external \"C\" destructor(o);
  return;
 end FunctionInlining.ExternalInline1.O.destructor;

 function FunctionInlining.ExternalInline1.O.constructor
  output ExternalObject o;
 algorithm
  external \"C\" o = constructor();
  return;
 end FunctionInlining.ExternalInline1.O.constructor;

 function FunctionInlining.ExternalInline1.f
  input ExternalObject o;
  input Real y;
  output Real x;
 algorithm
  external \"C\" x = f(o, y);
  return;
 end FunctionInlining.ExternalInline1.f;

 type FunctionInlining.ExternalInline1.O = ExternalObject;
end FunctionInlining.ExternalInline1;
")})));
	end ExternalInline1;
	
	
	model UninlinableFunction1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="UninlinableFunction1",
			description="Make sure that only unused functions are removed",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.UninlinableFunction1
 Real z[1];
 Real z[2];
 Real z[3];
 Real w[1];
 Real w[2];
equation
 w[1] = FunctionInlining.UninlinableFunction1.f1(z[2], z[3]);
 w[2] = z[1];
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;

public
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
	end UninlinableFunction1;
    
    
    model IfStatementInline1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfStatementInline1",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.IfStatementInline1
 Real z1;
 Real z2;
equation
 z1 = 5;
 z2 = 3;

end FunctionInlining.IfStatementInline1;
")})));
    end IfStatementInline1;
    
    
    model IfStatementInline2
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfStatementInline2",
			description="",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.IfStatementInline2
 Real v;
 Real z;
 Real temp_1;
equation
 v = 2;
 z = noEvent(if temp_1 > 2 then temp_1 else 1) + 2;
 temp_1 = v;
end FunctionInlining.IfStatementInline2;
")})));
    end IfStatementInline2;
    
    
    model IfStatementInline3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfStatementInline3",
			description="",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.IfStatementInline3
 Real v1;
 Real v2;
 Real v3;
 Real z;
 Real temp_1;
equation
 v1 = 1;
 v2 = 2;
 v3 = 3;
 z = noEvent(if temp_1 > 2 then temp_1 else v2) + noEvent(if temp_1 > 2 then v3 else temp_1);
 temp_1 = v1;
end FunctionInlining.IfStatementInline3;
")})));
    end IfStatementInline3;
    
    
    model IfStatementInline4
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfStatementInline4",
			description="",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.IfStatementInline4
 Real v;
 Real z;
 Real temp_1;
equation
 v = 1;
 z = noEvent(if temp_1 > 2 then noEvent(if temp_1 > 2 then temp_1 else 0.0) else temp_1 + 1);
 temp_1 = v;
end FunctionInlining.IfStatementInline4;
")})));
    end IfStatementInline4;
	
	
	model IfStatementInline5
        function f
			input Boolean test;
            input Real x;
            output Real y;
        algorithm
            y := x + 1;
	        if test then
                y := x;
            end if;
        end f;
        
		Real v = time + 1;
        Real z = f(time > 3, v);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfStatementInline5",
			description="Event-generating argument to inlined function",
			inline_functions="all",
			flatModel="
fclass FunctionInlining.IfStatementInline5
 Real v;
 Real z;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
equation
 v = time + 1;
 z = noEvent(if temp_1 then v else v + 1);
 temp_1 = time > 3;
end FunctionInlining.IfStatementInline5;
")})));
	end IfStatementInline5;
    
    
    model IfStatementInline6
        function f
            input Real x;
            output Real y;
        algorithm
            if x > 2 then
                y := x;
            else
                y := 1;
            end if;
        end f;

        Real z = f(if time > 3 then time else 3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfStatementInline6",
			description="Event-generating argument to inlined function",
			inline_functions="all",
			flatModel="
fclass FunctionInlining.IfStatementInline6
 Real z;
 Real temp_1;
equation
 z = noEvent(if temp_1 > 2 then noEvent(if temp_1 > 2 then temp_1 else 0.0) else 1);
 temp_1 = if time > 3 then time else 3;
end FunctionInlining.IfStatementInline6;
")})));
    end IfStatementInline6;
    
    
    model ForStatementInline1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline1",
			description="",
			variability_propagation=false,
			inline_functions="all",
			eliminate_alias_variables=false,
			flatModel="
fclass FunctionInlining.ForStatementInline1
 Real v;
 Real z;
 Real temp_1;
 Real temp_5;
 Real temp_7;
 Real temp_9;
equation
 v = 3;
 z = 1 + temp_5 * temp_5 + temp_7 * temp_7 + temp_9 * temp_9;
 temp_1 = v;
 temp_5 = 1 + (temp_1 - 1) / 3;
 temp_7 = 1 + 2 * ((temp_1 - 1) / 3);
 temp_9 = 1 + 3 * ((temp_1 - 1) / 3);
end FunctionInlining.ForStatementInline1;
")})));
    end ForStatementInline1;
    
    
    model ForStatementInline2
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline2",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ForStatementInline2
 Real z;
equation
 z = 18.22222222222222;

end FunctionInlining.ForStatementInline2;
")})));
    end ForStatementInline2;
    
    
    model ForStatementInline3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline3",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ForStatementInline3
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = v[1] * v[1] + v[2] * v[2] + v[3] * v[3];
end FunctionInlining.ForStatementInline3;
")})));
    end ForStatementInline3;
    
    
    model ForStatementInline4
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline4",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ForStatementInline4
 Real z;
equation
 z = 14;

end FunctionInlining.ForStatementInline4;
")})));
    end ForStatementInline4;


    model ForStatementInline5
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline5",
			description="",
			variability_propagation=false,
			inline_functions="all",
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
 z = noEvent(if v[3] > 2 then temp_12 else temp_12 + v[3]);
 temp_6 = noEvent(if v[1] > 2 then v[1] * v[1] else 0);
 temp_7 = noEvent(if v[1] > 2 then temp_6 else temp_6 + v[1]);
 temp_9 = noEvent(if v[2] > 2 then temp_7 + v[2] * v[2] else temp_7);
 temp_10 = noEvent(if v[2] > 2 then temp_9 else temp_9 + v[2]);
 temp_12 = noEvent(if v[3] > 2 then temp_10 + v[3] * v[3] else temp_10);
end FunctionInlining.ForStatementInline5;
")})));
    end ForStatementInline5;


    model ForStatementInline6
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline6",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ForStatementInline6
 Real z;
equation
 z = 12;

end FunctionInlining.ForStatementInline6;
")})));
    end ForStatementInline6;


    model ForStatementInline7
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline7",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ForStatementInline7
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
 Real temp_12;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = temp_12 + temp_12 + 3 * temp_12 + 4 * temp_12;
 temp_12 = v[1] * v[1] + v[2] * v[2] + v[3] * v[3];
end FunctionInlining.ForStatementInline7;
")})));
    end ForStatementInline7;


    model ForStatementInline8
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ForStatementInline8",
			description="",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.ForStatementInline8
 Real v[1];
 Real v[2];
 Real v[3];
 Real z;
equation
 v[1] = 1;
 v[2] = 2;
 v[3] = 3;
 z = v[1] * v[1] + v[1] * v[2] + v[1] * v[3] + v[2] * v[1] + v[2] * v[2] + v[2] * v[3] + v[3] * v[1] + v[3] * v[2] + v[3] * v[3];
end FunctionInlining.ForStatementInline8;
")})));
    end ForStatementInline8;
	
    
    
    model MultipleOutputsInline1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MultipleOutputsInline1",
			description="Inlining function call using multiple outputs",
			variability_propagation=false,
			inline_functions="all",
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
 x[6] = x[5] + 3;
 x[8] = x[7] + x[6];
 x[5] = x[3] + 1;
 x[7] = x[5] + 1;
end FunctionInlining.MultipleOutputsInline1;
")})));
    end MultipleOutputsInline1;
    
    
    model MultipleOutputsInline2
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MultipleOutputsInline2",
			description="Inlining function call using multiple (but not all) outputs",
			variability_propagation=false,
			inline_functions="all",
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
equation
 x[1] = y[1] + y[2];
 x[2] = y[1] * y[2];
 x[3] = y[3] + y[4];
 x[4] = y[3] - y[4];
 x[5] = y[5] - y[6];
 x[6] = y[5] * y[6];
 y[1] = 1;
 y[2] = 1;
 y[3] = 1;
 y[4] = 1;
 y[5] = 1;
 y[6] = 1;
end FunctionInlining.MultipleOutputsInline2;
")})));
    end MultipleOutputsInline2;


    model MultipleOutputsInline3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MultipleOutputsInline3",
			description="Inlining function call using multiple (but not all) outputs",
			variability_propagation=false,
			inline_functions="all",
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
equation
 x[1] = y[1] + y[2];
 x[2] = y[1] * y[2];
 x[3] = y[3] + y[4];
 x[4] = y[3] - y[4];
 x[5] = y[5] - y[6];
 x[6] = y[5] * y[6];
 y[1] = 1;
 y[2] = 1;
 y[3] = 1;
 y[4] = 1;
 y[5] = 1;
 y[6] = 1;
end FunctionInlining.MultipleOutputsInline3;
")})));
    end MultipleOutputsInline3;
    
    
    model IfEquationInline1
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline1",
			description="Test inlining of function calls in if equations",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.IfEquationInline1
 Real x;
 Real y;
equation
 y = if time > 1 then x else 0;
 x = 1;
end FunctionInlining.IfEquationInline1;
")})));
    end IfEquationInline1;
    
    
    model IfEquationInline2
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline2",
			description="Test inlining of function calls in if equations",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.IfEquationInline2
 parameter Boolean b = true /* true */;
 Real y;
equation
 y = 1;

end FunctionInlining.IfEquationInline2;
")})));
    end IfEquationInline2;
    
    
    model IfEquationInline3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline3",
			description="Test inlining of function calls in if equations",
			variability_propagation=false,
			inline_functions="all",
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
    end IfEquationInline3;
    
    
    model IfEquationInline4
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline4",
			description="Test inlining of function calls in if equations",
			variability_propagation=false,
			inline_functions="all",
			flatModel="
fclass FunctionInlining.IfEquationInline4
 Real x1;
 Real x2;
 Real y;
equation
 y = if time > 1 then x1 else x2;
 x1 = 1;
 x2 = 2;
end FunctionInlining.IfEquationInline4;
")})));
    end IfEquationInline4;
    
    
    model IfEquationInline5
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline5",
			description="Test inlining of function calls in if equations",
			variability_propagation=false,
			inline_functions="all",
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
    end IfEquationInline5;
    
    
    model IfEquationInline6
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline6",
			description="Test inlining of function calls in if equations",
			variability_propagation=false,
			inline_functions="all",
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
    end IfEquationInline6;


model IfEquationInline7
    record R
        Real p;
    end R;
    
    function f1
        input Real p;
        output R r;
    algorithm
        r := R(p);
    end f1;
    
    function f2
        input R r;
        output Real x;
    algorithm
        x := r.p;
    end f2;
    
    Real x;
    Real y;
equation
    if time > 0 then
        x = 4;
        y = 2;
    else
        x = f2(f1(time));
        time = y + 1;
    end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEquationInline7",
			description="Check that temporary equations are removed properly within if equations",
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.IfEquationInline7
 Real x;
 Real y;
 Real temp_1.p;
equation
 temp_1.p = if time > 0 then 0.0 else time;
 x = if time > 0 then 4 else temp_1.p;
 0.0 = if time > 0 then y - 2 else time - (y + 1);

public
 record FunctionInlining.IfEquationInline7.R
  Real p;
 end FunctionInlining.IfEquationInline7.R;

end FunctionInlining.IfEquationInline7;
")})));
end IfEquationInline7;
    
    
    
    model TrivialInline1
        function f
            input Real a;
            input Real b;
            output Real c;
            output Real d;
        algorithm
            c := a + b;
            d := a * b;
        end f;
        
        Real x;
        Real y;
        Real z = 1;
    equation
        if z > 2 then
            x = 3;
            y = 4;
        else
            (x, y) = f(z, 3);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline1",
			description="Test inlining of trivial functions - 2 outputs",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline1
 Real x;
 Real y;
 Real z;
equation
 x = if z > 2 then 3 else z + 3;
 y = if z > 2 then 4 else z * 3;
 z = 1;
end FunctionInlining.TrivialInline1;
")})));
    end TrivialInline1;
    
    
    model TrivialInline2
        function f
            input Real a;
            input Real b;
            output Real c[2];
            output Real d;
        algorithm
            c := {a + b, a-b};
            d := a * b;
        end f;
        
        Real x[2];
        Real z = 1;
    equation
        if z > 2 then
            x[1] = 3;
            x[2] = 4;
        else
            x = f(z, 3);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline2",
			description="Test inlining of trivial functions - 2 outputs, one used",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline2
 Real x[1];
 Real x[2];
 Real z;
 Real temp_1[1];
 Real temp_1[2];
equation
 temp_1[1] = if z > 2 then 0.0 else z + 3;
 temp_1[2] = if z > 2 then 0.0 else z - 3;
 x[1] = if z > 2 then 3 else temp_1[1];
 x[2] = if z > 2 then 4 else temp_1[2];
 z = 1;
end FunctionInlining.TrivialInline2;
")})));
    end TrivialInline2;
    
    
    model TrivialInline3
        record R
            Real a;
            Real b;
        end R;
        
        function f
            input Real c;
            input Real d;
            output R e;
        algorithm
            e := R(c + d, c * d);
        end f;
        
        R x;
        Real z = 1;
    equation
        if z > 2 then
            x = R(3, 4);
        else
            x = f(z, 3);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline3",
			description="Test inlining of trivial functions - record output, record constructor",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline3
 Real x.a;
 Real x.b;
 Real z;
 Real temp_1.a;
 Real temp_1.b;
equation
 temp_1.a = if z > 2 then 0.0 else z + 3;
 temp_1.b = if z > 2 then 0.0 else z * 3;
 x.a = if z > 2 then 3 else temp_1.a;
 x.b = if z > 2 then 4 else temp_1.b;
 z = 1;

public
 record FunctionInlining.TrivialInline3.R
  Real a;
  Real b;
 end FunctionInlining.TrivialInline3.R;

end FunctionInlining.TrivialInline3;
")})));
    end TrivialInline3;
    
    
    model TrivialInline4
        record R
            Real a;
            Real b;
        end R;
        
        function f
            input Real c;
            input Real d;
            output R e;
        algorithm
            e.a := c + d;
			e.b := c * d;
        end f;
        
        R x;
        Real z = 1;
    equation
        if z > 2 then
            x = R(3, 4);
        else
            x = f(z, 3);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline4",
			description="Test inlining of trivial functions - record constructor, separate assignments",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline4
 Real x.a;
 Real x.b;
 Real z;
 Real temp_1.a;
 Real temp_1.b;
equation
 temp_1.a = if z > 2 then 0.0 else z + 3;
 temp_1.b = if z > 2 then 0.0 else z * 3;
 x.a = if z > 2 then 3 else temp_1.a;
 x.b = if z > 2 then 4 else temp_1.b;
 z = 1;

public
 record FunctionInlining.TrivialInline4.R
  Real a;
  Real b;
 end FunctionInlining.TrivialInline4.R;

end FunctionInlining.TrivialInline4;
")})));
    end TrivialInline4;
    
    
    model TrivialInline5
        function f
            input Real a[:];
            input Real b;
            output Real c[size(a,1)];
        algorithm
            c := a * b;
        end f;
        
        Real x[3];
        Real z[3] = {1, 2, 3};
    equation
        if z[1] > 2 then
            x = z[end:-1:1];
        else
            x = f(z, 3);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline5",
			description="Test inlining of trivial functions - array, unknown size",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline5
 Real x[1];
 Real x[2];
 Real x[3];
 Real z[1];
 Real z[2];
 Real z[3];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
equation
 temp_1[1] = if z[1] > 2 then 0.0 else z[1] * 3;
 temp_1[2] = if z[1] > 2 then 0.0 else z[2] * 3;
 temp_1[3] = if z[1] > 2 then 0.0 else z[3] * 3;
 x[1] = if z[1] > 2 then z[3] else temp_1[1];
 x[2] = if z[1] > 2 then z[2] else temp_1[2];
 x[3] = if z[1] > 2 then z[1] else temp_1[3];
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;
end FunctionInlining.TrivialInline5;
")})));
    end TrivialInline5;
    
    
    model TrivialInline6
        function f1
            input Real a;
            output Real b;
        algorithm
            b := f2(a * 2) * 2;
        end f1;
        
        function f2
            input Real c;
            output Real d;
        algorithm
            d := c + 1;
        end f2;
        
        Real x;
        Real z = 1;
    equation
        if z > 2 then
            x = 2;
        else
            x = f1(z);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline6",
			description="Test inlining of trivial functions - function calling function",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline6
 Real x;
 Real z;
equation
 x = if z > 2 then 2 else (z * 2 + 1) * 2;
 z = 1;
end FunctionInlining.TrivialInline6;
")})));
    end TrivialInline6;
    
    
    model TrivialInline7
        function f1
            input Real a;
            output Real b;
            output Real c;
        algorithm
            (b, c) := f2(a);
        end f1;
        
        function f2
            input Real d;
            output Real e;
            output Real f;
        algorithm
            e := d + 1;
			f := d * 2;
        end f2;
        
        Real x;
        Real y;
        Real z = 1;
    equation
        if z > 2 then
            x = 2;
			y = 3;
        else
            (x, y) = f1(z);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline7",
			description="Test inlining of trivial functions - function calling function, 2 outputs",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline7
 Real x;
 Real y;
 Real z;
equation
 x = if z > 2 then 2 else z + 1;
 y = if z > 2 then 3 else z * 2;
 z = 1;
end FunctionInlining.TrivialInline7;
")})));
    end TrivialInline7;
    
    
    model TrivialInline8
        function f
            input Real a[3];
            input Real b;
            output Real c[size(a,1)];
        algorithm
            c := a * b;
        end f;
        
        Real x[3];
        Real z[3] = {1, 2, 3};
    equation
        if z[1] > 2 then
            x = z[end:-1:1];
        else
            x = f(z, 3);
        end if;

    annotation(__JModelica(UnitTesting(tests={ 
        TransformCanonicalTestCase(
            name="TrivialInline8",
            description="Test inlining of trivial functions - array, known size",
			variability_propagation=false,
            inline_functions="trivial",
            flatModel="
fclass FunctionInlining.TrivialInline8
 Real x[1];
 Real x[2];
 Real x[3];
 Real z[1];
 Real z[2];
 Real z[3];
 Real temp_1[1];
 Real temp_1[2];
 Real temp_1[3];
equation
 temp_1[1] = if z[1] > 2 then 0.0 else z[1] * 3;
 temp_1[2] = if z[1] > 2 then 0.0 else z[2] * 3;
 temp_1[3] = if z[1] > 2 then 0.0 else z[3] * 3;
 x[1] = if z[1] > 2 then z[3] else temp_1[1];
 x[2] = if z[1] > 2 then z[2] else temp_1[2];
 x[3] = if z[1] > 2 then z[1] else temp_1[3];
 z[1] = 1;
 z[2] = 2;
 z[3] = 3;
end FunctionInlining.TrivialInline8;
")})));
    end TrivialInline8;
    
    
    model TrivialInline9
        function f
            input Real a;
            input Real b;
            output Real c;
        algorithm
            c := a * b;
			c := c + 2;
        end f;
        
        Real x;
        Real z = 1;
    equation
        if z > 2 then
            x = z;
        else
            x = f(z, 3);
        end if;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TrivialInline9",
			description="Test inlining of trivial functions - non-trivial function",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.TrivialInline9
 Real x;
 Real z;
equation
 x = if z > 2 then z else FunctionInlining.TrivialInline9.f(z, 3);
 z = 1;

public
 function FunctionInlining.TrivialInline9.f
  input Real a;
  input Real b;
  output Real c;
 algorithm
  c := a * b;
  c := c + 2;
  return;
 end FunctionInlining.TrivialInline9.f;

end FunctionInlining.TrivialInline9;
")})));
    end TrivialInline9;


model TrivialInline10
    record R
        Real a;
        Real b[2];      
    end R;
    
    function f
        input Real c;
        output R d;
    algorithm
        d := R(c, {1,2});
    end f;
    
    R x = f(1);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TrivialInline10",
            description="Test that assigning an entire record at once works in trivial inlining mode",
            variability_propagation=false,
			inline_functions="trivial",
            flatModel="
fclass FunctionInlining.TrivialInline10
 Real x.a;
 Real x.b[1];
 Real x.b[2];
equation
 x.a = 1;
 x.b[1] = 1;
 x.b[2] = 2;

public
 record FunctionInlining.TrivialInline10.R
  Real a;
  Real b[2];
 end FunctionInlining.TrivialInline10.R;

end FunctionInlining.TrivialInline10;
")})));
end TrivialInline10;


model InlineAnnotation1
	function f
		input Real a;
		output Real b;
	algorithm
		b := a * a;
		b := b - a;
	annotation(Inline=true);
	end f;
	
	Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation1",
			description="Inline annotation",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation1
 Real x;
 Real temp_1;
equation
 x = temp_1 * temp_1 - temp_1;
 temp_1 = time;
end FunctionInlining.InlineAnnotation1;
")})));
end InlineAnnotation1;


model InlineAnnotation2
    function f
        input Real a;
        output Real b;
    algorithm
        b := a * a;
		while b > a loop
            b := b - a;
		end while;
    annotation(Inline=true);
    end f;
    
    Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation2",
			description="Inline annotation on function that can't be inlined'",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation2
 Real x;
equation
 x = FunctionInlining.InlineAnnotation2.f(time);

public
 function FunctionInlining.InlineAnnotation2.f
  input Real a;
  output Real b;
 algorithm
  b := a * a;
  while b > a loop
   b := b - a;
  end while;
  return;
 end FunctionInlining.InlineAnnotation2.f;

end FunctionInlining.InlineAnnotation2;
")})));
end InlineAnnotation2;


model InlineAnnotation3
    function f
        input Real a;
        output Real b;
    algorithm
        b := a * a;
        b := b - a;
    annotation(LateInline=true);
    end f;
    
    Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation3",
			description="LateInline annotation",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation3
 Real x;
 Real temp_1;
equation
 x = temp_1 * temp_1 - temp_1;
 temp_1 = time;
end FunctionInlining.InlineAnnotation3;
")})));
end InlineAnnotation3;


model InlineAnnotation4
    function f
        input Real a;
        output Real b;
    algorithm
        b := a * a;
        b := b - a;
    annotation(InlineAfterIndexReduction=true);
    end f;
    
    Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation4",
			description="InlineAfterIndexReduction annotation",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation4
 Real x;
 Real temp_1;
equation
 x = temp_1 * temp_1 - temp_1;
 temp_1 = time;
end FunctionInlining.InlineAnnotation4;
")})));
end InlineAnnotation4;


model InlineAnnotation5
    function f
        input Real a;
        output Real b;
    algorithm
        b := a * a;
    annotation(Inline=false);
    end f;
    
    Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation5",
			description="Inline annotation set to false on function we would normally inline",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation5
 Real x;
equation
 x = FunctionInlining.InlineAnnotation5.f(time);

public
 function FunctionInlining.InlineAnnotation5.f
  input Real a;
  output Real b;
 algorithm
  b := a * a;
  return;
 end FunctionInlining.InlineAnnotation5.f;

end FunctionInlining.InlineAnnotation5;
")})));
end InlineAnnotation5;


model InlineAnnotation6
    function f
        input Real a;
        output Real b;
    algorithm
        b := a * a;
    annotation(LateInline=false);
    end f;
    
    Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation6",
			description="LateInline annotation set to false on function we would normally inline",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation6
 Real x;
equation
 x = FunctionInlining.InlineAnnotation6.f(time);

public
 function FunctionInlining.InlineAnnotation6.f
  input Real a;
  output Real b;
 algorithm
  b := a * a;
  return;
 end FunctionInlining.InlineAnnotation6.f;

end FunctionInlining.InlineAnnotation6;
")})));
end InlineAnnotation6;


model InlineAnnotation7
    function f
        input Real a;
        output Real b;
    algorithm
        b := a * a;
    annotation(InlineAfterIndexReduction=false);
    end f;
    
    Real x = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="InlineAnnotation7",
			description="InlineAfterIndexReduction annotation set to false on function we would normally inline",
			inline_functions="trivial",
			variability_propagation=false,
			flatModel="
fclass FunctionInlining.InlineAnnotation7
 Real x;
equation
 x = FunctionInlining.InlineAnnotation7.f(time);

public
 function FunctionInlining.InlineAnnotation7.f
  input Real a;
  output Real b;
 algorithm
  b := a * a;
  return;
 end FunctionInlining.InlineAnnotation7.f;

end FunctionInlining.InlineAnnotation7;
")})));
end InlineAnnotation7;


model EmptyArray
    function f
        input Real d[:,:];
        output Real e;
    algorithm
        e := sum(size(d));
    end f;
    
    parameter Real a[:, :] = fill(0.0,0,2);
    Real x = f(a);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="EmptyArray",
			description="Test inlining of functions with empty arrays",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.EmptyArray
 Real x;
equation
 x = 2;
end FunctionInlining.EmptyArray;
")})));
end EmptyArray;


model BindingExpInRecord
    function f
        input Real i;
        output Real[2] o = { i, -i };
    algorithm
    end f;
    
    record A
        parameter Real[2] x = f(1);
    end A;
    
    A a;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="BindingExpInRecord",
			description="Check that inlining function only used in declaration of record class doesn't cause crash",
			variability_propagation=false,
			inline_functions="trivial",
			flatModel="
fclass FunctionInlining.BindingExpInRecord
 parameter Real a.x[1] = 1 /* 1 */;
 parameter Real a.x[2] = -1 /* -1 */;

public
 record FunctionInlining.BindingExpInRecord.A
  parameter Real x[2];
 end FunctionInlining.BindingExpInRecord.A;

end FunctionInlining.BindingExpInRecord;
")})));
end BindingExpInRecord;


model AssertInline1
	function f
		input Real x;
		output Real y;
	algorithm
		assert(x < 5, "Bad x: " + String(x));
		y := 2 / (x - 5);
		annotation(Inline=true);
	end f;
	
	Real z = f(time);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AssertInline1",
			description="Inline function containing assert",
			flatModel="
fclass FunctionInlining.AssertInline1
 Real z;
 Real temp_1;
equation
 z = 2 / (temp_1 - 5);
 temp_1 = time;
 assert(noEvent(temp_1 < 5), \"Bad x: \" + String(temp_1));
end FunctionInlining.AssertInline1;
")})));
end AssertInline1;

	
end FunctionInlining;
