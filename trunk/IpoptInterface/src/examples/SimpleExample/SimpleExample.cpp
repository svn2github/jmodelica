#include "SimpleExample.hpp"
#include "../../IpoptInterface/OptimicaTNLP.hpp"
#include "IpIpoptApplication.hpp"

/*
 * These functions encode the optimization problem
 *
 *    min (x-2)^2 + 3
 *
 *   subject to
 *
 *    3 - x <= 0
 */


SimpleExample::SimpleExample()
:
SimultaneousInterface()
{

}

SimpleExample::~SimpleExample()
{
	
}

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */
bool SimpleExample::getDimensionsImpl(int& nVars, int& nEqConstr, int& nIneqConstr,
                                  int& nNzJacEqConstr, int& nNzJacIneqConstr) {

	nVars = 1;                   // Number of variables
	nEqConstr = 0;               // Number of equality constraints
	nIneqConstr = 1;             // Number of inequality constraints
	nNzJacEqConstr = 0;              // Number of non-zeros in eq. constr. Jac.
	nNzJacIneqConstr = 1;            // Number of non-zeros in ineq. constr. Jac.

	return true;
}



/**
 * evalCost returns the cost function value at a given point in search space.
 */
bool SimpleExample::evalCostImpl(const double* x, double& f) {

	f = (x[0]-2)*(x[0]-2) + 3;
	return true;

}

/**
 * evalGradCost returns the gradient of the cost function value at
 * a given point in search space.
 */
bool SimpleExample::evalGradCostImpl(const double* x, double* grad_f) {
	grad_f[0] = 2*x[0];
	return true;
}

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
bool SimpleExample::evalEqConstraintImpl(const double* x, double* gEq) {

	return true;
}

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the
 * equality constraints.
 */
bool SimpleExample::evalJacEqConstraintImpl(const double* x, double* jac_gEq) {

	return true;
}

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
bool SimpleExample::evalIneqConstraintImpl(const double* x, double* gIneq) {

	gIneq[0] = 3-x[0];
	return true;
}

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the
 * inequality constraints g(x)<=0
 */
bool SimpleExample::evalJacIneqConstraintImpl(const double* x, double* jac_gIneq) {
	jac_gIneq[0] = -1;
	return 1;
}

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
bool SimpleExample::getBoundsImpl(double* x_lb, double* x_ub) {
	
	x_lb[0] = -10;
	x_ub[0] = 10;

	return true;
}

/**
 * getInitial returns the initial point.
 */
bool SimpleExample::getInitialImpl(double* xInit){
	
	xInit[0] = 2;

	return true;
}

/** 
 * getEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
bool SimpleExample::getJacEqConstraintNzElementsImpl(int* rowIndex, int* colIndex) {
	return true;
}

/** 
 * getIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
bool SimpleExample::getJacIneqConstraintNzElementsImpl(int* rowIndex, int* colIndex) {

	colIndex[0] = 1;
	colIndex[0] = 1;

	return true;
}

/**
 * test main function
 */
int main(int argv, char* argc[])
{
//	using namespace Ipopt;
	
	// Create a new instance of your nlp
	//  (use a SmartPtr, not raw)
	SimpleExample* op = new SimpleExample();	
	op->prettyPrint();

	SmartPtr<TNLP> mynlp = new OptimicaTNLP(op);   

	// Create a new instance of IpoptApplication
	//  (use a SmartPtr, not raw)
	SmartPtr<IpoptApplication> app = new IpoptApplication();

	// Change some options
	// Note: The following choices are only examples, they might not be
	//       suitable for your optimization problem.
	app->Options()->SetStringValue("output_file", "ipopt.out");
	app->Options()->SetStringValue("hessian_approximation","limited-memory");

	// Intialize the IpoptApplication and process the options
	ApplicationReturnStatus status;
	status = app->Initialize();
	if (status != Solve_Succeeded) {
		printf("\n\n*** Error during initialization!\n");
		return (int) status;
	}

	// Ask Ipopt to solve the problem
	status = app->OptimizeTNLP(mynlp);

	if (status == Solve_Succeeded) {
		printf("\n\n*** The problem solved!\n");
	}
	else {
		printf("\n\n*** The problem FAILED!\n");
	}

	// As the SmartPtrs go out of scope, the reference count
	// will be decremented and the objects will automatically
	// be deleted.
	
	delete op;

	return (int) status;
}
