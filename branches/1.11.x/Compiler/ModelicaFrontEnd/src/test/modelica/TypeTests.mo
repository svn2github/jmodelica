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

package TypeTests

	model TypeTest1
		Integer x = true;
	

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeTest1",
			description="Basic expression type test.",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/TypeTests.mo':
Semantic error at line 11, column 11:
  The binding expression of the variable x does not match the declared type of the variable
")})));
	end TypeTest1;

	model TypeTest2

	  Real x;
	equation
	  x=true;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeTest2",
			description="Basic expression type test.",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/TypeTests.mo':
Semantic error at line 35, column 4:
  The right and left expression types of equation are not compatible
")})));
	end TypeTest2;

	model TypeTest3
	  Real x = 1;
	  Boolean y = true;
      Real z = x + y;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeTest3",
			description="Basic expression type test.",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/TypeTests.mo':
Semantic error at line 51, column 16:
  Type error in expression: x + y
")})));
	end TypeTest3;

	model TypeTest4
	  Real x = 1;
	  Boolean y = true;
	equation
	  x+y=3;  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeTest4",
			description="Basic expression type test.",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/TypeTests.mo':
Semantic error at line 66, column 4:
  Type error in expression: x + y
")})));
	end TypeTest4;

	model TypeTest5
	  Real x = 1;
	  Boolean y = true;
	initial equation
	  x+y=3;  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeTest5",
			description="Basic expression type test.",
			errorMessage="
1 errors found:
Error: in file 'src/test/modelica/TypeTests.mo':
Semantic error at line 66, column 4:
  Type error in expression: x + y
")})));
	end TypeTest5;

	model TypeTest6
	  Real x = 1;
	  Real y(start=true,unit=3,nominal="N",min=true,max="M");
	equation
	  x+y=3;  

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeTest6",
			description="Basic expression type test.",
			errorMessage="
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
	end TypeTest6;


model TypeRel1
 Boolean eq = 1   == 2;
 Boolean ne = 1   <> 2;
 Boolean gt = 1.0 >  2.0;
 Boolean ge = 1.0 >= 2.0;
 Boolean lt = 1.0 <  2.0;
 Boolean le = 1.0 <= 2.0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeRel1",
			description="Type checks of relational operators: Real/Real (Integer for ==/<>)",
			flatModel="
fclass TypeTests.TypeRel1
 discrete Boolean eq = 1 == 2;
 discrete Boolean ne = 1 <> 2;
 discrete Boolean gt = 1.0 > 2.0;
 discrete Boolean ge = 1.0 >= 2.0;
 discrete Boolean lt = 1.0 < 2.0;
 discrete Boolean le = 1.0 <= 2.0;

end TypeTests.TypeRel1;
")})));
end TypeRel1;


model TypeRel2
 Boolean gt = 1 >  2.0;
 Boolean ge = 1 >= 2.0;
 Boolean lt = 1 <  2.0;
 Boolean le = 1 <= 2.0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeRel2",
			description="Type checks of relational operators: Real/Integer",
			flatModel="
fclass TypeTests.TypeRel2
 discrete Boolean gt = 1 > 2.0;
 discrete Boolean ge = 1 >= 2.0;
 discrete Boolean lt = 1 < 2.0;
 discrete Boolean le = 1 <= 2.0;

end TypeTests.TypeRel2;
")})));
end TypeRel2;


model TypeRel3
 Boolean eq = true == false;
 Boolean ne = true <> false;
 Boolean gt = true >  false;
 Boolean ge = true >= false;
 Boolean lt = true <  false;
 Boolean le = true <= false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeRel3",
			description="Type checks of relational operators: Boolean/Boolean",
			flatModel="
fclass TypeTests.TypeRel3
 discrete Boolean eq = true == false;
 discrete Boolean ne = true <> false;
 discrete Boolean gt = true > false;
 discrete Boolean ge = true >= false;
 discrete Boolean lt = true < false;
 discrete Boolean le = true <= false;

end TypeTests.TypeRel3;
")})));
end TypeRel3;


model TypeRel4
 Boolean eq = "1.0" == "2.0";
 Boolean ne = "1.0" <> "2.0";
 Boolean gt = "1.0" >  "2.0";
 Boolean ge = "1.0" >= "2.0";
 Boolean lt = "1.0" <  "2.0";
 Boolean le = "1.0" <= "2.0";

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="TypeRel4",
			description="Type checks of relational operators: String/String",
			flatModel="
fclass TypeTests.TypeRel4
 discrete Boolean eq = \"1.0\" == \"2.0\";
 discrete Boolean ne = \"1.0\" <> \"2.0\";
 discrete Boolean gt = \"1.0\" > \"2.0\";
 discrete Boolean ge = \"1.0\" >= \"2.0\";
 discrete Boolean lt = \"1.0\" < \"2.0\";
 discrete Boolean le = \"1.0\" <= \"2.0\";

