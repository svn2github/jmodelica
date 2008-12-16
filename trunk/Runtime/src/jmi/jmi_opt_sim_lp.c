#include "jmi_opt_sim.h"


static int lp_radau_get_dimensions(jmi_opt_sim_t *jmi_opt_sim, int *n_x, int *n_g, int *n_h,
		int *dg_n_nz, int *dh_n_nz) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	return 0;
}


static int lp_radau_f(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *f) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	return 0;
}

static int lp_radau_df(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *df) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	return 0;
}

static int lp_radau_h(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	return 0;
}

static int lp_radau_dh(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	return 0;
}

static int lp_radau_g(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	return 0;
}

static int lp_radau_dg(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	return 0;
}

static int lp_radau_h_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *colIndex, int *rowIndex) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	return 0;
}

static int lp_radau_g_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *colIndex, int *rowIndex) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	return 0;
}

int jmi_opt_sim_lp_radau_new(jmi_opt_sim_t **jmi_opt_sim, jmi_t *jmi, int n_e,
        jmi_real_t *hs, int hs_free,
        jmi_real_t *pi_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
        jmi_real_t *u_lb, jmi_real_t *w_lb, jmi_real_t t0_lb,
        jmi_real_t tf_lb, jmi_real_t *hs_lb,
        jmi_real_t *pi_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
        jmi_real_t *u_ub, jmi_real_t *w_ub, jmi_real_t t0_ub,
        jmi_real_t tf_ub, jmi_real_t *hs_ub,
        int n_cp) {

	if (jmi->opt == NULL) {
		return -1;
	}

	int i, j;

	jmi_opt_sim_lp_radau_t* opt = (jmi_opt_sim_lp_radau_t*)calloc(1,sizeof(jmi_opt_sim_lp_radau_t));
	*jmi_opt_sim = (jmi_opt_sim_t*)opt;

	// Compute Radau points and Lagrange polynomials

	// Compute vector sizes
    (*jmi_opt_sim)->n_x = jmi->opt->n_p_opt +                                   // Number of parameters to be optimized
                          (2*jmi->n_x + jmi->n_u + jmi->n_w)*(n_e*n_cp + 1) +   // Collocation variables + initial variables
                          (2*jmi->n_x + jmi->n_u + jmi->n_w)*jmi->n_tp;         // Pointwise values

    // Free element lengths
    if (hs_free == 1) {
    	(*jmi_opt_sim)->n_x += n_e;
    }

    // Free start time
    if (jmi->opt->start_time_free == 1) {
    	(*jmi_opt_sim)->n_x += 1;
    }

    // Free final time
    if (jmi->opt->final_time_free == 1) {
    	(*jmi_opt_sim)->n_x += 1;
    }

    // Number of equality constraints
    (*jmi_opt_sim)->n_h = (2*jmi->n_x + jmi->n_w)*(n_e*n_cp + 1) +             // Collocation equations + initial equations
                          (2*jmi->n_x  + jmi->n_u + jmi->n_w)*jmi->n_tp +      // Pointwise equations
                          jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1) +               // Path constraints from optimization
                          jmi->opt->Heq->n_eq_F*jmi->n_tp;                // Point constraints from optimization

    // Free element lengths:
    // Add constraint sum(hs) = 1
    if (hs_free == 1) {
    	(*jmi_opt_sim)->n_h += 1;
    }

    // Number of inequality constraints
    (*jmi_opt_sim)->n_g = jmi->opt->Cineq->n_eq_F*(n_e*n_cp + 1) +               // Path inconstraints from optimization
                          jmi->opt->Hineq->n_eq_F*jmi->n_tp;                    // Point inconstraints from optimization

	// Allocate vectors
	(*jmi_opt_sim)->hs = (jmi_real_t*)calloc(n_e,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x_lb = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x_ub = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x_init = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));

	// Set the bounds vector
    for (i=0;i<jmi->opt->n_p_opt;i++) {
    	(*jmi_opt_sim)->x_lb[i] = pi_lb[i];
    	(*jmi_opt_sim)->x_ub[i] = pi_ub[i];
    }

    for (i=0;i<(n_e*n_cp + 1);i++) {
    	for (j=0;j<jmi->n_dx;j++) {
        	(*jmi_opt_sim)->x_lb[jmi->opt->n_p_opt + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_lb[j];
        	(*jmi_opt_sim)->x_ub[jmi->opt->n_p_opt + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_ub[j];
    	}

    	for (j=0;j<jmi->n_x;j++) {
        	(*jmi_opt_sim)->x_lb[jmi->opt->n_p_opt + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_lb[j];
        	(*jmi_opt_sim)->x_ub[jmi->opt->n_p_opt + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_ub[j];
    	}

    	for (j=0;j<jmi->n_u;j++) {
        	(*jmi_opt_sim)->x_lb[jmi->opt->n_p_opt + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_lb[j];
        	(*jmi_opt_sim)->x_ub[jmi->opt->n_p_opt + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_ub[j];
    	}

    	for (j=0;j<jmi->n_w;j++) {
        	(*jmi_opt_sim)->x_lb[jmi->opt->n_p_opt + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_lb[j];
        	(*jmi_opt_sim)->x_ub[jmi->opt->n_p_opt + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_ub[j];
    	}

    }

	// Set mesh
    (*jmi_opt_sim)->n_e = n_e;
    for (i=0;i<n_e;i++) {
    	(*jmi_opt_sim)->hs[i] = hs[i];
    }

	//Set function pointers
    (*jmi_opt_sim)->jmi = jmi;
    (*jmi_opt_sim)->get_dimensions = *lp_radau_get_dimensions;
	(*jmi_opt_sim)->get_interval_spec = *jmi_opt_sim_get_interval_spec;
	(*jmi_opt_sim)->f = *lp_radau_f;
	(*jmi_opt_sim)->df = *lp_radau_df;
	(*jmi_opt_sim)->h = *lp_radau_h;
	(*jmi_opt_sim)->dh = *lp_radau_dh;
	(*jmi_opt_sim)->g = *lp_radau_g;
	(*jmi_opt_sim)->dg = *lp_radau_dg;
	(*jmi_opt_sim)->get_bounds = *jmi_opt_sim_get_bounds;
	(*jmi_opt_sim)->get_initial = *jmi_opt_sim_get_initial;
	(*jmi_opt_sim)->h_nz_indices = *lp_radau_h_nz_indices;
	(*jmi_opt_sim)->g_nz_indices = *lp_radau_g_nz_indices;

//	(*jmi_opt_sim)->g_nz_indices = *lp_radau_g_nz_indices;
	return 0;
}

int jmi_opt_sim_lp_radau_delete(jmi_opt_sim_t *jmi_opt_sim) {

	return 0;
}
