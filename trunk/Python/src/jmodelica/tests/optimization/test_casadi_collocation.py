#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
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

"""Tests the casadi_collocation module."""

import os
import nose

import numpy as N
import pylab as P

from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica.io import ResultDymolaTextual
from jmodelica.examples import *

try:
    from jmodelica.optimization.casadi_collocation import *
    from jmodelica.casadi_interface import compile_casadi, CasadiModel
except NameError, ImportError:
    pass
    #logging.warning('Could not load Casadi collocation. Check jmodelica.check_packages()')

path_to_mos = os.path.join(get_files_path(), 'Modelica')

def assert_results(res, cost_ref, u_norm_ref, cost_places=4, norm_places = 5):
    """Helper function for asserting optimization results."""
    cost = float(res.solver.solver.output(casadi.NLP_COST))
    u = res["u"]
    u_norm = N.linalg.norm(u) / N.sqrt(len(u))
    nose.tools.assert_almost_equal(cost, cost_ref, cost_places)
    nose.tools.assert_almost_equal(u_norm, u_norm_ref, norm_places)

class TestRadau:
    
    """
    Tests jmodelica.optimization.casadi_collocation.RadauCollocator.
    """
    
    @classmethod
    def setUpClass(cls):
        """Compile the test models."""
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt2"
        compile_casadi(class_path, file_path)
        
    def setUp(self):
        """Load the test models."""
        JMU_VDP = 'VDP_pack_VDP_Opt2.jmu'
        self.model_VDP = CasadiModel(JMU_VDP)
    
    @testattr(casadi = True)
    def test_VDP(self):
        """Test optimizing the VDP using default options."""
        opts = self.model_VDP.optimize_options(algorithm="CasadiRadau")
        res = self.model_VDP.optimize(algorithm="CasadiRadau", options=opts)
        assert_results(res, 2.3469089e1, 2.872384555575e-1)
        
    @testattr(casadi = True)
    def test_init_traj(self):
        """Test optimizing the VDP based on an existing optimization reult."""
        opts = self.model_VDP.optimize_options(algorithm="CasadiRadau")
        opts['n_e'] = 30
        opts['n_cp'] = 3
        res = self.model_VDP.optimize(algorithm="CasadiRadau", options=opts)
        
        opts['n_e'] = 100
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_VDP.optimize(algorithm="CasadiRadau", options=opts)