end TypeTests.TypeRel4;
")})));
end TypeRel4;


model TypeRel5
 Boolean eq = {1.0} == {2.0};
 Boolean ne = {1.0} <> {2.0};
 Boolean gt = {1.0} >  {2.0};
 Boolean ge = {1.0} >= {2.0};
 Boolean lt = {1.0} <  {2.0};
 Boolean le = {1.0} <= {2.0};

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeRel5",
			description="Type checks of relational operators: Real[1]/Real[1]",
			errorMessage="
6 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 222, column 15:
  Type error in expression: {1.0} == {2.0}
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 223, column 15:
  Type error in expression: {1.0} <> {2.0}
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 224, column 15:
  Type error in expression: {1.0} > {2.0}
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 225, column 15:
  Type error in expression: {1.0} >= {2.0}
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 226, column 15:
  Type error in expression: {1.0} < {2.0}
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 227, column 15:
  Type error in expression: {1.0} <= {2.0}
")})));
end TypeRel5;


model TypeRel6
 Boolean eq = 1.0 == "2.0";
 Boolean ne = 1.0 <> "2.0";
 Boolean gt = 1.0 >  "2.0";
 Boolean ge = 1.0 >= "2.0";
 Boolean lt = 1.0 <  "2.0";
 Boolean le = 1.0 <= "2.0";

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="TypeRel6",
			description="Type checks of relational operators: Real/String",
			errorMessage="
6 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 258, column 15:
  Type error in expression: 1.0 == \"2.0\"
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 259, column 15:
  Type error in expression: 1.0 <> \"2.0\"
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 260, column 15:
  Type error in expression: 1.0 > \"2.0\"
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 261, column 15:
  Type error in expression: 1.0 >= \"2.0\"
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 262, column 15:
  Type error in expression: 1.0 < \"2.0\"
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 263, column 15:
  Type error in expression: 1.0 <= \"2.0\"
")})));
end TypeRel6;



model AbsType1
 Real x = abs(y);
 Real y = -2.0;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="AbsType1",
			description="abs() operator: Real arg & result",
			flatModel="
fclass TypeTests.AbsType1
 Real x = abs(y);
 Real y = - 2.0;
end TypeTests.AbsType1;
")})));
end AbsType1;


model AbsType2
 constant Real x1 = abs(-2.0);
 constant Real x2 = abs(2.0);
 Real y1 = x1;
 Real y2 = x2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="AbsType2",
			description="abs() operator: Real constant",
			flatModel="
fclass TypeTests.AbsType2
 constant Real x1 = abs(- 2.0);
 constant Real x2 = abs(2.0);
 Real y1 = 2.0;
 Real y2 = 2.0;
end TypeTests.AbsType2;
")})));
end AbsType2;


model AbsType3
 Integer x = abs(y);
 Integer y = -2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="AbsType3",
			description="abs() operator: Integer arg & result",
			flatModel="
fclass TypeTests.AbsType3
 discrete Integer x = abs(y);
 discrete Integer y = - 2;
end TypeTests.AbsType3;
")})));
end AbsType3;


model AbsType4
 constant Integer x1 = abs(-2);
 constant Integer x2 = abs(2);
 Integer y1 = x1;
 Integer y2 = x2;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="AbsType4",
			description="abs() operator: Integer constant",
			flatModel="
fclass TypeTests.AbsType4
 constant Integer x1 = abs(- 2);
 constant Integer x2 = abs(2);
 discrete Integer y1 = 2;
 discrete Integer y2 = 2;
end TypeTests.AbsType4;
")})));
end AbsType4;


model AbsType5
 parameter String x = abs("-1");

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AbsType5",
			description="abs() operator: String arg",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 338, column 17:
  Calling function abs(): types of positional argument 1 and input v are not compatible
")})));
end AbsType5;


model AbsType6
 Real x[2] = abs({1,-1});

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="AbsType6",
			description="abs() operator: array arg",
			flatModel="
fclass TypeTests.AbsType6
 Real x[2] = abs({1, - 1});
end TypeTests.AbsType6;
")})));
end AbsType6;


model AbsType7
 Real x = abs(1,-1);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AbsType7",
			description="abs() operator: too many args",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 348, column 17:
  Calling function abs(): too many positional arguments
")})));
end AbsType7;


model AbsType8
 Real x = abs();

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="AbsType8",
			description="abs() operator: no args",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 364, column 11:
  Calling function abs(): missing argument for required input v
")})));
end AbsType8;



