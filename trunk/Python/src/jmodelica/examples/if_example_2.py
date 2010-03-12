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
from jmodelica.simulation.sundials import SundialsDAESimulator
from jmodelica.compiler import ModelicaCompiler
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

def run_demo(with_plots=True):
    """
    This example shows how to simulate a system that contains switches.
    The example model is simple in the sense that no reinitialization
    of the variables is needed at the event points.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'IfExpExamples.IfExpExample2'
    compiled_model_name = 'IfExpExamples_IfExpExample2'
    mofile = curr_dir+'/files/IfExpExamples.mo'
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(mofile,model_name,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(compiled_model_name)

    # Initialize the switches (1=true, 0=false)
    model.set_sw(N.array([1,1]))

    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    simulator = SundialsDAESimulator(model, verbosity=3, start_time=0.0, final_time=N.pi/2, time_step=0.01)
    #Simulate until first event (assumed to be known)
    simulator.run()
    simulator.write_data()
    res1 = jmodelica.io.ResultDymolaTextual('IfExpExamples_IfExpExample2_result.txt')

    # Turn switches
    model.set_sw(N.array([0,1]))
    # Simulate until next event
    simulator.run(start_time=N.pi/2,final_time=N.pi)
    simulator.write_data()
    res2 = jmodelica.io.ResultDymolaTextual('IfExpExamples_IfExpExample2_result.txt')

    # Turn switches again
    model.set_sw(N.array([0,0]))
    simulator.run(start_time=N.pi,final_time=5)
    simulator.write_data()
    res3 = jmodelica.io.ResultDymolaTextual('IfExpExamples_IfExpExample2_result.txt')

    # Get results
    x1 = res1.get_variable_data('x')
    u1 = res1.get_variable_data('u')
    x2 = res2.get_variable_data('x')
    u2 = res2.get_variable_data('u')
    x3 = res3.get_variable_data('x')
    u3 = res3.get_variable_data('u')
       
    assert N.abs(x1.x[-1] - 1.0000027) < 1e-3, \
            "Wrong value, last value of x1 in if_example_2.py"

    assert N.abs(u1.x[-1] - 0.9999999) < 1e-3, \
            "Wrong value, last value of u1 in if_example_2.py"

    assert N.abs(x2.x[-1] - 2.5707990) < 1e-3, \
            "Wrong value, last value of x2 in if_example_2.py"

    assert N.abs(u2.x[-1] - 1.0) < 1e-3, \
            "Wrong value, last value of u2 in if_example_2.py"

    assert N.abs(x3.x[-1] - 3.5297217) < 1e-3, \
            "Wrong value, last value of x3 in if_example_2.py"

    assert N.abs(u3.x[-1] - (-0.2836621)) < 1e-3, \
            "Wrong value, last value of u3 in if_example_2.py"        
  

    if with_plots:
        #Plot
        fig = p.figure()
        p.plot(x1.t, x1.x, u1.t, u1.x,x2.t, x2.x, u2.t, u2.x,x3.t, x3.x, u3.t, u3.x)
        p.legend(('x','u'))
        p.show()

if __name__=="__main__":
    run_demo()
