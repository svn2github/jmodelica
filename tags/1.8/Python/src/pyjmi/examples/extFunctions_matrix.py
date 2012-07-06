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

import pylab as p
import numpy as N

from pymodelica import compile_jmu
from pyjmi import JMUModel

def run_demo(with_plots=True):
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    class_name = 'ExtFunctions.transposeSquareMatrix'
    mofile = curr_dir+'/files/ExtFunctions.mo'
    
    jmu_name = compile_jmu(class_name, mofile, target='model_noad')
    model = JMUModel(jmu_name)

    #simulate
    res = model.simulate()
    
    b1_1 = res['b_out[1,1]']
    b1_2 = res['b_out[1,2]']
    b2_1 = res['b_out[2,1]']
    b2_2 = res['b_out[2,2]']
    t = res['time']

    assert N.abs(b1_1[-1] - 1) < 1e-6
     
    assert N.abs(b1_2[-1] - 3) < 1e-6
     
    assert N.abs(b2_1[-1] - 2) < 1e-6
     
    assert N.abs(b2_2[-1] - 4) < 1e-6 
           
    if with_plots:
        fig = p.figure()
        p.clf()
        p.plot(t, b1_1, label='b1_1')
        p.plot(t, b1_2, label='b1_2')
        p.plot(t, b2_1, label='b2_1')
        p.plot(t, b2_2, label='b2_2')
        p.legend()
        p.grid()
        p.show()

if __name__=="__main__":
    run_demo()
