package testCanonicalAddMulTree
model testCanonicalAddMulTree

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
            name="Canonize equations transformation to add- and mul-tree",
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations = true,
            description="",
            flatModel="
            
fclass testCanonicalAddMulTree.testCanonicalAddMulTree
 Real x;
 Real a;
 Real b;
equation
 a * c + b * c = 0;
 a * c + a * d + (b * c + b * d) = 0;
 a * c + b * c + (a * d * -1 + b * d * -1) = 0;
 a * c + b * d + (a * d * -1 + b * c * -1) = 0;
 a * b * (c * d) + a * b * c * (e * -1) = 0;

end testCanonicalAddMulTree.testCanonicalAddMulTree;

")})));

end testCanonicalAddMulTree;
end testCanonicalAddMulTree;