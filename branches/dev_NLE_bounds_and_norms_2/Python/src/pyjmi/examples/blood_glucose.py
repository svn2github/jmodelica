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

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the JModelica.org Python packages
from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    Blood Glucose model
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    fmu_name1 = compile_fmu("JMExamples.BloodGlucose.BloodGlucose1", 
    curr_dir+"/files/JMExamples.mo")
    bg = load_fmu(fmu_name1)
    
    res = bg.simulate(final_time=400)

    # Extract variable profiles
    G	= res['G']
    X	= res['X']
    I	= res['I']
    t	= res['time']
    
    print "t = ", repr(N.array(t))
    print "G = ", repr(N.array(G))
    print "X = ", repr(N.array(X))
    print "I = ", repr(N.array(I))

    if with_plots:
        # Plot
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t,G)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('G')
        plt.subplot(2,2,2)
        plt.plot(t,X)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('X')
        plt.subplot(2,2,3)
        plt.plot(t,I)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('I')
        
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
