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
    temperature control of industrial gas phase polyethylene reactors, S. A. Dadebo, 
    P. J. McLellan and K. B. McAuley, J Proc. Cont. Vol. 7 No. 2, pp. 83 - 95, 1997.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name = compile_jmu("JMExamples_opt.Polyeth_opt", 
    (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    poly = JMUModel(jmu_name)
    
    res = poly.optimize()

    # Extract variable profiles
    In_con = res['poly.In_con']
    M1_con = res['poly.M1_con']
    Y1	   = res['poly.Y1']
    Y2	   = res['poly.Y2']
    T	= res['poly.T']
    Tw	= res['poly.Tw']
    Tg	= res['poly.Tg'] 
    u	= res['u']
    t	= res['time']
	
    print "t = ", repr(N.array(t))
    print "In_con = ", repr(N.array(In_con))
    print "M1_con = ", repr(N.array(M1_con))

    print "Y1 = ", repr(N.array(Y1))
    print "Y2 = ", repr(N.array(Y2))
    print "T = ", repr(N.array(T))
    print "Tw = ", repr(N.array(Tw))
    print "Tg = ", repr(N.array(Tg))

    if with_plots:
        # Plot
        plt.figure(1)
        plt.subplot(421)
        plt.plot(t,In_con)
        plt.grid()
        plt.ylabel('In_con')
        
        plt.subplot(422)
        plt.plot(t,M1_con)
        plt.grid()
        plt.ylabel('M1_con')
		
        plt.figure(1)
        plt.subplot(423)
        plt.plot(t,Y1)
        plt.grid()
        plt.ylabel('Y1')
        
        plt.subplot(424)
        plt.plot(t,Y2)
        plt.grid()
        plt.ylabel('Y2')
        
        plt.subplot(425)
        plt.plot(t,T)
        plt.grid()
        plt.ylabel('T')
		
        plt.subplot(426)
        plt.plot(t,Tw)
        plt.grid()
        plt.ylabel('Tw')
        
        plt.subplot(427)
        plt.plot(t,Tg)
        plt.grid()
        plt.ylabel('Tg')
		
        plt.subplot(428)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
		
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
