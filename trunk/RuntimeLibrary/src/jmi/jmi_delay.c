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


static int jmi_delaybuffer_new(jmi_delaybuffer_t *buffer);
static int jmi_delaybuffer_delete(jmi_delaybuffer_t *buffer);

static int jmi_delaybuffer_init(jmi_delaybuffer_t *buffer, jmi_real_t max_delay, jmi_real_t t0, jmi_real_t y0);

/** \brief position is an inout argument */ 
static jmi_real_t jmi_delaybuffer_evaluate(jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                                           jmi_real_t tr, jmi_delay_position_t *position, jmi_real_t t_curr, jmi_real_t y_curr);

static int jmi_delaybuffer_record_sample(jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_event);

static jmi_real_t jmi_delaybuffer_next_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position);
static jmi_real_t jmi_delaybuffer_prev_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position);

static int jmi_delaybuffer_update_position_at_event(jmi_delaybuffer_t *buffer, jmi_real_t tr, jmi_delay_position_t *position);

static void jmi_delay_position_init(jmi_delay_position_t *position);


static jmi_real_t get_t(jmi_t *jmi) { return *jmi_get_t(jmi); }

static void init_delay(jmi_delay_t *delay, jmi_boolean fixed, jmi_boolean no_event) {
    delay->fixed = fixed;
    delay->no_event = no_event;
    jmi_delay_position_init(&(delay->position));
}

/*  For fixed delays, we use the delay time as an offset already when recording into the buffer.
    We do this to make sure that update_position will advance to the new interval when triggered
    exactly at a time event.
    This also means that we don't offset the event time when reading it out in jmi_delay_next_time_event.
    
    If we want to reuse the same jmi_delaybuffer_t struct with different delay times,
    we will have to fix this issue in update_position instead. */
static jmi_real_t get_time_offset(jmi_delay_t *delay) { return delay->fixed ? delay->buffer.max_delay : 0; }


int jmi_delay_new(jmi_t *jmi, int index) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    if (index < 0 || index >= jmi->n_delays) return -1;

    /* Initialize with sensible default values to be safe. The proper initialization is done in jmi_delay_init. */
    init_delay(delay, FALSE, FALSE);
    /* Initialize the delay buffer */
    return jmi_delaybuffer_new(&(jmi->delays[index].buffer));
}
int jmi_delay_delete(jmi_t *jmi, int index) {
    if (index < 0 || index >= jmi->n_delays) return -1;
    return jmi_delaybuffer_delete(&(jmi->delays[index].buffer));
}

int jmi_delay_init(jmi_t *jmi, int index, jmi_boolean fixed, jmi_boolean no_event, jmi_real_t max_delay, jmi_real_t y0) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    if (index < 0 || index >= jmi->n_delays) return -1;

    init_delay(delay, fixed, no_event);
    /* Note: cannot use get_time_offset below since the buffer hasn't been initialized yet */
    return jmi_delaybuffer_init(&(delay->buffer), max_delay, get_t(jmi) + (fixed ? max_delay : 0), y0);
}

jmi_real_t jmi_delay_evaluate(jmi_t *jmi, int index, jmi_real_t y_in, jmi_real_t delay_time) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    jmi_real_t t = get_t(jmi);
    jmi_real_t t_delayed, t_curr;
    if (index < 0 || index >= jmi->n_delays) return -1; /* todo: better way to handle the error? */

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
    return jmi_delaybuffer_evaluate(&(delay->buffer), jmi->atEvent || delay->no_event, t_delayed, &(delay->position), t_curr, y_in);
}

int jmi_delay_record_sample(jmi_t *jmi, int index, jmi_real_t y_in) {
    jmi_delay_t *delay = &(jmi->delays[index]);
    if (index < 0 || index >= jmi->n_delays) return -1;
    return jmi_delaybuffer_record_sample(&(delay->buffer), get_t(jmi) + get_time_offset(delay), y_in, jmi->delay_event_mode);
}

int jmi_delay_set_event_mode(jmi_t *jmi, jmi_boolean in_event) {
    jmi->delay_event_mode = in_event;
    return 0;
}

