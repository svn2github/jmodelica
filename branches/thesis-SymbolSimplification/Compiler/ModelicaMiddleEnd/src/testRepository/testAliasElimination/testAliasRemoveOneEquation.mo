package testAliasRemoveOneEquation
model testAliasRemoveOneEquation

    Real a;
    Real b;
    Real c;

equation
    a = 1;
    b = a;
    c = 2 * b;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Alias elimination remove one equation",
            eliminate_alias_variables=true,
            variability_propagation=false,
			canonize_equations=false,
            description="",
            flatModel="
            
fclass testAliasRemoveOneEquation.testAliasRemoveOneEquation
 Real c;
 Real a;
equation
 c = 2 * a;
 a = 1;
end testAliasRemoveOneEquation.testAliasRemoveOneEquation;

")})));

end testAliasRemoveOneEquation;
end testAliasRemoveOneEquation;