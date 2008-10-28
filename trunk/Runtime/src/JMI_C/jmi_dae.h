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
 * Return sizes of model vectors.
 */
int jmi_dae_get_sizes(int* num_ci, int* num_cd, int* num_pi, int* num_pd,
                  int* num_dx, int* num_x, int* num_u, int* num_w);

/**
 *  Evaluations needed
 *
 *   - DAE residual: res = F(..)
 *

 */
int jmi_dae_F(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
          Double_t* dx, Double_t* x, Double_t* u, Double_t* w, 
          Double_t t, Double_t* res);
