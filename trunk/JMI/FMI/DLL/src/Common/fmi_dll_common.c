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


#include <stdio.h>
#include <stdarg.h>
#include "fmi_dll_types.h"
#include "fmi_dll_common.h"
#include "jm_types.h"
#include <string.h>
#include <errno.h>

#define FUNCTION_NAME_LENGTH_MAX 2048			/* Maximum length of FMI function name. Used in the load DLL function. */
#define PRE_FIX_LOGGER_MSG "C FMI interface: "	/* Logger message example: "C FMI Interface: Could not allocate memory for this and that.." */
#define STRINGIFY(str) #str

static char* fmi_dll_get_last_error_from_dll_system()
{
	#define DLL_ERROR_MESSAGE_SIZE 1000

	static char err_str[DLL_ERROR_MESSAGE_SIZE]; 

#ifdef _MSC_VER
	LPVOID lpMsgBuf;
	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR)&lpMsgBuf, 0, NULL);
	sprintf(err_str, "%s", lpMsgBuf);
#else
	PRINT_MY_DEBUG_INFO_HERE
	sprintf(err_str, "%s", dlerror());
#endif	
	return err_str;
}

static const char* fmi_dll_set_last_error(fmi_dll_t* fmu, const char* fmt, ...)
{
	va_list ap;
	va_start (ap, fmt);
	vsprintf(fmu->errMessageBuf, fmt, ap);
}

const char* fmi_dll_common_get_last_error(fmi_dll_t* fmu)
{
	return fmu->errMessageBuf;
}

static jm_status_enu_t fmi_dll_common_get_fcn_from_dll(fmi_dll_t* fmu, const char* function_name, void** fptr)
{
	char fname[FUNCTION_NAME_LENGTH_MAX];
	void* tmpfptr;

	if (strlen(fmu->modelIdentifier) + strlen(function_name) + 2 > FUNCTION_NAME_LENGTH_MAX) {
		fmi_dll_set_last_error(fmu, "%s", PRE_FIX_LOGGER_MSG "DLL function name is too long. Max name length is set to " STRINGIFY(FUNCTION_NAME_LENGTH_MAX) ".");
		return jm_status_error;
	}

	sprintf(fname,"%s_%s", fmu->modelIdentifier, function_name);
#ifdef _MSC_VER
	*fptr = tmpfptr = GetProcAddress(fmu->dllHandle, fname);
#else
	*fptr = tmpfptr = dlsym(fmu->dllHandle, name);
#endif
	if (!tmpfptr) { /* Fail */
		return jm_status_error;
	} else {		/* Success */
		return jm_status_success;
	}
}

