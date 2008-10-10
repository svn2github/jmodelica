#include "OptimicaTNLP.hpp"
#include "../OptimicaInterface/SimultaneousInterface.hpp"

#include <iostream>


OptimicaTNLP::OptimicaTNLP(SimultaneousInterface* problem)
  :
  problem_(problem),
  n_eq_(0),
  n_ineq_(0),
  nnz_jac_eq_(0),
  nnz_jac_ineq_(0)
{
  ASSERT_EXCEPTION(problem_ != NULL, INVALID_TNLP,
		   "Null problem definition passed into OptimicaTNLP");
  
  std::cout <<"Woohoo... Created one..." << std::endl;
}

OptimicaTNLP::~OptimicaTNLP()
{
}

bool OptimicaTNLP::get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
				Index& nnz_h_lag, IndexStyleEnum& index_style)
{
  if (!problem_->getDimensions(n, n_eq_, n_ineq_, nnz_jac_eq_, nnz_jac_ineq_)) {
      return false;
  } 
  
  m = n_eq_ + n_ineq_;
  nnz_jac_g = nnz_jac_eq_ + nnz_jac_ineq_;
  nnz_h_lag = 0;
  index_style = FORTRAN_STYLE;
  
  return true;
}

bool OptimicaTNLP::get_bounds_info(Index n, Number* x_l, Number* x_u,
				   Index m, Number* g_l, Number* g_u)
{
  DBG_ASSERT(n_eq_ + n_ineq_ == m);
  DBG_ASSERT(sizeof(Number) == sizeof(double));
  DBG_ASSERT(sizeof(Index) == sizeof(int));
  
  for (int i=0; i<m; i++) {
	  g_l[i] = -1e20;
  }

  for (int i=0; i<n; i++) {
	 g_u[i] = 0;
  }
  
  return problem_->getBounds((double*)x_u, (double*)x_l);
}

bool OptimicaTNLP::get_starting_point(Index n, bool init_x, Number* x,
				      bool init_z, Number* z_L, Number* z_U,
				      Index m, bool init_lambda,
				      Number* lambda)
{
  DBG_ASSERT(init_x == true && init_z == false && init_lambda == false);
  return problem_->getInitial((double*)x);
}

bool OptimicaTNLP::eval_f(Index n, const Number* x, bool new_x,
			  Number& obj_value)
{
  return problem_->evalCost((const double*)x, (double&)obj_value);
}

bool OptimicaTNLP::eval_grad_f(Index n, const Number* x, bool new_x,
			       Number* grad_f)
{
  return problem_->evalGradCost((const double*)x, (double*) grad_f);
}

bool OptimicaTNLP::eval_g(Index n, const Number* x, bool new_x,
			  Index m, Number* g)
{
  bool retval = problem_->evalEqConstraint((const double*)x, (double*)g);
  if (retval) {
    double* gin = g + n_eq_;
    retval = problem_->evalIneqConstraint((const double*)x, (double*)gin);
    }
  return retval;
}

bool OptimicaTNLP::eval_jac_g(Index n, const Number* x, bool new_x,
			      Index m, Index nele_jac, Index* iRow,
			      Index *jCol, Number* values)
{
  bool retval = problem_->evalJacEqConstraint((const double*)x, (double*)values);
  if (retval) {
    double* values_ineq = values + nnz_jac_eq_;
    retval = problem_->evalJacIneqConstraint((const double*)x, values_ineq);
  }
  return retval;
}

void OptimicaTNLP::finalize_solution(SolverReturn status,
				     Index n, const Number* x, const Number* z_L, const Number* z_U,
				     Index m, const Number* g, const Number* lambda,
				     Number obj_value,
				     const IpoptData* ip_data,
				     IpoptCalculatedQuantities* ip_cq)
{
  std::cout << "<speech voice=\"robot\">Optimal profile calculated!</speech>" << std::endl;
}
