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


/** \file jmi_block_solver.h
 *  \brief Equiation block solver interface.
 */

#ifndef _JMI_BLOCK_SOLVER_H
#define _JMI_BLOCK_SOLVER_H

#include "jmi_log.h"
typedef enum jmi_block_solver_residual_scaling_mode_t {
    jmi_residual_scaling_none = 0,
    jmi_residual_scaling_auto = 1,
    jmi_residual_scaling_manual = 2
} jmi_block_solver_residual_scaling_mode_t;

typedef enum jmi_block_solver_iv_scaling_mode_t {
    jmi_iter_var_scaling_none = 0,
    jmi_iter_var_scaling_nominal = 1,
    jmi_iter_var_scaling_heuristics = 2
} jmi_block_solver_iv_scaling_mode_t;

typedef enum jmi_block_solver_experimental_mode_t {
    jmi_block_solver_experimental_none = 0,
    jmi_block_solver_experimental_converge_switches_first = 1,
    jmi_block_solver_experimental_steepest_descent = 2,
    jmi_block_solver_experimental_steepest_descent_first = 4
} jmi_block_solver_experimental_mode_t;

/**< \brief Equation block solver options. */
typedef struct jmi_block_solver_options_t {
    double tolerance;                 /**< \brief Tolerance for the equation block solver */
    int max_iter;                     /**< \brief Maximum number of iterations for the equation block solver before failure */
    int log_level;                   /**< \brief Log level for logging in the solver: jmi_log 0 - none, 1 - fatal error, 2 - error, 3 - warning, 4 - info, 5 -verbose, 6 - debug */

    int enforce_bounds_flag;                /**< \brief Enforce min-max bounds on variables in the equation blocks*/
    int use_jacobian_equilibration_flag;    /**< \brief If jacobian equlibration should be used in equation block solvers */
    int use_Brent_in_1d_flag;               /**< \brief If Brent search should be used to improve accuracy in solution of 1D non-linear equations */
    
    jmi_block_solver_residual_scaling_mode_t residual_equation_scaling_mode; /**< \brief Equations scaling mode in equation block solvers:0-no scaling,1-automatic scaling,2-manual scaling */
    jmi_block_solver_iv_scaling_mode_t iteration_variable_scaling_mode;    /**< \brief Iteration variables scaling mode in equation block solvers:
                                                                         0 - no scaling, 1 - scaling based on nominals only (default), 2 - utilize heuristict to guess nominal based on min,max,start, etc. */

    int rescale_each_step_flag;             /**< \brief If scaling should be updated at every step (only active if residual_equation_scaling_mode is not "none") */
    int rescale_after_singular_jac_flag;    /**< \brief If scaling should be updated after singular jac was detected (only active if residual_equation_scaling_mode is not "none") */

    int check_jac_cond_flag;     /**< \brief Flag if the solver should check Jacobian condition number and log it. */

    int experimental_mode;         /**< \brief  Activate experimental features of equation block solvers. Combination of jmi_block_solver_experimental_mode_t flags. */
} jmi_block_solver_options_t;

/**
    \brief Main data structure used in the block solver.
*/
typedef struct jmi_block_solver_t jmi_block_solver_t;
struct jmi_block_solver_t {
    void* problem_data; /**< \brief External problem data pointer. Can be used by the problem code. */
} ;

int jmi_block_solver_init(jmi_block_solver_t* solver);


#endif /* _JMI_COMMON_H */
