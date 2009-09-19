package CCodeGenTests

model CCodeGenTest1
  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest1",
        description="Test of code generation",
        template = 
        "$C_variable_aliases$
$C_DAE_equation_residuals$",
        generatedCode="#define _p_ ((*(jmi->z))[jmi->offs_pi+0])
#define _der_x1_ ((*(jmi->z))[jmi->offs_dx+0])
#define _der_x2_ ((*(jmi->z))[jmi->offs_dx+1])
#define _x1_ ((*(jmi->z))[jmi->offs_x+0])
#define _x2_ ((*(jmi->z))[jmi->offs_x+1])
#define _u_ ((*(jmi->z))[jmi->offs_u+0])
#define _w_ ((*(jmi->z))[jmi->offs_w+0])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = ( 1 - ( pow(_x2_,2) ) ) * ( _x1_ ) - ( _x2_ ) + ( _p_ ) * ( _u_ ) - (_der_x1_);
    (*res)[1] = _x1_ - (_der_x2_);
    (*res)[2] = _x1_ + _x2_ - (_w_);
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
        generatedCode="#define _der_x_ ((*(jmi->z))[jmi->offs_dx+0])
#define _der_v_ ((*(jmi->z))[jmi->offs_dx+1])
#define _x_ ((*(jmi->z))[jmi->offs_x+0])
#define _v_ ((*(jmi->z))[jmi->offs_x+1])
#define _y_ ((*(jmi->z))[jmi->offs_w+0])
#define _z_ ((*(jmi->z))[jmi->offs_w+1])
#define _w_ ((*(jmi->z))[jmi->offs_w+2])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] =  - ( _x_ ) - (_der_x_);
    (*res)[1] = 4 - (_der_v_);
    (*res)[2] = 3 - (_y_);
    (*res)[3] = _x_ - (_z_);
    (*res)[4] = 2 - (_w_);

    (*res)[0] =  - ( _x_ ) - (_der_x_);
    (*res)[1] = 4 - (_der_v_);
    (*res)[2] = 3 - (_y_);
    (*res)[3] = _x_ - (_z_);
    (*res)[4] = 2 - (_w_);
    (*res)[5] = 3 - (_y_);

   (*res)[0] = 0.0 - _z_;
   (*res)[1] = 1 - _w_;
   (*res)[2] = 0.0 - _v_;
   (*res)[3] = 0.0 - _der_x_;
   (*res)[4] = 0.0 - _der_v_;")})));


		Real x(start=1);
		Real y(start=3,fixed=true)=3;
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;
	end CCodeGenTest2;

	model CCodeGenTest3
  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest3",
        description="Test of code generation",
        template = 
        "$C_DAE_initial_dependent_parameter_residuals$",
        generatedCode="   (*res)[0] = ( _p1_ ) * ( _p1_ ) - _p2_;
   (*res)[1] = _p2_ - _p3_;")})));


	    parameter Real p3 = p2;
	    parameter Real p2 = p1*p1;
		parameter Real p1 = 4;
	end CCodeGenTest3;


end CCodeGenTests;