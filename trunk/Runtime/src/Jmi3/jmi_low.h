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

typedef	int (*jmi_dae_get_sizes_t)(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
			int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq);

typedef int (*jmi_dae_F_t)(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		      Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		      Double_t t, Double_t* res);

typedef int (*jmi_dae_xd_dF_t)(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int mask, Double_t* res);

typedef struct {
  jmi_dae_get_sizes_t dae_get_sizes;
  jmi_dae_F_t dae_F;
  jmi_dae_xd_dF_t dae_sd_dF;
} Jmi_low;

int jmi_low_init(Jmi_low* jmi_low);
int jmi_low_delete(Jmi_low* jmi_low);




#endif
