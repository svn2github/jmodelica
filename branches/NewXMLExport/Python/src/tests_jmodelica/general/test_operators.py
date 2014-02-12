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

class TestHomotopy(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.HomotopyTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=0.5, time_step=0.01)
        self.run()

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_end_value('x', 0.5)

class TestSemiLinear(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.SemiLinearTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_SemiLinearTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestDiv(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.DivTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_DivTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestMod(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.ModTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_ModTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestRem(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.RemTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_RemTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestCeil(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.CeilTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_CeilTest_result.txt')

    @testattr(stddist = True)
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

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_FloorTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestInteger(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.IntegerTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_IntegerTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestNested(SimulationTest):
    """
    Tests nested event generating builtins.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.NestedTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_NestedTest_result.txt')

    @testattr(stddist = True)
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

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.1)
        self.run()

    @testattr(stddist = True)
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

class TestEdge(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.EdgeTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_EdgeTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x','y'])

class TestChange(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.ChangeTest')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_ChangeTest_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x','y'])

class TestReinitME(SimulationTest):
    """
    Basic test of reinit() for ME.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('BouncingBall.mo', 'BouncingBall', target="me")

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, time_step=0.02)
        self.run()
        self.load_expected_data('BouncingBall_result_ME.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['h','v'])
        
class TestReinitCS(SimulationTest):
    """
    Basic test of reinit() for CS.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('BouncingBall.mo', 'BouncingBall', target="cs")

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, time_step=0.02)
        self.run()
        self.load_expected_data('BouncingBall_result_CS.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['h','v'])

class TestStringExpConstant(SimulationTest):
    """
    Basic test of Modelica string operator.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.StringExpConstant')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base()
        self.run()

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        # Tested with asserts in model

class TestStringExpParameter(SimulationTest):
    """
    Basic test of Modelica string operator.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.StringExpParameter')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base()
        self.run()

    @testattr(stddist = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        # Tested with asserts in model
