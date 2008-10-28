/**
 * Interface to first derivatives of the dae residual
 *
 *   - Cost function Jacobian w.r.t. pd: jac = dFdpd
 *   - Cost function Jacobian w.r.t. pi: jac = dFdpi
 *   - Cost function Jacobian w.r.t. dx: jac = dFddx
 *   - Cost function Jacobian w.r.t. x: jac = dFdx
 *   - Cost function Jacobian w.r.t. u: jac = dFdu
 *   - Cost function Jacobian w.r.t. w: jac = dFdw
 *   - Cost function Jacobian w.r.t. t: jac = dFdt
 *
 *   Assume dense Jacobians for now.
 */



//PD=1
//PI=2
//PD|PI

int jmi_dae_ad_get_sizes(int* nJacJ, int* nJacCeq, int* nJacCineq, int* nJacHeq, int* nJacCeq, int mask);

int jmi_dae_ad_dJ(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_dae_ad_dCeq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_dae_ad_dCineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_dae_ad_dHeq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
	      Double_t* w, Double_t t, int mask, Double_t* jac);

int jmi_dae_ad_dHineq(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
	      Double_t* w, Double_t t, int mask, Double_t* jac);



//if (mask & PD)

int jmi_dae_ad_dJdpd(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);

int jmi_dae_ad_dJdpi(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);

int jmi_dae_ad_dJddx(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);

int jmi_dae_ad_dJdx(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);

int jmi_dae_ad_dJdu(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);

int jmi_dae_ad_dJdw(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);

int jmi_dae_ad_dJdt(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd, 
              Double_t* dx, Double_t* x, Double_t* u, 
              Double_t* w, Double_t t, Double_t* jac);


