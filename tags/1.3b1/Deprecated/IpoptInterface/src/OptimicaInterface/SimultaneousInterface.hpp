// Copyright (C) 2009 Modelon AB
// All Rights reserved
// This file is published under the Common Public License 1.0.

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
	 * initialize allocates memory and initialize the model
	 */
	bool initialize();

	
	/**
	 * getDimension returns the number of variables and the number of
	 * constraints, respectively, in the problem.
	 */ 
	bool getDimensions(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr);
	
	/**
	 * getIntervalSpec returns data that specifies the optimization interval.
	 */
	bool getIntervalSpec(double& startTime, bool& startTimeFree, double& finalTime, bool& finalTimeFree);
	
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
	bool getBounds(double* x_lb, double* x_ub);

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

	/**
	 * Print the solution
	 */
	bool writeSolution(double* x);

	
	// Getters
	ModelInterface* getModel() const;       
	int getNumVars() const;                   
	int getNumEqConstr() const;                
	int getNumIneqConstr() const;             
	const double* getXInit() const;               
	const double* getX_lb() const;                
	const double* getX_ub() const;                
	int getNumNzJacEqConstr() const;          
	const int* getRowJacEqConstraintNzElements() const;
	const int* getColJacEqConstraintNzElements() const;
	const int getNumNzJacIneqConstr() const;            
	const int* getRowJacIneqConstraintNzElements() const;
	const int* getColJacIneqConstraintNzElements() const;
	int getNumColl() const;                       
	const double* getA() const;                      
	const double* getB() const;                      
	const double* getC() const;                      
	int getNumEl() const;                        
	const double* getMesh() const;                 
	                                
	double getStartTime() const;             
	bool getStartTimeFree() const;             
	double getFinalTime() const;               
	bool getFinalTimeFree() const;             

	const double* getModelStateInit() const;         
	const double* getModelDerivativeInit() const;    
	const double* getModelParameters() const;        
	const double* getModelInputInit() const;         
	const double* getModelOutputInit() const;        
	const double* getModelAlgebraicInit() const;     

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
    
	ModelInterface* model_;           // The model representation
	int nVars_;                       // Number of variables
	int nEqConstr_;                   // Number of equality constraints
	int nIneqConstr_;                 // Number of inequality constraints
	double* xInit_;                   // Initial point
	double* x_lb_;                    // Lower bound for x
	double* x_ub_;                    // Upper bound for x
	int nNzJacEqConstr_;              // Number of non-zeros in eq. constr. Jac.
	int* rowJacEqConstraintNzElements_;  // Row indices of non-zeros elements
	int* colJacEqConstraintNzElements_;  // Col indices of non-zero elements
	int nNzJacIneqConstr_;            // Number of non-zeros in ineq. constr. Jac.
	int* rowJacIneqConstraintNzElements_; // Row indices of non-zeros elements
	int* colJacIneqConstraintNzElements_; // Col indices of non-zero elements
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

	double* modelStateInit_;           // Initial state vector
	double* modelDerivativeInit_;      // Initial state derivatives
	double* modelParameters_;          // Parameters of dynamic model
	double* modelInputInit_;           // Initial inputs of dynamic model (TODO: really?)
	double* modelOutputInit_;          // Initial outputs of dynamic model
	double* modelAlgebraicInit_;          // Initial algebraic variables of dynamic model
	
	bool initialized_;                 // Flag indicating if the class is initialized
protected:
	virtual bool getDimensionsImpl(int& nVars, int& nEqConstr, int& nIneqConstr,
			                     int& nNzJacEqConstr, int& nNzJacIneqConstr) = 0;

	virtual bool getIntervalSpecImpl(double& startTime, bool& startTimeFree, double& finalTime, bool& finalTimeFree) = 0;
	
	virtual bool getNumElImpl(int& nEl) = 0;
	
	virtual bool getMeshImpl(double* mesh) = 0;
	
	virtual bool getModelImpl(ModelInterface*& model) = 0;
	
	virtual bool evalCostImpl(const double* x, double& f) = 0;

	virtual bool evalGradCostImpl(const double* x, double* grad_f) = 0;

	virtual bool evalEqConstraintImpl(const double* x, double* gEq) = 0;

	virtual bool evalJacEqConstraintImpl(const double* x, double* jac_gEq) = 0;

	virtual bool evalIneqConstraintImpl(const double* x, double* gIneq) = 0;

	virtual bool evalJacIneqConstraintImpl(const double* x, double* jac_gIneq) = 0;

	virtual bool getBoundsImpl(double* x_lb, double* x_ub) = 0;

	virtual bool getInitialImpl(double* x_init) = 0;

	virtual bool getJacEqConstraintNzElementsImpl(int* rowIndex, int* colIndex) = 0;

	virtual bool getJacIneqConstraintNzElementsImpl(int* rowIndex, int* colIndex) = 0;
	
};

#endif /*SIMULTANEOUSINTERFACE_HPP_*/
