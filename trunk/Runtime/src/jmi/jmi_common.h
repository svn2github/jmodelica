/*
 * jmi_common.h contains private data structures and functions.
 *
 */


#ifndef _JMI_COMMON_H
#define _JMI_COMMON_H

#include <stdio.h>
#include <stdlib.h>

#define JMI_AD_NONE 0
#define JMI_AD_CPPAD 1

/*
 *  TODO: Error codes...
 *  Introduce #defines to denote different error codes
 */

#if JMI_AD == JMI_AD_CPPAD
// This must be done outside of 'extern "C"'
#include <cppad/cppad.hpp>
#include <vector>
#endif

// Forward declaration of jmi struct
typedef struct jmi_t jmi_t;

// Typedef for the doubles used in the interface.
typedef double jmi_real_t;

// This section defines types in the case of no AD and
// in the case of CppAD.
#if JMI_AD == JMI_AD_NONE
typedef jmi_real_t jmi_ad_var_t;
typedef jmi_real_t *jmi_real_vec_t;
typedef jmi_real_vec_t *jmi_real_vec_p;
typedef jmi_real_t *jmi_ad_var_vec_t;
typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;
typedef void jmi_ad_tape_t;
typedef jmi_ad_tape_t *jmi_ad_tape_p;
//typedef void jmi_dae_ad_t;
//typedef void jmi_init_ad_t;
typedef void jmi_func_ad_t;
#elif JMI_AD == JMI_AD_CPPAD
typedef CppAD::AD<jmi_real_t> jmi_ad_var_t;
typedef std::vector<jmi_real_t> jmi_real_vec_t;
typedef jmi_real_vec_t *jmi_real_vec_p;
typedef std::vector< jmi_ad_var_t > jmi_ad_var_vec_t;
typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;
typedef CppAD::ADFun<jmi_real_t> jmi_ad_tape_t;
typedef jmi_ad_tape_t *jmi_ad_tape_p;

/*
 * The struct jmi_cppad_func_t contains a tape and associated
 * sparsity information for a particular function F.
 */
typedef struct {

	jmi_ad_var_vec_p F_z_dependent;
	jmi_ad_tape_p F_z_tape;
	int tape_initialized;

	int dF_z_n_nz;
	int* dF_z_row;
	int* dF_z_col;

	// Sparsity patterns for individual independent variables
	// These variables are useful when computing the Jacobian.
	int dF_ci_n_nz, dF_cd_n_nz, dF_pi_n_nz, dF_pd_n_nz,
        dF_dx_n_nz, dF_x_n_nz, dF_u_n_nz, dF_w_n_nz, dF_t_n_nz,
        dF_dx_p_n_nz, dF_x_p_n_nz, dF_u_p_n_nz, dF_w_p_n_nz, dF_t_p_n_nz;
	int *dF_ci_row, *dF_cd_row, *dF_pi_row, *dF_pd_row,
		*dF_dx_row, *dF_x_row, *dF_u_row, *dF_w_row, *dF_t_row,
	    *dF_dx_p_row, *dF_x_p_row, *dF_u_p_row, *dF_w_p_row, *dF_t_p_row;
	int *dF_ci_col, *dF_cd_col, *dF_pi_col, *dF_pd_col,
		*dF_dx_col, *dF_x_col, *dF_u_col, *dF_w_col, *dF_t_col,
		*dF_dx_p_col, *dF_x_p_col, *dF_u_p_col, *dF_w_p_col, *dF_t_p_col;

	jmi_real_vec_p z_work;
} jmi_func_ad_t;
/*
typedef struct {
	jmi_cppad_func_t* F;
	jmi_real_vec_p z_work;

} jmi_dae_ad_t;

typedef struct {
	jmi_cppad_func_t* F0;
	jmi_cppad_func_t* F1;
	jmi_real_vec_p z_work;
} jmi_init_ad_t;
*/

#else
#error "The directive JMI_AD_NONE or JMI_AD_CPPAD must be set"
#endif

