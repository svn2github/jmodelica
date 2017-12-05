/*
	Copyright (C) 2013-2017 Modelon AB

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

package VariabilityPropagationInitialTests

package InitialEquation

model InitialEquation1
    parameter Boolean c = false;
    Boolean b = c;
initial equation
    pre(b) = false;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquation1",
            description="Tests that corresponding initial equations are removed",
            flatModel="
fclass VariabilityPropagationInitialTests.InitialEquation.InitialEquation1
 parameter Boolean c = false /* false */;
 parameter Boolean b;
parameter equation
 b = c;
end VariabilityPropagationInitialTests.InitialEquation.InitialEquation1;
")})));
end InitialEquation1;

model InitialEquation2
    Real x(fixed=false,start=3.14);
	Real y;
	parameter Real p1 = 1;
equation
	x = y + 1;
	y = p1 + 1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquation2",
            description="Check fixed=true",
            flatModel="
fclass VariabilityPropagationInitialTests.InitialEquation.InitialEquation2
 parameter Real y;
 parameter Real x(fixed = true,start = 3.14);
 parameter Real p1 = 1 /* 1 */;
parameter equation
 y = p1 + 1;
 x = y + 1;
end VariabilityPropagationInitialTests.InitialEquation.InitialEquation2;
")})));
end InitialEquation2;

model InitialEquation3
    Real x;
    parameter Real p1 = 3;
    Real p2 = p1;
initial equation
    x = p2;
equation
    when time > 1 then
        x = time;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquation3",
            description="Test no propagation of initial equations",
            flatModel="
fclass VariabilityPropagationInitialTests.InitialEquation.InitialEquation3
 discrete Real x;
 parameter Real p1 = 3 /* 3 */;
 parameter Real p2;
 discrete Boolean temp_1;
initial equation 
 x = p2;
 pre(temp_1) = false;
parameter equation
 p2 = p1;
equation
 temp_1 = time > 1;
 x = if temp_1 and not pre(temp_1) then time else pre(x);
end VariabilityPropagationInitialTests.InitialEquation.InitialEquation3;
")})));
end InitialEquation3;

model InitialEquation4
    parameter Real p1;
initial equation
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InitialEquation4",
            description="Test no propagation of initial equations",
            errorMessage="
Error in flattened model:
  The DAE initialization system has 1 equations and 0 free variables.

Error in flattened model:
  The initialization system is structurally singular. The following equation(s) could not be matched to any variable:
    p1 = 3
")})));
end InitialEquation4;

end InitialEquation;

package InitialEquationPropagate

model InitialEquationPropagate1
    parameter Real p1(fixed=false);
initial equation
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquationPropagate1",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialEquationPropagate.InitialEquationPropagate1
 constant Real p1(fixed = true) = 3;
end VariabilityPropagationInitialTests.InitialEquationPropagate.InitialEquationPropagate1;
")})));
end InitialEquationPropagate1;

model InitialEquationPropagate2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
initial equation
    p2 = p1 + 1;
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialEquationPropagate2",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialEquationPropagate.InitialEquationPropagate2
 constant Real p1(fixed = true) = 3;
 constant Real p2(fixed = true) = 4.0;
end VariabilityPropagationInitialTests.InitialEquationPropagate.InitialEquationPropagate2;
")})));
end InitialEquationPropagate2;

end InitialEquationPropagate;

end VariabilityPropagationInitialTests;
