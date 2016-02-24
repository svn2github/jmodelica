package vpTest1
model vpTest1

    Real a;
    Real x;
    Real y;

equation
    a = 1;
    x = a;
    y = 5 * x;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="vpTest1",
            eliminate_alias_variables=false,
            variability_propagation=false,
            description="",
            flatModel="
            
fclass vpTest1.vpTest1
 Real y;
 Real a;
equation
 y = 5 * a;
 a = 1;
end vpTest1.vpTest1;

")})));

end vpTest1;
end vpTest1;