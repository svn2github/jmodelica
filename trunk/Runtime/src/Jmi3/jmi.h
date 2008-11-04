// This interface offers additional functionality such as ad and fd support

#ifndef _JMI_H
#define _JMI_H

#include "jmi_low.h"



//typedef struct Jmi Jmi;

/**
 * This function selects the derivative method: sd, fd, or ad. The mask is
 * a vector of integers of the same size as jac. If an entry in mask is 1,
 * then the corresponding jacobian element is computed, otherwise it is not
 * computed.
 */
typedef int (*jmi_dae_jac_F_t)(Jmi* jmi, Double_t* ci, Double_t* cd,
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			    Double_t t, int der_method, int* mask, Double_t* jac);

struct Jmi_dae_der {
  jmi_dae_jac_F_t dae_jac_F;
  int jac_fd_F_nnz;
  double* jac_fd_F_nz_row;
  double* jac_fd_F_nz_col;
  int jac_ad_F_nnz;
  double* jac_ad_F_nz_row;
  double* jac_ad_F_nz_col;
};

int jmi_init(Jmi* jmi);
int jmi_delete(Jmi* jmi);

#endif
