"""
This file contains algorithms performing derivative-free optimization of
a function.
"""

import numpy as N
import scipy as S
import scipy.linalg
import matplotlib.pyplot as plt
import time
from openopt import GLP

def nelme(f,xstart,lb=None,ub=None,h=0.3,plot_con=False,plot_sim=False,
		  x_tol=1e-3,f_tol=1e-6,max_iters=500,max_fevals=5000,disp=True):
	"""
	Minimize a function of one or more variables using the 
	Nelder-Mead simplex method. Handles box bound constraints but not 
	very well.
	
	Parameters::
	
		f -- 
			callable f(x)
			The objective function to be minimized.
			
		xstart -- 
			ndarray or scalar
			The initial guess for x. 
			
		lb -- 
			ndarray or scalar
			The lower bound on x.
			Default: None
		
		ub --
			ndarray or scalar
			The upper bound on x.
			Default: None
		
		h -- 
			int
			The side length of the initial simplex.
			NB: 0 < h < 1 should be fulfilled.
			Default: 0.3	
			
		plot_con --
			bool
			Set to True if a contour plot of the objective function and
			plots of the bounds (if any) are desired. 
			NB: Only works for two dimensions.
			Default: False
		
		plot_sim --
			bool
			Set to True if a plot of the simplex in each iteration is 
			desired. 
			NB: Only works for two dimensions.
			Default: False
		
		x_tol --
			float
			The tolerance for the termination criteria for x. 
			Termination when all side lengths in the simplex have 
			reached this value.
			NB: x_tol < h must be fulfilled.
			Default: 1e-3
		
		f_tol --
			float
			The tolerance for the termination criteria for the objective 
			function. Termination when all vertix function values in the
			simplex are this close to each other.
			Default: 1e-6
		
		max_iters --
			int
			The maximum number of iterations allowed.
			Default: 500
			
		max_fevals --
			int
			The maximum number of function evaluations allowed.
			Default: 5000
			
		disp --
			bool
			Set to True to print convergence messages.
			Default: True
			
	Returns::
	
		x_opt --
			ndarray or scalar
			The optimal point which minimizes the objective function.
			
		f_opt --
			float
			The minimal value of the objective function.
		
		nbr_iters --
			int
			The number of iterations performed.
		
		nbr_fevals --
			int
			The number of function evaluations made.	
		
		solve_time --
			float
			The execution time for the solver in seconds.
	"""
	
	t0 = time.clock()
	
	# Check that lb < ub
	if ub is not None:	# "None" < everything
		if N.any(lb >= ub):
			raise ValueError, 'Lower bound must be smaller than upper bound.'
	
	# Check that lb < xstart < ub 
	if N.any(xstart <= lb):
		raise ValueError, 'xstart must be larger than lb.'
	if ub is not None:	# "None" < everything
		if N.any(xstart >= ub):
			raise ValueError, 'xstart must be smaller than ub.'
	
	# Convert xstart to float type array and flatten it so that 
	# len(xstart) can be used even if xstart is a scalar
	xstart = N.asfarray(xstart).flatten()	
	
	# Do the same with lb and ub
	if lb is not None:
		lb = N.asfarray(lb).flatten()
	if ub is not None:
		ub = N.asfarray(ub).flatten()
	
	# Number of dimensions
	n = len(xstart)
	
	# If not two dimensions nothing should be plotted
	if n != 2:
		plot_con = False
		plot_sim = False
	
	# Number of function evaluations
	nbr_fevals = 0
	
	if plot_con:
		
		# Create meshgrid
		if lb is None:
			x_min = xstart[0]-3*N.absolute(xstart[0])
			y_min = xstart[1]-3*N.absolute(xstart[1])
		else:
			x_min = lb[0]
			y_min = lb[1]
		if ub is None:
			x_max = xstart[0]+3*N.absolute(xstart[0])
			y_max = xstart[1]+3*N.absolute(xstart[1])
		else:
			x_max = ub[0]
			y_max = ub[1]
		x_vec = N.linspace(x_min,x_max,10)
		y_vec = N.linspace(y_min,y_max,10)
		x_grid,y_grid = N.meshgrid(x_vec,y_vec)
		
		# Compute the contour lines for f
		l = len(x_vec)
		z = N.zeros((l,l))
		for i in range(l):
			for j in range(l):
				point = N.array([x_grid[i,j],y_grid[i,j]])
				z[i,j] = f(point)
				nbr_fevals += 1
		
		# Plot the contour lines for f
		plt.figure()
		plt.grid()
		plt.axis('equal')
		plt.contour(x_grid,y_grid,z) 
		plt.title('Contour lines for the objective function f')
		plt.show()
		
		# Plot lower bounds
		if lb is not None:
			plt.plot(lb[0]*N.ones(len(y_vec)),y_vec)
			plt.plot(x_vec,lb[1]*N.ones(len(x_vec)))
		
		# Plot upper bounds
		if ub is not None:
			plt.plot(ub[0]*N.ones(len(y_vec)),y_vec)
			plt.plot(x_vec,ub[1]*N.ones(len(x_vec)))
	
	# Scale h such that it has the appropriate size compared to xstart
	scale = S.linalg.norm(xstart)
	if scale > 1:
		h = h*scale
	
	# Initial simplex
	X = N.zeros((n+1,n))
	X[0] = xstart
	for i in range(1,n+1):
		X[i] = xstart
		X[i,i-1] = xstart[i-1] + h
	
	if plot_sim:
		# Plot the initial simplex
		plt.plot(N.hstack((X[:,0],X[0,0])),N.hstack((X[:,1],X[0,1])))
		plt.show()
		
	# If the initial simplex has vertices outside the feasible region it 
	# must be shrunk s.t all vertices are inside this region
	if ub is not None:
		for i in range(1,n+1):
			v = X[i]
			if N.any(v >= ub):
				ind = v >= ub
				v[ind] = ub[ind] - 1e-6
				X[i] = v
		if plot_sim:
			# Plot the new initial simplex
			plt.plot(N.hstack((X[:,0],X[0,0])),N.hstack((X[:,1],X[0,1])))
		
	# Start iterations
	k = 0
	while k < max_iters and nbr_fevals < max_fevals:
		
		# Function values at the vertices of the current simplex
		f_val = N.zeros(n+1)
		for i in range(n+1):
			f_val[i] = f(X[i])
			nbr_fevals += 1
		
		# Order all vertices s.t f(x0) <= f(x1) <= ... <= f(xn)
		ind = N.argsort(f_val)
		X = X[ind]
		f_val = f_val[ind]
			
		if plot_sim:
			# Plot the current simplex
			plt.plot(N.hstack((X[:,0],X[0,0])),N.hstack((X[:,1],X[0,1])))
			plt.draw()
	
		# CONVERGENCE TESTS
		
		# Domain convergence test
		X_diff = N.diff(X,axis=0)
		sides = N.vstack((X_diff,X[0]-X[n]))
		side_lengths = N.zeros(n+1)
		for i in range(n+1):
			side_lengths[i] = S.linalg.norm(sides[i,:]) 
		term_x = N.all(side_lengths <= x_tol)
		
		# Function value convergence test
		f_diff = N.diff(f_val)
		F_diff = N.absolute(N.hstack((f_diff,f_val[0]-f_val[n])))
		term_f = N.all(F_diff <= f_tol)	
		
		if term_x or term_f:
			break
		
		# Centroid of the side opposite the worst vertex
		c = 1.0/n*N.sum(X[0:n],0)
		
		# Transformation parameters
		alfa = 1	# 0 < alfa
		beta = 0.5	# 0 < beta < 1
		gamma = 2	# 1 < gamma
		delta = 0.5	# 0 < delta < 1
		
		# Reflection
		xr = c + alfa*(c-X[n])
		
		# If the reflection point ends up outside the feasible region we
		# must move it to the inside of the region
		if ub is not None:
			if N.any(xr >= ub):
				ind = xr >= ub
				xr[ind] = ub[ind] - 1e-6
		if lb is not None:
			if N.any(xr <= lb):
				ind = xr <= lb
				xr[ind] = lb[ind] + 1e-6
				
		fr = f(xr)
		nbr_fevals += 1
		if f_val[0] <= fr and fr < f_val[n-1]:
			X[n] = xr
			# Go to next iteration
			k += 1
			continue
			
		# Expansion	
		elif fr < f_val[0]:
			xe = c + gamma*(xr-c)
			# If the expansion point ends up outside the feasible region we
			# must move it to the inside of the region
			if ub is not None:
				if N.any(xe >= ub):
					ind = xe >= ub
					xe[ind] = ub[ind] - 1e-6
			if lb is not None:
				if N.any(xe <= lb):
					ind = xe <= lb
					xe[ind] = lb[ind] + 1e-6
			fe = f(xe)
			nbr_fevals += 1
			if fe < fr:
				X[n] = xe
				# Go to next iteration
				k += 1
				continue
			else:
				X[n] = xr
				# Go to next iteration
				k += 1
				continue
				
		# Contraction		
		elif f_val[n-1] <= fr:
			# Outside contraction
			if fr < f_val[n]:
				xc = c + beta*(xr-c)
				fc = f(xc)
				nbr_fevals += 1
				if fc <= fr:
					X[n] = xc
					# Go to next iteration
					k += 1
					continue
			# Inside contraction
			else:
				xc = c + beta*(X[n]-c)
				fc = f(xc) 
				nbr_fevals += 1
				if fc < f_val[n]:
					X[n] = xc
					# Go to next iteration
					k += 1
					continue
			# Shrink simplex toward x0
			for i in range(1,n+1):
				X[i] = X[0] + delta*(X[i]-X[0])
			k += 1
			
	# Optimal point and objective function value		
	x_opt = X[0]
	f_opt = f(x_opt)
	nbr_fevals += 1
	
	# Number of iterations
	nbr_iters = k

	t1 = time.clock()
	solve_time = t1 - t0

	# Print convergence results
	if disp:
		print ' '
		print 'Solver: Nelder-Mead'
		print ' '
		if nbr_iters >= max_iters:
			print 'Warning: Maximum number of iterations has been exceeded.'
		elif nbr_fevals >= max_fevals:
			print 'Warning: Maximum number of function evaluations has been exceeded.'
		else:
			print 'Optimization terminated successfully.'
			if term_x:
				print 'Terminated due to sufficiently small simplex.'
			else:
				print 'Terminated due to sufficiently close function values at the vertices of the simplex.'
		print ' '
		print 'Number of iterations: ' + str(nbr_iters)
		print 'Number of function evaluations: ' + str(nbr_fevals)
		print ' '
		print 'Execution time: ' + str(solve_time) + ' s'
		print ' '

	# Return results
	return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time

