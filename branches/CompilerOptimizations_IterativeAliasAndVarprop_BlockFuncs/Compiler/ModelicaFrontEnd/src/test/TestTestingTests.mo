/*
	Copyright (C) 2009-2013 Modelon AB

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

package TestTestingTests

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
			flatModel="
fclass TestTestingTests.VariabilityInference
 constant Real x1 = 1;
 constant Boolean x2 = true;
 parameter Real p1 = 4 /* 4 */;
 parameter Real r2;
parameter equation
 r2 = p1 + 1.0;
end TestTestingTests.VariabilityInference;
")})));
end VariabilityInference;


model DoubleDerivative
    Real x;
	Real y;
	Real yder;
    
equation
    y = der(x);
	y = 1;
	yder = der(y);
	

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="DoubleDerivative",
			description="",
			flatModel="
fclass TestTestingTests.DoubleDerivative
 Real x;
 constant Real y = 1;
 constant Real yder = 0.0;
initial equation 
 x = 0.0;
equation
 1.0 = der(x);
end TestTestingTests.DoubleDerivative;
")})));
end DoubleDerivative;


model CopyPropagation
    Real x1,x2,x3,x4;
    
equation
    x1 = 1;
    x2 = x1;
    x3 = x2;
    x4 = x3;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="CopyPropagation",
			description="",
			flatModel="
fclass TestTestingTests.CopyPropagation
 constant Real x2 = 1;
end TestTestingTests.CopyPropagation;
")})));
end CopyPropagation;

model ConstProp
	Real x,y,z,a,b,c;
equation
	x = 1;
    x = y;
    y = z;
    a = x + 10;
    b = z + 7;
    c = z + y;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstProp",
			description="",
			flatModel="
fclass TestTestingTests.ConstProp
 constant Real x = 1;
 constant Real a = 11.0;
 constant Real b = 8.0;
 constant Real c = 2.0;
end TestTestingTests.ConstProp;
")})));
end ConstProp;

model ComSubEl
	Real x1,x2;
	Real x3,x4;
equation
	x1 = sin(x2);
	x2 = x3;
    x3 = x1 + x2 + 3;
    x4 = x1 + x3 - 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ComSubEl",
			description="",
			flatModel="
fclass TestTestingTests.ComSubEl
 Real x1;
 Real x2;
 Real x4;
equation
 x1 = sin(x2);
 x2 = x1 + x2 + 3;
 x4 = x1 + x2 - 4;
end TestTestingTests.ComSubEl;
")})));
end ComSubEl;


model RedEl
	Real a,b,x,y;
equation
	a = sin(b);
	b = x;
	x = a + b;
	y = a + b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RedEl",
			description="",
			flatModel="
fclass TestTestingTests.RedEl
 Real a;
 Real b;
 Real y;
equation
 a = sin(b);
 b = a + b;
 y = a + b;
end TestTestingTests.RedEl;
")})));
end RedEl;

model DumbOpt
	Real a,b;
equation
	a = sin(b);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="DumbOpt",
			description="",
			flatModel="
fclass TestTestingTests.DumbOpt
 Real a;
 Real b;
equation
 a = sin(b);
 b = a + b;
end TestTestingTests.DumbOpt;
")})));
end DumbOpt;


model CircDep
	Real x1,x2;
equation
	x1 = sin(x2);
	x2 = sin(x1);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="CircDep",
			description="",
			flatModel="
fclass TestTestingTests.CircDep
 Real x1;
 Real x2;
equation
 x1 = sin(x2);
 x2 = sin(x1);
end TestTestingTests.CircDep;
")})));
end CircDep;


model TimeDer
	Real x(start=1);
equation
	der(x) = 10;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TimeDer",
			description="",
			flatModel="
fclass TestTestingTests.TimeDer
 Real x(start = 1);
initial equation 
 x = 1;
equation
 der(x) = 10;
end TestTestingTests.TimeDer;
")})));
end TimeDer;


model MissedAlias
	Real a,b,c;
	parameter Real d = 8;
equation
    a = b;
    a + b = 2;
    c = b * d;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MissedAlias",
			description="",
			flatModel="
