
#!/usr/bin/env python 
# -*- coding: utf-8 -*-

import os
import numpy as N
import pylab as p
import matplotlib

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.tests import get_example_path
from jmodelica.simulation.assimulo import JMIExplicit
from jmodelica.compiler import OptimicaCompiler
from jmodelica.optimization.assimulo_shooting import Multiple_Shooting
from Assimulo.Explicit_ODE import CVode

def run_demo(with_plots=True):
    """
    An example on how to optimize a model using the Assimulo simulation package
    with multiple shooting.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'QuadTank_pack.QuadTank_Opt'
    mofile = curr_dir+'/files/QuadTank.mo'
    package = 'QuadTank_pack_QuadTank_Opt'
    
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    oc.compile_model(mofile,model_name,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(package)
    Quad_mod = JMIExplicit(model)
    
    Quad_sim = CVode(Quad_mod)
    Quad_sim.discr = 'BDF'
    Quad_sim.iter = 'Newton'
    Quad_sim.atol = Quad_sim.rtol = 1e-6

    Quad_shoot = Multiple_Shooting(Quad_sim, gridsize=10, initial_u=[2.5,2.5])
    Quad_shoot.verbosity = Multiple_Shooting.QUIET
    Quad_shoot.optMethod = 'scipy_slsqp'

    sol = Quad_shoot.run(True)
    
    print sol.xf
    Quad_shoot.plot()

if __name__=="__main__":
    run_demo()
