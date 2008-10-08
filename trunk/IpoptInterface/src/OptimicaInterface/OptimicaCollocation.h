#ifndef OPTIMICACOLLOCATION_H_
#define OPTIMICACOLLOCATION_H_

#include <stdlib.h>
#include <stdio.h>

#include "../ModelInterface/ModelInterface.h"

/**
 * Definition of a dynamic optimization problem generated from
 * Optimica, where the transcription has been done by means of
 * orthogonal collocation.
 */

typedef struct {
	ModelDef md;                     // The model representation
	int nVars;                       // Number of variables
	int nEqConstr;                   // Number of equality constraints
	int nIneqConstr;                 // Number of inequality constraints
	double* xInit;                   // Initial point
	double* x_lb;                    // Lower bound for x
	double* x_ub;                    // Upper bound for x
	int nNzJacEqConstr;              // Number of non-zeros in eq. constr. Jac.
	int* colJacEqConstraintNzElements;  // Col indices of non-zero elements
	int* rowJacEqConstraintNzElements;  // Row indices of non-zeros elements
	int nNzJacIneqConstr;            // Number of non-zeros in ineq. constr. Jac.
	int* colJacIneqConstraintNzElements; // Col indices of non-zero elements
	int* rowJacIneqConstraintNzElements; // Row indices of non-zeros elements
	int nColl;                       // Number of collocation points
	double* A;                       // The A matrix in the Butcher tableau
	double* b;                       // The b matrix in the Butcher tableau
	double* c;                       // The c matrix in the Butcher tableau
	int nEl;                         // Number of elements
	double* mesh;                    // The optimization mesh expressed as
	                                 // element lengths.
	double startTime;                // Start time of optimization horizon
	int startTimeFree;               // Problem with free start time
	double finalTime;                // Final time of optimization horizon
	int finalTimeFree;               // Problem with free final time
} OCDef;


/**
 * initOptimizationProblem sets up the problem by creating an instance of OCPDef.
 */
OCDef* initOptimizationProblem();

/**
 * evalCost returns the cost function value at a given point in search space.
 */
int evalCost(OCDef* od, double* x, double* f);

/**
 * evalGradCost returns the gradient of the cost function value at 
 * a given point in search space.
 */
int evalGradCost(OCDef* od, double* x, double* grad_f);

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
int evalEqConstraint(OCDef* od, double* x, double* gEq);

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the 
 * equality constraints.
 */
int evalJacEqConstraint(OCDef* od, double* x, double* jac_gEq);

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
int evalIneqConstraint(OCDef* od, double* x, double* gIneq);

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the 
 * inequality constraints g(x)<=0
 */
int evalJacIneqConstraint(OCDef* od, double* x, double* jac_gIneq);

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */ 
int getDimensions(OCDef* od, int* nVars, int* nEqConstr, int* nIneqConstr);

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
int getBounds(OCDef* od, double* x_ub, double* x_lb);

/**
 * getInitial returns the initial point.
 */
int getInitial(OCDef* od, double* x_init);

/** 
 * getEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
int getJacEqConstraintNzElements(OCDef* od, int* colIndex, int* rowIndex);

/** 
 * getIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
int getJacIneqConstraintNzElements(OCDef* od, int* colIndex, int* rowIndex);


#endif /*OPTIMICACOLLOCATION_H_*/
