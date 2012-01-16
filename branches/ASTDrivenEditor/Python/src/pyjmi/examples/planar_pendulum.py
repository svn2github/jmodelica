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

# Import library for path manipulations
import os.path

import numpy as N
import matplotlib.pyplot as plt

from jmodelica import compile_fmu
from pyfmi import FMUModel

def run_demo(with_plots=True):
    """ 
    Example demonstrating how to use index reduction.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile model
    fmu_name = compile_fmu("Pendulum_pack.PlanarPendulum", 
        curr_dir+"/files/Pendulum_pack.mop",compiler='optimica')

    # Load model
    model = FMUModel(fmu_name)

    # Load result file
    res = model.simulate(final_time=10.)

    x = res['x']
    y = res['y']
    vx = res['vx']
    vy = res['vy']
    t = res['time']

    assert N.abs(x[-1] - 3.87669270e-01) < 1e-3, \
           "Wrong value in simulation result."  

    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.plot(t,x,t,y)
        plt.grid(True)
        plt.legend(['x','y'])
        plt.subplot(2,1,2)
        plt.plot(t,vx,t,vy)
        plt.grid(True)
        plt.legend(['vx','vy'])
        plt.xlabel('time [s]')
        plt.show()
