// Copyright (C) 2009 Modelon AB
// All Rights reserved
// This file is published under the Common Public License 1.0.



#include "jmi_TNLP.hpp"
#include "jmi_opt_sim.h"

#include <iostream>


jmi_TNLP::jmi_TNLP(jmi_opt_sim_t* problem)
  :
  problem_(problem),
  n_(0),
  n_h_(0),
  n_g_(0),
  dh_n_nz_(0),
  dg_n_nz_(0)
{
  ASSERT_EXCEPTION(problem_ != NULL, INVALID_TNLP,
		   "Null problem definition passed into jmi_TNLP");

 // std::cout <<"Woohoo... Created one..." << std::endl;
}

jmi_TNLP::~jmi_TNLP()
{
}

bool jmi_TNLP::get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
				Index& nnz_h_lag, IndexStyleEnum& index_style)
{
 // std::cout << "In get_nlp_info\n";
  //if (!problem_->getDimensions(n, n_eq_, n_ineq_, dh_n_nz, dg_n_nz)) {
  //    return false;
  //}

  if (jmi_opt_sim_get_dimensions(problem_, &n, &n_g_, &n_h_,
			&dg_n_nz_, &dh_n_nz_) < 0) {
	  return false;
  }

  n_ = n;
  m = n_h_ + n_g_;
  nnz_jac_g = dh_n_nz_ + dg_n_nz_;
  nnz_h_lag = 0;
  index_style = FORTRAN_STYLE;

  //std::cout << "n: " << n << " m: " << m << " nnz_jac_g: " << nnz_jac_g << " nnz_h_lag: " << nnz_h_lag << std::endl;

  return true;
}

bool jmi_TNLP::get_bounds_info(Index n, Number* x_l, Number* x_u,
				   Index m, Number* g_l, Number* g_u)
{
 // std::cout << "In Get Bounds Info\n";
  DBG_ASSERT(n_h_ + n_g_ == m);
  DBG_ASSERT(sizeof(Number) == sizeof(double));
  DBG_ASSERT(sizeof(Index) == sizeof(int));

 // std::cout << "first\n";


  for (int i=0; i<n_h_; i++) {
	  g_l[i] = 0;
  }

 // std::cout << "second\n";
  for (int i=0; i<n_h_; i++) {
	 g_u[i] = 0;
  }

  for (int i=n_h_; i<n_h_ + n_g_; i++) {
	  g_l[i] = -1e20;
  }

 // std::cout << "second\n";
  for (int i=n_h_; i<n_h_ + n_g_; i++) {
	 g_u[i] = 0;
  }

  if (jmi_opt_sim_get_bounds(problem_, x_l, x_u) < 0) {
	  return false;
  }
//  bool retval = problem_->getBounds((double*)x_l, (double*)x_u);


 // std::cout << "third\n";
 /* for (int i=0; i<n; i++) {
    std::cout << x_l[i] << " <= x <= " << x_u[i] << std::endl;
  }
   */
  return true;

}

bool jmi_TNLP::get_starting_point(Index n, bool init_x, Number* x,
				      bool init_z, Number* z_L, Number* z_U,
				      Index m, bool init_lambda,
				      Number* lambda)
{
  DBG_ASSERT(init_x == true && init_z == false && init_lambda == false);
//  std::cout << "jmi_TNLP::get_starting_point\n";
  //return problem_->getInitial((double*)x);
  if (jmi_opt_sim_get_initial(problem_, x) < 0) {
	  return false;
  }
  return true;
}

/*
bool jmi_TNLP::get_constraints_linearity(Index m, LinearityType* const_types) {

	int i;
	std::cout << "jmi_TNLP::get_constraints_linearity" << std::endl;
	for(i=0;i<m;i++) {
		const_types[i] = NON_LINEAR;
	}

	for(i=1506;i<2423;i++) {
		const_types[i] = LINEAR;
	}

	return true;
}
*/

bool jmi_TNLP::eval_f(Index n, const Number* x, bool new_x,
			  Number& obj_value)
{
  //return problem_->evalCost((const double*)x, (double&)obj_value);
	int i;

	for (i=0;i<n_;i++) {
		problem_->x[i] = x[i];
	}

	if (jmi_opt_sim_f(problem_, &obj_value) < 0) {
		return false;
	}

	return true;

}

bool jmi_TNLP::eval_grad_f(Index n, const Number* x, bool new_x,
			       Number* grad_f)
{
  //return problem_->evalGradCost((const double*)x, (double*) grad_f);
	int i;

	for (i=0;i<n_;i++) {
		grad_f[i] = 0;
	}

	for (i=0;i<n_;i++) {
		problem_->x[i] = x[i];
	}

	if (jmi_opt_sim_df(problem_, grad_f) < 0) {
		return false;
	}
	return true;
}

bool jmi_TNLP::eval_g(Index n, const Number* x, bool new_x,
			  Index m, Number* g)
{
	int i;

	for (i=0;i<n_h_+n_g_;i++) {
		g[i] = 0;
	}

	for (i=0;i<n_;i++) {
		problem_->x[i] = x[i];
	}

	if (jmi_opt_sim_h(problem_, g) < 0) {
		return false;
	}

	g += problem_->n_h;
	if (jmi_opt_sim_g(problem_, g) < 0) {
		return false;
	}
	return true;
/*
	//	  std::cout << "jmi_TNLP::eval_g begin" << std::endl;
  bool retval = problem_->evalEqConstraint((const double*)x, (double*)g);
  if (retval) {
    double* gin = g + n_eq_;
    retval = problem_->evalIneqConstraint((const double*)x, (double*)gin);
    }
//  std::cout << "jmi_TNLP::eval_g end" << std::endl;
  return retval;
  */
}