def seqbar(f,xstart,lb=None,ub=None,mu=0.1,plot=False,x_tol=1e-3,
		   q_tol=1e-3,max_iters=1000,max_fevals=5000,disp=True):
	"""
	Bounded minimization of a function of one or more variables using 
	a sequential barrier function method which uses the Nelder-Mead 
	simplex method. Handles box bound constraints. Can only be used if 
	some bound (lb or ub or both) is provided.
	
	Parameters::
	
		f --
			callable f(x)
			The objective function to be minimized.
		
		xstart --
			ndarray or scalar
			The initial guess for x. 
			NB: lb < xstart < ub must be fulfilled 
			Default: None
			
		lb -- 
			ndarray or scalar
			The lower bound on x.
			Default: None
		
		ub --
			ndarray or scalar
			The upper bound on x.
			Default: None
		
		mu --
			float
			The initial value of the barrier parameter.
			Default: 0.1
		
		plot --
			bool
			Set to True if contour plots for the objective function and 
			the auxiliary function and plots of the simplex in each 
			Nelder-Mead iteration are desired. The bounds are also 
			plotted.
			NB: Only works for two dimensions.
			
		x_tol --
			float
			The tolerance for the termination criteria for x.
			Default: 1e-3
		
		q_tol --
			float
			The tolerance for the termination criteria for the auxiliary 
			function.
			Default: 1e-3
		
		max_iters --
			int
			The maximum number of iterations allowed.
			Default: 1000
			
		max_fevals --
			int
			The maximum number of function evaluations allowed.
			Default: 5000
		
		disp --
			bool
			Set to True to print convergence messages.
			Default: True
	
	Returns::
	
		x_opt --
			ndarray or scalar
			The optimal point which minimizes the objective function.
		
		f_opt --
			float
			The optimal value of the objective function.
			
		nbr_iters --
			int
			The number of iterations performed.
		
		nbr_fevals --
			int
			The number of function evaluations made.
		
		solve_time --
			float
			The execution time for the solver in seconds.
	"""
	
	t0 = time.clock()
	
	# If no bounds are given this function should not be used
	if lb is None and ub is None:
		raise ValueError, 'No bounds given, use function nelme instead.'
	
	# Check that lb < ub
	if ub is not None:	# "None" < everything
		if N.any(lb >= ub):
			raise ValueError, 'Lower bound must be smaller than upper bound.'
	
	# Check that lb < xstart < ub 
	if N.any(xstart <= lb):
		raise ValueError, 'xstart must be larger than lb.'
	if ub is not None:	# "None" < everything
		if N.any(xstart >= ub):
			raise ValueError, 'xstart must be smaller than ub.'
	
	# Convert xstart to float type array and flatten it so that 
	# len(xstart) can be used even if xstart is a scalar
	xstart = N.asfarray(xstart).flatten()	
	
	# Do the same with lb and ub
	if lb is not None:
		lb = N.asfarray(lb).flatten()
	if ub is not None:
		ub = N.asfarray(ub).flatten()
	
	# Auxiliary function
	def q(x):
	
		if lb is None and ub is None:
			out = f(x)
		else:
			if lb is None:
				b = - N.sum(N.log(ub-x))
			elif ub is None:
				b = - N.sum(N.log(x-b))
			else:
				b = - N.sum(N.log(ub-x)) - N.sum(N.log(x-lb))
			out = f(x) + mu*b

		return out

	# Number of dimensions
	n = len(xstart)
	
	# If not two dimensions nothing should be plotted
	if n != 2:
		plot = False
	
	# Number of iterations and function evaluations
	nbr_iters = 0
	nbr_fevals = 0
	
	if plot:
		
		# Create meshgrid
		if lb is None:
			x_min = xstart[0]-3*N.absolute(xstart[0])
			y_min = xstart[1]-3*N.absolute(xstart[1])
		else:
			x_min = lb[0]+1e-6
			y_min = lb[1]+1e-6
		if ub is None:
			x_max = xstart[0]+3*N.absolute(xstart[0])
			y_max = xstart[1]+3*N.absolute(xstart[1])
		else:
			x_max = ub[0]-1e-6
			y_max = ub[1]-1e-6
		x_vec = N.linspace(x_min,x_max,10)
		y_vec = N.linspace(y_min,y_max,10)
		x_grid,y_grid = N.meshgrid(x_vec,y_vec)
		
		# Compute the contour lines for f
		l = len(x_vec)
		z = N.zeros((l,l))
		for i in range(l):
			for j in range(l):
				point = N.array([x_grid[i,j],y_grid[i,j]])
				z[i,j] = f(point)
				nbr_fevals += 1
		
		# Plot the contour lines for f
		plt.figure()
		plt.grid()
		plt.axis('equal')
		plt.contour(x_grid,y_grid,z) 
		plt.title('Contour lines for the objective function f')
		plt.show()
		
		# Plot lower bounds
		if lb is not None:
			plt.plot(lb[0]*N.ones(len(y_vec)),y_vec)
			plt.plot(x_vec,lb[1]*N.ones(len(x_vec)))
		
		# Plot upper bounds
		if ub is not None:
			plt.plot(ub[0]*N.ones(len(y_vec)),y_vec)
			plt.plot(x_vec,ub[1]*N.ones(len(x_vec)))
	
	# The side length for the initial simplex 
	h = 0.3
	
	# Start iterations
	x_pre = xstart
	k = 0
	while nbr_iters < max_iters and nbr_fevals < max_fevals:
		
		# Only plot the five first steps in order to save time
		if k > 4:
			plot = False
		
		if plot:
			# Plot the countour lines of the auxiliary function q for the 
			# current mu
			if lb is None:
				b = - N.log(ub[0]-x_grid) - N.log(ub[1]-y_grid)
			elif ub is None:
				b = - N.log(x_grid-lb[0]) - N.log(y_grid-lb[1])
			else:
				b = - N.log(ub[0]-x_grid) - N.log(ub[1]-y_grid)\
					- N.log(x_grid-lb[0]) - N.log(y_grid-lb[1])
			Z = z + mu*b 
			print 'Z: ' + str(Z)
			plt.figure()
			plt.grid()
			plt.axis('equal')
			plt.contour(x_grid,y_grid,Z)
			plt.title('Contour lines for the auxiliary function q with mu = ' + str(mu))
			plt.show()				
			
		# Previous q value
		q_pre = q(x_pre)
		nbr_fevals += 1
		
		# Minimize q with Nelder-Mead
		x_new,q_new,iters,func_evals,solve_time = nelme(q,x_pre,lb=lb,ub=ub,h=h,
														plot_sim=plot,disp=False)
		
		# Increase number of iterations and function evaluations
		nbr_iters += iters
		nbr_fevals += func_evals
		
		# Increase k
		k += 1
		
		# CONVERGENCE TESTS
		
		# Termination criteria for x
		term_x = S.linalg.norm(x_new - x_pre)/S.linalg.norm(x_pre) < x_tol
			
		# Termination criteria for q
		term_q = S.linalg.norm(q_new - q_pre)/S.linalg.norm(q_pre) < q_tol
		
		if term_x or term_q:
			break
		
		# Reduce the barrier parameter for next iteration
		mu = 0.5*mu
		
		# Reduce the side length for the initial simplex in Nelder-Mead
		h = 0.5*h
		
		# Update x
		x_pre = x_new
	
	# Optimal point and function value
	x_opt = x_new
	f_opt = f(x_opt)
	nbr_fevals += 1
		
	t1 = time.clock()
	solve_time = t1 - t0
	
	# Print convergence results
	if disp:
		print ' '
		print 'Solver: Sequential barrier method with Nelder-Mead'
		print ' '
		if nbr_iters >= max_iters:
			print 'Warning: Maximum number of iterations has been exceeded.'
		elif nbr_fevals >= max_fevals:
			print 'Warning: Maximum number of function evaluations has been exceeded.'
		else:
			print 'Optimization terminated successfully.'
			if term_x:
				print 'Termination criteria for x was fulfilled.'
			else:
				print 'Termination criteria for auxiliary function was fulfilled.'
		print ' '
		print 'Number of iterations: ' + str(nbr_iters)
		print 'Number of function evaluations: ' + str(nbr_fevals)
		print ' '
		print 'Execution time: ' + str(solve_time) + ' s'
		print ' '
	
	# Return results
	return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time

