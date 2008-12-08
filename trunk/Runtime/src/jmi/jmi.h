/*
 * Design considerations
 *
 * The model/optimization interface is intended to be used in a wide range of
 * applications and on multiple platforms. This also includes embedded
 * platforms in HILS applications.
 *
 * It is desirable that the model/optimization interfaces can be easily interfaced
 * with python. Python is the intended language for scripting in JModelica and it is
 * therefore important that the generated code is straight forward to use with the
 * python extensions or ctypes framework.
 *
 * The model/optimization interface is intended to be used by wide range of users,
 * with different backgrounds and programming skills. It is therefore desirable that
 * the interface is as simple and intuitive as possible.
 *
 * Given these motivations, it is reasonable to use pure C where possible, and to a
 * limited extent C++ where needed (e.g. in solver interfaces and in most likely in the
 * AD framework).
 *
 * It should also be possible to build shared libraries for models/optimization problems.
 * In this way, it is possible to build applications that contains several models.
 *
 * -------------------------------------------------------------------------------------
 * Interface specification
 * -------------------------------------------------------------------------------------
 *
 *   The jmi interface consists of three parts: DAE, DAE initialization and optimization.
 *   Essentially, the jmi interface consists of a collection of functions that are
 *   offered to the user for evaluation of the DAE residual, cost functions, constraints
 *   etc. These functions takes as arguments one more of the following three argument
 *   classes:
 *
 *   Parameters (denoted p):
 *
 *      ci   independent constant
 *      cd   dependent constants
 *      pi   independent parameters
 *      pd   dependent parameters
 *
 *      p = [ci^T, cd^T, pi^T, pd^T]^T
 *
 *   Variables (denoted v):
 *
 *      dx    differentiated variables
 *      x     variables that appear differentiated
 *      u     inputs
 *      w     algebraic variables
 *      t     time
 *
 *	    v = [dx^T, x^T, u^T, w^T, t]^T
 *
 *   Variables defined at particular time instants (denoted q):
 *
 *      dx(t_i)    differentiated variables evaluated at time t_i, i \in 1..n_tp
 *      x(t_i)     variables that appear differentiated evaluated at time i, t_i \in 1..n_tp
 *      u(t_i)     inputs evaluated at time t_i, i \in 1..n_tp
 *      w(t_i)     algebraic variables evaluated at time t_i, i \in 1..n_tp
 *      t_i        time instants i \in 1..n_tp
 *
 *      q = [dx(t_1)^T,...,dx(t_n_tp)^T,  x(t_1)^T,...,x(t_n_tp)^T,
 *           u(t_1)^T,...,u(t_n_tp)^T,  w(t_1)^T,..., w(t_n_tp)^T, t_1, ...,t_n_tp]^T
 *
 *   All parameters, variables and point-wise evaluated variables are denoted z:
 *
 *      z = [p^T, v^T, q^T]
 *
 *   The DAE interface is defined by the residual function
 *
 *      F(p,v) = 0
 *
 *	 The DAE initialization interface is defined by the functions
 *
 *	    F0(p,v) = 0
 *	    F1(p,v) = 0
 *
 *   F0 represents the DAE system augmented with additional initial equations
 *   and start values that are fixed. F1 on the other hand contains equations for
 *   initialization of variables for which the value given in the start attribute is
 *   not fixed.
 *
 *   The optimization part of the interface is defined by the functions
 *
 *      J(p,v)
 *      Ceq(p,v,q) = 0
 *      Cineq(p,v,q) <= 0
 *      Heq(p,q) = 0
 *      Hineq(p,q) <= 0
 *
 *   where J is the cost function to be minimized, Ceq are path equality constraints,
 *   Cineq are path inequality constraints, Heq are (time) point equality constraints,
 *   and Hineq are (time) point inequality constraints. The rationale for introducing
 *   Heq and Hineq is to enable expression of e.g. terminal constraints.
 *
 */

#ifndef _JMI_H
#define _JMI_H

#include "jmi_common.h"

#define JMI_DER_SYMBOLIC 1
#define JMI_DER_CPPAD 2

#define JMI_DER_SPARSE 1
#define JMI_DER_DENSE_COL_MAJOR 2
#define JMI_DER_DENSE_ROW_MAJOR 4

