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
#include <string.h>
#include <math.h>
#include <setjmp.h>
/*#include <sundials/sundials_types.h>*/

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
/* This must be done outside of 'extern "C"' */
#include <cppad/cppad.hpp>
#include <vector>
#endif /* JMI_AD == JMI_AD_CPPAD */

/* Forward declaration of jmi structs */
typedef struct jmi_t jmi_t;                               /**< \brief Forward declaration of struct. */
typedef struct fmi_t fmi_t;                               /**< \brief Forward declaration of struct. */
typedef struct jmi_dae_t jmi_dae_t;                       /**< \brief Forward declaration of struct. */
typedef struct jmi_init_t jmi_init_t;                     /**< \brief Forward declaration of struct. */
typedef struct jmi_opt_t jmi_opt_t;                       /**< \brief Forward declaration of struct. */
typedef struct jmi_func_t jmi_func_t;                     /**< \brief Forward declaration of struct. */
typedef struct jmi_func_ad_t jmi_func_ad_t;               /**< \brief Forward declaration of struct. */
typedef struct jmi_block_residual_t jmi_block_residual_t; /**< \brief Forward declaration of struct. */
typedef struct jmi_ode_solver_t jmi_ode_solver_t;         /**< \brief Forward declaration of struct. */
typedef struct jmi_color_info jmi_color_info;             /**< \brief Forward declaration of struct. */
typedef struct jmi_simple_color_info_t jmi_simple_color_info_t;      /**< \brief Forward declaration of struct. */
typedef struct jmi_log_t jmi_log_t;                       /**< \brief Forward declaration of struct. */

/* Typedef for the doubles used in the interface. */
typedef double jmi_real_t; /*< Typedef for the real number
               < representation used in the Runtime
               < Library. */
typedef int jmi_int_t; /*< Typedef for the integer number
               < representation used in the Runtime
               < Library. */

/* This section defines types in the case of no AD and
 in the case of CppAD.*/
#if JMI_AD == JMI_AD_NONE
typedef jmi_real_t jmi_ad_var_t;                       /**< \brief If JMI_AD_NONE: alias for jmi_real_t.<br> */
                                                       /**< \brief If JMI_AD_CPPAD: an active AD object. */
typedef jmi_real_t *jmi_real_vec_t;                    /**< \brief If JMI_AD_NONE: a vector of jmi_real_ts.<br> */
                                                       /**< \brief If JMI_AD_CPPAD: a vector of jmi_real_ts. */
typedef jmi_real_vec_t *jmi_real_vec_p;                /**< \brief If JMI_AD_NONE: a pointer to a vector of jmi_real_ts.<br> */
                                                       /**< \brief If JMI_AD_CPPAD: a pointer to a vector of jmi_real_ts. */
typedef jmi_real_t *jmi_ad_var_vec_t;                  /**< \brief If JMI_AD_NONE: a vector of jmi_real_ts.<br> */
                                                       /**< \brief If JMI_AD_CPPAD: a vector of active AD objecs. */
typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;            /**< \brief If JMI_AD_NONE: a pointer to a vector of jmi_real_ts.<br> */
                                                       /**< \brief If JMI_AD_CPPAD: a pointer to a vector of active AD objecs. */
typedef void jmi_ad_tape_t;                            /**< \brief If JMI_AD_NONE: void (not used).<br> */
                                                       /**< \brief If JMI_AD_CPPAD: an AD tape. */
typedef jmi_ad_tape_t *jmi_ad_tape_p;                  /**< \brief If JMI_AD_NONE: a pointer to void (not used).<br> */

#define AD_WRAP_LITERAL(x) ((jmi_ad_var_t) (x)) /**< \brief Macro for inserting an AD object based on a literal. Has no effect when compiling without CppAD  <br> */

#define COND_EXP_EQ(op1,op2,th,el) ((op1==op2)? (th): (el)) /**< \brief Macro for conditional expression == <br> */
#define COND_EXP_LE(op1,op2,th,el) ((op1<=op2)? (th): (el)) /**< \brief Macro for conditional expression <= <br> */
#define COND_EXP_LT(op1,op2,th,el) ((op1<op2)? (th): (el))  /**< \brief Macro for conditional expression < <br> */
#define COND_EXP_GE(op1,op2,th,el) ((op1>=op2)? (th): (el)) /**< \brief Macro for conditional expression >= <br> */
#define COND_EXP_GT(op1,op2,th,el) ((op1>op2)? (th): (el))  /**< \brief Macro for conditional expression > <br> */

#define LOG_EXP_OR(op1,op2) ((op1)+(op2)>JMI_FALSE) /**< \brief Macro for logical expression or <br> */

#define JMI_AD_WITH_CPPAD 0

#include "jmi_array_none.h"

#elif JMI_AD == JMI_AD_CPPAD  /* else to if JMI_AD == JMI_AD_NONE ... */
typedef CppAD::AD<jmi_real_t> jmi_ad_var_t;
typedef std::vector<jmi_real_t> jmi_real_vec_t;
typedef jmi_real_vec_t *jmi_real_vec_p;
typedef std::vector< jmi_ad_var_t > jmi_ad_var_vec_t;
typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;
typedef CppAD::ADFun<jmi_real_t> jmi_ad_tape_t;
typedef jmi_ad_tape_t *jmi_ad_tape_p;

#define AD_WRAP_LITERAL(x) CppAD::AD<jmi_real_t>(x)

#define COND_EXP_EQ(op1,op2,th,el) (CppAD::CondExpEq(op1,op2,th,el))
#define COND_EXP_LE(op1,op2,th,el) (CppAD::CondExpLe(op1,op2,th,el))
#define COND_EXP_LT(op1,op2,th,el) (CppAD::CondExpLt(op1,op2,th,el))
#define COND_EXP_GE(op1,op2,th,el) (CppAD::CondExpGe(op1,op2,th,el))
#define COND_EXP_GT(op1,op2,th,el) (CppAD::CondExpGt(op1,op2,th,el))

#define LOG_EXP_OR(op1,op2)  (COND_EXP_GT((op1)+(op2),JMI_FALSE,JMI_TRUE,JMI_FALSE))

#define JMI_AD_WITH_CPPAD 1

#include "jmi_array_cppad.h"

#else /* if JMI_AD == JMI_AD_NONE ... elif JMI_AD == JMI_AD_CPPAD ... */
/* TODO: Shouldn't this error state that JMI_AD must be set to JMI_AD_NONE or JMI_AD_CPPAD? */
#error "The directive JMI_AD_NONE or JMI_AD_CPPAD must be set"
#endif /* if JMI_AD == JMI_AD_NONE ... elif JMI_AD == JMI_AD_CPPAD ... else ... */

/* If we are using a C++ compiler now, but aren't using CppAD, then we need extern "C" around functions. */
#ifdef __cplusplus
#if JMI_AD == JMI_AD_NONE
#define JMI_AD_NONE_AND_CPP
#endif /* JMI_AD == JMI_AD_NONE */
#endif /* __cplusplus */

#define LOG_EXP_AND(op1,op2) ((op1)*(op2))           /**< \brief Macro for logical expression and <br> */
#define LOG_EXP_NOT(op)      (JMI_TRUE-(op))         /**< \brief Macro for logical expression not <br> */

