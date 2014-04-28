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

package BlockFunctionExtractionTests

model ExtractFunctionCall
  Real a, b;
equation
  a + b = f(time);
  a * b = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExtractFunctionCall",
            description="",
            flatModel="
fclass BlockFunctionExtractionTests.ExtractFunctionCall
 Real a;
 Real b;
 Real temp_1;
equation
 a + b = temp_1;
 a * b = 2;
 temp_1 = BlockFunctionExtractionTests.f(time);

public
 function BlockFunctionExtractionTests.f
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1 + 1;
  return;
 end BlockFunctionExtractionTests.f;

end BlockFunctionExtractionTests.ExtractFunctionCall;
")})));
end ExtractFunctionCall;

model ExtractFunctionCall2
  Real a, b;
equation
  a + b = f(time+1) + f(1+time);
  a * b = 2;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="ExtractFunctionCall2",
            description="",
            flatModel="
fclass BlockFunctionExtractionTests.ExtractFunctionCall2
 Real a;
 Real b;
 Real temp_1;
 Real temp_2;
equation
 a + b = temp_1 + temp_2;
 a * b = 2;
 temp_1 = BlockFunctionExtractionTests.f(time + 1);
 temp_2 = BlockFunctionExtractionTests.f(1 + time);

public
 function BlockFunctionExtractionTests.f
  input Real i1;
  output Real o1;
 algorithm
  o1 := i1 + 1;
  return;
 end BlockFunctionExtractionTests.f;

end BlockFunctionExtractionTests.ExtractFunctionCall2;
")})));
end ExtractFunctionCall2;

function f
  input Real i1;
  output Real o1;
algorithm
  o1 := i1 + 1;
  
    annotation(Inline=false);
end f;

end BlockFunctionExtractionTests;