jmi_real_t jmi_delay_next_time_event(jmi_t *jmi) {
    jmi_real_t t_event = JMI_INF;
    int index;
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

    t = get_t(jmi) - delay_time;

    if (jmi->atEvent) jmi_delaybuffer_update_position_at_event(&(delay->buffer), t, &(delay->position));

    if (first) {
        t_event = jmi_delaybuffer_prev_event_time(&(delay->buffer), &(delay->position));
        if (t_event <= -JMI_INF) {
            *event_indicator = 1; 
            return 0;
        }
        *event_indicator = t - t_event;
    } else {
        jmi_real_t t_event = jmi_delaybuffer_next_event_time(&(delay->buffer), &(delay->position));
        if (t_event >= JMI_INF) {
            *event_indicator = 1; 
            return 0;
        }
        *event_indicator = t_event - t;
    }
    return 0;
}

int jmi_delay_first_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator) {
    return jmi_delay_event_indicator(jmi, index, delay_time, event_indicator, TRUE);
}
int jmi_delay_second_event_indicator(jmi_t *jmi, int index, jmi_real_t delay_time, jmi_real_t *event_indicator) {
    return jmi_delay_event_indicator(jmi, index, delay_time, event_indicator, FALSE);
}


static void clear(jmi_delaybuffer_t *buffer, jmi_real_t max_delay) {
    buffer->size = buffer->head = buffer->head_index = 0;
    buffer->max_delay = max_delay;
}

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

/* index - buffer->head_index should be between 0 and buffer->size - 1 */
static int index2pos(jmi_delaybuffer_t *buffer, int index) {
    int pos = index - buffer->head_index + buffer->head;
    if (pos >= buffer->capacity) pos -= buffer->capacity;
    return pos;
}


/* Note: jmi_delaybuffer_evaluate may reverse the effects of put by restoring the value of buffer->size from before the invocation. */
static int put(jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean event_occurred) {
    jmi_delay_point_t *buf;
    int tail;
    /* Reserve space for the new point to (possibly) be inserted below */
    if (reserve(buffer, buffer->size+1) < 0) return -1;
    buf = buffer->buf;

    /* Check consistency with previous buffer contents and calculate apropriate ti */
    if (buffer->size >= 1) {
        int last_index = buffer->head_index + buffer->size - 1;
        int last = index2pos(buffer, last_index);
        int index;

        if (event_occurred) {
            if (buf[last].t != t) return -1; /* event occured => should have same t */
            if (buf[last].y == y) return  0; /* Filter out this event since it has the same y. NB: only valid for linear interpolation. */
            if (buf[last].left == last_index) {
                /* There was already an event last, discard it and replace with this one. */
                /* This guarantees that there are never two events in a row, as expected. */
                buffer->size--;
                last_index--;
                last = index2pos(buffer, last_index);
            }
        } else {
            if (buf[last].t >= t) return -1; /* t should always increase except for events */
        }

        /* Set the right links */
        index = buffer->head_index + buffer->size; /* index of the new point */
        tail = index2pos(buffer, index);
        if (event_occurred) {
            /* Break the links between the last point and the current one */
            buf[last].right = index-1; /* This value should already be present there? */
            buf[tail].left  = index;
        } else {
            /* Link the last point with the current one */
            buf[last].right = index;
            buf[tail].left  = index-1;
        }
        /* Don't link beyond the existing buffer */
        buf[tail].right = index;
    } else {
        /* This is the first point; there's nothing to link to but itself */
        tail = buffer->head;
        buf[tail].left = buf[tail].right = 0;
    }
    buf[tail].t = t;
    buf[tail].y = y;
    buffer->size++;

    return 0;
}


static int jmi_delaybuffer_new(jmi_delaybuffer_t *buffer) {
    buffer->capacity = BUFFER_INITIAL_CAPACITY;
    buffer->buf = (jmi_delay_point_t *)calloc(buffer->capacity, sizeof(jmi_delay_point_t));
    clear(buffer, 0); /* sets max_delay to zero; will be set to correct value in jmi_delaybuffer_init */
    return 0;
}
static int jmi_delaybuffer_delete(jmi_delaybuffer_t *buffer) {
    free(buffer->buf);
    buffer->buf = NULL;
    return 0;
}

static int jmi_delaybuffer_init(jmi_delaybuffer_t *buffer, jmi_real_t max_delay, jmi_real_t t0, jmi_real_t y0) {
    clear(buffer, max_delay);
    return put(buffer, t0, y0, FALSE);
}

