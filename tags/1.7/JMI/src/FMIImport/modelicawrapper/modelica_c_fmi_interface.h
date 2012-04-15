#ifndef MODELICA_C_FMI_INTERFACE_H
#define MODELICA_C_FMI_INTERFACE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "c_fmi_interface.h"
#include "c_fmi_interface_datatypes.h"

/*
From External object p156 in Modelica Language Specification 3.2:
External functions may be defined which operate on the internal memory of an ExternalObject. 
An ExternalObject used as input argument or return value of an external C-function is mapped to the C-type "void*".
*/
typedef void* extObj;

#define PREFIX_FUNCTION(A)  mw_ ## A		/* Prefixing "fmiGetVersion" to "mw_fmiGetVersion"*/

/* Common FMI functions */
const char* PREFIX_FUNCTION(fmiGetVersion)					(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiSetDebugLogging)				(extObj fmuobj, fmiBoolean loggingOn);
fmiStatus	PREFIX_FUNCTION(fmiSetReal)						(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]);
fmiStatus	PREFIX_FUNCTION(fmiSetInteger)					(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus	PREFIX_FUNCTION(fmiSetBoolean)					(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus	PREFIX_FUNCTION(fmiSetString)					(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
fmiStatus	PREFIX_FUNCTION(fmiGetReal)						(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiReal    value[]);
fmiStatus	PREFIX_FUNCTION(fmiGetInteger)					(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus	PREFIX_FUNCTION(fmiGetBoolean)					(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus	PREFIX_FUNCTION(fmiGetString)					(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

/* FMI Co-Simulation 1.0 */

extObj PREFIX_FUNCTION(FMUModelCS1)(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn);
void PREFIX_FUNCTION(FMUModelCS1Destroy)(extObj* fmuobj);

const char*	PREFIX_FUNCTION(fmiGetTypesPlatform)			(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiInstantiateSlave)			(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiTerminateSlave)				(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiResetSlave)					(extObj fmuobj);
void		PREFIX_FUNCTION(fmiFreeSlaveInstance)			(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiSetRealInputDerivatives)		(extObj fmuobj, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[]);                                                  
fmiStatus	PREFIX_FUNCTION(fmiGetRealOutputDerivatives)	(extObj fmuobj, const fmiValueReference vr[], size_t  nvr, const fmiInteger order[], fmiReal value[]);                                              
fmiStatus	PREFIX_FUNCTION(fmiCancelStep)					(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiDoStep)						(extObj fmuobj, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep);
fmiStatus	PREFIX_FUNCTION(fmiGetStatus)					(extObj fmuobj, const fmiStatusKind s, fmiStatus*  value);
fmiStatus	PREFIX_FUNCTION(fmiGetRealStatus)				(extObj fmuobj, const fmiStatusKind s, fmiReal*    value);
fmiStatus	PREFIX_FUNCTION(fmiGetIntegerStatus)			(extObj fmuobj, const fmiStatusKind s, fmiInteger* value);
fmiStatus	PREFIX_FUNCTION(fmiGetBooleanStatus)			(extObj fmuobj, const fmiStatusKind s, fmiBoolean* value);
fmiStatus	PREFIX_FUNCTION(fmiGetStringStatus)				(extObj fmuobj, const fmiStatusKind s, fmiString*  value);


/* FMI Model Exchange 1.0 */
extObj PREFIX_FUNCTION(FMUModelME1)(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn);
void PREFIX_FUNCTION(FMUModelME1Destroy)(extObj* fmuobj);

const char* PREFIX_FUNCTION(fmiGetModelTypesPlatform)		(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiInstantiateModel)			(extObj fmuobj);
/* see fmiInstantiateSlave for Co-simulation */
void		PREFIX_FUNCTION(fmiFreeModelInstance)			(extObj fmuobj);
fmiStatus	PREFIX_FUNCTION(fmiSetTime)						(extObj fmuobj, fmiReal time);
fmiStatus	PREFIX_FUNCTION(fmiSetContinuousStates)			(extObj fmuobj, const fmiReal x[], size_t nx);
fmiStatus	PREFIX_FUNCTION(fmiCompletedIntegratorStep)		(extObj fmuobj, fmiBoolean* callEventUpdate);
fmiStatus	PREFIX_FUNCTION(fmiInitialize)					(extObj fmuobj, fmiBoolean toleranceControlled, fmiReal relativeTolerance, 
																fmiBoolean* terminateSimulation, fmiBoolean* upcomingTimeEvent, fmiReal* nextEventTime);

fmiStatus	PREFIX_FUNCTION(fmiGetDerivatives)				(extObj fmuobj, fmiReal derivatives[]    , size_t nx);
fmiStatus	PREFIX_FUNCTION(fmiGetEventIndicators)			(extObj fmuobj, fmiReal eventIndicators[], size_t ni);
fmiStatus	PREFIX_FUNCTION(fmiEventUpdate)					(extObj fmuobj, fmiBoolean* iterationConverged, fmiBoolean* stateValuesChanged, fmiBoolean* stateValueReferencesChanged, fmiBoolean* terminateSimulation, fmiBoolean* upcomingTimeEvent, fmiReal* nextEventTime);
/* Changed the fmiEventInfo struct to be a argument of base types instead. See fmiInitialize above. */
fmiStatus	PREFIX_FUNCTION(fmiGetContinuousStates)			(extObj fmuobj, fmiReal states[], size_t nx);
fmiStatus	PREFIX_FUNCTION(fmiGetNominalContinuousStates)	(extObj fmuobj, fmiReal x_nominal[], size_t nx);
fmiStatus	PREFIX_FUNCTION(fmiGetStateValueReferences)		(extObj fmuobj, fmiValueReference vrx[], size_t nx);
fmiStatus	PREFIX_FUNCTION(fmiTerminate)					(extObj fmuobj);


#ifdef __cplusplus
}
#endif

#endif /* End of MODELICA_C_FMI_INTERFACE_H */