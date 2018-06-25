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
Test module for functions directly in jmodelica Python packages.
"""

import os

import numpy as N
import nose
import nose.tools
import logging

from pymodelica.compiler import compile_jmu, compile_fmu
from pyjmi.jmi import JMUModel
from pyfmi import load_fmu
from tests_jmodelica import testattr, get_files_path
from pyjmi.common.algorithm_drivers import InvalidAlgorithmOptionException
from pyjmi.common.algorithm_drivers import InvalidSolverArgumentException
from pyjmi.common.algorithm_drivers import UnrecognizedOptionError

try:
    from assimulo.explicit_ode import *
except ImportError:
    logging.warning('Could not load Assimulo module. Check pyjmi.check_packages()')

try:
    ipopt_present = pyjmi.environ['IPOPT_HOME']
except:
    ipopt_present = False

int = N.int32
N.int = N.int32
    
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
        jmu_name = compile_jmu('DepPar.DepPar1', path, 
            compiler_options={'state_start_values_fixed':True})
        model = JMUModel(jmu_name)
        
        assert (model.get('p1') == 1.0)
        assert (model.get('p2') == 2.0)
        assert (model.get('p3') == 6.0)
        
    @testattr(stddist = True)
    def test_inlined_switches(self):
        """ Test a model that need in-lined switches to initialize. """
        path = os.path.join(get_files_path(), 'Modelica', 'event_init.mo')
        fmu_name = compile_fmu('Init', path)
        model = load_fmu(fmu_name)
        model.initialize()
        assert N.abs(model.get("x") - (-2.15298995))              < 1e-3
        
        
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
        
        cls.jmu_name = compile_jmu(cpath_vdp, fpath_vdp)
        
    def setUp(self):
        """
        Sets up the test case.
        """
        self.model_vdp = JMUModel(Test_init_ipopt.jmu_name)

    @testattr(ipopt = True)
    def test_initialize(self):
        """ Test the pyjmi.JMUModel.initialize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum"
        
        jmu_pend = compile_jmu(cpath_pend, fpath_pend)
        pend = JMUModel(jmu_pend)
        
        res = pend.initialize()

        assert N.abs(res.final('theta') - 0.1)              < 1e-3
        assert N.abs(res.final('dtheta') - 0.)              < 1e-3
        assert N.abs(res.final('x') - 0)                    < 1e-3
        assert N.abs(res.final('dx') - 0)                   < 1e-3
        assert N.abs(res.final('der(theta)') - 0)           < 1e-3
        assert N.abs(res.final('der(dtheta)') - 0.09983341) < 1e-3
        assert N.abs(res.final('der(x)') - 0)               < 1e-3
        assert N.abs(res.final('der(dx)') - 0)              < 1e-3
        
    @testattr(ipopt = True)
    def test_initialize_with_solverargs(self):
        """ Test the pyjmi.JMUModel.initialize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum"
        
        jmu_pend = compile_jmu(cpath_pend, fpath_pend)
        pend = JMUModel(jmu_pend)
        
        res = pend.initialize(options={'IPOPT_options':{'max_iter':1000}})

        assert N.abs(res.final('theta') - 0.1)              < 1e-3
        assert N.abs(res.final('dtheta') - 0.)              < 1e-3
        assert N.abs(res.final('x') - 0)                    < 1e-3
        assert N.abs(res.final('dx') - 0)                   < 1e-3
        assert N.abs(res.final('der(theta)') - 0)           < 1e-3
        assert N.abs(res.final('der(dtheta)') - 0.09983341) < 1e-3
        assert N.abs(res.final('der(x)') - 0)               < 1e-3
        assert N.abs(res.final('der(dx)') - 0)              < 1e-3

    @testattr(ipopt = True)
    def test_optimize(self):
        """ Test the pyjmi.JMUModel.optimize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum_Opt"
        jmu_pend = compile_jmu(cpath_pend, fpath_pend,compiler_options={'state_start_values_fixed':True})
        pend = JMUModel(jmu_pend)
        
        res = pend.optimize()
        
        assert N.abs(res.final('cost') - 1.2921683e-01) < 1e-3
   

    @testattr(ipopt = True)
    def test_optimize_set_n_cp(self):
        """ Test the pyjmi.JMUModel.optimize function and setting n_cp in alg_args.
        """
        res = self.model_vdp.optimize(options={'n_cp':10})
        
        assert N.abs(res.final('cost') - 2.34602647e+01 ) < 1e-3
            
    @testattr(ipopt = True)
    def test_optimize_set_args(self):
        """Test the pyjmi.JMUModel.optimize function and setting some 
        algorithm and solver args.
        """
        res_file_name = 'test_optimize_set_result_mesh.txt'
        res = self.model_vdp.optimize(
            options={'result_mesh':'element_interpolation', 
                     'result_file_name':res_file_name,
                     'IPOPT_options':{'max_iter':100}})
        
        assert N.abs(res.final('cost') - 2.3469089e+01) < 1e-3


    @testattr(ipopt = True)
    def test_optimize_invalid_options(self):
        """ Test that the pyjmi.JMUModel.optimize function raises exception 
        for an invalid algorithm option.
        """
        nose.tools.assert_raises(UnrecognizedOptionError,
                                 self.model_vdp.optimize,
                                 options={'ne':10})
                                 
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

        cls.jmu_name = compile_jmu(cpath_rlc, fpath_rlc, compiler_options={'state_start_values_fixed':True})
        
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
        self.model_rlc = JMUModel(Test_init_assimulo.jmu_name)

    @testattr(stddist = True)
    def test_simulate(self):
        """ Test the pyjmi.JMUModel.simulate function using all default parameters."""
        sim_res = self.model_rlc.simulate()
        
        assert N.abs(sim_res.final('resistor.v') - 0.138037041741) < 1e-3
        
    @testattr(stddist = True)
    def test_simulate_set_argument(self):
        """ Test the pyjmi.JMUModel.simulate function and setting an 
        algorithm argument.
        """
        sim_res = self.model_rlc.simulate(final_time=30.0)
        
        assert N.abs(sim_res.final('resistor.v') - 0.159255008028) < 1e-3
        
    @testattr(stddist = True)
    def test_simulate_set_probl_arg(self):
        """ Test that it is possible to set properties in Assimulo and 
        that an exception is raised if the argument is invalid. 
        """
        opts = self.model_rlc.simulate_options()
        opts['IDA_options']['max_eIter']=100 
        opts['IDA_options']['maxh']=0.1
        sim_res = self.model_rlc.simulate(options = opts)
        
        opts = sim_res.options
        opts['IDA_options']['maxeter']=10
        nose.tools.assert_raises(InvalidSolverArgumentException,
                                 self.model_rlc.simulate,options=opts)
        
    @testattr(stddist = True)
    def test_simulate_invalid_solver_arg(self):
        """ Test that the pyjmi.JMUModel.simulate function raises an exception for an 
            invalid solver argument.
        """
        opts = self.model_rlc.simulate_options()
        opts['IDA_options']['mxiter']=10
        nose.tools.assert_raises(InvalidSolverArgumentException,
                                 self.model_rlc.simulate, options=opts)

    @testattr(stddist = True)
    def test_simulate_invalid_solver(self):
        """ Test that the pyjmi.JMUModel.optimize function raises exception 
        for an invalid solver.
        """
        opts = self.model_rlc.simulate_options()
        opts['solver']='IDAR'
        nose.tools.assert_raises(InvalidAlgorithmOptionException,
                                 self.model_rlc.simulate,options=opts)
    
    @testattr(stddist=True)
    def test_simulate_initialize_arg(self):
        """ Test pyjmi.JMUModel.simulate alg_arg 'initialize'. """
        # This test is built on that simulation without initialization fails.
        # Since simulation without initialization fails far down in Sundials
        # no "proper" exception is thrown which means that I can only test that
        # the general Exception is returned which means that the test is pretty
        # unspecific (the test will pass for every type of error thrown). Therefore,
        # I first test that running the simulation with default settings succeeds, so
        # at least one knows that the error has with initialization to do.
        name = compile_jmu(self.cpath_minit, self.fpath_minit)
        model = JMUModel(name)
        
        nose.tools.ok_(model.simulate())
        
        model = JMUModel(name)
        
        nose.tools.assert_raises(Exception,
                                 model.simulate,
                                 options={'initialize':False})


