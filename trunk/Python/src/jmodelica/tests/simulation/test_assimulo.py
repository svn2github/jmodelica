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
import nose
import os
import numpy as N
import jmodelica.jmi as jmi
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler

try:
    from jmodelica.simulation.assimulo import JMIODE, JMIDAE, JMIModel_Exception
except NameError:
    print 'Could not load Assimulo module.'

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join(jm_home, 'Python', 'jmodelica', 'examples')
sep = os.path.sep

mc = ModelicaCompiler()
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)


class Test_JMI_ODE:
    """
    This class tests jmodelica.simulation.assimulo.JMIODE
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        modelf_ODE = 'files' + sep + 'VDP.mo'
        fpath_ODE = os.path.join(path_to_examples, modelf_ODE)
        cpath_ODE = 'VDP_pack.VDP_Opt'
        fname_ODE = cpath_ODE.replace('.','_',1)
        
        oc.compile_model(fpath_ODE, cpath_ODE)
        
    def setUp(self):
        """Load the test model."""
        package_ODE = 'VDP_pack_VDP_Opt'

        # Load the dynamic library and XML data
        self.m_ODE = jmi.Model(package_ODE)
        
        # Creates the solvers
        self.ODE = JMIODE(self.m_ODE)
        
    def test_init(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.__init__
        """
        assert self.m_ODE == self.ODE._model
        
        for i in range(len(self.ODE.y0)):
            assert self.m_ODE.real_x[i] == self.ODE.y0[i]
            
        #Test for algebraic variables
        modelf_DAE = 'files' + sep + 'RLC_Circuit.mo'
        fpath_DAE = os.path.join(path_to_examples, modelf_DAE)
        cpath_DAE = 'RLC_Circuit'
        fname_DAE = cpath_DAE.replace('.','_',1)
        mc.compile_model(fpath_DAE, cpath_DAE)
        package_DAE = 'RLC_Circuit'
        # Load the dynamic library and XML data
        m_DAE = jmi.Model(package_DAE)
        
        nose.tools.assert_raises(JMIModel_Exception, JMIODE, m_DAE)
        

        #Test for discontinious model
        modelf_DISC = 'files' + sep + 'IfExpExamples.mo'
        fpath_DISC = os.path.join(path_to_examples, modelf_DISC)
        cpath_DISC = 'IfExpExamples.IfExpExample2'
        fname_DISC = cpath_DISC.replace('.','_',1)
        mc.compile_model(fpath_DISC, cpath_DISC)
        package_DISC = 'IfExpExamples_IfExpExample2'
        # Load the dynamic library and XML data
        m_DISC = jmi.Model(package_DISC)
        
        nose.tools.assert_raises(JMIModel_Exception, JMIODE, m_DISC)
    
    def test_f(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.f
        """
        test_x = N.array([1.,1.,1.])
        test_t = 2
        
        temp_rhs = self.ODE.f(test_t,test_x)
        
        assert temp_rhs[0] == -1.0
        assert temp_rhs[1] == 1.0
        nose.tools.assert_almost_equal(temp_rhs[2], 14.77811, 5)
    
    def test_j(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.j
        """
        test_x = N.array([1.,1.,1.])
        test_t = 2
        
        temp_j = self.ODE.j(test_t,test_x)
        print temp_j
        assert temp_j[0,0] == 0.0
        assert temp_j[0,1] == -3.0
        assert temp_j[0,2] == 0.0
        assert temp_j[1,0] == 1.0
        assert temp_j[1,1] == 0.0
        assert temp_j[1,2] == 0.0
        nose.tools.assert_almost_equal(temp_j[2,0], 14.7781122, 5)
        nose.tools.assert_almost_equal(temp_j[2,1], 14.7781122, 5)
        assert temp_j[2,2] == 0.0
    
    def test_reset(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.reset
        """
        self.ODE.t0 = 10.0
        self.ODE._model.real_x = N.array([2.,2.,2.])
        
        self.ODE.reset()
        
        assert self.ODE._model.t == 10.0
        assert self.ODE._model.real_x[0] != 2.0
        assert self.ODE._model.real_x[1] != 2.0
        assert self.ODE._model.real_x[2] != 2.0
        
    def test_g(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.g
        """
        #This is not implemented in JMIODE yet.
        pass
        
class Test_JMI_DAE:
    """
    This class tests jmodelica.simulation.assimulo.JMIDAE
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        #DAE test model
        modelf_DAE = 'files' + sep + 'Pendulum_pack_no_opt.mo'
        fpath_DAE = os.path.join(path_to_examples, modelf_DAE)
        cpath_DAE = 'Pendulum_pack.Pendulum'
        fname_DAE = cpath_DAE.replace('.','_',1)

        mc.compile_model(fpath_DAE, cpath_DAE)
        
        modelf_DISC = 'files' + sep + 'IfExpExamples.mo'
        fpath_DISC = os.path.join(path_to_examples, modelf_DISC)
        cpath_DISC = 'IfExpExamples.IfExpExample2'
        fname_DISC = cpath_DISC.replace('.','_',1)

        mc.compile_model(fpath_DISC, cpath_DISC)
        
    def setUp(self):
        """Load the test model."""
        package_DAE = 'Pendulum_pack_Pendulum'
        package_DISC = 'IfExpExamples_IfExpExample2'

        # Load the dynamic library and XML data
        self.m_DAE = jmi.Model(package_DAE)
        self.m_DISC = jmi.Model(package_DISC)
        
        # Creates the solvers
        self.DAE = JMIDAE(self.m_DAE)
        self.DISC = JMIDAE(self.m_DISC)
        
    def test_eps(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.get/set_eps
        """
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, 'Test')
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, -1)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, 1)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_eps, -1.0)
        
        self.DAE.eps = 1.0
        assert self.DAE.eps == 1.0
        self.DAE.eps = 10.0
        assert self.DAE.eps == 10.0
        
    def test_max_eIteration(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.get/set_max_eIteration
        """
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, 'Test')
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, -1)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, 1.0)
        nose.tools.assert_raises(JMIModel_Exception, self.DAE._set_max_eIteration, -1.0)
        
        self.DAE.max_eIter = 1
        assert self.DAE.max_eIter == 1
        self.DAE.max_eIter = 10
        assert self.DAE.max_eIter == 10
        
    def test_check_eIter(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.check_eIter
        """
        self.DAE.eps = 1e-4
        
        b_mode = [1, -1, 0]
        a_mode = [-1, 1, 1]
        
        [eIter, iter] = self.DAE.check_eIter(b_mode, a_mode)
        
        assert iter == True
        assert eIter[0] == -1
        assert eIter[1] == 1
        assert eIter[2] == 1
        
        b_mode = [2, 5, 1]
        a_mode = [0, 2, 2]
        
        [eIter, iter] = self.DAE.check_eIter(b_mode, a_mode)
        
        assert iter == False
        assert eIter[0] == 0
        assert eIter[1] == 0
        assert eIter[2] == 0
        
    def test_event_switch(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.event_switch
        """
        solver = lambda x:1
        solver.verbosity = 1
        solver.LOUD = 2
        solver.switches = [False, False, True]
        event_info = [1, 0, -1]
        
        self.DAE.event_switch(solver,event_info)
        
        assert solver.switches[0] == True
        assert solver.switches[1] == False
        assert solver.switches[2] == False
        
    def test_f(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.f
        """
        test_x = N.array([1.,1.,1.,1.])
        test_dx = N.array([2.,2.,2.,2.])
        test_t = 2
        
        temp_f = self.DAE.f(test_t,test_x,test_dx)
        
        assert temp_f[0] == -1.0
        assert temp_f[2] == -1.0
        assert temp_f[3] == -2.0
        nose.tools.assert_almost_equal(temp_f[1], -1.158529, 5)
        
    def test_g(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.g
        """
        temp_g = self.DISC.g(2.,[1.,2.],[2.,0],[0,0])
        
        nose.tools.assert_almost_equal(temp_g[0], -0.429203, 5)
        nose.tools.assert_almost_equal(temp_g[1], 1.141592, 5)
        
    def test_g_adjust(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.g
        """
        self.DISC.eps = 2.0

        temp_g_adjust = self.DISC.g_adjust(2.,[1.,2.],[2.,0],[0,0])

        nose.tools.assert_almost_equal(temp_g_adjust[0], -2.429203, 5)
        nose.tools.assert_almost_equal(temp_g_adjust[1], -0.858407, 5)
        
        temp_g_adjust = self.DISC.g_adjust(2.,[1.,2.],[2.,0],[0,1])
        
        nose.tools.assert_almost_equal(temp_g_adjust[0], -2.429203, 5)
        nose.tools.assert_almost_equal(temp_g_adjust[1], 3.141592, 5)
        

    def test_init(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.__init__
        """
        assert self.m_DAE == self.DAE._model
        assert self.DAE.max_eIter == 50
        assert self.DAE.eps == 1e-9
        assert self.DAE.jac == self.DAE.j
        
        temp_y0 = N.append(self.m_DAE.real_x.copy(), self.m_DAE.real_w.copy())
        temp_yd0 = N.append(self.m_DAE.real_dx.copy(),[0]*len(self.m_DAE.real_w))
        temp_algvar = [1.0]*len(self.m_DAE.real_x) + [0.0]*len(self.m_DAE.real_w)
        
        for i in range(len(temp_y0)):
            assert temp_y0[i] == self.DAE.y0[i]
            assert temp_yd0[i] == self.DAE.yd0[i]
            assert temp_algvar[i] == self.DAE.algvar[i]
            
        #Test discontiniuous system
        assert self.DISC._g_nbr == 2
        assert self.DISC.event_fcn == self.DISC.g_adjust
        
    def test_reset(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.reset
        """   
        self.DAE.t0 = 10.0
        self.DAE._model.real_x = N.array([2.,2.,2.,2.])
        self.DAE._model.real_dx = N.array([2.,2.,2.,2.])

        self.DAE.reset()
        
        assert self.DAE._model.t == 10.0
        assert self.DAE._model.real_x[0] != 2.0
        assert self.DAE._model.real_x[1] != 2.0
        assert self.DAE._model.real_x[2] != 2.0
        assert self.DAE._model.real_dx[0] != 2.0
        assert self.DAE._model.real_dx[1] != 2.0
        assert self.DAE._model.real_dx[2] != 2.0        
       
        assert self.DAE.y0[0] == 0.1


    def test_j(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.j
        """
        
        test_x = N.array([1.,1.,1.,1.])
        test_dx = N.array([2.,2.,2.,2.])
        test_t = 2
        
        temp_j = self.DAE.j(0.1,test_t,test_x,test_dx)
        print temp_j
        assert temp_j[0,0] == -0.1
        assert temp_j[0,1] == 1.0
        assert temp_j[1,1] == -0.1
        nose.tools.assert_almost_equal(temp_j[1,0], 0.5403023, 5)
        
    def test_handle_event(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.handle_event
        """
        solver = lambda x:1
        solver.verbosity = 1
        solver.NORMAL = solver.LOUD = 2
        solver.t = [[1.0]]
        solver.y = [[1.,1.]]
        solver.yd = [[1.,1.]]
        solver.switches = [False,True]
        self.DISC.event_switch = lambda x,y:1
        self.DISC.init_mode = lambda x:1
        self.DISC.check_eIter = lambda x,y: [True,False]
        
        self.DISC.handle_event(solver, [1,1])
        
        self.DISC.check_eIter = lambda x,y: [True,True]
        
        self.DISC.handle_event(solver, [1,1])

        
        
    def test_init_mode(self):
        """
        Tests jmodelica.simulation.assimulo.init_mode
        """
        solver = lambda x:1
        solver.switches = [True, True]
        solver.make_consistency = lambda x:1
        
        self.DISC.init_mode(solver)
        
        assert self.DISC._model.sw[0] == 1
        assert self.DISC._model.sw[1] == 1
    
    def test_initiate(self):
        """
        Tests jmodelica.simulation.assimulo.initiate
        """
        self.DAE.init_mode = lambda x:1
        self.DAE.initiate('Test')
        
        self.DISC.handle_event = lambda x,y:1
        solver = lambda x:1
        solver.switches = [False, False]
        
        self.DISC.initiate(solver)

        assert solver.switches[0] == True
        assert solver.switches[1] == True
