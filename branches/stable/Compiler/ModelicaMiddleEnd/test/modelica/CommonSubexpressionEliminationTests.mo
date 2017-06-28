/*
	Copyright (C) 2015 Modelon AB

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

within ;
package CommonSubexpressionEliminationTests

    function f1
        input Real x;
        output Real y1 = x;
        output Real y2 = x;
    algorithm
        annotation(Inline=false);
    end f1;

model FunctionCall1
    Real y1 = f1(time);
    Real y2 = f1(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall1
 Real y1;
equation
 y1 = CommonSubexpressionEliminationTests.f1(time);

public
 function CommonSubexpressionEliminationTests.f1
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.f1;

end CommonSubexpressionEliminationTests.FunctionCall1;
")})));
end FunctionCall1;

model FunctionCall2
    Real y1;
    Real y2,y3;
equation
    y1 = f1(time);
    (y2,y3) = f1(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall2",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall2
 Real y1;
 Real y3;
equation
 (y1, y3) = CommonSubexpressionEliminationTests.f1(time);

public
 function CommonSubexpressionEliminationTests.f1
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.f1;

end CommonSubexpressionEliminationTests.FunctionCall2;
")})));
end FunctionCall2;

model FunctionCall3
    Real y1;
    Real y2,y3;
equation
    (y2,y3) = f1(time);
    y1 = f1(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall3",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall3
 Real y1;
 Real y3;
equation
 (y1, y3) = CommonSubexpressionEliminationTests.f1(time);

public
 function CommonSubexpressionEliminationTests.f1
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.f1;

end CommonSubexpressionEliminationTests.FunctionCall3;
")})));
end FunctionCall3;

model FunctionCall4
    Real y1,y4;
    Real y2,y3;
equation
    (y2,y3) = f1(time);
    (y1,y4) = f1(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall4",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall4
 Real y2;
 Real y3;
equation
 (y2, y3) = CommonSubexpressionEliminationTests.f1(time);

public
 function CommonSubexpressionEliminationTests.f1
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.f1;

end CommonSubexpressionEliminationTests.FunctionCall4;
")})));
end FunctionCall4;

model FunctionCall5
    Real y1,y2;
equation
    (y1, ) = f1(time);
    ( ,y2) = f1(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall5",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall5
 Real y1;
 Real y2;
equation
 (y1, y2) = CommonSubexpressionEliminationTests.f1(time);

public
 function CommonSubexpressionEliminationTests.f1
  input Real x;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x;
  y2 := x;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.f1;

end CommonSubexpressionEliminationTests.FunctionCall5;
")})));
end FunctionCall5;

model FunctionCall6

    record R
        Real x;
        Real[2,1] y;
    end R;
    
    function f2
        input Real x;
        output Real y = x;
        output R r = R(x,{{x},{x}});
    algorithm
        annotation(Inline=false);
    end f2;

    Real y1,y2;
    R y3,y4;
equation
    (y1, ) = f2(time);
    ( ,y3) = f2(time);
    (y2,y4) = f2(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall6",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall6
 Real y1;
 Real y3.x;
 Real y3.y[1,1];
 Real y3.y[2,1];
equation
 (y1, CommonSubexpressionEliminationTests.FunctionCall6.R(y3.x, {{y3.y[1,1]}, {y3.y[2,1]}})) = CommonSubexpressionEliminationTests.FunctionCall6.f2(time);

public
 function CommonSubexpressionEliminationTests.FunctionCall6.f2
  input Real x;
  output Real y;
  output CommonSubexpressionEliminationTests.FunctionCall6.R r;
 algorithm
  y := x;
  r.x := x;
  r.y[1,1] := x;
  r.y[2,1] := x;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.FunctionCall6.f2;

 record CommonSubexpressionEliminationTests.FunctionCall6.R
  Real x;
  Real y[2,1];
 end CommonSubexpressionEliminationTests.FunctionCall6.R;

end CommonSubexpressionEliminationTests.FunctionCall6;
")})));
end FunctionCall6;

model FunctionCall7

    function f2
        input Real x;
    algorithm
        assert(x > 0, "msg");
        annotation(Inline=false);
    end f2;

equation
    f2(time);
    f2(time);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall7",
            description="Elimination of duplicate function call",
            flatModel="
fclass CommonSubexpressionEliminationTests.FunctionCall7
equation
 CommonSubexpressionEliminationTests.FunctionCall7.f2(time);

public
 function CommonSubexpressionEliminationTests.FunctionCall7.f2
  input Real x;
 algorithm
  assert(x > 0, \"msg\");
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.FunctionCall7.f2;

end CommonSubexpressionEliminationTests.FunctionCall7;
")})));
end FunctionCall7;


model ParameterFunctionCall1
    function f
        input Real x1;
        input Real x2;
        output Real y1;
        output Real y2;
    algorithm
        y1 := x1 + x2;
        y2 := x1 * x2;
        annotation(Inline=false);
    end f;
    
    parameter Real p1 = 1;
    parameter Real p2 = 2;
    Real x1, x2, x3, x4;
equation
    (x1, x2) = f(p1, p2);
    (x3, x4) = f(p1, p2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ParameterFunctionCall1",
            description="",
            variability_propagation=false,
            flatModel="
fclass CommonSubexpressionEliminationTests.ParameterFunctionCall1
 parameter Real p1 = 1 /* 1 */;
 parameter Real p2 = 2 /* 2 */;
 Real x1;
 Real x2;
