#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include "modelica_c_fmi_interface.h"
#include "c_fmi_interface_datatypes.h"
#include "c_fmi_interface_me_1_0.h"
#include "c_fmi_interface_cs_1_0.h"

/* Logger function */
void modelica_logger(fmiComponent c, fmiString instanceName, fmiStatus status, fmiString category, fmiString message, ...)
{
	char msg[2024];
	va_list argp;	
	va_start(argp, message);
	vsprintf(msg, message, argp);
	if (!instanceName) instanceName = "?";
	if (!category) category = "?";
	printf("fmiStatus = %d;  %s (%s): %s\n", status, instanceName, category, msg);
}

/* Memory allocation function */
void* modelica_allocateMemory(size_t nobj, size_t size)
{
	return calloc(nobj, size);
}

/* Free memory function */
void modelica_freeMemory(void* obj)
{
	free(obj);
}

/* Common FMI functions */

const char* PREFIX_FUNCTION(fmiGetVersion)(extObj fmuobj)
{
	return fmiGetVersion((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiSetDebugLogging)(extObj fmuobj, fmiBoolean loggingOn)
{
	return fmiSetDebugLogging((FMU*)fmuobj, loggingOn);
}

fmiStatus PREFIX_FUNCTION(fmiSetReal)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiReal value[])
{
	return fmiSetReal((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiSetInteger)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiInteger value[])
{
	return fmiSetInteger((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiSetBoolean)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[])
{
	return fmiSetBoolean((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiSetString)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, const fmiString value[])
{
	return fmiSetString((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetReal)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiReal value[])
{
	return fmiGetReal((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetInteger)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiInteger value[])
{
	return fmiGetInteger((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetBoolean)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiBoolean value[])
{
	return fmiGetBoolean((FMU*)fmuobj, vr, nvr, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetString)(extObj fmuobj, const fmiValueReference vr[], size_t nvr, fmiString value[])
{
	return fmiGetString((FMU*)fmuobj, vr, nvr, value);
}




/* FMI Co-Simulation 1.0 */
extObj PREFIX_FUNCTION(FMUModelCS1)(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn)
{
	fmiCallbackFunctions callBackFunctions;
	callBackFunctions.logger = modelica_logger;
	callBackFunctions.allocateMemory = modelica_allocateMemory;
	callBackFunctions.freeMemory = modelica_freeMemory;
	callBackFunctions.stepFinished = NULL;

	return (extObj)FMUModelCS1(fmuPath, instanceName, loggingOn, callBackFunctions);
}
void PREFIX_FUNCTION(FMUModelCS1Destroy)(extObj* fmuobj){
	FMUModelCS1Destroy((FMU*)fmuobj);
}


const char*	PREFIX_FUNCTION(fmiGetTypesPlatform)(extObj fmuobj)
{
	return fmiGetTypesPlatform((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiInstantiateSlave)(extObj fmuobj)
{
	return fmiInstantiateSlave((FMU*)fmuobj) == NULL ? fmiFatal: fmiOK; 
}

fmiStatus PREFIX_FUNCTION(fmiInitializeSlave)(extObj fmuobj, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop)
{
	return fmiInitializeSlave((FMU*)fmuobj, tStart, StopTimeDefined, tStop);
}

fmiStatus PREFIX_FUNCTION(fmiTerminateSlave)(extObj fmuobj)
{
	return fmiTerminateSlave((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiResetSlave)(extObj fmuobj)
{
	return fmiResetSlave((FMU*)fmuobj);
}

void PREFIX_FUNCTION(fmiFreeSlaveInstance)(extObj fmuobj)
{
	fmiFreeSlaveInstance((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiSetRealInputDerivatives)(extObj fmuobj, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[])
{
	return fmiSetRealInputDerivatives((FMU*)fmuobj, vr, nvr, order, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetRealOutputDerivatives)(extObj fmuobj, const fmiValueReference vr[], size_t  nvr, const fmiInteger order[], fmiReal value[])
{
	return fmiGetRealOutputDerivatives((FMU*)fmuobj, vr, nvr, order, value);
}

fmiStatus PREFIX_FUNCTION(fmiCancelStep)(extObj fmuobj)
{
	return fmiCancelStep((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiDoStep)(extObj fmuobj, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep)
{
	return fmiDoStep((FMU*)fmuobj, currentCommunicationPoint, communicationStepSize, newStep);
}

fmiStatus PREFIX_FUNCTION(fmiGetStatus)(extObj fmuobj, const fmiStatusKind s, fmiStatus*  value)
{
	return fmiGetStatus((FMU*)fmuobj, s, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetRealStatus)(extObj fmuobj, const fmiStatusKind s, fmiReal*  value)
{
	return fmiGetRealStatus((FMU*)fmuobj, s, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetIntegerStatus)(extObj fmuobj, const fmiStatusKind s, fmiInteger*  value)
{
	return fmiGetIntegerStatus((FMU*)fmuobj, s, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetBooleanStatus)(extObj fmuobj, const fmiStatusKind s, fmiBoolean*  value)
{
	return fmiGetBooleanStatus((FMU*)fmuobj, s, value);
}

fmiStatus PREFIX_FUNCTION(fmiGetStringStatus)(extObj fmuobj, const fmiStatusKind s, fmiString*  value)
{
	return fmiGetStringStatus((FMU*)fmuobj, s, value);
}




/* FMI Model Exchange 1.0 */
extObj PREFIX_FUNCTION(FMUModelME1)(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn)
{
	fmiCallbackFunctions callBackFunctions;
	FMU* fmu;
	callBackFunctions.logger = modelica_logger;
	callBackFunctions.allocateMemory = modelica_allocateMemory;
	callBackFunctions.freeMemory = modelica_freeMemory;

	fmu = FMUModelME1(fmuPath, instanceName, loggingOn, callBackFunctions);
	if (fmu)
		fmiInstantiateModel(fmu);
	return (extObj)fmu;
}
void PREFIX_FUNCTION(FMUModelME1Destroy)(extObj* fmuobj){
	FMUModelME1Destroy((FMU*)fmuobj);
}

const char* PREFIX_FUNCTION(fmiGetModelTypesPlatform)	  (extObj fmuobj)
{
	return fmiGetModelTypesPlatform((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiInstantiateModel)(extObj* fmuobj)
{
	return fmiInstantiateModel((FMU*)fmuobj) == NULL ? fmiFatal: fmiOK;
}

void PREFIX_FUNCTION(fmiFreeModelInstance)(extObj fmuobj)
{
	fmiFreeModelInstance((FMU*)fmuobj);
}

fmiStatus PREFIX_FUNCTION(fmiSetTime)(extObj fmuobj, fmiReal time)
{
	return fmiSetTime((FMU*)fmuobj, time);
}

fmiStatus PREFIX_FUNCTION(fmiSetContinuousStates)(extObj fmuobj, const fmiReal x[], size_t nx)
{
	return fmiSetContinuousStates((FMU*)fmuobj, x, nx);
}

fmiStatus PREFIX_FUNCTION(fmiCompletedIntegratorStep)(extObj fmuobj, fmiBoolean* callEventUpdate)
{
	return fmiCompletedIntegratorStep((FMU*)fmuobj, callEventUpdate);
}

fmiStatus PREFIX_FUNCTION(fmiInitialize)(extObj fmuobj, fmiBoolean toleranceControlled, fmiReal relativeTolerance, 
										   fmiBoolean* terminateSimulation, fmiBoolean* upcomingTimeEvent, fmiReal* nextEventTime)
{
	fmiEventInfo eventInfo;
	fmiStatus flag;

	flag = fmiInitialize((FMU*) fmuobj, toleranceControlled, relativeTolerance, &eventInfo);

	*terminateSimulation = eventInfo.terminateSimulation;
	*upcomingTimeEvent = eventInfo.upcomingTimeEvent;
	*nextEventTime = eventInfo.nextEventTime;
	return flag;
}

fmiStatus PREFIX_FUNCTION(fmiGetDerivatives)(extObj fmuobj, fmiReal derivatives[], size_t nx)
{
	return fmiGetDerivatives((FMU*)fmuobj, derivatives, nx);
}

fmiStatus PREFIX_FUNCTION(fmiGetEventIndicators)(extObj fmuobj, fmiReal eventIndicators[], size_t ni)
{
	return fmiGetEventIndicators((FMU*)fmuobj, eventIndicators, ni);
}

fmiStatus PREFIX_FUNCTION(fmiEventUpdate)(extObj fmuobj, fmiBoolean* iterationConverged, fmiBoolean* stateValuesChanged, fmiBoolean* stateValueReferencesChanged, fmiBoolean* terminateSimulation, fmiBoolean* upcomingTimeEvent, fmiReal* nextEventTime)
{
	fmiEventInfo eventInfo;
	fmiBoolean intermediateResults = fmiFalse;
	fmiStatus flag;
	flag = fmiEventUpdate((FMU*)fmuobj, intermediateResults, &eventInfo);
	*iterationConverged = eventInfo.iterationConverged;
	*stateValuesChanged = eventInfo.stateValuesChanged;
	*stateValueReferencesChanged = eventInfo.stateValueReferencesChanged;
	*terminateSimulation = eventInfo.terminateSimulation;
	*upcomingTimeEvent = eventInfo.upcomingTimeEvent;
	*nextEventTime = eventInfo.nextEventTime;
	return flag;
}

fmiStatus PREFIX_FUNCTION(fmiGetContinuousStates)(extObj fmuobj, fmiReal states[], size_t nx)
{
	return fmiGetContinuousStates((FMU*) fmuobj, states, nx);
}

fmiStatus PREFIX_FUNCTION(fmiGetNominalContinuousStates)(extObj fmuobj, fmiReal x_nominal[], size_t nx)
{
	return fmiGetNominalContinuousStates((FMU*)fmuobj, x_nominal, nx);
}

fmiStatus PREFIX_FUNCTION(fmiGetStateValueReferences)(extObj fmuobj, fmiValueReference vrx[], size_t nx)
{
	return fmiGetStateValueReferences((FMU*)fmuobj, vrx, nx);
}

fmiStatus PREFIX_FUNCTION(fmiTerminate)(extObj fmuobj)
{
	return fmiTerminate((FMU*)fmuobj);
}

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif