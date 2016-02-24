package aliasTestFun
model aliasTestFun

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
    j = 10;
    p = 20;
    q = a + p;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="TestTest1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            description="",
            flatModel="
            
fclass aliasTestFun.aliasTestFun
 Real p;
 Real q;
 Real j;
equation
 p = 20;
 j = 10;
 q = j + p;
end aliasTestFun.aliasTestFun;

")})));

end aliasTestFun;
end aliasTestFun;