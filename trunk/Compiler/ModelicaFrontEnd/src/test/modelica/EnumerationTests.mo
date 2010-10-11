package EnumerationTests



  model EnumerationTest1
   annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.FlatteningTestCase(name="EnumerationTest1",
          description="Test basic use of enumerations",
          flatModel="
fclass EnumerationTests.EnumerationTest1
 parameter EnumerationTests.EnumerationTest1.Size t_shirt_size = EnumerationTests.EnumerationTest1.Size.medium;

 type EnumerationTests.EnumerationTest1.Size = enumeration(small \"1st\", medium, large, xlarge);
end EnumerationTests.EnumerationTest1;
")})));

    type Size = enumeration(small "1st", medium, large, xlarge); 
	parameter Size t_shirt_size = Size.medium; 
  end EnumerationTest1;

  
  model EnumerationTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest2",
         description="Test basic use of enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest2
 parameter EnumerationTests.EnumerationTest2.Size a1.t_shirt_size = EnumerationTests.EnumerationTest2.Size.medium;
 parameter EnumerationTests.EnumerationTest2.Size a2.t_shirt_size = EnumerationTests.EnumerationTest2.Size.medium;
 parameter EnumerationTests.EnumerationTest2.Size s = EnumerationTests.EnumerationTest2.Size.large;

 type EnumerationTests.EnumerationTest2.Size = enumeration(small \"1st\", medium, large, xlarge);
end EnumerationTests.EnumerationTest2;
")})));

    type Size = enumeration(small "1st", medium, large, xlarge); 
	  
    model A
      parameter Size t_shirt_size = Size.medium; 
	end A;
	
    A a1;
    A a2;
	parameter Size s = Size.large;
  end EnumerationTest2;


  model EnumerationTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest3",
         description="Test of constant evaluation for enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest3
 constant EnumerationTests.EnumerationTest3.A x = EnumerationTests.EnumerationTest3.A.b;
 parameter EnumerationTests.EnumerationTest3.A y = EnumerationTests.EnumerationTest3.A.b;

 type EnumerationTests.EnumerationTest3.A = enumeration(a, b, c);
end EnumerationTests.EnumerationTest3;
")})));

    type A = enumeration(a, b, c);
    constant A x = A.b;
	parameter A y = x;
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
	parameter A x = B.a;
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
	parameter A x;
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
 parameter EnumerationTests.EnumerationTest6.A x = EnumerationTests.EnumerationTest6.B.a;

 type EnumerationTests.EnumerationTest6.A = enumeration(a, b, c);

 type EnumerationTests.EnumerationTest6.B = enumeration(a, b, c);
end EnumerationTests.EnumerationTest6;
")})));

    type A = enumeration(a, b, c);
    type B = enumeration(a, b, c);
	parameter A x = B.a;
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
  
  
  model EnumerationTest8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest8",
         description="Range expressions with Booleans and enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest8
 constant Boolean a[2] = false:true;
 parameter Boolean b[2] = {false,true} /* { false, true } */;
 constant EnumerationTests.EnumerationTest8.A c[3] = EnumerationTests.EnumerationTest8.A.b:EnumerationTests.EnumerationTest8.A.d;
 parameter EnumerationTests.EnumerationTest8.A d[3] = {EnumerationTests.EnumerationTest8.A.b,EnumerationTests.EnumerationTest8.A.c,EnumerationTests.EnumerationTest8.A.d} /* { EnumerationTests.EnumerationTest8.A.b, EnumerationTests.EnumerationTest8.A.c, EnumerationTests.EnumerationTest8.A.d } */;

 type EnumerationTests.EnumerationTest8.A = enumeration(a, b, c, d, e);
end EnumerationTests.EnumerationTest8;
")})));

	  type A = enumeration(a, b, c, d, e);
	
	  constant Boolean a[2] = false:true;
	  parameter Boolean b[2] = a;
	  constant A c[3] = A.b:A.d;
	  parameter A d[3] = c;
  end EnumerationTest8;
  
  
  model EnumerationTest9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest9",
         description="Relational operators with enumerations",
         flatModel="
fclass EnumerationTests.EnumerationTest9
 constant Boolean x[6,3] = {{EnumerationTests.EnumerationTest9.A.c < EnumerationTests.EnumerationTest9.A.b,EnumerationTests.EnumerationTest9.A.c < EnumerationTests.EnumerationTest9.A.c,EnumerationTests.EnumerationTest9.A.c < EnumerationTests.EnumerationTest9.A.d},{EnumerationTests.EnumerationTest9.A.c <= EnumerationTests.EnumerationTest9.A.b,EnumerationTests.EnumerationTest9.A.c <= EnumerationTests.EnumerationTest9.A.c,EnumerationTests.EnumerationTest9.A.c <= EnumerationTests.EnumerationTest9.A.d},{EnumerationTests.EnumerationTest9.A.c > EnumerationTests.EnumerationTest9.A.b,EnumerationTests.EnumerationTest9.A.c > EnumerationTests.EnumerationTest9.A.c,EnumerationTests.EnumerationTest9.A.c > EnumerationTests.EnumerationTest9.A.d},{EnumerationTests.EnumerationTest9.A.c >= EnumerationTests.EnumerationTest9.A.b,EnumerationTests.EnumerationTest9.A.c >= EnumerationTests.EnumerationTest9.A.c,EnumerationTests.EnumerationTest9.A.c >= EnumerationTests.EnumerationTest9.A.d},{EnumerationTests.EnumerationTest9.A.c == EnumerationTests.EnumerationTest9.A.b,EnumerationTests.EnumerationTest9.A.c == EnumerationTests.EnumerationTest9.A.c,EnumerationTests.EnumerationTest9.A.c == EnumerationTests.EnumerationTest9.A.d},{EnumerationTests.EnumerationTest9.A.c <> EnumerationTests.EnumerationTest9.A.b,EnumerationTests.EnumerationTest9.A.c <> EnumerationTests.EnumerationTest9.A.c,EnumerationTests.EnumerationTest9.A.c <> EnumerationTests.EnumerationTest9.A.d}};
 parameter Boolean y[6,3] = {{false,false,true},{false,true,true},{true,false,false},{true,true,false},{false,true,false},{true,false,true}} /* { { false, false, true }, { false, true, true }, { true, false, false }, { true, true, false }, { false, true, false }, { true, false, true } } */;

 type EnumerationTests.EnumerationTest9.A = enumeration(a, b, c, d, e);
end EnumerationTests.EnumerationTest9;
")})));

	  type A = enumeration(a, b, c, d, e);
	  constant Boolean[:,:] x = {
		  { A.c <  A.b, A.c <  A.c, A.c <  A.d }, 
		  { A.c <= A.b, A.c <= A.c, A.c <= A.d }, 
		  { A.c >  A.b, A.c >  A.c, A.c >  A.d }, 
		  { A.c >= A.b, A.c >= A.c, A.c >= A.d }, 
		  { A.c == A.b, A.c == A.c, A.c == A.d }, 
		  { A.c <> A.b, A.c <> A.c, A.c <> A.d } 
		  };
	  parameter Boolean[:,:] y = x;
  end EnumerationTest9;
  
  
  model EnumerationTest10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.FlatteningTestCase(
         name="EnumerationTest10",
         description="Using the Integer() operator: basic test",
         flatModel="
fclass EnumerationTests.EnumerationTest10
 constant Integer i[3] = {Integer(EnumerationTests.EnumerationTest10.A.a),Integer(EnumerationTests.EnumerationTest10.A.c),Integer(EnumerationTests.EnumerationTest10.A.e)};
 parameter Integer j[3] = {1,3,5} /* { 1, 3, 5 } */;

 type EnumerationTests.EnumerationTest10.A = enumeration(a, b, c, d, e);
end EnumerationTests.EnumerationTest10;
")})));

	  type A = enumeration(a, b, c, d, e);
	  constant Integer i[:] = { Integer(A.a), Integer(A.c), Integer(A.e) };
	  parameter Integer j[:] = i;
  end EnumerationTest10;
  
  
  model EnumerationTest11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.ErrorTestCase(
         name="EnumerationTest11",
         description="Using the Integer() operator: wrong type of argument",
         errorMessage="
4 errors found:
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Semantic error at line 219, column 22:
  Could not evaluate binding expression for parameter 'is': 'Integer(\"1\")'
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Semantic error at line 219, column 35:
  Calling function Integer(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Semantic error at line 220, column 35:
  Calling function Integer(): types of positional argument 1 and input x are not compatible
Error: in file 'Compiler/ModelicaFrontEnd/src/test/modelica/EnumerationTests.mo':
Semantic error at line 221, column 35:
  Calling function Integer(): types of positional argument 1 and input x are not compatible
")})));

	  parameter Integer is = Integer("1");
	  parameter Integer ir = Integer(1.0);
	  parameter Integer ii = Integer(1);
  end EnumerationTest11;


end EnumerationTests;