model IntegerExp1
 constant Integer x = integer(1.8);
 Integer y = x;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IntegerExp1",
			description="integer() operator: constant",
			flatModel="
fclass TypeTests.IntegerExp1
 constant Integer x = integer(1.8);
 constant Integer y = 1;
end TypeTests.IntegerExp1;
")})));
end IntegerExp1;


model IntegerExp2
 Real x = 1.0;
 Integer y = integer(x);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IntegerExp2",
			description="integer() operator: continous arg",
			flatModel="
fclass TypeTests.IntegerExp2
 constant Real x = 1.0;
 discrete Integer y;
 discrete Integer temp_1;
initial equation 
 temp_1 = integer(x);
 pre(y) = 0;
equation
 y = temp_1;
 when {x < pre(temp_1), x >= pre(temp_1) + 1} then
  temp_1 = 1;
 end when;
end TypeTests.IntegerExp2;
")})));
end IntegerExp2;


model ConstCmpEq
 constant Boolean a = 1 == 2;
 constant Boolean b = 1 == 1;
 Boolean x = a;
 Boolean y = b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstCmpEq",
			description="Constant evaluation of comparisons: equals",
			flatModel="
fclass TypeTests.ConstCmpEq
 constant Boolean a = 1 == 2;
 constant Boolean b = 1 == 1;
 constant Boolean x = false;
 constant Boolean y = true;
end TypeTests.ConstCmpEq;
")})));
end ConstCmpEq;


model ConstCmpNeq
 constant Boolean a = 1 <> 2;
 constant Boolean b = 1 <> 1;
 Boolean x = a;
 Boolean y = b;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstCmpNeq",
			description="Constant evaluation of comparisons: not equal",
			flatModel="
fclass TypeTests.ConstCmpNeq
 constant Boolean a = 1 <> 2;
 constant Boolean b = 1 <> 1;
 constant Boolean x = true;
 constant Boolean y = false;
end TypeTests.ConstCmpNeq;
")})));
end ConstCmpNeq;


model ConstCmpLeq
 constant Boolean a = 1 <= 2;
 constant Boolean b = 1 <= 1;
 constant Boolean c = 2 <= 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstCmpLeq",
			description="Constant evaluation of comparisons: less or equal",
			flatModel="
fclass TypeTests.ConstCmpLeq
 constant Boolean a = 1 <= 2;
 constant Boolean b = 1 <= 1;
 constant Boolean c = 2 <= 1;
 constant Boolean x = true;
 constant Boolean y = true;
 constant Boolean z = false;
end TypeTests.ConstCmpLeq;
")})));
end ConstCmpLeq;


model ConstCmpLt
 constant Boolean a = 1 < 2;
 constant Boolean b = 1 < 1;
 constant Boolean c = 2 < 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstCmpLt",
			description="Constant evaluation of comparisons: less than",
			flatModel="
fclass TypeTests.ConstCmpLt
 constant Boolean a = 1 < 2;
 constant Boolean b = 1 < 1;
 constant Boolean c = 2 < 1;
 constant Boolean x = true;
 constant Boolean y = false;
 constant Boolean z = false;
end TypeTests.ConstCmpLt;
")})));
end ConstCmpLt;


model ConstCmpGeq
 constant Boolean a = 1 >= 2;
 constant Boolean b = 1 >= 1;
 constant Boolean c = 2 >= 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstCmpGeq",
			description="Constant evaluation of comparisons: greater or equal",
			flatModel="
fclass TypeTests.ConstCmpGeq
 constant Boolean a = 1 >= 2;
 constant Boolean b = 1 >= 1;
 constant Boolean c = 2 >= 1;
 constant Boolean x = false;
 constant Boolean y = true;
 constant Boolean z = true;
end TypeTests.ConstCmpGeq;
")})));
end ConstCmpGeq;


model ConstCmpGt
 constant Boolean a = 1 > 2;
 constant Boolean b = 1 > 1;
 constant Boolean c = 2 > 1;
 Boolean x = a;
 Boolean y = b;
 Boolean z = c;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstCmpGt",
			description="Constant evaluation of comparisons:greater than",
			flatModel="
fclass TypeTests.ConstCmpGt
 constant Boolean a = 1 > 2;
 constant Boolean b = 1 > 1;
 constant Boolean c = 2 > 1;
 constant Boolean x = false;
 constant Boolean y = false;
 constant Boolean z = true;
end TypeTests.ConstCmpGt;
")})));
end ConstCmpGt;



model RealEq1
 Boolean a = 1.0 == 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RealEq1",
			description="Equality comparisons for reals: == outside function",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 672, column 14:
  Type error in expression: 1.0 == 2
")})));
end RealEq1;


