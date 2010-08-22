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

from jmodelica import simulate

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using a DAE simulator with 
    Assimulo. The model used is made by Maja Djačić.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    m_name = 'SolAngles'
    mofile = curr_dir+'/files/SolAngles.mo'
    
    sim_res = simulate(m_name, mofile,
                       alg_args={'final_time':86400.0, 'num_communication_points':86400},
                       solver_args={'make_consistency':'IDA_YA_YDP_INIT'})
    
    res = sim_res.result_data
    theta = res.get_variable_data('theta')
    azim = res.get_variable_data('azim')
    N_day = res.get_variable_data('N_day')

    
    # Plot results
    if with_plots:
        p.figure(1)
        p.plot(theta.t, theta.x)
        p.xlabel('time [s]')
        p.ylabel('theta [deg]')
        p.title('Angle of Incidence on Surface')
        p.grid()
        p.show()

if __name__=="__main__":
    run_demo()
