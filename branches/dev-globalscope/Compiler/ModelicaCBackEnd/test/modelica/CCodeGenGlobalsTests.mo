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


package CCodeGenGlobalsTests

package Reinit

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
            relational_time_events=false,
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_3 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_3 = 1;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            JMI_GLOBAL(tmp_1) = AD_WRAP_LITERAL(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

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
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _y_1;
    _der_x_6 = 1;
    _der_y_7 = 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _y_1 - (2), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (2), _sw(1), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[1]);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    if (JMI_GLOBAL(tmp_2) != _y_1) {
        _y_1 = JMI_GLOBAL(tmp_2);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_6 = 1;
    _der_y_7 = 2;
    _y_1 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _y_1 - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    _x_0 = 0.0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (2), _sw(1), JMI_REL_GT);
    }
    _temp_2_3 = _sw(1);
    pre_temp_1_2 = JMI_FALSE;
    pre_temp_2_3 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _y_1 - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_2 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            JMI_GLOBAL(tmp_1) = AD_WRAP_LITERAL(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

static int dae_block_1(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 2 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _x_0 - (2), _sw(1), JMI_REL_GT);
            }
            _temp_2_3 = _sw(1);
        }
        if (LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))) {
            JMI_GLOBAL(tmp_2) = AD_WRAP_LITERAL(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


-----
")})));
end ReinitCTest2;

model ReinitCTest3
    Real x,y;
equation
    der(x) = 1;
    der(y) = 2;
    when time > 2 then
        reinit(x, 1);
    elsewhen time > 1 then
        reinit(y, 1);
    end when;
    
    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest3",
            description="",
            variability_propagation=false,
            relational_time_events=false,
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _y_1;
    _der_x_6 = 1;
    _der_y_7 = 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    if (JMI_GLOBAL(tmp_2) != _y_1) {
        _y_1 = JMI_GLOBAL(tmp_2);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    _der_x_6 = 1;
    _der_y_7 = 2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_2 = _sw(0);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
    }
    _temp_2_3 = _sw(1);
    _x_0 = 0.0;
    _y_1 = 0.0;
    pre_temp_1_2 = JMI_FALSE;
    pre_temp_2_3 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870919;
        x[1] = 536870918;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870918;
        x[1] = 536870919;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(1) = jmi_turn_switch(jmi, _time - (1), _sw(1), JMI_REL_GT);
            }
            _temp_2_3 = _sw(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_2 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2))) {
            JMI_GLOBAL(tmp_1) = AD_WRAP_LITERAL(1);
        } else {
            if (LOG_EXP_AND(_temp_2_3, LOG_EXP_NOT(pre_temp_2_3))) {
                JMI_GLOBAL(tmp_2) = AD_WRAP_LITERAL(1);
            }
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


-----
")})));
end ReinitCTest3;

model ReinitCTest4
    function f
        input Real[:] x;
        output Real y = sum(x);
        algorithm
        annotation(Inline=false);
    end f;

    Real x;
equation
    der(x) = f({time});
    when time > 2 then
        reinit(x, f({1}));
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest4",
            description="",
            variability_propagation=false,
            relational_time_events=false,
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    JMI_DEF(REA, tmp_2)
    int tmp_2_computed = 0;
-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    jmi_array_ref_1(tmp_3, 1) = _time;
    _der_x_3 = func_CCodeGenGlobalsTests_Reinit_ReinitCTest4_f_exp0(tmp_3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    dae_block_0_set_up(jmi);
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_3, 1, 1)
    JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_3, 1, 1, 1)
    jmi_array_ref_1(tmp_3, 1) = _time;
    _der_x_3 = func_CCodeGenGlobalsTests_Reinit_ReinitCTest4_f_exp0(tmp_3);
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    pre_temp_1_1 = JMI_FALSE;
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static void dae_block_0_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_2_computed) = 0;
}

