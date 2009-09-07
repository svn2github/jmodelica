#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.optimization.shooting module."""

import numpy as N
import pylab as p
import matplotlib
import nose

from jmodelica.tests import load_example_standard_model
from jmodelica.simulation.sundials import solve_using_sundials


class TestSolveUsingSundials:
    """Test simulation of the VDP model using the SUNDIALS interface."""
    
    def setUp(self):
        """Test setUp. Load the test model."""
        self.m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo', 
                                             'VDP_pack.VDP_Opt')
        
    def test_simulation_with_sensivity(self, SMALL=0.3):
        """Testing simulation sensivity of JmiOptModel."""
        
        FINALTIME = 2
        STARTTIME = self.m.opt_interval_get_start_time()
        DURATION = FINALTIME - STARTTIME
        
        self.m.reset()
        self.m.u = [0.25]
        T, ys, sens, params = solve_using_sundials(self.m, FINALTIME,
                                                   STARTTIME, sensi=True)
        
        assert len(T) == len(ys)
        assert sens is not None
        assert len(T) > 1
        
        self.m.reset()
        self.m.u = [0.25 + SMALL]
        self.m.x = self.m.x + SMALL
        T2, ys2, ignore, ignore2 = solve_using_sundials(self.m, FINALTIME,
                                                        STARTTIME, sensi=False)
        
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

    def test_fixed_simulation(self):
        """Test simulation of JmiOptModel without plotting.
        
        No plotting is done to compare times against
        self.testFixedSimulationReturnLast().
        """
        
        assert self.m.opt_interval_finaltime_fixed(), "Only fixed times " \
                                                      "supported."
        assert self.m.opt_interval_starttime_fixed(), "Only fixed times " \
                                                      "supported."
        
        start_time = self.m.opt_interval_get_start_time()
        final_time = self.m.opt_interval_get_final_time()
        
        self.m.reset()
        self.m.u = [0.25]
        T, ys, sens, ignore = solve_using_sundials(self.m, final_time,
                                                   start_time)
        assert len(T) == len(ys)
        nose.tools.assert_almost_equal(T[0], start_time)
        nose.tools.assert_almost_equal(T[-1], final_time)
        
    def test_fixed_simulation_return_last(self):
        """Test simulation of JmiOptModel without plotting.
        
        No plotting is done to compare times against
        self.testFixedSimulation().
        """
        assert self.m.opt_interval_finaltime_fixed(), "Only fixed times " \
                                                      "supported."
        assert self.m.opt_interval_starttime_fixed(), "Only fixed times " \
                                                      "supported."
        
        start_time = self.m.opt_interval_get_start_time()
        final_time = self.m.opt_interval_get_final_time()
        
        self.m.reset()
        self.m.u = [0.25]
        T, ys, sens, ignore = solve_using_sundials(self.m, final_time,
                                                   start_time,
                                                   return_last=True)
        assert len(ys) > 0
        assert T is not None
        
        
    def test_fixed_simulation_with_plot(self):
        """Test simulation of JmiOptModel with result plotting."""
        assert self.m.opt_interval_finaltime_fixed(), "Only fixed times " \
                                                      "supported."
        assert self.m.opt_interval_starttime_fixed(), "Only fixed times " \
                                                      "supported."
        
        start_time = self.m.opt_interval_get_start_time()
        final_time = self.m.opt_interval_get_final_time()
        
        self.m.reset()
        self.m.u = [0.25]
        T, ys, sens, ignore = solve_using_sundials(self.m, final_time,
                                                   start_time)
        assert len(T) == len(ys)
        
        fig = p.figure()
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestJmiOptModel_test_fixed_simulation_with_plot.png')
        
    def test_fixed_simulation_intervals(self):
        """Test simulation between a different time span of JmiOptModel."""
        assert self.m.opt_interval_finaltime_fixed(), "Only fixed times " \
                                                      "supported."
        assert self.m.opt_interval_starttime_fixed(), "Only fixed times " \
                                                      "supported."
        
        start_time = self.m.opt_interval_get_start_time()
        final_time = self.m.opt_interval_get_final_time()
        middle_timepoint = (self.m.opt_interval_get_final_time() + self.m.opt_interval_get_start_time()) / 2.0
        
        T, ys, sens, ignore = solve_using_sundials(self.m, final_time,
                                                   middle_timepoint)
        nose.tools.assert_almost_equal(T[0], middle_timepoint)
        nose.tools.assert_almost_equal(T[-1], final_time)
        assert len(T) == len(ys)
        T, ys, sens, ignore = solve_using_sundials(self.m, middle_timepoint,
                                                   start_time)
        assert len(T) == len(ys)
        nose.tools.assert_almost_equal(T[0], start_time)
        nose.tools.assert_almost_equal(T[-1], middle_timepoint)
        
        fig = p.figure()
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestJmiOptModel_test_fixed_simulation_intervals.png')
