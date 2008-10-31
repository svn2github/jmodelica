/**
 * Interface to first derivatives of the dae residual
 *
 *   Assume dense Jacobians for now.
 */

/*
 * This function is provided for the user in order to know the size of memory to allocate
 *
 */

#ifndef _JMI_DAE_SD_H
#define _JMI_DAE_SD_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif

int jmi_dae_sd_dF(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
     	      Double_t* w, Double_t t, int mask, Double_t* jac);

#if defined __cplusplus
    }
#endif

#endif
