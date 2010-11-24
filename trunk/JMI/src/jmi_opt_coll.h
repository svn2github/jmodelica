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



/** \file jmi_opt_coll.h
 *  \brief An interface to an NLP resulting from discretization of a dynamic
 *  optimization problem by means of a simultaneous method.
 **/

/**
 * \defgroup jmi_opt_coll JMI Simultaneous Optimization interface
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
 * a method is specified by the call-back functions in the struct jmi_opt_coll_t.
 * This design enables different methods to be implemented and accessed in a
 * unified way.
 *
 * The main data structure of the JMI Simultaneous Optimization interface is
 * jmi_opt_coll_t. In this struct, pointers to the call-back functions for
 * evaluation of the functions \f$f\f$, \f$g\f$, and \f$h\f$, and their
 * derivatives, as well as for accessing sparsity information. Notice that the
 * content of the vector \f$x\f$ is specific for a particular transcription
 * method. A jmi_opt_coll_t struct is typically created by a corresponding
 * create-function that is implemented by a particular implementation of a
 * transcription method.
 *
 */

/* @{ */
#ifndef _JMI_OPT_COLL_H
#define _JMI_OPT_COLL_H

#include "jmi.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \defgroup jmi_opt_coll_typedefs Typedefs
 * \brief Typedefs for data stuctures and call-back function pointers.
 */
/* @{ */

typedef struct jmi_opt_coll_t jmi_opt_coll_t;

/* Function typedefs */
typedef int (*jmi_opt_coll_get_dimensions_t)(jmi_opt_coll_t *jmi_opt_coll, int *n_x, int *n_g, int *n_h,
		int *dg_n_nz, int *dh_n_nz);

typedef int (*jmi_opt_coll_get_interval_spec_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *startTime, int *startTimeFree,
		jmi_real_t *finalTime, int *finalTimeFree);

typedef int (*jmi_opt_coll_f_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *f);

typedef int (*jmi_opt_coll_df_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *df);

typedef int (*jmi_opt_coll_h_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res);

typedef int (*jmi_opt_coll_dh_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac);

typedef int (*jmi_opt_coll_g_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res);

typedef int (*jmi_opt_coll_dg_t)(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac);

typedef int (*jmi_opt_coll_get_bounds_t)(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *x_lb, jmi_real_t *x_ub);

typedef int (*jmi_opt_coll_set_bounds_t)(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *x_lb, jmi_real_t *x_ub);

typedef int (*jmi_opt_coll_get_initial_t)(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *x_init);

typedef int (*jmi_opt_coll_set_initial_t)(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *x_init);

typedef int (*jmi_opt_coll_set_initial_from_trajectory_t)(
		jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *p_opt_init, jmi_real_t *trajectory_data_init,
		int traj_n_points, jmi_real_t *hs_init, jmi_real_t start_time_init,
		jmi_real_t final_time_init);

typedef int (*jmi_opt_coll_h_nz_indices_t)(jmi_opt_coll_t *jmi_opt_coll,
		int *colIndex, int *rowIndex);

typedef int (*jmi_opt_coll_g_nz_indices_t)(jmi_opt_coll_t *jmi_opt_coll,
		int *colIndex, int *rowIndex);

typedef int (*jmi_opt_coll_write_file_matlab_t)(jmi_opt_coll_t *jmi_opt_coll,
		const char *file_name);

typedef int (*jmi_opt_coll_get_result_variable_vector_length_t)(jmi_opt_coll_t
		*jmi_opt_coll, int *n);

typedef int (*jmi_opt_coll_get_result_t)(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *p_opt, jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x,
		jmi_real_t *u, jmi_real_t *w);

typedef int (*jmi_opt_coll_get_result_mesh_interpolation_t)(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *mesh, int n_mesh, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);

typedef int (*jmi_opt_coll_get_result_element_interpolation_t)(jmi_opt_coll_t *jmi_opt_coll,
		int n_interpolation_points, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);

/* @} */

/**
 * \defgroup jmi_opt_coll_t The jmi_opt_coll_t struct, setters and getters.
 * \brief Documentation of the jmi_opt_coll_t struct and it setters and getters.
 */
/* @{ */