fclass TestTestingTests.MissedAlias
 constant Real a = 1.0;
 parameter Real c;
 parameter Real d = 8 /* 8 */;
parameter equation
 c = 1.0 * d;
end TestTestingTests.MissedAlias;
")})));
end MissedAlias;


model RevSubEl
	Real t,x1,x2,x4;
equation
    t = x1 + x2;
    x1 = sin(x2);
    x2 = t + 3;
    x4 = t - 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RevSubEl",
			description="",
			flatModel="
fclass TestTestingTests.RevSubEl
 Real t;
 Real x1;
 Real x2;
 Real x4;
equation
 t = x1 + x2;
 x1 = sin(x2);
 x2 = t + 3;
 x4 = t - 4;
end TestTestingTests.RevSubEl;
")})));
end RevSubEl;


model SameIfElse
	Real c;
	Real y;
	parameter Real x = 4;
equation
	y = sin(x);
	x = if x > y then y + c else y + c;	
	
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SameIfElse",
			description="",
			flatModel="
fclass TestTestingTests.SameIfElse
 Real c;
 parameter Real y;
 parameter Real x = 4 /* 4 */;
parameter equation
 y = sin(x);
equation
 x = if x > y then y + c else y + c;
end TestTestingTests.SameIfElse;
")})));
end SameIfElse;


model AlmostSameIfElse
	Real a,b,c;
    Real y;
    parameter Real x = 4;
equation
	a = 3;
	y = sin(x);
	if x > y then x = y + c; b = a + 1; else x = y + c; a = b; end if;
	
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="AlmostSameIfElse",
			description="",
			flatModel="
fclass TestTestingTests.AlmostSameIfElse
 constant Real a = 3;
 Real b;
 Real c;
 parameter Real y;
 parameter Real x = 4 /* 4 */;
parameter equation
 y = sin(x);
equation
 x = if x > y then y + c else y + c;
 0.0 = if x > y then b - 4.0 else 3.0 - b;
end TestTestingTests.AlmostSameIfElse;
")})));
end AlmostSameIfElse;


model SameVarSameEq
	Real x1,x2;
equation
	(x2 * x1) - x1 + (x2 * x1) - (x2 * x1) = 3 + (x2 * x1);
	x1 = sin(cos(x2));
	
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SameVarSameEq",
			description="",
			flatModel="
fclass TestTestingTests.SameVarSameEq
 Real x1;
 Real x2;
equation
 x2 * x1 - x1 + x2 * x1 - x2 * x1 = 3 + x2 * x1;
 x1 = sin(cos(x2));
end TestTestingTests.SameVarSameEq;
")})));
end SameVarSameEq;


model TestReordering
    Real x1,x2;
equation
    x2 + x2 - x1 = 3 + x2 + x2;
    x1 = sin(x2);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="TestReordering",
			description="",
			flatModel="
fclass TestTestingTests.TestReordering
 Real x1;
 Real x2;
equation
 x2 + x2 - x1 = 3 + x2 + x2;
 x1 = sin(x2);
end TestTestingTests.TestReordering;
")})));
end TestReordering;


model ConstAliasing
    Real x,y;
equation
    x = 4;
    y = 4;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstAliasing",
			description="",
			flatModel="
fclass TestTestingTests.ConstAliasing
 constant Real x = 4;
 constant Real y = 4;
end TestTestingTests.ConstAliasing;
")})));
end ConstAliasing;


model SimpOne
	Real x1;
	parameter Real x2;
equation
	x1 = 0 * x2;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SimpOne",
			description="",
			flatModel="
fclass TestTestingTests.SimpOne
 constant Real x1 = 0;
 parameter Real x2;
end TestTestingTests.SimpOne;
")})));
end SimpOne;

model MatrixAlias
    constant Real a[2,2] = {{1,2},{3,4}};
	Real b;
equation
	a[1,1] = b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="MatrixAlias",
			description="",
			flatModel="
fclass TestTestingTests.MatrixAlias
 constant Real a[1,1] = 1;
 constant Real a[1,2] = 2;
 constant Real a[2,1] = 3;
 constant Real a[2,2] = 4;
 constant Real b = 1.0;
end TestTestingTests.MatrixAlias;
")})));
end MatrixAlias;

	

end TestTestingTests;
