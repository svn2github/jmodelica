#include "SimultaneousInterface.hpp"

SimultaneousInterface::SimultaneousInterface()
:
	model_(NULL),           // The model representation
	nVars_(0),                       // Number of variables
	nEqConstr_(0),        // Number of equality constraints
	nIneqConstr_(0),                 // Number of inequality constraints
	xInit_(NULL),                   // Initial point
	x_lb_(NULL),                    // Lower bound for x
	x_ub_(NULL),                    // Upper bound for x
	nNzJacEqConstr_(0),              // Number of non-zeros in eq. constr. Jac.
	rowJacEqConstraintNzElements_(NULL),  // Row indices of non-zeros elements
	colJacEqConstraintNzElements_(NULL),  // Col indices of non-zero elements
	nNzJacIneqConstr_(0),            // Number of non-zeros in ineq. constr. Jac.
	rowJacIneqConstraintNzElements_(NULL), // Row indices of non-zeros elements
	colJacIneqConstraintNzElements_(NULL), // Col indices of non-zero elements
	nColl_(0),                       // Number of collocation points
	A_(NULL),                       // The A matrix in the Butcher tableau
	b_(NULL),                       // The b matrix in the Butcher tableau
	c_(NULL),                       // The c matrix in the Butcher tableau
	nEl_(0),                         // Number of elements
	mesh_(NULL),                    // The optimization mesh expressed as
	// element lengths.
	startTime_(0.0),                // Start time of optimization horizon
	startTimeFree_(false),               // Problem with free start time
	finalTime_(0.0),                // Final time of optimization horizon
	finalTimeFree_(false),               // Problem with free final time
	initialized_(false)
	{

	}

SimultaneousInterface::~SimultaneousInterface()
{
		delete [] xInit_;
		delete [] x_lb_;
		delete [] x_ub_;
		delete [] colJacEqConstraintNzElements_;
		delete [] rowJacEqConstraintNzElements_;
		delete [] colJacIneqConstraintNzElements_; 
		delete [] rowJacIneqConstraintNzElements_;

}

/**
 * initialize allocates memory and initialize the model
 */
bool SimultaneousInterface::initialize() 
{
	if (!initialized_) {
		getDimensionsImpl(nVars_, nEqConstr_, nIneqConstr_, nNzJacEqConstr_, nNzJacIneqConstr_);

		xInit_ = new double[nVars_ + 1];
		x_lb_ = new double[nVars_ + 1];
		x_ub_ = new double[nVars_ + 1];

		colJacEqConstraintNzElements_ = new int[nNzJacEqConstr_ + 1];
		rowJacEqConstraintNzElements_ = new int[nNzJacEqConstr_ + 1];
		colJacIneqConstraintNzElements_ = new int[nNzJacIneqConstr_ + 1];
		rowJacIneqConstraintNzElements_  = new int[nNzJacIneqConstr_ + 1];

		getBoundsImpl(x_lb_,x_ub_);
		getInitialImpl(xInit_);

		getJacEqConstraintNzElementsImpl(colJacEqConstraintNzElements_,
				rowJacEqConstraintNzElements_);

		getJacIneqConstraintNzElementsImpl(colJacIneqConstraintNzElements_,
				rowJacIneqConstraintNzElements_);

		initialized_ = true;
	}
	return true;

}

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */ 
bool SimultaneousInterface::getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
		int& nNzJacEqConstr, int& nNzJacIneqConstr)
{
	if (!initialized_) 
		if (!initialize())
			return false;

	nVars = nVars_;
	nEqConstr = nEqConstr_;
	nIneqConstr = nIneqConstr_;
	nNzJacEqConstr = nNzJacEqConstr_;
	nNzJacIneqConstr = nNzJacEqConstr_;

	return true;
}

/**
 * evalCost returns the cost function value at a given point in search space.
 */
bool SimultaneousInterface::evalCost(const double* x, double& f) {

	if (!initialized_) 
			if (!initialize())
				return false;
		return evalCostImpl(x,f);
}

/**
 * evalGradCost returns the gradient of the cost function value at 
 * a given point in search space.
 */
bool SimultaneousInterface::evalGradCost(const double* x, double* grad_f){

	if (!initialized_) 
		if (!initialize())
			return false;
	return evalGradCostImpl(x,grad_f);

}

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
bool SimultaneousInterface::evalEqConstraint(const double* x, double* gEq){

	if (!initialized_) 
		if (!initialize())
			return false;
	return evalEqConstraintImpl(x, gEq);

}

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the 
 * equality constraints.
 */
bool SimultaneousInterface::evalJacEqConstraint(const double* x, double* jac_gEq){

	if (!initialized_) 
		if (!initialize())
			return false;
	return evalJacEqConstraintImpl(x, jac_gEq);

}

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
bool SimultaneousInterface::evalIneqConstraint(const double* x, double* gIneq){

	if (!initialized_) 
		if (!initialize())
			return false;
	return evalIneqConstraintImpl(x, gIneq);

}

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the 
 * inequality constraints g(x)<=0
 */
bool SimultaneousInterface::evalJacIneqConstraint(const double* x, double* jac_gIneq){

	if (!initialized_) 
		if (!initialize())
			return false;
	return evalJacIneqConstraintImpl(x, jac_gIneq);

}

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
bool SimultaneousInterface::getBounds(double* x_ub, double* x_lb){

	if (!initialized_) 
		if (!initialize())
			return false;

	int i = 0;
	for (i=0;i<nVars_;i++) {
		x_lb[i] = x_lb_[i];
		x_ub[i] = x_ub_[i];
	}

	return true;
}

/**
 * getInitial returns the initial point.
 */
bool SimultaneousInterface::getInitial(double* x_init){

	if (!initialized_) 
		if (!initialize())
			return false;

	int i = 0;
	for (i=0;i<nVars_;i++) {
		x_init[i] = xInit_[i];
	}

	return true;

}

/** 
 * getEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
bool SimultaneousInterface::getJacEqConstraintNzElements(int* rowIndex, int* colIndex){

	if (!initialized_) 
		if (!initialize())
			return false;

	int i = 0;
	for (i=0;i<nNzJacEqConstr_;i++) {
		colIndex[i] = colJacEqConstraintNzElements_[i];
		rowIndex[i] = rowJacEqConstraintNzElements_[i];
	}

	return true;

}

/** 
 * getIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
bool SimultaneousInterface::getJacIneqConstraintNzElements(int* rowIndex, int* colIndex){

	if (!initialized_) 
		if (!initialize())
			return false;

	int i = 0;
	for (i=0;i<nNzJacEqConstr_;i++) {
		colIndex[i] = colJacIneqConstraintNzElements_[i];
		rowIndex[i] = rowJacIneqConstraintNzElements_[i];
	}

	return true;

}

/**
 * Print the problem specification
 */
bool SimultaneousInterface::prettyPrint() {

	if (!initialized_) 
		if (!initialize())
			return false;

	
printf("Number of variables                           :%d\n",nVars_);
printf("Number of eq constr.                          :%d\n",nEqConstr_);
printf("Number of ineq constr.                        :%d\n",nIneqConstr_);
printf("Number of nz elements in eq. constr. Jac.     :%d\n",nNzJacEqConstr_);
printf("Number of nz elements in ineq. constr. Jac.   :%d\n",nNzJacIneqConstr_);

return true;

}

