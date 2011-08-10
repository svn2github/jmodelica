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
    cost = res["cost"][-1]
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
        jmu_vdp = 'VDP_pack_VDP_Opt2.jmu'
        self.model_vdp = CasadiModel(jmu_vdp)
    
    @testattr(casadi = True)
    def test_vdp(self):
        """Test optimizing the VDP using default options."""
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau")
        res = self.model_vdp.optimize(algorithm="CasadiRadau", options=opts)
        assert_results(res, 2.3469089e1, 2.872384555575e-1)
        
    @testattr(casadi = True)
    def test_init_traj(self):
        """Test optimizing the VDP based on an existing optimization reult."""
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau")
        opts['n_e'] = 30
        opts['n_cp'] = 3
        res = self.model_vdp.optimize(algorithm="CasadiRadau", options=opts)
        
        opts['n_e'] = 100
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau", options=opts)

class TestRadau2:
    
    """
    Tests jmodelica.optimization.casadi_collocation.Radau2Collocator.
    """
    
    @classmethod
    def setUpClass(cls):
        """Compile the test models."""
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt2"
        compile_casadi(class_path, file_path)
        
    def setUp(self):
        """Load the test models."""
        jmu_vdp = 'VDP_pack_VDP_Opt2.jmu'
        self.model_vdp = CasadiModel(jmu_vdp)
    
    @testattr(casadi = True)
    def test_init_traj(self):
        """Test optimizing the VDP based on an existing optimization reult."""
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 2.36076704795e1, 2.8099726741e-1)
        
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 2.346018464586e1, 2.84860645767e-1)
        
    @testattr(casadi = True)
    def test_blocking_factors(self):
        """Test optimizing the VDP using blocking factors."""
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['n_e'] = 60
        opts['n_cp'] = 3
        opts['blocking_factors'] = opts['n_e'] * [1]
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 2.440785869906e1, 2.997111577228e-1,
                       cost_places=1, norm_places=1)
        
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['blocking_factors'] = [1, 2, 1, 1, 2, 13]
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 6.9557353378639e1, 4.1528861933309e-1,
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
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts["state_cont_var"] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        cost_with = res["cost"][-1]
        u = res["u"]
        u_norm_with = N.linalg.norm(u) / N.sqrt(len(u))
        assert_results(res, cost_ref, u_norm_ref)
        
        # Without state continuity variables
        opts["state_cont_var"] = False
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_n_cp(self):
        """
        Test optimizing the VDP with varying n_e and n_cp.
        """
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        
        # n_cp = 1
        opts['n_e'] = 100
        opts['n_cp'] = 1
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 1.906718422888e1, 2.56751074502e-1)
        
        # n_cp = 3
        opts['n_e'] = 50
        opts['n_cp'] = 3
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 2.3469088662e1, 2.8723846121e-1)
        
        # n_cp = 8
        opts['n_e'] = 20
        opts['n_cp'] = 8
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 2.3469088662e1, 2.803233e-1)
    
    @testattr(casadi = True)
    def test_graphs(self):
        """
        Test that results are consistent regardless of graph.
        
        The exact Hessian is currently not used for the MX graph test. Change
        this when https://sourceforge.net/apps/trac/casadi/ticket/164 has been
        fixed.
        
        Once https://trac.modelon.se/P420-JModelica-CasadiCollocation/ticket/15
        has been resolved, change this test to use the CSTR instead, in order
        to vary the test cases.
        """
        # References values
        cost_ref = 2.388146259989e1
        u_norm_ref = 2.81668841597e-1
        
        # SX
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['n_e'] = 30
        opts['n_cp'] = 2
        opts['graph'] = "SX"
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # expanded_MX
        opts['graph'] = "expanded_MX"
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX
        opts['graph'] = "MX"
        opts['exact_Hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_ref, u_norm_ref, cost_places=3, norm_places=4)
        
    @testattr(casadi = True)
    def test_exact_Hessian(self):
        """
        Test that results are consistent regardless of graph and exact_Hessian.
        """
        # References values
        cost_ref = 2.3384921684583301e1
        u_norm_ref = 2.8227471021520e-1
        
        # Solve problem to get initialization trajectory
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['n_e'] = 20
        opts['n_cp'] = 4
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        assert_results(res, cost_ref, u_norm_ref)
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        
        # SX with exact Hessian
        opts['graph'] = "SX"
        opts['exact_Hessian'] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # SX without exact Hessian
        opts['exact_Hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # expanded_MX with exact Hessian
        opts['graph'] = "expanded_MX"
        opts['exact_Hessian'] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref, 6, 7)
        
        # expanded_MX without exact Hessian
        opts['exact_Hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
        assert_results(res, cost_ref, u_norm_ref, 5, 6)
        
        # MX with exact Hessian
        opts['graph'] = "MX"
        opts['exact_Hessian'] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref, 6, 7)
        
        # MX without exact Hessian
        opts['exact_Hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
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
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['CasADi_options_G']['numeric_jacobian'] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # numeric_jacobian = False
        opts['CasADi_options_G']['numeric_jacobian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
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
        jmu_vdp = 'VDP_pack_VDP_Opt2.jmu'
        self.model_vdp = CasadiModel(jmu_vdp)
        
        jmu_two_state = 'TwoState.jmu'
        self.model_two_state = CasadiModel(jmu_two_state)
    
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
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 8
        opts['n_cp'] = 5
                
        #Test LG points
        opts['discr'] = "LG"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        #Test LGL points
        opts['discr'] = "LGL"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        
        """
        
    @testattr(casadi = True)
    def test_vdp(self):
        """Tests the different discretization options on a modified VDP."""
        opts = self.model_vdp.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 60
        
        #Test LG points
        opts['discr'] = "LG"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectral",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectral",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectral",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        """
        opts['n_e'] = 20
        opts['n_cp'] = 6
        
        #Test LG points
        opts['discr'] = "LG"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        """
