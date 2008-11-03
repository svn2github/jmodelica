#include "jmi_internal.h"
#include "jmi_runtime.h"
#include "jmi.h"

// Derivatives for dae part
	static int jmi_dae_der_get_sizes(int* n_jac_F, int mask){

		*n_jac_F = 0;
		int n_ci;
		int n_cd;
		int n_pi;
		int n_pd;
		int n_dx;
		int n_x;
		int n_u;
		int n_w;
		int n_eq;

		jmi_dae_get_sizes(&n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_eq);

		if (mask & DER_PI) {
			*n_jac_F += n_eq*n_pi;
		}
		if (mask & DER_PD) {
	        *n_jac_F += n_eq*n_pd;
		}
		if (mask & DER_DX) {
	        *n_jac_F += n_eq*n_dx;
		}
		if (mask & DER_X) {
	        *n_jac_F += n_eq*n_x;
		}
		if (mask & DER_U) {
	        *n_jac_F += n_eq*n_u;
		}
		if (mask & DER_W) {
	        *n_jac_F += n_eq*n_w;
		}

		return 1;
	}

	static int jmi_dae_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
				Double_t* dx, Double_t* x, Double_t* u,
				Double_t* w, Double_t t, int der_method, int mask, Double_t* jac) {

		return 1;
	}

	static int jmi_dae_ad_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;
	}

	static int jmi_dae_fd_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	// Derivatives for init part
	static int jmi_init_der_get_sizes(int* n_jac_F0, int* n_jac_F1, int mask) {

	}

	static int jmi_init_dF0(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac)  {

		// not implemented yet
		return 0;

	}

	static int jmi_init_dF1(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_init_ad_dF0(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_init_ad_dF1(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_init_fd_dF0(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_init_fd_dF1(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	// Derivative functions for opt part
	static int jmi_opt_der_get_sizes(int* n_jac_J, int* n_jac_Ceq,
			                         int* n_jac_Cineq, int* n_jac_Heq, int* n_jac_Hineq, int mask) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_dJ(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_dCeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac)  {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_dCineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_dHeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_dHineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_ad_dJ(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_ad_dCeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_ad_dCineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_ad_dHeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_ad_dHineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_fd_dJ(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_fd_dCeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_fd_dCineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_fd_dHeq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

	static int jmi_opt_fd_dHineq(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int mask, Double_t* jac) {

		// not implemented yet
		return 0;

	}

