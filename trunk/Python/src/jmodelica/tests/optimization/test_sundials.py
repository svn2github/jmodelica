#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.optimization.sundials module."""

import os
import numpy as N
import pylab as p
import matplotlib
import nose

#from jmodelica.tests import load_example_standard_model
from jmodelica.compiler import OptimicaCompiler
from jmodelica.tests import testattr
from jmodelica import jmi
from jmodelica.optimization.sundials import construct_grid
from jmodelica.optimization.sundials import MultipleShooter
from jmodelica.optimization.sundials import construct_grid
from jmodelica.optimization.sundials import _check_normgrid_consistency
from jmodelica.optimization.sundials import _split_opt_x
from jmodelica.optimization.sundials import plot_control_solutions
from jmodelica.optimization.sundials import single_shooting

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join(jm_home, "Python", "jmodelica", "examples")
path_to_tests = os.path.join(jm_home, "Python", "jmodelica", "tests")

oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)
sep = os.path.sep

def _lazy_init_shooter(model, gridsize, single_initial_u=2.5):
    """ A helper function used by TestMultipleShooterLazy and
        TestShootingHardcore.
    """
    # needed to be able get a reasonable initial
    model.u = [single_initial_u] * len(model.u)
    initial_u = [[single_initial_u] * len(model.u)] * gridsize
    
    grid = construct_grid(gridsize)
    shooter = MultipleShooter(model, initial_u, grid)
    #shooter.set_log_level(3)
    
    return shooter


class TestMultipleShooterLazy:
    """Test the MultipleShooter class the lazy way.
    
    The tests in this class are run quickly as opposed to the test cases in
    TestShootingHardcore. NOTE that they are also less thourough.
    """
    def setUp(self):
        #DLLFILE = 'VDP_pack_VDP_Opt'
        #MODELICA_FILE = 'VDP.mo'
        #MODEL_PACKAGE = 'VDP_pack.VDP_Opt'
        
        #model = load_example_standard_model(DLLFILE, MODELICA_FILE,
        #                                     MODEL_PACKAGE)
        modelf = "files" + sep + "VDP.mo"
        fpath = os.path.join(path_to_examples, modelf)
        cpath = "VDP_pack.VDP_Opt"
        fname = cpath.replace('.','_',1)

        oc.compile_model(cpath, fpath, target='ipopt')
        #oc.compile_model(fpath, cpath)

        # Load the dynamic library and XML data
        model = jmi.Model(fname)
                                             
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
#        DLLFILE = 'VDP_pack_VDP_Opt'
#        MODELICA_FILE = 'VDP.mo'
#        MODEL_PACKAGE = 'VDP_pack.VDP_Opt'
#        
#        model = load_example_standard_model(DLLFILE, MODELICA_FILE,
#                                             MODEL_PACKAGE)
        
        modelf = "files" + sep + "VDP.mo"
        fpath = os.path.join(path_to_examples, modelf)
        cpath = "VDP_pack.VDP_Opt"
        fname = cpath.replace('.','_',1)

        oc.compile_model(cpath, fpath, target='ipopt')

        # Load the dynamic library and XML data
        model = jmi.Model(fname)
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
        soptimum = single_shooting(self._model,initial_u=2.5, plot=False)
        
        N.testing.assert_array_almost_equal(moptimum.xf, soptimum.xf,
                                            decimal=3)
        nose.tools.assert_almost_equal(moptimum.ff, soptimum.ff, places=4)


def _verify_gradient(f, df, xstart, xend, SMALL=0.1, STEPS=100):
    """Output a comparison plot between f.d. quotient and and df.
    
    The plot is written to the current matplotlib figure within the interval
    [xstart, xend] split into STEPS steps. The finite difference quotient has
    an infitesimal equal to SMALL.
    
    This function was written before I knew about the built in OpenOPT gradient
    verification feature. See MultipleShooter.check_gradient().
    """
    assert xstart < xend
    
    x = N.arange(xstart, xend, 1.0*(xend - xstart) / STEPS)
    
    # Plot the function evaluated
    p.subplot(211)
    fevals = N.array(map(f,x))
    p.plot(x, fevals, label='The evaluated function')
    p.title('Derivative check ')
    p.legend()
    
    p.subplot(212)
    p.title('Derivative comparison')
    p.hold(True)
    
    # Plot the derivative
    dfs = map(df,x)
    p.plot(x, dfs, label='Given derivative')
    
    # Plot the approximated finite difference
    fevals_delta = N.array(map(f, x+SMALL))
    adfs = (fevals_delta - fevals) / SMALL
    p.plot(x, adfs, label='Approximate derivative')
    
    # Plot the difference between approximated derivative and the given
    # derivative
    p.plot(x, adfs-dfs, label='Der. method difference')
    
    p.hold(False)
    p.legend(prop=matplotlib.font_manager.FontProperties(size=8))
    
    