class TestRadau2:
    
    """
    Tests jmodelica.optimization.casadi_collocation.Radau2Collocator.
    
    All tests are done on the VDP, except one test which specifically tests
    the CSTR.
    """
    
    @classmethod
    def setUpClass(cls):
        """Compile the test models."""
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Bounds_Lagrange"
        compile_casadi(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Bounds_Mayer"
        compile_casadi(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        class_path = "CSTR.CSTR_Opt_Bounds_Lagrange"
        compile_casadi(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        class_path = "CSTR.CSTR_Opt_Bounds_Mayer"
        compile_casadi(class_path, file_path)
    
    def setUp(self):
        """Load the test models."""
        JMU_VDP_Lagrange = 'VDP_pack_VDP_Opt_Bounds_Lagrange.jmu'
        self.model_VDP_Lagrange = CasadiModel(JMU_VDP_Lagrange)
        
        JMU_VDP_Mayer = 'VDP_pack_VDP_Opt_Bounds_Mayer.jmu'
        self.model_VDP_Mayer = CasadiModel(JMU_VDP_Mayer)
        
        JMU_CSTR_Lagrange = "CSTR_CSTR_Opt_Bounds_Lagrange.jmu"
        self.model_CSTR_Lagrange = CasadiModel(JMU_CSTR_Lagrange)
        
        JMU_CSTR_Mayer = "CSTR_CSTR_Opt_Bounds_Mayer.jmu"
        self.model_CSTR_Mayer = CasadiModel(JMU_CSTR_Mayer)
        
        self.algorithm = "CasadiRadau2"
    
    @testattr(casadi = True)
    def test_init_traj(self):
        """Test optimizing based on an existing optimization reult."""
        opts = self.model_VDP_Mayer.optimize_options("CasadiRadau2")
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 2.36076704795e1, 2.8099726741e-1)
        
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 2.346018464586e1, 2.84860645767e-1)
        
    @testattr(casadi = True)
    def test_CSTR_Mayer_and_Lagrange(self):
        """Test the CSTR with both Mayer and Lagrange costs."""
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.0556730059e2
        
        # Mayer
        opts = self.model_CSTR_Mayer.optimize_options("CasadiRadau2")
        res = self.model_CSTR_Mayer.optimize("CasadiRadau2", opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Lagrange
        res = self.model_CSTR_Lagrange.optimize("CasadiRadau2", opts)
        assert_results(res, cost_ref, u_norm_ref, cost_places=0, norm_places=0)
    
    @testattr(casadi = True)
    def test_element_lengths(self):
        """Test non-uniformly distributed elements."""
        opts = self.model_VDP_Mayer.optimize_options("CasadiRadau2")
        opts['n_e'] = 23
        opts['hs'] = (4 * [0.01] + 2 * [0.05] + 10 * [0.02] + 5 * [0.02] + 
                     2 * [0.28])
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 2.34597852302e1, 3.707273887662e-1)
    
    @testattr(casadi = True)
    def test_free_element_lengths(self):
        """Test optimized element lengths with both result modes."""
        # References values
        cost_ref = 2.343240065531e1
        u_norm_ref = 2.630846391607e-1
        
        # Collocation points
        opts = self.model_VDP_Lagrange.optimize_options("CasadiRadau2")
        opts['hs'] = "free"
        opts['result_mode'] = "collocation_points"
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Element interpolation
        opts['result_mode'] = "element_interpolation"
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, norm_places=2)
    
    @testattr(casadi = True)
    def test_result_mode(self):
        """
        Test the two different result modes.
        
        The difference between the trajectories of the two result modes should
        be very small if n_e * n_cp is sufficiently large. This is tested.
        """
        # References values
        cost_ref = 2.345988962015e1
        u_norm_ref = 2.84538707322e-1
        
        # Collocation points
        opts = self.model_VDP_Lagrange.optimize_options("CasadiRadau2")
        opts['n_e'] = 100
        opts['n_cp'] = 5
        opts['result_mode'] = "collocation_points"
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Element interpolation
        opts['result_mode'] = "element_interpolation"
        opts['n_eval_points'] = 15
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, 4, 3)
    
    @testattr(casadi = True)
    def test_blocking_factors(self):
        """Test blocking factors."""
        opts = self.model_VDP_Mayer.optimize_options("CasadiRadau2")
        opts['n_cp'] = 3
        opts['blocking_factors'] = opts['n_e'] * [1]
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 2.8169280267e1, 2.997111577228e-1,
                       cost_places=1, norm_places=1)
        
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['blocking_factors'] = [1, 2, 1, 1, 2, 13]
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 6.939387678875e1, 4.1528861933309e-1,
                       cost_places=1, norm_places=1)
    
    @testattr(casadi = True)
    def test_state_cont_var(self):
        """
        Test that results are consistent regardless of state_cont_var.
        """
        # References values
        cost_ref = 2.3469088662e1
        u_norm_ref = 2.8723846121e-1
        
        # With state continuity variables
        opts = self.model_VDP_Mayer.optimize_options("CasadiRadau2")
        opts["state_cont_var"] = True
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Without state continuity variables
        opts["state_cont_var"] = False
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_n_cp(self):
        """
        Test varying n_e and n_cp.
        """
        opts = self.model_VDP_Mayer.optimize_options("CasadiRadau2")
        
        # n_cp = 1
        opts['n_e'] = 100
        opts['n_cp'] = 1
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 1.906718422888e1, 2.56751074502e-1)
        
        # n_cp = 3
        opts['n_e'] = 50
        opts['n_cp'] = 3
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 2.3469088662e1, 2.8723846121e-1)
        
        # n_cp = 8
        opts['n_e'] = 20
        opts['n_cp'] = 8
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        assert_results(res, 2.3469088662e1, 2.803233e-1)
        
    @testattr(casadi = True)
    def test_graphs_and_exact_Hessian(self):
        """
        Test that results are consistent regardless of graph and exact_Hessian.
        """
        # References values
        cost_ref = 2.3384921684583301e1
        u_norm_ref = 2.8227471021520e-1
        
        # Solve problem to get initialization trajectory
        opts = self.model_VDP_Lagrange.optimize_options("CasadiRadau2")
        opts['n_e'] = 20
        opts['n_cp'] = 4
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        
        assert_results(res, cost_ref, u_norm_ref)
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        
        # SX with exact Hessian
        opts['graph'] = "SX"
        opts['exact_Hessian'] = True
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # SX without exact Hessian
        opts['exact_Hessian'] = False
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # expanded_MX with exact Hessian
        opts['graph'] = "expanded_MX"
        opts['exact_Hessian'] = True
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref, 6, 7)
        
        # expanded_MX without exact Hessian
        opts['exact_Hessian'] = False
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
        assert_results(res, cost_ref, u_norm_ref, 5, 6)
        
        # MX with exact Hessian
        opts['graph'] = "MX"
        opts['exact_Hessian'] = True
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref, 6, 7)
        
        # MX without exact Hessian
        opts['exact_Hessian'] = False
        res = self.model_VDP_Lagrange.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.85 * sol_without)
        assert_results(res, cost_ref, u_norm_ref, 5, 6)
        
    @testattr(casadi = True)
    def test_CasADi_option(self):
        """
        Test the CasADi option numeric_jacobian.
        """
        # References values
        cost_ref = 2.34690886624e1
        u_norm_ref = 2.8723845558898e-1
        
        # numeric_jacobian = True
        opts = self.model_VDP_Mayer.optimize_options("CasadiRadau2")
        opts['CasADi_options_G']['numeric_jacobian'] = True
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # numeric_jacobian = False
        opts['CasADi_options_G']['numeric_jacobian'] = False
        res = self.model_VDP_Mayer.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_without < 0.7 * sol_with)
        assert_results(res, cost_ref, u_norm_ref, cost_places=2, norm_places=3)

