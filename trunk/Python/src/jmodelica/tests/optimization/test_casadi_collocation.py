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
    
    """This class tests the class CasadiRadau."""
    
    @testattr(casadi = True)
    def test_radau_vdp(self):
        """Test optimizing the VDP."""
        jn = compile_casadi("VDP_pack.VDP_Opt2",
                            os.path.join(path_to_mos, "VDP.mop"))
        print(os.path.join(path_to_mos, "VDP.mop"))
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options(algorithm="CasadiRadau")
        opts['n_e'] = 50
        opts['n_cp'] = 3
        res = vdp.optimize(algorithm="CasadiRadau", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 2.3469089e1, places=3)
        nose.tools.assert_almost_equal(u_norm, 2.872384555575e-1, places=3)
    
    @testattr(casadi = True)
    def test_radau_cstr_example(self):
        """Test the cstr_casadi example."""
        cstr_casadi.run_demo(with_plots=False, graph="SX")
        
    @testattr(casadi = True)
    def test_radau_vdp_example(self):
        """Test the vdp_casadi example."""
        vdp_casadi.run_demo(with_plots=False, graph="SX")
    
    @testattr(casadi = True)
    def test_radau_pe_example(self):
        """Test the parameter_estimation_1_casadi example."""
        parameter_estimation_1_casadi.run_demo(with_plots=False,
                                               algorithm="CasadiRadau",
                                               graph="SX")

class TestRadau2:
    
    """This class tests the class CasadiRadau2."""
    
    @testattr(casadi = True)
    def test_radau2_vdp(self):
        """Test optimizing the VDP with varying n_e and n_cp."""
        jn = compile_casadi("VDP_pack.VDP_Opt2",
                            os.path.join(path_to_mos, "VDP.mop"))
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options(algorithm="CasadiRadau2")
        opts['graph'] = "SX"
        
        # n_cp = 1
        opts['n_e'] = 100
        opts['n_cp'] = 1
        res = vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"][1:]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 1.906718422888e1, places=3)
        nose.tools.assert_almost_equal(u_norm, 2.576417883844e-1, places=3)
        
        # n_cp = 3
        opts['n_e'] = 50
        opts['n_cp'] = 3
        res = vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"][1:]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 2.3469088662e1, places=3)
        nose.tools.assert_almost_equal(u_norm, 2.851435918954e-1, places=3)
        
        # n_cp = 8
        opts['n_e'] = 20
        opts['n_cp'] = 8
        res = vdp.optimize(algorithm="CasadiRadau2", options=opts)
        
        cost = res["cost"][-1]
        u = res["u"][1:]
        u_norm = N.linalg.norm(u) / N.sqrt(len(u))
        nose.tools.assert_almost_equal(cost, 2.3469088662e1, places=3)
        nose.tools.assert_almost_equal(u_norm, 2.7989115974e-1, places=3)
    
    @testattr(casadi = True)
    def test_radau2_cstr_example(self):
        """Test the cstr_casadi example."""
        cstr_casadi_radau2.run_demo(with_plots=False, graph="SX")
        
    @testattr(casadi = True)
    def test_radau2_vdp_example(self):
        """Test the vdp_casadi example using all 3 graph types."""
        vdp_casadi_radau2.run_demo(with_plots=False, graph="SX")
        vdp_casadi_radau2.run_demo(with_plots=False, graph="MX")
        vdp_casadi_radau2.run_demo(with_plots=False, graph="expanded_MX")
    
    @testattr(casadi = True)
    def test_radau2_pe_example(self):
        """Test the parameter_estimation_1_casadi example."""
        parameter_estimation_1_casadi.run_demo(with_plots=False,
                                               algorithm="CasadiRadau2",
                                               graph="SX")

class TestPseudoSpectral:
    
    """This class tests the class CasadiPseudoSpectral."""
    
    @testattr(casadi = True)
    def test_ps_twostate(self):
        """Tests the different discretization on the TwoState example."""
        
        jn = compile_casadi("TwoState", os.path.join(path_to_mos,"TwoState.mop"))
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 30
                
        #Test LG points
        opts['discr'] = "LG"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
    
    @testattr(casadi = True)
    def test_ps_twostate_inittraj(self):
        """
        Tests that the option init_traj is functional.
        
        NOTE: SHOULD ALSO TEST THAT THE NUMBER OF ITERATIONS SHOULD BE SMALLER.
        """
        
        jn = compile_casadi("TwoState", os.path.join(path_to_mos,"TwoState.mop"))
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 30
        opts['discr'] = "LG"
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        
        vdp = CasadiModel(jn)

        #Test LG points
        opts['discr'] = "LG"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
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
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
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
        res = vdp.optimize(algorithm="CasadiPseudoSpectral", options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
    
    @testattr(casadi = True)
    def test_ps_doubleintegrator(self):
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
    def test_ps_vdp(self):
        """Tests the different discretization options on a modified VDP."""
        
        jn = compile_casadi("VDP_pack.VDP_Opt2", os.path.join(path_to_mos,"VDP.mop"))
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options("CasadiPseudoSpectral")
        opts['n_e'] = 1
        opts['n_cp'] = 60
        
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
