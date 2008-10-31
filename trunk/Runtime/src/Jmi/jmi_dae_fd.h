/**
 * Interface to first derivatives of the dae residual
 *
 *   Assume dense Jacobians for now.
 */


#ifndef _JMI_DAE_FD_H
#define _JMI_DAE_FD_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif

int jmi_dae_fd_dF(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
     	      Double_t* w, Double_t t, int mask, Double_t* jac, Double_t* work1, Double_t* work2);

#if defined __cplusplus
    }
#endif

#endif
