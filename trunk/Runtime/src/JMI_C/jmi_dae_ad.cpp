/**
 * Interface to first derivatives of the dae residual
 *
 *   - DAE residual Jacobian w.r.t. pd: jac = dFdpd
 *   - DAE residual Jacobian w.r.t. pi: jac = dFdpi
 *   - DAE residual Jacobian w.r.t. dx: jac = dFddx
 *   - DAE residual Jacobian w.r.t. x: jac = dFdx
 *   - DAE residual Jacobian w.r.t. u: jac = dFdu
 *   - DAE residual Jacobian w.r.t. w: jac = dFdw
 *   - DAE residual Jacobian w.r.t. t: jac = dFdt
 *
 *   Assume dense Jacobians for now.
 */


#include "jmi_dae.h"

//#include <adolc/adolc.h>
//#include <adolc/adouble.h>

int jmi_dae_ad_get_sizes(int* nJacF, int mask) {

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

	}
	if (mask & AD_DX) {

	}
	if (mask & AD_X) {

	}
	if (mask & AD_U) {

	}
	if (mask & AD_W) {

	}

	return 0;


}


int jmi_dae_ad_dF(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
		     Double_t* w, Double_t t, int mask, Double_t* jac) {

	// This is a quick and dirty finite difference implementation.


  /*
  static Tape tape;
  static int tape_initialized;
  if (!tape_initialized) {
    compute tape;
  }

  evaluate derivative.
  */

	return 0;

}


