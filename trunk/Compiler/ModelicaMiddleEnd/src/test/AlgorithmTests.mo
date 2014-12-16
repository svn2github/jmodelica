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

within ;
package AlgorithmTests

package For
model Break1
    Real x;
    algorithm
        x := 1;
        for i in 1:2 loop
            x := x + 1;
            break;
            x := x + i;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_Break1",
            description="Break in for",
            flatModel="
fclass AlgorithmTests.For.Break1
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
algorithm
 x := 1;
 temp_1 := true;
 if temp_1 then
  x := x + 1;
  temp_1 := false;
  if temp_1 then
   x := x + 1;
  end if;
 end if;
 if temp_1 then
  x := x + 1;
  temp_1 := false;
  if temp_1 then
   x := x + 2;
  end if;
 end if;
end AlgorithmTests.For.Break1;
")})));
end Break1;

model Break2
    Real x;
    algorithm
        x := 1;
        for i in 1:2 loop
            x := x + 1;
            if noEvent(x > 2) then
                break;
            else
                x := x + 1;
            end if;
            x := x + i;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_Break2",
            description="Break in for",
            flatModel="
fclass AlgorithmTests.For.Break2
 Real x;
 discrete Boolean temp_1;
initial equation 
 pre(temp_1) = false;
algorithm
 x := 1;
 temp_1 := true;
 if temp_1 then
  x := x + 1;
  if noEvent(x > 2) then
   temp_1 := false;
  end if;
  if temp_1 then
   x := x + 1;
  end if;
 end if;
 if temp_1 then
  x := x + 1;
  if noEvent(x > 2) then
   temp_1 := false;
  end if;
  if temp_1 then
   x := x + 2;
  end if;
 end if;
end AlgorithmTests.For.Break2;
")})));
end Break2;
/*
// Enable this after #3631 is done
model Break3
    Real x;
    algorithm
        x := 1;
        for j in 1:1 loop
            for i in 1:2 loop
                if noEvent(x > 1) then
                    x := 2;
                elseif noEvent(x > 2) then
                    x := 3;
                else
                    if noEvent(x > 3) then
                        break;
                    end if;
                    x := 4;
                end if;
            end for;
            break;
        end for;
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="For_Break3",
            description="Break in for",
            flatModel="
fclass AlgorithmTests.For.Break3
 Real x;
 discrete Boolean temp_1;
 discrete Boolean temp_2;
algorithm
 x := 1;
 temp_1 := true;
 if temp_1 then
  temp_2 := true;
  if temp_2 then
   if noEvent(x > 1) then
    x := 2;
   elseif noEvent(x > 2) then
    x := 3;
   else
    if noEvent(x > 3) then
     temp_2 := false;
    end if;
    if temp_2 then
     x := 4;
    end if;
   end if;
  end if;
  if temp_2 then
   if noEvent(x > 1) then
    x := 2;
   elseif noEvent(x > 2) then
    x := 3;
   else
    if noEvent(x > 3) then
     temp_2 := false;
    end if;
    if temp_2 then
     x := 4;
    end if;
   end if;
  end if;
  temp_1 := false;
 end if;
end AlgorithmTests.For.Break3;
")})));
end Break3;
*/
end For;

model TempAssign1
  function f
      input Real[:,:] x;
      output Real[size(x,2),size(x,1)] y = transpose(x);
    algorithm
      y := transpose(y);
  end f;
  
    Real[2,2] x = {{1,2},{3,4}} .* time;
    Real[2,2] y1,y2;
  equation
    y1 = f(x);
  algorithm
    y2 := x;
    y2 := transpose(y2);
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign1",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real y1[1,1];
 Real y1[1,2];
 Real y1[2,1];
 Real y1[2,2];
 Real y2[1,1];
 Real y2[1,2];
 Real y2[2,1];
 Real y2[2,2];
 Real temp_2[1,1];
 Real temp_2[1,2];
 Real temp_2[2,1];
 Real temp_2[2,2];
equation
 ({{y1[1,1], y1[1,2]}, {y1[2,1], y1[2,2]}}) = AlgorithmTests.TempAssign1.f({{x[1,1], x[1,2]}, {x[2,1], x[2,2]}});
