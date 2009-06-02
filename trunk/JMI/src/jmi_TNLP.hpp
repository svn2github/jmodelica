// Copyright (C) 2009 Modelon AB
// All Rights reserved
// This file is published under the Common Public License 1.0.

#ifndef JMI_TNLP_HPP_
#define JMI_TNLP_HPP_

#include "IpTNLP.hpp"
#include "jmi_opt_sim.h"

using namespace Ipopt;

/**
 * This is the class that present the dynamic optimization
 * problem from Optimica to Ipopt
 */
class jmi_TNLP : public TNLP
{
public:
  // Construct an OptimicaTNLP - SimultaneousInterface pointer
  // must be valid
  jmi_TNLP(jmi_opt_sim_t* problem);

  virtual ~jmi_TNLP();

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
/*
    virtual Index get_number_of_nonlinear_variables();

    virtual bool get_list_of_nonlinear_variables(Index num_nonlin_vars,
        Index* pos_nonlin_vars);
*/
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
    jmi_TNLP();

    /** Copy Constructor */
    jmi_TNLP(const jmi_TNLP&);

    /** Overloaded Equals Operator */
    void operator=(const jmi_TNLP&);
    //@}

    // Problem definition
    jmi_opt_sim_t* problem_;
    Index n_;
    Index n_h_;
    Index n_g_;
    Index dh_n_nz_;
    Index dg_n_nz_;
};



#endif
