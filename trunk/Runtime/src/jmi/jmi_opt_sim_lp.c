#include "jmi_opt_sim.h"
#include "jmi_opt_sim_lp.h"


static int lp_radau_f(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *f) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	*f = (jmi_opt_sim->x[0]-2)*(jmi_opt_sim->x[0]-2) + 3;

	return 0;
}

static int lp_radau_df(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *df) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	df[0] = 2*jmi_opt_sim->x[0];

	return 0;
}

static int lp_radau_g(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
    res[0] = 3-jmi_opt_sim->x[0];
	return 0;
}

static int lp_radau_dg(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
    jac[0] = -1;
	return 0;
}


static int lp_radau_dg_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	irow[0] = 1;
	icol[0] = 1;
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

static int lp_radau_dh_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol) {
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
        int n_cp, int der_eval_alg) {

	if (jmi->opt == NULL) {
		return -1;
	}

	int i, j;

	jmi_opt_sim_lp_radau_t* opt = (jmi_opt_sim_lp_radau_t*)calloc(1,sizeof(jmi_opt_sim_lp_radau_t));
	*jmi_opt_sim = (jmi_opt_sim_t*)opt;

	opt->der_eval_alg = der_eval_alg;

	// Compute Radau points and Lagrange polynomials
	opt->n_cp = n_cp;
	opt->cp = (jmi_real_t*)calloc(n_cp,sizeof(jmi_real_t));
	opt->cpp = (jmi_real_t*)calloc(n_cp+1,sizeof(jmi_real_t));
	opt->Lp_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*n_cp*n_cp);
	opt->Lpp_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*(n_cp+1)*(n_cp+1));
	opt->Lp_dot_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*n_cp*n_cp);
	opt->Lpp_dot_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*(n_cp+1)*(n_cp+1));
	opt->Lp_dot_vals = (jmi_real_t*)malloc(sizeof(jmi_real_t)*n_cp*n_cp);
	opt->Lpp_dot_vals = (jmi_real_t*)malloc(sizeof(jmi_real_t)*(n_cp+1)*(n_cp+1));

    jmi_opt_sim_lp_radau_get_pols(n_cp, opt->cp, opt->cpp, opt->Lp_coeffs,
    		opt->Lpp_coeffs, opt->Lp_dot_coeffs,
    		opt->Lpp_dot_coeffs, opt->Lp_dot_vals, opt->Lpp_dot_vals);


    /*
    // Print Lagrange polynomials
	printf("cp = {");
    for (i=0;i<n_cp;i++) {
    	printf("%4.16e",opt->cp[i]);
    	if (i<n_cp-1) {
        	printf(", ");
    	}
    }
    printf("}\n\n");

	printf("cpp = {");
    for (i=0;i<n_cp+1;i++) {
    	printf("%4.16e",opt->cpp[i]);
    	if (i<n_cp+1) {
        	printf(", ");
    	}
    }
    printf("}\n\n");

	printf("Lp_coeffs = {");
    for (i=0;i<n_cp;i++) {
    	printf("{");
    	for (j=0;j<n_cp;j++) {
    		printf("%4.16e",opt->Lp_coeffs[j*n_cp + i]);
    		if (j<n_cp-1) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<n_cp-1) {
			printf(",\n");
		}
    }
    printf("}\n\n");


	printf("Lp_dot_coeffs = {");
    for (i=0;i<n_cp;i++) {
    	printf("{");
    	for (j=0;j<n_cp;j++) {
    		printf("%4.16e",opt->Lp_dot_coeffs[j*n_cp + i]);
    		if (j<n_cp-1) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<n_cp-1) {
			printf(",\n");
		}
    }
    printf("}\n\n");

	printf("Lp_dot_vals = {");
    for (i=0;i<n_cp;i++) {
    	printf("{");
    	for (j=0;j<n_cp;j++) {
    		printf("%4.16e",opt->Lp_dot_vals[j*n_cp + i]);
    		if (j<n_cp-1) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<n_cp-1) {
			printf(",\n");
		}
    }
    printf("}\n\n");

	printf("Lpp_coeffs = {");
    for (i=0;i<n_cp+1;i++) {
    	printf("{");
    	for (j=0;j<n_cp+1;j++) {
    		printf("%4.16e",opt->Lpp_coeffs[j*(n_cp+1) + i]);
    		if (j<n_cp) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<n_cp) {
			printf(",\n");
		}
    }
    printf("}\n\n");


	printf("Lpp_dot_coeffs = {");
    for (i=0;i<n_cp+1;i++) {
    	printf("{");
    	for (j=0;j<n_cp+1;j++) {
    		printf("%4.16e",opt->Lpp_dot_coeffs[j*(n_cp+1) + i]);
    		if (j<n_cp) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<n_cp) {
			printf(",\n");
		}
    }
    printf("}\n\n");

	printf("Lpp_dot_vals = {");
    for (i=0;i<n_cp+1;i++) {
    	printf("{");
    	for (j=0;j<n_cp+1;j++) {
    		printf("%4.16e",opt->Lpp_dot_vals[j*(n_cp+1) + i]);
    		if (j<n_cp) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<n_cp) {
			printf(",\n");
		}
    }
    printf("}\n\n");

    */

	// Compute vector sizes
