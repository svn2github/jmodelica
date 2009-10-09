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



/** \file jmi_common.h
 *  \brief Internals of the JMI Model interface.
 */

#ifndef _JMI_COMMON_H
#define _JMI_COMMON_H

#include <stdio.h>
#include <stdlib.h>

/**
 * \defgroup Jmi_internal Internal functions of the JMI Model \
 * interface.
 *
 * \brief Documentation of the internal functions and data structures
 * of the JMI Model interface.
 *
 * The JMI Model interface is supported by internal data structures
 * and functions which are described in the following. The internal
 * data structures support the the use of CppAD (see
 * http://www.coin-or.org/CppAD/) a package for automatic
 * differentiation. CppAD is based in operator overloading in and is
 * written in C++. Accordingly, the JMI Runtime Library needs to be
 * compiled with a C++ compiler in order to use CppAD. On the other
 * hand, for some applications it is desirable to compile the Runtime
 * Library using a pure C compiler. In order to accommodate these two
 * situations, there are two sets of typedefs for some of the internal
 * data structures: one set for the case of C++ compilation with CppAD
 * and one set of typedefs for the case of C compilation without
 * CppAD. By setting the constant JMI_AD to either JMI_AD_NONE or
 * JMI_AD_CPPAD (typically done by a compiler directive (switch -D if
 * gcc is used)), the correct set of typedefs are included.
 *
 * \section jmi_func_t Representation of functions
 *
 * All the mathematical functions defined in the JMI Model interface
 * are functions of independent variables contained in \f$z\f$. It is
 * therefore convenient to introduce an abstraction of a general
 * function \f$F(z)\f$, which can then be used to represent all
 * functions in the JMI Model interface. This abstraction is
 * materilized by the jmi_func_t struct. This struct contains function
 * pointers for evaluation of the function and its derivatives, as
 * well as sparsity information. In addition, jmi_func_t may contain
 * data structures for evaluation of derivatives by means of CppAD.
 *
 * \section jmi_jmi_t JMI Model interface structs
 *
 * The main struct of the JMI model interface is jmi_t. An instance of
 * this struct is passed as the first argument to most functions in
 * the JMI model interface and can be viewed as an object
 * corresponding to a particular model. jmi_t contains dimension
 * information of the model and one or several of the structs
 * - jmi_dae_t which contains the DAE residual function.
 * - jmi_init_t which contains the DAE initialization functions.
 * - jmi_opt_t which contains the cost function, the constraint
 *   functions, and a specification of the optimization interval.
 * If one of the structs are not present in jmi_t, the corresponding
 * pointer is set to NULL.
 *
 * \section jmi_internal_init Initialization of interal JMI Model \
 * interface structs
 *
 * Instances of jmi_t are created by a call to ::jmi_new, which is a
 * function that is typically defined in the generated model code.
 * The creation of a jmi_t struct proceeds in three
 * steps:
 *   - First, a raw struct is created by the function ::jmi_init. In
 *   this function, the dimensions of the variable vectors are set,
 *   but no substructs are initialized.
 *   - Then the jmi_dae_t, jmi_init_t, and jmi_opt_t structs are
 *   initialized by the functions ::jmi_dae_init, ::jmi_init_init, and
 *   ::jmi_opt_init respectively. In these function calls, the
 *   corresponding function pointers are set and new jmi_func_t
 *   structs are created.
 *   - Finlly, the the AD structs (jmi_func_ad_t) are set up in the
 *   function call ::jmi_ad_init. Notice that the variable vectors
 *   should have been initialized prior to the call to ::jmi_ad_init.
 *   Such initialization usually requires access to XML meta-data
 *   files, which is done outside of the generated code.
 *   Accordingly, the AD initialization must be done from the user
 *   code after ::jmi_new has returned a valid jmi_t instance.
 *
 * Typically, ::jmi_init, ::jmi_dae_init, ::jmi_init_init, and
 * ::jmi_opt_init are called from within the ::jmi_new function. The
 * function jmi_ad_init is then called from the user code after the
 * variable vectors has been initialized.
 *
 */

/* @{ */

/**
 * \defgroup jmi_internal_defines Defines
 * \brief Defined constants.
 */

/* @{ */

#define JMI_AD_NONE 0 /**< \brief No CppAD support.*/
#define JMI_AD_CPPAD 1 /**< \brief CppAD support. */

/* @} */