model RealEq2
 Boolean a = 1.0 <> 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RealEq2",
			description="Equality comparisons for reals: <> outside function",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 688, column 14:
  Type error in expression: 1.0 <> 2
")})));
end RealEq2;


model RealEq3
 function f
  output Boolean a = 1.0 == 2;
 algorithm
 end f;
 
 Boolean b = f();

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RealEq3",
			description="Equality comparisons for reals: == in function",
			flatModel="
fclass TypeTests.RealEq3
 discrete Boolean b = TypeTests.RealEq3.f();

public
 function TypeTests.RealEq3.f
  output Boolean a := 1.0 == 2;
 algorithm
  return;
 end TypeTests.RealEq3.f;

end TypeTests.RealEq3;
")})));
end RealEq3;


model RealEq4
 function f
  output Boolean a = 1.0 <> 2;
 algorithm
 end f;
 
 Boolean b = f();

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="RealEq4",
			description="Equality comparisons for reals: <> in function",
			flatModel="
fclass TypeTests.RealEq4
 discrete Boolean b = TypeTests.RealEq4.f();

public
 function TypeTests.RealEq4.f
  output Boolean a := 1.0 <> 2;
 algorithm
  return;
 end TypeTests.RealEq4.f;

end TypeTests.RealEq4;
")})));
end RealEq4;



model ParameterStart1
  constant Real p(start=2);
  Real y = p;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ParameterStart1",
			description="Constant without binding expression: start set",
			flatModel="
fclass TypeTests.ParameterStart1
 constant Real p(start = 2);
 constant Real y = 2.0;
end TypeTests.ParameterStart1;
")})));
end ParameterStart1;


model ParameterStart2
  constant Real p;
  Real y = p;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ParameterStart2",
			description="Constant without binding expression: start not set",
			flatModel="
fclass TypeTests.ParameterStart2
 constant Real p;
 constant Real y = 0.0;
end TypeTests.ParameterStart2;
")})));
end ParameterStart2;

model ArrayTypeTest1
  type T = Real[3](unit="m");
  T x = {1,2,4};

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTypeTest1",
			description="Check that short type declarations with array indices are expanded correctly.",
			flatModel="
fclass TypeTests.ArrayTypeTest1
 constant TypeTests.ArrayTypeTest1.T x[1] = 1;
 constant TypeTests.ArrayTypeTest1.T x[2] = 2;
 constant TypeTests.ArrayTypeTest1.T x[3] = 4;

