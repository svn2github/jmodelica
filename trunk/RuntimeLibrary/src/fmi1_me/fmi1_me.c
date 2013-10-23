/*
    Copyright (C) 2009 Modelon AB

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

#include <stdio.h>
#include <string.h>
#include <time.h>

#include "fmi1_me.h"
#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_log.h"

#ifdef USE_FMI_ALLOC
#include "fmi_alloc.h"
#endif

#define indexmask 0x0FFFFFFF
#define typemask 0xF0000000

static fmiValueReference get_index_from_value_ref(fmiValueReference valueref) {
    /* Translate a ValueReference into variable index in z-vector. */
    fmiValueReference index = valueref & indexmask;
    
    return index;
}

static fmiValueReference get_type_from_value_ref(fmiValueReference valueref) {
    /* Translate a ValueReference into variable type in z-vector. */
    fmiValueReference type = valueref & typemask;
    
    return type;
}

/* Inquire version numbers of header files */
const char* fmi1_me_get_model_types_platform() {
    return fmiModelTypesPlatform;
}
const char* fmi1_me_get_version() {
    return fmiVersion;
}

/* Creation and destruction of model instances and setting debug status */

fmiComponent fmi1_me_instantiate_model(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn) {

    fmi1_me_t *component;
    char* tmpname;
    char* tmpguid;
    size_t inst_name_len;
    size_t guid_len;

    /* Create jmi struct -> No need  since jmi_init allocates it
     jmi_t* jmi = (jmi_t *)functions.allocateMemory(1, sizeof(jmi_t)); */
    jmi_t* jmi = 0;
    jmi_callbacks_t* jmi_callbacks = 0;
    fmiInteger retval;

    if(!functions.allocateMemory || !functions.freeMemory || !functions.logger) {
         if(functions.logger) {
             /* We have to use the raw logger callback here; the logger in the jmi_t struct is not yet initialized. */
             functions.logger(0, instanceName, fmiError, "ERROR", "Memory management functions allocateMemory/freeMemory are required.");
         }
         return 0;
    }
    
    component = (fmi1_me_t *)functions.allocateMemory(1, sizeof(fmi1_me_t));
    component->fmi_functions = functions;
    
    jmi_callbacks = (jmi_callbacks_t*)calloc(1,sizeof(jmi_callbacks_t));
    jmi_callbacks->fmix_me = component;
    jmi_callbacks->fmi_name = instanceName;
    jmi_callbacks->logging_on = loggingOn;
    jmi_callbacks->logger = (loggerCallabackFunction)functions.logger;
    jmi_callbacks->allocate_memory = (globalAllocateMemory)functions.allocateMemory;
    
#ifdef USE_FMI_ALLOC
    /* Set the global user functions pointer so that memory allocation functions are intercepted */
    fmiFunctions = &(component -> fmi_functions);
#endif

    retval = jmi_new(&jmi, jmi_callbacks);
    if(retval != 0) {
        /* creating jmi struct failed */
        functions.freeMemory(component);
        return NULL;
    }

    inst_name_len = strlen(instanceName)+1;
    tmpname = (char*)(fmi1_me_t *)functions.allocateMemory(inst_name_len, sizeof(char));
    strncpy(tmpname, instanceName, inst_name_len);
    component -> fmi_instance_name = tmpname;

    guid_len = strlen(GUID)+1;
    tmpguid = (char*)(fmi1_me_t *)functions.allocateMemory(guid_len, sizeof(char));
    strncpy(tmpguid, GUID, guid_len);
    component -> fmi_GUID = tmpguid;
    
    component -> fmi_functions = functions;
    component -> jmi = jmi;
    
    /* set start values*/
    if (jmi_generic_func(component->jmi, jmi_set_start_values) != 0)
    	return NULL;
    
    /* Print some info about Jacobians, if available. */
    if (jmi->color_info_A != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "color_info_A");
        jmi_log_fmt(jmi->log, node, logInfo, "<num_nonzeros: %d> in Jacobian A", jmi->color_info_A->n_nz);
        jmi_log_fmt(jmi->log, node, logInfo, "<num_colors: %d> in Jacobian A", jmi->color_info_A->n_groups);
        jmi_log_leave(jmi->log, node);
    }

    if (jmi->color_info_B != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "color_info_B");
        jmi_log_fmt(jmi->log, node, logInfo, "<num_nonzeros: %d> in Jacobian B", jmi->color_info_B->n_nz);
        jmi_log_fmt(jmi->log, node, logInfo, "<num_colors: %d> in Jacobian B", jmi->color_info_B->n_groups);
        jmi_log_leave(jmi->log, node);
    }

    if (jmi->color_info_C != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "color_info_C");
        jmi_log_fmt(jmi->log, node, logInfo, "<num_nonzeros: %d> in Jacobian C", jmi->color_info_C->n_nz);
        jmi_log_fmt(jmi->log, node, logInfo, "<num_colors: %d> in Jacobian C", jmi->color_info_C->n_groups);
        jmi_log_leave(jmi->log, node);
    }

    if (jmi->color_info_D != NULL) {
        jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "color_info_D");
        jmi_log_fmt(jmi->log, node, logInfo, "<num_nonzeros: %d> in Jacobian D", jmi->color_info_D->n_nz);
        jmi_log_fmt(jmi->log, node, logInfo, "<num_colors: %d> in Jacobian D", jmi->color_info_D->n_groups);
        jmi_log_leave(jmi->log, node);
    }

    return (fmiComponent)component;
}

void fmi1_me_free_model_instance(fmiComponent c) {
    /* Dispose the given model instance and deallocated all the allocated memory and other resources 
     * that have been allocated by the functions of the Model Exchange Interface for instance "c".*/
    if (c) {
        fmi1_me_t* component = (fmi1_me_t*)c;
        fmiCallbackFreeMemory fmi_free = component -> fmi_functions.freeMemory;

        jmi_delete(component->jmi);
        component->jmi = 0;
        fmi_free((void*)component -> fmi_instance_name);
        fmi_free((void*)component -> fmi_GUID);
        fmi_free(component);
    }
}

fmiStatus fmi1_me_set_debug_logging(fmiComponent c, fmiBoolean loggingOn) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    ((fmi1_me_t*)c) -> jmi -> log -> jmi_callbacks -> logging_on = loggingOn;
    return fmiOK;
}

/* Providing independent variables and re-initialization of caching */

fmiStatus fmi1_me_set_time(fmiComponent c, fmiReal time) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    *(jmi_get_t(((fmi1_me_t *)c)->jmi)) = time;
    ((fmi1_me_t *)c)->jmi->recomputeVariables = 1;
    return fmiOK;
}

fmiStatus fmi1_me_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (jmi_get_real_x(((fmi1_me_t *)c)->jmi), x, nx*sizeof(fmiReal));
    ((fmi1_me_t *)c)->jmi->recomputeVariables = 1;
    return fmiOK;
}

fmiStatus fmi1_me_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    *callEventUpdate = fmiFalse;
    return fmiOK;
}

