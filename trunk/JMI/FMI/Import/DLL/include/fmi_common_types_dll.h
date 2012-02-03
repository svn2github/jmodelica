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


#ifndef FMI_COMMON_TYPES_DLL_H
#define FMI_COMMON_TYPES_DLL_H

#include "fmiPlatformTypes.h"

/* Include platform dependent headers */
#ifdef _MSC_VER /* Microsoft Windows API */
#include <windows.h>
#else /* Standard POSIX/UNIX API */
#define HANDLE void* 
#include <dlfcn.h>
#endif

#define FUNCTION_NAME_LENGTH_MAX 2048			/* Maximum length of FMI function name. Used in the load DLL function. */
#define PRE_FIX_LOGGER_MSG "C FMI Interface: "	/* Logger message example: "M FMI Interface: Could not allocate memory for this and that.." */

typedef enum {fmiOK,
fmiWarning,
fmiDiscard,
fmiError,
fmiFatal,
fmiPending} fmiStatus;

typedef void  (*fmiCallbackLogger) (fmiComponent c, fmiString instanceName, fmiStatus status,
									fmiString category, fmiString message, ...);
typedef void* (*fmiCallbackAllocateMemory)(size_t nobj, size_t size);
typedef void  (*fmiCallbackFreeMemory)    (void* obj);
typedef void  (*fmiStepFinished)          (fmiComponent c, fmiStatus status);

typedef struct {
	fmiCallbackLogger         logger;
	fmiCallbackAllocateMemory allocateMemory;
	fmiCallbackFreeMemory     freeMemory;
	fmiStepFinished           stepFinished;
} fmiCallbackFunctions;

typedef struct {
	fmiBoolean iterationConverged;
	fmiBoolean stateValueReferencesChanged;
	fmiBoolean stateValuesChanged;
	fmiBoolean terminateSimulation;
	fmiBoolean upcomingTimeEvent;
	fmiReal    nextEventTime;
} fmiEventInfo;

typedef enum {
	fmiDoStepStatus,
	fmiPendingStatus,
	fmiLastSuccessfulTime
} fmiStatusKind;

