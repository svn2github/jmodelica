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

def run_demo(with_plots=True):
    """ 
    Load change of a distillation column. The distillation column model is 
    documented in the paper:

    @Article{hahn+02,
    title={An improved method for nonlinear model reduction using balancing of 
        empirical gramians},
    author={Hahn, J. and Edgar, T.F.},
    journal={Computers and Chemical Engineering},
    volume={26},
    number={10},
    pages={1379-1397},
    year={2002}
    }
    
    Note: This example requires Ipopt with MA27.
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
    print(' *** Stationary point A ***')
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
    print(' *** Stationary point B ***')
    print '(Tray index, x_i_B, y_i_B)'
    for i in range(32):
        y_B[i] = init_result['y[' + str(i+1) + ']'][0]
        x_B[i] = init_result['x[' + str(i+1) + ']'][0]
        print '(' + str(i+1) + ', %f, %f)' %(x_B[i], y_B[i])

    # Set up and solve an optimal control problem. 

    # Compile the JMU
    jmu_name = compile_jmu("JMExamples_opt.Distillation1_opt", 
    (curr_dir+"/files/JMExamples.mo",curr_dir+"/files/JMExamples_opt.mop"), 
        compiler_options={'state_start_values_fixed':True}) 

    # Load the dynamic library and XML data
    model = JMUModel(jmu_name)

    # Initialize the model with parameters

    # Initialize the model to stationary point A
    for i in range(32):
        model.set('x_init[' + str(i+1) + ']', x_A[i])

    # Set the target values to stationary point B
    model.set('rr_ref',rr_0_B)
    model.set('x1_ref',x_B[0])

    # Solve the optimization problem
    opts = model.optimize_options()
    opts['hs'] = N.ones(100)*1./100  # Equidistant points
    opts['n_e'] = 100                # Number of elements
    opts['n_cp'] = 3                 # Number of collocation points in each element
    opt_res = model.optimize()

    # Extract variable profiles
    x1  = opt_res['x[1]']
    x8  = opt_res['x[8]']
    x16 = opt_res['x[16]']
    x24 = opt_res['x[24]']
    x32 = opt_res['x[32]']
    y1  = opt_res['y[1]']
    y8  = opt_res['y[8]']
    y16 = opt_res['y[16]']
    y24 = opt_res['y[24]']
    y32 = opt_res['y[32]']
    t   = opt_res['time']
    rr  = opt_res['rr']
    
    assert N.abs(opt_res.final('rr') - 2.0) < 1e-3
    
    # Plot the results
    if with_plots:
        plt.figure()
        plt.subplot(1,2,1)
        plt.plot(t,x16,t,x32,t,x1,t,x8,t,x24)
        plt.title('Liquid composition')
        plt.grid(True)
        plt.ylabel('x')
        plt.subplot(1,2,2)
        plt.plot(t,y16,t,y32,t,y1,t,y8,t,y24)
        plt.title('Vapor composition')
        plt.grid(True)
        plt.ylabel('y')
        
        plt.xlabel('time')
        plt.show()        
        
        plt.figure(3)
        plt.clf()
        plt.hold(True)
        plt.plot(t,rr)
        plt.ylabel('rr')
        plt.xlabel('t [s]')
        plt.title('Reflux ratio')

        plt.show()

if __name__ == "__main__":
    run_demo()

