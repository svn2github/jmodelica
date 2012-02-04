#include "c_fmi_interface_datatypes.h"
#include "c_fmi_interface_common_1_0.h"
#include "c_fmi_interface_me_1_0.h"

/* Constructor for FMI ME 1.0 */
FMU* FMUModelME1(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn, fmiCallbackFunctions callBackFunctions)
{
	return instantiateModel(fmuPath, instanceName, loggingOn, callBackFunctions, FMI_ME1); /* Allocate memory for the FMU wrapper model instance and copy some inputs */	
}

/* Destructor */
void FMUModelME1Destroy(FMU* fmu)
{
	freeModel(fmu);	
	return;
}

fmiComponent fmiInstantiateModel(FMU* fmu)
{
	/* Instantiate model */
	if (!fmu || !fmu->fmu_me1) {
		return NULL;
	} else {
		fmu->c = fmu->fmu_me1->fmiInstantiateModel(fmu->instanceName, fmu->GUID, fmu->callBackFunctions, fmu->loggingOn);
		if (fmu->c)
			fmu->condition |= cond_Instantiated;
		return fmu->c;
	}
}


void fmiFreeModelInstance(FMU* fmu)
{
	if (!fmu || !fmu->fmu_me1) {
		return;
	} else {
		fmu->fmu_me1->fmiFreeModelInstance(fmu->c);		
		return;
	}
}

fmiStatus fmiInitialize(FMU* fmu, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo)
{
	fmiStatus fmiFlag;

	if (!fmu || !fmu->fmu_me1) {
		return fmiFatal;
	} else {
		fmiFlag = fmu->fmu_me1->fmiInitialize(fmu->c, toleranceControlled, relativeTolerance, eventInfo);
		if (fmiFlag != fmiError && fmiFlag != fmiFatal)
			fmu->condition |= cond_Initialized;
		return fmiFlag;
	}
}

/* Call FMI function Macros */
#define CALL_FMI_FUNCTION_RETURN_STRING(functioncall) \
if (!fmu || !fmu->fmu_me1) { \
	return NULL; \
} else { \
	return functioncall; \
}

#define CALL_FMI_FUNCTION_RETURN_FMISTATUS(functioncall) \
if (!fmu || !fmu->fmu_me1) { \
	return fmiFatal; \
} else { \
	return functioncall; \
}

const char* fmiGetModelTypesPlatform(FMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_me1->fmiGetModelTypesPlatform());
}

fmiStatus fmiSetTime(FMU* fmu, fmiReal time)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetTime(fmu->c, time));
}

fmiStatus fmiSetContinuousStates(FMU* fmu, const fmiReal x[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiSetContinuousStates(fmu->c, x, nx));
}


fmiStatus fmiCompletedIntegratorStep(FMU* fmu, fmiBoolean* callEventUpdate)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiCompletedIntegratorStep(fmu->c, callEventUpdate));
}

fmiStatus fmiGetDerivatives(FMU* fmu, fmiReal derivatives[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetDerivatives(fmu->c, derivatives, nx));
}

fmiStatus fmiGetEventIndicators(FMU* fmu, fmiReal eventIndicators[], size_t ni)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetEventIndicators(fmu->c, eventIndicators, ni));
}

fmiStatus fmiEventUpdate(FMU* fmu, fmiBoolean intermediateResults, fmiEventInfo* eventInfo)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiEventUpdate(fmu->c, intermediateResults, eventInfo));
}

fmiStatus fmiGetContinuousStates(FMU* fmu, fmiReal states[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetContinuousStates(fmu->c, states, nx));
}

fmiStatus fmiGetNominalContinuousStates(FMU* fmu, fmiReal x_nominal[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetNominalContinuousStates(fmu->c, x_nominal, nx));
}

fmiStatus fmiGetStateValueReferences(FMU* fmu, fmiValueReference vrx[], size_t nx)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiGetStateValueReferences(fmu->c, vrx, nx));
}

fmiStatus fmiTerminate(FMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_me1->fmiTerminate(fmu->c));
}