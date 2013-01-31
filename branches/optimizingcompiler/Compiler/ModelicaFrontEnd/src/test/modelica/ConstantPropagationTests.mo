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

package ConstantPropagationTests

model VariabilityInference
	Real x1;
	Boolean x2;
equation
	x1 = 1;
	x2 = true;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="VariabilityInference",
			description="",
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.VariabilityInference
 constant Real x1 = 1;
 constant Boolean x2 = true;
end ConstantPropagationTests.VariabilityInference;
")})));
end VariabilityInference;

model SimplifyLitExps
	Real x1;
	Boolean x2;
equation
	x1 = 1 + 2 * 3 - 4 / 8 + 6 * 7 - 8 * 9;
	x2 = true and false or true or false and true;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SimplifyLitExps",
			description="",
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.SimplifyLitExps
 constant Real x1 = -23.5;
 constant Boolean x2 = true;
end ConstantPropagationTests.SimplifyLitExps;
")})));
end SimplifyLitExps;

model ConstantSubstitution
	Real x1,x2,x3,x4;
equation
	x1 = 1;
	x2 = x3;
	x3 = x1;
	x4 = x2;
	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="ConstantSubstitution",
			description="",
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.ConstantSubstitution
 constant Real x1 = 1;
 constant Real x2 = 1;
 constant Real x3 = 1;
 constant Real x4 = 1;
end ConstantPropagationTests.ConstantSubstitution;
")})));
end ConstantSubstitution;

end ConstantPropagationTests;
