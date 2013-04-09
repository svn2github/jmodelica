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

import os

from scipy.io.matlab.mio import loadmat
import matplotlib.pyplot as plt
import numpy as N

from pymodelica import compile_fmu
from pymodelica import compile_fmux
from pyfmi import load_fmu
from pyjmi import CasadiModel
from pyjmi.common.core import TrajectoryLinearInterpolation
from pyjmi.optimization.casadi_collocation import ParameterEstimationData

def run_demo(with_plots=True):
    """
    This example demonstrates how to solve parameter estimation problmes.

    The data used in the example was recorded by Kristian Soltesz at the 
    Department of Automatic Control. 
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

    # Build input trajectory matrix for use in simulation
    u = N.transpose(N.vstack((t_meas,u1,u2)))

    # compile FMU
    fmu_name = compile_fmu('QuadTankPack.Sim_QuadTank', 
        curr_dir+'/files/QuadTankPack.mop')

    # Load model
    model = load_fmu(fmu_name)
    
    # Simulate model response with nominal parameters
    res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60)

    # Load simulation result
    x1_sim = res['qt.x1']
    x2_sim = res['qt.x2']
    x3_sim = res['qt.x3']
    x4_sim = res['qt.x4']
    t_sim  = res['time']
    
    u1_sim = res['u1']
    u2_sim = res['u2']
    
    assert N.abs(res.final('qt.x1') - 0.05642485) < 1e-3
    assert N.abs(res.final('qt.x2') - 0.05510478) < 1e-3
    assert N.abs(res.final('qt.x3') - 0.02736532) < 1e-3
    assert N.abs(res.final('qt.x4') - 0.02789808) < 1e-3
    assert N.abs(res.final('u1') - 6.0)           < 1e-3
    assert N.abs(res.final('u2') - 5.0)           < 1e-3

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

        plt.figure(2)
        plt.subplot(2,1,1)
        plt.plot(t_sim,u1_sim,'r')
        plt.subplot(2,1,2)
        plt.plot(t_sim,u2_sim,'r')

    # Compile the Optimica model to an XML file
    model_name = compile_fmux("QuadTankPack.QuadTank_ParEstCasADi",
        curr_dir+"/files/QuadTankPack.mop")
    
    # Load the model
    model_casadi=CasadiModel(model_name)

    """
    The collocation algorithm minimizes, if the parameter_estimation_data
    option is set, a quadrature approximation of the integral

    \int_{t_0}^{t_f} (y(t_i)-y_i^{meas})^T Q (y(t_i)-y_i^{meas}) dt

    The measurement data is given as a matrix where the first
    column is time and the following column contains data corresponding
    to the variable names given in the measured_variables list.

    Notice that input trajectories used in identification experiments
    are handled using the errors in variables method, i.e., deviations
    from the measured inputs are penalized in the cost function, rather
    than forcing the inputs to follow the measurement profile exactly.
    The weighting matrix Q may be used to express that inputs are typically
    more reliable than than measured outputs.
    """

    Q = N.array([[1.,0,0,0],[0,1,0,0],[0,0,10,0],[0,0,0,10]])
    measured_variables=['qt.x1','qt.x2','qt.u1','qt.u2']
    data = N.transpose(N.vstack((t_meas,y1_meas,y2_meas,u1,u2)))

    par_est_data = ParameterEstimationData(Q,measured_variables,data)

    opts = model_casadi.optimize_options()

    opts['n_e'] = 60

    opts['parameter_estimation_data'] = par_est_data
    #opts['IPOPT_options']['derivative_test'] = 'second-order'
    #opts['IPOPT_options']['max_iter'] = 0

    res = model_casadi.optimize(algorithm="LocalDAECollocationAlg",
                                options=opts)

    # Load state profiles
    x1_opt = res["qt.x1"]
    x2_opt = res["qt.x2"]
    x3_opt = res["qt.x3"]
    x4_opt = res["qt.x4"]
    u1_opt = res["qt.u1"]
    u2_opt = res["qt.u2"]
    t_opt  = res["time"]

    # Extract optimal values of parameters
    a1_opt = res["qt.a1"]
    a2_opt = res["qt.a2"]

    # Print optimal parameter values
    print('a1: ' + str(a1_opt*1e4) + 'cm^2')
    print('a2: ' + str(a2_opt*1e4) + 'cm^2')
    
    assert N.abs(res.final('qt.x1') - 0.0707102)  < 1e-3
    assert N.abs(res.final('qt.x2') - 0.06655758) < 1e-3
    assert N.abs(res.final('qt.x3') - 0.02736501) < 1e-3
    assert N.abs(res.final('qt.x4') - 0.02789977) < 1e-3
    assert N.abs(res.final('u1') - 6.0)           < 1e-3
    assert N.abs(res.final('u2') - 5.0)           < 1e-3

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

        plt.figure(2)
        plt.subplot(2,1,1)
        plt.plot(t_opt,u1_opt,'k')
        plt.subplot(2,1,2)
        plt.plot(t_opt,u2_opt,'k')
        plt.show()

if __name__=="__main__":
    run_demo()
