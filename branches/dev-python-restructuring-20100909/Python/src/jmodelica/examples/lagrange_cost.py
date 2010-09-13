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
from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

def run_demo(with_plots=True):
    """This example demonstrates how to solve optimization problems
       with a Lagrange cost term encoded using the Optimica attribute
       objectiveIntegrand."""

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    n_e = 50 # Number of elements
    hs = N.ones(n_e)*1./n_e # Equidistant point
    n_cp = 3 # Number of collocation points
    b_f = 3*N.ones(10) # Blocking factors

    jmu_name = compile_jmu("LagrangeCost.OptTest", 
        curr_dir+"/files/LagrangeCost.mop")
    model = JMUModel(jmu_name)
    res = model.optimize(
        alg_args={'n_e':n_e,'hs':hs,'n_cp':n_cp,'blocking_factors':b_f})

    x1 = res.result_data.get_variable_data('sys.x[1]')
    x2 = res.result_data.get_variable_data('sys.x[2]')
    u = res.result_data.get_variable_data('sys.u')

    assert N.abs(x1.x[-1] - 0.20172085497700001) < 1e-3, \
            "Wrong value of final state x[1] in lagrange_cost.py"  

    if with_plots:
        
        plt.figure(1)
        plt.clf()
        plt.subplot(211)
        plt.plot(x1.t,x1.x)
        plt.hold(True)
        plt.ylabel('x[1], x[2]')
        plt.plot(x2.t,x2.x)
        plt.grid(True)
        plt.subplot(212)
        plt.plot(u.t,u.x)
        plt.ylabel('u')
        plt.xlabel('t[s]')
        plt.grid(True)
        plt.show()

if __name__ == "__main__":
    run_demo()
