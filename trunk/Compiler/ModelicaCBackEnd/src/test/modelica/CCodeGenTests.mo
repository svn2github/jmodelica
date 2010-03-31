package CCodeGenTests

model CCodeGenTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest1",
         description="Test of code generation",
         template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
         generatedCode="
#define _p_3 ((*(jmi->z))[jmi->offs_real_pi+0])
#define _der_x1_5 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _der_x2_6 ((*(jmi->z))[jmi->offs_real_dx+1])
#define _x1_0 ((*(jmi->z))[jmi->offs_real_x+0])
#define _x2_1 ((*(jmi->z))[jmi->offs_real_x+1])
#define _u_2 ((*(jmi->z))[jmi->offs_real_u+0])
#define _w_4 ((*(jmi->z))[jmi->offs_real_w+0])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = ( 1 - ( ((_x2_1)*(_x2_1)) ) ) * ( _x1_0 ) - ( _x2_1 ) + ( _p_3 ) * ( _u_2 ) - (_der_x1_5);
    (*res)[1] = _x1_0 - (_der_x2_6);
    (*res)[2] = _x1_0 + _x2_1 - (_w_4);
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
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest2",
         description="Test of code generation",
         template="
$C_variable_aliases$
$C_DAE_equation_residuals$
$C_DAE_initial_equation_residuals$
$C_DAE_initial_guess_equation_residuals$
",
         generatedCode="
#define _der_z_4 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _der_v_5 ((*(jmi->z))[jmi->offs_real_dx+1])
#define _z_1 ((*(jmi->z))[jmi->offs_real_x+0])
#define _v_3 ((*(jmi->z))[jmi->offs_real_x+1])
#define _y_0 ((*(jmi->z))[jmi->offs_real_w+0])
#define _w_2 ((*(jmi->z))[jmi->offs_real_w+1])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] =  - ( _z_1 ) - (_der_z_4);
    (*res)[1] = 4 - (_der_v_5);
    (*res)[2] = 3 - (_y_0);
    (*res)[3] = 2 - (_w_2);

    (*res)[0] =  - ( _z_1 ) - (_der_z_4);
    (*res)[1] = 4 - (_der_v_5);
    (*res)[2] = 3 - (_y_0);
    (*res)[3] = 2 - (_w_2);
    (*res)[4] = 3 - (_y_0);

   (*res)[0] = 0.0 - _z_1;
   (*res)[1] = 1 - _w_2;
   (*res)[2] = 0.0 - _v_3;
")})));

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
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest3",
         description="Test of code generation",
         template="$C_DAE_initial_dependent_parameter_residuals$",
         generatedCode="
   (*res)[0] = ( _p1_0 ) * ( _p1_0 ) - _p2_1;
   (*res)[1] = _p2_1 - _p3_2;
")})));

	    parameter Real p3 = p2;
	    parameter Real p2 = p1*p1;
		parameter Real p1 = 4;
	end CCodeGenTest3;


model CCodeGenTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest4",
         description="Test of code generation",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = _y_1 - (_der_x_2);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(time,jmi_divide(AD_WRAP_LITERAL(3.141592653589793),AD_WRAP_LITERAL(2),\"Divide by zero: ( 3.141592653589793 ) / ( 2 )\"),JMI_TRUE,JMI_FALSE),JMI_TRUE,sin(time),_x_0)) - (_y_1);
")})));

  Real x(start=0);
  Real y = noEvent(if time <= Modelica.Constants.pi/2 then sin(time) else x);
equation
  der(x) = y; 
end CCodeGenTest4;


model CCodeGenTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest5",
         description="Test of code generation",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = _y_3 - (_der_x_4);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(time,_one_0,JMI_TRUE,JMI_FALSE),JMI_TRUE,_x_2,(COND_EXP_EQ(COND_EXP_LE(time,_two_1,JMI_TRUE,JMI_FALSE),JMI_TRUE,(  - ( AD_WRAP_LITERAL(2) ) ) * ( _x_2 ),( AD_WRAP_LITERAL(3) ) * ( _x_2 ))))) - (_y_3);
")})));

  parameter Real one = 1;
  parameter Real two = 2;
  Real x(start=0.1,fixed=true);
  Real y = noEvent(if time <= one then x else if time <= two then -2*x else 3*x);
equation
  der(x) = y; 
end CCodeGenTest5;

model CCodeGenTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest6",
         description="Test of code generation",
         template="
$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
         generatedCode="
    (*res)[0] = _one_1 - (time);
    (*res)[1] = _two_2 - (time);

    (*res)[0] = _one_1 - (time);
    (*res)[1] = _two_2 - (time);
    (*res)[2] = _p_0 - (_one_1);
")})));

  parameter Real p=1;
  parameter Real one = 1;
  parameter Real two = 2;
  Real x(start=0.1,fixed=true);
  Real y = if time <= one then x else if time <= two then -2*x else 3*x;
  Real z;
initial equation
  z = if p>=one then one else two; 
equation
  der(x) = y; 
  der(z) = -z;
end CCodeGenTest6;

model CCodeGenTest7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest7",
         description="Test of code generation. Verify that no event indicators are generated from relational expressions inside noEvent operators.",
         template="