/**
 * \defgroup jmi_internal_typedefs Typedefs
 * \brief Internal typedefs.
 */

/* @{ */

/*
 *  TODO: Error codes...
 *  Introduce #defines to denote different error codes
 */

#if JMI_AD == JMI_AD_CPPAD
// This must be done outside of 'extern "C"'
#include <cppad/cppad.hpp>
#include <vector>
#endif

// Forward declaration of jmi structs
typedef struct jmi_t jmi_t;  ///< Forward declaration of struct.
typedef struct jmi_dae_t jmi_dae_t; ///< Forward declaration of struct.
typedef struct jmi_init_t jmi_init_t; ///< Forward declaration of struct.
typedef struct jmi_opt_t jmi_opt_t; ///< Forward declaration of struct.
typedef struct jmi_func_t jmi_func_t; ///< Forward declaration of struct.
typedef struct jmi_func_ad_t jmi_func_ad_t; ///< Forward declaration of struct.

// Typedef for the doubles used in the interface.
typedef double jmi_real_t; ///< Typedef for the real number
			   ///< representation used in the Runtime
			   ///< Library.

// This section defines types in the case of no AD and
// in the case of CppAD.
#if JMI_AD == JMI_AD_NONE
typedef jmi_real_t jmi_ad_var_t;                       ///< If JMI_AD_NONE: alias for jmi_real_t.<br>
                                                       ///< If JMI_AD_CPPAD: an active AD object.
typedef jmi_real_t *jmi_real_vec_t;                    ///< If JMI_AD_NONE: a vector of jmi_real_ts.<br>
                                                       ///< If JMI_AD_CPPAD: a vector of jmi_real_ts.
typedef jmi_real_vec_t *jmi_real_vec_p;                ///< If JMI_AD_NONE: a pointer to a vector of jmi_real_ts.<br>
                                                       ///< If JMI_AD_CPPAD: a pointer to a vector of jmi_real_ts.
typedef jmi_real_t *jmi_ad_var_vec_t;                  ///< If JMI_AD_NONE: a vector of jmi_real_ts.<br>
                                                       ///< If JMI_AD_CPPAD: a vector of active AD objecs.
typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;            ///< If JMI_AD_NONE: a pointer to a vector of jmi_real_ts.<br>
                                                       ///< If JMI_AD_CPPAD: a pointer to a vector of active AD objecs.
typedef void jmi_ad_tape_t;                            ///< If JMI_AD_NONE: void (not used).<br>
                                                       ///< If JMI_AD_CPPAD: an AD tape.
typedef jmi_ad_tape_t *jmi_ad_tape_p;                  ///< If JMI_AD_NONE: a pointer to void (not used).<br>

#define COND_EXP_EQ(op1,op2,th,el) ((op1==op2)? (th): (el)) ///< Macro for conditional expression == <br>
#define COND_EXP_LE(op1,op2,th,el) ((op1<=op2)? (th): (el)) ///< Macro for conditional expression <= <br>
#define COND_EXP_LT(op1,op2,th,el) ((op1<op2)? (th): (el)) ///< Macro for conditional expression < <br>
#define COND_EXP_GE(op1,op2,th,el) ((op1>=op2)? (th): (el)) ///< Macro for conditional expression >= <br>
#define COND_Exp_GT(op1,op2,th,el) ((op1>op2)? (th): (el)) ///< Macro for conditional expression > <br>

#define AD_WRAP_LITERAL(x) x ///< Macro for inserting an AD object based on a literal. Has no effect when compiling without CppAD  <br>

#elif JMI_AD == JMI_AD_CPPAD
typedef CppAD::AD<jmi_real_t> jmi_ad_var_t;
typedef std::vector<jmi_real_t> jmi_real_vec_t;
typedef jmi_real_vec_t *jmi_real_vec_p;
typedef std::vector< jmi_ad_var_t > jmi_ad_var_vec_t;
typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;
typedef CppAD::ADFun<jmi_real_t> jmi_ad_tape_t;
typedef jmi_ad_tape_t *jmi_ad_tape_p;

#define COND_EXP_EQ(op1,op2,th,el) (CppAD::CondExpEq(op1,op2,th,el))
#define COND_EXP_LE(op1,op2,th,el) (CppAD::CondExpLe(op1,op2,th,el))
#define COND_EXP_LT(op1,op2,th,el) (CppAD::CondExpLt(op1,op2,th,el))
#define COND_EXP_GE(op1,op2,th,el) (CppAD::CondExpGe(op1,op2,th,el))
#define COND_EXP_GT(op1,op2,th,el) (CppAD::CondExpGt(op1,op2,th,el))

