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

"""Tests the greybox identification framework."""

import os
import numpy as N
from tests_jmodelica import testattr, get_files_path
from pyjmi.optimization.greybox import GreyBox, Identification
import cPickle as pickle

try:
    from pyjmi import transfer_optimization_problem
    from pyjmi.optimization.casadi_collocation import ExternalData
except (NameError, ImportError):
    pass

def strnorm(StringnotNorm):
    caracters = ['\n','\t',' ']
    StringnotNorm = str(StringnotNorm)
    for c in caracters:
        StringnotNorm = StringnotNorm.replace(c, '')
    return StringnotNorm
    
@testattr(casadi = True)
def test_op_structure():
    
    # Locate the model and file paths 
    file_path = os.path.join(get_files_path(), 'Modelica', "DrumBoiler.mo")
    modelPath = "DrumBoiler"

    # Load measurement data
    with open(os.path.join(get_files_path(), 'Modelica',"DBdata.pickle")) as fp:
       RCdata = pickle.load(fp) 
    measurements = RCdata['measurements'] 
    time = RCdata['time'] 
        
    # Extract control signal data from measurements
    inputs={}
    inputs['uc']= measurements.pop('uc')
    inputs['fc']= measurements.pop('fc')

    # Transfer model to Casadi interface
    op = transfer_optimization_problem(modelPath, file_path, accept_model=True )
    op_opts = op.optimize_options()

    # Create greybox object
    GB = GreyBox(op, op_opts, measurements, inputs, time)
    
    # Assert start and final time
    assert GB.op.getStartTime().getValue() == time[0]
    assert GB.op.getFinalTime().getValue() == time[-1]
    
    # Assert collocation options
    assert GB.options['n_e'] == len(time)-1
    assert GB.options['n_cp'] == 1
    
    
    # Assert external data
    ext_data = GB.options['external_data']
    # input data
    for inp in inputs.keys():
		evaluated_input = ext_data.eliminated[inp].eval(time)
		N.array_equal(inputs[inp], evaluated_input)
    # measurement data
    for meas in measurements.keys():
		evaluated_meas = ext_data.eliminated['GreyBox_measured_'+meas].eval(time)
		N.array_equal(measurements[meas], evaluated_meas)
		
	# Assert objective and objective integrand
    assert strnorm(GB.op.getObjectiveIntegrand().getDescription()) == strnorm('(((0.499*sq((E-GreyBox_measured_E)))/GreyBox_r_E)+((0.499*sq((P-GreyBox_measured_P)))/GreyBox_r_P))')
    assert strnorm(GB.op.getObjective().getDescription()) == strnorm('((((500*log(GreyBox_r_E))+(sq((E(0.000000)-133.837))/GreyBox_r_E))+(500*log(GreyBox_r_P)))+(sq((P(0.000000)-138))/GreyBox_r_P))')

@testattr(casadi = True)
def test_op_structure_sum():
    # Locate the model and file paths 
    file_path = os.path.join(get_files_path(),'Modelica',"DrumBoiler.mo")
    modelPath = "DrumBoiler"

    # Load measurement data
    with open(os.path.join(get_files_path(),'Modelica',"DBdata.pickle")) as fp:
       RCdata = pickle.load(fp) 
    measurements = RCdata['measurements'] 
    time = RCdata['time'][0:3]
    
    # Only use first 3 measurements
    for var in measurements.keys():
        measurements[var] = measurements[var][0:3]
        
    # Extract control signal data from measurements
    inputs={}
    inputs['uc']= measurements.pop('uc')
    inputs['fc']= measurements.pop('fc')

    # Transfer model to Casadi interface
    op = transfer_optimization_problem(modelPath, file_path, accept_model=True )
    op_opts = op.optimize_options()

    # Create greybox object
    GB = GreyBox(op, op_opts, measurements, inputs, time, costType = 'sum')
    
    # Assert start and final time
    assert GB.op.getStartTime().getValue() == time[0]
    assert GB.op.getFinalTime().getValue() == time[-1]
    
    # Assert collocation options
    assert GB.options['n_e'] == len(time)-1
    assert GB.options['n_cp'] == 3
    
    # Assert external data
    ext_data = GB.options['external_data']
    for inp in inputs.keys():
		evaluated_input = ext_data.eliminated[inp].eval(time)
		N.array_equal(inputs[inp], evaluated_input)

   	# Assert objective and objective integrand
    assert strnorm(GB.op.getObjectiveIntegrand().getDescription()) == strnorm('0')
    print strnorm(GB.op.getObjective().getDescription())
    assert strnorm(GB.op.getObjective().getDescription()) == strnorm('((((((((sq((E(0.000000)-133.837))/GreyBox_r_E)+(sq((E(2.004008)-132.493))/GreyBox_r_E))+(sq((E(4.008016)-129.124))/GreyBox_r_E))+(3*log(GreyBox_r_E)))+(sq((P(0.000000)-138))/GreyBox_r_P))+(sq((P(2.004008)-141.156))/GreyBox_r_P))+(sq((P(4.008016)-132.906))/GreyBox_r_P))+(3*log(GreyBox_r_P)))')