$C_DAE_equation_residuals$
$C_DAE_event_indicator_residuals$
",
         generatedCode="
    (*res)[0] = _y_1 - (_der_x_2);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(2),JMI_TRUE,JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(0),(CO
ND_EXP_EQ(COND_EXP_GE(AD_WRAP_LITERAL(3),AD_WRAP_LITERAL(4),JMI_TRUE,JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(1),(COND_EXP_EQ(COND_EXP_
LT(AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(2),JMI_TRUE,JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(2),(COND_EXP_EQ(COND_EXP_GT(AD_WRAP_LITERAL(
3),AD_WRAP_LITERAL(4),JMI_TRUE,JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(4),(COND_EXP_EQ(COND_EXP_EQ(AD_WRAP_LITERAL(4),AD_WRAP_LITERAL(
3),JMI_TRUE,JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(4),AD_WRAP_LITERAL(7))))))))))) - (_y_1);
")})));

  Real x(start=0);
  Real y = noEvent(if 1 <= 2 then 0 else if 3 >= 4 then 1 
   else if 1 < 2 then 2 else if 3 > 4 then 4 
   else if 4 == 3 then 4 else 7);
equation
 der(x) = y; 
end CCodeGenTest7;

model CCodeGenTest8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest8",
         description="Test of code generation",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = (COND_EXP_EQ(_sw(0),JMI_TRUE, - ( AD_WRAP_LITERAL(1) ) + _y_1, - ( _y_1 ))) - (_x_0);
    (*res)[1] = _z_2 + _x_0 + (COND_EXP_EQ(_sw(1),JMI_TRUE, - ( AD_WRAP_LITERAL(3) ),AD_WRAP_LITERAL(3))) - (_y_1);
    (*res)[2] =  - ( _y_1 ) - ( _x_0 ) + (COND_EXP_EQ(_sw(2),JMI_TRUE, - ( AD_WRAP_LITERAL(1) ),AD_WRAP_LITERAL(1))) - (_z_2);
")})));

  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
equation
   x = if time>=1 then (-1 + y) else  (- y);
   y = z + x +(if z>=-1.5 then -3 else 3);
   z = -y  - x + (if y>=0.5 then -1 else 1);

end CCodeGenTest8;

model CCodeGenTest9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest9",
         description="Test of code generation",
         template="$C_DAE_initial_equation_residuals$
$C_DAE_initial_event_indicator_residuals$",
         generatedCode="
    (*res)[0] =  - ( _x_0 ) - (_der_x_3);
    (*res)[1] =  - ( _y_1 ) - (_der_y_4);
    (*res)[2] =  - ( _z_2 ) - (_der_z_5);
    (*res)[3] = (COND_EXP_EQ(COND_EXP_GE(time,AD_WRAP_LITERAL(1),JMI_TRUE,JMI_FALSE),JMI_TRUE, - ( AD_WRAP_LITERAL(1) ) + _y_1, - 
( _y_1 ))) - (_x_0);
    (*res)[4] = _z_2 + _x_0 + (COND_EXP_EQ(COND_EXP_GE(_z_2, - ( AD_WRAP_LITERAL(1.5) ),JMI_TRUE,JMI_FALSE),JMI_TRUE, - ( AD_WRAP_
LITERAL(3) ),AD_WRAP_LITERAL(3))) - (_y_1);
    (*res)[5] =  - ( _y_1 ) - ( _x_0 ) + (COND_EXP_EQ(_sw_init(0),JMI_TRUE, - ( AD_WRAP_LITERAL(1) ),AD_WRAP_LITERAL(1))) - (_z_2);
    (*res)[0] = _y_1 - (AD_WRAP_LITERAL(0.5));
")})));

  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
initial equation
   x = noEvent(if time>=1 then (-1 + y) else  (- y));
   y = noEvent(z + x +(if z>=-1.5 then -3 else 3));
   z = -y  - x + (if y>=0.5 then -1 else 1);
equation
   der(x) = -x;
   der(y) = -y;
   der(z) = -z;
end CCodeGenTest9;

model CCodeGenTest10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest10",
         description="Test of code generation",
         template="$C_DAE_initial_equation_residuals$
$C_DAE_initial_event_indicator_residuals$",
         generatedCode="
    (*res)[0] =  - ( _x_0 ) - (_der_x_3);
    (*res)[1] =  - ( _y_1 ) - (_der_y_4);
    (*res)[2] =  - ( _z_2 ) - (_der_z_5);
    (*res)[3] = (COND_EXP_EQ(_sw_init(0),JMI_TRUE, - ( AD_WRAP_LITERAL(1) ) + _y_1, - ( _y_1 ))) - (_x_0);
    (*res)[4] = _z_2 + _x_0 + (COND_EXP_EQ(_sw_init(1),JMI_TRUE, - ( AD_WRAP_LITERAL(3) ),AD_WRAP_LITERAL(3))) - (_y_1);
    (*res)[5] =  - ( _y_1 ) - ( _x_0 ) + (COND_EXP_EQ(_sw_init(2),JMI_TRUE, - ( AD_WRAP_LITERAL(1) ),AD_WRAP_LITERAL(1))) - (_z_2);
    (*res)[0] = time - (AD_WRAP_LITERAL(1));
    (*res)[1] = _z_2 - ( - ( AD_WRAP_LITERAL(1.5) ));
    (*res)[2] = _y_1 - (AD_WRAP_LITERAL(0.5));
")})));

  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
initial equation
   x = if time>=1 then (-1 + y) else  (- y);
   y = z + x +(if z>=-1.5 then -3 else 3);
   z = -y  - x + (if y>=0.5 then -1 else 1);
equation
   der(x) = -x;
   der(y) = -y;
   der(z) = -z;
end CCodeGenTest10;

model CCodeGenTest11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest11",
         description="C code generation: the '<>' operator",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = 1 - (_x_0);
    (*res)[1] = 2 - (_y_1);
    (*res)[2] = (COND_EXP_EQ(COND_EXP_EQ(_x_0, _y_1, JMI_FALSE, JMI_TRUE),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_z_2);
")})));

 Integer x = 1;
 Integer y = 2;
 Real z = noEvent(if x <> y then 1.0 else 2.0);
end CCodeGenTest11;

model CCodeGenTest12

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenTest12",
         description="C code generation: test that x^2 is represented by x*x in the generated code. ",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = pow(_x_0 - ( 0.3 ),0.3) + ((_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(
_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))*(_x_0 - ( 0.3 ))) - (_der_x_1);
")})));

  Real x(start=1,fixed=true);
equation
  der(x) = (x-0.3)^0.3 + (x-0.3)^10;
end CCodeGenTest12;

model CLogExp1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CLogExp1",
         description="C code generation for logical operators: and",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = JMI_FALSE - (_y_1);
    (*res)[2] = (COND_EXP_EQ(LOG_EXP_AND(_x_0, _y_1),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_z_2);
")})));

 Boolean x = true;
 Boolean y = false;
 Real z = noEvent(if x and y then 1.0 else 2.0);
end CLogExp1;


model CLogExp2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CLogExp2",
         description="C code generation for logical operators: or",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = JMI_FALSE - (_y_1);
    (*res)[2] = (COND_EXP_EQ(LOG_EXP_OR(_x_0, _y_1),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_z_2);
")})));

 Boolean x = true;
 Boolean y = false;
 Real z = noEvent(if x or y then 1.0 else 2.0);
end CLogExp2;


model CLogExp3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CLogExp3",
         description="C code generation for logical operators: not",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = (COND_EXP_EQ(LOG_EXP_NOT(_x_0),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_y_1);
")})));

 Boolean x = true;
 Real y = noEvent(if not x then 1.0 else 2.0);
end CLogExp3;




model CCodeGenDiscreteVariables1

 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenDiscreteVariables1",
         description="Test C code generation of discrete variables.",
         template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
         generatedCode="
#define _c1_0 ((*(jmi->z))[jmi->offs_real_ci+0])
#define _c2_1 ((*(jmi->z))[jmi->offs_real_ci+1])
#define _p1_2 ((*(jmi->z))[jmi->offs_real_pi+0])
#define _p2_15 ((*(jmi->z))[jmi->offs_real_pd+0])
#define _ci1_6 ((*(jmi->z))[jmi->offs_integer_ci+0])
#define _ci2_7 ((*(jmi->z))[jmi->offs_integer_ci+1])
#define _pi1_8 ((*(jmi->z))[jmi->offs_integer_pi+0])
#define _pi2_16 ((*(jmi->z))[jmi->offs_integer_pd+0])
#define _cb1_10 ((*(jmi->z))[jmi->offs_boolean_ci+0])
#define _cb2_11 ((*(jmi->z))[jmi->offs_boolean_ci+1])
#define _pb1_12 ((*(jmi->z))[jmi->offs_boolean_pi+0])
#define _pb2_17 ((*(jmi->z))[jmi->offs_boolean_pd+0])
#define _der_x_14 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _x_4 ((*(jmi->z))[jmi->offs_real_x+0])
#define _w_5 ((*(jmi->z))[jmi->offs_real_w+0])
#define time ((*(jmi->z))[jmi->offs_t])
#define _rd2_3 ((*(jmi->z))[jmi->offs_real_d+0])
#define _rid2_9 ((*(jmi->z))[jmi->offs_integer_d+0])
#define _rbd2_13 ((*(jmi->z))[jmi->offs_boolean_d+0])

    (*res)[0] =  - ( _x_4 ) - (_der_x_14);
    (*res)[1] = 4 - (_rd2_3);
    (*res)[2] = 4 - (_w_5);
    (*res)[3] = 4 - (_rid2_9);
    (*res)[4] = JMI_FALSE - (_rbd2_13);


")})));

  constant Real c1 = 1;
  constant Real c2 = c1;
  parameter Real p1 = 1;
  parameter Real p2 = p1;
  discrete Real rd1 = 4;
  discrete Real rd2 = rd1;
  Real x(start=1);
  Real w = 4;

  constant Integer ci1 = 1;
  constant Integer ci2 = ci1;
  parameter Integer pi1 = 1;
  parameter Integer pi2 = pi1;
  discrete Integer rid1 = 4;
  discrete Integer rid2 = rid1;

  constant Boolean cb1 = true;
  constant Boolean cb2 = cb1;
  parameter Boolean pb1 = true;
  parameter Boolean pb2 = pb1;
  discrete Boolean rbd1 = false;
  discrete Boolean rbd2 = rbd1;

equation
  der(x) = -x;

end CCodeGenDiscreteVariables1;

model CCodeGenUniqueNames
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenUniqueNames",
         description="Test that unique names are generated for each variable",
         template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
         generatedCode="
#define _der_x_y_3 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _x_y_0 ((*(jmi->z))[jmi->offs_real_x+0])
#define _x_y_1 ((*(jmi->z))[jmi->offs_real_w+0])
#define _der_x_y_2 ((*(jmi->z))[jmi->offs_real_w+1])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = 1 - (_x_y_0);
    (*res)[1] = _x_y_0 + 2 - (_x_y_1);
    (*res)[2] = _der_x_y_3 - ( 1 ) - (_der_x_y_2);
")})));

 model A
  Real y;
 end A;
 
 Real x_y = 1;
 A x(y = x_y + 2);
 Real der_x_y = der(x_y) - 1;
end CCodeGenUniqueNames;


model CCodeGenDotOp
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenDotOp",
         description="C code generation of dot operators (.+, .*, etc)",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = jmi_divide(( _y_1_1_4 ) * ( _y_1_1_4 ),pow(_y_1_1_4 + _y_1_1_4 - ( 2 ),_y_1_1_4),\"Divide by zero: ( ( y[1,1] ) .* ( y[1,1] ) ) ./ ( ( y[1,1] .+ y[1,1] .- ( 2 ) ) .^ y[1,1] )\") - (_x_1_1_0);
    (*res)[1] = jmi_divide(( _y_1_2_5 ) * ( _y_1_2_5 ),pow(_y_1_2_5 + _y_1_2_5 - ( 2 ),_y_1_2_5),\"Divide by zero: ( ( y[1,2] ) .* ( y[1,2] ) ) ./ ( ( y[1,2] .+ y[1,2] .- ( 2 ) ) .^ y[1,2] )\") - (_x_1_2_1);
    (*res)[2] = jmi_divide(( _y_2_1_6 ) * ( _y_2_1_6 ),pow(_y_2_1_6 + _y_2_1_6 - ( 2 ),_y_2_1_6),\"Divide by zero: ( ( y[2,1] ) .* ( y[2,1] ) ) ./ ( ( y[2,1] .+ y[2,1] .- ( 2 ) ) .^ y[2,1] )\") - (_x_2_1_2);
    (*res)[3] = jmi_divide(( _y_2_2_7 ) * ( _y_2_2_7 ),pow(_y_2_2_7 + _y_2_2_7 - ( 2 ),_y_2_2_7),\"Divide by zero: ( ( y[2,2] ) .* ( y[2,2] ) ) ./ ( ( y[2,2] .+ y[2,2] .- ( 2 ) ) .^ y[2,2] )\") - (_x_2_2_3);
    (*res)[4] = 1 - (_y_1_1_4);
    (*res)[5] = 2 - (_y_1_2_5);
    (*res)[6] = 3 - (_y_2_1_6);
    (*res)[7] = 4 - (_y_2_2_7);
")})));

 Real x[2,2] = y .* y ./ (y .+ y .- 2) .^ y;
 Real y[2,2] = {{1,2},{3,4}};
end CCodeGenDotOp;



model CCodeGenMinMax
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CCodeGenMinMax",
         description="C code generation of min() and max()",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = 1 - (_x_1_1_0);
    (*res)[1] = 2 - (_x_1_2_1);
    (*res)[2] = 3 - (_x_2_1_2);
    (*res)[3] = 4 - (_x_2_2_3);
    (*res)[4] = jmi_min(jmi_min(jmi_min(_x_1_1_0, _x_1_2_1), _x_2_1_2), _x_2_2_3) - (_y1_4);
    (*res)[5] = jmi_min(1, 2) - (_y2_5);
    (*res)[6] = jmi_max(jmi_max(jmi_max(_x_1_1_0, _x_1_2_1), _x_2_1_2), _x_2_2_3) - (_y3_6);
    (*res)[7] = jmi_max(1, 2) - (_y4_7);
")})));

 Real x[2,2] = {{1,2},{3,4}};
 Real y1 = min(x);
 Real y2 = min(1, 2);
 Real y3 = max(x);
 Real y4 = max(1, 2);
end CCodeGenMinMax;



/* ====================== Function tests =================== */

/* Functions used in tests */
function TestFunction0
 output Real o1 = 0;
algorithm
end TestFunction0;

function TestFunction1
 input Real i1 = 0;
 output Real o1 = i1;
algorithm
end TestFunction1;

function TestFunction2
 input Real i1 = 0;
 input Real i2 = 0;
 output Real o1 = 0;
 output Real o2 = i2;
algorithm
 o1 := i1;
end TestFunction2;

function TestFunction3
 input Real i1;
 input Real i2;
 input Real i3 = 0;
 output Real o1 = i1 + i2 + i3;
 output Real o2 = i2 + i3;
 output Real o3 = i1 + i2;
algorithm
end TestFunction3;

function TestFunctionNoOut
 input Real i1;
algorithm
end TestFunctionNoOut;

function TestFunctionCallingFunction
 input Real i1;
 output Real o1;
algorithm
 o1 := TestFunction1(i1);
end TestFunctionCallingFunction;

function TestFunctionRecursive
 input Integer i1;
 output Integer o1;
algorithm
 if i1 < 3 then
  o1 := 1;
 else
  o1 := TestFunctionRecursive(i1 - 1) + TestFunctionRecursive(i1 - 2);
 end if;
end TestFunctionRecursive;


/* Function tests */
model CFunctionTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest1",
         description="Test of code generation",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
    jmi_ad_var_t o1_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction1_def(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp(2.0) - (_x_0);
")})));

 Real x;
equation
 x = TestFunction1(2.0);
end CFunctionTest1;

model CFunctionTest2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest2",
         description="C code gen: functions: using multiple outputs",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
   jmi_ad_var_t o1_v;
   jmi_ad_var_t o2_v;
   o1_v = 0;
   o2_v = i2_v;
   o1_v = i1_v;
   if (o1_o != NULL) *o1_o = o1_v;
   if (o2_o != NULL) *o2_o = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}


    jmi_ad_var_t tmp_var_0;
    jmi_ad_var_t tmp_var_1;
    func_CCodeGenTests_TestFunction2_def(1, 2, &tmp_var_0, &tmp_var_1);
    (*res)[0] = tmp_var_0 - (_x_0);
    (*res)[1] = tmp_var_1 - (_y_1);
")})));

 Real x;
 Real y;
equation
 (x, y) = TestFunction2(1, 2);
end CFunctionTest2;

model CFunctionTest3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest3",
         description="C code gen: functions: two calls to same function",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
   jmi_ad_var_t o1_v;
   jmi_ad_var_t o2_v;
   o1_v = 0;
   o2_v = i2_v;
   o1_v = i1_v;
   if (o1_o != NULL) *o1_o = o1_v;
   if (o2_o != NULL) *o2_o = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction2_exp(1, 0) - (_x_0);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp(2, 3) - (_y_1);
")})));

 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction2(1);
end CFunctionTest3;

model CFunctionTest4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest4",
         description="C code gen: functions: calls to two functions",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);
void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
   jmi_ad_var_t o1_v;
   jmi_ad_var_t o2_v;
   o1_v = 0;
   o2_v = i2_v;
   o1_v = i1_v;
   if (o1_o != NULL) *o1_o = o1_v;
   if (o2_o != NULL) *o2_o = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}

void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
   jmi_ad_var_t o1_v;
   o1_v = i1_v;
   if (o1_o != NULL) *o1_o = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction1_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp(( _y_1 ) * ( 2 )) - (_x_0);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp(2, 3) - (_y_1);
")})));

 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction1(y * 2);
end CFunctionTest4;

model CFunctionTest5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest5",
         description="C code gen: functions: fewer components assigned than outputs",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v);

void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o) {
   jmi_ad_var_t o1_v;
   jmi_ad_var_t o2_v;
   jmi_ad_var_t o3_v;
   o1_v = i1_v + i2_v + i3_v;
   o2_v = i2_v + i3_v;
   o3_v = i1_v + i2_v;
   if (o1_o != NULL) *o1_o = o1_v;
   if (o2_o != NULL) *o2_o = o2_v;
   if (o3_o != NULL) *o3_o = o3_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction3_def(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
   return o1_v;
}


    jmi_ad_var_t tmp_var_0;
    jmi_ad_var_t tmp_var_1;
    func_CCodeGenTests_TestFunction3_def(1, 2, 3, &tmp_var_0, &tmp_var_1, NULL);
    (*res)[0] = tmp_var_0 - (_x_0);
    (*res)[1] = tmp_var_1 - (_y_1);
")})));

  Real x;
  Real y;
equation
  (x, y) = TestFunction3(1, 2, 3);
end CFunctionTest5;

model CFunctionTest6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest6",
         description="C code gen: functions: one output skipped",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v);

void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o) {
   jmi_ad_var_t o1_v;
   jmi_ad_var_t o2_v;
   jmi_ad_var_t o3_v;
   o1_v = i1_v + i2_v + i3_v;
   o2_v = i2_v + i3_v;
   o3_v = i1_v + i2_v;
   if (o1_o != NULL) *o1_o = o1_v;
   if (o2_o != NULL) *o2_o = o2_v;
   if (o3_o != NULL) *o3_o = o3_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction3_def(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
   return o1_v;
}


    jmi_ad_var_t tmp_var_0;
    jmi_ad_var_t tmp_var_1;
    func_CCodeGenTests_TestFunction3_def(1, 2, 3, &tmp_var_0, NULL, &tmp_var_1);
    (*res)[0] = tmp_var_0 - (_x_0);
    (*res)[1] = tmp_var_1 - (_z_1);
")})));

  Real x;
  Real z;
equation
  (x, , z) = TestFunction3(1, 2, 3);
end CFunctionTest6;

model CFunctionTest7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest7",
         description="C code gen: functions: no components assigned",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
   jmi_ad_var_t o1_v;
   jmi_ad_var_t o2_v;
   o1_v = 0;
   o2_v = i2_v;
   o1_v = i1_v;
   if (o1_o != NULL) *o1_o = o1_v;
   if (o2_o != NULL) *o2_o = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}


    func_CCodeGenTests_TestFunction2_def(1, 2, NULL, NULL);
")})));

equation
  TestFunction2(1, 2);
end CFunctionTest7;

model CFunctionTest8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest8",
         description="C code gen: functions: function calling other function",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunctionCallingFunction_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunctionCallingFunction_exp(jmi_ad_var_t i1_v);
void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionCallingFunction_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
   jmi_ad_var_t o1_v;
   o1_v = func_CCodeGenTests_TestFunction1_exp(i1_v);
   if (o1_o != NULL) *o1_o = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunctionCallingFunction_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunctionCallingFunction_def(i1_v, &o1_v);
   return o1_v;
}

void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
   jmi_ad_var_t o1_v;
   o1_v = i1_v;
   if (o1_o != NULL) *o1_o = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction1_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionCallingFunction_exp(1) - (_x_0);
")})));

 Real x = TestFunctionCallingFunction(1);
end CFunctionTest8;


/* TODO: Why is this commented out?
model CFunctionTest9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest9",
         description="C code gen: functions:",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunctionRecursive_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunctionRecursive_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionRecursive_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
   jmi_ad_var_t o1_v;
   if (i1_v < 3) {
       o1_v = 1;
   } else {
       o1_v = func_CCodeGenTests_TestFunctionRecursive_exp(i1_v - ( 1 )) + func_CCodeGenTests_TestFunctionRecursive_exp(i1_v - ( 2 ));
   }
   if (o1_o != NULL) *o1_o = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunctionRecursive_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunctionRecursive_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionRecursive_exp(5) - (_x_0);
")})));

 Real x = TestFunctionRecursive(5);
end CFunctionTest9;
*/

model CFunctionTest10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest10",
         description="C code gen: functions: no inputs",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunction0_def(jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction0_exp();

void func_CCodeGenTests_TestFunction0_def(jmi_ad_var_t* o1_o) {
   jmi_ad_var_t o1_v;
   o1_v = 0;
   if (o1_o != NULL) *o1_o = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction0_exp() {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunction0_def(&o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction0_exp() - (_x_0);
")})));

 Real x = TestFunction0();
end CFunctionTest10;

model CFunctionTest11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CFunctionTest11",
         description="C code gen: functions: no outputs",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunctionNoOut_def(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionNoOut_def(jmi_ad_var_t i1_v) {
   return;
}


    func_CCodeGenTests_TestFunctionNoOut_def(1);
")})));

equation
 TestFunctionNoOut(1);
end CFunctionTest11;



model CForLoop1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CForLoop1",
         description="C code generation for for loops: range exp",
         template="
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CForLoop1_f_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    o_v = 1.0;
    x_v = 0;
    for (jmi_ad_var_t i_i = 1; i_i <= 3; i_i += 1) {
        x_v = x_v + i_i;
    }
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CForLoop1_f_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CForLoop1_f_def(&o_v);
    return o_v;
}

")})));

 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 1:3 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();
end CForLoop1;


model CForLoop2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CForLoop2",
         description="C code generation for for loops: generic exp",
         template="
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CForLoop2_f_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    o_v = 1.0;
    x_v = 0;
    jmi_ad_var_t i_ia[] = { 2, 3, 5 };
    for (int i_ii = 0; i_ii < 3; i_ii++) {
        jmi_ad_var_t i_i = i_ia[i_ii];
        x_v = x_v + i_i;
    }
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CForLoop2_f_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CForLoop2_f_def(&o_v);
    return o_v;
}

")})));

 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in {2,3,5} loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();
end CForLoop2;



model CArrayInput1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput1",
         description="C code generation: array inputs to functions: basic test",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput1_f_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput1_f_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput1_f_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput1_f_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput1_f_def(inp_a, &out_v);
    return out_v;
}


    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    (*res)[0] = func_CCodeGenTests_CArrayInput1_f_exp(tmp_1) - (_x_0);
")})));

 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = f(1:3);
end CArrayInput1;


model CArrayInput2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput2",
         description="C code generation: array inputs to functions: expressions around call",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput2_f_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput2_f_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput2_f_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput2_f_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput2_f_def(inp_a, &out_v);
    return out_v;
}


    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0 + 3;
    jmi_array_ref_1(tmp_1, 2) = 2.0 + 5;
    jmi_array_ref_1(tmp_1, 3) = 3.0 + 7;
    (*res)[0] = 2 + ( 5 ) * ( func_CCodeGenTests_CArrayInput2_f_exp(tmp_1) ) - (_x_0);
")})));

 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = 2 + 5 * f((1:3) + {3, 5, 7});
end CArrayInput2;


model CArrayInput3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput3",
         description="C code generation: array inputs to functions: nestled calls",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput3_f_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput3_f_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput3_f_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput3_f_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput3_f_def(inp_a, &out_v);
    return out_v;
}


    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    JMI_ARRAY_DECL(tmp_2, 3, 3)
    jmi_array_ref_1(tmp_2, 1) = 4.0;
    jmi_array_ref_1(tmp_2, 2) = 5.0;
    jmi_array_ref_1(tmp_2, 3) = 6.0;
    JMI_ARRAY_DECL(tmp_3, 3, 3)
    jmi_array_ref_1(tmp_3, 1) = 7.0;
    jmi_array_ref_1(tmp_3, 2) = 8.0;
    jmi_array_ref_1(tmp_3, 3) = 9.0;
    JMI_ARRAY_DECL(tmp_4, 3, 3)
    jmi_array_ref_1(tmp_4, 1) = func_CCodeGenTests_CArrayInput3_f_exp(tmp_1);
    jmi_array_ref_1(tmp_4, 2) = func_CCodeGenTests_CArrayInput3_f_exp(tmp_2);
    jmi_array_ref_1(tmp_4, 3) = func_CCodeGenTests_CArrayInput3_f_exp(tmp_3);
    (*res)[0] = func_CCodeGenTests_CArrayInput3_f_exp(tmp_4) - (_x_0);
")})));

 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = f({f(1:3),f(4:6),f(7:9)});
end CArrayInput3;


model CArrayInput4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput4",
         description="C code generation: array inputs to functions: in assign statement",
         template="
$C_function_headers$
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput4_f1_def(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f1_exp();
void func_CCodeGenTests_CArrayInput4_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f2_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput4_f1_def(jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = 1.0;
    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    out_v = func_CCodeGenTests_CArrayInput4_f2_exp(tmp_1);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f1_exp() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput4_f1_def(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput4_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f2_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput4_f2_def(inp_a, &out_v);
    return out_v;
}

")})));

 function f1
  output Real out = 1.0;
 algorithm
  out := f2(1:3);
 end f1;
 
 function f2
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();
end CArrayInput4;


model CArrayInput5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput5",
         description="C code generation: array inputs to functions: function call stmt",
         template="
$C_function_headers$
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput5_f1_def(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f1_exp();
void func_CCodeGenTests_CArrayInput5_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out1_o, jmi_ad_var_t* out2_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f2_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput5_f1_def(jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    jmi_ad_var_t t_v;
    out_v = 1.0;
    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    func_CCodeGenTests_CArrayInput5_f2_def(tmp_1, &out_v, &t_v);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f1_exp() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput5_f1_def(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput5_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out1_o, jmi_ad_var_t* out2_o) {
    jmi_ad_var_t out1_v;
    jmi_ad_var_t out2_v;
    out1_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    out2_v = jmi_max(jmi_max(jmi_array_val_1(inp_a, 1), jmi_array_val_1(inp_a, 2)), jmi_array_val_1(inp_a, 3));
    if (out1_o != NULL) *out1_o = out1_v;
    if (out2_o != NULL) *out2_o = out2_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f2_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out1_v;
    func_CCodeGenTests_CArrayInput5_f2_def(inp_a, &out1_v, NULL);
    return out1_v;
}

")})));

 function f1
  output Real out = 1.0;
  protected Real t;
 algorithm
  (out, t) := f2(1:3);
 end f1;
 
 function f2
  input Real inp[3];
  output Real out1 = sum(inp);
  output Real out2 = max(inp);
 algorithm
 end f2;
 
 Real x = f1();
end CArrayInput5;


model CArrayInput6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput6",
         description="C code generation: array inputs to functions: if statement",
         template="
$C_function_headers$
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput6_f1_def(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f1_exp();
void func_CCodeGenTests_CArrayInput6_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f2_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput6_f1_def(jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = 1.0;
    JMI_ARRAY_DECL(tmp_1, 2, 2)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    JMI_ARRAY_DECL(tmp_2, 2, 2)
    jmi_array_ref_1(tmp_2, 1) = 3.0;
    jmi_array_ref_1(tmp_2, 2) = 4.0;
    if (COND_EXP_LT(func_CCodeGenTests_CArrayInput6_f2_exp(tmp_1),4,JMI_TRUE,JMI_FALSE)) {
        JMI_ARRAY_DECL(tmp_3, 2, 2)
        jmi_array_ref_1(tmp_3, 1) = 5.0;
        jmi_array_ref_1(tmp_3, 2) = 6.0;
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp(tmp_3);
    } else if (COND_EXP_GT(func_CCodeGenTests_CArrayInput6_f2_exp(tmp_2),5,JMI_TRUE,JMI_FALSE)) {
        JMI_ARRAY_DECL(tmp_4, 2, 2)
        jmi_array_ref_1(tmp_4, 1) = 7.0;
        jmi_array_ref_1(tmp_4, 2) = 8.0;
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp(tmp_4);
    } else {
        JMI_ARRAY_DECL(tmp_5, 2, 2)
        jmi_array_ref_1(tmp_5, 1) = 9.0;
        jmi_array_ref_1(tmp_5, 2) = 10.0;
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp(tmp_5);
    }
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f1_exp() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput6_f1_def(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput6_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f2_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput6_f2_def(inp_a, &out_v);
    return out_v;
}

")})));

 function f1
  output Real out = 1.0;
 algorithm
  if f2(1:2) < 4 then
   out := f2(5:6);
  elseif f2(3:4) > 5 then
   out := f2(7:8);
  else
   out := f2(9:10);
  end if;
 end f1;
 
 function f2
  input Real inp[2];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();
end CArrayInput6;


model CArrayInput7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput7",
         description="C code generation: array inputs to functions: while stmt",
         template="
$C_function_headers$
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput7_f1_def(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f1_exp();
void func_CCodeGenTests_CArrayInput7_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f2_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput7_f1_def(jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = 1.0;
    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    while (COND_EXP_LT(func_CCodeGenTests_CArrayInput7_f2_exp(tmp_1),2,JMI_TRUE,JMI_FALSE)) {
        JMI_ARRAY_DECL(tmp_2, 3, 3)
        jmi_array_ref_1(tmp_2, 1) = 4.0;
        jmi_array_ref_1(tmp_2, 2) = 5.0;
        jmi_array_ref_1(tmp_2, 3) = 6.0;
        out_v = func_CCodeGenTests_CArrayInput7_f2_exp(tmp_2);
}
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f1_exp() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput7_f1_def(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput7_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f2_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput7_f2_def(inp_a, &out_v);
    return out_v;
}

")})));

 function f1
  output Real out = 1.0;
 algorithm
  while f2(1:3) < 2 loop
   out := f2(4:6);
  end while;
 end f1;
 
 function f2
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();
end CArrayInput7;


model CArrayInput8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayInput8",
         description="C code generation: array inputs to functions: for stmt",
         template="
$C_function_headers$
$C_functions$
",
         generatedCode="
void func_CCodeGenTests_CArrayInput8_f1_def(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f1_exp();
void func_CCodeGenTests_CArrayInput8_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f2_exp(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput8_f1_def(jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = 1.0;
    JMI_ARRAY_DECL(tmp_1, 3, 3)
    jmi_array_ref_1(tmp_1, 1) = 1.0;
    jmi_array_ref_1(tmp_1, 2) = 2.0;
    jmi_array_ref_1(tmp_1, 3) = 3.0;
    JMI_ARRAY_DECL(tmp_2, 3, 3)
    jmi_array_ref_1(tmp_2, 1) = 4.0;
    jmi_array_ref_1(tmp_2, 2) = 5.0;
    jmi_array_ref_1(tmp_2, 3) = 6.0;
    jmi_ad_var_t i_ia[] = { func_CCodeGenTests_CArrayInput8_f2_exp(tmp_1), func_CCodeGenTests_CArrayInput8_f2_exp(tmp_2) };
    for (int i_ii = 0; i_ii < 2; i_ii++) {
        jmi_ad_var_t i_i = i_ia[i_ii];
        JMI_ARRAY_DECL(tmp_3, 3, 3)
        jmi_array_ref_1(tmp_3, 1) = 7.0;
        jmi_array_ref_1(tmp_3, 2) = 8.0;
        jmi_array_ref_1(tmp_3, 3) = 9.0;
        out_v = func_CCodeGenTests_CArrayInput8_f2_exp(tmp_3);
    }
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f1_exp() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput8_f1_def(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput8_f2_def(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f2_exp(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput8_f2_def(inp_a, &out_v);
    return out_v;
}

")})));

 function f1
  output Real out = 1.0;
 algorithm
  for i in {f2(1:3), f2(4:6)} loop
   out := f2(7:9);
  end for;
 end f1;
 
 function f2
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f2;
 
 Real x = f1();
end CArrayInput8;


model CArrayOutputs1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayOutputs1",
         description="C code generation: array outputs from functions: in equation",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayOutputs1_f_def(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs1_f_def(jmi_array_t* o_a) {
    if (o_a == NULL) {
        JMI_ARRAY_DECL(o_an, 2, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 2;
    return;
}


    JMI_ARRAY_DECL(tmp_1, 2, 2)
    func_CCodeGenTests_CArrayOutputs1_f_def(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - (_x_1_0);
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - (_x_2_1);
")})));

 function f
  output Real o[2] = {1,2};
 algorithm
 end f;
 
 Real x[2] = f();
end CArrayOutputs1;


model CArrayOutputs2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayOutputs2",
         description="C code generation: array outputs from functions: in expression in equation",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayOutputs2_f_def(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs2_f_def(jmi_array_t* o_a) {
     if (o_a == NULL) {
        JMI_ARRAY_DECL(o_an, 2, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 2;
    return;
}


    JMI_ARRAY_DECL(tmp_1, 2, 2)
    func_CCodeGenTests_CArrayOutputs2_f_def(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - (_temp_1_1_1);
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - (_temp_1_2_2);
    (*res)[2] = ( _temp_1_1_1 ) * ( 3 ) + ( _temp_1_2_2 ) * ( 4 ) - (_x_0);
")})));

 function f
  output Real o[2] = {1,2};
 algorithm
 end f;
 
 Real x;
equation
 x = f() * {3,4};
end CArrayOutputs2;


model CArrayOutputs3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayOutputs3",
         description="C code generation: array outputs from functions: in expression in function",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayOutputs3_f1_def(jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CArrayOutputs3_f1_exp();
void func_CCodeGenTests_CArrayOutputs3_f2_def(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs3_f1_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    JMI_ARRAY_DECL(temp_1_a, 2, 2)
    o_v = 0;
    func_CCodeGenTests_CArrayOutputs3_f2_def(temp_1_a);
    x_v = ( jmi_array_val_1(temp_1_a, 1) ) * ( 3 ) + ( jmi_array_val_1(temp_1_a, 2) ) * ( 4 );
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayOutputs3_f1_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CArrayOutputs3_f1_def(&o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs3_f2_def(jmi_array_t* o_a) {
     if (o_a == NULL) {
        JMI_ARRAY_DECL(o_an, 2, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 2;
    return;
}


    (*res)[0] = func_CCodeGenTests_CArrayOutputs3_f1_exp() - (_x_0);
")})));

 function f1
  output Real o = 0;
  protected Real x;
 algorithm
  x := f2() * {3,4};
 end f1;
 
 function f2
  output Real o[2] = {1,2};
 algorithm
 end f2;
 
 Real x = f1();
end CArrayOutputs3;


model CArrayOutputs4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayOutputs4",
         description="C code generation: array outputs from functions: function call statement",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayOutputs4_f1_def(jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CArrayOutputs4_f1_exp();
void func_CCodeGenTests_CArrayOutputs4_f2_def(jmi_array_t* o1_a, jmi_ad_var_t* o2_o);

void func_CCodeGenTests_CArrayOutputs4_f1_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    JMI_ARRAY_DECL(x_a, 2, 2)
    jmi_ad_var_t y_v;
    o_v = 0;
    func_CCodeGenTests_CArrayOutputs4_f2_def(x_a, &y_v);
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayOutputs4_f1_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CArrayOutputs4_f1_def(&o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs4_f2_def(jmi_array_t* o1_a, jmi_ad_var_t* o2_o) {
    jmi_ad_var_t o2_v;
    if (o1_a == NULL) {
        JMI_ARRAY_DECL(o1_an, 2, 2)
        o1_a = o1_an;
    }
    jmi_array_ref_1(o1_a, 1) = 1;
    jmi_array_ref_1(o1_a, 2) = 2;
    o2_v = 3;
    if (o2_o != NULL) *o2_o = o2_v;
    return;
}


    (*res)[0] = func_CCodeGenTests_CArrayOutputs4_f1_exp() - (_x_0);
")})));

 function f1
  output Real o = 0;
  protected Real x[2];
  protected Real y;
 algorithm
  (x,y) := f2();
 end f1;
 
 function f2
  output Real o1[2] = {1,2};
  output Real o2 = 3;
 algorithm
 end f2;
 
 Real x = f1();
end CArrayOutputs4;


model CArrayOutputs5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CArrayOutputs5",
         description="C code generation: array outputs from functions: passing input array",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CArrayOutputs5_f1_def(jmi_array_t* i_a, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CArrayOutputs5_f1_exp(jmi_array_t* i_a);
void func_CCodeGenTests_CArrayOutputs5_f2_def(jmi_array_t* i_a, jmi_array_t* o1_a, jmi_ad_var_t* o2_o);

void func_CCodeGenTests_CArrayOutputs5_f1_def(jmi_array_t* i_a, jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    JMI_ARRAY_DECL(x_a, 2, 2)
    jmi_ad_var_t y_v;
    o_v = 0;
    func_CCodeGenTests_CArrayOutputs5_f2_def(i_a, x_a, &y_v);
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayOutputs5_f1_exp(jmi_array_t* i_a) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CArrayOutputs5_f1_def(i_a, &o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs5_f2_def(jmi_array_t* i_a, jmi_array_t* o1_a, jmi_ad_var_t* o2_o) {
    jmi_ad_var_t o2_v;
     if (o1_a == NULL) {
        JMI_ARRAY_DECL(o1_an, 2, 2)
        o1_a = o1_an;
    }
    jmi_array_ref_1(o1_a, 1) = jmi_array_val_1(i_a, 1);
    jmi_array_ref_1(o1_a, 2) = jmi_array_val_1(i_a, 2);
    o2_v = 3;
    if (o2_o != NULL) *o2_o = o2_v;
    return;
}


    JMI_ARRAY_DECL(tmp_1, 2, 2)
    jmi_array_ref_1(tmp_1, 1) = 1;
    jmi_array_ref_1(tmp_1, 2) = 2;
    (*res)[0] = func_CCodeGenTests_CArrayOutputs5_f1_exp(tmp_1) - (_x_0);
")})));

 function f1
  input Real i[2];
  output Real o = 0;
  protected Real x[2];
  protected Real y;
 algorithm
  (x, y) := f2(i);
 end f1;
 
 function f2
  input Real i[2];
  output Real o1[2] = i;
  output Real o2 = 3;
 algorithm
 end f2;
 
 Real x = f1({1,2});
end CArrayOutputs5;



model CAbsTest1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CAbsTest1",
         description="C code generation for abs() operator",
         template="$C_DAE_equation_residuals$",
         generatedCode="
    (*res)[0] = jmi_abs(_y_1) - (_x_0);
    (*res)[1] =  - ( 2 ) - (_y_1);
")})));

 Real x = abs(y);
 Real y = -2;
end CAbsTest1;



model CUnknownArray1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CUnknownArray1",
         description="integer() operator:",
         template="$C_functions$",
         generatedCode="
void func_CCodeGenTests_CUnknownArray1_f_def(jmi_array_t* a_a, jmi_array_t* b_a, jmi_array_t* o_a) {
    if (o_a == NULL) {
        JMI_ARRAY_DECL(o_an, 0, size(a, 1))
        o_a = o_an;
    }
    for (jmi_ad_var_t i1_i = 1; i1_i <= jmi_array_size(o_a, 0); i1_i += 1) {
        jmi_array_ref_1(o_a, i1_i) = jmi_array_val_1(a_a, i1_i) + jmi_array_val_1(b_a, i1_i);
    }
    return;
}
")})));

 function f
  input Real a[:];
  input Real b[:];
  output Real o[size(a,1)] = a + b;
 algorithm
 end f;
 
 Real x[2] = f({1,2}, {3,4});
end CUnknownArray1;



model CRecordDecl1
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl1",
         description="C code generation for records: structs: basic test",
         template="$C_records$",
         generatedCode="
typedef struct _A_0_r {
    jmi_ad_var_t a;
    jmi_ad_var_t b;
} A_0_r;
JMI_RECORD_ARRAY_TYPE(A_0_r, A_0_ra)

")})));

 record A
  Real a;
  Real b;
 end A;
 
 A x;
equation
 x.a = 1;
 x.b = 2;
end CRecordDecl1;


model CRecordDecl2
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl2",
         description="C code generation for records: structs: nested records",
         template="$C_records$",
         generatedCode="
typedef struct _B_0_r {
    jmi_ad_var_t c;
} B_0_r;
JMI_RECORD_ARRAY_TYPE(B_0_r, B_0_ra)

typedef struct _A_1_r {
    jmi_ad_var_t a;
    B_0_r* b;
} A_1_r;
JMI_RECORD_ARRAY_TYPE(A_1_r, A_1_ra)

")})));

 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 A x;
equation
 x.a = 1;
 x.b.c = 2;
end CRecordDecl2;


model CRecordDecl3
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl3",
         description="C code generation for records: structs: array in record",
         template="$C_records$",
         generatedCode="
typedef struct _A_0_r {
    jmi_array_t* a;
} A_0_r;
JMI_RECORD_ARRAY_TYPE(A_0_r, A_0_ra)

")})));

 record A
  Real a[2];
 end A;

 A x;
equation
 x.a = {1,2};
end CRecordDecl3;


model CRecordDecl4
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl4",
         description="C code generation for records: structs: array of records",
         template="$C_records$",
         generatedCode="
typedef struct _B_0_r {
    jmi_ad_var_t c;
} B_0_r;
JMI_RECORD_ARRAY_TYPE(B_0_r, B_0_ra)

typedef struct _A_1_r {
    jmi_ad_var_t a;
    B_0_ra* b;
} A_1_r;
JMI_RECORD_ARRAY_TYPE(A_1_r, A_1_ra)

")})));

 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 A x;
equation
 x.a = 1;
 x.b[1].c = 2;
 x.b[2].c = 3;
end CRecordDecl4;


model CRecordDecl5
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl5",
         description="C code generation for records: declarations: basic test",
         template="$C_functions$",
         generatedCode="
void func_CCodeGenTests_CRecordDecl5_f_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    JMI_RECORD_DECL(A_0_r, x_v)
    x_v->a = 1;
    x_v->b = 2;
    o_v = x_v->a;
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl5_f_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl5_f_def(&o_v);
    return o_v;
}

")})));

  function f
  output Real o;
  protected A x = A(1,2);
 algorithm
  o := x.a;
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 Real x = f();
end CRecordDecl5;


model CRecordDecl6
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl6",
         description="C code generation for records: declarations: nestled records",
         template="$C_functions$",
         generatedCode="
void func_CCodeGenTests_CRecordDecl6_f_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    JMI_RECORD_DECL(A_1_r, x_v)
    JMI_RECORD_DECL(B_0_r, tmp_1)
    x_v->b = tmp_1;
    x_v->a = 1;
    x_v->b->c = 2;
    o_v = x_v->b->c;
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl6_f_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl6_f_def(&o_v);
    return o_v;
}

")})));

 function f
  output Real o;
  protected A x = A(1, B(2));
 algorithm
  o := x.b.c;
 end f;
 
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f();
end CRecordDecl6;


model CRecordDecl7
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl7",
         description="C code generation for records: declarations: array in record",
         template="$C_functions$",
         generatedCode="
void func_CCodeGenTests_CRecordDecl7_f_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    JMI_RECORD_DECL(A_0_r, x_v)
    JMI_ARRAY_DECL(tmp_1, 2, 2)
    x_v->a = tmp_1;
    jmi_array_ref_1(x_v->a, 1) = 1;
    jmi_array_ref_1(x_v->a, 2) = 2;
    o_v = jmi_array_val_1(x_v->a, 1);
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl7_f_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl7_f_def(&o_v);
    return o_v;
}

")})));

 function f
  output Real o;
  protected A x = A({1,2});
 algorithm
  o := x.a[1];
 end f;
 
 record A
  Real a[2];
 end A;
 
 Real x = f();
end CRecordDecl7;


model CRecordDecl8
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl8",
         description="C code generation for records: declarations: array of records",
         template="$C_functions$",
         generatedCode="
void func_CCodeGenTests_CRecordDecl8_f_def(jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    JMI_RECORD_ARRAY_DECL(A_1_r, A_1_ra, x_a, 3, 3)
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_1, 2, 2)
    jmi_array_rec_1(x_a, 1)->b = tmp_1;
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_2, 2, 2)
    jmi_array_rec_1(x_a, 2)->b = tmp_2;
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_3, 2, 2)
    jmi_array_rec_1(x_a, 3)->b = tmp_3;
    jmi_array_rec_1(x_a, 1)->a = 1;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 1)->c = 2;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c = 3;
    jmi_array_rec_1(x_a, 2)->a = 4;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 2)->b, 1)->c = 5;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 2)->b, 2)->c = 6;
    jmi_array_rec_1(x_a, 3)->a = 7;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 3)->b, 1)->c = 8;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 3)->b, 2)->c = 9;
    o_v = jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c;
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl8_f_exp() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl8_f_def(&o_v);
    return o_v;
}

")})));

 function f
  output Real o;
  protected A x[3] = {A(1,{B(2),B(3)}),A(4,{B(5),B(6)}),A(7,{B(8),B(9)})};
 algorithm
  o := x[1].b[2].c;
 end f;
 
 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f();
end CRecordDecl8;


model CRecordDecl9
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl9",
         description="C code generation for records: outputs: basic test",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl9_f_def(A_0_r* x_v);
A_0_r* func_CCodeGenTests_CRecordDecl9_f_exp();

void func_CCodeGenTests_CRecordDecl9_f_def(A_0_r* x_v) {
    if (x_v == NULL) {
        JMI_RECORD_DECL(A_0_r, x_vn)
        x_v = x_vn;
    }
    x_v->a = 1;
    x_v->b = 2;
    return;
}

A_0_r* func_CCodeGenTests_CRecordDecl9_f_exp() {
    func_CCodeGenTests_CRecordDecl9_f_def(&x_v);
    return x_v;
}


    JMI_RECORD_DECL(A_0_r, tmp_1)
    func_CCodeGenTests_CRecordDecl9_f_def(tmp_1);
    (*res)[0] = tmp_1->a - (_x_a_0);
    (*res)[1] = tmp_1->b - (_x_b_1);
")})));

 function f
  output A x = A(1,2);
 algorithm
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 A x = f();
end CRecordDecl9;


model CRecordDecl10
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl10",
         description="C code generation for records: outputs: nested arrays",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl10_f_def(A_1_r* x_v);
A_1_r* func_CCodeGenTests_CRecordDecl10_f_exp();

void func_CCodeGenTests_CRecordDecl10_f_def(A_1_r* x_v) {
    if (x_v == NULL) {
        JMI_RECORD_DECL(A_1_r, x_vn)
        JMI_RECORD_DECL(B_0_r, tmp_1)
        x_vn->b = tmp_1;
        x_v = x_vn;
    }
    x_v->a = 1;
    x_v->b->c = 2;
    return;
}

A_1_r* func_CCodeGenTests_CRecordDecl10_f_exp() {
    func_CCodeGenTests_CRecordDecl10_f_def(&x_v);
    return x_v;
}


    JMI_RECORD_DECL(A_1_r, tmp_1)
    JMI_RECORD_DECL(B_0_r, tmp_2)
    tmp_1->b = tmp_2;
    func_CCodeGenTests_CRecordDecl10_f_def(tmp_1);
    (*res)[0] = tmp_1->a - (_x_a_0);
    (*res)[1] = tmp_1->b->c - (_x_b_c_1);
")})));

  function f
  output A x = A(1, B(2));
 algorithm
 end f;
 
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 A x = f();
end CRecordDecl10;


model CRecordDecl11
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl11",
         description="C code generation for records: outputs: array in record",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl11_f_def(A_0_r* x_v);
A_0_r* func_CCodeGenTests_CRecordDecl11_f_exp();

void func_CCodeGenTests_CRecordDecl11_f_def(A_0_r* x_v) {
    if (x_v == NULL) {
        JMI_RECORD_DECL(A_0_r, x_vn)
        JMI_ARRAY_DECL(tmp_1, 2, 2)
        x_vn->a = tmp_1;
        x_v = x_vn;
    }
    jmi_array_ref_1(x_v->a, 1) = 1;
    jmi_array_ref_1(x_v->a, 2) = 2;
    return;
}

A_0_r* func_CCodeGenTests_CRecordDecl11_f_exp() {
    func_CCodeGenTests_CRecordDecl11_f_def(&x_v);
    return x_v;
}


    JMI_RECORD_DECL(A_0_r, tmp_1)
    JMI_ARRAY_DECL(tmp_2, 2, 2)
    tmp_1->a = tmp_2;
    func_CCodeGenTests_CRecordDecl11_f_def(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1->a, 1) - (_x_a_1_0);
    (*res)[1] = jmi_array_val_1(tmp_1->a, 2) - (_x_a_2_1);
")})));

  function f
  output A x = A({1,2});
 algorithm
 end f;
 
 record A
  Real a[2];
 end A;
 
 A x = f();
end CRecordDecl11;


model CRecordDecl12
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl12",
         description="C code generation for records: outputs: array of records",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl12_f_def(A_1_ra* x_a);

void func_CCodeGenTests_CRecordDecl12_f_def(A_1_ra* x_a) {
    if (x_a == NULL) {
        JMI_RECORD_ARRAY_DECL(A_1_r, A_1_ra, x_an, 3, 3)
        JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_1, 2, 2)
        jmi_array_rec_1(x_an, 1)->b = tmp_1;
        JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_2, 2, 2)
        jmi_array_rec_1(x_an, 2)->b = tmp_2;
        JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_3, 2, 2)
        jmi_array_rec_1(x_an, 3)->b = tmp_3;
        x_a = x_an;
    }
    jmi_array_rec_1(x_a, 1)->a = 1;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 1)->c = 2;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c = 3;
    jmi_array_rec_1(x_a, 2)->a = 4;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 2)->b, 1)->c = 5;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 2)->b, 2)->c = 6;
    jmi_array_rec_1(x_a, 3)->a = 7;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 3)->b, 1)->c = 8;
    jmi_array_rec_1(jmi_array_rec_1(x_a, 3)->b, 2)->c = 9;
    return;
}


    JMI_RECORD_ARRAY_DECL(A_1_r, A_1_ra, tmp_1, 3, 3)
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_2, 2, 2)
    jmi_array_rec_1(tmp_1, 1)->b = tmp_2;
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_3, 2, 2)
    jmi_array_rec_1(tmp_1, 2)->b = tmp_3;
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_4, 2, 2)
    jmi_array_rec_1(tmp_1, 3)->b = tmp_4;
    func_CCodeGenTests_CRecordDecl12_f_def(tmp_1);
    (*res)[0] = jmi_array_rec_1(tmp_1, 1)->a - (_x_1_a_0);
    (*res)[1] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 1)->c - (_x_1_b_1_c_1);
    (*res)[2] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 2)->c - (_x_1_b_2_c_2);
    (*res)[1] = jmi_array_rec_1(tmp_1, 2)->a - (_x_2_a_3);
    (*res)[2] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 1)->c - (_x_2_b_1_c_4);
    (*res)[3] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 2)->c - (_x_2_b_2_c_5);
    (*res)[2] = jmi_array_rec_1(tmp_1, 3)->a - (_x_3_a_6);
    (*res)[3] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 1)->c - (_x_3_b_1_c_7);
    (*res)[4] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 2)->c - (_x_3_b_2_c_8);
")})));

  function f
  output A x[3] = {A(1,{B(2),B(3)}),A(4,{B(5),B(6)}),A(7,{B(8),B(9)})};
 algorithm
 end f;
 
 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 A x[3] = f();
end CRecordDecl12;


model CRecordDecl13
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl13",
         description="C code generation for records: inputs: basic test",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl13_f_def(A_0_r* x_v, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl13_f_exp(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl13_f_def(A_0_r* x_v, jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    o_v = x_v->a;
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl13_f_exp(A_0_r* x_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl13_f_def(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_DECL(A_0_r, tmp_1)
    tmp_1->a = 1;
    tmp_1->b = 2;
    (*res)[0] = func_CCodeGenTests_CRecordDecl13_f_exp(tmp_1) - (_x_0);
")})));

  function f
  output Real o;
  input A x;
 algorithm
  o := x.a;
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 Real x = f(A(1,2));
end CRecordDecl13;


model CRecordDecl14
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl14",
         description="C code generation for records: inputs: nested records",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl14_f_def(A_1_r* x_v, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl14_f_exp(A_1_r* x_v);

void func_CCodeGenTests_CRecordDecl14_f_def(A_1_r* x_v, jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    o_v = x_v->b->c;
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl14_f_exp(A_1_r* x_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl14_f_def(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_DECL(A_1_r, tmp_1)
    JMI_RECORD_DECL(B_0_r, tmp_2)
    tmp_1->b = tmp_2;
    tmp_1->a = 1;
    tmp_1->b->c = 2;
    (*res)[0] = func_CCodeGenTests_CRecordDecl14_f_exp(tmp_1) - (_x_0);
")})));

 function f
  output Real o;
  input A x;
 algorithm
  o := x.b.c;
 end f;
 
 record A
  Real a;
  B b;
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f(A(1, B(2)));
end CRecordDecl14;


model CRecordDecl15
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl15",
         description="C code generation for records: inputs: array in record",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl15_f_def(A_0_r* x_v, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl15_f_exp(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl15_f_def(A_0_r* x_v, jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    o_v = jmi_array_val_1(x_v->a, 1);
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl15_f_exp(A_0_r* x_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl15_f_def(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_DECL(A_0_r, tmp_1)
    JMI_ARRAY_DECL(tmp_2, 2, 2)
    tmp_1->a = tmp_2;
    jmi_array_ref_1(tmp_1->a, 1) = 1;
    jmi_array_ref_1(tmp_1->a, 2) = 2;
    (*res)[0] = func_CCodeGenTests_CRecordDecl15_f_exp(tmp_1) - (_x_0);
")})));

 function f
  output Real o;
  input A x;
 algorithm
  o := x.a[1];
 end f;
 
 record A
  Real a[2];
 end A;
 
 Real x = f(A({1,2}));
end CRecordDecl15;


model CRecordDecl16
 annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
     JModelica.UnitTesting.CCodeGenTestCase(
         name="CRecordDecl16",
         description="C code generation for records: inputs: array of records",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_CRecordDecl16_f_def(A_1_ra* x_a, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl16_f_exp(A_1_ra* x_a);

void func_CCodeGenTests_CRecordDecl16_f_def(A_1_ra* x_a, jmi_ad_var_t* o_o) {
    jmi_ad_var_t o_v;
    o_v = jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c;
    if (o_o != NULL) *o_o = o_v;
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl16_f_exp(A_1_ra* x_a) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl16_f_def(x_a, &o_v);
    return o_v;
}


    JMI_RECORD_ARRAY_DECL(A_1_r, A_1_ra, tmp_1, 3, 3)
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_2, 2, 2)
    jmi_array_rec_1(tmp_1, 1)->b = tmp_2;
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_3, 2, 2)
    jmi_array_rec_1(tmp_1, 2)->b = tmp_3;
    JMI_RECORD_ARRAY_DECL(B_0_r, B_0_ra, tmp_4, 2, 2)
    jmi_array_rec_1(tmp_1, 3)->b = tmp_4;
    jmi_array_rec_1(tmp_1, 1)->a = null;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 1)->c = null;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 2)->c = null;
    jmi_array_rec_1(tmp_1, 2)->a = null;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 1)->c = null;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 2)->c = null;
    jmi_array_rec_1(tmp_1, 3)->a = null;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 1)->c = null;
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 2)->c = null;
    (*res)[0] = func_CCodeGenTests_CRecordDecl16_f_exp(tmp_1) - (_x_0);
")})));

 function f
  output Real o;
  input A x[3];
 algorithm
  o := x[1].b[2].c;
 end f;
 
 record A
  Real a;
  B b[2];
 end A;
 
 record B
  Real c;
 end B;
 
 Real x = f({A(1,{B(2),B(3)}),A(4,{B(5),B(6)}),A(7,{B(8),B(9)})});
end CRecordDecl16;



end CCodeGenTests;
