package canonicalFormTestParentheses
model canonicalFormTestParentheses

    Real x;
    Real a;
    Real b;
    Real c;

equation
    0 = x*(a+b);
    x = 1 + (a+b)*b;
    x = (a+b)*(a+b);
    x = a-b-c;
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="CanonicalFormTestParentheses",
            eliminate_alias_variables=false,
            variability_propagation=false,
            iterative_symbol_simplification = false,
            description="",
            flatModel="
            
fclass canonicalFormTestParentheses.canonicalFormTestParentheses
 Real x;
 Real a;
 Real b;
equation
 0 = x*a + x*b;
 0 = 1 + a*b + b*b + x;
 0 = a*a + a*b + b*a + b*b + x;

end canonicalFormTestParentheses.canonicalFormTestParentheses;

")})));

end canonicalFormTestParentheses;
end canonicalFormTestParentheses;