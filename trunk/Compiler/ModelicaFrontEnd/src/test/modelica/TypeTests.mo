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

	model TypeTest6
	   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TypeTest6",
                                               description="Basic expression type test.",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 130, column 10:
  The type of the binding expression of the attribute start does not match the declared type of the variable
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 130, column 21:
  The type of the binding expression of the attribute unit does not match the declared type of the variable
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 130, column 28:
  The type of the binding expression of the attribute nominal does not match the declared type of the variable
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 130, column 40:
  The type of the binding expression of the attribute min does not match the declared type of the variable
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 130, column 49:
  The type of the binding expression of the attribute max does not match the declared type of the variable
")})));
	
	  Real x = 1;
	  Real y(start=true,unit=3,nominal="N",min=true,max="M");
	equation
	  x+y=3;  
	end TypeTest6;


model TypeRel1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="TypeRel1",
         description="Type checks of relational operators: Real/Real",
         flatModel="
fclass TypeTests.TypeRel1
 Boolean eq = 1.0 == 2.0;
 Boolean ne = 1.0 <> 2.0;
 Boolean gt = 1.0 > 2.0;
 Boolean ge = 1.0 >= 2.0;
 Boolean lt = 1.0 < 2.0;
 Boolean le = 1.0 <= 2.0;
end TypeTests.TypeRel1;
")})));

 Boolean eq = 1.0 == 2.0;
 Boolean ne = 1.0 <> 2.0;
 Boolean gt = 1.0 >  2.0;
 Boolean ge = 1.0 >= 2.0;
 Boolean lt = 1.0 <  2.0;
 Boolean le = 1.0 <= 2.0;
end TypeRel1;


model TypeRel2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="TypeRel2",
         description="Type checks of relational operators: Real/Integer",
         flatModel="
fclass TypeTests.TypeRel2
 Boolean eq = 1 == 2.0;
 Boolean ne = 1 <> 2.0;
 Boolean gt = 1 > 2.0;
 Boolean ge = 1 >= 2.0;
 Boolean lt = 1 < 2.0;
 Boolean le = 1 <= 2.0;
end TypeTests.TypeRel2;
")})));

 Boolean eq = 1 == 2.0;
 Boolean ne = 1 <> 2.0;
 Boolean gt = 1 >  2.0;
 Boolean ge = 1 >= 2.0;
 Boolean lt = 1 <  2.0;
 Boolean le = 1 <= 2.0;
end TypeRel2;


model TypeRel3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="TypeRel3",
         description="Type checks of relational operators: Boolean/Boolean",
         flatModel="
fclass TypeTests.TypeRel3
 Boolean eq = true == false;
 Boolean ne = true <> false;
 Boolean gt = true > false;
 Boolean ge = true >= false;
 Boolean lt = true < false;
 Boolean le = true <= false;
end TypeTests.TypeRel3;
")})));

 Boolean eq = true == false;
 Boolean ne = true <> false;
 Boolean gt = true >  false;
 Boolean ge = true >= false;
 Boolean lt = true <  false;
 Boolean le = true <= false;
end TypeRel3;


model TypeRel4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="TypeRel4",
         description="Type checks of relational operators: String/String",
         flatModel="
fclass TypeTests.TypeRel4
 Boolean eq = \"1.0\" == \"2.0\";
 Boolean ne = \"1.0\" <> \"2.0\";
 Boolean gt = \"1.0\" > \"2.0\";
 Boolean ge = \"1.0\" >= \"2.0\";
 Boolean lt = \"1.0\" < \"2.0\";
 Boolean le = \"1.0\" <= \"2.0\";
end TypeTests.TypeRel4;
")})));

 Boolean eq = "1.0" == "2.0";
 Boolean ne = "1.0" <> "2.0";
 Boolean gt = "1.0" >  "2.0";
 Boolean ge = "1.0" >= "2.0";
 Boolean lt = "1.0" <  "2.0";
 Boolean le = "1.0" <= "2.0";
end TypeRel4;


model TypeRel5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="TypeRel5",
         description="Type checks of relational operators: Real[1]/Real[1]",
         errorMessage="
6 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 222, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 223, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 224, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 225, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 226, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 227, column 15:
  Type error in expression
")})));

 Boolean eq = {1.0} == {2.0};
 Boolean ne = {1.0} <> {2.0};
 Boolean gt = {1.0} >  {2.0};
 Boolean ge = {1.0} >= {2.0};
 Boolean lt = {1.0} <  {2.0};
 Boolean le = {1.0} <= {2.0};
end TypeRel5;


model TypeRel6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="TypeRel6",
         description="Type checks of relational operators: Real/String",
         errorMessage="
6 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 258, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 259, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 260, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 261, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 262, column 15:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 263, column 15:
  Type error in expression
")})));

 Boolean eq = 1.0 == "2.0";
 Boolean ne = 1.0 <> "2.0";
 Boolean gt = 1.0 >  "2.0";
 Boolean ge = 1.0 >= "2.0";
 Boolean lt = 1.0 <  "2.0";
 Boolean le = 1.0 <= "2.0";
end TypeRel6;


end TypeTests;
