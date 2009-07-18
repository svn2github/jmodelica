#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import library for path manipulations
import os.path

import jmodelica
import jmodelica.jmi as jmi
import jmodelica.optimicacompiler as oc

import numpy as N
import scipy as S
import scipy.optimize as opt
import ctypes as ct
import matplotlib.pyplot as plt


def run_demo():
    """Demonstrate how to solve the 
    CSTR optimization problem."""

    curr_dir = os.path.dirname(os.path.abspath(__file__));


    oc.compile_model(curr_dir+"/CSTR.mo", "CSTR.CSTR_Opt", target='ipopt')

    cstr=jmi.Model("CSTR_CSTR_Opt")

    pi = cstr.getPI();
    x = cstr.getX();
    dx = cstr.getDX();
    u = cstr.getU();
    w = cstr.getW();
    
    dx[0] = 0;
    dx[1] = 0;
    dx[2] = 0;
    
    x[1]=500
    
    # Solve initialization system
    # Free variables are u, T
    def F0_cost(y):
       w[0] = y[0] # Set u
       x[2] = y[1] # Set T
       res = N.zeros(4)
       cstr.jmimodel._dll.jmi_dae_F(cstr.jmimodel._jmi,res) # Evaluate DAE
       return N.array([res[1],res[2]]) # Return result
    
    # Start values for least squares problem
    xx0 = N.array([300, 325])
    xopt,cov_x,infodict,msg,iter = opt.leastsq(F0_cost,xx0,full_output=1)
    
    print(xopt)

    pi[14] = x[1] # set c target
    pi[15] = xopt[1] # set T target
    pi[16] = xopt[0] # set u target
    
    # Initialize the mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    # Create an NLP object
    nlp = jmi.SimultaneousOptLagPols(cstr,n_e,hs,n_cp)
    
    # Create an Ipopt NLP object
    nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)
       
    nlp_ipopt.opt_sim_ipopt_set_int_option("max_iter",500)

    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()
    
    # Retreive the number of points in each column in the
    # result matrix
    n_points = nlp.jmi_simoptlagpols.opt_sim_get_result_variable_vector_length()
    n_points = n_points.value
    
    # Create result data vectors
    p_opt = N.zeros(1)
    t_ = N.zeros(n_points)
    dx_ = N.zeros(3*n_points)
    x_ = N.zeros(3*n_points)
    u_ = N.zeros(n_points)
    w_ = N.zeros(n_points)

    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)
    
    # Plot
    plt.figure(1)
    plt.clf()
    plt.subplot(311)
    plt.plot(t_,x_[n_points:2*n_points])
    plt.grid()
    plt.ylabel('x1')
    
    plt.subplot(312)
    plt.plot(t_,x_[n_points*2:n_points*3])
    plt.grid()
    plt.ylabel('x2')
    
    plt.subplot(313)
    plt.plot(t_,u_)
    plt.grid()
    plt.ylabel('u')
    plt.xlabel('time')
    plt.show()
    
if __name__ == "__main__":
    run_demo()
