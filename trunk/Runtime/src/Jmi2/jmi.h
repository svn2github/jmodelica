/*
 * Design motivations
 *
 * The model/optimization interface is intended to be used in a wide range of
 * applications and on multiple platforms. This also includes embedded
 * platforms in HILS applications.
 *
 * It is desirable that the model/optimization interfaces can be easily interfaced
 * with python. Python is the intended language for scripting in JModelica and it is
 * therefore important that the generated code is straight forward to use with the
 * python extensions framework.
 *
 * The model/optimization interface is intended to be used by wide range of users,
 * with different backgrounds and programming skills. It is therefore desirable that
 * the interface is as simple and intuitive as possible.
 *
 * Given these motivations, it is reasonable to use pure C where possible, and to a
 * limited extent C++ where needed (e.g. in solver interfaces and in most likely in the
 * AD framework).
 *
 * It should also be possible to build shared libraries for models/optimization problems.
 * In this way, it is possible to build applications that contains several models.
 *
 */

#ifndef _JMI_H
#define _JMI_H

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


#endif
