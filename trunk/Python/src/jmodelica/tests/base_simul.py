"""JModelica test package.

This base.py file holds base classes for simulation and optimization tests.
"""

import os
import numpy

import jmodelica.jmi as jmi
import jmodelica.initialization.ipopt as ipopt_init
from jmodelica.optimization import ipopt
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
from jmodelica.simulation.sundials import SundialsDAESimulator
from jmodelica.io import ResultDymolaTextual


_jm_home = os.environ.get('JMODELICA_HOME')
_tests_path = os.path.join(_jm_home, "Python", "jmodelica", "tests")
_model_name = ''

class _BaseSimOptTest:
    """
    Base class for simulation and optimization tests.
    Actual test classes should inherit SimulationTest or OptimizationTest.
    """

    @classmethod
    def setup_class_base(cls, mo_file, class_name, compiler, options = {}):
        """
        Set up a new test model. Compiles the model. 
        Call this with proper args from setUpClass(). 
          mo_file     - the relative path from the files dir to the .mo file to compile
          class_name  - the qualified name of the class to simulate
          options     - a dict of options to set in the compiler, defaults to no options
          compiler    - the compiler to use
        """
	global _model_name, _tests_path
	_model_name = class_name.replace('.','_')
	path = os.path.join(_tests_path, 'files', mo_file)
        _set_compiler_options(compiler, options)
	compiler.compile_model(path, class_name, target='ipopt')


    def setup_base(self, tolerance):
        """ 
        Set up a new test case. Configures test and creates model.
        Call this with proper args from setUp(). 
	  tolerance -  the relative error tolerance when comparing values, default is 1.0e-3
	Any other named args are passed to the NLP constructor.
        """
	global _model_name
	self.tolerance = tolerance
	self.model_name = _model_name
	self.model = jmi.Model(self.model_name);


    def run(self):
        """
        Run simulation and load result. 
        Call this from setUp() or within a test depending if all tests should run simulation.
        """
        self._run_and_write_data()
	self.data = ResultDymolaTextual(self.model_name + '_result.txt')


    def load_expected_data(self, name):
        """
        Load the expected data to use for assert_all_paths() and assert_all_end_values().
          name -  the file name of the results file, relative to files dir
        """
	path = os.path.join(_tests_path, 'files', name)
        self.expected = ResultDymolaTextual(path)


    def assert_all_inital_values(self, variables, tolerance = None):
        """
        Assert that all given variables match expected intial values loaded by a call to 
        load_expected_data().
          variables -  list of the names of the variables to test
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
        self._assert_all_spec_values(variables, 0, tolerance)


    def assert_all_end_values(self, variables, tolerance = None):
        """
        Assert that all given variables match expected end values loaded by a call to 
        load_expected_data().
          variables -  list of the names of the variables to test
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
        self._assert_all_spec_values(variables, -1, tolerance)


    def assert_all_trajectories(self, variables, same_span = True, tolerance = None):
        """
        Assert that the trajectories of all given variables match expected trajectories 
        loaded by a call to load_expected_data().
          variables -  list of the names of the variables to test
          same_span -  if True, require that the paths span the same time interval
                       if False, only compare overlapping part, default True
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
        for var in variables:
            expected = self.expected.get_variable_data(var)
            self.assert_trajectory(var, expected, same_span, tolerance)


    def assert_initial_value(self, variable, value, tolerance = None):
        """
        Assert that the inital value for a simulation variable matches expected value. 
          variable  -  the name of the variable
          value     -  the expected value
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
        self._assert_value(variable, value, 0, tolerance)


    def assert_end_value(self, variable, value, tolerance = None):
        """
        Assert that the end result for a simulation variable matches expected value. 
          variable  -  the name of the variable
          value     -  the expected value
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
        self._assert_value(variable, value, -1, tolerance)

    
    def assert_trajectory(self, variable, expected, same_span = True, tolerance = None):
        """
        Assert that the trajectory of a simulation variable matches expected trajectory. 
          variable  -  the name of the variable
          expected  -  the expected trajectory
          same_span -  if True, require that the paths span the same time interval
                       if False, only compare overlapping part, default True
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
	if tolerance is None:
	    tolerance = self.tolerance
	ans = expected
	res = self.data.get_variable_data(variable)

	if same_span:
	    assert _rel_error(ans.t[0], res.t[0]) < tolerance
	    assert _rel_error(ans.t[-1], res.t[-1]) < tolerance

        # Merge the time lists
        time = list(set(ans.t) | set(res.t))

        # Get overlapping span
        (t1, t2) = (max(ans.t[0], res.t[0]), min(ans.t[-1], res.t[-1]))

        # Remove values outside overlap
        time = filter((lambda t: t >= t1 and t <= t2), time)

        # Calc the relative error for each time point
        rel_error = [_eval_and_calc_rel_error(ans, res, t) for t in time]
	assert max(rel_error) < tolerance


    def _assert_all_spec_values(self, variables, index, tolerance = None):
        """
        Assert that all given variables match expected values loaded by a call to 
        load_expected_data(), for a given index in the value arrays.
          variables -  list of the names of the variables to test
          index     -  the index in the array holding the values, 0 is initial, -1 is end
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
        for var in variables:
            value = self.expected.get_variable_data(var).x[index]
            self._assert_value(var, value, index, tolerance)


    def _assert_value(self, variable, value, index, tolerance = None):
        """
        Assert that a specific value for a simulation variable matches expected value. 
          variable  -  the name of the variable
          value     -  the expected value
          index     -  the index in the array holding the values, 0 is initial, -1 is end
          tolerance -  the relative error tolerance, defaults to the value set with setup_base()
        """
	if tolerance is None:
	    tolerance = self.tolerance
	res = self.data.get_variable_data(variable)
	assert _rel_error(value, res.x[index]) <= tolerance



class SimulationTest(_BaseSimOptTest):
    """
    Base class for simulation tests.
    """

    @classmethod
    def setup_class_base(cls, mo_file, class_name, options = {}, compiler = None):
        """
        Set up a new test model. Compiles the model. 
        Call this with proper args from setUpClass(). 
          mo_file     - the relative path from the files dir to the .mo file to compile
          class_name  - the qualified name of the class to simulate
          options     - a dict of options to set in the compiler, defaults to no options
          compiler    - the compiler to use, defaults to an instance of ModelicaCompiler
        """
        if compiler is None:
            compiler = ModelicaCompiler()
        _BaseSimOptTest.setup_class_base(mo_file, class_name, compiler, options)


    def setup_base(self, tolerance = 1.0e-4, **args):
        """ 
        Set up a new test case. Creates and configures the simulation.
        Call this with proper args from setUp(). 
	  tolerance -  the relative error tolerance when comparing values, default is 1.0e-4
	Any other named args are passed to sundials.
        """
        _BaseSimOptTest.setup_base(self, tolerance)
	ipopt_nlp = ipopt_init.NLPInitialization(self.model)
        ipopt_opt = ipopt_init.InitializationOptimizer(ipopt_nlp)
        ipopt_opt.init_opt_ipopt_solve()
	self.sundials = SundialsDAESimulator(self.model, **args)


    def _run_and_write_data(self):
        """
        Run optimization and write result to file.
        """
	self.sundials.run()
	self.sundials.write_data()


class OptimizationTest(_BaseSimOptTest):
    """
    Base class for optimization tests.
    """

    @classmethod
    def setup_class_base(cls, mo_file, class_name, options = {}, compiler = None):
        """
        Set up a new test model. Compiles the model. 
        Call this with proper args from setUpClass(). 
          mo_file     - the relative path from the files dir to the .mo file to compile
          class_name  - the qualified name of the class to simulate
          options     - a dict of options to set in the compiler, defaults to no options
          compiler    - the compiler to use, defaults to a new instance of OptimicaCompiler
        """
        if compiler is None:
            compiler = OptimicaCompiler()
        _BaseSimOptTest.setup_class_base(mo_file, class_name, compiler, options)


    def setup_base(self, nlp_args = (), tolerance = 1.0e-4, options = {}, result_mesh='default', n_interpolation_points=20):
        """ 
        Set up a new test case. Creates and configures the optimization.
        Call this with proper args from setUp(). 
          nlp_args  -  arguments to pass to the NLP constructor besides the model
	  tolerance -  the relative error tolerance when comparing values, default is 1.0e-4
          options   -  a dict of options to set in the optimizer, defaults to no options
        """
        _BaseSimOptTest.setup_base(self, tolerance)
	self.nlp = ipopt.NLPCollocationLagrangePolynomials(self.model, *nlp_args)
        self.ipopt = ipopt.CollocationOptimizer(self.nlp)
        self._result_mesh = result_mesh
        self._n_interpolation_points = n_interpolation_points
        _set_ipopt_options(self.ipopt, options)


    def _run_and_write_data(self):
        """
        Run optimization and write result to file.
        """
        self.ipopt.opt_sim_ipopt_solve()
        if self._result_mesh=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(self._n_interpolation_points)
        else:
            self.nlp.export_result_dymola()



# =========== Helper functions =============

def _set_ipopt_options(nlp, opts):
    """
    Set all options contained in dict opts in Ipopt NLP object nlp.
    Selects method to use from the type of each value.
    """
    for k, v in opts.iteritems():
        if isinstance(v, int):
            nlp.opt_sim_ipopt_set_int_option(k, v)
        elif isinstance(v, float):
            nlp.opt_sim_ipopt_set_num_option(k, v)
        elif isinstance(v, str):
            nlp.opt_sim_ipopt_set_string_option(k, v)


def _set_compiler_options(cmp, opts):
    """
    Set all options contained in dict opts in compiler cmp.
    Selects method to use from the type of each value.
    """
    for k, v in opts.iteritems():
        if isinstance(v, bool):
            cmp.set_boolean_option(k, v)
        elif isinstance(v, int):
            cmp.set_integer_option(k, v)
        elif isinstance(v, float):
            cmp.set_real_option(k, v)
        elif isinstance(v, str):
            cmp.set_string_option(k, v)


def _rel_error(v1, v2):
    """
    Calculates the relative error between two values.
    """
    if v1 == v2:
        return 0.0
    return abs(v1 - v2) / max(abs(v1), abs(v2))

def _eval_and_calc_rel_error(ans, res, t):
    """
    Evaluate both ans and res at time t and calculate the relative error.
    """
    return _rel_error(_trajectory_eval(ans, t), _trajectory_eval(res, t))


def _trajectory_eval(var, t):
    """
    Given the variable var, evaluate the variable for the time t.
    Values in var.t must be in increasing order, and t must be within the span of var.t.
    """
    (pt, px) = (var.t[0], var.x[0])
    for (ct, cx) in zip(var.t, var.x):
        # Since the t values are copies of the ones in the trajectories, we can use equality
        if ct == t:
            return cx
        elif ct > t:
            # pt < t < ct - use linear interpolation
            return ((t - pt) * cx + (ct - t) * px) / (ct - pt)
        (pt, px) = (ct, cx)
