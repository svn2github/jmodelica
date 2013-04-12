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
Test module for testing the SLOW examples.
"""
from tests_jmodelica import testattr
from pyfmi.examples import *
from pyjmi.examples import *

@testattr(slow = True)
def test_cstr_mpc():
    """ Test the cstr_mpc example. """    
    cstr_mpc.run_demo(False)
    
@testattr(ma27 = True)
def test_distillation():
    """ Test the distillation example. """  
    distillation.run_demo(False)
    
@testattr(slow = True)
def test_furuta_modified():
    """ Test the furuta_modified example. """
    furuta_modified.run_demo(False)

@testattr(slow = True)
def test_furuta_dfo():
    """ Test the furuta_dfo example. """
    furuta_dfo.run_demo(False)
