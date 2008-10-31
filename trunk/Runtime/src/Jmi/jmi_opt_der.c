
#include "jmi_opt.h"
#include "jmi_dae.h"

int jmi_opt_der_get_sizes(int* nJacJ, int* nJacCeq, int* nJacCineq, int* nJacHeq, int* nJacHineq, int mask) {

	*nJacCeq = 0;
	*nJacCineq = 0;
	*nJacHeq = 0;
	*nJacHineq = 0;
	int n_Ceq;
	int n_Cineq;
	int n_Heq;
	int n_Hineq;

	jmi_opt_get_sizes(&n_Ceq, &n_Cineq, &n_Heq, &n_Hineq);

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
		*nJacJ += n_pi;
		*nJacCeq += n_Ceq*n_pi;
		*nJacCineq += n_Cineq*n_pi;
		*nJacHeq += n_Heq*n_pi;
		*nJacHineq += n_Hineq*n_pi;
	}
	if (mask & DER_PD) {
		*nJacJ += n_pd;
        *nJacCeq += n_Ceq*n_pd;
        *nJacCineq += n_Cineq*n_pd;
        *nJacHeq += n_Heq*n_pd;
        *nJacHineq += n_Hineq*n_pd;
	}
	if (mask & DER_DX) {
		*nJacJ += n_dx;
        *nJacCeq += n_Ceq*n_dx;
        *nJacCineq += n_Cineq*n_dx;
        *nJacHeq += n_Heq*n_dx;
        *nJacHineq += n_Hineq*n_dx;
	}
	if (mask & DER_X) {
		*nJacJ += n_x;
        *nJacCeq += n_Ceq*n_x;
        *nJacCineq += n_Cineq*n_x;
        *nJacHeq += n_Heq*n_x;
        *nJacHineq += n_Hineq*n_x;
	}
	if (mask & DER_U) {
		*nJacJ += n_u;
        *nJacCeq += n_Ceq*n_u;
        *nJacCineq += n_Cineq*n_u;
        *nJacHeq += n_Heq*n_u;
        *nJacHineq += n_Hineq*n_u;
	}
	if (mask & DER_W) {
		*nJacJ += n_w;
        *nJacCeq += n_Ceq*n_w;
        *nJacCineq += n_Cineq*n_w;
        *nJacHeq += n_Heq*n_w;
        *nJacHineq += n_Hineq*n_w;
	}

	return 0;

}
