#include "c_fmi_interface_common_1_0.h"
#include "c_fmi_unzip.h"
#include "c_fmi_interface_datatypes.h"

//#include "m_fmi_interface_unzip.h"
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#ifdef _MSC_VER /* Microsoft Windows API */
#include "windows.h"
#include "StrSafe.h"
#define FILE_SEP "\\" 
#define DLL_EXT ".dll"
#else
#define FILE_SEP "/"
#define DLL_EXT ".so"
#endif

/* Set DLL path folder */
#if _WIN32 || _WIN64
#if _WIN64
#define FMU_DLL_PLATFORM_FOLDER "win64"
#else
#define FMU_DLL_PLATFORM_FOLDER "win32"
#endif
#endif
#if __GNUC__ /* Assuming this is Linux */
#if __x86_64__ || __ppc64__
#define FMU_DLL_PLATFORM_FOLDER "linux64"
#else
#define FMU_DLL_PLATFORM_FOLDER "linux32"
#endif
#endif

#define FUNCTION_NAME_LENGTH_MAX 2048			/* Maximum length of FMI function name. Used in the load DLL function. */
#define PRE_FIX_LOGGER_MSG "C FMI Interface: "	/* Logger message example: "M FMI Interface: Could not allocate memory for this and that.." */
#define STRINGIFY(s) #s

