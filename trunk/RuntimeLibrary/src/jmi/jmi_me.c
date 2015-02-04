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

#include "jmi_me.h"
#include "jmi_delay.h"
#include "jmi_dynamic_state.h"

#define indexmask  0x07FFFFFF
#define negatemask 0x08000000
#define typemask   0xF0000000

jmi_value_reference get_index_from_value_ref(jmi_value_reference valueref) {
    /* Translate a ValueReference into variable index in z-vector. */
    jmi_value_reference index = valueref & indexmask;
    
    return index;
}

jmi_value_reference get_type_from_value_ref(jmi_value_reference valueref) {
    /* Translate a ValueReference into variable type in z-vector. */
    jmi_value_reference type = valueref & typemask;
    
    return type;
}

jmi_value_reference is_negated(jmi_value_reference valueref) {
    /* Checks for a valueReference if it is negated. */
    jmi_value_reference negated = valueref & negatemask;
    
    return negated;
}

int jmi_me_init(jmi_callbacks_t* jmi_callbacks, jmi_t* jmi, jmi_string GUID, jmi_string_t resource_location) {
                       
    jmi_t* jmi_ = jmi;
    int retval;
    
    retval = jmi_new(&jmi, jmi_callbacks);
    if(retval != 0) {
        /* creating jmi struct failed */
        jmi_log_comment(jmi_->log, logError, "Creating internal struct failed.");
        return retval;
    }
    
    jmi_ = jmi;
    
    /* Check if the GUID is correct.*/
    if (strcmp(GUID, C_GUID) != 0) {
        jmi_log_comment(jmi_->log, logError, "The model and the description file are not consistent to each other.");
        jmi_delete(jmi_);
        return -1;
    }
    
    /* Check resource location */
    if (resource_location && !jmi_dir_exists(resource_location)) {
        jmi_log_node(jmi->log, logError, "Error", "Resource location does not exist <Path:%s>", resource_location);
        jmi_delete(jmi_);
        return -1;
    }
    jmi_->resource_location = resource_location;
    
    /* set start values*/
    if (jmi_generic_func(jmi_, jmi_set_start_values) != 0) {
        jmi_log_comment(jmi_->log, logError, "Failed to set start values.");
        jmi_delete(jmi_);
        return -1;
    }
    
    /* Runtime options may be updated with start values */
    jmi_update_runtime_options(jmi);

    /* Write start values to the pre vector*/
    jmi_copy_pre_values(jmi);
    
    /* Print some info about Jacobians, if available. */
    if (jmi_->color_info_A != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi_->log, logInfo, "color_info_A");
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_nonzeros: %d> in Jacobian A", jmi_->color_info_A->n_nz);
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_colors: %d> in Jacobian A", jmi_->color_info_A->n_groups);
        jmi_log_leave(jmi_->log, node);
    }

    if (jmi_->color_info_B != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi_->log, logInfo, "color_info_B");
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_nonzeros: %d> in Jacobian B", jmi_->color_info_B->n_nz);
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_colors: %d> in Jacobian B", jmi_->color_info_B->n_groups);
        jmi_log_leave(jmi_->log, node);
    }

    if (jmi_->color_info_C != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi_->log, logInfo, "color_info_C");
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_nonzeros: %d> in Jacobian C", jmi_->color_info_C->n_nz);
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_colors: %d> in Jacobian C", jmi_->color_info_C->n_groups);
        jmi_log_leave(jmi_->log, node);
    }

    if (jmi_->color_info_D != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi_->log, logInfo, "color_info_D");
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_nonzeros: %d> in Jacobian D", jmi_->color_info_D->n_nz);
        jmi_log_fmt(jmi_->log, node, logInfo, "<num_colors: %d> in Jacobian D", jmi_->color_info_D->n_groups);
        jmi_log_leave(jmi_->log, node);
    }
    
    return 0;
}

