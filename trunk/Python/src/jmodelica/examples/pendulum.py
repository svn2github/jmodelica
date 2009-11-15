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
    """Demonstrate how to solve a dynamic optimization
    problem based on an inverted pendulum system."""

    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    # Comile the Optimica model first to C code and
    # then to a dynamic library
    oc.compile_model(curr_dir+"/files/Pendulum_pack.mo",
                 "Pendulum_pack.Pendulum_Opt",
                 target='ipopt')

    # Load the dynamic library and XML data
    pend=jmi.Model("Pendulum_pack_Pendulum_Opt")

    # Initialize the mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element

    # Create an NLP object
    nlp = ipopt.NLPCollocationLagrangePolynomials(pend,n_e,hs,n_cp)

    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)

    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()

    # Write to file. The resulting file can also be
    # loaded into Dymola.
    nlp.export_result_dymola()
    
    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('Pendulum_pack_Pendulum_Opt_result.txt')

    # Extract variable profiles
    theta=res.get_variable_data('pend.theta')
    dtheta=res.get_variable_data('pend.dtheta')
    x=res.get_variable_data('pend.x')
    dx=res.get_variable_data('pend.dx')
    u=res.get_variable_data('u')
    
    cost=res.get_variable_data('cost')
    assert N.abs(cost.x[-1] - 1.2921683e-01) < 1e-3, \
           "Wrong value of cost function in pendulum.py"  

    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(211)
        plt.plot(theta.t,theta.x)
        plt.grid()
        plt.ylabel('th')
        
        plt.subplot(212)
        plt.plot(theta.t,theta.x)
        plt.grid()
        plt.ylabel('dth')
        plt.xlabel('time')
        plt.show()
        
        plt.figure(2)
        plt.clf()
        plt.subplot(311)
        plt.plot(x.t,x.x)
        plt.grid()
        plt.ylabel('x')
        
        plt.subplot(312)
        plt.plot(dx.t,dx.x)
        plt.grid()
        plt.ylabel('dx')
        plt.xlabel('time')
        
        plt.subplot(313)
        plt.plot(u.t,u.x)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()
        
if __name__ == "__main__":
    run_demo()