#define AD_WRAP_LITERAL(x) CppAD::AD<jmi_real_t>(x)

#else
#error "The directive JMI_AD_NONE or JMI_AD_CPPAD must be set"
#endif

/**
 * Function to wrap division and report errors.
 */
jmi_ad_var_t jmi_divide(jmi_ad_var_t num, jmi_ad_var_t den,const char msg[]);

/* @} */

/**
 * \defgroup jmi_function_typedefs Function typedefs
 *
 * \brief Function signatures to be used in the generated code
 */

/* @{ */

/**
 * \brief Function signature for evaluation of a residual function in
 * the generated code.
 *
 * Notice that this function signature is used for all functions in
 * the DAE, DAE initialization, and Optimization interfaces. Notice
 * that this definition supports both C compilation and C++
 * compilation with CppAD.
 *
 * @param jmi A jmi_t struct.
 * @param res (Output) The residual value.
 * @return Error code.
 *
 */
typedef int (*jmi_residual_func_t)(jmi_t* jmi, jmi_ad_var_vec_p res);

/**
 * \brief Evaluation of symbolic jacobian of a residual function in
 * generated code.
 *
 * Notice that this function signature is used for all functions in
 * the DAE, DAE initialization, and Optimization interfaces. Notice
 * that this definition supports both C compilation and C++
 * compilation with CppAD.
 *
 * @param jmi A jmi_t struct.
 * @param sparsity See ::jmi_dae_dF.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param res (Output) The residual value.
 * @return Error code.
 */
typedef int (*jmi_jacobian_func_t)(jmi_t* jmi, int sparsity,
             int independent_vars, int* mask, jmi_real_t* jac);

/* @} */

/**
 * \defgroup jmi_func_t The jmi_func_t struct
 *
 * \brief Functions for creating, deleting and evaluating jmi_func_t
 * functions.
 *
 */

/* @{ */


/**
 * \brief Create a new jmi_func_t.
 *
 * @param jmi_func (Output) A double pointer to a jmi_func_t struct.
 * @param F A function pointer to the residual function.
 * @param n_eq_F The number of equations in the residual.
 * @param dF Function pointer to the symbolic Jacobian function.
 * @param dF_n_nz The number of non-zeros in the symbolic Jacobian.
 * @param dF_row Row indices of the non-zero elements in the symbolic Jacobian.
 * @param dF_col Column indices of the non-zero elements in the symbolic
 *        Jacobian.
 * @return Error code.
 *
 */
int jmi_func_new(jmi_func_t** jmi_func, jmi_residual_func_t F,
                 int n_eq_F, jmi_jacobian_func_t dF,
		 int dF_n_nz, int* dF_row, int* dF_col);

/**
 * \brief Delete a jmi_func_t.
 *
 * @param func The jmi_func_t struct to delete.
 * @return Error code.
 */
int jmi_func_delete(jmi_func_t *func);

/**
 * \brief Evaluate the residual function of a jmi_func_t struct.
 *
 * @param jmi The jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param res (Output) The residual values.
 * @return Error code.
 *
 */
int jmi_func_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res);

/**
 * \brief Evaluation of the symbolic Jacobian of the
 * residual function contained in a jmi_func_t.
 *
 * @param jmi The jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param sparsity See ::jmi_dae_dF.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param jac (Output) The Jacobian
 *
 */
int jmi_func_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
		int independent_vars, int* mask, jmi_real_t* jac) ;

/**
 * \brief Returns the number of non-zeros in the symbolic Jacobian.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param n_nz (Output) The number of non-zero Jacobian entries.
 * @return Error code.
 */
int jmi_func_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz);

/**
 * \brief Returns the row and column indices of the non-zero elements in the
 * symbolic residual Jacobian.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param row (Output) The row indices of the non-zeros in the DAE residual
 *            Jacobian.
 * @param col (Output) The column indices of the non-zeros in the DAE residual
 *            Jacobian.
 * @return Error code.
 *
 */
int jmi_func_dF_nz_indices(jmi_t *jmi, jmi_func_t *func,
                           int independent_vars,
                           int *mask, int *row, int *col);

