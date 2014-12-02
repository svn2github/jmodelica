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


package NonFixedParameterPropagation
    
    model Simple1
        parameter Real x(fixed=false, start=3.14);
        parameter Real y = x;
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple1",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple1
 parameter Real x(fixed = false,start = 3.14);
 parameter Real y(fixed = false);
 parameter Real z(start = 1,fixed = false);
initial equation 
 x = 3.14;
 y = x;
 z = y;
end NonFixedParameterPropagation.Simple1;
")})));
    end Simple1;
    
    model Simple2
        parameter Real x(fixed=false, start=3.14);
        parameter Real y(fixed=false) = x;
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple2",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple2
 parameter Real x(fixed = false,start = 3.14);
 parameter Real y(fixed = false);
 parameter Real z(start = 1,fixed = false);
initial equation 
 x = 3.14;
 z = y;
 y = x;
end NonFixedParameterPropagation.Simple2;
")})));
    end Simple2;
    
    model Simple3
        parameter Real x(fixed=false, start=3.14);
        parameter Real y(fixed=false);
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
        y = x + 42;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple3",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple3
 parameter Real x(fixed = false,start = 3.14);
 parameter Real y(fixed = false);
 parameter Real z(start = 1,fixed = false);
initial equation 
 x = 3.14;
 y = x + 42;
 z = y;
end NonFixedParameterPropagation.Simple3;
")})));
    end Simple3;
    
    model Simple4
        parameter Real x(fixed=false, start=3.14);
        parameter Real y(fixed=false);
        parameter Real z(start=1) = y;
    initial equation
        x = 3.14;
        y = x;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple4",
            description="Test propagation of non-fixed parameter attribute",
            flatModel="
fclass NonFixedParameterPropagation.Simple4
 parameter Real x(fixed = false,start = 3.14);
 parameter Real y(fixed = false);
 parameter Real z(start = 1,fixed = false);
initial equation 
 x = 3.14;
 y = x;
 z = y;
end NonFixedParameterPropagation.Simple4;
")})));
    end Simple4;
    
    model Simple5
        parameter Real x(fixed=false);
        Real y;
    initial equation
        y = 23;
    equation
        y = x + time;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Simple5",
            description="Test matching of non-fixed parameter",
            flatModel="
fclass NonFixedParameterPropagation.Simple5
 parameter Real x(fixed = false);
 Real y;
initial equation 
 y = 23;
equation
 y = x + time;
end NonFixedParameterPropagation.Simple5;
")})));
    end Simple5;
    
    model FunctionCall1
        function F
            input Real i;
            output Real o[2];
        algorithm
            o[1] := i;
            o[2] := - i;
        annotation(Inline=false);
        end F;
        parameter Real p[2] = F(x);
        parameter Real x(fixed=false);
    initial equation
        x = time;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="FunctionCall1",
            description="Test propagation of non fixed parameters through function call equations",
            flatModel="
fclass NonFixedParameterPropagation.FunctionCall1
 parameter Real p[1](fixed = false);
 parameter Real p[2](fixed = false);
 parameter Real x(fixed = false);
 parameter Real temp_1[1](fixed = false);
 parameter Real temp_1[2](fixed = false);
initial equation 
 x = time;
 ({temp_1[1], temp_1[2]}) = NonFixedParameterPropagation.FunctionCall1.F(x);
 p[2] = temp_1[2];
 p[1] = temp_1[1];

public
 function NonFixedParameterPropagation.FunctionCall1.F
  input Real i;
  output Real[2] o;
 algorithm
  o[1] := i;
  o[2] := - i;
  return;
 annotation(Inline = false);
 end NonFixedParameterPropagation.FunctionCall1.F;

end NonFixedParameterPropagation.FunctionCall1;
")})));
    end FunctionCall1;

end NonFixedParameterPropagation;