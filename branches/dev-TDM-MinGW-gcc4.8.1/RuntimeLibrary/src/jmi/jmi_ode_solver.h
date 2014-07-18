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

#include "jmi_util.h"
#include "jmi_ode_problem.h"
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



struct jmi_ode_solver_t {
    jmi_ode_problem_t* ode_problem;                    /**< \brief A pointer to the corresponding jmi_ode_problem_t struct */

    void *integrator;
    jmi_real_t step_size;
    jmi_real_t rel_tol;
    jmi_ode_solve_func_t solve;
    jmi_ode_delete_func_t delete_solver;
};

/**
 * \brief Creates a new jmi_ode_solver_t instance.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param method A jmi_ode_method_t struct. 
 * @param step_size The step size for the mehtod.
 * @param rel_tol The relative tolerance for the method.
 * @return Error code.
  */
int jmi_new_ode_solver(jmi_ode_problem_t* problem, jmi_ode_method_t method, jmi_real_t step_size, jmi_real_t rel_tol);

/**
 * \brief Deletes the jmi_ode_solver_t instance.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
  */
void jmi_delete_ode_solver(jmi_ode_problem_t* problem);

#endif