/**
 * \brief Get the number of variables and the number of
 * constraints, respectively, in the NLP problem.
 *
 * @param jmi_opt_coll_t A jmi_opt_coll_t struct.
 * @param n_x (Output) Number of variables in the NLP problem.
 * @param n_g (Output) Number of inequality constraints.
 * @param n_h (Output) Number of equality constraints.
 * @param dg_n_nz (Output) Number of non-zeros in the Jacobian of the inequality
 * constraints.
 * @param dh_n_nz (Output) Number of non-zeros in the Jacobian of the equality
 * constraints.
 */
int jmi_opt_coll_get_dimensions(jmi_opt_coll_t *jmi_opt_coll, int *n_x, int *n_g,
		int *n_h, int *dg_n_nz, int *dh_n_nz);

/**
 * \brief Retrieve data that specifies the optimization interval.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param start_time (Output) Optimization interval start time.
 * @param start_time_free (Output) 0 if the start time is fixed, otherwise 1.
 * @param final_time (Output) Optimization interval final time.
 * @param final_time_free (Output) 0 if the final time is fixed, otherwise 1.
 * \return Error code.
 */
int jmi_opt_coll_get_interval_spec(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *start_time, int *start_time_free,
		jmi_real_t *final_time, int *final_time_free);

/**
 * \brief Get the number of finite elements
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param n_e (Output) Number of elements.
 * \return Error code.
 */
int jmi_opt_coll_get_n_e(jmi_opt_coll_t *jmi_opt_coll,int *n_e);

/**
 * \brief Get the x vector of the NLP.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @return The x vector.
 */
jmi_real_t* jmi_opt_coll_get_x(jmi_opt_coll_t *jmi_opt_coll);

/**
 * \brief Get the initial point of the NLP.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param x_init (Output) the initial guess vector.
 * @return Error code.
 */
int jmi_opt_coll_get_initial(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *x_init);

/**
 * \brief Get blocking factors.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param blocking_factors (Output) A vector of blocking factors.
 * @return Error code.
 */
int jmi_opt_coll_get_blocking_factors(jmi_opt_coll_t *jmi_opt_coll, int *blocking_Factors);

/**
 * \brief Get number of blocking factors.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param n_blocking_factors (Output) Number of blocking factors.
 * @return Error code.
 */
int jmi_opt_coll_get_blocking_factors(jmi_opt_coll_t *jmi_opt_coll, int *n_blocking_Factors);

/**
 * \brief Set the initial point of the NLP.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param (Output) x_init The initial guess vector.
 * @return Error code.
 */
 int jmi_opt_coll_set_initial(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *x_init);

/**
 * \brief Set the initial point based on time series trajectories of the
 * variables of the problem.
 *
 * Also, initial guesses for the optimization interval and element lengths
 * are provided.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param p_opt_init A vector of size n_p_opt containing initial values for the
 * optimized parameters.
 * @param trajectory_data_init A matrix stored in column major format. The
 * first column contains the time vector. The following column contains, in
 * order, the derivative, state, input, and algebraic variable profiles.
 * @param traj_n_points Number of time points contained in the vector
   trajectory_data_init.
 * @param hs_init A vector of length n_e containing initial guesses of the
 * normalized lengths of the finite elements. This argument is neglected
 * if the problem does not have free element lengths.
 * @param start_time_init Initial guess of interval start time. This
 * argument is neglected if the start time is fixed.
 * @param final_time_init Initial guess of interval final time. This
 * argument is neglected if the final time is fixed.
 *
 */
int jmi_opt_coll_set_initial_from_trajectory(
		jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *p_opt_init, jmi_real_t *trajectory_data_init,
		int traj_n_points,jmi_real_t *hs_init, jmi_real_t start_time_init,
		jmi_real_t final_time_init);

/**
 * \brief The main struct in the jmi_opt_coll interface is jmi_opt_coll_t.
 *
 * This struct contains a pointer to a jmi_t struct, dimension information of
 * the NLP, and variable vectors.
 */
