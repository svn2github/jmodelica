/**
 *
 * This is a first draft of an interface to CppAD. The interface supports computation
 * of Jacobians and sparsity patterns on the form required by Ipopt.
 *
 * Usage:
 *    The initialization proceeds in two steps. A struct of type Jmi_cppad_dae_der
 *    is called in the jmi_cppad_new. Here, a pointer to the dae residual function, F,
 *    (and later to the other init and opt functions) is provided. The function F
 *    resides in the generated code, and it needs to be set here. One approach is
 *    to call jmi_cppad_new in the jmi_new function that is provided by the generated
 *    code. In a second initialization step, jmi_cppad_init is called. In this step
 *    all the tapes and the sparsity patterns are computed and cached. This requires
 *    actual values (sensible values, ideally...) are provided for all the independent
 *    variables. Such values may originate from XML data or solution of an initial system.
 *    Therefore it is reasonable that this function is called from outside of the the generated
 *    code.
 *
 * Current limitations:
 *   - Memory is copied at several locations form double* vectors to vector<AD>
 *     objects. This may be a bit inefficient - but how can it be avoided?
 *   - Work-vectors. New objects are created at each function call. It may make
 *     sense to allocate work vectors and save them between calls.
 *   - The current design is based on individual tapes for each of the independent
 *     variable vectors, pi, pd, dx, x, etc. While this works well for computation of
 *     Jacobians, this does not work for Hessians, because then we need to compute the
 *     cross terms such as \frac{d^2F}/{d_pd d_pi}. Probably all the independent variables
 *     need to be collected in one vector<AD> object, and then split in the dae_F function.
 *     Preferably, the generated code not be affected apart from changing function signatures
 *     and possibly splitting of the independent variables vector.
 *
 * Issues:
 *   - The code contains a lot of repetitive segments, which could probably be factored
 *     out by means of functions or macros.
 *   - If the generated code supports CppAD, the Jmi struct that is returned from jmi_new
 *     is currently incomplete in the sense that the field jmi->jmi_dae->F is not set. Rather
 *     this field is set in the function jmi_cppad_init. This is probably ok, since the Jmi
 *     struct is not complete anyway prior to the call of jmi_cppad_init.
 */

#ifndef _JMI_CPPAD_HPP
#define _JMI_CPPAD_HPP

#include <cppad/cppad.hpp>
#include <stdio.h>

#include "jmi.h"

/*
typedef std::vector< CppAD::AD<double> > Jmi_AD_vec;
typedef CppAD::AD<double> Jmi_AD;
*/

// Function signatures

/**
 * Evaluation of the DAE residual. This is the function signature that is needed in order
 * to support the AD types, and which should be used by the generated code.
 */
typedef int (*jmi_cppad_dae_F_t)(Jmi* jmi, Jmi_AD_vec &ci, Jmi_AD_vec &cd, Jmi_AD_vec &pi, Jmi_AD_vec &pd,
		Jmi_AD_vec &dx, Jmi_AD_vec &x, Jmi_AD_vec &u, Jmi_AD_vec &w,
				 Jmi_AD &t, Jmi_AD_vec &res);

/**
 * jmi_cppad_new creates a new Jmi_cppad_dae_der struct.
 * TODO: add function signatures for init and opt interfaces.
 */
int jmi_cppad_new(Jmi* jmi, jmi_cppad_dae_F_t cppad_res_func);

/**
 * jmi_cppad_init initializes the tapes and computes the sparsity patterns.
 */
int jmi_cppad_init(Jmi* jmi, Jmi_Double_t* ci_init, Jmi_Double_t* cd_init,
                           Jmi_Double_t* pi_init, Jmi_Double_t* pd_init,
		           Jmi_Double_t* dx_init, Jmi_Double_t* x_init, Jmi_Double_t* u_init,
		   Jmi_Double_t* w_init, Jmi_Double_t t_init);


/**
 * jmi_cppad_delete performs deallocations of tapes and sparsity information.
 */
int jmi_cppad_delete(Jmi* jmi);

/**
 * The struct Jmi_cppad_dae_der contains basically all the tapes and the sparsity patters
 * that are computed in the jmi_cppad_init function.
 *
 */
/*
typedef struct {
  Jmi_dae_der jmi_dae_der;
  jmi_cppad_dae_F_t F;

  Jmi_AD_vec *ci_independent;
  Jmi_AD_vec *cd_independent;

  Jmi_AD_vec *pi_independent;
  Jmi_AD_vec *F_pi_dependent;
  CppAD::ADFun<double> *F_pi_tape;
  Jmi_AD_vec *pd_independent;
  Jmi_AD_vec *F_pd_dependent;
  CppAD::ADFun<double> *F_pd_tape;
  Jmi_AD_vec *dx_independent;
  Jmi_AD_vec *F_dx_dependent;
  CppAD::ADFun<double> *F_dx_tape;
  Jmi_AD_vec *x_independent;
  Jmi_AD_vec *F_x_dependent;
  CppAD::ADFun<double> *F_x_tape;
  Jmi_AD_vec *u_independent;
  Jmi_AD_vec *F_u_dependent;
  CppAD::ADFun<double> *F_u_tape;
  Jmi_AD_vec *w_independent;
  Jmi_AD_vec *F_w_dependent;
  CppAD::ADFun<double> *F_w_tape;
  Jmi_AD_vec *t_independent;
  Jmi_AD_vec *F_t_dependent;
  CppAD::ADFun<double> *F_t_tape;

  bool tapes_initialized;

  int jac_F_n_nz;
  int* jac_F_irow; // Sparsity info for jacobian
  int* jac_F_icol; //

  // Sparsity patterns for individual independent variables
  // These variables are useful when computing the Jacobian
  int jac_F_pi_n_nz;
  int* jac_F_pi_irow;
  int* jac_F_pi_icol;

  int jac_F_pd_n_nz;
  int* jac_F_pd_irow;
  int* jac_F_pd_icol;

  int jac_F_dx_n_nz;
  int* jac_F_dx_irow;
  int* jac_F_dx_icol;

  int jac_F_x_n_nz;
  int* jac_F_x_irow;
  int* jac_F_x_icol;

  int jac_F_u_n_nz;
  int* jac_F_u_irow;
  int* jac_F_u_icol;

  int jac_F_w_n_nz;
  int* jac_F_w_irow;
  int* jac_F_w_icol;

  int jac_F_t_n_nz;
  int* jac_F_t_irow;
  int* jac_F_t_icol;

} Jmi_cppad_dae_der;

*/
#endif
