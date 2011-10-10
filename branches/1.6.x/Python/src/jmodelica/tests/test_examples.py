""" Test module for testing the examples.
 
"""

from jmodelica.tests import testattr
from jmodelica.examples import *


@testattr(ipopt = True)
def test_parameter_estimation_1():
    """
    Test the parameter_estimation_1 example
    """
    parameter_estimation_1.run_demo(False)   

@testattr(ipopt = True)
def test_vdp():
    """
    Test the vdp example
    """
    vdp.run_demo(False)

@testattr(ipopt = True)
def test_vdp_minimum_time():
    """
    Test the vdp_minimum_time example
    """
    vdp_minimum_time.run_demo(False)

@testattr(ipopt = True)
def test_quadtank():
    """
    Test the quadtank example
    """
    quadtank.run_demo(False)

@testattr(ipopt = True)
def test_quadtank_static_opt():
    """
    Test the quadtank static optimization example
    """
    quadtank_static_opt.run_demo(False)

@testattr(assimulo = True)
def test_cstr():
    """
    Test the cstr example
    """
    cstr.run_demo(False)

@testattr(ipopt = True)
def test_pendulum():
    """
    Test the pendulum example
    """
    pendulum.run_demo(False)
    
@testattr(slow = True)
def test_cstr_mpc():
    """ Test the cstr_mpc example. """    
    cstr_mpc.run_demo(False)

@testattr(ipopt = True)
def test_cstr2():
    """ Test the cstr2 example. """   
    cstr2.run_demo(False)

@testattr(slow = True)
def test_distillation():
    """ Test the distillation example. """  
    distillation.run_demo(False)
    
@testattr(assimulo = True)
def test_if_example_1():
    """ Test the if_example_1 example. """    
    if_example_1.run_demo(False)

@testattr(assimulo = True)
def test_if_example_2():
    """ Test the if_example_2 example. """    
    if_example_2.run_demo(False)
    
@testattr(assimulo = True)
def test_RLC():
    """ Test the RLC example. """    
    RLC.run_demo(False)

@testattr(assimulo = True)
def test_simulation_with_input():
    """ Test the simulation_with_input example. """    
    simulation_with_input.run_demo(False)

@testattr(assimulo = True)
def test_rlc_linearization():
    """ Test that linearization of the RLC circuit works. """    
    RLC_linearization.run_demo(False)

@testattr(fmi = True)
def test_fmi_bouncing_ball_raw():
    """ Test that the FMI bouncing ball example works """    
    fmi_bouncing_ball_native.run_demo(False)

@testattr(ipopt = True)
def test_lagrange_cost():
    """ Test the Lagrange cost example """    
    lagrange_cost.run_demo(False)

@testattr(assimulo = True)
def test_fmi_bouncing_ball():
    """ Test that the FMI bouncing ball using the high-level simulate works. """
    fmi_bouncing_ball.run_demo(False)

@testattr(assimulo = True)
def test_extfunctions():
    """ Test of simulation with external functions. """
    extfunctions.run_demo(False)
    
@testattr(windows = True)
def test_extfunctions_arrays():
    """ Test of simulation with external functions using array input. """
    extFunctions_arrays.run_demo(False)
    
@testattr(windows = True)
def test_extfunctions_matrix():
    """ Test of simulation with external functions using matrix input and output. """
    extFunctions_matrix.run_demo(False)

@testattr(assimulo = True)
def test_distillation_fmu():
    """ Test of simulation of the distillation column using the FMU export. """
    distillation_fmu.run_demo(False)

@testattr(ipopt = True)
def test_qt_par_est():
    """ Run parameter estimation example """
    qt_par_est.run_demo(False)

@testattr(windows = True)
def test_fmu_with_input():
    """ Run FMU with input example. """
    fmu_with_input.run_demo(False)

@testattr(assimulo = True)
def test_planar_pendulum():
    """ Run planar pendulum example """
    planar_pendulum.run_demo(False)

@testattr(assimulo = True)
def test_mechanics_rotational_examples_first():
    """ Run mechanics high index example from MSL """
    mechanical_rotational_examples_first.run_demo(False)

@testattr(assimulo = True)
def test_crane():
    """ Run the PyMBS example """
    crane.run_demo(False)
    
@testattr(assimulo = True)
def test_leadtransport():
    """ Run the Lead example """
    leadtransport.run_demo(False)
    
@testattr(casadi = True)
def test_cstr_casadi():
    """Run the CSTR CasADi example."""
    cstr_casadi.run_demo(False)
    
@testattr(casadi = True)
def test_cstr_casadi():
    """Run the VDP CasADi example."""
    vdp_casadi.run_demo(False)
    
@testattr(casadi = True)
def test_parameter_estimation_1_casadi():
    """Run the Parameter Estimation CasADi example."""
    parameter_estimation_1_casadi.run_demo(False, algorithm="CasadiRadau")
    
@testattr(casadi = True)
def test_cstr_casadi_radau2():
    """Run the CSTR CasADi example using CasadiRadau2."""
    cstr_casadi_radau2.run_demo(False)
    
@testattr(casadi = True)
def test_vdp_casadi_radau2():
    """Run the VDP CasADi example using CasadiRadau2."""
    vdp_casadi_radau2.run_demo(False)

@testattr(casadi = True)
def test_parameter_estimation_1_casadi_radau2():
    """Run the Parameter Estimation CasADi example using CasadiRadau2."""
    parameter_estimation_1_casadi.run_demo(False, algorithm="CasadiRadau2")
    
@testattr(casadi = True)
def test_vdp_casadi_ps():
    """Run the VDP CasADi example using CasadiPseudoSpectral."""
    vdp_casadi_ps.run_demo(False)
