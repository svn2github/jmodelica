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
import logging

import numpy as N
import pylab as P
import nose

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.io import ResultDymolaTextual

try:
    from jmodelica.simulation.assimulo_interface import JMIDAESens, write_data
    from assimulo.implicit_ode import IDA
except ImportError:
    logging.warning(
        'Could not find Assimulo package. Check jmodelica.check_packages()')


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
    #Store data continuous during the simulation, important when solving a 
    #problem with sensitivites.
    rob_sim.store_cont = True 
    
    #Value used when IDA estimates the tolerances on the parameters
    rob_sim.pbar = rob_mod.p0 
    
    #Let Sundials find consistent initial conditions by use of 'IDA_YA_YDP_INIT'
    rob_sim.make_consistent('IDA_YA_YDP_INIT')
    
    #Simulate
    rob_sim.simulate(4,400) #Simulate 4 seconds with 400 communication points

    write_data(rob_sim)

    res = ResultDymolaTextual('Robertson_result.txt')

    dy1dp1 = res.get_variable_data('dy1/dp1')
    dy2dp1 = res.get_variable_data('dy2/dp1')
    dy3dp1 = res.get_variable_data('dy3/dp1')
    
    nose.tools.assert_almost_equal(dy1dp1.x[40], -0.35590, 3)
    nose.tools.assert_almost_equal(dy2dp1.x[40],  3.9026e-04, 6)
    nose.tools.assert_almost_equal(dy3dp1.x[40],  3.5551e-01 , 3)

    
if __name__ == "__main__":
    run_demo()
