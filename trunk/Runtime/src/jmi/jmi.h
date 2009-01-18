/** \file jmi.h */

/** \mainpage The JModelica C Runtime interface
 * 
 * \section basic The basic interface
 *
 * The basic interface can be found at the <a href="group__Jmi.html"> Jmi page </a> 
 *
 * \section opt The Optimization interface
 *
 * The optimization interface is found at
 */


/**
 * \defgroup Jmi The JMI interface
 *
 * \brief Documentation of the public JMI interface.
 *
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
 *
 * <h3> Interface specification </h3>
 *
 *   The jmi interface consists of three parts: DAE, DAE initialization and optimization.
 *   Essentially, the jmi interface consists of a collection of functions that are
 *   offered to the user for evaluation of the DAE residual, cost functions, constraints
 *   etc. These functions takes as arguments one more of the following three argument
 *   types:
 *
 *   Parameters (denoted \f$p\f$):
 *    - \f$c_i\f$   independent constant
 *    - \f$c_d\f$   dependent constants
 *    - \f$p_i\f$   independent parameters
 *    - \f$p_d\f$   dependent parameters
 *
 *    with
 *
 *      \f$ p = [c_i^T, c_d^T, p_i^T, p_d^T]^T \f$
 *
 *   Variables (denoted \f$v\f$):
 *
 *    - \f$dx\f$    differentiated variables
 *    - \f$x\f$     variables that appear differentiated
 *    - \f$u\f$     inputs
 *    - \f$w\f$     algebraic variables
 *    - \f$t\f$     time
 *   
 *    with 
 * 
 *    \f$v = [dx^T, x^T, u^T, w^T, t]^T\f$
 *
 *   Variables defined at particular time instants (denoted \f$q\f$):
 *
 *      - \f$dx(t_i)\f$    differentiated variables evaluated at time \f$t_i, i \in 1..n_{tp}\f$
 *      - \f$x(t_i)\f$     variables that appear differentiated evaluated at time \f$t_i, t_i \in 1..n_{tp}\f$
 *      - \f$u(t_i)\f$     inputs evaluated at time \f$t_i, i \in 1..n_{tp}\f$
 *      - \f$w(t_i)\f$     algebraic variables evaluated at time \f$t_i, i \in 1..n_{tp}\f$
 *
 *    \f$ q = [dx(t_1)^T, x(t_1)^T, u(t_1)^T, w(t_1)^T, ...,
 *           dx(t_{n_{tp}})^T, x(t_{n_{tp}})^T, u(t_{n_{tp}})^T, w(t_{n_{tp}})^T]^T\f$
 *
 *   All parameters, variables and point-wise evaluated variables are denoted z:
 *
 *     \f$ z = [p^T, v^T, q^T]^T \f$
 *
 *   <h4> The DAE interface </h4>
 *
 *   The DAE interface is defined by the residual function
 *
 *     \f$ F(p,v) = 0 \f$
 *
 *    <h4> The DAE initialization interface </h4>
 *
 *	 The DAE initialization interface is defined by the functions
 *
 *	  \f$  F_0(p,v) = 0 \f$<br>
 *	  \f$  F_1(p,v) = 0 \f$
 *
 *   \f$F_0\f$ represents the DAE system augmented with additional initial equations
 *   and start values that are fixed. \f$F_1\f$ on the other hand contains equations for
 *   initialization of variables for which the value given in the start attribute is
 *   not fixed.
 *
 *   <h4> The optimization interface </h4>
 *
 *   The optimization part of the interface is defined by the functions
 *
 *      \f$J(p,q)\f$<br>
 *      \f$C_{eq}(p,v,q) = 0\f$<br>
 *      \f$C_{ineq}(p,v,q) \leq 0\f$<br>
 *      \f$H_{eq}(p,q) = 0\f$<br>
 *      \f$H_{ineq}(p,q) \leq 0\f$<br>
 *
 *   where \f$J\f$ is the cost function to be minimized, \f$C_{eq}\f$ are path equality constraints,
 *   \f$C_{ineq}\f$ are path inequality constraints, \f$H_{eq}\f$ are (time) point equality constraints,
 *   and \f$H_{ineq}\f$ are (time) point inequality constraints. The rationale for introducing
 *   \f$H_{eq}\f$ and \f$H_{ineq}\f$ is to enable expression of e.g. terminal constraints.
 *
 */

#ifndef _JMI_H
#define _JMI_H

#include "jmi_common.h"

/* @{ */


/**
 * \defgroup Defines Defined constants
 */
/* @{ */

#define JMI_INF 1e20;

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

/* @} */

/*
 *****************************************
 *
 *    Public interface
 *
 ****************************************
 */

/**
 * \defgroup Constructors Creation, initialization and destruction of jmi_t structs
 */

/* @{ */

/** 
 * \brief Create a new jmi_t struct.
 * 
 * This function creates a new jmi struct, for which a pointer is returned in the output argument jmi.
 * Typically this function is defined in the generated code.
 *
 * @param jmi A pointer to a jmi_t pointer where the new jmi_t struct is stored.
 */
int jmi_new(jmi_t** jmi);

/** 
 * Initializes the AD variables and tapes. Prior to this call, the variables in z should
 * be initialized, which is also the reason why this function must be provided for
 * the user to call after the actual creation of the jmi_t struct.
 *
 * @param jmi A pointer to a jmi_t struct.
 */
int jmi_ad_init(jmi_t* jmi);

/**
 * Deallocates memory and deletes a jmi_t struct.
 * 
 * @param jmi A pointer to the jmi_t struc to be deleted.
 */
int jmi_delete(jmi_t* jmi);

/* @} */

