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
        opts['n_e'] = 50
        opts['n_cp'] = 3
        opts['blocking_factors'] = opts['n_e'] * [1]
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 2.81692892672e1, 2.997111577228e-1)
        
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['blocking_factors'] = [1, 2, 1, 1, 2, 13]
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, 6.9393876378875e1, 4.1528861933309e-1)
    
    @testattr(casadi = True)
    def test_state_cont_var(self):
        """
        Test that results are consistent regardless of state_cont_var.
        """
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        
        # With state continuity variables
        opts["state_cont_var"] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        cost_with = res["cost"][-1]
        u = res["u"]
        u_norm_with = N.linalg.norm(u) / N.sqrt(len(u))
        assert_results(res, 2.3469088662e1, 2.8723846121e-1)
        
        # Without state continuity variables
        opts["state_cont_var"] = False
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_with, u_norm_with)
    
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
        Test optimizing the VDP with all three graph types.
        
        Once https://trac.modelon.se/P420-JModelica-CasadiCollocation/ticket/15
        has been resolved, change this test to use the CSTR instead, in order
        to vary the test cases.
        """
        # SX
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['n_e'] = 30
        opts['n_cp'] = 2
        opts['graph'] = "SX"
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost_SX = res["cost"][-1]
        u = res["u"]
        u_norm_SX = N.linalg.norm(u) / N.sqrt(len(u))
        assert_results(res, 2.388146259989e1, 2.81668841597e-1)
        
        # expanded_MX
        opts['graph'] = "expanded_MX"
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_SX, u_norm_SX, 6, 7)
        
        # MX
        opts['graph'] = "MX"
        opts['exact_hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_SX, u_norm_SX, 5, 6)
        
    @testattr(casadi = True)
    def test_exact_hessian(self):
        """
        Test optimizing the VDP with and without exact Hessian for all graphs.
        
        Since exact Hessian is not supported by MX graphs, this only tests SX
        and expanded_MX. This should be changed when it's also supported for
        MX.
        """
        # SX with exact Hessian
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['graph'] = "SX"
        opts['exact_hessian'] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost_SX_with = res["cost"][-1]
        u = res["u"]
        u_norm_SX_with = N.linalg.norm(u) / N.sqrt(len(u))
        assert_results(res, 2.3384921684583301e1, 2.8227471021520e-1)
        
        # SX without exact Hessian
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        opts['exact_hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_SX_with, u_norm_SX_with)
        
        # expanded_MX with exact Hessian
        opts['graph'] = "expanded_MX"
        opts['exact_hessian'] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_SX_with, u_norm_SX_with, 6, 7)
        
        # expanded_MX without exact Hessian
        opts['exact_hessian'] = False
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        assert_results(res, cost_SX_with, u_norm_SX_with, 5, 6)

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