void jmi_setup_experiment(jmi_t* jmi, jmi_boolean tolerance_defined,
                          jmi_real_t relative_tolerance) {
    
    jmi_update_runtime_options(jmi);
    /* Sets the relative tolerance to a default value for use in Kinsol when tolerance controlled is false */
    if (tolerance_defined == FALSE) {
        jmi->events_epsilon = jmi->options.events_default_tol; /* Used in the event detection */
        jmi->newton_tolerance = jmi->options.nle_solver_default_tol; /* Used in the Newton iteration */
    } else {
        jmi->events_epsilon = jmi->options.events_tol_factor*relative_tolerance; /* Used in the event detection */
        jmi->newton_tolerance = jmi->options.nle_solver_tol_factor*relative_tolerance; /* Used in the Newton iteration */
    }
    jmi->options.block_solver_options.res_tol = jmi->newton_tolerance;
    jmi->options.block_solver_options.events_epsilon = jmi->events_epsilon;
}

int jmi_initialize(jmi_t* jmi) {
    int retval;
    jmi_log_node_t top_node;
    
    if (jmi->is_initialized == 1) {
        jmi_log_comment(jmi->log, logError, "FMU is already initialized: only one initialization is allowed");
        return -1;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 4){
        top_node =jmi_log_enter_fmt(jmi->log, logInfo, "Initialization", 
                                "Starting initialization.");
    }
    
    /* Evaluate parameters */
    jmi_init_eval_parameters(jmi);
    
    /* We are at the initial event TODO: is this really necessary? */
    jmi->atEvent   = JMI_TRUE;
    jmi->atInitial = JMI_TRUE;
    jmi->tmp_events_epsilon = jmi->events_epsilon;
    jmi->events_epsilon = 0.0;
    
    /* Solve initial equations */
    retval = jmi_ode_initialize(jmi);

    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Initialization failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }
    
    /* Copy values to pre after the initial equations are solved. */
    jmi_copy_pre_values(jmi);

    /* Reset atEvent flag */
    jmi->atEvent = JMI_FALSE;
    jmi->atInitial = JMI_FALSE;

    jmi_save_last_successful_values(jmi);
    
    jmi->is_initialized = 1;
    
    /* Initialize delay blocks */
    retval = jmi_init_delay_blocks(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Failed to initialize delay blocks.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }
    
    retval = jmi_next_time_event(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Computation of next time event failed after initialization.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 4){
        jmi_log_leave(jmi->log, top_node);
    }
    
    return 0;
}

int jmi_cannot_set(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    size_t start, size_t end, char* fmt) {
    jmi_value_reference i;
    jmi_value_reference index;
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);
        if (index >= start && index < end) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         fmt, vr[i]);
            return -1;
        }
    }
    return 0;
}

int jmi_set_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 const jmi_real_t value[]) {
    
    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int needParameterUpdate = 0;

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Real variables when the model is terminated");
        return -1;
    }
    
    if (jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_ci, jmi->offs_real_pi,
        "Cannot set Real constant <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pi_s, jmi->offs_real_pi_f,
        "Cannot set Real structural parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pi_f, jmi->offs_real_pi_e,
        "Cannot set Real final parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pi_e, jmi->offs_real_pd,
        "Cannot set Real evaluated parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pd, jmi->offs_integer_ci,
        "Cannot set Real dependent parameter <variable: #r%d#>")) {
        
        return -1;
    }
    
    jmi->recomputeVariables = 1;
    z = jmi_get_z(jmi);
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);

        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < jmi->offs_real_dx) {
            needParameterUpdate = 1;
        }

    }
    if( needParameterUpdate ) {
          jmi_init_eval_parameters(jmi);
    }
    return 0;
}

int jmi_set_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_int_t value[]) {
    
    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int needParameterUpdate = 0;

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Integer variables when the model is terminated");
        return -1;
    }
    
    if (jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_ci, jmi->offs_integer_pi,
        "Cannot set Integer constant <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pi_s, jmi->offs_integer_pi_f,
        "Cannot set Integer structural parameter <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pi_f, jmi->offs_integer_pi_e,
        "Cannot set Integer final parameter <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pi_e, jmi->offs_integer_pd,
        "Cannot set Integer evaluated parameter <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pd, jmi->offs_boolean_ci,
        "Cannot set Integer dependent parameter <variable: #i%d#>")) {
        
        return -1;
    }

    jmi->recomputeVariables = 1;
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < jmi->offs_real_dx) {
             needParameterUpdate = 1;
        }

    }
    if( needParameterUpdate ) {
          jmi_init_eval_parameters(jmi);
    }
    return 0;
}

