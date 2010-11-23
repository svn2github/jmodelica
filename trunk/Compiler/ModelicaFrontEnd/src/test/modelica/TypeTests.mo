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
         description="Type checks of relational operators: Real/Real (Integer for ==/<>)",
         flatModel="
fclass TypeTests.TypeRel1
 Boolean eq = 1 == 2;
 Boolean ne = 1 <> 2;
 Boolean gt = 1.0 > 2.0;
 Boolean ge = 1.0 >= 2.0;
 Boolean lt = 1.0 < 2.0;
 Boolean le = 1.0 <= 2.0;
end TypeTests.TypeRel1;
")})));

 Boolean eq = 1   == 2;
 Boolean ne = 1   <> 2;
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
 Boolean gt = 1 > 2.0;
 Boolean ge = 1 >= 2.0;
 Boolean lt = 1 < 2.0;
 Boolean le = 1 <= 2.0;
end TypeTests.TypeRel2;
")})));

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



model AbsType1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AbsType1",
         description="abs() operator: Real arg & result",
         flatModel="
fclass TypeTests.AbsType1
 Real x = abs(y);
 Real y =  - ( 2.0 );
end TypeTests.AbsType1;
")})));

 Real x = abs(y);
 Real y = -2.0;
end AbsType1;


model AbsType2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AbsType2",
         description="abs() operator: Real constant",
         flatModel="
fclass TypeTests.AbsType2
 constant Real x1 = abs( - ( 2.0 ));
 constant Real x2 = abs(2.0);
 Real y1 = 2.0;
 Real y2 = 2.0;
end TypeTests.AbsType2;
")})));

 constant Real x1 = abs(-2.0);
 constant Real x2 = abs(2.0);
 Real y1 = x1;
 Real y2 = x2;
end AbsType2;


model AbsType3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AbsType3",
         description="abs() operator: Integer arg & result",
         flatModel="
fclass TypeTests.AbsType3
 Integer x = abs(y);
 Integer y =  - ( 2 );
end TypeTests.AbsType3;
")})));

 Integer x = abs(y);
 Integer y = -2;
end AbsType3;


model AbsType4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="AbsType4",
         description="abs() operator: Integer constant",
         flatModel="
fclass TypeTests.AbsType4
 constant Integer x1 = abs( - ( 2 ));
 constant Integer x2 = abs(2);
 Integer y1 = 2;
 Integer y2 = 2;
end TypeTests.AbsType4;
")})));

 constant Integer x1 = abs(-2);
 constant Integer x2 = abs(2);
 Integer y1 = x1;
 Integer y2 = x2;
end AbsType4;


model AbsType5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AbsType5",
         description="abs() operator: String arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 338, column 17:
  Calling function abs(): types of positional argument 1 and input v are not compatible
")})));

 String x = abs("-1");
end AbsType5;


model AbsType6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AbsType6",
         description="abs() operator: array arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 343, column 18:
  Calling function abs(): types of positional argument 1 and input v are not compatible
")})));

 Real x[2] = abs({1,-1});
end AbsType6;


model AbsType7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AbsType7",
         description="abs() operator: too many args",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 348, column 17:
  Calling function abs(): too many positional arguments
")})));

 Real x = abs(1,-1);
end AbsType7;


model AbsType8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="AbsType8",
         description="abs() operator: no args",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 364, column 11:
  Calling function abs(): missing argument for required input v
")})));

 Real x = abs();
end AbsType8;



model IntegerExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IntegerExp1",
         description="integer() operator: constant",
         flatModel="
fclass TypeTests.IntegerExp1
 constant Integer x = integer(1.8);
 Integer y;
equation
 y = 1;
end TypeTests.IntegerExp1;
")})));

 constant Integer x = integer(1.8);
 Integer y = x;
end IntegerExp1;


model IntegerExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="IntegerExp2",
         description="integer() operator: continous arg",
         flatModel="
fclass TypeTests.IntegerExp2
 Real x;
 Integer y;
equation
 x = 1.0;
 y = integer(x);
end TypeTests.IntegerExp2;
")})));

 Real x = 1.0;
 Integer y = integer(x);
end IntegerExp2;


model IntegerExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="IntegerExp3",
         description="integer() operator: array arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 490, column 19:
  Calling function integer(): types of positional argument 1 and input x are not compatible
