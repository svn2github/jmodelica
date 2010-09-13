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

"""
Test module for functions directly in jmodelica.
"""

import os

import numpy as N
import nose
import nose.tools
import warnings
import jmodelica
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
from jmodelica import jmi
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica.algorithm_drivers import InvalidAlgorithmArgumentException
from jmodelica.algorithm_drivers import InvalidSolverArgumentException

try:
    from assimulo.explicit_ode import *
except ImportError:
    warnings.warn('Could not load Assimulo module. Check jmodelica.check_packages()')

try:
    ipopt_present = jmodelica.environ['IPOPT_HOME']
except:
    ipopt_present = False

int = N.int32
N.int = N.int32

# Create compilers
mc = ModelicaCompiler()
mc.set_boolean_option('state_start_values_fixed',True)
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)

    
class Test_init_std:
    """ Class which contains std tests for the init module. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        pass
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    #@testattr(stddist = True)
    #def test_exception_raised(self):
        #""" Test compact functions without passing mofile raises exception."""
        #cpath = "Pendulum_pack.Pendulum"   
        #nose.tools.assert_raises(Exception, jmodelica.simulate, cpath)
        #nose.tools.assert_raises(Exception, jmodelica.optimize, cpath)
        
    @testattr(stddist = True)
    def test_dependent_parameters(self):
        """ Test evaluation of dependent parameters. """
        path = os.path.join(get_files_path(), 'Modelica', 'DepPar.mo')
        model = mc.compile_model('DepPar.DepPar1', path)
        
        assert (model.get('p1') == 1.0), 'Wrong value of independent parameter p1'
        assert (model.get('p2') == 2.0), 'Wrong value of dependent parameter p2'
        assert (model.get('p3') == 6.0), 'Wrong value of dependent parameter p3'
        
        
class Test_init_ipopt:
    """ Class which contains ipopt tests for the init module. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        # VDP model
        fpath_vdp = os.path.join(get_files_path(),'Modelica','VDP.mop')
        cpath_vdp = "VDP_pack.VDP_Opt"
        
        jmi.compile_jmu(cpath_vdp, fpath_vdp)
        cls.dll_vdp = cpath_vdp.replace('.','_',1)
        
    def setUp(self):
        """
        Sets up the test case.
        """
        self.model_vdp = jmi.JMUModel(Test_init_ipopt.dll_vdp+'.jmu')

    @testattr(ipopt = True)
    def test_initialize(self):
        """ Test the jmodelica.initialize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum"
        
        jmu_pend = jmi.compile_jmu(cpath_pend, fpath_pend)
        pend = jmi.JMUModel(jmu_pend)
        
        init_res = pend.initialize()
        res = init_res.result_data
        theta=res.get_variable_data('theta')
        dtheta=res.get_variable_data('dtheta')
        x=res.get_variable_data('x')
        dx=res.get_variable_data('dx')
        _dtheta=res.get_variable_data('der(theta)')
        ddtheta=res.get_variable_data('der(dtheta)')
        _dx=res.get_variable_data('der(x)')
        ddx=res.get_variable_data('der(dx)')
    
        assert N.abs(theta.x[-1] - 0.1) < 1e-3, \
            "Wrong value of variable theta using jmodelica.initialize."
        assert N.abs(dtheta.x[-1] - 0.) < 1e-3, \
            "Wrong value of variable dtheta using jmodelica.initialize."
        assert N.abs(x.x[-1] - 0) < 1e-3, \
            "Wrong value of variable x using jmodelica.initialize."
        assert N.abs(dx.x[-1] - 0) < 1e-3, \
            "Wrong value of variable dx using jmodelica.initialize."
        assert N.abs(_dtheta.x[-1] - 0) < 1e-3, \
            "Wrong value of variable der(theta) using jmodelica.initialize."
        assert N.abs(ddtheta.x[-1] - 0.09983341) < 1e-3, \
            "Wrong value of variable der(dtheta) using jmodelica.initialize."
        assert N.abs(_dx.x[-1] - 0) < 1e-3, \
            "Wrong value of variable der(x) using jmodelica.initialize."
        assert N.abs(ddx.x[-1] - 0) < 1e-3, \
            "Wrong value of variable der(dx) using jmodelica.initialize."
        
    @testattr(ipopt = True)
    def test_initialize_with_solverargs(self):
        """ Test the jmodelica.initialize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum"
        
        jmu_pend = jmi.compile_jmu(cpath_pend, fpath_pend)
        pend = jmi.JMUModel(jmu_pend)
        
        init_res = pend.initialize(solver_args={'max_iter':1000})
        res = init_res.result_data
        theta=res.get_variable_data('theta')
        dtheta=res.get_variable_data('dtheta')
        x=res.get_variable_data('x')
        dx=res.get_variable_data('dx')
        _dtheta=res.get_variable_data('der(theta)')
        ddtheta=res.get_variable_data('der(dtheta)')
        _dx=res.get_variable_data('der(x)')
        ddx=res.get_variable_data('der(dx)')
    
        assert N.abs(theta.x[-1] - 0.1) < 1e-3, \
            "Wrong value of variable theta using jmodelica.initialize."
        assert N.abs(dtheta.x[-1] - 0.) < 1e-3, \
            "Wrong value of variable dtheta using jmodelica.initialize."
        assert N.abs(x.x[-1] - 0) < 1e-3, \
            "Wrong value of variable x using jmodelica.initialize."
        assert N.abs(dx.x[-1] - 0) < 1e-3, \
            "Wrong value of variable dx using jmodelica.initialize."
        assert N.abs(_dtheta.x[-1] - 0) < 1e-3, \
            "Wrong value of variable der(theta) using jmodelica.initialize."
        assert N.abs(ddtheta.x[-1] - 0.09983341) < 1e-3, \
            "Wrong value of variable der(dtheta) using jmodelica.initialize."
        assert N.abs(_dx.x[-1] - 0) < 1e-3, \
            "Wrong value of variable der(x) using jmodelica.initialize."
        assert N.abs(ddx.x[-1] - 0) < 1e-3, \
            "Wrong value of variable der(dx) using jmodelica.initialize."

    @testattr(ipopt = True)
    def test_optimize(self):
        """ Test the jmodelica.optimize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum_Opt"
        jmu_pend = jmi.compile_jmu(cpath_pend, fpath_pend,compiler_options={'state_start_values_fixed':True})
        pend = jmi.JMUModel(jmu_pend)
        
        opt_res = pend.optimize()
        cost=opt_res.result_data.get_variable_data('cost')
        
        assert N.abs(cost.x[-1] - 1.2921683e-01) < 1e-3, \
            "Wrong value of cost function using jmodelica.optimize with vdp."
   

    @testattr(ipopt = True)
    def test_optimize_set_n_cp(self):
        """ Test the jmodelica.optimize function and setting n_cp in alg_args.
        """
        opt_res = self.model_vdp.optimize(alg_args={'n_cp':10})
        cost=opt_res.result_data.get_variable_data('cost')
        
        assert N.abs(cost.x[-1] - 2.34602647e+01 ) < 1e-3, \
                "Wrong value of cost function using jmodelica.optimize with vdp. \
                cost.x[-1] was: "+str(cost.x[-1])
            
    @testattr(ipopt = True)
    def test_optimize_set_args(self):
        """Test the jmodelica.optimize function and setting some algorithm and solver args.
        """
        res_file_name = 'test_optimize_set_result_mesh.txt'
        opt_res = self.model_vdp.optimize(alg_args={'result_mesh':'element_interpolation', 
                                               'result_file_name':res_file_name},
                                     solver_args={'max_iter':100})
        cost=opt_res.result_data.get_variable_data('cost')
        
        assert N.abs(cost.x[-1] - 2.3469089e+01) < 1e-3, \
                "Wrong value of cost function using jmodelica.optimize with vdp."


    @testattr(ipopt = True)
    def test_optimize_invalid_algorithm_arg(self):
        """ Test that the jmodelica.optimize function raises exception for an 
            invalid algorithm argument.
        """
        nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidAlgorithmArgumentException,
                                 self.model_vdp.optimize,
                                 alg_args={'ne':10})
                                 
class Test_init_assimulo:
    """ Class which contains assimulo tests for the init module. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        # RLC model
        fpath_rlc = os.path.join(get_files_path(),'Modelica','RLC_Circuit.mo')
        cpath_rlc = "RLC_Circuit"

        jmi.compile_jmu(cpath_rlc, fpath_rlc, compiler_options={'state_start_values_fixed':True})
        
    def setUp(self):
        """
        Sets up the test case.
        """
        self.cpath_vdp = "VDP_pack.VDP_Opt"
        self.fpath_vdp = os.path.join(get_files_path(),'Modelica','VDP.mop')
        self.cpath_minit = "must_initialize"
        self.fpath_minit = os.path.join(get_files_path(), 'Modelica', 'must_initialize.mo')
        self.fpath_rlc = os.path.join(get_files_path(),'Modelica','RLC_Circuit.mo')
        self.cpath_rlc = "RLC_Circuit"
        self.model_rlc = jmi.JMUModel('RLC_Circuit.jmu')

    @testattr(assimulo = True)
    def test_simulate(self):
        """ Test the jmodelica.simulate function using all default parameters."""
        sim_res = self.model_rlc.simulate()
        resistor_v = sim_res.result_data.get_variable_data('resistor.v')
        
        assert N.abs(resistor_v.x[-1] - 0.138037041741) < 1e-3, \
            "Wrong value in simulation result using jmodelica.simulate with rlc."
        
    @testattr(assimulo = True)
    def test_simulate_set_alg_arg(self):
        """ Test the jmodelica.simulate function and setting an algorithm argument."""    
        sim_res = self.model_rlc.simulate(alg_args={'final_time':30.0})
        resistor_v = sim_res.result_data.get_variable_data('resistor.v')
        
        assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
            "Wrong value in simulation result using jmodelica.simulate with rlc."
        
    @testattr(assimulo = True)
    def test_simulate_set_probl_arg(self):
        """ Test that it is possible to set properties in assimulo and that an 
            exception is raised if the argument is invalid. """
        sim_res = self.model_rlc.simulate(solver_args={'max_eIter':100, 'maxh':0.1})
        nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidSolverArgumentException,
                                 self.model_rlc.simulate,
                                 solver_args={'maxeter':10})
        
    @testattr(assimulo = True)
    def test_simulate_invalid_solver_arg(self):
        """ Test that the jmodelica.simulate function raises an exception for an 
            invalid solver argument.
        """    
        nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidSolverArgumentException,
                                 self.model_rlc.simulate,
                                 solver_args={'mxiter':10})

    @testattr(assimulo = True)
    def test_simulate_invalid_algorithm_arg(self):
        """ Test that the jmodelica.optimize function raises exception for an 
            invalid algorithm argument.
        """
        nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidAlgorithmArgumentException,
                                 self.model_rlc.simulate,
                                 alg_args={'starttime':10})
      
    @testattr(assimulo=True)
    def test_simulate_w_ode(self):
        """ Test jmodelica.simulate with ODE problem and setting solver args."""
        jmi.compile_jmu(self.cpath_vdp, self.fpath_vdp, compiler_options={'state_start_values_fixed':True}
                        ,target='model')
        jmu_name = jmi.get_jmu_name(self.cpath_vdp)
        model = jmi.JMUModel(jmu_name)
        sim_res = model.simulate(alg_args={'solver':'CVode', 'final_time':20, 'num_communication_points':0},
                                     solver_args={'discr':'BDF', 'iter':'Newton'})
        x1=sim_res.result_data.get_variable_data('x1')
        x2=sim_res.result_data.get_variable_data('x2')
        
        assert N.abs(x1.x[-1] + 0.736680243) < 1e-5, \
               "Wrong value in simulation result in VDP_assimulo.py" 
        assert N.abs(x2.x[-1] - 1.57833994) < 1e-5, \
               "Wrong value in simulation result in VDP_assimulo.py"


    
    @testattr(assimulo=True)
    def test_simulate_initialize_arg(self):
        """ Test jmodelica.simulate alg_arg 'initialize'. """
        # This test is built on that simulation without initialization fails.
        # Since simulation without initialization fails far down in Sundials
        # no "proper" exception is thrown which means that I can only test that
        # the general Exception is returned which means that the test is pretty
        # unspecific (the test will pass for every type of error thrown). Therefore,
        # I first test that running the simulation with default settings succeeds, so
        # at least one knows that the error has with initialization to do.
        name = jmi.compile_jmu(self.cpath_minit, self.fpath_minit)
        model = jmi.JMUModel(name)
        
        nose.tools.ok_(model.simulate())
        
        model = jmi.JMUModel(name)
        
        nose.tools.assert_raises(Exception,
                                 model.simulate,
                                 alg_args={'initialize':False})


