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
    Example about landing an object
    reference : PROPT - Matlab Optimal Control Software (DAE, ODE)
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name = compile_jmu("JMExamples_opt.MoonLander_opt", 
    (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    ml = JMUModel(jmu_name)
    
    res = ml.optimize()

    # Extract variable profiles
    h=res['h']
    v=res['v']
    m=res['m']
    u=res['u']
    t=res['time'] 

    print "t = ", repr(N.array(t))
    print "h = ", repr(N.array(h))
    print "v = ", repr(N.array(v))
    print "m = ", repr(N.array(m))
    print "u = ", repr(N.array(u))
    
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(221)
        plt.plot(t,h)
        plt.grid()
        plt.ylabel('h')
        plt.title('height')
		
        plt.subplot(222)
        plt.plot(t,v)
        plt.grid()
        plt.ylabel('v')
        plt.title('velocity')
		
        plt.subplot(223)
        plt.plot(t,m)
        plt.grid()
        plt.ylabel('m')
        plt.title('mass')
        
        plt.subplot(224)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.title('thrust')
        
        plt.xlabel('time')
        plt.show()
		
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name = compile_jmu("JMExamples_opt.MoonLander_opttime", 
    (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    ml = JMUModel(jmu_name)
    
    res = ml.optimize()

    # Extract variable profiles
    h=res['h']
    v=res['v']
    m=res['m']
    u=res['u']
    t=res['time'] 

    print "t = ", repr(N.array(t))
    print "h = ", repr(N.array(h))
    print "v = ", repr(N.array(v))
    print "m = ", repr(N.array(m))
    print "u = ", repr(N.array(u))
    
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(221)
        plt.plot(t,h)
        plt.grid()
        plt.ylabel('h')
        plt.title('height')
		
        plt.subplot(222)
        plt.plot(t,v)
        plt.grid()
        plt.ylabel('v')
        plt.title('velocity')
		
        plt.subplot(223)
        plt.plot(t,m)
        plt.grid()
        plt.ylabel('m')
        plt.title('mass')
        
        plt.subplot(224)
        plt.plot(t,u)
        plt.grid()
        plt.ylabel('u')
        plt.title('thrust')
        
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()