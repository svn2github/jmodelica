/*
    Copyright (C) 2012 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/



/** \file fmi_xml_model_description.h
*  \brief Public interface to the FMI XML C-library.
*/

#ifndef FMI_XML_MODELDESCRIPTION_H_
#define FMI_XML_MODELDESCRIPTION_H_

#include <stddef.h>
#include <1.0-ME/fmiModelFunctions.h>
#include <1.0-ME/fmiModelTypes.h>
#include <jm_callbacks.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \defgroup Forward declarations of structs used in the interface.
 * \brief All the structures used in the interfaces are intended to
 *  be treated as opaque objects by the client code.
 */
/*  ModelDescription is the entry point for the package*/
typedef struct fmi_xml_model_description_t fmi_xml_model_description_t;

/* \defgroup Vendor annotation supporting structures*/
/* @{ */
typedef struct fmi_xml_vendor_list_t fmi_xml_vendor_list_t;
typedef struct fmi_xml_vendor_t fmi_xml_vendor_t;
typedef struct fmi_xml_annotation_t fmi_xml_annotation_t;
/* @} */

/* \defgroup  Type definitions supporting structures*/
/* @{ */
typedef struct fmi_xml_real_typedef_t fmi_xml_real_typedef_t;
typedef struct fmi_xml_integer_typedef_t fmi_xml_integer_typedef_t;
typedef struct fmi_xml_enumeration_typedef_t fmi_xml_enumeration_typedef_t;
typedef struct fmi_xml_variable_typedef_t fmi_xml_variable_typedef_t;

typedef struct fmi_xml_type_definitions_t fmi_xml_type_definitions_t;
/* @} */

/* \defgroup Scalar Variable types */
/* @{ */
/* General variable type is convenien to unify all the variable list operations */
typedef struct fmi_xml_variable_t fmi_xml_variable_t;
typedef struct fmi_xml_variable_list_t fmi_xml_variable_list_t;
/* Typed variables are needed to support specific attributes */
typedef struct fmi_xml_real_variable_t fmi_xml_real_variable_t;
typedef struct fmi_xml_integer_variable_t fmi_xml_integer_variable_t;
typedef struct fmi_xml_string_variable_t fmi_xml_string_variable_t;
typedef struct fmi_xml_enum_variable_t fmi_xml_enum_variable_t;
typedef struct fmi_xml_bool_variable_t fmi_xml_bool_variable_t;
/* @} */

/* \defgroup Structures encapsulating unit information */
/* @{ */
typedef struct fmi_xml_unit_t fmi_xml_unit_t;
typedef struct fmi_xml_display_unit_t fmi_xml_display_unit_t;
typedef struct fmi_xml_unit_definitions_t fmi_xml_unit_definitions_t;
/* @} */

/* \defgroup FMU capabilities flags */
/* @{ */
typedef struct fmi_xml_capabilities_t fmi_xml_capabilities_t;
/* @} */

/* 
   \brief Allocate the ModelDescription structure and initialize as empty model.
   @return NULL pointer is returned if memory allocation fails.
   @param callbacks - Standard FMI callbacks may be sent into the module. The argument is optional (pointer can be zero).
*/
fmi_xml_model_description_t* fmi_xml_allocate_model_description( jm_callbacks* callbacks);

/* 
   \brief Parse XML file
   Repeaded calls invalidate the data structures created with the previous call to fmiParseXML,
   i.e., fmiClearModelDescrition is automatically called before reading in the new file.

    @param md A model description object as returned by fmi_xml_allocate_model_description.
    @param filename A name (full path) of the XML file name with model definition.
   @return 0 if parsing was successfull. Non-zero value indicates an error.
*/
int fmi_xml_parse( fmi_xml_model_description_t* md, const char* fileName);

/* 
   Clears the data associated with the model description. This is useful if the same object
   instance is used repeatedly to work with different XML files.
    @param md A model description object as returned by fmi_xml_allocate_model_description.
*/
void fmi_xml_clear_model_description( fmi_xml_model_description_t* md);

/*
*    @param md A model description object as returned by fmi_xml_allocate_model_description.
*    @return 1 if model description is empty and 0 if there is some content associated.
*/
int fmi_xml_is_model_description_empty(fmi_xml_model_description_t* md);

