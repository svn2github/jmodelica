/*
 * Design considerations
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
 *
 *      This interface describes a DAE on the form
 *
 *        F(ci,cd,pi,pd,dx,x,u,w,t) = 0
 *
 *      were
 *
 *        ci   independent constant
 *        cd   dependent constants
 *        pi   independent parameters
 *        pd   dependent parameters
 *
 *        dx    differentiated variables
 *        x     variables whos derivatives appear in the DAE
 *        u     inputs
 *        w     algebraic variables
 *        t     time
 *
 *	     This interface also contains a specification of a DAE initialization
 *	     system on the form
 *
 *	      F0(ci,cd,pi,pd,dx,x,u,w,t) = 0
 *	      F1(ci,cd,pi,pd,dx,x,u,w,t) = 0
 *
 *	    were
 *
 *	      ci   independent constant
 *	      cd   dependent constants
 *	      pi   independent parameters
 *	      pd   dependent parameters
 *
 * 	      dx    differentiated variables
 *	      x     variables whos derivatives appear in the DAE
 *	      u     inputs
 *	      w     algebraic variables
 *	      t0     time
 *
 *	 	F0 represents the DAE system augmented with additional initial equations
 *	 	and start values that are fixed. F1 on the other hand contains equations for
 *	 	initialization of variables for which the value given in the start attribute is
 *	 	not fixed.
 *
 *      Interface also contains the optimization-specific parts of an Optimica
 *      problem:
 *
 *       - A cost function:
 *
 *         J(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t) to minimize
 *
 *       - Equality path constraints:
 *
 *         Ceq(ci,cd,pi,pd,dx,x,u,w,t) = 0
 *
 *       - Inequality path constraints:
 *
 *         Cineq(ci,cd,pi,pd,dx,x,u,w,t) <= 0
 *
 *       - Equality point constraints:
 *
 *         Heq(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t_p) = 0
 *
 *       - Inequality point constraints:
 *
 *         Hineq(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t_p) <= 0
 *
 *      where dx_p, x_p, u_p, w_p and t_p denotes variables at
 *      certain points in time. This is used describe initial and
 *      terminal conditions, e.g. **This sematics needs to be specified.**
 *
 */

#ifndef _JMI_H
#define _JMI_H

#include <stdio.h>

// Forward declaration of Jmi struct
typedef struct Jmi Jmi;

// Constants for controlling derivative evaluation
static const int DER_PI_SPARSE = 1;
static const int DER_PD_SPARSE = 2;
static const int DER_DX_SPARSE = 4;
static const int DER_X_SPARSE = 8;
static const int DER_U_SPARSE = 16;
static const int DER_W_SPARSE = 32;

static const int DER_PI_SKIP = 1;
static const int DER_PD_SKIP = 2;
static const int DER_DX_SKIP = 4;
static const int DER_X_SKIP = 8;
static const int DER_U_SKIP = 16;
static const int DER_W_SKIP = 32;
static const int DER_T_SKIP = 64;

// Typedef for the doubles used in the interface.
typedef double Double_t;

// Function signatures

/**
 * Evaluation of the DAE residual.
 */
typedef int (*jmi_dae_F_t)(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		Double_t t, Double_t* res);

/**
 * Evaluation of the Jacobian of the DAE residual.
 *
 *   sparsity        This argument is a mask that selects wheather
 *                   sparse or dense evaluation of the Jacobian should
 *                   be used. The constants DER_NN_SPARSE are used to
 *                   specity this information for each of the vectors
 *                   pi, pd, dx, etc. If a sparse
 *                   representation is selected, the sparsity pattern in
 *                   mask is used. If sparsity=0, dense evaluation is assumed
 *                   and the mask argument is neglected. [Is this really a
 *                   good idea? This means that we need to deal with row vs
 *                   column orientation after all. This complication was avoided
 *                   by only working with the triplet formulation. It may be an
 *                   alternative to work only with sparse representation in the
 *                   interface but to include library-functions for unpacking.]
 *   skip            This arguments controls what input vectors are
 *                   assumed to be independent variables. The constants
 *                   DER_NN_SKIP are used to indicate that the Jacobian w.r.t.
 *                   a particular vector should not be evaluated.
 *   mask            This array has the same size as the number of column of the dense
 *                   Jacobian, and holds the value of 0 if the corresponding Jacobian
 *                   cloumn should not be computed. If the value of an entry in
 *                   mask i 1, then the correponding Jacobian colum will be evaluated.
 *                   The evaluated Jacobian columns are stored in the first
 *                   entries of the output argument jac.
 *
 *                   [We need to think about the caching issue in AD, where we would like
 *                   to store a tape for a particular combination of sparsity, skip and mask
 *                   arguments. Options:
 *
 *                    - Supply this information in the jmi_init function and store it in
 *                      the corresponding struct. In this case it would not be possible change
 *                      these values after initialization and they would not be arguments to
 *                      the derivative functions.
 *
 *                    - Introduce a newMask argument. If false, the cached data can be used,
 *                      otherwise new data structures are computed.
 *                   ]
 */
