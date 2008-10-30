
#ifndef _JMI_OPT_DER_H
#define _JMI_OPT_DER_H
#include "jmi.h"
#include "jmi_opt_der.h"

#if defined __cplusplus
        extern "C" {
#endif

/**
 * This function returns the size of the jacobian vector given a particular mask.
 */

int jmi_opt_der_get_sizes(int* nJacJ, int* nJacCeq, int* nJacCineq, int* nJacHeq, int* nJacHineq, int mask);



#if defined __cplusplus
    }
#endif

#endif
