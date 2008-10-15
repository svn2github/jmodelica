#include "SimultaneousInterface.hpp"

#include <iostream>
#include <fstream>

using namespace std;

SimultaneousInterface::SimultaneousInterface()
:
	model_(NULL),           // The model representation
	nVars_(0),                       // Number of variables
	nEqConstr_(0),        // Number of equality constraints
	nIneqConstr_(0),                 // Number of inequality constraints
	xInit_(NULL),                   // Initial point
	x_lb_(NULL),                    // Lower bound for x
	x_ub_(NULL),                    // Upper bound for x
	nNzJacEqConstr_(0),              // Number of non-zeros in eq. constr. Jac.
	rowJacEqConstraintNzElements_(NULL),  // Row indices of non-zeros elements
	colJacEqConstraintNzElements_(NULL),  // Col indices of non-zero elements
	nNzJacIneqConstr_(0),            // Number of non-zeros in ineq. constr. Jac.
	rowJacIneqConstraintNzElements_(NULL), // Row indices of non-zeros elements
	colJacIneqConstraintNzElements_(NULL), // Col indices of non-zero elements
	nColl_(0),                       // Number of collocation points
	A_(NULL),                       // The A matrix in the Butcher tableau
	b_(NULL),                       // The b matrix in the Butcher tableau
	c_(NULL),                       // The c matrix in the Butcher tableau
	nEl_(0),                         // Number of elements
	mesh_(NULL),                    // The optimization mesh expressed as
	// element lengths.
	startTime_(0.0),                // Start time of optimization horizon
	startTimeFree_(false),               // Problem with free start time
	finalTime_(0.0),                // Final time of optimization horizon
	finalTimeFree_(false),               // Problem with free final time
	
	modelStateInit_(NULL),           // Initial state vector
	modelDerivativeInit_(NULL),      // Initial state derivatives
	modelParameters_(NULL),          // Parameters of dynamic model
    modelInputInit_(NULL),           // Initial inputs of dynamic model (TODO: really?)
    modelOutputInit_(NULL),          // Initial outputs of dynamic model
	modelAlgebraicInit_(NULL),          // Initial algebraic variables of dynamic model
	
	initialized_(false)

	{

	}

SimultaneousInterface::~SimultaneousInterface()
{
	delete model_;
	
		delete [] xInit_;
		delete [] x_lb_;
		delete [] x_ub_;
		delete [] rowJacEqConstraintNzElements_;
		delete [] colJacEqConstraintNzElements_;
		delete [] rowJacIneqConstraintNzElements_;
		delete [] colJacIneqConstraintNzElements_; 

		delete [] modelStateInit_;
		delete [] modelDerivativeInit_;
		delete [] modelParameters_;
		delete [] modelInputInit_;
		delete [] modelOutputInit_;
		delete [] modelAlgebraicInit_;

}

/**
 * initialize allocates memory and initialize the model
 */