/*
    (*jmi_opt_sim)->n_x = jmi->opt->n_p_opt +                                   // Number of parameters to be optimized
                          (2*jmi->n_x + jmi->n_u + jmi->n_w)*(n_e*n_cp + 1) +   // Collocation variables + initial variables
                          jmi->n_x*n_e +                                        // States at element junctions
                          (2*jmi->n_x + jmi->n_u + jmi->n_w)*jmi->n_tp;         // Pointwise values
*/
    (*jmi_opt_sim)->n_x = 1;

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
/*
    (*jmi_opt_sim)->n_h = (2*jmi->n_x + jmi->n_w)*(n_e*n_cp + 1) +             // Collocation equations + initial equations
                          (2*jmi->n_x  + jmi->n_u + jmi->n_w)*jmi->n_tp +      // Pointwise equations
                          jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1) +               // Path constraints from optimization
                          jmi->opt->Heq->n_eq_F*jmi->n_tp;                // Point constraints from optimization
*/
    (*jmi_opt_sim)->n_h = 0;

    // if free element lengths:
    // TODO: should be modeled explicitly in the Optimica code?
    // Add constraint sum(hs) = 1
    if (hs_free == 1) {
    	(*jmi_opt_sim)->n_h += 1;
    }

    // Number of inequality constraints
    /*
    (*jmi_opt_sim)->n_g = jmi->opt->Cineq->n_eq_F*(n_e*n_cp + 1) +               // Path inconstraints from optimization
                          jmi->opt->Hineq->n_eq_F*jmi->n_tp;                    // Point inconstraints from optimization
*/
    (*jmi_opt_sim)->n_g = 1;

	// Allocate vectors
	(*jmi_opt_sim)->hs = (jmi_real_t*)calloc(n_e,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x_lb = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x_ub = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));
	(*jmi_opt_sim)->x_init = (jmi_real_t*)calloc((*jmi_opt_sim)->n_x,sizeof(jmi_real_t));

	// TODO: Dummy initialization - needs to be replaced
	(*jmi_opt_sim)->dg_n_nz = ((*jmi_opt_sim)->n_g)*((*jmi_opt_sim)->n_x);
	(*jmi_opt_sim)->dh_n_nz = ((*jmi_opt_sim)->n_h)*((*jmi_opt_sim)->n_x);

	(*jmi_opt_sim)->dg_row = (int*)calloc((*jmi_opt_sim)->dg_n_nz,sizeof(int));
	(*jmi_opt_sim)->dg_col = (int*)calloc((*jmi_opt_sim)->dg_n_nz,sizeof(int));
	(*jmi_opt_sim)->dh_row = (int*)calloc((*jmi_opt_sim)->dh_n_nz,sizeof(int));
	(*jmi_opt_sim)->dh_col = (int*)calloc((*jmi_opt_sim)->dh_n_nz,sizeof(int));

	// Set the bounds vector
