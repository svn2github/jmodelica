
#include "jmi_dae.h"

int jmi_dae_der_get_sizes(int* nJacF, int mask) {

	*nJacF = 0;
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

	if (mask & AD_PI) {
		*nJacF += n_eq*n_pi;
	}
	if (mask & AD_PD) {
        *nJacF += n_eq*n_pd;
	}
	if (mask & AD_DX) {
        *nJacF += n_eq*n_dx;
	}
	if (mask & AD_X) {
        *nJacF += n_eq*n_x;
	}
	if (mask & AD_U) {
        *nJacF += n_eq*n_u;
	}
	if (mask & AD_W) {
        *nJacF += n_eq*n_w;
	}

	return 0;

}
