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

import os.path
import numpy as N
import matplotlib.pyplot as plt

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the ODE simulator.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    file_name = os.path.join(curr_dir,'files','VDP.mop')
    
    fmu_name = compile_fmu("JMExamples.VDP.VDP", 
    curr_dir+"/files/JMExamples.mo")

    model = load_fmu(fmu_name)
    
    res = model.simulate(final_time=10, options={'solver':'CVode'})

    x1 = res['x1']
    x2 = res['x2']
    t  = res['time']
    
    if with_plots:
        plt.figure()
        plt.plot(x2, x1)
        plt.legend(('x1(x2)'))
        plt.show()

        

if __name__=="__main__":
    run_demo()
