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

#ifndef JMI_CS_H
#define JMI_CS_H

#include "jmi.h"
#include "jmi_ode_problem.h"
#include "jmi_me.h"

#define JMI_CS_MAX_INPUT_DERIVATIVES 3

struct jmi_cs_real_input_t {
    jmi_value_reference vr;         /**< \brief Valuereference of the real input*/
    jmi_real_t tn;                  /**< \brief Time when the input was specified. */
    jmi_real_t value;
    jmi_boolean active;
    jmi_real_t input_derivatives[JMI_CS_MAX_INPUT_DERIVATIVES];
    jmi_real_t input_derivatives_factor[JMI_CS_MAX_INPUT_DERIVATIVES];
};

int jmi_cs_set_real_input_derivatives(jmi_ode_problem_t* ode_problem, 
        const jmi_value_reference vr[], size_t nvr, const int order[],
        const jmi_real_t value[]);
        
int jmi_cs_init_real_input_struct(jmi_cs_real_input_t* real_input);

/**
 * \brief Checks if the user is changing the values of any discrete inputs.
 * 
 * @param jmi The jmi_t struct.
 * @param vr The value references of values the user is setting.
 * @param nvr The number of value references.
 * @param value The new values for variables.
 * @return True if the input would result in changes of discrete inputs sent to
 * a fmiX_set_XXX function.
 */
int jmi_cs_check_discrete_input_change(jmi_t*                       jmi,
                                       const jmi_value_reference    vr[],
                                       size_t                       nvr,
                                       const void*                  value);

#endif /* JMI_CS_H */