int jmi_set_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_boolean value[]) {
    
    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int needParameterUpdate = 0;

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Boolean variables when the model is terminated");
        return -1;
    }
    
    if (jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_ci, jmi->offs_boolean_pi,
        "Cannot set Boolean constant <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pi_s, jmi->offs_boolean_pi_f,
        "Cannot set Boolean structural parameter <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pi_f, jmi->offs_boolean_pi_e,
        "Cannot set Boolean final parameter <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pi_e, jmi->offs_boolean_pd,
        "Cannot set Boolean evaluated parameter <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pd, jmi->offs_real_dx,
        "Cannot set Boolean dependent parameter <variable: #b%d#>")) {
        
        return -1;
    }

    jmi->recomputeVariables = 1;
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < jmi->offs_real_dx) {
            needParameterUpdate = 1;
        }

    }
    if( needParameterUpdate ) {
          jmi_init_eval_parameters(jmi);
    }
    return 0;
}

int jmi_set_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   const jmi_string value[]) {
    
    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set String variables when the model is terminated");
        return -1;
    }

    jmi->recomputeVariables = 1;
    jmi_log_comment(jmi->log, logWarning, "Strings are not yet supported.");
    return 0;
}

int jmi_get_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 jmi_real_t value[]) {
    
    int retval;
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int isParameterOrConstant = 1;

    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i < nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }

    /* Get the z vector*/
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = (jmi_real_t)z[index];
    }
    return 0;
}

int jmi_get_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_int_t value[]) {
    
    int retval;
    jmi_real_t* z;
    jmi_value_reference i;
    jmi_value_reference index;
    int isParameterOrConstant = 1;
    
    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i < nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }

    /* Get the z vector*/
    z = jmi_get_z(jmi);
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = (jmi_int_t)z[index];
    }
    return 0;
}

int jmi_get_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_boolean value[]) {
    
    int retval;
    jmi_real_t* z;
    jmi_value_reference i;
    jmi_value_reference index;
    int isParameterOrConstant = 1;
    
    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i < nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }
    
    /* Get the z vector*/
    z = jmi_get_z(jmi);
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = z[index];
    }
    return 0;
}

int jmi_get_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   jmi_string  value[]) {
    
    int retval;
    int i;
    int index;
    int isParameterOrConstant = 1;
    
    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i < nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }

    /* Strings not yet supported. */
    for(i = 0; i < nvr; i++) value[i] = 0;
    jmi_log_comment(jmi->log, logWarning, "Strings are not yet supported.");
    
    return 0;
}

int jmi_get_directional_derivative(jmi_t* jmi,
                const jmi_value_reference vUnknown_ref[], size_t nUnknown,
                const jmi_value_reference vKnown_ref[],   size_t nKnown,
                const jmi_real_t dvKnown[], jmi_real_t dvUnknown[]) {
    
    jmi_real_t* store_dz = jmi->dz[0];
    int i, ef;
    
    jmi->dz[0]                  = jmi->dz_active_variables_buf[jmi->dz_active_index];
    jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];

    for (i = 0; i < jmi->n_v; i++) {
        jmi->dz_active_variables[0][i] = 0;
    }

    for (i = 0; i < nKnown; i++) {
        jmi->dz_active_variables[0][get_index_from_value_ref(vKnown_ref[i])-jmi->offs_real_dx] = dvKnown[i];
    }

    ef = jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);
    for (i = 0; i < nUnknown; i++) {
        dvUnknown[i] = jmi->dz_active_variables[0][get_index_from_value_ref(vUnknown_ref[i])-jmi->offs_real_dx];
    }

    jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];
    jmi->dz[0] = store_dz;

    return ef;
}

