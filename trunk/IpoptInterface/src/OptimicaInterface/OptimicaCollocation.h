#ifndef OPTIMICACOLLOCATION_H_
#define OPTIMICACOLLOCATION_H_

#include "../ModelInterface/ModelInterface.h"

/**
 * Definition of a dynamic optimization problem generated from
 * Optimica, where the transcription has been done by means of
 * orthogonal collocation.
 */

typedef struct {
	MIDef md;                        // The model representation
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
 * evalCost returns the cost function value at a given point in search space.
 */
static int evalCost(OCDef* od, double* x, double* f);

/**
 * evalConstraints evaluate the equatlity constraint residuals at a given point.
 * Notice that inequality constraints are assumed to be transformed to equality
 * constraints in this interface. Also notice that evalConstraints contains both
 * the equality constraints resulting from transcription of the dynamics as well
 * as constraints given in the optimization formulation.
 */
static int evalConstraints(OCDef* od, double* x, double* g);

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */ 
static int getDimensions(OCDef* od, int* n, int* m);

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
static int getBounds(OCDef* od, double* x_ub, double* x_lb);
/**
 * getInitial returns the initial point.
 */
static int getInitial(OCDef* od, double* x_init);

#endif /*OPTIMICACOLLOCATION_H_*/
