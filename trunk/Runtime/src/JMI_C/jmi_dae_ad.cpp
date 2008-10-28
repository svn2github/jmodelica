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

#include <adolc/adolc.h>
#include <adolc/adouble.h>

int jmi_dae_ad_dFdpd(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		     Double_t* w, Double_t t, Double_t* jac) {

  /*
  static Tape tape;
  static int tape_initialized;
  if (!tape_initialized) {
    compute tape;
  }

  evaluate derivative.
  */
}

int jmi_dae_ad_dFdpi(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		     Double_t* w, Double_t t, Double_t* jac) {

}

int jmi_dae_ad_dFddx(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		     Double_t* w, Double_t t, Double_t* jac) {

}

int jmi_dae_ad_dFdx(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		    Double_t* w, Double_t t, Double_t* jac) {

}

int jmi_dae_ad_dFdu(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		    Double_t* w, Double_t t, Double_t* jac) {

}

int jmi_dae_ad_dFdw(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		    Double_t* w, Double_t t, Double_t* jac) {

}

int jmi_dae_ad_dFdt(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
		    Double_t* w, Double_t t, Double_t* jac) {

}