typedef int (*jmi_dae_jac_F_t)(Jmi* jmi, Double_t* ci, Double_t* cd,
		Double_t* pi, Double_t* pd,
		Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		Double_t t, int sparsity, int skip, int* mask, Double_t* jac);

/**
 * Returns the number of non-zeros in the DAE residual Jacobian.
 */
typedef int (*jmi_dae_jac_F_nnz_t)(Jmi* jmi, int* nnz);

/**
 * Returns the row and column indices of the non-zero elements in the DAE
 * residual Jacobian.
 */
typedef int (*jmi_dae_jac_F_nz_indices_t)(Jmi* jmi, int* row, int* col);

/*
jmi_dae_jac_F_nnz_t qwe(Jmi* jmi, int q2, int* nn, int q) {
	printf("%d",*nn);
	return 0;
}
 */

/**
 * Creates a new Jmi struct, for which a pointer is returned in the output argument jmi.
 * This function is assumed to be given in the generated code.
 */
int jmi_new(Jmi** jmi);

/**
 * Deallocates memory and deletes a Jmi struct.
 */
int jmi_delete(Jmi** jmi);

/**
 * Struct describing a DAE model including evaluation of the DAE residual and (optional) a symbolic
 * Jacobian. If the Jacobian is not evaluated, the corresponding function pointers are set to NULL.
 * [In the previous design the sparsity information was encoded as vectors directly in the struct,
 * but I think that functions are better since the design is then consistent with Jmi_dae_der.]
 */
typedef struct {
	jmi_dae_F_t F;
	int n_ci;
	int n_cd;
	int n_pi;
	int n_pd;
	int n_dx;
	int n_x;
	int n_u;
	int n_w;
	int n_eq_F;
	jmi_dae_jac_F_t jac_sd_F;
	jmi_dae_jac_F_nnz_t jac_sd_F_nnz;
	jmi_dae_jac_F_nz_indices_t jac_sd_F_nz_indices;
} Jmi_dae;

typedef struct {
	//..
} Jmi_init;

typedef struct {
	//..
} Jmi_opt;

/**
 * Struct containing functions for evaluation of the DAE Jacobian residual. The
 * function pointers in this struct may be set to point to generic differentiation
 * methods, such as e.g., automatic differentiation.
 */
typedef struct {
	jmi_dae_jac_F_t jac_F;
	jmi_dae_jac_F_nnz_t jac_F_nnz;
	jmi_dae_jac_F_nz_indices_t jac_F_nz_indices;
} Jmi_dae_der;

typedef struct {
	//...
} Jmi_init_der;

typedef struct{
	//...
} Jmi_opt_der;

/**
 * Jmi is the main struct in the Jmi interface. It contains pointers to structs of
 * types Jmi_dae, Jmi_init, and Jmi_opt. These pointers are set to structs of the corresponding
 * type in the jmi_init function that is implemented in the generated code. If a particular
 * problem does not contain all types of information, the corresponding pointers are set to
 * NULL. The pointers of type Jmi_dae_der, Jmi_init_der, and Jmi_opt_der are always set to
 * NULL in jmi_init. These pointers are instead assigned in library init functions that provides
 * particular implementations of differentiation methods. In this way, the Jmi struct can hold,
 * apart from potential symbolic derivatives, one additional derivative method.
 */
struct Jmi{
	Jmi_dae* jmi_dae;
	Jmi_init* jmi_init;
	Jmi_opt* jmi_opt;
	Jmi_dae_der* jmi_dae_der;
	Jmi_init_der* jmi_init_der;
	Jmi_opt_der* jmi_opt_der;
};

#endif