/*#define ALMOST_ZERO(op) (jmi_abs(op)<=1e-6? JMI_TRUE: JMI_FALSE)*/
#define ALMOST_ZERO(op) LOG_EXP_AND(ALMOST_LT_ZERO(op),ALMOST_GT_ZERO(op))
#define ALMOST_LT_ZERO(op) (op<=1e-6? JMI_TRUE: JMI_FALSE)
#define ALMOST_GT_ZERO(op) (op>=-1e-6? JMI_TRUE: JMI_FALSE)
#define SURELY_LT_ZERO(op) (op<=-1e-6? JMI_TRUE: JMI_FALSE)
#define SURELY_GT_ZERO(op) (op>=1e-6? JMI_TRUE: JMI_FALSE)


/* Record creation macro */
#define JMI_RECORD_STATIC(type, name) \
    type name##_rec;\
    type* name = &name##_rec;

#ifdef JMI_AD_NONE_AND_CPP
extern "C" {
#endif /* JMI_AD_NONE_AND_CPP */

/**
 * Function to wrap division and report errors to the log, for use in functions.
 */
jmi_ad_var_t jmi_divide_function(const char* name, jmi_ad_var_t num, jmi_ad_var_t den, const char* msg);

/**
 * Function to wrap division and report errors to the log, for use in equations.
 */
jmi_ad_var_t jmi_divide_equation(jmi_t *jmi, jmi_ad_var_t num, jmi_ad_var_t den, const char* msg);

/**
 * Set the terminate flag and log message.
 */
void jmi_flag_termination(jmi_t *jmi, const char* msg);

/**
 * Function to get the absolute value.
 * Is a separate function to avoid evaluating expressions several times.
 */
jmi_ad_var_t jmi_abs(jmi_ad_var_t v);

/**
 * Function to get the absolute value.
 * Is a separate function to avoid evaluating expressions several times.
 */
jmi_ad_var_t jmi_sign(jmi_ad_var_t v);

/**
 * Function to get the smaller of two values.
 * Is a separate function to avoid evaluating expressions twice.
 */
jmi_ad_var_t jmi_min(jmi_ad_var_t x, jmi_ad_var_t y);

/**
 * Function to get the larger of two values.
 * Is a separate function to avoid evaluating expressions twice.
 */
jmi_ad_var_t jmi_max(jmi_ad_var_t x, jmi_ad_var_t y);

/**
 * The sample operator. Returns true if time = offset + i*h, i>=0 during
 * handling of an event. During continuous integration, false is returned.
 *
 */
jmi_ad_var_t jmi_sample(jmi_t* jmi, jmi_real_t offset, jmi_real_t h);

/**
 * The round function for double numbers. 
 *
 */
jmi_real_t jmi_dround(jmi_real_t x);

/**
 * The remainder function for double numbers. 
 *
 */
jmi_real_t jmi_dremainder(jmi_real_t x, jmi_real_t y);

/* @} */

/**
 * \defgroup jmi_function_typedefs Function typedefs
 *
 * \brief Function signatures to be used in the generated code
 */

/* @{ */

/**
 * \brief A generic function signature that only takes a jmi_t struct as input.
 *
 * @param jmi A jmi_t struct.
 * @return Error code.
 */
typedef int (*jmi_generic_func_t)(jmi_t* jmi);

/**
 * \brief A function signature for computation of the next time event.
 *
 * @param jmi A jmi_t struct.
 * @param nextTime (Output) The time instant of the next time event.
 * @return Error code.
 */
typedef int (*jmi_next_time_event_func_t)(jmi_t* jmi, jmi_real_t* nextTime);

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
 * \brief Function signature for evaluation of a directional derivative function
 * in the generated code.
 *
 * Notice that this function signature is used for all functions in
 * the DAE, DAE initialization, and Optimization interfaces. Notice
 * that this definition supports both C compilation and C++
 * compilation with CppAD.
 *
 * @param jmi A jmi_t struct.
 * @param res (Output) The residual value vector.
 * @param dF (Output) The directional derivative of the residual function.
 * @param dz the Seed vector of size n_x + n_x + n_u + n_w.
 * @return Error code.
 *
 */
typedef int (*jmi_directional_der_residual_func_t)(jmi_t* jmi, jmi_ad_var_vec_p res,
        jmi_ad_var_vec_p dF, jmi_ad_var_vec_p dz);


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
 * @param sym_dF Function pointer to the symbolic Jacobian function.
 * @param sym_dF_n_nz The number of non-zeros in the symbolic Jacobian.
 * @param sym_dF_row Row indices of the non-zero elements in the symbolic Jacobian.
 * @param sym_dF_col Column indices of the non-zero elements in the symbolic
 *        Jacobian.
 * @param dir_dF A function pointer to the directional derivative function.
 * @param dF_n_nz The number of non-zeros in the AD Jacobian.
 * @param dF_row Row indices of the non-zero elements in the AD Jacobian.
 * @param dF_col Column indices of the non-zero elements in the AD
 *        Jacobian.
 * @return Error code.
 *
 */
int jmi_func_new(jmi_func_t** jmi_func, jmi_residual_func_t F,
                 int n_eq_F, jmi_jacobian_func_t sym_dF,
                 int sym_dF_n_nz, int* sym_dF_row, int* sym_dF_col,
                 jmi_directional_der_residual_func_t cad_dir_dF,
                 int cad_dF_n_nz, int* cad_dF_row, int* cad_dF_col);

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
int jmi_func_sym_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
        int independent_vars, int* mask, jmi_real_t* jac) ;

/**
 * \brief Returns the number of non-zeros in the symbolic Jacobian.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param n_nz (Output) The number of non-zero Jacobian entries.
 * @return Error code.
 */
int jmi_func_sym_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz);

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
int jmi_func_sym_dF_nz_indices(jmi_t *jmi, jmi_func_t *func,
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
int jmi_func_sym_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity,
                    int independent_vars, int *mask,
            int *dF_n_cols, int *dF_n_nz);
            
/**
 * \brief Evaluate the directional AD derivative of the residual function of
 * a jmi_func_t struct, using symbolic differentiation.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param res (Output) The DAE residual vector.
 * @param dF (Output) The directional derivative.
 * @param dv Seed vector of size n_x + n_x + n_u + n_w.
 * @return Error code.
 */

int jmi_func_sym_directional_dF(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res,
             jmi_real_t *dF, jmi_real_t* dv);

/**
 * \brief Evaluate the directional AD derivative of the residual function of
 * a jmi_func_t struct, using the CAD technique.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param res (Output) The DAE residual vector.
 * @param dF (Output) The directional derivative.
 * @param dv Seed vector of size n_x + n_x + n_u + n_w.
 * @return Error code.
 */
int jmi_func_cad_directional_dF(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res,
             jmi_real_t *dF, jmi_real_t* dv);

/**
 * \brief Evaluation of the AD Jacobian of the
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

int jmi_func_cad_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
        int independent_vars, int* mask, jmi_real_t* jac) ;

/**
 * \brief Returns the number of non-zeros in the AD Jacobian.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param n_nz (Output) The number of non-zero Jacobian entries.
 * @return Error code.
 */

int jmi_func_cad_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz);

