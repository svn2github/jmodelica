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
    Demonstrate how to solve a continous state constraint optimization problem.
    reference : PROPT - Matlab Optimal Control Software (DAE, ODE)
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name = compile_jmu("JMExamples_opt.ContState_opt", 
        (os.path.join(curr_dir, 'files', 'JMExamples_opt.mop'), os.path.join(curr_dir, 'files', 'JMExamples.mo')),
        compiler_options={'propagate_derivatives':False})
    cs = JMUModel(jmu_name)
    
    res = cs.optimize()

    # Extract variable profiles
    x1 = res['x1']
    x2 = res['x2']
    u = res['u']
    t = res['time']
    p = res['p']
    J = res['J']  

    assert N.abs(res.final('x1') + 0.22364) < 1e-4
    assert N.abs(res.final('x2') - 0.00813) < 1e-4
    assert N.abs(res.final('p') - 1.49187)  < 1e-4
    assert N.abs(res.final('J') - 0.16982)  < 1e-4
   
    if with_plots:
        plt.figure(1)
        plt.clf()
        
        plt.subplot(221)
        plt.plot(t,x1,t,x2)
        plt.grid()
        plt.ylabel('x')
        plt.xlabel('time')
        
        plt.subplot(222)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        
        plt.subplot(223)
        plt.plot(t,J)
        plt.grid()
        plt.ylabel('J')
        plt.xlabel('time')
        
        plt.subplot(224)
        plt.plot(t,p)
        plt.grid()
        plt.ylabel('path')
        plt.xlabel('time')
        
        plt.show()

if __name__ == "__main__":
    run_demo()
