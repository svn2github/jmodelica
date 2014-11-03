#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB
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

# Import the needed JModelica.org Python methods
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import transfer_optimization_problem, get_files_path
from pyjmi.optimization.mpc import MPC

def run_demo(with_plots=True):
    """
    This example is based on the Hicks-Ray Continuously Stirred Tank Reactors 
    (CSTR) system. The system has two states, the concentration and the 
    temperature. The control input to the system is the temperature of the 
    cooling flow in the reactor jacket. The chemical reaction in the reactor is 
    exothermic, and also temperature dependent; high temperature results in high 
    reaction rate.
    
    The problem is solved using the CasADi-based collocation algorithm. The
    steps performed correspond to those demonstrated in
    example pyjmi.examples.cstr, where the same problem is solved using the
    default JMI algorithm. FMI is used for initialization and simulation
    purposes.
    
    The following steps are demonstrated in this example:
    
    1.  How to solve the initialization problem. The initialization model has
        equations specifying that all derivatives should be identically zero,
        which implies that a stationary solution is obtained. Two stationary
        points, corresponding to different inputs, are computed. We call the
        stationary points A and B respectively. Point A corresponds to
        operating conditions where the reactor is cold and the reaction rate is
        low, whereas point B corresponds to a higher temperature where the
        reaction rate is high.
    
    2.  How to generate an initial guess for a direct collocation method by
        means of simulation with a constant input. The trajectories resulting
        from the simulation are used to initialize the variables in the
        transcribed NLP.
       
    3.  An optimal control problem is solved where the objective is to transfer 
        the state of the system from stationary point A to point B. The
        challenge is to ignite the reactor while avoiding uncontrolled
        temperature increase.

    4.  An MPC-object for the optimization problem is created. After each 
        sample(optimization) the nlp is updated with a prediction of the 
        states in the next sample. To simulate noise each state prediction is 
        multiplied with a random number between 0.99 and 1.01.
    """
    ### 1. Solve the initialization problem
    # Locate the Modelica and Optimica code
    file_path = os.path.join(get_files_path(), "CSTR.mop")
    
    # Compile the stationary initialization model into an FMU
    init_fmu = compile_fmu("CSTR.CSTR_Init", file_path)
    # Load the FMU
    init_model = load_fmu(init_fmu)

    # Set input for Stationary point A
    Tc_0_A = 250
    init_model.set('Tc', Tc_0_A)

    # Solve the initialization problem using FMI
    init_model.initialize()

    # Store stationary point A
    [c_0_A, T_0_A] = init_model.get(['c', 'T'])

    # Print some data for stationary point A
    print(' *** Stationary point A ***')
    print('Tc = %f' % Tc_0_A)
    print('c = %f' % c_0_A)
    print('T = %f' % T_0_A)

    # Set inputs for Stationary point B
    init_model.reset() # reset the FMU so that we can initialize it again
    Tc_0_B = 280
    init_model.set('Tc', Tc_0_B)

    # Solve the initialization problem using FMI
    init_model.initialize()

    # Store stationary point B
    [c_0_B, T_0_B] = init_model.get(['c', 'T'])

    # Print some data for stationary point B
    print(' *** Stationary point B ***')
    print('Tc = %f' % Tc_0_B)
    print('c = %f' % c_0_B)
    print('T = %f' % T_0_B)

    ### 2. Compute initial guess trajectories by means of simulation
    # Compile the optimization initialization model
    init_sim_fmu = compile_fmu("CSTR.CSTR_Init_Optimization", file_path)

    # Load the model
    init_sim_model = load_fmu(init_sim_fmu)

    # Set initial and reference values
    init_sim_model.set('cstr.c_init', c_0_A)
    init_sim_model.set('cstr.T_init', T_0_A)
    init_sim_model.set('c_ref', c_0_B)
    init_sim_model.set('T_ref', T_0_B)
    init_sim_model.set('Tc_ref', Tc_0_B)
    init_sim_model.set('q_Tc', 1)

    init_res = init_sim_model.simulate(start_time=0., final_time=150)

    # Extract variable profiles
    t_init_sim = init_res['time']
    c_init_sim = init_res['cstr.c']
    T_init_sim = init_res['cstr.T']
    Tc_init_sim = init_res['cstr.Tc']

    ### 3. Solve the optimal control problem
    # Compile and load optimization problem
    op = transfer_optimization_problem("CSTR.CSTR_Opt_MPC_casadi", file_path,
             compiler_options={"state_initial_equations":True})

    # Set options collocation
    opt_opts = op.optimize_options()
    opt_opts['n_e'] = 50
    opt_opts['n_cp'] = 2
    opt_opts['init_traj'] = init_res
    opt_opts['nominal_traj'] = init_res
    opt_opts['IPOPT_options']['tol'] = 1e-10

    # Set reference values
    op.set('Tc_ref', Tc_0_B)
    op.set('c_ref', float(c_0_B))
    op.set('T_ref', float(T_0_B))

    # Set initial values
    op.set('_start_cstr.c', float(c_0_A))
    op.set('_start_cstr.T', float(T_0_A))

    # Solve the optimal control problem
    res = op.optimize(options=opt_opts)
    c_res = res['cstr.c']
    T_res = res['cstr.T']
    Tc_res = res['cstr.Tc']
    time_res = res['time']

    ### 4. Solve the optimal control problem through the MPC-class
    #Define some MPC options.
    #Note: n_e must be evelny dividable by number_samp.  
    #(the samplepoints must coincide with meshpoints)
    number_samp = 50
    finalTime = 150.
    sample_period = finalTime/number_samp

    #Create the MPC-object
    #Note: Only initializes the nlp, does not solve it.
    MPC_object = MPC(op, opt_opts, sample_period, number_samp)
    
    #Update the states and optimize number_samp times
    for j in range(0,number_samp):
        
        #Make an optimization
        MPC_object.sample()

        if j < number_samp-1:
            #Update the states
            MPC_object.update_nlp_state()    

    #Extract variable profiles
    complete_result = MPC_object.get_complete_results()
    c_res_comp = complete_result['cstr.c']
    T_res_comp = complete_result['cstr.T']
    Tc_res_comp = complete_result['cstr.Tc']
    time_res_comp = complete_result['time']

     # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        Tc_norm = N.linalg.norm(Tc_res_comp) / N.sqrt(len(Tc_res_comp))
        assert(N.abs(Tc_norm - 305.391279041414) < 1e-3)
        c_norm = N.linalg.norm(c_res_comp) / N.sqrt(len(c_res_comp))
        assert(N.abs(c_norm - 620.133808841317) < 1e-3)
        T_norm = N.linalg.norm(T_res_comp) / N.sqrt(len(T_res_comp))
        assert(N.abs(T_norm - 318.8207410714946) < 1e-3)

    # Plot the results
    if with_plots:
        plt.figure('MPC')
        plt.subplot(3, 1, 1)
        plt.plot(time_res_comp, c_res_comp)
        plt.plot(time_res, c_res, '--')
        plt.legend(('MPC.sample', 'op.optimize'))
        plt.grid()
        plt.ylabel('Concentration')

        plt.subplot(3, 1, 2)
        plt.plot(time_res_comp, T_res_comp)
        plt.plot(time_res, T_res, '--')
        plt.grid()
        plt.ylabel('Temperature')

        plt.subplot(3, 1, 3)
        plt.step(time_res_comp, Tc_res_comp)
        plt.plot(time_res, Tc_res, '--')
        plt.grid()
        plt.ylabel('Cooling temperature')
        plt.xlabel('time')
        plt.show()
    
if __name__=="__main__":
    run_demo()

