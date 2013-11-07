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

int jmi_cs_set_real_input_derivatives(jmi_ode_problem_t* ode_problem, 
        const jmi_value_reference vr[], size_t nvr, const int order[],
        const jmi_real_t value[]) {
    
    jmi_cs_input_t* inputs;
    int i,j;
    jmi_boolean found_input = FALSE;

    if (nvr > ode_problem -> n_real_u) {
        jmi_log_comment(ode_problem->log, logError, "Failed to set the input derivative, too many inputs.");
        return -1;
    }
    
    for (i = 0; i < nvr; i++) {
        if (order[i] < 1 || order[i] > JMI_CS_MAX_INPUT_DERIVATIVES) {
            jmi_log_node(ode_problem->log, logError, "SetInputDerivativeFailed", "Failed to set the input derivative, un-supported order: <order:%d>",order[i]);
            return -1;
        }
        found_input = FALSE;
        
        /* Check if there exists an active input with the value reference vr[i] */
        inputs = ode_problem -> inputs;
        for (j = 0; j < ode_problem -> n_real_u; j++) {
            if (inputs[j].vr == vr[i] && inputs[j].active == TRUE) {
                inputs[j].input_derivatives[order[i]-1] = value[i];
                found_input = TRUE;
                break;
            }
        }
        
        /* Found an active input, continue */
        if (found_input == TRUE) {
            continue;
        }
        
        /* No active input found, active an available */
        for (j = 0; j < ode_problem -> n_real_u; j++) {
            if (inputs[j].active == FALSE) {
                jmi_cs_init_input_struct(&(inputs[j]));
                inputs[j].active = TRUE;
                inputs[j].input_derivatives[order[i]-1] = value[i];
                inputs[j].vr = vr[i];
                
                found_input = TRUE;
                break;
            }
        }
        
        /* No available inputs -> the user has set an input which is not an input */
        if (found_input == FALSE) {
            jmi_log_comment(ode_problem->log, logError, "Failed to set the input derivative, inconsistent number of inputs.");
            return -1;
        }
        
        /*
        for (j = 0; j < ode_problem->n_real_u; j++) {
            if (inputs[j].vr == vr[i]) {
                if (ode_problem-> -> inputs[j].active == FALSE) {
                    jmi_cs_init_input_struct(&(ode_problem-> -> inputs[j]));
                    ode_problem-> -> inputs[j].active = TRUE;
                }
                ode_problem -> inputs[j].input_derivatives[order[i]-1] = value[i];
                break;f
            }
        }
        */
    }
    
    return 0;
}

int jmi_cs_init_input_struct(jmi_cs_input_t* value) {
    int i = 0;
    jmi_real_t fac[JMI_CS_MAX_INPUT_DERIVATIVES] = {1,2,6};
    
    value -> active = FALSE;
    value -> tn     = 0.0;
    value -> input  = 0.0;
    
    for (i = 0; i < JMI_CS_MAX_INPUT_DERIVATIVES; i++) {
        value -> input_derivatives[i] = 0.0;
        value -> input_derivatives_factor[i] = fac[i];
    }
    
    return 0;
}
