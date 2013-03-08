/*
    Copyright (C) 2011 Modelon AB

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
#include "fmi_cs.h" 

const char* fmi_get_types_platform() {
    return fmiPlatform;
}


fmiStatus fmi_do_step(fmiComponent c,
						 fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep) {
	return fmiError;
}

void fmi_free_slave_instance(fmiComponent c) {
    return;
}

fmiComponent fmi_instantiate_slave(fmiString instanceName, fmiString GUID, fmiString fmuLocation, fmiString mimeType, 
                                   fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiCallbackFunctions functions, 
                                   fmiBoolean loggingOn) {
    return NULL;
}


fmiStatus fmi_terminate_slave(fmiComponent c) {
    return fmiError;
}

fmiStatus fmi_initialize_slave(fmiComponent c, fmiReal tStart,
                                    fmiBoolean StopTimeDefined, fmiReal tStop){
    return fmiError;
}

fmiStatus fmi_cancel_step(fmiComponent c){
    return fmiError;
}

fmiStatus fmi_reset_slave(fmiComponent c) {
    return fmiError;
}

fmiStatus fmi_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]){
    return fmiError;
}

fmiStatus fmi_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]){
    return fmiError;
}

fmiStatus fmi_get_status(fmiComponent c, const fmiStatusKind s, fmiStatus* value){
    return fmiError;
}

fmiStatus fmi_get_real_status(fmiComponent c, const fmiStatusKind s, fmiReal* value){
    return fmiError;
}

fmiStatus fmi_get_integer_status(fmiComponent c, const fmiStatusKind s, fmiInteger* value){
    return fmiError;
}

fmiStatus fmi_get_boolean_status(fmiComponent c, const fmiStatusKind s, fmiBoolean* value){
    return fmiError;
}

fmiStatus fmi_get_string_status(fmiComponent c, const fmiStatusKind s, fmiString* value){
    return fmiError;
}

/*
fmiStatus fmi_save_state(fmiComponent c, size_t index){
    return fmiError;
}

fmiStatus fmi_restore_state(fmiComponent c, size_t index){
    return fmiError;
}
*/
