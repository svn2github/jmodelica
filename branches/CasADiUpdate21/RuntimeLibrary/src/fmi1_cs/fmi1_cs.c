/*
    Copyright (C) 2011 Modelon AB

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
#include <stdarg.h>
#include "fmi1_cs.h" 
#include "fmi1_me.h"
#include "jmi_ode_solver.h"
#include "jmi_log.h"

const char* fmi1_cs_get_types_platform() {
    return fmiPlatform;
}

const char* fmi1_cs_get_version() {
    return fmi1_me_get_version();
}

fmiStatus fmi1_cs_set_debug_logging(fmiComponent c, fmiBoolean loggingOn){
    fmi1_cs_t* fmi1_cs;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    fmi1_cs->ode_problem->jmi_callbacks->log_options.logging_on_flag = loggingOn;     
    
    return fmi1_me_set_debug_logging(fmi1_cs->ode_problem ->fmix_me,loggingOn);
}


fmiStatus fmi1_cs_do_step(fmiComponent c, fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize, fmiBoolean newStep) {
    fmi1_cs_t* fmi1_cs;
    jmi_ode_problem_t* ode_problem;
    jmi_cs_input_t* inputs;
    int flag, retval = JMI_ODE_EVENT;
    int initialize = (int)JMI_FALSE; /* Should an initialization be performed on start of every do_step? */
    fmiReal time_final = currentCommunicationPoint+communicationStepSize;
    fmiReal time_event;
    fmiInteger i;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    ode_problem = fmi1_cs -> ode_problem;

    /* Check if there are upcoming time events. */
    if (fmi1_cs->event_info.upcomingTimeEvent == fmiTrue){
        if(fmi1_cs->event_info.nextEventTime < time_final){
            time_event = fmi1_cs->event_info.nextEventTime;
        }else{
            time_event = time_final;
        }
    }else{
        time_event = time_final;
    }
    
    /* For the active inputs, get the initialize input */
    inputs = ode_problem->inputs;
    for (i = 0; i < ode_problem -> n_real_u; i++) {
        if (inputs[i].active == fmiTrue) {
            inputs[i].tn = ode_problem->time;
            retval = fmi1_me_get_real(ode_problem ->fmix_me, &(inputs[i].vr), 1, &(inputs[i].input));
            if (retval != fmiOK) {
                jmi_log_comment(ode_problem->log, logError, "Failed to get the initial inputs.");
                return fmiError;
            }
        }
    }
    
    if (communicationStepSize == 0.0) {
        /* Evaluate the equations */
        /* retval = fmi1_me_get_derivatives(ode_problem->fmix_me, fmi1_cs->states_derivative, fmi1_cs->n_real_x); */
        retval = fmi1_me_event_update(ode_problem->fmix_me, fmiFalse, &(fmi1_cs->event_info));
        if (retval != fmiOK) {
            jmi_log_comment(ode_problem->log, logError, "Failed to evaluate the derivatives with step-size zero.");
        }
    } else {
        retval = JMI_ODE_EVENT;
        while (retval == JMI_ODE_EVENT && ode_problem->time < time_final){
            
            /*printf("time = %f", ode_problem->time);
            fflush(stdout);*/
    
            retval = ode_problem->ode_solver->solve(ode_problem->ode_solver, time_event, initialize);
            if (retval==JMI_ODE_OK && time_event == time_final) {
                break;
            }
            
            if (retval<JMI_ODE_OK){
                jmi_log_comment(ode_problem->log, logError, "Failed to perform a step.");
                return fmiError;
            }
            
            flag = fmi1_me_event_update(ode_problem ->fmix_me, fmiFalse, &(fmi1_cs->event_info));
            if (flag != fmiOK){
                jmi_log_comment(ode_problem->log, logError, "Failed to handle the event.");
                return fmiError;
            }
            
            flag = fmi1_me_get_continuous_states(ode_problem->fmix_me, ode_problem->states, ode_problem->n_real_x);
            if (flag != fmiOK) {
                return fmiError;
            }
            flag = fmi1_me_get_nominal_continuous_states(ode_problem->fmix_me, ode_problem->nominal, ode_problem->n_real_x);
            if (flag != fmiOK) {
                jmi_log_node(ode_problem->log, logError, "Error", "Failed to get the nominal states.");
                return fmiError;
            }
            
            /* Check if there are upcoming time events. */
            if (fmi1_cs->event_info.upcomingTimeEvent == fmiTrue){
                if(fmi1_cs->event_info.nextEventTime < time_final){
                    time_event = fmi1_cs->event_info.nextEventTime;
                }else{
                    time_event = time_final;
                }
            }else{
                time_event = time_final;
            }
            
            /* Event handled, initialize again */
            initialize = (int)JMI_TRUE;
        }
    }
    
    /* De-activate inputs as they are no longer valid */
    for (i = 0; i < ode_problem -> n_real_u; i++) {
        inputs[i].active = fmiFalse;
    }
    
    return fmiOK;
}

