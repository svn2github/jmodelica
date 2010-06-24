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

within ;
package ArrayBuiltins
	
	
	
model SizeExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SizeExp1",
		 description="Size operator: first dim",
		 flatModel="
fclass ArrayBuiltins.SizeExp1
 Real x;
equation
 x = 2;
end ArrayBuiltins.SizeExp1;
")})));

 Real x = size(ones(2), 1);
end SizeExp1;


model SizeExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SizeExp2",
		 description="Size operator: second dim",
		 flatModel="
fclass ArrayBuiltins.SizeExp2
 Real x;
equation
 x = 3;
end ArrayBuiltins.SizeExp2;
")})));

 Real x = size(ones(2, 3), 2);
end SizeExp2;


model SizeExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SizeExp3",
		 description="Size operator: without dim",
		 flatModel="
fclass ArrayBuiltins.SizeExp3
 Real x[1];
equation
 x[1] = 2;
end ArrayBuiltins.SizeExp3;
")})));

 Real x[1] = size(ones(2));
end SizeExp3;


model SizeExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SizeExp4",
		 description="Size operator: without dim",
		 flatModel="
fclass ArrayBuiltins.SizeExp4
 Real x[1];
 Real x[2];
equation
 x[1] = 2;
 x[2] = 3;
end ArrayBuiltins.SizeExp4;
")})));

 Real x[2] = size(ones(2, 3));
end SizeExp4;


model SizeExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SizeExp5",
		 description="Size operator: using parameter",
		 flatModel="
fclass ArrayBuiltins.SizeExp5
 parameter Integer p = 1 /* 1 */;
 Real x;
equation
 x = 2;
end ArrayBuiltins.SizeExp5;
")})));

 parameter Integer p = 1;
 Real x = size(ones(2, 3), p);
end SizeExp5;


model SizeExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="SizeExp6",
		 description="Size operator: too high variability of dim",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 793, column 11:
  Type error in expression
")})));

 Integer d = 1;
 Real x = size(ones(2, 3), d);
end SizeExp6;


model SizeExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="SizeExp7",
		 description="Size operator: array as dim",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 809, column 11:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 809, column 28:
  Calling function size(): types of positional argument 2 and input d are not compatible
")})));

 Real x = size(ones(2, 3), {1, 2});
end SizeExp7;


model SizeExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="SizeExp8",
		 description="Size operator: Real as dim",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 828, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 1.0);
end SizeExp8;


model SizeExp9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="SizeExp9",
		 description="Size operator: too low dim",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 844, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 0);
end SizeExp9;


model SizeExp10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="SizeExp10",
		 description="Size operator: too high dim",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 860, column 11:
  Type error in expression
")})));

 Real x = size(ones(2, 3), 3);
end SizeExp10;



model FillExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="FillExp1",
		 description="Fill operator: one dim",
		 flatModel="
fclass ArrayBuiltins.FillExp1
 Real x[1];
 Real x[2];
equation
 x[1] = 1 + 2;
 x[2] = 1 + 2;
end ArrayBuiltins.FillExp1;
")})));

 Real x[2] = fill(1 + 2, 2);
end FillExp1;


model FillExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="FillExp2",
		 description="Fill operator: three dims",
		 flatModel="
fclass ArrayBuiltins.FillExp2
 Real x[1,1,1];
 Real x[1,1,2];
 Real x[1,1,3];
 Real x[1,1,4];
 Real x[1,2,1];
 Real x[1,2,2];
 Real x[1,2,3];
 Real x[1,2,4];
 Real x[1,3,1];
 Real x[1,3,2];
 Real x[1,3,3];
 Real x[1,3,4];
 Real x[2,1,1];
 Real x[2,1,2];
 Real x[2,1,3];
 Real x[2,1,4];
 Real x[2,2,1];
 Real x[2,2,2];
 Real x[2,2,3];
 Real x[2,2,4];
 Real x[2,3,1];
 Real x[2,3,2];
 Real x[2,3,3];
 Real x[2,3,4];
equation
 x[1,1,1] = 1 + 2;
 x[1,1,2] = 1 + 2;
 x[1,1,3] = 1 + 2;
 x[1,1,4] = 1 + 2;
 x[1,2,1] = 1 + 2;
 x[1,2,2] = 1 + 2;
 x[1,2,3] = 1 + 2;
 x[1,2,4] = 1 + 2;
 x[1,3,1] = 1 + 2;
 x[1,3,2] = 1 + 2;
 x[1,3,3] = 1 + 2;
 x[1,3,4] = 1 + 2;
 x[2,1,1] = 1 + 2;
 x[2,1,2] = 1 + 2;
 x[2,1,3] = 1 + 2;
 x[2,1,4] = 1 + 2;
 x[2,2,1] = 1 + 2;
 x[2,2,2] = 1 + 2;
 x[2,2,3] = 1 + 2;
 x[2,2,4] = 1 + 2;
 x[2,3,1] = 1 + 2;
 x[2,3,2] = 1 + 2;
 x[2,3,3] = 1 + 2;
 x[2,3,4] = 1 + 2;
