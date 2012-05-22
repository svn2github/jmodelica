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

"""
Test module for Jacobian evaluation using CAD in pyjmi.
"""

import os
import numpy as N
import numpy.linalg as lin
import nose

import pyjmi.jmi as jmi
from pymodelica.compiler import compile_jmu
from pyjmi.jmi import JMUModel
from tests_jmodelica import testattr, get_files_path

int = N.int32
N.int = N.int32

class Test_cad_std:
    """ Class which contains std tests for the cad module. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        pass
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass

    @testattr(stddist = True)
    def test_simulation(self):
        
        path = os.path.join(get_files_path(), 'Modelica', "VDP_pack.mo")
        
        jmu_name = compile_jmu("VDP_pack.VDP", path)
        model_cppad = JMUModel(jmu_name)
        sim_opts_cppad = model_cppad.simulate_options()
        sim_opts_cppad['initialize'] = False
        res_cppad = model_cppad.simulate(final_time=10, options = sim_opts_cppad)
        
        
        jmu_name = compile_jmu("VDP_pack.VDP", path, compiler_options={"generate_dae_jacobian":True}, target='model_noad')
        model_cad = JMUModel(jmu_name)
        sim_opts_cad = model_cad.simulate_options()
        sim_opts_cad['initialize'] = False
        res_cad = model_cad.simulate(final_time=10, options = sim_opts_cad)
        
        x1_cppad = model_cppad.get('x1')
        x2_cppad = model_cppad.get('x2')
        x1_cad = model_cad.get('x1')
        x2_cad = model_cad.get('x2')

        nose.tools.assert_almost_equal(lin.norm(x1_cppad-x1_cad)+lin.norm(x2_cppad-x2_cad),0)

    @testattr(stddist = True)
    def test_dependent_variables1(self):    
        """ Test evaluation of CAD with different dependent variables"""
        path = os.path.join(get_files_path(), 'Modelica', 'furuta.mo')
        
        u = 0.01
        
        jmu_name = compile_jmu("Furuta",path)
        model_cppad = JMUModel(jmu_name)
        model_cppad.set('u', u)
        
        jmu_name = compile_jmu("Furuta",path, compiler_options={"generate_dae_jacobian":True}, target='model_noad')
        model_cad = JMUModel(jmu_name)
        model_cad.set('u', u)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_U)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_1 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_1)
        jac_cppad_1 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_1)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_U)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_2 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_2)
        jac_cppad_2 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_2)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_X)

        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))        
        jac_cad_3 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_3)
        jac_cppad_3 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_3)
        
        FLAG = (jmi.JMI_DER_X, jmi.JMI_DER_U)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_4 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_4)
        jac_cppad_4 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_4)
        
        FLAG = (jmi.JMI_DER_DX)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_5 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_5)
        jac_cppad_5 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_5)
        
        FLAG = (jmi.JMI_DER_X)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_6 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_6)
        jac_cppad_6 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_6)
        
        FLAG = (jmi.JMI_DER_U)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_7 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_7)
        jac_cppad_7 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_7)
        
        sumarray= lin.norm(N.array([lin.norm(jac_cad_1-jac_cppad_1),lin.norm(jac_cad_2-jac_cppad_2),lin.norm(jac_cad_3-jac_cppad_3),lin.norm(jac_cad_4-jac_cppad_4),lin.norm(jac_cad_5-jac_cppad_5),lin.norm(jac_cad_6-jac_cppad_6),lin.norm(jac_cad_7-jac_cppad_7)]))
        nose.tools.assert_almost_equal(sumarray, 0)
        
    @testattr(stddist = True)
    def test_dependent_variables2(self):
        """ Test evaluation of CAD with different dependent variables after simulation. """
        path = os.path.join(get_files_path(), 'Modelica', 'DISTLib.mo')
        jmu_name = compile_jmu("DISTLib.Examples.Simulation", path)
        
        model_cppad = JMUModel(jmu_name)
        model_cppad.initialize()
        sim_opts_cppad = model_cppad.simulate_options()
        sim_opts_cppad['IDA_options']['verbosity'] = 0
        res_cppad = model_cppad.simulate(final_time=2, options = sim_opts_cppad)
        
        sim_opts_cppad['initialize'] = False
        model_cppad.initialize_from_data(res_cppad.result_data,0.0)
        model_cppad.jmimodel._sw[0] = 1.
        res_cppad = model_cppad.simulate(final_time=80, options = sim_opts_cppad)
        
        jmu_name = compile_jmu("DISTLib.Examples.Simulation", path, compiler_options={"generate_dae_jacobian":True}, target='model_noad')
        model_cad = JMUModel(jmu_name)
        
        sim_opts_cad = model_cad.simulate_options()
        sim_opts_cad['initialize'] = False
        model_cad.initialize_from_data(res_cppad.result_data,0.0)
        model_cad.jmimodel._sw[0] = 1.
        res_cad = model_cad.simulate(final_time=80, options = sim_opts_cad)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_W)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_1 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_1)
        jac_cppad_1 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_1)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_W)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_2 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_2)
        jac_cppad_2 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_2)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_X)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_3 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_3)
        jac_cppad_3 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_3)
        
        FLAG = (jmi.JMI_DER_X, jmi.JMI_DER_W)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_4 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_4)
        jac_cppad_4 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_4)
        
        FLAG = (jmi.JMI_DER_DX)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_5 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_5)
        jac_cppad_5 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_5)
        
        FLAG = (jmi.JMI_DER_X)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_6 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_6)
        jac_cppad_6 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_6)
        
        FLAG = (jmi.JMI_DER_W)
        
        n_var = len(model_cad.jmimodel.get_z())
        n_cols,n_z = model_cad.jmimodel.dae_dF_dim(jmi.JMI_DER_CAD, jmi.JMI_DER_SPARSE, FLAG , N.ones(n_var,dtype=int))
        jac_cad_7 = N.zeros(n_z)
        model_cad.jmimodel.dae_dF(jmi.JMI_DER_CAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cad_7)
        jac_cppad_7 = N.zeros(n_z)
        model_cppad.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,jmi.JMI_DER_SPARSE, FLAG,N.ones(n_var,dtype=int),jac_cppad_7)
        
        sumarray= lin.norm(N.array([lin.norm(jac_cad_1-jac_cppad_1),lin.norm(jac_cad_2-jac_cppad_2),lin.norm(jac_cad_3-jac_cppad_3),lin.norm(jac_cad_4-jac_cppad_4),lin.norm(jac_cad_5-jac_cppad_5),lin.norm(jac_cad_6-jac_cppad_6),lin.norm(jac_cad_7-jac_cppad_7)]))

        nose.tools.assert_almost_equal(sumarray, 0)
    