/**
 * \defgroup Access Setters and getters for the fields in jmi_t
 */

/* @{ */

/**
 * Get the sizes of the variable vectors.
 */
int jmi_get_sizes(jmi_t* jmi, int* n_ci, int* n_cd, int* n_pi, int* n_pd,
		int* n_dx, int* n_x, int* n_u, int* n_w, int* n_tp, int* n_z);

/**
 * Get the offsets for the variable types in the z vector.
 */
int jmi_get_offsets(jmi_t* jmi, int* offs_ci, int* offs_cd, int* offs_pi, int* offs_pd,
		int* offs_dx, int* offs_x, int* offs_u, int* offs_w, int* offs_t,
		int* offs_dx_p, int* offs_x_p, int* offs_u_p, int* offs_w_p);

/**
 * Set the vector of time points included in the problem.
 */
int jmi_set_tp(jmi_t *jmi, jmi_real_t *tp);

/**
 * Get the number of time points.
 */
int jmi_get_n_tp(jmi_t *jmi, int *n_tp);

/**
 * Get the vector of time points included in the problem.
 */
int jmi_get_tp(jmi_t *jmi, jmi_real_t *tp);



/**
 * Function that gives access to a variable vector.
 * Notice that these functions (and the variable vector)
 * is common for the DAE, Initialization and Optimization interfaces.
 */
jmi_real_t* jmi_get_ci(jmi_t* jmi);
jmi_real_t* jmi_get_cd(jmi_t* jmi);
jmi_real_t* jmi_get_pi(jmi_t* jmi);
jmi_real_t* jmi_get_pd(jmi_t* jmi);
jmi_real_t* jmi_get_dx(jmi_t* jmi);
jmi_real_t* jmi_get_x(jmi_t* jmi);
jmi_real_t* jmi_get_u(jmi_t* jmi);
jmi_real_t* jmi_get_w(jmi_t* jmi);
jmi_real_t* jmi_get_t(jmi_t* jmi);
jmi_real_t* jmi_get_dx_p(jmi_t* jmi,int i);
jmi_real_t* jmi_get_x_p(jmi_t* jmi, int i);
jmi_real_t* jmi_get_u_p(jmi_t* jmi, int i);
jmi_real_t* jmi_get_w_p(jmi_t* jmi, int i);



/* @} */

/**
 * \defgroup Misc Misc. 
 */
/* @{ */

/**
 * Print a summary of the content of the jmi struct.
 */
void jmi_print_summary(jmi_t *jmi);

/* @} */


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

/**
 * \defgroup DAE DAE interface 
 */
/* @{ */


/**
 * \brief Get the number of equations of the DAE.
 *
 * @param jmi A jmi_t struct.
 * @param n_eq_F (Output) The number of DAE equations is stored in this argument.
 * @return Error code.
 */
int jmi_dae_get_sizes(jmi_t* jmi, int* n_eq_F);


/**
 * \brief Evaluate DAE residual. The user sets the input variables by writing to
 * the vectors obtained from the functions jmi_dae_get_x, ...
 */
int jmi_dae_F(jmi_t* jmi, jmi_real_t* res);

/**
 * \brief Evaluate the Jacobian of the DAE residual function.
 */
int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac);

/**
 * \brief Returns the number of non-zeros in the DAE residual Jacobian.
 */
int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz);

/**
 * \brief Returns the row and column indices of the non-zero elements in the DAE
 * residual Jacobian.
 */
int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
		                  int *mask, int* row, int* col);

/**
 * \brief This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of the DAE residual given a sparsity configuration.
 */
int jmi_dae_dF_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/* @} */

/*********************************************
 *
 * Initialization interface
 *
 ********************************************/

/**
 * \defgroup Initialization DAE Initialization Interface
 */
/* @{ */

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
int jmi_init_dF0_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

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
int jmi_init_dF1_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of the F1 init function given a sparsity configuration.
 */
int jmi_init_dF1_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);


/* @} */


/*********************************************
 *
 * Optimization interface
 *
 ********************************************/

/**
 * \defgroup Optimization Optimization interface
 */
/* @{ */


/**
 * Set the optimization interval. This function should be called prior to using other
 * functions in the optimization interface.
 */
int jmi_opt_set_optimization_interval(jmi_t *jmi, double start_time, int start_time_free,
		                              double final_time, int final_time_free);


/**
 * Specify the optimization interval.
 */
int jmi_opt_set_optimization_interval(jmi_t *jmi, double start_time, int start_time_free,
		                              double final_time, int final_time_free);

/**
 * Get the optimization interval.
 */
int jmi_opt_get_optimization_interval(jmi_t *jmi, double *start_time, int *start_time_free,
		                              double *final_time, int *final_time_free);


/**
 * Specify optimization parameters. p_opt_indices contains the indices of the
 * parameters to be optimized in the pi vector.
 */
int jmi_opt_set_p_opt_indices(jmi_t *jmi, int n_p_opt, int *p_opt_indices);

/**
 * Get the number of optimization parameters.
 */
int jmi_opt_get_n_p_opt(jmi_t *jmi, int *n_p_opt);

/**
 * Get the optimization parameter indices.
 */
int jmi_opt_get_p_opt_indices(jmi_t *jmi, int *p_opt_indices);



/**
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
int jmi_opt_dJ_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

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
int jmi_opt_dCeq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

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
int jmi_opt_dCineq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

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
int jmi_opt_dHeq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

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
int jmi_opt_Hineq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col);

/**
 * This helper function computes the number of columns and the number of non zero
 * elements in the Jacobian of Hineq given a sparsity configuration.
 */
int jmi_opt_dHineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz);

/* @} */

#endif


/* @} */