public
 type TypeTests.ArrayTypeTest1.T = Real(unit = \"m\");
end TypeTests.ArrayTypeTest1;
")})));
end ArrayTypeTest1;

model ArrayTypeTest2
  type S = T[4](start=3,unit="m");
  type T = Real[3](unit="l");
  T x = {1,2,4};
  S y = zeros(4,3);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTypeTest2",
			description="Check that short type declarations with array indices are expanded correctly.",
			flatModel="
fclass TypeTests.ArrayTypeTest2
 constant TypeTests.ArrayTypeTest2.T x[1] = 1;
 constant TypeTests.ArrayTypeTest2.T x[2] = 2;
 constant TypeTests.ArrayTypeTest2.T x[3] = 4;
 constant TypeTests.ArrayTypeTest2.S y[1,1] = 0;
 constant TypeTests.ArrayTypeTest2.S y[1,2] = 0;
 constant TypeTests.ArrayTypeTest2.S y[1,3] = 0;
 constant TypeTests.ArrayTypeTest2.S y[2,1] = 0;
 constant TypeTests.ArrayTypeTest2.S y[2,2] = 0;
 constant TypeTests.ArrayTypeTest2.S y[2,3] = 0;
 constant TypeTests.ArrayTypeTest2.S y[3,1] = 0;
 constant TypeTests.ArrayTypeTest2.S y[3,2] = 0;
 constant TypeTests.ArrayTypeTest2.S y[3,3] = 0;
 constant TypeTests.ArrayTypeTest2.S y[4,1] = 0;
 constant TypeTests.ArrayTypeTest2.S y[4,2] = 0;
 constant TypeTests.ArrayTypeTest2.S y[4,3] = 0;

public
 type TypeTests.ArrayTypeTest2.T = Real(unit = \"l\");
 type TypeTests.ArrayTypeTest2.S = Real(start = 3,unit = \"m\");
end TypeTests.ArrayTypeTest2;
")})));
end ArrayTypeTest2;

model ArrayTypeTest3
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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTypeTest3",
			description="Check that short type declarations with array indices are expanded correctly.",
			flatModel="
fclass TypeTests.ArrayTypeTest3
 constant Real y[1].x(start = 1) = 1;
 constant Real y[2].x(start = 1) = 1;
 constant Real y[3].x(start = 1) = 1;
 constant Real z[1].x = 1;
 constant Real z[2].x = 1;
 constant Real z[3].x = 1;
 constant Real w.x = 1;
end TypeTests.ArrayTypeTest3;
")})));
end ArrayTypeTest3;

model ArrayTypeTest4

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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTypeTest4",
			description="Check that short type declarations with array indices are expanded correctly.",
			flatModel="
fclass TypeTests.ArrayTypeTest4
 constant Real y[1,1].x(start = 1) = 1;
 constant Real y[1,2].x(start = 1) = 1;
 constant Real y[2,1].x(start = 1) = 1;
 constant Real y[2,2].x(start = 1) = 1;
 constant Real y[3,1].x(start = 1) = 1;
 constant Real y[3,2].x(start = 1) = 1;
 constant Real z[1].x = 1;
 constant Real z[2].x = 1;
 constant Real z[3].x = 1;
 constant Real w.x = 1;
end TypeTests.ArrayTypeTest4;
")})));
end ArrayTypeTest4;

model ArrayTypeTest5

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

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ArrayTypeTest5",
			description="Check that short type declarations with array indices are expanded correctly.",
			flatModel="
fclass TypeTests.ArrayTypeTest5
 constant Real y[1,1].x(start = 1) = 3;
 constant Real y[1,2].x(start = 1) = 3;
 constant Real y[2,1].x(start = 1) = 3;
 constant Real y[2,2].x(start = 1) = 3;
 constant Real y[3,1].x(start = 1) = 3;
 constant Real y[3,2].x(start = 1) = 3;
 constant Real z[1].x = 3;
 constant Real z[2].x = 3;
 constant Real z[3].x = 3;
 constant Real w.x = 3;
end TypeTests.ArrayTypeTest5;
")})));
end ArrayTypeTest5;



model UnknownTypeAccess1
 model C
  Real x=1;
 end C;
 C c;
equation
 c.x = c;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="UnknownTypeAccess1",
			description="Using component of model type as expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1010, column 8:
  Accesses to composite components other than records are not allowed: c
")})));
end UnknownTypeAccess1;



model RecursiveStructure1
	model A
		B b;
	end A;
	
	model B
		A a1;
	end B;
	
	A a2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecursiveStructure1",
			description="Detect recursive class structures",
			errorMessage="
1 error found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1021, column 5:
  Recursive class structure
")})));
end RecursiveStructure1;


model RecursiveStructure2
	model A
		extends B;
	end A;
	
	model B
		extends A;
	end B;
	
	A a;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecursiveStructure2",
			description="Detect recursive class structures",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1062, column 3:
  Recursive class structure
")})));
end RecursiveStructure2;


model RecursiveStructure3
	model A
		extends B;
	end A;
	
	model B
		A a1;
	end B;
	
	A a2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecursiveStructure3",
			description="Detect recursive class structures",
			errorMessage="
1 error found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1071, column 3:
  Recursive class structure
")})));
end RecursiveStructure3;


model RecursiveStructure4
	model A = B;
	model B = A;
	
	A a;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RecursiveStructure4",
			description="Detect recursive class structures",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1141, column 13:
  Recursive class structure
")})));
end RecursiveStructure4;


model WhenType1
	Real x = 1;
equation
	when 1 then
		x = 2;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="WhenType1",
			description="Using test expression of wrong type",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1100, column 2:
  Test expression of when equation isn't Boolean scalar or vector expression
")})));
end WhenType1;


model WhenType2
	Real x = 1;
equation
	when fill(false, 1, 1) then
		x = 2;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="WhenType2",
			description="Using test expression with too many dimensions",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1120, column 2:
  Test expression of when equation isn't Boolean scalar or vector expression
")})));
end WhenType2;

model DivTest1
  Real aReal = 3;
  Integer anInt = 3;
  Real x    = div(aReal,aReal) + div(anInt,aReal) + div(aReal,anInt) + div(anInt,anInt);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="DivTest1",
			description="Testing output types of the div operator.",
			flatModel="
fclass TypeTests.DivTest1
 constant Real aReal = 3;
 constant Integer anInt = 3;
 Real x;
 discrete Integer temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
 discrete Real temp_4;
initial equation 
 temp_1 = div(anInt, anInt);
 temp_2 = div(aReal, anInt);
 temp_3 = div(anInt, aReal);
 temp_4 = div(aReal, aReal);
equation
 x = temp_4 + temp_3 + temp_2 + temp_1;
 when {noEvent(div(anInt, anInt)) < pre(temp_1), noEvent(div(anInt, anInt)) >= pre(temp_1) + 1} then
  temp_1 = 1;
 end when;
 when {noEvent(div(aReal, anInt)) < pre(temp_2), noEvent(div(aReal, anInt)) >= pre(temp_2) + 1} then
  temp_2 = 1.0;
 end when;
 when {noEvent(div(anInt, aReal)) < pre(temp_3), noEvent(div(anInt, aReal)) >= pre(temp_3) + 1} then
  temp_3 = 1.0;
 end when;
 when {noEvent(div(aReal, aReal)) < pre(temp_4), noEvent(div(aReal, aReal)) >= pre(temp_4) + 1} then
  temp_4 = 1.0;
 end when;
end TypeTests.DivTest1;
")})));
end DivTest1;

model DivTest2
  Real x    = div(1.,true) + div("hej",2.);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="DivTest2",
			description="Testing wrong input types of the div operator.",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1107, column 22:
  Calling function div(): types of positional argument 2 and input x2 are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1107, column 34:
  Calling function div(): types of positional argument 1 and input x1 are not compatible
")})));
end DivTest2;

model ModTest1
  Real aReal = 3;
  Integer anInt = 3;
  Real x    = mod(aReal,aReal) + mod(anInt,aReal) + mod(aReal,anInt) + mod(anInt,anInt);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ModTest1",
			description="Testing output types of the mod operator.",
			flatModel="
fclass TypeTests.ModTest1
 constant Real aReal = 3;
 constant Integer anInt = 3;
 Real x;
 discrete Integer temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
 discrete Real temp_4;
initial equation 
 temp_1 = integer(anInt / anInt);
 temp_2 = floor(aReal / anInt);
 temp_3 = floor(anInt / aReal);
 temp_4 = floor(aReal / aReal);
equation
 x = 3.0 - temp_4 * 3.0 + (3 - temp_3 * 3.0) + (3.0 - temp_2 * 3) + (3 - temp_1 * 3);
 when {anInt / anInt < pre(temp_1), anInt / anInt >= pre(temp_1) + 1} then
  temp_1 = 1;
 end when;
 when {aReal / anInt < pre(temp_2), aReal / anInt >= pre(temp_2) + 1} then
  temp_2 = 1.0;
 end when;
 when {anInt / aReal < pre(temp_3), anInt / aReal >= pre(temp_3) + 1} then
  temp_3 = 1.0;
 end when;
 when {aReal / aReal < pre(temp_4), aReal / aReal >= pre(temp_4) + 1} then
  temp_4 = 1.0;
 end when;
end TypeTests.ModTest1;
")})));
end ModTest1;

model ModTest2
  Real x    = mod(1.,true) + mod("hej",2.);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ModTest2",
			description="Testing wrong input types of the mod operator.",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1141, column 22:
  Calling function mod(): types of positional argument 2 and input x2 are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1141, column 34:
  Calling function mod(): types of positional argument 1 and input x1 are not compatible
")})));
end ModTest2;

model RemTest1
  Real aReal = 3;
  Integer anInt = 3;
  Real x    = rem(aReal,aReal) + rem(anInt,aReal) + rem(aReal,anInt) + rem(anInt,anInt);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="RemTest1",
			description="Testing output types of the rem operator.",
			flatModel="
fclass TypeTests.RemTest1
 constant Real aReal = 3;
 constant Integer anInt = 3;
 Real x;
 discrete Integer temp_1;
 discrete Real temp_2;
 discrete Real temp_3;
 discrete Real temp_4;
initial equation 
 temp_1 = div(anInt, anInt);
 temp_2 = div(aReal, anInt);
 temp_3 = div(anInt, aReal);
 temp_4 = div(aReal, aReal);
equation
 x = 3.0 - temp_4 * 3.0 + (3 - temp_3 * 3.0) + (3.0 - temp_2 * 3) + (3 - temp_1 * 3);
 when {noEvent(div(anInt, anInt)) < pre(temp_1), noEvent(div(anInt, anInt)) >= pre(temp_1) + 1} then
  temp_1 = 1;
 end when;
 when {noEvent(div(aReal, anInt)) < pre(temp_2), noEvent(div(aReal, anInt)) >= pre(temp_2) + 1} then
  temp_2 = 1.0;
 end when;
 when {noEvent(div(anInt, aReal)) < pre(temp_3), noEvent(div(anInt, aReal)) >= pre(temp_3) + 1} then
  temp_3 = 1.0;
 end when;
 when {noEvent(div(aReal, aReal)) < pre(temp_4), noEvent(div(aReal, aReal)) >= pre(temp_4) + 1} then
  temp_4 = 1.0;
 end when;
end TypeTests.RemTest1;
")})));
end RemTest1;

model RemTest2
  Real x    = rem(1.,true) + rem("hej",2.);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="RemTest2",
			description="Testing wrong input types of the rem operator.",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1175, column 22:
  Calling function rem(): types of positional argument 2 and input x2 are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1175, column 34:
  Calling function rem(): types of positional argument 1 and input x1 are not compatible
")})));
end RemTest2;

model PreTest1
	Real x (start=3);
        Real y;
        discrete Real z;
equation
        y = pre(x);
	when time>1 then
		z = pre(x);
	elsewhen time>3 then
                z = 2*pre(x);
        end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="PreTest1",
			description="Testing that continuous variables can be accessed in pre expressions inside when clauses.",
			errorMessage="
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1148, column 13:
  Calling built-in operator pre() with a continuous variable access as argument can only be done in when clauses
")})));
end PreTest1;

model EdgeTest1
  Real x (start=3);
  Boolean x2;
  Boolean y,y2;
  Boolean z,z2;
  
equation
  y  = edge(x);
  y2 = edge(x2);
  when time>1 then
    z  = edge(x);
    z2 = edge(x2);
  end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="EdgeTest1",
			description="Testing that input to edge has to be boolean.",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1120, column 8:
  Calling function edge(): argument must be a boolean variable access
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1123, column 10:
  Calling function edge(): argument must be a boolean variable access
")})));
end EdgeTest1;

model ChangeTest1
  Real x (start=3);
  Boolean y;
  Boolean z;
equation
  y = change(x);
  when time>1 then
    z = change(x);
  end when;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ChangeTest1",
			description="Testing that continuous variables can be accessed in change expressions inside when clauses.",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1147, column 7:
  Calling built-in operator change() with a continuous variable access as argument can only be done in when clauses
")})));
end ChangeTest1;

model IfExpType1
    model M
        parameter Integer n=1;
        Real y[n];
    end M;

    parameter Integer n = 3;
    M m(n=n, y = if n==1 then {2} else 1:n);

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfExpType1",
			description="If expression with branches with different array sizes",
			flatModel="
fclass TypeTests.IfExpType1
 parameter Integer n = 3 /* 3 */;
 parameter Integer m.n = 3 /* 3 */;
 constant Real m.y[1] = 1;
 constant Real m.y[2] = 2;
 constant Real m.y[3] = 3;
end TypeTests.IfExpType1;
")})));
end IfExpType1;


model IfExpType2
    Real x = if 1 then 1 else 2;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="IfExpType2",
			description="If expression errors: non-boolean test expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1217, column 17:
  Test expression of if expression must be scalar boolean
")})));
end IfExpType2;


model IfExpType3
    model M
        parameter Integer n=1;
        Real y[n];
    end M;

    parameter Integer n = 3;
    M m(n=n, y = if n==1 then {true} else 1:n);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="IfExpType3",
			description="If expression errors: incompatible types of branches",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1239, column 18:
  Branches of if expression has incompatible types
")})));
end IfExpType3;


model IfExpType4
    model M
        parameter Integer n=1;
        Real y[n];
    end M;

    parameter Integer n = 3;
    Integer k = n;
    M m(n=n, y = if k==1 then {2} else 1:n);

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="IfExpType4",
			description="If expression errors: non-parameter test expression",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1262, column 18:
  If expression with branches that have different array sizes must have parameter test expression
")})));
end IfExpType4;


model IfExpType5
  function F
    input Real x1;
    input Real x2;
    input Integer n;
    output Real y[n];
  algorithm
    for i in 1:n loop
      y[i] := i;
    end for;
    y[1] := x1 + x2;
  end F;

  model M
    parameter Integer n=1;
    Real y[n];
  end M;

  parameter Integer n = 3;
  M m(n=n, y = if n==1 then {2.} else F(3,5,n));

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="IfExpType5",
			description="If expression with branches with different array sizes, using function call",
			variability_propagation=false,
			flatModel="
fclass TypeTests.IfExpType5
 parameter Integer n = 3 /* 3 */;
 parameter Integer m.n = 3 /* 3 */;
 Real m.y[1];
 Real m.y[2];
 Real m.y[3];
equation
 ({m.y[1], m.y[2], m.y[3]}) = TypeTests.IfExpType5.F(3, 5, 3);

public
 function TypeTests.IfExpType5.F
  input Real x1;
  input Real x2;
  input Integer n;
  output Real[n] y;
 algorithm
  for i in 1:n loop
   y[i] := i;
  end for;
  y[1] := x1 + x2;
  return;
 end TypeTests.IfExpType5.F;

end TypeTests.IfExpType5;
")})));
end IfExpType5;

model EquationNominalTypeTest1
	Real x, y;
	parameter Real pEnabled = 1;
	Real pValues[2] = {2,3};
equation
	x = y + 1;
	y = x - 1 annotation(__Modelon(nominal(enabled=pEnabled)=pValues));
	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="EquationNominalTypeTest1",
			description="If expression errors: non-parameter test expression",
			errorMessage="
3 errors found:

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1358, column 49:
  Cannot evaluate boolean enabled expression: pEnabled

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1358, column 59:
  Nominal expression should have parameter variability or less, pValues has variability

Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1358, column 59:
  Size of nominal expression pValues is not the same size as the surrounding equation, size of expression [2], size of equation scalar
")})));
end EquationNominalTypeTest1;



model Primitive1
    type T2 = Real[3];
    type T = T2;
    
    Real[3] x = {1,2,3};
    T y = x;
	T z;
	T2 w = x;
equation
	z = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Primitive1",
			description="Short class decl of type that is array of Real",
			flatModel="
fclass TypeTests.Primitive1
 Real x[3] = {1, 2, 3};
 TypeTests.Primitive1.T2 y[3] = x[1:3];
 TypeTests.Primitive1.T2 z[3];
 TypeTests.Primitive1.T2 w[3] = x[1:3];
equation
 z[1:3] = x[1:3];

public
 type TypeTests.Primitive1.T2 = Real;
end TypeTests.Primitive1;
")})));
end Primitive1;


model Primitive2
    type T2 = Real[3];
    type T
		extends T2;
	end T;
        
    Real[3] x = {1,2,3};
    T y = x;
    T z;
    T2 w = x;
equation
    z = x;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Primitive2",
			description="Class decl extending type that is array of Real",
			flatModel="
fclass TypeTests.Primitive2
 Real x[3] = {1, 2, 3};
 TypeTests.Primitive2.T y[3] = x[1:3];
 TypeTests.Primitive2.T z[3];
 TypeTests.Primitive2.T2 w[3] = x[1:3];
equation
 z[1:3] = x[1:3];

public
 type TypeTests.Primitive2.T = Real;
 type TypeTests.Primitive2.T2 = Real;
end TypeTests.Primitive2;
")})));
end Primitive2;


model Primitive3
    type T1 = Real;
    type T2 = T1[2];
	type T3 = T2;
	type T4 = T3[3];
	type T5 = T4;
    
    Real[3,2] x = {{1,2},{3,4},{5,6}};
    Real[2] y = {7,8};
    T5 z1 = x;
    T5 z2;
	T3 z3 = y;
	T3 z4;
equation
    z2 = x;
	z4 = y;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Primitive3",
			description="Short class decl of type that is array of Real, adding dimensions in several levels",
			flatModel="
fclass TypeTests.Primitive3
 Real x[3,2] = {{1, 2}, {3, 4}, {5, 6}};
 Real y[2] = {7, 8};
 TypeTests.Primitive3.T4 z1[3,2] = x[1:3,1:2];
 TypeTests.Primitive3.T4 z2[3,2];
 TypeTests.Primitive3.T2 z3[2] = y[1:2];
 TypeTests.Primitive3.T2 z4[2];
equation
 z2[1:3,1:2] = x[1:3,1:2];
 z4[1:2] = y[1:2];

public
 type TypeTests.Primitive3.T4 = Real;
 type TypeTests.Primitive3.T2 = Real;
end TypeTests.Primitive3;
")})));
end Primitive3;


model Primitive4
    type T2 = Real[3,3];
    type T = T2;
        
    function f
        input Real[3] x;
        input Real[3] y;
        output T z;
    algorithm
        z := {x, cross(x,y), y};
    end f;
    
    Real[3] x = {1,2,3};
    Real[3] y = {4,5,6};
    T z1 = f(x,y);
    T z2;
equation
    z2 = transpose(z1);

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="Primitive4",
			description="",
			flatModel="
fclass TypeTests.Primitive4
 Real x[3] = {1, 2, 3};
 Real y[3] = {4, 5, 6};
 TypeTests.Primitive4.T2 z1[3,3] = TypeTests.Primitive4.f(x[1:3], y[1:3]);
 TypeTests.Primitive4.T2 z2[3,3];
equation
 z2[1:3,1:3] = transpose(z1[1:3,1:3]);

public
 function TypeTests.Primitive4.f
  input Real[3] x;
  input Real[3] y;
  output Real[3, 3] z;
 algorithm
  z := {x, cross(x, y), y};
  return;
 end TypeTests.Primitive4.f;

 type TypeTests.Primitive4.T2 = Real;
end TypeTests.Primitive4;
")})));
end Primitive4;


model StringExpType1
	parameter String a = String({1,2});
	parameter String b = String("a");

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="StringExpType1",
			description="",
			errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1439, column 30:
  Calling function String(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/TypeTests.mo':
Semantic error at line 1440, column 30:
  Calling function String(): types of positional argument 1 and input x are not compatible
")})));
end StringExpType1;


end TypeTests;
