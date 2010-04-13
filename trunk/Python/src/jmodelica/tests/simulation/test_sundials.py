#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.simulation.sundials module."""

import numpy as N
import pylab as p
import matplotlib
import os
import nose

from jmodelica.simulation.sundials import SundialsODESimulator
from jmodelica.simulation.sundials import SundialsDAESimulator
from jmodelica.tests import testattr
import jmodelica.simulation.sundials as sundials
import jmodelica.simulation
import jmodelica.jmi as jmi
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join(jm_home, "Python", "jmodelica", "examples")
path_to_tests = os.path.join(jm_home, "Python", "jmodelica", "tests")

mc = ModelicaCompiler()
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)
sep = os.path.sep

class TestSimulator:
    
    @classmethod
    def setUpClass(cls):
        """Compile the test model. (This is only run once during the test)"""

        modelf = "files" + sep + "VDP.mo"
        fpath = os.path.join(path_to_examples, modelf)
        cpath = "VDP_pack.VDP_Opt"
        fname = cpath.replace('.','_',1)

        oc.compile_model(fpath, cpath)
        
    
    def setUp(self):
        """Load the test model."""
        package = "VDP_pack_VDP_Opt"

        # Load the dynamic library and XML data
        self.m = jmi.Model(package)
        self.simulator = SundialsODESimulator(self.m,start_time=0.0, final_time=20.0)
        
   
    def test_set_get_model(self):
        """Test the model setter/getter."""
        simulator = self.simulator
        assert simulator.get_model() == self.m        
        
        package = "VDP_pack_VDP_Opt"

        # Load the dynamic library and XML data
        another_model = jmi.Model(package)
        
        simulator.set_model(another_model)
        assert simulator.get_model() == another_model
        
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_model, None)
                                 

        # Load the dynamic library and XML data
        another_model = jmi.Model(package)
        
        simulator.model = another_model # testing property
        assert another_model == simulator.get_model()
        
                           
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
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_absolute_tolerance, -1e-4)
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
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
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_relative_tolerance, -1e-4)
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_relative_tolerance, 0)
                                 
   
    def test_set_get_verbosity(self):
        """Test the verbosity setter/getter.
        
        Setting verbosity is highly useful for debugging, but can at the same
        time be very annoying if too much output is cluttering the console.
        
        This test test not only tests getters and setters but als documents the
        available verbosities.
        
        """
        simulator = self.simulator
        simulator.set_verbosity(SundialsODESimulator.QUIET)
        assert SundialsODESimulator.QUIET == 0, "QUIET constant should be zero"
        simulator.set_verbosity(SundialsODESimulator.WHISPER)
        assert simulator.get_verbosity() == SundialsODESimulator.WHISPER
        simulator. verbosity = SundialsODESimulator.NORMAL # testing property
        assert simulator.get_verbosity() == SundialsODESimulator.NORMAL
        simulator.set_verbosity(SundialsODESimulator.LOUD)
        assert simulator.verbosity == SundialsODESimulator.LOUD # property test
        simulator.set_verbosity(SundialsODESimulator.SCREAM)
        assert simulator.get_verbosity() == SundialsODESimulator.SCREAM
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_verbosity, 65487)
        nose.tools.assert_raises(jmodelica.simulation.SimulationException,
                                 simulator.set_verbosity, -5465)

                            
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
        