equation
 (x1, x2) = CommonSubexpressionEliminationTests.ParameterFunctionCall1.f(p1, p2);

public
 function CommonSubexpressionEliminationTests.ParameterFunctionCall1.f
  input Real x1;
  input Real x2;
  output Real y1;
  output Real y2;
 algorithm
  y1 := x1 + x2;
  y2 := x1 * x2;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.ParameterFunctionCall1.f;

end CommonSubexpressionEliminationTests.ParameterFunctionCall1;
")})));
end ParameterFunctionCall1;


model ParameterFunctionCall2
    function f
        input Real x1;
        input Real x2;
        output Real y;
    algorithm
        y := x1 * x2;
        annotation(Inline=false);
    end f;
    
    parameter Real p1 = 1;
    parameter Real p2 = 2;
    Real x1, x2;
equation
    x1 = f(p1, p2);
    x2 = f(p1, p2);

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ParameterFunctionCall2",
            description="",
            variability_propagation=false,
            flatModel="
fclass CommonSubexpressionEliminationTests.ParameterFunctionCall2
 parameter Real p1 = 1 /* 1 */;
 parameter Real p2 = 2 /* 2 */;
 Real x1;
 Real x2;
 parameter Real temp_1;
parameter equation
 temp_1 = CommonSubexpressionEliminationTests.ParameterFunctionCall2.f(p1, p2);
equation
 x1 = temp_1;
 x2 = temp_1;

public
 function CommonSubexpressionEliminationTests.ParameterFunctionCall2.f
  input Real x1;
  input Real x2;
  output Real y;
 algorithm
  y := x1 * x2;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.ParameterFunctionCall2.f;

end CommonSubexpressionEliminationTests.ParameterFunctionCall2;
")})));
end ParameterFunctionCall2;


model InfiniteLoop
  function func
    input Boolean b1;
    output Boolean b2;
  algorithm
    b2 := b1;
    annotation(Inline = false);
  end func;

    Real x;
    Real y;
  initial equation
    x = 1;
    y = 1;
  equation
    when {func(initial())} then
      x=2;
    end when;
    when {func(initial())} then
      y=2;
    end when;

      annotation(__JModelica(UnitTesting(tests={
          TimeTestCase(
            name="CSE_TemporaryVariables",
            description="Verifies that temporary variables used for function calls aren't created twice.
                         This caused an inifinite loop. #5389.",
            variability_propagation=false,
            maxTime=1.0
)})));
end InfiniteLoop;


model DuplicateTemporaries
  function func
    input Boolean b1;
    output Boolean b2;
  algorithm
    b2 := b1;
    annotation(Inline = false);
  end func;

    Real x;
    Real y;
  initial equation
    x = 1;
    y = 1;
  equation
    when {func(initial())} then
      x=2;
    end when;
    when {func(initial())} then
      y=2;
    end when;

      annotation(__JModelica(UnitTesting(tests={
          TransformCanonicalTestCase(
            name="CSE_DuplicateTemporaries",
            description="Verifies that temporary variables used for function calls aren't created twice.
                         This caused an inifinite loop. #5389.",
            variability_propagation=false,
            flatModel="
fclass CommonSubexpressionEliminationTests.DuplicateTemporaries
 discrete Real x;
 discrete Real y;
 discrete Boolean temp_1;
initial equation
 x = 1;
 y = 1;
 pre(temp_1) = false;
equation
 x = if temp_1 and not pre(temp_1) then 2 else pre(x);
 y = if temp_1 and not pre(temp_1) then 2 else pre(y);
 temp_1 = CommonSubexpressionEliminationTests.DuplicateTemporaries.func(initial());

public
 function CommonSubexpressionEliminationTests.DuplicateTemporaries.func
  input Boolean b1;
  output Boolean b2;
 algorithm
  b2 := b1;
  return;
 annotation(Inline = false);
 end CommonSubexpressionEliminationTests.DuplicateTemporaries.func;

end CommonSubexpressionEliminationTests.DuplicateTemporaries;
")})));
end DuplicateTemporaries;

end CommonSubexpressionEliminationTests;
