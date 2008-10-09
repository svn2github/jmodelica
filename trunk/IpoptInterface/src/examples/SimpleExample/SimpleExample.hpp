#ifndef SIMPLEEXAMPLE_HPP_
#define SIMPLEEXAMPLE_HPP_

#include "../../OptimicaInterface/SimultaneousInterface.hpp"

class SimpleExample : public SimultaneousInterface
{
public:
	SimpleExample();
	virtual ~SimpleExample();

	
	/**
	 * getDimension returns the number of variables and the number of
	 * constraints, respectively, in the problem.
	 */ 
	virtual bool getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr);

	/**
	 * evalCost returns the cost function value at a given point in search space.
	 */
	virtual bool evalCost(const double* x, double& f);

	/**
	 * evalGradCost returns the gradient of the cost function value at 
	 * a given point in search space.
	 */
	virtual bool evalGradCost(const double* x, double* grad_f);

	/**
	 * evalEqConstraints returns the residual of the equality constraints
	 */
	virtual bool evalEqConstraint(const double* x, double* gEq);

	/**
	 * evalJacEqConstraints returns the Jacobian of the residual of the 
	 * equality constraints.
	 */
	virtual bool evalJacEqConstraint(const double* x, double* jac_gEq);

	/**
	 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
	 */
	virtual bool evalIneqConstraint(const double* x, double* gIneq);

	/**
	 * evalJacIneqConstraints returns Jacobian of the residual of the 
	 * inequality constraints g(x)<=0
	 */
	virtual bool evalJacIneqConstraint(const double* x, double* jac_gIneq);

	/**
	 * getBounds returns the upper and lower bounds on the optimization variables.
	 */
	virtual bool getBounds(double* x_ub, double* x_lb);

	/**
	 * getInitial returns the initial point.
	 */
	virtual bool getInitial(double* x_init);

	/** 
	 * getEqConstraintNzElements returns the indices of the non-zeros in the 
	 * equality constraint Jacobian.
	 */
	virtual bool getJacEqConstraintNzElements(int* colIndex, int* rowIndex);

	/** 
	 * getIneqConstraintElements returns the indices of the non-zeros in the 
	 * inequality constraint Jacobian.
	 */
	virtual bool getJacIneqConstraintNzElements(int* colIndex, int* rowIndex);	

};

#endif /*SIMPLEEXAMPLE_HPP_*/
