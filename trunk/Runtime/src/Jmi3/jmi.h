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

#define JMI_DER_SPARSE 1
#define JMI_DER_DENSE_COL_MAJOR 2
#define JMI_DER_DENSE_ROW_MAJOR 4

#define JMI_DER_PI_SKIP 1
#define JMI_DER_PD_SKIP 2
#define JMI_DER_DX_SKIP 4
#define JMI_DER_X_SKIP 8
#define JMI_DER_U_SKIP 16
#define JMI_DER_W_SKIP 32
#define JMI_DER_T_SKIP 64

// TODO: Error codes...

// Typedef for the doubles used in the interface.
typedef double Jmi_Double_t;

// Function signatures

/**
 * Evaluation of the DAE residual.
 */
typedef int (*jmi_dae_F_t)(Jmi* jmi, Jmi_Double_t* ci, Jmi_Double_t* cd, Jmi_Double_t* pi, Jmi_Double_t* pd,
		Jmi_Double_t* dx, Jmi_Double_t* x, Jmi_Double_t* u, Jmi_Double_t* w,
		Jmi_Double_t t, Jmi_Double_t* res);

/**
 * Evaluation of the Jacobian of the DAE residual.
 *
 *   sparsity        This argument is a mask that selects wheather
 *                   sparse or dense evaluation of the Jacobian should
 *                   be used. The constants JMI_DER_SPARSE are used to
 *                   specity a sparse Jacobian, whereas JMI_DER_DENSE_COL_MAJOR
 *                   and JMI_DER_DENSE_ROW_MAJOR are used to specify dense
 *                   column major or row major Jacobians respectively.
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
 */
typedef int (*jmi_dae_jac_F_t)(Jmi* jmi, Jmi_Double_t* ci, Jmi_Double_t* cd,
		Jmi_Double_t* pi, Jmi_Double_t* pd,
		Jmi_Double_t* dx, Jmi_Double_t* x, Jmi_Double_t* u, Jmi_Double_t* w,
		Jmi_Double_t t, int sparsity, int skip, int* mask, Jmi_Double_t* jac);

/**
 * Returns the number of non-zeros in the DAE residual Jacobian.
 */
typedef int (*jmi_dae_jac_F_nnz_t)(Jmi* jmi, int* nnz);

/**
 * Returns the row and column indices of the non-zero elements in the DAE
 * residual Jacobian.
 */
typedef int (*jmi_dae_jac_F_nz_indices_t)(Jmi* jmi, int* row, int* col);

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
