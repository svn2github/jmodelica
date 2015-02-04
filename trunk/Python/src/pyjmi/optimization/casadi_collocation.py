#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
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
Module containing the CasADi interface Python wrappers.
"""

import logging
import codecs
import operator
import itertools
import time
import copy
import types
from operator import sub
from collections import OrderedDict, Iterable

try:
    import casadi
    import casadi.tools as ct
except ImportError:
    logging.warning('Could not find CasADi package, aborting.')
import numpy as N

from pyjmi.optimization.polynomial import *
from pyjmi.common import xmlparser
from pyjmi.common.xmlparser import XMLException
from pyjmi.common.core import TrajectoryLinearInterpolation
from pyjmi.common.core import TrajectoryUserFunction

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

from pyjmi.common.algorithm_drivers import JMResultBase
from pyjmi.common.io import ResultDymolaTextual

class CasadiCollocatorException(Exception):
    """
    A CasadiCollocator Exception.
    """
    pass

class CasadiCollocator(object):

    """
    Base class for implementation of collocation algorithms using CasadiModel.
    """

    UPPER = N.inf
    LOWER = -N.inf

    def __init__(self, model):
        # Store model and OCP object
        self.model = model
        self.ocp = model.get_casadi_ocp()

        # Update dependent parameters
        casadi.updateDependent(self.ocp)

        # Check if minimum time normalization has occured
        t0 = self.ocp.variable('startTime')
        tf = self.ocp.variable('finalTime')
        if (t0.getFree() and not self.ocp.t0_free or
            tf.getFree() and not self.ocp.tf_free):
            self._normalize_min_time = True
        else:
            self._normalize_min_time = False

        # Get start and final time
        if self._normalize_min_time:
            self.t0 = self.ocp.t0
            self.tf = self.ocp.tf
        else:
            self.t0 = t0.getStart()
            self.tf = tf.getStart()

        # Update OCP expressions
        self.model.update_expressions()

    def get_model(self):
        return self.model

    def get_model_description(self):
        return self.get_model().get_model_description()

    def get_cost(self):
        raise NotImplementedError

    def get_var_indices(self):
        return self.var_indices

    def get_time(self):
        return self.time

    def get_time_points(self):
        return self.time_points

    def get_xx(self):
        return self.xx

    def get_n_xx(self):
        return self.n_xx

    def get_xx_lb(self):
        return self.xx_lb

    def get_xx_ub(self):
        return self.xx_ub

    def get_xx_init(self):
        return self.xx_init

    def get_hessian(self):
        return None

    def get_inequality_constraint(self):
        """
        Get the inequality constraint g(x) <= 0.0
        """
        return casadi.SX()

    def get_equality_constraint(self):
        """
        Get the equality constraint h(x) = 0.0
        """
        return casadi.SX()

    def set_solver_option(self, k, v):
        """
        Sets nonlinear programming solver options.

            Parameters::

                k - Name of the option
                v - Value of the option (int, double, string)
        """
        self.solver_object.setOption(k,v)

    def _get_xml_variable_by_name(self, name):
        """
        Helper function for getting an XML variable by name.

        This method does not really belong here...
        """
        variables = self.model.xmldoc.get_model_variables()
        for var in variables:
            if var.get_name() == name:
                return var
        raise XMLException("Could not find XML variable with name: %s" % name)

    def export_result_dymola(self, file_name='', format='txt', 
                             write_scaled_result=False):
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

        Limitations::

            Currently only textual format is supported.
        """
        (t,dx_opt,x_opt,u_opt,w_opt,p_opt) = self.get_result()
        data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt))

        if (format=='txt'):

            if file_name=='':
                file_name=self.model.get_identifier() + '_result.txt'

            # Open file
            f = codecs.open(file_name,'w','utf-8')

            # Write header
            f.write('#1\n')
            f.write('char Aclass(3,11)\n')
            f.write('Atrajectory\n')
            f.write('1.1\n')
            f.write('\n')

            md = self.model.get_model_description()

            # NOTE: it is essential that the lists 'names', 'aliases', 'descriptions' 
            # and 'variabilities' are sorted in the same order and that this order 
            # is: value reference order AND within the same value reference the 
            # non-alias variable must be before its corresponding aliases. Otherwise 
            # the header-writing algorithm further down will fail.
            # Therefore the following code is needed...

            # all lists that we need for later
            vrefs_alias = []
            vrefs = []
            names_alias = []
            names = []
            names_noalias = []
            aliases_alias = []
            aliases = []
            descriptions_alias = []
            descriptions = []
            variabilities_alias = []
            variabilities = []
            variabilities_noalias = []

            # go through all variables and split in non-alias/only-alias lists
            for var in md.get_model_variables():
                if var.get_alias() == xmlparser.NO_ALIAS:
                    vrefs.append(var.get_value_reference())
                    names.append(var.get_name())
                    aliases.append(var.get_alias())
                    descriptions.append(var.get_description())
                    variabilities.append(var.get_variability())
                else:
                    vrefs_alias.append(var.get_value_reference())
                    names_alias.append(var.get_name())
                    aliases_alias.append(var.get_alias())
                    descriptions_alias.append(var.get_description())
                    variabilities_alias.append(var.get_variability())

            # extend non-alias lists with only-alias-lists
            vrefs.extend(vrefs_alias)
            names.extend(names_alias)
            aliases.extend(aliases_alias)
            descriptions.extend(descriptions_alias)
            variabilities.extend(variabilities_alias)

            # start values (used in parameter writing)
            start = md.get_variable_start_attributes()
            start_values = dict([(start[i][0], start[i][1]) for i in range(len(start))])

            # if some parameters were optimized, store that value
            vr_map = self.model.get_vr_map()
            for var in self.ocp.pf:
                try:
                    vr = var.getValueReference()
                    start_values[vr] = p_opt[vr_map[vr][0]]
                except KeyError:
                    pass
            # add and calculate the dependent parameters
            for (_, vr, val) in self.model.get_pd_val():
                try:
                    start_values[vr] = val
                except KeyError:
                    pass

            # zip to list of tuples and sort - non alias variables are now
            # guaranteed to be first in list and all variables are in value reference 
            # order
            names = sorted(zip(
                tuple(vrefs), 
                tuple(names)), 
                           key=operator.itemgetter(0))
            aliases = sorted(zip(
                tuple(vrefs), 
                tuple(aliases)), 
                             key=operator.itemgetter(0))
            descriptions = sorted(zip(
                tuple(vrefs), 
                tuple(descriptions)), 
                                  key=operator.itemgetter(0))
            variabilities = sorted(zip(
                tuple(vrefs), 
                tuple(variabilities)), 
                                   key=operator.itemgetter(0))

            num_vars = len(names)

            # Find the maximum name and description length
            max_name_length = len('Time')
            max_desc_length = len('Time in [s]')

            for i in range(len(names)):
                name = names[i][1]
                desc = descriptions[i][1]

                if (len(name)>max_name_length):
                    max_name_length = len(name)

                if (len(desc)>max_desc_length):
                    max_desc_length = len(desc)

            f.write('char name(%d,%d)\n' % (num_vars + 1, max_name_length))
            f.write('time\n')

            # write names
            for name in names:
                f.write(name[1] +'\n')

            f.write('\n')

            f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
            f.write('Time in [s]\n')

            # write descriptions
            for desc in descriptions:
                f.write(desc[1]+'\n')

            f.write('\n')

            # Write data meta information
            f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
            f.write('0 1 0 -1 # time\n')

            cnt_1 = 1
            cnt_2 = 1

            n_parameters = 0
            params = []

            for i, name in enumerate(names):
                if variabilities[i][1] == xmlparser.PARAMETER or \
                   variabilities[i][1] == xmlparser.CONSTANT:
                    if aliases[i][1] == 0: # no alias
                        cnt_1 = cnt_1 + 1
                        n_parameters += 1
                        params += [name]
                        f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                    else: # alias
                        if aliases[i][1] == 1:
                            neg = 1
                        else:
                            neg = -1 # negated alias
                        var = self._get_xml_variable_by_name(name[1])
                        if var.get_alias():
                            # Check whether the alias has the same variability
                            var_ali = md.get_aliases_for_variable(name[1])[0]
                            for aliass in var_ali:
                                aliass_var = \
                                    self._get_xml_variable_by_name(aliass)
                                if not aliass_var.get_alias():
                                    variab = aliass_var.get_variability()
                                    if (variab != xmlparser.PARAMETER and
                                        variab != xmlparser.CONSTANT):
                                        f.write('2 %d 0 -1 # ' % (neg*cnt_2) +
                                                name[1] +'\n')
                                    else:
                                        f.write('1 %d 0 -1 # ' % (neg*cnt_1) +
                                                name[1] +'\n')
                        else:
                            f.write('1 %d 0 -1 # ' % (neg*cnt_1) +
                                    name[1] +'\n')
                else:
                    if aliases[i][1] == 0: # noalias
                        cnt_2 = cnt_2 + 1
                        f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                    else: # alias
                        if aliases[i][1] == 1:
                            neg = 1
                        else:
                            neg = -1 # negated alias
                        var = self._get_xml_variable_by_name(name[1])
                        if var.get_alias():
                            # Check whether the alias has the same variability
                            var_ali = md.get_aliases_for_variable(name[1])[0]
                            for aliass in var_ali:
                                aliass_var = \
                                    self._get_xml_variable_by_name(aliass)
                                if not aliass_var.get_alias():
                                    variab = aliass_var.get_variability()
                                    if (variab == xmlparser.PARAMETER or
                                        variab == xmlparser.CONSTANT):
                                        f.write('1 %d 0 -1 # ' % (neg*cnt_1) +
                                                name[1] +'\n')
                                    else:
                                        f.write('2 %d 0 -1 # ' % (neg*cnt_2) +
                                                name[1] +'\n')
                        else:
                            f.write('2 %d 0 -1 # ' % (neg*cnt_2) +
                                    name[1] +'\n')
            f.write('\n')

            # Write data
            # Write data set 1
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            f.write("%.14E" % data[0,0])
            str_text = ''
            for i in params:
                str_text += " %.14E" % (start_values[i[0]])#(0.0)#(z[ref])

            f.write(str_text)
            f.write('\n')
            f.write("%.14E" % data[-1,0])
            f.write(str_text)

            f.write('\n\n')

            # Write data set 2
            n_vars = len(data[0,:])
            n_points = len(data[:,0])
            f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
            for i in range(n_points):
                str_text = ''
                for ref in range(n_vars):
                    str_text = str_text + (" %.14E" % data[i,ref])
                f.write(str_text+'\n')

            f.write('\n')

            f.close()

        else:
            raise Error('Export on binary Dymola result files not yet ' +
                        'supported.')

    def get_result(self):
        t_opt = self.get_time().reshape([-1, 1])
        dx_opt = N.empty([len(t_opt), self.model.get_n_x()])
        x_opt = N.empty([len(t_opt), self.model.get_n_x()])
        w_opt = N.empty([len(t_opt), self.model.get_n_w()])
        u_opt = N.empty([len(t_opt), self.model.get_n_u()])
        p_opt  = N.empty(self.model.get_n_p())

        p_opt[:] = self.primal_opt[self.get_var_indices()['p_opt']][:, 0]

        cnt = 0
        var_indices = self.get_var_indices()
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                dx_opt[cnt, :] = self.primal_opt[var_indices[i][k]['dx']][:, 0]
                x_opt[cnt, :] = self.primal_opt[var_indices[i][k]['x']][:, 0]
                u_opt[cnt, :] = self.primal_opt[var_indices[i][k]['u']][:, 0]
                w_opt[cnt, :] = self.primal_opt[var_indices[i][k]['w']][:, 0]
                cnt += 1
        return (t_opt, dx_opt, x_opt, u_opt, w_opt, p_opt)

    def get_opt_input(self):
        """
        Get the optimized input variables as a function of time.

        The purpose of this method is to conveniently provide the optimized
        input variables to a simulator.

        Returns::

            input_names --
                Tuple consisting of the names of the input variables.

            input_interpolator --
                Collocation polynomials for input variables as a function of
                time.
        """
        # Consider: do we actually need to save _xi, _ti, and _hi in self?
        if self.hs == "free":
            self._hi = map(lambda h: self.horizon * h, self.h_opt)
        else:
            self._hi = map(lambda h: self.horizon * h, self.h)
        self._xi = self._u_opt[1:].reshape(self.n_e, self.n_cp, self.model.n_u)
        self._ti = N.cumsum([self.t0] + self._hi[1:])
        input_names = tuple([repr(u) for u in self.model.u])
        return (input_names, self._create_input_interpolator(self._xi, self._ti, self._hi))

    def _create_input_interpolator(self, xi, ti, hi):
        def _input_interpolator(t):
            i = N.clip(N.searchsorted(ti, t), 1, self.n_e)
            tau = (t - ti[i - 1]) / hi[i]

            x = 0
            for k in xrange(self.n_cp):
                x += xi[i - 1, k, :] * self.pol.eval_basis(k + 1, tau, False)
            return x
        return _input_interpolator

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
        return_status = stats['return_status']
        nbr_iter = stats['iter_count']
        objective = float(self.solver_object.output(casadi.NLP_SOLVER_F))
        total_exec_time = stats['t_mainloop']
        return (return_status, nbr_iter, objective, total_exec_time)

    def solve_nlp(self):
        """
        Calls the nonlinear programming solver.

        Returns::

            sol_time --
                Duration (seconds) of call to nonlinear programming solver.
                Type: float
        """
        init = time.clock()
        # Initialize solver
        if self.warm_start:
            # Initialize primal variables and set parameters
            self.solver_object.setInput(self.get_xx_init(),
                                        casadi.NLP_SOLVER_X0)
            self.solver_object.setInput(self._par_vals, casadi.NLP_SOLVER_P)

            # Initialize dual variables
            self.solver_object.setInput(self.dual_opt['g'],
                                        casadi.NLP_SOLVER_LAM_G0)
            self.solver_object.setInput(self.dual_opt['x'],
                                        casadi.NLP_SOLVER_LAM_X0)
        else:
            self._init_and_set_solver_inputs()
        # Solve the problem
        t0 = time.clock()
        self.extra_init = t0 - init
        self.times['init'] += self.extra_init
        self.solver_object.evaluate()

        # Get the result
        primal_opt = N.array(self.solver_object.output(casadi.NLP_SOLVER_X))
        self.primal_opt = primal_opt.reshape(-1)
        dual_g_opt = N.array(self.solver_object.output(casadi.NLP_SOLVER_LAM_G))
        dual_g_opt = dual_g_opt.reshape(-1)
        dual_x_opt = N.array(self.solver_object.output(casadi.NLP_SOLVER_LAM_X))
        dual_x_opt = dual_x_opt.reshape(-1)
        self.dual_opt = {'g': dual_g_opt, 'x': dual_x_opt}
        sol_time = time.clock() - t0
        return sol_time
        
    def _init_and_set_solver_inputs(self):
        self.solver_object.init()

        # Primal initial guess and parameter values
        self.solver_object.setInput(self.get_xx_init(), casadi.NLP_SOLVER_X0)
        self.solver_object.setInput(self._par_vals, casadi.NLP_SOLVER_P)

        # Dual initial guess
        if self.init_dual is not None:
            self.solver_object.setInput(self.init_dual['g'],
                                        casadi.NLP_SOLVER_LAM_G0)
            self.solver_object.setInput(self.init_dual['x'],
                                        casadi.NLP_SOLVER_LAM_X0)

        # Bounds on x
        self.solver_object.setInput(self.get_xx_lb(), casadi.NLP_SOLVER_LBX)
        self.solver_object.setInput(self.get_xx_ub(), casadi.NLP_SOLVER_UBX)

        # Bounds on the constraints
        n_h = self.get_equality_constraint().numel()
        hublb = n_h * [0]
        n_g = self.get_inequality_constraint().numel()
        gub = n_g * [0]
        glb = n_g * [self.LOWER]
        self.glub = hublb + gub
        self.gllb = hublb + glb

        self.solver_object.setInput(self.gllb, casadi.NLP_SOLVER_LBG)
        self.solver_object.setInput(self.glub, casadi.NLP_SOLVER_UBG)
        
class ExternalData(object):

    """
    External data connected to variables.

    The data can for each variable be treated in three different ways.

    eliminated --
        The data for these inputs is used to eliminate the corresponding NLP
        variables.

    quad_pen --
        The NLP variables are kept, but a quadratic penalty on the deviation
        from the data is introduced.

    constr_quad_pen --
        The NLP variables are kept, but a quadratic penalty on the deviation
        from the data is introduced, as well as an equality constraint.

    eliminated and constr_quad_pen must be inputs, whereas quad_pen can be any
    kind of variable.

    The data for each variable is either a user-defined function of time, or
    a matrix with two rows where the first row is points in time and the
    second row is values for the variable at the corresponding points in time.
    In the second case, the given data is linearly interpolated to get the
    values at the collocation points.
    """

    def __init__(self, eliminated=OrderedDict(), quad_pen=OrderedDict(),
                 constr_quad_pen=OrderedDict(), Q=None):
        """
        The following quadratic cost is formed:

        .. math::

            f = \int_{t_0}^{t_f} (y(t) - y_m(t)) \cdot Q \cdot
            (y(t) - y_m(t))\,\mathrm{d}t,

        where y is the function created by gluing together the
        collocation polynomials for the variables with quadratic penalties at
        all the mesh points and y_m is a function providing the measured
        values at a given time point. If the variable data are a matrix, the
        data are linearly interpolated to create the function y_m. If the data
        are a function, then this function defines y_m.

        Parameters::

            eliminated --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to eliminate the inputs.

                Type: OrderedDict
                Default: OrderedDict()

            quad_pen --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to penalize the inputs.

                Type: OrderedDict
                Default: OrderedDict()

            constr_quad_pen --
                Dictionary with variable names as keys and the values are the
                corresponding data used to constraint and penalize the
                variables.

                Type: OrderedDict
                Default: OrderedDict()

            Q --
                Weighting matrix used to form the quadratic penalty for the
                uneliminated variables. The order of the variables is the same
                as the ordered dictionaries constr_quad_pen and quad_pen,
                with the constrained inputs coming first.

                Type: rank 2 ndarray
                Default: None
        """
        # Check dimension of Q
        Q_len = ((0 if constr_quad_pen is None else len(constr_quad_pen)) + 
                 (0 if quad_pen is None else len(quad_pen)))
        if Q_len > 0 and (Q.shape[0] != Q.shape[1] or Q.shape[0] != Q_len):
            raise ValueError("Weighting matrix Q must be square and have " +
                             "the same dimension as the total number of " +
                             "penalized variables.")

        # Transform data into trajectories
        eliminated = copy.deepcopy(eliminated)
        constr_quad_pen = copy.deepcopy(constr_quad_pen)
        quad_pen = copy.deepcopy(quad_pen)
        for variable_list in [eliminated, constr_quad_pen, quad_pen]:
            for (name, data) in variable_list.items():
                if (isinstance(data, types.FunctionType) or
                    hasattr(data, '__call__')):
                    variable_list[name] = TrajectoryUserFunction(data)
                else:
                    if data.shape[0] != 2:
                        raise ValueError("If variable data is not a " +
                                         "function, it must be a matrix " +
                                         "with exactly two rows.")
                    variable_list[name] = TrajectoryLinearInterpolation(
                        data[0], data[1].reshape([-1, 1]))

        # Store data as attributes
        self.eliminated = eliminated
        self.constr_quad_pen = constr_quad_pen
        self.quad_pen = quad_pen
        self.Q = Q

class FreeElementLengthsData(object):

    """
    Data used to control the element lengths when they are free.

    The objective function f is adjusted to penalize large element lengths for
    elements with high state derivatives, resulting in the augmented objective
    function \hat{f} defined as follows:

    .. math::

        \hat{f} = f + c \cdot \sum_{i = 1}^{n_e} \left(h_i^a \cdot 
        \int_{t_i}^{t_{i+1}} \dot{x}(t) \cdot Q \cdot
        \dot{x}(t)\,\mathrm{d}t\right).
    """

    def __init__(self, c, Q, bounds=(0.7, 1.3), a=1.):
        """
        Parameters::

            c --
                The coefficient for the newly introduced cost term.

                Type: float

            Q --
                The coefficient matrix for weighting the various state
                derivatives.

                Type: ndarray with shape (n_x, n_x)

            bounds --
                Element length bounds. The bounds are given as a tuple (l, u),
                where the bounds are used in the following way:

                .. math::
                    l / n_e \leq h_i \leq u / n_e, \quad\forall i \in [1, n_e],

                where h_i is the normalized length of element i.

                Type: tuple
                Default: (0.7, 1.3)

            a --
                The exponent of the element length.

                Type: float
                Default: 1.
        """
        self.bounds = bounds
        self.c = c
        self.Q = Q
        self.a = a

