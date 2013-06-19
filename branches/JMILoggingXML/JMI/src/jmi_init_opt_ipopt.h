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

/** \file jmi_init_opt_ipopt.h
 *  \brief An interface between the NLP representation provided by jmi_init_opt_t
 *  and IPOPT.
 **/

#ifndef _JMI_INIT_OPT_IPOPT_H
#define _JMI_INIT_OPT_IPOPT_H

#include "jmi.h"
#include "jmi_init_opt.h"

#ifdef __cplusplus
extern "C" {
#endif


/**
 * \defgroup jmi_init_opt_ipopt Ipopt interface to the optimization-based DAE optimization algorithm
 * \brief Documentation of the Ipopt interface the optimization-based DAE optimization algorithm.
 *
 */
/* @{ */


/**
 * \brief Struct containing a pointer to a jmi_TNLP object which represents
 * the Ipopt NLP.
 */
typedef struct jmi_init_opt_ipopt_t jmi_init_opt_ipopt_t;

/**
 * \brief Create a new instance of a jmi_init_opt_ipopt_t struct.
 *
 * @param jmi_init_opt_ipopt (Output) The new struct.
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @return Error code.
 */
int jmi_init_opt_ipopt_new(jmi_init_opt_ipopt_t **jmi_init_opt_ipopt, jmi_init_opt_t *jmi_init_opt);

//int jmi_init_opt_ipopt_set_initial_point(jmi_init_opt_ipopt_t *jmi_init_opt_ipopt, jmi_real_t *x_init);

/**
 * \brief Solve the NLP problem.
 *
 * @param jmi_init_opt_ipopt A jmi_init_opt_ipopt_t struct.
 * @return Error code.
 */
int jmi_init_opt_ipopt_solve(jmi_init_opt_ipopt_t *jmi_init_opt_ipopt);

/**
 * \brief Set Ipopt string option.
 *
 *  @param jmi_init_opt_ipopt A jmi_init_opt_ipopt_t struct.
 *  @param key The name of the option.
 *  @param val The value of the option.
 *  @return Error code.
 */
int jmi_init_opt_ipopt_set_string_option(jmi_init_opt_ipopt_t *jmi_init_opt_ipopt, char* key, char* val);

/**
 * \brief Set Ipopt integer option.
 *
 *  @param jmi_init_opt_ipopt A jmi_init_opt_ipopt_t struct.
 *  @param key The name of the option.
 *  @param val The value of the option.
 *  @return Error code.
 */
int jmi_init_opt_ipopt_set_int_option(jmi_init_opt_ipopt_t *jmi_init_opt_ipopt, char* key, int val);

/**
 * \brief Set Ipopt double option.
 *
 *  @param jmi_init_opt_ipopt A jmi_init_opt_ipopt_t struct.
 *  @param key The name of the option.
 *  @param val The value of the option.
 *  @return Error code.
 */
int jmi_init_opt_ipopt_set_num_option(jmi_init_opt_ipopt_t *jmi_init_opt_ipopt, char* key, double val);

/**
 * \brief Get statistics from the last optimization run.
 *
 * @param jmi_init_opt_ipopt A jmi_init_opt_ipopt_t struct.
 * @param return_status Return status from IPOPT (Output)
 * @param nbr_iter Number of iterations (Output)
 * @param objective Final value of objective function (Output)
 * @param total_exec_time Execution time (Output)
 * @return Error code.
 */
int jmi_init_opt_ipopt_get_statistics(jmi_init_opt_ipopt_t* jmi_init_opt_ipopt,
        int* return_status, int* nbr_iter, jmi_real_t* objective,
        jmi_real_t* total_exec_time);

/* @} */

#ifdef __cplusplus
}
#endif

#endif /* _JMI_OPT_SIM_IPOPT_H */