/**
 * \brief Computes the number of columns and the number of non-zero
 * elements in the symbolic Jacobian of a jmi_func_t given a sparsity
 * configuration.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param sparsity See ::jmi_dae_dF.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param dF_n_cols (Output) The number of columns of the resulting Jacobian.
 * @param dF_n_nz (Output) The number of non-zeros of the resulting Jacobian.
 *
 */
int jmi_func_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity,
                    int independent_vars, int *mask,
		    int *dF_n_cols, int *dF_n_nz);

/**
 * \brief Data structure for representing a single function
 * \f$F(z)\f$.
 *
 * jmi_func_t is a struct that contains function pointers and
 * dimension information corresponding to a mathematical vector valued
 * function, \f$F(z)\f$. The struct also contains function pointers to
 * symbolic Jacobians and associated sparsity information and a
 * pointer to a jmi_func_ad_t struct containing AD data (if compiled
 * with AD support).
 */
struct jmi_func_t{
	jmi_residual_func_t F; ///< \brief Pointer to a function for evaluation of \f$F(z)\f$.
	jmi_jacobian_func_t dF; ///< \brief Pointer to a function for evaluation of the Jacobian of \f$F(z)\f$.
	int n_eq_F; ///< \brief Size of the function.
	int dF_n_nz; ///< \brief Number of non-zeros in the symbolic Jacobian of \f$F(z)\f$ (if available).
	int* dF_row; ///< \brief Row indices of the non-zero elements in the symbolic Jacobian of \f$F(z)\f$ (if available).
	int* dF_col; ///< \brief Column indices of the non-zero elements in the symbolic Jacobian of \f$F(z)\f$ (if available).
	jmi_func_ad_t* ad; ///< \brief Pointer to a jmi_func_ad_t struct containing AD information (if compiled with AD support).
};

/**
 * \brief Contains data structures for CppAD.
 *
 * The struct jmi_func_ad_t contains a tape and associated sparsity
 * information for a particular jmi_func_t struct.
 */
struct jmi_func_ad_t{
	jmi_ad_var_vec_p F_z_dependent; ///< \brief A vector containing active AD independent objects for use
	                                ///< by CppAD.
	jmi_ad_tape_p F_z_tape;         ///< \brief An AD tape.
	int tape_initialized;           ///< \brief Flag to indicate if the other fields are initialized.
	                                ///< 0 if uninitialized and 1 if initialized.
	int dF_z_n_nz;                  ///< \brief Number of non-zeros in Jacobian.
	int* dF_z_row;                  ///< \brief Row indices of non-zeros in Jacobian.
	int* dF_z_col;                  ///< \brief Column indices of non-zeros in Jacobian.
	jmi_real_vec_p z_work;          ///< A work vector for \f$z\f$.
};

/* @} */

/**
 * \defgroup jmi_structs_init The jmi_t, jmi_dae_t, jmi_init_t, and \
 * jmi_opt_t structs
 *
 * \brief Functions for initialization of the jmi_t, jmi_dae_t,
 * jmi_init_t, and jmi_opt_t structs.
 *
 */

/* @{ */

/**
 * \brief Allocates memory and sets up the jmi_t struct.
 *
 * This function is typically called from within jmi_new in the generated code.
 * The reason for introducing this function is that the allocation of the
 * jmi_t struct should not be repeated in the generated code.
 *
 * @param jmi (Output) A pointer to a jmi_t pointer.
 * @param n_ci Number of independent constants.
 * @param n_cd Number of dependent constants.
 * @param n_pi Number of independent parameters.
 * @param n_pd Number of dependent parameters.
 * @param n_dx Number of derivatives.
 * @param n_x Number of differentiated variables.
 * @param n_u Number of inputs.
 * @param n_w Number of algebraics.
 * @param n_tp Number of interpolation time points.
 * @return Error code.
 */
int jmi_init(jmi_t** jmi, int n_ci, int n_cd, int n_pi, int n_pd, int n_dx,
		int n_x, int n_u, int n_w, int n_tp);