class BlockingFactors(object):

    """
    Class used to specify blocking factors for CasADi collocators.

    This is used to enforce piecewise constant inputs. The inputs may only
    change at some element boundaries, specified by the blocking factors.

    This also enables the introduction of bounds and quadratic penalties on the
    difference of the inputs between element boundaries.
    """

    def __init__(self, factors, du_bounds={}, du_quad_pen={}):
        """
        Parameters::
            
            factors --
                Dictionary with variable names as keys and list of blocking
                factors as corresponding values.

                The blocking factors should be list of ints. Each element in
                the list specifies the number of collocation elements for which
                the input must be constant. For example, if blocking_factors ==
                [2, 2, 1], then the input will attain 3 different values
                (number of elements in the list), and it will change values
                between element number 2 and 3 and number 4 and 5. The sum of
                all elements in the list must be the same as the number of
                collocation elements and the length of the list determines the
                number of separate values that the inputs may attain.
                
                Type: {string: [int]}
            
            du_bounds --
                Dictionary with variables names as keys and bounds on the
                absolute value of the change in the corresponding input between
                the blocking factors.
                
                Type: {string: float}
                Default: {}

            du_quad_pen --
                This parameter adds a quadratic penalty on the change in u
                between blocking factors.
                
                The parameter should be a dictionary with variables names as
                keys. The values are the weights for the penalty term of the
                corresponding variable.

                Type: {string: float}
                Default: {}
        """
        # Check that factors exist for variables with bounds and penalties
        for name in du_bounds.keys():
            if name not in factors.keys():
                raise ValueError('Bound provided for variable %s' % name +
                                 'but no factors.')
        for name in du_quad_pen.keys():
            if name not in factors.keys():
                raise ValueError('Penalty weight provided for variable ' +
                                 '%s but no factors.' % name)

        # Store parameters as attributes
        self.factors = factors
        self.du_bounds = du_bounds
        self.du_quad_pen = du_quad_pen

