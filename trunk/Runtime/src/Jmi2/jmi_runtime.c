#include <stdio.h>

#include "jmi_internal.h"
#include "jmi_runtime.h"
#include "jmi.h"

int jmi_init(Jmi* jmi, int der_method_mask) {
	Jmi_internal* jmi_int = (Jmi_internal*)malloc(sizeof(Jmi_internal));
	Jmi* jmi_ext = &(jmi_int->jmi);

	// Assign function pointers to external Jmi struct
	jmi_ext->query = jmi_query;

	int f_mask;
	jmi_query(&f_mask);

	if (f_mask & DAE_AVAIL) {
		jmi_ext->dae_get_sizes = jmi_dae_get_sizes;
		jmi_ext->dae_F = jmi_dae_F;
		jmi_ext->dae_der_get_sizes = jmi_dae_der_get_sizes;
		jmi_ext->dae_dF = jmi_dae_dF;
	} else {
		jmi_ext->dae_get_sizes = NULL;
		jmi_ext->dae_F = NULL;
		jmi_ext->dae_der_get_sizes = NULL;
		jmi_ext->dae_dF = NULL;
	}

	if (f_mask & INIT_AVAIL) {
		jmi_ext->init_get_sizes = jmi_init_get_sizes;
		jmi_ext->init_F0 = jmi_init_F0;
		jmi_ext->init_F1 = jmi_init_F1;
		jmi_ext->init_der_get_sizes = jmi_init_der_get_sizes;
		jmi_ext->init_dF0 = jmi_init_dF0;
		jmi_ext->init_dF1 = jmi_init_dF1;
	} else {
		jmi_ext->init_get_sizes = NULL;
		jmi_ext->init_F0 = NULL;
		jmi_ext->init_F1 = NULL;
		jmi_ext->init_der_get_sizes = NULL;
		jmi_ext->init_dF0 = NULL;
		jmi_ext->init_dF1 = NULL;
	}

	if (f_mask & OPT_AVAIL) {
		jmi_ext->opt_get_sizes = jmi_opt_get_sizes;
		jmi_ext->opt_J = jmi_opt_J;
		jmi_ext->opt_Ceq = jmi_opt_Ceq;
		jmi_ext->opt_Cineq = jmi_opt_Cineq;
		jmi_ext->opt_Heq = jmi_opt_Heq;
		jmi_ext->opt_Hineq = jmi_opt_Hineq;
		jmi_ext->opt_der_get_sizes = jmi_opt_der_get_sizes;
		jmi_ext->opt_dJ = jmi_opt_dJ;
		jmi_ext->opt_dCeq = jmi_opt_dCeq;
		jmi_ext->opt_dCineq = jmi_opt_dCineq;
		jmi_ext->opt_dHeq = jmi_opt_dHeq;
		jmi_ext->opt_dHineq = jmi_opt_dHineq;
	} else {
		jmi_ext->opt_get_sizes = NULL;
		jmi_ext->opt_J = NULL;
		jmi_ext->opt_Ceq = NULL;
		jmi_ext->opt_Cineq = NULL;
		jmi_ext->opt_Heq = NULL;
		jmi_ext->opt_Hineq = NULL;
		jmi_ext->opt_der_get_sizes = NULL;
		jmi_ext->opt_dJ = NULL;
		jmi_ext->opt_dCeq = NULL;
		jmi_ext->opt_dCineq = NULL;
		jmi_ext->opt_dHeq = NULL;
		jmi_ext->opt_dHineq = NULL;
	}

	jmi = (Jmi*)jmi_int;

	return 1;
}

int jmi_delete(Jmi* jmi) {


	return 1;
}

int jmi_query(int* function_mask){


	return 1;
}