fmiStatus fmi1_me_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    /* Get the z vector*/
    fmiValueReference i;
    fmiValueReference index;
    jmi_real_t* z;
    
    if (c == NULL) {
		return fmiFatal;
    }

    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_real_pd && index<((fmi1_me_t *)c)->jmi->offs_integer_ci) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "CannotSetVariable",
                         "Cannot set Real dependent parameter <variable: #r%d#>", vr[i]);
            return fmiError;
        }

        if (index>=((fmi1_me_t *)c)->jmi->offs_real_ci && index<((fmi1_me_t *)c)->jmi->offs_real_pi) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "CannotSetVariable",
                         "Cannot set Real constant <variable: #r%d#>", vr[i]);
            return fmiError;
        }

    }

    ((fmi1_me_t *)c)->jmi->recomputeVariables = 1;
    z = jmi_get_z(((fmi1_me_t *)c)->jmi);
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);

        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < (((fmi1_me_t *)c)->jmi)->offs_real_dx) {
            jmi_init_eval_parameters(((fmi1_me_t *)c)->jmi);
        }

    }
    return fmiOK;
}

fmiStatus fmi1_me_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
    /* Get the z vector*/
    fmiValueReference i;
    fmiValueReference index;
    jmi_real_t* z;
    
    if (c == NULL) {
		return fmiFatal;
    }

    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_integer_pd && index<((fmi1_me_t *)c)->jmi->offs_boolean_ci) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "CannotSetVariable",
                         "Cannot set Integer dependent parameter <variable: #i%d#>", vr[i]);
            return fmiError;
        }

        if (index>=((fmi1_me_t *)c)->jmi->offs_integer_ci && index<((fmi1_me_t *)c)->jmi->offs_integer_pi) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "CannotSetVariable",
                         "Cannot set Integer constant <variable: #i%d#>", vr[i]);
            return fmiError;
        }

    }

    ((fmi1_me_t *)c)->jmi->recomputeVariables = 1;
    z = jmi_get_z(((fmi1_me_t *)c)->jmi);

    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index < (((fmi1_me_t *)c)->jmi)->offs_real_dx) {
            jmi_init_eval_parameters(((fmi1_me_t *)c)->jmi);
        }

    }
    return fmiOK;
}

fmiStatus fmi1_me_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
    /* Get the z vector*/
    fmiValueReference i;
    fmiValueReference index;
    jmi_real_t* z;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_boolean_pd && index<((fmi1_me_t *)c)->jmi->offs_real_dx) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "CannotSetVariable",
                         "Cannot set Boolean dependent parameter <variable: #b%d#>", vr[i]);
            return fmiError;
        }

        if (index>=((fmi1_me_t *)c)->jmi->offs_boolean_ci && index<((fmi1_me_t *)c)->jmi->offs_boolean_pi) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "CannotSetVariable",
                         "Cannot set Boolean constant <variable: #b%d#>", vr[i]);
            return fmiError;
        }

    }

    ((fmi1_me_t *)c)->jmi->recomputeVariables = 1;
    z = jmi_get_z(((fmi1_me_t *)c)->jmi);

    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];

        if (index<(((fmi1_me_t *)c)->jmi)->offs_real_dx) {
            jmi_init_eval_parameters(((fmi1_me_t *)c)->jmi);
        }

    }
    return fmiOK;
}

fmiStatus fmi1_me_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    /* Strings not yet supported. */
    ((fmi1_me_t *)c)->jmi->recomputeVariables = 1;
    jmi_log_comment(((fmi1_me_t *)c)->jmi->log, logWarning, "Strings are not yet supported.");
    return fmiWarning;
}

/* Evaluation of the model equations */