int jmi_get_derivatives(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx) {
    int retval;
    jmi_log_node_t node;
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetDerivatives", 
                                "Call to get derivatives at <t:%g>.", jmi_get_t(jmi)[0]);
        if (jmi->jmi_callbacks.log_options.log_level >= 6){
            jmi_log_reals(jmi->log, node, logInfo, "switches", jmi_get_sw(jmi), jmi->n_sw);
            jmi_log_reals(jmi->log, node, logInfo, "booleans", jmi_get_boolean_d(jmi), jmi->n_boolean_d);
            jmi_log_reals(jmi->log, node, logInfo, "integers", jmi_get_integer_d(jmi), jmi->n_integer_d);
        }
    }
    
    
    if (jmi->recomputeVariables == 1  && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            
            /* Store the current time and states */
            jmi_real_t time = *(jmi_get_t(jmi));
            jmi_real_t *x = jmi->jmi_callbacks.allocate_memory(jmi->n_real_x, sizeof(jmi_real_t));
            memcpy(x, jmi_get_real_x(jmi), jmi->n_real_x*sizeof(jmi_real_t));
            
            jmi_log_node(jmi->log, logWarning, "Warning",
                "Evaluating the derivatives failed at <t:%g>, retrying with restored values.", jmi_get_t(jmi)[0]);
            /* If it failed, reset to the previous succesful values */
            jmi_reset_last_successful_values(jmi);
            
            /* Restore the current time and states */
            memcpy (jmi_get_real_x(jmi), x, jmi->n_real_x*sizeof(jmi_real_t));
            *(jmi_get_t(jmi)) = time;
            jmi->jmi_callbacks.free_memory(x);
            
            /* Try again */
            retval = jmi_ode_derivatives(jmi);
            if(retval != 0) {
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    jmi_log_leave(jmi->log, node);
                }
                jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed at <t:%g>", jmi_get_t(jmi)[0]);
                /* If it failed, reset to the previous succesful values */
                jmi_reset_last_successful_values(jmi);
            
                return -1;
            }
        }
        jmi->recomputeVariables = 0;
    }

    memcpy (derivatives, jmi_get_real_dx(jmi), nx*sizeof(jmi_real_t));
    
    /* Verify that output is free from NANs */
    {
        int index_of_nan = 0;
        retval = jmi_check_nan(jmi, derivatives, nx, &index_of_nan);
        if (retval != 0) {
            jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed at <t:%g>. Produced NaN in <index:%I>", jmi_get_t(jmi)[0], index_of_nan);
            return -1;
        }
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_leave(jmi->log, node);
    }
    
    return 0;
}

int jmi_set_time(jmi_t* jmi, jmi_real_t time) {
    jmi_real_t* time_old = (jmi_get_t(jmi));

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set time when the model is terminated");
        return -1;
    }

    if (*time_old != time) {
        *time_old = time;
        jmi->recomputeVariables = 1;
    }

    return 0;
}

int jmi_set_continuous_states(jmi_t* jmi, const jmi_real_t x[], size_t nx) {
    jmi_real_t* x_cur = jmi_get_real_x(jmi);
    size_t i;
    
    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set continuous states when the model is terminated");
        return -1;
    }

    for (i = 0; i < nx; i++){
        if (x_cur[i] != x[i]){
            x_cur[i] = x[i];
            jmi->recomputeVariables = 1;
        }
    }
    return 0;
}

int jmi_completed_integrator_step(jmi_t* jmi, jmi_real_t* triggered_event) {
    int retval = 0;
    jmi_log_node_t node;
    *triggered_event = JMI_FALSE;
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node = jmi_log_enter_fmt(jmi->log, logInfo, "CompletedIntegratorStep", 
                                "Completed integrator step was called at <t:%g> indicating a successful step.", jmi_get_t(jmi)[0]);
    }
    
    /* Sample delay blocks */
    jmi_delay_set_event_mode(jmi, JMI_FALSE);
    retval = jmi_sample_delay_blocks(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Delay sampling after completed integrator step failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, node);
        }
        return -1;
    }
    
    /* Save the z values to the z_last vector */
    jmi_save_last_successful_values(jmi);
    /* Block completed step */
    /* jmi_block_completed_integrator_step(jmi); */
    
    /* Verify the choice of dynamic states */
    retval = jmi_dynamic_state_verify_choice(jmi);
    if (retval == JMI_UPDATE_STATES) { /*Bad choice, needs to be updated */
        *triggered_event = JMI_TRUE;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_leave(jmi->log, node);
    }

    
    return 0;
}