end ArrayBuiltins.FillExp2;
")})));

 Real x[2,3,4] = fill(1 + 2, 2, 3, 4);
end FillExp2;


model FillExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="FillExp3",
		 description="Fill operator: no size args",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 892, column 11:
  Too few arguments to fill(), must have at least 2
")})));

 Real x = fill(1 + 2);
end FillExp3;


model FillExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="FillExp4",
		 description="Fill operator:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 897, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [3]
")})));

 Real x[2] = fill(1 + 2, 3);
end FillExp4;


model FillExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="FillExp5",
		 description="Fill operator: Real size arg",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 897, column 26:
  Argument of fill() is not compatible with Integer: 2.0
")})));

 Real x[2] = fill(1 + 2, 2.0);
end FillExp5;


model FillExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="FillExp6",
		 description="Fill operator: too high variability of size arg",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1145, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is [n]
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1145, column 26:
  Argument of fill() does not have constant or parameter variability: n
")})));

 Integer n = 2;
 Real x[2] = fill(1 + 2, n);
end FillExp6;


model FillExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="FillExp7",
		 description="Fill operator: no arguments at all",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1259, column 7:
  Array size mismatch in declaration of x, size of declaration is [2] and size of binding expression is []
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1259, column 14:
  Calling function fill(): missing argument for required input s
")})));

 Real x[2] = fill();
end FillExp7;


model FillExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="FillExp8",
		 description="Fill operator: filling with array",
		 flatModel="
fclass ArrayBuiltins.FillExp8
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 1;
 x[2,2] = 2;
 x[3,1] = 1;
 x[3,2] = 2;
end ArrayBuiltins.FillExp8;
")})));

 Real x[3,2] = fill({1,2}, 3);
end FillExp8;
 


model MinExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MinExp1",
		 description="Min operator: 2 scalar args",
		 flatModel="
fclass ArrayBuiltins.MinExp1
 constant Real x = min(1 + 2, 3 + 4);
 Real y;
equation
 y = 3.0;
end ArrayBuiltins.MinExp1;
")})));

 constant Real x = min(1+2, 3+4);
 Real y = x;
end MinExp1;


model MinExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MinExp2",
		 description="Min operator: 1 array arg",
		 flatModel="
fclass ArrayBuiltins.MinExp2
 constant Real x = min(min(min(1, 2), 3), 4);
 Real y;
equation
 y = 1.0;
end ArrayBuiltins.MinExp2;
")})));

 constant Real x = min({{1,2},{3,4}});
 Real y = x;
end MinExp2;


model MinExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MinExp3",
		 description="Min operator: strings",
		 flatModel="
