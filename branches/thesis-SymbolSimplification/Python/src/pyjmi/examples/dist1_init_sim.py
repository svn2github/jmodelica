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
from pymodelica import compile_jmu
from pyjmi import JMUModel

# Import the JModelica.org Python packages
from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    Distillation4 optimization model
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

	# Compile the stationary initialization model into a JMU
    jmu_name = compile_jmu("JMExamples.Distillation.Distillation1Input_init", 
    curr_dir+"/files/JMExamples.mo")

    # Load a model instance into Python
    init_model = JMUModel(jmu_name)
    
    # Set inputs for Stationary point A
    rr_0_A = 3.0
    init_model.set('rr',rr_0_A)
    init_result = init_model.initialize()
    	
    # Store stationary point A
    y_A = N.zeros(32)
    x_A = N.zeros(32)
    # print(' *** Stationary point A ***')
    print '(Tray index, x_i_A, y_i_A)'
    for i in range(32):
        y_A[i] = init_result['y['+ str(i+1) +']'][0]
        x_A[i] = init_result['x['+ str(i+1) +']'][0]
        print '(' + str(i+1) + ', %f, %f)' %(x_A[i], y_A[i])
    
    # Set inputs for stationary point B
    rr_0_B = 2.0
    init_model.set('rr',rr_0_B)
    init_result = init_model.initialize()

    # Store stationary point B
    y_B = N.zeros(32)
    x_B = N.zeros(32)
    # print(' *** Stationary point B ***')
    print '(Tray index, x_i_B, y_i_B)'
    for i in range(32):
        y_B[i] = init_result['y[' + str(i+1) + ']'][0]
        x_B[i] = init_result['x[' + str(i+1) + ']'][0]
        print '(' + str(i+1) + ', %f, %f)' %(x_B[i], y_B[i])

    # Set up and solve the simulation problem. 

    fmu_name1 = compile_fmu("JMExamples.Distillation.Distillation1Inputstep", 
    curr_dir+"/files/JMExamples.mo")
    dist1 = load_fmu(fmu_name1)

    # Initialize the model with parameters

    # Initialize the model to stationary point A
    for i in range(32):
        dist1.set('x_init[' + str(i+1) + ']', x_A[i])
		
    res = dist1.simulate(final_time=50)

    # Extract variable profiles
    x1  = res['x[1]']
    x8  = res['x[8]']
    x16	= res['x[16]']
    x24	= res['x[24]']
    x32	= res['x[32]']
    y1  = res['y[1]']
    y8  = res['y[8]']
    y16	= res['y[16]']
    y24	= res['y[24]']
    y32	= res['y[32]']
    t	= res['time']
    rr  = res['rr']
    
    print "t = ", repr(N.array(t))
    print "x1 = ", repr(N.array(x1))
    print "x8 = ", repr(N.array(x8))
    print "x16 = ", repr(N.array(x16))
    print "x32 = ", repr(N.array(x32))

    if with_plots:
        # Plot
        plt.figure()
        plt.subplot(1,3,1)
        plt.plot(t,x16,t,x32,t,x1,t,x8,t,x24)
        plt.title('Liquid composition')
        plt.grid(True)
        plt.ylabel('x')
        plt.subplot(1,3,2)
        plt.plot(t,y16,t,y32,t,y1,t,y8,t,y24)
        plt.title('Vapor composition')
        plt.grid(True)
        plt.ylabel('y')
        plt.subplot(1,3,3)
        plt.plot(t,rr)
        plt.title('Reflux ratio')
        plt.grid(True)
        plt.ylabel('rr')
		
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
