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
    In this problem, the objective is to maximize the concentration of penicillin, P, 
    produced in a fed-batch bioreactor, given a finite amount of time. 
    Initial guesse should be determed by initialization and simulation and after the problem is optimized
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));
        
    # Compile the stationary initialization model into a JMU
    jmu_name1 = compile_jmu("JMExamples_opt.PenicillinPlant_Init", 
    (curr_dir+"/files/JMExamples_opt.mop", curr_dir+"/files/JMExamples.mo"),
    compiler_options={"enable_variable_scaling":True})
    
	# load the JMU
    init_pp1 = JMUModel(jmu_name1)
	
    # Set inputs for Stationary point A
    du1_0_A = 5e-4
    init_pp1.set('du1',du1_0_A)
        
    # Solve the DAE initialization system with Ipopt
    init_res1 = init_pp1.initialize()
	
	# Extract variable profiles
    X1_0_A = init_res1['X1'] [0]
    S1_0_A = init_res1['S1'] [0]
    P1_0_A = init_res1['P1'] [0]
    V1_0_A = init_res1['V1'] [0]
    u1_0_A = init_res1['u1'] [0]
    
	# Print some data for stationary point A
    print(' *** Stationary point A ***')
    print('X1 = %f' % X1_0_A)
    print('S1 = %f' % S1_0_A)
    print('P1 = %f' % P1_0_A)
    print('V1 = %f' % V1_0_A)
    print('u1 = %f' % u1_0_A)
	
	# Set inputs for Stationary point B
    du1_0_B = 0
    init_pp1.set('du1',du1_0_B)
        
    # Solve the DAE initialization system with Ipopt
    init_res1 = init_pp1.initialize()
	
	# Extract variable profiles
    X1_0_B = init_res1['X1'] [0]
    S1_0_B = init_res1['S1'] [0]
    P1_0_B = init_res1['P1'] [0]
    V1_0_B = init_res1['V1'] [0]
    u1_0_B = init_res1['u1'] [0]
    
	# Print some data for stationary point A
    print(' *** Stationary point A ***')
    print('X1 = %f' % X1_0_B)
    print('S1 = %f' % S1_0_B)
    print('P1 = %f' % P1_0_B)
    print('V1 = %f' % V1_0_B)
    print('u1 = %f' % u1_0_B)
	
    #compile the optimization initialization model
    jmu_name = compile_jmu("JMExamples_opt.PenicillinPlant_Init_opt", 
    (curr_dir+"/files/JMExamples_opt.mop", curr_dir+"/files/JMExamples.mo"))
	
	#Load the model
    sim_model = JMUModel(jmu_name)
	
	#Set model parameters
    sim_model.set('pp.X1_0',X1_0_A)
    sim_model.set('pp.S1_0',S1_0_A)
    sim_model.set('pp.P1_0',P1_0_A)
    sim_model.set('pp.V1_0',V1_0_A)
    sim_model.set('pp.u1_0',u1_0_A)
    sim_model.set('X1_ref',X1_0_B)
    sim_model.set('S1_ref',S1_0_B)
    sim_model.set('P1_ref',P1_0_B)
    sim_model.set('V1_ref',V1_0_B)
    sim_model.set('u1_ref',u1_0_B)
    sim_model.set('du1_ref',du1_0_B)
	
    res = sim_model.simulate(start_time=0.,final_time=150.)
	
    X1_sim = res['pp.X1']
    S1_sim = res['pp.S1']
    P1_sim = res['pp.P1']
    V1_sim = res['pp.V1']
    u1_sim = res['pp.u1']
    du1_sim = res['pp.du1']
    t_sim = res['time']
    
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(321)
        plt.plot(t_sim,X1_sim)
        plt.title('Cell mass concentration')
        plt.grid()
        plt.ylabel('X1')

        plt.subplot(322)
        plt.plot(t_sim,S1_sim)
        plt.title('Substrate concentration')
        plt.grid()
        plt.ylabel('S1')
		
        plt.subplot(323)
        plt.plot(t_sim,P1_sim)
        plt.title('Penicillin concentration')
        plt.grid()
        plt.ylabel('P1')
        
        plt.subplot(324)
        plt.plot(t_sim,V1_sim)
        plt.title('Volume of medium')
        plt.grid()
        plt.ylabel('V1')
		
        plt.subplot(325)
        plt.plot(t_sim,u1_sim)
        plt.title('Feed flowrate')
        plt.grid()
        plt.ylabel('u1')
		
        plt.subplot(326)
        plt.plot(t_sim,du1_sim)
        plt.title('Derivative of Feed flowrate')
        plt.grid()
        plt.ylabel('du1')
		
        plt.xlabel('time')
        plt.show()

    # Compile model
    jmu_name = compile_jmu("JMExamples_opt.PenicillinPlant_opt", 
    (curr_dir+"/files/JMExamples_opt.mop", curr_dir+"/files/JMExamples.mo"))
	# Load model
    pp = JMUModel(jmu_name)
	
    pp.set('pp.X1_0',X1_0_A)
    pp.set('pp.S1_0',S1_0_A)
    pp.set('pp.P1_0',P1_0_A)
    pp.set('pp.V1_0',V1_0_A)
    pp.set('pp.u1_0',u1_0_A)
    pp.set('X1_ref',X1_0_B)
    pp.set('S1_ref',S1_0_B)
    pp.set('P1_ref',P1_0_B)
    pp.set('V1_ref',V1_0_B)
    pp.set('u1_ref',u1_0_B)
    pp.set('du1_ref',du1_0_B)
	
    n_e = 100
    opt_opts = pp.optimize_options()
    opt_opts['n_e'] = n_e
    res1 = pp.optimize()
	
    X1=res1['pp.X1']
    S1=res1['pp.S1']
    P1=res1['pp.P1']
    V1=res1['pp.V1']
    u1=res1['pp.u1'] 
    du1=res1['pp.du1']
    t=res1['time']
	
    print "X1(final) = ", repr(X1[1])
    print "X1 = ", repr(N.array(X1))
    print "S1 = ", repr(N.array(S1))
    print "P1 = ", repr(N.array(P1))
    print "V1 = ", repr(N.array(V1))
    print "u1 = ", repr(N.array(u1))
    print "du1 = ", repr(N.array(du1))
    print "len(u1) = ", repr(len(u1))
    print "len(t) = ", repr(len(t))
	
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(321)
        plt.plot(t,X1)
        plt.title('Cell mass concentration')
        plt.grid()
        plt.ylabel('X1')

        plt.subplot(322)
        plt.plot(t,S1)
        plt.title('Substrate concentration')
        plt.grid()
        plt.ylabel('S1')
		
        plt.subplot(323)
        plt.plot(t,P1)
        plt.title('Penicillin concentration')
        plt.grid()
        plt.ylabel('P1')
        
        plt.subplot(324)
        plt.plot(t,V1)
        plt.title('Volume of medium')
        plt.grid()
        plt.ylabel('V1')
		
        plt.subplot(325)
        plt.plot(t,u1)
        plt.title('Feed flowrate')
        plt.grid()
        plt.ylabel('u1')
		
        plt.subplot(326)
        plt.plot(t,du1)
        plt.title('Derivative of Feed flowrate')
        plt.grid()
        plt.ylabel('du1')
		
        plt.xlabel('time')
        plt.show()
	
	
if __name__ == "__main__":
    run_demo()
