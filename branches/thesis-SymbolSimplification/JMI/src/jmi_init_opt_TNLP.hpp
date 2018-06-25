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

#ifndef JMI_INIT_OPT_TNLP_HPP_
#define JMI_INIT_OPT_TNLP_HPP_

#include "IpTNLP.hpp"
#include "jmi_init_opt.h"

using namespace Ipopt;

/**
 * This is the class that present the optimization problem resulting from
 * the DAE initialization problem to Ipopt.
 */
class jmi_init_opt_TNLP : public TNLP
{
public:
  // Construct an OptimicaTNLP - SimultaneousInterface pointer
  // must be valid
  jmi_init_opt_TNLP(jmi_init_opt_t* problem);

  virtual ~jmi_init_opt_TNLP();

  /** @name NLP initialization methods */
  //@{
  virtual bool get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
                              Index& nnz_h_lag, IndexStyleEnum& index_style);

  virtual bool get_bounds_info(Index n, Number* x_l, Number* x_u,
                   Index m, Number* g_l, Number* g_u);

  virtual bool get_starting_point(Index n, bool init_x, Number* x,
                  bool init_z, Number* z_L, Number* z_U,
                  Index m, bool init_lambda,
                  Number* lambda);
  //@}

//  virtual bool get_constraints_linearity(Index m, LinearityType* const_types);

  /** @name NLP evaluation methods */
  //@{
  virtual bool eval_f(Index n, const Number* x, bool new_x,
              Number& obj_value);

  virtual bool eval_grad_f(Index n, const Number* x, bool new_x,
               Number* grad_f);

  virtual bool eval_g(Index n, const Number* x, bool new_x,
              Index m, Number* g);

  virtual bool eval_jac_g(Index n, const Number* x, bool new_x,
              Index m, Index nele_jac, Index* iRow,
              Index *jCol, Number* values);
  //@}

    /** @name Solution Methods */
    //@{
    /** This method is called when the algorithm is complete so the TNLP can store/write the solution */
    virtual void finalize_solution(SolverReturn status,
                                   Index n, const Number* x, const Number* z_L, const Number* z_U,
                                   Index m, const Number* g, const Number* lambda,
                                   Number obj_value,
                                   const IpoptData* ip_data,
                                   IpoptCalculatedQuantities* ip_cq);
    //@}

    virtual Index get_number_of_nonlinear_variables();

    virtual bool get_list_of_nonlinear_variables(Index num_nonlin_vars,
        Index* pos_nonlin_vars);

  private:
    /**@name Default Compiler Generated Methods
     * (Hidden to avoid implicit creation/calling).
     * These methods are not implemented and
     * we do not want the compiler to implement
     * them for us, so we declare them private
     * and do not define them. This ensures that
     * they will not be implicitly created/called. */
    //@{
    /** Default Constructor */
    jmi_init_opt_TNLP();

    /** Copy Constructor */
    jmi_init_opt_TNLP(const jmi_init_opt_TNLP&);

    /** Overloaded Equals Operator */
    void operator=(const jmi_init_opt_TNLP&);
    //@}

    // Problem definition
    jmi_init_opt_t* problem_;
    Index n_;
    Index n_h_;
    Index dh_n_nz_;
    int return_status_;

};



#endif
