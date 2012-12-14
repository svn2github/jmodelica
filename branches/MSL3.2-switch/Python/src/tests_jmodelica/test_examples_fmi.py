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
Test module for testing the FMI examples.
"""

from tests_jmodelica import testattr
from pyfmi.examples import *
from pyjmi.examples import *


@testattr(fmi = True)
def test_fmi_bouncing_ball_raw():
    """ Test that the FMI bouncing ball example works """    
    fmi_bouncing_ball_native.run_demo(False)
    
@testattr(assimulo = True)
def test_crane():
    """ Run the PyMBS example """
    crane.run_demo(False)
    
@testattr(assimulo = True)
def test_distillation_fmu():
    """ Test of simulation of the distillation column using the FMU export. """
    distillation_fmu.run_demo(False)
    
@testattr(assimulo = True)
def test_distillation1_fmu():
    """ Test the distillation1_fmu example. """    
    distillation1_fmu.run_demo(False)
    
@testattr(assimulo = True)
def test_distillation2_fmu():
    """ Test the distillation2_fmu example. """    
    distillation2_fmu.run_demo(False)
    
@testattr(assimulo = True)
def test_distillation4_fmu():
    """ Test the distillation4_fmu example. """    
    distillation4_fmu.run_demo(False)
    
@testattr(assimulo = True)
def test_fmi_bouncing_ball():
    """ Test that the FMI bouncing ball using the high-level simulate works. """
    fmi_bouncing_ball.run_demo(False) 
    
@testattr(windows = True)
def test_fmu_with_input():
    """ Run FMU with input example. """
    fmu_with_input.run_demo(False)
    
@testattr(assimulo = True)
def test_mechanics_rotational_examples_first():
    """ Run mechanics high index example from MSL """
    mechanical_rotational_examples_first.run_demo(False)
    
@testattr(assimulo = True)
def test_mechanics_rotational_examples_coupled_clutches():
    """ Run mechanics high index example from MSL """
    mechanical_rotational_examples_coupled_clutches.run_demo(False)
    
@testattr(assimulo = True)
def test_planar_pendulum():
    """ Run planar pendulum example """
    planar_pendulum.run_demo(False)
	
@testattr(assimulo = True)
def test_QR():
    """ Test the QR example. """    
    QR.run_demo(False)
    
@testattr(assimulo = True)
def test_bouncingball_cs_sim():
    """ Test the FMI Bouncing Ball CS 1.0 example. """    
    fmi_bouncing_ball_cs.run_demo(False)

@testattr(assimulo = True)
def test_robertson_sensitivity_fmu():
    """ Test the sensitivty example Robertson as an FMU. """
    robertson_fmu.run_demo(False)
