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
    Simulation of a model containing if expressions. The
    relational expressions in the model does not, however,
    generate events since they are contained inside the
    noEvent(.) operator.
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'IfExpExamples.IfExpExample1'
    compiled_model_name = 'IfExpExamples_IfExpExample1'
    mofile = curr_dir+'/files/IfExpExamples.mo'
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(mofile,model_name,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(compiled_model_name)
    
    disc_mod = JMIDAE(model) #Create an Assimulo problem
    disc_sim = IDA(disc_mod) #Create an IDA solver
    disc_sim.initiate() #Calculate initial conditions
    disc_sim.simulate(5,500) #Simulate 5 seconds with 500 communication points

    write_data(disc_sim)

    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('IfExpExamples_IfExpExample1_result.txt')
    x = res.get_variable_data('x')
    u = res.get_variable_data('u')
    
    assert N.abs(x.x[-1] - 3.5297357) < 1e-3, \
            "Wrong value, last value of x in if_example.py"
    assert N.abs(u.x[-1] - (-0.2836625)) < 1e-3, \
            "Wrong value, last value of u in if_example.py"            

    if with_plots:
        fig = p.figure()
        p.plot(x.t, x.x, u.t, u.x)
        p.legend(('x','u'))
        p.show()


if __name__=="__main__":
    run_demo()
