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
#include "fmi.h"
#include "fmiModelFunctions.h"
#include "fmiModelTypes.h"
#include "jmi.h"

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
const char* fmi_get_model_types_platform() {
    return fmiModelTypesPlatform;
}
const char* fmi_get_version() {
    return fmiVersion;
}

/* Creation and destruction of model instances and setting debug status */

fmiComponent fmi_instantiate_model(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn) {
    fmi_t *component;
    char* tmpname;
    char* tmpguid;
    size_t inst_name_len;
    size_t guid_len;

    /* Create jmi struct*/
    jmi_t* jmi = (jmi_t *)functions.allocateMemory(1, sizeof(jmi_t));
    fmiInteger retval = jmi_new(&jmi);
    if(retval != 0) {
        /* creating jmi struct failed */
        return NULL;
    }
    
    component = (fmi_t *)functions.allocateMemory(1, sizeof(fmi_t));
    
    inst_name_len = strlen(instanceName)+1;
    tmpname = (char*)(fmi_t *)functions.allocateMemory(inst_name_len, sizeof(char));
    strncpy(tmpname, instanceName, inst_name_len);
    component -> fmi_instance_name = tmpname;

    guid_len = strlen(GUID)+1;
    tmpguid = (char*)(fmi_t *)functions.allocateMemory(guid_len, sizeof(char));
    strncpy(tmpguid, GUID, guid_len);
    component -> fmi_GUID = tmpguid;
    
    component -> fmi_functions = functions;
    component -> fmi_logging_on = loggingOn;
    component -> jmi = jmi;
    
    /* set start values*/
    jmi_set_start_values(component -> jmi);
     
    return (fmiComponent)component;
}

void fmi_free_model_instance(fmiComponent c) {
    /* Dispose the given model instance and deallocated all the allocated memory and other resources 
     * that have been allocated by the functions of the Model Exchange Interface for instance "c".*/
    if (c) {
        fmiCallbackFreeMemory fmi_free = ((fmi_t*)c) -> fmi_functions.freeMemory;
        fmi_free(((fmi_t*)c) -> jmi);
        fmi_free((void*)((fmi_t*)c) -> fmi_instance_name);
        fmi_free((void*)((fmi_t*)c) -> fmi_GUID);
        fmi_free(c);
    }
}

fmiStatus fmi_set_debug_logging(fmiComponent c, fmiBoolean loggingOn) {
    ((fmi_t*)c) -> fmi_logging_on = loggingOn;
    return fmiOK;
}

/* Providing independent variables and re-initialization of caching */

fmiStatus fmi_set_time(fmiComponent c, fmiReal time) {
    *(jmi_get_t(((fmi_t *)c)->jmi)) = time;
    return fmiOK;
}

fmiStatus fmi_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx) {
	memcpy (jmi_get_real_x(((fmi_t *)c)->jmi), x, nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate) {
    *callEventUpdate = fmiFalse;
    return fmiOK;
}

fmiStatus fmi_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];
    }
    return fmiOK;
}

fmiStatus fmi_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];
    }
    return fmiOK;
}

fmiStatus fmi_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from the value array to z vector. */
        z[index] = value[i];
    }
    return fmiOK;
}

fmiStatus fmi_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]) {
    /* Strings not yet supported. */
    (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiWarning, "INFO", "Strings are not yet supported.");
    return fmiWarning;
}

/* Evaluation of the model equations */

