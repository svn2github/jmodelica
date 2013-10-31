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
#include "jmi.h"
#include "jmi_util.h"
#include "jmi_log.h"

#define indexmask 0x0FFFFFFF
#define typemask 0xF0000000

jmi_value_reference get_index_from_value_ref(jmi_value_reference valueref) { //TODO: should be static later on if possible
    /* Translate a ValueReference into variable index in z-vector. */
    jmi_value_reference index = valueref & indexmask;
    
    return index;
}

jmi_value_reference get_type_from_value_ref(jmi_value_reference valueref) { //TODO: should be static later on if possible
    /* Translate a ValueReference into variable type in z-vector. */
    jmi_value_reference type = valueref & typemask;
    
    return type;
}

int jmi_set_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_real_t value[]) {
    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_real_pd && index < jmi->offs_integer_ci) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Real dependent parameter <variable: #r%d#>", vr[i]);
            return -1;
        }

        if (index >= jmi->offs_real_ci && index < jmi->offs_real_pi) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Real constant <variable: #r%d#>", vr[i]);
            return -1;
        }
    }
    
    jmi->recomputeVariables = 1;
    z = jmi_get_z(jmi);
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);

        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < jmi->offs_real_dx) {
            jmi_init_eval_parameters(jmi);
        }
    }
    return 0;
}

int jmi_set_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_int_t value[]) {
    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_integer_pd && index < jmi->offs_boolean_ci) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Integer dependent parameter <variable: #i%d#>", vr[i]);
            return -1;
        }

        if (index >= jmi->offs_integer_ci && index < jmi->offs_integer_pi) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Integer constant <variable: #i%d#>", vr[i]);
            return -1;
        }
    }

    jmi->recomputeVariables = 1;
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < jmi->offs_real_dx) {
            jmi_init_eval_parameters(jmi);
        }
    }
    return 0;
}

int jmi_set_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_boolean value[]) {
    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if (index >= jmi->offs_boolean_pd && index < jmi->offs_real_dx) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Boolean dependent parameter <variable: #b%d#>", vr[i]);
            return -1;
        }

        if (index >= jmi->offs_boolean_ci && index < jmi->offs_boolean_pi) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Boolean constant <variable: #b%d#>", vr[i]);
            return -1;
        }
    }

    jmi->recomputeVariables = 1;
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < jmi->offs_real_dx) {
            jmi_init_eval_parameters(jmi);
        }

    }
    return 0;
}

int jmi_set_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_string value[]) {
    jmi->recomputeVariables = 1;
    jmi_log_comment(jmi->log, logWarning, "Strings are not yet supported.");
    return 0;
}

int jmi_get_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_real_t value[]) {
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

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0) {
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

int jmi_get_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_int_t value[]) {
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

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0) {
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

int jmi_get_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_boolean value[]) {
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

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0) {
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

int jmi_get_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_string  value[]) {
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

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && isParameterOrConstant == 0) {
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
    
    jmi_real_t** dz = jmi->dz;
    jmi_real_t** dv = jmi->dz;
    int i;
    for (i = 0; i < jmi->n_v; i++) {
        (*dv)[i] = 0.;
    }
    
    for (i = 0;i < nKnown; i++) {
        (*dv)[get_index_from_value_ref(vKnown_ref[i])] = dvKnown[i];
    }
    
    jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);
    for (i = 0; i < nUnknown; i++) {
        dvUnknown[i] = (*dz)[get_index_from_value_ref(vUnknown_ref[i])];
    }
    
    return 0;
}

int jmi_get_derivatives(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx) {
    int retval;
    
    if (jmi->recomputeVariables == 1) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_node(jmi->log, logError, "Error",
                "Evaluating the derivatives failed at <t:%g>", jmi_get_t(jmi)[0]);
            return -1;
        }
        jmi->recomputeVariables = 0;
    }
    memcpy (derivatives, jmi_get_real_dx(jmi), nx*sizeof(jmi_real_t));
    
    return 0;
}

