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



/** \file fmi1_import.h
*  \brief Public interface to the FMI import C-library.
*/

#ifndef FMI1_IMPORT_H_
#define FMI1_IMPORT_H_

#include <stddef.h>
#include <jm_callbacks.h>
#include <Common/fmi_import_context.h>
#include <FMI1/fmi1_xml_model_description.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \defgroup Forward declarations of structs used in the interface.
 * \brief All the structures used in the interfaces are intended to
 *  be treated as opaque objects by the client code.
 */

/* \defgroup Vendor annotation supporting structures*/
/* @{ */
typedef fmi1_xml_vendor_list_t fmi1_import_vendor_list_t;
typedef fmi1_xml_vendor_t fmi1_import_vendor_t;
typedef fmi1_xml_annotation_t fmi1_import_annotation_t;
/* @} */

/* \defgroup  Type definitions supporting structures*/
/* @{ */
typedef fmi1_xml_real_typedef_t fmi1_import_real_typedef_t;
typedef fmi1_xml_integer_typedef_t fmi1_import_integer_typedef_t;
typedef fmi1_xml_enumeration_typedef_t fmi1_import_enumeration_typedef_t;
typedef fmi1_xml_variable_typedef_t fmi1_import_variable_typedef_t;

typedef fmi1_xml_type_definitions_t fmi1_import_type_definitions_t;
/* @} */

/* \defgroup Scalar Variable types */
/* @{ */
/* General variable type is convenien to unify all the variable list operations */
typedef fmi1_xml_variable_t fmi1_import_variable_t;
typedef struct fmi1_import_variable_list_t fmi1_import_variable_list_t;
/* Typed variables are needed to support specific attributes */
typedef fmi1_xml_real_variable_t fmi1_import_real_variable_t;
typedef fmi1_xml_integer_variable_t fmi1_import_integer_variable_t;
typedef fmi1_xml_string_variable_t fmi1_import_string_variable_t;
typedef fmi1_xml_enum_variable_t fmi1_import_enum_variable_t;
typedef fmi1_xml_bool_variable_t fmi1_import_bool_variable_t;
/* @} */

/* \defgroup Structures encapsulating unit information */
/* @{ */
typedef fmi1_xml_unit_t fmi1_import_unit_t;
typedef fmi1_xml_display_unit_t fmi1_import_display_unit_t;
typedef fmi1_xml_unit_definitions_t fmi1_import_unit_definitions_t;
/* @} */

/* \defgroup FMU capabilities flags */
/* @{ */
typedef fmi1_xml_capabilities_t fmi1_import_capabilities_t;
/* @} */

/* 
   \brief Create fmi1_import_t structure and parse the XML file.

    @param context A context data strucutre is used to propagate the callbacks for memory handling and logging.
    @param dirPath A directory name (full path) of a directory where the FMU was unzipped.
    @return The new structure if parsing was successfull. 0-pointer is returned on error.
*/
fmi1_import_t* fmi1_import_parse_xml( fmi_import_context_t* context, const char* dirPath);

/* Error handling:
*  Many functions in the library return pointers to struct. An error is indicated by returning NULL/0-pointer.
*  If error is returned than fmiGetLastError() functions can be used to retrieve the error message.
*  If logging callbacks were specified then the same information is reported via logger.
*  Memory for the error string is allocated and deallocated in the module.
*  Client code should not store the pointer to the string since it can become invalid.
*    @param fmu A model description object as returned by fmi1_import_allocate_model_description.
*    @return NULL-terminated string with an error message.
*/
const char* fmi1_import_get_last_error(fmi1_import_t* fmu);

/* 
fmiClearLastError clears the error message and returns 0 if further processing is possible. If it returns 1 then the 
error was not recoverable. The fmu object should then be freed and recreated.
*/
int fmi1_import_clear_last_error(fmi1_import_t* fmu);

/* Release the memory allocated
@param An fmu object as returned by fmi1_import_parse_xml.
*/
void fmi1_import_free(fmi1_import_t*);

/* \defgroup General information
 * \brief Functions for retrieving general model information. Memory for the strings is allocated and deallocated in the module.
 *       All the functions take a model description object as returned by fmi1_import_allocate_model_description as parameter.
 * @{
*/
const char* fmi1_import_get_model_name(fmi1_import_t* fmu);

const char* fmi1_import_get_model_identifier(fmi1_import_t* fmu);

const char* fmi1_import_get_GUID(fmi1_import_t* fmu);

const char* fmi1_import_get_description(fmi1_import_t* fmu);

const char* fmi1_import_get_author(fmi1_import_t* fmu);

const char* fmi1_import_get_model_version(fmi1_import_t* fmu);
const char* fmi1_import_get_model_standard_version(fmi1_import_t* fmu);
const char* fmi1_import_get_generation_tool(fmi1_import_t* fmu);
const char* fmi1_import_get_generation_date_and_time(fmi1_import_t* fmu);

fmi1_variable_naming_convension_enu_t fmi1_import_get_naming_convention(fmi1_import_t* fmu);

unsigned int fmi1_import_get_number_of_continuous_states(fmi1_import_t* fmu);

unsigned int fmi1_import_get_number_of_event_indicators(fmi1_import_t* fmu);

double fmi1_import_get_default_experiment_start(fmi1_import_t* fmu);

void fmi1_import_set_default_experiment_start(fmi1_import_t* fmu, double);

double fmi1_import_get_default_experiment_stop(fmi1_import_t* fmu);

void fmi1_import_set_default_experiment_stop(fmi1_import_t* fmu, double);

double fmi1_import_get_default_experiment_tolerance(fmi1_import_t* fmu);

void fmi1_import_set_default_experiment_tolerance(fmi1_import_t* fmu, double);

fmi1_fmu_kind_enu_t fmi1_import_get_fmu_kind(fmi1_import_t* fmu);

fmi1_import_capabilities_t* fmi1_import_get_capabilities(fmi1_import_t* fmu);

/* @} */
#include <Common/fmi_import_util.h>
/* #include "fmi1_import_type.h"
#include "fmi1_import_unit.h"
#include "fmi1_import_variable.h"
#include "fmi1_import_variable_list.h"
#include "fmi1_import_vendor_annotations.h"
#include "fmi1_import_capabilities.h"
#include "fmi1_import_cosim.h" */
#ifdef __cplusplus
}
#endif

#endif
