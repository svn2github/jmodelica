#import "../../ModelInterface/ModelInterface.h"

/**
 * This file encodes the model
 * 
 *   \dot x_1 = (1 - x_2^2)*x_1 - x_2 + u
 *   \dot x_2 = p_1*x_1
 *   \dot x_3 = x_1^2 + x_2^2 + u^2
 *
 */

/**
 * miInitModel initializes the model and creates an ModelDef instance
 */
ModelDef* miInitModel() {

	// Create a model "object"
	ModelDef* m = (ModelDef*)malloc(sizeof(ModelDef));
		
	// Retrieve model dimensions
	miGetDimensions(&(m->nStates), &(m->nDerivatives), 
			        &(m->nInputs), &(m->nOutputs),
			        &(m->nAlgebraic), &(m->nParameters), 
			        &(m->nEqns));
   
	// Allocate memory
    m->states = calloc((m->nStates)+1, sizeof(double));
    m->derivatives = calloc((m->nDerivatives)+1, sizeof(double));
    m->inputs = calloc((m->nInputs)+1, sizeof(double));
    m->algebraic = calloc((m->nAlgebraic)+1, sizeof(double));
    m->parameters = calloc((m->nParameters)+1, sizeof(double));

    return m;
    
}

/**
 * miGetDimensions retrieves the dimensions of the model variable vectors.
 */
int miGetDimensions(int* nStates, int* nDerivatives, 
		          int* nInputs, int* nOutputs,
		          int* nAlgebraic, int* nParameters,
		          int* nEqns) {

	*nStates = 3;
	*nDerivatives = 3;
	*nInputs = 1;
	*nOutputs = 0;
	*nAlgebraic = 0;
	*nParameters = 1;
	*nEqns = 3;

	return 1;

}

/**
 * Evaluate the residual of the DAE. The argument res should have the
 * the size nEqns.
 */
int miEvalDAEResidual(ModelDef* md, double* res) {
	double* x = md->states;
	double* dx = md->derivatives;
	double* u = md->inputs;
//	double* y = md->outputs;
//	double* z = md->algebraic;
	double* p = md->parameters;
	
	res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
	res[1] = p[0]*x[0] - dx[1];
	res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0];
	
	return 1;
}

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. state variables.
 */
int miEvalJacDAEResidualStates(ModelDef* md, double* jacStates) {
	double* x = md->states;
//	double* dx = md->derivatives;
//	double* u = md->inputs;
//	double* y = md->outputs;
//	double* z = md->algebraic;
	double* p = md->parameters;

	jacStates[0] = (1-x[1]*x[1]);
   	jacStates[1] = p[0];
   	jacStates[2] = 2*x[0];
   	jacStates[3] = -2*x[1]*x[0] - 1;
 	jacStates[4] = 0;
  	jacStates[5] = 2*x[1];
   	jacStates[6] = 0;
   	jacStates[7] = 0;
   	jacStates[8] = 0;
	
	return 1;
}

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. derivatives.
 */
int miEvalJacDAEResidualDerivatives(ModelDef* md, double* jacDerivatives) {
  
	jacDerivatives[0] = -1;
   	jacDerivatives[1] = 0;
   	jacDerivatives[2] = 0;
   	jacDerivatives[3] = 0;
 	jacDerivatives[4] = -1;
  	jacDerivatives[5] = 0;
   	jacDerivatives[6] = 0;
   	jacDerivatives[7] = 0;
   	jacDerivatives[8] = -1;

	return 1;
}

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. inputs.
 */
int miEvalJacDAEResidualInputs(ModelDef* md, double* jacInputs) {

//	double* x = md->states;
//	double* dx = md->derivatives;
	double* u = md->inputs;
//	double* y = md->outputs;
//	double* z = md->algebraic;
//	double* p = md->parameters;

	jacInputs[0] = 1;
   	jacInputs[1] = 0;
   	jacInputs[2] = 2*u[0];
	
	return 1;
}

/**
 * miEvalJacDAEResidualStates returns the Jacobian of the DAE
 * w.r.t. parameters.
 */
int miEvalJacDAEResidualParameters(ModelDef* md, double* jacParameters) {
	
	double* x = md->states;
//	double* dx = md->derivatives;
//	double* u = md->inputs;
//	double* y = md->outputs;
//	double* z = md->algebraic;
//	double* p = md->parameters;

	jacParameters[0] = 0;
   	jacParameters[1] = x[0];
   	jacParameters[2] = 0;
	
	return 1;
}

