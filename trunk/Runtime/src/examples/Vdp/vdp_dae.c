
/**
 * This file encodes the model
 *
 *   \dot x_1 = (1 - x_2^2)*x_1 - x_2 + u
 *   \dot x_2 = p_1*x_1
 *   \dot x_3 = x_1^2 + x_2^2 + u^2
 *
 *   x_1(0) = 0
 *   x_2(0) = 1
 *   x_3(0) = 0
 *
 *   p_1 = 1;
 *
 */

#include "../../Jmi/jmi_dae.h"

int jmi_dae_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
                  int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq){

	*n_ci = 0;
	*n_cd = 0;
	*n_pi = 1;
	*n_pd = 0;
	*n_dx = 3;
	*n_x = 3;
	*n_u = 1;
	*n_w = 0;
	*n_eq = 3;

	return 0;

}

int jmi_dae_F(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
          Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
          Double_t t, Double_t* res) {

	res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
	res[1] = pi[0]*x[0] - dx[1];
	res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0] - dx[2];

	return 0;

}

