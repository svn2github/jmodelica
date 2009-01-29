#include "jmi_opt_sim.h"
#include "jmi_opt_sim_lp.h"

static jmi_real_t p_opt(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	return jmi_opt_sim->x[nlp->offs_p_opt + i];
}
static jmi_real_t dx_0(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	return jmi_opt_sim->x[nlp->offs_dx_0 + i];
}
static jmi_real_t x_0(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	return jmi_opt_sim->x[nlp->offs_x_0 + i];
}
static jmi_real_t u_0(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	return jmi_opt_sim->x[nlp->offs_u_0 + i];
}
static jmi_real_t w_0(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	return jmi_opt_sim->x[nlp->offs_w_0 + i];
}

// i is element, j is collocation point, k is variable index
static jmi_real_t dx_coll(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_dx_coll + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j-1) + k];
}
// i is element, j is collocation point, k is variable index
static jmi_real_t x_coll(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	//printf("* %d %d *\n",i,j);
	if (i==0 && j==0) {
		return jmi_opt_sim->x[nlp->offs_x_0 + k];
	} else if (i>0 && j==0) {
		return jmi_opt_sim->x[nlp->offs_x_el_junc + jmi->n_x*(i-1) + k];
	} else {
		return jmi_opt_sim->x[nlp->offs_x_coll + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j - 1) + k];
	}
}
// i is element, j is collocation point, k is variable index
static jmi_real_t u_coll(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_u_coll + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j - 1) + k];
}
// i is element, j is collocation point, k is variable index
static jmi_real_t w_coll(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_w_coll + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(nlp->n_cp*i + j - 1) + k];
}

// i is time point, j is variable index
static jmi_real_t dx_p(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_dx_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
}
// i is time point, j is variable index
static jmi_real_t x_p(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_x_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
}
// i is time point, j is variable index
static jmi_real_t u_p(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_u_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
}
// i is time point, j is variable index
static jmi_real_t w_p(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi_opt_sim->x[nlp->offs_w_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j];
}

// i equation index
static int dh_init_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i) {
	return i;
}

// i element j collocation point k equation index
static int dh_res_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(i*nlp->n_cp + j-1) + k;
}

// i element j equation index
static int dh_cont_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*i + j;
}

// Interpolation equations for u_0 i equation index
static int dh_u0_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
      jmi->n_x*jmi_opt_sim->n_e + i;

}

// i element j collocation point k equation index
static int dh_coll_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*jmi_opt_sim->n_e + jmi->n_u + jmi->n_x*(nlp->n_cp*i + j-1) + k;

}


// i interpolation point j equation index
static int dh_dx_p_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
    jmi->n_x*jmi_opt_sim->n_e + jmi->n_x*nlp->n_cp*jmi_opt_sim->n_e +
	       jmi->n_u +
	       (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j;
}

// i interpolation point j equation index
static int dh_x_p_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*jmi_opt_sim->n_e + jmi->n_x*nlp->n_cp*jmi_opt_sim->n_e +
	       jmi->n_u +
	       jmi->n_dx + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j;
}

// i interpolation point j equation index
static int dh_u_p_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*jmi_opt_sim->n_e + jmi->n_x*nlp->n_cp*jmi_opt_sim->n_e +
	       jmi->n_u +
	       jmi->n_dx + jmi->n_x + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j;
}

// i interpolation point j equation index
static int dh_w_p_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*jmi_opt_sim->n_e + jmi->n_x*nlp->n_cp*jmi_opt_sim->n_e +
	       jmi->n_u +
	       jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + j;
}

// Constraint Ceq, element i, collocation point j, constraint k
static int dh_Ceq_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*jmi_opt_sim->n_e + jmi->n_x*nlp->n_cp*jmi_opt_sim->n_e +
	       jmi->n_u +
	       jmi->n_dx + jmi->n_x + jmi->n_u + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*jmi->n_tp +
	       jmi->opt->Ceq->n_eq_F*(nlp->n_cp*i + (j - 1) + 1) + k;
}

// Constraint Heq, constraint i
static int dh_Heq_eq_offs(jmi_opt_sim_t *jmi_opt_sim, int i) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_sim->n_e*nlp->n_cp) +
	       jmi->n_x*jmi_opt_sim->n_e + jmi->n_x*nlp->n_cp*jmi_opt_sim->n_e +
	       jmi->n_u +
	       (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*jmi->n_tp +
	       jmi->opt->Ceq->n_eq_F*(nlp->n_cp*jmi_opt_sim->n_e + 1) + i;
}

/*
// i sparse entry index
static int dg_init_sparse_offs(jmi_opt_sim_t *jmi_opt_sim, int i) {
	return i;
}

// i element j collocation point k equation index
static int dg_coll_spare_offs(jmi_opt_sim_t *jmi_opt_sim, int i, int j, int k) {
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	return nlp->dF0_n_nz +
	          nlp->dF_dp_n_nz*(i*nlp->n_cp + j + 1) +
	             nlp->dF_ddx_dx_du_dw_n_nz*(i*nlp->n_cp + j);
}
*/

// Forward declarations
static void print_problem_stats(jmi_opt_sim_t *jmi_opt_sim);

static void print_lp_pols(jmi_opt_sim_t *jmi_opt_sim);


// Copy optimization parameters
static void lp_radau_copy_p(jmi_opt_sim_t *jmi_opt_sim) {
	//jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;
	int i;

	jmi_real_t *pi = jmi_get_pi(jmi);

	for (i=0;i<jmi->opt->n_p_opt;i++) {
		pi[jmi->opt->p_opt_indices[i]] = jmi_opt_sim->x[i];
	}
}

// Copy variables, i denotes element and j denotes collocation point
static void lp_radau_copy_v(jmi_opt_sim_t *jmi_opt_sim, int i, int j) {

	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	int k;
	jmi_real_t *v;

	v = jmi_get_dx(jmi);
	for(k=0;k<jmi->n_dx;k++) {
		v[k] = dx_coll(jmi_opt_sim, i, j, k);
	}

	v = jmi_get_x(jmi);
	for(k=0;k<jmi->n_x;k++) {
		v[k] = x_coll(jmi_opt_sim, i, j, k);
	}

	v = jmi_get_u(jmi);
	for(k=0;k<jmi->n_u;k++) {
		v[k] = u_coll(jmi_opt_sim, i, j, k);
	}

	v = jmi_get_w(jmi);
	for(k=0;k<jmi->n_w;k++) {
		v[k] = w_coll(jmi_opt_sim, i, j, k);
	}

	v = jmi_get_t(jmi);
	v[0] = 0;
	for (k=0;k<i;k++) {
		v[0] += jmi_opt_sim->hs[i];
	} //TODO: Take into account the situation when initial and final times are free.
	v[0] = jmi->opt->start_time + (jmi->opt->final_time - jmi->opt->start_time)*(v[0] +
			jmi_opt_sim->hs[i]*nlp->cp[j-1]);
//	printf("-\n%d, %d, %12.12f\n-\n",i,j,v[0]);

}

