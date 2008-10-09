#include "ModelInterface.hpp"

#include <stdlib.h>
#include <stdio.h>

ModelInterface::ModelInterface()
:
nStates_(0),                // Number of states
nDerivatives_(0),           // Number of derivatives
nInputs_(0),                // Number of intputs
nOutputs_(0),               // Number of outputs in the model
nAlgebraic_(0),             // Number of auxilary variables
nParameters_(0),            // Number of parameters
nEqns_(0),                   // Number of equations in the DAE
states_(0),              // State vector
derivatives_(0),         // Derivative vector
parameters_(0),          // Parameter vector
inputs_(0),              // Input vector
outputs_(0),             // Output vector 
algebraic_(0),           // Algebraic vector 
initialized_(0)
{
}
ModelInterface::~ModelInterface()
{
	if (initialized_) {
		free(states_);
		free(derivatives_);
	    free(parameters_);
	    free(inputs_);
	    free(outputs_);
	    free(algebraic_);
	}
}

/**
 * initialize allocates memory and initialize the model
 */
bool ModelInterface::initialize() {

	if (!initialized_) {
	// Retrieve model dimensions
	getDimensionsImpl(nStates_, nDerivatives_, 
			          nInputs_, nOutputs_,
			          nAlgebraic_, nParameters_, 
			          nEqns_);
   
	// Allocate memory
    states_ = (double*)calloc(nStates_+1, sizeof(double));
    derivatives_ = (double*)calloc(nDerivatives_+1, sizeof(double));
    inputs_ = (double*)calloc(nInputs_+1, sizeof(double));
    outputs_ = (double*)calloc(nOutputs_+1, sizeof(double));
    algebraic_ = (double*)calloc(nAlgebraic_+1, sizeof(double));
    parameters_ = (double*)calloc(nParameters_+1, sizeof(double));
    initialized_ = true;
	}
	return true;
}

/**
 * getDimensions retrieves the dimensions of the model variable vectors.
 */
bool ModelInterface::getDimensions(int& nStates, int& nDerivatives, 
		          int& nInputs, int& nOutputs,
		          int& nAlgebraic, int& nParameters,
		          int& nEqns) {
	
	if (!initialized_) 
		if (!initialize())
			return false;
    nStates = nStates_;
    nDerivatives = nDerivatives_;
    nInputs = nInputs_;
    nOutputs = nOutputs_;
    nAlgebraic = nAlgebraic_;
    nParameters = nParameters_;
    nEqns = nEqns_;
    
    return true;
}

/**
 * Evaluate the residual of the DAE. The argument res should have the
 * the size nEqns.
 */
bool ModelInterface::evalDAEResidual(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* res) {
	
	if (!initialized_) 
		if (!initialize())
			return false;
    
    return true;	
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. state variables.
 */
bool ModelInterface::evalJacDAEResidualStates(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacStates){
	
	if (!initialized_) 
		if (!initialize())
			return false;
    
    return true;	
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. derivatives.
 */
bool ModelInterface::evalJacDAEResidualDerivatives(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacDerivatives) {
	
	if (!initialized_) 
		if (!initialize())
			return false;
    
    return true;	
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. inputs.
 */
bool ModelInterface::evalJacDAEResidualInputs(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacInputs){
	
	if (!initialized_) 
		if (!initialize())
			return false;
    
    return true;	
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. parameters.
 */
bool ModelInterface::evalJacDAEResidualParameters(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacParameters){
	
	if (!initialized_) 
		if (!initialize())
			return false;
    
    return true;	
}


