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
    Blood Glucose model
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu = compile_jmu("JMExamples_opt.BloodGlucose_opt_scaled",(curr_dir+"/files/JMExamples_opt.mop", curr_dir+"/files/JMExamples.mo"))
    bg = JMUModel(jmu)
    res = bg.optimize()
	
    jmu_final = compile_jmu("JMExamples_opt.BloodGlucose_opt_scaled_final",(curr_dir+"/files/JMExamples_opt.mop", curr_dir+"/files/JMExamples.mo"))
    bg_final = JMUModel(jmu_final)
    res_final = bg_final.optimize()

    # Extract variable profiles
    G	= res['bc.G']
    X	= res['bc.X']
    I	= res['bc.I']
    D	= res['bc.D']
    t	= res['time']
	
	# Extract variable profiles of final result
    G_final	= res_final['bc.G']
    X_final	= res_final['bc.X']
    I_final	= res_final['bc.I']
    D_final	= res_final['bc.D']
    
    print "t = ", repr(N.array(t))
    print "G = ", repr(N.array(G))
    print "X = ", repr(N.array(X))
    print "I = ", repr(N.array(I))
    print "D = ", repr(N.array(D))

    if with_plots:
        # Plot
        plt.figure()
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
        plt.subplot(2,2,4)
        plt.plot(t,D)
        plt.title('Input')
        plt.grid(True)
        plt.ylabel('D')
        
		
        plt.xlabel('time')
        plt.show()
		
		# Plot for final result
        plt.figure()
        plt.subplot(2,2,1)
        plt.plot(t,G_final)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('G_final')
        plt.subplot(2,2,2)
        plt.plot(t,X_final)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('X_final')
        plt.subplot(2,2,3)
        plt.plot(t,I_final)
        plt.title('Plasma Glucose Conc.')
        plt.grid(True)
        plt.ylabel('I_final')
        plt.subplot(2,2,4)
        plt.plot(t,D_final)
        plt.title('Input')
        plt.grid(True)
        plt.ylabel('D_final')
        
		
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()