class TestPseudoSpectral:
    
    """
    Tests jmodelica.optimization.casadi_collocation.PseudoSpectral.
    """
    
    @classmethod
    def setUpClass(cls):
        """Compile the test models."""
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt2"
        compile_casadi(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'TwoState.mop')
        class_path = "TwoState"
        compile_casadi(class_path, file_path)
    
    def setUp(self):
        """Load the test models."""
        JMU_VDP = 'VDP_pack_VDP_Opt2.jmu'
        self.model_VDP = CasadiModel(JMU_VDP)
        
        JMU_two_state = 'TwoState.jmu'
        self.model_two_state = CasadiModel(JMU_two_state)
    
    @testattr(casadi = True)
    def test_two_state(self):
        """Tests the different discretization on the TwoState example."""
        opts = self.model_two_state.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 30
                
        #Test LG points
        opts['discr'] = "LG"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
    
    @testattr(casadi = True)
    def test_two_state_init_traj(self):
        """
        Tests that the option init_traj is functional.
        
        NOTE: SHOULD ALSO TEST THAT THE NUMBER OF ITERATIONS SHOULD BE SMALLER.
        """
        opts = self.model_two_state.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 30
        opts['discr'] = "LG"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)

        #Test LG points
        opts['discr'] = "LG"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectral",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
    
    @testattr(casadi = True)
    def test_doubleintegrator(self):
        """Tests the different discretization on the DoubleIntegrator example."""
        
        """
        UNCOMMENT WHEN FREE TIME HAVE BEEN FIXED!!!
        
        jn = compile_casadi("DoubleIntegrator", os.path.join(path_to_mos,"DoubleIntegrator.mop"))
        VDP = CasadiModel(jn)
        
        opts = VDP.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 8
        opts['n_cp'] = 5
                
        #Test LG points
        opts['discr'] = "LG"
        res = VDP.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = VDP.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        #Test LGL points
        opts['discr'] = "LGL"
        res = VDP.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        
        """
        
    @testattr(casadi = True)
    def test_VDP(self):
        """Tests the different discretization options on a modified VDP."""
        opts = self.model_VDP.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 60
        
        #Test LG points
        opts['discr'] = "LG"
        res = self.model_VDP.optimize(algorithm="CasadiPseudoSpectral",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_VDP.optimize(algorithm="CasadiPseudoSpectral",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = self.model_VDP.optimize(algorithm="CasadiPseudoSpectral",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        """
        opts['n_e'] = 20
        opts['n_cp'] = 6
        
        #Test LG points
        opts['discr'] = "LG"
        res = VDP.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = VDP.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = VDP.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        """
