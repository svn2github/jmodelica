package CodeGenTests


  model CodeGenTest1
  
  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CodeGenTestCase(name="CodeGenTest1",
        description="Test of code generation",
        template = 
        "n_ci: $n_ci$
n_real_ci: $n_real_ci$
n_integer_ci: $n_integer_ci$
n_boolean_ci: $n_boolean_ci$
n_string_ci $n_string_ci$
n_cd: $n_cd$
n_real_cd: $n_real_cd$
n_integer_cd: $n_integer_cd$
n_boolean_cd: $n_boolean_cd$
n_string_cd: $n_string_cd$
n_pi: $n_pi$
n_real_pi: $n_real_pi$
n_integer_pi: $n_integer_pi$
n_boolean_pi: $n_boolean_pi$
n_string_pi: $n_string_pi$
n_pd: $n_pd$
n_real_pd: $n_real_pd$
n_integer_pd: $n_integer_pd$
n_boolean_pd: $n_boolean_pd$
n_string_pd: $n_string_pd$
n_w: $n_w$
n_real_w: $n_real_w$
n_integer_w: $n_integer_w$
n_boolean_w: $n_boolean_w$
n_string_w: $n_string_w$
n_real_x: $n_real_x$
n_u: $n_u$
n_real_u: $n_real_u$
n_integer_u: $n_integer_u$
n_boolean_u: $n_boolean_u$
n_string_u: $n_string_u$
n_equations: $n_equations$
n_initial_equations: $n_initial_equations$",
        generatedCode="n_ci: 0
n_real_ci: 0
n_integer_ci: 0
n_boolean_ci: 0
n_string_ci 0
n_cd: 0
n_real_cd: 0
n_integer_cd: 0
n_boolean_cd: 0
n_string_cd: 0
n_pi: 12
n_real_pi: 3
n_integer_pi: 3
n_boolean_pi: 3
n_string_pi: 3
n_pd: 8
n_real_pd: 2
n_integer_pd: 2
n_boolean_pd: 2
n_string_pd: 2
n_w: 11
n_real_w: 2
n_integer_w: 3
n_boolean_w: 3
n_string_w: 3
n_real_x: 1
n_u: 4
n_real_u: 1
n_integer_u: 1
n_boolean_u: 1
n_string_u: 1
n_equations: 5
n_initial_equations: 0")})));
  
  
  	parameter Real rp1=1;
  	parameter Real rp2=rp1;
    parameter Real rp3(start=1);
    parameter Real rp4(start=rp1);
    parameter Real rp5(start=rp1) = 5;
    Real r1(start=1);
    Real r2=3;
    Real r3;
	input Real r4 = 5;

  	parameter Integer ip1=1;
  	parameter Integer ip2=ip1;
    parameter Integer ip3(start=1);
    parameter Integer ip4(start=ip1);
    parameter Integer ip5(start=ip1) = 5;
    Integer i1(start=1);
    Integer i2=3;
  	Integer i3=4;
	input Integer r4 = 5;

  	parameter Boolean bp1=true;
  	parameter Boolean bp2=bp1;
    parameter Boolean bp3(start=true);
    parameter Boolean bp4(start=bp1);
    parameter Boolean bp5(start=bp1) = false;
    Boolean b1(start=true);
    Boolean b2=true;
	Boolean b3=true;
	input Boolean b4 =true;
		
  	parameter String sp1="hello";
  	parameter String sp2=sp1;
    parameter String sp3(start="hello");
    parameter String sp4(start=sp1);
    parameter String sp5(start=sp1) = "hello";
    String s1(start="hello");
    String s2="hello";
	String s3="hello";
	input String s4="hello";
    
    equation 
     r1 = 1;
     der(r3)=1;
     i1 = 1;
     b1 = true;
     s2 = "hello";
  end CodeGenTest1;


	model CodeGenTest2
	
	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CodeGenTestCase(name="CodeGenTest2",
        description="Test of code generation",
        template = "$n_real_x$",generatedCode="1")})));
		Real x;
    equation
        der(x)=1;
	end CodeGenTest2;



end CodeGenTests;