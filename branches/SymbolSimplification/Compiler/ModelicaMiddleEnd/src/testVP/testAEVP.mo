package testAEVP

model AEVP1
    Real x1,x2,x3,x4;
equation
    x1 = 1;
    x2 = x3 + x1;
    x3 = x1;
    x4 = x2; 
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AEVP1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            iterative_symbol_simplification=true,
            description="",
            flatModel="
            
fclass testAEVP.AEVP1
 constant Real x2 = 2.0;
 constant Real x1 = 1;
end testAEVP.AEVP1;
")})));
end AEVP1;

model AEVP2
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
            name="AEVP2",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            iterative_symbol_simplification=true,
            description="Tests if variability 
            inferred from equations is propagated to declarations",
            flatModel="
fclass testAEVP.AEVP2
 parameter Real r1;
 constant Boolean x2 = true;
 parameter Real p1 = 4 /* 4 */;
 parameter Real r2;
 constant Real x1 = 1;
parameter equation
 r1 = p1;
 r2 = p1 + 1.0;
end testAEVP.AEVP2;
")})));
end AEVP2;


end testAEVP;