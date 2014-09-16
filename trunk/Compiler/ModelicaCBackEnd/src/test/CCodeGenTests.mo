/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


package CCodeGenTests

model CCodeGenTest1
  Real x1(start=0); 
  Real x2(start=1); 
  input Real u; 
  parameter Real p = 1;
  Real w = x1+x2;
equation 
  der(x1) = (1-x2^2)*x1 - x2 + p*u; 
  der(x2) = x1; 

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest1",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
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
#define _time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = (1 - (1.0 * (_x2_1) * (_x2_1))) * _x1_0 - _x2_1 + _p_3 * _u_2 - (_der_x1_5);
    (*res)[1] = _x1_0 - (_der_x2_6);
    (*res)[2] = _x1_0 + _x2_1 - (_w_4);
")})));
end CCodeGenTest1;


	model CCodeGenTest2
		Real x(start=1);
		Real y(start=3)=3;
	    Real z = x;
	    Real w(start=1) = 2;
	    Real v;
	equation
		der(x) = -x;
		der(v) = 4;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest2",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="
$C_variable_aliases$
$C_DAE_equation_residuals$
$C_DAE_initial_equation_residuals$
$C_DAE_initial_guess_equation_residuals$
",
			generatedCode="
#define _der_x_4 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _der_v_5 ((*(jmi->z))[jmi->offs_real_dx+1])
#define _x_0 ((*(jmi->z))[jmi->offs_real_x+0])
#define _v_3 ((*(jmi->z))[jmi->offs_real_x+1])
#define _y_1 ((*(jmi->z))[jmi->offs_real_w+0])
#define _w_2 ((*(jmi->z))[jmi->offs_real_w+1])
#define _time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = - _x_0 - (_der_x_4);
    (*res)[1] = 4 - (_der_v_5);
    (*res)[2] = 3 - (_y_1);
    (*res)[3] = 2 - (_w_2);

    (*res)[0] = - _x_0 - (_der_x_4);
    (*res)[1] = 4 - (_der_v_5);
    (*res)[2] = 3 - (_y_1);
    (*res)[3] = 2 - (_w_2);
    (*res)[4] = 1 - (_x_0);
    (*res)[5] = 0.0 - (_v_3);

    (*res)[0] = 1 - _x_0;
    (*res)[1] = 3 - _y_1;
    (*res)[2] = 1 - _w_2;
    (*res)[3] = 0.0 - _v_3;
")})));
	end CCodeGenTest2;

	model CCodeGenTest3
	    parameter Real p3 = p2;
	    parameter Real p2 = p1*p1;
		parameter Real p1 = 4;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest3",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_initial_dependent_parameter_residuals$",
			generatedCode="
    (*res)[0] = _p1_2 * _p1_2 - (_p2_0);
    (*res)[1] = _p2_0 - (_p3_1);
")})));
	end CCodeGenTest3;


model CCodeGenTest4
  Real x(start=0);
  Real y = noEvent(if time <= Modelica.Constants.pi/2 then sin(time) else x);
equation
  der(x) = y; 

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest4",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = _y_1 - (_der_x_2);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(_time, jmi_divide_equation(jmi, AD_WRAP_LITERAL(3.141592653589793),AD_WRAP_LITERAL(2),\"3.141592653589793 / 2\"), JMI_TRUE, JMI_FALSE), JMI_TRUE, sin(_time), _x_0)) - (_y_1);
")})));
end CCodeGenTest4;


model CCodeGenTest5
  parameter Real one = 1;
  parameter Real two = 2;
  Real x(start=0.1,fixed=true);
  Real y = noEvent(if time <= one then x else if time <= two then -2*x else 3*x);
equation
  der(x) = y; 

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest5",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = _y_3 - (_der_x_4);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(_time, _one_0, JMI_TRUE, JMI_FALSE), JMI_TRUE, _x_2, COND_EXP_EQ(COND_EXP_LE(_time, _two_1, JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(-2) * _x_2, AD_WRAP_LITERAL(3) * _x_2))) - (_y_3);
")})));
end CCodeGenTest5;

model CCodeGenTest6
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

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest6",
			description="Test of code generation",
			variability_propagation=false,
			template="
$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
         generatedCode="
    (*res)[0] = _time - (_one_1);
    (*res)[1] = _time - (_two_2);

    (*res)[0] = _time - (_one_1);
    (*res)[1] = _time - (_two_2);
")})));
end CCodeGenTest6;

model CCodeGenTest7
  parameter Integer z = 2;
  Real x(start=0);
  Real y = noEvent(if time <= 2 then 0 else if time >= 4 then 1 
   else if x < 2 then 2 else if x > 4 then 4 
   else if z == 3 then 4 else 7);
equation
 der(x) = y; 

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest7",
			description="Test of code generation. Verify that no event indicators are generated from relational expressions inside noEvent operators.",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="
$C_DAE_equation_residuals$
$C_DAE_event_indicator_residuals$
",
			generatedCode="
    (*res)[0] = _y_2 - (_der_x_3);
    (*res)[1] = (COND_EXP_EQ(COND_EXP_LE(_time, AD_WRAP_LITERAL(2), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(0), COND_EXP_EQ(COND_EXP_GE(_time, AD_WRAP_LITERAL(4), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(1), COND_EXP_EQ(COND_EXP_LT(_x_1, AD_WRAP_LITERAL(2), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(2), COND_EXP_EQ(COND_EXP_GT(_x_1, AD_WRAP_LITERAL(4), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(4), COND_EXP_EQ(COND_EXP_EQ(_z_0, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(4), AD_WRAP_LITERAL(7))))))) - (_y_2);

")})));
end CCodeGenTest7;

model CCodeGenTest8
  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
equation
   x = if time>=1 then (-1 + y) else  (- y);
   y = z + x +(if z>=-1.5 then -3 else 3);
   z = -y  - x + (if y>=0.5 then -1 else 1);


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest8",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(-1) + _y_1, - _y_1) - (_x_0);
    (*res)[1] = _z_2 + _x_0 + COND_EXP_EQ(_sw(1), JMI_TRUE, AD_WRAP_LITERAL(-3), AD_WRAP_LITERAL(3)) - (_y_1);
    (*res)[2] = - _y_1 - _x_0 + COND_EXP_EQ(_sw(2), JMI_TRUE, AD_WRAP_LITERAL(-1), AD_WRAP_LITERAL(1)) - (_z_2);
")})));
end CCodeGenTest8;

model CCodeGenTest9
  Real x(start=0);
  Real y(start=1);
  Real z(start=0);
initial equation
   x = noEvent(if time>=1 then (-1 + y) else  (- y));
   y = 2 * noEvent(z + x +(if z>=-1.5 then -3 else 3));
   z = -y  - x + (if y>=0.5 then -1 else 1);
equation
   der(x) = -x;
   der(y) = -y;
   der(z) = -z;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest9",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="
$C_DAE_initial_equation_residuals$
$C_DAE_initial_event_indicator_residuals$
",
			generatedCode="
    (*res)[0] = - _x_0 - (_der_x_3);
    (*res)[1] = - _y_1 - (_der_y_4);
    (*res)[2] = - _z_2 - (_der_z_5);
    (*res)[3] = (COND_EXP_EQ(COND_EXP_GE(_time, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(-1) + _y_1, - _y_1)) - (_x_0);
    (*res)[4] = 2 * (_z_2 + _x_0 + COND_EXP_EQ(COND_EXP_GE(_z_2, AD_WRAP_LITERAL(-1.5), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(-3), AD_WRAP_LITERAL(3))) - (_y_1);
    (*res)[5] = - _y_1 - _x_0 + COND_EXP_EQ(_sw_init(0), JMI_TRUE, AD_WRAP_LITERAL(-1), AD_WRAP_LITERAL(1)) - (_z_2);

    (*res)[0] = _y_1 - (AD_WRAP_LITERAL(0.5));
")})));
end CCodeGenTest9;

model CCodeGenTest10
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

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest10",
			description="Test of code generation",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="
$C_DAE_initial_equation_residuals$
$C_DAE_initial_event_indicator_residuals$
",
			generatedCode="
    (*res)[0] = - _x_0 - (_der_x_3);
    (*res)[1] = - _y_1 - (_der_y_4);
    (*res)[2] = - _z_2 - (_der_z_5);
    (*res)[3] = COND_EXP_EQ(_sw_init(0), JMI_TRUE, AD_WRAP_LITERAL(-1) + _y_1, - _y_1) - (_x_0);
    (*res)[4] = _z_2 + _x_0 + COND_EXP_EQ(_sw_init(1), JMI_TRUE, AD_WRAP_LITERAL(-3), AD_WRAP_LITERAL(3)) - (_y_1);
    (*res)[5] = - _y_1 - _x_0 + COND_EXP_EQ(_sw_init(2), JMI_TRUE, AD_WRAP_LITERAL(-1), AD_WRAP_LITERAL(1)) - (_z_2);

    (*res)[0] = _time - (AD_WRAP_LITERAL(1));
    (*res)[1] = _z_2 - (AD_WRAP_LITERAL(-1.5));
    (*res)[2] = _y_1 - (AD_WRAP_LITERAL(0.5));

")})));
end CCodeGenTest10;

model CCodeGenTest11
 Integer x = 1;
 Integer y = 2;
 Real z = noEvent(if x <> y then 1.0 else 2.0);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest11",
			description="C code generation: the '<>' operator",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = 1 - (_x_0);
    (*res)[1] = 2 - (_y_1);
    (*res)[2] = (COND_EXP_EQ(COND_EXP_EQ(_x_0, _y_1, JMI_FALSE, JMI_TRUE),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_z_2);
")})));
end CCodeGenTest11;


model CCodeGenTest12
  Real x(start=1,fixed=true);
equation
  der(x) = (x-0.3)^0.3 + (x-0.3)^3;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest12",
			description="C code generation: test that x^2 is represented by x*x in the generated code.",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = pow((_x_0 - 0.3),0.3) + (1.0 * ((_x_0 - 0.3)) * ((_x_0 - 0.3)) * ((_x_0 - 0.3))) - (_der_x_1);
")})));
end CCodeGenTest12;


model CCodeGenTest13
	constant Integer ci = 1;
	constant Integer cd = ci;
	parameter Integer pi = 2;
	parameter Integer pd = pi;

	type A = enumeration(a, b, c);
	type B = enumeration(d, e, f);
	
	constant A aic = A.a;
	constant B bic = B.e;
	constant A adc = aic;
	constant B bdc = bic;
	parameter A aip = A.b;
	parameter B bip = B.f;
	parameter A adp = aip;
	parameter B bdp = bip;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest13",
			description="Code generation for enumerations: variable aliases",
			variability_propagation=false,
			template="$C_variable_aliases$",
			generatedCode="
#define _ci_0 ((*(jmi->z))[jmi->offs_integer_ci+0])
#define _cd_1 ((*(jmi->z))[jmi->offs_integer_ci+1])
#define _aic_4 ((*(jmi->z))[jmi->offs_integer_ci+2])
#define _bic_5 ((*(jmi->z))[jmi->offs_integer_ci+3])
#define _adc_6 ((*(jmi->z))[jmi->offs_integer_ci+4])
#define _bdc_7 ((*(jmi->z))[jmi->offs_integer_ci+5])
#define _pi_2 ((*(jmi->z))[jmi->offs_integer_pi+0])
#define _aip_8 ((*(jmi->z))[jmi->offs_integer_pi+1])
#define _bip_9 ((*(jmi->z))[jmi->offs_integer_pi+2])
#define _pd_3 ((*(jmi->z))[jmi->offs_integer_pd+0])
#define _adp_10 ((*(jmi->z))[jmi->offs_integer_pd+1])
#define _bdp_11 ((*(jmi->z))[jmi->offs_integer_pd+2])
#define _time ((*(jmi->z))[jmi->offs_t])	 
")})));
end CCodeGenTest13;


model CCodeGenTest14
	function f
		input Real[2] a;
		output Real b;
	algorithm
		b := sum(a);
	end f;
	
    parameter Real[2] c = {1,2};
	Real x;
	
equation
	when initial() then
		x = f(c);
	end when;
	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest14",
            description="",
            generate_ode=true,
            generate_dae=false,
            equation_sorting=true,
            variability_propagation=false,
            template="$C_ode_derivatives$",
            generatedCode="
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _c_1_0;
    jmi_array_ref_1(tmp_1, 2) = _c_2_1;
    _x_2 = COND_EXP_EQ(_atInitial, JMI_TRUE, func_CCodeGenTests_CCodeGenTest14_f_exp0(tmp_1), pre_x_2);
/********* Write back reinits *******/
")})));
end CCodeGenTest14;

model CCodeGenTest15
  Real x1(start=0); 
  Real x2(start=1); 
  input Real u; 
  parameter Real p = 1;
  Real w = x1+x2;
equation 
  der(x1) = (1-x2^2)*x1 - x2 + p*u; 
  der(x2) = x1;


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest15",
			description="Test the compiler option generate_only_initial_system",
			generate_ode=true,
			generate_dae=false,
			equation_sorting=true,
			generate_only_initial_system=true,
			variability_propagation=false,
			template="
$C_ode_derivatives$
$C_ode_guards$
$C_ode_time_events$
$C_DAE_event_indicator_residuals$
$C_ode_initialization$
",
			generatedCode="
  ef=model_ode_initialize(jmi);

  model_ode_guards_init(jmi);


  model_init_R0(jmi, res);

    model_ode_guards(jmi);
  _x2_1 = 1;
  _x1_0 = 0;
  _der_x1_5 = (1 - (1.0 * (_x2_1) * (_x2_1))) * _x1_0 + (- _x2_1) + _p_3 * _u_2;
  _der_x2_6 = _x1_0;
  _w_4 = _x1_0 + _x2_1;
")})));
end CCodeGenTest15;

model CCodeGenTest16
  Real x,y,z;
initial equation
 der(x) = if time>=1 then 1 elseif time>=2 then 3 else 5;
equation
 y - (if time>=5 then -z else z) + x = 3;
 y + sin(z) + x = 5;
 der(x) = -x + z;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest16",
			description="Test the compiler option generate_only_initial_system",
			generate_ode=true,
			generate_dae=false,
			equation_sorting=true,
			generate_only_initial_system=true,
			variability_propagation=false,
			template="
$n_event_indicators$
$n_initial_event_indicators$
$C_DAE_initial_event_indicator_residuals$
$C_ode_initialization$
",
			generatedCode="
3
0
    (*res)[0] = _time - (AD_WRAP_LITERAL(5));
    (*res)[1] = _time - (AD_WRAP_LITERAL(1));
    (*res)[2] = _time - (AD_WRAP_LITERAL(2));

    model_ode_guards(jmi);
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw_init(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(1) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(2)), _sw_init(1), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _der_x_3 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, AD_WRAP_LITERAL(1), COND_EXP_EQ(_sw_init(1), JMI_TRUE, AD_WRAP_LITERAL(3), AD_WRAP_LITERAL(5)));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(5)), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
")})));
end CCodeGenTest16;


model CCodeGenTest17
	type A = enumeration(a, b, c);
	A a;
equation
	when time > 2 then
		a = pre(a);
	end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenTest17",
			description="Test C code compilation for pre() of enum variable",
			variability_propagation=false,
			template="
$C_variable_aliases$
-----
$C_ode_initialization$
",
			generatedCode="
#define _time ((*(jmi->z))[jmi->offs_t])
#define _a_0 ((*(jmi->z))[jmi->offs_integer_d+0])
#define _temp_1_1 ((*(jmi->z))[jmi->offs_boolean_d+0])
#define pre_a_0 ((*(jmi->z))[jmi->offs_pre_integer_d+0])
#define pre_temp_1_1 ((*(jmi->z))[jmi->offs_pre_boolean_d+0])

-----
    model_ode_guards(jmi);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    pre_a_0 = 1;
    _a_0 = pre_a_0;
    pre_temp_1_1 = JMI_FALSE;
")})));
end CCodeGenTest17;

model CCodeGenTest18
    parameter Boolean[3] table = {false, true, false};
    Boolean x;
    Integer index = integer(time);
algorithm
    if index < 4 then
        x := table[index];
    else
        x := true;
    end if;
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest18",
            description="Test generation of temporary variables",
            template="$C_ode_derivatives$",
            generatedCode="
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (pre_index_4), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_time - (pre_index_4 + AD_WRAP_LITERAL(1)), _sw(1), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _index_4 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_OR(_sw(0), _sw(1)), _atInitial), JMI_TRUE, floor(_time), pre_index_4);
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = _table_1_0;
    jmi_array_ref_1(tmp_1, 2) = _table_2_1;
    jmi_array_ref_1(tmp_1, 3) = _table_3_2;
    _x_3 = pre_x_3;
    if (COND_EXP_LT(_index_4, 4, JMI_TRUE, JMI_FALSE)) {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
        jmi_array_ref_1(tmp_1, 1) = _table_1_0;
        jmi_array_ref_1(tmp_1, 2) = _table_2_1;
        jmi_array_ref_1(tmp_1, 3) = _table_3_2;
        _x_3 = func_temp_1_exp0(_index_4, tmp_1);
    } else {
        _x_3 = JMI_TRUE;
    }
/********* Write back reinits *******/
")})));
end CCodeGenTest18;


model CCodeGenTest19
    function f
        input String a;
        input Real b;
        output Real c;
    algorithm
        c := b;
        c := c + 1;
    end f;

    Real x = time / f("a", time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenTest19",
            description="Check that quotes in divisions are escaped in the string representation",
            template="$C_ode_derivatives$",
            generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = jmi_divide_equation(jmi, _time,func_CCodeGenTests_CCodeGenTest19_f_exp0(\"a\", _time),\"time / CCodeGenTests.CCodeGenTest19.f(\\\"a\\\", time)\");
/********* Write back reinits *******/
")})));
end CCodeGenTest19;


model CLogExp1
 Boolean x = true;
 Boolean y = false;
 Real z = noEvent(if x and y then 1.0 else 2.0);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CLogExp1",
			description="C code generation for logical operators: and",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = JMI_FALSE - (_y_1);
    (*res)[2] = (COND_EXP_EQ(LOG_EXP_AND(_x_0, _y_1),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_z_2);
")})));
end CLogExp1;


model CLogExp2
 Boolean x = true;
 Boolean y = false;
 Real z = noEvent(if x or y then 1.0 else 2.0);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CLogExp2",
			description="C code generation for logical operators: or",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = JMI_FALSE - (_y_1);
    (*res)[2] = (COND_EXP_EQ(LOG_EXP_OR(_x_0, _y_1),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_z_2);
")})));
end CLogExp2;


model CLogExp3
 Boolean x = true;
 Real y = noEvent(if not x then 1.0 else 2.0);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CLogExp3",
			description="C code generation for logical operators: not",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = JMI_TRUE - (_x_0);
    (*res)[1] = (COND_EXP_EQ(LOG_EXP_NOT(_x_0),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0))) - (_y_1);
")})));
end CLogExp3;

model CStringExp
	function StringCompare
		input String expected;
		input String actual;
	algorithm
		assert(actual == expected, "Compare failed, expected: " + expected + ", actual: " + actual);
	end StringCompare;
	type E = enumeration(small, medium, large, xlarge);
	parameter Real realVar = 3.14;
	Integer intVar = if realVar < 2.5 then 12 else 42;
	Boolean boolVar = if realVar < 2.5 then true else false;
	E enumVar = if realVar < 2.5 then E.small else E.medium;
equation
	StringCompare("42",           String(intVar));
	StringCompare("42          ", String(intVar, minimumLength=12));
	StringCompare("          42", String(intVar, minimumLength=12, leftJustified=false));
	
	StringCompare("3.14000",      String(realVar));
	StringCompare("3.14000     ", String(realVar, minimumLength=12));
	StringCompare("     3.14000", String(realVar, minimumLength=12, leftJustified=false));
	StringCompare("3.1400000",    String(realVar, significantDigits=8));
	StringCompare("3.1400000   ", String(realVar, minimumLength=12, significantDigits=8));
	StringCompare("   3.1400000", String(realVar, minimumLength=12, leftJustified=false, significantDigits=8));
	
	StringCompare("-3.14000",     String(-realVar));
	StringCompare("-3.14000    ", String(-realVar, minimumLength=12));
	StringCompare("    -3.14000", String(-realVar, minimumLength=12, leftJustified=false));
	StringCompare("-3.1400000",   String(-realVar, significantDigits=8));
	StringCompare("-3.1400000  ", String(-realVar, minimumLength=12, significantDigits=8));
	StringCompare("  -3.1400000", String(-realVar, minimumLength=12, leftJustified=false, significantDigits=8));
	
	StringCompare("false",        String(boolVar));
	StringCompare("false       ", String(boolVar, minimumLength=12));
	StringCompare("       false", String(boolVar, minimumLength=12, leftJustified=false));
	
	StringCompare("true",         String(not boolVar));
	StringCompare("true        ", String(not boolVar, minimumLength=12));
	StringCompare("        true", String(not boolVar, minimumLength=12, leftJustified=false));
	
	StringCompare("medium",       String(enumVar));
	StringCompare("medium      ", String(enumVar, minimumLength=12));
	StringCompare("      medium", String(enumVar, minimumLength=12, leftJustified=false));

    StringCompare("42",           String(intVar, format="%d"));
    StringCompare("3.1400000",    String(realVar, format="%f"));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CStringExp",
            description="C code generation for string operator",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    JMI_DEF_STR_STAT(tmp_1, 10)
    JMI_DEF_STR_STAT(tmp_2, 12)
    JMI_DEF_STR_STAT(tmp_3, 12)
    JMI_DEF_STR_STAT(tmp_4, 13)
    JMI_DEF_STR_STAT(tmp_5, 13)
    JMI_DEF_STR_STAT(tmp_6, 13)
    JMI_DEF_STR_STAT(tmp_7, 15)
    JMI_DEF_STR_STAT(tmp_8, 15)
    JMI_DEF_STR_STAT(tmp_9, 15)
    JMI_DEF_STR_STAT(tmp_10, 13)
    JMI_DEF_STR_STAT(tmp_11, 13)
    JMI_DEF_STR_STAT(tmp_12, 13)
    JMI_DEF_STR_STAT(tmp_13, 15)
    JMI_DEF_STR_STAT(tmp_14, 15)
    JMI_DEF_STR_STAT(tmp_15, 15)
    JMI_DEF_STR_STAT(tmp_16, 5)
    JMI_DEF_STR_STAT(tmp_17, 12)
    JMI_DEF_STR_STAT(tmp_18, 12)
    JMI_DEF_STR_STAT(tmp_19, 5)
    JMI_DEF_STR_STAT(tmp_20, 12)
    JMI_DEF_STR_STAT(tmp_21, 12)
    JMI_DEF_STR_STAT(tmp_22, 6)
    JMI_DEF_STR_STAT(tmp_23, 12)
    JMI_DEF_STR_STAT(tmp_24, 12)
    JMI_DEF_STR_STAT(tmp_25, 16)
    JMI_DEF_STR_STAT(tmp_26, 16)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-d\", (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"42\", tmp_1);
    JMI_INI_STR_STAT(tmp_2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%-*d\", (int) AD_WRAP_LITERAL(12), (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"42          \", tmp_2);
    JMI_INI_STR_STAT(tmp_3)
    snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), ((JMI_FALSE) ? (\"%-*d\") : (\"%*d\")), (int) AD_WRAP_LITERAL(12), (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"          42\", tmp_3);
    JMI_INI_STR_STAT(tmp_4)
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%-.*g\", (int) 6, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.14000\", tmp_4);
    JMI_INI_STR_STAT(tmp_5)
    snprintf(JMI_STR_END(tmp_5), JMI_STR_LEFT(tmp_5), \"%-*.*g\", (int) AD_WRAP_LITERAL(12), (int) 6, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.14000     \", tmp_5);
    JMI_INI_STR_STAT(tmp_6)
    snprintf(JMI_STR_END(tmp_6), JMI_STR_LEFT(tmp_6), ((JMI_FALSE) ? (\"%-*.*g\") : (\"%*.*g\")), (int) AD_WRAP_LITERAL(12), (int) 6, _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"     3.14000\", tmp_6);
    JMI_INI_STR_STAT(tmp_7)
    snprintf(JMI_STR_END(tmp_7), JMI_STR_LEFT(tmp_7), \"%-.*g\", (int) AD_WRAP_LITERAL(8), _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.1400000\", tmp_7);
    JMI_INI_STR_STAT(tmp_8)
    snprintf(JMI_STR_END(tmp_8), JMI_STR_LEFT(tmp_8), \"%-*.*g\", (int) AD_WRAP_LITERAL(12), (int) AD_WRAP_LITERAL(8), _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.1400000   \", tmp_8);
    JMI_INI_STR_STAT(tmp_9)
    snprintf(JMI_STR_END(tmp_9), JMI_STR_LEFT(tmp_9), ((JMI_FALSE) ? (\"%-*.*g\") : (\"%*.*g\")), (int) AD_WRAP_LITERAL(12), (int) AD_WRAP_LITERAL(8), _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"   3.1400000\", tmp_9);
    JMI_INI_STR_STAT(tmp_10)
    snprintf(JMI_STR_END(tmp_10), JMI_STR_LEFT(tmp_10), \"%-.*g\", (int) 6, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.14000\", tmp_10);
    JMI_INI_STR_STAT(tmp_11)
    snprintf(JMI_STR_END(tmp_11), JMI_STR_LEFT(tmp_11), \"%-*.*g\", (int) AD_WRAP_LITERAL(12), (int) 6, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.14000    \", tmp_11);
    JMI_INI_STR_STAT(tmp_12)
    snprintf(JMI_STR_END(tmp_12), JMI_STR_LEFT(tmp_12), ((JMI_FALSE) ? (\"%-*.*g\") : (\"%*.*g\")), (int) AD_WRAP_LITERAL(12), (int) 6, - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"    -3.14000\", tmp_12);
    JMI_INI_STR_STAT(tmp_13)
    snprintf(JMI_STR_END(tmp_13), JMI_STR_LEFT(tmp_13), \"%-.*g\", (int) AD_WRAP_LITERAL(8), - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.1400000\", tmp_13);
    JMI_INI_STR_STAT(tmp_14)
    snprintf(JMI_STR_END(tmp_14), JMI_STR_LEFT(tmp_14), \"%-*.*g\", (int) AD_WRAP_LITERAL(12), (int) AD_WRAP_LITERAL(8), - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"-3.1400000  \", tmp_14);
    JMI_INI_STR_STAT(tmp_15)
    snprintf(JMI_STR_END(tmp_15), JMI_STR_LEFT(tmp_15), ((JMI_FALSE) ? (\"%-*.*g\") : (\"%*.*g\")), (int) AD_WRAP_LITERAL(12), (int) AD_WRAP_LITERAL(8), - _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"  -3.1400000\", tmp_15);
    JMI_INI_STR_STAT(tmp_16)
    snprintf(JMI_STR_END(tmp_16), JMI_STR_LEFT(tmp_16), \"%-s\", COND_EXP_EQ(_boolVar_2, JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"false\", tmp_16);
    JMI_INI_STR_STAT(tmp_17)
    snprintf(JMI_STR_END(tmp_17), JMI_STR_LEFT(tmp_17), \"%-*s\", (int) AD_WRAP_LITERAL(12), COND_EXP_EQ(_boolVar_2, JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"false       \", tmp_17);
    JMI_INI_STR_STAT(tmp_18)
    snprintf(JMI_STR_END(tmp_18), JMI_STR_LEFT(tmp_18), ((JMI_FALSE) ? (\"%-*s\") : (\"%*s\")), (int) AD_WRAP_LITERAL(12), COND_EXP_EQ(_boolVar_2, JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"       false\", tmp_18);
    JMI_INI_STR_STAT(tmp_19)
    snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%-s\", COND_EXP_EQ(LOG_EXP_NOT(_boolVar_2), JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"true\", tmp_19);
    JMI_INI_STR_STAT(tmp_20)
    snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%-*s\", (int) AD_WRAP_LITERAL(12), COND_EXP_EQ(LOG_EXP_NOT(_boolVar_2), JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"true        \", tmp_20);
    JMI_INI_STR_STAT(tmp_21)
    snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), ((JMI_FALSE) ? (\"%-*s\") : (\"%*s\")), (int) AD_WRAP_LITERAL(12), COND_EXP_EQ(LOG_EXP_NOT(_boolVar_2), JMI_TRUE, \"true\", \"false\"));
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"        true\", tmp_21);
    JMI_INI_STR_STAT(tmp_22)
    snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%-s\", E_0_e[(int) _enumVar_3]);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"medium\", tmp_22);
    JMI_INI_STR_STAT(tmp_23)
    snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%-*s\", (int) AD_WRAP_LITERAL(12), E_0_e[(int) _enumVar_3]);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"medium      \", tmp_23);
    JMI_INI_STR_STAT(tmp_24)
    snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), ((JMI_FALSE) ? (\"%-*s\") : (\"%*s\")), (int) AD_WRAP_LITERAL(12), E_0_e[(int) _enumVar_3]);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"      medium\", tmp_24);
    JMI_INI_STR_STAT(tmp_25)
    snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%d\", (int) _intVar_1);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"42\", tmp_25);
    JMI_INI_STR_STAT(tmp_26)
    snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%f\", _realVar_0);
    func_CCodeGenTests_CStringExp_StringCompare_def0(\"3.1400000\", tmp_26);
    (*res)[0] = COND_EXP_EQ(COND_EXP_LT(_realVar_0, AD_WRAP_LITERAL(2.5), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(12), AD_WRAP_LITERAL(42)) - (_intVar_1);
    (*res)[1] = COND_EXP_EQ(COND_EXP_LT(_realVar_0, AD_WRAP_LITERAL(2.5), JMI_TRUE, JMI_FALSE), JMI_TRUE, JMI_TRUE, JMI_FALSE) - (_boolVar_2);
    (*res)[2] = COND_EXP_EQ(COND_EXP_LT(_realVar_0, AD_WRAP_LITERAL(2.5), JMI_TRUE, JMI_FALSE), JMI_TRUE, AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2)) - (_enumVar_3);
")})));
end CStringExp;




model CCodeGenDiscreteVariables1
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


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenDiscreteVariables1",
			description="Test C code generation of discrete variables.",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
			generatedCode="
#define _c1_0 ((*(jmi->z))[jmi->offs_real_ci+0])
#define _c2_1 ((*(jmi->z))[jmi->offs_real_ci+1])
#define _p1_2 ((*(jmi->z))[jmi->offs_real_pi+0])
#define _p2_3 ((*(jmi->z))[jmi->offs_real_pd+0])
#define _ci1_7 ((*(jmi->z))[jmi->offs_integer_ci+0])
#define _ci2_8 ((*(jmi->z))[jmi->offs_integer_ci+1])
#define _pi1_9 ((*(jmi->z))[jmi->offs_integer_pi+0])
#define _pi2_10 ((*(jmi->z))[jmi->offs_integer_pd+0])
#define _cb1_12 ((*(jmi->z))[jmi->offs_boolean_ci+0])
#define _cb2_13 ((*(jmi->z))[jmi->offs_boolean_ci+1])
#define _pb1_14 ((*(jmi->z))[jmi->offs_boolean_pi+0])
#define _pb2_15 ((*(jmi->z))[jmi->offs_boolean_pd+0])
#define _der_x_20 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _x_5 ((*(jmi->z))[jmi->offs_real_x+0])
#define _w_6 ((*(jmi->z))[jmi->offs_real_w+0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define _rd2_4 ((*(jmi->z))[jmi->offs_real_d+0])
#define _rid2_11 ((*(jmi->z))[jmi->offs_integer_d+0])
#define _rbd2_16 ((*(jmi->z))[jmi->offs_boolean_d+0])

    (*res)[0] = - _x_5 - (_der_x_20);
    (*res)[1] = 4 - (_rd2_4);
    (*res)[2] = 4 - (_w_6);
    (*res)[3] = 4 - (_rid2_11);
    (*res)[4] = JMI_FALSE - (_rbd2_16);
")})));
end CCodeGenDiscreteVariables1;


model CCodeGenParameters1
	function f
		input Real x;
		output Real y;
		external "C";
	end f;
	
	parameter Real x = 1;
	parameter Real y = x;
	parameter Real z = f(1);
	Real dummy = x;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenParameters1",
            description="Make sure scaling is applied properly when setting to parameter values",
            generate_dae=true,
            enable_variable_scaling=true,
            variability_propagation=false,
            template="
$C_DAE_initial_dependent_parameter_assignments$
$C_set_start_values$
",
            generatedCode="
    _y_1 = ((_x_0*sf(0)))/sf(1);
    _z_2 = (func_CCodeGenTests_CCodeGenParameters1_f_exp0(AD_WRAP_LITERAL(1)))/sf(2);

    _x_0 = (1)/sf(0);
    model_init_eval_parameters(jmi);
    _dummy_3 = (0.0)/sf(3);
")})));
end CCodeGenParameters1;

model CCodeGenParameters2
    type E = enumeration(A,B,C);
    
    // Regular independent
    parameter Real    reg1 = 1;
    parameter Integer reg2 = 1;
    parameter E       reg3 = E.A;
    parameter Boolean reg4 = true;
    parameter String  reg5 = "string";
    
    // Structural independent
    parameter Real    struct1 = 1;
    parameter Integer struct2 = 1;
    parameter E       struct3 = E.A;
    parameter Boolean struct4 = true;
    parameter String  struct5 = "string";
    
    // Final independent
    final parameter Real    final1 = 1;
    final parameter Integer final2 = 1;
    final parameter E       final3 = E.A;
    final parameter Boolean final4 = true;
    final parameter String  final5 = "string";
    
    // Evaluate independent
    parameter Real    eval1 = 1 annotation(Evaluate=true);
    parameter Integer eval2 = 1 annotation(Evaluate=true);
    parameter E       eval3 = E.A annotation(Evaluate=true);
    parameter Boolean eval4 = true annotation(Evaluate=true);
    parameter String  eval5 = "string" annotation(Evaluate=true);
    
    parameter Real dummy[n];
    parameter Integer n = if (struct4) then integer(struct1) + struct2 else Integer(struct3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenParameters2",
            description="Code generated for independent parameters",
            generate_dae=true,
            variability_propagation=false,
            template="
N_real_pi = $n_real_pi$;
N_real_pi_s = $n_real_pi_s$;
N_real_pi_f = $n_real_pi_f$;
N_real_pi_e = $n_real_pi_e$;

N_integer_pi = $n_integer_pi$ + $n_enum_pi$;
N_integer_pi_s = $n_integer_pi_s$ + $n_enum_pi_s$;
N_integer_pi_f = $n_integer_pi_f$ + $n_enum_pi_f$;
N_integer_pi_e = $n_integer_pi_e$ + $n_enum_pi_e$;

N_boolean_pi = $n_boolean_pi$;
N_boolean_pi_s = $n_boolean_pi_s$;
N_boolean_pi_f = $n_boolean_pi_f$;
N_boolean_pi_e = $n_boolean_pi_e$;

N_string_pi = $n_string_pi$;
N_string_pi_s = $n_string_pi_s$;
N_string_pi_f = $n_string_pi_f$;
N_string_pi_e = $n_string_pi_e$;
---
$C_variable_aliases$
---
$C_DAE_initial_dependent_parameter_assignments$
---
$C_set_start_values$
",
            generatedCode="
N_real_pi = 6;
N_real_pi_s = 3;
N_real_pi_f = 0;
N_real_pi_e = 0;

N_integer_pi = 5 + 4;
N_integer_pi_s = 4 + 3;
N_integer_pi_f = 0 + 0;
N_integer_pi_e = 0 + 0;

N_boolean_pi = 4;
N_boolean_pi_s = 3;
N_boolean_pi_f = 0;
N_boolean_pi_e = 0;

N_string_pi = 4;
N_string_pi_s = 4;
N_string_pi_f = 0;
N_string_pi_e = 0;
---
#define _reg1_0 ((*(jmi->z))[jmi->offs_real_pi+0])
#define _dummy_1_20 ((*(jmi->z))[jmi->offs_real_pi+1])
#define _dummy_2_21 ((*(jmi->z))[jmi->offs_real_pi+2])
#define _struct1_5 ((*(jmi->z))[jmi->offs_real_pi+3])
#define _final1_10 ((*(jmi->z))[jmi->offs_real_pi+4])
#define _eval1_15 ((*(jmi->z))[jmi->offs_real_pi+5])
#define _reg2_1 ((*(jmi->z))[jmi->offs_integer_pi+0])
#define _reg3_2 ((*(jmi->z))[jmi->offs_integer_pi+1])
#define _struct2_6 ((*(jmi->z))[jmi->offs_integer_pi+2])
#define _final2_11 ((*(jmi->z))[jmi->offs_integer_pi+3])
#define _eval2_16 ((*(jmi->z))[jmi->offs_integer_pi+4])
#define _n_22 ((*(jmi->z))[jmi->offs_integer_pi+5])
#define _struct3_7 ((*(jmi->z))[jmi->offs_integer_pi+6])
#define _final3_12 ((*(jmi->z))[jmi->offs_integer_pi+7])
#define _eval3_17 ((*(jmi->z))[jmi->offs_integer_pi+8])
#define _reg4_3 ((*(jmi->z))[jmi->offs_boolean_pi+0])
#define _struct4_8 ((*(jmi->z))[jmi->offs_boolean_pi+1])
#define _final4_13 ((*(jmi->z))[jmi->offs_boolean_pi+2])
#define _eval4_18 ((*(jmi->z))[jmi->offs_boolean_pi+3])
#define _time ((*(jmi->z))[jmi->offs_t])

---

---
    _reg1_0 = (1);
    _reg2_1 = (1);
    _reg3_2 = (1);
    _reg4_3 = (JMI_TRUE);
    _dummy_1_20 = (0.0);
    _dummy_2_21 = (0.0);
    _struct1_5 = (1);
    _struct2_6 = (1);
    _struct3_7 = (1);
    _struct4_8 = (JMI_TRUE);
    _final1_10 = (1);
    _final2_11 = (1);
    _final3_12 = (1);
    _final4_13 = (JMI_TRUE);
    _eval1_15 = (1);
    _eval2_16 = (1);
    _eval3_17 = (1);
    _eval4_18 = (JMI_TRUE);
    _n_22 = (2);
    model_init_eval_parameters(jmi);
")})));
end CCodeGenParameters2;

model CCodeGenUniqueNames
 model A
  Real y;
 end A;
 
 Real x_y = 1;
 A x(y = x_y + 2);
 Real der_x_y = der(x_y) - 1;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenUniqueNames",
			description="Test that unique names are generated for each variable",
			enable_structural_diagnosis=false,
			index_reduction=false,
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="
$C_variable_aliases$
$C_DAE_equation_residuals$
",
			generatedCode="
#define _der_x_y_3 ((*(jmi->z))[jmi->offs_real_dx+0])
#define _x_y_0 ((*(jmi->z))[jmi->offs_real_x+0])
#define _x_y_1 ((*(jmi->z))[jmi->offs_real_w+0])
#define _der_x_y_2 ((*(jmi->z))[jmi->offs_real_w+1])
#define _time ((*(jmi->z))[jmi->offs_t])

    (*res)[0] = 1 - (_x_y_0);
    (*res)[1] = _x_y_0 + 2 - (_x_y_1);
    (*res)[2] = _der_x_y_3 - 1 - (_der_x_y_2);
")})));
end CCodeGenUniqueNames;


model CCodeGenDotOp
 Real x[2,2] = y .* y ./ (y .+ y .- 2) .^ y;
 Real y[2,2] = {{1,2},{3,4}};

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenDotOp",
			description="C code generation of dot operators (.+, .*, etc)",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = jmi_divide_equation(jmi, _y_1_1_4 * _y_1_1_4,pow((_y_1_1_4 + _y_1_1_4 - 2),_y_1_1_4),\"y[1,1] .* y[1,1] ./ (y[1,1] .+ y[1,1] .- 2) .^ y[1,1]\") - (_x_1_1_0);
    (*res)[1] = jmi_divide_equation(jmi, _y_1_2_5 * _y_1_2_5,pow((_y_1_2_5 + _y_1_2_5 - 2),_y_1_2_5),\"y[1,2] .* y[1,2] ./ (y[1,2] .+ y[1,2] .- 2) .^ y[1,2]\") - (_x_1_2_1);
    (*res)[2] = jmi_divide_equation(jmi, _y_2_1_6 * _y_2_1_6,pow((_y_2_1_6 + _y_2_1_6 - 2),_y_2_1_6),\"y[2,1] .* y[2,1] ./ (y[2,1] .+ y[2,1] .- 2) .^ y[2,1]\") - (_x_2_1_2);
    (*res)[3] = jmi_divide_equation(jmi, _y_2_2_7 * _y_2_2_7,pow((_y_2_2_7 + _y_2_2_7 - 2),_y_2_2_7),\"y[2,2] .* y[2,2] ./ (y[2,2] .+ y[2,2] .- 2) .^ y[2,2]\") - (_x_2_2_3);
    (*res)[4] = 1 - (_y_1_1_4);
    (*res)[5] = 2 - (_y_1_2_5);
    (*res)[6] = 3 - (_y_2_1_6);
    (*res)[7] = 4 - (_y_2_2_7);
")})));
end CCodeGenDotOp;



model CCodeGenMinMax
 Real x[2,2] = {{1,2},{3,4}};
 Real y1 = min(x);
 Real y2 = min(1, 2);
 Real y3 = max(x);
 Real y4 = max(1, 2);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CCodeGenMinMax",
			description="C code generation of min() and max()",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = 1 - (_x_1_1_0);
    (*res)[1] = 2 - (_x_1_2_1);
    (*res)[2] = 3 - (_x_2_1_2);
    (*res)[3] = 4 - (_x_2_2_3);
    (*res)[4] = jmi_min(jmi_min(jmi_min(_x_1_1_0, _x_1_2_1), _x_2_1_2), _x_2_2_3) - (_y1_4);
    (*res)[5] = jmi_min(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2)) - (_y2_5);
    (*res)[6] = jmi_max(jmi_max(jmi_max(_x_1_1_0, _x_1_2_1), _x_2_1_2), _x_2_2_3) - (_y3_6);
    (*res)[7] = jmi_max(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2)) - (_y4_7);
")})));
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
 Real x;
equation
 x = TestFunction1(2.0);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest1",
            description="Test of code generation",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction1_def0(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp0(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunction1_def0(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp0(jmi_ad_var_t i1_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction1_def0(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp0(2.0) - (_x_0);
")})));
end CFunctionTest1;

model CFunctionTest2
 Real x;
 Real y;
equation
 (x, y) = TestFunction2(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest2",
            description="C code gen: functions: using multiple outputs",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    jmi_ad_var_t o2_v;
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    if (o2_o != NULL) *o2_o = o2_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}


    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    func_CCodeGenTests_TestFunction2_def0(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2), &tmp_1, &tmp_2);
    (*res)[0] = tmp_1 - (_x_0);
    (*res)[1] = tmp_2 - (_y_1);
")})));
end CFunctionTest2;

model CFunctionTest3
 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction2(1);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest3",
            description="C code gen: functions: two calls to same function",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    jmi_ad_var_t o2_v;
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    if (o2_o != NULL) *o2_o = o2_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction2_exp0(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(0)) - (_x_0);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp0(AD_WRAP_LITERAL(2), AD_WRAP_LITERAL(3)) - (_y_1);
")})));
end CFunctionTest3;

model CFunctionTest4
 Real x;
 Real y = TestFunction2(2, 3);
equation
 x = TestFunction1(y * 2);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest4",
            description="C code gen: functions: calls to two functions",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);
void func_CCodeGenTests_TestFunction1_def1(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp1(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    jmi_ad_var_t o2_v;
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    if (o2_o != NULL) *o2_o = o2_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}

void func_CCodeGenTests_TestFunction1_def1(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp1(jmi_ad_var_t i1_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction1_def1(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction1_exp1(_y_1 * AD_WRAP_LITERAL(2)) - (_x_0);
    (*res)[1] = func_CCodeGenTests_TestFunction2_exp0(AD_WRAP_LITERAL(2), AD_WRAP_LITERAL(3)) - (_y_1);
")})));
end CFunctionTest4;

model CFunctionTest5
  Real x;
  Real y;
equation
  (x, y) = TestFunction3(1, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest5",
            description="C code gen: functions: fewer components assigned than outputs",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction3_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v);

void func_CCodeGenTests_TestFunction3_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    jmi_ad_var_t o2_v;
    jmi_ad_var_t o3_v;
    o1_v = i1_v + i2_v + i3_v;
    o2_v = i2_v + i3_v;
    o3_v = i1_v + i2_v;
    if (o1_o != NULL) *o1_o = o1_v;
    if (o2_o != NULL) *o2_o = o2_v;
    if (o3_o != NULL) *o3_o = o3_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction3_def0(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
    return o1_v;
}


    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    func_CCodeGenTests_TestFunction3_def0(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2), AD_WRAP_LITERAL(3), &tmp_1, &tmp_2, NULL);
    (*res)[0] = tmp_1 - (_x_0);
    (*res)[1] = tmp_2 - (_y_1);
")})));
end CFunctionTest5;

model CFunctionTest6
  Real x;
  Real z;
equation
  (x, , z) = TestFunction3(1, 2, 3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest6",
            description="C code gen: functions: one output skipped",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction3_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v);

void func_CCodeGenTests_TestFunction3_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o, jmi_ad_var_t* o3_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    jmi_ad_var_t o2_v;
    jmi_ad_var_t o3_v;
    o1_v = i1_v + i2_v + i3_v;
    o2_v = i2_v + i3_v;
    o3_v = i1_v + i2_v;
    if (o1_o != NULL) *o1_o = o1_v;
    if (o2_o != NULL) *o2_o = o2_v;
    if (o3_o != NULL) *o3_o = o3_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction3_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t i3_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction3_def0(i1_v, i2_v, i3_v, &o1_v, NULL, NULL);
    return o1_v;
}


    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    func_CCodeGenTests_TestFunction3_def0(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2), AD_WRAP_LITERAL(3), &tmp_1, NULL, &tmp_2);
    (*res)[0] = tmp_1 - (_x_0);
    (*res)[1] = tmp_2 - (_z_1);
")})));
end CFunctionTest6;

model CFunctionTest7
equation
  TestFunction2(1, 2);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest7",
            description="C code gen: functions: no components assigned",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v);

void func_CCodeGenTests_TestFunction2_def0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v, jmi_ad_var_t* o1_o, jmi_ad_var_t* o2_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    jmi_ad_var_t o2_v;
    o1_v = 0;
    o2_v = i2_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    if (o2_o != NULL) *o2_o = o2_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction2_exp0(jmi_ad_var_t i1_v, jmi_ad_var_t i2_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction2_def0(i1_v, i2_v, &o1_v, NULL);
    return o1_v;
}


    func_CCodeGenTests_TestFunction2_def0(AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2), NULL, NULL);
")})));
end CFunctionTest7;

model CFunctionTest8
 Real x = TestFunctionCallingFunction(1);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest8",
            description="C code gen: functions: function calling other function",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunctionCallingFunction_def0(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunctionCallingFunction_exp0(jmi_ad_var_t i1_v);
void func_CCodeGenTests_TestFunction1_def1(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp1(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionCallingFunction_def0(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    o1_v = func_CCodeGenTests_TestFunction1_exp1(i1_v);
    if (o1_o != NULL) *o1_o = o1_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunctionCallingFunction_exp0(jmi_ad_var_t i1_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunctionCallingFunction_def0(i1_v, &o1_v);
    return o1_v;
}

void func_CCodeGenTests_TestFunction1_def1(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    o1_v = i1_v;
    if (o1_o != NULL) *o1_o = o1_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction1_exp1(jmi_ad_var_t i1_v) {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction1_def1(i1_v, &o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionCallingFunction_exp0(AD_WRAP_LITERAL(1)) - (_x_0);
")})));
end CFunctionTest8;


/* TODO: Why is this commented out?
model CFunctionTest9
 Real x = TestFunctionRecursive(5);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CFunctionTest9",
			description="C code gen: functions:",
			variability_propagation=false,
			inline_functions="none",
			template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
         generatedCode="
void func_CCodeGenTests_TestFunctionRecursive_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunctionRecursive_exp(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionRecursive_def(jmi_ad_var_t i1_v, jmi_ad_var_t* o1_o) {
   JMI_DYNAMIC_INIT()
   jmi_ad_var_t o1_v;
   if (i1_v < 3) {
       o1_v = 1;
   } else {
       o1_v = func_CCodeGenTests_TestFunctionRecursive_exp(i1_v - ( 1 )) + func_CCodeGenTests_TestFunctionRecursive_exp(i1_v - ( 2 ));
   }
   if (o1_o != NULL) *o1_o = o1_v;
   JMI_DYNAMIC_FREE()
   return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunctionRecursive_exp(jmi_ad_var_t i1_v) {
   jmi_ad_var_t o1_v;
   func_CCodeGenTests_TestFunctionRecursive_def(i1_v, &o1_v);
   return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunctionRecursive_exp(5) - (_x_0);
")})));
end CFunctionTest9;
*/

model CFunctionTest10
 Real x = TestFunction0();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest10",
            description="C code gen: functions: no inputs",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunction0_def0(jmi_ad_var_t* o1_o);
jmi_ad_var_t func_CCodeGenTests_TestFunction0_exp0();

void func_CCodeGenTests_TestFunction0_def0(jmi_ad_var_t* o1_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o1_v;
    o1_v = 0;
    if (o1_o != NULL) *o1_o = o1_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestFunction0_exp0() {
    jmi_ad_var_t o1_v;
    func_CCodeGenTests_TestFunction0_def0(&o1_v);
    return o1_v;
}


    (*res)[0] = func_CCodeGenTests_TestFunction0_exp0() - (_x_0);
")})));
end CFunctionTest10;

model CFunctionTest11
equation
 TestFunctionNoOut(1);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest11",
            description="C code gen: functions: no outputs",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_TestFunctionNoOut_def0(jmi_ad_var_t i1_v);

void func_CCodeGenTests_TestFunctionNoOut_def0(jmi_ad_var_t i1_v) {
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return;
}


    func_CCodeGenTests_TestFunctionNoOut_def0(AD_WRAP_LITERAL(1));
")})));
end CFunctionTest11;

model CFunctionTest12
function f
  input Real x[2];
  output Real y[2];
algorithm
  y:=x;
end f;

Real z[2](each nominal=3)={1,1};
Real w[2];
equation
w=f(z);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest12",
            description="C code gen: function and variable scaling",
            enable_variable_scaling=true,
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CFunctionTest12_f_def0(jmi_array_t* x_a, jmi_array_t* y_a);

void func_CCodeGenTests_CFunctionTest12_f_def0(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, y_an, 2, 1)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    jmi_array_ref_1(y_a, 1) = jmi_array_val_1(x_a, 1);
    jmi_array_ref_1(y_a, 2) = jmi_array_val_1(x_a, 2);
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = (_z_1_0*sf(0));
    jmi_array_ref_1(tmp_2, 2) = (_z_2_1*sf(1));
    func_CCodeGenTests_CFunctionTest12_f_def0(tmp_2, tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - ((_w_1_2*sf(2)));
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - ((_w_2_3*sf(3)));
    (*res)[2] = 1 - ((_z_1_0*sf(0)));
    (*res)[3] = 1 - ((_z_2_1*sf(1)));
")})));
end CFunctionTest12;


model CFunctionTest13

		
function F
  input Real x[2];
  input Real u;
  output Real dx[2];
  output Real y[2];
algorithm
  dx := -x + {u,0};
  y := 2*x;
end F;

Real x[2](each start = 3);
Real z[2];
Real u = 3;
Real y[2];
equation
 der(x) = -x;
(z,y) = F(x,u);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest13",
            description="C code gen: solved function call equation",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
void func_CCodeGenTests_CFunctionTest13_F_def0(jmi_array_t* x_a, jmi_ad_var_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a);

void func_CCodeGenTests_CFunctionTest13_F_def0(jmi_array_t* x_a, jmi_ad_var_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, dx_an, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, y_an, 2, 1)
    if (dx_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, dx_an, 2, 1, 2)
        dx_a = dx_an;
    }
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    jmi_array_ref_1(dx_a, 1) = - jmi_array_val_1(x_a, 1) + u_v;
    jmi_array_ref_1(dx_a, 2) = - jmi_array_val_1(x_a, 2);
    jmi_array_ref_1(y_a, 1) = 2 * jmi_array_val_1(x_a, 1);
    jmi_array_ref_1(y_a, 2) = 2 * jmi_array_val_1(x_a, 2);
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1)
    model_ode_guards(jmi);
/************* ODE section *********/
    _der_x_1_7 = - _x_1_0;
    _der_x_2_8 = - _x_2_1;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _u_4 = 3;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _x_1_0;
    jmi_array_ref_1(tmp_3, 2) = _x_2_1;
    func_CCodeGenTests_CFunctionTest13_F_def0(tmp_3, _u_4, tmp_1, tmp_2);
    _z_1_2 = (jmi_array_val_1(tmp_1, 1));
    _z_2_3 = (jmi_array_val_1(tmp_1, 2));
    _y_1_5 = (jmi_array_val_1(tmp_2, 1));
    _y_2_6 = (jmi_array_val_1(tmp_2, 2));
/********* Write back reinits *******/
")})));
end CFunctionTest13;

model CFunctionTest14
function F
  input Real x[2];
  input Real u;
  output Real dx[2];
  output Real y[2];
algorithm
  dx := -x + {u,0};
  y := 2*x;
end F;

Real x[2](each start = 3);
Real z[2];
Real u = 3;
Real y[2];
equation
 der(x) = -x;
(z,y) = F(z+x,u);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest14",
            description="C code gen: unsolved function call equation",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
void func_CCodeGenTests_CFunctionTest14_F_def0(jmi_array_t* x_a, jmi_ad_var_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a);

void func_CCodeGenTests_CFunctionTest14_F_def0(jmi_array_t* x_a, jmi_ad_var_t u_v, jmi_array_t* dx_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, dx_an, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, y_an, 2, 1)
    if (dx_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, dx_an, 2, 1, 2)
        dx_a = dx_an;
    }
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    jmi_array_ref_1(dx_a, 1) = - jmi_array_val_1(x_a, 1) + u_v;
    jmi_array_ref_1(dx_a, 2) = - jmi_array_val_1(x_a, 2);
    jmi_array_ref_1(y_a, 1) = 2 * jmi_array_val_1(x_a, 1);
    jmi_array_ref_1(y_a, 2) = 2 * jmi_array_val_1(x_a, 2);
    JMI_DYNAMIC_FREE()
    return;
}


    model_ode_guards(jmi);
/************* ODE section *********/
    _der_x_1_7 = - _x_1_0;
    _der_x_2_8 = - _x_2_1;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _u_4 = 3;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/********* Write back reinits *******/
")})));
end CFunctionTest14;


model CFunctionTest15
	function f
		input Real[2] x;
		output Real y;
	algorithm
		y := sum(x);
	end f;
	
	parameter Real[2] p1 = {1,2};
    parameter Real p2 = f(p1);
    parameter Real p3 = f(p1 .+ p2);
	Real z(start=f(p1 .+ p3));
    Real w(start=f(p1 .+ p2));
equation
	der(z) = -z;
	der(w) = -w;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFunctionTest15",
            description="Declare temp variables for parameters and start values at start of function",
            inline_functions="none",
            template="
$C_set_start_values$
$C_DAE_initial_dependent_parameter_assignments$
$C_DAE_initial_guess_equation_residuals$
",
            generatedCode="
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    _p1_1_0 = (1);
    _p1_2_1 = (2);
    model_init_eval_parameters(jmi);
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _p1_1_0 + _p3_3;
    jmi_array_ref_1(tmp_1, 2) = _p1_2_1 + _p3_3;
    _z_4 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _p1_1_0 + _p2_2;
    jmi_array_ref_1(tmp_2, 2) = _p1_2_1 + _p2_2;
    _w_5 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_2));
    _der_z_6 = (0.0);
    _der_w_7 = (0.0);

    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = _p1_1_0;
    jmi_array_ref_1(tmp_3, 2) = _p1_2_1;
    _p2_2 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_3));
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 2, 1, 2)
    jmi_array_ref_1(tmp_4, 1) = _p1_1_0 + _p2_2;
    jmi_array_ref_1(tmp_4, 2) = _p1_2_1 + _p2_2;
    _p3_3 = (func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_4));

    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _p1_1_0 + _p3_3;
    jmi_array_ref_1(tmp_1, 2) = _p1_2_1 + _p3_3;
    (*res)[0] = func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_1) - _z_4;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _p1_1_0 + _p2_2;
    jmi_array_ref_1(tmp_2, 2) = _p1_2_1 + _p2_2;
    (*res)[1] = func_CCodeGenTests_CFunctionTest15_f_exp0(tmp_2) - _w_5;
")})));
end CFunctionTest15;


model CForLoop1
 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 1:3 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CForLoop1",
            description="C code generation for for loops: range exp",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CForLoop1_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    jmi_ad_var_t i_0i;
    jmi_ad_var_t i_0ie;
    o_v = 1.0;
    x_v = 0;
    i_0ie = 3 + 1 / 2.0;
    for (i_0i = 1; i_0i < i_0ie; i_0i += 1) {
        x_v = x_v + i_0i;
    }
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CForLoop1_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CForLoop1_f_def0(&o_v);
    return o_v;
}

")})));
end CForLoop1;


model CForLoop2
 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in {2,3,5} loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CForLoop2",
            description="C code generation for for loops: generic exp",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CForLoop2_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    jmi_ad_var_t i_0i;
    int i_0ii;
    jmi_ad_var_t i_0ia[3];
    o_v = 1.0;
    x_v = 0;
    i_0ia[0] = 2;
    i_0ia[1] = 3;
    i_0ia[2] = 5;
    for (i_0ii = 0; i_0ii < 3; i_0ii++) {
        i_0i = i_0ia[i_0ii];
        x_v = x_v + i_0i;
    }
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CForLoop2_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CForLoop2_f_def0(&o_v);
    return o_v;
}

")})));
end CForLoop2;


model CForLoop3
 function f
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 3:-1:1 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CForLoop3",
            description="C code generation for for loops: decreasing range exp",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CForLoop3_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    jmi_ad_var_t i_0i;
    jmi_ad_var_t i_0ie;
    o_v = 1.0;
    x_v = 0;
    i_0ie = 1 + - 1 / 2.0;
    for (i_0i = 3; i_0i > i_0ie; i_0i += - 1) {
        x_v = x_v + i_0i;
    }
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CForLoop3_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CForLoop3_f_def0(&o_v);
    return o_v;
}

")})));
end CForLoop3;


model CForLoop4
 function f
  input Real i;
  output Real o = 1.0;
  protected Real x = 0;
  algorithm
  for i in 3:i:1 loop
   x := x + i;
  end for;
 end f;
 
 Real x = f(-1);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CForLoop4",
            description="C code generation for for loops: range exp, unknown if increasing or decreasing",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CForLoop4_f_def0(jmi_ad_var_t i_v, jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    jmi_ad_var_t i_0i;
    jmi_ad_var_t i_0ie;
    o_v = 1.0;
    x_v = 0;
    i_0ie = 1 + i_0i / 2.0;
    for (i_0i = 3; i_0i * i_0i < i_0ie * i_0i; i_0i += i_0i) {
        x_v = x_v + i_0i;
    }
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CForLoop4_f_exp0(jmi_ad_var_t i_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CForLoop4_f_def0(i_v, &o_v);
    return o_v;
}

")})));
end CForLoop4;



model CArrayInput1
 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = f(1:3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput1",
            description="C code generation: array inputs to functions: basic test",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput1_f_def0(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput1_f_exp0(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput1_f_def0(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput1_f_exp0(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput1_f_def0(inp_a, &out_v);
    return out_v;
}


    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3);
    (*res)[0] = func_CCodeGenTests_CArrayInput1_f_exp0(tmp_1) - (_x_0);
")})));
end CArrayInput1;


model CArrayInput2
 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = 2 + 5 * f((1:3) + {3, 5, 7});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput2",
            description="C code generation: array inputs to functions: expressions around call",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput2_f_def0(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput2_f_exp0(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput2_f_def0(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput2_f_exp0(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput2_f_def0(inp_a, &out_v);
    return out_v;
}


    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1) + AD_WRAP_LITERAL(3);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2) + AD_WRAP_LITERAL(5);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3) + AD_WRAP_LITERAL(7);
    (*res)[0] = 2 + 5 * func_CCodeGenTests_CArrayInput2_f_exp0(tmp_1) - (_x_0);
")})));
end CArrayInput2;


model CArrayInput3
 function f
  input Real inp[3];
  output Real out = sum(inp);
 algorithm
 end f;
 
 Real x = f({f(1:3),f(4:6),f(7:9)});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput3",
            description="C code generation: array inputs to functions: nestled calls",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput3_f_def0(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput3_f_exp0(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput3_f_def0(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput3_f_exp0(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput3_f_def0(inp_a, &out_v);
    return out_v;
}


    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_3, 3, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 3, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3);
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1, 3)
    jmi_array_ref_1(tmp_2, 1) = AD_WRAP_LITERAL(4);
    jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(5);
    jmi_array_ref_1(tmp_2, 3) = AD_WRAP_LITERAL(6);
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_3, 3, 1, 3)
    jmi_array_ref_1(tmp_3, 1) = AD_WRAP_LITERAL(7);
    jmi_array_ref_1(tmp_3, 2) = AD_WRAP_LITERAL(8);
    jmi_array_ref_1(tmp_3, 3) = AD_WRAP_LITERAL(9);
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 3, 1, 3)
    jmi_array_ref_1(tmp_4, 1) = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_1);
    jmi_array_ref_1(tmp_4, 2) = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_2);
    jmi_array_ref_1(tmp_4, 3) = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_3);
    (*res)[0] = func_CCodeGenTests_CArrayInput3_f_exp0(tmp_4) - (_x_0);
")})));
end CArrayInput3;


model CArrayInput4
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput4",
            description="C code generation: array inputs to functions: in assign statement",
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput4_f1_def0(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f1_exp0();
void func_CCodeGenTests_CArrayInput4_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput4_f1_def0(jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3);
    out_v = func_CCodeGenTests_CArrayInput4_f2_exp1(tmp_1);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f1_exp0() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput4_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput4_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput4_f2_exp1(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput4_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput4;


model CArrayInput5
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput5",
            description="C code generation: array inputs to functions: function call stmt",
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput5_f1_def0(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f1_exp0();
void func_CCodeGenTests_CArrayInput5_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out1_o, jmi_ad_var_t* out2_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput5_f1_def0(jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    jmi_ad_var_t t_v;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3);
    func_CCodeGenTests_CArrayInput5_f2_def1(tmp_1, &out_v, &t_v);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f1_exp0() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput5_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput5_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out1_o, jmi_ad_var_t* out2_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out1_v;
    jmi_ad_var_t out2_v;
    out1_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    out2_v = jmi_max(jmi_max(jmi_array_val_1(inp_a, 1), jmi_array_val_1(inp_a, 2)), jmi_array_val_1(inp_a, 3));
    if (out1_o != NULL) *out1_o = out1_v;
    if (out2_o != NULL) *out2_o = out2_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput5_f2_exp1(jmi_array_t* inp_a) {
    jmi_ad_var_t out1_v;
    func_CCodeGenTests_CArrayInput5_f2_def1(inp_a, &out1_v, NULL);
    return out1_v;
}

")})));
end CArrayInput5;


model CArrayInput6
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput6",
            description="C code generation: array inputs to functions: if statement",
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput6_f1_def0(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f1_exp0();
void func_CCodeGenTests_CArrayInput6_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput6_f1_def0(jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_5, 2, 1)
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1, 2)
    jmi_array_ref_1(tmp_3, 1) = AD_WRAP_LITERAL(3);
    jmi_array_ref_1(tmp_3, 2) = AD_WRAP_LITERAL(4);
    if (COND_EXP_LT(func_CCodeGenTests_CArrayInput6_f2_exp1(tmp_1), 4, JMI_TRUE, JMI_FALSE)) {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
        jmi_array_ref_1(tmp_2, 1) = AD_WRAP_LITERAL(5);
        jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(6);
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp1(tmp_2);
    } else if (COND_EXP_GT(func_CCodeGenTests_CArrayInput6_f2_exp1(tmp_3), 5, JMI_TRUE, JMI_FALSE)) {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_4, 2, 1, 2)
        jmi_array_ref_1(tmp_4, 1) = AD_WRAP_LITERAL(7);
        jmi_array_ref_1(tmp_4, 2) = AD_WRAP_LITERAL(8);
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp1(tmp_4);
    } else {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_5, 2, 1, 2)
        jmi_array_ref_1(tmp_5, 1) = AD_WRAP_LITERAL(9);
        jmi_array_ref_1(tmp_5, 2) = AD_WRAP_LITERAL(10);
        out_v = func_CCodeGenTests_CArrayInput6_f2_exp1(tmp_5);
    }
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f1_exp0() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput6_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput6_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput6_f2_exp1(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput6_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput6;


model CArrayInput7
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput7",
            description="C code generation: array inputs to functions: while stmt",
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput7_f1_def0(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f1_exp0();
void func_CCodeGenTests_CArrayInput7_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput7_f1_def0(jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1)
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3);
    while (COND_EXP_LT(func_CCodeGenTests_CArrayInput7_f2_exp1(tmp_1), 2, JMI_TRUE, JMI_FALSE)) {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1, 3)
        jmi_array_ref_1(tmp_2, 1) = AD_WRAP_LITERAL(4);
        jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(5);
        jmi_array_ref_1(tmp_2, 3) = AD_WRAP_LITERAL(6);
        out_v = func_CCodeGenTests_CArrayInput7_f2_exp1(tmp_2);
    }
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f1_exp0() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput7_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput7_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput7_f2_exp1(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput7_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput7;


model CArrayInput8
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayInput8",
            description="C code generation: array inputs to functions: for stmt",
            variability_propagation=false,
            inline_functions="none",
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_CArrayInput8_f1_def0(jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f1_exp0();
void func_CCodeGenTests_CArrayInput8_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o);
jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f2_exp1(jmi_array_t* inp_a);

void func_CCodeGenTests_CArrayInput8_f1_def0(jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1)
    jmi_ad_var_t i_0i;
    int i_0ii;
    jmi_ad_var_t i_0ia[2];
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_3, 3, 1)
    out_v = 1.0;
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    jmi_array_ref_1(tmp_1, 3) = AD_WRAP_LITERAL(3);
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1, 3)
    jmi_array_ref_1(tmp_2, 1) = AD_WRAP_LITERAL(4);
    jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(5);
    jmi_array_ref_1(tmp_2, 3) = AD_WRAP_LITERAL(6);
    i_0ia[0] = func_CCodeGenTests_CArrayInput8_f2_exp1(tmp_1);
    i_0ia[1] = func_CCodeGenTests_CArrayInput8_f2_exp1(tmp_2);
    for (i_0ii = 0; i_0ii < 2; i_0ii++) {
        i_0i = i_0ia[i_0ii];
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_3, 3, 1, 3)
        jmi_array_ref_1(tmp_3, 1) = AD_WRAP_LITERAL(7);
        jmi_array_ref_1(tmp_3, 2) = AD_WRAP_LITERAL(8);
        jmi_array_ref_1(tmp_3, 3) = AD_WRAP_LITERAL(9);
        out_v = func_CCodeGenTests_CArrayInput8_f2_exp1(tmp_3);
    }
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f1_exp0() {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput8_f1_def0(&out_v);
    return out_v;
}

void func_CCodeGenTests_CArrayInput8_f2_def1(jmi_array_t* inp_a, jmi_ad_var_t* out_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t out_v;
    out_v = jmi_array_val_1(inp_a, 1) + jmi_array_val_1(inp_a, 2) + jmi_array_val_1(inp_a, 3);
    if (out_o != NULL) *out_o = out_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayInput8_f2_exp1(jmi_array_t* inp_a) {
    jmi_ad_var_t out_v;
    func_CCodeGenTests_CArrayInput8_f2_def1(inp_a, &out_v);
    return out_v;
}

")})));
end CArrayInput8;


model CArrayOutputs1
 function f
  output Real o[2] = {1,2};
 algorithm
 end f;
 
 Real x[2] = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs1",
            description="C code generation: array outputs from functions: in equation",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs1_f_def0(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs1_f_def0(jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1)
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs1_f_def0(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - (_x_1_0);
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - (_x_2_1);
")})));
end CArrayOutputs1;


model CArrayOutputs2
 function f
  output Real o[2] = {1,2};
 algorithm
 end f;
 
 Real x;
equation
 x = f() * {3,4};

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs2",
            description="C code generation: array outputs from functions: in expression in equation",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs2_f_def0(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs2_f_def0(jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1)
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_CArrayOutputs2_f_def0(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1, 1) - (_temp_1_1_1);
    (*res)[1] = jmi_array_val_1(tmp_1, 2) - (_temp_1_2_2);
    (*res)[2] = _temp_1_1_1 * 3 + _temp_1_2_2 * 4 - (_x_0);
")})));
end CArrayOutputs2;


model CArrayOutputs3
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs3",
            description="C code generation: array outputs from functions: in expression in function",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs3_f1_def0(jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CArrayOutputs3_f1_exp0();
void func_CCodeGenTests_CArrayOutputs3_f2_def1(jmi_array_t* o_a);

void func_CCodeGenTests_CArrayOutputs3_f1_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    jmi_ad_var_t x_v;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, 2, 1, 2)
    o_v = 0;
    func_CCodeGenTests_CArrayOutputs3_f2_def1(temp_1_a);
    x_v = jmi_array_val_1(temp_1_a, 1) * 3 + jmi_array_val_1(temp_1_a, 2) * 4;
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayOutputs3_f1_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CArrayOutputs3_f1_def0(&o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs3_f2_def1(jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1)
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    (*res)[0] = func_CCodeGenTests_CArrayOutputs3_f1_exp0() - (_x_0);
")})));
end CArrayOutputs3;


model CArrayOutputs4
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs4",
            description="C code generation: array outputs from functions: function call statement",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs4_f1_def0(jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CArrayOutputs4_f1_exp0();
void func_CCodeGenTests_CArrayOutputs4_f2_def1(jmi_array_t* o1_a, jmi_ad_var_t* o2_o);

void func_CCodeGenTests_CArrayOutputs4_f1_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, x_a, 2, 1)
    jmi_ad_var_t y_v;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, x_a, 2, 1, 2)
    o_v = 0;
    func_CCodeGenTests_CArrayOutputs4_f2_def1(x_a, &y_v);
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayOutputs4_f1_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CArrayOutputs4_f1_def0(&o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs4_f2_def1(jmi_array_t* o1_a, jmi_ad_var_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o1_an, 2, 1)
    jmi_ad_var_t o2_v;
    if (o1_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o1_an, 2, 1, 2)
        o1_a = o1_an;
    }
    jmi_array_ref_1(o1_a, 1) = 1;
    jmi_array_ref_1(o1_a, 2) = 2;
    o2_v = 3;
    if (o2_o != NULL) *o2_o = o2_v;
    JMI_DYNAMIC_FREE()
    return;
}


    (*res)[0] = func_CCodeGenTests_CArrayOutputs4_f1_exp0() - (_x_0);
")})));
end CArrayOutputs4;


model CArrayOutputs5
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CArrayOutputs5",
            description="C code generation: array outputs from functions: passing input array",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CArrayOutputs5_f1_def0(jmi_array_t* i_a, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CArrayOutputs5_f1_exp0(jmi_array_t* i_a);
void func_CCodeGenTests_CArrayOutputs5_f2_def1(jmi_array_t* i_a, jmi_array_t* o1_a, jmi_ad_var_t* o2_o);

void func_CCodeGenTests_CArrayOutputs5_f1_def0(jmi_array_t* i_a, jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, x_a, 2, 1)
    jmi_ad_var_t y_v;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, x_a, 2, 1, 2)
    o_v = 0;
    func_CCodeGenTests_CArrayOutputs5_f2_def1(i_a, x_a, &y_v);
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CArrayOutputs5_f1_exp0(jmi_array_t* i_a) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CArrayOutputs5_f1_def0(i_a, &o_v);
    return o_v;
}

void func_CCodeGenTests_CArrayOutputs5_f2_def1(jmi_array_t* i_a, jmi_array_t* o1_a, jmi_ad_var_t* o2_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o1_an, 2, 1)
    jmi_ad_var_t o2_v;
    if (o1_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o1_an, 2, 1, 2)
        o1_a = o1_an;
    }
    jmi_array_ref_1(o1_a, 1) = jmi_array_val_1(i_a, 1);
    jmi_array_ref_1(o1_a, 2) = jmi_array_val_1(i_a, 2);
    o2_v = 3;
    if (o2_o != NULL) *o2_o = o2_v;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
    (*res)[0] = func_CCodeGenTests_CArrayOutputs5_f1_exp0(tmp_1) - (_x_0);
")})));
end CArrayOutputs5;



model CAbsTest1
 Real x = abs(y);
 Real y = -2;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CAbsTest1",
			description="C code generation for abs() operator",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = jmi_abs(_y_1) - (_x_0);
    (*res)[1] = - 2 - (_y_1);
")})));
end CAbsTest1;



model CUnknownArray1
 function f
  input Real a[:];
  input Real b[size(a,1)];
  output Real o[size(a,1)] = a + b;
 algorithm
 end f;
 
 Real x[2] = f({1,2}, {3,4});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray1",
            description="C code generation for unknown array sizes: basic test",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray1_f_def0(jmi_array_t* a_a, jmi_array_t* b_a, jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, o_an, -1, 1)
    jmi_ad_var_t i1_0i;
    jmi_ad_var_t i1_0ie;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, o_an, jmi_array_size(a_a, 0), 1, jmi_array_size(a_a, 0))
        o_a = o_an;
    }
    i1_0ie = jmi_array_size(a_a, 0) + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        jmi_array_ref_1(o_a, i1_0i) = jmi_array_val_1(a_a, i1_0i) + jmi_array_val_1(b_a, i1_0i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray1;


model CUnknownArray2
	function f
		input Real x[:,2];
		output Real y[size(x, 1), 2];
	algorithm
		y := x * {{1, 2}, {3, 4}};
	end f;

	Real x[3,2] = f({{5,6},{7,8},{9,0}});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray2",
            description="C code generation for unknown array sizes: array constructor * array with unknown size",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray2_f_def0(jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, y_an, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, -1, 2)
    jmi_ad_var_t temp_2_v;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, temp_3_a, 4, 2)
    jmi_ad_var_t i3_0i;
    jmi_ad_var_t i3_0ie;
    jmi_ad_var_t i4_1i;
    jmi_ad_var_t i4_1ie;
    jmi_ad_var_t i5_2i;
    jmi_ad_var_t i5_2ie;
    jmi_ad_var_t i1_3i;
    jmi_ad_var_t i1_3ie;
    jmi_ad_var_t i2_4i;
    jmi_ad_var_t i2_4ie;
    JMI_ARRAY_INIT_2(STAT, jmi_ad_var_t, jmi_array_t, temp_3_a, 4, 2, 2, 2)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, y_an, jmi_array_size(x_a, 0) * 2, 2, jmi_array_size(x_a, 0), 2)
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, jmi_array_size(x_a, 0) * 2, 2, jmi_array_size(x_a, 0), 2)
    jmi_array_ref_2(temp_3_a, 1, 1) = 1;
    jmi_array_ref_2(temp_3_a, 1, 2) = 2;
    jmi_array_ref_2(temp_3_a, 2, 1) = 3;
    jmi_array_ref_2(temp_3_a, 2, 2) = 4;
    i3_0ie = jmi_array_size(x_a, 0) + 1 / 2.0;
    for (i3_0i = 1; i3_0i < i3_0ie; i3_0i += 1) {
        i4_1ie = 2 + 1 / 2.0;
        for (i4_1i = 1; i4_1i < i4_1ie; i4_1i += 1) {
            temp_2_v = 0.0;
            i5_2ie = 2 + 1 / 2.0;
            for (i5_2i = 1; i5_2i < i5_2ie; i5_2i += 1) {
                temp_2_v = temp_2_v + jmi_array_val_2(x_a, i3_0i, i5_2i) * jmi_array_val_2(temp_3_a, i5_2i, i4_1i);
            }
            jmi_array_ref_2(temp_1_a, i3_0i, i4_1i) = temp_2_v;
        }
    }
    i1_3ie = jmi_array_size(x_a, 0) + 1 / 2.0;
    for (i1_3i = 1; i1_3i < i1_3ie; i1_3i += 1) {
        i2_4ie = 2 + 1 / 2.0;
        for (i2_4i = 1; i2_4i < i2_4ie; i2_4i += 1) {
            jmi_array_ref_2(y_a, i1_3i, i2_4i) = jmi_array_val_2(temp_1_a, i1_3i, i2_4i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray2;


// This tests for a bug that wasn't exposed until C code generation
model CUnknownArray3
    function f1
        input Real[:] x1;
        output Real y1;
    algorithm
        y1 := f3(f2(x1));
    end f1;
    
    function f2
        input Real[:] x2;
        output Real[size(x2,1)] y2;
    algorithm
        y2 := x2;
    end f2;
    
    function f3
        input Real[:] x3;
        output Real y3;
    algorithm
        y3 := sum(x3);
    end f3;
    
    Real x = f1({1,2});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray3",
            description="Passing array return value of unknown size directly to other function",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray3_f1_def0(jmi_array_t* x1_a, jmi_ad_var_t* y1_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y1_v;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, -1, 1)
    JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, jmi_array_size(x1_a, 0), 1, jmi_array_size(x1_a, 0))
    func_CCodeGenTests_CUnknownArray3_f2_def2(x1_a, temp_1_a);
    y1_v = func_CCodeGenTests_CUnknownArray3_f3_exp1(temp_1_a);
    if (y1_o != NULL) *y1_o = y1_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CUnknownArray3_f1_exp0(jmi_array_t* x1_a) {
    jmi_ad_var_t y1_v;
    func_CCodeGenTests_CUnknownArray3_f1_def0(x1_a, &y1_v);
    return y1_v;
}

void func_CCodeGenTests_CUnknownArray3_f3_def1(jmi_array_t* x3_a, jmi_ad_var_t* y3_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y3_v;
    jmi_ad_var_t temp_1_v;
    jmi_ad_var_t i1_0i;
    jmi_ad_var_t i1_0ie;
    temp_1_v = 0.0;
    i1_0ie = jmi_array_size(x3_a, 0) + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        temp_1_v = temp_1_v + jmi_array_val_1(x3_a, i1_0i);
    }
    y3_v = temp_1_v;
    if (y3_o != NULL) *y3_o = y3_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CUnknownArray3_f3_exp1(jmi_array_t* x3_a) {
    jmi_ad_var_t y3_v;
    func_CCodeGenTests_CUnknownArray3_f3_def1(x3_a, &y3_v);
    return y3_v;
}

void func_CCodeGenTests_CUnknownArray3_f2_def2(jmi_array_t* x2_a, jmi_array_t* y2_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, y2_an, -1, 1)
    jmi_ad_var_t i1_1i;
    jmi_ad_var_t i1_1ie;
    if (y2_a == NULL) {
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, y2_an, jmi_array_size(x2_a, 0), 1, jmi_array_size(x2_a, 0))
        y2_a = y2_an;
    }
    i1_1ie = jmi_array_size(x2_a, 0) + 1 / 2.0;
    for (i1_1i = 1; i1_1i < i1_1ie; i1_1i += 1) {
        jmi_array_ref_1(y2_a, i1_1i) = jmi_array_val_1(x2_a, i1_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray3;

model CUnknownArray4
function f
	input Real[:] i;
	output Real[size(i,1)] o;
	output Real dummy = 1;
algorithm
	o := i;
end f;

function fw
	input Integer[:] i;
	output Real[size(i,1)] o;
	output Real dummy = 1;
algorithm
	o[{1,3,5}] := {1,1,1};
	(o[i],) := f(o[i]);
end fw;

Real[3] ae;
equation
	(ae[{3,2,1}],) = fw({1,2,3});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray4",
            description="Unknown size expression",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray4_fw_def0(jmi_array_t* i_a, jmi_array_t* o_a, jmi_ad_var_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, o_an, -1, 1)
    jmi_ad_var_t dummy_v;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, -1, 1)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, -1, 1)
    jmi_ad_var_t i1_0i;
    jmi_ad_var_t i1_0ie;
    jmi_ad_var_t i1_1i;
    jmi_ad_var_t i1_1ie;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, o_an, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
        o_a = o_an;
    }
    JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
    JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
    dummy_v = 1;
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 3) = 1;
    jmi_array_ref_1(o_a, 5) = 1;
    i1_0ie = jmi_array_size(i_a, 0) + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        jmi_array_ref_1(temp_1_a, i1_0i) = jmi_array_val_1(o_a, jmi_array_val_1(i_a, i1_0i));
    }
    func_CCodeGenTests_CUnknownArray4_f_def1(temp_1_a, temp_2_a, NULL);
    i1_1ie = jmi_array_size(i_a, 0) + 1 / 2.0;
    for (i1_1i = 1; i1_1i < i1_1ie; i1_1i += 1) {
        jmi_array_ref_1(o_a, jmi_array_ref_1(i_a, i1_1i)) = jmi_array_val_1(temp_2_a, i1_1i);
    }
    if (dummy_o != NULL) *dummy_o = dummy_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_CUnknownArray4_f_def1(jmi_array_t* i_a, jmi_array_t* o_a, jmi_ad_var_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, o_an, -1, 1)
    jmi_ad_var_t dummy_v;
    jmi_ad_var_t i1_2i;
    jmi_ad_var_t i1_2ie;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, o_an, jmi_array_size(i_a, 0), 1, jmi_array_size(i_a, 0))
        o_a = o_an;
    }
    dummy_v = 1;
    i1_2ie = jmi_array_size(i_a, 0) + 1 / 2.0;
    for (i1_2i = 1; i1_2i < i1_2ie; i1_2i += 1) {
        jmi_array_ref_1(o_a, i1_2i) = jmi_array_val_1(i_a, i1_2i);
    }
    if (dummy_o != NULL) *dummy_o = dummy_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray4;

model CUnknownArray5
function f
	input Integer[:] i1;
	input Integer[size(i1,1)] i2;
	input Real[:,:] x;
	output Real[size(i1,1),size(i1,1)] y;
algorithm
	y := transpose([x[i1,i2]]);
end f;

Real[2,2] ae = f({1,2},{2,1},{{3,4},{5,6},{7,8}});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray5",
            description="Unknown size slice of matrix in transpose",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray5_f_def0(jmi_array_t* i1_a, jmi_array_t* i2_a, jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, y_an, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, -1, 2)
    jmi_ad_var_t i7_0i;
    jmi_ad_var_t i7_0ie;
    jmi_ad_var_t i8_1i;
    jmi_ad_var_t i8_1ie;
    jmi_ad_var_t i5_2i;
    jmi_ad_var_t i5_2ie;
    jmi_ad_var_t i6_3i;
    jmi_ad_var_t i6_3ie;
    jmi_ad_var_t i3_4i;
    jmi_ad_var_t i3_4ie;
    jmi_ad_var_t i4_5i;
    jmi_ad_var_t i4_5ie;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, y_an, jmi_array_size(i1_a, 0) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i1_a, 0))
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, jmi_array_size(i1_a, 0) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i1_a, 0))
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, jmi_array_size(i1_a, 0) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i1_a, 0))
    i7_0ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
    for (i7_0i = 1; i7_0i < i7_0ie; i7_0i += 1) {
        i8_1ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
        for (i8_1i = 1; i8_1i < i8_1ie; i8_1i += 1) {
            jmi_array_ref_2(temp_2_a, i7_0i, i8_1i) = jmi_array_val_2(x_a, jmi_array_val_1(i1_a, i7_0i), jmi_array_val_1(i2_a, i8_1i));
        }
    }
    i5_2ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
    for (i5_2i = 1; i5_2i < i5_2ie; i5_2i += 1) {
        i6_3ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
        for (i6_3i = 1; i6_3i < i6_3ie; i6_3i += 1) {
            jmi_array_ref_2(temp_1_a, i5_2i, i6_3i) = jmi_array_val_2(temp_2_a, i5_2i, i6_3i);
        }
    }
    i3_4ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
    for (i3_4i = 1; i3_4i < i3_4ie; i3_4i += 1) {
        i4_5ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
        for (i4_5i = 1; i4_5i < i4_5ie; i4_5i += 1) {
            jmi_array_ref_2(y_a, i3_4i, i4_5i) = jmi_array_val_2(temp_1_a, i4_5i, i3_4i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray5;

model CUnknownArray6
function f
    input Integer[:] i1;
    input Integer[size(i1,1)] i2;
    input Real[:,:] x;
    output Real[size(i1,1) * 2 - 2,size(i1,1)] y;
algorithm
    y := transpose([x[i1,i2]]);
end f;

Real[2,2] ae = f({1,2},{2,1},{{3,4},{5,6},{7,8}});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray6",
            description="Multiple unknown size outputs with low precedence exp",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray6_f_def0(jmi_array_t* i1_a, jmi_array_t* i2_a, jmi_array_t* x_a, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, y_an, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, -1, 2)
    jmi_ad_var_t i7_0i;
    jmi_ad_var_t i7_0ie;
    jmi_ad_var_t i8_1i;
    jmi_ad_var_t i8_1ie;
    jmi_ad_var_t i5_2i;
    jmi_ad_var_t i5_2ie;
    jmi_ad_var_t i6_3i;
    jmi_ad_var_t i6_3ie;
    jmi_ad_var_t i3_4i;
    jmi_ad_var_t i3_4ie;
    jmi_ad_var_t i4_5i;
    jmi_ad_var_t i4_5ie;
    if (y_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, y_an, (jmi_array_size(i1_a, 0) * 2 - 2) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0) * 2 - 2, jmi_array_size(i1_a, 0))
        y_a = y_an;
    }
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, jmi_array_size(i1_a, 0) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i1_a, 0))
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, jmi_array_size(i1_a, 0) * jmi_array_size(i1_a, 0), 2, jmi_array_size(i1_a, 0), jmi_array_size(i1_a, 0))
    i7_0ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
    for (i7_0i = 1; i7_0i < i7_0ie; i7_0i += 1) {
        i8_1ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
        for (i8_1i = 1; i8_1i < i8_1ie; i8_1i += 1) {
            jmi_array_ref_2(temp_2_a, i7_0i, i8_1i) = jmi_array_val_2(x_a, jmi_array_val_1(i1_a, i7_0i), jmi_array_val_1(i2_a, i8_1i));
        }
    }
    i5_2ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
    for (i5_2i = 1; i5_2i < i5_2ie; i5_2i += 1) {
        i6_3ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
        for (i6_3i = 1; i6_3i < i6_3ie; i6_3i += 1) {
            jmi_array_ref_2(temp_1_a, i5_2i, i6_3i) = jmi_array_val_2(temp_2_a, i5_2i, i6_3i);
        }
    }
    i3_4ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
    for (i3_4i = 1; i3_4i < i3_4ie; i3_4i += 1) {
        i4_5ie = jmi_array_size(i1_a, 0) + 1 / 2.0;
        for (i4_5i = 1; i4_5i < i4_5ie; i4_5i += 1) {
            jmi_array_ref_2(y_a, i3_4i, i4_5i) = jmi_array_val_2(temp_1_a, i4_5i, i3_4i);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CUnknownArray6;

model CUnknownArray7
    record R1
        R2[1] x;
    end R1;
    record R2
        Real[1] y;
    end R2;
    function f
        input Integer m;
        output R1[m,m] o;
    algorithm
        for i in 1:m loop
            o[i,:] := {R1({R2({i*j})}) for j in 1:m};
        end for;
    end f;
    
    R1[1,1] c = f(1);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CUnknownArray7",
            description="Unknown size record array",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CUnknownArray7_f_def0(jmi_ad_var_t m_v, R1_1_ra* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, R1_1_r, R1_1_ra, o_an, -1, 2)
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_1_max;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_2_max;
    JMI_ARR(DYNA, R1_1_r, R1_1_ra, temp_1_a, -1, 1)
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_3_max;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_4_max;
    jmi_ad_var_t i_0i;
    jmi_ad_var_t i_0ie;
    jmi_ad_var_t i2_1i;
    jmi_ad_var_t i2_1ie;
    jmi_ad_var_t i1_2i;
    jmi_ad_var_t i1_2ie;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_2(DYNA, R1_1_r, R1_1_ra, o_an, m_v * m_v, 2, m_v, m_v)
        tmp_1_max = m_v * m_v + 1;
        for (tmp_1 = 1; tmp_1 < tmp_1_max; tmp_1++) {
            JMI_ARRAY_INIT_1(DYNA, R2_0_r, R2_0_ra, jmi_array_rec_1(o_an, tmp_1)->x, 1, 1, 1)
            tmp_2_max = 1 + 1;
            for (tmp_2 = 1; tmp_2 < tmp_2_max; tmp_2++) {
                JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, jmi_array_rec_1(jmi_array_rec_1(o_an, tmp_1)->x, tmp_2)->y, 1, 1, 1)
            }
        }
        o_a = o_an;
    }
    JMI_ARRAY_INIT_1(DYNA, R1_1_r, R1_1_ra, temp_1_a, m_v, 1, m_v)
    tmp_3_max = m_v + 1;
    for (tmp_3 = 1; tmp_3 < tmp_3_max; tmp_3++) {
        JMI_ARRAY_INIT_1(DYNA, R2_0_r, R2_0_ra, jmi_array_rec_1(temp_1_a, tmp_3)->x, 1, 1, 1)
        tmp_4_max = 1 + 1;
        for (tmp_4 = 1; tmp_4 < tmp_4_max; tmp_4++) {
            JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, jmi_array_rec_1(jmi_array_rec_1(temp_1_a, tmp_3)->x, tmp_4)->y, 1, 1, 1)
        }
    }
    i_0ie = m_v + 1 / 2.0;
    for (i_0i = 1; i_0i < i_0ie; i_0i += 1) {
        i2_1ie = m_v + 1 / 2.0;
        for (i2_1i = 1; i2_1i < i2_1ie; i2_1i += 1) {
            jmi_array_ref_1(jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i2_1i)->x, 1)->y, 1) = i_0i * i2_1i;
        }
        i1_2ie = m_v + 1 / 2.0;
        for (i1_2i = 1; i1_2i < i1_2ie; i1_2i += 1) {
            jmi_array_ref_1(jmi_array_rec_1(jmi_array_rec_2(o_a, i_0i, i1_2i)->x, 1)->y, 1) = jmi_array_val_1(jmi_array_rec_1(jmi_array_rec_1(temp_1_a, i1_2i)->x, 1)->y, 1);
        }
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
end CUnknownArray7;

model CRecordDecl1
    record A
        Real a;
        Real b;
    end A;
    function F
        input A i;
        output Real o;
    algorithm
        o := i.a + i.b;
        annotation(Inline=false);
    end F;
 
    Real r = F(A(time, time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl1",
            description="C code generation for records: structs: basic test",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_records$",
            generatedCode="
typedef struct _A_0_r {
    jmi_ad_var_t a;
    jmi_ad_var_t b;
} A_0_r;
JMI_ARRAY_TYPE(A_0_r, A_0_ra)

")})));
end CRecordDecl1;


model CRecordDecl2
    record A
        Real a;
        B b;
    end A;

    record B
        Real c;
    end B;

    function F
        input A i;
        output Real o;
    algorithm
        o := i.a + i.b.c;
        annotation(Inline=false);
    end F;
 
    Real r = F(A(time, B(time)));


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CRecordDecl2",
			description="C code generation for records: structs: nested records",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_records$",
			generatedCode="
typedef struct _B_0_r {
    jmi_ad_var_t c;
} B_0_r;
JMI_ARRAY_TYPE(B_0_r, B_0_ra)

typedef struct _A_1_r {
    jmi_ad_var_t a;
    B_0_r* b;
} A_1_r;
JMI_ARRAY_TYPE(A_1_r, A_1_ra)

")})));
end CRecordDecl2;


model CRecordDecl3
    record A
        Real a[2];
    end A;
    function F
        input A i;
        output Real o;
    algorithm
        o := i.a[1] + i.a[2];
        annotation(Inline=false);
    end F;
 
    Real r = F(A({time, time}));

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CRecordDecl3",
			description="C code generation for records: structs: array in record",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_records$",
			generatedCode="
typedef struct _A_0_r {
    jmi_array_t* a;
} A_0_r;
JMI_ARRAY_TYPE(A_0_r, A_0_ra)

")})));
end CRecordDecl3;


model CRecordDecl4
    record A
        Real a;
        B b[2];
    end A;

    record B
        Real c;
    end B;
    function F
        input A i;
        output Real o;
    algorithm
        o := i.a + i.b[1].c + i.b[2].c;
        annotation(Inline=false);
    end F;
 
    Real r = F(A(time, {B(time), B(time)}));

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CRecordDecl4",
			description="C code generation for records: structs: array of records",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_records$",
			generatedCode="
typedef struct _B_0_r {
    jmi_ad_var_t c;
} B_0_r;
JMI_ARRAY_TYPE(B_0_r, B_0_ra)

typedef struct _A_1_r {
    jmi_ad_var_t a;
    B_0_ra* b;
} A_1_r;
JMI_ARRAY_TYPE(A_1_r, A_1_ra)

")})));
end CRecordDecl4;


model CRecordDecl5
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl5",
            description="C code generation for records: declarations: basic test",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CRecordDecl5_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    JMI_RECORD_STATIC(A_0_r, x_v)
    x_v->a = 1;
    x_v->b = 2;
    o_v = x_v->a;
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl5_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl5_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl5;


model CRecordDecl6
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl6",
            description="C code generation for records: declarations: nestled records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CRecordDecl6_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    JMI_RECORD_STATIC(A_1_r, x_v)
    JMI_RECORD_STATIC(B_0_r, tmp_1)
    x_v->b = tmp_1;
    x_v->a = 1;
    x_v->b->c = 2;
    o_v = x_v->b->c;
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl6_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl6_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl6;


model CRecordDecl7
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl7",
            description="C code generation for records: declarations: array in record",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CRecordDecl7_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    JMI_RECORD_STATIC(A_0_r, x_v)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    x_v->a = tmp_1;
    jmi_array_ref_1(x_v->a, 1) = 1;
    jmi_array_ref_1(x_v->a, 2) = 2;
    o_v = jmi_array_val_1(x_v->a, 1);
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl7_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl7_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl7;


model CRecordDecl8
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl8",
            description="C code generation for records: declarations: array of records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_CRecordDecl8_f_def0(jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    JMI_ARR(STAT, A_1_r, A_1_ra, x_a, 3, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_1, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARRAY_INIT_1(STAT, A_1_r, A_1_ra, x_a, 3, 1, 3)
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_1, 2, 1, 2)
    jmi_array_rec_1(x_a, 1)->b = tmp_1;
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
    jmi_array_rec_1(x_a, 2)->b = tmp_2;
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
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
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl8_f_exp0() {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl8_f_def0(&o_v);
    return o_v;
}

")})));
end CRecordDecl8;


model CRecordDecl9
 function f
  output A x = A(1,2);
 algorithm
 end f;
 
 record A
  Real a;
  Real b;
 end A;
 
 A x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl9",
            description="C code generation for records: outputs: basic test",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl9_f_def0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl9_f_def0(A_0_r* x_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(A_0_r, x_vn)
    if (x_v == NULL) {
        x_v = x_vn;
    }
    x_v->a = 1;
    x_v->b = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    func_CCodeGenTests_CRecordDecl9_f_def0(tmp_1);
    (*res)[0] = tmp_1->a - (_x_a_0);
    (*res)[1] = tmp_1->b - (_x_b_1);
")})));
end CRecordDecl9;


model CRecordDecl10
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl10",
            description="C code generation for records: outputs: nested arrays",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl10_f_def0(A_1_r* x_v);

void func_CCodeGenTests_CRecordDecl10_f_def0(A_1_r* x_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(A_1_r, x_vn)
    JMI_RECORD_STATIC(B_0_r, tmp_1)
    if (x_v == NULL) {
        x_vn->b = tmp_1;
        x_v = x_vn;
    }
    x_v->a = 1;
    x_v->b->c = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_RECORD_STATIC(A_1_r, tmp_1)
    JMI_RECORD_STATIC(B_0_r, tmp_2)
    tmp_1->b = tmp_2;
    func_CCodeGenTests_CRecordDecl10_f_def0(tmp_1);
    (*res)[0] = tmp_1->a - (_x_a_0);
    (*res)[1] = tmp_1->b->c - (_x_b_c_1);
")})));
end CRecordDecl10;


model CRecordDecl11
  function f
  output A x = A({1,2});
 algorithm
 end f;
 
 record A
  Real a[2];
 end A;
 
 A x = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl11",
            description="C code generation for records: outputs: array in record",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl11_f_def0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl11_f_def0(A_0_r* x_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(A_0_r, x_vn)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    if (x_v == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
        x_vn->a = tmp_1;
        x_v = x_vn;
    }
    jmi_array_ref_1(x_v->a, 1) = 1;
    jmi_array_ref_1(x_v->a, 2) = 2;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    tmp_1->a = tmp_2;
    func_CCodeGenTests_CRecordDecl11_f_def0(tmp_1);
    (*res)[0] = jmi_array_val_1(tmp_1->a, 1) - (_x_a_1_0);
    (*res)[1] = jmi_array_val_1(tmp_1->a, 2) - (_x_a_2_1);
")})));
end CRecordDecl11;


model CRecordDecl12
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl12",
            description="C code generation for records: outputs: array of records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl12_f_def0(A_1_ra* x_a);

void func_CCodeGenTests_CRecordDecl12_f_def0(A_1_ra* x_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, A_1_r, A_1_ra, x_an, 3, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_1, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_3, 2, 1)
    if (x_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, A_1_r, A_1_ra, x_an, 3, 1, 3)
        JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_1, 2, 1, 2)
        jmi_array_rec_1(x_an, 1)->b = tmp_1;
        JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
        jmi_array_rec_1(x_an, 2)->b = tmp_2;
        JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
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
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STAT, A_1_r, A_1_ra, tmp_1, 3, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STAT, A_1_r, A_1_ra, tmp_1, 3, 1, 3)
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 1)->b = tmp_2;
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 2)->b = tmp_3;
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_4, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 3)->b = tmp_4;
    func_CCodeGenTests_CRecordDecl12_f_def0(tmp_1);
    (*res)[0] = jmi_array_rec_1(tmp_1, 1)->a - (_x_1_a_0);
    (*res)[1] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 1)->c - (_x_1_b_1_c_1);
    (*res)[2] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 2)->c - (_x_1_b_2_c_2);
    (*res)[3] = jmi_array_rec_1(tmp_1, 2)->a - (_x_2_a_3);
    (*res)[4] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 1)->c - (_x_2_b_1_c_4);
    (*res)[5] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 2)->c - (_x_2_b_2_c_5);
    (*res)[6] = jmi_array_rec_1(tmp_1, 3)->a - (_x_3_a_6);
    (*res)[7] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 1)->c - (_x_3_b_1_c_7);
    (*res)[8] = jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 2)->c - (_x_3_b_2_c_8);
")})));
end CRecordDecl12;


model CRecordDecl13
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl13",
            description="C code generation for records: inputs: basic test",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl13_f_def0(A_0_r* x_v, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl13_f_exp0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl13_f_def0(A_0_r* x_v, jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    o_v = x_v->a;
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl13_f_exp0(A_0_r* x_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl13_f_def0(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    tmp_1->a = AD_WRAP_LITERAL(1);
    tmp_1->b = AD_WRAP_LITERAL(2);
    (*res)[0] = func_CCodeGenTests_CRecordDecl13_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl13;


model CRecordDecl14
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl14",
            description="C code generation for records: inputs: nested records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl14_f_def0(A_1_r* x_v, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl14_f_exp0(A_1_r* x_v);

void func_CCodeGenTests_CRecordDecl14_f_def0(A_1_r* x_v, jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    o_v = x_v->b->c;
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl14_f_exp0(A_1_r* x_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl14_f_def0(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_STATIC(A_1_r, tmp_1)
    JMI_RECORD_STATIC(B_0_r, tmp_2)
    tmp_1->b = tmp_2;
    tmp_1->a = AD_WRAP_LITERAL(1);
    tmp_1->b->c = AD_WRAP_LITERAL(2);
    (*res)[0] = func_CCodeGenTests_CRecordDecl14_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl14;


model CRecordDecl15
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl15",
            description="C code generation for records: inputs: array in record",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl15_f_def0(A_0_r* x_v, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl15_f_exp0(A_0_r* x_v);

void func_CCodeGenTests_CRecordDecl15_f_def0(A_0_r* x_v, jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    o_v = jmi_array_val_1(x_v->a, 1);
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl15_f_exp0(A_0_r* x_v) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl15_f_def0(x_v, &o_v);
    return o_v;
}


    JMI_RECORD_STATIC(A_0_r, tmp_1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    tmp_1->a = tmp_2;
    jmi_array_ref_1(tmp_1->a, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_1->a, 2) = AD_WRAP_LITERAL(2);
    (*res)[0] = func_CCodeGenTests_CRecordDecl15_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl15;


model CRecordDecl16
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

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl16",
            description="C code generation for records: inputs: array of records",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_CRecordDecl16_f_def0(A_1_ra* x_a, jmi_ad_var_t* o_o);
jmi_ad_var_t func_CCodeGenTests_CRecordDecl16_f_exp0(A_1_ra* x_a);

void func_CCodeGenTests_CRecordDecl16_f_def0(A_1_ra* x_a, jmi_ad_var_t* o_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t o_v;
    o_v = jmi_array_rec_1(jmi_array_rec_1(x_a, 1)->b, 2)->c;
    if (o_o != NULL) *o_o = o_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_CRecordDecl16_f_exp0(A_1_ra* x_a) {
    jmi_ad_var_t o_v;
    func_CCodeGenTests_CRecordDecl16_f_def0(x_a, &o_v);
    return o_v;
}


    JMI_ARR(STAT, A_1_r, A_1_ra, tmp_1, 3, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_2, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_3, 2, 1)
    JMI_ARR(STAT, B_0_r, B_0_ra, tmp_4, 2, 1)
    JMI_ARRAY_INIT_1(STAT, A_1_r, A_1_ra, tmp_1, 3, 1, 3)
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_2, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 1)->b = tmp_2;
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_3, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 2)->b = tmp_3;
    JMI_ARRAY_INIT_1(STAT, B_0_r, B_0_ra, tmp_4, 2, 1, 2)
    jmi_array_rec_1(tmp_1, 3)->b = tmp_4;
    jmi_array_rec_1(tmp_1, 1)->a = AD_WRAP_LITERAL(1);
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 1)->c = AD_WRAP_LITERAL(2);
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 1)->b, 2)->c = AD_WRAP_LITERAL(3);
    jmi_array_rec_1(tmp_1, 2)->a = AD_WRAP_LITERAL(4);
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 1)->c = AD_WRAP_LITERAL(5);
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 2)->b, 2)->c = AD_WRAP_LITERAL(6);
    jmi_array_rec_1(tmp_1, 3)->a = AD_WRAP_LITERAL(7);
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 1)->c = AD_WRAP_LITERAL(8);
    jmi_array_rec_1(jmi_array_rec_1(tmp_1, 3)->b, 2)->c = AD_WRAP_LITERAL(9);
    (*res)[0] = func_CCodeGenTests_CRecordDecl16_f_exp0(tmp_1) - (_x_0);
")})));
end CRecordDecl16;

model CRecordDecl17
    record A
    end A;
    function F
        input Real i;
        output Real o;
        A a;
    algorithm
        o := i;
        annotation(Inline=false);
    end F;
 
    A x;
    Real r = F(time);
    annotation(__JModelica(UnitTesting(tests={ 
        CCodeGenTestCase(
            name="CRecordDecl17",
            description="Test that a default field is created for an empty record.",
            template="$C_records$",
            generatedCode=
"typedef struct _A_0_r {
    char dummy;
} A_0_r;
JMI_ARRAY_TYPE(A_0_r, A_0_ra)

"
)})));
end CRecordDecl17;


model CRecordDecl18
	record A
		Real r;
	end A;
	
	model B
		C c;
	end B;
	
	model C
		A[2] a;
	end C;
	
	B b(c(a = {A(1), A(2)}));

	annotation(__JModelica(UnitTesting(tests={ 
		CCodeGenTestCase(
			name="CRecordDecl18",
			description="Array of records in subcomponent",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_variable_aliases$",
			generatedCode="
#define _b_c_a_1_r_0 ((*(jmi->z))[jmi->offs_real_w+0])
#define _b_c_a_2_r_1 ((*(jmi->z))[jmi->offs_real_w+1])
#define _time ((*(jmi->z))[jmi->offs_t])
")})));
end CRecordDecl18;


model CRecordDecl19
    record R
        Real[2] x;
    end R;
    
    parameter Real[2] p = {1,2};
    R r(x(start=p));
equation
    der(r.x) = p;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl19",
            description="Start value for array member of record",
            template="$C_DAE_initial_guess_equation_residuals$",
            generatedCode="
   (*res)[0] = _p_1_0 - _r_x_1_2;
   (*res)[1] = _p_2_1 - _r_x_2_3;
")})));
end CRecordDecl19;

model CRecordDecl20
    record R
        Real x1 = -1;
        constant Real y = 2;
        final parameter Real z = 3; 
        Real x2;
    end R;
    
    function f
        input R i;
        output Real o = i.x1;
        algorithm
    end f;
    
    Real r = f(R(time,time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CRecordDecl20",
            description="Record constructor of record with unmodifiable components.",
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    tmp_1->x1 = _time;
    tmp_1->y = 2;
    tmp_1->z = 3;
    tmp_1->x2 = _time;
    _r_0 = func_CCodeGenTests_CRecordDecl20_f_exp0(tmp_1);
/********* Write back reinits *******/
")})));
end CRecordDecl20;


model RemoveCopyright
	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="RemoveCopyright",
			description="Test that licence tag is filtered out",
			variability_propagation=false,
			template="/* test copyright blurb */ test",
			generatedCode="
test
")})));
end RemoveCopyright;

model ExtStmtInclude1
	function extFunc
		 external "C" annotation(Include="#include \"extFunc.h\"");
	end extFunc;
	algorithm
		extFunc();

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ExtStmtInclude1",
			description="Test that include statement is inserted properly.",
			variability_propagation=false,
			template="$external_func_includes$",
			generatedCode="
#include \"extFunc.h\"
")})));
end ExtStmtInclude1;

model ExtStmtInclude2
	function extFunc1
		 external "C" annotation(Include="#include \"extFunc1.h\"");
	end extFunc1;
	function extFunc2
		external "C" annotation(Include="#include \"extFunc2.h\"");
	end extFunc2;
	algorithm
		extFunc1();
		extFunc2();

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ExtStmtInclude2",
			description="Test that include statements are inserted properly.",
			variability_propagation=false,
			template="$external_func_includes$",
			generatedCode="
#include \"extFunc2.h\"
#include \"extFunc1.h\"
")})));
end ExtStmtInclude2;

model SimpleExternal1
	Real a_in=1;
	Real b_out;
	function f
		input Real a;
		output Real b;
		external;
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal1",
            description="External C function (undeclared), one scalar input, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal1_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternal1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    b_v = f(a_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal1_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_SimpleExternal1_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternal1;

model SimpleExternal2
	Real a_in=1;
	Real b_in=2;
	Real c_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		external "C";
	end f;
	equation
		c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal2",
            description="External C function (undeclared), two scalar inputs, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal2_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternal2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    c_v = f(a_v, b_v);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal2_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternal2_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end SimpleExternal2;

model SimpleExternal3
	Real a_in=1;
	Real b_out;
	function f
		input Real a;
		output Real b;
		external b = my_f(a);
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal3",
            description="External C function (declared with return), one scalar input, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal3_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternal3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    b_v = my_f(a_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal3_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_SimpleExternal3_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternal3;

model SimpleExternal4
	Real a_in=1;
	Real b_out;
	function f
		input Real a;
		output Real b;
		external my_f(a, b);
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal4",
            description="External C function (declared without return), one scalar input, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal4_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternal4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    my_f(a_v, &b_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal4_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_SimpleExternal4_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternal4;

model SimpleExternal5
	Real a_in=1;
	function f
		input Real a;
		external;
	end f;
	equation
		f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal5",
            description="External C function (undeclared), scalar input, no output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal5_f_def0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternal5_f_def0(jmi_ad_var_t a_v) {
    JMI_DYNAMIC_INIT()
    f(a_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end SimpleExternal5;

model SimpleExternal6
	Real a_in=1;
	function f
		input Real a;
		external my_f(a);
	end f;
	equation
		f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal6",
            description="External C function (declared), scalar input, no output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal6_f_def0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternal6_f_def0(jmi_ad_var_t a_v) {
    JMI_DYNAMIC_INIT()
    my_f(a_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end SimpleExternal6;

model SimpleExternal7
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		external my_f(a,c,b);
	end f;
	equation
		c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal7",
            description="External C function (declared without return), two scalar inputs, one scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal7_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal7_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternal7_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    my_f(a_v, &c_v, b_v);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal7_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternal7_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end SimpleExternal7;

model SimpleExternal8
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		output Real d;
		external my_f(a,c,b,d);
	end f;
	equation
		(c_out, d_out) = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal8",
            description="External C function (declared without return), two scalar inputs, two scalar outputs.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal8_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal8_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternal8_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    my_f(a_v, &c_v, b_v, &d_v);
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal8_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternal8_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end SimpleExternal8;

model SimpleExternal9
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		output Real d;
		external d = my_f(a,b,c);
	end f;
	equation
		(c_out, d_out) = f(a_in, b_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal9",
            description="External C function (declared with return), two scalar inputs, two scalar outputs (one in return stmt, one in fcn stmt).",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal9_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal9_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternal9_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    d_v = my_f(a_v, b_v, &c_v);
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal9_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternal9_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end SimpleExternal9;

model SimpleExternal10
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;
	Real e_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		output Real d;
		output Real e;
		external d = my_f(a,c,b,e);
	end f;
	equation
		(c_out, d_out, e_out) = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternal10",
            description="External C function (declared with return), two scalar inputs, three scalar outputs (one in return stmt, two in fcn stmt).",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternal10_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o, jmi_ad_var_t* e_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternal10_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternal10_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o, jmi_ad_var_t* e_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    jmi_ad_var_t e_v;
    d_v = my_f(a_v, &c_v, b_v, &e_v);
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    if (e_o != NULL) *e_o = e_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternal10_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternal10_f_def0(a_v, b_v, &c_v, NULL, NULL);
    return c_v;
}

")})));
end SimpleExternal10;

model IntegerExternal1
	Integer a_in=1;
	Real b_out;
	function f
		input Integer a;
		output Real b;
		external;
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal1",
            description="External C function (undeclared), one scalar Integer input, one scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternal1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternal1_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_IntegerExternal1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    jmi_int_t tmp_1;
    tmp_1 = (int)a_v;
    b_v = f(tmp_1);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternal1_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternal1_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternal1;

model IntegerExternal2
	Integer a_in=1;
	Integer b_out;
	function f
		input Real a;
		output Integer b;
		external;
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal2",
            description="External C function (undeclared), one scalar Real input, one scalar Integer output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternal2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternal2_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_IntegerExternal2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    b_v = f(a_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternal2_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternal2_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternal2;

model IntegerExternal3
	Integer a_in=1;
	Integer b_out;
	function f
		input Real a;
		output Integer b;
		external my_f(a, b);
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal3",
            description="External C function (declared), one scalar Real input, one scalar Integer output in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternal3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternal3_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_IntegerExternal3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    jmi_int_t tmp_1;
    tmp_1 = (int)b_v;
    my_f(a_v, &tmp_1);
    b_v = tmp_1;
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternal3_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternal3_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternal3;

model IntegerExternal4
	Integer a_in = 1;
	Integer b_in = 2;
	Integer c_out;
	Integer d_out;
	function f
		input Integer a;
		input Integer b;
		output Integer c;
		output Integer d;
		external d = my_f(a,b,c);
	end f;
	equation
		(c_out, d_out) = f(a_in, b_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternal4",
            description="External C function (declared), two scalar Integer inputs, two scalar Integer outputs (one in return, one in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternal4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternal4_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_IntegerExternal4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    jmi_int_t tmp_1;
    jmi_int_t tmp_2;
    jmi_int_t tmp_3;
    tmp_1 = (int)a_v;
    tmp_2 = (int)b_v;
    tmp_3 = (int)c_v;
    d_v = my_f(tmp_1, tmp_2, &tmp_3);
    c_v = tmp_3;
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternal4_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_IntegerExternal4_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end IntegerExternal4;

model ExternalLiteral1
	Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external my_f(a,b,10);
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalLiteral1",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalLiteral1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_ExternalLiteral1_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_ExternalLiteral1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    my_f(a_v, b_v, 10);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalLiteral1_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_ExternalLiteral1_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end ExternalLiteral1;

model ExternalLiteral2
    Real a_in = 1;
    Real b_in = 2;
    Real c_out;
    function f
        input Real a;
        input Real b;
        output Real c;
        external my_f(a,20,b,10);
    end f;
    equation
        c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalLiteral2",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalLiteral2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_ExternalLiteral2_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_ExternalLiteral2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    my_f(a_v, 20, b_v, 10);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalLiteral2_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_ExternalLiteral2_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end ExternalLiteral2;

model ExternalLiteral3
    Real c_out;
    function f
        output Real c;
        external my_f(10,20,30);
    end f;
    equation
        c_out = f();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalLiteral3",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalLiteral3_f_def0(jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_ExternalLiteral3_f_exp0();

void func_CCodeGenTests_ExternalLiteral3_f_def0(jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    my_f(10, 20, 30);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalLiteral3_f_exp0() {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_ExternalLiteral3_f_def0(&c_v);
    return c_v;
}

")})));
end ExternalLiteral3;

model IntegerInFunc1
	function f
		input Integer i;
		input Real a[3];
		output Real x;
	algorithm
		x := a[i];
	end f;
	
	Real x[3] = {2.3, 4.2, 1.5};
	Real y = f(1, x);
	Real z = f(2, x);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerInFunc1",
            description="Using Integer variable in function",
            variability_propagation=false,
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_IntegerInFunc1_f_def0(jmi_ad_var_t i_v, jmi_array_t* a_a, jmi_ad_var_t* x_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t x_v;
    x_v = jmi_array_val_1(a_a, i_v);
    if (x_o != NULL) *x_o = x_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerInFunc1_f_exp0(jmi_ad_var_t i_v, jmi_array_t* a_a) {
    jmi_ad_var_t x_v;
    func_CCodeGenTests_IntegerInFunc1_f_def0(i_v, a_a, &x_v);
    return x_v;
}

")})));
end IntegerInFunc1;

model IfExpInParExp
  parameter Integer N = 2;
  parameter Real r[3] = array((if i<=N then 1. else 2.) for i in 1:3); 

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="IfExpInParExp",
			description="Test that relational expressions in parameter expressions are treated correctly",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_initial_dependent_parameter_residuals$",
			generatedCode="
    (*res)[0] = COND_EXP_EQ(COND_EXP_LE(AD_WRAP_LITERAL(1), _N_0, JMI_TRUE, JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0)) - (_r_1_1);
    (*res)[1] = COND_EXP_EQ(COND_EXP_LE(AD_WRAP_LITERAL(2), _N_0, JMI_TRUE, JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0)) - (_r_2_2);
    (*res)[2] = COND_EXP_EQ(COND_EXP_LE(AD_WRAP_LITERAL(3), _N_0, JMI_TRUE, JMI_FALSE),JMI_TRUE,AD_WRAP_LITERAL(1.0),AD_WRAP_LITERAL(2.0)) - (_r_3_3);
")})));
end IfExpInParExp;



model CIntegerExp1
	Real x = 10 ^ 4;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CIntegerExp1",
			description="Test that exponential expressions with integer exponents are properly transformed",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = (1.0 * (10) * (10) * (10) * (10)) - (_x_0);
")})));
end CIntegerExp1;


model CIntegerExp2
	Real x = 10 ^ (-4);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CIntegerExp2",
			description="Test that exponential expressions with integer exponents are properly transformed",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = (1.0 / (10) / (10) / (10) / (10)) - (_x_0);
")})));
end CIntegerExp2;


model CIntegerExp3
	Real x = 10 ^ 0;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CIntegerExp3",
			description="Test that exponential expressions with integer exponents are properly transformed",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = (1.0) - (_x_0);
")})));
end CIntegerExp3;


model CIntegerExp4
	Real x = 10 ^ 10;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CIntegerExp4",
			description="Test that exponential expressions with integer exponents are properly transformed",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = pow(10,10) - (_x_0);
")})));
end CIntegerExp4;


model CIntegerExp5
	Real x = 10 ^ (-10);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="CIntegerExp5",
			description="Test that exponential expressions with integer exponents are properly transformed",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = pow(10,-10) - (_x_0);
")})));
end CIntegerExp5;



model ModelIdentifierTest
	Real r = 1.0;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ModelIdentifierTest",
			description="",
			variability_propagation=false,
			template="$C_model_id$",
			generatedCode="
CCodeGenTests_ModelIdentifierTest
")})));
end ModelIdentifierTest;

model GUIDTest1
	Real r = 1.0;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="GUIDTest1",
			description="",
			variability_propagation=false,
			template="$C_guid$",
			generatedCode="
\"c143b522ea1fdf6db1132a647457c83a\"
")})));
end GUIDTest1;

model GUIDTest2
	Real r = 2.0;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="GUIDTest2",
			description="",
			variability_propagation=false,
			template="$C_guid$",
			generatedCode="
\"ff13c7197701d1a1e9559970770f01f0\"
")})));
end GUIDTest2;

model DependentParametersWithScalingTest1
  record R
    Real x = 1;
  end R;

  function F
   input Real x;
   output Real y;
  algorithm
   y := 2*x;
  end F;

  function FR
   input R x;
   output R y;
  algorithm
   y := R(x.x*5);
  end FR;

  parameter Real p1 = 1;
  parameter Real p2 = 3*p1;
  parameter Real p3 = F(p2);
  parameter R r = R(3);
  parameter R r2 = r;
  parameter R r3 = FR(r2);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="DependentParametersWithScalingTest1",
            description="",
            enable_variable_scaling=true,
            variability_propagation=false,
            inline_functions="none",
            template="$C_DAE_initial_dependent_parameter_assignments$",
            generatedCode="
    JMI_RECORD_STATIC(R_0_r, tmp_1)
    JMI_RECORD_STATIC(R_0_r, tmp_2)
    _p2_1 = (3 * (_p1_0*sf(0)))/sf(2);
    _r2_x_2 = ((_r_x_3*sf(1)))/sf(3);
    _p3_4 = (func_CCodeGenTests_DependentParametersWithScalingTest1_F_exp0((_p2_1*sf(2))))/sf(4);
    tmp_2->x = (_r2_x_2*sf(3));
    func_CCodeGenTests_DependentParametersWithScalingTest1_FR_def1(tmp_2, tmp_1);
    _temp_1_x_5 = (tmp_1->x)/sf(5);
    _r3_x_6 = ((_temp_1_x_5*sf(5)))/sf(6);
")})));
end DependentParametersWithScalingTest1;

model WhenTest1
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true); 
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when {x > 2} then 
z = false; 
end when; 
when (time>1 and time<1.1) or  (time>2 and time<2.1) or  (time>3 and time<3.1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="WhenTest1",
			description="Test of code generation of when clauses.",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_ode_guards$
                   $C_ode_derivatives$ 
                   $C_ode_initialization$
",
			generatedCode="

                       model_ode_guards(jmi);
/************* ODE section *********/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_time - (1), _sw(2), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_time - (1.1), _sw(3), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(4) = jmi_turn_switch(_time - (2), _sw(4), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(5) = jmi_turn_switch(_time - (2.1), _sw(5), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(6) = jmi_turn_switch(_time - (3), _sw(6), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(7) = jmi_turn_switch(_time - (3.1), _sw(7), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_4_9 = LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(2), _sw(3)), LOG_EXP_AND(_sw(4), _sw(5))), LOG_EXP_AND(_sw(6), _sw(7)));
    _x_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_4_9, LOG_EXP_NOT(pre_temp_4_9)), JMI_TRUE, pre_x_1 + AD_WRAP_LITERAL(1.1), pre_x_1);
    _der_xx_19 = - _x_1;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _y_2 = COND_EXP_EQ(LOG_EXP_AND(_temp_4_9, LOG_EXP_NOT(pre_temp_4_9)), JMI_TRUE, pre_y_2 + AD_WRAP_LITERAL(1.1), pre_y_2);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_y_2 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_6 = LOG_EXP_AND(_sw(0), pre_z_5);
    _w_3 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_6, LOG_EXP_NOT(pre_temp_1_6)), JMI_TRUE, JMI_FALSE, pre_w_3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_1 - (2), _sw(1), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_3_8 = _sw(1);
    _z_5 = COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, JMI_FALSE, pre_z_5);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_y_2 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_2_7 = LOG_EXP_AND(_sw(0), _z_5);
    _v_4 = COND_EXP_EQ(LOG_EXP_AND(_temp_2_7, LOG_EXP_NOT(pre_temp_2_7)), JMI_TRUE, JMI_FALSE, pre_v_4);
/********* Write back reinits *******/
 
                       model_ode_guards(jmi);
    pre_x_1 = 0.0;
    _x_1 = pre_x_1;
    _der_xx_19 = - _x_1;
    pre_y_2 = 0.0;
    _y_2 = pre_y_2;
    pre_z_5 = JMI_TRUE;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_y_2 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_6 = LOG_EXP_AND(_sw(0), pre_z_5);
    _z_5 = pre_z_5;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_y_2 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_2_7 = LOG_EXP_AND(_sw(0), _z_5);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_1 - (2), _sw(1), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_3_8 = _sw(1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_time - (1), _sw(2), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_time - (1.1), _sw(3), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(4) = jmi_turn_switch(_time - (2), _sw(4), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(5) = jmi_turn_switch(_time - (2.1), _sw(5), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(6) = jmi_turn_switch(_time - (3), _sw(6), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(7) = jmi_turn_switch(_time - (3.1), _sw(7), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_4_9 = LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_sw(2), _sw(3)), LOG_EXP_AND(_sw(4), _sw(5))), LOG_EXP_AND(_sw(6), _sw(7)));
    pre_w_3 = JMI_TRUE;
    _w_3 = pre_w_3;
    pre_v_4 = JMI_TRUE;
    _v_4 = pre_v_4;
    _xx_0 = 2;
    pre_temp_1_6 = JMI_FALSE;
    pre_temp_2_7 = JMI_FALSE;
    pre_temp_3_8 = JMI_FALSE;
    pre_temp_4_9 = JMI_FALSE;

")})));
end WhenTest1;

model WhenTest2 

 Real x,ref;
 discrete Real I;
 discrete Real u;

 parameter Real K = 1;
 parameter Real Ti = 1;
 parameter Real h = 0.1;

equation
 der(x) = -x + u;
 when sample(0,h) then
   I = pre(I) + h*(ref-x);
   u = K*(ref-x) + 1/Ti*I;
 end when;
 ref = if time <1 then 0 else 1;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="WhenTest2",
			equation_sorting=true,
			description="Test that samplers are not duplicated in the function tha computes the next time event.",
			generate_ode=true,
			variability_propagation=false,
			template="
$C_ode_guards$
                   $C_ode_time_events$" ,
         generatedCode="
  jmi_real_t nextTimeEvent;
  jmi_real_t nextTimeEventTmp;
  jmi_real_t nSamp;
  nextTimeEvent = JMI_INF;
  nextTimeEventTmp = JMI_INF;
  if (SURELY_LT_ZERO(_t - (AD_WRAP_LITERAL(0)))) {
    nextTimeEventTmp = AD_WRAP_LITERAL(0);
  }  else if (ALMOST_ZERO(jmi_dremainder(_t - (AD_WRAP_LITERAL(0)), _h_6))) {
    nSamp = jmi_dround((_t - (AD_WRAP_LITERAL(0))) / (_h_6));
    nextTimeEventTmp = (nSamp + 1.0) * (_h_6) + (AD_WRAP_LITERAL(0));
  }  else if (SURELY_GT_ZERO(jmi_dremainder(_t - (AD_WRAP_LITERAL(0)), _h_6))) {
    nSamp = floor((_t - (AD_WRAP_LITERAL(0))) / (_h_6));
    nextTimeEventTmp = (nSamp + 1.0) * (_h_6) + (AD_WRAP_LITERAL(0));
  }
   if (nextTimeEventTmp<nextTimeEvent) {
    nextTimeEvent = nextTimeEventTmp;
  }
  *nextTime = nextTimeEvent;
")})));
end WhenTest2; 

model WhenTest3 

 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when sample(0,2/3) then
   y = pre(y) + 1;
 end when;


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="WhenTest3",
			description="Test code generation of samplers",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_ode_time_events$ 
                   $C_ode_derivatives$ 
                   $C_ode_initialization$
",
			generatedCode="
  jmi_real_t nextTimeEvent;
  jmi_real_t nextTimeEventTmp;
  jmi_real_t nSamp;
  nextTimeEvent = JMI_INF;
  nextTimeEventTmp = JMI_INF;
  if (SURELY_LT_ZERO(_t - (AD_WRAP_LITERAL(0)))) {
    nextTimeEventTmp = AD_WRAP_LITERAL(0);
  }  else if (ALMOST_ZERO(jmi_dremainder(_t - (AD_WRAP_LITERAL(0)), jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\")))) {
    nSamp = jmi_dround((_t - (AD_WRAP_LITERAL(0))) / (jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\")));
    nextTimeEventTmp = (nSamp + 1.0) * (jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\")) + (AD_WRAP_LITERAL(0));
  }  else if (SURELY_GT_ZERO(jmi_dremainder(_t - (AD_WRAP_LITERAL(0)), jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\")))) {
    nSamp = floor((_t - (AD_WRAP_LITERAL(0))) / (jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\")));
    nextTimeEventTmp = (nSamp + 1.0) * (jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\")) + (AD_WRAP_LITERAL(0));
  }
   if (nextTimeEventTmp<nextTimeEvent) {
    nextTimeEvent = nextTimeEventTmp;
  }
  nextTimeEventTmp = JMI_INF;
  if (SURELY_LT_ZERO(_t - (AD_WRAP_LITERAL(0)))) {
    nextTimeEventTmp = AD_WRAP_LITERAL(0);
  }  else if (ALMOST_ZERO(jmi_dremainder(_t - (AD_WRAP_LITERAL(0)), jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\")))) {
    nSamp = jmi_dround((_t - (AD_WRAP_LITERAL(0))) / (jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\")));
    nextTimeEventTmp = (nSamp + 1.0) * (jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\")) + (AD_WRAP_LITERAL(0));
  }  else if (SURELY_GT_ZERO(jmi_dremainder(_t - (AD_WRAP_LITERAL(0)), jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\")))) {
    nSamp = floor((_t - (AD_WRAP_LITERAL(0))) / (jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\")));
    nextTimeEventTmp = (nSamp + 1.0) * (jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\")) + (AD_WRAP_LITERAL(0));
  }
   if (nextTimeEventTmp<nextTimeEvent) {
    nextTimeEvent = nextTimeEventTmp;
  }
  *nextTime = nextTimeEvent;
 
                       model_ode_guards(jmi);
/************* ODE section *********/
    _der_dummy_9 = 0;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _temp_1_3 = jmi_sample(jmi,AD_WRAP_LITERAL(0),jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\"));
    _x_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3)), JMI_TRUE, pre_x_0 + AD_WRAP_LITERAL(1), pre_x_0);
    _temp_2_4 = jmi_sample(jmi,AD_WRAP_LITERAL(0),jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\"));
    _y_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_2_4, LOG_EXP_NOT(pre_temp_2_4)), JMI_TRUE, pre_y_1 + AD_WRAP_LITERAL(1), pre_y_1);
/********* Write back reinits *******/
 
                       model_ode_guards(jmi);
    _der_dummy_9 = 0;
    _temp_1_3 = jmi_sample(jmi,AD_WRAP_LITERAL(0),jmi_divide_equation(jmi, AD_WRAP_LITERAL(1),AD_WRAP_LITERAL(3),\"1 / 3\"));
    _temp_2_4 = jmi_sample(jmi,AD_WRAP_LITERAL(0),jmi_divide_equation(jmi, AD_WRAP_LITERAL(2),AD_WRAP_LITERAL(3),\"2 / 3\"));
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_y_1 = 0.0;
    _y_1 = pre_y_1;
    _dummy_2 = 0.0;
    pre_temp_1_3 = JMI_FALSE;
    pre_temp_2_4 = JMI_FALSE;

")})));
end WhenTest3; 

model WhenEqu4
 discrete Boolean sampleTrigger;
 Real x_p(start=1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
initial equation
 x_c = pre(x_c); 	
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {initial(),sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu4",
            description="Test code generation of samplers",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=false,
            variability_propagation=false,
            template="
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = pre_x_c_3;
        x[1] = _x_c_3;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = - _a_c_8;
        residual[1] = - 1.0;
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            pre_x_c_3 = x[0];
            _x_c_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a_c_8 * pre_x_c_3 + _b_c_9 * _u_c_4 - (_x_c_3);
            (*res)[1] = pre_x_c_3 - (_x_c_3);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
    _sampleTrigger_0 = jmi_sample(jmi,AD_WRAP_LITERAL(0),_h_11);
    _u_c_4 = COND_EXP_EQ(LOG_EXP_OR(_atInitial, LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _c_p_7 * _x_p_1, pre_u_c_4);
    _x_c_3 = COND_EXP_EQ(LOG_EXP_OR(_atInitial, LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _a_c_8 * pre_x_c_3 + _b_c_9 * _u_c_4, pre_x_c_3);
    _u_p_2 = _c_c_10 * _x_c_3;
    _der_x_p_15 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
/********* Write back reinits *******/

    model_ode_guards(jmi);
    _x_p_1 = 1;
    _u_c_4 = _c_p_7 * _x_p_1;
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    _u_p_2 = _c_c_10 * _x_c_3;
    _der_x_p_15 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
    _sampleTrigger_0 = jmi_sample(jmi,AD_WRAP_LITERAL(0),_h_11);
    pre_sampleTrigger_0 = JMI_FALSE;
    pre_u_c_4 = 0.0;
")})));
end WhenEqu4;

model WhenEqu5
 discrete Boolean sampleTrigger;
 Real x_p(start=1, fixed=true);
 Real u_p;
 discrete Real x_c;
 discrete Real u_c;
 parameter Real a_p = -1;
 parameter Real b_p = 1;
 parameter Real c_p = 1;
 parameter Real a_c = 0.8;
 parameter Real b_c = 1;
 parameter Real c_c = 1;
 parameter Real h = 0.1;
 discrete Boolean atInit = true and initial();
initial equation
 x_c = pre(x_c); 	
equation
 der(x_p) = a_p*x_p + b_p*u_p;
 u_p = c_c*x_c;
 sampleTrigger = sample(0,h);
 when {atInit,sampleTrigger} then
   u_c = c_p*x_p;
   x_c = a_c*pre(x_c) + b_c*u_c;
 end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu5",
            description="Test code generation of samplers",
            generate_ode=true,
            automatic_tearing=false,
            equation_sorting=true,
            variability_propagation=false,
            template="
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = pre_x_c_3;
        x[1] = _x_c_3;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = - 1.0;
        residual[1] = - 1.0;
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            pre_x_c_3 = x[0];
            _x_c_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = pre_x_c_3 - (_x_c_3);
            (*res)[1] = pre_x_c_3 - (_x_c_3);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
    _atInit_12 = LOG_EXP_AND(JMI_TRUE, _atInitial);
    _sampleTrigger_0 = jmi_sample(jmi,AD_WRAP_LITERAL(0),_h_11);
    _u_c_4 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_AND(_atInit_12, LOG_EXP_NOT(pre_atInit_12)), LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _c_p_7 * _x_p_1, pre_u_c_4);
    _x_c_3 = COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_AND(_atInit_12, LOG_EXP_NOT(pre_atInit_12)), LOG_EXP_AND(_sampleTrigger_0, LOG_EXP_NOT(pre_sampleTrigger_0))), JMI_TRUE, _a_c_8 * pre_x_c_3 + _b_c_9 * _u_c_4, pre_x_c_3);
    _u_p_2 = _c_c_10 * _x_c_3;
    _der_x_p_17 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
/********* Write back reinits *******/

    model_ode_guards(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    _u_p_2 = _c_c_10 * _x_c_3;
    _x_p_1 = 1;
    _der_x_p_17 = _a_p_5 * _x_p_1 + _b_p_6 * _u_p_2;
    _sampleTrigger_0 = jmi_sample(jmi,AD_WRAP_LITERAL(0),_h_11);
    _atInit_12 = LOG_EXP_AND(JMI_TRUE, _atInitial);
    pre_u_c_4 = 0.0;
    _u_c_4 = pre_u_c_4;
    pre_sampleTrigger_0 = JMI_FALSE;
    pre_atInit_12 = JMI_FALSE;
")})));
end WhenEqu5;

model WhenEqu6
	function F
		input Real x;
		output Real y1;
		output Real y2;
	algorithm
		y1 := 1;
		y2 := 2;
	end F;
	Real x,y;
	equation
	when sample(0,1) then
		(x,y) = F(time);
	end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu6",
            description="Test code generation when equations with function calls.",
            generate_ode=true,
            inline_functions="none",
            equation_sorting=true,
            variability_propagation=false,
            template="
$C_dae_blocks_residual_functions$
                   $C_ode_derivatives$ 
                   $C_ode_initialization$
",
            generatedCode="

                       jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _temp_1_2 = jmi_sample(jmi,AD_WRAP_LITERAL(0),AD_WRAP_LITERAL(1));
    if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
        func_CCodeGenTests_WhenEqu6_F_def0(_time, &tmp_1, &tmp_2);
        _x_0 = (tmp_1);
        _y_1 = (tmp_2);
    } else {
        _x_0 = pre_x_0;
        _y_1 = pre_y_1;
    }
/********* Write back reinits *******/
 
                       model_ode_guards(jmi);
    _temp_1_2 = jmi_sample(jmi,AD_WRAP_LITERAL(0),AD_WRAP_LITERAL(1));
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_y_1 = 0.0;
    _y_1 = pre_y_1;
    pre_temp_1_2 = JMI_FALSE;
")})));
end WhenEqu6;

model WhenEqu7
 discrete Real x;
 Real y1,y2;
 Real z1,z2,z3;
equation
 when time > 3 then
  x = sin(x) +3;
 end when;
 
  y1 + y2 = 5;
  when time > 3 then 
    y1 = 7 - 2*y2;
  end when;
  
  z1 + z2 + z3 = 5;
  when time > 3 then 
    z1 = 7 - 2*z2;
    z3 = 7 - 2*z2;
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu7",
            description="Test code generation unsolved when equations",
            generate_ode=true,
            automatic_tearing=false,
            equation_sorting=true,
            variability_propagation=false,
            template="
$C_ode_derivatives$ 
                   $C_ode_initialization$
                   $C_dae_blocks_residual_functions$
                   $C_dae_init_blocks_residual_functions$
",
            generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (3), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_6 = _sw(0);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (3), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_2_7 = _sw(0);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (3), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_3_8 = _sw(0);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[2]);
/********* Write back reinits *******/

                       model_ode_guards(jmi);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (3), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_6 = _sw(0);
    pre_y1_1 = 0.0;
    _y1_1 = pre_y1_1;
    _y2_2 = - _y1_1 + 5;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (3), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_2_7 = _sw(0);
    pre_z1_3 = 0.0;
    _z1_3 = pre_z1_3;
    pre_z3_5 = 0.0;
    _z3_5 = pre_z3_5;
    _z2_4 = - _z1_3 + (- _z3_5) + 5;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (3), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_3_8 = _sw(0);
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_temp_1_6 = JMI_FALSE;
    pre_temp_2_7 = JMI_FALSE;
    pre_temp_3_8 = JMI_FALSE;

                   static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_1_6, LOG_EXP_NOT(pre_temp_1_6)), JMI_TRUE, sin(_x_0) + AD_WRAP_LITERAL(3), pre_x_0) - (_x_0);
        }
    }
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y1_1;
        x[1] = _y2_2;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[1] = 1.0;
        residual[2] = - COND_EXP_EQ(LOG_EXP_AND(_temp_2_7, LOG_EXP_NOT(pre_temp_2_7)), JMI_TRUE, AD_WRAP_LITERAL(-2), AD_WRAP_LITERAL(0.0));
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y1_1 = x[0];
            _y2_2 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_2_7, LOG_EXP_NOT(pre_temp_2_7)), JMI_TRUE, AD_WRAP_LITERAL(7) - AD_WRAP_LITERAL(2) * _y2_2, pre_y1_1) - (_y1_1);
            (*res)[1] = 5 - (_y1_1 + _y2_2);
        }
    }
    return ef;
}

static int dae_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 3 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z3_5;
        x[1] = _z1_3;
        x[2] = _z2_4;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        residual[2] = 1.0;
        residual[4] = 1.0;
        residual[5] = 1.0;
        residual[6] = - COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, AD_WRAP_LITERAL(-2), AD_WRAP_LITERAL(0.0));
        residual[7] = - COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, AD_WRAP_LITERAL(-2), AD_WRAP_LITERAL(0.0));
        residual[8] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z3_5 = x[0];
            _z1_3 = x[1];
            _z2_4 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, AD_WRAP_LITERAL(7) - AD_WRAP_LITERAL(2) * _z2_4, pre_z3_5) - (_z3_5);
            (*res)[1] = COND_EXP_EQ(LOG_EXP_AND(_temp_3_8, LOG_EXP_NOT(pre_temp_3_8)), JMI_TRUE, AD_WRAP_LITERAL(7) - AD_WRAP_LITERAL(2) * _z2_4, pre_z1_3) - (_z1_3);
            (*res)[2] = 5 - (_z1_3 + _z2_4 + _z3_5);
        }
    }
    return ef;
}


                   
")})));
end WhenEqu7;

model WhenEqu8
	
function f
	input Real x;
	input Real y;
	output Real a;
	output Real b;
 algorithm
	 a := y;
	 b := x;
end f;

 discrete Real x,y;
 Real a,b;
equation
	a = time;
	b = time*2;
  when {initial(), time > 1} then
    (x,y) = f(a,b);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu8",
            description="Test code generation unsolved when equations",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            inline_functions="none",
            template="
$C_ode_derivatives$ 
                   $C_ode_initialization$
                   $C_dae_blocks_residual_functions$
                   $C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _a_2 = _time;
    _b_3 = _time * 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_4 = _sw(0);
    if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4)))) {
        func_CCodeGenTests_WhenEqu8_f_def0(_a_2, _b_3, &tmp_1, &tmp_2);
        _x_0 = (tmp_1);
        _y_1 = (tmp_2);
    } else {
        _x_0 = pre_x_0;
        _y_1 = pre_y_1;
    }
/********* Write back reinits *******/
 
                       jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    model_ode_guards(jmi);
    _a_2 = _time;
    _b_3 = _time * 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_4 = _sw(0);
    func_CCodeGenTests_WhenEqu8_f_def0(_a_2, _b_3, &tmp_3, &tmp_4);
    _x_0 = (tmp_3);
    _y_1 = (tmp_4);
    pre_x_0 = 0.0;
    pre_y_1 = 0.0;
    pre_temp_1_4 = JMI_FALSE;

                   
                   
")})));
end WhenEqu8;

model WhenEqu9
	
function f
	input Real x;
	input Real y;
	output Real a;
	output Real b;
 algorithm
	 a := y;
	 b := x;
end f;

 discrete Real x,y;
 Real a,b;
equation
  a = time;
  b = time*x;
  when time > 2 then
    (x,y) = f(a,b);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu9",
            description="Test code generation unsolved when equations",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_3;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_3 = x[0];
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            func_CCodeGenTests_WhenEqu9_f_def0(_a_2, _b_3, &tmp_1, &tmp_2);
            _y_1 = (tmp_2);
        } else {
            _y_1 = pre_y_1;
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            _x_0 = (tmp_1);
        } else {
            _x_0 = pre_x_0;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _time * _x_0 - (_b_3);
        }
    }
    return ef;
}

")})));
end WhenEqu9;

model WhenEqu10
	
function f
	input Real x;
	input Real y;
	output Real a;
	output Real b;
 algorithm
	 a := y;
	 b := x;
end f;

 discrete Real x,y;
 Real a,b;
equation
  when time > 2 then
    (a,b) = f(x,y);
  end when;
  when {initial(), time > 2} then
    (x,y) = f(a,b);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenEqu10",
            description="Test code generation unsolved when equations",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            inline_functions="none",
            template="
$C_dae_blocks_residual_functions$
                   $C_dae_init_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            func_CCodeGenTests_WhenEqu10_f_def0(_x_0, _y_1, &tmp_1, &tmp_2);
            _b_3 = (tmp_2);
        } else {
            _b_3 = pre_b_3;
        }
        if (LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4))) {
            _a_2 = (tmp_1);
        } else {
            _a_2 = pre_a_2;
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5)))) {
                func_CCodeGenTests_WhenEqu10_f_def0(_a_2, _b_3, &tmp_3, &tmp_4);
                (*res)[0] = tmp_4 - (_y_1);
            } else {
                (*res)[0] = pre_y_1 - (_y_1);
            }
            if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_2_5, LOG_EXP_NOT(pre_temp_2_5)))) {
                (*res)[1] = tmp_3 - (_x_0);
            } else {
                (*res)[1] = pre_x_0 - (_x_0);
            }
        }
    }
    return ef;
}


                   
")})));
end WhenEqu10;

model WhenTest11
    Real x = time;
    discrete Real z;
equation
    when time >= 2 then
        z = pre(x);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="WhenTest11",
			description="Code generation for use of pre on continuous variable",
			equation_sorting=true,
			generate_ode=true,
			template="$C_ode_derivatives$",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (2), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_1_2 = _sw(0);
    _z_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, pre_x_0, pre_z_1);
/********* Write back reinits *******/
")})));
end WhenTest11; 



function dummyFunc
	input Real i;
	output Real x = i;
	output Real y = i;
	algorithm
end dummyFunc;

model IfEqu1

    Real x,y;
equation
    if time >= 2 then
        (x,y) = dummyFunc(time*time*time/2);
    elseif time >= 1 then
        (x,y) = dummyFunc(time*time);
    else
        (x,y) = dummyFunc(time);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu1",
            description="Code generation for if equation",
            variability_propagation=false,
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_6;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (_sw(0)) {
        func_CCodeGenTests_dummyFunc_def0(jmi_divide_equation(jmi, _time * _time * _time,AD_WRAP_LITERAL(2),\"time * time * time / 2\"), &tmp_1, &tmp_2);
        _x_0 = (tmp_1);
        _y_1 = (tmp_2);
    } else {
        if (_sw(1)) {
            func_CCodeGenTests_dummyFunc_def0(_time * _time, &tmp_3, &tmp_4);
            _x_0 = (tmp_3);
            _y_1 = (tmp_4);
        } else {
            func_CCodeGenTests_dummyFunc_def0(_time, &tmp_5, &tmp_6);
            _x_0 = (tmp_5);
            _y_1 = (tmp_6);
        }
    }
/********* Write back reinits *******/
")})));
end IfEqu1;

model IfEqu2
    Real x,y,t;
equation
    t = time;
    if time >= 1 then
        (x,t) = dummyFunc(y);
    else
        (x,t) = dummyFunc(y);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu2",
            description="Code generation for if equation, numerically solved",
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        if (_sw(0)) {
            func_CCodeGenTests_dummyFunc_def0(_y_1, &tmp_1, &tmp_2);
            _x_0 = (tmp_1);
        } else {
            func_CCodeGenTests_dummyFunc_def0(_y_1, &tmp_3, &tmp_4);
            _x_0 = (tmp_3);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                (*res)[0] = tmp_2 - (_t_2);
            } else {
                (*res)[0] = tmp_4 - (_t_2);
            }
        }
    }
    return ef;
}

")})));
end IfEqu2;

model IfEqu3
    Real x,y,a,b;
equation
    if time >= 1 then
        (x,y) = dummyFunc(a);
    else
        (x,y) = dummyFunc(b);
    end if;
    if time >= 1 then
        (a,b) = dummyFunc(x);
    else
        (a,b) = dummyFunc(y);
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu3",
            description="Code generation for if equation, in block",
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_6;
    jmi_ad_var_t tmp_7;
    jmi_ad_var_t tmp_8;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_3;
        x[1] = _a_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_3 = x[0];
            _a_2 = x[1];
        }
        if (_sw(0)) {
            func_CCodeGenTests_dummyFunc_def0(_a_2, &tmp_1, &tmp_2);
            _y_1 = (tmp_2);
        } else {
            func_CCodeGenTests_dummyFunc_def0(_b_3, &tmp_3, &tmp_4);
            _y_1 = (tmp_4);
        }
        if (_sw(0)) {
            _x_0 = (tmp_1);
        } else {
            _x_0 = (tmp_3);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                func_CCodeGenTests_dummyFunc_def0(_x_0, &tmp_5, &tmp_6);
                (*res)[0] = tmp_6 - (_b_3);
            } else {
                func_CCodeGenTests_dummyFunc_def0(_y_1, &tmp_7, &tmp_8);
                (*res)[0] = tmp_8 - (_b_3);
            }
            if (_sw(0)) {
                (*res)[1] = tmp_5 - (_a_2);
            } else {
                (*res)[1] = tmp_7 - (_a_2);
            }
        }
    }
    return ef;
}

")})));
end IfEqu3;

model IfEqu4
function f
	input Real[:] i;
	output Real[size(i,1)] x = i;
	output Real[size(i,1)] y = i;
	algorithm
end f;
    Real[2] x,y;
equation
    if time >= 1 then
        (x,y) = f({time,time});
    else
        (x[1:end],y[{2,1}]) = f({time,time});
    end if;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu4",
            description="Code generation for if equation, temp vars",
            variability_propagation=false,
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_5, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_6, 2, 1)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (_sw(0)) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_ref_1(tmp_3, 1) = _time;
        jmi_array_ref_1(tmp_3, 2) = _time;
        func_CCodeGenTests_IfEqu4_f_def0(tmp_3, tmp_1, tmp_2);
        _x_1_0 = (jmi_array_val_1(tmp_1, 1));
        _x_2_1 = (jmi_array_val_1(tmp_1, 2));
        _y_1_2 = (jmi_array_val_1(tmp_2, 1));
        _y_2_3 = (jmi_array_val_1(tmp_2, 2));
    } else {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 2, 1, 2)
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_5, 2, 1, 2)
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_6, 2, 1, 2)
        jmi_array_ref_1(tmp_6, 1) = _time;
        jmi_array_ref_1(tmp_6, 2) = _time;
        func_CCodeGenTests_IfEqu4_f_def0(tmp_6, tmp_4, tmp_5);
        _x_1_0 = (jmi_array_val_1(tmp_4, 1));
        _x_2_1 = (jmi_array_val_1(tmp_4, 2));
        _y_2_3 = (jmi_array_val_1(tmp_5, 1));
        _y_1_2 = (jmi_array_val_1(tmp_5, 2));
    }
/********* Write back reinits *******/
")})));
end IfEqu4;

model IfEqu5
    Real x;
    parameter Real y(fixed=false,start=3);
initial equation
    if time >= 1 then
        (x,) = dummyFunc(1);
    else
        (x,) = dummyFunc(2);
    end if;
equation
    when time > 1 then
		x = 1;
	end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IfEqu5",
            description="Code generation for if equation, initial equation",
            variability_propagation=false,
            inline_functions="none",
            template="$C_ode_initialization$",
            generatedCode="
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    model_ode_guards(jmi);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    if (_sw_init(0)) {
        func_CCodeGenTests_dummyFunc_def0(AD_WRAP_LITERAL(1), &tmp_1, NULL);
        _x_0 = (tmp_1);
    } else {
        func_CCodeGenTests_dummyFunc_def0(AD_WRAP_LITERAL(2), &tmp_2, NULL);
        _x_0 = (tmp_2);
    }
    pre_x_0 = _x_0;
    pre_temp_1_2 = JMI_FALSE;
    _y_1 = 3;
")})));
end IfEqu5;



model ReinitCTest1
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ReinitCTest1",
			description="",
			variability_propagation=false,
			template="
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
			generatedCode="
    jmi_ad_var_t tmp_1;
    model_ode_guards(jmi);
/************* ODE section *********/
    _der_x_3 = 1;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
        tmp_1 = AD_WRAP_LITERAL(1);
    }
/********* Write back reinits *******/
    if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
        _x_0 = tmp_1;
        jmi->reinit_triggered = 1;
    }

-----
    model_ode_guards(jmi);
    _der_x_3 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    pre_temp_1_1 = JMI_FALSE;

-----

-----
")})));
end ReinitCTest1;


model ReinitCTest2
    Real x,y;
equation
    der(x) = 1;
	der(y) = 2;
    when y > 2 then
        reinit(x, 1);
    end when;
    when x > 2 then
        reinit(y, 1);
    end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ReinitCTest2",
			description="",
			variability_propagation=false,
			template="
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
			generatedCode="
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    model_ode_guards(jmi);
/************* ODE section *********/
    _der_x_6 = 1;
    _der_y_7 = 2;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_y_1 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_0 - (2), _sw(1), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_2_3 = _sw(1);
    if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
        tmp_1 = AD_WRAP_LITERAL(1);
    }
    if (LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))) {
        tmp_2 = AD_WRAP_LITERAL(1);
    }
/********* Write back reinits *******/
    if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
        _x_0 = tmp_1;
        jmi->reinit_triggered = 1;
    }
    if (LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))) {
        _y_1 = tmp_2;
        jmi->reinit_triggered = 1;
    }

-----
    model_ode_guards(jmi);
    _der_x_6 = 1;
    _der_y_7 = 2;
    _y_1 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_y_1 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    _x_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_0 - (2), _sw(1), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_2_3 = _sw(1);
    pre_temp_1_2 = JMI_FALSE;
    pre_temp_2_3 = JMI_FALSE;
-----

-----
")})));
end ReinitCTest2;


// This requires conversion of all when clauses to if clauses (or other elsewhen support), see #3199
model ReinitCTest3
    Real x;
equation
    der(x) = 1;
    when time > 2 then
        reinit(x, 1);
    elsewhen time > 1 then
        reinit(y, 1);
    end when;
end ReinitCTest3;



model NoDAEGenerationTest1
  Real x, y, z;
  parameter Real p = 1;
  parameter Real p2 = p;
equation
  z = x + y;
  3 = x - y;
  5 = x + 3*y;  


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="NoDAEGenerationTest1",
			description="Test that no DAE is generated if the corresponding option is set to false.",
			generate_dae=false,
			variability_propagation=false,
			template="
$C_DAE_equation_residuals$
                   $C_DAE_initial_equation_residuals$
                   $C_DAE_initial_dependent_parameter_residuals$
",
         generatedCode=" 
")})));
end NoDAEGenerationTest1;

model BlockTest1
  Real x, y, z;
equation
  z = x + y;
  3 = x - y;
  5 = x + 3*y;  

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest1",
            description="Test code generation of systems of equations.",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            automatic_tearing=false,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = - 3;
        residual[1] = 1.0;
        residual[2] = - 1.0;
        residual[3] = - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 3 * _y_1 - (5);
            (*res)[1] = _x_0 - _y_1 - (3);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = - 3;
        residual[1] = 1.0;
        residual[2] = - 1.0;
        residual[3] = - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 3 * _y_1 - (5);
            (*res)[1] = _x_0 - _y_1 - (3);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _z_2 = _x_0 + _y_1;
/********* Write back reinits *******/

    model_ode_guards(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    _z_2 = _x_0 + _y_1;
")})));
end BlockTest1;


model BlockTest2
Real x1,x2,z1,z2[2];

equation

sin(z1)*3 = z1 + 2;
{{1,2},{3,4}}*z2 = {4,5};

der(x2) = -x2 + z2[1] + z2[2];
der(x1) = -x1 + z1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest2",
            description="Test generation of equation blocks",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            automatic_tearing=false,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z2_2_4;
        x[1] = _z2_1_3;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z2_2_4 = x[0];
            _z2_1_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 5 - (3 * _z2_1_3 + 4 * _z2_2_4);
            (*res)[1] = 4 - (_z2_1_3 + 2 * _z2_2_4);
        }
    }
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z1_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z1_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z1_2 + 2 - (sin(_z1_2) * 3);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z1_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z1_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z1_2 + 2 - (sin(_z1_2) * 3);
        }
    }
    return ef;
}

static int dae_init_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z2_2_4;
        x[1] = _z2_1_3;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z2_2_4 = x[0];
            _z2_1_3 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 5 - (3 * _z2_1_3 + 4 * _z2_2_4);
            (*res)[1] = 4 - (_z2_1_3 + 2 * _z2_2_4);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    _der_x2_5 = - _x2_1 + _z2_1_3 + _z2_2_4;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    _der_x1_6 = - _x1_0 + _z1_2;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
/********* Write back reinits *******/

    model_ode_guards(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[1]);
    _x2_1 = 0.0;
    _der_x2_5 = - _x2_1 + _z2_1_3 + _z2_2_4;
    _x1_0 = 0.0;
    _der_x1_6 = - _x1_0 + _z1_2;
")})));
end BlockTest2;

model BlockTest3
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor(start=false);
 Boolean startBack(start=false);
 Integer mode(start=2);
 Real dummy;
equation 
 der(dummy) = 1;
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a;
 startFor = pre(mode)==2 and sa > 1;
 startBack = pre(mode) == 2 and sa < -1;
 a = if pre(mode) == 1 or startFor then sa-1 else 
     if pre(mode) == 3 or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == 1 or startFor then 
     f0 + f1*v else 
     if pre(mode) == 3 or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == 1 or startFor)
      and v>0 then 1 else 
      if (pre(mode) == 3 or startBack)
          and v<0 then 3 else 2;


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest3",
            description="Test of code generation of blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=false,
            variability_propagation=false,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 10;
        x[2] = 8;
        x[3] = 4;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870925;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_4;
        x[1] = _sa_7;
        x[2] = _f_5;
        x[3] = _der_v_16;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 16 * sizeof(jmi_real_t));
        residual[0] = - 1.0;
        residual[1] = 1.0;
        residual[5] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(1.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(1.0), AD_WRAP_LITERAL(0)));
        residual[6] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(0.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(0.0), _f0_1));
        residual[10] = 1.0;
        residual[11] = 1.0;
        residual[12] = 1.0;
        residual[15] = _m_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_4 = x[0];
            _sa_7 = x[1];
            _f_5 = x[2];
            _der_v_16 = x[3];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(_sa_7 - (- 1), _sw(1), jmi->events_epsilon, JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_sa_7 - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a_4 - (_der_v_16);
            (*res)[1] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - AD_WRAP_LITERAL(1), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(0))) - (_a_4);
            (*res)[2] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7)) - (_f_5);
            (*res)[3] = _u_6 - _f_5 - (_m_0 * _der_v_16);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 7;
        x[1] = 10;
        x[2] = 8;
        x[3] = 4;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870925;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_4;
        x[1] = _sa_7;
        x[2] = _f_5;
        x[3] = _der_v_16;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 16 * sizeof(jmi_real_t));
        residual[0] = - 1.0;
        residual[1] = 1.0;
        residual[5] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(1.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(1.0), AD_WRAP_LITERAL(0)));
        residual[6] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(0.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(0.0), _f0_1));
        residual[10] = 1.0;
        residual[11] = 1.0;
        residual[12] = 1.0;
        residual[15] = _m_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_4 = x[0];
            _sa_7 = x[1];
            _f_5 = x[2];
            _der_v_16 = x[3];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(_sa_7 - (- 1), _sw(1), jmi->events_epsilon, JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_sa_7 - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _a_4 - (_der_v_16);
            (*res)[1] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - AD_WRAP_LITERAL(1), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(0))) - (_a_4);
            (*res)[2] = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7)) - (_f_5);
            (*res)[3] = _u_6 - _f_5 - (_m_0 * _der_v_16);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
    _der_dummy_15 = 1;
    _u_6 = 2 * sin(_time);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_v_3 - (AD_WRAP_LITERAL(0)), _sw(2), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_v_3 - (AD_WRAP_LITERAL(0)), _sw(3), jmi->events_epsilon, JMI_REL_LT);
    }
    _mode_10 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2)), JMI_TRUE, AD_WRAP_LITERAL(1), COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), _sw(3)), JMI_TRUE, AD_WRAP_LITERAL(3), AD_WRAP_LITERAL(2)));
/********* Write back reinits *******/

    model_ode_guards(jmi);
    _der_dummy_15 = 1;
    _u_6 = 2 * sin(_time);
    pre_mode_10 = 2;
    _v_3 = 0.0;
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_v_3 - (AD_WRAP_LITERAL(0)), _sw(2), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_v_3 - (AD_WRAP_LITERAL(0)), _sw(3), jmi->events_epsilon, JMI_REL_LT);
    }
    _mode_10 = COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), _sw(2)), JMI_TRUE, AD_WRAP_LITERAL(1), COND_EXP_EQ(LOG_EXP_AND(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), _sw(3)), JMI_TRUE, AD_WRAP_LITERAL(3), AD_WRAP_LITERAL(2)));
    _dummy_11 = 0.0;
    pre_startFor_8 = JMI_FALSE;
    pre_startBack_9 = JMI_FALSE;
")})));
end BlockTest3;

model BlockTest4
  Real x(min=3); 
  Real y(max=-2, nominal=5);
  Real z(min=4,max=5,nominal=8);
equation
  z = x + y;
  3 = x - y;
  5 = x + 3*y + z;  

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest4",
            description="Test that min, max, and nominal attributes are correctly generated",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            automatic_tearing=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        x[0] = 5;
        x[2] = 8;
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[1] = 3;
        x[2] = 4;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[0] = -2;
        x[2] = 5;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
        x[2] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        init_with_ubound(x[0], -2, \"Resetting initial value for variable y\");
        x[1] = _x_0;
        init_with_lbound(x[1], 3, \"Resetting initial value for variable x\");
        x[2] = _z_2;
        init_with_bounds(x[2], 4, 5, \"Resetting initial value for variable z\");
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = - 3;
        residual[1] = 1.0;
        residual[2] = - 1.0;
        residual[3] = - 1.0;
        residual[4] = - 1.0;
        residual[5] = - 1.0;
        residual[6] = - 1.0;
        residual[8] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            check_ubound(x[0], -2, \"Out of bounds for variable y\");
            _y_1 = x[0];
            check_lbound(x[1], 3, \"Out of bounds for variable x\");
            _x_0 = x[1];
            check_bounds(x[2], 4, 5, \"Out of bounds for variable z\");
            _z_2 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 3 * _y_1 + _z_2 - (5);
            (*res)[1] = _x_0 - _y_1 - (3);
            (*res)[2] = _x_0 + _y_1 - (_z_2);
        }
    }
    return ef;
}

")})));
end BlockTest4;

model BlockTest5
  parameter Real p1 = 4;
  Real x[2](min={1, 4*p1}); 
  Real y(max=-2, nominal=5);
  equation
  3 = x[1] - y + x[2];
  5 = x[1] + 3*y;
  3 = x[1] + y + x[2];  



    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest5",
            description="Test of min and max for iteration varaibles.",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=false,
            variability_propagation=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[0] = 16.0;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[1] = -2;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 3;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_2;
        init_with_lbound(x[0], 16.0, \"Resetting initial value for variable x[2]\");
        x[1] = _y_3;
        init_with_ubound(x[1], -2, \"Resetting initial value for variable y\");
        x[2] = _x_1_1;
        init_with_lbound(x[2], 1, \"Resetting initial value for variable x[1]\");
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = - 1.0;
        residual[2] = - 1.0;
        residual[3] = - 1.0;
        residual[4] = - 3;
        residual[5] = 1.0;
        residual[6] = - 1.0;
        residual[7] = - 1.0;
        residual[8] = - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            check_lbound(x[0], 16.0, \"Out of bounds for variable x[2]\");
            _x_2_2 = x[0];
            check_ubound(x[1], -2, \"Out of bounds for variable y\");
            _y_3 = x[1];
            check_lbound(x[2], 1, \"Out of bounds for variable x[1]\");
            _x_1_1 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_1 + _y_3 + _x_2_2 - (3);
            (*res)[1] = _x_1_1 + 3 * _y_3 - (5);
            (*res)[2] = _x_1_1 - _y_3 + _x_2_2 - (3);
        }
    }
    return ef;
}

")})));
end BlockTest5;

model BlockTest6
  function f1
    input Real x;
	output Real y=0;
  algorithm
	  for i in 1:3 loop
		  y := y + x;
	  end for;
  end f1;

  function f2
	input Real x;
	input Integer n;
	output Real y[2]={0,0};
  algorithm
	  for i in 1:n loop
		  y := {y[1] + x, y[2] + 2*x};
	  end for;
  end f2;
  
  parameter Real p1 = 4;
  Real x[2](min=f2(3,2)); 
  Real y(max=-f1(2), nominal=5);
  equation
  3 = x[1] - y + x[2];
  5 = x[1] + 3*y;
  3 = x[1] + y + x[2];  

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest6",
            description="Test of min, max and nominal attributes in blocks",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            automatic_tearing=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[0] = 12.0;
        x[2] = 6.0;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[1] = -6.0;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
        x[1] = 5;
        x[2] = 3;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_2;
        init_with_lbound(x[0], 12.0, \"Resetting initial value for variable x[2]\");
        x[1] = _y_3;
        init_with_ubound(x[1], -6.0, \"Resetting initial value for variable y\");
        x[2] = _x_1_1;
        init_with_lbound(x[2], 6.0, \"Resetting initial value for variable x[1]\");
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 9 * sizeof(jmi_real_t));
        residual[0] = - 1.0;
        residual[2] = - 1.0;
        residual[3] = - 1.0;
        residual[4] = - 3;
        residual[5] = 1.0;
        residual[6] = - 1.0;
        residual[7] = - 1.0;
        residual[8] = - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            check_lbound(x[0], 12.0, \"Out of bounds for variable x[2]\");
            _x_2_2 = x[0];
            check_ubound(x[1], -6.0, \"Out of bounds for variable y\");
            _y_3 = x[1];
            check_lbound(x[2], 6.0, \"Out of bounds for variable x[1]\");
            _x_1_1 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_1_1 + _y_3 + _x_2_2 - (3);
            (*res)[1] = _x_1_1 + 3 * _y_3 - (5);
            (*res)[2] = _x_1_1 - _y_3 + _x_2_2 - (3);
        }
    }
    return ef;
}

")})));
end BlockTest6;

model BlockTest7
    parameter Real A[2,2] = 2*{{1,2},{3,4}};
    Real x[2];
    Real y[2];
    Real z[2];
    Real w[2];
    parameter Real p = 2;
    discrete Real d;
equation
    when time>=1 then
 d = pre(d) + 1;
    end when;
    {{1,2},{3,4}}*x = {3,4};
    p*A*y = y;
    (d+1)*A*z = z+{2,2};
    (x[1]+1)*A*w = w+{3,3};

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest7",
            description="Test of min, max and nominal attributes in blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=false,
            variability_propagation=false,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_5;
        x[1] = _x_1_4;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2_5 = x[0];
            _x_1_4 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 4 - (3 * _x_1_4 + 4 * _x_2_5);
            (*res)[1] = 3 - (_x_1_4 + 2 * _x_2_5);
        }
    }
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 8;
        x[1] = 7;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_2_7;
        x[1] = _y_1_6;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = _p_12 * _A_2_2_3 - 1.0;
        residual[1] = _p_12 * _A_1_2_1;
        residual[2] = _p_12 * _A_2_1_2;
        residual[3] = _p_12 * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_2_7 = x[0];
            _y_1_6 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_2_7 - (_p_12 * _A_2_1_2 * _y_1_6 + _p_12 * _A_2_2_3 * _y_2_7);
            (*res)[1] = _y_1_6 - (_p_12 * _A_1_1_0 * _y_1_6 + _p_12 * _A_1_2_1 * _y_2_7);
        }
    }
    return ef;
}

static int dae_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 3 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
        x[1] = 9;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z_2_9;
        x[1] = _z_1_8;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_d_13 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_d_13 + 1) * _A_1_2_1;
        residual[2] = (_d_13 + 1) * _A_2_1_2;
        residual[3] = (_d_13 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z_2_9 = x[0];
            _z_1_8 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z_2_9 + 2 - ((_d_13 + 1) * _A_2_1_2 * _z_1_8 + (_d_13 + 1) * _A_2_2_3 * _z_2_9);
            (*res)[1] = _z_1_8 + 2 - ((_d_13 + 1) * _A_1_1_0 * _z_1_8 + (_d_13 + 1) * _A_1_2_1 * _z_2_9);
        }
    }
    return ef;
}

static int dae_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 4 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _w_2_11;
        x[1] = _w_1_10;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_x_1_4 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_x_1_4 + 1) * _A_1_2_1;
        residual[2] = (_x_1_4 + 1) * _A_2_1_2;
        residual[3] = (_x_1_4 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _w_2_11 = x[0];
            _w_1_10 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _w_2_11 + 3 - ((_x_1_4 + 1) * _A_2_1_2 * _w_1_10 + (_x_1_4 + 1) * _A_2_2_3 * _w_2_11);
            (*res)[1] = _w_1_10 + 3 - ((_x_1_4 + 1) * _A_1_1_0 * _w_1_10 + (_x_1_4 + 1) * _A_1_2_1 * _w_2_11);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 6;
        x[1] = 5;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2_5;
        x[1] = _x_1_4;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 4;
        residual[1] = 2;
        residual[2] = 3;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2_5 = x[0];
            _x_1_4 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 4 - (3 * _x_1_4 + 4 * _x_2_5);
            (*res)[1] = 3 - (_x_1_4 + 2 * _x_2_5);
        }
    }
    return ef;
}

static int dae_init_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 8;
        x[1] = 7;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_2_7;
        x[1] = _y_1_6;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = _p_12 * _A_2_2_3 - 1.0;
        residual[1] = _p_12 * _A_1_2_1;
        residual[2] = _p_12 * _A_2_1_2;
        residual[3] = _p_12 * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_2_7 = x[0];
            _y_1_6 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_2_7 - (_p_12 * _A_2_1_2 * _y_1_6 + _p_12 * _A_2_2_3 * _y_2_7);
            (*res)[1] = _y_1_6 - (_p_12 * _A_1_1_0 * _y_1_6 + _p_12 * _A_1_2_1 * _y_2_7);
        }
    }
    return ef;
}

static int dae_init_block_2(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 3 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
        x[1] = 9;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z_2_9;
        x[1] = _z_1_8;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_d_13 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_d_13 + 1) * _A_1_2_1;
        residual[2] = (_d_13 + 1) * _A_2_1_2;
        residual[3] = (_d_13 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z_2_9 = x[0];
            _z_1_8 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _z_2_9 + 2 - ((_d_13 + 1) * _A_2_1_2 * _z_1_8 + (_d_13 + 1) * _A_2_2_3 * _z_2_9);
            (*res)[1] = _z_1_8 + 2 - ((_d_13 + 1) * _A_1_1_0 * _z_1_8 + (_d_13 + 1) * _A_1_2_1 * _z_2_9);
        }
    }
    return ef;
}

static int dae_init_block_3(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 4 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 11;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _w_2_11;
        x[1] = _w_1_10;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = (_x_1_4 + 1) * _A_2_2_3 - 1.0;
        residual[1] = (_x_1_4 + 1) * _A_1_2_1;
        residual[2] = (_x_1_4 + 1) * _A_2_1_2;
        residual[3] = (_x_1_4 + 1) * _A_1_1_0 - 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _w_2_11 = x[0];
            _w_1_10 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _w_2_11 + 3 - ((_x_1_4 + 1) * _A_2_1_2 * _w_1_10 + (_x_1_4 + 1) * _A_2_2_3 * _w_2_11);
            (*res)[1] = _w_1_10 + 3 - ((_x_1_4 + 1) * _A_1_1_0 * _w_1_10 + (_x_1_4 + 1) * _A_1_2_1 * _w_2_11);
        }
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 2, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, 2, 0, 0, JMI_PARAMETER_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 1, \"2\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_2, NULL, 2, 0, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 2, \"3\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_3, NULL, 2, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 3, \"4\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 2, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_1, NULL, 2, 0, 0, JMI_PARAMETER_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 1, \"2\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_2, NULL, 2, 0, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 2, \"3\", -1);
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_3, NULL, 2, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 3, \"4\", -1);
")})));
end BlockTest7;

model BlockTest8
    Real a;
    Real b;
    Boolean d;
equation
    a = 1 - b;
    a = sin(b) * (if d then 1 else 2);
    d = b < 0;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest8",
            description="Test of mixed non-solved equation block",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=false,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_b_1 - (0), _sw(0), jmi->events_epsilon, JMI_REL_LT);
            }
            _d_2 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = sin(_b_1) * COND_EXP_EQ(_d_2, JMI_TRUE, AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2)) - (_a_0);
            (*res)[1] = 1 - _b_1 - (_a_0);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_b_1 - (0), _sw(0), jmi->events_epsilon, JMI_REL_LT);
            }
            _d_2 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = sin(_b_1) * COND_EXP_EQ(_d_2, JMI_TRUE, AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2)) - (_a_0);
            (*res)[1] = 1 - _b_1 - (_a_0);
        }
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 2, 1, 1, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 2, 1, 1, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
")})));
end BlockTest8;

model BlockTest9
    function F
        input Real t[2];
        output Real y;
    algorithm
        y := t[1] * 2;
        if t[1] > t[2] then
            y := t[1] - t[2];
        end if;
    end F;
    
    Real x;
equation
    0 = x * F({time, 2});
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest9",
            description="Test of linear equation block",
            generate_ode=true,
            equation_sorting=true,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = _time;
        jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
        residual[0] = (- func_CCodeGenTests_BlockTest9_F_exp0(tmp_1));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
            jmi_array_ref_1(tmp_2, 1) = _time;
            jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(2);
            (*res)[0] = _x_0 * func_CCodeGenTests_BlockTest9_F_exp0(tmp_2) - (0);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_ref_1(tmp_3, 1) = _time;
        jmi_array_ref_1(tmp_3, 2) = AD_WRAP_LITERAL(2);
        residual[0] = (- func_CCodeGenTests_BlockTest9_F_exp0(tmp_3));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
            jmi_array_ref_1(tmp_2, 1) = _time;
            jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(2);
            (*res)[0] = _x_0 * func_CCodeGenTests_BlockTest9_F_exp0(tmp_2) - (0);
        }
    }
    return ef;
}

")})));
end BlockTest9;

model BlockTest10
    function F
        input Real t[2];
        output Real y;
    algorithm
        y := t[1] * 2;
        if t[1] > t[2] then
            y := t[1] - t[2];
        end if;
    end F;
    
    Real x;
    Boolean b;
equation
    b = x > 0;
    0 = if b then x * F({time, 2}) else -1;
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest10",
            description="Test of mixed linear equation block",
            generate_ode=true,
            automatic_tearing=false,
            equation_sorting=true,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870914;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = _time;
        jmi_array_ref_1(tmp_1, 2) = AD_WRAP_LITERAL(2);
        residual[0] = - COND_EXP_EQ(_b_1, JMI_TRUE, func_CCodeGenTests_BlockTest10_F_exp0(tmp_1), AD_WRAP_LITERAL(0));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_x_0 - (0), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _b_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
            jmi_array_ref_1(tmp_2, 1) = _time;
            jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(2);
            (*res)[0] = COND_EXP_EQ(_b_1, JMI_TRUE, _x_0 * func_CCodeGenTests_BlockTest10_F_exp0(tmp_2), AD_WRAP_LITERAL(-1)) - (0);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870914;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_ref_1(tmp_3, 1) = _time;
        jmi_array_ref_1(tmp_3, 2) = AD_WRAP_LITERAL(2);
        residual[0] = - COND_EXP_EQ(_b_1, JMI_TRUE, func_CCodeGenTests_BlockTest10_F_exp0(tmp_3), AD_WRAP_LITERAL(0));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_x_0 - (0), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _b_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
            jmi_array_ref_1(tmp_2, 1) = _time;
            jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(2);
            (*res)[0] = COND_EXP_EQ(_b_1, JMI_TRUE, _x_0 * func_CCodeGenTests_BlockTest10_F_exp0(tmp_2), AD_WRAP_LITERAL(-1)) - (0);
        }
    }
    return ef;
}

")})));
end BlockTest10;

model BlockTest11
    Real a,b;
equation
    a = b * (if time > 1 then 3.14 else 6.18);
    a + b = 42;
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest11",
            description="Test relation switch expression in jacobian of mixed linear equation block",
            generate_ode=true,
            automatic_tearing=false,
            equation_sorting=true,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw(0), jmi->events_epsilon, JMI_REL_GT);
        }
        residual[1] = (- COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(3.14), AD_WRAP_LITERAL(6.18)));
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 42 - (_a_0 + _b_1);
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            (*res)[1] = _b_1 * COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(3.14), AD_WRAP_LITERAL(6.18)) - (_a_0);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
        x[1] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        x[1] = _a_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 4 * sizeof(jmi_real_t));
        residual[0] = 1.0;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw(0), jmi->events_epsilon, JMI_REL_GT);
        }
        residual[1] = (- COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(3.14), AD_WRAP_LITERAL(6.18)));
        residual[2] = 1.0;
        residual[3] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
            _a_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 42 - (_a_0 + _b_1);
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            (*res)[1] = _b_1 * COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(3.14), AD_WRAP_LITERAL(6.18)) - (_a_0);
        }
    }
    return ef;
}

")})));
end BlockTest11;

model BlockTest12
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    
    Integer t;
    Real y,x;
  equation
    (t,y) = f(x);
    x = y + 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest12",
            description="Mixed function call in block",
            inline_functions="none",
            variability_propagation=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435459;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        func_CCodeGenTests_BlockTest12_f_def0(_x_2, &tmp_1, &tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_1);
        }
        _y_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_1 + 1 - (_x_2);
        }
    }
    return ef;
}

")})));
end BlockTest12;

model BlockTest13
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    
    Integer t;
    Real y,x;
  equation
    (t,y) = f(x);
    y = 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest13",
            description="Mixed function call in block",
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435459;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        func_CCodeGenTests_BlockTest13_f_def0(_x_2, &tmp_1, &tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_2 - (_y_1);
        }
    }
    return ef;
}

")})));
end BlockTest13;

model BlockTest14
    Integer t;
    Real y,x;
  algorithm
    t := 1;
    y := x;
  equation
    x = y + 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest14",
            description="Mixed algorithm in block",
            inline_functions="none",
            variability_propagation=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435459;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_2 = _y_1 + 1;
        tmp_2 = _t_0;
        tmp_3 = _y_1;
        _t_0 = 1;
        _y_1 = _x_2;
        tmp_1 = _t_0;
        _t_0 = tmp_2;
        tmp_2 = tmp_1;
        tmp_1 = _y_1;
        _y_1 = tmp_3;
        tmp_3 = tmp_1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_2);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_3 - (_y_1);
        }
    }
    return ef;
}

")})));
end BlockTest14;

model BlockTest15
    Integer t;
    Real y,x;
  algorithm
    t := 1;
    y := x;
  equation
    y = 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest15",
            description="Mixed algorithm in block",
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435459;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        tmp_2 = _t_0;
        tmp_3 = _y_1;
        _t_0 = 1;
        _y_1 = _x_2;
        tmp_1 = _t_0;
        _t_0 = tmp_2;
        tmp_2 = tmp_1;
        tmp_1 = _y_1;
        _y_1 = tmp_3;
        tmp_3 = tmp_1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _t_0 = (tmp_2);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_3 - (_y_1);
        }
    }
    return ef;
}

")})));
end BlockTest15;

model BlockTest16
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    Integer t;
    Real y,x;
  equation
    if x < y then
        (t,y) = f(x);
    else
        (t,y) = f(x);
    end if;
    x = y + 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest16",
            description="Mixed if equation in block",
            inline_functions="none",
            variability_propagation=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435459;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_2 = _y_1 + 1;
        if (_sw(0)) {
            func_CCodeGenTests_BlockTest16_f_def0(_x_2, &tmp_1, &tmp_2);
        } else {
            func_CCodeGenTests_BlockTest16_f_def0(_x_2, &tmp_3, &tmp_4);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (_sw(0)) {
                _t_0 = (tmp_1);
            } else {
                _t_0 = (tmp_3);
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                (*res)[0] = tmp_2 - (_y_1);
            } else {
                (*res)[0] = tmp_4 - (_y_1);
            }
        }
    }
    return ef;
}

")})));
end BlockTest16;

model BlockTest17
    function f
        input Real x;
        output Integer y1 = 1;
        output Real y2 = x;
      algorithm
    end f;
    Integer t;
    Real y,x;
  equation
    if x < y then
        (t,y) = f(x);
    else
        (t,y) = f(x);
    end if;
    y = 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="BlockTest17",
            description="Mixed if equation in block",
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 268435459;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        if (_sw(0)) {
            func_CCodeGenTests_BlockTest17_f_def0(_x_2, &tmp_1, &tmp_2);
        } else {
            func_CCodeGenTests_BlockTest17_f_def0(_x_2, &tmp_3, &tmp_4);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (_sw(0)) {
                _t_0 = (tmp_1);
            } else {
                _t_0 = (tmp_3);
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (_sw(0)) {
                (*res)[0] = tmp_2 - (_y_1);
            } else {
                (*res)[0] = tmp_4 - (_y_1);
            }
        }
    }
    return ef;
}

")})));
end BlockTest17;



model Algorithm1
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := 5;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm1",
			description="C code generation of algorithms",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = 5;
    _y_1 = _x_0 + 2;
/********* Write back reinits *******/
")})));
end Algorithm1;


model Algorithm2
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := 5;
 x := x + 2;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm2",
			description="C code generation of algorithms",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = 5;
    _x_0 = _x_0 + 2;
    _y_1 = _x_0 + 2;
/********* Write back reinits *******/
")})));
end Algorithm2;


model Algorithm3
 Real x;
 Real y;
equation
 y = x + 2;
algorithm
 x := y;
 x := x * 2;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm3",
			description="C code generation of algorithms - in block",
			generate_ode=true,
			equation_sorting=true,
			automatic_tearing=false,
			variability_propagation=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _x_0;
            _x_0 = _y_1;
            _x_0 = _x_0 * 2;
            tmp_1 = _x_0;
            _x_0 = tmp_2;
            tmp_2 = tmp_1;
            (*res)[0] = tmp_2 - (_x_0);
            (*res)[1] = _x_0 + 2 - (_y_1);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
         if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _x_0;
            _x_0 = _y_1;
            _x_0 = _x_0 * 2;
            tmp_1 = _x_0;
            _x_0 = tmp_2;
            tmp_2 = tmp_1;
            (*res)[0] = tmp_2 - (_x_0);
            (*res)[1] = _x_0 + 2 - (_y_1);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/********* Write back reinits *******/

"),
		CCodeGenTestCase(
			name="Algorithm3Tearing",
			description="C code generation of algorithms - in torn block",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_0 = _y_1;
        _x_0 = _x_0 * 2;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 2 - (_y_1);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
        }
        _x_0 = _y_1;
        _x_0 = _x_0 * 2;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 + 2 - (_y_1);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/********* Write back reinits *******/

")})));
end Algorithm3;


model Algorithm4
    Real x, y, z;
equation
    y + x + z = 3;
algorithm
    y:= x*2 + 2;
    z:= y + x;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm4",
			description="C code generation of algorithms - in block",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			automatic_tearing=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
        x[2] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
        x[2] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
            _z_2 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _y_1;
            tmp_3 = _z_2;
            _y_1 = _x_0 * 2 + 2;
            _z_2 = _y_1 + _x_0;
            tmp_1 = _y_1;
            _y_1 = tmp_2;
            tmp_2 = tmp_1;
            tmp_1 = _z_2;
            _z_2 = tmp_3;
            tmp_3 = tmp_1;
            (*res)[0] = tmp_2 - (_y_1);
            (*res)[1] = tmp_3 - (_z_2);
            (*res)[2] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
        x[2] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
        x[2] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
            _z_2 = x[2];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _y_1;
            tmp_3 = _z_2;
            _y_1 = _x_0 * 2 + 2;
            _z_2 = _y_1 + _x_0;
            tmp_1 = _y_1;
            _y_1 = tmp_2;
            tmp_2 = tmp_1;
            tmp_1 = _z_2;
            _z_2 = tmp_3;
            tmp_3 = tmp_1;
            (*res)[0] = tmp_2 - (_y_1);
            (*res)[1] = tmp_3 - (_z_2);
            (*res)[2] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/********* Write back reinits *******/

"),
		CCodeGenTestCase(
			name="Algorithm4Tearing",
			description="C code generation of algorithms - in torn block",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
	jmi_ad_var_t tmp_1;
	jmi_ad_var_t tmp_2;
	jmi_ad_var_t tmp_3;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        tmp_2 = _y_1;
        tmp_3 = _z_2;
        _y_1 = _x_0 * 2 + 2;
        _z_2 = _y_1 + _x_0;
        tmp_1 = _y_1;
        _y_1 = tmp_2;
        tmp_2 = tmp_1;
        tmp_1 = _z_2;
        _z_2 = tmp_3;
        tmp_3 = tmp_1;
        _z_2 = (tmp_3);
        _y_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        tmp_2 = _y_1;
        tmp_3 = _z_2;
        _y_1 = _x_0 * 2 + 2;
        _z_2 = _y_1 + _x_0;
        tmp_1 = _y_1;
        _y_1 = tmp_2;
        tmp_2 = tmp_1;
        tmp_1 = _z_2;
        _z_2 = tmp_3;
        tmp_3 = tmp_1;
        _z_2 = (tmp_3);
        _y_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = 3 - (_y_1 + _x_0 + _z_2);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/********* Write back reinits *******/

")})));
end Algorithm4;


model Algorithm5
 Real x(start=0.5);
algorithm
 while noEvent(x < 1) loop
  while noEvent(x < 2) loop
   while noEvent(x < 3) loop
    x := x + 1;
   end while;
  end while;
 end while;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm5",
			description="C code generation of algorithm with while loops",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_ode_derivatives$
",
			generatedCode="


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = 0.5;
    while ((COND_EXP_LT(_x_0, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE))) {
        while ((COND_EXP_LT(_x_0, AD_WRAP_LITERAL(2), JMI_TRUE, JMI_FALSE))) {
            while ((COND_EXP_LT(_x_0, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE))) {
                _x_0 = _x_0 + 1;
            }
        }
    }
/********* Write back reinits *******/
")})));
end Algorithm5;


model Algorithm6
 Real x;
algorithm
 for i in {1, 2, 4}, j in 1:3 loop
  x := x + i * j;
 end for;
end Algorithm6;


model Algorithm7
	Real x,y,z,a;
algorithm
	x := y;
algorithm
	a := z*x;
equation
	y = x * 2;
	z = time + a;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm7",
            description="C code generation of algorithm.",
            generate_ode=true,
            equation_sorting=true,
            inline_functions="none",
            variability_propagation=false,
            automatic_tearing=false,
            template="
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
        x[1] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
            _y_1 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _x_0;
            _x_0 = _y_1;
            tmp_1 = _x_0;
            _x_0 = tmp_2;
            tmp_2 = tmp_1;
            (*res)[0] = tmp_2 - (_x_0);
            (*res)[1] = _x_0 * 2 - (_y_1);
        }
    }
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_3;
        x[1] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_3 = x[0];
            _z_2 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_4 = _a_3;
            _a_3 = _z_2 * _x_0;
            tmp_3 = _a_3;
            _a_3 = tmp_4;
            tmp_4 = tmp_3;
            (*res)[0] = tmp_4 - (_a_3);
            (*res)[1] = _time + _a_3 - (_z_2);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
/********* Write back reinits *******/
")})));
end Algorithm7;


model Algorithm8
	Real x,y,z,a;
initial algorithm
	x := y + z;
algorithm
	a := z + x;
equation
	y = x * 2;
	z = time + a;
	when time > 1 then
		x = 2;
	end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm8",
            description="C code generation of initial algorithm.",
            generate_ode=true,
            equation_sorting=true,
            inline_functions="none",
            variability_propagation=false,
            automatic_tearing=false,
            template="
$C_dae_init_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
            generatedCode="
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
        x[2] = 4;
        x[3] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_3;
        x[1] = _z_2;
        x[2] = _x_0;
        x[3] = _y_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_3 = x[0];
            _z_2 = x[1];
            _x_0 = x[2];
            _y_1 = x[3];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _a_3;
            _a_3 = _z_2 + _x_0;
            tmp_1 = _a_3;
            _a_3 = tmp_2;
            tmp_2 = tmp_1;
            (*res)[0] = tmp_2 - (_a_3);
            (*res)[1] = _time + _a_3 - (_z_2);
            tmp_4 = _x_0;
            _x_0 = _y_1 + _z_2;
            tmp_3 = _x_0;
            _x_0 = tmp_4;
            tmp_4 = tmp_3;
            (*res)[2] = tmp_4 - (_x_0);
            (*res)[3] = _x_0 * 2 - (_y_1);
        }
    }
    return ef;
}


static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_3;
        x[1] = _z_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_3 = x[0];
            _z_2 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_2 = _a_3;
            _a_3 = _z_2 + _x_0;
            tmp_1 = _a_3;
            _a_3 = tmp_2;
            tmp_2 = tmp_1;
            (*res)[0] = tmp_2 - (_a_3);
            (*res)[1] = _time + _a_3 - (_z_2);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_4 = _sw(0);
    _x_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_4, LOG_EXP_NOT(pre_temp_1_4)), JMI_TRUE, AD_WRAP_LITERAL(2), pre_x_0);
    _y_1 = _x_0 * 2;
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
/********* Write back reinits *******/
")})));
end Algorithm8;

model Algorithm9
record R
	Real[3] a;
end R;

function f
	output Real[2] o;
algorithm
	o := {1, 1};
end f;

function fw
protected R r_;
	output R r;
algorithm
	r.a[1:2] := 2*f();
	r.a[2:3] := f();
	r_ := r;
end fw;


R r,re;
algorithm
	r.a[1:2] := 2*f();
	r.a[2:3] := f();
	r := fw();
equation
	re.a[1] = 1;
	(re.a[2:3]) = f();
	
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm9",
            description="C code generation of assignment statements scalarized into function call statements",
            generate_ode=true,
            equation_sorting=true,
            inline_functions="none",
            variability_propagation=false,
            eliminate_alias_variables=false,
            template="
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
void func_CCodeGenTests_Algorithm9_f_def0(jmi_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1)
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 2) = 1;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_Algorithm9_fw_def1(R_0_r* r_v) {
    JMI_DYNAMIC_INIT()
    JMI_RECORD_STATIC(R_0_r, r__v)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_RECORD_STATIC(R_0_r, r_vn)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, 2, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    r__v->a = tmp_1;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, temp_1_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, temp_2_a, 2, 1, 2)
    if (r_v == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 3, 1, 3)
        r_vn->a = tmp_2;
        r_v = r_vn;
    }
    func_CCodeGenTests_Algorithm9_f_def0(temp_1_a);
    jmi_array_ref_1(r_v->a, 1) = 2 * jmi_array_val_1(temp_1_a, 1);
    jmi_array_ref_1(r_v->a, 2) = 2 * jmi_array_val_1(temp_1_a, 2);
    func_CCodeGenTests_Algorithm9_f_def0(temp_2_a);
    jmi_array_ref_1(r_v->a, 2) = jmi_array_val_1(temp_2_a, 1);
    jmi_array_ref_1(r_v->a, 3) = jmi_array_val_1(temp_2_a, 2);
    jmi_array_ref_1(r__v->a, 1) = jmi_array_val_1(r_v->a, 1);
    jmi_array_ref_1(r__v->a, 2) = jmi_array_val_1(r_v->a, 2);
    jmi_array_ref_1(r__v->a, 3) = jmi_array_val_1(r_v->a, 3);
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_RECORD_STATIC(R_0_r, tmp_3)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 3, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_5, 2, 1)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 3, 1, 3)
    tmp_3->a = tmp_4;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    func_CCodeGenTests_Algorithm9_f_def0(tmp_1);
    _temp_2_1_8 = (jmi_array_val_1(tmp_1, 1));
    _temp_2_2_9 = (jmi_array_val_1(tmp_1, 2));
    _r_a_1_0 = 2 * _temp_2_1_8;
    _r_a_2_1 = 2 * _temp_2_2_9;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    func_CCodeGenTests_Algorithm9_f_def0(tmp_2);
    _temp_3_1_10 = (jmi_array_val_1(tmp_2, 1));
    _temp_3_2_11 = (jmi_array_val_1(tmp_2, 2));
    _r_a_2_1 = _temp_3_1_10;
    _r_a_3_2 = _temp_3_2_11;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 3, 1, 3)
    tmp_3->a = tmp_4;
    func_CCodeGenTests_Algorithm9_fw_def1(tmp_3);
    _temp_4_a_1_12 = (jmi_array_val_1(tmp_3->a, 1));
    _temp_4_a_2_13 = (jmi_array_val_1(tmp_3->a, 2));
    _temp_4_a_3_14 = (jmi_array_val_1(tmp_3->a, 3));
    _r_a_1_0 = _temp_4_a_1_12;
    _r_a_2_1 = _temp_4_a_2_13;
    _r_a_3_2 = _temp_4_a_3_14;
    _re_a_1_3 = 1;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_5, 2, 1, 2)
    func_CCodeGenTests_Algorithm9_f_def0(tmp_5);
    _temp_1_1_6 = (jmi_array_val_1(tmp_5, 1));
    _temp_1_2_7 = (jmi_array_val_1(tmp_5, 2));
    _re_a_2_4 = _temp_1_1_6;
    _re_a_3_5 = _temp_1_2_7;
/********* Write back reinits *******/
")})));
end Algorithm9;

model Algorithm10

function f
	input Real[2] i;
	output Real[2] o;
	output Real dummy = 1;
algorithm
	o := i;
end f;

function fw
	output Real[5] o;
	output Real dummy = 1;
algorithm
	o[{1,3,5}] := {1,1,1};
	(o[{2,4}],) := f(o[{3,5}]);
end fw;

Real[5] a,ae;
algorithm
	(a[{2,4}],) := f({1,1});
	(a[{5,4,3,2,1}],) := fw();
equation
	(ae[{5,4,3,2,1}],) = fw();

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm10",
            description="C code generation of slices in function call assignments",
            algorithms_as_functions=false,
            generate_ode=true,
            equation_sorting=true,
            inline_functions="none",
            variability_propagation=false,
            eliminate_alias_variables=false,
            template="
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
void func_CCodeGenTests_Algorithm10_fw_def0(jmi_array_t* o_a, jmi_ad_var_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 5, 1)
    jmi_ad_var_t dummy_v;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 5, 1, 5)
        o_a = o_an;
    }
    dummy_v = 1;
    jmi_array_ref_1(o_a, 1) = 1;
    jmi_array_ref_1(o_a, 3) = 1;
    jmi_array_ref_1(o_a, 5) = 1;
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = jmi_array_val_1(o_a, 3);
    jmi_array_ref_1(tmp_2, 2) = jmi_array_val_1(o_a, 5);
    func_CCodeGenTests_Algorithm10_f_def1(tmp_2, tmp_1, NULL);
    jmi_array_ref_1(o_a, 2) = (jmi_array_val_1(tmp_1, 1));
    jmi_array_ref_1(o_a, 4) = (jmi_array_val_1(tmp_1, 2));
    if (dummy_o != NULL) *dummy_o = dummy_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_Algorithm10_f_def1(jmi_array_t* i_a, jmi_array_t* o_a, jmi_ad_var_t* dummy_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1)
    jmi_ad_var_t dummy_v;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, o_an, 2, 1, 2)
        o_a = o_an;
    }
    dummy_v = 1;
    jmi_array_ref_1(o_a, 1) = jmi_array_val_1(i_a, 1);
    jmi_array_ref_1(o_a, 2) = jmi_array_val_1(i_a, 2);
    if (dummy_o != NULL) *dummy_o = dummy_v;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 5, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 5, 1)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(1);
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 5, 1, 5)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_2, 2) = AD_WRAP_LITERAL(1);
    func_CCodeGenTests_Algorithm10_f_def1(tmp_2, tmp_1, NULL);
    _a_2_1 = (jmi_array_val_1(tmp_1, 1));
    _a_4_3 = (jmi_array_val_1(tmp_1, 2));
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_3, 5, 1, 5)
    func_CCodeGenTests_Algorithm10_fw_def0(tmp_3, NULL);
    _a_5_4 = (jmi_array_val_1(tmp_3, 1));
    _a_4_3 = (jmi_array_val_1(tmp_3, 2));
    _a_3_2 = (jmi_array_val_1(tmp_3, 3));
    _a_2_1 = (jmi_array_val_1(tmp_3, 4));
    _a_1_0 = (jmi_array_val_1(tmp_3, 5));
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_4, 5, 1, 5)
    func_CCodeGenTests_Algorithm10_fw_def0(tmp_4, NULL);
    _ae_5_9 = (jmi_array_val_1(tmp_4, 1));
    _ae_4_8 = (jmi_array_val_1(tmp_4, 2));
    _ae_3_7 = (jmi_array_val_1(tmp_4, 3));
    _ae_2_6 = (jmi_array_val_1(tmp_4, 4));
    _ae_1_5 = (jmi_array_val_1(tmp_4, 5));
/********* Write back reinits *******/
")})));
end Algorithm10;

model Algorithm11
	Real x,y,z1,z2,z3;
algorithm
	y := x;
	z1 := x;
algorithm
	y := z1;
	z2 := x;
algorithm
	y := z3;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Algorithm11",
            description="C code generation of algorithm. Residual from algorithm result.",
            generate_ode=true,
            equation_sorting=true,
            inline_functions="none",
            template="
$C_dae_add_blocks_residual_functions$
$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
            generatedCode="
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"2\", -1);

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_6;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_0 = x[0];
        }
        tmp_2 = _y_1;
        tmp_3 = _z1_2;
        _y_1 = _x_0;
        _z1_2 = _x_0;
        tmp_1 = _y_1;
        _y_1 = tmp_2;
        tmp_2 = tmp_1;
        tmp_1 = _z1_2;
        _z1_2 = tmp_3;
        tmp_3 = tmp_1;
        _z1_2 = (tmp_3);
        tmp_5 = _y_1;
        tmp_6 = _z2_3;
        _y_1 = _z1_2;
        _z2_3 = _x_0;
        tmp_4 = _y_1;
        _y_1 = tmp_5;
        tmp_5 = tmp_4;
        tmp_4 = _z2_3;
        _z2_3 = tmp_6;
        tmp_6 = tmp_4;
        _z2_3 = (tmp_6);
        _y_1 = (tmp_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_5 - (_y_1);
        }
    }
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_7;
    jmi_ad_var_t tmp_8;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 4;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _z3_4;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _z3_4 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            tmp_8 = _y_1;
            _y_1 = _z3_4;
            tmp_7 = _y_1;
            _y_1 = tmp_8;
            tmp_8 = tmp_7;
            (*res)[0] = tmp_8 - (_y_1);
        }
    }
    return ef;
}


    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
/********* Write back reinits *******/
")})));
end Algorithm11;

model Algorithm12
 Real x(start=0.5);
 Real y = time;
 Boolean b;
algorithm
 x := 1;
 b := y >= x * 3 or y - 1 < x;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm12",
			description="C code generation of relational expressions in algorithms, assign",
			algorithms_as_functions=false,
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _y_1 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_temp_1_3, _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_temp_2_4, _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    _x_0 = 1;
    _temp_1_3 = _y_1 - _x_0 * 3;
    _temp_2_4 = _y_1 - 1 - _x_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_temp_1_3, _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_temp_2_4, _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    _b_2 = LOG_EXP_OR(_sw(0), _sw(1));
/********* Write back reinits *******/

    (*res)[0] = _temp_1_3;
    (*res)[1] = _temp_2_4;
")})));
end Algorithm12;

model Algorithm13
  Real r1;
algorithm
	if time > 0.5 then 
		r1 := 1;
	elseif time > 1 then
		if time > 0.7 then
			r1 := 2;
		end if;
	else
		if time > 1.5 then
			r1 := 3;
		else
			r1 := 4;
		end if;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm13",
			description="C code generation of relational expressions in algorithms, if",
			algorithms_as_functions=false,
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_ode_derivatives$
$C_DAE_event_indicator_residuals$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (0.5), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_time - (1), _sw(1), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_time - (0.7), _sw(2), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_time - (1.5), _sw(3), jmi->events_epsilon, JMI_REL_GT);
    }
    _r1_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (0.5), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_time - (1), _sw(1), jmi->events_epsilon, JMI_REL_GT);
    }
    if (_sw(0)) {
        _r1_0 = 1;
    } else if (_sw(1)) {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(2) = jmi_turn_switch(_time - (0.7), _sw(2), jmi->events_epsilon, JMI_REL_GT);
        }
        if (_sw(2)) {
            _r1_0 = 2;
        }
    } else {
        if (jmi->atInitial || jmi->atEvent) {
            _sw(3) = jmi_turn_switch(_time - (1.5), _sw(3), jmi->events_epsilon, JMI_REL_GT);
        }
        if (_sw(3)) {
            _r1_0 = 3;
        } else {
            _r1_0 = 4;
        }
    }
/********* Write back reinits *******/

    (*res)[0] = _time - (0.5);
    (*res)[1] = _time - (1);
    (*res)[2] = _time - (0.7);
    (*res)[3] = _time - (1.5);
")})));
end Algorithm13;

model Algorithm14
	Real x;
algorithm
	when time > 1 then
		x := 2;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm14",
			description="C code generation of when statement",
			generate_ode=true,
			equation_sorting=true,
			inline_functions="none",
			variability_propagation=false,
			automatic_tearing=false,
			template="
$C_ode_derivatives$
$C_ode_initialization$
$C_DAE_event_indicator_residuals$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = pre_x_0;
    if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
        _x_0 = 2;
    }
/********* Write back reinits *******/

    model_ode_guards(jmi);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    pre_x_0 = 0.0;
    _x_0 = pre_x_0;
    pre_temp_1_1 = JMI_FALSE;

    (*res)[0] = _time - (1);
")})));
end Algorithm14;

model Algorithm15
	Real x;
initial equation
	x = 1;
algorithm
	when time > 1 then
		x := 2;
	end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm15",
			description="C code generation of when statement and initial equation",
			generate_ode=true,
			equation_sorting=true,
			inline_functions="none",
			variability_propagation=false,
			automatic_tearing=false,
			template="
$C_ode_derivatives$
$C_ode_initialization$
$C_DAE_event_indicator_residuals$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = pre_x_0;
    if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
        _x_0 = 2;
    }
/********* Write back reinits *******/

    model_ode_guards(jmi);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 1;
    pre_x_0 = _x_0;
    pre_temp_1_1 = JMI_FALSE;

    (*res)[0] = _time - (1);
")})));
end Algorithm15;

model Algorithm16
  Real x;
  discrete Real a,b;
equation
  x = sin(time*10);
algorithm
  when {x >= 0.7} then
    a := a + 1;
  elsewhen {initial(), x < 0.7} then
    a := a - 1;
  elsewhen {x >= 0.7, x >= 0.8, x < 0.8, x < 0.7} then
    b := b + 1;
  end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm16",
			description="C code generation of elsewhen statement",
			generate_ode=true,
			equation_sorting=true,
			inline_functions="none",
			variability_propagation=false,
			automatic_tearing=false,
			template="
$C_ode_derivatives$
$C_ode_initialization$
$C_DAE_event_indicator_residuals$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = sin(_time * AD_WRAP_LITERAL(10));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (0.7), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_1_3 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_0 - (0.7), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_2_4 = _sw(1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (0.7), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_3_5 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_x_0 - (0.8), _sw(2), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_4_6 = _sw(2);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_x_0 - (0.8), _sw(3), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_5_7 = _sw(3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_0 - (0.7), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_6_8 = _sw(1);
    _a_1 = pre_a_1;
    _b_2 = pre_b_2;
    if (LOG_EXP_AND(_temp_1_3, LOG_EXP_NOT(pre_temp_1_3))) {
        _a_1 = _a_1 + 1;
    } else if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_2_4, LOG_EXP_NOT(pre_temp_2_4)))) {
        _a_1 = _a_1 - 1;
    } else if (LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_OR(LOG_EXP_AND(_temp_3_5, LOG_EXP_NOT(pre_temp_3_5)), LOG_EXP_AND(_temp_4_6, LOG_EXP_NOT(pre_temp_4_6))), LOG_EXP_AND(_temp_5_7, LOG_EXP_NOT(pre_temp_5_7))), LOG_EXP_AND(_temp_6_8, LOG_EXP_NOT(pre_temp_6_8)))) {
        _b_2 = _b_2 + 1;
    }
/********* Write back reinits *******/

    model_ode_guards(jmi);
    _x_0 = sin(_time * AD_WRAP_LITERAL(10));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (0.7), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_1_3 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_0 - (0.7), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_2_4 = _sw(1);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (0.7), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_3_5 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_x_0 - (0.8), _sw(2), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_4_6 = _sw(2);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(3) = jmi_turn_switch(_x_0 - (0.8), _sw(3), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_5_7 = _sw(3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_x_0 - (0.7), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    _temp_6_8 = _sw(1);
    pre_a_1 = 0.0;
    _a_1 = pre_a_1;
    _a_1 = _a_1 - 1;
    pre_b_2 = 0.0;
    _b_2 = pre_b_2;
    pre_temp_1_3 = JMI_FALSE;
    pre_temp_2_4 = JMI_FALSE;
    pre_temp_3_5 = JMI_FALSE;
    pre_temp_4_6 = JMI_FALSE;
    pre_temp_5_7 = JMI_FALSE;
    pre_temp_6_8 = JMI_FALSE;

    (*res)[0] = _x_0 - (0.7);
    (*res)[1] = _x_0 - (0.7);
    (*res)[2] = _x_0 - (0.8);
    (*res)[3] = _x_0 - (0.8);

")})));
end Algorithm16;

model Algorithm17
	parameter Real x(fixed=false);
	parameter Real y(fixed=false) = 1;
	parameter Boolean b = false;
initial algorithm
	if b then
		x := 2;
	end if;
initial algorithm
	if b then
		y := 2;
	end if;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Algorithm17",
			description="C code generation for initial statement of non-fixed parameter",
			generate_ode=true,
			equation_sorting=true,
			inline_functions="none",
			variability_propagation=false,
			automatic_tearing=false,
			template="
$C_ode_initialization$
",
			generatedCode="
    model_ode_guards(jmi);
    _x_0 = 0.0;
    if (_b_2) {
        _x_0 = 2;
    }
    _y_1 = 1;
    if (_b_2) {
        _y_1 = 2;
    }

			
")})));
end Algorithm17;

model OutputTest1

  output Real x_1(start=0.951858508368);
  output Real x_2(start=2.17691690118);
  output Real x_3(start=1.47982066619);
  output Real x_4(start=2.41568015438);
  output Real x_5(start=2.50288121643);
  output Real w_ode_1_1;
  Real w_ode_1_2;
  Real w_ode_1_3;
  output Real w_ode_2_1;
  Real w_ode_2_2;
  Real w_ode_2_3;
  output Real w_ode_3_1;
  Real w_ode_3_2;
  Real w_ode_3_3;
  output Real w_ode_4_1;
  Real w_ode_4_2;
  Real w_ode_4_3;
  output Real w_ode_5_1;
  Real w_ode_5_2;
  Real w_ode_5_3;
  output Real w_output_1_1;
  output Real w_output_1_2;
  output Real w_output_1_3;
  output Real w_output_2_1;
  output Real w_output_2_2;
  output Real w_output_2_3;
  output Real w_output_3_1;
  output Real w_output_3_2;
  output Real w_output_3_3;
  output Real w_output_4_1;
  output Real w_output_4_2;
  output Real w_output_4_3;
  output Real w_output_5_1;
  output Real w_output_5_2;
  output Real w_output_5_3;
  output Real w_output_6_1;
  output Real w_output_6_2;
  output Real w_output_6_3;
  Real w_other_1_1;
  Real w_other_1_2;
  Real w_other_1_3;
  Real w_other_2_1;
  Real w_other_2_2;
  Real w_other_2_3;
  Real w_other_3_1;
  Real w_other_3_2;
  Real w_other_3_3;
  input Real ur_1;
  input Real ur_2;
  input Real ur_3;
  input Real ur_4;
  output Integer io1 = 1;
  output Boolean bo1 = true;
equation
(w_ode_1_1) + 4*(w_ode_1_2) + (w_ode_1_3) + sin(x_5) - (x_3) - 4*(x_5) + cos(ur_3) + 4*(ur_3) = 0;
cos(w_ode_1_1) + (w_ode_1_2)*sin(w_ode_1_3) + 4*(x_4) - 4*(x_5) - 4*(x_4) + (ur_4) + 4*(ur_1) = 0;
sin(w_ode_1_1) - sin(w_ode_1_2) - sin(w_ode_1_3) + 4*(x_2)*4*(x_3)*4*(x_3) + 4*(ur_3)*4*(ur_1) = 0;

der(x_1) = cos(w_ode_1_1)*(w_ode_1_2)*cos(w_ode_1_3) + 4*(x_2) + 4*(x_1) - (x_5) + 4*(ur_2) + cos(ur_4);

(w_ode_2_1)*sin(w_ode_2_2)*4*(w_ode_2_3) + (x_3) - (x_5) + sin(x_2) + (ur_3)*sin(ur_1) = 0;
4*(w_ode_2_1)*sin(w_ode_2_2) - cos(w_ode_2_3) + cos(x_4)*cos(x_3) - cos(x_3) + 4*(ur_1) - cos(ur_2) = 0;
(w_ode_2_1) - cos(w_ode_2_2) + cos(w_ode_2_3) + sin(x_4)*sin(x_1)*cos(x_4) + cos(ur_1)*sin(ur_1) = 0;

der(x_2) = sin(w_ode_2_1) - sin(w_ode_2_2) - sin(w_ode_2_3) + sin(w_ode_1_1) - sin(w_ode_1_2) - 4*(w_ode_1_3) + sin(x_1) + 4*(x_3) + (x_4) + (ur_2) + sin(ur_3);

4*(w_ode_3_1) - 4*(w_ode_3_2) + sin(w_ode_3_3) + (x_4) + cos(x_5) + 4*(x_3) + sin(ur_4)*cos(ur_1) = 0;
4*(w_ode_3_1) - (w_ode_3_2) + 4*(w_ode_3_3) + sin(x_2) - 4*(x_2) + (x_3) + 4*(ur_4) - 4*(ur_4) = 0;
4*(w_ode_3_1) + cos(w_ode_3_2)*cos(w_ode_3_3) + (x_3) + cos(x_2) + 4*(x_2) + cos(ur_1)*4*(ur_4) = 0;

der(x_3) = 4*(w_ode_3_1) - (w_ode_3_2)*(w_ode_3_3) + sin(w_ode_2_1) - cos(w_ode_2_2) - 4*(w_ode_2_3) + 4*(x_4) - 4*(x_2) - (x_2) + (ur_3)*4*(ur_4);

4*(w_ode_4_1)*(w_ode_4_2) - 4*(w_ode_4_3) + cos(x_1) - sin(x_2)*(x_2) + (ur_1) + 4*(ur_1) = 0;
4*(w_ode_4_1) + cos(w_ode_4_2) + sin(w_ode_4_3) + sin(x_2) + sin(x_4) + cos(x_3) + (ur_3) + sin(ur_2) = 0;
cos(w_ode_4_1)*sin(w_ode_4_2)*cos(w_ode_4_3) + cos(x_3) - cos(x_2) - (x_3) + (ur_3) - sin(ur_3) = 0;

der(x_4) = 4*(w_ode_4_1)*sin(w_ode_4_2)*4*(w_ode_4_3) + sin(w_ode_3_1) - (w_ode_3_2)*cos(w_ode_3_3) + cos(x_5) - (x_4) - (x_4) + (ur_1) + (ur_4);

4*(w_ode_5_1) + (w_ode_5_2)*(w_ode_5_3) + 4*(x_5) - 4*(x_4) + 4*(x_5) + (ur_3)*4*(ur_3) = 0;
(w_ode_5_1) + cos(w_ode_5_2)*(w_ode_5_3) + 4*(x_1) - sin(x_2) - sin(x_4) + cos(ur_2)*sin(ur_1) = 0;
cos(w_ode_5_1) + cos(w_ode_5_2)*cos(w_ode_5_3) + 4*(x_3) + (x_3)*4*(x_4) + cos(ur_3) + sin(ur_2) = 0;

der(x_5) = (w_ode_5_1) - sin(w_ode_5_2) + cos(w_ode_5_3) + 4*(w_ode_4_1) + cos(w_ode_4_2) - 4*(w_ode_4_3) + (x_3) - sin(x_2) + sin(x_2) + (ur_2)*sin(ur_4);

cos(w_output_1_1) - 4*(w_output_1_2)*cos(w_output_1_3) + sin(x_3)*4*(x_4) - (x_5) + cos(ur_1)*4*(ur_3) = 0;
(w_output_1_1) + sin(w_output_1_2) + cos(w_output_1_3) + 4*(x_5) + sin(x_5)*(x_2) + sin(ur_1) - cos(ur_4) = 0;
cos(w_output_1_1) + sin(w_output_1_2) - sin(w_output_1_3) + sin(x_2) - (x_3) + cos(x_5) + 4*(ur_1) + 4*(ur_4) = 0;

sin(w_output_2_1)*4*(w_output_2_2) + cos(w_output_2_3) + 4*(x_4)*cos(x_5) - (x_2) + cos(ur_2)*cos(ur_2) = 0;
(w_output_2_1) - cos(w_output_2_2) + 4*(w_output_2_3) + (x_4) + cos(x_1) - cos(x_5) + sin(ur_3) + (ur_2) = 0;
cos(w_output_2_1)*cos(w_output_2_2)*sin(w_output_2_3) + (x_2) - (x_2)*sin(x_5) + cos(ur_2)*sin(ur_2) = 0;

4*(w_output_3_1) + sin(w_output_3_2) + (w_output_3_3) + (x_4) - cos(x_4)*cos(x_1) + sin(ur_3) + cos(ur_1) = 0;
cos(w_output_3_1) + sin(w_output_3_2)*(w_output_3_3) + sin(x_5) - cos(x_5) - 4*(x_5) + 4*(ur_3) - cos(ur_2) = 0;
cos(w_output_3_1) + 4*(w_output_3_2) - sin(w_output_3_3) + cos(x_3) + cos(x_3) - sin(x_1) + 4*(ur_3) + 4*(ur_4) = 0;

cos(w_output_4_1) + sin(w_output_4_2) + (w_output_4_3) + 4*(x_3)*(x_5)*cos(x_2) + cos(ur_4) - 4*(ur_3) = 0;
4*(w_output_4_1)*sin(w_output_4_2)*sin(w_output_4_3) + (x_1) + sin(x_1)*cos(x_1) + sin(ur_2) - 4*(ur_3) = 0;
sin(w_output_4_1) + 4*(w_output_4_2)*sin(w_output_4_3) + (x_2) + (x_3)*(x_3) + (ur_2) + sin(ur_1) = 0;

(w_output_5_1) + (w_output_5_2) + sin(w_output_5_3) + sin(x_1)*(x_1) - sin(x_3) + (ur_1) + sin(ur_4) = 0;
(w_output_5_1) - sin(w_output_5_2) + (w_output_5_3) + sin(x_4)*sin(x_2) + sin(x_4) + sin(ur_4) + cos(ur_3) = 0;
4*(w_output_5_1) - (w_output_5_2) + (w_output_5_3) + cos(x_1)*(x_1)*sin(x_1) + 4*(ur_4) + sin(ur_4) = 0;

cos(w_output_6_1)*(w_output_6_2) + 4*(w_output_6_3) + cos(x_1)*(x_2)*cos(x_2) + 4*(ur_4) - sin(ur_3) = 0;
(w_output_6_1)*sin(w_output_6_2) + (w_output_6_3) + sin(x_4) - (x_4)*(x_4) + cos(ur_2) + (ur_4) = 0;
4*(w_output_6_1) - 4*(w_output_6_2)*sin(w_output_6_3) + sin(x_5) + sin(x_4)*(x_2) + (ur_3) - (ur_1) = 0;

(w_other_1_1) + cos(w_other_1_2) - (w_other_1_3) + cos(x_2) - 4*(x_5) - 4*(x_2) + (ur_3) + 4*(ur_1) = 0;
(w_other_1_1) + 4*(w_other_1_2) + 4*(w_other_1_3) + 4*(x_1) - cos(x_3)*4*(x_2) + sin(ur_2) + 4*(ur_3) = 0;
cos(w_other_1_1)*(w_other_1_2) - sin(w_other_1_3) + sin(x_4) + cos(x_1)*sin(x_2) + (ur_3) - 4*(ur_3) = 0;

sin(w_other_2_1) - (w_other_2_2) + (w_other_2_3) + 4*(x_5) - 4*(x_4) - sin(x_5) + 4*(ur_4) - 4*(ur_4) = 0;
sin(w_other_2_1)*4*(w_other_2_2) + 4*(w_other_2_3) + sin(x_1) - cos(x_1) + cos(x_4) + sin(ur_2)*cos(ur_2) = 0;
sin(w_other_2_1) + sin(w_other_2_2) - (w_other_2_3) + 4*(x_1)*4*(x_4) - (x_4) + cos(ur_2) - sin(ur_2) = 0;

4*(w_other_3_1) + sin(w_other_3_2)*4*(w_other_3_3) + (x_2) + cos(x_2) - (x_5) + 4*(ur_1) - 4*(ur_1) = 0;
4*(w_other_3_1)*(w_other_3_2) + (w_other_3_3) + cos(x_3) + sin(x_2) + 4*(x_1) + (ur_2) - cos(ur_2) = 0;
cos(w_other_3_1)*4*(w_other_3_2) + (w_other_3_3) + 4*(x_4) - sin(x_4) + (x_3) + 4*(ur_3) - cos(ur_4) = 0;


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="OutputTest1",
			description="Test of code generation of output value references.",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$n_outputs$
				   $C_DAE_output_vrefs$
",
         generatedCode=" 
30
static const int Output_vrefs[30] = {5,6,7,8,9,14,17,20,23,26,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,268435513,536870970};         
")})));
end OutputTest1;


model StartValues1
  Real x(start=1);
  parameter Real y = 2;
  parameter Real z(start=3);
  Real q;
  
equation
  der(x) = x;
  q = x + 1;


	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="StartValues1",
			description="",
			variability_propagation=false,
			template="$C_set_start_values$",
			generatedCode="
_y_1 = (2);
_z_2 = (3);
model_init_eval_parameters(jmi);
_x_0 = (1);
_q_3 = (0.0);
_der_x_4 = (0.0);
")})));
end StartValues1;

model StartValues2
  parameter Real pr = 1.5;
  parameter Integer pi = 2;
  parameter Boolean pb = true;
  
  Real r(start=5.5);
  Integer i(start=10); 
  Boolean b(start=false);
  
equation
  der(r) = -r;
  i = integer(r) + 2;
  b = false;
  

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="StartValues2",
			description="",
			variability_propagation=false,
			template="$C_set_start_values$",
			generatedCode="
    _pr_0 = (1.5);
    _pi_1 = (2);
    _pb_2 = (JMI_TRUE);
    model_init_eval_parameters(jmi);
    _r_3 = (5.5);
    _i_4 = (10);
    _b_5 = (JMI_FALSE);
    _temp_1_6 = (0);
    _der_r_10 = (0.0);
    pre_i_4 = (10);
    pre_b_5 = (JMI_FALSE);
    pre_temp_1_6 = (0);
")})));
end StartValues2;

model ExternalArray1
	Real a_in[2]={1,1};
	Real b_out;
	function f
		input Real a[2];
		output Real b;
		external;
	end f;
	equation
		b_out = f(a_in);


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray1",
            description="External C function (undeclared) with one dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArray1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_ExternalArray1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_ExternalArray1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    b_v = f(a_a->var, jmi_array_size(a_a, 0));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalArray1_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_ExternalArray1_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArray1;

model ExternalArray2
	Real a_in[2,2]={{1,1},{1,1}};
	Real b_out;
	function f
		input Real a[2,2];
		output Real b;
		external;
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray2",
            description="External C function (undeclared) with two dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArray2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_ExternalArray2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_ExternalArray2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    b_v = f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalArray2_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_ExternalArray2_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArray2;

model ExternalArray3
	Real a_in[2,2];
	Real b_out;
	function f
		input Real a[:,:];
		output Real b;
		external;
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray3",
            description="External C function (undeclared) with two dim and unknown no of elements array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArray3_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_ExternalArray3_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_ExternalArray3_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    b_v = f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalArray3_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_ExternalArray3_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArray3;

model ExternalArray4
	Real a_in[2];
	Real b_out[2];
	function f
		input Real a[2];
		output Real b[2];
		external;
	end f;
	equation
		a_in[1] = 1;
		a_in[2] = 2;
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray4",
            description="External C function (undeclared) with one dim array input, one dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_ExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 2, 1)
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    f(a_a->var, jmi_array_size(a_a, 0), b_a->var, jmi_array_size(b_a, 0));
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArray4;

model ExternalArray5
	Real a_in[2,2];
	Real b_out[2,2];
	function f
		input Real a[2,2];
		output Real b[2,2];
		external;
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray5",
            description="External C function (undeclared) with two dim array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArray5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_ExternalArray5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 4, 2)
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1), b_a->var, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1));
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArray5;

model ExternalArray6
	Real a_in[2,2];
	Real b_out[2,2];
	function f
		input Real a[:,:];
		output Real b[size(a,1),size(a,2)];
		external;
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArray6",
            description="External C function (undeclared) with two dim and unknown no of elements array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArray6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_ExternalArray6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, b_an, -1, 2)
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, b_an, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
        b_a = b_an;
    }
    f(a_a->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1), b_a->var, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1));
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArray6;

model IntegerExternalArray1
	Integer a_in[2]={1,1};
	Real b_out;
	function f
		input Integer a[2];
		output Real b;
		external;
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray1",
            description="External C function (undeclared) with one dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArray1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalArray1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_IntegerExternalArray1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1, 2)
    jmi_copy_matrix_to_int(a_a, a_a->var, tmp_1->var);
    b_v = f(tmp_1->var, jmi_array_size(a_a, 0));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalArray1_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalArray1_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end IntegerExternalArray1;

model IntegerExternalArray2
	Integer a_in[2,2]={{1,1},{1,1}};
	Real b_out;
	function f
		input Integer a[2,2];
		output Real b;
		external;
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray2",
            description="External C function (undeclared) with two dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArray2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalArray2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_IntegerExternalArray2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2)
    JMI_ARRAY_INIT_2(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2, 2, 2)
    jmi_copy_matrix_to_int(a_a, a_a->var, tmp_1->var);
    b_v = f(tmp_1->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalArray2_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalArray2_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end IntegerExternalArray2;

model IntegerExternalArray3
	discrete Real a_in = 1;
	Integer b_out[2];
	function f
		input Real a;
		output Integer b[2];
		external;
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray3",
            description="External C function (undeclared) with one scalar Real input, one dim array Integer output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArray3_f_def0(jmi_ad_var_t a_v, jmi_array_t* b_a);

void func_CCodeGenTests_IntegerExternalArray3_f_def0(jmi_ad_var_t a_v, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, b_an, 2, 1)
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1)
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_1(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1, 2)
    jmi_copy_matrix_to_int(b_a, b_a->var, tmp_1->var);
    f(a_v, tmp_1->var, jmi_array_size(b_a, 0));
    jmi_copy_matrix_from_int(b_a, tmp_1->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end IntegerExternalArray3;

model IntegerExternalArray4
	Integer a_in[2,2];
	Integer b_out[2,2];
	function f
		input Integer a[2,2];
		output Integer b[2,2];
		external;
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArray4",
            description="External C function (undeclared) with one 2-dim Integer array input, one 2-dim Integer array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_IntegerExternalArray4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, b_an, 4, 2)
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2)
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_2, 4, 2)
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STAT, jmi_ad_var_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2, 2, 2)
    jmi_copy_matrix_to_int(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(STAT, jmi_int_t, jmi_int_array_t, tmp_2, 4, 2, 2, 2)
    jmi_copy_matrix_to_int(b_a, b_a->var, tmp_2->var);
    f(tmp_1->var, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1), tmp_2->var, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1));
    jmi_copy_matrix_from_int(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end IntegerExternalArray4;

model SimpleExternalFortran1

	Real a_in=1;
	Real b_out;
	
	function f
		input Real a;
		output Real b;
		external "FORTRAN 77";
	end f;
	
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran1",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran1_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternalFortran1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    extern jmi_ad_var_t f_(jmi_ad_var_t*);
    b_v = f_(&a_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran1_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_SimpleExternalFortran1_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternalFortran1;

model SimpleExternalFortran2
	Real a_in=1;
	Real b_in=2;
	Real c_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		external "FORTRAN 77";
	end f;
	equation
		c_out = f(a_in, b_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran2",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran2_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternalFortran2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    extern jmi_ad_var_t f_(jmi_ad_var_t*, jmi_ad_var_t*);
    c_v = f_(&a_v, &b_v);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran2_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternalFortran2_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end SimpleExternalFortran2;

model SimpleExternalFortran3
	Real a_in=1;
	Real b_out;
	function f
		input Real a;
		output Real b;
		external "FORTRAN 77" b = my_f(a);
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran3",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran3_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternalFortran3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    extern jmi_ad_var_t my_f_(jmi_ad_var_t*);
    b_v = my_f_(&a_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran3_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_SimpleExternalFortran3_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternalFortran3;

model SimpleExternalFortran4
	Real a_in=1;
	Real b_out;
	function f
		input Real a;
		output Real b;
		external "FORTRAN 77" my_f(a, b);
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran4",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran4_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternalFortran4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    extern void my_f_(jmi_ad_var_t*, jmi_ad_var_t*);
    my_f_(&a_v, &b_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran4_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_SimpleExternalFortran4_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end SimpleExternalFortran4;

model SimpleExternalFortran5
	Real a_in=1;
	function f
		input Real a;
		external "FORTRAN 77";
	end f;
	equation
		f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran5",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran5_f_def0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternalFortran5_f_def0(jmi_ad_var_t a_v) {
    JMI_DYNAMIC_INIT()
    extern void f_(jmi_ad_var_t*);
    f_(&a_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end SimpleExternalFortran5;

model SimpleExternalFortran6
	Real a_in=1;
	function f
		input Real a;
		external "FORTRAN 77" my_f(a);
	end f;
	equation
		f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran6",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran6_f_def0(jmi_ad_var_t a_v);

void func_CCodeGenTests_SimpleExternalFortran6_f_def0(jmi_ad_var_t a_v) {
    JMI_DYNAMIC_INIT()
    extern void my_f_(jmi_ad_var_t*);
    my_f_(&a_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end SimpleExternalFortran6;

model SimpleExternalFortran7
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		external "FORTRAN 77" my_f(a,c,b);
	end f;
	equation
		c_out = f(a_in, b_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran7",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran7_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran7_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternalFortran7_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    extern void my_f_(jmi_ad_var_t*, jmi_ad_var_t*, jmi_ad_var_t*);
    my_f_(&a_v, &c_v, &b_v);
    if (c_o != NULL) *c_o = c_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran7_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternalFortran7_f_def0(a_v, b_v, &c_v);
    return c_v;
}

")})));
end SimpleExternalFortran7;

model SimpleExternalFortran8
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		output Real d;
		external "FORTRAN 77" my_f(a,c,b,d);
	end f;
	equation
		(c_out, d_out) = f(a_in, b_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran8",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran8_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran8_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternalFortran8_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    extern void my_f_(jmi_ad_var_t*, jmi_ad_var_t*, jmi_ad_var_t*, jmi_ad_var_t*);
    my_f_(&a_v, &c_v, &b_v, &d_v);
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran8_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternalFortran8_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end SimpleExternalFortran8;

model SimpleExternalFortran9
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		output Real d;
		external "FORTRAN 77" d = my_f(a,b,c);
	end f;
	equation
		(c_out, d_out) = f(a_in, b_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran9",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran9_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran9_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternalFortran9_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    extern jmi_ad_var_t my_f_(jmi_ad_var_t*, jmi_ad_var_t*, jmi_ad_var_t*);
    d_v = my_f_(&a_v, &b_v, &c_v);
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran9_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternalFortran9_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end SimpleExternalFortran9;

model SimpleExternalFortran10
	Real a_in = 1;
	Real b_in = 2;
	Real c_out;
	Real d_out;
	Real e_out;
	function f
		input Real a;
		input Real b;
		output Real c;
		output Real d;
		output Real e;
		external "FORTRAN 77" d = my_f(a,c,b,e);
	end f;
	equation
		(c_out, d_out, e_out) = f(a_in, b_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SimpleExternalFortran10",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_SimpleExternalFortran10_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o, jmi_ad_var_t* e_o);
jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran10_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_SimpleExternalFortran10_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o, jmi_ad_var_t* e_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    jmi_ad_var_t e_v;
    extern jmi_ad_var_t my_f_(jmi_ad_var_t*, jmi_ad_var_t*, jmi_ad_var_t*, jmi_ad_var_t*);
    d_v = my_f_(&a_v, &c_v, &b_v, &e_v);
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    if (e_o != NULL) *e_o = e_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_SimpleExternalFortran10_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_SimpleExternalFortran10_f_def0(a_v, b_v, &c_v, NULL, NULL);
    return c_v;
}

")})));
end SimpleExternalFortran10;

model IntegerExternalFortran1
	Integer a_in=1;
	Real b_out;
	function f
		input Integer a;
		output Real b;
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran1",
            description="External Fortran function, one scalar Integer input, one scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalFortran1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran1_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_IntegerExternalFortran1_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    jmi_int_t tmp_1;
    extern jmi_ad_var_t f_(jmi_int_t*);
    tmp_1 = (int)a_v;
    b_v = f_(&tmp_1);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran1_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalFortran1_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternalFortran1;

model IntegerExternalFortran2
	Integer a_in=1;
	Integer b_out;
	function f
		input Real a;
		output Integer b;
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran2",
            description="",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalFortran2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran2_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_IntegerExternalFortran2_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    extern jmi_int_t f_(jmi_ad_var_t*);
    b_v = f_(&a_v);
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran2_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalFortran2_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternalFortran2;

model IntegerExternalFortran3
	Integer a_in=1;
	Integer b_out;
	function f
		input Real a;
		output Integer b;
		external "FORTRAN 77" my_f(a, b);
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran3",
            description="External Fortran function (declared), one scalar Real input, one scalar Integer output in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalFortran3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran3_f_exp0(jmi_ad_var_t a_v);

void func_CCodeGenTests_IntegerExternalFortran3_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    jmi_int_t tmp_1;
    extern void my_f_(jmi_ad_var_t*, jmi_int_t*);
    tmp_1 = (int)b_v;
    my_f_(&a_v, &tmp_1);
    b_v = tmp_1;
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran3_f_exp0(jmi_ad_var_t a_v) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalFortran3_f_def0(a_v, &b_v);
    return b_v;
}

")})));
end IntegerExternalFortran3;

model IntegerExternalFortran4
	Integer a_in = 1;
	Integer b_in = 2;
	Integer c_out;
	Integer d_out;
	function f
		input Integer a;
		input Integer b;
		output Integer c;
		output Integer d;
		external "FORTRAN 77" d = my_f(a,b,c);
	end f;
	equation
		(c_out, d_out) = f(a_in, b_in);		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalFortran4",
            description="External Fortran function (declared), two scalar Integer inputs, two scalar Integer outputs (one in return, one in func stmt.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalFortran4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran4_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v);

void func_CCodeGenTests_IntegerExternalFortran4_f_def0(jmi_ad_var_t a_v, jmi_ad_var_t b_v, jmi_ad_var_t* c_o, jmi_ad_var_t* d_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t c_v;
    jmi_ad_var_t d_v;
    jmi_int_t tmp_1;
    jmi_int_t tmp_2;
    jmi_int_t tmp_3;
    extern jmi_int_t my_f_(jmi_int_t*, jmi_int_t*, jmi_int_t*);
    tmp_1 = (int)a_v;
    tmp_2 = (int)b_v;
    tmp_3 = (int)c_v;
    d_v = my_f_(&tmp_1, &tmp_2, &tmp_3);
    c_v = tmp_3;
    if (c_o != NULL) *c_o = c_v;
    if (d_o != NULL) *d_o = d_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalFortran4_f_exp0(jmi_ad_var_t a_v, jmi_ad_var_t b_v) {
    jmi_ad_var_t c_v;
    func_CCodeGenTests_IntegerExternalFortran4_f_def0(a_v, b_v, &c_v, NULL);
    return c_v;
}

")})));
end IntegerExternalFortran4;

model ExternalArrayFortran1
	Real a_in[2]={1,1};
	Real b_out;
	function f
		input Real a[2];
		output Real b;
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran1",
            description="External Fortan function with one dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_ExternalArrayFortran1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_ExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    extern jmi_ad_var_t f_(jmi_ad_var_t*, jmi_int_t*);
    b_v = f_(a_a->var, &jmi_array_size(a_a, 0));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalArrayFortran1_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_ExternalArrayFortran1_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArrayFortran1;

model ExternalArrayFortran2
	Real a_in[2,2]={{1,1},{1,1}};
	Real b_out;
	function f
		input Real a[2,2];
		output Real b;
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran2",
            description="External Fortan function with two dim array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_ExternalArrayFortran2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_ExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 4, 2)
    extern jmi_ad_var_t f_(jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    JMI_ARRAY_INIT_2(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 4, 2, 2, 2)
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalArrayFortran2_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_ExternalArrayFortran2_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArrayFortran2;

model ExternalArrayFortran3
	Real a_in[2,2];
	Real b_out;
	function f
		input Real a[:,:];
		output Real b;
		external "FORTRAN 77";
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran3",
            description="External Fortran function with two dim and unknown no of elements array input, scalar output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArrayFortran3_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_ExternalArrayFortran3_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_ExternalArrayFortran3_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 2)
    extern jmi_ad_var_t f_(jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_ExternalArrayFortran3_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_ExternalArrayFortran3_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end ExternalArrayFortran3;

model ExternalArrayFortran4
	Real a_in[2];
	Real b_out[2];
	function f
		input Real a[2];
		output Real b[2];
		external "FORTRAN 77";
	end f;
	equation
		a_in[1] = 1;
		a_in[2] = 2;
		b_out = f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran4",
            description="External Fortran function with one dim array input, one dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_ExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 2, 1)
    extern void f_(jmi_ad_var_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    f_(a_a->var, &jmi_array_size(a_a, 0), b_a->var, &jmi_array_size(b_a, 0));
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArrayFortran4;

model ExternalArrayFortran5
	Real a_in[2,2];
	Real b_out[2,2];
	function f
		input Real a[2,2];
		output Real b[2,2];
		external "FORTRAN 77";
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran5",
            description="External Fortran function with two dim array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArrayFortran5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_ExternalArrayFortran5_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 4, 2)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 4, 2)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 4, 2)
    extern void f_(jmi_ad_var_t*, jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STATREAL, jmi_ad_var_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 4, 2, 2, 2)
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 4, 2, 2, 2)
    jmi_matrix_to_fortran_real(b_a, b_a->var, tmp_2->var);
    f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1), tmp_2->var, &jmi_array_size(b_a, 0), &jmi_array_size(b_a, 1));
    jmi_matrix_from_fortran_real(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArrayFortran5;

model ExternalArrayFortran6
	Real a_in[2,2];
	Real b_out[2,2];
	function f
		input Real a[:,:];
		output Real b[size(a,1),size(a,2)];
		external "FORTRAN 77";
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);
		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalArrayFortran6",
            description="External Fortran function with two dim and unknown no of elements array input, two dim array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_ExternalArrayFortran6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_ExternalArrayFortran6_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, b_an, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 2)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_2, -1, 2)
    extern void f_(jmi_ad_var_t*, jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, b_an, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_1, jmi_array_size(a_a, 0) * jmi_array_size(a_a, 1), 2, jmi_array_size(a_a, 0), jmi_array_size(a_a, 1))
    jmi_matrix_to_fortran_real(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_2, jmi_array_size(b_a, 0) * jmi_array_size(b_a, 1), 2, jmi_array_size(b_a, 0), jmi_array_size(b_a, 1))
    jmi_matrix_to_fortran_real(b_a, b_a->var, tmp_2->var);
    f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1), tmp_2->var, &jmi_array_size(b_a, 0), &jmi_array_size(b_a, 1));
    jmi_matrix_from_fortran_real(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end ExternalArrayFortran6;

model IntegerExternalArrayFortran1
	Integer a_in[2]={1,1};
	Real b_out;
	function f
		input Integer a[2];
		output Real b;
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran1",
            description="External Fortran function (undeclared) with one dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalArrayFortran1_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_IntegerExternalArrayFortran1_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1)
    extern jmi_ad_var_t f_(jmi_int_t*, jmi_int_t*);
    JMI_ARRAY_INIT_1(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1, 2)
    jmi_matrix_to_fortran_int(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalArrayFortran1_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalArrayFortran1_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end IntegerExternalArrayFortran1;

model IntegerExternalArrayFortran2
	Integer a_in[2,2]={{1,1},{1,1}};
	Real b_out;
	function f
		input Integer a[2,2];
		output Real b;
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran2",
            description="External Fortran function (undeclared) with two dim Integer array input, scalar Real output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_IntegerExternalArrayFortran2_f_exp0(jmi_array_t* a_a);

void func_CCodeGenTests_IntegerExternalArrayFortran2_f_def0(jmi_array_t* a_a, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t b_v;
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2)
    extern jmi_ad_var_t f_(jmi_int_t*, jmi_int_t*, jmi_int_t*);
    JMI_ARRAY_INIT_2(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2, 2, 2)
    jmi_matrix_to_fortran_int(a_a, a_a->var, tmp_1->var);
    b_v = f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1));
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_IntegerExternalArrayFortran2_f_exp0(jmi_array_t* a_a) {
    jmi_ad_var_t b_v;
    func_CCodeGenTests_IntegerExternalArrayFortran2_f_def0(a_a, &b_v);
    return b_v;
}

")})));
end IntegerExternalArrayFortran2;

model IntegerExternalArrayFortran3
	Integer a_in = 1;
	Integer b_out[2];
	function f
		input Real a;
		output Integer b[2];
		external "FORTRAN 77";
	end f;
	equation
		b_out = f(a_in);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran3",
            description="External Fortran function (undeclared) with one scalar Real input, one dim array Integer output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArrayFortran3_f_def0(jmi_ad_var_t a_v, jmi_array_t* b_a);

void func_CCodeGenTests_IntegerExternalArrayFortran3_f_def0(jmi_ad_var_t a_v, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, b_an, 2, 1)
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1)
    extern void f_(jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, b_an, 2, 1, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_1(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 2, 1, 2)
    jmi_matrix_to_fortran_int(b_a, b_a->var, tmp_1->var);
    f_(&a_v, tmp_1->var, &jmi_array_size(b_a, 0));
    jmi_matrix_from_fortran_int(b_a, tmp_1->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end IntegerExternalArrayFortran3;

model IntegerExternalArrayFortran4
	Integer a_in[2,2];
	Integer b_out[2,2];
	function f
		input Integer a[2,2];
		output Integer b[2,2];
		external "FORTRAN 77";
	end f;
	equation
		a_in = {{1,1},{2,2}};
		b_out = f(a_in);		

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerExternalArrayFortran4",
            description="External Fortran function (undeclared) with one 2-dim Integer array input, one 2-dim Integer array output.",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_IntegerExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a);

void func_CCodeGenTests_IntegerExternalArrayFortran4_f_def0(jmi_array_t* a_a, jmi_array_t* b_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, b_an, 4, 2)
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2)
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_2, 4, 2)
    extern void f_(jmi_int_t*, jmi_int_t*, jmi_int_t*, jmi_int_t*, jmi_int_t*, jmi_int_t*);
    if (b_a == NULL) {
        JMI_ARRAY_INIT_2(STAT, jmi_ad_var_t, jmi_array_t, b_an, 4, 2, 2, 2)
        b_a = b_an;
    }
    JMI_ARRAY_INIT_2(STAT, jmi_int_t, jmi_int_array_t, tmp_1, 4, 2, 2, 2)
    jmi_matrix_to_fortran_int(a_a, a_a->var, tmp_1->var);
    JMI_ARRAY_INIT_2(STAT, jmi_int_t, jmi_int_array_t, tmp_2, 4, 2, 2, 2)
    jmi_matrix_to_fortran_int(b_a, b_a->var, tmp_2->var);
    f_(tmp_1->var, &jmi_array_size(a_a, 0), &jmi_array_size(a_a, 1), tmp_2->var, &jmi_array_size(b_a, 0), &jmi_array_size(b_a, 1));
    jmi_matrix_from_fortran_int(b_a, tmp_2->var, b_a->var);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end IntegerExternalArrayFortran4;

model Smooth1
  Real y = time - 2;
  Real x = smooth(0, if y < 0 then 0 else y ^ 3);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="Smooth1",
			description="",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = _time - 2 - (_y_0);
    (*res)[1] = (COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(0), (1.0 * (_y_0) * (_y_0) * (_y_0)))) - (_x_1);
")})));
end Smooth1;


model CFloor1
	parameter Real x = 2.4;
	Real y = floor(x);

	annotation(__JModelica(UnitTesting(tests={ 
		CCodeGenTestCase(
			name="CFloor1",
			description="C code generation for floor() operator",
			variability_propagation=false,
			generate_ode=false,
			generate_dae=true,
			template="$C_DAE_equation_residuals$",
			generatedCode="
    (*res)[0] = floor(_x_0) - (_y_1);
")})));
end CFloor1;


model TearingTest1
	
  Real u0,u1,u2,u3,uL;
  Real i0,i1,i2,i3,iL;
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real R3 = 1;
  parameter Real L = 1;
equation
  u0 = sin(time);
  u1 = R1*i1;
  u2 = R2*i2;
  u3 = R3*i3;
  uL = L*der(iL);
  u0 = u1 + u3;
  uL = u1 + u2;
  u2 = u3;
  i0 = i1 + iL;
  i1 = i2 + i3;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TearingTest1",
            description="Test code generation of torn blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            variability_propagation=false,
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 12;
        x[1] = 13;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _i2_6;
        x[1] = _i3_7;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        jmi_real_t* Q1 = calloc(6, sizeof(jmi_real_t));
        jmi_real_t* Q2 = calloc(6, sizeof(jmi_real_t));
        jmi_real_t* Q3 = residual;
        int i;
        char trans = 'N';
        double alpha = -1;
        double beta = 1;
        int n1 = 3;
        int n2 = 2;
        Q1[0] = -1.0;
        Q1[3] = -1.0;
        for (i = 0; i < 6; i += 3) {
            Q1[i + 0] = (Q1[i + 0]) / (1.0);
            Q1[i + 1] = (Q1[i + 1] - ((- _R1_9)) * Q1[i + 0]) / (1.0);
            Q1[i + 2] = (Q1[i + 2] - (-1.0) * Q1[i + 1]) / (-1.0);
        }
        Q2[4] = 1.0;
        Q2[5] = 1.0;
        memset(Q3, 0, 4 * sizeof(jmi_real_t));
        Q3[1] = (- _R2_10);
        Q3[2] = (- _R3_11);
        dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
        free(Q1);
        free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _i2_6 = x[0];
            _i3_7 = x[1];
        }
        _i1_5 = _i2_6 + _i3_7;
        _u1_1 = _R1_9 * _i1_5;
        _u2_2 = - (- _u0_0 + _u1_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _R3_11 * _i3_7 - (_u2_2);
            (*res)[1] = _R2_10 * _i2_6 - (_u2_2);
        }
    }
    return ef;
}

")})));
end TearingTest1;

model TearingTest2
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor(start=false);
 Boolean startBack(start=false);
 Integer mode(start=2);
 Real dummy;
equation 
 der(dummy) = 1;
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a;
 startFor = pre(mode)==2 and sa > 1;
 startBack = pre(mode) == 2 and sa < -1;
 a = if pre(mode) == 1 or startFor then sa-1 else 
     if pre(mode) == 3 or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == 1 or startFor then 
     f0 + f1*v else 
     if pre(mode) == 3 or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == 1 or startFor)
      and v>0 then 1 else 
      if (pre(mode) == 3 or startBack)
          and v<0 then 3 else 2;


    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TearingTest2",
            description="Test of code generation of torn mixed linear block",
            generate_ode=true,
            equation_sorting=true,
            variability_propagation=false,
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870925;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _sa_7;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        jmi_real_t* Q1 = calloc(3, sizeof(jmi_real_t));
        jmi_real_t* Q2 = calloc(3, sizeof(jmi_real_t));
        jmi_real_t* Q3 = residual;
        int i;
        char trans = 'N';
        double alpha = -1;
        double beta = 1;
        int n1 = 3;
        int n2 = 1;
        Q1[0] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(1.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(1.0), AD_WRAP_LITERAL(0)));
        Q1[2] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(0.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(0.0), _f0_1));
        for (i = 0; i < 3; i += 3) {
            Q1[i + 0] = (Q1[i + 0]) / (1.0);
            Q1[i + 1] = (Q1[i + 1] - (- 1.0) * Q1[i + 0]) / (1.0);
            Q1[i + 2] = (Q1[i + 2]) / (1.0);
        }
        Q2[1] = _m_0;
        Q2[2] = 1.0;
        memset(Q3, 0, 1 * sizeof(jmi_real_t));
        dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
        free(Q1);
        free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _sa_7 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(_sa_7 - (- 1), _sw(1), jmi->events_epsilon, JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_sa_7 - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        _a_4 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - AD_WRAP_LITERAL(1), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(0)));
        _der_v_16 = _a_4;
        _f_5 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7));
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _u_6 - _f_5 - (_m_0 * _der_v_16);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870926;
        x[1] = 536870925;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _sa_7;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        jmi_real_t* Q1 = calloc(3, sizeof(jmi_real_t));
        jmi_real_t* Q2 = calloc(3, sizeof(jmi_real_t));
        jmi_real_t* Q3 = residual;
        int i;
        char trans = 'N';
        double alpha = -1;
        double beta = 1;
        int n1 = 3;
        int n2 = 1;
        Q1[0] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(1.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(1.0), AD_WRAP_LITERAL(0)));
        Q1[2] = - COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, AD_WRAP_LITERAL(0.0), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, AD_WRAP_LITERAL(0.0), _f0_1));
        for (i = 0; i < 3; i += 3) {
            Q1[i + 0] = (Q1[i + 0]) / (1.0);
            Q1[i + 1] = (Q1[i + 1] - (- 1.0) * Q1[i + 0]) / (1.0);
            Q1[i + 2] = (Q1[i + 2]) / (1.0);
        }
        Q2[1] = _m_0;
        Q2[2] = 1.0;
        memset(Q3, 0, 1 * sizeof(jmi_real_t));
        dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
        free(Q1);
        free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _sa_7 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(_sa_7 - (- 1), _sw(1), jmi->events_epsilon, JMI_REL_LT);
            }
            _startBack_9 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(1));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_sa_7 - (1), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _startFor_8 = LOG_EXP_AND(COND_EXP_EQ(pre_mode_10, 2, JMI_TRUE, JMI_FALSE), _sw(0));
        }
        _a_4 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _sa_7 - AD_WRAP_LITERAL(1), COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, _sa_7 + AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(0)));
        _der_v_16 = _a_4;
        _f_5 = COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), _startFor_8), JMI_TRUE, _f0_1 + _f1_2 * _v_3, COND_EXP_EQ(LOG_EXP_OR(COND_EXP_EQ(pre_mode_10, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE), _startBack_9), JMI_TRUE, - _f0_1 + _f1_2 * _v_3, _f0_1 * _sa_7));
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _u_6 - _f_5 - (_m_0 * _der_v_16);
        }
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 1, 2, 2, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 1, 2, 2, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end TearingTest2;

model MapTearingTest1

  function F
    input Real x;
    input Integer[2] map;
    output Real y;
  algorithm
    y := x + 1;
  end F;
  Integer[2] map = {1,2};
  Real x, y;
equation
  x = y + 1;
  y = F(x, map);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="MapTearingTest1",
            description="Test code generation of torn blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1)
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _x_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _x_2 = x[0];
        }
        JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_ref_1(tmp_1, 1) = _map_1_0;
        jmi_array_ref_1(tmp_1, 2) = _map_2_1;
        _y_3 = func_CCodeGenTests_MapTearingTest1_F_exp0(_x_2, tmp_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _y_3 + 1 - (_x_2);
        }
    }
    return ef;
}

")})));
end MapTearingTest1;

model RecordTearingTest1
  function F
    input Real a;
    input Real b;
    output Real x;
    output Real y;
  algorithm
    x := a + b;
    y := a - b;
  end F;
  Real a;
  Real b;
  Real c;
  Real d;
  Real e;
  Real f;
equation
  (c,d) = F(a,b);
  (e,f) = F(c,d);
  (a,b) = F(e,f);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordTearingTest1",
            description="",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            variability_propagation=false,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_6;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 5;
        x[1] = 0;
        x[2] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _f_5;
        x[1] = _a_0;
        x[2] = _b_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _f_5 = x[0];
            _a_0 = x[1];
            _b_1 = x[2];
        }
        func_CCodeGenTests_RecordTearingTest1_F_def0(_a_0, _b_1, &tmp_1, &tmp_2);
        _c_2 = (tmp_1);
        _d_3 = (tmp_2);
        func_CCodeGenTests_RecordTearingTest1_F_def0(_c_2, _d_3, &tmp_3, &tmp_4);
        _e_4 = (tmp_3);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = tmp_4 - (_f_5);
            func_CCodeGenTests_RecordTearingTest1_F_def0(_e_4, _f_5, &tmp_5, &tmp_6);
            (*res)[1] = tmp_5 - (_a_0);
            (*res)[2] = tmp_6 - (_b_1);
        }
    }
    return ef;
}

")})));
end RecordTearingTest1;

model RecordTearingTest2
	function F
		input Real a;
		input Real b;
		output Real c;
		output Real d;
	algorithm
		c := a + b;
		d := c - a;
	end F;
	Real x,y;
	
	constant Real c1 = 23;
equation
	(c1, c1) = F(x,y);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="RecordTearingTest2",
            description="",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            inline_functions="none",
            template="$C_dae_blocks_residual_functions$",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
        x[1] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_1;
        x[1] = _x_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_1 = x[0];
            _x_0 = x[1];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            func_CCodeGenTests_RecordTearingTest2_F_def0(_x_0, _y_1, &tmp_1, &tmp_2);
            (*res)[0] = tmp_1 - (_c1_2);
            (*res)[1] = tmp_2 - (_c1_2);
        }
    }
    return ef;
}

")})));
end RecordTearingTest2;


model MathSolve
	Real a[2,2] = [1,2;3,4];
    Real b[2] = {-2,3};
	Real x[2];
equation
	x = Modelica.Math.Matrices.solve(a, b);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="MathSolve",
            description="Using MSL function Modelica.Math.Matrices.solve",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_Modelica_Math_Matrices_solve_def0(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a);
void func_Modelica_Math_Matrices_LAPACK_dgesv_vec_def1(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a, jmi_ad_var_t* info_o);

void func_Modelica_Math_Matrices_solve_def0(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, x_an, -1, 1)
    jmi_ad_var_t info_v;
    if (x_a == NULL) {
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, x_an, jmi_array_size(b_a, 0), 1, jmi_array_size(b_a, 0))
        x_a = x_an;
    }
    func_Modelica_Math_Matrices_LAPACK_dgesv_vec_def1(A_a, b_a, x_a, &info_v);
    if (COND_EXP_EQ(info_v, AD_WRAP_LITERAL(0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Solving a linear system of equations with function\\n\\\"Matrices.solve\\\" is not possible, because the system has either\\nno or infinitely many solutions (A is singular).\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_Modelica_Math_Matrices_LAPACK_dgesv_vec_def1(jmi_array_t* A_a, jmi_array_t* b_a, jmi_array_t* x_a, jmi_ad_var_t* info_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, x_an, -1, 1)
    jmi_ad_var_t info_v;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, Awork_a, -1, 2)
    jmi_ad_var_t lda_v;
    jmi_ad_var_t ldb_v;
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, ipiv_a, -1, 1)
    jmi_ad_var_t i1_0i;
    jmi_ad_var_t i1_0ie;
    jmi_ad_var_t i1_1i;
    jmi_ad_var_t i1_1ie;
    jmi_ad_var_t i2_2i;
    jmi_ad_var_t i2_2ie;
    jmi_int_t tmp_1;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_2, -1, 2)
    jmi_int_t tmp_3;
    JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_4, -1, 1)
    jmi_int_t tmp_5;
    jmi_int_t tmp_6;
    extern void dgesv_(jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    if (x_a == NULL) {
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, x_an, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
        x_a = x_an;
    }
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, Awork_a, jmi_array_size(A_a, 0) * jmi_array_size(A_a, 0), 2, jmi_array_size(A_a, 0), jmi_array_size(A_a, 0))
    JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, ipiv_a, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
    i1_0ie = jmi_array_size(A_a, 0) + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        jmi_array_ref_1(x_a, i1_0i) = jmi_array_val_1(b_a, i1_0i);
    }
    i1_1ie = jmi_array_size(A_a, 0) + 1 / 2.0;
    for (i1_1i = 1; i1_1i < i1_1ie; i1_1i += 1) {
        i2_2ie = jmi_array_size(A_a, 0) + 1 / 2.0;
        for (i2_2i = 1; i2_2i < i2_2ie; i2_2i += 1) {
            jmi_array_ref_2(Awork_a, i1_1i, i2_2i) = jmi_array_val_2(A_a, i1_1i, i2_2i);
        }
    }
    lda_v = jmi_max(AD_WRAP_LITERAL(1), jmi_array_size(A_a, 0));
    ldb_v = jmi_max(AD_WRAP_LITERAL(1), jmi_array_size(b_a, 0));
    tmp_1 = (int)1;
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_2, jmi_array_size(Awork_a, 0) * jmi_array_size(Awork_a, 1), 2, jmi_array_size(Awork_a, 0), jmi_array_size(Awork_a, 1))
    jmi_matrix_to_fortran_real(Awork_a, Awork_a->var, tmp_2->var);
    tmp_3 = (int)lda_v;
    JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_4, jmi_array_size(ipiv_a, 0), 1, jmi_array_size(ipiv_a, 0))
    jmi_matrix_to_fortran_int(ipiv_a, ipiv_a->var, tmp_4->var);
    tmp_5 = (int)ldb_v;
    tmp_6 = (int)info_v;
    dgesv_(&jmi_array_size(A_a, 0), &tmp_1, tmp_2->var, &tmp_3, tmp_4->var, x_a->var, &tmp_5, &tmp_6);
    info_v = tmp_6;
    if (info_o != NULL) *info_o = info_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end MathSolve;

model MathSolve2
	Real A[2,2] = [1,2;3,4];
	Real x_r[2] = {-2,3};
    Real b[2] = A*x_r;
    Real B[2,3] = [b, 2*b, -3*b];
    Real X[2,3];
equation
	X = Modelica.Math.Matrices.solve2(A, B);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="MathSolve2",
            description="Using MSL function Modelica.Math.Matrices.solve",
            variability_propagation=false,
            template="
$C_function_headers$
$C_functions$
",
            generatedCode="
void func_Modelica_Math_Matrices_solve2_def0(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a);
void func_Modelica_Math_Matrices_LAPACK_dgesv_def1(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a, jmi_ad_var_t* info_o);

void func_Modelica_Math_Matrices_solve2_def0(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, X_an, -1, 2)
    jmi_ad_var_t info_v;
    if (X_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, X_an, jmi_array_size(B_a, 0) * jmi_array_size(B_a, 1), 2, jmi_array_size(B_a, 0), jmi_array_size(B_a, 1))
        X_a = X_an;
    }
    func_Modelica_Math_Matrices_LAPACK_dgesv_def1(A_a, B_a, X_a, &info_v);
    if (COND_EXP_EQ(info_v, AD_WRAP_LITERAL(0), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"Solving a linear system of equations with function\\n\\\"Matrices.solve2\\\" is not possible, because the system has either\\nno or infinitely many solutions (A is singular).\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return;
}

void func_Modelica_Math_Matrices_LAPACK_dgesv_def1(jmi_array_t* A_a, jmi_array_t* B_a, jmi_array_t* X_a, jmi_ad_var_t* info_o) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, X_an, -1, 2)
    jmi_ad_var_t info_v;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, Awork_a, -1, 2)
    jmi_ad_var_t lda_v;
    jmi_ad_var_t ldb_v;
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, ipiv_a, -1, 1)
    jmi_ad_var_t i1_0i;
    jmi_ad_var_t i1_0ie;
    jmi_ad_var_t i2_1i;
    jmi_ad_var_t i2_1ie;
    jmi_ad_var_t i1_2i;
    jmi_ad_var_t i1_2ie;
    jmi_ad_var_t i2_3i;
    jmi_ad_var_t i2_3ie;
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 2)
    jmi_int_t tmp_2;
    JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_3, -1, 1)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_4, -1, 2)
    jmi_int_t tmp_5;
    jmi_int_t tmp_6;
    extern void dgesv_(jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);
    if (X_a == NULL) {
        JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, X_an, jmi_array_size(A_a, 0) * jmi_array_size(B_a, 1), 2, jmi_array_size(A_a, 0), jmi_array_size(B_a, 1))
        X_a = X_an;
    }
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, Awork_a, jmi_array_size(A_a, 0) * jmi_array_size(A_a, 0), 2, jmi_array_size(A_a, 0), jmi_array_size(A_a, 0))
    JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, ipiv_a, jmi_array_size(A_a, 0), 1, jmi_array_size(A_a, 0))
    i1_0ie = jmi_array_size(A_a, 0) + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        i2_1ie = jmi_array_size(B_a, 1) + 1 / 2.0;
        for (i2_1i = 1; i2_1i < i2_1ie; i2_1i += 1) {
            jmi_array_ref_2(X_a, i1_0i, i2_1i) = jmi_array_val_2(B_a, i1_0i, i2_1i);
        }
    }
    i1_2ie = jmi_array_size(A_a, 0) + 1 / 2.0;
    for (i1_2i = 1; i1_2i < i1_2ie; i1_2i += 1) {
        i2_3ie = jmi_array_size(A_a, 0) + 1 / 2.0;
        for (i2_3i = 1; i2_3i < i2_3ie; i2_3i += 1) {
            jmi_array_ref_2(Awork_a, i1_2i, i2_3i) = jmi_array_val_2(A_a, i1_2i, i2_3i);
        }
    }
    lda_v = jmi_max(AD_WRAP_LITERAL(1), jmi_array_size(A_a, 0));
    ldb_v = jmi_max(AD_WRAP_LITERAL(1), jmi_array_size(B_a, 0));
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_1, jmi_array_size(Awork_a, 0) * jmi_array_size(Awork_a, 1), 2, jmi_array_size(Awork_a, 0), jmi_array_size(Awork_a, 1))
    jmi_matrix_to_fortran_real(Awork_a, Awork_a->var, tmp_1->var);
    tmp_2 = (int)lda_v;
    JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_3, jmi_array_size(ipiv_a, 0), 1, jmi_array_size(ipiv_a, 0))
    jmi_matrix_to_fortran_int(ipiv_a, ipiv_a->var, tmp_3->var);
    JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_4, jmi_array_size(X_a, 0) * jmi_array_size(X_a, 1), 2, jmi_array_size(X_a, 0), jmi_array_size(X_a, 1))
    jmi_matrix_to_fortran_real(X_a, X_a->var, tmp_4->var);
    tmp_5 = (int)ldb_v;
    tmp_6 = (int)info_v;
    dgesv_(&jmi_array_size(A_a, 0), &jmi_array_size(B_a, 1), tmp_1->var, &tmp_2, tmp_3->var, tmp_4->var, &tmp_5, &tmp_6);
    jmi_matrix_from_fortran_real(X_a, tmp_4->var, X_a->var);
    info_v = tmp_6;
    if (info_o != NULL) *info_o = info_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end MathSolve2;

class ExtObject
	extends ExternalObject;
	
	function constructor
		output ExtObject eo;
		external "C" eo = init_myEO();
	end constructor;
	
	function destructor
		input ExtObject eo;
		external "C" close_myEO(eo);
	end destructor;
end ExtObject;

class ExtObjectwInput
    extends ExternalObject;
    
    function constructor
		input Real i;
        output ExtObjectwInput eo;
        external "C" eo = init_myEO(i);
    end constructor;
    
    function destructor
        input ExtObjectwInput eo;
        external "C" close_myEO(eo);
    end destructor;
end ExtObjectwInput;

function useMyEO
    input ExtObject eo;
    output Real r;
    external "C" r = useMyEO(eo);
end useMyEO;

function useMyEOI
    input ExtObjectwInput eo;
    output Real r;
    external "C" r = useMyEO(eo);
end useMyEOI;

model TestExtObject1
	ExtObject myEO = ExtObject();
	Real y;
equation
	y = useMyEO(myEO);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject1",
            description="",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="
$C_variable_aliases$
$C_function_headers$
$C_functions$
$C_destruct_external_object$
",
            generatedCode="
#define _y_1 ((*(jmi->z))[jmi->offs_real_w+0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define _myEO_0 ((jmi->ext_objs)[0])

void func_CCodeGenTests_ExtObject_destructor_def0(jmi_extobj_t eo_v);
void func_CCodeGenTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o);
jmi_extobj_t func_CCodeGenTests_ExtObject_constructor_exp1();
void func_CCodeGenTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_ad_var_t* r_o);
jmi_ad_var_t func_CCodeGenTests_useMyEO_exp2(jmi_extobj_t eo_v);

void func_CCodeGenTests_ExtObject_destructor_def0(jmi_extobj_t eo_v) {
    JMI_DYNAMIC_INIT()
    close_myEO(eo_v);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o) {
    JMI_DYNAMIC_INIT()
    jmi_extobj_t eo_v;
    eo_v = init_myEO();
    if (eo_o != NULL) *eo_o = eo_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_extobj_t func_CCodeGenTests_ExtObject_constructor_exp1() {
    jmi_extobj_t eo_v;
    func_CCodeGenTests_ExtObject_constructor_def1(&eo_v);
    return eo_v;
}

void func_CCodeGenTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_ad_var_t* r_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t r_v;
    r_v = useMyEO(eo_v);
    if (r_o != NULL) *r_o = r_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_useMyEO_exp2(jmi_extobj_t eo_v) {
    jmi_ad_var_t r_v;
    func_CCodeGenTests_useMyEO_def2(eo_v, &r_v);
    return r_v;
}


    if (_myEO_0 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEO_0);
        _myEO_0 = NULL;
    }
")})));
end TestExtObject1;

model TestExtObject2
    ExtObject myEO = ExtObject();
	ExtObject myEO2 = ExtObject();
    Real y;
equation
    y = useMyEO(myEO) + useMyEO(myEO2);	

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject2",
            description="",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="
$C_variable_aliases$
$C_function_headers$
$C_functions$
$C_destruct_external_object$
",
            generatedCode="
#define _y_2 ((*(jmi->z))[jmi->offs_real_w+0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define _myEO_0 ((jmi->ext_objs)[0])
#define _myEO2_1 ((jmi->ext_objs)[1])

void func_CCodeGenTests_ExtObject_destructor_def0(jmi_extobj_t eo_v);
void func_CCodeGenTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o);
jmi_extobj_t func_CCodeGenTests_ExtObject_constructor_exp1();
void func_CCodeGenTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_ad_var_t* r_o);
jmi_ad_var_t func_CCodeGenTests_useMyEO_exp2(jmi_extobj_t eo_v);

void func_CCodeGenTests_ExtObject_destructor_def0(jmi_extobj_t eo_v) {
    JMI_DYNAMIC_INIT()
    close_myEO(eo_v);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o) {
    JMI_DYNAMIC_INIT()
    jmi_extobj_t eo_v;
    eo_v = init_myEO();
    if (eo_o != NULL) *eo_o = eo_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_extobj_t func_CCodeGenTests_ExtObject_constructor_exp1() {
    jmi_extobj_t eo_v;
    func_CCodeGenTests_ExtObject_constructor_def1(&eo_v);
    return eo_v;
}

void func_CCodeGenTests_useMyEO_def2(jmi_extobj_t eo_v, jmi_ad_var_t* r_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t r_v;
    r_v = useMyEO(eo_v);
    if (r_o != NULL) *r_o = r_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_useMyEO_exp2(jmi_extobj_t eo_v) {
    jmi_ad_var_t r_v;
    func_CCodeGenTests_useMyEO_def2(eo_v, &r_v);
    return r_v;
}


    if (_myEO_0 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEO_0);
        _myEO_0 = NULL;
    }
    if (_myEO2_1 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEO2_1);
        _myEO2_1 = NULL;
    }
")})));
end TestExtObject2;

model TestExtObject3
    ExtObject myEO1 = ExtObject();
	ExtObject myEO2 = ExtObject();
	ExtObjectwInput myEO3 = ExtObjectwInput(z1);
	ExtObjectwInput myEO4 = ExtObjectwInput(z1);
    Real y1;
	Real y2;
	Real y3;
	Real y4;
	parameter Real z1 = 5;
equation
    y1 = useMyEO(myEO1);
	y2 = useMyEO(myEO2);
    y3 = useMyEOI(myEO3);
    y4 = useMyEOI(myEO4);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject3",
            description="",
            variability_propagation=false,
            template="
$C_set_start_values$
$C_DAE_initial_dependent_parameter_assignments$
$C_destruct_external_object$
",
            generatedCode="
    if (!jmi->indep_extobjs_initialized) { 
        _myEO1_0 = (func_CCodeGenTests_ExtObject_constructor_exp1());
    }
    if (!jmi->indep_extobjs_initialized) { 
        _myEO2_1 = (func_CCodeGenTests_ExtObject_constructor_exp1());
    }
    _z1_8 = (5);
    model_init_eval_parameters(jmi);
    _y1_4 = (0.0);
    _y2_5 = (0.0);
    _y3_6 = (0.0);
    _y4_7 = (0.0);
    jmi->indep_extobjs_initialized = 1;

    if (!jmi->dep_extobjs_initialized) { 
        _myEO3_2 = (func_CCodeGenTests_ExtObjectwInput_constructor_exp3(_z1_8));
    }
    if (!jmi->dep_extobjs_initialized) { 
        _myEO4_3 = (func_CCodeGenTests_ExtObjectwInput_constructor_exp3(_z1_8));
    }
    jmi->dep_extobjs_initialized = 1;

    if (_myEO1_0 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEO1_0);
        _myEO1_0 = NULL;
    }
    if (_myEO2_1 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEO2_1);
        _myEO2_1 = NULL;
    }
    if (_myEO3_2 != NULL) {
        func_CCodeGenTests_ExtObjectwInput_destructor_def2(_myEO3_2);
        _myEO3_2 = NULL;
    }
    if (_myEO4_3 != NULL) {
        func_CCodeGenTests_ExtObjectwInput_destructor_def2(_myEO4_3);
        _myEO4_3 = NULL;
    }
")})));
end TestExtObject3;


model TestExtObject4
	constant Integer N = 3;
	ExtObject myEOs[N] = fill(ExtObject(), N);
	Real y[N];
equation
	for i in 1:N loop
		y[i] = useMyEO(myEOs[i]);
	end for;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject4",
            description="Arrays of external objects",
            variability_propagation=false,
            template="$C_destruct_external_object$",
            generatedCode="
    if (_myEOs_1_1 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEOs_1_1);
        _myEOs_1_1 = NULL;
    }
    if (_myEOs_2_2 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEOs_2_2);
        _myEOs_2_2 = NULL;
    }
    if (_myEOs_3_3 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEOs_3_3);
        _myEOs_3_3 = NULL;
    }
")})));
end TestExtObject4;
    

model TestExtObject5
    ExtObject a = ExtObject();
    ExtObject b = a; 

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject5",
            description="Test that destructor calls are only generated for external objects with constructor calls",
            variability_propagation=false,
            template="$C_destruct_external_object$",
            generatedCode="
    if (_a_0 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_a_0);
        _a_0 = NULL;
    }
")})));
end TestExtObject5;


model TestExtObject6
    ExtObject eo1 = ExtObject();
    ExtObject myEOs[2] = { ExtObject(), eo1 };
    Real y[2];
equation
    for i in 1:2 loop
        y[i] = useMyEO(myEOs[i]);
    end for;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObject6",
            description="Test that destructor calls are only generated for external objects with constructor calls",
            variability_propagation=false,
            template="$C_destruct_external_object$",
            generatedCode="
    if (_eo1_0 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_eo1_0);
        _eo1_0 = NULL;
    }
    if (_myEOs_1_1 != NULL) {
        func_CCodeGenTests_ExtObject_destructor_def0(_myEOs_1_1);
        _myEOs_1_1 = NULL;
    }
")})));
end TestExtObject6;

model TestExtObjectArray1
    ExtObject myEOs[2] = { ExtObject(), ExtObject() };
    Real z;

 function get_y
    input ExtObject eos[:];
    output Real y;
 algorithm
    y := useMyEO(eos[1]);
 end get_y;
 
equation
    z = get_y(myEOs);    

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestExtObjectArray1",
            description="",
            template="
$C_variable_aliases$
$C_DAE_initial_dependent_parameter_assignments$
$C_functions$
",
            generatedCode="
#define _z_2 ((*(jmi->z))[jmi->offs_real_pd+0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define _myEOs_1_0 ((jmi->ext_objs)[0])
#define _myEOs_2_1 ((jmi->ext_objs)[1])

    JMI_ARR(STAT, jmi_extobj_t, jmi_extobj_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_extobj_t, jmi_extobj_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _myEOs_1_0;
    jmi_array_ref_1(tmp_1, 2) = _myEOs_2_1;
    _z_2 = (func_CCodeGenTests_TestExtObjectArray1_get_y_exp2(tmp_1));
    jmi->dep_extobjs_initialized = 1;

void func_CCodeGenTests_ExtObject_destructor_def0(jmi_extobj_t eo_v) {
    JMI_DYNAMIC_INIT()
    close_myEO(eo_v);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_ExtObject_constructor_def1(jmi_extobj_t* eo_o) {
    JMI_DYNAMIC_INIT()
    jmi_extobj_t eo_v;
    eo_v = init_myEO();
    if (eo_o != NULL) *eo_o = eo_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_extobj_t func_CCodeGenTests_ExtObject_constructor_exp1() {
    jmi_extobj_t eo_v;
    func_CCodeGenTests_ExtObject_constructor_def1(&eo_v);
    return eo_v;
}

void func_CCodeGenTests_TestExtObjectArray1_get_y_def2(jmi_extobj_array_t* eos_a, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = func_CCodeGenTests_useMyEO_exp3(jmi_array_val_1(eos_a, 1));
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestExtObjectArray1_get_y_exp2(jmi_extobj_array_t* eos_a) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_TestExtObjectArray1_get_y_def2(eos_a, &y_v);
    return y_v;
}

void func_CCodeGenTests_useMyEO_def3(jmi_extobj_t eo_v, jmi_ad_var_t* r_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t r_v;
    r_v = useMyEO(eo_v);
    if (r_o != NULL) *r_o = r_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_useMyEO_exp3(jmi_extobj_t eo_v) {
    jmi_ad_var_t r_v;
    func_CCodeGenTests_useMyEO_def3(eo_v, &r_v);
    return r_v;
}

")})));
end TestExtObjectArray1;

model TestRuntimeOptions1
    Real x = 1;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestRuntimeOptions1",
			description="Testing generation of runtime options map",
			generate_ode=true,
			generate_runtime_option_parameters=true,
			variability_propagation=false,
			cs_step_size=0.0011, // This is done to prevent nasty Java 6 bug: http://stackoverflow.com/a/14661106
			template="
$C_runtime_option_map$
$C_variable_aliases$
$C_set_start_values$
",
			generatedCode="
const char *fmi_runtime_options_map_names[] = {
    \"_block_jacobian_check\",
    \"_block_jacobian_check_tol\",
    \"_block_solver_experimental_mode\",
    \"_cs_rel_tol\",
    \"_cs_solver\",
    \"_cs_step_size\",
    \"_enforce_bounds\",
    \"_events_default_tol\",
    \"_events_tol_factor\",
    \"_iteration_variable_scaling\",
    \"_log_level\",
    \"_nle_solver_check_jac_cond\",
    \"_nle_solver_default_tol\",
    \"_nle_solver_max_iter\",
    \"_nle_solver_min_tol\",
    \"_nle_solver_regularization_tolerance\",
    \"_nle_solver_step_limit_factor\",
    \"_nle_solver_tol_factor\",
    \"_rescale_after_singular_jac\",
    \"_rescale_each_step\",
    \"_residual_equation_scaling\",
    \"_runtime_log_to_file\",
    \"_use_Brent_in_1d\",
    \"_use_jacobian_equilibration\",
    NULL
};

const int fmi_runtime_options_map_vrefs[] = {
    536870928, 0, 268435466, 1, 268435467, 2, 536870929, 3, 4, 268435468,
    268435469, 536870930, 5, 268435470, 6, 7, 8, 9, 536870931, 536870932,
    268435471, 536870933, 536870934, 536870935, 0
};

const int fmi_runtime_options_map_length = 24;
#define __block_jacobian_check_tol_2 ((*(jmi->z))[jmi->offs_real_pi+0])
#define __cs_rel_tol_4 ((*(jmi->z))[jmi->offs_real_pi+1])
#define __cs_step_size_6 ((*(jmi->z))[jmi->offs_real_pi+2])
#define __events_default_tol_8 ((*(jmi->z))[jmi->offs_real_pi+3])
#define __events_tol_factor_9 ((*(jmi->z))[jmi->offs_real_pi+4])
#define __nle_solver_default_tol_13 ((*(jmi->z))[jmi->offs_real_pi+5])
#define __nle_solver_min_tol_15 ((*(jmi->z))[jmi->offs_real_pi+6])
#define __nle_solver_regularization_tolerance_16 ((*(jmi->z))[jmi->offs_real_pi+7])
#define __nle_solver_step_limit_factor_17 ((*(jmi->z))[jmi->offs_real_pi+8])
#define __nle_solver_tol_factor_18 ((*(jmi->z))[jmi->offs_real_pi+9])
#define __block_solver_experimental_mode_3 ((*(jmi->z))[jmi->offs_integer_pi+0])
#define __cs_solver_5 ((*(jmi->z))[jmi->offs_integer_pi+1])
#define __iteration_variable_scaling_10 ((*(jmi->z))[jmi->offs_integer_pi+2])
#define __log_level_11 ((*(jmi->z))[jmi->offs_integer_pi+3])
#define __nle_solver_max_iter_14 ((*(jmi->z))[jmi->offs_integer_pi+4])
#define __residual_equation_scaling_21 ((*(jmi->z))[jmi->offs_integer_pi+5])
#define __block_jacobian_check_1 ((*(jmi->z))[jmi->offs_boolean_pi+0])
#define __enforce_bounds_7 ((*(jmi->z))[jmi->offs_boolean_pi+1])
#define __nle_solver_check_jac_cond_12 ((*(jmi->z))[jmi->offs_boolean_pi+2])
#define __rescale_after_singular_jac_19 ((*(jmi->z))[jmi->offs_boolean_pi+3])
#define __rescale_each_step_20 ((*(jmi->z))[jmi->offs_boolean_pi+4])
#define __runtime_log_to_file_22 ((*(jmi->z))[jmi->offs_boolean_pi+5])
#define __use_Brent_in_1d_23 ((*(jmi->z))[jmi->offs_boolean_pi+6])
#define __use_jacobian_equilibration_24 ((*(jmi->z))[jmi->offs_boolean_pi+7])
#define _x_0 ((*(jmi->z))[jmi->offs_real_w+0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define pre_x_0 ((*(jmi->z))[jmi->offs_pre_real_w+0])

    __block_jacobian_check_1 = (JMI_FALSE);
    __block_jacobian_check_tol_2 = (1.0E-6);
    __block_solver_experimental_mode_3 = (0);
    __cs_rel_tol_4 = (1.0E-6);
    __cs_solver_5 = (0);
    __cs_step_size_6 = (0.0011);
    __enforce_bounds_7 = (JMI_FALSE);
    __events_default_tol_8 = (1.0E-10);
    __events_tol_factor_9 = (1.0E-4);
    __iteration_variable_scaling_10 = (1);
    __log_level_11 = (3);
    __nle_solver_check_jac_cond_12 = (JMI_FALSE);
    __nle_solver_default_tol_13 = (1.0E-10);
    __nle_solver_max_iter_14 = (100);
    __nle_solver_min_tol_15 = (1.0E-12);
    __nle_solver_regularization_tolerance_16 = (-1.0);
    __nle_solver_step_limit_factor_17 = (10.0);
    __nle_solver_tol_factor_18 = (1.0E-4);
    __rescale_after_singular_jac_19 = (JMI_TRUE);
    __rescale_each_step_20 = (JMI_FALSE);
    __residual_equation_scaling_21 = (1);
    __runtime_log_to_file_22 = (JMI_FALSE);
    __use_Brent_in_1d_23 = (JMI_FALSE);
    __use_jacobian_equilibration_24 = (JMI_FALSE);
    model_init_eval_parameters(jmi);
    _x_0 = (0.0);
")})));
end TestRuntimeOptions1;



model TestEmptyArray1
	function f
		input Real d[:,:];
		output Real e;
	algorithm
		e := sum(size(d));
		e := e + 1;
	end f;
	
	parameter Real a[:, :] = fill(0.0,0,2);
	parameter Integer b[:] = 2:size(a, 2);
	parameter Boolean c = false;
	Real x = f(a);
	Real y = if c then a[1, b[1]] else 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestEmptyArray1",
            description="Test handling of empty arrays",
            variability_propagation=false,
            generate_ode=false,
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 0, 2)
    JMI_ARRAY_INIT_2(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 0, 2, 0, 2)
    (*res)[0] = func_CCodeGenTests_TestEmptyArray1_f_exp0(tmp_1) - (_x_2);
    (*res)[1] = 1 - (_y_3);
")})));
end TestEmptyArray1;

model VariableArrayIndex1
    Real table[:] = {42, 3.14};
    Integer i = if time > 1 then 1 else 2;
    Real x = table[i];

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="VariableArrayIndex1",
            description="Test of variable array index access",
            template="$C_functions$",
            generatedCode="
void func_temp_1_def0(jmi_ad_var_t i_0_v, jmi_array_t* x_a, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = jmi_array_val_1(x_a, i_0_v);
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_temp_1_exp0(jmi_ad_var_t i_0_v, jmi_array_t* x_a) {
    jmi_ad_var_t y_v;
    func_temp_1_def0(i_0_v, x_a, &y_v);
    return y_v;
}

")})));
end VariableArrayIndex1;


model TestRelationalOp1
Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
initial equation
 v1 = if time>=0 and time<=3 then 0 else 0;
 v2 = if time>0 then 0 else 0;
 v3 = if time<=0 and time <= 2 then 0 else 0;
 v4 = if time<0 then 0 else 0;
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = if y<=0 then 0 else 1;
 der(v2) = if y<0 then 0 else 1;
 der(v3) = if y>=0 then 0 else 1;
 der(v4) = if y>0 then 0 else 1;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestRelationalOp1",
			description="Test correct generation of all four relational operators",
			variability_propagation=false,
			template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
			generatedCode="
static const int N_initial_relations = 6;
static const int DAE_initial_relations[] = { JMI_REL_GEQ, JMI_REL_LEQ, JMI_REL_GT, JMI_REL_LEQ, JMI_REL_LEQ, JMI_REL_LT };
static const int N_relations = 4;
static const int DAE_relations[] = { JMI_REL_LEQ, JMI_REL_LT, JMI_REL_GEQ, JMI_REL_GT };
")})));
end TestRelationalOp1;

model TestRelationalOp2

Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = if y<=0 then 0 else 1;
 der(v2) = if y<0 then 0 else 1;
 der(v3) = if y>=0 then 0 else 1;
 der(v4) = if y>0 then 0 else 1;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestRelationalOp2",
			description="Test correct generation of all four relational operators",
			variability_propagation=false,
			template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
			generatedCode="
static const int N_initial_relations = 0;
static const int DAE_initial_relations[] = { -1 };
static const int N_relations = 4;
static const int DAE_relations[] = { JMI_REL_LEQ, JMI_REL_LT, JMI_REL_GEQ, JMI_REL_GT };
")})));
end TestRelationalOp2;

model TestRelationalOp3
Real v1(start=-1);
Real v2(start=-1);
Real v3(start=-1);
Real v4(start=-1);
Real y(start=1);
Integer i(start=0);
Boolean up(start=true);
initial equation
 v1 = if time>=0 and time<=3 then 0 else 0;
 v2 = if time>0 then 0 else 0;
 v3 = if time<=0 and time <= 2 then 0 else 0;
 v4 = if time<0 then 0 else 0;
equation
when sample(0.1,1) then
  i = if up then pre(i) + 1 else pre(i) - 1;
  up = if pre(i)==2 then false else if pre(i)==-2 then true else pre(up);
  y = i;
end when;
 der(v1) = y;
 der(v2) = y;
 der(v3) = y;
 der(v4) = y;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestRelationalOp3",
			description="Test generation of all four relational operators.",
			variability_propagation=false,
			template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
			generatedCode="
static const int N_initial_relations = 6;
static const int DAE_initial_relations[] = { JMI_REL_GEQ, JMI_REL_LEQ, JMI_REL_GT, JMI_REL_LEQ, JMI_REL_LEQ, JMI_REL_LT };
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };
")})));
end TestRelationalOp3;

model TestRelationalOp4
  parameter Real p1 = 1;
  parameter Real p2 = if p1 >=1 then 1 else 2;
  Real x;
  Real y;
  Real z;
  Real w;
  Real r;
  discrete Real q1;
  discrete Real q2;
initial equation
  x = if time>=4 then 1 else 2;
  y = if noEvent(time>=2) then 2 else 5;
  z = if p1<=5 then 1 else 6;
equation
  der(x) = if time>=1 then 1 else 0; 
  der(y) = if noEvent(time>=1) then 1 else 0; 
  der(z) = if p1>=1 then 1 else 0; 
  der(w) = if 2>=1 then 1 else 0; 
  der(r) = if y>=3 then 1.0 else 0.0; 
  when x>=0.1 then 
    q1 = if pre(q1)>=0.5 then pre(q1) else 2*pre(q1);
    q2 = if w>=0.5 then pre(q2) else 2*pre(q2); 
  end when;

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestRelationalOp4",
			description="Test correct event generation.",
			variability_propagation=false,
			template="
$C_DAE_initial_relations$
$C_DAE_relations$
",
			generatedCode="
static const int N_initial_relations = 1;
static const int DAE_initial_relations[] = { JMI_REL_GEQ };
static const int N_relations = 5;
static const int DAE_relations[] = { JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ, JMI_REL_GEQ };
")})));
end TestRelationalOp4;

model TestRelationalOp5
  Real x;
  Real y;
  Real z;
equation
  der(x) = smooth(0,if x>=0 then x else 0); 
  der(y) = smooth(1,if y>=0 then y^2 else 0); 
  der(z) = smooth(2,if z>=0 then z^3 else 0); 

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestRelationalOp5",
			description="Test correct event generation in smooth operators.",
			generate_ode=true,
			equation_sorting=true,
			variability_propagation=false,
			template="
$C_DAE_initial_relations$
$C_DAE_relations$
$C_ode_derivatives$
",
			generatedCode="
static const int N_initial_relations = 0;
static const int DAE_initial_relations[] = { -1 };
static const int N_relations = 1;
static const int DAE_relations[] = { JMI_REL_GEQ };
    model_ode_guards(jmi);
/************* ODE section *********/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(0)), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _der_x_3 = (COND_EXP_EQ(_sw(0), JMI_TRUE, _x_0, AD_WRAP_LITERAL(0)));
    _der_y_4 = (COND_EXP_EQ(COND_EXP_GE(_y_1, AD_WRAP_LITERAL(0), JMI_TRUE, JMI_FALSE), JMI_TRUE, (1.0 * (_y_1) * (_y_1)), AD_WRAP_LITERAL(0)));
    _der_z_5 = (COND_EXP_EQ(COND_EXP_GE(_z_2, AD_WRAP_LITERAL(0), JMI_TRUE, JMI_FALSE), JMI_TRUE, (1.0 * (_z_2) * (_z_2) * (_z_2)), AD_WRAP_LITERAL(0)));
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
/********* Write back reinits *******/
")})));
end TestRelationalOp5;

model TestRelationalOp6
	type E = enumeration(a, b);
	parameter Real x = 3.14;
	E a = if x > 3 then E.a else E.b;
	E b = if x > 3 then E.b else E.a;
equation
	assert(String(a) < String(b), "Assertion error, " + String(a) + " < " + String(b));
	assert(String(b) > String(a), "Assertion error, " + String(b) + " > " + String(a));
	assert(String(a) == String(a), "Assertion error, " + String(a) + " == " + String(a));
	assert(String(a) <= String(b), "Assertion error, " + String(a) + " <= " + String(b));
	assert(String(a) <= String(a), "Assertion error, " + String(a) + " <= " + String(a));
	assert(String(b) >= String(a), "Assertion error, " + String(b) + " >= " + String(a));
	assert(String(a) >= String(a), "Assertion error, " + String(a) + " >= " + String(a));
	assert(String(a) <> String(b), "Assertion error, " + String(a) + " <> " + String(b));
	assert(String(b) <> String(a), "Assertion error, " + String(b) + " <> " + String(a));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp6",
            description="Test generation of relational operators when comparing strings.",
            generate_dae=true,
            template="$C_DAE_equation_residuals$",
            generatedCode="
    JMI_DEF_STR_STAT(tmp_1, 1)
    JMI_DEF_STR_STAT(tmp_2, 1)
    JMI_DEF_STR_STAT(tmp_3, 1)
    JMI_DEF_STR_STAT(tmp_4, 1)
    JMI_DEF_STR_STAT(tmp_5, 1)
    JMI_DEF_STR_STAT(tmp_6, 1)
    JMI_DEF_STR_STAT(tmp_7, 1)
    JMI_DEF_STR_STAT(tmp_8, 1)
    JMI_DEF_STR_STAT(tmp_9, 1)
    JMI_DEF_STR_STAT(tmp_10, 1)
    JMI_DEF_STR_STAT(tmp_11, 1)
    JMI_DEF_STR_STAT(tmp_12, 1)
    JMI_DEF_STR_STAT(tmp_13, 1)
    JMI_DEF_STR_STAT(tmp_14, 1)
    JMI_DEF_STR_STAT(tmp_15, 1)
    JMI_DEF_STR_STAT(tmp_16, 1)
    JMI_DEF_STR_STAT(tmp_17, 1)
    JMI_DEF_STR_STAT(tmp_18, 1)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%-s\", E_0_e[(int) _b_2]);
    if (strcmp(tmp_1, tmp_2) < 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_19, 22)
        JMI_INI_STR_STAT(tmp_19)
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%s\", \" < \");
        snprintf(JMI_STR_END(tmp_19), JMI_STR_LEFT(tmp_19), \"%-s\", E_0_e[(int) _b_2]);
        jmi_assert_failed(tmp_19, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_3)
    snprintf(JMI_STR_END(tmp_3), JMI_STR_LEFT(tmp_3), \"%-s\", E_0_e[(int) _b_2]);
    JMI_INI_STR_STAT(tmp_4)
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_3, tmp_4) > 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_20, 22)
        JMI_INI_STR_STAT(tmp_20)
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%-s\", E_0_e[(int) _b_2]);
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%s\", \" > \");
        snprintf(JMI_STR_END(tmp_20), JMI_STR_LEFT(tmp_20), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_20, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_5)
    snprintf(JMI_STR_END(tmp_5), JMI_STR_LEFT(tmp_5), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_6)
    snprintf(JMI_STR_END(tmp_6), JMI_STR_LEFT(tmp_6), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_5, tmp_6) == 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_21, 23)
        JMI_INI_STR_STAT(tmp_21)
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%s\", \" == \");
        snprintf(JMI_STR_END(tmp_21), JMI_STR_LEFT(tmp_21), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_21, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_7)
    snprintf(JMI_STR_END(tmp_7), JMI_STR_LEFT(tmp_7), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_8)
    snprintf(JMI_STR_END(tmp_8), JMI_STR_LEFT(tmp_8), \"%-s\", E_0_e[(int) _b_2]);
    if (strcmp(tmp_7, tmp_8) <= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_22, 23)
        JMI_INI_STR_STAT(tmp_22)
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%s\", \" <= \");
        snprintf(JMI_STR_END(tmp_22), JMI_STR_LEFT(tmp_22), \"%-s\", E_0_e[(int) _b_2]);
        jmi_assert_failed(tmp_22, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_9)
    snprintf(JMI_STR_END(tmp_9), JMI_STR_LEFT(tmp_9), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_10)
    snprintf(JMI_STR_END(tmp_10), JMI_STR_LEFT(tmp_10), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_9, tmp_10) <= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_23, 23)
        JMI_INI_STR_STAT(tmp_23)
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%s\", \" <= \");
        snprintf(JMI_STR_END(tmp_23), JMI_STR_LEFT(tmp_23), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_23, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_11)
    snprintf(JMI_STR_END(tmp_11), JMI_STR_LEFT(tmp_11), \"%-s\", E_0_e[(int) _b_2]);
    JMI_INI_STR_STAT(tmp_12)
    snprintf(JMI_STR_END(tmp_12), JMI_STR_LEFT(tmp_12), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_11, tmp_12) >= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_24, 23)
        JMI_INI_STR_STAT(tmp_24)
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%-s\", E_0_e[(int) _b_2]);
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%s\", \" >= \");
        snprintf(JMI_STR_END(tmp_24), JMI_STR_LEFT(tmp_24), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_24, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_13)
    snprintf(JMI_STR_END(tmp_13), JMI_STR_LEFT(tmp_13), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_14)
    snprintf(JMI_STR_END(tmp_14), JMI_STR_LEFT(tmp_14), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_13, tmp_14) >= 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_25, 23)
        JMI_INI_STR_STAT(tmp_25)
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%s\", \" >= \");
        snprintf(JMI_STR_END(tmp_25), JMI_STR_LEFT(tmp_25), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_25, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_15)
    snprintf(JMI_STR_END(tmp_15), JMI_STR_LEFT(tmp_15), \"%-s\", E_0_e[(int) _a_1]);
    JMI_INI_STR_STAT(tmp_16)
    snprintf(JMI_STR_END(tmp_16), JMI_STR_LEFT(tmp_16), \"%-s\", E_0_e[(int) _b_2]);
    if (strcmp(tmp_15, tmp_16) != 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_26, 23)
        JMI_INI_STR_STAT(tmp_26)
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%-s\", E_0_e[(int) _a_1]);
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%s\", \" <> \");
        snprintf(JMI_STR_END(tmp_26), JMI_STR_LEFT(tmp_26), \"%-s\", E_0_e[(int) _b_2]);
        jmi_assert_failed(tmp_26, JMI_ASSERT_ERROR);
    }
    JMI_INI_STR_STAT(tmp_17)
    snprintf(JMI_STR_END(tmp_17), JMI_STR_LEFT(tmp_17), \"%-s\", E_0_e[(int) _b_2]);
    JMI_INI_STR_STAT(tmp_18)
    snprintf(JMI_STR_END(tmp_18), JMI_STR_LEFT(tmp_18), \"%-s\", E_0_e[(int) _a_1]);
    if (strcmp(tmp_17, tmp_18) != 0 == JMI_FALSE) {
        JMI_DEF_STR_STAT(tmp_27, 23)
        JMI_INI_STR_STAT(tmp_27)
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%s\", \"Assertion error, \");
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%-s\", E_0_e[(int) _b_2]);
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%s\", \" <> \");
        snprintf(JMI_STR_END(tmp_27), JMI_STR_LEFT(tmp_27), \"%-s\", E_0_e[(int) _a_1]);
        jmi_assert_failed(tmp_27, JMI_ASSERT_ERROR);
    }
")})));
end TestRelationalOp6;

model TestRelationalOp7
    function f
        input Real[:] x;
        output Real y = sum(x);
      algorithm
    end f;
    
    Real y1,y2;
  initial equation
    y1 = integer(f({y1}));
    y2 = integer(f({y2}));
  equation
    when time > f({pre(y1)}) then
        y1 = 1;
    end when;
    when time > f({pre(y2)}) then
        y2 = 1;
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestRelationalOp7",
            description="Test generation of temps in relational operators.",
            
            template="
$C_DAE_event_indicator_residuals$
$C_DAE_initial_event_indicator_residuals$
",
            generatedCode="
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_ref_1(tmp_1, 1) = pre_y1_0;
    (*res)[0] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_ref_1(tmp_2, 1) = pre_y2_1;
    (*res)[1] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_2));

    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 1, 1)
    JMI_ARR(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_1, 1, 1, 1)
    jmi_array_ref_1(tmp_1, 1) = pre_y1_0;
    (*res)[0] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_1));
    JMI_ARRAY_INIT_1(STATREAL, jmi_ad_var_t, jmi_array_t, tmp_2, 1, 1, 1)
    jmi_array_ref_1(tmp_2, 1) = pre_y2_1;
    (*res)[1] = _time - (func_CCodeGenTests_TestRelationalOp7_f_exp0(tmp_2));
")})));

end TestRelationalOp7;

model StringOperations1
	type E = enumeration(a, bb, ccc);
	
	function f
		input String x;
		output Real y;
	algorithm
		y := 1;
	end f;
	
	Real r = time;
	Boolean b = r < 2;
	E e = if b then E.bb else E.ccc;
	Integer i = Integer(e);
	Real dummy = f("x " + String(r) + " y " + String(b) + " z " + String(e) + " v " + String(i) + " w");

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations1",
            description="Basic test of string concatenation and the String() operator, variable values",
            inline_functions="none",
            template="
$C_enum_strings$
$C_ode_derivatives$
",
            generatedCode="
char* E_0_e[] = { \"\", \"a\", \"bb\", \"ccc\" };

    JMI_DEF_STR_STAT(tmp_1, 44)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _r_0 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_r_0 - (2), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    _b_1 = _sw(0);
    _e_2 = COND_EXP_EQ(_b_1, JMI_TRUE, AD_WRAP_LITERAL(2), AD_WRAP_LITERAL(3));
    _i_3 = (_e_2);
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"x \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _r_0);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" y \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-s\", COND_EXP_EQ(_b_1, JMI_TRUE, \"true\", \"false\"));
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" z \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-s\", E_0_e[(int) _e_2]);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" v \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-d\", (int) _i_3);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \" w\");
    _dummy_4 = func_CCodeGenTests_StringOperations1_f_exp0(tmp_1);
/********* Write back reinits *******/
")})));
end StringOperations1;


model StringOperations2
    type E = enumeration(a, bb, ccc);
    
    function f
        input String x;
        output Real y;
    algorithm
        y := 1;
    end f;
    
    Real dummy = f("x " + String(0.1234567) + " y " + String(true) + " z " + String(E.a) + " v " + String(42) + " w " + String(time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations2",
            description="Basic test of string concatenation and the String() operator, constant values",
            inline_functions="none",
            template="
$C_enum_strings$
$C_ode_derivatives$
",
            generatedCode="
char* E_0_e[] = { \"\", \"a\", \"bb\", \"ccc\" };

    JMI_DEF_STR_STAT(tmp_1, 42)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"x 0.123457 y true z a v 42 w \");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    _dummy_0 = func_CCodeGenTests_StringOperations2_f_exp0(tmp_1);
/********* Write back reinits *******/
")})));
end StringOperations2;


model StringOperations3
    type E = enumeration(a, bb, ccc);
    
    function f
        input String x;
        output Real y;
    algorithm
        y := 1;
    end f;
    
    constant String s = "x " + String(0.1234567) + " y " + String(true) + " z " + String(E.a) + " v " + String(42) + " w";
	Real dummy = f(s);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations3",
            description="Basic test of string concatenation and the String() operator, constant evaluation",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_enum_strings$
$C_ode_derivatives$
",
            generatedCode="
char* E_0_e[] = { \"\", \"a\", \"bb\", \"ccc\" };

    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _dummy_1 = func_CCodeGenTests_StringOperations3_f_exp0(\"x 0.123457 y true z a v 42 w\");
/********* Write back reinits *******/
")})));
end StringOperations3;


model StringOperations4
    function f
        input String s;
        output Real x;
    algorithm
        x := 1;
        f(s + "123");
    end f;
    
    Real y = f("abc" + String(time));

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations4",
            description="Basic test of string concatenation and the String() operator, using function inputs",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
void func_CCodeGenTests_StringOperations4_f_def0(jmi_string_t s_v, jmi_ad_var_t* x_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t x_v;
    JMI_DEF_STR_DYNA(tmp_1)
    x_v = 1;
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(s_v) + 3)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", s_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"123\");
    func_CCodeGenTests_StringOperations4_f_def0(tmp_1, NULL);
    JMI_FREE(tmp_1)
    if (x_o != NULL) *x_o = x_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations4_f_exp0(jmi_string_t s_v) {
    jmi_ad_var_t x_v;
    func_CCodeGenTests_StringOperations4_f_def0(s_v, &x_v);
    return x_v;
}


    JMI_DEF_STR_STAT(tmp_1, 16)
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", \"abc\");
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    _y_0 = func_CCodeGenTests_StringOperations4_f_exp0(tmp_1);
/********* Write back reinits *******/
")})));
end StringOperations4;

model StringOperations5
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        s := "str";
        s := s;
        t := s;
        s := t + s;
    end f2;
    
    Real y = f2(-time);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations5",
            description="Basic test of string assignments",
            inline_functions="none",
            variability_propagation=false,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_StringOperations5_f2_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_DEF_STR_DYNA(s_v)
    JMI_DEF_STR_DYNA(t_v)
    JMI_DEF_STR_DYNA(tmp_1)
    y_v = x_v;
    JMI_ASG(STR, s_v, \"str\")
    JMI_ASG(STR, s_v, s_v)
    JMI_ASG(STR, t_v, s_v)
    JMI_INI_STR_DYNA(tmp_1, JMI_LEN(t_v) + JMI_LEN(s_v))
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", t_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%s\", s_v);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_FREE(tmp_1)
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations5_f2_exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations5_f2_def0(x_v, &y_v);
    return y_v;
}

")})));
end StringOperations5;

model StringOperations6
    function f1
        input String s;
        output String o;
        output Integer i;
      algorithm
        o := s;
        i := 1;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        s := "str";
        s := f1(s);
    end f2;
    
    Real y = f2(-time);
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations6",
            description="String return value in function call",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_StringOperations6_f2_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_DEF_STR_DYNA(s_v)
    JMI_DEF_STR_DYNA(t_v)
    JMI_DEF_STR_DYNA(tmp_1)
    y_v = x_v;
    JMI_ASG(STR, s_v, \"str\")
    tmp_1 = func_CCodeGenTests_StringOperations6_f1_exp1(s_v);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_FREE(tmp_1)
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations6_f2_exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations6_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations6_f1_def1(jmi_string_t s_v, jmi_string_t* o_o, jmi_ad_var_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(o_v)
    jmi_ad_var_t i_v;
    JMI_ASG(STR, o_v, s_v)
    i_v = 1;
    JMI_RET(STR, o_o, o_v)
    if (i_o != NULL) *i_o = i_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenTests_StringOperations6_f1_exp1(jmi_string_t s_v) {
    JMI_DEF_STR_DYNA(o_v)
    func_CCodeGenTests_StringOperations6_f1_def1(s_v, &o_v, NULL);
    return o_v;
}

")})));
end StringOperations6;

model StringOperations7
    function f1
        input String s;
        output String o;
        output Integer i;
      algorithm
        o := s;
        i := 1;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        s := "str";
        (s,) := f1(s);
    end f2;
    
    Real y = f2(-time);
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations7",
            description="String return value in function call assignment",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_StringOperations7_f2_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_DEF_STR_DYNA(s_v)
    JMI_DEF_STR_DYNA(t_v)
    JMI_DEF_STR_DYNA(tmp_1)
    y_v = x_v;
    JMI_ASG(STR, s_v, \"str\")
    func_CCodeGenTests_StringOperations7_f1_def1(s_v, &tmp_1, NULL);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_FREE(tmp_1)
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations7_f2_exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations7_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations7_f1_def1(jmi_string_t s_v, jmi_string_t* o_o, jmi_ad_var_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(o_v)
    jmi_ad_var_t i_v;
    JMI_ASG(STR, o_v, s_v)
    i_v = 1;
    JMI_RET(STR, o_o, o_v)
    if (i_o != NULL) *i_o = i_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenTests_StringOperations7_f1_exp1(jmi_string_t s_v) {
    JMI_DEF_STR_DYNA(o_v)
    func_CCodeGenTests_StringOperations7_f1_def1(s_v, &o_v, NULL);
    return o_v;
}

")})));
end StringOperations7;

model StringOperations8
    function f1
        input String s;
        output String o;
        output Integer i;
      algorithm
        o := s;
        i := 1;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String s;
        String t;
      algorithm
        y := x;
        (s,) := f1("| " + f1(String(x)) + " ^_^ " + String(x) + " |");
        Modelica.Utilities.Streams.print(s);
    end f2;
    
    Real y = f2(-time);
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations8",
            description="String operator combinations",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_StringOperations8_f2_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_DEF_STR_DYNA(s_v)
    JMI_DEF_STR_DYNA(t_v)
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_DEF_STR_STAT(tmp_2, 13)
    JMI_DEF_STR_DYNA(tmp_3)
    JMI_DEF_STR_DYNA(tmp_4)
    y_v = x_v;
    JMI_INI_STR_STAT(tmp_2)
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%-.*g\", (int) 6, x_v);
    tmp_3 = func_CCodeGenTests_StringOperations8_f1_exp1(tmp_2);
    JMI_INI_STR_DYNA(tmp_4, 2 + JMI_LEN(tmp_3) + 5 + 7 + 6 + 2)
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", \"| \");
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", tmp_3);
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", \" ^_^ \");
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%-.*g\", (int) 6, x_v);
    snprintf(JMI_STR_END(tmp_4), JMI_STR_LEFT(tmp_4), \"%s\", \" |\");
    func_CCodeGenTests_StringOperations8_f1_def1(tmp_4, &tmp_1, NULL);
    JMI_ASG(STR, s_v, tmp_1)
    JMI_FREE(tmp_1)
    JMI_FREE(tmp_3)
    JMI_FREE(tmp_4)
    func_Modelica_Utilities_Streams_print_def2(s_v, \"\");
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations8_f2_exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations8_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations8_f1_def1(jmi_string_t s_v, jmi_string_t* o_o, jmi_ad_var_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_DYNA(o_v)
    jmi_ad_var_t i_v;
    JMI_ASG(STR, o_v, s_v)
    i_v = 1;
    JMI_RET(STR, o_o, o_v)
    if (i_o != NULL) *i_o = i_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_string_t func_CCodeGenTests_StringOperations8_f1_exp1(jmi_string_t s_v) {
    JMI_DEF_STR_DYNA(o_v)
    func_CCodeGenTests_StringOperations8_f1_def1(s_v, &o_v, NULL);
    return o_v;
}

void func_Modelica_Utilities_Streams_print_def2(jmi_string_t string_v, jmi_string_t fileName_v) {
    JMI_DYNAMIC_INIT()
    ModelicaInternal_print(string_v, fileName_v);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end StringOperations8;

model StringOperations9
    function f
        input Real x;
        input Integer i;
        input Boolean b;
        input String fmt;
        output Real y;
        String s;
      algorithm
        s := String(x, significantDigits=1, minimumLength=i, leftJustified=b)
        + String(x, significantDigits=i, minimumLength=2, leftJustified=b)
        + String(x, significantDigits=i, minimumLength=i, leftJustified=false)
        + String(x, significantDigits=i, minimumLength=i, leftJustified=b)
        + String(x, significantDigits=i, leftJustified=b)
        + String(x)
        + String(x, format=fmt)
        
        + String(i, minimumLength=2, leftJustified=b)
        + String(i, minimumLength=i, leftJustified=true)
        + String(i, minimumLength=i, leftJustified=b)
        + String(i, format=fmt)
        
        + String(b, minimumLength=2, leftJustified=b)
        + String(b, minimumLength=i, leftJustified=true)
        + String(b, minimumLength=i, leftJustified=b);
    end f;
    
    Real y = f(-time, 3, true, "%g");

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations9",
            description="String operator unknown options",
            inline_functions="none",
            variability_propagation=false,
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_StringOperations9_f_def0(jmi_ad_var_t x_v, jmi_ad_var_t i_v, jmi_ad_var_t b_v, jmi_string_t fmt_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_DEF_STR_DYNA(s_v)
    JMI_DEF_STR_DYNA(tmp_1)
    JMI_INI_STR_DYNA(tmp_1, jmi_max(7 + AD_WRAP_LITERAL(1), i_v) + jmi_max(7 + i_v, AD_WRAP_LITERAL(2)) + jmi_max(7 + i_v, i_v) + jmi_max(7 + i_v, i_v) + 7 + i_v + 7 + 6 + 16 + jmi_max(10, AD_WRAP_LITERAL(2)) + jmi_max(10, i_v) + jmi_max(10, i_v) + 16 + jmi_max(5, AD_WRAP_LITERAL(2)) + jmi_max(5, i_v) + jmi_max(5, i_v))
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*.*g\") : (\"%*.*g\")), (int) i_v, (int) AD_WRAP_LITERAL(1), x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*.*g\") : (\"%*.*g\")), (int) AD_WRAP_LITERAL(2), (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((JMI_FALSE) ? (\"%-*.*g\") : (\"%*.*g\")), (int) i_v, (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*.*g\") : (\"%*.*g\")), (int) i_v, (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-.*g\") : (\"%.*g\")), (int) i_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), fmt_v, x_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*d\") : (\"%*d\")), (int) AD_WRAP_LITERAL(2), (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((JMI_TRUE) ? (\"%-*d\") : (\"%*d\")), (int) i_v, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*d\") : (\"%*d\")), (int) i_v, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), fmt_v, (int) i_v);
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*s\") : (\"%*s\")), (int) AD_WRAP_LITERAL(2), COND_EXP_EQ(b_v, JMI_TRUE, \"true\", \"false\"));
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((JMI_TRUE) ? (\"%-*s\") : (\"%*s\")), (int) i_v, COND_EXP_EQ(b_v, JMI_TRUE, \"true\", \"false\"));
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), ((b_v) ? (\"%-*s\") : (\"%*s\")), (int) i_v, COND_EXP_EQ(b_v, JMI_TRUE, \"true\", \"false\"));
    JMI_ASG(STR, s_v, tmp_1)
    JMI_FREE(tmp_1)
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations9_f_exp0(jmi_ad_var_t x_v, jmi_ad_var_t i_v, jmi_ad_var_t b_v, jmi_string_t fmt_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations9_f_def0(x_v, i_v, b_v, fmt_v, &y_v);
    return y_v;
}

")})));
end StringOperations9;

model StringOperations10
    function f1
        input String[:] s;
        output String[size(s,1)] o;
      algorithm
        o := s;
    end f1;
    
    function f2
        input Real x;
        output Real y;
        String[2] s;
      algorithm
        y := x;
        s := {"str", "str"};
        s := f1(s);
    end f2;
    
    Real y = f2(-time);
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations10",
            description="String array return value in function call",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_StringOperations10_f2_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_ARR(STAT, jmi_string_t, jmi_string_array_t, s_a, 2, 1)
    JMI_ARR(STAT, jmi_string_t, jmi_string_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_string_t, jmi_string_array_t, s_a, 2, 1, 2)
    y_v = x_v;
    JMI_ASG(STR, jmi_array_ref_1(s_a, 1), \"str\")
    JMI_ASG(STR, jmi_array_ref_1(s_a, 2), \"str\")
    func_CCodeGenTests_StringOperations10_f1_def1(s_a, tmp_1);
    JMI_ASG(STR, jmi_array_ref_1(s_a, 1), jmi_array_val_1(tmp_1, 1))
    JMI_ASG(STR, jmi_array_ref_1(s_a, 2), jmi_array_val_1(tmp_1, 2))
    jmi_free_str_arr(tmp_1);
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations10_f2_exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations10_f2_def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations10_f1_def1(jmi_string_array_t* s_a, jmi_string_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, o_an, -1, 1)
    jmi_ad_var_t i1_0i;
    jmi_ad_var_t i1_0ie;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, o_an, jmi_array_size(s_a, 0), 1, jmi_array_size(s_a, 0))
        o_a = o_an;
    }
    i1_0ie = jmi_array_size(s_a, 0) + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        JMI_ASG(STR, jmi_array_ref_1(o_a, i1_0i), jmi_array_val_1(s_a, i1_0i))
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
end StringOperations10;

model StringOperations11
    function f1
        input String[:] s;
        output String[size(s,1)] o;
      algorithm
        o := s;
    end f1;
    
    function f2
        input Real x;
        input Integer n;
        output Real y;
        String[n] s;
      algorithm
        y := x;
        s := {"str" for i in 1:n};
        s := f1(s);
    end f2;
    
    Real y = f2(-time, 2);
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="StringOperations11",
            description="Unknown size string array return value in function call",
            inline_functions="none",
            variability_propagation=false,
            template="
$C_functions$
",
            generatedCode="
void func_CCodeGenTests_StringOperations11_f2_def0(jmi_ad_var_t x_v, jmi_ad_var_t n_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, s_a, -1, 1)
    JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, temp_1_a, -1, 1)
    jmi_ad_var_t i2_0i;
    jmi_ad_var_t i2_0ie;
    jmi_ad_var_t i1_1i;
    jmi_ad_var_t i1_1ie;
    JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, s_a, n_v, 1, n_v)
    JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, temp_1_a, n_v, 1, n_v)
    y_v = x_v;
    i2_0ie = n_v + 1 / 2.0;
    for (i2_0i = 1; i2_0i < i2_0ie; i2_0i += 1) {
        JMI_ASG(STR, jmi_array_ref_1(temp_1_a, i2_0i), \"str\")
    }
    i1_1ie = n_v + 1 / 2.0;
    for (i1_1i = 1; i1_1i < i1_1ie; i1_1i += 1) {
        JMI_ASG(STR, jmi_array_ref_1(s_a, i1_1i), jmi_array_val_1(temp_1_a, i1_1i))
    }
    func_CCodeGenTests_StringOperations11_f1_def1(s_a, tmp_1);
    jmi_free_str_arr(tmp_1);
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_StringOperations11_f2_exp0(jmi_ad_var_t x_v, jmi_ad_var_t n_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_StringOperations11_f2_def0(x_v, n_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_StringOperations11_f1_def1(jmi_string_array_t* s_a, jmi_string_array_t* o_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, o_an, -1, 1)
    jmi_ad_var_t i1_2i;
    jmi_ad_var_t i1_2ie;
    if (o_a == NULL) {
        JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, o_an, jmi_array_size(s_a, 0), 1, jmi_array_size(s_a, 0))
        o_a = o_an;
    }
    i1_2ie = jmi_array_size(s_a, 0) + 1 / 2.0;
    for (i1_2i = 1; i1_2i < i1_2ie; i1_2i += 1) {
        JMI_ASG(STR, jmi_array_ref_1(o_a, i1_2i), jmi_array_val_1(s_a, i1_2i))
    }
    JMI_DYNAMIC_FREE()
    return;
}
")})));
end StringOperations11;

model TestTerminate1 // Test C code generation for terminate()
        Real x(start = 0);
    equation
        der(x) = time;
        when x >= 2 then
            terminate("X is high enough.");
        end when;
	
	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestTerminate1",
			description="",
			template="
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
    _der_x_3 = _time;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (2), _sw(0), jmi->events_epsilon, JMI_REL_GEQ);
    }
    _temp_1_1 = _sw(0);
    if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
        jmi_flag_termination(jmi, \"X is high enough.\");
    }
/********* Write back reinits *******/

")})));
end TestTerminate1;

/* TODO: Once there is support for if equations containing functions without return values, 
         add tests of terminate() in if equations. */ 


model TestAssert1
    function f
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
        assert(x < 3, "x is too high.");
        assert(y < 4, "y is too high.", AssertionLevel.error);
        assert(x + y < 5, "sum is a bit high.", AssertionLevel.warning);
    end f;
    
    Real x = time + 1;
    Real y = f(x);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="TestAssert1",
            description="Test C code generation for assert() in functions",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenTests_TestAssert1_f_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = x_v + 1;
    if (COND_EXP_LT(x_v, AD_WRAP_LITERAL(3), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"x is too high.\", JMI_ASSERT_ERROR);
    }
    if (COND_EXP_LT(y_v, AD_WRAP_LITERAL(4), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"y is too high.\", JMI_ASSERT_ERROR);
    }
    if (COND_EXP_LT(x_v + y_v, AD_WRAP_LITERAL(5), JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"sum is a bit high.\", JMI_ASSERT_WARNING);
    }
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_TestAssert1_f_exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_TestAssert1_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end TestAssert1;


model TestAssert2
    Real x = time + 1;
    Real y = x + 1;
equation
    assert(x < 3, "x is too high.");
    assert(y < 4, "y is too high.", AssertionLevel.error);
    assert(x + y < 5, "sum is a bit high.", AssertionLevel.warning);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestAssert2",
			description="Test C code generation for assert() in equations",
			template="
$C_ode_initialization$
$C_ode_derivatives$
",
			generatedCode="
    model_ode_guards(jmi);
    _x_0 = _time + 1;
    _y_1 = _x_0 + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(3)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(3)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"x is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_y_1 - (AD_WRAP_LITERAL(4)), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_y_1 - (AD_WRAP_LITERAL(4)), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"y is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_x_0 + _y_1 - (AD_WRAP_LITERAL(5)), _sw(2), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_x_0 + _y_1 - (AD_WRAP_LITERAL(5)), _sw(2), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(2) == JMI_FALSE) {
        jmi_assert_failed(\"sum is a bit high.\", JMI_ASSERT_WARNING);
    }
    
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = _time + 1;
    _y_1 = _x_0 + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(3)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(3)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"x is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_y_1 - (AD_WRAP_LITERAL(4)), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(_y_1 - (AD_WRAP_LITERAL(4)), _sw(1), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(1) == JMI_FALSE) {
        jmi_assert_failed(\"y is too high.\", JMI_ASSERT_ERROR);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_x_0 + _y_1 - (AD_WRAP_LITERAL(5)), _sw(2), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(_x_0 + _y_1 - (AD_WRAP_LITERAL(5)), _sw(2), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(2) == JMI_FALSE) {
        jmi_assert_failed(\"sum is a bit high.\", JMI_ASSERT_WARNING);
    }
/********* Write back reinits *******/
")})));
end TestAssert2;


model TestStringWithUnicode1
	Real x = time + 1;
equation
	assert(x < 5, "euro: €
aring: å
Auml: Ä\nbell: \a");

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TestStringWithUnicode1",
			description="C string literal with line breaks and unicode chars",
			template="$C_ode_derivatives$",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = _time + 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(5)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_x_0 - (AD_WRAP_LITERAL(5)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
    }
    if (_sw(0) == JMI_FALSE) {
        jmi_assert_failed(\"euro: \\xe2\\x82\\xac\\naring: \\xc3\\xa5\\nAuml: \\xc3\\x84\\nbell: \\a\", JMI_ASSERT_ERROR);
    }
/********* Write back reinits *******/
")})));
end TestStringWithUnicode1;


model CFixedFalseParam1
    Real x, y;
    parameter Real p(fixed=false);
initial equation
    2*x = p;
    x = 3;
equation
    der(x) = -x;
    y = x * time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CFixedFalseParam1",
            description="Test of C code generation of parameters with fixed = false.",
            template="
***Derivatives:
$C_ode_derivatives$
***Initialization:
$C_ode_initialization$
***Param:
$C_DAE_initial_dependent_parameter_assignments$
",
            generatedCode="
***Derivatives:
    model_ode_guards(jmi);
/************* ODE section *********/
    _der_x_3 = - _x_0;
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _y_1 = _x_0 * _time;
/********* Write back reinits *******/

***Initialization:
    model_ode_guards(jmi);
    _x_0 = 3;
    _der_x_3 = - _x_0;
    _y_1 = _x_0 * _time;
    _p_2 = 2 * _x_0;

***Param:
")})));
end CFixedFalseParam1;

model ActiveSwitches1
    Real f = if s then time else -1;
    Boolean s = f > 10;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ActiveSwitches1",
            description="Test code gen for active switch indexes in block.",
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870914;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _f_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _f_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_f_0 - (10), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _s_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_s_1, JMI_TRUE, _time, AD_WRAP_LITERAL(-1)) - (_f_0);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870914;
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _f_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        residual[0] = 1.0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _f_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_f_0 - (10), _sw(0), jmi->events_epsilon, JMI_REL_GT);
            }
            _s_1 = _sw(0);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(_s_1, JMI_TRUE, _time, AD_WRAP_LITERAL(-1)) - (_f_0);
        }
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 1, 1, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 1, 1, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end ActiveSwitches1;

model ActiveSwitches2
    Real a = if b < 3.14 then time else -1;
    Real b = if a > 10 then a else -der(a);
initial equation
    der(a) = if a > 42 then 0.1 else 0.2;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ActiveSwitches2",
            description="Test code gen for active switch indexes in block.",
            template="
$C_dae_blocks_residual_functions$
$C_dae_init_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
$C_dae_init_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_b_1 - (AD_WRAP_LITERAL(3.14)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, AD_WRAP_LITERAL(-1)) - (_a_0);
        }
    }
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _der_a_2;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        memset(residual, 0, 1 * sizeof(jmi_real_t));
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch(_a_0 - (AD_WRAP_LITERAL(10)), _sw(1), jmi->events_epsilon, JMI_REL_GT);
        }
        residual[0] = - COND_EXP_EQ(_sw(1), JMI_TRUE, AD_WRAP_LITERAL(0.0), AD_WRAP_LITERAL(-1.0));
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _der_a_2 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(_a_0 - (AD_WRAP_LITERAL(10)), _sw(1), jmi->events_epsilon, JMI_REL_GT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(1), JMI_TRUE, _a_0, - _der_a_2) - (_b_1);
        }
    }
    return ef;
}


static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw + 1;
        x[1] = jmi->offs_sw + 0;
        x[2] = jmi->offs_sw_init + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _a_0;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        jmi_real_t* Q1 = calloc(2, sizeof(jmi_real_t));
        jmi_real_t* Q2 = calloc(2, sizeof(jmi_real_t));
        jmi_real_t* Q3 = residual;
        int i;
        char trans = 'N';
        double alpha = -1;
        double beta = 1;
        int n1 = 2;
        int n2 = 1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch(_a_0 - (AD_WRAP_LITERAL(10)), _sw(1), jmi->events_epsilon, JMI_REL_GT);
        }
        Q1[1] = - COND_EXP_EQ(_sw(1), JMI_TRUE, AD_WRAP_LITERAL(1.0), AD_WRAP_LITERAL(0.0));
        for (i = 0; i < 2; i += 2) {
            Q1[i + 0] = (Q1[i + 0]) / (1.0);
            Q1[i + 1] = (Q1[i + 1] - (- COND_EXP_EQ(_sw(1), JMI_TRUE, AD_WRAP_LITERAL(0.0), AD_WRAP_LITERAL(-1.0))) * Q1[i + 0]) / (1.0);
        }
        memset(Q3, 0, 1 * sizeof(jmi_real_t));
        Q3[0] = 1.0;
        dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
        free(Q1);
        free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _a_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw_init(0) = jmi_turn_switch(_a_0 - (AD_WRAP_LITERAL(42)), _sw_init(0), jmi->events_epsilon, JMI_REL_GT);
        }
        _der_a_2 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, AD_WRAP_LITERAL(0.1), AD_WRAP_LITERAL(0.2));
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw(1) = jmi_turn_switch(_a_0 - (AD_WRAP_LITERAL(10)), _sw(1), jmi->events_epsilon, JMI_REL_GT);
        }
        _b_1 = COND_EXP_EQ(_sw(1), JMI_TRUE, _a_0, - _der_a_2);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(_b_1 - (AD_WRAP_LITERAL(3.14)), _sw(0), jmi->events_epsilon, JMI_REL_LT);
            }
            (*res)[0] = COND_EXP_EQ(_sw(0), JMI_TRUE, _time, AD_WRAP_LITERAL(-1)) - (_a_0);
        }
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 1, 0, 1, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, 1, 0, 0, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 1, \"2\", -1);

    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 1, 0, 3, JMI_DISCRETE_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);
")})));
end ActiveSwitches2;

model ActiveSwitches3
    Real x;
    parameter Real p(fixed=false);
initial equation
    p = x * 6.28;
equation
    x = if p > 3.14 then p - 42 else p + time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ActiveSwitches3",
            description="Test code gen fixed=false parameters with switch indicators.",
            template="
C_dae_init_blocks_residual_functions
$C_dae_init_blocks_residual_functions$
C_dae_init_add_blocks_residual_functions
$C_dae_init_add_blocks_residual_functions$
C_ode_derivatives
$C_ode_derivatives$
C_ode_initialization
$C_ode_initialization$
C_DAE_event_indicator_residuals
$C_DAE_event_indicator_residuals$
C_DAE_initial_event_indicator_residuals
$C_DAE_initial_event_indicator_residuals$
static const int N_sw = $n_switches$;
static const int N_sw_init = $n_initial_switches$;
",
            generatedCode="
C_dae_init_blocks_residual_functions
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 0;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
        x[0] = jmi->offs_sw_init + 0;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _p_1;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
        jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
        jmi_real_t* Q3 = residual;
        int i;
        char trans = 'N';
        double alpha = -1;
        double beta = 1;
        int n1 = 1;
        int n2 = 1;
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw_init(0) = jmi_turn_switch(_p_1 - (AD_WRAP_LITERAL(3.14)), _sw_init(0), jmi->events_epsilon, JMI_REL_GT);
        }
        Q1[0] = - COND_EXP_EQ(_sw_init(0), JMI_TRUE, AD_WRAP_LITERAL(1.0), AD_WRAP_LITERAL(1.0));
        for (i = 0; i < 1; i += 1) {
            Q1[i + 0] = (Q1[i + 0]) / (1.0);
        }
        Q2[0] = -6.28;
        memset(Q3, 0, 1 * sizeof(jmi_real_t));
        Q3[0] = 1.0;
        dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
        free(Q1);
        free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _p_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            _sw_init(0) = jmi_turn_switch(_p_1 - (AD_WRAP_LITERAL(3.14)), _sw_init(0), jmi->events_epsilon, JMI_REL_GT);
        }
        _x_0 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, _p_1 - AD_WRAP_LITERAL(42), _p_1 + _time);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _x_0 * 6.28 - (_p_1);
        }
    }
    return ef;
}


C_dae_init_add_blocks_residual_functions
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 1, 0, 1, JMI_PARAMETER_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

C_ode_derivatives
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = COND_EXP_EQ(COND_EXP_GT(_p_1, AD_WRAP_LITERAL(3.14), JMI_TRUE, JMI_FALSE), JMI_TRUE, _p_1 - AD_WRAP_LITERAL(42), _p_1 + _time);
/********* Write back reinits *******/

C_ode_initialization
    model_ode_guards(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);

C_DAE_event_indicator_residuals

C_DAE_initial_event_indicator_residuals
    (*res)[0] = _p_1 - (AD_WRAP_LITERAL(3.14));

static const int N_sw = 0;
static const int N_sw_init = 1;
")})));
end ActiveSwitches3;

model ActiveSwitches4
    parameter Real p1(fixed=false);
    parameter Real p2(fixed=false);
    Real a = if p1 > 0 then 1 else 2;
initial equation
    p1 = p2 * 23;
    p2 = p1 + 1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ActiveSwitches4",
            description="Test code gen variability propagated switches (fixed = false).",
            template="
C_dae_init_blocks_residual_functions
$C_dae_init_blocks_residual_functions$
C_dae_init_add_blocks_residual_functions
$C_dae_init_add_blocks_residual_functions$
C_ode_derivatives
$C_ode_derivatives$
C_ode_initialization
$C_ode_initialization$
C_DAE_event_indicator_residuals
$C_DAE_event_indicator_residuals$
C_DAE_initial_event_indicator_residuals
$C_DAE_initial_event_indicator_residuals$
static const int N_sw = $n_switches$;
static const int N_sw_init = $n_initial_switches$;
",
            generatedCode="
C_dae_init_blocks_residual_functions
static int dae_init_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Init block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    if (evaluation_mode == JMI_BLOCK_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_START) {
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _p2_1;
    } else if (evaluation_mode==JMI_BLOCK_EVALUATE_JACOBIAN) {
        jmi_real_t* Q1 = calloc(1, sizeof(jmi_real_t));
        jmi_real_t* Q2 = calloc(1, sizeof(jmi_real_t));
        jmi_real_t* Q3 = residual;
        int i;
        char trans = 'N';
        double alpha = -1;
        double beta = 1;
        int n1 = 1;
        int n2 = 1;
        Q1[0] = -23;
        for (i = 0; i < 1; i += 1) {
            Q1[i + 0] = (Q1[i + 0]) / (1.0);
        }
        Q2[0] = -1.0;
        memset(Q3, 0, 1 * sizeof(jmi_real_t));
        Q3[0] = 1.0;
        dgemm_(&trans, &trans, &n2, &n2, &n1, &alpha, Q2, &n2, Q1, &n1, &beta, Q3, &n2);
        free(Q1);
        free(Q2);
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _p2_1 = x[0];
        }
        _p1_0 = _p2_1 * 23;
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _p1_0 + 1 - (_p2_1);
        }
    }
    return ef;
}


C_dae_init_add_blocks_residual_functions
    jmi_dae_init_add_equation_block(*jmi, dae_init_block_0, NULL, 1, 0, 0, JMI_CONSTANT_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_LINEAR_SOLVER, 0, \"1\", -1);

C_ode_derivatives
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
/********* Write back reinits *******/

C_ode_initialization
    model_ode_guards(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_init_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw_init(0) = jmi_turn_switch(_p1_0 - (AD_WRAP_LITERAL(0)), _sw_init(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _a_2 = COND_EXP_EQ(_sw_init(0), JMI_TRUE, AD_WRAP_LITERAL(1), AD_WRAP_LITERAL(2));

C_DAE_event_indicator_residuals

C_DAE_initial_event_indicator_residuals
    (*res)[0] = _p1_0 - (AD_WRAP_LITERAL(0));

static const int N_sw = 0;
static const int N_sw_init = 1;
")})));
end ActiveSwitches4;

model ActiveSwitches5
    Real x,y;
equation
    x = smooth(1,if time > 1 then time * 1.2 else 1);
    y = der(x);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ActiveSwitches5",
            description="Test code gen differentiated switches inside Smooth(1, ...)",
            template="
C_dae_init_blocks_residual_functions
$C_dae_init_blocks_residual_functions$
C_dae_init_add_blocks_residual_functions
$C_dae_init_add_blocks_residual_functions$
C_ode_derivatives
$C_ode_derivatives$
C_ode_initialization
$C_ode_initialization$
C_DAE_event_indicator_residuals
$C_DAE_event_indicator_residuals$
C_DAE_initial_event_indicator_residuals
$C_DAE_initial_event_indicator_residuals$
static const int N_sw = $n_switches$;
static const int N_sw_init = $n_initial_switches$;
",
            generatedCode="
C_dae_init_blocks_residual_functions

C_dae_init_add_blocks_residual_functions

C_ode_derivatives
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = (COND_EXP_EQ(COND_EXP_GT(_time, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), JMI_TRUE, _time * AD_WRAP_LITERAL(1.2), AD_WRAP_LITERAL(1)));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _der_x_2 = (COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(1.2), AD_WRAP_LITERAL(0)));
    _y_1 = _der_x_2;
/********* Write back reinits *******/

C_ode_initialization
    model_ode_guards(jmi);
    _x_0 = (COND_EXP_EQ(COND_EXP_GT(_time, AD_WRAP_LITERAL(1), JMI_TRUE, JMI_FALSE), JMI_TRUE, _time * AD_WRAP_LITERAL(1.2), AD_WRAP_LITERAL(1)));
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(_time - (AD_WRAP_LITERAL(1)), _sw(0), jmi->events_epsilon, JMI_REL_GT);
    }
    _der_x_2 = (COND_EXP_EQ(_sw(0), JMI_TRUE, AD_WRAP_LITERAL(1.2), AD_WRAP_LITERAL(0)));
    _y_1 = _der_x_2;

C_DAE_event_indicator_residuals
    (*res)[0] = _time - (AD_WRAP_LITERAL(1));

C_DAE_initial_event_indicator_residuals
    (*res)[0] = _time - (AD_WRAP_LITERAL(1));

static const int N_sw = 1;
static const int N_sw_init = 0;
")})));
end ActiveSwitches5;

model SwitchesAsNoEvent1
    Boolean x = time > 0.5;
    Real y = abs(time + 0.5);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SwitchesAsNoEvent1",
            description="Test so that no switches are generated when generate_event_switches is set to false.",
            generate_event_switches=false,
            template="
$C_DAE_initial_relations$
$C_DAE_relations$
$C_ode_derivatives$
",
            generatedCode="
static const int N_initial_relations = 0;
static const int DAE_initial_relations[] = { -1 };
static const int N_relations = 0;
static const int DAE_relations[] = { -1 };
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _x_0 = COND_EXP_GT(_time, 0.5, JMI_TRUE, JMI_FALSE);
    _y_1 = jmi_abs(_time + AD_WRAP_LITERAL(0.5));
/********* Write back reinits *******/

")})));
end SwitchesAsNoEvent1;

model TruncDivString1
	Real[5,5] a_really_long_variable_name = ones(5,5) * time;
	Real x;
equation
	x = time / (sum(a_really_long_variable_name));

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="TruncDivString1",
			description="Test code gen for active switch indexes in block.",
			template="
$C_ode_derivatives$
",
			generatedCode="
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _a_really_long_variable_name_1_1_0 = _time;
    _a_really_long_variable_name_1_2_1 = _time;
    _a_really_long_variable_name_1_3_2 = _time;
    _a_really_long_variable_name_1_4_3 = _time;
    _a_really_long_variable_name_1_5_4 = _time;
    _a_really_long_variable_name_2_1_5 = _time;
    _a_really_long_variable_name_2_2_6 = _time;
    _a_really_long_variable_name_2_3_7 = _time;
    _a_really_long_variable_name_2_4_8 = _time;
    _a_really_long_variable_name_2_5_9 = _time;
    _a_really_long_variable_name_3_1_10 = _time;
    _a_really_long_variable_name_3_2_11 = _time;
    _a_really_long_variable_name_3_3_12 = _time;
    _a_really_long_variable_name_3_4_13 = _time;
    _a_really_long_variable_name_3_5_14 = _time;
    _a_really_long_variable_name_4_1_15 = _time;
    _a_really_long_variable_name_4_2_16 = _time;
    _a_really_long_variable_name_4_3_17 = _time;
    _a_really_long_variable_name_4_4_18 = _time;
    _a_really_long_variable_name_4_5_19 = _time;
    _a_really_long_variable_name_5_1_20 = _time;
    _a_really_long_variable_name_5_2_21 = _time;
    _a_really_long_variable_name_5_3_22 = _time;
    _a_really_long_variable_name_5_4_23 = _time;
    _a_really_long_variable_name_5_5_24 = _time;
    _x_25 = jmi_divide_equation(jmi, _time,(_a_really_long_variable_name_1_1_0 + _a_really_long_variable_name_1_2_1 + _a_really_long_variable_name_1_3_2 + _a_really_long_variable_name_1_4_3 + _a_really_long_variable_name_1_5_4 + _a_really_long_variable_name_2_1_5 + _a_really_long_variable_name_2_2_6 + _a_really_long_variable_name_2_3_7 + _a_really_long_variable_name_2_4_8 + _a_really_long_variable_name_2_5_9 + _a_really_long_variable_name_3_1_10 + _a_really_long_variable_name_3_2_11 + _a_really_long_variable_name_3_3_12 + _a_really_long_variable_name_3_4_13 + _a_really_long_variable_name_3_5_14 + _a_really_long_variable_name_4_1_15 + _a_really_long_variable_name_4_2_16 + _a_really_long_variable_name_4_3_17 + _a_really_long_variable_name_4_4_18 + _a_really_long_variable_name_4_5_19 + _a_really_long_variable_name_5_1_20 + _a_really_long_variable_name_5_2_21 + _a_really_long_variable_name_5_3_22 + _a_really_long_variable_name_5_4_23 + _a_really_long_variable_name_5_5_24),\"(truncated) time / (a_really_long_variable_name[1,1] + a_really_long_variable_name[1,2] + a_really_long_variable_name[1,3] + a_really_long_variable_name[1,4] + a_really_long_variable_name[1,5] + a_really_long_variable_name[2,1] + a_really_long_variable_name[2,2] + a_really_long_variable_name[2,3] + a_really_long_variable_name[2,4] + a_really_long_variable_name[2,5] + a_really_long_variable_name[3,1] + a_really_long_variable_name[3,2] + a_really_long_variable_name[3,3] + a_really_long_variable_name[3,4...\");
/********* Write back reinits *******/
")})));
end TruncDivString1;

package ExternalFunction
package CEval
model Scalar
    type E = enumeration(A,B);
    function f
        input Real a1;
        input Integer a2;
        input Boolean a3;
        input String a4;
        input E a5;
        output Real b1;
        output Integer b2;
        output Boolean b3;
        output String b4;
        output E b5;
        external;
    end f;
    
    Real x1;
    Integer x2;
    Boolean x3;
    String x4;
    E x5;
equation
    (x1,x2,x3,x4,x5) = f(1,2,true,"s",E.A);
	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ExternalFunction_CEval_Scalar",
			description="Test code gen for external C functions evaluation. Scalars.",
			variability_propagation=false,
			inline_functions="none",
			template="
$ECE_external_includes$
$ECE_record_definitions$
$ECE_main$
",
			generatedCode="
/* Declarations */
jmi_ad_var_t a1_v;
jmi_ad_var_t a2_v;
jmi_ad_var_t a3_v;
JMI_DEF_STR_DYNA(a4_v)
jmi_ad_var_t a5_v;
jmi_ad_var_t b1_v;
jmi_ad_var_t b2_v;
jmi_ad_var_t b3_v;
JMI_DEF_STR_DYNA(b4_v)
jmi_ad_var_t b5_v;
jmi_int_t tmp_1;
jmi_int_t tmp_2;
jmi_int_t tmp_3;
jmi_int_t tmp_4;
jmi_int_t tmp_5;
jmi_int_t tmp_6;

    JMCEVAL_setup();
printf(\"START\\n\"); fflush(stdout);
/* Parse */
JMCEVAL_parse(Real, a1_v);
JMCEVAL_parse(Integer, a2_v);
JMCEVAL_parse(Boolean, a3_v);
JMCEVAL_parse(String, a4_v);
JMCEVAL_parse(Enum, a5_v);
JMCEVAL_parse(Real, b1_v);
JMCEVAL_parse(Integer, b2_v);
JMCEVAL_parse(Boolean, b3_v);
JMCEVAL_parse(String, b4_v);
JMCEVAL_parse(Enum, b5_v);

/* Call the function */
printf(\"CALC\\n\"); fflush(stdout);
tmp_1 = (int)a2_v;
tmp_2 = (int)a3_v;
tmp_3 = (int)a5_v;
tmp_4 = (int)b2_v;
tmp_5 = (int)b3_v;
tmp_6 = (int)b5_v;
f(a1_v, tmp_1, tmp_2, a4_v, tmp_3, &b1_v, &tmp_4, &tmp_5, &b4_v, &tmp_6);
b2_v = tmp_4;
b3_v = tmp_5;
b5_v = tmp_6;
printf(\"DONE\\n\"); fflush(stdout);

/* Print */
JMCEVAL_print(Real, b1_v);
JMCEVAL_print(Integer, b2_v);
JMCEVAL_print(Boolean, b3_v);
JMCEVAL_print(String, b4_v);
JMCEVAL_print(Enum, b5_v);

/* Free strings */
JMCEVAL_free(a4_v);
JMCEVAL_free(b4_v);

printf(\"END\\n\"); fflush(stdout);
")})));
end Scalar;

model Array
type E = enumeration(A,B);
function f
    input Real[:] a1;
    input Integer[:] a2;
    input Boolean[:] a3;
    input String[:] a4;
    input E[:] a5;
    output Real[size(a1,1)] b1;
    output Integer[size(a2,1)] b2;
    output Boolean[size(a3,1)] b3;
    output String[size(a4,1)] b4;
    output E[size(a5,1)] b5;
    external;
end f;
    Real[1] x1;
    Integer[1] x2;
    Boolean[1] x3;
    String[1] x4;
    E[1] x5;
equation
	(x1,x2,x3,x4,x5) = f({1},{2},{true},{"s"},{E.A});

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
            name="ExternalFunction_CEval_Array",
			description="Test code gen for external C functions evaluation. Arrays.",
			variability_propagation=false,
			inline_functions="none",
			template="
$ECE_external_includes$
$ECE_record_definitions$
$ECE_main$
",
			generatedCode="
/* Declarations */
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, a1_a, -1, 1)
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, a2_a, -1, 1)
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, a3_a, -1, 1)
JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, a4_a, -1, 1)
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, a5_a, -1, 1)
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, b1_a, -1, 1)
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, b2_a, -1, 1)
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, b3_a, -1, 1)
JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, b4_a, -1, 1)
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, b5_a, -1, 1)
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_1, -1, 1)
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_2, -1, 1)
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_3, -1, 1)
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_4, -1, 1)
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_5, -1, 1)
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_6, -1, 1)

    JMCEVAL_setup();
printf(\"START\\n\"); fflush(stdout);
/* Parse */
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, a1_a, d[0], 1, d[0])
JMCEVAL_parseArray(Real, a1_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, a2_a, d[0], 1, d[0])
JMCEVAL_parseArray(Integer, a2_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, a3_a, d[0], 1, d[0])
JMCEVAL_parseArray(Boolean, a3_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, a4_a, d[0], 1, d[0])
JMCEVAL_parseArray(String, a4_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, a5_a, d[0], 1, d[0])
JMCEVAL_parseArray(Enum, a5_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, b1_a, d[0], 1, d[0])
JMCEVAL_parseArray(Real, b1_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, b2_a, d[0], 1, d[0])
JMCEVAL_parseArray(Integer, b2_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, b3_a, d[0], 1, d[0])
JMCEVAL_parseArray(Boolean, b3_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, b4_a, d[0], 1, d[0])
JMCEVAL_parseArray(String, b4_a);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, b5_a, d[0], 1, d[0])
JMCEVAL_parseArray(Enum, b5_a);

/* Call the function */
printf(\"CALC\\n\"); fflush(stdout);
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_1, jmi_array_size(a2_a, 0), 1, jmi_array_size(a2_a, 0))
jmi_copy_matrix_to_int(a2_a, a2_a->var, tmp_1->var);
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_2, jmi_array_size(a3_a, 0), 1, jmi_array_size(a3_a, 0))
jmi_copy_matrix_to_int(a3_a, a3_a->var, tmp_2->var);
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_3, jmi_array_size(a5_a, 0), 1, jmi_array_size(a5_a, 0))
jmi_copy_matrix_to_int(a5_a, a5_a->var, tmp_3->var);
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_4, jmi_array_size(b2_a, 0), 1, jmi_array_size(b2_a, 0))
jmi_copy_matrix_to_int(b2_a, b2_a->var, tmp_4->var);
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_5, jmi_array_size(b3_a, 0), 1, jmi_array_size(b3_a, 0))
jmi_copy_matrix_to_int(b3_a, b3_a->var, tmp_5->var);
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_6, jmi_array_size(b5_a, 0), 1, jmi_array_size(b5_a, 0))
jmi_copy_matrix_to_int(b5_a, b5_a->var, tmp_6->var);
f(a1_a->var, jmi_array_size(a1_a, 0), tmp_1->var, jmi_array_size(a2_a, 0), tmp_2->var, jmi_array_size(a3_a, 0), a4_a->var, jmi_array_size(a4_a, 0), tmp_3->var, jmi_array_size(a5_a, 0), b1_a->var, jmi_array_size(b1_a, 0), tmp_4->var, jmi_array_size(b2_a, 0), tmp_5->var, jmi_array_size(b3_a, 0), b4_a->var, jmi_array_size(b4_a, 0), tmp_6->var, jmi_array_size(b5_a, 0));
jmi_copy_matrix_from_int(b2_a, tmp_4->var, b2_a->var);
jmi_copy_matrix_from_int(b3_a, tmp_5->var, b3_a->var);
jmi_copy_matrix_from_int(b5_a, tmp_6->var, b5_a->var);
printf(\"DONE\\n\"); fflush(stdout);

/* Print */
JMCEVAL_printArray(Real, b1_a);
JMCEVAL_printArray(Integer, b2_a);
JMCEVAL_printArray(Boolean, b3_a);
JMCEVAL_printArray(String, b4_a);
JMCEVAL_printArray(Enum, b5_a);

/* Free strings */
JMCEVAL_freeArray(a4_a);
JMCEVAL_freeArray(b4_a);

printf(\"END\\n\"); fflush(stdout);
")})));
end Array;

package Os
    model Obj1
        extends ExternalObject;
        function constructor
            input Real x;
            input Integer y;
            input Boolean b;
            input String s;
            output Obj1 o1;
            external "C" o1 = my_constructor1(x,y,b,s);
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input Obj1 o1;
            external "C"
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end Obj1;
    end Os;
model ExtObj
    model Obj2
        extends ExternalObject;
        function constructor
            input Real[:] x;
            input Integer[2] y;
            input Boolean[:] b;
            input String[:] s;
            output Obj2 o2;
            external "C" my_constructor2(x,y,o2,b,s);
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input Obj2 o2;
            external "C"
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end Obj2;
    model Obj3
        extends ExternalObject;
        function constructor
            input Os.Obj1 o1;
            input Obj2[:] o2;
            output Obj3 o3;
            external "C" my_constructor3(o1,o2,o3);
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end constructor;
        function destructor
            input Obj3 o3;
            external "C"
                annotation(Library="extObjects", Include="#include \"extObjects.h\"");
        end destructor;
    end Obj3;
    
    function use3
        input  Obj3 o3;
        output Real x;
        external annotation(Library="extObjects", Include="#include \"extObjects.h\"");
    end use3;
    Os.Obj1 o1 = Os.Obj1(3.13, 3, true, "A message");
    Obj2 o2 = Obj2({3.13,3.14}, {3,4}, {false, true}, {"A message 1", "A message 2"});
    Obj3 o3 = Obj3(o1,{o2,o2});
    Real x = use3(o3);

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ExternalFunction_CEval_ExtObj",
            description="Test code gen for external C functions evaluation. External objects.",
            variability_propagation=false,
            inline_functions="none",
            template="
$ECE_external_includes$
$ECE_record_definitions$
$ECE_main$
",
            generatedCode="
#include \"extObjects.h\"

    /* Declarations */
    jmi_ad_var_t x_v;
    jmi_extobj_t o3_v;
    jmi_extobj_t tmp_1_arg0;
    jmi_int_t tmp_2;
    jmi_int_t tmp_3;
    jmi_ad_var_t tmp_4_arg0;
    jmi_ad_var_t tmp_4_arg1;
    jmi_ad_var_t tmp_4_arg2;
    JMI_DEF_STR_DYNA(tmp_4_arg3)
    JMI_ARR(DYNA, jmi_extobj_t, jmi_extobj_array_t, tmp_1_arg1, -1, 1)
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_5_max;
    JMI_ARR(STAT, jmi_int_t, jmi_int_array_t, tmp_6, 2, 1)
    JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_7, -1, 1)
    JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_8_arg0, -1, 1)
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_8_arg1, -1, 1)
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_8_arg2, -1, 1)
    JMI_ARR(DYNA, jmi_string_t, jmi_string_array_t, tmp_8_arg3, -1, 1)

    JMCEVAL_setup();
    printf(\"START\\n\"); fflush(stdout);
    /* Parse */
    JMCEVAL_parse(Real, x_v);
    JMCEVAL_parse(Real, tmp_4_arg0);
    JMCEVAL_parse(Integer, tmp_4_arg1);
    JMCEVAL_parse(Boolean, tmp_4_arg2);
    JMCEVAL_parse(String, tmp_4_arg3);
    tmp_2 = (int)tmp_4_arg1;
    tmp_3 = (int)tmp_4_arg2;
    tmp_1_arg0 = my_constructor1(tmp_4_arg0, tmp_2, tmp_3, tmp_4_arg3);
    JMCEVAL_parseArrayDims(1);
    JMI_ARRAY_INIT_1(DYNA, jmi_extobj_t, jmi_extobj_array_t, tmp_1_arg1, d[0], 1, d[0])
    tmp_5_max = d[0] + 1;
    for (tmp_5 = 1; tmp_5 < tmp_5_max; tmp_5++) {
        JMCEVAL_parseArrayDims(1);
        JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_8_arg0, d[0], 1, d[0])
        JMCEVAL_parseArray(Real, tmp_8_arg0);
        JMCEVAL_parseArrayDims(1);
        JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_8_arg1, d[0], 1, d[0])
        JMCEVAL_parseArray(Integer, tmp_8_arg1);
        JMCEVAL_parseArrayDims(1);
        JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_8_arg2, d[0], 1, d[0])
        JMCEVAL_parseArray(Boolean, tmp_8_arg2);
        JMCEVAL_parseArrayDims(1);
        JMI_ARRAY_INIT_1(DYNA, jmi_string_t, jmi_string_array_t, tmp_8_arg3, d[0], 1, d[0])
        JMCEVAL_parseArray(String, tmp_8_arg3);
        JMI_ARRAY_INIT_1(STAT, jmi_int_t, jmi_int_array_t, tmp_6, 2, 1, 2)
        jmi_copy_matrix_to_int(tmp_8_arg1, tmp_8_arg1->var, tmp_6->var);
        JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_7, jmi_array_size(tmp_8_arg2, 0), 1, jmi_array_size(tmp_8_arg2, 0))
        jmi_copy_matrix_to_int(tmp_8_arg2, tmp_8_arg2->var, tmp_7->var);
        my_constructor2(tmp_8_arg0->var, tmp_6->var, &jmi_array_ref_1(tmp_1_arg1, tmp_5), tmp_7->var, tmp_8_arg3->var);
    }
    my_constructor3(tmp_1_arg0, tmp_1_arg1->var, &o3_v);

    /* Call the function */
    printf(\"CALC\\n\"); fflush(stdout);
    x_v = use3(o3_v);
    printf(\"DONE\\n\"); fflush(stdout);

    /* Print */
    JMCEVAL_print(Real, x_v);

    /* Free strings */
    JMCEVAL_free(tmp_4_arg3);
    destructor(tmp_1_arg0);
    tmp_5_max = d[0] + 1;
    for (tmp_5 = 1; tmp_5 < tmp_5_max; tmp_5++) {
        JMCEVAL_freeArray(tmp_8_arg3);
        destructor(jmi_array_ref_1(tmp_1_arg1, tmp_5));
    }
    destructor(o3_v);

    printf(\"END\\n\"); fflush(stdout);
")})));
end ExtObj;

model Dgelsx
    function dgelsx
      "Computes the minimum-norm solution to a real linear least squares problem with rank deficient A"
      input Real A[:, :];
      input Real B[size(A, 1), :];
      input Real rcond=0.0 "Reciprocal condition number to estimate rank";
      output Real X[max(size(A, 1), size(A, 2)), size(B, 2)]=cat(
                1,
                B,
                zeros(max(nrow, ncol) - nrow, nrhs))
        "Solution is in first size(A,2) rows";
      output Integer info;
      output Integer rank "Effective rank of A";
    protected
      Integer nrow=size(A, 1);
      Integer ncol=size(A, 2);
      Integer nx=max(nrow, ncol);
      Integer nrhs=size(B, 2);
      Integer lwork=max(min(nrow, ncol) + 3*ncol, 2*min(nrow, ncol) + nrhs);
      Real work[max(min(size(A, 1), size(A, 2)) + 3*size(A, 2), 2*min(size(A, 1),
        size(A, 2)) + size(B, 2))];
      Real Awork[size(A, 1), size(A, 2)]=A;
      Integer jpvt[size(A, 2)]=zeros(ncol);
    external"FORTRAN 77" dgelsx(
              nrow,
              ncol,
              nrhs,
              Awork,
              nrow,
              X,
              nx,
              jpvt,
              rcond,
              rank,
              work,
              lwork,
              info);
    end dgelsx;
    
    Real[2,1] out;
    Real a;
    Real b;
  equation
    (out,a,b) = dgelsx({{1},{2}},{{1},{2}},1);

	annotation(__JModelica(UnitTesting(tests={
		CCodeGenTestCase(
			name="ExternalFunction_CEval_Dgelsx",
			description="Test code gen ceval of external functions.",
			variability_propagation=false,
			inline_functions="none",
			template="
$ECE_external_includes$
$ECE_record_definitions$
$ECE_main$
",
			generatedCode="
/* Declarations */
jmi_ad_var_t nrow_v;
jmi_ad_var_t ncol_v;
jmi_ad_var_t nrhs_v;
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, Awork_a, -1, 2)
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, X_a, -1, 2)
jmi_ad_var_t nx_v;
JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, jpvt_a, -1, 1)
jmi_ad_var_t rcond_v;
jmi_ad_var_t rank_v;
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, work_a, -1, 1)
jmi_ad_var_t lwork_v;
jmi_ad_var_t info_v;
jmi_int_t tmp_1;
jmi_int_t tmp_2;
jmi_int_t tmp_3;
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_4, -1, 2)
jmi_int_t tmp_5;
JMI_ARR(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_6, -1, 2)
jmi_int_t tmp_7;
JMI_ARR(DYNA, jmi_int_t, jmi_int_array_t, tmp_8, -1, 1)
jmi_int_t tmp_9;
jmi_int_t tmp_10;
jmi_int_t tmp_11;
extern void dgelsx_(jmi_int_t*, jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_ad_var_t*, jmi_int_t*, jmi_int_t*);

    JMCEVAL_setup();
printf(\"START\\n\"); fflush(stdout);
/* Parse */
JMCEVAL_parse(Integer, nrow_v);
JMCEVAL_parse(Integer, ncol_v);
JMCEVAL_parse(Integer, nrhs_v);
JMCEVAL_parseArrayDims(2);
JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, Awork_a, d[0]*d[1], 2, d[0], d[1])
JMCEVAL_parseArray(Real, Awork_a);
JMCEVAL_parseArrayDims(2);
JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, X_a, d[0]*d[1], 2, d[0], d[1])
JMCEVAL_parseArray(Real, X_a);
JMCEVAL_parse(Integer, nx_v);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, jpvt_a, d[0], 1, d[0])
JMCEVAL_parseArray(Integer, jpvt_a);
JMCEVAL_parse(Real, rcond_v);
JMCEVAL_parse(Integer, rank_v);
JMCEVAL_parseArrayDims(1);
JMI_ARRAY_INIT_1(DYNAREAL, jmi_ad_var_t, jmi_array_t, work_a, d[0], 1, d[0])
JMCEVAL_parseArray(Real, work_a);
JMCEVAL_parse(Integer, lwork_v);
JMCEVAL_parse(Integer, info_v);

/* Call the function */
printf(\"CALC\\n\"); fflush(stdout);
tmp_1 = (int)nrow_v;
tmp_2 = (int)ncol_v;
tmp_3 = (int)nrhs_v;
JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_4, jmi_array_size(Awork_a, 0) * jmi_array_size(Awork_a, 1), 2, jmi_array_size(Awork_a, 0), jmi_array_size(Awork_a, 1))
jmi_matrix_to_fortran_real(Awork_a, Awork_a->var, tmp_4->var);
tmp_5 = (int)nrow_v;
JMI_ARRAY_INIT_2(DYNAREAL, jmi_ad_var_t, jmi_array_t, tmp_6, jmi_array_size(X_a, 0) * jmi_array_size(X_a, 1), 2, jmi_array_size(X_a, 0), jmi_array_size(X_a, 1))
jmi_matrix_to_fortran_real(X_a, X_a->var, tmp_6->var);
tmp_7 = (int)nx_v;
JMI_ARRAY_INIT_1(DYNA, jmi_int_t, jmi_int_array_t, tmp_8, jmi_array_size(jpvt_a, 0), 1, jmi_array_size(jpvt_a, 0))
jmi_matrix_to_fortran_int(jpvt_a, jpvt_a->var, tmp_8->var);
tmp_9 = (int)rank_v;
tmp_10 = (int)lwork_v;
tmp_11 = (int)info_v;
dgelsx_(&tmp_1, &tmp_2, &tmp_3, tmp_4->var, &tmp_5, tmp_6->var, &tmp_7, tmp_8->var, &rcond_v, &tmp_9, work_a->var, &tmp_10, &tmp_11);
jmi_matrix_from_fortran_real(X_a, tmp_6->var, X_a->var);
rank_v = tmp_9;
info_v = tmp_11;
printf(\"DONE\\n\"); fflush(stdout);

/* Print */
JMCEVAL_printArray(Real, X_a);
JMCEVAL_print(Integer, rank_v);
JMCEVAL_print(Integer, info_v);

/* Free strings */

printf(\"END\\n\"); fflush(stdout);
")})));
end Dgelsx;
end CEval;
end ExternalFunction;


model QuotedIdentifierFunc1
    function '!#%'
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    end '!#%';

    function '&/('
        input Real x;
        output Real y;
    algorithm
        y := x + 1;
    end '&/(';

    Real z = '!#%'(time) + '&/('(time);
	
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="QuotedIdentifierFunc1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode=false,
            generate_dae=true,
            template="
$C_function_headers$
$C_functions$
$C_DAE_equation_residuals$
",
            generatedCode="
void func_CCodeGenTests_QuotedIdentifierFunc1_______def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp0(jmi_ad_var_t x_v);
void func_CCodeGenTests_QuotedIdentifierFunc1_______def1(jmi_ad_var_t x_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp1(jmi_ad_var_t x_v);

void func_CCodeGenTests_QuotedIdentifierFunc1_______def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = x_v + 1;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp0(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_QuotedIdentifierFunc1_______def0(x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_QuotedIdentifierFunc1_______def1(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = x_v + 1;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_QuotedIdentifierFunc1_______exp1(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_QuotedIdentifierFunc1_______def1(x_v, &y_v);
    return y_v;
}


    (*res)[0] = func_CCodeGenTests_QuotedIdentifierFunc1_______exp0(_time) + func_CCodeGenTests_QuotedIdentifierFunc1_______exp1(_time) - (_z_0);
")})));
end QuotedIdentifierFunc1;

model LoadResource1
    function strlen
        input String s;
        output Integer n;
        external;
    end strlen;
    parameter Integer y = strlen(Modelica.Utilities.Files.loadResource("modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt"));
    discrete  Integer z = strlen(Modelica.Utilities.Files.loadResource("modelica://Modelica/Resources/Data/Utilities/Examples_readRealParameters.txt"));
    
    discrete Integer rel  = strlen(Modelica.Utilities.Files.loadResource("../Data/String.txt"));
    discrete Integer abs  = strlen(Modelica.Utilities.Files.loadResource("/C:/home/user/Data/String.txt"));
    discrete Integer file = strlen(Modelica.Utilities.Files.loadResource("file:///C:/home/user/Data/String.txt"));
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="LoadResource1",
            description="",
            variability_propagation=false,
            template="
$C_ode_derivatives$
$C_DAE_initial_dependent_parameter_assignments$
",
            generatedCode="
    char tmp_1[JMI_PATH_MAX];
    char tmp_2[JMI_PATH_MAX];
    char tmp_3[JMI_PATH_MAX];
    char tmp_4[JMI_PATH_MAX];
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    jmi_load_resource(jmi, tmp_1, \"/0_Examples_readRealParameters.txt\");
    _z_1 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_1);
    jmi_load_resource(jmi, tmp_2, \"/1_String.txt\");
    _rel_2 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_2);
    jmi_load_resource(jmi, tmp_3, \"/2_String.txt\");
    _abs_3 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_3);
    jmi_load_resource(jmi, tmp_4, \"/2_String.txt\");
    _file_4 = func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_4);
/********* Write back reinits *******/

    char tmp_5[JMI_PATH_MAX];
    jmi_load_resource(jmi, tmp_5, \"/0_Examples_readRealParameters.txt\");
    _y_0 = (func_CCodeGenTests_LoadResource1_strlen_exp0(tmp_5));
")})));
end LoadResource1;

model IntegerEnumIndices
    type E = enumeration(ONE,TWO,THREE);
    constant Integer i1 = 1;
    parameter Integer i2 = 2;
    Integer i3 = integer(time);
    constant E e1 = E.ONE;
    parameter E e2 = E.TWO;
    E e3 = if i3 > 0 then E.THREE else E.TWO;
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="IntegerAndEnumIndices",
            description="Check that indices given to integers and enums don't overlap. #3871",
            variability_propagation=false,
            template="
$C_variable_aliases$
",
            generatedCode="
#define _i1_0 ((*(jmi->z))[jmi->offs_integer_ci+0])
#define _e1_3 ((*(jmi->z))[jmi->offs_integer_ci+1])
#define _i2_1 ((*(jmi->z))[jmi->offs_integer_pi+0])
#define _e2_4 ((*(jmi->z))[jmi->offs_integer_pi+1])
#define _time ((*(jmi->z))[jmi->offs_t])
#define _i3_2 ((*(jmi->z))[jmi->offs_integer_d+0])
#define _e3_5 ((*(jmi->z))[jmi->offs_integer_d+1])
#define pre_i3_2 ((*(jmi->z))[jmi->offs_pre_integer_d+0])
#define pre_e3_5 ((*(jmi->z))[jmi->offs_pre_integer_d+1])
")})));
end IntegerEnumIndices;

model Functional1
    partial function partFunc
        output Real y;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x;
      algorithm
        y := x*x;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf1;
        input partFunc pf2;
        input Real x;
        output Real y;
      algorithm
        y := pf1() + pf2();
    end usePartFunc;

    Real y = usePartFunc(function fullFunc(x=time), function fullFunc(x=time), time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional1",
            description="Code generation for functional input arguments. Basic.",
            variability_propagation=false,
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional1_fullFunc_fpout2_ func_CCodeGenTests_Functional1_fullFunc_fpout2;
struct func_CCodeGenTests_Functional1_fullFunc_fpout2_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional1_fullFunc_fp2_ func_CCodeGenTests_Functional1_fullFunc_fp2;
struct func_CCodeGenTests_Functional1_fullFunc_fp2_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional1_fullFunc_fp2*, func_CCodeGenTests_Functional1_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional1_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional1_fullFunc_fp2*, func_CCodeGenTests_Functional1_fullFunc_fp2*, ...);
    jmi_ad_var_t x_v;
    int x_v_s;
};
typedef struct func_CCodeGenTests_Functional1_partFunc_fpout1_ func_CCodeGenTests_Functional1_partFunc_fpout1;
struct func_CCodeGenTests_Functional1_partFunc_fpout1_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional1_partFunc_fp1_ func_CCodeGenTests_Functional1_partFunc_fp1;
struct func_CCodeGenTests_Functional1_partFunc_fp1_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional1_partFunc_fp1*, func_CCodeGenTests_Functional1_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional1_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional1_partFunc_fp1*, func_CCodeGenTests_Functional1_partFunc_fp1*, ...);
};
jmi_ad_var_t func_CCodeGenTests_Functional1_fullFunc_fpcl2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional1_fullFunc_fp2* func_CCodeGenTests_Functional1_fullFunc_fpcr2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional1_usePartFunc_def0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_ad_var_t x_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional1_usePartFunc_exp0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_ad_var_t x_v);
void func_CCodeGenTests_Functional1_partFunc_def1(jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional1_partFunc_exp1();
void func_CCodeGenTests_Functional1_fullFunc_def2(jmi_ad_var_t x_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional1_fullFunc_exp2(jmi_ad_var_t x_v);

jmi_ad_var_t func_CCodeGenTests_Functional1_fullFunc_fpcl2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fpout2* out, ...) {
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x_v_s) {
        tmp_1 = fp_in->x_v;
    } else {
        tmp_1 = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional1_fullFunc_def2(tmp_1, &tmp_2);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_2;
        }
    }
    return tmp_2;
}

func_CCodeGenTests_Functional1_fullFunc_fp2* func_CCodeGenTests_Functional1_fullFunc_fpcr2(func_CCodeGenTests_Functional1_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional1_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional1_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional1_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional1_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x_v_s = 0;
    } else {
        fp_out->x_v_s = fp_in->x_v_s;
        fp_out->x_v = fp_in->x_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x_v_s && va_arg(argp, int)) {
        fp_out->x_v_s = 1;
        fp_out->x_v = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional1_usePartFunc_def0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = pf1_v->fpcl(pf1_v, NULL) + pf2_v->fpcl(pf2_v, NULL);
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional1_usePartFunc_exp0(func_CCodeGenTests_Functional1_partFunc_fp1* pf1_v, func_CCodeGenTests_Functional1_partFunc_fp1* pf2_v, jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional1_usePartFunc_def0(pf1_v, pf2_v, x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional1_partFunc_def1(jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional1_partFunc_exp1() {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional1_partFunc_def1(&y_v);
    return y_v;
}

void func_CCodeGenTests_Functional1_fullFunc_def2(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = x_v * x_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional1_fullFunc_exp2(jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional1_fullFunc_def2(x_v, &y_v);
    return y_v;
}


    func_CCodeGenTests_Functional1_fullFunc_fp2 tmp_1;
    func_CCodeGenTests_Functional1_fullFunc_fp2 tmp_2;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _y_0 = func_CCodeGenTests_Functional1_usePartFunc_exp0((func_CCodeGenTests_Functional1_partFunc_fp1*)func_CCodeGenTests_Functional1_fullFunc_fpcr2(NULL, &tmp_1, 1, (jmi_ad_var_t)(_time)), (func_CCodeGenTests_Functional1_partFunc_fp1*)func_CCodeGenTests_Functional1_fullFunc_fpcr2(NULL, &tmp_2, 1, (jmi_ad_var_t)(_time)), _time);
/********* Write back reinits *******/


")})));
end Functional1;

model Functional2
    record R
        Real x;
        Integer y;
        String s;
    end R;
    
    partial function partFunc
        input Real x1;
        input Real x2;
        output Real y1;
        output Real y2;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input R r;
        input Real a;
        output Real b;
      algorithm
        y1 := r.x + r.y + x1 + x2 + a;
        y2 := y1 + 1;
        b := y2 + 1;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
        output Real y;
      protected
        Real y1,y2;
      algorithm
        (y1,y2) := pf(x, x+1);
        y := y1 + y2;
    end usePartFunc;

    Real y = usePartFunc(function fullFunc(r=R(time, 1, "string"), a=time+1), time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional2",
            description="Code generation for functional input arguments. Multiple inputs and outputs.",
            variability_propagation=false,
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional2_fullFunc_fpout2_ func_CCodeGenTests_Functional2_fullFunc_fpout2;
struct func_CCodeGenTests_Functional2_fullFunc_fpout2_ {
    int n;
    jmi_ad_var_t y1_v;
    jmi_ad_var_t y2_v;
    jmi_ad_var_t b_v;
};
typedef struct func_CCodeGenTests_Functional2_fullFunc_fp2_ func_CCodeGenTests_Functional2_fullFunc_fp2;
struct func_CCodeGenTests_Functional2_fullFunc_fp2_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional2_fullFunc_fp2*, func_CCodeGenTests_Functional2_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional2_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional2_fullFunc_fp2*, func_CCodeGenTests_Functional2_fullFunc_fp2*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x2_v;
    int x2_v_s;
    R_0_r* r_v;
    int r_v_s;
    jmi_ad_var_t a_v;
    int a_v_s;
};
typedef struct func_CCodeGenTests_Functional2_partFunc_fpout1_ func_CCodeGenTests_Functional2_partFunc_fpout1;
struct func_CCodeGenTests_Functional2_partFunc_fpout1_ {
    int n;
    jmi_ad_var_t y1_v;
    jmi_ad_var_t y2_v;
};
typedef struct func_CCodeGenTests_Functional2_partFunc_fp1_ func_CCodeGenTests_Functional2_partFunc_fp1;
struct func_CCodeGenTests_Functional2_partFunc_fp1_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional2_partFunc_fp1*, func_CCodeGenTests_Functional2_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional2_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional2_partFunc_fp1*, func_CCodeGenTests_Functional2_partFunc_fp1*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x2_v;
    int x2_v_s;
};
jmi_ad_var_t func_CCodeGenTests_Functional2_fullFunc_fpcl2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional2_fullFunc_fp2* func_CCodeGenTests_Functional2_fullFunc_fpcr2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional2_usePartFunc_def0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_ad_var_t x_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional2_usePartFunc_exp0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_ad_var_t x_v);
void func_CCodeGenTests_Functional2_partFunc_def1(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t* y1_o, jmi_ad_var_t* y2_o);
jmi_ad_var_t func_CCodeGenTests_Functional2_partFunc_exp1(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v);
void func_CCodeGenTests_Functional2_fullFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, R_0_r* r_v, jmi_ad_var_t a_v, jmi_ad_var_t* y1_o, jmi_ad_var_t* y2_o, jmi_ad_var_t* b_o);
jmi_ad_var_t func_CCodeGenTests_Functional2_fullFunc_exp2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, R_0_r* r_v, jmi_ad_var_t a_v);

jmi_ad_var_t func_CCodeGenTests_Functional2_fullFunc_fpcl2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fpout2* out, ...) {
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    R_0_r* tmp_3;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_6;
    jmi_ad_var_t tmp_7;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->r_v_s) {
        tmp_3 = fp_in->r_v;
    } else {
        tmp_3 = va_arg(argp, R_0_r*);
    }
    if (fp_in->a_v_s) {
        tmp_4 = fp_in->a_v;
    } else {
        tmp_4 = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional2_fullFunc_def2(tmp_1, tmp_2, tmp_3, tmp_4, &tmp_5, &tmp_6, &tmp_7);
    if (out != NULL) {
        if (out->n > 0) {
            out->y1_v = tmp_5;
        }
        if (out->n > 1) {
            out->y2_v = tmp_6;
        }
        if (out->n > 2) {
            out->b_v = tmp_7;
        }
    }
    return tmp_5;
}

func_CCodeGenTests_Functional2_fullFunc_fp2* func_CCodeGenTests_Functional2_fullFunc_fpcr2(func_CCodeGenTests_Functional2_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional2_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional2_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional2_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional2_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
        fp_out->r_v_s = 0;
        fp_out->a_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
        fp_out->r_v_s = fp_in->r_v_s;
        fp_out->r_v = fp_in->r_v;
        fp_out->a_v_s = fp_in->a_v_s;
        fp_out->a_v = fp_in->a_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->r_v_s && va_arg(argp, int)) {
        fp_out->r_v_s = 1;
        fp_out->r_v = va_arg(argp, R_0_r*);
    }
    if (!fp_out->a_v_s && va_arg(argp, int)) {
        fp_out->a_v_s = 1;
        fp_out->a_v = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional2_usePartFunc_def0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    jmi_ad_var_t y1_v;
    jmi_ad_var_t y2_v;
    func_CCodeGenTests_Functional2_partFunc_fpout1 tmp_1;
    tmp_1.n = 2;
    pf_v->fpcl(pf_v, &tmp_1, (jmi_ad_var_t)(x_v), (jmi_ad_var_t)(x_v + AD_WRAP_LITERAL(1)));
    y1_v = tmp_1.y1_v;
    y2_v = tmp_1.y2_v;
    y_v = y1_v + y2_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional2_usePartFunc_exp0(func_CCodeGenTests_Functional2_partFunc_fp1* pf_v, jmi_ad_var_t x_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional2_usePartFunc_def0(pf_v, x_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional2_partFunc_def1(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t* y1_o, jmi_ad_var_t* y2_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y1_v;
    jmi_ad_var_t y2_v;
    if (y1_o != NULL) *y1_o = y1_v;
    if (y2_o != NULL) *y2_o = y2_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional2_partFunc_exp1(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v) {
    jmi_ad_var_t y1_v;
    func_CCodeGenTests_Functional2_partFunc_def1(x1_v, x2_v, &y1_v, NULL);
    return y1_v;
}

void func_CCodeGenTests_Functional2_fullFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, R_0_r* r_v, jmi_ad_var_t a_v, jmi_ad_var_t* y1_o, jmi_ad_var_t* y2_o, jmi_ad_var_t* b_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y1_v;
    jmi_ad_var_t y2_v;
    jmi_ad_var_t b_v;
    y1_v = r_v->x + r_v->y + x1_v + x2_v + a_v;
    y2_v = y1_v + 1;
    b_v = y2_v + 1;
    if (y1_o != NULL) *y1_o = y1_v;
    if (y2_o != NULL) *y2_o = y2_v;
    if (b_o != NULL) *b_o = b_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional2_fullFunc_exp2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, R_0_r* r_v, jmi_ad_var_t a_v) {
    jmi_ad_var_t y1_v;
    func_CCodeGenTests_Functional2_fullFunc_def2(x1_v, x2_v, r_v, a_v, &y1_v, NULL, NULL);
    return y1_v;
}


    JMI_RECORD_STATIC(R_0_r, tmp_1)
    func_CCodeGenTests_Functional2_fullFunc_fp2 tmp_2;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    tmp_1->x = _time;
    tmp_1->y = AD_WRAP_LITERAL(1);
    tmp_1->s = \"string\";
    _y_0 = func_CCodeGenTests_Functional2_usePartFunc_exp0((func_CCodeGenTests_Functional2_partFunc_fp1*)func_CCodeGenTests_Functional2_fullFunc_fpcr2(NULL, &tmp_2, 0, 0, 1, (R_0_r*)(tmp_1), 1, (jmi_ad_var_t)(_time + AD_WRAP_LITERAL(1))), _time);
/********* Write back reinits *******/


")})));
end Functional2;

model Functional3
    partial function partFunc
        input Real x1;
        output Real y;
    end partFunc;
    
    partial function middleFunc
        extends partFunc;
        input Real x2;
    end middleFunc;
    
    function fullFunc
        extends middleFunc;
        input Real x3;
      algorithm
        y := x1 + x2 + x3;
    end fullFunc;
    
    function useMiddleFunc
        input middleFunc mf;
        input Real b;
        input Real c;
        output Real y = usePartFunc(function mf(x2=b), c);
        algorithm
    end useMiddleFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real c;
        output Real y;
      algorithm
        y := pf(c);
    end usePartFunc;

    Real y = useMiddleFunc(function fullFunc(x3=time), time, time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional3",
            description="Code generation for functional input arguments. Chained.",
            variability_propagation=false,
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional3_fullFunc_fpout4_ func_CCodeGenTests_Functional3_fullFunc_fpout4;
struct func_CCodeGenTests_Functional3_fullFunc_fpout4_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional3_fullFunc_fp4_ func_CCodeGenTests_Functional3_fullFunc_fp4;
struct func_CCodeGenTests_Functional3_fullFunc_fp4_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional3_fullFunc_fp4*, func_CCodeGenTests_Functional3_fullFunc_fpout4*, ...);
    func_CCodeGenTests_Functional3_fullFunc_fp4* (*fpcr)(func_CCodeGenTests_Functional3_fullFunc_fp4*, func_CCodeGenTests_Functional3_fullFunc_fp4*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x2_v;
    int x2_v_s;
    jmi_ad_var_t x3_v;
    int x3_v_s;
};
typedef struct func_CCodeGenTests_Functional3_partFunc_fpout1_ func_CCodeGenTests_Functional3_partFunc_fpout1;
struct func_CCodeGenTests_Functional3_partFunc_fpout1_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional3_partFunc_fp1_ func_CCodeGenTests_Functional3_partFunc_fp1;
struct func_CCodeGenTests_Functional3_partFunc_fp1_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional3_partFunc_fp1*, func_CCodeGenTests_Functional3_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional3_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional3_partFunc_fp1*, func_CCodeGenTests_Functional3_partFunc_fp1*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
};
typedef struct func_CCodeGenTests_Functional3_middleFunc_fpout2_ func_CCodeGenTests_Functional3_middleFunc_fpout2;
struct func_CCodeGenTests_Functional3_middleFunc_fpout2_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional3_middleFunc_fp2_ func_CCodeGenTests_Functional3_middleFunc_fp2;
struct func_CCodeGenTests_Functional3_middleFunc_fp2_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional3_middleFunc_fp2*, func_CCodeGenTests_Functional3_middleFunc_fpout2*, ...);
    func_CCodeGenTests_Functional3_middleFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional3_middleFunc_fp2*, func_CCodeGenTests_Functional3_middleFunc_fp2*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x2_v;
    int x2_v_s;
};
jmi_ad_var_t func_CCodeGenTests_Functional3_fullFunc_fpcl4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fpout4* out, ...);
func_CCodeGenTests_Functional3_fullFunc_fp4* func_CCodeGenTests_Functional3_fullFunc_fpcr4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fp4* fp_out, ...);
jmi_ad_var_t func_CCodeGenTests_Functional3_middleFunc_fpcl2(func_CCodeGenTests_Functional3_middleFunc_fp2* fp_in, func_CCodeGenTests_Functional3_middleFunc_fpout2* out, ...);
func_CCodeGenTests_Functional3_middleFunc_fp2* func_CCodeGenTests_Functional3_middleFunc_fpcr2(func_CCodeGenTests_Functional3_middleFunc_fp2* fp_in, func_CCodeGenTests_Functional3_middleFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional3_usePartFunc_def0(func_CCodeGenTests_Functional3_partFunc_fp1* pf_v, jmi_ad_var_t c_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional3_usePartFunc_exp0(func_CCodeGenTests_Functional3_partFunc_fp1* pf_v, jmi_ad_var_t c_v);
void func_CCodeGenTests_Functional3_partFunc_def1(jmi_ad_var_t x1_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional3_partFunc_exp1(jmi_ad_var_t x1_v);
void func_CCodeGenTests_Functional3_middleFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional3_middleFunc_exp2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v);
void func_CCodeGenTests_Functional3_useMiddleFunc_def3(func_CCodeGenTests_Functional3_middleFunc_fp2* mf_v, jmi_ad_var_t b_v, jmi_ad_var_t c_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional3_useMiddleFunc_exp3(func_CCodeGenTests_Functional3_middleFunc_fp2* mf_v, jmi_ad_var_t b_v, jmi_ad_var_t c_v);
void func_CCodeGenTests_Functional3_fullFunc_def4(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional3_fullFunc_exp4(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v);

jmi_ad_var_t func_CCodeGenTests_Functional3_fullFunc_fpcl4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fpout4* out, ...) {
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x3_v_s) {
        tmp_3 = fp_in->x3_v;
    } else {
        tmp_3 = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional3_fullFunc_def4(tmp_1, tmp_2, tmp_3, &tmp_4);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_4;
        }
    }
    return tmp_4;
}

func_CCodeGenTests_Functional3_fullFunc_fp4* func_CCodeGenTests_Functional3_fullFunc_fpcr4(func_CCodeGenTests_Functional3_fullFunc_fp4* fp_in, func_CCodeGenTests_Functional3_fullFunc_fp4* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional3_fullFunc_fp4));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional3_fullFunc_fpcl4;
    fp_out->fpcr = &func_CCodeGenTests_Functional3_fullFunc_fpcr4;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
        fp_out->x3_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
        fp_out->x3_v_s = fp_in->x3_v_s;
        fp_out->x3_v = fp_in->x3_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x3_v_s && va_arg(argp, int)) {
        fp_out->x3_v_s = 1;
        fp_out->x3_v = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    return fp_out;
}

jmi_ad_var_t func_CCodeGenTests_Functional3_middleFunc_fpcl2(func_CCodeGenTests_Functional3_middleFunc_fp2* fp_in, func_CCodeGenTests_Functional3_middleFunc_fpout2* out, ...) {
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional3_middleFunc_def2(tmp_1, tmp_2, &tmp_3);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_3;
        }
    }
    return tmp_3;
}

func_CCodeGenTests_Functional3_middleFunc_fp2* func_CCodeGenTests_Functional3_middleFunc_fpcr2(func_CCodeGenTests_Functional3_middleFunc_fp2* fp_in, func_CCodeGenTests_Functional3_middleFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional3_middleFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional3_middleFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional3_middleFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional3_usePartFunc_def0(func_CCodeGenTests_Functional3_partFunc_fp1* pf_v, jmi_ad_var_t c_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = pf_v->fpcl(pf_v, NULL, (jmi_ad_var_t)(c_v));
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional3_usePartFunc_exp0(func_CCodeGenTests_Functional3_partFunc_fp1* pf_v, jmi_ad_var_t c_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional3_usePartFunc_def0(pf_v, c_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_partFunc_def1(jmi_ad_var_t x1_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional3_partFunc_exp1(jmi_ad_var_t x1_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional3_partFunc_def1(x1_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_middleFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional3_middleFunc_exp2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional3_middleFunc_def2(x1_v, x2_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_useMiddleFunc_def3(func_CCodeGenTests_Functional3_middleFunc_fp2* mf_v, jmi_ad_var_t b_v, jmi_ad_var_t c_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional3_middleFunc_fp2* tmp_1;
    tmp_1 = mf_v->fpcr(mf_v, NULL, 0, 1, (jmi_ad_var_t)(b_v));
    JMI_DYNAMIC_ADD(tmp_1)
    y_v = func_CCodeGenTests_Functional3_usePartFunc_exp0((func_CCodeGenTests_Functional3_partFunc_fp1*)tmp_1, c_v);
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional3_useMiddleFunc_exp3(func_CCodeGenTests_Functional3_middleFunc_fp2* mf_v, jmi_ad_var_t b_v, jmi_ad_var_t c_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional3_useMiddleFunc_def3(mf_v, b_v, c_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional3_fullFunc_def4(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = x1_v + x2_v + x3_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional3_fullFunc_exp4(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional3_fullFunc_def4(x1_v, x2_v, x3_v, &y_v);
    return y_v;
}


    func_CCodeGenTests_Functional3_fullFunc_fp4 tmp_1;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _y_0 = func_CCodeGenTests_Functional3_useMiddleFunc_exp3((func_CCodeGenTests_Functional3_middleFunc_fp2*)func_CCodeGenTests_Functional3_fullFunc_fpcr4(NULL, &tmp_1, 0, 0, 1, (jmi_ad_var_t)(_time)), _time, _time);
/********* Write back reinits *******/



")})));
end Functional3;

model Functional4
    partial function partFunc
        input Real x1;
    end partFunc;
    
    function fullFunc
        extends partFunc;
        input Real x2;
      algorithm
        assert(x1 < x2, "msg");
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        input Real x;
      algorithm
        pf(x);
    end usePartFunc;
  equation
    usePartFunc(function fullFunc(x2=time+1), time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional4",
            description="Code generation for functional input arguments. No output.",
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional4_fullFunc_fpout2_ func_CCodeGenTests_Functional4_fullFunc_fpout2;
struct func_CCodeGenTests_Functional4_fullFunc_fpout2_ {
    int n;
};
typedef struct func_CCodeGenTests_Functional4_fullFunc_fp2_ func_CCodeGenTests_Functional4_fullFunc_fp2;
struct func_CCodeGenTests_Functional4_fullFunc_fp2_ {
    void (*fpcl)(func_CCodeGenTests_Functional4_fullFunc_fp2*, func_CCodeGenTests_Functional4_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional4_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional4_fullFunc_fp2*, func_CCodeGenTests_Functional4_fullFunc_fp2*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x2_v;
    int x2_v_s;
};
typedef struct func_CCodeGenTests_Functional4_partFunc_fpout1_ func_CCodeGenTests_Functional4_partFunc_fpout1;
struct func_CCodeGenTests_Functional4_partFunc_fpout1_ {
    int n;
};
typedef struct func_CCodeGenTests_Functional4_partFunc_fp1_ func_CCodeGenTests_Functional4_partFunc_fp1;
struct func_CCodeGenTests_Functional4_partFunc_fp1_ {
    void (*fpcl)(func_CCodeGenTests_Functional4_partFunc_fp1*, func_CCodeGenTests_Functional4_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional4_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional4_partFunc_fp1*, func_CCodeGenTests_Functional4_partFunc_fp1*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
};
void func_CCodeGenTests_Functional4_fullFunc_fpcl2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional4_fullFunc_fp2* func_CCodeGenTests_Functional4_fullFunc_fpcr2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional4_usePartFunc_def0(func_CCodeGenTests_Functional4_partFunc_fp1* pf_v, jmi_ad_var_t x_v);
void func_CCodeGenTests_Functional4_partFunc_def1(jmi_ad_var_t x1_v);
void func_CCodeGenTests_Functional4_fullFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v);

void func_CCodeGenTests_Functional4_fullFunc_fpcl2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fpout2* out, ...) {
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional4_fullFunc_def2(tmp_1, tmp_2);
    if (out != NULL) {
    }
}

func_CCodeGenTests_Functional4_fullFunc_fp2* func_CCodeGenTests_Functional4_fullFunc_fpcr2(func_CCodeGenTests_Functional4_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional4_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional4_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional4_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional4_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional4_usePartFunc_def0(func_CCodeGenTests_Functional4_partFunc_fp1* pf_v, jmi_ad_var_t x_v) {
    JMI_DYNAMIC_INIT()
    func_CCodeGenTests_Functional4_partFunc_fpout1 tmp_1;
    tmp_1.n = 0;
    pf_v->fpcl(pf_v, &tmp_1, (jmi_ad_var_t)(x_v));
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_Functional4_partFunc_def1(jmi_ad_var_t x1_v) {
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return;
}

void func_CCodeGenTests_Functional4_fullFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v) {
    JMI_DYNAMIC_INIT()
    if (COND_EXP_LT(x1_v, x2_v, JMI_TRUE, JMI_FALSE) == JMI_FALSE) {
        jmi_assert_failed(\"msg\", JMI_ASSERT_ERROR);
    }
    JMI_DYNAMIC_FREE()
    return;
}


    func_CCodeGenTests_Functional4_fullFunc_fp2 tmp_1;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    func_CCodeGenTests_Functional4_usePartFunc_def0((func_CCodeGenTests_Functional4_partFunc_fp1*)func_CCodeGenTests_Functional4_fullFunc_fpcr2(NULL, &tmp_1, 0, 1, (jmi_ad_var_t)(_time + AD_WRAP_LITERAL(1))), _time);
/********* Write back reinits *******/



")})));
end Functional4;

model Functional5
    partial function partFunc
        input Real x1;
        input Real x3;
        input Real x5;
        output Real y;
    end partFunc;
    
    function fullFunc
        input Real x1;
        input Real x2;
        input Real x3;
        input Real x4;
        input Real x5;
        output Real y;
      algorithm
        y := x1 + x2 + x3 + x4 + x5;
    end fullFunc;
    
    function usePartFunc
        input partFunc pf;
        output Real y;
      algorithm
        y := pf(1,3,5);
    end usePartFunc;
    
    function usePartAlias = usePartFunc;
    
    Real y1 = usePartFunc(function fullFunc(x2=time, x4=4));
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="Functional5",
            description="Code generation for functional input arguments. Interleaving binds.",
            generate_ode=true,
            equation_sorting=true,
            template="
$C_function_headers$
$C_functions$
$C_ode_derivatives$
",
            generatedCode="
typedef struct func_CCodeGenTests_Functional5_fullFunc_fpout2_ func_CCodeGenTests_Functional5_fullFunc_fpout2;
struct func_CCodeGenTests_Functional5_fullFunc_fpout2_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional5_fullFunc_fp2_ func_CCodeGenTests_Functional5_fullFunc_fp2;
struct func_CCodeGenTests_Functional5_fullFunc_fp2_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional5_fullFunc_fp2*, func_CCodeGenTests_Functional5_fullFunc_fpout2*, ...);
    func_CCodeGenTests_Functional5_fullFunc_fp2* (*fpcr)(func_CCodeGenTests_Functional5_fullFunc_fp2*, func_CCodeGenTests_Functional5_fullFunc_fp2*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x2_v;
    int x2_v_s;
    jmi_ad_var_t x3_v;
    int x3_v_s;
    jmi_ad_var_t x4_v;
    int x4_v_s;
    jmi_ad_var_t x5_v;
    int x5_v_s;
};
typedef struct func_CCodeGenTests_Functional5_partFunc_fpout1_ func_CCodeGenTests_Functional5_partFunc_fpout1;
struct func_CCodeGenTests_Functional5_partFunc_fpout1_ {
    int n;
    jmi_ad_var_t y_v;
};
typedef struct func_CCodeGenTests_Functional5_partFunc_fp1_ func_CCodeGenTests_Functional5_partFunc_fp1;
struct func_CCodeGenTests_Functional5_partFunc_fp1_ {
    jmi_ad_var_t (*fpcl)(func_CCodeGenTests_Functional5_partFunc_fp1*, func_CCodeGenTests_Functional5_partFunc_fpout1*, ...);
    func_CCodeGenTests_Functional5_partFunc_fp1* (*fpcr)(func_CCodeGenTests_Functional5_partFunc_fp1*, func_CCodeGenTests_Functional5_partFunc_fp1*, ...);
    jmi_ad_var_t x1_v;
    int x1_v_s;
    jmi_ad_var_t x3_v;
    int x3_v_s;
    jmi_ad_var_t x5_v;
    int x5_v_s;
};
jmi_ad_var_t func_CCodeGenTests_Functional5_fullFunc_fpcl2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fpout2* out, ...);
func_CCodeGenTests_Functional5_fullFunc_fp2* func_CCodeGenTests_Functional5_fullFunc_fpcr2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fp2* fp_out, ...);
void func_CCodeGenTests_Functional5_usePartFunc_def0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional5_usePartFunc_exp0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v);
void func_CCodeGenTests_Functional5_partFunc_def1(jmi_ad_var_t x1_v, jmi_ad_var_t x3_v, jmi_ad_var_t x5_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional5_partFunc_exp1(jmi_ad_var_t x1_v, jmi_ad_var_t x3_v, jmi_ad_var_t x5_v);
void func_CCodeGenTests_Functional5_fullFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v, jmi_ad_var_t x4_v, jmi_ad_var_t x5_v, jmi_ad_var_t* y_o);
jmi_ad_var_t func_CCodeGenTests_Functional5_fullFunc_exp2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v, jmi_ad_var_t x4_v, jmi_ad_var_t x5_v);

jmi_ad_var_t func_CCodeGenTests_Functional5_fullFunc_fpcl2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fpout2* out, ...) {
    jmi_ad_var_t tmp_1;
    jmi_ad_var_t tmp_2;
    jmi_ad_var_t tmp_3;
    jmi_ad_var_t tmp_4;
    jmi_ad_var_t tmp_5;
    jmi_ad_var_t tmp_6;
    va_list argp;
    va_start(argp, out);
    if (fp_in->x1_v_s) {
        tmp_1 = fp_in->x1_v;
    } else {
        tmp_1 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x2_v_s) {
        tmp_2 = fp_in->x2_v;
    } else {
        tmp_2 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x3_v_s) {
        tmp_3 = fp_in->x3_v;
    } else {
        tmp_3 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x4_v_s) {
        tmp_4 = fp_in->x4_v;
    } else {
        tmp_4 = va_arg(argp, jmi_ad_var_t);
    }
    if (fp_in->x5_v_s) {
        tmp_5 = fp_in->x5_v;
    } else {
        tmp_5 = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    func_CCodeGenTests_Functional5_fullFunc_def2(tmp_1, tmp_2, tmp_3, tmp_4, tmp_5, &tmp_6);
    if (out != NULL) {
        if (out->n > 0) {
            out->y_v = tmp_6;
        }
    }
    return tmp_6;
}

func_CCodeGenTests_Functional5_fullFunc_fp2* func_CCodeGenTests_Functional5_fullFunc_fpcr2(func_CCodeGenTests_Functional5_fullFunc_fp2* fp_in, func_CCodeGenTests_Functional5_fullFunc_fp2* fp_out, ...) {
    va_list argp;
    if (fp_out == NULL) {
        fp_out = malloc(sizeof(func_CCodeGenTests_Functional5_fullFunc_fp2));
    }
    fp_out->fpcl = &func_CCodeGenTests_Functional5_fullFunc_fpcl2;
    fp_out->fpcr = &func_CCodeGenTests_Functional5_fullFunc_fpcr2;
    if (fp_in == NULL) {
        fp_out->x1_v_s = 0;
        fp_out->x2_v_s = 0;
        fp_out->x3_v_s = 0;
        fp_out->x4_v_s = 0;
        fp_out->x5_v_s = 0;
    } else {
        fp_out->x1_v_s = fp_in->x1_v_s;
        fp_out->x1_v = fp_in->x1_v;
        fp_out->x2_v_s = fp_in->x2_v_s;
        fp_out->x2_v = fp_in->x2_v;
        fp_out->x3_v_s = fp_in->x3_v_s;
        fp_out->x3_v = fp_in->x3_v;
        fp_out->x4_v_s = fp_in->x4_v_s;
        fp_out->x4_v = fp_in->x4_v;
        fp_out->x5_v_s = fp_in->x5_v_s;
        fp_out->x5_v = fp_in->x5_v;
    }
    va_start(argp, fp_out);
    if (!fp_out->x1_v_s && va_arg(argp, int)) {
        fp_out->x1_v_s = 1;
        fp_out->x1_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x2_v_s && va_arg(argp, int)) {
        fp_out->x2_v_s = 1;
        fp_out->x2_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x3_v_s && va_arg(argp, int)) {
        fp_out->x3_v_s = 1;
        fp_out->x3_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x4_v_s && va_arg(argp, int)) {
        fp_out->x4_v_s = 1;
        fp_out->x4_v = va_arg(argp, jmi_ad_var_t);
    }
    if (!fp_out->x5_v_s && va_arg(argp, int)) {
        fp_out->x5_v_s = 1;
        fp_out->x5_v = va_arg(argp, jmi_ad_var_t);
    }
    va_end(argp);
    return fp_out;
}

void func_CCodeGenTests_Functional5_usePartFunc_def0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = pf_v->fpcl(pf_v, NULL, (jmi_ad_var_t)(AD_WRAP_LITERAL(1)), (jmi_ad_var_t)(AD_WRAP_LITERAL(3)), (jmi_ad_var_t)(AD_WRAP_LITERAL(5)));
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional5_usePartFunc_exp0(func_CCodeGenTests_Functional5_partFunc_fp1* pf_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional5_usePartFunc_def0(pf_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional5_partFunc_def1(jmi_ad_var_t x1_v, jmi_ad_var_t x3_v, jmi_ad_var_t x5_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional5_partFunc_exp1(jmi_ad_var_t x1_v, jmi_ad_var_t x3_v, jmi_ad_var_t x5_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional5_partFunc_def1(x1_v, x3_v, x5_v, &y_v);
    return y_v;
}

void func_CCodeGenTests_Functional5_fullFunc_def2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v, jmi_ad_var_t x4_v, jmi_ad_var_t x5_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    jmi_ad_var_t y_v;
    y_v = x1_v + x2_v + x3_v + x4_v + x5_v;
    if (y_o != NULL) *y_o = y_v;
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenTests_Functional5_fullFunc_exp2(jmi_ad_var_t x1_v, jmi_ad_var_t x2_v, jmi_ad_var_t x3_v, jmi_ad_var_t x4_v, jmi_ad_var_t x5_v) {
    jmi_ad_var_t y_v;
    func_CCodeGenTests_Functional5_fullFunc_def2(x1_v, x2_v, x3_v, x4_v, x5_v, &y_v);
    return y_v;
}


    func_CCodeGenTests_Functional5_fullFunc_fp2 tmp_1;
    model_ode_guards(jmi);
/************* ODE section *********/
/************ Real outputs *********/
/****Integer and boolean outputs ***/
/**** Other variables ***/
    _y1_0 = func_CCodeGenTests_Functional5_usePartFunc_exp0((func_CCodeGenTests_Functional5_partFunc_fp1*)func_CCodeGenTests_Functional5_fullFunc_fpcr2(NULL, &tmp_1, 0, 1, (jmi_ad_var_t)(_time), 0, 1, (jmi_ad_var_t)(AD_WRAP_LITERAL(4)), 0));
/********* Write back reinits *******/



")})));
end Functional5;

end CCodeGenTests;
