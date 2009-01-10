#include "jmi_opt_sim.h"
#include "jmi_opt_sim_lp.h"

// Forward declarations
static void print_problem_stats(jmi_opt_sim_t *jmi_opt_sim);

static void print_lp_pols(jmi_opt_sim_t *jmi_opt_sim);


// Copy optimization parameters
static void lp_radau_copy_p(jmi_opt_sim_t *jmi_opt_sim) {

}

// Copy variables, i denotes element and j denotes collocation point
static void lp_radau_copy_v(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {

	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	int k;
	jmi_real_t *v;

	v = jmi_get_dx(jmi);
	for(k=0;k<jmi->n_dx;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_dx_coll +
		         (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j) + k];
	}

	v = jmi_get_x(jmi);
	for(k=0;k<jmi->n_x;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_x_coll +
		         (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j) + k];
	}

	v = jmi_get_u(jmi);
	for(k=0;k<jmi->n_u;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_u_coll +
		         (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j) + k];
	}

	v = jmi_get_w(jmi);
	for(k=0;k<jmi->n_w;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_w_coll +
		         (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j) + k];
	}


}

// Copy point wise values
static void lp_radau_copy_q(jmi_opt_sim_t *jmi_opt_sim) {

	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	int i,j;
	jmi_real_t *dx_p = jmi_get_dx_p(jmi);
	jmi_real_t *x_p = jmi_get_x_p(jmi);
	jmi_real_t *u_p = jmi_get_u_p(jmi);
	jmi_real_t *w_p = jmi_get_w_p(jmi);
/*
	printf("1[\n");
	for(i=0;i<jmi->n_z;i++) {
		printf("-----> %d: %f\n",i+1,z[i]);
	}
	printf("]\n");
*/
	for(i=0;i<jmi->n_tp;i++) {
		for(j=0;j<jmi->n_dx;j++) {
			dx_p[jmi->n_dx*i + j] = jmi_opt_sim->x[nlp->offs_dx_p +
	           (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
		}
		for(j=0;j<jmi->n_x;j++) {
			x_p[jmi->n_x*i + j] = jmi_opt_sim->x[nlp->offs_x_p +
	           (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
		}
		for(j=0;j<jmi->n_u;j++) {
			u_p[jmi->n_u*i + j] = jmi_opt_sim->x[nlp->offs_u_p +
	           (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
		}
		for(j=0;j<jmi->n_w;j++) {
			w_p[jmi->n_w*i + j] = jmi_opt_sim->x[nlp->offs_w_p +
	           (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
		}
	}

/*
	printf("2[\n");
	for(i=0;i<jmi->n_z;i++) {
		printf("-----> %d: %f\n",i+1,z[i]);
	}
	printf("]\n");
*/
}

// Copy initial point
static void lp_radau_copy_initial_point(jmi_opt_sim_t *jmi_opt_sim) {

	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	int k;
	jmi_real_t *v;

	v = jmi_get_dx(jmi);
	for(k=0;k<jmi->n_dx;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_dx_0 + k];
	}

	v = jmi_get_x(jmi);
	for(k=0;k<jmi->n_x;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_x_0 + k];
	}

	v = jmi_get_u(jmi);
	for(k=0;k<jmi->n_u;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_u_0 + k];
	}

	v = jmi_get_w(jmi);
	for(k=0;k<jmi->n_w;k++) {
		v[k] = jmi_opt_sim->x[nlp->offs_w_0 + k];
	}


}

// Cost function
static int lp_radau_f(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *f) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	// Copy values into jmi->z
    lp_radau_copy_p(jmi_opt_sim);
    lp_radau_copy_q(jmi_opt_sim);

	// Call cost function evaluation
	jmi_opt_J(jmi_opt_sim->jmi, f);

	return 0;
}

// Gradient of cost function
static int lp_radau_df(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *df) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	// Copy values into jmi->z
    lp_radau_copy_p(jmi_opt_sim);
    lp_radau_copy_q(jmi_opt_sim);

	// Compute cost function gradient
	jmi_opt_dJ(jmi_opt_sim->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
			   JMI_DER_PI, nlp->der_mask, df);
	jmi_opt_dJ(jmi_opt_sim->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
			   JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
			   df + nlp->offs_dx_p);

	return 0;
}

static int lp_radau_g(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	int i,j;
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	// Initial system
	lp_radau_copy_p(jmi_opt_sim);
	lp_radau_copy_initial_point(jmi_opt_sim);
	jmi_init_F0(jmi_opt_sim->jmi,res);

	// collocation points
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			lp_radau_copy_v(jmi_opt_sim,i,j);
			jmi_dae_F(jmi_opt_sim->jmi, res + jmi->init->F0->n_eq_F +
					   jmi->dae->F->n_eq_F*(i*nlp->n_cp + j));
		}
	}

	return 0;
}

static int lp_radau_dg(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	int i,j;
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	// Initial system
	lp_radau_copy_p(jmi_opt_sim);
	lp_radau_copy_initial_point(jmi_opt_sim);
	jmi_init_dF0(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
			     nlp->der_mask, jac);

	// collocation points
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		// dF_dp
		jmi_dae_dF(jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
				JMI_DER_PI, nlp->der_mask, jac + nlp->dF0_n_nz);
		// dF_ddx_dx_du_dw
		for (j=0;j<nlp->n_cp;j++) {
			lp_radau_copy_v(jmi_opt_sim,i,j);
			jmi_dae_dF(jmi_opt_sim->jmi, nlp->der_eval_alg, JMI_DER_SPARSE,
					   JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
					   nlp->der_mask,
					   jac + nlp->dF0_n_nz +
					   nlp->dF_dp_n_nz*(i+1) +
					   nlp->dF_ddx_dx_du_dw_n_nz*(i*nlp->n_cp + j));
		}
	}


	return 0;
}


