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

#ifdef _WIN32
  #include <windows.h>
#else
  #define _GNU_SOURCE
  #include <dlfcn.h>
#endif

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include "fmi1_me.h"
#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_log.h"
#include "jmi_me.h"

/* Inquire version numbers of header files */
const char* fmi1_me_get_model_types_platform() {
    return fmiModelTypesPlatform;
}
const char* fmi1_me_get_version() {
    return fmiVersion;
}

/* Local helpers for fmi1_me_instantiate_model */
int jmi_find_parent_dir(char* path, const char* dir) {
    int found = 0;
    int dir_level = 3;
    int c_i = strlen(path) - 1;
    
    while(dir_level > 0 && !found) {
        while(c_i > 0 && path[c_i] != '\\' && path[c_i] != '/')
            c_i--;
        if (c_i <= 0)
            break;
        if (strcmp(&path[c_i+1],dir) == 0)
            found = 1;
        path[c_i]= '\0';
        c_i--;
        dir_level--;
    }
    
    return found;
}

union jmi_func_cast {
	void* x;
	char* (*y)();
};

void* jmi_func_to_voidp(char* (*y)()) {
	union jmi_func_cast jfc;
	assert(sizeof(jfc.x)==sizeof(jfc.y));
	jfc.y = y;
	return jfc.x;
}
 
char* jmi_locate_resources(void* (*allocateMemory)(size_t nobj, size_t size)) {
    int found;
    char *resource_dir = "/resources";
    char *binary_dir = "binaries";
    char *res;
    char path[JMI_PATH_MAX];
    char *resolved = path;
    
#ifdef _WIN32
    EXTERN_C IMAGE_DOS_HEADER __ImageBase;
    GetModuleFileName((HINSTANCE)&__ImageBase, path, MAX_PATH);
#else
    Dl_info info;
    dladdr(jmi_func_to_voidp(jmi_locate_resources), &info);
    resolved = realpath(info.dli_fname, path);
    if (!resolved)
        return NULL;
#endif
    
    found = jmi_find_parent_dir(resolved, binary_dir);
    
    if (!found)
        return NULL;
    
    strcat(resolved, resource_dir);
    
    if (!jmi_dir_exists(resolved))
        return NULL;
    
    res = allocateMemory(strlen(resolved)+1,sizeof(char));
    strcpy(res, resolved);
    return res;
}

/* Creation and destruction of model instances and setting debug status */
fmiComponent fmi1_me_instantiate_model(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn) {

    fmi1_me_t *component;
    jmi_callbacks_t* cb;
    char* tmpname;
    char* resource_location;
    size_t inst_name_len;

    /* Create jmi struct -> No need  since jmi_init allocates it
     jmi_t* jmi = (jmi_t *)functions.allocateMemory(1, sizeof(jmi_t)); */
    fmiInteger retval;

    if(!functions.allocateMemory || !functions.freeMemory || !functions.logger) {
         if(functions.logger) {
             /* We have to use the raw logger callback here; the logger in the jmi_t struct is not yet initialized. */
             functions.logger(0, instanceName, fmiError, "ERROR", "Memory management functions allocateMemory/freeMemory are required.");
         }
         return 0;
    }
    
    component = (fmi1_me_t *)functions.allocateMemory(1, sizeof(fmi1_me_t));
    if(!component) {
         if(functions.logger) {
             /* We have to use the raw logger callback here; the logger in the jmi_t struct is not yet initialized. */
             functions.logger(0, instanceName, fmiError, "ERROR", "Could not allocate memory for the model instance.");
         }
         return 0;
    }
    component->fmi_functions = functions;
    cb = &component->jmi.jmi_callbacks;

    cb->emit_log = fmi1_me_emit_log;
    cb->is_log_category_emitted = fmi1_me_is_log_category_emitted;
    cb->log_options.logging_on_flag = loggingOn;
    cb->log_options.log_level = 5;
    cb->allocate_memory = functions.allocateMemory;
    cb->free_memory = functions.freeMemory;
    cb->model_name = jmi_get_model_identifier();       /**< \brief Name of the model (corresponds to a fixed compiled unit name) */
    cb->instance_name = instanceName;    /** < \brief Name of this model instance. */
    cb->model_data = component;
    
    resource_location = jmi_locate_resources(functions.allocateMemory);
    if (!resource_location)
        functions.logger(0, instanceName, fmiWarning, "Warning", "Could not find resource location.");
    
    retval = jmi_me_init(cb, &component->jmi, GUID, resource_location);
    
    if (retval != 0) {
        functions.freeMemory(component);
        return NULL;
    }

    inst_name_len = strlen(instanceName)+1;
    tmpname = (char*)(fmi1_me_t *)functions.allocateMemory(inst_name_len, sizeof(char));
    strncpy(tmpname, instanceName, inst_name_len);
    component -> fmi_instance_name = tmpname;
    
    return component;
}

