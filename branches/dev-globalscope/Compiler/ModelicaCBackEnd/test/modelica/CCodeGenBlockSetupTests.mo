/*
    Copyright (C) 2009-2018 Modelon AB

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


package CCodeGenBlockSetupTests

package WhenTestCache

model WhenTestCache1
    function f
        input Real x;
        output Real y = x;
        algorithm
        annotation(Inline=false);
    end f;
    
    discrete Real y;
initial equation
    y = 0;
equation
    when time > 1 then
        y = f(time);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenTestCache1",
            description="",
            template="
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
            generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    dae_block_0_set_up(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

static JMI_DEF(REA, tmp_1)
static int tmp_1_computed = 0;
static void dae_block_0_set_up(jmi_t* jmi) {
    tmp_1_computed = 0;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870915;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_1 = _sw(0);
        }
        _y_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1)), JMI_TRUE, JMI_CACHED(tmp_1, func_CCodeGenBlockSetupTests_WhenTestCache_WhenTestCache1_f_exp0(_time)), pre_y_0);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTestCache1;

model WhenTestCache2
    function f
        input Real x;
        output Real y = x;
    algorithm
        annotation(Inline=false);
    end f;

    Real y, x;
equation
    when time > 1 then
        y = f(time + x);
        x = f(time + y);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="WhenTestCache2",
            description="",
            template="
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
            generatedCode="
int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE) {
        x[0] = 3;
    } else if (evaluation_mode == JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE) {
        x[0] = 3;
        x[1] = 2;
    } else if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL_AUTO) {
        (*res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = _y_0;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
            _y_0 = x[0];
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (1), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_2 = _sw(0);
        }
        _x_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, func_CCodeGenBlockSetupTests_WhenTestCache_WhenTestCache2_f_exp0(_time + _y_0), pre_x_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, func_CCodeGenBlockSetupTests_WhenTestCache_WhenTestCache2_f_exp0(_time + _x_1), pre_y_0) - (_y_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTestCache2;

end WhenTestCache;

end CCodeGenTests;
