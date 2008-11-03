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


#ifndef _JMI_RUNTIME_H
#define _JMI_RUNTIME_H

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

static const int DAE_AVAIL = 1;
static const int DAE_SD_AVAIL = 2;
static const int INIT_AVAIL = 4;
static const int INIT_SD_AVAIL = 8;
static const int OPT_AVAIL = 16;
static const int OPT_SD_AVAIL = 32;

typedef struct Jmi Jmi;

struct Jmi {
	int (*query)(int* function_mask);

	int (*dae_get_sizes)(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
			int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq);
	int (*dae_F)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, Double_t* res);
	int (*dae_der_get_sizes)(int* n_jac_F, int mask);
	int (*dae_dF)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int der_method, int mask, Double_t* res);

	int (*init_get_sizes)(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
			int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq_F0, int* n_eq_F1);
	int (*init_F0)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, Double_t* res);
	int (*init_F1)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, Double_t* res);
	int (*init_der_get_sizes)(int* n_jac_f0, int* n_jac_F1, int mask);
	int (*init_dF0)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int der_method, int mask, Double_t* res);
	int (*init_dF1)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int der_method, int mask, Double_t* res);

	int (*opt_get_sizes)(int* n_Ceq, int* n_Cineq, int* n_Heq, int* n_Hineq);
	int (*opt_J)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t* t, Double_t* J);
	int (*opt_Ceq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t* t, Double_t* Ceq);
	int (*opt_Cineq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t* t, Double_t* Cineq);
	int (*opt_Heq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx_p, Double_t* x_p, Double_t* u_p,
			Double_t* w_p, Double_t* t_p, Double_t* Heq);
	int (*opt_Hineq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx_p, Double_t* x_p, Double_t* u_p,
			Double_t* w_p, Double_t* t_p, Double_t* Hineq);
	int (*opt_der_get_sizes)(int* n_jac_J, int* n_jac_Ceq, int* n_jac_Cineq,
			int* n_jac_Heq, int* n_jac_Hineq, int mask);
	int (*opt_dJ)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method, int mask, Double_t* jac);
	int (*opt_dCeq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method,  int mask, Double_t* jac);
	int (*opt_dCineq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method,  int mask, Double_t* jac);
	int (*opt_dHeq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method,  int mask, Double_t* jac);
	int (*opt_dHineq)(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			Double_t* dx, Double_t* x, Double_t* u,
			Double_t* w, Double_t t, int der_method,  int mask, Double_t* jac);

};

/**
 * Initializes a Jmi struct.
 */
 int jmi_init(Jmi* jmi, int der_method_mask);

/**
 * Deletess a Jmi struct.
 */
int jmi_delete(Jmi* jmi);



#endif
