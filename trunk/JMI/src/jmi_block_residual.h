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


/** \file jmi_block_residual.h
 *  \brief Structures and functions for handling equation blocks.
 */

#ifndef _JMI_BLOCK_RESIDUAL_H
#define _JMI_BLOCK_RESIDUAL_H

#include "jmi_common.h"

#ifdef JMI_AD_NONE_AND_CPP
extern "C" {
#endif /* JMI_AD_NONE_AND_CPP */

/* Lapack function */
extern void dgesv_(int* N, int* NRHS, double* A, int* LDA, int* IPIV,
                double* B, int* LDB, int* INFO );

extern double dnrm2_(int* N, double* X, int* INCX);

/**
 * \brief Function signature for evaluation of a equation block residual
 * function in the generated code.
 *
 * @param jmi A jmi_t struct.
 * @param x (Input/Output) The iteration variable vector. If the init argument is
 * set to JMI_BLOCK_INITIALIZE then x is an output argument that holds the
 * initial values. If init is set to JMI_BLOCK_EVALUATE, then x is an input
 * argument used in the evaluation of the residual.
 * @param residual (Output) The residual vector if init is set to
 * JMI_BLOCK_EVALUATE, otherwise this argument is not used.
 * @param init Set to either JMI_BLOCK_INITIALIZE or JMI_BLOCK_EVALUATE.
 * @return Error code.
 */
typedef int (*jmi_block_residual_func_t)(jmi_t* jmi, jmi_real_t* x,
		jmi_real_t* residual, int init);
		
/**
 * \brief Function signature for evaluation of a directional derivatives for a
 * block function in the generated code.
 *
 * @param jmi A jmi_t struct.
 * @param x (Input/Output) The iteration variable vector. If the init argument is
 * set to JMI_BLOCK_INITIALIZE then x is an output argument that holds the
 * initial values. If init is set to JMI_BLOCK_EVALUATE, then x is an input
 * argument used in the evaluation of the residual.
 * @param dx (input) The seed vector that is used if init is set to JMI_BLOCK_EVALUATE
 * @param dRes (output) the directional derivative if init is set to JMI_BLOCK_EVALUATE
 * @param residual (Output) The residual vector if init is set to
 * JMI_BLOCK_EVALUATE, otherwise this argument is not used.
 * @param init Set to either JMI_BLOCK_INITIALIZE or JMI_BLOCK_EVALUATE.
 * @return Error code.
 */
typedef int (*jmi_block_dir_der_func_t)(jmi_t* jmi, jmi_real_t* x,
		 jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int init);

/**
 * \brief A equation block solver function signature.
 *
 * @param block A jmi_block_residual_t struct.
 * @return Error code.
 */
typedef int (*jmi_block_residual_solve_func_t)(jmi_block_residual_t* block);

/**
 * \brief Compute the block Jacobian for the solver
 *
 * @param block A jmi_block_residual_t struct.
 * @param jacobian A vector that upon function exit contains the Jacobian in column major form.
 * @return Error code.
 */
typedef int (*jmi_block_residual_jacobian_func_t)(jmi_block_residual_t* block, jmi_real_t* jacobian);

/**
 * \brief Compute the LU factorization of the block Jacobian for the solver
 *
 * @param block A jmi_block_residual_t struct.
 * @param jacobian A vector that upon function exit contains the LU factorization of the Jacobian in column major form.
 * @return Error code.
 */
typedef int (*jmi_block_residual_jacobian_factorization_func_t)(jmi_block_residual_t* block, jmi_real_t* factorization);

/**
 * \brief A equation block solver destructor signature.
 *
 * @param block A jmi_block_residual_t struct.
  */
typedef void (*jmi_block_residual_delete_func_t)(jmi_block_residual_t* block);

struct jmi_block_residual_t {
	jmi_t *jmi;                    /**< \brief A pointer to the corresponding jmi_t struct */
	jmi_block_residual_func_t F;   /**< \brief A function pointer to the block residual function */
	jmi_block_dir_der_func_t dF;   /**< \brief A function pointer to the block AD-function */
	int n;                         /**< \brief The number of real unknowns in the equation system */
	int n_nr;                         /**< \brief The number of non-real unknowns in the equation system */
	jmi_real_t* x;                 /**< \brief Work vector for the real iteration variables */
	jmi_real_t* x_nr;                 /**< \brief Work vector for the non-real iteration variables */
	jmi_real_t* dx;				   /**< \brief Work vector for the seed vector */
	jmi_real_t* dv;					/**< \brief Work vector for (dF/dv)*dv */
    int index ;

    jmi_real_t* res;               /**< \brief Work vector for the block residual */
    jmi_real_t* dres;			   /**< \brief Work vector for the directional derivative that corresponds to dx */
    jmi_real_t* jac;               /**< \brief Work vector for the block Jacobian */
    int* ipiv;                     /**< \brief Work vector needed for dgesv */

    jmi_real_t* min;               /**< \brief Min values for iteration variables */
    jmi_real_t* max;               /**< \brief Max values for iteration variables */
    jmi_real_t* nominal;           /**< \brief Nominal values for iteration variables */
    jmi_real_t* initial;           /**< \brief Nominal values for iteration variables */
    
    int jacobian_variability;      /**< \brief Variability of Jacobian coefficients: JMI_CONSTANT_VARIABILITY
                                         JMI_PARAMETER_VARIABILITY, JMI_DISCRETE_VARIABILITY, JMI_CONTINUOUS_VARIABILITY */

    void * solver;
    jmi_block_residual_solve_func_t solve;
    jmi_block_residual_delete_func_t delete_solver;
    jmi_block_residual_jacobian_func_t evaluate_jacobian;
    jmi_block_residual_jacobian_factorization_func_t evaluate_jacobian_factorization;
    
    int init;			   /**< \brief A flag for initialization */
    
    long int nb_calls;                    /**< \brief Nb of times the block has been solved */
    long int nb_iters;                     /**< \breif Total nb if iterations of non-linear solver */
    long int nb_jevals ;
    long int nb_fevals;
    double time_spent;             /**< \brief Total time spent in non-linear solver */
	char* message_buffer ; /**< \brief Message buffer used for debugging purposes */
};

/**
 * \brief Register a block residual function in a jmi_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F A jmi_block_residual_func_t function
 * @param dF A jmi_block_dir_der_func_t function
 * @param n Integer size of the block of real variables
 * @param n_nr Integer size of the block of non-real variables
 * @param jacobian_variability Variability of the Jacobian coefficients
 * @param solver Solver to be used for the block
 * @param index Integer ID nbr of the block
 * @return Error code.
 */
int jmi_dae_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, jmi_block_solvers_t solver, int index);

