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
 * In the interface, all variable vectors are concatenated into one, which is denoted z.
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

#if defined __cplusplus
        extern "C" {
#endif

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


#if JMI_AD == None
	typedef void Jmi_AD;
	typedef double* Jmi_AD_var_vec;
	typedef double Jmi_AD_var;
	typedef void Jmi_AD_tape;
#elif JMI_AD == CppAD
	typedef std::vector< CppAD::AD<double> > Jmi_AD_var_vec;
	typedef CppAD::AD<double> Jmi_AD_var;
	typedef CppAD::ADFun<double> Jmi_AD_tape
	typedef struct {

	  Jmi_AD_vec *z_independent;
	  Jmi_AD_vec *F_z_dependent;

	  CppAD::ADFun<double> *F_z_tape;

	  bool tape_initialized;

	  int dF_n_nz_ad;
	  int* dF_irow_ad;
	  int* dF_icol_ad;

	  // Sparsity patterns for individual independent variables
	  // These variables are useful when computing the Jacobian
	  int dF_pi_n_nz_ad;
	  int* dF_pi_irow_ad;
	  int* dF_pi_icol_ad;

	  int dF_pd_n_nz_ad;
	  int* dF_pd_irow_ad;
	  int* dF_pd_icol_ad;

	  int dF_dx_n_nz_ad;
	  int* dF_dx_irow_ad;
	  int* dF_dx_icol_ad;

	  int dF_x_n_nz_ad;
	  int* dF_x_irow_ad;
	  int* dF_x_icol_ad;

	  int dF_u_n_nz_ad;
	  int* dF_u_irow_ad;
	  int* dF_u_icol_ad;

	  int dF_w_n_nz_ad;
	  int* dF_w_irow_ad;
	  int* dF_w_icol_ad;

	  int dF_t_n_nz_ad;
	  int* dF_t_irow_ad;
	  int* dF_t_icol_ad;

	} Jmi_dae_ad;

#else
	#error The directive JMI_AD must be set to 'None' or 'CppAD'
#endif

// Function signatures to be used in the generated code

/**
 * Evaluation of the DAE residual in the generated code.
 */
typedef int (*jmi_dae_F_t)(Jmi* jmi, Jmi_AD_var_vec res);


/**
 * Evaluation of symbolic jacobian in generated code.
 */
typedef int (*jmi_dae_dF_t)(Jmi* jmi, int sparsity, int skip, int* mask, Jmi_Double_t* jac);

/**
 * Returns the number of non-zeros in the DAE residual Jacobian.
 */
//typedef int (*jmi_dae_dF_nnz_t)(Jmi* jmi, int* nnz);

/**
 * Returns the row and column indices of the non-zero elements in the DAE
 * residual Jacobian.
 */
//typedef int (*jmi_dae_dF_nz_indices_t)(Jmi* jmi, int* row, int* col);


/**
 * Struct describing a DAE model including evaluation of the DAE residual and (optional) a symbolic
 * Jacobian. If the Jacobian is not evaluated, the corresponding function pointers are set to NULL.
 */
typedef struct {
	jmi_dae_F_t F;
	int dF_n_nz;
	int* dF_irow;
	int* dF_icol;
	Jmi_dae_ad* ad;
} Jmi_dae;

typedef struct {
	//..
} Jmi_init;

typedef struct {
	//..
} Jmi_opt;

/**
 * Jmi is the main struct in the Jmi interface. It contains pointers to structs of
 * types Jmi_dae, Jmi_init, and Jmi_opt. These pointers are set to structs of the corresponding
 * type in the jmi_init function that is implemented in the generated code. If a particular
 * problem does not contain all types of information, the corresponding pointers are set to
 * NULL.
 */
struct Jmi{
	Jmi_dae* dae;
	Jmi_init* init;
	Jmi_opt* opt;

	int n_ci;
	int n_cd;
	int n_pi;
	int n_pd;
	int n_dx;
	int n_x;
	int n_u;
	int n_w;
	// Offset variables in the z vector, for convenience.
	int offs_ci;
	int offs_cd;
	int offs_pi;
	int offs_pd;
	int offs_dx;
	int offs_u;
	int offs_w;
    int offs_t;

	int n_z; // the sum of all variables (including t), for convenience

	int n_eq_F;

	/* The z vector contains all variables in the order
	 * ci, cd, pi, pd, dx, x, u, w, t.
	 */
	Jmi_Double_t* z;

};


/*
 * ***************************************
 *
 *    Public interface
 *
 * ***************************************
 */

/**
 * Creates a new Jmi struct, for which a pointer is returned in the output argument jmi.
 * This function is assumed to be given in the generated code.
 */
 int jmi_new(Jmi** jmi);

 /**
  * Initializes the AD variables and tapes. Prior to this call, the variables in z should
  * be initialized.
  */
 int jmi_ad_init(Jmi* jmi);

/**
 * Deallocates memory and deletes a Jmi struct.
 */
 int jmi_delete(Jmi* jmi);

/**
 * Functions that gives access to the variable vectors.
 * Notice that these functions (and the variable vector)
 * is common for dae, init and opt.
 */
 int jmi_get_ci(Jmi* jmi, double** ci);
 int jmi_get_cd(Jmi* jmi, double** cd);
 int jmi_get_pi(Jmi* jmi, double** pi);
 int jmi_get_pd(Jmi* jmi, double** pd);
 int jmi_get_dx(Jmi* jmi, double** dx);
 int jmi_get_x(Jmi* jmi, double** x);
 int jmi_get_u(Jmi* jmi, double** u);
 int jmi_get_w(Jmi* jmi, double** w);
 int jmi_get_t(Jmi* jmi, double** t);

 /**
  * Evaluate DAE residual. The user sets the input variables by writing to
  * the vectors obtained from the functions jmi_dae_get_x, ...
  */
 int jmi_dae_F(Jmi* jmi, Jmi_Double_t* res);

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


 /**
  * Evaluate the symbolic Jacobian of the DAE residual function.
  */
 int jmi_dae_dF(Jmi* jmi, int sparsity, int skip, int* mask, Jmi_Double_t* jac);

 /**
  * Returns the number of non-zeros in the symbolic DAE residual Jacobian.
  */
 int jmi_dae_dF_nnz(Jmi* jmi, int* nnz);

 /**
  * Returns the row and column indices of the non-zero elements in the symbolic DAE
  * residual Jacobian.
  */
 int jmi_dae_dF_nz_indices(Jmi* jmi, int* row, int* col);

 /**
   * Evaluate the Jacobian of the DAE residual function by means of an automatic
   * differentiation algorithm.
   */
  int jmi_dae_dF_ad(Jmi* jmi, int sparsity, int skip, int* mask, Jmi_Double_t* jac);


  /**
   * Returns the number of non-zeros in the AD DAE residual Jacobian.
   */
  int jmi_dae_dF_nnz_ad(Jmi* jmi, int* nnz);

  /**
   * Returns the row and column indices of the non-zero elements in the AD DAE
   * residual Jacobian.
   */
  int jmi_dae_dF_nz_indices_ad(Jmi* jmi, int* row, int* col);


#if defined __cplusplus
    }
#endif



#endif
