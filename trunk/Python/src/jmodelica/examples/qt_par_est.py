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

import os;
from scipy.io.matlab.mio import loadmat
import matplotlib.pyplot as plt
import numpy as N

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

def run_demo(with_plots=True):
    """
    This example demonstrates how to solve parameter estimation
    problmes.

    The data used in the example was recorded by Kristian Soltesz
    at the Department of Automatic Control. 
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Load measurement data from file
    data = loadmat(curr_dir+'/files/qt_par_est_data.mat',appendmat=False)

    # Extract data series
    t_meas = data['t'][6000::100,0]-60
    y1_meas = data['y1_f'][6000::100,0]/100
    y2_meas = data['y2_f'][6000::100,0]/100
    y3_meas = data['y3_d'][6000::100,0]/100
    y4_meas = data['y4_d'][6000::100,0]/100
    u1 = data['u1_d'][6000::100,0]
    u2 = data['u2_d'][6000::100,0]
        
    # Plot measurements and inputs
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(2,2,1)
        plt.plot(t_meas,y3_meas)
        plt.title('x3')
        plt.grid()
        plt.subplot(2,2,2)
        plt.plot(t_meas,y4_meas)
        plt.title('x4')
        plt.grid()
        plt.subplot(2,2,3)
        plt.plot(t_meas,y1_meas)
        plt.title('x1')
        plt.xlabel('t[s]')
        plt.grid()
        plt.subplot(2,2,4)
        plt.plot(t_meas,y2_meas)
        plt.title('x2')
        plt.xlabel('t[s]')
        plt.grid()
        plt.show()

        plt.figure(2)
        plt.clf()
        plt.subplot(2,1,1)
        plt.plot(t_meas,u1)
        plt.hold(True)
        plt.title('u1')
        plt.grid()
        plt.subplot(2,1,2)
        plt.plot(t_meas,u2)
        plt.title('u2')
        plt.xlabel('t[s]')
        plt.hold(True)
        plt.grid()
        plt.show()

    # Build input trajectory matrix for use in simulation
    u = N.transpose(N.vstack((t_meas,u1,u2)))

    # compile JMU
    jmu_name = compile_jmu('QuadTankPack.Sim_QuadTank', 
        curr_dir+'/files/QuadTankPack.mop')
    model = JMUModel(jmu_name)
    
    # Simulate model response with nominal parameters
    res = model.simulate(input_trajectory=u,start_time=0.,final_time=60)

    # Load simulation result
    x1_sim = res['qt.x1']
    x2_sim = res['qt.x2']
    x3_sim = res['qt.x3']
    x4_sim = res['qt.x4']
    t_sim  = res['time']
    
    u1_sim = res['u1']
    u2_sim = res['u2']

    # Plot simulation result
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t_sim,x3_sim)
        plt.subplot(2,2,2)
        plt.plot(t_sim,x4_sim)
        plt.subplot(2,2,3)
        plt.plot(t_sim,x1_sim)
        plt.subplot(2,2,4)
        plt.plot(t_sim,x2_sim)
        plt.show()

        plt.figure(2)
        plt.subplot(2,1,1)
        plt.plot(t_sim,u1_sim,'r')
        plt.subplot(2,1,2)
        plt.plot(t_sim,u2_sim,'r')
        plt.show()

    # Compile model
    jmu_name = compile_jmu("QuadTankPack.QuadTank_ParEst",
        curr_dir+"/files/QuadTankPack.mop")
    qt_par_est = JMUModel(jmu_name)

    # Number of measurement points
    N_meas = N.size(u1,0)

    # Set measurement data into model
    for i in range(0,N_meas):
        qt_par_est.set("t_meas["+`i+1`+"]",t_meas[i])
        qt_par_est.set("y1_meas["+`i+1`+"]",y1_meas[i])
        qt_par_est.set("y2_meas["+`i+1`+"]",y2_meas[i])

    # Numer of element in collocation algorithm
    n_e = 100
    # Normalized element lengths
    hs = N.ones(n_e)/n_e
    # Number of collocation points
    n_cp = 3

    # Solve parameter optimization problem
    res = qt_par_est.optimize(
        options={"n_e":n_e,"n_cp":3, "result_mesh":"element_interpolation","hs":hs})

    # Extract optimal values of parameters
    a1_opt = res["qt.a1"]
    a2_opt = res["qt.a2"]

    # Print optimal parameter values
    print('a1: ' + str(a1_opt*1e4) + 'cm^2')
    print('a2: ' + str(a2_opt*1e4) + 'cm^2')

    assert N.abs(a1_opt*1.e6 - 2.658636) < 1e-3, \
           "Wrong value of parameter a1"  
    assert N.abs(a2_opt*1.e6 - 2.715543) < 1e-3, \
           "Wrong value of parameter a2"  

    # Load state profiles
    x1_opt = res["qt.x1"]
    x2_opt = res["qt.x2"]
    x3_opt = res["qt.x3"]
    x4_opt = res["qt.x4"]
    u1_opt = res["qt.u1"]
    u2_opt = res["qt.u2"]
    t_opt  = res["time"]

    # Plot
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t_opt,x3_opt,'k')
        plt.subplot(2,2,2)
        plt.plot(t_opt,x4_opt,'k')
        plt.subplot(2,2,3)
        plt.plot(t_opt,x1_opt,'k')
        plt.subplot(2,2,4)
        plt.plot(t_opt,x2_opt,'k')
        plt.show()

    # Compile second parameter estimation model
    jmu_name = compile_jmu("QuadTankPack.QuadTank_ParEst2", 
        curr_dir+"/files/QuadTankPack.mop")
    qt_par_est2 = JMUModel(jmu_name)
    
    # Number of measurement points
    N_meas = N.size(u1,0)

    # Set measurement data into model
    for i in range(0,N_meas):
        qt_par_est2.set("t_meas["+`i+1`+"]",t_meas[i])
        qt_par_est2.set("y1_meas["+`i+1`+"]",y1_meas[i])
        qt_par_est2.set("y2_meas["+`i+1`+"]",y2_meas[i])
        qt_par_est2.set("y3_meas["+`i+1`+"]",y3_meas[i])
        qt_par_est2.set("y4_meas["+`i+1`+"]",y4_meas[i])

    # Solve parameter estimation problem
    res_opt2 = qt_par_est2.optimize(
        options={"n_e":n_e,"n_cp":3, "result_mesh":"element_interpolation","hs":hs})

    # Get optimal parameter values
    a1_opt2 = res_opt2["qt.a1"]
    a2_opt2 = res_opt2["qt.a2"]
    a3_opt2 = res_opt2["qt.a3"]
    a4_opt2 = res_opt2["qt.a4"]

    # Print optimal parameter values 
    print('a1:' + str(a1_opt2*1e4) + 'cm^2')
    print('a2:' + str(a2_opt2*1e4) + 'cm^2')
    print('a3:' + str(a3_opt2*1e4) + 'cm^2')
    print('a4:' + str(a4_opt2*1e4) + 'cm^2')

    assert N.abs(a1_opt2*1.e6 - 2.659686) < 1e-3, \
           "Wrong value of parameter a1"  
    assert N.abs(a2_opt2*1.e6 - 2.706181) < 1e-3, \
           "Wrong value of parameter a2"  
    assert N.abs(a3_opt2*1.e6 - 3.007429) < 1e-3, \
           "Wrong value of parameter a3"  
    assert N.abs(a4_opt2*1.e6 - 2.933729) < 1e-3, \
           "Wrong value of parameter a4"  

    # Extract state and input profiles
    x1_opt2 = res_opt2["qt.x1"]
    x2_opt2 = res_opt2["qt.x2"]
    x3_opt2 = res_opt2["qt.x3"]
    x4_opt2 = res_opt2["qt.x4"]
    u1_opt2 = res_opt2["qt.u1"]
    u2_opt2 = res_opt2["qt.u2"]
    t_opt2  = res_opt2["time"]

    # Plot
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t_opt2,x3_opt2,'r')
        plt.subplot(2,2,2)
        plt.plot(t_opt2,x4_opt2,'r')
        plt.subplot(2,2,3)
        plt.plot(t_opt2,x1_opt2,'r')
        plt.subplot(2,2,4)
        plt.plot(t_opt2,x2_opt2,'r')
        plt.show()
