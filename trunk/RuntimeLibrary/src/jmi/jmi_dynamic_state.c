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

int jmi_dynamic_state_add_set(jmi_t* jmi, int index, int n_variables, int n_states, int* variable_value_references, int* state_value_references, int* algebraic_value_references, jmi_dynamic_state_coefficents_func_t coefficents);
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    int i = 0;
    
    set->variables_value_references = (jmi_int_t*)calloc(n_variables,sizeof(jmi_int_t));
    set->state_value_references = (jmi_int_t*)calloc(n_states,sizeof(jmi_int_t));
    set->n_variables = n_variables;
    set->n_states = n_states;
    set->coefficents = coefficents;
    
    for (i = 0; i < n_variables; i++) {
        set->variables_value_references[i] = variable_value_references[i];
    }
    /* As default, choose the first variables to the states */
    for (i = 0; i < n_states; i++) {
        set->state_value_references[i] = variable_value_references[i];
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_check_is_state(jmi_t* jmi, int index, int* value_references) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    int ret = JMI_TRUE;
    int i = 0;
    
    for (i = 0; i < set->n_states; i++) {
        if (set->state_value_references[i] != value_references[i]) {
            ret = JMI_FALSE;
            break;
        }
    }
    
    return ret;
}
