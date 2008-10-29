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

#ifndef _JMI_INIT_AD_H
#define _JMI_INIT_AD_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif


int jmi_dae_ad_dF0dpd(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);

int jmi_dae_ad_dF0dpi(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);

int jmi_dae_ad_dF0ddx(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);

int jmi_dae_ad_dF0dx(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);

int jmi_dae_ad_dF0du(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);

int jmi_dae_ad_dF0dw(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);

int jmi_dae_ad_dF0dt(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t t0, Double_t* jac);


#if defined __cplusplus
    }
#endif

#endif