void fmi1_me_free_model_instance(fmiComponent c) {
    /* Dispose the given model instance and deallocated all the allocated memory and other resources 
     * that have been allocated by the functions of the Model Exchange Interface for instance "c".*/
    fmi1_me_t* component;
    fmiCallbackFreeMemory fmi_free;
    if (c) {
        component = (fmi1_me_t*)c;
        fmi_free = component -> fmi_functions.freeMemory;

        fmi_free(component->jmi.resource_location);
        jmi_delete(&component->jmi);
        fmi_free((void*)component -> fmi_instance_name);
        fmi_free(component);
    }
}

fmiStatus fmi1_me_set_debug_logging(fmiComponent c, fmiBoolean loggingOn) {
    fmi1_me_t* self = (fmi1_me_t*)c;
    if (c == NULL) {
		return fmiFatal;
    }
    
    self->jmi.jmi_callbacks.log_options.logging_on_flag = loggingOn;
    return fmiOK;
}

/* Providing independent variables and re-initialization of caching */

fmiStatus fmi1_me_set_time(fmiComponent c, fmiReal time) {
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    jmi_real_t* time_old = (jmi_get_t(jmi));
    if (c == NULL) {
		return fmiFatal;
    }
    
    if (*time_old != time) {
        *time_old = time;
        jmi->recomputeVariables = 1;
    }
    /* *(jmi_get_t(jmi)) = time; 
    jmi->recomputeVariables = 1; */
    return fmiOK;
}

fmiStatus fmi1_me_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx) {
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    jmi_real_t* x_cur = jmi_get_real_x(jmi);
    fmiInteger i;
    if (c == NULL) {
		return fmiFatal;
    }
    
    for (i = 0; i < nx; i++){
        if (x_cur[i] != x[i]){
            x_cur[i] = x[i];
            jmi->recomputeVariables = 1;
        }
    }
    /* memcpy (jmi_get_real_x(jmi), x, nx*sizeof(fmiReal));
    jmi->recomputeVariables = 1; */
    return fmiOK;
}