/* Error handling:
*  Many functions in the library return pointers to struct. An error is indicated by returning NULL/0-pointer.
*  If error is returned than fmiGetLastError() functions can be used to retrieve the error message.
*  If logging callbacks were specified then the same information is reported via logger.
*  Memory for the error string is allocated and deallocated in the module.
*  Client code should not store the pointer to the string since it can become invalid.
*    @param md A model description object as returned by fmi_xml_allocate_model_description.
*    @return NULL-terminated string with an error message.
*/
const char* fmi_xml_get_last_error(fmi_xml_model_description_t* md);

/* 
fmiClearLastError clears the error message and returns 0 if further processing is possible. If it returns 1 then the 
error was not recoverable. Model desciption should be freed and recreated.
*/
int fmi_xml_clear_last_error(fmi_xml_model_description_t* md);

/* Release the memory allocated
@param md A model description object as returned by fmi_xml_allocate_model_description.
*/
void fmi_xml_free_model_description(fmi_xml_model_description_t*);

/* \defgroup General information
 * \brief Functions for retrieving general model information. Memory for the strings is allocated and deallocated in the module.
 *       All the functions take a model description object as returned by fmi_xml_allocate_model_description as parameter.
 * @{
*/
const char* fmi_xml_get_model_name(fmi_xml_model_description_t* md);

const char* fmi_xml_get_model_identifier(fmi_xml_model_description_t* md);

const char* fmi_xml_get_GUID(fmi_xml_model_description_t* md);

const char* fmi_xml_get_description(fmi_xml_model_description_t* md);

const char* fmi_xml_get_author(fmi_xml_model_description_t* md);

const char* fmi_xml_get_model_version(fmi_xml_model_description_t* md);
const char* fmi_xml_get_model_standard_version(fmi_xml_model_description_t* md);
const char* fmi_xml_get_generation_tool(fmi_xml_model_description_t* md);
const char* fmi_xml_get_generation_date_and_time(fmi_xml_model_description_t* md);

typedef enum fmi_xml_variable_naming_convension_enu_t
{ 
        fmi_xml_naming_enu_flat,
        fmi_xml_naming_enu_structured
} fmi_xml_variable_naming_convension_enu_t;

fmi_xml_variable_naming_convension_enu_t fmi_xml_get_naming_convention(fmi_xml_model_description_t* md);

static const char* fmi_xml_naming_convention2string(fmi_xml_variable_naming_convension_enu_t convention) {
    if(convention == fmi_xml_naming_enu_flat) return "flat";
    if(convention == fmi_xml_naming_enu_structured) return "structured";
    return "Invalid";
}

unsigned int fmi_xml_get_number_of_continuous_states(fmi_xml_model_description_t* md);

unsigned int fmi_xml_get_number_of_event_indicators(fmi_xml_model_description_t* md);

double fmi_xml_get_default_experiment_start(fmi_xml_model_description_t* md);

void fmi_xml_set_default_experiment_start(fmi_xml_model_description_t* md, double);

double fmi_xml_get_default_experiment_stop(fmi_xml_model_description_t* md);

void fmi_xml_set_default_experiment_stop(fmi_xml_model_description_t* md, double);

double fmi_xml_get_default_experiment_tolerance(fmi_xml_model_description_t* md);

void fmi_xml_set_default_experiment_tolerance(fmi_xml_model_description_t* md, double);

typedef enum fmi_xml_fmu_kind_enu_t
{
        fmi_xml_fmu_kind_enu_me = 0,
        fmi_xml_fmu_kind_enu_cs_standalone,
        fmi_xml_fmu_kind_enu_cs_tool
} fmi_xml_fmu_kind_enu_t;

static const char* fmi_xml_fmu_kind2string(fmi_xml_fmu_kind_enu_t kind) {
    switch (kind) {
    case fmi_xml_fmu_kind_enu_me: return "ModelExchange";
    case fmi_xml_fmu_kind_enu_cs_standalone: return "CoSimulation_StandAlone";
    case fmi_xml_fmu_kind_enu_cs_tool: return "CoSimulation_Tool";
    }
    return "Invalid";
}

fmi_xml_fmu_kind_enu_t fmi_xml_get_fmu_kind(fmi_xml_model_description_t* md);

fmi_xml_capabilities_t* fmi_xml_get_capabilities(fmi_xml_model_description_t* md);


/* @} */
#include "fmi_xml_type.h"
#include "fmi_xml_unit.h"
#include "fmi_xml_variable.h"
#include "fmi_xml_variable_list.h"
#include "fmi_xml_vendor_annotations.h"
#include "fmi_xml_capabilities.h"
#include "fmi_xml_cosim.h"

#endif
