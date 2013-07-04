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
    fmi1_cs -> logging_on = loggingOn;     
    
    return fmi1_me_set_debug_logging(fmi1_cs->fmi1_me,loggingOn);
}


fmiStatus fmi1_cs_do_step(fmiComponent c,
                         fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep) {
    fmi1_cs_t* fmi1_cs;
    fmi_t* fmi1_me;
    jmi_t* jmi;
    int flag, retval = JMI_ODE_EVENT;
    int initialize = JMI_FALSE; /* Should an initialization be performed on start of every do_step? */
    fmiReal time_final = currentCommunicationPoint+communicationStepSize;
    fmiReal time_event;
    fmiInteger i;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    jmi = fmi1_me->jmi;

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
    for (i = 0; i < fmi1_cs -> n_real_u; i++) {
        if (fmi1_cs -> inputs[i].active == fmiTrue) {
            fmi1_cs -> inputs[i].tn = fmi1_cs->time;
            retval = fmi1_me_get_real(fmi1_cs->fmi1_me, &(fmi1_cs -> inputs[i].vr), 1, &(fmi1_cs -> inputs[i].input));
            if (retval != fmiOK) {
                jmi_log_comment(jmi->log, logError, "Failed to get the initial inputs.");
                return fmiError;
            }
        }
    }
    
    if (communicationStepSize == 0.0) {
        /* Evaluate the equations */
        /* retval = fmi1_me_get_derivatives(fmi1_cs->fmi1_me, fmi1_cs->states_derivative, fmi1_cs->n_real_x); */
        retval = fmi1_me_event_update(fmi1_cs->fmi1_me, fmiFalse, &(fmi1_cs->event_info));
        if (retval != fmiOK) {
            jmi_log_comment(jmi->log, logError, "Failed to evaluate the derivatives with step-size zero.");
        }
    } else {
        retval = JMI_ODE_EVENT;
        while (retval == JMI_ODE_EVENT && fmi1_cs->time < time_final){
        
            retval = fmi1_cs->ode_solver->solve(fmi1_cs->ode_solver, time_event, initialize);
            if (retval==JMI_ODE_OK && time_event == time_final) {
                break;
            }
            
            if (retval<JMI_ODE_OK){
                jmi_log_comment(jmi->log, logError, "Failed to perform a step.");
                return fmiError;
            }
            
            flag = fmi1_me_event_update(fmi1_cs->fmi1_me, fmiFalse, &(fmi1_cs->event_info));
            if (flag != fmiOK){
                jmi_log_comment(jmi->log, logError, "Failed to handle the event.");
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
            initialize = JMI_TRUE;
        }
    }
    
    /* De-activate inputs as they are no longer valid */
    for (i = 0; i < fmi1_cs -> n_real_u; i++) {
        fmi1_cs -> inputs[i].active = fmiFalse;
    }
    
    return fmiOK;
}

void fmi1_cs_free_slave_instance(fmiComponent c) {
    fmi1_cs_t* fmi1_cs;
    
    if (c == NULL) {
		return;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    
    if (fmi1_cs->ode_solver){
        jmi_delete_ode_solver(fmi1_cs);
    }
    fmi1_me_free_model_instance(fmi1_cs->fmi1_me);
    
    if (fmi1_cs) {
        fmiCallbackFreeMemory fmi_free = fmi1_cs -> callback_functions.freeMemory;

        fmi_free((void*)fmi1_cs -> instance_name);
        fmi_free((void*)fmi1_cs -> encoded_instance_name);
        fmi_free((void*)fmi1_cs -> GUID);
        fmi_free((void*)fmi1_cs -> states);
        fmi_free((void*)fmi1_cs -> states_derivative);
        fmi_free((void*)fmi1_cs -> event_indicators);
        fmi_free((void*)fmi1_cs -> event_indicators_previous);
        fmi_free((void*)fmi1_cs -> inputs);
        fmi_free(fmi1_cs);
    }
    return;
}

void log_forwarding_me(fmiComponent c, fmiString instanceName, fmiStatus status, fmiString category, fmiString message, ...){
    void *tmp;
    fmi1_cs_t* fmi1_cs;
    int verification, length;
    va_list args;
    char buffer[50000];
    
    sscanf(instanceName, "Encoded name: %p %i", &tmp, &verification);

    va_start(args, message);
    /* vsnprintf(buffer, sizeof buffer, message, args); */ /* Cannot be used due to C89 */
    length = vsprintf (buffer,message, args);
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
    char* tmpname;
    char* tmpguid;
    char* tmp_name_encoded;
    size_t inst_name_len;
    size_t guid_len;
    char buffer[400];
    fmiInteger i;
    
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
    
    component -> callback_functions = functions;
    component -> logging_on = loggingOn;                                   
    
    component -> fmi1_me = fmi1_me_instantiate_model(component -> encoded_instance_name, GUID, component -> me_callback_functions, loggingOn);
    
    if (component -> fmi1_me == NULL){
        functions.freeMemory((void*)component -> instance_name);
        functions.freeMemory((void*)component -> encoded_instance_name);
        functions.freeMemory((void*)component -> GUID);
        functions.freeMemory(component);
        return NULL;
    }
    
    /* NEEDS TO COME FROM OUTSIDE, FROM THE XML FILE*/
    component -> n_real_x = ((fmi_t*)component->fmi1_me)->jmi->n_real_x;
    component -> n_sw     = ((fmi_t*)component->fmi1_me)->jmi->n_sw;
    component -> n_real_u = ((fmi_t*)component->fmi1_me)->jmi->n_real_u;
    component -> states   = (fmiReal*)functions.allocateMemory(component->n_real_x, sizeof(fmiReal));
    component -> states_derivative   = (fmiReal*)functions.allocateMemory(component->n_real_x, sizeof(fmiReal));
    component -> event_indicators = (fmiReal*)functions.allocateMemory(component->n_sw, sizeof(fmiReal));
    component -> event_indicators_previous = (fmiReal*)functions.allocateMemory(component->n_sw, sizeof(fmiReal));
    component -> inputs = (fmi1_cs_input_t*)functions.allocateMemory(component->n_real_u, sizeof(fmi1_cs_input_t));
    
    /* Initialize inputs */
    for (i = 0; i < component -> n_real_u; i++) {
        fmi1_cs_init_input_struct(&(component -> inputs[i]));
    }
    
    return (fmiComponent)component;
}


fmiStatus fmi1_cs_terminate_slave(fmiComponent c) {
    fmi1_cs_t* fmi1_cs;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    
    return fmi1_me_terminate(fmi1_cs->fmi1_me);
}

fmiStatus fmi1_cs_initialize_slave(fmiComponent c, fmiReal tStart,
                                    fmiBoolean StopTimeDefined, fmiReal tStop){
    fmi1_cs_t* fmi1_cs;
    fmi_t* fmi1_me;
    fmiBoolean toleranceControlled = fmiTrue;
    fmiReal relativeTolerance = 1e-6;
    fmiStatus retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    
    /* jmi_ode_solvers_t solver = JMI_ODE_CVODE; */
                                        
    retval = fmi1_me_initialize(fmi1_cs->fmi1_me, toleranceControlled, relativeTolerance, &(fmi1_cs->event_info));
    if (retval != fmiOK) { 
        return fmiError; 
    }
    
    /*Get the states*/ 
    fmi1_me_get_continuous_states(fmi1_cs->fmi1_me, fmi1_cs->states, fmi1_cs->n_real_x);
    /*Store the time */
    fmi1_cs->time = tStart;
    /*Get the event indicators */
    fmi1_me_get_event_indicators(fmi1_cs->fmi1_me, fmi1_cs->event_indicators, fmi1_cs->n_sw);
    fmi1_me_get_event_indicators(fmi1_cs->fmi1_me, fmi1_cs->event_indicators_previous, fmi1_cs->n_sw);
    
    
    /* Create solver */
    retval = jmi_new_ode_solver(fmi1_cs, fmi1_me->jmi->options.cs_solver);
    if (retval != fmiOK){ return fmiError; }
    
    return fmiOK;
}

fmiStatus fmi1_cs_cancel_step(fmiComponent c){
    return fmiError;
}

fmiStatus fmi1_cs_reset_slave(fmiComponent c) {
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_cs = (fmi1_cs_t*)c;
    
    retval = fmi1_cs_terminate_slave(c);
    if (retval != fmiOK){ return fmiError; }
    
    if (fmi1_cs->ode_solver){
        jmi_delete_ode_solver(fmi1_cs);
    }
    
    fmi1_me_free_model_instance(fmi1_cs->fmi1_me);
    fmi1_cs->fmi1_me = NULL;
    
    fmi1_cs -> fmi1_me = fmi1_me_instantiate_model(fmi1_cs->encoded_instance_name, fmi1_cs->GUID, fmi1_cs->me_callback_functions, fmi1_cs->logging_on);
    
    if (fmi1_cs->fmi1_me == NULL){ return fmiError; }
    
    return fmiOK;
}

fmiStatus fmi1_cs_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_real(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_integer(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_boolean(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_set_string(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_real(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_integer(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_boolean(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]){
    if (c == NULL) {
		return fmiFatal;
    }
    
    return fmi1_me_get_string(((fmi1_cs_t*)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]){
    return fmiError;
}

fmiStatus fmi1_cs_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmiInteger i,j;
    fmiBoolean found_input = fmiFalse;
    fmi_t* fmi1_me;
    jmi_t* jmi;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    jmi = fmi1_me->jmi;
    
    if (nvr > fmi1_cs -> n_real_u) {
        jmi_log_comment(jmi->log, logError, "Failed to set the input derivative, too many inputs.");
        return fmiError;
    }
    
    for (i = 0; i < nvr; i++) {
        if (order[i] < 1 || order[i] > FMI1_CS_MAX_INPUT_DERIVATIVES) {
            jmi_log_node(jmi->log, logError, "SetInputDerivativeFailed", "<Failed to set the input derivative, un-supported order:> order:%d",order[i]);
            return fmiError;
        }
        found_input = fmiFalse;
        
        /* Check if there exists an active input with the value reference vr[i] */
        for (j = 0; j < fmi1_cs -> n_real_u; j++) {
            if (fmi1_cs->inputs[j].vr == vr[i] && fmi1_cs -> inputs[j].active == fmiTrue) {
                fmi1_cs -> inputs[j].input_derivatives[order[i]-1] = value[i];
                found_input = fmiTrue;
                break;
            }
        }
        
        /* Found an active input, continue */
        if (found_input == fmiTrue) {
            continue;
        }
        
        /* No active input found, active an available */
        for (j = 0; j < fmi1_cs -> n_real_u; j++) {
            if (fmi1_cs -> inputs[j].active == fmiFalse) {
                fmi1_cs_init_input_struct(&(fmi1_cs -> inputs[j]));
                fmi1_cs -> inputs[j].active = fmiTrue;
                fmi1_cs -> inputs[j].input_derivatives[order[i]-1] = value[i];
                fmi1_cs -> inputs[j].vr = vr[i];
                
                found_input = fmiTrue;
                break;
            }
        }
        
        /* No available inputs -> the user has set an input which is not an input */
        if (found_input == fmiFalse) {
            jmi_log_comment(jmi->log, logError, "Failed to set the input derivative, inconsistent number of inputs.");
            return fmiError;
        }
        
        /*
        for (j = 0; j < fmi1_cs -> n_real_u; j++) {
            if (fmi1_cs->inputs[j].vr == vr[i]) {
                if (fmi1_cs -> inputs[j].active == fmiFalse) {
                    fmi1_cs_init_input_struct(&(fmi1_cs -> inputs[j]));
                    fmi1_cs -> inputs[j].active = fmiTrue;
                }
                fmi1_cs -> inputs[j].input_derivatives[order[i]-1] = value[i];
                break;
            }
        }
        */
    }
    
    return fmiOK;
}

fmiStatus fmi1_cs_init_input_struct(fmi1_cs_input_t* value) {
    fmiInteger i = 0;
    fmiReal fac[FMI1_CS_MAX_INPUT_DERIVATIVES] = {1,2,6};
    
    value -> active = fmiFalse;
    value -> tn     = 0.0;
    value -> input  = 0.0;
    
    for (i = 0; i < FMI1_CS_MAX_INPUT_DERIVATIVES; i++) {
        value -> input_derivatives[i] = 0.0;
        value -> input_derivatives_factor[i] = fac[i];
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

int fmi1_cs_rhs_fcn(void* c, jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs){
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    
    /* Set the states */
    retval = fmi1_me_set_continuous_states(fmi1_cs->fmi1_me, (fmiReal*)y, fmi1_cs->n_real_x);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi1_cs_set_time(c, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the inputs */
    retval = fmi1_cs_set_input(c, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Evaluate the derivatives */
    if (fmi1_cs->n_real_x > 0) {
        retval = fmi1_me_get_derivatives(fmi1_cs->fmi1_me, (fmiReal*)rhs , fmi1_cs->n_real_x);
        if (retval != fmiOK) {
            return -1;
        }
    }else{
        rhs[0] = 0.0;
    }
    
    return 0;
}

int fmi1_cs_root_fcn(void* c, jmi_real_t t, jmi_real_t *y, jmi_real_t *root){
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    
    retval = fmi1_me_set_continuous_states(fmi1_cs->fmi1_me, (fmiReal*)y, fmi1_cs->n_real_x);
    if (retval != fmiOK) {
        return -1;
    }
    
    retval = fmi1_cs_set_time(c, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the inputs */
    retval = fmi1_cs_set_input(c, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    retval = fmi1_me_get_event_indicators(fmi1_cs->fmi1_me, (fmiReal*)root , fmi1_cs->n_sw);
    if (retval != fmiOK) {
        return -1;
    }
    
    return 0;
}

fmiStatus fmi1_cs_set_input(fmiComponent c, fmiReal time) {
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmiStatus retval;
    fmiReal value;
    fmiInteger i,j;
    
    for (i = 0; i < fmi1_cs -> n_real_u; i++) {
        if (fmi1_cs->inputs[i].active == fmiFalse) {
            continue;
        }
        value = fmi1_cs -> inputs[i].input;
        for (j = 0; j < FMI1_CS_MAX_INPUT_DERIVATIVES; j++) {
            value += pow((time - fmi1_cs -> inputs[i].tn),j+1.0) * (fmi1_cs -> inputs[i].input_derivatives[j]) / 
                                    (fmi1_cs -> inputs[i].input_derivatives_factor[j]);
        }
        
        retval = fmi1_me_set_real(fmi1_cs->fmi1_me, &(fmi1_cs -> inputs[i].vr), 1, &value);
        if (retval != fmiOK) {
            return fmiError;
        }
    }
    return fmiOK;
}

fmiStatus fmi1_cs_set_time(fmiComponent c, fmiReal time){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    int retval;
    
    retval = fmi1_me_set_time(fmi1_cs->fmi1_me, time);
    if (retval != fmiOK) {
        return fmiError;
    }
    fmi1_cs->time = time;
    
    return fmiOK;
}

fmiStatus fmi1_cs_get_time(fmiComponent c, fmiReal* value){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    *value = fmi1_cs->time;
    return fmiOK;
}

fmiStatus fmi1_cs_completed_integrator_step(fmiComponent c, fmiBoolean* step_event){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    int retval;
    
    retval = fmi1_me_completed_integrator_step(fmi1_cs->fmi1_me, step_event);
    if (retval != fmiOK) {
        return fmiError;
    }
    
    return fmiOK;
}


jmi_log_t* fmi1_cs_get_jmi_t_log(fmi1_cs_t* fmi1_cs) {
    fmi_t* fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    jmi_t* jmi = fmi1_me->jmi;
    return jmi->log;
}

/*
fmiStatus fmi_save_state(fmiComponent c, size_t index){
    return fmiError;
}

fmiStatus fmi_restore_state(fmiComponent c, size_t index){
    return fmiError;
}
*/
