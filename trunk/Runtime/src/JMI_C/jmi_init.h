/*
   This interface describes a DAE system for initialization on the form

     F0(ci,cd,pi,pd,dx,x,u,w,t) = 0
     F1(ci,cd,pi,pd,dx,x,u,w,t) = 0

   were

     ci   independent constant
     cd   dependent constants
     pi   independent parameters
     pd   dependent parameters

     dx    differentiated variables
     x     variables whos derivatives appear in the DAE
     u     inputs
     w     algebraic variables
     t0     time

	F0 represents the DAE system augmented with additional initial equations
	and start values that are fixed. F1 on the other hand contains equations for
	initialization of variables for which the value given in the start attribute is
	not fixed.

*/

/**
 * Return sizes of model vectors.
 */

#ifndef _JMI_INIT_H
#define _JMI_INIT_H

#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif


int jmi_init_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
                       int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq_F0, int* _eq_F1);

/**
 *
 *   - initial DAE residual: res = F0(..)
 *
 */
int jmi_init_F0(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, Double_t* dx, Double_t* x,
		        Double_t* u, Double_t* w, Double_t t0, Double_t* res);

/**
 *
 *   - initial DAE residual: res = F1(..)
 *
 */
int jmi_init_F1(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, Double_t* dx, Double_t* x,
		        Double_t* u, Double_t* w, Double_t t0, Double_t* res);

#if defined __cplusplus
    }
#endif


#endif