bool SimultaneousInterface::initialize() 
{
	if (!initialized_) {

		getModelImpl(model_);
		
		if (model_ != NULL) {
			
			int nStates = model_->getNumStates();
			int nDerivatives = model_->getNumDerivatives();
			int nParameters = model_->getNumParameters();
			int nInputs = model_->getNumInputs();
			int nOutputs = model_->getNumOutputs();
			int nAlgebraic = model_->getNumAlgebraic();

//			printf("SimultaneousInterface::initialize(): nStates_ = %d\n",nStates);
			
			modelStateInit_ = new double[nStates];
			modelDerivativeInit_ = new double[nDerivatives];
			modelParameters_ = new double[nParameters];
			modelInputInit_ = new double[nInputs];
			modelOutputInit_ = new double[nOutputs];
			modelAlgebraicInit_ = new double[nAlgebraic];

			model_->getInitial(modelStateInit_, modelDerivativeInit_, modelParameters_,
					modelInputInit_, modelOutputInit_, modelAlgebraicInit_);
		} 

		getDimensionsImpl(nVars_, nEqConstr_, nIneqConstr_, nNzJacEqConstr_, nNzJacIneqConstr_);

		xInit_ = new double[nVars_];
		x_lb_ = new double[nVars_];
		x_ub_ = new double[nVars_];

		rowJacEqConstraintNzElements_ = new int[nNzJacEqConstr_];
		colJacEqConstraintNzElements_ = new int[nNzJacEqConstr_];
		rowJacIneqConstraintNzElements_  = new int[nNzJacIneqConstr_];
		colJacIneqConstraintNzElements_ = new int[nNzJacIneqConstr_];

		// get bounds
		getBoundsImpl(x_lb_,x_ub_);

		// get initial point
		getInitialImpl(xInit_);

		// get non-zeros in inequality constraints
		getJacEqConstraintNzElementsImpl(rowJacEqConstraintNzElements_,
				colJacEqConstraintNzElements_);

		// get non-zeros in equality constraints
		getJacIneqConstraintNzElementsImpl(rowJacIneqConstraintNzElements_,
				colJacIneqConstraintNzElements_);

		getNumElImpl(nEl_);
		mesh_ = new double[nEl_];
		getMeshImpl(mesh_);

		getIntervalSpecImpl(startTime_, startTimeFree_, finalTime_, finalTimeFree_);
		
		// Remains to implement collocation matrices
		
		initialized_ = true;
	}
	return true;

}

/**
 * getDimension returns the number of variables and the number of
 * constraints, respectively, in the problem.
 */ 
bool SimultaneousInterface::getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
		int& nNzJacEqConstr, int& nNzJacIneqConstr)
{

//	std::cout << "SimultaneousInterface::getDimensions enter\n";
	
	nVars = nVars_;
	nEqConstr = nEqConstr_;
	nIneqConstr = nIneqConstr_;
	nNzJacEqConstr = nNzJacEqConstr_;
	nNzJacIneqConstr = nNzJacIneqConstr_;

//	std::cout << "SimultaneousInterface::getDimensions exit\n";
	
	return true;
}

/**
 * evalCost returns the cost function value at a given point in search space.
 */
bool SimultaneousInterface::evalCost(const double* x, double& f) {

//	std::cout << "SimultaneousInterface::evalCost enter\n";
	return evalCostImpl(x,f);
}

/**
 * evalGradCost returns the gradient of the cost function value at 
 * a given point in search space.
 */
bool SimultaneousInterface::evalGradCost(const double* x, double* grad_f){
//	std::cout << "SimultaneousInterface::evalGradCost enter\n";
	return evalGradCostImpl(x,grad_f);

}

/**
 * evalEqConstraints returns the residual of the equality constraints
 */
bool SimultaneousInterface::evalEqConstraint(const double* x, double* gEq){
//	std::cout << "SimultaneousInterface::evalEqConstraint enter\n";
	return evalEqConstraintImpl(x, gEq);
}

/**
 * evalJacEqConstraints returns the Jacobian of the residual of the 
 * equality constraints.
 */
bool SimultaneousInterface::evalJacEqConstraint(const double* x, double* jac_gEq){
//	std::cout << "SimultaneousInterface::evalJacEqConstraint enter\n";
	return evalJacEqConstraintImpl(x, jac_gEq);

}

/**
 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
 */
bool SimultaneousInterface::evalIneqConstraint(const double* x, double* gIneq){
//	std::cout << "SimultaneousInterface::evalIneqConstraint enter\n";
	return evalIneqConstraintImpl(x, gIneq);

}

/**
 * evalJacIneqConstraints returns Jacobian of the residual of the 
 * inequality constraints g(x)<=0
 */
bool SimultaneousInterface::evalJacIneqConstraint(const double* x, double* jac_gIneq){
//	std::cout << "SimultaneousInterface::evalJacIneqConstraint enter\n";
	return evalJacIneqConstraintImpl(x, jac_gIneq);

}

