#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt
import scipy.integrate as integr

# Import the JModelica.org Python packages
from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.optimization import ipopt

def run_demo(with_plots=True):
    """Demonstrate how to solve a simple
    parameter estimation problem."""

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile the Optimica model to a JMU
    jmu_name = compile_jmu("ParEst.ParEst",
        curr_dir+"/files/ParameterEstimation_1.mop")
    
    # Load the dynamic library and XML data
    model=JMUModel(jmu_name)
    
    # Retreive parameter and variable vectors
    pi = model.real_pi
    x = model.real_x
    dx = model.real_dx
    u = model.real_u
    w = model.real_w
    
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
    
    # optimize
    res = model.optimize(options={'IPOPT_options':{"max_iter":500}})
    
    # Extract variable profiles
    x1 = res['sys.x1']
    u = res['u']
    w = res['sys.w']
    z = res['sys.z']
    t = res['time']
    
    assert N.abs(w - 1.051198) < 1e-4, \
            "Wrong value of parameter w in parameter_estimation_1.py"  
    assert N.abs(z - 0.448710 ) < 1e-4, \
            "Wrong value of parameter z in parameter_estimation_1.py"  
    
    if with_plots:
        # Plot optimization result
        plt.figure(2)
        plt.clf()
        plt.subplot(211)
        plt.plot(t,x,'g')
        plt.plot(t_sim,xx[:,0])
        plt.plot(t_meas,xx_meas[:,0],'x')
        plt.grid()
        plt.ylabel('y')
        
        plt.subplot(212)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.show()
        
        print("** Optimal parameter values: **")
        print("w = %f"%pi[0])
        print("z = %f"%pi[1])

if __name__ == "__main__":
    run_demo()