@testattr(casadi = True)
def test_identification_object():
    # Locate the model and file paths 
    file_path = os.path.join(get_files_path(),'Modelica',"DrumBoiler.mo")
    modelPath = "DrumBoiler"

    # Load measurement data
    with open(os.path.join(get_files_path(),'Modelica',"DBdata.pickle")) as fp:
       RCdata = pickle.load(fp) 
    measurements = RCdata['measurements'] 
    time = RCdata['time'] 
        
    # Extract control signal data from measurements
    inputs={}
    inputs['uc']= measurements.pop('uc')
    inputs['fc']= measurements.pop('fc')

    # Transfer model to Casadi interface
    op = transfer_optimization_problem(modelPath, file_path, accept_model=True )
    op_opts = op.optimize_options()

    # Create greybox object
    GB = GreyBox(op, op_opts, measurements, inputs, time)
    
    # Set some variable attributes
    GB.set_variable_attribute(GB.get_noise_covariance_variable('E'), 'max', 100)
    GB.set_variable_attribute(GB.get_noise_covariance_variable('P'), 'max', 100)
    GB.set_variable_attribute('x10', 'initialGuess', 148)
    GB.set_variable_attribute('x20', 'initialGuess', 27.5)
        
    # Define null model free parameters and other parameters to free
    nullModelFree = set(['GreyBox_r_E', 'GreyBox_r_P', 'x10', 'x20'])
        
    # Optimize null model
    identification = GB.identify(nullModelFree)
    
    # Assert free variables
    idFree = identification.free_parameters
    assert len(idFree.difference(nullModelFree)) == 0
    assert len(nullModelFree.difference(idFree)) == 0
    
    for par in nullModelFree:
		assert identification.greybox.op.getVariable(par).getAttribute('free').getValue() == 1.0
		
    #Assert value of free variables
    res = identification.result
    assert abs(res.final('GreyBox_r_E') - 99.999995739422701) <1e-6
    assert abs(res.final('GreyBox_r_P') - 74.464755778693103) <1e-6
    assert abs(res.final('x10') - 138.77236665852601) <1e-6
    assert abs(res.final('x20') - 40.696009354038303) <1e-6


@testattr(casadi = True)
def test_nonuniform_element_length():
    # Locate the model and file paths 
    file_path = os.path.join(get_files_path(),'Modelica',"DrumBoiler.mo")
    modelPath = "DrumBoiler"

    # Load measurement data
    with open(os.path.join(get_files_path(),'Modelica',"DBdata.pickle")) as fp:
       RCdata = pickle.load(fp) 
    measurements = RCdata['measurements'] 
    time = RCdata['time'] 
    
    # remove every third measurement to get nonuniform distribution of measurements
    for var in measurements.keys():
		measurements[var] = N.delete(measurements[var], slice(None, None, 3))
    
    time = N.delete(time, slice(None, None, 3))  

    # Extract control signal data from measurements
    inputs={}
    inputs['uc']= measurements.pop('uc')
    inputs['fc']= measurements.pop('fc')
    

    # Transfer model to Casadi interface
    op = transfer_optimization_problem(modelPath, file_path, accept_model=True )
    op_opts = op.optimize_options()

    # Create greybox object
    GB = GreyBox(op, op_opts, measurements, inputs, time, hs=True)
    
    # Set some variable attributes
    GB.set_variable_attribute(GB.get_noise_covariance_variable('E'), 'max', 100)
    GB.set_variable_attribute(GB.get_noise_covariance_variable('P'), 'max', 100)
    GB.set_variable_attribute('x10', 'initialGuess', 148)
    GB.set_variable_attribute('x20', 'initialGuess', 27.5)
        
    # Define null model free parameters and other parameters to free
    nullModelFree = set(['GreyBox_r_E', 'GreyBox_r_P', 'x10', 'x20'])
    
    # Assert start and final time
    assert GB.op.getStartTime().getValue() == time[0]
    assert GB.op.getFinalTime().getValue() == time[-1]
    
    # Assert collocation options
    assert GB.options['n_e'] == len(time)-1
    assert GB.options['n_cp'] == 1    
    
    assert N.allclose(GB.options['hs'][0:4], [ 0.00200803,  0.00401606,  0.00200803,  0.00401606])
    
