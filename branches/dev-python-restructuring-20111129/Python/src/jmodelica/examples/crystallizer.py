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

import numpy as N
import matplotlib.pyplot as plt

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

def run_demo(with_plots=True):
    """
    This is the crystallizer example from Bieglers book in section 10.3.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
        
    # Compile model

    jmu_name = compile_jmu("Crystallizer.SimulateCrystallizer", curr_dir+"/files/Crystallizer.mop", 
                           compiler_options={"enable_variable_scaling":True})

    crys = JMUModel(jmu_name)

    sim_opts = crys.simulate_options()

    res = crys.simulate(final_time=25,options=sim_opts)

    time = res['time']
    Ls = res['c.Ls']
    Nc = res['c.Nc']
    L = res['c.L']
    Ac = res['c.Ac']
    Vc = res['c.Vc']
    Mc = res['c.Mc']
    Cc = res['c.Cc']
    Tc = res['c.Tc']
    
    Ta = res['Ta']
    Teq = res['c.Teq']
    deltaT = res['c.deltaT']
    Cbar = res['c.Cbar']
    
    Tj = res['c.Tj']

    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(2,1,1)
        plt.plot(time,Ls)
        plt.grid()
        plt.subplot(2,1,2)
        plt.plot(time,Tj)
        plt.grid()
        plt.show()
        
        plt.figure(2)
        plt.clf()
        plt.subplot(4,1,1)
        plt.plot(time,Nc)
        plt.title('Nc')
        plt.grid()
        plt.subplot(4,1,2)
        plt.plot(time,L)
        plt.title('L')
        plt.grid()
        plt.subplot(4,1,3)
        plt.plot(time,Ac)
        plt.title('Ac')
        plt.grid()
        plt.subplot(4,1,4)
        plt.plot(time,Vc)
        plt.title('Vc')
        plt.grid()
        
        plt.figure(3)
        plt.clf()
        plt.subplot(4,1,1)
        plt.plot(time,Mc)
        plt.title('Mc')
        plt.grid()
        plt.subplot(4,1,2)
        plt.plot(time,Cc)
        plt.title('Cc')
        plt.grid()
        plt.subplot(4,1,3)
        plt.plot(time,Tc)
        plt.title('Tc')
        plt.grid()
        plt.subplot(4,1,4)
        plt.plot(time,Teq)
        plt.title('Teq')
        plt.grid()
        plt.show()

        plt.figure(4)
        plt.clf()
        plt.subplot(4,1,1)
        plt.plot(time,deltaT)
        plt.title('deltaT')
        plt.grid()
        plt.subplot(4,1,2)
        plt.plot(time,Cbar)
        plt.title('Cbar')
        plt.grid()
        plt.subplot(4,1,3)
        plt.plot(time,Teq-Tc)
        plt.title('Teq-Tc')
        plt.grid()
        plt.subplot(4,1,4)
        plt.plot(time,Ta)
        plt.title('Ta')
        plt.grid()
        plt.show()
        
    jmu_name = compile_jmu("Crystallizer.OptCrystallizer",
                           curr_dir+"/files/Crystallizer.mop",
                           compiler_options={"enable_variable_scaling":True})

    crys_opt = JMUModel(jmu_name)

    opt_opts = crys_opt.optimize_options()

    n_e = 20
    opt_opts['n_e'] = n_e 
    opt_opts['init_traj'] = res.result_data
    opt_opts['blocking_factors'] = N.ones(n_e,dtype=int)
    #opt_opts['write_scaled_result'] = True
    #opt_opts['IPOPT_options']['derivative_test'] = 'first-order'
    opt_opts['IPOPT_options']['max_iter'] = 1000
    opt_opts['IPOPT_options']['tol'] = 1e-3
    opt_opts['IPOPT_options']['dual_inf_tol'] = 1e-3
    
    res_opt = crys_opt.optimize(options=opt_opts)
    
    time = res_opt['time']
    Ls = res_opt['c.Ls']
    Nc = res_opt['c.Nc']
    L = res_opt['c.L']
    Ac = res_opt['c.Ac']
    Vc = res_opt['c.Vc']
    Mc = res_opt['c.Mc']
    Cc = res_opt['c.Cc']
    Tc = res_opt['c.Tc']
    
#    Ta = res_opt['Ta']
    Teq = res_opt['c.Teq']
    deltaT = res_opt['c.deltaT']
    Cbar = res_opt['c.Cbar']
    
    Tj = res_opt['c.Tj']

    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.hold(True)
        plt.plot(time,Ls)
        plt.subplot(2,1,2)
        plt.hold(True)
        plt.plot(time,Tj,'x-')
        
        plt.figure(2)
        plt.subplot(4,1,1)
        plt.hold(True)
        plt.plot(time,Nc)
        plt.title('Nc')
        plt.subplot(4,1,2)
        plt.hold(True)
        plt.plot(time,L)
        plt.title('L')
        plt.subplot(4,1,3)
        plt.hold(True)
        plt.plot(time,Ac)
        plt.title('Ac')
        plt.subplot(4,1,4)
        plt.hold(True)
        plt.plot(time,Vc)
        plt.title('Vc')
        
        plt.figure(3)
        plt.subplot(4,1,1)
        plt.hold(True)
        plt.plot(time,Mc)
        plt.title('Mc')
        plt.subplot(4,1,2)
        plt.hold(True)
        plt.plot(time,Cc)
        plt.title('Cc')
        plt.subplot(4,1,3)
        plt.hold(True)
        plt.plot(time,Tc)
        plt.title('Tc')
        plt.subplot(4,1,4)
        plt.hold(True)
        plt.plot(time,Teq)
        plt.title('Teq')
        plt.show()
        
        plt.figure(4)
        plt.subplot(4,1,1)
        plt.hold(True)
        plt.plot(time,deltaT)
        plt.title('deltaT')
        plt.subplot(4,1,2)
        plt.hold(True)
        plt.plot(time,Cbar)
        plt.title('Cbar')
        plt.subplot(4,1,3)
        plt.hold(True)
        plt.plot(time,Teq-Tc)
        plt.title('Teq-Tc')
#        plt.subplot(4,1,4)
#        plt.plot(time,Ta)
#        plt.title('Ta')
        
        plt.show()
            
if __name__ == "__main__":
    run_demo()

