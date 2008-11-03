// Example of generated function


#include <stdio.h>
#include <stdlib.h>
#include "jmi_low.h"


// Is it possible to use the function typedefs here to define the functions? 

// I think that it is actually a good idea to have this function
// instead of fields in the struct. All "sections" (dae, init, opt)
// are not allways used but the fields would always be present for 
// all section. Seems a bit fishy to have unused fields whos validity
// is checked by a NULL pointer condition for some function. Raises
// consistency issues of the struct.
int jmi_dae_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
		      int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq) {
  // generated code
  return 1;
}

static jmi_dae_F(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		 Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		 Double_t t, Double_t* res) {
  // Generated code
  return 1;
}

static int jmi_dae_sd_dF(Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
			 Double_t* dx, Double_t* x, Double_t* u,
			 Double_t* w, Double_t t, int mask, Double_t* jac) {
  // Generated code
  return 1;
}


// This is the init function
int jmi_low_init(Jmi_low* jmi_low) {
  jmi_low = (Jmi_low*)malloc(sizeof(Jmi_low));
  jmi_low->dae_get_sizes = &jmi_dae_get_sizes;
  jmi_low->dae_F = &jmi_dae_F;
  jmi_low->dae_sd_dF = &jmi_dae_sd_dF;
}

int jmi_low_delete(Jmi_low* jmi_low){
  free(jmi_low);
  return 1;
}


// This is the const struct. Mabye this is better, cleaner? 
// No dynamic memory allocation. This const struct should be in jmi_low.h
// but cannot make it work...
const Jmi_low jmi_low_struct = {&jmi_dae_get_sizes,
                 &jmi_dae_F,
                 &jmi_dae_sd_dF};
