#include "VDPOptimization.hpp"
#include "../../IpoptInterface/OptimicaTNLP.hpp"
#include "IpIpoptApplication.hpp"

VDPOptimization::VDPOptimization()
:
SimultaneousInterface(),
model_(NULL), // TODO: Is this one really needed?
modelInitialized_(false)
{
}

VDPOptimization::~VDPOptimization()
{
}

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */
bool VDPOptimization::getDimensionsImpl(int& nVars, int& nEqConstr, int& nIneqConstr,
		int& nNzJacEqConstr, int& nNzJacIneqConstr) {

	ModelInterface* model;
	getModelImpl(model);

	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	int nEqns = model->getNumEqns();

	// This model uses a hard coded backward euler scheme with N elements
	int nEl;
	getNumElImpl(nEl);

	nVars = (nEl+1)*nStates + nEl*(nDerivatives + nInputs + nOutputs + nAlgebraic);

	// This problem has no constraints apart from the equalit constraint resulting from
	// transcribed dynamical system
	nEqConstr = nEl*nEqns + // Equations for the differential equation
	nEl*nDerivatives + // Equations for the backward Euler approximation
	nStates; // Equations for the initial conditions

	nIneqConstr = 0;

	nNzJacEqConstr = nEl*nEqns*(nStates + nDerivatives + nInputs + nOutputs + nAlgebraic) + // Collocation of residuals
	nEl*3*nDerivatives + // Backward euler approximation of derivatives
	nStates; // initial conditions
	nNzJacIneqConstr = 0;

	return true;
}

bool VDPOptimization::getIntervalSpecImpl(double& startTime, bool& startTimeFree, double& finalTime, bool& finalTimeFree) {
	startTime = 0;
	startTimeFree = false;
	finalTime = 5;
	finalTimeFree = false;
	return true;
}

bool VDPOptimization::getModelImpl(ModelInterface*& model) {

	if (!modelInitialized_) {
		model_ = new VDPModel();
		model_->initialize();
		modelInitialized_ = true;
		/*    	if (model_==NULL)
    		printf("VDPOptimization::getModelImpl1(): model==NULL\n");
    	else
    		printf("VDPOptimization::getModelImpl1(): model!=NULL\n");
		 */

	}
	model = model_;
	/*	if (model_==NULL)
		printf("VDPOptimization::getModelImpl2(): model==NULL\n");
	else
		printf("VDPOptimization::getModelImpl2(): model!=NULL\n");
	 */
	return true;

}

bool VDPOptimization::getNumElImpl(int& nEl) {
	nEl = 100;
	return true;
}

bool VDPOptimization::getMeshImpl(double* mesh) {
	int nEl;
	getNumElImpl(nEl);
	for (int i=0;i<nEl;i++) {
		mesh[i] = 1/((double)nEl);
	}
	return true;
}

/**
 * evalCost returns the cost function value at a given point in search space.
 */
bool VDPOptimization::evalCostImpl(const double* x, double& f) {

	ModelInterface* model = getModel();

	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	//	int nEqns = model->getNumEqns();

	int N = getNumEl();

	// Find x_3(t_f)
	f = x[(nStates + (N-1)*(nStates + nDerivatives + nInputs + nOutputs + nAlgebraic) + nStates - 1)];
	return true;

}

/**
 * evalGradCost returns the gradient of the cost function value at
 * a given point in search space.
 */
bool VDPOptimization::evalGradCostImpl(const double* x, double* grad_f) {

	ModelInterface* model = getModel();

	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	//	int nEqns = model->getNumEqns();

	int nEl = getNumEl();

	for (int i=0;i<getNumVars();i++) {
		grad_f[i] = 0;
	}

	grad_f[(nStates + (nEl-1)*(nStates + nDerivatives + nInputs + nOutputs + nAlgebraic) + nStates - 1)] = 1;

	return true;

}

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
bool VDPOptimization::evalEqConstraintImpl(const double* x, double* gEq) {

	ModelInterface* model = getModel();

	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	//	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	int nEqns = model->getNumEqns();

	int nEl = getNumEl();

	double startTime = getStartTime();
	double finalTime = getFinalTime();

	const double* h = getMesh();

	// Evaluate the Collocation residuals
	const double* _x = NULL;
	const double* xInit = getModelStateInit();
	const double* dx = NULL;
	const double* p = getModelParameters();
	const double* u = NULL;
	const double* y = NULL;
	const double* z = NULL;

	double* gEqPtr = gEq;
	int gEqIndex = 0;

	for (int i=0;i<nEl;i++) {

		_x = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i;
		dx = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates;
		u = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives;
		z = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives + nInputs;

		model->evalDAEResidual(_x, dx, p, u, y,  z, gEqPtr);
		gEqPtr += nEqns;
		gEqIndex += nEqns;

	}

	// Evaluate the equations for the derivatives

	for (int i=0;i<nEl;i++) {
		_x = (double*)x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i;
		dx = (double*)x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates;

		if (i==0) {
			for (int j=0;j<nDerivatives;j++) {
				gEqPtr[j] = dx[j] - (_x[j] - _x[j-nStates])/(h[i]*(finalTime-startTime));
			}
		} else {
			for (int j=0;j<nDerivatives;j++) {
				gEqPtr[j] = dx[j] - (_x[j] - _x[j-nStates - nDerivatives - nInputs - nAlgebraic])/(h[i]*(finalTime-startTime));
			}
		}
		gEqPtr += nDerivatives;
		gEqIndex += nDerivatives;

	}

	// Evaluate the equations for the initial conditions
	for (int j=0;j<nStates;j++) {
		gEqPtr[j] = x[j] - xInit[j];
	}

	return true;
}

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the
 * equality constraints.
 */
