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
 * python extensions framework.
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
 *
 *      This interface describes a DAE on the form
 *
 *        F(ci,cd,pi,pd,dx,x,u,w,t) = 0
 *
 *      were
 *
 *        ci   independent constant
 *        cd   dependent constants
 *        pi   independent parameters
 *        pd   dependent parameters
 *
 *        dx    differentiated variables
 *        x     variables whos derivatives appear in the DAE
 *        u     inputs
 *        w     algebraic variables
 *        t     time
 *
 * In the interface, all variable vectors, and t, are concatenated into one, which is denoted z.
 *
 *	     This interface also contains a specification of a DAE initialization
 *	     system on the form
 *
 *	      F0(ci,cd,pi,pd,dx,x,u,w,t0) = 0
 *	      F1(ci,cd,pi,pd,dx,x,u,w,t0) = 0
 *
 *	    were
 *
 *	      ci   independent constant
 *	      cd   dependent constants
 *	      pi   independent parameters
 *	      pd   dependent parameters
 *
 * 	      dx    differentiated variables
 *	      x     variables whos derivatives appear in the DAE
 *	      u     inputs
 *	      w     algebraic variables
 *	      t0     time
 *
 *	 	F0 represents the DAE system augmented with additional initial equations
 *	 	and start values that are fixed. F1 on the other hand contains equations for
 *	 	initialization of variables for which the value given in the start attribute is
 *	 	not fixed.
 *
 *      Interface also contains the optimization-specific parts of an Optimica
 *      problem:
 *
 *       - A cost function:
 *
 *         J(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t) to minimize
 *
 *       - Equality path constraints:
 *
 *         Ceq(ci,cd,pi,pd,dx,x,u,w,t) = 0
 *
 *       - Inequality path constraints:
 *
 *         Cineq(ci,cd,pi,pd,dx,x,u,w,t) <= 0
 *
 *       - Equality point constraints:
 *
 *         Heq(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t_p) = 0
 *
 *       - Inequality point constraints:
 *
 *         Hineq(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t_p) <= 0
 *
 *      where dx_p, x_p, u_p, w_p and t_p denotes variables at
 *      certain points in time. This is used describe initial and
 *      terminal conditions, e.g. **This sematics needs to be specified.**
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

#define JMI_DER_CI 1
#define JMI_DER_CD 2
#define JMI_DER_PI 4
#define JMI_DER_PD 8
#define JMI_DER_DX 16
#define JMI_DER_X 32
#define JMI_DER_U 64
#define JMI_DER_W 128
#define JMI_DER_T 256

#define JMI_DER_ALL JMI_DER_CI | JMI_DER_CD | JMI_DER_PI | JMI_DER_PD |\
	JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W |\
	JMI_DER_T

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
		int* n_dx, int* n_x, int* n_u, int* n_w);

/*
 * Get the offsets for the variable types in the z vector.
 */
int jmi_get_offsets(jmi_t* jmi, int* offs_ci, int* offs_cd, int* offs_pi, int* offs_pd,
		int* offs_dx, int* offs_x, int* offs_u, int* offs_w, int* offs_t);

/*
 * Get the number of equations in the DAE.
 */
int jmi_dae_get_sizes(jmi_t* jmi, int* n_eq_F);

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

/**
 * Evaluate DAE residual. The user sets the input variables by writing to
 * the vectors obtained from the functions jmi_dae_get_x, ...
 */
int jmi_dae_F(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluation of the Jacobian of the DAE residual.
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


/**
 * Evaluate the symbolic Jacobian of the DAE residual function.
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

/**
 * Evaluate the F0 function of the initialization system.
 */
int jmi_init_F0(jmi_t* jmi, jmi_real_t* res);

/**
 * Evaluate the symbolic Jacobian of the F0 initialization function.
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
 * Evaluate the symbolic Jacobian of the F1 initialization function.
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


#endif
