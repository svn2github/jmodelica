#include "SimpleExample.hpp"

SimpleExample::SimpleExample()
{
	// TODO: invoke super class constructor

	// Move to super class?
	getBounds(x_lb_,x_ub_);
	getInitial(xInit_);

	getJacEqConstraintNzElements(colJacEqConstraintNzElements_,
			                     rowJacEqConstraintNzElements_);
	
	getJacIneqConstraintNzElements(colJacIneqConstraintNzElements_,
			                       rowJacIneqConstraintNzElements_);
	

}


SimpleExample::~SimpleExample()
{
}



/*
 * These functions encode the optimization problem
 *
 *    min (x-2)^2 + 3
 *
 *   subject to
 *
 *    3 - x <= 0
 */


/**
 * initOptimizationProblem sets up the problem by creating an instance of OCPDef.
 */

/*
bool SimpleExample::initOptimizationProblem() {

	OCDef* od = (OCDef*)malloc(sizeof(OCDef));

//	ModelDef md = initModel();

//	*md = initModel();                // The model representation

	ocGetDimensions(&(od->nVars), &(od->nEqConstr), &(od->nIneqConstr),
			        &(od->nNzJacEqConstr), &(od->nNzJacIneqConstr));

	
	od->xInit = (double*)calloc(od->nVars,sizeof(double)); // Initial point
	od->x_lb  = (double*)calloc(od->nVars,sizeof(double)); // Lower bound for x
	od->x_ub = (double*)calloc(od->nVars,sizeof(double));  // Upper bound for x

	od->xInit[0] = 2;
	od->x_lb[0] = -10;
	od->x_ub[0] = 10;

	od->colJacIneqConstraintNzElements = 
		(int*)calloc(od->nNzJacIneqConstr,sizeof(int)); // Col indices of non-zero elements
	od->rowJacIneqConstraintNzElements =
		(int*)calloc(od->nNzJacIneqConstr,sizeof(int)); // Row indices of non-zeros elements
	od->colJacIneqConstraintNzElements[0] = 1;
	od->rowJacIneqConstraintNzElements[0] = 1;
	
	//	int nColl;                       // Number of collocation points
//	double* A;                       // The A matrix in the Butcher tableau
//	double* b;                       // The b matrix in the Butcher tableau
//	double* c;                       // The c matrix in the Butcher tableau
//	int nEl;                         // Number of elements
//	double* mesh;                    // The optimization mesh expressed as
	                                 // element lengths.
//	double startTime;                // Start time of optimization horizon
//	int startTimeFree;               // Problem with free start time
//	double finalTime;                // Final time of optimization horizon
//	int finalTimeFree;               // Problem with free final time

	return (OCDef*)od;
}
*/
/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */
bool SimpleExample::getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
                                  int& nNzJacEqConstr, int& nNzJacIneqConstr) {

	nVars = 1;                   // Number of variables
	nEqConstr = 0;               // Number of equality constraints
	nIneqConstr = 1;             // Number of inequality constraints
	nNzJacEqConstr = 0;              // Number of non-zeros in eq. constr. Jac.
	nNzJacIneqConstr = 1;            // Number of non-zeros in ineq. constr. Jac.

	return 1;
}



/**
 * evalCost returns the cost function value at a given point in search space.
 */
bool SimpleExample::evalCost(const double* x, double& f) {

	f = (x[0]-2)*(x[0]-2) + 3;
	return true;

}

/**
 * evalGradCost returns the gradient of the cost function value at
 * a given point in search space.
 */
bool ocEvalGradCost(const double* x, double* grad_f) {
	grad_f[0] = 2*x[0];
	return true;
}

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
bool evalEqConstraints(const double* x, double* gEq) {

	return true;
}

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the
 * equality constraints.
 */
bool evalJacEqConstraint(const double* x, double* jac_gEq) {

	return true;
}

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
bool evalIneqConstraint(const double* x, double* gIneq) {

	gIneq[0] = 3-x[0];
	return true;
}

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the
 * inequality constraints g(x)<=0
 */
bool evalJacIneqConstraint(const double* x, double* jac_gIneq) {
	jac_gIneq[0] = -1;
	return 1;
}

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
bool getBounds(double* x_ub, double* x_lb) {
	
	x_lb[0] = -10;
	x_ub[0] = 10;

	return true;
}

/**
 * getInitial returns the initial point.
 */
bool getInitial(double* xInit){
	
	xInit[0] = 2;

	return true;
}

/** 
 * getEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
bool getJacEqConstraintNzElements(int* colIndex, int* rowIndex) {
	return true;
}

/** 
 * getIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
bool getJacIneqConstraintNzElements(int* colIndex, int* rowIndex) {

	colIndex[0] = 1;
	colIndex[0] = 1;

	return true;
}

/**
 * dummy main
 */
int main()
{
	printf("Hello Optimizers!");
	return 0;
}

