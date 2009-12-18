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

    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    simulator = SundialsDAESimulator(model, verbosity=3, start_time=0.0, final_time=5.0, time_step=0.01)
    simulator.run()
        
    simulator.write_data()

    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('IfExpExamples_IfExpExample1_result.txt')
    x = res.get_variable_data('x')
    u = res.get_variable_data('u')

    #assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
#           "Wrong value in simulation result in RLC.py"
    
    fig = p.figure()
    p.plot(x.t, x.x, u.t, u.x)
    p.legend(('x','u'))
    p.show()


if __name__=="__main__":
    run_demo()
