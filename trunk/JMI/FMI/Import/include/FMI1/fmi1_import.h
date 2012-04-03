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

/**
	* \mainpage JModelica Runtime Library: FMI import
	*
	* \version     0.1a
	* \date April  2012
	* \section FMI Import library
	The library is intended as a foundation for applications interfacing FMUs (Functional Mockup Units)
	that follow FMI Standard. See <http://functional-mockup-interface.org/> 
	* \section License	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

	* \copyright (C) 2012 Modelon AB
*/

/** \file fmi1_import.h
*  \brief Public interface to the FMI import C-library.
*/

#ifndef FMI1_IMPORT_H_
#define FMI1_IMPORT_H_

#include <stddef.h>
#include <jm_callbacks.h>
#include <Common/fmi_import_util.h>
#include <Common/fmi_import_context.h>
#include <FMI1/fmi1_xml_model_description.h>

#include <FMI1/fmi1_types.h>
#include <FMI1/fmi1_functions.h>
#include <FMI1/fmi1_enums.h>
#include <FMI1/fmi1_capi.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \addtogroup  fmi1_import FMI 1.0 import interface
 *  All the structures used in the interfaces are intended to
 *  be treated as opaque objects by the client code.
 @{ 
 */
/** 
\name Vendor annotation supporting structures
*/
/**@{ */
	/** Opaque list of vendor annotations. */
typedef fmi1_xml_vendor_list_t fmi1_import_vendor_list_t;
	/** Opaque vendor object. */
typedef fmi1_xml_vendor_t fmi1_import_vendor_t;
	/** Opaque annotation object. */
typedef fmi1_xml_annotation_t fmi1_import_annotation_t;
/**@} */

/**@name   Type definitions supporting structures*/
/**@{ */
/** Opaque type definition object. */
typedef fmi1_xml_real_typedef_t fmi1_import_real_typedef_t;
/** Opaque integer type definition object. */
typedef fmi1_xml_integer_typedef_t fmi1_import_integer_typedef_t;
/** Opaque enumeration type definition object. */
typedef fmi1_xml_enumeration_typedef_t fmi1_import_enumeration_typedef_t;
/** Opaque general variable type definition object. */
typedef fmi1_xml_variable_typedef_t fmi1_import_variable_typedef_t;
/** Opaque list of the type definitions in the model */
typedef fmi1_xml_type_definitions_t fmi1_import_type_definitions_t;
/**@} */

/**@name Scalar variable types */
/**Typed variables are needed to support specific attributes */
/**@{ */
/**General variable type is convenien to unify all the variable list operations */
typedef fmi1_xml_variable_t fmi1_import_variable_t;
/** Opaque real variable */
typedef fmi1_xml_real_variable_t fmi1_import_real_variable_t;
/** Opaque integer variable */
typedef fmi1_xml_integer_variable_t fmi1_import_integer_variable_t;
/** Opaque string variable */
typedef fmi1_xml_string_variable_t fmi1_import_string_variable_t;
/** Opaque enumeration variable */
typedef fmi1_xml_enum_variable_t fmi1_import_enum_variable_t;
/** Opaque boolean variable */
typedef fmi1_xml_bool_variable_t fmi1_import_bool_variable_t;
/** List of variables */
typedef struct fmi1_import_variable_list_t fmi1_import_variable_list_t;
/**@} */

/**\name Structures encapsulating unit information */
/**@{ */
/** A variable unit defined with a unit defition */
typedef fmi1_xml_unit_t fmi1_import_unit_t;
/** A display unit */
typedef fmi1_xml_display_unit_t fmi1_import_display_unit_t;
/** The list of all the unit definitions in the model */
typedef fmi1_xml_unit_definitions_t fmi1_import_unit_definitions_t;
/**@} */

/**\name FMU capabilities flags */
/**@{ */
/** A container for all the capability flags */
typedef fmi1_xml_capabilities_t fmi1_import_capabilities_t;
/** @} */
/**	\addtogroup fmi1_import_init Constuction, destruction and error handling
	\addtogroup fmi1_import_gen General information retrieval
	\addtogroup fmi1_import_capi Interface to the standard FMI 1.0 "C" API
	*/
 /** @} */
 /** @} */

/** \addtogroup fmi1_import_init Constuction, destruction and error handling
@{
*/
/**
   \brief Create ::fmi1_import_t structure and parse the XML file.

    @param context A context data strucutre is used to propagate the callbacks for memory handling and logging.
    @param dirPath A directory name (full path) of a directory where the FMU was unzipped.
    @return The new structure if parsing was successfull. 0-pointer is returned on error.
*/
fmi1_import_t* fmi1_import_parse_xml( fmi_import_context_t* context, const char* dirPath);

/**Error handling:
*  Many functions in the library return pointers to struct. An error is indicated by returning NULL/0-pointer.
*  If error is returned than fmi_import_get_last_error() functions can be used to retrieve the error message.
*  If logging callbacks were specified then the same information is reported via logger.
*  Memory for the error string is allocated and deallocated in the module.
*  Client code should not store the pointer to the string since it can become invalid.
*    @param fmu An FMU object as returned by fmi1_import_parse_xml().
*    @return NULL-terminated string with an error message.
*/
const char* fmi1_import_get_last_error(fmi1_import_t* fmu);

/**
Clear the error message.
* @param fmu An FMU object as returned by fmi1_import_parse_xml().
* @return 0 if further processing is possible. If it returns 1 then the 
*	error was not recoverable. The fmu object should then be freed and recreated.
*/
int fmi1_import_clear_last_error(fmi1_import_t* fmu);

/**Release the memory allocated
@param fmu An fmu object as returned by fmi1_import_parse_xml().
*/
void fmi1_import_free(fmi1_import_t* fmu);
/** @}
\addtogroup fmi1_import_gen
 * \brief Functions for retrieving general model information. Memory for the strings is allocated and deallocated in the module.
 *   All the functions take an FMU object as returned by fmi1_import_parse_xml() as a parameter. 
 *   The information is retrieved from the XML file.
 * @{
*/
/** Get model name. */
const char* fmi1_import_get_model_name(fmi1_import_t* fmu);

/** Get model identifier. */
const char* fmi1_import_get_model_identifier(fmi1_import_t* fmu);

/** Get FMU GUID. */
const char* fmi1_import_get_GUID(fmi1_import_t* fmu);

/** Get FMU description. */
const char* fmi1_import_get_description(fmi1_import_t* fmu);

/** Get FMU author. */
const char* fmi1_import_get_author(fmi1_import_t* fmu);

/** Get FMU version. */
const char* fmi1_import_get_model_version(fmi1_import_t* fmu);

/** Get FMI standard version (always 1.0). */
const char* fmi1_import_get_model_standard_version(fmi1_import_t* fmu);

/** Get FMU generation tool. */
const char* fmi1_import_get_generation_tool(fmi1_import_t* fmu);

/** Get FMU generation date and time. */
const char* fmi1_import_get_generation_date_and_time(fmi1_import_t* fmu);

/** Get variable naming convention used. */
fmi1_variable_naming_convension_enu_t fmi1_import_get_naming_convention(fmi1_import_t* fmu);

/** Get the number of contnuous states. */
unsigned int fmi1_import_get_number_of_continuous_states(fmi1_import_t* fmu);

/** Get the number of event indicators. */
unsigned int fmi1_import_get_number_of_event_indicators(fmi1_import_t* fmu);

/** Get the start time for default experiment  as specified in the XML file. */
double fmi1_import_get_default_experiment_start(fmi1_import_t* fmu);

/** Get the stop time for default experiment  as specified in the XML file. */
double fmi1_import_get_default_experiment_stop(fmi1_import_t* fmu);

/** Get the tolerance default experiment as specified in the XML file. */
double fmi1_import_get_default_experiment_tolerance(fmi1_import_t* fmu);

/** Get the type of the FMU (model exchange or co-simulation) */
fmi1_fmu_kind_enu_t fmi1_import_get_fmu_kind(fmi1_import_t* fmu);

/** Get the structure with capability flags.
	@return A pointer to the fmi1_import_capabilities_t allocated within the library. 
			Note that for model exchange FMUs the values of all the flags are always default.
*/

fmi1_import_capabilities_t* fmi1_import_get_capabilities(fmi1_import_t* fmu);

/**@} */

/**
 * \addtogroup fmi1_import_capi
 * @{
 */
/** \brief Free a C-API struct. All memory allocated since the struct was created is freed.
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml().
 */
void fmi1_import_destroy_dllfmu(fmi1_import_t* fmu);

/**
 * \brief Create a C-API struct. The C-API struct is a placeholder for the FMI DLL functions.
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml().
 * @param callBackFunctions Callback functions used by the FMI functions internally.
 * @param standard FMI standard that the function should load.
 * @param unzipped_folder FMI standard that the function should load.
 * @param unzipped_folder Folder in which the unziped FMU files are located.
 * @return Error status. If the function returns with an error, it is not allowed to call any of the other C-API functions.
 */
jm_status_enu_t fmi1_import_create_dllfmu(fmi1_import_t* fmu, fmi1_callback_functions_t callBackFunctions, fmi1_fmu_kind_enu_t standard, const char* unzipped_folder);

/**
 * \brief Loads the FMI functions from the shared library. The shared library must be loaded before this function can be called, see fmi1_import_load_dll.
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml().
 * @return Error status. If the function returns with an error, no other C-API functions than fmi1_import_free_dll and fmi1_import_destroy_dllfmu are allowed to be called.
 */
jm_status_enu_t fmi1_import_load_fcn(fmi1_import_t* fmu);

/**
 * \brief Loads the FMU's shared library. The shared library functions are not loaded in this call, see fmi1_import_load_fcn().
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml().
 * @return Error status. If the function returns with an error, no other C-API functions than fmi1_import_destroy_dllfmu are allowed to be called.
 */
jm_status_enu_t fmi1_import_load_dll(fmi1_import_t* fmu);

/**
 * \brief Frees the handle to the FMU´s shared library. After this function returnes, no other C-API functions than fmi1_import_destroy_dllfmu() and fmi1_import_load_dll() are allowed to be called.
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMU´s shared library, see fmi1_import_load_dll().
 * @return Error status.
 */
jm_status_enu_t fmi1_import_free_dll(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiGetVersion() 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return FMI version.
 */
const char* fmi1_import_get_version(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiSetDebugLogging(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param loggingOn Enable or disable the debug logger.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_debug_logging(fmi1_import_t* fmu, fmi1_boolean_t loggingOn);

/**
 * \brief Wrapper for the FMI function fmiSetReal(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_real(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_real_t    value[]);

/**
 * \brief Wrapper for the FMI function fmiSetInteger(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_integer(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t value[]);

/**
 * \brief Wrapper for the FMI function fmiSetBoolean(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_boolean(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_boolean_t value[]);

/**
 * \brief Wrapper for the FMI function fmiSetString(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_string(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_string_t  value[]);


/**
 * \brief Wrapper for the FMI function fmiGetReal(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value (Output)Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_real(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_real_t    value[]);

/**
 * \brief Wrapper for the FMI function fmiGetInteger(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value (Output)Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_integer(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_integer_t value[]);

/**
 * \brief Wrapper for the FMI function fmiGetBoolean(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value (Output)Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_boolean(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_boolean_t value[]);

/**
 * \brief Wrapper for the FMI function fmiGetString(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param value (Output)Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_string(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_string_t  value[]);

/**
 * \brief Wrapper for the FMI function fmiGetModelTypesPlatform(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return The platform the FMU was compiled for.
 */
const char* fmi1_import_get_model_types_platform(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiInstantiateModel(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param instanceName The name of the instance.
 * @param GUID The GUID identifier.
 * @param loggingOn Enable or disable the debug logger.
 * @return Error status. Returnes jm_status_error if fmiInstantiateModel returned NULL, otherwise jm_status_success.
 */
jm_status_enu_t fmi1_import_instantiate_model(fmi1_import_t* fmu, fmi1_string_t instanceName, fmi1_string_t GUID, fmi1_boolean_t loggingOn);

/**
 * \brief Wrapper for the FMI function fmiFreeModelInstance(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 */
void fmi1_import_free_model_instance(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiSetTime(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param time Set the current time.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_time(fmi1_import_t* fmu, fmi1_real_t time);

/**
 * \brief Wrapper for the FMI function fmiSetContinuousStates(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param x Array of state values.
 * @param nx Number of states.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_continuous_states(fmi1_import_t* fmu, const fmi1_real_t x[], size_t nx);

/**
 * \brief Wrapper for the FMI function fmiCompletedIntegratorStep(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param callEventUpdate (Output) Call fmiEventUpdate indicator.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_completed_integrator_step(fmi1_import_t* fmu, fmi1_boolean_t* callEventUpdate);

/**
 * \brief Wrapper for the FMI function fmiInitialize(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param toleranceControlled Enable or disable the use of relativeTolerance in the FMU.
 * @param relativeTolerance A relative tolerance used in the FMU.
 * @param eventInfo (Output) fmiEventInfo struct.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_initialize(fmi1_import_t* fmu, fmi1_boolean_t toleranceControlled, fmi1_real_t relativeTolerance, fmi1_event_info_t* eventInfo);

/**
 * \brief Wrapper for the FMI function fmiGetDerivatives(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param derivatives (Output) Array of the derivatives.
 * @param nx Number of derivatives.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_derivatives(fmi1_import_t* fmu, fmi1_real_t derivatives[], size_t nx);

/**
 * \brief Wrapper for the FMI function fmiGetEventIndicators(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param eventIndicators (Output) The event indicators.
 * @param ni Number of event indicators.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_event_indicators(fmi1_import_t* fmu, fmi1_real_t eventIndicators[], size_t ni);

/**
 * \brief Wrapper for the FMI function fmiEventUpdate(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param intermediateResults Indicate whether or not the fmiEventUpdate shall return after every internal event interation.
 * @param eventInfo (Output) An fmiEventInfo struct.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_eventUpdate(fmi1_import_t* fmu, fmi1_boolean_t intermediateResults, fmi1_event_info_t* eventInfo);

/**
 * \brief Wrapper for the FMI function fmiGetContinuousStates(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param states (Output) Array of state values.
 * @param nx Number of states.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_continuous_states(fmi1_import_t* fmu, fmi1_real_t states[], size_t nx);

/**
 * \brief Wrapper for the FMI function fmiGetNominalContinuousStates(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param x_nominal (Output) The nominal values.
 * @param nx Number of nominal values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_nominal_continuous_states(fmi1_import_t* fmu, fmi1_real_t x_nominal[], size_t nx);

/**
 * \brief Wrapper for the FMI function fmiGetStateValueReferences(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vrx (Output) The value-references of the states.
 * @param nx Number of value-references.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_state_value_references(fmi1_import_t* fmu, fmi1_value_reference_t vrx[], size_t nx);

/**
 * \brief Wrapper for the FMI function fmiTerminate(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return FMI status.
 */
fmi1_status_t fmi1_import_terminate(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiGetTypesPlatform(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return The platform the FMU was compiled for.
 */
const char* fmi1_import_get_types_platform(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiInstantiateSlave(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param instanceName The name of the instance.
 * @param fmuGUID The GUID identifier.
 * @param fmuLocation Access path to the FMU archive.
 * @param mimeType MIME type.
 * @param timeout Communication timeout value in milli-seconds.
 * @param visible Indicates whether or not the simulator application window shoule be visible.
 * @param interactive Indicates whether the simulator application must be manually started by the user.
 * @param loggingOn Enable or disable the debug logger.
 * @return Error status. Returnes jm_status_error if fmiInstantiateSlave returned NULL, otherwise jm_status_success.
 */
jm_status_enu_t fmi1_import_instantiate_slave(fmi1_import_t* fmu, fmi1_string_t instanceName, fmi1_string_t fmuGUID, fmi1_string_t fmuLocation, fmi1_string_t mimeType,
																 fmi1_real_t timeout, fmi1_boolean_t visible, fmi1_boolean_t interactive, fmi1_boolean_t loggingOn);

/**
 * \brief Wrapper for the FMI function fmiInitializeSlave(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param tStart Start time of the simulation
 * @param StopTimeDefined Indicates whether or not the stop time is used.
 * @param tStop The stop time of the simulation.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_initialize_slave(fmi1_import_t* fmu, fmi1_real_t tStart, fmi1_boolean_t StopTimeDefined, fmi1_real_t tStop);

/**
 * \brief Wrapper for the FMI function fmiTerminateSlave(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return FMI status.
 */
fmi1_status_t fmi1_import_terminate_slave(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiResetSlave(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return FMI status.
 */
fmi1_status_t fmi1_import_reset_slave(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiFreeSlaveInstance(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 */
void fmi1_import_free_slave_instance(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiSetRealInputDerivatives(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param order	Array of derivative orders.
 * @param value Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_set_real_input_derivatives(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t order[], const  fmi1_real_t value[]);                                                  

/**
 * \brief Wrapper for the FMI function fmiGetOutputDerivatives(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param vr Array of value references.
 * @param nvr Number of array elements.
 * @param order	Array of derivative orders.
 * @param value (Output) Array of variable values.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_real_output_derivatives(fmi1_import_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t order[], fmi1_real_t value[]);                                              

/**
 * \brief Wrapper for the FMI function fmiCancelStep(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @return FMI status.
 */
fmi1_status_t fmi1_import_cancel_step(fmi1_import_t* fmu);

/**
 * \brief Wrapper for the FMI function fmiDoStep(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param currentCommunicationPoint Current communication point of the master.
 * @param communicationStepSize Communication step size.
 * @param newStep Indicates whether or not the last communication step was accepted by the master.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_do_step(fmi1_import_t* fmu, fmi1_real_t currentCommunicationPoint, fmi1_real_t communicationStepSize, fmi1_boolean_t newStep);

/**
 * \brief Wrapper for the FMI function fmiGetStatus(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param s Kind of status to return the value for.
 * @param value (Output) FMI status value.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_status(fmi1_import_t* fmu, const fmi1_status_kind_t s, fmi1_status_t*  value);

/**
 * \brief Wrapper for the FMI function fmiGetRealStatus(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param s Kind of status to return the value for.
 * @param value (Output) FMI real value.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_real_status(fmi1_import_t* fmu, const fmi1_status_kind_t s, fmi1_real_t*    value);

/**
 * \brief Wrapper for the FMI function fmiGetIntegerStatus(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn.
 * @param s Kind of status to return the value for.
 * @param value (Output) FMI integer value.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_integer_status(fmi1_import_t* fmu, const fmi1_status_kind_t s, fmi1_integer_t* value);

/**
 * \brief Wrapper for the FMI function fmiGetBooleanStatus(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn.
 * @param s Kind of status to return the value for.
 * @param value (Output) FMI boolean value.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_boolean_status(fmi1_import_t* fmu, const fmi1_status_kind_t s, fmi1_boolean_t* value);

/**
 * \brief Wrapper for the FMI function fmiGetStringStatus(...) 
 * 
 * @param fmu A model description object returned by fmi1_import_parse_xml() that has loaded the FMI functions, see fmi1_import_load_fcn().
 * @param s Kind of status to return the value for.
 * @param value (Output) FMI string value.
 * @return FMI status.
 */
fmi1_status_t fmi1_import_get_string_status(fmi1_import_t* fmu, const fmi1_status_kind_t s, fmi1_string_t*  value);

/**@} */

#ifdef __cplusplus
}
#endif
#include "fmi1_import_type.h"
#include "fmi1_import_unit.h"
#include "fmi1_import_variable.h"
#include "fmi1_import_vendor_annotations.h"
#include "fmi1_import_capabilities.h"
#include "fmi1_import_cosim.h"
#include "fmi1_import_variable_list.h"
#endif
