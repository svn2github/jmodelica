from jmodelica.tests.base_simul import *
from jmodelica.tests import testattr
import numpy as N

class TestOptimization(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
                '../../examples/files/VDP.mo', 'VDP_pack.VDP_Opt', 
                options = { 'state_start_values_fixed': True })

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 })
        self.run()

    @testattr(stddist = True)
    def test_cost_end(self):
        self.assert_end_value('cost', 2.3469089e+01)


class TestIfExp(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
                'IfExpTest.mo', 'IfExpTest')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 })
        self.run()

    @testattr(stddist = True)
    def test_cost_end(self):
        self.assert_end_value('cost', 1.0590865e+00)

class TestFreeInitialConditions(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'FreeInitialConditions.mo', 'FreeInitialConditions')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 })
        self.run()

    @testattr(stddist = True)
    def test_cost_end(self):
        self.assert_end_value('cost', 1.9179767e+01)

class TestBlockingFactors(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'BlockingTest.mo', 'BlockingTest')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        blocking_factors=N.ones(50,dtype='int32')
        self.setup_base(nlp_args = (n_e, hs, n_cp, blocking_factors), options = { 'max_iter': 500 })
        self.run()
        self.load_expected_data('BlockingTest_result.txt')

    @testattr(stddist = True)
    def test_cost_end(self):
        self.assert_end_value('cost', 7.3297101e-01)

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x[1]', 'x[2]', 'w1', 'w2', 'w3', 'w4'])

