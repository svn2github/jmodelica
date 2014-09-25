/*
    Copyright (C) 2009-2014 Modelon AB

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

package OverdeterminedInitialSystem
    
    model Basic1
        Integer a;
        Integer b;
    initial equation
        pre(a) = 0;
        pre(b) = 0;
    equation
        a = b;
        b = if time > 0 then 1 else 0;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic1",
            description="A basic test",
            flatModel="
fclass OverdeterminedInitialSystem.Basic1
 discrete Integer a;
initial equation 
 pre(a) = 0;
equation
 a = if time > 0 then 1 else 0;
end OverdeterminedInitialSystem.Basic1;
")})));
    end Basic1;

    model Basic2
        Real a;
        Real b;
    initial equation
        a = 1;
        b = 1;
    equation
        der(a) = time;
        a = b;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic2",
            description="A basic test",
            flatModel="
fclass OverdeterminedInitialSystem.Basic2
 Real a;
initial equation 
 a = 1;
equation
 der(a) = time;
end OverdeterminedInitialSystem.Basic2;
")})));
    end Basic2;

    model Basic3
        Real x;
        Real y;
    initial equation
        x = 2;
        y = 3;
    equation
        x + 1 = y;
        der(x) = time;

    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Basic3",
            description="A basic test",
            flatModel="
fclass OverdeterminedInitialSystem.Basic3
 Real x;
 Real y;
initial equation 
 x = 2;
equation
 x + 1 = y;
 der(x) = time;
end OverdeterminedInitialSystem.Basic3;
")})));
    end Basic3;

end OverdeterminedInitialSystem;
