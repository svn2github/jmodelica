import numpy as N

def quad_err(t_meas,y_meas,t_sim,y_sim):
	"""
	Compute the quadratic error sum for the difference between 
	measurements and simulation results. The measurements and the 
	simulation results do not have to be given at the same time points.
	
	Parameters::
		
		t_meas --
			ndarray (of 1 dimension)
			The measurement time points.
			
		y_meas --
			ndarray
			The measurement values. The number of dimensions of the 
			array corresponds to the number of physical quantities
			measured.
		
		t_sim --
			ndarray (of 1 dimension)
			The simulation time points.
			
		y_sim --
			ndarray
			The simulation values. The number of dimensions of the array 
			corresponds to the number of physical quantities simulated.
	
	Returns::
	
		err --
			float
			The quadratic error.
	"""
	
	# The size of the array y_meas
	m, n = N.shape(y_meas)
	
	# Interpolate to get the simulated values in the measurement points
	Y_sim = N.zeros((m,n))
	for i in range(m):
		Y_sim[i] = N.interp(t_meas,t_sim,y_sim[i])
		
	# Evaluate the error
	err = sum(sum((Y_sim - y_meas)**2,0))
	
	return err
