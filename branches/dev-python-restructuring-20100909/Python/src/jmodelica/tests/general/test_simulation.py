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
Module for testing Simulation.
"""
from jmodelica.tests.general.base_simul import *
from jmodelica.tests import testattr
from jmodelica.compiler import OptimicaCompiler
import numpy as N


class TestNominal(SimulationTest):

    @classmethod
    def setUpClass(cls):
        oc = OptimicaCompiler()
        SimulationTest.setup_class_base(
                'NominalTest.mop', 'NominalTests.NominalTest1',compiler=oc,
                options={"enable_variable_scaling":True})

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, time_step = 0.1, abs_tol=1.0e-8)
        self.run()
        self.load_expected_data('NominalTests_NominalTest1_result.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'y', 'z', 'der(x)', 'der(y)'])


class TestFunction1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'FunctionAR.mo', 'FunctionAR.UnknownArray1')

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.002, rel_tol=1.0e-2, abs_tol=1.0e-2)
        self.run()
        self.load_expected_data('UnknownArray.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        vars = ['x[%d]' % i for i in range(1, 4)]
        self.assert_all_trajectories(vars, same_span=True)


class TestFunction2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'FunctionAR.mo', 'FunctionAR.FuncRecord1')

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.002, rel_tol=1.0e-2)
        self.run()
        self.load_expected_data('FuncRecord.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'r.a'], same_span=True)


class TestStreams1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'StreamExample.mo', 'StreamExample.Examples.Systems.HeatedGas_SimpleWrap',options={'enable_variable_scaling':True})

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.1,)
        self.run()
        self.load_expected_data('StreamExample_Examples_Systems_HeatedGas_SimpleWrap_result.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['linearResistanceWrap.port_a.m_flow',
                                      'linearResistanceWrap.linearResistance.port_a.p',
                                      'linearResistanceWrap.linearResistance.port_a.h_outflow',
                                      ], same_span=True, rel_tol=1e-2, abs_tol=1e-2)

class TestStreams2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'StreamExample.mo', 'StreamExample.Examples.Systems.HeatedGas',options={'enable_variable_scaling':True})

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.1,)
        self.run()
        self.load_expected_data('StreamExample_Examples_Systems_HeatedGas_result.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['linearResistance.port_a.m_flow',
                                      'multiPortVolume.flowPort[1].h_outflow'
                                      ], same_span=True, rel_tol=1e-2, abs_tol=1e-2)
