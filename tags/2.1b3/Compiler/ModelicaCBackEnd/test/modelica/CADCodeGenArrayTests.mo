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


package CADCodeGenArrayTests

model CADRecordArray2
    record R
        Real[:] x;
    end R;
    
    function f
        input R[:] r;
        output Real y;
    algorithm
        for i in 1:size(r,1) loop
            y := y + sum(r[i].x);
        end for;
    end f;
    
    Real y = f({R({1,y}),R({time})});
    
    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADRecordArray2",
            description="Test for bug in #5346",
            inline_functions="none",
            generate_dae_jacobian=true,
            generate_block_jacobian=true,
            template="
$CAD_dae_blocks_residual_functions$
$CAD_ode_derivatives$
            ",
            generatedCode="
static int dae_block_dir_der_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t v_0;
    jmi_real_t d_0;
    JMI_ARR(STAT, R_0_r, R_0_ra, tmp_var_0, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_1, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_2, 1, 1)
    JMI_ARR(STAT, R_0_r, R_0_ra, tmp_der_0, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_3, 2, 1)
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    jmi_real_t** dF = &dRes;
    jmi_real_t** dz;
    if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_0;
        return 0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE) {
        dz = jmi->dz_active_variables;
        (*dz)[ jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] = dx[0];
        _y_0 = x[0];
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_INACTIVE) {
        dz = jmi->dz;
    } else if (evaluation_mode == JMI_BLOCK_WRITE_BACK) {
        dz = jmi->dz;
        (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] = -(*dF)[0];
    } else {
        return -1;
    }
    if (evaluation_mode == JMI_BLOCK_EVALUATE_INACTIVE || evaluation_mode == JMI_BLOCK_EVALUATE) {
        JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, tmp_var_0, 2, 1, 2)
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_1, 2, 1, 2)
        jmi_array_rec_1(tmp_var_0, 1)->x = tmp_1;
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_2, 1, 1, 1)
        jmi_array_rec_1(tmp_var_0, 2)->x = tmp_2;
        JMI_ARRAY_INIT_1(STAT, R_0_r, R_0_ra, tmp_der_0, 2, 1, 2)
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_3, 2, 1, 2)
        jmi_array_rec_1(tmp_der_0, 1)->x = tmp_3;
        JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
        jmi_array_rec_1(tmp_der_0, 2)->x = tmp_4;
        jmi_array_ref_1(jmi_array_rec_1(tmp_var_0, 1)->x, 1) = AD_WRAP_LITERAL(1);
        jmi_array_ref_1(jmi_array_rec_1(tmp_var_0, 1)->x, 2) = _y_0;
        jmi_array_ref_1(jmi_array_rec_1(tmp_var_0, 2)->x, 1) = _time;
        jmi_array_ref_1(jmi_array_rec_1(tmp_der_0, 1)->x, 1) = AD_WRAP_LITERAL(0);
        jmi_array_ref_1(jmi_array_rec_1(tmp_der_0, 1)->x, 2) = (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx];
        jmi_array_ref_1(jmi_array_rec_1(tmp_der_0, 2)->x, 1) = (*dz)[jmi->offs_t];
        func_CADCodeGenArrayTests_CADRecordArray2_f_der_AD0(tmp_var_0, tmp_der_0, &v_0, &d_0);
        (*res)[0] = v_0 - (_y_0);
        (*dF)[0] = d_0 - ((*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx]);
        (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] = 0;
    }
        JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end CADRecordArray2;

end CADCodeGenArrayTests;
