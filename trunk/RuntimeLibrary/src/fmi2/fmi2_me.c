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
#include "jmi_util.h"
#include "jmi.h"
#include "jmi_ode_problem.h"

#ifdef USE_FMI_ALLOC
#include "fmi_alloc.h"
#endif

const char* fmi2_get_types_platform() {
    return fmiTypesPlatform;
}

const char* fmi2_get_version() {
    return fmiVersion;
}

fmiStatus fmi2_set_debug_logging(fmiComponent    c,
                                 fmiBoolean      loggingOn, 
                                 size_t          nCategories, 
                                 const fmiString categories[]) {
    return fmiOK;
}

fmiComponent fmi2_instantiate(fmiString instanceName,
                              fmiType   fmuType, 
                              fmiString fmuGUID, 
                              fmiString fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn) {
    
    fmiComponent component;
    fmiInteger   retval;
    jmi_t* jmi = 0;
    
    if(!functions->allocateMemory || !functions->freeMemory || !functions->logger) {
         if(functions->logger) {
             /* We have to use the raw logger callback here; the logger in the jmi_t struct is not yet initialized. */
             functions->logger(0, instanceName, fmiError, "ERROR", "Memory management functions allocateMemory/freeMemory are required.");
         }
         return NULL;
    }
    
    /*Allocate memory for the correct struct. */
    if (fmuType == fmiModelExchange) {
        component = (fmiComponent)functions->allocateMemory(1, sizeof(fmi2_me_t));
        retval = fmi2_me_instantiate(component, instanceName, fmuType, fmuGUID, 
                                     fmuResourceLocation, functions, visible,
                                     loggingOn);
        if (retval != fmiOK) {
            functions->freeMemory(component);
            return NULL;
        }

#ifndef FMUME20
        jmi_log_comment(jmi->log, logError, "The model is not compiled as a Co-Simulation FMU.");
        fmi2_free_instance(component);
        return NULL;
#endif

    } else if (fmuType == fmiCoSimulation) {
        component = (fmiComponent)functions->allocateMemory(1, sizeof(fmi2_cs_t));
        retval = fmi2_cs_instantiate(component, instanceName, fmuType, fmuGUID, 
                                     fmuResourceLocation, functions, visible,
                                     loggingOn);
        if (retval != fmiOK) {
            functions->freeMemory(component);
            return NULL;
        }

#ifndef FMUCS20
        jmi_log_comment(jmi->log, logError, "The model is not compiled as a Model Exchange FMU.");
        fmi2_free_instance(component);
        return NULL;
#endif
    }
    
    return component;
}

fmiStatus fmi2_me_instantiate(fmiComponent c,
                              fmiString    instanceName,
                              fmiType      fmuType, 
                              fmiString    fmuGUID, 
                              fmiString    fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn) {
    fmi2_me_t* fmi2_me;
    jmi_t* jmi = 0;
    fmiInteger retval;
    char* tmpname;
    size_t inst_name_len;
        
    fmi2_me = (fmi2_me_t*)c;                              
    retval = jmi_me_instantiate(&jmi, fmi2_me, instanceName, fmuGUID,
                                functions->allocateMemory, functions->freeMemory,
                                (logger_callaback_function_t)functions->logger,
                                loggingOn + '0');
    
    if (retval != 0) {
        return fmiError;
    }
    
    fmi2_me -> fmi_functions = functions;
    /*TODO: Check how fmiFunctions is used, Iakov */
#ifdef USE_FMI_ALLOC
    /* Set the global user functions pointer so that memory allocation functions are intercepted */
    fmiFunctions = &(fmi2_me -> fmi_functions);
#endif
    inst_name_len = strlen(instanceName)+1;
    tmpname = (char*)(fmi2_me_t *)functions->allocateMemory(inst_name_len, sizeof(char));
    strncpy(tmpname, instanceName, inst_name_len);
    fmi2_me -> fmi_instance_name = tmpname;
    
    fmi2_me -> fmu_type = fmuType;
    fmi2_me -> jmi = jmi;
    
    return fmiOK;
}