static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_ARR(STAT, jmi_real_t, jmi_array_t, tmp_4, 1, 1)
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch(jmi, _time - (2), _sw(0), JMI_REL_GT);
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1))) {
            JMI_ARRAY_INIT_1(STAT, jmi_real_t, jmi_array_t, tmp_4, 1, 1, 1)
            jmi_array_ref_1(tmp_4, 1) = AD_WRAP_LITERAL(1);
            JMI_GLOBAL(tmp_1) = JMI_CACHED(JMI_GLOBAL(tmp_2), func_CCodeGenGlobalsTests_Reinit_ReinitCTest4_f_exp0(tmp_4));
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


-----
")})));
end ReinitCTest4;

//TODO: The result in this test isn't ideal since the reinit operator is
// handled in the original system as well even though it won't be triggered.
// This is however not the fault of reinit but when initial()...
model ReinitCTest5
    Real x;
equation
    der(x) = time;
    when initial() then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest5",
            description="Test the reinit operator in the initial system",
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_2) = _x_0;
    _der_x_1 = _time;
    if (_atInitial) {
        JMI_GLOBAL(tmp_2) = AD_WRAP_LITERAL(1);
    }
    if (JMI_GLOBAL(tmp_2) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_2);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_1 = _time;
    _x_0 = 0.0;
    JMI_GLOBAL(tmp_1) = AD_WRAP_LITERAL(1);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

-----
")})));
end ReinitCTest5;

model ReinitCTest6
    Real x;
equation
    der(x) = time;
    when {initial(), time > 2} then
        reinit(x, 1);
    end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest6",
            description="Test the reinit operator in the initial system",
            template="
$C_global_temps$
-----
$C_ode_derivatives$
-----
$C_ode_initialization$
-----
$C_dae_blocks_residual_functions$
-----
$C_dae_init_blocks_residual_functions$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_2) = _x_0;
    _der_x_3 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (JMI_GLOBAL(tmp_2) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_2);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----

int model_ode_initialize_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    _der_x_3 = _time;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
    }
    _temp_1_1 = _sw(0);
    _x_0 = 0.0;
    JMI_GLOBAL(tmp_1) = AD_WRAP_LITERAL(1);
    pre_temp_1_1 = JMI_FALSE;
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}

-----
static int dae_block_0(jmi_t* jmi, jmi_real_t* x, jmi_real_t* residual, int evaluation_mode) {
    /***** Block: 1 *****/
    jmi_real_t** res = &residual;
    int ef = 0;
    JMI_DYNAMIC_INIT()
    if (evaluation_mode == JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode == JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE) {
        x[0] = 536870916;
    } else if (evaluation_mode & JMI_BLOCK_EVALUATE || evaluation_mode & JMI_BLOCK_WRITE_BACK) {
        if ((evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) == 0) {
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
            if (evaluation_mode & JMI_BLOCK_EVALUATE_NON_REALS) {
                _sw(0) = jmi_turn_switch_time(jmi, _time - (2), _sw(0), jmi->eventPhase ? (JMI_REL_GEQ) : (JMI_REL_GT));
            }
            _temp_1_1 = _sw(0);
        }
        if (LOG_EXP_OR(_atInitial, LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1)))) {
            JMI_GLOBAL(tmp_2) = AD_WRAP_LITERAL(1);
        }
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}


-----
")})));
end ReinitCTest6;


model ReinitCTest7
    Real x(start = 1);
equation
    der(x) = -x;
  when x < 0.9 then
    reinit(x, 0.8);
  elsewhen x < 0.7 then
    reinit(x, 0.4);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest7",
            description="Reinit of same var in different elsewhen branches",
            template="
$C_global_temps$
-----
$C_ode_derivatives$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _x_0;
    _der_x_5 = - _x_0;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.9), _sw(0), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    } else if (JMI_GLOBAL(tmp_2) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_2);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end ReinitCTest7;


model ReinitCTest8
    Real x(start = 1);
    Real y(start = 2);
    Real z(start = 3);
