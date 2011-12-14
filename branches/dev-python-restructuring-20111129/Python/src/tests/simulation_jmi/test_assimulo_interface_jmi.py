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
import logging
import nose
import os
import numpy as N
import pylab as P
from scipy.io.matlab.mio import loadmat
from pyjmi.jmi import compile_jmu
from pyjmi.jmi import JMUModel
from pyfmi.fmi import compile_fmu
from pyfmi.fmi import FMUModel
import pyfmi.fmi as fmi
from pyjmi.common.io import ResultDymolaTextual
from pyjmi.tests import testattr
from pyjmi.tests import get_files_path

try:
    from pyjmi.simulation.assimulo_interface import JMIODE, JMIDAE, JMIModel_Exception
    from pyfmi.simulation.assimulo_interface import FMIODE
    from pyjmi.simulation.assimulo_interface import JMIDAESens
    from pyjmi.simulation.assimulo_interface import write_data
    from pyjmi.common.core import TrajectoryLinearInterpolation
    from assimulo.explicit_ode import CVode
    from assimulo.implicit_ode import IDA
except NameError, ImportError:
    logging.warning('Could not load Assimulo module. Check jmodelica.check_packages()')

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_mos  = os.path.join(get_files_path(), 'Modelica')

class Test_JMI_ODE:
    """
    This class tests jmodelica.simulation.assimulo.JMIODE
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        fpath_ODE = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        cpath_ODE = 'VDP_pack.VDP_Opt'

        # compile VDP
        fname_ODE = compile_jmu(cpath_ODE, fpath_ODE, 
                    compiler_options={'state_start_values_fixed':True})

        fpath = os.path.join(get_files_path(), 'Modelica', 'DoubleInput.mo')
        cpath = 'DoubleInput_Nominal'
        fname = compile_jmu(cpath, fpath, 
                    compiler_options={"enable_variable_scaling":True})
        
    def setUp(self):
        """Load the test model."""
        package_ODE = 'VDP_pack_VDP_Opt.jmu'
        package_INPUT = 'DoubleInput_Nominal.jmu'

        # Load the dynamic library and XML data
        self.m_ODE = JMUModel(package_ODE)
        self.m_INPUT = JMUModel(package_INPUT)
        
        # Creates the solvers
        self.ODE = JMIODE(self.m_ODE)
    
    @testattr(assimulo = True)
    def test_result_name_file(self):
        """
        Tests user naming of result file (JMIODE).
        """
        res = self.m_ODE.simulate()
        
        #Default name
        assert res.result_file == "VDP_pack_VDP_Opt_result.txt"
        assert os.path.exists(res.result_file)
        
        self.m_ODE.reset()
        
        res = self.m_ODE.simulate(options={"result_file_name":
                                    "VDP_pack_VDP_Opt_result_test.txt"})
                                    
        #User defined name
        assert res.result_file == "VDP_pack_VDP_Opt_result_test.txt"
        assert os.path.exists(res.result_file)
    
    @testattr(assimulo = True)
    def test_input(self):
        """
        Tests the input.
        """
        t = N.linspace(1,10.,100)
        u = (0.75)*N.ones(N.size(t,0))
        u_traj = TrajectoryLinearInterpolation(t,u.reshape(100,1))
        
        ODE =  JMIODE(self.m_ODE, ('u',u_traj))
        
        vdp_sim = CVode(ODE)

        vdp_sim(10,100)
    
        write_data(vdp_sim)
    
        # Load the file we just wrote to file
        res = ResultDymolaTextual('VDP_pack_VDP_Opt_result.txt')
    
        x1=res.get_variable_data('x1')
        x2=res.get_variable_data('x2')
        u =res.get_variable_data('u')
        
        assert u.x[-1] == 0.75
        nose.tools.assert_almost_equal(x1.x[-1], -0.54108518, 5)
        nose.tools.assert_almost_equal(x2.x[-1], -0.81364915, 5)
    
    @testattr(assimulo = True)
    def test_scaled_input(self):
        """
        Tests that simulation of scaled input works.
        """
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u1,u2)))
        
        opts = self.m_INPUT.simulate_options()
        opts["solver"] = "CVode"
        
        res = self.m_INPUT.simulate(final_time=10, input=(['u1','u2'],u_traj),
                                    options=opts)
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
    
    @testattr(assimulo = True) 
    def test_init(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.__init__
        """
        assert self.m_ODE == self.ODE._model
        
        for i in range(len(self.ODE.y0)):
            assert self.m_ODE.real_x[i] == self.ODE.y0[i]
            
        #Test for algebraic variables
        fpath_DAE = os.path.join(get_files_path(), 'Modelica', 
            'RLC_Circuit.mo')
        cpath_DAE = 'RLC_Circuit'

        fname_DAE = compile_jmu(cpath_DAE, fpath_DAE)
        package_DAE = 'RLC_Circuit.jmu'
        # Load the dynamic library and XML data
        m_DAE = JMUModel(package_DAE)
        
        nose.tools.assert_raises(JMIModel_Exception, JMIODE, m_DAE)
        

        #Test for discontinious model
        fpath_DISC = os.path.join(get_files_path(), 'Modelica', 'IfExpExamples.mo')
        cpath_DISC = 'IfExpExamples.IfExpExample2'

        fname_ODE = compile_jmu(cpath_DISC, fpath_DISC)
        package_DISC = 'IfExpExamples_IfExpExample2.jmu'
        # Load the dynamic library and XML data
        m_DISC = JMUModel(package_DISC)
        
        nose.tools.assert_raises(JMIModel_Exception, JMIODE, m_DISC)
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True) 
    def test_j(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.j
        """
        test_x = N.array([1.,1.,1.])
        test_t = 2
        
        temp_j = self.ODE.j(test_t,test_x)
        #print temp_j
        assert temp_j[0,0] == 0.0
        assert temp_j[0,1] == -3.0
        assert temp_j[0,2] == 0.0
        assert temp_j[1,0] == 1.0
        assert temp_j[1,1] == 0.0
        assert temp_j[1,2] == 0.0
        nose.tools.assert_almost_equal(temp_j[2,0], 14.7781122, 5)
        nose.tools.assert_almost_equal(temp_j[2,1], 14.7781122, 5)
        assert temp_j[2,2] == 0.0
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True) 
    def test_g(self):
        """
        Tests jmodelica.simulation.assimulo.JMIODE.g
        """
        #This is not implemented in JMIODE yet.
        pass
        
    @testattr(assimulo = True)
    def test_double_input(self):
        """
        This tests double input.
        """
        fpath = os.path.join(get_files_path(), 'Modelica', 'DoubleInput.mo')
        cpath = 'DoubleInput'

        # compile VDP
        fname = compile_jmu(cpath, fpath, 
                    compiler_options={'state_start_values_fixed':True})

        # Load the dynamic library and XML data
        dInput = JMUModel(fname)
        
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u1,u2)))
        
        res = dInput.simulate(final_time=10, input=(['u1','u2'],u_traj),options={'solver':'CVode'})
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
        #TEST REVERSE ORDER OF INPUT
        
        # Load the dynamic library and XML data
        dInput = JMUModel(fname)
        
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u2,u1)))
        
        res = dInput.simulate(final_time=10, input=(['u2','u1'],u_traj),options={'solver':'CVode'})
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)

        
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
        fpath_DAE = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack_no_opt.mo')
        cpath_DAE = 'Pendulum_pack.Pendulum'

        fname_DISC = compile_jmu(cpath_DAE, fpath_DAE)
        
        fpath_DISC = os.path.join(get_files_path(), 'Modelica', 
            'IfExpExamples.mo')
        cpath_DISC = 'IfExpExamples.IfExpExample2'
        
        fname_DISC = compile_jmu(cpath_DISC, fpath_DISC)
        
        fpath = os.path.join(get_files_path(), 'Modelica', 'DoubleInput.mo')
        cpath = 'DoubleInput_Nominal'
        fname = compile_jmu(cpath, fpath, 
                    compiler_options={"enable_variable_scaling":True})
        
    def setUp(self):
        """Load the test model."""
        package_DAE = 'Pendulum_pack_Pendulum.jmu'
        package_DISC = 'IfExpExamples_IfExpExample2.jmu'
        package_INPUT = 'DoubleInput_Nominal.jmu'

        # Load the dynamic library and XML data
        self.m_DAE = JMUModel(package_DAE)
        self.m_DISC = JMUModel(package_DISC)
        self.m_INPUT = JMUModel(package_INPUT)
        
        # Creates the solvers
        self.DAE = JMIDAE(self.m_DAE)
        self.DISC = JMIDAE(self.m_DISC)
        
    @testattr(assimulo = True)
    def test_result_name_file(self):
        """
        Tests user naming of result file (JMIDAE).
        """
        res = self.m_DAE.simulate()
        
        #Default name
        assert res.result_file == "Pendulum_pack_Pendulum_result.txt"
        assert os.path.exists(res.result_file)
        
        res = self.m_DAE.simulate(options={"result_file_name":
                                    "Pendulum_pack_Pendulum_result_test.txt"})
                                    
        #User defined name
        assert res.result_file == "Pendulum_pack_Pendulum_result_test.txt"
        assert os.path.exists(res.result_file)
        
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True)
    def test_scaled_input(self):
        """
        Tests that simulation of scaled input works.
        """
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u1,u2)))
        
        res = self.m_INPUT.simulate(final_time=10, input=(['u1','u2'],u_traj))
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True) 
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
    
    @testattr(assimulo = True) 
    def test_g(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.g
        """
        temp_g = self.DISC.g(2.,[1.,2.],[2.,0],[0,0])
        
        nose.tools.assert_almost_equal(temp_g[0], -0.429203, 5)
        nose.tools.assert_almost_equal(temp_g[1], 1.141592, 5)
    
    @testattr(assimulo = True) 
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
        
    @testattr(assimulo = True) 
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
        assert self.DISC.state_events == self.DISC.g_adjust
    
    @testattr(assimulo = True) 
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

    @testattr(assimulo = True)
    def test_event_iteration(self):
        """
        This tests JMUs with event iteration (JModelica.org).
        """
        jmu_name = compile_jmu('EventIter.EventMiddleIter', os.path.join(path_to_mos,'EventIter.mo'))

        model = JMUModel(jmu_name)

        sim_res = model.simulate(final_time=10)

        x = sim_res['x']
        y = sim_res['y']
        z = sim_res['z']
        
        nose.tools.assert_almost_equal(x[0], 2.00000, 4)
        nose.tools.assert_almost_equal(x[-1], 10.000000, 4)
        nose.tools.assert_almost_equal(y[-1], 3.0000000, 4)
        nose.tools.assert_almost_equal(z[-1], 2.0000000, 4)
        
        jmu_name = compile_jmu('EventIter.EventStartIter', os.path.join(path_to_mos,'EventIter.mo'))
        
        model = JMUModel(jmu_name)

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
    def test_j(self):
        """
        Tests jmodelica.simulation.assimulo.JMIDAE.j
        """
        
        test_x = N.array([1.,1.,1.,1.])
        test_dx = N.array([2.,2.,2.,2.])
        test_t = 2
        
        temp_j = self.DAE.j(0.1,test_t,test_x,test_dx)
        #print temp_j
        assert temp_j[0,0] == -0.1
        assert temp_j[0,1] == 1.0
        assert temp_j[1,1] == -0.1
        nose.tools.assert_almost_equal(temp_j[1,0], 0.5403023, 5)
    
    @testattr(assimulo = True) 
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
        solver.t_cur = N.array(1.0)
        solver.y_cur = N.array([1.,1.])
        solver.yd_cur = N.array([1.,1.])
        solver.switches = [False,True]
        self.DISC.event_switch = lambda x,y:1
        self.DISC.init_mode = lambda x:1
        self.DISC.check_eIter = lambda x,y: [True,False]
        
        self.DISC.handle_event(solver, [1,1])
        
        self.DISC.check_eIter = lambda x,y: [True,True]
        
        self.DISC.handle_event(solver, [1,1])

    @testattr(assimulo = True) 
    def test_init_mode(self):
        """
        Tests jmodelica.simulation.assimulo.init_mode
        """
        solver = lambda x:1
        solver.switches = [True, True]
        solver.make_consistent = lambda x:1
        
        self.DISC.init_mode(solver)
        
        assert self.DISC._model.sw[0] == 1
        assert self.DISC._model.sw[1] == 1
    
    @testattr(assimulo = True) 
    def test_initiate(self):
        """
        Tests jmodelica.simulation.assimulo.initiate
        """
        #self.DAE.init_mode = lambda x:1
        #self.DAE.initiate('Test')
        
        #self.DISC.handle_event = lambda x,y:1
        #solver = lambda x:1
        #solver.switches = [False, False]
        
        #self.DISC.initiate(solver)

        #assert solver.switches[0] == True
        #assert solver.switches[1] == True
        pass
    """
    @testattr(assimulo = True)
    def test_scaled_input(self):
        #This tests simulation with scaled input.
        fpath = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        cpath = 'VDP_pack.VDP_scaled_input'
        
        # compile VDP
        jmu_name = compile_jmu(cpath, fpath, 
                    compiler_options={'enable_variable_scaling':True})

        # Load the dynamic library and XML data
        vdp = JMUModel(jmu_name)
        
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)/10.0
        u_traj = N.transpose(N.vstack((t,u1)))
        
        res_scaled = vdp.simulate(final_time=10, input=(['u'],u_traj))
        
        # compile VDP
        jmu_name = compile_jmu(cpath, fpath, 
                    compiler_options={'enable_variable_scaling':False})

        # Load the dynamic library and XML data
        vdp = JMUModel(jmu_name)
        
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u_traj = N.transpose(N.vstack((t,u1)))
        
        res = vdp.simulate(final_time=10, input=(['u'],u_traj))
        
        nose.tools.assert_almost_equal(res["u"][0], res_scaled["u"][0], 3)
        nose.tools.assert_almost_equal(res["u"][-1], res_scaled["u"][-1], 3)
    """
    @testattr(assimulo = True)
    def test_order_input(self):
        """
        This tests that the inputs are sorted in an correct value reference order
        when being written to file.
        """
        fpath = os.path.join(get_files_path(), 'Modelica', 'OrderInputs.mop')
        cpath = 'OptimInputs'
        
        unames = ['u1', 'u_e2', 'u_h3', 'u_c4', 'u_p5']
        n = len(unames)

        uvalues = [1.,2.,3.,4.,5.]

        data = N.array([[0.,1.,2.,3.,4.,5.],
                 [1.,1.,2.,3.,4.,5.],
                 [2.,1.,2.,3.,4.,5.]])
        inputtuple = (unames,data)
        jmu_name = compile_jmu(cpath,fpath)
        
        model = JMUModel(jmu_name)
        res = model.simulate(0,2,input=inputtuple)
        
        nose.tools.assert_almost_equal(res["u1"][-1], 1.000000000, 3)
        nose.tools.assert_almost_equal(res["u_e2"][-1], 2.00000, 3)
        nose.tools.assert_almost_equal(res["u_h3"][-1], 3.00000, 3)
        nose.tools.assert_almost_equal(res["u_c4"][-1], 4.000000, 3)
        nose.tools.assert_almost_equal(res["u_p5"][-1], 5.000000, 3)
        
        nose.tools.assert_almost_equal(res["T.u1"][-1], 1.000000000, 3)
        nose.tools.assert_almost_equal(res["T.u_e2"][-1], 2.00000, 3)
        nose.tools.assert_almost_equal(res["T.u_h3"][-1], 3.00000, 3)
        nose.tools.assert_almost_equal(res["T.u_c4"][-1], 4.000000, 3)
        nose.tools.assert_almost_equal(res["T.u_p5"][-1], 5.000000, 3)

    @testattr(assimulo = True)
    def test_double_input(self):
        """
        This tests double input.
        """
        fpath = os.path.join(get_files_path(), 'Modelica', 'DoubleInput.mo')
        cpath = 'DoubleInput'

        # compile VDP
        fname = compile_jmu(cpath, fpath, 
                    compiler_options={'state_start_values_fixed':True})

        # Load the dynamic library and XML data
        dInput = JMUModel(fname)
        
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u1,u2)))
        
        res = dInput.simulate(final_time=10, input=(['u1','u2'],u_traj))
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
        #TEST REVERSE ORDER OF INPUT
        
        # Load the dynamic library and XML data
        dInput = JMUModel(fname)
        
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u2,u1)))
        
        res = dInput.simulate(final_time=10, input=(['u2','u1'],u_traj))
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)

    @testattr(assimulo = True)
    def test_double_input_with_function(self):
        """
        This tests double input with function.
        """
        fpath = os.path.join(get_files_path(), 'Modelica', 'DoubleInput.mo')
        cpath = 'DoubleInput'

        # compile VDP
        fname = compile_jmu(cpath, fpath, 
                    compiler_options={'state_start_values_fixed':True})

        # Load the dynamic library and XML data
        dInput = JMUModel(fname)

        def func(t):
            return N.array([N.cos(t),N.sin(t)])
        
        res = dInput.simulate(final_time=10, input=(['u1','u2'],func))
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
        #TEST REVERSE ORDER OF INPUT
        
        # Load the dynamic library and XML data
        dInput = JMUModel(fname)

        def func(t):
            return [N.sin(t),N.cos(t)]
        
        res = dInput.simulate(final_time=10, input=(['u2','u1'],func))
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
        
