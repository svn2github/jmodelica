// Copyright (C) 2009 Modelon AB
// All Rights reserved
// This file is published under the Common Public License 1.0.



#include "jmi_init_opt_TNLP.hpp"
#include "jmi_init_opt.h"

#include <iostream>


jmi_init_opt_TNLP::jmi_init_opt_TNLP(jmi_init_opt_t* problem)
  :
  problem_(problem),
  n_(0),
  n_h_(0),
  dh_n_nz_(0)
{
  ASSERT_EXCEPTION(problem_ != NULL, INVALID_TNLP,
		   "Null problem definition passed into jmi_init_opt_TNLP");
}

jmi_init_opt_TNLP::~jmi_init_opt_TNLP()
{
}

bool jmi_init_opt_TNLP::get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
				Index& nnz_h_lag, IndexStyleEnum& index_style)
{
  if (jmi_init_opt_get_dimensions(problem_, &n, &n_h_,
			&dh_n_nz_) < 0) {
	  return false;
  }
  n_ = n;
  m = n_h_;
  nnz_jac_g = dh_n_nz_;
  nnz_h_lag = 0;
  index_style = FORTRAN_STYLE;
  return true;
}

bool jmi_init_opt_TNLP::get_bounds_info(Index n, Number* x_l, Number* x_u,
				   Index m, Number* g_l, Number* g_u)
{
  DBG_ASSERT(n_h_ + n_g_ == m);
  DBG_ASSERT(sizeof(Number) == sizeof(double));
  DBG_ASSERT(sizeof(Index) == sizeof(int));

  for (int i=0; i<n_h_; i++) {
	  g_l[i] = 0;
  }

  for (int i=0; i<n_h_; i++) {
	 g_u[i] = 0;
  }

  if (jmi_init_opt_get_bounds(problem_, x_l, x_u) < 0) {
	  return false;
  }

  return true;

}

bool jmi_init_opt_TNLP::get_starting_point(Index n, bool init_x, Number* x,
				      bool init_z, Number* z_L, Number* z_U,
				      Index m, bool init_lambda,
				      Number* lambda)
{
  DBG_ASSERT(init_x == true && init_z == false && init_lambda == false);
  if (jmi_init_opt_get_initial(problem_, x) < 0) {
	  return false;
  }
  return true;
}

bool jmi_init_opt_TNLP::eval_f(Index n, const Number* x, bool new_x,
			  Number& obj_value)
{

	int i;

//	printf("eval_f\n");

	for (i=0;i<n_;i++) {
		problem_->x[i] = x[i];
	}

	if (jmi_init_opt_f(problem_, &obj_value) < 0) {
		return false;
	}

	return true;

}

bool jmi_init_opt_TNLP::eval_grad_f(Index n, const Number* x, bool new_x,
			       Number* grad_f)
{

	//printf("eval_df\n");

	int i;

	for (i=0;i<n_;i++) {
		grad_f[i] = 0;
	}

	for (i=0;i<n_;i++) {
		problem_->x[i] = x[i];
	}

	if (jmi_init_opt_df(problem_, grad_f) < 0) {
		return false;
	}
	return true;
}

bool jmi_init_opt_TNLP::eval_g(Index n, const Number* x, bool new_x,
			  Index m, Number* g)
{
	int i;

//	printf("eval_g\n");

	for (i=0;i<n_h_;i++) {
		g[i] = 0;
	}

	for (i=0;i<n_;i++) {
		problem_->x[i] = x[i];
	}

	if (jmi_init_opt_h(problem_, g) < 0) {
		return false;
	}

	return true;

}

bool jmi_init_opt_TNLP::eval_jac_g(Index n, const Number* x, bool new_x,
			      Index m, Index nele_jac, Index* iRow,
			      Index *jCol, Number* values)
{

	int i;

//	printf("eval_dg\n");

	if (values == NULL) {
		if (jmi_init_opt_dh_nz_indices(problem_, iRow, jCol) < 0) {
			return false;
		}

		return true;
	} else {
		for (i=0;i<dh_n_nz_;i++) {
			values[i] = 0;
		}
		for (i=0;i<n_;i++) {
			problem_->x[i] = x[i];
		}
		if (jmi_init_opt_dh(problem_, values) < 0) {
			return false;
		}
		return true;
	}

	return false;
}

void jmi_init_opt_TNLP::finalize_solution(SolverReturn status,
				     Index n, const Number* x, const Number* z_L, const Number* z_U,
				     Index m, const Number* g, const Number* lambda,
				     Number obj_value,
				     const IpoptData* ip_data,
				     IpoptCalculatedQuantities* ip_cq)
{
}

/*
Index jmi_init_opt_TNLP::get_number_of_nonlinear_variables() {

	return problem_->n_nonlinear_variables;
}

bool jmi_init_opt_TNLP::get_list_of_nonlinear_variables(Index num_nonlin_vars,
    Index* pos_nonlin_vars) {

	int i;
	for (i=0;i<num_nonlin_vars;i++) {
		pos_nonlin_vars[i] = problem_->non_linear_variables_indices[i];
	}

	return true;

}
*/
