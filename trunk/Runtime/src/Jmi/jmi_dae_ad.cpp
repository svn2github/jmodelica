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


int jmi_dae_ad_dF(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
		     Double_t* w, Double_t t, int mask, Double_t* jac) {


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


