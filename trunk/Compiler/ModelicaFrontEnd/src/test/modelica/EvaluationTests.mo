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

package EvaluationTests
	model VectorMul
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="VectorMul",
         description="Check that constant evaluation for vector multiplication succeeds",
         flatModel="
fclass EvaluationTests.VectorMul
 parameter Integer n = 3 /* 3 */;
 parameter Real x[3] = 1:n;
 parameter Real y[3] = n: - ( 1 ):1;
 parameter Real z = ( x[1:3] ) * ( y[1:3] );
 Real q = z;
end EvaluationTests.VectorMul;
")})));

		parameter Integer n = 3;
		parameter Real x[n] = 1:n;
		parameter Real y[n] = n:-1:1;
		parameter Real z = x * y;
		Real q = z;
	end VectorMul;
end EvaluationTests;
