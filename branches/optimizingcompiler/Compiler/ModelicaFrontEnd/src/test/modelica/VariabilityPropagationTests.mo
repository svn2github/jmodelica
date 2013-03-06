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

package VariabilityPropagationTests

model VariabilityInference
	Real x1;
	Boolean x2;
	
	parameter Real p1 = 4;
	Real r1;
	Real r2;
equation
	x1 = 1;
	x2 = true;
	r1 = p1;
	r2 = p1 + x1;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="VariabilityInference",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.VariabilityInference
 constant Real x1 = 1;
 constant Boolean x2 = true;
 parameter Real p1 = 4 /* 4 */;
 parameter Real r2;
parameter equation
 r2 = p1 + 1.0;
end VariabilityPropagationTests.VariabilityInference;
")})));
end VariabilityInference;

model SimplifyLitExps
	Real x1;
	Boolean x2;
equation
	x1 = 1 + 2 * 3 - 4 / 8 + 6 * 7 - 8 * 9;
	x2 = true and false or true or false and true;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SimplifyLitExps",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.SimplifyLitExps
 constant Real x1 = -23.5;
 constant Boolean x2 = true;
end VariabilityPropagationTests.SimplifyLitExps;
")})));
end SimplifyLitExps;

model ConstantSubstitution
	Real x1,x2,x3,x4;
equation
	x1 = 1;
	x2 = x3 + x1;
	x3 = x1;
	x4 = x2;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantSubstitution",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.ConstantSubstitution
 constant Real x3 = 1;
 constant Real x4 = 2.0;
end VariabilityPropagationTests.ConstantSubstitution;
")})));
end ConstantSubstitution;

model WhenEq1
	parameter Real p1 = 4;
	Real x1,x2;
equation
	when p1 > 3 then
		x1 = x2 + 1;
	end when;
	x2 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEq1",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.WhenEq1
 parameter Real p1 = 4 /* 4 */;
 discrete Real x1;
 constant Real x2 = 3;
initial equation
 pre(x1) = 0.0;
equation
 when p1 > 3 then
  x1 = 4.0;
 end when;
end VariabilityPropagationTests.WhenEq1;
")})));
end WhenEq1;

model WhenEq2
	Real x1,x2;
equation
	when false then
		x1 = x2 + 1;
	end when;
	x2 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEq2",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.WhenEq2
 discrete Real x1;
 constant Real x2 = 3;
initial equation
 pre(x1) = 0.0;
equation
 when false then
  x1 = 4.0;
 end when;
end VariabilityPropagationTests.WhenEq2;
")})));
end WhenEq2;

model WhenEq3
	constant Real p1 = 4;
	Real x1,x2;
equation
	when 3 <= p1 then
		x1 = x2 + 1;
	end when;
	x2 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEq3",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.WhenEq3
 constant Real p1 = 4;
 discrete Real x1;
 constant Real x2 = 3;
initial equation
 pre(x1) = 0.0;
equation
 when true then
  x1 = 4.0;
 end when;
end VariabilityPropagationTests.WhenEq3;
")})));
end WhenEq3;

model IfEq1
	constant Real p1 = 4;
	Real x1,x2;
equation
	if 3 > p1 then
		x1 = x2 + 1;
	elseif 3 < p1 then
		x1 = x2;
	else
		x1 = x2 - 1;		
	end if;
	x2 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEq1",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.IfEq1
 constant Real p1 = 4;
 constant Real x1 = 3;
end VariabilityPropagationTests.IfEq1;
")})));
end IfEq1;

model IfEq2
	constant Real c1 = 4;
	parameter Real p1 = 1;
	Real x1,x2,x3;
equation
	if (x3 < c1) then
		x1 = 1;
		x2 = p1 + 1;
	else
		x1 = 2;
		x2 = 3;
	end if;
	x3 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEq2",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.IfEq2
 constant Real c1 = 4;
 parameter Real p1 = 1 /* 1 */;
 constant Real x1 = 1;
 parameter Real x2;
 constant Real x3 = 3;
parameter equation
 x2 = p1 + 1;
end VariabilityPropagationTests.IfEq2;
")})));
end IfEq2;

model IfEq3
	constant Real c1 = 4;
	parameter Real p1 = 1;
	Real x1,x2;
equation
	if false then
		x1 = 1;
		x2 = p1;
	else
		x1 = p1;
		x2 = 3;
	end if;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEq3",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.IfEq3
 constant Real c1 = 4;
 parameter Real p1 = 1 /* 1 */;
 constant Real x2 = 3;
end VariabilityPropagationTests.IfEq3;
")})));
end IfEq3;

model IfEq4
	constant Real c1 = 4;
	parameter Real p1 = 1;
	Real x1,x2,x3,x4;
equation
	x3 = 3;
	if (x3 > c1) then
		x1 = 1;
		x2 = p1 + 1;
	elseif (x4 < c1) then
		x1 = 2;
		x2 = p1 + 2;
	else
		x1 = 3;
		x2 = 4;
	end if;
	x4 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfEq4",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.IfEq4
 constant Real c1 = 4;
 parameter Real p1 = 1 /* 1 */;
 constant Real x1 = 2;
 parameter Real x2;
 constant Real x3 = 3;
 constant Real x4 = 3;