/* FMI 1.0 common functions */
typedef const char*		(*fmiGetModelTypesPlatform_ft)		(); /* Should only be in ME 1.0 but is made avaiable for CS 1.0. This is due to fmiGetTypesPlatform is replaced with this function in some FMUs */
typedef const char*		(*fmiGetVersion_ft)					();
typedef fmiStatus		(*fmiSetDebugLogging_ft)			(fmiComponent c, fmiBoolean loggingOn);
typedef fmiStatus		(*fmiSetReal_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal   value[]);
typedef fmiStatus		(*fmiSetInteger_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
typedef fmiStatus		(*fmiSetBoolean_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
typedef fmiStatus		(*fmiSetString_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
typedef fmiStatus		(*fmiGetReal_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal   value[]);
typedef fmiStatus		(*fmiGetInteger_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
typedef fmiStatus		(*fmiGetBoolean_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
typedef fmiStatus		(*fmiGetString_ft)					(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

/* FMI ME 1.0 functions */
typedef fmiComponent	(*fmiInstantiateModel_ft)			(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn);
typedef void			(*fmiFreeModelInstance_ft)			(fmiComponent c);
typedef fmiStatus		(*fmiSetTime_ft)					(fmiComponent c, fmiReal time);
typedef fmiStatus		(*fmiSetContinuousStates_ft)		(fmiComponent c, const fmiReal x[], size_t nx);
typedef fmiStatus		(*fmiCompletedIntegratorStep_ft)	(fmiComponent c, fmiBoolean* callEventUpdate);
typedef fmiStatus		(*fmiInitialize_ft)					(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);
typedef fmiStatus		(*fmiGetDerivatives_ft)				(fmiComponent c, fmiReal derivatives[]    , size_t nx);
typedef fmiStatus		(*fmiGetEventIndicators_ft)			(fmiComponent c, fmiReal eventIndicators[], size_t ni);
typedef fmiStatus		(*fmiEventUpdate_ft)				(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);
typedef fmiStatus		(*fmiGetContinuousStates_ft)		(fmiComponent c, fmiReal states[], size_t nx);
typedef fmiStatus		(*fmiGetNominalContinuousStates_ft)	(fmiComponent c, fmiReal x_nominal[], size_t nx);
typedef fmiStatus		(*fmiGetStateValueReferences_ft)	(fmiComponent c, fmiValueReference vrx[], size_t nx);
typedef fmiStatus		(*fmiTerminate_ft)					(fmiComponent c);    

/* FMI CS 1.0 functions */
typedef const char*		(*fmiGetTypesPlatform_ft)			();
typedef fmiComponent	(*fmiInstantiateSlave_ft)			(fmiString  instanceName, fmiString  fmuGUID, fmiString  fmuLocation, 
															fmiString  mimeType, fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, 
															fmiCallbackFunctions functions, fmiBoolean loggingOn);
typedef fmiStatus		(*fmiInitializeSlave_ft)			(fmiComponent c, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop);
typedef fmiStatus		(*fmiTerminateSlave_ft)				(fmiComponent c);
typedef fmiStatus		(*fmiResetSlave_ft)					(fmiComponent c);
typedef void			(*fmiFreeSlaveInstance_ft)			(fmiComponent c);
typedef fmiStatus		(*fmiSetRealInputDerivatives_ft)	(fmiComponent c, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[]);                                                  
typedef fmiStatus		(*fmiGetRealOutputDerivatives_ft)	(fmiComponent c, const fmiValueReference vr[], size_t  nvr, const fmiInteger order[], fmiReal value[]);                                              
typedef fmiStatus		(*fmiCancelStep_ft)					(fmiComponent c);
typedef fmiStatus		(*fmiDoStep_ft)						(fmiComponent c, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep);
typedef fmiStatus		(*fmiGetStatus_ft)					(fmiComponent c, const fmiStatusKind s, fmiStatus*  value);
typedef fmiStatus		(*fmiGetRealStatus_ft)				(fmiComponent c, const fmiStatusKind s, fmiReal*    value);
typedef fmiStatus		(*fmiGetIntegerStatus_ft)			(fmiComponent c, const fmiStatusKind s, fmiInteger* value);
typedef fmiStatus		(*fmiGetBooleanStatus_ft)			(fmiComponent c, const fmiStatusKind s, fmiBoolean* value);
typedef fmiStatus		(*fmiGetStringStatus_ft)			(fmiComponent c, const fmiStatusKind s, fmiString*  value);  

typedef enum {
	cond_WrapperModelLoaded = 1<<0,
	cond_UnzipedFMU			= 1<<1,
	cond_DllLoaded			= 1<<2,
	cond_Instantiated		= 1<<3,
	cond_Initialized		= 1<<4
} fmuCondition;

typedef enum {
	FMI_ME1,
	FMI_CS1
} fmiStandard;

typedef enum {
	call_success,
	call_error
} callStatus;

typedef struct { /* FMI CS 1.0 struct */
	fmiComponent c;		
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
} DLLFMUCS1;


typedef struct { /* FMI ME 1.0 struct */		
	fmiComponent c;		
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
} DLLFMUME1;


/* FMU object */
typedef struct {
	const char* dllPath;						/* Full path to the DLL file */
	const char* modelIdentifier;				/* Used to get the FMI fuctions */
	fmuCondition condition;						/* Current condition of the FMU model */
	fmiCallbackFunctions callBackFunctions;		/* Callback function structure passed to the model instantiated */

	HANDLE dllHandle;
	fmiStandard standard;						/* The current FMI standard this struct represent */
	DLLFMUME1* fmu_me1;
	DLLFMUCS1* fmu_cs1;
} DLLFMU;

#endif /* End of header file FMI_COMMON_TYPES_DLL_H */
