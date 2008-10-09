#include "../../OptimicaInterface/OptimicaCollocation.h"
#include "../../ModelInterface/ModelInterface.h"

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
OCDef* initOptimizationProblem() {

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

/**
 * ocGetDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */
int ocGetDimensions(int* nVars, int* nEqConstr, int* nIneqConstr,
		            int* nNzJacEqConstr, int* nNzJacIneqConstr) {

	*nVars = 1;                   // Number of variables
	*nEqConstr = 0;               // Number of equality constraints
	*nIneqConstr = 1;             // Number of inequality constraints
	*nNzJacEqConstr = 0;              // Number of non-zeros in eq. constr. Jac.
	*nNzJacIneqConstr = 1;            // Number of non-zeros in ineq. constr. Jac.

	return 1;
}



/**
 * ocEvalCost returns the cost function value at a given point in search space.
 */
int ocEvalCost(OCDef* od, double* x, double* f) {

	*f = (x[0]-2)*(x[0]-2) + 3;
	return 1;

}

/**
 * ocEvalGradCost returns the gradient of the cost function value at
 * a given point in search space.
 */
int ocEvalGradCost(OCDef* od, double* x, double* grad_f) {
	*grad_f = 2*x[0];
	return 1;
}

/**
 * ocEvalEqConstraints returns the residual of the equality constraints
 */
int ocEvalEqConstraints(OCDef* od, double* x, double* gEq) {

	return 1;
}

/**
 * ocEvalJacEqConstraints returns the Jacobian of the residual of the
 * equality constraints.
 */
int ocEvalJacEqConstraint(OCDef* od, double* x, double* jac_gEq) {

	return 1;
}

/**
 * ocEvalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
int ocEvalIneqConstraint(OCDef* od, double* x, double* gIneq) {

	*gIneq = 3-x[0];
	return 1;
}

/**
 * ocEvalJacIneqConstraints returns Jacobian of the residual of the
 * inequality constraints g(x)<=0
 */
int ocEvalJacIneqConstraint(OCDef* od, double* x, double* jac_gIneq) {
	*jac_gIneq = -1;
	return 1;
}

/**
 * ocGetBounds returns the upper and lower bounds on the optimization variables.
 */
int ocGetBounds(OCDef* od, double* x_ub, double* x_lb) {

	int i;
	for (i=0;i<od->nVars;i++) {
		x_lb[i] = od->x_lb[i];
		x_ub[i] = od->x_ub[i];
	}
	return 1;
}

/**
 * ocGetInitial returns the initial point.
 */
int ocGetInitial(OCDef* od, double* xInit){

	int i;
	for (i=0;i<od->nVars;i++) {
		xInit[i] = od->xInit[i];
	}
	return 1;
}

/** 
 * ocGetEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
int ocGetJacEqConstraintNzElements(OCDef* od, int* colIndex, int* rowIndex) {
	return 1;
}

/** 
 * ocGetIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
int ocGetJacIneqConstraintNzElements(OCDef* od, int* colIndex, int* rowIndex) {
	int i;
	for (i=0;i<od->nNzJacEqConstr;i++) {
		colIndex[i] = od->colJacIneqConstraintNzElements[i];
		rowIndex[i] = od->rowJacIneqConstraintNzElements[i];
	}
	return 1;
}

/**
 * dummy main
 */
int main()
{
	printf("Hello Optimizers!");
	return 0;
}
