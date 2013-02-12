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

"""Tests for the pyfmi.simulation.assimulo module."""
import logging
import nose
import os
import numpy as N
import pylab as P
from scipy.io.matlab.mio import loadmat

from pymodelica.compiler import compile_jmu, compile_fmu
from pyfmi.fmi_deprecated import FMUModel2
from pyfmi.fmi import FMUModel, load_fmu, FMUException
from pyfmi.common.io import ResultDymolaTextual
from tests_jmodelica import testattr, get_files_path

try:
    from pyfmi.simulation.assimulo_interface import FMIODE
    from pyfmi.simulation.assimulo_interface import write_data
    from pyfmi.common.core import TrajectoryLinearInterpolation
    from assimulo.solvers import CVode
    from assimulo.solvers import IDA
except (NameError, ImportError):
    logging.warning('Could not load Assimulo module. Check pyfmi.check_packages()')

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_mos  = os.path.join(get_files_path(), 'Modelica')


def input_linear(t):
    if t < 0.5:
        return t
    elif t < 1.0:
        return 0.5
    elif t < 1.5:
        return t-0.5
    elif t < 2.0:
        return 2.5-t
    elif t < 2.5:
        return 0.5
    else:
        return 3.0-t
        
input_object = (["u"],input_linear)

class Test_Events:
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        file_name = os.path.join(get_files_path(), 'Modelica', 'EventIter.mo')

        compile_fmu("EventIter.EventInfiniteIteration1", file_name)
        compile_fmu("EventIter.EventInfiniteIteration2", file_name)
        compile_fmu("EventIter.EventInfiniteIteration3", file_name)
    
    @testattr(stddist = True)
    def test_event_infinite_iteration_1(self):
        model = load_fmu("EventIter_EventInfiniteIteration1.fmu")
        nose.tools.assert_raises(FMUException, model.initialize)
        
    @testattr(stddist = True)
    def test_event_infinite_iteration_2(self):
        model = load_fmu("EventIter_EventInfiniteIteration2.fmu")
        nose.tools.assert_raises(FMUException, model.initialize)
        
    @testattr(assimulo = True)
    def test_event_infinite_iteration_3(self):
        model = load_fmu("EventIter_EventInfiniteIteration3.fmu")
        nose.tools.assert_raises(FMUException, model.simulate)

