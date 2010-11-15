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

static unsigned int get_index_from_value_ref(unsigned int valueref) {
    /* Translate a ValueReference into variable index in z-vector. */
    unsigned int index = valueref & indexmask;
    
    return index;
}

static unsigned int get_type_from_value_ref(unsigned int valueref) {
    /* Translate a ValueReference into variable type in z-vector. */
    unsigned int type = valueref & typemask;
    
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
    
    /* Create jmi struct*/
    jmi_t* jmi = (jmi_t *)functions.allocateMemory(1, sizeof(jmi_t));
    int retval = jmi_new(&jmi);
    if(retval != 0) {
        /* creating jmi struct failed */
        return NULL;
    }
    
    fmi_t *component;
    component = (fmi_t *)functions.allocateMemory(1, sizeof(fmi_t));
    
    char* tmpname = (char*)(fmi_t *)functions.allocateMemory(strlen(instanceName)+1, sizeof(char));
    strcpy(tmpname, instanceName);
    component -> fmi_instance_name = tmpname;

    char* tmpguid = (char*)(fmi_t *)functions.allocateMemory(strlen(GUID)+1, sizeof(char));
    strcpy(tmpguid, GUID);
    component -> fmi_GUID = tmpguid;
    
    component -> fmi_functions = functions;
    component -> fmi_logging_on = loggingOn;
    component -> jmi = jmi;
        
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
    return fmiOK;
}
fmiStatus fmi_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx) {
	memcpy (jmi_get_real_x(((fmi_t *)c)->jmi), x, nx*sizeof(fmiReal));
    return fmiOK;
}
fmiStatus fmi_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate) {
    return fmiOK;
}
fmiStatus fmi_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    int i;
    unsigned int index;
    
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
    
    int i;
    unsigned int index;
    
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
    
    int i;
    unsigned int index;
    
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
	int retval = jmi_ode_initialize(((fmi_t *)c)->jmi);
    ((fmi_t *)c) -> fmi_epsilon=0.0001*relativeTolerance; //Used in the event detection

	if(retval != 0) {
		(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Initialization failed.");
		return fmiError;
	}
    return fmiOK;
}
fmiStatus fmi_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
	int retval = jmi_ode_derivatives(((fmi_t *)c)->jmi);
	if(retval != 0) {
		(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the derivatives failed.");
		return fmiError;
	}
	memcpy (derivatives, jmi_get_real_dx(((fmi_t *)c)->jmi), nx*sizeof(fmiReal));
	return fmiOK;
}
fmiStatus fmi_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    int retval = jmi_dae_R(((fmi_t *)c)->jmi,eventIndicators);
    jmi_real_t *switches = jmi_get_sw(((fmi_t *)c)->jmi);

	if(retval != 0) {
		(((fmi_t *)c) -> fmi_functions).logger(c, ((fmi_t *)c)->fmi_instance_name, fmiError, "ERROR", "Evaluating the event indicators failed.");
		return fmiError;
	}
    int i;
    
    for (i = 0; i < ni; i=i+1){
        if (switches[i] == 1){
            eventIndicators[i] = eventIndicators[i]/1.0+((fmi_t *)c)->fmi_epsilon; //MISSING DIVIDING WITH NOMINAL
        }else{
            eventIndicators[i] = eventIndicators[i]/1.0-((fmi_t *)c)->fmi_epsilon; //MISSING DIVIDING WITH NOMINAL
        }
    }
    
    return fmiOK;
}
fmiStatus fmi_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    /* Get the z vector*/
    jmi_real_t* z = jmi_get_z(((fmi_t *)c)->jmi);
    
    int i;
    unsigned int index;
    
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
    
    int i;
    unsigned int index;
    
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
    
    int i;
    unsigned int index;
    
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
fmiStatus fmi_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    return fmiOK;
}
fmiStatus fmi_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx) {
	memcpy (states, jmi_get_real_x(((fmi_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}
fmiStatus fmi_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx) {
	fmiReal ones[nx];
	int i;
	for(i = 0; i <nx; i = i + 1) {
		ones[i]=1.0;
	}
	memcpy (x_nominal, ones, nx*sizeof(fmiReal));
    return fmiOK;
}
fmiStatus fmi_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx) {
	int offset = ((fmi_t *)c)->jmi->offs_real_x;
	fmiValueReference valrefs[nx];
	int i;
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
