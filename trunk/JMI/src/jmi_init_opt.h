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



/** \file jmi_init_opt.h
 *  \brief An interface to an NLP corresponding to the DAE initialization
 *  system.
 **/

/**
 * \defgroup jmi_init_opt DAE initialization algorithm based on optimization.
 *
 * The DEA initialization problem is here cast to an optimization problem:
 *
 * \f$ \displaystyle\min_{p_{f}, \dot x, x, w} \displaystyle
 *   \sum_{i=1}^{n_{F_1}}F_{1,i}(p,\dot x, x, u,w,t_0)^2\f$<br>
 * subject to<br>
 * \f$ F_0(p,\dot x, x, u, w, t_0)=0\f$<br>
 *
 * where \f$p_f\f$ are parameters with the fixed attribute set to false,
 * \f$\dot x\f$ are the derivatives, \f$x\f$ are the differentiate variables,
 * \f$u\f$ are the inputs, \f$w\f$ are the algebraic variables \f$t_0\f$ is
 * the initial time, \f$F_0\f$ are the equations that must hold at
 * initial time, and \f$F_1\f$ are the residual equations derived from initial
 * guesses (start attributes) for non fixed variables.
 *
 * Limitations:<br>
 *  - Free parameters are not supported.
 *
 *
 */

/* @{ */
#ifndef _JMI_INIT_OPT_H
#define _JMI_INIT_OPT_H

#include "jmi.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \defgroup jmi_init_opt_typedefs Typedefs
 * \brief Typedefs for data structures.
 */
/* @{ */

typedef struct jmi_init_opt_t jmi_init_opt_t;

/* @} */

/**
 * \defgroup jmi_init_opt_t The jmi_init_opt_t struct, setters and getters.
 * \brief Documentation of the jmi_init_opt_t struct and it setters and getters.
 */
/* @{ */

/**
 * \brief Get the number of variables and the number of
 * constraints, respectively, in the NLP problem.
 *
 * @param jmi_init_opt_t A jmi_init_opt_t struct.
 * @param n_x (Output) Number of variables in the NLP problem.
  * @param n_h (Output) Number of equality constraints.
 * @param dg_n_nz (Output) Number of non-zeros in the Jacobian of the inequality
 * constraints.
 */
int jmi_init_opt_get_dimensions(jmi_init_opt_t *jmi_init_opt, int *n_x,
		int *n_h, int *dh_n_nz);

/**
 * \brief Get the x vector of the NLP.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @return The x vector.
 */
jmi_real_t* jmi_init_opt_get_x(jmi_init_opt_t *jmi_init_opt);

/**
 * \brief Get the initial point of the NLP.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param x_init (Output) the initial guess vector.
 * @return Error code.
 */
int jmi_init_opt_get_initial(jmi_init_opt_t *jmi_init_opt, jmi_real_t *x_init);

/**
 * \brief Set the initial point of the NLP.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param x_init The initial guess vector.
 * @return Error code.
 */
 int jmi_init_opt_set_initial(jmi_init_opt_t *jmi_init_opt,
		jmi_real_t *x_init);

/**
  * \brief Set the initial point of the NLP based on values in the JMI model.
  *
  * @param jmi_init_opt A jmi_init_opt_t struct.
  * @return Error code.
  */
 int jmi_init_opt_set_initial_from_model(jmi_init_opt_t *jmi_init_opt);

/**
 * \brief The main struct in the jmi_init_opt interface is jmi_init_opt_t.
 *
 * This struct contains a pointer to a jmi_t struct, dimension information of
 * the NLP, and variable vectors.
 */
struct jmi_init_opt_t{
	jmi_t *jmi;                       /* jmi_t struct */
	jmi_real_t *x;                    /* x vector. */
	jmi_real_t *x_lb;                 /* Lower bounds for variables */
	jmi_real_t *x_ub;                 /* Upper bound for variables */
	jmi_real_t *x_init;               /* Initial starting point */
	int n_x;                          /* Number of variables in the initialization problem */
	int n_p_free;                     /* Number of parameters with fixed = false */
	int *p_free_indices;              /* Indices of parameters with fixed = false */
	int n_h;                          /* Number of equality constraints */
	int dh_n_nz;
	int *dh_irow;
	int *dh_icol;
	int dF0_n_nz;
	int n_nonlinear_variables;
	int *non_linear_variables_indices;  /* Stored Fortran style (first index = 1) */
	jmi_real_t *res_F1;                 /* work vector */
	jmi_real_t *dF1_dv;                 /* work vector */
	int dF1_dv_n_nz;
	int *dF1_dv_irow;
	int *dF1_dv_icol;
	int dF_dv_n_nz;
	int *der_mask_v;
	int der_eval_alg;
	int stat;
};

/**
 * \brief Create a new jmi_init_opt_t struct.
 */
