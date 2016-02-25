package testVP

model VP1
    Real x1,x2,x3,x4;
equation
    x1 = 1;
    x2 = x3 + x1;
    x3 = x1;
    x4 = x2; 
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VP1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            description="",
            flatModel="
            
fclass testVP.VP1
 constant Real x1 = 1;
 constant Real x2 = 2.0;
 constant Real x3 = 1.0;
 constant Real x4 = 2.0;
end testVP.VP1;
")})));
end VP1;

model VP2
    Real x1;
    Boolean x2;
    parameter Real p1 = 4;
    Real r1;
    Real r2;
equation
    x1 = 1;
    x2 = true;
    r1 = p1;
    r2 = p1 + x1;
    annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="VP2",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            description="Tests if variability 
            inferred from equations is propagated to declarations",
            flatModel="
fclass testVP.VP2
 constant Real x1 = 1;
 constant Boolean x2 = true;
 parameter Real p1 = 4 /* 4 */;
 parameter Real r1;
 parameter Real r2;
parameter equation
 r1 = p1;
 r2 = p1 + 1.0;
end testVP.VP2;
")})));
end VP2;


end testVP;