def test_verify_gradient():
    """Testing _verify_gradient(...)."""
    fig = p.figure()
    f = lambda x: x**2
    df = lambda x: 2*x
    _verify_gradient(f, df, -10, 10)
    fig.savefig('test_verify_gradient.png')
    

class _PartialEvaluator:
    """Evaluator used to evaluate a {f(x): R^n -> R} by setting all variables
       to fixed values except x_{index} which is varied. Thus a new one
       dimensional function is created.
       
    This function is used by test_gradient_elements().
    """
    def __init__(self, g, dg, xbase, index):
        """Constructor.
        
        Parameters:
        g  -- the function g: R^n -> R
        dg -- the gradient of g, namely dg: R^n -> R^n
        xbase -- the x vector used for all x:s except index.
        index -- the index in x vector which is to be varied.
        """
        self._g = g
        self._dg = dg
        self._xbase = xbase
        self._index = index
        
    def f(self, xi):
        """Evaluate the one dimensional function f.
        
        xi is the value if index index in x before evaluating g.
        """
        xvec = self._xbase.copy()
        xvec[self._index] = xi
        return self._g(xvec)
        
    def df(self, x):
        """Returns the index index in the gradient evaluated using xbase except
           xbase[index]=x.
        """
        xvec = self._xbase.copy()
        xvec[self._index] = x
        return self._dg(xvec)[self._index]


@testattr(veryslow = True, slow = True)
def test_f_gradient_elements(certainindex=None):
    """Basic testing of gradients (disabled by default).
    
    This tests takes slightly less than an hour to run on my computer unless
    certainindex is defined (whereas only the element of index certainindex
    will be tested). Therefor it is turned off by default. Set run_huge_test
    variable to True to run this test by default.
    
    Also note that this test is not really supposed to test functionality per
    se. It is rather a test that can be used to visually verify that gradients
    behave the way they are expected to.
    """
    run_huge_test = False
    
    if run_huge_test is False and certainindex is None:
        return
#    m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo',
#                                     'VDP_pack.VDP_Opt')
    modelf = "files" + sep + "VDP.mo"
    fpath = os.path.join(path_to_examples, modelf)
    cpath = "VDP_pack.VDP_Opt"
    fname = cpath.replace('.','_',1)

    oc.compile_model(cpath, fpath, target='ipopt')

    # Load the dynamic library and XML data
    m = jmi.Model(fname)

    grid = [(0, 0.1),
            (0.1, 0.2),
            (0.2, 0.3),
            (0.3, 0.4),
            (0.4, 0.5),
            (0.5, 0.6),
            (0.6, 0.7),
            (0.7, 0.8),
            (0.8, 0.9),
            (0.9, 1.0),]
    initial_u = [0.25] * len(grid)
    shooter = MultipleShooter(m, initial_u, grid)
    p0 = shooter.get_p0()
    
    if certainindex is not None:
        indices = [certainindex]
    else:
        indices = range(len(p0))
    
    for index in indices:
        fig = p.figure()
        evaluator = _PartialEvaluator(shooter.f, shooter.df, p0, index)
        p.suptitle('Partial derivative test (of gradient elements, index=%s)' %
                                                                         index)
        _verify_gradient(evaluator.f, evaluator.df, -10, 10)
        fig.savefig('test_f_gradient_elements_%s.png' % index)
        fig.savefig('test_f_gradient_elements_%s.eps' % index)


def test_f_gradient_element_29():
    """Testing part. diff. which corresponds to element 29 in grad(f) in VDP.
    
    This was a failing test in test_f_gradient_elements(None) which is the
    reason why I'm adding it here.
    """
    test_f_gradient_elements(29)


def test_plot_control_solutions():
    """Testing plot_control_solutions(...)."""
