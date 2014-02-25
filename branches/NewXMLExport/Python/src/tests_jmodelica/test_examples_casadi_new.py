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

from tests_jmodelica import testattr
from pyjmi.examples import (ccpp_new, vdp_casadi_new, cstr_casadi_new,
                            qt_par_est_casadi_new)

@testattr(casadi = True)
def test_ccpp_new():
    """Run the new Combined Cycle Power Plant example."""
    ccpp_new.run_demo(False)

@testattr(casadi = True)
def test_vdp_casadi_new():
    """Run the new VDP CasADi example."""
    vdp_casadi_new.run_demo(False)

@testattr(casadi = True)
def test_cstr_casadi_new():
    """Run the new CSTR CasADi example."""
    cstr_casadi_new.run_demo(False)

@testattr(casadi = True)
def test_qt_par_casadi_new():
    """Run the new QT CasADi example."""
    qt_par_est_casadi_new.run_demo(False)