int jmi_get_event_indicators(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni) {
    int retval;
    jmi_log_node_t node;
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetEventIndicators", 
                                "Call to get event indicators at <t:%g>.", jmi_get_t(jmi)[0]);
    }
    
    if (jmi->recomputeVariables == 1 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            
            /* Store the current time and states */
            jmi_real_t time = *(jmi_get_t(jmi));
            jmi_real_t *x = (jmi_real_t*)jmi->jmi_callbacks.allocate_memory(jmi->n_real_x, sizeof(jmi_real_t));
            memcpy(x, jmi_get_real_x(jmi), jmi->n_real_x*sizeof(jmi_real_t));
            
            jmi_log_node(jmi->log, logWarning, "Warning",
                "Evaluating the derivatives failed while evaluating the event indicators at <t:%g>, retrying with restored values.", jmi_get_t(jmi)[0]);
            /* If it failed, reset to the previous succesful values */
            jmi_reset_last_successful_values(jmi);
            
            /* Restore the current time and states */
            memcpy (jmi_get_real_x(jmi), x, jmi->n_real_x*sizeof(jmi_real_t));
            *(jmi_get_t(jmi)) = time;
            jmi->jmi_callbacks.free_memory(x);
            
            /* Try again */
            retval = jmi_ode_derivatives(jmi);
            if(retval != 0) {
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    jmi_log_leave(jmi->log, node);
                }
                jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed while evaluating the event indicators at <t:%g>", jmi_get_t(jmi)[0]);
                /* If it failed, reset to the previous succesful values */
                jmi_reset_last_successful_values(jmi);
            
                return -1;
            }
        }
        jmi->recomputeVariables = 0;
    }

    retval = jmi_dae_R_perturbed(jmi,eventIndicators);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Evaluating the event indicators failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, node);
        }
        return -1;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_reals(jmi->log, node, logInfo, "Event Indicators", eventIndicators, ni);
        jmi_log_leave(jmi->log, node);
    }
    
    return 0;
}

int jmi_get_nominal_continuous_states(jmi_t* jmi, jmi_real_t x_nominal[], size_t nx) {
    if (nx != jmi->n_real_x) {
        jmi_log_node(jmi->log, logError, "Error",
            "Wrong size of array when getting nominal values: size is <given_nx:%d>, should be <actual_nx:%d>", nx, jmi->n_real_x);
        return 1;
    }
    
    memcpy(x_nominal, jmi->nominals, nx * sizeof(jmi_real_t));
    return 0;
}

