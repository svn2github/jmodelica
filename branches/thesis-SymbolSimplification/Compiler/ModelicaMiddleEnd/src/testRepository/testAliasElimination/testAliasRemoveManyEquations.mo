package testAliasRemoveManyEquations
model testAliasRemoveManyEquations

    Real a;
    Real b;
    Real c;
    Real d;
    Real e;
    Real f;
    Real g;
    Real h;
    Real i;
    Real j;
    Real p;
    Real q;

equation
    a = b;
    b = c;
    c = d;
    d = e;
    e = f;
    f = g;
    g = h;
    h = i;
    i = j;
    j = 1;
    p = 2;
    q = a + p;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Alias elimination remove many equations",
            eliminate_alias_variables=true,
            variability_propagation=false,
			canonize_equations=false,
            description="",
            flatModel="
            
fclass testAliasRemoveManyEquations.testAliasRemoveManyEquations
 Real a;
 Real p;
 Real q;
equation
 a = 1;
 p = 2;
 q = a + p;
end testAliasRemoveManyEquations.testAliasRemoveManyEquations;

")})));

end testAliasRemoveManyEquations;
end testAliasRemoveManyEquations;