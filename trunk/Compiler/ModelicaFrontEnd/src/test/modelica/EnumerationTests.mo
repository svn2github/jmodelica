package EnumerationTests

   model EnumerationTest1
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="EnumerationTest1",
                                               description="Test basic use of enumerations",
                                               flatModel=
"
fclass EnumerationTests.EnumerationTest1
 EnumerationTests.EnumerationTest1.Size t_shirt_size = Size.medium;

  type EnumerationTests.EnumerationTest1.Size = enumeration(small \"1st\", medium, large, xlarge);
end EnumerationTests.EnumerationTest1;
")})));

    type Size = enumeration(small "1st", medium, large, xlarge); 
    Size t_shirt_size = Size.medium; 
  end EnumerationTest1;

/* These tests does not yet pass
   model EnumerationTest2
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="EnumerationTest2",
                                               description="Test basic use of enumerations",
                                               flatModel=
"
fclass EnumerationTests.EnumerationTest2
 EnumerationTests.EnumerationTest2.Size a.t_shirt_size = Size.medium;

  type EnumerationTests.EnumerationTest2.Size = enumeration(small \"1st\", medium, large, xlarge);
end EnumerationTests.EnumerationTest2;
")})));
     type Size = enumeration(small "1st", medium, large, xlarge); 
    model A
      Size t_shirt_size = Size.medium; 
    end A;
    A a;
  end EnumerationTest2;

   model EnumerationTest3
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="EnumerationTest3",
                                               description="Test basic use of enumerations",
                                               flatModel=
"
fclass EnumerationTests.EnumerationTest3
 EnumerationTests.EnumerationTest3.Size a1.t_shirt_size = a1.Size.medium;
 EnumerationTests.EnumerationTest3.Size a2.t_shirt_size = a2.Size.medium;
 EnumerationTests.EnumerationTest3.Size s = Size.large;

  type EnumerationTests.EnumerationTest3.Size = enumeration(small "1st", medium, large, xlarge);
end EnumerationTests.EnumerationTest3;
")})));
     type Size = enumeration(small "1st", medium, large, xlarge); 
    model A
      Size t_shirt_size = Size.medium; 
    end A;
    A a1;
    A a2;
    Size s = Size.large;
  end EnumerationTest3;

 */

end EnumerationTests;