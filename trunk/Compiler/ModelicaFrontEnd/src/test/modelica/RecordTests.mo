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
         description="Records: binding expression, wrong type (array)",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/RecordTests.mo':
Semantic error at line 488, column 4:
  The binding expression of the variable x does not match the declared type of the variable
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
 RecordTests.RecordConstructor1.A x = A(1.0, 2, \"foo\");

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
 RecordTests.RecordConstructor2.A x = A(1.0, 2, \"foo\");

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
 RecordTests.RecordConstructor3.A x = A(1, 2, \"foo\");

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



end RecordTests;
