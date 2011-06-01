import threading
import os
import numpy as N

class fevalThread(threading.Thread):
	def __init__(self,x,func_file_name,dir_name):
		self.x = x
		self.func_file_name = func_file_name
		self.dir_name = dir_name
		threading.Thread.__init__(self)
	def run(self):
		l = list()
		for val in self.x:
			l.append(str(val))
		x_string = ' '.join(l)
		cmd = ' '.join(['func_eval.py',x_string,self.func_file_name,self.dir_name])
		self.retval = os.system(cmd)

def feval(func_file_name,x):
	"""
	Evaluate a function in a separate process.
	
	Parameters::
	
		func_file_name --
			string
			The name of a python file containing the function definition.
			The function in the file must have the same name as the file 
			itself (without ".py").
			
		x --
			ndarray (1 or 2 dimensions)
			The point(s) in which to evaluate the function.
		
	Returns::
	
		fval --
			float or ndarray (1 dimension)
			The function value(s) in x.
	"""
	
	# Evaluation in one point only
	if N.ndim(x) == 1:
		dir_name = 'dir'
		th = fevalThread(x,func_file_name,dir_name)
		th.start()
		th.join()
		retval = th.retval
		if retval != 0:
			raise OSError, 'Something went wrong with the function evaluation: os.system did not return 0.'
		f_string = file(dir_name+'/f_value.txt').read()
		fval = eval(f_string)
	
	# Evaluation in several points	
	else:
		m = len(x)
		fval = N.zeros(m)
		# Create and start threads
		threads = []
		for i in range(m):
			dir_name = 'dir_'+str(i+1)
			th = fevalThread(x[i],func_file_name,dir_name)
			th.start()
			threads.append(th)	
		# Wait for all threads to complete
		for t in threads:
		    t.join()    
		# Read from result files
		for i in range(m):
			retval = threads[i].retval
			if retval != 0:
				raise OSError, 'Something went wrong with the function evaluation: os.system did not return 0.'
			dir_name = 'dir_'+str(i+1)
			f_string = file(dir_name+'/f_value.txt').read()
			fval[i] = eval(f_string)
	
	return fval
