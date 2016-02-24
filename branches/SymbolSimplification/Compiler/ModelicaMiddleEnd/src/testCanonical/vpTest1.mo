package aliasTest1
model aliasTest1

    Real a;
    Real b;

equation
    a = 1;
    x = a;
    y = 5 * x;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TestTest1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            description="",
            flatModel="
            
fclass aliasTest1.aliasTest1
 Real y;
 Real a;
equation
 y = 5 * a;
 a = 1;
end aliasTest1.aliasTest1;

")})));

end aliasTest1;
end aliasTest1;