/**
 * getBounds returns the upper and lower bounds on the optimization variables.
 */
bool SimultaneousInterface::getBounds(double* x_lb, double* x_ub){
//	std::cout << "SimultaneousInterface::getBounds enter\n";
	int i = 0;
	for (i=0;i<nVars_;i++) {
		x_lb[i] = x_lb_[i];
		x_ub[i] = x_ub_[i];
	}

	return true;
}

/**
 * getInitial returns the initial point.
 */
bool SimultaneousInterface::getInitial(double* x_init){
//	std::cout << "SimultaneousInterface::getInitial enter\n";
	int i = 0;
	for (i=0;i<nVars_;i++) {
		x_init[i] = xInit_[i];
	}

	return true;

}

/** 
 * getEqConstraintNzElements returns the indices of the non-zeros in the 
 * equality constraint Jacobian.
 */
bool SimultaneousInterface::getJacEqConstraintNzElements(int* rowIndex, int* colIndex){
//	std::cout << "SimultaneousInterface::getJacEqConstraintNzElements enter\n";
	int i = 0;
	for (i=0;i<nNzJacEqConstr_;i++) {
		rowIndex[i] = rowJacEqConstraintNzElements_[i];
		colIndex[i] = colJacEqConstraintNzElements_[i];
	}

	return true;

}

/** 
 * getIneqConstraintElements returns the indices of the non-zeros in the 
 * inequality constraint Jacobian.
 */
bool SimultaneousInterface::getJacIneqConstraintNzElements(int* rowIndex, int* colIndex){
//	std::cout << "SimultaneousInterface::getJacIneqConstraintNzElements enter\n";
	int i = 0;
	for (i=0;i<nNzJacIneqConstr_;i++) {
		colIndex[i] = colJacIneqConstraintNzElements_[i];
		rowIndex[i] = rowJacIneqConstraintNzElements_[i];
	}
//	std::cout << "SimultaneousInterface::getJacIneqConstraintNzElements exit\n";
	return true;

}

/**
 * Print the problem specification
 */
bool SimultaneousInterface::prettyPrint() {

	std::cout << "NPL program data:" << std::endl;
	std::cout << "Number of variables                           :" << nVars_ << std::endl;
	std::cout << "Number of eq constr.                          :" << nEqConstr_ << std::endl;
	std::cout << "Number of ineq constr.                        :" << nIneqConstr_ << std::endl;
	std::cout << "Number of nz elements in eq. constr. Jac.     :" << nNzJacEqConstr_ << std::endl;
	std::cout << "Number of nz elements in ineq. constr. Jac.   :" << nNzJacIneqConstr_ << std::endl;
    std::cout << std::endl;
	
	return true;

}

bool SimultaneousInterface::writeSolution(double* x) {

	ofstream myfile;
	myfile.open ("opt_res.py");
	
	ModelInterface* model = getModel();
	
	int nStates = model->getNumStates();
	int nDerivatives = model->getNumDerivatives();
	int nInputs = model->getNumInputs();
	int nOutputs = model->getNumOutputs();
	int nAlgebraic = model->getNumAlgebraic();
	int nEqns = model->getNumEqns();

	int nEl = getNumEl();
	
	myfile << "#*** Optimal solution ***" << std::endl;
    myfile << "#Initial states:" << std::endl;
   	myfile << "x0 = array([";
    for (int i=0;i<nStates;i++) {
    	myfile << x[i];
    	if (i<nStates-1) {
    		myfile << ", ";
    	}
    }
	myfile << "])" << std::endl;
	
    myfile << "#States, derivatives, inputs, algebraics:" << std::endl;
   	myfile << "vars = array([";
    for (int i=0;i<nEl;i++){
    	myfile << "[";
    	for (int j=0;j<nStates;j++){
      		myfile << x[nStates+i*(nStates+nDerivatives+nInputs+nAlgebraic) + j] << ", ";	
     	}
    	for (int j=0;j<nDerivatives;j++){
    		myfile << x[nStates+nStates + i*(nStates+nDerivatives+nInputs+nAlgebraic) + j] << ", ";
    	}
    	for (int j=0;j<nInputs;j++){
       		if (j==nInputs-1 && nAlgebraic==0) {
    			myfile << x[nStates + nStates + nDerivatives +i*(nStates+nDerivatives+nInputs+nAlgebraic) + j];
    		} else {
    			myfile << x[nStates + nStates + nDerivatives +i*(nStates+nDerivatives+nInputs+nAlgebraic) + j] << ", ";
    		}
    	}
    	for (int j=0;j<nAlgebraic;j++){
       		if (j==nInputs-1) {
       			myfile << x[nStates + nStates + nDerivatives + nInputs + i*(nStates+nDerivatives+nInputs+nAlgebraic) + j];
       		} else {
       			myfile << x[nStates + nStates + nDerivatives + nInputs + i*(nStates+nDerivatives+nInputs+nAlgebraic) + j] << ", ";
       		}
       	}    	
    	myfile << "]";
    	if (i<nEl-1){
        	myfile << "," << std::endl;    		
    	}
    }
	myfile << "])" << std::endl;
    
	myfile.close();
    return true;
}



