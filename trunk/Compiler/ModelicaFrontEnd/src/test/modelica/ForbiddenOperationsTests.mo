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


package ForbiddenOperationsTests


model ComplexExpInDer1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ComplexExpInDer1",
        description="Error when using complex expression in der().",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 35, column 2:
  Expressions within der() not supported
")})));

 Real x;
 Real y;
equation
 der(x * y) = 0;
end ComplexExpInDer1;

model ComplexExpInDer2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="ComplexExpInDer2",
        description="Error when using complex expression in der().",
                                               errorMessage=
"
Error: in file '/Users/jakesson/projects/JModelica/Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 50, column 2:
  Expressions within der() not supported
")})));

 Real x;
equation
 der(der(x)) = 0;
end ComplexExpInDer2;


/* ================ Algorithms =============== */

function WhenInFunction_Func
 input Real i1;
 output Real o1 = 1.0;
algorithm
 when i1 > 1.0 then
  o1 := 2.0;
 end when;
end WhenInFunction_Func;

model WhenInFunction
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenInFunction",
         description="Content checks in algorithms: when in function",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 60, column 2:
  When statements are not allowed in functions
")})));

 Real x = WhenInFunction_Func(1);
end WhenInFunction;

model WhenInBlocks1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenInBlocks1",
         description="Content checks in algorithms: when inside if clause",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 84, column 3:
  When statements are not allowed inside if, for, while and when clauses
")})));

 Real x;
algorithm
 if x < 1 then
  when x < 0.5 then
   x := 0.8;
  end when;
 end if;
end WhenInBlocks1;

model WhenInBlocks2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenInBlocks2",
         description="Content checks in algorithms: when inside when clause",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 84, column 3:
  When statements are not allowed inside if, for, while and when clauses
")})));

 Real x;
algorithm
 when x < 1 then
  when x < 0.5 then
   x := 0.8;
  end when;
 end when;
end WhenInBlocks2;

model WhenInBlocks3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenInBlocks3",
         description="Content checks in algorithms: when inside while clause",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 84, column 3:
  When statements are not allowed inside if, for, while and when clauses
")})));

 Real x;
algorithm
 while x < 1 loop
  when x < 0.5 then
   x := 0.8;
  end when;
 end while;
end WhenInBlocks3;

model WhenInBlocks4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="WhenInBlocks4",
         description="Content checks in algorithms: when inside for clause",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 84, column 3:
  When statements are not allowed inside if, for, while and when clauses
")})));

 Real x;
algorithm
 for i in 1:3 loop
  when x < 0.5 then
   x := 0.8;
  end when;
 end for;
end WhenInBlocks4;

model ReturnOutsideFunction
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="ReturnOutsideFunction",
         description="Content checks in algorithms: return outside function",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Semantic error at line 166, column 2:
  Return statements are only allowed in functions
")})));

algorithm
 return;
end ReturnOutsideFunction;

model IfEquTest_ComplErr
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="IfEquTest_ComplErr",
         description="",
         errorMessage="
2 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Compliance error at line 194, column 10:
  Boolean variables are not supported, only constants and parameters
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/ForbiddenOperationsTests.mo':
Compliance error at line 196, column 2:
  If equations are currently only supported with constant or parameter test expressions
")})));

 Real x;
 Boolean y = true;
equation
 if y then
   x=3;
 else
   x=5;
 end if;

end IfEquTest_ComplErr;


end ForbiddenOperationsTests;
