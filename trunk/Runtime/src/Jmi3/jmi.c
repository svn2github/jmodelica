// This is the implementation of the "external" interface
#include <stdlib.h>
#include "jmi.h"

/*
static int jmi_dae_fd_jac_F(Jmi_dae_der* jmi_dae_der, Double_t* ci, Double_t* cd,
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int* mask, Double_t* jac) {
  // Code for finite differences
  return 1;

}


static int jmi_dae_ad_jac_F(Jmi_dae_der* jmi_dae_der, Double_t* ci, Double_t* cd,
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int* mask, Double_t* jac) {

  // Code for automatic differentiation
  return 1;

}

static int jmi_dae_jac_fd_F_nnz(Jmi_dae_der* jmi_dae_der, int* nnz) {
  //...
  return 1;
}

static int jmi_dae_jac_fd_F_nz_indices(Jmi_dae_der* jmi_dae_der, int* row, int* col) {
  //... Ehhh, what to do here...? Assume dense fd:s? May relay on info from generated code.
  return 1;
}

static int jmi_dae_jac_ad_F_nnz(Jmi_dae_der* jmi_dae_der, int* nnz) {
  //...
  return 1;
}

static int jmi_dae_jac_ad_F_nz_indices(Jmi_dae_der* jmi_dae_der, int* row, int* col) {
  //...
  return 1;
}

int jmi_der_new(Jmi* jmi, Jmi_der* jmi_der) {
  jmi_der = (Jmi_der*)malloc(sizeof(Jmi_der));
  // Allocate jmi_dae_der
  Jmi_dae_der* jmi_dae_der = (Jmi_dae_der*)malloc(sizeof(Jmi_dae_der));
  jmi_dae_der->jmi = jmi;
  jmi_dae_der->jac_F = &jmi_dae_jac_F;
  jmi_dae_der->jac_fd_F_nnz = &jmi_dae_jac_fd_F_nnz;
  jmi_dae_der->jac_fd_F_nz_indices = &jmi_dae_jac_fd_F_nz_indices;
  jmi_dae_der->jac_ad_F_nnz = &jmi_dae_jac_ad_F_nnz;
  jmi_dae_der->jac_ad_F_nz_indices = &jmi_dae_jac_ad_F_nz_indices;
 // Allocate jmi_init_der...

 // Allocate jmi_init_der...

  jmi_der->jmi_dae_der = jmi_dae_der;
  //  jmi_der->jmi_init_der = jmi_init_der;
  //  jmi_der->jmi_opt_der = jmi_opt_der;

  return 1;
}

int jmi_der_delete(Jmi_der* jmi_der) {
  free(jmi_der->jmi_dae_der);
  //free(jmi_der->jmi_init_der);
  //free(jmi_der->jmi_opt_der);
  free(jmi_der);
  return 1;
}
*/
