#include "c_fmi_interface_datatypes.h"
#include "c_fmi_interface_common_1_0.h"
#include "c_fmi_interface_cs_1_0.h"

/* Constructor for FMI ME 1.0 */
FMU* FMUModelCS1(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn, fmiCallbackFunctions callBackFunctions)
{
	return instantiateModel(fmuPath, instanceName, loggingOn, callBackFunctions, FMI_CS1); /* Allocate memory for the FMU wrapper model instance and copy some inputs */	
}

/* Destructor */
void FMUModelCS1Destroy(FMU* fmu)
{
	freeModel(fmu);
	return;
}

fmiComponent fmiInstantiateSlave(FMU* fmu)
{
	/* Instantiate model */
	if (!fmu || !fmu->fmu_cs1) {
		return NULL;
	} else {
		fmu->c = fmu->fmu_cs1->fmiInstantiateSlave(fmu->instanceName, fmu->GUID, "", "", 0, fmiFalse, fmiFalse, fmu->callBackFunctions, fmu->loggingOn);
		if (fmu->c)
			fmu->condition |= cond_Instantiated;
		return fmu->c;
	}
}

void fmiFreeSlaveInstance(FMU* fmu)
{
	if (!fmu || !fmu->fmu_cs1) {
		return;
	} else {
		fmu->fmu_cs1->fmiFreeSlaveInstance(fmu->c);
		freeModel(fmu);
		return;
	}	
}


fmiStatus fmiInitializeSlave(FMU* fmu, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop)
{
	fmiStatus fmiFlag;

	if (!fmu || !fmu->fmu_cs1) {
		return fmiFatal;
	} else {
		fmiFlag = fmu->fmu_cs1->fmiInitializeSlave(fmu->c, tStart, StopTimeDefined, tStop);
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

const char* fmiGetTypesPlatform(FMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_cs1->fmiGetTypesPlatform());
}

fmiStatus fmiTerminateSlave(FMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiTerminateSlave(fmu->c));
}

fmiStatus fmiResetSlave(FMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiResetSlave(fmu->c));
}

fmiStatus fmiSetRealInputDerivatives(FMU* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[])  
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiSetRealInputDerivatives(fmu->c, vr, nvr, order, value));
}

fmiStatus fmiGetRealOutputDerivatives(FMU* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[])   
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiGetRealOutputDerivatives(fmu->c, vr, nvr, order, value));
}

fmiStatus fmiCancelStep(FMU* fmu)   
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiCancelStep(fmu->c));
}

fmiStatus fmiDoStep(FMU* fmu, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_cs1->fmiDoStep(fmu->c, currentCommunicationPoint, communicationStepSize, newStep));
}

/* fmiGetStatus* */
#define FMIGETSTATUSX(FNAME,FSTATUSTYPE) \
fmiStatus FNAME(FMU* fmu, const fmiStatusKind s, FSTATUSTYPE*  value) \
{ \
	if (!fmu || !fmu->fmu_cs1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_cs1->FNAME(fmu->c, s, value); \
	} \
}

FMIGETSTATUSX(fmiGetStatus, fmiStatus)
FMIGETSTATUSX(fmiGetRealStatus, fmiReal)
FMIGETSTATUSX(fmiGetIntegerStatus, fmiInteger)
FMIGETSTATUSX(fmiGetBooleanStatus, fmiBoolean)
FMIGETSTATUSX(fmiGetStringStatus, fmiString)