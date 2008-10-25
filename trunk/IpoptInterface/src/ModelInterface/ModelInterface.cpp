#include "ModelInterface.hpp"

#include <stdlib.h>
#include <iostream>



ModelInterface::ModelInterface()
:
nStates_(0),                // Number of states
nDerivatives_(0),           // Number of derivatives
nParameters_(0),            // Number of parameters
nInputs_(0),                // Number of intputs
nOutputs_(0),               // Number of outputs in the model
nAlgebraic_(0),             // Number of auxilary variables
nEqns_(0),                   // Number of equations in the DAE
states_(NULL),              // State vector
derivatives_(NULL),         // Derivative vector
parameters_(NULL),          // Parameter vector
inputs_(NULL),              // Input vector
outputs_(NULL),             // Output vector 
algebraic_(NULL),           // Algebraic vector 
initialized_(false)
{
}
ModelInterface::~ModelInterface()
{
		delete [] states_;
		delete [] derivatives_;
	    delete [] parameters_;
	    delete [] inputs_;
	    delete [] outputs_;
	    delete [] algebraic_;

}

/**
 * initialize allocates memory and initialize the model
 */
bool ModelInterface::initialize() {

	if (!initialized_) {
	// Retrieve model dimensions
	getDimensionsImpl(nStates_, nDerivatives_, 
			          nParameters_ ,nInputs_, nOutputs_,
			          nAlgebraic_, 
			          nEqns_);

	// Allocate memory
    states_ = new double[nStates_];
    derivatives_ = new double[nDerivatives_];
    parameters_ = new double[nParameters_];
    inputs_ = new double[nInputs_];
    outputs_ = new double[nOutputs_];
    algebraic_ = new double[nAlgebraic_];
 
    // Get consistent initial conditions
    getInitialImpl(states_, derivatives_, parameters_, inputs_, 
    		       outputs_, algebraic_);
    
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
	
    nStates = nStates_;
    nDerivatives = nDerivatives_;
    nInputs = nInputs_;
    nOutputs = nOutputs_;
    nAlgebraic = nAlgebraic_;
    nParameters = nParameters_;
    nEqns = nEqns_;

    return true;
}

bool ModelInterface::getInitial(double* x, double* dx, double* p, double* u,
		                        double* y, double* z) {	
	return getInitialImpl(x, dx, p, u, y, z);

}

/**
 * Evaluate the residual of the DAE. The argument res should have the
 * the size nEqns.
 */
bool ModelInterface::evalDAEResidual(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* res) {
	
    return evalDAEResidualImpl(x, dx, p, u, y, z, res);

}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. state variables.
 */
bool ModelInterface::evalJacDAEResidualStates(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacStates){

	return evalJacDAEResidualStatesImpl(x, dx, p, u, y, z, jacStates);
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. derivatives.
 */
bool ModelInterface::evalJacDAEResidualDerivatives(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacDerivatives) {
	
    return evalJacDAEResidualDerivativesImpl(x, dx, p, u, y, z, jacDerivatives);
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. inputs.
 */
bool ModelInterface::evalJacDAEResidualInputs(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacInputs){
	
    return evalJacDAEResidualInputsImpl(x, dx, p, u, y, z, jacInputs);
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. parameters.
 */
bool ModelInterface::evalJacDAEResidualParameters(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacParameters){
	
    return evalJacDAEResidualParametersImpl(x, dx, p, u, y, z, jacParameters);	

}

bool ModelInterface::evalJacDAEResidualAlgebraic(const double* x, const double* dx, const double* p, const double* u,
        const double* y, const double* z, double* jacAlgebraic){
	
    return evalJacDAEResidualAlgebraicImpl(x, dx, p, u, y, z, jacAlgebraic);	

}

bool ModelInterface::prettyPrint() {

	std::cout << "Dynamic model data:" << std::endl;
	std::cout << "Number of states                                   :" << nStates_ << std::endl;
	std::cout << "Number of derivatives                              :" << nDerivatives_ << std::endl;
	std::cout << "Number of parameters                               :" << nParameters_ << std::endl;
	std::cout << "Number of inputs                                   :" << nInputs_ << std::endl;
	std::cout << "Number of output                                   :" << nOutputs_ << std::endl;
	std::cout << "Number of algebraic                                :" << nAlgebraic_ << std::endl;

	std::cout << std::endl;
	
	return true;

}


// Getters
int ModelInterface::getNumStates() {
	return nStates_;
}

int ModelInterface::getNumDerivatives() {
	return nDerivatives_;
}

int ModelInterface::getNumInputs() {
	return nInputs_;
}
int ModelInterface::getNumOutputs() {
	return nOutputs_;
}

int ModelInterface::getNumAlgebraic() {
	return nAlgebraic_;
}

int ModelInterface::getNumParameters() {
	return nParameters_;
}

int ModelInterface::getNumEqns() {
	return nEqns_;
}
