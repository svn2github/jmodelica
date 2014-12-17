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


/*
 * jmi_delay.c: Implementation of delay simulation functionality.
 */

#include <stdlib.h>
#include <string.h>

#include "jmi.h"
#include "jmi_util.h"
#include "jmi_delay.h"
#include "jmi_delay_impl.h"


#define BUFFER_INITIAL_CAPACITY 256



 /* Forward declaration of jmi_delaybuffer_t functions */

/** \brief Construct a new delay buffer and allocate space for the buffer */
static int jmi_delaybuffer_new(jmi_t *jmi, jmi_delaybuffer_t *buffer);
/** \brief Deallocate the internal buffer */
static int jmi_delaybuffer_delete(jmi_delaybuffer_t *buffer);

/** \brief (Re-)initialize a delay buffer */
static int jmi_delaybuffer_init(jmi_delaybuffer_t *buffer, jmi_real_t max_delay);

/** \brief Evaluate the buffer at time `tr`. Don't step the (inout) argument `position` over events unless `at_event`. Also provide one last data point. */ 
static jmi_real_t jmi_delaybuffer_evaluate(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                                           jmi_real_t tr, jmi_delay_position_t *position, jmi_real_t t_curr, jmi_real_t y_curr);
/** \brief Evaluate the buffer at time `tr`. Don't step the (inout) argument `position` over events unless `at_event`. Also provide one first data point. */ 
static jmi_real_t jmi_delaybuffer_evaluate_left(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                                                jmi_real_t tr, jmi_delay_position_t *position, jmi_real_t t_curr, jmi_real_t y_curr);

/** \brief Record a sample at the right end, discarding samples on the left that are not needed to interpolate with up to `max_delay` delay. */
static int jmi_delaybuffer_record_sample(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_event);
/** \brief Record a sample at the left end, discarding samples on the right that are not needed to interpolate with up to `max_delay` (negative) delay. */
static int jmi_delaybuffer_record_sample_left(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_event);

/** \brief Get the next event time stored in the buffer, relative to `position`, or `JMI_INF` if there is none */
static jmi_real_t jmi_delaybuffer_next_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position);
/** \brief Get the previous event time stored in the buffer, relative to `position`, or `-JMI_INF` if there is none */
static jmi_real_t jmi_delaybuffer_prev_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position);

/** \brief Update `position` to the interval that contains time `tr`, stepping over events if needed */
static int jmi_delaybuffer_update_position_at_event(jmi_delaybuffer_t *buffer, jmi_real_t tr, jmi_delay_position_t *position);

/** \brief Truncate the buffer to cover only `t >= t_limit`. The inout argument `lposition` should point to the interval for `t_limit`. */ 
static int jmi_delaybuffer_truncate_left( jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t_limit, jmi_delay_position_t *lposition);
/** \brief Truncate the buffer to cover only `t <= t_limit`. The inout argument `rposition` should point to the interval for `t_limit`. */ 
static int jmi_delaybuffer_truncate_right(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t_limit, jmi_delay_position_t *rposition);

/** \brief Initialize `position` to point at the first position in a newly initialized delay buffer.*/
static void jmi_delay_position_init(jmi_delay_position_t *position);



 /* Implementation of jmi_delay API, based on jmi_delaybuffer_t */

static jmi_real_t get_t(jmi_t *jmi) { return *jmi_get_t(jmi); }

/** \brief Initialize a `jmi_delay_t`, except for the delay buffer */
static void init_delay(jmi_delay_t *delay, jmi_boolean fixed, jmi_boolean no_event) {
    delay->fixed = fixed;
    delay->no_event = no_event;
    jmi_delay_position_init(&(delay->position));
}

/*  For fixed delays, we use the delay time as an offset already when recording into the buffer.
    We do this so that actual time of each time event is stored in the buffer. This ensures that
    when we trigger on a time event, update_position will know which is the new interval.
    This also means that we don't offset the event time when reading it out in jmi_delay_next_time_event.
    
    NB: If we want to reuse the same jmi_delaybuffer_t struct with different delay times,
    we will need to fix this issue in update_position instead. */
static jmi_real_t get_time_offset(jmi_delay_t *delay) { return delay->fixed ? delay->buffer.max_delay : 0; }


int jmi_delay_new(jmi_t *jmi, int index) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    if (index < 0 || index >= jmi->n_delays) return -1;

    /* Initialize with sensible default values to be safe. The proper initialization is done in jmi_delay_init. */
    init_delay(delay, FALSE, FALSE);
    /* Initialize the delay buffer */
    return jmi_delaybuffer_new(jmi, &(delay->buffer));
}
int jmi_delay_delete(jmi_t *jmi, int index) {
    if (index < 0 || index >= jmi->n_delays) return -1;
    return jmi_delaybuffer_delete(&(jmi->delays[index].buffer));
}

