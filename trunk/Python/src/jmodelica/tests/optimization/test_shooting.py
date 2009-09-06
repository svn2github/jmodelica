#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.optimization.shooting module."""

import numpy as N
import nose

from jmodelica.tests import load_example_standard_model

from jmodelica.optimization.shooting import construct_grid
from jmodelica.optimization.shooting import MultipleShooter


def _lazy_init_shooter(model, gridsize, single_initial_u=2.5):
    """ A helper function used by TestMultipleShooterLazy and
        TestShootingHardcore.
    """
    # needed to be able get a reasonable initial
    model.u = [single_initial_u] * len(model.u)
    initial_u = [[single_initial_u] * len(model.u)] * gridsize
    
    grid = construct_grid(gridsize)
    shooter = MultipleShooter(model, initial_u, grid)
    
    return shooter


class TestMultipleShooterLazy:
    """Test the MultipleShooter class the lazy way.
    
    The tests in this class are run quickly as opposed to the test cases in
    TestShootingHardcore. NOTE that they are also less thourough.
    """
    def setUp(self):
        DLLFILE = 'VDP_pack_VDP_Opt'
        MODELICA_FILE = 'VDP.mo'
        MODEL_PACKAGE = 'VDP_pack.VDP_Opt'
        
        model = load_example_standard_model(DLLFILE, MODELICA_FILE,
                                             MODEL_PACKAGE)
                                             
        GRIDSIZE = 10
        shooter = _lazy_init_shooter(model, GRIDSIZE)
        p0 = shooter.get_p0()
        
        self._shooter = shooter
        self._p0 = p0
        
    def test_f(self):
        """Test MultipleShooter.f(...)."""
        self._shooter.f(self._p0)
        
    def test_h(self):
        """Test MultipleShooter.h(...)."""
        self._shooter.h(self._p0)
        
    def test_df(self):
        """Test MultipleShooter.df(...)."""
        self._shooter.df(self._p0)
        
    def test_dh(self):
        """Test MultipleShooter.dh(...)."""
        self._shooter.dh(self._p0)
        

class TestShootingHardcore:
    """Test the shooting methods by actually running them.
    
    These tests takes a looong time. If you don't want to run the slow tests
    you can call nosetests like so:
      $ nosetests -a '!slow'
    """
    slow = True
    
    def setUp(self):
        DLLFILE = 'VDP_pack_VDP_Opt'
        MODELICA_FILE = 'VDP.mo'
        MODEL_PACKAGE = 'VDP_pack.VDP_Opt'
        
        model = load_example_standard_model(DLLFILE, MODELICA_FILE,
                                             MODEL_PACKAGE)
        self._model = model
    
    def test_mshooting(self):
        """Test a basic multiple shooting optimization."""
        
        GRIDSIZE = 10
        shooter = _lazy_init_shooter(self._model, GRIDSIZE)
        
        optimum = shooter.run_optimization(plot=False)
        print "Optimal p:", optimum
        
    def test_mshooting_gradients(self):
        """ Verify multiple shooting gradients against finite different
            quotient.
        
        This test requires manual validation by goign through the result
        printed to stdout. Use the '-s' flag in nosetests.
        
        """
        GRIDSIZE = 10
        shooter = _lazy_init_shooter(self._model, GRIDSIZE)
        shooter.check_gradients()
        
    def test_basic_sshooting(self):
        single_shooting(self._model, plot=False)
        
    def test_single_against_multiple(self):
        """Compares single shooting against multiple shooting code with only
           one segment.
        
        """
        GRIDSIZE = 1
        shooter = _lazy_init_shooter(self._model, GRIDSIZE)
        moptimum = shooter.run_optimization(plot=False)
        soptimum = single_shooting(self._model, plot=False)
        
        N.testing.assert_array_almost_equal(moptimum.xf, soptimum.xf,
                                            decimal=3)
        nose.tools.assert_almost_equal(moptimum.ff, soptimum.ff, places=4)