/**
 * \brief Returns the row and column indices of the non-zero elements in the
 * AD residual Jacobian.
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
 
int jmi_func_cad_dF_nz_indices(jmi_t *jmi, jmi_func_t *func,
                           int independent_vars,
                           int *mask, int *row, int *col);
                          

/**
 * \brief Computes the number of columns and the number of non-zero
 * elements in the AD Jacobian of a jmi_func_t given a sparsity
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

int jmi_func_cad_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity,
                    int independent_vars, int *mask,
            int *dF_n_cols, int *dF_n_nz);

/**
 * \brief Evaluate the directional finite difference derivative of the residual function of
 * a jmi_func_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param res (Output) The DAE residual vector.
 * @param dF (Output) The directional derivative.
 * @param dv Seed vector of size n_x + n_x + n_u + n_w.
 * @return Error code.
 */

int jmi_func_fd_directional_dF(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res,
             jmi_real_t *dF, jmi_real_t* dv);

/**
 * \brief Evaluation of the finite difference Jacobian of the
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

int jmi_func_fd_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
        int independent_vars, int* mask, jmi_real_t* jac) ;

/**
 * \brief Returns the number of non-zeros in the finite difference Jacobian.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param n_nz (Output) The number of non-zero Jacobian entries.
 * @return Error code.
 */

int jmi_func_fd_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz);

/**
 * \brief Returns the row and column indices of the non-zero elements in the
 * finite difference residual Jacobian.
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

int jmi_func_fd_dF_nz_indices(jmi_t *jmi, jmi_func_t *func,
                           int independent_vars,
                           int *mask, int *row, int *col);

/**
 * \brief Computes the number of columns and the number of non-zero
 * elements in the finite difference Jacobian of a jmi_func_t given a sparsity
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

int jmi_func_fd_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity,
                    int independent_vars, int *mask,
            int *dF_n_cols, int *dF_n_nz);

typedef enum jmi_residual_equation_scaling_mode_t {
    jmi_residual_scaling_none = 0,
    jmi_residual_scaling_auto = 1,
    jmi_residual_scaling_manual = 2
} jmi_residual_equation_scaling_mode_t;


typedef enum jmi_iteration_var_scaling_mode_t {
    jmi_iter_var_scaling_none = 0,
    jmi_iter_var_scaling_nominal = 1,
    jmi_iter_var_scaling_heuristics = 2
} jmi_iteration_var_scaling_mode_t;

typedef enum jmi_block_solver_experimental_mode_t {
    jmi_block_solver_experimental_none = 0,
    jmi_block_solver_experimental_converge_switches_first = 1,
    jmi_block_solver_experimental_steepest_descent = 2,
    jmi_block_solver_experimental_steepest_descent_first = 4
} jmi_block_solver_experimental_mode_t;

/**< \brief Run-time options. */
typedef struct jmi_options_t {
    int log_level; /**< \brief Log level for jmi_log 0 - none, 1 - fatal error, 2 - error, 3 - warning, 4 - info, 5 -verbose, 6 - debug */
    int enforce_bounds_flag; /**< \brief Enforce min-max bounds on variables in the equation blocks*/
    int use_jacobian_equilibration_flag;  /**< \brief If jacobian equlibration should be used in equation block solvers */
    
    jmi_residual_equation_scaling_mode_t residual_equation_scaling_mode; /**< \brief Equations scaling mode in equation block solvers:0-no scaling,1-automatic scaling,2-manual scaling */
    int iteration_variable_scaling_mode; /**< \brief Iteration variables scaling mode in equation block solvers:
            0 - no scaling, 1 - scaling based on nominals only (default), 2 - utilize heuristict to guess nominal based on min,max,start, etc. */
    int block_solver_experimental_mode; /**< \brief  Activate experimental features of equation block solvers */
    int nle_solver_max_iter; /**< \brief Maximum number of iterations for the equation block solver before failure */

    int rescale_each_step_flag;  /**< \brief If scaling should be updated at every step (only active if use_automatic_scaling_flag is set) */
    int rescale_after_singular_jac_flag;  /**< \brief If scaling should be updated after singular jac was detected (only active if use_automatic_scaling_flag is set) */
    int use_Brent_in_1d_flag;  /**< \brief If Brent search should be used to improve accuracy in solution of 1D non-linear equations */
    double nle_solver_default_tol;  /**< \brief Default tolerance for the equation block solver */
    int nle_solver_check_jac_cond_flag; /**< \brief Flag if NLE solver should check Jacobian condition number and log it. */
    double nle_solver_min_tol;  /**< \brief Minimum tolerance for the equation block solver */
    double nle_solver_tol_factor;   /**< \brief Tolerance safety factor for the non-linear equation block solver. */
    double events_default_tol;  /**< \brief Default tolerance for the event iterations. */        
    double events_tol_factor;   /**< \brief Tolerance safety factor for the event iterations. */

    int block_jacobian_check; /**< \brief Compares analytic block jacobian with finite difference block jacobian */ 
    double block_jacobian_check_tol; /**< \brief Tolerance for block jacobian comparison */
    int cs_solver; /**< \brief Option for changing the internal CS solver */
    double cs_rel_tol; /** < \brief Default tolerance for the adaptive solvers in the CS case. */
    double cs_step_size; /** < \brief Default step-size for the non-adaptive solvers in the CS case. */   
    
    int runtime_log_to_file; /** < \brief Write the runtime log directly to a file as well? */
} jmi_options_t;

/**< \brief Initialize run-time options. */
void jmi_init_runtime_options(jmi_t *jmi, jmi_options_t* op);

#define check_lbound(x, xmin, message) \
    if(jmi->options.enforce_bounds_flag && (x < xmin)) \
        { jmi_log_node(jmi->log, logInfo, "LBoundExceeded", "<message:%s>", \
                       message);                                        \
            return 1; }

#define check_ubound(x, xmax, message) \
    if(jmi->options.enforce_bounds_flag && (x > xmax)) \
        { jmi_log_node(jmi->log, logInfo, "UBoundExceeded", "<message:%s>", \
                       message);                                        \
            return 1; }

#define init_with_lbound(x, xmin, message) \
    if(jmi->options.enforce_bounds_flag && (x < xmin)) \
        { jmi_log_node(jmi->log, logInfo, "LBoundSaturation", "<message:%s>", \
                       message); \
            x = xmin; }

#define init_with_ubound(x, xmax, message) \
    if(jmi->options.enforce_bounds_flag && (x > xmax)) \
        { jmi_log_node(jmi->log, logInfo, "UBoundSaturation", "<message:%s>", \
                       message);                                        \
            x = xmax; }

#define check_bounds(x, xmin, xmax, message) \
    check_lbound(x, xmin, message)\
    else check_ubound(x, xmax, message)

