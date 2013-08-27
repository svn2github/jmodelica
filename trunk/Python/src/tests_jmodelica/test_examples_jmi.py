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
""" Test module for testing the examples.
 
"""

from tests_jmodelica import testattr
from pyjmi.examples import *

@testattr(stddist = True)
def test_ast_example():
    """ Test the ast_example example."""
    ast_example.run_demo(False)

@testattr(ipopt = True)
def test_bang_control():
    """ Test the bang_control example. """    
    bang_control.run_demo(False)

@testattr(stddist = True)
def test_blood_glucose():
    """ Test the blood_glucose example. """    
    blood_glucose.run_demo(False)
    
@testattr(ipopt = True)
def test_blood_glucose_opt():
    """ Test the blood_glucose_opt example. """    
    blood_glucose_opt.run_demo(False)
    
@testattr(ipopt = True)
def test_blood_glucose_opt_scaled():
    """ Test the blood_glucose_opt_scaled example. """    
    blood_glucose_opt_scaled.run_demo(False)
    
@testattr(ipopt = True)
def test_catalytic_cracking():
    """ Test the catalytic_cracking example. """    
    catalytic_cracking.run_demo(False)
    
@testattr(ipopt = True)
def test_catalyst_mixing():
    """ Test the catalyst_mixing example. """    
    catalyst_mixing.run_demo(False)
    
@testattr(ipopt = True)
def test_coloumb_friction():
    """ Test the coloumb_friction example. """
    coloumb_friction.run_demo(False)

@testattr(ipopt = True)
def test_cont_state():
    """ Test the cont_state example. """
    cont_state.run_demo(False)

@testattr(ipopt = True)
def test_crystallizer():
    """ Test the crystallizer example. """
    crystallizer.run_demo(False)

@testattr(ipopt = True)
def test_cstr():
    """ Test the cstr example. """
    cstr.run_demo(False)

@testattr(slow = True)
def test_cstr_mpc():
    """ Test the cstr_mpc example. """    
    cstr_mpc.run_demo(False)

@testattr(ipopt = True)
def test_cstr2():
    """ Test the cstr2 example. """
    cstr2.run_demo(False)
    
@testattr(ipopt = True)
def test_dist1_init_sim():
    """ Test the dist1_init_sim example. """
    dist1_init_sim.run_demo(False)
    
@testattr(ma27 = True)
def test_distillation():
    """ Test the distillation example. """  
    distillation.run_demo(False)

@testattr(ma27 = True)
def test_distillation1_opt():
    """ Test the distillation1_opt example. """
    distillation1_opt.run_demo(False)
    
@testattr(ipopt = True)
def test_lagrange_cost():
    """ Test the Lagrange cost example """    
    lagrange_cost.run_demo(False)
    
@testattr(stddist = True)
def test_leadtransport():
    """ Run the Lead example """
    leadtransport.run_demo(False)
    
@testattr(ipopt = True)
def test_moon_lander():
    """ Test the moon_lander example. """    
    moon_lander.run_demo(False)    
    
@testattr(ipopt = True)
def test_parameter_estimation_1():
    """ Test the parameter_estimation_1 example """
    parameter_estimation_1.run_demo(False) 
    
@testattr(ipopt = True)
def test_pendulum():
    """ Test the pendulum example """
    pendulum.run_demo(False)

@testattr(ipopt = True)
def test_qt_par_est():
    """ Run parameter estimation example """
    qt_par_est.run_demo(False)

@testattr(ipopt = True)
def test_quadtank():
    """ Test the quadtank example """
    quadtank.run_demo(False)

@testattr(ipopt = True)
def test_quadtank_static_opt():
    """ Test the quadtank static optimization example """
    quadtank_static_opt.run_demo(False)

@testattr(stddist = True)
def test_rlc_linearization():
    """ Test that linearization of the RLC circuit works. """    
    RLC_linearization.run_demo(False)
    
@testattr(ipopt = True)
def test_vdp():
    """ Test the vdp example """
    vdp.run_demo(False)

@testattr(ipopt = True)
def test_vdp_minimum_time():
    """ Test the vdp_minimum_time example """
    vdp_minimum_time.run_demo(False)
    
@testattr(ipopt = True)
def test_vdp_minimum_time_interpolation():
    """ Test the vdp_minimum_time_interpolation example """
    vdp_minimum_time_interpolation.run_demo(False)
    
@testattr(stddist = True)
def bounds_kinsol_example():
    """ Test the bounds_kinsol example."""
    bounds_kinsol.run_demo(False)
