#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.simulation.assimulo module."""
import nose
import os
import numpy as N
import jmodelica.jmi as jmi
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler

try:
    from jmodelica.simulation.assimulo import JMIExplicit, JMIImplicit, JMIModel_Exception
except NameError:
    print 'Could not load Assimulo module.'

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join(jm_home, 'Python', 'jmodelica', 'examples')
sep = os.path.sep

mc = ModelicaCompiler()
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)

class Test_Assimulo:
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test models. (This is only run once during the test)
        """
        #DAE test model
        modelf_DAE = 'files' + sep + 'Pendulum_pack_no_opt.mo'
        fpath_DAE = os.path.join(path_to_examples, modelf_DAE)
        cpath_DAE = 'Pendulum_pack.Pendulum'
        fname_DAE = cpath_DAE.replace('.','_',1)

        mc.compile_model(fpath_DAE, cpath_DAE)
        
        #ODE test model
        modelf_ODE = 'files' + sep + 'VDP.mo'
        fpath_ODE = os.path.join(path_to_examples, modelf_ODE)
        cpath_ODE = 'VDP_pack.VDP_Opt'
        fname_ODE = cpath_ODE.replace('.','_',1)
        
        oc.compile_model(fpath_ODE, cpath_ODE)
   
    def setUp(self):
        """Load the test models."""
        package_DAE = 'Pendulum_pack_Pendulum'
        package_ODE = 'VDP_pack_VDP_Opt'

        # Load the dynamic library and XML data
        self.m_DAE = jmi.Model(package_DAE)
        self.m_ODE = jmi.Model(package_ODE)
        
        # Creates the solvers
        self.DAE = JMIImplicit(self.m_DAE)
        self.ODE = JMIExplicit(self.m_ODE)
        
    def test_Imp_eps(self):
        """
        This tests the functionality of assimulo.JMIImplicit.eps
        """
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, 'Test')
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, -1)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, 1)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, -1.0)
        
        self.DAE.eps = 1.0
        assert self.DAE.eps == 1.0
        self.DAE.eps = 10.0
        assert self.DAE.eps == 10.0
        
    def test_Imp_max_eIter(self):
        """
        This tests the functionality of assimulo.JMIImplicit.max_eIter
        """
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, 'Test')
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, -1)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, 1.0)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, -1.0)
        
        self.DAE.max_eIter = 1
        assert self.DAE.max_eIter == 1
        self.DAE.max_eIter = 10
        assert self.DAE.max_eIter == 10
    
    def test_Imp_reset(self):
        """
        This tests the functionality of assimulo.JMIImplicit.reset
        """
        #NOT COMPLETE
        
        t0_prev = self.DAE._model.t.copy()
        y0_prev = self.DAE.y0.copy()
        y0d_prev = self.DAE.yd0.copy()
        
        self.DAE._model.t = 10.0
        self.DAE.t0 = 10.0
        
        assert t0_prev != self.DAE._model.t
        
        self.DAE.reset()
        
        assert 10.0 == self.DAE._model.t
        
        #NEEDS MORE EXTENSIVE TESTING
        
    def test_Imp_check_eIter(self):
        """
        This tests the functionality of assimulo.JMIImplicit.check_eIter
        """
        
        b_mode = [1, -1, 0]
        a_mode = [-1, 1, 1]
        
        [eIter, iter] = self.DAE.check_eIter(b_mode, a_mode)
        
        assert iter == True
        assert eIter[0] == -1
        assert eIter[1] == 1
        assert eIter[2] == 0
    
    def test_Imp_init_mode(self):
        """
        This tests the functionality of assimulo.JMIImplicit.init_mode
        """
        raise NotImplementedError
    
    def test_Imp_event_switch(self):
        """
        This tests the functionality of assimulo.JMIImplicit.event_switch
        """
        raise NotImplementedError
        
    def test_Imp_handle_event(self):
        """
        This tests the functionality of assimulo.JMIImplicit.handle_event
        """
        raise NotImplementedError
        
    def test_Imp_g_adjust(self):
        """
        This tests the functionality of assimulo.JMIImplicit.g_adjust
        """
        raise NotImplementedError
        
    def test_Imp_g(self):
        """
        This tests the functionality of assimulo.JMIImplicit.g
        """
        raise NotImplementedError
        
    def test_Imp_f(self):
        """
        This tests the functionality of assimulo.JMIImplicit.f
        """
        test_x = N.array([1.,1.,1.,1.])
        test_dx = N.array([2.,2.,2.,2.])
        test_t = 2
        
        temp_f = self.DAE.f(test_t,test_x,test_dx)
        
        print temp_f
        assert temp_f[0] == -1.0
        assert temp_f[2] == -1.0
        assert temp_f[3] == -2.0
        nose.tools.assert_almost_equal(temp_f[1], -1.158529, 5)
        
    def test_Imp_init(self):
        """
        This tests the functionality of assimulo.JMIImplicit.__init__
        """
        assert self.m_DAE == self.DAE._model
        assert self.DAE.max_eIter == 50
        assert self.DAE.eps == 1e-9
        
        temp_y0 = N.append(self.m_DAE.x.copy(), self.m_DAE.w.copy())
        temp_yd0 = N.append(self.m_DAE.dx.copy(),[0]*len(self.m_DAE.w))
        temp_algvar = [1.0]*len(self.m_DAE.x) + [0.0]*len(self.m_DAE.w)
        
        for i in range(len(temp_y0)):
            assert temp_y0[i] == self.DAE.y0[i]
            assert temp_yd0[i] == self.DAE.yd0[i]
            assert temp_algvar[i] == self.DAE.algvar[i]
        
        
        #NOT TESTING EVENT HANDLING
        
    def test_Exp_reset(self):
        """
        This tests the functionality of assimulo.JMIExplicit.reset
        """
        temp_t0 = self.ODE._model.t
        temp_y0 = self.ODE._model.x.copy()
        
        self.ODE.t0 = 10.0
        self.ODE._model.x = N.array([5.,5.,5.])
        
        assert temp_t0 != 10.0
        assert temp_y0[0] != 5.0
        assert temp_y0[1] != 5.0
        assert temp_y0[2] != 5.0
        
        self.ODE.reset()
        
        assert self.ODE._model.t == 10.0
        N.testing.assert_array_almost_equal(temp_y0, self.ODE.y0)
        
        
    def test_Exp_g(self):
        """
        This tests the functionality of assimulo.JMIExplicit.g
        """
        raise NotImplementedError
        
    def test_Exp_f(self):
        """
        This tests the functionality of assimulo.JMIExplicit.f
        """
        test_x = N.array([1.,1.,1.])
        test_t = 2
        
        temp_rhs = self.ODE.f(test_t,test_x)
        
        assert temp_rhs[0] == -1.0
        assert temp_rhs[1] == 1.0
        nose.tools.assert_almost_equal(temp_rhs[2], 14.77811, 5)
        
    def test_Exp_init(self):
        """
        This tests the functionality of assimulo.JMIExplicit.__init__
        """
        assert self.m_ODE == self.ODE._model
        
        for i in range(len(self.ODE.y0)):
            assert self.m_ODE.x[i] == self.ODE.y0[i]