void fmi2_free_instance(fmiComponent c)  {
    /* Dispose the given model instance and deallocated all the allocated memory and other resources 
     * that have been allocated by the functions of the Model Exchange Interface for instance "c".*/
    fmi2_me_t* fmi2_me;
    fmi2_cs_t* fmi2_cs;
    fmiCallbackFreeMemory fmi_free;
    if (c) {
        fmi2_me = (fmi2_me_t*)c;
        fmi_free = fmi2_me -> fmi_functions->freeMemory;

        jmi_delete(fmi2_me->jmi);
        fmi2_me->jmi = 0;
        fmi_free((void*)fmi2_me -> fmi_instance_name);
        if (fmi2_me->fmu_type == fmiModelExchange) {
            fmi_free(fmi2_me);
        } else if (fmi2_me->fmu_type == fmiModelExchange) {
            fmi2_cs = (fmi2_cs_t*)c;
            jmi_free_ode_problem(fmi2_cs -> ode_problem);
            fmi_free(fmi2_cs);
        }
    }
}

fmiStatus fmi2_setup_experiment(fmiComponent c, 
                                fmiBoolean   toleranceDefined, 
                                fmiReal      tolerance, 
                                fmiReal      startTime, 
                                fmiBoolean   stopTimeDefined, 
                                fmiReal      stopTime) {
    fmiStatus retval;
    
    jmi_setup_experiment(((fmi2_me_t*)c)->jmi, toleranceDefined + '0', tolerance);
    
    retval = fmi2_set_time(c, startTime);
    
    if (((fmi2_me_t*)c)->fmu_type == fmiCoSimulation) {
        /*jmi_init_ode_problem(((fmi2_me_t*)c)->ode_problem, startTime, fmi2_cs_rhs_fcn,
                             fmi2_cs_root_fcn, fmi2_cs_completed_integrator_step);*/
    }
    
    return retval;
}

fmiStatus fmi2_enter_initialization_mode(fmiComponent c) {
    fmiInteger retval;
    jmi_ode_problem_t* ode_problem;
    jmi_ode_method_t ode_method;
    jmi_real_t ode_step_size;
    jmi_real_t ode_rel_tol;
    
    if (((fmi2_me_t *)c)->fmi_mode != instantiatedMode) {
        jmi_log_comment(((fmi2_me_t *)c)->jmi->log, logError, "Can only enter initialization mode after instantiating the model.");
        return fmiError;
    }
    
    retval = jmi_initialize(((fmi2_me_t*)c)->jmi);
    if (retval != 0) {
        return fmiError;
    }
    
    ((fmi2_me_t *)c) -> fmi_mode = initializationMode;
    
    if (((fmi2_me_t *)c) -> fmu_type == fmiCoSimulation) {
        ode_problem = ((fmi2_cs_t *)c) -> ode_problem; 
        /*Get the states, event indicators and the nominals for the ODE problem. Initialization. */
        fmi2_get_continuous_states(ode_problem->fmix_me, ode_problem->states, ode_problem->n_real_x);
        fmi2_get_event_indicators(ode_problem->fmix_me, ode_problem->event_indicators, ode_problem->n_sw);
        fmi2_get_event_indicators(ode_problem->fmix_me, ode_problem->event_indicators_previous, ode_problem->n_sw);
        fmi2_get_nominals_of_continuous_states(ode_problem->fmix_me, ode_problem->nominal, ode_problem->n_real_x);
        
        
        /* These options for the solver need to be found in a better way. */
        ode_method    = ((fmi2_me_t*)c)->jmi->options.cs_solver;
        ode_step_size = ((fmi2_me_t*)c)->jmi->options.cs_step_size;
        ode_rel_tol   = ((fmi2_me_t*)c)->jmi->options.cs_rel_tol;
        
        /* Create solver */
        retval = jmi_new_ode_solver(ode_problem, ode_method, ode_step_size, ode_rel_tol);
        if (retval != fmiOK) { 
            return fmiError;
        }
    }
    
    return fmiOK;
}

