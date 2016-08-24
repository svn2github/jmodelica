/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "jmi_opt_coll_TNLP.hpp"
#include "jmi_opt_coll.h"

#include <iostream>


jmi_opt_coll_TNLP::jmi_opt_coll_TNLP(jmi_opt_coll_t* problem)
  :
  problem_(problem),
  n_(0),
  n_h_(0),
  n_g_(0),
  dh_n_nz_(0),
  dg_n_nz_(0),
  return_status_(-1)
{
  ASSERT_EXCEPTION(problem_ != NULL, INVALID_TNLP,
           "Null problem definition passed into jmi_opt_coll_TNLP");
}

jmi_opt_coll_TNLP::~jmi_opt_coll_TNLP()
{
}

bool jmi_opt_coll_TNLP::get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
                Index& nnz_h_lag, IndexStyleEnum& index_style)
{
  if (jmi_opt_coll_get_dimensions(problem_, &n, &n_g_, &n_h_,
            &dg_n_nz_, &dh_n_nz_) < 0) {
      return false;
  }
  n_ = n;
  m = n_h_ + n_g_;
  nnz_jac_g = dh_n_nz_ + dg_n_nz_;
  nnz_h_lag = 0;
  index_style = FORTRAN_STYLE;
  return true;
}

bool jmi_opt_coll_TNLP::get_bounds_info(Index n, Number* x_l, Number* x_u,
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

  for (int i=n_h_; i<n_h_ + n_g_; i++) {
      g_l[i] = -1e20;
  }

  for (int i=n_h_; i<n_h_ + n_g_; i++) {
     g_u[i] = 0;
  }

  if (jmi_opt_coll_get_bounds(problem_, x_l, x_u) < 0) {
      return false;
  }

  return true;

}

bool jmi_opt_coll_TNLP::get_starting_point(Index n, bool init_x, Number* x,
                      bool init_z, Number* z_L, Number* z_U,
                      Index m, bool init_lambda,
                      Number* lambda)
{
  DBG_ASSERT(init_x == true && init_z == false && init_lambda == false);
  if (jmi_opt_coll_get_initial(problem_, x) < 0) {
      return false;
  }
  return true;
}

/*
bool jmi_opt_coll_TNLP::get_constraints_linearity(Index m, LinearityType* const_types) {

    int i;
    std::cout << "jmi_opt_coll_TNLP::get_constraints_linearity" << std::endl;
    for(i=0;i<m;i++) {
        const_types[i] = NON_LINEAR;
    }

    for(i=1506;i<2423;i++) {
        const_types[i] = LINEAR;
    }

    return true;
}
*/

bool jmi_opt_coll_TNLP::eval_f(Index n, const Number* x, bool new_x,
              Number& obj_value)
{

    int i;

    for (i=0;i<n_;i++) {
        problem_->x[i] = x[i];
    }

    if (jmi_opt_coll_f(problem_, &obj_value) < 0) {
        return false;
    }

    return true;

}

bool jmi_opt_coll_TNLP::eval_grad_f(Index n, const Number* x, bool new_x,
                   Number* grad_f)
{

    int i;

    for (i=0;i<n_;i++) {
        grad_f[i] = 0;
    }

    for (i=0;i<n_;i++) {
        problem_->x[i] = x[i];
    }

    if (jmi_opt_coll_df(problem_, grad_f) < 0) {
        return false;
    }
    return true;
}

bool jmi_opt_coll_TNLP::eval_g(Index n, const Number* x, bool new_x,
              Index m, Number* g)
{
    int i;

    for (i=0;i<n_h_+n_g_;i++) {
        g[i] = 0;
    }

    for (i=0;i<n_;i++) {
        problem_->x[i] = x[i];
    }

    if (jmi_opt_coll_h(problem_, g) < 0) {
        return false;
    }

    g += problem_->n_h;
    if (jmi_opt_coll_g(problem_, g) < 0) {
        return false;
    }

    return true;

}

bool jmi_opt_coll_TNLP::eval_jac_g(Index n, const Number* x, bool new_x,
                  Index m, Index nele_jac, Index* iRow,
                  Index *jCol, Number* values)
{

    int i;

    if (values == NULL) {
        if (jmi_opt_coll_dh_nz_indices(problem_, iRow, jCol) < 0) {
            return false;
        }

        iRow += problem_->dh_n_nz;
        jCol += problem_->dh_n_nz;
        if (jmi_opt_coll_dg_nz_indices(problem_, iRow, jCol) < 0) {
            return false;
        }

        for(i=0;i<problem_->dg_n_nz;i++) {
            iRow[i] += n_h_;
        }

        iRow -= problem_->dh_n_nz;
        jCol -= problem_->dh_n_nz;

        return true;
    } else {
        for (i=0;i<dg_n_nz_;i++) {
            values[i] = 0;
        }
        for (i=0;i<n_;i++) {
            problem_->x[i] = x[i];
        }
        if (jmi_opt_coll_dh(problem_, values) < 0) {
            return false;
        }

        values += problem_->dh_n_nz;
        if (jmi_opt_coll_dg(problem_, values) < 0) {
            return false;
        }
        return true;
    }

    return false;
}

void jmi_opt_coll_TNLP::finalize_solution(SolverReturn status,
                     Index n, const Number* x, const Number* z_L, const Number* z_U,
                     Index m, const Number* g, const Number* lambda,
                     Number obj_value,
                     const IpoptData* ip_data,
                     IpoptCalculatedQuantities* ip_cq)
{
    return_status_ = status;
//  printf("jmi_init_opt_TNLP.finalize_solution(.)\n");
//      printf("Return status: %d\n",status);
}


Index jmi_opt_coll_TNLP::get_number_of_nonlinear_variables() {
    //printf("********* %d\n",problem_->n_nonlinear_variables);
    return problem_->n_nonlinear_variables;
}

bool jmi_opt_coll_TNLP::get_list_of_nonlinear_variables(Index num_nonlin_vars,
    Index* pos_nonlin_vars) {

    int i;
    for (i=0;i<num_nonlin_vars;i++) {
        //printf("* %d\n",problem_->non_linear_variables_indices[i]);
        pos_nonlin_vars[i] = problem_->non_linear_variables_indices[i];
    }

    return true;

/*
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

*/
    /*
    pos_nonlin_vars[0] = 5;
    pos_nonlin_vars[1] = 6;
    pos_nonlin_vars[2] = 8;
    pos_nonlin_vars[3] = 13;
    pos_nonlin_vars[4] = 14;
    pos_nonlin_vars[5] = 16;
    pos_nonlin_vars[6] = 21;
    pos_nonlin_vars[7] = 22;
    pos_nonlin_vars[8] = 24;
    pos_nonlin_vars[9] = 29;
    pos_nonlin_vars[10] = 30;
    pos_nonlin_vars[11] = 32;
*/

/*
//  int i;

//  for (i=0;i<301;i++) {
//      pos_nonlin_vars[1+4*i] = 5 + 8*i;
//      pos_nonlin_vars[2+4*i] = 6 + 8*i;
//      pos_nonlin_vars[3+4*i] = 7 + 8*i;
//      pos_nonlin_vars[4+4*i] = 8 + 8*i;
//  }

//  for (i=0;i<16;i++) {
//      pos_nonlin_vars[1220 - 16 + i] = 2725 - 16 + i + 1;
//  }
*/
//  return true;

}

int jmi_opt_coll_TNLP::get_return_status() {
    return return_status_;
}