// Flags for evaluation of Jacobians w.r.t. parameters in the p vector
#define JMI_DER_CI 1
#define JMI_DER_CD 2
#define JMI_DER_PI 4
#define JMI_DER_PD 8
// Flags for evaluation of Jacobians w.r.t. variables in the v vector
#define JMI_DER_DX 16
#define JMI_DER_X 32
#define JMI_DER_U 64
#define JMI_DER_W 128
#define JMI_DER_T 256
// Flags for evaluation of Jacobians w.r.t. variables in the q vector
#define JMI_DER_DX_P 512
#define JMI_DER_X_P 1024
#define JMI_DER_U_P 2048
#define JMI_DER_W_P 4096
#define JMI_DER_T_P 8192

#define JMI_DER_ALL JMI_DER_CI | JMI_DER_CD | JMI_DER_PI | JMI_DER_PD |\
	JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W |\
	JMI_DER_T | JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P |\
	JMI_DER_T_P

#define JMI_DER_ALL_P JMI_DER_CI | JMI_DER_CD | JMI_DER_PI | JMI_DER_PD

#define JMI_DER_ALL_V JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W |\
	JMI_DER_T

#define JMI_DER_ALL_Q  JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P |\
	JMI_DER_T_P

/*
 *****************************************
 *
 *    Public interface
 *
 ****************************************
 */

/**
 * Creates a new jmi struct, for which a pointer is returned in the output argument jmi.
 * This function is assumed to be given in the generated code.
 */
int jmi_new(jmi_t** jmi);

/**
 * Initializes the AD variables and tapes. Prior to this call, the variables in z should
 * be initialized, which is also the reason why this function must be provided for
 * the user to call after the actual creation of the jmi_t struct.
 */
int jmi_ad_init(jmi_t* jmi);

/**
 * Deallocates memory and deletes a jmi struct.
 */
int jmi_delete(jmi_t* jmi);

/*
 * Get the sizes of the variable vectors.
 */
int jmi_get_sizes(jmi_t* jmi, int* n_ci, int* n_cd, int* n_pi, int* n_pd,
		int* n_dx, int* n_x, int* n_u, int* n_w, int* n_tp, int* n_z);

/*
 * Get the offsets for the variable types in the z vector.
 */
int jmi_get_offsets(jmi_t* jmi, int* offs_ci, int* offs_cd, int* offs_pi, int* offs_pd,
		int* offs_dx, int* offs_x, int* offs_u, int* offs_w, int* offs_t,
		int* offs_dx_p, int* offs_x_p, int* offs_u_p, int* offs_w_p, int* offs_t_p);


/**
 * Functions that gives access to the variable vectors.
 * Notice that these functions (and the variable vector)
 * is common for dae, init and opt.
 */
int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci);
int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd);
int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi);
int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd);
int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx);
int jmi_get_x(jmi_t* jmi, jmi_real_t** x);
int jmi_get_u(jmi_t* jmi, jmi_real_t** u);
int jmi_get_w(jmi_t* jmi, jmi_real_t** w);
int jmi_get_t(jmi_t* jmi, jmi_real_t** t);
int jmi_get_dx_p(jmi_t* jmi, jmi_real_t** dx_p);
int jmi_get_x_p(jmi_t* jmi, jmi_real_t** x_p);
int jmi_get_u_p(jmi_t* jmi, jmi_real_t** u_p);
int jmi_get_w_p(jmi_t* jmi, jmi_real_t** w_p);
int jmi_get_t_p(jmi_t* jmi, jmi_real_t** t_p);



/**
 * Evaluation of Jacobians.
 *
 *   eval_alg          This argument is used to select the method evaluation
 *                     for the Jacobian. JMI_DER_SYMBOLIC and JMI_DER_CPPAD
 *                     is currently supported.
 *   sparsity          This argument is a mask that selects whether
 *                     sparse or dense evaluation of the Jacobian should
 *                     be used. The constants JMI_DER_SPARSE are used to
 *                     specify a sparse Jacobian, whereas JMI_DER_DENSE_COL_MAJOR
 *                     and JMI_DER_DENSE_ROW_MAJOR are used to specify dense
 *                     column major or row major Jacobians respectively.
 *   independent_vars  This argument is used to specify which variable types
 *                     are considered to be independent variables in the Jacobian
 *                     evaluation. The constants JMI_DER_NN are used to indicate that
 *                     the Jacobian w.r.t. a particular vector should be evaluated.
 *   mask              This array has the same size as the number of column of the dense
 *                     Jacobian, and holds the value of 0 if the corresponding Jacobian
 *                     column should not be computed. If the value of an entry in
 *                     mask i 1, then the corresponding Jacobian column will be evaluated.
 *                     The evaluated Jacobian columns are stored in the first
 *                     entries of the output argument jac.
 *
 *  TODO: It may be interesting to include an additional layer that enables
 *  support for partially defined Jacobians. This would be beneficial if symbolic
 *  expressions for the Jacobian is available for some entries, but for other
 *  an AD algorithm is to be used.
 */

