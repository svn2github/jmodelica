package testAliasRemoveTwoEquations
model testAliasRemoveTwoEquations

    Real a;
    Real b;
    Real c;
    Real d;
    Real e;

equation
    a = b;
    b = c;
    b = 1;
    d = 2;
    e = b + c + d;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Alias elimination remove two equations",
            eliminate_alias_variables=true,
            variability_propagation=false,
			canonize_equations=false,
            description="",
            flatModel="
            
fclass testAliasRemoveTwoEquations.testAliasRemoveTwoEquations
 Real d;
 Real b;
 Real e;
equation
 d = 2;
 e = b + b + d;
 b = 1;
end testAliasRemoveTwoEquations.testAliasRemoveTwoEquations;

")})));

end testAliasRemoveTwoEquations;
end testAliasRemoveTwoEquations;