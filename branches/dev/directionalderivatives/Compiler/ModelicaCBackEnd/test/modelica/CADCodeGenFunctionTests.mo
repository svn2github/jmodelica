/*
    Copyright (C) 2015-2017 Modelon AB

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
package CADCodeGenFunctionTests

model CADFunction1

	function F
		input Real x;
		output Real y;
	algorithm
		y := x;
	end F;
	Real a(start=2);
	equation
		der(a) = F(a);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction1_F_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    y_var_v = x_var_v;
    y_der_v = x_der_v;
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    jmi_real_t v_0;
    jmi_real_t d_0;
    func_CADCodeGenFunctionTests_CADFunction1_F_der_AD0(_a_0, (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx], &v_0, &d_0);
    (*res)[0] = v_0 - (_der_a_1);
    (*dF)[0] = d_0 - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
")})));
  end CADFunction1;

  model CADFunction2

	function F
		input Real x;
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2;
		b := x*4;
		c := x*8;
	end F;
	Real x(start=5);
	equation
		der(x) = F(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction2",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction2_F_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* a_var_o, jmi_real_t* b_var_o, jmi_real_t* c_var_o, jmi_real_t* a_der_o, jmi_real_t* b_der_o, jmi_real_t* c_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, a_var_v)
    JMI_DEF(REA, a_der_v)
    JMI_DEF(REA, b_var_v)
    JMI_DEF(REA, b_der_v)
    JMI_DEF(REA, c_var_v)
    JMI_DEF(REA, c_der_v)
    a_var_v = x_var_v * 2;
    a_der_v = x_der_v * 2 + x_var_v * AD_WRAP_LITERAL(0);
    b_var_v = x_var_v * 4;
    b_der_v = x_der_v * 4 + x_var_v * AD_WRAP_LITERAL(0);
    c_var_v = x_var_v * 8;
    c_der_v = x_der_v * 8 + x_var_v * AD_WRAP_LITERAL(0);
    if (a_var_o != NULL) *a_var_o = a_var_v;
    if (a_der_o != NULL) *a_der_o = a_der_v;
    if (b_var_o != NULL) *b_var_o = b_var_v;
    if (b_der_o != NULL) *b_der_o = b_der_v;
    if (c_var_o != NULL) *c_var_o = c_var_v;
    if (c_der_o != NULL) *c_der_o = c_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    jmi_real_t v_0;
    jmi_real_t d_0;
    func_CADCodeGenFunctionTests_CADFunction2_F_der_AD0(_x_0, (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx], &v_0, NULL, NULL, &d_0, NULL, NULL);
    (*res)[0] = v_0 - (_der_x_1);
    (*dF)[0] = d_0 - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
")})));
  end CADFunction2;
  

  model CADFunction3

	function F
		input Real x;
		output Real y;
	algorithm
		y := F2(x)^2;
	end F;
	function F2
		input Real x;
		output Real y;
	algorithm
		y := F3(x)^2;
	end F2;
	function F3
		input Real x;
		output Real y;
	algorithm
		y := x^2;
	end F3;
	Real a(start=5);
	equation
		der(a) = F(a)+F2(a);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction3",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction3_F_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_0;
    jmi_real_t v_1;
    jmi_real_t d_1;
    func_CADCodeGenFunctionTests_CADFunction3_F2_der_AD1(x_var_v, x_der_v, &v_1, &d_1);
    v_0 = (1.0 * (v_1) * (v_1));
    y_var_v = v_0;
    y_der_v = v_1 == 0 ? 0 : (v_0 * (AD_WRAP_LITERAL(0) * log(jmi_abs(v_1)) + 2 * d_1 / v_1));
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction3_F2_der_AD1(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_2;
    jmi_real_t v_3;
    jmi_real_t d_3;
    func_CADCodeGenFunctionTests_CADFunction3_F3_der_AD2(x_var_v, x_der_v, &v_3, &d_3);
    v_2 = (1.0 * (v_3) * (v_3));
    y_var_v = v_2;
    y_der_v = v_3 == 0 ? 0 : (v_2 * (AD_WRAP_LITERAL(0) * log(jmi_abs(v_3)) + 2 * d_3 / v_3));
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction3_F3_der_AD2(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_4;
    v_4 = (1.0 * (x_var_v) * (x_var_v));
    y_var_v = v_4;
    y_der_v = x_var_v == 0 ? 0 : (v_4 * (AD_WRAP_LITERAL(0) * log(jmi_abs(x_var_v)) + 2 * x_der_v / x_var_v));
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    jmi_real_t v_5;
    jmi_real_t d_5;
    jmi_real_t v_6;
    jmi_real_t d_6;
    func_CADCodeGenFunctionTests_CADFunction3_F_der_AD0(_a_0, (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx], &v_5, &d_5);
    func_CADCodeGenFunctionTests_CADFunction3_F2_der_AD1(_a_0, (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx], &v_6, &d_6);
    (*res)[0] = v_5 + v_6 - (_der_a_1);
    (*dF)[0] = d_5 + d_6 - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
")})));
  end CADFunction3; 
  
  
    model CADFunction4	

	function F
		input Real x; 
		output Real a;
		output Real b;
		output Real c;
	algorithm
		a := x*2;
		b := x*4;
		c := x*8;
	end F;
	function F2
		input Real x;
		output Real a;
	algorithm
		a := F(x)*x;
	end F2;
	Real x(start=5);
	equation
		der(x) = F2(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction4",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction4_F2_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* a_var_o, jmi_real_t* a_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, a_var_v)
    JMI_DEF(REA, a_der_v)
    jmi_real_t v_0;
    jmi_real_t d_0;
    func_CADCodeGenFunctionTests_CADFunction4_F_der_AD1(x_var_v, x_der_v, &v_0, NULL, NULL, &d_0, NULL, NULL);
    a_var_v = v_0 * x_var_v;
    a_der_v = d_0 * x_var_v + v_0 * x_der_v;
    if (a_var_o != NULL) *a_var_o = a_var_v;
    if (a_der_o != NULL) *a_der_o = a_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction4_F_der_AD1(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* a_var_o, jmi_real_t* b_var_o, jmi_real_t* c_var_o, jmi_real_t* a_der_o, jmi_real_t* b_der_o, jmi_real_t* c_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, a_var_v)
    JMI_DEF(REA, a_der_v)
    JMI_DEF(REA, b_var_v)
    JMI_DEF(REA, b_der_v)
    JMI_DEF(REA, c_var_v)
    JMI_DEF(REA, c_der_v)
    a_var_v = x_var_v * 2;
    a_der_v = x_der_v * 2 + x_var_v * AD_WRAP_LITERAL(0);
    b_var_v = x_var_v * 4;
    b_der_v = x_der_v * 4 + x_var_v * AD_WRAP_LITERAL(0);
    c_var_v = x_var_v * 8;
    c_der_v = x_der_v * 8 + x_var_v * AD_WRAP_LITERAL(0);
    if (a_var_o != NULL) *a_var_o = a_var_v;
    if (a_der_o != NULL) *a_der_o = a_der_v;
    if (b_var_o != NULL) *b_var_o = b_var_v;
    if (b_der_o != NULL) *b_der_o = b_der_v;
    if (c_var_o != NULL) *c_var_o = c_var_v;
    if (c_der_o != NULL) *c_der_o = c_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    jmi_real_t v_1;
    jmi_real_t d_1;
    func_CADCodeGenFunctionTests_CADFunction4_F2_der_AD0(_x_0, (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx], &v_1, &d_1);
    (*res)[0] = v_1 - (_der_x_1);
    (*dF)[0] = d_1 - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
")})));
  end CADFunction4; 

model CADFunction5

			function F
			input Real x;
			input Real x1;
			input Real x2;
			input Real x3;
			input Real x4;
			output Real a;
			output Real b;
			output Real c;
			output Real d;
			output Real e;
			output Real f;
			output Real g;
		algorithm
			a := x*2;
			b := x1*4;
			c := x2*8;
			d := x3*8;
			e := x4*8;
			f := x*x1*x2;
			g := x3*x4+x1;
		end F;
		Real x(start=5);
		Real x1(start=10);
		Real x2(start=15);
		Real x3(start=20);
		Real x4(start=25);
		 Real a;
		 Real b;
		 Real c;
		 Real d;
		 Real e;
		 Real f;
		 Real g;
		 input Real U(start=10);
		 output Real Y;
		equation
			der(x)   = x1*U;
			(a,b,c,d,e,f,g) = F(x,x1,x2,x3,x4);
			der(x1)  = b;
			der(x2)  = c;
			der(x3)  = d+a;
			der(x4)  = e*f+g;
			Y = x+x1+x2+x3+x4;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction5",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction5_F_der_AD0(jmi_real_t x_var_v, jmi_real_t x1_var_v, jmi_real_t x2_var_v, jmi_real_t x3_var_v, jmi_real_t x4_var_v, jmi_real_t x_der_v, jmi_real_t x1_der_v, jmi_real_t x2_der_v, jmi_real_t x3_der_v, jmi_real_t x4_der_v, jmi_real_t* a_var_o, jmi_real_t* b_var_o, jmi_real_t* c_var_o, jmi_real_t* d_var_o, jmi_real_t* e_var_o, jmi_real_t* f_var_o, jmi_real_t* g_var_o, jmi_real_t* a_der_o, jmi_real_t* b_der_o, jmi_real_t* c_der_o, jmi_real_t* d_der_o, jmi_real_t* e_der_o, jmi_real_t* f_der_o, jmi_real_t* g_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, a_var_v)
    JMI_DEF(REA, a_der_v)
    JMI_DEF(REA, b_var_v)
    JMI_DEF(REA, b_der_v)
    JMI_DEF(REA, c_var_v)
    JMI_DEF(REA, c_der_v)
    JMI_DEF(REA, d_var_v)
    JMI_DEF(REA, d_der_v)
    JMI_DEF(REA, e_var_v)
    JMI_DEF(REA, e_der_v)
    JMI_DEF(REA, f_var_v)
    JMI_DEF(REA, f_der_v)
    JMI_DEF(REA, g_var_v)
    JMI_DEF(REA, g_der_v)
    jmi_real_t v_0;
    jmi_real_t d_0;
    jmi_real_t v_1;
    jmi_real_t d_1;
    a_var_v = x_var_v * 2;
    a_der_v = x_der_v * 2 + x_var_v * AD_WRAP_LITERAL(0);
    b_var_v = x1_var_v * 4;
    b_der_v = x1_der_v * 4 + x1_var_v * AD_WRAP_LITERAL(0);
    c_var_v = x2_var_v * 8;
    c_der_v = x2_der_v * 8 + x2_var_v * AD_WRAP_LITERAL(0);
    d_var_v = x3_var_v * 8;
    d_der_v = x3_der_v * 8 + x3_var_v * AD_WRAP_LITERAL(0);
    e_var_v = x4_var_v * 8;
    e_der_v = x4_der_v * 8 + x4_var_v * AD_WRAP_LITERAL(0);
    v_0 = x_var_v * x1_var_v;
    d_0 = x_der_v * x1_var_v + x_var_v * x1_der_v;
    f_var_v = v_0 * x2_var_v;
    f_der_v = d_0 * x2_var_v + v_0 * x2_der_v;
    v_1 = x3_var_v * x4_var_v;
    d_1 = x3_der_v * x4_var_v + x3_var_v * x4_der_v;
    g_var_v = v_1 + x1_var_v;
    g_der_v = d_1 + x1_der_v;
    if (a_var_o != NULL) *a_var_o = a_var_v;
    if (a_der_o != NULL) *a_der_o = a_der_v;
    if (b_var_o != NULL) *b_var_o = b_var_v;
    if (b_der_o != NULL) *b_der_o = b_der_v;
    if (c_var_o != NULL) *c_var_o = c_var_v;
    if (c_der_o != NULL) *c_der_o = c_der_v;
    if (d_var_o != NULL) *d_var_o = d_var_v;
    if (d_der_o != NULL) *d_der_o = d_der_v;
    if (e_var_o != NULL) *e_var_o = e_var_v;
    if (e_der_o != NULL) *e_der_o = e_der_v;
    if (f_var_o != NULL) *f_var_o = f_var_v;
    if (f_der_o != NULL) *f_der_o = f_der_v;
    if (g_var_o != NULL) *g_var_o = g_var_v;
    if (g_der_o != NULL) *g_der_o = g_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_DEF(REA, tmp_var_0)
    JMI_DEF(REA, tmp_der_0)
    JMI_DEF(REA, tmp_var_1)
    JMI_DEF(REA, tmp_der_1)
    JMI_DEF(REA, tmp_var_2)
    JMI_DEF(REA, tmp_der_2)
    JMI_DEF(REA, tmp_var_3)
    JMI_DEF(REA, tmp_der_3)
    JMI_DEF(REA, tmp_var_4)
    JMI_DEF(REA, tmp_der_4)
    JMI_DEF(REA, tmp_var_5)
    JMI_DEF(REA, tmp_der_5)
    JMI_DEF(REA, tmp_var_6)
    JMI_DEF(REA, tmp_der_6)
    jmi_real_t v_2;
    jmi_real_t d_2;
    jmi_real_t v_3;
    jmi_real_t d_3;
    jmi_real_t v_4;
    jmi_real_t d_4;
    jmi_real_t v_5;
    jmi_real_t d_5;
    (*res)[0] = _x1_1 * _U_12 - (_der_x_14);
    (*dF)[0] = (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx] * _U_12 + _x1_1 * (*dz)[jmi_get_index_from_value_ref(10)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
    func_CADCodeGenFunctionTests_CADFunction5_F_der_AD0(_x_0, _x1_1, _x2_2, _x3_3, _x4_4, (*dz)[jmi_get_index_from_value_ref(5)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(7)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(8)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(9)-jmi->offs_real_dx], &tmp_var_0, &tmp_var_1, &tmp_var_2, &tmp_var_3, &tmp_var_4, &tmp_var_5, &tmp_var_6, &tmp_der_0, &tmp_der_1, &tmp_der_2, &tmp_der_3, &tmp_der_4, &tmp_der_5, &tmp_der_6);
    (*res)[1] = tmp_var_0 - (_a_5);
    (*dF)[1] = tmp_der_0 - ((*dz)[jmi_get_index_from_value_ref(11)-jmi->offs_real_dx]);
    (*res)[2] = tmp_var_1 - (_b_6);
    (*dF)[2] = tmp_der_1 - ((*dz)[jmi_get_index_from_value_ref(12)-jmi->offs_real_dx]);
    (*res)[3] = tmp_var_2 - (_c_7);
    (*dF)[3] = tmp_der_2 - ((*dz)[jmi_get_index_from_value_ref(13)-jmi->offs_real_dx]);
    (*res)[4] = tmp_var_3 - (_d_8);
    (*dF)[4] = tmp_der_3 - ((*dz)[jmi_get_index_from_value_ref(14)-jmi->offs_real_dx]);
    (*res)[5] = tmp_var_4 - (_e_9);
    (*dF)[5] = tmp_der_4 - ((*dz)[jmi_get_index_from_value_ref(15)-jmi->offs_real_dx]);
    (*res)[6] = tmp_var_5 - (_f_10);
    (*dF)[6] = tmp_der_5 - ((*dz)[jmi_get_index_from_value_ref(16)-jmi->offs_real_dx]);
    (*res)[7] = tmp_var_6 - (_g_11);
    (*dF)[7] = tmp_der_6 - ((*dz)[jmi_get_index_from_value_ref(17)-jmi->offs_real_dx]);
    (*res)[8] = _b_6 - (_der_x1_15);
    (*dF)[8] = (*dz)[jmi_get_index_from_value_ref(12)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx]);
    (*res)[9] = _c_7 - (_der_x2_16);
    (*dF)[9] = (*dz)[jmi_get_index_from_value_ref(13)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
    (*res)[10] = _d_8 + _a_5 - (_der_x3_17);
    (*dF)[10] = (*dz)[jmi_get_index_from_value_ref(14)-jmi->offs_real_dx] + (*dz)[jmi_get_index_from_value_ref(11)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(3)-jmi->offs_real_dx]);
    v_2 = _e_9 * _f_10;
    d_2 = (*dz)[jmi_get_index_from_value_ref(15)-jmi->offs_real_dx] * _f_10 + _e_9 * (*dz)[jmi_get_index_from_value_ref(16)-jmi->offs_real_dx];
    (*res)[11] = v_2 + _g_11 - (_der_x4_18);
    (*dF)[11] = d_2 + (*dz)[jmi_get_index_from_value_ref(17)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(4)-jmi->offs_real_dx]);
    v_5 = _x_0 + _x1_1;
    d_5 = (*dz)[jmi_get_index_from_value_ref(5)-jmi->offs_real_dx] + (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx];
    v_4 = v_5 + _x2_2;
    d_4 = d_5 + (*dz)[jmi_get_index_from_value_ref(7)-jmi->offs_real_dx];
    v_3 = v_4 + _x3_3;
    d_3 = d_4 + (*dz)[jmi_get_index_from_value_ref(8)-jmi->offs_real_dx];
    (*res)[12] = v_3 + _x4_4 - (_Y_13);
    (*dF)[12] = d_3 + (*dz)[jmi_get_index_from_value_ref(9)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(18)-jmi->offs_real_dx]);
")})));
end CADFunction5;


model CADFunction6

			function F
			input Real x;
			input Real x1;
			input Real x2;
			input Real x3;
			input Real x4;
			output Real a;
			output Real b;
			output Real c;
			output Real d;
			output Real e;
			output Real f;
			output Real g;
		algorithm
			a := x*2;
			b := x1*4;
			c := x2*8;
			d := x3*8;
			(e,f,g) := F2(x4,x3,x2);
		end F;
		
		function F2
			input Real x1;
			input Real x2;
			input Real x3;
			output Real a;
			output Real b;
			output Real c;
		algorithm
			a := x1*2;
			b := x2*4;
			c := x3*8;
		end F2;
		
		Real x(start=5);
		Real x1(start=10);
		Real x2(start=15);
		Real x3(start=20);
		Real x4(start=25);
		Real a;
		Real b;
		Real c;
		Real d;
		Real e;
		Real f;
		Real g;
		input Real U(start=10);
		output Real Y;
	equation
		der(x)   = x1*U;
		(a,b,c,d) = F(x,x1,x2,x3,x4);
		der(x1)  = b;
		der(x2)  = c;
		der(x3)  = d+a;
		der(x4)  = e*f+g+x1;
		(e,f,g) = F(x,x1,x2,x3,x4);
		Y = x+x1+x2+x3+x4;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction6",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction6_F_der_AD0(jmi_real_t x_var_v, jmi_real_t x1_var_v, jmi_real_t x2_var_v, jmi_real_t x3_var_v, jmi_real_t x4_var_v, jmi_real_t x_der_v, jmi_real_t x1_der_v, jmi_real_t x2_der_v, jmi_real_t x3_der_v, jmi_real_t x4_der_v, jmi_real_t* a_var_o, jmi_real_t* b_var_o, jmi_real_t* c_var_o, jmi_real_t* d_var_o, jmi_real_t* e_var_o, jmi_real_t* f_var_o, jmi_real_t* g_var_o, jmi_real_t* a_der_o, jmi_real_t* b_der_o, jmi_real_t* c_der_o, jmi_real_t* d_der_o, jmi_real_t* e_der_o, jmi_real_t* f_der_o, jmi_real_t* g_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, a_var_v)
    JMI_DEF(REA, a_der_v)
    JMI_DEF(REA, b_var_v)
    JMI_DEF(REA, b_der_v)
    JMI_DEF(REA, c_var_v)
    JMI_DEF(REA, c_der_v)
    JMI_DEF(REA, d_var_v)
    JMI_DEF(REA, d_der_v)
    JMI_DEF(REA, e_var_v)
    JMI_DEF(REA, e_der_v)
    JMI_DEF(REA, f_var_v)
    JMI_DEF(REA, f_der_v)
    JMI_DEF(REA, g_var_v)
    JMI_DEF(REA, g_der_v)
    a_var_v = x_var_v * 2;
    a_der_v = x_der_v * 2 + x_var_v * AD_WRAP_LITERAL(0);
    b_var_v = x1_var_v * 4;
    b_der_v = x1_der_v * 4 + x1_var_v * AD_WRAP_LITERAL(0);
    c_var_v = x2_var_v * 8;
    c_der_v = x2_der_v * 8 + x2_var_v * AD_WRAP_LITERAL(0);
    d_var_v = x3_var_v * 8;
    d_der_v = x3_der_v * 8 + x3_var_v * AD_WRAP_LITERAL(0);
    func_CADCodeGenFunctionTests_CADFunction6_F2_der_AD1(x4_var_v, x3_var_v, x2_var_v, x4_der_v, x3_der_v, x2_der_v, &e_var_v, &f_var_v, &g_var_v, &e_der_v, &f_der_v, &g_der_v);
    if (a_var_o != NULL) *a_var_o = a_var_v;
    if (a_der_o != NULL) *a_der_o = a_der_v;
    if (b_var_o != NULL) *b_var_o = b_var_v;
    if (b_der_o != NULL) *b_der_o = b_der_v;
    if (c_var_o != NULL) *c_var_o = c_var_v;
    if (c_der_o != NULL) *c_der_o = c_der_v;
    if (d_var_o != NULL) *d_var_o = d_var_v;
    if (d_der_o != NULL) *d_der_o = d_der_v;
    if (e_var_o != NULL) *e_var_o = e_var_v;
    if (e_der_o != NULL) *e_der_o = e_der_v;
    if (f_var_o != NULL) *f_var_o = f_var_v;
    if (f_der_o != NULL) *f_der_o = f_der_v;
    if (g_var_o != NULL) *g_var_o = g_var_v;
    if (g_der_o != NULL) *g_der_o = g_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction6_F2_der_AD1(jmi_real_t x1_var_v, jmi_real_t x2_var_v, jmi_real_t x3_var_v, jmi_real_t x1_der_v, jmi_real_t x2_der_v, jmi_real_t x3_der_v, jmi_real_t* a_var_o, jmi_real_t* b_var_o, jmi_real_t* c_var_o, jmi_real_t* a_der_o, jmi_real_t* b_der_o, jmi_real_t* c_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, a_var_v)
    JMI_DEF(REA, a_der_v)
    JMI_DEF(REA, b_var_v)
    JMI_DEF(REA, b_der_v)
    JMI_DEF(REA, c_var_v)
    JMI_DEF(REA, c_der_v)
    a_var_v = x1_var_v * 2;
    a_der_v = x1_der_v * 2 + x1_var_v * AD_WRAP_LITERAL(0);
    b_var_v = x2_var_v * 4;
    b_der_v = x2_der_v * 4 + x2_var_v * AD_WRAP_LITERAL(0);
    c_var_v = x3_var_v * 8;
    c_der_v = x3_der_v * 8 + x3_var_v * AD_WRAP_LITERAL(0);
    if (a_var_o != NULL) *a_var_o = a_var_v;
    if (a_der_o != NULL) *a_der_o = a_der_v;
    if (b_var_o != NULL) *b_var_o = b_var_v;
    if (b_der_o != NULL) *b_der_o = b_der_v;
    if (c_var_o != NULL) *c_var_o = c_var_v;
    if (c_der_o != NULL) *c_der_o = c_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    jmi_real_t v_0;
    jmi_real_t d_0;
    jmi_real_t v_1;
    jmi_real_t d_1;
    jmi_real_t v_2;
    jmi_real_t d_2;
    jmi_real_t v_3;
    jmi_real_t d_3;
    jmi_real_t v_4;
    jmi_real_t d_4;
    JMI_DEF(REA, tmp_var_0)
    JMI_DEF(REA, tmp_der_0)
    JMI_DEF(REA, tmp_var_1)
    JMI_DEF(REA, tmp_der_1)
    JMI_DEF(REA, tmp_var_2)
    JMI_DEF(REA, tmp_der_2)
    JMI_DEF(REA, tmp_var_3)
    JMI_DEF(REA, tmp_der_3)
    (*res)[0] = _x1_1 * _U_9 - (_der_x_11);
    (*dF)[0] = (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx] * _U_9 + _x1_1 * (*dz)[jmi_get_index_from_value_ref(10)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
    (*res)[1] = _b_6 - (_der_x1_12);
    (*dF)[1] = (*dz)[jmi_get_index_from_value_ref(12)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx]);
    (*res)[2] = _c_7 - (_der_x2_13);
    (*dF)[2] = (*dz)[jmi_get_index_from_value_ref(13)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
    (*res)[3] = _d_8 + _a_5 - (_der_x3_14);
    (*dF)[3] = (*dz)[jmi_get_index_from_value_ref(14)-jmi->offs_real_dx] + (*dz)[jmi_get_index_from_value_ref(11)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(3)-jmi->offs_real_dx]);
    v_1 = _a_5 * _der_x1_12;
    d_1 = (*dz)[jmi_get_index_from_value_ref(11)-jmi->offs_real_dx] * _der_x1_12 + _a_5 * (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
    v_0 = v_1 + _der_x2_13;
    d_0 = d_1 + (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx];
    (*res)[4] = v_0 + _x1_1 - (_der_x4_15);
    (*dF)[4] = d_0 + (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(4)-jmi->offs_real_dx]);
    v_4 = _x_0 + _x1_1;
    d_4 = (*dz)[jmi_get_index_from_value_ref(5)-jmi->offs_real_dx] + (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx];
    v_3 = v_4 + _x2_2;
    d_3 = d_4 + (*dz)[jmi_get_index_from_value_ref(7)-jmi->offs_real_dx];
    v_2 = v_3 + _x3_3;
    d_2 = d_3 + (*dz)[jmi_get_index_from_value_ref(8)-jmi->offs_real_dx];
    (*res)[5] = v_2 + _x4_4 - (_Y_10);
    (*dF)[5] = d_2 + (*dz)[jmi_get_index_from_value_ref(9)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(15)-jmi->offs_real_dx]);
    func_CADCodeGenFunctionTests_CADFunction6_F_der_AD0(_x_0, _x1_1, _x2_2, _x3_3, _x4_4, (*dz)[jmi_get_index_from_value_ref(5)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(6)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(7)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(8)-jmi->offs_real_dx], (*dz)[jmi_get_index_from_value_ref(9)-jmi->offs_real_dx], &tmp_var_0, &tmp_var_1, &tmp_var_2, &tmp_var_3, NULL, NULL, NULL, &tmp_der_0, &tmp_der_1, &tmp_der_2, &tmp_der_3, NULL, NULL, NULL);
    (*res)[6] = tmp_var_0 - (_a_5);
    (*dF)[6] = tmp_der_0 - ((*dz)[jmi_get_index_from_value_ref(11)-jmi->offs_real_dx]);
    (*res)[7] = tmp_var_1 - (_b_6);
    (*dF)[7] = tmp_der_1 - ((*dz)[jmi_get_index_from_value_ref(12)-jmi->offs_real_dx]);
    (*res)[8] = tmp_var_2 - (_c_7);
    (*dF)[8] = tmp_der_2 - ((*dz)[jmi_get_index_from_value_ref(13)-jmi->offs_real_dx]);
    (*res)[9] = tmp_var_3 - (_d_8);
    (*dF)[9] = tmp_der_3 - ((*dz)[jmi_get_index_from_value_ref(14)-jmi->offs_real_dx]);
")})));
end CADFunction6;

model CADFunction7
	function F
		input Real x;
		output Real y;
		output Real z;
	algorithm
		y := x*x;
		z := x*y;
	end F;
	Real x(start=5);
	Real y(start=7);
	Real a(start=2);
	equation
		(x,y) = F(a);
		der(a) = log(x*y);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction7",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction7_F_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* z_var_o, jmi_real_t* y_der_o, jmi_real_t* z_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    JMI_DEF(REA, z_var_v)
    JMI_DEF(REA, z_der_v)
    y_var_v = x_var_v * x_var_v;
    y_der_v = x_der_v * x_var_v + x_var_v * x_der_v;
    z_var_v = x_var_v * y_var_v;
    z_der_v = x_der_v * y_var_v + x_var_v * y_der_v;
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    if (z_var_o != NULL) *z_var_o = z_var_v;
    if (z_der_o != NULL) *z_der_o = z_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_DEF(REA, tmp_var_0)
    JMI_DEF(REA, tmp_der_0)
    JMI_DEF(REA, tmp_var_1)
    JMI_DEF(REA, tmp_der_1)
    jmi_real_t v_0;
    jmi_real_t d_0;
    func_CADCodeGenFunctionTests_CADFunction7_F_der_AD0(_a_2, (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx], &tmp_var_0, &tmp_var_1, &tmp_der_0, &tmp_der_1);
    (*res)[0] = tmp_var_0 - (_x_0);
    (*dF)[0] = tmp_der_0 - ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
    (*res)[1] = tmp_var_1 - (_y_1);
    (*dF)[1] = tmp_der_1 - ((*dz)[jmi_get_index_from_value_ref(3)-jmi->offs_real_dx]);
    v_0 = _x_0 * _y_1;
    d_0 = (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] * _y_1 + _x_0 * (*dz)[jmi_get_index_from_value_ref(3)-jmi->offs_real_dx];
    (*res)[2] = jmi_log_equation(jmi, v_0,\"log(x * y)\") - (_der_a_3);
    (*dF)[2] = d_0 / v_0 - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
")})));
  end CADFunction7;

model CADFunction8
	function f1
		input Real x[2];
		output Real y[2];
	algorithm
		y := x + {1,1};
		y := y + x;
	end f1;

	function f2
		input Real x[2];
		output Real y[2];
	algorithm
		y := f1(x) + f1(x+{1,1});
		y := y + f1(y);
	end f2;

	Real x[2] = {time, time*2};
	Real y1,y2;
equation
	{y1,y2} = f2(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction8",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction8_f2_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_array_t* y_var_a, jmi_array_t* y_der_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_var_an, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_der_an, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_2_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_2_der_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_3_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_3_der_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_4_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_4_der_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 2, 1)
    if (y_var_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, y_var_an, 2, 1, 2)
        y_var_a = y_var_an;
    }
    if (y_der_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, y_der_an, 2, 1, 2)
        y_der_a = y_der_an;
    }
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 2, 1, 2)
    func_CADCodeGenFunctionTests_CADFunction8_f1_der_AD1(x_var_a, x_der_a, temp_1_var_a, temp_1_der_a);
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_2_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_2_der_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 2, 1, 2)
    jmi_array_ref_1(tmp_var_0, 1) = jmi_array_val_1(x_var_a, 1) + AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_var_0, 2) = jmi_array_val_1(x_var_a, 2) + AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_der_0, 1) = jmi_array_val_1(x_der_a, 1) + AD_WRAP_LITERAL(0);
    jmi_array_ref_1(tmp_der_0, 2) = jmi_array_val_1(x_der_a, 2) + AD_WRAP_LITERAL(0);
    func_CADCodeGenFunctionTests_CADFunction8_f1_der_AD1(tmp_var_0, tmp_der_0, temp_2_var_a, temp_2_der_a);
    jmi_array_ref_1(y_var_a, 1) = jmi_array_val_1(temp_1_var_a, 1) + jmi_array_val_1(temp_2_var_a, 1);
    jmi_array_ref_1(y_der_a, 1) = jmi_array_val_1(temp_1_der_a, 1) + jmi_array_val_1(temp_2_der_a, 1);
    jmi_array_ref_1(y_var_a, 2) = jmi_array_val_1(temp_1_var_a, 2) + jmi_array_val_1(temp_2_var_a, 2);
    jmi_array_ref_1(y_der_a, 2) = jmi_array_val_1(temp_1_der_a, 2) + jmi_array_val_1(temp_2_der_a, 2);
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_3_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_3_der_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_4_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_4_der_a, 2, 1, 2)
    func_CADCodeGenFunctionTests_CADFunction8_f1_der_AD1(y_var_a, y_der_a, temp_4_var_a, temp_4_der_a);
    jmi_array_ref_1(temp_3_var_a, 1) = jmi_array_val_1(y_var_a, 1) + jmi_array_val_1(temp_4_var_a, 1);
    jmi_array_ref_1(temp_3_der_a, 1) = jmi_array_val_1(y_der_a, 1) + jmi_array_val_1(temp_4_der_a, 1);
    jmi_array_ref_1(temp_3_var_a, 2) = jmi_array_val_1(y_var_a, 2) + jmi_array_val_1(temp_4_var_a, 2);
    jmi_array_ref_1(temp_3_der_a, 2) = jmi_array_val_1(y_der_a, 2) + jmi_array_val_1(temp_4_der_a, 2);
    jmi_array_ref_1(y_var_a, 1) = jmi_array_val_1(temp_3_var_a, 1);
    jmi_array_ref_1(y_der_a, 1) = jmi_array_val_1(temp_3_der_a, 1);
    jmi_array_ref_1(y_var_a, 2) = jmi_array_val_1(temp_3_var_a, 2);
    jmi_array_ref_1(y_der_a, 2) = jmi_array_val_1(temp_3_der_a, 2);
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction8_f1_der_AD1(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_array_t* y_var_a, jmi_array_t* y_der_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_var_an, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_der_an, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 2, 1)
    if (y_var_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, y_var_an, 2, 1, 2)
        y_var_a = y_var_an;
    }
    if (y_der_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, y_der_an, 2, 1, 2)
        y_der_a = y_der_an;
    }
    jmi_array_ref_1(y_var_a, 1) = jmi_array_val_1(x_var_a, 1) + 1;
    jmi_array_ref_1(y_der_a, 1) = jmi_array_val_1(x_der_a, 1) + AD_WRAP_LITERAL(0);
    jmi_array_ref_1(y_var_a, 2) = jmi_array_val_1(x_var_a, 2) + 1;
    jmi_array_ref_1(y_der_a, 2) = jmi_array_val_1(x_der_a, 2) + AD_WRAP_LITERAL(0);
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_var_a, 1) = jmi_array_val_1(y_var_a, 1) + jmi_array_val_1(x_var_a, 1);
    jmi_array_ref_1(temp_1_der_a, 1) = jmi_array_val_1(y_der_a, 1) + jmi_array_val_1(x_der_a, 1);
    jmi_array_ref_1(temp_1_var_a, 2) = jmi_array_val_1(y_var_a, 2) + jmi_array_val_1(x_var_a, 2);
    jmi_array_ref_1(temp_1_der_a, 2) = jmi_array_val_1(y_der_a, 2) + jmi_array_val_1(x_der_a, 2);
    jmi_array_ref_1(y_var_a, 1) = jmi_array_val_1(temp_1_var_a, 1);
    jmi_array_ref_1(y_der_a, 1) = jmi_array_val_1(temp_1_der_a, 1);
    jmi_array_ref_1(y_var_a, 2) = jmi_array_val_1(temp_1_var_a, 2);
    jmi_array_ref_1(y_der_a, 2) = jmi_array_val_1(temp_1_der_a, 2);
    JMI_DYNAMIC_FREE()
    return;
}


    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_1, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_1, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_2, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_2, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_2, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_2, 2, 1, 2)
    jmi_array_ref_1(tmp_var_2, 1) = _x_1_0;
    jmi_array_ref_1(tmp_var_2, 2) = _x_2_1;
    jmi_array_ref_1(tmp_der_2, 1) = (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
    jmi_array_ref_1(tmp_der_2, 2) = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
    func_CADCodeGenFunctionTests_CADFunction8_f2_der_AD0(tmp_var_2, tmp_der_2, tmp_var_1, tmp_der_1);
    (*res)[0] = jmi_array_val_1(tmp_var_1, 1) - (_y1_2);
    (*res)[1] = jmi_array_val_1(tmp_var_1, 2) - (_y2_3);
    (*dF)[0] = jmi_array_val_1(tmp_der_1, 1) - ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
    (*dF)[1] = jmi_array_val_1(tmp_der_1, 2) - ((*dz)[jmi_get_index_from_value_ref(3)-jmi->offs_real_dx]);
    (*res)[2] = _time - (_x_1_0);
    (*dF)[2] = (*dz)[jmi->offs_t] - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
    (*res)[3] = 2 * _x_1_0 - (_x_2_1);
    (*dF)[3] = AD_WRAP_LITERAL(0) * _x_1_0 + 2 * (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx]);
")})));
end CADFunction8;

model CADFunction9
	function f1
		input Real x[2];
		output Real y1;
		output Real y2;
		Real[2] tmp;
	algorithm
		tmp := x + {1,1};
		tmp := tmp + x;
		y1 := tmp[1];
		y2 := tmp[1] + y1;
	end f1;

	function f2
		input Real x[2];
		output Real y1;
		output Real y2;
	algorithm
		y1 := f1(x+{1,1});
		y2 := y1 + x[2];
	end f2;

	Real x[2] = {time, time*2};
	Real y1;
equation
	y1 = f2(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction9",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
$C_DAE_equation_directional_derivative$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction9_f2_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* y1_var_o, jmi_real_t* y2_var_o, jmi_real_t* y1_der_o, jmi_real_t* y2_der_o);
void func_CADCodeGenFunctionTests_CADFunction9_f1_der_AD1(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* y1_var_o, jmi_real_t* y2_var_o, jmi_real_t* y1_der_o, jmi_real_t* y2_der_o);

void func_CADCodeGenFunctionTests_CADFunction9_f2_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* y1_var_o, jmi_real_t* y2_var_o, jmi_real_t* y1_der_o, jmi_real_t* y2_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y1_var_v)
    JMI_DEF(REA, y1_der_v)
    JMI_DEF(REA, y2_var_v)
    JMI_DEF(REA, y2_der_v)
    jmi_real_t v_0;
    jmi_real_t d_0;
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 2, 1, 2)
    jmi_array_ref_1(tmp_var_0, 1) = jmi_array_val_1(x_var_a, 1) + AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_var_0, 2) = jmi_array_val_1(x_var_a, 2) + AD_WRAP_LITERAL(1);
    jmi_array_ref_1(tmp_der_0, 1) = jmi_array_val_1(x_der_a, 1) + AD_WRAP_LITERAL(0);
    jmi_array_ref_1(tmp_der_0, 2) = jmi_array_val_1(x_der_a, 2) + AD_WRAP_LITERAL(0);
    func_CADCodeGenFunctionTests_CADFunction9_f1_der_AD1(tmp_var_0, tmp_der_0, &v_0, NULL, &d_0, NULL);
    y1_var_v = v_0;
    y1_der_v = d_0;
    y2_var_v = y1_var_v + jmi_array_val_1(x_var_a, 2);
    y2_der_v = y1_der_v + jmi_array_val_1(x_der_a, 2);
    if (y1_var_o != NULL) *y1_var_o = y1_var_v;
    if (y1_der_o != NULL) *y1_der_o = y1_der_v;
    if (y2_var_o != NULL) *y2_var_o = y2_var_v;
    if (y2_der_o != NULL) *y2_der_o = y2_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction9_f1_der_AD1(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* y1_var_o, jmi_real_t* y2_var_o, jmi_real_t* y1_der_o, jmi_real_t* y2_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y1_var_v)
    JMI_DEF(REA, y1_der_v)
    JMI_DEF(REA, y2_var_v)
    JMI_DEF(REA, y2_der_v)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_a, 2, 1, 2)
    jmi_array_ref_1(tmp_var_a, 1) = jmi_array_val_1(x_var_a, 1) + 1;
    jmi_array_ref_1(tmp_der_a, 1) = jmi_array_val_1(x_der_a, 1) + AD_WRAP_LITERAL(0);
    jmi_array_ref_1(tmp_var_a, 2) = jmi_array_val_1(x_var_a, 2) + 1;
    jmi_array_ref_1(tmp_der_a, 2) = jmi_array_val_1(x_der_a, 2) + AD_WRAP_LITERAL(0);
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 2, 1, 2)
    jmi_array_ref_1(temp_1_var_a, 1) = jmi_array_val_1(tmp_var_a, 1) + jmi_array_val_1(x_var_a, 1);
    jmi_array_ref_1(temp_1_der_a, 1) = jmi_array_val_1(tmp_der_a, 1) + jmi_array_val_1(x_der_a, 1);
    jmi_array_ref_1(temp_1_var_a, 2) = jmi_array_val_1(tmp_var_a, 2) + jmi_array_val_1(x_var_a, 2);
    jmi_array_ref_1(temp_1_der_a, 2) = jmi_array_val_1(tmp_der_a, 2) + jmi_array_val_1(x_der_a, 2);
    jmi_array_ref_1(tmp_var_a, 1) = jmi_array_val_1(temp_1_var_a, 1);
    jmi_array_ref_1(tmp_der_a, 1) = jmi_array_val_1(temp_1_der_a, 1);
    jmi_array_ref_1(tmp_var_a, 2) = jmi_array_val_1(temp_1_var_a, 2);
    jmi_array_ref_1(tmp_der_a, 2) = jmi_array_val_1(temp_1_der_a, 2);
    y1_var_v = jmi_array_val_1(tmp_var_a, 1);
    y1_der_v = jmi_array_val_1(tmp_der_a, 1);
    y2_var_v = jmi_array_val_1(tmp_var_a, 1) + y1_var_v;
    y2_der_v = jmi_array_val_1(tmp_der_a, 1) + y1_der_v;
    if (y1_var_o != NULL) *y1_var_o = y1_var_v;
    if (y1_der_o != NULL) *y1_der_o = y1_der_v;
    if (y2_var_o != NULL) *y2_var_o = y2_var_v;
    if (y2_der_o != NULL) *y2_der_o = y2_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


    jmi_real_t v_1;
    jmi_real_t d_1;
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_1, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_1, 2, 1, 2)
    jmi_array_ref_1(tmp_var_1, 1) = _x_1_0;
    jmi_array_ref_1(tmp_var_1, 2) = _x_2_1;
    jmi_array_ref_1(tmp_der_1, 1) = (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
    jmi_array_ref_1(tmp_der_1, 2) = (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
    func_CADCodeGenFunctionTests_CADFunction9_f2_der_AD0(tmp_var_1, tmp_der_1, &v_1, NULL, &d_1, NULL);
    (*res)[0] = v_1 - (_y1_2);
    (*dF)[0] = d_1 - ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
    (*res)[1] = _time - (_x_1_0);
    (*dF)[1] = (*dz)[jmi->offs_t] - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
    (*res)[2] = 2 * _x_1_0 - (_x_2_1);
    (*dF)[2] = AD_WRAP_LITERAL(0) * _x_1_0 + 2 * (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] - ((*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx]);
")})));
end CADFunction9;

model CADFunction10
    function F1
        input Real x;
        output Real y;
        Real[:] m = {1, 2, 3, 4, 5, 6, 7, 8};
    algorithm
        y := 0;
        for i in 1:size(m,1)/2 loop
            for j in 1:size(m,1)/2 loop
                if m[integer(i + j * 2)] > x then
                    break;
                end if;
                y := y + m[integer(i + j * 2)] * x;
            end for;
        end for;
    annotation(Inline=false,smoothOrder=1);
    end F1;
    
    Real x = sin(y);
    Real y = F1(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction10",
            description="Test code gen bug where ad steps were produced for array subscripts",
            generate_dae_jacobian=true,
            template="$CAD_functions$",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction10_F1_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, m_var_a, 8, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, m_der_a, 8, 1)
    jmi_real_t v_0;
    jmi_real_t i_0i;
    jmi_real_t i_0ie;
    jmi_real_t v_1;
    jmi_real_t j_1i;
    jmi_real_t j_1ie;
    jmi_real_t v_2;
    jmi_real_t d_2;
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, m_var_a, 8, 1, 8)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, m_der_a, 8, 1, 8)
    jmi_array_ref_1(m_var_a, 1) = 1;
    jmi_array_ref_1(m_der_a, 1) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 2) = 2;
    jmi_array_ref_1(m_der_a, 2) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 3) = 3;
    jmi_array_ref_1(m_der_a, 3) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 4) = 4;
    jmi_array_ref_1(m_der_a, 4) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 5) = 5;
    jmi_array_ref_1(m_der_a, 5) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 6) = 6;
    jmi_array_ref_1(m_der_a, 6) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 7) = 7;
    jmi_array_ref_1(m_der_a, 7) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(m_var_a, 8) = 8;
    jmi_array_ref_1(m_der_a, 8) = AD_WRAP_LITERAL(0);
    y_var_v = 0;
    y_der_v = AD_WRAP_LITERAL(0);
    v_0 = jmi_divide_function(\"CADCodeGenFunctionTests.CADFunction10.F1\", 8,2,\"8 / 2\");
    i_0ie = v_0 + 1 / 2.0;
    for (i_0i = 1; i_0i < i_0ie; i_0i += 1) {
        v_1 = jmi_divide_function(\"CADCodeGenFunctionTests.CADFunction10.F1\", 8,2,\"8 / 2\");
        j_1ie = v_1 + 1 / 2.0;
        for (j_1i = 1; j_1i < j_1ie; j_1i += 1) {
            if (COND_EXP_GT(jmi_array_val_1(m_var_a, floor(i_0i + j_1i * AD_WRAP_LITERAL(2))), x_var_v, JMI_TRUE, JMI_FALSE)) {
                break;
            }
            v_2 = jmi_array_val_1(m_var_a, floor(i_0i + j_1i * AD_WRAP_LITERAL(2))) * x_var_v;
            d_2 = jmi_array_val_1(m_der_a, floor(i_0i + j_1i * AD_WRAP_LITERAL(2))) * x_var_v + jmi_array_val_1(m_var_a, floor(i_0i + j_1i * AD_WRAP_LITERAL(2))) * x_der_v;
            y_var_v = y_var_v + v_2;
            y_der_v = y_der_v + d_2;
        }
    }
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADFunction10;

model CADFunction11
    function F1
        input Real[2] X;
        output Real lambda;
    algorithm
        lambda := F3(F2(X, {1.1, 1.2}));
    annotation(smoothOrder = 1, Inline=false);
    end F1;

    function F2
        input Real[:] X;
        input Real[size(X, 1)] MMX;
        output Real[size(X, 1)] moleFractions;
    algorithm
        for i in 1:size(X, 1) loop
            moleFractions[i] := X[i] * MMX[i];
        end for;
        annotation(smoothOrder = 1, Inline=false);
    end F2;

    function F3
        input Real[:] X;
        output Real y;
    algorithm
        y := 0;
        for i in 1:size(X, 1) loop
            y := y + X[i];
        end for;
    annotation(smoothOrder = 1, Inline=false);
    end F3;

    Real x;
    Real y;
equation
    x = F1({y, -y});
    y * x = 0;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction11",
            description="Test code gen bug where function call and input initialization was done in the wrong order",
            generate_dae_jacobian=true,
            template="$CAD_functions$",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction11_F1_der_AD0(jmi_array_t* X_var_a, jmi_array_t* X_der_a, jmi_real_t* lambda_var_o, jmi_real_t* lambda_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, lambda_var_v)
    JMI_DEF(REA, lambda_der_v)
    jmi_real_t v_0;
    jmi_real_t d_0;
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_1, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 2, 1, 2)
    jmi_array_ref_1(tmp_var_0, 1) = 1.1;
    jmi_array_ref_1(tmp_var_0, 2) = 1.2;
    jmi_array_ref_1(tmp_der_0, 1) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(tmp_der_0, 2) = AD_WRAP_LITERAL(0);
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_1, 2, 1, 2)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_1, 2, 1, 2)
    func_CADCodeGenFunctionTests_CADFunction11_F2_der_AD2(X_var_a, tmp_var_0, X_der_a, tmp_der_0, tmp_var_1, tmp_der_1);
    func_CADCodeGenFunctionTests_CADFunction11_F3_der_AD1(tmp_var_1, tmp_der_1, &v_0, &d_0);
    lambda_var_v = v_0;
    lambda_der_v = d_0;
    if (lambda_var_o != NULL) *lambda_var_o = lambda_var_v;
    if (lambda_der_o != NULL) *lambda_der_o = lambda_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction11_F3_der_AD1(jmi_array_t* X_var_a, jmi_array_t* X_der_a, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_1;
    jmi_real_t i_0i;
    jmi_real_t i_0ie;
    y_var_v = 0;
    y_der_v = AD_WRAP_LITERAL(0);
    v_1 = jmi_array_size(X_var_a, 0);
    i_0ie = v_1 + 1 / 2.0;
    for (i_0i = 1; i_0i < i_0ie; i_0i += 1) {
        y_var_v = y_var_v + jmi_array_val_1(X_var_a, i_0i);
        y_der_v = y_der_v + jmi_array_val_1(X_der_a, i_0i);
    }
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction11_F2_der_AD2(jmi_array_t* X_var_a, jmi_array_t* MMX_var_a, jmi_array_t* X_der_a, jmi_array_t* MMX_der_a, jmi_array_t* moleFractions_var_a, jmi_array_t* moleFractions_der_a) {
    JMI_DYNAMIC_INIT()
    jmi_real_t v_2;
    JMI_ARR(DYNA, jmi_real_t, jmi_array_t, moleFractions_var_an, -1, 1)
    JMI_ARR(DYNA, jmi_real_t, jmi_array_t, moleFractions_der_an, -1, 1)
    jmi_real_t v_3;
    jmi_real_t i_1i;
    jmi_real_t i_1ie;
    if (moleFractions_var_a == NULL) {
        v_2 = jmi_array_size(X_var_a, 0);
        JMI_ARRAY_INIT_1(DYNA, jmi_real_t, jmi_array_t, moleFractions_var_an, v_2, 1, jmi_array_size(X_var_a, 0))
        moleFractions_var_a = moleFractions_var_an;
    }
    if (moleFractions_der_a == NULL) {
        v_2 = jmi_array_size(X_var_a, 0);
        JMI_ARRAY_INIT_1(DYNA, jmi_real_t, jmi_array_t, moleFractions_der_an, v_2, 1, jmi_array_size(X_var_a, 0))
        moleFractions_der_a = moleFractions_der_an;
    }
    v_3 = jmi_array_size(X_var_a, 0);
    i_1ie = v_3 + 1 / 2.0;
    for (i_1i = 1; i_1i < i_1ie; i_1i += 1) {
        jmi_array_ref_1(moleFractions_var_a, i_1i) = jmi_array_val_1(X_var_a, i_1i) * jmi_array_val_1(MMX_var_a, i_1i);
        jmi_array_ref_1(moleFractions_der_a, i_1i) = jmi_array_val_1(X_der_a, i_1i) * jmi_array_val_1(MMX_var_a, i_1i) + jmi_array_val_1(X_var_a, i_1i) * jmi_array_val_1(MMX_der_a, i_1i);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADFunction11;

model CADFunction12
    function F1
        input Real x;
        output Real[2] y;
    algorithm
        y[1] := x;
        y[2] := -x;
    annotation(derivative=F1_der, Inline=false);
    end F1;

    function F1_der
        input Real x;
        input Real x_der;
        output Real[2] y;
    algorithm
        y[1] := x_der;
        y[2] := -x_der;
    annotation(Inline=false);
    end F1_der;


    Real x;
    Real y;
    Real z;
equation
    {x, y} = F1(z);
    y * x = z;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADFunction12",
            description="Test code gen bug including function call with derivative annoation and non-scalar output",
            generate_dae_jacobian=true,
            template="
$C_functions$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADFunction12_F1_def0(jmi_real_t x_v, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_an, 2, 1)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    jmi_array_ref_1(y_a, 1) = x_v;
    jmi_array_ref_1(y_a, 2) = - x_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADFunction12_F1_der_def1(jmi_real_t x_v, jmi_real_t x_der_v, jmi_array_t* y_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_an, 2, 1)
    if (y_a == NULL) {
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, y_an, 2, 1, 2)
        y_a = y_an;
    }
    jmi_array_ref_1(y_a, 1) = x_der_v;
    jmi_array_ref_1(y_a, 2) = - x_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


void func_CADCodeGenFunctionTests_CADFunction12_F1_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_array_t* y_var_a, jmi_array_t* y_der_a) {
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_var_an, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, y_der_an, 2, 1)
    /*Using specified derivative annotation instead of AD*/
    func_CADCodeGenFunctionTests_CADFunction12_F1_def0(x_var_v, y_var_a);
    func_CADCodeGenFunctionTests_CADFunction12_F1_der_def1(x_var_v, x_der_v, y_der_a);
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADFunction12;

