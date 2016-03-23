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
	eliminate_alias_variables=true,
	variability_propagation=true,
	canonize_equations=false,
	simple_ae=false,
	simple_vp=false,
            description="",
            flatModel="
            
fclass aliasTestFun.aliasTestFun
 Real a;
 Real p;
 Real q;
equation
 a = 10;
 p = 20;
 q = a + p;
end aliasTestFun.aliasTestFun;

")})));

end aliasTestFun;
end aliasTestFun;