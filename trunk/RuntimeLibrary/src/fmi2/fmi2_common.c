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
#include "fmi2_common.h"

#include "jmi_me.h"
#include "fmiFunctionTypes.h"



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
    return 0;
}

fmiComponent fmi2_instantiate(fmiString instanceName,
                              fmiType   fmuType, 
                              fmiString fmuGUID, 
                              fmiString fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn) {
    char* str = "not implemented";
    return str;
}

void fmi2_free_instance(fmiComponent c)  {
    
}

fmiStatus fmi2_setup_experiment(fmiComponent c, 
                                fmiBoolean   toleranceDefined, 
                                fmiReal      tolerance, 
                                fmiReal      startTime, 
                                fmiBoolean   stopTimeDefined, 
                                fmiReal      stopTime) {
    return 0;
}

fmiStatus fmi2_enter_initialization_mode(fmiComponent c) {
    if (((fmi2_t *)c)->fmi_mode != instantiatedMode) {
        //Log that only from instantiatedMode one can go to initializationMode.
        return fmiError;
    }
    
    ((fmi2_t *)c) -> fmi_mode = initializationMode;
    return fmiOK;
}

fmiStatus fmi2_exit_initialization_mode(fmiComponent c) {
    if (((fmi2_t *)c)->fmi_mode != initializationMode) {
        //Log that only from initializationMode one can exit initializationMode.
        return fmiError;
    }
    if (((fmi2_t *)c)->fmi_type == fmiModelExchange) {
        ((fmi2_t *)c) -> fmi_mode = eventMode;
    } else {
        //TODO: what happens in the CS case?
    }
    return fmiOK;
}

fmiStatus fmi2_terminate(fmiComponent c) {
    return 0;
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

    retval = jmi_get_real(((fmi2_t *)c)->jmi, vr, nvr, value);
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

    retval = jmi_get_integer(((fmi2_t *)c)->jmi, vr, nvr, value);
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

    retval = jmi_get_boolean(((fmi2_t *)c)->jmi, vr, nvr, casted_values);
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

    retval = jmi_get_string(((fmi2_t *)c)->jmi, vr, nvr, value);
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
    
    retval = jmi_set_real(((fmi2_t *)c)->jmi, vr, nvr, value);
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
    
    retval = jmi_set_integer(((fmi2_t *)c)->jmi, vr, nvr, value);
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
    
    retval = jmi_set_boolean(((fmi2_t *)c)->jmi, vr, nvr, casted_values);
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
    
    retval = jmi_set_string(((fmi2_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmiError;
    }
    
    /* Strings not yet supported. */
    return fmiWarning;
}

fmiStatus fmi2_get_fmu_state(fmiComponent c, fmiFMUstate* FMUstate) {
    return 0;
}

fmiStatus fmi2_set_fmu_state(fmiComponent c, fmiFMUstate FMUstate) {
    return 0;
}

fmiStatus fmi2_free_fmu_state(fmiComponent c, fmiFMUstate* FMUstate) {
    return 0;
}

fmiStatus fmi2_serialized_fmu_state_size(fmiComponent c, fmiFMUstate FMUstate,
                                         size_t* size) {
    return 0;
}

fmiStatus fmi2_serialized_fmu_state(fmiComponent c, fmiFMUstate FMUstate,
                                    fmiByte serializedState[], size_t size) {
    return 0;
}

fmiStatus fmi2_de_serialized_fmu_state(fmiComponent c,
                                       const fmiByte serializedState[],
                                       size_t size, fmiFMUstate* FMUstate) {
    return 0;
}

fmiStatus fmi2_get_directional_derivative(fmiComponent c,
                const fmiValueReference vUnknown_ref[], size_t nUnknown,
                const fmiValueReference vKnown_ref[],   size_t nKnown,
                const fmiReal dvKnown[], fmiReal dvUnknown[]) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_directional_derivative(((fmi2_t *)c)->jmi, vUnknown_ref,
                    nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

