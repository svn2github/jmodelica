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
    An example on how to simulate a model using the DAE simulator. The
    result can be compared with that of sim_rlc.py which has solved the
    same problem using dymola. Also writes information to a file.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'RLC_Circuit'
    mofile = curr_dir+'/files/RLC_Circuit.mo'
    
    sim_res = simulate(model_name, mofile, alg_args={'final_time':30})
    
    res = sim_res.result_data
    sine_y = res.get_variable_data('sine.y')
    resistor_v = res.get_variable_data('resistor.v')
    inductor1_i = res.get_variable_data('inductor1.i')

    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
           "Wrong value in simulation result in RLC.py"

    
    if with_plots:
        fig = p.figure()
        p.plot(sine_y.t, sine_y.x, resistor_v.t, resistor_v.x, inductor1_i.t, inductor1_i.x)
        p.legend(('sine.y','resistor.v','inductor1.i'))
        p.show()


if __name__=="__main__":
    run_demo()
