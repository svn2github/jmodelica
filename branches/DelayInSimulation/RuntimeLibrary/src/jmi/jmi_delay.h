 /*
    Copyright (C) 2014 Modelon AB

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

/** \file jmi_delay.h
 *  \brief Interface to functionality for simulation of delays.
 */

#ifndef _JMI_DELAY_H
#define _JMI_DELAY_H

#include "jmi_types.h"


/** \brief Initialize the delay block with the given index and allocate memory for its buffers */
int jmi_delay_new(jmi_t *jmi, int index);
/** \brief Free the memory for the buffers of the delay block with the given index */
int jmi_delay_delete(jmi_t *jmi, int index);

/** \brief Initialize the delay block with given index and provide a first data point. The time variable in the jmi struct should already be initialized. */
int jmi_delay_init(jmi_t *jmi, int index, jmi_boolean fixed, jmi_boolean no_event, jmi_real_t max_delay, jmi_real_t y0);

/** \brief Evaluate the output jmi_t *jmi, int index, given its current input value and delay time */
jmi_real_t jmi_delay_evaluate(jmi_t *jmi, int index, jmi_real_t y_in, jmi_real_t delay_time);

/** \brief Record a sample into the delay buffer. Call at each completed integrator step. Time is taken from the jmi struct. */
int jmi_delay_record_sample(jmi_t *jmi, int index, jmi_real_t y_in);

/** \brief While in event mode for the delays, calls to `jmi_delay_record_sample` will be taken as event samples */
int jmi_delay_set_event_mode(jmi_t *jmi, jmi_boolean in_event);

/** \brief Return the next time event caused by a delay block, or JMI_INF if there is no next time event */
jmi_real_t jmi_delay_next_time_event(jmi_t *jmi);

/** \brief Return the first (of two) event indicators >= 0 for a variable delay block in *event_indicator. Return -1 on failure, 0 otherwise. */
int jmi_delay_first_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator);
/** \brief Return the second (of two) event indicators >= 0 for a variable delay block in *event_indicator. Return -1 on failure, 0 otherwise. */
int jmi_delay_second_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator);


#endif 
