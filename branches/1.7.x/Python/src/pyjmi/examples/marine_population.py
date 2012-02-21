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
import scipy as Sci
import matplotlib.pyplot as plt

# Import the JModelica.org Python packages
from pymodelica import compile_jmu
from pyjmi import JMUModel

def run_demo(with_plots=True):
    """
    This is an example of parameter estimation of marine population dynamics.
    reference:
    Benchmarking Optimization Software with COPS Elizabeth D. 
    Dolan and Jorge J. More ARGONNE NATIONAL LABORATORY
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    jmu_name = compile_jmu("JMExamples_opt.MarinePopulation_opt", (curr_dir+"/files/JMExamples_opt.mop",curr_dir+"/files/JMExamples.mo"))
    mp = JMUModel(jmu_name)
	
    # optimize
    opts = mp.optimize_options()
    opts['n_e'] = 20
    opts['n_cp'] = 1
    res = mp.optimize(options=opts)
	
	#Extract variable profiles
    y1=res['sys.y[1]']
    y2=res['sys.y[2]']
    y3=res['sys.y[3]']
    y4=res['sys.y[4]']
    y5=res['sys.y[5]']
    y6=res['sys.y[6]']
    y7=res['sys.y[7]']
    y8=res['sys.y[8]']
    g1=res['sys.g[1]']
    g2=res['sys.g[2]']
    g3=res['sys.g[3]']
    g4=res['sys.g[4]']
    g5=res['sys.g[5]']
    g6=res['sys.g[6]']
    g7=res['sys.g[7]']
    g1=res['sys.m[1]']
    m1=res['sys.m[1]']
    m2=res['sys.m[2]']
    m3=res['sys.m[3]']
    m4=res['sys.m[4]']
    m5=res['sys.m[5]']
    m6=res['sys.m[6]']
    m7=res['sys.m[7]']
    m8=res['sys.m[8]']
    t =res['time']
	
    ym=([[ 20000., 17000., 10000., 15000., 12000., 9000., 7000., 3000.],
    [ 12445., 15411., 13040., 13338., 13484., 8426., 6615., 4022.],
    [  7705., 13074., 14623., 11976., 12453., 9272., 6891., 5020.],
    [  4664.,  8579., 12434., 12603., 11738., 9710., 6821., 5722.],
    [  2977.,  7053., 11219., 11340., 13665., 8534., 6242., 5695.],
    [  1769.,  5054., 10065., 11232., 12112., 9600., 6647., 7034.],
    [   943.,  3907.,  9473., 10334., 11115., 8826., 6842., 7348.],
    [   581.,  2624.,  7421., 10297., 12427., 8747., 7199., 7684.],
    [   355.,  1744.,  5369.,  7748., 10057., 8698., 6542., 7410.],
    [   223.,  1272.,  4713.,  6869.,  9564., 8766., 6810., 6961.],
    [   137.,   821.,  3451.,  6050.,  8671., 8291., 6827., 7525.],
    [    87.,   577.,  2649.,  5454.,  8430., 7411., 6423., 8388.],
    [    49.,   337.,  2058.,  4115.,  7435., 7627., 6268., 7189.],
    [    32.,   228.,  1440.,  3790.,  6474., 6658., 5859., 7467.],
    [    17.,   168.,  1178.,  3087.,  6524., 5880., 5562., 7144.],
    [    11.,    99.,   919.,  2596.,  5360., 5762., 4480., 7256.],
    [     7.,    65.,   647.,  1873.,  4556., 5058., 4944., 7538.],
    [     4.,    44.,   509.,  1571.,  4009., 4527., 4233., 6649.],
    [     2.,    27.,   345.,  1227.,  3677., 4229., 3805., 6378.],
    [     1.,    20.,   231.,   934.,  3197., 3695., 3159., 6454.],
    [     1.,    12.,   198.,   707.,  2562., 3163., 3232., 5566.]]);      
       
    tm = range(21)
    y1_m = [ym[i][0] for i in range(0,21)]
    y2_m = [ym[i][1] for i in range(0,21)]
    y3_m = [ym[i][2] for i in range(0,21)]
    y4_m = [ym[i][3] for i in range(0,21)]
    y5_m = [ym[i][4] for i in range(0,21)]
    y6_m = [ym[i][5] for i in range(0,21)]
    y7_m = [ym[i][6] for i in range(0,21)]
    y8_m = [ym[i][7] for i in range(0,21)]
    
    if with_plots:
        # Plot
        plt.figure()
        plt.clf()
        plt.subplot(421)
        plt.plot(t,y1,tm,y1_m,'x')
        plt.title('y1')
        plt.grid()
        plt.ylabel('y1')
		
        plt.subplot(422)
        plt.plot(t,y2,tm,y2_m,'x')
        plt.title('y2')
        plt.grid()
        plt.ylabel('y2')
		
        plt.subplot(423)
        plt.plot(t,y3,tm,y3_m,'x')
        plt.title('y3')
        plt.grid()
        plt.ylabel('y3')
		
        plt.subplot(424)
        plt.plot(t,y4,tm,y4_m,'x')
        plt.title('y4')
        plt.grid()
        plt.ylabel('y4')

        plt.subplot(425)
        plt.plot(t,y5,tm,y5_m,'x')
        plt.title('y5')
        plt.grid()
        plt.ylabel('y5')
		
        plt.subplot(426)
        plt.plot(t,y6,tm,y6_m,'x')
        plt.title('y6')
        plt.grid()
        plt.ylabel('y6')
		
        plt.subplot(427)
        plt.plot(t,y7,tm,y7_m,'x')
        plt.title('y7')
        plt.grid()
        plt.ylabel('y7')
		
        plt.subplot(428)
        plt.plot(t,y8,tm,y8_m,'x')
        plt.title('y8')
        plt.grid()
        plt.ylabel('y8')

        print("** Optimal parameter values: **")
        print('g = {0:.3f} {1:.3f} {2:.3f} {3:.3f} {4:.3f} {5:.3f} {6:.3f} '
        .format(g1,g2,g3,g4,g5,g6,g7))
        print('m = {0:.3f} {1:.3f} {2:.3f} {3:.3f} {4:.3f} {5:.3f} {6:.3f} {7:.3f}'
        .format(m1,m2,m3,m4,m5,m6,m7,m8))

        J = Sci.linalg.norm(y1-y1_m)+Sci.linalg.norm(y2-y2_m)+Sci.linalg.norm(y3-y3_m)
        +Sci.linalg.norm(y4-y4_m)+Sci.linalg.norm(y5-y5_m)+Sci.linalg.norm(y6-y6_m)
        +Sci.linalg.norm(y7-y7_m)+Sci.linalg.norm(y8-y8_m)
        print('J = ', repr(J))
if __name__ == "__main__":
    run_demo()