int jmi_event_iteration(jmi_t* jmi, jmi_boolean intermediate_results,
                        jmi_event_info_t* event_info) {
                            
    jmi_int_t retval;
    jmi_int_t i, max_iterations;
    jmi_real_t* z = jmi_get_z(jmi);
    jmi_real_t* switches;
    jmi_log_node_t top_node;
    jmi_log_node_t iter_node;
    jmi_log_node_t discrete_node;

    /* Used for logging */
    switches = jmi_get_sw(jmi);
    
    jmi->model_terminate = 0;  /* Reset terminate flag. */
    max_iterations = 30;       /* Maximum number of event iterations */

    /* Performed at the fist event iteration: */
    if (jmi->nbr_event_iter == 0) {

        /* Reset eventInfo */
        event_info->next_event_time_defined = FALSE;         /* The next event time is not set. */
        event_info->next_event_time = 0.0;                   /* A reset. */
        event_info->state_value_references_changed = FALSE;  /* No support for dynamic state selection */
        event_info->terminate_simulation = FALSE;            /* Don't terminate the simulation unless flagged to. */
        event_info->iteration_converged = FALSE;             /* The iteration has not converged */
        event_info->nominals_of_states_changed = FALSE;      /* Not used, get_nominals is not implemented. */
        event_info->state_values_changed = FALSE;            /* State variables have not been changed by reinit. */

        top_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalEventIterations", 
                                 "Starting global event iteration at <t:%E>", jmi_get_t(jmi)[0]);
        
        if (jmi->n_sw > 0) {
            jmi_log_reals(jmi->log, top_node, logInfo, "pre-switches", switches, jmi->n_sw);
        }

        /* Initial evaluation of model so that we enter the event iteration with correct values. */
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Initial evaluation of the model equations during event iteration failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        /* We are at an event -> set atEvent to true. */
        jmi->atEvent = JMI_TRUE;
        /* We are at an time event -> set atTimeEvent to true. */
        if (jmi->nextTimeEvent.defined) {
            jmi->atTimeEvent = ALMOST_ZERO(jmi_get_t(jmi)[0]-jmi->nextTimeEvent.time);
            jmi->eventPhase = jmi->nextTimeEvent.phase;
        }else{
            jmi->atTimeEvent = JMI_FALSE;
            jmi->eventPhase = JMI_TIME_GREATER;
        }
        
    } else if (intermediate_results) {
        top_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalEventIterations", 
                                 "Continuing global event iteration at <t:%E>", jmi_get_t(jmi)[0]);
    }

    /* Iterate */
    while (event_info->iteration_converged == FALSE) {
        jmi->reinit_triggered = 0; /* Reset reinit flag. */
        
        jmi->nbr_event_iter += 1;
        
        iter_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalIteration", 
                                      "Global iteration <iter:%I>, at <t:%E>", jmi->nbr_event_iter, jmi_get_t(jmi)[0]);
        
        /* Copy current values to pre values */
        jmi_copy_pre_values(jmi);

        /* Evaluate the ODE */
        retval = jmi_ode_derivatives(jmi);
        
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluation of model equations during event iteration failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }
        
        /* Compare current values with the pre values. If there is an element that differs, set
         * event_info->iteration_converged to false. */
        event_info->iteration_converged = TRUE; /* Assume the iteration converged */
        
        /* Log updates, NOTE this should in the future also contain which expressions changed! */
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            discrete_node =jmi_log_enter_fmt(jmi->log, logInfo, "GlobalUpdateOfDiscreteVariables", 
                                "Global updating of discrete variables");
        }
        
        for (i = jmi->offs_real_d; i < jmi->offs_pre_real_dx; i++) {
            if (z[i - jmi->offs_real_d + jmi->offs_pre_real_d] != z[i]) {
                event_info->iteration_converged = FALSE;
                
                /* Extra logging of the discrete variables that has been changed) */
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    if (i < jmi->offs_boolean_d) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <integer: #i%d#> <from: %d> <to: %d>", jmi_get_value_ref_from_index(i, JMI_INTEGER), (jmi_int_t)z[i - jmi->offs_real_d + jmi->offs_pre_real_d], (jmi_int_t)z[i]);
                    } else if (i < jmi->offs_sw) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <boolean: #b%d#> <from: %d> <to: %d>", jmi_get_value_ref_from_index(i, JMI_BOOLEAN), (jmi_int_t)z[i - jmi->offs_real_d + jmi->offs_pre_real_d], (jmi_int_t)z[i]);
                    } else if (i < jmi->offs_guards) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <switch: %I> <from: %d> <to: %d>", i-jmi->offs_sw, (jmi_int_t)z[i - jmi->offs_real_d + jmi->offs_pre_real_d], (jmi_int_t)z[i]);
                    }
                }
            }
        }
        
        /* Close the log node for the discrete variables update */
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, discrete_node);
        }

        if (jmi->jmi_callbacks.log_options.log_level >= 5) {
            jmi_log_reals(jmi->log, iter_node, logInfo, "z_values", &z[jmi->offs_real_d], jmi->offs_pre_real_dx-jmi->offs_real_d);
            jmi_log_reals(jmi->log, iter_node, logInfo, "pre(z)_values", &z[jmi->offs_pre_real_d], jmi->offs_pre_real_dx-jmi->offs_real_d);
        }
        
        /* Check if a reinit triggered - this would mean that state variables changed. */
        if (jmi->reinit_triggered) {
            event_info->iteration_converged = FALSE;
            event_info->state_values_changed = TRUE;
        }
        
        /* No convergence under the allowed number of iterations. */
        if (jmi->nbr_event_iter >= max_iterations) {
            jmi_log_node(jmi->log, logError, "Error", "Failed to converge during global fixed point "
                         "iteration due to too many iterations at <t:%E>",jmi_get_t(jmi)[0]);
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        jmi_log_leave(jmi->log, iter_node);

        if (intermediate_results) {
            break;
        }
    }
    
    /* Only do the final steps if the event iteration is done. */
    if (event_info->iteration_converged == TRUE) {
        jmi_log_node_t final_node = jmi_log_enter(jmi->log, logInfo, "final_step");

        /* Reset the number of event iterations */
        jmi->nbr_event_iter = 0;

        /* If the event epsilon is 0 due to initialization of the system, reset it */
        if (jmi->events_epsilon == 0.0) {
            jmi->events_epsilon = jmi->tmp_events_epsilon;
        }

        /* Reset atEvent flag */
        jmi->atEvent = JMI_FALSE;

        /* Evaluate the guards with the event flag set to false in order to
         * reset guards depending on samplers before copying pre values.
         * If this is not done, then the corresponding pre values for these guards
         * will be true, and no event will be triggered at the next sample.
         */
        retval = jmi_ode_guards(jmi);

        if (retval != 0) { /* Error check */
            jmi_log_comment(jmi->log, logError, "Computation of guard expressions failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        /* Final evaluation of the model with event flag set to false. It can
         * for example change values of booleans that should only be true during
         * events due to a sample function.
        */
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Final evaluation of the model equations during event iteration failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }
        jmi->recomputeVariables = 0; /* The variables are computed. End of event iteration. */
        
        /* Sample delay blocks */
        jmi_delay_set_event_mode(jmi, JMI_TRUE);
        retval = jmi_sample_delay_blocks(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Delay sampling after event iteration failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }
        
        /* Compute the next time event */
        retval = jmi_next_time_event(jmi);
        if(retval != 0) { /* Error check */
            jmi_log_comment(jmi->log, logError, "Computation of next time event failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }
        
        /* If there is an upcoming time event, then set the event information
         * accordingly.
         */
        if (jmi->nextTimeEvent.defined) {
            event_info->next_event_time_defined = TRUE;
            event_info->next_event_time = jmi->nextTimeEvent.time;
            /*printf("fmi_event_upate: nextTimeEvent: %f\n",nextTimeEvent); */
        } else {
            event_info->next_event_time_defined = FALSE;
        }
        
        /* Save the z values to the z_last vector */
        jmi_save_last_successful_values(jmi);
        /* Block completed step */
        /* jmi_block_completed_integrator_step(jmi); */
        
        jmi_log_leave(jmi->log, final_node);

        if (jmi->n_sw > 0) {
            jmi_log_reals(jmi->log, top_node, logInfo, "post-switches", switches, jmi->n_sw);
        }
        jmi_log_leave(jmi->log, top_node);

    } else if (intermediate_results) {
        jmi_log_leave(jmi->log, top_node);
    }

    /* If everything went well, check if termination of simulation was requested. */
    event_info->terminate_simulation = jmi->model_terminate ? TRUE : FALSE;
    
    if (jmi->model_terminate == FALSE && jmi->atTimeEvent && 
        jmi->eventPhase == JMI_TIME_EXACT && jmi->nextTimeEvent.defined 
        && ALMOST_ZERO(jmi_get_t(jmi)[0]-jmi->nextTimeEvent.time) &&
        event_info->iteration_converged == TRUE) {
        return jmi_event_iteration(jmi, intermediate_results, event_info);
    }
    
    if (jmi->updated_states == JMI_TRUE) {
        event_info->state_values_changed = TRUE;
        jmi->updated_states = JMI_FALSE;
    }
    
    return 0;
}

int jmi_next_time_event(jmi_t* jmi) {
    int retval;
    
    retval = jmi_ode_next_time_event(jmi, &jmi->nextTimeEvent);
    if(retval != 0) {
        return -1;
    }
    
    /* See if the delay blocks need to update the next event time. Need to do this after sampling them,
       if the next event is caused by a delay of the current one. */
    {
        jmi_real_t t_delay = jmi_delay_next_time_event(jmi);
        if (t_delay != JMI_INF) {
            jmi_min_time_event(&jmi->nextTimeEvent, 1, 0, t_delay);
        }
    }
    
    return 0;
}

int jmi_update_and_terminate(jmi_t* jmi) {
    int retval;

    if (jmi->recomputeVariables == 1) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }

    jmi_destruct_external_objs(jmi);
    jmi->user_terminate = 1;

    return 0;
}

int compare_option_names(const void* a, const void* b) {
    const char** sa = (const char**)a;
    const char** sb = (const char**)b;
    return strcmp(*sa, *sb);
}

static int get_option_index(char* option) {
    const char** found=(const char**)bsearch(&option, 
                                             fmi_runtime_options_map_names,
                                             fmi_runtime_options_map_length,
                                             sizeof(char*),
                                             compare_option_names);
    int vr, index;
    if(!found) return 0;
    index = (int)(found - &fmi_runtime_options_map_names[0]);
    if(index >= fmi_runtime_options_map_length ) return 0;
    vr = fmi_runtime_options_map_vrefs[index];
    return get_index_from_value_ref(vr);
}

/**
 * Update run-time options specified by the user.
 */
void jmi_update_runtime_options(jmi_t* jmi) {
    jmi_real_t* z = jmi_get_z(jmi);
    int index;
    jmi_options_t* op = &jmi->options;
    jmi_block_solver_options_t* bsop = &op->block_solver_options;
    index = get_option_index("_log_level");
    if(index) {
        op->log_options->log_level = (int)z[index];
    }
    index = get_option_index("_enforce_bounds");
    if(index)
        op->block_solver_options.enforce_bounds_flag = (int)z[index]; 
    
    index = get_option_index("_use_jacobian_equilibration");
    if(index ){
        bsop->use_jacobian_equilibration_flag = (int)z[index]; 
    }
    
    index = get_option_index("_residual_equation_scaling");
    if(index) {
        int fl = (int)z[index];
        switch(fl) {
        case jmi_residual_scaling_none:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_none;
            break;
        case jmi_residual_scaling_manual:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_manual;
            break;
        case jmi_residual_scaling_hybrid:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_hybrid;
            break;
        default:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_auto;
        }
    }  
        
    index = get_option_index("_nle_solver_min_residual_scaling_factor");
    if(index)
        bsop->min_residual_scaling_factor = z[index];
    
    index = get_option_index("_nle_solver_max_residual_scaling_factor");
    if(index)
        bsop->max_residual_scaling_factor = z[index];

    index = get_option_index("_nle_solver_max_iter");
    if(index)
        bsop->max_iter = (int)z[index];
    index = get_option_index("_block_solver_experimental_mode");
    if(index)
        bsop->experimental_mode  = (int)z[index];
    
    index = get_option_index("_iteration_variable_scaling");
    if(index) {
        switch((int)z[index]) {
        case jmi_iter_var_scaling_none:
            bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_none;
            break;
        case jmi_iter_var_scaling_heuristics:
            bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_heuristics;
            break;
        default:
            bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_nominal;
        }
    }
    index = get_option_index("_rescale_each_step");
    if(index)
        bsop->rescale_each_step_flag = (int)z[index]; 
    index = get_option_index("_rescale_after_singular_jac");
    if(index)
        bsop->rescale_after_singular_jac_flag = (int)z[index]; 
    index = get_option_index("_use_Brent_in_1d");
    if(index)
        bsop->use_Brent_in_1d_flag = (int)z[index]; 
    index = get_option_index("_nle_solver_default_tol");
    if(index)
        op->nle_solver_default_tol = z[index]; 
    index = get_option_index("_nle_solver_check_jac_cond");
    if(index)
        bsop->check_jac_cond_flag = (int)z[index]; 
    index = get_option_index("_nle_solver_step_limit_factor");
    if(index)
        bsop->step_limit_factor = z[index];
    index = get_option_index("_nle_solver_min_tol");
    if(index)
        bsop->min_tol = z[index];
    index = get_option_index("_nle_solver_regularization_tolerance");
    if(index)
        bsop->regularization_tolerance = z[index];
    index = get_option_index("_nle_solver_tol_factor");
    if(index)
        op->nle_solver_tol_factor = z[index]; 
    index = get_option_index("_events_default_tol");
    if(index)
        op->events_default_tol = z[index]; 
    index = get_option_index("_events_tol_factor");
    if(index)
        op->events_tol_factor = z[index];
    index = get_option_index("_block_jacobian_check");
    if(index)
         bsop->block_jacobian_check = z[index]; 
    index = get_option_index("_block_jacobian_check_tol");
    if(index)
         bsop->block_jacobian_check_tol = z[index];
    index = get_option_index("_cs_solver");
    if(index)
        op->cs_solver = z[index];
    index = get_option_index("_cs_rel_tol");
    if(index)
        op->cs_rel_tol = z[index];
    index = get_option_index("_cs_step_size");
    if(index)
        op->cs_step_size = z[index]; 
    index = get_option_index("_runtime_log_to_file");
    if(index)
        op->log_options->copy_log_to_file_flag = (int)z[index]; 
    
    bsop->res_tol = jmi->newton_tolerance;
    bsop->events_epsilon = jmi->events_epsilon;
/*    op->block_solver_experimental_mode = 
            jmi_block_solver_experimental_steepest_descent_first;
   op->log_level = 5; */
}