// Getters
ModelInterface* SimultaneousInterface::getModel() const {
	return model_;
}

int SimultaneousInterface::getNumVars() const {
	return nVars_;
}

int SimultaneousInterface::getNumEqConstr() const {
	return nEqConstr_;
}

int SimultaneousInterface::getNumIneqConstr() const {
	return nIneqConstr_;
}

const double* SimultaneousInterface::getXInit() const {
	return xInit_;
}

const double* SimultaneousInterface::getX_lb() const {
	return x_lb_;
}

const double* SimultaneousInterface::getX_ub() const {
	return x_ub_;
}

int SimultaneousInterface::getNumNzJacEqConstr() const {
	return nNzJacEqConstr_;
}

const int* SimultaneousInterface::getRowJacEqConstraintNzElements() const {
	return rowJacEqConstraintNzElements_;
}

const int* SimultaneousInterface::getColJacEqConstraintNzElements() const {
	return colJacEqConstraintNzElements_;
}

const int SimultaneousInterface::getNumNzJacIneqConstr() const {
	return nNzJacIneqConstr_;
}

const int* SimultaneousInterface::getRowJacIneqConstraintNzElements() const {
	return rowJacIneqConstraintNzElements_;
}

const int* SimultaneousInterface::getColJacIneqConstraintNzElements() const {
	return colJacIneqConstraintNzElements_;
}

int SimultaneousInterface::getNumColl() const {
	return nColl_;
}

const double* SimultaneousInterface::getA() const {
	return A_;
}

const double* SimultaneousInterface::getB() const {
	return b_;
}

const double* SimultaneousInterface::getC() const {
	return c_;
}

int SimultaneousInterface::getNumEl() const {
	return nEl_;
}

const double* SimultaneousInterface::getMesh() const {
	return mesh_;
}

double SimultaneousInterface::getStartTime() const {
	return startTime_;
}

bool SimultaneousInterface::getStartTimeFree() const {
	return startTimeFree_;
}

double SimultaneousInterface::getFinalTime() const {
	return finalTime_;
}

bool SimultaneousInterface::getFinalTimeFree() const {
	return finalTimeFree_;
}

const double* SimultaneousInterface::getModelStateInit() const {
	return modelStateInit_;
}

const double* SimultaneousInterface::getModelDerivativeInit() const {
	return modelDerivativeInit_;
}

const double* SimultaneousInterface::getModelParameters() const {
	return modelParameters_;
}

const double* SimultaneousInterface::getModelInputInit() const {
	return modelInputInit_;
}

const double* SimultaneousInterface::getModelOutputInit() const {
	return modelOutputInit_;
}

const double* SimultaneousInterface::getModelAlgebraicInit() const {
	return modelAlgebraicInit_;
}


