#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2015 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the needed JModelica.org Python methods
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import transfer_optimization_problem, get_files_path
from pyjmi.optimization.greybox import GreyBox


## NOT NEEDED ? ##
#from pyjmi import CasadiModel
#import cPickle as pickle
#from pyjmi.common.core import TrajectoryLinearInterpolation
#from pyjmi.optimization.casadi_collocation import *

def run_demo():
	"""
	
	"""
	# Locate the model and file paths 
	file_path = os.path.join(get_files_path(), "DrumBoiler.mo")
	modelPath = "DrumBoiler"


	# Create reference data
	nullModelReferenceCost = 5631.068823 #the cost from the null model
	reference = {'TD':{'cost':5466.596971, 'costred':164.471852, 'risk':0.000000},'TR':{'cost':5629.636935, 'costred':1.431888, 'risk':0.731872},'A4':{'cost':5630.900339, 'costred':0.168484, 'risk':0.996721}
				,'distE':{'cost':4362.561987, 'costred':1268.506836, 'risk':0.000000},'distP':{'cost':4399.728897, 'costred':1231.339926, 'risk':0.000000}} #Create reference by running without framework
	tol = 1e-3


	# Load measurement data
	with open("DBdata.pickle") as fp:
	   RCdata = pickle.load(fp) 
	measurements = RCdata['measurements'] 
	time = RCdata['time'] 
		
	# Extract control signal data from measurements
	inputs={}
	inputs['uc']= measurements.pop('uc')
	inputs['fc']= measurements.pop('fc')


	MLClasspath = "DrumBoilerpackage.DrumBoiler"
	modelPath = "DrumBoiler.mop"
	# Transfer model to Casadi interface
	op = transfer_optimization_problem(MLClasspath, modelPath, accept_model=True )
	op_opts = op.optimize_options()

	# Create greybox object
	GB = GreyBox(op, op_opts, measurements, inputs, time)
		
	# Set some variable attributes
	GB.set_variable_attribute('GreyBox_r_E', 'max', 100)
	GB.set_variable_attribute('GreyBox_r_P', 'max', 100)
	GB.set_variable_attribute('x10', 'initialGuess', 148)
	GB.set_variable_attribute('x20', 'initialGuess', 27.5)
		
	# Define null model free parameters and other parameters to free
	nullModelFree = set(['GreyBox_r_E', 'GreyBox_r_P', 'x10', 'x20'])
	optimizeParameters = set(["TD","TR","A4","distE","distP"])
		
	# Define parameters to free (noise covariances and initial guesses )
	GB.set_free_parameters(nullModelFree)
		
	# Optimize null model
	identification = GB.identify()

		
	# Assert result 
	assert(N.abs(identification.cost - nullModelReferenceCost) < tol)
		
	# Create dictionaries for results
	testcases = []

	for var in optimizeParameters:
		# Add var to set of free parameters
		testcases.append(identification.release([var]))
		
		
		
	print("=======================SUMMARY========================")

	results = identification.compare(testcases)


	# assert results
	for var in optimizeParameters:
		assert(N.abs(results[var]['cost'] - reference[var]['cost']) < tol)
		assert(N.abs(results[var]['costred'] - reference[var]['costred']) < tol)
		assert(N.abs(results[var]['risk'] - reference[var]['risk']) < tol)


if __name__=="__main__":
run_demo()
