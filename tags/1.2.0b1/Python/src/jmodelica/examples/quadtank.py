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

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
from jmodelica import optimize

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt
import scipy.integrate as integr

def run_demo(with_plots=True):
    """Optimal control of the quadruple tank process."""

    oc = OptimicaCompiler()

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    # Compile the Optimica model first to C code and
    # then to a dynamic library
    oc.compile_model("QuadTank_pack.QuadTank_Opt",
                     curr_dir+"/files/QuadTank.mo",
                     target='ipopt')

    # Load the dynamic library and XML data
    qt=jmi.Model("QuadTank_pack_QuadTank_Opt")

    # Define inputs for operating point A
    u_A = N.array([2.,2])

    # Define inputs for operating point B
    u_B = N.array([2.5,2.5])

    x_0 = N.ones(4)*0.01

    def res(y,t):
        for i in range(4):
            qt.get_real_x()[i+1] = y[i]
        qt.jmimodel.ode_f()
        return qt.get_real_dx()[1:5]

    # Compute stationary state values for operating point A
    qt.set_real_u(u_A)
    #qt.getPI()[21] = u_A[0]
    #qt.getPI()[22] = u_A[1]
    
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
    qt.set_real_u(u_B)
    
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
    
    qt.set_value("x1_0",x_A[0])
    qt.set_value("x2_0",x_A[1])
    qt.set_value("x3_0",x_A[2])
    qt.set_value("x4_0",x_A[3])

    qt.set_value("x1_r",x_B[0])
    qt.set_value("x2_r",x_B[1])
    qt.set_value("x3_r",x_B[2])
    qt.set_value("x4_r",x_B[3])

    qt.set_value("u1_r",u_B[0])
    qt.set_value("u2_r",u_B[1])

    # Solve optimal control problem
    (qt, res) = optimize(qt, solver_args={'max_iter':500})

    # Extract variable profiles
    x1=res.get_variable_data('x1')
    x2=res.get_variable_data('x2')
    x3=res.get_variable_data('x3')
    x4=res.get_variable_data('x4')
    u1=res.get_variable_data('u1')
    u2=res.get_variable_data('u2')

    cost=res.get_variable_data('cost')

    assert N.abs(cost.x[-1] - 5.0333257e+02) < 1e-3, \
           "Wrong value of cost function in quadtank.py"  

    if with_plots:
        # Plot
        plt.figure(2)
        plt.clf()
        plt.subplot(411)
        plt.plot(x1.t,x1.x)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(412)
        plt.plot(x2.t,x2.x)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(413)
        plt.plot(x3.t,x3.x)
        plt.grid()
        plt.ylabel('x3')
        
        plt.subplot(414)
        plt.plot(x4.t,x4.x)
        plt.grid()
        plt.ylabel('x4')
        plt.show()
        
        plt.figure(3)
        plt.clf()
        plt.subplot(211)
        plt.plot(u1.t,u1.x)
        plt.grid()
        plt.ylabel('u1')
        
        plt.subplot(212)
        plt.plot(u2.t,u2.x)
        plt.grid()
        plt.ylabel('u2')
        
    if __name__ == "__main__":
        run_demo()
