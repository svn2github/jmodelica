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
    jmu_name1 = compile_jmu("JMExamples_opt.PenicillinPlant_opt1", (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    
	# optimize
    pp1 = JMUModel(jmu_name1)
    opts = pp1.optimize_options()
    opts['n_e'] = 30
    res1 = pp1.optimize(options=opts)
    
    # Extract variable profiles
    X1=res1['X1']
    S1=res1['S1']
    P1=res1['P1']
    V1=res1['V1']
    u1=res1['u1'] 
    t1=res1['time']
	
    print "X1(final) = ", repr(X1[1])
    print "t1 = ", repr(N.array(t1))
    print "X1 = ", repr(N.array(X1))
    print "S1 = ", repr(N.array(S1))
    print "P1 = ", repr(N.array(P1))
    print "V1 = ", repr(N.array(V1))
    print "u1 = ", repr(N.array(u1))
    print "len(u1) = ", repr(len(u1))
    print "len(t1) = ", repr(len(t1))
	
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    jmu_name2 = compile_jmu("JMExamples_opt.PenicillinPlant_opt2", (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    pp2 = JMUModel(jmu_name2)
	
	#set results of the first state as input for the second state
    X2_init = X1[len(X1)-1]
    S2_init = S1[len(S1)-1]
    P2_init = P1[len(P1)-1]
    V2_init = V1[len(V1)-1]
    u2_init = u1[len(u1)-1]
	
    pp2.set('X2_0',X2_init)
    pp2.set('S2_0',S2_init)
    pp2.set('P2_0',P2_init)
    pp2.set('V2_0',V2_init)
    pp2.set('u2_0',u2_init)

    opts = pp2.optimize_options()
    opts['n_e'] = 30
	#opts["init_traj"] = res1
    res2 = pp2.optimize(options=opts)
	
	#Extract variable profiles
    X2=res2['X2']
    S2=res2['S2']
    P2=res2['P2']
    V2=res2['V2']
    u2=res2['u2']
	
    t2 = t1+80
    t = range(182)
    t[0:91] = t1
    t[91:182] = t2
    X = range(182)
    S = range(182)
    P = range(182)
    V = range(182)
    u = range(182)
    X[0:91] = X1
    X[91:182] = X2
    S[0:91] = S1
    S[91:182] = S2
    P[0:91] = P1
    P[91:182] = P2
    V[0:91] = V1
    V[91:182] = V2
    u[0:91] = u1
    u[91:182] = u2

    
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(321)
        plt.plot(t,X)
        plt.title('Cell mass concentration')
        plt.grid()
        plt.ylabel('X')

        plt.subplot(322)
        plt.plot(t,S)
        plt.title('Substrate concentration')
        plt.grid()
        plt.ylabel('S')
		
        plt.subplot(323)
        plt.plot(t,P)
        plt.title('Penicillin concentration')
        plt.grid()
        plt.ylabel('P')
        
        plt.subplot(324)
        plt.plot(t,V)
        plt.title('Volume of medium')
        plt.grid()
        plt.ylabel('V')
		
        plt.subplot(325)
        plt.plot(t,u)
        plt.title('Feed flowrate')
        plt.grid()
        plt.ylabel('u')
		
        plt.xlabel('time')
        plt.show()

        # plt.figure(2)
        # plt.clf()
        # plt.subplot(321)
        # plt.plot(t2,X2)
        # plt.title('Cell mass concentration')
        # plt.grid()
        # plt.ylabel('X2')

        # plt.subplot(322)
        # plt.plot(t2,S2)
        # plt.title('Substrate concentration')
        # plt.grid()
        # plt.ylabel('S2')
		
        # plt.subplot(323)
        # plt.plot(t2,P2)
        # plt.title('Penicillin concentration')
        # plt.grid()
        # plt.ylabel('P2')
        
        # plt.subplot(324)
        # plt.plot(t2,V2)
        # plt.title('Volume of medium')
        # plt.grid()
        # plt.ylabel('V2')
		
        # plt.subplot(325)
        # plt.plot(t2,u2)
        # plt.title('Feed flowrate')
        # plt.grid()
        # plt.ylabel('u2')
		
        # plt.xlabel('time')
        # plt.show()

        print "Penicillin production:", repr(P2[len(P2)-1])
		
if __name__ == "__main__":
    run_demo()