/* Load FMI CS 1.0 functions */
static jm_status_enu_t fmi_dll_common_load_cs_1_0_fcn_from_dll(fmi_dll_t* fmu)
{
	#define LOAD_DLL_FUNCTION_CS_1_0(FMIFUNCTION) if (fmi_dll_common_get_fcn_from_dll(fmu, #FMIFUNCTION, (void**)&fmu->fmu_cs1->FMIFUNCTION) == jm_status_error) { \
	fmi_dll_set_last_error(fmu, "%s %s", PRE_FIX_LOGGER_MSG "Could not load the FMI function '"#FMIFUNCTION"'.", fmi_dll_get_last_error_from_dll_system()); \
	return jm_status_error; \
}

	/* Workaround for Dymola 2012 and SimulationX 3.x */
	if (fmi_dll_common_get_fcn_from_dll(fmu, "fmiGetTypesPlatform", (void**)&fmu->fmu_cs1->fmiGetTypesPlatform) == jm_status_error) {
		if (fmi_dll_common_get_fcn_from_dll(fmu, "fmiGetModelTypesPlatform", (void**)&fmu->fmu_cs1->fmiGetTypesPlatform) == jm_status_error) {
			char* str = fmi_dll_get_last_error_from_dll_system();
			fmi_dll_set_last_error(fmu, "%s %s", PRE_FIX_LOGGER_MSG "Could not load any of the FMI functions 'fmiGetModelTypesPlatform' or 'fmiGetTypesPlatform'.", str);
			return jm_status_error;
		}
	}

	LOAD_DLL_FUNCTION_CS_1_0(fmiInstantiateSlave);
	LOAD_DLL_FUNCTION_CS_1_0(fmiInitializeSlave);
	LOAD_DLL_FUNCTION_CS_1_0(fmiTerminateSlave);
	LOAD_DLL_FUNCTION_CS_1_0(fmiResetSlave);
	LOAD_DLL_FUNCTION_CS_1_0(fmiFreeSlaveInstance);
	LOAD_DLL_FUNCTION_CS_1_0(fmiSetRealInputDerivatives);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetRealOutputDerivatives);
	LOAD_DLL_FUNCTION_CS_1_0(fmiCancelStep);
	LOAD_DLL_FUNCTION_CS_1_0(fmiDoStep);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetStatus);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetRealStatus);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetIntegerStatus);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetBooleanStatus);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetStringStatus);

	LOAD_DLL_FUNCTION_CS_1_0(fmiGetVersion);
	LOAD_DLL_FUNCTION_CS_1_0(fmiSetDebugLogging);
	LOAD_DLL_FUNCTION_CS_1_0(fmiSetReal);
	LOAD_DLL_FUNCTION_CS_1_0(fmiSetInteger);
	LOAD_DLL_FUNCTION_CS_1_0(fmiSetBoolean);
	LOAD_DLL_FUNCTION_CS_1_0(fmiSetString);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetReal);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetInteger);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetBoolean);
	LOAD_DLL_FUNCTION_CS_1_0(fmiGetString);
	return jm_status_success; 
}

