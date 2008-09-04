package TmpTests
class ModTest11
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="ModTest11",
                                               description="Additional merging tests",
                                               flatModel=
" fclass ModificationTests.ModTest11
 Real c2.c3.c4a.z=6;
 Real c2.c3.c4a.x=4;
 Real c2.c3.c4b.z=2;
 Real c2.c3.c4b.x=10;
 Real c3.c4a.z=6;
 Real c3.c4a.x=5;
 Real c3.c4b.z=8;
 Real c3.c4b.x=3;
equation 
end ModificationTests.ModTest11;
")})));
  
  class C2
    
    class C3
      
      class C4
        Real z=2;
        Real x=3;
      end C4;
    
      C4 c4a,c4b;
    
    end C3;
  	
  	C3 c3(c4a.z=6);
  	
  end C2;
  
  C2 c2(c3.c4a.x=4,c3.c4b.x=10);
  extends C2(c3.c4a.x=5,c3.c4b.z=8);
end ModTest11;

end TmpTests;