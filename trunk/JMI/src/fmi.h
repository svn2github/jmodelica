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
#ifndef fmi_h
#define fmi_h

#include "fmiModelFunctions.h"
#include "jmi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Type definitions */
typedef struct {
    fmiString fmi_instance_name;
    fmiString fmi_GUID;
    fmiCallbackFunctions fmi_functions;
    fmiBoolean fmi_logging_on;
    fmiReal fmi_newton_tolerance;
    fmiReal fmi_epsilon;
    jmi_t* jmi;
} fmi_t;

/* Inquire version numbers of header files */
const char* fmi_get_model_types_platform();
const char* fmi_get_version();

/* Creation and destruction of model instances and setting debug status */
fmiComponent fmi_instantiate_model(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn);
void fmi_free_model_instance(fmiComponent c);
fmiStatus fmi_set_debug_logging(fmiComponent c, fmiBoolean loggingOn);

/* Providing independent variables and re-initialization of caching */
fmiStatus fmi_set_time(fmiComponent c, fmiReal time);
fmiStatus fmi_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx);
fmiStatus fmi_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate);
fmiStatus fmi_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]);
fmiStatus fmi_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus fmi_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus fmi_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]);

/* Evaluation of the model equations */
fmiStatus fmi_initialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);
fmiStatus fmi_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx);
fmiStatus fmi_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni);
fmiStatus fmi_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]);
fmiStatus fmi_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus fmi_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus fmi_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]);
fmiStatus fmi_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);
fmiStatus fmi_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx);
fmiStatus fmi_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx);
fmiStatus fmi_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx);
fmiStatus fmi_terminate(fmiComponent c);

#ifdef __cplusplus
}
#endif
#endif
