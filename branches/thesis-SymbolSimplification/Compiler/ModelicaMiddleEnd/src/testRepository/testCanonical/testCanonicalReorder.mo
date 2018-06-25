package testCanonicalReorder
model testCanonicalReorder

    Real s1;
    Real s2;
    Real s11;
    Real s111;
    Real x;

equation
    s2 * s1 = 0;
    s11 + s1 = 0;
    s111 * -2 + s111 * 2 = 0;
    s11 * s111 * s2 + s1 * s11 = 0;
    s11 * s2 * s111 + s111 * s11 * s1 = x;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Canonize equations reorder expressions",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations = true,
            description="",
            flatModel="
            
fclass testCanonicalReorder.testCanonicalReorder
 Real s1;
 Real s2;
 Real s11;
 Real s111;
 Real x;
equation
 s1 * s2 = 0;
 s1 + s11 = 0;
 s111 * 2 + s111 * -2 = 0;
 s11 * s111 * s2 + s1 * s11 = 0;
 s1 * s11 * s111 + s11 * s111 * s2 + x * -1 = 0;
end testCanonicalReorder.testCanonicalReorder;

")})));

end testCanonicalReorder;
end testCanonicalReorder;