// Copy point wise values
static void lp_radau_copy_q(jmi_opt_sim_t *jmi_opt_sim) {

	jmi_t *jmi = jmi_opt_sim->jmi;

	int i,j;
	jmi_real_t *_dx_p;
	jmi_real_t *_x_p;
	jmi_real_t *_u_p;
	jmi_real_t *_w_p;
/*
	printf("1[\n");
	for(i=0;i<jmi->n_z;i++) {
		printf("-----> %d: %f\n",i+1,z[i]);
	}
	printf("]\n");
*/
	for(i=0;i<jmi->n_tp;i++) {
		_dx_p = jmi_get_dx_p(jmi,i);
		_x_p = jmi_get_x_p(jmi,i);
		_u_p = jmi_get_u_p(jmi,i);
		_w_p = jmi_get_w_p(jmi,i);

		for(j=0;j<jmi->n_dx;j++) {
			_dx_p[j] = dx_p(jmi_opt_sim,i,j);
		}
		for(j=0;j<jmi->n_x;j++) {
			_x_p[j] = x_p(jmi_opt_sim,i,j);
		}
		for(j=0;j<jmi->n_u;j++) {
			_u_p[j] = u_p(jmi_opt_sim,i,j);
		}
		for(j=0;j<jmi->n_w;j++) {
			_w_p[j] = w_p(jmi_opt_sim,i,j);
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

//	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	int k;
	jmi_real_t *v;

	v = jmi_get_dx(jmi);
	for(k=0;k<jmi->n_dx;k++) {
		v[k] = dx_0(jmi_opt_sim,k);
	}

	v = jmi_get_x(jmi);
	for(k=0;k<jmi->n_x;k++) {
		v[k] = x_0(jmi_opt_sim,k);
	}

	v = jmi_get_u(jmi);
	for(k=0;k<jmi->n_u;k++) {
		v[k] = u_0(jmi_opt_sim,k);
	}

	v = jmi_get_w(jmi);
	for(k=0;k<jmi->n_w;k++) {
		v[k] = w_0(jmi_opt_sim,k);
	}

	// TODO: take variable start time into account
	v = jmi_get_t(jmi);
	v[0] = jmi->opt->start_time;

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
	//jmi_t *jmi = jmi_opt_sim->jmi;

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

	// Path inequality constraints
	// Initial variables
	lp_radau_copy_p(jmi_opt_sim);
	lp_radau_copy_q(jmi_opt_sim);
	lp_radau_copy_initial_point(jmi_opt_sim);
	jmi_opt_Cineq(jmi_opt_sim->jmi,res);

	// Collocation variables
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			lp_radau_copy_v(jmi_opt_sim,i,j+1);
			jmi_opt_Cineq(jmi_opt_sim->jmi, res + jmi->opt->Cineq->n_eq_F*(1 + i*nlp->n_cp + j));
		}
	}

	jmi_opt_Hineq(jmi,res + jmi->opt->Cineq->n_eq_F*(nlp->n_cp*jmi_opt_sim->n_e + 1));

	return 0;
}

static int lp_radau_dg(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	int i,j;
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;

	// Initial variables
	lp_radau_copy_p(jmi_opt_sim);
	lp_radau_copy_q(jmi_opt_sim);
	lp_radau_copy_initial_point(jmi_opt_sim);
	jmi_opt_dCineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_PI, nlp->der_mask, jac);
	jmi_opt_dCineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask, jac + nlp->dCineq_dp_n_nz);
	jmi_opt_dCineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
			     jac + nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz);

	// collocation variables
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			lp_radau_copy_v(jmi_opt_sim,i,j+1);
			jmi_opt_dCineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					     JMI_DER_PI, nlp->der_mask,
					     jac + (nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
					     (1 + i*nlp->n_cp + j));
			jmi_opt_dCineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					     JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask,
					     jac + (nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
					     (1 + i*nlp->n_cp + j) + nlp->dCineq_dp_n_nz);
			jmi_opt_dCineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					     JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
					     jac + (nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
					     (1 + i*nlp->n_cp + j) + nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz);
		}

	}

	jmi_opt_dHineq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_PI | JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
			     jac + (nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
			     (1 + nlp->n_cp*jmi_opt_sim->n_e));

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
	//	printf("-- g\n");

		int i,j;
		jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
		jmi_t *jmi = jmi_opt_sim->jmi;

		// Initial system
		lp_radau_copy_p(jmi_opt_sim);
		lp_radau_copy_q(jmi_opt_sim);
		lp_radau_copy_initial_point(jmi_opt_sim);
		jmi_init_F0(jmi_opt_sim->jmi,res+ dh_init_eq_offs(jmi_opt_sim,0));

		// collocation point residuals
		for (i=0;i<jmi_opt_sim->n_e;i++) {
			for (j=0;j<nlp->n_cp;j++) {
				lp_radau_copy_v(jmi_opt_sim,i,j+1);
				jmi_dae_F(jmi_opt_sim->jmi, res + dh_res_eq_offs(jmi_opt_sim, i, j + 1, 0));
			}
		}

		// Continuity equations
		for (i=0;i<jmi_opt_sim->n_e;i++) {
			for (j=0;j<jmi->n_x;j++) {
				res[dh_cont_eq_offs(jmi_opt_sim, i, j)] = x_coll(jmi_opt_sim,i,nlp->n_cp,j) -
				                          x_coll(jmi_opt_sim,i+1,0,j);
			}
		}

		// Interpolation equation for u_0
		// Compute element length, taking into account if the initial or
		// terminal time, or the element lengths are free.
		jmi_real_t el_length;
		if (jmi->opt->final_time_free == 0 &&
		    jmi->opt->start_time_free == 0 &&
		    jmi_opt_sim->hs_free ==0) {
			el_length = jmi_opt_sim->hs[0]*(jmi->opt->final_time - jmi->opt->start_time);
		} else { // TODO: Take care of the other cases
			el_length=0;
		}
		int k,l;
		for (k=0;k<jmi->n_u;k++) {
			res[dh_u0_eq_offs(jmi_opt_sim,k)] = u_0(jmi_opt_sim,k);
			for (l=0;l<nlp->n_cp;l++) {
				//printf("--- %d %d %d %d %d\n",i,jmi_opt_sim->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_sim, i, k),l);
				res[dh_u0_eq_offs(jmi_opt_sim, k)] -=
					jmi_opt_sim_lp_radau_eval_pol(0,nlp->n_cp, nlp->Lp_coeffs, l)*
					   u_coll(jmi_opt_sim,0,l+1,k);
			}
		}


		// Collocation equations
		for (i=0;i<jmi_opt_sim->n_e;i++) {
			for (j=0;j<nlp->n_cp;j++) {
				int k,l;

				// Compute element length, taking into account if the initial or
				// terminal time, or the element lengths are free.
				jmi_real_t el_length;
				if (jmi->opt->final_time_free == 0 &&
				    jmi->opt->start_time_free == 0 &&
				    jmi_opt_sim->hs_free ==0) {
					el_length = jmi_opt_sim->hs[i]*(jmi->opt->final_time - jmi->opt->start_time);
				} else { // TODO: Take care of the other cases
					el_length=0;
				}
				for (k=0;k<jmi->n_x;k++) {
					res[dh_coll_eq_offs(jmi_opt_sim, i, j+1, k)] = dx_coll(jmi_opt_sim,i,j+1,k);
					for (l=0;l<nlp->n_cp+1;l++) {
						//printf("-- %d %d %d %d %f---\n",i,j,k,l,nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + l]);
							res[dh_coll_eq_offs(jmi_opt_sim, i, j+1, k)] -=
							nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + l]*x_coll(jmi_opt_sim,i,l,k)/el_length;
					}
				}
			}
		}

		// Interpolation equations
		for (i=0;i<jmi->n_tp;i++) {
				int k,l;
				// Compute element length, taking into account if the initial or
				// terminal time, or the element lengths are free.
				if (jmi->opt->final_time_free == 0 &&
				    jmi->opt->start_time_free == 0 &&
				    jmi_opt_sim->hs_free ==0) {
					el_length = jmi_opt_sim->hs[jmi_opt_sim->tp_e[i]]*(jmi->opt->final_time - jmi->opt->start_time);
				} else { // TODO: Take care of the other cases
					el_length=0;
				}

				// Interpolation equations for dx
				for (k=0;k<jmi->n_dx;k++) {
					res[dh_dx_p_eq_offs(jmi_opt_sim, i, k)] = dx_p(jmi_opt_sim,i,k);
					for (l=0;l<nlp->n_cp+1;l++) {
						//printf("--- %d %d %d %d %d\n",i,jmi_opt_sim->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_sim, i, k),l);
						res[dh_dx_p_eq_offs(jmi_opt_sim, i, k)] -=
							jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, l)*
							   x_coll(jmi_opt_sim,jmi_opt_sim->tp_e[i],l,k)/el_length;
					}
				}

				// Interpolation equations for x
				for (k=0;k<jmi->n_x;k++) {
					res[dh_x_p_eq_offs(jmi_opt_sim, i, k)] = x_p(jmi_opt_sim,i,k);
					for (l=0;l<nlp->n_cp+1;l++) {
						//printf("--- %d %d %d %d %d\n",i,jmi_opt_sim->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_sim, i, k),l);
						res[dh_x_p_eq_offs(jmi_opt_sim, i, k)] -=
							jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, l)*
							   x_coll(jmi_opt_sim,jmi_opt_sim->tp_e[i],l,k);
					}
				}

				// Interpolation equations for u
				for (k=0;k<jmi->n_u;k++) {
					res[dh_u_p_eq_offs(jmi_opt_sim, i, k)] = u_p(jmi_opt_sim,i,k);
					for (l=0;l<nlp->n_cp;l++) {
						//printf("--- %d %d %d %d %d\n",i,jmi_opt_sim->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_sim, i, k),l);
						res[dh_u_p_eq_offs(jmi_opt_sim, i, k)] -=
							jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, l)*
							   u_coll(jmi_opt_sim,jmi_opt_sim->tp_e[i],l+1,k);
					}
				}

				// Interpolation equations for w
				for (k=0;k<jmi->n_w;k++) {
					res[dh_w_p_eq_offs(jmi_opt_sim, i, k)] = w_p(jmi_opt_sim,i,k);
					for (l=0;l<nlp->n_cp;l++) {
						//printf("--- %d %d %d %d %d\n",i,jmi_opt_sim->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_sim, i, k),l);
						res[dh_w_p_eq_offs(jmi_opt_sim, i, k)] -=
							jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, l)*
							   w_coll(jmi_opt_sim,jmi_opt_sim->tp_e[i],l+1,k);
					}
				}
		}

		// Constraints Ceq
		lp_radau_copy_initial_point(jmi_opt_sim);
		// Initial variables
		jmi_opt_Ceq(jmi_opt_sim->jmi,res + dh_Ceq_eq_offs(jmi_opt_sim,0,0,0));

		// Collocation variables
		for (i=0;i<jmi_opt_sim->n_e;i++) {
			for (j=0;j<nlp->n_cp;j++) {
				lp_radau_copy_v(jmi_opt_sim,i,j+1);
				jmi_opt_Ceq(jmi_opt_sim->jmi,res + dh_Ceq_eq_offs(jmi_opt_sim,i,j+1,0));
			}
		}

		// Constraints in Heq

		jmi_opt_Heq(jmi_opt_sim->jmi,res + dh_Heq_eq_offs(jmi_opt_sim, 0));



	return 0;
}