#define init_with_bounds(x, xmin, xmax, message) \
    init_with_lbound(x, xmin, message) \
    else init_with_ubound(x, xmax, message)


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
struct jmi_func_t {
    jmi_residual_func_t F;  /**< \brief Pointer to a function for evaluation of \f$F(z)\f$. */
    jmi_jacobian_func_t sym_dF; /**< \brief Pointer to a function for evaluation of the symbolic Jacobian of \f$F(z)\f$. */
    jmi_directional_der_residual_func_t cad_dir_dF; /**< \brief Pointer to a function for evaluation of the directional AD derivative of the function */
    int n_eq_F;             /**< \brief Size of the function. */
    int sym_dF_n_nz;            /**< \brief Number of non-zeros in the symbolic Jacobian of \f$F(z)\f$ (if available). */
    int* sym_dF_row;            /**< \brief Row indices of the non-zero elements in the symbolic Jacobian of \f$F(z)\f$ (if available). */
    int* sym_dF_col;            /**< \brief Column indices of the non-zero elements in the symbolic Jacobian of \f$F(z)\f$ (if available). */
    int cad_dF_n_nz;            /**< \brief Number of non-zeros in the AD Jacobian of \f$F(z)\f$ (if available). */
    int* cad_dF_row;            /**< \brief Row indices of the non-zero elements in the AD Jacobian of \f$F(z)\f$ (if available). */
    int* cad_dF_col;            /**< \brief Column indices of the non-zero elements in the AD Jacobian of \f$F(z)\f$ (if available). */
    jmi_func_ad_t* ad;      /**< \brief Pointer to a jmi_func_ad_t struct containing AD information (if compiled with AD support). */
    int coloring_counter;   /**< \brief Number of times that the graph coloring algorithm  has been performed. */
    int* coloring_done;     /**< \brief Contains info of which independent_vars that the graph_coloring algorithm has been done. */
    jmi_color_info** c_info;  /**< \brief Vector of jmi_graph_coloring struct, contains graph coloring results for every independent_vars that has been performed  */
    
};

/**
 * \brief Contains result of a graph coloring.
 */
struct jmi_color_info {
    int* sparse_repr;
    int* offs;
    int n_colors;
    int* map_info;
    int* map_off;
};

struct jmi_simple_color_info_t {
    int n_nz;                       /**< \brief Number of non-zeros. */
    int n_cols;                     /**< \brief Number of columns */
    int* col_n_nz;                   /**< \brief Number of non-zeros in each column */
    int col_offset;                 /**< \brief Column offset (in some cases, column indexing does not start at zero)*/
    int* rows;                      /**< \brief Row indices. */
    int* cols;                      /**< \brief Column indices. */
    int* col_start_index;           /**< \brief Column start indices (incidence patterns are stored column major)*/
    int n_groups;                   /**< \brief Number of groups in the CPR seeding. */
    int n_cols_in_grouping;         /**< \brief Total number of columns used in CPR seeding computation. */
    int* n_cols_in_group;           /**< \brief The number of column in each CPR group. */
    int* group_cols;                /**< \brief An ordered array of column indices corresponding to CPR groups. */
    int* group_start_index;         /**< \brief An array containing the start indices for each group in the array group_cols. */
};

/**
 * \brief Contains data structures for CppAD.
 *
 * The struct jmi_func_ad_t contains a tape and associated sparsity
 * information for a particular jmi_func_t struct.
 */
struct jmi_func_ad_t {
    jmi_ad_var_vec_p F_z_dependent; /**< \brief A vector containing active AD independent objects for use by CppAD. */
    jmi_ad_tape_p F_z_tape;         /**< \brief An AD tape. */
    int tape_initialized;           /**< \brief Flag to indicate if the other fields are initialized. 0 if uninitialized and 1 if initialized. */
    int dF_z_n_nz;                  /**< \brief Number of non-zeros in Jacobian. */
    int* dF_z_row;                  /**< \brief Row indices of non-zeros in Jacobian. */
    int* dF_z_col;                  /**< \brief Column indices of non-zeros in Jacobian. */
    int* dF_z_col_start_index;        /**< \brief The index in the sparse Jacobian vector of the
                                                first element corresponding to a particular column. */
    int* dF_z_col_n_nz;               /**< \brief The number of non-zeros of each column in the sparse
                                                Jacobian. */
    jmi_real_vec_p z_work;          /**< \brief A work vector for \f$z\f$. */
    int exec_time;                  /**< \brief A variable that is used for measuring execution time. */
    jmi_simple_color_info_t* color_info; /**< \brief A struct containing coloring info for the CPR seeding. */

