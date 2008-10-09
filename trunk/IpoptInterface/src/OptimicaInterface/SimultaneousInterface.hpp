#ifndef SIMULTANEOUSINTERFACE_HPP_
#define SIMULTANEOUSINTERFACE_HPP_

#include <stdlib.h>
#include <stdio.h>

#include "../ModelInterface/ModelInterface.hpp"

/**
 * The class SimultaneousInterface provides an interface to a  dynamic optimization
 * problem based on a simultaneous transcription method. The public interface 
 * provides methods for accessing the problem dimensions as well as for evaluation
 * of the cost function, its constraints etc. 
 * 
 * SimultaneousInterface is intended to be used as a base class, in which case the
 * protected virtual methods with suffix 'Impl' need to be overridden. The public 
 * non-virtual methods then invokes the 'Impl' methods when needed. This design
 * enables the initialization of the class itself to be done entirely in the 
 * base class SimultaneousInterface, without the need for derived classes to deal
 * with initialization and memory allocation. This is achieved by each public
 * non-virtual method performing a check whether the class is initialized or not. 
 * If its not, the method 'initialize' is called.
 * 
 */
class SimultaneousInterface
{
public:
	SimultaneousInterface();
	
	virtual ~SimultaneousInterface();
		
	/**
	 * getDimension returns the number of variables and the number of
	 * constraints, respectively, in the problem.
	 */ 
	bool getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr);

	/**
	 * evalCost returns the cost function value at a given point in search space.
	 */
	bool evalCost(const double* x, double& f);

	/**
	 * evalGradCost returns the gradient of the cost function value at 
	 * a given point in search space.
	 */
	bool evalGradCost(const double* x, double* grad_f);

	/**
	 * evalEqConstraints returns the residual of the equality constraints
	 */
	bool evalEqConstraint(const double* x, double* gEq);

	/**
	 * evalJacEqConstraints returns the Jacobian of the residual of the 
	 * equality constraints.
	 */
	bool evalJacEqConstraint(const double* x, double* jac_gEq);

	/**
	 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
	 */
	bool evalIneqConstraint(const double* x, double* gIneq);

	/**
	 * evalJacIneqConstraints returns Jacobian of the residual of the 
	 * inequality constraints g(x)<=0
	 */
	bool evalJacIneqConstraint(const double* x, double* jac_gIneq);

	/**
	 * getBounds returns the upper and lower bounds on the optimization variables.
	 */
	bool getBounds(double* x_ub, double* x_lb);

	/**
	 * getInitial returns the initial point.
	 */
	bool getInitial(double* x_init);

	/** 
	 * getEqConstraintNzElements returns the indices of the non-zeros in the 
	 * equality constraint Jacobian.
	 */
	bool getJacEqConstraintNzElements(int* colIndex, int* rowIndex);

	/** 
	 * getIneqConstraintElements returns the indices of the non-zeros in the 
	 * inequality constraint Jacobian.
	 */
	bool getJacIneqConstraintNzElements(int* colIndex, int* rowIndex);
	
	/**
	 * Print the problem specification
	 */
	bool prettyPrint();
	
private:

    /**@name Default Compiler Generated Methods
     * (Hidden to avoid implicit creation/calling).
     * These methods are not implemented and 
     * we do not want the compiler to implement
     * them for us, so we declare them private
     * and do not define them. This ensures that
     * they will not be implicitly created/called. */
    //@{
    /** Default Constructor */
//    SimultaneousInterface();

    /** Copy Constructor */
    SimultaneousInterface(const SimultaneousInterface&);

    /** Overloaded Equals Operator */
    void operator=(const SimultaneousInterface&);
    //@}
	
	/**
	 * initialize allocates memory and initialize the model
	 */
	bool initialize();

    
	ModelInterface* model_;           // The model representation
	int nVars_;                       // Number of variables
	int nEqConstr_;                   // Number of equality constraints
	int nIneqConstr_;                 // Number of inequality constraints
	double* xInit_;                   // Initial point
	double* x_lb_;                    // Lower bound for x
	double* x_ub_;                    // Upper bound for x
	int nNzJacEqConstr_;              // Number of non-zeros in eq. constr. Jac.
	int* colJacEqConstraintNzElements_;  // Col indices of non-zero elements
	int* rowJacEqConstraintNzElements_;  // Row indices of non-zeros elements
	int nNzJacIneqConstr_;            // Number of non-zeros in ineq. constr. Jac.
	int* colJacIneqConstraintNzElements_; // Col indices of non-zero elements
	int* rowJacIneqConstraintNzElements_; // Row indices of non-zeros elements
	int nColl_;                       // Number of collocation points
	double* A_;                       // The A matrix in the Butcher tableau
	double* b_;                       // The b matrix in the Butcher tableau
	double* c_;                       // The c matrix in the Butcher tableau
	int nEl_;                         // Number of elements
	double* mesh_;                    // The optimization mesh expressed as
	                                 // element lengths.
	double startTime_;                // Start time of optimization horizon
	bool startTimeFree_;               // Problem with free start time
	double finalTime_;                // Final time of optimization horizon
	bool finalTimeFree_;               // Problem with free final time

	bool initialized_;                 // Flag indicating if the class is initialized
protected:
	/**
	 * getDimension returns the number of variables and the number of
	 * constraints, respectively, in the problem.
	 */ 
	virtual bool getDimensionsImpl(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr)=0;

	/**
	 * evalCost returns the cost function value at a given point in search space.
	 */
	virtual bool evalCostImpl(const double* x, double& f)=0;

	/**
	 * evalGradCost returns the gradient of the cost function value at 
	 * a given point in search space.
	 */
	virtual bool evalGradCostImpl(const double* x, double* grad_f)=0;

	/**
	 * evalEqConstraints returns the residual of the equality constraints
	 */
	virtual bool evalEqConstraintImpl(const double* x, double* gEq)=0;

	/**
	 * evalJacEqConstraints returns the Jacobian of the residual of the 
	 * equality constraints.
	 */
	virtual bool evalJacEqConstraintImpl(const double* x, double* jac_gEq) = 0;

	/**
	 * evalIneqConstraints returns the residual of the inequality constraints g(x)<=0
	 */
	virtual bool evalIneqConstraintImpl(const double* x, double* gIneq) = 0;

	/**
	 * evalJacIneqConstraints returns Jacobian of the residual of the 
	 * inequality constraints g(x)<=0
	 */
	virtual bool evalJacIneqConstraintImpl(const double* x, double* jac_gIneq) = 0;

	/**
	 * getBounds returns the upper and lower bounds on the optimization variables.
	 */
	virtual bool getBoundsImpl(double* x_ub, double* x_lb) = 0;

	/**
	 * getInitial returns the initial point.
	 */
	virtual bool getInitialImpl(double* x_init) = 0;

	/** 
	 * getEqConstraintNzElements returns the indices of the non-zeros in the 
	 * equality constraint Jacobian.
	 */
	virtual bool getJacEqConstraintNzElementsImpl(int* colIndex, int* rowIndex) = 0;

	/** 
	 * getIneqConstraintElements returns the indices of the non-zeros in the 
	 * inequality constraint Jacobian.
	 */
	virtual bool getJacIneqConstraintNzElementsImpl(int* colIndex, int* rowIndex) = 0;
	
	
	
};

#endif /*SIMULTANEOUSINTERFACE_HPP_*/
