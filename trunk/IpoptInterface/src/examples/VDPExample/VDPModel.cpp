#include "VDPModel.hpp"

VDPModel::VDPModel()
:
	ModelInterface()
{
}

VDPModel::~VDPModel()
{
}


/**
 * getDimensions retrieves the dimensions of the model variable vectors.
 */
bool VDPModel::getDimensionsImpl(int& nStates, int& nDerivatives, 
		          int& nParameters, int& nInputs, 
		          int& nOutputs, int& nAlgebraic,
		          int& nEqns) {

	nStates = 3;
	nDerivatives = 3;
	nInputs = 1;
	nOutputs = 0;
	nAlgebraic = 0;
	nParameters = 1;
	nEqns = 3;

	return true;
}

/**
 * Evaluate the residual of the DAE. The argument res should have the
 * the size nEqns.
 */
bool VDPModel::evalDAEResidualImpl(const double* x, const double* dx, const double* p,
		             const double* u, const double* y, const double* z, double* res) {

	res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
	res[1] = p[0]*x[0] - dx[1];
	res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0];

	return true;
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. state variables.
 */
bool VDPModel::evalJacDAEResidualStatesImpl(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacStates) {

	jacStates[0] = (1-x[1]*x[1]);
   	jacStates[1] = p[0];
   	jacStates[2] = 2*x[0];
   	jacStates[3] = -2*x[1]*x[0] - 1;
 	jacStates[4] = 0;
  	jacStates[5] = 2*x[1];
   	jacStates[6] = 0;
   	jacStates[7] = 0;
   	jacStates[8] = 0;

   	return true;
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. derivatives.
 */
bool VDPModel::evalJacDAEResidualDerivativesImpl(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacDerivatives) {

	jacDerivatives[0] = -1;
   	jacDerivatives[1] = 0;
   	jacDerivatives[2] = 0;
   	jacDerivatives[3] = 0;
 	jacDerivatives[4] = -1;
  	jacDerivatives[5] = 0;
   	jacDerivatives[6] = 0;
   	jacDerivatives[7] = 0;
   	jacDerivatives[8] = -1;

   	return true;
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. inputs.
 */
bool VDPModel::evalJacDAEResidualInputsImpl(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacInputs) {

	jacInputs[0] = 1;
   	jacInputs[1] = 0;
   	jacInputs[2] = 2*u[0];

   	return true;
}

/**
 * evalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. parameters.
 */
bool VDPModel::evalJacDAEResidualParametersImpl(const double* x, const double* dx, const double* p,
        const double* u, const double* y, const double* z, double* jacParameters) {
	
	jacParameters[0] = 0;
   	jacParameters[1] = x[0];
   	jacParameters[2] = 0;

   	return true;
   	
}
