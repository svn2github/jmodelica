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



// TODO: Binding expressions
// TODO: Arrays (inkl modifiers - each, etc)



end RecordTests;
