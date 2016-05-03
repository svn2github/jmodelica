/*
    Copyright (C) 2015 Modelon AB

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
package LibraryTests

model LibraryTest1
        extends TestLib.M;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="LibraryTest1",
            description="Test compiling with a custom library",
            modelicaLibraries="TestLib",
            flatModel="
fclass LibraryTests.LibraryTest1
 Real x;
equation
 x = time;
end LibraryTests.LibraryTest1;
")})));
end LibraryTest1;

model LibraryTest2
        extends TestLib.Sub.M;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="LibraryTest2",
            description="Test compiling with a custom library",
            modelicaLibraries="TestLib",
            flatModel="
fclass LibraryTests.LibraryTest2
 Real x;
equation
 x = time;
end LibraryTests.LibraryTest2;
")})));
end LibraryTest2;

model LibraryTest3
        extends EmptyLib.M;

    annotation(__JModelica(UnitTesting(tests={
        WarningTestCase(
            name="LibraryTest3",
            description="Empty top level package file",
            modelicaLibraries="EmptyLib",
            errorMessage="
1 errors and 1 warnings found:

Error at line 36, column 26, in file 'Compiler/ModelicaCompiler/src/test/LibraryTests.mo':
  Cannot find class declaration for M

Warning at line 0, column 0, in file 'Compiler/ModelicaCompiler/src/test/EmptyLib':
  Empty structured entity, package is omitted
")})));
end LibraryTest3;

end LibraryTests;
