#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
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
import platform

from tests_jmodelica import testattr
# Will catch import errors in the examples.
try:
    from pyjmi.examples import (ccpp, vdp_casadi, vdp_minimum_time_casadi,
                            cstr_casadi, qt_par_est_casadi, vehicle_turn,
                            distillation4_opt, cstr_mpc_casadi, ccpp_elimination)
except (NameError, ImportError):
    pass

@testattr(casadi = True)
def test_ccpp():
    """Run the Combined Cycle Power Plant example."""
    ccpp.run_demo(False)

@testattr(casadi = True)
def test_vdp_casadi():
    """Run the VDP CasADi example."""
    vdp_casadi.run_demo(False)

@testattr(casadi = True)
def test_vdp_minimum_time_casadi():
    """Run the VDP CasADi minimum time example."""
    vdp_minimum_time_casadi.run_demo(False)

@testattr(casadi = True)
def test_cstr_casadi():
    """Run the CSTR CasADi example."""
    cstr_casadi.run_demo(False)

@testattr(casadi = True)
def test_qt_par_casadi():
    """Run the QT CasADi example."""
    qt_par_est_casadi.run_demo(False)

@testattr(ma27 = True)
def test_vehicle_turn():
    """Run the vehicle turn example."""
    vehicle_turn.run_demo(False)
    
@testattr(ma27 = True)
def test_distillation4_opt():
    """Run the large istillation optimization example."""
    distillation4_opt.run_demo(False)
    
@testattr(ma27 = True)
def test_cstr_mpc_casadi():
    """Run the cstr mpc optimization example."""
    cstr_mpc_casadi.run_demo(False)

@testattr(casadi = True)
def test_ccpp_variable_elimination():
    """Run the Combined Cycle Power Plant example."""
    ccpp.run_demo(False)
    