")})));

 Real y = integer({1.0, 2.0});
end IntegerExp3;



model ConstCmpEq
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ConstCmpEq",
         description="Constant evaluation of comparisons: equals",
         flatModel="
fclass TypeTests.ConstCmpEq
 constant Boolean a = 1 == 2;
 constant Boolean b = 1 == 1;
 Boolean x;
 Boolean y;
equation
 x = false;
 y = true;
end TypeTests.ConstCmpEq;
")})));

 constant Boolean a = 1 == 2;
 constant Boolean b = 1 == 1;
 Boolean x = a;
 Boolean y = b;
end ConstCmpEq;


model ConstCmpNeq
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ConstCmpNeq",
         description="Constant evaluation of comparisons: not equal",
         flatModel="
fclass TypeTests.ConstCmpNeq
 constant Boolean a = 1 <> 2;
 constant Boolean b = 1 <> 1;
 Boolean x;
 Boolean y;
equation
 x = true;
 y = false;
end TypeTests.ConstCmpNeq;
")})));

 constant Boolean a = 1 <> 2;
 constant Boolean b = 1 <> 1;
 Boolean x = a;
 Boolean y = b;
end ConstCmpNeq;


model ConstCmpLeq
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ConstCmpLeq",
         description="Constant evaluation of comparisons: less or equal",
         flatModel="
fclass TypeTests.ConstCmpLeq
 constant Boolean a = 1 <= 2;
 constant Boolean b = 1 <= 1;
 constant Boolean c = 2 <= 1;
 Boolean x;
 Boolean y;
 Boolean z;
equation
 x = true;
 y = true;
 z = false;
end TypeTests.ConstCmpLeq;
")})));

 constant Boolean a = 1 <= 2;
 constant Boolean b = 1 <= 1;
 constant Boolean c = 2 <= 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;
end ConstCmpLeq;


model ConstCmpLt
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ConstCmpLt",
         description="Constant evaluation of comparisons: less than",
         flatModel="
fclass TypeTests.ConstCmpLt
 constant Boolean a = 1 < 2;
 constant Boolean b = 1 < 1;
 constant Boolean c = 2 < 1;
 Boolean x;
 Boolean y;
 Boolean z;
equation
 x = true;
 y = false;
 z = false;
end TypeTests.ConstCmpLt;
")})));

 constant Boolean a = 1 < 2;
 constant Boolean b = 1 < 1;
 constant Boolean c = 2 < 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;
end ConstCmpLt;


model ConstCmpGeq
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ConstCmpGeq",
         description="Constant evaluation of comparisons: greater or equal",
         flatModel="
fclass TypeTests.ConstCmpGeq
 constant Boolean a = 1 >= 2;
 constant Boolean b = 1 >= 1;
 constant Boolean c = 2 >= 1;
 Boolean x;
 Boolean y;
 Boolean z;
equation
 x = false;
 y = true;
 z = true;
end TypeTests.ConstCmpGeq;
")})));

 constant Boolean a = 1 >= 2;
 constant Boolean b = 1 >= 1;
 constant Boolean c = 2 >= 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;
end ConstCmpGeq;


model ConstCmpGt
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ConstCmpGt",
         description="Constant evaluation of comparisons:greater than",
         flatModel="
fclass TypeTests.ConstCmpGt
 constant Boolean a = 1 > 2;
 constant Boolean b = 1 > 1;
 constant Boolean c = 2 > 1;
 Boolean x;
 Boolean y;
 Boolean z;
equation
 x = false;
 y = false;
 z = true;
end TypeTests.ConstCmpGt;
")})));

 constant Boolean a = 1 > 2;
 constant Boolean b = 1 > 1;
 constant Boolean c = 2 > 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;
end ConstCmpGt;



model RealEq1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RealEq1",
         description="Equality comparisons for reals: == outside function",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 672, column 14:
  Type error in expression
")})));

 Boolean a = 1.0 == 2;
end RealEq1;


model RealEq2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RealEq2",
         description="Equality comparisons for reals: <> outside function",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 688, column 14:
  Type error in expression
")})));

 Boolean a = 1.0 <> 2;
end RealEq2;


model RealEq3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RealEq3",
         description="Equality comparisons for reals: == in function",
         flatModel="
