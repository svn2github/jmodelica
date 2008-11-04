// Example of generated function

#include <stdio.h>
#include <stdlib.h>
#include "jmi_low.h"

static int jmi_dae_F(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		 Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		 Double_t t, Double_t* res) {
  // Generated code
  return 1;
}

static int jmi_dae_sd_jac_F(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u,
			 Double_t* w, Double_t t, int* mask, Double_t* jac) {
  // Generated code
  return 1;
}


// This is the init function
int jmi_new(Jmi* jmi) {
  // Create jmi struct
  jmi = (Jmi*)malloc(sizeof(Jmi));
  // Create jmi_dae struct
  Jmi_dae* jmi_dae = (Jmi_dae*)malloc(sizeof(Jmi_dae));
  // Assign function pointers
  jmi_dae->dae_F = &jmi_dae_F;
  jmi_dae->dae_sd_jac_F = &jmi_dae_sd_jac_F;
  // Set sizes of dae vectors
  jmi_dae->n_ci=0;
  jmi_dae->n_cd=0;
  jmi_dae->n_pi=0;
  jmi_dae->n_pd=0;
  jmi_dae->n_dx=0;
  jmi_dae->n_x=0;
  jmi_dae->n_u=0;
  jmi_dae->n_w=0;
  jmi_dae->n_eq=0;
  // Set sparsity information of jacobian
  jmi_dae->jac_sd_F_nnz = 4;
  jmi_dae->jac_sd_F_nz_row = (Double_t*)malloc(jmi_dae->jac_sd_F_nnz*sizeof(Double_t));
  jmi_dae->jac_sd_F_nz_col =  (Double_t*)malloc(jmi_dae->jac_sd_F_nnz*sizeof(Double_t));
  jmi_dae->jac_sd_F_nz_row[0] = 1;
  jmi_dae->jac_sd_F_nz_row[1] = 2;
  jmi_dae->jac_sd_F_nz_row[2] = 1;
  jmi_dae->jac_sd_F_nz_row[3] = 2;
  jmi_dae->jac_sd_F_nz_col[0] = 1;
  jmi_dae->jac_sd_F_nz_col[1] = 1;
  jmi_dae->jac_sd_F_nz_col[2] = 2;
  jmi_dae->jac_sd_F_nz_col[3] = 2;

  // Set struct pointers in jmi 
  jmi->jmi_dae = jmi_dae;
  jmi->jmi_init = NULL;
  jmi->jmi_opt = NULL;
  return 1;
}

int jmi_delete(Jmi* jmi){
  if(jmi->jmi_dae != NULL) {
    if (jmi->jmi_dae->jac_sd_F_nz_row != NULL) {
      free(jmi->jmi_dae->jac_sd_F_nz_row);
    }
    if (jmi->jmi_dae->jac_sd_F_nz_col != NULL) {
      free(jmi->jmi_dae->jac_sd_F_nz_col);
    }
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
