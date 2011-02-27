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

import os as O

import numpy as N
import matplotlib.pyplot as plt
import nose

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel


def run_demo(with_plots=True):
    """
    Demonstrates how to use JModelica.org for calculating sensitivities.
    """
    
    curr_dir = O.path.join(O.path.dirname(O.path.abspath(__file__)),'files')
    
    jmu_name = compile_jmu("Robertson", O.path.join(curr_dir,"Robertson.mop"))
    
    # Load a model instance into Python
    model = JMUModel(jmu_name)
    
    # Get and set the options
    opts = model.simulate_options()
    opts['IDA_options']['atol'] = [1.0e-8, 1.0e-14, 1.0e-6]
    opts['IDA_options']['sensitivity'] = True
    opts['ncp'] = 400

    #Simulate
    res = model.simulate(final_time=4, options=opts)

    dy1dp1 = res['dy1/dp1']
    dy2dp1 = res['dy2/dp1']
    dy3dp1 = res['dy3/dp1']
    time = res['time']
    
    nose.tools.assert_almost_equal(dy1dp1[40], -0.35590, 3)
    nose.tools.assert_almost_equal(dy2dp1[40],  3.9026e-04, 6)
    nose.tools.assert_almost_equal(dy3dp1[40],  3.5551e-01 , 3)
    
    plt.plot(time, dy1dp1, time, dy2dp1, time, dy3dp1)
    plt.legend(('dy1/dp1', 'dy2/dp1', 'dy3/dp1'))
    plt.show()
    
    
if __name__ == "__main__":
    run_demo()
