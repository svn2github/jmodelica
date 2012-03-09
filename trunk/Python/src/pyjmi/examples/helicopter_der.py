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
from pymodelica import compile_jmu
from pyjmi import JMUModel

def run_demo(with_plots=True):
    """
    Helicopter model with derivative inputs
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu = compile_jmu("JMExamples_opt.HelicopterDer",(curr_dir+"/files/JMExamples_opt.mop", curr_dir+"/files/JMExamples.mo"))
    hd = JMUModel(jmu)
    
    res = hd.optimize()

    # Extract variable profiles
    te	= res['te']
    tr	= res['tr']
    tp	= res['tp']
    Vf	= res['Vf']
    Vb	= res['Vb']
    t	= res['time']
    

    if with_plots:
        # Plot
        plt.figure()
        plt.subplot(3,2,1)
        plt.plot(t,te)
        plt.grid(True)
        plt.ylabel('te')
        plt.subplot(3,2,2)
        plt.plot(t,tr)
        plt.grid(True)
        plt.ylabel('tr')
        plt.subplot(3,2,3)
        plt.plot(t,tp)
        plt.grid(True)
        plt.ylabel('tp')
        plt.subplot(3,2,4)
        plt.plot(t,Vf)
        plt.grid(True)
        plt.ylabel('Vf')
        plt.subplot(3,2,5)
        plt.plot(t,Vb)
        plt.grid(True)
        plt.ylabel('Vb')
        
		
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()