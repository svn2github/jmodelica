#include "../../JMI_C/jmi_init.h"


int jmi_init_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
                       int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq_F0, int* n_eq_F1) {

	*n_ci = 0;
	*n_cd = 0;
	*n_pi = 1;
	*n_pd = 0;
	*n_dx = 3;
	*n_x = 3;
	*n_u = 1;
	*n_w = 0;
	*n_eq_F0 = 3;
	*n_eq_F1 = 3;

	return 0;

}

int jmi_init_F0(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, Double_t* dx,
		        Double_t* x, Double_t* u, Double_t* w, Double_t t0, Double_t* res) {

	// Initial residuals for the derivatives
	res[0] = dx[0] - (1-x[1]*x[1])*x[0] - x[1] + u[0];
	res[1] = dx[1] - pi[0]*x[0];
	res[2] = dx[2] - x[0]*x[0] + x[1]*x[1] + u[0]*u[0];

    return 0;
}

int jmi_init_F1(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, Double_t* dx,
		        Double_t* x, Double_t* u, Double_t* w, Double_t t0, Double_t* res) {

	// Initial conditions for the states
	res[0] = x[0] - 0;
	res[1] = x[1] - 1;
	res[2] = x[2] - 0;

    return 0;
}
