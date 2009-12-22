#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.simulation.assimulo module."""
import nose
import os
import jmodelica.jmi as jmi
from jmodelica.simulation.assimulo import AJMIExplModel, AJMIImplModel
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join(jm_home, 'Python', 'jmodelica', 'examples')
sep = os.path.sep

mc = ModelicaCompiler()
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)

class TestSimulator:
    
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
        fname_DAE = cpath_ODE.replace('.','_',1)
        
        oc.compile_model(fpath_ODE, cpath_ODE)
   
    def setUp(self):
        """Load the test models."""
        package_DAE = 'Pendulum_pack_Pendulum'
        package_ODE = 'VDP_pack_VDP_Opt'

        # Load the dynamic library and XML data
        #self.m_DAE = jmi.Model(package_DAE)
        #self.m_ODE = jmi.Model(package_ODE)
        
        # Creates the solvers
        #self.DAE = Simulator(self.m_DAE, 'IDA')
        #self.ODE = Simulator(self.m_ODE, 'CVode')
        
    
    def test_init(self):
        """
        This tests the functionality of assimulo.Simulator.__init__
        """
        
        nose.tools.assert_raises(Simulator_Exception, Simulator, self.m_DAE, 'Test')
        
        solv = Simulator(self.m_DAE, 'IDA')
        assert solv.DAE == True
        solv = Simulator(self.m_DAE, 'CVode')
        assert solv.DAE == False
        assert solv._model.t == 0.0
        assert solv._model == self.m_DAE
        
    def test_reset(self):
        """
        This tests the functionality of assimulo.Simulator.reset
        """
        
        ODE_pre_y = self.ODE._model.x.copy()
        DAE_pre_y = self.DAE._model.x.copy()
        
        self.ODE.run(10)
        self.DAE.run(10)
        
        assert ODE_pre_y.sum() != self.ODE._model.x.sum()
        assert DAE_pre_y.sum() != self.DAE._model.x.sum()
        
        self.ODE.reset()
        self.DAE.reset()
        
        assert ODE_pre_y.sum() == self.ODE._model.x.sum()
        assert DAE_pre_y.sum() == self.DAE._model.x.sum()
    
    def test_re_init(self):
        """
        This tests the functionality of assimulo.Simulator.re_init
        """
        
        ODE_pre_y = self.ODE._model.x.copy()
        DAE_pre_y = self.DAE._model.x.copy()
        DAE_pre_t = self.DAE._model.t.copy()

        self.ODE.re_init(10.0, [1., 1., 1.])
        self.DAE.re_init(10.0, [1., 1., 1., 1.], [1., 1., 1., 1.])
        
        assert ODE_pre_y.sum() != self.ODE._model.x.sum()
        assert DAE_pre_y.sum() != self.DAE._model.x.sum()
        assert DAE_pre_t != self.DAE._model.t
        
        nose.tools.assert_raises(Simulator_Exception, self.ODE.re_init, 10.0, [1., 1.])
        nose.tools.assert_raises(Simulator_Exception, self.DAE.re_init, 10.0, [1.,1.,1.,1.])
        nose.tools.assert_raises(Simulator_Exception, self.DAE.re_init, 10.0, [1.,1.,1.,1.], [1.,1.])

        u = [10.1]
        self.ODE.re_init(10.0, [1., 1., 1.], u0 = u)
        self.DAE.re_init(10.0, [1., 1., 1., 1.], [1., 1., 1., 1.], u)
        
        assert self.ODE._model.u == u
        assert self.DAE._model.u == u
        
        nose.tools.assert_raises(Simulator_Exception, self.ODE.re_init, 10.0, [1., 1., 1.], u0=[1, 1])
        nose.tools.assert_raises(Simulator_Exception, self.DAE.re_init, 10.0, [1,1,1,1],[1,1,1,1],'Test')
        nose.tools.assert_raises(Simulator_Exception, self.DAE.re_init, 10.0, [1,1,1,1],[1,1,1,1],[1.0,1.0])
