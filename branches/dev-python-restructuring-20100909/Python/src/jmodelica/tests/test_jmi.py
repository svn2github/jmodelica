#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
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

""" Test module for testing the jmi module
"""

import os

import ctypes as ct
import numpy as N
import nose
import matplotlib.pyplot as plt
import nose.tools as ntools

#from jmodelica.tests import load_example_standard_model
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path

import jmodelica.xmlparser as xp
import jmodelica.io
import jmodelica.jmi as jmi
from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel

try:
    from jmodelica.simulation.assimulo_interface import JMIODE
    #, JMIDAE, FMIODE, JMIModel_Exception
    #from jmodelica.simulation.assimulo_interface import write_data
    #from jmodelica.simulation.assimulo_interface import TrajectoryLinearInterpolation
    from assimulo.explicit_ode import CVode
except NameError, ImportError:
    warnings.warn('Could not load Assimulo module. Check jmodelica.check_packages()')

int = N.int32
N.int = N.int32

# constants used in TestJMIModel
eval_alg = jmi.JMI_DER_CPPAD
sparsity = jmi.JMI_DER_SPARSE
indep_vars = jmi.JMI_DER_ALL

class TestModel_VDP:
    """Test the high level model class, jmi.Model.
    
    The tests are based on the Van der Pol oscillator.
    
    Also note that this class also is tested in simulation tests.
    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        # compile VDP
        fpath_vdp = os.path.join(get_files_path(), 'Modelica', "VDP.mop")
        cpath_vdp = "VDP_pack.VDP_Opt"
        fname_vdp = compile_jmu(cpath_vdp, fpath_vdp, 
                    compiler_options={'state_start_values_fixed':True})
        
        #fname_vdp = cpath_vdp.replace('.','_',1)
        #oc.set_boolean_option('state_start_values_fixed',True)
        #oc.compile_model(cpath_vdp, fpath_vdp)#, target='ipopt')
    
    def setUp(self):
        """
        Sets up the test case.
        """
        self.vdp = JMUModel("VDP_pack_VDP_Opt.jmu")
        
    @testattr(stddist = True)
    def test_has_cppad_derivatives(self):
        """ Test jmi.Model.has_cppad_derivatives function."""
        nose.tools.assert_equal(self.vdp.has_cppad_derivatives(), True)
    
    @testattr(stddist = True)                                          
    def test_model_size(self):
        """Test jmi.Model length of x"""
        size = len(self.vdp.real_x)
        nose.tools.assert_equal(size, 3)

    @testattr(stddist = True)    
    def test_reset(self):
        """Testing resetting the a jmi.Model."""
        random = N.array([12, 31, 42])
        self.vdp.real_x = random
        self.vdp.reset()
        maxdiff = max(N.abs(random - self.vdp.real_x))
        assert maxdiff > 0.001

    @testattr(stddist = True)    
    def test_get_variable_names(self):
        """ Test jmi.Model.get_variable_names method."""
        names = self.vdp.get_variable_names()
        ntools.assert_equal(names[0][1],'p1')
        
    @testattr(stddist = True)
    def test_get_dx_variable_names(self):
        """ Test jmi.Model.get_dx_variable_names method."""
        names = [(5,'der(x1)'),(6,'der(x2)'),(7,'der(cost)')]
        ntools.assert_equal(self.vdp.get_dx_variable_names(),names)
    
    @testattr(stddist = True)
    def test_get_x_variable_names(self):
        """ Test jmi.Model.get_x_variable_names method."""
        names = [(8,'x1'),(9,'x2'),(10,'cost')]
        ntools.assert_equal(self.vdp.get_x_variable_names(),names)
    
    @testattr(stddist = True)
    def test_get_u_variable_names(self):
        """ Test jmi.Model.get_u_variable_names method."""
        names = [(11,'u')]
        ntools.assert_equal(self.vdp.get_u_variable_names(),names)
    
    @testattr(stddist = True)
    def test_get_w_variable_names(self):
        """ Test jmi.Model.get_w_variable_names method."""
        # TODO improve test 
        # there are no algebraic variables in the vdp model
        names = []
        ntools.assert_equal(self.vdp.get_w_variable_names(),names)
    
    @testattr(stddist = True)
    def test_get_p_opt_variable_names(self):
        """ Test jmi.Model.get_p_opt_variable_names method."""
        # TODO improve test 
        # there are no popt variables in the model
        names = []
        ntools.assert_equal(self.vdp.get_p_opt_variable_names(),names)
     
    @testattr(stddist = True)   
    def test_get_sizes(self):
        """ Test jmi.Model.get_sizes method."""
        sizes = [0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 20]
        ntools.assert_equal(self.vdp.get_sizes(),sizes)
    
    @testattr(stddist = True)    
    def test_get_offsets(self):
        """ Test jmi.Model.get_offsets method."""
        offsets = [0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 8, 11, 12, 12, 13, 16, 19, 20, 20, 20, 20, 20, 20, 20, 20]
        ntools.assert_equal(self.vdp.get_offsets(),offsets)
    
    @testattr(stddist = True)
    def test_get_n_tp(self):
        """ Test jmi.Model.get_n_tp method."""
        ntools.assert_equal(self.vdp.get_n_tp(),1)
        
    @testattr(stddist = True)    
    def test_states_get_set(self):
        """Test jmi.Model.set_real_x(...) and jmi.Model.get_real_x()."""
        new_states = [1.74, 3.38, 12.45]
        reset = [0, 0, 0]
        self.vdp.real_x = reset
        states = self.vdp.real_x
        N.testing.assert_array_almost_equal(reset, states)
        self.vdp.real_x = new_states
        states = self.vdp.real_x
        N.testing.assert_array_almost_equal(new_states, states)

    @testattr(stddist = True)    
    def test_states_p_get_set(self):
        """Test jmi.Model.set_real_x_p(...) and jmi.Model.get_real_x_p()."""
        new_states = N.ones(3)
        timepoint=0
        self.vdp.set_real_x_p(new_states, 0)
        N.testing.assert_array_almost_equal(self.vdp.get_real_x_p(0),new_states)

    @testattr(stddist = True)    
    def test_real_ci_get_set(self):
        """Test jmi.Model.set_real_ci(...) and jmi.Model.get_real_ci()."""
        # cd is empty
        ci_new = N.ones(1)
        self.vdp.set_real_ci(ci_new)
        N.testing.assert_array_almost_equal(self.vdp.get_real_ci(),N.zeros(0))

    @testattr(stddist = True)    
    def test_real_cd_get_set(self):
        """Test jmi.Model.set_real_cd(...) and jmi.Model.get_real_cd()."""
        # cd is empty
        cd_new = N.ones(1)
        self.vdp.set_real_cd(cd_new)
        N.testing.assert_array_almost_equal(self.vdp.get_real_cd(),N.zeros(0))
        
    @testattr(stddist = True)    
    def test_real_pd_get_set(self):
        """Test jmi.Model.set_real_pd(...) and jmi.Model.get_real_pd()."""
        # pd is empty
        pd_new = N.ones(1)
        self.vdp.set_real_pd(pd_new)
        N.testing.assert_array_almost_equal(self.vdp.get_real_pd(),N.zeros(0))

    @testattr(stddist = True)    
    def test_integer_ci_get_set(self):
        """Test jmi.Model.set_integer_ci(...) and jmi.Model.get_integer_ci()."""
        # cd is empty
        ci_new = N.ones(1)
        self.vdp.set_integer_ci(ci_new)
        N.testing.assert_array_almost_equal(self.vdp.get_integer_ci(),N.zeros(0))

    @testattr(stddist = True)    
    def test_integer_cd_get_set(self):
        """Test jmi.Model.set_integer_cd(...) and jmi.Model.get_integer_cd()."""
        # cd is empty
        cd_new = N.ones(1)
        self.vdp.set_integer_cd(cd_new)
        N.testing.assert_array_almost_equal(self.vdp.get_integer_cd(),N.zeros(0))

    @testattr(stddist = True)    
    def test_integer_pi_get_set(self):
        """Test jmi.Model.set_integer_pi(...) and jmi.Model.get_integer_pi()."""
        # pd is empty
        pi_new = N.ones(1)
        self.vdp.set_integer_pi(pi_new)
        N.testing.assert_array_almost_equal(self.vdp.get_integer_pi(),N.zeros(0))
        
    @testattr(stddist = True)    
    def test_integer_pd_get_set(self):
        """Test jmi.Model.set_integer_pd(...) and jmi.Model.get_integer_pd()."""
        # pd is empty
        pd_new = N.ones(1)
        self.vdp.set_integer_pd(pd_new)
        N.testing.assert_array_almost_equal(self.vdp.get_integer_pd(),N.zeros(0))

    @testattr(stddist = True)    
    def test_boolean_ci_get_set(self):
        """Test jmi.Model.set_boolean_ci(...) and jmi.Model.get_boolean_ci()."""
        # cd is empty
        ci_new = N.ones(1)
        self.vdp.set_boolean_ci(ci_new)
        N.testing.assert_array_almost_equal(self.vdp.get_boolean_ci(),N.zeros(0))

    @testattr(stddist = True)    
    def test_boolean_cd_get_set(self):
        """Test jmi.Model.set_boolean_cd(...) and jmi.Model.get_boolean_cd()."""
        # cd is empty
        cd_new = N.ones(1)
        self.vdp.set_boolean_cd(cd_new)
        N.testing.assert_array_almost_equal(self.vdp.get_boolean_cd(),N.zeros(0))

    @testattr(stddist = True)    
    def test_boolean_pi_get_set(self):
        """Test jmi.Model.set_boolean_pi(...) and jmi.Model.get_boolean_pi()."""
        # pd is empty
        pi_new = N.ones(1)
        self.vdp.set_boolean_pi(pi_new)
        N.testing.assert_array_almost_equal(self.vdp.get_boolean_pi(),N.zeros(0))
        
    @testattr(stddist = True)    
    def test_boolean_pd_get_set(self):
        """Test jmi.Model.set_boolean_pd(...) and jmi.Model.get_boolean_pd()."""
        # pd is empty
        pd_new = N.ones(1)
        self.vdp.set_boolean_pd(pd_new)
        N.testing.assert_array_almost_equal(self.vdp.get_boolean_pd(),N.zeros(0))
    
    @testattr(stddist = True)   
    def test_derivatives(self):
        """Test jmi.Model.set_real_dx(...) and jmi.Model.get_real_dx()."""
        reset = [0, 0, 0]
        diffs = self.vdp.real_dx
        diffs[:] = reset
        diffs2 = self.vdp.real_dx
        N.testing.assert_array_almost_equal(reset, diffs2)
        
        new_diffs = [1.54, 3.88, 45.87]
        diffs[:] = new_diffs
        N.testing.assert_array_almost_equal(new_diffs, diffs2)

    @testattr(stddist = True)    
    def test_derivatives_p_get_set(self):
        """Test jmi.Model.set_real_dx_p(...) and jmi.Model.get_real_dx_p()."""
        new_diffs = N.ones(3)
        timepoint=0
        self.vdp.set_real_dx_p(new_diffs, 0)
        N.testing.assert_array_almost_equal(self.vdp.get_real_dx_p(0),new_diffs)
            
    @testattr(stddist = True)    
    def test_inputs(self):
        """Test jmi.Model.set_real_u(...) and jmi.Model.get_real_u()."""
        new_inputs = [1.54]
        reset = [0]
        self.vdp.real_u = reset
        inputs = self.vdp.real_u
        N.testing.assert_array_almost_equal(reset, inputs)
        self.vdp.real_u = new_inputs
        inputs = self.vdp.real_u
        N.testing.assert_array_almost_equal(new_inputs, inputs)

    @testattr(stddist = True)    
    def test_inputs_p_get_set(self):
        """Test jmi.Model.set_real_u_p(...) and jmi.Model.get_real_u_p()."""
        new_inputs = N.ones(1)
        timepoint=0
        self.vdp.set_real_u_p(new_inputs, 0)
        N.testing.assert_array_almost_equal(self.vdp.get_real_u_p(0),new_inputs)
        
    @testattr(stddist = True)    
    def test_real_w_get_set(self):
        """Test jmi.Model.set_real_w(...) and jmi.Model.get_real_w()."""
        # w is empty
        w_new = N.ones(1)
        self.vdp.set_real_w(w_new)
        N.testing.assert_array_almost_equal(self.vdp.get_real_w(),N.zeros(0))

    @testattr(stddist = True)    
    def test_real_w_p_get_set(self):
        """Test jmi.Model.set_real_w_p(...) and jmi.Model.get_real_w_p()."""
        new_alg = N.ones(1)
        timepoint=0
        self.vdp.set_real_w_p(new_alg, 0)
        N.testing.assert_array_almost_equal(self.vdp.get_real_w_p(0),N.zeros(0))

    @testattr(stddist = True)    
    def test_real_d_get_set(self):
        """Test jmi.Model.set_real_d(...) and jmi.Model.get_real_d()."""
        # d is empty
        d_new = N.ones(1)
        self.vdp.set_real_d(d_new)
        N.testing.assert_array_almost_equal(self.vdp.get_real_d(),N.zeros(0))

    @testattr(stddist = True)    
    def test_integer_d_get_set(self):
        """Test jmi.Model.set_integer_d(...) and jmi.Model.get_integer_d()."""
        # d is empty
        d_new = N.ones(1)
        self.vdp.set_integer_d(d_new)
        N.testing.assert_array_almost_equal(self.vdp.get_integer_d(),N.zeros(0))

    @testattr(stddist = True)    
    def test_integer_u_get_set(self):
        """Test jmi.Model.set_integer_u(...) and jmi.Model.get_integer_u()."""
        # u is empty
        u_new = N.ones(1)
        self.vdp.set_integer_u(u_new)
        N.testing.assert_array_almost_equal(self.vdp.get_integer_u(),N.zeros(0))

    @testattr(stddist = True)    
    def test_boolean_d_get_set(self):
        """Test jmi.Model.set_boolean_d(...) and jmi.Model.get_boolean_d()."""
        # d is empty
        d_new = N.ones(1)
        self.vdp.set_boolean_d(d_new)
        N.testing.assert_array_almost_equal(self.vdp.get_boolean_d(),N.zeros(0))

    @testattr(stddist = True)    
    def test_boolean_u_get_set(self):
        """Test jmi.Model.set_boolean_u(...) and jmi.Model.get_boolean_u()."""
        # u is empty
        u_new = N.ones(1)
        self.vdp.set_boolean_u(u_new)
        N.testing.assert_array_almost_equal(self.vdp.get_boolean_u(),N.zeros(0))
        
    @testattr(stddist = True)    
    def test_z_get_set(self):
        """Test jmi.Model.set_z(...) and jmi.Model.get_z()."""
        z_new = self.vdp.get_z()
        z_new.itemset(0,2)
        self.vdp.set_z(z_new)
        N.testing.assert_array_almost_equal(self.vdp.get_z(),z_new)

    @testattr(stddist = True)    
    def test_get_sw(self):
        """Test jmi.Model.set_sw(...) and jmi.Model.get_sw()."""
        sw_new = self.vdp.get_sw()
        self.vdp.set_sw(sw_new)
        N.testing.assert_array_almost_equal(self.vdp.get_sw(),sw_new)

    @testattr(stddist = True)    
    def test_get_sw_init(self):
        """Test jmi.Model.set_sw_init(...) and jmi.Model.get_sw_init()."""
        sw_init_new = self.vdp.get_sw_init()
        self.vdp.set_sw_init(sw_init_new)
        N.testing.assert_array_almost_equal(self.vdp.get_sw_init(),sw_init_new)

    @testattr(stddist = True)    
    def test_variable_scaling_factors_get_set(self):
        """Test jmi.Model.set_variable_scaling_factors(...) and jmi.Model.get_variable_scaling_factors()."""
        variable_scaling_factors_new = self.vdp.get_variable_scaling_factors()
        variable_scaling_factors_new.itemset(0,2)
        self.vdp.set_variable_scaling_factors(variable_scaling_factors_new)
        N.testing.assert_array_almost_equal(self.vdp.get_variable_scaling_factors(),variable_scaling_factors_new)

    @testattr(stddist = True)    
    def test_get_scaling_method(self):
        """Test jmi.Model.get_scaling_method()."""
        ntools.assert_equal(self.vdp.get_scaling_method(),jmi.JMI_SCALING_NONE)
    
    @testattr(stddist = True)    
    def test_parameters(self):
        """Test methods jmi.Model.[set|get]_real_pi(...)."""
        new_params = [1.54, 19.54, 78.12, 0, 3]
        reset = [0] * 5
        self.vdp.real_pi = reset
        params = self.vdp.real_pi
        N.testing.assert_array_almost_equal(reset, params)
        self.vdp.real_pi = new_params
        params = self.vdp.real_pi
        N.testing.assert_array_almost_equal(new_params, params)
    
    @testattr(stddist = True)    
    def test_time_get_set(self):
        """Test jmi.Model.[set|get]_t(...)."""
        new_time = 0.47
        reset = 0
        self.vdp.t = reset
        t = self.vdp.t
        nose.tools.assert_almost_equal(reset, t)
        self.vdp.t = new_time
        t = self.vdp.t
        nose.tools.assert_almost_equal(new_time, t)
    
    @testattr(stddist = True)   
    def test_evaluation(self):
        """Test jmi.Model.eval_ode_f()."""
        self.vdp.real_dx = [0, 0, 0]
        self.vdp.eval_ode_f()
        all_zeros = True
        for value in self.vdp.real_dx:
            if value != 0:
                all_zeros = False
                
        assert not all_zeros
    
    @testattr(assimulo = True)
    def test_optimization_cost_eval(self):
        """Test evaluation of optimization cost function."""
        simulator_mod = JMIODE(self.vdp)
        simulator = CVode(simulator_mod)
        simulator.simulate(10)

        T, ys = [simulator.t, simulator.y]
        
        self.vdp.set_real_x_p(ys[-1], 0)
        self.vdp.set_real_dx_p(self.vdp.real_dx, 0)
        cost = self.vdp.opt_eval_J()
        nose.tools.assert_not_equal(cost, 0)
    
    @testattr(assimulo = True)
    def test_optimization_cost_jacobian(self):
        """Test evaluation of optimization cost function jacobian.
        Note:
        This test is model specific for the VDP oscillator.
        """
        simulator_mod = JMIODE(self.vdp)
        simulator = CVode(simulator_mod)
        simulator.simulate(10)

        T, ys = [simulator.t, simulator.y]
        
        self.vdp.set_real_x_p(ys[-1], 0)
        self.vdp.set_real_dx_p(self.vdp.real_dx, 0)
        jac = self.vdp.opt_eval_jac_J(jmi.JMI_DER_X_P)
        N.testing.assert_almost_equal(jac, [[0, 0, 1]])
    
    @testattr(stddist = True)    
    def test_setget_value(self):
        """ Test set and get a value of a variable or parameter. """
        parameter = 'p1'
        # set_value
        new_value = 2.0
        self.vdp.set(parameter, new_value)
        nose.tools.assert_equal(self.vdp.get(parameter), new_value)

    @testattr(stddist = True)        
    def test_setget_values(self):
        """ Test set and get a list of variables or parameters."""
        parameters = ['p1', 'p2', 'p3']
        real_values = [0.0, 0.0, 0.0]
        # set_values
        new_values = [1.0, 2.0, 3.0]
        self.vdp.set(parameters, new_values)
        for index, val in enumerate(new_values):
            nose.tools.assert_equal(val, self.vdp.get(parameters[index]))
            
    @testattr(stddist = True)
    def test_writeload_parameters_from_XML(self):
        """ Test writing and loading parameters parameters from XML."""
        original_values = self.vdp.get_real_pi()
        new_values = N.ones(len(original_values))
        self.vdp.set_real_pi(new_values)

        # new values are set
        N.testing.assert_array_equal(self.vdp.get_real_pi(),new_values)
      
        #load original values, pi are now = old values
        self.vdp.load_parameters_from_XML()
        N.testing.assert_array_equal(self.vdp.get_real_pi(),original_values)
       
        # set new values and write to xml
        self.vdp.set_real_pi(new_values)
        self.vdp.write_parameters_to_XML()
       
        #load values, pi are now = new values
        self.vdp.load_parameters_from_XML()
        N.testing.assert_array_equal(self.vdp.get_real_pi(),new_values)

    @testattr(stddist = True)
    def test_writeload_params_new_file(self):
        """ Test writing and loading parameters parameters from XML 
            with new file. 
        """
        original_values = self.vdp.get_real_pi()
        new_values = N.ones(len(original_values))
        self.vdp.set_real_pi(new_values)

        # new values are set
        N.testing.assert_array_equal(self.vdp.get_real_pi(),new_values)
       
        #load original values, pi are now = old values
        self.vdp.load_parameters_from_XML()
        N.testing.assert_array_equal(self.vdp.get_real_pi(),original_values)
        
        # set new values and write to xml
        self.vdp.set_real_pi(new_values)
        self.vdp.write_parameters_to_XML("test_jmi.xml")
        
        #load values, pi are now = new values
        self.vdp.load_parameters_from_XML("test_jmi.xml")
        N.testing.assert_array_equal(self.vdp.get_real_pi(),new_values)
        
        #load original values, pi are now = old values
        self.vdp.load_parameters_from_XML()
        N.testing.assert_array_equal(self.vdp.get_real_pi(),original_values)          
            
    @testattr(stddist = True)        
    def test_get_name(self):
        """Test jmi.Model.get_name method."""
        ntools.assert_equal(self.vdp.get_name(),"VDP_pack_VDP_Opt")
    
    @testattr(stddist = True)    
    def test_opt_interval_starttime_free(self):
        """Test jmi.Model.get_name method."""
        ntools.assert_equal(self.vdp.opt_interval_starttime_free(),False)
    
    @testattr(stddist = True)    
    def test_opt_interval_starttime_fixed(self):
        """Test jmi.Model.opt_interval_starttime_fixed method."""
        ntools.assert_equal(self.vdp.opt_interval_starttime_fixed(),True)
    
    @testattr(stddist = True)        
    def test_opt_interval_finaltime_free(self):
        """Test jmi.Model.opt_interval_finaltime_free method."""
        ntools.assert_equal(self.vdp.opt_interval_finaltime_free(),False)
    
    @testattr(stddist = True)    
    def test_opt_interval_finaltime_fixed(self):
        """Test jmi.Model.opt_interval_finaltime_fixed method."""
        ntools.assert_equal(self.vdp.opt_interval_finaltime_fixed(),True)
    
    @testattr(stddist = True)   
    def test_opt_interval_get_start_time(self):
        """Test jmi.Model.opt_interval_get_start_time method."""
        ntools.assert_equal(self.vdp.opt_interval_get_start_time(),0.0)
    
    @testattr(stddist = True)   
    def test_opt_interval_get_final_time(self):
        """Test jmi.Model.opt_interval_get_final_time method."""
        ntools.assert_equal(self.vdp.opt_interval_get_final_time(),20.0)
        
class TestModel_RLC:
    """Test the high level model class, jmi.Model with alias variables 
        enabled.
    
    The tests are based on the RLC_Circuit example file.

    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        fpath_rlc = os.path.join(get_files_path(), 'Modelica', "RLC_Circuit.mo")
        cpath_rlc = "RLC_Circuit"
        fname_vdp = compile_jmu(cpath_rlc, fpath_rlc, 
                    compiler_options={'eliminate_alias_variables':True})
        # compile RLC_Circuit with alias variables elimination

    
    def setUp(self):
        """
        Sets up the test case.
        """
        self.rlc = JMUModel("RLC_Circuit.jmu")

    # removed method
    #@testattr(stddist = True)
    #def test_get_variable_description(self):
        #ntools.assert_equal(self.rlc.get_variable_description("resistor.R"),"Resistance")
        
    @testattr(stddist = True)
    def test_get_variable_descriptions(self):
        """Test jmi.Model.get_variable_descriptions method."""
        descriptions = self.rlc.get_variable_descriptions()
        ntools.assert_equal(descriptions[0][1],"Potential at the pin")

    @testattr(stddist = True)
    def test_is_negated_alias(self):
        """Test jmi.Model.is_negated_alias method."""
        ntools.assert_equal(self.rlc.is_negated_alias("resistor.n.i"),True)
    
    @testattr(stddist = True)
    def test_get_aliases(self):
        """Test jmi.Model.get_aliases_for_variable method."""
        (aliases,is_neg_alias) = self.rlc.get_aliases_for_variable("capacitor.p.i")
        ntools.assert_equal(aliases[0],"capacitor.i")
        ntools.assert_equal(aliases[1], "capacitor.n.i")
        ntools.assert_equal(is_neg_alias[0],False)
        ntools.assert_equal(is_neg_alias[1], True)
            
    @testattr(stddist = True)
    def test_setget_alias_value(self):
       """ Test set and get the value of a alias variable. """ 
       alias_variable = 'capacitor.i'
       aliased_variable = 'capacitor.p.i'
       cap_i = self.rlc.get(aliased_variable)
       cap_p_i = self.rlc.get(alias_variable)
       nose.tools.assert_equal(cap_i, cap_p_i)
       new_value = 1.0
       self.rlc.set(alias_variable, new_value)
       nose.tools.assert_equal(self.rlc.get(aliased_variable), new_value)
       
    @testattr(stddist = True)
    def test_set_constant(self):
        """ Test that set_value of constant should raise error."""
        nose.tools.assert_raises(Exception, self.rlc.set, 'sine.pi',1.0)

