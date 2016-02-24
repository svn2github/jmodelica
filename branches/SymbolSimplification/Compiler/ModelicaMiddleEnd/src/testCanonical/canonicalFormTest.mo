package canonicalFormTest
model canonicalFormTest

    Real a;
    Real b;
    Real c;
    Real d;

equation
    0 = a - b - c- d;
    a = 1;
    b = 1;
    c = 1;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CanonicalFormTest",
            eliminate_alias_variables=false,
            variability_propagation=false,
            description="",
            flatModel="
            
fclass canonicalFormTest.canonicalFormTest
 Real x;
 Real a;
 Real b;
equation
 0 = x;
 0 = a + b * 2 + (a + b) * 2 - x * (a + b * 2);
 0 = (a + b) * 2 * (a - b) + 5 * (a + b * 2) - x * (a + b * 2) * (a - b);

end canonicalFormTest.canonicalFormTest;

")})));

end canonicalFormTest;
end canonicalFormTest;