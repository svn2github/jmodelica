#ifndef fmi_xml_model_decription_impl_h_
#define fmi_xml_model_decription_impl_h_

#include <stdarg.h>

#include <jm_callbacks.h>
#include <jm_vector.h>
#include <jm_named_ptr.h>
#include <jm_string_set.h>
#include "fmi_xml_callbacks.h"
#include "fmi_xml_model_description.h"

#include "fmi_xml_unit_impl.h"
#include "fmi_xml_type_impl.h"
#include "fmi_xml_variable_impl.h"
#include "fmi_xml_vendor_annotations.h"
#include "fmi_xml_capabilities_impl.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum fmi_xml_model_description_status_enu_t {
    fmi_xml_model_description_enu_empty,
    fmi_xml_model_description_enu_ok,
    fmi_xml_model_description_enu_error
} fmi_xml_model_description_status_enu_t;

/*  ModelDescription is the entry point for the package*/
struct fmi_xml_model_description_t {

    jm_callbacks* callbacks;

    #define FMI_MAX_ERROR_MESSAGE_SIZE 1000

    char errMessageBuf[FMI_MAX_ERROR_MESSAGE_SIZE];

    fmi_xml_model_description_status_enu_t status;

    jm_vector(char) fmi_xml_standard_version;

    jm_vector(char) modelName;

    jm_vector(char) modelIdentifier;

    jm_vector(char) GUID;

    jm_vector(char) description;

    jm_vector(char) author;

    jm_vector(char) version;
    jm_vector(char) generationTool;
    jm_vector(char) generationDateAndTime;

    fmi_xml_variable_naming_convension_enu_t namingConvension;

    size_t numberOfContinuousStates;

    size_t numberOfEventIndicators;

    double defaultExperimentStartTime;

    double defaultExperimentStopTime;

    double defaultExperimentTolerance;

    jm_vector(jm_voidp) vendorList;

    jm_vector(jm_named_ptr) unitDefinitions;
    jm_vector(jm_named_ptr) displayUnitDefinitions;

    fmi_xml_type_definitions_t typeDefinitions;

    jm_string_set descriptions;

    jm_vector(jm_named_ptr) variables;

    fmi_xml_variable_list_t* variablesByVR;

    fmi_xml_fmu_kind_enu_t fmuKind;

    fmi_xml_capabilities_t capabilities;

    jm_vector(char) entryPoint;
    jm_vector(char) mimeType;
    int manual_start;
    jm_vector(jm_string) additionalModels;
};

void fmi_xml_report_error(fmi_xml_model_description_t* md, const char* module, const char* fmt, ...);

void fmi_xml_report_error_v(fmi_xml_model_description_t* md, const char* module, const char* fmt, va_list ap);

void fmi_xml_report_warning(fmi_xml_model_description_t* md, const char* module, const char* fmt, ...);

void fmi_xml_report_warning_v(fmi_xml_model_description_t* md, const char* module, const char* fmt, va_list ap);


#ifdef __cplusplus
}
#endif

#endif

