package CCodeGenTests

model CCodeGenTest1
  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest1",
        description="Test of code generation",
        template = 
        "$C_variable_aliases$
$C_DAE_equation_residuals$",
        generatedCode="#define p ((*(jmi->z))[jmi->offs_pi+0])
#define der_x1 ((*(jmi->z))[jmi->offs_dx+0])
#define der_x2 ((*(jmi->z))[jmi->offs_dx+1])
#define x1 ((*(jmi->z))[jmi->offs_x+0])
#define x2 ((*(jmi->z))[jmi->offs_x+1])
#define u ((*(jmi->z))[jmi->offs_u+0])
#define w ((*(jmi->z))[jmi->offs_w+0])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = ( 1 - ( pow(x2,2) ) ) * ( x1 ) - ( x2 ) + ( p ) * ( u ) - (der_x1);
    (*res)[1] = x1 - (der_x2);
    (*res)[2] = x1 + x2 - (w);
")})));
 
  Real x1(start=0); 
  Real x2(start=1); 
  input Real u; 
  parameter Real p = 1;
  Real w = x1+x2;
equation 
  der(x1) = (1-x2^2)*x1 - x2 + p*u; 
  der(x2) = x1; 
end CCodeGenTest1;


	model CCodeGenTest2

  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest2",
        description="Test of code generation",
        template = 
        "$C_variable_aliases$
$C_DAE_equation_residuals$
$C_DAE_initial_equation_residuals$
$C_DAE_initial_guess_equation_residuals$",
        generatedCode="#define der_x ((*(jmi->z))[jmi->offs_dx+0])
#define der_v ((*(jmi->z))[jmi->offs_dx+1])
#define x ((*(jmi->z))[jmi->offs_x+0])
#define v ((*(jmi->z))[jmi->offs_x+1])
#define y ((*(jmi->z))[jmi->offs_w+0])
#define z ((*(jmi->z))[jmi->offs_w+1])
#define w ((*(jmi->z))[jmi->offs_w+2])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] =  - ( x ) - (der_x);
    (*res)[1] = 4 - (der_v);
    (*res)[2] = x - (z);
    (*res)[3] = 2 - (w);

    (*res)[0] = 1 - (x);
    (*res)[1] = 3 - (y);

   (*res)[2] = 0.0 - z;
   (*res)[3] = 1 - w;
   (*res)[4] = 0.0 - v;
   (*res)[5] = 0.0 - der_x;
   (*res)[6] = 0.0 - der_v;")})));


		Real x(start=1);
		Real y(start=3,fixed=true);
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
	end CCodeGenTest2;


end CCodeGenTests;