fmiStatus fmi1_me_initialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo) {
    fmiInteger retval;
    fmiInteger i;                   /* Iteration variable */
    fmiInteger nF0, nF1, nFp, nF;   /* Number of F-equations */
    fmiInteger nR0, nR;             /* Number of R-equations */
    fmiInteger initComplete = 0;    /* If the initialization are complete */
    jmi_real_t nextTimeEvent;       /* Next time event instant */
    fmiInteger iter, max_iterations;
    
    jmi_real_t* switchesR;   /* Switches */
    jmi_real_t* switchesR0;  /* Initial Switches */
    jmi_real_t* switches;
    jmi_real_t* sw_temp = 0;
    jmi_real_t* b_mode;
    fmi1_me_t* fmi1_me;
    jmi_t* jmi;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_me = (fmi1_me_t *)c;
    jmi = fmi1_me->jmi;

    if (((fmi1_me_t*)c)->jmi->is_initialized==1) {
        jmi_log_comment(jmi->log, logError, "FMU is already initialized: only one call to fmiInitialize is allowed");
        return fmiError;
    }

    /* For debugging Jacobians */
/*
    int n_states;
    jmi_real_t* jac;
    int j;
*/

    /* Update eventInfo */

    eventInfo->upcomingTimeEvent = fmiFalse;            /* Next time event is computed after initialization */
    eventInfo->nextEventTime = 0.0;                     /* Next time event is computed after initialization */
    eventInfo->stateValueReferencesChanged = fmiFalse;  /* No support for dynamic state selection */
    eventInfo->terminateSimulation = fmiFalse;          /* Don't terminate the simulation */
    eventInfo->iterationConverged = fmiTrue;            /* The iteration has converged */
    
    max_iterations = 30;
    
    /* Evaluate parameters */
    jmi_init_eval_parameters(jmi);

    /* Get Sizes */
    retval = jmi_init_get_sizes(jmi,&nF0,&nF1,&nFp,&nR0); /* Get the size of R0 and F0, (interested in R0) */
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Initialization failed when trying to retrieve the initial sizes.");
        return fmiError;
    }

    retval = jmi_dae_get_sizes(jmi,&nF,&nR);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Initialization failed when trying to retrieve the actual sizes.");
        return fmiError;
    }
    /* ---- */
    fmi_update_runtime_options(fmi1_me);
    /* Sets the relative tolerance to a default value for use in Kinsol when tolerance controlled is false */
    if (toleranceControlled == fmiFalse){
        relativeTolerance = jmi->options.nle_solver_default_tol;
        jmi->events_epsilon = jmi->options.events_default_tol; /* Used in the event detection */
        jmi->newton_tolerance = jmi->options.nle_solver_default_tol; /* Used in the Newton iteration */
    }
    else {
        jmi->events_epsilon = jmi->options.events_tol_factor*relativeTolerance; /* Used in the event detection */
        jmi->newton_tolerance = jmi->options.nle_solver_tol_factor*relativeTolerance; /* Used in the Newton iteration */
    }
    
    /* We are at the initial event TODO: is this really necessary? */
    ((fmi1_me_t *)c)->jmi->atEvent   = JMI_TRUE;
    ((fmi1_me_t *)c)->jmi->atInitial = JMI_TRUE;

    /* Write values to the pre vector*/
    jmi_copy_pre_values(((fmi1_me_t*)c)->jmi);

    /* Set the switches */
    b_mode =  ((fmi1_me_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
    sw_temp =  ((fmi1_me_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
    retval = jmi_init_R0(((fmi1_me_t *)c)->jmi, b_mode);
    switches = jmi_get_sw(((fmi1_me_t *)c)->jmi);
    for (i=0; i < nR0; i=i+1){
        if (i < nR){
            if (jmi->relations[i] == JMI_REL_GEQ){
                if (b_mode[i] >= 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
            if (jmi->relations[i] == JMI_REL_GT){
                if (b_mode[i] > 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
            if (jmi->relations[i] == JMI_REL_LEQ){
                if (b_mode[i] <= 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
            if (jmi->relations[i] == JMI_REL_LT){
                if (b_mode[i] < 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
        }else{
            if (jmi->initial_relations[i-nR] == JMI_REL_GEQ){
                if (b_mode[i] >= 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
            if (jmi->initial_relations[i-nR] == JMI_REL_GT){
                if (b_mode[i] > 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
            if (jmi->initial_relations[i-nR] == JMI_REL_LEQ){
                if (b_mode[i] <= 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
            if (jmi->initial_relations[i-nR] == JMI_REL_LT){
                if (b_mode[i] < 0.0){
                    switches[i] = 1.0;
                }else{
                    switches[i] = 0.0;
                }
            }
        }
    }

    ((fmi1_me_t*)c) -> fmi_functions.freeMemory(b_mode);
    /* Call the initialization function */
    retval = jmi_ode_initialize(((fmi1_me_t *)c)->jmi);

    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Initialization failed.");
        ((fmi1_me_t*)c) -> fmi_functions.freeMemory(sw_temp);
        return fmiError;
    }
    
    iter = 0;
    while (initComplete == 0 && nR0 > 0){                            /* Loop during event iteration */
        iter += 1;
        
        if (iter > 1){
            retval = jmi_evaluate_switches(jmi,switches,0);
        }
        
        retval = jmi_ode_initialize(((fmi1_me_t *)c)->jmi);

        if(retval != 0) { /* Error check */
            jmi_log_comment(jmi->log, logError, "Initialization failed.");
            ((fmi1_me_t*)c) -> fmi_functions.freeMemory(sw_temp);
            return fmiError;
        }
        
        /* Evaluate the switches */
        memcpy(sw_temp,switches,nR0*sizeof(jmi_real_t));
        retval = jmi_evaluate_switches(jmi,sw_temp,0);
        
        if (jmi_compare_switches(switches,sw_temp,nR0)){
            initComplete = 1;
        }
        
        /* No convergence under the allowed number of iterations. */
        if(iter >= max_iterations){
            jmi_log_node(jmi->log, logError, "Error", "Failed to converge during global fixed point iteration "
                         "due to too many iterations at <t:%g> (initialization).", jmi_get_t(jmi)[0]);
            ((fmi1_me_t*)c) -> fmi_functions.freeMemory(sw_temp);
            return fmiError;
        }
    }
    
    ((fmi1_me_t*)c) -> fmi_functions.freeMemory(sw_temp);

    /* Compute the next time event */
    retval = jmi_ode_next_time_event(((fmi1_me_t *)c)->jmi,&nextTimeEvent);

    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Computation of next time event failed.");
        return fmiError;
    }

    if (!(nextTimeEvent==JMI_INF)) {
        /* If there is an upcoming time event, then set the event information
           accordingly. */
        eventInfo->upcomingTimeEvent = fmiTrue;
        eventInfo->nextEventTime = nextTimeEvent;
        /*printf("fmiInitialize: nextTimeEvent: %f\n",nextTimeEvent);*/
    } else {
        eventInfo->upcomingTimeEvent = fmiFalse;
    }

    /* Reset atEvent flag */
    ((fmi1_me_t *)c)->jmi->atEvent = JMI_FALSE;
    ((fmi1_me_t *)c)->jmi->atInitial = JMI_FALSE;

    /* Evaluate the guards with the event flag set to false in order to 
     * reset guards depending on samplers before copying pre values.
     * If this is not done, then the corresponding pre values for these guards
     * will be true, and no event will be triggered at the next sample. 
     */
    retval = jmi_ode_guards(((fmi1_me_t *)c)->jmi);

    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Computation of guard expressions failed.");
        return fmiError;
    }

    jmi_copy_pre_values(((fmi1_me_t*)c)->jmi);

    /* Initialization is now complete, but we also need to handle events
     * at the start of the integration.
     */
    retval = fmi1_me_event_update(c, fmiFalse, eventInfo);
    if(retval == fmiError) {
        jmi_log_comment(jmi->log, logError, "Event iteration failed during the initialization.");
        return fmiError;
    }

    /*
    //Set the final switches (if any)
    if (nR > 0){
        jmi_real_t* a_mode =  ((fmi1_me_t*)c) -> fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));
        retval = jmi_dae_R(((fmi1_me_t *)c)->jmi,a_mode); //Get the event indicators after the initialisation
        
        if(retval != 0) { //Error check
            jmi_log_comment(jmi->log, logError, "Initialization failed.");
            return fmiError;
        }
        
        switches = jmi_get_sw(((fmi1_me_t *)c)->jmi); //Get the switches
        
        for (i=0; i < nR; i=i+1){ //Set the final switches
            if (a_mode[i] > 0.0){
                switches[i] = 1.0;
            }else{
                switches[i] = 0.0;
            }
            printf("Switches (after) %d, %f\n",i,switches[i]);
        }
        ((fmi1_me_t*)c) -> fmi_functions.freeMemory(a_mode); //Free memory
    }
    */
    /*
    n_states = ((fmi1_me_t *)c)->jmi->n_real_x;
    jac = (jmi_real_t*)calloc(n_states*n_states,sizeof(jmi_real_t));
    fmi_get_jacobian(c, FMI_STATES, FMI_DERIVATIVES, jac, n_states);

    for (i=0;i<n_states;i++) {
        for (j=0;j<n_states;j++) {
            printf("%f, ",jac[i + j*n_states]);
        }
        printf("\n");
    }

    free(jac);
*/

    ((fmi1_me_t*)c)->jmi->is_initialized = 1;

    return fmiOK;
}

fmiStatus fmi1_me_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    if (((fmi1_me_t *)c)->jmi->recomputeVariables==1) {
        fmiInteger retval = jmi_ode_derivatives(((fmi1_me_t *)c)->jmi);
        if(retval != 0) {
            jmi_log_node(((fmi1_me_t *)c)->jmi->log, logError, "Error", "Evaluating the derivatives failed at <t:%g>",
                         jmi_get_t(((fmi1_me_t *)c)->jmi)[0]);
            return fmiError;
        }
        ((fmi1_me_t *)c)->jmi->recomputeVariables = 0;
    }
    memcpy (derivatives, jmi_get_real_dx(((fmi1_me_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi1_me_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    jmi_t* jmi;
    fmiValueReference i;
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    jmi = ((fmi1_me_t *)c)->jmi;
    
    if (((fmi1_me_t *)c)->jmi->recomputeVariables==1) {
        retval = jmi_ode_derivatives(((fmi1_me_t *)c)->jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return fmiError;
        }
        ((fmi1_me_t *)c)->jmi->recomputeVariables = 0;
    }
    retval = jmi_dae_R_perturbed(((fmi1_me_t *)c)->jmi,eventIndicators);
    
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Evaluating the event indicators failed.");
        return fmiError;
    }

    return fmiOK;
}

fmiStatus fmi1_me_get_partial_derivatives(fmiComponent c, fmiStatus (*setMatrixElement)(void* data, fmiInteger row, fmiInteger col, fmiReal value), void* A, void* B, void* C, void* D){    

/* fmi_get_jacobian is not an FMI function. Still use fmiStatus as return arguments?. Is there an error handling policy? Standard messages? Which function should return errors?*/
    
    fmiStatus fmiFlag;
    fmiReal* jac;
    jmi_t* jmi = ((fmi1_me_t *)c)->jmi;
    fmi1_me_t* fmi1_me = (fmi1_me_t *)c;
    int nA;
    int nB;
    int nC;
    int nD;
    int nx;
    int nu;
    int ny;
    int jac_size;
    int i;
    int row;
    int col;

    int n_outputs;
    int* output_vrefs;

    clock_t c0, c1, d0, d1;
    jmi_real_t setElementTime;

    c0 = clock();

    setElementTime = 0;

    /* Get number of outputs that are variability = "continuous", ny */
    n_outputs = ny = jmi->n_outputs;
    if (!(output_vrefs = (int*)fmi1_me -> fmi_functions.allocateMemory(n_outputs, sizeof(int)))) {
        jmi_log_comment(jmi->log, logError, "Out of memory.");
        return fmiError;
    }
        
    jmi_get_output_vrefs(jmi, output_vrefs);

    /* This analysis needs to be extended to account for discrete reals*/
    for(i = 0; i < n_outputs; i++)
        if (get_type_from_value_ref(output_vrefs[i])!= 0)
            ny--;   
    fmi1_me -> fmi_functions.freeMemory(output_vrefs);
    
    nx = jmi->n_real_x;
    nu = jmi->n_real_u;
    
    nA = nx*nx;
    nB = nx*nu;
    nC = ny*nx;
    nD = ny*nu;

    /*
    if (fmi1_me -> fmi_logging_on) {
        jmi_log_node(jmi->log, logInfo, "size_of_A", "<m: %d, n:%d>", nx, nx);
        jmi_log_node(jmi->log, logInfo, "size_of_B", "<m: %d, n:%d>", nx, nu);
        jmi_log_node(jmi->log, logInfo, "size_of_C", "<m: %d, n:%d>", ny, nx);
        jmi_log_node(jmi->log, logInfo, "size_of_D", "<m: %d, n:%d>", ny, nu);
    }
     */

    /* Allocate a big chunk of memory that is enough to compute all Jacobians */
    jac_size = nA + nB + nC + nD;

    /* Allocate memory for the biggest matrix, use this for all matrices. */
    if (!(jac = fmi1_me -> fmi_functions.allocateMemory(sizeof(fmiReal),jac_size))) {
        jmi_log_comment(jmi->log, logError, "Out of memory.");
        return fmiError;
    }

    /* Individual calls to evaluation of A, B, C, D matrices can be made
     * more efficiently by evaluating several Jacobian at the same time.
     */

    /* Get the internal A matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_STATES, FMI_DERIVATIVES, jac, nA); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the A matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }

    /* Update external A matrix */
    for (row=0;row<nx;row++) {
        for (col=0;col<nx;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(A,row+1,col+1,jac[row + col*nx]);
            d1 = clock();
            setElementTime += ((fmiReal)(d1-d0))/(CLOCKS_PER_SEC);
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix A");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    /* Get the internal B matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_INPUTS, FMI_DERIVATIVES, jac, nB); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the B matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }
    /* Update external B matrix */
    for (row=0;row<nx;row++) {
        for (col=0;col<nu;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(B,row+1,col+1,jac[row + col*nx]);
            d1 = clock();
            setElementTime += ((fmiReal)(d1-d0))/(CLOCKS_PER_SEC);
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix B");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    /* Get the internal C matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_STATES, FMI_OUTPUTS, jac, nC); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the C matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }
    /* Update external C matrix */
    for (row=0;row<ny;row++) {
        for (col=0;col<nx;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(C,row + 1, col + 1, jac[row+col*ny]);
            d1 = clock();
            setElementTime += ((fmiReal)(d1-d0))/(CLOCKS_PER_SEC);
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix C");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    /* Get the internal D matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_INPUTS, FMI_OUTPUTS, jac, nD); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the D matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }
    /* Update external D matrix */
    for (row=0;row<ny;row++) {
        for (col=0;col<nu;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(D,row + 1, col + 1,jac[row + col*ny]);
            d1 = clock();
            setElementTime += ((fmiReal) ((long)(d1-d0))/(CLOCKS_PER_SEC));
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix D");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    fmi1_me -> fmi_functions.freeMemory(jac);

    c1 = clock();
    /*printf("Jac eval call: %f\n", ((fmiReal) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/
    /*printf(" - setMatrixElementTime: %f\n", setElementTime);*/
    return fmiOK;
}

/*Evaluates the A, B, C and D matrices using finite differences, this functions has
only been used for debugging purposes*/
fmiStatus fmi1_me_get_jacobian_fd(fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac){
    int i;
    int j;
    int k;
    int offs;
    fmiReal h = 0.000001;
    size_t nvvr = 0;
    size_t nzvr = 0;
    fmiReal* z1;
    fmiReal* z2;
    
    int n_outputs;
    int* output_vrefs;
    int n_outputs2;
    int* output_vrefs2;
    
    jmi_t* jmi = ((fmi1_me_t *)c)->jmi;
    
    n_outputs = jmi->n_outputs;
    n_outputs2 = n_outputs;
    
    output_vrefs = (int*)calloc(n_outputs, sizeof(int));
    output_vrefs2 = (int*)calloc(n_outputs, sizeof(int));
    
    jmi_get_output_vrefs(jmi, output_vrefs);
    j = 0;
    for(i = 0; i < n_outputs; i++){
        if(get_type_from_value_ref(output_vrefs[i]) == 0){
            output_vrefs2[j] = output_vrefs[i]; 
            j++;        
        }else{
            n_outputs2--;
        }
    }
    
    offs = jmi->offs_real_x;
    if(independents&FMI_STATES){
        nvvr += jmi->n_real_x;
    }else{
        offs = jmi->offs_real_u;
    }
    if(independents&FMI_INPUTS){
        nvvr += jmi->n_real_u;
    }
    if(dependents&FMI_DERIVATIVES){
        nzvr += jmi->n_real_dx;
    }
    if(dependents&FMI_OUTPUTS){
        nzvr += n_outputs2;
    }
    
    z1 = (fmiReal*)calloc(nzvr, sizeof(fmiReal));
    z2 = (fmiReal*)calloc(nzvr, sizeof(fmiReal));
    
    for(i = 0; i < nvvr; i++){
        k = 0;
        if((*(jmi->z))[offs+i] != 0){
            h = (*(jmi->z))[offs+i]*0.000000015;
        }else{
            h = 0.000001;
        }
        (*(jmi->z))[offs+i] += h;
        jmi->block_level = 0; /* to recover from errors */        
        jmi_generic_func(jmi, jmi->dae->ode_derivatives);
        if(dependents&FMI_DERIVATIVES){
            for(j = 0; j < jmi->n_real_dx; j++){
                z1[k] = (*(jmi->z))[jmi->offs_real_dx+j];
                k++;
            }
        }
        
        if(dependents&FMI_OUTPUTS){
            for(j = 0; j < n_outputs2; j++){
                z1[k] = (*(jmi->z))[get_index_from_value_ref(output_vrefs2[j])];
                k++;
            }
        }
        
        (*(jmi->z))[offs+i] -= 2*h;
        jmi->block_level = 0; /* to recover from errors */
        
        jmi_generic_func(jmi, jmi->dae->ode_derivatives);
        k = 0;
        if(dependents&FMI_DERIVATIVES){
            for(j = 0; j < jmi->n_real_dx; j++){
                z2[k] = (*(jmi->z))[jmi->offs_real_dx+j];
                k++;
            }
        }
        if(dependents&FMI_OUTPUTS){
            for(j = 0; j < n_outputs2; j++){
                z2[k] = (*(jmi->z))[get_index_from_value_ref(output_vrefs2[j])];
                k++;
            }
        }
        (*(jmi->z))[offs+i] += h;
        
        for(j = 0; j < nzvr;j++){
            jac[i*nzvr+j] = (z1[j] - z2[j])/(2*h);
        }
        
    }
    
    free(output_vrefs);
    free(output_vrefs2);
    
    return fmiOK;
}

/*Evaluates the A, B, C and D matrices*/
fmiStatus fmi1_me_get_jacobian(fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac) {
    
    int i;
    int j;
    int k;
    int index;
    int output_off = 0;
    
    int passed = 0;
    int failed = 0;
    
    fmiReal rel_tol;
    fmiReal abs_tol;
    
    int offs;
    jmi_real_t** dv;
    jmi_real_t** dz;


    /*Used for debugging 
    fmiReal tol = 0.001;    
    fmiReal* jac2;*/
    
    size_t nvvr = 0;
    size_t nzvr = 0;
    
    int n_outputs;
    int* output_vrefs;
    int n_outputs_real;
    int* output_vrefs_real;
    jmi_t* jmi = ((fmi1_me_t *)c)->jmi;
    clock_t c0, c1;

    c0 = clock();
    n_outputs = jmi->n_outputs;
    n_outputs_real = n_outputs;
    
    /*dv and the dz are stored in the same vector*/
    dv = jmi->dz;
    dz = jmi->dz;
    
    /* Used for debbugging
    jac2 = (fmiReal*)calloc(njac, sizeof(fmiReal));
    */
    
    offs = jmi->n_real_dx;
    
    for(i = 0; i<jmi->n_real_dx+jmi->n_real_x+jmi->n_real_u+jmi->n_real_w;i++){
        (*dz)[i] = 0;
    }

    if ((dependents==FMI_DERIVATIVES) && (independents==FMI_STATES) && jmi->color_info_A != NULL) {
        /* Compute Jacobian A with compression */
        for (i=0;i<jmi->color_info_A->n_groups;i++) {
            for(k = 0; k<jmi->n_real_dx+jmi->n_real_x+jmi->n_real_u+jmi->n_real_w;k++){
                (*dz)[k] = 0;
            }
            /* Set the seed vector */
            for (j=0;j<jmi->color_info_A->n_cols_in_group[i];j++) {
                (*dv)[jmi->color_info_A->group_cols[jmi->color_info_A->group_start_index[i] + j] + jmi->n_real_dx] = 1.;
            }
            /*
            for (j=0;j<jmi->n_v;j++) {
                printf(" * %d %f\n",j,(*(jmi->dz))[j]);
            }
            */
            /* Evaluate directional derivative */
            if (i==0) {
                jmi->cached_block_jacobians = 0;
            } else {
                jmi->cached_block_jacobians = 1;
            }
            jmi->block_level = 0; /* to recover from errors */
            
            jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);
            /* Extract Jacobian values */
            for (j=0;j<jmi->color_info_A->n_cols_in_group[i];j++) {
                for (k=jmi->color_info_A->col_start_index[jmi->color_info_A->group_cols[jmi->color_info_A->group_start_index[i] + j]];
                     k<jmi->color_info_A->col_start_index[jmi->color_info_A->group_cols[jmi->color_info_A->group_start_index[i] + j]]+
                       jmi->color_info_A->col_n_nz[jmi->color_info_A->group_cols[jmi->color_info_A->group_start_index[i] + j]];
                        k++) {
                    jac[(jmi->color_info_A->group_cols[jmi->color_info_A->group_start_index[i] + j])*(jmi->n_real_x) +
                        jmi->color_info_A->rows[k]] = (*dz)[jmi->color_info_A->rows[k]];
                }
            }
            /* Reset seed vector */
            for (j=0;j<jmi->color_info_A->n_cols_in_group[i];j++) {
                (*dv)[jmi->color_info_A->group_cols[jmi->color_info_A->group_start_index[i] + j] + jmi->n_real_dx] = 0.;
            }
        }
        c1 = clock();

        /*printf("Jac A eval call: %f\n", ((fmiReal) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/

    } else {

        output_vrefs = (int*)calloc(n_outputs, sizeof(int));
        output_vrefs_real = (int*)calloc(n_outputs, sizeof(int));

        jmi_get_output_vrefs(jmi, output_vrefs);
        j = 0;
        for(i = 0; i < n_outputs; i++){
            if(get_type_from_value_ref(output_vrefs[i]) == 0){
                output_vrefs_real[j] = output_vrefs[i];
                j++;
            }else{
                n_outputs_real--;
            }
        }

        /*nvvr: number of x and/or u variables used
      nzvr: number of dx and/or w variables used*/

        if(independents&FMI_STATES){
            nvvr += jmi->n_real_x;
        }else{
            offs += jmi->n_real_x;
        }
        if(independents&FMI_INPUTS){
            nvvr += jmi->n_real_u;
        }
        if(dependents&FMI_DERIVATIVES){
            nzvr += jmi->n_real_dx;
            output_off = jmi->n_real_dx;
        }
        if(dependents&FMI_OUTPUTS){
            nzvr += n_outputs_real;
        }

        /*For every x and/or u variable...*/
        for(i = 0; i < nvvr; i++){
            (*dv)[i+offs] = 1;
            jmi->block_level = 0; /* to recover from errors */

            /*Evaluate directional derivative*/
            jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);

            /*Jacobian elements ddx/dx and/or ddx/du*/
            if(dependents&FMI_DERIVATIVES){
                for(j = 0; j<jmi->n_real_dx;j++){
                    jac[i*nzvr+j] = (*dz)[j];
                }
            }

            /*Jacobian elements dy/dx and/or dy/du*/
            if(dependents&FMI_OUTPUTS){
                for(j = 0; j<n_outputs_real;j++){
                    index = get_index_from_value_ref(output_vrefs_real[j]);
                    if(index < jmi->n_real_x + jmi->n_real_u){
                        if(index == i + offs){
                            jac[i*nzvr+output_off+j] = 1;
                        } else{
                            jac[i*nzvr+output_off+j] = 0;
                        }
                    } else{
                        jac[i*nzvr+j+output_off] = (*dz)[index-jmi->offs_real_dx];
                    }
                }
            }
            /*reset dz vector*/
            for(j = 0; j<jmi->n_real_dx+jmi->n_real_x+jmi->n_real_u+jmi->n_real_w;j++){
                (*dz)[j] = 0;
            }

        }

        free(output_vrefs);
        free(output_vrefs_real);

    }
    /*
    ---This section has been used for debugging---
    fmi_get_jacobian_fd(c, independents, dependents, jac2, njac);
    
    for(j = 0; j < nvvr; j++){
        for(k = 0; k < nzvr; k++){
            i = j*nzvr + k;
            if(jac[i] != 0 && jac2[i] != 0){
                rel_tol = 1.0 - jac2[i]/jac[i];
                if((rel_tol < tol) && (rel_tol > -tol)){
                    passed++;
                } else{
                    failed++;
                    printf("\ni: %d,j: %d, cad: %f, fd: %f, rel_tol: %f",k, j, jac[i], jac2[i], rel_tol);
                }
            } else{
                abs_tol = jac[i]-jac2[i];
                if((abs_tol < tol) && (abs_tol > -tol)){
                    passed++;
                } else{
                    failed++;
                    printf("\ni: %d, j: %d, cad: %f, fd: %f, abs_tol: %f",k, j, jac[i], jac2[i], abs_tol);
                }
            }
        }
    }
    printf("\nPASSED: %d\tFAILED: %d\n\n", passed, failed);

    free(jac2);
    */
    
    c1 = clock();

    /*printf("Jac eval call: %f\n", ((fmiReal) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/
    return fmiOK;
}

/*Evaluate the directional derivative dz/dv dv*/
fmiStatus fmi1_me_get_directional_derivative(fmiComponent c, const fmiValueReference z_vref[], size_t nzvr, const fmiValueReference v_vref[], size_t nvvr, fmiReal dz[], const fmiReal dv[]) {
    int i = 0;
    jmi_t* jmi = ((fmi1_me_t *)c)->jmi;
    jmi_real_t** dv_ = jmi->dz;
    jmi_real_t** dz_ = jmi->dz;
    for (i=0;i<jmi->n_v;i++) {
        (*dv_)[i] = 0.;
    }
    for (i=0;i<nvvr;i++) {
        (*dv_)[get_index_from_value_ref(v_vref[i])] = dv[i];
    }
    jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);
    for (i=0;i<nzvr;i++) {
        dz[i] = (*dz_)[get_index_from_value_ref(z_vref[i])];
    }
    return fmiOK;
}

fmiStatus fmi1_me_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    fmiInteger retval;
    fmiValueReference i;
    fmiValueReference index;
    jmi_real_t* z;
    int isParameterOrConstant = 1;
    
    if (c == NULL) {
		return fmiFatal;
    }

    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i <nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (((fmi1_me_t *)c)->jmi->recomputeVariables==1 && ((fmi1_me_t *)c)->jmi->is_initialized==1 && isParameterOrConstant==0) {
        retval = jmi_ode_derivatives(((fmi1_me_t *)c)->jmi);
        if(retval != 0) {
            jmi_log_comment(((fmi1_me_t *)c)->jmi->log, logError, "Evaluating the derivatives failed.");
            return fmiError;
        }
        ((fmi1_me_t *)c)->jmi->recomputeVariables = 0;
    }

    /* Get the z vector*/
    z = jmi_get_z(((fmi1_me_t *)c)->jmi);

    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = (fmiReal)z[index];
    }

    return fmiOK;
}

fmiStatus fmi1_me_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    fmiInteger retval;
    jmi_real_t* z;
    fmiValueReference i;
    fmiValueReference index;
    int isParameterOrConstant = 1;
    
    if (c == NULL) {
		return fmiFatal;
    }

    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i <nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (((fmi1_me_t *)c)->jmi->recomputeVariables==1 && ((fmi1_me_t *)c)->jmi->is_initialized==1 && isParameterOrConstant==0) {
        retval = jmi_ode_derivatives(((fmi1_me_t *)c)->jmi);
        if(retval != 0) {
            jmi_log_comment(((fmi1_me_t *)c)->jmi->log, logError, "Evaluating the derivatives failed.");
            return fmiError;
        }
        ((fmi1_me_t *)c)->jmi->recomputeVariables = 0;
    }

    /* Get the z vector*/
    z = jmi_get_z(((fmi1_me_t *)c)->jmi);
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = (fmiInteger)z[index];
    }
    return fmiOK;
}

fmiStatus fmi1_me_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    fmiInteger retval;
    jmi_real_t* z;
    fmiValueReference i;
    fmiValueReference index;
    int isParameterOrConstant = 1;
    
    if (c == NULL) {
		return fmiFatal;
    }

    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i <nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (((fmi1_me_t *)c)->jmi->recomputeVariables==1 && ((fmi1_me_t *)c)->jmi->is_initialized==1 && isParameterOrConstant==0) {
        retval = jmi_ode_derivatives(((fmi1_me_t *)c)->jmi);
        if(retval != 0) {
            jmi_log_comment(((fmi1_me_t *)c)->jmi->log, logError, "Evaluating the derivatives failed.");
            return fmiError;
        }
        ((fmi1_me_t *)c)->jmi->recomputeVariables = 0;
    }
    
    /* Get the z vector*/
    z = jmi_get_z(((fmi1_me_t *)c)->jmi);
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = z[index];
    }
    return fmiOK;
}

fmiStatus fmi1_me_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    fmiInteger retval;
    int i;
    int index;
    int isParameterOrConstant = 1;
    
    if (c == NULL) {
		return fmiFatal;
    }

    /* This is to make sure that if all variables that are inquired
     * are parameters or constants, then the solver should not be invoked.
     */
    for (i = 0; i <nvr; i = i + 1) {
        index = get_index_from_value_ref(vr[i]);

        if (index>=((fmi1_me_t *)c)->jmi->offs_real_dx) {
            isParameterOrConstant = 0;
            break;
        }
    }

    if (((fmi1_me_t *)c)->jmi->recomputeVariables==1 && ((fmi1_me_t *)c)->jmi->is_initialized==1 && isParameterOrConstant==0) {
        retval = jmi_ode_derivatives(((fmi1_me_t *)c)->jmi);
        if(retval != 0) {
            jmi_log_comment(((fmi1_me_t *)c)->jmi->log, logError, "Evaluating the derivatives failed.");
            return fmiError;
        }
        ((fmi1_me_t *)c)->jmi->recomputeVariables = 0;
    }

    /* Strings not yet supported. */
    for(i = 0; i < nvr; i++) value[i] = 0;
    
    jmi_log_comment(((fmi1_me_t *)c)->jmi->log, logWarning, "Strings are not yet supported.");
    return fmiWarning;
}

jmi_t* fmi1_me_get_jmi_t(fmiComponent c) {
    return ((fmi1_me_t*)c)->jmi;
}

fmiStatus fmi1_me_event_iteration(fmiComponent c, fmiBoolean duringInitialization,
                              fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {

    fmiInteger nGuards;
    fmiInteger nF;
    fmiInteger nR;
    fmiInteger retval;
    fmiInteger i,iter, max_iterations;
    jmi_real_t nextTimeEvent;
    fmi1_me_t* fmi1_me = ((fmi1_me_t *)c);
    jmi_t* jmi = fmi1_me->jmi;
    jmi_real_t* z = jmi_get_z(jmi);
    jmi_real_t* event_indicators;
    jmi_real_t* switches;
    jmi_real_t* sw_temp;
    jmi_log_node_t top_node;

    /* Allocate memory */
    nGuards = jmi->n_guards;
    jmi_dae_get_sizes(jmi, &nF, &nR);
    event_indicators = fmi1_me->fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));
    sw_temp = fmi1_me->fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));
    switches = jmi_get_sw(jmi); /* Get the switches */

    /* Reset eventInfo */
    eventInfo->upcomingTimeEvent = fmiFalse;            /* No support for time events */
    eventInfo->nextEventTime = 0.0;                     /* Not used */
    eventInfo->stateValueReferencesChanged = fmiFalse;  /* No support for dynamic state selection */
    eventInfo->terminateSimulation = fmiFalse;          /* Don't terminate the simulation */
    eventInfo->iterationConverged = fmiFalse;           /* The iteration have not converged */
    
    jmi->terminate = 0; /* Reset terminate flag. */

    max_iterations = 30; /* Maximum number of event iterations */

    retval = jmi_ode_derivatives(jmi);

    top_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalEventIterations", 
                                 "Starting global event iteration at <t:%E>", jmi_get_t(jmi)[0]);

    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Initial evaluation of the model equations during event iteration failed.");
        jmi_log_unwind(jmi->log, top_node);
        return fmiError;
    }

    /* Copy all pre values */
    jmi_copy_pre_values(jmi);

    /* We are at an event -> set atEvent to true. */
    jmi->atEvent = JMI_TRUE;

    /* Iterate */
    iter = 0;
    while (eventInfo->iterationConverged == fmiFalse) {
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
            return fmiError;
        }

        /* Compare new values with values
         * with the pre values. If there is an element that differs, set
         * eventInfo->iterationConverged to false
         */
        eventInfo->iterationConverged = fmiTrue; /* Assume the iteration converged */

        /* Start with continuous variables - they could change due to
         * the reinit operator. */

        /*
        for (i=jmi->offs_real_dx;i<jmi->offs_t;i++) {
            if (jmi->z[i - jmi->offs_real_dx + jmi->offs_pre_real_dx] != jmi->z[i]) {
                eventInfo->iterationConverged = fmiFalse;
            }
        }
         */

        for (i=jmi->offs_real_d;i<jmi->offs_pre_real_dx;i=i+1) {
            if (z[i - jmi->offs_real_d + jmi->offs_pre_real_d] != z[i]) {
                eventInfo->iterationConverged = fmiFalse;
            }
        }
        
        /* Evaluate the switches */
        memcpy(sw_temp,switches,nR*sizeof(jmi_real_t));
        retval = jmi_evaluate_switches(jmi,sw_temp,1);
        
        if (jmi_compare_switches(switches,sw_temp,nR) == 0){
            eventInfo->iterationConverged = fmiFalse;
        }

        /* Copy new values to pre values */
        jmi_copy_pre_values(jmi);

        if (intermediateResults) {
            break;
        }
        
        /* No convergence under the allowed number of iterations. */
        if (iter >= max_iterations) {
            jmi_log_node(jmi->log, logError, "Error", "Failed to converge during global fixed point "
                         "iteration due to too many iterations at <t:%E>",jmi_get_t(jmi)[0]);
            jmi_log_unwind(jmi->log, top_node);
            return fmiError;
        }

        jmi_log_leave(jmi->log, iter_node);
    }

    /* Only do the final steps if the event iteration is done. */
    if (eventInfo->iterationConverged == fmiTrue) {
        jmi_log_node_t final_node = jmi_log_enter(jmi->log, logInfo, "final_step");

        /* Compute the next time event */
        retval = jmi_ode_next_time_event(jmi,&nextTimeEvent);

        if(retval != 0) { /* Error check */
            jmi_log_comment(jmi->log, logError, "Computation of next time event failed.");
            jmi_log_unwind(jmi->log, top_node);
            return fmiError;
        }

        /* If there is an upcoming time event, then set the event information
         * accordingly.
         */
        if (!(nextTimeEvent==JMI_INF)) {
            eventInfo->upcomingTimeEvent = fmiTrue;
            eventInfo->nextEventTime = nextTimeEvent;
            /*printf("fmi_event_upate: nextTimeEvent: %f\n",nextTimeEvent); */
        } else {
            eventInfo->upcomingTimeEvent = fmiFalse;
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
            return fmiError;
        }

        jmi_log_leave(jmi->log, final_node);
    }

	/* If everything went well, check if termination of simulation was requested. */
	eventInfo->terminateSimulation = jmi->terminate ? fmiTrue : fmiFalse;

    fmi1_me->fmi_functions.freeMemory(event_indicators);
    fmi1_me->fmi_functions.freeMemory(sw_temp);

    jmi_log_leave(jmi->log, top_node);

    return fmiOK;
}

fmiStatus fmi1_me_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_event_iteration(c, JMI_FALSE, intermediateResults, eventInfo);
}

fmiStatus fmi1_me_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (states, jmi_get_real_x(((fmi1_me_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi1_me_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx) {
    fmiReal* ones;
    fmiValueReference i;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
/*    ones = ((fmi1_me_t*)c) -> fmi_functions.allocateMemory(nx, sizeof(fmiReal)); */

    for(i = 0; i <nx; i = i + 1) {
        x_nominal[i]=1.0;
    }
    /*
    memcpy (x_nominal, ones, nx*sizeof(fmiReal));

    ((fmi1_me_t*)c) -> fmi_functions.freeMemory(ones); */
    return fmiOK;
}

fmiStatus fmi1_me_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx) {
    fmiInteger offset;
    fmiValueReference i;
    
    if (c == NULL) {
		return fmiFatal;
    }
        
    offset = ((fmi1_me_t *)c)->jmi->offs_real_x;
    
    for(i = 0; i<nx; i = i + 1) {
        vrx[i] = offset + i;
    }
    return fmiOK;
}

fmiStatus fmi1_me_terminate(fmiComponent c) {
    /* Release all resources that have been allocated since fmi_initialize has been called. */
    jmi_terminate(((fmi1_me_t *)c)->jmi);
    return fmiOK;
}

BOOL fmi1_me_emitted_category(log_t *log, category_t category) {
    jmi_callbacks_t* jmi_callbacks = log->jmi_callbacks;
    if (((fmi1_me_t *)(jmi_callbacks->fmix_me) != NULL) && !jmi_callbacks->logging_on) {
        return FALSE;
    }
    if (!log->filtering_enabled) {
        return TRUE;
    }
    
    switch (category) {
        case logError:   break;
        case logWarning: if(log->options->log_level < 3) return FALSE; break;
        case logInfo:    if(log->options->log_level < 4) return FALSE; break;
    }
    return TRUE;
}

void fmi1_me_create_log_file_if_needed(log_t *log) {
    if (log->log_file != NULL) return;
    if (log->options->runtime_log_to_file) {
        /* Create new log file */
        const char *instance_name = log->jmi_callbacks->fmi_name;
        char filename[1024];

        sprintf(filename, "%s_%s.log", jmi_get_model_identifier(),
                                       instance_name);
        /* TODO: fopen returns NULL on error
           ==> will try to reopen the file at the next emit. Do we want this? 
           Not an issue if create_log_file_if_needed is only called once.*/
        log->log_file = fopen(filename, "w");
    }
}

static fmiStatus category_to_fmiStatus(category_t c) {
    switch (c) {
    case logError:   return fmiError;
    case logWarning: return fmiWarning;
    case logInfo:    return fmiOK;
    default:         return fmiError;
    }
}

static const char *category_to_fmiCategory(category_t c) {
    switch (c) {
    case logError:   return "ERROR";
    case logWarning: return "WARNING";
    case logInfo:    return "INFO";
    default:         return "UNKNOWN CATEGORY";
    }
}

void fmi1_me_emit(log_t *log, char* message) {
    jmi_callbacks_t* jmi_callbacks = log->jmi_callbacks;
    category_t category = log->c;
    category_t severest_category = severest(category, log->severest_category);

    if (!emitted_category(log, category)) return;

    /* create_log_file_if_needed(log); */
    if (log->log_file) {
        file_logger(log->log_file, log->log_file, 
                    category, severest_category, message);
        fflush(log->log_file);
    }
    if ((fmi1_me_t *)(jmi_callbacks->fmix_me)) {
        ((fmiCallbackLogger)(jmi_callbacks->logger))((fmi1_me_t *)(jmi_callbacks->fmix_me),
                                   jmi_callbacks->fmi_name,
                                   category_to_fmiStatus(category),
                                   category_to_fmiCategory(severest_category),
                                   message);
        
    } else {
        file_logger(stdout, stderr, category, severest_category, message);
    }
}

fmiStatus fmi1_me_extract_debug_info(fmiComponent c) {
    fmiInteger nniters;
    fmiReal avg_nniters;
    fmi1_me_t* fmi1_me = ((fmi1_me_t*)c);
    jmi_t* jmi = fmi1_me->jmi;
    jmi_block_residual_t* block;
    int i;
    jmi_log_node_t topnode = jmi_log_enter(jmi->log, logInfo, "FMIDebugInfo");
    
    /* Extract debug information from initialization*/
    for (i = 0; i < jmi->n_dae_init_blocks; i++) {
        block = jmi->dae_init_block_residuals[i];
        nniters = block->nb_iters;

        /* Test if block is solved by KINSOL */
        if (nniters > 0) {
            /* Output to logger */
            jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "initialization");
            jmi_log_fmt(jmi->log, node, logInfo, "<block: %d, size: %d, nniters: %d, nbcalls: %d, njevals: %d, nfevals: %d>", 
                        block->index, block->n, (int)nniters, (int)block->nb_calls, (int)block->nb_jevals, (int)block->nb_fevals);
            jmi_log_fmt(jmi->log, node, logInfo, "<time_spent: %f>", block->time_spent);
            jmi_log_leave(jmi->log, node);
        }
    }

    /* Extract debug information from DAE blocks */
    for (i = 0; i < jmi->n_dae_blocks; i++) {
        block = jmi->dae_block_residuals[i];
        nniters = block->nb_iters;

        /* Test if block is solved by KINSOL */
        if (nniters > 0) {
            /* Output to logger */
            /* NB: Exactly the same code as above. Todo: factor out? */
            jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "dae_blocks");
            jmi_log_fmt(jmi->log, node, logInfo, "<block: %d, size: %d, nniters: %d, nbcalls: %d, njevals: %d, nfevals: %d>", 
                        block->index, block->n, (int)nniters, (int)block->nb_calls, (int)block->nb_jevals, (int)block->nb_fevals);
            jmi_log_fmt(jmi->log, node, logInfo, "<time_spent: %f>", block->time_spent);
            jmi_log_leave(jmi->log, node);            
        }
    }
    /*
        for (i=0; i < jmi->n_dae_blocks;i=i+1){
            jmi_delete_block_residual(jmi->dae_block_residuals[i]);
    }*/

    jmi_log_leave(jmi->log, topnode);

    return fmiOK;
}

extern const char *fmi_runtime_options_map_names[];
extern const int fmi_runtime_options_map_vrefs[];
extern const int fmi_runtime_options_map_length;

int compare_option_names(const void* a, const void* b) {
    const char** sa = (const char**)a;
    const char** sb = (const char**)b;
    return strcmp(*sa, *sb);
}

static int get_option_index(char* option) {
    const char** found=(const char**)bsearch(&option,fmi_runtime_options_map_names,fmi_runtime_options_map_length,sizeof(char*),compare_option_names);
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
void fmi_update_runtime_options(fmi1_me_t* fmi1_me) {
    jmi_t* jmi = fmi1_me->jmi;
    jmi_real_t* z = jmi_get_z(jmi);
    int index;
    int index1;
    int index2;
    jmi_options_t* op = &fmi1_me->jmi->options;
    index = get_option_index("_log_level");
    if(index)
        op->log_level = (int)z[index]; 
    index = get_option_index("_enforce_bounds");
    if(index)
        op->enforce_bounds_flag = (int)z[index]; 
    
    index = get_option_index("_use_jacobian_equilibration");
    index1 = get_option_index("_use_jacobian_scaling");
    if(index || index1 ){
        int fl, fl1;
        fl = fl1 = op->use_jacobian_equilibration_flag;
        if(index) fl = (int)z[index]; 
        if(index1) fl1 = (int)z[index1];
        
        op->use_jacobian_equilibration_flag = fl || fl1; 
    }
    
    index = get_option_index("_residual_equation_scaling");
    index1 = get_option_index("_use_automatic_scaling");
    index2 = get_option_index("_use_manual_equation_scaling");
    if(index || index1 || index2) {
        /* to support deprecation: non-default setting given precendence*/
        if(index2 && (int)z[index2]) {
            op->residual_equation_scaling_mode = jmi_residual_scaling_manual;
        }
        else if(index1 && !(int)z[index1]){
            op->residual_equation_scaling_mode = jmi_residual_scaling_none;
        }
        else if(index && ((int)z[index] != jmi_residual_scaling_auto)) {
            op->residual_equation_scaling_mode = (int)z[index];
        }
        else
            op->residual_equation_scaling_mode = jmi_residual_scaling_auto;
    }
    index = get_option_index("_nle_solver_max_iter");
    if(index)
        op->nle_solver_max_iter = (int)z[index];
    index = get_option_index("_block_solver_experimental_mode");
    if(index)
        op->block_solver_experimental_mode  = (int)z[index];
    
    index = get_option_index("_iteration_variable_scaling");
    if(index)
        op->iteration_variable_scaling_mode = (int)z[index];
    
    index = get_option_index("_rescale_each_step");
    if(index)
        op->rescale_each_step_flag = (int)z[index]; 
    index = get_option_index("_rescale_after_singular_jac");
    if(index)
        op->rescale_after_singular_jac_flag = (int)z[index]; 
    index = get_option_index("_use_Brent_in_1d");
    if(index)
        op->use_Brent_in_1d_flag = (int)z[index]; 
    index = get_option_index("_nle_solver_default_tol");
    if(index)
        op->nle_solver_default_tol = z[index]; 
    index = get_option_index("_nle_solver_check_jac_cond");
    if(index)
        op->nle_solver_check_jac_cond_flag = (int)z[index]; 
    index = get_option_index("_nle_solver_min_tol");
    if(index)
        op->nle_solver_min_tol = z[index]; 
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
        op->block_jacobian_check = z[index]; 
    index = get_option_index("_block_jacobian_check_tol");
    if(index)
        op->block_jacobian_check_tol = z[index];
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
        op->runtime_log_to_file = (int)z[index]; 
    
/*    op->block_solver_experimental_mode = 
            jmi_block_solver_experimental_steepest_descent_first|
            jmi_block_solver_experimental_converge_switches_first;
   op->log_level = 5; */
}
