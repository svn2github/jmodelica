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
    Greenhouse Optimal Climate Control, a problem with external input
    reference : OPTIMAL CONTROL OF A SOLAR GREENHOUSE
    R.J.C. van Ooteghem, J.D. Stigter, L.G. van Willigenburg, G. van Straten
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name = compile_jmu("JMExamples_opt.Greenhouse_opt", 
    (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    gh = JMUModel(jmu_name)
    
    res = gh.optimize()

    # Extract variable profiles
    x1=res['x1']
    x2=res['x2']
    x3=res['x3']
    u=res['u']
    t=res['time']
    sun=res['sun']
    temp=res['temp']  

    print "t = ", repr(N.array(t))
    print "x1 = ", repr(N.array(x1))
    print "x2 = ", repr(N.array(x2))
    print "sun = ", repr(N.array(sun))
    print "temp = ", repr(N.array(temp))
    
    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(321)
        plt.plot(t,x1)
        plt.grid()
        plt.ylabel('x1')

        
        plt.subplot(322)
        plt.plot(t,x2)
        plt.grid()
        plt.ylabel('x2')
		
        plt.subplot(323)
        plt.plot(t,x3)
        plt.grid()
        plt.ylabel('x3')
		
        plt.subplot(324)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        
        plt.subplot(325)
        plt.plot(t,sun)
        plt.grid()
        plt.ylabel('sun')
		
        plt.subplot(326)
        plt.plot(t,temp)
        plt.grid()
        plt.ylabel('temp')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
