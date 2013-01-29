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

model SimplifyLitExps1
	Real x1;
	Boolean x2;
equation
	x1 = 1 + 2 * 3 - 4 / 8 + 6 * 7 - 8 * 9;
	x2 = true and false or true or false and true;

	annotation(__JModelica(UnitTesting(tests={
		TransformCanonicalTestCase(
			name="SimplifyLitExps1",
			description="",
			constant_propagation=true,
			flatModel="
fclass ConstantPropagationTests.SimplifyLitExps1
 Real x1;
 discrete Boolean x2;
initial equation 
 pre(x2) = false;
equation
 x1 = -23.5;
 x2 = true;
end ConstantPropagationTests.SimplifyLitExps1;
")})));
end SimplifyLitExps1;

end ConstantPropagationTests;