class LocalDAECollocator(CasadiCollocator):

    """Solves a dynamic optimization problem using local collocation."""

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
        if op.get_attr(t0, "free") or op.get_attr(tf, "free"):
            if not op.getNormalizedTimeFlag():
                # Change this once #3438 has been fixed
                raise CasadiCollocatorException(
                    "Problems with free time horizons are only " +
                    "supported if time has been normalized.")
            self._normalize_min_time = True
        else:
            self._normalize_min_time = False

        # Check if init_traj is a JMResult
        try:
            self.init_traj = self.init_traj.result_data
        except AttributeError:
            pass

        # Check if nominal_traj is a JMResult
        try:
            self.nominal_traj = self.nominal_traj.result_data
        except AttributeError:
            pass

        # Get start and final time
        if self._normalize_min_time:
            self.t0 = op.getStartTime().getValue()
            self.tf = op.getFinalTime().getValue()
        else:
            self.t0 = op.get_attr(t0, "_value")
            self.tf = op.get_attr(tf, "_value")

        # Define element lengths
        self.horizon = self.tf - self.t0
        if self.hs != "free":
            self.h = [N.nan] # Element 0
            if self.hs is None:
                self.h += self.n_e * [1. / self.n_e]
            else:
                self.h += list(self.hs)

        # Define polynomial for representation of solutions
        if self.discr == "LG":
            self.pol = GaussPol(self.n_cp)
        elif self.discr == "LGR":
            self.pol = RadauPol(self.n_cp)
        else:
            raise CasadiCollocatorException("Unknown discretization scheme %s."
                                            % self.discr)
        self.warm_start = False
        # Get to work
        self._create_nlp()

        self.times['init'] = time.clock() - t0_init

    def solve_and_write_result(self):
        """
        Solve the nonlinear program and write the results to a file.
        Called e.g. by LocalDAECollocationAlg.solve.
        """
        t0 = time.clock()
        # todo: account for preprocessing time within solve_nlp separately?
        self.times['sol'] = self.solve_nlp()
        self.result_file_name = self.export_result_dymola(self.result_file_name)
        self.times['post_processing'] = time.clock() - t0 - self.times['sol'] -self.extra_init

    def get_result_object(self):
        """ 
        Load result data saved in e.g. solve_and_write_result and create a LocalDAECollocationAlgResult object.

        Returns::

            The LocalDAECollocationAlgResult object.
        """
        t0 = time.clock()
        resultfile = self.result_file_name
        res = ResultDymolaTextual(resultfile)

        # Get optimized element lengths
        h_opt = self.get_h_opt()

        self.times['post_processing'] += time.clock() - t0
        self.times['tot'] = self.times['init'] + self.times['sol'] + self.times['post_processing']

        # Create and return result object
        return LocalDAECollocationAlgResult(self.op, resultfile, self,
                                            res, self.options, self.times,
                                            h_opt)

    def _create_nlp(self):
        """
        Wrapper for creating the NLP.
        """
        self._create_model_variable_structures()
        self._scale_variables()
        self._define_collocation()
        self._create_nlp_variables()
        self._create_nlp_parameters()
        self._create_constraints_and_cost()
        self._create_blocking_factors_constraints_and_cost()
        self._compute_bounds_and_init()
        self._create_solver()

    def _create_model_variable_structures(self):
        """
        Create model variable structures.

        Create vectorized model variables unless named_vars is enabled.
        """
        # Get model variable vectors
        op = self.op
        var_kinds = {'dx': op.DERIVATIVE,
                     'x': op.DIFFERENTIATED,
                     'u': op.REAL_INPUT,
                     'w': op.REAL_ALGEBRAIC}
        mvar_vectors = {'dx': N.array([var for var in
                                       op.getVariables(var_kinds['dx'])
                                       if (not var.isAlias() and not var.wasEliminated())]),
                        'x': N.array([var for var in
                                      op.getVariables(var_kinds['x'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'u': N.array([var for var in
                                      op.getVariables(var_kinds['u'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'w': N.array([var for var in
                                      op.getVariables(var_kinds['w'])
                                      if (not var.isAlias() and not var.wasEliminated())])}

        # Count variables (uneliminated inputs and free parameters are counted
        # later)
        n_var = {'dx': len(mvar_vectors["dx"]),
                 'x': len(mvar_vectors["x"]),
                 'u': len(mvar_vectors["u"]),
                 'w': len(mvar_vectors["w"])}

        # Exchange alias variables in external data
        if self.external_data is not None:
            eliminated = self.external_data.eliminated
            quad_pen = self.external_data.quad_pen
            constr_quad_pen = self.external_data.constr_quad_pen
            Q = self.external_data.Q
            variable_lists = [eliminated, quad_pen, constr_quad_pen]
            new_eliminated = OrderedDict()
            new_quad_pen = OrderedDict()
            new_constr_quad_pen = OrderedDict()
            new_variable_lists = [new_eliminated, new_quad_pen, new_constr_quad_pen]
            for i in xrange(3):
                for name in variable_lists[i].keys():
                    var = op.getVariable(name)
                    if var is None:
                        raise CasadiCollocatorException(
                            "Measured variable %s not " % name +
                            "found in model.")
                    if var.isAlias():
                        new_name = var.getModelVariable().getName()
                    else:
                        new_name = name
                    new_variable_lists[i][new_name] = variable_lists[i][name]
            self.external_data.eliminated = new_eliminated
            self.external_data.quad_pen = new_quad_pen
            self.external_data.constr_quad_pen = new_constr_quad_pen

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
        mvar_vectors['p_opt'] = [par for par in pars
                                 if op.get_attr(par, "free")]
        n_var['p_opt'] = len(mvar_vectors['p_opt'])

        # Create named symbolic variable structure
        named_mvar_struct = OrderedDict()
        named_mvar_struct["time"] = [op.getTimeVariable()]
        named_mvar_struct["x"] = [mvar.getVar() for mvar in mvar_vectors['x']]
        named_mvar_struct["unelim_u"] = \
            [mvar.getVar() for mvar in
             mvar_vectors['u'][unelim_input_indices]]
        named_mvar_struct["w"] = [mvar.getVar() for mvar in mvar_vectors['w']]
        named_mvar_struct["p_opt"] = [mvar.getVar() for
                                      mvar in mvar_vectors['p_opt']]
        named_mvar_struct["elim_u"] = \
            [mvar.getVar() for mvar in
             mvar_vectors['u'][elim_input_indices]]
        named_mvar_struct_dx = [mvar.getVar() for mvar in mvar_vectors['dx']]
        
        # Create structure for variable elimination handling
        elimination = casadi.MX()
        for var in op.getEliminatedVariables():
            elimination.append(op.getSolutionOfEliminatedVariable(var))        
        
        # Get optimization and model expressions
        initial = op.getInitialResidual()
        dae = op.getDaeResidual()
        path = casadi.vertcat([path_c.getResidual() for
                               path_c in op.getPathConstraints()])
        point = casadi.vertcat([point_c.getResidual() for
                                point_c in op.getPointConstraints()])
        mterm = op.getObjective()
        lterm = op.getObjectiveIntegrand()



        # Append name of variables into a list
        named_vars = reduce(list.__add__, named_mvar_struct.values() +
                            [named_mvar_struct_dx])           

        # Create data structure to handle different type of variables of the dynamic problem
        mvar_struct = OrderedDict()
        mvar_struct["time"] = casadi.MX.sym("time")
        mvar_struct["x"] = casadi.MX.sym("x", n_var['x'])
        mvar_struct["dx"] = casadi.MX.sym("dx", n_var['dx'])
        mvar_struct["unelim_u"] = casadi.MX.sym("unelim_u", n_var['unelim_u'])
        mvar_struct["w"] = casadi.MX.sym("w", n_var['w'])
        mvar_struct["elim_u"] = casadi.MX.sym("elim_u", n_var['elim_u'])
        mvar_struct["p_opt"] = casadi.MX.sym("p_opt", n_var['p_opt'])
        
        # Handy ordered structure for substitution
        svector_vars=[mvar_struct["time"]]


        # Create map from name to variable index and type
        name_map = {}
        for vt in ["x", "unelim_u", "w", "p_opt", "elim_u", "dx"]:
            i = 0
            for var in mvar_vectors[vt]:
                name = var.getName()
                name_map[name] = (i, vt)
                svector_vars.append(mvar_struct[vt][i])
                i = i + 1
        
        # Add names to the eliminated variables
        i = 0
        for var in op.getEliminatedVariables():
            name = var.getName()
            name_map[name] = (i, "elim_var")
            i = i + 1

        # Substitute named variables with vector variables in expressions
        s_op_expressions = [initial, dae, path, mterm, lterm, elimination]
        [initial, dae, path, mterm, lterm, elimination] = casadi.substitute(
            s_op_expressions
            , named_vars, svector_vars)        
        self.mvar_struct = mvar_struct
        

        # Create BlockingFactors from self.blocking_factors
        if isinstance(self.blocking_factors, Iterable):
            factors = dict(zip(
                    [var.getName() for var in mvar_vectors['unelim_u']],
                    n_var['unelim_u'] * [self.blocking_factors]))
            self.blocking_factors = BlockingFactors(factors)

        # Store expressions and variable structures
        self.initial = initial
        self.dae = dae
        self.path = path
        self.point = point
        self.mterm = mterm
        self.lterm = lterm
        self.mvar_vectors = mvar_vectors
        self.n_var = n_var
        self.name_map = name_map
        self.elimination = elimination

    def _scale_variables(self):
        """
        Traditional variables scaling if there are no nominal trajectories.

        Timed variables are not scaled until _create_constraints, at
        which point the constraint points are known.
        """
        # Scale variables
        if self.variable_scaling and self.nominal_traj is None:
            # Fetch scaling factors
            sf = {}
            scaled_vars={}
            list_struct=list()
            list_scaled_vars=list()
            var_kinds = ["x", "unelim_u", "w", "p_opt", "dx"]
            for vk in var_kinds:
                sf[vk] = N.array([N.abs(self.op.get_attr(v, "nominal")) for
                                  v in self.mvar_vectors[vk]])
                scaled_vars[vk] = sf[vk]*self.mvar_struct[vk]

                if self.n_var[vk]>0:
                    list_struct.append(self.mvar_struct[vk])
                    list_scaled_vars.append(scaled_vars[vk])
                    
                # Check for zero nominal values
                zero_sf_indices = N.where(sf[vk] == 0.0)[0]
                if len(zero_sf_indices) > 0:
                    names = ""
                    for i in zero_sf_indices:
                        names += self.mvar_vectors[vk][i].getName() + ", "
                    raise CasadiCollocatorException(
                        "Nominal value(s) for variable(s) %s is zero." %
                        names)
                
            # Compose scaling factors
            sf["time"] = N.array([1.])
            sf["elim_u"] = N.ones(self.n_var["elim_u"])
            list_struct.append(self.mvar_struct["time"])
            list_scaled_vars.append(sf["time"]*self.mvar_struct["time"])
            if self.n_var["elim_u"]>0:
                list_struct.append(self.mvar_struct["elim_u"])
                list_scaled_vars.append(
                    sf["elim_u"]*self.mvar_struct["elim_u"])             
            self._sf = sf

            op_expressions = [self.initial, self.dae,
                              self.path, self.point,
                              self.mterm, self.lterm]
            [self.initial, self.dae, self.path, self.point, 
             self.mterm, self.lterm] = casadi.substitute(
                 op_expressions,
                 list_struct,list_scaled_vars)          

    def _define_collocation(self):
        """
        Define collocation variables.

        The variables are used for either creating the collocation constraints
        or eliminating the derivative variables.
        """
        dx_i_k = [casadi.MX.sym("dx_i_k", self.n_var["x"])]
        h_i = casadi.MX.sym("h_i")
        x_i = [casadi.MX.sym("x_i", self.n_cp + 1, self.n_var["x"])]
        der_vals_k = casadi.MX.sym("der_vals[k]", self.n_cp + 1,
                                 self.n_var["x"])
        coll_der = casadi.sumRows(x_i[0] * der_vals_k) / h_i
        coll_der = [coll_der.T]
        coll_eq = casadi.sumRows(x_i[0]*der_vals_k) - h_i*dx_i_k[0].T
        coll_eq = coll_eq.T

        collocation = {}
        collocation['coll_der'] = coll_der
        collocation['coll_eq'] = coll_eq
        collocation['dx_i_k'] = dx_i_k
        collocation['x_i'] = x_i
        collocation['der_vals_k'] = der_vals_k
        collocation['h_i'] = h_i

        self._collocation = collocation

    def _create_nlp_variables(self):
        """
        Create the NLP variables and store them in a nested dictionary.
        """
        # Set model info
        nlp_n_var = copy.copy(self.n_var)
        del nlp_n_var['u']
        del nlp_n_var['elim_u']
        if self.blocking_factors is not None:
            n_u = nlp_n_var['unelim_u']
            del nlp_n_var['unelim_u']
            n_bf_u = len(self.blocking_factors.factors)
            n_cont_u = n_u - n_bf_u
        if self.eliminate_der_var:
            del nlp_n_var['dx']
        n_popt = nlp_n_var['p_opt']
        del nlp_n_var['p_opt']
        mvar_vectors = self.mvar_vectors

        # Count NLP variables
        n_xx = n_popt
        n_xx += (1 + self.n_e * self.n_cp) * N.sum(nlp_n_var.values())
        if self.eliminate_der_var:
            n_xx += nlp_n_var['x'] # dx_1_0
        if self.blocking_factors is not None:
            n_xx += (1 + self.n_e * self.n_cp) * n_cont_u
            for factors in self.blocking_factors.factors.values():
                n_xx += len(factors)
        if not self.eliminate_cont_var:
            n_xx += (self.n_e - 1) * nlp_n_var['x']
        self.is_gauss = (self.discr == "LG")
        if self.is_gauss:
            n_xx += (self.n_e - 1) * nlp_n_var['x'] # Mesh points
            n_xx += N.sum(nlp_n_var.values()) # tf
        if self.hs == "free":
            n_xx += self.n_e

        # Create NLP variables
        xx = casadi.MX.sym("xx", n_xx)
            
        # Map with indices of variables
        var_indices=dict()
        # Map with different levels of packed mx variables
        var_map=dict()

        if self.named_vars:
            named_xx = []            

        # Contains the indices at which xx is splited
        # Those indices will let us split the xx as follows
        # [0, all_x, all_dx, all_w, all_unelimu, initial_final_points, popt, h_free]
        global_split_indices=[0]
        
        # Map with splited order
        split_map = dict()
        split_map['x'] = 0
        split_map['dx'] = 1
        split_map['w'] = 2
        split_map['unelim_u'] = 3
        split_map['init_final'] = 4
        split_map['p_opt'] = 5
        split_map['h'] = 6

        # Fill in global_split_indices structure
        for varType in ['x', 'dx', 'w', 'unelim_u']:
            if varType=='x':
                if self.discr == "LGR":
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        nlp_n_var[varType]*(self.n_cp+1)*self.n_e)
                elif self.discr == "LG":
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        nlp_n_var[varType]*(self.n_cp+2)*self.n_e)
                else:
                    raise CasadiCollocatorException(
                        "Unknown discretization scheme %s." % self.discr)
            elif varType=='unelim_u':
                if self.blocking_factors is not None:
                    count_us=(1+self.n_e * self.n_cp) * n_cont_u
                    for factors in self.blocking_factors.factors.values():
                        count_us += len(factors)
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        count_us) 
                else:
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        nlp_n_var[varType]*(self.n_cp)*self.n_e)                        
            else:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    nlp_n_var[varType]*(self.n_cp)*self.n_e)
        # Append split index for final points 
        if self.discr == "LGR":
            if self.blocking_factors is not None:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    nlp_n_var['dx']+\
                    nlp_n_var['w'])                     
            else:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    nlp_n_var['dx']+\
                    nlp_n_var['unelim_u']+\
                    nlp_n_var['w'])
        elif self.discr == "LG":
            if self.blocking_factors is not None:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    2*(nlp_n_var['dx']+\
                       nlp_n_var['w']))                    
            else:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    2*(nlp_n_var['dx']+\
                       nlp_n_var['unelim_u']+\
                       nlp_n_var['w']))
        else:
            raise CasadiCollocatorException(
                "Unknown discretization scheme %s." % self.discr)                
        # Append split index for the free parameters 
        global_split_indices.append(global_split_indices[-1]+n_popt)
        n_freeh2 = self.n_e if self.hs == "free" else 0
        # Append index for the free elements
        global_split_indices.append(global_split_indices[-1]+n_freeh2) 
        
        # Split MX variables accordingly
        global_split=casadi.vertsplit(xx,global_split_indices)
        counter_s = 0
        
        # Define the order of the loop for building the check_point map 
        if self.blocking_factors is not None:
            variable_type_list = ['x','dx','w']
        else:
            variable_type_list = ['x','dx','w','unelim_u'] 
        # Builds the check_point map
        for j,varType in enumerate(variable_type_list):
            var_map[varType] = dict()
            var_indices[varType] = dict()
            var_map[varType]['all'] = \
                      global_split[split_map[varType]]
            if nlp_n_var[varType]>0:
                add=0
                if varType=='x':
                    add=1
                    if self.discr == "LG":
                        add=2
                element_split2 = casadi.vertsplit(
                    var_map[varType]['all'],
                    nlp_n_var[varType]*(self.n_cp+add))
                # Builds element branch of the map
                for i in range(1, self.n_e+1):
                    var_map[varType][i] = dict()
                    var_map[varType][i]['all'] = element_split2[i-1]
                    var_indices[varType][i] = dict()
                    collocations_split2 = casadi.vertsplit(
                        var_map[varType][i]['all'],
                        nlp_n_var[varType])
                    discrete_points=self.n_cp 
                    move_zero=1
                    if varType=='x':
                        if self.discr == "LGR":
                            discrete_points+=1
                        else:
                            discrete_points+=2
                        move_zero=0
                    # Builds collocation branch of the map
                    for k in range(discrete_points):
                        var_map[varType][i][k+move_zero] = dict()
                        var_map[varType][i][k+move_zero]['all'] = \
                                  collocations_split2[k]
                        var_indices[varType][i][k+move_zero] = list()
                        scalar_split = casadi.vertsplit(
                            var_map[varType][i][k+move_zero]['all'])
                        # Builds the individual variables branch of the map
                        for var in mvar_vectors[varType]:
                            name = var.getName()
                            (var_index, _) = self.name_map[name]
                            var_map[varType][i][k+move_zero][var_index] = \
                                      scalar_split[var_index]
                            var_indices[varType][i][k+move_zero].append(counter_s)
                            if self.named_vars:
                                named_xx.append(
                                    casadi.SX.sym(name+'_%d_%d' % (i, k+move_zero)))
                            counter_s+=1
            else:
                # Handle the cases of empty variables
                for i in range(1, self.n_e+1):
                    var_map[varType][i] = dict()
                    var_indices[varType][i] = dict()
                    var_map[varType][i]['all'] = xx[0:0]
                    for k in range(1, self.n_cp+1):
                        var_map[varType][i][k] = dict()
                        var_indices[varType][i][k] = list()
                        var_map[varType][i][k]['all'] = xx[0:0]
                        
        if self.blocking_factors is not None:
            varType = 'unelim_u'
            # Index controls without blocking factors
            var_map[varType] = dict()
            var_indices[varType] = dict() 
            
            # Creates auxiliary list
            aux_list = [counter_s]*n_u
            
            if self.named_vars:
                u_cont_names = [
                    var.getName() for var in mvar_vectors['unelim_u']
                    if var.getName() not in
                    self.blocking_factors.factors.keys()]
            
            var_indices['u_cont'] = dict()
            for i in xrange(1, self.n_e + 1):
                var_indices['u_cont'][i]=dict()
                for k in xrange(1, self.n_cp + 1):
                    new_index = counter_s + n_cont_u
                    var_indices['u_cont'][i][k] = range(counter_s, new_index)
                    counter_s = new_index
                    if self.named_vars:
                        named_xx += [casadi.SX.sym('%s_%d_%d' % (name, i, k)) for
                                     name in u_cont_names] 

            # Create index storage for inputs with blocking factors
            var_indices['u_bf'] = dict()
            for i in xrange(1, self.n_e + 1):
                var_indices['u_bf'][i] = dict()
                for k in xrange(1, self.n_cp + 1):
                    var_indices['u_bf'][i][k]= []
                    
                    
            # Index controls with blocking factors
            for name in self.blocking_factors.factors.keys():
                element = 1
                factors = self.blocking_factors.factors[name]
                for (factor_i, factor) in enumerate(factors):
                    for i in xrange(element, element + factor):
                        for k in xrange(1, self.n_cp + 1):
                            var_indices['u_bf'][i][k].append(counter_s)
                    if self.named_vars:
                        named_xx.append(casadi.SX.sym('%s_%d' % (name, element)))
                    counter_s += 1
                    element += factor
                    
            # Weave indices for inputs with and without blocking factors
            for i in xrange(1, self.n_e + 1):
                var_indices[varType][i]=dict()
                for k in xrange(1, self.n_cp + 1):
                    i_cont = 0
                    i_bf = 0
                    indices = []
                    for var in self.mvar_vectors['unelim_u']:
                        if var.getName() in self.blocking_factors.factors:
                            indices.append(var_indices['u_bf'][i][k][i_bf])
                            i_bf += 1
                        else:
                            indices.append(var_indices['u_cont'][i][k][i_cont])
                            i_cont += 1
                    var_indices[varType][i][k] = indices                    
                del var_indices['u_bf'][i]
                del var_indices['u_cont'][i]
            
            del var_indices['u_bf']
            del var_indices['u_cont'] 
            
            # Add inputs to variable map
            for i in xrange(1, self.n_e + 1):
                var_map[varType][i] = dict()
                for k in xrange(1, self.n_cp + 1):
                    var_map[varType][i][k] = \
                        global_split[split_map['unelim_u']][
                            map(sub, var_indices[varType][i][k], 
                                aux_list)]
                    
            # Index initial controls separately if blocking_factors is not None       
            # Find indices of inputs with blocking factors
            bf_indices = []
            cont_indices = []
            for var in mvar_vectors['unelim_u']:
                name = var.getName()
                (idx, _) = self.name_map[name]
                if name in self.blocking_factors.factors:
                    bf_indices.append(idx)
                else:
                    cont_indices.append(idx)
            bf_indices = N.array(bf_indices, dtype=int)
            cont_indices = N.array(cont_indices, dtype=int)
            
            # Index initial controls with blocking factors
            var_indices['unelim_u'][1][0] = N.empty(n_u, dtype=int)
            var_indices['unelim_u'][1][0][bf_indices] = \
                [var_indices['unelim_u'][1][1][bf_i] for
                 bf_i in bf_indices]
            
            # Index initial controls without blocking factors
            new_index = counter_s + n_cont_u
            var_indices['unelim_u'][1][0][cont_indices] = \
                         range(counter_s, new_index)
            var_indices['unelim_u'][1][0] = \
                         list(var_indices['unelim_u'][1][0])
            counter_s = new_index
            
            # Insert initial controls into variable map                
            var_map['unelim_u'][1][0] = xx[var_indices['unelim_u'][1][0]]
            if self.named_vars:
                named_xx += [
                    casadi.SX.sym(var.getName() + '_1_0') for
                    var in mvar_vectors['unelim_u'] if
                    var.getName() not in self.blocking_factors.factors] 

        # Creates check_point map entry for initial points
        split_indices=[0,nlp_n_var['dx']]
        if self.blocking_factors is not None:
            varType='w'
            split_indices.append(split_indices[-1]+nlp_n_var[varType])
            inter_split=casadi.vertsplit(
                global_split[split_map['init_final']],
                nlp_n_var['dx']+\
                nlp_n_var['w'])  
            variable_type_list = ['dx','w']
        else:
            for varType in ['w','unelim_u']:
                split_indices.append(split_indices[-1]+nlp_n_var[varType])                
            inter_split=casadi.vertsplit(
                global_split[split_map['init_final']],
                nlp_n_var['dx']+\
                nlp_n_var['unelim_u']+\
                nlp_n_var['w'])            
            variable_type_list = ['dx', 'w', 'unelim_u']
        
        split_init=casadi.vertsplit(inter_split[0], split_indices)
        for zt,varType in enumerate(variable_type_list):
            var_map[varType][1][0] = dict()
            var_indices[varType][1][0]=list() 
            if nlp_n_var[varType]!=0:
                var_map[varType][1][0]['all']=split_init[zt]                    
                tmp_split=casadi.vertsplit(var_map[varType][1][0]['all'])
                for var in mvar_vectors[varType]:
                    name = var.getName()
                    (var_index, _) = self.name_map[name]
                    var_map[varType][1][0][var_index] = \
                              tmp_split[var_index]
                    var_indices[varType][1][0].append(counter_s)
                    if self.named_vars:
                        named_xx.append(casadi.SX.sym(name+'_1_0'))                        
                    counter_s+=1
            else:
                var_map[varType][1][0]['all']=xx[0:0]
                           
        # Creates check_point map entry for final points
        if self.discr == "LG":
            split_end=casadi.vertsplit(inter_split[1], split_indices)
            ii=self.n_e
            kk=self.n_cp+1 
            for zt,varType in enumerate(variable_type_list):
                var_map[varType][ii][kk] = dict()
                var_indices[varType][ii][kk]=list()
                if nlp_n_var[varType]!=0:
                    var_map[varType][ii][kk]['all']=split_end[zt]
                    tmp_split=casadi.vertsplit(
                        var_map[varType][ii][kk]['all'])
                    for var in mvar_vectors[varType]:
                        name = var.getName()
                        (var_index, _) = self.name_map[name]
                        var_map[varType][ii][kk][var_index] = \
                                  tmp_split[var_index]
                        var_indices[varType][ii][kk].append(counter_s)
                        if self.named_vars:
                            named_xx.append(
                                casadi.SX.sym(name+'_%d_%d' % (ii, kk)))                             
                        counter_s+=1
                else:
                    var_map[varType][ii][kk]['all']=xx[0:0]

        # Creates check_point map entry parameters
        var_map['p_opt'] = dict()
        var_map['p_opt']['all'] = \
                  global_split[split_map['p_opt']]
        var_indices['p_opt']=range(counter_s,counter_s+n_popt)
        if n_popt!=0:
            tmp_split=casadi.vertsplit(var_map['p_opt']['all'])
            for par in mvar_vectors['p_opt']:
                name = par.getName()
                (var_index, _) = self.name_map[name] 
                var_map['p_opt'][var_index] = tmp_split[var_index]
                if self.named_vars:
                    named_xx.append(casadi.SX.sym(name))
                counter_s+=1
                                   
        # Creates check_point map entry free elements
        var_map['h'] = dict()
        var_map['h']['all'] = \
                  global_split[split_map['h']]
        var_indices['h']=range(counter_s,counter_s+n_freeh2)
        if n_freeh2!=0:
            tmp_split=casadi.vertsplit(var_map['h']['all'])
            for i in range(self.n_e):
                var_map['h'][i+1] = tmp_split[i]
                if self.named_vars:
                    named_xx.append(casadi.SX.sym('h_%d' % i+1))
                counter_s+=1                     

        # Update h_i for free elements length
        if self.hs == "free":
            var_indices['h'] =[ N.nan ]+ var_indices['h']
            self.h = casadi.vertcat([N.nan,var_map['h']['all']])        

        assert(counter_s == n_xx)
        if self.named_vars:
            assert(len(named_xx) == n_xx)
        
        # Save variables and indices as data attributes
        self.xx = xx
        if self.named_vars:
            self.named_xx = casadi.vertcat(named_xx)
            
        self.global_split_indices = global_split_indices
        self.n_xx = n_xx
        self.var_map = var_map
        self.var_indices = var_indices
    
    def _create_nlp_parameters(self):
        """
        Substitute parameter symbols in expressions for new parameter symbols,
        and save their values.
        """
        # Get parameter values and symbols
        par_vars = [par.getVar() for par in self.mvar_vectors['p_fixed']]
        par_vals = [self.op.get_attr(par, "_value")
                    for par in self.mvar_vectors['p_fixed']]
        self._par_vals = N.array(par_vals).reshape(-1)

        #Create parameter symbols        
        self.pp = casadi.MX.sym("par", len(par_vars), 1)
        self.pp_list = []

        #Add parameters to variable dictionaries and create list with parameter 
        #symbols (the list is needed for the substitution below).
        #Note: For parameters the var_indices dictionary gives the index in 
        #self.pp (and not self.xx).  
        i=0
        for para in par_vars:
            self.pp_list.append(self.pp[i])
            self.var_indices[para.getName()] = i
            self.var_map[para.getName()] = self.pp[i]
            i+=1

        #Create list of parameter names
        if self.named_vars:
            named_pp = []
            for para in par_vars:
                named_pp.append(casadi.SX.sym(para.getName()))
            self.named_pp = casadi.vertcat(named_pp)

        #Substitute old parameter symbols for new parameter symbols
        op_expressions = [self.initial, self.dae, self.path, self.point,
                        self.mterm, self.lterm, self.elimination]
        [self.initial,
         self.dae,
         self.path,
         self.point,
         self.mterm,
         self.lterm,
         self.elimination] = casadi.substitute(op_expressions, par_vars, self.pp_list)
        

    def _get_z_l0(self,i,k,with_der=True):
        """
        Returns a vector with all the NLP variables at a collocation point.

        Parameters::

            i --
                Element index.
                Type: int

            k --
                Collocation point.
                Type: int

            with_der --
                Appends the derivatives to the returning vector

        Returns::

            z --
                NLP variable vector.
                Type: MX or SX
        """
        keys = copy.copy(self.mvar_struct.keys())
        del keys[0] #removes time
        del keys[-1] #removes parameters

        if with_der:
            var_kinds = keys
        else:
            del keys[1]
            var_kinds = keys
        if self._normalize_min_time:
            z = [self.time_points[i][k]*(self._denorm_tf-self._denorm_t0)]
        else:
            z = [self.time_points[i][k]]
        z.append(self.pp)
        for vk in var_kinds:
            if self.n_var[vk]>0:
                if self.blocking_factors is None:
                    z.append(self.var_map[vk][i][k]['all'])
                else:
                    if vk != 'unelim_u':
                        z.append(self.var_map[vk][i][k]['all'])
                    else:
                        z.append(self.var_map[vk][i][k])
        return z

    def _get_z_l1(self,i,with_der=True):
        """
        Returns a vector with all the NLP variables at a collocation point.

        Parameters::

            i --
            Element index.
            Type: int

            with_der --
            Appends the derivatives to the returning vector

        Returns::

            z --
            NLP variable vector.
            Type: MX or 
        """
        keys = copy.copy(self.mvar_struct.keys())
        del keys[0]
        del keys[-1]

        if with_der:
            var_kinds = keys
        else:
            del keys[1]
            var_kinds = keys
        times=[self.time_points[i][k] for k in range(1, self.n_cp+1)]
        if self._normalize_min_time:
            times *= (self._denorm_tf-self._denorm_t0) 
        z=[casadi.MX(times)]
        z.append(self.pp)
        for vk in var_kinds:
            if self.n_var[vk]>0:
                z.append(self.var_map[vk][i]['all'])
        return z

    def _compute_time_points(self):
        """
        Return a vector with the corresponding times at the collocation points

        Returns::

            time --
                time vector.
                Type float
        """
        # Calculate time points
        self.time_points = {}
        time = []
        i = 1
        self.time_points[i] = {}
        t = self.t0
        self.time_points[i][0] = t
        time.append(t)
        ti = t # Time at start of element
        for k in xrange(1, self.n_cp + 1):
            t = ti + self.horizon * self.h[i] * self.pol.p[k]
            self.time_points[i][k] = t
            time.append(t)
        for i in xrange(2, self.n_e + 1):
            self.time_points[i] = {}
            ti = (self.time_points[i - 1][self.n_cp] +
                  (1. - self.pol.p[self.n_cp]) * self.horizon * self.h[i])
            for k in xrange(1, self.n_cp + 1):
                t = ti + self.horizon * self.h[i] * self.pol.p[k]
                self.time_points[i][k] = t
                time.append(t)
        if self.is_gauss:
            i = self.n_e
            ti = (self.time_points[i - 1][self.n_cp] +
                  (1. - self.pol.p[self.n_cp]) * self.horizon * self.h[i])
            t = ti + self.horizon * self.h[i]
            self.time_points[i][self.n_cp + 1] = t
            time.append(t)
        if self.hs != "free":
            assert(N.allclose(time[-1], self.tf))

        return time

    def _compute_collocation_constrained_points(self,time):
        """
        Create dictionary for the collocation points with timed variables.

        Parameters::

            time --
                  Vector with all the time points
                  Type: list(float)

        Returns::

             collocation_constraint_points --
                                            dictionary with the timed points
                                            Type dictionary
        """
        if self.op.getTimedVariables().size > 0 and self.hs == "free":
            raise CasadiCollocatorException("Point constraints can not be " +
                                            "combined with free element " +
                                            "lengths.")
        cnstr_points_expr = [timed_var.getTimePoint() for timed_var
                             in self.op.getTimedVariables()]
        if self._normalize_min_time:
            for expr in cnstr_points_expr:
                if not self._check_linear_comb(expr):
                    raise CasadiCollocatorException(
                        "Constraint point %s is not a " % repr(expr) +
                        "convex combination of startTime and finalTime.")
            t0_var = self.op.getVariable('startTime').getVar()
            tf_var = self.op.getVariable('finalTime').getVar()

            # Map time points to constraint points
            cnstr_points_f = casadi.MXFunction(
                [t0_var, tf_var], [casadi.vertcat(cnstr_points_expr)])
            cnstr_points_f.init()
            cnstr_points_f.setInput(0., 0)
            cnstr_points_f.setInput(1., 1)
            cnstr_points_f.evaluate()
            constraint_points = cnstr_points_f.output().toArray().reshape(-1)
            constraint_points = sorted(set(constraint_points))
        else:
            constraint_points = sorted(set([self.op.evaluateExpression(expr)
                                            for expr in cnstr_points_expr]))

        collocation_constraint_points = {}
        for constraint_point in constraint_points:
            tp_index = None
            if self.is_gauss:
                time_enumeration = enumerate(time[1:-1])
            else:
                time_enumeration = enumerate(time[1:])
            for (index, time_point) in time_enumeration:
                if N.allclose(constraint_point, time_point):
                    tp_index = index
                    break
            if tp_index is None:
                if N.allclose(constraint_point, self.t0):
                    collocation_constraint_points[constraint_point] = \
                        (1, 0)
                elif (self.is_gauss and
                      N.allclose(constraint_point, self.tf)):
                    collocation_constraint_points[constraint_point] = \
                        (self.n_e, self.n_cp + 1)
                else:
                    raise CasadiCollocatorException(
                        "Constraint point " + `constraint_point` +
                        " does not coincide with a collocation point.")
            else:
                (e, cp) = divmod(tp_index, self.n_cp)
                collocation_constraint_points[constraint_point] = \
                    (e + 1, cp + 1)
        return collocation_constraint_points

    def _store_and_scale_timed_vars(self,time):
        """
        store collocation points that are constrained due to 
        timed variables.  It also scale accordingly to the 
        scaling mode the expressions that involve timed vars.
            self.path, 
            self.point, 
            self.mterm
        Parameters::

            time --
                  Vector with all the time points
                  Type: list(float)
        """
        # Map constraint points to collocation points
        nlp_timed_variables = []
        if self.hs == "free":
            timed_variables = []
        else:
            # Compute constraint points
            collocation_constraint_points=\
                self._compute_collocation_constrained_points(time)

            # Compose timed variables and corresponding scaling factors and
            # NLP variables
            timed_variables = []
            timed_variables_sfs = []
            for tv in self.op.getTimedVariables():
                timed_variables.append(tv.getVar())
                tp = tv.getTimePoint()
                if self._normalize_min_time:
                    cp = self._tp2cp(tp)
                else:
                    cp = self.op.evaluateExpression(tp)
                (i, k) = collocation_constraint_points[cp]
                name = tv.getBaseVariable().getName()
                (index, vt) = self.name_map[name]
                if self.variable_scaling and self.nominal_traj is None:
                    timed_variables_sfs.append(self._sf[vt][index])
                if vt == "elim_u":
                    raise CasadiCollocatorException(
                        "Point constraints may not depend on eliminated " +
                        "input %s" % name)
                nlp_timed_variables.append(self.var_map[vt][i][k][index])

        
        # Classical scaling of timed variables
        if (self.variable_scaling and self.nominal_traj is None and
            self.hs != "free" and len(collocation_constraint_points) > 0):
            ocp_expressions = [self.path, self.point, self.mterm]
            [self.path,
             self.point,
             self.mterm] = casadi.substitute(
                 ocp_expressions, timed_variables,
                 map(operator.mul, timed_variables_sfs, timed_variables))
            
        self._timed_variables = timed_variables
        self._nlp_timed_variables = nlp_timed_variables 

    def _denormalize_times(self):
        """
        Denormalize time for minimum time problems
        """
        if self._normalize_min_time:
            t_init = {}
            t_nom = {}
            if self.init_traj is not None:
                intraj_gvd = self.init_traj.get_variable_data
            if self.nominal_traj is not None:
                nomtraj_gvd = self.nominal_traj.get_variable_data
            for t_name in ['startTime', 'finalTime']:
                t_var = self.op.getVariable(t_name)
                if self.op.get_attr(t_var, "free"):
                    if t_name == 'startTime':
                         t0_index = self.name_map.get('startTime')[0]
                         self._denorm_t0 = self.var_map['p_opt'][t0_index]
                    else:
                        tf_index = self.name_map.get('finalTime')[0]
                        self._denorm_tf = self.var_map['p_opt'][tf_index]
                    var_init_guess = self.op.get_attr(t_var, "initialGuess")
                    if self.init_traj is None:
                        t_init[t_name] = var_init_guess
                    else:
                        try:
                            data = self.init_traj.get_variable_data(t_name)
                        except VariableNotFoundError:
                            if (var_init_guess in [0., 1.]):
                                print("Warning: Could not find initial " +
                                      "guess for %s in initial " % t_name +
                                      "trajectories. Using end-point of " +
                                      "provided time horizon instead.")
                                if t_name == "startTime":
                                    t_init[t_name] = intraj_gvd("time").t[0]
                                elif t_name == "finalTime":
                                    t_init[t_name] = intraj_gvd("time").t[-1]
                                else:
                                    raise CasadiCollocatorException(
                                        "BUG: Please contact the developers.")
                            else:
                                print("Warning: Could not find initial " +
                                      "guess for %s in initial " % t_name +
                                      "trajectories. Using initialGuess " +
                                      "attribute value instead.")
                                t_init[t_name] = var_init_guess
                        else:
                            t_init[t_name] = data.x[0]
                    if self.nominal_traj is None:
                        t_nom[t_name] = self.op.get_attr(t_var, "nominal")
                    else:
                        try:
                            mode = self.nominal_traj_mode[t_name]
                        except KeyError:
                            mode = self.nominal_traj_mode["_default_mode"]
                        if mode == "attribute":
                            t_nom[t_name] = self.op.get_attr(t_var, "nominal")
                        else:
                            try:
                                data = self.nominal_traj.get_variable_data(
                                    t_name)
                            except VariableNotFoundError:
                                print("Warning: Could not find nominal " +
                                      "value for %s in nominal t" % t_name +
                                      "rajectories. Using end-point of " +
                                      "provided time horizon instead.")
                                if t_name == "startTime":
                                    t_nom[t_name] = nomtraj_gvd("time").t[0]
                                elif t_name == "finalTime":
                                    t_nom[t_name] = nomtraj_gvd("time").t[-1]
                                else:
                                    raise CasadiCollocatorException(
                                        "BUG: Please contact the developers.")
                            else:
                                t_nom[t_name] = data.x[0]
                else:
                    t_init[t_name] = self.op.get_attr(t_var, "start")
                    t_nom[t_name] = self.op.get_attr(t_var, "start")
                    if t_name == 'startTime':
                        self._denorm_t0 = self.t0
                    else: 
                        self._denorm_tf = self.tf
            self._denorm_t0_init = t_init["startTime"]
            self._denorm_tf_init = t_init["finalTime"]
            self._denorm_t0_nom = t_nom["startTime"]
            self._denorm_tf_nom = t_nom["finalTime"]

    def _create_nominal_trajectories(self):
        """
        Returns a dictionary that contains the trajectories. Must be called after time has 
        been denormalized and self._denorm_t0_init etc have been set

        Returns::

             nom_traj --
                    dictionary with all trajectories
                    Type dictionary
        """
        # Create nominal trajectories
        mvar_vectors = self.mvar_vectors
        name_map = self.name_map
        nom_traj = {}
        if self.variable_scaling and self.nominal_traj is not None:
            n = len(self.nominal_traj.get_data_matrix()[:, 0])
            for vt in ["dx", 'x', 'unelim_u', 'w']:
                nom_traj[vt] = {}
                for var in mvar_vectors[vt]:
                    data_matrix = N.empty([n, len(mvar_vectors[vt])])
                    name = var.getName()
                    (var_index, _) = name_map[name]
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        # It is possibly to treat missing variable trajectories
                        # more efficiently, especially in the case of MX
                        print("Warning: Could not find nominal trajectory " +
                              "for variable " + name + ". Using nominal " +
                              "attribute value instead.")
                        self.nominal_traj_mode[name] = "attribute"
                        abscissae = N.array([0])
                        nom_val = self.op.get_attr(var, "nominal")
                        constant_sf = N.abs(nom_val)
                        ordinates = N.array([[constant_sf]])
                    else:
                        abscissae = data.t
                        ordinates = data.x.reshape([-1, 1])
                    nom_traj[vt][var_index] = \
                        TrajectoryLinearInterpolation(abscissae, ordinates)
        return nom_traj

    def _create_trajectory_scaling_factor_structures(self):
        """
        Define structures for trajectory scaling. Structures that are
        used to scale the level0 functions.
        """
        if self.variable_scaling and self.nominal_traj is not None:
            # Create nominal trajectories
            nom_traj = self._create_nominal_trajectories()
            if self._normalize_min_time:
                t0_nom = self._denorm_t0_nom
                tf_nom = self._denorm_tf_nom

            # Create storage for scaling factors
            time_points = self.get_time_points()
            n_var = copy.copy(self.n_var)
            is_variant = {}
            n_variant_var = 0
            n_invariant_var = 0
            n_variant_dx = 0
            n_variant_x = 0
            variant_sf = {}
            invariant_d = []
            invariant_e = []
            variant_timed_var = []
            variant_timed_sf = []
            name_idx_sf_map = {}
            self._is_variant = is_variant
            self._variant_sf = variant_sf
            self._invariant_d = invariant_d
            self._invariant_e = invariant_e
            self._name_idx_sf_map = name_idx_sf_map
            for i in xrange(1, self.n_e + 1):
                variant_sf[i] = {}
                for k in time_points[i]:
                    variant_sf[i][k] = []

            # Evaluate trajectories to generate scaling factors
            for vt in ['dx', 'x', 'unelim_u', 'w']:
                for var in self.mvar_vectors[vt]:
                    name = var.getName()
                    (var_index, _) = self.name_map[name]
                    try:
                        mode = self.nominal_traj_mode[name]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    values = {}
                    traj_min = N.inf
                    traj_max = -N.inf
                    for i in xrange(1, self.n_e + 1):
                        values[i] = {}
                        for k in time_points[i]:
                            tp = time_points[i][k]
                            if self._normalize_min_time:
                                tp = t0_nom + (tf_nom - t0_nom) * tp
                            val = float(nom_traj[vt][var_index].eval(tp))
                            values[i][k] = val
                            if val < traj_min:
                                traj_min = val
                            if val > traj_max:
                                traj_max = val
                    if mode in ["attribute", "linear", "affine"]:
                        variant = False
                    elif mode == "time-variant":
                        variant = True
                        if (traj_min < 0 and traj_max > 0 or
                            traj_min == 0 or traj_max == 0):
                            variant = False
                        if variant:
                            traj_abs = N.abs([traj_min, traj_max])
                            abs_min = traj_abs.min()
                            abs_max = traj_abs.max()
                            if abs_min < 1e-3 and abs_max / abs_min > 1e6:
                                variant = False
                        if not variant:
                            if (self.nominal_traj_mode["_default_mode"] == 
                                "time-variant"):
                                variant = False
                                print("Warning: Could not do time-variant " + 
                                      "scaling for variable %s. " % name +
                                      "Doing time-invariant affine scaling " +
                                      "instead.")
                            else:
                                raise CasadiCollocatorException(
                                    "Could not do time-variant scaling for " +
                                    "variable %s." % name)
                    else:
                        raise CasadiCollocatorException(
                            "Unknown scaling mode %s " % mode +
                            "for variable %s." % name)
                    (idx, vt) = self.name_map[name]
                    if variant:
                        if vt == "x":
                            n_variant_x += 1
                        if vt == "dx":
                            n_variant_dx += 1
                        is_variant[name] = True
                        name_idx_sf_map[name] = n_variant_var
                        n_variant_var += 1
                        for i in xrange(1, self.n_e + 1):
                            for k in time_points[i]:
                                variant_sf[i][k].append(N.abs(values[i][k]))
                    else:
                        is_variant[name] = False
                        if mode == "attribute":
                            d = N.abs(self.op.get_attr(var, "nominal"))
                            if d == 0.0:
                                raise CasadiCollocatorException(
                                    "Nominal value for " +
                                    "%s is zero." % name)
                            e = 0.
                        elif mode == "linear":
                            d = max([abs(traj_max), abs(traj_min)])
                            if d == 0.0:
                                d = N.abs(self.op.get_attr(var, "nominal"))
                                print("Warning: Nominal trajectory for " +
                                      "variable %s is identically " % name + 
                                      "zero. Using nominal attribute instead.")
                                if d == 0.0:
                                    raise CasadiCollocatorException(
                                        "Nominal value for " +
                                        "%s is zero." % name)
                            e = 0.
                        elif mode in ["affine", "time-variant"]:
                            if N.allclose(traj_max, traj_min):
                                if (self.nominal_traj_mode["_default_mode"] in 
                                    ["affine", "time-variant"]):
                                    print("Warning: Could not do affine " +
                                          "scaling for variable %s. " % name + 
                                          "Doing linear scaling instead.")
                                else:
                                    raise CasadiCollocatorException(
                                        "Could not do affine scaling " +
                                        "for variable %s." % name)
                                d = max([abs(traj_max), abs(traj_min)])
                                if d == 0.:
                                    print("Warning: Nominal trajectory for " +
                                          "variable %s is " % name + 
                                          "identically zero. Using nominal " +
                                          "attribute instead.")
                                    d = N.abs(self.op.get_attr(var, "nominal"))
                                    if d == 0.:
                                        raise CasadiCollocatorException(
                                            "Nominal value for " +
                                            "%s is zero." % name)
                                else:
                                    d = max([abs(traj_max), abs(traj_min)])
                                e = 0.
                            else:
                                d = traj_max - traj_min
                                e = traj_min
                        name_idx_sf_map[name] = n_invariant_var
                        n_invariant_var += 1
                        invariant_d.append(d)
                        invariant_e.append(e)

            # Do not scaled eliminated inputs
            for var in self.mvar_vectors['elim_u']:
                name = var.getName()
                (idx, vt) = self.name_map[name]
                is_variant[name] = False
                d = 1.
                e = 0.
                name_idx_sf_map[name] = n_invariant_var
                n_invariant_var += 1
                invariant_d.append(d)
                invariant_e.append(e)

            # Handle free parameters
            for var in self.mvar_vectors['p_opt']:
                name = var.getName()
                (var_index, _) = self.name_map[name]
                is_variant[name] = False
                if name == "startTime":
                    d = N.abs(self._denorm_t0_nom)
                    if d == 0.:
                        d = 1.
                    e = 0.
                elif name == "finalTime":
                    d = N.abs(self._denorm_tf_nom)
                    if d == 0.:
                        d = 1.
                    e = 0.
                else:
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        print("Warning: Could not find nominal trajectory " +
                              "for variable " + name + ". Using nominal " +
                              "attribute value instead.")
                        nom_val = self.op.get_attr(var, "nominal")
                        d = N.abs(nom_val)
                        if d == 0.:
                            raise CasadiCollocatorException(
                                "Nominal value for %s is zero." % name)
                    else:
                        d = N.abs(data.x[0])
                        if N.allclose(d, 0.):
                            print("Warning: Nominal value for %s is " % name +
                                  "too small. Setting scaling factor to 1.")
                            d = 1.
                    e = 0.
                name_idx_sf_map[name] = n_invariant_var
                n_invariant_var += 1
                invariant_d.append(d)
                invariant_e.append(e)

            self.n_variant_var = n_variant_var
            self.n_variant_x =n_variant_x
            self.n_variant_dx =n_variant_dx
            self.n_invariant_var = n_invariant_var

    def _create_external_input_trajectories(self):
        """
        Computes the external input trajectories 
        """        
        # Create measured input trajectories
        if (self.external_data is None or
            len(self.external_data.eliminated) == 0):
            self.var_map['elim_u'] = dict()
            self.var_map['constr_u'] = dict()
            for i in xrange(1, self.n_e + 1):
                self.var_map['elim_u'][i]=dict()
                self.var_map['constr_u'][i] = dict()
                for k in self.time_points[i].keys():
                    self.var_map['elim_u'][i][k] = dict()
                    self.var_map['constr_u'][i][k] = dict()
                    self.var_map['elim_u'][i][k]['all'] = N.array([])
                    self.var_map['constr_u'][i][k]['all'] = N.array([])

        if (self.external_data is not None and
            (len(self.external_data.eliminated) +
             len(self.external_data.constr_quad_pen) > 0)):
            # Create storage of maximum and minimum values
            traj_min = OrderedDict()
            traj_max = OrderedDict()
            for name in (self.external_data.eliminated.keys() +
                         self.external_data.constr_quad_pen.keys()):
                traj_min[name] = N.inf
                traj_max[name] = -N.inf

            # Collocation points
            self.var_map['elim_u'] = dict()
            self.var_map['constr_u'] = dict()            
            for i in xrange(1, self.n_e + 1):
                self.var_map['elim_u'][i]=dict()
                self.var_map['constr_u'][i] = dict()                
                for k in self.time_points[i].keys():
                    self.var_map['elim_u'][i][k] = dict()
                    self.var_map['constr_u'][i][k] = dict()                    
                    # Eliminated inputs
                    values = []
                    for (name, data) in \
                        self.external_data.eliminated.items():
                        value = data.eval(self.time_points[i][k])[0, 0]
                        values.append(value)
                        if value < traj_min[name]:
                            traj_min[name] = value
                        if value > traj_max[name]:
                            traj_max[name] = value
                    self.var_map['elim_u'][i][k]['all'] = N.array(values)
                    for z in range(0,len(values)):
                        self.var_map['elim_u'][i][k][z] = values[z]                    

                    # Constrained inputs
                    values = []
                    for (name, data) in \
                        self.external_data.constr_quad_pen.items():
                        value = data.eval(self.time_points[i][k])[0, 0]
                        values.append(value)
                        if value < traj_min[name]:
                            traj_min[name] = value
                        if value > traj_max[name]:
                            traj_max[name] = value
                    self.var_map['constr_u'][i][k]['all'] = N.array(values)
                    for z in range(0,len(values)):
                        self.var_map['constr_u'][i][k][z] = values[z]                    

            # Check that constrained and eliminated inputs satisfy their bounds
            for var_name in (self.external_data.eliminated.keys() +
                             self.external_data.constr_quad_pen.keys()):
                var = self.op.getVariable(var_name)
                var_min = self.op.get_attr(var, "min")
                var_max = self.op.get_attr(var, "max")
                if traj_min[var_name] < var_min:
                    raise CasadiCollocatorException(
                        "The trajectory for the measured input " + var_name +
                        " does not satisfy the input's lower bound.")
                if traj_max[var_name] > var_max:
                    raise CasadiCollocatorException(
                        "The trajectory for the measured input " + var_name +
                        " does not satisfy the input's upper bound.")



    def _define_l0_functions(self):
        """
        Defines all functions required for the DOP transcription
        
        Declares the level0 constraints and cost terms as casadi functions.
        path constraints
              self.G_e_l0_fcn
              self.G_i_l0_fcn
        point constraints
              self.g_e_l0_fcn
              selfg_i_l0_fcn
        Collocation equation
              self.coll_l0_eq_fcn -> it has a different signature
        Initial function
              self.initial_l0_fcn
        DAE residual
              self.dae_l0_fcn
        Mayer term
              self.mtem_l0_fcn
        Lagrange Term
              self.lterm_l0_fcn 

        The signature of the functions is 
        f(["x", "dx", "unelim_u", "w", "elim_u", "p_opt"]+["scaling_factor_list"])

        if one of the arguments has dimension zero (n_var[vt]=0) then 
        it is skipped and not passed as an argument. The same applies to
        scaling_factor_list if the time_variant scaling mode is not activated

        First, the expressions are scaled accordingly to the scaling
        mode option and then the casadi functions are created and stored
        as attributes of the class. The scaling is also done for the cost 
        expressions, thus this function must be called before the 
        define_cost_ter

        """
        #defines the symbolic input
        s_sym_input = [self.mvar_struct["time"]]
        s_sym_input_no_der = [self.mvar_struct["time"]]
        s_sym_input.append(self.pp)
        s_sym_input_no_der.append(self.pp)
        var_kinds_ordered =copy.copy(self.mvar_struct.keys())
        del var_kinds_ordered[0]
        for vk in var_kinds_ordered:
            if self.n_var[vk]>0:
                s_sym_input.append(self.mvar_struct[vk])
                if vk!="dx":
                    s_sym_input_no_der.append(self.mvar_struct[vk])

        #collocation symbolics
        dx_i_k = self._collocation['dx_i_k']
        x_i = self._collocation['x_i']
        der_vals_k = self._collocation['der_vals_k']
        h_i = self._collocation['h_i']
        scoll_eq = self._collocation['coll_eq']
        scoll_der = self._collocation['coll_der']        
        if not self.variable_scaling or self.nominal_traj is None:
            self._eliminate_der_var()
            initial_fcn = self._FXFunction(s_sym_input,
                                           [self.initial])
            if self.eliminate_der_var:
                print "TODO define input for no derivative mode daeresidual"
                raise NotImplementedError("eliminate_der_ver not supported yet")
            else:
                coll_eq_fcn = casadi.MXFunction(
                    x_i + [der_vals_k, h_i] + dx_i_k, [scoll_eq])
                coll_eq_fcn.init()
                self.coll_l0_eq_fcn = coll_eq_fcn
                dae_fcn = self._FXFunction(s_sym_input,
                                           [self.dae])
        else:
            # Compose scaling factors for collocation equations
            x_i_d = self.n_var['x'] * [None]
            x_i_e = self.n_var['x'] * [None]
            x_i_sf = casadi.MX.sym("x_i_sf", self.n_cp + 1, self.n_variant_x)
            dx_i_k_d = self.n_var['dx'] * [None]
            dx_i_k_e = self.n_var['dx'] * [None]
            dx_i_k_sf = casadi.MX.sym("dx_i_sf", self.n_variant_dx)
            sn_cp_ones = N.ones((self.n_cp + 1, 1))            
            var_x_idx = 0
            var_dx_idx = 0
            for var in self.mvar_vectors['x']:
                # State
                x_name = var.getName()
                (ind, _) = self.name_map[x_name]
                if self._is_variant[x_name]:
                    x_i_d[ind] = x_i_sf[:, var_x_idx]
                    x_i_e[ind] = 0. * sn_cp_ones
                    var_x_idx += 1
                else:
                    x_sf_index = self._name_idx_sf_map[x_name]
                    x_i_d[ind] = self._invariant_d[x_sf_index] * sn_cp_ones
                    x_i_e[ind] = self._invariant_e[x_sf_index] * sn_cp_ones

                # State derivative
                dx_name = var.getMyDerivativeVariable().getName()
                (ind, _) = self.name_map[dx_name]
                if self._is_variant[dx_name]:
                    dx_i_k_d[ind] = dx_i_k_sf[var_dx_idx]
                    dx_i_k_e[ind] = 0.                    
                    var_dx_idx += 1
                else:
                    dx_sf_index = self._name_idx_sf_map[dx_name]
                    dx_i_k_d[ind] = self._invariant_d[dx_sf_index]
                    dx_i_k_e[ind] = self._invariant_e[dx_sf_index]                    

            # Scale collocation equations
            x_i_d = casadi.horzcat(x_i_d)
            x_i_e = casadi.horzcat(x_i_e)
            s_unscaled_var = list(x_i)
            s_scaled_var = [x_i_d * x_i[0] + x_i_e]            

            if self.eliminate_der_var:
                print "TODO collocation inlining derivative"
                raise NotImplementedError("eliminate_der_var not supported yet")
            else:
                s_unscaled_var.append(dx_i_k[0])
                dx_i_k_d = casadi.vertcat(dx_i_k_d)
                dx_i_k_e = casadi.vertcat(dx_i_k_e)    
                s_scaled_var.append(dx_i_k_d * dx_i_k[0] + dx_i_k_e)
                [scoll_eq] = casadi.substitute([scoll_eq], s_unscaled_var,
                                               s_scaled_var)                

            # Compose scaling factors for other expressions           
            sym_sf = casadi.MX.sym("d_i_k", self.n_variant_var)
            self._sym_sf = sym_sf            
            sz_d = {}
            sz_e = {}
            sz_d["time"]=1.
            sz_e["time"]=0.            
            for vk in ["x", "dx", "unelim_u", "w", "elim_u", "p_opt"]:
                if self.n_var[vk]>0:
                    sz_d[vk] = self.n_var[vk]*[1]
                    sz_e[vk] = self.n_var[vk]*[0.]
                    for var in self.mvar_vectors[vk]:
                        name = var.getName()
                        sf_idx = self._name_idx_sf_map[name]
                        (var_index, _) = self.name_map[name] 
                        if self._is_variant[name]:
                            sz_d[vk][var_index] = sym_sf[sf_idx]
                        else:
                            sz_d[vk][var_index] = self._invariant_d[sf_idx]
                            sz_e[vk][var_index] = self._invariant_e[sf_idx]

            # Compose scaling factors for timed variables
            timed_var_d = []
            timed_var_e = []
            for tv in self.op.getTimedVariables():
                base_name = tv.getBaseVariable().getName()
                sf_idx = self._name_idx_sf_map[base_name]
                if self._is_variant[base_name]:
                    tp = tv.getTimePoint()
                    if self._normalize_min_time:
                        cp = self._tp2cp(tp)
                    else:
                        cp = self.op.evaluateExpression(tp)
                    (i, k) = collocation_constraint_points[tp]
                    timed_var_d.append(self._variant_sf[i][k][sf_idx])
                    timed_var_e.append(0.)
                else:
                    timed_var_d.append(self._invariant_d[sf_idx])
                    timed_var_e.append(self._invariant_e[sf_idx])

            # Scale variables in expressions
            scaled_timed_var = map(
                operator.add,
                map(operator.mul, timed_var_d, self._timed_variables),
                timed_var_e)

            s_scaled_z = [sz_d["time"] * \
                          self.mvar_struct["time"] +\
                          sz_e["time"]]
            s_unscaled_z = [self.mvar_struct["time"]]
            for vk in ["x", "dx", "unelim_u", "w", "elim_u", "p_opt"]:
                if self.n_var[vk]>0:
                    s_scaled_z.append(
                        casadi.vertcat(sz_d[vk]) *\
                        self.mvar_struct[vk]+\
                        casadi.vertcat(sz_e[vk]))
                    s_unscaled_z.append(self.mvar_struct[vk])

            s_scaled_var = s_scaled_z + scaled_timed_var
            s_unscaled_var = s_unscaled_z + self._timed_variables

            s_ocp_expressions = [self.initial, self.dae, 
                                 self.path, self.point,
                                 self.mterm, self.lterm]
            s_scaled_expressions = casadi.substitute(s_ocp_expressions,
                                                     s_unscaled_var,
                                                     s_scaled_var)
            # Scale variables in expressions
            if self.eliminate_der_var:
                print "TODO scaling for the additional constraints elim_der_var"
                raise NotImplementedError("eliminate_der_var not supported yet")                

            else:
                [self.initial, self.dae,
                 self.path, self.point,
                 self.mterm, self.lterm] = s_scaled_expressions

            # Create functions
            if self.n_variant_var>0:
                initial_fcn = self._FXFunction(
                    s_sym_input + [sym_sf], [self.initial])
            else:
                initial_fcn = self._FXFunction(
                    s_sym_input, [self.initial])
                
            if self.eliminate_der_var:
                print "TODO define input for function with no derivatives"
                raise NotImplementedError("eliminate_der_var not supported yet") 
            else:
                if self.n_variant_x>0 and self.n_variant_dx>0:
                    coll_eq_fcn = casadi.MXFunction(
                        x_i + [der_vals_k, h_i] + dx_i_k +
                        [x_i_sf, dx_i_k_sf], [scoll_eq])
                elif self.n_variant_x>0 and not self.n_variant_dx>0:
                    coll_eq_fcn = casadi.MXFunction(
                        x_i + [der_vals_k, h_i] + dx_i_k +
                        [x_i_sf], [scoll_eq])  
                elif not self.n_variant_x>0 and self.n_variant_dx>0:
                    coll_eq_fcn = casadi.MXFunction(
                        x_i + [der_vals_k, h_i] + dx_i_k +
                        [dx_i_k_sf], [scoll_eq])  
                else:
                    coll_eq_fcn = casadi.MXFunction(
                        x_i + [der_vals_k, h_i] + dx_i_k, [scoll_eq])  

                coll_eq_fcn.setOption("name", "coll_l0_eq_fcn")
                coll_eq_fcn.init()
                self.coll_l0_eq_fcn = coll_eq_fcn

                if self.n_variant_var>0:
                    dae_fcn = self._FXFunction(
                        s_sym_input + [sym_sf], [self.dae])
                else:
                    dae_fcn = self._FXFunction(
                        s_sym_input, [self.dae])

        # Initialize functions
        initial_fcn.setOption("name", "initial_l0_fcn")
        initial_fcn.init()
        self.initial_l0_fcn =  initial_fcn
        dae_fcn.setOption("name", "dae_l0_fcn")
        dae_fcn.init()
        self.dae_l0_fcn = dae_fcn

        # Manipulate and sort path constraints
        g_e = []
        g_i = []
        for (res, cnstr) in itertools.izip(self.path, self.op.getPathConstraints()):
            if cnstr.getType() == cnstr.EQ:
                g_e.append(res)
            elif cnstr.getType() == cnstr.LEQ:
                g_i.append(res)
            elif cnstr.getType() == cnstr.GEQ:
                g_i.append(-res)

        # Create path constraint functions
        s_path_constraint_input = []
        if self.eliminate_der_var:
            print "TODO define input for function with no derivatives"
            raise NotImplementedError("named_vars not supported yet") 
        else:
            s_path_constraint_input += s_sym_input
        s_path_constraint_input += self._timed_variables

        if self.variable_scaling and self.nominal_traj is not None:
            if self.n_variant_var>0:
                s_path_constraint_input.append(sym_sf)


        g_e_fcn = self._FXFunction(s_path_constraint_input,
                                   [casadi.vertcat(g_e)])
        g_i_fcn = self._FXFunction(s_path_constraint_input,
                                   [casadi.vertcat(g_i)])


        g_e_fcn.setOption("name", "g_e_l0_fcn")
        g_e_fcn.init()
        g_i_fcn.setOption("name", "g_i_l0_fcn")
        g_i_fcn.init()
        self.g_e_l0_fcn = g_e_fcn
        self.g_i_l0_fcn = g_i_fcn

        # Manipulate and sort point constraints
        G_e = []
        G_i = []
        for (res, cnstr) in itertools.izip(self.point,
                                           self.op.getPointConstraints()):
            if cnstr.getType() == cnstr.EQ:
                G_e.append(res)
            elif cnstr.getType() == cnstr.LEQ:
                G_i.append(res)
            elif cnstr.getType() == cnstr.GEQ:
                G_i.append(-res)

        # Create point constraint functions
        # Note that sym_input is needed as input since the point constraints
        # may depend on free parameters
        s_point_constraint_input = s_sym_input_no_der + self._timed_variables

        G_e_fcn = self._FXFunction(s_point_constraint_input,
                                   [casadi.vertcat(G_e)])
        G_i_fcn = self._FXFunction(s_point_constraint_input,
                                   [casadi.vertcat(G_i)])

        G_e_fcn.setOption("name", "G_e_l0_fcn")
        G_e_fcn.init()
        G_i_fcn.setOption("name", "G_i_l0_fcn")
        G_i_fcn.init()
        self.G_e_l0_fcn = G_e_fcn
        self.G_i_l0_fcn = G_i_fcn
        
        # Solution for eliminated variables NOT SCALED. CALLED AFTER RE-SCALE SOLUTION
        elimination_fcn = self._FXFunction(s_sym_input,[self.elimination])
        elimination_fcn.setOption("name","eliminated_variables_solution_fcn")
        elimination_fcn.init()
        self.elimination_fcn = elimination_fcn

        #Define cost terms
        s_sym_input = [self.mvar_struct["time"]]
        s_sym_input_no_der = [self.mvar_struct["time"]]
        s_sym_input.append(self.pp)
        s_sym_input_no_der.append(self.pp)
        for vk in ["x", "dx", "unelim_u", "w",  "elim_u",  "p_opt"]:
            if self.n_var[vk]>0:
                s_sym_input.append(self.mvar_struct[vk])
                if vk!="dx":
                    s_sym_input_no_der.append(self.mvar_struct[vk])

        # Mayer term
        if not self.mterm.isConstant() or self.mterm.getValue() != 0.:
            # Create function for evaluation of Mayer term
            s_mterm_input = s_sym_input_no_der + self._timed_variables
            mterm_fcn = self._FXFunction(s_mterm_input, [self.mterm])
            mterm_fcn.setOption("name", "mterm_l0_fcn")
            mterm_fcn.init()
            self.mtem_l0_fcn = mterm_fcn

        # Lagrange term
        if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
            # Create function for evaluation of Lagrange integrand
            if self.eliminate_der_var:
                print "TODO lagrange input no derivative mode"
                raise NotImplementedError("eliminate_der_var not supported yet")                
            else:
                s_fcn_input = s_sym_input
                s_fcn_input += self._timed_variables
            if self.variable_scaling and self.nominal_traj is not None:
                if self.n_variant_var>0:
                    s_fcn_input.append(self._sym_sf)
            lterm_fcn = self._FXFunction(s_fcn_input, [self.lterm])
            lterm_fcn.setOption("name", "lterm_l0_fcn")
            lterm_fcn.init()
            self. lterm_l0_fcn = lterm_fcn
            
        

    def _define_l1_functions(self):
        """
        Defines checkpointed functions.
        
        Declares the level1 constraints and cost terms as casadi functions.
        Collocation equation
              self.coll_l1_eq_fcn -> it has a different signature
        DAE residual
              self.dae_l1_fcn
        Lagrange Term
              self.lterm_l1_fcn 

        The signature of the functions is 
        f(["x", "dx", "unelim_u", "w", "elim_u", "p_opt"]+["scaling_factor_list"])

        if one of the arguments has dimension zero (n_var[vt]=0) then 
        it is skipped and not passed as an argument. The same applies to
        scaling_factor_list if the time_variant scaling mode is not activated

        This functions recieve variables that contain all the collocation
        points of a certain element ith. The idea consist on setting up all the 
        collocation points of a certain element by calling a single function per 
        element.
        """     
        # Define the symbolic input for level 1 functions
        l1_mvar_struct = OrderedDict()
        l1_mvar_struct["time"] = casadi.MX.sym("timel1", self.n_cp)
        additional_p = 2 if self.is_gauss else 1
        l1_mvar_struct["x"] = casadi.MX.sym("xl1", 
                                          self.n_var['x']*(self.n_cp+additional_p))
        l1_mvar_struct["dx"] = casadi.MX.sym("dxl1", 
                                           self.n_var['dx']*self.n_cp)
        l1_mvar_struct["unelim_u"] = casadi.MX.sym("unelim_u", 
                                                 self.n_var['unelim_u']*self.n_cp)
        l1_mvar_struct["w"] = casadi.MX.sym("wl1", 
                                          self.n_var['w']*self.n_cp)
        l1_mvar_struct["elim_u"] = casadi.MX.sym("elim_ul1", 
                                               self.n_var['elim_u']*self.n_cp)
        l1_mvar_struct["p_opt"] = casadi.MX.sym("p_opt_l1", self.n_var['p_opt']) 
        inputs_order_map=OrderedDict()
        inputs_order_map_no_der=OrderedDict()
        s_sym_input_l1 = [l1_mvar_struct["time"]]
        s_sym_input_l1_no_der = [l1_mvar_struct["time"]]
        s_sym_input_l1.append(self.pp)
        s_sym_input_l1_no_der.append(self.pp)
        inputs_order_map["time"]=0
        inputs_order_map_no_der["time"]=0
        inputs_order_map["parameters"]=1
        inputs_order_map_no_der["parameters"]=1
        var_kinds_ordered =copy.copy(l1_mvar_struct.keys())
        del var_kinds_ordered[0]
        counter=2
        counter2=2
        for vk in var_kinds_ordered:
            if self.n_var[vk]>0:
                s_sym_input_l1.append(l1_mvar_struct[vk])
                if vk!="dx":
                    s_sym_input_l1_no_der.append(l1_mvar_struct[vk])
                    inputs_order_map_no_der[vk]=counter2
                    counter2+=1
                inputs_order_map[vk]=counter
                counter+=1  

        # Build lists of collocation point variables
        empty_list = [[] for i in range(self.n_cp)]
        x_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["x"]], 
                                 self.n_var['x'])
        dx_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["dx"]], 
                                  self.n_var['dx'])
        unu_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["unelim_u"]], 
                                   self.n_var['unelim_u']) \
            if self.n_var['unelim_u']>0 else empty_list
        w_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["w"]], 
                                 self.n_var['w']) \
            if self.n_var['w']>0 else empty_list 
        elu_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["elim_u"]], 
                                   self.n_var['elim_u']) \
            if self.n_var['elim_u']>0 else empty_list
        no_boundaries_x_col = list(copy.copy(x_col))
        del no_boundaries_x_col[0]
        if self.is_gauss:
            del no_boundaries_x_col[-1]
        x_col = [[x_col[k]] for k in range(self.n_cp+additional_p)]
        dx_col = [[dx_col[k]] for k in range(self.n_cp)]
        unu_col = [[unu_col[k]] for k in range(self.n_cp)] \
            if self.n_var['unelim_u']>0 else unu_col
        w_col = [[w_col[k]] for k in range(self.n_cp)] \
            if self.n_var['w']>0 else w_col
        elu_col = [[elu_col[k]] for k in range(self.n_cp)] \
            if self.n_var['elim_u']>0 else elu_col        
        no_boundaries_x_col = [[no_boundaries_x_col[k]] for k in range(self.n_cp)]
        time_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["time"]])
        time_col = [[time_col[k]] for k in range(self.n_cp)]

        # Create gauss quadrature weights symbolic variable
        sym_g_weights = casadi.MX.sym("Gauss_wj", self.n_cp)

        # Create parameters symbolic variable
        p_opt=[l1_mvar_struct["p_opt"]] if self.n_var['p_opt']>0 else []

        # Prepare input for collocation equation (level 0 functions)
        no_rboundary_x = casadi.vertsplit(
            s_sym_input_l1[inputs_order_map["x"]], 
            self.n_var['x']*(self.n_cp+1))
        x_i = [casadi.reshape(no_rboundary_x[0], (self.n_var["x"], self.n_cp + 1)).T]
        element_der_vals = casadi.MX.sym(
            "der_vals_l1", self.n_var["x"]*(self.n_cp + 1)*(self.n_cp))
        der_vals_col = casadi.vertsplit(element_der_vals,
                                        self.n_var["x"]*(self.n_cp + 1))
        der_vals_col = [[casadi.reshape(der_vals_col[k],
                                        (self.n_var["x"], self.n_cp + 1)).T]
                        for k in range(self.n_cp)]
        h_i = casadi.MX.sym("h_i")
        dx_i = casadi.MX.sym("dx_i_k", self.n_var["x"]*(self.n_cp))
        dx_i_col = casadi.vertsplit(dx_i, self.n_var["x"])
        dx_i_col = [[dx_i_col[k]] for k in range(self.n_cp)]

        if not self.variable_scaling or self.nominal_traj is None:
            if self.eliminate_der_var:
                print "TODO define input for no derivative mode daeresidual with check_point"
                raise NotImplementedError("eliminate_der_ver not supported yet with check_point")
            else:
                # Define functions output
                output_dae_element = list()
                output_coll_element = list()
                lagTerms = list()
                for k in range(self.n_cp):
                    # Call level0 DAEResidual
                    input_l0_fcn = time_col[k]+[self.pp]+no_boundaries_x_col[k]\
                        +dx_col[k]+unu_col[k]+w_col[k]+elu_col[k]+p_opt
                    [dae_k] = self.dae_l0_fcn.call(input_l0_fcn)
                    output_dae_element.append(dae_k)
                    # Call level0 Collocations
                    input_l0_coll_fcn = x_i + der_vals_col[k] + \
                        [h_i] + dx_i_col[k]
                    [coll_k] = self.coll_l0_eq_fcn.call(input_l0_coll_fcn)
                    output_coll_element.append(coll_k)
                    if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                        # Call level0 lagrange
                        input_l0_fcn += self._timed_variables
                        [lag_k] = self.lterm_l0_fcn.call(input_l0_fcn)
                        lagTerms.append(lag_k)

                # Define DAEResideual level1
                input_dae_l1 = s_sym_input_l1
                output_dae_element = casadi.vertcat(output_dae_element)
                dae_l1_fcn = casadi.MXFunction(input_dae_l1,
                                               [output_dae_element])
                dae_l1_fcn.setOption("name", "dae_l1_fcn")
                dae_l1_fcn.init()
                self.dae_l1_fcn = dae_l1_fcn

                # Define Collocation equation level1
                output_coll_element = casadi.vertcat(output_coll_element)
                coll_eq_l1_fcn = casadi.MXFunction([l1_mvar_struct["x"]]\
                                                   +[element_der_vals,h_i]\
                                                   +[dx_i],
                                                   [output_coll_element])
                coll_eq_l1_fcn.setOption("name", "coll_l1_eq_fcn")
                coll_eq_l1_fcn.init()                
                self.coll_eq_l1_fcn = coll_eq_l1_fcn

                if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                    # Define Lagrange term level1
                    lagTerms= casadi.horzcat(lagTerms)
                    output_lag_element = casadi.mul(lagTerms, sym_g_weights)
                    input_lterm_l1 = [sym_g_weights]
                    input_lterm_l1 += s_sym_input_l1
                    input_lterm_l1 += self._timed_variables
                    lterm_l1 = casadi.MXFunction(input_lterm_l1,
                                                 [output_lag_element])
                    lterm_l1.setOption("name", "lterm_l1_fcn")
                    lterm_l1.init()
                    self.lterm_l1 = lterm_l1
        else:
            # Define symbolic scaling factors for dae
            sym_l1_sf = casadi.MX.sym("d_i_k_sf", 
                                    self.n_variant_var*self.n_cp)
            sym_sf_col = casadi.vertsplit(sym_l1_sf, self.n_variant_var) \
                if self.n_variant_var>0 else empty_list

            sym_sf_col = [[sym_sf_col[k]] for k in range(self.n_cp)]\
                if self.n_variant_var>0 else sym_sf_col

            # Define scaling factors for collocation equation
            x_i_sf = casadi.MX.sym("x_i_sf", (self.n_cp + 1)*self.n_variant_x)
            x_i_sf_r = [casadi.reshape(x_i_sf,
                                       (self.n_variant_x, self.n_cp + 1)).T]\
                if self.n_variant_x>0 else []

            sdx_sf_i = casadi.MX.sym("dx_i_sf", self.n_variant_dx*self.n_cp)
            sdx_sf_col = map(list,casadi.vertsplit(sdx_sf_i, self.n_variant_dx))\
                if self.n_variant_dx>0 else empty_list
            sdx_sf_col = [[sdx_sf_col[k]] for k in range(self.n_cp)]\
                if self.n_variant_dx>0 else sdx_sf_col

            if self.eliminate_der_var:
                print "TODO define input for no derivative mode daeresidual"
                raise NotImplementedError("eliminate_der_ver not supported yet")
            else:
                # Define functions
                output_dae_element = list()
                output_coll_element = list()
                lagTerms = list()
                for k in range(self.n_cp):
                    # Call level1 Collocations
                    input_l0_fcn = time_col[k]+no_boundaries_x_col[k]\
                        +dx_col[k]+unu_col[k]+w_col[k]+elu_col[k]+p_opt\
                        +sym_sf_col[k]
                    [dae_k]=self.dae_l0_fcn.call(input_l0_fcn)
                    output_dae_element.append(dae_k)

                    # Call level0 Collocations
                    input_l0_coll_fcn = x_i + der_vals_col[k] + \
                        [h_i] + dx_i_col[k] + \
                        x_i_sf_r + sdx_sf_col[k]
                    [coll_k] = self.coll_l0_eq_fcn.call(input_l0_coll_fcn)
                    output_coll_element.append(coll_k)

                    if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                        #call level0 lagrange
                        input_l0_fcn = time_col[k]+no_boundaries_x_col[k]\
                            +dx_col[k]+unu_col[k]+w_col[k]+elu_col[k]+p_opt\
                            + self._timed_variables +sym_sf_col[k]
                        [lag_k] = self.lterm_l0_fcn.call(input_l0_fcn)
                        lagTerms.append(lag_k)

                # Define DAEResidual level1    
                output_dae_element = casadi.vertcat(output_dae_element)
                input_dae_l1 = copy.copy(s_sym_input_l1)
                if self.n_variant_var>0:
                    input_dae_l1 += [sym_l1_sf]

                dae_l1_fcn = casadi.MXFunction(input_dae_l1,
                                               [output_dae_element])
                dae_l1_fcn.setOption("name", "dae_l1_fcn")
                dae_l1_fcn.init()                    
                self.dae_l1_fcn = dae_l1_fcn

                # Define Collocation equation level1
                output_coll_element = casadi.vertcat(output_coll_element)
                if self.n_variant_x>0 and self.n_variant_dx>0:
                    coll_eq_l1_fcn = casadi.MXFunction([l1_mvar_struct["x"]]\
                                                       +[element_der_vals,h_i]\
                                                       +[dx_i]+[x_i_sf]\
                                                       +[sdx_sf_i],
                                                       [output_coll_element])
                elif self.n_variant_x>0 and not self.n_variant_dx>0:
                    coll_eq_l1_fcn = casadi.MXFunction([l1_mvar_struct["x"]]\
                                                       +[element_der_vals,h_i]\
                                                       +[dx_i]+[x_i_sf],
                                                       [output_coll_element])
                elif not self.n_variant_x>0 and self.n_variant_dx>0:
                    coll_eq_l1_fcn = casadi.MXFunction([l1_mvar_struct["x"]]\
                                                       +[element_der_vals,h_i]\
                                                       +[dx_i]+[sdx_sf_i],
                                                       [output_coll_element])
                else:
                    coll_eq_l1_fcn = casadi.MXFunction([l1_mvar_struct["x"]]\
                                                       +[element_der_vals,h_i]\
                                                       +[dx_i],
                                                       [output_coll_element])
                coll_eq_l1_fcn.setOption("name", "coll_l1_eq_fcn")
                coll_eq_l1_fcn.init() 
                self.coll_eq_l1_fcn = coll_eq_l1_fcn 

                if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                    # Define Lagrange term level1    
                    lagTerms= casadi.horzcat(lagTerms)
                    output_lag_element = casadi.mul(lagTerms, sym_g_weights)
                    input_lterm_l1 = [sym_g_weights]
                    input_lterm_l1 += copy.copy(s_sym_input_l1)
                    input_lterm_l1 += copy.copy(self._timed_variables)
                    if self.n_variant_var>0:
                        input_lterm_l1 += [sym_l1_sf]
                    lterm_l1 = casadi.MXFunction(input_lterm_l1,
                                                 [output_lag_element])
                    lterm_l1.setOption("name", "lterm_l1_fcn")
                    lterm_l1.init()
                    self.lterm_l1 = lterm_l1

    def _call_functions(self):
        """
        Call common functions for level 1 and level 0
        """
        
        # Broadcast self.pol.der_vals
        # Note that der_vals is quite different from self.pol.der_vals
        der_vals = []
        self.der_vals = der_vals

        for k in xrange(self.n_cp + 1):
            #Done like this because of casadi update. This can be improved
            der_vals_k = [self.pol.der_vals[:, k].T.reshape([1, self.n_cp + 1]).T]
            der_vals_k *= self.n_var['x']            
            der_vals.append(casadi.horzcat(der_vals_k))

        # Create list of state matrices
        x_list = [[]]
        self.x_list = x_list        

        for i in xrange(1, self.n_e + 1):
            x_i = [self.var_map['x'][i][k]['all'].T for k in xrange(self.n_cp + 1)]
            x_i = [casadi.vertcat(x_i)]
            x_list.append(x_i)

        # Index collocation equation scale factors
        if self.variable_scaling and self.nominal_traj is not None:
            coll_sf = {}
            self.coll_sf = coll_sf
            for i in xrange(1, self.n_e + 1):
                coll_sf[i] = {}
                coll_sf[i]['x'] = []
                coll_sf[i]['dx'] = {}
                for k in xrange(1, self.n_cp + 1):
                    coll_sf[i]['dx'][k] = []
            for var in self.mvar_vectors['x']:
                x_name = var.getName()
                dx_name = var.getMyDerivativeVariable().getName()
                x_sf_index = self._name_idx_sf_map[x_name]
                dx_sf_index = self._name_idx_sf_map[dx_name]

                # States
                if self._is_variant[x_name]:
                    # First element
                    i = 1
                    coll_sf[i]['x'].append([])
                    coll_sf[i]['x'][-1].append(self._variant_sf[i][0][x_sf_index])
                    for k in xrange(1, self.n_cp + 1):
                        coll_sf[i]['x'][-1].append(
                            self._variant_sf[i][k][x_sf_index])

                    # Suceeding elements
                    for i in xrange(2, self.n_e + 1):
                        k = self.n_cp + self.is_gauss
                        coll_sf[i]['x'].append([])
                        coll_sf[i]['x'][-1].append(
                            self._variant_sf[i-1][k][x_sf_index])
                        for k in xrange(1, self.n_cp + 1):
                            coll_sf[i]['x'][-1].append(
                                self._variant_sf[i][k][x_sf_index])

                # State derivatives
                if self._is_variant[dx_name]:
                    for i in xrange(1, self.n_e + 1):
                        for k in xrange(1, self.n_cp + 1):
                            coll_sf[i]['dx'][k].append(
                                self._variant_sf[i][k][dx_sf_index])
                            
        # Create constraint storage
        c_e = casadi.MX()
        c_i = casadi.MX()

        # Initial conditions
        i = 1
        k = 0
        s_fcn_input = self._get_z_l0(i, k)
        if self.n_var['p_opt']>0:
            s_fcn_input += [self.var_map['p_opt']['all'] ]
        if self.variable_scaling and self.nominal_traj is not None:
            if self.n_variant_var>0:
                s_fcn_input.append(self._variant_sf[i][k])

        [initial_constr] = self.initial_l0_fcn.call(s_fcn_input)
        c_e.append(initial_constr)
        if self.eliminate_der_var:
            print "Call the additional equations for no derivative mode"
            raise NotImplementedError("named_vars not supported yet")
        else:
            [dae_t0_constr] = self.dae_l0_fcn.call(s_fcn_input)
        c_e.append(dae_t0_constr)

        if self.blocking_factors is None:
            inp_list = [inp.getName() for inp in self.mvar_vectors['unelim_u']]
        else:
            inp_list = [inp.getName() for inp in self.mvar_vectors['unelim_u'] 
                   if not self.blocking_factors.factors.has_key(inp.getName())]

        for name in inp_list:
            # Evaluate u_1_0 based on polynomial u_1
            u_1_0 = 0
            input_index = self.name_map[name][0]

            for k in xrange(1, self.n_cp + 1):
                u_1_0 += (self.pol.eval_basis(k, 0, False) *
                          self.var_map['unelim_u'][1][k][input_index
                          ])

            # Add residual for u_1_0 as constraint
            u_1_0_constr = self.var_map['unelim_u'][1][0][input_index] - u_1_0
            c_e.append(u_1_0_constr)

        # Continuity constraints for x_{i, n_cp + 1}
        if self.is_gauss:
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        x_i_np1 += self.pol.w[k] * self.var_map['dx'][i][k]['all']
                    x_i_np1 = (self.var_map['x'][i][0]['all'] + 
                               self.horizon * self.h[i] * x_i_np1)

                    # Add residual for x_i_np1 as constraint
                    quad_constr = self.var_map['x'][i][self.n_cp + 1]['all'] - x_i_np1
                    c_e.append(quad_constr)
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_np1 += self.var_map['x'][i][k]['all'] * self.pol.eval_basis(
                            k, 1, True)

                    # Add residual for x_i_np1 as constraint
                    quad_constr = self.var_map['x'][i][self.n_cp + 1]['all'] - x_i_np1
                    c_e.append(quad_constr)

        # Constraints for terminal values
        if self.is_gauss:
            for var_type in ['unelim_u', 'w']:
                # Evaluate xx_{n_e, n_cp + 1} based on polynomial xx_{n_e}
                xx_ne_np1 = 0
                for k in xrange(1, self.n_cp + 1):
                    xx_ne_np1 += (self.var_map[var_type][self.n_e][k]['all'] *
                                  self.pol.eval_basis(k, 1, False))

                # Add residual for xx_ne_np1 as constraint
                term_constr = (self.var_map[var_type][self.n_e][self.n_cp + 1]['all'] -
                               xx_ne_np1)
                c_e.append(term_constr)
            if not self.eliminate_der_var:
                # Evaluate dx_{n_e, n_cp + 1} based on polynomial x_{n_e}
                dx_ne_np1 = 0
                for k in xrange(self.n_cp + 1):
                    x_ne_k = self.var_map['x'][self.n_e][k]['all']
                    dx_ne_np1 += (1. / (self.horizon * self.h[self.n_e]) *
                                  x_ne_k * self.pol.eval_basis_der(k, 1))

                # Add residual for dx_ne_np1 as constraint
                term_constr_dx = (self.var_map['dx'][self.n_e][self.n_cp + 1]['all'] -
                                  dx_ne_np1)
                c_e.append(term_constr_dx)

        # Element length constraints
        if self.hs == "free":
            h_constr = casadi.sumRows(self.h[1:]) - 1
            c_e.append(h_constr)
            
        # Path constraints
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                s_fcn_input = []
                if self.eliminate_der_var:
                    print "TODO path constraints eliminate derivative mode"
                    raise NotImplementedError("eliminate_der_var not supported yet")
                else:
                    s_fcn_input += self._get_z_l0(i, k)
                if self.n_var['p_opt']>0:
                    s_fcn_input += [self.var_map['p_opt']['all']]
                s_fcn_input += self._nlp_timed_variables
                if self.variable_scaling and self.nominal_traj is not None:
                    if self.n_variant_var>0:
                        s_fcn_input.append(self._variant_sf[i][k])

                [g_e_constr] = self.g_e_l0_fcn.call(s_fcn_input)
                [g_i_constr] = self.g_i_l0_fcn.call(s_fcn_input)

                c_e.append(g_e_constr)
                c_i.append(g_i_constr)
                
        # Point constraints
        s_fcn_input = self._get_z_l0(i, k, with_der=False)
        if self.n_var['p_opt']>0:
            s_fcn_input += [self.var_map['p_opt']['all']]
        s_fcn_input += self._nlp_timed_variables
        [G_e_constr] = self.G_e_l0_fcn.call(s_fcn_input)
        [G_i_constr] = self.G_i_l0_fcn.call(s_fcn_input)

        c_e.append(G_e_constr)
        c_i.append(G_i_constr)

        # Check that only inputs are constrained or eliminated
        if self.external_data is not None:
            for var_name in (self.external_data.eliminated.keys() +
                             self.external_data.constr_quad_pen.keys()):
                (_, vt) = self.name_map[var_name]
                if vt not in ['elim_u', 'unelim_u']:
                    if var_name in self.external_data.eliminated.keys():
                        msg = ("Eliminated variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    else:
                        msg = ("Constrained variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    raise jmiVariableNotFoundError(msg) 

        # Equality constraints for constrained inputs
        if self.external_data is not None:
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    for j in xrange(len(self.external_data.constr_quad_pen)):
                        # Retrieve variable and value
                        name = self.external_data.constr_quad_pen.keys()[j]
                        constr_var = self._get_unscaled_expr(name, i, k)
                        constr_val = self.var_map['constr_u'][i][k]['all'][j]                            

                        # Add constraint
                        input_constr = constr_var - constr_val
                        c_e.append(input_constr)
                        
        # Equality constraints for delayed feedback
        if self.delayed_feedback is not None:

            # Check for unsupported cases
            if self.blocking_factors is not None: raise CasadiCollocatorException(
                "Blocking factors are not supported with delayed feedback.")
            if self._normalize_min_time: raise CasadiCollocatorException(
                "Free time horizon os not supported with delayed feedback.")
            if self.hs is not None: raise CasadiCollocatorException(
                "Non-uniform element lengths are not supported with delayed feedback.")
            
            for (u_name, (y_name, delay_n_e)) in self.delayed_feedback.iteritems():
                u_dae_var = self.op.getVariable(u_name)
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        u_var = self._get_unscaled_expr(u_name, i, k)
                        if i > delay_n_e:
                            u_value = self._get_unscaled_expr(y_name, i-delay_n_e, k)
                        else:
                            u_value = self._eval_initial(u_dae_var, i, k)
                                                
                        # Add constraint
                        input_constr = u_var - u_value
                        c_e.append(input_constr)
        
        # Broadcast the constraints
        self.c_e = c_e
        self.c_i = c_i
        
        # Calculate cost
        self.cost_mayer = 0
        if not self.mterm.isConstant() or self.mterm.getValue() != 0.:
            # Evaluate Mayer term
            s_z = self._get_z_l0(1, 0, with_der=False)
            s_mterm_fcn_input = s_z
            if self.n_var['p_opt']>0:
                s_mterm_fcn_input += [self.var_map['p_opt']['all']]            
            s_mterm_fcn_input += self._nlp_timed_variables
            [self.cost_mayer] = self.mtem_l0_fcn.call(s_mterm_fcn_input)

    
    def _call_l0_functions(self):
        """
        Call functions in a normal fashion without checkpoint.
        
        Build the list of equality and inequality constraints 
        using only level zero functions. This function must 
        be called only after _define_l0_constraint_functions 
        has been called. 

        The inequality constraints are stored in  the class 
        attribute c_i, while the equality constraints are 
        stored in the class attribute c_e

        Define the bolza problem based on level zero functions.
        It does not include restricted inputs. Those are added to 
        self.cost later
        """
        # Collocation and DAE constraints
        for i in xrange(1, self.n_e + 1):
            for k in xrange(1, self.n_cp + 1):
                # Create function inputs
                if self.eliminate_der_var:
                    print "TODO set input for no derivative mode collocation equation"
                    raise NotImplementedError("eliminate_der_var not supported yet")
                else:
                    s_fcn_input = self._get_z_l0(i, k)
                    if self.n_var['p_opt']>0:
                        s_fcn_input += [self.var_map['p_opt']['all']]                    

                    scoll_input = self.x_list[i] + [self.der_vals[k],
                                               self.horizon * self.h[i]]                    
                    scoll_input += [self.var_map['dx'][i][k]['all']]

                if self.variable_scaling and self.nominal_traj is not None:
                    if self.n_variant_var>0:
                        s_fcn_input += [self._variant_sf[i][k]]
                    if self.eliminate_der_var:
                        print "TODO set input for no derivative mode collocation equation"
                        raise NotImplementedError("eliminate_der_var not supported yet")                        
                    else:
                        if self.n_variant_x>0 and self.n_variant_dx>0:
                            scoll_input += [casadi.horzcat(self.coll_sf[i]['x'])]
                            scoll_input += [self.coll_sf[i]['dx'][k]]
                        elif self.n_variant_x>0 and not self.n_variant_dx>0:
                            scoll_input += [casadi.horzcat(self.coll_sf[i]['x'])]                       
                        elif not self.n_variant_x>0 and self.n_variant_dx>0:
                            scoll_input += [self.coll_sf[i]['dx'][k]]                            

                # Evaluate collocation constraints
                if not self.eliminate_der_var:
                    [scoll_constr] = self.coll_l0_eq_fcn.call(scoll_input)
                    self.c_e.append(scoll_constr)

                # Evaluate DAE constraints
                [dae_constr] = self.dae_l0_fcn.call(s_fcn_input)
                self.c_e.append(dae_constr)


        # Continuity constraints for x_{i, 0}
        if not self.eliminate_cont_var:
            for i in xrange(1, self.n_e):
                cont_constr = (self.var_map['x'][i][self.n_cp + self.is_gauss]['all'] - 
                               self.var_map['x'][i + 1][0]['all'])
                self.c_e.append(cont_constr)


        self.cost_lagrange = 0        
        if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
            # Get start and final time
            t0_var = self.op.getVariable('startTime')
            tf_var = self.op.getVariable('finalTime')
            if self.op.get_attr(t0_var, "free"):
                (ind, _) = self.name_map["startTime"]
                t0 = self.var_map['p_opt']['all'][ind]
            else:
                t0 = self.op.get_attr(t0_var, "_value")
            if self.op.get_attr(tf_var, "free"):
                (ind, _) = self.name_map["finalTime"]
                tf = self.var_map['p_opt']['all'][ind]
            else:
                tf = self.op.get_attr(tf_var, "_value")

            # Evaluate Lagrange cost
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    if self.eliminate_der_var:
                        print "TODO lagrange input no derivative mode"
                        raise NotImplementedError("eliminate_der_var not supported yet")                          
                    else:
                        s_lterm_fcn_input = self._get_z_l0(i,k)
                        if self.n_var['p_opt']>0:
                            s_lterm_fcn_input += [self.var_map['p_opt']['all']]                        
                        s_lterm_fcn_input += self._nlp_timed_variables

                    if self.variable_scaling and self.nominal_traj is not None:
                        if self.n_variant_var>0:
                            s_lterm_fcn_input += [self._variant_sf[i][k]]
                    [lterm_val] = self. lterm_l0_fcn.call(s_lterm_fcn_input)
                    # This can be improved! See #3355
                    self.cost_lagrange += ((tf - t0) * self.h[i] *
                                           lterm_val * self.pol.w[k])

        # Sum up the two cost terms
        self.cost = self.cost_mayer + self.cost_lagrange

    def _FXFunction(self, *args):
        f = casadi.MXFunction(*args)
        if self.expand_to_sx == 'DAE':
            f.init()
            f = casadi.SXFunction(f)
        return f

    def _call_l1_functions(self):
        """
        Call checkpointed functions.
        
        Build the list of equality and inequality constraints 
        using level zero and level one functions. This function must 
        be called only after _define_l0_functions and _define_l1_functions 
        have been called. 

        The inequality constraints are stored in  the class 
        attribute c_i, while the equality constraints are 
        stored in the class attribute c_e

        Define the bolza problem based on level zero 
        and level one functions.It does not include restricted inputs. 
        Those are added to self.cost later
        """ 

        # Create der_vals for all collocation points (level1 input)
        der_vals_l1=list()
        for k in xrange(1, self.n_cp + 1):
            der_vals_k = self.pol.der_vals[:, k]
            for j in der_vals_k:
                for x in range(self.n_var['x']):
                    der_vals_l1.append(j)
        der_vals_l1=casadi.MX(der_vals_l1) 

        # Index collocation equation scale factors
        if self.variable_scaling and self.nominal_traj is not None:
            coll_l1_sf = {}
            for i in xrange(1, self.n_e + 1):
                coll_l1_sf[i] = {}
                if i==1:
                    coll_l1_sf[i]['x'] =[] 
                    for var in self.mvar_vectors['x']:
                        x_name = var.getName()
                        dx_name = var.getMyDerivativeVariable().getName()
                        x_sf_index = self._name_idx_sf_map[x_name]
                        dx_sf_index = self._name_idx_sf_map[dx_name]
                        if self._is_variant[x_name]:
                            coll_l1_sf[i]['x'].append(
                                self._variant_sf[i][0][x_sf_index])
                else:
                    k = self.n_cp + self.is_gauss
                    coll_l1_sf[i]['x'] = []
                    for var in self.mvar_vectors['x']:
                        x_name = var.getName()
                        dx_name = var.getMyDerivativeVariable().getName()
                        x_sf_index = self._name_idx_sf_map[x_name]
                        dx_sf_index = self._name_idx_sf_map[dx_name]
                        if self._is_variant[x_name]:
                            coll_l1_sf[i]['x'].append(
                                self._variant_sf[i-1][k][x_sf_index])              
                coll_l1_sf[i]['dx'] = []

            #level 1 scaling factor lists for Collocation equation
            for k in xrange(1, self.n_cp + 1):
                for var in self.mvar_vectors['x']:
                    x_name = var.getName()
                    dx_name = var.getMyDerivativeVariable().getName()
                    x_sf_index = self._name_idx_sf_map[x_name]
                    dx_sf_index = self._name_idx_sf_map[dx_name]
                    if self._is_variant[x_name]:
                        for i in xrange(1, self.n_e + 1):
                            coll_l1_sf[i]['x'].append(
                                self._variant_sf[i][k][x_sf_index])
                    if self._is_variant[dx_name]:
                        for i in xrange(1, self.n_e + 1):
                            coll_l1_sf[i]['dx'].append(
                                self._variant_sf[i][k][dx_sf_index])

            #Compute level 1 scaling factors lists for DAE
            element_variant_sf=dict()
            for i in range(1, self.n_e+1):
                element_variant_sf[i]=list()
                for k in range(1, self.n_cp+1):
                    element_variant_sf[i]+=self._variant_sf[i][k]
        
        if self.n_var['elim_u']>0:
            raise NotImplementedError("Checkpoint not supported with eliminated inputs")
        
        # Collocation and DAE constraints
        # This is benefitial for code generation 
        h_uniform=self.h[1]
        h_no_free=casadi.MX(h_uniform*self.horizon)
        non_uniform_h=False
        for i in xrange(2, self.n_e + 1):
            if self.h[i]!=h_uniform:
                non_uniform_h=True
                break
        for i in xrange(1, self.n_e + 1):
            # Create function inputs
            if self.eliminate_der_var:
                print "TODO set input for no derivative mode collocation equation"
                raise NotImplementedError("eliminate_der_var not supported yet")
            else:
                e_fcn_input = self._get_z_l1(i)
                if self.n_var['p_opt']>0:
                    e_fcn_input += [self.var_map['p_opt']['all']]
                if self.hs == "free" or non_uniform_h:
                    ecoll_input = [self.var_map['x'][i]['all']]+\
                        [der_vals_l1]+[self.horizon * self.h[i]]+\
                        [self.var_map['dx'][i]['all']]
                else:
                    ecoll_input = [self.var_map['x'][i]['all']]+\
                        [der_vals_l1]+[h_no_free]+\
                        [self.var_map['dx'][i]['all']]                        
                if self.variable_scaling and self.nominal_traj is not None:
                    if self.n_variant_var>0: 
                        e_fcn_input += [element_variant_sf[i]]

                    if self.n_variant_x>0 and self.n_variant_dx>0:
                        ecoll_input += [coll_l1_sf[i]['x']]
                        ecoll_input += [coll_l1_sf[i]['dx']]
                    elif self.n_variant_x>0 and not self.n_variant_dx>0:
                        ecoll_input += [coll_l1_sf[i]['x']]                       
                    elif not self.n_variant_x>0 and self.n_variant_dx>0:
                        ecoll_input += [coll_l1_sf[i]['dx']]

                [dae_constr_l1] = self.dae_l1_fcn.call(e_fcn_input)
                self.c_e.append(dae_constr_l1)
                if not self.eliminate_der_var:
                    [col_costr_l1]=self.coll_eq_l1_fcn.call(ecoll_input)
                    self.c_e.append(col_costr_l1)

        # Continuity constraints for x_{i, 0}
        if not self.eliminate_cont_var:
            for i in xrange(1, self.n_e):
                cont_constr = (self.var_map['x'][i][self.n_cp + self.is_gauss]['all'] - 
                               self.var_map['x'][i + 1][0]['all'])
                self.c_e.append(cont_constr)  

        # Lagrange term with check point
        self.cost_lagrange = 0       
        if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
            # Get start and final time
            t0_var = self.op.getVariable('startTime')
            tf_var = self.op.getVariable('finalTime')
            if self.op.get_attr(t0_var, "free"):
                (ind, _) = self.name_map["startTime"]
                t0 = self.var_map['p_opt']['all'][ind]
            else:
                t0 = self.op.get_attr(t0_var, "_value")
            if self.op.get_attr(tf_var, "free"):
                (ind, _) = self.name_map["finalTime"]
                tf = self.var_map['p_opt']['all'][ind]
            else:
                tf = self.op.get_attr(tf_var, "_value")

            # Evaluate Lagrange cost   
            Gauss_w = list()    
            for k in range(1, self.n_cp+1):
                Gauss_w.append(self.pol.w[k])
            Gauss_w=casadi.MX(Gauss_w)
            if self.hs == "free" or non_uniform_h:
                for i in xrange(1, self.n_e + 1):
                    if self.eliminate_der_var:
                        print "TODO lagrange input no derivative mode"
                        raise NotImplementedError("eliminate_der_var not supported yet")                          
                    else:
                        e_fcn_input = [Gauss_w]+self._get_z_l1(i)
                        if self.n_var['p_opt']>0:
                            e_fcn_input += [self.var_map['p_opt']['all']]  
                        e_fcn_input += self._nlp_timed_variables
                        if self.variable_scaling and self.nominal_traj is not None:
                            if self.n_variant_var>0: 
                                e_fcn_input += [element_variant_sf[i]]

                        [e_lterm_val] = self.lterm_l1.call(e_fcn_input)
                        self.cost_lagrange += ((tf - t0) * self.h[i] *
                                               e_lterm_val)
            else:
                for i in xrange(1, self.n_e + 1):
                    if self.eliminate_der_var:
                        print "TODO lagrange input no derivative mode"
                        raise NotImplementedError("eliminate_der_var not supported yet")                          
                    else:
                        e_fcn_input = [Gauss_w]+self._get_z_l1(i)
                        if self.n_var['p_opt']>0:
                            e_fcn_input += [self.var_map['p_opt']['all']]  
                        e_fcn_input += self._nlp_timed_variables
                        if self.variable_scaling and self.nominal_traj is not None:
                            if self.n_variant_var>0: 
                                e_fcn_input += [element_variant_sf[i]]

                        [e_lterm_val] = self.lterm_l1.call(e_fcn_input)
                        self.cost_lagrange += e_lterm_val
                
                self.cost_lagrange=(tf - t0)*self.h[1]*self.cost_lagrange

        # Sum up the two cost terms
        self.cost = self.cost_mayer + self.cost_lagrange

    def _eliminate_der_var(self):
        """
        Eliminate derivative variables from OCP expressions.
        """
        if self.eliminate_der_var:
            coll_der = self._collocation['coll_der']
            self.dae_t0 = self.dae
            ocp_expressions = [self.dae,
                               self.path,
                               self.point,
                               self.mterm,
                               self.lterm]
            [self.dae,
             self.path,
             self.point,
             self.mterm,
             self.lterm] = casadi.substitute(ocp_expressions,
                                             self.mvar_struct["dx"],
                                             coll_der)

    def _check_linear_comb(self, expr):
        """
        Checks if expr is a linear combination of startTime and finalTime.
        """
        t0 = self.op.getVariable('startTime').getVar()
        tf = self.op.getVariable('finalTime').getVar()
        [zero] = casadi.substitute([expr], [t0, tf], [0., 0.])
        if zero != 0.:
            return False
        f = casadi.MXFunction([t0, tf], [expr])
        f.init()
        if not f.grad(0).isConstant() or not f.grad(1).isConstant():
            return False
        return True

    def _tp2cp(self, tp):
        """
        Computes the normalized collocation point given a time point.
        """
        t0_var = self.op.getVariable('startTime').getVar()
        tf_var = self.op.getVariable('finalTime').getVar()
        cp_f = casadi.MXFunction([t0_var, tf_var], [tp])
        cp_f.init()
        cp_f.setInput(0., 0)
        cp_f.setInput(1., 1)
        cp_f.evaluate()
        return cp_f.output().toScalar()

    def _get_affine_scaling(self, name, i, k):
        """
        Get the affine scaling (d, e) of variable name at a collocation point.

            unscaled_value = d*scaled_value + e
        """
        if self.variable_scaling:
            if self.nominal_traj is None:
                (ind, vt) = self.name_map[name]
                return (self._sf[vt][ind], 0.0)
            else:
                sf_index = self._name_idx_sf_map[name]
                if self._is_variant[name]:
                    return (variant_sf[i][k][sf_index], 0.0)
                else:
                    return (self._invariant_d[sf_index], self._invariant_e[sf_index])
        else:
            return (1.0, 0.0)
        
    def _get_unscaled_expr(self, name, i, k):
        """
        Get expression for unscaled value of variable at collocation point.
        """
        (ind, vt) = self.name_map[name]
        val = self.var_map[vt][i][k][ind]
        d, e = self._get_affine_scaling(name, i, k)        
        return d*val + e

    def _create_constraints_and_cost(self):
        """
        Create the constraints and cost function.
        """
        # Calculate time points    
        time=self._compute_time_points()

        #compute and scale timed variables       
        self._store_and_scale_timed_vars(time)
        # Denormalize time for minimum time problems
        self._denormalize_times()

        # must be called after time has been denormalized and self._denorm_t0_init etc have been set
        self._create_initial_trajectories()        

        #create trajectory scaling structures
        self._create_trajectory_scaling_factor_structures()

        # Create measured input trajectories
        self._create_external_input_trajectories()

        # At this point, most features stop being supported
        if self.eliminate_der_var:
            raise NotImplementedError("eliminate_der_var not yet supported.")
        if self.eliminate_cont_var:
            raise NotImplementedError("eliminate_cont_var not yet supported.")

        # Make time an attribute
        self.time = N.array(time)

        # Define level0 functions
        self._define_l0_functions() 
        if self.checkpoint:
            self._define_l1_functions()

        # Call functions
        self._call_functions()
        if not self.checkpoint:
            self._call_l0_functions()
        else:         
            self._call_l1_functions()

        # Add quadratic cost for external data
        if (self.external_data is not None and
            (len(self.external_data.quad_pen) +
             len(self.external_data.constr_quad_pen) > 0)):
            # Retrieve scaling factors
            if self.variable_scaling and self.nominal_traj is not None:
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                name_idx_sf_map = self._name_idx_sf_map

            # Create nested dictionary for storage of errors and calculate
            # reference values
            err = {}
            y_ref = {}
            datas = (self.external_data.constr_quad_pen.values() +
                     self.external_data.quad_pen.values())
            for i in range(1, self.n_e + 1):
                err[i] = {}
                y_ref[i] = {}
                for k in range(1, self.n_cp + 1):
                    err[i][k] = []
                    ref_val = []
                    for data in datas:
                        ref_val.append(data.eval(self.time_points[i][k])[0, 0])
                    y_ref[i][k] = N.array(ref_val)

            # Calculate errors
            name_map = self.name_map
            if self.variable_scaling and self.nominal_traj is None:
                sfs = self._sf
            var_names = (self.external_data.constr_quad_pen.keys() +
                         self.external_data.quad_pen.keys())
            for j in xrange(len(var_names)):
                name = var_names[j]
                for i in range(1, self.n_e + 1):
                    for k in range(1, self.n_cp + 1):
                        unscaled_val = self._get_unscaled_expr(name, i, k)
                        ref_val = y_ref[i][k][j]
                        err[i][k].append(unscaled_val - ref_val)

            # Calculate cost contribution from each collocation point
            Q = self.external_data.Q
            for i in range(1, self.n_e + 1):
                h_i = self.horizon * self.h[i]
                for k in range(1, self.n_cp + 1):
                    err_i_k = N.array(err[i][k])
                    integrand = N.dot(N.dot(err_i_k, Q), err_i_k)
                    self.cost += (h_i * integrand * self.pol.w[k])

        # Add cost term for free element lengths
        if self.hs == "free":
            Q = self.free_element_lengths_data.Q
            c = self.free_element_lengths_data.c
            a = self.free_element_lengths_data.a
            length_cost = 0
            for i in range(1, self.n_e + 1):
                h_i = self.horizon * self.h[i]
                for k in range(1, self.n_cp + 1):
                    integrand = casadi.mul(
                        casadi.mul(self.var_map['dx'][i][k]['all'].T, Q),
                        self.var_map['dx'][i][k]['all'])
                    length_cost += (h_i ** (1 + a) * integrand * self.pol.w[k])
            self.cost += c * length_cost

    def _create_blocking_factors_constraints_and_cost(self):
        """
        Add the constraints and penalties from blocking factors.
        """
        # Retrieve meta-data
        if self.variable_scaling:
            if self.nominal_traj is None:
                sfs = self._sf
            else:
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                name_idx_sf_map = self._name_idx_sf_map
        c_i = self.c_i

        # Add constraints and penalties
        if self.blocking_factors is not None:
            bf_pen = 0.
            for var in self.mvar_vectors['unelim_u']:
                name = var.getName()
                if name in self.blocking_factors.factors:
                    # Find scale factors
                    (idx, _) = self.name_map[name]
                    if self.variable_scaling:
                        if self.nominal_traj is None:
                            d_0 = sfs['unelim_u'][idx]
                            e_0 = 0.
                            d_1 = d_0
                            e_1 = 0.
                        else:
                            sf_index = name_idx_sf_map[name]
                            if is_variant[name]:
                                d_0 = variant_sf[i][1][sf_index]
                                e_0 = 0.
                                d_1 = variant_sf[i+1][1][sf_index]
                                e_1 = 0.
                            else:
                                d_0 = invariant_d[sf_index]
                                e_0 = invariant_e[sf_index]
                                d_1 = d_0
                                e_1 = e_0
                    else:
                        d_0 = 1.
                        e_0 = 0.
                        d_1 = d_0
                        e_1 = e_0

                    # Get variable info
                    factors = self.blocking_factors.factors[name]
                    if name in self.blocking_factors.du_bounds:
                        bound = self.blocking_factors.du_bounds[name]
                    if name in self.blocking_factors.du_quad_pen:
                        weight = self.blocking_factors.du_quad_pen[name]

                    # Loop over blocking factor boundaries
                    quad_pen = 0.
                    for i in N.cumsum(factors)[:-1]:
                        # Create delta_u
                        du = (d_0*self.var_map['unelim_u'][i][1][idx] + e_0 -
                              d_1*self.var_map['unelim_u'][i+1][1][idx] - e_1)

                        # Add constraints
                        if name in self.blocking_factors.du_bounds:
                            c_i.append(du - bound)
                            c_i.append(-du - bound)

                        # Add penalty
                        if name in self.blocking_factors.du_quad_pen:
                            quad_pen += du ** 2

                    # Add penalty for variable
                    if name in self.blocking_factors.du_quad_pen:
                        bf_pen += weight * quad_pen
            self.cost += bf_pen


    def _create_initial_trajectories(self):
        """
        Create interpolated initial trajectories.
        """
        if self.init_traj is not None:
            n = len(self.init_traj.get_data_matrix()[:, 0])
            self.init_traj_interp = traj = {}

            for vt in ["dx", "x", "w", "unelim_u"]:
                for var in self.mvar_vectors[vt]:
                    data_matrix = N.empty([n, len(self.mvar_vectors[vt])])
                    name = var.getName()
                    try:
                        data = self.init_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        print("Warning: Could not find initial " +
                              "trajectory for variable " + name +
                              ". Using initialGuess attribute value " +
                              "instead.")
                        ordinates = N.array([[
                            self.op.get_attr(var, "initialGuess")]])
                        abscissae = N.array([0])
                    else:
                        abscissae = data.t
                        ordinates = data.x.reshape([-1, 1])
                    traj[var] = TrajectoryLinearInterpolation(
                        abscissae, ordinates)

    def _eval_initial(self, var, i, k):
        """
        Evaluate initial value of Variable var at a given collocation point.

        self._create_initial_trajectories() must have been called first.
        """
        if self.init_traj is None:
            return self.op.get_attr(var, "initialGuess")
        else:
            time = self.time_points[i][k]
            if self._normalize_min_time:
                time = (self._denorm_t0_init +
                        (self._denorm_tf_init - self._denorm_t0_init) * time)
            return self.init_traj_interp[var].eval(time)

    def _compute_bounds_and_init(self):
        """
        Compute bounds and intial guesses for NLP variables.
        """
        # Create lower and upper bounds
        xx_lb = self.LOWER * N.ones(self.get_n_xx())
        xx_ub = self.UPPER * N.ones(self.get_n_xx())
        xx_init = N.zeros(self.get_n_xx())

        # Retrieve model data
        op = self.op
        var_types = ['x', 'unelim_u', 'w', 'p_opt']
        name_map = self.name_map
        mvar_vectors = self.mvar_vectors
        time_points = self.time_points
        if self.variable_scaling:
            if self.nominal_traj is None:
                sfs = self._sf
            else:
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                name_idx_sf_map = self._name_idx_sf_map

        # Handle free parameters
        p_max = N.empty(self.n_var["p_opt"])
        p_min = copy.deepcopy(p_max)
        p_init = copy.deepcopy(p_max)
        for var in mvar_vectors["p_opt"]:
            name = var.getName()
            (var_index, _) = name_map[name]
            if self.variable_scaling:
                if self.nominal_traj is None:
                    sf = sfs["p_opt"][var_index]
                else:
                    sf_index = name_idx_sf_map[name]
                    sf = invariant_d[sf_index]
            else:
                sf = 1.
            p_min[var_index] = op.get_attr(var, "min") / sf
            p_max[var_index] = op.get_attr(var, "max") / sf

            # Handle initial guess
            var_init = op.get_attr(var, "initialGuess")
            if self.init_traj is not None:
                name = var.getName()
                if name == "startTime":
                    var_init = self._denorm_t0_init
                elif name == "finalTime":
                    var_init = self._denorm_tf_init
                else:
                    try: 
                        data = self.init_traj.get_variable_data(name) 
                    except VariableNotFoundError: 
                        pass
                    else: 
                        var_init = data.x[0] 
            p_init[var_index] = var_init / sf
        xx_lb[self.var_indices['p_opt']] = p_min
        xx_ub[self.var_indices['p_opt']] = p_max
        xx_init[self.var_indices['p_opt']] = p_init

        # Manipulate initial trajectories
        if self.init_traj is not None:
            n = len(self.init_traj.get_data_matrix()[:, 0])
            traj = {}

            for vt in ["dx", "x", "w", "unelim_u"]:
                traj[vt] = {}
                for var in mvar_vectors[vt]:
                    data_matrix = N.empty([n, len(mvar_vectors[vt])])
                    name = var.getName()
                    (var_index, _) = name_map[name]
                    if name == "startTime":
                        abscissae = N.array([0])
                        ordinates = N.array([[self._denorm_t0_init]])
                    elif name == "finalTime":
                        abscissae = N.array([0])
                        ordinates = N.array([[self._denorm_tf_init]])
                    else:
                        try:
                            data = self.init_traj.get_variable_data(name)
                        except VariableNotFoundError:
                            print("Warning: Could not find initial " +
                                  "trajectory for variable " + name +
                                  ". Using initialGuess attribute value " +
                                  "instead.")
                            ordinates = N.array([[
                                op.get_attr(var, "initialGuess")]])
                            abscissae = N.array([0])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        traj[vt][var_index] = TrajectoryLinearInterpolation(
                            abscissae, ordinates)

        # Denormalize time for minimum time problems
        if self._normalize_min_time:
            t0 = self._denorm_t0_init
            tf = self._denorm_tf_init

        # Set bounds and initial guesses
        for vt in ['dx', 'x', 'w', 'unelim_u']:
            var_min = N.empty(len(mvar_vectors[vt]))
            var_max = N.empty(len(mvar_vectors[vt]))
            var_init = N.empty(len(mvar_vectors[vt]))
            for var in mvar_vectors[vt]:
                name = var.getName()
                v_min = op.get_attr(var, "min")
                v_max = op.get_attr(var, "max")
                (var_idx, _) = name_map[name]
                if self.variable_scaling:
                    if self.nominal_traj is None:
                        d = sfs[vt][var_idx]
                        e = 0.
                    else:
                        sf_index = name_idx_sf_map[name]
                        if is_variant[name]:
                            e = 0.
                            for i in xrange(1, self.n_e + 1):
                                for k in self.time_points[i].keys():
                                    d = variant_sf[i][k][sf_index]
                                    v_init = self._eval_initial(var, i, k)
                                    xx_lb[self.var_indices[vt][i][k][var_idx]] = \
                                        (v_min - e) / d
                                    xx_ub[self.var_indices[vt][i][k][var_idx]] = \
                                        (v_max - e) / d
                                    xx_init[self.var_indices[vt][i][k][var_idx]] = \
                                        (v_init - e) / d
                        else:
                            d = invariant_d[sf_index]
                            e = invariant_e[sf_index]
                else:
                    d = 1.
                    e = 0.
                if ((not self.variable_scaling) or (self.nominal_traj is None)
                    or (not is_variant[name])):
                    for i in xrange(1, self.n_e + 1):
                        for k in self.time_points[i].keys():
                            v_init = self._eval_initial(var, i, k)
                            xx_lb[self.var_indices[vt][i][k][var_idx]] = \
                                (v_min - e) / d
                            xx_ub[self.var_indices[vt][i][k][var_idx]] = \
                                (v_max - e) / d
                            xx_init[self.var_indices[vt][i][k][var_idx]] = \
                                (v_init - e) / d

        # Set bounds and initial guesses for continuity variables
        if not self.eliminate_cont_var:
            vt = 'x'
            k = self.n_cp + self.is_gauss
            for i in xrange(2, self.n_e + 1):
                xx_lb[self.var_indices[vt][i][0]] = xx_lb[self.var_indices[vt][i - 1][k]]
                xx_ub[self.var_indices[vt][i][0]] = xx_ub[self.var_indices[vt][i - 1][k]]
                xx_init[self.var_indices[vt][i][0]] = \
                    xx_init[self.var_indices[vt][i - 1][k]]

        # Compute bounds and initial guesses for element lengths
        if self.hs == "free":
            h_0 = 1. / self.n_e
            h_bounds = self.free_element_lengths_data.bounds
            for i in xrange(1, self.n_e + 1):
                xx_lb[self.var_indices['h'][i]] = h_bounds[0] * h_0
                xx_ub[self.var_indices['h'][i]] = h_bounds[1] * h_0
                xx_init[self.var_indices['h'][i]] = h_bounds[1] * h_0

        # Store bounds and initial guesses
        self.xx_lb = xx_lb
        self.xx_ub = xx_ub
        self.xx_init = xx_init

    def _create_solver(self):
        # Concatenate constraints
        constraints = casadi.vertcat([self.c_e, self.c_i])

        # Create solver object
        nlp = casadi.MXFunction(casadi.nlpIn(x=self.xx, p=self.pp),
                                casadi.nlpOut(f=self.cost, g=constraints))
        if self.solver == "IPOPT":
            self.solver_object = casadi.NlpSolver("ipopt",nlp)
        elif self.solver == "WORHP":
            self.solver_object = casadi.NlpSolver("worhp",nlp)
        else:
            raise CasadiCollocatorException(
                    "Unknown nonlinear programming solver %s." % self.solver)

        # Expand to SX
        self.solver_object.setOption("expand", self.expand_to_sx == "NLP")

    def get_equality_constraint(self):
        return self.c_e

    def get_inequality_constraint(self):
        return self.c_i

    def get_cost(self):
        return self.cost_fcn

    def get_result(self):
        # Set model info
        n_var = self.n_var
        cont = {'dx': False, 'x': True, 'unelim_u': False, 'w': False}
        mvar_vectors = self.mvar_vectors
        var_types = ['x', 'unelim_u', 'w']
        if not self.eliminate_der_var:
            var_types = ['dx'] + var_types
        name_map = self.name_map
        var_map = self.var_map
        var_opt = {}
        op = self.op
        if self.variable_scaling:
            if self.nominal_traj is None:
                sf = self._sf
            else:
                name_idx_sf_map = self._name_idx_sf_map
                is_variant = self._is_variant
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e

        # Get copy of solution
        primal_opt = copy.copy(self.primal_opt)

        # Get element lengths
        if self.hs == "free":
            self.h_opt = N.hstack([N.nan, primal_opt[self.var_indices['h'][1:]]])
            h_scaled = self.horizon * self.h_opt
        else:
            h_scaled = self.horizon * N.array(self.h)

        # Create array with discrete times
        if self.result_mode == "collocation_points":
            if self.hs == "free":
                t_start = self.time[0]
                t_opt = [t_start]
                for h in h_scaled[1:]:
                    for k in xrange(1, self.n_cp + 1):
                        t_opt.append(t_start + self.pol.p[k] * h)
                    t_start += h
                t_opt = N.array(t_opt).reshape([-1, 1])
            else:
                t_opt = self.get_time().reshape([-1, 1])
        elif self.result_mode == "mesh_points":
            t_opt = [self.time[0]]
            for h in h_scaled[1:]:
                t_opt.append(t_opt[-1] + h)
            t_opt = N.array(t_opt).reshape([-1, 1])
        elif self.result_mode == "element_interpolation":
            t_opt = [self.time[0]]
            for i in xrange(1, self.n_e + 1):
                t_end = t_opt[-1] + h_scaled[i]
                t_i = N.linspace(t_opt[-1], t_end, self.n_eval_points)
                t_opt.extend(t_i)
            t_opt = N.array(t_opt[1:]).reshape([-1, 1])
        else:
            raise CasadiCollocatorException("Unknown result mode %s." %
                                            self.result_mode)

        # Create arrays for storage of variable trajectories
        for var_type in var_types + ['elim_u']:
            var_opt[var_type] = N.empty([len(t_opt), n_var[var_type]])
        var_opt['merged_u'] = N.empty([len(t_opt),
                                       n_var['unelim_u'] + n_var['elim_u']])
        if self.eliminate_der_var:
            var_opt['dx'] = N.empty([len(t_opt), n_var['x']])
        var_opt['p_opt'] = N.empty(n_var['p_opt'])

        # Get optimal parameter values and rescale
        p_opt = primal_opt[self.var_indices['p_opt']].reshape(-1)
        if self.variable_scaling and not self.write_scaled_result:
            if self.nominal_traj is None:
                p_opt *= sf['p_opt']
            else:
                p_opt_sf = N.empty(n_var['p_opt'])
                for var in mvar_vectors['p_opt']:
                    name = var.getName()
                    (ind, _) = name_map[name]
                    sf_index = name_idx_sf_map[name]
                    p_opt_sf[ind] = invariant_d[sf_index]
                p_opt *= p_opt_sf
        var_opt['p_opt'][:] = p_opt

        # Rescale solution
        time_points = self.get_time_points()
        if self.variable_scaling and not self.write_scaled_result:
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        for var in mvar_vectors[var_type]:
                            name = var.getName()
                            if (var_type != "unelim_u" or
                                self.blocking_factors is None or
                                name not in self.blocking_factors.factors):
                                (ind, _) = name_map[name]
                                global_ind = self.var_indices[var_type][i][k][ind]
                                xx_i_k = primal_opt[global_ind]
                                if self.nominal_traj is None:
                                    xx_i_k *= sf[var_type][ind]
                                else:
                                    sf_index = self._name_idx_sf_map[name]
                                    if self._is_variant[name]:
                                        xx_i_k *= variant_sf[i][k][sf_index]
                                    else:
                                        d = invariant_d[sf_index]
                                        e = invariant_e[sf_index]
                                        xx_i_k = d * xx_i_k + e
                                primal_opt[global_ind] = xx_i_k

        # Rescale inputs with blocking factors
        if (self.variable_scaling and not self.write_scaled_result and
            self.blocking_factors is not None):
            var_type = "unelim_u"
            k = 1
            for var in mvar_vectors[var_type]:
                name = var.getName()
                if name in self.blocking_factors.factors:
                    (ind, _) = name_map[name]
                    # Rescale once per factor
                    for i in N.cumsum(self.blocking_factors.factors[name]):
                        global_ind = self.var_indices[var_type][i][k][ind]
                        u_i_k = primal_opt[global_ind]
                        if self.nominal_traj is None:
                            u_i_k *= sf[var_type][ind]
                        else:
                            sf_index = self._name_idx_sf_map[name]
                            if self._is_variant[name]:
                                u_i_k *= variant_sf[i][k][sf_index]
                            else:
                                d = invariant_d[sf_index]
                                e = invariant_e[sf_index]
                                u_i_k = d * u_i_k + e
                        primal_opt[global_ind] = u_i_k

        # Rescale continuity variables
        if (self.variable_scaling and not self.eliminate_cont_var and
            not self.write_scaled_result):
            for i in xrange(1, self.n_e):
                k = self.n_cp + self.is_gauss
                x_i_k = primal_opt[self.var_indices['x'][i][k]]
                primal_opt[self.var_indices['x'][i + 1][0]] = x_i_k
        if (self.is_gauss and self.variable_scaling and 
            not self.eliminate_cont_var and not self.write_scaled_result):
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = primal_opt[self.var_indices['dx'][i][k]]
                        x_i_np1 += self.pol.w[k] * dx_i_k
                    x_i_np1 = (primal_opt[self.var_indices['x'][i][0]] + 
                               self.horizon * self.h[i] * x_i_np1)

                    # Rescale x_{i, n_cp + 1}
                    primal_opt[self.var_indices['x'][i][self.n_cp + 1]] = x_i_np1
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[self.var_indices['x'][i][k]]
                        x_i_np1 += x_i_k * self.pol.eval_basis(k, 1, True)

                    # Rescale x_{i, n_cp + 1}
                    primal_opt[self.var_indices['x'][i][self.n_cp + 1]] = x_i_np1
                    
        
        # Get solution trajectories
        t_index = 0
        if self.result_mode == "collocation_points":
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    var_opt['elim_u'][t_index, :] = self.var_map['elim_u'][i][k]['all']
                    t_index += 1
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[self.var_indices['dx'][i][k]]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1

                # Collocation point derivatives
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = 0
                        for l in xrange(self.n_cp + 1):
                            x_i_l = primal_opt[self.var_indices['x'][i][l]]
                            dx_i_k += (1. / h_scaled[i] * x_i_l * 
                                       self.pol.eval_basis_der(
                                           l, self.pol.p[k]))
                        var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                        t_index += 1
        elif self.result_mode == "element_interpolation":
            tau_arr = N.linspace(0, 1, self.n_eval_points)
            for i in xrange(1, self.n_e + 1):
                for tau in tau_arr:
                    # Non-derivatives and uneliminated inputs
                    for var_type in ['x', 'unelim_u', 'w']:
                        # Evaluate xx_i_tau based on polynomial xx^i
                        xx_i_tau = 0
                        for k in xrange(not cont[var_type], self.n_cp + 1):
                            xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                            xx_i_tau += xx_i_k * self.pol.eval_basis(
                                k, tau, cont[var_type])
                        var_opt[var_type][t_index, :] = xx_i_tau.reshape(-1)

                    # eliminated inputs
                    xx_i_tau = 0
                    for k in xrange(not cont[var_type], self.n_cp + 1):
                        xx_i_k = self.var_map['elim_u'][i][k]['all']
                        xx_i_tau += xx_i_k * self.pol.eval_basis(
                            k, tau, cont[var_type])
                    var_opt['elim_u'][t_index, :] = xx_i_tau.reshape(-1)

                    # Derivatives
                    dx_i_tau = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[self.var_indices['x'][i][k]]
                        dx_i_tau += (1. / h_scaled[i] * x_i_k * 
                                     self.pol.eval_basis_der(k, tau))
                    var_opt['dx'][t_index, :] = dx_i_tau.reshape(-1)

                    t_index += 1
        elif self.result_mode == "mesh_points":
            # Start time
            i = 1
            k = 0
            for var_type in var_types:
                xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
            var_opt['elim_u'][t_index, :] = self.var_map['elim_u'][i][k]['all']
            t_index += 1
            k = self.n_cp + self.is_gauss

            # Mesh points
            var_types.remove('x')
            if self.discr == "LGR":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    u_i_k = self.var_map['elim_u'][i][k]['all']
                    var_opt['elim_u'][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            elif self.discr == "LG":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        # Evaluate xx_{i, n_cp + 1} based on polynomial xx_i
                        xx_i_k = 0
                        for l in xrange(1, self.n_cp + 1):
                            xx_i_l = primal_opt[self.var_indices[var_type][i][l]]
                            xx_i_k += xx_i_l * self.pol.eval_basis(l, 1, False)
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    # Evaluate u_{i, n_cp + 1} based on polynomial u_i
                    u_i_k = 0
                    for l in xrange(1, self.n_cp + 1):
                        u_i_l = self.var_map['elim_u'][i][l]['all']
                        u_i_k += u_i_l * self.pol.eval_basis(l, 1, False)
                    var_opt['elim_u'][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            var_types.insert(0, 'x')

            # Handle states separately
            t_index = 1
            for i in xrange(1, self.n_e + 1):
                x_i_k = primal_opt[self.var_indices['x'][i][k]]
                var_opt['x'][t_index, :] = x_i_k.reshape(-1)
                t_index += 1

            # Handle state derivatives separately
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[self.var_indices['dx'][i][k]]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1

                # Mesh point state derivatives
                t_index = 1
                for i in xrange(1, self.n_e + 1):
                    dx_i_k = 0
                    for l in xrange(self.n_cp + 1):
                        x_i_l = primal_opt[self.var_indices['x'][i][l]]
                        dx_i_k += (1. / h_scaled[i] * x_i_l * 
                                   self.pol.eval_basis_der(l, 1.))
                    var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                    t_index += 1
        else:
            raise CasadiCollocatorException("Unknown result mode %s." %
                                            self.result_mode)

        # Merge uneliminated and eliminated inputs
        if self.n_var['u'] > 0:
            var_opt['merged_u'][:, self._unelim_input_indices] = \
                var_opt['unelim_u']
            var_opt['merged_u'][:, self._elim_input_indices] = \
                var_opt['elim_u']

        # Store optimal inputs for interpolator purposes
        if self.result_mode == "collocation_points":
            u_opt = var_opt['merged_u']
        else:
            t_index = 0
            u_opt = N.empty([self.n_e * self.n_cp + 1 + self.is_gauss,
                             self.n_var['u']])
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    unelim_u_i_k = primal_opt[self.var_indices['unelim_u'][i][k]]
                    u_opt[t_index, self._unelim_input_indices] = \
                        unelim_u_i_k.reshape(-1)
                    elim_u_i_k = self.var_map['elim_u'][i][k]['all']
                    u_opt[t_index, self._elim_input_indices] = \
                        elim_u_i_k.reshape(-1)
                    t_index += 1
        self._u_opt = u_opt

        # Denormalize minimum time problem
        if self._normalize_min_time:
            t0_var = op.getVariable('startTime')
            tf_var = op.getVariable('finalTime')
            if op.get_attr(t0_var, "free"):
                name = t0_var.getName()
                (ind, _) = name_map[name]
                t0 = var_opt['p_opt'][ind]
            else:
                t0 = op.get_attr(t0_var, "_value")
            if op.get_attr(tf_var, "free"):
                name = tf_var.getName()
                (ind, _) = name_map[name]
                tf = var_opt['p_opt'][ind]
            else:
                tf = op.get_attr(tf_var, "_value")
            t_opt = t0 + (tf - t0) * t_opt
            var_opt['dx'] /= (tf - t0)
        
        # Create array to storage eliminated variables
        n_eliminations = len(op.getEliminatedVariables())
        
        var_opt['elim_vars'] = N.ones([len(t_opt), n_eliminations])    
        if n_eliminations>0:
            # Compute eliminated variables
            t_index = 0
            var_kinds_ordered =copy.copy(self.mvar_struct.keys())
            del var_kinds_ordered[0]        
            for t in t_opt:
                index_var = 0
                self.elimination_fcn.setInput(t,0)
                self.elimination_fcn.setInput(self._par_vals,1)
                j=2
                for vk in var_kinds_ordered:
                    if self.n_var[vk]>0:
                        if vk is not 'p_opt':
                            var_input = var_opt[vk][t_index,:]
                        else:
                            var_input = var_opt[vk]
                        self.elimination_fcn.setInput(var_input,j)
                        j+=1
                self.elimination_fcn.evaluate()
                result = self.elimination_fcn.getOutput()
                for index_v in range(n_eliminations):
                    var_opt['elim_vars'][t_index,index_v] = result[index_v]
                t_index+=1 

        # Return results
        return (t_opt, var_opt['dx'], var_opt['x'], var_opt['merged_u'],
                var_opt['w'], var_opt['p_opt'], var_opt['elim_vars'])

    def get_h_opt(self):
        if self.hs == "free":
            return self.h_opt
        else:
            return None

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
            (t,dx_opt,x_opt,u_opt,w_opt,p_opt, elim_vars) = self.get_result()
            data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt,elim_vars))
        else:
            (t,dx_opt,x_opt,u_opt,w_opt,p_opt) = result
            data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt))

        if (format=='txt'):
            op = self.op
            name_map = self.name_map
            mvar_vectors = self.mvar_vectors
            variable_list = reduce(list.__add__,
                                   [list(mvar_vectors[vt]) for
                                    vt in ['p_opt', 'p_fixed',
                                           'dx', 'x', 'u', 'w']])
            if result is None:
                for v in op.getEliminatedVariables():
                    variable_list.append(v) 

            # Map variable to aliases
            alias_map = {}
            for var in variable_list:
                alias_map[var.getName()] = []
            for alias_var in op.getAliases():
                alias = alias_var.getModelVariable()
                alias_map[alias.getName()].append(alias_var)

            # Set up sections
            num_vars = len(op.getAllVariables()) + 1
            #num_vars -= len(op.getEliminatedVariables())
            name_section = []
            description_section = []
            data_info_section = []
            data_info_section.append('int dataInfo(%d,%d)\n' % (num_vars, 4))
            data_info_section.append('0 1 0 -1 # time\n')

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

            # Define section headers
            name_section.append('\n')
            name_section = ['char name(%d,%d)\n' % (num_vars, max_name_length),
                            'time\n'] + name_section
            description_section.append('\n')
            description_section = ['char description(%d,%d)\n' %
                                   (num_vars, max_desc_length),
                                   'Time in [s]\n'] + description_section
            data_info_section.append('\n')

            # Collect parameter data (data_1)
            data_1 = []
            for par in mvar_vectors['p_opt']:
                name = par.getName()
                (ind, _) = name_map[name]
                data_1.append(" %.14E" % p_opt[ind])

            for par in mvar_vectors['p_fixed']:
                data_1.append(" %.14E" % op.get_attr(par, "_value"))

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

            # Write names
            for name in name_section:
                f.write(name)

            # Write descriptions
            for description in description_section:
                f.write(description)

            # Write dataInfo
            for data_info in data_info_section:
                f.write(data_info)

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

    def get_opt_input(self):
        """
        Get the optimized input variables as a function of time.

        The purpose of this method is to conveniently provide the optimized
        input variables to a simulator.

        Returns::

            input_names --
                Tuple consisting of the names of the input variables.

            input_interpolator --
                Collocation polynomials for input variables as a function of
                time.
        """
        # Consider: do we actually need to save _xi, _ti, and _hi in self?
        if self.hs == "free":
            self._hi = map(lambda h: self.horizon * h, self.h_opt)
        else:
            self._hi = map(lambda h: self.horizon * h, self.h)
        
        xi = self._u_opt[1:self.n_e*self.n_cp+1]
        self._xi = xi.reshape(self.n_e, self.n_cp, self.n_var['u'])
        self._ti = N.cumsum([self.t0] + self._hi[1:])
        input_names = tuple([u.getName() for u in self.mvar_vectors['u']])
        return (input_names, self._create_input_interpolator(self._xi, self._ti, self._hi))

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
            raise CasadiCollocatorException(
                "named_var_expr only works if named_vars is enabled.")

    def get_J(self, point="fcn"):
        """
        Get the Jacobian of the constraints.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "function"
        
        Returns::
            
            matrix --
                Matrix value
        """
        J_fcn = self.solver_object.jacG()
        if point == "fcn":
            return J_fcn
        elif point == "init":
            J_fcn.setInput(self.xx_init, 0)
        elif point == "opt":
            J_fcn.setInput(self.primal_opt, 0)
        elif point == "sym":
            return J_fcn.call([self.xx, []],True)[0]
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        J_fcn.setInput(self._par_vals, 1)
        J_fcn.evaluate()
        return J_fcn.output(0).toArray()
    
    def get_H(self, point="fcn"):
        """
        Get the Hessian of the Lagrangian.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "function"
        
        Returns::
            
            matrix --
                Matrix value

            sigma --
                Symbolic sigma. Only returned if point is "sym".

            dual --
                Symbolic dual variables. Only returned if point is "sym".
        """
        H_fcn = self.solver_object.hessLag()
        if point == "fcn":
            return H_fcn
        elif point == "init":
            x = self.xx_init
            sigma = self._compute_sigma()
            dual = N.zeros(self.c_e.numel() +
                           self.c_i.numel())
            H_fcn.setInput(x, 0)
            H_fcn.setInput(self._par_vals, 1)
            H_fcn.setInput(sigma, 2)
            H_fcn.setInput(dual, 3)
        elif point == "opt":
            x = self.primal_opt
            sigma = self._compute_sigma()
            dual = self.dual_opt['g']
            H_fcn.setInput(x, 0)
            H_fcn.setInput(self._par_vals, 1)
            H_fcn.setInput(sigma, 2)
            H_fcn.setInput(dual, 3)
        elif point == "sym":
            nu = casadi.MX.sym("nu", self.c_e.numel())
            sigma = casadi.MX.sym("sigma")
            lam = casadi.MX.sym("lambda", self.c_i.numel())
            dual = casadi.vertcat([nu, lam])
            return [H_fcn.call([self.xx, [], sigma, dual],True)[0], sigma,
                    dual]
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        H_fcn.evaluate()
        return H_fcn.output(0).toArray()

    def get_KKT(self, point="fcn"):
        """
        Get the KKT matrix.

        This only constructs the simple KKT system [H, J^T; J, 0]; not the full
        KKT system used by IPOPT. However, if the problem has no inequality
        constraints (including bounds), they coincide.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "function"
        
        Returns::
            
            matrix --
                Matrix value

            sigma --
                Symbolic sigma. Only returned if point is "sym".

            dual --
                Symbolic dual variables. Only returned if point is "sym".
        """
        if point == "fcn" or point == "sym":
            x = self.xx
            J = self.get_J("sym")
            [H, sigma, dual] = self.get_H("sym")
            zeros = N.zeros([dual.numel(), dual.numel()])
            KKT = casadi.blockcat([[H, J.T], [J, zeros]])
            if point == "sym":
                return KKT
            else:
                KKT_fcn = casadi.MXFunction([x, [], sigma, dual], [KKT])
                return KKT_fcn
        elif point == "init":
            x = self.xx_init
            dual = N.zeros(self.c_e.numel() +
                           self.c_i.numel())
        elif point == "opt":
            x = self.primal_opt
            dual = self.dual_opt['g']
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        sigma = self._compute_sigma()
        J = self.get_J(point)
        H = self.get_H(point)
        zeros = N.zeros([len(dual), len(dual)])
        KKT = N.bmat([[H, J.T], [J, zeros]])
        return KKT

    def _compute_sigma(self):
        """
        Computes the objective scaling factor sigma.
        """
        grad_fcn = self.solver_object.gradF()
        grad_fcn.setInput(self.xx_init, 0)
        grad_fcn.setInput(self._par_vals, 1)
        grad_fcn.evaluate()
        grad = grad_fcn.output(0).toArray()
        sigma_inv = N.linalg.norm(grad, N.inf)
        if sigma_inv < 1000.:
            return 1.
        else:
            return 1. / sigma_inv


