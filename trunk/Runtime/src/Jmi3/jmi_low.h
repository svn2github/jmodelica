// This is the include file that goes with the generated code.

#ifndef _JMI_LOW_H
#define _JMI_LOW_H

typedef double Double_t;

/*
 * These constants are used to encode and decode the masks that are
 * used as arguments in the Jacobian fuctions.
 *
 */

static const int DER_PI = 1;
static const int DER_PD = 2;
static const int DER_DX = 4;
static const int DER_X = 8;
static const int DER_U = 16;
static const int DER_W = 32;

static const int DER_FD = 1;
static const int DER_SD = 2;
static const int DER_AD = 4;

typedef int (*jmi_dae_F_t)(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			   Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			   Double_t t, Double_t* res);

typedef int (*jmi_dae_xd_jac_F_t)(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
				  Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
				  Double_t t, int* mask, Double_t* jac);

typedef struct {
  jmi_dae_F_t dae_F;
  jmi_dae_xd_jac_F_t dae_sd_jac_F;
  int n_ci;
  int n_cd;
  int n_pi;
  int n_pd;
  int n_dx;
  int n_x;
  int n_u;
  int n_w;
  int n_eq;
  int jac_sd_F_nnz;
  Double_t* jac_sd_F_nz_row;
  Double_t* jac_sd_F_nz_col;
} Jmi_dae;

typedef struct {

} Jmi_init;

typedef struct {
} Jmi_opt;

typedef struct {
  Jmi_dae* jmi_dae;
  Jmi_init* jmi_init;
  Jmi_opt* jmi_opt;
} Jmi;

int jmi_new(Jmi* jmi);
int jmi_delete(Jmi* jmi);

#endif
