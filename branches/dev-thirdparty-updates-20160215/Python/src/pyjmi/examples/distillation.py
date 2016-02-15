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

def run_demo(with_plots=True, with_blocking_factors = False):
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
    jmu_name = compile_jmu("DISTLib.Binary_Dist_initial", 
        curr_dir+"/files/DISTLib.mo")

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
    for i in range(N.size(y_A)):
        y_A[i] = init_model.get('y['+ str(i+1) +']')
        x_A[i] = init_model.get('x['+ str(i+1) +']')
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
    for i in range(N.size(y_B)):
        y_B[i] = init_model.get('y[' + str(i+1) + ']')
        x_B[i] = init_model.get('x[' + str(i+1) + ']')
        print '(' + str(i+1) + ', %f, %f)' %(x_B[i], y_B[i])

    # Set up and solve an optimal control problem. 

    # Compile the JMU
    jmu_name = compile_jmu("DISTLib_Opt.Binary_Dist_Opt1", 
        (curr_dir+"/files/DISTLib.mo",curr_dir+"/files/DISTLib_Opt.mop"), 
        compiler_options={'state_start_values_fixed':True})

    # Load the dynamic library and XML data
    model = JMUModel(jmu_name)

    # Initialize the model with parameters

    # Initialize the model to stationary point A
    for i in range(N.size(x_A)):
        model.set('x_0[' + str(i+1) + ']', x_A[i])

    # Set the target values to stationary point B
    model.set('rr_ref',rr_0_B)
    model.set('y1_ref',y_B[0])

    n_e = 100               # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3;               # Number of collocation points in each element

    # Solve the optimization problem
    if with_blocking_factors:
        # Blocking factors for control parametrization
        blocking_factors=4*N.ones(n_e/4,dtype=N.int)
        
        opt_opts = model.optimize_options()
        opt_opts['n_e'] = n_e
        opt_opts['n_cp'] = n_cp
        opt_opts['hs'] = hs
        opt_opts['blocking_factors'] = blocking_factors
        
        opt_res = model.optimize(options=opt_opts)
    else:
        opt_res = model.optimize(options={'n_e':n_e, 'n_cp':n_cp, 'hs':hs})

    # Extract variable profiles
    u1_res     = opt_res['rr']
    u1_ref_res = opt_res['rr_ref']
    y1_ref_res = opt_res['y1_ref']
    time       = opt_res['time']
    
    x_res = []
    x_ref_res = []
    for i in range(N.size(x_B)):
        x_res.append(opt_res['x[' + str(i+1) + ']'])

    y_res = []
    for i in range(N.size(x_B)):
        y_res.append(opt_res['y[' + str(i+1) + ']'])
        
    
    if with_blocking_factors:
        assert N.abs(opt_res.final('cost')/1.e1 - 2.8549683) < 1e-3
    else:
        assert N.abs(opt_res.final('cost')/1.e1 - 2.8527469) < 1e-3

    # Plot the results
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.hold(True)
        plt.subplot(311)
        plt.title('Liquid composition')
        plt.plot(time, x_res[0])
        plt.ylabel('x1')
        plt.grid()
        plt.subplot(312)
        plt.plot(time, x_res[16])
        plt.ylabel('x17')
        plt.grid()
        plt.subplot(313)
        plt.plot(time, x_res[31])
        plt.ylabel('x32')
        plt.grid()
        plt.xlabel('t [s]')
        plt.show()
        
        # Plot the results
        plt.figure(2)
        plt.clf()
        plt.hold(True)
        plt.subplot(311)
        plt.title('Vapor composition')
        plt.plot(time, y_res[0])
        plt.plot(time, y1_ref_res, '--')
        plt.ylabel('y1')
        plt.grid()
        plt.subplot(312)
        plt.plot(time, y_res[16])
        plt.ylabel('y17')
        plt.grid()
        plt.subplot(313)
        plt.plot(time, y_res[31])
        plt.ylabel('y32')
        plt.grid()
        plt.xlabel('t [s]')
        plt.show()
        
        
        plt.figure(3)
        plt.clf()
        plt.hold(True)
        plt.plot(time, u1_res)
        plt.ylabel('u')
        plt.plot(time, u1_ref_res, '--')
        plt.xlabel('t [s]')
        plt.title('Reflux ratio')
        plt.grid()
        plt.show()

if __name__ == "__main__":
    run_demo()

