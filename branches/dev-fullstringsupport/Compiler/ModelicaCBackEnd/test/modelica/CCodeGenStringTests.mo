/*
    Copyright (C) 2017 Modelon AB

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


package CCodeGenStringTests

model CCodeGenString1
    parameter String s0 = "";
    parameter Real t(fixed=false);
    parameter String s1 = String(t);
    parameter String s2 = s1;
initial equation
    t = time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenString1",
            description="Code generated for strings",
            eliminate_alias_variables=false,
            template="
$C_variable_aliases$
$C_z_offsets_strings$
$C_set_start_values$

$C_dae_init_blocks_residual_functions$
$C_ode_initialization$

$C_dae_blocks_residual_functions$
$C_ode_derivatives$

",
            generatedCode="
#define _t_1 ((*(jmi->z))[0])
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_pi_s0_0 (jmi->z_t.strings.values[0])
#define _s_pd_s1_2 (jmi->z_t.strings.values[1])
#define _s_pd_s2_3 (jmi->z_t.strings.values[2])

o->o_ci = 0;
o->n_ci = 0;
o->o_cd = 0;
o->n_cd = 0;
o->o_pi = 0;
o->n_pi = 1;
o->o_ps = 1;
o->n_ps = 0;
o->o_pf = 1;
o->n_pf = 0;
o->o_pe = 1;
o->n_pe = 0;
o->o_pd = 1;
o->n_pd = 2;
o->o_w = 3;
o->n_w = 0;
o->o_wp = 3;
o->n_wp = 0;
o->n = 3;

int jmi_set_start_values_0_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_pi_s0_0, (\"\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_1_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _t_1 = (0.0);
    JMI_ASG(STR_Z, _s_pd_s1_2, (\"\"));
    JMI_ASG(STR_Z, _s_pd_s2_3, (\"\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_0_0(jmi_t* jmi);

int jmi_set_start_values_1_0(jmi_t* jmi);

int jmi_set_start_values_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_set_start_values_0_0(jmi);
    model_init_eval_parameters(jmi);
    ef |= jmi_set_start_values_1_0(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    _t_1 = _time;
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _t_1);
    JMI_ASG(STR_Z, _s_pd_s1_2, tmp_1)
    JMI_ASG(STR_Z, _s_pd_s2_3, _s_pd_s1_2)
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString1;

model CCodeGenString2
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    s2 = s1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenString2",
            description="Code generated for strings",
            eliminate_alias_variables=false,
            template="
$C_variable_aliases$
$C_z_offsets_strings$
$C_set_start_values$

$C_dae_init_blocks_residual_functions$
$C_ode_initialization$

$C_dae_blocks_residual_functions$
$C_ode_derivatives$
",
            generatedCode="
#define _time ((*(jmi->z))[jmi->offs_t])
#define __homotopy_lambda ((*(jmi->z))[jmi->offs_homotopy_lambda])
#define _s_pi_s0_0 (jmi->z_t.strings.values[0])
#define _s_w_s1_1 (jmi->z_t.strings.values[1])
#define _s_w_s2_2 (jmi->z_t.strings.values[2])
#define pre_s1_1 (jmi->z_t.strings.values[jmi->z_t.strings.offsets.o_wp+0])
#define pre_s2_2 (jmi->z_t.strings.values[jmi->z_t.strings.offsets.o_wp+1])

o->o_ci = 0;
o->n_ci = 0;
o->o_cd = 0;
o->n_cd = 0;
o->o_pi = 0;
o->n_pi = 1;
o->o_ps = 1;
o->n_ps = 0;
o->o_pf = 1;
o->n_pf = 0;
o->o_pe = 1;
o->n_pe = 0;
o->o_pd = 1;
o->n_pd = 0;
o->o_w  = 1;
o->n_w  = 2;
o->o_wp = 3;
o->n_wp = 2;
o->n = 5;

int jmi_set_start_values_0_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_pi_s0_0, (\"\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_1_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ASG(STR_Z, _s_w_s1_1, (\"\"));
    JMI_ASG(STR_Z, _s_w_s2_2, (\"\"));
    JMI_ASG(STR_Z, pre_s1_1, (\"\"));
    JMI_ASG(STR_Z, pre_s2_2, (\"\"));
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_0_0(jmi_t* jmi);

int jmi_set_start_values_1_0(jmi_t* jmi);

int jmi_set_start_values_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_set_start_values_0_0(jmi);
    model_init_eval_parameters(jmi);
    ef |= jmi_set_start_values_1_0(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, _s_w_s2_2, _s_w_s1_1)
    JMI_ASG(STR_Z, pre_s1_1, \"\")
    JMI_ASG(STR_Z, pre_s2_2, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, pre_s1_1, _s_w_s1_1)
    JMI_ASG(STR_Z, _s_w_s2_2, _s_w_s1_1)
    JMI_ASG(STR_Z, pre_s2_2, _s_w_s2_2)
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString2;

model CCodeGenString3
    parameter String s0 = "";
    String s1;
    String s2;
equation
    s1 = String(time);
    s2 = s1 + s1;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CCodeGenString3",
            description="Code generated for strings. Add in solved equation.",
            template="
$C_ode_initialization$
$C_ode_derivatives$
",
            generatedCode="
int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_1) + JMI_LEN(_s_w_s1_1))
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    JMI_ASG(STR_Z, _s_w_s2_2, tmp_2)
    JMI_ASG(STR_Z, pre_s1_1, \"\")
    JMI_ASG(STR_Z, pre_s2_2, \"\")
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DEF_STR_STAT(tmp_1, 13)
    JMI_DEF_STR_DYNA(tmp_2)
    JMI_INI_STR_STAT(tmp_1)
    snprintf(JMI_STR_END(tmp_1), JMI_STR_LEFT(tmp_1), \"%-.*g\", (int) 6, _time);
    JMI_ASG(STR_Z, _s_w_s1_1, tmp_1)
    JMI_ASG(STR_Z, pre_s1_1, _s_w_s1_1)
    JMI_INI_STR_DYNA(tmp_2, JMI_LEN(_s_w_s1_1) + JMI_LEN(_s_w_s1_1))
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    snprintf(JMI_STR_END(tmp_2), JMI_STR_LEFT(tmp_2), \"%s\", _s_w_s1_1);
    JMI_ASG(STR_Z, _s_w_s2_2, tmp_2)
    JMI_ASG(STR_Z, pre_s2_2, _s_w_s2_2)
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CCodeGenString3;

end CCodeGenStringTests;
