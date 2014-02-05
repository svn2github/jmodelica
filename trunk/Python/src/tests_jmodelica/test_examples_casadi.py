#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2012 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
""" 
Test module for testing the CASADI examples. 
"""

from tests_jmodelica import testattr
from pyjmi.examples import *

#~ @testattr(casadi = True)
#~ def test_ccpp():
    #~ """Run the Combined Cycle Power Plant example."""
    #~ ccpp.run_demo(False)

@testattr(casadi = True)
def test_cstr_casadi():
    """Run the CSTR CasADi example."""
    cstr_casadi.run_demo(False)
    
@testattr(casadi = True)
def test_hohmann_transfer():
    """Run the Hohmann Transfer example using CsadiPseudoSpectral."""
    hohmann_transfer.run_demo(False)
    
@testattr(casadi = True)
def test_parameter_estimation_1_casadi():
    """Run the Parameter Estimation CasADi example."""
    parameter_estimation_1_casadi.run_demo(False)
    
@testattr(casadi = True)
def test_qt_par_est_casadi():
    """ Run quad tank parameter estimation CasADi example """
    qt_par_est_casadi.run_demo(False)
    
@testattr(casadi = True)
def test_vdp_casadi():
    """Run the VDP CasADi example."""
    vdp_casadi.run_demo(False)

@testattr(casadi = True)
def test_vdp_casadi_ps():
    """Run the VDP CasADi example using CasadiPseudoSpectral."""
    vdp_casadi_ps.run_demo(False)
