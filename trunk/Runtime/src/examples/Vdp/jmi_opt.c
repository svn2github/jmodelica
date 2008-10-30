
/**
 * This file encodes the optimization problem
 *
 *  min x_3(t_f)
 *   u
 *
 *  subject to
 *
 *   \dot x_1 = (1 - x_2^2)*x_1 - x_2 + u
 *   \dot x_2 = p_1*x_1
 *   \dot x_3 = x_1^2 + x_2^2 + u^2
 *
 *  -1 <= u <= 1
 *
 * with initial conditions
 *
 *   x_1(0) = 0;
 *   x_2(0) = 1;
 *   x_3(0) = 0;
 *
 *  and t_f = 5.
 *
 */

#include "../../JMI_C/jmi_opt.h"

int jmi_opt_get_sizes(int* n_Ceq, int* n_Cineq, int* n_Heq, int* n_Hineq) {

	*n_Ceq = 0;
	*n_Cineq = 2;
	*n_Heq = 0;
	*n_Hineq = 0;

	return 0;

}

int jmi_opt_J(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t* t, Double_t* J) {

	// penalized x_3
	*J = x[2];

	return 0;

}

int jmi_opt_Ceq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t* t, Double_t* Ceq) {

	// No equality path constraints
	return 0;

}

int jmi_opt_Cineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t* t, Double_t* Cineq) {

	// u<=1
	Cineq[0] = u[0] - 1;
	// u>=-1
	Cineq[1] = -u[0] -1;

	return 0;

}

int jmi_opt_Heq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx_p, Double_t* x_p, Double_t* u_p,
              Double_t* w_p, Double_t* t_p, Double_t* Heq) {
    // No equality point constraints
	return 0;

}

int jmi_opt_Hineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx_p, Double_t* x_p, Double_t* u_p,
              Double_t* w_p, Double_t* t_p, Double_t* Hineq) {

	// No inequality point constraints
	return 0;

}
