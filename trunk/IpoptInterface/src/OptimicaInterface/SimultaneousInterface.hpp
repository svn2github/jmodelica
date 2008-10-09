#ifndef SIMULTANEOUSINTERFACE_HPP_
#define SIMULTANEOUSINTERFACE_HPP_

class SimultaneousInterface
{
public:
	SimultaneousInterface();
	virtual ~SimultaneousInterface();
	
	/**
	 * getDimension returns the number of variables and the number of
	 * constraints, respectively, in the problem.
	 */ 
	virtual bool getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr)=0;

	/**
	 * evalCost returns the cost function value at a given point in search space.
	 */
	virtual bool evalCost(const double* x, double& f)=0;

	/**
	 * evalGradCost returns the gradient of the cost function value at 
	 * a given point in search space.
	 */
	virtual bool ocEvalGradCost(double* x, double* grad_f)=0;

	/**
	 * evalEqConstraints returns the residual of the equality constraints
	 */
	virtual bool evalEqConstraint(OCDef* od, double* x, double* gEq)=0;

	/**
	 * evalJacEqConstraints returns the Jacobian of the residual of the 
	 * equality constraints.
	 */
	virtual bool evalJacEqConstraint(double* x, double* jac_gEq) = 0;

	/**
	 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
	 */
	virtual bool evalIneqConstraint(double* x, double* gIneq) = 0;

	/**
	 * evalJacIneqConstraints returns Jacobian of the residual of the 
	 * inequality constraints g(x)<=0
	 */
	virtual bool evalJacIneqConstraint(double* x, double* jac_gIneq) = 0;

	/**
	 * getBounds returns the upper and lower bounds on the optimization variables.
	 */
	virtual bool getBounds(double* x_ub, double* x_lb) = 0;

	/**
	 * getInitial returns the initial point.
	 */
	virtual bool getInitial(double* x_init) = 0;

	/** 
	 * getEqConstraintNzElements returns the indices of the non-zeros in the 
	 * equality constraint Jacobian.
	 */
	virtual bool getJacEqConstraintNzElements(int* colIndex, int* rowIndex) = 0;

	/** 
	 * getIneqConstraintElements returns the indices of the non-zeros in the 
	 * inequality constraint Jacobian.
	 */
	virtual bool getJacIneqConstraintNzElements(int* colIndex, int* rowIndex) = 0;
	
};

#endif /*SIMULTANEOUSINTERFACE_HPP_*/