fclass TypeTests.RealEq3
 Boolean b = TypeTests.RealEq3.f();

 function TypeTests.RealEq3.f
  output Boolean a := 1.0 == 2;
 algorithm
  return;
 end TypeTests.RealEq3.f;
end TypeTests.RealEq3;
")})));

 function f
  output Boolean a = 1.0 == 2;
 algorithm
 end f;
 
 Boolean b = f();
end RealEq3;


model RealEq4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RealEq4",
         description="Equality comparisons for reals: <> in function",
         flatModel="
fclass TypeTests.RealEq4
 Boolean b = TypeTests.RealEq4.f();

 function TypeTests.RealEq4.f
  output Boolean a := 1.0 <> 2;
 algorithm
  return;
 end TypeTests.RealEq4.f;
end TypeTests.RealEq4;
")})));

 function f
  output Boolean a = 1.0 <> 2;
 algorithm
 end f;
 
 Boolean b = f();
end RealEq4;



model ParameterStart1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ParameterStart1",
         description="Constant without binding expression: start set",
         flatModel="
fclass TypeTests.ParameterStart1
 constant Real p(start = 2);
 Real y;
equation
 y = 2.0;
end TypeTests.ParameterStart1;
")})));

  constant Real p(start=2);
  Real y = p;
end ParameterStart1;


model ParameterStart2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ParameterStart2",
         description="Constant without binding expression: start not set",
         flatModel="
fclass TypeTests.ParameterStart2
 constant Real p;
 Real y;
equation
 y = 0.0;
end TypeTests.ParameterStart2;
")})));

  constant Real p;
  Real y = p;
end ParameterStart2;

model ArrayTypeTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayTypeTest1",
         description="Check that short type declarations with array indices are expanded correctly.",
         flatModel="fclass TypeTests.ArrayTypeTest1
 Real x[1](unit = \"m\");
 Real x[2](unit = \"m\");
 Real x[3](unit = \"m\");
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 4;
end TypeTests.ArrayTypeTest1;
")})));


  type T = Real[3](unit="m");
  T x = {1,2,4};
end ArrayTypeTest1;

model ArrayTypeTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayTypeTest2",
         description="Check that short type declarations with array indices are expanded correctly.",
         flatModel="fclass TypeTests.ArrayTypeTest2
 Real x[1](unit = \"l\");
 Real x[2](unit = \"l\");
 Real x[3](unit = \"l\");
 Real y[1,1](start = 3,unit = \"m\");
 Real y[1,2](start = 3,unit = \"m\");
 Real y[1,3](start = 3,unit = \"m\");
 Real y[2,1](start = 3,unit = \"m\");
 Real y[2,2](start = 3,unit = \"m\");
 Real y[2,3](start = 3,unit = \"m\");
 Real y[3,1](start = 3,unit = \"m\");
 Real y[3,2](start = 3,unit = \"m\");
 Real y[3,3](start = 3,unit = \"m\");
 Real y[4,1](start = 3,unit = \"m\");
 Real y[4,2](start = 3,unit = \"m\");
 Real y[4,3](start = 3,unit = \"m\");
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 4;
 y[1,1] = 0;
 y[1,2] = 0;
 y[1,3] = 0;
 y[2,1] = 0;
 y[2,2] = 0;
 y[2,3] = 0;
 y[3,1] = 0;
 y[3,2] = 0;
 y[3,3] = 0;
 y[4,1] = 0;
 y[4,2] = 0;
 y[4,3] = 0;
end TypeTests.ArrayTypeTest2;
")})));

  type S = T[4](start=3,unit="m");
  type T = Real[3](unit="l");
  T x = {1,2,4};
  S y = zeros(4,3);
end ArrayTypeTest2;

model ArrayTypeTest3

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayTypeTest3",
         description="Check that short type declarations with array indices are expanded correctly.",
         flatModel="fclass TypeTests.ArrayTypeTest3
 Real y[1].x(start = 1);
 Real y[2].x(start = 1);
 Real y[3].x(start = 1);
 Real z[1].x;
 Real z[2].x;
 Real z[3].x;
 Real w.x;
equation
 y[1].x = 1;
 y[2].x = 1;
 y[3].x = 1;
 z[1].x = 1;
 z[2].x = 1;
 z[3].x = 1;
 w.x = 1;
end TypeTests.ArrayTypeTest3;
")})));

 model A
  Real x = 1;
 end A;

 model B = A(x(start=1));

 model C
 extends A;
 end C; 

  B y[3];
  C z[3];
  C w;
end ArrayTypeTest3;

model ArrayTypeTest4

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayTypeTest4",
         description="Check that short type declarations with array indices are expanded correctly.",
         flatModel="fclass TypeTests.ArrayTypeTest4
 Real y[1,1].x(start = 1);
 Real y[1,2].x(start = 1);
 Real y[2,1].x(start = 1);
 Real y[2,2].x(start = 1);
 Real y[3,1].x(start = 1);
 Real y[3,2].x(start = 1);
 Real z[1].x;
 Real z[2].x;
 Real z[3].x;
 Real w.x;
equation
 y[1,1].x = 1;
 y[1,2].x = 1;
 y[2,1].x = 1;
 y[2,2].x = 1;
 y[3,1].x = 1;
 y[3,2].x = 1;
 z[1].x = 1;
 z[2].x = 1;
 z[3].x = 1;
 w.x = 1;
end TypeTests.ArrayTypeTest4;
")})));

 model A
  Real x = 1;

 end A;

 model B = A[2](x(start=1));

 model C
 extends A;
 end C; 

  B y[3];
  C z[3];
  C w;
end ArrayTypeTest4;

model ArrayTypeTest5

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="ArrayTypeTest5",
         description="Check that short type declarations with array indices are expanded correctly.",
         flatModel="fclass TypeTests.ArrayTypeTest5
 Real y[1,1].x(start = 1);
 Real y[1,2].x(start = 1);
 Real y[2,1].x(start = 1);
 Real y[2,2].x(start = 1);
 Real y[3,1].x(start = 1);
 Real y[3,2].x(start = 1);
 Real z[1].x;
 Real z[2].x;
 Real z[3].x;
 Real w.x;
equation
 y[1,1].x = 3;
 y[1,2].x = 3;
 y[2,1].x = 3;
 y[2,2].x = 3;
 y[3,1].x = 3;
 y[3,2].x = 3;
 z[1].x = 3;
 z[2].x = 3;
 z[3].x = 3;
 w.x = 3;
end TypeTests.ArrayTypeTest5;
")})));

 model A
  Real x;
  equation
   x = 3;
 end A;

 model B = A[2](x(start=1));

 model C
 extends A;
 end C; 

  B y[3];
  C z[3];
  C w;
end ArrayTypeTest5;



model UnknownTypeAccess1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="UnknownTypeAccess1",
         description="Using component of model type as expression",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1010, column 8:
  Accesses to composite components other than records are not allowed: c
")})));

 model C
  Real x=1;
 end C;
 C c;
equation
 c.x = c;
end UnknownTypeAccess1;



model RecursiveStructure1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecursiveStructure1",
         description="Detect recursive class structures",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1017, column 5:
  Recursive class structure
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1021, column 5:
  Recursive class structure
")})));

	model A
		B b;
	end A;
	
	model B
		A a1;
	end B;
	
	A a2;
end RecursiveStructure1;


model RecursiveStructure2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecursiveStructure2",
         description="Detect recursive class structures",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1058, column 3:
  Recursive class structure
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1062, column 3:
  Recursive class structure
")})));

	model A
		extends B;
	end A;
	
	model B
		extends A;
	end B;
	
	A a;
end RecursiveStructure2;


model RecursiveStructure3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecursiveStructure3",
         description="Detect recursive class structures",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1071, column 3:
  Recursive class structure
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1075, column 5:
  Recursive class structure
")})));

	model A
		extends B;
	end A;
	
	model B
		A a1;
	end B;
	
	A a2;
end RecursiveStructure3;



model WhenType1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenType1",
         description="Using test expression of wrong type",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1100, column 2:
  Test expression of when equation isn't Boolean scalar or vector expression
")})));

	Real x = 1;
equation
	when 1 then
		x = 2;
	end when;
end WhenType1;


model WhenType2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenType2",
         description="Using test expression with too many dimensions",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1120, column 2:
  Test expression of when equation isn't Boolean scalar or vector expression
")})));

	Real x = 1;
equation
	when fill(false, 1, 1) then
		x = 2;
	end when;
end WhenType2;



end TypeTests;
