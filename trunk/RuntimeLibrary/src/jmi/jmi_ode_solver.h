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
#include "jmi_log.h"


/**
 * \brief A ode solver function signature.
 *
 * @param block A jmi_block_residual_t struct.
 * @return Error code.
 */
typedef int (*jmi_ode_solve_func_t)(jmi_ode_solver_t* block, jmi_real_t time_final, int initialize);

/**
 * \brief A ode solver destructor signature.
 *
 * @param block A jmi_ode_solver_t struct.
  */
typedef void (*jmi_ode_delete_func_t)(jmi_ode_solver_t* block);

/**
 * \brief An ode right-hand-side signature.
 *
 * @param block A rhs_func_t struct.
  */
typedef int (*rhs_func_t)(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t* y, jmi_real_t* rhs);

/**
 * \brief An ode root-function signature.
 *
 * @param block A root_func_t struct.
  */
typedef int (*root_func_t)(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t *y, jmi_real_t *root);

/**
 * \brief An ode complete-step-function signature.
 *
 * @param block A complete_step_func_t struct.
  */
typedef int (*complete_step_func_t)(jmi_ode_problem_t* ode_problem, char* step_event);

struct jmi_ode_solver_t {
    jmi_ode_problem_t* ode_problem;                    /**< \brief A pointer to the corresponding jmi_ode_problem_t struct */

    void *integrator;
    jmi_real_t step_size;
    jmi_real_t rel_tol;
    jmi_real_t* nominal;
    jmi_ode_solve_func_t solve;
    jmi_ode_delete_func_t delete_solver;
};

struct jmi_ode_problem_t {
    void*                 fmix_me;              /**< \brief Reference to a fmix_me instance. */
    jmi_ode_solver_t*     ode_solver;           /**< \brief Struct containing the ODE solver. */
    jmi_log_t*            log;                  /**< \brief A pointer to the corresponding log_t struct */
    
    rhs_func_t            rhs_func;             /**< \brief A callback function for the rhs of the ODE problem. */
    root_func_t           root_func;            /**< \brief A callback function for the root of the ODE problem. */
    complete_step_func_t  complete_step_func;   /**< \brief A callback function for completing the step, checks for step-events. */
    
    BOOL                  logging_on;           /**< \brief The logging on / off attribute. */
    int                   n_real_x;
    int                   n_real_u;
    int                   n_sw;
    jmi_real_t            time;
    jmi_real_t*           states;
    jmi_real_t*           states_derivative;
    jmi_real_t*           event_indicators;
    jmi_real_t*           event_indicators_previous;
    void*                 inputs;
};

int jmi_new_ode_solver(jmi_ode_problem_t* problem, jmi_ode_method_t method, jmi_real_t step_size, jmi_real_t rel_tol, jmi_real_t* nominal);
void jmi_delete_ode_solver(jmi_ode_problem_t* problem);

#endif
