#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
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

import os as O
import numpy as N
import pylab as P
import warnings
import nose

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

try:
    from jmodelica.simulation.assimulo_interface import JMIDAESens
    from assimulo.implicit_ode import IDA
except:
    warnings.warn('Could not find Assimulo package. Check jmodelica.check_packages()')


def run_demo(with_plots=True):
    """
    Demonstrates how to use JModelica.org for calculating sensitivities.
    """
    
    curr_dir = O.path.join(O.path.dirname(O.path.abspath(__file__)),'files')
    
    jmu_name = compile_jmu("Robertson", O.path.join(curr_dir,"Robertson.mop"))
    
    # Load a model instance into Python
    jm_model = JMUModel(jmu_name)
    
    global rob_mod
    global rob_sim
    
    rob_mod = JMIDAESens(jm_model) #Create an Assimulo problem
    rob_sim = IDA(rob_mod) #Create an IDA solver
    
    #Sets the paramters
    rob_sim.atol = N.array([1.0e-8, 1.0e-14, 1.0e-6])
    rob_sim.store_cont = True #Store data continuous during the simulation, important when solving a problem
                              #with sensitivites.
    
    rob_sim.pbar = rob_mod.p0 #Value used when IDA estimates the tolerances on the parameters
    
    #Let Sundials find consistent initial conditions by use of 'IDA_YA_YDP_INIT'
    rob_sim.make_consistency('IDA_YA_YDP_INIT')
    
    #Simulate
    rob_sim.simulate(4,400) #Simulate 4 seconds with 400 communication points
    
    #Get the result
    names, sens_matrix = rob_mod.get_sens_result()

    nose.tools.assert_almost_equal(sens_matrix[0][40,0], -0.35590, 3)
    nose.tools.assert_almost_equal(sens_matrix[0][40,1],  3.9026e-04, 6)
    nose.tools.assert_almost_equal(sens_matrix[0][40,2],  3.5551e-01 , 3)
    
if __name__ == "__main__":
    run_demo()