int jmi_delay_init(jmi_t *jmi, int index, jmi_boolean fixed, jmi_boolean no_event, jmi_real_t max_delay, jmi_real_t y0) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    if (index < 0 || index >= jmi->n_delays) return -1;

    init_delay(delay, fixed, no_event);
    if (jmi_delaybuffer_init(&(delay->buffer), max_delay) < 0) return -1;

    /* Record the initial point, and then an event with the same value to get constant interpolation before the initial time */
    if (jmi_delaybuffer_record_sample(jmi, &(delay->buffer), get_t(jmi) + get_time_offset(delay), y0, FALSE) < 0) return -1;
    return jmi_delaybuffer_record_sample(jmi, &(delay->buffer), get_t(jmi) + get_time_offset(delay), y0, TRUE);
}

jmi_real_t jmi_delay_evaluate(jmi_t *jmi, int index, jmi_real_t y_in, jmi_real_t delay_time) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    jmi_real_t t = get_t(jmi);
    jmi_real_t t_delayed, t_curr;
    if (index < 0 || index >= jmi->n_delays) {
    	jmi_internal_error(jmi, "Delay index out of bounds");
    }

    /* Calculate current and delayed time appropriately depending on the type of delay */
    if (delay->fixed) {
        /* Ignore the delay time if fixed, then it has already been used when putting data into the buffer. */
        t_delayed = t;
        /* Adjust the current time in the same way instead */ 
        t_curr = t + delay->buffer.max_delay; /* max_delay is the fixed delay */
    } else {
        t_delayed = t - delay_time;
        t_curr = t;
    }

    /* If delay->no_event, evaluate should always think that we are at an event so that it can cross events in the buffer */
    return jmi_delaybuffer_evaluate(jmi, &(delay->buffer), jmi->atEvent || delay->no_event, t_delayed, &(delay->position), t_curr, y_in);
}

int jmi_delay_record_sample(jmi_t *jmi, int index, jmi_real_t y_in) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    if (index < 0 || index >= jmi->n_delays) return -1;
    return jmi_delaybuffer_record_sample(jmi, &(delay->buffer), get_t(jmi) + get_time_offset(delay), y_in, jmi->delay_event_mode);
}

/* todo: Fold as an argument into the record_sample functions? */
int jmi_delay_set_event_mode(jmi_t *jmi, jmi_boolean in_event) {
    jmi->delay_event_mode = in_event;
    return 0;
}

jmi_real_t jmi_delay_next_time_event(jmi_t *jmi) {
    jmi_real_t t_event = JMI_INF;
    int index;
    /* consider: More efficient strategy than linear iteration over all (fixed and variable time, event and noevent) delays? */
    for (index = 0; index < jmi->n_delays; index++) {
        jmi_delay_t *delay = &(jmi->delays[index]);
        if (delay->fixed && !delay->no_event) {
            jmi_real_t t = jmi_delaybuffer_next_event_time(&(delay->buffer), &(delay->position));
            /* Don't add the delay time here since it has already been added when recording for fixed delays. */
            if (t < t_event) t_event = t;
        }
    }
    return t_event;
}

static int jmi_delay_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator, jmi_boolean first) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    jmi_real_t t, t_event;
    if (index < 0 || index >= jmi->n_delays) return -1;
    if (delay->fixed || delay->no_event) return -1;

    t = get_t(jmi) - delay_time; /* t = current delayed time */

    if (jmi->atEvent) jmi_delaybuffer_update_position_at_event(&(delay->buffer), t, &(delay->position));

    if (first) {
        t_event = jmi_delaybuffer_prev_event_time(&(delay->buffer), &(delay->position));
        if (t_event <= -JMI_INF) {
            *event_indicator = 1; 
            return 0;
        }
        *event_indicator = t - t_event; /* Should always be >= 0. Equal to zero at least when time - delay_time == t_event. */
    } else {
        jmi_real_t t_event = jmi_delaybuffer_next_event_time(&(delay->buffer), &(delay->position));
        if (t_event >= JMI_INF) {
            *event_indicator = 1; 
            return 0;
        }
        *event_indicator = t_event - t; /* Should always be >= 0. Equal to zero at least when time - delay_time == t_event. */
    }
    return 0;
}

