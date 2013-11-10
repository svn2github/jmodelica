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
    return 0;
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
    fmiInteger retval;
    fmi2_cs_t* fmi2_cs;
    jmi_t* jmi;
    jmi_ode_problem_t* ode_problem = 0;
    
    retval = fmi2_me_instantiate(c, instanceName, fmuType, fmuGUID, 
                                fmuResourceLocation, functions, visible,
                                loggingOn);
    if (retval != fmiOK) {
        return retval;
    }
    
    jmi = ((fmi2_me_t*)c) -> jmi;
    fmi2_cs = (fmi2_cs_t*)c;
    jmi_new_ode_problem(&ode_problem, c, jmi->n_real_x, jmi->n_sw, jmi->n_real_u, jmi->log);
    fmi2_cs -> ode_problem = ode_problem;
    
    return fmiOK;
}

/* Helper method for fmi2_free_instance. */
void fmi2_cs_free_instance(fmiComponent c) {
    fmi2_me_free_instance(c);
    jmi_free_ode_problem(((fmi2_cs_t*)c) -> ode_problem);
    
}
