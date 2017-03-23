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
#include "fmi2FunctionTypes.h"

/* Forward declarations: */
int fmi2_cs_rhs_fcn(jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs, jmi_ode_sizes_t sizes, void* problem_data);
int fmi2_cs_root_fcn(jmi_real_t t, jmi_real_t *y, jmi_real_t *root, jmi_ode_sizes_t sizes, void* problem_data);
int fmi2_cs_completed_integrator_step(char* step_event, char* terminate, void* problem_data);

fmi2Status fmi2_set_real_input_derivatives(fmi2Component c, 
                                           const fmi2ValueReference vr[],
                                           size_t nvr, const fmi2Integer order[],
                                           const fmi2Real value[]) {
    fmi2_cs_t* fmi2_cs = (fmi2_cs_t*)c;
    jmi_cs_data_t* cs_data = fmi2_cs->cs_data;
    jmi_log_t* log = fmi2_cs->ode_problem->log;
    fmi2Integer retval;
    
    if (c == NULL) {
		return fmi2Fatal;
    }
    
    retval = jmi_cs_set_real_input_derivatives(cs_data, log, vr, nvr, order, value);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_get_real_output_derivatives(fmi2Component c,
                                            const fmi2ValueReference vr[],
                                            size_t nvr, const fmi2Integer order[],
                                            fmi2Real value[]) {
    return fmi2Error;
}

fmi2Status fmi2_do_step(fmi2Component c, fmi2Real currentCommunicationPoint,
                        fmi2Real    communicationStepSize,
                        fmi2Boolean noSetFMUStatePriorToCurrentPoint) {
    
    fmi2_cs_t* fmi2_cs;
    jmi_ode_problem_t* ode_problem;
    jmi_cs_data_t* cs_data;
    jmi_cs_real_input_t* real_inputs;
    int flag;
	fmi2Real time_event;
    size_t i;

	int initialize = FALSE;
	int retval = JMI_ODE_EVENT;
    fmi2Real time_final = currentCommunicationPoint + communicationStepSize;

    
    if (c == NULL) {
		return fmi2Fatal;
    }

	if (((fmi2_me_t*)c)->fmu_mode != slaveInitialized) {
		jmi_log_comment(((fmi2_me_t *)c)->jmi.log, logError, "Can only do a step if the model is an initialized slave.");
        return fmi2Error;
	}

    if (((fmi2_me_t*)c)->stopTime < time_final-JMI_ALMOST_EPS*time_final) {
        jmi_log_node(((fmi2_me_t *)c)->jmi.log, logError, "Error", "Cannot take a step past the <stop_time: %g>. Asked <final_time: %g>.", ((fmi2_me_t*)c)->stopTime);
        return fmi2Error;
    }

    fmi2_cs = (fmi2_cs_t*)c;
    ode_problem = fmi2_cs->ode_problem;
    cs_data = fmi2_cs->cs_data;
    
    /* For the active real inputs, get the current input value */
    real_inputs = cs_data->real_inputs;
    for (i = 0; i < cs_data->n_real_inputs; i++) {
        if (real_inputs[i].active == fmi2True) {
            real_inputs[i].tn = ode_problem->time;
            flag = fmi2_get_real(cs_data->fmix_me, &(real_inputs[i].vr),
                                 1, &(real_inputs[i].value));
            if (flag != fmi2OK) {
                jmi_log_comment(ode_problem->log, logError,
                    "Failed to get the current value of real inputs.");
                return fmi2Error;
            }
        }
    }
    
    while (retval == JMI_ODE_EVENT && ode_problem->time+JMI_ALMOST_EPS*time_final < time_final) {

        while (fmi2_cs->event_info.newDiscreteStatesNeeded ||
               fmi2_cs->cs_data->triggered_external_event)
        {
            flag = fmi2_new_discrete_state(cs_data->fmix_me, &(fmi2_cs->event_info));
            initialize = TRUE; /* Event detected, need to initialize the ODE problem. */

            if (flag != fmi2OK) {
                jmi_log_comment(ode_problem->log, logError, "Failed to handle the event.");
                return fmi2Error;
            }
            
            fmi2_cs->cs_data->triggered_external_event = FALSE;
        }
        
        /* Check if the simulation should be terminated. */
        if (fmi2_cs->event_info.terminateSimulation) {
            jmi_log_node(ode_problem->log, logInfo, "Terminate", "Terminating simulation after a signal from the model at <t:%E>.", ode_problem->time);
            return fmi2Discard;
        }
        
        /* We need the values of the continuous states to initialize, no need to check 'valuesOfContinuousStatesChanged'. */
        if (initialize) {
            flag = fmi2_get_continuous_states(cs_data->fmix_me, ode_problem->states, ode_problem->sizes.states);
            
            if (flag != fmi2OK) {
                jmi_log_node(ode_problem->log, logError, "Error", "Failed to get the continuous states.");
                return fmi2Error;
            }
        }
        
        /* Check if the nominal values have changed. */
        if (fmi2_cs->event_info.nominalsOfContinuousStatesChanged) {
            flag = fmi2_get_nominals_of_continuous_states(cs_data->fmix_me, ode_problem->nominals, ode_problem->sizes.states);
            if (flag != fmi2OK) {
                jmi_log_node(ode_problem->log, logError, "Error", "Failed to get the nominal states.");
                return fmi2Error;
            }
            fmi2_cs->event_info.nominalsOfContinuousStatesChanged = fmi2False;
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
        
        retval = jmi_ode_solver_solve(ode_problem->ode_solver, time_event, initialize);
        initialize = FALSE; /* The ODE problem has been initialized. */
        
        /* Set time to the model */
        flag = fmi2_set_time(cs_data->fmix_me, ode_problem->time);
        if (flag != fmi2OK) {
            jmi_log_node(ode_problem->log, logError, "Error", "Failed to set the time.");
            return fmi2Error;
        }
        
        /* Set states to the model */
        flag = fmi2_set_continuous_states(cs_data->fmix_me, ode_problem->states, ode_problem->sizes.states);
        if (flag != fmi2OK) {
            jmi_log_node(ode_problem->log, logError, "Error", "Failed to set the continuous states.");
            return fmi2Error;
        }

        if (retval < JMI_ODE_OK) {
            jmi_log_comment(ode_problem->log, logError, "Failed to perform a step.");
            return fmi2Error;
        } else if (retval == JMI_ODE_EVENT || 
                  (retval == JMI_ODE_OK && time_event != time_final) ||
                  (retval == JMI_ODE_OK && fmi2_cs->event_info.nextEventTimeDefined && fmi2_cs->event_info.nextEventTime == time_final)) {
            fmi2_cs->event_info.newDiscreteStatesNeeded = fmi2True; /* Finished with an event -> new discrete states needed. */
            retval = JMI_ODE_EVENT;
        }
    }
    
    /* De-activate real inputs as they are no longer valid */
    for (i = 0; i < cs_data -> n_real_inputs; i++) {
        real_inputs[i].active = fmi2False;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_cancel_step(fmi2Component c) {
    return fmi2OK;
}

fmi2Status fmi2_get_status(fmi2Component c, const fmi2StatusKind s,
                           fmi2Status* value) {
    return fmi2Discard;
}

fmi2Status fmi2_get_real_status(fmi2Component c, const fmi2StatusKind s,
                                fmi2Real* value) {
    fmi2_cs_t* fmi2_cs = (fmi2_cs_t*)c;
    jmi_ode_problem_t* ode_problem = fmi2_cs -> ode_problem;
    
    if (s == fmi2LastSuccessfulTime) {
        *value = ode_problem->time;
        return fmi2OK;
    }
    return fmi2Discard;
}

fmi2Status fmi2_get_integer_status(fmi2Component c, const fmi2StatusKind s,
                                   fmi2Integer* values) {
    return fmi2Discard;
}

fmi2Status fmi2_get_boolean_status(fmi2Component c, const fmi2StatusKind s,
                                   fmi2Boolean* value) {
    return fmi2Discard;
}


fmi2Status fmi2_get_string_status(fmi2Component c, const fmi2StatusKind s,
                                  fmi2String* value) {
    return fmi2Discard;
}

/* Helper method for fmi2_instantiate */
fmi2Status fmi2_cs_instantiate(fmi2Component c,
                               fmi2String    instanceName,
                               fmi2Type      fmuType, 
                               fmi2String    fmuGUID, 
                               fmi2String    fmuResourceLocation, 
                               const fmi2CallbackFunctions* functions, 
                               fmi2Boolean                  visible,
                               fmi2Boolean                  loggingOn) {
    fmi2Status retval;
    fmi2_cs_t* fmi2_cs;
    jmi_t* jmi;
    jmi_ode_callbacks_t ode_callbacks;
    jmi_ode_sizes_t ode_sizes;
    
    retval = fmi2_me_instantiate(c, instanceName, fmuType, fmuGUID, 
                                 fmuResourceLocation, functions, visible,
                                 loggingOn);
    if (retval != fmi2OK) {
        return retval;
    }
    
    jmi = &((fmi2_me_t*)c) -> jmi;
    fmi2_cs = (fmi2_cs_t*)c;
    
    ode_callbacks = jmi_ode_problem_default_callbacks();
    ode_callbacks.rhs_func = fmi2_cs_rhs_fcn;
    ode_callbacks.root_func = fmi2_cs_root_fcn;
    ode_callbacks.complete_step_func = fmi2_cs_completed_integrator_step;
    ode_sizes.states = jmi->n_real_x;
    ode_sizes.root_fnc = jmi->n_relations;
    fmi2_cs->cs_data = jmi_new_cs_data(c, jmi->n_real_u);
    fmi2_cs -> ode_problem = jmi_new_ode_problem(&jmi->jmi_callbacks,
        fmi2_cs->cs_data, ode_callbacks, ode_sizes, jmi->log);
    
    return fmi2OK;
}

/* Helper method for fmi2_free_instance. */
void fmi2_cs_free_instance(fmi2Component c) {
    jmi_free_ode_solver(((fmi2_cs_t *)c)->ode_problem->ode_solver);
    jmi_free_ode_problem(((fmi2_cs_t*)c)->ode_problem);
    jmi_free_cs_data(((fmi2_cs_t*)c)->cs_data);
    fmi2_me_free_instance(c);
}

fmi2Status fmi2_cs_set_real_inputs(jmi_cs_data_t* cs_data, fmi2Real time) {
    jmi_cs_real_input_t* real_inputs;
    fmi2Status retval;
    fmi2Real value;
    fmi2Integer i,j;
    
    real_inputs = cs_data->real_inputs;
    for (i = 0; i < cs_data->n_real_inputs; i++) {
        if (real_inputs[i].active == fmi2False) {
            continue;
        }
        value = real_inputs[i].value;
        for (j = 0; j < JMI_CS_MAX_INPUT_DERIVATIVES; j++) {
            value += pow((time - real_inputs[i].tn), j + 1.0) *
                     real_inputs[i].input_derivatives[j] / 
                     real_inputs[i].input_derivatives_factor[j];
        }
        
        retval = fmi2_set_real(cs_data->fmix_me, &(real_inputs[i].vr),
                               1, &value);
        if (retval != fmi2OK) {
            return fmi2Error;
        }
    }
    return fmi2OK;
}

int fmi2_cs_rhs_fcn(jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs, jmi_ode_sizes_t sizes, void* problem_data){
    fmi2Status retval;
    jmi_cs_data_t* cs_data = (jmi_cs_data_t*)problem_data;
    
    /* Set the states */
    retval = fmi2_set_continuous_states(cs_data->fmix_me, y, sizes.states);
    if (retval != fmi2OK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi2_set_time(cs_data->fmix_me, t);
    if (retval != fmi2OK) {
        return -1;
    }
    
    /* Set the inputs */
    retval = fmi2_cs_set_real_inputs(cs_data, t);
    if (retval != fmi2OK) {
        return -1;
    }
    
    /* Evaluate the derivatives */
    if (sizes.states > 0) {
        retval = fmi2_get_derivatives(cs_data->fmix_me, rhs, sizes.states);
        if (retval != fmi2OK) {
            return -1;
        }
    }
    
    return 0;
}

int fmi2_cs_root_fcn(jmi_real_t t, jmi_real_t *y, jmi_real_t *root, jmi_ode_sizes_t sizes, void* problem_data){
    fmi2Status retval;
    jmi_cs_data_t* cs_data = (jmi_cs_data_t*)problem_data;
    
    retval = fmi2_set_continuous_states(cs_data->fmix_me, y, sizes.states);
    if (retval != fmi2OK) {
        return -1;
    }
    
    /* Set the time */
    retval = fmi2_set_time(cs_data->fmix_me, t);
    if (retval != fmi2OK) {
        return -1;
    }
    
    /* Set the inputs */
    retval = fmi2_cs_set_real_inputs(cs_data, t);
    if (retval != fmi2OK) {
        return -1;
    }
    
    retval = fmi2_get_event_indicators(cs_data->fmix_me, root, sizes.root_fnc);
    if (retval != fmi2OK) {
        return -1;
    }
    
    return 0;
}

int fmi2_cs_completed_integrator_step(char* step_event, char* terminate, void* problem_data) {
    int retval;
    jmi_cs_data_t* cs_data = (jmi_cs_data_t*)problem_data;

	fmi2Boolean tmp_terminate_simulation;
    fmi2Boolean tmp_step_event;
    retval = fmi2_completed_integrator_step(cs_data->fmix_me, fmi2False, &tmp_step_event, &tmp_terminate_simulation);
    step_event[0] = (char) tmp_step_event;
    terminate[0] = (char) tmp_terminate_simulation;

    if (retval != fmi2OK) {
        return -1;
    }
    
    return 0;
}
