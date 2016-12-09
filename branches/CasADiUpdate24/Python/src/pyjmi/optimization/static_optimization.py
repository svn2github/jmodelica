#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2016 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Module containing the classes for CasADi-based static optimization.
"""

import struct
import logging
import codecs
import operator
import itertools
import time
import copy
import types
import math
import os
from os import system, path
from operator import sub
from collections import OrderedDict, Iterable
from scipy.sparse import csc_matrix, csr_matrix

try:
    import casadi
    import casadi.tools as ct
except ImportError:
    logging.warning('Could not find CasADi package, aborting.')
import numpy as N

from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError
from pyjmi.casadi_interface import convert_casadi_der_name

#Check to see if pyfmi is installed so that we also catch the error generated
#from that package
from pymodelica.common.io import VariableNotFoundError as \
     pymodelicaVariableNotFoundError
try:
    from pyfmi.common.io import VariableNotFoundError as \
         fmiVariableNotFoundError
    VariableNotFoundError = (
        jmiVariableNotFoundError, pymodelicaVariableNotFoundError,
        fmiVariableNotFoundError)
except ImportError:
    VariableNotFoundError = (jmiVariableNotFoundError,
                             pymodelicaVariableNotFoundError)

from pyjmi.common.algorithm_drivers import JMResultBase as JMResultBaseJMI
from pyfmi.common.algorithm_drivers import JMResultBase as JMResultBaseFMI
JMResultBaseAll = (JMResultBaseJMI, JMResultBaseFMI)
from pyjmi.common.io import ResultDymolaTextual

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

class StaticOptimizerException(Exception):
    """
    A StaticOptimizer Exception.
    """
    pass

class StaticExternalData(object):

    """
    External data connected to variables.
    """

    def __init__(self, eliminated=OrderedDict(), quad_pen=OrderedDict(),
                 constr_quad_pen=OrderedDict(), Q=None):
        """
        The data can for each variable be treated in the following ways.

        eliminated --
            The data for these inputs is used to eliminate the corresponding NLP variables.

        quad_pen --
            The NLP variables are kept, but a quadratic penalty on the deviation from the data is introduced.

        eliminated must be inputs, whereas quad_pen can be any kind of variable.

        The data for each variable is either a scalar or a vector. If a vector of length n is used, n instances of the DAE
        will be created in the NLP. All vectors must have the same length n. This is particularly useful for parameter
        estimation with multiple experiments.

        Parameters::

            eliminated --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to eliminate the inputs.

                Type: OrderedDict, with vectors as values
                Default: OrderedDict()

            quad_pen --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to penalize the inputs.

                Type: OrderedDict, with vectors as values
                Default: OrderedDict()

            Q --
                Weighting matrix used to form the quadratic penalty for the
                uneliminated variables. The order of the variables is the same
                as the ordered dictionaries quad_pen.

                Type: List of rank 2 ndarrays
                Default: None
        """
        # Check dimension of data for each variable
        variable_lists = [eliminated, quad_pen]
        for variable_list in variable_lists:
            if len(variable_list) > 0:
                n_name = variable_list.keys()[0]
                if N.iterable(variable_list[n_name]):
                    n = len(variable_list[n_name])
                else:
                    for (key, val) in variable_list.iteritems():
                        variable_list[key] = [val]
                    n = 1
        for variable_list in variable_lists:
            for (key, val) in variable_list.iteritems():
                if len(val) != n:
                    raise ValueError('Variable %s has data of dimension %d but %s has of dimension %d.' %
                                     (n_name, n, key, val))
        if not isinstance(Q, list):
            if n > 1:
                raise ValueError('One Q is needed for each data point.')
            else:
                Q = [Q]

        # Store data as attributes
        self.eliminated = eliminated
        self.quad_pen = quad_pen
        self.Q = Q
        self.n = n

class StaticOptimizer(object):

    """Solves a static optimization problem."""

    def __init__(self, op, options):
        # Get the options
        self.__dict__.update(options)
        self.options = options # save the options for the result object
        self.times = {}
        t0_init = time.clock()

        # Store OptimizationProblem object
        self.op = op

        # Evaluate dependent parameters
        op.calculateValuesForDependentParameters()

        # Check if minimum time normalization has occured
        t0 = op.getVariable('startTime')
        tf = op.getVariable('finalTime')
        if op.get_attr(t0, "free"):
            self.t0 = t0.getVar()
        else:
            self.t0 = op.get_attr(t0, "_value")

        # Get to work
        self._create_nlp()
        self.times['init'] = time.clock() - t0_init 
        
    def solve_and_write_result(self):
        """
        Solve the nonlinear program and write the results to a file.
        """
        t0 = time.clock()
        self.times['sol'] = self.solve()
        self.result_file_name = self.export_result_dymola(self.result_file_name)
        self.times['post_processing'] = time.clock() - t0 - self.times['sol']

    def get_result_object(self, include_init=True):
        """ 
        Load result data saved in e.g. solve_and_write_result and create a StaticOptimizationAlgResult object.

        Returns::

            The StaticOptimizationAlgResult object.
        """
        t0 = time.clock()
        resultfile = self.result_file_name
        res = ResultDymolaTextual(resultfile)
    
        self.times['post_processing'] += time.clock() - t0
        self.times['tot'] = self.times['sol'] + self.times['post_processing']
        
        if include_init:
            self.times['tot'] += self.times['init']
            
        # Create and return result object
        return StaticOptimizationAlgResult(self.op, resultfile, self, res, self.options, self.times)

    def _create_nlp(self):
        """
        Wrapper for creating the NLP.
        """
        self._create_model_variable_structures()
        self._create_nlp_variables()
        self._compute_external_inputs()
        self._create_constraints_and_cost()
        self._compute_bounds_and_init()
        self._scale_nlp()
        self._create_solver_object()

    def _create_model_variable_structures(self):
        """
        Create model variable structures.

        Create vectorized model variables unless named_vars is enabled.
        """
        # Get model variable vectors
        op = self.op
        var_kinds = {'dx': op.DERIVATIVE,
                     'x': op.DIFFERENTIATED,
                     'y': op.REAL_ALGEBRAIC,
                     'u': op.REAL_INPUT}
        mvar_vectors = {'dx': N.array([var for var in
                                       op.getVariables(var_kinds['dx'])
                                       if (not var.isAlias() and not var.wasEliminated())]),
                        'x': N.array([var for var in
                                      op.getVariables(var_kinds['x'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'y': N.array([var for var in
                                      op.getVariables(var_kinds['y'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'u': N.array([var for var in
                                      op.getVariables(var_kinds['u'])
                                      if (not var.isAlias() and not var.wasEliminated())])}

        # Count variables (uneliminated inputs and free parameters are counted
        # later)
        n_var = {'dx': len(mvar_vectors["dx"]),
                 'x': len(mvar_vectors["x"]),
                 'y': len(mvar_vectors["y"]),
                 'u': len(mvar_vectors["u"])}

        # Exchange alias variables in external data
        if self.external_data is not None:
            eliminated = self.external_data.eliminated
            quad_pen = self.external_data.quad_pen
            Q = self.external_data.Q
            variable_lists = [eliminated, quad_pen]
            new_eliminated = OrderedDict()
            new_quad_pen = OrderedDict()
            new_variable_lists = [new_eliminated, new_quad_pen]
            for i in xrange(2):
                for name in variable_lists[i].keys():
                    var = op.getVariable(name)
                    if var is None:
                        raise StaticOptimizerException(
                            "Measured variable %s not " % name +
                            "found in model.")
                    if var.isAlias():
                        new_name = var.getModelVariable().getName()
                    else:
                        new_name = name
                    new_variable_lists[i][new_name] = variable_lists[i][name]
            self.external_data.eliminated = new_eliminated
            self.external_data.quad_pen = new_quad_pen

        # Create eliminated and uneliminated input lists
        if (self.external_data is None or
            len(self.external_data.eliminated) == 0):
            elim_input_indices = []
        else:
            input_names = [u.getName() for u in mvar_vectors['u']]
            elim_names = self.external_data.eliminated.keys()
            elim_vars = [op.getModelVariable(elim_name)
                         for elim_name in elim_names]
            for (i, elim_var) in enumerate(elim_vars):
                if elim_var is None:
                    raise CasadiCollocatorException(
                        "Eliminated input %s is " % elim_names[i] +
                        "not a model variable.")
                if elim_var.getCausality() != elim_var.INPUT:
                    raise CasadiCollocatorException(
                        "Eliminated input %s is " % elim_var.getName() +
                        "not a model input.")
            elim_var_names = [elim_var.getName() for elim_var in elim_vars]
            elim_input_indices = [input_names.index(u) for u in elim_var_names]
        unelim_input_indices = [i for i in range(n_var['u']) if
                                i not in elim_input_indices]
        self._unelim_input_indices = unelim_input_indices
        self._elim_input_indices = elim_input_indices
        mvar_vectors["unelim_u"] = mvar_vectors['u'][unelim_input_indices]
        mvar_vectors["elim_u"] = mvar_vectors['u'][elim_input_indices]
        n_var['unelim_u'] = len(unelim_input_indices)
        n_var['elim_u'] = len(elim_input_indices)

        # Create lists of and count other external data variables
        if self.external_data is not None:
            for (vk, source) in (('quad_pen', self.external_data.quad_pen),):
                mvar_vectors[vk] = [op.getVariable(name) for (name, data) in source.iteritems()]
                n_var[vk] = len(mvar_vectors[vk])
        else:
            n_var['quad_pen'] = 0

        # Create name map for external data
        if self.external_data is not None:
            self.external_data_name_map = {}
            for (vk, source) in (('elim_u', self.external_data.eliminated), 
                                 ('quad_pen', self.external_data.quad_pen)):
                for (j, name) in enumerate(source.iterkeys()):
                    self.external_data_name_map[name] = (j, vk)

        # Sort parameters
        par_kinds = [op.BOOLEAN_CONSTANT,
                     op.BOOLEAN_PARAMETER_DEPENDENT,
                     op.BOOLEAN_PARAMETER_INDEPENDENT,
                     op.INTEGER_CONSTANT,
                     op.INTEGER_PARAMETER_DEPENDENT,
                     op.INTEGER_PARAMETER_INDEPENDENT,
                     op.REAL_CONSTANT,
                     op.REAL_PARAMETER_INDEPENDENT,
                     op.REAL_PARAMETER_DEPENDENT]
        pars = reduce(list.__add__, [list(op.getVariables(par_kind)) for
                                     par_kind in par_kinds])
        mvar_vectors['p_fixed'] = [par for par in pars
                                   if not op.get_attr(par, "free")]
        n_var['p_fixed'] = len(mvar_vectors['p_fixed'])
        mvar_vectors['p_opt'] = [par for par in pars
                                 if op.get_attr(par, "free")]
        n_var['p_opt'] = len(mvar_vectors['p_opt'])

        # Create named symbolic variable structure
        named_mvar_struct = OrderedDict()
        named_mvar_struct["t"] = [op.getTimeVariable()]
        named_mvar_struct["dx"] = [mvar.getVar() for mvar in mvar_vectors['dx']]
        named_mvar_struct["x"] = [mvar.getVar() for mvar in mvar_vectors['x']]
        named_mvar_struct["y"] = [mvar.getVar() for mvar in mvar_vectors['y']]
        named_mvar_struct["unelim_u"] = \
            [mvar.getVar() for mvar in
             mvar_vectors['u'][unelim_input_indices]]
        named_mvar_struct["elim_u"] = \
            [mvar.getVar() for mvar in
             mvar_vectors['u'][elim_input_indices]]
        named_mvar_struct["p_opt"] = [mvar.getVar() for
                                      mvar in mvar_vectors['p_opt']]
        named_mvar_struct["p_fixed"] = [mvar.getVar() for
                                        mvar in mvar_vectors['p_fixed']]    
        
        # Get optimization and model expressions
        initial = op.getInitialResidual()
        dae = op.getDaeResidual()
        path_e = []
        path_i = []
        for pc in op.getPathConstraints():
            pc_type = pc.getType()
            if pc_type == pc.EQ:
                path_e.append(pc.getResidual())
            elif pc_type == pc.LEQ:
                path_i.append(pc.getResidual())
            elif pc_type == pc.GEQ:
                path_i.append(-pc.getResidual())
            else:
                raise StaticOptimizerException("Unknown path constraint type %d." % pc_type)
        path_e = casadi.vertcat(path_e)
        path_i = casadi.vertcat(path_i)
        objective = op.getObjectiveIntegrand()

        # Check invalid constructs
        if len(op.getPointConstraints()) > 0:
            if self.verbosity >= 1:
                print("Warning: Point constraints are ignored in static optimization.")
        if not op.getObjective().isZero():
            raise StaticOptimizerException('Optimica objective is not supported. Use objectiveIntegrand instead.')

        # Append name of variables into a list
        named_vars = reduce(list.__add__, named_mvar_struct.values())           

        # Create data structure to handle different type of variables of the dynamic problem
        mvar_struct = OrderedDict()
        mvar_struct["t"] = casadi.MX.sym("t")
        mvar_struct["dx"] = casadi.MX.sym("dx", n_var['dx'])
        mvar_struct["x"] = casadi.MX.sym("x", n_var['x'])
        mvar_struct["y"] = casadi.MX.sym("y", n_var['y'])
        mvar_struct["unelim_u"] = casadi.MX.sym("unelim_u", n_var['unelim_u'])
        mvar_struct["elim_u"] = casadi.MX.sym("elim_u", n_var['elim_u'])
        mvar_struct["p_opt"] = casadi.MX.sym("p_opt", n_var['p_opt'])
        mvar_struct["p_fixed"] = casadi.MX.sym("p_fixed", n_var['p_fixed'])
        
        # Handy ordered structure for substitution
        svector_vars=[mvar_struct["t"]]

        # Create map from name to variable index and type
        name_map = {}
        for vt in ["dx", "x", "y", "unelim_u", "elim_u", "p_opt", "p_fixed"]:
            i = 0
            for var in mvar_vectors[vt]:
                name = var.getName()
                name_map[name] = (i, vt)
                svector_vars.append(mvar_struct[vt][i])
                i = i + 1

        # Substitute named variables with vector variables in expressions
        s_op_expressions = [initial, dae, path_e, path_i, objective]
        [initial, dae, path_e, path_i, objective] = casadi.substitute(s_op_expressions, named_vars, svector_vars)
        self.mvar_struct = mvar_struct

        # Store expressions and variable structures
        self.initial = initial
        self.dae = dae
        self.path_e = path_e
        self.path_i = path_i
        self.objective = objective
        self.mvar_vectors = mvar_vectors
        self.n_var = n_var
        self.name_map = name_map

    def _create_nlp_variables(self):
        """
        Create the NLP variables and store them in a nested dictionary.
        """
        # Set model info
        nlp_n_var = copy.copy(self.n_var)
        del nlp_n_var['u']
        del nlp_n_var['elim_u']
        del nlp_n_var['quad_pen']
        n_popt = nlp_n_var['p_opt']
        n_pp = nlp_n_var['p_fixed']
        del nlp_n_var['p_fixed']
        del nlp_n_var['p_opt']
        mvar_vectors = self.mvar_vectors

        # Count NLP variables
        if self.external_data is None:
            self.n_instances = 1
        else:
            self.n_instances = self.external_data.n
        n_xx = n_popt
        n_xx += self.n_instances * N.sum(nlp_n_var.values())

        # Create NLP variables and parameters
        xx = casadi.MX.sym("xx", n_xx)
        pp = casadi.MX.sym("pp", n_pp)

        # Map with indices of variables
        self.var_indices = var_indices = dict()
        self.var_map = var_map = dict()
        if self.named_vars:
            self.named_xx = named_xx = []
            self.named_pp = named_pp = []

        # Index free parameters
        global_index = 0
        for vk in ['p_opt']:
            var_map[vk] = casadi.MX()
            var_indices[vk] = []
            var_index = 0
            for var in mvar_vectors[vk]:
                name = var.getName()
                var_map[vk].append(xx[global_index])
                if self.named_vars:
                    named_var = casadi.SX.sym(var.getName())
                    self.named_xx.append(named_var)
                var_indices[vk].append(global_index)
                global_index += 1
                var_index += 1

        # Index DAE variables
        for vk in ['dx', 'x', 'y', 'unelim_u']:
            var_map[vk] = dict()
            var_indices[vk] = dict()
            var_index = 0
            for i in xrange(self.n_instances):
                var_map[vk][i] = casadi.MX()
                var_indices[vk][i] = []
                for var in mvar_vectors[vk]:
                    name = var.getName()
                    var_map[vk][i].append(xx[global_index])
                    var_indices[vk][i].append(global_index)
                    if self.named_vars:
                        if self.n_instances == 1:
                            named_var = casadi.SX.sym(var.getName())
                        else:
                            named_var = casadi.SX.sym(var.getName()+'_%d' % i)
                        self.named_xx.append(named_var)
                    global_index += 1
                    var_index += 1

        # Index fixed parameters
        vk = 'p_fixed'
        var_map[vk] = casadi.MX()
        var_indices[vk] = []
        p_fixed_index = 0
        for var in mvar_vectors[vk]:
            name = var.getName()
            var_map[vk].append(pp[p_fixed_index])
            if self.named_vars:
                named_var = casadi.SX.sym(var.getName())
                self.named_pp.append(named_var)
            var_indices[vk].append(p_fixed_index)
            p_fixed_index += 1

        # Check that only inputs are eliminated
        if self.external_data is not None:
            for var_name in self.external_data.eliminated.keys():
                (_, vk) = self.external_data_name_map[var_name]
                if vk not in ['elim_u', 'unelim_u']:
                    if var_name in self.external_data.eliminated.keys():
                        msg = ("Eliminated variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    raise jmiVariableNotFoundError(msg)
        
        # Save variables and indices as data attributes
        self.xx = xx
        self.pp = pp
        assert n_xx == global_index
        assert n_pp == p_fixed_index
        if self.named_vars:
            assert(len(named_xx) == n_xx)
            assert(len(named_pp) == n_pp)
            self.named_xx = casadi.vertcat(self.named_xx)
            self.named_pp = casadi.vertcat(self.named_pp)
        self.n_xx = n_xx
        self.n_pp = n_pp

    def _get_z(self, i):
        """
        Returns a vector with all the NLP variables at a collocation point.

        Parameters::

            i --
                DAE instance.
                Type: int

        Returns::

            z --
                NLP variable vector.
                Type: MX or SX
        """
        z = []
        for vk in self.mvar_struct.iterkeys(): #Dangerous need to verify that variable types are added in correct order
            if vk == 't':
                z.append(self.t0)
            elif vk in ['p_opt', 'p_fixed']:
                if self.n_var[vk]>0:
                    z.append(self.var_map[vk])
            else:
                if self.n_var[vk]>0:
                    z.append(self.var_map[vk][i])
        return z

    def _compute_external_inputs(self):
        """
        Computes the external inputs.
        """        
        for vk in ('elim_u', 'quad_pen'):
            self.var_map[vk] = dict()
            for i in xrange(self.n_instances):
                self.var_map[vk][i] = N.zeros(self.n_var[vk])
        if self.external_data is not None:
            for (vk, source) in (('elim_u', self.external_data.eliminated), 
                                 ('quad_pen', self.external_data.quad_pen)):
                for (j, (name, data)) in enumerate(source.items()):
                    self._sample_external_input(vk, j, name, data)

    def _sample_external_input(self, vk, var_index, name, data):
        """
        Sample the external data for one variable.
        """
        traj_min, traj_max = N.inf, -N.inf

        # Sample collocation points
        for i in xrange(self.n_instances):
            value = data[i]
            if value < traj_min:
                traj_min = value
            if value > traj_max:
                traj_max = value
            
            # Write the sampled data to var_map or _par_vals
            self.var_map[vk][i][var_index] = value

        # Check that constrained and eliminated inputs satisfy their bounds
        if vk in 'elim_u':
            var = self.op.getVariable(name)
            var_min = self.op.get_attr(var, "min")
            var_max = self.op.get_attr(var, "max")
            if traj_min < var_min:
                raise CasadiCollocatorException(
                    "The trajectory for the measured input " + name +
                    " does not satisfy the input's lower bound.")
            if traj_max > var_max:
                raise CasadiCollocatorException(
                    "The trajectory for the measured input " + name +
                    " does not satisfy the input's upper bound.")

    def _create_constraints_and_cost(self):
        # Define symbolic input
        sym_input = [self.mvar_struct["t"]]
        var_kinds_ordered = copy.copy(self.mvar_struct.keys())
        del var_kinds_ordered[0]
        for vk in var_kinds_ordered:
            if self.n_var[vk]>0:
                sym_input.append(self.mvar_struct[vk])
        
        # Create functions
        dae_fcn = self._FXFunction(sym_input, [self.dae])
        initial_fcn = self._FXFunction(sym_input, [self.initial])
        path_e_fcn = self._FXFunction(sym_input, [self.path_e])
        path_i_fcn = self._FXFunction(sym_input, [self.path_i])
        objective_fcn = self._FXFunction(sym_input, [self.objective])

        # Create constraints and cost
        self.c_e = c_e = casadi.MX()
        self.c_i = c_i = casadi.MX()
        cost = casadi.MX(0)
        for i in xrange(self.n_instances):
            z = self._get_z(i)
            c_e.append(dae_fcn.call(z)[0])
            c_e.append(initial_fcn.call(z)[0])
            c_e.append(path_e_fcn.call(z)[0])
            c_i.append(path_i_fcn.call(z)[0])
            cost += objective_fcn.call(z)[0]

        # Add quadratic cost for external data
        if (self.external_data is not None and len(self.external_data.quad_pen) > 0):
            # Create nested dictionary for storage of errors and calculate reference values
            err = {}
            for i in range(self.n_instances):
                err[i] = []

            # Calculate errors
            for (vk, source) in (('quad_pen', self.external_data.quad_pen),):
                for (j, name) in enumerate(source.keys()):
                    for i in range(self.n_instances):
                        (ind, vt) = self.name_map[name]
                        var = self.var_map[vt][i][ind]
                        ref_val = self.var_map[vk][i][j]
                        err[i].append(var - ref_val)

            # Calculate cost contribution from each collocation point
            for i in range(self.n_instances):
                Q = self.external_data.Q[i]
                err_i = N.array(err[i])
                cost += N.dot(N.dot(err_i, Q), err_i)
        
        self.cost = cost

    def _compute_bounds_and_init(self):
        """
        Compute bounds and intial guesses for NLP variables.
        """
        # Create lower and upper bounds
        xx_min = -N.inf * N.ones(self.n_xx)
        xx_max = N.inf * N.ones(self.n_xx)
        xx_init = N.zeros(self.n_xx)
        xx_sf = N.zeros(self.n_xx)

        # Retrieve model data
        op = self.op
        name_map = self.name_map
        mvar_vectors = self.mvar_vectors

        # Set up initial guess
        if not self.init_guess is None:
            self.init_guess = copy.deepcopy(self.init_guess)
            if isinstance(self.init_guess, list):
                if len(self.init_guess) != self.n_instances:
                    raise ValueError('An initial guess needs to be provided for each problem instance.')
                for (i, obj) in enumerate(self.init_guess):
                    if isinstance(obj, JMResultBaseAll):
                        self.init_guess[i] = self.init_guess[i].result_data
            else:
                if isinstance(self.init_guess, JMResultBaseAll):
                    self.init_guess = self.init_guess.result_data
                if len(self.init_guess.get_result_data('time').t) != self.n_instances:
                    raise ValueError('The initial guess needs to have a time point for each problem instance.')

        # Compute values
        for vk in ['unelim_u', 'p_opt', 'dx', 'x', 'y']:
            for var in mvar_vectors[vk]:
                var_min = op.get_attr(var, 'min')
                var_max = op.get_attr(var, 'max')
                for i in xrange(self.n_instances):
                    var_init = self._eval_initial(var, i)
                    name = var.getName()
                    (var_index, _) = name_map[name]
                    if vk in ['p_opt']:
                        global_index = self.var_indices[vk][var_index]
                    else:
                        global_index = self.var_indices[vk][i][var_index]
                    xx_init[global_index] = var_init
                    xx_min[global_index] = var_min
                    xx_max[global_index] = var_max
                    if N.abs(var_init) < 1e-6:
                        if self.verbosity == 3:
                            if self.init_guess is not None:
                                print('Warning: Initial guess for %s is too close to zero. ' % name +
                                      'Using nominal attribute instead for scaling instead.')
                            var_nom = op.get_attr(var, 'nominal')
                            xx_sf[global_index] = N.abs(var_nom)
                    else:
                        xx_sf[global_index] = N.abs(var_init)

        # Store bounds and initial guesses
        self.xx_min = xx_min
        self.xx_max = xx_max
        self.xx_init = xx_init
        self.xx_sf = xx_sf

    def _eval_initial(self, var, i):
        """
        Evaluate initial value of Variable var at a given instance.
        """
        if self.init_guess is None:
            return self.op.get_attr(var, "initialGuess")
        else:
            name = var.getName()
            if isinstance(self.init_guess, ResultDymolaTextual):
                return self.init_guess.get_variable_data(name).x[i]
            else:
                return self.init_guess[i].get_variable_data(name).x[0]

    def _scale_nlp(self):
        if self.variable_scaling:
            [self.c_e, self.c_i, self.cost] = \
                    casadi.substitute([self.c_e, self.c_i, self.cost], [self.xx], [self.xx_sf * self.xx])
            self.xx_init /= self.xx_sf
            self.xx_min /= self.xx_sf
            self.xx_max /= self.xx_sf

    def _FXFunction(self, *args):
        f = casadi.MXFunction(*args)
        if self.expand_to_sx != 'no':
            f.init()
            f = casadi.SXFunction(f)
        return f

    def _create_solver_object(self):
        # Concatenate constraints
        constraints = casadi.vertcat([self.c_e, self.c_i])

        # Create solver object
        self.constraints = constraints
        nlp = casadi.MXFunction(casadi.nlpIn(x=self.xx, p=self.pp),
                                casadi.nlpOut(f=self.cost, g=constraints))
        if self.solver == "IPOPT":
            self.solver_object = casadi.NlpSolver("ipopt",nlp)
        elif self.solver == "WORHP":
            self.solver_object = casadi.NlpSolver("worhp",nlp)
        else:
            raise CasadiCollocatorException(
                    "Unknown nonlinear programming solver %s." % self.solver)

    def _recalculate_model_parameters(self):
        """
        Recalculate the model's parameters and set them in self._par_vals
        """
        self.op.calculateValuesForDependentParameters()
        par_vals = [self.op.get_attr(par, "_value") for par in self.mvar_vectors['p_fixed']]
        self.par_vals = N.array(par_vals).reshape(-1)

    def _init_and_set_solver_inputs(self):
        self.solver_object.init()

        # Expand to SX
        self.solver_object.setOption("expand", self.expand_to_sx == "NLP")

        # Primal initial guess and parameter values
        self.solver_object.setInput(self.xx_init, 'x0')
        self.solver_object.setInput(self.par_vals, 'p')

        # Bounds on x
        self.solver_object.setInput(self.xx_min, 'lbx')
        self.solver_object.setInput(self.xx_max, 'ubx')

        # Bounds on the constraints
        lbg = self.c_e.numel()*[0.] + self.c_i.numel()*[-N.inf]
        ubg = (self.c_e.numel() + self.c_i.numel())*[0.]
        self.solver_object.setInput(lbg, 'lbg')
        self.solver_object.setInput(ubg, 'ubg')

    def set_solver_option(self, k, v):
        """
        Sets nonlinear programming solver options.

            Parameters::

                k - Name of the option
                v - Value of the option (int, double, string)
        """
        self.solver_object.setOption(k, v)

    def get_solver_statistics(self):
        """ 
        Get nonlinear programming solver statistics.

        Returns::

            return_status -- 
                Return status from nonlinear programming solver.

            nbr_iter -- 
                Number of iterations.

            objective -- 
                Final value of objective function.

            total_exec_time -- 
                Nonlinear programming solver execution time.
        """
        stats = self.solver_object.getStats()
        nbr_iter = stats['iter_count']
        objective = float(self.solver_object.getOutput('f'))
        total_exec_time = stats['t_mainloop.proc']
        
        # 'Maximum_CPU_Time_Exceeded' and 'Feasible_Point_for_Square_Problem_Found' fail
        # to fill in stats['return_status'].
        if (self.solver_object.hasSetOption('max_cpu_time') and
            total_exec_time >= self.solver_object.getOption('max_cpu_time')):
            return_status = 'Maximum_CPU_Time_Exceeded'
        else:
            try:
                return_status = stats['return_status']
            except KeyError:
                return_status = 'Feasible_Point_for_Square_Problem_Found'
        return (return_status, nbr_iter, objective, total_exec_time)

    def solve(self):
        # Solve the problem
        self._recalculate_model_parameters()
        self._init_and_set_solver_inputs()
        t0 = time.clock()
        self.solver_object.evaluate()
        sol_time = time.clock() - t0

        # Get the result
        primal_opt = N.array(self.solver_object.getOutput('x')).reshape(-1)
        if self.variable_scaling and not self.write_scaled_result:
            primal_opt = self.xx_sf * primal_opt
        self.primal_opt = primal_opt.reshape(-1)
        return sol_time

    def get_result(self):
        # Set model info
        n_var = self.n_var
        cont = {'dx': False, 'x': True, 'y': False, 'unelim_u': False}
        mvar_vectors = self.mvar_vectors
        var_types = ['dx', 'x', 'y', 'unelim_u']
        name_map = self.name_map
        var_map = self.var_map
        var_opt = {}
        op = self.op

        # Get solution
        primal_opt = self.primal_opt
        t_opt = N.arange(self.n_instances).reshape([-1, 1])

        # Create arrays for storage of variable trajectories
        for var_type in var_types + ['elim_u']:
            var_opt[var_type] = N.empty([len(t_opt), n_var[var_type]])
        var_opt['merged_u'] = N.empty([len(t_opt), n_var['unelim_u'] + n_var['elim_u']])
        var_opt['p_opt'] = N.empty(n_var['p_opt'])

        # Get parameter values
        var_opt['p_opt'][:] = primal_opt[self.var_indices['p_opt']].reshape(-1)
        var_opt['p_fixed'] = self.par_vals
        
        # Get instance variables
        for i in xrange(self.n_instances):
            for var_type in var_types:
                xx_i = primal_opt[self.var_indices[var_type][i]]
                var_opt[var_type][i, :] = xx_i.reshape(-1)
            var_opt['elim_u'][i, :] = self.var_map['elim_u'][i]

        # Merge uneliminated and eliminated inputs
        if self.n_var['u'] > 0:
            var_opt['merged_u'][:, self._unelim_input_indices] = var_opt['unelim_u']
            var_opt['merged_u'][:, self._elim_input_indices] = var_opt['elim_u']

        # Return results
        return (t_opt, var_opt['dx'], var_opt['x'], var_opt['y'], var_opt['merged_u'],
                var_opt['p_opt'], var_opt['p_fixed'])

    def export_result_dymola(self, file_name='', format='txt', 
                             write_scaled_result=False, result=None):
        """
        Export an optimization or simulation result to file in Dymolas result file 
        format. The parameter values are read from the z vector of the model object 
        and the time series are read from the data argument.

        Parameters::

            file_name --
                If no file name is given, the name of the model (as defined by 
                casadiModel.get_name()) concatenated with the string '_result' is used. 
                A file suffix equal to the format argument is then appended to the 
                file name.
                Default: Empty string.

            format --
                A text string equal either to 'txt' for textual format or 'mat' for 
                binary Matlab format.
                Default: 'txt'

            write_scaled_result --
                Set this parameter to True to write the result to file without
                taking scaling into account. If the value of write_sacled_result
                is False, then the variable scaling factors of the model are
                used to reproduced the unscaled variable values.
                Default: False
                
            result --
                If a result is given, that result is the one that gets exported
                to a dymola file. Otherwise this function will call 
                self.get_result() and export the result from the last 
                optimization/sample.
                Default: None 

        Returns::

            used_file_name --
                The actual file name used to write the result file.
                Equals file_name unless file_name is empty.

        Limitations::

            Currently only textual format is supported.
        """
        if result is None:
            (t, dx_opt, x_opt, y_opt, u_opt, p_opt, p_fixed) = self.get_result()
        else:
            (t, dx_opt, x_opt, y_opt, u_opt, p_opt, p_fixed) = result
        data = N.hstack((t, dx_opt, x_opt, y_opt, u_opt))

        if (format=='txt'):
            op = self.op
            name_map = self.name_map
            mvar_vectors = self.mvar_vectors
            variable_list = reduce(list.__add__, [list(mvar_vectors[vt]) for
                                                  vt in ['dx', 'x', 'y', 'u', 'p_opt', 'p_fixed']])

            # Map variable to aliases
            alias_map = {}
            for var in variable_list:
                alias_map[var.getName()] = []
            for alias_var in op.getAliases():
                alias = alias_var.getModelVariable()
                alias_map[alias.getName()].append(alias_var)

            # Set up sections
            # Put exactly one entry per variable in name_section etc
            # - its length is used to determine num_vars
            name_section = ['time\n']
            description_section = ['Time in [s]\n']
            data_info_section = ['0 1 0 -1 # time\n']

            # Collect meta information
            n_variant = 1
            n_invariant = 1
            max_name_length = len('Time')
            max_desc_length = len('Time in [s]')
            for var in variable_list:
                # Name
                name = var.getName()
                name_section.append('%s\n' % name)
                if len(name) > max_name_length:
                    max_name_length = len(name)

                # Description
                description = op.get_attr(var, "comment")
                description_section.append('%s\n' % description)
                if len(description) > max_desc_length:
                    max_desc_length = len(description)

                # Data info
                variability = var.getVariability()
                if variability in [var.PARAMETER, var.CONSTANT]:
                    n_invariant += 1
                    data_info_section.append('1 %d 0 -1 # %s\n' %
                                             (n_invariant, name))
                else:
                    n_variant += 1
                    data_info_section.append('2 %d 0 -1 # %s\n' %
                                             (n_variant, name))

                # Handle alias variables
                for alias_var in alias_map[var.getName()]:
                    # Name
                    name = alias_var.getName()
                    name_section.append('%s\n' % name)
                    if len(name) > max_name_length:
                        max_name_length = len(name)

                    # Description
                    description = op.get_attr(alias_var, "comment")
                    description_section.append('%s\n' % description)
                    if len(description) > max_desc_length:
                        max_desc_length = len(description)

                    # Data info
                    if alias_var.isNegated():
                        neg = -1
                    else:
                        neg = 1
                    if variability in [alias_var.PARAMETER, alias_var.CONSTANT]:
                        data_info_section.append('1 %d 0 -1 # %s\n' %
                                                 (neg*n_invariant, name))
                    else:
                        data_info_section.append('2 %d 0 -1 # %s\n' %
                                                 (neg*n_variant, name))

            # Collect parameter data (data_1)
            data_1 = []
            for par in mvar_vectors['p_opt']:
                name = par.getName()
                (ind, _) = name_map[name]
                data_1.append(" %.14E" % p_opt[ind])

            for par_val in p_fixed:
                data_1.append(" %.14E" % par_val)

            # Open file
            if file_name == '':
                file_name = self.op.getIdentifier() + '_result.txt'
            f = codecs.open(file_name, 'w', 'utf-8')

            # Write header
            f.write('#1\n')
            f.write('char Aclass(3,11)\n')
            f.write('Atrajectory\n')
            f.write('1.1\n')
            f.write('\n')

            num_vars = len(name_section)

            # Write names
            f.write('char name(%d,%d)\n' % (num_vars, max_name_length))
            for name in name_section:
                f.write(name)
            f.write('\n')

            # Write descriptions
            f.write('char description(%d,%d)\n' % (num_vars, max_desc_length))
            for description in description_section:
                f.write(description)
            f.write('\n')

            # Write dataInfo
            f.write('int dataInfo(%d,%d)\n' % (num_vars, 4))
            for data_info in data_info_section:
                f.write(data_info)
            f.write('\n')

            # Write data_1
            n_parameters = (len(mvar_vectors['p_opt']) +
                            len(mvar_vectors['p_fixed']))
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            par_val_str = ''
            for par_val in data_1:
                par_val_str += par_val
            par_val_str += '\n'
            f.write("%.14E" % data[0,0])
            f.write(par_val_str)
            f.write("%.14E" % data[-1,0])
            f.write(par_val_str)
            f.write('\n')

            # Write data_2
            n_vars = len(data[0, :])
            n_points = len(data[:, 0])
            f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
            for i in range(n_points):
                str_text = ''
                for ref in range(n_vars):
                    str_text = str_text + (" %.14E" % data[i, ref])
                f.write(str_text + '\n')

            # Close file
            f.write('\n')
            f.close()

            return file_name
        else:
            raise NotImplementedError('Export on binary Dymola result files ' +
                                      'not yet supported.')

    def get_named_var_expr(self, expr):
        """
        Substitute anonymous variables in an expression for named variables.

        Only works if named_vars == True.
        """
        if self.named_vars:
            f = casadi.MXFunction([self.xx, self.pp], [expr])
            f.init()
            return f.call([self.named_xx, self.named_pp],True)[0]
        else:
            raise CasadiCollocatorException("named_var_expr only works if named_vars is enabled.")

class StaticOptimizationAlgResult(JMResultBaseJMI):
    
    """
    A JMResultBase object with the additional attributes times and h_opt.
    
    Attributes::
    
        times --
            A dictionary with the keys 'init', 'sol', 'post_processing' and
            'tot', which measure CPU time consumed during different algorithm
            stages.

            times['init'] is the time spent creating the NLP.
            
            times['sol'] is the time spent solving the NLP (total Ipopt
            time).
            
            times['post_processing'] is the time spent processing the NLP
            solution before it is returned.
            
            times['tot'] is the sum of all the other times.
            
            Type: dict
    """
    
    def __init__(self, model=None, result_file_name=None, solver=None, 
                 result_data=None, options=None, times=None, h_opt=None):
        super(StaticOptimizationAlgResult, self).__init__(model, result_file_name, solver, result_data, options)
        self.times = times
        
        if solver is not None:
            # Save values from the solver since they might change in the solver.
            # Assumes that solver.primal_opt and solver.dual_opt will not be mutated, which seems to be the case.
            self.primal_opt = solver.primal_opt
            self.solver_statistics = solver.get_solver_statistics()

        if times is not None and self.options['verbosity'] >= 1:
            # Print times
            print("\nInitialization time: %.2f seconds" % times['init'])
            print("\nTotal time: %.2f seconds" % times['tot'])
            print("Solution time: %.2f seconds" % times['sol'])
            print("Post-processing time: %.2f seconds\n" % times['post_processing'])
