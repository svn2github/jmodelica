package EnumerationTests



  model EnumerationTest1
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="EnumerationTest1",
          description="Test basic use of enumerations",
          flatModel="
fclass EnumerationTests.EnumerationTest1
 EnumerationTests.EnumerationTest1.Size t_shirt_size = EnumerationTests.EnumerationTest1.Size.medium;

 type EnumerationTests.EnumerationTest1.Size = enumeration(small \"1st\", medium, large, xlarge);
end EnumerationTests.EnumerationTest1;
")})));

    type Size = enumeration(small "1st", medium, large, xlarge); 
    Size t_shirt_size = Size.medium; 
  end EnumerationTest1;

  
  model EnumerationTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest2",
         description="Test basic use of enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest2
 EnumerationTests.EnumerationTest2.Size a1.t_shirt_size = EnumerationTests.EnumerationTest2.Size.medium;
 EnumerationTests.EnumerationTest2.Size a2.t_shirt_size = EnumerationTests.EnumerationTest2.Size.medium;
 EnumerationTests.EnumerationTest2.Size s = EnumerationTests.EnumerationTest2.Size.large;

 type EnumerationTests.EnumerationTest2.Size = enumeration(small \"1st\", medium, large, xlarge);
end EnumerationTests.EnumerationTest2;
")})));

    type Size = enumeration(small "1st", medium, large, xlarge); 
	  
    model A
      Size t_shirt_size = Size.medium; 
	end A;
	
    A a1;
    A a2;
    Size s = Size.large;
  end EnumerationTest2;


  model EnumerationTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest3",
         description="Test of constant evaluation for enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest3
 constant EnumerationTests.EnumerationTest3.A x = EnumerationTests.EnumerationTest3.A.b;
 EnumerationTests.EnumerationTest3.A y = EnumerationTests.EnumerationTest3.A.b;

 type EnumerationTests.EnumerationTest3.A = enumeration(a, b, c);
end EnumerationTests.EnumerationTest3;
")})));

    type A = enumeration(a, b, c);
    constant A x = A.b;
    A y = x;
  end EnumerationTest3;
  
  
  model EnumerationTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="EnumerationTest4",
         description="Using incompatible enumerations: binding expression",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Semantic error at line 72, column 6:
  The binding expression of the variable x does not match the declared type of the variable
")})));

    type A = enumeration(a, b, c);
    type B = enumeration(a, c, b);
    A x = B.a;
  end EnumerationTest4;
  
  
  model EnumerationTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="EnumerationTest5",
         description="Using incompatible enumerations: equation",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Semantic error at line 92, column 4:
  The right and left expression types of equation are not compatible
")})));

    type A = enumeration(a, b, c);
    type B = enumeration(a, c, b);
	  A x;
  equation
    x = B.a;
  end EnumerationTest5;
  
  
  model EnumerationTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest6",
         description="Using equivalent enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest6
 EnumerationTests.EnumerationTest6.A x = EnumerationTests.EnumerationTest6.B.a;

 type EnumerationTests.EnumerationTest6.A = enumeration(a, b, c);

 type EnumerationTests.EnumerationTest6.B = enumeration(a, b, c);
end EnumerationTests.EnumerationTest6;
")})));

    type A = enumeration(a, b, c);
    type B = enumeration(a, b, c);
    A x = B.a;
  end EnumerationTest6;
  
  
  // Keeping this here for now, despite it being a compliance test
  model EnumerationTest7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ComplianceErrorTestCase(
         name="EnumerationTest7",
         description="Compliance error for using enumeration as array size",
         errorMessage="
1 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Compliance error at line 117, column 12:
  Array sizes of Boolean or enumeration type are not supported: A
")})));

    type A = enumeration(a, b, c);
    Real x[A];
  end EnumerationTest7;
  


end EnumerationTests;