/* Help functions */
static void print_load_dll_error(FMU* fmu)
{
#ifdef _MSC_VER
	int dllerror  = GetLastError();
	LPVOID lpMsgBuf;
	LPVOID lpDisplayBuf;

	FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, dllerror, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR) &lpMsgBuf, 0, NULL);
	lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT, (lstrlen((LPCTSTR)lpMsgBuf)+40)*sizeof(TCHAR)); 
	StringCchPrintf((LPTSTR)lpDisplayBuf, LocalSize(lpDisplayBuf) / sizeof(TCHAR), TEXT("%s: error %d"), lpMsgBuf,dllerror);
	fmu->callBackFunctions.logger(NULL, fmu->instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Loading DLL failed: %s",lpDisplayBuf);
#else
	fmu->callBackFunctions.logger(NULL, fmu->instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Loading DLL failed: %s",dlerror());
#endif
	return;
}

static callStatus load_dll_function(FMU* fmu, const char* function_name, void** fptr)
{
	char fname[FUNCTION_NAME_LENGTH_MAX];
	void* tmpfptr;

	if (strlen(fmu->modelIdentifier) + strlen(function_name) + 2 > FUNCTION_NAME_LENGTH_MAX) {
		fmu->callBackFunctions.logger(NULL, fmu->instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "DLL function name is too long. Max length is set to " STRINGIFY(FUNCTION_NAME_LENGTH_MAX) ".");
		return call_error;
	}

	sprintf(fname,"%s_%s", fmu->modelIdentifier, function_name);
#ifdef _MSC_VER
	*fptr = tmpfptr = GetProcAddress(fmu->dllHandle, fname);
#else
	*fptr = tmpfptr = dlsym(fmu->dllHandle, name);
#endif
	if (!tmpfptr) { /* Fail */
		return call_error;
	} else {		/* Success */
		return call_success;
	}
}

void free_dll(FMU* fmu)
{
	if (fmu->dllHandle) {
		/* Free DLL handle */
#ifdef _MSC_VER		
		FreeLibrary(fmu->dllHandle);		
#else		
		dlclose(fmu->dllHandle);
#endif
	}
}

static callStatus load_dll_handle(FMU* fmu)
{
	/* Load DLL */
#ifdef _MSC_VER
	fmu->dllHandle = LoadLibrary(fmu->dllPath);
#else	
	fmu->dllHandle = dlopen(fmu->dllPath, RTLD_LAZY);
#endif	
	if (!fmu->dllHandle) {
		return call_error;
	}

	fmu->condition |=cond_DllLoaded;
	return call_success;
}

static callStatus load_dll_functions_me1(FMU* fmu)
{
	/* Load FMI functions */
#ifdef LOAD_DLL_FUNCTION
#undef LOAD_DLL_FUNCTION
#endif
#define LOAD_DLL_FUNCTION(FMIFUNCTION) if (load_dll_function(fmu, #FMIFUNCTION, (void**)&fmu->fmu_me1->FMIFUNCTION) != call_success) return call_error
	LOAD_DLL_FUNCTION(fmiGetModelTypesPlatform);
	LOAD_DLL_FUNCTION(fmiInstantiateModel);
	LOAD_DLL_FUNCTION(fmiFreeModelInstance);
	LOAD_DLL_FUNCTION(fmiSetTime);
	LOAD_DLL_FUNCTION(fmiSetContinuousStates);
	LOAD_DLL_FUNCTION(fmiCompletedIntegratorStep);
	LOAD_DLL_FUNCTION(fmiInitialize);
	LOAD_DLL_FUNCTION(fmiGetDerivatives);
	LOAD_DLL_FUNCTION(fmiGetEventIndicators);
	LOAD_DLL_FUNCTION(fmiEventUpdate);
	LOAD_DLL_FUNCTION(fmiGetContinuousStates);
	LOAD_DLL_FUNCTION(fmiGetNominalContinuousStates);
	LOAD_DLL_FUNCTION(fmiGetStateValueReferences);
	LOAD_DLL_FUNCTION(fmiTerminate);
	return call_success; 
}

static callStatus load_dll_functions_cs1(FMU* fmu)
{
	/* Load FMI functions */
#ifdef LOAD_DLL_FUNCTION
#undef LOAD_DLL_FUNCTION
#endif
#define LOAD_DLL_FUNCTION(FMIFUNCTION) if (load_dll_function(fmu, #FMIFUNCTION, (void**)&fmu->fmu_cs1->FMIFUNCTION) != call_success) { \
	fmu->callBackFunctions.logger(NULL, fmu->instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not load the FMI function '"#FMIFUNCTION"'."); \
	return call_error; \
}

	/* Workaround for Dymola 2012 and SimulationX 3.x */
	if (load_dll_function(fmu, "fmiGetTypesPlatform", (void**)&fmu->fmu_cs1->fmiGetTypesPlatform) != call_success) {
		if (load_dll_function(fmu, "fmiGetModelTypesPlatform", (void**)&fmu->fmu_cs1->fmiGetTypesPlatform) != call_success) {
			fmu->callBackFunctions.logger(NULL, fmu->instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not load any of the FMI functions 'fmiGetModelTypesPlatform' or 'fmiGetTypesPlatform'.");
			return call_error;
		}
	}
	LOAD_DLL_FUNCTION(fmiInstantiateSlave);
	LOAD_DLL_FUNCTION(fmiInitializeSlave);
	LOAD_DLL_FUNCTION(fmiTerminateSlave);
	LOAD_DLL_FUNCTION(fmiResetSlave);
	LOAD_DLL_FUNCTION(fmiFreeSlaveInstance);
	LOAD_DLL_FUNCTION(fmiSetRealInputDerivatives);
	LOAD_DLL_FUNCTION(fmiGetRealOutputDerivatives);
	LOAD_DLL_FUNCTION(fmiCancelStep);
	LOAD_DLL_FUNCTION(fmiDoStep);
	LOAD_DLL_FUNCTION(fmiGetStatus);
	LOAD_DLL_FUNCTION(fmiGetRealStatus);
	LOAD_DLL_FUNCTION(fmiGetIntegerStatus);
	LOAD_DLL_FUNCTION(fmiGetBooleanStatus);
	LOAD_DLL_FUNCTION(fmiGetStringStatus);
	return call_success;
}

static callStatus load_dll_functions_common1(FMU* fmu)
{
	/* Load FMI functions */
#ifdef LOAD_DLL_FUNCTION
#undef LOAD_DLL_FUNCTION
#endif
#define LOAD_DLL_FUNCTION(FMIFUNCTION) if (load_dll_function(fmu, #FMIFUNCTION, (void**)&fmu->fmu_common1->FMIFUNCTION) != call_success) return call_error
	LOAD_DLL_FUNCTION(fmiGetVersion);
	LOAD_DLL_FUNCTION(fmiSetDebugLogging);
	LOAD_DLL_FUNCTION(fmiSetReal);
	LOAD_DLL_FUNCTION(fmiSetInteger);
	LOAD_DLL_FUNCTION(fmiSetBoolean);
	LOAD_DLL_FUNCTION(fmiSetString);
	LOAD_DLL_FUNCTION(fmiGetReal);
	LOAD_DLL_FUNCTION(fmiGetInteger);
	LOAD_DLL_FUNCTION(fmiGetBoolean);
	LOAD_DLL_FUNCTION(fmiGetString);
	return call_success;
}

void freeModel(FMU* fmu)
{
	/* If NULL ptr is passed, which may be the case if instantiate function fails */
	if (fmu == NULL)
		return;

	/* If DLL is loaded */
	if (fmu->condition & cond_DllLoaded)
		free_dll(fmu);

	/* Remove unzip folder */
	if (fmu->condition & cond_UnzipedFMU) {
	}

	/* If wrapper model instance is loaded */
	if (fmu->condition & cond_WrapperModelLoaded) {
		fmu->callBackFunctions.freeMemory((void*)fmu->dllPath);
		fmu->callBackFunctions.freeMemory((void*)fmu->xmlPath);
		fmu->callBackFunctions.freeMemory((void*)fmu->unzipPath);
		fmu->callBackFunctions.freeMemory((void*)fmu->fmuPath);
		fmu->callBackFunctions.freeMemory((void*)fmu->GUID);
		fmu->callBackFunctions.freeMemory((void*)fmu->instanceName);
		fmu->callBackFunctions.freeMemory((void*)fmu->modelIdentifier);	

		fmu->callBackFunctions.freeMemory((void*)fmu->fmu_me1);	
		fmu->callBackFunctions.freeMemory((void*)fmu->fmu_cs1);	
		fmu->callBackFunctions.freeMemory((void*)fmu->fmu_common1);
		fmu->callBackFunctions.freeMemory(fmu);
	}
	return;
}

/* Return NULL to indicate failier */
#define TEMPFOLDER "C:\\P510-JModelica\\FMIToolbox\\trunk\\src\\wrapperfolder\\temporaryfolder\\"
static char* getTempFolder(FMU* fmu)
{
	char* str_ptr;
	str_ptr = (char*)fmu->callBackFunctions.allocateMemory(sizeof(char), strlen(TEMPFOLDER) + 1);
	if (!str_ptr)
		return NULL;
	return strcpy(str_ptr,TEMPFOLDER);	
}

#define GUID_MACRO "sadasd"
#define MODEL_IDENTIFIER "Furuta"

/* Help function used in the instantiate functions */
FMU* instantiateModel(const char* fmuPath, fmiString instanceName, fmiBoolean loggingOn, fmiCallbackFunctions callBackFunctions, fmiStandard standard)
{
	FMU* fmu = NULL;
	//char* fmuPath = FMU_PATH;
	fmiCallbackLogger         fmuLogger;
	fmiCallbackAllocateMemory fmuCalloc;
	fmiCallbackFreeMemory     fmuFree;

	fmuLogger = callBackFunctions.logger;
	fmuCalloc = callBackFunctions.allocateMemory;
	fmuFree = callBackFunctions.freeMemory;


	/* Allocate memory for the FMU instance */
	fmu = (FMU*)fmuCalloc(1,sizeof(FMU));
	if (fmu==NULL) { /* Could not allocate memory for the FMU struct */
		fmuLogger(NULL,instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the FMU struct.");
		goto error_goto;
	}
	
	/* Set FMU wrapper model condition */
	fmu->condition = 0;
	fmu->condition |= cond_WrapperModelLoaded;

	/* Set callback functions */
	fmu->callBackFunctions = callBackFunctions;

	/* Set FMI standard to load */
	fmu->standard = standard;

	/* Set all memory alloated pointers to NULL */
	fmu->dllPath = NULL;
	fmu->xmlPath = NULL;
	fmu->unzipPath = NULL;
	fmu->fmuPath = NULL;
	fmu->GUID = NULL;
	fmu->instanceName = NULL;
	fmu->dllHandle = NULL;
	fmu->modelIdentifier = NULL;
	fmu->c = NULL;
	fmu->fmu_me1 = NULL;
	fmu->fmu_cs1 = NULL;
	fmu->fmu_common1 = NULL;

	/* Allocate memory for the specific FMI standard structs */
	switch (standard) {
		case FMI_ME1:
			fmu->fmu_me1 = (FMUME1*)fmuCalloc(1,sizeof(FMUME1));
			if (fmu->fmu_me1 == NULL) {
				fmuLogger(NULL,instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the FMU->FMUME1 struct.");
				goto error_goto;
			}
			break;
		case FMI_CS1:
			fmu->fmu_cs1 = (FMUCS1*)fmuCalloc(1,sizeof(FMUCS1));
			if (fmu->fmu_cs1 == NULL) {
				fmuLogger(NULL,instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the FMU->FMUME1 struct.");
				goto error_goto;
			}
			break;
		default:
			fmuLogger(NULL,instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Not a supported FMI standard.");
			goto error_goto;
	}

	/* Allocate memory for the common FMI standard struct */
	fmu->fmu_common1 = (FMUCOMMON1*)fmuCalloc(1,sizeof(FMUCOMMON1));
	if (fmu->fmu_common1 == NULL) {
		fmuLogger(NULL,instanceName, fmiFatal, "", PRE_FIX_LOGGER_MSG "Could not allocate memory for the FMU->FMUME1 struct.");
		goto error_goto;
	}

	/* Get temporary folder to unzip the FMU in */
	fmu->unzipPath = getTempFolder(fmu);
	if (!fmu->unzipPath)
		goto error_goto;

	/* Unzip FMU */
	if (!unzipFMU(fmuPath, fmu->unzipPath))
		goto error_goto;

	fmu->condition |= cond_UnzipedFMU;

	/* Copy DLL path */
	fmu->dllPath = (char*)fmuCalloc(sizeof(char), strlen(fmu->unzipPath) + strlen(FILE_SEP "binaries" FILE_SEP FMU_DLL_PLATFORM_FOLDER FILE_SEP "Furuta" DLL_EXT) + 1);
	sprintf(fmu->dllPath, "%s%s", fmu->unzipPath, FILE_SEP "binaries" FILE_SEP FMU_DLL_PLATFORM_FOLDER FILE_SEP "Furuta" DLL_EXT);

	/* Copy XML path */
	fmu->xmlPath = (char*)fmuCalloc(sizeof(char), strlen(fmu->unzipPath) + strlen(FILE_SEP "modelDescription.xml") + 1);
	sprintf(fmu->xmlPath, "%s%s", fmu->unzipPath, FILE_SEP "modelDescription.xml");

	/* Copy FMU path */
	fmu->fmuPath = (char*)fmuCalloc(sizeof(char), strlen(fmuPath) + 1);
	sprintf(fmu->fmuPath, "%s", fmuPath);

	/* Copy instance name */
	fmu->instanceName = (char*)fmuCalloc(sizeof(char), strlen(instanceName) + 1);
	sprintf(fmu->instanceName, "%s", instanceName);

	/* THIS SHOULD BE DONE AFTER THE XML IS PARSED */
	/* Copy the GUID */
	fmu->GUID = (char*)fmuCalloc(sizeof(char), strlen(GUID_MACRO) + 1);
	sprintf(fmu->GUID, "%s", GUID_MACRO);	

	/* Copy the modelIdentifier */
	fmu->modelIdentifier = (char*)fmuCalloc(sizeof(char), strlen(MODEL_IDENTIFIER) + 1);
	sprintf(fmu->modelIdentifier, "%s", MODEL_IDENTIFIER);	

	/* Load DLL Handle */
	if (load_dll_handle(fmu) == call_error) {
		print_load_dll_error(fmu);
		goto error_goto;
	}

	/* Load FMI standard specific DLL functions */
	switch (fmu->standard) {
		case FMI_ME1:
			if (load_dll_functions_me1(fmu) == call_error) {
				print_load_dll_error(fmu);
				goto error_goto;
			}
			break;

		case FMI_CS1:
			if (load_dll_functions_cs1(fmu) == call_error) {
				print_load_dll_error(fmu);
				goto error_goto;
			}
			break;
	}

	/* Load FMI standard common DLL functions */	
	if (load_dll_functions_common1(fmu) == call_error) {
		print_load_dll_error(fmu);
		goto error_goto;
	}

	/* Set FMU wrapper model condition */
	fmu->condition |= cond_DllLoaded;

	/* Everything was succesfull */
	return fmu;

error_goto:
	freeModel(fmu);
	return NULL;
}

/* Call FMI function Macros */
#define CALL_FMI_FUNCTION_RETURN_STRING(functioncall) \
if (!fmu || !fmu->fmu_common1) { \
	return NULL; \
} else { \
	return functioncall; \
}

#define CALL_FMI_FUNCTION_RETURN_FMISTATUS(functioncall) \
if (!fmu || !fmu->fmu_common1) { \
	return fmiFatal; \
} else { \
	return functioncall; \
}

/* Common FMI functions */

const char* fmiGetVersion(FMU* fmu)
{
	CALL_FMI_FUNCTION_RETURN_STRING(fmu->fmu_common1->fmiGetVersion());
}

fmiStatus fmiSetDebugLogging(FMU* fmu, fmiBoolean loggingOn)
{
	CALL_FMI_FUNCTION_RETURN_FMISTATUS(fmu->fmu_common1->fmiSetDebugLogging(fmu->c, loggingOn));
}

/* fmiSet* functions */
#define FMISETX(FNAME,FTYPE) \
fmiStatus FNAME(FMU* fmu, const fmiValueReference vr[], size_t nvr, const FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_common1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_common1->FNAME(fmu->c, vr, nvr, value); \
	} \
}

/* fmiGet* functions */
#define FMIGETX(FNAME,FTYPE) \
fmiStatus FNAME(FMU* fmu, const fmiValueReference vr[], size_t nvr, FTYPE value[]) \
{ \
	if (!fmu || !fmu->fmu_common1) { \
		return fmiFatal; \
	} else { \
		return fmu->fmu_common1->FNAME(fmu->c, vr, nvr, value); \
	} \
}

FMISETX(fmiSetReal,		fmiReal);
FMISETX(fmiSetInteger,	fmiInteger);
FMISETX(fmiSetBoolean,	fmiBoolean);
FMISETX(fmiSetString,	fmiString);

FMIGETX(fmiGetReal,		fmiReal);
FMIGETX(fmiGetInteger,	fmiInteger);
FMIGETX(fmiGetBoolean,	fmiBoolean);
FMIGETX(fmiGetString,	fmiString);