/**
 * \brief Allocates a jmi_dae_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F A function pointer to the DAE residual function.
 * @param n_eq_F Number of equations in the DAE residual.
 * @param dF Function pointer to the symbolic Jacobian function.
 * @param dF_n_nz Number of non-zeros in the symbolic jacobian.
 * @param dF_row Row indices of the non-zeros in the symbolic Jacobain.
 * @param dF_col Column indices of the non-zeros in the symbolic Jacobain.
 * @param R A function pointer to the DAE event indicator residual function.
 * @param n_eq_R Number of equations in the event indicator function.
 * @param dR Function pointer to the symbolic Jacobian function.
 * @param dR_n_nz Number of non-zeros in the symbolic jacobian.
 * @param dR_row Row indices of the non-zeros in the symbolic Jacobain.
 * @param dR_col Column indices of the non-zeros in the symbolic Jacobain.
 * @return Error code.
 */
int jmi_dae_init(jmi_t* jmi, jmi_residual_func_t F, int n_eq_F,
        jmi_jacobian_func_t dF, int dF_n_nz, int* dF_row, int* dF_col,
        jmi_residual_func_t R, int n_eq_R,
        jmi_jacobian_func_t dR, int dR_n_nz, int* dR_row, int* dR_col);

/**
 * \brief Allocates a jmi_init_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F0 A function pointer to the DAE initialization residual function
 * \f$F_0\f$.
 * @param n_eq_F0 Number of equations in the DAE initialization residual
 *        function \f$F_0\f$.
 * @param dF0 Function pointer to the symbolic Jacobian of \f$F_0\f$.
 * @param dF0_n_nz Number of non-zeros in the symbolic jacobian of \f$F_0\f$.
 * @param dF0_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$F_0\f$.
 * @param dF0_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$F_0\f$.
 * @param F1 A function pointer to the DAE initialization residual function
 * \f$F_1\f$.
 * @param n_eq_F1 Number of equations in the DAE initialization residual
 *        function \f$F_1\f$.
 * @param dF1 Function pointer to the symbolic Jacobian of \f$F_1\f$.
 * @param dF1_n_nz Number of non-zeros in the symbolic jacobian of \f$F_1\f$.
 * @param dF1_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$F_1\f$.
 * @param dF1_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$F_1\f$.
 * @param Fp A function pointer to the DAE initialization residual function
 * \f$F_p\f$.
 * @param n_eq_Fp Number of equations in the DAE initialization residual
 *        function \f$F_p\f$.
 * @param dFp Function pointer to the symbolic Jacobian of \f$F_p\f$.
 * @param dFp_n_nz Number of non-zeros in the symbolic jacobian of \f$F_p\f$.
 * @param dFp_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$F_p\f$.
 * @param dFp_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$F_p\f$.
 * @param R0 A function pointer to the DAE event indicator residual function.
 * @param n_eq_R0 Number of equations in the event indicator function.
 * @param dR0 Function pointer to the symbolic Jacobian function.
 * @param dR0_n_nz Number of non-zeros in the symbolic jacobian.
 * @param dR0_row Row indices of the non-zeros in the symbolic Jacobain.
 * @param dR0_col Column indices of the non-zeros in the symbolic Jacobain.
 * @return Error code.
 *
 */
int jmi_init_init(jmi_t* jmi, jmi_residual_func_t F0, int n_eq_F0,
		  jmi_jacobian_func_t dF0,
		  int dF0_n_nz, int* dF0_row, int* dF0_col,
		  jmi_residual_func_t F1, int n_eq_F1,
		  jmi_jacobian_func_t dF1,
		  int dF1_n_nz, int* dF1_row, int* dF1_col,
		  jmi_residual_func_t Fp, int n_eq_Fp,
		  jmi_jacobian_func_t dFp,
		  int dFp_n_nz, int* dFp_row, int* dFp_col,
		  jmi_residual_func_t R0, int n_eq_R0,
		  jmi_jacobian_func_t dR0,
		  int dR0_n_nz, int* dR0_row, int* dR0_col);

