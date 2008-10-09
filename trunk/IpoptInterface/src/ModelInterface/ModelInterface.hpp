#ifndef MODELINTERFACE_HPP_
#define MODELINTERFACE_HPP_

class ModelInterface
{
public:
	ModelInterface();
	virtual ~ModelInterface();


	/**
	 * getDimensions retrieves the dimensions of the model variable vectors.
	 */
	bool getDimensions(int& nStates, int& nDerivatives, 
			          int& nInputs, int& nOutputs,
			          int& nAlgebraic, int& nParameters,
			          int& nEqns);

	/**
	 * Evaluate the residual of the DAE. The argument res should have the
	 * the size nEqns.
	 */
	bool evalDAEResidual(const double* x, const double* dx, const double* u,
			             const double* y, const double* z, const double* p, double* res);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. state variables.
	 */
	bool evalJacDAEResidualStates(const double* x, const double* dx, const double* u,
            const double* y, const double* z, const double* p, double* jacStates);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. derivatives.
	 */
	bool evalJacDAEResidualDerivatives(const double* x, const double* dx, const double* u,
            const double* y, const double* z, const double* p, double* jacDerivatives);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. inputs.
	 */
	bool evalJacDAEResidualInputs(const double* x, const double* dx, const double* u,
            const double* y, const double* z, const double* p, double* jacInputs);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. parameters.
	 */
	bool evalJacDAEResidualParameters(const double* x, const double* dx, const double* u,
            const double* y, const double* z, const double* p, double* jacParameters);
	
	
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
    ModelInterface(const ModelInterface&);

    /** Overloaded Equals Operator */
    void operator=(const ModelInterface&);
    //@}
	
	/**
	 * initialize allocates memory and initialize the model
	 */
	bool initialize();
    
	// Dimensions
    int nStates_;                // Number of states
    int nDerivatives_;           // Number of derivatives
	int nInputs_;                // Number of intputs
	int nOutputs_;               // Number of outputs in the model
	int nAlgebraic_;             // Number of auxilary variables
	int nParameters_;            // Number of parameters
    int nEqns_;                   // Number of equations in the DAE

    double* states_;              // State vector
    double* derivatives_;         // Derivative vector
    double* parameters_;          // Parameter vector
    double* inputs_;              // Input vector
    double* outputs_;             // Output vector 
    double* algebraic_;           // Algebraic vector 

    bool initialized_;            // Flag to indicate wether the class is initialized or not.
protected:
	/**
	 * getDimensions retrieves the dimensions of the model variable vectors.
	 */
	virtual bool getDimensionsImpl(int& nStates, int& nDerivatives, 
			          int& nParameters, int& nInputs, 
			          int& nOutputs, int& nAlgebraic,
			          int& nEqns)=0;

	/**
	 * Evaluate the residual of the DAE. The argument res should have the
	 * the size nEqns.
	 */
	virtual bool evalDAEResidualImpl(const double* x, const double* dx, const double* p,
			             const double* u, const double* y, const double* z, double* res)=0;

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. state variables.
	 */
	virtual bool evalJacDAEResidualStatesImpl(const double* x, const double* dx, const double* p,
            const double* u, const double* y, const double* z, double* jacStates)=0;

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. derivatives.
	 */
	virtual bool evalJacDAEResidualDerivativesImpl(const double* x, const double* dx, const double* p,
            const double* u, const double* y, const double* z, double* jacDerivatives)=0;

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. inputs.
	 */
	virtual bool evalJacDAEResidualInputsImpl(const double* x, const double* dx, const double* p,
            const double* u, const double* y, const double* z, double* jacInputs)=0;

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. parameters.
	 */
	virtual bool evalJacDAEResidualParametersImpl(const double* x, const double* dx, const double* p,
            const double* u, const double* y, const double* z, double* jacParameters)=0;
	
};

#endif /*MODELINTERFACE_HPP_*/
