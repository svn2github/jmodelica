""" Test module for testing the jmi module
"""

import os

import nose
import matplotlib.pyplot as plt
import nose.tools as ntools
import numpy as N

#from jmodelica.tests import load_example_standard_model
from jmodelica.tests import testattr

import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
from jmodelica.compiler import ModelicaCompiler
import jmodelica.xmlparser as xp
import jmodelica.io
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer
from jmodelica.optimization import ipopt
from jmodelica.simulation.sundials import SundialsODESimulator


sep = os.path.sep

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join(jm_home, "Python", "jmodelica", "examples")
path_to_tests = os.path.join(jm_home, "Python", "jmodelica", "tests")
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)

@testattr(stddist = True)
def test_Model_dae_get_sizes():
    """ Test of the dae_get_sizes in Model
    """
    
    model = "files" + sep + "VDP.mo"
    fpath = os.path.join(path_to_examples, model)
    cpath = "VDP_pack.VDP_Opt"
    fname = cpath.replace('.','_',1)

    oc.compile_model(fpath, cpath, target='ipopt')

    # Load the dynamic library and XML data
    vdp = jmi.Model(fname)

    res_n_eq_F = 3
    n_eq_F, n_eq_R = vdp.jmimodel.dae_get_sizes()
    assert n_eq_F==res_n_eq_F, \
           "test_jmi.py: test_Model_dae_get_sizes: Wrong number of DAE equations." 

    res_n_eq_F0 = 6
    res_n_eq_F1 = 7
    res_n_eq_Fp = 0
    res_n_eq_R0 = 0
    n_eq_F0,n_eq_F1,n_eq_Fp,n_eq_R0 = vdp.jmimodel.init_get_sizes()
    assert n_eq_F0==res_n_eq_F0 and n_eq_F1==res_n_eq_F1 and n_eq_Fp==res_n_eq_Fp and n_eq_R0==res_n_eq_R0, \
           "test_jmi.py: test_Model_dae_get_sizes: Wrong number of DAE initialization equations." 

    res_n_eq_Ceq = 0
    res_n_eq_Cineq = 1
    res_n_eq_Heq = 0
    res_n_eq_Hineq = 0
    
    n_eq_Ceq,n_eq_Cineq,n_eq_Heq,n_eq_Hineq = vdp.jmimodel.opt_get_sizes()

    assert n_eq_Ceq==res_n_eq_Ceq and n_eq_Cineq==res_n_eq_Cineq and n_eq_Heq==res_n_eq_Heq and n_eq_Hineq==res_n_eq_Hineq,  \
           "test_jmi.py: test_Model_dae_get_sizes: Wrong number of constraints." 


@testattr(stddist = True)
def test_state_start_values_fixed():
    """ Test of the compiler option state_start_values_fixed
    """
    """ Test of the dae_get_sizes in Model
    """
    
    model = "files" + sep + "VDP_pack.mo"
    fpath = os.path.join(path_to_tests, model)
    cpath = "VDP_pack.VDP"
    fname = cpath.replace('.','_',1)

    mc = ModelicaCompiler()
    
    mc.set_boolean_option('state_start_values_fixed',False)

    mc.compile_model(fpath, cpath)

    # Load the dynamic library and XML data
    vdp = jmi.Model(fname)

    res_n_eq_F = 2
    n_eq_F, n_eq_R = vdp.jmimodel.dae_get_sizes()
    assert n_eq_F==res_n_eq_F, \
           "test_jmi.py: test_Model_dae_get_sizes: Wrong number of DAE equations." 

    res_n_eq_F0 = 2
    res_n_eq_F1 = 5
    res_n_eq_Fp = 0
    res_n_eq_R0 = 0
    n_eq_F0,n_eq_F1,n_eq_Fp, n_eq_R0 = vdp.jmimodel.init_get_sizes()
    assert n_eq_F0==res_n_eq_F0 and n_eq_F1==res_n_eq_F1 and n_eq_Fp==res_n_eq_Fp and n_eq_R0==res_n_eq_R0, \
           "test_jmi.py: test_Model_dae_get_sizes: Wrong number of DAE initialization equations." 



class TestModel:
    """Test the high level model class, jmi.Model.
    
    The tests are based on the Van der Pol oscillator.
    
    Also note that this class also is tested in simulation tests.
    """
    
    def setUp(self):
        """Test setUp. Load the test model."""
        model = "files" + sep + "VDP.mo"
        fpath = os.path.join(path_to_examples, model)
        cpath = "VDP_pack.VDP_Opt"
        fname = cpath.replace('.','_',1)

        oc.compile_model(fpath, cpath, target='ipopt')

        # Load the dynamic library and XML data
        self.m = jmi.Model(fname)
        
