/*
    Copyright (C) 2015 Modelon AB

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

/*
 * jmi_dynamic_state.c contains functions that work with jmi_dynamic_state_set_t
 */
 
#include "jmi.h"
#include "jmi_util.h"
#include "jmi_dynamic_state.h"

#include <stdarg.h>

/* #define SAFETY_FACTOR 100 */
#define SAFETY_FACTOR 0.001

/* int jmi_dynamic_state_add_set(jmi_t* jmi, jmi_int_t index, jmi_int_t n_variables, jmi_int_t n_states, jmi_int_t* value_references, jmi_dynamic_state_coefficents_func_t coefficents) { */
int jmi_dynamic_state_add_set(jmi_t* jmi, int index, int n_variables, int n_states, int* variable_value_references, int* ds_state_value_references, int* ds_algebraic_value_references, jmi_dynamic_state_coefficents_func_t coefficents) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    int i = 0;
    
    set->variables_value_references = (jmi_int_t*)calloc(n_variables,sizeof(jmi_int_t));
    set->state_value_references = (jmi_int_t*)calloc(n_states,sizeof(jmi_int_t));
    set->ds_state_value_references = (jmi_int_t*)calloc(n_states,sizeof(jmi_int_t));
    set->algebraic_value_references = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->temp_algebraic = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->ds_algebraic_value_references = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->temp = (jmi_real_t*)calloc((n_variables-n_states)*n_variables,sizeof(jmi_real_t));
    set->n_variables = n_variables;
    set->n_states = n_states;
    set->coefficents = coefficents;
    
    for (i = 0; i < n_variables; i++) {
        set->variables_value_references[i] = variable_value_references[i];
    }
    /* As default, choose the first variables to the states */
    for (i = 0; i < n_states; i++) {
        set->state_value_references[i] = variable_value_references[i];
        set->ds_state_value_references[i] = ds_state_value_references[i];
    }
    for (i = 0; i < n_variables-n_states; i++) {
        set->algebraic_value_references[i] = variable_value_references[i+n_states];
        set->ds_algebraic_value_references[i] = ds_algebraic_value_references[i];
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_delete_set(jmi_t* jmi, jmi_int_t index) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    
    free(set->variables_value_references);
    free(set->state_value_references);
    free(set->ds_state_value_references);
    free(set->algebraic_value_references);
    free(set->ds_algebraic_value_references);
    free(set->temp);
    free(set->temp_algebraic);
    
    return JMI_OK;
}

int jmi_dynamic_state_perform_update(jmi_t* jmi, jmi_int_t index_set) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index_set];
    int i = 0;
    int j = 0;
    jmi_real_t *z;
    
    jmi_log_node_t node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesUpdate", 
                            "Updating the dynamic states in <set:%I>", index_set);
    jmi_log_vrefs(jmi->log, node, logInfo, "old_states", 'r', set->state_value_references, set->n_states);
    
    for (i = 0; i < set->n_variables - set->n_states; i++) {
        set->algebraic_value_references[i] = set->temp_algebraic[i];
    }
    
    for (i = 0; i < set->n_variables; i++) {
        if (set->variables_value_references[i] != set->algebraic_value_references[j]) {
            set->state_value_references[j] = set->variables_value_references[i];
            j++;
        }
        if (j > set->n_variables-set->n_states) { break; }
    }
    for (i = i+1; i < set->n_variables; i++) {
        set->state_value_references[j] = set->variables_value_references[i];
        j++;
    }
    

    for (i = 0; i < set->n_states; i++) {
        z = jmi_get_z(jmi);
        z[jmi_get_index_from_value_ref(set->ds_state_value_references[i])] = z[jmi_get_index_from_value_ref(set->state_value_references[i])];
    }
    for (i = 0; i < set->n_variables - set->n_states; i++) {
        z = jmi_get_z(jmi);
        z[jmi_get_index_from_value_ref(set->ds_algebraic_value_references[i])] = z[jmi_get_index_from_value_ref(set->algebraic_value_references[i])];
    }
    
    /* Set that the states has been updated */
    jmi->updated_states = JMI_TRUE;
    
    jmi_log_vrefs(jmi->log, node, logInfo, "new_states", 'r', set->state_value_references, set->n_states);
    jmi_log_leave(jmi->log, node);
    
    return JMI_OK;
}