fmiStatus fmi_initialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo) {
	fmiInteger retval;
    fmiInteger i;                   /* Iteration variable */
    fmiInteger nF0, nF1, nFp, nF;   /* Number of F-equations */
    fmiInteger nR0, nR;             /* Number of R-equations */
    fmiInteger initComplete = 0;    /* If the initialization are complete */
    jmi_real_t nextTimeEvent;       /* Next time event instant */
    fmiReal safety_factor_events = 0.0001;
    fmiReal safety_factor_newton = 0.01;
    
    jmi_real_t* switchesR;   /* Switches */
    jmi_real_t* switchesR0;  /* Initial Switches */

    /* Update eventInfo */
    eventInfo->upcomingTimeEvent = fmiFalse;            /* Next time event is computed after initialization */
    eventInfo->nextEventTime = 0.0;                     /* Next time event is computed after initialization */
    eventInfo->stateValueReferencesChanged = fmiFalse;  /* No support for dynamic state selection */
    eventInfo->terminateSimulation = fmiFalse;          /* Don't terminate the simulation */
    eventInfo->iterationConverged = fmiTrue;            /* The iteration has converged */
    
    /* Set tolerance in the BLT blocks */
    for (i=0; i < ((fmi_t *)c)->jmi->n_dae_init_blocks; i=i+1){
        ((fmi_t *)c)->jmi->dae_init_block_residuals[i]->kin_ftol = relativeTolerance*safety_factor_newton;
        ((fmi_t *)c)->jmi->dae_init_block_residuals[i]->kin_stol = relativeTolerance*safety_factor_newton;
    }
    for (i=0; i < ((fmi_t *)c)->jmi->n_dae_blocks; i=i+1){
        ((fmi_t *)c)->jmi->dae_block_residuals[i]->kin_ftol = relativeTolerance*safety_factor_newton;
        ((fmi_t *)c)->jmi->dae_block_residuals[i]->kin_stol = relativeTolerance*safety_factor_newton;
    }
    
    /* Get Sizes */
    retval = jmi_init_get_sizes(((fmi_t *)c)->jmi,&nF0,&nF1,&nFp,&nR0); /* Get the size of R0 and F0, (interested in R0) */
    if(retval != 0) {
        (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed when trying to retrieve the initial sizes.");
        return fmiError;
    }
    
    retval = jmi_dae_get_sizes(((fmi_t *)c)->jmi,&nF,&nR);
    if(retval != 0) {
        (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed when trying to retrieve the actual sizes.");
        return fmiError;
    }
    /* ---- */
    
    ((fmi_t *)c) -> fmi_epsilon=safety_factor_events*relativeTolerance; /* Used in the event detection */
    ((fmi_t *)c) -> fmi_newton_tolerance=safety_factor_newton*relativeTolerance; /* Used in the Newton iteration */
    
    /* We are at the initial event TODO: is this really necessary? */
    ((fmi_t *)c)->jmi->atEvent = JMI_TRUE;

    /* Write values to the pre vector*/
    jmi_copy_pre_values(((fmi_t*)c)->jmi);

    while (initComplete == 0){                            /* Loop during event iteration */
    
        if (nR0 > 0){                                     /* Specify the switches if any */
            jmi_real_t* b_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
            retval = jmi_init_R0(((fmi_t *)c)->jmi, b_mode);

            if(retval != 0) {
                (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed when trying to retrieve the event indicators.");
                return fmiError;
            }
            
            switchesR0 = jmi_get_sw_init(((fmi_t *)c)->jmi);
            switchesR = jmi_get_sw(((fmi_t *)c)->jmi);
            
            for (i=0; i < nR0; i=i+1){
                if (b_mode[i] > 0.0){
                    if (i >= nR){
                        switchesR0[i-nR] = 1.0;
                    }else{
                        switchesR[i] = 1.0;
                    }
                }else{
                    if (i >= nR){
                        switchesR0[i-nR] = 0.0;
                    }else{
                        switchesR[i] = 0.0;
                    }
                }
            }
            ((fmi_t*)c) -> fmi_functions.freeMemory(b_mode);
        }/* End specify switches */

        /* Call the initialization algorithm */
        retval = jmi_ode_initialize(((fmi_t *)c)->jmi);
        
        if(retval != 0) { /* Error check */
            (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed.");
            return fmiError;
        }
        
        if (nR0 > 0){ /* Event functions, check if there is an iteration. */
            jmi_real_t* b_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
            retval = jmi_init_R0(((fmi_t *)c)->jmi, b_mode);
            
            if(retval != 0) { /* Error check */
                (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed when trying to retrieve the event indicators.");
                return fmiError;
            }
            
            initComplete = 1; /* Assume the iteration is complete */
            for (i=0; i < nR0; i=i+1){ /* Loop over the event functions */
                if (i >= nR){
                    if (switchesR0[i-nR] == 1.0){
                        if (b_mode[i] <= ((fmi_t *)c)->fmi_epsilon){
                            switchesR0[i-nR] = 0.0;
                            initComplete = 0; /* Iteration not complete */
                        }
                    }else{
                        if (b_mode[i] >= ((fmi_t *)c)->fmi_epsilon){
                            switchesR0[i-nR] = 1.0;
                            initComplete = 0; /* Iteration not complete */
                        }
                    }
                }else{
                    if (switchesR[i] == 1.0){
                        if (b_mode[i] <= ((fmi_t *)c)->fmi_epsilon){
                            switchesR[i] = 0.0;
                            initComplete = 0; /* Iteration not complete */
                        }
                    }else{
                        if (b_mode[i] >= ((fmi_t *)c)->fmi_epsilon){
                            switchesR[i] = 1.0;
                            initComplete = 0; /* Iteration not complete */
                        }
                    }
                }
            }
            ((fmi_t*)c) -> fmi_functions.freeMemory(b_mode);
            
        }else{ /* No event functions, initialization is complete. */
            initComplete = 1;
        }
    }

    /* Compute the next time event */
    retval = jmi_ode_next_time_event(((fmi_t *)c)->jmi,&nextTimeEvent);

    if(retval != 0) { /* Error check */
    	(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Computation of next time event failed.");
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
    ((fmi_t *)c)->jmi->atEvent = JMI_FALSE;

    /* Evaluate the guards with the event flag set to false in order to 
     * reset guards depending on samplers before copying pre values.
     * If this is not done, then the corresponding pre values for these guards
     * will be true, and no event will be triggered at the next sample. 
     */
    retval = jmi_ode_guards(((fmi_t *)c)->jmi);

    if(retval != 0) { /* Error check */
    	(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Computation of guard expressions failed.");
        return fmiError;
    }

    jmi_copy_pre_values(((fmi_t*)c)->jmi);

    /* Initialization is now complete, but we also need to handle events
     * at the start of the integration.
     */
    fmi_event_update(c, fmiFalse, eventInfo);

    /*
    //Set the final switches (if any)
    if (nR > 0){
        jmi_real_t* a_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));
        retval = jmi_dae_R(((fmi_t *)c)->jmi,a_mode); //Get the event indicators after the initialisation
        
        if(retval != 0) { //Error check
            (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed.");
            return fmiError;
        }
        
        switches = jmi_get_sw(((fmi_t *)c)->jmi); //Get the switches
        
        for (i=0; i < nR; i=i+1){ //Set the final switches
            if (a_mode[i] > 0.0){
                switches[i] = 1.0;
            }else{
                switches[i] = 0.0;
            }
            printf("Switches (after) %d, %f\n",i,switches[i]);
        }
        ((fmi_t*)c) -> fmi_functions.freeMemory(a_mode); //Free memory
    }
    */
    
    return fmiOK;
}

fmiStatus fmi_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
	fmiInteger retval = jmi_ode_derivatives(((fmi_t *)c)->jmi);
	if(retval != 0) {
		(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the derivatives failed.");
		return fmiError;
	}
	memcpy (derivatives, jmi_get_real_dx(((fmi_t *)c)->jmi), nx*sizeof(fmiReal));
	return fmiOK;
}

fmiStatus fmi_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    fmiInteger retval = jmi_dae_R(((fmi_t *)c)->jmi,eventIndicators);
    jmi_real_t *switches = jmi_get_sw(((fmi_t *)c)->jmi);
    fmiValueReference i;
    
	if(retval != 0) {
		(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the event indicators failed.");
		return fmiError;
	}

    for (i = 0; i < ni; i=i+1){
        if (switches[i] == 1.0){
            eventIndicators[i] = eventIndicators[i]/1.0+((fmi_t *)c)->fmi_epsilon; /* MISSING DIVIDING WITH NOMINAL */
        }else{
            eventIndicators[i] = eventIndicators[i]/1.0-((fmi_t *)c)->fmi_epsilon; /* MISSING DIVIDING WITH NOMINAL */
        }
    }
    return fmiOK;
}

fmiStatus fmi_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = z[index];
    }
    return fmiOK;
}

fmiStatus fmi_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = z[index];
    }
    return fmiOK;
}

fmiStatus fmi_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
    
    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);
        
        /* Set value from z vector to return value array*/
        value[i] = z[index];
    }
    return fmiOK;
}

fmiStatus fmi_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    /* Strings not yet supported. */
    (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiWarning, "INFO", "Strings are not yet supported.");
    return fmiWarning;
}