void fmi1_cs_free_slave_instance(fmiComponent c) {
    fmi1_cs_t* fmi1_cs;
    fmiCallbackFreeMemory fmi_free;
    
    if (c == NULL) {
		return;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    
    if (fmi1_cs->ode_problem->ode_solver){
        jmi_delete_ode_solver(fmi1_cs->ode_problem);
    }
    
    fmi1_me_free_model_instance(fmi1_cs->ode_problem->fmix_me);
    
    if (fmi1_cs) {
        /* Free the ODE problem.
         * In case log was created as:
         * ode_problem -> log = jmi_log_init( jmi_callbacks); 
         * it have to be freed by:
         * free(fmi1_cs -> ode_problem -> log);*/
        fmi1_cs -> ode_problem -> log = NULL;
        jmi_free_ode_problem((void*)fmi1_cs -> ode_problem);
        
        /* Free the fmi1_cs struct. */
        fmi_free = fmi1_cs -> callback_functions.freeMemory;
        fmi_free((void*)fmi1_cs -> instance_name);
        fmi_free((void*)fmi1_cs -> encoded_instance_name);
        fmi_free((void*)fmi1_cs -> GUID);
        fmi_free(fmi1_cs);
    }
}

void log_forwarding_me(fmiComponent c, fmiString instanceName, fmiStatus status, fmiString category, fmiString message, ...){
    void *tmp;
    fmi1_cs_t* fmi1_cs;
    int verification;
    va_list args;
    char buffer[50000];
    
    sscanf(instanceName, "Encoded name: %p %i", &tmp, &verification);

    va_start(args, message);
    /* vsnprintf(buffer, sizeof buffer, message, args); */ /* Cannot be used due to C89 */
    vsprintf (buffer,message, args);
    va_end(args);
  
    
    buffer[sizeof buffer - 1] = 0;
    
    if(verification == 123){
         fmi1_cs = (fmi1_cs_t*)tmp;
         
         fmi1_cs->callback_functions.logger(tmp, fmi1_cs->instance_name, status, category, buffer);
         
    }else{
         printf("ERROR! Log forwarding failed, the instance name has been manipulated... \n");
    }
}

fmiComponent fmi1_cs_instantiate_slave(fmiString instanceName, fmiString GUID, fmiString fmuLocation, fmiString mimeType, 
                                   fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiCallbackFunctions functions, 
                                   fmiBoolean loggingOn) {
    fmi1_cs_t *component;
    fmi1_me_t * fmi1_me;
    jmi_ode_problem_t* ode_problem = 0;
    jmi_t* jmi;
    char* tmpname;
    char* tmpguid;
    char* tmp_name_encoded;
    size_t inst_name_len;
    size_t guid_len;
    
    component = (fmi1_cs_t *)functions.allocateMemory(1, sizeof(fmi1_cs_t));
    
    component -> me_callback_functions.allocateMemory = functions.allocateMemory;
    component -> me_callback_functions.freeMemory = functions.freeMemory;
    component -> me_callback_functions.logger = log_forwarding_me;
    
    inst_name_len = strlen(instanceName)+1;
    tmpname = (char*)functions.allocateMemory(inst_name_len, sizeof(char));
    strncpy(tmpname, instanceName, inst_name_len);
    component -> instance_name = tmpname;

    guid_len = strlen(GUID)+1;
    tmpguid = (char*)functions.allocateMemory(guid_len, sizeof(char));
    strncpy(tmpguid, GUID, guid_len);
    component -> GUID = tmpguid;
    
    /* Encode the instance name passed to the ME interface to include the fmi1_cs_t struct */
    /* Also encode a verification number to check against manipulation of the name (123) */
    tmp_name_encoded = (char*)functions.allocateMemory(100, sizeof(char));
    component -> encoded_instance_name = tmp_name_encoded;
    sprintf(tmp_name_encoded, "Encoded name: %p 123", (void*)component);
    
    component -> logging_on = loggingOn;
    component -> callback_functions = functions;
    
    fmi1_me = (fmi1_me_t *)fmi1_me_instantiate_model(component -> encoded_instance_name, GUID, component -> me_callback_functions, loggingOn);
    
    if (fmi1_me == NULL){
        functions.freeMemory((void*)component -> instance_name);
        functions.freeMemory((void*)component -> encoded_instance_name);
        functions.freeMemory((void*)component -> GUID);
        functions.freeMemory(component);
        return NULL;
    }
    jmi = &(fmi1_me->jmi);
    /* NEEDS TO COME FROM OUTSIDE, FROM THE XML FILE*/
    jmi_new_ode_problem(&ode_problem, &(fmi1_me->jmi.jmi_callbacks),
                        fmi1_me,
                        jmi->n_real_x,
                        jmi->n_relations,
                        jmi->n_real_u,
                        jmi->log);
    /* In case fmi1_me_instantiate_model was not called, log struct have to
     * be created as:
     * ode_problem -> log = jmi_log_init(jmi_callbacks); */
    
    component -> ode_problem = ode_problem;
    
    return (fmiComponent)component;
}


fmiStatus fmi1_cs_terminate_slave(fmiComponent c) {
    fmi1_cs_t* fmi1_cs;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    
    return fmi1_me_terminate(fmi1_cs->ode_problem->fmix_me);
}

fmiStatus fmi1_cs_initialize_slave(fmiComponent c, fmiReal tStart,
                                    fmiBoolean StopTimeDefined, fmiReal tStop){
    fmi1_cs_t* fmi1_cs;
    jmi_ode_problem_t* ode_problem;
    fmi1_me_t* fmi1_me;
    jmi_ode_method_t ode_method;
    jmi_real_t ode_step_size;
    jmi_real_t ode_rel_tol;
    fmiBoolean toleranceControlled = fmiTrue;
    fmiReal relativeTolerance = 1e-6;
    fmiStatus retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    ode_problem = fmi1_cs -> ode_problem;
    fmi1_me = (fmi1_me_t*)(ode_problem->fmix_me);
    
    /* jmi_ode_solvers_t solver = JMI_ODE_CVODE; */
                                        
    retval = fmi1_me_initialize(ode_problem->fmix_me, toleranceControlled, relativeTolerance, &(fmi1_cs->event_info));
    if (retval != fmiOK) { 
        return fmiError; 
    }
    
    /*Get the states, event indicators and the nominals for the ODE problem. Initialization. */
    fmi1_me_get_continuous_states(ode_problem->fmix_me, ode_problem->states, ode_problem->n_real_x);
    fmi1_me_get_event_indicators(ode_problem->fmix_me, ode_problem->event_indicators, ode_problem->n_sw);
    fmi1_me_get_event_indicators(ode_problem->fmix_me, ode_problem->event_indicators_previous, ode_problem->n_sw);
    fmi1_me_get_nominal_continuous_states(ode_problem->fmix_me, ode_problem->nominal, ode_problem->n_real_x);
    /*The rest of the initialization for the ODE problem. */
    jmi_init_ode_problem(ode_problem, tStart, fmi1_cs_rhs_fcn,
                         fmi1_cs_root_fcn, fmi1_cs_completed_integrator_step);
    
    /* These options for the solver need to be found in a better way. */
    ode_method    = fmi1_me->jmi.options.cs_solver;
    ode_step_size = fmi1_me->jmi.options.cs_step_size;
    ode_rel_tol   = fmi1_me->jmi.options.cs_rel_tol;
    
    /* Create solver */
    retval = jmi_new_ode_solver(ode_problem, ode_method, ode_step_size, ode_rel_tol);
    if (retval != fmiOK){ return fmiError; }
    
    return fmiOK;
}

fmiStatus fmi1_cs_cancel_step(fmiComponent c){
    return fmiError;
}

fmiStatus fmi1_cs_reset_slave(fmiComponent c) {
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs;
    jmi_ode_problem_t* ode_problem;
    fmi1_me_t* fmi1_me;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    ode_problem = fmi1_cs -> ode_problem;
    
    retval = fmi1_cs_terminate_slave(c);
    if (retval != fmiOK){ return fmiError; }
    
    if (ode_problem->ode_solver){
        jmi_delete_ode_solver(ode_problem);
    }
    
    fmi1_me_free_model_instance(ode_problem->fmix_me);
    ode_problem->fmix_me = NULL;
    
    ode_problem->fmix_me = fmi1_me = fmi1_me_instantiate_model(fmi1_cs->encoded_instance_name,
                                                     fmi1_cs->GUID, fmi1_cs->me_callback_functions,
                                                     fmi1_cs->logging_on);
    
    if (ode_problem->fmix_me == NULL){ return fmiError; }
    ode_problem->log = fmi1_me->jmi.log;
    return fmiOK;
}

fmiStatus fmi1_cs_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_real(((fmi1_cs_t *)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_integer(((fmi1_cs_t *)c)->ode_problem ->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_boolean(((fmi1_cs_t *)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_string(((fmi1_cs_t *)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_real(((fmi1_cs_t *)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_integer(((fmi1_cs_t *)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_boolean(((fmi1_cs_t *)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_string(((fmi1_cs_t*)c)->ode_problem->fmix_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]){
    return fmiError;
}

fmiStatus fmi1_cs_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    jmi_ode_problem_t* ode_problem = fmi1_cs -> ode_problem;
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_cs_set_real_input_derivatives(ode_problem, vr, nvr, order, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_cs_get_status(fmiComponent c, const fmiStatusKind s, fmiStatus* value){
    return fmiDiscard;
}

fmiStatus fmi1_cs_get_real_status(fmiComponent c, const fmiStatusKind s, fmiReal* value){
    return fmiDiscard;
}

fmiStatus fmi1_cs_get_integer_status(fmiComponent c, const fmiStatusKind s, fmiInteger* value){
    return fmiDiscard;
}

fmiStatus fmi1_cs_get_boolean_status(fmiComponent c, const fmiStatusKind s, fmiBoolean* value){
    return fmiDiscard;
}

fmiStatus fmi1_cs_get_string_status(fmiComponent c, const fmiStatusKind s, fmiString* value){
    return fmiDiscard;
}

int fmi1_cs_rhs_fcn(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs){
    fmiStatus retval;
    
    /* Set the states */
    retval = fmi1_me_set_continuous_states(ode_problem->fmix_me, (fmiReal*)y, ode_problem->n_real_x);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi1_me_set_time(ode_problem->fmix_me, t);
    if (retval != fmiOK) {
        return -1;
    }
	ode_problem->time = t;
    
    /* Set the inputs */
    retval = fmi1_cs_set_input(ode_problem, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Evaluate the derivatives */
    if (ode_problem->n_real_x > 0) {
        retval = fmi1_me_get_derivatives(ode_problem->fmix_me, (fmiReal*)rhs , ode_problem->n_real_x);
        if (retval != fmiOK) {
            return -1;
        }
    }else{
        rhs[0] = 0.0;
    }
    
    return 0;
}

int fmi1_cs_root_fcn(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t *y, jmi_real_t *root){
    fmiStatus retval;
    
    retval = fmi1_me_set_continuous_states(ode_problem->fmix_me, (fmiReal*)y, ode_problem->n_real_x);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi1_me_set_time(ode_problem->fmix_me, t);
    if (retval != fmiOK) {
        return -1;
    }
    ode_problem->time = t;
    
    /* Set the inputs */
    retval = fmi1_cs_set_input(ode_problem, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    retval = fmi1_me_get_event_indicators(ode_problem->fmix_me, (fmiReal*)root , ode_problem->n_sw);
    if (retval != fmiOK) {
        return -1;
    }
    
    return 0;
}

fmiStatus fmi1_cs_set_input(jmi_ode_problem_t* ode_problem, fmiReal time) {
    jmi_cs_input_t* inputs;
    fmiStatus retval;
    fmiReal value;
    fmiInteger i,j;
    
    inputs = ode_problem -> inputs;
    for (i = 0; i < ode_problem -> n_real_u; i++) {
        if (inputs[i].active == fmiFalse) {
            continue;
        }
        value = inputs[i].input;
        for (j = 0; j < JMI_CS_MAX_INPUT_DERIVATIVES; j++) {
            value += pow((time - inputs[i].tn),j+1.0) * (inputs[i].input_derivatives[j]) / 
                                    (inputs[i].input_derivatives_factor[j]);
        }
        
        retval = fmi1_me_set_real(ode_problem->fmix_me, &(inputs[i].vr), 1, &value);
        if (retval != fmiOK) {
            return fmiError;
        }
    }
    return fmiOK;
}

fmiStatus fmi1_cs_set_time(fmiComponent c, fmiReal time){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    int retval;
    
    retval = fmi1_me_set_time(fmi1_cs->ode_problem->fmix_me, time);
    if (retval != fmiOK) {
        return fmiError;
    }
    fmi1_cs->ode_problem->time = time;
    
    return fmiOK;
}

int fmi1_cs_completed_integrator_step(jmi_ode_problem_t* ode_problem, char* step_event){
    int retval;

    retval = fmi1_me_completed_integrator_step(ode_problem->fmix_me, step_event);
    if (retval != fmiOK) {
        return -1;
    }
    
    return 0;
}

/*
fmiStatus fmi_save_state(fmiComponent c, size_t index){
    return fmiError;
}

fmiStatus fmi_restore_state(fmiComponent c, size_t index){
    return fmiError;
}
*/
