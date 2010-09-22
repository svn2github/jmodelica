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

# Import the JModelica.org Python packages
from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

def run_demo(with_plots=True):
    """Demonstrate how to solve a dynamic optimization
    problem based on an inverted pendulum system."""
    
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    class_name = "Pendulum_pack.Pendulum_Opt"
    
    # compile JMU
    jmu_name = compile_jmu(class_name, curr_dir+"/files/Pendulum_pack.mop",
        compiler_options={'state_start_values_fixed':True})
    
    model = JMUModel(jmu_name)
    # optimize
    res = model.optimize()

    # Extract variable profiles
    theta=res['pend.theta']
    dtheta=res['pend.dtheta']
    x=res['pend.x']
    dx=res['pend.dx']
    u=res['u']
    t=res['time']
    
    cost=res['cost']
    assert N.abs(cost[-1] - 1.2921683e-01) < 1e-3, \
           "Wrong value of cost function in pendulum.py"  

    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(211)
        plt.plot(t,theta)
        plt.grid()
        plt.ylabel('th')
        
        plt.subplot(212)
        plt.plot(t,theta)
        plt.grid()
        plt.ylabel('dth')
        plt.xlabel('time')
        plt.show()
        
        plt.figure(2)
        plt.clf()
        plt.subplot(311)
        plt.plot(t,x)
        plt.grid()
        plt.ylabel('x')
        
        plt.subplot(312)
        plt.plot(t,dx)
        plt.grid()
        plt.ylabel('dx')
        plt.xlabel('time')
        
        plt.subplot(313)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()
        
if __name__ == "__main__":
    run_demo()
