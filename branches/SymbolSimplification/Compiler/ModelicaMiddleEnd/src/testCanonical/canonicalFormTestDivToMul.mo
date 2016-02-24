package canonicalFormTestDivToMul
model canonicalFormTestDivToMul

    Real x;
    Real a;
    Real b;

equation
    0 = x/(b/a + b*a);
    x = 1 + (a + b)/(a/2 + b);
    x = (a + b)/(a/2 + b) + 5/(a - b);
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CanonicalFormTest",
            eliminate_alias_variables=false,
            variability_propagation=false,
            iterative_symbol_simplification = false,
            description="",
            flatModel="
            
fclass canonicalFormTestDivToMul.canonicalFormTestDivToMul
 Real x;
 Real a;
 Real b;
equation
 0 = x;
 0 = a + b * 2 + (a + b) * 2 - x * (a + b * 2);
 0 = (a + b) * 2 * (a - b) + 5 * (a + b * 2) - x * (a + b * 2) * (a - b);

end canonicalFormTestDivToMul.canonicalFormTestDivToMul;

")})));

end canonicalFormTestDivToMul;
end canonicalFormTestDivToMul;