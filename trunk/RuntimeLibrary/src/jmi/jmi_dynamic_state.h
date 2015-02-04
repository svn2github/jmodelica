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


/** \file jmi_dynamic_state.h
 *  \brief Structures and functions for handling dynamic state select.
 */

#ifndef _JMI_DYNAMIC_STATE_H
#define _JMI_DYNAMIC_STATE_H

#include "jmi_types.h"

typedef int (*jmi_dynamic_state_coefficents_func_t)(jmi_t* jmi, jmi_real_t* residual);

struct jmi_dynamic_state_set_t {
    jmi_int_t n_variables;
    jmi_int_t n_states;
    jmi_int_t *variables_value_references;
    jmi_int_t *state_value_references;
    jmi_int_t *ds_state_value_references;
    jmi_int_t *algebraic_value_references;
    jmi_int_t *ds_algebraic_value_references;
    jmi_int_t *temp_algebraic;
    jmi_real_t *temp;
    jmi_dynamic_state_coefficents_func_t coefficents;
};

int jmi_dynamic_state_perform_update(jmi_t* jmi, jmi_int_t index_set);

int jmi_dynamic_state_update_states(jmi_t* jmi, jmi_int_t index_set);

int jmi_dynamic_state_verify_choice(jmi_t* jmi);

int jmi_dynamic_state_delete_set(jmi_t* jmi, jmi_int_t index);

/* int jmi_dynamic_state_add_set(jmi_t* jmi, jmi_int_t index_set, jmi_int_t n_variables, jmi_int_t n_states, jmi_int_t* value_references, jmi_dynamic_state_coefficents_func_t coefficents); */
int jmi_dynamic_state_add_set(jmi_t* jmi, int index, int n_variables, int n_states, int* variable_value_references, int* state_value_references, int* algebraic_value_references, jmi_dynamic_state_coefficents_func_t coefficents); 

int jmi_dynamic_state_check_is_state(jmi_t* jmi, jmi_int_t index_set, ...);


#endif /* _JMI_DYNAMIC_STATE_H */


