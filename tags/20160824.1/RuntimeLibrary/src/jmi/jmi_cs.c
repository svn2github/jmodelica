/*
    Copyright (C) 2013 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "stdio.h"
#include "jmi_cs.h"

static int is_disc_input_with_diff_value(jmi_t*                     jmi,
                                         const jmi_value_reference  valueref[],
                                         const void*                value,
                                         size_t                     i) {
    size_t z_index;
    int is_integer_input, is_boolean_input;
    
    z_index = jmi_get_index_from_value_ref(valueref[i]);
    is_integer_input = (z_index >= jmi->offs_integer_u && z_index < jmi->offs_boolean_d);
    is_boolean_input = (z_index >= jmi->offs_boolean_u && z_index < jmi->offs_sw);
    /* TODO: Add check for if discrete reals have changed when codegen is fixed:
     * is_disc_real_input = (index >= jmi->offs_disc_real_u && index < jmi->XXX); */
    
    if (is_integer_input) {
        return ((*jmi->z)[z_index] != ((jmi_int_t*)value)[i]);
    } else if (is_boolean_input) {
        return ((*jmi->z)[z_index] != ((jmi_boolean*)value)[i]);
    /*} else if (is_disc_real_input) {
        return (jmi_abs((*jmi->z)[z_index] - ((jmi_real_t*)value)[i]) < 
                JMI_ALMOST_EPS * jmi_abs((*jmi->z)[z_index]); */
    } else {
        return 0;
    }
}

int jmi_cs_check_discrete_input_change(jmi_t*                       jmi,
                                       const jmi_value_reference    vr[],
                                       size_t                       nvr,
                                       const void*                  value) {
    size_t i;
    
    for (i = 0; i < nvr; i++) {
        if (is_disc_input_with_diff_value(jmi, vr, value, i)) {
            return 1; /* Detected change */
        }
    }
    
    return 0; /* No changed detected */
}

int jmi_cs_set_real_input_derivatives(jmi_ode_problem_t* ode_problem, 
        const jmi_value_reference vr[], size_t nvr, const int order[],
        const jmi_real_t value[]) {
    
    jmi_cs_real_input_t* real_inputs;
    size_t i, j;
    jmi_boolean found_real_input = FALSE;
    
    for (i = 0; i < nvr; i++) {
        if (order[i] < 1 || order[i] > JMI_CS_MAX_INPUT_DERIVATIVES) {
            jmi_log_node(ode_problem->log, logError, "SetInputDerivativeFailed",
                "Failed to set the input derivative, un-supported order: "
                "<order:%d>", order[i]);
            return -1;
        }
        found_real_input = FALSE;
        
        /* Check if there exists an active input with the value reference vr[i] */
        real_inputs = ode_problem -> real_inputs;
        for (j = 0; j < ode_problem -> n_real_u; j++) {
            if (real_inputs[j].vr == vr[i] && real_inputs[j].active == TRUE) {
                real_inputs[j].input_derivatives[order[i]-1] = value[i];
                found_real_input = TRUE;
                break;
            }
        }
        
        /* Found an active real input, continue */
        if (found_real_input == TRUE) {
            continue;
        }
        
        /* No active real input found, activate an available */
        for (j = 0; j < ode_problem -> n_real_u; j++) {
            if (real_inputs[j].active == FALSE) {
                jmi_cs_init_real_input_struct(&(real_inputs[j]));
                real_inputs[j].active = TRUE;
                real_inputs[j].input_derivatives[order[i]-1] = value[i];
                real_inputs[j].vr = vr[i];
                
                found_real_input = TRUE;
                break;
            }
        }
        
        /* No available real inputs -> the user has set a variable which is
         * not a real input */
        if (found_real_input == FALSE) {
            jmi_log_comment(ode_problem->log, logError,
                "Failed to set the input derivative, inconsistent number of "
                "real inputs.");
            return -1;
        }
    }
    
    return 0;
}

int jmi_cs_init_real_input_struct(jmi_cs_real_input_t* real_input) {
    int i = 0;
    jmi_real_t fac[JMI_CS_MAX_INPUT_DERIVATIVES] = {1,2,6};
    
    real_input->active = FALSE;
    real_input->tn     = 0.0;
    real_input->value  = 0.0;
    
    for (i = 0; i < JMI_CS_MAX_INPUT_DERIVATIVES; i++) {
        real_input->input_derivatives[i] = 0.0;
        real_input->input_derivatives_factor[i] = fac[i];
    }
    
    return 0;
}