/**
 * \brief Register an initialization block residual function in a jmi_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F A jmi_block_residual_func_t function
 * @param dF A jmi_block_dir_der_func_t function
 * @param n Integer size of the block of real variables
 * @param n_nr Integer size of the block of non-real variables
 * @param jacobian_variability Variability of the Jacobian coefficients
 * @param solver Solver to be used for the block
 * @param index Integer ID nbr of the block
 * @return Error code.
 */
int jmi_dae_init_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, jmi_block_solvers_t solver, int index);


/**
 * \brief Allocates a jmi_block_residual struct.
 * 
 * @param b A jmi_block_residual_t struct (Output)
 * @param jmi A jmi_t struct.
 * @param solver Kind of solver to use
 * @param F A jmi_block_residual_func_t function
 * @param dF A jmi_block_dir_der_func_t function 
 * @param n Integer size of the block of real variables
 * @param n_nr Integer size of the block of non-real variables
 * @param jacobian_variability Variability of the Jacobian coefficients
 * @param index Integer ID nbr of the block
 * @return Error code.
 */
int jmi_new_block_residual(jmi_block_residual_t** b,jmi_t* jmi, jmi_block_solvers_t solver,
                           jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, int index);
                           
int jmi_solve_block_residual(jmi_block_residual_t * block);


int jmi_block_jacobian_fd(jmi_block_residual_t* b, jmi_real_t* x, jmi_real_t delta_rel, jmi_real_t delta_abs);

/**
 * \brief Deletes a jmi_block_residual struct.
 * 
 * @param b A jmi_block_residual_t struct.
 * @return Error code.
 */
int jmi_delete_block_residual(jmi_block_residual_t* b);

/**
 * \brief Calculate directional derivatives for a equation block.
 *
 * The function expects the block to be already solved and uses current solution
 *  for derivatives calculation.
 *
 * @param jmi A jmi_t struct.
 * @param current_block An equation block to process.
 * @return Error code.
 */
int jmi_ode_unsolved_block_dir_der(jmi_t *jmi, jmi_block_residual_t *current_block);

#ifdef JMI_AD_NONE_AND_CPP
}
#endif /* JMI_AD_NONE_AND_CPP */
#endif /* _JMI_COMMON_H */
