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

#ifndef fmi2_me_h
#define fmi2_me_h

#include "fmiFunctions.h"
#include "jmi_util.h"
#include "jmi_me.h"

/**
 * \brief Makes the simulation go into event mode.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi2_enter_event_mode(fmiComponent c);

/**
 * \brief Updates the FMU after an event. Does one event iteration.
 * 
 * @param c The FMU struct.
 * @param eventInfo (Output) An fmiEventInfo struct.
 * @return Error code.
 */
fmiStatus fmi2_new_discrete_state(fmiComponent  c,
                                  fmiEventInfo* fmiEventInfo);

/**
 * \brief Makes the simulation go into continuous time mode.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi2_enter_continuous_time_mode(fmiComponent c);

/**
 * \brief Checks for step-events, can flush old FMU states and can terminate the simulation.
 * 
 * @param c The FMU struct.
 * @param noSetFMUStatePriorToCurrentPoint A fmiBoolean, can be used to 
 *                                         flush earlier saved FMU states.
 * @param enterEventMode (Output) A fmiBoolean.
 * @param terminateSimulation (Output) A fmiBoolean.
 * @return Error code.
 */
fmiStatus fmi2_completed_integrator_step(fmiComponent c,
                                         fmiBoolean   noSetFMUStatePriorToCurrentPoint, 
                                         fmiBoolean*  enterEventMode, 
                                         fmiBoolean*  terminateSimulation);

/**
 * \brief Set the current time.
 * 
 * @param c The FMU struct.
 * @param time The current time.
 * @return Error code.
 */
fmiStatus fmi2_set_time(fmiComponent c, fmiReal time);

/**
 * \brief Set the current states.
 * 
 * @param c The FMU struct.
 * @param x Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmiStatus fmi2_set_continuous_states(fmiComponent c, const fmiReal x[],
                                     size_t nx);

/**
 * \brief Calculates the derivatives.
 * 
 * @param c The FMU struct.
 * @param derivatives (Output) Array of the derivatives.
 * @param nx Number of derivatives.
 * @return Error code.
 */
fmiStatus fmi2_get_derivatives(fmiComponent c, fmiReal derivatives[], size_t nx);

/**
 * \brief Get the event indicators (for state-events)
 * 
 * @param c The FMU struct.
 * @param eventIndicators (Output) The event indicators.
 * @param ni Number of event indicators.
 * @return Error code.
 */
fmiStatus fmi2_get_event_indicators(fmiComponent c, 
                                    fmiReal eventIndicators[], size_t ni);
/**
 * \brief Get the current states.
 * 
 * @param c The FMU struct.
 * @param x (Output) Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmiStatus fmi2_get_continuous_states(fmiComponent c, fmiReal x[], size_t nx);

/**
 * \brief Get the nominal values of the states.
 * 
 * @param c The FMU struct.
 * @param x_nominal (Output) The nominal values.
 * @param nx Number of nominal values.
 * @return Error code.
 */
fmiStatus fmi2_get_nominals_of_continuous_states(fmiComponent c, 
                                                 fmiReal x_nominal[], 
                                                 size_t nx);

#endif