// Function signatures to be used in the generated code

/**
 * Evaluation of the DAE residual in the generated code.
 */
typedef int (*jmi_residual_func_t)(jmi_t* jmi, jmi_ad_var_vec_p res);

/**
 * Evaluation of symbolic jacobian in generated code.
 */
typedef int (*jmi_jacobian_func_t)(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac);

/*
 * The jmi_func_t is a struct that contains function pointers and dimension information
 * corresponding to a mathematical vector valued function, F. The struct also contains
 * function pointers to symbolic Jacobians and associated sparsity information.
 */

typedef struct {
	jmi_residual_func_t F;
	jmi_jacobian_func_t dF;
	int n_eq_F;
	int dF_n_nz;
	int* dF_row;
	int* dF_col;
	jmi_func_ad_t* ad;
} jmi_func_t;


/**
 * Struct describing a DAE model including evaluation of the DAE residual and (optional) a symbolic
 * Jacobian. If the Jacobian is not provided, the corresponding function pointers are set to NULL.
 */
typedef struct {
	jmi_func_t* F;
} jmi_dae_t;

typedef struct {
	jmi_func_t* F0;
	jmi_func_t* F1;
} jmi_init_t;

typedef struct {
	jmi_func_t* J;
	jmi_func_t* Ceq;
	jmi_func_t* Cineq;
	jmi_func_t* Heq;
	jmi_func_t* Hineq;
	jmi_real_t start_time;
	int start_time_free;
	jmi_real_t final_time;
	int final_time_free;
    // TODO: Make sure that these are initialized.
	int n_p_opt;                     // Number of parameters to optimize (in the p_i vector)
	int *p_opt_indices;              // Indices of the parameters to optimize (in the p_i vector)

} jmi_opt_t;

/**
 * jmi is the main struct in the jmi interface. It contains pointers to structs of
 * types jmi_dae, jmi_init, and jmi_opt. The creation of a jmi_t struct proceeds in three
 * steps. First, a raw struct is created by the function jmi_init. Then the jmi_dae_t,
 * jmi_init_t, and jmi_opt_t structs are initialized by the functions jmi_dae_init,
 * jmi_init_init, and jmi_opt_init respectively. Finlly, the the jmi_xxx_ad_t structs are
 * are set up in the function call jmi_ad_init. Notice that the variables should have been
 * initialized prior to the call to jmi_ad_init.
 *
 * Typically, jmi_init and jmi_xxx_init functions are called from within the jmi_new function
 * that is provided by the generated code. The function jmi_ad_init is then called from the
 * user code after the variable vectors has been initialized.
 */
struct jmi_t{
	jmi_dae_t* dae;
	jmi_init_t* init;
	jmi_opt_t* opt;

	int n_ci;
	int n_cd;
	int n_pi;
	int n_pd;
	int n_dx;
	int n_x;
	int n_u;
	int n_w;

	// TODO: Make sure that these are initialized
	// TODO: Give access to tp
	int n_tp;                        // Number of time points included in the optimization problem
	jmi_real_t *tp;                  // Time point values in the normalized interval [0..1].
	                                 // A value <=0 corresponds to the initial time and
	                                 // a value >=1 corresponds to the final time.

	int n_p;
	int n_v;
	int n_q;
	int n_z; // the sum of all variables vector sizes (including t), for convenience

	// Offset variables in the z vector, for convenience.
	int offs_ci;
	int offs_cd;
	int offs_pi;
	int offs_pd;
	int offs_dx;
	int offs_x;
	int offs_u;
	int offs_w;
	int offs_t;
	int offs_dx_p;
	int offs_x_p;
	int offs_u_p;
	int offs_w_p;
	int offs_t_p;

	int offs_p;
	int offs_v;
	int offs_q;

	// This vector contains active AD objects in case of AD
	jmi_ad_var_vec_p z;
	// This vector contains the actual values
	jmi_real_t** z_val;

};