bool VDPOptimization::evalJacEqConstraintImpl(const double* x, double* jac_gEq) {

	ModelInterface* model = getModel();

	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	//	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	int nEqns = model->getNumEqns();

	int nEl = getNumEl();

	// Evaluate the Collocation residuals
	const double* _x = NULL;
	const double* dx = NULL;
	const double* p = getModelParameters();
	const double* u = NULL;
	const double* y = NULL;
	const double* z = NULL;

	double startTime = getStartTime();
	double finalTime = getFinalTime();

	const double* h = getMesh();

	double* jac_gEqPtr = jac_gEq;

	// Jacobian for collocation equations
	for (int i=0;i<nEl;i++) {

		_x = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i;
		dx = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates;
		u = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives;
		z = x + nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives + nInputs;

		model->evalJacDAEResidualStates(_x, dx, p, u, y,  z, jac_gEqPtr);
		jac_gEqPtr += nEqns*(nStates);
		model->evalJacDAEResidualDerivatives(_x, dx, p, u, y,  z, jac_gEqPtr);
		jac_gEqPtr += nEqns*(nDerivatives);
		model->evalJacDAEResidualInputs(_x, dx, p, u, y,  z, jac_gEqPtr);
		jac_gEqPtr += nEqns*(nInputs);
		model->evalJacDAEResidualAlgebraic(_x, dx, p, u, y,  z, jac_gEqPtr);
		jac_gEqPtr += nEqns*(nAlgebraic);

	}

	// Jacobian for derivative equations
	for (int i=0;i<nEl;i++) {

			for (int j=0;j<nDerivatives;j++) {
				jac_gEqPtr[j] = 1/(h[i]*(finalTime-startTime));
			}
			jac_gEqPtr += nDerivatives;

			for (int j=0;j<nDerivatives;j++) {
				jac_gEqPtr[j] = -1/(h[i]*(finalTime-startTime));
			}
			jac_gEqPtr += nDerivatives;

			for (int j=0;j<nDerivatives;j++) {
				jac_gEqPtr[j] = 1;
			}
			jac_gEqPtr += nDerivatives;

	}

	// Jacobian for initial conditions
	for (int j=0;j<nDerivatives;j++) {
		jac_gEqPtr[j] = 1;
	}
	return true;

}

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
bool VDPOptimization::evalIneqConstraintImpl(const double* x, double* gIneq) {

	return true;
}

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the
 * inequality constraints g(x)<=0
 */
bool VDPOptimization::evalJacIneqConstraintImpl(const double* x, double* jac_gIneq) {
	return 1;
}

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
bool VDPOptimization::getBoundsImpl(double* x_lb, double* x_ub) {

	int nVars;
	int nEqConstr;
	int nIneqConstr;
	int nNzJacEqConstr;
	int nNzJacIneqConstr;

	getDimensionsImpl(nVars, nEqConstr, nIneqConstr, nNzJacEqConstr, nNzJacIneqConstr);

	// Set wide bounds. TODO: check what the values are to make IPOPT ignore them
	for (int i=0; i<=nVars; i++) {
		x_lb[i] = -1e20;
		x_ub[i] = 1e20;
	}

	return true;

}

/**
 * getInitial returns the initial point.
 */
bool VDPOptimization::getInitialImpl(double* xInit){

	int nVars;
	int nEqConstr;
	int nIneqConstr;
	int nNzJacEqConstr;
	int nNzJacIneqConstr;

	getDimensionsImpl(nVars, nEqConstr, nIneqConstr, nNzJacEqConstr, nNzJacIneqConstr);

	// Initialize everything to zero
	for (int i=0; i<=nVars; i++) {
		xInit[i] = 0;
	}

	return true;
}

/**
 * getEqConstraintNzElements returns the indices of the non-zeros in the
 * equality constraint Jacobian.
 */
