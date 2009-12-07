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
        generatedCode="#define _der_z_ ((*(jmi->z))[jmi->offs_dx+0])
#define _der_v_ ((*(jmi->z))[jmi->offs_dx+1])
#define _z_ ((*(jmi->z))[jmi->offs_x+0])
#define _v_ ((*(jmi->z))[jmi->offs_x+1])
#define _y_ ((*(jmi->z))[jmi->offs_w+0])
#define _w_ ((*(jmi->z))[jmi->offs_w+1])
#define time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] =  - ( _z_ ) - (_der_z_);
    (*res)[1] = 4 - (_der_v_);
    (*res)[2] = 3 - (_y_);
    (*res)[3] = 2 - (_w_);

    (*res)[0] =  - ( _z_ ) - (_der_z_);
    (*res)[1] = 4 - (_der_v_);
    (*res)[2] = 3 - (_y_);
    (*res)[3] = 2 - (_w_);
    (*res)[4] = 3 - (_y_);

   (*res)[0] = 0.0 - _z_;
   (*res)[1] = 1 - _w_;
   (*res)[2] = 0.0 - _v_;
   (*res)[3] = 0.0 - _der_z_;
   (*res)[4] = 0.0 - _der_v_;

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


model CCodeGenTest4

  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest4",
        description="Test of code generation",
        template = 
        "$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _y_ - (_der_x_);
    (*res)[1] = (COND_EXP_LE(time,jmi_divide(3.141592653589793,2,\"Divide by zero: ( 3.141592653589793 ) / ( 2 )\"),sin(time),_x_)) - (_y_);
")})));
  Real x(start=0);
  Real y = if time <= Modelica.Constants.pi/2 then sin(time) else x;
equation
  der(x) = y; 
end CCodeGenTest4;


model CCodeGenTest5

  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest5",
        description="Test of code generation",
        template = 
        "$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _y_ - (_der_x_);
    (*res)[1] = (COND_EXP_LE(time,_one_,_x_,(COND_EXP_LE(time,_two_,(  - ( 2 ) ) * ( _x_ ),( 3 ) * ( _x_ ))))) - (_y_);
")})));


  parameter Real one = 1;
  parameter Real two = 2;
  Real x(start=0.1,fixed=true);
  Real y = if time <= one then x else if time <= two then -2*x else 3*x;
equation
  der(x) = y; 
end CCodeGenTest5;

model CCodeGenTest6
  	  annotation(JModelica(unitTesting = JModelica.UnitTesting(testCase={
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest6",
        description="Test of code generation",
        template = 
        "$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$",
        generatedCode="
    (*res)[0] = _one_ - (time);
    (*res)[1] = _two_ - (time);

    (*res)[0] = _one_ - (time);
    (*res)[1] = _two_ - (time);
    (*res)[2] = _one_ - (_p_);

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
      JModelica.UnitTesting.CCodeGenTestCase(name="CCodeGenTest7",
        description="Test of code generation",
        template = 
        "$C_DAE_equation_residuals$",
        generatedCode="
    (*res)[0] = _y_ - (_der_x_);
    (*res)[1] = (COND_EXP_LE(AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(0),(COND_EXP_GE(AD_WRAP_LITERAL(3),AD_WRAP_LITERAL(4),AD_WRAP_LITERAL(1)
,(COND_EXP_LT(AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(2),(COND_EXP_GT(AD_WRAP_LITERAL(3),AD_WRAP_LITERAL(4),AD_WRAP_LITERAL(4),(COND_EXP_EQ(A
D_WRAP_LITERAL(4),AD_WRAP_LITERAL(3),AD_WRAP_LITERAL(4),AD_WRAP_LITERAL(7))))))))))) - (_y_);
")})));
  Real x(start=0);
  Real y = if 1 <= 2 then 0 else if 3 >= 4 then 1 
   else if 1 < 2 then 2 else if 3 > 4 then 4 
   else if 4 == 3 then 4 else 7;
equation
  der(x) = y; 
end CCodeGenTest7;


/* ========= Function tests ========= */

/* Functions used in tests */
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
         description="C code gen: functions: simple function",
         template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
", 
         generatedCode="
void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r) {
   jmi_ad_var_t o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v = i1_v;
   func_CCodeGenTests_TestFunction1_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp(2.0) - (_x_);
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
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r) {
   jmi_ad_var_t o1_v = 0;
   jmi_ad_var_t o2_v = i2_v;
   o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   if (o2_r != NULL) *o2_r = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v = 0;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}


    jmi_ad_var_t tmp_var_0;
    jmi_ad_var_t tmp_var_1;
    func_CCodeGenTests_TestFunction2_def(1, 2, &tmp_var_0, &tmp_var_1);
    (*res)[0] = tmp_var_0 - (_x_);
    (*res)[1] = tmp_var_1 - (_y_);
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
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r) {
   jmi_ad_var_t o1_v = 0;
   jmi_ad_var_t o2_v = i2_v;
   o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   if (o2_r != NULL) *o2_r = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v = 0;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction2_exp(1, 0) - (_x_);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp(2, 3) - (_y_);
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
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);
void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r) {
   jmi_ad_var_t o1_v = 0;
   jmi_ad_var_t o2_v = i2_v;
   o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   if (o2_r != NULL) *o2_r = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v = 0;
   func_CCodeGenTests_TestFunction2_def(i1_v, i2_v, &o1_v, NULL);
   return o1_v;
}

void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r) {
   jmi_ad_var_t o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v = i1_v;
   func_CCodeGenTests_TestFunction1_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp(( _y_ ) * ( 2 )) - (_x_);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp(2, 3) - (_y_);
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
void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r, jmi_ad_var_t* o3_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v);

void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r, jmi_ad_var_t* o3_r) {
   jmi_ad_var_t o1_v = i1_v + i2_v + i3_v;
   jmi_ad_var_t o2_v = i2_v + i3_v;
   jmi_ad_var_t o3_v = i1_v + i2_v;
   if (o1_r != NULL) *o1_r = o1_v;
   if (o2_r != NULL) *o2_r = o2_v;
   if (o3_r != NULL) *o3_r = o3_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v) {
   jmi_ad_var_t o1_v = i1_v + i2_v + i3_v;
   func_CCodeGenTests_TestFunction3_def(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
   return o1_v;
}


    jmi_ad_var_t tmp_var_0;
    jmi_ad_var_t tmp_var_1;
    func_CCodeGenTests_TestFunction3_def(1, 2, 3, &tmp_var_0, &tmp_var_1, NULL);
    (*res)[0] = tmp_var_0 - (_x_);
    (*res)[1] = tmp_var_1 - (_y_);
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
void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r, jmi_ad_var_t* o3_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v);

void func_CCodeGenTests_TestFunction3_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r, jmi_ad_var_t* o3_r) {
   jmi_ad_var_t o1_v = i1_v + i2_v + i3_v;
   jmi_ad_var_t o2_v = i2_v + i3_v;
   jmi_ad_var_t o3_v = i1_v + i2_v;
   if (o1_r != NULL) *o1_r = o1_v;
   if (o2_r != NULL) *o2_r = o2_v;
   if (o3_r != NULL) *o3_r = o3_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v) {
   jmi_ad_var_t o1_v = i1_v + i2_v + i3_v;
   func_CCodeGenTests_TestFunction3_def(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
   return o1_v;
}


    jmi_ad_var_t tmp_var_0;
    jmi_ad_var_t tmp_var_1;
    func_CCodeGenTests_TestFunction3_def(1, 2, 3, &tmp_var_0, NULL, &tmp_var_1);
    (*res)[0] = tmp_var_0 - (_x_);
    (*res)[1] = tmp_var_1 - (_z_);
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
void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_r, jmi_ad_var_t* o2_r) {
   jmi_ad_var_t o1_v = 0;
   jmi_ad_var_t o2_v = i2_v;
   o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   if (o2_r != NULL) *o2_r = o2_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
   jmi_ad_var_t o1_v = 0;
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
void func_CCodeGenTests_TestFunctionCallingFunction_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r);
jmi_ad_var_t func_CCodeGenTests_TestFunctionCallingFunction_exp(jmi_ad_var_t i1_v);
void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionCallingFunction_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r) {
   jmi_ad_var_t o1_v;
   o1_v = func_CCodeGenTests_TestFunction1_exp(i1_v);
   if (o1_r != NULL) *o1_r = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunctionCallingFunction_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunctionCallingFunction_def(i1_v, &o1_v);
   return o1_v;
}

void func_CCodeGenTests_TestFunction1_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r) {
   jmi_ad_var_t o1_v = i1_v;
   if (o1_r != NULL) *o1_r = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v = i1_v;
   func_CCodeGenTests_TestFunction1_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionCallingFunction_exp(1) - (_x_);
")})));

 Real x = TestFunctionCallingFunction(1);
end CFunctionTest8;

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
void func_CCodeGenTests_TestFunctionRecursive_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r);
jmi_ad_var_t func_CCodeGenTests_TestFunctionRecursive_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionRecursive_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_r) {
   jmi_ad_var_t o1_v;
   if (i1_v < 3) {
       o1_v = 1;
   } else {
       o1_v = func_CCodeGenTests_TestFunctionRecursive_exp(i1_v - ( 1 )) + func_CCodeGenTests_TestFunctionRecursive_exp(i1_v - ( 2 ));
   }
   if (o1_r != NULL) *o1_r = o1_v;
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunctionRecursive_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunctionRecursive_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionRecursive_exp(5) - (_x_);
")})));

 Real x = TestFunctionRecursive(5);
end CFunctionTest9;


end CCodeGenTests;
