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



/** \file jmi_opt_sim.h
 *  \brief An interface to an NLP resulting from discretization of a dynamic
 *  optimization problem by means of a simultaneous method.
 **/

/**
 * \defgroup jmi_opt_sim JMI Simultaneous Optimization interface
 *
 * \brief The JMI Simultaneous optimization interface provides an NLP interface
 * for a dynamic optimization problem transcribed using a simultaneous method.
 *
 * The NLP has the form
 *
 * \f$
 *   \min f(x)
 * \f$
 *
 *   subject to
 *
 * \f$ g(x) \leq 0\f$<br>
 * \f$  h(x) = 0 \f$
 *
 * where \f$x\in R^{n_x}\f$, \f$g\in n_g\f$ and \f$h \in n_h\f$. The interface
 * also supports evaluation of Jacobians of \f$f\f$, \f$g\f$, and \f$h\f$ as
 * well as parsity patterns for \f$g\f$ and \f$h\f$.
 *
 * The method of transcription is not specified by the interface. Rather, such
 * a method is specified by the call-back functions in the struct jmi_opt_sim_t.
 * This design enables different methods to be implemented and accessed in a
 * unified way.
 *
 * The main data structure of the JMI Simultaneous Optimization interface is
 * jmi_opt_sim_t. In this struct, pointers to the call-back functions for
 * evaluation of the functions \f$f\f$, \f$g\f$, and \f$h\f$, and their
 * derivatives, as well as for accessing sparsity information. Notice that the
 * content of the vector \f$x\f$ is specific for a particular transcription
 * method. A jmi_opt_sim_t struct is typically created by a corresponding
 * create-function that is implemented by a particular implementation of a
 * transcription method.
 *
 */

/* @{ */
#ifndef _JMI_OPT_SIM_H
#define _JMI_OPT_SIM_H

#include "jmi.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \defgroup jmi_opt_sim_typedefs Typedefs
 * \brief Typedefs for data stuctures and call-back function pointers.
 */
/* @{ */

typedef struct jmi_opt_sim_t jmi_opt_sim_t;

// Function typedefs
typedef int (*jmi_opt_sim_get_dimensions_t)(jmi_opt_sim_t *jmi_opt_sim, int *n_x, int *n_g, int *n_h,
		int *dg_n_nz, int *dh_n_nz);

typedef int (*jmi_opt_sim_get_interval_spec_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *startTime, int *startTimeFree,
		jmi_real_t *finalTime, int *finalTimeFree);

typedef int (*jmi_opt_sim_f_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *f);

typedef int (*jmi_opt_sim_df_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *df);

typedef int (*jmi_opt_sim_h_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res);

typedef int (*jmi_opt_sim_dh_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac);

typedef int (*jmi_opt_sim_g_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res);

typedef int (*jmi_opt_sim_dg_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac);

typedef int (*jmi_opt_sim_get_bounds_t)(jmi_opt_sim_t *jmi_opt_sim,
		jmi_real_t *x_lb, jmi_real_t *x_ub);

typedef int (*jmi_opt_sim_get_initial_t)(jmi_opt_sim_t *jmi_opt_sim,
		jmi_real_t *x_init);

typedef int (*jmi_opt_sim_h_nz_indices_t)(jmi_opt_sim_t *jmi_opt_sim,
		int *colIndex, int *rowIndex);

typedef int (*jmi_opt_sim_g_nz_indices_t)(jmi_opt_sim_t *jmi_opt_sim,
		int *colIndex, int *rowIndex);

typedef int (*jmi_opt_sim_write_file_matlab_t)(jmi_opt_sim_t *jmi_opt_sim,
		const char *file_name);

typedef int (*jmi_opt_sim_get_result_variable_vector_length_t)(jmi_opt_sim_t
		*jmi_opt_sim, int *n);

typedef int (*jmi_opt_sim_get_result_t)(jmi_opt_sim_t *jmi_opt_sim,
		jmi_real_t *p_opt, jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x,
		jmi_real_t *u, jmi_real_t *w);

/* @} */

/**
 * \defgroup jmi_opt_sim_t The jmi_opt_sim_t struct, setters and getters.
 * \brief Documentation of the jmi_opt_sim_t struct and it setters and getters.
 */
/* @{ */

/**
 * jmi_opt_sim_get_dimenstions returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */
int jmi_opt_sim_get_dimensions(jmi_opt_sim_t *jmi_opt_sim, int *n_x, int *n_g, int *n_h,
		int *dg_n_nz, int *dh_n_nz);

/**
 * jmi_opt_sim_get_interval_spec returns data that specifies the optimization interval.
 */
int jmi_opt_sim_get_interval_spec(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *start_time, int *start_time_free,
		jmi_real_t *final_time, int *final_time_free);