int jmi_dynamic_state_check_for_new_states(jmi_t* jmi, jmi_int_t index_set) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index_set];
    jmi_int_t new_states = JMI_FALSE;
    jmi_log_node_t node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesChecking", 
                            "Verifying the dynamic states in <set:%I>", index_set);
    
    /* Update the coefficients */
    set->coefficents(jmi, set->temp);
    
    jmi_log_vrefs(jmi->log, node, logInfo, "variables", 'r', set->variables_value_references, set->n_variables);
    jmi_log_vrefs(jmi->log, node, logInfo, "states", 'r', set->state_value_references, set->n_states);
    jmi_log_vrefs(jmi->log, node, logInfo, "algebraics", 'r', set->algebraic_value_references, set->n_variables - set->n_states);
    jmi_log_real_matrix(jmi->log, node, logInfo, "CoefficientMatrix", set->temp, set->n_variables-set->n_states, set->n_variables);
    
    if (set->n_variables - set->n_states == 1) {
        int i = 0;
        jmi_int_t best_choice = set->algebraic_value_references[0];
        jmi_real_t best_value = -1;
        
        for (i = 0; i < set->n_variables; i++) {
            if (set->algebraic_value_references[0] == set->variables_value_references[i]) {
                if (JMI_ABS(set->temp[i]) < SAFETY_FACTOR) {
                    /* Look if there are any other better choice */
                    best_value = JMI_ABS(set->temp[i]);
                }
            }
        }
        if (best_value != -1) {
            jmi_log_node(jmi->log, logInfo, "Info", "Looking for new dynamic states in <set:%I> due to <value:%E>.",index_set, best_value);
            for (i = 0; i < set->n_variables; i++) {
                if (JMI_ABS(best_value) < JMI_ABS(set->temp[i])) {
                    best_value = JMI_ABS(set->temp[i]);
                    best_choice = set->variables_value_references[i];
                }
            }
        }
        
        if (best_value != -1 && best_choice != set->algebraic_value_references[0]) {
            new_states = JMI_TRUE;
            set->temp_algebraic[0] = best_choice;
        }
        
        /*
        for (i = 1; i < set->n_variables; i++) {
            if (JMI_ABS(set->temp[i]) < min) {
                second_min = min;
                min = JMI_ABS(set->temp[i]);
                index_alg = set->variables_value_references[i];
            } else if(second_min == -1) {
                second_min = JMI_ABS(set->temp[i]);
            }
        }
        jmi_log_node(jmi->log, logInfo, "Info", "Comparing <min:%E> against <second_min:%E> in <set:%I>.",
            min, second_min, index_set);
        if (min < SAFETY_FACTOR*second_min) {
            for (i = 0; i < set->n_states; i++) {
                if (index_alg == set->state_value_references[i]) { 
                    new_states = JMI_TRUE;
                }
            }
        }
        */
        
        if (new_states == JMI_TRUE) {
            jmi_log_node(jmi->log, logInfo, "Info", "Found new dynamic states in <set:%I>. Changing algebraic to <real: #r%d#>.",
             index_set, best_choice);
        }
    } else {
        jmi_log_node(jmi->log, logError, "Error", "Trying to update the <set:%I> but the set is multi-dimensional which is currently not supported.",
             index_set);
    }
    
    jmi_log_leave(jmi->log, node);
    
    return new_states;
}

int jmi_dynamic_state_update_states(jmi_t* jmi, jmi_int_t index_set) {    
    jmi_int_t new_states = jmi_dynamic_state_check_for_new_states(jmi, index_set);
    
    if (new_states == JMI_TRUE) {
        jmi_dynamic_state_perform_update(jmi, index_set);
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_verify_choice(jmi_t* jmi) {
    int i = 0;
    jmi_int_t new_states = JMI_FALSE;
    jmi_log_node_t node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesVerifying", 
                            "Verifying the dynamic states.");
    
    for (i = 0; i < jmi->n_dynamic_state_sets; i++) {
        new_states = jmi_dynamic_state_check_for_new_states(jmi, i);
        if (new_states == JMI_TRUE) {
            jmi_log_node(jmi->log, logInfo, "Info", "Detected bad choice of dynamic states in <set:%I>.",i);
            jmi_log_leave(jmi->log, node);
            return JMI_UPDATE_STATES;
        }
    }
    
    jmi_log_leave(jmi->log, node);
    
    return JMI_OK;
}

int jmi_dynamic_state_check_is_state(jmi_t* jmi, jmi_int_t index, ...) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    int ret = JMI_TRUE;
    int i = 0;
    jmi_log_node_t node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesCheck", 
                            "Checking if the following are states.");
    va_list ap;
    va_start(ap, index);
    
    for (i = 0; i < set->n_states; i++) {
        jmi_int_t value_reference = va_arg(ap, jmi_int_t);
        jmi_log_vrefs(jmi->log, node, logInfo, "is_state", 'r', &value_reference, 1);
        
        if (set->state_value_references[i] != value_reference) {
            ret = JMI_FALSE;
            break;
        }
    }
    va_end(ap);
    
    jmi_log_leave(jmi->log, node);
    
    return ret;
}
