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
#include "fmi_cs.h" 
#include "fmi.h"
#include "jmi_ode_solver.h"

const char* fmi1_cs_get_types_platform() {
    return fmiPlatform;
}

const char* fmi1_cs_get_version() {
    return fmi_get_version();
}

fmiStatus fmi1_cs_set_debug_logging(fmiComponent c, fmiBoolean loggingOn){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmi1_cs -> logging_on = loggingOn;     
    
    return fmi_set_debug_logging(fmi1_cs->fmi1_me,loggingOn);
}


fmiStatus fmi1_cs_do_step(fmiComponent c,
						 fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep) {
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmi_t* fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    jmi_t* jmi = fmi1_me->jmi;
    
    int flag, retval = JMI_ODE_EVENT;
    int reInitialize = JMI_FALSE;
    fmiReal tfinal = currentCommunicationPoint+communicationStepSize;
    fmiReal ttarget;
    
    jmi->ode_solver->tout = currentCommunicationPoint;
    
    /* Check if there are upcoming time events. */
    if (fmi1_cs->event_info.upcomingTimeEvent == fmiTrue){
        if(fmi1_cs->event_info.nextEventTime < tfinal){
            ttarget = fmi1_cs->event_info.nextEventTime;
        }else{
            ttarget = tfinal;
        }
    }else{
        ttarget = tfinal;
    }
    
    while (retval == JMI_ODE_EVENT && jmi->ode_solver->tout < tfinal){
    
        retval = jmi->ode_solver->solve(jmi->ode_solver, ttarget,reInitialize);
        if (retval==JMI_ODE_OK && ttarget == tfinal) {break;}
        if (retval<JMI_ODE_OK){
            jmi_log_comment(jmi->log, logError, "Failed to perform a step.");
            return fmiError;
        }
        
        flag = fmi_event_update(fmi1_cs->fmi1_me, fmiFalse, &(fmi1_cs->event_info));
        if (flag != fmiOK){
            jmi_log_comment(jmi->log, logError, "<Failed to handle the event.>");
            return fmiError;
        }
        
        /* Check if there are upcoming time events. */
        if (fmi1_cs->event_info.upcomingTimeEvent == fmiTrue){
            if(fmi1_cs->event_info.nextEventTime < tfinal){
                ttarget = fmi1_cs->event_info.nextEventTime;
            }else{
                ttarget = tfinal;
            }
        }else{
            ttarget = tfinal;
        }
        
        /* EVENT HANDLED, REINITIALIZE */
        reInitialize = JMI_TRUE;
    }
    
    return fmiOK;
}

void fmi1_cs_free_slave_instance(fmiComponent c) {
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmi_t* fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    jmi_t* jmi = fmi1_me->jmi;
    
    if (jmi->ode_solver){
        jmi_delete_ode_solver(jmi);
    }
    fmi_free_model_instance(fmi1_cs->fmi1_me);
    
    if (fmi1_cs) {
        fmiCallbackFreeMemory fmi_free = fmi1_cs -> callback_functions.freeMemory;

        fmi_free((void*)fmi1_cs -> instance_name);
        fmi_free((void*)fmi1_cs -> encoded_instance_name);
        fmi_free((void*)fmi1_cs -> GUID);
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
    fmiCallbackFunctions *tmp_callbacks;
    size_t inst_name_len;
    size_t guid_len;
    char buffer[400];
    
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
    
    component -> fmi1_me = fmi_instantiate_model(component -> encoded_instance_name, GUID, component -> me_callback_functions, loggingOn);
    
    if (component -> fmi1_me == NULL){
        return NULL;
    }
    
    /* NEEDS TO COME FROM OUTSIDE, FROM THE XML FILE*/
    component -> n_real_x = ((fmi_t*)component->fmi1_me)->jmi->n_real_x;
    component -> n_sw = ((fmi_t*)component->fmi1_me)->jmi->n_sw;
    
    return (fmiComponent)component;
}


fmiStatus fmi1_cs_terminate_slave(fmiComponent c) {
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    
    return fmi_terminate(fmi1_cs->fmi1_me);
}

fmiStatus fmi1_cs_initialize_slave(fmiComponent c, fmiReal tStart,
                                    fmiBoolean StopTimeDefined, fmiReal tStop){
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmi_t* fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    
    fmiBoolean toleranceControlled = fmiTrue;
    fmiReal relativeTolerance = 1e-6;
    jmi_ode_solvers_t solver = JMI_ODE_CVODE;
    fmiStatus retval;
                                        
    retval = fmi_initialize(fmi1_cs->fmi1_me, toleranceControlled, relativeTolerance, &(fmi1_cs->event_info));
    if (retval != fmiOK){ return fmiError; }
    
    /* Create solver */
    jmi_new_ode_solver(fmi1_me->jmi, solver, rhs_fcn, root_fcn, fmi1_cs->n_real_x, fmi1_cs->n_sw, tStart, (void*)fmi1_cs);
    
    return fmiOK;
}

fmiStatus fmi1_cs_cancel_step(fmiComponent c){
    return fmiError;
}

fmiStatus fmi1_cs_reset_slave(fmiComponent c) {
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    fmi_t* fmi1_me = (fmi_t*)(fmi1_cs->fmi1_me);
    jmi_t* jmi = fmi1_me->jmi;
    
    retval = fmi1_cs_terminate_slave(c);
    if (retval != fmiOK){ return fmiError; }
    
    if (jmi->ode_solver){
        jmi_delete_ode_solver(jmi);
    }
    
    fmi_free_model_instance(fmi1_cs->fmi1_me);
    fmi1_cs->fmi1_me = NULL;
    
    fmi1_cs -> fmi1_me = fmi_instantiate_model(fmi1_cs->encoded_instance_name, fmi1_cs->GUID, fmi1_cs->me_callback_functions, fmi1_cs->logging_on);
    
    if (fmi1_cs->fmi1_me == NULL){ return fmiError; }
    
    return fmiOK;
}

fmiStatus fmi1_cs_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]){
    return fmi_set_real(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]){
    return fmi_set_integer(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]){
    return fmi_set_boolean(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]){
    return fmi_set_string(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]){
    return fmi_get_real(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]){
    return fmi_get_integer(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]){
    return fmi_get_boolean(((fmi1_cs_t *)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]){
    return fmi_get_string(((fmi1_cs_t*)c)->fmi1_me,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]){
    return fmiError;
}

fmiStatus fmi1_cs_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]){
    return fmiError;
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

int rhs_fcn(void* c, jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs){
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    
    retval = fmi_set_continuous_states(fmi1_cs->fmi1_me, (fmiReal*)y, fmi1_cs->n_real_x);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_set_time(fmi1_cs->fmi1_me, t);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_get_derivatives(fmi1_cs->fmi1_me, (fmiReal*)rhs , fmi1_cs->n_real_x);
    if (retval != fmiOK){return -1;}
    
    return 0;
}

int root_fcn(void* c, jmi_real_t t, jmi_real_t *y, jmi_real_t *root){
    fmiStatus retval;
    fmi1_cs_t* fmi1_cs = (fmi1_cs_t*)c;
    
    retval = fmi_set_continuous_states(fmi1_cs->fmi1_me, (fmiReal*)y, fmi1_cs->n_real_x);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_set_time(fmi1_cs->fmi1_me, t);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_get_event_indicators(fmi1_cs->fmi1_me, (fmiReal*)root , fmi1_cs->n_sw);
    if (retval != fmiOK){return -1;}
    
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
