/*
    Copyright (C) 2012 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#ifndef FMI_DLL_1_0_CS_H_
#define FMI_DLL_1_0_CS_H_

#include "fmi_dll_types.h"

const char*		fmi_dll_1_0_cs_get_types_platform				(fmi_dll_t* fmu);
fmiComponent	fmi_dll_1_0_cs_instantiate_slave				(fmi_dll_t* fmu, fmiString instanceName, fmiString fmuGUID, fmiString fmuLocation, fmiString mimeType,
																 fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiBoolean loggingOn);
fmiStatus		fmi_dll_1_0_cs_initialize_slave					(fmi_dll_t* fmu, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop);
fmiStatus		fmi_dll_1_0_cs_terminate_slave					(fmi_dll_t* fmu);
fmiStatus		fmi_dll_1_0_cs_reset_slave						(fmi_dll_t* fmu);
void			fmi_dll_1_0_cs_free_slave_instance				(fmi_dll_t* fmu);
fmiStatus		fmi_dll_1_0_cs_set_real_input_derivatives		(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[]);                                                  
fmiStatus		fmi_dll_1_0_cs_get_real_output_derivatives		(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]);                                              
fmiStatus		fmi_dll_1_0_cs_cancel_step						(fmi_dll_t* fmu);
fmiStatus		fmi_dll_1_0_cs_do_step							(fmi_dll_t* fmu, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep);
fmiStatus		fmi_dll_1_0_cs_get_status						(fmi_dll_t* fmu, const fmiStatusKind s, fmiStatus*  value);
fmiStatus		fmi_dll_1_0_cs_get_real_status					(fmi_dll_t* fmu, const fmiStatusKind s, fmiReal*    value);
fmiStatus		fmi_dll_1_0_cs_get_integer_status				(fmi_dll_t* fmu, const fmiStatusKind s, fmiInteger* value);
fmiStatus		fmi_dll_1_0_cs_get_boolean_status				(fmi_dll_t* fmu, const fmiStatusKind s, fmiBoolean* value);
fmiStatus		fmi_dll_1_0_cs_get_string_status				(fmi_dll_t* fmu, const fmiStatusKind s, fmiString*  value);


const char*		fmi_dll_1_0_cs_get_version						(fmi_dll_t* fmu);
fmiStatus		fmi_dll_1_0_cs_set_debug_logging				(fmi_dll_t* fmu, fmiBoolean loggingOn);
fmiStatus		fmi_dll_1_0_cs_set_real							(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]);
fmiStatus		fmi_dll_1_0_cs_set_Integer						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus		fmi_dll_1_0_cs_set_boolean						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus		fmi_dll_1_0_cs_set_string						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
fmiStatus		fmi_dll_1_0_cs_get_real							(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiReal    value[]);
fmiStatus		fmi_dll_1_0_cs_get_integer						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus		fmi_dll_1_0_cs_get_boolean						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus		fmi_dll_1_0_cs_get_string						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

#endif /* End of header file FMI_DLL_1_0_CS_H_ */