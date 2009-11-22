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

end ForbiddenOperationsTests;
