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


#include "fmi_common_types_dll.h"
#include "fmi_1_0_me_dll.h"

fmiComponent fmi_1_0_me_dll_instantiate_model(DLLFMU* fmu, fmiString instanceName, fmiString GUID, fmiBoolean loggingOn)
{
	/* Instantiate model */
	if (!fmu || !fmu->fmu_me1) {
		return NULL;
	} else {
		fmu->fmu_me1->c = fmu->fmu_me1->fmiInstantiateModel(instanceName, GUID, fmu->callBackFunctions, loggingOn);
		if (fmu->fmu_me1->c)
			fmu->condition |= cond_Instantiated;
		return fmu->fmu_me1->c;
	}
}

void fmi_1_0_me_dll_free_model_instance(DLLFMU* fmu)
{
	if (!fmu || !fmu->fmu_me1) {
		return;
	} else {
		fmu->fmu_me1->fmiFreeModelInstance(fmu->fmu_me1->c);		
		return;
	}
}

fmiStatus fmi_1_0_me_dll_initialize(DLLFMU* fmu, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo)
{
	fmiStatus fmiFlag;

	if (!fmu || !fmu->fmu_me1) {
		return fmiFatal;
	} else {
		fmiFlag = fmu->fmu_me1->fmiInitialize(fmu->fmu_me1->c, toleranceControlled, relativeTolerance, eventInfo);
		if (fmiFlag != fmiError && fmiFlag != fmiFatal)
			fmu->condition |= cond_Initialized;
		return fmiFlag;
	}
}

/* Call FMI function Macros */
#define CALL_FMI_FUNCTION_RETURN_STRING(functioncall) \
if (!fmu || !fmu->fmu_me1) { \
	return NULL; \
} else { \
	return functioncall; \
}

#define CALL_FMI_FUNCTION_RETURN_FMISTATUS(functioncall) \
if (!fmu || !fmu->fmu_me1) { \
	return fmiFatal; \
} else { \
	return functioncall; \
}

const char* fmi_1_0_me_dll_get_model_types_platform(DLLFMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_me1->fmiGetModelTypesPlatform());
}

fmiStatus fmi_1_0_me_dll_set_time(DLLFMU* fmu, fmiReal time)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetTime(fmu->fmu_me1->c, time));
}

fmiStatus fmi_1_0_me_dll_set_continuous_states(DLLFMU* fmu, const fmiReal x[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetContinuousStates(fmu->fmu_me1->c, x, nx));
}


fmiStatus fmi_1_0_me_dll_completed_integrator_step(DLLFMU* fmu, fmiBoolean* callEventUpdate)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiCompletedIntegratorStep(fmu->fmu_me1->c, callEventUpdate));
}

fmiStatus fmi_1_0_me_dll_get_derivatives(DLLFMU* fmu, fmiReal derivatives[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetDerivatives(fmu->fmu_me1->c, derivatives, nx));
}

fmiStatus fmi_1_0_me_dll_get_event_indicators(DLLFMU* fmu, fmiReal eventIndicators[], size_t ni)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetEventIndicators(fmu->fmu_me1->c, eventIndicators, ni));
}

fmiStatus fmi_1_0_me_dll_eventUpdate(DLLFMU* fmu, fmiBoolean intermediateResults, fmiEventInfo* eventInfo)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiEventUpdate(fmu->fmu_me1->c, intermediateResults, eventInfo));
}

fmiStatus fmi_1_0_me_dll_get_continuous_states(DLLFMU* fmu, fmiReal states[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetContinuousStates(fmu->fmu_me1->c, states, nx));
}

fmiStatus fmi_1_0_me_dll_get_nominal_continuous_states(DLLFMU* fmu, fmiReal x_nominal[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetNominalContinuousStates(fmu->fmu_me1->c, x_nominal, nx));
}

fmiStatus fmi_1_0_me_dll_get_state_value_references(DLLFMU* fmu, fmiValueReference vrx[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetStateValueReferences(fmu->fmu_me1->c, vrx, nx));
}

fmiStatus fmi_1_0_me_dll_terminate(DLLFMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiTerminate(fmu->fmu_me1->c));
}

/* Common FMI 1.0 functions */

const char* fmi_1_0_me_dll_get_version(DLLFMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_me1->fmiGetVersion());
}

fmiStatus fmi_1_0_me_set_debug_logging(DLLFMU* fmu, fmiBoolean loggingOn)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetDebugLogging(fmu->fmu_me1->c, loggingOn));
}

/* fmiSet* functions */
#define FMISETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_me1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_me1->FNAME2(fmu->fmu_me1->c, vr, nvr, value); \
	} \
}

/* fmiGet* functions */
#define FMIGETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_me1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_me1->FNAME2(fmu->fmu_me1->c, vr, nvr, value); \
	} \
}

FMISETX(fmi_1_0_me_dll_set_real,	fmiSetReal,		fmiReal);
FMISETX(fmi_1_0_me_dll_set_integer, fmiSetInteger,	fmiInteger);
FMISETX(fmi_1_0_me_dll_set_boolean, fmiSetBoolean,	fmiBoolean);
FMISETX(fmi_1_0_me_dll_set_string,	fmiSetString,	fmiString);

FMIGETX(fmi_1_0_me_dll_get_real,	fmiGetReal,		fmiReal);
FMIGETX(fmi_1_0_me_dll_get_integer,	fmiGetInteger,	fmiInteger);
FMIGETX(fmi_1_0_me_dll_get_boolean,	fmiGetBoolean,	fmiBoolean);
FMIGETX(fmi_1_0_me_dll_get_string,	fmiGetString,	fmiString);

