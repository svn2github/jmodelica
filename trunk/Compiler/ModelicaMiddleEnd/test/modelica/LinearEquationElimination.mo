/*
    Copyright (C) 2009-2015 Modelon AB

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


package LinearEquationElimination
    model Simple1
        Real a,b,c,y,x;
    equation
        x = a + b + c;
        a + b + c = y;
        y * x = 1;
        a * b * c = time;
        sqrt(a^2 + b^2 + c^2) = 1;
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple1",
            description="A simple test case that tests elimination",
            flatModel="
fclass LinearEquationElimination.Simple1
 Real a;
 Real b;
 Real c;
 Real y;
equation
 y = a + b + c;
 y * y = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;
end LinearEquationElimination.Simple1;
")})));
    end Simple1;

    model Simple2
        Real a;
        Real b;
        Real c;
        Real d;
    equation
        a = 2 * b + time;
        c = 2 * a - b;
        b = a + 2 * d;
        d = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple2",
            description="A simple test case that tests elimination.",
            flatModel="
fclass LinearEquationElimination.Simple2
 Real a;
 Real b;
 Real c;
 Real d;
equation
 a = 2 * b + time;
 c = -2 * (- time) + 3 * b;
 -2 * d = time + b;
 d = sin(time);
end LinearEquationElimination.Simple2;
")})));
    end Simple2;

    model Option1
        Real a,b,c,y,x;
    equation
        x = a + b + c;
        a + b + c = y;
        y * x = 1;
        a * b * c = time;
        sqrt(a^2 + b^2 + c^2) = 1;
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Option1",
            eliminate_linear_equations=false,
            description="Ensure that no elimination is done if option is false",
            flatModel="
fclass LinearEquationElimination.Option1
 Real a;
 Real b;
 Real c;
 Real y;
 Real x;
equation
 x = a + b + c;
 a + b + c = y;
 y * x = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;
end LinearEquationElimination.Option1;
")})));
    end Option1;


    model FunctionCall1
        function F
            input Real i;
            output Real o;
        algorithm
            o := i + 1;
        annotation(Inline=false);
        end F;
        Real a,b,c,y,x;
    equation
        F(x) = a + b + c;
        a + b + c = y;
        y * x = 1;
        a * b * c = time;
        sqrt(a^2 + b^2 + c^2) = 1;
        
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="Ensure that no elimination is done if there is a function call in one of the expressions",
            eliminate_linear_equations=false,
            flatModel="
fclass LinearEquationElimination.FunctionCall1
 Real a;
 Real b;
 Real c;
 Real y;
 Real x;
equation
 LinearEquationElimination.FunctionCall1.F(x) = a + b + c;
 a + b + c = y;
 y * x = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;

public
 function LinearEquationElimination.FunctionCall1.F
  input Real i;
  output Real o;
 algorithm
  o := i + 1;
  return;
 annotation(Inline = false);
 end LinearEquationElimination.FunctionCall1.F;

end LinearEquationElimination.FunctionCall1;
")})));
    end FunctionCall1;


    model Constant1
        Real a;
        Real b;
        Real c;
    equation
        a = b + 1;
        b = c + 1;
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Constant1",
            description="Alias elimination through re-arrangement of variable ordering, solving for equations with
                    constant terms.",
            flatModel="
fclass LinearEquationElimination.Constant1
 Real a;
 Real b;
 Real c;
equation
 a = b + 1;
 - c = - a + 2;
 c = sin(time);
end LinearEquationElimination.Constant1;
")})));
    end Constant1;


    model Coefficient1
        Real a;
        Real b;
        Real c;
    equation
        a = 2 * b;
        a = 4 * c;
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Coefficient1",
            description="Alias elimination through re-arrangement of variable ordering, with coefficients.",
            flatModel="
fclass LinearEquationElimination.Coefficient1
 Real a;
 Real b;
 Real c;
equation
 a = 2 * b;
 -4 * c = -2 * b;
 c = sin(time);
end LinearEquationElimination.Coefficient1;
")})));
    end Coefficient1;


    model Coefficient2
        Real a;
        Real b;
        Real c;
    equation
        3 * a = 2 * b;
        2 * a = 4 * c;
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Coefficient2",
            description="Alias elimination through re-arrangement of variable ordering, with coefficients on
                    both sides.",
            flatModel="
fclass LinearEquationElimination.Coefficient2
 Real a;
 Real b;
 Real c;
equation
 3 * a = 2 * b;
 -4 * c = 2 / 3 * (-2 * b);
 c = sin(time);
end LinearEquationElimination.Coefficient2;
")})));
    end Coefficient2;


    model TimeExpression1
        Real a;
        Real b;
    equation
        a = time + 1;
        b = a + 1;

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TimeExpression1",
            description="Find alias expressions where time is an alias.",
            flatModel="
fclass LinearEquationElimination.TimeExpression1
 Real a;
 Real b;
equation
 a = time + 1;
 b = time + 2;
end LinearEquationElimination.TimeExpression1;
")})));
    end TimeExpression1;


    model TimeExpression2

        Real a;
        Real b;
        Real c;
    equation
        a = time + 1;
        b = time - 1;
        c = sin(time);

        annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TimeExpression2",
            description="Find alias expressions when time expression is mutual.",
            flatModel="
fclass LinearEquationElimination.TimeExpression2
 Real a;
 Real b;
 Real c;
equation
 a = time + 1;
 b = a + -2;
 c = sin(time);
end LinearEquationElimination.TimeExpression2;
")})));
    end TimeExpression2;


end LinearEquationElimination;
