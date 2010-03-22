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

package RecordTests



model RecordFlat1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordFlat1",
         description="Records: basic flattening test",
         flatModel="
fclass RecordTests.RecordFlat1
 RecordTests.RecordFlat1.A x;
 RecordTests.RecordFlat1.A y;
equation
 y = x;

 record RecordTests.RecordFlat1.A
  Real a;
  Real b;
 end RecordTests.RecordFlat1.A;
end RecordTests.RecordFlat1;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
end RecordFlat1;


model RecordFlat2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordFlat2",
         description="Records: accessing components",
         flatModel="
fclass RecordTests.RecordFlat2
 RecordTests.RecordFlat2.A x;
 RecordTests.RecordFlat2.A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;

 record RecordTests.RecordFlat2.A
  Real a;
  Real b;
 end RecordTests.RecordFlat2.A;
end RecordTests.RecordFlat2;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;
end RecordFlat2;


model RecordFlat3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordFlat3",
         description="Records: modification",
         flatModel="
fclass RecordTests.RecordFlat3
 RecordTests.RecordFlat3.A x(a = 1,b = 2);
 RecordTests.RecordFlat3.A y;
equation
 y = x;

 record RecordTests.RecordFlat3.A
  Real a;
  Real b;
 end RecordTests.RecordFlat3.A;
end RecordTests.RecordFlat3;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x(a=1, b=2);
 A y;
equation
 y = x;
end RecordFlat3;


model RecordFlat4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordFlat4",
         description="Records: two records",
         flatModel="
fclass RecordTests.RecordFlat4
 RecordTests.RecordFlat4.B y;
 RecordTests.RecordFlat4.A x;

 record RecordTests.RecordFlat4.B
  Real c;
  Real d;
 end RecordTests.RecordFlat4.B;

 record RecordTests.RecordFlat4.A
  Real a;
  Real b;
 end RecordTests.RecordFlat4.A;
end RecordTests.RecordFlat4;
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real c;
  Real d;
 end B;
 
 B y;
 A x;
end RecordFlat4;


model RecordFlat5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordFlat5",
         description="Records: nestled records",
         flatModel="
fclass RecordTests.RecordFlat5
 RecordTests.RecordFlat5.A x;

 record RecordTests.RecordFlat5.B
  Real c;
  Real d;
 end RecordTests.RecordFlat5.B;

 record RecordTests.RecordFlat5.A
  Real a;
  RecordTests.RecordFlat5.B b;
 end RecordTests.RecordFlat5.A;
end RecordTests.RecordFlat5;
")})));

 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
  Real d;
 end B;
 
 A x;
end RecordFlat5;



model RecordType1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordType1",
         description="Records: equivalent types",
         flatModel="
fclass RecordTests.RecordType1
 RecordTests.RecordType1.A x;
 RecordTests.RecordType1.B y;
equation
 y = x;

 record RecordTests.RecordType1.A
  Real a;
  Real b;
 end RecordTests.RecordType1.A;

 record RecordTests.RecordType1.B
  Real a;
  Real b;
 end RecordTests.RecordType1.B;
end RecordTests.RecordType1;
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 A x;
 B y;
equation
 y = x;
end RecordType1;


model RecordType2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordType2",
         description="Records: non-equivalent types (component name)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 246, column 2:
  The right and left expression types of equation are not compatible
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 A x;
 B y;
equation
 y = x;
end RecordType2;


model RecordType3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordType3",
         description="Records: non-equivalent types (component type)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 275, column 2:
  The right and left expression types of equation are not compatible
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Boolean b;
 end B;
 
 A x;
 B y;
equation
 y = x;
end RecordType3;


model RecordType4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordType4",
         description="Records: equivalent nested types",
         flatModel="
fclass RecordTests.RecordType4
 RecordTests.RecordType4.C x;
 RecordTests.RecordType4.D y;
