package TransformCanonicalTests


	model TransformCanonicalTest1
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest1",
        description="Test basic canonical transformations",
                                               flatModel=
"
fclass TransformCanonicalTests.TransformCanonicalTest1
 Real x(start = 1);
 Real y(start = 3,fixed = true);
 Real z;
 Real w(start = 1);
 Real v;
initial equation 
 x = 1;
 y = 3;
equation 
 der(x) =  - ( x );
 der(v) = 4;
 z = x;
 w = 2;
end TransformCanonicalTests.TransformCanonicalTest1;
")})));

		Real x(start=1);
		Real y(start=3,fixed=true);
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
	end TransformCanonicalTest1;
	
  model TransformCanonicalTest2
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest2",
        description="Test parameter sorting",
                                               flatModel=
"
fclass TransformCanonicalTests.TransformCanonicalTest2
 parameter Real p5 = 5;
 parameter Real p1 = 4;
 parameter Real p6 = p5;
 parameter Real p2 = ( p1 ) * ( p1 );
 parameter Real p3 = p2 + p1;
 parameter Real p4 = ( p3 ) * ( p3 );
equation 
end TransformCanonicalTests.TransformCanonicalTest2;
")})));


    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p1;
  	parameter Real p1 = 4;
  end TransformCanonicalTest2;

  model TransformCanonicalTest3_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TransformCanonical3_Err",
                                               description="Test parameter sorting.",
                                               errorMessage=
" 1 error found...
In file '../ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  The model TransformCanonicalTests.TransformCanonicalTest3_Err contains cyclic parameter dependencies.

")})));
    
    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p4*p1;
  	parameter Real p1 = 4;
  end TransformCanonicalTest3_Err;

  model TransformCanonicalTest4_Err
     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.ErrorTestCase(name="TransformCanonical4_Err",
                                               description="Test parameter sorting.",
                                               errorMessage=
" 1 error found...
In file '../ModelicaFrontEnd/src/test/modelica/TransformCanonicalTests.mo':
Semantic error at line 0, column 0:
  The model TransformCanonicalTests.TransformCanonicalTest4_Err contains cyclic parameter dependencies.

")})));

    parameter Real p6 = p5;
  	parameter Real p5 = 5;
  	parameter Real p4 = p3*p3;
  	parameter Real p3 = p2 + p1;
  	parameter Real p2 = p1*p2;
  	parameter Real p1 = 4;
  end TransformCanonicalTest4_Err;

  model TransformCanonicalTest5
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest5",
        description="Test parameter sorting",
                                               flatModel=
"
fclass TransformCanonicalTests.TransformCanonicalTest5
 parameter Real p7 = 1;
 parameter Real p5 = 1;
 parameter Real p3 = 1;
 parameter Real p11 = ( p7 ) * ( p5 );
 parameter Real p8 = ( p7 ) * ( p3 );
 parameter Real p10 = ( p11 ) * ( p3 );
 parameter Real p2 = p11;
 parameter Real p9 = ( p11 ) * ( p8 );
equation 
end TransformCanonicalTests.TransformCanonicalTest5;
")})));


    parameter Real p10 = p11*p3;
  	parameter Real p9 = p11*p8;
  	parameter Real p2 = p11;
  	parameter Real p11 = p7*p5;
  	parameter Real p8 = p7*p3;
  	parameter Real p7 = 1;
  	parameter Real p5 = 1;
    parameter Real p3 = 1;
  	
  end TransformCanonicalTest5;


  model TransformCanonicalTest6
	     annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.TransformCanonicalTestCase(name="TransformCanonicalTest6",
        description="Test parameter sorting",
                                               flatModel=
"
fclass TransformCanonicalTests.TransformCanonicalTest6
 parameter Real p1 = sin(1) /* 0.8414709848078965 */;
 parameter Real p2 = cos(1) /* 0.5403023058681398 */;
 parameter Real p3 = tan(1) /* 1.5574077246549023 */;
 parameter Real p4 = asin(0.3) /* 0.3046926540153975 */;
 parameter Real p5 = acos(0.3) /* 1.2661036727794992 */;
 parameter Real p6 = atan(0.3) /* 0.2914567944778671 */;
 parameter Real p7 = atan2(0.3) /* 0.5404195002705842 */;
 parameter Real p8 = sinh(1) /* 1.1752011936438014 */;
 parameter Real p9 = cosh(1) /* 1.543080634815244 */;
 parameter Real p10 = tanh(1) /* 0.7615941559557649 */;
 parameter Real p11 = exp(1) /* 2.7182818284590455 */;
 parameter Real p12 = log(1) /* 0.0 */;
 parameter Real p13 = log10(1) /* 0.0 */;
equation 
end TransformCanonicalTests.TransformCanonicalTest6;
")})));


    parameter Real p1 = sin(1);
    parameter Real p2 = cos(1);
    parameter Real p3 = tan(1); 
    parameter Real p4 = asin(0.3);
    parameter Real p5 = acos(0.3);
    parameter Real p6 = atan(0.3); 
    parameter Real p7 = atan2(0.3,0.5); 	
    parameter Real p8 = sinh(1);
    parameter Real p9 = cosh(1);
    parameter Real p10 = tanh(1); 
    parameter Real p11 = exp(1);
    parameter Real p12 = log(1);
    parameter Real p13 = log10(1); 


  	
  end TransformCanonicalTest6;


end TransformCanonicalTests;