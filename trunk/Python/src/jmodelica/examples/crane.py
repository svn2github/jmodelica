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
    An example on how to simulate a model using the DAE
    simulator. Also writes information to a file.

    NOTICE: The script does not run since the compiler does
    not support all constructs needed.
    
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'PyMBSModels.CraneCrab_recursive_der_state_Test'
    mofile = curr_dir+'/files/PyMBSModels.mo'
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(model_name,mofile,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(model_name.replace('.', '_'))
    
    #crane_mod = JMIDAE(model) #Create an Assimulo model
    #crane_sim = IDA(crane_mod) #Create an IDA solver
    
    #crane_sim.initiate() #Calculate initial conditions
    #crane_sim.simulate(30,3000) #Simulate 30 seconds with 3000 communications points
    #crane_sim.plot()
    #write_data(crane_sim)

    # Load the file we just wrote to file
    #res = jmodelica.io.ResultDymolaTextual('RLC_Circuit_result.txt')

    # remains to add plotting

if __name__=="__main__":
    run_demo()
