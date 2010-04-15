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

import os
import numpy as N
import pylab as p
import matplotlib

import jmodelica
import jmodelica.jmi as jmi
from time import time
from jmodelica.tests import get_example_path
from jmodelica.compiler import ModelicaCompiler
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

try:
    from jmodelica.simulation.assimulo import JMIDAE, write_data
    from Assimulo.Implicit_ODE import IDA
except:
    raise ImportError('Could not find Assimulo package.')

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using a DAE simulator with 
    Assimulo. The model used is made by Maja Djačić.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    m_name = 'SolAngles'
    mofile = curr_dir+'/files/SolAngles.mo'
    
    
    mc = ModelicaCompiler()
    
    # Compile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(m_name,mofile,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(m_name)
    
    #Simulation with the new package, Assimulo
    SolAng_mod = JMIDAE(model)
    SolAng_sim = IDA(SolAng_mod)
    SolAng_sim.reset() #Resets to the initial values from the model
    SolAng_sim.make_consistency('IDA_YA_YDP_INIT') #Calculates initial values
    
    #Time the run method for assimulo
    time_begin = time()
    SolAng_sim(86400.0, 86400) #Simulate the same time and with the same number of output points
    #rtol and atol is by default 1.0e-6 the same as with pySundials
    assimulo = time()-time_begin #Elapsed time
    
    write_data(SolAng_sim)
    
    # Load the data we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('SolAngles_result.txt')
    theta = res.get_variable_data('theta')
    azim = res.get_variable_data('azim')
    N_day = res.get_variable_data('N_day')

    
    # Plot results
    if with_plots:
        p.figure(1)
        p.plot(theta.t, theta.x)
        p.xlabel('time [s]')
        p.ylabel('theta [deg]')
        p.title('Angle of Incidence on Surface')
        p.grid()
        p.show()
    
    #Print the statistics for the timing
    print '\nElapsed time:'
    print 'Assimulo: %e' %assimulo

if __name__=="__main__":
    run_demo()
