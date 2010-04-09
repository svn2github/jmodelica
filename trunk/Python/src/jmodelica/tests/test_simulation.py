from jmodelica.tests.base_simul import *
from jmodelica.tests import testattr
from jmodelica.compiler import OptimicaCompiler
import numpy as N


class TestNominal(SimulationTest):

    @classmethod
    def setUpClass(cls):
        oc = OptimicaCompiler()
        SimulationTest.setup_class_base(
                'NominalTest.mo', 'NominalTests.NominalTest1',compiler=oc,
                options={"enable_variable_scaling":True})

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(verbosity=3, start_time=0.0, final_time=10.0, time_step = 0.1)
        self.run()
        self.load_expected_data('NominalTests_NominalTest1_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'y', 'z', 'der(x)', 'der(y)'])


class TestFunction1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'FunctionAR.mo', 'FunctionAR.UnknownArray1')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(verbosity=3, start_time=0.0, final_time=1.0, time_step = 0.002, rel_tol=1.0e-2, abs_tol=1.0e-2)
        self.run()
        self.load_expected_data('UnknownArray.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        vars = ['x[%d]' % i for i in range(1, 4)]
        self.assert_all_trajectories(vars, same_span=True)


class TestFunction2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'FunctionAR.mo', 'FunctionAR.FuncRecord1')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(verbosity=3, start_time=0.0, final_time=1.0, time_step = 0.002, rel_tol=1.0e-2)
        self.run()
        self.load_expected_data('FuncRecord.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'r.a'], same_span=True)

