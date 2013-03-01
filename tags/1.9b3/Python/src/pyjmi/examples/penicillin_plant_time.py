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
    In this example, the objective is to maximize the concentration of penicillin, P, 
    produced in a fed-batch bioreactor, given a finite amount of time. 
    reference:
    Fed-batch Fermentor Control: Dynamic Optimization of Batch Processes II. Role of Measurements 
    in Handling Uncertainty 2001, B. Srinivasan, D. Bonvin, E. Visser, S. Palanki
    Illustrative example: Nominal Optimization of a Fed-Batch Fermentor for Penicillin Production.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    jmu_name1 = compile_jmu("JMExamples_opt.PenicillinPlant_opttime", (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    
	# optimize
    pp1 = JMUModel(jmu_name1)
    res1 = pp1.optimize()
    
    # Extract variable profiles
    X1=res1['X1']
    S1=res1['S1']
    P1=res1['P1']
    V1=res1['V1']
    u1=res1['u1'] 
    du1=res1['du1']
    t=res1['time']
	
    print "X1(final) = ", repr(X1[1])
    print "t = ", repr(N.array(t))
    print "X1 = ", repr(N.array(X1))
    print "S1 = ", repr(N.array(S1))
    print "P1 = ", repr(N.array(P1))
    print "V1 = ", repr(N.array(V1))
    print "u1 = ", repr(N.array(u1))
    print "du1 = ", repr(N.array(du1))
    print "len(u1) = ", repr(len(u1))
    print "len(t) = ", repr(len(t))
	
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(321)
        plt.plot(t,X1)
        plt.title('Cell mass concentration')
        plt.grid()
        plt.ylabel('X1')

        plt.subplot(322)
        plt.plot(t,S1)
        plt.title('Substrate concentration')
        plt.grid()
        plt.ylabel('S1')
		
        plt.subplot(323)
        plt.plot(t,P1)
        plt.title('Penicillin concentration')
        plt.grid()
        plt.ylabel('P1')
        
        plt.subplot(324)
        plt.plot(t,V1)
        plt.title('Volume of medium')
        plt.grid()
        plt.ylabel('V1')
		
        plt.subplot(325)
        plt.plot(t,u1)
        plt.title('Feed flowrate')
        plt.grid()
        plt.ylabel('u1')
		
        plt.subplot(326)
        plt.plot(t,du1)
        plt.title('Derivative of Feed flowrate')
        plt.grid()
        plt.ylabel('du1')
		
        plt.xlabel('time')
        plt.show()
	
	print "Final time:", repr(t[len(t)-1])
	
if __name__ == "__main__":
    run_demo()