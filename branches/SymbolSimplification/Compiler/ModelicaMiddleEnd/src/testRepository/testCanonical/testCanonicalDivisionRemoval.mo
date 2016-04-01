package testCanonicalDivisionRemoval
model testCanonicalDivisionRemoval

	Real a;
	Real b;
	Real c;
	Real d;
	Real x;

equation
    0 = a / b + c;
    0 = (a + b) / c + d;
    0 = a / (b + c);
    0 = (a + b) / (c + d);
    x / a = b / (c + d);
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Canonize equations division removal",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations = true,
            description="",
            flatModel="
            
fclass testCanonicalDivisionRemoval.testCanonicalDivisionRemoval
 Real a;
 Real b;
 Real c;
 Real d;
 Real x;
equation
 c * b + a = 0;
 a + b + d * c = 0;
 a = 0;
 a + b = 0;
 x * c + (- a * b) + x * d = 0;

end testCanonicalDivisionRemoval.testCanonicalDivisionRemoval;

")})));

end testCanonicalDivisionRemoval;
end testCanonicalDivisionRemoval;