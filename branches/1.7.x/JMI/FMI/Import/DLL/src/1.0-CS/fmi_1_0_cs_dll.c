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

#include "fmi_1_0_cs_dll.h"
#include "fmi_common_types_dll.h"

fmiComponent fmi_1_0_cs_dll_instantiate_slave(DLLFMU* fmu, fmiString instanceName, fmiString fmuGUID, fmiString fmuLocation, fmiString mimeType, fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiBoolean loggingOn)
{
	/* Instantiate model */
	if (!fmu || !fmu->fmu_cs1) {
		return NULL;
	} else {
		fmu->fmu_cs1->c = fmu->fmu_cs1->fmiInstantiateSlave(instanceName, fmuGUID, fmuLocation, mimeType, timeout, visible, interactive, fmu->callBackFunctions, loggingOn);
		if (fmu->fmu_cs1->c)
			fmu->condition |= cond_Instantiated;
		return fmu->fmu_cs1->c;
	}
}



void fmi_1_0_cs_dll_free_slave_instance(DLLFMU* fmu)
{
	if (!fmu || !fmu->fmu_cs1) {
		return;
	} else {
		fmu->fmu_cs1->fmiFreeSlaveInstance(fmu->fmu_cs1->c);
		return;
	}	
}


fmiStatus fmi_1_0_cs_dll_initialize_slave(DLLFMU* fmu, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop)
{
	fmiStatus fmiFlag;

	if (!fmu || !fmu->fmu_cs1) {
		return fmiFatal;
	} else {
		fmiFlag = fmu->fmu_cs1->fmiInitializeSlave(fmu->fmu_cs1->c, tStart, StopTimeDefined, tStop);
		if (fmiFlag != fmiError && fmiFlag != fmiFatal)
			fmu->condition |= cond_Initialized;
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

const char* fmi_1_0_cs_dll_get_types_platform(DLLFMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_cs1->fmiGetTypesPlatform());
}

fmiStatus fmi_1_0_cs_dll_terminate_slave(DLLFMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiTerminateSlave(fmu->fmu_cs1->c));
}

fmiStatus fmi_1_0_cs_dll_reset_slave(DLLFMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiResetSlave(fmu->fmu_cs1->c));
}

fmiStatus fmi_1_0_cs_dll_set_real_input_derivatives(DLLFMU* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[])  
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiSetRealInputDerivatives(fmu->fmu_cs1->c, vr, nvr, order, value));
}

fmiStatus fmi_1_0_cs_dll_get_real_output_derivatives(DLLFMU* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[])   
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiGetRealOutputDerivatives(fmu->fmu_cs1->c, vr, nvr, order, value));
}

fmiStatus fmi_1_0_cs_dll_cancel_step(DLLFMU* fmu)   
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiCancelStep(fmu->fmu_cs1->c));
}

fmiStatus fmi_1_0_cs_dll_do_step(DLLFMU* fmu, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiDoStep(fmu->fmu_cs1->c, currentCommunicationPoint, communicationStepSize, newStep));
}

/* fmiGetStatus* */
#define FMIGETSTATUSX(FNAME1, FNAME2,FSTATUSTYPE) \
fmiStatus FNAME1(DLLFMU* fmu, const fmiStatusKind s, FSTATUSTYPE*  value) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME2(fmu->fmu_cs1->c, s, value); \
	} \
}

FMIGETSTATUSX(fmi_1_0_cs_dll_get_status,			fmiGetStatus,			fmiStatus)
FMIGETSTATUSX(fmi_1_0_cs_dll_get_real_status,		fmiGetRealStatus,		fmiReal)
FMIGETSTATUSX(fmi_1_0_cs_dll_get_integer_status,	fmiGetIntegerStatus,	fmiInteger)
FMIGETSTATUSX(fmi_1_0_cs_dll_get_boolean_status,	fmiGetBooleanStatus,	fmiBoolean)
FMIGETSTATUSX(fmi_1_0_cs_dll_get_string_status,		fmiGetStringStatus,		fmiString)


/* fmiSet* functions */
#define FMISETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, const FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME2(fmu->fmu_cs1->c, vr, nvr, value); \
	} \
}

/* fmiGet* functions */
#define FMIGETX(FNAME1, FNAME2, FTYPE) \
fmiStatus FNAME1(DLLFMU* fmu, const fmiValueReference vr[], size_t nvr, FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME2(fmu->fmu_cs1->c, vr, nvr, value); \
	} \
}

FMISETX(fmi_1_0_cs_dll_set_real,	fmiSetReal,		fmiReal);
FMISETX(fmi_1_0_cs_dll_set_integer, fmiSetInteger,	fmiInteger);
FMISETX(fmi_1_0_cs_dll_set_boolean, fmiSetBoolean,	fmiBoolean);
FMISETX(fmi_1_0_cs_dll_set_string,	fmiSetString,	fmiString);

FMIGETX(fmi_1_0_cs_dll_get_real,	fmiGetReal,		fmiReal);
FMIGETX(fmi_1_0_cs_dll_get_integer,	fmiGetInteger,	fmiInteger);
FMIGETX(fmi_1_0_cs_dll_get_boolean,	fmiGetBoolean,	fmiBoolean);
FMIGETX(fmi_1_0_cs_dll_get_string,	fmiGetString,	fmiString);