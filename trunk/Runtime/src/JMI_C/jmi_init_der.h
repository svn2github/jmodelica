


#ifndef _JMI_INIT_DER_H
#define _JMI_INIT_DER_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif

/**
 * This function returns the size of the jacobian vector given a particular mask.
 */
int jmi_init_der_get_sizes(int* nJacF0, int* nJacF1, int mask);

#if defined __cplusplus
    }
#endif

#endif
