#ifndef C_FMI_INTERFACE_CS_1_0_H
#define C_FMI_INTERFACE_CS_1_0_H

#include "c_fmi_interface_datatypes.h"
#include "c_fmi_interface_common_1_0.h"

FMU* FMUModelCS1(const char* fmuPath, const char* instanceName, fmiBoolean loggingOn, fmiCallbackFunctions callBackFunctions);
void FMUModelCS1Destroy(FMU* fmu);

const char*	fmiGetTypesPlatform			  (FMU* fmu);
fmiComponent fmiInstantiateSlave		  (FMU* fmu);
fmiStatus	fmiInitializeSlave			  (FMU* fmu, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop);
fmiStatus	fmiTerminateSlave			  (FMU* fmu);
fmiStatus	fmiResetSlave				  (FMU* fmu);
void		fmiFreeSlaveInstance		  (FMU* fmu);
fmiStatus	fmiSetRealInputDerivatives	  (FMU* fmu, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[]);                                                  
fmiStatus	fmiGetRealOutputDerivatives   (FMU* fmu, const fmiValueReference vr[], size_t  nvr, const fmiInteger order[], fmiReal value[]);                                              
fmiStatus	fmiCancelStep				  (FMU* fmu);
fmiStatus	fmiDoStep					  (FMU* fmu, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep);
fmiStatus	fmiGetStatus				  (FMU* fmu, const fmiStatusKind s, fmiStatus*  value);
fmiStatus	fmiGetRealStatus			  (FMU* fmu, const fmiStatusKind s, fmiReal*    value);
fmiStatus	fmiGetIntegerStatus			  (FMU* fmu, const fmiStatusKind s, fmiInteger* value);
fmiStatus	fmiGetBooleanStatus			  (FMU* fmu, const fmiStatusKind s, fmiBoolean* value);
fmiStatus	fmiGetStringStatus			  (FMU* fmu, const fmiStatusKind s, fmiString*  value);

#endif /* End of header file C_FMI_INTERFACE_CS_1_0_H */