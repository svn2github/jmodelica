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
#include <time.h>

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
    char buffer[400];

    /* Create jmi struct -> No need  since jmi_init allocates it
     jmi_t* jmi = (jmi_t *)functions.allocateMemory(1, sizeof(jmi_t)); */
    jmi_t* jmi = 0;
    fmiInteger retval;

    if(!functions.allocateMemory || !functions.freeMemory || !functions.logger) {
         if(functions.logger) {
             functions.logger(0, instanceName, fmiError, "ERROR", "Memory management functions allocateMemory/freeMemory are required.");
         }
         return 0;
    }
    
    component = (fmi_t *)functions.allocateMemory(1, sizeof(fmi_t));
    component -> fmi_functions = functions;

#ifdef USE_FMI_ALLOC
    /* Set the global user functions pointer so that memory allocation functions are intercepted */
    fmiFunctions = &(component -> fmi_functions);
#endif

    retval = jmi_new(&jmi);
    if(retval != 0) {
        /* creating jmi struct failed */
        functions.freeMemory(component);
        return NULL;
    }

    jmi->fmi = component;

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
    
    /* Print some info about Jacobians, if available. */
    if (jmi->color_info_A != NULL) {
    	sprintf(buffer,"Number of non-zeros in Jacobian A: %d", jmi->color_info_A->n_nz);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    	sprintf(buffer,"Number of colors in Jacobian A: %d", jmi->color_info_A->n_groups);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    }

    if (jmi->color_info_B != NULL) {
    	sprintf(buffer,"Number of non-zeros in Jacobian B: %d", jmi->color_info_B->n_nz);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    	sprintf(buffer,"Number of colors in Jacobian B: %d", jmi->color_info_B->n_groups);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    }

    if (jmi->color_info_C != NULL) {
    	sprintf(buffer,"Number of non-zeros in Jacobian C: %d", jmi->color_info_C->n_nz);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    	sprintf(buffer,"Number of colors in Jacobian C: %d", jmi->color_info_C->n_groups);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    }

    if (jmi->color_info_D != NULL) {
    	sprintf(buffer,"Number of non-zeros in Jacobian D: %d", jmi->color_info_D->n_nz);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    	sprintf(buffer,"Number of colors in Jacobian D: %d", jmi->color_info_D->n_groups);
    	(component->fmi_functions).logger(component, component->fmi_instance_name, fmiWarning, "INFO", buffer);
    }

    return (fmiComponent)component;
}

