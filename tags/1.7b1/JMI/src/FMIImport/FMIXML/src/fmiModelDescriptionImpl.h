#ifndef fmiModelDecriptionImpl_h_
#define fmiModelDecriptionImpl_h_

#include <stdarg.h>

#include <jm_callbacks.h>
#include <jm_vector.h>
#include <jm_named_ptr.h>
#include <jm_string_set.h>
#include "fmiCallbacks.h"
#include "fmiModelDescription.h"

#include "fmiUnitImpl.h"
#include "fmiTypeImpl.h"
#include "fmiVariableImpl.h"
#include "fmiVendorAnnotations.h"

typedef enum fmiModelDescriptionStatus_ {
    fmiModelDescriptionEmpty,
    fmiModelDescriptionOK,
    fmiModelDescriptionError
} fmiModelDescriptionStatus;

/*  ModelDescription is the entry point for the package*/
struct fmiModelDescription {

    jm_callbacks* callbacks;

    fmiCallbacks fmiCallbacksMap;

    #define FMI_MAX_ERROR_MESSAGE_SIZE 200

    char errMessageBuf[FMI_MAX_ERROR_MESSAGE_SIZE];

    fmiModelDescriptionStatus status;

    jm_vector(char) fmiStandardVersion;

    jm_vector(char) modelName;

    jm_vector(char) modelIdentifier;

    jm_vector(char) GUID;

    jm_vector(char) description;

    jm_vector(char) author;

    jm_vector(char) version;
    jm_vector(char) generationTool;
    jm_vector(char) generationDateAndTime;

    fmiVariableNamingConvension namingConvension;

    size_t numberOfContinuousStates;

    size_t numberOfEventIndicators;

    double defaultExperimentStartTime;

    double defaultExperimentStopTime;

    double defaultExperimentTolerance;

    jm_vector(jm_voidp) vendorList;

    jm_vector(jm_named_ptr) unitDefinitions;
    jm_vector(jm_named_ptr) displayUnitDefinitions;

    fmiTypeDefinitions typeDefinitions;

    jm_string_set descriptions;

    jm_vector(jm_named_ptr) variables;

    fmiVariableList* variablesByVR;
};

void fmiReportError(fmiModelDescription* md, const char* module, const char* fmt, va_list ap);

#endif

