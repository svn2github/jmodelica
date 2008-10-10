#include "VDPOptimization.hpp"




VDPOptimization::VDPOptimization()
:
SimultaneousInterface(),
model_(NULL),
modelInitialized_(false),
N_(100), // Number of elements
tf_(5.) // Final time
{
}

VDPOptimization::~VDPOptimization()
{
}

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */
bool VDPOptimization::getDimensionsImpl(int& nVars, int& nEqConstr, int& nIneqConstr,
                                  int& nNzJacEqConstr, int& nNzJacIneqConstr) {

	ModelInterface* model;
	if (!getModelInterfaceImpl(model))
		return false;
	
	int nStates;
	int nDerivatives;
	int nParameters;
	int nInputs;
	int nOutputs;
	int nAlgebraic;
	int nEqns;

	// This model uses a hard coded backward euler scheme with N elements
	int N = N_;
	
	// Get model dimensions
	model->getDimensions(nStates, nDerivatives, nParameters, nInputs, nOutputs, nAlgebraic, nEqns);
		
	nVars = (N+1)*nStates + N*(nDerivatives + nInputs + nOutputs + nAlgebraic);
	
	// This problem has no constraints apart from the equalit constraint resulting from
	// transcribed dynamical system
	nEqConstr = N*nEqns + // Equations for the differential equation
	            N*nDerivatives + // Equations for the backward Euler approximation
	            nStates; // Equations for the initial conditions
	
	nIneqConstr = 0;
	
	nNzJacEqConstr = N*nEqns*(2*nStates + nDerivatives + nInputs + nOutputs + nAlgebraic) + // Collocation of residuals
	                 N*3*nDerivatives + // Backward euler approximation of derivatives
	                 nStates; // initial conditions
	nNzJacIneqConstr = 0;
	
	return true;
}

bool VDPOptimization::getModelInterfaceImpl(ModelInterface* model) {
 
	if (!modelInitialized_) {
    	model_ = new VDPModel();
    	modelInitialized_ = true;
    }
    model = model_;
	return true;

}

/**
 * evalCost returns the cost function value at a given point in search space.
 */
bool VDPOptimization::evalCostImpl(const double* x, double& f) {

	ModelInterface* model;
	if (!getModelInterfaceImpl(model))
		return false;
	
	int nStates;
	int nDerivatives;
	int nParameters;
	int nInputs;
	int nOutputs;
	int nAlgebraic;
	int nEqns;
	int N = N_;
	
	// Get model dimensions
	model->getDimensions(nStates, nDerivatives, nParameters, nInputs, nOutputs, nAlgebraic, nEqns);

	// Find x_3(t_f)
	f = x[(nStates + (N-1)*(nStates + nDerivatives + nInputs + nOutputs + nAlgebraic) + nStates - 1) - 1];
	return true;

}

/**
 * evalGradCost returns the gradient of the cost function value at
 * a given point in search space.
 */
bool VDPOptimization::evalGradCostImpl(const double* x, double* grad_f) {
	grad_f[0] = 2*x[0];
	return true;
}

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
bool VDPOptimization::evalEqConstraintImpl(const double* x, double* gEq) {
	// Evaluate the Collocation residuals
	
	// Evaluate the equations for the derivatives
	
	// Evaluate the equations for the initial conditions
	
	
	return true;
}

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the
 * equality constraints.
 */
bool VDPOptimization::evalJacEqConstraintImpl(const double* x, double* jac_gEq) {

	return true;
}

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
bool VDPOptimization::evalIneqConstraintImpl(const double* x, double* gIneq) {

	gIneq[0] = 3-x[0];
	return true;
}

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the
 * inequality constraints g(x)<=0
 */
bool VDPOptimization::evalJacIneqConstraintImpl(const double* x, double* jac_gIneq) {
	jac_gIneq[0] = -1;
	return 1;
}

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
bool VDPOptimization::getBoundsImpl(double* x_ub, double* x_lb) {
	
	x_lb[0] = -10;
	x_ub[0] = 10;

	return true;
}

/**
 * getInitial returns the initial point.
 */
bool VDPOptimization::getInitialImpl(double* xInit){

	int nVars;
	int nEqConstr;
	int nIneqConstr;
	int nNzJacEqConstr;
	int nNzJacIneqConstr;
	
	getDimensions(nVars, nEqConstr, nIneqConstr, nNzJacEqConstr, nNzJacIneqConstr);

	// Initialize everything to zero
	for (int i=0; i<=nVars; i++) {
		xInit[i] = 0;
	}
	
	return true;
}

/** 
 * getEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
bool VDPOptimization::getJacEqConstraintNzElementsImpl(int* colIndex, int* rowIndex) {
	
	
	return true;
}

/** 
 * getIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
bool VDPOptimization::getJacIneqConstraintNzElementsImpl(int* colIndex, int* rowIndex) {

	// No inequality constraints.
	return true;
	
}
