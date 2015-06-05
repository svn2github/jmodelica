/*
    Copyright (C) 2009-2015 Modelon AB

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

package DerivativeVariablePropagation

    model RewriteTest1
        Real a, b, c;
    equation
        a = der(c);
        b = -c;
        b = time;
        annotation(__JModelica(UnitTesting(tests={
            TransformCanonicalTestCase(
                name="RewriteTest1",
                description="A simple case that tests a simple derivative rewrite",
                flatModel="
fclass DerivativeVariablePropagation.RewriteTest1
 Real a;
 Real b;
 Real _der_b;
equation
 a = - _der_b;
 b = time;
 _der_b = 1.0;
end DerivativeVariablePropagation.RewriteTest1;
    ")})));
    end RewriteTest1;
    
end DerivativeVariablePropagation;
