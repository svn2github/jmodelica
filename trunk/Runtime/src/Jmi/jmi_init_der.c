
#include "jmi_init.h"

int jmi_init_der_get_sizes(int* nJacF0, int* nJacF1, int mask) {

	*nJacF0 = 0;
	*nJacF1 = 0;
	int n_ci;
	int n_cd;
	int n_pi;
	int n_pd;
	int n_dx;
	int n_x;
	int n_u;
	int n_w;
	int n_eq_F0;
	int n_eq_F1;

	jmi_init_get_sizes(&n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_eq_F0, &n_eq_F1);

	if (mask & AD_PI) {
		*nJacF0 += n_eq_F0*n_pi;
		*nJacF1 += n_eq_F1*n_pi;
	}
	if (mask & AD_PD) {
        *nJacF0 += n_eq_F0*n_pd;
        *nJacF1 += n_eq_F1*n_pd;
	}
	if (mask & AD_DX) {
        *nJacF0 += n_eq_F0*n_dx;
        *nJacF1 += n_eq_F1*n_dx;
	}
	if (mask & AD_X) {
        *nJacF0 += n_eq_F0*n_x;
        *nJacF1 += n_eq_F1*n_x;
	}
	if (mask & AD_U) {
        *nJacF0 += n_eq_F0*n_u;
        *nJacF1 += n_eq_F1*n_u;
	}
	if (mask & AD_W) {
        *nJacF0 += n_eq_F0*n_w;
        *nJacF1 += n_eq_F1*n_w;
	}

	return 0;

}
