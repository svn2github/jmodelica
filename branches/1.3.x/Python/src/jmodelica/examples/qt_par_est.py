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
from jmodelica import initialize
from jmodelica import simulate
from jmodelica import optimize
from jmodelica.compiler import OptimicaCompiler

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

    # Simulate model response with nominal parameters
    res_sim = simulate('QuadTankPack.Sim_QuadTank',
                       curr_dir+'/files/QuadTankPack.mo',
                       compiler='opimica',
                       alg_args={"input_trajectory":u,'start_time':0.,'final_time':60})

    # Load simulation result
    x1_sim = res_sim.result_data.get_variable_data('qt.x1')
    x2_sim = res_sim.result_data.get_variable_data('qt.x2')
    x3_sim = res_sim.result_data.get_variable_data('qt.x3')
    x4_sim = res_sim.result_data.get_variable_data('qt.x4')
    
    u1_sim = res_sim.result_data.get_variable_data('u1')
    u2_sim = res_sim.result_data.get_variable_data('u2')

    # Plot simulation result
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(x1_sim.t,x3_sim.x)
        plt.subplot(2,2,2)
        plt.plot(x2_sim.t,x4_sim.x)
        plt.subplot(2,2,3)
        plt.plot(x3_sim.t,x1_sim.x)
        plt.subplot(2,2,4)
        plt.plot(x4_sim.t,x2_sim.x)
        plt.show()

        plt.figure(2)
        plt.subplot(2,1,1)
        plt.plot(u1_sim.t,u1_sim.x,'r')
        plt.subplot(2,1,2)
        plt.plot(u2_sim.t,u2_sim.x,'r')
        plt.show()

    # Create Optimica compiler
    oc = OptimicaCompiler()

    # Compile model
    qt_par_est = oc.compile_model("QuadTankPack.QuadTank_ParEst",
                                  curr_dir+"/files/QuadTankPack.mo",target='ipopt')

    # Number of measurement points
    N_meas = N.size(u1,0)

    # Set measurement data into model
    for i in range(0,N_meas):
        qt_par_est.set_value("t_meas["+`i+1`+"]",t_meas[i])
        qt_par_est.set_value("y1_meas["+`i+1`+"]",y1_meas[i])
        qt_par_est.set_value("y2_meas["+`i+1`+"]",y2_meas[i])

    # Numer of element in collocation algorithm
    n_e = 100
    # Normalized element lengths
    hs = N.ones(n_e)/n_e
    # Number of collocation points
    n_cp = 3

    # Solve parameter optimization problem
    res_opt = optimize(qt_par_est,alg_args={"n_e":n_e,"n_cp":3, \
                                            "result_mesh":"element_interpolation",
                                            "hs":hs})

    # Extract optimal values of parameters
    a1_opt = res_opt.result_data.get_variable_data("qt.a1")
    a2_opt = res_opt.result_data.get_variable_data("qt.a2")

    # Print optimal parameter values
    print('a1: ' + str(a1_opt.x[-1]*1e4) + 'cm^2')
    print('a2: ' + str(a2_opt.x[-1]*1e4) + 'cm^2')

    assert N.abs(a1_opt.x[-1]*1.e6 - 2.658636) < 1e-3, \
           "Wrong value of parameter a1"  
    assert N.abs(a2_opt.x[-1]*1.e6 - 2.715543) < 1e-3, \
           "Wrong value of parameter a2"  

    # Load state profiles
    x1_opt = res_opt.result_data.get_variable_data("qt.x1")
    x2_opt = res_opt.result_data.get_variable_data("qt.x2")
    x3_opt = res_opt.result_data.get_variable_data("qt.x3")
    x4_opt = res_opt.result_data.get_variable_data("qt.x4")
    u1_opt = res_opt.result_data.get_variable_data("qt.u1")
    u2_opt = res_opt.result_data.get_variable_data("qt.u2")

    # Plot
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(x3_opt.t,x3_opt.x,'k')
        plt.subplot(2,2,2)
        plt.plot(x4_opt.t,x4_opt.x,'k')
        plt.subplot(2,2,3)
        plt.plot(x1_opt.t,x1_opt.x,'k')
        plt.subplot(2,2,4)
        plt.plot(x2_opt.t,x2_opt.x,'k')
        plt.show()

    # Compile second parameter estimation model
    qt_par_est2 = oc.compile_model("QuadTankPack.QuadTank_ParEst2",
                                   curr_dir+"/files/QuadTankPack.mo",target='ipopt')
    # Number of measurement points
    N_meas = N.size(u1,0)

    # Set measurement data into model
    for i in range(0,N_meas):
        qt_par_est2.set_value("t_meas["+`i+1`+"]",t_meas[i])
        qt_par_est2.set_value("y1_meas["+`i+1`+"]",y1_meas[i])
        qt_par_est2.set_value("y2_meas["+`i+1`+"]",y2_meas[i])
        qt_par_est2.set_value("y3_meas["+`i+1`+"]",y3_meas[i])
        qt_par_est2.set_value("y4_meas["+`i+1`+"]",y4_meas[i])

    # Solve parameter estimation problem
    res_opt2 = optimize(qt_par_est2,alg_args={"n_e":n_e,"n_cp":3, \
                                              "result_mesh":"element_interpolation","hs":hs})

    # Get optimal parameter values
    a1_opt2 = res_opt2.result_data.get_variable_data("qt.a1")
    a2_opt2 = res_opt2.result_data.get_variable_data("qt.a2")
    a3_opt2 = res_opt2.result_data.get_variable_data("qt.a3")
    a4_opt2 = res_opt2.result_data.get_variable_data("qt.a4")

    # Print optimal parameter values 
    print('a1:' + str(a1_opt2.x[-1]*1e4) + 'cm^2')
    print('a2:' + str(a2_opt2.x[-1]*1e4) + 'cm^2')
    print('a3:' + str(a3_opt2.x[-1]*1e4) + 'cm^2')
    print('a4:' + str(a4_opt2.x[-1]*1e4) + 'cm^2')

    assert N.abs(a1_opt2.x[-1]*1.e6 - 2.659686) < 1e-3, \
           "Wrong value of parameter a1"  
    assert N.abs(a2_opt2.x[-1]*1.e6 - 2.706181) < 1e-3, \
           "Wrong value of parameter a2"  
    assert N.abs(a3_opt2.x[-1]*1.e6 - 3.007429) < 1e-3, \
           "Wrong value of parameter a3"  
    assert N.abs(a4_opt2.x[-1]*1.e6 - 2.933729) < 1e-3, \
           "Wrong value of parameter a4"  

    # Extract state and input profiles
    x1_opt2 = res_opt2.result_data.get_variable_data("qt.x1")
    x2_opt2 = res_opt2.result_data.get_variable_data("qt.x2")
    x3_opt2 = res_opt2.result_data.get_variable_data("qt.x3")
    x4_opt2 = res_opt2.result_data.get_variable_data("qt.x4")
    u1_opt2 = res_opt2.result_data.get_variable_data("qt.u1")
    u2_opt2 = res_opt2.result_data.get_variable_data("qt.u2")

    # Plot
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(x3_opt2.t,x3_opt2.x,'r')
        plt.subplot(2,2,2)
        plt.plot(x4_opt2.t,x4_opt2.x,'r')
        plt.subplot(2,2,3)
        plt.plot(x1_opt2.t,x1_opt2.x,'r')
        plt.subplot(2,2,4)
        plt.plot(x2_opt2.t,x2_opt2.x,'r')
        plt.show()