fmiStatus fmi1_me_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate) {
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    fmiInteger retval;
    fmiReal triggered_event;
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_completed_integrator_step(jmi, &triggered_event);
    if (retval != 0) {
        return fmiError;
    }
    
    if (triggered_event == 1.0){
        *callEventUpdate = fmiTrue;
    }else{
        *callEventUpdate = fmiFalse;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_set_real(jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
     fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
   fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_set_integer(jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
     fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
   fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_set_boolean(jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]) {
     fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
   fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_set_string(jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    /* Strings not yet supported. */
    return fmiWarning;
}

/* Evaluation of the model equations */

fmiStatus fmi1_me_initialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo) {
    fmiInteger retval;
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    
    /* For debugging Jacobians */
/*
    int n_states;
    jmi_real_t* jac;
    int j;
*/
    
    if (c == NULL) {
		return fmiFatal;
    }

    jmi_setup_experiment(jmi, toleranceControlled, relativeTolerance);
    
    retval = jmi_initialize(jmi);
    if (retval != 0) {
        return fmiError;
    }
    
    /* Initialization is now complete, but we also need to handle events
     * at the start of the integration.
     */
    retval = fmi1_me_event_update(c, fmiFalse, eventInfo);
    if(retval == fmiError) {
        jmi_log_comment(jmi->log, logError, "Event iteration failed during the initialization.");
        return fmiError;
    }

    /* For debugging Jacobians */
/*
    n_states = ((fmi1_me_t *)c)->jmi->n_real_x;
    jac = (jmi_real_t*)calloc(n_states*n_states,sizeof(jmi_real_t));
    fmi_get_jacobian(c, FMI_STATES, FMI_DERIVATIVES, jac, n_states);

    for (i=0;i<n_states;i++) {
        for (j=0;j<n_states;j++) {
            printf("%f, ",jac[i + j*n_states]);
        }
        printf("\n");
    }

    free(jac);
*/



    return fmiOK;
}

fmiStatus fmi1_me_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
    fmiInteger retval;
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_derivatives(jmi, derivatives, nx);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    fmiInteger retval;
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_event_indicators(jmi, eventIndicators, ni);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_get_partial_derivatives(fmiComponent c, fmiStatus (*setMatrixElement)(void* data, fmiInteger row, fmiInteger col, fmiReal value), void* A, void* B, void* C, void* D){    

/* fmi_get_jacobian is not an FMI function. Still use fmiStatus as return arguments?. Is there an error handling policy? Standard messages? Which function should return errors?*/
    
    fmiStatus fmiFlag;
    fmiReal* jac;
    fmi1_me_t* fmi1_me = (fmi1_me_t*)c;
    jmi_t* jmi = &fmi1_me->jmi;
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

    clock_t /*c0, c1,*/ d0, d1;
    jmi_real_t setElementTime;

    /* c0 = clock(); */

    setElementTime = 0;

    /* Get number of outputs that are variability = "continuous", ny */
    n_outputs = ny = jmi->n_outputs;
    if (!(output_vrefs = (int*)fmi1_me -> fmi_functions.allocateMemory(n_outputs, sizeof(int)))) {
        jmi_log_comment(jmi->log, logError, "Out of memory.");
        return fmiError;
    }
        
    jmi_get_output_vrefs(jmi, output_vrefs);

    /* This analysis needs to be extended to account for discrete reals*/
    for(i = 0; i < n_outputs; i++)
        if (get_type_from_value_ref(output_vrefs[i])!= 0)
            ny--;   
    fmi1_me -> fmi_functions.freeMemory(output_vrefs);
    
    nx = jmi->n_real_x;
    nu = jmi->n_real_u;
    
    nA = nx*nx;
    nB = nx*nu;
    nC = ny*nx;
    nD = ny*nu;

    /*
    if (fmi1_me -> fmi_logging_on) {
        jmi_log_node(jmi->log, logInfo, "size_of_A", "<m: %d, n:%d>", nx, nx);
        jmi_log_node(jmi->log, logInfo, "size_of_B", "<m: %d, n:%d>", nx, nu);
        jmi_log_node(jmi->log, logInfo, "size_of_C", "<m: %d, n:%d>", ny, nx);
        jmi_log_node(jmi->log, logInfo, "size_of_D", "<m: %d, n:%d>", ny, nu);
    }
     */

    /* Allocate a big chunk of memory that is enough to compute all Jacobians */
    jac_size = nA + nB + nC + nD;

    /* Allocate memory for the biggest matrix, use this for all matrices. */
    if (!(jac = fmi1_me -> fmi_functions.allocateMemory(sizeof(fmiReal),jac_size))) {
        jmi_log_comment(jmi->log, logError, "Out of memory.");
        return fmiError;
    }

    /* Individual calls to evaluation of A, B, C, D matrices can be made
     * more efficiently by evaluating several Jacobian at the same time.
     */

    /* Get the internal A matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_STATES, FMI_DERIVATIVES, jac, nA); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the A matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }

    /* Update external A matrix */
    for (row=0;row<nx;row++) {
        for (col=0;col<nx;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(A,row+1,col+1,jac[row + col*nx]);
            d1 = clock();
            setElementTime += ((fmiReal)(d1-d0))/(CLOCKS_PER_SEC);
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix A");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    /* Get the internal B matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_INPUTS, FMI_DERIVATIVES, jac, nB); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the B matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }
    /* Update external B matrix */
    for (row=0;row<nx;row++) {
        for (col=0;col<nu;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(B,row+1,col+1,jac[row + col*nx]);
            d1 = clock();
            setElementTime += ((fmiReal)(d1-d0))/(CLOCKS_PER_SEC);
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix B");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    /* Get the internal C matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_STATES, FMI_OUTPUTS, jac, nC); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the C matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }
    /* Update external C matrix */
    for (row=0;row<ny;row++) {
        for (col=0;col<nx;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(C,row + 1, col + 1, jac[row+col*ny]);
            d1 = clock();
            setElementTime += ((fmiReal)(d1-d0))/(CLOCKS_PER_SEC);
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix C");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    /* Get the internal D matrix */
    fmiFlag = fmi1_me_get_jacobian(c, FMI_INPUTS, FMI_OUTPUTS, jac, nD); 
    if (fmiFlag > fmiWarning) {
        jmi_log_comment(jmi->log, logError, "Evaluating the D matrix failed.");
        fmi1_me -> fmi_functions.freeMemory(jac);
        return fmiFlag;
    }
    /* Update external D matrix */
    for (row=0;row<ny;row++) {
        for (col=0;col<nu;col++) {
            d0 = clock();
            fmiFlag = setMatrixElement(D,row + 1, col + 1,jac[row + col*ny]);
            d1 = clock();
            setElementTime += ((fmiReal) ((long)(d1-d0))/(CLOCKS_PER_SEC));
            if (fmiFlag > fmiWarning) {
                jmi_log_comment(jmi->log, logError, "setMatrixElement failed to update matrix D");
                fmi1_me -> fmi_functions.freeMemory(jac);
                return fmiFlag;
            }
        }
    }

    fmi1_me -> fmi_functions.freeMemory(jac);

    /* c1 = clock(); */
    /*printf("Jac eval call: %f\n", ((fmiReal) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/
    /*printf(" - setMatrixElementTime: %f\n", setElementTime);*/
    return fmiOK;
}

/*Evaluates the A, B, C and D matrices using finite differences, this functions has
only been used for debugging purposes*/
fmiStatus fmi1_me_get_jacobian_fd(fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac){
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
    
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    
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
    
    for(i = 0; (size_t)i < nvvr; i++){
        k = 0;
        if((*(jmi->z))[offs+i] != 0){
            h = (*(jmi->z))[offs+i]*0.000000015;
        }else{
            h = 0.000001;
        }
        (*(jmi->z))[offs+i] += h;
        jmi->block_level = 0; /* to recover from errors */        
        jmi_generic_func(jmi, jmi->dae->ode_derivatives);
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
        jmi->block_level = 0; /* to recover from errors */
        
        jmi_generic_func(jmi, jmi->dae->ode_derivatives);
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
        
        for(j = 0; (size_t)j < nzvr;j++){
            jac[i*nzvr+j] = (z1[j] - z2[j])/(2*h);
        }
        
    }
    
    free(output_vrefs);
    free(output_vrefs2);
    free(z1);
    free(z2);
    
    return fmiOK;
}

/*Evaluates the A, B, C and D matrices*/
fmiStatus fmi1_me_get_jacobian(fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac) {
    
    int i;
    int j;
    int k;
    int index;
    int output_off = 0;
    
    /*
    int passed = 0;
    int failed = 0;
    */
    
/**    fmiReal rel_tol;
    fmiReal abs_tol; */
    
    int offs;
    jmi_real_t** dv;
    jmi_real_t** dz;


    /*Used for debugging 
    fmiReal tol = 0.001;    
    fmiReal* jac2;*/
    
    size_t nvvr = 0;
    size_t nzvr = 0;
    
    int n_outputs;
    int* output_vrefs;
    int n_outputs_real;
    int* output_vrefs_real;
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    /* clock_t c0, c1; */

    /* c0 = clock(); */
    n_outputs = jmi->n_outputs;
    n_outputs_real = n_outputs;
    
    /*dv and the dz are stored in the same vector*/
    dv = jmi->dz;
    dz = jmi->dz;
    
    /* Used for debbugging
    jac2 = (fmiReal*)calloc(njac, sizeof(fmiReal));
    */
    
    offs = jmi->n_real_dx;
    
    for(i = 0; i<jmi->n_real_dx+jmi->n_real_x+jmi->n_real_u+jmi->n_real_w;i++){
        (*dz)[i] = 0;
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
            for (j=0;j<jmi->n_v;j++) {
                printf(" * %d %f\n",j,(*(jmi->dz))[j]);
            }
            */
            /* Evaluate directional derivative */
            if (i==0) {
                jmi->cached_block_jacobians = 0;
            } else {
                jmi->cached_block_jacobians = 1;
            }
            jmi->block_level = 0; /* to recover from errors */
            
            jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);
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
        /* c1 = clock(); */

        /*printf("Jac A eval call: %f\n", ((fmiReal) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/

    } else {

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
        for(i = 0; (size_t)i < nvvr; i++){
            (*dv)[i+offs] = 1;
            jmi->block_level = 0; /* to recover from errors */

            /*Evaluate directional derivative*/
            jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);

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

        free(output_vrefs);
        free(output_vrefs_real);

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
    
    /*
    c1 = clock();
    */
    
    /*printf("Jac eval call: %f\n", ((fmiReal) ((long)(c1-c0))/(CLOCKS_PER_SEC)));*/
    return fmiOK;
}

/*Evaluate the directional derivative dz/dv dv*/
fmiStatus fmi1_me_get_directional_derivative(fmiComponent c, const fmiValueReference z_vref[], size_t nzvr, const fmiValueReference v_vref[], size_t nvvr, fmiReal dz[], const fmiReal dv[]) {
    fmiInteger retval;
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_directional_derivative(jmi,
                                            z_vref, nzvr, v_vref, nvvr,
                                            dv, dz);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    fmiInteger retval;
    fmi1_me_t* self = (fmi1_me_t*)c;
    jmi_t* jmi = &self->jmi;

    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_real(jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }

    return fmiOK;
}

fmiStatus fmi1_me_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_integer(&((fmi1_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_boolean(&((fmi1_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }

    retval = jmi_get_string(&((fmi1_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }

    /* Strings not yet supported. */
    return fmiWarning;
}

jmi_t* fmi1_me_get_jmi_t(fmiComponent c) {
    return &((fmi1_me_t*)c)->jmi;
}

fmiStatus fmi1_me_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    fmiInteger retval;
    jmi_event_info_t* event_info;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    event_info = (jmi_event_info_t*)calloc(1, sizeof(jmi_event_info_t));
    
    retval = jmi_event_iteration(&((fmi1_me_t *)c)->jmi, intermediateResults, event_info);
    if (retval != 0) {
        free(event_info);
        return fmiError;
    }
    
    eventInfo->iterationConverged          = event_info->iteration_converged;
    eventInfo->stateValueReferencesChanged = event_info->state_value_references_changed;
    eventInfo->stateValuesChanged          = event_info->state_values_changed;
    eventInfo->terminateSimulation         = event_info->terminate_simulation;
    eventInfo->upcomingTimeEvent           = event_info->next_event_time_defined;
    eventInfo->nextEventTime               = event_info->next_event_time;
    
    free(event_info);
    
    return fmiOK;
}

fmiStatus fmi1_me_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (states, jmi_get_real_x(&((fmi1_me_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi1_me_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_nominal_continuous_states(&((fmi1_me_t *)c)->jmi, x_nominal, nx);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi1_me_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx) {
    fmiInteger offset;
    fmiValueReference i;
    
    if (c == NULL) {
		return fmiFatal;
    }
        
    offset = ((fmi1_me_t *)c)->jmi.offs_real_x;
    
    for(i = 0; i<nx; i = i + 1) {
        vrx[i] = offset + i;
    }
    return fmiOK;
}

fmiStatus fmi1_me_terminate(fmiComponent c) {
    /* Release all resources that have been allocated since fmi_initialize has been called. */
    jmi_terminate(&((fmi1_me_t *)c)->jmi);
    return fmiOK;
}

static fmiStatus category_to_fmiStatus(jmi_log_category_t c) {
    switch (c) {
    case logError:   return fmiError;
    case logWarning: return fmiWarning;
    case logInfo:    return fmiOK;
    default:         return fmiError;
    }
}

static const char *category_to_fmiCategory(jmi_log_category_t c) {
    switch (c) {
    case logError:   return "ERROR";
    case logWarning: return "WARNING";
    case logInfo:    return "INFO";
    default:         return "UNKNOWN CATEGORY";
    }
}

void fmi1_me_emit_log(jmi_callbacks_t* jmi_callbacks, jmi_log_category_t category, jmi_log_category_t severest_category, char* message) {

    fmi1_me_t* c = (fmi1_me_t*)(jmi_callbacks->model_data);
  
    if(c){
        if(c->fmi_functions.logger)
            c->fmi_functions.logger(c,jmi_callbacks->instance_name, 
                                    category_to_fmiStatus(category),
                                    category_to_fmiCategory(severest_category),
                                    "%s", message); /* prevent interpretation of message as format string */
    } else {
        switch (category) {
            case logError:
                fprintf(stderr, "<!-- ERROR:   --> %s\n", message);
            break;
            case logWarning:
                fprintf(stderr, "<!-- WARNING: --> %s\n", message);
            break;
            case logInfo:
                fprintf(stdout, "%s\n", message);
            break;
        }
    }
}

BOOL fmi1_me_is_log_category_emitted(jmi_callbacks_t* cb, jmi_log_category_t category) {

    jmi_callbacks_t* jmi_callbacks = cb;
    fmi1_me_t * self = (fmi1_me_t *)cb->model_data;
    if ((self != NULL) && !jmi_callbacks->log_options.logging_on_flag) {
        return FALSE;
    }
    
    switch (category) {
        case logError:   break;
        case logWarning: if(cb->log_options.log_level < 3) return FALSE; break;
        case logInfo:    if(cb->log_options.log_level < 4) return FALSE; break;
    }
    return TRUE;
}

fmiStatus fmi1_me_extract_debug_info(fmiComponent c) {
    fmiInteger nniters;
/*    fmiReal avg_nniters; */
    fmi1_me_t* fmi1_me = ((fmi1_me_t*)c);
    jmi_t* jmi = &fmi1_me->jmi;
    jmi_block_residual_t* block;
    int i;
    jmi_log_node_t topnode = jmi_log_enter(jmi->log, logInfo, "FMIDebugInfo");
    
    /* Extract debug information from initialization*/
    for (i = 0; i < jmi->n_dae_init_blocks; i++) {
        block = jmi->dae_init_block_residuals[i];
        nniters = block->nb_iters;

        /* Test if block is solved by KINSOL */
        if (nniters > 0) {
            /* Output to logger */
            jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "initialization");
            jmi_log_fmt(jmi->log, node, logInfo, "<block: %d, size: %d, nniters: %d, nbcalls: %d, njevals: %d, nfevals: %d>", 
                        block->index, block->n, (int)nniters, (int)block->nb_calls, (int)block->nb_jevals, (int)block->nb_fevals);
            jmi_log_fmt(jmi->log, node, logInfo, "<time_spent: %f>", block->time_spent);
            jmi_log_leave(jmi->log, node);
        }
    }

    /* Extract debug information from DAE blocks */
    for (i = 0; i < jmi->n_dae_blocks; i++) {
        block = jmi->dae_block_residuals[i];
        nniters = block->nb_iters;

        /* Test if block is solved by KINSOL */
        if (nniters > 0) {
            /* Output to logger */
            /* NB: Exactly the same code as above. Todo: factor out? */
            jmi_log_node_t node = jmi_log_enter(jmi->log, logInfo, "dae_blocks");
            jmi_log_fmt(jmi->log, node, logInfo, "<block: %d, size: %d, nniters: %d, nbcalls: %d, njevals: %d, nfevals: %d>", 
                        block->index, block->n, (int)nniters, (int)block->nb_calls, (int)block->nb_jevals, (int)block->nb_fevals);
            jmi_log_fmt(jmi->log, node, logInfo, "<time_spent: %f>", block->time_spent);
            jmi_log_leave(jmi->log, node);            
        }
    }
    /*
        for (i=0; i < jmi->n_dae_blocks;i=i+1){
            jmi_delete_block_residual(jmi->dae_block_residuals[i]);
    }*/

    jmi_log_leave(jmi->log, topnode);

    return fmiOK;
}
