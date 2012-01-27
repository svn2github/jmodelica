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

#ifndef FMI_1_0_CS_DLL_H
#define FMI_1_0_CS_DLL_H

#include "fmi_common_types_dll.h"

const char*		fmi_1_0_cs_dll_get_types_platform				(DLLFMU* fmu);
fmiComponent	fmi_1_0_cs_dll_instantiate_slave				(DLLFMU* fmu, fmiString instanceName, fmiString fmuGUID, fmiString fmuLocation, fmiString mimeType,
																 fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiBoolean loggingOn);
fmiStatus		fmi_1_0_cs_dll_initialize_slave					(DLLFMU* fmu, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop);
fmiStatus		fmi_1_0_cs_dll_terminate_slave					(DLLFMU* fmu);
fmiStatus		fmi_1_0_cs_dll_reset_slave						(DLLFMU* fmu);
void			fmi_1_0_cs_dll_free_slave_instance				(DLLFMU* fmu);
fmiStatus		fmi_1_0_cs_dll_set_real_input_derivatives		(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[]);                                                  
fmiStatus		fmi_1_0_cs_dll_get_real_output_derivatives		(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]);                                              
fmiStatus		fmi_1_0_cs_dll_cancel_step						(DLLFMU* fmu);
fmiStatus		fmi_1_0_cs_dll_do_step							(DLLFMU* fmu, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep);
fmiStatus		fmi_1_0_cs_dll_get_status						(DLLFMU* fmu, const fmiStatusKind s, fmiStatus*  value);
fmiStatus		fmi_1_0_cs_dll_get_real_status					(DLLFMU* fmu, const fmiStatusKind s, fmiReal*    value);
fmiStatus		fmi_1_0_cs_dll_get_integer_status				(DLLFMU* fmu, const fmiStatusKind s, fmiInteger* value);
fmiStatus		fmi_1_0_cs_dll_get_boolean_status				(DLLFMU* fmu, const fmiStatusKind s, fmiBoolean* value);
fmiStatus		fmi_1_0_cs_dll_get_string_status				(DLLFMU* fmu, const fmiStatusKind s, fmiString*  value);


const char*		fmi_1_0_cs_dll_get_version						(DLLFMU* fmu);
fmiStatus		fmi_1_0_cs_dll_set_debug_logging				(DLLFMU* fmu, fmiBoolean loggingOn);
fmiStatus		fmi_1_0_cs_dll_set_real							(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]);
fmiStatus		fmi_1_0_cs_dll_set_Integer						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus		fmi_1_0_cs_dll_set_boolean						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus		fmi_1_0_cs_dll_set_string						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
fmiStatus		fmi_1_0_cs_dll_get_real							(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiReal    value[]);
fmiStatus		fmi_1_0_cs_dll_get_integer						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus		fmi_1_0_cs_dll_get_boolean						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus		fmi_1_0_cs_dll_get_string						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

#endif /* End of header file FMI_1_0_CS_DLL_H */