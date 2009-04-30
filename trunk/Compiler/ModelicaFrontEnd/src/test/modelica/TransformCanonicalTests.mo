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

end TransformCanonicalTests;