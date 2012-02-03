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

#include "fmi_1_0_me_load_fcn_dll.h"
#include "fmi_common_types_dll.h"
#include <stdio.h>

#define STRINGIFY(s) #s

static callStatus fmi_1_0_me_load_dll_fcn_internal(DLLFMU* fmu, const char* function_name, void** fptr)
{
	char fname[FUNCTION_NAME_LENGTH_MAX];
	void* tmpfptr;

	if (strlen(fmu->modelIdentifier) + strlen(function_name) + 2 > FUNCTION_NAME_LENGTH_MAX) {
		fmu->callBackFunctions.logger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "DLL function name is too long. Max length is set to " STRINGIFY(FUNCTION_NAME_LENGTH_MAX) ".");
		return call_error;
	}

	sprintf(fname,"%s_%s", fmu->modelIdentifier, function_name);
#ifdef _MSC_VER
	*fptr = tmpfptr = GetProcAddress(fmu->dllHandle, fname);
#else
	*fptr = tmpfptr = dlsym(fmu->dllHandle, name);
#endif
	if (!tmpfptr) { /* Fail */
		return call_error;
	} else {		/* Success */
		return call_success;
	}
}

/* Load FMI 1.0 functions */
callStatus fmi_1_0_me_load_dll_fcn(DLLFMU* fmu)
{
#define LOAD_DLL_FUNCTION_ME_1_0(FMIFUNCTION) if (fmi_1_0_me_load_dll_fcn_internal(fmu, #FMIFUNCTION, (void**)&fmu->fmu_me1->FMIFUNCTION) != call_success) { \
	fmu->callBackFunctions.logger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not load the FMI function '"#FMIFUNCTION"'."); \
	return call_error; \
}
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetModelTypesPlatform);
	LOAD_DLL_FUNCTION_ME_1_0(fmiInstantiateModel);
	LOAD_DLL_FUNCTION_ME_1_0(fmiFreeModelInstance);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetTime);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetContinuousStates);
	LOAD_DLL_FUNCTION_ME_1_0(fmiCompletedIntegratorStep);
	LOAD_DLL_FUNCTION_ME_1_0(fmiInitialize);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetDerivatives);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetEventIndicators);
	LOAD_DLL_FUNCTION_ME_1_0(fmiEventUpdate);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetContinuousStates);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetNominalContinuousStates);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetStateValueReferences);
	LOAD_DLL_FUNCTION_ME_1_0(fmiTerminate);

	LOAD_DLL_FUNCTION_ME_1_0(fmiGetVersion);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetDebugLogging);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetReal);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetInteger);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetBoolean);
	LOAD_DLL_FUNCTION_ME_1_0(fmiSetString);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetReal);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetInteger);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetBoolean);
	LOAD_DLL_FUNCTION_ME_1_0(fmiGetString);
	return call_success; 
}