bool VDPOptimization::getJacEqConstraintNzElementsImpl(int* rowIndex, int* colIndex) {
	//	ModelInterface* model;
	//	getModelImpl(model);
	ModelInterface* model = getModel();

	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	//	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	int nEqns = model->getNumEqns();

	int nEl;
	getNumElImpl(nEl);

	int _xIndex = 0;
	int dxIndex = 0;
	int uIndex = 0;
	int zIndex = 0;
	int eqnIndex = 0;
	int _colIndex = 0;
	int _rowIndex = 0;

	// Set sparsity pattern for DAE residuals
	for (int i=0;i<nEl;i++) {
		_xIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i;
		dxIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates;
		uIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives;
		zIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives + nInputs;
		eqnIndex = nEqns*i;

		for (int j=0;j<nStates;j++) {
			for (int k=0;k<nEqns;k++) {
				rowIndex[_rowIndex++] = eqnIndex + k +1;
				colIndex[_colIndex++] = _xIndex + j +1;
			}
		}

		for (int j=0;j<nDerivatives;j++) {
			for (int k=0;k<nEqns;k++) {
				rowIndex[_rowIndex++] = eqnIndex + k + 1;
				colIndex[_colIndex++] = dxIndex + j + 1;
			}
		}

		for (int j=0;j<nInputs;j++) {
			for (int k=0;k<nEqns;k++) {
				rowIndex[_rowIndex++] = eqnIndex + k + 1;
				colIndex[_colIndex++] = uIndex + j + 1;
			}
		}

		for (int j=0;j<nAlgebraic;j++) {
			for (int k=0;k<nEqns;k++) {
				rowIndex[_rowIndex++] = eqnIndex + k + 1;
				colIndex[_colIndex++] = zIndex + j + 1;
			}
		}

	}

	// Set sparsity pattern for derivative approximations

	for (int i=0;i<nEl;i++) {

		_xIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i;
		dxIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates;
		uIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives;
		zIndex = nStates + (nStates + nDerivatives + nInputs + nAlgebraic)*i + nStates + nDerivatives + nInputs;
		eqnIndex += nEqns;

		if (i==0) {
			for (int j=0;j<nDerivatives;j++) {
				rowIndex[_rowIndex++] = eqnIndex + j + 1;
				colIndex[_colIndex++] = _xIndex - nStates + j + 1;
			}
		} else {
			for (int j=0;j<nDerivatives;j++) {
				rowIndex[_rowIndex++] = eqnIndex + j + 1;
				colIndex[_colIndex++] = _xIndex - nStates -nDerivatives - nInputs - nAlgebraic + j + 1;
			}
		}

		for (int j=0;j<nStates;j++) {
			rowIndex[_rowIndex++] = eqnIndex + j + 1;
			colIndex[_colIndex++] = _xIndex + j + 1;
		}

		for (int j=0;j<nDerivatives;j++) {
			rowIndex[_rowIndex++] = eqnIndex + j + 1;
			colIndex[_colIndex++] = dxIndex + j + 1;
		}

	}

	eqnIndex += nEqns;

	for (int j=0;j<nStates;j++) {
		rowIndex[_rowIndex++] = eqnIndex + j + 1;
		colIndex[_colIndex++] = j + 1;
	}

	/*
	for (int i=0;i<getNumNzJacEqConstr();i++) {
		std::cout << rowIndex[i] << " " << colIndex[i] << std::endl;
	}
	 */
	//	std::cout << "VDPOptimization::getJacEqConstraintNzElementsImpl(): _rowIndex: " << _rowIndex << " _colIndex: " << _colIndex << std::endl;

	return true;

}

/**
 * getIneqConstraintElements returns the indices of the non-zeros in the
 * inequality constraint Jacobian.
 */
bool VDPOptimization::getJacIneqConstraintNzElementsImpl(int* rowIndex, int* colIndex) {

	// No inequality constraints.
	return true;

}


int main(int argv, char* argc[])
{

	//	using namespace Ipopt;

	//	printf("Hej!\n");
	// Create a new instance of your nlp
	//  (use a SmartPtr, not raw)
	VDPOptimization* op = new VDPOptimization();
	//Initialize first!
	op->initialize();
	op->getModel()->prettyPrint();
	op->prettyPrint();

	SmartPtr<TNLP> mynlp = new OptimicaTNLP(op);

	// Create a new instance of IpoptApplication
	//  (use a SmartPtr, not raw)
	SmartPtr<IpoptApplication> app = new IpoptApplication();

	// Change some options
	// Note: The following choices are only examples, they might not be
	//       suitable for your optimization problem.
	app->Options()->SetStringValue("output_file", "ipopt.out");
	app->Options()->SetStringValue("hessian_approximation","limited-memory");
	app->Options()->SetStringValue("derivative_test","first-order");
	//	app->Options()->SetIntegerValue("print_level",12);
	app->Options()->SetIntegerValue("max_iter",1000);

	// Intialize the IpoptApplication and process the options
	ApplicationReturnStatus status;
	status = app->Initialize();
	if (status != Solve_Succeeded) {
		printf("\n\n*** Error during initialization!\n");
		return (int) status;
	}

	// Ask Ipopt to solve the problem
	status = app->OptimizeTNLP(mynlp);

	if (status == Solve_Succeeded) {
		printf("\n\n*** The problem solved!\n");
	}
	else {
		printf("\n\n*** The problem FAILED!\n");
	}

	// As the SmartPtrs go out of scope, the reference count
	// will be decremented and the objects will automatically
	// be deleted.

	//delete op;

	return (int) status;
}
