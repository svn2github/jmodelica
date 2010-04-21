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

# Import the JModelica.org Python packages
from jmodelica import optimize

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """Demonstrate how to solve a minimum time
    dynamic optimization problem based on a
    Van der Pol oscillator system."""

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    model_name = 'VDP_pack.VDP_Opt_Min_Time'
    mo_file = curr_dir+'/files/VDP.mo'
	
    (model, res) = optimize(model_name, mo_file, compiler_target='ipopt',
							compiler_options={'state_start_values_fixed':True})
							
    # Extract variable profiles
    x1=res.get_variable_data('x1')
    x2=res.get_variable_data('x2')
    u=res.get_variable_data('u')
    tf=res.get_variable_data('tf')

    assert N.abs(tf.x[-1] - 2.2811587) < 1e-3, \
            "Wrong value of cost function in cstr_minimum_time.py"
    
    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(311)
        plt.plot(x1.t,x1.x)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(312)
        plt.plot(x2.t,x2.x)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(313)
        plt.plot(u.t,u.x)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