    /*int n_groups;*/                   /**< \brief Number of groups in the CPR seeding. */
    /*int n_cols_in_grouping;*/         /**< \brief Total number of columns used in CPR seeding computation. */
    /*int* n_cols_in_group;    */       /**< \brief The number of column in each CPR group. */
    /*int* group_cols;          */      /**< \brief An ordered array of column indices corresponding to CPR groups. */
    /*int* group_start_index;     */    /**< \brief An array containing the start indices for each group in the array group_cols. */

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
 * @param n_real_ci Number of real independent constants.
 * @param n_real_cd Number of real dependent constants.
 * @param n_real_pi Number of real independent parameters.
 * @param n_real_pd Number of real dependent parameters.
 * @param n_integer_ci Number of integer independent constants.
 * @param n_integer_cd Number of integer dependent constants.
 * @param n_integer_pi Number of integer independent parameters.
 * @param n_integer_pd Number of integer dependent parameters.
 * @param n_boolean_ci Number of boolean independent constants.
 * @param n_boolean_cd Number of boolean dependent constants.
 * @param n_boolean_pi Number of boolean independent parameters.
 * @param n_boolean_pd Number of boolean dependent parameters.
 * @param n_string_ci Number of string independent constants.
 * @param n_string_cd Number of string dependent constants.
 * @param n_string_pi Number of string independent parameters.
 * @param n_string_pd Number of string dependent parameters.
 * @param n_real_dx Number of real derivatives.
 * @param n_real_x Number of real differentiated variables.
 * @param n_real_u Number of real inputs.
 * @param n_real_w Number of real algebraics.
 * @param n_tp Number of interpolation time points.
 * @param n_real_d Number of real discrete parameters.
 * @param n_integer_d Number of integer discrete parameters.
 * @param n_integer_u Number of integer inputs.
 * @param n_boolean_d Number of boolean discrete parameters.
 * @param n_boolean_u Number of boolean inputs.
 * @param n_string_d Number of string discrete parameters.
 * @param n_string_u Number of string inputs.
 * @param n_outputs Number of outputs.
 * @param output_vrefs Value references of the outputs.
 * @param n_sw Number of switching functions in DAE \$fF\$f.
 * @param n_sw_init Number of switching functions in DAE initialization system \$fF_0\$f.
 * @param n_guards Number of guards in DAE \$fF\$f.
 * @param n_guards_init Number of guards in DAE initialization system \$fF_0\$f.
 * @param n_dae_blocks Number of DAE blocks.
 * @param n_dae_init_blocks Number of DAE initialization blocks.
 * @param n_initial_relations Number of relational operators in the initial equations.
 * @param initial_relations Kind of relational operators in the initial equations. One of JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ.
 * @param n_relations Number of relational operators in the DAE equations.
 * @param relations Kind of relational operators in the DAE equations. One of: JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ.
 * @param scaling_method Scaling method. Options are JMI_SCALING_NONE or JMI_SCALING_VARIABLES.
 * @return Error code.
 */
int jmi_init(jmi_t** jmi, int n_real_ci, int n_real_cd, int n_real_pi,
        int n_real_pd, int n_integer_ci, int n_integer_cd,
        int n_integer_pi, int n_integer_pd,int n_boolean_ci, int n_boolean_cd,
        int n_boolean_pi, int n_boolean_pd, int n_string_ci, int n_string_cd,
        int n_string_pi, int n_string_pd,
        int n_real_dx, int n_real_x, int n_real_u, int n_real_w,
        int n_tp,int n_real_d,
        int n_integer_d, int n_integer_u,
        int n_boolean_d, int n_boolean_u,
        int n_string_d, int n_string_u,
        int n_outputs, int* output_vrefs,
        int n_sw, int n_sw_init,
        int n_guards, int n_guards_init,
        int n_dae_blocks, int n_dae_init_blocks,
        int n_initial_relations, int* initial_relations,
        int n_relations, int* relations,
        int scaling_method, int n_ext_objs);

/**
 * \brief Allocates a jmi_dae_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F A function pointer to the DAE residual function.
 * @param n_eq_F Number of equations in the DAE residual.
 * @param sym_dF Function pointer to the symbolic Jacobian function.
 * @param sym_dF_n_nz Number of non-zeros in the symbolic jacobian.
 * @param sym_dF_row Row indices of the non-zeros in the symbolic Jacobian.
 * @param sym_dF_col Column indices of the non-zeros in the symbolic Jacobian.
 * @param cad_dir_dF A function pointer for evaluation of the AD generated directional
 *               derivative for the DAE residual function.
 * @param cad_dF_n_nz Number of non-zeros in the AD jacobian.
 * @param cad_dF_row Row indices of the non-zeros in the AD Jacobian.
 * @param cad_dF_col Column indices of the non-zeros in the AD Jacobian.
 * @param cad_A_n_nz Number of non-zeros in the ODE AD Jacobian A.
 * @param cad_A_row Row indices of the non-zeros in the ODE AD Jacobian A.
 * @param cad_A_col Column indices of the non-zeros in the ODE AD Jacobian A.
 * @param cad_B_n_nz Number of non-zeros in the ODE AD Jacobian B.
 * @param cad_B_row Row indices of the non-zeros in the ODE AD Jacobian B.
 * @param cad_B_col Column indices of the non-zeros in the ODE AD Jacobian B.
 * @param cad_C_n_nz Number of non-zeros in the ODE AD Jacobian C.
 * @param cad_C_row Row indices of the non-zeros in the ODE AD Jacobian C.
 * @param cad_C_col Column indices of the non-zeros in the ODE AD Jacobian C.
 * @param cad_D_n_nz Number of non-zeros in the ODE AD Jacobian D.
 * @param cad_D_row Row indices of the non-zeros in the ODE AD Jacobian D.
 * @param cad_D_col Column indices of the non-zeros in the ODE AD Jacobian D.
 * @param R A function pointer to the DAE event indicator residual function.
 * @param n_eq_R Number of equations in the event indicator function.
 * @param dR Function pointer to the symbolic Jacobian function.
 * @param dR_n_nz Number of non-zeros in the symbolic jacobian.
 * @param dR_row Row indices of the non-zeros in the symbolic Jacobian.
 * @param dR_col Column indices of the non-zeros in the symbolic Jacobian.
 * @param ode_derivatives A function pointer to the ODE RHS function.
 * @param ode_derivatives_dir_der A function pointer to the ODE directional derivative function.
 * @param ode_outputs A function pointer to the ODE output function.
 * @param ode_initialize A function pointer to the ODE initialization function.
 * @param ode_guards A function pointer for evaluating the guard expressions.
 * @param ode_guards_init A function pointer for evaluating the guard expressions.
 *        in the initial equations.
 * @return Error code.
 */
int jmi_dae_init(jmi_t* jmi, jmi_residual_func_t F, int n_eq_F,
        jmi_jacobian_func_t sym_dF, int sym_dF_n_nz, int* sym_dF_row, int* sym_dF_col,
        jmi_directional_der_residual_func_t cad_dir_dF,
        int cad_dF_n_nz, int* cad_dF_row, int* cad_dF_col,
        int cad_A_n_nz, int* cad_A_row, int* cad_A_col,
        int cad_B_n_nz, int* cad_B_row, int* cad_B_col,
        int cad_C_n_nz, int* cad_C_row, int* cad_C_col,
        int cad_D_n_nz, int* cad_D_row, int* cad_D_col,
        jmi_residual_func_t R, int n_eq_R,
        jmi_jacobian_func_t dR, int dR_n_nz, int* dR_row, int* dR_col,
        jmi_generic_func_t ode_derivatives,
        jmi_generic_func_t ode_derivatives_dir_der,
        jmi_generic_func_t ode_outputs,
        jmi_generic_func_t ode_initialize,
        jmi_generic_func_t ode_guards,
        jmi_generic_func_t ode_guards_init,
        jmi_next_time_event_func_t ode_next_time_event);

/**
 * \brief Allocates memory for the contents of a jmi_simple_color_info struct
 *
 * @param c_info A jmi_simple_color_info struct
 * @param n_cols, Number of columns in Jacobian
 * @param n_cols_in_grouping, Number of columns to include in the coloring
 * @param n_nz, Number of non-zeros
 * @param rows, Row indices of non-zero elements
 * @param cols, Column indices of non-zero elements
 * @param col_offset, Offset of the first column to include in the coloring
 * @param one_indexing If 1, then assume FORTRAN style 1-indexing, if 0 assume C style 0-indexing
 *
 * @return Error code
 */
int jmi_new_simple_color_info(jmi_simple_color_info_t** c_info, int n_cols, int n_cols_in_grouping, int n_nz,
        int* rows, int* cols, int col_offset, int one_indexing);

/**
 * \brief Deletes the contents of a jmi_simple_color_info struct
 *
 * @param c_info A jmi_color_info struct
 * @return Error code
 */
void jmi_delete_simple_color_info(jmi_simple_color_info_t **c_info_ptr);

/**
 * \brief Allocates memory for the contents of a jmi_color_info struct
 *
 * @param c_info A jmi_color_info struct
 * @param dF_n_cols, number of columns
 * @param dF_n_nz, number of non-zeros
 *
 * @return Error code
 */
int jmi_new_color_info(jmi_color_info** c_info, int dF_n_cols, int dF_n_nz);

/**
 * \brief Deletes the contents of a jmi_color_info struct
 *
 * @param c_i A jmi_color_info struct
 * @return Error code
 */
int jmi_delete_color_info(jmi_color_info *c_i);

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
 * @param dF0_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_0\f$.
 * @param dF0_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_0\f$.
 * @param F1 A function pointer to the DAE initialization residual function
 * \f$F_1\f$.
 * @param n_eq_F1 Number of equations in the DAE initialization residual
 *        function \f$F_1\f$.
 * @param dF1 Function pointer to the symbolic Jacobian of \f$F_1\f$.
 * @param dF1_n_nz Number of non-zeros in the symbolic jacobian of \f$F_1\f$.
 * @param dF1_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_1\f$.
 * @param dF1_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_1\f$.
 * @param Fp A function pointer to the DAE initialization residual function
 * \f$F_p\f$.
 * @param n_eq_Fp Number of equations in the DAE initialization residual
 *        function \f$F_p\f$.
 * @param dFp Function pointer to the symbolic Jacobian of \f$F_p\f$.
 * @param dFp_n_nz Number of non-zeros in the symbolic jacobian of \f$F_p\f$.
 * @param dFp_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_p\f$.
 * @param dFp_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_p\f$.
 * @param R0 A function pointer to the DAE event indicator residual function.
 * @param n_eq_R0 Number of equations in the event indicator function.
 * @param dR0 Function pointer to the symbolic Jacobian function.
 * @param dR0_n_nz Number of non-zeros in the symbolic jacobian.
 * @param dR0_row Row indices of the non-zeros in the symbolic Jacobian.
 * @param dR0_col Column indices of the non-zeros in the symbolic Jacobian.
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
          jmi_generic_func_t eval_parameters,
          jmi_residual_func_t R0, int n_eq_R0,
          jmi_jacobian_func_t dR0,
          int dR0_n_nz, int* dR0_row, int* dR0_col);