algorithm
 y2[1,1] := x[1,1];
 y2[1,2] := x[1,2];
 y2[2,1] := x[2,1];
 y2[2,2] := x[2,2];
 temp_2[1,1] := y2[1,1];
 temp_2[1,2] := y2[2,1];
 temp_2[2,1] := y2[1,2];
 temp_2[2,2] := y2[2,2];
 y2[1,1] := temp_2[1,1];
 y2[1,2] := temp_2[1,2];
 y2[2,1] := temp_2[2,1];
 y2[2,2] := temp_2[2,2];
equation
 x[1,1] = time;
 x[1,2] = 2 .* time;
 x[2,1] = 3 .* time;
 x[2,2] = 4 .* time;

public
 function AlgorithmTests.TempAssign1.f
  input Real[:, :] x;
  output Real[:,:] y;
  Real[:,:] temp_1;
 algorithm
  size(y) := {size(x, 2), size(x, 1)};
  for i1 in 1:size(x, 2) loop
   for i2 in 1:size(x, 1) loop
    y[i1,i2] := x[i2,i1];
   end for;
  end for;
  size(temp_1) := {size(x, 2), size(x, 1)};
  for i1 in 1:size(x, 1) loop
   for i2 in 1:size(x, 2) loop
    temp_1[i1,i2] := y[i2,i1];
   end for;
  end for;
  for i1 in 1:size(x, 2) loop
   for i2 in 1:size(x, 1) loop
    y[i1,i2] := temp_1[i1,i2];
   end for;
  end for;
  return;
 end AlgorithmTests.TempAssign1.f;

end AlgorithmTests.TempAssign1;
")})));
end TempAssign1;

model TempAssign2
  function f
      input R[:] x;
      output R[size(x,1)] y = x;
      Integer t = size(x,1);
    algorithm
      y[1:t] := y[{t+1-i for i in 1:t}];
  end f;
  
    record R
        Real a,b;
    end R;
    
    R[2] x = {R(time,time),R(time,time)};
    R[2] y1,y2;
  equation
    y1 = f(x);
  algorithm
    y2 := x;
    y2 := y2[{2+1-i for i in 1:2}];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign2",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign2
 Real x[1].a;
 Real x[1].b;
 Real x[2].a;
 Real x[2].b;
 Real y1[1].a;
 Real y1[1].b;
 Real y1[2].a;
 Real y1[2].b;
 Real y2[1].a;
 Real y2[1].b;
 Real y2[2].a;
 Real y2[2].b;
 Real temp_2[1].a;
 Real temp_2[1].b;
 Real temp_2[2].a;
 Real temp_2[2].b;
equation
 ({AlgorithmTests.TempAssign2.R(y1[1].a, y1[1].b), AlgorithmTests.TempAssign2.R(y1[2].a, y1[2].b)}) = AlgorithmTests.TempAssign2.f({AlgorithmTests.TempAssign2.R(x[1].a, x[1].b), AlgorithmTests.TempAssign2.R(x[2].a, x[2].b)});
algorithm
 y2[1].a := x[1].a;
 y2[1].b := x[1].b;
 y2[2].a := x[2].a;
 y2[2].b := x[2].b;
 temp_2[1].a := y2[2].a;
 temp_2[1].b := y2[2].b;
 temp_2[2].a := y2[1].a;
 temp_2[2].b := y2[1].b;
 y2[1].a := temp_2[1].a;
 y2[1].b := temp_2[1].b;
 y2[2].a := temp_2[2].a;
 y2[2].b := temp_2[2].b;
equation
 x[1].a = time;
 x[1].b = time;
 x[2].a = time;
 x[2].b = time;

public
 function AlgorithmTests.TempAssign2.f
  input AlgorithmTests.TempAssign2.R[:] x;
  output AlgorithmTests.TempAssign2.R[:] y;
  Integer t;
  AlgorithmTests.TempAssign2.R[:] temp_1;
  Integer[:] temp_2;
 algorithm
  size(y) := {:};
  for i1 in 1:size(x, 1) loop
   y[i1].a := x[i1].a;
   y[i1].b := x[i1].b;
  end for;
  t := size(x, 1);
  size(temp_1) := {t};
  size(temp_2) := {t};
  for i2 in 1:t loop
   temp_2[i2] := t + 1 - i2;
  end for;
  for i1 in 1:t loop
   temp_1[i1].a := y[temp_2[i1]].a;
   temp_1[i1].b := y[temp_2[i1]].b;
  end for;
  for i1 in 1:t loop
   y[i1].a := temp_1[i1].a;
   y[i1].b := temp_1[i1].b;
  end for;
  return;
 end AlgorithmTests.TempAssign2.f;

 record AlgorithmTests.TempAssign2.R
  Real a;
  Real b;
 end AlgorithmTests.TempAssign2.R;

