/*
    Copyright (C) 2009 Modelon AB

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

#ifndef FMI_1_0_ME_DLL_H
#define FMI_1_0_ME_DLL_H

#include "fmi_common_types_dll.h"

const char*		fmi_1_0_me_dll_get_model_types_platform			(DLLFMU* fmu);
fmiComponent	fmi_1_0_me_dll_instantiate_model				(DLLFMU* fmu, fmiString instanceName, fmiString GUID, fmiBoolean loggingOn);
void			fmi_1_0_me_dll_free_model_instance				(DLLFMU* fmu);
fmiStatus		fmi_1_0_me_dll_set_time							(DLLFMU* fmu, fmiReal time);
fmiStatus		fmi_1_0_me_dll_set_continuous_states			(DLLFMU* fmu, const fmiReal x[], size_t nx);
fmiStatus		fmi_1_0_me_dll_completed_integrator_step		(DLLFMU* fmu, fmiBoolean* callEventUpdate);
fmiStatus		fmi_1_0_me_dll_initialize						(DLLFMU* fmu, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);
fmiStatus		fmi_1_0_me_dll_get_derivatives					(DLLFMU* fmu, fmiReal derivatives[]    , size_t nx);
fmiStatus		fmi_1_0_me_dll_get_event_indicators				(DLLFMU* fmu, fmiReal eventIndicators[], size_t ni);
fmiStatus		fmi_1_0_me_dll_eventUpdate						(DLLFMU* fmu, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);
fmiStatus		fmi_1_0_me_dll_get_continuous_states			(DLLFMU* fmu, fmiReal states[], size_t nx);
fmiStatus		fmi_1_0_me_dll_get_nominal_continuous_states	(DLLFMU* fmu, fmiReal x_nominal[], size_t nx);
fmiStatus		fmi_1_0_me_dll_get_state_value_references		(DLLFMU* fmu, fmiValueReference vrx[], size_t nx);
fmiStatus		fmi_1_0_me_dll_terminate						(DLLFMU* fmu);

const char*		fmi_1_0_me_dll_get_version						(DLLFMU* fmu);
fmiStatus		fmi_1_0_me_dll_set_debug_logging				(DLLFMU* fmu, fmiBoolean loggingOn);
fmiStatus		fmi_1_0_me_dll_set_real							(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]);
fmiStatus		fmi_1_0_me_dll_set_Integer						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus		fmi_1_0_me_dll_set_boolean						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus		fmi_1_0_me_dll_set_string						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
fmiStatus		fmi_1_0_me_dll_get_real							(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiReal    value[]);
fmiStatus		fmi_1_0_me_dll_get_integer						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus		fmi_1_0_me_dll_get_boolean						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus		fmi_1_0_me_dll_get_string						(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, fmiString  value[]);


#endif /* End of header file FMI_1_0_ME_DLL_H */