class TestSundialsDAESimulator:
    
    @classmethod
    def setUpClass(cls):
        """Compile the test model. (This is only run once during the test)"""
        modelf = "files" + sep + "Pendulum_pack_no_opt.mo"
        fpath = os.path.join(path_to_examples, modelf)
        cpath = "Pendulum_pack.Pendulum"
        fname = cpath.replace('.','_',1)

        mc.compile_model(fpath, cpath)
        

    def setUp(self):
        """Load the test model for DAE."""
        package = "Pendulum_pack_Pendulum"

        # Load the dynamic library and XML data
        self.m = jmi.Model(package)

        self.simulator = SundialsDAESimulator(self.m, start_time=0.0, final_time=10.0)
    
    
    def test_is_simulator(self):
        assert isinstance(self.simulator, jmodelica.simulation.Simulator)
    
  
    def test_constructor_parameters(self):
        """Assert that a couple of different parameters exists in the
           DAE constructor.
        """
        simulator = SundialsDAESimulator(time_step=0.2,
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
        #TODO
        #assert simulator.sensitivity_analysis == True
        assert simulator.return_last == True
        assert simulator.get_start_time() == 1
        assert simulator.get_final_time() == 20
      
    def test_simulation(self):
        """Run a very basic DAE simulation."""
        
        simulator = self.simulator
        x_before_simulation = simulator.get_model().real_x.copy()
        simulator.run()
        simulator.run(10.0,20.0)
        Ts, ys = simulator.get_solution()
        simulator.write_data()
        
        assert len(Ts) == len(ys), "Time points and solution points must be " \
                                   "equal lengths."
        assert len(Ts) >= 5, "A solution was expected got less than 5 points."
        assert not (x_before_simulation==simulator.get_model().real_x).all(), \
               "Simulation does seem to have been performed."
        
        # Plotting
        fig = p.figure()
        p.plot(Ts, ys)
        p.title('testDAESimulation(...) output')
        fig.savefig('TestSundialsDAESimulator_test_simulation.png')
      
    def test_simulation_with_algebraic_variables(self):
        """Run a simulation with a model with algebraic variables"""
 
        libname = 'RLC_Circuit'
        mofile = 'files' + sep + 'RLC_Circuit.mo'
        optpackage = 'RLC_Circuit'
    
        # Comile the Modelica model first to C code and
        # then to a dynamic library
        mc.compile_model(os.path.join(path_to_examples,mofile),libname)

        # Load the dynamic library and XML data
        model=jmi.Model(optpackage)
        
        # Running a simulation with the attribute return_last = True (Only the final result should be returned)
        simulator = SundialsDAESimulator(model, start_time=0.0, final_time=30.0, time_step=0.01, return_last=True, verbosity=4)
        simulator.run()
        memory = simulator.solver_memory
        simulator.run(30.0,40.0)
        assert memory is simulator.solver_memory
        Ts, ys = simulator.get_solution()

        assert len(Ts) == len(ys) #Length of the vectors should be the same
        assert len(ys[0,:]) == 20 #Number of variables in the example
    
        #NO LONGER VALID
        """
        #Ts, ys = simulator.get_solution('sine.y','resistor.v','inductor1.i')
        #assert len(Ts) == len(ys) #Length of the vectors should be the same
        #assert len(ys[0,:]) == 3 #Should be able to find three variables
        
        # Load the dynamic library and XML data
        model=jmi.Model(optpackage)
        
        simulator = SundialsDAESimulator(model, start_time=0.0, final_time=30.0, time_step=0.01)
        simulator.run()
        
        Ts, ys = simulator.get_solution()
        
        assert len(Ts) == len(ys) #Length of the vectors should be the same
        assert len(ys[0,:]) == 42 #Number of variables in the example
        
        
        Ts, ys = simulator.get_solution('sine.y','Not_a_variable','inductor1.i')
        
        assert len(Ts) == len(ys) #Length of the vectors should be the same
        assert len(ys[0,:]) == 2 #Should be able to find two variables
    
        Ts, ys = simulator.get_solution('sine.y','resistor.v','inductor1.i')
        
        assert len(Ts) == len(ys) #Length of the vectors should be the same
        assert len(ys[0,:]) == 3 #Should be able to find three variables
        
        fig = p.figure()
        p.plot(Ts, ys)
        p.legend(('sine.y','resistor.v','inductor1.i'))
        p.title('testDAESimulationAlgebraic(...) output')
        fig.savefig('TestSundialsDAESimulator_test_simulation_with_algebraic.png')        
        """
    

class TestSundialsODESimulator:
    
    @classmethod
    def setUpClass(cls):
        """Compile the test model. (This is only run once during the test)"""

        modelf = "files" + sep + "VDP.mo"
        fpath = os.path.join(path_to_examples, modelf)
        cpath = "VDP_pack.VDP_Opt"
        fname = cpath.replace('.','_',1)

        oc.compile_model(fpath, cpath)
        
    
    def setUp(self):
        """Load the test model."""
        package = "VDP_pack_VDP_Opt"

        # Load the dynamic library and XML data
        self.m = jmi.Model(package)
        self.simulator = SundialsODESimulator(self.m,start_time=0.0, final_time=20.0)
      
    def test_is_simulator(self):
        assert isinstance(self.simulator, jmodelica.simulation.Simulator)
      
    def test_constructor_parameters(self):
        """Assert that a couple of different parameters exists in the
           constructor.
        """
        simulator = SundialsODESimulator(time_step=0.2,
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
        x_before_simulation = simulator.get_model().real_x.copy()
        simulator.run()
        Ts, ys = simulator.get_solution()
        simulator.write_data()
        
        assert len(Ts) == len(ys), "Time points and solution points must be " \
                                   "equal lengths."
        assert len(Ts) >= 5, "A solution was expected got less than 5 points."
        assert not (x_before_simulation==simulator.get_model().real_x).all(), \
               "Simulation does seem to have been performed."
        
        # Plotting
        fig = p.figure()
        p.plot(Ts, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestSundialsODESimulator_test_simulation.png')
    
         
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
        self.m.real_u = [0.25 + SMALL]
        self.m.real_x = self.m.real_x + SMALL
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
