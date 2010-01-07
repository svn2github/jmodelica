#!/usr/bin/env python 
# -*- coding: utf-8 -*-

import os
import numpy as N
import pylab as p

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.simulation.assimulo import JMIExplicit
from jmodelica.compiler import OptimicaCompiler
from Assimulo.Explicit_ODE import CVode


def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the ODE simulator.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'VDP_pack.VDP_Opt'
    mofile = curr_dir+'/files/VDP.mo'
    package = 'VDP_pack_VDP_Opt'
    
    
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    oc.compile_model(mofile,model_name)

    # Load the dynamic library and XML data
    model=jmi.Model(package)
    
    VDP_mod = JMIExplicit(model)
    
    VDP_sim = CVode(VDP_mod)
    VDP_sim.discr = 'BDF' #discretication method, default Adams
    VDP_sim.iter = 'Newton' #iteration method, default FixedPoint
    VDP_sim(20) #Runs the simulation
    VDP_sim.stats_print() #Prints the integration statistics
    VDP_sim.plot() #Plots the solution

if __name__=="__main__":
    run_demo()