equation
    der(x) = -x;
    der(y) = -y;
    der(z) = -z;
  when x < 0.9 then
    reinit(x, 0.8);
    reinit(y, 1.8);
  elsewhen x < 0.7 then
    reinit(z, 2.4);
    reinit(x, 0.4);
  elsewhen x < 0.5 then
    reinit(z, 2.1);
    reinit(x, 0.1);
    reinit(y, 1.1);
  end when;

    annotation(__JModelica(UnitTesting(tests={
        CCodeGenTestCase(
            name="ReinitCTest8",
            description="Reinit of same var in different elsewhen branches, check grouping of several sets of reinits",
            template="
$C_global_temps$
-----
$C_ode_derivatives$
",
            generatedCode="
    jmi_real_t tmp_1;
    jmi_real_t tmp_2;
    jmi_real_t tmp_3;
    jmi_real_t tmp_4;
    jmi_real_t tmp_5;
    jmi_real_t tmp_6;
    jmi_real_t tmp_7;

-----

int model_ode_derivatives_base(jmi_t* jmi) {
    int ef = 0;
    JMI_DYNAMIC_INIT()
    JMI_GLOBAL(tmp_1) = _x_0;
    JMI_GLOBAL(tmp_2) = _y_1;
    JMI_GLOBAL(tmp_3) = _z_2;
    JMI_GLOBAL(tmp_4) = _x_0;
    JMI_GLOBAL(tmp_5) = _z_2;
    JMI_GLOBAL(tmp_6) = _x_0;
    JMI_GLOBAL(tmp_7) = _y_1;
    _der_x_9 = - _x_0;
    _der_y_10 = - _y_1;
    _der_z_11 = - _z_2;
    if (jmi->atInitial || jmi->atEvent) {
        _sw(2) = jmi_turn_switch(jmi, _x_0 - (0.5), _sw(2), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(1) = jmi_turn_switch(jmi, _x_0 - (0.7), _sw(1), JMI_REL_LT);
    }
    if (jmi->atInitial || jmi->atEvent) {
        _sw(0) = jmi_turn_switch(jmi, _x_0 - (0.9), _sw(0), JMI_REL_LT);
    }
    ef |= jmi_solve_block_residual(jmi->dae_block_residuals[0]);
    if (JMI_GLOBAL(tmp_1) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_1);
        jmi->reinit_triggered = 1;
    } else if (JMI_GLOBAL(tmp_4) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_4);
        jmi->reinit_triggered = 1;
    } else if (JMI_GLOBAL(tmp_6) != _x_0) {
        _x_0 = JMI_GLOBAL(tmp_6);
        jmi->reinit_triggered = 1;
    }
    if (JMI_GLOBAL(tmp_2) != _y_1) {
        _y_1 = JMI_GLOBAL(tmp_2);
        jmi->reinit_triggered = 1;
    } else if (JMI_GLOBAL(tmp_7) != _y_1) {
        _y_1 = JMI_GLOBAL(tmp_7);
        jmi->reinit_triggered = 1;
    }
    if (JMI_GLOBAL(tmp_3) != _z_2) {
        _z_2 = JMI_GLOBAL(tmp_3);
        jmi->reinit_triggered = 1;
    } else if (JMI_GLOBAL(tmp_5) != _z_2) {
        _z_2 = JMI_GLOBAL(tmp_5);
        jmi->reinit_triggered = 1;
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end ReinitCTest8;

end Reinit;

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
$C_global_temps$
$C_ode_derivatives$
$C_dae_blocks_residual_functions$
",
            generatedCode="
    JMI_DEF(REA, tmp_1)
    int tmp_1_computed = 0;


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

static void dae_block_0_set_up(jmi_t* jmi) {
    JMI_GLOBAL(tmp_1_computed) = 0;
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
        _y_0 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_1, LOG_EXP_NOT(pre_temp_1_1)), JMI_TRUE, JMI_CACHED(JMI_GLOBAL(tmp_1), func_CCodeGenGlobalsTests_WhenTestCache_WhenTestCache1_f_exp0(_time)), pre_y_0);
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
$C_global_temps$
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
        _x_1 = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, func_CCodeGenGlobalsTests_WhenTestCache_WhenTestCache2_f_exp0(_time + _y_0), pre_x_1);
        if (evaluation_mode & JMI_BLOCK_EVALUATE) {
            (*res)[0] = COND_EXP_EQ(LOG_EXP_AND(_temp_1_2, LOG_EXP_NOT(pre_temp_1_2)), JMI_TRUE, func_CCodeGenGlobalsTests_WhenTestCache_WhenTestCache2_f_exp0(_time + _x_1), pre_y_0) - (_y_0);
        }
    }
    JMI_DYNAMIC_FREE()
    return ef;
}
")})));
end WhenTestCache2;

end WhenTestCache;

end CCodeGenGlobalsTests;