bool jmi_TNLP::eval_jac_g(Index n, const Number* x, bool new_x,
			      Index m, Index nele_jac, Index* iRow,
			      Index *jCol, Number* values)
{

	int i;

	if (values == NULL) {
		if (jmi_opt_sim_dh_nz_indices(problem_, iRow, jCol) < 0) {
			return false;
		}

		iRow += problem_->dh_n_nz;
		jCol += problem_->dh_n_nz;
		if (jmi_opt_sim_dg_nz_indices(problem_, iRow, jCol) < 0) {
			return false;
		}

		for(i=0;i<problem_->dg_n_nz;i++) {
			iRow[i] += n_h_;
		}

		iRow -= problem_->dh_n_nz;
		jCol -= problem_->dh_n_nz;

		/*
		for (i=0;i<nele_jac;i++) {
			std::cout << "[" << iRow[i] << "," << jCol[i] << "]" << std::endl;
		}
*/
		return true;
	} else {
		for (i=0;i<dg_n_nz_;i++) {
			values[i] = 0;
		}
		for (i=0;i<n_;i++) {
			problem_->x[i] = x[i];
		}
		if (jmi_opt_sim_dh(problem_, values) < 0) {
			return false;
		}

		values += problem_->dh_n_nz;
		if (jmi_opt_sim_dg(problem_, values) < 0) {
			return false;
		}
		return true;
	}


	/*
//	std::cout << "jmi_TNLP::eval_jac_g enter\n";
  bool retval = false;
  if (values == NULL) {
//		std::cout << "jmi_TNLP::eval_jac_g enter computing sparsity\n";

    retval = problem_->getJacEqConstraintNzElements(iRow,jCol);
 */
 /*
    std::cout << "*" << std::endl;
    for (int i=0;i<dh_n_nz + dg_n_nz_;i++) {
    	std::cout << iRow[i] << " " << jCol[i] << std::endl;
    }
*/
	/*
    if (retval) {
      iRow += dh_n_nz;
      jCol += dh_n_nz;
      retval = problem_->getJacIneqConstraintNzElements(iRow, jCol);
    }
    */
/*
  iRow -= dh_n_nz;
    jCol -= dh_n_nz;

    std::cout << "**" << std::endl;
    for (int i=0;i<dh_n_nz + dg_n_nz_;i++) {
    	std::cout << iRow[i] << " " << jCol[i] << std::endl;
    }
 */
 /* }
  else {
//		std::cout << "jmi_TNLP::eval_jac_g enter computing jac_g \n";
    retval = problem_->evalJacEqConstraint((const double*)x, (double*)values);
    if (retval) {
      values += dh_n_nz;
      retval = problem_->evalJacIneqConstraint((const double*)x, (double*)values);
    }
    */
    /*
    values -= dh_n_nz;
    for (int i=0;i<dh_n_nz + dg_n_nz_;i++) {
    	std::cout << values[i] << std::endl;
    }
    */
 // }
  //std::cout << "jmi_TNLP::eval_jac_g exit\n";
  //return retval;
	return false;
}

void jmi_TNLP::finalize_solution(SolverReturn status,
				     Index n, const Number* x, const Number* z_L, const Number* z_U,
				     Index m, const Number* g, const Number* lambda,
				     Number obj_value,
				     const IpoptData* ip_data,
				     IpoptCalculatedQuantities* ip_cq)
{
  //std::cout << "<speech voice=\"robot\">Optimal profile calculated!</speech>" << std::endl;
 // problem_->writeSolution((double*)x);

}

/*
Index jmi_TNLP::get_number_of_nonlinear_variables() {
	return 12;//2725-1205 - 300;
}

bool jmi_TNLP::get_list_of_nonlinear_variables(Index num_nonlin_vars,
    Index* pos_nonlin_vars) {

	pos_nonlin_vars[0] = 5;
	pos_nonlin_vars[1] = 6;
	pos_nonlin_vars[2] = 7;
	pos_nonlin_vars[3] = 12;
	pos_nonlin_vars[4] = 13;
	pos_nonlin_vars[5] = 14;
	pos_nonlin_vars[6] = 19;
	pos_nonlin_vars[7] = 20;
	pos_nonlin_vars[8] = 21;
	pos_nonlin_vars[9] = 26;
	pos_nonlin_vars[10] = 27;
	pos_nonlin_vars[11] = 28;


//	int i;

//	for (i=0;i<301;i++) {
//		pos_nonlin_vars[1+4*i] = 5 + 8*i;
//		pos_nonlin_vars[2+4*i] = 6 + 8*i;
//		pos_nonlin_vars[3+4*i] = 7 + 8*i;
//		pos_nonlin_vars[4+4*i] = 8 + 8*i;
//	}

//	for (i=0;i<16;i++) {
//		pos_nonlin_vars[1220 - 16 + i] = 2725 - 16 + i + 1;
//	}

	return true;

}
*/