struct jmi_opt_coll_t{
	jmi_t *jmi;                        /* jmi_t struct */
	int n_x;                           /* Number of variables */
	int n_e;                           /* Number of elements in mesh */
	jmi_real_t *hs;                    /* Normalized element lengths in mesh (sum(h[i]=1) */
	int hs_free;                       /* Free element lengths */
	int *tp_e;                         /* Element indices for time points */
	jmi_real_t* tp_tau;                /* Taus for time points within elements */
	jmi_real_t *x;                     /* x vector. */
	jmi_real_t *x_lb;                  /* Lower bounds for variables */
	jmi_real_t *x_ub;                  /* Upper bound for variables */
	jmi_real_t *x_init;                /* Initial starting point */
	int *blocking_factors;             /* Specification of blocking factors */
	int n_blocking_factors;            /* Number of blocking factors */
	int n_blocking_factor_constraints; /* Number of constraints resulting */
		                               /* from blocking factors divided by the number of inputs */
	int dg_n_nz;
	int dh_n_nz;
	int *dg_row;
	int *dg_col;
	int *dh_row;
	int *dh_col;
	int n_nonlinear_variables;
	int *non_linear_variables_indices; /* Stored Fortran style (first index = 1) */
	jmi_opt_coll_get_dimensions_t get_dimensions;
	jmi_opt_coll_get_interval_spec_t get_interval_spec;
	jmi_opt_coll_f_t f;
	jmi_opt_coll_df_t df;
	jmi_opt_coll_h_t h;
	jmi_opt_coll_dh_t dh;
	jmi_opt_coll_g_t g;
	jmi_opt_coll_dg_t dg;
	int n_g;                          /* Number of inequality constraints */
	int n_h;                          /* Number of equality constraints */
	jmi_opt_coll_get_bounds_t get_bounds;
	jmi_opt_coll_get_initial_t get_initial;
	jmi_opt_coll_set_initial_from_trajectory_t set_initial_from_trajectory;
	jmi_opt_coll_g_nz_indices_t dg_nz_indices;
	jmi_opt_coll_h_nz_indices_t dh_nz_indices;
	jmi_opt_coll_write_file_matlab_t write_file_matlab;
	jmi_opt_coll_get_result_variable_vector_length_t get_result_variable_vector_length;
	jmi_opt_coll_get_result_t get_result;
	jmi_opt_coll_get_result_mesh_interpolation_t get_result_mesh_interpolation;
	jmi_opt_coll_get_result_element_interpolation_t get_result_element_interpolation;
};

/**
 * \brief Get the upper and lower bounds of the optimization variables.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param x_lb (Output) Lower bounds vector.
 * @param x_lb (Output) Upper bounds vector.
 * @return Error code.
 */
int jmi_opt_coll_get_bounds(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *x_lb, jmi_real_t *x_ub);

/**
 * \brief Get the upper and lower bounds of the optimization variables.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param x_lb (Output) Lower bounds vector.
 * @param x_lb (Output) Upper bounds vector.
 * @return Error code.
 */
int jmi_opt_coll_set_bounds(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *x_lb, jmi_real_t *x_ub);


/* @} */

/**
 * \defgroup jmi_opt_coll_eval_functions Evaluation of NLP functions.
 * \brief Functions for evaluation of \f$f\f$, \f$g\f$, and \f$h\f$.
 */
/* @{ */

/**
 * \brief Returns the cost function value at a given point in search space.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param f (Output) Value of the cost function.
 * @param Error code.
 */
int jmi_opt_coll_f(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *f);

/**
 * \brief Returns the gradient of the cost function value at
 * a given point in search space.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param df (Output) Value of the gradient of the cost function.
 * @param Error code.
 */
int jmi_opt_coll_df(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *df);

/**
 * \brief Returns the residual of the inequality constraints.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param res (Output) Residual of the inequality constraints.
 * @param Error code.
 */
int jmi_opt_coll_g(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res);

/**
 * \brief Returns the Jacobian of the residual of the inequality constraints.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param jac (Output) Jacobian of the residual of the inequality constraints.
 * @param Error code.
 */
int jmi_opt_coll_dg(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac);

/**
 * \Brief Returns the indices of the non-zeros in the
 * inequality constraint Jacobian. The indices are returned in Fortran style
 * with the first entry indexed as 1.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param irow (Output) Row indices of the non-zero entries in the
 *  Jacobian of the residual of the inequality constraints.
 * @param icol (Output) Column indices of the non-zero entries in the
 *  Jacobian of the residual of the inequality constraints.
 * @param Error code.
 */
int jmi_opt_coll_dg_nz_indices(jmi_opt_coll_t *jmi_opt_coll, int *irow, int *icol);

/**
 * \brief Returns the residual of the equality constraints.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param res (Output) Residual of the equality constraints.
 * @param Error code.
 */
int jmi_opt_coll_h(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res);