parameter equation
 x2 = p1 + 2;
end VariabilityPropagationTests.IfEq4;
")})));
end IfEq4;

model Func1
	Real c_out;
    function f
        output Real c;
    algorithm
    	c := 1;
    end f;
equation
    c_out = f();
    annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Func1",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.Func1
 constant Real c_out = 1;
end VariabilityPropagationTests.Func1;
")})));
end Func1;

model FunctionCallEquation1
	Real x1,x2;
	Real x3,x4;
	Real x5;
	parameter Real p = 3;
	
    function f
    	input Real i1;
        output Real c1;
        output Real c2;
    algorithm
    	c1 := 1*i1;
    	c2 := 2*i1;
    end f;
equation
    (x1,x2) = f(x5);
    (x3,x4) = f(p);
    x5 = 5;
    annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="FunctionCallEquation1",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation1
 constant Real x1 = 5.0;
 constant Real x2 = 10.0;
 parameter Real x3;
 parameter Real x4;
 constant Real x5 = 5;
 parameter Real p = 3 /* 3 */;
parameter equation
 (x3, x4) = VariabilityPropagationTests.FunctionCallEquation1.f(p);

public
 function VariabilityPropagationTests.FunctionCallEquation1.f
  input Real i1;
  output Real c1;
  output Real c2;
 algorithm
  c1 := 1 * i1;
  c2 := 2 * i1;
  return;
 end VariabilityPropagationTests.FunctionCallEquation1.f;
end VariabilityPropagationTests.FunctionCallEquation1;
")})));
end FunctionCallEquation1;

model FunctionCallEquation2
	Real z1[2];
	Real z2[2];
	parameter Real p = 3;
	
    function f
    	input Real i1;
        output Real c[2];
    algorithm
    	c[1] := 1*i1;
    	c[2] := 2*i1;
    end f;
equation
    (z1) = f(1);
    (z2) = f(p);
    annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="FunctionCallEquation2",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation2
 constant Real z1[1] = 1.0;
 constant Real z1[2] = 2.0;
 parameter Real z2[1];
 parameter Real z2[2];
 parameter Real p = 3 /* 3 */;
parameter equation
 ({z2[1], z2[2]}) = VariabilityPropagationTests.FunctionCallEquation2.f(p);

public
 function VariabilityPropagationTests.FunctionCallEquation2.f
  input Real i1;
  output Real[2] c;
 algorithm
  c[1] := 1 * i1;
  c[2] := 2 * i1;
  return;
 end VariabilityPropagationTests.FunctionCallEquation2.f;
end VariabilityPropagationTests.FunctionCallEquation2;
")})));
end FunctionCallEquation2;

model FunctionCallEquation3
	A a;
	A b;
	parameter Real p = 3;
	
    function f
    	input Real i;
        output A o;
    algorithm
    	o := A(i*1,i*2);
    end f;
    
	record A
		Real a;
		Real b;
	end A;
equation
    a = f(3);
    b = f(p);
    annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="FunctionCallEquation3",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.FunctionCallEquation3
 constant Real a.a = 3.0;
 constant Real a.b = 6.0;
 parameter Real b.a;
 parameter Real b.b;
 parameter Real p = 3 /* 3 */;
parameter equation
 (VariabilityPropagationTests.FunctionCallEquation3.A(b.a, b.b)) = VariabilityPropagationTests.FunctionCallEquation3.f(p);

public
 function VariabilityPropagationTests.FunctionCallEquation3.f
  input Real i;
  output VariabilityPropagationTests.FunctionCallEquation3.A o;
 algorithm
  o.a := i * 1;
  o.b := i * 2;
  return;
 end VariabilityPropagationTests.FunctionCallEquation3.f;

 record VariabilityPropagationTests.FunctionCallEquation3.A
  Real a;
  Real b;
 end VariabilityPropagationTests.FunctionCallEquation3.A;

end VariabilityPropagationTests.FunctionCallEquation3;
")})));
end FunctionCallEquation3;


model Der1
	Real x1,x2;
	Real x3,x4;
	Real x5,x6;
	parameter Real p1 = 4;
equation
    x2 = der(x1);
    x1 = 3;
    x3 = der(x4);
    der(x4) = 3;
    x5 = der(x6);
    x6 = p1 + 1;
    annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="Der1",
			description="",
			variability_propagation=true,
			flatModel="
fclass VariabilityPropagationTests.Der1
 constant Real x1 = 3;
 constant Real x2 = 0;
 Real x3;
 Real x4;
 constant Real x5 = 0;
 parameter Real x6;
 parameter Real p1 = 4 /* 4 */;
initial equation 
 x4 = 0.0;
parameter equation
 x6 = p1 + 1;
equation
 x3 = der(x4);
 der(x4) = 3;
end VariabilityPropagationTests.Der1;
")})));
end Der1;

end VariabilityPropagationTests;