void fmi_free_model_instance(fmiComponent c) {
    /* Dispose the given model instance and deallocated all the allocated memory and other resources 
     * that have been allocated by the functions of the Model Exchange Interface for instance "c".*/
    if (c) {
        fmi_t* component = (fmi_t*)c;
        fmiCallbackFreeMemory fmi_free = component -> fmi_functions.freeMemory;
        jmi_delete(component->jmi);
        component->jmi = 0;
        fmi_free((void*)component -> fmi_instance_name);
        fmi_free((void*)component -> fmi_GUID);
        fmi_free(component);
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

        if (index<(((fmi_t *)c)->jmi)->offs_real_dx) {
        	jmi_init_eval_parameters(((fmi_t *)c)->jmi);
        }

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

        if (index<(((fmi_t *)c)->jmi)->offs_real_dx) {
        	jmi_init_eval_parameters(((fmi_t *)c)->jmi);
        }

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

        if (index<(((fmi_t *)c)->jmi)->offs_real_dx) {
        	jmi_init_eval_parameters(((fmi_t *)c)->jmi);
        }

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
    fmiReal safety_factor_newton = 0.0001;
    
    jmi_real_t* switchesR;   /* Switches */
    jmi_real_t* switchesR0;  /* Initial Switches */
    jmi_real_t* b_mode;

    /* Update eventInfo */

    eventInfo->upcomingTimeEvent = fmiFalse;            /* Next time event is computed after initialization */
    eventInfo->nextEventTime = 0.0;                     /* Next time event is computed after initialization */
    eventInfo->stateValueReferencesChanged = fmiFalse;  /* No support for dynamic state selection */
    eventInfo->terminateSimulation = fmiFalse;          /* Don't terminate the simulation */
    eventInfo->iterationConverged = fmiTrue;            /* The iteration has converged */
    
    /* Evaluate parameters */
    jmi_init_eval_parameters(((fmi_t *)c)->jmi);

    /* Sets the relative tolerance to a default value for use in Kinsol when tolerance controlled is false */
    if (toleranceControlled == fmiFalse){
        relativeTolerance = 1e-6;
    }
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

    ((fmi_t *)c)->jmi->atInitial = JMI_TRUE;

    /* Write values to the pre vector*/
    jmi_copy_pre_values(((fmi_t*)c)->jmi);

    /* Set the switches */
    b_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
    retval = jmi_init_R0(((fmi_t *)c)->jmi, b_mode);
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
    /* Call the initialization function */
    retval = jmi_ode_initialize(((fmi_t *)c)->jmi);

    if(retval != 0) { /* Error check */
        (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed.");
        return fmiError;
    }

    while (initComplete == 0){                            /* Loop during event iteration */

        if (nR0 > 0){                                     /* Specify the switches if any */
            b_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
            retval = jmi_init_R0(((fmi_t *)c)->jmi, b_mode);

            if(retval != 0) {
                (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed when trying to retrieve the event indicators.");
                return fmiError;
            }
            
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
        
        if (nR0 > 0){ /* Event functions, check if there is an iteration. */
            jmi_real_t* b_mode =  ((fmi_t*)c) -> fmi_functions.allocateMemory(nR0, sizeof(jmi_real_t));
            /* Call the initialization algorithm */
             retval = jmi_ode_initialize(((fmi_t *)c)->jmi);

             if(retval != 0) { /* Error check */
                 (((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed.");
                 return fmiError;
             }

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
    ((fmi_t *)c)->jmi->atInitial = JMI_FALSE;

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
	jmi_real_t *switches;
	fmiValueReference i;
	fmiInteger retval = jmi_ode_derivatives(((fmi_t *)c)->jmi);
	if(retval != 0) {
		(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the derivatives failed.");
		return fmiError;
	}
	retval = jmi_dae_R(((fmi_t *)c)->jmi,eventIndicators);
	switches = jmi_get_sw(((fmi_t *)c)->jmi);
    
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

fmiStatus fmi_get_partial_derivatives(fmiComponent c, fmiStatus (*setMatrixElement)(void* data, fmiInteger row, fmiInteger col, fmiReal value), void* A, void* B, void* C, void* D){	

/* fmi_get_jacobian is not an FMI function. Still use fmiStatus as return arguments?. Is there an error handling policy? Standard messages? Which function should return errors?*/
	
	fmiStatus fmiFlag;
	fmiReal* jac;
	jmi_t* jmi = ((fmi_t *)c)->jmi;
	fmi_t* fmi = (fmi_t *)c;
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

	char msg[100]; /* Holder for the logger function's messages */

	clock_t c0, c1, d0, d1;
	jmi_real_t setElementTime;

	c0 = clock();

	setElementTime = 0;

	/* Get number of outputs that are variability = "continuous", ny */
	n_outputs = ny = jmi->n_outputs;
	if (!(output_vrefs = (int*)fmi -> fmi_functions.allocateMemory(n_outputs, sizeof(int)))) {
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiError, "ERROR", "Out of memory.");
		return fmiError;
	}
		
	jmi_get_output_vrefs(jmi, output_vrefs);

	/* This analysis needs to be extended to account for discrete reals*/
	for(i = 0; i < n_outputs; i++)
		if (get_type_from_value_ref(output_vrefs[i])!= 0)
			ny--;	
	fmi -> fmi_functions.freeMemory(output_vrefs);
	
	nx = jmi->n_real_x;
	nu = jmi->n_real_u;
	
	nA = nx*nx;
	nB = nx*nu;
	nC = ny*nx;
	nD = ny*nu;

	/*
	if (fmi -> fmi_logging_on) {
		sprintf(msg,"size of A  = %d %d",nx,nx);
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiOK, "OK", msg);
		sprintf(msg,"size of B  = %d %d",nx,nu);
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiOK, "OK", msg);
		sprintf(msg,"size of C  = %d %d",ny,nx);
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiOK, "OK", msg);
		sprintf(msg,"size of D  = %d %d",ny,nu);
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiOK, "OK", msg);
	}
	 */

	/* Allocate a big chunk of memory that is enough to compute all Jacobians */
	jac_size = nA + nB + nC + nD;

	/* Allocate memory for the biggest matrix, use this for all matrices. */
	if (!(jac = fmi -> fmi_functions.allocateMemory(sizeof(fmiReal),jac_size))) {
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiError, "ERROR", "Out of memory.");
		return fmiError;
	}

	/* Individual calls to evaluation of A, B, C, D matrices can be made
	 * more efficiently by evaluating several Jacobian at the same time.
	 */

	/* Get the internal A matrix */
	fmiFlag = fmi_get_jacobian(c, FMI_STATES, FMI_DERIVATIVES, jac, nA); 
	if (fmiFlag > fmiWarning) {
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "Evaluating the A matrix failed.");
		fmi -> fmi_functions.freeMemory(jac);
		return fmiFlag;
	}

	/* Update external A matrix */
	for (row=0;row<nx;row++) {
		for (col=0;col<nx;col++) {
			d0 = clock();
			fmiFlag = setMatrixElement(A,row+1,col+1,jac[row + col*nx]);
			d1 = clock();
			setElementTime += ((realtype) ((long)(d1-d0))/(CLOCKS_PER_SEC));
			if (fmiFlag > fmiWarning) {
				fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "setMatrixElement failed to update matrix A");
				fmi -> fmi_functions.freeMemory(jac);
				return fmiFlag;
			}
		}
	}

	/* Get the internal B matrix */
	fmiFlag = fmi_get_jacobian(c, FMI_INPUTS, FMI_DERIVATIVES, jac, nB); 
	if (fmiFlag > fmiWarning) {
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "Evaluating the B matrix failed.");
		fmi -> fmi_functions.freeMemory(jac);
		return fmiFlag;
	}
	/* Update external B matrix */
	for (row=0;row<nx;row++) {
		for (col=0;col<nu;col++) {
			d0 = clock();
			fmiFlag = setMatrixElement(B,row+1,col+1,jac[row + col*nx]);
			d1 = clock();
			setElementTime += ((realtype) ((long)(d1-d0))/(CLOCKS_PER_SEC));
			if (fmiFlag > fmiWarning) {
				fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "setMatrixElement failed to update matrix B");
				fmi -> fmi_functions.freeMemory(jac);
				return fmiFlag;
			}
		}
	}

	/* Get the internal C matrix */
	fmiFlag = fmi_get_jacobian(c, FMI_STATES, FMI_OUTPUTS, jac, nC); 
	if (fmiFlag > fmiWarning) {
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "Evaluating the C matrix failed.");
		fmi -> fmi_functions.freeMemory(jac);
		return fmiFlag;
	}
	/* Update external C matrix */
	for (row=0;row<ny;row++) {
		for (col=0;col<nx;col++) {
			d0 = clock();
			fmiFlag = setMatrixElement(C,row + 1, col + 1, jac[row+col*ny]);
			d1 = clock();
			setElementTime += ((realtype) ((long)(d1-d0))/(CLOCKS_PER_SEC));
			if (fmiFlag > fmiWarning) {
				fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "setMatrixElement failed to update matrix C");
				fmi -> fmi_functions.freeMemory(jac);
				return fmiFlag;
			}
		}
	}



	/* Get the internal D matrix */
	fmiFlag = fmi_get_jacobian(c, FMI_INPUTS, FMI_OUTPUTS, jac, nD); 
	if (fmiFlag > fmiWarning) {
		fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "Evaluating the D matrix failed.");
		fmi -> fmi_functions.freeMemory(jac);
		return fmiFlag;
	}
	/* Update external D matrix */
	for (row=0;row<ny;row++) {
		for (col=0;col<nu;col++) {
			d0 = clock();
			fmiFlag = setMatrixElement(D,row + 1, col + 1,jac[row + col*ny]);
			d1 = clock();
			setElementTime += ((realtype) ((long)(d1-d0))/(CLOCKS_PER_SEC));
			if (fmiFlag > fmiWarning) {
				fmi -> fmi_functions.logger(c, fmi->fmi_instance_name, fmiFlag, "ERROR", "setMatrixElement failed to update matrix D");
				fmi -> fmi_functions.freeMemory(jac);
				return fmiFlag;
			}
		}
	}

	fmi -> fmi_functions.freeMemory(jac);

	c1 = clock();
	/*printf("Jac eval call: %f\n", ((realtype) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/
	/*printf(" - setMatrixElementTime: %f\n", setElementTime);*/
	return fmiOK;
}

/*Evaluates the A, B, C and D matrices using finite differences, this functions has
only been used for debugging purposes*/
fmiStatus fmi_get_jacobian_fd(fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac){
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
	
	jmi_t* jmi = ((fmi_t *)c)->jmi;
	
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
 		jmi->dae->ode_derivatives(jmi);
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
 		jmi->dae->ode_derivatives(jmi);
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
fmiStatus fmi_get_jacobian(fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac) {
	
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

	clock_t c0, c1;

	c0 = clock();

	/*Used for debugging 
	fmiReal tol = 0.001;	
	fmiReal* jac2;*/
	
	size_t nvvr = 0;
	size_t nzvr = 0;
	
	int n_outputs;
	int* output_vrefs;
	int n_outputs_real;
	int* output_vrefs_real;
	jmi_t* jmi = ((fmi_t *)c)->jmi;
	n_outputs = jmi->n_outputs;
	n_outputs_real = n_outputs;
	
	/*dv and the dz are stored in the same vector*/
	dv = jmi->dv;
	dz = jmi->dv;
	
	/* Used for debbugging
	jac2 = (fmiReal*)calloc(njac, sizeof(fmiReal));
	*/
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
	
	offs = jmi->n_real_dx;
	
 	for(i = 0; i<jmi->n_real_dx+jmi->n_real_x+jmi->n_real_u+jmi->n_real_w;i++){
 		(*dz)[i] = 0;
 		(*dv)[i] = 0;
	}

	for(i = 0; i < jmi->n_real_u; i++){
		(*(jmi->z))[i+jmi->offs_real_u] = (*(jmi->z_val))[i+jmi->offs_real_u];
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
			for (j=0;j<jmi->n_z;j++) {
				printf(" * %d %f\n",j,d_z[j]);
			}*/
			/* Evaluate directional derivative */
			jmi->dae->ode_derivatives_dir_der(jmi);
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
	} else {


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
		
		/*Evaluate directional derivative*/
		jmi->dae->ode_derivatives_dir_der(jmi);
		
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
	free(output_vrefs);
	free(output_vrefs_real);
	
	c1 = clock();

	/*printf("Jac eval call: %f\n", ((realtype) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/
	return fmiOK;
}

/*Evaluate the directional derivative dz/dv dv*/
fmiStatus fmi_get_directional_derivative(fmiComponent c, const fmiValueReference z_vref[], size_t nzvr, const fmiValueReference v_vref[], size_t nvvr, fmiReal dz[], const fmiReal dv[]) {
	int i = 0;
	jmi_t* jmi = ((fmi_t *)c)->jmi;
	jmi_real_t** dv_ = jmi->dv;
	jmi_real_t** dz_ = jmi->dv;
	for (i=0;i<nvvr;i++) {
		(*dv_)[get_index_from_value_ref(v_vref[i])] = dv[i];
	}
	jmi->dae->ode_derivatives_dir_der(jmi);
	for (i=0;i<nzvr;i++) {
		dz[i] = (*dz_)[get_index_from_value_ref(z_vref[i])];
	}
	return fmiOK;
}


fmiStatus fmi_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    fmiValueReference i;
    fmiValueReference index;
	
	/* Make the derivative consistent if a derivative is output */
	fmiValueReference derIndexMin;
	fmiValueReference derIndexMax;
	fmiBoolean updateDerivatives=fmiTrue;
	fmiInteger retval;
	derIndexMin=((fmi_t *)c)->jmi->offs_real_dx;
	derIndexMax=((fmi_t *)c)->jmi->offs_real_dx+((fmi_t *)c)->jmi->n_real_dx-1;

    for (i = 0; i <nvr; i = i + 1) {
        /* Get index in z vector from value reference. */ 
        index = get_index_from_value_ref(vr[i]);

		/* Update the derivatives if an index is a derivative */		
		if (derIndexMax<=index && derIndexMin>=index) {
			if (updateDerivatives) {
				updateDerivatives=fmiFalse;
				retval = jmi_ode_derivatives(((fmi_t *)c)->jmi);
				if(retval != 0) {
					(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the derivatives failed in fmiGetReal.");
					return fmiError;
				}				
			}
		}		
        
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
        value[i] = (fmiInteger)z[index];
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

fmiStatus fmi_event_iteration(fmiComponent c, fmiBoolean duringInitialization,
		                      fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {

	fmiInteger nGuards;
	fmiInteger nF;
	fmiInteger nR;
	fmiInteger retval;
	fmiInteger i;
    jmi_real_t nextTimeEvent;
	fmi_t* fmi = ((fmi_t *)c);
	jmi_t* jmi = fmi->jmi;
	jmi_real_t* z = jmi_get_z(jmi);
    jmi_real_t* event_indicators;
    jmi_real_t* switches;

	/* Allocate memory */
    nGuards = jmi->n_guards;
    jmi_dae_get_sizes(jmi, &nF, &nR);
    event_indicators = fmi->fmi_functions.allocateMemory(nR, sizeof(jmi_real_t));
    switches = jmi_get_sw(jmi); /* Get the switches */

    /* Reset eventInfo */
    eventInfo->upcomingTimeEvent = fmiFalse;            /* No support for time events */
    eventInfo->nextEventTime = 0.0;                     /* Not used */
    eventInfo->stateValueReferencesChanged = fmiFalse;  /* No support for dynamic state selection */
    eventInfo->terminateSimulation = fmiFalse;          /* Don't terminate the simulation */
    eventInfo->iterationConverged = fmiFalse;           /* The iteration have not converged */

    retval = jmi_ode_derivatives(jmi);

    if(retval != 0) {
        fmi->fmi_functions.logger(c, fmi->fmi_instance_name, fmiError, "ERROR", "Initialize during event iteration failed.");
        return fmiError;
    }

	/* Copy all pre values */
	jmi_copy_pre_values(jmi);

    /* We are at an event -> set atEvent to true. */
    jmi->atEvent = JMI_TRUE;

    /* Iterate */
    while ((eventInfo->iterationConverged)==fmiFalse){

    	/* Set switches according to the event indicators*/
        retval = jmi_dae_R(jmi,event_indicators);

        /* Turn the switches */
        for (i=0; i < nR; i=i+1){
            if (switches[i] == 1.0){
                if (event_indicators[i] <= 0.0){
                    switches[i] = 0.0;
                }
            }else{
                if (event_indicators[i] > 0.0){
                    switches[i] = 1.0;
                }
            }
        }

    	/* Evaluate the ODE again */
        retval = jmi_ode_derivatives(jmi);

        if(retval != 0) {
            (fmi->fmi_functions).logger(c, fmi->fmi_instance_name, fmiError, "ERROR", "Evaluation of model equations during event iteration failed.");
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

    	/* Evaluate the event indicators again */
        retval = jmi_dae_R(jmi,event_indicators);

    	/* Check the switches against the event indicators
    	 * separately to account for the epsilon.
    	 */
        for (i=0; i < nR; i=i+1){
            if (switches[i] == 1.0){
                if (event_indicators[i] <= -1*fmi->fmi_epsilon){
                    eventInfo->iterationConverged = fmiFalse;
                }
            }else{
                if (event_indicators[i] >= fmi->fmi_epsilon){
                	eventInfo->iterationConverged = fmiFalse;
                }
            }
        }

    	/* Copy new values to pre values */
    	jmi_copy_pre_values(jmi);

    	if (intermediateResults){
    		break;
    	}

    }

    /* Only do the final steps if the event iteration is done. */
    if (eventInfo->iterationConverged == fmiTrue) {

    	/* Compute the next time event */
    	retval = jmi_ode_next_time_event(jmi,&nextTimeEvent);

    	if(retval != 0) { /* Error check */
    		(fmi -> fmi_functions).logger(c, fmi->fmi_instance_name, fmiError, "ERROR", "Computation of next time event failed.");
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

    	if(retval != 0) { /* Error check */
    		(fmi->fmi_functions).logger(c,fmi->fmi_instance_name, fmiError, "ERROR", "Computation of guard expressions failed.");
    		return fmiError;
    	}

    }

    fmi->fmi_functions.freeMemory(event_indicators);

    return fmiOK;

}

fmiStatus fmi_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {

	return fmi_event_iteration(c, JMI_FALSE, intermediateResults, eventInfo);
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
	fmiValueReference i;
	for(i = 0; i<nx; i = i + 1) {
		vrx[i] = offset + i;
	}
    return fmiOK;
}

fmiStatus fmi_terminate(fmiComponent c) {
    /* Release all resources that have been allocated since fmi_initialize has been called. */
    return fmiOK;
}

fmiStatus fmi_extract_debug_info(fmiComponent c) {
    fmiInteger nniters;
    fmiReal avg_nniters;
    char buf[100];
    fmi_t* fmi;
    jmi_t* jmi;
    fmiCallbackLogger logger;
    fmiString instance_name;
    jmi_block_residual_t* block;
    int i;
    
    fmi = ((fmi_t*)c);
    jmi = fmi->jmi;
    logger = fmi->fmi_functions.logger;
    instance_name = fmi->fmi_instance_name;
    
    /* Extract debug information from initialization*/
    for (i = 0; i < jmi->n_dae_init_blocks; i++) {
        block = jmi->dae_init_block_residuals[i];
        nniters = block->nb_iters;

        /* Test if block is solved by KINSOL */
        if (nniters > 0) {
            /* Output to logger */
            sprintf(buf, "INIT Block %d ; size: %d nniters: %d nbcalls: %d njevals: %d", 
                    block->index, block->n, nniters, block->nb_calls, block->nb_jevals);
            logger(c, instance_name, fmiOK, "DEBUG", buf);

            sprintf(buf, "INIT Block %d ; time: %f", block->index, block->time_spent);
            logger(c, instance_name, fmiOK, "TIMING", buf);
        }
    }

    /* Extract debug information from DAE blocks */
    for (i = 0; i < jmi->n_dae_blocks; i++) {
        block = jmi->dae_block_residuals[i];
        nniters = block->nb_iters;

        /* Test if block is solved by KINSOL */
        if (nniters > 0) {
            /* Output to logger */
            sprintf(buf, "SIM Block %d ; size: %d nniters: %d nbcalls: %d njevals: %d", 
                    block->index, block->n, nniters, block->nb_calls, block->nb_jevals);
            logger(c, instance_name, fmiOK, "DEBUG", buf);

            sprintf(buf,"INIT Block %d ; time: %f", block->index, block->time_spent);
            logger(c, instance_name, fmiOK, "TIMING", buf);

            
        }
    }
    /*
        for (i=0; i < jmi->n_dae_blocks;i=i+1){
            jmi_delete_block_residual(jmi->dae_block_residuals[i]);
    }*/
    return fmiOK;
}
