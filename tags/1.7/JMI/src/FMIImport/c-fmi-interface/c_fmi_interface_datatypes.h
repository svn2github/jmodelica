#ifndef C_FMI_INTERFACE_DATATYPES_H
#define C_FMI_INTERFACE_DATATYPES_H

#include "fmiPlatformTypes.h"

/* Include platform dependent headers */
#ifdef _MSC_VER /* Microsoft Windows API */
#include <windows.h>
#else /* Standard POSIX/UNIX API */
#define HANDLE void* 
#include <dlfcn.h>
#endif

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

typedef enum {fmiDoStepStatus,
fmiPendingStatus,
fmiLastSuccessfulTime} fmiStatusKind;

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

typedef struct { /* FMI CS 1.0 struct */
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
} FMUCS1;


typedef struct { /* FMI ME 1.0 struct */	
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
} FMUME1;


typedef struct {
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
} FMUCOMMON1;

/* FMU object */
typedef struct {
	const char* dllPath;
	const char* xmlPath;
	const char* unzipPath;
	const char* fmuPath;
	const char* GUID;
	const char* modelIdentifier;	
	fmuCondition condition;
	fmiCallbackFunctions callBackFunctions;
	fmiString instanceName;
	fmiBoolean loggingOn;

	HANDLE dllHandle; 
	fmiComponent c;	
	fmiStandard standard;

	FMUME1* fmu_me1;
	FMUCS1* fmu_cs1;
	FMUCOMMON1* fmu_common1;
} FMU;

#endif /* End of header file C_FMI_INTERFACE_DATATYPES_H */