/**
 * \brief Frees memory from jmi_init_t struct.
 *
 * @param init is the pointer to init field in jmi. It's set to NULL on return.
 */
void jmi_delete_init(jmi_init_t** pinit);

/**
 * \brief Allocates a jmi_opt_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param Ffdp A function pointer to the free dependent parameters residual
 * function \f$F_{fdp}\f$.
 * @param n_eq_Ffdp Number of equations in the free dependent parameters residual
 *        \f$F_{fdp}\f$.
 * @param dFfdp Function pointer to the symbolic Jacobian of \f$F_{fdp}\f$.
 * @param dFfdp_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$F_{fdp}\f$.
 * @param dFfdp_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_{fdp}\f$.
 * @param dFfdp_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$F_{fdp}\f$.
 * @param J A function pointer to the generalized terminal penalty function \f$J\f$.
 * @param n_eq_J Number of generalized terminal penalty functions.
 * @param dJ Function pointer to the symbolic Jacobian of \f$J\f$.
 * @param dJ_n_nz Number of non-zeros in the symbolic jacobian of \f$J\f$.
 * @param dJ_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$J\f$.
 * @param dJ_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$J\f$.
 * @param L A function pointer to the Lagrange integrand \f$L\f$.
 * @param n_eq_L Number of Lagrange integrands.
 * @param dL Function pointer to the symbolic Jacobian of \f$L\f$.
 * @param dL_n_nz Number of non-zeros in the symbolic jacobian of \f$L\f$.
 * @param dL_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$L\f$.
 * @param dL_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$L\f$.
 * @param Ceq A function pointer to the equality path constraint residual
 * function \f$C_{eq}\f$.
 * @param n_eq_Ceq Number of equations in the equality path constraint residual
 *        \f$C_{eq}\f$.
 * @param dCeq Function pointer to the symbolic Jacobian of \f$C_{eq}\f$.
 * @param dCeq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$C_{eq}\f$.
 * @param dCeq_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$C_{eq}\f$.
 * @param dCeq_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$C_{eq}\f$.
 * @param Cineq A function pointer to the inequality path constraint residual
 * function \f$C_{ineq}\f$.
 * @param n_eq_Cineq Number of equations in the inequality path constraint
 *        residual \f$C_{ineq}\f$.
 * @param dCineq Function pointer to the symbolic Jacobian of \f$C_{ineq}\f$.
 * @param dCineq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$C_{ineq}\f$.
 * @param dCineq_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$C_{ineq}\f$.
 * @param dCineq_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$C_{ineq}\f$.
 * @param Heq A function pointer to the equality point constraint residual
 * function \f$H_{eq}\f$.
 * @param n_eq_Heq Number of equations in the equality point constraint residual
 *        \f$H_{eq}\f$.
 * @param dHeq Function pointer to the symbolic Jacobian of \f$H_{eq}\f$.
 * @param dHeq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$H_{eq}\f$.
 * @param dHeq_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$H_{eq}\f$.
 * @param dHeq_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$H_{eq}\f$.
 * @param Hineq A function pointer to the inequality point constraint residual
 * function \f$H_{ineq}\f$.
 * @param n_eq_Hineq Number of equations in the inequality point constraint
 *        residual \f$H_{ineq}\f$.
 * @param dHineq Function pointer to the symbolic Jacobian of \f$H_{ineq}\f$.
 * @param dHineq_n_nz Number of non-zeros in the symbolic jacobian of
 *        \f$H_{ineq}\f$.
 * @param dHineq_row Row indices of the non-zeros in the symbolic Jacobian
 *        of \f$H_{ineq}\f$.
 * @param dHineq_col Column indices of the non-zeros in the symbolic Jacobian
 *        of \f$H_{ineq}\f$.
 * @return Error code.
 */
