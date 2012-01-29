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

#include <stdio.h>
#include "fmi_common_types_dll.h"
#include "fmi_1_0_me_load_fcn_dll.h"
#include "fmi_1_0_cs_load_fcn_dll.h"
#include "fmi_common_dll.h"

void fmi_common_dll_destroy_DLLFMU(DLLFMU* fmu)
{
	/* If NULL ptr is passed, which may be the case if instantiate function fails */
	if (fmu == NULL)
		return;

	/* If DLL is loaded */
	if (fmu->condition & cond_DllLoaded)
		fmi_common_dll_free_DLLFMU(fmu);

	/* Remove unzip folder */
	if (fmu->condition & cond_UnzipedFMU) {
	}

	/* If wrapper model instance is loaded */
	if (fmu->condition & cond_WrapperModelLoaded) {
		fmu->callBackFunctions.freeMemory((void*)fmu->dllPath);
		fmu->callBackFunctions.freeMemory((void*)fmu->modelIdentifier);	

		fmu->callBackFunctions.freeMemory((void*)fmu->fmu_me1);	
		fmu->callBackFunctions.freeMemory((void*)fmu->fmu_cs1);
		fmu->callBackFunctions.freeMemory((void*)fmu);
	}
	return;
}


/* Help function used in the instantiate functions */
DLLFMU* fmi_common_dll_create_DLLFMU(const char* dllPath, const char* modelIdentifier, fmiCallbackFunctions callBackFunctions, fmiStandard standard)
{
	DLLFMU* fmu = NULL;
	fmiCallbackLogger         fmuLogger;
	fmiCallbackAllocateMemory fmuCalloc;
	fmiCallbackFreeMemory     fmuFree;

	fmuLogger = callBackFunctions.logger;
	fmuCalloc = callBackFunctions.allocateMemory;
	fmuFree = callBackFunctions.freeMemory;


	/* Allocate memory for the FMU instance */
	fmu = (DLLFMU*)fmuCalloc(1,sizeof(DLLFMU));
	if (fmu == NULL) { /* Could not allocate memory for the FMU struct */
		fmuLogger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the FMU struct.");
		goto error_goto;
	}
	
	/* Set FMU wrapper model condition */
	fmu->condition = 0;
	fmu->condition |= cond_WrapperModelLoaded;

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
			fmu->fmu_me1 = (DLLFMUME1*)fmuCalloc(1,sizeof(DLLFMUME1));
			if (fmu->fmu_me1 == NULL) {
				fmuLogger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the DLLFMUME1 struct.");
				goto error_goto;
			}
			break;
		case FMI_CS1:
			fmu->fmu_cs1 = (DLLFMUCS1*)fmuCalloc(1,sizeof(DLLFMUCS1));
			if (fmu->fmu_cs1 == NULL) {
				fmuLogger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the DLLFMUCS1 struct.");
				goto error_goto;
			}
			break;
		default:
			fmuLogger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Not a supported FMI standard.");
			goto error_goto;
	}

	/* Copy DLL path */
	fmu->dllPath = (char*)fmuCalloc(sizeof(char), strlen(dllPath) + 1);
	if (fmu->dllPath == NULL) {
		fmuLogger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the DLL path string.");
		goto error_goto;
	}
	sprintf((char*)fmu->dllPath, dllPath);

	/* Copy the modelIdentifier */
	fmu->modelIdentifier = (char*)fmuCalloc(sizeof(char), strlen(modelIdentifier) + 1);
	if (fmu->modelIdentifier == NULL) {
		fmuLogger(NULL, "", fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the DLL path string.");
		goto error_goto;
	}
	sprintf((char*)fmu->modelIdentifier, modelIdentifier);

	/* Everything was succesfull */
	return fmu;

error_goto:
	fmi_common_dll_destroy_DLLFMU(fmu);
	return NULL;
}

/* Load DLL and FMI functions */
callStatus fmi_common_dll_load_DLLFMU(DLLFMU* fmu)
{
/* Load DLL */
#ifdef _MSC_VER
	fmu->dllHandle = LoadLibrary(fmu->dllPath);
#else	
	fmu->dllHandle = dlopen(fmu->dllPath, RTLD_LAZY);
#endif	
	if (!fmu->dllHandle) {
		return call_error;
	}
	fmu->condition |=cond_DllLoaded;
/* Load FMI functions */
	switch (fmu->standard) {
		case FMI_ME1:
			if (fmi_1_0_me_load_fcn_dll(fmu) == call_error) {
				fmi_common_dll_free_DLLFMU(fmu);
				return call_error;
			}
			break;
		case FMI_CS1:
			if (fmi_1_0_cs_load_fcn_dll(fmu) == call_error) {
				fmi_common_dll_free_DLLFMU(fmu);
				return call_error;
			}
			break;
	}

	return call_success;
}

/* Free DLL handle */
void fmi_common_dll_free_DLLFMU(DLLFMU* fmu)
{
	if (fmu->dllHandle) {		
#ifdef _MSC_VER		
		FreeLibrary(fmu->dllHandle);		
#else		
		dlclose(fmu->dllHandle);
#endif
	}
	fmu->condition ^= cond_DllLoaded;
}