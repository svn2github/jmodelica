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

from pymodelica import compile_jmu, compile_fmux
from pyjmi import JMUModel, CasadiModel

def run_demo(with_plots=True):

    curr_dir = os.path.dirname(os.path.abspath(__file__));
        
    jmu_name  = compile_jmu("Orbital", curr_dir+"/files/Hohmann.mop")
    comp_opts = {"normalize_minimum_time_problems": False} # Disable minimum time normalization
    fmux_name = compile_fmux("HohmannTransfer", curr_dir+"/files/Hohmann.mop",
                             compiler_options=comp_opts)

    # Optimization
    model = CasadiModel(fmux_name)
    opts = model.optimize_options(algorithm="CasadiPseudoSpectralAlg")
    opts["n_cp"] = 40                                      # Number of collocation points
    opts["n_e"] = 2                                        # Number of phases
    opts["free_phases"] = True                             # The phase boundary is allowed to be changed in time
    opts["phase_options"] = ["t1"]                         # The phase boundary is connected to variable t1
    opts["link_options"] = [(1,"vy","dy1"),(1,"vx","dx1")] # Allow for discontinuities between phase 1 and 2 for vy and vx.
                                                           # The discontinuities are connected by dy1 and dx1
    # Optimize
    res_opt = model.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)

    # Get results
    dx1,dy1,dx2,dy2 = res_opt.final("dx1"), res_opt.final("dy1"), res_opt.final("dx2"), res_opt.final("dy2")
    r1,r2,my        = res_opt.final("rStart"), res_opt.final("rFinal"), res_opt.final("my")
    tf,t1           = res_opt.final("time"), res_opt.final("t1")
    
    # Verify solution using theoretical results
    # Assert dv1 
    assert N.abs( N.sqrt(dx1**2+dy1**2) - N.sqrt(my/r1)*(N.sqrt(2*r2/(r1+r2))-1) ) < 1e-1
    #Assert dv2 
    assert N.abs( N.sqrt(dx2**2+dy2**2) - N.sqrt(my/r2)*(1-N.sqrt(2*r1/(r1+r2))) ) < 1e-1
    #Assert transfer time 
    assert N.abs( tf-t1 - N.pi*((r1+r2)**3/(8*my))**0.5 ) < 1e-1

    # Verify solution by simulation
    model = JMUModel(jmu_name)
    
    # Retrieve the options
    opts = model.simulate_options()
    
    opts["ncp"] = 100
    opts["solver"] = "IDA"
    opts["initialize"] = False
    
    # Simulation of Phase 1
    res = model.simulate(final_time=t1,options=opts)

    x_phase_1,y_phase_1 = res["x"], res["y"]
    
    # Simulation of Phase 2
    model.set("vx", dx1 + res.final("vx"))
    model.set("vy", dy1 + res.final("vy"))

    res = model.simulate(start_time=t1,final_time=tf,options=opts)

    x_phase_2,y_phase_2 = res["x"], res["y"]

    # Simulation of Phase 3 (verify that we are still in orbit)
    model.set("vx", dx2 + res.final("vx"))
    model.set("vy", dy2 + res.final("vy"))

    res = model.simulate(start_time=tf, final_time=tf*2, options=opts)

    x_phase_3,y_phase_3 = res["x"], res["y"]
    
    if with_plots:
        # Plot Earth
        r = 1.0
        xE = r*N.cos(N.linspace(0,2*N.pi,200))
        yE = r*N.sin(N.linspace(0,2*N.pi,200))
        plt.plot(xE,yE,label="Earth")

        # Plot Orbits
        r = res.final("rStart")
        xS = r*N.cos(N.linspace(0,2*N.pi,200))
        yS = r*N.sin(N.linspace(0,2*N.pi,200))
        plt.plot(xS,yS,label="Low Orbit")

        r = res.final("rFinal")
        xSE = r*N.cos(N.linspace(0,2*N.pi,200))
        ySE = r*N.sin(N.linspace(0,2*N.pi,200))
        plt.plot(xSE,ySE,label="High Orbit")
        
        # Plot Satellite trajectory
        x_sim=N.hstack((N.hstack((x_phase_1,x_phase_2)),x_phase_3))
        y_sim=N.hstack((N.hstack((y_phase_1,y_phase_2)),y_phase_3))

        plt.plot(x_sim,y_sim,"-",label="Satellite")
        
        # Plot Rocket Burns
        plt.arrow(x_phase_1[-1],y_phase_1[-1],0.5*dx1,0.5*dy1, width=0.01,label="dv1")
        plt.arrow(x_phase_2[-1],y_phase_2[-1],0.5*dx2,0.5*dy2, width=0.01,label="dv2")
        
        plt.legend()
        plt.show()

if __name__ == "__main__":
    run_demo()
