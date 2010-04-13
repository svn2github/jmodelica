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
    from jmodelica.simulation.assimulo import TrajectoryLinearInterpolation
    from Assimulo.Implicit_ODE import IDA
except:
    raise ImportError('Could not find Assimulo package.')

def run_demo(with_plots=True):
    """
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'SecondOrder'
    mofile = curr_dir+'/files/SecondOrder.mo'

    # Generate input
    t = N.linspace(0.,10.,100) 
    u = N.cos(t)
    u = N.array([u])
    u = N.transpose(u)
    u_traj = TrajectoryLinearInterpolation(t,u)
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(mofile,model_name,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(model_name)

    model.set_value('u',u_traj.eval(0.)[0])
    
    mod = JMIDAE(model, input=u_traj) #Create an assimulo DAE model
    sim = IDA(mod) #Create an IDA solver
    
    sim.initiate() #Calculate initial conditions
    sim.simulate(30,3000) #Simulate 30 seconds with 3000 communication points
    
    
    write_data(sim) #Writes data

    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('SecondOrder_result.txt')
    x1_sim = res.get_variable_data('x1')
    x2_sim = res.get_variable_data('x2')
    u_sim = res.get_variable_data('u')
    
    assert N.abs(x1_sim.x[-1]*1.e1 - (-8.3999640)) < 1e-3, \
            "Wrong value of x1_sim function in simulation_with_input.py"

    assert N.abs(x2_sim.x[-1]*1.e1 - (-5.0691179)) < 1e-3, \
            "Wrong value of x2_sim function in simulation_with_input.py"  

    assert N.abs(u_sim.x[-1]*1.e1 - (-8.3907153)) < 1e-3, \
            "Wrong value of u_sim function in simulation_with_input.py"  



#    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
#           "Wrong value in simulation result in RLC.py"


    if with_plots:
        fig = p.figure()
        p.clf()
        p.subplot(2,1,1)
        p.plot(x1_sim.t, x1_sim.x, x2_sim.t, x2_sim.x)
        p.subplot(2,1,2)
        p.plot(u_sim.t, u_sim.x,'x-',t, u[:,0],'x-')

        p.show()


if __name__=="__main__":
    run_demo()
