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
from jmodelica.compiler import ModelicaCompiler
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the DAE simulator. The
    result can be compared with that of sim_rlc.py which has solved the
    same problem using dymola. Also writes information to a file.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'RLC_Circuit'
    mofile = curr_dir+'/files/RLC_Circuit.mo'
    
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(mofile,model_name,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(model_name)

    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    simulator = SundialsDAESimulator(model, verbosity=3, start_time=0.0, final_time=30.0, time_step=0.01)
    simulator.run()
        
    simulator.write_data()

    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('RLC_Circuit_result.txt')
    sine_y = res.get_variable_data('sine.y')
    resistor_v = res.get_variable_data('resistor.v')
    inductor1_i = res.get_variable_data('inductor1.i')

    #Ts, ys = simulator.get_solution('sine.y','resistor.v','inductor1.i')
    fig = p.figure()
    p.plot(sine_y.t, sine_y.x, resistor_v.t, resistor_v.x, inductor1_i.t, inductor1_i.x)
    p.legend(('sine.y','resistor.v','inductor1.i'))
    p.show()


if __name__=="__main__":
    run_demo()