/* consider: Fold these two into a function the computes both at the same time? */
int jmi_delay_first_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator) {
    return jmi_delay_event_indicator(jmi, index, delay_time, event_indicator, TRUE);
}
int jmi_delay_second_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator) {
    return jmi_delay_event_indicator(jmi, index, delay_time, event_indicator, FALSE);
}



 /* Implementation of jmi_spatialdist API, based on jmi_delaybuffer_t */

/* Calculate delay buffer coordinate for the left/right end point given x.
   It is assumed that the left endpoint has a lower coordinate than the right.
   These functions should be used everywhere to make sure that the end
   positions are calculated in a consistent way from x, e.g. to make sure
   that position updates stay consistent with the event indicators. */
static jmi_real_t x2left(jmi_real_t x)  { return  -x; }
static jmi_real_t x2right(jmi_real_t x) { return 1-x; }
/* y is the normalized position along the pipe, 0 = left, 1 = right */
static jmi_real_t x2coord(jmi_real_t x, jmi_real_t y) { return y-x; }

static void init_spatialdist(jmi_spatialdist_t *spatialdist, jmi_boolean no_event, jmi_real_t x0) {
    spatialdist->no_event = no_event;
    spatialdist->last_x   = x0;
    jmi_delay_position_init(&(spatialdist->lposition));
    jmi_delay_position_init(&(spatialdist->rposition));
}

int jmi_spatialdist_new(jmi_t *jmi, int index) {
    jmi_spatialdist_t *spatialdist = &(jmi->spatialdists[index]);
    if (index < 0 || index >= jmi->n_spatialdists) return -1;

    /* Initialize with sensible default values to be safe. The proper initialization is done in jmi_spatialdist_init. */
    init_spatialdist(spatialdist, FALSE, 0);
    /* Initialize the delay buffer */
    return jmi_delaybuffer_new(jmi, &(spatialdist->buffer));
}
int jmi_spatialdist_delete(jmi_t *jmi, int index) {
    if (index < 0 || index >= jmi->n_spatialdists) return -1;
    return jmi_delaybuffer_delete(&(jmi->spatialdists[index].buffer));
}

int jmi_spatialdist_init(jmi_t *jmi, int index, jmi_boolean no_event, jmi_real_t x0, jmi_array_t *x_init, jmi_array_t *y_init) {
    int i;
    int n_init = x_init->num_elems;
    jmi_spatialdist_t *spatialdist = &(jmi->spatialdists[index]);
    jmi_delaybuffer_t *buffer = &(spatialdist->buffer);
    jmi_real_t last_x_init;
    
    if (index < 0 || index >= jmi->n_spatialdists) return -1;
    if (n_init != y_init->num_elems) return -1;
    if (n_init < 2) return -1;
    if (x_init->var[0] != 0.0) return -1;
    if (x_init->var[n_init-1] != 1.0) return -1;

    /* lposition and rposition are initialized to the beginning of the buffer, which is ok as long as there are no events in it. */
    init_spatialdist(spatialdist, no_event, x0);
    if (jmi_delaybuffer_init(buffer, 1.0) < 0) return -1;

    /* Initialize the buffer contents. */
    last_x_init = -1;
    for (i = 0; i < n_init; i++) {
        /* Create an event if this is a repeated x position */
        if (jmi_delaybuffer_record_sample(jmi, buffer, x2coord(x0, x_init->var[i]), y_init->var[i], x_init->var[i] == last_x_init) < 0) return -1;
        last_x_init = x_init->var[i];
    }
    /* Make sure rposition is at the right end point */
    if (jmi_delaybuffer_update_position_at_event(buffer, JMI_INF, &(spatialdist->rposition)) < 0) return -1;    
    return 0;
}


jmi_real_t jmi_spatialdist_evaluate(jmi_t *jmi, int index, jmi_real_t *out0, jmi_real_t *out1, jmi_real_t in0, jmi_real_t in1, jmi_real_t x, jmi_boolean positiveVelocity) {
    jmi_real_t out0dummy;
    jmi_real_t out1dummy;
    jmi_spatialdist_t *spatialdist = &(jmi->spatialdists[index]);
    if (index < 0 || index >= jmi->n_spatialdists) {
        jmi_internal_error(jmi, "Spatial distribution index out of bounds");
    }

    if (out0 == NULL) {
        out0 = &out0dummy;
    }

    if (out1 == NULL) {
        out1 = &out1dummy;
    }

    if (positiveVelocity) {
        *out0 = in0;
        *out1 = jmi_delaybuffer_evaluate_left(jmi, &(spatialdist->buffer), jmi->atEvent || spatialdist->no_event,
                                              x2right(x), &(spatialdist->rposition),
                                              x2left(x), in0);
    } else {
        *out1 = in1;
        *out0 = jmi_delaybuffer_evaluate(jmi, &(spatialdist->buffer), jmi->atEvent || spatialdist->no_event,
                                         x2left(x), &(spatialdist->lposition),
                                         x2right(x), in1);
    }
    return *out0;
}

