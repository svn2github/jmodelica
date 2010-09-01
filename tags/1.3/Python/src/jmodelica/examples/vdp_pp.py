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
import numpy as N
import pylab as p
from jmodelica.compiler import OptimicaCompiler
from jmodelica import simulate

def run_demo(with_plots=True):
    """
    Demonstrate how to do batch simulations
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Define model file name and class name
    model_name = 'VDP_pack.VDP'
    mofile = curr_dir+'/files/VDP.mo'

    # Optimica compiler needed since the .mo file contains
    # Optimica code
    oc = OptimicaCompiler()

    # Compile and load model
    model = oc.compile_model(model_name,mofile,target='ipopt')

    # Define initial conditions
    N_points = 11
    x1_0 = N.linspace(-3.,3.,N_points)
    x2_0 = N.zeros(N_points)

    # Open phase plane plot
    if with_plots:
        fig = p.figure()
        p.clf()
        p.hold(True)
        p.xlabel('x1')
        p.ylabel('x2')

    # Loop over initial conditions    
    for i in range(N_points):
        # Set initial conditions in model
        model.set_value('x1_0',x1_0[i])
        model.set_value('x2_0',x2_0[i])
        # Simulate 
        sim_res = simulate(model,alg_args={'final_time':20})
        # Get simulation result
        res = sim_res.result_data
        x1=res.get_variable_data('x1')
        x2=res.get_variable_data('x2')
        # Plot simulation result in phase plane plot
        if with_plots:
            p.plot(x1.x, x2.x,'b')

    if with_plots:
        p.grid()
        p.show()
    
        

if __name__=="__main__":
    run_demo()