/*
	// Bounds for optimization parameters
	int offs = 0;
	for (i=0;i<jmi->opt->n_p_opt;i++) {
    	(*jmi_opt_sim)->x_lb[i] = pi_lb[i];
    	(*jmi_opt_sim)->x_ub[i] = pi_ub[i];
    }
	offs += jmi->opt->n_p_opt;

    // Bounds for initial point and collocation points
    for (i=0;i<(n_e*n_cp + 1);i++) {
    	for (j=0;j<jmi->n_dx;j++) {
        	(*jmi_opt_sim)->x_lb[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_ub[j];
    	}

    	for (j=0;j<jmi->n_x;j++) {
        	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_ub[j];
    	}

    	for (j=0;j<jmi->n_u;j++) {
        	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_ub[j];
    	}

    	for (j=0;j<jmi->n_w;j++) {
        	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_ub[j];
    	}

    }
    offs += (n_e*n_cp + 1)*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w);

    // Bounds for the x variables at element junctions
    for (i=0;i<n_e;i++) {
    	for (j=0;j<jmi->n_x;j++) {
        	(*jmi_opt_sim)->x_lb[offs + (jmi->n_x)*i + j] = x_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + (jmi->n_x)*i + j] = x_ub[j];
    	}
    }
    offs += n_e*jmi->n_x;

    // Bounds for the element length variables (if free)
    if (hs_free == 1) {
    	for (i=0;i<n_e;i++) {
        	(*jmi_opt_sim)->x_lb[offs + i] = hs_lb[i];
        	(*jmi_opt_sim)->x_ub[offs + i] = hs_ub[i];
    	}
    }
    offs += n_e;

    // Bounds for interval end points (if free)
    if (jmi->opt->start_time_free == 1) {
    	(*jmi_opt_sim)->x_lb[offs] = t0_lb;
    	(*jmi_opt_sim)->x_ub[offs] = t0_ub;
     }
    offs += 1;

    if (jmi->opt->final_time_free == 1) {
     	(*jmi_opt_sim)->x_lb[offs] = tf_lb;
     	(*jmi_opt_sim)->x_ub[offs] = tf_ub;
      }
     offs += 1;

	// Set mesh
    (*jmi_opt_sim)->n_e = n_e;
    for (i=0;i<n_e;i++) {
    	(*jmi_opt_sim)->hs[i] = hs[i];
    }
*/

	(*jmi_opt_sim)->x_lb[0] = -10;
	(*jmi_opt_sim)->x_ub[0] = 10;

	//Set function pointers
    (*jmi_opt_sim)->jmi = jmi;
    (*jmi_opt_sim)->get_dimensions = *jmi_opt_sim_get_dimensions;
	(*jmi_opt_sim)->get_interval_spec = *jmi_opt_sim_get_interval_spec;
	(*jmi_opt_sim)->f = *lp_radau_f;
	(*jmi_opt_sim)->df = *lp_radau_df;
	(*jmi_opt_sim)->h = *lp_radau_h;
	(*jmi_opt_sim)->dh = *lp_radau_dh;
	(*jmi_opt_sim)->g = *lp_radau_g;
	(*jmi_opt_sim)->dg = *lp_radau_dg;
	(*jmi_opt_sim)->get_bounds = *jmi_opt_sim_get_bounds;
	(*jmi_opt_sim)->get_initial = *jmi_opt_sim_get_initial;
	(*jmi_opt_sim)->dh_nz_indices = *lp_radau_dh_nz_indices;
	(*jmi_opt_sim)->dg_nz_indices = *lp_radau_dg_nz_indices;

	return 0;
}

int jmi_opt_sim_lp_radau_delete(jmi_opt_sim_t *jmi_opt_sim) {

	return 0;
}