model FunctionDiscreteInputTest1
	function f
		input Integer i;
		output Real y;
	algorithm
		y := 1 + i;
	end f;
	
	Real x;
equation
	x = f(42);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionDiscreteInputTest1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_FunctionDiscreteInputTest1_f_der_AD0(jmi_real_t i_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_FunctionDiscreteInputTest1_f_der_AD0(jmi_real_t i_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    /*Zero derivative function*/
    func_CADCodeGenFunctionTests_FunctionDiscreteInputTest1_f_def0(i_v, &y_var_v);
    y_der_v = 0;
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionDiscreteInputTest1;

model FunctionDiscreteOutputTest1
	function f
		input Real x;
		output Integer i;
	algorithm
		i := if x + 23 > 42 then 42 else 1;
	end f;
	Integer i;
equation
	i = f(2.0);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionDiscreteOutputTest1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* i_o);

void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, i_v)
    /*Zero derivative function*/
    func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest1_f_def0(x_var_v, &i_v);
    JMI_RET(GEN, i_o, i_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionDiscreteOutputTest1;

model FunctionDiscreteOutputTest2
	function F1
		output Integer y;
	algorithm
		y := 42;
	end F1;
	function F2
		input Real x;
		output Real y;
		Integer i;
	algorithm
		y := F1() + x;
	end F2;
	Real x = 3;
	Real y;
equation
	y = F2(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionDiscreteOutputTest2",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest2_F2_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);
void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest2_F1_der_AD1(jmi_real_t* y_o);

void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest2_F2_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    JMI_DEF(INT, i_v)
    jmi_real_t v_0;
    func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest2_F1_der_AD1(&v_0);
    y_var_v = v_0 + x_var_v;
    y_der_v = AD_WRAP_LITERAL(0) + x_der_v;
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest2_F1_der_AD1(jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, y_v)
    /*Zero derivative function*/
    func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest2_F1_def1(&y_v);
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionDiscreteOutputTest2;

model FunctionDiscreteOutputTest3
	function F
		input Real x[:];
		output Integer i;
	algorithm
		i := size(x, 1);
	end F;
	Integer x[:] = {1,2,3};
	Integer i;
equation
	i = F(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionDiscreteOutputTest3",
            description="",
            variability_propagation=false,
            inline_functions="none",
            equation_sorting=true,
            generate_dae=true,
            generate_ode=true,
            generate_ode_jacobian=true,
            template="
$CAD_ode_derivatives$
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="

/******** Declarations *******/
    jmi_real_t v_0;
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 3, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 3, 1)

jmi_real_t** dz = jmi->dz;
    /*********** ODE section ***********/
    /*********** Real outputs **********/
    /*** Integer and boolean outputs ***/
    /********* Other variables *********/
    _x_1_0 = 1;
    pre_x_1_0 = _x_1_0;
    _x_2_1 = 2;
    pre_x_2_1 = _x_2_1;
    _x_3_2 = 3;
    pre_x_3_2 = _x_3_2;
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_var_0, 3, 1, 3)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_der_0, 3, 1, 3)
    jmi_array_ref_1(tmp_var_0, 1) = _x_1_0;
    jmi_array_ref_1(tmp_var_0, 2) = _x_2_1;
    jmi_array_ref_1(tmp_var_0, 3) = _x_3_2;
    jmi_array_ref_1(tmp_der_0, 1) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(tmp_der_0, 2) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(tmp_der_0, 3) = AD_WRAP_LITERAL(0);
    func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest3_F_der_AD0(tmp_var_0, tmp_der_0, &v_0);
    _i_3 = v_0;
    pre_i_3 = _i_3;

