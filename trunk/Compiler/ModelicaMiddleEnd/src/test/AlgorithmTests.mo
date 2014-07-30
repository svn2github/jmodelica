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

end AlgorithmTests;
