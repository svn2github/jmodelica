#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import library for path manipulations
import os.path

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer
from jmodelica.optimization import ipopt
from jmodelica.compiler import OptimicaCompiler

import numpy as N
import scipy as S
import scipy.optimize as opt
import ctypes as ct
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """This example is based on the Hicks-Ray
    Continuously Stirred Tank Reactors (CSTR) system. The system
    has two states, the concentration and the temperature. The
    control input to the system is the temperature of the cooling
    flow in the reactor jacket. The chemical reaction in the reactor
    is exothermic, and also temperature dependent; high temperature
    results in high reaction rate.
    
    The example demonstrates the following steps:
    
    1. How to solve a DAE initialization problem. The initialization
       model have equations specifying that all derivatives
       should be identically zero, which implies that a
       stationary solution is obtained. Two stationary points,
       corresponding to different inputs, are computed. We call
       the stationary points A and B respectively. point A corresponds
       to operating conditions where the reactor is cold and
       the reaction rate is low, whereas point B corresponds to
       a higher temperature where the reaction rate is high.

       For more information about the DAE initialization algorithm, see
       http://www.jmodelica.org/page/10.
       
    2. An optimal control problem is solved where the objective Is to
       transfer the state of the system from stationary point A to point
       B. The challenge is to ignite the reactor while avoiding
       uncontrolled temperature increase. It is also demonstrated how to
       set parameter and variable values in a model.

       More information about the simultaneous optimization algorithm
       can be found at http://www.jmodelica.org/page/10.

    3. The optimization result is saved to file and then
       the important variables are plotted.
"""

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    # Create a Modelica compiler instance
    oc = OptimicaCompiler()
        
    # Compile the stationary initialization model into a DLL
    oc.compile_model(curr_dir+"/files/CSTR.mo", "CSTR.CSTR_Init", target='ipopt')

    # Load a model instance into Python
    init_model = jmi.Model("CSTR_CSTR_Init")
    
    # Create DAE initialization object.
    init_nlp = NLPInitialization(init_model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
    
    # Set inputs for Stationary point A
    Tc_0_A = 250
    init_model.set_value('Tc',Tc_0_A)
    
    # init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
    # init_nlp_ipopt.init_opt_ipopt_set_int_option("max_iter",5)
    
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()
    
    # Store stationary point A
    c_0_A = init_model.get_value('c')
    T_0_A = init_model.get_value('T')
    
    # Print some data for stationary point A
    print(' *** Stationary point A ***')
    print('Tc = %f' % Tc_0_A)
    print('c = %f' % c_0_A)
    print('T = %f' % T_0_A)

    # Set inputs for Stationary point B
    Tc_0_B = 280
    init_model.set_value('Tc',Tc_0_B)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()
    
    # Store stationary point A
    c_0_B = init_model.get_value('c')
    T_0_B = init_model.get_value('T')
    
    # Print some data for stationary point B
    print(' *** Stationary point B ***')
    print('Tc = %f' % Tc_0_B)
    print('c = %f' % c_0_B)
    print('T = %f' % T_0_B)

    oc.compile_model(curr_dir+"/files/CSTR.mo", "CSTR.CSTR_Opt", target='ipopt')

    cstr = jmi.Model("CSTR_CSTR_Opt")

    cstr.set_value('Tc_ref',Tc_0_B)
    cstr.set_value('c_ref',c_0_B)
    cstr.set_value('T_ref',T_0_B)

    cstr.set_value('cstr.c_init',c_0_A)
    cstr.set_value('cstr.T_init',T_0_A)

    # Initialize the mesh
    n_e = 150 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    # Create an NLP object
    nlp = ipopt.NLPCollocationLagrangePolynomials(cstr,n_e,hs,n_cp)
    
    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)
       
    nlp_ipopt.opt_sim_ipopt_set_int_option("max_iter",500)

    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()
    
    # Write to file. The resulting file (CSTR_CSTR_Opt_result.txt) can also be
    # loaded into Dymola.
    nlp.export_result_dymola()
    
    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('CSTR_CSTR_Opt_result.txt')

    # Extract variable profiles
    c_res=res.get_variable_data('cstr.c')
    T_res=res.get_variable_data('cstr.T')
    Tc_res=res.get_variable_data('cstr.Tc')

    c_ref=res.get_variable_data('c_ref')
    T_ref=res.get_variable_data('T_ref')
    Tc_ref=res.get_variable_data('Tc_ref')

    # Plot the results
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.hold(True)
        plt.subplot(311)
        plt.plot(c_res.t,c_res.x)
        plt.plot(c_ref.t,c_ref.x,'--')
        plt.grid()
        plt.ylabel('Concentration')

        plt.subplot(312)
        plt.plot(T_res.t,T_res.x)
        plt.plot(T_ref.t,T_ref.x,'--')
        plt.grid()
        plt.ylabel('Temperature')

        plt.subplot(313)
        plt.plot(Tc_res.t,Tc_res.x)
        plt.plot(Tc_ref.t,Tc_ref.x,'--')
        plt.grid()
        plt.ylabel('Cooling temperature')
        plt.xlabel('time')
        plt.show()
    
if __name__ == "__main__":
    run_demo()
