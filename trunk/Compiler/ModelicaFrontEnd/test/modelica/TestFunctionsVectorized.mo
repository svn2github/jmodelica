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

package TestFunctionsVectorized

package DifferentDimensionedParamerers

    function v
        input Integer i;
        input Integer j[:];
        output Real o = i;
    algorithm
    end v;
    
model DifferingUnknownParameters1
    function f
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := v(d, ones(d, d));
        y := 1;
    end f;
    
    Real x = f(2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DifferingUnknownParameters1",
            description="Unknown size vectorization of function calls for scalar & matrix inputs.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters1
 Real x;
equation
 x = TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters1.f(2);

public
 function TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters1.f
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:,:] temp_2;
  Integer[:] temp_3;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d, d];
  for i1 in 1:d loop
   for i2 in 1:d loop
    temp_2[i1,i2] := 1;
   end for;
  end for;
  for i2 in 1:d loop
   init temp_3 as Integer[d];
   for i3 in 1:d loop
    temp_3[i3] := temp_2[i2,i3];
   end for;
   temp_1[i2] := TestFunctionsVectorized.DifferentDimensionedParamerers.v(d, temp_3);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters1.f;

 function TestFunctionsVectorized.DifferentDimensionedParamerers.v
  input Integer i;
  input Integer[:] j;
  output Real o;
 algorithm
  o := i;
  return;
 end TestFunctionsVectorized.DifferentDimensionedParamerers.v;

end TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters1;
")})));
end DifferingUnknownParameters1;

model DifferingUnknownParameters2
    function f
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := v(ones(d), ones(d, d));
        y := 1;
    end f;
    
    Real x = f(2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="DifferingUnknownParameters2",
            description="Unknown size vectorization of function calls for array & matrix inputs.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters2
 Real x;
equation
 x = TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters2.f(2);

public
 function TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters2.f
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:] temp_2;
  Integer[:,:] temp_3;
  Integer[:] temp_4;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d];
  for i1 in 1:d loop
   temp_2[i1] := 1;
  end for;
  init temp_3 as Integer[d, d];
  for i1 in 1:d loop
   for i2 in 1:d loop
    temp_3[i1,i2] := 1;
   end for;
  end for;
  for i2 in 1:d loop
   init temp_4 as Integer[d];
   for i3 in 1:d loop
    temp_4[i3] := temp_3[i2,i3];
   end for;
   temp_1[i2] := TestFunctionsVectorized.DifferentDimensionedParamerers.v(temp_2[i2], temp_4);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters2.f;

 function TestFunctionsVectorized.DifferentDimensionedParamerers.v
  input Integer i;
  input Integer[:] j;
  output Real o;
 algorithm
  o := i;
  return;
 end TestFunctionsVectorized.DifferentDimensionedParamerers.v;

end TestFunctionsVectorized.DifferentDimensionedParamerers.DifferingUnknownParameters2;
")})));
end DifferingUnknownParameters2;
end DifferentDimensionedParamerers;

package Nested
    function f
        input Real i[:];
        Real a[1];
        output Real[size(i, 1)] y;
    algorithm
        a[1] := i[1];
        y := ones(size(i, 1));
    end f;

    function g
        input Real i;
        Real a;
        output Real o;
    algorithm
        a := i;
        o := 1;
    end g;

model NestedVectorizedCalls1
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := f(g(ones(d)));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls1",
            description="Unknown size vectorization of function call as parameter to regular function call.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass TestFunctionsVectorized.Nested.NestedVectorizedCalls1
 Real x;
equation
 x = TestFunctionsVectorized.Nested.NestedVectorizedCalls1.z(2);

public
 function TestFunctionsVectorized.Nested.NestedVectorizedCalls1.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Integer[:] temp_2;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Integer[d];
  for i1 in 1:d loop
   temp_2[i1] := 1;
  end for;
  for i1 in 1:d loop
   temp_1[i1] := TestFunctionsVectorized.Nested.g(temp_2[i1]);
  end for;
  (a) := TestFunctionsVectorized.Nested.f(temp_1);
  y := 1;
  return;
 end TestFunctionsVectorized.Nested.NestedVectorizedCalls1.z;

 function TestFunctionsVectorized.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end TestFunctionsVectorized.Nested.f;

 function TestFunctionsVectorized.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end TestFunctionsVectorized.Nested.g;

end TestFunctionsVectorized.Nested.NestedVectorizedCalls1;
")})));
end NestedVectorizedCalls1;

model NestedVectorizedCalls2
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := g(f(ones(d)));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls2",
            description="Unknown size vectorization of function call with regular call as input.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass TestFunctionsVectorized.Nested.NestedVectorizedCalls2
 Real x;
