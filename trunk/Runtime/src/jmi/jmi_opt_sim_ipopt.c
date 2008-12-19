
#include "jmi_opt_sim_ipopt.h"

static int jmi_opt_sim_ipopt_f(Index n, Number* x, Bool new_x,
			  Number *f, UserDataPtr data) {

	int i;
	jmi_opt_sim_ipopt_t *nlp = (jmi_opt_sim_ipopt_t*)data;

	for (i=0;i<nlp->n;i++) {
		nlp->x[i] = x[i];
	}

	if (jmi_opt_sim_f(nlp->jmi_opt_sim, f) == 0) {
		return TRUE;
	} else {
		return FALSE;
	}

}

static int jmi_opt_sim_ipopt_df(Index n, Number* x, Bool new_x,
			       Number* df, UserDataPtr data) {
/*
  return problem_->evalGradCost((const double*)x, (double*) grad_f);
*/
	return 0;
}

static int jmi_opt_sim_ipopt_g(Index n, Number* x, Bool new_x,
			  Index m, Number* g, UserDataPtr data) {
/*
//	  std::cout << "jmi_opt_sim_ipopt_ipopt_eval_g begin" << std::endl;
  int retval = problem_->evalEqConstraint((const double*)x, (double*)g);
  if (retval) {
    double* gin = g + n_eq_;
    retval = problem_->evalIneqConstraint((const double*)x, (double*)gin);
    }
//  std::cout << "jmi_opt_sim_ipopt_ipopt_eval_g end" << std::endl;
  return retval;
*/

	return 0;
}

static int jmi_opt_sim_ipopt_dg(Index n, Number* x, Bool new_x,
			      Index m, Index dg_n_nz, Index* irow,
			      Index *icol, Number* dg, UserDataPtr data) {

	/*
//	std::cout << "jmi_opt_sim_ipopt_ipopt_eval_jac_g enter\n";
  int retval = -1;
  if (values == NULL) {
//		std::cout << "jmi_opt_sim_ipopt_ipopt_eval_jac_g enter computing sparsity\n";

    retval = problem_->getJacEqConstraintNzElements(iRow,jCol);

    if (retval) {
      iRow += nnz_jac_eq_;
      jCol += nnz_jac_eq_;
      retval = problem_->getJacIneqConstraintNzElements(iRow, jCol);
    }

  }
  else {
//		std::cout << "jmi_opt_sim_ipopt_ipopt_eval_jac_g enter computing jac_g \n";
    retval = problem_->evalJacEqConstraint((const double*)x, (double*)values);
    if (retval) {
      values += nnz_jac_eq_;
      retval = problem_->evalJacIneqConstraint((const double*)x, (double*)values);
    }

  }
  //std::cout << "jmi_opt_sim_ipopt_ipopt_eval_jac_g exit\n";
  return retval;
*/
	return 0;
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

	nlp->n = jmi_opt_sim->n_x;
	nlp->m = jmi_opt_sim->n_g + jmi_opt_sim->n_h;
	nlp->dg_n_nz = jmi_opt_sim->dg_n_nz + jmi_opt_sim->dh_n_nz;
	nlp->hess_lag_n_nz = 0;

	nlp->dg_row = (Index*)calloc(nlp->m,sizeof(Index));
	nlp->dg_col = (Index*)calloc(nlp->m,sizeof(Index));
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
