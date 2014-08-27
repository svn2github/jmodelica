/*
    Copyright (C) 2009-2013 Modelon AB

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

package LocalIterationBack
    
    model CGenTest1
        Real a, b, c;
    equation
        20 = c * a;
        23 = c * b;
        c = a + b;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="CGenTest1",
            description="Tests c code generation of local iteration in torn blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            local_iteration_in_tearing="all",
            template="
$C_dae_blocks_residual_functions$
$C_dae_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1.1 *****/
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
        x[0] = _b_1;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _b_1 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _c_2 * _b_1 - (23);
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
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_NON_REAL_VALUE_REFERENCE) {
    } else if (evaluation_mode == JMI_BLOCK_ACTIVE_SWITCH_INDEX) {
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _c_2;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _c_2 = x[0];
        }
        ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
        _a_0 = - (- _c_2 + _b_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = _c_2 * _a_0 - (20);
        }
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_1, NULL, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"1.1\");
    jmi_dae_add_equation_block(*jmi, dae_block_0, NULL, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\");
")})));
    end CGenTest1;




    model CADGenTest1
        Real a, b, c;
    equation
        20 = c * a;
        23 = c * b;
        c = a + b;
    
    annotation(__JModelica(UnitTesting(tests={
        CADCodeGenTestCase(
            name="CADGenTest1",
            description="Tests generation of local iteration in torn blocks",
            generate_ode=true,
            equation_sorting=true,
            automatic_tearing=true,
            local_iteration_in_tearing="all",
            generate_block_jacobian=true,
            template="
$CAD_dae_blocks_residual_functions$
$CAD_dae_add_blocks_residual_functions$
",
            generatedCode="
static int dae_block_dir_der_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int evaluation_mode) {
    /***** Block: 1.1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_real_t** dF = &dRes;
    jmi_real_t** dz;
    if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _b_1;
        return 0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE) {
        dz = jmi->dz_active_variables;
        (*dz)[ jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] = dx[0];
        _b_1 = x[0];
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_INACTIVE) {
        dz = jmi->dz;
    } else if (evaluation_mode == JMI_BLOCK_WRITE_BACK) {
        dz = jmi->dz;
        (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] = -(*dF)[0];
    } else {
        return -1;
    }
    if (evaluation_mode == JMI_BLOCK_EVALUATE_INACTIVE || evaluation_mode == JMI_BLOCK_EVALUATE) {
        (*res)[0] = _c_2 * _b_1 - (23);
        (*dF)[0] = (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] * _b_1 + _c_2 * (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] - (AD_WRAP_LITERAL(0));
        (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx] = 0;
    }
    return ef;
}

static int dae_block_dir_der_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_ad_var_t v_0;
    jmi_ad_var_t d_0;
    jmi_ad_var_t v_1;
    jmi_ad_var_t d_1;
    jmi_real_t** res = &residual;
    int ef = 0;
    jmi_real_t** dF = &dRes;
    jmi_real_t** dz;
    if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _c_2;
        return 0;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE) {
        dz = jmi->dz_active_variables;
        (*dz)[ jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] = dx[0];
        _c_2 = x[0];
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_INACTIVE) {
        dz = jmi->dz;
    } else if (evaluation_mode == JMI_BLOCK_WRITE_BACK) {
        dz = jmi->dz;
        (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] = -(*dF)[0];
    } else {
        return -1;
    }
    ef |= jmi_ode_unsolved_block_dir_der(jmi, jmi->dae_block_residuals[1]);
    v_1 = - _c_2;
    d_1 = - ((*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx]);
    v_0 = (v_1 + _b_1);
    d_0 = d_1 + (*dz)[jmi_get_index_from_value_ref(1)-jmi->offs_real_dx];
    _a_0 = - v_0;
    (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] = - (d_0);
    if (evaluation_mode == JMI_BLOCK_EVALUATE_INACTIVE || evaluation_mode == JMI_BLOCK_EVALUATE) {
        (*res)[0] = _c_2 * _a_0 - (20);
        (*dF)[0] = (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] * _a_0 + _c_2 * (*dz)[jmi_get_index_from_value_ref(0)-jmi->offs_real_dx] - (AD_WRAP_LITERAL(0));
        (*dz)[jmi_get_index_from_value_ref(2)-jmi->offs_real_dx] = 0;
    }
    return ef;
}


    jmi_dae_add_equation_block(*jmi, dae_block_1, dae_block_dir_der_1, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 1, \"1.1\");
    jmi_dae_add_equation_block(*jmi, dae_block_0, dae_block_dir_der_0, 1, 0, 0, JMI_CONTINUOUS_VARIABILITY, JMI_CONSTANT_VARIABILITY, JMI_KINSOL_SOLVER, 0, \"1\");
")})));
    end CADGenTest1;

end LocalIterationBack;
