import numpy as N

def quad_err(t_meas,y_meas,t_sim,y_sim,w=None):
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
				
		w --
			scalar or ndarray (of 1 dimension)
			Scaling factor(s). If y_meas and y_sim are 1-dimensional, then
			w must be a scalar. Otherwise, w must be a 1-dimensional array
			with the same number of elements as the number of rows in y_meas 
			and y_sim. 			
			Example: If w = [w1 w2 w2], then the first row in y_meas and 
			y_sim is multiplied with w1, the second with w2 and the third 
			with w3.
			If w is not supplied, then it is set to 1 or a 1-dimensional 
			array of ones.
			Default: None 
			
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
	
	if len(t_meas) != n1:
		raise ValueError, 't_meas and y_meas must have the same length.'
	
	if len(t_sim) != n2:
		raise ValueError, 't_sim and y_sim must have the same length.'
	
	if m1 != m2:
		raise ValueError, 'y_meas and y_sim must have the same number of rows.'
	
	if not N.all(N.diff(t_sim) >= 0):
		raise ValueError, 't_sim must be increasing.'
	
	if w is None:
		if dim1 == 1:
			w = 1
		else:
			w = N.ones(m1)
	else:
		if dim1 == 1:
			if N.ndim(w) != 0:
				raise ValueError, 'w must be a scalar since y_meas and y_sim only have one dimension.'
		else:
			if N.ndim(w) != 1:
				raise ValueError, 'w must be a 1-dimensional array since y_meas and y_sim are 2-dimensional.'
			if (len(w) != m1):
				raise ValueError, 'w must have the same length as the number of rows in y_meas and y_sim.'
			
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
	X = Y_sim - y_meas
	if m == 1:
		err = w*sum(X**2,0)
	else:
		qX2 = N.dot(w,X**2)
		err = sum(qX2)
	return err
