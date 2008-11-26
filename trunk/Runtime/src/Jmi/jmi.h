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
 * In the interface, all variable vectors, and t, are concatenated into one, which is denoted z.
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

#define JMI_DER_SPARSE 1
#define JMI_DER_DENSE_COL_MAJOR 2
#define JMI_DER_DENSE_ROW_MAJOR 4

#define JMI_DER_NO_SKIP 0
#define JMI_DER_CI_SKIP 1
#define JMI_DER_CD_SKIP 2
#define JMI_DER_PI_SKIP 4
#define JMI_DER_PD_SKIP 8
#define JMI_DER_DX_SKIP 16
#define JMI_DER_X_SKIP 32
#define JMI_DER_U_SKIP 64
#define JMI_DER_W_SKIP 128
#define JMI_DER_T_SKIP 256

#define JMI_AD_NONE 0
#define JMI_AD_CPPAD 1

/*
 *  TODO: Error codes...
 *  Introduce #defines to denote different error codes
 */

#include <stdio.h>
#include <stdlib.h>

#if JMI_AD == JMI_AD_CPPAD
// This must be done outside of 'extern "C"'
#include <cppad/cppad.hpp>
#include <vector>
#endif

#if defined __cplusplus
extern "C" {
#endif

// Forward declaration of jmi struct
typedef struct jmi_t jmi_t;

// Typedef for the doubles used in the interface.
typedef double jmi_real_t;

// This section defines types in the case of no AD and 
// in the case of CppAD.
#if JMI_AD == JMI_AD_NONE
  typedef jmi_real_t jmi_ad_var_t;
  typedef jmi_real_t *jmi_real_vec_t;
  typedef jmi_real_vec_t *jmi_real_vec_p;
  typedef jmi_real_t *jmi_ad_var_vec_t;
  typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;
  typedef void jmi_ad_tape_t;
  typedef jmi_ad_tape_t *jmi_ad_tape_p;
  typedef void jmi_dae_ad_t;
#elif JMI_AD == JMI_AD_CPPAD
  typedef CppAD::AD<jmi_real_t> jmi_ad_var_t;
  typedef std::vector<jmi_real_t> jmi_real_vec_t;
  typedef jmi_real_vec_t *jmi_real_vec_p;
  typedef std::vector< jmi_ad_var_t > jmi_ad_var_vec_t;
  typedef jmi_ad_var_vec_t *jmi_ad_var_vec_p;
  typedef CppAD::ADFun<jmi_real_t> jmi_ad_tape_t;
  typedef jmi_ad_tape_t *jmi_ad_tape_p;

  typedef struct {

    jmi_ad_var_vec_p F_z_dependent;

    jmi_ad_tape_p F_z_tape;

    int tape_initialized;

    int dF_z_n_nz;
    int* dF_z_irow;
    int* dF_z_icol;

    // Sparsity patterns for individual independent variables
    // These variables are useful when computing the Jacobian.
    int dF_ci_n_nz;
    int* dF_ci_irow;
    int* dF_ci_icol;

    int dF_cd_n_nz;
    int* dF_cd_irow;
    int* dF_cd_icol;

    int dF_pi_n_nz;
    int* dF_pi_irow;
    int* dF_pi_icol;

    int dF_pd_n_nz;
    int* dF_pd_irow;
    int* dF_pd_icol;

    int dF_dx_n_nz;
    int* dF_dx_irow;
    int* dF_dx_icol;

    int dF_x_n_nz;
    int* dF_x_irow;
    int* dF_x_icol;

    int dF_u_n_nz;
    int* dF_u_irow;
    int* dF_u_icol;

    int dF_w_n_nz;
    int* dF_w_irow;
    int* dF_w_icol;

    int dF_t_n_nz;
    int* dF_t_irow;
    int* dF_t_icol;

  } jmi_dae_ad_t;

#else
#error "The directive JMI_AD_NONE or JMI_AD_CPPAD must be set"
#endif

  // Function signatures to be used in the generated code

  /**
   * Evaluation of the DAE residual in the generated code.
   */
  typedef int (*jmi_dae_F_t)(jmi_t* jmi, jmi_ad_var_vec_p res);

  /**
   * Evaluation of symbolic jacobian in generated code.
   */
  typedef int (*jmi_dae_dF_t)(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac);

  /**
   * Struct describing a DAE model including evaluation of the DAE residual and (optional) a symbolic
   * Jacobian. If the Jacobian is not provided, the corresponding function pointers are set to NULL.
   */
  typedef struct {
    jmi_dae_F_t F;
    jmi_dae_dF_t dF;
    int n_eq_F;
    int dF_n_nz;
    int* dF_irow;
    int* dF_icol;
    jmi_dae_ad_t* ad;
  } jmi_dae_t;

  typedef struct {
    //..
  } jmi_init_t;

  typedef struct {
    //..
  } jmi_opt_t;

  /**
   * jmi is the main struct in the jmi interface. It contains pointers to structs of
   * types jmi_dae, jmi_init, and jmi_opt. The creation of a jmi_t struct proceeds in three
   * steps. First, a raw struct is created by the function jmi_init. Then the jmi_dae_t,
   * jmi_init_t, and jmi_opt_t structs are initialized by the functions jmi_dae_init,
   * jmi_init_init, and jmi_opt_init respectively. Finlly, the the jmi_xxx_ad_t structs are
   * are set up in the function call jmi_ad_init. Notice that the variables should have been
   * initialized prior to the call to jmi_ad_init.
   * 
   * Typically, jmi_init and jmi_xxx_init functions are called from within the jmi_new function
   * that is provided by the generated code. The function jmi_ad_init is then called from the
   * user code after the variable vectors has been initialized.
   */
  struct jmi_t{
    jmi_dae_t* dae;
    jmi_init_t* init;
    jmi_opt_t* opt;

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
    int offs_x;
    int offs_u;
    int offs_w;
    int offs_t;

    int n_z; // the sum of all variables vector sizes (including t), for convenience

    /* The z vector contains all variables in the order
     * ci, cd, pi, pd, dx, x, u, w, t.
     */
    // This vector contains active AD objects in case of AD
    jmi_ad_var_vec_p z;
    // This vector contains the actual values
    jmi_real_vec_p z_val;

  };


  /*
   * ***************************************
   *
   *    Public interface
   *
   * ***************************************
   */

  /**
   * Creates a new jmi struct, for which a pointer is returned in the output argument jmi.
   * This function is assumed to be given in the generated code.
   */
  int jmi_new(jmi_t** jmi);


  /**
   * Allocates memory and sets up the jmi_t struct. This function is typically called
   * from within jmi_new in the generated code. The reason for introducing this function
   * is that the allocation of the jmi_t struct should not be repeated in the generated code.
   */
  int jmi_init(jmi_t** jmi, int n_ci, int n_cd, int n_pi, int n_pd, int n_dx,
	       int n_x, int n_u, int n_w);

  /**
   * Allocates a jmi_dae_t struct.
   */
  int jmi_dae_init(jmi_t* jmi, jmi_dae_F_t jmi_dae_F, int n_eq_F, jmi_dae_dF_t jmi_dae_dF,
		   int dF_n_nz, int* irow, int* icol);

  //int jmi_init_init(..)

  //int jmi_opt_init(..)

  /**
   * Initializes the AD variables and tapes. Prior to this call, the variables in z should
   * be initialized, which is also the reason why this function must be provided for
   * the user to call after the actual creation of the jmi_t struct.
   */
  int jmi_ad_init(jmi_t* jmi);

  /**
   * Deallocates memory and deletes a jmi struct.
   */
  int jmi_delete(jmi_t* jmi);

  /**
   * Functions that gives access to the variable vectors.
   * Notice that these functions (and the variable vector)
   * is common for dae, init and opt.
   */
  int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci);
  int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd);
  int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi);
  int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd);
  int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx);
  int jmi_get_x(jmi_t* jmi, jmi_real_t** x);
  int jmi_get_u(jmi_t* jmi, jmi_real_t** u);
  int jmi_get_w(jmi_t* jmi, jmi_real_t** w);
  int jmi_get_t(jmi_t* jmi, jmi_real_t** t);

  /**
   * Evaluate DAE residual. The user sets the input variables by writing to
   * the vectors obtained from the functions jmi_dae_get_x, ...
   */
  int jmi_dae_F(jmi_t* jmi, jmi_real_t* res);

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
   *  TODO: It may be interesting to include an additional layer that enables
   *  support for partially defined Jacobians. This would be beneficial if symbolic
   *  expressions for the Jacobian is available for some entries, but for other
   *  an AD algorithm is to be used.
   */


  /**
   * Evaluate the symbolic Jacobian of the DAE residual function.
   */
  int jmi_dae_dF(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac);

  /**
   * Returns the number of non-zeros in the symbolic DAE residual Jacobian.
   */
  int jmi_dae_dF_n_nz(jmi_t* jmi, int* n_nz);

  /**
   * Returns the row and column indices of the non-zero elements in the symbolic DAE
   * residual Jacobian.
   */
  int jmi_dae_dF_nz_indices(jmi_t* jmi, int* row, int* col);


  /**
   * This helper function computes the number of columns and the number of non zero
   * elements in the jacobian given a sparsity configuration. Symbolic Jacobian.
   */
  int jmi_dae_dF_dim(jmi_t* jmi, int sparsity, int skip, int *mask,
		             int *dF_n_cols, int *dF_n_nz);

  /**
   * Evaluate the Jacobian of the DAE residual function by means of an automatic
   * differentiation algorithm.
   */
  int jmi_dae_dF_ad(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac);


  /**
   * Returns the number of non-zeros in the AD DAE residual Jacobian.
   */
  int jmi_dae_dF_n_nz_ad(jmi_t* jmi, int* n_nz);

  /**
   * Returns the row and column indices of the non-zero elements in the AD DAE
   * residual Jacobian.
   */
  int jmi_dae_dF_nz_indices_ad(jmi_t* jmi, int* row, int* col);

  /**
   * Same as jmi_dae_dF_dim, but for AD Jacobian.
   */
  int jmi_dae_dF_dim_ad(jmi_t* jmi, int sparsity, int skip, int *mask,
		                int *dF_n_cols, int *dF_n_nz);

#if defined __cplusplus
}
#endif

#endif
