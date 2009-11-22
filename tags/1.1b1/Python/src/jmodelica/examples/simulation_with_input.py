#!/usr/bin/env python 
# -*- coding: utf-8 -*-

import os
import numpy as N
import pylab as p
import matplotlib

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.tests import get_example_path
from jmodelica.simulation.sundials import SundialsDAESimulator
from jmodelica.simulation.sundials import TrajectoryLinearInterpolation
from jmodelica.compiler import ModelicaCompiler
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

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

    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    simulator = SundialsDAESimulator(model, verbosity=3, start_time=0.0, final_time=30.0, time_step=0.01,input=u_traj)
    simulator.run()
        
    simulator.write_data()

    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('SecondOrder_result.txt')
    x1_sim = res.get_variable_data('x1')
    x2_sim = res.get_variable_data('x2')
    u_sim = res.get_variable_data('u')

#    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
#           "Wrong value in simulation result in RLC.py"
    
    fig = p.figure()
    p.clf()
    p.subplot(2,1,1)
    p.plot(x1_sim.t, x1_sim.x, x2_sim.t, x2_sim.x)
    p.subplot(2,1,2)
    p.plot(u_sim.t, u_sim.x,'x-',t, u[:,0],'x-')

    p.show()


if __name__=="__main__":
    run_demo()
