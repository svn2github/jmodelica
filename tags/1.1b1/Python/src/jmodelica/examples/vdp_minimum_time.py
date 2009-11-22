#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
from jmodelica.optimization import ipopt

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """Demonstrate how to solve a minimum time
    dynamic optimization problem based on a
    Van der Pol oscillator system."""

    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    # Compile the Optimica model first to C code and
    # then to a dynamic library
    oc.compile_model(curr_dir+"/files/VDP.mo",
                     "VDP_pack.VDP_Opt_Min_Time",
                     target='ipopt')

    # Load the dynamic library and XML data
    vdp=jmi.Model("VDP_pack_VDP_Opt_Min_Time")

    # Initialize the mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element

    # Create an NLP object
    nlp = ipopt.NLPCollocationLagrangePolynomials(vdp,n_e,hs,n_cp)

    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)

    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()
    
    # Write to file. The resulting file can also be
    # loaded into Dymola.
    nlp.export_result_dymola()
    
    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('VDP_pack_VDP_Opt_Min_Time_result.txt')

    # Extract variable profiles
    x1=res.get_variable_data('x1')
    x2=res.get_variable_data('x2')
    u=res.get_variable_data('u')
    tf=res.get_variable_data('tf')

    assert N.abs(tf.x[-1] - 2.2811587) < 1e-3, \
            "Wrong value of cost function in cstr_minimum_time.py"
    
    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(311)
        plt.plot(x1.t,x1.x)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(312)
        plt.plot(x2.t,x2.x)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(313)
        plt.plot(u.t,u.x)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
