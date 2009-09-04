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
import scipy.integrate as integr

def run_demo():
    """Demonstrate how to solve a simple
    parameter estimation problem."""

    oc = OptimicaCompiler()
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile the Optimica model first to C code and
    # then to a dynamic library
    oc.compile_model(curr_dir+"/files/ParameterEstimation_1.mo",
                     "ParEst.ParEst",
                     target='ipopt')
    
    # Load the dynamic library and XML data
    model=jmi.Model("ParEst_ParEst")
    
    # Retreive parameter and variable vectors
    pi = model.getPI();
    x = model.getX();
    dx = model.getDX();
    u = model.getU();
    w = model.getW();
    
    # Set model input
    w[0] = 1

    # ODE right hand side
    # This can be done since DAE residuals 1 and 2
    # are written on simple "ODE" form: f(x,u)-\dot x = 0
    def F(xx,t):
        dx[0] = 0. # Set derivatives to zero
        dx[1] = 0.
        x[0] = xx[0] # Set states
        x[1] = xx[1]
        res = N.zeros(5); # Create residual vector
        model.jmimodel.dae_F(res) # Evaluate DAE residual
        return N.array([res[1],res[2]])
    
    # Simulate model to get measurement data
    N_points = 100 # Number of points in simulation
    t0 = 0
    tf = 15
    t_sim = N.linspace(t0,tf,num=N_points)
    xx0=N.array([0.,0.])
    xx = integr.odeint(F,xx0,t_sim)
        
    # Extract measurements
    N_points_meas = 11
    t_meas = N.linspace(t0,10,num=N_points_meas)
    xx_meas = integr.odeint(F,xx0,t_meas)

    # Add measurement noice
    xx_meas[:,0] = xx_meas[:,0] + N.random.random(N_points_meas)*0.2-0.1
    
    # Set parameters corresponding to measurement data in model
    pi[4:15] = t_meas
    pi[15:26] = xx_meas[:,0]

    # Plot simulation
    plt.figure(1)
    plt.clf()
    plt.subplot(211)
    plt.plot(t_sim,xx[:,0])
    plt.grid()
    plt.plot(t_meas,xx_meas[:,0],'x')
    plt.ylabel('x1')
    
    plt.subplot(212)
    plt.plot(t_sim,xx[:,1])
    plt.grid()
    plt.ylabel('x2')
    plt.show()
    
    # Initialize the mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    # Create an NLP object
    nlp = jmi.SimultaneousOptLagPols(model,n_e,hs,n_cp)
    
    # Create an Ipopt NLP object
    nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)
    
    #nlp_ipopt.opt_sim_ipopt_set_string_option("derivative_test","first-order")
    nlp_ipopt.opt_sim_ipopt_set_int_option("max_iter",500)
    
    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()

    # Retreive the number of points in each column in the
    # result matrix
    n_points = nlp.jmi_simoptlagpols.opt_sim_get_result_variable_vector_length()
    n_points = n_points.value

    # Create optimization result data vectors
    p_opt = N.zeros(2)
    t_ = N.zeros(n_points)
    dx_ = N.zeros(2*n_points)
    x_ = N.zeros(2*n_points)
    u_ = N.zeros(n_points)
    w_ = N.zeros(4*n_points)
    
    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)
    
    # Plot optimization result
    plt.figure(2)
    plt.clf()
    plt.subplot(211)
    plt.plot(t_,w_[n_points:2*n_points])
    plt.plot(t_meas,xx_meas[:,0],'x')
    plt.grid()
    plt.ylabel('y')
    
    plt.subplot(212)
    plt.plot(t_,w_[0:n_points])
    plt.grid()
    plt.ylabel('u')
    plt.show()
    
    print("** Optimal parameter values: **")
    print("w = %f"%pi[0])
    print("z = %f"%pi[1])

if __name__ == "__main__":
    run_demo()
