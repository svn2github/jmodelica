#ifndef _JMI_H
#define _JMI_H

#include "jmi_runtime.h"

#if defined __cplusplus
        extern "C" {
#endif

    /**
     * Returns a mask encoding what parts of the interface is implemented.
     * Notice that all functions needs to be present. Functions that are not
     * used must be implemented as dummy functions.
     */
    int jmi_query(int* function_mask);

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

	/**
	 * Return sizes of DAE model vectors.
	 */
	 int jmi_dae_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
			 int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq);

	/**
	 * Evaluation of DAE residual.
	 */
	 int jmi_dae_F(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			 Double_t t, Double_t* res);

	 /**
	  * Evaluation of DAE Jacobian.
	  */
	 int jmi_dae_sd_dF(Jmi* dae, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u,
			 Double_t* w, Double_t t, int mask, Double_t* jac);


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
	  * Get sizes of dae initialization system.
	  */
	 int jmi_init_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
	                        int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq_F0, int* n_eq_F1);

	 /*
	  * Evaluate fixed part of initialization system.
	  */
	 int jmi_init_F0(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, Double_t* dx, Double_t* x,
	 		        Double_t* u, Double_t* w, Double_t t0, Double_t* res);
	 /**
	  * Evaluate non-fixed part of initialization system.
	  */
	 int jmi_init_F1(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, Double_t* dx, Double_t* x,
	 		        Double_t* u, Double_t* w, Double_t t0, Double_t* res);

	 /**
	  * Evaluate symbolic deriavive of initialization system F0.
	  */
	 int jmi_init_sd_dFO(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	         	      Double_t* dx, Double_t* x, Double_t* u,
	         	      Double_t* w, Double_t t, int mask, Double_t* jac);

	 /**
	  * Evaluate symbolic deriavive of initialization system F1.
	  */
	 int jmi_init_sd_dF1(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	         	      Double_t* dx, Double_t* x, Double_t* u,
	         	      Double_t* w, Double_t t, int mask, Double_t* jac);

	 /**
	  * Interface to the optimization-specific parts of an Optimica
	  * problem:
	  *
	  *  - A cost function:
	  *
	  *    J(ci,cd,pi,pd,dx,x,u,w,t) to minimize
	  *
	  *  - Equality path constraints:
	  *
	  *    Ceq(ci,cd,pi,pd,dx,x,u,w,t) = 0
	  *
	  *  - Inequality path constraints:
	  *
	  *    Cineq(ci,cd,pi,pd,dx,x,u,w,t) <= 0
	  *
	  *  - Equality point constraints:
	  *
	  *    Heq(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t_p) = 0
	  *
	  *  - Inequality point constraints:
	  *
	  *    Hineq(ci,cd,pi,pd,dx_p,x_p,u_p,w_p,t_p) <= 0
	  *
	  *  where dx_p, x_p, u_p, w_p and t_p denotes variables at
	  *  certain points in time. This is used describe initial and terminal conditions, e.g.
	  */

	 /**
	  * Get sizes of optimization problem.
	  */
	 int jmi_opt_get_sizes(int* n_Ceq, int* n_Cineq, int* n_Heq, int* n_Hineq);

	 /**
	  * Evaluate cost function
	  */
	 int jmi_opt_J(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	               Double_t* w, Double_t* t, Double_t* J);

	 /**
	  * Path equality constraints Ceq = 0.
	  */
	 int jmi_opt_Ceq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	               Double_t* w, Double_t* t, Double_t* Ceq);

	 /**
	  * Path inequality constraints Cineq <= 0.
	  */
	 int jmi_opt_Cineq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	               Double_t* w, Double_t* t, Double_t* Cineq);

	 /**
	  * Point equality constraints Heq = 0.
	  */
	 int jmi_opt_Heq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx_p, Double_t* x_p, Double_t* u_p,
	               Double_t* w_p, Double_t* t_p, Double_t* Heq);

	 /**
	  * Point inequality constraints Hineq <= 0.
	  */
	 int jmi_opt_Hineq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx_p, Double_t* x_p, Double_t* u_p,
	               Double_t* w_p, Double_t* t_p, Double_t* Hineq);

	 /**
	  * Derivative of cost function.
	  */
	 int jmi_opt_sd_dJ(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	 	      Double_t* w, Double_t t, int mask, Double_t* jac);

	 /**
	  * Jacobian of equality path constraints.
	  */
	 int jmi_opt_sd_dCeq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	 	      Double_t* w, Double_t t, int mask, Double_t* jac);

	 /**
	  * Jacobian of inequality path constraints.
	  */
	 int jmi_opt_sd_dCineq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	 	      Double_t* w, Double_t t, int mask, Double_t* jac);

	 /**
	  * Jacobian of equality point constraints.
	  */
	 int jmi_opt_sd_dHeq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	 	      Double_t* w, Double_t t, int mask, Double_t* jac);
	 /**
	  * Jacobian of inequality point constraints.
	  */
	 int jmi_opt_sd_dHineq(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
	               Double_t* dx, Double_t* x, Double_t* u,
	 	      Double_t* w, Double_t t, int mask, Double_t* jac);


#if defined __cplusplus
    }
#endif


#endif
