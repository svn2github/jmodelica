#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2016 Modelon AB
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

"""Tests the static_optimization module."""

import os
import nose

from collections import OrderedDict
import numpy as N
from scipy.io.matlab.mio import loadmat

from tests_jmodelica import testattr, get_files_path
from pyjmi.common.io import ResultDymolaTextual
from pymodelica import compile_fmu
from pyfmi import load_fmu
try:
    from pyjmi import transfer_to_casadi_interface
    from pyjmi.optimization.static_optimization import *
    import casadi
except (NameError, ImportError):
    pass

from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError
#Check to see if pyfmi is installed so that we also catch the error generated
#from that package
try:
    from pyfmi.common.io import VariableNotFoundError as fmiVariableNotFoundError
    VariableNotFoundError = (jmiVariableNotFoundError, fmiVariableNotFoundError)
except ImportError:
    VariableNotFoundError = jmiVariableNotFoundError

path_to_mos = os.path.join(get_files_path(), 'Modelica')
path_to_data = os.path.join(get_files_path(), 'Data')

class TestStaticOptimizer(object):
    
    """
    Tests pyjmi.optimization.static_optimization.StaticOptimizer.
    """
    
    @classmethod
    def setUpClass(self):
        """Compile the test models."""
        sp_file_path = os.path.join(get_files_path(), 'Modelica', 'StaticProblem.mop')
        class_path = "StaticProblem"
        fmu_sp_sim = compile_fmu(class_path, sp_file_path, separate_process=True)
        self.sp_model = load_fmu(fmu_sp_sim)
        
        class_path = "StaticProblemControl"
        self.sp_op_control = transfer_to_casadi_interface(class_path, sp_file_path)
        
        class_path = "StaticProblemBound"
        self.sp_op_bound = transfer_to_casadi_interface(class_path, sp_file_path)
        
        class_path = "StaticProblemConstraint"
        self.sp_op_constraint = transfer_to_casadi_interface(class_path, sp_file_path)
        
        class_path = "StaticProblemEst"
        self.sp_op_est = transfer_to_casadi_interface(class_path, sp_file_path)
        
        self.algorithm = "StaticOptimizationAlg"

    @testattr(casadi = True)
    def test_control(self):
        """
        Test basic static control.
        """
        op = self.sp_op_control
        res = op.optimize(algorithm=self.algorithm)
        N.testing.assert_allclose([res['y'], res['u']], [[0.5], [5.6568]], rtol=1e-3)

    @testattr(casadi = True)
    def test_sp_bound_and_constraint(self):
        """
        Test consistency between bounds and constraint.
        """
        op_constraint = self.sp_op_constraint
        op_bound = self.sp_op_bound

        opts = op_constraint.optimize_options(algorithm=self.algorithm)
        eliminated = OrderedDict()
        eliminated['u'] = 5.5
        sed = StaticExternalData(eliminated=eliminated)
        opts['external_data'] = sed
        
        res_constraint = op_constraint.optimize(options=opts, algorithm=self.algorithm)
        res_bound = op_bound.optimize(options=opts, algorithm=self.algorithm)
        N.testing.assert_allclose([res_constraint['y'], res_constraint['p']], [[0.6], [2.33724079]], rtol=1e-3)
        N.testing.assert_allclose([res_bound['y'], res_bound['p']],
                                  [res_constraint['y'], res_constraint['p']], rtol=1e-3)

    @testattr(casadi = True)
    def test_sp_est(self):
        """
        Test multiple expriments.
        """
        op = self.sp_op_est
        model = self.sp_model
        opts = op.optimize_options(algorithm=self.algorithm)
        opts['IPOPT_options']['linear_solver'] = "ma27"
        eliminated = OrderedDict()

        # Define experiment input and outputs
        u = N.array([1., 2., 3., 4., 5.])
        eliminated['u'] = u
        quad_pen = OrderedDict()
        y_exact = 1 / u**0.4 
        y = y_exact + N.array([0.02, -0.04, 0.06, -0.08, 0.1])
        quad_pen['y'] = y
        Q = 5 * [1.]
        sed = StaticExternalData(Q=Q, eliminated=eliminated, quad_pen=quad_pen)
        opts['external_data'] = sed

        # Simulate to get initial guesses
        init_guess = []
        for u_val in u:
            model.set('u', u_val)
            init_guess.append(model.simulate(final_time=0.0))
            model.reset()
        opts['init_guess'] = init_guess

        # Solve and check result
        res = op.optimize(options=opts, algorithm=self.algorithm)
        N.testing.assert_allclose(res['y'], [1., 0.76837, 0.658618, 0.590393, 0.542379], rtol=1e-2)
        N.testing.assert_allclose(res.initial('p'), 1.63070498, rtol=1e-3)
