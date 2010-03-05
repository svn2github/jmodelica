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
import scipy.integrate as integr

def run_demo(with_plots=True):
    """Demonstrate how to solve a simple
    parameter estimation problem."""

    oc = OptimicaCompiler()
#    oc.set_boolean_option('state_start_values_fixed',True)

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile the Optimica model first to C code and
    # then to a dynamic library
    oc.compile_model(curr_dir+"/files/ParameterEstimation_1.mo",
                     "ParEst.ParEst",
                     target='ipopt')
    
    # Load the dynamic library and XML data
    model=jmi.Model("ParEst_ParEst")
    
    # Retreive parameter and variable vectors
    pi = model.get_real_pi();
    x = model.get_real_x();
    dx = model.get_real_dx();
    u = model.get_real_u();
    w = model.get_real_w();
    
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
        res = N.zeros(3); # Create residual vector
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
    #noice = N.random.random(N_points_meas)*0.2-0.1
    noice = [ 0.01463904,  0.0139424,   0.09834249,  0.0768069,   0.01971631, -0.03827911,
  0.05266659, -0.02608245,  0.05270525,  0.04717024,  0.0779514, ]
    xx_meas[:,0] = xx_meas[:,0] + noice
    
    # Set parameters corresponding to measurement data in model
    pi[4:15] = t_meas
    pi[15:26] = xx_meas[:,0]

    if with_plots:
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
    nlp = ipopt.NLPCollocationLagrangePolynomials(model,n_e,hs,n_cp)
    
    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)
    
    #nlp_ipopt.opt_sim_ipopt_set_string_option("derivative_test","first-order")
    nlp_ipopt.opt_sim_ipopt_set_int_option("max_iter",500)
    
    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()

    # Write to file. The resulting file can also be
    # loaded into Dymola.
    nlp.export_result_dymola()
    
    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('ParEst_ParEst_result.txt')

    # Extract variable profiles
    x1 = res.get_variable_data('sys.x1')
    u = res.get_variable_data('u')
    w = res.get_variable_data('sys.w')
    z = res.get_variable_data('sys.z')
    
    assert N.abs(w.x[-1] - 1.051198) < 1e-4, \
            "Wrong value of parameter w in parameter_estimation_1.py"  
    assert N.abs(z.x[-1] - 0.448710 ) < 1e-4, \
            "Wrong value of parameter z in parameter_estimation_1.py"  
    
    if with_plots:
        # Plot optimization result
        plt.figure(2)
        plt.clf()
        plt.subplot(211)
        plt.plot(x1.t,x1.x)
        plt.plot(t_meas,xx_meas[:,0],'x')
        plt.grid()
        plt.ylabel('y')
        
        plt.subplot(212)
        plt.plot(u.t,u.x)
        plt.grid()
        plt.ylabel('u')
        plt.show()
        
        print("** Optimal parameter values: **")
        print("w = %f"%pi[0])
        print("z = %f"%pi[1])

if __name__ == "__main__":
    run_demo()
