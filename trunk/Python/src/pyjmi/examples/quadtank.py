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
import matplotlib.pyplot as plt
import scipy.integrate as integr

# Import the JModelica.org Python packages
from pymodelica import compile_jmu
from pyjmi import JMUModel

def run_demo(with_plots=True):
    """
    Optimal control of the quadruple tank process.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    # Compile the Optimica model to JMU
    jmu_name = compile_jmu("QuadTank_pack.QuadTank_Opt", 
        curr_dir+"/files/QuadTank.mop")

    # Load the dynamic library and XML data
    qt = JMUModel(jmu_name)

    # Define inputs for operating point A
    u_A = N.array([2.,2])

    # Define inputs for operating point B
    u_B = N.array([2.5,2.5])

    x_0 = N.ones(4)*0.01

    def res(y,t):
        for i in range(4):
            qt.real_x[i+1] = y[i]
        qt.jmimodel.ode_f()
        return qt.real_dx[1:5]

    # Compute stationary state values for operating point A
    qt.real_u = u_A
    
    t_sim = N.linspace(0.,2000.,500)
    y_sim = integr.odeint(res,x_0,t_sim)

    x_A = y_sim[-1,:]

    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(211)
        plt.plot(t_sim,y_sim[:,0:4])
        plt.grid()
    
    # Compute stationary state values for operating point A
    qt.real_u = u_B
    
    t_sim = N.linspace(0.,2000.,500)
    y_sim = integr.odeint(res,x_0,t_sim)
    
    x_B = y_sim[-1,:]

    if with_plots:
        # Plot
        plt.figure(1)
        plt.subplot(212)
        plt.plot(t_sim,y_sim[:,0:4])
        plt.grid()
        plt.show()
    
    qt.set("x1_0",x_A[0])
    qt.set("x2_0",x_A[1])
    qt.set("x3_0",x_A[2])
    qt.set("x4_0",x_A[3])

    qt.set("x1_r",x_B[0])
    qt.set("x2_r",x_B[1])
    qt.set("x3_r",x_B[2])
    qt.set("x4_r",x_B[3])

    qt.set("u1_r",u_B[0])
    qt.set("u2_r",u_B[1])

    # Solve optimal control problem
    res = qt.optimize(options={'IPOPT_options':{'max_iter':500}})

    # Extract variable profiles
    x1=res['x1']
    x2=res['x2']
    x3=res['x3']
    x4=res['x4']
    u1=res['u1']
    u2=res['u2']
    t =res['time']

    assert N.abs(res.final('cost') - 5.0333257e+02) < 1e-3
    
    if with_plots:
        # Plot
        plt.figure(2)
        plt.clf()
        plt.subplot(411)
        plt.plot(t,x1)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(412)
        plt.plot(t,x2)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(413)
        plt.plot(t,x3)
        plt.grid()
        plt.ylabel('x3')
        
        plt.subplot(414)
        plt.plot(t,x4)
        plt.grid()
        plt.ylabel('x4')
        plt.show()
        
        plt.figure(3)
        plt.clf()
        plt.subplot(211)
        plt.plot(t,u1)
        plt.grid()
        plt.ylabel('u1')
        
        plt.subplot(212)
        plt.plot(t,u2)
        plt.grid()
        plt.ylabel('u2')
        
if __name__ == "__main__":
    run_demo()