int jmi_init_opt_new(jmi_init_opt_t **jmi_init_opt_new, jmi_t *jmi,
		int n_p_free, int *p_free_indices,
		jmi_real_t *p_opt_init, jmi_real_t *p_free_init, jmi_real_t *dx_init,
		jmi_real_t *x_init, jmi_real_t *w_init,
		jmi_real_t *p_opt_lb, jmi_real_t *p_free_lb, jmi_real_t *dx_lb,
		jmi_real_t *x_lb, jmi_real_t *w_lb,
		jmi_real_t *p_opt_ub, jmi_real_t *p_free_ub, jmi_real_t *dx_ub,
		jmi_real_t *x_ub, jmi_real_t *w_ub,
		int linearity_information_provided,
		int* p_opt_lin, int* p_free_lin, int* dx_lin, int* x_lin, int* w_lin,
		int der_eval_alg, int stat) ;

/**
 * \brief Delete a jmi_init_opt_t struct.
 */
int jmi_init_opt_delete(jmi_init_opt_t *jmi_init_opt);

/**
 * \brief Get the upper and lower bounds of the optimization variables.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param x_lb (Output) Lower bounds vector.
 * @param x_lb (Output) Upper bounds vector.
 * @return Error code.
 */
int jmi_init_opt_get_bounds(jmi_init_opt_t *jmi_init_opt, jmi_real_t *x_lb, jmi_real_t *x_ub);

/**
 * \brief Get the upper and lower bounds of the optimization variables.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param x_lb (Output) Lower bounds vector.
 * @param x_lb (Output) Upper bounds vector.
 * @return Error code.
 */
int jmi_init_opt_set_bounds(jmi_init_opt_t *jmi_init_opt, jmi_real_t *x_lb, jmi_real_t *x_ub);


/* @} */

/**
 * \defgroup jmi_init_opt_eval_functions Evaluation of NLP functions.
 * \brief Functions for evaluation of \f$f\f$, \f$g\f$, and \f$h\f$.
 */
/* @{ */

/**
 * \brief Returns the cost function value at a given point in search space.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param f (Output) Value of the cost function.
 * @param Error code.
 */
int jmi_init_opt_f(jmi_init_opt_t *jmi_init_opt, jmi_real_t *f);

/**
 * \brief Returns the gradient of the cost function value at
 * a given point in search space.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param df (Output) Value of the gradient of the cost function.
 * @param Error code.
 */
int jmi_init_opt_df(jmi_init_opt_t *jmi_init_opt, jmi_real_t *df);

/**
 * \brief Returns the residual of the equality constraints.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param res (Output) Residual of the equality constraints.
 * @param Error code.
 */
int jmi_init_opt_h(jmi_init_opt_t *jmi_init_opt, jmi_real_t *res);

/**
 * \brief Returns the Jacobian of the residual of the equality constraints.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param jac (Output) Jacobian of the residual of the equality constraints.
 * @param Error code.
 */
int jmi_init_opt_dh(jmi_init_opt_t *jmi_init_opt, jmi_real_t *jac);


/**
 * \Brief Returns the indices of the non-zeros in the
 * equality constraint Jacobian. The indices are returned in Fortran style
 * with the first entry indexed as 1.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param irow (Output) Row indices of the non-zero entries in the
 *  Jacobian of the residual of the equality constraints.
 * @param icol (Output) Column indices of the non-zero entries in the
 *  Jacobian of the residual of the equality constraints.
 * @param Error code.
 */
int jmi_init_opt_dh_nz_indices(jmi_init_opt_t *jmi_init_opt, int *irow, int *icol);


/* @} */

/**
 * \defgroup jmi_init_opt_misc Miscanellous
 * \brief Miscanellous functions.
 */
/* @{ */


/**
 * \brief Write the the optimization result to file in Matlab format.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param file_name Name of the file.
 * @return Error code.
 *
 */
int jmi_init_opt_write_file_matlab(jmi_init_opt_t *jmi_init_opt_t,
		const char *file_name);

/**
 * \brief Get the optimization results.
 *
 * The output arguments corresponding to the derivatives, the states, the
 * inputs and the algebraic variables are matrices (stored in column major
 * format) where each row contains the variable values at a particular time
 * point and were each column contains the trajectory of a particular variable.
 * The number of rows of these matrices are given by the function
 * jmi_init_opt_get_result_variable_vector_length.
 *
 * @param jmi_init_opt A jmi_init_opt_t struct.
 * @param p_opt (Output) A vector containing the optimal values of the
 * parameters.
 * @param t (Output) The time vector.
 * @param dx (Output) The derivatives.
 * @param x (Output) The states.
 * @param u (Output) The inputs.
 * @param w (Output) The algebraic variables.
 */
int jmi_init_opt_get_result(jmi_init_opt_t *jmi_init_opt, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w);

#ifdef __cplusplus
}
#endif


#endif /* JMI_INIT_OPT_H_ */

/* @} */
/* @} */
