
#include "jmi_opt_sim_ipopt.h"

static int jmi_opt_sim_ipopt_f(Index n, Number* x, Bool new_x,
			  Number *f, UserDataPtr data) {

	int i;
	jmi_opt_sim_ipopt_t *nlp = (jmi_opt_sim_ipopt_t*)data;

	for (i=0;i<nlp->n;i++) {
		nlp->jmi_opt_sim->x[i] = x[i];
	}

	if (jmi_opt_sim_f(nlp->jmi_opt_sim, f) == 0) {
		return TRUE;
	} else {
		return FALSE;
	}

}

static int jmi_opt_sim_ipopt_df(Index n, Number* x, Bool new_x,
			       Number* df, UserDataPtr data) {

	int i;
	jmi_opt_sim_ipopt_t *nlp = (jmi_opt_sim_ipopt_t*)data;

	for (i=0;i<n;i++) {
		df[i] = 0;
	}

	for (i=0;i<nlp->n;i++) {
		nlp->jmi_opt_sim->x[i] = x[i];
	}

	if (jmi_opt_sim_df(nlp->jmi_opt_sim, df) == 0) {
		return TRUE;
	} else {
		return FALSE;
	}
}

static int jmi_opt_sim_ipopt_g(Index n, Number* x, Bool new_x,
			  Index m, Number* g, UserDataPtr data) {

	int i, retval;
	jmi_opt_sim_ipopt_t *nlp = (jmi_opt_sim_ipopt_t*)data;

	for (i=0;i<m;i++) {
		g[i] = 0;
	}

	for (i=0;i<nlp->n;i++) {
		nlp->jmi_opt_sim->x[i] = x[i];
	}

	retval = jmi_opt_sim_g(nlp->jmi_opt_sim, g);
	if (retval!=0) {
		return FALSE;
	}
	g += nlp->jmi_opt_sim->n_g;
	retval = jmi_opt_sim_h(nlp->jmi_opt_sim, g);
	if (retval!=0) {
		return FALSE;
	}
	return TRUE;
}

static int jmi_opt_sim_ipopt_dg(Index n, Number* x, Bool new_x,
			      Index m, Index dg_n_nz, Index* irow,
			      Index *icol, Number* dg, UserDataPtr data) {

	int i, retval;
	jmi_opt_sim_ipopt_t *nlp = (jmi_opt_sim_ipopt_t*)data;

	if (dg == NULL) {
		retval = jmi_opt_sim_dg_nz_indices(nlp->jmi_opt_sim, irow, icol);
		if (retval!=0) {
			return FALSE;
		}
		irow += nlp->jmi_opt_sim->dg_n_nz;
		icol += nlp->jmi_opt_sim->dg_n_nz;
		retval = jmi_opt_sim_dh_nz_indices(nlp->jmi_opt_sim, irow, icol);

		for(i=0;i<nlp->jmi_opt_sim->dh_n_nz;i++) {
			irow[i] += nlp->jmi_opt_sim->dg_n_nz;
		}

		irow -= nlp->jmi_opt_sim->dg_n_nz;
		icol -= nlp->jmi_opt_sim->dg_n_nz;

		if (retval!=0) {
			return FALSE;
		}
		return TRUE;
	} else {
		for (i=0;i<dg_n_nz;i++) {
			dg[i] = 0;
		}
		for (i=0;i<nlp->n;i++) {
			nlp->jmi_opt_sim->x[i] = x[i];
		}
		retval = jmi_opt_sim_dg(nlp->jmi_opt_sim, dg);
		if (retval!=0) {
			return FALSE;
		}
		dg += nlp->jmi_opt_sim->dg_n_nz;
		retval = jmi_opt_sim_dh(nlp->jmi_opt_sim, dg);
		if (retval!=0) {
			return FALSE;
		}
		return TRUE;
	}
}

static int jmi_opt_sim_ipopt_hess_lag(Index n, Number *x, Bool new_x, Number obj_factor,
                            Index m, Number *lambda, Bool new_lambda,
                            Index nele_hess, Index *iRow, Index *jCol,
                            Number *values, UserDataPtr user_data) {
	return TRUE;
}



