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


package CCodeGenArrayTests

model UnknownSizeInEquation1
    function mysum
        input Real[:] x;
        output Real y;
        external;
    end mysum;
    
    function f
        input Real x;
        output Real[integer(x)] y;
        external;
    end f;
    
    Real y = mysum(f(time));
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="UnknownSizeInEquation1",
            description="",
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, floor(_time), 1, floor(_time))
    func_CCodeGenArrayTests_UnknownSizeInEquation1_f_def1(_time, tmp_1);
    _y_0 = func_CCodeGenArrayTests_UnknownSizeInEquation1_mysum_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end UnknownSizeInEquation1;

model UnknownSizeInEquation2
    function mysum
        input Real[:] x;
        output Real y;
        external;
    end mysum;
    
    function f
        input Real x;
        output Real[integer(x)] y;
        external;
    end f;
    
    Real y = mysum(if time > 2 then f(time) else f(time+1));
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="UnknownSizeInEquation2",
            description="",
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_2, -1, 1)
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (AD_WRAP_LITERAL(2)), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    if (_sw(0)) {
        JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, floor(_time), 1, floor(_time))
        func_CCodeGenArrayTests_UnknownSizeInEquation2_f_def1(_time, tmp_1);
    } else {
        JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_2, floor(_time + AD_WRAP_LITERAL(1)), 1, floor(_time + AD_WRAP_LITERAL(1)))
        func_CCodeGenArrayTests_UnknownSizeInEquation2_f_def1(_time + AD_WRAP_LITERAL(1), tmp_2);
    }
    _y_0 = func_CCodeGenArrayTests_UnknownSizeInEquation2_mysum_exp0(COND_EXP_EQ(_sw(0), JMI_TRUE, tmp_1, tmp_2));
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end UnknownSizeInEquation2;

model UnknownSizeInEquation3
    model M
        function mysum
            input Real[:] x;
            output Real y;
            external;
        end mysum;
        
        function f
            input Real x;
            output Real[integer(x)] y;
            external;
        end f;
        
        Real t = time;
        Real y = mysum(f(t));
    end M;
    
    M m;
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="UnknownSizeInEquation3",
            description="Flattening and scalarization of function call sizes",
            inline_functions="none",
            template="$C_ode_derivatives$",
            generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 1)
    _m_t_0 = _time;
    JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, floor(_m_t_0), 1, floor(_m_t_0))
    func_CCodeGenArrayTests_UnknownSizeInEquation3_m_f_def1(_m_t_0, tmp_1);
    _m_y_1 = func_CCodeGenArrayTests_UnknownSizeInEquation3_m_mysum_exp0(tmp_1);
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end UnknownSizeInEquation3;

model UnknownSizeInEquation4
    function mysum
        input Real[:] x;
        output Real y;
        external;
    end mysum;
    
    function f
        input Real x;
        output Real[integer(x)] y;
        external;
    end f;
    
    parameter Real p = 1;
    Real y = mysum(f(p));
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="UnknownSizeInEquation4",
            description="",
            inline_functions="none",
            template="$C_DAE_initial_dependent_parameter_assignments$",
            generatedCode="
int model_init_eval_parameters_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, -1, 1)
    JMI_ARRAY_INIT_1(DYNA, jmi_ad_var_t, jmi_array_t, tmp_1, floor(_p_0), 1, floor(_p_0))
    func_CCodeGenArrayTests_UnknownSizeInEquation4_f_def1(_p_0, tmp_1);
    _y_1 = (func_CCodeGenArrayTests_UnknownSizeInEquation4_mysum_exp0(tmp_1));
    JMI_DYNAMIC_FREE()
    return ef;
}

")})));
end UnknownSizeInEquation4;

model PrimitiveInRecord1
    record R
        parameter Integer n = 3;
        Real[n] x = 1:3;
    end R;
    
    function f
        input Real x;
        output Real y = x;
    protected
        R r;
    algorithm
        annotation(Inline=false);
    end f;
    
    Real y = f(time);
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="PrimitiveInRecord1",
            description="",
            inline_functions="none",
            template="$C_functions$",
            generatedCode="
void func_CCodeGenArrayTests_PrimitiveInRecord1_f_def0(jmi_ad_var_t x_v, jmi_ad_var_t* y_o) {
    JMI_DYNAMIC_INIT()
    JMI_DEF(REA, y_v)
    JMI_RECORD_STATIC(R_0_r, r_v)
    JMI_ARR(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_ad_var_t, jmi_array_t, tmp_1, 3, 1, 3)
    r_v->x = tmp_1;
    y_v = x_v;
    r_v->n = 3;
    jmi_array_ref_1(r_v->x, 1) = 1;
    jmi_array_ref_1(r_v->x, 2) = 2;
    jmi_array_ref_1(r_v->x, 3) = 3;
    JMI_RET(GEN, y_o, y_v)
    JMI_DYNAMIC_FREE()
    return;
}

jmi_ad_var_t func_CCodeGenArrayTests_PrimitiveInRecord1_f_exp0(jmi_ad_var_t x_v) {
    JMI_DEF(REA, y_v)
    func_CCodeGenArrayTests_PrimitiveInRecord1_f_def0(x_v, &y_v);
    return y_v;
}

")})));
end PrimitiveInRecord1;

end CCodeGenArrayTests;
