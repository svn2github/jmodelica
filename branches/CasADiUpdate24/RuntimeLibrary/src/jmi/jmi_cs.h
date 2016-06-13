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

#ifndef jmi_cs_h
#define jmi_cs_h

#include "jmi.h"
#include "jmi_ode_problem.h"
#include "jmi_me.h"

#define JMI_CS_MAX_INPUT_DERIVATIVES 3

struct jmi_cs_input_t {
    jmi_value_reference vr;         /**< \brief Valuereference of the input, note only reals */
    jmi_real_t tn;                   /**< \brief Time when the input was specified. */
    jmi_real_t input;
    jmi_boolean active;
    jmi_real_t input_derivatives[JMI_CS_MAX_INPUT_DERIVATIVES];
    jmi_real_t input_derivatives_factor[JMI_CS_MAX_INPUT_DERIVATIVES];
};



int jmi_cs_set_real_input_derivatives(jmi_ode_problem_t* ode_problem, 
        const jmi_value_reference vr[], size_t nvr, const int order[],
        const jmi_real_t value[]);
        
int jmi_cs_init_input_struct(jmi_cs_input_t* value);
#endif
