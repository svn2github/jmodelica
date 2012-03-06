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


#ifndef FMI_DLL_TYPES_H_
#define FMI_DLL_TYPES_H_

#include "fmi_functions.h"
#include "fmi_types.h"

#include <config.h>
/* Include platform dependent headers */
#if defined(_MSC_VER) || defined(WIN32) /* Microsoft Windows API */
#include <windows.h>
#else /* Standard POSIX/UNIX API */
#define HANDLE void* 
#include <dlfcn.h>
#endif

typedef enum {
	FMI_ME1,
	FMI_CS1
} fmi_dll_standard_enu_t;

typedef struct { /* FMI CS 1.0 struct */
	fmiComponent					c;		

	fmiGetVersion_ft				fmiGetVersion;
	fmiSetDebugLogging_ft			fmiSetDebugLogging;
    fmiSetReal_ft					fmiSetReal;
    fmiSetInteger_ft				fmiSetInteger;
    fmiSetBoolean_ft				fmiSetBoolean;
    fmiSetString_ft					fmiSetString;
	fmiGetReal_ft					fmiGetReal;
    fmiGetInteger_ft				fmiGetInteger;
    fmiGetBoolean_ft				fmiGetBoolean;
    fmiGetString_ft					fmiGetString;

	fmiGetTypesPlatform_ft			fmiGetTypesPlatform;   
    fmiInstantiateSlave_ft			fmiInstantiateSlave;
    fmiInitializeSlave_ft			fmiInitializeSlave;
    fmiTerminateSlave_ft			fmiTerminateSlave;
    fmiResetSlave_ft				fmiResetSlave;
    fmiFreeSlaveInstance_ft			fmiFreeSlaveInstance;
    fmiGetRealOutputDerivatives_ft	fmiGetRealOutputDerivatives;
    fmiSetRealInputDerivatives_ft	fmiSetRealInputDerivatives;
    fmiDoStep_ft					fmiDoStep;
    fmiCancelStep_ft				fmiCancelStep;
    fmiGetStatus_ft					fmiGetStatus;
    fmiGetRealStatus_ft				fmiGetRealStatus;
    fmiGetIntegerStatus_ft			fmiGetIntegerStatus;
    fmiGetBooleanStatus_ft			fmiGetBooleanStatus;
    fmiGetStringStatus_ft			fmiGetStringStatus;
} fmi_dll_cs1_t;


typedef struct { /* FMI ME 1.0 struct */		
	fmiComponent					c;		

	fmiGetVersion_ft				fmiGetVersion;
	fmiSetDebugLogging_ft			fmiSetDebugLogging;
    fmiSetReal_ft					fmiSetReal;
    fmiSetInteger_ft				fmiSetInteger;
    fmiSetBoolean_ft				fmiSetBoolean;
    fmiSetString_ft					fmiSetString;
	fmiGetReal_ft					fmiGetReal;
    fmiGetInteger_ft				fmiGetInteger;
    fmiGetBoolean_ft				fmiGetBoolean;
    fmiGetString_ft					fmiGetString;

    fmiGetModelTypesPlatform_ft		fmiGetModelTypesPlatform;    
    fmiInstantiateModel_ft			fmiInstantiateModel;
    fmiFreeModelInstance_ft			fmiFreeModelInstance;    
    fmiSetTime_ft					fmiSetTime;
    fmiSetContinuousStates_ft		fmiSetContinuousStates;
    fmiCompletedIntegratorStep_ft	fmiCompletedIntegratorStep;
    fmiInitialize_ft			 	fmiInitialize;
    fmiGetDerivatives_ft			fmiGetDerivatives;
    fmiGetEventIndicators_ft		fmiGetEventIndicators;
    fmiEventUpdate_ft				fmiEventUpdate;
    fmiGetContinuousStates_ft		fmiGetContinuousStates;
    fmiGetNominalContinuousStates_ft fmiGetNominalContinuousStates;
    fmiGetStateValueReferences_ft	fmiGetStateValueReferences;
    fmiTerminate_ft					fmiTerminate;
} fmi_dll_me1_t;


/* FMU object */
typedef struct {
	const char* dllPath;						/* Full path to the DLL file */
	const char* modelIdentifier;				/* Used to get the FMI fuctions */	
	fmiCallbackFunctions callBackFunctions;		/* Callback function structure passed to the model instantiated */

	#define FMI_MAX_ERROR_MESSAGE_SIZE 1000

    char errMessageBuf[FMI_MAX_ERROR_MESSAGE_SIZE];

	HANDLE dllHandle;

	fmi_dll_standard_enu_t standard;						/* The current FMI standard this struct represent */	
	fmi_dll_me1_t* fmu_me1;
	fmi_dll_cs1_t* fmu_cs1;
} fmi_dll_t;

#endif /* End of header file FMI_DLL_TYPES_H_ */