static int lp_radau_dg_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	int i;

	for (i=0;i<jmi_opt_sim->dg_n_nz;i++) {
		irow[i] = jmi_opt_sim->dg_row[i];
		icol[i] = jmi_opt_sim->dg_col[i];
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

static int lp_radau_dh_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	int i;

	for (i=0;i<jmi_opt_sim->dh_n_nz;i++) {
		irow[i] = jmi_opt_sim->dh_row[i];
		icol[i] = jmi_opt_sim->dh_col[i];
	}

	return 0;
}

int jmi_opt_sim_lp_radau_new(jmi_opt_sim_t **jmi_opt_sim, jmi_t *jmi, int n_e,
        jmi_real_t *hs, int hs_free,
        jmi_real_t *pi_init, jmi_real_t *dx_init, jmi_real_t *x_init,
        jmi_real_t *u_init, jmi_real_t *w_init,
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

	int i, j, k, l;

	jmi_opt_sim_lp_radau_t* opt = (jmi_opt_sim_lp_radau_t*)calloc(1,sizeof(jmi_opt_sim_lp_radau_t));
	*jmi_opt_sim = (jmi_opt_sim_t*)opt;

    // Compute offsets
    opt->offs_p_opt = 0;
    opt->offs_dx_0 = jmi->opt->n_p_opt;
    opt->offs_x_0 = opt->offs_dx_0 + jmi->n_dx;
    opt->offs_u_0 = opt->offs_x_0 + jmi->n_x;
    opt->offs_w_0 = opt->offs_u_0 + jmi->n_u;
    opt->offs_dx_coll = opt->offs_w_0 + jmi->n_w;
    opt->offs_x_coll= opt->offs_dx_coll + jmi->n_dx;
    opt->offs_u_coll = opt->offs_x_coll + jmi->n_x;
    opt->offs_w_coll = opt->offs_u_coll + jmi->n_u;
    opt->offs_x_el_junc = opt->offs_dx_coll + jmi->n_w +
                          (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(n_e)*n_cp;
    opt->offs_dx_p = opt->offs_x_el_junc + n_e*jmi->n_x;
    opt->offs_x_p = opt->offs_dx_p + jmi->n_dx;
    opt->offs_u_p = opt->offs_x_p + jmi->n_x;
    opt->offs_w_p = opt->offs_u_p + jmi->n_u;
    opt->offs_h = opt->offs_w_p + jmi->n_w;

    if (hs_free == 1) {
        opt->offs_t0 = opt->offs_h + n_e;
    } else {
    	opt->offs_t0 = opt->offs_h;
    }

    if (jmi->opt->start_time_free == 1) {
    	opt->offs_tf = opt->offs_h + 1;
    } else {
    	opt->offs_tf = opt->offs_h;
    }



	// Compute elements and taus of time points
	(*jmi_opt_sim)->tp_e = (int*)calloc(jmi->n_tp,sizeof(int));
	(*jmi_opt_sim)->tp_tau = (jmi_real_t*)calloc(jmi->n_tp,sizeof(jmi_real_t));

	for (i=0;i<jmi->n_tp;i++) {
		jmi_real_t ti = 0;
		for (j=0;j<n_e;j++) {
			ti += hs[j];
			printf("%f %f %f\n", ti, hs[j], jmi->tp[i]);
			if (jmi->tp[i]<=ti) {
				(*jmi_opt_sim)->tp_e[i] = j;
				(*jmi_opt_sim)->tp_tau[i] = (jmi->tp[i] - (ti - hs[j]))/
				            (hs[j]);
				break;
			}
		}
	}

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

	// Compute vector sizes
    (*jmi_opt_sim)->n_x = jmi->opt->n_p_opt +                                   // Number of parameters to be optimized
                          (2*jmi->n_x + jmi->n_u + jmi->n_w)*(n_e*n_cp + 1) +   // Collocation variables + initial variables
                          jmi->n_x*n_e +                                        // States at element junctions
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
    (*jmi_opt_sim)->n_h = 2*jmi->n_x + jmi->n_w + // Initial equations
    	                  (jmi->n_x + jmi->n_w)*n_e*n_cp +     // Residual equations
                          jmi->n_x*n_e +                        // Continuity equations
                          jmi->n_x*n_e*n_cp +                    // Collocation equations
						  (2*jmi->n_x  + jmi->n_u + jmi->n_w)*jmi->n_tp +      // Pointwise equations
                          jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1) +               // Path constraints from optimization
                          jmi->opt->Heq->n_eq_F*jmi->n_tp;                // Point constraints from optimization

    // if free element lengths:
    // TODO: should be modeled explicitly in the Optimica code?
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

	//Compute sparsity patters for dg and dh
	// Mask for derivative evaluation
	opt->der_mask = (int*)calloc(jmi->n_z,sizeof(int));
	for (i=0;i<jmi->n_z;i++) {
		opt->der_mask[i] = 1;
	}
	for (i=jmi->offs_pi;i<jmi->offs_pi + jmi->n_pi;i++) {
			opt->der_mask[i] = 0;
	}
	for (i=0;i<jmi->opt->n_p_opt;i++) {
		opt->der_mask[jmi->offs_pi + jmi->opt->p_opt_indices[i]] = 1;
	}
	for (i=0;i<jmi->n_z;i++) {
		printf("*** %d\n",opt->der_mask[i]);
	}

	(*jmi_opt_sim)->dg_n_nz = ((*jmi_opt_sim)->n_g)*((*jmi_opt_sim)->n_x);
	(*jmi_opt_sim)->dg_row = (int*)calloc((*jmi_opt_sim)->dg_n_nz,sizeof(int));
	(*jmi_opt_sim)->dg_col = (int*)calloc((*jmi_opt_sim)->dg_n_nz,sizeof(int));

	int dF0_n_nz, dF_dp_n_nz, dF_ddx_dx_du_dw_n_nz, dF0_n_cols,
	              dF_dp_n_cols, dF_ddx_dx_du_dw_n_cols;
	jmi_init_dF0_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI | JMI_DER_DX | JMI_DER_X |
			         JMI_DER_U | JMI_DER_W, opt->der_mask,
			         &dF0_n_cols, &dF0_n_nz);

	jmi_dae_dF_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI, opt->der_mask,
			         &dF_dp_n_cols, &dF_dp_n_nz);

	jmi_dae_dF_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX | JMI_DER_X | JMI_DER_U |JMI_DER_W,
			         opt->der_mask, &dF_ddx_dx_du_dw_n_cols,
			         &dF_ddx_dx_du_dw_n_nz);

	opt->dF0_n_nz = dF0_n_nz;
	opt->dF_dp_n_nz = dF_dp_n_nz;
	opt->dF_ddx_dx_du_dw_n_nz = dF_ddx_dx_du_dw_n_nz;

	(*jmi_opt_sim)->dh_n_nz = dF0_n_nz +           // Initial equations
	                          (dF_dp_n_nz + dF_ddx_dx_du_dw_n_nz)*n_e*n_cp +   // Dynamic residuals
	                          2*jmi->n_x*n_e +     // Continuity equations
	                          (jmi->n_x*(n_cp+1) + jmi->n_dx)*n_e*n_cp + // Collocation equations
	                          ((jmi->n_x+jmi->n_dx)*(n_cp+1) +jmi->n_x + jmi->n_dx+
	                           (jmi->n_u + jmi->n_w)*(n_cp) + jmi->n_u + jmi->n_w)*jmi->n_tp; // Time points

	(*jmi_opt_sim)->dh_row = (int*)calloc((*jmi_opt_sim)->dh_n_nz,sizeof(int));
	(*jmi_opt_sim)->dh_col = (int*)calloc((*jmi_opt_sim)->dh_n_nz,sizeof(int));

	int *dF0_irow = (int*)calloc(dF0_n_nz,sizeof(int));
	int *dF0_icol = (int*)calloc(dF0_n_nz,sizeof(int));
	jmi_init_dF0_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_PI | JMI_DER_DX | JMI_DER_X |
	         JMI_DER_U | JMI_DER_W, opt->der_mask, dF0_irow,dF0_icol);

	int *dF_dp_irow = (int*)calloc(dF_dp_n_nz,sizeof(int));
	int *dF_dp_icol = (int*)calloc(dF_dp_n_nz,sizeof(int));
	jmi_dae_dF_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_PI, opt->der_mask, dF_dp_irow,dF_dp_icol);

	int *dF_ddx_dx_du_dw_irow = (int*)calloc(dF_ddx_dx_du_dw_n_nz,sizeof(int));
	int *dF_ddx_dx_du_dw_icol = (int*)calloc(dF_ddx_dx_du_dw_n_nz,sizeof(int));
	jmi_dae_dF_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX | JMI_DER_X |
	         JMI_DER_U | JMI_DER_W, opt->der_mask,
	         dF_ddx_dx_du_dw_irow,dF_ddx_dx_du_dw_icol);

	for (i=0;i<dF0_n_nz;i++) {
		printf("> %d, %d\n", dF0_irow[i], dF0_icol[i]);
	}
	for (i=0;i<dF_dp_n_nz;i++) {
		printf(">> %d, %d\n", dF_dp_irow[i], dF_dp_icol[i]);
	}
	for (i=0;i<dF_ddx_dx_du_dw_n_nz;i++) {
		printf(">>> %d, %d\n", dF_ddx_dx_du_dw_irow[i], dF_ddx_dx_du_dw_icol[i]);
	}


	int row_index = 0;
	int col_index = 0;
	int rc_ind = 0;
	// Sparsity indices for initialization system
	for (i=0;i<dF0_n_nz;i++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dF0_irow[i] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dF0_icol[i] + col_index;
		rc_ind++;
	}

	// Sparsity for dynamic residuals
	for (i=0;i<n_e*n_cp;i++) {
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*i;
		col_index = 0;
		for (k=0;k<dF_dp_n_nz;k++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = dF_dp_irow[k] + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = dF_dp_icol[k] + col_index;
			rc_ind++;
		}
		col_index = dF0_n_cols + dF_ddx_dx_du_dw_n_cols*i;
		for (k=0;k<dF_ddx_dx_du_dw_n_nz;k++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = dF_ddx_dx_du_dw_irow[k] + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = dF_ddx_dx_du_dw_icol[k] + col_index;
			rc_ind++;
		}
	}

	// Sparsity for element junctions
	for (i=0;i<n_e;i++) {
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_x*i;
		col_index = dF0_n_cols + dF_ddx_dx_du_dw_n_cols*n_cp*i +
		            dF_ddx_dx_du_dw_n_cols*(n_cp - 1) + jmi->n_dx;
		for (j=0;j<jmi->n_x;j++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + col_index;
			rc_ind++;
		}
		col_index = dF0_n_cols + dF_ddx_dx_du_dw_n_cols*n_cp*n_e +
				           jmi->n_x*i;
		for (j=0;j<jmi->n_x;j++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + col_index;
			rc_ind++;
		}
	}

	// Sparsity for collocation equations
	// Take care of the first point separately
	for (i=0;i<n_cp;i++) {
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_x*n_e +
		            jmi->n_x*i;
		// Elements corresponding to x_{0,0}
		for (j=0;j<jmi->n_x;j++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_dx;
			rc_ind++;
		}

		// Elements corresponding to dx_{0,1}
		for (j=0;j<jmi->n_dx;j++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + dF_ddx_dx_du_dw_n_cols*i;
			rc_ind++;
		}

		// Elements corresponding x_{0,k}
		for (k=0;k<n_cp;k++) {
			for (j=0;j<jmi->n_x;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + jmi->n_dx + dF_ddx_dx_du_dw_n_cols*k;
				rc_ind++;
			}
		}
	}

	// Take care of the remaining elements
	for (l=1;l<n_e;l++) {
		for (i=0;i<n_cp;i++) {
			row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_x*n_e +
		            jmi->n_x*n_cp*l + jmi->n_x*i;

			// Elements for dx_{l,i}
			for (j=0;j<jmi->n_dx;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + dF_ddx_dx_du_dw_n_cols*n_cp*l +
				                                 dF_ddx_dx_du_dw_n_cols*i;
				rc_ind++;
			}

			// Elements for x_{l,i}
			for (k=0;k<n_cp;k++) {
				for (j=0;j<jmi->n_x;j++) {
					(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
					(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols +
					                                 dF_ddx_dx_du_dw_n_cols*n_cp*l + jmi->n_dx +
					                                 dF_ddx_dx_du_dw_n_cols*k;
					rc_ind++;
				}
			}

			// Elements for x_{j,0}
			for (j=0;j<jmi->n_x;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols +
				                                 dF_ddx_dx_du_dw_n_cols*n_cp*n_e +
				                                 jmi->n_x*(l-1);
				rc_ind++;
			}

		}
	}

	// Sparsity for interpolation of time points
	for (i=0;i<jmi->n_tp;i++) {
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_x*n_e +
		jmi->n_x*n_e*n_cp + (jmi->n_x + jmi->n_dx + jmi->n_u + jmi->n_w)*i;

		// If the time point is in element 0, treat it separately
			// Elements for dx^p_i
			// Elements corresponding to x_{i,0}
    		if ((*jmi_opt_sim)->tp_e[i] == 0) {
    			for (j=0;j<jmi->n_x;j++) {
    				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
    				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_dx;
    				rc_ind++;
    			}
    		} else {
    			for (j=0;j<jmi->n_x;j++) {
    			    (*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
    			    (*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + opt->offs_x_el_junc +
    			                                     ((*jmi_opt_sim)->tp_e[i]-1)*jmi->n_x;
    			    rc_ind++;
    			}
    		}

			// Elements corresponding x_{0,k}
			for (k=0;k<n_cp;k++) {
				for (j=0;j<jmi->n_x;j++) {
					(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
					(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + jmi->n_dx +
                                                     dF_ddx_dx_du_dw_n_cols*((*jmi_opt_sim)->tp_e[i]*n_cp + k);
					rc_ind++;
				}
			}
			// Elements corresponding to dx^p_i
			for (j=0;j<jmi->n_dx;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i +opt->offs_dx_p;
				rc_ind++;
			}

			// Elements for x^p_i
			// Elements corresponding to x_{i,0}
	   		if ((*jmi_opt_sim)->tp_e[i] == 0) {
	    			for (j=0;j<jmi->n_x;j++) {
	    				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx;
	    				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_dx;
	    				rc_ind++;
	    			}
	    		} else {
	    			for (j=0;j<jmi->n_x;j++) {
	    			    (*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx;
	    			    (*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + opt->offs_x_el_junc +
	    			                                     ((*jmi_opt_sim)->tp_e[i]-1)*jmi->n_x;
	    			    rc_ind++;
	    			}
	    		}

			// Elements corresponding x_{0,k}
			for (k=0;k<n_cp;k++) {
				for (j=0;j<jmi->n_x;j++) {
					(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx;
					(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + jmi->n_dx +
                                                     dF_ddx_dx_du_dw_n_cols*((*jmi_opt_sim)->tp_e[i]*n_cp + k);
					rc_ind++;
				}
			}
			// Elements corresponding to x^p_i
			for (j=0;j<jmi->n_x;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i + opt->offs_x_p;
				rc_ind++;
			}

			// Elements for u^p_i
			// Elements corresponding u_{0,k}
			for (k=0;k<n_cp;k++) {
				for (j=0;j<jmi->n_u;j++) {
					(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx + jmi->n_x;
					(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + jmi->n_dx +
					                                 jmi->n_x + dF_ddx_dx_du_dw_n_cols*((*jmi_opt_sim)->tp_e[i]*n_cp + k);
					rc_ind++;
				}
			}
			// Elements corresponding to u^p_i
			for (j=0;j<jmi->n_u;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx + jmi->n_x;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i + opt->offs_u_p;
				rc_ind++;
			}

			// Elements for w^p_i
			// Elements corresponding w_{0,k}
			for (k=0;k<n_cp;k++) {
				for (j=0;j<jmi->n_w;j++) {
					(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx + jmi->n_x + jmi->n_u;
					(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF0_n_cols + jmi->n_dx +
					                                 jmi->n_x + jmi->n_w + dF_ddx_dx_du_dw_n_cols*((*jmi_opt_sim)->tp_e[i]*n_cp + k);
					rc_ind++;
				}
			}
			// Elements corresponding to u^p_i
			for (j=0;j<jmi->n_w;j++) {
				(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_dx + jmi->n_x + jmi->n_u;
				(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i + opt->offs_w_p;
				rc_ind++;
			}
	}

	FILE *f = fopen("sparsity.m","wt");

	fprintf(f,"n_x=%d;\n",jmi->n_x);
	fprintf(f,"n_u=%d;\n",jmi->n_u);
	fprintf(f,"n_w=%d;\n",jmi->n_w);
	fprintf(f,"n_tp=%d\n",jmi->n_tp);
	fprintf(f,"n_p_opt=%d\n",jmi->opt->n_p_opt);
	fprintf(f,"n_eq_Heq=%d\n",jmi->opt->Heq->n_eq_F);
	fprintf(f,"n_eq_Ceq=%d\n",jmi->opt->Ceq->n_eq_F);
	fprintf(f,"n_e=%d;\n",n_e);
	fprintf(f,"n_cp=%d;\n",n_cp);
	fprintf(f,"n_eq_F0=%d\n",jmi->init->F0->n_eq_F);
	fprintf(f,"n_eq_F=%d\n",jmi->dae->F->n_eq_F);
	fprintf(f,"dF0_n_cols=%d\n",dF0_n_cols);
	fprintf(f,"dF_dp_n_cols=%d\n",dF_dp_n_cols);
	fprintf(f,"dF_ddx_dx_du_dw_n_cols=%d\n",dF_ddx_dx_du_dw_n_cols);

	fprintf(f,"ind=[");
	for (i=0;i<(*jmi_opt_sim)->dh_n_nz;i++) {
		fprintf(f,"%d %d %d;\n",i+1,(*jmi_opt_sim)->dh_row[i],(*jmi_opt_sim)->dh_col[i]);
	}
	fprintf(f,"];\n");
	fprintf(f,"plotSparsityLP(n_x,n_u,n_w,n_p_opt,n_tp,n_eq_Heq,n_eq_Ceq,n_e,n_cp,n_eq_F0,n_eq_F,dF0_n_cols,dF_dp_n_cols,dF_ddx_dx_du_dw_n_cols,ind,1)");
	fclose(f);

	// Set the bounds vector

	// Bounds for optimization parameters
	int offs = 0;
	for (i=0;i<jmi->opt->n_p_opt;i++) {
    	(*jmi_opt_sim)->x_lb[i] = pi_lb[i];
    	(*jmi_opt_sim)->x_ub[i] = pi_ub[i];
    	(*jmi_opt_sim)->x_init[i] = pi_init[i];
    }
	offs += jmi->opt->n_p_opt;

    // Bounds for initial point and collocation points
    for (i=0;i<(n_e*n_cp + 1);i++) {
    	for (j=0;j<jmi->n_dx;j++) {
        	(*jmi_opt_sim)->x_lb[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_ub[j];
        	(*jmi_opt_sim)->x_init[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_init[j];
    	}

    	for (j=0;j<jmi->n_x;j++) {
        	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_ub[j];
        	(*jmi_opt_sim)->x_init[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_init[j];
    	}

    	for (j=0;j<jmi->n_u;j++) {
        	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_ub[j];
        	(*jmi_opt_sim)->x_init[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_init[j];
    	}

    	for (j=0;j<jmi->n_w;j++) {
        	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_ub[j];
        	(*jmi_opt_sim)->x_init[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_init[j];
    	}
    }
    offs += (n_e*n_cp + 1)*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w);

    // Bounds for the x variables at element junctions
    for (i=0;i<n_e;i++) {
    	for (j=0;j<jmi->n_x;j++) {
        	(*jmi_opt_sim)->x_lb[offs + (jmi->n_x)*i + j] = x_lb[j];
        	(*jmi_opt_sim)->x_ub[offs + (jmi->n_x)*i + j] = x_ub[j];
        	(*jmi_opt_sim)->x_init[offs + (jmi->n_x)*i + j] = x_init[j];
    	}
    }
    offs += n_e*jmi->n_x;

    // Bounds for variables at the time points
    for (i=0;i<jmi->n_tp;i++) {
     	for (j=0;j<jmi->n_dx;j++) {
         	(*jmi_opt_sim)->x_lb[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_lb[j];
         	(*jmi_opt_sim)->x_ub[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_ub[j];
         	(*jmi_opt_sim)->x_init[offs + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = dx_init[j];
     	}

     	for (j=0;j<jmi->n_x;j++) {
         	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_lb[j];
         	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_ub[j];
         	(*jmi_opt_sim)->x_init[offs + jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = x_init[j];
     	}

     	for (j=0;j<jmi->n_u;j++) {
         	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_lb[j];
         	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_ub[j];
         	(*jmi_opt_sim)->x_init[offs + jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = u_init[j];
     	}

     	for (j=0;j<jmi->n_w;j++) {
         	(*jmi_opt_sim)->x_lb[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_lb[j];
         	(*jmi_opt_sim)->x_ub[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_ub[j];
         	(*jmi_opt_sim)->x_init[offs + jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j] = w_init[j];
     	}

     }
     offs += jmi->n_tp*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w);

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

	print_lp_pols(*jmi_opt_sim);
	print_problem_stats(*jmi_opt_sim);


	return 0;
}

int jmi_opt_sim_lp_radau_delete(jmi_opt_sim_t *jmi_opt_sim) {

	return 0;
}

static void print_problem_stats(jmi_opt_sim_t *jmi_opt_sim) {
	jmi_opt_sim_lp_radau_t *opt = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;

	int i;

	printf("Creating NLP struct from Radau points and Lagrange polynomials:\n");
	printf("Number of mesh elements:                                   %d\n",jmi_opt_sim->n_e);
	printf("Number of collocation points:                              %d\n",opt->n_cp);
	printf("Number of variables:                                       %d\n",jmi_opt_sim->n_x);

	printf("Number of inequality constraints:                          %d\n",jmi_opt_sim->n_g);
	printf("Number of non-zeros in inequality constraint Jacobian:     %d\n",jmi_opt_sim->dg_n_nz);
	printf("Number of equality constraints:                            %d\n",jmi_opt_sim->n_h);
	printf("Number of non-zeros in equality constraint Jacobian:       %d\n",jmi_opt_sim->dh_n_nz);

	printf("p_opt offset in x:                                         %d\n",opt->offs_p_opt);
	printf("dx_0 offset in x:                                          %d\n",opt->offs_dx_0);
	printf("x_0 offset in x:                                           %d\n",opt->offs_x_0);
	printf("u_0 offset in x:                                           %d\n",opt->offs_u_0);
	printf("w_0 offset in x:                                           %d\n",opt->offs_w_0);
	printf("dx_coll offset in x:                                       %d\n",opt->offs_dx_coll);
	printf("x_coll offset in x:                                        %d\n",opt->offs_x_coll);
	printf("u_coll offset in x:                                        %d\n",opt->offs_u_coll);
	printf("w_coll offset in x:                                        %d\n",opt->offs_w_coll);
	printf("x_el_junc offset in x:                                     %d\n",opt->offs_x_el_junc);
	printf("dx_p offset in x:                                          %d\n",opt->offs_dx_p);
	printf("x_p offset in x:                                           %d\n",opt->offs_x_p);
	printf("u_p offset in x:                                           %d\n",opt->offs_u_p);
	printf("w_p offset in x:                                           %d\n",opt->offs_w_p);
	printf("h offset in x:                                             %d\n",opt->offs_h);
	printf("t0 offset in x:                                            %d\n",opt->offs_t0);
	printf("tf offset in x:                                            %d\n",opt->offs_tf);

	printf("Time points (index, normalized time, element, tau):\n");
	for (i=0;i<jmi_opt_sim->jmi->n_tp;i++) {
		printf("%d %f, %d, %f\n",i,jmi_opt_sim->jmi->tp[i],
				                 jmi_opt_sim->tp_e[i],jmi_opt_sim->tp_tau[i]);
	}

}

static void print_lp_pols(jmi_opt_sim_t *jmi_opt_sim) {

	int i, j;

	jmi_opt_sim_lp_radau_t *opt = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;

    // Print Lagrange polynomials
	printf("cp = {");
    for (i=0;i<opt->n_cp;i++) {
    	printf("%4.16e",opt->cp[i]);
    	if (i<opt->n_cp-1) {
        	printf(", ");
    	}
    }
    printf("}\n\n");

	printf("cpp = {");
    for (i=0;i<opt->n_cp+1;i++) {
    	printf("%4.16e",opt->cpp[i]);
    	if (i<opt->n_cp+1) {
        	printf(", ");
    	}
    }
    printf("}\n\n");

	printf("Lp_coeffs = {");
    for (i=0;i<opt->n_cp;i++) {
    	printf("{");
    	for (j=0;j<opt->n_cp;j++) {
    		printf("%4.16e",opt->Lp_coeffs[j*opt->n_cp + i]);
    		if (j<opt->n_cp-1) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<opt->n_cp-1) {
			printf(",\n");
		}
    }
    printf("}\n\n");


	printf("Lp_dot_coeffs = {");
    for (i=0;i<opt->n_cp;i++) {
    	printf("{");
    	for (j=0;j<opt->n_cp;j++) {
    		printf("%4.16e",opt->Lp_dot_coeffs[j*opt->n_cp + i]);
    		if (j<opt->n_cp-1) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<opt->n_cp-1) {
			printf(",\n");
		}
    }
    printf("}\n\n");

	printf("Lp_dot_vals = {");
    for (i=0;i<opt->n_cp;i++) {
    	printf("{");
    	for (j=0;j<opt->n_cp;j++) {
    		printf("%4.16e",opt->Lp_dot_vals[j*opt->n_cp + i]);
    		if (j<opt->n_cp-1) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<opt->n_cp-1) {
			printf(",\n");
		}
    }
    printf("}\n\n");

	printf("Lpp_coeffs = {");
    for (i=0;i<opt->n_cp+1;i++) {
    	printf("{");
    	for (j=0;j<opt->n_cp+1;j++) {
    		printf("%4.16e",opt->Lpp_coeffs[j*(opt->n_cp+1) + i]);
    		if (j<opt->n_cp) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<opt->n_cp) {
			printf(",\n");
		}
    }
    printf("}\n\n");


	printf("Lpp_dot_coeffs = {");
    for (i=0;i<opt->n_cp+1;i++) {
    	printf("{");
    	for (j=0;j<opt->n_cp+1;j++) {
    		printf("%4.16e",opt->Lpp_dot_coeffs[j*(opt->n_cp+1) + i]);
    		if (j<opt->n_cp) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<opt->n_cp) {
			printf(",\n");
		}
    }
    printf("}\n\n");

	printf("Lpp_dot_vals = {");
    for (i=0;i<opt->n_cp+1;i++) {
    	printf("{");
    	for (j=0;j<opt->n_cp+1;j++) {
    		printf("%4.16e",opt->Lpp_dot_vals[j*(opt->n_cp+1) + i]);
    		if (j<opt->n_cp) {
    			printf(", ");
    		}
    	}
    	printf("}");
		if (i<opt->n_cp) {
			printf(",\n");
		}
    }
    printf("}\n\n");


}


