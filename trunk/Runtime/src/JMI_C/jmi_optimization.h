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

int jmi_opt_get_sizes(int* nCeq, int* nCineq, int* nHeq, int* nCeq);


int jmi_J(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t* t, Double_t* J);

int jmi_Ceq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t* t, Double_t* Ceq);

int jmi_Cineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t* t, Double_t* Cineq);

int jmi_Heq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx_p, Double_t* x_p, Double_t* u_p, 
              Double_t* w_p, Double_t* t_p, Double_t* Heq);

int jmi_Hineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx_p, Double_t* x_p, Double_t* u_p, 
              Double_t* w_p, Double_t* t_p, Double_t* Hineq);

