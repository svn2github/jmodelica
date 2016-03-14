package canonicalFormTest
model canonicalFormTest

	Real a;
	Real b;

equation
	a = 0;
    a = b;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CanonicalFormTest",
            eliminate_alias_variables=false,
            variability_propagation=false,
            iterative_symbol_simplification = false,
            canonize_equations = true,
            description="",
            flatModel="
            
fclass canonicalFormTest.canonicalFormTest
 Real a;
 Real b;
equation
a = 0;
a + (- b) = 0;
end canonicalFormTest.canonicalFormTest;

")})));

end canonicalFormTest;
end canonicalFormTest;