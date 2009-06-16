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

/** \file jmi_opt_sim_ipopt.h
 *  \brief An interface between the NLP representation provided by jmi_opt_sim_t
 *  and IPOPT.
 **/

#ifndef _JMI_OPT_SIM_IPOPT_H
#define _JMI_OPT_SIM_IPOPT_H

#include "jmi.h"
#include "jmi_opt_sim.h"

#ifdef __cplusplus
extern "C" {
#endif


/**
 * \defgroup jmi_opt_sim_ipopt Ipopt interface to the JMI simultaneous optimization interface
 * \brief Documentation of the Ipopt interface to the JMI simultaneous optimization interface.
 *
 */
/* @{ */


/**
 * \brief Struct containing a pointer to a jmi_TNLP object which represents
 * the Ipopt NLP.
 */
typedef struct jmi_opt_sim_ipopt_t jmi_opt_sim_ipopt_t;

/**
 * \brief Create a new instance of a jmi_opt_sim_ipopt_t struct.
 *
 * @param jmi_opt_sim_ipopt (Output) The new struct.
 * @param jmi_opt_sim A jmi_opt_sim_t struct.
 * @return Error code.
 */
int jmi_opt_sim_ipopt_new(jmi_opt_sim_ipopt_t **jmi_opt_sim_ipopt, jmi_opt_sim_t *jmi_opt_sim);

//int jmi_opt_sim_ipopt_set_initial_point(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, jmi_real_t *x_init);

/**
 * \brief Solve the NLP problem.
 *
 * @param jmi_opt_sim_ipopt A jmi_opt_sim_ipopt_t struct.
 * @return Error code.
 */
int jmi_opt_sim_ipopt_solve(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt);

/**
 * \brief Set Ipopt string option.
 *
 *  @param jmi_opt_sim_ipopt A jmi_opt_sim_ipopt_t struct.
 *  @param key The name of the option.
 *  @param val The value of the option.
 *  @return Error code.
 */
int jmi_opt_sim_ipopt_set_string_option(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, char* key, char* val);

/**
 * \brief Set Ipopt integer option.
 *
 *  @param jmi_opt_sim_ipopt A jmi_opt_sim_ipopt_t struct.
 *  @param key The name of the option.
 *  @param val The value of the option.
 *  @return Error code.
 */
int jmi_opt_sim_ipopt_set_int_option(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, char* key, int val);

/**
 * \brief Set Ipopt double option.
 *
 *  @param jmi_opt_sim_ipopt A jmi_opt_sim_ipopt_t struct.
 *  @param key The name of the option.
 *  @param val The value of the option.
 *  @return Error code.
 */
int jmi_opt_sim_ipopt_set_num_option(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, char* key, double val);

/* @} */

#ifdef __cplusplus
}
#endif

#endif /* _JMI_OPT_SIM_IPOPT_H */
