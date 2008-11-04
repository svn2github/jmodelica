// This interface offers additional functionality such as ad and fd support

#ifndef _JMI_H
#define _JMI_H

#include "jmi_low.h"



typedef struct Jmi_dae_der Jmi_dae_der;
typedef struct Jmi_init_der Jmi_init_der;
typedef struct Jmi_opt_der Jmi_opt_der;

/**
 * This function selects the derivative method: sd, fd, or ad. The mask is
 * a vector of integers of the same size as jac. If an entry in mask is 1,
 * then the corresponding jacobian element is computed, otherwise it is not
 * computed.
 */
typedef int (*jmi_dae_jac_F_t)(Jmi_dae_der* jmi_dae_der, Double_t* ci, Double_t* cd,
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			    Double_t t, int der_method, int* mask, Double_t* jac);

/**
 * These functions must be functions since they are not part of the generated
 * code base.
 */
typedef int (*jmi_dae_jac_F_nnz_t)(Jmi_dae_der* jmi_dae_der, int* nnz);
typedef int (*jmi_dae_jac_F_nz_indices_t)(Jmi_dae_der* jmi_dae_der, int* row, int* col);

struct Jmi_dae_der {
  Jmi* jmi;
  jmi_dae_jac_F_t jac_F;
  jmi_dae_jac_F_nnz_t jac_fd_F_nnz;
  jmi_dae_jac_F_nz_indices_t jac_fd_F_nz_indices;
  jmi_dae_jac_F_nnz_t jac_ad_F_nnz;
  jmi_dae_jac_F_nz_indices_t jac_ad_F_nz_indices;

};

struct Jmi_init_der {
  Jmi* jmi;
  //...
};

struct Jmi_opt_der {
  Jmi* jmi;
  //...
};

typedef struct {
  Jmi_dae_der* jmi_dae_der;
  Jmi_init_der* jmi_init_der;
  Jmi_opt_der* jmi_opt_der;
} Jmi_der;


int jmi_der_new(Jmi* jmi, Jmi_der* jmi_der);
int jmi_der_delete(Jmi_der* jmi_der);

#endif
