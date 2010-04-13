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
import matplotlib

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.tests import get_example_path
from jmodelica.compiler import ModelicaCompiler
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer
from jmodelica import simulate
from jmodelica.linearization import *

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
    
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(mofile,model_name,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(model_name)

    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    (E_dae,A_dae,B_dae,F_dae,g_dae,state_names,input_names,algebraic_names, \
     dx0,x0,u0,w0,t0) = linearize_dae(model)
    
    (A_ode,B_ode,g_ode,H_ode,M_ode,q_ode) = linear_dae_to_ode(E_dae,A_dae,B_dae,F_dae,g_dae)

    (m1,res1) = simulate("RLC_Circuit",mofile)
    (m2,res2) = simulate("RLC_Circuit_Linearized",mofile)
    
    c_v_1 = res1.get_variable_data('capacitor.v')
    i_p_i_1 = res1.get_variable_data('inductor.p.i')
    i_p1_i_1 = res1.get_variable_data('inductor1.p.i')
    
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
