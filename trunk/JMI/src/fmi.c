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
#include "fmi.h"
#include "fmiModelFunctions.h"
#include "fmiModelTypes.h"
#include "jmi.h"

/* Inquire version numbers of header files */
const char* fmi_get_model_types_platform() {
    return "fmiModelTypesPlatform";
}
const char* fmi_get_version() {
    return "fmiVersion";
}

/* Creation and destruction of model instances and setting debug status */
/*
fmiComponent fmi_instantiate_model(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn) 
}
*/
void fmi_free_model_instance(fmiComponent c) {
}
fmiStatus fmi_set_debug_logging(fmiComponent c, fmiBoolean loggingOn) {
    return fmiOK;
}

/* Providing independent variables and re-initialization of caching */

fmiStatus fmi_set_time(fmiComponent c, fmiReal time) {
    return fmiOK;
}
fmiStatus fmi_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx) {
    return fmiOK;
}
fmiStatus fmi_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate) {
    return fmiOK;
}
fmiStatus fmi_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    return fmiOK;
}
fmiStatus fmi_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
    return fmiOK;
}
fmiStatus fmi_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
    return fmiOK;
}
fmiStatus fmi_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]) {
    return fmiOK;
}

/* Evaluation of the model equations */

fmiStatus fmi_initialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo) {
    return fmiOK;
}
fmiStatus fmi_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
    return fmiOK;
}
fmiStatus fmi_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    return fmiOK;
}
fmiStatus fmi_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    return fmiOK;
}
fmiStatus fmi_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    return fmiOK;
}
fmiStatus fmi_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    return fmiOK;
}
fmiStatus fmi_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    return fmiOK;
}
fmiStatus fmi_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    return fmiOK;
}
fmiStatus fmi_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx) {
    return fmiOK;
}
fmiStatus fmi_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx) {
    return fmiOK;
}
fmiStatus fmi_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx) {
    return fmiOK;
}
fmiStatus fmi_terminate(fmiComponent c) {
    return fmiOK;
}