#        self.m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo', 
#                                             'VDP_pack.VDP_Opt')

    @testattr(stddist = True)                                          
    def test_model_size(self):
        """Test jmi.Model length of x"""
        size = len(self.m.x)
        nose.tools.assert_equal(size, 3)
    
    @testattr(stddist = True)    
    def test_states_get_set(self):
        """Test jmi.Model.set_x(...) and jmi.Model.get_x()."""
        new_states = [1.74, 3.38, 12.45]
        reset = [0, 0, 0]
        self.m.x = reset
        states = self.m.x
        N.testing.assert_array_almost_equal(reset, states)
        self.m.x = new_states
        states = self.m.x
        N.testing.assert_array_almost_equal(new_states, states)
    
    @testattr(stddist = True)   
    def test_diffs(self):
        """Test jmi.Model.set_dx(...) and jmi.Model.get_dx()."""
        reset = [0, 0, 0]
        diffs = self.m.dx
        diffs[:] = reset
        diffs2 = self.m.dx
        N.testing.assert_array_almost_equal(reset, diffs2)
        
        new_diffs = [1.54, 3.88, 45.87]
        diffs[:] = new_diffs
        N.testing.assert_array_almost_equal(new_diffs, diffs2)
    
    @testattr(stddist = True)    
    def test_inputs(self):
        """Test jmi.Model.set_u(...) and jmi.Model.get_u()."""
        new_inputs = [1.54]
        reset = [0]
        self.m.u = reset
        inputs = self.m.u
        N.testing.assert_array_almost_equal(reset, inputs)
        self.m.u = new_inputs
        inputs = self.m.u
        N.testing.assert_array_almost_equal(new_inputs, inputs)
    
    @testattr(stddist = True)    
    def test_parameters(self):
        """Test methods jmi.Model.[set|get]_pi(...)."""
        new_params = [1.54, 19.54, 78.12]
        reset = [0] * 3
        self.m.pi = reset
        params = self.m.pi
        N.testing.assert_array_almost_equal(reset, params)
        self.m.pi = new_params
        params = self.m.pi
        N.testing.assert_array_almost_equal(new_params, params)
    
    @testattr(stddist = True)    
    def test_time_get_set(self):
        """Test jmi.Model.[set|get]_t(...)."""
        new_time = 0.47
        reset = 0
        self.m.t = reset
        t = self.m.t
        nose.tools.assert_almost_equal(reset, t)
        self.m.t = new_time
        t = self.m.t
        nose.tools.assert_almost_equal(new_time, t)
    
    @testattr(stddist = True)   
    def test_evaluation(self):
        """Test jmi.Model.eval_ode_f()."""
        self.m.dx = [0, 0, 0]
        self.m.eval_ode_f()
        all_zeros = True
        for value in self.m.dx:
            if value != 0:
                all_zeros = False
                
        assert not all_zeros
    
    @testattr(stddist = True)    
    def test_reset(self):
        """Testing resetting the a jmi.Model."""
        random = N.array([12, 31, 42])
        self.m.x = random
        self.m.reset()
        maxdiff = max(N.abs(random - self.m.x))
        assert maxdiff > 0.001
        
    def test_optimization_cost_eval(self):
        """Test evaluation of optimization cost function."""
        simulator = SundialsODESimulator(self.m)
        simulator.run()
        T, ys = simulator.get_solution()
        
        self.m.set_x_p(ys[-1], 0)
        self.m.set_dx_p(self.m.dx, 0)
        cost = self.m.opt_eval_J()
        nose.tools.assert_not_equal(cost, 0)
        
    def test_optimization_cost_jacobian(self):
        """Test evaluation of optimization cost function jacobian.
        
        Note:
        This test is model specific for the VDP oscillator.
        """
        simulator = SundialsODESimulator(self.m)
        simulator.run()
        T, ys = simulator.get_solution()
        
        self.m.set_x_p(ys[-1], 0)
        self.m.set_dx_p(self.m.dx, 0)
        jac = self.m.opt_eval_jac_J(jmi.JMI_DER_X_P)
        N.testing.assert_almost_equal(jac, [[0, 0, 1]])
    
    @testattr(stddist = True)    
    def test_setget_value(self):
        """ Test set and get a value of a variable or parameter. """
        parameter = 'p1'
        # set_value
        new_value = 2.0
        self.m.set_value(parameter, new_value)
        nose.tools.assert_equal(self.m.get_value(parameter), new_value)

    @testattr(stddist = True)        
    def test_setget_values(self):
        """ Test set and get a list of variables or parameters."""
        parameters = ['p1', 'p2', 'p3']
        real_values = [0.0, 0.0, 0.0]
        # set_values
        new_values = [1.0, 2.0, 3.0]
        self.m.set_values(parameters, new_values)
        for index, val in enumerate(new_values):
            nose.tools.assert_equal(val, self.m.get_value(parameters[index]))

class TestModelCSTR:
    """Test the high level model class, jmi.Model with alias variables 
        enabled.
    
    The tests are based on the CSTR example file.

    """
    
    def setUp(self):
        """Test setUp. Load the test model."""
        model = "files" + sep + "CSTR.mo"
        fpath = os.path.join(path_to_examples, model)
        cpath = "CSTR.CSTR_Opt"
        fname = cpath.replace('.','_',1)

        oc.set_boolean_option('eliminate_alias_variables', True)
        oc.compile_model(fpath, cpath, target='ipopt')

        # Load the dynamic library and XML data
        self.m = jmi.Model(fname)
            
    @testattr(stddist = True)
    def test_setget_alias_value(self):
       """ Test set and get the value of a alias variable. """ 
       alias_variable = 'cstr.Tc'
       aliased_variable = 'u'
       u = self.m.get_value(aliased_variable)
       tc = self.m.get_value(alias_variable)
       nose.tools.assert_equal(u, tc)
       new_value = 345.0
       self.m.set_value(alias_variable, new_value)
       nose.tools.assert_equal(self.m.get_value(aliased_variable), new_value)
       


        
