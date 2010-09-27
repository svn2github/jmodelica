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

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the ODE simulator.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    file_name = os.path.join(curr_dir,'files','VDP.mop')
    
    jmu_name = compile_jmu('VDP_pack.VDP', file_name,
                        compiler_options={'state_start_values_fixed':True})

    model = JMUModel(jmu_name)
    
    res = model.simulate(final_time=20,
        options={'ncp':0,'solver':'CVode', 'CVode_options':{'discr':'BDF','iter':'Newton'}})

    x1 = res['x1']
    x2 = res['x2']
    t  = res['time']
    
    assert N.abs(x1[-1] + 0.736680243) < 1e-3, \
           "Wrong value in simulation result in VDP_assimulo.py" 
    assert N.abs(x2[-1] - 1.57833994) < 1e-3, \
           "Wrong value in simulation result in VDP_assimulo.py"
    #assert VDP_sim.stats['Number of F-Eval During Jac-Eval         '] == 0
    
    if with_plots:
        fig = p.figure()
        p.plot(t, x1, t, x2)
        p.legend(('x1','x2'))
        p.show()
        

if __name__=="__main__":
    run_demo()
