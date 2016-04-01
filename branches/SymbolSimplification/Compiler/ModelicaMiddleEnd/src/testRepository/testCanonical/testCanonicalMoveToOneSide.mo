package testCanonicalMoveToOneSide
model testCanonicalMoveToOneSide

	Real a;
	Real b;

equation
	a = 0;
    a = b;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="Canonize equations move to one side",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations = true,
            description="",
            flatModel="
            
fclass testCanonicalMoveToOneSide.testCanonicalMoveToOneSide
 Real a;
 Real b;
equation
a = 0;
a + b * -1 = 0;
end testCanonicalMoveToOneSide.testCanonicalMoveToOneSide;

")})));

end testCanonicalMoveToOneSide;
end testCanonicalMoveToOneSide;