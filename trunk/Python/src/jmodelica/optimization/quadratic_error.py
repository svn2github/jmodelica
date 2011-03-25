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
			ndarray (of 1 or 2 dimensions)
			The measurement values. The number of rows in the 
			array corresponds to the number of physical quantities
			measured.
			NB: Must have same length as t_meas and same number of 
				rows as y_sim.
		
		t_sim --
			ndarray (of 1 dimension)
			The simulation time points. 
			NB: Must be increasing.
			
		y_sim --
			ndarray (of 1 or 2 dimensions)
			The simulation values. The number of rows in the array 
			corresponds to the number of physical quantities simulated.
			NB: Must have same length as t_sim and same number of 
				rows as y_meas.
	
	Returns::
	
		err --
			float
			The quadratic error.
	"""
	
	# The number of dimensions of y_meas
	dim1 = N.ndim(y_meas)
	
	# The number of rows and columns in y_meas
	if dim1 == 1:
		m1 = 1
		n1 = len(y_meas)
	else:
		m1 = N.size(y_meas,0)
		n1 = N.size(y_meas,1)
	
	# The number of dimensions of y_sim
	dim2 = N.ndim(y_sim)
	
	# The number of rows and columns in y_sim
	if dim2 == 1:
		m2 = 1
		n2 = len(y_sim)
	else:
		m2 = N.size(y_sim,0)
		n2 = N.size(y_sim,1)
	
	if len(t_meas) is not n1:
		raise ValueError, 't_meas and y_meas must have the same length.'
	
	if len(t_sim) is not n2:
		raise ValueError, 't_sim and y_sim must have the same length.'
	
	if m1 is not m2:
		raise ValueError, 'y_meas and y_sim must have the same number of rows.'
	
	if not N.all(N.diff(t_sim) >= 0):
		raise ValueError, 't_sim must be increasing.'
	
	# The number of measurement points
	n = n1
	
	# The number of rows in y_meas and y_sim
	m = m1
	
	# Interpolate to get the simulated values in the measurement points
	Y_sim = N.zeros([m,n])
	if m == 1:
		Y_sim = N.interp(t_meas,t_sim,y_sim)
	else:
		for i in range(m):
			Y_sim[i] = N.interp(t_meas,t_sim,y_sim[i])
	
	# Check if the same time point occurs more than once in t_sim and 
	# then fix the problem
	for i in range(len(t_sim)):
		val = t_sim[i]
		rest = t_sim[i+1:]
		if val in rest and val in t_meas:
			ind1 = t_sim == val
			y_sim_val = y_sim[:,ind1]
			ind2 = t_meas == val
			if m == 1:
				Y_sim[:,ind2] = sum(y_sim_val)*1.0/len(y_sim_val)
			else:
				vec = N.sum(y_sim_val,1)*1.0/N.size(y_sim_val,1)
				for j in range(m):
					Y_sim[j,ind2] = vec[j]
		
	# Evaluate the error
	err = sum((Y_sim - y_meas)**2,0)
	
	if m == 1:
		return err
	else:
		return sum(err)
