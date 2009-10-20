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


def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the DAE simulator. The
    result can be compared with that of sim_rlc.py which has solved the
    same problem using dymola. Also writes information to a file.
    """
    
    path = get_example_path()
    os.chdir(path)
    
 
    libname = 'RLC_Circuit'
    mofile = 'RLC_Circuit.mo'
    optpackage = 'RLC_Circuit'
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(mofile,libname)

    # Load the dynamic library and XML data
    model=jmi.Model(optpackage)

    simulator = SundialsDAESimulator(model, verbosity=3, start_time=0.0, final_time=30.0, time_step=0.01)
    simulator.run()
    
    Ts, ys = simulator.get_solution('sine.y','resistor.v','inductor1.i')
    fig = p.figure()
    p.plot(Ts, ys)
    p.legend(('sine.y','resistor.v','inductor1.i'))
    p.show()
    
    simulator.write_data()

if __name__=="__main__":
    
    run_demo()
