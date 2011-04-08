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
Test module for Jacobian evaluation using CAD in jmodelica.
"""

import os
import jmodelica.jmi as jmi
import numpy as N

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path

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
    def test_dependent_parameters(self):
        """ Test evaluation of CAD with different dependent variables. """
        path = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack_no_opt.mo')
        jmu_name = compile_jmu('Pendulum_pack.Pendulum', path, 
                               compiler_options={"generate_dae_jacobian":True},target='model_noad')
        model = JMUModel(jmu_name)
        
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_U)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_X)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'
        FLAG = (jmi.JMI_DER_DX, jmi.JMI_DER_U)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'
        FLAG = (jmi.JMI_DER_X, jmi.JMI_DER_U)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'
        FLAG = (jmi.JMI_DER_DX)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'
        FLAG = (jmi.JMI_DER_X)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'
        FLAG = (jmi.JMI_DER_U)
        n_var = len(model.jmimodel.get_z())
        assert (model.jmimodel.dae_derivative_checker(jmi.JMI_DER_SPARSE, FLAG, jmi.JMI_DER_CHECK_SCREEN_OFF, N.ones(n_var,dtype=int))) != 0, 'FD and CAD evaluation of the Jacobians differs'







