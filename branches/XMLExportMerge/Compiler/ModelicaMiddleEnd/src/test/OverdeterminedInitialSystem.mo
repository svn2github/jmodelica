/*
    Copyright (C) 2009-2014 Modelon AB

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

package OverdeterminedInitialSystem
    
    model Basic1
        Integer a;
        Integer b;
    initial equation
        pre(a) = 0;
        pre(b) = 0;
    equation
        a = b;
        b = if time > 0 then 1 else 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic1",
            description="A basic test",
            flatModel="
fclass OverdeterminedInitialSystem.Basic1
 discrete Integer a;
initial equation 
 pre(a) = 0;
equation
 a = if time > 0 then 1 else 0;
end OverdeterminedInitialSystem.Basic1;
")})));
    end Basic1;

    model Basic2
        Real a;
        Real b;
    initial equation
        a = 1;
        b = 1;
    equation
        der(a) = time;
        a = b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic2",
            description="A basic test",
            flatModel="
fclass OverdeterminedInitialSystem.Basic2
 Real a;
initial equation 
 a = 1;
equation
 der(a) = time;
end OverdeterminedInitialSystem.Basic2;
")})));
    end Basic2;

    model Basic3
        Real x;
        Real y;
    initial equation
        x = 2;
        y = 3;
    equation
        x + 1 = y;
        der(x) = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic3",
            description="A basic test",
            flatModel="
fclass OverdeterminedInitialSystem.Basic3
 Real x;
 Real y;
initial equation 
 x = 2;
equation
 x + 1 = y;
 der(x) = time;
end OverdeterminedInitialSystem.Basic3;
")})));
    end Basic3;

    model Basic4
        Integer a;
        Integer b;
        Integer c;
        Integer d;
    initial equation
        pre(a) = 0;
        pre(b) = 0;
        pre(c) = 2;
    equation
        a = b;
        b = if time > 0 then 1 else 0;
        c = if time > 0 then 2 else -1;
        d = if time > 0 then -2 else -1;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic4",
            description="A basic test with some additional initial equations, this caused problems in BiPGraph",
            flatModel="
fclass OverdeterminedInitialSystem.Basic4
 discrete Integer a;
 discrete Integer c;
 discrete Integer d;
initial equation 
 pre(a) = 0;
 pre(c) = 2;
 pre(d) = 0;
equation
 a = if time > 0 then 1 else 0;
 c = if time > 0 then 2 else -1;
 d = if time > 0 then -2 else -1;
end OverdeterminedInitialSystem.Basic4;
")})));
    end Basic4;

    model Parameter1
        Real x;
        Real y;
        parameter Real p1 = 3;
    initial equation
        x = p1 - 1;
        y = p1;
    equation
        x + 1 = y;
        der(x) = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Parameter1",
            description="A basic test with parameters",
            flatModel="
fclass OverdeterminedInitialSystem.Parameter1
 Real x;
 Real y;
 structural parameter Real p1 = 3 /* 3 */;
initial equation 
 x = p1 - 1;
equation
 x + 1 = y;
 der(x) = time;
end OverdeterminedInitialSystem.Parameter1;
")})));
    end Parameter1;

    model FunctionCall1
        function F
            input Real x;
            output Integer a;
            output Integer b;
        algorithm
            a := if x < 3.12 then 1 else 0;
            b := if x > 42 then 1 else 0;
            annotation(Inline=false);
        end F;
        
        Integer a;
        Integer b;
        Integer c;
    initial equation
        (a,b) = F(6.28);
        c = 0;
    equation
        a = c;
        when time > pre(a) then
            a = pre(a) + 1;
            b = pre(b) * 2;
        end when;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="A basic test with function call equation",
            flatModel="
fclass OverdeterminedInitialSystem.FunctionCall1
 discrete Integer a;
 discrete Integer b;
 discrete Boolean temp_1;
initial equation 
 (a, b) = OverdeterminedInitialSystem.FunctionCall1.F(6.28);
 pre(temp_1) = false;
equation
 temp_1 = time > pre(a);
 a = if temp_1 and not pre(temp_1) then pre(a) + 1 else pre(a);
 b = if temp_1 and not pre(temp_1) then pre(b) * 2 else pre(b);

public
 function OverdeterminedInitialSystem.FunctionCall1.F
  input Real x;
  output Integer a;
  output Integer b;
 algorithm
  a := if x < 3.12 then 1 else 0;
  b := if x > 42 then 1 else 0;
  return;
 end OverdeterminedInitialSystem.FunctionCall1.F;

end OverdeterminedInitialSystem.FunctionCall1;
")})));
    end FunctionCall1;

    model HighIndex1
        Real x;
        Real y;
        Real vx;
        Real vy;
    initial equation
        vx = -1;
        vy = 1;
    equation
        der(vx) + der(vy) = 0;
        vx = der(x);
        vy = der(y);
        x + y = 2;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="HighIndex1",
            description="Test so that ceval through dummy expressions are done correctly.",
            flatModel="
fclass OverdeterminedInitialSystem.HighIndex1
 Real x;
 Real y;
 Real vx;
 Real vy;
 Real _der_vx;
 Real _der_y;
 Real _der_der_x;
 Real _der_der_y;
initial equation 
 vy = 1;
 x = 0.0;
equation
 _der_vx + der(vy) = 0;
 vx = der(x);
 vy = _der_y;
 x + y = 2;
 der(x) + _der_y = 0;
 _der_vx = _der_der_x;
 der(vy) = _der_der_y;
 _der_der_x + _der_der_y = 0;
end OverdeterminedInitialSystem.HighIndex1;
")})));
    end HighIndex1;
end OverdeterminedInitialSystem;
