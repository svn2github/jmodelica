
#include "../../Jmi/jmi_dae.h"

int jmi_dae_sd_dF(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
     	      Double_t* w, Double_t t, int mask, Double_t* jac) {


	int jac_index = 0;

	if (mask & DER_PI) {
		jac[jac_index++] = 0;
	   	jac[jac_index++] = x[0];
	   	jac[jac_index++] = 0;
	}
	if (mask & DER_PD) {

	}
	if (mask & DER_DX) {
		jac[jac_index++] = -1;
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = 0;
	 	jac[jac_index++] = -1;
	  	jac[jac_index++] = 0;
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = -1;
	}
	if (mask & DER_X) {
		jac[jac_index++] = (1-x[1]*x[1]);
	   	jac[jac_index++] = pi[0];
	   	jac[jac_index++] = 2*x[0];
	   	jac[jac_index++] = -2*x[1]*x[0] - 1;
	 	jac[jac_index++] = 0;
	  	jac[jac_index++] = 2*x[1];
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = 0;
	}
	if (mask & DER_U) {
	   	jac[jac_index++] = 1;
	   	jac[jac_index++] = 0;
	   	jac[jac_index++] = 2*u[0];

	}
	if (mask & DER_W) {

	}

	return 0;
}

