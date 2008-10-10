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

	virtual bool VDPOptimization::getModelInterfaceImpl(ModelInterface* model);
	
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
	virtual bool getBoundsImpl(double* x_ub, double* x_lb);

	/**
	 * getInitial returns the initial point.
	 */
	virtual bool getInitialImpl(double* x_init);

	/** 
	 * getEqConstraintNzElements returns the indices of the non-zeros in the 
	 * equality constraint Jacobian.
	 */
	virtual bool getJacEqConstraintNzElementsImpl(int* colIndex, int* rowIndex);

	/** 
	 * getIneqConstraintElements returns the indices of the non-zeros in the 
	 * inequality constraint Jacobian.
	 */
	virtual bool getJacIneqConstraintNzElementsImpl(int* colIndex, int* rowIndex);	

private:
	ModelInterface* model_;
	bool modelInitialized_;
	int N_; // Number of elements
	double tf_; // Final time
};

#endif /*VDPOPTIMIZATION_HPP_*/
