package AEVPTest2
model AEVPTest2

    extends Modelica.Block.Examples;

       annotation(__JModelica(UnitTesting(tests={
        TransformCanonicalTestCase(
            name="AEVPTest2",
            
            eliminate_alias_variables=false,
            variability_propagation=false,
            canonize_equations=false,
            iterative_symbol_simplification=true,
            description="",
            flatModel="
            
fclass AEVPTest2.AEVPTest2
 constant Real e = 11.0;
 constant Real d = 7;
 constant Real b = 2;
end AEVPTest2.AEVPTest2;

")})));

end AEVPTest2;
end AEVPTest2;