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
import ctypes as ct
import matplotlib.pyplot as plt
from scipy import *

# Import the JModelica.org Python packages
from pymodelica import compile_jmu
from pyjmi import JMUModel
from pyjmi.optimization import ipopt

def run_demo(with_plots=True):
    """
    Demonstrate how to solve a simple parameter estimation problem 
    in form of a model of catalytic cracking of gas oil.
    
    Reference:
    Benchmarking Optimization Software with COPS 
    Elizabeth D. Dolan and Jorge J. More ARGONNE NATIONAL LABORATORY
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile the Optimica model to a JMU
    jmu_name = compile_jmu("JMExamples_opt.CatalyticCracking_opt",
        (os.path.join(curr_dir, 'files', 'JMExamples_opt.mop'), os.path.join(curr_dir, 'files', 'JMExamples.mo')))
    
    # Load the dynamic library
    cc = JMUModel(jmu_name)
    
    # optimize
    opts = cc.optimize_options()
    opts['n_e'] = 20
    res = cc.optimize(options=opts)
    
    # Extract variable profiles
    y1     = res['sys.y1']
    y2     = res['sys.y2']
    theta1 = res['sys.theta1']
    theta2 = res['sys.theta2']
    theta3 = res['sys.theta3']
    t      = res['time']
    
    y1m = [1, 0.8105, 0.6208, 0.5258, 0.4345, 0.3903,
    0.3342, 0.3034, 0.2735, 0.2405, 0.2283, 0.2071, 0.1669,
    0.1530, 0.1339, 0.1265, 0.1200, 0.0990, 0.0870, 0.077, 0.069];
    y2m = [0, 0.2, 0.2886, 0.301, 0.3215, 0.3123, 0.2716,
    0.2551, 0.2258, 0.1959, 0.1789, 0.1457, 0.1198, 0.0909,
    0.0719, 0.0561, 0.0460, 0.0280, 0.0190, 0.0140, 0.01];
    tm = [0, 0.025, 0.05, 0.075, 0.1, 0.125, 
    0.15, 0.175, 0.2, 0.225, 0.25, 0.3, 0.35, 0.4,
    0.45, 0.5, 0.55, 0.65, 0.75, 0.85, 0.95];

    assert N.abs(res.final('sys.theta1') - 11.835148) < 1e-5
    assert N.abs(res.final('sys.theta2') - 8.338887)  < 1e-5
    assert N.abs(res.final('sys.theta3') - 1.007536)  < 1e-5

    if with_plots:
        plt.figure(1)
        plt.clf()
        
        plt.subplot(211)
        plt.plot(t, y1, tm, y1m, 'x')
        plt.grid()
        plt.ylabel('y1')
        plt.xlabel('time')
        
        plt.subplot(212)
        plt.plot(t, y2, tm, y2m, 'x')
        plt.grid()
        plt.ylabel('y2')
        plt.xlabel('time')
        
        plt.show()
        
        print("\n** Optimal parameter values: **")
        print("theta1 = %f" %res.final('sys.theta1'))
        print("theta2 = %f" %res.final('sys.theta2'))
        print("theta3 = %f" %res.final('sys.theta3'))

if __name__ == "__main__":
    run_demo()