class TestJMIModel_VDP:
    """ Test the JMI Model Interface wrappers.
    (Low-level jmodelica interfaces.)

    The correctness of the methods are not really tested here, only that they can
    be called without crashing and in some cases that return value has at least the
    correct type.
    
    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        # compile VDP
        fpath_vdp = os.path.join(get_files_path(), 'Modelica', "VDP.mop")
        cpath_vdp = "VDP_pack.VDP_Opt"
        fname_vdp = compile_jmu(cpath_vdp, fpath_vdp, 
                    compiler_options={'state_start_values_fixed':True})
    
    def setUp(self):
        """
        Sets up the test case.
        """
        self.vdp = JMUModel("VDP_pack_VDP_Opt.jmu")               

    @testattr(stddist = True)
    def test_initAD(self):
        """ Test JMIModel.initAD method. """
        self.vdp.jmimodel.initAD()

    @testattr(stddist = True)
    def test_get_sizes(self):
        """ Test JMIModel.get_sizes method. """
        n_real_ci = ct.c_int()
        n_real_cd = ct.c_int()
        n_real_pi = ct.c_int()
        n_real_pd = ct.c_int()
        n_integer_ci = ct.c_int()
        n_integer_cd = ct.c_int()
        n_integer_pi = ct.c_int()
        n_integer_pd = ct.c_int()
        n_boolean_ci = ct.c_int()
        n_boolean_cd = ct.c_int()
        n_boolean_pi = ct.c_int()
        n_boolean_pd = ct.c_int()
        n_real_dx = ct.c_int()
        n_real_x  = ct.c_int()
        n_real_u  = ct.c_int()
        n_real_w  = ct.c_int()
        n_tp = ct.c_int()
        n_real_d = ct.c_int()
        n_integer_d = ct.c_int()
        n_integer_u = ct.c_int()        
        n_boolean_d = ct.c_int()
        n_boolean_u = ct.c_int()                
        n_sw = ct.c_int()
        n_sw_init = ct.c_int()
        n_z  = ct.c_int()
        self.vdp.jmimodel.get_sizes(n_real_ci, n_real_cd, n_real_pi, n_real_pd,
                                    n_integer_ci, n_integer_cd, n_integer_pi, n_integer_pd,
                                    n_boolean_ci, n_boolean_cd, n_boolean_pi, n_boolean_pd,
                                    n_real_dx, n_real_x, n_real_u, n_real_w, n_tp,
                                    n_real_d,n_integer_d,n_integer_u,n_boolean_d,n_boolean_u,
                                    n_sw, n_sw_init, n_z)

    @testattr(stddist = True)
    def test_get_offsets(self):
        """ Test JMIModel.get_offsets method. """
        offs_real_ci = ct.c_int()
        offs_real_cd = ct.c_int()
        offs_real_pi = ct.c_int()
        offs_real_pd = ct.c_int()
        offs_integer_ci = ct.c_int()
        offs_integer_cd = ct.c_int()
        offs_integer_pi = ct.c_int()
        offs_integer_pd = ct.c_int()
        offs_boolean_ci = ct.c_int()
        offs_boolean_cd = ct.c_int()
        offs_boolean_pi = ct.c_int()
        offs_boolean_pd = ct.c_int()
        offs_real_dx = ct.c_int()
        offs_real_x = ct.c_int()
        offs_real_u = ct.c_int()
        offs_real_w = ct.c_int()
        offs_t = ct.c_int()
        offs_dx_p = ct.c_int()
        offs_x_p = ct.c_int()
        offs_u_p = ct.c_int()
        offs_w_p = ct.c_int()
        offs_real_d = ct.c_int()
        offs_integer_d = ct.c_int()
        offs_integer_u = ct.c_int()
        offs_boolean_d = ct.c_int()
        offs_boolean_u = ct.c_int()
        offs_sw = ct.c_int()
        offs_sw_init = ct.c_int()   
        self.vdp.jmimodel.get_offsets(offs_real_ci, offs_real_cd, offs_real_pi,
                                      offs_real_pd, offs_integer_ci, offs_integer_cd, offs_integer_pi,
                                      offs_integer_pd,offs_boolean_ci, offs_boolean_cd, offs_boolean_pi,
                                      offs_boolean_pd, offs_real_dx, offs_real_x, offs_real_u, 
                                      offs_real_w, offs_t, offs_dx_p, offs_x_p, offs_u_p, offs_w_p,
                                      offs_real_d,offs_integer_d,offs_integer_u,offs_boolean_d,offs_boolean_u,
                                      offs_sw, offs_sw_init)
        
    @testattr(stddist = True)
    def test_get_n_tp(self):
        """ Test JMIModel.get_n_tp method. """
        n_tp = ct.c_int()
        self.vdp.jmimodel.get_n_tp(n_tp)    
    
    @testattr(stddist = True)
    def test_getset_tp(self):
        """ Test JMIModel.get_tp and JMIModel.set_tp method. """
        n_tp = ct.c_int()
        self.vdp.jmimodel.get_n_tp(n_tp)
        #set tp
        set_tp = N.zeros(n_tp.value)
        for i in range(n_tp.value):
            set_tp[i]=i+1
        self.vdp.jmimodel.set_tp(set_tp) 
        #get tp
        get_tp = N.zeros(n_tp.value)
        self.vdp.jmimodel.get_tp(get_tp)
        for j in range(n_tp.value):
            if set_tp[j] != get_tp[j]:
                assert False, "value set with set_tp was not the same as returned by get_tp"   
    
    @testattr(stddist = True)
    def test_get_z(self):
        """ Test JMIModel.get_z method. """
        assert isinstance(self.vdp.jmimodel.get_z(), N.ndarray),\
            "JMIModel.get_z did not return numpy.ndarray."
        
    @testattr(stddist = True)
    def test_get_real_ci(self):
        """ Test JMIModel.get_real_ci method. """
        assert isinstance(self.vdp.jmimodel.get_real_ci(), N.ndarray),\
            "JMIModel.get_real_ci did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_cd(self):
        """ Test JMIModel.get_real_cd method. """
        assert isinstance(self.vdp.jmimodel.get_real_cd(), N.ndarray),\
            "JMIModel.get_real_cd did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_pi(self):
        """ Test JMIModel.get_real_pi method. """
        assert isinstance(self.vdp.jmimodel.get_real_pi(), N.ndarray),\
            "JMIModel.get_real_pi did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_pd(self):
        """ Test JMIModel.get_real_pd method. """
        assert isinstance(self.vdp.jmimodel.get_real_pd(), N.ndarray),\
            "JMIModel.get_real_pd did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_dx(self):
        """ Test JMIModel.get_real_dx method. """
        assert isinstance(self.vdp.jmimodel.get_real_dx(), N.ndarray),\
            "JMIModel.get_real_dx did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_x(self):
        """ Test JMIModel.get_real_x method. """
        assert isinstance(self.vdp.jmimodel.get_real_x(), N.ndarray),\
            "JMIModel.get_real_x did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_u(self):
        """ Test JMIModel.get_real_u method. """
        assert isinstance(self.vdp.jmimodel.get_real_u(), N.ndarray),\
            "JMIModel.get_real_u did not return numpy.ndarray."
    
    @testattr(stddist = True)
    def test_get_real_w(self):
        """ Test JMIModel.get_real_w method. """
        assert isinstance(self.vdp.jmimodel.get_real_w(), N.ndarray),\
            "JMIModel.get_real_w did not return numpy.ndarray. "
    
    @testattr(stddist = True)
    def test_get_t(self):
        """ Test JMIModel.get_t method. """
        assert isinstance(self.vdp.jmimodel.get_t(), N.ndarray),\
            "JMIModel.get_t did not return numpy.ndarray. "
    
    @testattr(stddist = True)
    def test_get_real_dx_p(self):
        """ Test JMIModel.get_real_dx_p method. """
        assert isinstance(self.vdp.jmimodel.get_real_dx_p(0), N.ndarray), \
            "JMIModel.get_real_dx_p(i) for i=0 did not return numpy.ndarray. "
    
    @testattr(stddist = True)
    def test_get_real_x_p(self):
        """ Test JMIModel.get_real_x_p method. """
        assert isinstance(self.vdp.jmimodel.get_real_x_p(0), N.ndarray), \
            "JMIModel.get_real_x_p(i) for i=0 did not return numpy.ndarray. "
    
    @testattr(stddist = True)
    def test_get_real_u_p(self):
        """ Test JMIModel.get_real_u_p method. """
        assert isinstance(self.vdp.jmimodel.get_real_u_p(0), N.ndarray), \
            "JMIModel.get_real_u_p(i) for i=0 did not return numpy.ndarray. " 
    
    @testattr(stddist = True)
    def test_get_real_w_p(self):
        """ Test JMIModel.get_real_w_p method. """
        assert isinstance(self.vdp.jmimodel.get_real_w_p(0), N.ndarray), \
            "JMIModel.get_real_w_p(i) for i=0 did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_real_d(self):
        """ Test JMIModel.get_real_d method. """
        assert isinstance(self.vdp.jmimodel.get_real_d(), N.ndarray),\
            "JMIModel.get_real_d did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_integer_d(self):
        """ Test JMIModel.get_integer_d method. """
        assert isinstance(self.vdp.jmimodel.get_integer_d(), N.ndarray),\
            "JMIModel.get_integer_d did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_integer_u(self):
        """ Test JMIModel.get_integer_u method. """
        assert isinstance(self.vdp.jmimodel.get_integer_u(), N.ndarray),\
            "JMIModel.get_integer_u did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_boolean_d(self):
        """ Test JMIModel.get_boolean_d method. """
        assert isinstance(self.vdp.jmimodel.get_boolean_d(), N.ndarray),\
            "JMIModel.get_boolean_d did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_boolean_u(self):
        """ Test JMIModel.get_boolean_u method. """
        assert isinstance(self.vdp.jmimodel.get_boolean_u(), N.ndarray),\
            "JMIModel.get_boolean_u did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_sw(self):
        """ Test JMIModel.get_sw method. """
        assert isinstance(self.vdp.jmimodel.get_sw(), N.ndarray),\
            "JMIModel.get_sw did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_sw_init(self):
        """ Test JMIModel.get_sw_init method. """
        assert isinstance(self.vdp.jmimodel.get_sw_init(), N.ndarray),\
            "JMIModel.get_sw_init did not return numpy.ndarray. "

    @testattr(stddist = True)
    def test_get_variable_scaling_factors(self):
        """ Test JMIModel.get_scaling_factors method. """
        assert isinstance(self.vdp.jmimodel.get_variable_scaling_factors(), N.ndarray),\
            "JMIModel.get_variable_scaling_factors did not return numpy.ndarray."

    #@testattr(stddist = True)
    #def test_ode_f():
    #    """ Test JMIModel.ode_f method. """
    #    model = jmi.JMIModel(fname, '.')
    #    model.ode_f()
    #    
    #
    #@testattr(stddist = True)
    #def test_ode_df():
    #    """ Test JMIModel.ode_f method. """
    #    model = jmi.JMIModel(fname, '.')
    #
    #
    #@testattr(stddist = True)
    #def test_ode_df_n_nz():
    #    """ Test JMIModel.ode_df_n_nz method. """
    #    model = jmi.JMIModel(fname, '.')
    # 
    #
    #@testattr(stddist = True)
    #def test_ode_df_nz_indices():
    #    """ Test JMIModel.ode_df_nz_indices method. """
    #    model = jmi.JMIModel(fname, '.')
    #
    #
    #@testattr(stddist = True)
    #def test_ode_df_dim():
    #    """ Test JMIModel.ode_df_dim method. """
    #    model = jmi.JMIModel('.')
    
    
    @testattr(stddist = True)
    def test_dae_get_sizes(self):
        """ Test JMIModel.dae_get_sizes method. """
        n_eq_F, n_eq_R = self.vdp.jmimodel.dae_get_sizes()
      
    @testattr(stddist = True)
    def test_dae_F(self):
        """ Test JMIModel.dae_F method. """
        size_F,size_R = self.vdp.jmimodel.dae_get_sizes()
        res = N.zeros(size_F)
        self.vdp.jmimodel.dae_F(res)
    
    @testattr(stddist = True)
    def test_dae_dF(self):
        """ Test JMIModel.dae_dF method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        jac = N.zeros(self.vdp.jmimodel.get_z().size)
        self.vdp.jmimodel.dae_dF(eval_alg,sparsity,indep_vars,mask,jac)
        
    @testattr(stddist = True)
    def test_dae_dF_n_nz(self):
        """ Test JMIModel.dae_dF_n_nz method. """
        self.vdp.jmimodel.dae_dF_n_nz(eval_alg)
    
    @testattr(stddist = True)
    def test_dae_dF_nz_indices(self):
        """ Test JMIModel.dae_dF_nz_indices method. """ 
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        nnz = self.vdp.jmimodel.dae_dF_n_nz(eval_alg)
        row = N.ndarray(nnz, dtype=int)
        col = N.ndarray(nnz, dtype=int)
        self.vdp.jmimodel.dae_dF_nz_indices(eval_alg, indep_vars, mask, row, col)
    
    @testattr(stddist = True)
    def test_dae_dF_dim(self):
        """ Test JMIModel.dae_dF_dim method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        n_cols, n_n_nz = self.vdp.jmimodel.dae_dF_dim(eval_alg, sparsity, indep_vars, mask)
        
    @testattr(stddist = True)
    def test_dae_R(self):
        """ Test JMIModel.dae_R method. """
        size_F, size_R = self.vdp.jmimodel.dae_get_sizes()
        res = N.zeros(size_R)
        self.vdp.jmimodel.dae_R(res)
    
    @testattr(stddist = True)
    def test_init_get_sizes(self):
        """ Test JMIModel.init_get_sizes method. """
        n_eq_f0, n_eq_f1, n_eq_fp, n_eq_r0 = self.vdp.jmimodel.init_get_sizes()
    
    @testattr(stddist = True)
    def test_init_F0(self):
        """ Test JMIModel.init_FO method. """
        n_eq_f0, n_eq_f1, n_eq_fp, n_eq_r0 = self.vdp.jmimodel.init_get_sizes()
        res = N.zeros(n_eq_f0)
        self.vdp.jmimodel.init_F0(res)
    
    @testattr(stddist = True)
    def test_init_dF0(self):
        """ Test JMIModel.init_dF0 method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        jac = N.zeros(self.vdp.jmimodel.get_z().size)
        self.vdp.jmimodel.init_dF0(eval_alg, sparsity, indep_vars, mask, jac)
    
    @testattr(stddist = True)
    def test_init_dF0_n_nz(self):
        """ Test JMIModel.init_dF0_n_nz method. """
        n_nz = self.vdp.jmimodel.init_dF0_n_nz(eval_alg)
    
    @testattr(stddist = True)
    def test_init_dF0_nz_indices(self):
        """ Test JMIModel.init_dF0_nz_indices method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        nnz = self.vdp.jmimodel.init_dF0_n_nz(eval_alg)
        row = N.ndarray(nnz, dtype=int)
        col = N.ndarray(nnz, dtype=int)
        self.vdp.jmimodel.init_dF0_nz_indices(eval_alg, indep_vars, mask, row, col)
    
    @testattr(stddist = True)
    def test_init_dF0_dim(self):
        """ Test JMIModel.init_dF0_dim method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        dF_n_cols, dF_n_nz = self.vdp.jmimodel.init_dF0_dim(eval_alg, sparsity, indep_vars,
                                                mask)
    
    @testattr(stddist = True)
    def test_init_F1(self):
        """ Test JMIModel.init_F1 method. """
        n_eq_f0, n_eq_f1, n_eq_fp, n_eq_r0 = self.vdp.jmimodel.init_get_sizes()
        res = N.zeros(n_eq_f1)
        self.vdp.jmimodel.init_F1(res)
    
    @testattr(stddist = True)
    def test_init_dF1(self):
        """ Test JMIModel.init_dF1 method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        jac = N.zeros(self.vdp.jmimodel.get_z().size)
        self.vdp.jmimodel.init_dF1(eval_alg, sparsity, indep_vars, mask, jac)
    
    @testattr(stddist = True)
    def test_init_dF1_n_nz(self):
        """ Test JMIModel.init_dF1_n_nz method. """
        n_nz = self.vdp.jmimodel.init_dF1_n_nz(eval_alg)
    
    @testattr(stddist = True)
    def test_init_dF1_nz_indices(self):
        """ Test JMIModel.init_dF1_nz_indices method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        nnz = self.vdp.jmimodel.init_dF1_n_nz(eval_alg)
        row = N.ndarray(nnz, dtype=int)
        col = N.ndarray(nnz, dtype=int)
        self.vdp.jmimodel.init_dF1_nz_indices(eval_alg, indep_vars, mask, row, col)
    
    @testattr(stddist = True)
    def test_init_dF1_dim(self):
        """ Test JMIModel.init_dF1_dim method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        dF_n_cols, dF_n_nz = self.vdp.jmimodel.init_dF1_dim(eval_alg, sparsity, indep_vars,
                                                mask) 
    @testattr(stddist = True)
    def test_init_R0(self):
        """ Test JMIModel.init_R0 method. """
        n_eq_f0, n_eq_f1, n_eq_fp, n_eq_r0 = self.vdp.jmimodel.init_get_sizes()
        res = N.zeros(n_eq_r0)
        self.vdp.jmimodel.init_R0(res)
    
    #@testattr(stddist = True)
    #def test_init_Fp():
    #    """ Test JMIModel.init_Fp method. """
    #    model = mc.getjmimodel()
    #    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    #    res = n.zeros(n_eq_fp)
    #    model.init_Fp(res)
    #    
    #
    #@testattr(stddist = True)
    #def test_init_dFp():
    #    """ Test JMIModel.init_dFp method. """
    #    model = mc.getjmimodel()
    #    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    #    if n_eq_fp > 0:
    #        mask = n.ones(model.get_z().size, dtype=int)
    #        jac = n.zeros(model.get_z().size)
    #        model.init_dFp(eval_alg, sparsity, indep_vars, mask, jac)
    #    else:
    #        assert False, "Cannot perform test, size of Fp is 0. "
    #    
    #
    #@testattr(stddist = True)
    #def test_init_dFp_n_nz():
    #    """ Test JMIModel.init_dFp_n_nz method. """
    #    model = mc.getjmimodel()
    #    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    #    if n_eq_fp > 0:
    #        n_nz = model.init_dFp_n_nz(eval_alg)
    #    else:
    #        assert False, "Cannot perform test, size of Fp is 0. "
    #    
    #
    #@testattr(stddist = True)
    #def test_init_dFp_nz_indices():
    #    """ Test JMIModel.init_dFp_nz_indices method. """
    #    model = mc.getjmimodel()
    #    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    #    if n_eq_fp > 0:
    #        mask = n.ones(model.get_z().size, dtype=int)
    #        nnz = model.init_dFp_n_nz(eval_alg)
    #        row = n.ndarray(nnz, dtype=int)
    #        col = n.ndarray(nnz, dtype=int)
    #        model.init_dFp_nz_indices(eval_alg, indep_vars, mask, row, col)
    #    else:
    #       assert False, "Cannot perform test, size of Fp is 0. " 
    #    
    #
    #@testattr(stddist = True)
    #def test_init_dFp_dim():
    #    """ Test JMIModel.init_dFp_dim method. """
    #    model = mc.getjmimodel()
    #    n_eq_f0, n_eq_f1, n_eq_fp = model.init_get_sizes()
    #    if n_eq_fp > 0:
    #        mask = n.ones(model.get_z().size, dtype=int)
    #        dF_n_cols, dF_n_nz = model.init_dFp_dim(eval_alg, sparsity,
    #                                                 indep_vars, mask) 
    #    else:
    #        assert False, "Cannot perform test, size of Fp is 0. "
    
    
    @testattr(stddist = True)
    def test_opt_getset_optimization_interval(self):
        """Test JMIModel.opt_[set|get]_optimization_interval methods."""
        st_set = ct.c_double(5)
        # 0 = fixed, 1 = free (free NOT YET SUPPORTED)
        stf_set = ct.c_int(0)
        ft_set = ct.c_double(20)
        # 0 = fixed, 1 = free (free NOT YET SUPPORTED)
        ftf_set = ct.c_int(0)
        self.vdp.jmimodel.opt_set_optimization_interval(st_set, stf_set, ft_set, ftf_set)
        st_get, stf_get, ft_get, ftf_get = self.vdp.jmimodel.opt_get_optimization_interval()
        
        nose.tools.assert_equal(st_set.value, st_get)
        nose.tools.assert_equal(stf_set.value, stf_get)
        nose.tools.assert_equal(ft_set.value, ft_get)
        nose.tools.assert_equal(ftf_set.value, ftf_get)
    
    @testattr(stddist = True)
    def test_opt_get_n_p_opt(self):
        """ Test opt_get_n_p_opt method. """
        assert isinstance(self.vdp.jmimodel.opt_get_n_p_opt(), int),\
            "Method does not return int."
    
    @testattr(stddist = True)
    def test_opt_getset_p_opt_indices(self):
        """ Test JMIModel.opt_set_p_opt_indices method. """
        n_pi = self.vdp.jmimodel.get_real_pi().size
        if n_pi > 0:
            # test set
            set_indices = N.zeros(1, dtype=int)
            set_indices[0]=0
            self.vdp.jmimodel.opt_set_p_opt_indices(1, set_indices)
            #test get
            get_indices = N.ones(1, dtype=int)
            self.vdp.jmimodel.opt_get_p_opt_indices(get_indices)
            nose.tools.assert_equal(self.vdp.jmimodel.opt_get_n_p_opt(), 1)
            nose.tools.assert_equal(set_indices[0], get_indices[0])
        else:
            assert False, "pi vector is empty"    
    
    @testattr(stddist = True)
    def test_opt_get_sizes(self):
        """ Test opt_get_sizes method. """
        n_eq_j, n_eq_l, n_eq_ffdp, n_eq_ceq, n_eq_cineq, n_eq_heq, n_eq_hineq = self.vdp.jmimodel.opt_get_sizes()
    
    @testattr(stddist = True)
    def test_opt_J(self):
        """ Test opt_J method. """
        self.vdp.jmimodel.opt_J()
        
    @testattr(stddist = True)
    def test_opt_dJ(self):
        """ Test opt_dJ method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        jac = N.zeros(self.vdp.jmimodel.get_z().size)
        self.vdp.jmimodel.opt_dJ(eval_alg, sparsity, indep_vars, mask, jac)
    
    @testattr(stddist = True)
    def test_opt_dJ_n_nz(self):
        """ Test opt_dJ_n_nz method. """
        assert isinstance(self.vdp.jmimodel.opt_dJ_n_nz(eval_alg), int),\
            "Method does not return int."
    
    @testattr(stddist = True)
    def test_opt_dJ_nz_indices(self):
        """ Test opt_dJ_nz_indices method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        nnz = self.vdp.jmimodel.opt_dJ_n_nz(eval_alg)
        row = N.ndarray(nnz, dtype=int)
        col = N.ndarray(nnz, dtype=int)
        self.vdp.jmimodel.opt_dJ_nz_indices(eval_alg, indep_vars, mask, row, col)
    
    @testattr(stddist = True)
    def test_opt_dJ_dim(self):
        """ Test opt_dJ_dim method. """
        mask = N.ones(self.vdp.jmimodel.get_z().size, dtype=int)
        dJ_n_cols, dJ_n_nz = self.vdp.jmimodel.init_dF0_dim(eval_alg, sparsity, indep_vars,
                                                mask)        
    
    @testattr(stddist = True)
    def test_Model_dae_get_sizes(self):
        """ Test of the dae_get_sizes in Model
        """   
        res_n_eq_F = 3
        n_eq_F, n_eq_R = self.vdp.jmimodel.dae_get_sizes()
        assert n_eq_F==res_n_eq_F, \
               "test_jmi.py: test_Model_dae_get_sizes: Wrong number of DAE equations." 
    
        res_n_eq_F0 = 6
        res_n_eq_F1 = 4
        res_n_eq_Fp = 0
        res_n_eq_R0 = 0
        n_eq_F0,n_eq_F1,n_eq_Fp,n_eq_R0 = self.vdp.jmimodel.init_get_sizes()
        assert n_eq_F0==res_n_eq_F0 and n_eq_F1==res_n_eq_F1 and n_eq_Fp==res_n_eq_Fp and n_eq_R0==res_n_eq_R0, \
               "test_jmi.py: test_Model_dae_get_sizes: Wrong number of DAE initialization equations." 

        res_n_eq_J = 1
        res_n_eq_L = 0
        res_n_eq_Ffdp = 0
        res_n_eq_Ceq = 0
        res_n_eq_Cineq = 1
        res_n_eq_Heq = 0
        res_n_eq_Hineq = 0
        
        n_eq_J, n_eq_L, n_eq_Ffdp,n_eq_Ceq,n_eq_Cineq,n_eq_Heq,n_eq_Hineq = self.vdp.jmimodel.opt_get_sizes()
    
        assert n_eq_J==res_n_eq_J and n_eq_L==res_n_eq_L and n_eq_Ffdp==res_n_eq_Ffdp and n_eq_Ceq==res_n_eq_Ceq and n_eq_Cineq==res_n_eq_Cineq and n_eq_Heq==res_n_eq_Heq and n_eq_Hineq==res_n_eq_Hineq,  \
               "test_jmi.py: test_Model_dae_get_sizes: Wrong number of constraints." 
    
    @testattr(stddist = True)
    def test_state_start_values_fixed(self):
        """ Test of the compiler option state_start_values_fixed
        """
        """ Test of the dae_get_sizes in Model
        """
        
        fpath = os.path.join(get_files_path(), 'Modelica', "VDP_pack.mo")
        cpath = "VDP_pack.VDP"
    
        jmu_name = compile_jmu(cpath, fpath, 
            compiler_options={'state_start_values_fixed':False})
        # Load the dynamic library and XML data
        vdp = JMUModel(jmu_name)
    
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
               
class TestModelGeneric:
    """ Test methods in the jmodelica.jmi.Model class
    """

    @classmethod
    def setUpClass(cls):

        fpath = os.path.join(get_files_path(), 'Modelica', 'DependentParameterTest.mo')
        cpath = "DependentParameterTest"
        
        fname = compile_jmu(cpath, fpath)

    
    def setUp(self):
        """Set up the test case."""
        self.m = JMUModel("DependentParameterTest.jmu")

    @testattr(stddist = True)
    def test_setget_independent_parameter(self):
       """ Test recomputation of dependent parameters when setting
           independent parameters."""

       self.m.set("p1",5)
       
       nose.tools.assert_equal(self.m.get("p2"),15)
       nose.tools.assert_equal(self.m.get("p3"),20)

class TZValues(object):
    """Base class for testing that the z vector has correct values
    after creation of model.
    """

    def __init__(self,fpath,cpath,z):
        self._fpath = fpath
        self._cpath = cpath
        self._z = z
    
    def setUp(self):
        """
        Sets up the test class.
        """
        jmu_name = compile_jmu(self._cpath, self._fpath)
        self._model = JMUModel(jmu_name)

    @testattr(stddist = True)
    def test_z_values(self):
       """ Test recomputation of dependent parameters when setting
           independent parameters."""

       N.testing.assert_almost_equal(self._model.get_z(),self._z)    

class TestDependentParameterEvaluation1(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar1"
        z = [ 2.,  2.,  1.,  1.,  2.,  2.,  2.,  1.,  1.,  1.,  2.,  2.,  1., 0., 1.,  0.,  0.]
        super(TestDependentParameterEvaluation1,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation2(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar2"
        z = [1., 4., 0.]
        super(TestDependentParameterEvaluation2,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation3(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar3"
        z = [  2.,   3.,   4.,   6.,  10.,   0.]
        super(TestDependentParameterEvaluation3,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation4(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar4"
        z = [ 2.,  3.,  2.,  3.,  0.]
        super(TestDependentParameterEvaluation4,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation5(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar5"
        z = [ 2.,  3.,  4.,  6.,  4.,  6.,  0.]
        super(TestDependentParameterEvaluation5,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation6(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar6"
        z =[ 2.,  3.,  4.,  6.,  4.,  6.,  4.,  6.,  4.,  6.,  0.]
        super(TestDependentParameterEvaluation6,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation7(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar7"
        z = [ 2.,  3.,  4.,  6.,  4.,  6.,  0.]
        super(TestDependentParameterEvaluation7,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation8(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepPar8"
        z = [ 2.,  1.,  3.,  0.,  1.,  1.,  0.,  0.,  0.,  1.,  1.,  1.,  0.]
        super(TestDependentParameterEvaluation8,self).__init__(fpath,cpath,z)

class TestDependentParameterEvaluation9(TZValues):
    """Test evaluation of dependent parameters.
    """

    def __init__(self):
        fpath = os.path.join(get_files_path(), 'Modelica', "DepParTests.mo")
        cpath = "DepParTests.DepRec1"
        z = [ 3.,  3.,  4.,  6.,  3.,  3.,  4.,  6.,  3.,  3.,  4.,  6.,  0.]
        super(TestDependentParameterEvaluation9,self).__init__(fpath,cpath,z)


class Test_JMU_methods:
    """
    This class tests the methods jmu_name and package_jmu.
    """
    
    @testattr(stddist = True)
    def test_jmu_name(self):
        """
        Test the method jmu_name.
        """
        name = jmi.get_jmu_name('VDP_pack.VDP')
        assert name == 'VDP_pack_VDP.jmu'
        name = jmi.get_jmu_name('VDP')
        assert name == 'VDP.jmu'
        name = jmi.get_jmu_name('VDP_pack')
        assert name == 'VDP_pack.jmu'
    
    @testattr(stddist = True)
    def test_package_jmu(self):
        """
        Test the method package_jmu. Basic test.
        """
        fpath_ODE = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        cpath_ODE = 'VDP_pack.VDP'
        jmu_name = compile_jmu(cpath_ODE, fpath_ODE)
        
        assert os.path.exists(jmu_name)