int jmi_spatialdist_record_sample(jmi_t *jmi, int index, jmi_real_t in0, jmi_real_t in1, jmi_real_t x, jmi_boolean positiveVelocity) {
    jmi_spatialdist_t *spatialdist = &(jmi->spatialdists[index]);
    jmi_delaybuffer_t *buffer = &(spatialdist->buffer);
    if (index < 0 || index >= jmi->n_spatialdists) return -1;

    if (x > spatialdist->last_x || (x == spatialdist->last_x && positiveVelocity) ) {
        /* Contents moving right */
        /* Truncation will only have an effect upon flow reversal. */
        if (jmi_delaybuffer_truncate_left(     jmi, buffer, x2left(spatialdist->last_x), &(spatialdist->lposition)) < 0) return -1;
        if (jmi_delaybuffer_record_sample_left(jmi, buffer, x2left(x), in0, jmi->delay_event_mode) < 0) return -1;

        if (jmi->delay_event_mode) {
            /* Update the position at the recording end to be at the end */
            if (jmi_delaybuffer_update_position_at_event(buffer, -JMI_INF, &(spatialdist->lposition)) < 0) return -1;
        }        
    } else {
        /* Contents moving right */
        /* Truncation will only have an effect upon flow reversal. */
        if (jmi_delaybuffer_truncate_right(jmi, buffer, x2right(spatialdist->last_x), &(spatialdist->rposition)) < 0) return -1;
        if (jmi_delaybuffer_record_sample( jmi, buffer, x2right(x), in1, jmi->delay_event_mode) < 0) return -1;

        if (jmi->delay_event_mode) {
            /* Update the position at the recording end to be at the end */
            if (jmi_delaybuffer_update_position_at_event(buffer, JMI_INF, &(spatialdist->rposition)) < 0) return -1;
        }
    }
    spatialdist->last_x = x;
    return 0;
}

int jmi_spatialdist_event_indicator(jmi_t *jmi, int index, jmi_real_t x, jmi_boolean positiveVelocity, jmi_real_t *event_indicator) {
    jmi_real_t t_event;
    jmi_spatialdist_t *spatialdist = &(jmi->spatialdists[index]);
    jmi_delaybuffer_t *buffer = &(spatialdist->buffer);
    if (index < 0 || index >= jmi->n_spatialdists) return -1;
    if (spatialdist->no_event) return -1;
    
    if (positiveVelocity) {
        /* Contents moving right */
        if (jmi->atEvent) jmi_delaybuffer_update_position_at_event(buffer, x2right(x), &(spatialdist->rposition));
        t_event = jmi_delaybuffer_prev_event_time(buffer, &(spatialdist->rposition));
        if (t_event <= -JMI_INF) {
            *event_indicator = 1; 
            return 0;
        }
        *event_indicator = x2right(x) - t_event;
    } else {
        /* Contents moving left */
        if (jmi->atEvent) jmi_delaybuffer_update_position_at_event(buffer, x2left(x), &(spatialdist->lposition));
        t_event = jmi_delaybuffer_next_event_time(buffer, &(spatialdist->lposition));
        if (t_event >= JMI_INF) {
            *event_indicator = 1; 
            return 0;
        }
        *event_indicator = t_event - x2left(x);
    }
    return 0;
}



 /* Implementation of jmi_delaybuffer_t functions */

/** \brief (Re)initialize the buffer as empty, without changing the current allocation */
static void clear(jmi_delaybuffer_t *buffer, jmi_real_t max_delay) {
    buffer->size = buffer->head = buffer->head_index = 0;
    buffer->max_delay = max_delay;
}

