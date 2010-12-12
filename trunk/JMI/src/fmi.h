/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

/** \file fmi.h
 *  \brief The public FMI model interface.
 **/

#ifndef fmi_h
#define fmi_h

#include "fmiModelFunctions.h"
#include "jmi.h"

/**
 * \defgroup fmi_public Public functions of the Functional Mock-up Interface.
 *
 * \brief Documentation of the public functions and data structures
 * of the Functional Mock-up Interface.
 */

/* @{ */

#ifdef __cplusplus
extern "C" {
#endif

/* Type definitions */
typedef struct {
    fmiString fmi_instance_name;
    fmiString fmi_GUID;
    fmiCallbackFunctions fmi_functions;
    fmiBoolean fmi_logging_on;
    fmiReal fmi_newton_tolerance;
    fmiReal fmi_epsilon;
    jmi_t* jmi;
} fmi_t;

/**
 * \defgroup fmi_init Creation, initialization and destruction.
 * 
 * \brief Definitions of how an FMU are created, initialized and terminated.
 */

/* @{ */

/**
 * \brief Instantiates the FMU.
 * 
 * @param instanceName The name of the instance.
 * @param GUID The GUID identifier.
 * @param functions Callback functions for logging, allocation and deallocation.
 * @param loggingOn Turn of or on logging, fmiBoolean.
 * @return An instance of a model.
 */
fmiComponent fmi_instantiate_model(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn);

/**
 * \brief Initialize the FMU.
 * 
 * @param c The FMU struct.
 * @param toleranceControlled A fmiBoolean.
 * @param relativeTolerance A fmiReal.
 * @param eventInfo (Output) fmiEventInfo struct.
 * @return Error code.
 */
fmiStatus fmi_initialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);

/**
 * \brief Dellocates all memory since fmi_initialize.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi_terminate(fmiComponent c);

/**
 * \brief Dispose of the model instance.
 * 
 * @param c The FMU struct.
 */
void fmi_free_model_instance(fmiComponent c);

/* @} */

/**
 * \defgroup fmi_ode ODE interface.
 * 
 * \brief Access to the ODE representation.
 */

/* @{ */

/**
 * \brief Set the current time.
 * 
 * @param c The FMU struct.
 * @param time The current time.
 * @return Error code.
 */
fmiStatus fmi_set_time(fmiComponent c, fmiReal time);

/**
 * \brief Set the current states.
 * 
 * @param c The FMU struct.
 * @param x Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmiStatus fmi_set_continuous_states(fmiComponent c, const fmiReal x[], size_t nx);

/**
 * \brief Calculates the derivatives.
 * 
 * @param c The FMU struct.
 * @param derivatives (Output) Array of the derivatives.
 * @param nx Number of derivatives.
 * @return Error code.
 */
fmiStatus fmi_get_derivatives(fmiComponent c, fmiReal derivatives[] , size_t nx);

/**
 * \brief Get the current states.
 * 
 * @param c The FMU struct.
 * @param states (Output) Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmiStatus fmi_get_continuous_states(fmiComponent c, fmiReal states[], size_t nx);

/**
 * \brief Get the nominal values of the states.
 * 
 * @param c The FMU struct.
 * @param x_nominal (Output) The nominal values.
 * @param nx Number of nominal values.
 * @return Error code.
 */
fmiStatus fmi_get_nominal_continuous_states(fmiComponent c, fmiReal x_nominal[], size_t nx);

/**
 * \brief Get the value-references of the states.
 * 
 * @param c The FMU struct.
 * @param vrx (Output) The value-references of the states.
 * @param nx Number of value-references.
 * @return Error code.
 */
fmiStatus fmi_get_state_value_references(fmiComponent c, fmiValueReference vrx[], size_t nx);


/* @} */

/**
 * \defgroup fmi_event Event handling.
 * 
 * \brief Access to the event handling and event control.
 */

/* @{ */

/**
 * \brief Checks for step-events.
 * 
 * @param c The FMU struct.
 * @param callEventUpdate (Output) A fmiBoolean.
 * @return Error code.
 */
fmiStatus fmi_completed_integrator_step(fmiComponent c, fmiBoolean* callEventUpdate);

/**
 * \brief Get the event indicators (for state-events)
 * 
 * @param c The FMU struct.
 * @param eventIndicators (Output) The event indicators.
 * @param ni Number of event indicators.
 * @return Error code.
 */
fmiStatus fmi_get_event_indicators(fmiComponent c, fmiReal eventIndicators[], size_t ni);

/**
 * \brief Updates the FMU after an event.
 * 
 * @param c The FMU struct.
 * @param intermediateResults A fmiBoolean.
 * @param eventInfo (Output) An fmiEventInfo struct.
 * @return Error code.
 */
fmiStatus fmi_event_update(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);

/* @} */

/**
 * \defgroup fmi_access Access variable values.
 *
 * \brief Values are accessed using the value-reference as key through variable type
 * functions get and set.
 */

/* @{ */

/**
 * \brief Set Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]);

/**
 * \brief Set Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);

/**
 * \brief Set Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);

/**
 * \brief Set String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]);

/**
 * \brief Get Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]);

/**
 * \brief Get Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);

/**
 * \brief Get Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);

/**
 * \brief Get String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

/**
 * \brief Get a pointer to the internal jmi_t struct.
 *
 * @param c The FMU struct.
 * @return A pointer to the internal jmi_t struct.
 */
jmi_t* fmi_get_jmi_t(fmiComponent c);

/* @} */

/**
 * \defgroup fmi_debug Debugging.
 * 
 * \brief Methods useful for debugging purposes.
 */

/* @{ */

/**
 * \brief Returns the compatible platforms.
 *
 * This methods returns the set of compatible platforms for which the FMU was
 * compiled for.
 * 
 * @return The set of compatible platforms.
 */
const char* fmi_get_model_types_platform();

/**
 * \brief Returns the version of the header file.
 * 
 * @return The version of fmiModelFunctions.h.
 */
const char* fmi_get_version();

/**
 * \brief Turns on or off debugging.
 * 
 * @param c The FMU struct.
 * @param loggingOn A fmiBoolean.
 * @return Error code.
 */
fmiStatus fmi_set_debug_logging(fmiComponent c, fmiBoolean loggingOn);

/* @} */

/* @} */

#ifdef __cplusplus
}
#endif
#endif
