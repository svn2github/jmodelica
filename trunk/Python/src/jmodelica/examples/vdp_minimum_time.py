#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """Demonstrate how to solve a minimum time
    dynamic optimization problem based on a
    Van der Pol oscillator system."""

    oc = OptimicaCompiler()
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
    nlp = jmi.SimultaneousOptLagPols(vdp,n_e,hs,n_cp)

    # Create an Ipopt NLP object
    nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)

    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()

    # Retreive the number of points in each column in the
    # result matrix
    n_points = nlp.jmi_simoptlagpols.opt_sim_get_result_variable_vector_length()
    n_points = n_points.value

    # Create result data vectors
    p_opt = N.zeros(1)
    t_ = N.zeros(n_points)
    dx_ = N.zeros(2*n_points)
    x_ = N.zeros(2*n_points)
    u_ = N.zeros(n_points)
    w_ = N.zeros(n_points)
    
    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)

    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(311)
        plt.plot(t_,x_[0:n_points])
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(312)
        plt.plot(t_,x_[n_points:n_points*2])
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(313)
        plt.plot(t_,u_[0:n_points])
        plt.grid()
        plt.ylabel('x2')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
