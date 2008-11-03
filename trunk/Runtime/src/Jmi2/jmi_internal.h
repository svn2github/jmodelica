
#ifndef _JMI_INTERNAL_H
#define _JMI_INTERNAL_H

#include "jmi_runtime.h"

#if defined __cplusplus
extern "C" {
#endif

	typedef struct {
		double* jac_fd_work1;
		double* jac_fd_work2;
	} Jmi_dae;


	typedef struct {
		double* jac_fd_work1;
		double* jac_fd_work2;
	} Jmi_init;

	typedef struct {
		double* jac_fd_work1;
		double* jac_fd_work2;
	} Jmi_opt;

	typedef struct {
		Jmi jmi;
        Jmi_dae jmi_dae;
        Jmi_init jmi_init;
        Jmi_opt jmi_opt;
	} Jmi_internal;


	// Derivatives for dae part
	/**
	 * This function returns the size of the jacobian vector given a particular mask.
	 */
	static int jmi_dae_der_get_sizes(int* n_jac_F, int mask);

	static int jmi_dae_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
				Double_t* dx, Double_t* x, Double_t* u,
				Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_dae_ad_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_dae_fd_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	// Derivatives for init part
	/**
	 * This function returns the size of the jacobian vector given a particular mask.
	 */
	static int jmi_init_der_get_sizes(int* n_jac_F0, int* n_jac_F1, int mask);

	static int jmi_init_dF0(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_init_dF1(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_init_ad_dF0(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_init_ad_dF1(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_init_fd_dF0(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_init_fd_dF1(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	// Derivative functions for opt part
	/**
	 * This function returns the size of the jacobian vector given a particular mask.
	 */
	static int jmi_opt_der_get_sizes(int* n_jac_J, int* n_jac_Ceq, int* n_jac_Cineq, int* n_jac_Heq, int* n_jac_Hineq, int mask);

	static int jmi_opt_dJ(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_opt_dCeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_opt_dCineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_opt_dHeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_opt_dHineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	static int jmi_opt_ad_dJ(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_ad_dCeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_ad_dCineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_ad_dHeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_ad_dHineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_fd_dJ(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_fd_dCeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_fd_dCineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_fd_dHeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

	static int jmi_opt_fd_dHineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac);

#if defined __cplusplus
}
#endif

#endif
