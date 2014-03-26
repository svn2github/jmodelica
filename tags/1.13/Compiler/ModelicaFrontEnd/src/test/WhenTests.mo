/*
    Copyright (C) 2013 Modelon AB

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
package WhenTests
	
model ReinitErr1
	Real x;
equation
	der(x) = 1;
	reinit(x, 1);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr1",
			description="reinit() outside when",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 24, column 2:
  The reinit() operator is only allowed in when equations
")})));
end ReinitErr1;


model ReinitErr2
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x+1, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr2",
			description="reinit() with non access as var",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 44, column 9:
  First argument to reinit() must be an access to a Real variable
")})));
end ReinitErr2;


model ReinitErr3
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, true);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr3",
			description="reinit() Boolean expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 65, column 9:
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr3;


model ReinitErr4
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, "1");
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr4",
			description="reinit() String expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 86, column 9:
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr4;


model ReinitErr5
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;
    when time > 3 then
        reinit(x, 2);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr5",
			description="several reinit() of same var",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 0, column 0:
  The variable x is assigned in reinit() clauses in more than one when clause:
    reinit(x, 1);
    reinit(x, 2);

")})));
end ReinitErr5;


model ReinitErr6
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr6",
			description="reinit() with wrong size expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 120, column 9:
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr6;


model ReinitErr7
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1:2);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr7",
			description="reinit() with wrong size expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 141, column 9:
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr7;


model ReinitErr8
    Integer x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr8",
			description="reinit() with Integer variable",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 162, column 9:
  First argument to reinit() must be an access to a Real variable
")})));
end ReinitErr8;


model ReinitErr9
    discrete Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr9",
			description="reinit() with discrete Real variable",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 183, column 9:
  Built-in operator reinit() must have a continuous variable access as its first argument
")})));
end ReinitErr9;


model ReinitErr10
    Real x;
equation
    when time > 2 then
        reinit(x, 1);
    end when;
    when time > 1 then
        x = 2;
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr10",
			description="reinit() with (implicitly) discrete Real variable",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 203, column 9:
  Built-in operator reinit() must have a continuous variable access as its first argument
")})));
end ReinitErr10;


model ReinitErr11
    Real x;
equation
    der(x) = 1;
algorithm
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr11",
			description="reinit() in when statement",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 206, column 9:
  The reinit() operator is only allowed in when equations
")})));
end ReinitErr11;


model ReinitErr12
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, ones(2));
    end when;
    when time > 4 then
        reinit(x[2], 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr12",
			description="several reinit() of same cell of array",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 0, column 0:
  The variable x[2] is assigned in reinit() clauses in more than one when clause:
    reinit(x[2], 1);
    reinit(x[2], 1);

")})));
end ReinitErr12;


model ReinitErr13
    Real x;
    Real y;
equation
    der(x) = 1;
    when time > 2 then
        y = reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr13",
			description="using reinit() as RHS of equation",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 278, column 9:
  The right and left expression types of equation are not compatible
")})));
end ReinitErr13;


model ReinitErr14
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, zeros(3));
    end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ReinitErr14",
			description="reinit() with wrong size expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/WhenTests.mo':
Semantic error at line 299, column 9:
  Arguments to reinit() must be of compatible types
")})));
end ReinitErr14;


model ReinitTest1
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ReinitTest1",
			description="Basic test of a when clause with reinit()",
			flatModel="
fclass WhenTests.ReinitTest1
 Real x;
 discrete Boolean temp_1;
initial equation 
 x = 0.0;
 pre(temp_1) = false;
equation
 der(x) = 1;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  reinit(x, 1);
 end if;
end WhenTests.ReinitTest1;
			
")})));
end ReinitTest1;


model ReinitTest2
    Real x[2];
equation
    der(x) = ones(2);
    when time > 2 then
        reinit(x, ones(2));
    end when;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ReinitTest2",
			description="reinit() with array args",
			flatModel="
fclass WhenTests.ReinitTest2
 Real x[1];
 Real x[2];
 discrete Boolean temp_1;
initial equation 
 x[1] = 0.0;
 x[2] = 0.0;
 pre(temp_1) = false;
equation
 der(x[1]) = 1;
 der(x[2]) = 1;
 temp_1 = time > 2;
 if temp_1 and not pre(temp_1) then
  reinit(x[1], 1);
  reinit(x[2], 1);
 end if;
end WhenTests.ReinitTest2;
")})));
end ReinitTest2;


end WhenTests;
