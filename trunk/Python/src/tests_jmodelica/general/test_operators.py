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

from tests_jmodelica.general.base_simul import *
from tests_jmodelica import testattr

class TestInteger(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.IntegerTest')

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.01})
        self.load_expected_data('OperatorTests_IntegerTest_result.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestFloor(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.FloorTest')

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.01})
        self.load_expected_data('OperatorTests_FloorTest_result.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestNested(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.NestedTest')

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.01})
        self.load_expected_data('OperatorTests_NestedTest_result.txt')

    @testattr(assimulo = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestSign(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.SignTest')

    @testattr(assimulo = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()

    @testattr(assimulo = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_end_value('x[1,1]', -1.0)
        self.assert_end_value('x[1,2]', 1.0)
        self.assert_end_value('x[2,1]', 1.0)
        self.assert_end_value('x[2,2]', -1.0)
        self.assert_end_value('y', -1.0)
        self.assert_end_value('z', 0)

