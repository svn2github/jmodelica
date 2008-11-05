// Example of generated function

#include <stdio.h>
#include <stdlib.h>
#include "../../Jmi3/jmi.h"

static int vdp_dae_F(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		 Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		 Double_t t, Double_t* res) {

	res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
	res[1] = pi[0]*x[0] - dx[1];
	res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0] - dx[2];

  return 1;
}

static int vdp_dae_sd_jac_F(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u,
			 Double_t* w, Double_t t, int sparsity, int skip, int* mask, Double_t* jac) {

/*
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

	*/
  return 1;
}

// This is the init function
int jmi_new(Jmi* jmi) {
  // Create jmi struct
  jmi = (Jmi*)malloc(sizeof(Jmi));
  // Create jmi_dae struct
  Jmi_dae* jmi_dae = (Jmi_dae*)malloc(sizeof(Jmi_dae));
  // Assign function pointers
  jmi_dae->F = &vdp_dae_F;
  jmi_dae->jac_sd_F = &vdp_dae_sd_jac_F;
  // Set sizes of dae vectors
  jmi_dae->n_ci=0;
  jmi_dae->n_cd=0;
  jmi_dae->n_pi=1;
  jmi_dae->n_pd=0;
  jmi_dae->n_dx=3;
  jmi_dae->n_x=3;
  jmi_dae->n_u=1;
  jmi_dae->n_w=0;
  jmi_dae->n_eq_F=3;
  // Set struct pointers in jmi
  jmi->jmi_dae = jmi_dae;
  jmi->jmi_init = NULL;
  jmi->jmi_opt = NULL;
  return 1;
}

int jmi_delete(Jmi* jmi){
  if(jmi->jmi_dae != NULL) {

    free(jmi->jmi_dae);
  }
  if(jmi->jmi_init != NULL) {
    free(jmi->jmi_init);
  }
  if(jmi->jmi_opt != NULL) {
    free(jmi->jmi_opt);
  }
  free(jmi);

return 1;
}
