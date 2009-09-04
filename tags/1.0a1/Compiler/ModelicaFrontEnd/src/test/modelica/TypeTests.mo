/*
    Copyright (C) 2009 Modelon AB

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

package TypeTests

	model TypeTest1
	   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TypeTest1",
                                               description="Basic expression type test.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/TypeTests.mo':
Semantic error at line 11, column 11:
  The binding expression of the variable x does not match the declared type of the variable
")})));
	
		Integer x = true;
	
	end TypeTest1;

	model TypeTest2

	   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TypeTest2",
                                               description="Basic expression type test.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/TypeTests.mo':
Semantic error at line 35, column 4:
  The right and left expression types of equation are not compatible
")})));

	  Real x;
	equation
	  x=true;
	end TypeTest2;

	model TypeTest3
	   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TypeTest3",
                                               description="Basic expression type test.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/TypeTests.mo':
Semantic error at line 51, column 16:
  Type error in expression
")})));
	
	  Real x = 1;
	  Boolean y = true;
      Real z = x + y;
	end TypeTest3;

	model TypeTest4
	   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TypeTest4",
                                               description="Basic expression type test.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/TypeTests.mo':
Semantic error at line 66, column 4:
  Type error in expression
")})));
	
	  Real x = 1;
	  Boolean y = true;
	equation
	  x+y=3;  
	end TypeTest4;

	model TypeTest5
	   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TypeTest5",
                                               description="Basic expression type test.",
                                               errorMessage=
"
1 error(s) found...
In file 'src/test/modelica/TypeTests.mo':
Semantic error at line 66, column 4:
  Type error in expression
")})));
	
	  Real x = 1;
	  Boolean y = true;
	initial equation
	  x+y=3;  
	end TypeTest5;

end TypeTests;