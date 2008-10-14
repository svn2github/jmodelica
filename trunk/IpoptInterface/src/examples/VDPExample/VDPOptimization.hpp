#ifndef VDPOPTIMIZATION_HPP_
#define VDPOPTIMIZATION_HPP_

#include "../../OptimicaInterface/SimultaneousInterface.hpp"
#include "../../ModelInterface/ModelInterface.hpp"
#include "VDPModel.hpp"


/**
 * This file encodes the optimization problem
 * 
 *  min x_3(t_f)
 *   u
 * 
 *  subject to
 *  
 *   \dot x_1 = (1 - x_2^2)*x_1 - x_2 + u
 *   \dot x_2 = p_1*x_1
 *   \dot x_3 = x_1^2 + x_2^2 + u^2
 *
 * with initial conditions
 * 
 *   x_1(0) = 0;
 *   x_2(0) = 1;
 *   x_3(0) = 0;
 * 
 *  and t_f = 5.
 * 
 * The dynamics is assumed to be given by a DAE system
 * 
 *   F(x,\dot x,u,z,p)
 * 
 * where x are the variables appearing differentiated, \dot x are the differentiated
 * variables, u are the inputs an z are the algebraic variables. The vector p consists of 
 * the parameters to be optimized. 
 * 
 * The transcription is performed by means of an implicit Euler scheme:
 * 
 *   \dot x_{k+1} = (x_{k+1} - x_{k})/h
 * 
 * where h is the step size. The discretization is performed on a mesh
 * consisting of N+1 points in the interval [0, t_f]. The variables in the NLP are 
 * then given by
 * 
 *   \bar x = [x_0^T, x_1^T, \dot x_1^T, u_1^T, z_1^T, ... x_{N}^T, \dot x_{N}^T, u_{N}^T, z_{N]^T, p^T]^T
 * 
 * yielding 
 * 
 *   n_{nlp} = (N+1)*n_x + N*(n_x + n_u + n_z) + n_p
 * 
 * variables in total. The nlp equality constraint resulting from collocation is given by:
 * 
 *    F(x_1,\dot x_1,u_1,z_1,p)
 *               .
 *               .
 *               .
 *    F(x_N,\dot x_N,u_N,z_N,p)
 *      \dot x_1 - (x_1 - x_0)/h
 *               .
 *               .
 *               .
 *      \dot x_N - (x_N - x_{N-1})/h
 *          x_0 - x_init
 * 
 * which gives (assuming that n_eq = n_x + n_z)
 * 
 *    N*(n_x + n_z + n_x ) + n_x
 * 
 * equality constraints. Consequently, the number of degrees of freedom in the optimization
 * problem is then
 * 
 *    N*n_u + n_p
 * 
 * 
 */


class VDPOptimization : public SimultaneousInterface
{
public:
	VDPOptimization();
	virtual ~VDPOptimization();
		
	/**
	 * getDimension returns the number of variables and the number of
	 * constraints, respectively, in the problem.
	 */ 
	virtual bool getDimensionsImpl(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr);

	virtual bool getModelImpl(ModelInterface* model);
	
	/**
	 * getNumEl returns the number of elements in the mesh
	 */
	virtual bool getNumElImpl(int& nEl);

	/**
	 * getMeshImpl computes the mesh
	 */
	virtual bool getMeshImpl(double* mesh);

	
	/**
	 * evalCost returns the cost function value at a given point in search space.
	 */
	virtual bool evalCostImpl(const double* x, double& f);

	/**
	 * evalGradCost returns the gradient of the cost function value at 
	 * a given point in search space.
	 */
	virtual bool evalGradCostImpl(const double* x, double* grad_f);

	/**
	 * evalEqConstraints returns the residual of the equality constraints
	 */
	virtual bool evalEqConstraintImpl(const double* x, double* gEq);

	/**
	 * evalJacEqConstraints returns the Jacobian of the residual of the 
	 * equality constraints.
	 */
	virtual bool evalJacEqConstraintImpl(const double* x, double* jac_gEq);

	/**
	 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
	 */
	virtual bool evalIneqConstraintImpl(const double* x, double* gIneq);

	/**
	 * evalJacIneqConstraints returns Jacobian of the residual of the 
	 * inequality constraints g(x)<=0
	 */
	virtual bool evalJacIneqConstraintImpl(const double* x, double* jac_gIneq);

	/**
	 * getBounds returns the upper and lower bounds on the optimization variables.
	 */
	virtual bool getBoundsImpl(double* x_lb, double* x_ub);

	/**
	 * getInitial returns the initial point.
	 */
	virtual bool getInitialImpl(double* x_init);

	/** 
	 * getEqConstraintNzElements returns the indices of the non-zeros in the 
	 * equality constraint Jacobian.
	 */
	virtual bool getJacEqConstraintNzElementsImpl(int* rowIndex, int* colIndex);

	/** 
	 * getIneqConstraintElements returns the indices of the non-zeros in the 
	 * inequality constraint Jacobian.
	 */
	virtual bool getJacIneqConstraintNzElementsImpl(int* rowIndex, int* colIndex);	

private:
	ModelInterface* model_;
	bool modelInitialized_;
};

#endif /*VDPOPTIMIZATION_HPP_*/
