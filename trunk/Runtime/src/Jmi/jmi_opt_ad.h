/**
 * Interface to first derivatives of the dae residual
 *
 *
 *   Assume dense Jacobians for now.
 */

#ifndef _JMI_OPT_AD_H
#define _JMI_OPT_AD_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif

int jmi_opt_ad_dJ(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_opt_ad_dCeq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_opt_ad_dCineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_opt_ad_dHeq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_opt_ad_dHineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac);

#if defined __cplusplus
    }
#endif


#endif
