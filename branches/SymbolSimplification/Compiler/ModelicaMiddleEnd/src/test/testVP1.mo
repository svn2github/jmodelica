package testVP1
model testVP1

    Integer x;
    parameter Integer y;

equation
    x = 1+2+3+y;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="testVP1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            description="",
            flatModel="
            
fclass testVP1.testVP1
 constant Integer x = 6;
 constant Integer y = 7;
end testVP1.testVP1;

")})));

end testVP1;
end testVP1;