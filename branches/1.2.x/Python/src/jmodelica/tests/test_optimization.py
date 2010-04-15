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
        blocking_factors = N.array([5,10,5,3])
        self.setup_base(nlp_args = (n_e, hs, n_cp, blocking_factors), options = { 'max_iter': 500 })
        self.run()
        self.load_expected_data('BlockingTest_result.txt')

    @testattr(stddist = True)
    def test_cost_end(self):
        self.assert_end_value('cost', 8.1819533e-01)

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x[1]', 'x[2]', 'w1', 'w2', 'w3', 'w4'])

class TestElementInterpolationResult(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'DI_opt.mo', 'DI_opt')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 8
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 },
                        result_mesh='element_interpolation')
        self.run()
        self.load_expected_data('DI_opt_element_interpolation_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'v', 'w1', 'w2', 'u', 'cost'])

class TestMeshInterpolationResult(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'DI_opt.mo', 'DI_opt')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 8
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 },
                        result_mesh='mesh_interpolation',result_arguments={"mesh":N.linspace(-0.1,2.2,50)})
        self.run()
        self.load_expected_data('DI_opt_mesh_interpolation_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'v', 'w1', 'w2', 'u', 'cost'])

class TestIntegersNBooleanParameters(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'ArrayIntBoolPars_Opt.mo', 'ArrayIntBoolPars_Opt')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 })
        self.run()
        self.load_expected_data('ArrayIntBoolPars_Opt_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['B', 'N', 'x[1]'])

class TestNominal(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'NominalTest.mo', 'NominalTests.NominalOptTest2',
            options={"enable_variable_scaling":True})

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 })
        self.run()
        self.load_expected_data('NominalTests_NominalOptTest2_result.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'der(x)', 'u'])

    @testattr(stddist = True)
    def test_initialization_from_data(self):       
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        self.nlp.set_initial_from_dymola(self.expected,hs,0,1)
        self.nlp.export_result_dymola()
        self.data = ResultDymolaTextual("NominalTests_NominalOptTest2_result.txt")
        self.assert_all_trajectories(['x', 'der(x)', 'u'])


class TestFunction1(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'FunctionAR_opt.mo', 'FunctionAR.UnknownArray1')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 }, rel_tol=1.0e-2, abs_tol=1.0e-2)
        self.run()
        self.load_expected_data('UnknownArray.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        vars = ['x[%d]' % i for i in range(1, 4)]
        self.assert_all_trajectories(vars, same_span=True)
 

class TestFunction1(OptimizationTest):

    @classmethod
    def setUpClass(cls):
        OptimizationTest.setup_class_base(
            'FunctionAR_opt.mo', 'FunctionAR.FuncRecord1')

    @testattr(stddist = True)
    def setUp(self):
        n_e = 50
        hs = N.ones(n_e)*1./n_e
        n_cp = 3
        self.setup_base(nlp_args = (n_e, hs, n_cp), options = { 'max_iter': 500 }, rel_tol=1.0e-2)
        self.run()
        self.load_expected_data('FuncRecord.txt')

    @testattr(stddist = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'r.a'], same_span=True)
   