class Test_Relations:
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        file_name = os.path.join(get_files_path(), 'Modelica', 'RelationTests.mo')

        compile_fmu("RelationTests.RelationLE", file_name)
        compile_fmu("RelationTests.RelationGE", file_name)
        compile_fmu("RelationTests.RelationLEInv", file_name)
        compile_fmu("RelationTests.RelationGEInv", file_name)
        compile_fmu("RelationTests.RelationLEInit", file_name)
        compile_fmu("RelationTests.RelationGEInit", file_name)
        compile_fmu("RelationTests.TestRelationalOp1", file_name)
        
    @testattr(assimulo = True)
    def test_relation_le(self):
        model = load_fmu("RelationTests_RelationLE.fmu")
        opts = model.simulate_options()
        opts["CVode_options"]["maxh"] = 0.001
        res = model.simulate(final_time=3.5, input=input_object,options=opts)
        
        nose.tools.assert_almost_equal(N.interp(0.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(2.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.75,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.25,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(1.5,res["time"],res["y"]),0.5,places=2)
        
    @testattr(assimulo = True)
    def test_relation_leinv(self):
        model = load_fmu("RelationTests_RelationLEInv.fmu")
        opts = model.simulate_options()
        opts["CVode_options"]["maxh"] = 0.001
        res = model.simulate(final_time=3.5, input=input_object,options=opts)
        
        nose.tools.assert_almost_equal(N.interp(0.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(2.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.75,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.25,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(1.5,res["time"],res["y"]),0.5,places=2)
        
    @testattr(assimulo = True)
    def test_relation_ge(self):
        model = load_fmu("RelationTests_RelationGE.fmu")
        opts = model.simulate_options()
        opts["CVode_options"]["maxh"] = 0.001
        res = model.simulate(final_time=3.5, input=input_object,options=opts)
        
        nose.tools.assert_almost_equal(N.interp(0.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(2.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.75,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.25,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(1.5,res["time"],res["y"]),0.5,places=2)
        
    @testattr(assimulo = True)
    def test_relation_geinv(self):
        model = load_fmu("RelationTests_RelationGEInv.fmu")
        opts = model.simulate_options()
        opts["CVode_options"]["maxh"] = 0.001
        res = model.simulate(final_time=3.5, input=input_object,options=opts)
        
        nose.tools.assert_almost_equal(N.interp(0.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(2.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.25,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.75,res["time"],res["y"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(0.75,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_not_almost_equal(N.interp(2.25,res["time"],res["x"]),0.5,places=2)
        nose.tools.assert_almost_equal(N.interp(1.5,res["time"],res["y"]),0.5,places=2)
        
    @testattr(assimulo = True)
    def test_relation_leinit(self):
        model = load_fmu("RelationTests_RelationLEInit.fmu")
        
        res = model.simulate(final_time=0.1)
        
        nose.tools.assert_almost_equal(res["x"][0],1.0,places=3)
        nose.tools.assert_almost_equal(res["y"][0],0.0,places=3)
        
    @testattr(assimulo = True)
    def test_relation_geinit(self):
        model = load_fmu("RelationTests_RelationGEInit.fmu")
        
        res = model.simulate(final_time=0.1)
        
        nose.tools.assert_almost_equal(res["x"][0],0.0,places=3)
        nose.tools.assert_almost_equal(res["y"][0],1.0,places=3)

    @testattr(assimulo = True)
    def test_relation_op_1(self):
        model = load_fmu("RelationTests_TestRelationalOp1.fmu")
        
        res = model.simulate(final_time=10)
        
        nose.tools.assert_almost_equal(N.interp(3.00,res["time"],res["der(v1)"]),1.0,places=3)
        nose.tools.assert_almost_equal(N.interp(3.40,res["time"],res["der(v1)"]),0.0,places=3)
        nose.tools.assert_almost_equal(N.interp(8.00,res["time"],res["der(v1)"]),0.0,places=3)
        nose.tools.assert_almost_equal(N.interp(8.25,res["time"],res["der(v1)"]),1.0,places=3)
        nose.tools.assert_almost_equal(N.interp(4.00,res["time"],res["der(v2)"]),1.0,places=3)
        nose.tools.assert_almost_equal(N.interp(4.20,res["time"],res["der(v2)"]),0.0,places=3)
        nose.tools.assert_almost_equal(N.interp(7.00,res["time"],res["der(v2)"]),0.0,places=3)
        nose.tools.assert_almost_equal(N.interp(7.20,res["time"],res["der(v2)"]),1.0,places=3)

class Test_FMI_ODE:
    """
    This class tests pyfmi.simulation.assimulo.FMIODE and together
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
        self._bounce  = load_fmu('bouncingBall.fmu',path_to_fmus)
        self._dq = load_fmu('dq.fmu',path_to_fmus)
        self._bounce.initialize()
        self._dq.initialize()
        self._bounceSim = FMIODE(self._bounce)
        self._dqSim     = FMIODE(self._dq)
    
    @testattr(assimulo = True)
    def test_no_state1(self):
        """
        Tests simulation when there is no state in the model (Example1).
        """
        model = load_fmu("NoState_Example1.fmu")
        
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
        model = load_fmu("NoState_Example2.fmu")
        
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
        self._bounceSim._model.continuous_states = y
        solver = lambda x:1
        solver.rtol = 1.e-4
        solver.t = 1.0
        solver.y = y
        solver.y_sol = [y]
        solver.continuous_output = False
        
        self._bounceSim.initialize(solver)
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
        model = load_fmu('Pendulum_0Dynamic.fmu', path_to_fmus)
        
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
        model = load_fmu('Robot.fmu', path_to_fmus)
        
        res = model.simulate(final_time=2.0)
        solver = res.solver
        
        nose.tools.assert_almost_equal(solver.t, 1.856045, places=3)    
        
    @testattr(windows = True)
    def test_typeDefinitions_simulation(self):
        """
        This tests a FMU with typeDefinitions including StringType and BooleanType
        """
        model = load_fmu('Robot_Dym74FD01.fmu', path_to_fmus)
        
        res = model.simulate(final_time=2.0)
        solver = res.solver
        
        nose.tools.assert_almost_equal(solver.t, 1.856045, places=3)        

    @testattr(assimulo = True)
    def test_assert_raises_sensitivity_parameters(self):
        """
        This tests that an exception is raised if a sensitivity calculation
        is to be perfomed and the parameters are not contained in the model.
        """
        fmu_name = compile_fmu('EventIter.EventMiddleIter', os.path.join(path_to_mos,'EventIter.mo'))

        model = load_fmu(fmu_name)
        opts = model.simulate_options()
        opts["sensitivities"] = ["hej", "hopp"]
        
        nose.tools.assert_raises(FMUException,model.simulate,0,1,(),'AssimuloFMIAlg',opts)

    @testattr(assimulo = True)
    def test_event_iteration(self):
        """
        This tests FMUs with event iteration (JModelica.org).
        """
        fmu_name = compile_fmu('EventIter.EventMiddleIter', os.path.join(path_to_mos,'EventIter.mo'))

        model = load_fmu(fmu_name)

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
        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-4
        opts["CVode_options"]["atol"] = 1e-6
        res = bounce.simulate(start_time=2.,final_time=5.,options=opts)
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
        bounce = load_fmu('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize()
        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-4
        opts["CVode_options"]["atol"] = 1e-6
        res = bounce.simulate(final_time=3., options=opts)
        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)
        
        #Writing after
        bounce = load_fmu('bouncingBall.fmu', path_to_fmus)
        bounce.initialize()
        opt = bounce.simulate_options()
        opt['continuous_output'] = False
        opt['initialize']=False
        opt["CVode_options"]["rtol"] = 1e-4
        opt["CVode_options"]["atol"] = 1e-6
        res = bounce.simulate(final_time=3., options=opt)
        
        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)
        
        #Test with predefined FMUModel
        model = load_fmu(os.path.join(path_to_fmus,'bouncingBall.fmu'))
        #model.initialize()
        res = model.simulate(final_time=3.,options=opts)

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
        bounce = load_fmu('bouncingBall.fmu', path_to_fmus)
        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-4
        opts["CVode_options"]["atol"] = 1e-6
        res = bounce.simulate(final_time=3., options=opts)

        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(res.solver.rtol, 1e-4, 6)
        assert res.solver.iter == 'Newton'
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        nose.tools.assert_almost_equal(time[-1],3.000000,5)
        
        #Writing continuous
        bounce = load_fmu('bouncingBall.fmu', path_to_fmus)
        #bounce.initialize(options={'initialize':False})
        res = bounce.simulate(final_time=3.,
            options={'initialize':True,'CVode_options':{'iter':'FixedPoint','rtol':1e-6,'atol':1e-6}})
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
        bounce = load_fmu('bouncingBall.fmu', path_to_fmus)
        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-4
        opts["CVode_options"]["atol"] = 1e-6
        #bounce.initialize()
        res = bounce.simulate(final_time=3., options=opts)

        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
        
        bounce.reset()
        #bounce.initialize()
        
        nose.tools.assert_almost_equal(bounce.get('h'), 1.00000,5)
        
        res = bounce.simulate(final_time=3.,options=opts)

        height = res['h']
        time = res['time']
        
        nose.tools.assert_almost_equal(height[0],1.000000,5)
        nose.tools.assert_almost_equal(height[-1],-0.9804523,5)
    
class Test_ODE_JACOBIANS1:
    
    @classmethod
    def setUpClass(cls):
        cname='Furuta'
        fname = os.path.join(get_files_path(), 'Modelica', 'furuta.mo')
        
        _fn_furuta = compile_fmu(cname, fname, compiler_options={'generate_ode_jacobian':True,'fmi_version':2.0})
        
    def setUp(self):
        pass

    @testattr(assimulo = True)
    def test_ode_simulation_furuta(self): 
        
        m_furuta = FMUModel2('Furuta.fmu')
        
        m_furuta.initialize()
        print "Starting simulation"
        
        opts = m_furuta.simulate_options()
        opts['with_jacobian'] = True
        res = m_furuta.simulate(final_time=100, options=opts)
    
        A,B,C,D,n_err1 = m_furuta.check_jacobians()
        
        opts['with_jacobian'] = False
        res = m_furuta.simulate(final_time=100, options=opts)
        
        A,B,C,D,n_err2 = m_furuta.check_jacobians()
        nose.tools.assert_equals(n_err1+n_err2, 0)

class Test_ODE_JACOBIANS2:
    
    @classmethod
    def setUpClass(cls):
        cname='NonLinear.MultiSystems'
        fname = os.path.join(get_files_path(), 'Modelica', 'NonLinear.mo')
        
        _fn_nonlin = compile_fmu(cname, fname, compiler_options={'generate_ode_jacobian':True,'fmi_version':2.0})
        
    def setUp(self):
        pass

    @testattr(assimulo = True)
    def test_ode_simulation_NonLinear(self):
        
        m_nonlin = FMUModel2('NonLinear_MultiSystems.fmu')
        
        m_nonlin.initialize()
        
        A,B,C,D,n_err = m_nonlin.check_jacobians()
        nose.tools.assert_equals(n_err, 0)
        
        
class Test_ODE_JACOBIANS3:
    
    @classmethod
    def setUpClass(cls):
        cname='DISTLib.Examples.Simulation'
        fname = os.path.join(get_files_path(), 'Modelica', 'DISTLib.mo')
        
        _fn_distlib = compile_fmu(cname, fname, compiler_options={'generate_ode_jacobian':True,'fmi_version':2.0})
        
    def setUp(self):
        pass
    
    @testattr(assimulo = True)
    def test_ode_simulation_distlib(self): 
        
        m_distlib1 = FMUModel2('DISTLib_Examples_Simulation.fmu')
        m_distlib2 = FMUModel2('DISTLib_Examples_Simulation.fmu')
        m_distlib1.initialize()
        m_distlib2.initialize()
        
        opts = m_distlib1.simulate_options()
        opts['with_jacobian'] = True
        res = m_distlib1.simulate(final_time=70, options=opts)
        res = m_distlib2.simulate(final_time=70)
        
        A,B,C,D,n_err1 = m_distlib1.check_jacobians()

        A,B,C,D,n_err2 = m_distlib2.check_jacobians()
        nose.tools.assert_equals(n_err1+n_err2, 0)
        
 
class Test_ODE_JACOBIANS4:
    
    @classmethod
    def setUpClass(cls):
        cname='NonLinear.TwoSystems_wIO'
        fname = os.path.join(get_files_path(), 'Modelica', 'NonLinearIO.mo')
        
        fn_nonlinIO = compile_fmu(cname, fname, compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
        
    def setUp(self):
        
        pass       
        
    @testattr(assimulo = True)
    def test_ode_simulation_NonLinearIO(self):
        m_nonlinIO = FMUModel2('NonLinear_TwoSystems_wIO.fmu')
        
        m_nonlinIO.set('u', 1)
        m_nonlinIO.set('u1', 10000)
        m_nonlinIO.set('u2', 1)
        m_nonlinIO.set('u3', 10000)
        
        m_nonlinIO.initialize()
        
        A,B,C,D,n_err = m_nonlinIO.check_jacobians()
        nose.tools.assert_equals(n_err, 0)
        
        
class Test_ODE_JACOBIANS5:
    
    @classmethod
    def setUpClass(cls):
        cname='BlockOdeJacTest'
        fname = os.path.join(get_files_path(), 'Modelica', 'BlockOdeJacTest.mo')
        
        _fn_block = compile_fmu(cname, fname, compiler_options={'generate_ode_jacobian':True,'generate_runtime_option_parameters':False,'fmi_version':2.0})
        
    def setUp(self):
        pass
    
    @testattr(assimulo = True)
    def test_ode_simulation_distlib(self): 
        
        m_block = FMUModel2('BlockOdeJacTest.fmu')
        m_block.initialize()
        
        A,B,C,D,n_err = m_block.check_jacobians()       
        nose.tools.assert_equals(n_err, 0)