def de(f,lb,ub,plot=False,x_tol=1e-6,f_tol=1e-6,max_iters=1000,
	   max_fevals=10000,disp=True):
	"""
	Minimize a function of one or more variables using the OpenOpt 
	solver 'de' which is a GLP solver based on the Differential 
	Evolution method. Handles box bound constraints. Can only be used if 
	bounds (both lb and ub) are provided.
	
	Parameters::
	
		f -- 
			callable f(x)
			The objective function to be minimized.
		
		lb -- 
			ndarray or scalar
			The lower bound on x.
	
		ub --
			ndarray or scalar
			The upper bound on x.
	
		plot --
			bool
			Set to True if a graph of the objective function value over 
			time is desired.
			Default: False
	
		x_tol --
			float
			The tolerance for the termination criteria for x.
			Default: 1e-6
			
		f_tol --
			float
			The tolerance for the termination criteria for the objective 
			function.
			Default: 1e-6
		
		max_iters --
			int
			The maximum number of iterations allowed.
			Default: 1000
			
		max_fevals --
			int
			The maximum number of function evaluations allowed.
			Default: 10000
		
		disp --
			bool
			Set to True to print convergence messages.
			Default: True
		
	Returns::
		
		x_opt --
			ndarray or scalar
			The optimal point which minimizes the objective function.
				
		f_opt --
			float
			The minimal value of the objective function.
		
		nbr_iters --
				int
				The number of iterations performed.
			
		nbr_fevals --
			int
			The number of function evaluations made.
			
		solve_time --
			float
			The execution time for the solver in seconds.
	"""
	
	# Check that lb < ub
	if N.any(lb >= ub):
		raise ValueError, 'Lower bound must be smaller than upper bound.'
	
	if plot:
		plt.figure()
	
	if disp:
		iprint = 0
	else:
		iprint = -1
	
	# Construct the problem
	p = GLP(f,lb=lb,ub=ub,maxIter=max_iters,maxFunEvals=max_fevals)
	
	# Solve the problem
	solver = 'de'
	r = p.solve(solver,plot=plot,xtol=x_tol,ftol=f_tol,iprint=iprint)
	
	# Get results	
	x_opt, f_opt = r.xf, r.ff
	d1 = r.evals
	d2 = r.elapsed
	nbr_iters = d1['iter']
	nbr_fevals = d1['f']
	solve_time = d2['solver_time']
	
	if disp:
		print ' '
		print 'Solver: OpenOpt solver ' + solver
		print ' '
		print 'Number of iterations: ' + str(nbr_iters)
		print 'Number of function evaluations: ' + str(nbr_fevals)
		print ' '
		print 'Execution time: ' + str(solve_time)
		print ' '
	
	# Return results
	return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time

