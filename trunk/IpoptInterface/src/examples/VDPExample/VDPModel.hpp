#ifndef VDPMODEL_HPP_
#define VDPMODEL_HPP_

#include "../../ModelInterface/ModelInterface.hpp"

/**
 * This file encodes the model
 * 
 *   \dot x_1 = (1 - x_2^2)*x_1 - x_2 + u
 *   \dot x_2 = p_1*x_1
 *   \dot x_3 = x_1^2 + x_2^2 + u^2
 *
 *   x_1(0) = 0
 *   x_2(0) = 1
 *   x_3(0) = 0
 * 
 *   p_1 = 1;
 * 
 */

class VDPModel : public ModelInterface
{
public:
	VDPModel();
	virtual ~VDPModel();

	/**
	 * getDimensions retrieves the dimensions of the model variable vectors.
	 */
	virtual bool getDimensionsImpl(int& nStates, int& nDerivatives, 
			          int& nParameters, int& nInputs, 
			          int& nOutputs, int& nAlgebraic,
			          int& nEqns);

	/** 
	 * getInitial computes consistend initial conditions.
	 */
	virtual bool getInitialImpl(double* x, double* dx, double* p, double* u,
			                    double* y, double* z);

	
	/**
	 * Evaluate the residual of the DAE. The argument res should have the
	 * the size nEqns.
	 */
	virtual bool evalDAEResidualImpl(const double* x, const double* dx, const double* p,
			             const double* u, const double* y, const double* z, double* res);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. state variables.
	 */
	virtual bool evalJacDAEResidualStatesImpl(const double* x, const double* dx, const double* p,
	        const double* u, const double* y, const double* z, double* jacStates);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. derivatives.
	 */
	virtual bool evalJacDAEResidualDerivativesImpl(const double* x, const double* dx, const double* p,
	        const double* u, const double* y, const double* z, double* jacDerivatives);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. inputs.
	 */
	virtual bool evalJacDAEResidualInputsImpl(const double* x, const double* dx, const double* p,
	        const double* u, const double* y, const double* z, double* jacInputs);

	/**
	 * evalJacDAEResidualStates returns the Jacobian of the DAE
	 * w.r.t. parameters.
	 */
	virtual bool evalJacDAEResidualParametersImpl(const double* x, const double* dx, const double* p,
	        const double* u, const double* y, const double* z, double* jacParameters);
	

	virtual bool evalJacDAEResidualAlgebraicImpl(const double* x, const double* dx, const double* p, const double* u,
            const double* y, const double* z, double* jacAlgebraic);

	
};

#endif /*VDPMODEL_HPP_*/