/* Load FMI ME 1.0 functions */
static jm_status_enu_t fmi_dll_common_load_me_1_0_fcn_from_dll(fmi_dll_t* fmu)
{
#define LOAD_DLL_FUNCTION_ME_1_0(FMIFUNCTION) if (fmi_dll_common_get_fcn_from_dll(fmu, #FMIFUNCTION, (void**)&fmu->fmu_me1->FMIFUNCTION) == jm_status_error) { \
	fmi_dll_set_last_error(fmu, "%s %s", PRE_FIX_LOGGER_MSG "Could not load the FMI function '"#FMIFUNCTION"'.", fmi_dll_get_last_error_from_dll_system()); \
	return jm_status_error; \
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
	return jm_status_success; 
}



void fmi_dll_common_destroy_dllfmu(fmi_dll_t* fmu)
{
	/* If NULL ptr is passed, which may be the case if instantiate function fails */
	if (fmu == NULL)
		return;

	/* If wrapper model instance is loaded */
	fmu->callBackFunctions.freeMemory((void*)fmu->dllPath);
	fmu->callBackFunctions.freeMemory((void*)fmu->modelIdentifier);	

	fmu->callBackFunctions.freeMemory((void*)fmu->fmu_me1);	
	fmu->callBackFunctions.freeMemory((void*)fmu->fmu_cs1);
	fmu->callBackFunctions.freeMemory((void*)fmu);
	return;
}


/* Help function used in the instantiate functions */
fmi_dll_t* fmi_dll_common_create_dllfmu(const char* dllPath, const char* modelIdentifier, fmiCallbackFunctions callBackFunctions, fmi_dll_standard_enu_t standard)
{
	fmi_dll_t* fmu = NULL;
	fmiCallbackLogger         fmuLogger;
	fmiCallbackAllocateMemory fmuCalloc;
	fmiCallbackFreeMemory     fmuFree;

	fmuLogger = callBackFunctions.logger;
	fmuCalloc = callBackFunctions.allocateMemory;
	fmuFree = callBackFunctions.freeMemory;


	/* Allocate memory for the FMU instance */
	fmu = (fmi_dll_t*)fmuCalloc(1, sizeof(fmi_dll_t));
	if (fmu == NULL) { /* Could not allocate memory for the FMU struct */
		fmuLogger(NULL, "", fmiFatal, "", "%s %s", PRE_FIX_LOGGER_MSG "Could not allocate memory for the FMU struct.", strerror(errno));
		goto error_goto;
	}	

	/* Set callback functions */
	fmu->callBackFunctions = callBackFunctions;

	/* Set FMI standard to load */
	fmu->standard = standard;

	/* Set all memory alloated pointers to NULL */
	fmu->dllPath = NULL;
	fmu->modelIdentifier = NULL;
	fmu->fmu_me1 = NULL;
	fmu->fmu_cs1 = NULL;

	/* Allocate memory for the specific FMI standard structs */
	switch (fmu->standard) {
		case FMI_ME1:
			fmu->fmu_me1 = (fmi_dll_me1_t*)fmuCalloc(1, sizeof(fmi_dll_me1_t));
			if (fmu->fmu_me1 == NULL) {
				fmuLogger(NULL, "", fmiFatal, "", "%s %s", PRE_FIX_LOGGER_MSG "Could not allocate memory for the fmi_dll_me1_t struct.", strerror(errno));
				goto error_goto;
			}
			break;
		case FMI_CS1:
			fmu->fmu_cs1 = (fmi_dll_cs1_t*)fmuCalloc(1, sizeof(fmi_dll_cs1_t));
			if (fmu->fmu_cs1 == NULL) {
				fmuLogger(NULL, "", fmiFatal, "", "%s %s", PRE_FIX_LOGGER_MSG "Could not allocate memory for the fmi_dll_cs1_t struct.", strerror(errno));
				goto error_goto;
			}
			break;
		default:
			fmuLogger(NULL, "", fmiFatal, "", "%s", PRE_FIX_LOGGER_MSG "Not a supported FMI standard.");
			goto error_goto;
	}

	/* Copy DLL path */
	fmu->dllPath = (char*)fmuCalloc(sizeof(char), strlen(dllPath) + 1);
	if (fmu->dllPath == NULL) {
		fmuLogger(NULL, "", fmiFatal, "", "%s %s", PRE_FIX_LOGGER_MSG "Could not allocate memory for the DLL path string.", strerror(errno));
		goto error_goto;
	}
	sprintf((char*)fmu->dllPath, dllPath);

	/* Copy the modelIdentifier */
	fmu->modelIdentifier = (char*)fmuCalloc(sizeof(char), strlen(modelIdentifier) + 1);
	if (fmu->modelIdentifier == NULL) {
		fmuLogger(NULL, "", fmiFatal, "", "%s %s", PRE_FIX_LOGGER_MSG "Could not allocate memory for the modelIdentifier string.", strerror(errno));
		goto error_goto;
	}
	sprintf((char*)fmu->modelIdentifier, modelIdentifier);

	/* Everything was succesfull */
	return fmu;

error_goto:
	fmi_dll_common_destroy_dllfmu(fmu);
	return NULL;
}

/* Load DLL and FMI functions */
jm_status_enu_t fmi_dll_common_load_fcn(fmi_dll_t* fmu)
{	
	/* Load FMI functions */
	switch (fmu->standard) {
		case FMI_ME1:
			if (fmi_dll_common_load_me_1_0_fcn_from_dll(fmu) == jm_status_error) {
				return jm_status_error;
			}
			break;
		case FMI_CS1:
			if (fmi_dll_common_load_cs_1_0_fcn_from_dll(fmu) == jm_status_error) {
				return jm_status_error;
			}
			break;
	}
	return jm_status_success;
}

jm_status_enu_t fmi_dll_common_load_dll(fmi_dll_t* fmu)
{
/* Load DLL */
#ifdef _MSC_VER
	fmu->dllHandle = LoadLibrary(fmu->dllPath);
#else	
	fmu->dllHandle = dlopen(fmu->dllPath, RTLD_LAZY);
#endif		
	if (!fmu->dllHandle) {
		fmi_dll_set_last_error(fmu, "%s %s", PRE_FIX_LOGGER_MSG "Could not load the DLL.", fmi_dll_get_last_error_from_dll_system());
		return jm_status_error;
	} else {
		return jm_status_success;
	}
}

/* Free DLL handle */
void fmi_dll_common_free_dll(fmi_dll_t* fmu)
{
	if (fmu->dllHandle) {		
#ifdef _MSC_VER		
		FreeLibrary(fmu->dllHandle);		
#else		
		dlclose(fmu->dllHandle);
#endif
	}
}