static int lp_radau_dh(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}

	int i,j,k,l;
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;

	// Initial system
	lp_radau_copy_p(jmi_opt_sim);
	lp_radau_copy_initial_point(jmi_opt_sim);
	jmi_init_dF0(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
			     nlp->der_mask, jac);

	// collocation point residuals
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			lp_radau_copy_v(jmi_opt_sim,i,j+1);
			// dF_dp
			jmi_dae_dF(jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					JMI_DER_PI, nlp->der_mask, jac + nlp->dF0_n_nz + (nlp->dF_dp_n_nz + nlp->dF_ddx_dx_du_dw_n_nz)*(i*nlp->n_cp + j));
			// dF_ddx_dx_du_dw
			jmi_dae_dF(jmi_opt_sim->jmi, nlp->der_eval_alg, JMI_DER_SPARSE,
					   JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
					   nlp->der_mask,
					   jac + nlp->dF0_n_nz +
					   nlp->dF_dp_n_nz*(i*nlp->n_cp + j + 1) +
					   nlp->dF_ddx_dx_du_dw_n_nz*(i*nlp->n_cp + j));
		}
	}

	// Continuity equations
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<jmi->n_x;j++) {
			jac[nlp->dF0_n_nz +
				   (nlp->dF_dp_n_nz +
				    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
				    jmi->n_x*2*i + j] = 1;
			jac[nlp->dF0_n_nz +
				   (nlp->dF_dp_n_nz +
				    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
				    jmi->n_x*(2*i+1) + j] = -1;

		}
	}


	// Interpolation equations for u_0
	jmi_real_t el_length;
	if (jmi->opt->final_time_free == 0 &&
	    jmi->opt->start_time_free == 0 &&
	    jmi_opt_sim->hs_free ==0) {
		el_length = jmi_opt_sim->hs[0]*(jmi->opt->final_time - jmi->opt->start_time);
	} else { // TODO: Take care of the other cases
		el_length=0;
	}

	// Entries for u_0,j
	for (j=0;j<nlp->n_cp;j++) {
		for (k=0;k<jmi->n_u;k++) {
			jac[nlp->dF0_n_nz +
			    (nlp->dF_dp_n_nz +
		    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
				 jmi->n_x*2*jmi_opt_sim->n_e +
				 jmi->n_u*j + k] =
					 -jmi_opt_sim_lp_radau_eval_pol(0,nlp->n_cp, nlp->Lp_coeffs, j);
		}
	}

	// Entries for u_0
	for (k=0;k<jmi->n_u;k++) {
		jac[nlp->dF0_n_nz +
		    (nlp->dF_dp_n_nz +
	    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
			 jmi->n_x*2*jmi_opt_sim->n_e +
			 jmi->n_u*nlp->n_cp + k] = 1;
	}


	// Collocation equations
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {

			// Compute element length, taking into account if the initial or
			// terminal time, or the element lengths are free.
			jmi_real_t el_length;
			if (jmi->opt->final_time_free == 0 &&
			    jmi->opt->start_time_free == 0 &&
			    jmi_opt_sim->hs_free ==0) {
				el_length = jmi_opt_sim->hs[0]*(jmi->opt->final_time - jmi->opt->start_time);
			} else { // TODO: Take care of the other cases
				el_length=0;
			}

			// dx
			for (k=0;k<jmi->n_dx;k++) {
				jac[nlp->dF0_n_nz +
					(nlp->dF_dp_n_nz +
					 nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + k] = 1;
			}

			// x_i,j
			for (k=0;k<nlp->n_cp;k++) {
				for (l=0;l<jmi->n_x;l++) {
/*					printf("-- %d\n",nlp->dF0_n_nz +
						(nlp->dF_dp_n_nz +
						 nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + jmi->n_x +
						 jmi->n_x*k + l);*/
					jac[nlp->dF0_n_nz +
						(nlp->dF_dp_n_nz +
						 nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + jmi->n_x +
						 jmi->n_x*k + l] = -nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + k + 1]/el_length;
				}
			}

			// x_i,0
			for (l=0;l<jmi->n_x;l++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + jmi->n_x +
						 jmi->n_x*nlp->n_cp + l] = -nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + 0]/el_length;
			}
		}
	}

	// Interpolation equations
	// Interpolation equations
	for (i=0;i<jmi->n_tp;i++) {
			// Compute element length, taking into account if the initial or
			// terminal time, or the element lengths are free.
			jmi_real_t el_length;
			if (jmi->opt->final_time_free == 0 &&
			    jmi->opt->start_time_free == 0 &&
			    jmi_opt_sim->hs_free ==0) {
				el_length = jmi_opt_sim->hs[jmi_opt_sim->tp_e[i]]*(jmi->opt->final_time - jmi->opt->start_time);
			} else { // TODO: Take care of the other cases
				el_length=0;
			}

			// Interpolation equations for dx_p

			// Entries for x_i,0
			for (k=0;k<jmi->n_x;k++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
						 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
								 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] =
							 -jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, 0)/el_length;
			}

			// Entries for x_i,j
			for (j=0;j<nlp->n_cp;j++) {
				for (k=0;k<jmi->n_x;k++) {
					jac[nlp->dF0_n_nz +
					    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
						 jmi->n_x*(j+1) +
						 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
								 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] =
							 -jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, j+1)/el_length;
				}
			}

			// Entries for dx_p
			for (k=0;k<jmi->n_dx;k++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 jmi->n_x*(nlp->n_cp+1) +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
							 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] = 1;
			}

			// Interpolation equations for x

			// Entries for x_i,0
			for (k=0;k<jmi->n_x;k++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
						 jmi->n_x*(nlp->n_cp + 2) +
						 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
								 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] =
							 -jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, 0);
			}

			// Entries for x_i,j
			for (j=0;j<nlp->n_cp;j++) {
				for (k=0;k<jmi->n_x;k++) {
					jac[nlp->dF0_n_nz +
					    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
						 jmi->n_x*(nlp->n_cp + 2) +
						 jmi->n_x*(j+1) +
						 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
								 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] =
							 -jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, j+1);
				}
			}

			// Entries for x_p
			for (k=0;k<jmi->n_x;k++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 jmi->n_x*(nlp->n_cp + 2) +
					 jmi->n_x*(nlp->n_cp+1) +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
							 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] = 1;
			}


			// Interpolation equations for u

			// Entries for u_i,j
			for (j=0;j<nlp->n_cp;j++) {
				for (k=0;k<jmi->n_u;k++) {
					jac[nlp->dF0_n_nz +
					    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
						 jmi->n_x*(nlp->n_cp + 2) +
						 jmi->n_x*(nlp->n_cp + 2) +
						 jmi->n_u*j +
						 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
								 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] =
							 -jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, j);
				}
			}

			// Entries for u_p
			for (k=0;k<jmi->n_u;k++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 jmi->n_x*(nlp->n_cp + 2) +
					 jmi->n_x*(nlp->n_cp + 2) +
					 jmi->n_u*nlp->n_cp +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
							 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] = 1;
			}

			// Interpolation equations for w

			// Entries for w_i,j
			for (j=0;j<nlp->n_cp;j++) {
				for (k=0;k<jmi->n_u;k++) {
					jac[nlp->dF0_n_nz +
					    (nlp->dF_dp_n_nz +
				    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
						 jmi->n_x*2*jmi_opt_sim->n_e +
						 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
						 jmi->n_x*(nlp->n_cp + 2) +
						 jmi->n_x*(nlp->n_cp + 2) +
						 jmi->n_u*(nlp->n_cp + 1) +
						 jmi->n_w*j +
						 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
								 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] =
							 -jmi_opt_sim_lp_radau_eval_pol(jmi_opt_sim->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, j);
				}
			}

			// Entries for w_p
			for (k=0;k<jmi->n_u;k++) {
				jac[nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 jmi->n_x*(nlp->n_cp + 2) +
					 jmi->n_x*(nlp->n_cp + 2) +
					 jmi->n_u*(nlp->n_cp + 1) +
					 jmi->n_w*nlp->n_cp +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
							 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*i + k] = 1;
			}
	}

	// Ceq
	// Initial variables
	lp_radau_copy_initial_point(jmi_opt_sim);
	jmi_opt_dCeq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_PI, nlp->der_mask, jac + nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
	                 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp);
	jmi_opt_dCeq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask, jac + nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
	                 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp + nlp->dCeq_dp_n_nz);
	jmi_opt_dCeq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
			     JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
			     jac + nlp->dF0_n_nz +
				    (nlp->dF_dp_n_nz +
			    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
					 jmi->n_x*2*jmi_opt_sim->n_e +
					 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
					 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
	                 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp +
	                 nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz);

	// collocation variables
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			lp_radau_copy_v(jmi_opt_sim,i,j+1);
			jmi_opt_dCeq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					     JMI_DER_PI, nlp->der_mask,
					     jac + nlp->dF0_n_nz +
						    (nlp->dF_dp_n_nz +
					    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
							 jmi->n_x*2*jmi_opt_sim->n_e +
							 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
							 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
			                 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp +
			                 (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
					     (1 + i*nlp->n_cp + j));
			jmi_opt_dCeq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					     JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask,
					     jac + nlp->dF0_n_nz +
						    (nlp->dF_dp_n_nz +
					    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
							 jmi->n_x*2*jmi_opt_sim->n_e +
							 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
							 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
			                 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp +
			                 (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
					     (1 + i*nlp->n_cp + j) + nlp->dCeq_dp_n_nz);
			jmi_opt_dCeq(jmi_opt_sim->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
					     JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
					     jac + nlp->dF0_n_nz +
						    (nlp->dF_dp_n_nz +
					    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
							 jmi->n_x*2*jmi_opt_sim->n_e +
							 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
							 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
			                 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp +
			                 (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
					     (1 + i*nlp->n_cp + j) + nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz);
		}

	}

	// Heq
	jmi_opt_dHeq(jmi_opt_sim->jmi, nlp->der_eval_alg, JMI_DER_SPARSE,
			   JMI_DER_PI | JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
			   nlp->der_mask,jac + nlp->dF0_n_nz +
		    (nlp->dF_dp_n_nz +
	    	nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_sim->n_e*nlp->n_cp) +
			 jmi->n_x*2*jmi_opt_sim->n_e +
			 jmi->n_u*(nlp->n_cp+1) + jmi->n_x*(nlp->n_cp + 2)*jmi_opt_sim->n_e*nlp->n_cp +
			 (jmi->n_x*(nlp->n_cp + 2) + jmi->n_x*(nlp->n_cp + 2) +
			 							 jmi->n_u*(nlp->n_cp + 1) + jmi->n_w*(nlp->n_cp + 1))*jmi->n_tp +
			 							 (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
			 						     (1 + jmi_opt_sim->n_e*nlp->n_cp ));

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

static int lp_radau_write_file_matlab(jmi_opt_sim_t *jmi_opt_sim, char* file_name) {
	int i,j,k;
	jmi_opt_sim_lp_radau_t *nlp = (jmi_opt_sim_lp_radau_t*)jmi_opt_sim;
	jmi_t *jmi = jmi_opt_sim->jmi;


	FILE *f = fopen(file_name,"wt");

	fprintf(f,"t=[");
	// initial time point
	// TODO: Support for free initial and final time
	fprintf(f,"%12.12f\n",jmi->opt->start_time);


	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			jmi_real_t tt = jmi->opt->start_time;
			for (k=0;k<i;k++) {
				tt += jmi_opt_sim->hs[k]*(jmi->opt->final_time-jmi->opt->start_time);
			}
			tt += jmi_opt_sim->hs[i]*nlp->cp[j]*(jmi->opt->final_time-jmi->opt->start_time);
			fprintf(f,"%12.12f\n",tt);
		}
	}
	fprintf(f,"];\n");

	// optimization parameters
	fprintf(f,"p_opt=[");
	for (i=0;i<jmi->opt->n_p_opt;i++) {
		fprintf(f,"%12.12f\n",p_opt(jmi_opt_sim,i));
	}
	fprintf(f,"];\n");

	// derivatives
	fprintf(f,"dx=[");
	for (i=0;i<jmi->n_dx;i++) {
		fprintf(f,"%12.12f, ",dx_0(jmi_opt_sim,i));
	}
	fprintf(f,"\n");
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			for (k=0;k<jmi->n_dx;k++) {
				fprintf(f,"%12.12f, ",dx_coll(jmi_opt_sim,i,j+1,k));
			}
			fprintf(f,"\n");
		}
	}
	fprintf(f,"];\n");

	// states
	fprintf(f,"x=[");
	for (i=0;i<jmi->n_x;i++) {
		fprintf(f,"%12.12f, ",x_0(jmi_opt_sim,i));
	}
	fprintf(f,"\n");
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			for (k=0;k<jmi->n_x;k++) {
				fprintf(f,"%12.12f, ",x_coll(jmi_opt_sim,i,j+1,k));
			}
			fprintf(f,"\n");
		}
	}
	fprintf(f,"];\n");

	// inputs
	fprintf(f,"u=[");
	for (i=0;i<jmi->n_u;i++) {
		fprintf(f,"%12.12f, ",u_0(jmi_opt_sim,i));
	}
	fprintf(f,"\n");
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			for (k=0;k<jmi->n_u;k++) {
				fprintf(f,"%12.12f, ",u_coll(jmi_opt_sim,i,j+1,k));
			}
			fprintf(f,"\n");
		}
	}
	fprintf(f,"];\n");

	// algebraics
	fprintf(f,"w=[");
	for (i=0;i<jmi->n_w;i++) {
		fprintf(f,"%12.12f, ",w_0(jmi_opt_sim,i));
	}
	fprintf(f,"\n");
	for (i=0;i<jmi_opt_sim->n_e;i++) {
		for (j=0;j<nlp->n_cp;j++) {
			for (k=0;k<jmi->n_u;k++) {
				fprintf(f,"%12.12f, ",w_coll(jmi_opt_sim,i,j+1,k));
			}
			fprintf(f,"\n");
		}
	}
	fprintf(f,"];\n");

	fclose(f);

	return 0;

}