static int update_position(jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                           jmi_real_t tr, jmi_delay_position_t *position) {
    /* Find an interval that contains tr */
    /* Don't cross any ti changes unless at_event is true */
    jmi_delay_point_t *buf = buffer->buf;
    int index = position->curr_interval;
    int second_last_index = buffer->head_index + buffer->size - 2;

    if (buffer->size < 1) return -1;
    if (buffer->size == 1) {
        /* Just a single point in the buffer */
        position->curr_interval = 0;
        return 0;
    }

    /* Make sure index is within bounds */
    if (index > second_last_index) index = second_last_index;
    else if (index < buffer->head_index) index = buffer->head_index;

    /* Search to the left */
    while (index > buffer->head_index) {
        int lpos = index2pos(buffer, index);
        if (buf[lpos].left == index && !at_event) break;
        if (buf[lpos].t    <= tr) break;
        index--;
    }

    /* Search to the right */    
    while (index < second_last_index) {
        int rpos = index2pos(buffer, index+1);
        if (buf[rpos].right == index+1 && !at_event) break;
        /* We must use > so that we choose the rightmost allowable interval at time events triggered when t == buf[rpos].tr */
        if (buf[rpos].t     >  tr) break;
        index++;
    }
    position->curr_interval = index;
    return 0;
}

static jmi_real_t evaluate(jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                           jmi_real_t tr, jmi_delay_position_t *position) {
    jmi_delay_point_t *buf = buffer->buf;
    if (buffer->size <= 1) {
        if (buffer->size == 1) return buf[buffer->head].y;
        else return -1; /* todo: error */
    }
    if (update_position(buffer, at_event, tr, position) < 0) return -1; /* todo: error */

    /* Linear interpolation */
    {
        int lpos = index2pos(buffer, position->curr_interval);
        int rpos = index2pos(buffer, position->curr_interval+1);
        jmi_real_t t0 = buf[lpos].t, t1 = buf[rpos].t;
        jmi_real_t y0 = buf[lpos].y, y1 = buf[rpos].y;

        if (tr <= t0) return y0;
        else if (tr >= t1) return y1;   

        return y0 + (y1-y0)*(tr-t0)/(t1-t0);
    }
}

static void discard_samples_left(jmi_delaybuffer_t *buffer, jmi_real_t t_limit) {
    jmi_delay_point_t *buf = buffer->buf;    
    const int offset = JMI_DELAY_MAX_INTERPOLATION_POINTS-1;
    while (offset < buffer->size && buf[index2pos(buffer, buffer->head_index + offset)].t < t_limit) {
        /* Remove the leftmost point */
        buffer->size--;
        buffer->head++;
        if (buffer->head >= buffer->capacity) buffer->head = 0;
        buffer->head_index++;
    }
}

static jmi_real_t jmi_delaybuffer_evaluate(jmi_delaybuffer_t *buffer, jmi_boolean at_event,
                                           jmi_real_t tr, jmi_delay_position_t *position, jmi_real_t t_curr, jmi_real_t y_curr) {
    /* todo: more efficient handling of (t_curr, y_curr)? */
    jmi_real_t y;
    int orig_size = buffer->size;
    put(buffer, t_curr, y_curr, FALSE); /* Temporarily put (t_curr, y_curr) in the delay buffer */
    y = evaluate(buffer, at_event, tr, position);
    buffer->size = orig_size;       /* Remove (t_curr, y_curr) from the delay buffer again */
    return y;
}

static int jmi_delaybuffer_record_sample(jmi_delaybuffer_t *buffer, jmi_real_t t, jmi_real_t y, jmi_boolean at_event) {
    if (put(buffer, t, y, at_event) < 0) return -1;
    discard_samples_left(buffer, t - buffer->max_delay);
    return 0;
}

static jmi_real_t jmi_delaybuffer_next_event_time(jmi_delaybuffer_t *buffer, jmi_delay_position_t *position) {
    jmi_delay_point_t *buf = buffer->buf;
    int last_index = position->curr_interval+1;
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

static void jmi_delay_position_init(jmi_delay_position_t *position) {
    position->curr_interval = 0;
}