/*********************************************
 *
 * DAE interface
 *
 ********************************************/

/*
 * Get the number of equations in the DAE.
 */
int jmi_dae_get_sizes(jmi_t* jmi, int* n_eq_F);


/**
 * Evaluate DAE residual. The user sets the input variables by writing to
 * the vectors obtained from the functions jmi_dae_get_x, ...
 */
int jmi_dae_F(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of the DAE residual function.
 */
int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the DAE residual Jacobian.
 */
int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements in the DAE
 * residual Jacobian.
 */
int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of the DAE residual given a sparsity configuration.
 */
int jmi_dae_dF_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/*********************************************
 *
 * Initialization interface
 *
 ********************************************/

/*
 * Get the number of equations in the DAE initialization functions.
 */
int jmi_init_get_sizes(jmi_t* jmi, int* n_eq_F0, int* n_eq_F1);

/**
 * Evaluate the F0 function of the initialization system.
 */
int jmi_init_F0(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of the F0 initialization function.
 */
int jmi_init_dF0(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of the F0 initialization function.
 */
int jmi_init_dF0_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of the F0
 * initialization function.
 */
int jmi_init_dF0_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of the F0 init function given a sparsity configuration.
 */
int jmi_init_dF0_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/**
 * Evaluate the F1 function of the initialization system.
 */
int jmi_init_F1(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of the F1 initialization function.
 */
int jmi_init_dF1(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of the F1 initialization function.
 */
int jmi_init_dF1_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of the F1
 * initialization function.
 */
int jmi_init_dF1_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of the F1 init function given a sparsity configuration.
 */
int jmi_init_dF1_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/*********************************************
 *
 * Optimization interface
 *
 ********************************************/

/*
 * Get the number of equations in the optimization functions.
 */
int jmi_opt_get_sizes(jmi_t* jmi, int* n_eq_Ceq, int* n_eq_Cineq, int* n_eq_Heq, int* n_eq_Hineq);

/**
 * Evaluate the cost function J.
 */
int jmi_opt_J(jmi_t* jmi, jmi_real_t* J);

/**
 * Evaluate the Jacobian of J.
 */
int jmi_opt_dJ(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of J.
 */
int jmi_opt_dJ_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of J.
 */
int jmi_opt_J_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of the const function J given a sparsity configuration.
 */
int jmi_opt_dJ_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/**
 * Evaluate the equality constraint function Ceq.
 */
int jmi_opt_Ceq(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of Ceq.
 */
int jmi_opt_dCeq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of Ceq.
 */
int jmi_opt_dCeq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of Ceq.
 */
int jmi_opt_Ceq_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of Ceq given a sparsity configuration.
 */
int jmi_opt_dCeq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/**
 * Evaluate the equality constraint function Cineq.
 */
int jmi_opt_Cineq(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of Cineq.
 */
int jmi_opt_dCineq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of Cineq.
 */
int jmi_opt_dCineq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of Cineq.
 */
int jmi_opt_Cineq_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of Cineq given a sparsity configuration.
 */
int jmi_opt_dCineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/**
 * Evaluate the equality constraint function Heq.
 */
int jmi_opt_Heq(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of Heq.
 */
int jmi_opt_dHeq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of Heq.
 */
int jmi_opt_dHeq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of Heq.
 */
int jmi_opt_Heq_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of Heq given a sparsity configuration.
 */
int jmi_opt_dHeq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/**
 * Evaluate the equality constraint function Hineq.
 */
int jmi_opt_Hineq(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the Jacobian of Hineq.
 */
int jmi_opt_dHineq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * Returns the number of non-zeros in the Jacobian of Hineq.
 */
int jmi_opt_dHineq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * Returns the row and column indices of the non-zero elements of the Jacobian of Hineq.
 */
int jmi_opt_Hineq_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of Hineq given a sparsity configuration.
 */
int jmi_opt_dHineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

#endif
