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
            description="A simple testcase that tests elimination",
            flatModel="
fclass LinearEquationElimination.Simple1
 Real a;
 Real b;
 Real c;
 Real x;
equation
 x = a + b + c;
 x * x = 1;
 a * b * c = time;
 sqrt(a ^ 2 + b ^ 2 + c ^ 2) = 1;
end LinearEquationElimination.Simple1;
")})));
    end Simple1;
    
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
end LinearEquationElimination;