int jmi_opt_sim_lp_radau_new(jmi_opt_sim_t **jmi_opt_sim, jmi_t *jmi, int n_e,
        jmi_real_t *hs, int hs_free,
        jmi_real_t *p_opt_init, jmi_real_t *dx_init, jmi_real_t *x_init,
        jmi_real_t *u_init, jmi_real_t *w_init,
        jmi_real_t *p_opt_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
        jmi_real_t *u_lb, jmi_real_t *w_lb, jmi_real_t t0_lb,
        jmi_real_t tf_lb, jmi_real_t *hs_lb,
        jmi_real_t *p_opt_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
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
    opt->offs_x_el_junc = opt->offs_dx_coll +
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
                          (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*(n_e*n_cp + 1) +   // Collocation variables + initial variables
                          jmi->n_x*n_e +                                        // States at element junctions
                          (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*jmi->n_tp;         // Pointwise values

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
    (*jmi_opt_sim)->n_h = jmi->n_dx + jmi->n_x + jmi->n_w + // Initial equations
    	                  (jmi->n_dx + jmi->n_w)*n_e*n_cp +     // Residual equations
                          jmi->n_x*n_e +                        // Continuity equations
                          jmi->n_x*n_e*n_cp +                    // Collocation equations
                          jmi->n_u +                                    // Interpolation for u_0
						  (jmi->n_dx + jmi->n_x  + jmi->n_u + jmi->n_w)*jmi->n_tp +      // Pointwise equations
                          jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1) +               // Path constraints from optimization
                          jmi->opt->Heq->n_eq_F;                // Point constraints from optimization

    // if free element lengths:
    // TODO: should be modeled explicitly in the Optimica code?
    // Add constraint sum(hs) = 1
    if (hs_free == 1) {
    	(*jmi_opt_sim)->n_h += 1;
    }

    // Number of inequality constraints

    (*jmi_opt_sim)->n_g = jmi->opt->Cineq->n_eq_F*(n_e*n_cp + 1) +               // Path inconstraints from optimization
                          jmi->opt->Hineq->n_eq_F;                    // Point inconstraints from optimization

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

	int dF0_n_nz, dF0_n_cols;
	jmi_init_dF0_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI | JMI_DER_DX | JMI_DER_X |
			         JMI_DER_U | JMI_DER_W, opt->der_mask,
			         &dF0_n_cols, &dF0_n_nz);
	opt->dF0_n_nz = dF0_n_nz;

	int dF_dp_n_nz, dF_ddx_dx_du_dw_n_nz, dF_dp_n_cols, dF_ddx_dx_du_dw_n_cols;
	jmi_dae_dF_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI, opt->der_mask,
			         &dF_dp_n_cols, &dF_dp_n_nz);

	jmi_dae_dF_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX | JMI_DER_X | JMI_DER_U |JMI_DER_W,
			         opt->der_mask, &dF_ddx_dx_du_dw_n_cols,
			         &dF_ddx_dx_du_dw_n_nz);
	opt->dF_dp_n_nz = dF_dp_n_nz;
	opt->dF_ddx_dx_du_dw_n_nz = dF_ddx_dx_du_dw_n_nz;

	int dCeq_dp_n_nz, dCeq_ddx_dx_du_dw_n_nz, dCeq_ddx_p_dx_p_du_p_dw_p_n_nz,
	    dCeq_dp_n_cols, dCeq_ddx_dx_du_dw_n_cols, dCeq_ddx_p_dx_p_du_p_dw_p_n_cols;
	jmi_opt_dCeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI, opt->der_mask,
			         &dCeq_dp_n_cols, &dCeq_dp_n_nz);
	jmi_opt_dCeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
			         opt->der_mask, &dCeq_ddx_dx_du_dw_n_cols, &dCeq_ddx_dx_du_dw_n_nz);
	jmi_opt_dCeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
			         opt->der_mask, &dCeq_ddx_p_dx_p_du_p_dw_p_n_cols, &dCeq_ddx_p_dx_p_du_p_dw_p_n_nz);
	opt->dCeq_dp_n_nz = dCeq_dp_n_nz;
	opt->dCeq_ddx_dx_du_dw_n_nz = dCeq_ddx_dx_du_dw_n_nz;
	opt->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz = dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;

	int dCineq_dp_n_nz, dCineq_ddx_dx_du_dw_n_nz, dCineq_ddx_p_dx_p_du_p_dw_p_n_nz,
	    dCineq_dp_n_cols, dCineq_ddx_dx_du_dw_n_cols, dCineq_ddx_p_dx_p_du_p_dw_p_n_cols;
	jmi_opt_dCineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI, opt->der_mask,
			         &dCineq_dp_n_cols, &dCineq_dp_n_nz);
	jmi_opt_dCineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
			         opt->der_mask, &dCineq_ddx_dx_du_dw_n_cols, &dCineq_ddx_dx_du_dw_n_nz);
	jmi_opt_dCineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
			         opt->der_mask, &dCineq_ddx_p_dx_p_du_p_dw_p_n_cols, &dCineq_ddx_p_dx_p_du_p_dw_p_n_nz);
	opt->dCineq_dp_n_nz = dCineq_dp_n_nz;
	opt->dCineq_ddx_dx_du_dw_n_nz = dCineq_ddx_dx_du_dw_n_nz;
	opt->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz = dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;

	int dHeq_dp_n_nz, dHeq_ddx_p_dx_p_du_p_dw_p_n_nz,
	    dHeq_dp_n_cols, dHeq_ddx_p_dx_p_du_p_dw_p_n_cols;
	jmi_opt_dHeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI, opt->der_mask,
			         &dHeq_dp_n_cols, &dHeq_dp_n_nz);
	jmi_opt_dHeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
			         opt->der_mask, &dHeq_ddx_p_dx_p_du_p_dw_p_n_cols, &dHeq_ddx_p_dx_p_du_p_dw_p_n_nz);
	opt->dHeq_dp_n_nz = dHeq_dp_n_nz;
	opt->dHeq_ddx_p_dx_p_du_p_dw_p_n_nz = dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;

	int dHineq_dp_n_nz, dHineq_ddx_p_dx_p_du_p_dw_p_n_nz,
	    dHineq_dp_n_cols, dHineq_ddx_p_dx_p_du_p_dw_p_n_cols;
	jmi_opt_dHineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_PI, opt->der_mask,
			         &dHineq_dp_n_cols, &dHineq_dp_n_nz);
	jmi_opt_dHineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
			         JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
			         opt->der_mask, &dHineq_ddx_p_dx_p_du_p_dw_p_n_cols, &dHineq_ddx_p_dx_p_du_p_dw_p_n_nz);
	opt->dHineq_dp_n_nz = dHineq_dp_n_nz;
	opt->dHineq_ddx_p_dx_p_du_p_dw_p_n_nz = dHineq_ddx_p_dx_p_du_p_dw_p_n_nz;

	(*jmi_opt_sim)->dg_n_nz = (dCineq_dp_n_nz + dCineq_ddx_dx_du_dw_n_nz +
		dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*(n_e*n_cp+1) + //  Inequality path constraints
        (dHineq_dp_n_nz + dHineq_ddx_p_dx_p_du_p_dw_p_n_nz); // Inequality point constraints
	(*jmi_opt_sim)->dg_row = (int*)calloc((*jmi_opt_sim)->dg_n_nz,sizeof(int));
	(*jmi_opt_sim)->dg_col = (int*)calloc((*jmi_opt_sim)->dg_n_nz,sizeof(int));

	(*jmi_opt_sim)->dh_n_nz = dF0_n_nz +           // Initial equations
	                          (dF_dp_n_nz + dF_ddx_dx_du_dw_n_nz)*n_e*n_cp +   // Dynamic residuals
	                          2*jmi->n_x*n_e +     // Continuity equations
	                          jmi->n_u*(n_cp + 1)  + // Interpolation of u_0
	                          (jmi->n_x*(n_cp+1) + jmi->n_dx)*n_e*n_cp + // Collocation equations
	                          ((jmi->n_x+jmi->n_dx)*(n_cp+1) +jmi->n_x + jmi->n_dx+  // Time points
	                          (jmi->n_u + jmi->n_w)*(n_cp) + jmi->n_u + jmi->n_w)*jmi->n_tp +
	                          (dCeq_dp_n_nz + dCeq_ddx_dx_du_dw_n_nz + // Equality path constraints
	                           		dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*(n_e*n_cp+1) +
	                                (dHeq_dp_n_nz + dHeq_ddx_p_dx_p_du_p_dw_p_n_nz); // Equality point constraints
	(*jmi_opt_sim)->dh_row = (int*)calloc((*jmi_opt_sim)->dh_n_nz,sizeof(int));
	(*jmi_opt_sim)->dh_col = (int*)calloc((*jmi_opt_sim)->dh_n_nz,sizeof(int));

	printf("%x\n",(int)(*jmi_opt_sim)->dh_row);

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

	int *dCeq_dp_irow = (int*)calloc(dCeq_dp_n_nz,sizeof(int));
	int *dCeq_dp_icol = (int*)calloc(dCeq_dp_n_nz,sizeof(int));
	jmi_opt_dCeq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_PI, opt->der_mask, dCeq_dp_irow,dCeq_dp_icol);

	int *dCeq_ddx_dx_du_dw_irow = (int*)calloc(dCeq_ddx_dx_du_dw_n_nz,sizeof(int));
	int *dCeq_ddx_dx_du_dw_icol = (int*)calloc(dCeq_ddx_dx_du_dw_n_nz,sizeof(int));
	jmi_opt_dCeq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX | JMI_DER_X |
	         JMI_DER_U | JMI_DER_W, opt->der_mask,
	         dCeq_ddx_dx_du_dw_irow,dCeq_ddx_dx_du_dw_icol);

	int *dCeq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dCeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	int *dCeq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dCeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	jmi_opt_dCeq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX_P | JMI_DER_X_P |
	         JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
	         dCeq_ddx_p_dx_p_du_p_dw_p_irow,dCeq_ddx_p_dx_p_du_p_dw_p_icol);

	int *dCineq_dp_irow = (int*)calloc(dCineq_dp_n_nz,sizeof(int));
	int *dCineq_dp_icol = (int*)calloc(dCineq_dp_n_nz,sizeof(int));
	jmi_opt_dCineq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_PI, opt->der_mask, dCineq_dp_irow,dCineq_dp_icol);

	int *dCineq_ddx_dx_du_dw_irow = (int*)calloc(dCineq_ddx_dx_du_dw_n_nz,sizeof(int));
	int *dCineq_ddx_dx_du_dw_icol = (int*)calloc(dCineq_ddx_dx_du_dw_n_nz,sizeof(int));
	jmi_opt_dCineq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX | JMI_DER_X |
	         JMI_DER_U | JMI_DER_W, opt->der_mask,
	         dCineq_ddx_dx_du_dw_irow,dCineq_ddx_dx_du_dw_icol);

	int *dCineq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dCineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	int *dCineq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dCineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	jmi_opt_dCineq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX_P | JMI_DER_X_P |
	         JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
	         dCineq_ddx_p_dx_p_du_p_dw_p_irow,dCineq_ddx_p_dx_p_du_p_dw_p_icol);

	int *dHeq_dp_irow = (int*)calloc(dHeq_dp_n_nz,sizeof(int));
	int *dHeq_dp_icol = (int*)calloc(dHeq_dp_n_nz,sizeof(int));
	jmi_opt_dHeq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_PI, opt->der_mask, dHeq_dp_irow,dHeq_dp_icol);

	int *dHeq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dHeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	int *dHeq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dHeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	jmi_opt_dHeq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX_P | JMI_DER_X_P |
	         JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
	         dHeq_ddx_p_dx_p_du_p_dw_p_irow,dHeq_ddx_p_dx_p_du_p_dw_p_icol);


	int *dHineq_dp_irow = (int*)calloc(dHineq_dp_n_nz,sizeof(int));
	int *dHineq_dp_icol = (int*)calloc(dHineq_dp_n_nz,sizeof(int));
	jmi_opt_dHineq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_PI, opt->der_mask, dHineq_dp_irow,dHineq_dp_icol);

	int *dHineq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dHineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	int *dHineq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dHineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
	jmi_opt_dHineq_nz_indices(jmi,opt->der_eval_alg,
	         JMI_DER_DX_P | JMI_DER_X_P |
	         JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
	         dHineq_ddx_p_dx_p_du_p_dw_p_irow,dHineq_ddx_p_dx_p_du_p_dw_p_icol);


	for (i=0;i<dF0_n_nz;i++) {
		printf("> %d, %d\n", dF0_irow[i], dF0_icol[i]);
	}
	for (i=0;i<dF_dp_n_nz;i++) {
		printf(">> %d, %d\n", dF_dp_irow[i], dF_dp_icol[i]);
	}
	for (i=0;i<dF_ddx_dx_du_dw_n_nz;i++) {
		printf(">>> %d, %d\n", dF_ddx_dx_du_dw_irow[i], dF_ddx_dx_du_dw_icol[i]);
	}

	for (i=0;i<dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
		printf(">>>>Heq %d, %d\n", dHeq_ddx_p_dx_p_du_p_dw_p_irow[i], dHeq_ddx_p_dx_p_du_p_dw_p_icol[i]);
	}

	int row_index = 0;
	int col_index = 0;
	int rc_ind = 0;

	/***********************************************
	 * Sparsity for inequality constraint Jacobian
	 ***********************************************/

	// Sparsity indices for dCineq: variables at initial time
	// Parameters
	for (i=0;i<dCineq_dp_n_nz;i++) {
		(*jmi_opt_sim)->dg_row[rc_ind] = dCineq_dp_irow[i] + row_index;
		(*jmi_opt_sim)->dg_col[rc_ind] = dCineq_dp_icol[i] + col_index;
		rc_ind++;
	}

	// Variables at collocation points
	col_index = opt->offs_dx_0;
	for (i=0;i<dCineq_ddx_dx_du_dw_n_nz;i++) {
		(*jmi_opt_sim)->dg_row[rc_ind] = dCineq_ddx_dx_du_dw_irow[i] + row_index;
		(*jmi_opt_sim)->dg_col[rc_ind] = dCineq_ddx_dx_du_dw_icol[i] + col_index;
		rc_ind++;
	}

	// Variables at interpolation points
	col_index = opt->offs_dx_p;
	for (i=0;i<dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
		(*jmi_opt_sim)->dg_row[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_irow[i] + row_index;
		(*jmi_opt_sim)->dg_col[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_icol[i] + col_index;
		rc_ind++;
	}

	// Sparsity for dCineq: collocation equations
	for (i=0;i<n_e*n_cp;i++) {
		row_index = jmi->opt->Cineq->n_eq_F + jmi->opt->Cineq->n_eq_F*i;
		col_index = 0;
		for (k=0;k<dCineq_dp_n_nz;k++) {
			(*jmi_opt_sim)->dg_row[rc_ind] = dCineq_dp_irow[k] + row_index;
			(*jmi_opt_sim)->dg_col[rc_ind] = dCineq_dp_icol[k] + col_index;
			rc_ind++;
		}

		col_index = opt->offs_dx_coll + dCineq_ddx_dx_du_dw_n_cols*i;
		for (k=0;k<dCineq_ddx_dx_du_dw_n_nz;k++) {
			(*jmi_opt_sim)->dg_row[rc_ind] = dCineq_ddx_dx_du_dw_irow[k] + row_index;
			(*jmi_opt_sim)->dg_col[rc_ind] = dCineq_ddx_dx_du_dw_icol[k] + col_index;
			rc_ind++;
		}

		col_index = opt->offs_dx_p + dCineq_ddx_p_dx_p_du_p_dw_p_n_cols;
		for (k=0;k<dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;k++) {
			(*jmi_opt_sim)->dg_row[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_irow[k] + row_index;
			(*jmi_opt_sim)->dg_col[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_icol[k] + col_index;
			rc_ind++;
		}
	}

	// Sparsity for Hineq
	row_index = jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1);
	col_index = 0;
	// Parameters
	for (j=0;j<dHineq_dp_n_nz;j++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dHineq_dp_irow[j] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dHineq_dp_icol[j] + col_index;
		rc_ind++;
	}

	// Variables at interpolation points
	col_index = opt->offs_dx_p;
	for (j=0;j<dHineq_ddx_p_dx_p_du_p_dw_p_n_nz;j++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dHineq_ddx_p_dx_p_du_p_dw_p_irow[j] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dHineq_ddx_p_dx_p_du_p_dw_p_icol[j] + col_index;
		rc_ind++;
	}


	/**********************************************
	 * Sparsity for equality constraint Jacobian
	 **********************************************/
	row_index = 0;
	col_index = 0;
	rc_ind = 0;

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

	// Sparsity for u_0 interpolation equation

	row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_x*n_e;
	for (i=0;i<n_cp;i++) {
		col_index = dF0_n_cols + dF_ddx_dx_du_dw_n_cols*i + jmi->n_dx + jmi->n_x;
		for (j=0;j<jmi->n_u;j++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + col_index;
			rc_ind++;
		}
	}
	col_index = jmi->opt->n_p_opt + jmi->n_dx + jmi->n_x;
	for (j=0;j<jmi->n_u;j++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + col_index;
		rc_ind++;
	}



	// Sparsity for collocation equations
	// Take care of the first point separately
	for (i=0;i<n_cp;i++) {
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_u + jmi->n_x*n_e +
		            jmi->n_x*i;

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

		// Elements corresponding to x_{0,0}
		for (j=0;j<jmi->n_x;j++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = j + 1 + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_dx;
			rc_ind++;
		}


	}

	// Take care of the remaining elements
	for (l=1;l<n_e;l++) {
		for (i=0;i<n_cp;i++) {
			row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_u + jmi->n_x*n_e +
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
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_u + jmi->n_x*n_e +
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


	// Sparsity indices for dCeq: variables at initial time
	row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_u + jmi->n_x*n_e +
	  jmi->n_x*n_e*n_cp + (jmi->n_x + jmi->n_dx + jmi->n_u + jmi->n_w)*jmi->n_tp;
	col_index = 0;
	// Parameters
	for (i=0;i<dCeq_dp_n_nz;i++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dCeq_dp_irow[i] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dCeq_dp_icol[i] + col_index;
		rc_ind++;
	}

	// Variables at collocation points
	col_index = opt->offs_dx_0;
	for (i=0;i<dCeq_ddx_dx_du_dw_n_nz;i++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dCeq_ddx_dx_du_dw_irow[i] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dCeq_ddx_dx_du_dw_icol[i] + col_index;
		rc_ind++;
	}

	// Variables at interpolation points
	col_index = opt->offs_dx_p;
	for (i=0;i<dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_irow[i] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_icol[i] + col_index;
		rc_ind++;
	}

	// Sparsity for dCeq: collocation equations
	for (i=0;i<n_e*n_cp;i++) {
		row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_u + jmi->n_x*n_e +
		  jmi->n_x*n_e*n_cp + (jmi->n_x + jmi->n_dx + jmi->n_u + jmi->n_w)*jmi->n_tp +
		  jmi->opt->Ceq->n_eq_F + jmi->opt->Ceq->n_eq_F*i;

		col_index = 0;
		for (k=0;k<dCeq_dp_n_nz;k++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = dCeq_dp_irow[k] + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = dCeq_dp_icol[k] + col_index;
			rc_ind++;
		}

		col_index = opt->offs_dx_coll + dCeq_ddx_dx_du_dw_n_cols*i;
		for (k=0;k<dCeq_ddx_dx_du_dw_n_nz;k++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = dCeq_ddx_dx_du_dw_irow[k] + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = dCeq_ddx_dx_du_dw_icol[k] + col_index;
			rc_ind++;
		}

		col_index = opt->offs_dx_p + dCeq_ddx_p_dx_p_du_p_dw_p_n_cols;
		for (k=0;k<dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;k++) {
			(*jmi_opt_sim)->dh_row[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_irow[k] + row_index;
			(*jmi_opt_sim)->dh_col[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_icol[k] + col_index;
			rc_ind++;
		}
	}

	// Sparsity for Heq
	row_index = jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*n_e*n_cp + jmi->n_u + jmi->n_x*n_e +
	   jmi->n_x*n_e*n_cp + (jmi->n_x + jmi->n_dx + jmi->n_u + jmi->n_w)*jmi->n_tp +
	   jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1);

	col_index = 0;
	// Parameters
	for (j=0;j<dHeq_dp_n_nz;j++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dHeq_dp_irow[j] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dHeq_dp_icol[j] + col_index;
		rc_ind++;
	}

	// Variables at interpolation points
	col_index = opt->offs_dx_p;
	for (j=0;j<dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;j++) {
		(*jmi_opt_sim)->dh_row[rc_ind] = dHeq_ddx_p_dx_p_du_p_dw_p_irow[j] + row_index;
		(*jmi_opt_sim)->dh_col[rc_ind] = dHeq_ddx_p_dx_p_du_p_dw_p_icol[j] + col_index;
		rc_ind++;
	}




	FILE *f = fopen("sparsity.m","wt");

	fprintf(f,"n_x=%d;\n",jmi->n_x);
	fprintf(f,"n_u=%d;\n",jmi->n_u);
	fprintf(f,"n_w=%d;\n",jmi->n_w);
	fprintf(f,"n_tp=%d\n",jmi->n_tp);
	fprintf(f,"n_p_opt=%d\n",jmi->opt->n_p_opt);
	fprintf(f,"n_eq_Ceq=%d\n",jmi->opt->Ceq->n_eq_F);
	fprintf(f,"n_eq_Cineq=%d\n",jmi->opt->Cineq->n_eq_F);
	fprintf(f,"n_eq_Heq=%d\n",jmi->opt->Heq->n_eq_F);
	fprintf(f,"n_eq_Hineq=%d\n",jmi->opt->Hineq->n_eq_F);
	fprintf(f,"n_e=%d;\n",n_e);
	fprintf(f,"n_cp=%d;\n",n_cp);
	fprintf(f,"n_eq_F0=%d\n",jmi->init->F0->n_eq_F);
	fprintf(f,"n_eq_F=%d\n",jmi->dae->F->n_eq_F);
	fprintf(f,"dF0_n_cols=%d\n",dF0_n_cols);
	fprintf(f,"dF_dp_n_cols=%d\n",dF_dp_n_cols);
	fprintf(f,"dF_ddx_dx_du_dw_n_cols=%d\n",dF_ddx_dx_du_dw_n_cols);

	fprintf(f,"dCeq_dp_n_cols=%d\n",dCeq_dp_n_cols);
	fprintf(f,"dCeq_ddx_dx_du_dw_n_cols=%d\n",dCeq_ddx_dx_du_dw_n_cols);
	fprintf(f,"dCeq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dCeq_ddx_p_dx_p_du_p_dw_p_n_cols);
	fprintf(f,"dCeq_dp_n_nz=%d\n",dCeq_dp_n_nz);
	fprintf(f,"dCeq_ddx_dx_du_dw_n_nz=%d\n",dCeq_ddx_dx_du_dw_n_nz);
	fprintf(f,"dCeq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dCeq_ddx_p_dx_p_du_p_dw_p_n_nz);

	fprintf(f,"dCineq_dp_n_cols=%d\n",dCineq_dp_n_cols);
	fprintf(f,"dCineq_ddx_dx_du_dw_n_cols=%d\n",dCineq_ddx_dx_du_dw_n_cols);
	fprintf(f,"dCineq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dCineq_ddx_p_dx_p_du_p_dw_p_n_cols);
	fprintf(f,"dCineq_dp_n_nz=%d\n",dCineq_dp_n_nz);
	fprintf(f,"dCineq_ddx_dx_du_dw_n_nz=%d\n",dCineq_ddx_dx_du_dw_n_nz);
	fprintf(f,"dCineq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dCineq_ddx_p_dx_p_du_p_dw_p_n_nz);

	fprintf(f,"dHeq_dp_n_cols=%d\n",dHeq_dp_n_cols);
	fprintf(f,"dHeq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dHeq_ddx_p_dx_p_du_p_dw_p_n_cols);
	fprintf(f,"dHeq_dp_n_nz=%d\n",dHeq_dp_n_nz);
	fprintf(f,"dHeq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dHeq_ddx_p_dx_p_du_p_dw_p_n_nz);

	fprintf(f,"dHineq_dp_n_cols=%d\n",dHineq_dp_n_cols);
	fprintf(f,"dHineq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dHineq_ddx_p_dx_p_du_p_dw_p_n_cols);
	fprintf(f,"dHineq_dp_n_nz=%d\n",dHineq_dp_n_nz);
	fprintf(f,"dHineq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dHineq_ddx_p_dx_p_du_p_dw_p_n_nz);


	fprintf(f,"ind_dg=[");
	for (i=0;i<(*jmi_opt_sim)->dg_n_nz;i++) {
		fprintf(f,"%d %d %d;\n",i+1,(*jmi_opt_sim)->dg_row[i],(*jmi_opt_sim)->dg_col[i]);
	}
	fprintf(f,"];\n");
	fprintf(f,"ind_dh=[");
	for (i=0;i<(*jmi_opt_sim)->dh_n_nz;i++) {
		fprintf(f,"%d %d %d;\n",i+1,(*jmi_opt_sim)->dh_row[i],(*jmi_opt_sim)->dh_col[i]);
	}
	fprintf(f,"];\n");
	fprintf(f,"plotSparsityLP(n_x,n_u,n_w,n_p_opt,n_tp,n_eq_Ceq,n_eq_Cineq,n_eq_Heq,n_eq_Hineq,n_e,n_cp,n_eq_F0, \
			  n_eq_F, dF0_n_cols,dF_dp_n_cols,dF_ddx_dx_du_dw_n_cols, \
			  dCeq_dp_n_cols,dCeq_ddx_dx_du_dw_n_cols,dCeq_ddx_p_dx_p_du_p_dw_p_n_cols, \
			  dCineq_dp_n_cols,dCineq_ddx_dx_du_dw_n_cols,dCineq_ddx_p_dx_p_du_p_dw_p_n_cols, \
			  dHeq_dp_n_cols,dHeq_ddx_p_dx_p_du_p_dw_p_n_cols, \
			  dHineq_dp_n_cols,dHineq_ddx_p_dx_p_du_p_dw_p_n_cols, \
              ind_dg,ind_dh,1)");
	fclose(f);

	// Set the bounds vector

	// Bounds for optimization parameters
	int offs = 0;
	for (i=0;i<jmi->opt->n_p_opt;i++) {
    	(*jmi_opt_sim)->x_lb[i] = p_opt_lb[i];
    	(*jmi_opt_sim)->x_ub[i] = p_opt_ub[i];
    	(*jmi_opt_sim)->x_init[i] = p_opt_init[i];
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
	(*jmi_opt_sim)->write_file_matlab = *lp_radau_write_file_matlab;

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


