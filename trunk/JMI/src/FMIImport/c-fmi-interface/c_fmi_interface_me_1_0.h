#ifndef C_FMI_INTERFACE_ME_1_0_H
#define C_FMI_INTERFACE_ME_1_0_H

#include "c_fmi_interface_datatypes.h"
#include "c_fmi_interface_common_1_0.h"

FMU* FMUModelME1(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn, fmiCallbackFunctions callBackFunctions);
void FMUModelME1Destroy(FMU* fmu);

const char* fmiGetModelTypesPlatform	  (FMU* fmu);
fmiComponent fmiInstantiateModel		  (FMU* fmu);
void		fmiFreeModelInstance		  (FMU* fmu);
fmiStatus	fmiSetTime					  (FMU* fmu, fmiReal time);
fmiStatus	fmiSetContinuousStates		  (FMU* fmu, const fmiReal x[], size_t nx);
fmiStatus	fmiCompletedIntegratorStep	  (FMU* fmu, fmiBoolean* callEventUpdate);
fmiStatus	fmiInitialize				  (FMU* fmu, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);

fmiStatus	fmiGetDerivatives			  (FMU* fmu, fmiReal derivatives[]    , size_t nx);
fmiStatus	fmiGetEventIndicators		  (FMU* fmu, fmiReal eventIndicators[], size_t ni);
fmiStatus	fmiEventUpdate				  (FMU* fmu, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);
fmiStatus	fmiGetContinuousStates        (FMU* fmu, fmiReal states[], size_t nx);
fmiStatus	fmiGetNominalContinuousStates (FMU* fmu, fmiReal x_nominal[], size_t nx);
fmiStatus	fmiGetStateValueReferences    (FMU* fmu, fmiValueReference vrx[], size_t nx);
fmiStatus	fmiTerminate                  (FMU* fmu);


#endif /* End of header file C_FMI_INTERFACE_ME_1_0_H */