int jmi_get_event_indicators(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni) {
    jmi_value_reference i;
    int retval;

    if (jmi->recomputeVariables == 1) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }
    retval = jmi_dae_R_perturbed(jmi,eventIndicators);
    
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Evaluating the event indicators failed.");
        return -1;
    }
    return 0;
}

//TODO: is not implemented.
int jmi_get_nominal_continuous_states(jmi_t* jmi, jmi_real_t x_nominal[], size_t nx) {
    int i;
    
    for(i = 0; i < nx; i++) {
        x_nominal[i] = 1.0;
    }
    
    return 0;
}

int jmi_event_iteration(jmi_t* jmi, jmi_boolean intermediate_results,
                        jmi_event_info_t* event_info) {
                            
    jmi_int_t nGuards;
    jmi_int_t nF;
    jmi_int_t nR;
    jmi_int_t retval;
    jmi_int_t i, iter, max_iterations;
    jmi_real_t next_event_time;
    jmi_real_t* z = jmi_get_z(jmi);
    jmi_real_t* event_indicators;
    jmi_real_t* switches;
    jmi_real_t* sw_temp;
    jmi_log_node_t top_node;

    /* Allocate memory */
    nGuards = jmi->n_guards;
    jmi_dae_get_sizes(jmi, &nF, &nR);
    event_indicators = jmi->jmi_callbacks->allocate_memory(nR, sizeof(jmi_real_t));
    sw_temp = jmi->jmi_callbacks->allocate_memory(nR, sizeof(jmi_real_t));
    switches = jmi_get_sw(jmi); /* Get the switches */

    /* Reset eventInfo */
    event_info->next_event_time_defined = FALSE;         /* The next event time is not set. */
    event_info->next_event_time = 0.0;                   /* A reset. */
    event_info->state_value_references_changed = FALSE;  /* No support for dynamic state selection */
    event_info->terminate_simulation = FALSE;            /* Don't terminate the simulation */
    event_info->iteration_converged = FALSE;             /* The iteration have not converged */
    event_info->nominals_of_states_changed = FALSE;      /* Not used, get_nominals is not implemented. */
    event_info->state_values_changed = FALSE;            /* Not used, the reinit operator is not supported. */
    
    jmi->terminate = 0; /* Reset terminate flag. */

    max_iterations = 30; /* Maximum number of event iterations */

    retval = jmi_ode_derivatives(jmi);

    top_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalEventIterations", 
                                 "Starting global event iteration at <t:%E>", jmi_get_t(jmi)[0]);

    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Initial evaluation of the model equations during event iteration failed.");
        jmi_log_unwind(jmi->log, top_node);
        return -1;
    }

    /* Copy all pre values */
    jmi_copy_pre_values(jmi);

    /* We are at an event -> set atEvent to true. */
    jmi->atEvent = JMI_TRUE;

    /* Iterate */
    iter = 0;
    while (event_info->iteration_converged == FALSE) {
        jmi_log_node_t iter_node;

        iter += 1;
        
        iter_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalIteration", 
                                      "Global iteration <iter:%d>, at <t:%E>", iter, jmi_get_t(jmi)[0]);
        
        /* Evaluate and turn the switches */
        retval = jmi_evaluate_switches(jmi,switches,1);

        /* Evaluate the ODE again */
        retval = jmi_ode_derivatives(jmi);

        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluation of model equations during event iteration failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        /* Compare new values with values
         * with the pre values. If there is an element that differs, set
         * eventInfo->iterationConverged to false
         */
        event_info->iteration_converged = TRUE; /* Assume the iteration converged */

        /* Start with continuous variables - they could change due to
         * the reinit operator. */

        /*
        for (i = jmi->offs_real_dx; i < jmi->offs_t; i++) {
            if (jmi->z[i - jmi->offs_real_dx + jmi->offs_pre_real_dx] != jmi->z[i]) {
                event_info->iteration_converged = FALSE;
                event_info->state_values_changed = TRUE;
            }
        }
         */

        for (i = jmi->offs_real_d; i < jmi->offs_pre_real_dx; i++) {
            if (z[i - jmi->offs_real_d + jmi->offs_pre_real_d] != z[i]) {
                event_info->iteration_converged = FALSE;
            }
        }
        
        /* Evaluate the switches */
        memcpy(sw_temp, switches, nR*sizeof(jmi_real_t));
        retval = jmi_evaluate_switches(jmi, sw_temp, 1);
        
        if (jmi_compare_switches(switches,sw_temp,nR) == 0){
            event_info->iteration_converged = FALSE;
        }

        /* Copy new values to pre values */
        jmi_copy_pre_values(jmi);

        if (intermediate_results) {
            break;
        }
        
        /* No convergence under the allowed number of iterations. */
        if (iter >= max_iterations) {
            jmi_log_node(jmi->log, logError, "Error", "Failed to converge during global fixed point "
                         "iteration due to too many iterations at <t:%E>",jmi_get_t(jmi)[0]);
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        jmi_log_leave(jmi->log, iter_node);
    }

    /* Only do the final steps if the event iteration is done. */
    if (event_info->iteration_converged == TRUE) {
        jmi_log_node_t final_node = jmi_log_enter(jmi->log, logInfo, "final_step");

        /* Compute the next time event */
        retval = jmi_ode_next_time_event(jmi,&next_event_time);

        if(retval != 0) { /* Error check */
            jmi_log_comment(jmi->log, logError, "Computation of next time event failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        /* If there is an upcoming time event, then set the event information
         * accordingly.
         */
        if (!(next_event_time == JMI_INF)) {
            event_info->next_event_time_defined = TRUE;
            event_info->next_event_time = next_event_time;
            /*printf("fmi_event_upate: nextTimeEvent: %f\n",nextTimeEvent); */
        } else {
            event_info->next_event_time_defined = FALSE;
        }

        /* Reset atEvent flag */
        jmi->atEvent = JMI_FALSE;

        /* Evaluate the guards with the event flat set to false in order to
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

        jmi_log_leave(jmi->log, final_node);
    }

	/* If everything went well, check if termination of simulation was requested. */
	event_info->terminate_simulation = jmi->terminate ? TRUE : FALSE;

    jmi->jmi_callbacks->free_memory(event_indicators);
    jmi->jmi_callbacks->free_memory(sw_temp);

    jmi_log_leave(jmi->log, top_node);

    return 0;
}









/*
fmiStatus fmi2_enter_event_mode(fmiComponent c) {
    return 0;
}

fmiStatus fmi2_new_discrete_state(fmiComponent  c,
                                  fmiEventInfo* fmiEventInfo) {
    return 0;
}

fmiStatus fmi2_enter_continuous_time_mode(fmiComponent c) {
    return 0;
}

fmiStatus fmi2_completed_integrator_step(fmiComponent c,
                                         fmiBoolean   noSetFMUStatePriorToCurrentPoint, 
                                         fmiBoolean*  enterEventMode, 
                                         fmiBoolean*   terminateSimulation) {
    return 0;
}

fmiStatus fmi2_set_time(fmiComponent c, fmiReal time) {
    return 0;
}

fmiStatus fmi2_set_continuous_states(fmiComponent c, const fmiReal x[],
                                     size_t nx) {
    return 0;
}

fmiStatus fmi2_get_derivatives(fmiComponent c, fmiReal derivatives[], size_t nx) {
    return 0;
}

fmiStatus fmi2_get_event_indicators(fmiComponent c, 
                                    fmiReal eventIndicators[], size_t ni) {
    return 0;
}

fmiStatus fmi2_get_continuous_states(fmiComponent c, fmiReal x[], size_t nx) {
    return 0;
}

fmiStatus fmi2_get_nominals_of_continuous_states(fmiComponent c, 
                                                 fmiReal x_nominal[], 
                                                 size_t nx) {
    return 0;
}
*/
