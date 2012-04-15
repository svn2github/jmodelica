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

#ifndef FMI_DLL_1_0_ME_H_
#define FMI_DLL_1_0_ME_H_

#include "fmi_dll_types.h"

const char*		fmi_dll_1_0_me_get_model_types_platform			(fmi_dll_t* fmu);
fmiComponent	fmi_dll_1_0_me_instantiate_model				(fmi_dll_t* fmu, fmiString instanceName, fmiString GUID, fmiBoolean loggingOn);
void			fmi_dll_1_0_me_free_model_instance				(fmi_dll_t* fmu);
fmiStatus		fmi_dll_1_0_me_set_time							(fmi_dll_t* fmu, fmiReal time);
fmiStatus		fmi_dll_1_0_me_set_continuous_states			(fmi_dll_t* fmu, const fmiReal x[], size_t nx);
fmiStatus		fmi_dll_1_0_me_completed_integrator_step		(fmi_dll_t* fmu, fmiBoolean* callEventUpdate);
fmiStatus		fmi_dll_1_0_me_initialize						(fmi_dll_t* fmu, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);
fmiStatus		fmi_dll_1_0_me_get_derivatives					(fmi_dll_t* fmu, fmiReal derivatives[]    , size_t nx);
fmiStatus		fmi_dll_1_0_me_get_event_indicators				(fmi_dll_t* fmu, fmiReal eventIndicators[], size_t ni);
fmiStatus		fmi_dll_1_0_me_eventUpdate						(fmi_dll_t* fmu, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);
fmiStatus		fmi_dll_1_0_me_get_continuous_states			(fmi_dll_t* fmu, fmiReal states[], size_t nx);
fmiStatus		fmi_dll_1_0_me_get_nominal_continuous_states	(fmi_dll_t* fmu, fmiReal x_nominal[], size_t nx);
fmiStatus		fmi_dll_1_0_me_get_state_value_references		(fmi_dll_t* fmu, fmiValueReference vrx[], size_t nx);
fmiStatus		fmi_dll_1_0_me_terminate						(fmi_dll_t* fmu);

const char*		fmi_dll_1_0_me_get_version						(fmi_dll_t* fmu);
fmiStatus		fmi_dll_1_0_me_set_debug_logging				(fmi_dll_t* fmu, fmiBoolean loggingOn);
fmiStatus		fmi_dll_1_0_me_set_real							(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]);
fmiStatus		fmi_dll_1_0_me_set_Integer						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus		fmi_dll_1_0_me_set_boolean						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus		fmi_dll_1_0_me_set_string						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
fmiStatus		fmi_dll_1_0_me_get_real							(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiReal    value[]);
fmiStatus		fmi_dll_1_0_me_get_integer						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus		fmi_dll_1_0_me_get_boolean						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus		fmi_dll_1_0_me_get_string						(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, fmiString  value[]);


#endif /* End of header file FMI_DLL_1_0_ME_H_ */