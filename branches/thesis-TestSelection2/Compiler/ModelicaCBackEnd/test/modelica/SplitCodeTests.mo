/*
    Copyright (C) 2016 Modelon AB

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


package SplitCodeTests

model SplitCodeTest1
  parameter Real[:] p = {1,2};
  Real[:] x = p .+ time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTest1",
            description="Test negative split options",
            cc_split_element_limit=0,
            template="
$C_set_start_values$
$C_DAE_initial_dependent_parameter_assignments$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
int jmi_set_start_values_0_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p_1_0 = (1);
    _p_2_1 = (2);
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_1_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = (0.0);
    _x_2_3 = (0.0);
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


int model_init_eval_parameters_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest1;

model SplitCodeTest2
  parameter Real[:] p = {1,2};
  Real[:] x = p .+ time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTest2",
            description="Test negative split options",
            cc_split_element_limit=1,
            cc_split_function_limit=-1,
            template="
$C_set_start_values$
$C_DAE_initial_dependent_parameter_assignments$
$C_ode_derivatives$
$C_ode_initialization$
",
            generatedCode="
int jmi_set_start_values_0_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p_1_0 = (1);
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_0_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _p_2_1 = (2);
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_1_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = (0.0);
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_1_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_2_3 = (0.0);
    JMI_DYNAMIC_FREE()
    return ef;
}

int jmi_set_start_values_0_0(jmi_t* jmi);
int jmi_set_start_values_0_1(jmi_t* jmi);

int jmi_set_start_values_1_0(jmi_t* jmi);
int jmi_set_start_values_1_1(jmi_t* jmi);

int jmi_set_start_values_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= jmi_set_start_values_0_0(jmi);
    ef |= jmi_set_start_values_0_1(jmi);
    model_init_eval_parameters(jmi);
    ef |= jmi_set_start_values_1_0(jmi);
    ef |= jmi_set_start_values_1_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}


int model_init_eval_parameters_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_2 = _p_1_0 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_2_3 = _p_2_1 + _time;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_initialize_0(jmi_t* jmi);
int model_ode_initialize_1(jmi_t* jmi);

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_initialize_0(jmi);
    ef |= model_ode_initialize_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest2;

model SplitCodeTest3
  Real[:] x = (1:11) .+ time;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTest3",
            description="Test split options",
            cc_split_element_limit=2,
            cc_split_function_limit=2,
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_1_0 = 1 + _time;
    _x_2_1 = _x_1_0 + 1;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_3_2 = _x_2_1 + 1;
    _x_4_3 = _x_2_1 + 2;
    JMI_DYNAMIC_FREE()
    return ef;
}

/*** SPLIT FILE ***/

int model_ode_derivatives_2(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_5_4 = _x_2_1 + 3;
    _x_6_5 = _x_2_1 + 4;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_3(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_7_6 = _x_2_1 + 5;
    _x_8_7 = _x_2_1 + 6;
    JMI_DYNAMIC_FREE()
    return ef;
}

/*** SPLIT FILE ***/

int model_ode_derivatives_4(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_9_8 = _x_2_1 + 7;
    _x_10_9 = _x_2_1 + 8;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_5(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _x_11_10 = _x_2_1 + 9;
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);
int model_ode_derivatives_2(jmi_t* jmi);
int model_ode_derivatives_3(jmi_t* jmi);
int model_ode_derivatives_4(jmi_t* jmi);
int model_ode_derivatives_5(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    ef |= model_ode_derivatives_2(jmi);
    ef |= model_ode_derivatives_3(jmi);
    ef |= model_ode_derivatives_4(jmi);
    ef |= model_ode_derivatives_5(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest3;

model SplitCodeTest4
    function f
        input Real[:] x;
        output Real y = sum(x);
    algorithm
        annotation(Inline=false);
    end f;
    
    Real y1 = f({time,time});
    Real y2 = f({time,time});

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="SplitCodeTest4",
            description="Split with temporaries",
            cc_split_element_limit=4,
            common_subexp_elim=false,
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_0(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
    jmi_array_ref_1(tmp_1, 1) = _time;
    jmi_array_ref_1(tmp_1, 2) = _time;
    _y1_0 = func_SplitCodeTests_SplitCodeTest4_f_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_1(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_2, 2, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_2, 2, 1, 2)
    jmi_array_ref_1(tmp_2, 1) = _time;
    jmi_array_ref_1(tmp_2, 2) = _time;
    _y2_1 = func_SplitCodeTests_SplitCodeTest4_f_exp0(tmp_2);
    JMI_DYNAMIC_FREE()
    return ef;
}

int model_ode_derivatives_0(jmi_t* jmi);
int model_ode_derivatives_1(jmi_t* jmi);

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    ef |= model_ode_derivatives_0(jmi);
    ef |= model_ode_derivatives_1(jmi);
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end SplitCodeTest4;

end SplitCodeTests;
