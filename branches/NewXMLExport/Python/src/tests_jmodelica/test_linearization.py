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

""" Test module for testing the linearize module
"""

import os
import os.path

import numpy as N
import nose

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_jmu
from pyjmi.jmi import JMUModel
from pyjmi.optimization import ipopt
from pyjmi.linearization import *
from pyjmi.initialization.ipopt import NLPInitialization
from pyjmi.initialization.ipopt import InitializationOptimizer


fpath = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
cpath = "CSTR.CSTR_Opt"
fname = cpath.replace('.','_',1)

class TestLinearization:


    def setup(self):
        """ 
        Setup test module. Compile test model (only needs to be done once) and 
        set log level. 
        """
        compile_jmu(cpath, fpath, compiler_options={'state_start_values_fixed':True})


    @testattr(ipopt = True)
    def test_linearization(self):
        
        # Load the dynamic library and XML data
        model = JMUModel(fname+'.jmu')

        # Create DAE initialization object.
        init_nlp = NLPInitialization(model)
        
        # Create an Ipopt solver object for the DAE initialization system
        init_nlp_ipopt = InitializationOptimizer(init_nlp)
            
        # Solve the DAE initialization system with Ipopt
        init_nlp_ipopt.init_opt_ipopt_solve()

        (E_dae,A_dae,B_dae,F_dae,g_dae,state_names,input_names,algebraic_names, \
         dx0,x0,u0,w0,t0) = linearize_dae(model)
        
        (A_ode,B_ode,g_ode,H_ode,M_ode,q_ode) = linear_dae_to_ode(E_dae,A_dae,B_dae,F_dae,g_dae)

        (A_ode2,B_ode2,g_ode2,H_ode2,M_ode2,q_ode2,state_names2,input_names2,algebraic_names2, \
         dx02,x02,u02,w02,t02) = linearize_ode(model)

        N.testing.assert_array_almost_equal(A_ode, A_ode2, err_msg="Error in linearization: A_ode.")
        N.testing.assert_array_almost_equal(B_ode, B_ode2, err_msg="Error in linearization: B_ode.")
        N.testing.assert_array_almost_equal(g_ode, g_ode2, err_msg="Error in linearization: g_ode.")
        N.testing.assert_array_almost_equal(H_ode, H_ode2, err_msg="Error in linearization: H_ode.")
        N.testing.assert_array_almost_equal(M_ode, M_ode2, err_msg="Error in linearization: M_ode.")
        N.testing.assert_array_almost_equal(q_ode, q_ode2, err_msg="Error in linearization: q_ode.")
        assert (state_names==state_names2)==True
        assert (input_names==input_names2)==True
        assert (algebraic_names==algebraic_names2)==True

        small = 1e-4
        assert (N.abs(A_ode-N.array([[ -0.00000000e+00,   1.00000000e+03,   6.00000000e+01],
     [ -0.00000000e+00,  -1.66821993e-02,  -1.19039519e+00],
     [ -0.00000000e+00,   3.48651310e-03,   2.14034026e-01]]))<=small).all()==True
        assert (N.abs(B_ode-N.array([[  1.00000000e+02],
     [ -0.00000000e+00],
     [  3.49859575e-02]]))<=small).all()==True
        assert (N.abs(g_ode-N.array([[-0.],
     [-0.],
     [-0.]]))<=small).all()==True

        assert N.abs(E_dae-N.array(([[-1.,  0.,  0.],
     [ 0., -1.,  0.],
     [ 0.,  0., -1.]]))<=small).all()==True
        assert (N.abs(A_dae-N.array([[ -0.00000000e+00,  -1.00000000e+03,  -6.00000000e+01],
     [ -0.00000000e+00,   1.66821993e-02,   1.19039519e+00],
     [ -0.00000000e+00,  -3.48651310e-03,  -2.14034026e-01]]))<=small).all()==True
        assert (N.abs(B_dae-N.array([[ -1.00000000e+02],
     [ -0.00000000e+00],
     [ -3.49859575e-02]]))<=small).all()==True
        assert (N.abs(g_dae-N.array([[-0.],
     [-0.],
     [-0.]]))<=small).all()==True

        assert (state_names==['cost', 'cstr.c', 'cstr.T'])==True
        assert (input_names==['u'])==True
        assert (algebraic_names==[])==True

