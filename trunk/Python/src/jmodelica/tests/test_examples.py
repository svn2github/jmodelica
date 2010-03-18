""" Test module for testing the examples.
 
"""

from jmodelica.tests import testattr
from jmodelica.examples import *


@testattr(stddist = True)
def test_parameter_estimation_1():
    """
    Test the parameter_estimation_1 example
    """
    parameter_estimation_1.run_demo(False)   

@testattr(stddist = True)
def test_vdp():
    """
    Test the vdp example
    """
    vdp.run_demo(False)

@testattr(stddist = True)
def test_vdp_minimum_time():
    """
    Test the vdp_minimum_time example
    """
    vdp_minimum_time.run_demo(False)

@testattr(stddist = True)
def test_quadtank():
    """
    Test the quadtank example
    """
    quadtank.run_demo(False)

@testattr(stddist = True)
def test_cstr():
    """
    Test the cstr example
    """
    cstr.run_demo(False)

@testattr(stddist = True)
def test_pendulum():
    """
    Test the pendulum example
    """
    pendulum.run_demo(False)
    
@testattr(slow = True)
def test_cstr_mpc():
    """ Test the cstr_mpc example. """    
    cstr_mpc.run_demo(False)

@testattr(stddist = True)
def test_cstr2():
    """ Test the cstr2 example. """   
    cstr2.run_demo(False)

@testattr(stddist = True)
def test_distillation():
    """ Test the distillation example. """  
    #distillation.run_demo(False)
    
@testattr(stddist = True)
def test_if_example_1():
    """ Test the if_example_1 example. """    
    if_example_1.run_demo(False)

@testattr(stddist = True)
def test_if_example_2():
    """ Test the if_example_2 example. """    
    if_example_2.run_demo(False)
    
@testattr(stddist = True)
def test_RLC():
    """ Test the RLC example. """    
    RLC.run_demo(False)

@testattr(stddist = True)
def test_sim_rlc():
    """ Test the sim_rlc example. """    
    sim_rlc.run_demo(False)

@testattr(stddist = True)
def test_simulation_with_input():
    """ Test the simulation_with_input example. """    
    simulation_with_input.run_demo(False)

@testattr(stddist = True)
def test_rlc_linearization():
    """ Test that linearization of the RLC circuit works. """    
    RLC_linearization.run_demo(False)
