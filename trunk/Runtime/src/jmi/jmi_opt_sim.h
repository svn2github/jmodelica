/*
 * jmi_opt_sim.h provides an interface to an NLP derived by means of a
 * simultaneous optimization method. Notice that the method of transcription
 * is not specified by the interface. Rather, such a method is specified
 * by the call back functions in the struct jmi_opt_sim_t. This design
 * enables different methods to be implemented. Typically, a jmi_opt_sim_t
 * struct is created by a function call to, for example, jmi_opt_sim_lp_radau_new.
 * The resulting struct can then be used generically in the jmi_opt_sim interface
 * functions.
 *
 * jmi_opt_sim provides an interface to an NLP on the form:
 *
 *   min f(x)
 *
 *   s.t.
 *
 *   g(x) <= 0
 *   h(x) = 0
 *
 * including evaluation of Jacobians of f, g, and h as well as parsity patterns
 * for g and h.
 *
 */

#ifndef _JMI_OPT_SIM_H
#define _JMI_OPT_SIM_H

#include "jmi.h"

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

typedef int (*jmi_opt_sim_get_bounds_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_lb, jmi_real_t *x_ub);

typedef int (*jmi_opt_sim_get_initial_t)(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_init);

typedef int (*jmi_opt_sim_h_nz_indices_t)(jmi_opt_sim_t *jmi_opt_sim, int *colIndex, int *rowIndex);

typedef int (*jmi_opt_sim_g_nz_indices_t)(jmi_opt_sim_t *jmi_opt_sim, int *colIndex, int *rowIndex);

typedef int (*jmi_opt_sim_write_file_matlab_t)(jmi_opt_sim_t *jmi_opt_sim, char *file_name);

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
};

typedef struct {
	jmi_opt_sim_t jmi_opt_sim;
    int n_cp;                      // Number of collocation points
    jmi_real_t *cp;                // Collocation points for algebraic variables
    jmi_real_t *cpp;               // Collocation points for dynamic variables
    jmi_real_t *Lp_coeffs;               // Lagrange polynomial coefficients based on the points in cp
    jmi_real_t *Lpp_coeffs;              // Lagrange polynomial coefficients based on the points in cp plus one more point
    jmi_real_t *Lp_dot_coeffs;               // Lagrange polynomial derivative coefficients based on the points in cp
    jmi_real_t *Lpp_dot_coeffs;              // Lagrange polynomial derivative coefficients based on the points in cp plus one more point
    jmi_real_t *Lp_dot_vals;        // Values of the derivative of the Lagrange polynomials at the points in cp
    jmi_real_t *Lpp_dot_vals;       // Values of the derivative of the Lagrange polynomials at the points in cpp
    int der_eval_alg;                   // Evaluation algorithm used for computation of derivatives
    int dF0_n_nz;
    int dF_dp_n_nz;
    int dF_ddx_dx_du_dw_n_nz;
    int offs_p_opt;
    int offs_dx_0;
    int offs_x_0;
    int offs_u_0;
    int offs_w_0;
    int offs_dx_coll;
    int offs_x_coll;
    int offs_u_coll;
    int offs_w_coll;
    int offs_x_el_junc;
    int offs_dx_p;
    int offs_x_p;
    int offs_u_p;
    int offs_w_p;
    int offs_h;
    int offs_t0;
    int offs_tf;
    int *der_mask;
} jmi_opt_sim_lp_radau_t;

int jmi_opt_sim_lp_radau_new(jmi_opt_sim_t **jmi_opt_sim, jmi_t *jmi, int n_e,
		            jmi_real_t *hs, int hs_free,
		            jmi_real_t *p_opt_init, jmi_real_t *dx_init, jmi_real_t *x_init,
		            jmi_real_t *u_init, jmi_real_t *w_init,
		            jmi_real_t *p_opt_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
		            jmi_real_t *u_lb, jmi_real_t *w_lb, jmi_real_t t0_lb,
		            jmi_real_t tf_lb, jmi_real_t *hs_lb,
		            jmi_real_t *p_opt_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
		            jmi_real_t *u_ub, jmi_real_t *w_ub, jmi_real_t t0_ub,
		            jmi_real_t tf_ub, jmi_real_t *hs_ub,
		            int n_cp, int der_eval_alg);

int jmi_opt_sim_lp_radau_delete(jmi_opt_sim_t *jmi_opt_sim);

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
int jmi_opt_sim_get_x(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t **x);

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

/**
 * jmi_opt_sim_get_bounds returns the upper and lower bounds on the optimization variables.
 */
int jmi_opt_sim_get_bounds(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_lb, jmi_real_t *x_ub);

/**
 * jmi_opt_sim_get_initial returns the initial point.
 */
int jmi_opt_sim_get_initial(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_init);

int jmi_opt_sim_write_file_matlab(jmi_opt_sim_t *jmi_opt_sim_t, char *file_name);

#endif /* JMI_OPT_SIM_H_ */
