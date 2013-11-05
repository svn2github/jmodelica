/*
    Copyright (C) 2013 Modelon AB

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

#ifndef fmi2_cs_h
#define fmi2_cs_h

#include "fmiFunctions.h"
#include "fmi2_me.h"

typedef struct fmi2_cs_t fmi2_cs_t;  /**< \brief Forward declaration of struct. */

struct fmi2_cs_t {
    fmi2_me_t          fmi2_me;          /**< \brief Must be the first one in this struct so that a fmi2_cs_t pointer can be used in place of a fmi2_me_t pointer. */
    jmi_ode_problem_t* ode_problem;      /**< \brief A jmi ode problem pointer. */
};

fmiStatus fmi2_cs_instantiate(fmiComponent c,
                              fmiString    instanceName,
                              fmiType      fmuType, 
                              fmiString    fmuGUID, 
                              fmiString    fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn);

/**
 * \brief Sets the derivative of the outputs
 * 
 * @param c The FMU struct.
 * @param vr The value reference(s)
 * @param nvr The length of vr
 * @param order The derivative order
 * @param value The value(s) to set.
 * @return Error code.
 */
fmiStatus fmi2_set_real_input_derivatives(fmiComponent c, 
                                          const fmiValueReference vr[],
                                          size_t nvr, const fmiInteger order[],
                                          const fmiReal value[]);

/**
 * \brief Gets the derivative of the outputs
 * 
 * @param c The FMU struct.
 * @param vr The value reference(s)
 * @param nvr The length of vr
 * @param order The order of the output derivative
 * @param value (Output) The value(s) to get.
 * @return Error code.
 */
fmiStatus fmi2_get_real_output_derivatives(fmiComponent c,
                                           const fmiValueReference vr[],
                                           size_t nvr, const fmiInteger order[],
                                           fmiReal value[]);

/**
 * \brief Performs a time-step.
 * 
 * @param c The FMU struct.
 * @param currentCommunicationPoint The current communication point.
 * @param communicationStepSize The length of the step to perform.
 * @param noSetFMUStatePriorToCurrentPoint A fmiBoolean, can be used to 
 *                                         flush earlier saved FMU states.
 * @return Error code.
 */
fmiStatus fmi2_do_step(fmiComponent c, fmiReal currentCommunicationPoint,
                       fmiReal    communicationStepSize,
                       fmiBoolean noSetFMUStatePriorToCurrentPoint);

/**
 * \brief Can be called in order to stop the current asynchronous execution.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi2_cancel_step(fmiComponent c);

/**
 * \brief Retrieve status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi2_get_status(fmiComponent c, const fmiStatusKind s,
                          fmiStatus* value);

/**
 * \brief Retrieve (real) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi2_get_real_status(fmiComponent c, const fmiStatusKind s,
                               fmiReal* value);
                               
/**
 * \brief Retrieve (integer) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi2_get_integer_status(fmiComponent c, const fmiStatusKind s,
                                  fmiInteger* values);

/**
 * \brief Retrieve (boolean) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi2_get_boolean_status(fmiComponent c, const fmiStatusKind s,
                                  fmiBoolean* value);

/**
 * \brief Retrieve (string) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi2_get_string_status(fmiComponent c, const fmiStatusKind s,
                                 fmiString* value);

#endif
