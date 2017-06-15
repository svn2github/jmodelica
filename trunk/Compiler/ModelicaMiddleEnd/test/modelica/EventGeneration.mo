/*
    Copyright (C) 2009-2017 Modelon AB

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

package EventGeneration


model Nested
  Real x;
equation
  1 + x = integer(3 + floor((time * 0.3) + 4.2) * 4);

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_Nested",
      description="Tests extraction of nested event generating expressions
      into when equations.",
      flatModel="
fclass EventGeneration.Nested
 Real x;
 discrete Real temp_1;
 discrete Integer temp_2;
initial equation 
 pre(temp_1) = 0.0;
 pre(temp_2) = 0;
equation
 1 + x = temp_2;
 temp_1 = if time * 0.3 + 4.2 < pre(temp_1) or time * 0.3 + 4.2 >= pre(temp_1) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_1);
 temp_2 = if 3 + temp_1 * 4 < pre(temp_2) or 3 + temp_1 * 4 >= pre(temp_2) + 1 or initial() then integer(3 + temp_1 * 4) else pre(temp_2);
end EventGeneration.Nested;
      
")})));
end Nested;

model InAlgorithm
  Real x;
algorithm
  x := integer(3 + floor((time * 0.3) + 4.2) * 4);

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InAlgorithm",
      description="Tests extraction of event generating expressions in algorithms.",
      flatModel="
fclass EventGeneration.InAlgorithm
 Real x;
 discrete Real temp_1;
 discrete Integer temp_2;
 Real _eventIndicator_1;
 Real _eventIndicator_2;
 Real _eventIndicator_3;
 Real _eventIndicator_4;
initial equation
 pre(temp_1) = 0.0;
 pre(temp_2) = 0;
algorithm
 temp_1 := if time * 0.3 + 4.2 < pre(temp_1) or time * 0.3 + 4.2 >= (pre(temp_1) + 1) or initial() then floor(time * 0.3 + 4.2) else pre(temp_1);
 _eventIndicator_3 := 3 + temp_1 * 4 - pre(temp_2);
 _eventIndicator_4 := 3 + temp_1 * 4 - (pre(temp_2) + 1);
 temp_2 := if 3 + temp_1 * 4 < pre(temp_2) or 3 + temp_1 * 4 >= (pre(temp_2) + 1) or initial() then integer(3 + temp_1 * 4) else pre(temp_2);
 x := temp_2;
equation
 _eventIndicator_1 = time * 0.3 + 4.2 - pre(temp_1);
 _eventIndicator_2 = time * 0.3 + 4.2 - (pre(temp_1) + 1);
end EventGeneration.InAlgorithm;
")})));
end InAlgorithm;

model InFunctionCall

  function f
    input Real x;
    output Real y;
  algorithm
   y := mod(x,2);
   return;
  end f;
  
  Real x;
equation
  x = f(integer(0.9 + time/10) * 3.14);

  annotation(__JModelica(UnitTesting(tests={
    TransformCanonicalTestCase(
      name="EventGeneration_InFunctionCall",
      description="Tests event generating expressions in function calls.",
      flatModel="
fclass EventGeneration.InFunctionCall
 Real x;
 discrete Integer temp_1;
 discrete Real temp_2;
initial equation 
 pre(temp_1) = 0;
 pre(temp_2) = 0.0;
equation
 x = temp_2 - noEvent(floor(temp_2 / 2)) * 2;
 temp_1 = if 0.9 + time / 10 < pre(temp_1) or 0.9 + time / 10 >= pre(temp_1) + 1 or initial() then integer(0.9 + time / 10) else pre(temp_1);
 temp_2 = temp_1 * 3.14;
end EventGeneration.InFunctionCall;
      
")})));
end InFunctionCall;


model InWhenClauses1
       Real x;
equation
    when integer(time*3) + noEvent(integer(time*3)) > 1 then
        x = floor(time * 0.3 + 4.2);
    end when;

       annotation(__JModelica(UnitTesting(tests={
               TransformCanonicalTestCase(
                       name="EventGeneration_InWhenClauses1",
      description="Tests event generating expressions in a when equation.",
      flatModel="
fclass EventGeneration.InWhenClauses1
 discrete Real x;
 discrete Integer temp_1;
 discrete Real temp_2;
 discrete Boolean temp_3;
initial equation 
 pre(temp_1) = 0;
 pre(temp_2) = 0.0;
 pre(x) = 0.0;
 pre(temp_3) = false;
equation
 temp_3 = temp_1 + noEvent(integer(time * 3)) > 1;
 x = if temp_3 and not pre(temp_3) then temp_2 else pre(x);
 temp_1 = if time * 3 < pre(temp_1) or time * 3 >= pre(temp_1) + 1 or initial() then integer(time * 3) else pre(temp_1);
 temp_2 = if time * 0.3 + 4.2 < pre(temp_2) or time * 0.3 + 4.2 >= pre(temp_2) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_2);
end EventGeneration.InWhenClauses1;
")})));
end InWhenClauses1;

model InWhenClauses2
       Real x;
algorithm
    when integer(time*3) + noEvent(integer(time*3)) > 1 then
        x := floor(time * 0.3 + 4.2);
    end when;

       annotation(__JModelica(UnitTesting(tests={
               TransformCanonicalTestCase(
                       name="EventGeneration_InWhenClauses2",
      description="Tests event generating expressions in a when statement.",
      flatModel="
fclass EventGeneration.InWhenClauses2
 discrete Real x;
 discrete Real temp_1;
 discrete Integer temp_2;
 Real _eventIndicator_1;
 Real _eventIndicator_2;
 Real _eventIndicator_3;
 Real _eventIndicator_4;
 discrete Boolean temp_3;
initial equation
 pre(temp_1) = 0.0;
 pre(temp_2) = 0;
 pre(x) = 0.0;
 pre(temp_3) = false;
algorithm
 temp_2 := if time * 3 < pre(temp_2) or time * 3 >= (pre(temp_2) + 1) or initial() then integer(time * 3) else pre(temp_2);
 temp_3 := temp_2 + noEvent(integer(time * 3)) > 1;
 if temp_3 and not pre(temp_3) then
  temp_1 := if time * 0.3 + 4.2 < pre(temp_1) or time * 0.3 + 4.2 >= pre(temp_1) + 1 or initial() then floor(time * 0.3 + 4.2) else pre(temp_1);
  x := temp_1;
 end if;
equation
 _eventIndicator_1 = time * 3 - pre(temp_2);
 _eventIndicator_2 = time * 3 - (pre(temp_2) + 1);
 _eventIndicator_3 = time * 0.3 + 4.2 - pre(temp_1);
 _eventIndicator_4 = time * 0.3 + 4.2 - (pre(temp_1) + 1);
end EventGeneration.InWhenClauses2;
")})));
end InWhenClauses2;

model InInitialAlgorithm
       Integer x;
initial algorithm
  x := integer(time);
equation
  when (time >= 1) then
    x = integer(time);
  end when;

       annotation(__JModelica(UnitTesting(tests={
               TransformCanonicalTestCase(
                       name="EventGeneration_InInitialAlgorithm",
      description="Tests event generating expressions in a when equation.",
      flatModel="
fclass EventGeneration.InInitialAlgorithm
 discrete Integer x;
 discrete Integer temp_1;
 discrete Boolean temp_2;
initial equation 
 algorithm
  x := integer(time);
;
 pre(temp_1) = 0;
 pre(temp_2) = false;
equation
 temp_2 = time >= 1;
 x = if temp_2 and not pre(temp_2) then temp_1 else pre(x);
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end EventGeneration.InInitialAlgorithm;
")})));
end InInitialAlgorithm;

model InInitialEquation
       Real x;
initial equation
  x = integer(time);
equation
  when (time >= 1) then
    x = integer(time);
  end when;

       annotation(__JModelica(UnitTesting(tests={
               TransformCanonicalTestCase(
                       name="EventGeneration_InInitialEquation",
      description="Tests event generating expressions in a when equation.",
      flatModel="
fclass EventGeneration.InInitialEquation
 discrete Real x;
 discrete Integer temp_1;
 discrete Boolean temp_2;
initial equation 
 x = integer(time);
 pre(temp_1) = 0;
 pre(temp_2) = false;
equation
 temp_2 = time >= 1;
 x = if temp_2 and not pre(temp_2) then temp_1 else pre(x);
 temp_1 = if time < pre(temp_1) or time >= pre(temp_1) + 1 or initial() then integer(time) else pre(temp_1);
end EventGeneration.InInitialEquation;
")})));
end InInitialEquation;

model OutputVars1
    discrete Integer i(start=0, fixed=true);
    discrete Real t;
  equation
    i = 1;
  algorithm
    when time > 1 + i then
        t := time + 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVars1",
            description="Test that event indicators are generated as equations when not referenced in LHS,
                option not set.",
            event_output_vars=false,
            flatModel="
fclass EventGeneration.OutputVars1
 constant Integer i(start = 0,fixed = true) = 1;
 discrete Real t;
 Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time > 2;
algorithm
 if temp_1 and not pre(temp_1) then
  t := time + 1;
 end if;
equation
 _eventIndicator_1 = time - 2;
end EventGeneration.OutputVars1;
")})));
end OutputVars1;

model OutputVars2
    discrete Integer i(start=0, fixed=true);
    discrete Real t;
  equation
    i = 1;
  algorithm
    when time > 1 + t then
        t := time + 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVars2",
            description="Test that event indicators are generated as statements when referenced in LHS, option set.",
            event_output_vars=false,
            flatModel="
fclass EventGeneration.OutputVars2
 constant Integer i(start = 0,fixed = true) = 1;
 discrete Real t;
 Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
algorithm
 _eventIndicator_1 := time - (1 + t);
 temp_1 := time > 1 + t;
 if temp_1 and not pre(temp_1) then
  t := time + 1;
 end if;
end EventGeneration.OutputVars2;
")})));
end OutputVars2;

model OutputVars3
    discrete Integer i(start=0, fixed=true);
    discrete Real t;
  equation
    i = 1;
  algorithm
    when time > 1 + i then
        t := time + 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVars3",
            description="Test that event indicators are generated as equations when not referenced in LHS, option set.",
            event_output_vars=true,
            flatModel="
fclass EventGeneration.OutputVars3
 constant Integer i(start = 0,fixed = true) = 1;
 discrete Real t;
 output Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
equation
 temp_1 = time > 2;
algorithm
 if temp_1 and not pre(temp_1) then
  t := time + 1;
 end if;
equation
 _eventIndicator_1 = time - 2;
end EventGeneration.OutputVars3;
")})));
end OutputVars3;

model OutputVars4
    discrete Integer i(start=0, fixed=true);
    discrete Real t;
  equation
    i = 1;
  algorithm
    when time > 1 + t then
        t := time + 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="EventGeneration_OutputVars4",
            description="Test that event indicators are generated as statements when referenced in LHS, option set.",
            event_output_vars=true,
            flatModel="
fclass EventGeneration.OutputVars4
 constant Integer i(start = 0,fixed = true) = 1;
 discrete Real t;
 output Real _eventIndicator_1;
 discrete Boolean temp_1;
initial equation
 pre(t) = 0.0;
 pre(temp_1) = false;
algorithm
 _eventIndicator_1 := time - (1 + t);
 temp_1 := time > 1 + t;
 if temp_1 and not pre(temp_1) then
  t := time + 1;
 end if;
end EventGeneration.OutputVars4;
")})));
end OutputVars4;


end EventGeneration;