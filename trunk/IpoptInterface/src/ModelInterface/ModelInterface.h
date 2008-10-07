#ifndef MODELINTERFACE_H_
#define MODELINTERFACE_H_

/**
 * MIDef holds information about the model representation
 */
typedef struct {

	// Dimensions
	long nStates;                // Number of states
    long nDerivatives;           // Number of derivatives
	long nInputs;                // Number of intputs
	long nOutputs;               // Number of outputs in the model
	long nAuxiliary;             // Number of auxilary variables
	long nParameters;            // Number of parameters
    long nDAE;                   // Number of equations in the DAE
} MIDef;

static int evalRHS(MIDef* md, double* states, double* derivatives ,
		           double* inputs, double* aux, double* parameters, 
		           double* res);



#endif /*MODELINTERFACE_H_*/
