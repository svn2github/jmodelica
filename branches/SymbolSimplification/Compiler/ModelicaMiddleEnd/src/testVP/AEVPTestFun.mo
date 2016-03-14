package AEVPTestFun
model AEVPTestFun

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
            name="AEVPTestFun",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            description="",
            flatModel="
            
fclass AEVPTestFun.AEVPTestFun
 constant Real j = 10;
 constant Real p = 20;
 constant Real q = 30.0;
end AEVPTestFun.AEVPTestFun;

")})));

end AEVPTestFun;
end AEVPTestFun;