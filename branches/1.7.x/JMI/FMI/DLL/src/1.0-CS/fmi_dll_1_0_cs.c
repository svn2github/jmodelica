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


#include "fmi_dll_1_0_cs.h"
#include "fmi_dll_types.h"

fmiComponent fmi_dll_1_0_cs_instantiate_slave(fmi_dll_t* fmu, fmiString instanceName, fmiString fmuGUID, fmiString fmuLocation, fmiString mimeType, fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiBoolean loggingOn)
{
	/* Instantiate model */
	if (!fmu || !fmu->fmu_cs1) {
		return NULL;
	} else {
		fmu->fmu_cs1->c = fmu->fmu_cs1->fmiInstantiateSlave(instanceName, fmuGUID, fmuLocation, mimeType, timeout, visible, interactive, fmu->callBackFunctions, loggingOn);
		return fmu->fmu_cs1->c;
	}
}



void fmi_dll_1_0_cs_free_slave_instance(fmi_dll_t* fmu)
{
	if (!fmu || !fmu->fmu_cs1) {
		return;
	} else {
		fmu->fmu_cs1->fmiFreeSlaveInstance(fmu->fmu_cs1->c);
		return;
	}	
}


fmiStatus fmi_dll_1_0_cs_initialize_slave(fmi_dll_t* fmu, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop)
{
	fmiStatus fmiFlag;

	if (!fmu || !fmu->fmu_cs1) {
		return fmiFatal;
	} else {
		fmiFlag = fmu->fmu_cs1->fmiInitializeSlave(fmu->fmu_cs1->c, tStart, StopTimeDefined, tStop);
		return fmiFlag;
	}
}

/* Call FMI function Macros */
#define CALL_FMI_FUNCTION_RETURN_STRING(functioncall) \
if (!fmu || !fmu->fmu_cs1) { \
	return NULL; \
} else { \
	return functioncall; \
}

#define CALL_FMI_FUNCTION_RETURN_FMISTATUS(functioncall) \
if (!fmu || !fmu->fmu_cs1) { \
	return fmiFatal; \
} else { \
	return functioncall; \
}

const char* fmi_dll_1_0_cs_get_types_platform(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_cs1->fmiGetTypesPlatform());
}

const char* fmi_dll_1_0_cs_get_version(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_cs1->fmiGetVersion());
}

fmiStatus fmi_dll_1_0_cs_set_debug_logging(fmi_dll_t* fmu, fmiBoolean loggingOn)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiSetDebugLogging(fmu->fmu_cs1->c, loggingOn));
}

fmiStatus fmi_dll_1_0_cs_terminate_slave(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiTerminateSlave(fmu->fmu_cs1->c));
}

fmiStatus fmi_dll_1_0_cs_reset_slave(fmi_dll_t* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiResetSlave(fmu->fmu_cs1->c));
}

fmiStatus fmi_dll_1_0_cs_set_real_input_derivatives(fmi_dll_t* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[])  
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiSetRealInputDerivatives(fmu->fmu_cs1->c, vr, nvr, order, value));
}

fmiStatus fmi_dll_1_0_cs_get_real_output_derivatives(fmi_dll_t* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[])   
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiGetRealOutputDerivatives(fmu->fmu_cs1->c, vr, nvr, order, value));
}

fmiStatus fmi_dll_1_0_cs_cancel_step(fmi_dll_t* fmu)   
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiCancelStep(fmu->fmu_cs1->c));
}

fmiStatus fmi_dll_1_0_cs_do_step(fmi_dll_t* fmu, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiDoStep(fmu->fmu_cs1->c, currentCommunicationPoint, communicationStepSize, newStep));
}

/* fmiGetStatus* */
#define FMIGETSTATUSX(FNAME1, FNAME2,FSTATUSTYPE) \
fmiStatus FNAME1(fmi_dll_t* fmu, const fmiStatusKind s, FSTATUSTYPE*  value) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME2(fmu->fmu_cs1->c, s, value); \
	} \
}

FMIGETSTATUSX(fmi_dll_1_0_cs_get_status,			fmiGetStatus,			fmiStatus)
FMIGETSTATUSX(fmi_dll_1_0_cs_get_real_status,		fmiGetRealStatus,		fmiReal)
FMIGETSTATUSX(fmi_dll_1_0_cs_get_integer_status,	fmiGetIntegerStatus,	fmiInteger)
FMIGETSTATUSX(fmi_dll_1_0_cs_get_boolean_status,	fmiGetBooleanStatus,	fmiBoolean)
FMIGETSTATUSX(fmi_dll_1_0_cs_get_string_status,		fmiGetStringStatus,		fmiString)


/* fmiSet* functions */
#define FMISETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, const FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME2(fmu->fmu_cs1->c, vr, nvr, value); \
	} \
}

/* fmiGet* functions */
#define FMIGETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(fmi_dll_t* fmu, const fmiValueReference vr[], size_t nvr, FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME2(fmu->fmu_cs1->c, vr, nvr, value); \
	} \
}

FMISETX(fmi_dll_1_0_cs_set_real,	fmiSetReal,		fmiReal);
FMISETX(fmi_dll_1_0_cs_set_integer, fmiSetInteger,	fmiInteger);
FMISETX(fmi_dll_1_0_cs_set_boolean, fmiSetBoolean,	fmiBoolean);
FMISETX(fmi_dll_1_0_cs_set_string,	fmiSetString,	fmiString);

FMIGETX(fmi_dll_1_0_cs_get_real,	fmiGetReal,		fmiReal);
FMIGETX(fmi_dll_1_0_cs_get_integer,	fmiGetInteger,	fmiInteger);
FMIGETX(fmi_dll_1_0_cs_get_boolean,	fmiGetBoolean,	fmiBoolean);
FMIGETX(fmi_dll_1_0_cs_get_string,	fmiGetString,	fmiString);