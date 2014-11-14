/*
    Copyright (C) 2013 Modelon AB

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

within ;
package SymbolicTests

model EquivalentIfBranch1
    type E = enumeration(E1,E2);
    Real x1 = if time > 1 then 2.0 else 2.0;
    Integer x2 = if time > 1 then 2 else 2;
    Boolean x3 = if time > 1 then true else true;
    String x4 = if time > 1 then "str" else "str";
    E x5 = if time > 1 then E.E2 else E.E2;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch1",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch1
 Real x1 = 2.0;
 discrete Integer x2 = 2;
 discrete Boolean x3 = true;
 discrete String x4 = \"str\";
 discrete SymbolicTests.EquivalentIfBranch1.E x5 = SymbolicTests.EquivalentIfBranch1.E.E2;

public
 type SymbolicTests.EquivalentIfBranch1.E = enumeration(E1, E2);

end SymbolicTests.EquivalentIfBranch1;

")})));
end EquivalentIfBranch1;

model EquivalentIfBranch2
    Real x = time;
    Real y = if x > 1 then x else x;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch2",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch2
 Real x = time;
 Real y = x;
end SymbolicTests.EquivalentIfBranch2;
")})));
end EquivalentIfBranch2;

model EquivalentIfBranch3
    Real x = time;
    Real y = if x > 1 then x elseif time > 2 then x else x;
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch3",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch3
 Real x = time;
 Real y = if x > 1 then x else x;
end SymbolicTests.EquivalentIfBranch3;
")})));
end EquivalentIfBranch3;

model EquivalentIfBranch4
    Real x[2] = {1,2};
    Real y = if time > 1 then x[1] else x[2];
    
    annotation(__JModelica(UnitTesting(tests={
        FlatteningTestCase(
            name="EquivalentIfBranch4",
            description="Symbolic simplification of equivalent if branches",
            flatModel="
fclass SymbolicTests.EquivalentIfBranch4
 Real x[2] = {1, 2};
 Real y = if time > 1 then x[1] else x[2];
end SymbolicTests.EquivalentIfBranch4;
")})));
end EquivalentIfBranch4;

end SymbolicTests;