fclass ArrayBuiltins.MinExp3
 constant String x = min(\"foo\", \"bar\");
 String y;
equation
 y = \"bar\";
end ArrayBuiltins.MinExp3;
")})));

 constant String x = min("foo", "bar");
 String y = x;
end MinExp3;


model MinExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MinExp4",
		 description="Min operator: booleans",
		 flatModel="
fclass ArrayBuiltins.MinExp4
 constant Boolean x = min(true, false);
 Boolean y;
equation
 y = false;
end ArrayBuiltins.MinExp4;
")})));

 constant Boolean x = min(true, false);
 Boolean y = x;
end MinExp4;


model MinExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MinExp5",
		 description="Min operator: mixed types",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 958, column 11:
  Type error in expression
")})));

 Real x = min(true, 0);
end MinExp5;


model MinExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MinExp6",
		 description="Min operator: 2 array args",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 974, column 15:
  Calling function min(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 974, column 22:
  Calling function min(): types of positional argument 2 and input y are not compatible
")})));

 Real x = min({1,2}, {3,4});
end MinExp6;


model MinExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MinExp7",
		 description="Min operator: 1 scalar arg",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 993, column 15:
  Calling function min(): types of positional argument 1 and input x are not compatible
")})));

 Real x = min(1);
end MinExp7;


model MinExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MinExp8",
		 description="Reduction-expression with min(): constant expression",
		 flatModel="
fclass ArrayBuiltins.MinExp8
 constant Real x = min(min(min(min(min(min(min(min(min(min(min(1.0, 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0);
 Real y;
equation
 y = 1.0;
end ArrayBuiltins.MinExp8;
")})));

 constant Real x = min(1.0 for i in 1:4, j in {2,3,5});
 Real y = x;
end MinExp8;


model MinExp9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MinExp9",
		 description="Reduction-expression with min(): basic test",
		 flatModel="
fclass ArrayBuiltins.MinExp9
 Real x;
equation
 x = min(min(min(min(min(min(min(min(( 1 ) * ( 2 ), ( 1 ) * ( 3 )), ( 1 ) * ( 5 )), ( 2 ) * ( 2 )), ( 2 ) * ( 3 )), ( 2 ) * ( 5 )), ( 3 ) * ( 2 )), ( 3 ) * ( 3 )), ( 3 ) * ( 5 ));
end ArrayBuiltins.MinExp9;
")})));

 Real x = min(i * j for i in 1:3, j in {2,3,5});
end MinExp9;


model MinExp10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MinExp10",
		 description="Reduction-expression with min(): non-vector index expressions",
		 errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1472, column 11:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1472, column 25:
  The expression of for index i must be a vector expression: {{1,2},{3,4}} has 2 dimension(s)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1472, column 45:
  The expression of for index j must be a vector expression: 2 has 0 dimension(s)
")})));

 Real x = min(i * j for i in {{1,2},{3,4}}, j in 2);
end MinExp10;


model MinExp11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MinExp11",
		 description="Reduction-expression with min(): non-scalar expression",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1188, column 11:
  The expression of a reduction-expression must be scalar, except for sum(): {( i ) * ( j ),2} has 1 dimension(s)
")})));

 Real x = min({i * j, 2} for i in 1:4, j in 2:5);
end MinExp11;


model MinExp12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MinExp12",
		 description="Reduction-expression with min(): wrong type in expression",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1193, column 7:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Real x = min(false for i in 1:4, j in 2:5);
end MinExp12;



model MaxExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MaxExp1",
		 description="Max operator: 2 scalar args",
		 flatModel="
fclass ArrayBuiltins.MaxExp1
 constant Real x = max(1 + 2, 3 + 4);
 Real y;
equation
 y = 7.0;
end ArrayBuiltins.MaxExp1;
")})));

 constant Real x = max(1+2, 3+4);
 Real y = x;
end MaxExp1;


model MaxExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MaxExp2",
		 description="Max operator: 1 array arg",
		 flatModel="
fclass ArrayBuiltins.MaxExp2
 constant Real x = max(max(max(1, 2), 3), 4);
 Real y;
equation
 y = 4.0;
end ArrayBuiltins.MaxExp2;
")})));

 constant Real x = max({{1,2},{3,4}});
 Real y = x;
end MaxExp2;


model MaxExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MaxExp3",
		 description="Max operator: strings",
		 flatModel="
fclass ArrayBuiltins.MaxExp3
 constant String x = max(\"foo\", \"bar\");
 String y;
equation
 y = \"foo\";
end ArrayBuiltins.MaxExp3;
")})));

 constant String x = max("foo", "bar");
 String y = x;
end MaxExp3;


model MaxExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MaxExp4",
		 description="Max operator: booleans",
		 flatModel="
fclass ArrayBuiltins.MaxExp4
 constant Boolean x = max(true, false);
 Boolean y;
equation
 y = true;
end ArrayBuiltins.MaxExp4;
")})));

 constant Boolean x = max(true, false);
 Boolean y = x;
end MaxExp4;


model MaxExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MaxExp5",
		 description="Max operator: mixed types",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 958, column 11:
  Type error in expression
")})));

 Real x = max(true, 0);
end MaxExp5;


model MaxExp6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MaxExp6",
		 description="Max operator: 2 array args",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 974, column 15:
  Calling function max(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 974, column 22:
  Calling function max(): types of positional argument 2 and input y are not compatible
")})));

 Real x = max({1,2}, {3,4});
end MaxExp6;


model MaxExp7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MaxExp7",
		 description="Max operator: 1 scalar arg",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 993, column 15:
  Calling function max(): types of positional argument 1 and input x are not compatible
")})));

 Real x = max(1);
end MaxExp7;


model MaxExp8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MaxExp8",
		 description="Reduction-expression with max(): constant expression",
		 flatModel="
fclass ArrayBuiltins.MaxExp8
 Real x;
equation
 x = max(max(max(max(max(max(max(max(max(max(max(1.0, 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0), 1.0);
end ArrayBuiltins.MaxExp8;
")})));

 Real x = max(1.0 for i in 1:4, j in {2,3,5});
end MaxExp8;


model MaxExp9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="MaxExp9",
		 description="Reduction-expression with max(): basic test",
		 flatModel="
fclass ArrayBuiltins.MaxExp9
 constant Real x = max(max(max(max(max(max(max(max(max(max(max(( 1 ) * ( 2 ), ( 1 ) * ( 3 )), ( 1 ) * ( 5 )), ( 2 ) * ( 2 )), ( 2 ) * ( 3 )), ( 2 ) * ( 5 )), ( 3 ) * ( 2 )), ( 3 ) * ( 3 )), ( 3 ) * ( 5 )), ( 4 ) * ( 2 )), ( 4 ) * ( 3 )), ( 4 ) * ( 5 ));
 Real y;
equation
 y = 20.0;
end ArrayBuiltins.MaxExp9;
")})));

 constant Real x = max(i * j for i in 1:4, j in {2,3,5});
 Real y = x;
end MaxExp9;


model MaxExp10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MaxExp10",
		 description="Reduction-expression with max(): non-vector index expressions",
		 errorMessage="
3 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1690, column 11:
  Type error in expression
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1690, column 25:
  The expression of for index i must be a vector expression: {{1,2},{3,4}} has 2 dimension(s)
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1690, column 45:
  The expression of for index j must be a vector expression: 2 has 0 dimension(s)
")})));

 Real x = max(i * j for i in {{1,2},{3,4}}, j in 2);
end MaxExp10;


model MaxExp11
 Real x = max({i * j, 2} for i in 1:4, j in 2:5);
end MaxExp11;


model MaxExp12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="MaxExp12",
		 description="Reduction-expression with max(): wrong type in expression",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1462, column 7:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Real x = max(false for i in 1:4, j in 2:5);
end MaxExp12;



model SumExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SumExp1",
		 description="sum() expressions: basic test",
		 flatModel="
fclass ArrayBuiltins.SumExp1
 constant Real x = 1 + 2 + 3 + 4;
 Real y;
equation
 y = 10.0;
end ArrayBuiltins.SumExp1;
")})));

 constant Real x = sum({1,2,3,4});
 Real y = x;
end SumExp1;


model SumExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SumExp2",
		 description="sum() expressions: reduction-expression",
		 flatModel="
fclass ArrayBuiltins.SumExp2
 constant Real x = ( 1 ) * ( 1 ) + ( 1 ) * ( 2 ) + ( 1 ) * ( 3 ) + ( 2 ) * ( 1 ) + ( 2 ) * ( 2 ) + ( 2 ) * ( 3 ) + ( 3 ) * ( 1 ) + ( 3 ) * ( 2 ) + ( 3 ) * ( 3 );
 Real y;
equation
 y = 36.0;
end ArrayBuiltins.SumExp2;
")})));

 constant Real x = sum(i * j for i in 1:3, j in 1:3);
 Real y = x;
end SumExp2;


model SumExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SumExp3",
		 description="sum() expressions: reduction-expression over array",
		 flatModel="
fclass ArrayBuiltins.SumExp3
 constant Real x[1] = 1 + 1 + 1 + 2 + 2 + 2 + 3 + 3 + 3;
 constant Real x[2] = 2 + 3 + 4 + 2 + 3 + 4 + 2 + 3 + 4;
 Real y[1];
 Real y[2];
equation
 y[1] = 18.0;
 y[2] = 27.0;
end ArrayBuiltins.SumExp3;
")})));

 constant Real x[2] = sum({i, j} for i in 1:3, j in 2:4);
 Real y[2] = x;
end SumExp3;


model SumExp4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="SumExp4",
		 description="sum() expressions: over array constructor with iterators",
		 flatModel="
fclass ArrayBuiltins.SumExp4
 constant Real x = 1 + 2 + 1 + 3 + 1 + 4 + 2 + 2 + 2 + 3 + 2 + 4 + 3 + 2 + 3 + 3 + 3 + 4;
 Real y;
equation
 y = 45.0;
end ArrayBuiltins.SumExp4;
")})));

 constant Real x = sum( { {i, j} for i in 1:3, j in 2:4 } );
 Real y = x;
end SumExp4;


model SumExp5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="SumExp5",
		 description="sum() expressions: scalar input",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 1489, column 15:
  Calling function sum(): types of positional argument 1 and input A are not compatible
")})));

 Real x = sum(1);
end SumExp5;



model Transpose1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Transpose1",
		 description="Scalarization of transpose operator: Integer[2,2]",
		 flatModel="
fclass ArrayBuiltins.Transpose1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
equation
 x[1,1] = 1;
 x[1,2] = 3;
 x[2,1] = 2;
 x[2,2] = 4;
end ArrayBuiltins.Transpose1;
")})));

 Real x[2,2] = transpose({{1,2},{3,4}});
end Transpose1;


model Transpose2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Transpose2",
		 description="Scalarization of transpose operator: Integer[3,2]",
		 flatModel="
fclass ArrayBuiltins.Transpose2
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
equation
 x[1,1] = 1;
 x[1,2] = 3;
 x[1,3] = 5;
 x[2,1] = 2;
 x[2,2] = 4;
 x[2,3] = 6;
end ArrayBuiltins.Transpose2;
")})));

 Real x[2,3] = transpose({{1,2},{3,4},{5,6}});
end Transpose2;


model Transpose3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Transpose3",
		 description="Scalarization of transpose operator: Integer[1,2]",
		 flatModel="
fclass ArrayBuiltins.Transpose3
 Real x[1,1];
 Real x[2,1];
equation
 x[1,1] = 1;
 x[2,1] = 2;
end ArrayBuiltins.Transpose3;
")})));

 Real x[2,1] = transpose({{1,2}});
end Transpose3;


model Transpose4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Transpose4",
		 description="Scalarization of transpose operator: Integer[2,2,2]",
		 flatModel="
fclass ArrayBuiltins.Transpose4
 Integer x[1,1,1];
 Integer x[1,1,2];
 Integer x[1,2,1];
 Integer x[1,2,2];
 Integer x[2,1,1];
 Integer x[2,1,2];
 Integer x[2,2,1];
 Integer x[2,2,2];
equation
 x[1,1,1] = 1;
 x[1,1,2] = 2;
 x[1,2,1] = 5;
 x[1,2,2] = 6;
 x[2,1,1] = 3;
 x[2,1,2] = 4;
 x[2,2,1] = 7;
 x[2,2,2] = 8;
end ArrayBuiltins.Transpose4;
")})));

 Integer x[2,2,2] = transpose({{{1,2},{3,4}},{{5,6},{7,8}}});
end Transpose4;


model Transpose5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Transpose5",
		 description="Scalarization of transpose operator: too few dimensions of arg",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6377, column 15:
  Calling function transpose(): types of positional argument 1 and input A are not compatible
")})));

  Real x[2] = {1,2};
  Real y[2];
equation
  y=transpose(x)*x;
end Transpose5;


model Transpose6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Transpose6",
		 description="Scalarization of transpose operator: Integer",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 4876, column 24:
  Calling function transpose(): types of positional argument 1 and input A are not compatible
")})));

 Real x[2] = transpose(1);
end Transpose6;


model Transpose7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Transpose7",
		 description="Scalarization of transpose operator: Real[1,2] -> Integer[2,1]",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 4892, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[2,1] = transpose({{1.0,2}});
end Transpose7;



model Cross1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Cross1",
		 description="cross() operator: Real result",
		 flatModel="
fclass ArrayBuiltins.Cross1
 Real x[1];
 Real x[2];
 Real x[3];
equation
 x[1] = ( 2 ) * ( 6 ) - ( ( 3 ) * ( 5 ) );
 x[2] = ( 3 ) * ( 4 ) - ( ( 1.0 ) * ( 6 ) );
 x[3] = ( 1.0 ) * ( 5 ) - ( ( 2 ) * ( 4 ) );
end ArrayBuiltins.Cross1;
")})));

 Real x[3] = cross({1.0,2,3}, {4,5,6});
end Cross1; 


model Cross2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="Cross2",
		 description="cross() operator: Integer result",
		 flatModel="
fclass ArrayBuiltins.Cross2
 Integer x[3] = cross({1,2,3}, {4,5,6});
end ArrayBuiltins.Cross2;
")})));

 Integer x[3] = cross({1,2,3}, {4,5,6});
end Cross2; 


model Cross3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Cross3",
		 description="cross() operator: Real arg, assigning Integer component",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6359, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[3] = cross({1.0,2,3}, {4,5,6});
end Cross3; 


model Cross4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Cross4",
		 description="cross() operator: scalar arguments",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6401, column 20:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6401, column 23:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 Integer x = cross(1, 2);
end Cross4; 


model Cross5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Cross5",
		 description="cross() operator: Integer[4] arguments",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6437, column 23:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6437, column 34:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 Integer x[4] = cross({1,2,3,4}, {4,5,6,7});
end Cross5; 


model Cross6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Cross6",
		 description="cross() operator: String[3] arguments",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6456, column 22:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6456, column 37:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 String x[3] = cross({"1","2","3"}, {"4","5","6"});
end Cross6; 


model Cross7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Cross7",
		 description="cross() operator: too many dims",
		 errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6475, column 25:
  Calling function cross(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6475, column 52:
  Calling function cross(): types of positional argument 2 and input y are not compatible
")})));

 Integer x[3,3] = cross({{1,2,3},{1,2,3},{1,2,3}}, {{4,5,6},{4,5,6},{4,5,6}});
end Cross7; 



model ArrayCat1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayCat1",
		 description="cat() operator: basic test",
		 flatModel="
fclass ArrayBuiltins.ArrayCat1
 Real x[1,1];
 Real x[1,2];
 Real x[2,1];
 Real x[2,2];
 Real x[3,1];
 Real x[3,2];
 Real x[4,1];
 Real x[4,2];
 Real x[5,1];
 Real x[5,2];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[2,1] = 3;
 x[2,2] = 4;
 x[3,1] = 5;
 x[3,2] = 6;
 x[4,1] = 7;
 x[4,2] = 8;
 x[5,1] = 9;
 x[5,2] = 0;
end ArrayBuiltins.ArrayCat1;
")})));

 Real x[5,2] = cat(1, {{1,2},{3,4}}, {{5,6}}, {{7,8},{9,0}});
end ArrayCat1;


model ArrayCat2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayCat2",
		 description="cat() operator: basic test",
		 flatModel="
fclass ArrayBuiltins.ArrayCat2
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[1,4];
 Real x[1,5];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[2,4];
 Real x[2,5];
equation
 x[1,1] = 1.0;
 x[1,2] = 2.0;
 x[1,3] = 3;
 x[1,4] = 4;
 x[1,5] = 5;
 x[2,1] = 6;
 x[2,2] = 7;
 x[2,3] = 8;
 x[2,4] = 9;
 x[2,5] = 0;
end ArrayBuiltins.ArrayCat2;
")})));

 Real x[2,5] = cat(2, {{1.0,2.0},{6,7}}, {{3},{8}}, {{4,5},{9,0}});
end ArrayCat2;


model ArrayCat3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="ArrayCat3",
		 description="cat() operator: using strings",
		 flatModel="
fclass ArrayBuiltins.ArrayCat3
 String x[2,5] = cat(2, {{\"1\",\"2\"},{\"6\",\"7\"}}, {{\"3\"},{\"8\"}}, {{\"4\",\"5\"},{\"9\",\"0\"}});
end ArrayBuiltins.ArrayCat3;
")})));

 String x[2,5] = cat(2, {{"1","2"},{"6","7"}}, {{"3"},{"8"}}, {{"4","5"},{"9","0"}});
end ArrayCat3;


model ArrayCat4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat4",
		 description="cat() operator: size mismatch",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6656, column 19:
  Types do not match in array concatenation
")})));

 Integer x[5,2] = cat(2, {{1,2},{3,4}}, {{5,6,0}}, {{7,8},{9,0}});
end ArrayCat4;


model ArrayCat5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat5",
		 description="cat() operator: size mismatch",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6672, column 19:
  Types do not match in array concatenation
")})));

 Integer x[2,5] = cat(2, {{1,2},{6,7}}, {{3},{8},{0}}, {{4,5},{9,0}});
end ArrayCat5;


model ArrayCat6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat6",
		 description="cat() operator: type mismatch",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6688, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[2,5] = cat(2, {{1.0,2},{6,7}}, {{3},{8}}, {{4,5},{9,0}});
end ArrayCat6;


model ArrayCat6b
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat6b",
		 description="cat() operator: type mismatch",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6704, column 19:
  Types do not match in array concatenation
")})));

 Integer x[2,5] = cat(2, {{"1","2"},{"6","7"}}, {{3},{8}}, {{4,5},{9,0}});
end ArrayCat6b;


model ArrayCat7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat7",
		 description="cat() operator: to high variability of dim",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6721, column 17:
  Dimension argument of cat() does not have constant or parameter variability: d
")})));

 Integer d = 1;
 Integer x[4] = cat(d, {1,2}, {4,5});
end ArrayCat7;


model ArrayCat8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="ArrayCat8",
		 description="cat() operator: parameter dim",
		 flatModel="
fclass ArrayBuiltins.ArrayCat8
 parameter Integer d = 1 /* 1 */;
 Integer x[4] = cat(d, {1,2}, {4,5});
end ArrayBuiltins.ArrayCat8;
")})));

 parameter Integer d = 1;
 Integer x[4] = cat(d, {1,2}, {4,5});
end ArrayCat8;


model ArrayCat9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat9",
		 description="cat() operator: non-Integer dim",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6743, column 17:
  Dimension argument of cat() is not compatible with Integer: 1.0
")})));

 Integer x[4] = cat(1.0, {1,2}, {4,5});
end ArrayCat9;


model ArrayCat10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayCat10",
		 description="Records:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6797, column 15:
  Types do not match in array concatenation
")})));

  Real x[2] = cat(1, {1}, 2);
end ArrayCat10;



model ArrayShortCat1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayShortCat1",
		 description="Shorthand array concatenation operator: basic test",
		 flatModel="
fclass ArrayBuiltins.ArrayShortCat1
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[1,3] = 3;
 x[2,1] = 4;
 x[2,2] = 5;
 x[2,3] = 6;
end ArrayBuiltins.ArrayShortCat1;
")})));

 Real x[2,3] = [1,2,3; 4,5,6];
end ArrayShortCat1;

model ArrayShortCat2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayShortCat2",
		 description="Shorthand array concatenation operator: different sizes",
		 flatModel="
fclass ArrayBuiltins.ArrayShortCat2
 Real x[1,1];
 Real x[1,2];
 Real x[1,3];
 Real x[2,1];
 Real x[2,2];
 Real x[2,3];
 Real x[3,1];
 Real x[3,2];
 Real x[3,3];
equation
 x[1,1] = 1;
 x[1,2] = 2;
 x[1,3] = 3;
 x[2,1] = 4;
 x[3,1] = 7;
 x[2,2] = 5;
 x[2,3] = 6;
 x[3,2] = 8;
 x[3,3] = 9;
end ArrayBuiltins.ArrayShortCat2;
")})));

 Real x[3,3] = [a, b; c, d];
 Real a = 1;
 Real b[1,2] = {{2,3}};
 Real c[2] = {4,7};
 Real d[2,2] = {{5,6},{8,9}};
end ArrayShortCat2;


model ArrayShortCat3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayShortCat3",
		 description="Shorthand array concatenation operator: more than 2 dimensions",
		 flatModel="
fclass ArrayBuiltins.ArrayShortCat3
 Real x[1,1,1,1];
 Real x[1,1,2,1];
 Real x[1,2,1,1];
 Real x[1,2,2,1];
 Real x[2,1,1,1];
 Real x[2,1,2,1];
 Real x[2,2,1,1];
 Real x[2,2,2,1];
equation
 x[1,1,1,1] = 1;
 x[1,1,2,1] = 2;
 x[1,2,1,1] = 3;
 x[1,2,2,1] = 4;
 x[2,1,1,1] = 5;
 x[2,1,2,1] = 6;
 x[2,2,1,1] = 7;
 x[2,2,2,1] = 8;
end ArrayBuiltins.ArrayShortCat3;
")})));

 Real x[2,2,2,1] = [{{{{1},{2}}}}, {{{3,4}}}; {{{5,6}}}, {{{7,8}}}];
end ArrayShortCat3;


model ArrayShortCat4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayShortCat4",
		 description="Shorthand array concatenation operator:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6862, column 16:
  Types do not match in array concatenation
")})));

 Real x[2,3] = [{{1,2,3}}; {{4,5}}];
end ArrayShortCat4;


model ArrayShortCat5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayShortCat5",
		 description="Shorthand array concatenation operator:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6878, column 17:
  Types do not match in array concatenation
")})));

 Real x[3,2] = [{1,2,3}, {4,5}];
end ArrayShortCat5;



model ArrayEnd1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayEnd1",
		 description="end operator: basic test",
		 flatModel="
fclass ArrayBuiltins.ArrayEnd1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
 Real y[1];
 Real y[2];
equation
 x[1] = 1;
 x[2] = 2;
 x[3] = 3;
 x[4] = 4;
 y[1] = ( x[2] ) * ( 2 );
 y[2] = ( x[3] ) * ( 2 );
end ArrayBuiltins.ArrayEnd1;
")})));

 Real x[4] = {1,2,3,4};
 Real y[2] = x[2:end-1] * 2;
end ArrayEnd1;


model ArrayEnd2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ArrayEnd2",
		 description="End operator: using in wrong place",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 6924, column 15:
  The end operator may only be used in array subscripts
")})));

 Real x[4] = {1,2,3,4};
 Real y = 2 - end;
end ArrayEnd2;


model ArrayEnd3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayEnd3",
		 description="End operator: nestled array subscripts",
		 flatModel="
fclass ArrayBuiltins.ArrayEnd3
 constant Integer x1[1] = 1;
 constant Integer x1[2] = 2;
 constant Integer x1[3] = 3;
 constant Integer x1[4] = 4;
 Real x2[1];
 Real x2[4];
 Real x2[5];
 Real y[1];
 Real y[2];
equation
 x2[1] = 5;
 y[2] = 6;
 y[1] = 7;
 x2[4] = 8;
 x2[5] = 9;
end ArrayBuiltins.ArrayEnd3;
")})));

 constant Integer x1[4] = {1,2,3,4};
 Real x2[5] = {5,6,7,8,9};
 Real y[2] = x2[end.-x1[2:end-1]];
end ArrayEnd3;



model Linspace1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Linspace1",
		 description="Linspace operator: basic test",
		 flatModel="
fclass ArrayBuiltins.Linspace1
 Real x[1];
 Real x[2];
 Real x[3];
 Real x[4];
equation
 x[1] = 1 + ( 0 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
 x[2] = 1 + ( 1 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
 x[3] = 1 + ( 2 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
 x[4] = 1 + ( 3 ) * ( ( 3 - ( 1 ) ) / ( 3 ) );
end ArrayBuiltins.Linspace1;
")})));

 Real x[4] = linspace(1, 3, 4);
end Linspace1;


model Linspace2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Linspace2",
		 description="Linspace operator: using parameter component as n",
		 flatModel="
fclass ArrayBuiltins.Linspace2
 Real a;
 Real b;
 parameter Integer c = 3 /* 3 */;
 Real x[1];
 Real x[2];
 Real x[3];
equation
 a = 1;
 b = 2;
 x[1] = a + ( 0 ) * ( ( b - ( a ) ) / ( 2 ) );
 x[2] = a + ( 1 ) * ( ( b - ( a ) ) / ( 2 ) );
 x[3] = a + ( 2 ) * ( ( b - ( a ) ) / ( 2 ) );
end ArrayBuiltins.Linspace2;
")})));

 Real a = 1;
 Real b = 2;
 parameter Integer c = 3;
 Real x[3] = linspace(a, b, c);
end Linspace2;


model Linspace3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Linspace3",
		 description="Linspace operator: wrong type of n",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7033, column 29:
  Calling function linspace(): types of positional argument 3 and input n are not compatible
")})));

 Real a = 1;
 Real b = 2;
 parameter Real c = 3;
 Real x[3] = linspace(a, b, c);
end Linspace3;


model Linspace4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Linspace4",
		 description="Linspace operator: wrong variability of n",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7052, column 14:
  Type error in expression
")})));

 Real a = 1;
 Real b = 2;
 Integer c = 3;
 Real x[3] = linspace(a, b, c);
end Linspace4;


model Linspace5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Linspace5",
		 description="Linspace operator: using result as Integer",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7057, column 10:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 Integer x[4] = linspace(1, 3, 3);
end Linspace5;



model NdimsExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="NdimsExp1",
		 description="Ndims operator: basic test",
		 flatModel="
fclass ArrayBuiltins.NdimsExp1
 constant Integer n = 2;
 Integer x;
equation
 x = ( 2 ) * ( 2 );
end ArrayBuiltins.NdimsExp1;
")})));

 constant Integer n = ndims({{1,2},{3,4}});
 Integer x = n * 2;
end NdimsExp1;



model ArrayIfExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayIfExp1",
		 description="Array if expressions",
		 flatModel="
fclass ArrayBuiltins.ArrayIfExp1
 parameter Integer N = 3 /* 3 */;
 parameter Real A[1,1] = 1 /* 1.0 */;
 parameter Real A[1,2] = 0 /* 0.0 */;
 parameter Real A[1,3] = 0 /* 0.0 */;
 parameter Real A[2,1] = 0 /* 0.0 */;
 parameter Real A[2,2] = 1 /* 1.0 */;
 parameter Real A[2,3] = 0 /* 0.0 */;
 parameter Real A[3,1] = 0 /* 0.0 */;
 parameter Real A[3,2] = 0 /* 0.0 */;
 parameter Real A[3,3] = 1 /* 1.0 */;
 Real x[1](start = 1);
 Real x[2](start = 1);
 Real x[3](start = 1);
equation
 der(x[1]) = (if time >= 3 then ( ( A[1,1] ) * ( x[1] ) + ( A[1,2] ) * ( x[2] ) + ( A[1,3] ) * ( x[3] ) ) / ( N ) else ( (  - ( A[1,1] ) ) * ( x[1] ) + (  - ( A[1,2] ) ) * ( x[2] ) + (  - ( A[1,3] ) ) * ( x[3] ) ) / ( N ));
 der(x[2]) = (if time >= 3 then ( ( A[2,1] ) * ( x[1] ) + ( A[2,2] ) * ( x[2] ) + ( A[2,3] ) * ( x[3] ) ) / ( N ) else ( (  - ( A[2,1] ) ) * ( x[1] ) + (  - ( A[2,2] ) ) * ( x[2] ) + (  - ( A[2,3] ) ) * ( x[3] ) ) / ( N ));
 der(x[3]) = (if time >= 3 then ( ( A[3,1] ) * ( x[1] ) + ( A[3,2] ) * ( x[2] ) + ( A[3,3] ) * ( x[3] ) ) / ( N ) else ( (  - ( A[3,1] ) ) * ( x[1] ) + (  - ( A[3,2] ) ) * ( x[2] ) + (  - ( A[3,3] ) ) * ( x[3] ) ) / ( N ));
end ArrayBuiltins.ArrayIfExp1;
")})));

  parameter Integer N = 3;
  parameter Real A[N,N] = identity(N);
  Real x[N](each start = 1);
equation
  der(x) = if time>=3 then A*x/N else -A*x/N;
end ArrayIfExp1;


model ArrayIfExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="ArrayIfExp2",
		 description="Constant evaluation of if expression",
		 flatModel="
fclass ArrayBuiltins.ArrayIfExp2
 constant Real a = (if 1 > 2 then 5 elseif 1 < 2 then 6 else 7);
 Real b;
equation
 b = 6.0;
end ArrayBuiltins.ArrayIfExp2;
")})));

  constant Real a = if 1 > 2 then 5 elseif 1 < 2 then 6 else 7;
  Real b = a;
end ArrayIfExp2;



model Identity1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.TransformCanonicalTestCase(
		 name="Identity1",
		 description="identity() operator: basic test",
		 flatModel="
fclass ArrayBuiltins.Identity1
 parameter Real A[1,1] = 1 /* 1.0 */;
 parameter Real A[1,2] = 0 /* 0.0 */;
 parameter Real A[1,3] = 0 /* 0.0 */;
 parameter Real A[2,1] = 0 /* 0.0 */;
 parameter Real A[2,2] = 1 /* 1.0 */;
 parameter Real A[2,3] = 0 /* 0.0 */;
 parameter Real A[3,1] = 0 /* 0.0 */;
 parameter Real A[3,2] = 0 /* 0.0 */;
 parameter Real A[3,3] = 1 /* 1.0 */;
end ArrayBuiltins.Identity1;
")})));

  parameter Real A[3,3] = identity(3);
end Identity1;


model Identity2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Identity2",
		 description="identity() operator:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7207, column 18:
  Array size mismatch in declaration of A, size of declaration is [] and size of binding expression is [3, 3]
")})));

  parameter Real A = identity(3);
end Identity2;


model Identity3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Identity3",
		 description="identity() operator:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7224, column 27:
  Type error in expression
")})));

  Integer n = 3;
  parameter Real A[3,3] = identity(n);
end Identity3;


model Identity4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="Identity4",
		 description="identity() operator:",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7240, column 36:
  Calling function identity(): types of positional argument 1 and input n are not compatible
")})));

  parameter Real A[3,3] = identity(3.0);
end Identity4;



model ScalarSize1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.FlatteningTestCase(
		 name="ScalarSize1",
		 description="Size of zero-length vector",
		 flatModel="
fclass ArrayBuiltins.ScalarSize1
 Real x[1] = cat(1, {1}, size(3.141592653589793));
end ArrayBuiltins.ScalarSize1;
")})));

  Real x[1] = cat(1, {1}, size(Modelica.Constants.pi));
end ScalarSize1;


model ScalarSize2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
	 JModelica.UnitTesting.ErrorTestCase(
		 name="ScalarSize2",
		 description="Size of scalar dotted access",
		 errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ArrayBuiltins.mo':
Semantic error at line 7272, column 15:
  Type error in expression
")})));

  Real x[1] = {1} + Modelica.Constants.pi;
end ScalarSize2;



end ArrayBuiltins;