#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
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

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the JModelica.org Python packages
from pymodelica import compile_fmux
from pyjmi import CasadiModel

def run_demo(with_plots=True):
    """
    Demonstrate how to optimize a VDP oscillator using LocalDAECollocationAlg.
    """
    # Compile and load model
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    jn = compile_fmux("VDP_pack.VDP_Opt2", curr_dir + "/files/VDP.mop")
    model = CasadiModel(jn)
    
    # Set algorithm options
    opts = model.optimize_options(algorithm="LocalDAECollocationAlg")
    opts['graph'] = "SX"
    
    # Optimize
    res = model.optimize(algorithm="LocalDAECollocationAlg", options=opts)
    
    # Extract variable profiles
    x1 = res['x1']
    x2 = res['x2']
    u = res['u']
    time = res['time']
    
    assert N.abs(res.final('x1') - 8.41026105e-07) < 1e-3
    assert N.abs(res.final('x2') + 3.56828261e-07) < 1e-3
    
    # Plot
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(3, 1, 1)
        plt.plot(time, x1)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(3, 1, 2)
        plt.plot(time, x2)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(3, 1, 3)
        plt.plot(time, u)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
