package aliasTest2
model aliasTest2

    Real a;
    Real b;
    Real c;
    Real d;
    Real e;

equation
    a = b;
    b = c;
    b = 2;
    d = 7;
    e = b + c + d;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TestTest1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            description="",
            flatModel="
            
fclass aliasTest2.aliasTest2
 Real d;
 Real b;
 Real e;
equation
 d = 7;
 e = b + b + d;
 b = 2;
end aliasTest2.aliasTest2;

")})));

end aliasTest2;
end aliasTest2;