def fmin(f,xstart=None,lb=None,ub=None,alg=None,plot=False,x_tol=1e-6,
		 f_tol=1e-6,max_iters=1000,max_fevals=10000,disp=True):
	"""
	Minimize a function of one or more variables using a derivative-free 
	method which can be chosen from the following alternatives: 
		1. The Nelder-Mead simplex method. Handles box bound constraints 
		   but not very well.
		2. A sequential barrier function method which uses the 
		   Nelder-Mead simplex method. Handles box bound constraints. 
		   Can only be chosen if some bound (lb or ub or both) is 
		   provided.
		3. The OpenOpt solver 'de' which is a GLP solver based on the
		   Differential Evolution method. Handles box bound constraints. 
		   Can only be chosen if bounds (both lb and ub) are provided.
	
	Parameters::
	
		f --
			callable f(x)
			The objective function to be minimized.
		
		xstart --
			ndarray or scalar
			The initial guess for x. 
			NB: Must be provided if alg = 1 or alg = 2 is chosen.
				lb < xstart < ub must be fulfilled.
			Default: None
			
		lb -- 
			ndarray or scalar
			The lower bound on x.
			Default: None
		
		ub --
			ndarray or scalar
			The upper bound on x.
			Default: None
			
		alg --
			int
			The number of the desired optimization method to be used:
				1 = The Nelder-Mead simplex method. Handles box bound
					constraints but not very well.
				2 = A sequential barrier function method which uses 
					the Nelder-Mead simplex method. Handles box bound 
					constraints. Can only be chosen if some bound (lb or 
					ub or both) is provided.
				3 = The OpenOpt solver 'de' which is a GLP solver based 
					on the Differential Evolution method. Handles box 
					bound constraints. Can only be chosen if bounds 
					(both lb and ub) are provided.
			Default: None
		
		plot --
			bool
			Set to True if graphic output is desired: 
				If alg = 1: The contour lines for the objective function 
							are plotted once and the simplex is plotted 
							in each iteration. The bounds (if any) are 
							also plotted.
				If alg = 2: The contour lines for the objective function 
							are plotted once, the contour lines for the 
							auxiliary function are plotted in each step
							(for each mu-value) and the simplex is 
							plotted in each Nelder-Mead iteration. The 
							bounds are also plotted.
				If alg = 3: A graphic output from OpenOpt is given where
							the objective function value is plotted over
							time. It also shows the name of the OpenOpt
							solver: "de".
			NB: Only works for two dimensions.
			Default: False
			
		x_tol --
			float
			The tolerance for the termination criteria for x.
			Default: 1e-6
		
		f_tol --
			float
			The tolerance for the termination criteria for the objective 
			function.
			Default: 1e-6
		
		max_iters --
			int
			The maximum number of iterations allowed.
			Default: 1000
			
		max_fevals --
			int
			The maximum number of function evaluations allowed.
			Default: 10000
		
		disp --
			bool
			Set to True to print convergence messages.
			Default: True
	
	Returns::
	
		x_opt --
			ndarray or scalar
			The optimal point which minimizes the objective function.
		
		f_opt --
			float
			The optimal value of the objective function.
			
		nbr_iters --
			int
			The number of iterations performed.
		
		nbr_fevals --
			int
			The number of function evaluations made.
		
		solve_time --
			float
			The execution time for the solver in seconds.
	"""
	
	# If no algorithm is chosen then alg = 1 or alg = 2 is used.
	if alg is None:
		if lb is None and ub is None:
			alg = 1
		else:
			alg = 2
	
	# Check that the choice of alg is allowed concerning lb and ub
	if lb is None and ub is None:
		if alg == 2:
			raise ValueError, 'Method 2 can only be chosen if bounds are provided.'
		if alg == 3:
			raise ValueError, 'Method 3 can only be chosen if bounds are provided.'
	elif lb is None or ub is None:
		if alg == 3:
			raise ValueError, 'Method 3 can only be chosen if both upper and lower bounds are provided'
							  
	# Check that xstart is given if alg = 1 or 2						  
	if alg == 1 or alg == 2:
		if xstart is None:
			raise ValueError, 'Methods 1 and 2 require a starting point.'
	
	# Solve the problem
	if alg == 1:
		x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = nelme(f,xstart,lb=lb,ub=ub,
															plot_con=plot,plot_sim=plot,
															x_tol=x_tol,f_tol=f_tol,
															max_iters=max_iters,
															max_fevals=max_fevals,
															disp=disp)
	elif alg == 2:
		x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = seqbar(f,xstart,lb=lb,ub=ub,
															 plot=plot,x_tol=x_tol,
															 q_tol=f_tol,
															 max_iters=max_iters,
															 max_fevals=max_fevals,
															 disp=disp)
	
	else:
		x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = de(f,lb,ub,plot=plot,x_tol=x_tol,
													     f_tol=f_tol,max_iters=max_iters,
														 max_fevals=max_fevals,disp=disp)
	
	# Return results
	return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time
