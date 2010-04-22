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
    An example on how to simulate a model using the ODE simulator.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'VDP_pack.VDP_Opt'
    mofile = curr_dir+'/files/VDP.mo'
    
    (model, res) = simulate(model_name, mofile, 
                            compiler='optimica',
                            compiler_options={'state_start_values_fixed':True},
                            alg_args={'final_time':20,'num_communication_points':0,'solver':'CVode'},
                            solver_args={'discr':'BDF','iter':'Newton'})

    x1=res.get_variable_data('x1')
    x2=res.get_variable_data('x2')
    
    assert N.abs(x1.x[-1] + 0.736680243) < 1e-5, \
           "Wrong value in simulation result in VDP_assimulo.py" 
    assert N.abs(x2.x[-1] - 1.57833994) < 1e-5, \
           "Wrong value in simulation result in VDP_assimulo.py"
    #assert VDP_sim.stats['Number of F-Eval During Jac-Eval         '] == 0
    
    if with_plots:
        fig = p.figure()
        p.plot(x1.t, x1.x, x2.t, x2.x)
        p.legend(('x1','x2'))
        p.show()
        

if __name__=="__main__":
    run_demo()
