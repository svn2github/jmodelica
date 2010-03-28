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
