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


/** \file jmi_block_solver_impl.h
 *  \brief Equation block solver private header.
 */

#ifndef _JMI_BLOCK_SOLVER_IMPL_H
#define _JMI_BLOCK_SOLVER_IMPL_H

#include "jmi_block_solver.h"
/**
    \brief Main data structure used in the block solver.
*/
struct jmi_block_solver_t {
    void* problem_data; /**< \brief External problem data pointer. Can be used by the problem code. */
    jmi_block_solver_options_t* options;
    jmi_callbacks_t* callbacks;
    jmi_log_t* log;
    int id ;

    int n;                         /**< \brief The number of iteration variables */
    jmi_real_t* x;                 /**< \brief Work vector for the real iteration variables */

    jmi_real_t* dx;                /**< \brief Work vector for the seed vector */

    jmi_real_t* res;               /**< \brief Work vector for the block residual */
    jmi_real_t* dres;              /**< \brief Work vector for the directional derivative that corresponds to dx */
    jmi_real_t* jac;               /**< \brief Work vector for the block Jacobian */
    int* ipiv;                     /**< \brief Work vector needed for dgesv */

    jmi_real_t* min;               /**< \brief Min values for iteration variables */
    jmi_real_t* max;               /**< \brief Max values for iteration variables */
    jmi_real_t* nominal;           /**< \brief Nominal values for iteration variables */
    jmi_real_t* initial;           /**< \brief Initial values for iteration variables */
    
    int jacobian_variability;      /**< \brief Variability of Jacobian coefficients: JMI_CONSTANT_VARIABILITY
                                         JMI_PARAMETER_VARIABILITY, JMI_DISCRETE_VARIABILITY, JMI_CONTINUOUS_VARIABILITY */

    int* value_references; /**< \brief Iteration variable value references. **/

    double cur_time;        /**< \brief Current time send in jmi_block_solver_solve(). Used for logging and controling rescaling. */

    void * solver;
    jmi_block_solver_solve_func_t solve;
    jmi_block_solver_delete_func_t delete_solver;
    
    int init;              /**< \brief A flag for initialization */

    jmi_block_solver_residual_func_t F;
    jmi_block_solver_dir_der_func_t dF;
    jmi_block_solver_check_discrete_variables_change_func_t check_discrete_variables_change;
    jmi_block_solver_update_discrete_variables_func_t update_discrete_variables;
    jmi_block_solver_log_discrete_variables log_discrete_variables;

    long int nb_calls;                    /**< \brief Nb of times the block has been solved */
    long int nb_iters;                     /**< \breif Total nb if iterations of non-linear solver */
    long int nb_jevals ;
    long int nb_fevals;
    double time_spent;             /**< \brief Total time spent in non-linear solver */
    char* message_buffer ; /**< \brief Message buffer used for debugging purposes */

} ;

/* Lapack function */
extern double dnrm2_(int* N, double* X, int* INCX);
extern void dgesv_(int* N, int* NRHS, double* A, int* LDA, int* IPIV,
                double* B, int* LDB, int* INFO );

#endif /* _JMI_BLOCK_SOLVER_H */
