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
#include "fmi2_common.h"
#include "jmi_util.h"
#include "jmi.h"

fmiStatus fmi2_enter_event_mode(fmiComponent c) {
    if (((fmi2_t *)c)->fmi_mode != continuousTimeMode) {
        //Log that only from continuousTimeMode one can go to eventMode.
        return fmiError;
    }
    
    ((fmi2_t *)c) -> fmi_mode = eventMode;
    return fmiOK;
}

fmiStatus fmi2_new_discrete_state(fmiComponent  c, fmiEventInfo* fmiEventInfo) {
    fmiInteger retval;
    jmi_event_info_t* event_info;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    event_info = (jmi_event_info_t*)calloc(1, sizeof(jmi_event_info_t));
    
    retval = jmi_event_iteration(((fmi2_t *)c)->jmi, FALSE, event_info);
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
    if (((fmi2_t *)c)->fmi_mode != continuousTimeMode) {
        //Log that only from eventMode one can go to continuousTimeMode.
        return fmiError;
    }
    
    ((fmi2_t *)c) -> fmi_mode = continuousTimeMode;
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
    *terminateSimulation = fmiFalse; //Should be able to use the stopTime to determine if the simulations should stop?
    return fmiOK;
}

fmiStatus fmi2_set_time(fmiComponent c, fmiReal time) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    *(jmi_get_t(((fmi2_t *)c)->jmi)) = time;
    ((fmi2_t *)c)->jmi->recomputeVariables = 1;
    return fmiOK;
}

fmiStatus fmi2_set_continuous_states(fmiComponent c, const fmiReal x[],
                                     size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (jmi_get_real_x(((fmi2_t *)c)->jmi), x, nx*sizeof(fmiReal));
    ((fmi2_t *)c)->jmi->recomputeVariables = 1;
    return fmiOK;
}

fmiStatus fmi2_get_derivatives(fmiComponent c, fmiReal derivatives[], size_t nx) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_derivatives(((fmi2_t *)c)->jmi, derivatives, nx);
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
    
    retval = jmi_get_event_indicators(((fmi2_t *)c)->jmi, eventIndicators, ni);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}

fmiStatus fmi2_get_continuous_states(fmiComponent c, fmiReal x[], size_t nx) {
    if (c == NULL) {
		return fmiFatal;
    }
    
    memcpy (x, jmi_get_real_x(((fmi2_t *)c)->jmi), nx*sizeof(fmiReal));
    return fmiOK;
}

fmiStatus fmi2_get_nominals_of_continuous_states(fmiComponent c, 
                                                 fmiReal x_nominal[], 
                                                 size_t nx) {
    fmiInteger retval;
    
    if (c == NULL) {
		return fmiFatal;
    }
    
    retval = jmi_get_nominal_continuous_states(((fmi2_t *)c)->jmi, x_nominal, nx);
    if (retval != 0) {
        return fmiError;
    }
    
    return fmiOK;
}
