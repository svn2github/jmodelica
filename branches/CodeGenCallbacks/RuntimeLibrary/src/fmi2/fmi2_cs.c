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

#include "stdio.h"
#include "fmi2_me.h"
#include "fmi2_cs.h"
#include "fmiFunctionTypes.h"


fmiStatus fmi2_set_real_input_derivatives(fmiComponent c, 
                                          const fmiValueReference vr[],
                                          size_t nvr, const fmiInteger order[],
                                          const fmiReal value[]) {
    fmi2_cs_t* fmi2_cs = (fmi2_cs_t*)c;
    jmi_ode_problem_t* ode_problem = fmi2_cs -> ode_problem;
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

fmiStatus fmi2_get_real_output_derivatives(fmiComponent c,
                                           const fmiValueReference vr[],
                                           size_t nvr, const fmiInteger order[],
                                           fmiReal value[]) {
    return fmiError;
}

fmiStatus fmi2_do_step(fmiComponent c, fmiReal currentCommunicationPoint,
                       fmiReal    communicationStepSize,
                       fmiBoolean noSetFMUStatePriorToCurrentPoint) {
    
    fmi2_cs_t* fmi2_cs;
    jmi_ode_problem_t* ode_problem;
    jmi_cs_input_t* inputs;
    int flag;
	fmiReal time_event;
    fmiInteger i;

	int initialize = FALSE;
	int retval = JMI_ODE_EVENT;
    fmiReal time_final = currentCommunicationPoint + communicationStepSize;

    
    if (c == NULL) {
		return fmiFatal;
    }

	if (((fmi2_me_t*)c)->fmi_mode != slaveInitialized) {
		jmi_log_comment(((fmi2_me_t *)c)->jmi.log, logError, "Can only do a step if the model is an initialized slave.");
        return fmiError;
	}
    
    fmi2_cs = (fmi2_cs_t*)c;
    ode_problem = fmi2_cs -> ode_problem;
    
    /* For the active inputs, get the initialize input */
    inputs = ode_problem->inputs;
    for (i = 0; i < ode_problem -> n_real_u; i++) {
        if (inputs[i].active == fmiTrue) {
            inputs[i].tn = ode_problem->time;
            flag = fmi2_get_real(ode_problem ->fmix_me, &(inputs[i].vr), 1, &(inputs[i].input));
            if (flag != fmiOK) {
                jmi_log_comment(ode_problem->log, logError, "Failed to get the initial inputs.");
                return fmiError;
            }
        }
    }
    
    while (retval == JMI_ODE_EVENT && ode_problem->time < time_final) {

        while (fmi2_cs->event_info.newDiscreteStatesNeeded) {
            flag = fmi2_new_discrete_state(ode_problem->fmix_me, &(fmi2_cs->event_info));
            initialize = TRUE; /* Event detected, need to initialize the ODE problem. */

            if (flag != fmiOK) {
            jmi_log_comment(ode_problem->log, logError, "Failed to handle the event.");
                return fmiError;
            }
        }
        
        /* We need the values of the continuous states to initialize, no need to check 'valuesOfContinuousStatesChanged'. */
        if (initialize) {
            flag = fmi2_get_continuous_states(ode_problem->fmix_me, ode_problem->states, ode_problem->n_real_x);
            
            if (flag != fmiOK) {
                jmi_log_node(ode_problem->log, logError, "Error", "Failed to get the continuous states.");
                return fmiError;
            }
        }
        
        /* Check if the nominal values have changed. */
        if (fmi2_cs->event_info.nominalsOfContinuousStatesChanged) {
            flag = fmi2_get_nominals_of_continuous_states(ode_problem->fmix_me, ode_problem->nominal, ode_problem->n_real_x);
            if (flag != fmiOK) {
                jmi_log_node(ode_problem->log, logError, "Error", "Failed to get the nominal states.");
                return fmiError;
            }
            fmi2_cs->event_info.nominalsOfContinuousStatesChanged = fmiFalse;
        }
        
        /* Check if there are upcoming time events. */
        if (fmi2_cs->event_info.nextEventTimeDefined) {
            if(fmi2_cs->event_info.nextEventTime < time_final) {
                time_event = fmi2_cs->event_info.nextEventTime;
            } else {
                time_event = time_final;
            }
        } else {
            time_event = time_final;
        }
        
        retval = ode_problem->ode_solver->solve(ode_problem->ode_solver, time_event, initialize);
        initialize = FALSE; /* The ODE problem has been initialized. */

        if (retval < JMI_ODE_OK) {
            jmi_log_comment(ode_problem->log, logError, "Failed to perform a step.");
            return fmiError;
        } else if (retval == JMI_ODE_EVENT) {
            fmi2_cs->event_info.newDiscreteStatesNeeded = fmiTrue; /* Finnished with an event -> new discrete states needed. */
        }
    }
    
    /* De-activate inputs as they are no longer valid */
    for (i = 0; i < ode_problem -> n_real_u; i++) {
        inputs[i].active = fmiFalse;
    }
    
    return fmiOK;
}

fmiStatus fmi2_cancel_step(fmiComponent c) {
    return fmiOK;
}

fmiStatus fmi2_get_status(fmiComponent c, const fmiStatusKind s,
                          fmiStatus* value) {
    return fmiDiscard;
}

fmiStatus fmi2_get_real_status(fmiComponent c, const fmiStatusKind s,
                               fmiReal* value) {
    return fmiDiscard;
}

fmiStatus fmi2_get_integer_status(fmiComponent c, const fmiStatusKind s,
                                  fmiInteger* values) {
    return fmiDiscard;
}

fmiStatus fmi2_get_boolean_status(fmiComponent c, const fmiStatusKind s,
                                  fmiBoolean* value) {
    return fmiDiscard;
}


fmiStatus fmi2_get_string_status(fmiComponent c, const fmiStatusKind s,
                                 fmiString* value) {
    return fmiDiscard;
}

/* Helper method for fmi2_instantiate*/
fmiStatus fmi2_cs_instantiate(fmiComponent c,
                              fmiString    instanceName,
                              fmiType      fmuType, 
                              fmiString    fmuGUID, 
                              fmiString    fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn) {
    fmiStatus retval;
    fmi2_cs_t* fmi2_cs;
    jmi_t* jmi;
    jmi_ode_problem_t* ode_problem = 0;
    
    retval = fmi2_me_instantiate(c, instanceName, fmuType, fmuGUID, 
                                fmuResourceLocation, functions, visible,
                                loggingOn);
    if (retval != fmiOK) {
        return retval;
    }
    
    jmi = &((fmi2_me_t*)c) -> jmi;
    fmi2_cs = (fmi2_cs_t*)c;
    
    jmi_new_ode_problem(&ode_problem, &jmi->jmi_callbacks, c, jmi->n_real_x, jmi->n_sw, jmi->n_real_u, jmi->log);
    fmi2_cs -> ode_problem = ode_problem;
    
    return fmiOK;
}

/* Helper method for fmi2_free_instance. */
void fmi2_cs_free_instance(fmiComponent c) {
    jmi_free_ode_problem(((fmi2_cs_t*)c) -> ode_problem);
	fmi2_me_free_instance(c);
}

int fmi2_cs_rhs_fcn(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs){
    fmiStatus retval;
    
    /* Set the states */
    retval = fmi2_set_continuous_states(ode_problem->fmix_me, (fmiReal*)y, ode_problem->n_real_x);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi2_set_time(ode_problem->fmix_me, t);
    if (retval != fmiOK) {
        return -1;
    }
	ode_problem->time = t;
    
    /* Set the inputs */
    retval = fmi2_cs_set_input(ode_problem, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Evaluate the derivatives */
    if (ode_problem->n_real_x > 0) {
        retval = fmi2_get_derivatives(ode_problem->fmix_me, (fmiReal*)rhs , ode_problem->n_real_x);
        if (retval != fmiOK) {
            return -1;
        }
    }else{
        rhs[0] = 0.0;
    }
    
    return 0;
}

int fmi2_cs_root_fcn(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t *y, jmi_real_t *root){
    fmiStatus retval;
    
    retval = fmi2_set_continuous_states(ode_problem->fmix_me, (fmiReal*)y, ode_problem->n_real_x);
    if (retval != fmiOK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi2_set_time(ode_problem->fmix_me, t);
    if (retval != fmiOK) {
        return -1;
    }
    ode_problem->time = t;
    
    /* Set the inputs */
    retval = fmi2_cs_set_input(ode_problem, t);
    if (retval != fmiOK) {
        return -1;
    }
    
    retval = fmi2_get_event_indicators(ode_problem->fmix_me, (fmiReal*)root , ode_problem->n_sw);
    if (retval != fmiOK) {
        return -1;
    }
    
    return 0;
}

fmiStatus fmi2_cs_set_input(jmi_ode_problem_t* ode_problem, fmiReal time) {
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
        
        retval = fmi2_set_real(ode_problem->fmix_me, &(inputs[i].vr), 1, &value);
        if (retval != fmiOK) {
            return fmiError;
        }
    }
    return fmiOK;
}

int fmi2_cs_completed_integrator_step(jmi_ode_problem_t* ode_problem, char* step_event){
    int retval;

	/* TODO: No support for terminating the Co-Simulation*/
	fmiBoolean* terminateSimulation = (fmiBoolean*)calloc(1, sizeof(fmiBoolean));
    retval = fmi2_completed_integrator_step(ode_problem->fmix_me, fmiFalse, (fmiBoolean*)step_event, terminateSimulation);
	free(terminateSimulation);
    if (retval != fmiOK) {
        return -1;
    }

    return 0;
}
