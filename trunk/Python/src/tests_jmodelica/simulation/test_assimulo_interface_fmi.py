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

"""Tests for the jmodelica.simulation.assimulo module."""
import logging
import nose
import os
import numpy as N
import pylab as P
from scipy.io.matlab.mio import loadmat

from jmodelica.compiler import compile_jmu, compile_fmu
from pyfmi.fmi import FMUModel
from pyfmi.common.io import ResultDymolaTextual
from tests_jmodelica import testattr, get_files_path

try:
    from pyfmi.simulation.assimulo_interface import FMIODE
    from pyfmi.simulation.assimulo_interface import write_data
    from pyfmi.common.core import TrajectoryLinearInterpolation
    from assimulo.solvers import CVode
    from assimulo.solvers import IDA
except NameError, ImportError:
    logging.warning('Could not load Assimulo module. Check jmodelica.check_packages()')

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_mos  = os.path.join(get_files_path(), 'Modelica')

class Test_FMI_ODE:
    """
    This class tests jmodelica.simulation.assimulo.FMIODE and together
    with Assimulo. Requires that Assimulo is installed.
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        file_name = os.path.join(get_files_path(), 'Modelica', 'noState.mo')

        _ex1_name = compile_fmu("NoState.Example1", file_name)
        _ex2_name = compile_fmu("NoState.Example2", file_name)
        
    def setUp(self):
        """
        Load the test model.
        """
        self._bounce  = FMUModel('bouncingBall.fmu',path_to_fmus)
        self._dq = FMUModel('dq.fmu',path_to_fmus)
        self._bounce.initialize()
        self._dq.initialize()
        self._bounceSim = FMIODE(self._bounce)
        self._dqSim     = FMIODE(self._dq)
    
    @testattr(assimulo = True)
    def test_no_state1(self):
        """
        Tests simulation when there is no state in the model (Example1).
        """
        model = FMUModel("NoState_Example1.fmu")
        
        res = model.simulate(final_time=10)
        
        x = res['x']
        y = res['y']
        z = res['z']
        
        nose.tools.assert_almost_equal(x[0] ,1.000000000)
        nose.tools.assert_almost_equal(x[-1],-2.000000000)
        nose.tools.assert_almost_equal(y[0] ,-1.000000000)
        nose.tools.assert_almost_equal(y[-1],-1.000000000)
        nose.tools.assert_almost_equal(z[0] ,1.000000000)
        nose.tools.assert_almost_equal(z[-1],4.000000000)
        
    @testattr(assimulo = True)
    def test_no_state2(self):
        """
        Tests simulation when there is no state in the model (Example2).
        """
        model = FMUModel("NoState_Example2.fmu")
        
        res = model.simulate(final_time=10)
        
        x = res['x']
        
        nose.tools.assert_almost_equal(x[0] ,-1.000000000)
        nose.tools.assert_almost_equal(x[-1],-1.000000000)
    
    @testattr(assimulo = True)
    def test_result_name_file(self):
        """
        Tests user naming of result file (FMIODE).
        """
        res = self._dq.simulate(options={"initialize":False})
        
        #Default name
        assert res.result_file == "dq_result.txt"
        assert os.path.exists(res.result_file)
        
        res = self._bounce.simulate(options={"result_file_name":
                                    "bouncingBallt_result_test.txt",
                                             "initialize":False})
                                    
        #User defined name
        assert res.result_file == "bouncingBallt_result_test.txt"
        assert os.path.exists(res.result_file)
    
    @testattr(assimulo = True)
    def test_init(self):
        """
        This tests the functionality of the method init. 
        """
        assert self._bounceSim._f_nbr == 2
        assert self._bounceSim._g_nbr == 1
        assert self._bounceSim.state_events == self._bounceSim.g
        assert self._bounceSim.y0[0] == 1.0
        assert self._bounceSim.y0[1] == 0.0
        assert self._dqSim._f_nbr == 1
        assert self._dqSim._g_nbr == 0
        try:
            self._dqSim.state_events
            raise FMUException('')
        except AttributeError:
            pass
        
        #sol = self._bounceSim._sol_real
        
        #nose.tools.assert_almost_equal(sol[0][0],1.000000000)
        #nose.tools.assert_almost_equal(sol[0][1],0.000000000)
        #nose.tools.assert_almost_equal(sol[0][2],0.000000000)
        #nose.tools.assert_almost_equal(sol[0][3],-9.81000000)
        
    @testattr(assimulo = True)
    def test_f(self):
        """
        This tests the functionality of the rhs.
        """
        t = 1.0
        y = N.array([1.0,1.0])
        
        rhs = self._bounceSim.rhs(t,y)
        
        nose.tools.assert_almost_equal(rhs[0],1.00000000)
        nose.tools.assert_almost_equal(rhs[1],-9.8100000)

    
    @testattr(assimulo = True)
    def test_g(self):
        """
        This tests the functionality of the event indicators.
        """
        t = 1.0
        y = N.array([1.0,1.0])
        
        event = self._bounceSim.g(t,y,None)
        
        nose.tools.assert_almost_equal(event[0],1.00000000)
        
        y = N.array([0.5,1.0])
        event = self._bounceSim.g(t,y,None)
        
        nose.tools.assert_almost_equal(event[0],0.50000000)

        
    @testattr(assimulo = True)
    def test_t(self):
        """
        This tests the functionality of the time events.
        """
        t = 1.0
        y = N.array([1.0,1.0])
        
        time = self._bounceSim.t(t,y,None)
        
        assert time == None
        #Further testing of the time event function is needed.
        
    @testattr(assimulo = True)
    def test_handle_result(self):
        """
        This tests the functionality of the handle result method.
        """
        t = 1.0
        y = N.array([1.0,1.0])
        
        solver = lambda x:1
        solver.continuous_output = False
        
        assert len(self._bounceSim._sol_real) == 0
        self._bounceSim.write_cont = False
        self._bounceSim.handle_result(solver,t,y)
        
        assert len(self._bounceSim._sol_real) == 1
        
        
    @testattr(assimulo = True)
    def test_handle_event(self):
        """
        This tests the functionality of the method handle_event.
        """
        y = N.array([1.,1.])
        self._bounceSim._model.real_x = y
        solver = lambda x:1
        solver.rtol = 1.e-4
        solver.t = 1.0
        solver.y = y
        solver.y_sol = [y]
        solver.continuous_output = False

        self._bounceSim.handle_event(solver, None)

        nose.tools.assert_almost_equal(solver.y[0],1.00000000)
        nose.tools.assert_almost_equal(solver.y[1],-0.70000000)
        
        #Further testing of the handle_event function is needed.
    
    @testattr(assimulo = True)
    def test_completed_step(self):
        """
        This tests the functionality of the method completed_step.
        """
        y = N.array([1.,1.])
        solver = lambda x:1
        solver.t = 1.0
        solver.y = y
        assert self._bounceSim.step_events(solver) == 0
        #Further testing of the completed step function is needed.
        
    @testattr(windows = True)
    def test_simulation_completed_step(self):
        """
        This tests a simulation of a Pendulum with dynamic state selection.
        """
        model = FMUModel('Pendulum_0Dynamic.fmu', path_to_fmus)
        
        res = model.simulate(final_time=10)
    
        x1_sim = res['x']
        x2_sim = res['y']
        
        nose.tools.assert_almost_equal(x1_sim[0], 1.000000, 4)
        nose.tools.assert_almost_equal(x2_sim[0], 0.000000, 4)
        nose.tools.assert_almost_equal(x1_sim[-1], 0.290109468, 4)
        nose.tools.assert_almost_equal(x2_sim[-1], -0.956993467, 4)
        
        model = FMUModel('Pendulum_0Dynamic.fmu', path_to_fmus)
        
        res = model.simulate(final_time=10, options={'ncp':1000})
    
        x1_sim = res['x']
        x2_sim = res['y']
        
        nose.tools.assert_almost_equal(x1_sim[0], 1.000000, 4)
        nose.tools.assert_almost_equal(x2_sim[0], 0.000000, 4)
        #nose.tools.assert_almost_equal(x1_sim[-1], 0.290109468, 5)
        #nose.tools.assert_almost_equal(x2_sim[-1], -0.956993467, 5)
    
    @testattr(windows = True)
    def test_terminate_simulation(self):
        """
        This tests a simulation with an event of terminate simulation.
        """
        model = FMUModel('Robot.fmu', path_to_fmus)
        
        res = model.simulate(final_time=2.0)
        solver = res.solver
        
        nose.tools.assert_almost_equal(solver.t, 1.856045, places=3)    
        
    @testattr(windows = True)
    def test_typeDefinitions_simulation(self):
        """
        This tests a FMU with typeDefinitions including StringType and BooleanType
        """
        model = FMUModel('Robot_Dym74FD01.fmu', path_to_fmus)
        
        res = model.simulate(final_time=2.0)
        solver = res.solver
        
        nose.tools.assert_almost_equal(solver.t, 1.856045, places=3)        

    @testattr(assimulo = True)
    def test_event_iteration(self):
        """
        This tests FMUs with event iteration (JModelica.org).
        """
        fmu_name = compile_fmu('EventIter.EventMiddleIter', os.path.join(path_to_mos,'EventIter.mo'))

        model = FMUModel(fmu_name)

        sim_res = model.simulate(final_time=10)

        x = sim_res['x']
        y = sim_res['y']
        z = sim_res['z']
        
        nose.tools.assert_almost_equal(x[0], 2.00000, 4)
        nose.tools.assert_almost_equal(x[-1], 10.000000, 4)
        nose.tools.assert_almost_equal(y[-1], 3.0000000, 4)
        nose.tools.assert_almost_equal(z[-1], 2.0000000, 4)
        
        fmu_name = compile_fmu('EventIter.EventStartIter', os.path.join(path_to_mos,'EventIter.mo'))
        
        model = FMUModel(fmu_name)

        sim_res = model.simulate(final_time=10)

        x = sim_res['x']
        y = sim_res['y']
        z = sim_res['z']
        
        nose.tools.assert_almost_equal(x[0], 1.00000, 4)
        nose.tools.assert_almost_equal(y[0], -1.00000, 4)
        nose.tools.assert_almost_equal(z[0], 1.00000, 4)
        nose.tools.assert_almost_equal(x[-1], -2.000000, 4)
        nose.tools.assert_almost_equal(y[-1], -1.0000000, 4)
        nose.tools.assert_almost_equal(z[-1], 4.0000000, 4)
    
    @testattr(assimulo = True)
    def test_changed_starttime(self):
        """
        This tests a simulation with different start time.
        """
        bounce = FMUModel('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize()
        res = bounce.simulate(start_time=2.,final_time=5.)
        height = res['h']
        time = res['time']

        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.98048862,4)
        nose.tools.assert_almost_equal(time[-1],5.000000,5)
        
    
    @testattr(assimulo = True)
    def test_basic_simulation(self):
        """
        This tests the basic simulation and writing.
        """
        #Writing continuous
        bounce = FMUModel('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize()
        res = bounce.simulate(final_time=3.)
        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)
        
        #Writing after
        bounce = FMUModel('bouncingBall.fmu', path_to_fmus)
        bounce.initialize()
        opt = bounce.simulate_options()
        opt['continuous_output'] = False
        opt['initialize']=False
        res = bounce.simulate(final_time=3., options=opt)
        
        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)
        
        #Test with predefined FMUModel
        model = FMUModel(os.path.join(path_to_fmus,'bouncingBall.fmu'))
        #model.initialize()
        res = model.simulate(final_time=3.)

        height = res['h']
        time = res['time']

        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)


    @testattr(assimulo = True)
    def test_default_simulation(self):
        """
        This test the default values of the simulation using simulate.
        """
        #Writing continuous
        bounce = FMUModel('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize()
        res = bounce.simulate(final_time=3.)

        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(res.solver.rtol, 0.000100, 5)
        assert res.solver.iter == 'Newton'
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)
        
        #Writing continuous
        bounce = FMUModel('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize(options={'initialize':False})
        res = bounce.simulate(final_time=3.,
            options={'initialize':True,'CVode_options':{'iter':'FixedPoint','rtol':1e-6}})
        height = res['h']
        time = res['time']
    
        nose.tools.assert_almost_equal(res.solver.rtol, 0.00000100, 7)
        assert res.solver.iter == 'FixedPoint'
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.98018113,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)

    @testattr(assimulo = True)
    def test_reset(self):
        """
        Test resetting an FMU. (Multiple instances is NOT supported on Dymola
        FMUs)
        """
        #Writing continuous
        bounce = FMUModel('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize()
        res = bounce.simulate(final_time=3.)

        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        
        bounce.reset()
        #bounce.initialize()
        
        nose.tools.assert_almost_equal(bounce.get('h'), 1.00000,5)
        
        res = bounce.simulate(final_time=3.)

        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
