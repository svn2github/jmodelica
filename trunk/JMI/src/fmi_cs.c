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
    return fmi_set_debug_logging(c,loggingOn);
}


fmiStatus fmi1_cs_do_step(fmiComponent c,
						 fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep) {
    fmi_t* fmi = (fmi_t *)c;
    jmi_t* jmi = fmi->jmi;
    int flag, retval = JMI_ODE_EVENT;
    int reInitialize = JMI_FALSE;
    fmiReal tfinal = currentCommunicationPoint+communicationStepSize;
    fmiReal ttarget;
    jmi->ode_solver->tout = currentCommunicationPoint;
    
    /* Check if there are upcoming time events. */
    if (fmi->event_info.upcomingTimeEvent == fmiTrue){
        if(fmi->event_info.nextEventTime < tfinal){
            ttarget = fmi->event_info.nextEventTime;
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
            jmi_log_error(jmi, "Failed to perform a step.");
            return fmiError;
        }
        
        flag = fmi_event_update(c, fmiFalse, &(fmi->event_info));
        if (flag != fmiOK){
            jmi_log_error(jmi, "Failed to handle the event.");
            return fmiError;
        }
        
        /* Check if there are upcoming time events. */
        if (fmi->event_info.upcomingTimeEvent == fmiTrue){
            if(fmi->event_info.nextEventTime < tfinal){
                ttarget = fmi->event_info.nextEventTime;
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
    fmi_t* fmi = (fmi_t *)c;
    jmi_t* jmi = fmi->jmi;
    
    if (jmi->ode_solver){
        jmi_delete_ode_solver(jmi);
    }
    fmi_free_model_instance(c);
    return;
}

fmiComponent fmi1_cs_instantiate_slave(fmiString instanceName, fmiString GUID, fmiString fmuLocation, fmiString mimeType, 
                                   fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiCallbackFunctions functions, 
                                   fmiBoolean loggingOn) {
    return fmi_instantiate_model(instanceName, GUID, functions, loggingOn);
}


fmiStatus fmi1_cs_terminate_slave(fmiComponent c) {
    return fmi_terminate(c);
}

fmiStatus fmi1_cs_initialize_slave(fmiComponent c, fmiReal tStart,
                                    fmiBoolean StopTimeDefined, fmiReal tStop){
    fmi_t* fmi = (fmi_t *)c;
    fmiBoolean toleranceControlled = fmiTrue;
    fmiReal relativeTolerance = 1e-6;
    jmi_ode_solvers_t solver = JMI_ODE_CVODE;
    fmiStatus retval;
                                        
    retval = fmi_initialize(c, toleranceControlled, relativeTolerance, &(fmi->event_info));
    if (retval != fmiOK){ return fmiError; }
    
    /* Create solver */
    jmi_new_ode_solver(fmi->jmi, solver, rhs_fcn, root_fcn);
    
    return fmiOK;
}

fmiStatus fmi1_cs_cancel_step(fmiComponent c){
    return fmiError;
}

fmiStatus fmi1_cs_reset_slave(fmiComponent c) {
    return fmiError;
}

fmiStatus fmi1_cs_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]){
    return fmi_set_real(c,vr,nvr,value);
}

fmiStatus fmi1_cs_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]){
    return fmi_set_integer(c,vr,nvr,value);
}

fmiStatus fmi1_cs_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]){
    return fmi_set_boolean(c,vr,nvr,value);
}

fmiStatus fmi1_cs_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]){
    return fmi_set_string(c,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]){
    return fmi_get_real(c,vr,nvr,value);
}

fmiStatus fmi1_cs_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]){
    return fmi_get_integer(c,vr,nvr,value);
}

fmiStatus fmi1_cs_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]){
    return fmi_get_boolean(c,vr,nvr,value);
}

fmiStatus fmi1_cs_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]){
    return fmi_get_string(c,vr,nvr,value);
}

fmiStatus fmi1_cs_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]){
    return fmiError;
}

fmiStatus fmi1_cs_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]){
    return fmiError;
}

fmiStatus fmi1_cs_get_status(fmiComponent c, const fmiStatusKind s, fmiStatus* value){
    return fmiError;
}

fmiStatus fmi1_cs_get_real_status(fmiComponent c, const fmiStatusKind s, fmiReal* value){
    return fmiError;
}

fmiStatus fmi1_cs_get_integer_status(fmiComponent c, const fmiStatusKind s, fmiInteger* value){
    return fmiError;
}

fmiStatus fmi1_cs_get_boolean_status(fmiComponent c, const fmiStatusKind s, fmiBoolean* value){
    return fmiError;
}

fmiStatus fmi1_cs_get_string_status(fmiComponent c, const fmiStatusKind s, fmiString* value){
    return fmiError;
}

int rhs_fcn(void* c, jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs){
    fmiStatus retval;
    fmi_t* fmi = (fmi_t *)c;
    
    retval = fmi_set_continuous_states((fmiComponent)c, (fmiReal*)y, fmi->jmi->n_real_x);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_set_time((fmiComponent)c, t);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_get_derivatives((fmiComponent)c, (fmiReal*)rhs , fmi->jmi->n_real_x);
    if (retval != fmiOK){return -1;}
    
    return 0;
}

int root_fcn(void* c, jmi_real_t t, jmi_real_t *y, jmi_real_t *root){
    fmiStatus retval;
    fmi_t* fmi = (fmi_t *)c;
    
    retval = fmi_set_continuous_states((fmiComponent)c, (fmiReal*)y, fmi->jmi->n_real_x);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_set_time((fmiComponent)c, t);
    if (retval != fmiOK){return -1;}
    
    retval = fmi_get_event_indicators((fmiComponent)c, (fmiReal*)root , fmi->jmi->n_sw);
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