/** \brief Make sure that the buffer has space for at least `capacity` points. May reallocate the buffer and move points in it, but preserves the index of each point. */
static int reserve(jmi_delaybuffer_t *buffer, int capacity) {
    int new_capacity;
    jmi_delay_point_t *new_buf;
    if (capacity <= buffer->capacity) return 0;

    /* Allocate new buffer */
    new_capacity = buffer->capacity;
    while (new_capacity < capacity) new_capacity *= 2;
    new_buf = (jmi_delay_point_t *)calloc(new_capacity, sizeof(jmi_delay_point_t));
    if (new_buf == NULL) return -1;

    /* Transfer contents */
    if (buffer->size <= buffer->capacity - buffer->head) {
        /* Just on block to transfer */
        memcpy(new_buf, buffer->buf + buffer->head, sizeof(jmi_delay_point_t)*(buffer->size));
    } else {
        /* Two blocks to transfer */
        int first_size = buffer->capacity - buffer->head;
        memcpy(new_buf,              buffer->buf + buffer->head, sizeof(jmi_delay_point_t)*(first_size));
        memcpy(new_buf + first_size, buffer->buf,                sizeof(jmi_delay_point_t)*(buffer->size - first_size));
    }

    /* Free old buffer */
    free(buffer->buf);

    /* Update buffer object */
    buffer->buf = new_buf;
    buffer->capacity = new_capacity;
    buffer->head = 0;

    return 0;
}

/** \brief Translate from sample index to position `buffer->buf`. `index` should be within the buffer, e.g. `0 <= index - buffer->head_index < buffer->size`. */
static int index2pos(jmi_delaybuffer_t *buffer, int index) {
    int pos = index - buffer->head_index + buffer->head;
    if (pos >= buffer->capacity) pos -= buffer->capacity;
    return pos;
}

static jmi_boolean event_left_of(jmi_delaybuffer_t *buffer, int index) {
    return buffer->buf[index2pos(buffer, index)].left == index;
}
static jmi_boolean event_right_of(jmi_delaybuffer_t *buffer, int index) {
    return buffer->buf[index2pos(buffer, index)].right == index;
}

/** \brief Discard the rightmost sample in the buffer. The buffer must not be empty. */
static void discard_right(jmi_delaybuffer_t *buffer) {
    buffer->size--;
    if (buffer->size > 0) {
        /* Don't link beyond buffer */
        int tail_index = buffer->head_index + buffer->size - 1;
        buffer->buf[index2pos(buffer, tail_index)].right = tail_index;
    }
}

/** \brief Discard the leftmost sample in the buffer. The buffer must not be empty. */
static void discard_left(jmi_delaybuffer_t *buffer) {
    buffer->size--;
    buffer->head++;
    if (buffer->head >= buffer->capacity) buffer->head = 0;
    buffer->head_index++;
    if (buffer->size > 0) {
        /* Don't link beyond buffer */
        buffer->buf[buffer->head].left = buffer->head_index;
    }
}

/** \brief Grow the buffer one sample the left. Space for the new sample should already have been reserved. */
static void undiscard_left(jmi_delaybuffer_t *buffer) {
    buffer->size++;
    buffer->head--;
    if (buffer->head < 0) buffer->head = buffer->capacity-1;
    buffer->head_index--;
}

/** \brief Break the links between the left sample and the right sample to mark an event between them */
static void delink(jmi_delay_point_t buf[], int left_pos, int left_index, int right_pos, int right_index) {
    buf[left_pos].right = left_index;
    buf[right_pos].left = right_index;
}

/** \brief Link the left sample to the right sample (no event in between) */
static void link(jmi_delay_point_t buf[], int left_pos, int left_index, int right_pos, int right_index) {
    buf[left_pos].right = right_index;
    buf[right_pos].left = left_index;
}

