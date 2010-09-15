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
    This example shows how to simulate a system that contains switches.
    The example model is simple in the sense that no reinitialization
    of the variables is needed at the event points.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    class_name = 'IfExpExamples.IfExpExample2'
    mofile = curr_dir+'/files/IfExpExamples.mo'

    jmu_name = compile_jmu(class_name, mofile)

    # Load the dynamic library and XML data
    model = JMUModel(jmu_name)

    # Initialize the switches (1=true, 0=false)
    model.set_sw(N.array([1,1]))
    
    #Simulate
    sim_res = model.simulate(alg_args={'final_time':5.0})
    
    # Get results
    res = sim_res.result_data
    x = res.get_variable_data('x')
    u = res.get_variable_data('u')
    
    assert N.abs(x.x[-1] - 3.5297217) < 1e-3, \
            "Wrong value, last value of x in if_example_2.py"

    assert N.abs(u.x[-1] - (-0.2836621)) < 1e-3, \
            "Wrong value, last value of u in if_example_2.py"        

    if with_plots:
        #Plot
        fig = p.figure()
        p.plot(x.t, x.x, u.t, u.x)
        p.legend(('x','u'))
        p.show()

if __name__=="__main__":
    run_demo()

