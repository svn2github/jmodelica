// This is the implementation of the "external" interface
#include <stdlib.h>
#include "jmi.h"

static int jmi_dae_fd_dF(Jmi* jmi, Double_t* ci, Double_t* cd, 
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int mask, Double_t* res) {
  // Code for finite differences
  return 1;

}


static int jmi_dae_ad_dF(Jmi* jmi, Double_t* ci, Double_t* cd, 
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int mask, Double_t* res) {

  // Code for automatic differentiation
  return 1;

}

static int jmi_dae_dF(Jmi* jmi, Double_t* ci, Double_t* cd, 
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			Double_t t, int der_method, int mask, Double_t* res) {

  if (der_method & DER_SD) {
    if (((Jmi_low*)jmi)->dae_sd_dF != NULL) {
      return ((Jmi_low*)jmi)->dae_sd_dF(ci,cd,pi,pd,dx,x,u,w,t,mask,res);
    } else {
      return -1;
    } 
  } else if (der_method & DER_FD) {
    return jmi_dae_fd_dF(jmi,ci,cd,pi,pd,dx,x,u,w,t,mask,res);
  } else if (der_method & DER_AD) {
    return jmi_dae_ad_dF(jmi,ci,cd,pi,pd,dx,x,u,w,t,mask,res);
  }
  return -1;


}


// This is the init function
int jmi_init(Jmi* jmi) {
  jmi = (Jmi*)malloc(sizeof(Jmi));
  jmi_low_init(&(jmi->jmi_low));
  jmi->dae_dF = &jmi_dae_dF;
  return 1;
}

int jmi_delete(Jmi* jmi) {
   jmi_low_delete(&(jmi->jmi_low));
   free(jmi);
  return 1;
}

