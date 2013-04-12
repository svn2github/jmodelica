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
    The model describes a minimum time control problem with coloumb friction.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name1 = compile_jmu("JMExamples_opt.ColoumbFriction_opt", 
        (os.path.join(curr_dir, 'files', 'JMExamples_opt.mop'), os.path.join(curr_dir, 'files', 'JMExamples.mo')))
    cf = JMUModel(jmu_name1)
    res = cf.optimize()
    
    # Extract variable profiles
    q =res['q']
    dq=res['dq']
    u =res['u'] 
    t =res['time']

    assert N.abs(res.final('q') + 1.0) < 1e-4
    assert N.abs(res.final('dq') - 0.0) < 1e-4

    if with_plots:
        plt.figure(1)
        plt.clf()
        
        plt.subplot(311)
        plt.plot(t,q)
        plt.grid()
        plt.ylabel('q')
        plt.xlabel('time')

        plt.subplot(312)
        plt.plot(t,dq)
        plt.grid()
        plt.ylabel('dq')
        plt.xlabel('time')

        plt.subplot(313)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        
        plt.show()

if __name__ == "__main__":
    run_demo()
