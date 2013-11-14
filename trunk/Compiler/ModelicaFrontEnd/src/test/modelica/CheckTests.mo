/*
    Copyright (C) 2011-2013 Modelon AB

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

package CheckTests
	
model InnerOuter1
    outer Real x;
equation
    x = true; // To generate another error to show up in an error check

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="InnerOuterTest14_Err",
            description="Check that error is not generated for outer without inner in check mode",
            checkType="check",
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 22, column 5:
  The right and left expression types of equation are not compatible
")})));
end InnerOuter1;


model ConditionalError1
	model A
		Real x = true;
	end A;
	
	A a if b;
	parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		ErrorTestCase(
			name="ConditionalError1",
			description="Check that errors in conditional components are found in check mode",
            checkType="check",
			errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 40, column 12:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ConditionalError1;


model ConditionalError2
    model A
        Real x = true;
    end A;
    
    A a if b;
    parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalError2",
			description="Check that inactive conditional components aren't error checked in compile mode",
			flatModel="
fclass CheckTests.ConditionalError2
 parameter Boolean b = false /* false */;
end CheckTests.ConditionalError2;
")})));
end ConditionalError2;


model ConditionalError3
	type B = enumeration(c, d);
	
	function f
		input Real x;
		output Real y;
	algorithm
		y := x * x;
	end f;
	
    model A
        B x = if f(time) > 2 then B.c else B.d;
    end A;
    
    A a if b;
    parameter Boolean b = false;

	annotation(__JModelica(UnitTesting(tests={
		FlatteningTestCase(
			name="ConditionalError3",
			description="Check that inactive conditional components aren't searched for used functions and enums when flattening in compile mode",
			flatModel="
fclass CheckTests.ConditionalError3
 parameter Boolean b = false /* false */;
end CheckTests.ConditionalError3;
")})));
end ConditionalError3;


model ConditionalError4
    model A
        Real x = true;
    end A;
    
    A a if b;
    parameter Boolean b = false;

    annotation(__JModelica(UnitTesting(tests={
        ErrorTestCase(
            name="ConditionalError4",
            description="Check that errors in conditional components are found in compile mode when using the check_inactive_contitionals option",
            check_inactive_contitionals=true,
            errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/CheckTests.mo':
Semantic error at line 111, column 12:
  The binding expression of the variable x does not match the declared type of the variable
")})));
end ConditionalError4;

end CheckTests;
