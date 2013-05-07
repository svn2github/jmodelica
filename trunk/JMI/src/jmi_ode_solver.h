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


/** \file jmi_ode_solver.h
 *  \brief Structures and functions for handling an ODE solver.
 */

#ifndef _JMI_ODE_SOLVER_H
#define _JMI_ODE_SOLVER_H

#include "jmi_common.h"
#include "jmi.h"
#include "jmi_util.h"

#ifdef __cplusplus
extern "C" {
#endif



/**
 * \brief A ode solver function signature.
 *
 * @param block A jmi_block_residual_t struct.
 * @return Error code.
 */
typedef int (*jmi_ode_solve_func_t)(jmi_ode_solver_t* block, jmi_real_t t_stop, int initialize);

/**
 * \brief A ode solver destructor signature.
 *
 * @param block A jmi_ode_solver_t struct.
  */
typedef void (*jmi_ode_delete_func_t)(jmi_ode_solver_t* block);

typedef int (*jmi_ode_rhs_func_t)(void *, jmi_real_t t, jmi_real_t* y, jmi_real_t* rhs);
typedef int (*jmi_ode_root_func_t)(void *, jmi_real_t t, jmi_real_t* y, jmi_real_t* root);

struct jmi_ode_solver_t {
    jmi_t *jmi;                    /**< \brief A pointer to the corresponding jmi_t struct */
    void *user_data;
    
    void *integrator;
    jmi_ode_solve_func_t solve;
    jmi_ode_delete_func_t delete_solver;
    jmi_ode_rhs_func_t rhs_fcn;
    jmi_ode_root_func_t root_fcn;
    jmi_real_t tout;  /**< \brief Value indicating which time the integrator integrated up to*/
    jmi_int_t n_real_x;
    jmi_int_t n_sw;
    jmi_real_t t_start;
};

int jmi_new_ode_solver(jmi_t* jmi, jmi_ode_solvers_t solver,jmi_ode_rhs_func_t rhs, jmi_ode_root_func_t root, jmi_int_t n_real_x, jmi_int_t n_sw, jmi_real_t t_start, void* user_data);
void jmi_delete_ode_solver(jmi_t* jmi);

#ifdef __cplusplus
}
#endif
#endif
