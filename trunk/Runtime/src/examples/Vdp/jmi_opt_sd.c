
#include "../../JMI_C/jmi.h"

#if defined __cplusplus
        extern "C" {
#endif

int jmi_opt_sd_dJ(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac) {

	return 0;

}

int jmi_opt_sd_dCeq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac) {

	if (mask & AD_U) {
		jac[0] = 1;
		jac[1] = -1;
	}

	return 0;

}

int jmi_opt_sd_dCineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac) {
	return 0;

}

int jmi_opt_sd_dHeq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac) {
	return 0;

}

int jmi_opt_sd_dHineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
	      Double_t* w, Double_t t, int mask, Double_t* jac) {

	return 0;
}

#if defined __cplusplus
    }
#endif

