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
	ModelDef* md;                     // The model representation
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
 * ocInitOptimizationProblem sets up the problem by creating an instance of OCPDef.
 */
OCDef* ocInitOptimizationProblem();

/**
 * ocGetDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */ 
int ocGetDimensions(int* nVars, int* nEqConstr, int* nIneqConstr,
		            int* nNzJacEqConstr, int* nNzJacIneqConstr);

/**
 * ocEvalCost returns the cost function value at a given point in search space.
 */
int ocEvalCost(OCDef* od, double* x, double* f);

/**
 * ocEvalGradCost returns the gradient of the cost function value at 
 * a given point in search space.
 */
int ocEvalGradCost(OCDef* od, double* x, double* grad_f);

/**
 * ocEvalEqConstraints returns the residual of the equality constraints
 */
int ocEvalEqConstraint(OCDef* od, double* x, double* gEq);

/**
 * ocEvalJacEqConstraints returns the Jacobian of the residual of the 
 * equality constraints.
 */
int ocEvalJacEqConstraint(OCDef* od, double* x, double* jac_gEq);

/**
 * ocEvalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
int ocEvalIneqConstraint(OCDef* od, double* x, double* gIneq);

/**
 * ocEvalJacIneqConstraints returns Jacobian of the residual of the 
 * inequality constraints g(x)<=0
 */
int ocEvalJacIneqConstraint(OCDef* od, double* x, double* jac_gIneq);

/**
 * ocGetBounds returns the upper and lower bounds on the optimization variables.
 */
int ocGetBounds(OCDef* od, double* x_ub, double* x_lb);

/**
 * ocGetInitial returns the initial point.
 */
int ocGetInitial(OCDef* od, double* x_init);

/** 
 * ocGetEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
int ocGetJacEqConstraintNzElements(OCDef* od, int* colIndex, int* rowIndex);

/** 
 * ocGetIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
int ocGetJacIneqConstraintNzElements(OCDef* od, int* colIndex, int* rowIndex);


#endif /*OPTIMICACOLLOCATION_H_*/
