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
from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """This example is based on a system composed of two
    Continously Stirred Tank Reactors (CSTRs) in series.
    The example demonstrates the following steps:
    
    1. How to solve a DAE initialization problem. The initialization
       model have equations specifying that all derivatives
       should be identically zero, which implies that a
       stationary solution is obtained. Two stationary points,
       corresponding to different inputs, are computed. We call
       the stationary points A and B respectively. For more information
       about the DAE initialization algorithm, see
       http://www.jmodelica.org/page/10.
    
    2. An optimal control problem is solved where the objective
       Is to transfer the state of the system from stationary
       point A to point B. Here, it is also demonstrated how
       to set parameter values in a model. More information
       about the simultaneous optimization algorithm can be
       found at http://www.jmodelica.org/page/10.
    
    3. The optimization result is saved to file and then
       the important variables are plotted."""
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    # Compile the stationary initialization model into a DLL
    jmu_name = compile_jmu("CSTRLib.Components.Two_CSTRs_stat_init", 
        curr_dir+"/files/CSTRLib.mo")

    # Load a JMU model instance
    init_model = JMUModel(jmu_name)
    
    # Set inputs for Stationary point A
    u1_0_A = 1
    u2_0_A = 1
    init_model.set('u1',u1_0_A)
    init_model.set('u2',u2_0_A)
    
    # Solve the DAE initialization system with Ipopt
    init_result = init_model.initialize()
    
    # Store stationary point A
    CA1_0_A = init_model.get('CA1')
    CA2_0_A = init_model.get('CA2')
    T1_0_A = init_model.get('T1')
    T2_0_A = init_model.get('T2')
    
    # Print some data for stationary point A
    print(' *** Stationary point A ***')
    print('u = [%f,%f]' % (u1_0_A,u2_0_A))
    print('CAi = [%f,%f]' % (CA1_0_A,CA2_0_A))
    print('Ti = [%f,%f]' % (T1_0_A,T2_0_A))
    
    # Set inputs for stationary point B
    u1_0_B = 1.1
    u2_0_B = 0.9
    init_model.set('u1',u1_0_B)
    init_model.set('u2',u2_0_B)
    
    # Solve the DAE initialization system with Ipopt
    init_result = init_model.initialize()
   
    # Stationary point B
    CA1_0_B = init_model.get('CA1')
    CA2_0_B = init_model.get('CA2')
    T1_0_B = init_model.get('T1')
    T2_0_B = init_model.get('T2')

    # Print some data for stationary point B
    print(' *** Stationary point B ***')
    print('u = [%f,%f]' % (u1_0_B,u2_0_B))
    print('CAi = [%f,%f]' % (CA1_0_B,CA2_0_B))
    print('Ti = [%f,%f]' % (T1_0_B,T2_0_B))
    
    ## Set up and solve an optimal control problem. 

    # Compile the Model
    jmu_name = compile_jmu("CSTR2_Opt", 
        [curr_dir+"/files/CSTRLib.mo", curr_dir+"/files/CSTR2_Opt.mop"],
        compiler_options={'enable_variable_scaling':True,'index_reduction':True})

    # Load the dynamic library and XML data
    model = JMUModel(jmu_name)

    # Initialize the model with parameters

    # Initialize the model to stationary point A
    model.set('cstr.two_CSTRs_Series.CA1_0',CA1_0_A)
    model.set('cstr.two_CSTRs_Series.CA2_0',CA2_0_A)
    model.set('cstr.two_CSTRs_Series.T1_0',T1_0_A)
    model.set('cstr.two_CSTRs_Series.T2_0',T2_0_A)
    
    # Set the target values to stationary point B
    model.set('u1_ref',u1_0_B)
    model.set('u2_ref',u2_0_B)
    model.set('CA1_ref',CA1_0_B)
    model.set('CA2_ref',CA2_0_B)
    
    # Initialize the optimization mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    res = model.optimize(
        options={'n_e':n_e, 'hs':hs, 'n_cp':n_cp,'blocking_factors':2*N.ones(n_e/2,dtype=N.int),'IPOPT_options':{'tol':1e-4}})
        
    # Extract variable profiles
    CA1_res=res['cstr.two_CSTRs_Series.CA1']
    CA2_res=res['cstr.two_CSTRs_Series.CA2']
    T1_res=res['cstr.two_CSTRs_Series.T1']
    T2_res=res['cstr.two_CSTRs_Series.T2']
    u1_res=res['cstr.two_CSTRs_Series.u1']
    u2_res=res['cstr.two_CSTRs_Series.u2']
    der_u2_res=res['der_u2']
    
    CA1_ref_res=res['CA1_ref']
    CA2_ref_res=res['CA2_ref']
    
    u1_ref_res=res['u1_ref']
    u2_ref_res=res['u2_ref']
    
    cost=res['cost']
    time=res['time']

    assert N.abs(cost[-1] - 1.4745648e+01) < 1e-3, \
           "Wrong value of cost function in cstr2.py"
    
    # Plot the results
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.hold(True)
        plt.subplot(211)
        plt.plot(time,CA1_res)
        plt.plot([time[0],time[-1]],[CA1_ref_res, CA1_ref_res],'--')
        plt.ylabel('Concentration reactor 1 [J/l]')
        plt.grid()
        plt.subplot(212)
        plt.plot(time,CA2_res)
        plt.plot([time[0],time[-1]],[CA2_ref_res, CA2_ref_res],'--')
        plt.ylabel('Concentration reactor 2 [J/l]')
        plt.xlabel('t [s]')
        plt.grid()
        plt.show()
        
        plt.figure(2)
        plt.clf()
        plt.hold(True)
        plt.subplot(211)
        plt.plot(time,T1_res)
        plt.ylabel('Temperature reactor 1 [K]')
        plt.grid()
        plt.subplot(212)
        plt.plot(time,T2_res)
        plt.ylabel('Temperature reactor 2 [K]')
        plt.grid()
        plt.xlabel('t [s]')
        plt.show()
        
        plt.figure(3)
        plt.clf()
        plt.hold(True)
        plt.subplot(211)
        plt.plot(time,u2_res)
        plt.ylabel('Input 2')
        plt.plot([time[0],time[-1]],[u2_ref_res, u2_ref_res],'--')
        plt.grid()
        plt.subplot(212)
        plt.plot(time,der_u2_res)
        plt.ylabel('Derivative of input 2')
        plt.xlabel('t [s]')
        plt.grid()
        plt.show()

if __name__ == "__main__":
    run_demo()
