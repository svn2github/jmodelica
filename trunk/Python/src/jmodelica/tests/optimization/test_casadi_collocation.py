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
        """Test optimizing the VDP."""
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau")
        opts['n_e'] = 50
        opts['n_cp'] = 3
        res = self.model_vdp.optimize(algorithm="CasadiRadau", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 2.3469089e1, places=4)
        nose.tools.assert_almost_equal(u_norm, 2.872384555575e-1, places=5)
        
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
        
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
    
    @testattr(casadi = True)
    def test_state_cont_var(self):
        """
        Test that results are consistent regardless of state_cont_var.
        
        This test uses the result from the first optimization to initialize the
        next one.
        """
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        
        # With state continuity variables
        opts["state_cont_var"] = True
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        cost_with = res["cost"][-1]
        u = res["u"]
        u_norm_with = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost_with, 2.3469088662e1, places=4)
        nose.tools.assert_almost_equal(u_norm_with, 2.8723846121e-1, places=5)
        
        # Without state continuity variables
        opts["state_cont_var"] = False
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        cost_without = res["cost"][-1]
        u = res["u"]
        u_norm_without = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost_without, cost_with, places=4)
        nose.tools.assert_almost_equal(u_norm_without, u_norm_with, places=5)
    
    @testattr(casadi = True)
    def test_n_cp(self):
        """
        Test optimizing the VDP with varying n_e and n_cp.
        
        This test uses the result from one optimization to initialize the next
        one.
        """
        opts = self.model_vdp.optimize_options(algorithm="CasadiRadau2")
        
        # n_cp = 1
        opts['n_e'] = 100
        opts['n_cp'] = 1
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 1.906718422888e1, places=4)
        nose.tools.assert_almost_equal(u_norm, 2.56751074502e-1, places=5)
        
        # n_cp = 3
        opts['n_e'] = 50
        opts['n_cp'] = 3
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 2.3469088662e1, places=4)
        nose.tools.assert_almost_equal(u_norm, 2.8723846121e-1, places=5)
        
        # n_cp = 8
        opts['n_e'] = 20
        opts['n_cp'] = 8
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 2.3469088662e1, places=4)
        nose.tools.assert_almost_equal(u_norm, 2.803233e-1, places=5)
        
    def test_graphs(self):
        """
        Test optimizing the VDP with all three graph types.
        
        This test uses the result from one optimization to initialize the next
        one.
        
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
        nose.tools.assert_almost_equal(cost_SX, 2.388146259989e1, places=4)
        nose.tools.assert_almost_equal(u_norm_SX, 2.81668841597e-1, places=5)
        
        # expanded_MX
        opts['graph'] = "expanded_MX"
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost_exp_MX = res["cost"][-1]
        u = res["u"]
        u_norm_exp_MX = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost_exp_MX, cost_SX, places=6)
        nose.tools.assert_almost_equal(u_norm_exp_MX, u_norm_SX, places=7)
        
        # MX
        opts['graph'] = "MX"
        opts['init_traj'] = ResultDymolaTextual("VDP_pack_VDP_Opt2_result.txt")
        res = self.model_vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost_MX = res["cost"][-1]
        u = res["u"]
        u_norm_MX = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost_MX, cost_SX, places=6)
        nose.tools.assert_almost_equal(u_norm_MX, u_norm_SX, places=7)

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