/**
 * \brief Allocates a jmi_opt_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param J A function pointer to the cost function \f$J\f$.
 * @param dJ Function pointer to the symbolic Jacobian of \f$J\f$.
 * @param dJ_n_nz Number of non-zeros in the symbolic jacobian of \f$J\f$.
 * @param dJ_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$J\f$.
 * @param dJ_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$J\f$.
 * @param Ceq A function pointer to the equality path constraint residual
 * function \f$C_{eq}\f$.
 * @param n_eq_Ceq Number of equations in the equality path constraint residual
 *        \f$C_{eq}\f$.
 * @param dCeq Function pointer to the symbolic Jacobian of \f$C_{eq}\f$.
 * @param dCeq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$C_{eq}\f$.
 * @param dCeq_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$C_{eq}\f$.
 * @param dCeq_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$C_{eq}\f$.
 * @param Cineq A function pointer to the inequality path constraint residual
 * function \f$C_{ineq}\f$.
 * @param n_eq_Cineq Number of equations in the inequality path constraint
 *        residual \f$C_{ineq}\f$.
 * @param dCineq Function pointer to the symbolic Jacobian of \f$C_{ineq}\f$.
 * @param dCineq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$C_{ineq}\f$.
 * @param dCineq_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$C_{ineq}\f$.
 * @param dCineq_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$C_{ineq}\f$.
 * @param Heq A function pointer to the equality point constraint residual
 * function \f$H_{eq}\f$.
 * @param n_eq_Heq Number of equations in the equality point constraint residual
 *        \f$H_{eq}\f$.
 * @param dHeq Function pointer to the symbolic Jacobian of \f$H_{eq}\f$.
 * @param dHeq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$H_{eq}\f$.
 * @param dHeq_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$H_{eq}\f$.
 * @param dHeq_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$H_{eq}\f$.
 * @param Hineq A function pointer to the inequality point constraint residual
 * function \f$H_{ineq}\f$.
 * @param n_eq_Hineq Number of equations in the inequality point constraint
 *        residual \f$H_{ineq}\f$.
 * @param dHineq Function pointer to the symbolic Jacobian of \f$H_{ineq}\f$.
 * @param dHineq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$H_{ineq}\f$.
 * @param dHineq_row Row indices of the non-zeros in the symbolic Jacobain
 *        of \f$H_{ineq}\f$.
 * @param dHineq_col Column indices of the non-zeros in the symbolic Jacobain
 *        of \f$H_{ineq}\f$.
 * @return Error code.
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

/**
 * \brief The main struct of the JMI Model interface containing
 * dimension information and pointers to jmi_dae_t, jmi_init_t, and
 * jmi_opt_t structs.
 *
 * jmi_t is the main struct in the JMI model interface. It contains
 * pointers to structs of types jmi_dae_t, jmi_init_t, and jmi_opt_t
 * to represent the DAE, DAE initialization and Optimization
 * interfaces.
 */
struct jmi_t{
  jmi_dae_t* dae;                        ///< \brief A jmi_dae_t struct pointer.
	jmi_init_t* init;                    ///< \brief A jmi_init_t struct pointer.
	jmi_opt_t* opt;                      ///< \brief A jmi_opt_t struct pointer.

	int n_ci;                            ///< \brief Number of independent constants.
	int n_cd;                            ///< \brief Number of dependent constants.
	int n_pi;                            ///< \brief Number of independent parameters.
	int n_pd;                            ///< \brief Number of dependent parameters.
	int n_dx;                            ///< \brief Number of derivatives.
	int n_x;                             ///< \brief Number of differentiated states.
	int n_u;                             ///< \brief Number of inputs.
	int n_w;                             ///< \brief Number of algebraics.

	int n_p;                             ///< \brief Number of elements in \f$p\f$.
	int n_v;                             ///< \brief Number of elements in \f$v\f$.
	int n_q;                             ///< \brief Number of elements in \f$q\f$.
	int n_z;                             ///< \brief Number of elements in \f$z\f$.

	int n_tp;                            ///< \brief Number of time points included in the optimization problem
	jmi_real_t *tp;                      ///< \brief Time point values in the normalized interval [0..1].
	                                     ///< A value \f$\leq 0\f$ corresponds to the initial time and
	                                     ///< a value \f$\geq 1\f$ corresponds to the final time.

	// Offset variables in the z vector, for convenience.
	int offs_ci;                         ///< Offset of the independent constant vector in \f$z\f$.
	int offs_cd;                         ///< Offset of the dependent constant vector in \f$z\f$.
	int offs_pi;                         ///< Offset of the independent parameter vector in \f$z\f$.
	int offs_pd;                         ///< Offset of the dependent parameter vector in \f$z\f$.
	int offs_dx;                         ///< Offset of the derivative vector in \f$z\f$.
	int offs_x;                          ///< Offset of the differentiated variable vector in \f$z\f$.
	int offs_u;                          ///< Offset of the input vector in \f$z\f$.
	int offs_w;                          ///< Offset of the algebraic variables vector in \f$z\f$.
	int offs_t;                          ///< Offset of the time entry in \f$z\f$.
	int offs_dx_p;                       ///< Offset of the first time point derivative vector in \f$z\f$.
	int offs_x_p;                        ///< Offset of the first time point differentiated variable vector in \f$z\f$.
	int offs_u_p;                        ///< Offset of the first time point input vector in \f$z\f$.
	int offs_w_p;                        ///< Offset of the first time point algebraic variable vector in \f$z\f$.