end AlgorithmTests.TempAssign2;
")})));
end TempAssign2;

model TempAssign3
  
  function f
      input R[:] x;
      output R[size(x,1)] y = x;
      Integer t = size(x,1);
    algorithm
      y[1:t] := y[{t+1-i for i in 1:t}];
  end f;
  
    record R
        Real a[2];
    end R;
    
    R[2] x = {R({time,time}),R({time,time})};
    R[2] y1,y2;
  equation
    y1 = f(x);
  algorithm
    y2 := x;
    y2 := y2[{2+1-i for i in 1:2}];
    
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TempAssign3",
            description="Scalarizing assignment temp generation",
            flatModel="
fclass AlgorithmTests.TempAssign3
 Real x[1].a[1];
 Real x[1].a[2];
 Real x[2].a[1];
 Real x[2].a[2];
 Real y1[1].a[1];
 Real y1[1].a[2];
 Real y1[2].a[1];
 Real y1[2].a[2];
 Real y2[1].a[1];
 Real y2[1].a[2];
 Real y2[2].a[1];
 Real y2[2].a[2];
 Real temp_2[1].a[1];
 Real temp_2[1].a[2];
 Real temp_2[2].a[1];
 Real temp_2[2].a[2];
equation
 ({AlgorithmTests.TempAssign3.R({y1[1].a[1], y1[1].a[2]}), AlgorithmTests.TempAssign3.R({y1[2].a[1], y1[2].a[2]})}) = AlgorithmTests.TempAssign3.f({AlgorithmTests.TempAssign3.R({x[1].a[1], x[1].a[2]}), AlgorithmTests.TempAssign3.R({x[2].a[1], x[2].a[2]})});
algorithm
 y2[1].a[1] := x[1].a[1];
 y2[1].a[2] := x[1].a[2];
 y2[2].a[1] := x[2].a[1];
 y2[2].a[2] := x[2].a[2];
 temp_2[1].a[1] := y2[2].a[1];
 temp_2[1].a[2] := y2[2].a[2];
 temp_2[2].a[1] := y2[1].a[1];
 temp_2[2].a[2] := y2[1].a[2];
 y2[1].a[1] := temp_2[1].a[1];
 y2[1].a[2] := temp_2[1].a[2];
 y2[2].a[1] := temp_2[2].a[1];
 y2[2].a[2] := temp_2[2].a[2];
equation
 x[1].a[1] = time;
 x[1].a[2] = time;
 x[2].a[1] = time;
 x[2].a[2] = time;

public
 function AlgorithmTests.TempAssign3.f
  input AlgorithmTests.TempAssign3.R[:] x;
  output AlgorithmTests.TempAssign3.R[:] y;
  Integer t;
  AlgorithmTests.TempAssign3.R[:] temp_1;
  Integer[:] temp_2;
 algorithm
  size(y) := {:};
  for i1 in 1:size(x, 1) loop
   y[i1].a[1] := x[i1].a[1];
   y[i1].a[2] := x[i1].a[2];
  end for;
  t := size(x, 1);
  size(temp_1) := {t};
  size(temp_2) := {t};
  for i2 in 1:t loop
   temp_2[i2] := t + 1 - i2;
  end for;
  for i1 in 1:t loop
   temp_1[i1].a[1] := y[temp_2[i1]].a[1];
   temp_1[i1].a[2] := y[temp_2[i1]].a[2];
  end for;
  for i1 in 1:t loop
   y[i1].a[1] := temp_1[i1].a[1];
   y[i1].a[2] := temp_1[i1].a[2];
  end for;
  return;
 end AlgorithmTests.TempAssign3.f;

 record AlgorithmTests.TempAssign3.R
  Real a[2];
 end AlgorithmTests.TempAssign3.R;

end AlgorithmTests.TempAssign3;
")})));
end TempAssign3;

end AlgorithmTests;
