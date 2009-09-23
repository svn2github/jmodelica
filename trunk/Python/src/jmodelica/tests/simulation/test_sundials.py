#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.optimization.shooting module."""

import numpy as N
import pylab as p
import matplotlib
import nose

from jmodelica.tests import load_example_standard_model

from jmodelica.simulation.sundials import SundialsOdeSimulator
import jmodelica.simulation.sundials as sundials
import jmodelica.simulation

class TestSundialsOdeSimulator:
    def setUp(self):
        """Load the test model."""
        
        self.m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo', 
                                             'VDP_pack.VDP_Opt')
        self.simulator = SundialsOdeSimulator(self.m)
        
    def test_is_simulator(self):
        assert isinstance(self.simulator, jmodelica.simulation.Simulator)
        
    def test_constructor_parameters(self):
        """Assert that a couple of different parameters exists ni the
           constructor.
        """
        simulator = SundialsOdeSimulator(time_step=0.2,
                                         model=self.m,
                                         abstol=1e-5,
                                         reltol=1e-5,
                                         sensitivity_analysis=True,
                                         return_last=True,
                                         start_time=1,
                                         final_time=20)
        assert simulator.time_step == 0.2
        assert simulator.model == self.m
        assert simulator.abstol == 1e-5
        assert simulator.reltol == 1e-5
        assert simulator.sensitivity_analysis == True
        assert simulator.return_last == True
        assert simulator.get_start_time() == 1
        assert simulator.get_final_time() == 20
                                             
    def test_simulation(self):
        """Run a very basic simulation."""
        
        simulator = self.simulator
        x_before_simulation = simulator.get_model().x.copy()
        simulator.run()
        Ts, ys = simulator.get_solution()
        
        assert len(Ts) == len(ys), "Time points and solution points must be " \
                                   "equal lengths."
        assert len(Ts) >= 5, "A solution was expected got less than 5 points."
        assert not (x_before_simulation==simulator.get_model().x).all(), \
               "Simulation does seem to have been performed."
               
        # Plotting
        fig = p.figure()
        p.plot(Ts, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestSundialsOdeSimulator_test_simulation.png')
               
    def test_return_last(self):
        """Testing the 'return_last'.
        
        The 'return_last' enables the user to ignore the whole solution
        horizon (ie. not accumulate the result).
        
        This saves memory and somewhat speed.
        """
        simulator = self.simulator
        assert simulator.get_return_last() == False # assert Default
        simulator.set_return_last(True)
        assert simulator.get_return_last() == True
        simulator.set_return_last(0)
        assert simulator.get_return_last() == False
        simulator.set_return_last(1)
        assert simulator.get_return_last() == True
        
        # Test property set
        simulator.return_last = True
        assert simulator.get_return_last() == True
        simulator.return_last = 0
        assert simulator.get_return_last() == False
        simulator.return_last = 1
        assert simulator.get_return_last() == True
        simulator.return_last = False
        assert simulator.get_return_last() == False
        
        # Test property get
        simulator.set_return_last(True)
        assert simulator.return_last == True
        simulator.set_return_last(0)
        assert simulator.return_last == False
        simulator.set_return_last(1)
        assert simulator.return_last == True
        simulator.set_return_last(False)
        assert simulator.return_last == False
        
        simulator.return_last = True
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_return_last, "Hello")
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_return_last, 45)
        simulator.run()
        T, Y = simulator.get_solution()
        nose.tools.assert_raises(TypeError, len, T) # Assert scalar
        nose.tools.assert_equal(len(Y), 3)
        
        
    def test_simulation_with_sensivity(self):
        """Run simulation with sensitivity analysis."""
        
        simulator = self.simulator
        simulator.set_sensitivity_analysis(False)
        nose.tools.assert_raises(sundials.SundialsSimulationException,
                                 simulator.set_sensitivity_analysis, -5465)
        nose.tools.assert_raises(sundials.SundialsSimulationException,
                                 simulator.set_sensitivity_analysis, "Hellu")
        simulator.run()
        Ts1, ys1 = simulator.get_solution()
        
        assert len(Ts1) == len(ys1), "Time points and solution points must be " \
                                   "equal lengths."
        assert len(Ts1) >= 5, "A solution was expected got less than 5 points."
        assert simulator.get_sensitivities() == None, "No sensitivity " \
                                                      "calculation should " \
                                                      "have been returned."
        assert simulator.sensitivities == None, "No sensitivity calculation " \
                                                "should have been done."
        assert simulator.get_sensitivity_indices() == None
        assert simulator.sensitivity_indices == None # test property (get)
                                                      
        simulator.set_sensitivity_analysis(True)
        assert simulator.sensitivity_analysis == True # testing property (get)
        simulator.get_model().reset()
        simulator.run()
        Ts2, ys2 = simulator.get_solution()
        N.testing.assert_array_almost_equal(Ts1, Ts2)
        N.testing.assert_array_almost_equal(ys1, ys2, decimal=2)
        assert simulator.get_sensitivities() != None, "Sensitivities should " \
                                                      "have been returned."
        assert simulator.sensitivities != None, "No sensitivity calculation " \
                                                "should have been done."
        assert simulator.get_sensitivity_indices() != None
        assert simulator.sensitivity_indices != None # test property (get)
        
        # TODO: Assert exact size of the sensitivity matrix
                                                      
        simulator.sensitivity_analysis = False # testing property (set)
        simulator.get_model().reset()
        simulator.run()
        Ts3, ys3 = simulator.get_solution()
        N.testing.assert_array_almost_equal(Ts1, Ts3)
        N.testing.assert_array_almost_equal(ys1, ys3)
        assert simulator.get_sensitivities() == None, "No sensitivity " \
                                                      "calculation should " \
                                                      "have been returned."
        assert simulator.sensitivities == None, "No sensitivity calculation " \
                                                "should have been done."
        assert simulator.get_sensitivity_indices() == None
        assert simulator.sensitivity_indices == None # test property (get)
        
    def test_set_get_verbosity(self):
        """Test the verbosity setter/getter.
        
        Setting verbosity is highly useful for debugging, but can at the same
        time be very annoying if too much output is cluttering the console.
        
        This test test not only tests getters and setters but als documents the
        available verbosities.
        
        """
        simulator = self.simulator
        simulator.set_verbosity(SundialsOdeSimulator.QUIET)
        assert SundialsOdeSimulator.QUIET == 0, "QUIET constant should be zero"
        simulator.set_verbosity(SundialsOdeSimulator.WHISPER)
        assert simulator.get_verbosity() == SundialsOdeSimulator.WHISPER
        simulator. verbosity = SundialsOdeSimulator.NORMAL # testing property
        assert simulator.get_verbosity() == SundialsOdeSimulator.NORMAL
        simulator.set_verbosity(SundialsOdeSimulator.LOUD)
        assert simulator.verbosity == SundialsOdeSimulator.LOUD # property test
        simulator.set_verbosity(SundialsOdeSimulator.SCREAM)
        assert simulator.get_verbosity() == SundialsOdeSimulator.SCREAM
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_verbosity, 65487)
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_verbosity, -5465)
        
    def test_set_get_model(self):
        """Test the model setter/getter."""
        simulator = self.simulator
        assert simulator.get_model() == self.m
        
        another_model = load_example_standard_model('VDP_pack_VDP_Opt',
                                                    'VDP.mo', 
                                                    'VDP_pack.VDP_Opt')
        simulator.set_model(another_model)
        assert simulator.get_model() == another_model
        
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_model, None)
                                 
        another_model = load_example_standard_model('VDP_pack_VDP_Opt',
                                                    'VDP.mo', 
                                                    'VDP_pack.VDP_Opt')
        simulator.model = another_model # testing property
        assert another_model == simulator.get_model()
        
    def test_simulation_intervals(self):
        simulator = self.simulator
        
        # First test setters and getters
        default_start = simulator.get_start_time()
        default_final = simulator.get_final_time()
        assert default_start < default_final
        
        my_start = 2
        my_final = 7
        
        simulator.set_simulation_interval(my_start, my_final)
        assert default_start != simulator.get_start_time(), "A setter failed."
        assert default_final != simulator.get_final_time(), "A setter failed."
        
        # Testincorrect interval
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_simulation_interval, 2, 1)
                                 
        # Finally make a test simulation and verify times
        simulator.run()
        T, Y = simulator.get_solution()
        nose.tools.assert_almost_equal(T[0], my_start)
        nose.tools.assert_almost_equal(T[-1], my_final)
                                 
    def test_absolute_tolerance(self):
        """Basic testing of setting absolute tolerance.
        
        The abstol can be set through a property or a setter.
        The abstol can be gotten through a property or a getter.
        """
        simulator = self.simulator
        
        default_tolerance = simulator.get_absolute_tolerance()
        MY_TOLERANCE = 4e-5
        nose.tools.assert_not_equal(default_tolerance, MY_TOLERANCE,
                                    "This test is useless.")
        simulator.set_absolute_tolerance(MY_TOLERANCE)
        nose.tools.assert_almost_equal(MY_TOLERANCE,
                                       simulator.get_absolute_tolerance())
        
        # Testing the property abstol
        MY_TOLERANCE2 = 3e-5
        simulator.abstol = MY_TOLERANCE2
        nose.tools.assert_equal(MY_TOLERANCE2,
                                simulator.get_absolute_tolerance())
        
        # Testing error checking
        nose.tools.assert_raises(sundials.SundialsSimulationException,
                                 simulator.set_absolute_tolerance, -1e-4)
        nose.tools.assert_raises(sundials.SundialsSimulationException,
                                 simulator.set_absolute_tolerance, 0)
                                 
    def test_relative_tolerance(self):
        """Basic testing of setting relative tolerance.
        
        The reltol can be set through a property or a setter.
        The reltol can be gotten through a property or a getter.
        """
        simulator = self.simulator
        
        default_tolerance = simulator.get_relative_tolerance()
        MY_TOLERANCE = 4e-5
        nose.tools.assert_not_equal(default_tolerance, MY_TOLERANCE,
                                    "This test is useless.")
        simulator.set_relative_tolerance(MY_TOLERANCE)
        nose.tools.assert_equal(MY_TOLERANCE,
                                simulator.get_relative_tolerance())
        
        # Testing the property reltol
        MY_TOLERANCE2 = 3e-5
        simulator.reltol = MY_TOLERANCE2
        nose.tools.assert_almost_equal(MY_TOLERANCE2,
                                       simulator.get_relative_tolerance())
        
        # Testing error checking
        nose.tools.assert_raises(sundials.SundialsSimulationException,
                                 simulator.set_relative_tolerance, -1e-4)
        nose.tools.assert_raises(sundials.SundialsSimulationException,
                                 simulator.set_relative_tolerance, 0)
                                 
    def test_time_steps(self):
        simulator = self.simulator
        
        default_time_step = simulator.get_time_step()
        assert default_time_step == simulator.time_step # Test property
        
        MY_TIME_STEP = 2 * default_time_step
        simulator.set_time_step(MY_TIME_STEP)
        assert MY_TIME_STEP == simulator.time_step # Test property
        assert MY_TIME_STEP == simulator.get_time_step()
        
        simulator.run()
        T, Y = simulator.get_solution()
        assert len(T) > 7, "The asserts below might not hold."
        nose.tools.assert_almost_equal(T[1]-T[0], MY_TIME_STEP)
        nose.tools.assert_almost_equal(T[2]-T[1], MY_TIME_STEP)
        nose.tools.assert_almost_equal(T[5]-T[4], MY_TIME_STEP)
        
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_time_step, 0)
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_time_step, -3)
        
    def test_simulation_with_sensivity(self, SMALL=0.3):
        """Testing simulation with sensivity, plotting a guesstimate."""
        
        simulator = self.simulator
        
        FINALTIME = 2
        STARTTIME = self.m.opt_interval_get_start_time()
        DURATION = FINALTIME - STARTTIME
        
        
        self.m.reset()
        self.m.u = [0.25]
        simulator.set_simulation_interval(STARTTIME, FINALTIME)
        simulator.set_sensitivity_analysis(True)
        simulator.run()
        T, ys = simulator.get_solution()
        sens = simulator.get_sensitivities()
        params = simulator.get_sensitivity_indices()
        
        assert len(T) == len(ys)
        assert sens is not None
        assert len(T) > 1
        
        self.m.reset()
        self.m.u = [0.25 + SMALL]
        self.m.x = self.m.x + SMALL
        simulator.set_sensitivity_analysis(True)
        simulator.run()
        T2, ys2 = simulator.get_solution()
        
        fig = p.figure()
        p.hold(True)
        p.plot(T, ys, label="The non-disturbed solution")
        p.plot(T2, ys2, label="The solution with disturbed initial conditions "
                                                          "(SMALL=%s)" % SMALL)
        
        lininterpol = ys[-1] + DURATION * N.dot(N.r_[
                                                    sens[params.xinit_start :
                                                         params.xinit_end],
                                                    sens[params.u_start :
                                                         params.u_end]
                                                ].T,
                                                [SMALL]*4)
        p.plot([T2[-1]], [lininterpol], 'xr',
               label="Expected states linearly interpolated.")
        
        p.legend(loc=0, prop=matplotlib.font_manager.FontProperties(size=8))
        p.hold(False)
        fig.savefig('TestJmiOptModel_test_simulation_with_sensivity.png')