int jmi_opt_sim_ipopt_new(jmi_opt_sim_ipopt_t **jmi_opt_sim_ipopt, jmi_opt_sim_t *jmi_opt_sim) {

	int i;

	jmi_opt_sim_ipopt_t* nlp = (jmi_opt_sim_ipopt_t*)calloc(1,sizeof(jmi_opt_sim_ipopt_t));
	*jmi_opt_sim_ipopt = nlp;

	nlp->jmi_opt_sim = jmi_opt_sim;

	nlp->n = jmi_opt_sim->n_x;
	nlp->m = jmi_opt_sim->n_g + jmi_opt_sim->n_h;

	nlp->dg_n_nz = jmi_opt_sim->dg_n_nz + jmi_opt_sim->dh_n_nz;
	nlp->hess_lag_n_nz = 0;

	nlp->dg_row = (Index*)calloc(nlp->dg_n_nz,sizeof(Index));
	nlp->dg_col = (Index*)calloc(nlp->dg_n_nz,sizeof(Index));
	nlp->g_lb = (jmi_real_t*)calloc(nlp->m,sizeof(jmi_real_t));
	nlp->g_ub = (jmi_real_t*)calloc(nlp->m,sizeof(jmi_real_t));

	nlp->g = (jmi_real_t*)calloc(nlp->m,sizeof(jmi_real_t));
	nlp->mult_g = (jmi_real_t*)calloc(nlp->m,sizeof(jmi_real_t));
	nlp->mult_x_lb = (jmi_real_t*)calloc(nlp->n,sizeof(jmi_real_t));
	nlp->mult_x_ub = (jmi_real_t*)calloc(nlp->n,sizeof(jmi_real_t));

	for (i=0;i<jmi_opt_sim->n_g;i++) {
		nlp->dg_row[i] = jmi_opt_sim->dg_row[i];
		nlp->dg_col[i] = jmi_opt_sim->dg_col[i];
		nlp->g_lb[i] = -JMI_INF;
		nlp->g_ub[i] = 0;
	}
	for (i=jmi_opt_sim->n_g;i<jmi_opt_sim->n_g +jmi_opt_sim->n_h;i++) {
		nlp->dg_row[i] = jmi_opt_sim->dh_row[i-jmi_opt_sim->n_g];
		nlp->dg_col[i] = jmi_opt_sim->dh_col[i-jmi_opt_sim->n_g];
		nlp->g_lb[i] = 0;
		nlp->g_ub[i] = 0;
	}

	Index index_style = 1; // Fortran style indexing.

	nlp->nlp = CreateIpoptProblem(nlp->n, jmi_opt_sim->x_lb, jmi_opt_sim->x_ub,
			                       nlp->m, nlp->g_lb, nlp->g_ub, nlp->dg_n_nz, nlp->hess_lag_n_nz,
	                               index_style, &jmi_opt_sim_ipopt_f,
	                               &jmi_opt_sim_ipopt_g, &jmi_opt_sim_ipopt_df,
	                               &jmi_opt_sim_ipopt_dg, &jmi_opt_sim_ipopt_hess_lag);

 //   AddIpoptIntOption(nlp->nlp, "print_level", 10);

	AddIpoptIntOption(nlp->nlp, "max_iter",100);
//    AddIpoptStrOption(nlp->nlp, "derivative_test","first-order");
//	AddIpoptNumOption(nlp->nlp, "derivative_test_pertubation",1e-6);
    //    AddIpoptStrOption(nlp->nlp, "derivative_test_print_all","yes");
	AddIpoptStrOption(nlp->nlp, "output_file", "ipopt.out");
	AddIpoptStrOption(nlp->nlp, "hessian_approximation", "limited-memory");

	return 0;

}

int jmi_opt_sim_ipopt_solve(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt) {
	int i;
	// Copy initial guess into x
	for (i=0;i<jmi_opt_sim_ipopt->jmi_opt_sim->n_x;i++) {
		jmi_opt_sim_ipopt->jmi_opt_sim->x[i] = jmi_opt_sim_ipopt->jmi_opt_sim->x_init[i];
	}


	jmi_opt_sim_ipopt->status = IpoptSolve(jmi_opt_sim_ipopt->nlp,
			                               jmi_opt_sim_ipopt->jmi_opt_sim->x,
			                               jmi_opt_sim_ipopt->g,
			                               &jmi_opt_sim_ipopt->objective,
			                               jmi_opt_sim_ipopt->mult_g,
			                               jmi_opt_sim_ipopt->mult_x_lb,
			                               jmi_opt_sim_ipopt->mult_x_ub,
			                               jmi_opt_sim_ipopt);

	return 0;

}



/*
int jmi_opt_sim_ipopt_get_starting_point(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, Index n, int init_x, Number* x,
				      int init_z, Number* z_L, Number* z_U,
				      Index m, int init_lambda,
				      Number* lambda) {

  return jmi_opt_sim_get_initial(x);

}

*/
