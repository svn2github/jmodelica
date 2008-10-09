#ifndef MODELINTERFACE_H_
#define MODELINTERFACE_H_

#include <stdlib.h>
#include <stdio.h>


/**
 * ModelDef holds information about the model representation
 */
typedef struct {

	// Dimensions
	int nStates;                // Number of states
    int nDerivatives;           // Number of derivatives
	int nInputs;                // Number of intputs
	int nOutputs;               // Number of outputs in the model
	int nAlgebraic;             // Number of auxilary variables
	int nParameters;            // Number of parameters
    int nEqns;                   // Number of equations in the DAE

    double* states;              // State vector
    double* derivatives;         // Derivative vector
    double* parameters;          // Parameter vector
    double* inputs;              // Input vector
    double* outputs;             // Output vector 
    double* algebraic;           // Algebraic vector 

} ModelDef;

/**
 * initModel initializes the model and creates an MIDef instance
 */
ModelDef* miInitModel();

/**
 * miGetDimensions retrieves the dimensions of the model variable vectors.
 */
int miGetDimensions(int* nStates, int* nDerivatives, 
		          int* nInputs, int* nOutputs,
		          int* nAlgebraic, int* nParameters,
		          int* nEqns);

/**
 * Evaluate the residual of the DAE. The argument res should have the
 * the size nEqns.
 */
int miEvalDAEResidual(ModelDef* md, double* res);

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. state variables.
 */
int miEvalJacDAEResidualStates(ModelDef* md, double* jacStates);

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. derivatives.
 */
int miEvalJacDAEResidualDerivatives(ModelDef* md, double* jacDerivatives);

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. inputs.
 */
int miEvalJacDAEResidualInputs(ModelDef* md, double* jacInputs);

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. parameters.
 */
int miEvalJacDAEResidualParameters(ModelDef* md, double* jacParameters);


#endif /*MODELINTERFACE_H_*/

