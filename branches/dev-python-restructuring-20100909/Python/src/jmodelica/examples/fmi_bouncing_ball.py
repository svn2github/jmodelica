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


import pylab as P
import numpy as N
import os as O
from jmodelica.fmi import FMUModel

curr_dir = O.path.dirname(O.path.abspath(__file__));
path_to_fmus = O.path.join(curr_dir, 'files', 'FMUs')

def run_demo(with_plots=True):
    """
    Demonstrates how to use JModelica.org for simulation of FMUs.
    """


    fmu_name = O.path.join(path_to_fmus,'bouncingBall.fmu')
    model = FMUModel(fmu_name)
    model.initialize()
    res_obj = model.simulate(alg_args={'final_time':2.})
    
    #Retrieve the result data
    res = res_obj.result_data
    
    #Retrieve the result for the variables
    h_res = res.get_variable_data('h')
    v_res = res.get_variable_data('v')

    assert N.abs(h_res.x[-1] - (0.0424044)) < 1e-4, \
            "Wrong value of h_res in fmi_bouncing_ball.py"
    
    #Plot the solution
    if with_plots:
        #Plot the height
        fig = P.figure()
        P.clf()
        P.subplot(2,1,1)
        P.plot(h_res.t, h_res.x)
        P.ylabel('Height (m)')
        P.xlabel('Time (s)')
        #Plot the velocity
        P.subplot(2,1,2)
        P.plot(v_res.t, v_res.x)
        P.ylabel('Velocity (m/s)')
        P.xlabel('Time (s)')
        P.suptitle('FMI Bouncing Ball')
        P.show()

    
if __name__ == "__main__":
    run_demo()
