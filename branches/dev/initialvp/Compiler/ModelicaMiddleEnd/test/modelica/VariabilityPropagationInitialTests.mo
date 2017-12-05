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

package FixedFalse

model FixedFalse1
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
initial equation
    p1 = 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse1",
            description="Test propagation of fixed false parameters",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse1
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
initial equation 
 p1 = 23;
 p2 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse1;
")})));
end FixedFalse1;

model FixedFalse2

    function f
        input Real x;
        output Real y2 = x;
        output Real y3 = x;
        algorithm
    end f;

    parameter Real p1(fixed=false);
    Real p2;
    Real p3;
initial equation
    p1 = 23;
equation
    (p2,p3) = f(p1);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse2",
            inline_functions="none",
            description="Test propagation of fixed false parameters, function call equation",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse2
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
 initial parameter Real p3;
initial equation 
 p1 = 23;
 (p2, p3) = VariabilityPropagationInitialTests.FixedFalse.FixedFalse2.f(p1);

public
 function VariabilityPropagationInitialTests.FixedFalse.FixedFalse2.f
  input Real x;
  output Real y2;
  output Real y3;
 algorithm
  y2 := x;
  y3 := x;
  return;
 end VariabilityPropagationInitialTests.FixedFalse.FixedFalse2.f;

end VariabilityPropagationInitialTests.FixedFalse.FixedFalse2;
")})));
end FixedFalse2;

model FixedFalse3
    parameter Real p1(fixed=false);
    discrete Real p2 = p1 + 1;
initial equation
    p1 = 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse3",
            description="Test propagation of fixed false parameters, originally discrete",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse3
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
initial equation 
 p1 = 23;
 p2 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse3;
")})));
end FixedFalse3;

model FixedFalse4
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
    Real p3 = p2 + 1;
initial equation
    p1 = 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse4",
            description="Test propagation of fixed false parameters, chained",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse4
 initial parameter Real p1(fixed = false);
 initial parameter Real p2;
 initial parameter Real p3;
initial equation 
 p1 = 23;
 p2 = p1 + 1;
 p3 = p2 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse4;
")})));
end FixedFalse4;

model FixedFalse5
    parameter Real p1(fixed=false);
    Real p2 = p1 + 1;
    Real p3 = p2;
initial equation
    p1 = p2 * 23;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FixedFalse5",
            description="Test propagation of fixed false parameters, alias",
            flatModel="
fclass VariabilityPropagationInitialTests.FixedFalse.FixedFalse5
 initial parameter Real p1(fixed = false);
 initial parameter Real p3;
 initial parameter Real p2;
initial equation 
 p1 = p3 * 23;
 p2 = p3;
 p3 = p1 + 1;
end VariabilityPropagationInitialTests.FixedFalse.FixedFalse5;
")})));
end FixedFalse5;

end FixedFalse;

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

package InitialSystemPropagate

model InitialSystemPropagateConstant1
    parameter Real p1(fixed=false);
initial equation
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateConstant1",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant1
 constant Real p1(fixed = true) = 3;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant1;
")})));
end InitialSystemPropagateConstant1;

model InitialSystemPropagateConstant2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
initial equation
    p2 = p1 + 1;
    p1 = 3;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateConstant2",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant2
 constant Real p1(fixed = true) = 3;
 constant Real p2(fixed = true) = 4.0;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateConstant2;
")})));
end InitialSystemPropagateConstant2;

model InitialSystemPropagateParameter1
    parameter Real p1(fixed=false);
    parameter Real p;
initial equation
    p1 = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter1",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter1
 parameter Real p1(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter1;
")})));
end InitialSystemPropagateParameter1;

model InitialSystemPropagateParameter2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p;
initial equation
    p2 = p1 + 1;
    p1 = p;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="InitialSystemPropagateParameter2",
            description="Test propagation of initial equations",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter2
 parameter Real p1(fixed = true);
 parameter Real p2(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
 p2 = p1 + 1;
end VariabilityPropagationInitialTests.InitialSystemPropagate.InitialSystemPropagateParameter2;
")})));
end InitialSystemPropagateParameter2;

end InitialSystemPropagate;

package MixedSystemPropagate

model MixedSystemPropagateConstant1
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2;
initial equation
    p3 = p2*p1 + x1*x2;
    p2 = x1*p1;
    p1 = 3;
equation
    x1 = p1*p1;
    x2 = p2*p1*x1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateConstant1",
            description="Test propagation of initial equations, interleaving constant",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant1
 constant Real p1(fixed = true) = 3;
 constant Real p2(fixed = true) = 27.0;
 constant Real p3(fixed = true) = 6642.0;
 constant Real x1 = 9.0;
 constant Real x2 = 729.0;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateConstant1;
")})));
end MixedSystemPropagateConstant1;

model MixedSystemPropagateParameter2
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    parameter Real p3(fixed=false);
    Real x1,x2;
    parameter Real p;
initial equation
    p3 = p2*p1 + x1*x2;
    p2 = x1*p1;
    p1 = p;
equation
    x1 = p1*p1;
    x2 = p2*p1*x1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="MixedSystemPropagateParameter2",
            description="Test propagation of initial equations, interleaving parameter",
            variability_propagation_initial=true,
            eliminate_alias_variables=false,
            flatModel="
fclass VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter2
 parameter Real p1(fixed = true);
 parameter Real x1;
 parameter Real p2(fixed = true);
 parameter Real x2;
 parameter Real p3(fixed = true);
 parameter Real p;
parameter equation
 p1 = p;
 x1 = p1 * p1;
 p2 = x1 * p1;
 x2 = p2 * p1 * x1;
 p3 = p2 * p1 + x1 * x2;
end VariabilityPropagationInitialTests.MixedSystemPropagate.MixedSystemPropagateParameter2;
")})));
end MixedSystemPropagateParameter2;

end MixedSystemPropagate;

end VariabilityPropagationInitialTests;
