/*
   This interface describes a DAE on the form

     F(ci,cd,pi,pd,dx,x,u,w,t) = 0

   were

     ci   independent constant
     cd   dependent constants
     pi   independent parameters
     pd   dependent parameters

     dx    differentiated variables
     x     variables whos derivatives appear in the DAE
     u     inputs
     w     algebraic variables
     t     time

 */


#ifndef _JMI_DAE_H
#define _JMI_DAE_H

#include "jmi.h"

#if defined __cplusplus
extern "C" {
#endif

	typedef struct Jmi_dae Jmi_dae;

	struct Jmi_def {

		int (*jmi_dae_sd_dF)(Jmi_dae*, Double_t* , Double_t*, Double_t*, Double_t*,
	               Double_t*, Double_t*, Double_t*,
	      	      Double_t*, Double_t, int, Double_t*);
		int (*jmi_dae_ad_dF)(Jmi_dae*, Double_t* , Double_t*, Double_t*, Double_t*,
	               Double_t*, Double_t*, Double_t*,
	      	      Double_t*, Double_t, int, Double_t*);
		int (*jmi_dae_fd_dF)(Jmi_dae*, Double_t* , Double_t*, Double_t*, Double_t*,
	               Double_t*, Double_t*, Double_t*,
	      	      Double_t*, Double_t, int, Double_t*);

		int sd_initialized;
		int ad_initialized;
		int fd_initialized;

		//Fields for AD stuff

		double* jac_fd_work1;
		double* jac_fd_work2;

	};


	/**
	 * Return sizes of model vectors.
	 */
	 int jmi_dae_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
			 int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq);

	/**
	 * Evaluation of DAE residual.
	 */
	 int jmi_dae_F(Jmi_dae* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			 Double_t t, Double_t* res);

	 /**
	  * This function returns the size of the jacobian vector given a particular mask.
	  */
	 int jmi_dae_der_get_sizes(int* nJacF, int mask);

	 int jmi_dae_dF(Jmi_dae* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u,
			 Double_t* w, Double_t t, int mask, Double_t* jac);


	 // These signatures should be in jmi_dae_der.h that is not part of the external interface.

	 static int jmi_dae_ad_dF(Jmi_dae* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	      	      Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);

	 static int jmi_dae_fd_dF(Jmi_dae* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	      	      Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);



	 /*
DAE_der_struct  jmi_dae_init(int der_type);

int jmi_dae_dF(DAE_der_struct data, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
     	      Double_t* w, Double_t t, int mask, Double_t* jac) {

	if (data->der_type == AD) {
		jmi_dae_sd_dF(DAE_der_struct data, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	              Double_t* dx, Double_t* x, Double_t* u,
	     	      Double_t* w, Double_t t, int mask, Double_t* jac);

	}


}

int jmi_dae_der_query(int* der_availability_mask);
	  */

#if defined __cplusplus
}
#endif


#endif
