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

#ifndef _JMI_OPT_H
#define _JMI_OPT_H
#include "jmi.h"

#if defined __cplusplus
        extern "C" {
#endif



int jmi_opt_get_sizes(int* n_Ceq, int* n_Cineq, int* n_Heq, int* n_Hineq);


int jmi_opt_J(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t* t, Double_t* J);

/**
 * Path equality constraints Ceq = 0.
 */
int jmi_opt_Ceq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t* t, Double_t* Ceq);

/**
 * Path inequality constraints Cineq <= 0.
 */
int jmi_opt_Cineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx, Double_t* x, Double_t* u,
              Double_t* w, Double_t* t, Double_t* Cineq);

/**
 * Point equality constraints Heq = 0.
 */
int jmi_opt_Heq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx_p, Double_t* x_p, Double_t* u_p,
              Double_t* w_p, Double_t* t_p, Double_t* Heq);

/**
 * Point inequality constraints Hineq <= 0.
 */
int jmi_opt_Hineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
              Double_t* dx_p, Double_t* x_p, Double_t* u_p,
              Double_t* w_p, Double_t* t_p, Double_t* Hineq);

#if defined __cplusplus
    }
#endif

#endif