class Test_JMI_DAE_Sens:
    """
    This class tests jmodelica.simulation.assimulo.JMIDAESens
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        #DAE with disc
        fpath_DISC = os.path.join(get_files_path(), 'Modelica', 
            'IfExpExamples.mo')
        cpath_DISC = 'IfExpExamples.IfExpExample2'
        
        fname_DISC = compile_jmu(cpath_DISC, fpath_DISC)
        
        #DAE test model
        fpath_DAE = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack_no_opt.mo')
        cpath_DAE = 'Pendulum_pack.Pendulum'

        fname_DAE = compile_jmu(cpath_DAE, fpath_DAE)
        
        #DAE with sens
        fpath_SENS = os.path.join(get_files_path(), 'Modelica', 
            'QuadTankSens.mop')
        cpath_SENS = 'QuadTankSens'
        
        fname_SENS = compile_jmu(cpath_SENS, fpath_SENS, compiler_options={"enable_variable_scaling":True})
        
        fpath = os.path.join(get_files_path(), 'Modelica', 'DoubleInput.mo')
        cpath = 'DoubleInput_Nominal'
        fname = compile_jmu(cpath, fpath, 
                    compiler_options={"enable_variable_scaling":True})
        
    def setUp(self):
        """Load the test model."""
        package_DAE = 'Pendulum_pack_Pendulum.jmu'
        package_SENS = 'QuadTankSens.jmu'
        package_DISC = 'IfExpExamples_IfExpExample2.jmu'
        package_INPUT = 'DoubleInput_Nominal.jmu'

        # Load the dynamic library and XML data
        self.m_DAE = JMUModel(package_DAE)
        self.m_SENS = JMUModel(package_SENS)
        self.m_DISC = JMUModel(package_DISC)
        self.m_INPUT = JMUModel(package_INPUT)

        # Creates the solvers
        self.DAE = JMIDAESens(self.m_DAE)
        self.SENS = JMIDAESens(self.m_SENS)
    
    @testattr(assimulo = True)
    def test_no_events(self):
        """
        Tests that models containing events cannot be simulated with JMIDAESens.
        """
        opts = self.m_DISC.simulate_options()
        opts["IDA_options"]["sensitivity"] = True
        nose.tools.assert_raises(JMIModel_Exception,self.m_DISC.simulate, 0, 1,None,"AssimuloAlg", opts)
    
    @testattr(assimulo = True)
    def test_result_name_file(self):
        """
        Tests user naming of result file (JMIDAESens).
        """
        path_result = os.path.join(get_files_path(), 'Results', 
                                'qt_par_est_data.mat')
        
        data = loadmat(path_result,appendmat=False)

        # Extract data series  
        t_meas = data['t'][6000::100,0]-60  
        u1 = data['u1_d'][6000::100,0]
        u2 = data['u2_d'][6000::100,0]
                
        # Build input trajectory matrix for use in simulation
        u_data = N.transpose(N.vstack((t_meas,u1,u2)))

        input_object = (['u1','u2'], u_data)
        
        opts = self.m_SENS.simulate_options()
        opts['IDA_options']['sensitivity']=True
        
        res = self.m_SENS.simulate(options=opts)
        
        #Default name
        assert res.result_file == "QuadTankSens_result.txt"
        assert os.path.exists(res.result_file)
        
        self.m_SENS.reset()
        
        opts["result_file_name"] = "QuadTankSens_result_test.txt"
        
        res = self.m_SENS.simulate(options=opts)
                                    
        #User defined name
        assert res.result_file == "QuadTankSens_result_test.txt"
        assert os.path.exists(res.result_file)
    
    @testattr(assimulo = True)
    def test_ordinary_dae(self):
        """
        This tests a simulation using JMIDAESens without any parameters.
        """
        sim = IDA(self.DAE)
        
        sim.simulate(1.0)

        nose.tools.assert_almost_equal(sim.y[-1][0], 0.15420124, 4)
        nose.tools.assert_almost_equal(sim.y[-1][1], 0.11721253, 4)
    
    @testattr(assimulo = True)
    def test_p0(self):
        """
        This test that the correct number of parameters are found.
        """
        assert self.SENS._p_nbr == 4
        assert self.SENS._parameter_names[0] == 'a1'
        assert self.SENS._parameter_names[1] == 'a2'
        assert self.SENS._parameter_names[2] == 'a3'
        assert self.SENS._parameter_names[3] == 'a4'
        
    @testattr(assimulo = True)
    def test_input_simulation(self):
        """
        This tests that input simulation works.
        """
        path_result = os.path.join(get_files_path(), 'Results', 
                                'qt_par_est_data.mat')
        
        data = loadmat(path_result,appendmat=False)

        # Extract data series  
        t_meas = data['t'][6000::100,0]-60  
        u1 = data['u1_d'][6000::100,0]
        u2 = data['u2_d'][6000::100,0]
                
        # Build input trajectory matrix for use in simulation
        u_data = N.transpose(N.vstack((t_meas,u1,u2)))

        u_traj = TrajectoryLinearInterpolation(u_data[:,0], 
                            u_data[:,1:])

        input_object = (['u1','u2'], u_traj)
        
        qt_mod = JMIDAESens(self.m_SENS, input_object)

        qt_sim = IDA(qt_mod)

        #Store data continuous during the simulation, important when solving a 
        #problem with sensitivites.
        qt_sim.store_cont = True 
            
        #Value used when IDA estimates the tolerances on the parameters
        qt_sim.pbar = qt_mod.p0 
            
        #Let Sundials find consistent initial conditions by use of 'IDA_YA_YDP_INIT'
        qt_sim.make_consistent('IDA_YA_YDP_INIT')
            
        #Simulate
        qt_sim.simulate(60) #Simulate 4 seconds with 400 communication points

        write_data(qt_sim)

        res = ResultDymolaTextual('QuadTankSens_result.txt')
    
        dx1da1 = res.get_variable_data('dx1/da1')
        dx1da2 = res.get_variable_data('dx1/da2')
        dx4da1 = res.get_variable_data('dx4/da1')
        
        nose.tools.assert_almost_equal(dx1da2.x[0], 0.000000, 4)
        nose.tools.assert_almost_equal(dx1da2.x[-1], 0.00000, 4)

    @testattr(assimulo = True)
    def test_order_input(self):
        """
        This tests that the inputs are sorted in an correct value reference order
        when being written to file.
        """
        fpath = os.path.join(get_files_path(), 'Modelica', 'OrderInputs.mop')
        cpath = 'OptimInputs'
        
        unames = ['u1', 'u_e2', 'u_h3', 'u_c4', 'u_p5']
        n = len(unames)

        uvalues = [1.,2.,3.,4.,5.]

        data = N.array([[0.,1.,2.,3.,4.,5.],
                 [1.,1.,2.,3.,4.,5.],
                 [2.,1.,2.,3.,4.,5.]])
        inputtuple = (unames,data)
        jmu_name = compile_jmu(cpath,fpath)
        
        model = JMUModel(jmu_name)
        
        opts = model.simulate_options()
        
        opts["IDA_options"]["sensitivity"] = True
        opts["IDA_options"]["write_cont"] = True
        
        res = model.simulate(0,2,input=inputtuple, options=opts)
        
        nose.tools.assert_almost_equal(res["u1"][-1], 1.000000000, 3)
        nose.tools.assert_almost_equal(res["u_e2"][-1], 2.00000, 3)
        nose.tools.assert_almost_equal(res["u_h3"][-1], 3.00000, 3)
        nose.tools.assert_almost_equal(res["u_c4"][-1], 4.000000, 3)
        nose.tools.assert_almost_equal(res["u_p5"][-1], 5.000000, 3)
        
        nose.tools.assert_almost_equal(res["T.u1"][-1], 1.000000000, 3)
        nose.tools.assert_almost_equal(res["T.u_e2"][-1], 2.00000, 3)
        nose.tools.assert_almost_equal(res["T.u_h3"][-1], 3.00000, 3)
        nose.tools.assert_almost_equal(res["T.u_c4"][-1], 4.000000, 3)
        nose.tools.assert_almost_equal(res["T.u_p5"][-1], 5.000000, 3)

    @testattr(assimulo = True)
    def test_input_simulation_high_level_switched_input(self):
        """
        This tests that input simulation works when using high-level methods
        and the inputs are not in JModelica order.
        """
        model = self.m_SENS
        path_result = os.path.join(get_files_path(), 'Results', 
                                'qt_par_est_data.mat')
        
        data = loadmat(path_result,appendmat=False)

        # Extract data series  
        t_meas = data['t'][6000::100,0]-60  
        u1 = data['u1_d'][6000::100,0]
        u2 = data['u2_d'][6000::100,0]
                
        # Build input trajectory matrix for use in simulation
        u_data = N.transpose(N.vstack((t_meas,u2,u1)))

        input_object = (['u2','u1'], u_data)
        
        opts = model.simulate_options()
        opts['IDA_options']['sensitivity']=True
        
        ##Store data continuous during the simulation, important when solving a 
        ##problem with sensitivites. FIXED INTERNALLY
        opts['IDA_options']['write_cont']=True
        
        res = model.simulate(final_time=60, input=input_object, options=opts)

        #Value used when IDA estimates the tolerances on the parameters
        #qt_sim.pbar = qt_mod.p0 

        dx1da1 = res['dx1/da1']
        dx1da2 = res['dx1/da2']
        dx4da1 = res['dx4/da1']

        nose.tools.assert_almost_equal(dx1da2[0], 0.000000, 4)
        nose.tools.assert_almost_equal(dx1da2[-1], 0.00000, 4)
        nose.tools.assert_almost_equal(res["u1"][-1], u1[-1], 4)
        nose.tools.assert_almost_equal(res["u2"][-1], u2[-1], 4)

    @testattr(assimulo = True)
    def test_input_simulation_high_level(self):
        """
        This tests that input simulation works using high-level methods.
        """
        model = self.m_SENS
        path_result = os.path.join(get_files_path(), 'Results', 
                                'qt_par_est_data.mat')
        
        data = loadmat(path_result,appendmat=False)

        # Extract data series  
        t_meas = data['t'][6000::100,0]-60  
        u1 = data['u1_d'][6000::100,0]
        u2 = data['u2_d'][6000::100,0]
                
        # Build input trajectory matrix for use in simulation
        u_data = N.transpose(N.vstack((t_meas,u1,u2)))

        input_object = (['u1','u2'], u_data)
        
        opts = model.simulate_options()
        opts['IDA_options']['sensitivity']=True
        
        ##Store data continuous during the simulation, important when solving a 
        ##problem with sensitivites. FIXED INTERNALLY
        opts['IDA_options']['write_cont']=True
        
        res = model.simulate(final_time=60, input=input_object, options=opts)

        #Value used when IDA estimates the tolerances on the parameters
        #qt_sim.pbar = qt_mod.p0 

        dx1da1 = res['dx1/da1']
        dx1da2 = res['dx1/da2']
        dx4da1 = res['dx4/da1']

        nose.tools.assert_almost_equal(dx1da2[0], 0.000000, 4)
        nose.tools.assert_almost_equal(dx1da2[-1], 0.00000, 4)
        nose.tools.assert_almost_equal(res["u1"][-1], u1[-1], 4)
        nose.tools.assert_almost_equal(res["u2"][-1], u2[-1], 4)
        
    @testattr(assimulo = True)
    def test_jac(self):
        """
        This tests the jacobian for simulation of sensitivites.
        """
        model = self.m_SENS
        
        opts = model.simulate_options()
        opts['IDA_options']['sensitivity'] = True
        
        res = model.simulate(final_time=10, options=opts)
        
        prob = res.solver._problem
        
        assert res.solver.usejac == True
        assert prob.j == prob.jac
    
    @testattr(assimulo = True)
    def test_scaling_test_2(self):
        """
        This tests a simulation when scaling is ON and there are input variables
        that are not used.
        """
        jmu_name = compile_jmu("Englezos652_with_input", os.path.join(get_files_path()
                        ,"Modelica","Englezos652.mop"),
                        compiler_options={"enable_variable_scaling":False})

        # Load a model instance into Python
        model = JMUModel(jmu_name)

        # Get and set the options
        opts = model.simulate_options()
        opts['IDA_options']['atol'] = 1.0e-6
        opts['IDA_options']['rtol'] = 1.0e-6
        opts['IDA_options']['sensitivity'] = True
        opts['ncp'] = 400
        
        res = model.simulate(0,1697000/3, options=opts)
        
        x1 = res["x1"][-1]
        r1 = res["r1"][-1]
        u1 = res["u1"][-1]

        nose.tools.assert_almost_equal(x1, 0.45537058, 3)
        nose.tools.assert_almost_equal(r1, 5.3287e-8, 2)
        nose.tools.assert_almost_equal(u1, 0.00000, 3)
    
    @testattr(assimulo = True)
    def test_scaled_input(self):
        """
        Tests that simulation of scaled input works.
        """
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u1,u2)))
        
        opts = self.m_INPUT.simulate_options()
        opts['IDA_options']['atol'] = 1.0e-6
        opts['IDA_options']['rtol'] = 1.0e-6
        opts['IDA_options']['sensitivity'] = True
        opts['ncp'] = 0
        
        res = self.m_INPUT.simulate(final_time=10, input=(['u1','u2'],u_traj),
                                    options=opts)
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
        
    @testattr(assimulo = True)
    def test_scaled_input_continuous(self):
        """
        Tests that simulation of scaled input works for writing continuous.
        """
        t = N.linspace(0.,10.,100) 
        u1 = N.cos(t)
        u2 = N.sin(t)
        u_traj = N.transpose(N.vstack((t,u1,u2)))
        
        opts = self.m_INPUT.simulate_options()
        opts['IDA_options']['atol'] = 1.0e-6
        opts['IDA_options']['rtol'] = 1.0e-6
        opts['IDA_options']['sensitivity'] = True
        opts['IDA_options']['write_cont'] = True
        opts['ncp'] = 0
        
        res = self.m_INPUT.simulate(final_time=10, input=(['u1','u2'],u_traj),
                                    options=opts)
        
        r1=res['u1']
        r2=res['u2']
        t1=res['time']
        
        #P.plot(t1,r1,t1,r2)
        #P.show()
        nose.tools.assert_almost_equal(r1[0], 1.000000000, 3)
        nose.tools.assert_almost_equal(r2[0], 0.000000000, 3)
        nose.tools.assert_almost_equal(r1[-1], -0.839071529, 3)
        nose.tools.assert_almost_equal(r2[-1], -0.544021110, 3)
        
        
        
    
    
    @testattr(assimulo = True)
    def test_scaling(self):
        """
        This tests a simulation when scaling is ON and OFF.
        """
        jmu_name = compile_jmu("Englezos652", os.path.join(get_files_path()
                        ,"Modelica","Englezos652.mop"),
                        compiler_options={"enable_variable_scaling":False})

        # Load a model instance into Python
        model = JMUModel(jmu_name)

        # Get and set the options
        opts = model.simulate_options()
        opts['IDA_options']['atol'] = 1.0e-9
        opts['IDA_options']['rtol'] = 1.0e-9
        opts['IDA_options']['sensitivity'] = True
        opts['ncp'] = 400
        
        res_no_scale = model.simulate(final_time=1697000, options=opts)
        
        jmu_name = compile_jmu("Englezos652", os.path.join(get_files_path()
                        ,"Modelica","Englezos652.mop"),
                        compiler_options={"enable_variable_scaling":True})

        # Load a model instance into Python
        model = JMUModel(jmu_name)
        
        res_with_scale = model.simulate(final_time=1697000, options=opts)
        
        nose.tools.assert_almost_equal(res_with_scale['x1'][-1], 
                                       res_no_scale['x1'][-1], 4)
        
        nose.tools.assert_almost_equal(res_with_scale['dx1/dk1'][-1], 
                                       res_no_scale['dx1/dk1'][-1], 1)
        
    @testattr(assimulo = True)
    def test_alias_variables(self):
        """
        This tests a simulation when there are alias in the sensitivity parameters.
        """
        #DAE with sens
        file_name = os.path.join(get_files_path(), 'Modelica', 
            'SensitivityTests.mop')
        model_name = 'SensitivityTests.SensTest1'
        
        jmu_name = compile_jmu(model_name, file_name)
        
        model = JMUModel(jmu_name)
        
        opts = model.simulate_options()
        
        opts['IDA_options']['sensitivity'] = True
        
        res = model.simulate(options=opts)
        
        x1 = res['dx1/da']
        x2 = res['dx2/da']
        x3 = res['dx3/da']
        x4 = res['dx4/da']
        x5 = res['dx5/da']
        
        nose.tools.assert_almost_equal(x2[-1], 0.000000, 4)
        nose.tools.assert_almost_equal(x3[-1], 1.000000, 4)
        nose.tools.assert_almost_equal(x4[-1], -1.000000,4)
        nose.tools.assert_almost_equal(x1[-1], x5[-1], 4)
        
        #The same test using continuous writing
        
        jmu_name = 'SensitivityTests_SensTest1.jmu'
        
        model = JMUModel(jmu_name)
        
        opts = model.simulate_options()
        
        opts['IDA_options']['sensitivity'] = True
        opts['IDA_options']['write_cont'] = True
        
        res = model.simulate(options=opts)
        
        x1 = res['dx1/da']
        x2 = res['dx2/da']
        x3 = res['dx3/da']
        x4 = res['dx4/da']
        x5 = res['dx5/da']
        
        nose.tools.assert_almost_equal(x2[-1], 0.000000, 4)
        nose.tools.assert_almost_equal(x3[-1], 1.000000, 4)
        nose.tools.assert_almost_equal(x4[-1], -1.000000,4)
        nose.tools.assert_almost_equal(x1[-1], x5[-1], 4)
        
        