jmi_t* fmi_get_jmi_t(fmiComponent c) {
	return ((fmi_t*)c)->jmi;
}

fmiStatus fmi_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    /* Handle an event */
    fmiInteger retval;
    fmiInteger nF; /* Number of F-equations */
    fmiInteger nR; /* Number of R-equations */
    fmiInteger nGuards; /* Number of guard expressions */
    jmi_real_t* b_mode;
    jmi_real_t* a_mode;
    jmi_real_t* pre_iter_guards;
    jmi_real_t* guards;
    jmi_real_t nextTimeEvent;       /* Next time event instant */
    jmi_real_t *switches; /* Switches */
    jmi_t* jmi;
    jmi = ((fmi_t*)c)->jmi;

    nGuards = jmi->n_guards;
    retval = jmi_dae_get_sizes((((fmi_t *)c) ->jmi), &nF, &nR); /* Get the size of R and F, (interested in R) */

    guards = (*(jmi->z_val)) + jmi->offs_guards; /* Get the guards */
    
    /* Value of the event indicators prior to the initialization */
    b_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));
    /* Value of the event indicators after the initialization */
    a_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));

    /* Value of the guards at the previous event iteration */
    pre_iter_guards =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nGuards, sizeof(jmi_real_t));
    
    /* Update eventInfo */
    eventInfo->upcomingTimeEvent = fmiFalse;            /* No support for time events */
    eventInfo->nextEventTime = 0.0;                     /* Not used */
    eventInfo->stateValueReferencesChanged = fmiFalse;  /* No support for dynamic state selection */
    eventInfo->terminateSimulation = fmiFalse;          /* Don't terminate the simulation */
    eventInfo->iterationConverged = fmiFalse;           /* The iteration have not converged */

    /* We are at an event */
    ((fmi_t *)c)->jmi->atEvent = JMI_TRUE;

    if (intermediateResults){ /* Return after each event iteration loop */
        fmiInteger j, i;
        jmi_real_t* switches;
        
        retval = jmi_dae_R(((fmi_t *)c)->jmi,b_mode); /* The event indicators before the initialisation */
        
        /* Turn the switches */
        switches = jmi_get_sw(((fmi_t *)c)->jmi); /* Get the switches */
        for (j=0; j < nR; j=j+1){
            if (switches[j] == 1.0){
                if (b_mode[j] <= ((fmi_t *)c)->fmi_epsilon){
                    switches[j] = 0.0;
                }
            }else{
                if (b_mode[j] >= ((fmi_t *)c)->fmi_epsilon){
                    switches[j] = 1.0;
                }
            }
        }
        
        /* Turn the switches */
        switches = jmi_get_sw(((fmi_t *)c)->jmi); /* Get the switches */
            
        retval = jmi_ode_derivatives(((fmi_t *)c)->jmi); /* Initialise */
        
        if(retval != 0) {
            (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialize during event iteration failed.");
            return fmiError;
        }
            
        retval = jmi_dae_R(((fmi_t *)c)->jmi,a_mode); /* Get the event indicators after the initialisation */
            
        /* Error check */
        if(retval != 0) {
            (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the event indicators failed.");
            return fmiError;
        }
        
        /* Compare the values of the event indicators before and after the event */
        eventInfo->iterationConverged = fmiTrue; /* Assume the iteration converged */
        switches = jmi_get_sw(((fmi_t *)c)->jmi); /* Get the switches */
        
        for (i=0; i < nR; i=i+1){
            if (switches[i] == 1.0){ /* Case when the switch are True */
                if (a_mode[i] <= ((fmi_t *)c)->fmi_epsilon){
                    eventInfo->iterationConverged = fmiFalse; /* Event iteration (not converged) */
                }
            }else{ /* Case when the switch are False */
                if (a_mode[i] >= ((fmi_t *)c)->fmi_epsilon){
                    eventInfo->iterationConverged = fmiFalse; /* Event iteration (not converged) */
                }
            }
        }
        
    }else{ /* Return once the iteration have converged */
        while ((eventInfo->iterationConverged)==fmiFalse){
            fmiInteger j;
            fmiInteger i;

            /* Save the guards before the iteration */
            for (i=0;i<nGuards;i++) {
            	pre_iter_guards[i] = guards[i];
            }

            retval = jmi_dae_R(((fmi_t *)c)->jmi,b_mode); /* The event indicators before the initialisation */
            
            /* Error check */
            if(retval != 0) {
                (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the event indicators failed.");
                return fmiError;
            }
            
            /* Turn the switches */
            switches = jmi_get_sw(((fmi_t *)c)->jmi); /* Get the switches */
            for (j=0; j < nR; j=j+1){
                if (switches[j] == 1.0){
                    if (b_mode[j] <= ((fmi_t *)c)->fmi_epsilon){
                        switches[j] = 0.0;
                    }
                }else{
                    if (b_mode[j] >= ((fmi_t *)c)->fmi_epsilon){
                        switches[j] = 1.0;
                    }
                }
            }
            
            retval = jmi_ode_derivatives(((fmi_t *)c)->jmi); /* Initialise */

            if(retval != 0) {
                (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialize during event iteration failed.");
                return fmiError;
            }
            
            retval = jmi_dae_R(((fmi_t *)c)->jmi,a_mode); /* Get the event indicators after the initialisation */
            
            /* Error check */
            if(retval != 0) {
                (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the event indicators failed.");
                return fmiError;
            }
            
            /* Compare the values of the event indicators before and after the event */
            eventInfo->iterationConverged = fmiTrue; /* Assume the iteration converged */
            switches = jmi_get_sw(((fmi_t *)c)->jmi); /* Get the switches */
            
            for (i=0; i < nR; i=i+1){
                if (switches[i] == 1.0){ /* Case when the switch are True */
                    if (a_mode[i] <= ((fmi_t *)c)->fmi_epsilon){
                        eventInfo->iterationConverged = fmiFalse; /* Event iteration (not converged) */
                    }
                }else{ /* Case when the switch are False */
                    if (a_mode[i] >= ((fmi_t *)c)->fmi_epsilon){
                    	eventInfo->iterationConverged = fmiFalse; /* Event iteration (not converged) */
                    }
                }
            }

            /* Compare the values of the guards before and after the event */

            for (i=0; i < nGuards; i=i+1){
            	if (pre_iter_guards[i]!=guards[i]) {
            		eventInfo->iterationConverged = fmiFalse; /* Event iteration (not converged) */
            		break;
            	}
            }
        }
    }
    
    ((fmi_t*)c) -> fmi_functions.freeMemory(a_mode); /* Free memory */
    ((fmi_t*)c) -> fmi_functions.freeMemory(b_mode); /* Free memory */
    ((fmi_t*)c) -> fmi_functions.freeMemory(pre_iter_guards); /* Free memory */

    /* Compute the next time event */
    retval = jmi_ode_next_time_event(((fmi_t *)c)->jmi,&nextTimeEvent);

    if(retval != 0) { /* Error check */
    	(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Computation of next time event failed.");
        return fmiError;
    }

    if (!(nextTimeEvent==JMI_INF)) {
        /* If there is an upcoming time event, then set the event information
           accordingly. */
    	eventInfo->upcomingTimeEvent = fmiTrue;
        eventInfo->nextEventTime = nextTimeEvent;
        /*printf("fmi_event_upate: nextTimeEvent: %f\n",nextTimeEvent); */
    } else {
    	eventInfo->upcomingTimeEvent = fmiFalse;
    }

    /* Reset atEvent flag */
    ((fmi_t *)c)->jmi->atEvent = JMI_FALSE;

    /* Evaluate the guards with the event flat set to false in order to 
     * reset guards depending on samplers before copying pre values.
     * If this is not done, then the corresponding pre values for these guards
     * will be true, and no event will be triggered at the next sample. 
     */
    retval = jmi_ode_guards(((fmi_t *)c)->jmi);

    if(retval != 0) { /* Error check */
    	(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Computation of guard expressions failed.");
        return fmiError;
    }

    if ((eventInfo->iterationConverged)==fmiTrue) {
        jmi_copy_pre_values(((fmi_t*)c)->jmi);
    }

    return fmiOK;
}

fmiStatus fmi_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx) {
	memcpy (states, jmi_get_real_x(((fmi_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx) {
	fmiReal* ones = ((fmi_t*)c) -> fmi_functions.allocateMemory(nx, sizeof(fmiReal));
	fmiValueReference i;
	for(i = 0; i <nx; i = i + 1) {
		ones[i]=1.0;
	}
	memcpy (x_nominal, ones, nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx) {
	fmiInteger offset = ((fmi_t *)c)->jmi->offs_real_x;
	fmiValueReference* valrefs = ((fmi_t*)c) -> fmi_functions.allocateMemory(nx, sizeof(fmiValueReference));
	fmiValueReference i;
    
	for(i = 0; i<nx; i = i + 1) {
		valrefs[i] = offset + i;
	}
	memcpy (vrx, valrefs, nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi_terminate(fmiComponent c) {
    /* Release all resources that have been allocated since fmi_initialize has been called. */
    return fmiOK;
}
