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

# Import the JModelica.org Python packages
from pymodelica import compile_fmux
from pymodelica import compile_jmu
from pyjmi import JMUModel
from pyjmi import CasadiModel
from pyjmi.optimization.casadi_collocation import ParameterEstimationData

import scipy.integrate as integr

def run_demo(with_plots=True):
    """
    Demonstrate how to solve a simple parameter estimation problem.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile the Optimica model to an XML file
    model_name = compile_fmux("ParEst.ParEstCasADi",
        curr_dir + "/files/ParameterEstimation_1.mop")
    
    # Load the model
    model_casadi = CasadiModel(model_name)

    # Compile the Optimica model to a JMU
    jmu_name = compile_jmu("ParEst.ParEst",
        curr_dir + "/files/ParameterEstimation_1.mop")
    
    # Load the dynamic library
    model = JMUModel(jmu_name)
    
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
    def F(xx, t):
        dx[0] = 0. # Set derivatives to zero
        dx[1] = 0.
        x[0] = xx[0] # Set states
        x[1] = xx[1]
        res = N.zeros(3); # Create residual vector
        model.jmimodel.dae_F(res) # Evaluate DAE residual
        return N.array([res[1], res[2]])
    
    # Simulate model to get measurement data
    N_points = 100 # Number of points in simulation
    t0 = 0
    tf = 15
    t_sim = N.linspace(t0,tf,num=N_points)
    xx0 = N.array([0.,0.])
    xx = integr.odeint(F,xx0,t_sim)
        
    # Extract measurements
    N_points_meas = 11
    t_meas = N.linspace(t0,10,num=N_points_meas)
    xx_meas = integr.odeint(F,xx0,t_meas)

    # Add measurement noice
    noice = [0.01463904, 0.0139424, 0.09834249, 0.0768069, 0.01971631, 
        -0.03827911, 0.05266659, -0.02608245, 0.05270525, 0.04717024, 0.0779514,]
    xx_meas[:,0] = xx_meas[:,0] + noice

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

    Q = N.array([[1.]])
    measured_variables=['sys.y']
    data = N.hstack((N.transpose(N.array([t_meas])),N.transpose(N.array([xx_meas[:,0]]))))

    par_est_data = ParameterEstimationData(Q,measured_variables,data)

    opts = model_casadi.optimize_options(algorithm="LocalDAECollocationAlg")

    opts['n_e'] = 16
    opts['n_cp'] = 3

    opts['parameter_estimation_data'] = par_est_data

    res_casadi = model_casadi.optimize(algorithm="LocalDAECollocationAlg", options=opts)

    # Extract variable profiles
    x1 = res_casadi['sys.x1']
    u = res_casadi['u']
    w = res_casadi['sys.w']
    z = res_casadi['sys.z']
    t = res_casadi['time']
    
    assert N.abs(res_casadi.final('sys.x1') - 0.99953927) < 1e-3
    assert N.abs(res_casadi.final('sys.w') - 1.04972186)  < 1e-3
    assert N.abs(res_casadi.final('sys.z') - 0.4703822)   < 1e-3

    if with_plots:
        # Plot optimization result
        plt.figure(3)
        plt.clf()
        plt.subplot(211)
        plt.plot(t,x1,'g')
        plt.plot(t_sim,xx[:,0])
        plt.plot(t_meas,xx_meas[:,0],'x')
        plt.grid()
        plt.subplot(212)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.show()
                
        print("** Optimal parameter values: **")
        print("w = %f"%w)
        print("z = %f"%z)

if __name__ == "__main__":
    run_demo()
