#ifndef C_FMI_INTERFACE_COMMON_1_0_H
#define C_FMI_INTERFACE_COMMON_1_0_H

#include "c_fmi_interface_datatypes.h"

typedef enum {
	call_success,
	call_error
} callStatus;

FMU* instantiateModel(const char* fmuPath_dummy_right_now, fmiString instanceName, fmiBoolean loggingOn, fmiCallbackFunctions callBackFunctions, fmiStandard standard);
void freeModel(FMU* fmu);

/* Common FMI functions */
const char* fmiGetVersion				  (FMU* fmu);
fmiStatus	fmiSetDebugLogging			  (FMU* fmu, fmiBoolean loggingOn);
fmiStatus	fmiSetReal					  (FMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]);
fmiStatus	fmiSetInteger				  (FMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
fmiStatus	fmiSetBoolean				  (FMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
fmiStatus	fmiSetString				  (FMU* fmu, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
fmiStatus	fmiGetReal					  (FMU* fmu, const fmiValueReference vr[], size_t nvr, fmiReal    value[]);
fmiStatus	fmiGetInteger				  (FMU* fmu, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
fmiStatus	fmiGetBoolean				  (FMU* fmu, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
fmiStatus	fmiGetString				  (FMU* fmu, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

#endif /* End of header file C_FMI_INTERFACE_COMMON_1_0_H */