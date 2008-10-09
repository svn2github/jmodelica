#include "SimultaneousInterface.hpp"

SimultaneousInterface::SimultaneousInterface()
:
model_(0),           // The model representation
nVars_(0),                       // Number of variables
nEqConstr_(0),        // Number of equality constraints
nIneqConstr_(0),                 // Number of inequality constraints
xInit_(0),                   // Initial point
x_lb_(0),                    // Lower bound for x
x_ub_(0),                    // Upper bound for x
nNzJacEqConstr_(0),              // Number of non-zeros in eq. constr. Jac.
colJacEqConstraintNzElements_(0),  // Col indices of non-zero elements
rowJacEqConstraintNzElements_(0),  // Row indices of non-zeros elements
nNzJacIneqConstr_(0),            // Number of non-zeros in ineq. constr. Jac.
colJacIneqConstraintNzElements_(0), // Col indices of non-zero elements
rowJacIneqConstraintNzElements_(0), // Row indices of non-zeros elements
nColl_(0),                       // Number of collocation points
A_(0),                       // The A matrix in the Butcher tableau
b_(0),                       // The b matrix in the Butcher tableau
c_(0),                       // The c matrix in the Butcher tableau
nEl_(0),                         // Number of elements
mesh_(0),                    // The optimization mesh expressed as
                                 // element lengths.
startTime_(0.0),                // Start time of optimization horizon
startTimeFree_(false),               // Problem with free start time
finalTime_(0.0),                // Final time of optimization horizon
finalTimeFree_(false)               // Problem with free final time
{

//	getDimensions(nVars_, nEqConstr_, nIneqConstr_, nNzJacEqConstr_, nNzJacIneqConstr_);

	xInit_ = (double*)calloc(nVars_ + 1,sizeof(double)); // Initial point
	x_lb_  = (double*)calloc(nVars_ + 1,sizeof(double)); // Lower bound for x
	x_ub_ = (double*)calloc(nVars_ + 1,sizeof(double));  // Upper bound for x

	colJacEqConstraintNzElements_ = 
		(int*)calloc(nNzJacEqConstr_ + 1,sizeof(int)); // Col indices of non-zero elements
	rowJacEqConstraintNzElements_ =
		(int*)calloc(nNzJacEqConstr_ + 1,sizeof(int)); // Row indices of non-zeros elements
	colJacIneqConstraintNzElements_ = 
		(int*)calloc(nNzJacIneqConstr_ + 1,sizeof(int)); // Col indices of non-zero elements
	rowJacIneqConstraintNzElements_ =
		(int*)calloc(nNzJacIneqConstr_ + 1,sizeof(int)); // Row indices of non-zeros elements

}

SimultaneousInterface::~SimultaneousInterface()
{
	free(xInit_);
	free(x_lb_);
	free(x_ub_),
	free(colJacEqConstraintNzElements_);
	free(rowJacEqConstraintNzElements_);
	free(colJacIneqConstraintNzElements_); 
	free(rowJacIneqConstraintNzElements_);
}