/**
 * \brief Returns the Jacobian of the residual of the equality constraints.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param jac (Output) Jacobian of the residual of the equality constraints.
 * @param Error code.
 */
int jmi_opt_coll_dh(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac);


/**
 * \Brief Returns the indices of the non-zeros in the
 * equality constraint Jacobian. The indices are returned in Fortran style
 * with the first entry indexed as 1.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param irow (Output) Row indices of the non-zero entries in the
 *  Jacobian of the residual of the equality constraints.
 * @param icol (Output) Column indices of the non-zero entries in the
 *  Jacobian of the residual of the equality constraints.
 * @param Error code.
 */
int jmi_opt_coll_dh_nz_indices(jmi_opt_coll_t *jmi_opt_coll, int *irow, int *icol);


/* @} */

/**
 * \defgroup jmi_opt_coll_misc Miscanellous
 * \brief Miscanellous functions.
 */
/* @{ */


/**
 * \brief Write the the optimization result to file in Matlab format.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param file_name Name of the file.
 * @return Error code.
 *
 */
int jmi_opt_coll_write_file_matlab(jmi_opt_coll_t *jmi_opt_coll_t,
		const char *file_name);

/**
 * \brief Get the length of the result variable vectors.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param n (Output) the number of points in the independent time vector.
 * @return Error code.
 *
 */
int jmi_opt_coll_get_result_variable_vector_length(jmi_opt_coll_t
		*jmi_opt_coll, int *n);

/**
 * \brief Get the optimization results.
 *
 * The output arguments corresponding to the derivatives, the states, the
 * inputs and the algebraic variables are matrices (stored in column major
 * format) where each row contains the variable values at a particular time
 * point and were each column contains the trajectory of a particular variable.
 * The number of rows of these matrices are given by the function
 * jmi_opt_coll_get_result_variable_vector_length.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param p_opt (Output) A vector containing the optimal values of the
 * parameters.
 * @param t (Output) The time vector.
 * @param dx (Output) The derivatives.
 * @param x (Output) The states.
 * @param u (Output) The inputs.
 * @param w (Output) The algebraic variables.
 */
int jmi_opt_coll_get_result(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);

/**
 * \brief Get the optimization results based on a user defined mesh.
 *
 * The output arguments corresponding to the derivatives, the states, the
 * inputs and the algebraic variables are matrices (stored in column major
 * format) where each row contains the variable values at a particular time
 * point and were each column contains the trajectory of a particular variable.
 * The number of rows of these matrices are given by the
 * the length of the user provided mesh. The variable values are computed using
 * interpolation.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param mesh Mesh used for computation of the result.
 * @param n_mesh Length of the mesh.
 * @param p_opt (Output) A vector containing the optimal values of the
 * parameters.
 * @param t (Output) The time vector.
 * @param dx (Output) The derivatives.
 * @param x (Output) The states.
 * @param u (Output) The inputs.
 * @param w (Output) The algebraic variables.
 */
int jmi_opt_coll_get_result_mesh_interpolation(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *mesh, int n_mesh, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);

/**
 * \brief Get the optimization results based on interpolation within finite
 * elements.
 *
 * The output arguments corresponding to the derivatives, the states, the
 * inputs and the algebraic variables are matrices (stored in column major
 * format) where each row contains the variable values at a particular time
 * point and were each column contains the trajectory of a particular variable.
 * The number of rows of these matrices are given by the
 * the number of finite elements times the number of interpolation points
 * specified by the user. The interpolation points at which the variables
 * are computed are equally spaced, and includes the element start and end
 * points within each finite element. Interpolation is used to compute the
 * variables at each point.
 *
 * @param jmi_opt_coll A jmi_opt_coll_t struct.
 * @param n_interpolation_points Number of interpolation points in each
 * interval.
 * @param p_opt (Output) A vector containing the optimal values of the
 * parameters.
 * @param t (Output) The time vector.
 * @param dx (Output) The derivatives.
 * @param x (Output) The states.
 * @param u (Output) The inputs.
 * @param w (Output) The algebraic variables.
 */
int jmi_opt_coll_get_result_element_interpolation(jmi_opt_coll_t *jmi_opt_coll,
		int n_interpolation_points, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);


#ifdef __cplusplus
}
#endif


#endif /* JMI_OPT_COLL_H_ */

/* @} */
/* @} */
