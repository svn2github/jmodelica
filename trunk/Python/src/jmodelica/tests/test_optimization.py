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