@testattr(casadi = True)
def test_compare():
    # Locate the model and file paths 
    file_path = os.path.join(get_files_path(),'Modelica',"DrumBoiler.mo")
    modelPath = "DrumBoiler"

    # Load measurement data
    with open(os.path.join(get_files_path(),'Modelica',"DBdata.pickle")) as fp:
       RCdata = pickle.load(fp) 
    measurements = RCdata['measurements'] 
    time = RCdata['time'] 

    # Extract control signal data from measurements
    inputs={}
    inputs['uc']= measurements.pop('uc')
    inputs['fc']= measurements.pop('fc')
    

    # Transfer model to Casadi interface
    op = transfer_optimization_problem(modelPath, file_path, accept_model=True )
    op_opts = op.optimize_options()

    # Create greybox object
    GB = GreyBox(op, op_opts, measurements, inputs, time)
    
    # Set some variable attributes
    GB.set_variable_attribute(GB.get_noise_covariance_variable('E'), 'max', 100)
    GB.set_variable_attribute(GB.get_noise_covariance_variable('P'), 'max', 100)
    GB.set_variable_attribute('x10', 'initialGuess', 148)
    GB.set_variable_attribute('x20', 'initialGuess', 27.5)
        
   # Define null model free parameters and other parameters to free
    nullModelFree = set(['GreyBox_r_E', 'GreyBox_r_P', 'x10', 'x20'])
    
    # Optimize null model
    identification = GB.identify(nullModelFree)
    
    
    # Optimize with 'TD' added to free variables
    
    # Add 'TD' to set of free parameters
    freeParam1 = set(['GreyBox_r_E', 'GreyBox_r_P', 'x10', 'x20', 'TD'])
    idObj1 = identification.release(freeParam1)
    
    # Assert free variables
    id1Free = idObj1.free_parameters
    assert len(id1Free.difference(freeParam1)) == 0
    assert len(freeParam1.difference(id1Free)) == 0
    
    #Assert that parameters are really free
    for par in freeParam1:
		assert identification.greybox.op.getVariable(par).getAttribute('free').getValue() == 1.0
    
    
    # Optimize with 'A4' added to free variables
    
    freeParam2 = set(['GreyBox_r_E', 'GreyBox_r_P', 'x10', 'x20', 'A4'])
    idObj2 = identification.release(freeParam2)
    
    # Assert free variables
    id2Free = idObj2.free_parameters
    assert len(id2Free.difference(freeParam2)) == 0
    assert len(freeParam2.difference(id2Free)) == 0
    
    #Assert that parameters are really free
    for par in freeParam2:
		assert identification.greybox.op.getVariable(par).getAttribute('free').getValue() == 1.0
    
    # Assert that 'TD' is no longer free
    assert identification.greybox.op.getVariable('TD').getAttribute('free').getValue() == 0.0
    
    result = identification.compare([idObj1, idObj2])
    
    # assert results
    assert abs(result[0]['cost'] - 5466.596970228651) < 1e-6
    assert abs(result[1]['cost'] - 5630.90033894926) <1e-6
    
    assert abs(result[0]['costred'] - 164.47186155134114) < 1e-6
    assert abs(result[1]['costred'] - 0.16849283073224797) < 1e-6
    
    # assert risk
    assert identification.calculate_risk(identification.get_cost()-idObj2.get_cost(),1,2) == result[1]['risk'] 
    assert identification.calculate_risk(identification.get_cost()-idObj1.get_cost(),1,2) == result[0]['risk'] 
    

@testattr(casadi = True)
def test_risk_calculation():
	
    idObj = Identification([],[],[],0)
    
    assert abs(idObj.calculate_risk(500, 5, 3) - 0.0) < 1e-6
    assert abs(idObj.calculate_risk(5, 5, 3) - 0.80070068201586642) < 1e-6
      