equation
 y = x;

 record RecordTests.RecordType4.A
  Real a;
  Real b;
 end RecordTests.RecordType4.A;

 record RecordTests.RecordType4.C
  RecordTests.RecordType4.A a;
  Real e;
 end RecordTests.RecordType4.C;

 record RecordTests.RecordType4.B
  Real a;
  Real b;
 end RecordTests.RecordType4.B;

 record RecordTests.RecordType4.D
  RecordTests.RecordType4.B a;
  Real e;
 end RecordTests.RecordType4.D;
end RecordTests.RecordType4;
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 record C
  A a;
  Real e;
 end C;

 record D
  B a;
  Real e;
 end D;
 
 C x;
 D y;
equation
 y = x;
end RecordType4;


model RecordType5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordType5",
         description="Records: non-equivalent nested types",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 342, column 2:
  The right and left expression types of equation are not compatible
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 record C
  A a;
  Real e;
 end C;

 record D
  B a;
  Real e;
 end D;
 
 C x;
 D y;
equation
 y = x;
end RecordType5;



model RecordBinding1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordBinding1",
         description="Records: binding expression, same record type",
         flatModel="
fclass RecordTests.RecordBinding1
 RecordTests.RecordBinding1.A x = y;
 RecordTests.RecordBinding1.A y;

 record RecordTests.RecordBinding1.A
  Real a;
  Real b;
 end RecordTests.RecordBinding1.A;
end RecordTests.RecordBinding1;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x = y;
 A y;
end RecordBinding1;


model RecordBinding2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordBinding2",
         description="Records: binding expression, equivalent record type",
         flatModel="
fclass RecordTests.RecordBinding2
 RecordTests.RecordBinding2.A x = y;
 RecordTests.RecordBinding2.B y;

 record RecordTests.RecordBinding2.A
  Real a;
  Real b;
 end RecordTests.RecordBinding2.A;

 record RecordTests.RecordBinding2.B
  Real a;
  Real b;
 end RecordTests.RecordBinding2.B;
end RecordTests.RecordBinding2;
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 A x = y;
 B y;
end RecordBinding2;


model RecordBinding3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordBinding3",
         description="Records: binding expression, wrong type (incompatible record)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 466, column 4:
  The binding expression of the variable x does not match the declared type of the variable
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real a;
  Real c;
 end B;
 
 A x = y;
 B y;
end RecordBinding3;


model RecordBinding4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordBinding4",
         description="Records: binding expression, wrong array size",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 499, column 4:
  Array size mismatch in declaration of x, size of declaration is [] and size of binding expression is [2]
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x = y;
 A y[2];
end RecordBinding4;


model RecordBinding5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordBinding5",
         description="Records: wrong type of binding exp of component",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 507, column 8:
  The binding expression of the variable b does not match the declared type of the variable
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x(a = 1, b = "foo");
end RecordBinding5;



model RecordArray1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordArray1",
         description="Record containing array: modification",
         flatModel="
fclass RecordTests.RecordArray1
 RecordTests.RecordArray1.A x(a = {1,2},b = 1);

 record RecordTests.RecordArray1.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray1.A;
end RecordTests.RecordArray1;
")})));

 record A
  Real a[2];
  Real b;
 end A;
 
 A x(a={1,2}, b=1);
end RecordArray1;


model RecordArray2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordArray2",
         description="Record containing array: equation with access",
         flatModel="
fclass RecordTests.RecordArray2
 RecordTests.RecordArray2.A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

 record RecordTests.RecordArray2.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray2.A;
end RecordTests.RecordArray2;
")})));

 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;
end RecordArray2;


model RecordArray3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordArray3",
         description="Record containing array: equation with other record",
         flatModel="
fclass RecordTests.RecordArray3
 RecordTests.RecordArray3.A x;
 RecordTests.RecordArray3.A y;
equation
 x = y;

 record RecordTests.RecordArray3.A
  Real a[2];
  Real b;
 end RecordTests.RecordArray3.A;