#define JMI_FUNC_COMPUTE_DF_DIM_PART(independent_vars_mask, n_vars, n_eq_F, jmi_dF_n_nz, jmi_dF_col) {\
	if ((independent_vars & independent_vars_mask)) {\
		for (i=0;i<n_vars;i++) {\
			if (mask[col_index]) {\
				(*dF_n_cols)++;\
				if (sparsity & JMI_DER_SPARSE) {\
					for (j=0;j<jmi_dF_n_nz;j++) {\
	(*dF_n_nz) += jmi_dF_col[j]-1 == col_index? 1 : 0;\
					}\
				} else {\
					(*dF_n_nz) += n_eq_F;\
				}\
			}\
			col_index++;\
		}\
	} else {\
		col_index += n_vars;\
	}\
}\

/**
 * Create a new jmi_func_t.
 */
int jmi_func_new(jmi_func_t** jmi_func, jmi_residual_func_t F, int n_eq_F, jmi_jacobian_func_t dF,
		int dF_n_nz, int* dF_row, int* dF_col);

/*
 * Delete a jmi_func_t.
 */
int jmi_func_delete(jmi_func_t *func);

/*
 * Convenience function to evaluate the Jacobian of the function contained in a
 * jmi_func_t.
 */
int jmi_func_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
		int independent_vars, int* mask, jmi_real_t* jac) ;

/*
 * Convenience function for accessing the number of non-zeros in the
 * Jacobian of the function in jmi_func_t.
 */
int jmi_func_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz);

/*
 *  Convenience function of accessing the non-zeros in the Jacobian
 *  in an jmi_func_t
 */
int jmi_func_dF_nz_indices(jmi_t *jmi, jmi_func_t *func, int *row, int *col);

/*
 *  Convenience function for computing the dimensions of the Jacobian in an
 *  jmi_func_t.
 */
int jmi_func_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/**
 * Allocates memory and sets up the jmi_t struct. This function is typically called
 * from within jmi_new in the generated code. The reason for introducing this function
 * is that the allocation of the jmi_t struct should not be repeated in the generated code.
 */
int jmi_init(jmi_t** jmi, int n_ci, int n_cd, int n_pi, int n_pd, int n_dx,
		int n_x, int n_u, int n_w, int n_tp);

/**
 * Allocates a jmi_dae_t struct.
 */
int jmi_dae_init(jmi_t* jmi, jmi_residual_func_t F, int n_eq_F, jmi_jacobian_func_t dF,
		int dF_n_nz, int* row, int* col);

/**
 * Allocates a jmi_init_t struct.
 */
int jmi_init_init(jmi_t* jmi, jmi_residual_func_t F0, int n_eq_F0,
		jmi_jacobian_func_t dF0,
		int dF0_n_nz, int* dF0_row, int* dF0_col,
		jmi_residual_func_t F1, int n_eq_F1,
		jmi_jacobian_func_t dF1,
		int dF1_n_nz, int* dF1_row, int* dF1_col);

/**
 * Allocates a jmi_opt_t struct.
 */
int jmi_opt_init(jmi_t* jmi, jmi_residual_func_t J,
		jmi_jacobian_func_t dJ,
		int dJ_n_nz, int* dJ_row, int* dJ_col,
		jmi_residual_func_t Ceq, int n_eq_Ceq,
		jmi_jacobian_func_t dCeq,
		int dCeq_n_nz, int* dCeq_row, int* dCeq_col,
		jmi_residual_func_t Cineq, int n_eq_Cineq,
		jmi_jacobian_func_t dCineq,
		int dCineq_n_nz, int* dCineq_row, int* dCineq_col,
		jmi_residual_func_t Heq, int n_eq_Heq,
		jmi_jacobian_func_t dHeq,
		int dHeq_n_nz, int* dHeq_row, int* dHeq_col,
		jmi_residual_func_t Hineq, int n_eq_Hineq,
		jmi_jacobian_func_t dHineq,
		int dHineq_n_nz, int* dHineq_row, int* dHineq_col);

#endif