	int offs_p;                          ///< Offset of the \f$p\f$ vector in \f$z\f$.
	int offs_v;                          ///< Offset of the \f$v\f$ vector in \f$z\f$.
	int offs_q;                          ///< Offset of the \f$z\f$ vector in \f$z\f$.

	jmi_ad_var_vec_p z;                  ///< This vector contains active AD objects in case of AD.
	jmi_real_t** z_val;                  ///< This vector contains the actual values.

};

/**
 * \brief Struct describing a DAE model.
 *
 * Contains one jmi_func_t struct representing the DAE residual
 * function.
 */
struct jmi_dae_t{
	jmi_func_t* F;                       ///< A jmi_func_t struct representing the DAE residual \f$F\f$.
	jmi_func_t* R;                       ///< A jmi_func_t struct representing the DAE event indicator function \f$R\f$.
};

/**
 * \brief A struct containing a DAE initialization system.
 */
struct jmi_init_t{
	jmi_func_t* F0;                      ///< A jmi_func_t struct representing \f$F_0\f$.
	jmi_func_t* F1;                      ///< A jmi_func_t struct representing \f$F_1\f$.
	jmi_func_t* Fp;                      ///< A jmi_func_t struct representing \f$F_p\f$.
	jmi_func_t* R0;                      ///< A jmi_func_t struct representing \f$R_0\f$.
};

/**
 * \brief A struct containing functions and information about the
 * interval definition and optimization parameters for an optimization
 * problem.
 */
struct  jmi_opt_t{
	jmi_func_t* J;                        ///< Function pointer to the cost function.
	jmi_func_t* Ceq;                      ///< Function pointer to the equality path constraint residual function.
	jmi_func_t* Cineq;                    ///< Function pointer to the inequality path constraint residual function.
	jmi_func_t* Heq;                      ///< Function pointer to the equality point constraint residual function.
	jmi_func_t* Hineq;                    ///< Function pointer to the inequality point constraint residual function.
	jmi_real_t start_time;                ///< Optimization interval start time.
	int start_time_free;                  ///< Start time free or fixed.
	jmi_real_t final_time;                ///< Optimization interval final time.
	int final_time_free;                  ///< Final time free or fixed.
	int n_p_opt;                          ///< Number of parameters to optimize (in the \f$p_i\f$ vector).
	int *p_opt_indices;                   ///< Indices of the parameters to optimize (in the \f$p_i\f$ vector).
};

/* @} */

/**
 * \defgroup Misc_internal Miscanellous
 * \brief Miscanellous functions.
 */
/* @{ */

/**
 * \brief Compute the class of variable.
 *
 * The return value is one of JMI_DER_NN if a valid Jacobian column index is
 * given, otherwise -1. For example JMI_DER_X indicats a differentiated
 * variable.
 *
 * @param jmi A jmi_t struct.
 * @param col_index The column index for which to compute the variable class.
 * @return Variable class.
 */
int jmi_variable_type(jmi_t *jmi, int col_index);

/**
 * \brief Check if a particular column is to be included in
 * the Jacobian defined by independent_vars and mask.
 *
 * If the column is to be included, then 1 is returned otherwise 0.
 *
 * @param jmi A jmi_t struct.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param col_index The column index to be checked.
 * @return 1 if the column is to be included, otherwise 0.
 */
int jmi_check_Jacobian_column_index(jmi_t *jmi, int independent_vars,
                                    int *mask, int col_index);

/**
 * \brief Map a colum_index for the complete Jacobian into a column index of
 * the sub-Jacobian defined by independent_vars and mask.
 * @param jmi A jmi_t struct.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param col_index The column index to be mapped.
 * @return Column index in the sub-Jacobian.
 *
 */
int jmi_map_Jacobian_column_index(jmi_t *jmi, int independent_vars,
                                  int *mask, int col_index);

/* @} */

/* @} */



#endif
