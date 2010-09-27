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

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica.algorithm_drivers import InvalidAlgorithmOptionException
from jmodelica.algorithm_drivers import InvalidSolverArgumentException
from jmodelica.algorithm_drivers import UnrecognizedOptionError

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
        
        cls.jmu_name = compile_jmu(cpath_vdp, fpath_vdp)
        
    def setUp(self):
        """
        Sets up the test case.
        """
        self.model_vdp = JMUModel(Test_init_ipopt.jmu_name)

    @testattr(ipopt = True)
    def test_initialize(self):
        """ Test the jmodelica.initialize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum"
        
        jmu_pend = compile_jmu(cpath_pend, fpath_pend)
        pend = JMUModel(jmu_pend)
        
        res = pend.initialize()

        theta=res['theta']
        dtheta=res['dtheta']
        x=res['x']
        dx=res['dx']
        _dtheta=res['der(theta)']
        ddtheta=res['der(dtheta)']
        _dx=res['der(x)']
        ddx=res['der(dx)']
    
        assert N.abs(theta[-1] - 0.1) < 1e-3, \
            "Wrong value of variable theta using jmodelica.initialize."
        assert N.abs(dtheta[-1] - 0.) < 1e-3, \
            "Wrong value of variable dtheta using jmodelica.initialize."
        assert N.abs(x[-1] - 0) < 1e-3, \
            "Wrong value of variable x using jmodelica.initialize."
        assert N.abs(dx[-1] - 0) < 1e-3, \
            "Wrong value of variable dx using jmodelica.initialize."
        assert N.abs(_dtheta[-1] - 0) < 1e-3, \
            "Wrong value of variable der(theta) using jmodelica.initialize."
        assert N.abs(ddtheta[-1] - 0.09983341) < 1e-3, \
            "Wrong value of variable der(dtheta) using jmodelica.initialize."
        assert N.abs(_dx[-1] - 0) < 1e-3, \
            "Wrong value of variable der(x) using jmodelica.initialize."
        assert N.abs(ddx[-1] - 0) < 1e-3, \
            "Wrong value of variable der(dx) using jmodelica.initialize."
        
    @testattr(ipopt = True)
    def test_initialize_with_solverargs(self):
        """ Test the jmodelica.initialize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum"
        
        jmu_pend = compile_jmu(cpath_pend, fpath_pend)
        pend = JMUModel(jmu_pend)
        
        res = pend.initialize(options={'IPOPT_options':{'max_iter':1000}})

        theta=res['theta']
        dtheta=res['dtheta']
        x=res['x']
        dx=res['dx']
        _dtheta=res['der(theta)']
        ddtheta=res['der(dtheta)']
        _dx=res['der(x)']
        ddx=res['der(dx)']
    
        assert N.abs(theta[-1] - 0.1) < 1e-3, \
            "Wrong value of variable theta using jmodelica.initialize."
        assert N.abs(dtheta[-1] - 0.) < 1e-3, \
            "Wrong value of variable dtheta using jmodelica.initialize."
        assert N.abs(x[-1] - 0) < 1e-3, \
            "Wrong value of variable x using jmodelica.initialize."
        assert N.abs(dx[-1] - 0) < 1e-3, \
            "Wrong value of variable dx using jmodelica.initialize."
        assert N.abs(_dtheta[-1] - 0) < 1e-3, \
            "Wrong value of variable der(theta) using jmodelica.initialize."
        assert N.abs(ddtheta[-1] - 0.09983341) < 1e-3, \
            "Wrong value of variable der(dtheta) using jmodelica.initialize."
        assert N.abs(_dx[-1] - 0) < 1e-3, \
            "Wrong value of variable der(x) using jmodelica.initialize."
        assert N.abs(ddx[-1] - 0) < 1e-3, \
            "Wrong value of variable der(dx) using jmodelica.initialize."

    @testattr(ipopt = True)
    def test_optimize(self):
        """ Test the jmodelica.optimize function using all default parameters. """
        fpath_pend = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        cpath_pend = "Pendulum_pack.Pendulum_Opt"
        jmu_pend = compile_jmu(cpath_pend, fpath_pend,compiler_options={'state_start_values_fixed':True})
        pend = JMUModel(jmu_pend)
        
        res = pend.optimize()
        cost=res['cost']
        
        assert N.abs(cost[-1] - 1.2921683e-01) < 1e-3, \
            "Wrong value of cost function using jmodelica.optimize with vdp."
   

    @testattr(ipopt = True)
    def test_optimize_set_n_cp(self):
        """ Test the jmodelica.optimize function and setting n_cp in alg_args.
        """
        res = self.model_vdp.optimize(options={'n_cp':10})
        cost=res['cost']
        
        assert N.abs(cost[-1] - 2.34602647e+01 ) < 1e-3, \
                "Wrong value of cost function using jmodelica.optimize with vdp. \
                cost.x[-1] was: "+str(cost[-1])
            
    @testattr(ipopt = True)
    def test_optimize_set_args(self):
        """Test the jmodelica.optimize function and setting some 
        algorithm and solver args.
        """
        res_file_name = 'test_optimize_set_result_mesh.txt'
        res = self.model_vdp.optimize(
            options={'result_mesh':'element_interpolation', 
                     'result_file_name':res_file_name,
                     'IPOPT_options':{'max_iter':100}})
        cost=res['cost']
        
        assert N.abs(cost[-1] - 2.3469089e+01) < 1e-3, \
                "Wrong value of cost function using jmodelica.optimize with vdp."


    @testattr(ipopt = True)
    def test_optimize_invalid_options(self):
        """ Test that the jmodelica.optimize function raises exception 
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

    @testattr(assimulo = True)
    def test_simulate(self):
        """ Test the jmodelica.simulate function using all default parameters."""
        sim_res = self.model_rlc.simulate()
        resistor_v = sim_res['resistor.v']
        
        assert N.abs(resistor_v[-1] - 0.138037041741) < 1e-3, \
            "Wrong value in simulation result using jmodelica.simulate with rlc."
        
    @testattr(assimulo = True)
    def test_simulate_set_argument(self):
        """ Test the jmodelica.simulate function and setting an 
        algorithm argument.
        """
        sim_res = self.model_rlc.simulate(final_time=30.0)
        resistor_v = sim_res['resistor.v']
        
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3, \
            "Wrong value in simulation result using jmodelica.simulate with rlc."
        
    @testattr(assimulo = True)
    def test_simulate_set_probl_arg(self):
        """ Test that it is possible to set properties in assimulo and 
        that an exception is raised if the argument is invalid. 
        """
        opts = self.model_rlc.simulate_options()
        opts['IDA_options']={'max_eIter':100, 'maxh':0.1}
        sim_res = self.model_rlc.simulate(options = opts)
        
        opts = sim_res.options
        opts['IDA_options']={'maxeter':10}
        nose.tools.assert_raises(InvalidSolverArgumentException,
                                 self.model_rlc.simulate,options=opts)
        
    @testattr(assimulo = True)
    def test_simulate_invalid_solver_arg(self):
        """ Test that the jmodelica.simulate function raises an exception for an 
            invalid solver argument.
        """
        opts = self.model_rlc.simulate_options()
        opts['IDA_options']={'mxiter':10}
        nose.tools.assert_raises(InvalidSolverArgumentException,
                                 self.model_rlc.simulate, options=opts)

    @testattr(assimulo = True)
    def test_simulate_invalid_solver(self):
        """ Test that the jmodelica.optimize function raises exception 
        for an invalid solver.
        """
        opts = self.model_rlc.simulate_options()
        opts['solver']='IDAR'
        nose.tools.assert_raises(InvalidAlgorithmOptionException,
                                 self.model_rlc.simulate,options=opts)
      
    @testattr(assimulo=True)
    def test_simulate_w_ode(self):
        """ Test jmodelica.simulate with ODE problem and setting solver 
        options."""
        jmu_name = compile_jmu(self.cpath_vdp, self.fpath_vdp, 
            compiler_options={'state_start_values_fixed':True},target='model')
        model = JMUModel(jmu_name)
        opts = model.simulate_options()
        opts['solver']='CVode'
        opts['ncp']=0
        opts['CVode_options']={'discr':'BDF', 'iter':'Newton'}
        sim_res = model.simulate(final_time=20, options=opts)
        x1=sim_res['x1']
        x2=sim_res['x2']
        
        assert N.abs(x1[-1] + 0.736680243) < 1e-5, \
               "Wrong value in simulation result in VDP_assimulo.py" 
        assert N.abs(x2[-1] - 1.57833994) < 1e-5, \
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
        name = compile_jmu(self.cpath_minit, self.fpath_minit)
        model = JMUModel(name)
        
        nose.tools.ok_(model.simulate())
        
        model = JMUModel(name)
        
        nose.tools.assert_raises(Exception,
                                 model.simulate,
                                 alg_args={'initialize':False})


