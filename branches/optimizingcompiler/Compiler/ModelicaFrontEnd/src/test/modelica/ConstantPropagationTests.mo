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

package ConstantPropagationTests

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
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.VariabilityInference
 constant Real x1 = 1;
 constant Boolean x2 = true;
 parameter Real p1 = 4 /* 4 */;
 parameter Real r1;
 parameter Real r2;
parameter equation
 r1 = p1;
 r2 = p1 + 1;
end ConstantPropagationTests.VariabilityInference;
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
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.SimplifyLitExps
 constant Real x1 = -23.5;
 constant Boolean x2 = true;
end ConstantPropagationTests.SimplifyLitExps;
")})));
end SimplifyLitExps;

model ConstantSubstitution
	Real x1,x2,x3,x4;
equation
	x1 = 1;
	x2 = x3;
	x3 = x1;
	x4 = x2;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantSubstitution",
			description="",
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.ConstantSubstitution
 constant Real x1 = 1;
 constant Real x2 = 1;
 constant Real x3 = 1;
 constant Real x4 = 1;
end ConstantPropagationTests.ConstantSubstitution;
")})));
end ConstantSubstitution;

model WhenEq1
	parameter Real p1 = 4;
	Real x1,x2;
equation
	when p1 > 3 then
		x1 = x2;
	end when;
	x2 = 3;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="WhenEq1",
			description="",
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.WhenEq1
 parameter Real p1 = 4;
 discrete Real x1;
 constant Real x2 = 3;
initial equation
 pre(x1) = 0.0;
equation
 when p1 > 3 then
  x1 = 3;
 end when;
end ConstantPropagationTests.WhenEq1;
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
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.WhenEq2
 discrete Real x1;
 constant Real x2 = 3;
initial equation
 pre(x1) = 0.0;
equation
 when false then
  x1 = 4;
 end when;
end ConstantPropagationTests.WhenEq2;
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
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.WhenEq3
 constant Real p1 = 4;
 discrete Real x1;
 constant Real x2 = 3;
initial equation
 pre(x1) = 0.0;
equation
 when 3 <= 4.0 then
  x1 = 4;
 end when;
end ConstantPropagationTests.WhenEq3;
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
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.IfEq1
 constant Real p1 = 4;
 Real x1;
 constant Real x2 = 3;
equation
 x1 = 3;
end ConstantPropagationTests.IfEq1;
")})));
end IfEq1;


end ConstantPropagationTests;