equation
 x = TestFunctionsVectorized.Nested.NestedVectorizedCalls2.z(2);

public
 function TestFunctionsVectorized.Nested.NestedVectorizedCalls2.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Real[:] temp_2;
  Integer[:] temp_3;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Real[d];
  init temp_3 as Integer[d];
  for i1 in 1:d loop
   temp_3[i1] := 1;
  end for;
  (temp_2) := TestFunctionsVectorized.Nested.f(temp_3);
  for i2 in 1:d loop
   temp_1[i2] := TestFunctionsVectorized.Nested.g(temp_2[i2]);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end TestFunctionsVectorized.Nested.NestedVectorizedCalls2.z;

 function TestFunctionsVectorized.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end TestFunctionsVectorized.Nested.g;

 function TestFunctionsVectorized.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end TestFunctionsVectorized.Nested.f;

end TestFunctionsVectorized.Nested.NestedVectorizedCalls2;
")})));
end NestedVectorizedCalls2;

model NestedVectorizedCalls3
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := f(g(f(ones(d))));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls3",
            description="Unknown size vectorization of function call as intermediate to two function calls.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass TestFunctionsVectorized.Nested.NestedVectorizedCalls3
 Real x;
equation
 x = TestFunctionsVectorized.Nested.NestedVectorizedCalls3.z(2);

public
 function TestFunctionsVectorized.Nested.NestedVectorizedCalls3.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Real[:] temp_2;
  Integer[:] temp_3;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Real[d];
  init temp_3 as Integer[d];
  for i1 in 1:d loop
   temp_3[i1] := 1;
  end for;
  (temp_2) := TestFunctionsVectorized.Nested.f(temp_3);
  for i1 in 1:d loop
   temp_1[i1] := TestFunctionsVectorized.Nested.g(temp_2[i1]);
  end for;
  (a) := TestFunctionsVectorized.Nested.f(temp_1);
  y := 1;
  return;
 end TestFunctionsVectorized.Nested.NestedVectorizedCalls3.z;

 function TestFunctionsVectorized.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end TestFunctionsVectorized.Nested.f;

 function TestFunctionsVectorized.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end TestFunctionsVectorized.Nested.g;

end TestFunctionsVectorized.Nested.NestedVectorizedCalls3;
")})));
end NestedVectorizedCalls3;

model NestedVectorizedCalls4
    function z
        input Integer d;
        Real a[d];
        output Real y;
    algorithm
        a := g(f(g(ones(d))));
        y := 1;
    end z;
    
    Real x = z(2);
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="NestedVectorizedCalls4",
            description="Unknown size vectorization of function call with regular call as intermediate.",
            variability_propagation=false,
            inline_functions="none",
            flatModel="
fclass TestFunctionsVectorized.Nested.NestedVectorizedCalls4
 Real x;
equation
 x = TestFunctionsVectorized.Nested.NestedVectorizedCalls4.z(2);

public
 function TestFunctionsVectorized.Nested.NestedVectorizedCalls4.z
  input Integer d;
  Real[:] a;
  output Real y;
  Real[:] temp_1;
  Real[:] temp_2;
  Real[:] temp_3;
  Integer[:] temp_4;
 algorithm
  init a as Real[d];
  init temp_1 as Real[d];
  init temp_2 as Real[d];
  init temp_3 as Real[d];
  init temp_4 as Integer[d];
  for i1 in 1:d loop
   temp_4[i1] := 1;
  end for;
  for i1 in 1:d loop
   temp_3[i1] := TestFunctionsVectorized.Nested.g(temp_4[i1]);
  end for;
  (temp_2) := TestFunctionsVectorized.Nested.f(temp_3);
  for i2 in 1:d loop
   temp_1[i2] := TestFunctionsVectorized.Nested.g(temp_2[i2]);
  end for;
  for i1 in 1:d loop
   a[i1] := temp_1[i1];
  end for;
  y := 1;
  return;
 end TestFunctionsVectorized.Nested.NestedVectorizedCalls4.z;

 function TestFunctionsVectorized.Nested.g
  input Real i;
  Real a;
  output Real o;
 algorithm
  a := i;
  o := 1;
  return;
 end TestFunctionsVectorized.Nested.g;

 function TestFunctionsVectorized.Nested.f
  input Real[:] i;
  Real[:] a;
  output Real[:] y;
 algorithm
  init a as Real[1];
  init y as Real[size(i, 1)];
  a[1] := i[1];
  for i1 in 1:size(i, 1) loop
   y[i1] := 1;
  end for;
  return;
 end TestFunctionsVectorized.Nested.f;

end TestFunctionsVectorized.Nested.NestedVectorizedCalls4;
")})));
end NestedVectorizedCalls4;

end Nested;

end TestFunctionsVectorized;