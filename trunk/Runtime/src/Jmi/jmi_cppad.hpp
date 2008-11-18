#ifndef _JMI_CPPAD_HPP
#define _JMI_CPPAD_HPP

#include <cppad/cppad.hpp>
#include <stdio.h>

#include "jmi.h"

typedef std::vector< CppAD::AD<double> > Jmi_AD_vec;
typedef CppAD::AD<double> Jmi_AD;


// Function signatures

/**
 * Evaluation of the DAE residual .
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


int jmi_cppad_delete(Jmi* jmi);

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


#endif
