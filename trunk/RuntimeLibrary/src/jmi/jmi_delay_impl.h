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

/** \file jmi_delay_impl.h
 *  \brief Delay simulation private include file.
 */

#ifndef _JMI_DELAY_IMPL_H
#define _JMI_DELAY_IMPL_H
 
#include "jmi_types.h"
#include "jmi_delay.h"

#define JMI_DELAY_MAX_INTERPOLATION_POINTS 2 /* Linear interpolation */

typedef struct {
    jmi_real_t t; /**< \brief Increases between points, except at events, where it remains the same. There may never be two events in a row without an event-free interval in between. */
    int segment;  /**< \brief Index of the segment this sample belongs to. Increases by one accross events. Indexes into the events buffer. */
    jmi_real_t y;
} jmi_delay_point_t;

/** \brief Represents the history of a signal. */
typedef struct {
    int capacity;    /**< \brief Number of allocated points in buf. Must be a power of two! This simplifies ring buffer management a lot. */
    int size;        /**< \brief Number of used points in buf. */
    int head_index;  /**< \brief Logical index associated with the head position. */
    jmi_delay_point_t *buf; /**< \brief Buffer of history points. */

    int event_capacity; /**< \brief Number of allocated points in event_buf. Must be a power of two! This simplifies ring buffer management a lot. */
    int *event_buf; /**< brief Indices to the left sample of each event. */

    jmi_real_t max_delay;   /**< \brief Maximum delay relative to the last recorded sample that the buffer will be queried for. */
} jmi_delaybuffer_t;

/** \brief Represents the current position in a `jmi_delaybuffer_t`, including state needed to trigger events. */
typedef struct {
    int curr_interval;        /**< \brief Index of the left end point of the current interval. */
} jmi_delay_position_t;

/** \brief Represents a single delay block (free or fixed delay). Wraps a delaybuffer_t with the history and adds additional state. */
struct jmi_delay_t {
    jmi_delaybuffer_t buffer;       /**< \brief The actual history. */
    jmi_boolean fixed;              /**< \brief True if this is a fixed delay. */
    jmi_boolean no_event;           /**< \brief True if this delay should not generate any events - it will cross events in the history anyway. */
    jmi_delay_position_t position;  /**< \brief Current buffer position, including state needed to trigger events. */
};

/** \brief Represents a single spatialDistribution block. Wraps a delaybuffer_t with the contents and adds additional state. */
struct jmi_spatialdist_t {
    jmi_delaybuffer_t buffer;        /**< \brief The actual history. */
    jmi_boolean no_event;            /**< \brief True if this spatialDistribution should not generate any events - it will cross events in the history anyway. */
    jmi_delay_position_t lposition;  /**< \brief Current buffer position for the left endpoint, including state needed to trigger events. */
    jmi_delay_position_t rposition;  /**< \brief Current buffer position for the right endpoint, including state needed to trigger events. */
    jmi_real_t last_x;               /**< \brief Last recorded x position. */
};


#endif