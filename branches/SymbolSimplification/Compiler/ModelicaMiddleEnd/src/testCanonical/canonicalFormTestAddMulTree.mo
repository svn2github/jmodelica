package canonicalFormTestAddMulTree
model canonicalFormTestAddMulTree

    Real a;
    Real b;
    Real c;
    Real d;
    Real e;

equation
    0 = (a + b) * c;
    0 = (a + b) * (c + d);
    0 = (a + b) * (c - d);
    0 = (a - b) * (c - d);
    0 = a * (b * (c * (d - e)));
    
       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="canonicalFormTestAddMulTree",
            eliminate_alias_variables=false,
            variability_propagation=false,
            iterative_symbol_simplification = false,
            canonize_equations = true,
            description="",
            flatModel="
            
fclass canonicalFormTestAddMulTree.canonicalFormTestAddMulTree
 Real x;
 Real a;
 Real b;
equation
 a * c + b * c = 0;
 a * c + a * d + b * c + b * d = 0;
 a * c - a * d + b * c - b * d = 0;
 a * c - a * d - b * c + b * d = 0;
 a * b * c * d - a * b * c * e = 0;

end canonicalFormTestAddMulTree.canonicalFormTestAddMulTree;

")})));

end canonicalFormTestAddMulTree;
end canonicalFormTestAddMulTree;