#    m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo',
#                                     'VDP_pack.VDP_Opt')
    
    modelf = "files" + sep + "VDP.mo"
    fpath = os.path.join(path_to_examples, modelf)
    cpath = "VDP_pack.VDP_Opt"
    fname = cpath.replace('.','_',1)

    oc.compile_model(cpath, fpath, target='ipopt')

    # Load the dynamic library and XML data
    m = jmi.Model(fname)
    m.reset()
    grid = [(0, 0.1),
            (0.1, 0.2),
            (0.2, 0.3),
            (0.3, 0.4),
            (0.4, 0.5),
            (0.5, 0.6),
            (0.6, 0.7),
            (0.7, 0.8),
            (0.8, 0.9),
            (0.9, 1.0),]
    grid = N.array(grid) * (m.opt_interval_get_final_time() - m.opt_interval_get_start_time()) + \
           m.opt_interval_get_start_time()
            
    # Used to be: N.array([1, 1, 1, 1]*len(grid))        
    us = [ -1.86750972e+00,
           -1.19613740e+00,  3.21955502e+01,  1.15871750e+00, -9.56876370e-01,
            7.82651050e+01, -3.35655693e-01,  1.95491165e+00,  1.47923425e+02,
           -2.32963068e+00, -1.65371763e-01,  1.94340923e+02,  6.82953492e-01,
           -1.57360749e+00,  2.66717232e+02,  1.46549806e+00,  1.74702679e+00,
            3.29995167e+02, -1.19712096e+00,  9.57726717e-01,  3.80947471e+02,
            3.54379487e-01, -1.95842811e+00,  4.52105868e+02,  2.34170339e+00,
            1.77754406e-01,  4.98700011e+02,  2.50000000e-01,  2.50000000e-01,
            2.50000000e-01,  2.50000000e-01,  2.50000000e-01,  1.36333570e-01,
            2.50000000e-01,  2.50000000e-01,  2.50000000e-01,  2.50000000e-01]
    us = N.array(us)
    plot_control_solutions(m, grid, us, doshow=False)


def test_control_solution_variations():
    """Test different variations of control solutions."""
#    m = load_example_standard_model('VDP_pack_VDP_Opt', 'VDP.mo',
#                                     'VDP_pack.VDP_Opt')
    
    modelf = "files" + sep + "VDP.mo"
    fpath = os.path.join(path_to_examples, modelf)
    cpath = "VDP_pack.VDP_Opt"
    fname = cpath.replace('.','_',1)

    oc.compile_model(cpath, fpath, target='ipopt')

    # Load the dynamic library and XML data
    m = jmi.Model(fname)
    m.reset()
    grid = [(0, 0.1),
            (0.1, 0.2),
            (0.2, 0.3),
            (0.3, 0.4),
            (0.4, 0.5),
            (0.5, 0.6),
            (0.6, 0.7),
            (0.7, 0.8),
            (0.8, 0.9),
            (0.9, 1.0),]
    start_time = m.opt_interval_get_start_time()
    final_time = m.opt_interval_get_final_time()
    grid = N.array(grid) * (final_time - start_time) + start_time    
            
    for u in [-0.5, -0.25, 0, 0.25, 0.5]:
        print "u:", u
        us = [ -1.86750972e+00, -1.19613740e+00, 3.21955502e+01,
                1.15871750e+00, -9.56876370e-01, 7.82651050e+01,
                -3.35655693e-01, 1.95491165e+00, 1.47923425e+02,
                -2.32963068e+00, -1.65371763e-01, 1.94340923e+02,
                6.82953492e-01, -1.57360749e+00, 2.66717232e+02,
                1.46549806e+00, 1.74702679e+00, 3.29995167e+02,
                -1.19712096e+00, 9.57726717e-01, 3.80947471e+02,
                3.54379487e-01, -1.95842811e+00, 4.52105868e+02,
                2.34170339e+00, 1.77754406e-01, 4.98700011e+02] + [u] * 10
        us = N.array(us)
        plot_control_solutions(m, grid, us, doshow=False)
        

def test_grid_consistency():
    """Testing _check_normgrid_consistency(..) and construct_grid(...)"""
    _check_normgrid_consistency(construct_grid(1))
    _check_normgrid_consistency(construct_grid(5))
    _check_normgrid_consistency(construct_grid(10))
    _check_normgrid_consistency(construct_grid(523))
