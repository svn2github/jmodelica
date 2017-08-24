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

"""
Module containing the tests for the FMI interface.
"""

import nose
import os
import numpy as N
import sys as S
import scipy.sparse.csc

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi.fmi import FMUModel, FMUException, FMUModelME1, FMUModelCS1, load_fmu, FMUModelCS2, FMUModelME2, PyEventInfo
import pyfmi.fmi_algorithm_drivers as ad
from pyfmi.common.core import get_platform_dir
from pyjmi.log import parse_jmi_log, gather_solves
from pyfmi.common.io import ResultHandler
import pyfmi.fmi as fmi

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_fmus_me1 = os.path.join(path_to_fmus,"ME1.0")
path_to_fmus_cs1 = os.path.join(path_to_fmus,"CS1.0")
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

path_to_fmus_me2 = os.path.join(path_to_fmus,"ME2.0")
path_to_fmus_cs2 = os.path.join(path_to_fmus,"CS2.0")
ME2 = 'bouncingBall2_me.fmu'
CS2 = 'bouncingBall2_cs.fmu'
ME1 = 'bouncingBall.fmu'
CS1 = 'bouncingBall.fmu'

class Test_FMUModelBase2:
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.negAliasFmu = compile_fmu("NegatedAlias",os.path.join(path_to_mofiles,"NegatedAlias.mo"), version=2.0)
        #cls.enumFMU = compile_fmu('Parameter.Enum', os.path.join(path_to_mofiles,'ParameterTests.mo'))

    @testattr(fmi = True)
    def test_version(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
        assert negated_alias.get_version() == "2.0"

    @testattr(fmi = True)
    def test_caching(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
        assert len(negated_alias.cache) == 0 #No starting cache
        
        vars_1 = negated_alias.get_model_variables()
        vars_2 = negated_alias.get_model_variables()
        assert id(vars_1) == id(vars_2)
        
        vars_3 = negated_alias.get_model_variables(filter="*")
        assert id(vars_1) != id(vars_3)
        
        vars_4 = negated_alias.get_model_variables(type=0)
        assert id(vars_3) != id(vars_4)
        
        vars_5 = negated_alias.get_model_time_varying_value_references()
        vars_7 = negated_alias.get_model_time_varying_value_references()
        assert id(vars_5) != id(vars_1)
        assert id(vars_5) == id(vars_7)
        
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
        assert len(negated_alias.cache) == 0 #No starting cache
        
        vars_6 = negated_alias.get_model_variables()
        assert id(vars_1) != id(vars_6)


    @testattr(fmi = True)
    def test_set_get_negated_real(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        x,y = negated_alias.get("x"), negated_alias.get("y")
        nose.tools.assert_almost_equal(x,1.0)
        nose.tools.assert_almost_equal(y,-1.0)

        negated_alias.set("y",2)

        x,y = negated_alias.get("x"), negated_alias.get("y")
        nose.tools.assert_almost_equal(x,-2.0)
        nose.tools.assert_almost_equal(y,2.0)

        negated_alias.set("x",3)

        x,y = negated_alias.get("x"), negated_alias.get("y")
        nose.tools.assert_almost_equal(x,3.0)
        nose.tools.assert_almost_equal(y,-3.0)

    @testattr(fmi = True)
    def test_set_get_negated_integer(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        x,y = negated_alias.get("ix"), negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,1.0)
        nose.tools.assert_almost_equal(y,-1.0)

        negated_alias.set("iy",2)

        x,y = negated_alias.get("ix"), negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,-2.0)
        nose.tools.assert_almost_equal(y,2.0)

        negated_alias.set("ix",3)

        x,y = negated_alias.get("ix"), negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,3.0)
        nose.tools.assert_almost_equal(y,-3.0)

class Test_FMUModelCS2:
    """
    This class tests pyfmi.fmi.FMUModelCS2
    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.coupled_name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", target="cs", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.bouncing_name = compile_fmu("BouncingBall",os.path.join(path_to_mofiles,"BouncingBall.mo"), target="cs", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.jacobian_name = compile_fmu("JacFuncTests.BasicJacobianTest",os.path.join(path_to_mofiles,"JacTest.mo"), target="cs", version="2.0", compiler_options={'generate_ode_jacobian':True})
        cls.terminate = compile_fmu("Terminate",os.path.join(path_to_mofiles,"Terminate.mo"),target="cs", version="2.0")
        cls.assert_fail = compile_fmu("AssertFail",os.path.join(path_to_mofiles,"Terminate.mo"),target="cs", version="2.0")
    
        
    @testattr(fmi = True)
    def test_assert_fail(self):
        model = load_fmu(Test_FMUModelCS2.assert_fail)
        
        nose.tools.assert_raises(Exception, model.simulate)
    
    @testattr(fmi = True)
    def test_terminate(self):
        model = load_fmu(Test_FMUModelCS2.terminate)
        
        model.initialize()
        status = model.do_step(0,1)
        
        assert status == fmi.FMI_DISCARD
        assert abs(model.get_real_status(fmi.FMI2_LAST_SUCCESSFUL_TIME) - 0.5) < 1e-3
        
    @testattr(fmi = True)
    def test_terminate_2(self):
        model = load_fmu(Test_FMUModelCS2.terminate)
        
        res = model.simulate()
        
        assert res.status == fmi.FMI_DISCARD
        assert abs(res["time"][-1] - 0.5) < 1e-3

    @testattr(fmi = True)
    def test_log_file_name(self):
        path, file_name = os.path.split(self.coupled_name)
        coupled = load_fmu(self.coupled_name)
        
        assert coupled.get_log_file_name() == file_name.replace(".","_")[:-4]+"_log.txt"
        
    @testattr(fmi = True)
    def test_part_log(self):
        model = load_fmu(self.coupled_name, log_level=6)
        
        model.set("_log_level", 6)
        
        model.simulate()
        
        num_lines = model.get_number_of_lines_log()
        assert num_lines > 50 #Assert big log
        
        log = model.get_log(start_lines=10)
        assert len(log) == 10
        log = model.get_log(end_lines=10)
        assert len(log) == 10
        log = model.get_log()
        assert len(log) == num_lines
        log = model.get_log(start_lines=10, end_lines=10)
        assert len(log) == 20
        log = model.get_log(start_lines=num_lines-10, end_lines=num_lines-10)
        assert len(log) == num_lines
    
    @testattr(windows = True)
    def test_init(self):
        """
        Test the method __init__ in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)

        assert bounce.get_identifier() == 'BouncingBall'
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=ME2, path=path_to_fmus_me2)
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=CS1, path=path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=ME1, path=path_to_fmus_me1)

    @testattr(fmi = True)
    def test_instantiate_slave(self):
        """
        Test the method instantiate_slave in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        bounce.reset() #Test multiple instantiation
        for i in range(0,10):
            name_of_slave = 'slave' + str(i)
            bounce.instantiate(name = name_of_slave)

    @testattr(fmi = True)
    def test_initialize(self):
        """
        Test the method initialize in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)

        for i in range(10):
            bounce.setup_experiment(tolerance= 10**-i)
            bounce.initialize()  #Initialize multiple times with different relTol
            bounce.reset()
            
        bounce.setup_experiment()
        bounce.initialize()    #Initialize with default options
        bounce.reset()

        bounce.setup_experiment(start_time=4.5)
        bounce.initialize()
        nose.tools.assert_almost_equal(bounce.time, 4.5)
    
    @testattr(fmi = True)
    def test_simulation_past_tstop(self):
        
        coupled = load_fmu(self.coupled_name)
        
        #Try to simulate past the defined stop
        coupled.setup_experiment(stop_time_defined=True, stop_time=1.0)
        coupled.initialize()
        
        step_size=0.1
        total_time=0
        for i in range(10):
            coupled.do_step(total_time, step_size)
            total_time += step_size
        status = coupled.do_step(total_time, step_size)
        assert status != 0

    @testattr(fmi = True)
    def test_reset_slave(self):
        """
        Test the method reset_slave in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        bounce.reset()
        
        bounce.setup_experiment()
        bounce.initialize()
        
    @testattr(fmi = True)
    def test_terminate(self):
        """
        Test the method terminate in FMUModelCS2
        """
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()
        coupled.terminate()

    @testattr(fmi = True)
    def test_the_time(self):
        """
        Test the time in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        assert bounce.time == 0.0
        bounce._set_time(4.5)
        assert bounce._get_time() == 4.5
        bounce.time = 3
        assert bounce.time == 3.0

        bounce.reset()
        bounce.setup_experiment(start_time=2.5)
        bounce.initialize()
        assert bounce.time == 2.5

    @testattr(fmi = True)
    def test_version(self):
        bounce = load_fmu(self.bouncing_name)
        assert bounce.get_version() == "2.0"
        
        coupled = load_fmu(self.coupled_name)
        assert coupled.get_version() == "2.0"

    @testattr(fmi = True)
    def test_do_step(self):
        """
        Test the method do_step in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()

        new_step_size = 1e-1
        for i in range(1,30):
            current_time = bounce.time
            status = bounce.do_step(current_time, new_step_size, True)
            assert status == 0
            nose.tools.assert_almost_equal(bounce.time , current_time + new_step_size)

        for i in range(10):
            current_time = coupled.time
            status = coupled.do_step(current_time, new_step_size, True)
            assert status == 0
            nose.tools.assert_almost_equal(coupled.time , current_time + new_step_size)

    @testattr(fmi = True)
    def test_set_input_derivatives(self):
        """
        Test the method set_input_derivatives in FMUModelCS2
        """
        #Do the setUp
        coupled = load_fmu(self.coupled_name)

        nose.tools.assert_raises(FMUException, coupled.set_input_derivatives, 'J1.phi', 1.0, 0) #this is nou an input-variable
        nose.tools.assert_raises(FMUException, coupled.set_input_derivatives, 'J1.phi', 1.0, 1)
        nose.tools.assert_raises(FMUException, coupled.set_input_derivatives, 578, 1.0, 1)

    @testattr(fmi = True)
    def test_get_output_derivatives(self):
        """
        Test the method get_output_derivatives in FMUModelCS2
        """
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()

        coupled.do_step(0.0, 0.02)
        nose.tools.assert_raises(FMUException, coupled.get_output_derivatives, 'J1.phi', 1)
        nose.tools.assert_raises(FMUException, coupled.get_output_derivatives, 'J1.phi', -1)
        nose.tools.assert_raises(FMUException, coupled.get_output_derivatives, 578, 0)

    @testattr(fmi = True)
    def test_get_directional_derivative_capability(self):
        """
        Test the method get_directional_derivative in FMUModelCS2
        """
        
        # Setup
        bounce = load_fmu(self.bouncing_name)
        bounce.setup_experiment()
        bounce.initialize()
        
        # Bouncing ball don't have the capability, check that this is handled
        nose.tools.assert_raises(FMUException, bounce.get_directional_derivative, [1], [1], [1])
        
    @testattr(fmi = True)
    def test_get_directional_derivative(self):
        """
        Test the method get_directional_derivative in FMUModelCS2
        """
        
        # Setup
        jacobian = load_fmu(self.jacobian_name)
        jacobian.setup_experiment()
        jacobian.initialize()
        
        jacobian.set('x1', 1.0)
        jacobian.set('x2', 1.0)
        
        states_list = jacobian.get_states_list()
        der_list    = jacobian.get_derivatives_list()
        states_ref  = [s.value_reference for s in states_list.values()]
        der_ref     = [s.value_reference for s in der_list.values()]

        dir_der1 = jacobian.get_directional_derivative(states_ref, der_ref, [1, 0])
        assert len(dir_der1) == 2
        nose.tools.assert_almost_equal(dir_der1[0], 1.)
        nose.tools.assert_almost_equal(dir_der1[1], 14.)
        
        dir_der2 = jacobian.get_directional_derivative(states_ref, der_ref, [0, 1])
        assert len(dir_der2) == 2
        nose.tools.assert_almost_equal(dir_der2[0], 16.)
        nose.tools.assert_almost_equal(dir_der2[1], 4.)

    @testattr(fmi = True)
    def test_simulate(self):
        """
        Test the main features of the method simulate() in FMUmodelCS2
        """
        #Set up for simulation
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)

        #Try simulate the bouncing ball
        res = bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        for i in range(5):
            res = bounce.simulate(start_time=0.1, final_time=1.0, options={'ncp':500})
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 6.0228998448008104, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()

        #Try to simulate the coupled-clutches
        res_coupled = coupled.simulate()
        sim_time_coupled = res_coupled['time']
        nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
        nose.tools.assert_almost_equal(sim_time_coupled[-1], 1.5)
        coupled.reset()


        for i in range(10):
            coupled = load_fmu(self.coupled_name)
            res_coupled = coupled.simulate(start_time=0.0, final_time=2.0)
            sim_time_coupled = res_coupled['time']
            nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
            nose.tools.assert_almost_equal(sim_time_coupled[-1],2.0)
            assert sim_time_coupled.all() >= sim_time_coupled[0] - 1e-4   #Check that the time is increasing
            assert sim_time_coupled.all() <= sim_time_coupled[-1] + 1e-4  #Give it some marginal

            #val_J1 = res_coupled['J1.w']
            #val_J2 = res_coupled['J2.w']
            #val_J3 = res_coupled['J3.w']
            #val_J4 = res_coupled['J4.w']

            val=[res_coupled.final('J1.w'), res_coupled.final('J2.w'), res_coupled.final('J3.w'), res_coupled.final('J4.w')]
            if i>0: #check that the results stays the same
                for j in range(len(val)):
                    nose.tools.assert_almost_equal(val[j], val_old[j])
            val_old = val
            coupled.reset()
        
        """
        #Compare to something we know is correct
        cs1_model = load_fmu('Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu',path_to_fmus_cs1)
        res1 = cs1_model.simulate(final_time=10, options={'result_file_name':'result1'})
        self._coupledCS2 = load_fmu(CoupledCS2, path_to_fmus_cs2)
        res2 = self._coupledCS2.simulate(final_time=10, options={'result_file_name':'result2'})
        diff1 = res1.final("J1.w") - res2.final("J1.w")
        diff2 = res1.final("J2.w") - res2.final("J2.w")
        diff3 = res1.final("J3.w") - res2.final("J3.w")
        diff4 = res1.final("J4.w") - res2.final("J4.w")
        nose.tools.assert_almost_equal(abs(diff1), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff2), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff3), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff4), 0.000, 1)
        """
        
    @testattr(windows = True)
    def test_simulate_extern(self):
        """
        Test the method simulate in FMUModelCS2 on FMU SDK bouncing ball
        """
        bounce  = load_fmu(fmu=CS2, path=path_to_fmus_cs2)

        #Try simulate the bouncing ball
        res = bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        for i in range(5):
            res = bounce.simulate(start_time=0.1, final_time=1.0, options={'ncp':500})
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 0.40479334288121899, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()

    @testattr(fmi = True)
    def test_simulate_options(self):
        """
        Test the method simultaion_options in FMUModelCS2
        """
        #Do the setUp
        coupled = load_fmu(self.coupled_name)

        #Test the result file
        res = coupled.simulate()
        assert res.result_file == coupled.get_identifier()+'_result.txt'
        assert os.path.exists(res.result_file)

        coupled.reset()
        opts = {'result_file_name':'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'}
        res = coupled.simulate(options=opts)
        assert res.result_file == 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'
        assert os.path.exists(res.result_file)

        #Test the option in the simulate method
        coupled.reset()
        opts={}
        opts['ncp'] = 250
        opts['initialize'] = False
        
        coupled.setup_experiment()
        coupled.initialize()
        res = coupled.simulate(options=opts)
        assert len(res['time']) == 251


class Test_State_Space_Repr:
    """
    This class tests pyfmi.fmi.FMUModelME2.get_state_space_representation
    """
    @classmethod
    def setUpClass(cls):
        cls.directional1 = compile_fmu("JacFuncTests.BasicJacobianTest",os.path.join(path_to_mofiles,"JacTest.mo"), target="me", version="2.0", compiler_options={'generate_ode_jacobian':True})
        cls.directional2 = compile_fmu("JacFuncTests.BasicJacobianTest2",os.path.join(path_to_mofiles,"JacTest.mo"), target="me", version="2.0", compiler_options={'generate_ode_jacobian':True})
        cls.cc           = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", target="me", version="2.0", compiler_options={'generate_ode_jacobian':True})
        cls.quadratic = compile_fmu("JacFuncTests.Quadratic",os.path.join(path_to_mofiles,"JacTest.mo"), target="me", version="2.0", compiler_options={'generate_ode_jacobian':True})
        
    def _run_test(self, name, matrix):
        model = load_fmu(name)
        model.setup_experiment()
        model.initialize()
        
        def get_matrix(matrix):
            if matrix == "A":
                M = model._get_A()
            elif matrix == "B":
                M = model._get_B()
            elif matrix == "C":
                M = model._get_C()
            elif matrix == "D":
                M = model._get_D()
            return M
        
        M1 = get_matrix(matrix)
        model.force_finite_differences = True
        M2 = get_matrix(matrix)
        
        print model.get_states_list()
        print model.get_input_list()
        print matrix, M1
        print matrix, M2
        
        M1 = M1.toarray().flatten()
        M2 = M2.toarray().flatten()
        
        for i in range(len(M1)):
            nose.tools.assert_almost_equal(M1[i], M2[i], places=4)
    
    @testattr(fmi = True)
    def test_sparse_dense_repr(self):
        model = load_fmu(self.cc)
        model.setup_experiment()
        model.initialize()
        
        A1,B1,C1,D1 = model.get_state_space_representation(A=True, B=False, C=False, D=False)
        A2,B2,C2,D2 = model.get_state_space_representation(A=True, B=False, C=False, D=False, use_structure_info=False)
        
        assert isinstance(A1, scipy.sparse.csc.csc_matrix)
        assert isinstance(A2, N.ndarray)
        
        model.force_finite_differences = 1
        A1,B1,C1,D1 = model.get_state_space_representation(A=True, B=False, C=False, D=False)
        A2,B2,C2,D2 = model.get_state_space_representation(A=True, B=False, C=False, D=False, use_structure_info=False)
        
        assert isinstance(A1, scipy.sparse.csc.csc_matrix)
        assert isinstance(A2, N.ndarray)
        
        model.force_finite_differences = 2
        A1,B1,C1,D1 = model.get_state_space_representation(A=True, B=False, C=False, D=False)
        A2,B2,C2,D2 = model.get_state_space_representation(A=True, B=False, C=False, D=False, use_structure_info=False)
        
        assert isinstance(A1, scipy.sparse.csc.csc_matrix)
        assert isinstance(A2, N.ndarray)
        
    @testattr(fmi = True)
    def test_finite_difference(self):
        model = load_fmu(self.quadratic)
        model.setup_experiment()
        model.initialize()
        
        model.force_finite_differences = 1 #Forward difference
        
        A1,B1,C1,D1 = model.get_state_space_representation(A=True, B=False, C=False, D=False)
        A2,B2,C2,D2 = model.get_state_space_representation(A=True, B=False, C=False, D=False, use_structure_info=False)
        
        nose.tools.assert_almost_equal(A1.todense()[0,0], 6)
        nose.tools.assert_almost_equal(A2[0,0], 6)
        
        model.force_finite_differences = 2 #Central difference
        
        A1,B1,C1,D1 = model.get_state_space_representation(A=True, B=False, C=False, D=False)
        A2,B2,C2,D2 = model.get_state_space_representation(A=True, B=False, C=False, D=False, use_structure_info=False)
        
        nose.tools.assert_almost_equal(A1.todense()[0,0], 6, places=8)
        nose.tools.assert_almost_equal(A2[0,0], 6, places=8)
        
        
    @testattr(fmi = True)
    def test_directional_without_initialize(self):
		model = load_fmu(self.directional1)
		
		nose.tools.assert_raises(FMUException, model._get_A)
		
		model.force_finite_differences = True
		
		nose.tools.assert_raises(FMUException, model._get_A)
    
    @testattr(fmi = True)
    def test_A_matrix1(self):
        pass
        #Should be actived after https://trac.jmodelica.org/ticket/4739
        #self._run_test(self.directional1, "A")
    
    @testattr(fmi = True)
    def test_A_matrix2(self):
        pass
        ##Should be actived after https://trac.jmodelica.org/ticket/4739
        #self._run_test(self.directional2, "A")
    
    @testattr(fmi = True)
    def test_B_matrix1(self):
        pass
        #self._run_test(self.directional1, "B")
    
    @testattr(fmi = True)
    def test_B_matrix2(self):
        self._run_test(self.directional2, "B")
    
    @testattr(fmi = True)
    def test_C_matrix1(self):
        pass
        #self._run_test(self.directional1, "C")
    
    @testattr(fmi = True)
    def test_C_matrix2(self):
        self._run_test(self.directional2, "C")
    
    @testattr(fmi = True)
    def test_D_matrix1(self):
        pass
        #self._run_test(self.directional1, "D")
    
    @testattr(fmi = True)
    def test_D_matrix2(self):
        self._run_test(self.directional2, "D")


class Test_FMUModelME2:
    """
    This class tests pyfmi.fmi.FMUModelME2
    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.coupled_name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", target="me", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.bouncing_name = compile_fmu("BouncingBall",os.path.join(path_to_mofiles,"BouncingBall.mo"), target="me", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.jacobian_name = compile_fmu("JacFuncTests.BasicJacobianTest",os.path.join(path_to_mofiles,"JacTest.mo"), target="me", version="2.0", compiler_options={'generate_ode_jacobian':True})
        cls.output2_name = compile_fmu("OutputTest2",os.path.join(path_to_mofiles,"OutputTest.mo"), target="me", version="2.0")
        cls.no_state_name = compile_fmu("NoState.Example1", os.path.join(path_to_mofiles,"noState.mo"), target="me", version="2.0")
        cls.enum_name = compile_fmu("Enumerations.Enumeration2", os.path.join(path_to_mofiles,"Enumerations.mo"), target="me", version="2.0")    
        cls.string1 = compile_fmu("StringModel1",os.path.join(path_to_mofiles,"TestString.mo"), target="me", version="2.0")
    
    @testattr(fmi = True)
    def test_get_string(self):
		model = load_fmu(self.string1)
		
		for i in range(100): #Test so that memory issues are detected
			assert model.get("str")[0] == "hej"
    
    @testattr(stddist = True)
    def test_get_enum(self):
        model = load_fmu(self.enum_name)
        
        assert model.get("one") == 1
        
        model.set("one", 2)
        assert model.get("one") == 2

    @testattr(windows = True)
    def test_malformed_xml(self):
        nose.tools.assert_raises(FMUException, load_fmu, os.path.join(path_to_fmus_me2, "MalFormed.fmu"))

    @testattr(fmi = True)
    def test_log_file_name(self):
        path, file_name = os.path.split(self.coupled_name)
        coupled = load_fmu(self.coupled_name)
        
        assert coupled.get_log_file_name() == file_name.replace(".","_")[:-4]+"_log.txt"
    
    @testattr(fmi = True)
    def test_version(self):
        bounce = load_fmu(self.bouncing_name)
        assert bounce.get_version() == "2.0"
        
        coupled = load_fmu(self.coupled_name)
        assert coupled.get_version() == "2.0"
        
    @testattr(fmi = True)
    def test_variable_initial(self):
        coupled = load_fmu(self.coupled_name)
        
        assert coupled.get_variable_initial("sin1.y") == fmi.FMI2_INITIAL_CALCULATED
        vars = coupled.get_model_variables()
        assert vars["sin1.y"].initial == fmi.FMI2_INITIAL_CALCULATED
        
    
    @testattr(windows = True)
    def test_init(self):
        """
        Test the method __init__ in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)

        assert bounce.get_identifier() == 'BouncingBall'
        nose.tools.assert_raises(FMUException, FMUModelME2, fmu=CS2, path=path_to_fmus_cs2)
        nose.tools.assert_raises(FMUException, FMUModelME2, fmu=CS1, path=path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, FMUModelME2, fmu=ME1, path=path_to_fmus_me1)

    @testattr(fmi = True)
    def test_instantiate_model(self):
        """
        Test the method instantiate_model in FMUModelME2
        """
        for i in range(5):
            bounce = load_fmu(self.bouncing_name)

    @testattr(fmi = True)
    def test_initialize(self):
        """
        Test the method initialize in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        nose.tools.assert_almost_equal(bounce.time, 0.0)

        bounce.reset()
        bounce.setup_experiment(tolerance=1e-7)
        bounce.initialize()

    @testattr(fmi = True)
    def test_reset(self):
        """
        Test the method reset in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)

        bounce.setup_experiment()
        bounce.initialize()

        bounce.reset()

        assert bounce.time is None

    @testattr(fmi = True)
    def test_terminate(self):
        """
        Test the method terminate in FMUModelME2
        """
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()
        coupled.terminate()

    @testattr(fmi = True)
    def test_time(self):
        """
        Test the method get/set_time in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)

        bounce.reset() #Currently results in a seg fault
        assert bounce.time is None
        
        bounce.setup_experiment()
        bounce.initialize()
        
        nose.tools.assert_almost_equal(bounce._get_time(), 0.0)
        bounce._set_time(2.71)
        nose.tools.assert_almost_equal(bounce.time , 2.71)
        bounce._set_time(1.00)
        nose.tools.assert_almost_equal(bounce._get_time() , 1.00)

        nose.tools.assert_raises(TypeError, bounce._set_time, '2.0')
        nose.tools.assert_raises(TypeError, bounce._set_time, N.array([1.0, 1.0]))

    @testattr(fmi = True)
    def test_get_event_info(self):
        """
        Test the method get_event_info in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        event = bounce.get_event_info()
        assert isinstance(event, PyEventInfo)

        assert event.newDiscreteStatesNeeded           == False
        assert event.nominalsOfContinuousStatesChanged == False
        assert event.valuesOfContinuousStatesChanged   == True
        assert event.terminateSimulation               == False
        assert event.nextEventTimeDefined              == False
        assert event.nextEventTime                     == 0.0

    @testattr(fmi = True)
    def test_get_event_indicators(self):
        """
        Test the method get_event_indicators in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled.setup_experiment()
        coupled.initialize()

        assert len(bounce.get_event_indicators()) == 1
        assert len(coupled.get_event_indicators()) == 33

        event_ind = bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],10.000000)
        bounce.continuous_states = N.array([5.]*2)
        event_ind = bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],5.000000)

    @testattr(fmi = True)
    def test_get_tolerances(self):
        """
        Test the method get_tolerances in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        [rtol,atol] = bounce.get_tolerances()

        assert rtol == 0.0001
        nose.tools.assert_almost_equal(atol[0],0.0000010)
        nose.tools.assert_almost_equal(atol[1],0.0000010)

    @testattr(fmi = True)
    def test_continuous_states(self):
        """
        Test the method get/set_continuous_states in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled.setup_experiment()
        coupled.initialize()

        nx = bounce.get_ode_sizes()[0]
        states = bounce._get_continuous_states()
        assert nx == len(states)

        nose.tools.assert_almost_equal(states[0],10.000000)
        nose.tools.assert_almost_equal(states[1],0.000000)

        bounce.continuous_states = N.array([2.,-3.])
        states = bounce.continuous_states

        nose.tools.assert_almost_equal(states[0],2.000000)
        nose.tools.assert_almost_equal(states[1],-3.000000)

        n_states=bounce._get_nominal_continuous_states()
        assert nx == len(n_states)
        nose.tools.assert_almost_equal(n_states[0], 1.000000)
        nose.tools.assert_almost_equal(n_states[1], 1.000000)


        nx = coupled.get_ode_sizes()[0]
        states = coupled._get_continuous_states()
        assert nx == len(states)
        coupled._set_continuous_states(N.array([5.]*nx))
        states = coupled.continuous_states
        nose.tools.assert_almost_equal(states[-1], 5.000000)

        n_states=coupled._get_nominal_continuous_states()
        nose.tools.assert_almost_equal(n_states[0], 0.0001)
        n_states=coupled.nominal_continuous_states
        nose.tools.assert_almost_equal(n_states[0], 0.0001)

    @testattr(fmi = True)
    def test_output_dependencies(self):
        model = load_fmu(self.output2_name)
        
        [state_dep, input_dep] = model.get_output_dependencies()
        
        assert state_dep["y1"][0] == "x1"
        assert state_dep["y1"][1] == "x2"
        assert state_dep["y2"][0] == "x2"
        assert state_dep["y3"][0] == "x1"
        assert input_dep["y1"][0] == "u1"
        assert input_dep["y3"][0] == "u1"
        assert len(input_dep["y2"]) == 0
        
    @testattr(fmi = True)
    def test_output_dependencies_2(self):
        model = load_fmu(self.coupled_name)
        
        [state_dep, input_dep] = model.get_output_dependencies()
        
        assert len(state_dep.keys()) == 0
        assert len(input_dep.keys()) == 0
        
    @testattr(fmi = True)
    def test_derivative_dependencies(self):
        model = load_fmu(self.no_state_name)
        
        [state_dep, input_dep] = model.get_derivatives_dependencies()
        
        assert len(state_dep.keys()) == 0
        assert len(input_dep.keys()) == 0

    @testattr(fmi = True)
    def test_get_derivatives(self):
        """
        Test the method get_derivatives in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled.setup_experiment()
        coupled.initialize()

        nx = bounce.get_ode_sizes()[0]
        der=bounce.get_derivatives()
        assert nx == len(der)

        nose.tools.assert_almost_equal(der[0], 0.000000)
        nose.tools.assert_almost_equal(der[1], -9.820000)

        bounce.continuous_states = N.array([5.0, 2.0])
        der=bounce.get_derivatives()
        nose.tools.assert_almost_equal(der[0], 2.000000)

        der_list = coupled.get_derivatives_list()
        der_ref  = N.array([s.value_reference for s in der_list.values()])
        der = coupled.get_derivatives()
        diff = N.sort(N.array([coupled.get_real(i) for i in der_ref]))-N.sort(der)
        nose.tools.assert_almost_equal(N.sum(diff), 0.)

    @testattr(fmi = True)
    def test_get_directional_derivative_capability(self):
        """
        Test the method get_directional_derivative in FMUModelME2
        """
        
        # Setup
        bounce = load_fmu(self.bouncing_name)
        bounce.setup_experiment()
        bounce.initialize()
        
        # Bouncing ball don't have the capability, check that this is handled
        nose.tools.assert_raises(FMUException, bounce.get_directional_derivative, [1], [1], [1])
        
    @testattr(fmi = True)
    def test_get_directional_derivative(self):
        """
        Test the method get_directional_derivative in FMUModelME2
        """
        
        # Setup
        jacobian = load_fmu(self.jacobian_name)
        jacobian.setup_experiment()
        jacobian.initialize()
        
        jacobian.set('x1', 1.0)
        jacobian.set('x2', 1.0)
        
        states_list = jacobian.get_states_list()
        der_list    = jacobian.get_derivatives_list()
        states_ref  = [s.value_reference for s in states_list.values()]
        der_ref     = [s.value_reference for s in der_list.values()]

        dir_der1 = jacobian.get_directional_derivative(states_ref, der_ref, [1, 0])
        assert len(dir_der1) == 2
        nose.tools.assert_almost_equal(dir_der1[0], 1.)
        nose.tools.assert_almost_equal(dir_der1[1], 14.)
        
        dir_der2 = jacobian.get_directional_derivative(states_ref, der_ref, [0, 1])
        assert len(dir_der2) == 2
        nose.tools.assert_almost_equal(dir_der2[0], 16.)
        nose.tools.assert_almost_equal(dir_der2[1], 4.)
        
    @testattr(fmi = True)
    def test_simulate_with_debug_option(self):
        coupled = load_fmu(self.coupled_name)

        opts=coupled.simulate_options()
        opts["logging"] = True
        
        #Verify that a simulation is successful
        res=coupled.simulate(options=opts)
        
    @testattr(fmi = True)
    def test_simulate_options(self):
        """
        Test the method simulate_options in FMUModelME2
        """
        coupled = load_fmu(self.coupled_name)

        opts=coupled.simulate_options()
        assert opts['initialize']
        assert not opts['with_jacobian']
        assert opts['ncp'] == 0

        #Test the result file
        res=coupled.simulate()
        assert res.result_file == coupled.get_identifier()+'_result.txt'
        assert os.path.exists(res.result_file)

        coupled.reset()
        opts = {'result_file_name':'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'}
        res=coupled.simulate(options=opts)
        assert res.result_file == 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'
        assert os.path.exists(res.result_file)

        #Test the option in the simulate method
        coupled.reset()
        opts={}
        opts['ncp'] = 250
        opts['initialize'] = False
        
        coupled.setup_experiment()
        coupled.initialize()
        coupled.event_update()
        coupled.enter_continuous_time_mode()
        res=coupled.simulate(options=opts)
        assert len(res['time']) > 250
    
    @testattr(fmi = True)
    def test_simulate_no_state(self):
        
        name = compile_fmu("Modelica.Blocks.Examples.IntegerNetwork1", version = 2.0, compiler_options={"generate_ode_jacobian":True, "eliminate_alias_constants":False})

        model = load_fmu(name)

        res = model.simulate(final_time=3)

        assert res.final("integerStep.y") == 3.0
    
    @testattr(fmi = True)
    def test_simulate(self):
        """
        Test the method simulate in FMUModelME2
        """
        bounce  = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)

        #Try simulate the bouncing ball
        res=bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-6
        opts["ncp"] = 500

        for i in range(5):
            res=bounce.simulate(start_time=0.1, final_time=1.0, options=opts)
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 6.0228998448008104, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()

        #Try to simulate the coupled-clutches
        res_coupled=coupled.simulate()
        sim_time_coupled = res_coupled['time']
        nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
        nose.tools.assert_almost_equal(sim_time_coupled[-1], 1.5)
        coupled.reset()


        for i in range(10):
            res_coupled = coupled.simulate(start_time=0.0, final_time=2.0)
            sim_time_coupled = res_coupled['time']
            nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
            nose.tools.assert_almost_equal(sim_time_coupled[-1],2.0)
            assert sim_time_coupled.all() >= sim_time_coupled[0] - 1e-4   #Check that the time is increasing
            assert sim_time_coupled.all() <= sim_time_coupled[-1] + 1e-4  #Give it some marginal

            #val_J1 = res_coupled['J1.w']
            #val_J2 = res_coupled['J2.w']
            #val_J3 = res_coupled['J3.w']
            #val_J4 = res_coupled['J4.w']

            val=[res_coupled.final('J1.w'), res_coupled.final('J2.w'), res_coupled.final('J3.w'), res_coupled.final('J4.w')]
            if i>0: #check that the results stays the same
                for j in range(len(val)):
                    nose.tools.assert_almost_equal(val[j], val_old[j])
            val_old = val
            coupled.reset()
        
        """
        #Compare to something we know is correct
        me1_model = load_fmu('Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu',path_to_fmus_me1)
        res1 = me1_model.simulate(final_time=2., options={'result_file_name':'result1'})
        coupled = load_fmu(CoupledME2, path_to_fmus_me2)
        res2 = coupled.simulate(final_time=2., options={'result_file_name':'result2'})
        diff1 = res1.final("J1.w") - res2.final("J1.w")
        diff2 = res1.final("J2.w") - res2.final("J2.w")
        diff3 = res1.final("J3.w") - res2.final("J3.w")
        diff4 = res1.final("J4.w") - res2.final("J4.w")
        nose.tools.assert_almost_equal(abs(diff1), 0.0000, 2)
        nose.tools.assert_almost_equal(abs(diff2), 0.0000, 2)
        nose.tools.assert_almost_equal(abs(diff3), 0.0000, 2)
        nose.tools.assert_almost_equal(abs(diff4), 0.0000, 2)
        """
        
    @testattr(windows = True)
    def test_simulate_extern(self):
        """
        Test the method simulate in FMUModelME2 on FMU SDK bouncing ball
        """
        bounce  = load_fmu(fmu=ME2, path=path_to_fmus_me2)

        #Try simulate the bouncing ball
        res = bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-6
        opts["ncp"] = 500

        for i in range(5):
            res=bounce.simulate(start_time=0.1, final_time=1.0, options=opts)
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 0.40400192742719998, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()


class Test_Result_Writing:
    """
    This test the result writing functionality.
    """
    @classmethod
    def setUpClass(cls):
        file_name = os.path.join(get_files_path(), 'Modelica', 'Friction.mo')
        cls.enum_name = compile_fmu("Friction2", file_name, target="me", version="2.0")
        
    @testattr(fmi = True)
    def test_enumeration_file(self):
        
        model = load_fmu(self.enum_name)
        data_type = model.get_variable_data_type("mode")
        
        assert data_type == fmi.FMI2_ENUMERATION
        
        opts = model.simulate_options()
        
        res = model.simulate(options=opts)
        res["mode"] #Check that the enumeration variable is in the dict, otherwise exception
        
    @testattr(fmi = True)
    def test_enumeration_memory(self):
        
        model = load_fmu(self.enum_name)
        data_type = model.get_variable_data_type("mode")
        
        assert data_type == fmi.FMI2_ENUMERATION
        
        opts = model.simulate_options()
        opts["result_handling"] = "memory"
        
        res = model.simulate(options=opts)
        res["mode"] #Check that the enumeration variable is in the dict, otherwise exception
        
    @testattr(fmi = True)
    def test_enumeration_csv(self):
        
        model = load_fmu(self.enum_name)
        data_type = model.get_variable_data_type("mode")
        
        assert data_type == fmi.FMI2_ENUMERATION
        
        from pyfmi.common.io import ResultHandlerCSV
        opts = model.simulate_options()
        opts["result_handling"] = "custom"
        opts["result_handler"] = ResultHandlerCSV(model)
        
        res = model.simulate(options=opts)
        res["mode"] #Check that the enumeration variable is in the dict, otherwise exception
        

class Test_load_fmu2:
    """
    This test the functionality of load_fmu method.
    """
    @testattr(windows = True)
    def test_raise_exception(self):
        """
        This method tests the error-handling of load_fmu
        """
        nose.tools.assert_raises(FMUException, load_fmu, 'not_an_fmu.txt', path_to_fmus)                      #loading non-fmu file
        nose.tools.assert_raises(FMUException, load_fmu, 'not_existing_file.fmu', path_to_fmus_me2)           #loading non-existing file
        #nose.tools.assert_raises(FMUException, load_fmu, 'not_a_.fmu', path_to_fmus)                          #loading a non-real fmu
        nose.tools.assert_raises(FMUException, load_fmu, fmu=ME2, path=path_to_fmus_me2, kind='invalid_kind') #loading fmu with wrong argument
        nose.tools.assert_raises(FMUException, load_fmu, fmu=ME1, path=path_to_fmus_me1, kind='CS')           #loading ME1-model as a CS-model
        nose.tools.assert_raises(FMUException, load_fmu, fmu=CS1, path=path_to_fmus_cs1, kind='ME')           #loading CS1-model as ME-model
        nose.tools.assert_raises(FMUException, load_fmu, fmu=ME2, path=path_to_fmus_me2, kind='CS')           #loading ME2-model as a CS-model
        nose.tools.assert_raises(FMUException, load_fmu, fmu=CS2, path=path_to_fmus_cs2, kind='ME')           #loading CS2-model as ME-model

    @testattr(windows = True)
    def test_correct_loading(self):
        """
        This method tests the correct loading of FMUs
        """
        model = load_fmu(fmu=ME2, path=path_to_fmus_me2, kind='auto') #loading ME2-model correct
        assert isinstance(model, FMUModelME2)
        model = load_fmu(fmu=ME2, path=path_to_fmus_me2, kind='me')   #loading ME2-model correct
        assert isinstance(model, FMUModelME2)
        model = load_fmu(fmu=CS2, path=path_to_fmus_cs2, kind='auto') #loading CS2-model correct
        assert isinstance(model, FMUModelCS2)
        model = load_fmu(fmu=CS2, path=path_to_fmus_cs2, kind='cs')   #loading CS2-model correct
        assert isinstance(model, FMUModelCS2)