fmiStatus fmi2_exit_initialization_mode(fmiComponent c) {
    if (((fmi2_me_t *)c)->fmi_mode != initializationMode) {
        jmi_log_comment(((fmi2_me_t *)c)->jmi->log, logError, "Can only exit initialization mode when being in initialization mode.");
        return fmiError;
    }
    if (((fmi2_me_t *)c)->fmu_type == fmiModelExchange) {
        ((fmi2_me_t *)c)->fmi_mode = eventMode;
    } else {
        //TODO: what happens in the CS case?
    }
    return fmiOK;
}

fmiStatus fmi2_terminate(fmiComponent c) {
    /* Release all resources that have been allocated since fmi_initialize has been called. */
    if (c == NULL) {
		return fmiFatal;
    }
    
    jmi_terminate(((fmi2_me_t *)c)->jmi);
    
    return fmiOK;
}

fmiStatus fmi2_reset(fmiComponent c) {
    return 0;
}

fmiStatus fmi2_get_real(fmiComponent c, const fmiValueReference vr[],
                        size_t nvr, fmiReal value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_real(((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }

    return fmiOK;
}

fmiStatus fmi2_get_integer(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, fmiInteger value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_integer(((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }

    return fmiOK;
}

fmiStatus fmi2_get_boolean(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, fmiBoolean value[]) {
    fmiInteger retval;
    jmi_boolean* casted_values = 0;
    int i;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    casted_values = (jmi_boolean*)calloc(nvr, sizeof(char));
    for (i = 0; i < nvr; i++) {
        casted_values[i] = value[i] + '0';
    }

    retval = jmi_get_boolean(((fmi2_me_t *)c)->jmi, vr, nvr, casted_values);
    if (retval != 0) {
        return fmiError;
    }
    
    for (i = 0; i < nvr; i++) {
        value[i] = casted_values[i] - '0';
    }
    free(casted_values);

    return fmiOK;
}

fmiStatus fmi2_get_string(fmiComponent c, const fmiValueReference vr[],
                          size_t nvr, fmiString value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_string(((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }

    /* Strings not yet supported. */
    return fmiWarning;
}

fmiStatus fmi2_set_real(fmiComponent c, const fmiValueReference vr[],
                        size_t nvr, const fmiReal value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_set_real(((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_set_integer(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, const fmiInteger value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_set_integer(((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_set_boolean(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, const fmiBoolean value[]) {
    fmiInteger retval;
    jmi_boolean* casted_values = 0;
    int i;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    casted_values = (jmi_boolean*)calloc(nvr, sizeof(char));
    for (i = 0; i < nvr; i++) {
        casted_values[i] = value[i] + '0';
    }
    
    retval = jmi_set_boolean(((fmi2_me_t *)c)->jmi, vr, nvr, casted_values);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_set_string(fmiComponent c, const fmiValueReference vr[],
                          size_t nvr, const fmiString value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_set_string(((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    /* Strings not yet supported. */
    return fmiWarning;
}

fmiStatus fmi2_get_fmu_state(fmiComponent c, fmiFMUstate* FMUstate) {
    return fmiError;
}

fmiStatus fmi2_set_fmu_state(fmiComponent c, fmiFMUstate FMUstate) {
    return fmiError;
}

fmiStatus fmi2_free_fmu_state(fmiComponent c, fmiFMUstate* FMUstate) {
    return fmiError;
}

fmiStatus fmi2_serialized_fmu_state_size(fmiComponent c, fmiFMUstate FMUstate,
                                         size_t* size) {
    return fmiError;
}

fmiStatus fmi2_serialized_fmu_state(fmiComponent c, fmiFMUstate FMUstate,
                                    fmiByte serializedState[], size_t size) {
    return fmiError;
}

fmiStatus fmi2_de_serialized_fmu_state(fmiComponent c,
                                       const fmiByte serializedState[],
                                       size_t size, fmiFMUstate* FMUstate) {
    return fmiError;
}

fmiStatus fmi2_get_directional_derivative(fmiComponent c,
                const fmiValueReference vUnknown_ref[], size_t nUnknown,
                const fmiValueReference vKnown_ref[],   size_t nKnown,
                const fmiReal dvKnown[], fmiReal dvUnknown[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_directional_derivative(((fmi2_me_t *)c)->jmi, vUnknown_ref,
                    nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_enter_event_mode(fmiComponent c) {
    if (((fmi2_me_t *)c)->fmi_mode != continuousTimeMode) {
        jmi_log_comment(((fmi2_me_t *)c)->jmi->log, logError, "Can only enter event mode from continuous time mode.");
        return fmiError;
    }
    
    ((fmi2_me_t *)c) -> fmi_mode = eventMode;
    return fmiOK;
}

fmiStatus fmi2_new_discrete_state(fmiComponent  c, fmiEventInfo* fmiEventInfo) {
    fmiInteger retval;
    jmi_event_info_t* event_info;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    event_info = (jmi_event_info_t*)calloc(1, sizeof(jmi_event_info_t));
    
    retval = jmi_event_iteration(((fmi2_me_t *)c)->jmi, FALSE, event_info);
    if (retval != 0) {
        return fmiError;
    }
    
    fmiEventInfo->newDiscreteStatesNeeded           = !(event_info->iteration_converged - '0');
    fmiEventInfo->terminateSimulation               = event_info->terminate_simulation - '0';
    fmiEventInfo->nominalsOfContinuousStatesChanged = event_info->nominals_of_states_changed - '0';
    fmiEventInfo->valuesOfContinuousStatesChanged   = event_info->state_values_changed - '0';
    fmiEventInfo->nextEventTimeDefined              = event_info->next_event_time_defined - '0';
    fmiEventInfo->nextEventTime                     = event_info->next_event_time;
    
    free(event_info);
    
    return fmiOK;
}

fmiStatus fmi2_enter_continuous_time_mode(fmiComponent c) {
    if (((fmi2_me_t *)c)->fmi_mode != continuousTimeMode) {
        jmi_log_comment(((fmi2_me_t *)c)->jmi->log, logError, "Can only enter continuous time mode from event mode.");
        return fmiError;
    }
    
    ((fmi2_me_t *)c) -> fmi_mode = continuousTimeMode;
    return fmiOK;
}

fmiStatus fmi2_completed_integrator_step(fmiComponent c,
                                         fmiBoolean   noSetFMUStatePriorToCurrentPoint, 
                                         fmiBoolean*  enterEventMode, 
                                         fmiBoolean*  terminateSimulation) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    *enterEventMode = fmiFalse;
    *terminateSimulation = fmiFalse; //TODO: Should be able to use the stopTime to determine if the simulations should stop?
    return fmiOK;
}

fmiStatus fmi2_set_time(fmiComponent c, fmiReal time) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    *(jmi_get_t(((fmi2_me_t *)c)->jmi)) = time;
    ((fmi2_me_t *)c)->jmi->recomputeVariables = 1;
    return fmiOK;
}

fmiStatus fmi2_set_continuous_states(fmiComponent c, const fmiReal x[],
                                     size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (jmi_get_real_x(((fmi2_me_t *)c)->jmi), x, nx*sizeof(fmiReal));
    ((fmi2_me_t *)c)->jmi->recomputeVariables = 1;
    return fmiOK;
}

fmiStatus fmi2_get_derivatives(fmiComponent c, fmiReal derivatives[], size_t nx) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_derivatives(((fmi2_me_t *)c)->jmi, derivatives, nx);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_get_event_indicators(fmiComponent c, 
                                    fmiReal eventIndicators[], size_t ni) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_event_indicators(((fmi2_me_t *)c)->jmi, eventIndicators, ni);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_get_continuous_states(fmiComponent c, fmiReal x[], size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (x, jmi_get_real_x(((fmi2_me_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi2_get_nominals_of_continuous_states(fmiComponent c, 
                                                 fmiReal x_nominal[], 
                                                 size_t nx) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_nominal_continuous_states(((fmi2_me_t *)c)->jmi, x_nominal, nx);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}
