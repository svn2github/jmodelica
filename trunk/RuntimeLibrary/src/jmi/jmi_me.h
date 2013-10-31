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

#ifndef jmi_me_h
#define jmi_me_h

#include "stdio.h"

#include "jmi.h"
#include "jmi_util.h"
#include "jmi_log.h"

typedef unsigned int jmi_value_reference;
typedef char jmi_boolean;
typedef const char* jmi_string;

typedef struct jmi_event_info_t jmi_event_info_t;

struct jmi_event_info_t {
    jmi_boolean iteration_converged;
    jmi_boolean state_value_references_changed;
    jmi_boolean state_values_changed;
    jmi_boolean nominals_of_states_changed;
    jmi_boolean terminate_simulation;
    jmi_boolean next_event_time_defined;
    jmi_real_t  next_event_time;
};

jmi_value_reference get_index_from_value_ref(jmi_value_reference valueref); /* TODO: should be static later on if possible */
    
jmi_value_reference get_type_from_value_ref(jmi_value_reference valueref); /* TODO: should be static later on if possible */

int jmi_set_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_real_t value[]);

int jmi_set_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_int_t value[]);

int jmi_set_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_boolean value[]);

int jmi_set_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, const jmi_string value[]);

int jmi_get_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_real_t value[]);

int jmi_get_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_int_t value[]);

int jmi_get_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_boolean value[]);

int jmi_get_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, jmi_string  value[]);

int jmi_get_directional_derivative(jmi_t* jmi,
                const jmi_value_reference vUnknown_ref[], size_t nUnknown,
                const jmi_value_reference vKnown_ref[],   size_t nKnown,
                const jmi_real_t dvKnown[], jmi_real_t dvUnknown[]);

int jmi_get_derivatives(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx);

int jmi_get_event_indicators(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni);

int jmi_get_nominal_continuous_states(jmi_t* jmi, jmi_real_t x_nominal[], size_t nx);

int jmi_event_iteration(jmi_t* jmi, jmi_boolean intermediate_results, jmi_event_info_t* event_info);
#endif
