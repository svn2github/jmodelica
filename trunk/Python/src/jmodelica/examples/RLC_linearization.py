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

import os
import numpy as N
import pylab as p

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.linearization import linearize_dae
from jmodelica.linearization import linear_dae_to_ode

int = N.int32
N.int = N.int32

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the DAE simulator. The
    result can be compared with that of sim_rlc.py which has solved the
    same problem using dymola. Also writes information to a file.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'RLC_Circuit'
    mofile = curr_dir+'/files/RLC_Circuit.mo'
    
    jmu_name = compile_jmu(model_name, mofile)
    model = JMUModel(jmu_name)
    init_res = model.initialize()

    (E_dae,A_dae,B_dae,F_dae,g_dae,state_names,input_names,algebraic_names, \
     dx0,x0,u0,w0,t0) = linearize_dae(init_res.model)
    
    (A_ode,B_ode,g_ode,H_ode,M_ode,q_ode) = linear_dae_to_ode(E_dae,A_dae,B_dae,F_dae,g_dae)

    sim_res1 = model.simulate()
    
    jmu_name = compile_jmu("RLC_Circuit_Linearized",mofile)
    lin_model = JMUModel(jmu_name)
    sim_res2 = lin_model.simulate()
    
    res1 = sim_res1.result_data
    c_v_1 = res1.get_variable_data('capacitor.v')
    i_p_i_1 = res1.get_variable_data('inductor.p.i')
    i_p1_i_1 = res1.get_variable_data('inductor1.p.i')
    
    res2 = sim_res2.result_data
    c_v_2 = res2.get_variable_data('x[1]')
    i_p_i_2 = res2.get_variable_data('x[2]')
    i_p1_i_2 = res2.get_variable_data('x[3]')

    assert N.abs(c_v_1.x[-1] - c_v_2.x[-1]) < 1e-3, \
           "Wrong value in simulation result in RLC_linearization.py"
    
    if with_plots:
        
        p.figure(1)
        p.hold(True)
        p.subplot(311)
        p.plot(c_v_1.t,c_v_1.x)
        p.plot(c_v_2.t,c_v_2.x,'g')
        p.ylabel('c.v')
        p.legend(('original model','linearized ODE'))
        p.grid()
        p.subplot(312)
        p.plot(i_p_i_1.t,i_p_i_1.x)
        p.plot(i_p_i_2.t,i_p_i_2.x,'g')
        p.ylabel('i.p.i')
        p.grid()
        p.subplot(313)
        p.plot(i_p1_i_1.t,i_p1_i_1.x)
        p.plot(i_p1_i_2.t,i_p1_i_2.x,'g')
        p.ylabel('i.p1.i')
        p.grid()
        p.show()
        
if __name__=="__main__":
    run_demo()