void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest3_F_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* i_o);

void func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest3_F_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* i_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, i_v)
    /*Zero derivative function*/
    func_CADCodeGenFunctionTests_FunctionDiscreteOutputTest3_F_def0(x_var_a, &i_v);
    JMI_RET(GEN, i_o, i_v)
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionDiscreteOutputTest3;

model FunctionMixedRecordInputTest1
	record R
		Real X[2];
		Integer i;
	end R;
	function F
		input R r;
		output Real y;
	algorithm
		y := sum(r.X) + r.i;
	end F;
	R r;
	Real y;
equation
	r.X[2] = 3;
	r.i = 1;
	y = F(R({r.X[1], 1 - r.X[2]}, r.i));
	r.X[1] = y + 2;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionMixedRecordInputTest1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_FunctionMixedRecordInputTest1_F_der_AD0(R_0_r* r_var_v, R_0_r* r_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_FunctionMixedRecordInputTest1_F_der_AD0(R_0_r* r_var_v, R_0_r* r_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_0;
    jmi_real_t d_0;
    v_0 = jmi_array_val_1(r_var_v->X, 1) + jmi_array_val_1(r_var_v->X, 2);
    d_0 = jmi_array_val_1(r_der_v->X, 1) + jmi_array_val_1(r_der_v->X, 2);
    y_var_v = v_0 + r_var_v->i;
    y_der_v = d_0 + AD_WRAP_LITERAL(0);
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionMixedRecordInputTest1;

model FunctionUnknownArraySizeTest1
	function F
		input Real x[:];
		output Real y;
		Real t[size(x, 1)];
	algorithm
		t := x .* 23;
		y := sum(t);
	end F;
	Real x[4] = {1,2,3,4};
	Real y;
equation
	y = F(x);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionUnknownArraySizeTest1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_FunctionUnknownArraySizeTest1_F_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_FunctionUnknownArraySizeTest1_F_der_AD0(jmi_array_t* x_var_a, jmi_array_t* x_der_a, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_0;
    JMI_ARR(DYNA, jmi_real_t, jmi_array_t, t_var_a, -1, 1)
    JMI_ARR(DYNA, jmi_real_t, jmi_array_t, t_der_a, -1, 1)
    JMI_DEF(REA, temp_1_var_v)
    JMI_DEF(REA, temp_1_der_v)
    jmi_real_t v_1;
    jmi_real_t i1_0i;
    jmi_real_t i1_0ie;
    jmi_real_t v_2;
    jmi_real_t i1_1i;
    jmi_real_t i1_1ie;
    v_0 = jmi_array_size(x_var_a, 0);
    JMI_ARRAY_INIT_1(DYNA, jmi_real_t, jmi_array_t, t_var_a, v_0, 1, jmi_array_size(x_var_a, 0))
    v_0 = jmi_array_size(x_var_a, 0);
    JMI_ARRAY_INIT_1(DYNA, jmi_real_t, jmi_array_t, t_der_a, v_0, 1, jmi_array_size(x_var_a, 0))
    v_1 = jmi_array_size(x_var_a, 0);
    i1_0ie = v_1 + 1 / 2.0;
    for (i1_0i = 1; i1_0i < i1_0ie; i1_0i += 1) {
        jmi_array_ref_1(t_var_a, i1_0i) = jmi_array_val_1(x_var_a, i1_0i) * 23;
        jmi_array_ref_1(t_der_a, i1_0i) = jmi_array_val_1(x_der_a, i1_0i) * 23 + jmi_array_val_1(x_var_a, i1_0i) * AD_WRAP_LITERAL(0);
    }
    temp_1_var_v = 0.0;
    temp_1_der_v = AD_WRAP_LITERAL(0);
    v_2 = jmi_array_size(x_var_a, 0);
    i1_1ie = v_2 + 1 / 2.0;
    for (i1_1i = 1; i1_1i < i1_1ie; i1_1i += 1) {
        temp_1_var_v = temp_1_var_v + jmi_array_val_1(t_var_a, i1_1i);
        temp_1_der_v = temp_1_der_v + jmi_array_val_1(t_der_a, i1_1i);
    }
    y_var_v = temp_1_var_v;
    y_der_v = temp_1_der_v;
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionUnknownArraySizeTest1;

model FunctionUnknownArraySizeTest2
    function F1
        input Real x[2];
        input Integer num;
        output Real y[2 + num * num];
    algorithm
        for i in 1:size(y,1) loop
            y[i] := x[1] + x[2];
        end for;
    end F1;
    
    Real z[2]={time,1};
    constant Integer num = 2;
    Real w[2 + num * num] = F1(z, num);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="FunctionUnknownArraySizeTest2",
            description="",
            generate_ode_jacobian=true,
            inline_functions="none",
            template="$CAD_functions$",
            generatedCode="
void func_CADCodeGenFunctionTests_FunctionUnknownArraySizeTest2_F1_der_AD0(jmi_array_t* x_var_a, jmi_real_t num_v, jmi_array_t* x_der_a, jmi_array_t* y_var_a, jmi_array_t* y_der_a) {
    JMI_DYNAMIC_INIT()
    jmi_real_t v_0;
    jmi_real_t v_1;
    JMI_ARR(DYNA, jmi_real_t, jmi_array_t, y_var_an, -1, 1)
    JMI_ARR(DYNA, jmi_real_t, jmi_array_t, y_der_an, -1, 1)
    jmi_real_t v_2;
    jmi_real_t i_0i;
    jmi_real_t i_0ie;
    if (y_var_a == NULL) {
        v_1 = num_v * num_v;
        v_0 = 2 + v_1;
        JMI_ARRAY_INIT_1(DYNA, jmi_real_t, jmi_array_t, y_var_an, (v_0), 1, 2 + v_1)
        y_var_a = y_var_an;
    }
    if (y_der_a == NULL) {
        v_1 = num_v * num_v;
        v_0 = 2 + v_1;
        JMI_ARRAY_INIT_1(DYNA, jmi_real_t, jmi_array_t, y_der_an, (v_0), 1, 2 + v_1)
        y_der_a = y_der_an;
    }
    v_2 = jmi_array_size(y_var_a, 0);
    i_0ie = v_2 + 1 / 2.0;
    for (i_0i = 1; i_0i < i_0ie; i_0i += 1) {
        jmi_array_ref_1(y_var_a, i_0i) = jmi_array_val_1(x_var_a, 1) + jmi_array_val_1(x_var_a, 2);
        jmi_array_ref_1(y_der_a, i_0i) = jmi_array_val_1(x_der_a, 1) + jmi_array_val_1(x_der_a, 2);
    }
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end FunctionUnknownArraySizeTest2;

model CADDerAnno1
		function f
			input Real x;
			output Real y;
		algorithm
			y := x^2;
			annotation(derivative=f_der);
		end f;
		
		function f_der
			input Real x;
			input Real der_x;
			output Real der_y;
		algorithm
			der_y := 2*x*der_x;
		end f_der;

		Real x1,x2;
	equation
		der(x1) + der(x2) = 1;
		x1 + f(x2) = 0;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADDerAnno1",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADDerAnno1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);
void func_CADCodeGenFunctionTests_CADDerAnno1_f_der_der_AD1(jmi_real_t x_var_v, jmi_real_t der_x_var_v, jmi_real_t x_der_v, jmi_real_t der_x_der_v, jmi_real_t* der_y_var_o, jmi_real_t* der_y_der_o);

void func_CADCodeGenFunctionTests_CADDerAnno1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    /*Using specified derivative annotation instead of AD*/
    func_CADCodeGenFunctionTests_CADDerAnno1_f_def0(x_var_v, &y_var_v);
    func_CADCodeGenFunctionTests_CADDerAnno1_f_der_def1(x_var_v, x_der_v, &y_der_v);
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

void func_CADCodeGenFunctionTests_CADDerAnno1_f_der_der_AD1(jmi_real_t x_var_v, jmi_real_t der_x_var_v, jmi_real_t x_der_v, jmi_real_t der_x_der_v, jmi_real_t* der_y_var_o, jmi_real_t* der_y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, der_y_var_v)
    JMI_DEF(REA, der_y_der_v)
    jmi_real_t v_0;
    jmi_real_t d_0;
    v_0 = 2 * x_var_v;
    d_0 = AD_WRAP_LITERAL(0) * x_var_v + 2 * x_der_v;
    der_y_var_v = v_0 * der_x_var_v;
    der_y_der_v = d_0 * der_x_var_v + v_0 * der_x_der_v;
    if (der_y_var_o != NULL) *der_y_var_o = der_y_var_v;
    if (der_y_der_o != NULL) *der_y_der_o = der_y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADDerAnno1;


model CADDerAnno2
		function f2
			input Real x1;
			input Integer i = 1;
			input Boolean b = true;
			output Integer i1;
			output Boolean b1;
			output Real y;
		algorithm
			i1 := 1;
			b1 := true;
			y  := if(b) then x1^2 else x1^3;
			annotation(derivative = f_der);
		end f2;
		
		function f_der
			input Real x1;
			input Integer i1;
			input Boolean b1;
			input Real der_x1;
			output Real der_y1;
		algorithm
			der_y1 := if(b1) then 2*x1*der_x1 else 3*x1^2*der_x1;
		end f_der;
		
		Real x1(start=2);
		Real y(start=2);
		Integer i (start = 1);
		Boolean b (start = true);
		output Real a1(start=4);
	equation
		y = f2(x1,i,b);
		i = if b then 1 else 2;
		b = x1 > 0;
		der(a1) = if i == 1 then x1 else -x1;
		der(x1) = a1;

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADDerAnno2",
            description="",
            variability_propagation=false,
            inline_functions="none",
            generate_ode_jacobian=true,
            generate_block_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
$C_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADDerAnno2_f2_der_AD0(jmi_real_t x1_var_v, jmi_real_t i_v, jmi_real_t b_v, jmi_real_t x1_der_v, jmi_real_t* i1_o, jmi_real_t* b1_o, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_CADDerAnno2_f2_der_AD0(jmi_real_t x1_var_v, jmi_real_t i_v, jmi_real_t b_v, jmi_real_t x1_der_v, jmi_real_t* i1_o, jmi_real_t* b1_o, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, i1_v)
    JMI_DEF(BOO, b1_v)
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    /*Using specified derivative annotation instead of AD*/
    func_CADCodeGenFunctionTests_CADDerAnno2_f2_def0(x1_var_v, i_v, b_v, &i1_v, &b1_v, &y_var_v);
    func_CADCodeGenFunctionTests_CADDerAnno2_f_der_def1(x1_var_v, i_v, b_v, x1_der_v, &y_der_v);
    JMI_RET(GEN, i1_o, i1_v)
    JMI_RET(GEN, b1_o, b1_v)
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}


void func_CADCodeGenFunctionTests_CADDerAnno2_f2_def0(jmi_real_t x1_v, jmi_real_t i_v, jmi_real_t b_v, jmi_real_t* i1_o, jmi_real_t* b1_o, jmi_real_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(INT, i1_v)
    JMI_DEF(BOO, b1_v)
    JMI_DEF(REA, y_v)
    i1_v = 1;
    b1_v = JMI_TRUE;
    y_v = COND_EXP_EQ(b_v, JMI_TRUE, (1.0 * (x1_v) * (x1_v)), (1.0 * (x1_v) * (x1_v) * (x1_v)));
    JMI_RET(GEN, i1_o, i1_v)
    JMI_RET(GEN, b1_o, b1_v)
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CADCodeGenFunctionTests_CADDerAnno2_f2_exp0(jmi_real_t x1_v, jmi_real_t i_v, jmi_real_t b_v) {
    JMI_DEF(INT, i1_v)
    func_CADCodeGenFunctionTests_CADDerAnno2_f2_def0(x1_v, i_v, b_v, &i1_v, NULL, NULL);
    return i1_v;
}

void func_CADCodeGenFunctionTests_CADDerAnno2_f_der_def1(jmi_real_t x1_v, jmi_real_t i1_v, jmi_real_t b1_v, jmi_real_t der_x1_v, jmi_real_t* der_y1_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, der_y1_v)
    der_y1_v = COND_EXP_EQ(b1_v, JMI_TRUE, AD_WRAP_LITERAL(2) * x1_v * der_x1_v, AD_WRAP_LITERAL(3) * (1.0 * (x1_v) * (x1_v)) * der_x1_v);
    JMI_RET(GEN, der_y1_o, der_y1_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_real_t func_CADCodeGenFunctionTests_CADDerAnno2_f_der_exp1(jmi_real_t x1_v, jmi_real_t i1_v, jmi_real_t b1_v, jmi_real_t der_x1_v) {
    JMI_DEF(REA, der_y1_v)
    func_CADCodeGenFunctionTests_CADDerAnno2_f_der_def1(x1_v, i1_v, b1_v, der_x1_v, &der_y1_v);
    return der_y1_v;
}

")})));
end CADDerAnno2;


model CADIfStmtTest1
	function f
		input Real x;
		input Boolean b;
		output Real y;
	algorithm
		if x > 5 or false then
			y := x^2;
		else
			y := 2;
		end if;
	end f;

	Real x;
equation
	der(x) = f(x, x > 4);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADIfStmtTest1",
            description="",
            variability_propagation=false,
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADIfStmtTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t b_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_CADIfStmtTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t b_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_0;
    jmi_real_t v_1;
    v_0 = COND_EXP_GT(x_var_v, 5, JMI_TRUE, JMI_FALSE);
    if (LOG_EXP_OR(v_0, JMI_FALSE)) {
        v_1 = (1.0 * (x_var_v) * (x_var_v));
        y_var_v = v_1;
        y_der_v = x_var_v == 0 ? 0 : (v_1 * (AD_WRAP_LITERAL(0) * log(jmi_abs(x_var_v)) + 2 * x_der_v / x_var_v));
    } else {
        y_var_v = 2;
        y_der_v = AD_WRAP_LITERAL(0);
    }
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADIfStmtTest1;

model CADForStmtTest1
	function f
		input Real x;
		input Integer n;
		output Real y;
	algorithm
		for i in {1, 2 + x, 4}, j in 1:(x + 1) loop
			y := x + y + i * j;
		end for;
	end f;

	Real x;
equation
	der(x) = f(x, 4);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADForStmtTest1",
            description="CAD for function with for loop",
            variability_propagation=false,
            generate_ode_jacobian=true,
            template="
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="
void func_CADCodeGenFunctionTests_CADForStmtTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t n_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_CADForStmtTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t n_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 3, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 3, 1)
    jmi_real_t i_0i;
    int i_0ii;
    jmi_real_t v_0;
    jmi_real_t d_0;
    jmi_real_t j_1i;
    jmi_real_t j_1ie;
    jmi_real_t v_1;
    jmi_real_t d_1;
    jmi_real_t v_2;
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_var_a, 3, 1, 3)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, temp_1_der_a, 3, 1, 3)
    jmi_array_ref_1(temp_1_var_a, 1) = 1;
    jmi_array_ref_1(temp_1_der_a, 1) = AD_WRAP_LITERAL(0);
    jmi_array_ref_1(temp_1_var_a, 2) = 2 + x_var_v;
    jmi_array_ref_1(temp_1_der_a, 2) = AD_WRAP_LITERAL(0) + x_der_v;
    jmi_array_ref_1(temp_1_var_a, 3) = 4;
    jmi_array_ref_1(temp_1_der_a, 3) = AD_WRAP_LITERAL(0);
    for (i_0ii = 0; i_0ii < jmi_array_size(temp_1_a, 0); i_0ii++) {
        i_0i = jmi_array_val_1(temp_1_a, i_0ii);
        v_0 = x_var_v + 1;
        d_0 = x_der_v + AD_WRAP_LITERAL(0);
        j_1ie = v_0 + 1 / 2.0;
        for (j_1i = 1; j_1i < j_1ie; j_1i += 1) {
            v_1 = x_var_v + y_var_v;
            d_1 = x_der_v + y_der_v;
            v_2 = i_0i * j_1i;
            y_var_v = v_1 + v_2;
            y_der_v = d_1 + AD_WRAP_LITERAL(0);
        }
    }
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADForStmtTest1;

model CADWhileStmtTest1
	function f
		input Real x;
		input Integer n;
		output Real y;
	algorithm
		while y < x - 2 or n < y loop
			y := y + 1;
		end while;
	end f;

	Real x;
equation
	der(x) = f(x, 4);

    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADWhileStmtTest1",
            description="",
            variability_propagation=false,
            generate_ode_jacobian=true,
            equation_sorting=false,
            template="
$CAD_ode_derivatives$
$CAD_function_headers$
$CAD_functions$
",
            generatedCode="

/******** Declarations *******/

jmi_real_t** dz = jmi->dz;
    /*********** ODE section ***********/
    /*********** Real outputs **********/
    /*** Integer and boolean outputs ***/
    /********* Other variables *********/

void func_CADCodeGenFunctionTests_CADWhileStmtTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t n_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o);

void func_CADCodeGenFunctionTests_CADWhileStmtTest1_f_der_AD0(jmi_real_t x_var_v, jmi_real_t n_v, jmi_real_t x_der_v, jmi_real_t* y_var_o, jmi_real_t* y_der_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_var_v)
    JMI_DEF(REA, y_der_v)
    jmi_real_t v_0;
    jmi_real_t v_1;
    jmi_real_t d_1;
    jmi_real_t v_2;
    v_1 = x_var_v - 2;
    d_1 = x_der_v - AD_WRAP_LITERAL(0);
    v_0 = COND_EXP_LT(y_var_v, v_1, JMI_TRUE, JMI_FALSE);
    v_2 = COND_EXP_LT(n_v, y_var_v, JMI_TRUE, JMI_FALSE);
    while (LOG_EXP_OR(v_0, v_2)) {
        y_var_v = y_var_v + 1;
        y_der_v = y_der_v + AD_WRAP_LITERAL(0);
        v_1 = x_var_v - 2;
        d_1 = x_der_v - AD_WRAP_LITERAL(0);
        v_0 = COND_EXP_LT(y_var_v, v_1, JMI_TRUE, JMI_FALSE);
        v_2 = COND_EXP_LT(n_v, y_var_v, JMI_TRUE, JMI_FALSE);
    }
    if (y_var_o != NULL) *y_var_o = y_var_v;
    if (y_der_o != NULL) *y_der_o = y_der_v;
    JMI_DYNAMIC_FREE()
    return;
}

")})));
end CADWhileStmtTest1;

end CADCodeGenFunctionTests;