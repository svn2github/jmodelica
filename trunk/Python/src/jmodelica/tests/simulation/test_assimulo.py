#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Tests for the jmodelica.simulation.assimulo module."""
import nose
import os
import jmodelica.jmi as jmi
from jmodelica.simulation.assimulo import Simulator, Simulator_Exception
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
        
        """Compile the test model. (This is only run once during the test)"""
        modelf = 'files' + sep + 'Pendulum_pack_no_opt.mo'
        fpath = os.path.join(path_to_examples, modelf)
        cpath = 'Pendulum_pack.Pendulum'
        fname = cpath.replace('.','_',1)

        mc.compile_model(fpath, cpath)
        
    def setUp(self):
        
        """Load the test model for DAE."""
        package = "Pendulum_pack_Pendulum"

        # Load the dynamic library and XML data
        self.m_DAE = jmi.Model(package)
    
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
        
        
        