int jmi_opt_init(jmi_t* jmi, jmi_residual_func_t Ffdp,int n_eq_Fdp,
         jmi_jacobian_func_t dFfdp,
         int dfdp_n_nz, int* dfdp_row, int* dfdp_col,
         jmi_residual_func_t J, int n_eq_J, jmi_jacobian_func_t dJ,
         int dJ_n_nz, int* dJ_row, int* dJ_col,
         jmi_residual_func_t L, int n_eq_L, jmi_jacobian_func_t dL,
         int dL_n_nz, int* dL_row, int* dL_col,
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
struct jmi_t {
    jmi_dae_t* dae;                      /**< \brief A jmi_dae_t struct pointer. */
    jmi_init_t* init;                    /**< \brief A jmi_init_t struct pointer. */
    jmi_opt_t* opt;                      /**< \brief A jmi_opt_t struct pointer. */
    fmi_t* fmi;                          /**< \brief A pointer to the FMI interface (NULL in JMI mode). */

    int n_real_ci;                       /**< \brief Number of independent constants. */
    int n_real_cd;                       /**< \brief Number of dependent constants. */
    int n_real_pi;                       /**< \brief Number of independent parameters. */
    int n_real_pd;                       /**< \brief Number of dependent parameters. */

    int n_integer_ci;                    /**< \brief Number of integer independent constants. */
    int n_integer_cd;                    /**< \brief Number of integer dependent constants. */
    int n_integer_pi;                    /**< \brief Number of integer independent parameters. */
    int n_integer_pd;                    /**< \brief Number of integer dependent parameters. */

    int n_boolean_ci;                    /**< \brief Number of boolean independent constants. */
    int n_boolean_cd;                    /**< \brief Number of boolean dependent constants. */
    int n_boolean_pi;                    /**< \brief Number of boolean independent parameters. */
    int n_boolean_pd;                    /**< \brief Number of boolean dependent parameters. */

    int n_string_ci;                     /**< \brief Number of string independent constants. */
    int n_string_cd;                     /**< \brief Number of string dependent constants. */
    int n_string_pi;                     /**< \brief Number of string independent parameters. */
    int n_string_pd;                     /**< \brief Number of string dependent parameters. */

    int n_real_dx;                       /**< \brief Number of derivatives. */
    int n_real_x;                        /**< \brief Number of differentiated states. */
    int n_real_u;                        /**< \brief Number of inputs. */
    int n_real_w;                        /**< \brief Number of algebraics. */
    int n_tp;                            /**< \brief Number of time points included in the optimization problem */

    int n_real_d;                        /**< \brief Number of discrete variables. */

    int n_integer_d;                     /**< \brief Number of integer discrete variables. */
    int n_integer_u;                     /**< \brief Number of integer inputs. */

    int n_boolean_d;                     /**< \brief Number of boolean discrete variables. */
    int n_boolean_u;                     /**< \brief Number of boolean inputs. */

    int n_string_d;                      /**< \brief Number of string discrete variables. */
    int n_string_u;                      /**< \brief Number of string inputs. */

    int n_outputs;                       /** \brief Number of output variables. */

    int *output_vrefs;                   /** \brief Value references of the output variables. */

    int n_sw;                            /**< \brief Number of switching functions in the DAE \f$F\f$. */
    int n_sw_init;                       /**< \brief Number of switching functions in the DAE initialization system\f$F_0\f$. */

    int n_guards;                        /**< \brief Number of guards in the DAE \f$F\f$. */
    int n_guards_init;                     /**< \brief Number of guards in the DAE initialization system\f$F_0\f$. */

    int n_p;                             /**< \brief Number of elements in \f$p\f$. */
    int n_v;                             /**< \brief Number of elements in \f$v\f$. */
    int n_q;                             /**< \brief Number of elements in \f$q\f$. */
    int n_d;                             /**< \brief Number of elements in \f$d\f$. */

    int n_z;                             /**< \brief Number of elements in \f$z\f$. */
    
    int n_dae_blocks;                    /**< \brief Number of BLT blocks. */
    int n_dae_init_blocks;               /**< \brief Number of initial BLT blocks. */
    
    jmi_real_t *tp;                      /**< \brief Time point values in the normalized interval [0..1]. A value \f$\leq 0\f$ corresponds to the initial time and a value \f$\geq 1\f$ corresponds to the final time. */

    /* Offset variables in the z vector, for convenience. */
    int offs_real_ci;                    /**< \brief  Offset of the independent real constant vector in \f$z\f$. */
    int offs_real_cd;                    /**< \brief  Offset of the dependent real constant vector in \f$z\f$. */
    int offs_real_pi;                    /**< \brief  Offset of the independent real parameter vector in \f$z\f$. */
    int offs_real_pd;                    /**< \brief  Offset of the dependent real parameter vector in \f$z\f$. */

    int offs_integer_ci;                 /**< \brief  Offset of the independent integer constant vector in \f$z\f$. */
    int offs_integer_cd;                 /**< \brief  Offset of the dependent integer constant vector in \f$z\f$. */
    int offs_integer_pi;                 /**< \brief  Offset of the independent integer parameter vector in \f$z\f$. */
    int offs_integer_pd;                 /**< \brief  Offset of the dependent integer parameter vector in \f$z\f$. */

    int offs_boolean_ci;                 /**< \brief  Offset of the independent boolean constant vector in \f$z\f$. */
    int offs_boolean_cd;                 /**< \brief  Offset of the dependent boolean constant vector in \f$z\f$. */
    int offs_boolean_pi;                 /**< \brief  Offset of the independent boolean parameter vector in \f$z\f$. */
    int offs_boolean_pd;                 /**< \brief  Offset of the dependent boolean parameter vector in \f$z\f$. */

    int offs_real_dx;                    /**< \brief  Offset of the derivative real vector in \f$z\f$. */
    int offs_real_x;                     /**< \brief  Offset of the differentiated real variable vector in \f$z\f$. */
    int offs_real_u;                     /**< \brief  Offset of the input real vector in \f$z\f$. */
    int offs_real_w;                     /**< \brief  Offset of the algebraic real variables vector in \f$z\f$. */
    int offs_t;                          /**< \brief  Offset of the time entry in \f$z\f$. */

    int offs_real_dx_p;                  /**< \brief  Offset of the first time point derivative vector in \f$z\f$. */
    int offs_real_x_p;                   /**< \brief  Offset of the first time point differentiated variable vector in \f$z\f$. */
    int offs_real_u_p;                   /**< \brief  Offset of the first time point input vector in \f$z\f$. */
    int offs_real_w_p;                   /**< \brief  Offset of the first time point algebraic variable vector in \f$z\f$. */

    int offs_real_d;                     /**< \brief  Offset of the discrete real variable vector in \f$z\f$. */

    int offs_integer_d;                  /**< \brief  Offset of the discrete integer variable vector in \f$z\f$. */
    int offs_integer_u;                  /**< \brief  Offset of the input integer vector in \f$z\f$. */

    int offs_boolean_d;                  /**< \brief  Offset of the discrete boolean variable vector in \f$z\f$. */
    int offs_boolean_u;                  /**< \brief  Offset of the input boolean vector in \f$z\f$. */

    int offs_sw;                         /**< \brief  Offset of the first switching function in the DAE \f$F\f$ */
    int offs_sw_init;                    /**< \brief  Offset of the first switching function in the DAE initialization system \f$F_0\f$ */

    int offs_guards;                     /**< \brief  Offset of the first guard \f$F\f$ */
    int offs_guards_init;                /**< \brief  Offset of the first guard in the DAE initialization system \f$F_0\f$ */

    int offs_pre_real_dx;                /**< \brief  Offset of the pre derivative real vector in \f$z\f$. */
    int offs_pre_real_x;                 /**< \brief  Offset of the pre differentiated real variable vector in \f$z\f$. */
    int offs_pre_real_u;                 /**< \brief  Offset of the pre input real vector in \f$z\f$. */
    int offs_pre_real_w;                 /**< \brief  Offset of the pre algebraic real variables vector in \f$z\f$. */

    int offs_pre_real_d;                 /**< \brief  Offset of the pre discrete real variable vector in \f$z\f$. */

    int offs_pre_integer_d;              /**< \brief  Offset of the pre discrete integer variable vector in \f$z\f$. */
    int offs_pre_integer_u;              /**< \brief  Offset of the pre input integer vector in \f$z\f$. */

    int offs_pre_boolean_d;              /**< \brief  Offset of the pre discrete boolean variable vector in \f$z\f$. */
    int offs_pre_boolean_u;              /**< \brief  Offset of the pre input boolean vector in \f$z\f$. */

    int offs_pre_sw;                     /**< \brief  Offset of the first pre switching function in the DAE \f$F\f$ */
    int offs_pre_sw_init;                /**< \brief  Offset of the first pre switching function in the DAE initialization system \f$F_0\f$ */

    int offs_pre_guards;                 /**< \brief  Offset of the first pre guard \f$F\f$ */
    int offs_pre_guards_init;            /**< \brief  Offset of the first pre guard in the DAE initialization system \f$F_0\f$ */

    int offs_p;                          /**< \brief  Offset of the \f$p\f$ vector in \f$z\f$. */
    int offs_v;                          /**< \brief  Offset of the \f$v\f$ vector in \f$z\f$. */
    int offs_q;                          /**< \brief  Offset of the \f$q\f$ vector in \f$z\f$. */
    int offs_d;                          /**< \brief  Offset of the \f$d\f$ vector in \f$z\f$. */

    jmi_ad_var_vec_p z;                  /**< \brief  This vector contains active AD objects in case of AD. */
    jmi_real_t** z_val;                  /**< \brief  This vector contains the actual values. */
    jmi_real_t **dz;                     /**< \brief  This vector is used to store calculated directional derivatives */
    int dz_active_index;                 /**< \brief The element in dz_active_variables to be used (0..JMI_ACTIVE_VAR_BUFS_NUM). Needed for local iterations */
    int block_level;                     /**< \brief Block level for nested equation blocks. Currently 0 or 1. */
    jmi_real_t *dz_active_variables[1];	 /**< \brief  This vector is used to store seed-values for active variables in block Jacobians */
#define JMI_ACTIVE_VAR_BUFS_NUM 3
    jmi_real_t *dz_active_variables_buf[JMI_ACTIVE_VAR_BUFS_NUM];  /**< \brief  This vector is the buffer used by dz_active_variables */
    void** ext_objs;                     /**< \brief This vector contains the external object pointers. */
    int indep_extobjs_initialized;       /** <\brief Flag indicating if initialization of independent external objects have been done. */
    int dep_extobjs_initialized;         /** <\brief Flag indicating if initialization of dependent external objects have been done. */
    
    jmi_real_t *variable_scaling_factors;             /**< \brief Scaling factors. For convenience the vector has the same size as z but only scaling of reals are used. */
    int scaling_method;                               /**< \brief Scaling method: JMI_SCALING_NONE, JMI_SCALING_VARIABLES */
    jmi_block_residual_t** dae_block_residuals;       /**< \brief A vector of function pointers to DAE equation blocks */
    jmi_block_residual_t** dae_init_block_residuals;  /**< \brief A vector of function pointers to DAE initialization equation blocks */
    int cached_block_jacobians;                       /**< \brief This flag indicates weather the Jacobian needs to be refactorized */

    jmi_int_t n_initial_relations;       /**< \brief Number of relational operators used in the event indicators for the initialization system. There should be the same number of initial relations as there are event indicators */
    jmi_int_t* initial_relations;        /**< \brief Kind of relational operators used in the event indicators for the initialization system: JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ */
    jmi_int_t n_relations;               /**< \brief Number of relational operators used in the event indicators for the DAE system */
    jmi_int_t* relations;                /**< \brief Kind of relational operators used in the event indicators for the DAE system: JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ */

    jmi_ad_var_t atEvent;                /**< \brief A boolean variable indicating if the model equations are evaluated at an event.*/
    jmi_ad_var_t atInitial;              /**< \brief A boolean variable indicating if the model equations are evaluated at the initial time */

    jmi_int_t is_initialized;            /**< Flag to keep track of if the initial equations have been solved. */

    jmi_simple_color_info_t* color_info_A;  /**< \brief CPR coloring info for the ODE Jacobian A */
    jmi_simple_color_info_t* color_info_B;  /**< \brief CPR coloring info for the ODE Jacobian B */
    jmi_simple_color_info_t* color_info_C;  /**< \brief CPR coloring info for the ODE Jacobian C */
    jmi_simple_color_info_t* color_info_D;  /**< \brief CPR coloring info for the ODE Jacobian D */

    jmi_options_t options;               /**< \brief Runtime options */
    jmi_real_t events_epsilon;           /**< \brief Value used to adjust the event indicator functions */
    jmi_int_t recomputeVariables;        /**< \brief Dirty flag indicating when equations should be resolved. */
    jmi_log_t *log;                      /**< \brief Struct containing the structured logger. */

    jmp_buf try_location;                /**< \brief Buffer for setjmp/longjmp, for exception handling. */
    int terminate;                       /**< \brief Flag to trigger termination of the simulation. */
};

/**
 * \brief Struct describing a DAE model.
 *
 * Contains one jmi_func_t struct representing the DAE residual
 * function.
 */
struct jmi_dae_t {
    jmi_func_t* F;                           /**< \brief  A jmi_func_t struct representing the DAE residual \f$F\f$. */
    jmi_func_t* R;                           /**< \brief  A jmi_func_t struct representing the DAE event indicator function \f$R\f$. */
    jmi_generic_func_t ode_derivatives;      /**< \brief A function pointer to a function for evaluating the ODE derivatives. */
    jmi_generic_func_t ode_derivatives_dir_der;      /**< \brief A function pointer to a function for evaluating the ODE directional derivative. */
    jmi_generic_func_t ode_outputs;          /**< \brief A function pointer to a function for evaluating the ODE outputs. */
    jmi_generic_func_t ode_initialize;       /**< \brief A function pointer to a function for initializing the ODE. */
    jmi_generic_func_t ode_guards;           /**< A function pointer for evaluating the guard expressions. */
    jmi_generic_func_t ode_guards_init;      /**< A function pointer for evaluating the guard expressions in the initial equations. */
    jmi_next_time_event_func_t ode_next_time_event;  /**< A function pointer for computing the next time event instant. */
};

/**
 * \brief A struct containing a DAE initialization system.
 */
struct jmi_init_t {
    jmi_func_t* F0;                      /**< \brief  A jmi_func_t struct representing \f$F_0\f$. */
    jmi_func_t* F1;                      /**< \brief  A jmi_func_t struct representing \f$F_1\f$. */
    jmi_func_t* Fp;                      /**< \brief  A jmi_func_t struct representing \f$F_p\f$. */
    jmi_func_t* R0;                      /**< \brief  A jmi_func_t struct representing \f$R_0\f$. */
    jmi_generic_func_t eval_parameters;  /**< \brief A function pointer to a function for evaluating parameters. */
};

/**
 * \brief A struct containing functions and information about the
 * interval definition and optimization parameters for an optimization
 * problem.
 */
struct  jmi_opt_t {
    jmi_func_t* Ffdp;                     /**< \brief  Function pointer to the free dependent parameters residual function. */
    jmi_func_t* J;                        /**< \brief  Function pointer to the cost function. */
    jmi_func_t* L;                        /**< \brief  Function pointer to the Lagrange integrand. */
    jmi_func_t* Ceq;                      /**< \brief  Function pointer to the equality path constraint residual function. */
    jmi_func_t* Cineq;                    /**< \brief  Function pointer to the inequality path constraint residual function. */
    jmi_func_t* Heq;                      /**< \brief  Function pointer to the equality point constraint residual function. */
    jmi_func_t* Hineq;                    /**< \brief  Function pointer to the inequality point constraint residual function. */
    jmi_real_t start_time;                /**< \brief  Optimization interval start time. */
    int start_time_free;                  /**< \brief  Start time free or fixed. */
    jmi_real_t final_time;                /**< \brief  Optimization interval final time. */
    int final_time_free;                  /**< \brief  Final time free or fixed. */
    int n_p_opt;                          /**< \brief  Number of parameters to optimize (in the \f$p_i\f$ vector). */
    int *p_opt_indices;                   /**< \brief  Indices of the parameters to optimize (in the \f$p_i\f$ vector). */
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

/**
 * \brief Compute the class of variable in Jacobian specified by independent_vars
 * and mask.
 *
 * The return value is one of JMI_DER_NN if a valid Jacobian column index is
 * given, otherwise -1. For example JMI_DER_X indicats a differentiated
 * variable.
 *
 * @param jmi A jmi_t struct.
 * @param independent_vars See ::jmi_dae_dF.
 * @param mask See ::jmi_dae_dF.
 * @param col_index The column index for which to compute the variable class.
 * @return Variable class.
 */
int jmi_variable_type_spec(jmi_t *jmi, int independent_vars,
                                  int *mask, int col_index);



/* @} */

/* @} */

#ifdef JMI_AD_NONE_AND_CPP
}
#endif /* JMI_AD_NONE_AND_CPP */
#endif /* _JMI_COMMON_H */
