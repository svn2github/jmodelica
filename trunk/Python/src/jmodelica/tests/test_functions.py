from jmodelica.tests.base_simul import *
from jmodelica.tests import testattr

class TestFunctionTest1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('FunctionTests.mo', 'FunctionTests.FunctionTest1')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(verbosity=3, start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('FunctionTest1+2_res.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['pi', 'tau', 'gpi', 'gtau'])

    @testattr(stddist = True)
    def test_ends(self):
        self.assert_all_end_values(['pi', 'tau', 'gpi', 'gtau'])

class TestFunctionTest2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('FunctionTests.mo', 'FunctionTests.FunctionTest2')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(verbosity=3, start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('FunctionTest1+2_res.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['pi', 'tau', 'gpi', 'gtau'])

    @testattr(stddist = True)
    def test_ends(self):
        self.assert_all_end_values(['pi', 'tau', 'gpi', 'gtau'])
