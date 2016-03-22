package testAEandVP
model testAEandVP

    Real a;
    Real b;
	Real c;

equation
	1 = a + b;
	b = a;
	c = 5 * a + b;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="canonicalFormTestAddMulTree",
            eliminate_alias_variables=true,
            variability_propagation=true,
            simple_ae = false,
            simple_vp = false,
            canonize_equations = false,
            description="",
            flatModel="
            
fclass testAEandVP.testAEandVP
 Real b;
 Real c;
equation
 1 = b + b;
 c = 5 * b + b;
end testAEandVP.testAEandVP;


")})));

end testAEandVP;
end testAEandVP;