/* Note: jmi_delaybuffer_evaluate may reverse the effects of put by restoring the value of buffer->size from before the invocation. */
/** \brief Try to add a sample to the left or right end of the buffer, possibly discarding it or replacing a previous sample due to filtering */
static int put(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_right, jmi_boolean event_occurred) {
    jmi_delay_point_t *buf;
    int dest_pos;
    /* Reserve space for the new point to (possibly) be inserted below */
    if (reserve(buffer, buffer->size+1) < 0) jmi_internal_error(jmi, "Unable to allocate more space for delay buffer");
    buf = buffer->buf;

    /* Check consistency with previous buffer contents and set up appropriate left/right links */
    if (buffer->size >= 1) {
        /* end: The last current sample at the end where we want to insert */
        int end_index = at_right ? buffer->head_index + buffer->size - 1 : buffer->head_index;
        int end_pos = index2pos(buffer, end_index);
        int dest_index;

        if (event_occurred) {
            if (buf[end_pos].t != t) return -1; /* event occured => should have same t */
            
            /* Never filter the new or remove the last sample if there is only one sample,
               since that might cause extrapolation behind the sample point. */
            if (buffer->size > 1) {
                /* Filter out the event, or the current sample? */

                if (buf[end_pos].y == y) return 0; /* Filter out this event since it has the same y. NB: only valid for linear interpolation. */

                /* If there is already an event at the end, discard it. */
                if (at_right && event_left_of(buffer, end_index)) {
                    discard_right(buffer);
                    end_index--;
                    end_pos = index2pos(buffer, end_index);
                }
                if (!at_right && event_right_of(buffer, end_index)) {
                    discard_left(buffer);
                    end_index++;
                    end_pos = index2pos(buffer, end_index);
                }
            }
        } else {
            /* t should always increase with index except for events */
            if ((at_right && buf[end_pos].t >= t) || (!at_right && buf[end_pos].t <= t)) return -1;
        }

        if (at_right) {
            /* Add new sample at the right end and point dest_index/dest_pos to it*/
            dest_index = end_index+1;
            buffer->size++; /* i.e. undiscard_right(buffer); */
            dest_pos = index2pos(buffer, dest_index);

            /* Set up the links with the sample to the left */
            if (event_occurred) delink(buf, end_pos, end_index, dest_pos, dest_index);
            else                  link(buf, end_pos, end_index, dest_pos, dest_index);
            /* Don't link beyond the existing buffer */
            buf[dest_pos].right = dest_index;
        } else {
            /* Add new sample at the left end and point dest_index/dest_pos to it*/
            dest_index = end_index-1;
            undiscard_left(buffer);
            dest_pos = index2pos(buffer, dest_index);

            /* Set up the links with the sample to the right */
            if (event_occurred) delink(buf, dest_pos, dest_index, end_pos, end_index);
            else                  link(buf, dest_pos, dest_index, end_pos, end_index);
            /* Don't link beyond the existing buffer */
            buf[dest_pos].left = dest_index;
        }
    } else {
        /* This is the first point; there's nothing to link to but itself */
        dest_pos = buffer->head;
        buffer->size++;
        buf[dest_pos].left = buf[dest_pos].right = buffer->head_index;
    }
    buf[dest_pos].t = t;
    buf[dest_pos].y = y;

    return 0;
}


static int jmi_delaybuffer_new(jmi_t *jmi, jmi_delaybuffer_t *buffer) {
    buffer->capacity = BUFFER_INITIAL_CAPACITY;
    buffer->buf = (jmi_delay_point_t *)calloc(buffer->capacity, sizeof(jmi_delay_point_t));
    if (buffer->buf == NULL) jmi_internal_error(jmi, "Unable to allocate space for delay buffer");
    clear(buffer, 0); /* sets max_delay to zero; will be set to correct value in jmi_delaybuffer_init */
    return 0;
}
static int jmi_delaybuffer_delete(jmi_delaybuffer_t *buffer) {
    free(buffer->buf);
    buffer->buf = NULL;
    buffer->capacity = 0;
    return 0;
}

static int jmi_delaybuffer_init(jmi_delaybuffer_t *buffer, jmi_real_t max_delay) {
    clear(buffer, max_delay);
    return 0;
}

/** \brief Move `position` to an interval that contains `tr`, if possible. Don't cross any events unless `at_event`. */
static int update_position(jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                           jmi_real_t tr, jmi_delay_position_t *position) {
    jmi_delay_point_t *buf = buffer->buf;
    int index = position->curr_interval;
    int last_index = buffer->head_index + buffer->size - 1;

    if (buffer->size < 1) return -1;
    if (buffer->size == 1) {
        /* Just a single point in the buffer */
        position->curr_interval = buffer->head_index;
        return 0;
    }

    /* Make sure that index is within bounds. 
       It may be at the last index, in which case we only have a point position and not an interval. */
    if (index > last_index) index = last_index;
    else if (index < buffer->head_index) index = buffer->head_index;

    /* Search to the left */
    while (index > buffer->head_index) {
        int lpos = index2pos(buffer, index);
        if (!at_event && event_left_of(buffer, index)) break;
        if (buf[lpos].t <= tr) break;
        index--;
    }

    /* Check for an event between index and index + 1. 
       This should probably only occur if we are to the left of the initial event (initial value for delay). */
    if (!at_event && event_right_of(buffer, index)) {
        position->curr_interval = index;
        return 0;
    }

    /* Search to the right */   
    /* index < last_index ==> index + 1 is a valid sample index */ 
    while (index < last_index) {
        int rpos = index2pos(buffer, index+1);
        if (!at_event && event_right_of(buffer, index+1)) break;
        /* We must use > so that we choose the rightmost allowable interval at time events triggered when t == buf[rpos].tr */
        if (buf[rpos].t > tr) break;
        index++;
    }
    position->curr_interval = index;
    return 0;
}

