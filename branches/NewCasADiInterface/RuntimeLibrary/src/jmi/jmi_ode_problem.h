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


/** \file jmi_ode_problem.h
 *  \brief Structures and functions for handling an ODE problem.
 */

#ifndef _JMI_ODE_PROBLEM_H
#define _JMI_ODE_PROBLEM_H

#include "jmi.h"
#include "jmi_log.h"
#include "jmi_cs.h"
#include "jmi_ode_solver.h"


/**
 * \brief An ode right-hand-side signature.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param t The ODE time.
 * @param y A pointer to the states of the ODE.
 * @param rhs A pointer to the state derivatives of the ODE.
 * @return Error code.
  */
typedef int (*rhs_func_t)(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t* y, jmi_real_t* rhs);

/**
 * \brief An ode root-function signature.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param t The ODE time.
 * @param y A pointer to the states of the ODE.
 * @param root A pointer to an evaluation of the event indicator of the ODE.
 * @return Error code.
  */
typedef int (*root_func_t)(jmi_ode_problem_t* ode_problem, jmi_real_t t, jmi_real_t *y, jmi_real_t *root);

/**
 * \brief An ode complete-step-function signature.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param step_event An indicator of whether a step event has occured or not.
 * @return Error code.
  */
typedef int (*complete_step_func_t)(jmi_ode_problem_t* ode_problem, char* step_event);

struct jmi_ode_problem_t {
    jmi_callbacks_t*      jmi_callbacks;
    void*                 fmix_me;                     /**< \brief Reference to a fmix_me instance. */
    jmi_ode_solver_t*     ode_solver;                  /**< \brief Struct containing the ODE solver. */
    jmi_log_t*            log;                         /**< \brief A pointer to the corresponding log_t struct */
    
    rhs_func_t            rhs_func;                    /**< \brief A callback function for the rhs of the ODE problem. */
    root_func_t           root_func;                   /**< \brief A callback function for the root of the ODE problem. */
    complete_step_func_t  complete_step_func;          /**< \brief A callback function for completing the step, checks for step-events. */
    
    int                   n_real_x;                    /**< \brief Number of differentiated states. */
    int                   n_real_u;                    /**< \brief Number of inputs. */
    int                   n_sw;                        /**< \brief Number of switching functions. */
    jmi_real_t            time;                        /**< \brief The time, independent variable of the ODE. */
    jmi_real_t*           states;                      /**< \brief The states of the ODE. */
    jmi_real_t*           states_derivative;           /**< \brief The state derivatives of the ODE. */
    jmi_real_t*           nominal;                     /**< \brief The nominals for the states. */
    jmi_real_t*           event_indicators;            /**< \brief The evaluated event indicators at the current time. */
    jmi_real_t*           event_indicators_previous;   /**< \brief The evaluated event indicators at the previous time. */
    jmi_cs_input_t*       inputs;                      /**< \brief The inputs to the ODE. */
};

/**
 * \brief Creates a new jmi_ode_problem_t instance.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param cb A jmi_callbacks_t pointer.
 * @param fmix_me A pointer to a FMI ME struct. 
 * @param n_real_x The number of continuous states.
 * @param n_sw The number of switches.
 * @param n_real_u The number of inputs.
 * @param log A pointer to a log struct.
 * @return Error code.
  */
int jmi_new_ode_problem(jmi_ode_problem_t** ode_problem, jmi_callbacks_t* cb, void* fmix_me, int n_real_x, int n_sw, int n_real_u, jmi_log_t* log);

/**
 * \brief Initializes the jmi_ode_problem_t instance.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param t_start The starting time.
 * @param rhs_func A callback function for the rhs of the ODE problem.
 * @param root_func A callback function for the root of the ODE problem.
 * @param complete_step_func A callback function for completing the step, checks for step-events.
 * @return Error code.
  */
int jmi_init_ode_problem(jmi_ode_problem_t* problem, jmi_real_t t_start,
                         rhs_func_t rhs_func, root_func_t root_func, 
                         complete_step_func_t complete_step_func);

/**
 * \brief Deletes the jmi_ode_problem_t instance.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
  */
void jmi_free_ode_problem(jmi_ode_problem_t* problem);

#endif