/**
 * Get the x vector.
 */
jmi_real_t* jmi_opt_sim_get_x(jmi_opt_sim_t *jmi_opt_sim);

/**
 * jmi_opt_sim_get_initial returns the initial point.
 */
int jmi_opt_sim_get_initial(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_init);


/**
 * \brief The main struct in the jmi_opt_sim interface is jmi_opt_sim_t.
 *
 * This struct contains a pointer to a jmi_t struct, dimension information of
 * the NLP, and variable vectors.
 */
struct jmi_opt_sim_t{
	jmi_t *jmi;                      // jmi_t struct
	int n_x;                         // Number of variables
	int n_e;                         // Number of elements in mesh
	jmi_real_t *hs;                    // Normalized element lengths in mesh (sum(h[i]=1)
	int hs_free;                      // Free element lengths
	int *tp_e;                         // Element indices for time points
	jmi_real_t* tp_tau;                       // Taus for time points within elements
	jmi_real_t *x;                    // x vector.
	jmi_real_t *x_lb;                 // Lower bounds for variables
	jmi_real_t *x_ub;                 // Upper bound for variables
	jmi_real_t *x_init;               // Initial starting point
	int dg_n_nz;
	int dh_n_nz;
	int *dg_row;
	int *dg_col;
	int *dh_row;
	int *dh_col;
	jmi_opt_sim_get_dimensions_t get_dimensions;
	jmi_opt_sim_get_interval_spec_t get_interval_spec;
	jmi_opt_sim_f_t f;
	jmi_opt_sim_df_t df;
	jmi_opt_sim_h_t h;
	jmi_opt_sim_dh_t dh;
	jmi_opt_sim_g_t g;
	jmi_opt_sim_dg_t dg;
	int n_g;                          // Number of inequality constraints
	int n_h;                          // Number of equality constraints
	jmi_opt_sim_get_bounds_t get_bounds;
	jmi_opt_sim_get_initial_t get_initial;
	jmi_opt_sim_g_nz_indices_t dg_nz_indices;
	jmi_opt_sim_h_nz_indices_t dh_nz_indices;
	jmi_opt_sim_write_file_matlab_t write_file_matlab;
	jmi_opt_sim_get_result_variable_vector_length_t get_result_variable_vector_length;
	jmi_opt_sim_get_result_t get_result;
};

/**
 * jmi_opt_sim_get_bounds returns the upper and lower bounds on the optimization variables.
 */
int jmi_opt_sim_get_bounds(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_lb, jmi_real_t *x_ub);


/* @} */

/**
 * \defgroup jmi_opt_sim_eval_functions Evaluation of NLP functions.
 * \brief Functions for evaluation of \f$f\f$, \f$g\f$, and \f$h\f$.
 */
/* @{ */

/**
 * jmi_opt_sim_f returns the cost function value at a given point in search space.
 */
int jmi_opt_sim_f(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *f);

/**
 * jmi_opt_sim_df returns the gradient of the cost function value at
 * a given point in search space.
 */
int jmi_opt_sim_df(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *df);

/**
 * jmi_opt_sim_g returns the residual of the inequality constraints h
 */
int jmi_opt_sim_g(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res);

/**
 * jmi_opt_sim_dg returns the Jacobian of the residual of the
 * inequality constraints.
 */
int jmi_opt_sim_dg(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac);

/**
 * jmi_opt_sim_g_nz_indices returns the indices of the non-zeros in the
 * inequality constraint Jacobian.
 */
int jmi_opt_sim_dg_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol);

/**
 * jmi_opt_sim_h returns the residual of the equality constraints h
 */
int jmi_opt_sim_h(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res);

/**
 * jmi_opt_sim_dh returns the Jacobian of the residual of the
 * equality constraints.
 */
int jmi_opt_sim_dh(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac);

/**
 * jmi_opt_sim_h_nz_indices returns the indices of the non-zeros in the
 * equality constraint Jacobian.
 */
int jmi_opt_sim_dh_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol);


/* @} */

/**
 * \defgroup jmi_opt_sim_misc Miscanellous
 * \brief Miscanellous functions.
 */
/* @{ */


/**
 * Write the the optimization result to file in Matlab format.
 */
int jmi_opt_sim_write_file_matlab(jmi_opt_sim_t *jmi_opt_sim_t,
		const char *file_name);

/**
 * Get the length of the result variable vectors.
 */
int jmi_opt_sim_get_result_variable_vector_length(jmi_opt_sim_t
		*jmi_opt_sim, int *n);

/**
 * Get the results, stored in column major format.
 */
int jmi_opt_sim_get_result(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);

#ifdef __cplusplus
}
#endif


#endif /* JMI_OPT_SIM_H_ */

/* @} */
/* @} */