class MeasurementData(object):

    """
    This class is obsolete and replaced by ExternalData.
    """
    
    def __init__(self, eliminated=OrderedDict(), constrained=OrderedDict(),
                 unconstrained=OrderedDict(), Q=None):
        raise DeprecationWarning('MeasurementData is obsolete. ' +
                                 'Use ExternalData instead.')

class LocalDAECollocationAlgResult(JMResultBase):
    
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
        
        h_opt --
            An array with the normalized optimized element lengths.
            
            The element lengths are only optimized (and stored in a class
            instance) if the algorithm option "hs" == free. Otherwise this
            attribute is None.
            
            Type: ndarray of floats or None
    """
    
    def __init__(self, model=None, result_file_name=None, solver=None, 
                 result_data=None, options=None, times=None, h_opt=None):
        super(LocalDAECollocationAlgResult, self).__init__(
                model, result_file_name, solver, result_data, options)
        self.h_opt = h_opt
        self.times = times
        
        # Save values from the solver since they might change in the solver.
        # Assumes that solver.primal_opt and solver.dual_opt will not be mutated, which seems to be the case.
        self.primal_opt = solver.primal_opt
        self.dual_opt = solver.dual_opt
        self.solver_statistics = solver.get_solver_statistics()
        self.opt_input = solver.get_opt_input()
        
        # Print times
        print("\nTotal time: %.2f seconds" % times['tot'])
        print("Pre-processing time: %.2f seconds" % times['init'])
        print("Solution time: %.2f seconds" % times['sol'])
        print("Post-processing time: %.2f seconds\n" %
              times['post_processing'])

        # Print condition numbers
        if self.options['print_condition_numbers']:
            J_init_cond = N.linalg.cond(solver.get_J("init"))
            J_opt_cond = N.linalg.cond(solver.get_J("opt"))
            KKT_init_cond = N.linalg.cond(solver.get_KKT("init"))
            KKT_opt_cond = N.linalg.cond(solver.get_KKT("opt"))
            print("\nJacobian condition number at the initial guess: %.3g" %
                  J_init_cond)
            print("Jacobian condition number at the optimum: %.3g" %
                  J_opt_cond)
            print("KKT matrix condition number at the initial guess: %.3g" %
                  KKT_init_cond)
            print("KKT matrix condition number at the optimum: %.3g" %
                  KKT_opt_cond)

    def get_opt_input(self):
        """
        Get the optimized input variables as a function of time.

        The purpose of this method is to conveniently provide the optimized
        input variables to a simulator.

        Returns::

            input_names --
                Tuple consisting of the names of the input variables.

            input_interpolator --
                Collocation polynomials for input variables as a function of
                time.
        """
        return self.opt_input

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
        return self.solver_statistics


class OptimizationSolver(object):
    """
    Represents an initialized optimization problem that can be reoptimized with different settings.

    Wrapper class around LocalDAECollocator to supply a user interface for warm starting.
    """

    def __init__(self, collocator):
        """
        Create a wrapper around a collocator object to expose reoptimization functionality.

        The collocator should be a LocalDAECollocator.
        """
        self.collocator = collocator

    def set(self, name, value):
        """Set the value of the named parameter from the original OptimizationProblem"""
        if name not in self.collocator.var_indices:
            raise KeyError("No parameter " + repr(name) + " in the optimization problem.")
        self.collocator._par_vals[self.collocator.var_indices[name]] = value

    def get(self, name):
        """Get the value of the named parameter from the original OptimizationProblem"""
        if name not in self.collocator.var_indices:
            raise KeyError("No parameter " + repr(name) + " in the optimization problem.")
        return self.collocator._par_vals[self.collocator.var_indices[name]]

    def set_solver_option(self, solver_name, name, value):
        """
        Set an option to the nonlinear programming solver.

        If solver_name does not correspond to the 'solver' option used
        in the optimization, the call is ignored.
        """
        if solver_name not in ['IPOPT', 'WORHP']:
            raise ValueError('Unknown nonlinear programming solver %s.' %
                             solver_name)
        if solver_name == self.collocator.solver:
            self.collocator.set_solver_option(name, value)

    def optimize(self):
        """Solve the optimization problem with the current settings, and return the result."""
        if self.collocator.warm_start:
            # It would be good to expose a way for the user to provide an initial guess at some point,
            # how to expose that option?
            self.collocator.xx_init = self.collocator.primal_opt

            self.collocator._init_and_set_solver_inputs()

        self.collocator.solve_and_write_result()
        return self.collocator.get_result_object()

    def set_warm_start(self, warm_start):
        """Set whether warm start is enabled for the optimization"""
        self.collocator.warm_start = warm_start
