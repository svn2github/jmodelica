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


#include "fmi_dll_types.h"
#include "fmi_dll_1_0_me.h"

fmiComponent fmi_dll_1_0_me_instantiate_model(fmi_dll_t* fmu, fmiString instanceName, fmiString GUID, fmiBoolean loggingOn)
{
	/* Instantiate model */
	if (!fmu || !fmu->fmu_me1) {
		return NULL;
	} else {
		fmu->fmu_me1->c = fmu->fmu_me1->fmiInstantiateModel(instanceName, GUID, fmu->callBackFunctions, loggingOn);
		return fmu->fmu_me1->c;
	}
}

void fmi_dll_1_0_me_free_model_instance(fmi_dll_t* fmu)
{
	if (!fmu || !fmu->fmu_me1) {
		return;
	} else {
		fmu->fmu_me1->fmiFreeModelInstance(fmu->fmu_me1->c);		
		return;
	}
}

fmiStatus fmi_dll_1_0_me_initialize(fmi_dll_t* fmu, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo)
{
	fmiStatus fmiFlag;

	if (!fmu || !fmu->fmu_me1) {
		return fmiFatal;
	} else {
		fmiFlag = fmu->fmu_me1->fmiInitialize(fmu->fmu_me1->c, toleranceControlled, relativeTolerance, eventInfo);
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

const char* fmi_dll_1_0_me_get_model_types_platform(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_me1->fmiGetModelTypesPlatform());
}

fmiStatus fmi_dll_1_0_me_set_time(fmi_dll_t* fmu, fmiReal time)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetTime(fmu->fmu_me1->c, time));
}

fmiStatus fmi_dll_1_0_me_set_continuous_states(fmi_dll_t* fmu, const fmiReal x[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetContinuousStates(fmu->fmu_me1->c, x, nx));
}


fmiStatus fmi_dll_1_0_me_completed_integrator_step(fmi_dll_t* fmu, fmiBoolean* callEventUpdate)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiCompletedIntegratorStep(fmu->fmu_me1->c, callEventUpdate));
}

fmiStatus fmi_dll_1_0_me_get_derivatives(fmi_dll_t* fmu, fmiReal derivatives[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetDerivatives(fmu->fmu_me1->c, derivatives, nx));
}

fmiStatus fmi_dll_1_0_me_get_event_indicators(fmi_dll_t* fmu, fmiReal eventIndicators[], size_t ni)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetEventIndicators(fmu->fmu_me1->c, eventIndicators, ni));
}

fmiStatus fmi_dll_1_0_me_eventUpdate(fmi_dll_t* fmu, fmiBoolean intermediateResults, fmiEventInfo* eventInfo)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiEventUpdate(fmu->fmu_me1->c, intermediateResults, eventInfo));
}

fmiStatus fmi_dll_1_0_me_get_continuous_states(fmi_dll_t* fmu, fmiReal states[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetContinuousStates(fmu->fmu_me1->c, states, nx));
}

fmiStatus fmi_dll_1_0_me_get_nominal_continuous_states(fmi_dll_t* fmu, fmiReal x_nominal[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetNominalContinuousStates(fmu->fmu_me1->c, x_nominal, nx));
}

fmiStatus fmi_dll_1_0_me_get_state_value_references(fmi_dll_t* fmu, fmiValueReference vrx[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetStateValueReferences(fmu->fmu_me1->c, vrx, nx));
}

fmiStatus fmi_dll_1_0_me_terminate(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiTerminate(fmu->fmu_me1->c));
}

/* Common FMI 1.0 functions */

const char* fmi_dll_1_0_me_get_version(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_me1->fmiGetVersion());
}

fmiStatus fmi_dll_1_0_me_set_debug_logging(fmi_dll_t* fmu, fmiBoolean loggingOn)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetDebugLogging(fmu->fmu_me1->c, loggingOn));
}

/* fmiSet* functions */
#define FMISETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_me1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_me1->FNAME2(fmu->fmu_me1->c, vr, nvr, value); \
	} \
}

/* fmiGet* functions */
#define FMIGETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_me1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_me1->FNAME2(fmu->fmu_me1->c, vr, nvr, value); \
	} \
}

FMISETX(fmi_dll_1_0_me_set_real,	fmiSetReal,		fmiReal)
FMISETX(fmi_dll_1_0_me_set_integer, fmiSetInteger,	fmiInteger)
FMISETX(fmi_dll_1_0_me_set_boolean, fmiSetBoolean,	fmiBoolean)
FMISETX(fmi_dll_1_0_me_set_string,	fmiSetString,	fmiString)

FMIGETX(fmi_dll_1_0_me_get_real,	fmiGetReal,		fmiReal)
FMIGETX(fmi_dll_1_0_me_get_integer,	fmiGetInteger,	fmiInteger)
FMIGETX(fmi_dll_1_0_me_get_boolean,	fmiGetBoolean,	fmiBoolean)
FMIGETX(fmi_dll_1_0_me_get_string,	fmiGetString,	fmiString)

