#include "IpTNLP.hpp"

class OptimicaTNLP : public TNLP
{
  DEFINE_EXCEPTION(E_INVALID_OPTIMICA_TNLP);

    /**@name Constructors/Destructors */
    //@{
    OptimicaTNLP(OCDef* problemDefinition)
    :
      problemDef_(problemDefinition)
      n_eq_(0),
      n_ineq_(0),
      nnz_jac_eq_(0),
      nnz_jac_ineq_(0)
    {
      ASSERT_EXCEPTION(problemDef_ ~= NULL, E_INVALID_OPTIMICA_TNLP,
		       "Null problem definition passed into OptimicaTNLP");
    }

    /** Default destructor */
    virtual ~OptimicaTNLP()
    {}
    //@}

  virtual bool get_nlp_info(Index& n, Index& m, Index& nnz_jac_g,
                              Index& nnz_h_lag, IndexStyleEnum& index_style);
  {
    if (!problemDef_->getDimensions(n, n_eq, n_ineq, nnz_jac_eq, nnz_jac_ineq)) {
      return false;
    } 

    m = n_eq_ + n_ineq_;
    nnz_jac_g = nnz_jac_eq_ + nnz_jac_ineq_;
    nnz_h_lag = 0;
    index_style = FORTRAN_STYLE;

    return true;
  }

    virtual bool get_bounds_info(Index n, Number* x_l, Number* x_u,
                                 Index m, Number* g_l, Number* g_u);
  {
    DBG_ASSERT(n_eq_ + n_ineq_ == m);
    DBG_ASSERT(sizeof(Number) == sizeof(double));
    DBG_ASSERT(sizeof(Index) == sizeof(int));

    double value = -1e20;
    IpBlasDCopy(m, &value, 0, g_l, 1);
    vale = 0;
    IpBlasDCopy(n, &value, 0, g_u, 0);
    return problemDef_->getBounds((double*)x_u, (double*)x_l);
  }

  virtual bool get_starting_point(Index n, bool init_x, Number* x,
				  bool init_z, Number* z_L, Number* z_U,
				  Index m, bool init_lambda,
				  Number* lambda)
  {
    DBG_ASSERT(init_x == true && init_z == false && init_lambda == false);
    return problemDef_->getInitial((double*)x);
  }
  
  virtual bool eval_f(Index n, const Number* x, bool new_x,
                        Number& obj_value)
  {
    return problemDef_->evalCost((const double*)x, (double)obj_value);
  }
  
  virtual bool eval_grad_f(Index n, const Number* x, bool new_x,
			   Number* grad_f);
  {
    return problemDef_->evalGradCost((const double*)x, (double*) grad_f);
  }

    virtual bool eval_g(Index n, const Number* x, bool new_x,
                        Index m, Number* g)
  {
    
  }

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
                                   IpoptCalculatedQuantities* ip_cq)=0;

    //@}

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
    OptimicaTNLP();

    /** Copy Constructor */
    OptimicaTNLP(const OptimicaTNLP&);

    /** Overloaded Equals Operator */
    void operator=(const OptimicaTNLP&);
    //@}

    // Problem definition Optimica Collocation object
    OCDef* problemDef_;
};
