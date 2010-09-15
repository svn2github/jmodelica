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
    Simulation of a model containing if expressions. The
    relational expressions in the model does not, however,
    generate events since they are contained inside the
    noEvent(.) operator.
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    class_name = 'IfExpExamples.IfExpExample1'
    mofile = curr_dir+'/files/IfExpExamples.mo'
    
    jmu_name = compile_jmu(class_name, mofile)
    model = JMUModel(jmu_name)
    sim_res = model.simulate(
        alg_args={'final_time':5, 'num_communication_points':500})
                        
    res = sim_res.result_data
    x = res.get_variable_data('x')
    u = res.get_variable_data('u')
    
    assert N.abs(x.x[-1] - 3.5297357) < 1e-3, \
            "Wrong value, last value of x in if_example.py"
    assert N.abs(u.x[-1] - (-0.2836625)) < 1e-3, \
            "Wrong value, last value of u in if_example.py"

    if with_plots:
        fig = p.figure()
        p.plot(x.t, x.x, u.t, u.x)
        p.legend(('x','u'))
        p.show()

if __name__=="__main__":
    run_demo()
