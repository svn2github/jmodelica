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

/** \file fmi_cs.h
 *  \brief The public FMI co-simulation interface.
 **/

#ifndef fmi_cs_h
#define fmi_cs_h

#include "fmi1_functions.h"
#include "jmi.h"

/**
 * \defgroup fmi_cs_public Public functions of the Functional Mock-up Interface for co-simulation.
 *
 * \brief Documentation of the public functions and data structures
 * of the Functional Mock-up Interface for co-simulation.
 */

/* @{ */

#ifdef __cplusplus
extern "C" {
#endif

const char* fmi_get_types_platform();

fmiStatus fmi_do_step(fmiComponent c,
						 fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep);
void fmi_free_slave_instance(fmiComponent c);
fmiComponent fmi_instantiate_slave(fmiString instanceName, fmiString GUID, fmiString fmuLocation, fmiString mimeType, 
                                   fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiCallbackFunctions functions, 
                                   fmiBoolean loggingOn);
fmiStatus fmi_terminate_slave(fmiComponent c);
fmiStatus fmi_initialize_slave(fmiComponent c, fmiReal tStart,fmiBoolean StopTimeDefined, fmiReal tStop);
fmiStatus fmi_cancel_step(fmiComponent c);
fmiStatus fmi_reset_slave(fmiComponent c) ;
fmiStatus fmi_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]);
fmiStatus fmi_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]);
fmiStatus fmi_get_status(fmiComponent c, const fmiStatusKind s, fmiStatus* value);
fmiStatus fmi_get_real_status(fmiComponent c, const fmiStatusKind s, fmiReal* value);
fmiStatus fmi_get_integer_status(fmiComponent c, const fmiStatusKind s, fmiInteger* value);
fmiStatus fmi_get_boolean_status(fmiComponent c, const fmiStatusKind s, fmiBoolean* value);
fmiStatus fmi_get_string_status(fmiComponent c, const fmiStatusKind s, fmiString* value);

/* Note in fmiCSFunctions.h
fmiStatus fmi_save_state(fmiComponent c, size_t index);
fmiStatus fmi_restore_state(fmiComponent c, size_t index);
*/
/* @} */

#ifdef __cplusplus
}
#endif
#endif