/* Interpolate the minimum degree polynomial through the given points using Neville's Algorithm */
#define MAX_NEVILLE_PTS 16
static jmi_real_t neville_evaluate(jmi_delaybuffer_t *buffer, jmi_real_t t, int first_index, int n_points) {
    jmi_real_t work[MAX_NEVILLE_PTS];
    jmi_real_t ts[MAX_NEVILLE_PTS];
    jmi_delay_point_t *buf = buffer->buf;
    int i, n;
    if (n_points > MAX_NEVILLE_PTS) return -1; /* todo: error */

    /* Copy the initial points */
    for (i=0; i < n_points; i++) {
        int pos = index2pos(buffer, i + first_index);
        work[i] = buf[pos].y;
        ts[i] = buf[pos].t;
    }

    /* Evaluate the intermediate results */
    /* Loop over the polynomial order n */
    for (n=1; n < n_points; n++) {
        /* Loop over the interpolating polynomials of order n */
        /* work[i] contains p[i:i+n-1](t) before this, and p[i:i+n](t) after */
        for (i=0; i < n_points-n; i++) {
            int j = i+n; 
            work[i] = ((ts[j] - t)*work[i] + (t-ts[i])*work[i+1])/(ts[j]-ts[i]);
        }
    }
    return work[0];
}

/** \brief Evaluate the buffer at time `tr`. Don't step the (inout) argument `position` over events unless `at_event`. */
static jmi_real_t evaluate(jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                           jmi_real_t tr, jmi_delay_position_t *position) {
    int lpos;
    jmi_delay_point_t *buf = buffer->buf;
    if (buffer->size <= 1) {
        if (buffer->size == 1) return buf[buffer->head].y;
        else return -1; /* todo: error */
    }
    if (update_position(buffer, at_event, tr, position) < 0) return -1; /* todo: error */

    /* If our interval is just one sample, return its value. */
    lpos = index2pos(buffer, position->curr_interval);
    if (event_right_of(buffer, position->curr_interval)) return buf[lpos].y;

    /* We have a whole interval, do linear interpolation. */
    return neville_evaluate(buffer, tr, position->curr_interval, 2);

    /* Linear interpolation. Todo: remove / use as special case? */
    /*
    {
        int lpos = index2pos(buffer, position->curr_interval);
        int rpos = index2pos(buffer, position->curr_interval+1);
        jmi_real_t t0 = buf[lpos].t, t1 = buf[rpos].t;
        jmi_real_t y0 = buf[lpos].y, y1 = buf[rpos].y;

        if (tr <= t0) return y0;
        else if (tr >= t1) return y1;   

        return y0 + (y1-y0)*(tr-t0)/(t1-t0);
    }
    */
}

static jmi_real_t jmi_delaybuffer_evaluate(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                                           jmi_real_t tr, jmi_delay_position_t *position, jmi_real_t t_curr, jmi_real_t y_curr) {
    /* todo: more efficient handling of (t_curr, y_curr)? */
    jmi_real_t y;
    int orig_size = buffer->size;
    put(jmi, buffer, t_curr, y_curr, TRUE, FALSE); /* Temporarily put (t_curr, y_curr) at the right end of the delay buffer */
    y = evaluate(buffer, at_event, tr, position);
    buffer->size = orig_size;       /* Remove (t_curr, y_curr) from the delay buffer again */
    return y;
}

static jmi_real_t jmi_delaybuffer_evaluate_left(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                                                jmi_real_t tr, jmi_delay_position_t *position, jmi_real_t t_curr, jmi_real_t y_curr) {
    /* todo: more efficient handling of (t_curr, y_curr)? */
    jmi_real_t y;
    int orig_size = buffer->size;
    put(jmi, buffer, t_curr, y_curr, FALSE, FALSE); /* Temporarily put (t_curr, y_curr) at the left end of the delay buffer */
    y = evaluate(buffer, at_event, tr, position);
    /* Remove (t_curr, y_curr) from the delay buffer again */
    if (buffer->size > orig_size) discard_left(buffer);
    return y;
}

static void discard_samples_left(jmi_delaybuffer_t *buffer, jmi_real_t t_limit) {
    jmi_delay_point_t *buf = buffer->buf;    
    const int offset = JMI_DELAY_MAX_INTERPOLATION_POINTS-1;
    while (offset < buffer->size && buf[index2pos(buffer, buffer->head_index + offset)].t < t_limit) {
        /* Remove the leftmost point */
        discard_left(buffer);
    }
}