end RecordTests.RecordArray3;
")})));

 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
 A y;
equation
 x = y;
end RecordArray3;


model RecordArray4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordArray4",
         description="Array of records: modification",
         flatModel="
fclass RecordTests.RecordArray4
 RecordTests.RecordArray4.A x[2](each a = 1,b = {1,2});

 record RecordTests.RecordArray4.A
  Real a;
  Real b;
 end RecordTests.RecordArray4.A;
end RecordTests.RecordArray4;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x[2](each a=1, b={1,2});
end RecordArray4;


model RecordArray5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordArray5",
         description="Array of records: accesses",
         flatModel="
fclass RecordTests.RecordArray5
 RecordTests.RecordArray5.A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

 record RecordTests.RecordArray5.A
  Real a;
  Real b;
 end RecordTests.RecordArray5.A;
end RecordTests.RecordArray5;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;
end RecordArray5;



model RecordConstructor1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordConstructor1",
         description="Record constructors: basic test",
         flatModel="
fclass RecordTests.RecordConstructor1
 RecordTests.RecordConstructor1.A x = RecordTests.RecordConstructor1.A(1.0, 2, \"foo\");

 record RecordTests.RecordConstructor1.A
  Real a;
  Integer b;
  String c;
 end RecordTests.RecordConstructor1.A;
end RecordTests.RecordConstructor1;
")})));

 record A
  Real a;
  Integer b;
  String c;
 end A;
 
 A x = A(1.0, 2, "foo");
end RecordConstructor1;


model RecordConstructor2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordConstructor2",
         description="Record constructors: named args",
         flatModel="
fclass RecordTests.RecordConstructor2
 RecordTests.RecordConstructor2.A x = RecordTests.RecordConstructor2.A(1.0, 2, \"foo\");

 record RecordTests.RecordConstructor2.A
  Real a;
  Integer b;
  String c;
 end RecordTests.RecordConstructor2.A;
end RecordTests.RecordConstructor2;
")})));

 record A
  Real a;
  Integer b;
  String c;
 end A;
 
 A x = A(c="foo", a=1.0, b=2);
end RecordConstructor2;


model RecordConstructor3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordConstructor3",
         description="Record constructors: default args",
         flatModel="
fclass RecordTests.RecordConstructor3
 RecordTests.RecordConstructor3.A x = RecordTests.RecordConstructor3.A(1, 2, \"foo\");

 record RecordTests.RecordConstructor3.A
  Real a;
  Integer b = 0;
  String c = \"foo\";
 end RecordTests.RecordConstructor3.A;
end RecordTests.RecordConstructor3;
")})));

 record A
  Real a;
  Integer b = 0;
  String c = "foo";
 end A;
 
 A x = A(1, 2);
end RecordConstructor3;


model RecordConstructor4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordConstructor4",
         description="Record constructors: wrong type of arg",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 764, column 18:
  Record constructor for A: types of positional argument 3 and input c are not compatible
")})));

 record A
  Real a;
  Integer b;
  String c;
 end A;
 
 A x = A(1.0, 2, 3);
end RecordConstructor4;


model RecordConstructor5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordConstructor5",
         description="Record constructors: too few args",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 786, column 8:
  Record constructor for A: missing argument for required input c
")})));

 record A
  Real a;
  Integer b;
  String c;
 end A;
 
 A x = A(1.0, 2);
end RecordConstructor5;


model RecordConstructor6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="RecordConstructor6",
         description="Record constructors: too many args",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 808, column 25:
  Record constructor for A: too many positional arguments
")})));

 record A
  Real a;
  Integer b;
  String c;
 end A;
 
 A x = A(1.0, 2, "foo", 0);
end RecordConstructor6;



// TODO: When it is possible to set compiler options in tests, use eliminate_alias_variables=false for these
model RecordScalarize1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize1",
         description="Scalarization of records: modification",
         flatModel="
fclass RecordTests.RecordScalarize1
 Real y.a;
 Real y.b;
equation
 y.a = 1;
 y.b = 2;

 record RecordTests.RecordScalarize1.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize1.A;
end RecordTests.RecordScalarize1;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x(a=1, b=2);
 A y;
equation
 y = x;
end RecordScalarize1;


model RecordScalarize2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize2",
         description="Scalarization of records: basic test",
         flatModel="
fclass RecordTests.RecordScalarize2
 Real y.a;
 Real y.b;
equation
 y.a = 1;
 y.b = 2;

 record RecordTests.RecordScalarize2.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize2.A;
end RecordTests.RecordScalarize2;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x;
 A y;
equation
 y = x;
 x.a = 1;
 x.b = 2;
end RecordScalarize2;


model RecordScalarize3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize3",
         description="Scalarization of records: record constructor",
         flatModel="
fclass RecordTests.RecordScalarize3
 Real y.a;
 Real y.b;
equation
 y.a = 1;
 y.b = 2;

 record RecordTests.RecordScalarize3.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize3.A;
end RecordTests.RecordScalarize3;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x = A(1, 2);
 A y;
equation
 y = x;
end RecordScalarize3;


model RecordScalarize4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize4",
         description="Scalarization of records: two different records, record constructors",
         flatModel="
fclass RecordTests.RecordScalarize4
 Real x.a;
 Real x.b;
 Real y.c;
 Real y.d;
equation
 x.a = 1;
 x.b = 2;
 y.c = 3;
 y.d = 4;

 record RecordTests.RecordScalarize4.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize4.A;

 record RecordTests.RecordScalarize4.B
  Real c;
  Real d;
 end RecordTests.RecordScalarize4.B;
end RecordTests.RecordScalarize4;
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real c;
  Real d;
 end B;
 
 A x = A(1, 2);
 B y = B(3, 4);
end RecordScalarize4;


model RecordScalarize5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize5",
         description="Scalarization of records: nestled records",
         flatModel="
fclass RecordTests.RecordScalarize5
 Real x.a;
 Real x.b.c;
 Real x.b.d;
equation
 x.a = 1;
 x.b.c = 2;
 x.b.d = 3;

 record RecordTests.RecordScalarize5.B
  Real c;
  Real d;
 end RecordTests.RecordScalarize5.B;

 record RecordTests.RecordScalarize5.A
  Real a;
  RecordTests.RecordScalarize5.B b;
 end RecordTests.RecordScalarize5.A;
end RecordTests.RecordScalarize5;
")})));

 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
  Real d;
 end B;
 
 A x = A(1, y);
 B y = B(2, 3);
end RecordScalarize5;


model RecordScalarize6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize6",
         description="Scalarization of records: equivalent records",
         flatModel="
fclass RecordTests.RecordScalarize6
 Real y.b;
 Real y.a;
equation
 y.a = 1;
 y.b = 2;

 record RecordTests.RecordScalarize6.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize6.A;

 record RecordTests.RecordScalarize6.B
  Real b;
  Real a;
 end RecordTests.RecordScalarize6.B;
end RecordTests.RecordScalarize6;
")})));

 record A
  Real a;
  Real b;
 end A;

 record B
  Real b;
  Real a;
 end B;
 
 A x = B(2, 1);
 B y;
equation
 y = x;
end RecordScalarize6;


model RecordScalarize7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize7",
         description="Scalarization of records: equivalent nestled records",
         flatModel="
fclass RecordTests.RecordScalarize7
 Real y.x.a;
 Real y.x.b;
 Real y.c;
equation
 y.c = 1;
 y.x.a = 2;
 y.x.b = 3;

 record RecordTests.RecordScalarize7.A
  Real b;
  Real a;
 end RecordTests.RecordScalarize7.A;

 record RecordTests.RecordScalarize7.C
  Real c;
  RecordTests.RecordScalarize7.A x;
 end RecordTests.RecordScalarize7.C;

 record RecordTests.RecordScalarize7.B
  Real a;
  Real b;
 end RecordTests.RecordScalarize7.B;

 record RecordTests.RecordScalarize7.D
  RecordTests.RecordScalarize7.B x;
  Real c;
 end RecordTests.RecordScalarize7.D;
end RecordTests.RecordScalarize7;
")})));

 record A
  Real b;
  Real a;
 end A;

 record B
  Real a;
  Real b;
 end B;
 
 record C
  Real c;
  A x;
 end C;

 record D
  B x;
  Real c;
 end D;
 
 C x = C(1, B(2, 3));
 D y;
equation
 y = x;
end RecordScalarize7;


model RecordScalarize8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize8",
         description="Scalarization of records: modification of array component",
         flatModel="
fclass RecordTests.RecordScalarize8
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

 record RecordTests.RecordScalarize8.A
  Real a[2];
  Real b;
 end RecordTests.RecordScalarize8.A;
end RecordTests.RecordScalarize8;
")})));

 record A
  Real a[2];
  Real b;
 end A;
 
 A x(a={1,2}, b=1);
end RecordScalarize8;


model RecordScalarize9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize9",
         description="Scalarization of records: record containing array",
         flatModel="
fclass RecordTests.RecordScalarize9
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;

 record RecordTests.RecordScalarize9.A
  Real a[2];
  Real b;
 end RecordTests.RecordScalarize9.A;
end RecordTests.RecordScalarize9;
")})));

 record A
  Real a[2];
  Real b;
 end A;
 
 A x;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 1;
end RecordScalarize9;


model RecordScalarize10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize10",
         description="Scalarization of records: record containing array, using record constructor",
         flatModel="
fclass RecordTests.RecordScalarize10
 Real x.a[1];
 Real x.a[2];
 Real x.b;
equation
 x.a[1] = 1;
 x.a[2] = 2;
 x.b = 3;

 record RecordTests.RecordScalarize10.A
  Real a[2];
  Real b;
 end RecordTests.RecordScalarize10.A;
end RecordTests.RecordScalarize10;
")})));

 record A
  Real a[2];
  Real b;
 end A;
 
 A x = A({1,2}, 3);
 A y;
equation
 x = y;
end RecordScalarize10;


model RecordScalarize11
 record A
  Real a;
  Real b;
 end A;
 
 A x[2](each a=1, b={1,2});
end RecordScalarize11;


model RecordScalarize12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="RecordScalarize12",
         description="Scalarization of records: array of records",
         flatModel="
fclass RecordTests.RecordScalarize12
 RecordTests.RecordScalarize12.A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

 record RecordTests.RecordScalarize12.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize12.A;
end RecordTests.RecordScalarize12;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x[2];
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;
end RecordScalarize12;


model RecordScalarize13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize13",
         description="Scalarization of records: arrays of records, binding exp + record equation",
         flatModel="
fclass RecordTests.RecordScalarize13
 Real x[1].a;
 Real x[1].b;
 Real x[2].a;
 Real x[2].b;
equation
 x[1].a = 1;
 x[1].b = 2;
 x[2].a = 3;
 x[2].b = 4;

 record RecordTests.RecordScalarize13.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize13.A;
end RecordTests.RecordScalarize13;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x[2] = {A(1,2), A(3,4)};
 A y[2];
equation
 x = y;
end RecordScalarize13;


model RecordScalarize14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize14",
         description="Scalarization of records: nestled records and arrays",
         flatModel="
fclass RecordTests.RecordScalarize14
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[1].b[2].a[1];
 Real x[1].b[2].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
equation
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 x[1].b[2].a[1] = 3;
 x[1].b[2].a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;

 record RecordTests.RecordScalarize14.B
  Real a[2];
 end RecordTests.RecordScalarize14.B;

 record RecordTests.RecordScalarize14.A
  RecordTests.RecordScalarize14.B b[2];
 end RecordTests.RecordScalarize14.A;
end RecordTests.RecordScalarize14;
")})));

 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 A y[2];
equation
 x = y;
end RecordScalarize14;


model RecordScalarize15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize15",
         description="Scalarization of records: access of nestled primitive",
         flatModel="
fclass RecordTests.RecordScalarize15
 Real x[1].b[1].a[1];
 Real x[1].b[2].a[1];
 Real x[1].b[2].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y;
equation
 x[1].b[1].a[1] = 1;
 y = 2;
 x[1].b[2].a[1] = 3;
 x[1].b[2].a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;

 record RecordTests.RecordScalarize15.B
  Real a[2];
 end RecordTests.RecordScalarize15.B;

 record RecordTests.RecordScalarize15.A
  RecordTests.RecordScalarize15.B b[2];
 end RecordTests.RecordScalarize15.A;
end RecordTests.RecordScalarize15;
")})));

 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 Real y = x[1].b[1].a[2];
end RecordScalarize15;


model RecordScalarize16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize16",
         description="Scalarization of records: access of nested record",
         flatModel="
fclass RecordTests.RecordScalarize16
 Real x[1].b[1].a[1];
 Real x[1].b[1].a[2];
 Real x[2].b[1].a[1];
 Real x[2].b[1].a[2];
 Real x[2].b[2].a[1];
 Real x[2].b[2].a[2];
 Real y.a[1];
 Real y.a[2];
equation
 x[1].b[1].a[1] = 1;
 x[1].b[1].a[2] = 2;
 y.a[1] = 3;
 y.a[2] = 4;
 x[2].b[1].a[1] = 5;
 x[2].b[1].a[2] = 6;
 x[2].b[2].a[1] = 7;
 x[2].b[2].a[2] = 8;

 record RecordTests.RecordScalarize16.B
  Real a[2];
 end RecordTests.RecordScalarize16.B;

 record RecordTests.RecordScalarize16.A
  RecordTests.RecordScalarize16.B b[2];
 end RecordTests.RecordScalarize16.A;
end RecordTests.RecordScalarize16;
")})));

 record A
  B b[2];
 end A;
 
 record B
  Real a[2];
 end B;
 
 A x[2] = { A({ B({1,2}), B({3,4}) }), A({ B({5,6}), B({7,8}) }) };
 B y = x[1].b[2];
end RecordScalarize16;


model RecordScalarize17
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize17",
         description="Scalarization of records: attribute on primitive in record",
         flatModel="
fclass RecordTests.RecordScalarize17
 Real x.a;
 Real x.b(start = 3);
equation
 x.a = 1;
 x.b = 2;

 record RecordTests.RecordScalarize17.A
  Real a;
  Real b;
 end RecordTests.RecordScalarize17.A;
end RecordTests.RecordScalarize17;
")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x(b(start=3)) = A(1,2);
end RecordScalarize17;


model RecordScalarize18
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.TransformCanonicalTestCase(
         name="RecordScalarize18",
         description="Scalarization of records: attributes on primitives in nestled records",
         flatModel="
fclass RecordTests.RecordScalarize18
 Real x.b1.a(start = 3);
 Real x.b2.a(start = 4);
equation
 x.b1.a = 1;
 x.b2.a = 2;

 record RecordTests.RecordScalarize18.A
  Real a;
 end RecordTests.RecordScalarize18.A;

 record RecordTests.RecordScalarize18.B
  RecordTests.RecordScalarize18.A b1;
  RecordTests.RecordScalarize18.A b2;
 end RecordTests.RecordScalarize18.B;
end RecordTests.RecordScalarize18;
")})));

 record A
  Real a;
 end A;
 
 record B
  A b1;
  A b2;
 end B;
 
 B x(b1(a(start=3)), b2.a(start=4)) = B(A(1),A(2));
end RecordScalarize18;

// TODO: Add more complicated combinations of arrays, records and modifiers
// TODO: Add modifier setting attributes



end RecordTests;
