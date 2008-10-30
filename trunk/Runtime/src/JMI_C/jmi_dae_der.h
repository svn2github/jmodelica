


#ifndef _JMI_DAE_DER_H
#define _JMI_DAE_DER_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif

/**
 * This function returns the size of the jacobian vector given a particular mask.
 */
int jmi_dae_der_get_sizes(int* nJacF, int mask);


#if defined __cplusplus
    }
#endif

#endif