static void discard_samples_right(jmi_delaybuffer_t *buffer, jmi_real_t t_limit) {
    jmi_delay_point_t *buf = buffer->buf;    
    const int offset = JMI_DELAY_MAX_INTERPOLATION_POINTS-1;
    while (offset < buffer->size && buf[index2pos(buffer, buffer->head_index + buffer->size - 1 - offset)].t > t_limit) {
        /* Remove the rightmost point */
        discard_right(buffer);
    }
}

static int jmi_delaybuffer_record_sample(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_event) {
    if (put(jmi, buffer, t, y, TRUE, at_event) < 0) return -1;
    discard_samples_left(buffer, t - buffer->max_delay);
    return 0;
}
static int jmi_delaybuffer_record_sample_left(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_event) {
    if (put(jmi, buffer, t, y, FALSE, at_event) < 0) return -1;
    discard_samples_right(buffer, t + buffer->max_delay);
    return 0;
}

static jmi_real_t jmi_delaybuffer_next_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position) {
    jmi_delay_point_t *buf = buffer->buf;
    int last_index = position->curr_interval; /* Start from the left point; there may be an event just to the right of it. */
    int index = buf[index2pos(buffer, last_index)].right;
    if (index != last_index) {
        int final_index;
        int orig_index = last_index;
        /* Find the fixed point */
        while (index != last_index) {
            last_index = index;
            index = buf[index2pos(buffer, index)].right;
        }
        /* Move all intermediate pointers to the new fixed point */
        final_index = index;
        index = orig_index;
        while (index != final_index) {
            int pos = index2pos(buffer, index);
            index = buf[pos].right;
            buf[pos].right = final_index;
        }
    }
    if (index >= buffer->head_index + buffer->size - 1) return JMI_INF;
    else return buf[index2pos(buffer, index)].t;
}
static jmi_real_t jmi_delaybuffer_prev_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position) {
    jmi_delay_point_t *buf = buffer->buf;
    int last_index = position->curr_interval;
    int index = buf[index2pos(buffer, last_index)].left;
    if (index != last_index) {
        int final_index;
        int orig_index = last_index;
        /* Find the fixed point */
        while (index != last_index) {
            last_index = index;
            index = buf[index2pos(buffer, index)].left;
        }
        /* Move all intermediate pointers to the new fixed point */
        final_index = index;
        index = orig_index;
        while (index != final_index) {
            int pos = index2pos(buffer, index);
            index = buf[pos].left;
            buf[pos].left = final_index;
        }
    }
    if (index <= buffer->head_index) return -JMI_INF;
    else return buf[index2pos(buffer, index)].t;
}

static int jmi_delaybuffer_update_position_at_event(jmi_delaybuffer_t *buffer, jmi_real_t tr, jmi_delay_position_t *position) {
    return update_position(buffer, TRUE, tr, position);
}

static int jmi_delaybuffer_truncate_left(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t_limit, jmi_delay_position_t *lposition) {
    jmi_delay_point_t *buf = buffer->buf;
    /* Early out: `jmi_spatialdist_record_sample` will call this each sample, but truncation will only be needed at flow reversal. */
    if ((buffer->size > 0) && (buf[index2pos(buffer, buffer->head_index)].t < t_limit)) {
        jmi_real_t y = evaluate(buffer, FALSE, t_limit, lposition);
        while ((buffer->size > 0) && (buf[index2pos(buffer, buffer->head_index)].t <= t_limit)) discard_left(buffer);
        put(jmi, buffer, t_limit, y, FALSE, FALSE);
    }
    return 0;
}
static int jmi_delaybuffer_truncate_right(jmi_t *jmi, jmi_delaybuffer_t *buffer, jmi_real_t t_limit, jmi_delay_position_t *rposition) {
    jmi_delay_point_t *buf = buffer->buf;
    /* Early out: `jmi_spatialdist_record_sample` will call this each sample, but truncation will only be needed at flow reversal. */
    if ((buffer->size > 0) && (buf[index2pos(buffer, buffer->head_index + buffer->size - 1)].t > t_limit)) {
        jmi_real_t y = evaluate(buffer, FALSE, t_limit, rposition);
        while ((buffer->size > 0) && (buf[index2pos(buffer, buffer->head_index + buffer->size - 1)].t >= t_limit)) discard_right(buffer);
        put(jmi, buffer, t_limit, y, TRUE, FALSE);
    }
    return 0;
}

static void jmi_delay_position_init(jmi_delay_position_t *position) {
    position->curr_interval = 0;
}
