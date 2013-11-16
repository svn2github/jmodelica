#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2011 Modelon AB
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
from operator import itemgetter
import itertools
import time
import copy
import types
from collections import OrderedDict
    
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
        return casadi.SXMatrix()
        
    def get_equality_constraint(self):
        """
        Get the equality constraint h(x) = 0.0
        """
        return casadi.SXMatrix()
        
    def set_ipopt_option(self, k, v):
        """
        Sets IPOPT options.
            
            Parameters::
            
                k - Name of the option
                v - Value of the option (int, double, string)
        """
        self.solver.setOption(k,v)

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
            start_values = dict([(start[i][0],start[i][1]) for i in range(len(start))])
            
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
                key=itemgetter(0))
            aliases = sorted(zip(
                tuple(vrefs), 
                tuple(aliases)), 
                key=itemgetter(0))
            descriptions = sorted(zip(
                tuple(vrefs), 
                tuple(descriptions)), 
                key=itemgetter(0))
            variabilities = sorted(zip(
                tuple(vrefs), 
                tuple(variabilities)), 
                key=itemgetter(0))
            
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
            raise Error('Export on binary Dymola result files not yet supported.')
        
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
        if self.hs == "free":
            self._hi = map(lambda h: self.horizon * h, self.h_opt)
        else:
            self._hi = map(lambda h: self.horizon * h, self.h)
        self._xi = self._u_opt[1:].reshape(self.n_e, self.model.n_u, self.n_cp)
        self._xi = N.transpose(self._xi, [0, 2, 1])
        self._ti = N.cumsum([self.t0] + self._hi[1:])
        input_names = tuple([repr(u) for u in self.model.u])
        return (input_names, self._input_interpolator)
    
    def _input_interpolator(self, t):
        i = N.clip(N.searchsorted(self._ti, t), 1, self.n_e)
        tau = (t - self._ti[i - 1]) / self._hi[i]
        
        x = 0
        for k in xrange(self.n_cp):
            x += self._xi[i - 1, k, :] * self.pol.eval_basis(k + 1, tau, False)
        return x
    
    def get_ipopt_statistics(self):
        """ 
        Get statistics from the last optimization.

        Returns::
        
            return_status -- 
                Return status from IPOPT.
                
            nbr_iter -- 
                Number of iterations.
                
            objective -- 
                Final value of objective function.
                
            total_exec_time -- 
                IPOPT execution time.
        """
        stats = self.solver.getStats()
        return_status = stats['return_status']
        nbr_iter = stats['iter_count']
        objective = float(self.solver.output(casadi.NLP_SOLVER_F))
        total_exec_time = stats['t_mainloop']
        return (return_status, nbr_iter, objective, total_exec_time)
    
    def ipopt_solve(self):
        """
        Solves the NLP using IPOPT.
        
        Returns::
        
            sol_time --
                Duration (seconds) of call to IPOPT.
                Type: float
        """
        # Initialize solver
        self.solver.init()
        
        # Initial condition
        self.solver.setInput(self.get_xx_init(), casadi.NLP_SOLVER_X0)
        
        # Bounds on x
        self.solver.setInput(self.get_xx_lb(), casadi.NLP_SOLVER_LBX)
        self.solver.setInput(self.get_xx_ub(), casadi.NLP_SOLVER_UBX)
        
        # Bounds on the constraints
        n_h = self.get_equality_constraint().numel()
        hublb = n_h * [0]
        n_g = self.get_inequality_constraint().numel()
        gub = n_g * [0]
        glb = n_g * [self.LOWER]
        self.glub = hublb + gub
        self.gllb = hublb + glb
        
        self.solver.setInput(self.gllb, casadi.NLP_SOLVER_LBG)
        self.solver.setInput(self.glub, casadi.NLP_SOLVER_UBG)
        
        # Solve the problem
        t0 = time.clock()
        self.solver.solve()
        
        # Get the result
        primal_opt = N.array(self.solver.output(casadi.NLP_SOLVER_X))
        self.primal_opt = primal_opt.reshape(-1)
        dual_opt = N.array(self.solver.output(casadi.NLP_SOLVER_LAM_G))
        self.dual_opt = dual_opt.reshape(-1)
        sol_time = time.clock() - t0
        return sol_time

class MeasurementData(object):
    
    """
    Numerical data connected to variables.
    
    The data can for each variable be treated in three different ways.
    
    eliminated --
        The data for these inputs is used to eliminate the corresponding NLP
        variables.
    
    constrained --
        The data for these inputs is used to constrain the corresponding NLP
        variables with equality constraints in each collocation point. A
        quadratic penalty is also introduced for these inputs.
    
    unconstrained --
        The data is only used to form a quadratic penalty for these variables.
    
    eliminated and constrained must be inputs, whereas unconstrained can be any
    kind of variables.
    
    The data for each variable is either a user-defined function of time, or
    a matrix with two rows where the first row is points in time and the
    second row is values for the variable at the corresponding points in time.
    In the second case, the given data is linearly interpolated to get the
    values at the collocation points.
    """

    def __init__(self, eliminated=OrderedDict(), constrained=OrderedDict(),
                 unconstrained=OrderedDict(), Q=None):
        """
        The following quadratic cost is formed:
               
        .. math::

            f = \int_{t_0}^{t_f} (y(t) - y_m(t)) \cdot Q \cdot
            (y(t) - y_m(t))\,\mathrm{d}t,
            
        where y is the function created by gluing together the
        collocation polynomials for the constrained and unconstrained variables
        at all the mesh points and y_m is a function providing the measured
        values at a given time point. If the variable data are a matrix, the
        data are linearly interpolated to create the function y_m. If the data
        are a function, then this function defines y_m.
        
        Parameters::
            
            eliminated --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to eliminate the inputs.
                
                Type: OrderedDict
                Default: OrderedDict()
            
            constrained --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to constrain and penalize the
                inputs.
                
                Type: OrderedDict
                Default: OrderedDict()
            
            unconstrained --
                Dictionary with variable names as keys and the values are the
                corresponding data used to penalize the variables.
                
                Type: OrderedDict
                Default: OrderedDict()
            
            Q --
                Weighting matrix used to form the quadratic penalty for the
                constrained and unconstrained variables. The order of the
                variables is the same as in constrained_inputs and
                unconstrained_variables, with the constrained inputs coming
                first.
                
                Type: rank 2 ndarray
                Default: None
        
        Limitations::
            
            Variable names for constrained and eliminated inputs do not take
            aliases into account; these variables have to be referenced by the
            name used in CasadiModel.
        """
        # Check dimension of Q
        Q_len = ((0 if constrained is None else len(constrained)) + 
                 (0 if unconstrained is None else len(unconstrained)))
        if Q_len > 0 and (Q.shape[0] != Q.shape[1] or Q.shape[0] != Q_len):
            raise ValueError("Weighting matrix Q must be square and have " +
                             "the same dimension as the total number of " +
                             "constrained and unconstrained variables.")
        
        # Transform data into trajectories
        eliminated = copy.copy(eliminated)
        constrained = copy.copy(constrained)
        unconstrained = copy.copy(unconstrained)
        for variable_list in [eliminated, constrained, unconstrained]:
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
        self.constrained = constrained
        self.unconstrained = unconstrained
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

class LocalDAECollocator(CasadiCollocator):
    
    """Solves an optimal control problem using local collocation."""
    
    def __init__(self, model, options):
        super(LocalDAECollocator, self).__init__(model)
        
        # Check normalization of minimum time problems
        t0 = self.ocp.variable('startTime')
        tf = self.ocp.variable('finalTime')
        if (t0.getFree() and self.ocp.t0_free or
            tf.getFree() and self.ocp.tf_free):
            raise CasadiCollocatorException(
                    "Problems with free start or final time must be " +
                    'compiled with the compiler option "normalize_minimum_' +
                    'time_problems" enabled.')
        
        # Get the options
        self.__dict__.update(options)
        
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
            raise ValueError("Unknown discretization scheme %s." % self.discr)
        
        # Update scaling factors
        self.model._update_sf()
        
        # Get to work
        self._create_nlp()
    
    def _create_nlp(self):
        """
        Wrapper for creating the NLP.
        """
        self._get_ocp_expressions()
        self._define_collocation()
        self._create_nlp_variables()
        self._rename_variables()
        self._create_constraints()
        self._create_cost()
        self._compute_bounds_and_init()
        self._create_solver()
    
    def _get_ocp_expressions(self):
        """
        Get OCP expressions from model and scale them if necessary.
        
        Timed variables are not scaled until _create_constraints, at
        which point the constraint points are known.
        """
        # Get OCP expressions
        self.initial = casadi.SXMatrix(self.model.get_initial(False))
        self.ode = casadi.SXMatrix(self.model.get_ode(False))
        self.alg = casadi.SXMatrix(self.model.get_alg(False))
        self.path = casadi.SXMatrix(self.model.get_path(False))
        self.point = casadi.SXMatrix(self.model.get_point(False))
        self.mterm = casadi.SXMatrix(self.model.get_mterm(False))
        self.lterm = casadi.SXMatrix(self.model.get_lterm(False))
        
        # Create input lists
        if (self.measurement_data is None or
            len(self.measurement_data.eliminated) == 0):
            elim_input_indices = []
        else:
            input_names = [repr(u) for u in self.model.u]
            try:
                elim_input_indices = [
                        input_names.index(u) for u in
                        self.measurement_data.eliminated.keys()]
            except ValueError:
                raise jmiVariableNotFoundError(
                        "Eliminated input " + u + " is either not an input " +
                        "or not in the model at all.")
        unelim_input_indices = [i for i in range(self.model.u.numel()) if
                                i not in elim_input_indices]
        self._unelim_input_indices = unelim_input_indices
        self._elim_input_indices = elim_input_indices
        self._model_unelim_u = self.model.u[unelim_input_indices]
        self._model_elim_u = self.model.u[elim_input_indices]
        
        sym_input = casadi.vertcat([self.model.t,
                                    self.model.dx,
                                    self.model.x,
                                    self._model_unelim_u,
                                    self.model.w,
                                    self.model.p,
                                    self._model_elim_u])
        sym_input_elim_der = casadi.vertcat([self.model.t,
                                             self.model.x,
                                             self._model_unelim_u,
                                             self.model.w,
                                             self.model.p,
                                             self._model_elim_u])
        self._sym_input = sym_input
        self._sym_input_elim_der = sym_input_elim_der
        
        # Scale variables
        if self.variable_scaling and self.nominal_traj is None:
            # Get scale factors
            sf = copy.copy(self.model.get_sf(False))
            sf['unelim_u'] = sf['u'][unelim_input_indices]
            del sf['u']
            self._sf = sf
            if (self.measurement_data is None or
                len(self.measurement_data.eliminated) == 0):
                variables = sym_input[1:]
            else:
                variables = sym_input[1:-len(elim_input_indices)]
            sfs = N.concatenate([sf['dx'],
                                 sf['x'],
                                 sf['unelim_u'],
                                 sf['w'],
                                 sf['p_opt']])
            
            # Insert scale factors
            ocp_expressions = [self.initial, self.ode, self.alg, self.path,
                               self.point, self.mterm, self.lterm]
            [self.initial,
             self.ode,
             self.alg,
             self.path,
             self.point,
             self.mterm,
             self.lterm] = casadi.substitute(ocp_expressions, [variables],
                                             [sfs * variables])
    
    def _define_collocation(self):
        """
        Define collocation variables.
        
        The variables are used for either creating the collocation constraints
        or eliminating the derivative variables.
        """
        collocation = {}
        dx_i_k = casadi.ssym("dx_i_k", self.model.get_n_x())
        x_i = casadi.ssym("x_i", self.model.get_n_x(), self.n_cp + 1)
        der_vals_k = casadi.ssym("der_vals[k]", self.model.get_n_x(),
                                 self.n_cp + 1)
        h_i = casadi.ssym("h_i")
        collocation['coll_der'] = casadi.sumCols(x_i * der_vals_k) / h_i
        collocation['coll_eq'] = casadi.sumCols(x_i * der_vals_k) - h_i*dx_i_k
        collocation['dx_i_k'] = dx_i_k
        collocation['x_i'] = x_i
        collocation['der_vals_k'] = der_vals_k
        collocation['h_i'] = h_i
        self._collocation = collocation
    
    def _create_nlp_variables(self, rename=False):
        """
        Create the NLP variables and store them in a nested dictionary.
        """
        # Set model info
        n_var = {'dx': self.model.get_n_x(), 'x': self.model.get_n_x(),
                 'unelim_u': self._model_unelim_u.numel(),
                 'w': self.model.get_n_w()}
        n_u = self._model_unelim_u.numel()
        self._n_var = copy.copy(n_var)
        if self.blocking_factors is not None:
            del n_var['unelim_u']
        if self.eliminate_der_var:
            del n_var['dx']
        
        # Count NLP variables
        n_xx = self.model.get_n_p()
        n_xx += (1 + self.n_e * self.n_cp) * N.sum(n_var.values())
        if self.eliminate_der_var:
            n_xx += n_var['x'] # dx_1_0
        if self.blocking_factors is not None:
            self.blocking_factors = list(self.blocking_factors)
            n_xx += len(self.blocking_factors) * n_u
        if not self.eliminate_cont_var:
            n_xx += (self.n_e - 1) * n_var['x']
        self.is_gauss = (self.discr == "LG")
        if self.is_gauss:
            n_xx += (self.n_e - 1) * n_var['x'] # Mesh points
            n_xx += N.sum(n_var.values()) # tf
        if self.hs == "free":
            n_xx += self.n_e
        
        # Create NLP variables
        if self.graph == "MX":
            xx = casadi.msym("xx", n_xx)
        elif self.graph == "SX":
            xx = casadi.ssym("xx", n_xx)
        else:
            raise ValueError("Unknown CasADi graph %s." % self.graph)
        
        # Get variables with correct names
        if rename:
            xx = self.xx
        
        # Create objects for variable indexing
        var_map = {}
        var_indices = {}
        index = 0
        
        # Index the parameters
        new_index = index + self.model.get_n_p()
        var_indices['p_opt'] = range(index, new_index)
        index = new_index
        var_map['p_opt'] = xx[var_indices['p_opt']]
        
        # Index the variables at the collocation points
        for i in xrange(1, self.n_e + 1):
            var_indices[i] = {}
            var_map[i] = {}
            for k in xrange(1, self.n_cp + 1):
                var_indices[i][k] = {}
                var_map[i][k] = {}
                for var_type in n_var.keys():
                    new_index = index + n_var[var_type]
                    var_indices[i][k][var_type] = range(index, new_index)
                    index = new_index
                    var_map[i][k][var_type] = xx[var_indices[i][k][var_type]]
        
        # Index controls separately if blocking_factors is not None
        if self.blocking_factors is not None:
            element = 1
            for factor in self.blocking_factors:
                new_index = index + n_u
                indices = range(index, new_index)
                for i in xrange(element, element + factor):
                    for k in xrange(1, self.n_cp + 1):
                        var_indices[i][k]['unelim_u'] = indices
                        var_map[i][k]['unelim_u'] = \
                                xx[var_indices[i][k]['unelim_u']]
                index = new_index
                element += factor
        
        # Index state continuity variables
        if self.discr == "LGR":
            if self.eliminate_cont_var:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    var_indices[i][0]['x'] = var_indices[i - 1][self.n_cp]['x']
                    var_map[i][0]['x'] = var_map[i - 1][self.n_cp]['x']
            else:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    new_index = index + n_var['x']
                    var_indices[i][0]['x'] = range(index, new_index)
                    index = new_index
                    var_map[i][0]['x'] = xx[var_indices[i][0]['x']]
        elif self.discr == "LG":
            # Index x_{i, n_cp + 1}
            for i in xrange(1, self.n_e):
                var_indices[i][self.n_cp + 1] = {}
                var_map[i][self.n_cp + 1] = {}
                
                new_index = index + n_var['x']
                var_indices[i][self.n_cp + 1]['x'] = range(index, new_index)
                index = new_index
                var_map[i][self.n_cp + 1]['x'] = \
                        xx[var_indices[i][self.n_cp + 1]['x']]
            
            # Index x_{i, 0}
            if self.eliminate_cont_var:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    var_indices[i][0]['x'] = \
                            var_indices[i - 1][self.n_cp + 1]['x']
                    var_map[i][0]['x'] = var_map[i - 1][self.n_cp + 1]['x']
            else:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    new_index = index + n_var['x']
                    var_indices[i][0]['x'] = range(index, new_index)
                    index = new_index
                    var_map[i][0]['x'] = xx[var_indices[i][0]['x']]
        else:
            raise ValueError("Unknown discretization scheme %s." %
                             self.discr)
        
        # Index variables for final mesh point
        if self.is_gauss:
            i = self.n_e
            k = self.n_cp + 1
            var_indices[i][k] = {}
            var_map[i][k] = {}
            for var_type in n_var.keys():
                new_index = index + n_var[var_type]
                var_indices[i][k][var_type] = range(index, new_index)
                index = new_index
                var_map[i][k][var_type] = xx[var_indices[i][k][var_type]]
        
        # Index the variables for the derivative initial values
        var_map[1][0] = {}
        var_indices[1][0] = {}
        if self.eliminate_der_var:
            new_index = index + n_var['x']
            var_indices[1][0]['dx'] = range(index, new_index)
            index = new_index
            var_map[1][0]['dx'] = xx[var_indices[1][0]['dx']]
        
        # Index the variables for the remaining initial values
        for var_type in n_var.keys():
            new_index = index + n_var[var_type]
            var_indices[1][0][var_type] = range(index, new_index)
            index = new_index
            var_map[1][0][var_type] = xx[var_indices[1][0][var_type]]
            
        # Index initial controls separately if blocking_factors is not None
        if self.blocking_factors is not None:
            var_indices[1][0]['unelim_u'] = var_indices[1][1]['unelim_u']
            var_map[1][0]['unelim_u'] = xx[var_indices[1][0]['unelim_u']]
            
        # Index element lengths
        if self.hs == "free":
            new_index = index + self.n_e
            var_indices['h'] = [N.nan] + range(index, new_index)
            index = new_index
            self.h = casadi.vertcat([N.nan, xx[var_indices['h'][1:]]])
        
        assert(index == n_xx)
        
        # Save variables and indices as data attributes
        self.xx = xx
        self.n_xx = n_xx
        self.var_map = var_map
        self.var_indices = var_indices
        
    def _rename_variables(self):
        """
        Renames the NLP variables.
        
        This only works for SX graphs. It's also done in a very inefficient
        manner and should only be used for debugging purposes. The NLP
        variables are essentially created twice; first with incorrect names and
        then recreated with correct names.
        """
        if self.rename_vars:
            if self.graph != "SX":
                raise NotImplementedError("Variable renaming only works " + \
                                          "for SX graphs.")
            xx = casadi.SXMatrix(self.n_xx, 1)
            var_indices = self.var_indices
            
            for i in xrange(1, self.n_e+1):
                if self.hs == "free":
                    xx[var_indices['h'][i]] = casadi.ssym("h_" + str(i))
                for k in var_indices[i].keys():
                    if (not self.eliminate_der_var and
                        'dx' in var_indices[i][k].keys()):
                        dx = casadi.SXMatrix(self.model.get_n_x(), 1)
                        for j in xrange(self.model.get_n_x()):
                            dx[j, 0] = (
                                    casadi.ssym(str(self.model.get_dx()[j]) +
                                    '_' + str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['dx'], 0] = dx
                    
                    if not self.eliminate_cont_var or k > 0 or i == 1:
                        if 'x' in var_indices[i][k].keys():
                            x = casadi.SXMatrix(self.model.get_n_x(), 1)
                            for j in xrange(self.model.get_n_x()):
                                x[j, 0] = (
                                        casadi.ssym(str(self.model.get_x()[j]) +
                                        '_' +  str(i) + '_' + str(k)))
                            xx[var_indices[i][k]['x'], 0] = x
                    
                    if 'unelim_u' in var_indices[i][k].keys():
                        u = casadi.SXMatrix(self._model_unelim_u.numel(), 1)
                        for j in xrange(self._model_unelim_u.numel()):
                            u[j, 0] = (
                                    casadi.ssym(str(self._model_unelim_u[j]) +
                                    '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['unelim_u'], 0] = u
                    
                    if 'w' in var_indices[i][k].keys():
                        w = casadi.SXMatrix(self.model.get_n_w(), 1)
                        for j in xrange(self.model.get_n_w()):
                            w[j, 0] = (
                                    casadi.ssym(str(self.model.get_w()[j]) +
                                    '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['w'], 0] = w
            
            if 'p_opt' in var_indices.keys():
                p_opt = casadi.SXMatrix(self.model.get_n_p(), 1)
                for j in xrange(self.model.get_n_p()):
                    p_opt[j, 0] = casadi.ssym(str(self.model.get_p()[j]))
                xx[var_indices['p_opt'], 0] = p_opt
            
            # Derivative initial values
            if self.eliminate_der_var:
                dx = casadi.SXMatrix(self.model.get_n_x(), 1)
                for j in xrange(self.model.get_n_x()):
                    dx[j, 0] = casadi.ssym(
                            str(self.model.get_dx()[j]) + '_1_0')
                xx[var_indices[1][0]['dx'], 0] = dx
            
            self.xx = xx
            self._create_nlp_variables(True)
    
    def _get_z(self, i, k):
        """
        Return a vector with all the NLP variables at a collocation point.
        
        Assumes the state derivatives are NLP variables.
        
        Parameters::
        
            i --
                Element index.
                Type: int
                 
            k --
                Collocation point.
                Type: int
                
        Returns::
        
            z --
                NLP variable vector.
                Type: MX or SXMatrix
        """
        z = casadi.vertcat([self.time_points[i][k],
                            self.var_map[i][k]['dx'],
                            self.var_map[i][k]['x'],
                            self.var_map[i][k]['unelim_u'],
                            self.var_map[i][k]['w'],
                            self.var_map['p_opt'],
                            self.var_map[i][k]['elim_u']])
        return z
    
    def _get_z_elim_der(self, i, k):
        """
        Return a vector with all the NLP variables at a collocation point.
        
        Assumes the state derivatives are not NLP variables.
        
        Parameters::
        
            i --
                Element index.
                Type: int
                 
            k --
                Collocation point.
                Type: int
                
        Returns::
        
            z --
                NLP variable vector.
                
                Type: MX or SXMatrix
        """
        z = casadi.vertcat([self.time_points[i][k],
                            self.var_map[i][k]['x'],
                            self.var_map[i][k]['unelim_u'],
                            self.var_map[i][k]['w'],
                            self.var_map['p_opt'],
                            self.var_map[i][k]['elim_u']])
        return z
    
    def _eliminate_der_var(self):
        """
        Eliminate derivative variables from OCP expressions.
        """
        if self.eliminate_der_var:
            coll_der = self._collocation['coll_der']
            self.ode_t0 = self.ode
            self.alg_t0 = self.alg
            ocp_expressions = [self.ode,
                               self.alg,
                               self.path,
                               self.point,
                               self.mterm,
                               self.lterm]
            [self.ode,
             self.alg,
             self.path,
             self.point,
             self.mterm,
             self.lterm] = casadi.substitute(ocp_expressions, [self.model.dx],
                                             [coll_der])
    
    def _create_constraints(self):
        """
        Create the constraints and time points.
        """
        # Get local references
        var_map = self.var_map
        var_vectors = copy.copy(self.model._var_vectors)
        var_vectors['unelim_u'] = copy.copy([var_vectors['u'][i] for
                                             i in self._unelim_input_indices])
        var_vectors['elim_u'] = copy.copy([var_vectors['u'][i] for
                                           i in self._elim_input_indices])
        del var_vectors['u']
        self._var_vectors = var_vectors
        
        # Update inputs in vr_map
        vr_map = copy.copy(self.model.get_vr_map())
        for vt in ['elim_u', 'unelim_u']:
            for ind in xrange(len(var_vectors[vt])):
                vr = var_vectors[vt][ind].getValueReference()
                vr_map[vr] = (ind, vt)
        self._vr_map = vr_map
        
        # Check that only inputs are constrained or eliminated
        if self.measurement_data is not None:
            for var_name in (self.measurement_data.eliminated.keys() +
                             self.measurement_data.constrained.keys()):
                vr = self.model.xmldoc.get_value_reference(var_name)
                (_, vt) = vr_map[vr]
                if vt not in ['elim_u', 'unelim_u']:
                    if var_name in self.measurement_data.eliminated.keys():
                        msg = ("Eliminated variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    else:
                        msg = ("Constrained variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    raise jmiVariableNotFoundError(msg)
        
        # Broadcast self.pol.der_vals
        # Note that der_vals is quite different from self.pol.der_vals
        der_vals = []
        self.der_vals = der_vals
        for k in xrange(self.n_cp + 1):
            der_vals_k = [self.pol.der_vals[:, k].reshape([1, self.n_cp + 1])]
            der_vals_k *= self.model.get_n_x()
            der_vals.append(casadi.vertcat(der_vals_k))
            
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
        
        # Map constraint points to collocation points
        if not self.ocp.point.empty() and self.hs == "free":
            raise CasadiCollocatorException("Point constraints can not be " +
                                            "combined with free element " +
                                            "lengths.")
        if self.graph == "SX":
            nlp_timed_variables = casadi.SXMatrix()
        else:
            nlp_timed_variables = casadi.MX()
        if self.hs == "free":
            timed_variables = casadi.SXMatrix()
        else:
            collocation_constraint_points = []
            for constraint_point in self.ocp.tp:
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
                        collocation_constraint_points.append((1, 0))
                    elif (self.is_gauss and
                          N.allclose(constraint_point, self.tf)):
                        collocation_constraint_points.append(
                                (self.n_e, self.n_cp + 1))
                    else:
                        raise CasadiCollocatorException(
                                "Constraint point " + `constraint_point` +
                                " does not coincide with a collocation point.")
                else:
                    (e, cp) = divmod(tp_index, self.n_cp)
                    collocation_constraint_points.append((e + 1, cp + 1))
        
            # Compose timed variables and corresponding NLP variables
            var_vector_list = [var_vectors['x'],
                               var_vectors['unelim_u'],
                               var_vectors['w']]
            timed_variables = casadi.SXMatrix(
                    [vari.atTime(tp, True) for
                     tp in self.ocp.tp for
                     var_vector in var_vector_list for
                     vari in var_vector])
            for (i, k) in collocation_constraint_points:
                for var_type in ['x', 'unelim_u', 'w']:
                    nlp_timed_variables.append(var_map[i][k][var_type])
            
            # Check that point constraints do not depend on eliminated inputs
            timed_inputs = casadi.SXMatrix(
                    [vari.atTime(tp, True) for
                     tp in self.ocp.tp for
                     vari in var_vectors['elim_u']])
            if not casadi.isZero(casadi.jacobian(self.point, timed_inputs)):
                raise CasadiCollocatorException("Point constraints may not " +
                                                "depend on eliminated inputs.")
        
        # Scale timed variables
        if (self.variable_scaling and self.nominal_traj is None and
            self.hs != "free"):
            # Get scale factors
            sf = self._sf
            nbr_constraint_points = len(collocation_constraint_points)
            if nbr_constraint_points > 0:
                timed_variables_sfs = N.concatenate(
                        nbr_constraint_points *
                        [sf['x'], sf['unelim_u'], sf['w']])
                
                # Insert scale factors
                ocp_expressions = [self.path, self.point, self.mterm]
                [self.path,
                 self.point,
                 self.mterm] = casadi.substitute(ocp_expressions,
                                                 [timed_variables],
                                                 [timed_variables_sfs *
                                                  timed_variables])
        
        # Denormalize time for minimum time problems
        if self._normalize_min_time:
            t0_var = self.ocp.variable('startTime')
            tf_var = self.ocp.variable('finalTime')
            if t0_var.getFree():
                if self.init_traj is None:
                    t0_init = t0_var.getInitialGuess()
                else:
                    try:
                        data = self.init_traj.get_variable_data("startTime")
                    except VariableNotFoundError:
                        if t0_var.getInitialGuess() == 0.:
                            print("Warning: Could not find initial guess " +
                                  "for startTime in initial trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            t0_init = self.init_traj.get_variable_data(
                                    "time").t[0]
                        else:
                            print("Warning: Could not find initial guess " +
                                  "for startTime in initial trajectories. " +
                                  "Using initialGuess attribute value " +
                                  "instead.")
                            t0_init = t0_var.getInitialGuess()
                    else:
                        t0_init = data.x[0]
                if self.nominal_traj is None:
                    t0_nom = t0_var.getNominal()
                else:
                    try:
                        mode = self.nominal_traj_mode["startTime"]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    if mode == "attribute":
                        t0_nom = t0_var.getNominal()
                    else:
                        try:
                            data = self.nominal_traj.get_variable_data(
                                    "startTime")
                        except VariableNotFoundError:
                            print("Warning: Could not find nominal value " +
                                  "for startTime in nominal trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            t0_nom = self.nominal_traj.get_variable_data(
                                    "time").t[0]
                        else:
                            t0_nom = data.x[0]
            else:
                t0_init = t0_var.getStart()
                t0_nom = t0_var.getStart()
                assert tf_var.getFree(), \
                       "Bug: Time should not have been normalized"
            if tf_var.getFree():
                if self.init_traj is None:
                    tf_init = tf_var.getInitialGuess()
                else:
                    try:
                        data = self.init_traj.get_variable_data("finalTime")
                    except VariableNotFoundError:
                        if tf_var.getInitialGuess() == 1.:
                            print("Warning: Could not find initial guess " +
                                  "for finalTime in initial trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            tf_init = self.init_traj.get_variable_data(
                                    "time").t[-1]
                        else:
                            print("Warning: Could not find initial guess " +
                                  "for finalTime in initial trajectories. " +
                                  "Using initialGuess attribute value " +
                                  "instead.")
                            tf_init = tf_var.getInitialGuess()
                    else:
                        tf_init = data.x[0]
                if self.nominal_traj is None:
                    tf_nom = tf_var.getNominal()
                else:
                    try:
                        mode = self.nominal_traj_mode["finalTime"]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    if mode == "attribute":
                        tf_nom = tf_var.getNominal()
                    else:
                        try:
                            data = self.nominal_traj.get_variable_data(
                                    "finalTime")
                        except VariableNotFoundError:
                            print("Warning: Could not find nominal value " +
                                  "for finalTime in nominal trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            tf_nom = self.nominal_traj.get_variable_data(
                                    "time").t[0]
                        else:
                            tf_nom = data.x[0]
            else:
                tf_init = tf_var.getStart()
                tf_nom = tf_var.getStart()
            self._denorm_t0_init = t0_init
            self._denorm_tf_init = tf_init
            self._denorm_t0_nom = t0_nom
            self._denorm_tf_nom = tf_nom
        
        # Create nominal trajectories
        if self.variable_scaling and self.nominal_traj is not None:
            nom_traj = {"dx": {}}
            vr_map = self._vr_map
            n = len(self.nominal_traj.get_data_matrix()[:, 0])
            for vt in ['x', 'unelim_u', 'w']:
                nom_traj[vt] = {}
                for var in var_vectors[vt]:
                    data_matrix = N.empty([n, len(var_vectors[vt])])
                    (var_index, _) = vr_map[var.getValueReference()]
                    name = var.getName()
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        # It is possibly to treat missing variable trajectories
                        # more efficiently, especially in the case of MX
                        print("Warning: Could not find nominal trajectory " +
                              "for variable " + name + ". Using nominal " +
                              "attribute value instead.")
                        abscissae = N.array([0])
                        nom_val = var.getNominal()
                        if nom_val is None:
                            constant_sf = 1
                        else:
                            constant_sf = N.abs(nom_val)
                        ordinates = N.array([[constant_sf]])
                    else:
                        abscissae = data.t
                        ordinates = data.x.reshape([-1, 1])
                    nom_traj[vt][var_index] = \
                            TrajectoryLinearInterpolation(abscissae, ordinates)
                    
                    # Treat derivatives separately
                    if vt == "x":
                        data_matrix = N.empty([n, len(var_vectors[vt])])
                        name = convert_casadi_der_name(str(var.der()))
                        vr = self.model.xmldoc.get_value_reference(name)
                        (var_index, _) = vr_map[vr]
                        try:
                            data = self.nominal_traj.get_variable_data(name)
                        except VariableNotFoundError:
                            # It is possibly to treat missing variable 
                            # trajectories more efficiently, especially in the
                            # case of MX
                            print("Warning: Could not find nominal " +
                                  "trajectory for variable " + name + ". " +
                                  "Using nominal attribute value instead.")
                            abscissae = N.array([0])
                            nom_val = var.getNominal()
                            if nom_val is None:
                                constant_sf = 1
                            else:
                                constant_sf = N.abs(nom_val)
                            ordinates = N.array([[constant_sf]])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        nom_traj["dx"][var_index] = \
                                TrajectoryLinearInterpolation(abscissae,
                                                              ordinates)
            
            # Create storage for scaling factors
            time_points = self.get_time_points()
            n_var = copy.copy(self._n_var)
            is_variant = {}
            variant_var = casadi.SXMatrix(0, 1)
            n_variant_x = 0
            n_variant_dx = 0
            variant_sf = {}
            invariant_var = casadi.SXMatrix(0, 1)
            invariant_d = []
            invariant_e = []
            variant_timed_var = casadi.SXMatrix(0, 1)
            variant_timed_sf = []
            vr_sf_map = {}
            self._is_variant = is_variant
            self._variant_sf = variant_sf
            self._invariant_d = invariant_d
            self._invariant_e = invariant_e
            self._vr_sf_map = vr_sf_map
            for i in xrange(1, self.n_e + 1):
                variant_sf[i] = {}
                for k in time_points[i]:
                    variant_sf[i][k] = []
            
            # Evaluate trajectories to generate scaling factors
            for vt in ['x', 'unelim_u', 'w']:
                for var in var_vectors[vt]:
                    vr = var.getValueReference()
                    (var_index, _) = vr_map[vr]
                    name = var.getName()
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
                        raise ValueError("Unknown scaling mode %s " % mode +
                                         "for variable %s." % name)
                    if variant:
                        if vt == "x":
                            n_variant_x += 1
                        is_variant[vr] = True
                        vr_sf_map[vr] = variant_var.numel()
                        variant_var.append(var.var())
                        for i in xrange(1, self.n_e + 1):
                            for k in time_points[i]:
                                variant_sf[i][k].append(N.abs(values[i][k]))
                        for l in xrange(len(self.ocp.tp)):
                            tp = self.ocp.tp[l]
                            (i, k) = collocation_constraint_points[l]
                            variant_timed_var.append(var.atTime(tp))
                            variant_timed_sf.append(N.abs(values[i][k]))
                    else:
                        is_variant[vr] = False
                        if mode == "attribute":
                            d = N.abs(var.getNominal())
                            e = 0.
                        elif mode == "linear":
                            d = max([abs(traj_max), abs(traj_min)])
                            if d == 0.0:
                                d = 1.
                                print("Warning: Nominal trajectory for " +
                                      "variable %s is identically " % name + 
                                      "zero.")
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
                                if traj_max == 0.0:
                                    print("Warning: Nominal trajectory for " +
                                          "variable %s is " % name + 
                                          "identically zero.")
                                    d = 1.
                                else:
                                    d = max([abs(traj_max), abs(traj_min)])
                                e = 0.
                            else:
                                d = traj_max - traj_min
                                e = traj_min
                        vr_sf_map[vr] = invariant_var.numel()
                        invariant_var.append(var.var())
                        invariant_d.append(d)
                        invariant_e.append(e)
                        for tp in self.ocp.tp:
                            invariant_var.append(var.atTime(tp))
                            invariant_d.append(d)
                            invariant_e.append(e)
            
            # Do not scaled eliminated inputs
            for var in var_vectors['elim_u']:
                vr = var.getValueReference()
                is_variant[vr] = False
                d = 1.
                e = 0.
                vr_sf_map[vr] = invariant_var.numel()
                invariant_var.append(var.var())
                invariant_d.append(d)
                invariant_e.append(e)
            
            # Evaluate trajectories for state derivatives
            # Heavy code duplication from above
            for var in var_vectors["x"]:
                name = convert_casadi_der_name(str(var.der()))
                try:
                    mode = self.nominal_traj_mode[name]
                except KeyError:
                    mode = self.nominal_traj_mode["_default_mode"]
                vr = self.model.xmldoc.get_value_reference(name)
                (var_index, _) = vr_map[vr]
                values = {}
                traj_min = N.inf
                traj_max = -N.inf
                for i in xrange(1, self.n_e + 1):
                    values[i] = {}
                    for k in time_points[i]:
                        tp = time_points[i][k]
                        if self._normalize_min_time:
                            tp = t0_nom + (tf_nom - t0_nom) * tp
                        val = float(nom_traj["dx"][var_index].eval(tp))
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
                    raise ValueError("Unknown scaling mode %s " % mode +
                                     "for variable %s." % name)
                if variant:
                    n_variant_dx += 1
                    is_variant[vr] = True
                    vr_sf_map[vr] = variant_var.numel()
                    variant_var.append(var.der())
                    for i in xrange(1, self.n_e + 1):
                        for k in time_points[i]:
                            variant_sf[i][k].append(N.abs(values[i][k]))
                else:
                    is_variant[vr] = False
                    if mode == "attribute":
                        d = N.abs(var.getNominal())
                        e = 0.
                    elif mode == "linear":
                        d = max([abs(traj_max), abs(traj_min)])
                        if d == 0.0:
                            d = 1.
                            print("Warning: Nominal trajectory for " +
                                  "variable %s is identically " % name + 
                                  "zero.")
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
                            if N.allclose(traj_max, 0.):
                                d = 1.
                            else:
                                d = max([abs(traj_max), abs(traj_min)])
                            e = 0.
                        else:
                            d = traj_max - traj_min
                            e = traj_min
                    vr_sf_map[vr] = invariant_var.numel()
                    invariant_var.append(var.der())
                    invariant_d.append(d)
                    invariant_e.append(e)
            
            # Handle free parameters
            for var in self.ocp.pf:
                vr = var.getValueReference()
                (var_index, _) = vr_map[vr]
                is_variant[vr] = False
                name = var.getName()
                if name == "startTime":
                    d = N.abs(self._denorm_t0_nom)
                    if N.allclose(d, 0.):
                        d = 1.
                    e = 0.
                elif name == "finalTime":
                    d = N.abs(self._denorm_tf_nom)
                    if N.allclose(d, 0.):
                        d = 1.
                    e = 0.
                else:
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        print("Warning: Could not find nominal trajectory " +
                              "for variable " + name + ". Using nominal " +
                              "attribute value instead.")
                        nom_val = var.getNominal()
                        if nom_val is None:
                            d = 1.
                        else:
                            d = N.abs(nom_val)
                        e = 0.
                    else:
                        d = N.abs(data.x[0])
                        e = 0.
                vr_sf_map[vr] = invariant_var.numel()
                invariant_var.append(var.var())
                invariant_d.append(d)
                invariant_e.append(e)
        
        # Create measured input trajectories
        if (self.measurement_data is None or
            len(self.measurement_data.eliminated) == 0):
            for i in xrange(1, self.n_e + 1):
                for k in self.time_points[i].keys():
                    var_map[i][k]['elim_u'] = N.array([])
        if (self.measurement_data is not None and
            (len(self.measurement_data.eliminated) +
             len(self.measurement_data.constrained) > 0)):
            # Create storage of maximum and minimum values
            traj_min = OrderedDict()
            traj_max = OrderedDict()
            for name in (self.measurement_data.eliminated.keys() +
                         self.measurement_data.constrained.keys()):
                traj_min[name] = N.inf
                traj_max[name] = -N.inf
            
            # Collocation points
            for i in xrange(1, self.n_e + 1):
                for k in self.time_points[i].keys():
                    # Eliminated inputs
                    values = []
                    for (name, data) in \
                            self.measurement_data.eliminated.items():
                        value = data.eval(self.time_points[i][k])[0, 0]
                        values.append(value)
                        if value < traj_min[name]:
                            traj_min[name] = value
                        if value > traj_max[name]:
                            traj_max[name] = value
                    var_map[i][k]['elim_u'] = N.array(values)
                    
                    # Constrained inputs
                    values = []
                    for (name, data) in \
                            self.measurement_data.constrained.items():
                        value = data.eval(self.time_points[i][k])[0, 0]
                        values.append(value)
                        if value < traj_min[name]:
                            traj_min[name] = value
                        if value > traj_max[name]:
                            traj_max[name] = value
                    var_map[i][k]['constr_u'] = N.array(values)
            
            # Check that constrained and eliminated inputs satisfy their bounds
            for var_name in (self.measurement_data.eliminated.keys() +
                             self.measurement_data.constrained.keys()):
                var_min = self.ocp.variable(var_name).getMin()
                var_max = self.ocp.variable(var_name).getMax()
                if traj_min[name] < var_min:
                    raise CasadiCollocatorException(
                        "The trajectory for the measured input " + name +
                        " does not satisfy the input's lower bound.")
                if traj_max[name] > var_max:
                    raise CasadiCollocatorException(
                        "The trajectory for the measured input " + name +
                        " does not satisfy the input's upper bound.")
        
        # Create collocation and DAE functions
        sym_input = self._sym_input
        sym_input_elim_der = self._sym_input_elim_der
        dx_i_k = self._collocation['dx_i_k']
        x_i = self._collocation['x_i']
        der_vals_k = self._collocation['der_vals_k']
        h_i = self._collocation['h_i']
        coll_eq = self._collocation['coll_eq']
        coll_der = self._collocation['coll_der']
        if not self.variable_scaling or self.nominal_traj is None:
            self._eliminate_der_var()
            initial_fcn = casadi.SXFunction([sym_input], [self.initial])
            if self.eliminate_der_var:
                ode_fcn = casadi.SXFunction(
                        [sym_input_elim_der, x_i, der_vals_k, h_i],
                        [self.ode])
                alg_fcn = casadi.SXFunction(
                        [sym_input_elim_der, x_i, der_vals_k, h_i],
                        [self.alg])
                ode_fcn_t0 = casadi.SXFunction([sym_input], [self.ode_t0])
                alg_fcn_t0 = casadi.SXFunction([sym_input], [self.alg_t0])
                ode_fcn_t0.init()
                alg_fcn_t0.init()
            else:
                coll_eq_fcn = casadi.SXFunction([x_i, der_vals_k, h_i, dx_i_k],
                                                [coll_eq])
                coll_eq_fcn.init()
                ode_fcn = casadi.SXFunction([sym_input], [self.ode])
                alg_fcn = casadi.SXFunction([sym_input], [self.alg])
        else:
            # Scale variables in collocation equations
            x_i_sf = casadi.ssym("x_i_sf", (self.n_cp + 1) * n_variant_x)
            variant_x_i = casadi.SXMatrix(0, 1)
            invariant_x_i = casadi.SXMatrix(0, 1)
            invariant_x_i_d = []
            invariant_x_i_e = []
            if not self.eliminate_der_var:
                dx_i_k_sf = casadi.ssym("dx_i_k_sf", n_variant_dx)
                variant_dx_i_k = casadi.SXMatrix(0, 1)
                invariant_dx_i_k = casadi.SXMatrix(0, 1)
                invariant_dx_i_k_d = []
                invariant_dx_i_k_e = []
            for var in var_vectors['x']:
                x_vr = var.getValueReference()
                dx_name = convert_casadi_der_name(str(var.der()))
                dx_vr = self.model.xmldoc.get_value_reference(dx_name)
                
                (ind, _) = vr_map[x_vr]
                x_i_temp = x_i[ind, :].reshape([self.n_cp + 1, 1])
                if is_variant[x_vr]:
                    variant_x_i.append(x_i_temp)
                else:
                    invariant_x_i.append(x_i_temp)
                    x_sf_index = vr_sf_map[x_vr]
                    for k in xrange(self.n_cp + 1):
                        invariant_x_i_d.append(invariant_d[x_sf_index])
                        invariant_x_i_e.append(invariant_e[x_sf_index])
                if not self.eliminate_der_var:
                    if is_variant[dx_vr]:
                        variant_dx_i_k.append(dx_i_k[ind])
                    else:
                        invariant_dx_i_k.append(dx_i_k[ind])
                        dx_sf_index = vr_sf_map[dx_vr]
                        invariant_dx_i_k_d.append(invariant_d[dx_sf_index])
                        invariant_dx_i_k_e.append(invariant_e[dx_sf_index])
            
            invariant_x_i_d = N.array(invariant_x_i_d)
            invariant_x_i_e = N.array(invariant_x_i_e)
            unscaled_var = casadi.SXMatrix(0, 1)
            unscaled_var.append(invariant_x_i)
            unscaled_var.append(variant_x_i)
            scaled_var = casadi.SXMatrix(0, 1)
            scaled_var.append(invariant_x_i_d * invariant_x_i +
                              invariant_x_i_e)
            scaled_var.append(x_i_sf * variant_x_i)
            if self.eliminate_der_var:
                coll_der = casadi.substitute(coll_der, unscaled_var,
                                             scaled_var)
                self._collocation['coll_der'] = coll_der
                self._eliminate_der_var()
            else:
                invariant_dx_i_k_d = N.array(invariant_dx_i_k_d)
                invariant_dx_i_k_e = N.array(invariant_dx_i_k_e)
                unscaled_var.append(invariant_dx_i_k)
                unscaled_var.append(variant_dx_i_k)
                scaled_var.append(invariant_dx_i_k_d * invariant_dx_i_k +
                                  invariant_dx_i_k_e)
                scaled_var.append(dx_i_k_sf * variant_dx_i_k)
                coll_eq = casadi.substitute(coll_eq, unscaled_var, scaled_var)
            
            # Scale variables in expressions
            sym_sf = casadi.ssym("d_i_k", variant_var.numel())
            self._sym_sf = sym_sf
            ocp_expressions = [self.initial, self.ode, self.alg, self.path,
                               self.point, self.mterm, self.lterm]
            if self.eliminate_der_var:
                ocp_expressions += [self.ode_t0, self.alg_t0]
            unscaled_var = casadi.SXMatrix(0, 1)
            unscaled_var.append(invariant_var)
            unscaled_var.append(variant_var)
            unscaled_var.append(variant_timed_var)
            scaled_var = casadi.SXMatrix(0, 1)
            scaled_var.append(N.array(invariant_d) * invariant_var +
                              N.array(invariant_e))
            scaled_var.append(sym_sf * variant_var)
            scaled_var.append(N.array(variant_timed_sf) * variant_timed_var)
            scaled_expressions = casadi.substitute(ocp_expressions,
                                                   [unscaled_var],
                                                   [scaled_var])
            if self.eliminate_der_var:
                [self.initial, self.ode, self.alg, self.path, self.point,
                 self.mterm, self.lterm, self.ode_t0, self.alg_t0] = \
                        scaled_expressions
            else:
                [self.initial, self.ode, self.alg, self.path, self.point,
                 self.mterm, self.lterm] = scaled_expressions
            
            # Create functions
            initial_fcn = casadi.SXFunction([sym_input, sym_sf],
                                            [self.initial])
            if self.eliminate_der_var:
                ode_fcn = casadi.SXFunction([sym_input_elim_der, x_i,
                                             der_vals_k, h_i, sym_sf, x_i_sf], 
                                            [self.ode])
                alg_fcn = casadi.SXFunction([sym_input_elim_der, x_i,
                                             der_vals_k, h_i, sym_sf, x_i_sf],
                                            [self.alg])
                ode_fcn_t0 = casadi.SXFunction([sym_input, sym_sf],
                                               [self.ode_t0])
                alg_fcn_t0 = casadi.SXFunction([sym_input, sym_sf],
                                               [self.alg_t0])
                ode_fcn_t0.init()
                alg_fcn_t0.init()
            else:
                coll_eq_fcn = casadi.SXFunction(
                        [x_i, der_vals_k, h_i, dx_i_k, x_i_sf, dx_i_k_sf],
                        [coll_eq])
                coll_eq_fcn.init()
                ode_fcn = casadi.SXFunction([sym_input, sym_sf], [self.ode])                
                alg_fcn = casadi.SXFunction([sym_input, sym_sf], [self.alg])
        
        # Initialize functions
        initial_fcn.init()
        ode_fcn.init()
        alg_fcn.init()
        
        # Manipulate and sort path constraints
        g_e = []
        g_i = []
        path = self.path
        lb = self.ocp.path_min.toArray().reshape(-1)
        ub = self.ocp.path_max.toArray().reshape(-1)
        for i in xrange(path.numel()):
            if lb[i] == ub[i]:
                g_e.append(path[i] - ub[i])
            else:
                if lb[i] != -N.inf:
                    g_i.append(-path[i] + lb[i])
                if ub[i] != N.inf:
                    g_i.append(path[i] - ub[i])
        
        # Create path constraint functions
        path_constraint_input = []
        if self.eliminate_der_var:
            path_constraint_input += [sym_input_elim_der, x_i, der_vals_k, h_i]
        else:
            path_constraint_input.append(sym_input)
        path_constraint_input.append(timed_variables)
        if self.variable_scaling and self.nominal_traj is not None:
            path_constraint_input.append(sym_sf)
        g_e_fcn = casadi.SXFunction(path_constraint_input,
                                    [casadi.vertcat(g_e)])
        g_i_fcn = casadi.SXFunction(path_constraint_input,
                                    [casadi.vertcat(g_i)])
        g_e_fcn.init()
        g_i_fcn.init()
        
        # Create point constraint functions
        G_e = []
        G_i = []
        lb = self.ocp.point_min.toArray().reshape(-1)
        ub = self.ocp.point_max.toArray().reshape(-1)
        for i in xrange(self.point.numel()):
            if lb[i] == ub[i]:
                G_e.append(self.point[i] - ub[i])
            else:
                if lb[i] != -N.inf:
                    G_i.append(-self.point[i] + lb[i])
                if ub[i] != N.inf:
                    G_i.append(self.point[i] - ub[i])
        G_e_fcn = casadi.SXFunction(
                [casadi.vertcat([self.model.p, timed_variables])],
                [casadi.vertcat(G_e)])
        G_i_fcn = casadi.SXFunction([casadi.vertcat(
                [self.model.p, timed_variables])],
                [casadi.vertcat(G_i)])
        G_e_fcn.init()
        G_i_fcn.init()
        
        # Define function evaluation methods based on graph
        if self.graph == 'MX':
            initial_fcn_eval = initial_fcn.call
            ode_fcn_eval = ode_fcn.call
            alg_fcn_eval = alg_fcn.call
            if self.eliminate_der_var:
                ode_fcn_t0_eval = ode_fcn_t0.call
                alg_fcn_t0_eval = alg_fcn_t0.call
            else:
                coll_eq_fcn_eval = coll_eq_fcn.call
            g_e_eval = g_e_fcn.call
            g_i_eval = g_i_fcn.call
            G_e_eval = G_e_fcn.call
            G_i_eval = G_i_fcn.call
            c_e = casadi.MX() 
            c_i = casadi.MX()
        elif self.graph == 'SX':
            initial_fcn_eval = initial_fcn.eval
            ode_fcn_eval = ode_fcn.eval
            alg_fcn_eval = alg_fcn.eval
            if self.eliminate_der_var:
                ode_fcn_t0_eval = ode_fcn_t0.eval
                alg_fcn_t0_eval = alg_fcn_t0.eval
            else:
                coll_eq_fcn_eval = coll_eq_fcn.eval
            g_e_eval = g_e_fcn.eval
            g_i_eval = g_i_fcn.eval
            G_e_eval = G_e_fcn.eval
            G_i_eval = G_i_fcn.eval
            c_e = casadi.SXMatrix()
            c_i = casadi.SXMatrix()
        else:
            raise ValueError('Unknown CasADi graph %s.' % graph)
        
        # Create list of state matrices
        x_list = [[]]
        self.x_list = x_list
        for i in xrange(1, self.n_e + 1):
            x_i = [var_map[i][k]['x'] for k in xrange(self.n_cp + 1)]
            x_i = casadi.horzcat(x_i)
            x_list.append(x_i)
        
        # Index collocation equation scale factors
        if self.variable_scaling and self.nominal_traj is not None:
            coll_sf = {}
            for i in xrange(1, self.n_e + 1):
                coll_sf[i] = {}
                coll_sf[i]['x'] = []
                coll_sf[i]['dx'] = {}
                for k in xrange(1, self.n_cp + 1):
                    coll_sf[i]['dx'][k] = []
            for var in var_vectors['x']:
                x_vr = var.getValueReference()
                dx_name = convert_casadi_der_name(str(var.der()))
                dx_vr = self.model.xmldoc.get_value_reference(dx_name)
                
                x_sf_index = vr_sf_map[x_vr]
                dx_sf_index = vr_sf_map[dx_vr]
                
                # States
                if is_variant[x_vr]:
                    # First element
                    i = 1
                    coll_sf[i]['x'].append(variant_sf[i][0][x_sf_index])
                    for k in xrange(1, self.n_cp + 1):
                        coll_sf[i]['x'].append(
                                variant_sf[i][k][x_sf_index])
                    
                    # Suceeding elements
                    for i in xrange(2, self.n_e + 1):
                        k = self.n_cp + self.is_gauss
                        coll_sf[i]['x'].append(variant_sf[i-1][k][x_sf_index])
                        for k in xrange(1, self.n_cp + 1):
                            coll_sf[i]['x'].append(
                                    variant_sf[i][k][x_sf_index])
                
                # State derivatives
                if is_variant[dx_vr]:
                    for i in xrange(1, self.n_e + 1):
                        for k in xrange(1, self.n_cp + 1):
                            coll_sf[i]['dx'][k].append(
                                    variant_sf[i][k][dx_sf_index])
        
        # Initial conditions
        i = 1
        k = 0
        fcn_input = [self._get_z(i, k)]
        if self.variable_scaling and self.nominal_traj is not None:
            fcn_input.append(variant_sf[i][k])
        [initial_constr] = initial_fcn_eval(fcn_input)
        c_e.append(initial_constr)
        if self.eliminate_der_var:
            [ode_t0_constr] = ode_fcn_t0_eval(fcn_input)
            [alg_t0_constr] = alg_fcn_t0_eval(fcn_input)
        else:
            [ode_t0_constr] = ode_fcn_eval(fcn_input)
            [alg_t0_constr] = alg_fcn_eval(fcn_input)
        c_e.append(ode_t0_constr)
        c_e.append(alg_t0_constr)
        
        if self.blocking_factors is None:
            # Evaluate u_1_0 based on polynomial u_1
            u_1_0 = 0
            for k in xrange(1, self.n_cp + 1):
                u_1_0 += (var_map[1][k]['unelim_u'] *
                          self.pol.eval_basis(k, 0, False))
                
            # Add residual for u_1_0 as constraint
            c_e.append(var_map[1][0]['unelim_u'] - u_1_0)
        
        # Collocation and DAE constraints
        for i in xrange(1, self.n_e + 1):
            for k in xrange(1, self.n_cp + 1):
                # Create function inputs
                if self.eliminate_der_var:
                    z = self._get_z_elim_der(i, k)
                    fcn_input = [z, x_list[i], der_vals[k],
                                 self.horizon * self.h[i]]
                else:
                    z = self._get_z(i, k)
                    fcn_input = [z]
                    coll_input = [x_list[i], der_vals[k],
                                  self.horizon * self.h[i],
                                  var_map[i][k]['dx']]
                if self.variable_scaling and self.nominal_traj is not None:
                    fcn_input.append(variant_sf[i][k])
                    if self.eliminate_der_var:
                        fcn_input.append(coll_sf[i]['x'])
                    else:
                        coll_input.append(coll_sf[i]['x'])
                        coll_input.append(coll_sf[i]['dx'][k])
                
                # Evaluate collocation constraints
                if not self.eliminate_der_var:
                    [coll_constr] = coll_eq_fcn_eval(coll_input)
                    c_e.append(coll_constr)
                
                # Evaluate DAE constraints
                [ode_constr] = ode_fcn_eval(fcn_input)
                [alg_constr] = alg_fcn_eval(fcn_input)
                c_e.append(ode_constr)
                c_e.append(alg_constr)
        
        # Continuity constraints for x_{i, n_cp + 1}
        if self.is_gauss:
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        x_i_np1 += self.pol.w[k] * var_map[i][k]['dx']
                    x_i_np1 = (var_map[i][0]['x'] + 
                               self.horizon * self.h[i] * x_i_np1)
                    
                    # Add residual for x_i_np1 as constraint
                    c_e.append(var_map[i][self.n_cp + 1]['x'] - x_i_np1)
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_np1 += var_map[i][k]['x'] * self.pol.eval_basis(
                            k, 1, True)
                    
                    # Add residual for x_i_np1 as constraint
                    c_e.append(var_map[i][self.n_cp + 1]['x'] - x_i_np1)
        
        # Constraints for terminal values
        if self.is_gauss:
            for var_type in ['unelim_u', 'w']:
                # Evaluate xx_{n_e, n_cp + 1} based on polynomial xx_{n_e}
                xx_ne_np1 = 0
                for k in xrange(1, self.n_cp + 1):
                    xx_ne_np1 += (var_map[self.n_e][k][var_type] *
                                  self.pol.eval_basis(k, 1, False))
                
                # Add residual for xx_ne_np1 as constraint
                c_e.append(var_map[self.n_e][self.n_cp + 1][var_type] -
                           xx_ne_np1)
            if not self.eliminate_der_var:
                # Evaluate dx_{n_e, n_cp + 1} based on polynomial x_{n_e}
                dx_ne_np1 = 0
                for k in xrange(self.n_cp + 1):
                    x_ne_k = var_map[self.n_e][k]['x']
                    dx_ne_np1 += (1. / (self.horizon * self.h[self.n_e]) *
                                  x_ne_k * self.pol.eval_basis_der(k, 1))
                
                # Add residual for dx_ne_np1 as constraint
                c_e.append(var_map[self.n_e][self.n_cp + 1]['dx'] - dx_ne_np1)
        
        # Continuity constraints for x_{i, 0}
        if not self.eliminate_cont_var:
            for i in xrange(1, self.n_e):
                cont_constr = (var_map[i][self.n_cp + self.is_gauss]['x'] - 
                               var_map[i + 1][0]['x'])
                c_e.append(cont_constr)
        
        # Element length constraints
        if self.hs == "free":
            h_constr = casadi.sumRows(self.h[1:]) - 1
            c_e.append(h_constr)
        
        # Path constraints
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                fcn_input = []
                if self.eliminate_der_var:
                    z = self._get_z_elim_der(i, k)
                    fcn_input += [z, x_list[i], der_vals[k],
                                  self.horizon * self.h[i]]
                else:
                    z = self._get_z(i, k)
                    fcn_input.append(z)
                fcn_input.append(nlp_timed_variables)
                if self.variable_scaling and self.nominal_traj is not None:
                    fcn_input.append(variant_sf[i][k])
                [g_e_constr] = g_e_eval(fcn_input)
                [g_i_constr] = g_i_eval(fcn_input)
                c_e.append(g_e_constr)
                c_i.append(g_i_constr)
        
        # Point constraints
        [G_e_constr] = G_e_eval([casadi.vertcat(
                [var_map['p_opt'], nlp_timed_variables])])
        [G_i_constr] = G_i_eval([casadi.vertcat(
                [var_map['p_opt'], nlp_timed_variables])])
        c_e.append(G_e_constr)
        c_i.append(G_i_constr)
        
        # Equality constraints for constrained inputs
        if self.measurement_data is not None:
            if self.variable_scaling and self.nominal_traj is None:
                sfs = self._sf
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    for j in xrange(len(self.measurement_data.constrained)):
                        # Retrieve variable and value
                        var_name = self.measurement_data.constrained.keys()[j]
                        vr = self.model.xmldoc.get_value_reference(var_name)
                        (ind, vt) = vr_map[vr]
                        constr_var = self.var_map[i][k]['unelim_u'][ind]
                        constr_val = self.var_map[i][k]['constr_u'][j]
                        
                        # Scale variable
                        if self.variable_scaling:
                            if self.nominal_traj is None:
                                sf = sfs[vt][ind]
                                constr_var *= sf
                            else:
                                sf_index = vr_sf_map[vr]
                                if is_variant[vr]:
                                    sf = variant_sf[i][k][sf_index]
                                    constr_var *= sf
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    constr_var = d * constr_var + e
                        
                        # Add constraint
                        c_e.append(constr_var - constr_val)
        
        # Store constraints and time as data attributes
        self.c_e = c_e
        if self.graph == 'MX':
            if c_i.isNull():
                self.c_i = casadi.MX(0, 1)
            else:
                self.c_i = c_i
        else:
            self.c_i = c_i
        self.time = N.array(time)
        
    def _create_cost(self):
        """
        Define the cost.
        """
        # Retrieve collocation variables
        if self.eliminate_der_var:
            x_i = self._collocation['x_i']
            der_vals_k = self._collocation['der_vals_k']
            h_i = self._collocation['h_i']
            coll_der = self._collocation['coll_der']
        
        # Retrieve time-variant scale factors
        if self.variable_scaling and self.nominal_traj is not None:
            variant_sf = self._variant_sf
        
        # Calculate cost
        self.cost_mayer = 0
        self.cost_lagrange = 0
        
        # Mayer term
        if self.mterm.numel() > 0:
            # Get terminal values
            if self.discr == "LGR":
                z = self._get_z_elim_der(self.n_e, self.n_cp)
            elif self.discr == "LG":
                z = self._get_z_elim_der(self.n_e, self.n_cp + 1)
            else:
                raise ValueError("Unknown discretization scheme %s." %
                                 self.discr)
            
            # Create function for evaluation of Mayer term
            tf = self.ocp.variable('finalTime').getStart()
            mterm_inputs = casadi.SXMatrix(self.model.t)
            mterm_inputs.append(casadi.SXMatrix(
                    [x.atTime(tf, True) for
                     x in self._var_vectors['x']]))
            mterm_inputs.append(casadi.SXMatrix(
                    [u.atTime(tf, True) for
                     u in self._var_vectors['unelim_u']]))
            mterm_inputs.append(casadi.SXMatrix(
                    [w.atTime(tf, True) for
                     w in self._var_vectors['w']]))
            mterm_inputs.append(self.model.p)
            mterm_inputs.append(casadi.SXMatrix(
                    [u.atTime(tf, True) for
                     u in self._var_vectors['elim_u']]))
            mterm_fcn = casadi.SXFunction([mterm_inputs], [self.mterm])
            mterm_fcn.init()
            
            # Use appropriate function evaluation based on graph
            if self.graph == "MX":
                [self.cost_mayer] = mterm_fcn.call([z])
            elif self.graph == "SX":
                [self.cost_mayer] = mterm_fcn.eval([z])
            else:
                raise ValueError("Unknown CasADi graph %s." %
                                 self.graph)
        
        # Lagrange term
        if self.lterm.numel() > 0:
            # Create function for evaluation of Lagrange integrand
            if self.eliminate_der_var:
                fcn_input = [self._sym_input_elim_der, x_i, der_vals_k,
                             h_i]
            else:
                fcn_input = [self._sym_input]
            if self.variable_scaling and self.nominal_traj is not None:
                fcn_input.append(self._sym_sf)
            
            lterm_fcn = casadi.SXFunction(fcn_input, [self.lterm])
            lterm_fcn.init()
                
            # Define function evaluation method based on graph
            if self.graph == "MX":
                lterm_fcn_eval = lterm_fcn.call
            elif self.graph == "SX":
                lterm_fcn_eval = lterm_fcn.eval
            else:
                raise ValueError("Unknown CasADi graph %s." % self.graph)
            
            # Get start and final time
            t0_var = self.ocp.variable('startTime')
            tf_var = self.ocp.variable('finalTime')
            if t0_var.getFree():
                vr = t0_var.getValueReference()
                (ind, _) = self._vr_map[vr]
                t0 = self.var_map['p_opt'][ind]
            else:
                t0 = t0_var.getStart()
            if tf_var.getFree():
                vr = tf_var.getValueReference()
                (ind, _) = self._vr_map[vr]
                tf = self.var_map['p_opt'][ind]
            else:
                tf = tf_var.getStart()

            # Evaluate Lagrange cost
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    if self.eliminate_der_var:
                        z = self._get_z_elim_der(i, k)
                        fcn_input = [z, self.x_list[i], self.der_vals[k],
                                     self.horizon * self.h[i]]
                    else:
                        fcn_input = [self._get_z(i, k)]
                    if self.variable_scaling and self.nominal_traj is not None:
                        fcn_input.append(variant_sf[i][k])
                    [lterm_val] = lterm_fcn_eval(fcn_input)
                    self.cost_lagrange += ((tf - t0) * self.h[i] *
                                           lterm_val * self.pol.w[k])
        
        # Sum up the two cost terms
        self.cost = self.cost_mayer + self.cost_lagrange
        
        # Add quadratic cost for measurement data
        if (self.measurement_data is not None and
            (len(self.measurement_data.unconstrained) +
             len(self.measurement_data.constrained) > 0)):
            # Retrieve scaling factors
            if self.variable_scaling and self.nominal_traj is not None:
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                vr_sf_map = self._vr_sf_map
            
            # Create nested dictionary for storage of errors and calculate
            # reference values
            err = {}
            y_ref = {}
            datas = (self.measurement_data.constrained.values() +
                     self.measurement_data.unconstrained.values())
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
            vr_map = self._vr_map
            if self.variable_scaling and self.nominal_traj is None:
                sfs = self._sf
            var_names = (self.measurement_data.constrained.keys() +
                         self.measurement_data.unconstrained.keys())
            for j in xrange(len(var_names)):
                var_name = var_names[j]
                vr = self.model.xmldoc.get_value_reference(var_name)
                (ind, vt) = vr_map[vr]
                for i in range(1, self.n_e + 1):
                    for k in range(1, self.n_cp + 1):
                        val = self.var_map[i][k][vt][ind]
                        ref_val = y_ref[i][k][j]
                        if self.variable_scaling:
                            if self.nominal_traj is None:
                                sf = sfs[vt][ind]
                                err[i][k].append(sf * val - ref_val)
                            else:
                                sf_index = vr_sf_map[vr]
                                if is_variant[vr]:
                                    sf = variant_sf[i][k][sf_index]
                                    err[i][k].append(sf * val - ref_val)
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    err[i][k].append(d * val + e - ref_val)
                        else:
                            err[i][k].append(val - ref_val)
            
            # Calculate cost contribution from each collocation point
            Q = self.measurement_data.Q
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
                            casadi.mul(self.var_map[i][k]['dx'].T, Q),
                            self.var_map[i][k]['dx'])
                    length_cost += (h_i ** (1 + a) * integrand * self.pol.w[k])
            self.cost += c * length_cost
    
    def _compute_bounds_and_init(self):
        """
        Compute bounds and intial guesses for NLP variables.
        """
        # Create lower and upper bounds
        xx_lb = self.LOWER * N.ones(self.get_n_xx())
        xx_ub = self.UPPER * N.ones(self.get_n_xx())
        xx_init = N.zeros(self.get_n_xx())
        
        # Retrieve model data
        var_indices = self.get_var_indices()
        ocp = self.ocp
        var_types = ['x', 'unelim_u', 'w', 'p_opt']
        vr_map = self._vr_map
        var_vectors = self._var_vectors
        time_points = self.get_time_points()
        if self.variable_scaling:
            if self.nominal_traj is None:
                sfs = self._sf
            else:
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                vr_sf_map = self._vr_sf_map
        
        # Handle free parameters
        p_max = N.empty(self.model.get_n_p())
        p_min = copy.deepcopy(p_max)
        p_init = copy.deepcopy(p_max)
        for var in var_vectors["p_opt"]:
            vr = var.getValueReference()
            (var_index, _) = vr_map[vr]
            if self.variable_scaling:
                if self.nominal_traj is None:
                    sf = sfs["p_opt"][var_index]
                else:
                    sf_index = vr_sf_map[vr]
                    sf = invariant_d[sf_index]
            else:
                sf = 1
            p_min[var_index] = var.getMin() / sf
            p_max[var_index] = var.getMax() / sf
            
            # Handle initial guess
            var_init = var.getInitialGuess()
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
        xx_lb[var_indices['p_opt']] = p_min
        xx_ub[var_indices['p_opt']] = p_max
        xx_init[var_indices['p_opt']] = p_init
        
        # Manipulate initial trajectories
        if self.init_traj is not None:
            n = len(self.init_traj.get_data_matrix()[:, 0])
            traj = {}
            traj["dx"] = {}
            for vt in var_vectors.keys():
                traj[vt] = {}
                for var in var_vectors[vt]:
                    data_matrix = N.empty([n, len(var_vectors[vt])])
                    (var_index, _) = vr_map[var.getValueReference()]
                    name = var.getName()
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
                            ordinates = N.array([[var.getInitialGuess()]])
                            abscissae = N.array([0])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        traj[vt][var_index] = \
                                TrajectoryLinearInterpolation(abscissae, ordinates)
                    
                    # Treat derivatives separately
                    if vt == "x":
                        name = convert_casadi_der_name(str(var.der()))
                        vr = self.model.xmldoc.get_value_reference(name)
                        data_matrix = N.empty([n, len(var_vectors[vt])])
                        (var_index, _) = vr_map[vr]
                        try:
                            data = self.init_traj.get_variable_data(name)
                        except VariableNotFoundError:
                            print("Warning: Could not find initial " + \
                                  "trajectory for variable " + name + ". " + 
                                  "Using 0 as initial guess instead.")
                            abscissae = N.array([0])
                            ordinates = N.array([[0]])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        traj["dx"][var_index] = \
                                TrajectoryLinearInterpolation(abscissae,
                                                              ordinates)
        
        # Denormalize time for minimum time problems
        if self._normalize_min_time:
            t0 = self._denorm_t0_init
            tf = self._denorm_tf_init
        
        # Set bounds and initial guesses
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                time = time_points[i][k]
                if self._normalize_min_time:
                    time = t0 + (tf - t0) * time
                for vt in ['x', 'unelim_u', 'w']:
                    var_min = N.empty(len(var_vectors[vt]))
                    var_max = N.empty(len(var_vectors[vt]))
                    var_init = N.empty(len(var_vectors[vt]))
                    if (not self.eliminate_der_var and vt == "x"):
                        var_init_der = N.empty(len(var_vectors[vt]))
                    for var in var_vectors[vt]:
                        vr = var.getValueReference()
                        (var_index, _) = vr_map[vr]
                        d = 1.
                        e = 0.
                        if self.variable_scaling:
                            if self.nominal_traj is None:
                                d = sfs[vt][var_index]
                            else:
                                sf_index = vr_sf_map[vr]
                                if is_variant[vr]:
                                    d = variant_sf[i][k][sf_index]
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                        var_min[var_index] = (var.getMin() - e) / d
                        var_max[var_index] = (var.getMax() - e) / d
                        if self.init_traj is None:
                            var_initial = var.getInitialGuess()
                        else:
                            var_initial = traj[vt][var_index].eval(time)
                        var_init[var_index] = (var_initial - e) / d
                        
                        # Treat derivatives separately
                        if (not self.eliminate_der_var and vt == "x"):
                            name = convert_casadi_der_name(str(var.der()))
                            vr = self.model.xmldoc.get_value_reference(name)
                            (var_index, _) = vr_map[vr]
                            d = 1.
                            e = 0.
                            if self.variable_scaling:
                                if self.nominal_traj is None:
                                    d = sfs["dx"][var_index]
                                else:
                                    sf_index = vr_sf_map[vr]
                                    if is_variant[vr]:
                                        d = variant_sf[i][k][sf_index]
                                    else:
                                        d = invariant_d[sf_index]
                                        e = invariant_e[sf_index]
                            if self.init_traj is None:
                                var_initial = 0.
                            else:
                                var_initial = traj["dx"][var_index].eval(time)
                            var_init_der[var_index] = (var_initial - e) / d
                    
                    xx_lb[var_indices[i][k][vt]] = var_min
                    xx_ub[var_indices[i][k][vt]] = var_max
                    xx_init[var_indices[i][k][vt]] = var_init
                    if (not self.eliminate_der_var and vt == "x"):
                        xx_init[var_indices[i][k]["dx"]] = var_init_der
        
        # Set bounds and initial guesses for continuity variables
        if not self.eliminate_cont_var:
            vt = 'x'
            k = self.n_cp + self.is_gauss
            for i in xrange(2, self.n_e + 1):
                xx_lb[var_indices[i][0][vt]] = xx_lb[var_indices[i - 1][k][vt]]
                xx_ub[var_indices[i][0][vt]] = xx_ub[var_indices[i - 1][k][vt]]
                xx_init[var_indices[i][0][vt]] = \
                        xx_init[var_indices[i - 1][k][vt]]
        
        # Compute bounds and initial guesses for element lengths
        if self.hs == "free":
            h_0 = 1. / self.n_e
            h_bounds = self.free_element_lengths_data.bounds
            var_indices = self.get_var_indices()
            for i in xrange(1, self.n_e + 1):
                xx_lb[var_indices['h'][i]] = h_bounds[0] * h_0
                xx_ub[var_indices['h'][i]] = h_bounds[1] * h_0
                xx_init[var_indices['h'][i]] = h_bounds[1] * h_0
        
        # Store bounds and initial guesses
        self.xx_lb = xx_lb
        self.xx_ub = xx_ub
        self.xx_init = xx_init
    
    def _create_solver(self):
        # Concatenate constraints
        constraints = casadi.vertcat([self.get_equality_constraint(),
                                      self.get_inequality_constraint()])
        
        # Define NLP function based on graph
        if self.graph == "MX":
            nlp = casadi.MXFunction(casadi.nlpIn(x=self.xx),
                                    casadi.nlpOut(f=self.cost, g=constraints))
        elif self.graph == "SX":
            nlp = casadi.SXFunction(casadi.nlpIn(x=self.xx),
                                    casadi.nlpOut(f=self.cost, g=constraints))
        else:
            raise ValueError("Unknown CasADi graph %s." % graph)
        
        # Create solver object        
        self.solver = casadi.IpoptSolver(nlp)
    
    def get_equality_constraint(self):
        return self.c_e
    
    def get_inequality_constraint(self):
        return self.c_i
    
    def get_cost(self):
        return self.cost_fcn
    
    def get_result(self):
        # Set model info
        n_var = copy.copy(self._n_var)
        n_var['elim_u'] = self._model_elim_u.numel()
        cont = {'dx': False, 'x': True, 'unelim_u': False, 'w': False}
        var_vectors = self._var_vectors
        var_types = ['x', 'unelim_u', 'w']
        if not self.eliminate_der_var:
            var_types = ['dx'] + var_types
        vr_map = self._vr_map
        var_map = self.var_map
        var_opt = {}
        var_indices = self.get_var_indices()
        if self.variable_scaling:
            if self.nominal_traj is None:
                sf = self._sf
            else:
                vr_sf_map = self._vr_sf_map
                is_variant = self._is_variant
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
        
        # Get copy of solution
        primal_opt = copy.copy(self.primal_opt)
        
        # Get element lengths
        if self.hs == "free":
            self.h_opt = N.hstack([N.nan, primal_opt[var_indices['h'][1:]]])
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
            t_opt = []
            t_start = 0.
            for i in xrange(1, self.n_e + 1):
                t_end = t_start + h_scaled[i]
                t_i = N.linspace(t_start, t_end, self.n_eval_points)
                t_opt = N.hstack([t_opt, t_i])
                t_start = t_opt[-1]
            t_opt = t_opt.reshape([-1, 1])
        else:
            raise ValueError("Unknown result mode %s." % self.result_mode)
        
        # Create arrays for storage of variable trajectories
        for var_type in var_types + ['elim_u']:
            var_opt[var_type] = N.empty([len(t_opt), n_var[var_type]])
        var_opt['merged_u'] = N.empty([len(t_opt),
                                       n_var['unelim_u'] + n_var['elim_u']])
        if self.eliminate_der_var:
            var_opt['dx'] = N.empty([len(t_opt), n_var['x']])
        var_opt['p_opt'] = N.empty(self.model.get_n_p())
        
        # Get optimal parameter values and rescale
        p_opt = primal_opt[self.get_var_indices()['p_opt']].reshape(-1)
        if self.variable_scaling and not self.write_scaled_result:
            if self.nominal_traj is None:
                p_opt *= sf['p_opt']
            else:
                p_opt_sf = N.empty(self.model.get_n_p())
                for var in self.ocp.pf:
                    vr = var.getValueReference()
                    (ind, _) = vr_map[vr]
                    sf_index = vr_sf_map[vr]
                    p_opt_sf[ind] = invariant_d[sf_index]
                p_opt *= p_opt_sf
        var_opt['p_opt'][:] = p_opt
        
        # Rescale solution
        time_points = self.get_time_points()
        if self.variable_scaling and not self.write_scaled_result:
            t_index = 0
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in ['x', 'unelim_u', 'w']:
                        for var in var_vectors[var_type]:
                            vr = var.getValueReference()
                            (ind, _) = vr_map[vr]
                            global_ind = var_indices[i][k][var_type][ind]
                            xx_i_k = primal_opt[global_ind]
                            if self.nominal_traj is None:
                                xx_i_k *= sf[var_type][ind]
                            else:
                                sf_index = self._vr_sf_map[vr]
                                if self._is_variant[vr]:
                                    xx_i_k *= variant_sf[i][k][sf_index]
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    xx_i_k = d * xx_i_k + e
                            primal_opt[global_ind] = xx_i_k
                    
                    # Treat state derivatives separately
                    if not self.eliminate_der_var:
                        dx_names = self.model.xmldoc.get_dx_variable_names(
                                False)
                        name_dict = dict((x[0], x[1]) for x in dx_names)
                        for vr in sorted(name_dict):
                            (ind, _) = vr_map[vr]
                            global_ind = var_indices[i][k]["dx"][ind]
                            xx_i_k = primal_opt[global_ind]
                            if self.nominal_traj is None:
                                xx_i_k *= sf["dx"][ind]
                            else:
                                sf_index = self._vr_sf_map[vr]
                                if self._is_variant[vr]:
                                    xx_i_k = xx_i_k*variant_sf[i][k][sf_index]
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    xx_i_k = d * xx_i_k + e
                            primal_opt[global_ind] = xx_i_k
                        t_index += 1
        
        # Rescale continuity variables
        if (self.variable_scaling and not self.eliminate_cont_var and
            not self.write_scaled_result):
            for i in xrange(1, self.n_e):
                k = self.n_cp + self.is_gauss
                x_i_k = primal_opt[var_indices[i][k]['x']]
                primal_opt[var_indices[i + 1][0]['x']] = x_i_k
        if (self.is_gauss and self.variable_scaling and 
            not self.eliminate_cont_var and not self.write_scaled_result):
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = primal_opt[var_indices[i][k]['dx']]
                        x_i_np1 += self.pol.w[k] * dx_i_k
                    x_i_np1 = (primal_opt[var_indices[i][0]['x']] + 
                               self.horizon * self.h[i] * x_i_np1)
                    
                    # Rescale x_{i, n_cp + 1}
                    primal_opt[var_indices[i][self.n_cp + 1]['x']] = x_i_np1
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[var_indices[i][k]['x']]
                        x_i_np1 += x_i_k * self.pol.eval_basis(k, 1, True)
                    
                    # Rescale x_{i, n_cp + 1}
                    primal_opt[var_indices[i][self.n_cp + 1]['x']] = x_i_np1
        
        # Get solution trajectories
        t_index = 0
        if self.result_mode == "collocation_points":
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        xx_i_k = primal_opt[var_indices[i][k][var_type]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    var_opt['elim_u'][t_index, :] = var_map[i][k]['elim_u']
                    t_index += 1
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[var_indices[i][k]['dx']]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1
                
                # Collocation point derivatives
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = 0
                        for l in xrange(self.n_cp + 1):
                            x_i_l = primal_opt[var_indices[i][l]['x']]
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
                            xx_i_k = primal_opt[var_indices[i][k][var_type]]
                            xx_i_tau += xx_i_k * self.pol.eval_basis(
                                    k, tau, cont[var_type])
                        var_opt[var_type][t_index, :] = xx_i_tau.reshape(-1)
                    
                    # eliminated inputs
                    xx_i_tau = 0
                    for k in xrange(not cont[var_type], self.n_cp + 1):
                        xx_i_k = var_map[i][k]['elim_u']
                        xx_i_tau += xx_i_k * self.pol.eval_basis(
                                k, tau, cont[var_type])
                    var_opt['elim_u'][t_index, :] = xx_i_tau.reshape(-1)
                    
                    # Derivatives
                    dx_i_tau = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[var_indices[i][k]['x']]
                        dx_i_tau += (1. / h_scaled[i] * x_i_k * 
                                     self.pol.eval_basis_der(k, tau))
                    var_opt['dx'][t_index, :] = dx_i_tau.reshape(-1)
                    
                    t_index += 1
        elif self.result_mode == "mesh_points":
            # Start time
            i = 1
            k = 0
            for var_type in var_types:
                xx_i_k = primal_opt[var_indices[i][k][var_type]]
                var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
            var_opt['elim_u'][t_index, :] = var_map[i][k]['elim_u']
            t_index += 1
            k = self.n_cp + self.is_gauss
            
            # Mesh points
            var_types.remove('x')
            if self.discr == "LGR":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        xx_i_k = primal_opt[var_indices[i][k][var_type]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    u_i_k = var_map[i][k]['elim_u']
                    var_opt[var_type][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            elif self.discr == "LG":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        # Evaluate xx_{i, n_cp + 1} based on polynomial xx_i
                        xx_i_k = 0
                        for l in xrange(1, self.n_cp + 1):
                            xx_i_l = primal_opt[var_indices[i][l][var_type]]
                            xx_i_k += xx_i_l * self.pol.eval_basis(l, 1, False)
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    # Evaluate u_{i, n_cp + 1} based on polynomial u_i
                    u_i_k = 0
                    for l in xrange(1, self.n_cp + 1):
                        u_i_l = var_map[i][l]['elim_u']
                        u_i_k += u_i_l * self.pol.eval_basis(l, 1, False)
                    var_opt['elim_u'][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            var_types.insert(0, 'x')
            
            # Handle states separately
            t_index = 1
            for i in xrange(1, self.n_e + 1):
                x_i_k = primal_opt[var_indices[i][k]['x']]
                var_opt['x'][t_index, :] = x_i_k.reshape(-1)
                t_index += 1
            
            # Handle state derivatives separately
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[var_indices[i][k]['dx']]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1
                
                # Mesh point state derivatives
                t_index = 1
                for i in xrange(1, self.n_e + 1):
                    dx_i_k = 0
                    for l in xrange(self.n_cp + 1):
                        x_i_l = primal_opt[var_indices[i][l]['x']]
                        dx_i_k += (1. / h_scaled[i] * x_i_l * 
                                   self.pol.eval_basis_der(l, 1.))
                    var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                    t_index += 1
        else:
            raise ValueError("Unknown result mode %s." % self.result_mode)
        
        # Merge uneliminated and eliminated inputs
        if self.model.get_n_u() > 0:
            var_opt['merged_u'][:, self._unelim_input_indices] = \
                    var_opt['unelim_u']
            var_opt['merged_u'][:, self._elim_input_indices] = \
                    var_opt['elim_u']
        
        # Store optimal inputs for interpolator purposes
        if self.result_mode == "collocation_points":
            u_opt = var_opt['merged_u']
        else:
            t_index = 0
            u_opt = N.empty([self.n_e * self.n_cp + 1, self.model.get_n_u()])
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    unelim_u_i_k = primal_opt[var_indices[i][k]['unelim_u']]
                    u_opt[t_index, self._unelim_input_indices] = \
                        unelim_u_i_k.reshape(-1)
                    elim_u_i_k = self.var_map[i][k]['elim_u']
                    u_opt[t_index, self._elim_input_indices] = \
                        elim_u_i_k.reshape(-1)
                    t_index += 1
        self._u_opt = u_opt
        
        # Denormalize minimum time problem
        if self._normalize_min_time:
            t0_var = self.ocp.variable('startTime')
            tf_var = self.ocp.variable('finalTime')
            if t0_var.getFree():
                vr = t0_var.getValueReference()
                (ind, _) = vr_map[vr]
                t0 = var_opt['p_opt'][ind]
            else:
                t0 = t0_var.getStart()
            if tf_var.getFree():
                vr = tf_var.getValueReference()
                (ind, _) = vr_map[vr]
                tf = var_opt['p_opt'][ind]
            else:
                tf = tf_var.getStart()
            t_opt = t0 + (tf - t0) * t_opt
            var_opt['dx'] /= (tf - t0)

        # Return results
        return (t_opt, var_opt['dx'], var_opt['x'], var_opt['merged_u'],
                var_opt['w'], var_opt['p_opt'])
    
    def get_h_opt(self):
        if self.hs == "free":
            return self.h_opt
        else:
            return None

class LocalDAECollocator2(CasadiCollocator):
    
    """Solves an optimal control problem using local collocation."""
    
    def __init__(self, op, options):
        # Get the options
        self.__dict__.update(options)
        
        # Store model and op objects
        # Remove unneeded_op if unneeded! FIX!!!
        self.unneeded_op = op
        op = op.op
        self.op = op
        model = op.getModel()
        self.model = model        
        
        # Check if minimum time normalization has occured
        print("WARNING: Free time horizons are currently not supported")
        #~ t0 = self.ocp.variable('startTime')
        #~ tf = self.ocp.variable('finalTime')
        #~ if (t0.getFree() and not self.ocp.t0_free or
            #~ tf.getFree() and not self.ocp.tf_free):
            #~ self._normalize_min_time = True
        #~ else:
            #~ self._normalize_min_time = False
        #~ 
        #~ # Get start and final time
        #~ if self._normalize_min_time:
            #~ self.t0 = self.ocp.t0
            #~ self.tf = self.ocp.tf
        #~ else:
            #~ self.t0 = t0.getStart()
            #~ self.tf = tf.getStart()

        # Change this once the above works! FIX!!!
        self.t0 = model.getVariableByName('startTime').getAttribute(
                'bindingExpression')
        self.tf = model.getVariableByName('finalTime').getAttribute(
                'bindingExpression')

        # Not sure if needed? FIX!!!
        #~ # Check normalization of minimum time problems
        #~ t0 = self.ocp.variable('startTime')
        #~ tf = self.ocp.variable('finalTime')
        #~ if (t0.getFree() and self.ocp.t0_free or
            #~ tf.getFree() and self.ocp.tf_free):
            #~ raise CasadiCollocatorException(
                    #~ "Problems with free start or final time must be " +
                    #~ 'compiled with the compiler option "normalize_minimum_' +
                    #~ 'time_problems" enabled.')
        
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
            raise ValueError("Unknown discretization scheme %s." % self.discr)
        
        # Get to work
        self._create_nlp()
    
    def _create_nlp(self):
        """
        Wrapper for creating the NLP.
        """
        self._create_model_variable_map()
        self._eliminate_nonfree_parameters()
        self._update_sf()
        self._get_ocp_expressions()
        self._define_collocation()
        self._create_nlp_variables()
        self._rename_variables()
        self._create_constraints()
        self._create_cost()
        self._compute_bounds_and_init()
        self._create_solver()

    def _create_model_variable_map(self):
        """
        Create map of model variables.

        Create vectorized model variables unless named_vars is enabled.
        """
        # Get model variable vectors
        model = self.model
        op = self.op
        var_kinds = {'dx': model.DERIVATIVE,
                     'x': model.DIFFERENTIATED,
                     'u': model.REAL_INPUT,
                     'w': model.REAL_ALGEBRAIC}
        mvar_vectors = {'dx': N.array([var for var in
                                       model.getVariableByKind(var_kinds['dx'])
                                       if not var.isAlias()]),
                        'x': N.array([var for var in
                                      model.getVariableByKind(var_kinds['x'])
                                      if not var.isAlias()]),
                        'u': N.array([var for var in
                                      model.getVariableByKind(var_kinds['u'])
                                      if not var.isAlias()]),
                        'w': N.array([var for var in
                                      model.getVariableByKind(var_kinds['w'])
                                      if not var.isAlias()])}

        # Count variables (uneliminated inputs and free parameters are counted
        # later)
        n_var = {'dx': len(mvar_vectors["dx"]),
                 'x': len(mvar_vectors["x"]),
                 'u': len(mvar_vectors["u"]),
                 'w': len(mvar_vectors["w"])}

        # Create eliminated and uneliminated input lists
        if (self.measurement_data is None or
            len(self.measurement_data.eliminated) == 0):
            elim_input_indices = []
        else:
            input_names = [u.getName() for u in mvar_vectors['u']]
            elim_names = self.measurement_data.eliminated.keys()
            elim_vars = [model.getModelVariableByName(elim_name)
                         for elim_name in elim_names]
            for (i, elim_var) in enumerate(elim_vars):
                if elim_var is None:
                    raise jmiVariableNotFoundError(
                            "Eliminated input %s is " % elim_names[i] +
                            "not a model variable.")
                if elim_var.getCausality() != elim_var.INPUT:
                    raise ValueError(
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
        
        # Identify free parameters
        # Make sure that startTime and finalTime enter var_vectors of free
        # parameters! FIX!!!
        indep_pars = \
                list(model.getVariableByKind(model.REAL_PARAMETER_INDEPENDENT))
        dep_pars = \
                list(model.getVariableByKind(model.REAL_PARAMETER_DEPENDENT))
        mvar_vectors['p_opt'] =  N.array([par for par in indep_pars + dep_pars
                                          if par.getAttribute("free")])
        mvar_vectors['p'] = N.array([par for par in indep_pars + dep_pars
                                     if not par.getAttribute("free")])
        n_var['p_opt'] = len(mvar_vectors['p_opt'])
        
        # Create named symbolic variable structure
        named_mvar_struct = OrderedDict()
        named_mvar_struct["time"] = [model.getTimeVariable()]
        named_mvar_struct["dx"] = [mvar.getVar() for
                                   mvar in mvar_vectors['dx']]
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

        # Get optimization and model expressions
        initial = model.getInitialResidual()
        dae = model.getDaeResidual()
        path = casadi.vertcat([constr.getResidual() for
                               constr in op.getPathConstraints()])
        mterm = op.getMayerTerm()
        lterm = op.getLagrangeTerm()

        # Substitute named variables with vector variables in expressions
        if self.named_vars:
            self.mvar_struct = named_mvar_struct
        else:
            # Create vector variables
            mvar_struct = ct.struct_msym(
                    [ct.entry("time", shape=1),
                     ct.entry("dx", shape=n_var['dx']),
                     ct.entry("x", shape=n_var['x']),
                     ct.entry("unelim_u", shape=n_var['unelim_u']),
                     ct.entry("w", shape=n_var['w']),
                     ct.entry("p_opt", shape=n_var['p_opt']),
                     ct.entry("elim_u", shape=n_var['elim_u'])])
            named_vars = reduce(list.__add__, named_mvar_struct.values())
            vector_vars = [mvar_struct.cat[i] for
                           i in range(mvar_struct.cat.numel())]

            # Substitute
            # Point constraints here! FIX!!!
            op_expressions = [initial, dae, path, mterm, lterm]
            [initial, dae, path, mterm, lterm] = casadi.substitute(
                    op_expressions, named_vars, vector_vars)
            self.mvar_struct = mvar_struct

        # Store expressions and variable vectors
        self.initial = initial
        self.dae = dae
        self.path = path
        self.mterm = mterm
        self.lterm = lterm
        self.mvar_vectors = mvar_vectors
        self.n_var = n_var

    def _eliminate_nonfree_parameters(self):
        # Update dependent parameters
        model = self.model
        model.calculateValuesForDependentParameters()
        
        # Update optimization expressions
        # Point constraints here! FIX!!!
        op_expressions = [self.initial, self.dae, self.path, self.mterm,
                          self.lterm]
        parameters = casadi.vertcat([p.getVar() for
                                     p in self.mvar_vectors["p"]])
        parameter_values = \
                [p.getAttribute("evalutedBindingExpression").getValue() for
                 p in self.mvar_vectors["p"]]
        [self.initial,
         self.dae,
         self.path,
         self.mterm,
         self.lterm] = casadi.substitute(op_expressions, [parameters],
                                         [parameter_values])

    def _update_sf(self):
        self.model._update_sf()
    
    def _get_ocp_expressions(self):
        """
        Get OCP expressions from model and scale them if necessary.
        
        Timed variables are not scaled until _create_constraints, at
        which point the constraint points are known.
        """
        # Get OCP expressions
        self.initial = casadi.SXMatrix(self.model.get_initial(False))
        self.ode = casadi.SXMatrix(self.model.get_ode(False))
        self.alg = casadi.SXMatrix(self.model.get_alg(False))
        self.path = casadi.SXMatrix(self.model.get_path(False))
        self.point = casadi.SXMatrix(self.model.get_point(False))
        self.mterm = casadi.SXMatrix(self.model.get_mterm(False))
        self.lterm = casadi.SXMatrix(self.model.get_lterm(False))
        
        # Create input lists
        if (self.measurement_data is None or
            len(self.measurement_data.eliminated) == 0):
            elim_input_indices = []
        else:
            input_names = [repr(u) for u in self.model.u]
            try:
                elim_input_indices = [
                        input_names.index(u) for u in
                        self.measurement_data.eliminated.keys()]
            except ValueError:
                raise jmiVariableNotFoundError(
                        "Eliminated input " + u + " is either not an input " +
                        "or not in the model at all.")
        unelim_input_indices = [i for i in range(self.model.u.numel()) if
                                i not in elim_input_indices]
        self._unelim_input_indices = unelim_input_indices
        self._elim_input_indices = elim_input_indices
        self._model_unelim_u = self.model.u[unelim_input_indices]
        self._model_elim_u = self.model.u[elim_input_indices]
        
        sym_input = casadi.vertcat([self.model.t,
                                    self.model.dx,
                                    self.model.x,
                                    self._model_unelim_u,
                                    self.model.w,
                                    self.model.p,
                                    self._model_elim_u])
        sym_input_elim_der = casadi.vertcat([self.model.t,
                                             self.model.x,
                                             self._model_unelim_u,
                                             self.model.w,
                                             self.model.p,
                                             self._model_elim_u])
        self._sym_input = sym_input
        self._sym_input_elim_der = sym_input_elim_der
        
        # Scale variables
        if self.variable_scaling and self.nominal_traj is None:
            # Get scale factors
            sf = copy.copy(self.model.get_sf(False))
            sf['unelim_u'] = sf['u'][unelim_input_indices]
            del sf['u']
            self._sf = sf
            if (self.measurement_data is None or
                len(self.measurement_data.eliminated) == 0):
                variables = sym_input[1:]
            else:
                variables = sym_input[1:-len(elim_input_indices)]
            sfs = N.concatenate([sf['dx'],
                                 sf['x'],
                                 sf['unelim_u'],
                                 sf['w'],
                                 sf['p_opt']])
            
            # Insert scale factors
            ocp_expressions = [self.initial, self.ode, self.alg, self.path,
                               self.point, self.mterm, self.lterm]
            [self.initial,
             self.ode,
             self.alg,
             self.path,
             self.point,
             self.mterm,
             self.lterm] = casadi.substitute(ocp_expressions, [variables],
                                             [sfs * variables])
    
    def _define_collocation(self):
        """
        Define collocation variables.
        
        The variables are used for either creating the collocation constraints
        or eliminating the derivative variables.
        """
        collocation = {}
        dx_i_k = casadi.ssym("dx_i_k", self.model.get_n_x())
        x_i = casadi.ssym("x_i", self.model.get_n_x(), self.n_cp + 1)
        der_vals_k = casadi.ssym("der_vals[k]", self.model.get_n_x(),
                                 self.n_cp + 1)
        h_i = casadi.ssym("h_i")
        collocation['coll_der'] = casadi.sumCols(x_i * der_vals_k) / h_i
        collocation['coll_eq'] = casadi.sumCols(x_i * der_vals_k) - h_i*dx_i_k
        collocation['dx_i_k'] = dx_i_k
        collocation['x_i'] = x_i
        collocation['der_vals_k'] = der_vals_k
        collocation['h_i'] = h_i
        self._collocation = collocation
    
    def _create_nlp_variables(self, rename=False):
        """
        Create the NLP variables and store them in a nested dictionary.
        """
        # Set model info
        n_var = {'dx': self.model.get_n_x(), 'x': self.model.get_n_x(),
                 'unelim_u': self._model_unelim_u.numel(),
                 'w': self.model.get_n_w()}
        n_u = self._model_unelim_u.numel()
        self._n_var = copy.copy(n_var)
        if self.blocking_factors is not None:
            del n_var['unelim_u']
        if self.eliminate_der_var:
            del n_var['dx']
        
        # Count NLP variables
        n_xx = self.model.get_n_p()
        n_xx += (1 + self.n_e * self.n_cp) * N.sum(n_var.values())
        if self.eliminate_der_var:
            n_xx += n_var['x'] # dx_1_0
        if self.blocking_factors is not None:
            self.blocking_factors = list(self.blocking_factors)
            n_xx += len(self.blocking_factors) * n_u
        if not self.eliminate_cont_var:
            n_xx += (self.n_e - 1) * n_var['x']
        self.is_gauss = (self.discr == "LG")
        if self.is_gauss:
            n_xx += (self.n_e - 1) * n_var['x'] # Mesh points
            n_xx += N.sum(n_var.values()) # tf
        if self.hs == "free":
            n_xx += self.n_e
        
        # Create NLP variables
        if self.graph == "MX":
            xx = casadi.msym("xx", n_xx)
        elif self.graph == "SX":
            xx = casadi.ssym("xx", n_xx)
        else:
            raise ValueError("Unknown CasADi graph %s." % self.graph)
        
        # Get variables with correct names
        if rename:
            xx = self.xx
        
        # Create objects for variable indexing
        var_map = {}
        var_indices = {}
        index = 0
        
        # Index the parameters
        new_index = index + self.model.get_n_p()
        var_indices['p_opt'] = range(index, new_index)
        index = new_index
        var_map['p_opt'] = xx[var_indices['p_opt']]
        
        # Index the variables at the collocation points
        for i in xrange(1, self.n_e + 1):
            var_indices[i] = {}
            var_map[i] = {}
            for k in xrange(1, self.n_cp + 1):
                var_indices[i][k] = {}
                var_map[i][k] = {}
                for var_type in n_var.keys():
                    new_index = index + n_var[var_type]
                    var_indices[i][k][var_type] = range(index, new_index)
                    index = new_index
                    var_map[i][k][var_type] = xx[var_indices[i][k][var_type]]
        
        # Index controls separately if blocking_factors is not None
        if self.blocking_factors is not None:
            element = 1
            for factor in self.blocking_factors:
                new_index = index + n_u
                indices = range(index, new_index)
                for i in xrange(element, element + factor):
                    for k in xrange(1, self.n_cp + 1):
                        var_indices[i][k]['unelim_u'] = indices
                        var_map[i][k]['unelim_u'] = \
                                xx[var_indices[i][k]['unelim_u']]
                index = new_index
                element += factor
        
        # Index state continuity variables
        if self.discr == "LGR":
            if self.eliminate_cont_var:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    var_indices[i][0]['x'] = var_indices[i - 1][self.n_cp]['x']
                    var_map[i][0]['x'] = var_map[i - 1][self.n_cp]['x']
            else:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    new_index = index + n_var['x']
                    var_indices[i][0]['x'] = range(index, new_index)
                    index = new_index
                    var_map[i][0]['x'] = xx[var_indices[i][0]['x']]
        elif self.discr == "LG":
            # Index x_{i, n_cp + 1}
            for i in xrange(1, self.n_e):
                var_indices[i][self.n_cp + 1] = {}
                var_map[i][self.n_cp + 1] = {}
                
                new_index = index + n_var['x']
                var_indices[i][self.n_cp + 1]['x'] = range(index, new_index)
                index = new_index
                var_map[i][self.n_cp + 1]['x'] = \
                        xx[var_indices[i][self.n_cp + 1]['x']]
            
            # Index x_{i, 0}
            if self.eliminate_cont_var:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    var_indices[i][0]['x'] = \
                            var_indices[i - 1][self.n_cp + 1]['x']
                    var_map[i][0]['x'] = var_map[i - 1][self.n_cp + 1]['x']
            else:
                for i in xrange(2, self.n_e + 1):
                    var_indices[i][0] = {}
                    var_map[i][0] = {}
                    new_index = index + n_var['x']
                    var_indices[i][0]['x'] = range(index, new_index)
                    index = new_index
                    var_map[i][0]['x'] = xx[var_indices[i][0]['x']]
        else:
            raise ValueError("Unknown discretization scheme %s." %
                             self.discr)
        
        # Index variables for final mesh point
        if self.is_gauss:
            i = self.n_e
            k = self.n_cp + 1
            var_indices[i][k] = {}
            var_map[i][k] = {}
            for var_type in n_var.keys():
                new_index = index + n_var[var_type]
                var_indices[i][k][var_type] = range(index, new_index)
                index = new_index
                var_map[i][k][var_type] = xx[var_indices[i][k][var_type]]
        
        # Index the variables for the derivative initial values
        var_map[1][0] = {}
        var_indices[1][0] = {}
        if self.eliminate_der_var:
            new_index = index + n_var['x']
            var_indices[1][0]['dx'] = range(index, new_index)
            index = new_index
            var_map[1][0]['dx'] = xx[var_indices[1][0]['dx']]
        
        # Index the variables for the remaining initial values
        for var_type in n_var.keys():
            new_index = index + n_var[var_type]
            var_indices[1][0][var_type] = range(index, new_index)
            index = new_index
            var_map[1][0][var_type] = xx[var_indices[1][0][var_type]]
            
        # Index initial controls separately if blocking_factors is not None
        if self.blocking_factors is not None:
            var_indices[1][0]['unelim_u'] = var_indices[1][1]['unelim_u']
            var_map[1][0]['unelim_u'] = xx[var_indices[1][0]['unelim_u']]
            
        # Index element lengths
        if self.hs == "free":
            new_index = index + self.n_e
            var_indices['h'] = [N.nan] + range(index, new_index)
            index = new_index
            self.h = casadi.vertcat([N.nan, xx[var_indices['h'][1:]]])
        
        assert(index == n_xx)
        
        # Save variables and indices as data attributes
        self.xx = xx
        self.n_xx = n_xx
        self.var_map = var_map
        self.var_indices = var_indices
        
    def _rename_variables(self):
        """
        Renames the NLP variables.
        
        This only works for SX graphs. It's also done in a very inefficient
        manner and should only be used for debugging purposes. The NLP
        variables are essentially created twice; first with incorrect names and
        then recreated with correct names.
        """
        if self.rename_vars:
            if self.graph != "SX":
                raise NotImplementedError("Variable renaming only works " + \
                                          "for SX graphs.")
            xx = casadi.SXMatrix(self.n_xx, 1)
            var_indices = self.var_indices
            
            for i in xrange(1, self.n_e+1):
                if self.hs == "free":
                    xx[var_indices['h'][i]] = casadi.ssym("h_" + str(i))
                for k in var_indices[i].keys():
                    if (not self.eliminate_der_var and
                        'dx' in var_indices[i][k].keys()):
                        dx = casadi.SXMatrix(self.model.get_n_x(), 1)
                        for j in xrange(self.model.get_n_x()):
                            dx[j, 0] = (
                                    casadi.ssym(str(self.model.get_dx()[j]) +
                                    '_' + str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['dx'], 0] = dx
                    
                    if not self.eliminate_cont_var or k > 0 or i == 1:
                        if 'x' in var_indices[i][k].keys():
                            x = casadi.SXMatrix(self.model.get_n_x(), 1)
                            for j in xrange(self.model.get_n_x()):
                                x[j, 0] = (
                                        casadi.ssym(str(self.model.get_x()[j]) +
                                        '_' +  str(i) + '_' + str(k)))
                            xx[var_indices[i][k]['x'], 0] = x
                    
                    if 'unelim_u' in var_indices[i][k].keys():
                        u = casadi.SXMatrix(self._model_unelim_u.numel(), 1)
                        for j in xrange(self._model_unelim_u.numel()):
                            u[j, 0] = (
                                    casadi.ssym(str(self._model_unelim_u[j]) +
                                    '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['unelim_u'], 0] = u
                    
                    if 'w' in var_indices[i][k].keys():
                        w = casadi.SXMatrix(self.model.get_n_w(), 1)
                        for j in xrange(self.model.get_n_w()):
                            w[j, 0] = (
                                    casadi.ssym(str(self.model.get_w()[j]) +
                                    '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['w'], 0] = w
            
            if 'p_opt' in var_indices.keys():
                p_opt = casadi.SXMatrix(self.model.get_n_p(), 1)
                for j in xrange(self.model.get_n_p()):
                    p_opt[j, 0] = casadi.ssym(str(self.model.get_p()[j]))
                xx[var_indices['p_opt'], 0] = p_opt
            
            # Derivative initial values
            if self.eliminate_der_var:
                dx = casadi.SXMatrix(self.model.get_n_x(), 1)
                for j in xrange(self.model.get_n_x()):
                    dx[j, 0] = casadi.ssym(
                            str(self.model.get_dx()[j]) + '_1_0')
                xx[var_indices[1][0]['dx'], 0] = dx
            
            self.xx = xx
            self._create_nlp_variables(True)
    
    def _get_z(self, i, k):
        """
        Return a vector with all the NLP variables at a collocation point.
        
        Assumes the state derivatives are NLP variables.
        
        Parameters::
        
            i --
                Element index.
                Type: int
                 
            k --
                Collocation point.
                Type: int
                
        Returns::
        
            z --
                NLP variable vector.
                Type: MX or SXMatrix
        """
        z = casadi.vertcat([self.time_points[i][k],
                            self.var_map[i][k]['dx'],
                            self.var_map[i][k]['x'],
                            self.var_map[i][k]['unelim_u'],
                            self.var_map[i][k]['w'],
                            self.var_map['p_opt'],
                            self.var_map[i][k]['elim_u']])
        return z
    
    def _get_z_elim_der(self, i, k):
        """
        Return a vector with all the NLP variables at a collocation point.
        
        Assumes the state derivatives are not NLP variables.
        
        Parameters::
        
            i --
                Element index.
                Type: int
                 
            k --
                Collocation point.
                Type: int
                
        Returns::
        
            z --
                NLP variable vector.
                
                Type: MX or SXMatrix
        """
        z = casadi.vertcat([self.time_points[i][k],
                            self.var_map[i][k]['x'],
                            self.var_map[i][k]['unelim_u'],
                            self.var_map[i][k]['w'],
                            self.var_map['p_opt'],
                            self.var_map[i][k]['elim_u']])
        return z
    
    def _eliminate_der_var(self):
        """
        Eliminate derivative variables from OCP expressions.
        """
        if self.eliminate_der_var:
            coll_der = self._collocation['coll_der']
            self.ode_t0 = self.ode
            self.alg_t0 = self.alg
            ocp_expressions = [self.ode,
                               self.alg,
                               self.path,
                               self.point,
                               self.mterm,
                               self.lterm]
            [self.ode,
             self.alg,
             self.path,
             self.point,
             self.mterm,
             self.lterm] = casadi.substitute(ocp_expressions, [self.model.dx],
                                             [coll_der])
    
    def _create_constraints(self):
        """
        Create the constraints and time points.
        """
        # Get local references
        var_map = self.var_map
        var_vectors = copy.copy(self.model._var_vectors)
        var_vectors['unelim_u'] = copy.copy([var_vectors['u'][i] for
                                             i in self._unelim_input_indices])
        var_vectors['elim_u'] = copy.copy([var_vectors['u'][i] for
                                           i in self._elim_input_indices])
        del var_vectors['u']
        self._var_vectors = var_vectors
        
        # Update inputs in vr_map
        vr_map = copy.copy(self.model.get_vr_map())
        for vt in ['elim_u', 'unelim_u']:
            for ind in xrange(len(var_vectors[vt])):
                vr = var_vectors[vt][ind].getValueReference()
                vr_map[vr] = (ind, vt)
        self._vr_map = vr_map
        
        # Check that only inputs are constrained or eliminated
        if self.measurement_data is not None:
            for var_name in (self.measurement_data.eliminated.keys() +
                             self.measurement_data.constrained.keys()):
                vr = self.model.xmldoc.get_value_reference(var_name)
                (_, vt) = vr_map[vr]
                if vt not in ['elim_u', 'unelim_u']:
                    if var_name in self.measurement_data.eliminated.keys():
                        msg = ("Eliminated variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    else:
                        msg = ("Constrained variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    raise jmiVariableNotFoundError(msg)
        
        # Broadcast self.pol.der_vals
        # Note that der_vals is quite different from self.pol.der_vals
        der_vals = []
        self.der_vals = der_vals
        for k in xrange(self.n_cp + 1):
            der_vals_k = [self.pol.der_vals[:, k].reshape([1, self.n_cp + 1])]
            der_vals_k *= self.model.get_n_x()
            der_vals.append(casadi.vertcat(der_vals_k))
            
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
        
        # Map constraint points to collocation points
        if not self.ocp.point.empty() and self.hs == "free":
            raise CasadiCollocatorException("Point constraints can not be " +
                                            "combined with free element " +
                                            "lengths.")
        if self.graph == "SX":
            nlp_timed_variables = casadi.SXMatrix()
        else:
            nlp_timed_variables = casadi.MX()
        if self.hs == "free":
            timed_variables = casadi.SXMatrix()
        else:
            collocation_constraint_points = []
            for constraint_point in self.ocp.tp:
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
                        collocation_constraint_points.append((1, 0))
                    elif (self.is_gauss and
                          N.allclose(constraint_point, self.tf)):
                        collocation_constraint_points.append(
                                (self.n_e, self.n_cp + 1))
                    else:
                        raise CasadiCollocatorException(
                                "Constraint point " + `constraint_point` +
                                " does not coincide with a collocation point.")
                else:
                    (e, cp) = divmod(tp_index, self.n_cp)
                    collocation_constraint_points.append((e + 1, cp + 1))
        
            # Compose timed variables and corresponding NLP variables
            var_vector_list = [var_vectors['x'],
                               var_vectors['unelim_u'],
                               var_vectors['w']]
            timed_variables = casadi.SXMatrix(
                    [vari.atTime(tp, True) for
                     tp in self.ocp.tp for
                     var_vector in var_vector_list for
                     vari in var_vector])
            for (i, k) in collocation_constraint_points:
                for var_type in ['x', 'unelim_u', 'w']:
                    nlp_timed_variables.append(var_map[i][k][var_type])
            
            # Check that point constraints do not depend on eliminated inputs
            timed_inputs = casadi.SXMatrix(
                    [vari.atTime(tp, True) for
                     tp in self.ocp.tp for
                     vari in var_vectors['elim_u']])
            if not casadi.isZero(casadi.jacobian(self.point, timed_inputs)):
                raise CasadiCollocatorException("Point constraints may not " +
                                                "depend on eliminated inputs.")
        
        # Scale timed variables
        if (self.variable_scaling and self.nominal_traj is None and
            self.hs != "free"):
            # Get scale factors
            sf = self._sf
            nbr_constraint_points = len(collocation_constraint_points)
            if nbr_constraint_points > 0:
                timed_variables_sfs = N.concatenate(
                        nbr_constraint_points *
                        [sf['x'], sf['unelim_u'], sf['w']])
                
                # Insert scale factors
                ocp_expressions = [self.path, self.point, self.mterm]
                [self.path,
                 self.point,
                 self.mterm] = casadi.substitute(ocp_expressions,
                                                 [timed_variables],
                                                 [timed_variables_sfs *
                                                  timed_variables])
        
        # Denormalize time for minimum time problems
        if self._normalize_min_time:
            t0_var = self.ocp.variable('startTime')
            tf_var = self.ocp.variable('finalTime')
            if t0_var.getFree():
                if self.init_traj is None:
                    t0_init = t0_var.getInitialGuess()
                else:
                    try:
                        data = self.init_traj.get_variable_data("startTime")
                    except VariableNotFoundError:
                        if t0_var.getInitialGuess() == 0.:
                            print("Warning: Could not find initial guess " +
                                  "for startTime in initial trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            t0_init = self.init_traj.get_variable_data(
                                    "time").t[0]
                        else:
                            print("Warning: Could not find initial guess " +
                                  "for startTime in initial trajectories. " +
                                  "Using initialGuess attribute value " +
                                  "instead.")
                            t0_init = t0_var.getInitialGuess()
                    else:
                        t0_init = data.x[0]
                if self.nominal_traj is None:
                    t0_nom = t0_var.getNominal()
                else:
                    try:
                        mode = self.nominal_traj_mode["startTime"]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    if mode == "attribute":
                        t0_nom = t0_var.getNominal()
                    else:
                        try:
                            data = self.nominal_traj.get_variable_data(
                                    "startTime")
                        except VariableNotFoundError:
                            print("Warning: Could not find nominal value " +
                                  "for startTime in nominal trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            t0_nom = self.nominal_traj.get_variable_data(
                                    "time").t[0]
                        else:
                            t0_nom = data.x[0]
            else:
                t0_init = t0_var.getStart()
                t0_nom = t0_var.getStart()
                assert tf_var.getFree(), \
                       "Bug: Time should not have been normalized"
            if tf_var.getFree():
                if self.init_traj is None:
                    tf_init = tf_var.getInitialGuess()
                else:
                    try:
                        data = self.init_traj.get_variable_data("finalTime")
                    except VariableNotFoundError:
                        if tf_var.getInitialGuess() == 1.:
                            print("Warning: Could not find initial guess " +
                                  "for finalTime in initial trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            tf_init = self.init_traj.get_variable_data(
                                    "time").t[-1]
                        else:
                            print("Warning: Could not find initial guess " +
                                  "for finalTime in initial trajectories. " +
                                  "Using initialGuess attribute value " +
                                  "instead.")
                            tf_init = tf_var.getInitialGuess()
                    else:
                        tf_init = data.x[0]
                if self.nominal_traj is None:
                    tf_nom = tf_var.getNominal()
                else:
                    try:
                        mode = self.nominal_traj_mode["finalTime"]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    if mode == "attribute":
                        tf_nom = tf_var.getNominal()
                    else:
                        try:
                            data = self.nominal_traj.get_variable_data(
                                    "finalTime")
                        except VariableNotFoundError:
                            print("Warning: Could not find nominal value " +
                                  "for finalTime in nominal trajectories. " +
                                  "Using end-point of provided time horizon " +
                                  "instead.")
                            tf_nom = self.nominal_traj.get_variable_data(
                                    "time").t[0]
                        else:
                            tf_nom = data.x[0]
            else:
                tf_init = tf_var.getStart()
                tf_nom = tf_var.getStart()
            self._denorm_t0_init = t0_init
            self._denorm_tf_init = tf_init
            self._denorm_t0_nom = t0_nom
            self._denorm_tf_nom = tf_nom
        
        # Create nominal trajectories
        if self.variable_scaling and self.nominal_traj is not None:
            nom_traj = {"dx": {}}
            vr_map = self._vr_map
            n = len(self.nominal_traj.get_data_matrix()[:, 0])
            for vt in ['x', 'unelim_u', 'w']:
                nom_traj[vt] = {}
                for var in var_vectors[vt]:
                    data_matrix = N.empty([n, len(var_vectors[vt])])
                    (var_index, _) = vr_map[var.getValueReference()]
                    name = var.getName()
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        # It is possibly to treat missing variable trajectories
                        # more efficiently, especially in the case of MX
                        print("Warning: Could not find nominal trajectory " +
                              "for variable " + name + ". Using nominal " +
                              "attribute value instead.")
                        abscissae = N.array([0])
                        nom_val = var.getNominal()
                        if nom_val is None:
                            constant_sf = 1
                        else:
                            constant_sf = N.abs(nom_val)
                        ordinates = N.array([[constant_sf]])
                    else:
                        abscissae = data.t
                        ordinates = data.x.reshape([-1, 1])
                    nom_traj[vt][var_index] = \
                            TrajectoryLinearInterpolation(abscissae, ordinates)
                    
                    # Treat derivatives separately
                    if vt == "x":
                        data_matrix = N.empty([n, len(var_vectors[vt])])
                        name = convert_casadi_der_name(str(var.der()))
                        vr = self.model.xmldoc.get_value_reference(name)
                        (var_index, _) = vr_map[vr]
                        try:
                            data = self.nominal_traj.get_variable_data(name)
                        except VariableNotFoundError:
                            # It is possibly to treat missing variable 
                            # trajectories more efficiently, especially in the
                            # case of MX
                            print("Warning: Could not find nominal " +
                                  "trajectory for variable " + name + ". " +
                                  "Using nominal attribute value instead.")
                            abscissae = N.array([0])
                            nom_val = var.getNominal()
                            if nom_val is None:
                                constant_sf = 1
                            else:
                                constant_sf = N.abs(nom_val)
                            ordinates = N.array([[constant_sf]])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        nom_traj["dx"][var_index] = \
                                TrajectoryLinearInterpolation(abscissae,
                                                              ordinates)
            
            # Create storage for scaling factors
            time_points = self.get_time_points()
            n_var = copy.copy(self._n_var)
            is_variant = {}
            variant_var = casadi.SXMatrix(0, 1)
            n_variant_x = 0
            n_variant_dx = 0
            variant_sf = {}
            invariant_var = casadi.SXMatrix(0, 1)
            invariant_d = []
            invariant_e = []
            variant_timed_var = casadi.SXMatrix(0, 1)
            variant_timed_sf = []
            vr_sf_map = {}
            self._is_variant = is_variant
            self._variant_sf = variant_sf
            self._invariant_d = invariant_d
            self._invariant_e = invariant_e
            self._vr_sf_map = vr_sf_map
            for i in xrange(1, self.n_e + 1):
                variant_sf[i] = {}
                for k in time_points[i]:
                    variant_sf[i][k] = []
            
            # Evaluate trajectories to generate scaling factors
            for vt in ['x', 'unelim_u', 'w']:
                for var in var_vectors[vt]:
                    vr = var.getValueReference()
                    (var_index, _) = vr_map[vr]
                    name = var.getName()
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
                        raise ValueError("Unknown scaling mode %s " % mode +
                                         "for variable %s." % name)
                    if variant:
                        if vt == "x":
                            n_variant_x += 1
                        is_variant[vr] = True
                        vr_sf_map[vr] = variant_var.numel()
                        variant_var.append(var.var())
                        for i in xrange(1, self.n_e + 1):
                            for k in time_points[i]:
                                variant_sf[i][k].append(N.abs(values[i][k]))
                        for l in xrange(len(self.ocp.tp)):
                            tp = self.ocp.tp[l]
                            (i, k) = collocation_constraint_points[l]
                            variant_timed_var.append(var.atTime(tp))
                            variant_timed_sf.append(N.abs(values[i][k]))
                    else:
                        is_variant[vr] = False
                        if mode == "attribute":
                            d = N.abs(var.getNominal())
                            e = 0.
                        elif mode == "linear":
                            d = max([abs(traj_max), abs(traj_min)])
                            if d == 0.0:
                                d = 1.
                                print("Warning: Nominal trajectory for " +
                                      "variable %s is identically " % name + 
                                      "zero.")
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
                                if traj_max == 0.0:
                                    print("Warning: Nominal trajectory for " +
                                          "variable %s is " % name + 
                                          "identically zero.")
                                    d = 1.
                                else:
                                    d = max([abs(traj_max), abs(traj_min)])
                                e = 0.
                            else:
                                d = traj_max - traj_min
                                e = traj_min
                        vr_sf_map[vr] = invariant_var.numel()
                        invariant_var.append(var.var())
                        invariant_d.append(d)
                        invariant_e.append(e)
                        for tp in self.ocp.tp:
                            invariant_var.append(var.atTime(tp))
                            invariant_d.append(d)
                            invariant_e.append(e)
            
            # Do not scaled eliminated inputs
            for var in var_vectors['elim_u']:
                vr = var.getValueReference()
                is_variant[vr] = False
                d = 1.
                e = 0.
                vr_sf_map[vr] = invariant_var.numel()
                invariant_var.append(var.var())
                invariant_d.append(d)
                invariant_e.append(e)
            
            # Evaluate trajectories for state derivatives
            # Heavy code duplication from above
            for var in var_vectors["x"]:
                name = convert_casadi_der_name(str(var.der()))
                try:
                    mode = self.nominal_traj_mode[name]
                except KeyError:
                    mode = self.nominal_traj_mode["_default_mode"]
                vr = self.model.xmldoc.get_value_reference(name)
                (var_index, _) = vr_map[vr]
                values = {}
                traj_min = N.inf
                traj_max = -N.inf
                for i in xrange(1, self.n_e + 1):
                    values[i] = {}
                    for k in time_points[i]:
                        tp = time_points[i][k]
                        if self._normalize_min_time:
                            tp = t0_nom + (tf_nom - t0_nom) * tp
                        val = float(nom_traj["dx"][var_index].eval(tp))
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
                    raise ValueError("Unknown scaling mode %s " % mode +
                                     "for variable %s." % name)
                if variant:
                    n_variant_dx += 1
                    is_variant[vr] = True
                    vr_sf_map[vr] = variant_var.numel()
                    variant_var.append(var.der())
                    for i in xrange(1, self.n_e + 1):
                        for k in time_points[i]:
                            variant_sf[i][k].append(N.abs(values[i][k]))
                else:
                    is_variant[vr] = False
                    if mode == "attribute":
                        d = N.abs(var.getNominal())
                        e = 0.
                    elif mode == "linear":
                        d = max([abs(traj_max), abs(traj_min)])
                        if d == 0.0:
                            d = 1.
                            print("Warning: Nominal trajectory for " +
                                  "variable %s is identically " % name + 
                                  "zero.")
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
                            if N.allclose(traj_max, 0.):
                                d = 1.
                            else:
                                d = max([abs(traj_max), abs(traj_min)])
                            e = 0.
                        else:
                            d = traj_max - traj_min
                            e = traj_min
                    vr_sf_map[vr] = invariant_var.numel()
                    invariant_var.append(var.der())
                    invariant_d.append(d)
                    invariant_e.append(e)
            
            # Handle free parameters
            for var in self.ocp.pf:
                vr = var.getValueReference()
                (var_index, _) = vr_map[vr]
                is_variant[vr] = False
                name = var.getName()
                if name == "startTime":
                    d = N.abs(self._denorm_t0_nom)
                    if N.allclose(d, 0.):
                        d = 1.
                    e = 0.
                elif name == "finalTime":
                    d = N.abs(self._denorm_tf_nom)
                    if N.allclose(d, 0.):
                        d = 1.
                    e = 0.
                else:
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        print("Warning: Could not find nominal trajectory " +
                              "for variable " + name + ". Using nominal " +
                              "attribute value instead.")
                        nom_val = var.getNominal()
                        if nom_val is None:
                            d = 1.
                        else:
                            d = N.abs(nom_val)
                        e = 0.
                    else:
                        d = N.abs(data.x[0])
                        e = 0.
                vr_sf_map[vr] = invariant_var.numel()
                invariant_var.append(var.var())
                invariant_d.append(d)
                invariant_e.append(e)
        
        # Create measured input trajectories
        if (self.measurement_data is None or
            len(self.measurement_data.eliminated) == 0):
            for i in xrange(1, self.n_e + 1):
                for k in self.time_points[i].keys():
                    var_map[i][k]['elim_u'] = N.array([])
        if (self.measurement_data is not None and
            (len(self.measurement_data.eliminated) +
             len(self.measurement_data.constrained) > 0)):
            # Create storage of maximum and minimum values
            traj_min = OrderedDict()
            traj_max = OrderedDict()
            for name in (self.measurement_data.eliminated.keys() +
                         self.measurement_data.constrained.keys()):
                traj_min[name] = N.inf
                traj_max[name] = -N.inf
            
            # Collocation points
            for i in xrange(1, self.n_e + 1):
                for k in self.time_points[i].keys():
                    # Eliminated inputs
                    values = []
                    for (name, data) in \
                            self.measurement_data.eliminated.items():
                        value = data.eval(self.time_points[i][k])[0, 0]
                        values.append(value)
                        if value < traj_min[name]:
                            traj_min[name] = value
                        if value > traj_max[name]:
                            traj_max[name] = value
                    var_map[i][k]['elim_u'] = N.array(values)
                    
                    # Constrained inputs
                    values = []
                    for (name, data) in \
                            self.measurement_data.constrained.items():
                        value = data.eval(self.time_points[i][k])[0, 0]
                        values.append(value)
                        if value < traj_min[name]:
                            traj_min[name] = value
                        if value > traj_max[name]:
                            traj_max[name] = value
                    var_map[i][k]['constr_u'] = N.array(values)
            
            # Check that constrained and eliminated inputs satisfy their bounds
            for var_name in (self.measurement_data.eliminated.keys() +
                             self.measurement_data.constrained.keys()):
                var_min = self.ocp.variable(var_name).getMin()
                var_max = self.ocp.variable(var_name).getMax()
                if traj_min[name] < var_min:
                    raise CasadiCollocatorException(
                        "The trajectory for the measured input " + name +
                        " does not satisfy the input's lower bound.")
                if traj_max[name] > var_max:
                    raise CasadiCollocatorException(
                        "The trajectory for the measured input " + name +
                        " does not satisfy the input's upper bound.")
        
        # Create collocation and DAE functions
        sym_input = self._sym_input
        sym_input_elim_der = self._sym_input_elim_der
        dx_i_k = self._collocation['dx_i_k']
        x_i = self._collocation['x_i']
        der_vals_k = self._collocation['der_vals_k']
        h_i = self._collocation['h_i']
        coll_eq = self._collocation['coll_eq']
        coll_der = self._collocation['coll_der']
        if not self.variable_scaling or self.nominal_traj is None:
            self._eliminate_der_var()
            initial_fcn = casadi.SXFunction([sym_input], [self.initial])
            if self.eliminate_der_var:
                ode_fcn = casadi.SXFunction(
                        [sym_input_elim_der, x_i, der_vals_k, h_i],
                        [self.ode])
                alg_fcn = casadi.SXFunction(
                        [sym_input_elim_der, x_i, der_vals_k, h_i],
                        [self.alg])
                ode_fcn_t0 = casadi.SXFunction([sym_input], [self.ode_t0])
                alg_fcn_t0 = casadi.SXFunction([sym_input], [self.alg_t0])
                ode_fcn_t0.init()
                alg_fcn_t0.init()
            else:
                coll_eq_fcn = casadi.SXFunction([x_i, der_vals_k, h_i, dx_i_k],
                                                [coll_eq])
                coll_eq_fcn.init()
                ode_fcn = casadi.SXFunction([sym_input], [self.ode])
                alg_fcn = casadi.SXFunction([sym_input], [self.alg])
        else:
            # Scale variables in collocation equations
            x_i_sf = casadi.ssym("x_i_sf", (self.n_cp + 1) * n_variant_x)
            variant_x_i = casadi.SXMatrix(0, 1)
            invariant_x_i = casadi.SXMatrix(0, 1)
            invariant_x_i_d = []
            invariant_x_i_e = []
            if not self.eliminate_der_var:
                dx_i_k_sf = casadi.ssym("dx_i_k_sf", n_variant_dx)
                variant_dx_i_k = casadi.SXMatrix(0, 1)
                invariant_dx_i_k = casadi.SXMatrix(0, 1)
                invariant_dx_i_k_d = []
                invariant_dx_i_k_e = []
            for var in var_vectors['x']:
                x_vr = var.getValueReference()
                dx_name = convert_casadi_der_name(str(var.der()))
                dx_vr = self.model.xmldoc.get_value_reference(dx_name)
                
                (ind, _) = vr_map[x_vr]
                x_i_temp = x_i[ind, :].reshape([self.n_cp + 1, 1])
                if is_variant[x_vr]:
                    variant_x_i.append(x_i_temp)
                else:
                    invariant_x_i.append(x_i_temp)
                    x_sf_index = vr_sf_map[x_vr]
                    for k in xrange(self.n_cp + 1):
                        invariant_x_i_d.append(invariant_d[x_sf_index])
                        invariant_x_i_e.append(invariant_e[x_sf_index])
                if not self.eliminate_der_var:
                    if is_variant[dx_vr]:
                        variant_dx_i_k.append(dx_i_k[ind])
                    else:
                        invariant_dx_i_k.append(dx_i_k[ind])
                        dx_sf_index = vr_sf_map[dx_vr]
                        invariant_dx_i_k_d.append(invariant_d[dx_sf_index])
                        invariant_dx_i_k_e.append(invariant_e[dx_sf_index])
            
            invariant_x_i_d = N.array(invariant_x_i_d)
            invariant_x_i_e = N.array(invariant_x_i_e)
            unscaled_var = casadi.SXMatrix(0, 1)
            unscaled_var.append(invariant_x_i)
            unscaled_var.append(variant_x_i)
            scaled_var = casadi.SXMatrix(0, 1)
            scaled_var.append(invariant_x_i_d * invariant_x_i +
                              invariant_x_i_e)
            scaled_var.append(x_i_sf * variant_x_i)
            if self.eliminate_der_var:
                coll_der = casadi.substitute(coll_der, unscaled_var,
                                             scaled_var)
                self._collocation['coll_der'] = coll_der
                self._eliminate_der_var()
            else:
                invariant_dx_i_k_d = N.array(invariant_dx_i_k_d)
                invariant_dx_i_k_e = N.array(invariant_dx_i_k_e)
                unscaled_var.append(invariant_dx_i_k)
                unscaled_var.append(variant_dx_i_k)
                scaled_var.append(invariant_dx_i_k_d * invariant_dx_i_k +
                                  invariant_dx_i_k_e)
                scaled_var.append(dx_i_k_sf * variant_dx_i_k)
                coll_eq = casadi.substitute(coll_eq, unscaled_var, scaled_var)
            
            # Scale variables in expressions
            sym_sf = casadi.ssym("d_i_k", variant_var.numel())
            self._sym_sf = sym_sf
            ocp_expressions = [self.initial, self.ode, self.alg, self.path,
                               self.point, self.mterm, self.lterm]
            if self.eliminate_der_var:
                ocp_expressions += [self.ode_t0, self.alg_t0]
            unscaled_var = casadi.SXMatrix(0, 1)
            unscaled_var.append(invariant_var)
            unscaled_var.append(variant_var)
            unscaled_var.append(variant_timed_var)
            scaled_var = casadi.SXMatrix(0, 1)
            scaled_var.append(N.array(invariant_d) * invariant_var +
                              N.array(invariant_e))
            scaled_var.append(sym_sf * variant_var)
            scaled_var.append(N.array(variant_timed_sf) * variant_timed_var)
            scaled_expressions = casadi.substitute(ocp_expressions,
                                                   [unscaled_var],
                                                   [scaled_var])
            if self.eliminate_der_var:
                [self.initial, self.ode, self.alg, self.path, self.point,
                 self.mterm, self.lterm, self.ode_t0, self.alg_t0] = \
                        scaled_expressions
            else:
                [self.initial, self.ode, self.alg, self.path, self.point,
                 self.mterm, self.lterm] = scaled_expressions
            
            # Create functions
            initial_fcn = casadi.SXFunction([sym_input, sym_sf],
                                            [self.initial])
            if self.eliminate_der_var:
                ode_fcn = casadi.SXFunction([sym_input_elim_der, x_i,
                                             der_vals_k, h_i, sym_sf, x_i_sf], 
                                            [self.ode])
                alg_fcn = casadi.SXFunction([sym_input_elim_der, x_i,
                                             der_vals_k, h_i, sym_sf, x_i_sf],
                                            [self.alg])
                ode_fcn_t0 = casadi.SXFunction([sym_input, sym_sf],
                                               [self.ode_t0])
                alg_fcn_t0 = casadi.SXFunction([sym_input, sym_sf],
                                               [self.alg_t0])
                ode_fcn_t0.init()
                alg_fcn_t0.init()
            else:
                coll_eq_fcn = casadi.SXFunction(
                        [x_i, der_vals_k, h_i, dx_i_k, x_i_sf, dx_i_k_sf],
                        [coll_eq])
                coll_eq_fcn.init()
                ode_fcn = casadi.SXFunction([sym_input, sym_sf], [self.ode])                
                alg_fcn = casadi.SXFunction([sym_input, sym_sf], [self.alg])
        
        # Initialize functions
        initial_fcn.init()
        ode_fcn.init()
        alg_fcn.init()
        
        # Manipulate and sort path constraints
        g_e = []
        g_i = []
        path = self.path
        lb = self.ocp.path_min.toArray().reshape(-1)
        ub = self.ocp.path_max.toArray().reshape(-1)
        for i in xrange(path.numel()):
            if lb[i] == ub[i]:
                g_e.append(path[i] - ub[i])
            else:
                if lb[i] != -N.inf:
                    g_i.append(-path[i] + lb[i])
                if ub[i] != N.inf:
                    g_i.append(path[i] - ub[i])
        
        # Create path constraint functions
        path_constraint_input = []
        if self.eliminate_der_var:
            path_constraint_input += [sym_input_elim_der, x_i, der_vals_k, h_i]
        else:
            path_constraint_input.append(sym_input)
        path_constraint_input.append(timed_variables)
        if self.variable_scaling and self.nominal_traj is not None:
            path_constraint_input.append(sym_sf)
        g_e_fcn = casadi.SXFunction(path_constraint_input,
                                    [casadi.vertcat(g_e)])
        g_i_fcn = casadi.SXFunction(path_constraint_input,
                                    [casadi.vertcat(g_i)])
        g_e_fcn.init()
        g_i_fcn.init()
        
        # Create point constraint functions
        G_e = []
        G_i = []
        lb = self.ocp.point_min.toArray().reshape(-1)
        ub = self.ocp.point_max.toArray().reshape(-1)
        for i in xrange(self.point.numel()):
            if lb[i] == ub[i]:
                G_e.append(self.point[i] - ub[i])
            else:
                if lb[i] != -N.inf:
                    G_i.append(-self.point[i] + lb[i])
                if ub[i] != N.inf:
                    G_i.append(self.point[i] - ub[i])
        G_e_fcn = casadi.SXFunction(
                [casadi.vertcat([self.model.p, timed_variables])],
                [casadi.vertcat(G_e)])
        G_i_fcn = casadi.SXFunction([casadi.vertcat(
                [self.model.p, timed_variables])],
                [casadi.vertcat(G_i)])
        G_e_fcn.init()
        G_i_fcn.init()
        
        # Define function evaluation methods based on graph
        if self.graph == 'MX':
            initial_fcn_eval = initial_fcn.call
            ode_fcn_eval = ode_fcn.call
            alg_fcn_eval = alg_fcn.call
            if self.eliminate_der_var:
                ode_fcn_t0_eval = ode_fcn_t0.call
                alg_fcn_t0_eval = alg_fcn_t0.call
            else:
                coll_eq_fcn_eval = coll_eq_fcn.call
            g_e_eval = g_e_fcn.call
            g_i_eval = g_i_fcn.call
            G_e_eval = G_e_fcn.call
            G_i_eval = G_i_fcn.call
            c_e = casadi.MX() 
            c_i = casadi.MX()
        elif self.graph == 'SX':
            initial_fcn_eval = initial_fcn.eval
            ode_fcn_eval = ode_fcn.eval
            alg_fcn_eval = alg_fcn.eval
            if self.eliminate_der_var:
                ode_fcn_t0_eval = ode_fcn_t0.eval
                alg_fcn_t0_eval = alg_fcn_t0.eval
            else:
                coll_eq_fcn_eval = coll_eq_fcn.eval
            g_e_eval = g_e_fcn.eval
            g_i_eval = g_i_fcn.eval
            G_e_eval = G_e_fcn.eval
            G_i_eval = G_i_fcn.eval
            c_e = casadi.SXMatrix()
            c_i = casadi.SXMatrix()
        else:
            raise ValueError('Unknown CasADi graph %s.' % graph)
        
        # Create list of state matrices
        x_list = [[]]
        self.x_list = x_list
        for i in xrange(1, self.n_e + 1):
            x_i = [var_map[i][k]['x'] for k in xrange(self.n_cp + 1)]
            x_i = casadi.horzcat(x_i)
            x_list.append(x_i)
        
        # Index collocation equation scale factors
        if self.variable_scaling and self.nominal_traj is not None:
            coll_sf = {}
            for i in xrange(1, self.n_e + 1):
                coll_sf[i] = {}
                coll_sf[i]['x'] = []
                coll_sf[i]['dx'] = {}
                for k in xrange(1, self.n_cp + 1):
                    coll_sf[i]['dx'][k] = []
            for var in var_vectors['x']:
                x_vr = var.getValueReference()
                dx_name = convert_casadi_der_name(str(var.der()))
                dx_vr = self.model.xmldoc.get_value_reference(dx_name)
                
                x_sf_index = vr_sf_map[x_vr]
                dx_sf_index = vr_sf_map[dx_vr]
                
                # States
                if is_variant[x_vr]:
                    # First element
                    i = 1
                    coll_sf[i]['x'].append(variant_sf[i][0][x_sf_index])
                    for k in xrange(1, self.n_cp + 1):
                        coll_sf[i]['x'].append(
                                variant_sf[i][k][x_sf_index])
                    
                    # Suceeding elements
                    for i in xrange(2, self.n_e + 1):
                        k = self.n_cp + self.is_gauss
                        coll_sf[i]['x'].append(variant_sf[i-1][k][x_sf_index])
                        for k in xrange(1, self.n_cp + 1):
                            coll_sf[i]['x'].append(
                                    variant_sf[i][k][x_sf_index])
                
                # State derivatives
                if is_variant[dx_vr]:
                    for i in xrange(1, self.n_e + 1):
                        for k in xrange(1, self.n_cp + 1):
                            coll_sf[i]['dx'][k].append(
                                    variant_sf[i][k][dx_sf_index])
        
        # Initial conditions
        i = 1
        k = 0
        fcn_input = [self._get_z(i, k)]
        if self.variable_scaling and self.nominal_traj is not None:
            fcn_input.append(variant_sf[i][k])
        [initial_constr] = initial_fcn_eval(fcn_input)
        c_e.append(initial_constr)
        if self.eliminate_der_var:
            [ode_t0_constr] = ode_fcn_t0_eval(fcn_input)
            [alg_t0_constr] = alg_fcn_t0_eval(fcn_input)
        else:
            [ode_t0_constr] = ode_fcn_eval(fcn_input)
            [alg_t0_constr] = alg_fcn_eval(fcn_input)
        c_e.append(ode_t0_constr)
        c_e.append(alg_t0_constr)
        
        if self.blocking_factors is None:
            # Evaluate u_1_0 based on polynomial u_1
            u_1_0 = 0
            for k in xrange(1, self.n_cp + 1):
                u_1_0 += (var_map[1][k]['unelim_u'] *
                          self.pol.eval_basis(k, 0, False))
                
            # Add residual for u_1_0 as constraint
            c_e.append(var_map[1][0]['unelim_u'] - u_1_0)
        
        # Collocation and DAE constraints
        for i in xrange(1, self.n_e + 1):
            for k in xrange(1, self.n_cp + 1):
                # Create function inputs
                if self.eliminate_der_var:
                    z = self._get_z_elim_der(i, k)
                    fcn_input = [z, x_list[i], der_vals[k],
                                 self.horizon * self.h[i]]
                else:
                    z = self._get_z(i, k)
                    fcn_input = [z]
                    coll_input = [x_list[i], der_vals[k],
                                  self.horizon * self.h[i],
                                  var_map[i][k]['dx']]
                if self.variable_scaling and self.nominal_traj is not None:
                    fcn_input.append(variant_sf[i][k])
                    if self.eliminate_der_var:
                        fcn_input.append(coll_sf[i]['x'])
                    else:
                        coll_input.append(coll_sf[i]['x'])
                        coll_input.append(coll_sf[i]['dx'][k])
                
                # Evaluate collocation constraints
                if not self.eliminate_der_var:
                    [coll_constr] = coll_eq_fcn_eval(coll_input)
                    c_e.append(coll_constr)
                
                # Evaluate DAE constraints
                [ode_constr] = ode_fcn_eval(fcn_input)
                [alg_constr] = alg_fcn_eval(fcn_input)
                c_e.append(ode_constr)
                c_e.append(alg_constr)
        
        # Continuity constraints for x_{i, n_cp + 1}
        if self.is_gauss:
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        x_i_np1 += self.pol.w[k] * var_map[i][k]['dx']
                    x_i_np1 = (var_map[i][0]['x'] + 
                               self.horizon * self.h[i] * x_i_np1)
                    
                    # Add residual for x_i_np1 as constraint
                    c_e.append(var_map[i][self.n_cp + 1]['x'] - x_i_np1)
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_np1 += var_map[i][k]['x'] * self.pol.eval_basis(
                            k, 1, True)
                    
                    # Add residual for x_i_np1 as constraint
                    c_e.append(var_map[i][self.n_cp + 1]['x'] - x_i_np1)
        
        # Constraints for terminal values
        if self.is_gauss:
            for var_type in ['unelim_u', 'w']:
                # Evaluate xx_{n_e, n_cp + 1} based on polynomial xx_{n_e}
                xx_ne_np1 = 0
                for k in xrange(1, self.n_cp + 1):
                    xx_ne_np1 += (var_map[self.n_e][k][var_type] *
                                  self.pol.eval_basis(k, 1, False))
                
                # Add residual for xx_ne_np1 as constraint
                c_e.append(var_map[self.n_e][self.n_cp + 1][var_type] -
                           xx_ne_np1)
            if not self.eliminate_der_var:
                # Evaluate dx_{n_e, n_cp + 1} based on polynomial x_{n_e}
                dx_ne_np1 = 0
                for k in xrange(self.n_cp + 1):
                    x_ne_k = var_map[self.n_e][k]['x']
                    dx_ne_np1 += (1. / (self.horizon * self.h[self.n_e]) *
                                  x_ne_k * self.pol.eval_basis_der(k, 1))
                
                # Add residual for dx_ne_np1 as constraint
                c_e.append(var_map[self.n_e][self.n_cp + 1]['dx'] - dx_ne_np1)
        
        # Continuity constraints for x_{i, 0}
        if not self.eliminate_cont_var:
            for i in xrange(1, self.n_e):
                cont_constr = (var_map[i][self.n_cp + self.is_gauss]['x'] - 
                               var_map[i + 1][0]['x'])
                c_e.append(cont_constr)
        
        # Element length constraints
        if self.hs == "free":
            h_constr = casadi.sumRows(self.h[1:]) - 1
            c_e.append(h_constr)
        
        # Path constraints
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                fcn_input = []
                if self.eliminate_der_var:
                    z = self._get_z_elim_der(i, k)
                    fcn_input += [z, x_list[i], der_vals[k],
                                  self.horizon * self.h[i]]
                else:
                    z = self._get_z(i, k)
                    fcn_input.append(z)
                fcn_input.append(nlp_timed_variables)
                if self.variable_scaling and self.nominal_traj is not None:
                    fcn_input.append(variant_sf[i][k])
                [g_e_constr] = g_e_eval(fcn_input)
                [g_i_constr] = g_i_eval(fcn_input)
                c_e.append(g_e_constr)
                c_i.append(g_i_constr)
        
        # Point constraints
        [G_e_constr] = G_e_eval([casadi.vertcat(
                [var_map['p_opt'], nlp_timed_variables])])
        [G_i_constr] = G_i_eval([casadi.vertcat(
                [var_map['p_opt'], nlp_timed_variables])])
        c_e.append(G_e_constr)
        c_i.append(G_i_constr)
        
        # Equality constraints for constrained inputs
        if self.measurement_data is not None:
            if self.variable_scaling and self.nominal_traj is None:
                sfs = self._sf
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    for j in xrange(len(self.measurement_data.constrained)):
                        # Retrieve variable and value
                        var_name = self.measurement_data.constrained.keys()[j]
                        vr = self.model.xmldoc.get_value_reference(var_name)
                        (ind, vt) = vr_map[vr]
                        constr_var = self.var_map[i][k]['unelim_u'][ind]
                        constr_val = self.var_map[i][k]['constr_u'][j]
                        
                        # Scale variable
                        if self.variable_scaling:
                            if self.nominal_traj is None:
                                sf = sfs[vt][ind]
                                constr_var *= sf
                            else:
                                sf_index = vr_sf_map[vr]
                                if is_variant[vr]:
                                    sf = variant_sf[i][k][sf_index]
                                    constr_var *= sf
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    constr_var = d * constr_var + e
                        
                        # Add constraint
                        c_e.append(constr_var - constr_val)
        
        # Store constraints and time as data attributes
        self.c_e = c_e
        if self.graph == 'MX':
            if c_i.isNull():
                self.c_i = casadi.MX(0, 1)
            else:
                self.c_i = c_i
        else:
            self.c_i = c_i
        self.time = N.array(time)
        
    def _create_cost(self):
        """
        Define the cost.
        """
        # Retrieve collocation variables
        if self.eliminate_der_var:
            x_i = self._collocation['x_i']
            der_vals_k = self._collocation['der_vals_k']
            h_i = self._collocation['h_i']
            coll_der = self._collocation['coll_der']
        
        # Retrieve time-variant scale factors
        if self.variable_scaling and self.nominal_traj is not None:
            variant_sf = self._variant_sf
        
        # Calculate cost
        self.cost_mayer = 0
        self.cost_lagrange = 0
        
        # Mayer term
        if self.mterm.numel() > 0:
            # Get terminal values
            if self.discr == "LGR":
                z = self._get_z_elim_der(self.n_e, self.n_cp)
            elif self.discr == "LG":
                z = self._get_z_elim_der(self.n_e, self.n_cp + 1)
            else:
                raise ValueError("Unknown discretization scheme %s." %
                                 self.discr)
            
            # Create function for evaluation of Mayer term
            tf = self.ocp.variable('finalTime').getStart()
            mterm_inputs = casadi.SXMatrix(self.model.t)
            mterm_inputs.append(casadi.SXMatrix(
                    [x.atTime(tf, True) for
                     x in self._var_vectors['x']]))
            mterm_inputs.append(casadi.SXMatrix(
                    [u.atTime(tf, True) for
                     u in self._var_vectors['unelim_u']]))
            mterm_inputs.append(casadi.SXMatrix(
                    [w.atTime(tf, True) for
                     w in self._var_vectors['w']]))
            mterm_inputs.append(self.model.p)
            mterm_inputs.append(casadi.SXMatrix(
                    [u.atTime(tf, True) for
                     u in self._var_vectors['elim_u']]))
            mterm_fcn = casadi.SXFunction([mterm_inputs], [self.mterm])
            mterm_fcn.init()
            
            # Use appropriate function evaluation based on graph
            if self.graph == "MX":
                [self.cost_mayer] = mterm_fcn.call([z])
            elif self.graph == "SX":
                [self.cost_mayer] = mterm_fcn.eval([z])
            else:
                raise ValueError("Unknown CasADi graph %s." %
                                 self.graph)
        
        # Lagrange term
        if self.lterm.numel() > 0:
            # Create function for evaluation of Lagrange integrand
            if self.eliminate_der_var:
                fcn_input = [self._sym_input_elim_der, x_i, der_vals_k,
                             h_i]
            else:
                fcn_input = [self._sym_input]
            if self.variable_scaling and self.nominal_traj is not None:
                fcn_input.append(self._sym_sf)
            
            lterm_fcn = casadi.SXFunction(fcn_input, [self.lterm])
            lterm_fcn.init()
                
            # Define function evaluation method based on graph
            if self.graph == "MX":
                lterm_fcn_eval = lterm_fcn.call
            elif self.graph == "SX":
                lterm_fcn_eval = lterm_fcn.eval
            else:
                raise ValueError("Unknown CasADi graph %s." % self.graph)
            
            # Get start and final time
            t0_var = self.ocp.variable('startTime')
            tf_var = self.ocp.variable('finalTime')
            if t0_var.getFree():
                vr = t0_var.getValueReference()
                (ind, _) = self._vr_map[vr]
                t0 = self.var_map['p_opt'][ind]
            else:
                t0 = t0_var.getStart()
            if tf_var.getFree():
                vr = tf_var.getValueReference()
                (ind, _) = self._vr_map[vr]
                tf = self.var_map['p_opt'][ind]
            else:
                tf = tf_var.getStart()

            # Evaluate Lagrange cost
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    if self.eliminate_der_var:
                        z = self._get_z_elim_der(i, k)
                        fcn_input = [z, self.x_list[i], self.der_vals[k],
                                     self.horizon * self.h[i]]
                    else:
                        fcn_input = [self._get_z(i, k)]
                    if self.variable_scaling and self.nominal_traj is not None:
                        fcn_input.append(variant_sf[i][k])
                    [lterm_val] = lterm_fcn_eval(fcn_input)
                    self.cost_lagrange += ((tf - t0) * self.h[i] *
                                           lterm_val * self.pol.w[k])
        
        # Sum up the two cost terms
        self.cost = self.cost_mayer + self.cost_lagrange
        
        # Add quadratic cost for measurement data
        if (self.measurement_data is not None and
            (len(self.measurement_data.unconstrained) +
             len(self.measurement_data.constrained) > 0)):
            # Retrieve scaling factors
            if self.variable_scaling and self.nominal_traj is not None:
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                vr_sf_map = self._vr_sf_map
            
            # Create nested dictionary for storage of errors and calculate
            # reference values
            err = {}
            y_ref = {}
            datas = (self.measurement_data.constrained.values() +
                     self.measurement_data.unconstrained.values())
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
            vr_map = self._vr_map
            if self.variable_scaling and self.nominal_traj is None:
                sfs = self._sf
            var_names = (self.measurement_data.constrained.keys() +
                         self.measurement_data.unconstrained.keys())
            for j in xrange(len(var_names)):
                var_name = var_names[j]
                vr = self.model.xmldoc.get_value_reference(var_name)
                (ind, vt) = vr_map[vr]
                for i in range(1, self.n_e + 1):
                    for k in range(1, self.n_cp + 1):
                        val = self.var_map[i][k][vt][ind]
                        ref_val = y_ref[i][k][j]
                        if self.variable_scaling:
                            if self.nominal_traj is None:
                                sf = sfs[vt][ind]
                                err[i][k].append(sf * val - ref_val)
                            else:
                                sf_index = vr_sf_map[vr]
                                if is_variant[vr]:
                                    sf = variant_sf[i][k][sf_index]
                                    err[i][k].append(sf * val - ref_val)
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    err[i][k].append(d * val + e - ref_val)
                        else:
                            err[i][k].append(val - ref_val)
            
            # Calculate cost contribution from each collocation point
            Q = self.measurement_data.Q
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
                            casadi.mul(self.var_map[i][k]['dx'].T, Q),
                            self.var_map[i][k]['dx'])
                    length_cost += (h_i ** (1 + a) * integrand * self.pol.w[k])
            self.cost += c * length_cost
    
    def _compute_bounds_and_init(self):
        """
        Compute bounds and intial guesses for NLP variables.
        """
        # Create lower and upper bounds
        xx_lb = self.LOWER * N.ones(self.get_n_xx())
        xx_ub = self.UPPER * N.ones(self.get_n_xx())
        xx_init = N.zeros(self.get_n_xx())
        
        # Retrieve model data
        var_indices = self.get_var_indices()
        ocp = self.ocp
        var_types = ['x', 'unelim_u', 'w', 'p_opt']
        vr_map = self._vr_map
        var_vectors = self._var_vectors
        time_points = self.get_time_points()
        if self.variable_scaling:
            if self.nominal_traj is None:
                sfs = self._sf
            else:
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
                is_variant = self._is_variant
                vr_sf_map = self._vr_sf_map
        
        # Handle free parameters
        p_max = N.empty(self.model.get_n_p())
        p_min = copy.deepcopy(p_max)
        p_init = copy.deepcopy(p_max)
        for var in var_vectors["p_opt"]:
            vr = var.getValueReference()
            (var_index, _) = vr_map[vr]
            if self.variable_scaling:
                if self.nominal_traj is None:
                    sf = sfs["p_opt"][var_index]
                else:
                    sf_index = vr_sf_map[vr]
                    sf = invariant_d[sf_index]
            else:
                sf = 1
            p_min[var_index] = var.getMin() / sf
            p_max[var_index] = var.getMax() / sf
            
            # Handle initial guess
            var_init = var.getInitialGuess()
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
        xx_lb[var_indices['p_opt']] = p_min
        xx_ub[var_indices['p_opt']] = p_max
        xx_init[var_indices['p_opt']] = p_init
        
        # Manipulate initial trajectories
        if self.init_traj is not None:
            n = len(self.init_traj.get_data_matrix()[:, 0])
            traj = {}
            traj["dx"] = {}
            for vt in var_vectors.keys():
                traj[vt] = {}
                for var in var_vectors[vt]:
                    data_matrix = N.empty([n, len(var_vectors[vt])])
                    (var_index, _) = vr_map[var.getValueReference()]
                    name = var.getName()
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
                            ordinates = N.array([[var.getInitialGuess()]])
                            abscissae = N.array([0])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        traj[vt][var_index] = \
                                TrajectoryLinearInterpolation(abscissae, ordinates)
                    
                    # Treat derivatives separately
                    if vt == "x":
                        name = convert_casadi_der_name(str(var.der()))
                        vr = self.model.xmldoc.get_value_reference(name)
                        data_matrix = N.empty([n, len(var_vectors[vt])])
                        (var_index, _) = vr_map[vr]
                        try:
                            data = self.init_traj.get_variable_data(name)
                        except VariableNotFoundError:
                            print("Warning: Could not find initial " + \
                                  "trajectory for variable " + name + ". " + 
                                  "Using 0 as initial guess instead.")
                            abscissae = N.array([0])
                            ordinates = N.array([[0]])
                        else:
                            abscissae = data.t
                            ordinates = data.x.reshape([-1, 1])
                        traj["dx"][var_index] = \
                                TrajectoryLinearInterpolation(abscissae,
                                                              ordinates)
        
        # Denormalize time for minimum time problems
        if self._normalize_min_time:
            t0 = self._denorm_t0_init
            tf = self._denorm_tf_init
        
        # Set bounds and initial guesses
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                time = time_points[i][k]
                if self._normalize_min_time:
                    time = t0 + (tf - t0) * time
                for vt in ['x', 'unelim_u', 'w']:
                    var_min = N.empty(len(var_vectors[vt]))
                    var_max = N.empty(len(var_vectors[vt]))
                    var_init = N.empty(len(var_vectors[vt]))
                    if (not self.eliminate_der_var and vt == "x"):
                        var_init_der = N.empty(len(var_vectors[vt]))
                    for var in var_vectors[vt]:
                        vr = var.getValueReference()
                        (var_index, _) = vr_map[vr]
                        d = 1.
                        e = 0.
                        if self.variable_scaling:
                            if self.nominal_traj is None:
                                d = sfs[vt][var_index]
                            else:
                                sf_index = vr_sf_map[vr]
                                if is_variant[vr]:
                                    d = variant_sf[i][k][sf_index]
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                        var_min[var_index] = (var.getMin() - e) / d
                        var_max[var_index] = (var.getMax() - e) / d
                        if self.init_traj is None:
                            var_initial = var.getInitialGuess()
                        else:
                            var_initial = traj[vt][var_index].eval(time)
                        var_init[var_index] = (var_initial - e) / d
                        
                        # Treat derivatives separately
                        if (not self.eliminate_der_var and vt == "x"):
                            name = convert_casadi_der_name(str(var.der()))
                            vr = self.model.xmldoc.get_value_reference(name)
                            (var_index, _) = vr_map[vr]
                            d = 1.
                            e = 0.
                            if self.variable_scaling:
                                if self.nominal_traj is None:
                                    d = sfs["dx"][var_index]
                                else:
                                    sf_index = vr_sf_map[vr]
                                    if is_variant[vr]:
                                        d = variant_sf[i][k][sf_index]
                                    else:
                                        d = invariant_d[sf_index]
                                        e = invariant_e[sf_index]
                            if self.init_traj is None:
                                var_initial = 0.
                            else:
                                var_initial = traj["dx"][var_index].eval(time)
                            var_init_der[var_index] = (var_initial - e) / d
                    
                    xx_lb[var_indices[i][k][vt]] = var_min
                    xx_ub[var_indices[i][k][vt]] = var_max
                    xx_init[var_indices[i][k][vt]] = var_init
                    if (not self.eliminate_der_var and vt == "x"):
                        xx_init[var_indices[i][k]["dx"]] = var_init_der
        
        # Set bounds and initial guesses for continuity variables
        if not self.eliminate_cont_var:
            vt = 'x'
            k = self.n_cp + self.is_gauss
            for i in xrange(2, self.n_e + 1):
                xx_lb[var_indices[i][0][vt]] = xx_lb[var_indices[i - 1][k][vt]]
                xx_ub[var_indices[i][0][vt]] = xx_ub[var_indices[i - 1][k][vt]]
                xx_init[var_indices[i][0][vt]] = \
                        xx_init[var_indices[i - 1][k][vt]]
        
        # Compute bounds and initial guesses for element lengths
        if self.hs == "free":
            h_0 = 1. / self.n_e
            h_bounds = self.free_element_lengths_data.bounds
            var_indices = self.get_var_indices()
            for i in xrange(1, self.n_e + 1):
                xx_lb[var_indices['h'][i]] = h_bounds[0] * h_0
                xx_ub[var_indices['h'][i]] = h_bounds[1] * h_0
                xx_init[var_indices['h'][i]] = h_bounds[1] * h_0
        
        # Store bounds and initial guesses
        self.xx_lb = xx_lb
        self.xx_ub = xx_ub
        self.xx_init = xx_init
    
    def _create_solver(self):
        # Concatenate constraints
        constraints = casadi.vertcat([self.get_equality_constraint(),
                                      self.get_inequality_constraint()])
        
        # Define NLP function based on graph
        if self.graph == "MX":
            nlp = casadi.MXFunction(casadi.nlpIn(x=self.xx),
                                    casadi.nlpOut(f=self.cost, g=constraints))
        elif self.graph == "SX":
            nlp = casadi.SXFunction(casadi.nlpIn(x=self.xx),
                                    casadi.nlpOut(f=self.cost, g=constraints))
        else:
            raise ValueError("Unknown CasADi graph %s." % graph)
        
        # Create solver object        
        self.solver = casadi.IpoptSolver(nlp)
    
    def get_equality_constraint(self):
        return self.c_e
    
    def get_inequality_constraint(self):
        return self.c_i
    
    def get_cost(self):
        return self.cost_fcn
    
    def get_result(self):
        # Set model info
        n_var = copy.copy(self._n_var)
        n_var['elim_u'] = self._model_elim_u.numel()
        cont = {'dx': False, 'x': True, 'unelim_u': False, 'w': False}
        var_vectors = self._var_vectors
        var_types = ['x', 'unelim_u', 'w']
        if not self.eliminate_der_var:
            var_types = ['dx'] + var_types
        vr_map = self._vr_map
        var_map = self.var_map
        var_opt = {}
        var_indices = self.get_var_indices()
        if self.variable_scaling:
            if self.nominal_traj is None:
                sf = self._sf
            else:
                vr_sf_map = self._vr_sf_map
                is_variant = self._is_variant
                variant_sf = self._variant_sf
                invariant_d = self._invariant_d
                invariant_e = self._invariant_e
        
        # Get copy of solution
        primal_opt = copy.copy(self.primal_opt)
        
        # Get element lengths
        if self.hs == "free":
            self.h_opt = N.hstack([N.nan, primal_opt[var_indices['h'][1:]]])
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
            t_opt = []
            t_start = 0.
            for i in xrange(1, self.n_e + 1):
                t_end = t_start + h_scaled[i]
                t_i = N.linspace(t_start, t_end, self.n_eval_points)
                t_opt = N.hstack([t_opt, t_i])
                t_start = t_opt[-1]
            t_opt = t_opt.reshape([-1, 1])
        else:
            raise ValueError("Unknown result mode %s." % self.result_mode)
        
        # Create arrays for storage of variable trajectories
        for var_type in var_types + ['elim_u']:
            var_opt[var_type] = N.empty([len(t_opt), n_var[var_type]])
        var_opt['merged_u'] = N.empty([len(t_opt),
                                       n_var['unelim_u'] + n_var['elim_u']])
        if self.eliminate_der_var:
            var_opt['dx'] = N.empty([len(t_opt), n_var['x']])
        var_opt['p_opt'] = N.empty(self.model.get_n_p())
        
        # Get optimal parameter values and rescale
        p_opt = primal_opt[self.get_var_indices()['p_opt']].reshape(-1)
        if self.variable_scaling and not self.write_scaled_result:
            if self.nominal_traj is None:
                p_opt *= sf['p_opt']
            else:
                p_opt_sf = N.empty(self.model.get_n_p())
                for var in self.ocp.pf:
                    vr = var.getValueReference()
                    (ind, _) = vr_map[vr]
                    sf_index = vr_sf_map[vr]
                    p_opt_sf[ind] = invariant_d[sf_index]
                p_opt *= p_opt_sf
        var_opt['p_opt'][:] = p_opt
        
        # Rescale solution
        time_points = self.get_time_points()
        if self.variable_scaling and not self.write_scaled_result:
            t_index = 0
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in ['x', 'unelim_u', 'w']:
                        for var in var_vectors[var_type]:
                            vr = var.getValueReference()
                            (ind, _) = vr_map[vr]
                            global_ind = var_indices[i][k][var_type][ind]
                            xx_i_k = primal_opt[global_ind]
                            if self.nominal_traj is None:
                                xx_i_k *= sf[var_type][ind]
                            else:
                                sf_index = self._vr_sf_map[vr]
                                if self._is_variant[vr]:
                                    xx_i_k *= variant_sf[i][k][sf_index]
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    xx_i_k = d * xx_i_k + e
                            primal_opt[global_ind] = xx_i_k
                    
                    # Treat state derivatives separately
                    if not self.eliminate_der_var:
                        dx_names = self.model.xmldoc.get_dx_variable_names(
                                False)
                        name_dict = dict((x[0], x[1]) for x in dx_names)
                        for vr in sorted(name_dict):
                            (ind, _) = vr_map[vr]
                            global_ind = var_indices[i][k]["dx"][ind]
                            xx_i_k = primal_opt[global_ind]
                            if self.nominal_traj is None:
                                xx_i_k *= sf["dx"][ind]
                            else:
                                sf_index = self._vr_sf_map[vr]
                                if self._is_variant[vr]:
                                    xx_i_k = xx_i_k*variant_sf[i][k][sf_index]
                                else:
                                    d = invariant_d[sf_index]
                                    e = invariant_e[sf_index]
                                    xx_i_k = d * xx_i_k + e
                            primal_opt[global_ind] = xx_i_k
                        t_index += 1
        
        # Rescale continuity variables
        if (self.variable_scaling and not self.eliminate_cont_var and
            not self.write_scaled_result):
            for i in xrange(1, self.n_e):
                k = self.n_cp + self.is_gauss
                x_i_k = primal_opt[var_indices[i][k]['x']]
                primal_opt[var_indices[i + 1][0]['x']] = x_i_k
        if (self.is_gauss and self.variable_scaling and 
            not self.eliminate_cont_var and not self.write_scaled_result):
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = primal_opt[var_indices[i][k]['dx']]
                        x_i_np1 += self.pol.w[k] * dx_i_k
                    x_i_np1 = (primal_opt[var_indices[i][0]['x']] + 
                               self.horizon * self.h[i] * x_i_np1)
                    
                    # Rescale x_{i, n_cp + 1}
                    primal_opt[var_indices[i][self.n_cp + 1]['x']] = x_i_np1
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[var_indices[i][k]['x']]
                        x_i_np1 += x_i_k * self.pol.eval_basis(k, 1, True)
                    
                    # Rescale x_{i, n_cp + 1}
                    primal_opt[var_indices[i][self.n_cp + 1]['x']] = x_i_np1
        
        # Get solution trajectories
        t_index = 0
        if self.result_mode == "collocation_points":
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        xx_i_k = primal_opt[var_indices[i][k][var_type]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    var_opt['elim_u'][t_index, :] = var_map[i][k]['elim_u']
                    t_index += 1
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[var_indices[i][k]['dx']]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1
                
                # Collocation point derivatives
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = 0
                        for l in xrange(self.n_cp + 1):
                            x_i_l = primal_opt[var_indices[i][l]['x']]
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
                            xx_i_k = primal_opt[var_indices[i][k][var_type]]
                            xx_i_tau += xx_i_k * self.pol.eval_basis(
                                    k, tau, cont[var_type])
                        var_opt[var_type][t_index, :] = xx_i_tau.reshape(-1)
                    
                    # eliminated inputs
                    xx_i_tau = 0
                    for k in xrange(not cont[var_type], self.n_cp + 1):
                        xx_i_k = var_map[i][k]['elim_u']
                        xx_i_tau += xx_i_k * self.pol.eval_basis(
                                k, tau, cont[var_type])
                    var_opt['elim_u'][t_index, :] = xx_i_tau.reshape(-1)
                    
                    # Derivatives
                    dx_i_tau = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[var_indices[i][k]['x']]
                        dx_i_tau += (1. / h_scaled[i] * x_i_k * 
                                     self.pol.eval_basis_der(k, tau))
                    var_opt['dx'][t_index, :] = dx_i_tau.reshape(-1)
                    
                    t_index += 1
        elif self.result_mode == "mesh_points":
            # Start time
            i = 1
            k = 0
            for var_type in var_types:
                xx_i_k = primal_opt[var_indices[i][k][var_type]]
                var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
            var_opt['elim_u'][t_index, :] = var_map[i][k]['elim_u']
            t_index += 1
            k = self.n_cp + self.is_gauss
            
            # Mesh points
            var_types.remove('x')
            if self.discr == "LGR":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        xx_i_k = primal_opt[var_indices[i][k][var_type]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    u_i_k = var_map[i][k]['elim_u']
                    var_opt[var_type][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            elif self.discr == "LG":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        # Evaluate xx_{i, n_cp + 1} based on polynomial xx_i
                        xx_i_k = 0
                        for l in xrange(1, self.n_cp + 1):
                            xx_i_l = primal_opt[var_indices[i][l][var_type]]
                            xx_i_k += xx_i_l * self.pol.eval_basis(l, 1, False)
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    # Evaluate u_{i, n_cp + 1} based on polynomial u_i
                    u_i_k = 0
                    for l in xrange(1, self.n_cp + 1):
                        u_i_l = var_map[i][l]['elim_u']
                        u_i_k += u_i_l * self.pol.eval_basis(l, 1, False)
                    var_opt['elim_u'][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            var_types.insert(0, 'x')
            
            # Handle states separately
            t_index = 1
            for i in xrange(1, self.n_e + 1):
                x_i_k = primal_opt[var_indices[i][k]['x']]
                var_opt['x'][t_index, :] = x_i_k.reshape(-1)
                t_index += 1
            
            # Handle state derivatives separately
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[var_indices[i][k]['dx']]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1
                
                # Mesh point state derivatives
                t_index = 1
                for i in xrange(1, self.n_e + 1):
                    dx_i_k = 0
                    for l in xrange(self.n_cp + 1):
                        x_i_l = primal_opt[var_indices[i][l]['x']]
                        dx_i_k += (1. / h_scaled[i] * x_i_l * 
                                   self.pol.eval_basis_der(l, 1.))
                    var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                    t_index += 1
        else:
            raise ValueError("Unknown result mode %s." % self.result_mode)
        
        # Merge uneliminated and eliminated inputs
        if self.model.get_n_u() > 0:
            var_opt['merged_u'][:, self._unelim_input_indices] = \
                    var_opt['unelim_u']
            var_opt['merged_u'][:, self._elim_input_indices] = \
                    var_opt['elim_u']
        
        # Store optimal inputs for interpolator purposes
        if self.result_mode == "collocation_points":
            u_opt = var_opt['merged_u']
        else:
            t_index = 0
            u_opt = N.empty([self.n_e * self.n_cp + 1, self.model.get_n_u()])
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    unelim_u_i_k = primal_opt[var_indices[i][k]['unelim_u']]
                    u_opt[t_index, self._unelim_input_indices] = \
                        unelim_u_i_k.reshape(-1)
                    elim_u_i_k = self.var_map[i][k]['elim_u']
                    u_opt[t_index, self._elim_input_indices] = \
                        elim_u_i_k.reshape(-1)
                    t_index += 1
        self._u_opt = u_opt
        
        # Denormalize minimum time problem
        if self._normalize_min_time:
            t0_var = self.ocp.variable('startTime')
            tf_var = self.ocp.variable('finalTime')
            if t0_var.getFree():
                vr = t0_var.getValueReference()
                (ind, _) = vr_map[vr]
                t0 = var_opt['p_opt'][ind]
            else:
                t0 = t0_var.getStart()
            if tf_var.getFree():
                vr = tf_var.getValueReference()
                (ind, _) = vr_map[vr]
                tf = var_opt['p_opt'][ind]
            else:
                tf = tf_var.getStart()
            t_opt = t0 + (tf - t0) * t_opt
            var_opt['dx'] /= (tf - t0)

        # Return results
        return (t_opt, var_opt['dx'], var_opt['x'], var_opt['merged_u'],
                var_opt['w'], var_opt['p_opt'])
    
    def get_h_opt(self):
        if self.hs == "free":
            return self.h_opt
        else:
            return None

class PseudoSpectral(CasadiCollocator):
    
    """
    This class discretize and solves optimization problem of the general kind,
    
    .. math::
    
        min J = \Phi (x(t_0),t_0, x(t_f),t_f;q) + \int_{t_0}^{t_f} \Theta (x(t),u(t),t;q)dt
        
    subject to the dynamics,
    
    .. math::
    
        \dot{x} = f(x,u,t;q)
        
    and the constraints,
    
    .. math::
    
        \phi_{min} \leq \phi (x(t_0),t_0,x(t_f),t_f;q) \leq \phi_{max}
    
        C_{min} \leq C(x(t),u(t),t;q) \leq C_{max}.
    
    This class gives the option to discretize the optimization problem and 
    perform the collocation at three different set of points, Legendre-Gauss 
    (LG), Legendre-Gauss-Radau (LGR) and Legendre-Gauss-Lobatto (LGL). The 
    points are calculated from the roots of different variations and/or 
    combinations of Legendre polynomials. For LG, the collocation points are 
    calculated as the roots of :math:`P_N(x)`. For LGR, roots of 
    :math:`P_N(x)-P_{N-1}(x)`. For LGL, roots of 
    :math:`(1-x^2) \cdot P_{N-1}'(x)`. Here, :math:`P_N(x)` is a Legendre 
    polynomial of degree :math:`N`.
    
    The points all lie in/on the interval :math:`(-1,1)`. A
    transformation of the optimization interval to the interval :math:`(-1,1)`
    is performed as (still allowing free start and/or final time),
    
    .. math::
    
        t = \\frac{t_f-t_0}{2} \\tau + \\frac{t_f-t_0}{2}.
        
    The state(s) and control(s) are approximated with Lagrange polynomials. For 
    LG and LGR points the state(s) are approximated with :math:`N+1` polynomials
    and for LGL points, :math:`N` polynomials. In all cases the control(s) is 
    approximated using :math:`N` Lagrange polynomials. Example (LG), 
    
    .. math::
    
        x(\\tau) \\approx X(\\tau) = \sum_{i=0}^N X(\\tau _i) L_i(\\tau) ,\quad
        u(\\tau) \\approx U(\\tau) = \sum_{i=1}^N U(\\tau _i) L_i(\\tau). 
    
    Differentiation of the state(s) approximation gives the approximation for
    the state(s) derivatives,
    
    .. math::
    
        \dot{x}(\\tau) \\approx \\frac{dX(\\tau)}{d\\tau} =  
        \sum_{i=0}^N X(\\tau _i) \\frac{dL_i(\\tau)}{d\\tau}, \quad D=\dot{L}.
    
    This implementation gives the options to use either discretization as a
    global collocation method, i.e. the number of phases (elements) are set to
    one or to use it as a local method, number of phases are greater than one. 
    If the number of phases are greater than one, the phases needs to be linked
    together as,
    
    .. math::
    
        x_N^p = x_0^{p+1} + dx^{p+1}
        
    where :math:`x_N^p` is the end point in the :math:`p` phase, 
    :math:`x_0^{p+1}` is the start point in the :math:`p+1` phase and 
    :math:`dx^{p+1}` can be specified to allow discontinuous changes in the 
    state(s). :math:`dx^{p+1}` defaults to zero.
    
    Using the above described method leads to, for each phase (LG),
    
    .. math::
        
        \sum_{i=0}^N D_{ki}X_i - \\frac{t_f-t_0}{2}f(X_k,U_k,\\tau_k;q) = 0, 
        \quad k=1,...,N \quad \\text{(Eq. 1)}
        
        X_{N+1} - X_0 - \sum_{i=0}^N \sum_{k=1}^N \omega_k D_{ki}X_i = 0 \quad 
        \\text{(Eq. 2)}
        
        \phi_{min} \leq \phi (X_0,t_0,X_{N+1},t_f;q) \leq \phi_{max} \quad 
        \\text{(Eq. 3)}
    
        C_{min} \leq C(X_k,U_k,\\tau_k;q) \leq C_{max}, \quad k=1,...,N \quad 
        \\text{(Eq. 4)}
    
    together with,
    
    .. math::
    
        x_{N+1}^p = x_0^{p+1} + dx^{p+1}, \quad p=1,...,P-1
    
        J = \Phi (X_0^1,t_0^1, X_{N+1}^P,t_f^P;q) + \sum_{p=1}^P 
        \\frac{t_f^p-t_0^p}{2} \sum_{k=1}^N \omega_k \Theta (X_k^p,U_k^p,
        \\tau_k^p;q)
    
    gives our NLP which is solved using IPOPT. The changes needed when using 
    LGR points is that the final point is instead :math:`X_N`, because the final
    point is included in the collocation. This removes the need for Equation 2. 
    For LGL points, both the start and final time is included in the collocation 
    so that the start point is :math:`X_1` and the final point :math:`X_N`. This 
    also removes the need for Equation 2.
    
    .. warning::
    
        Path constraints are currently not supported, as is not optimization 
        problems with free start or final time. However, variable bounds are 
        supported.
    
    .. note::
    
        In the result file, the control(s) at the end points for the LG points
        have been extrapolated from the approximated Lagrange polynomials. For
        the LGR points, the start points for the controls have been extrapolated
        in the same way.
        
        The same procedure have been performed for the state derivative(s) in the
        case for LG and LGR points.
    
    .. note::
        
        A reference of an implementation of Gauss-Pseudospectral method can be
        found in, `Algorithm 902: GPOPS, A MATLAB software for solving 
        multiple-phase optimal control problems using the gauss pseudospectral 
        method <http://portal.acm.org/citation.cfm?doid=1731022.1731032>`_. 
        
        Other references include,
        
            - `A unified framework for the numerical solution of optimal control
              problems using pseudospectral methods. 
              <http://portal.acm.org/citation.cfm?id=1872787>`_
        
            - `A Gauss pseudospectral transcription for optimal control. 
              <http://dspace.mit.edu/handle/1721.1/28919>`_
            
            - `Advancement and analysis of Gauss pseudospectral transcription 
              for optimal control problems. 
              <http://dspace.mit.edu/handle/1721.1/42180>`_
    """
    
    def __init__(self, model, options):
        super(PseudoSpectral, self).__init__(model)
        
        # Check normalization of minimum time problems
        t0 = self.ocp.variable('startTime')
        tf = self.ocp.variable('finalTime')
        if (t0.getFree() and not self.ocp.t0_free or
            tf.getFree() and not self.ocp.tf_free):
            raise CasadiCollocatorException(
                    "Problems with free start or final time must be " +
                    'compiled with the compiler option "normalize_minimum_' +
                    'time_problems" disabled.')
        
        #Make problem explicit
        model._convert_to_ode()
        
        self.options = options
        self.md  = model.get_model_description()
        
        #Create the necessary vectors for a corresponding set of points
        if options['discr'] == "LG":
            self._Collocation    = range(1,options['n_cp']+1)
            self._Discretization = range(0,options['n_cp']+2)
            self._Approximation  = range(0,options['n_cp']+1)
            self._Weights    = gauss_quadrature_weights("LG", options['n_cp'])
            self._DiffMatrix = differentiation_matrix("Gauss", options['n_cp'])
            self._Roots      = legendre_Pn_roots(options['n_cp'])
            self._ApproximationRoots = N.append(-1.0, self._Roots)
            self._WeightsTDiffMatrix = N.dot(self._Weights, self._DiffMatrix).flatten()
            self._WeightsTDiffMatrix[0] = N.array(0.0)#Using analytical results for W*D
        elif options['discr'] == "LGR":
            self._Collocation    = range(1,options['n_cp']+1)
            self._Discretization = range(0,options['n_cp']+1)
            self._Approximation  = range(0,options['n_cp']+1)
            self._Weights    = gauss_quadrature_weights("LGR", options['n_cp'])
            self._DiffMatrix = differentiation_matrix("Radau", options['n_cp'])
            self._Roots      = N.append(jacobi_a1_b0_roots(options['n_cp']-1), 1.0)
            self._ApproximationRoots = N.append(-1.0, self._Roots)
            #self._WeightsTDiffMatrix = N.dot(self._Weights, self._DiffMatrix).flatten()
            self._WeightsTDiffMatrix     = N.zeros(options['n_cp']+1)#Using analytical results for W*D
            self._WeightsTDiffMatrix[0]  = N.array(-1.0)
            self._WeightsTDiffMatrix[-1] = N.array(1.0)
        elif options['discr'] == "LGL":
            self._Collocation    = range(0,options['n_cp'])
            self._Discretization = range(0,options['n_cp'])
            self._Approximation  = range(0,options['n_cp'])
            self._Weights    = gauss_quadrature_weights("LGL", options['n_cp'])
            self._DiffMatrix = differentiation_matrix("Legendre", options['n_cp'])
            self._Roots      = N.append(N.append(-1.0, legendre_dPn_roots(options['n_cp']-1)), 1.0)
            self._ApproximationRoots = self._Roots
            #self._WeightsTDiffMatrix = N.dot(self._Weights, self._DiffMatrix).flatten()
            self._WeightsTDiffMatrix     = N.zeros(options['n_cp']) #Using analytical results for W*D
            self._WeightsTDiffMatrix[0]  = N.array(-1.0)
            self._WeightsTDiffMatrix[-1] = N.array(1.0)
        else:
            raise Exception("Unknown discretization option. Valid options: LG,LGL,LGR")
            
        self._Phases   = range(1,options['n_e']+1)
        
        self._create_nlp_variables()
        self._create_collocation_constraints()
        self._create_bolza_functional()
        
        # Compute bounds
        self._compute_bounds_and_init()
        
        # Get constraints
        c_e = self.get_equality_constraint()
        c_i = self.get_inequality_constraint()
        c = casadi.vertcat([c_e, c_i])
        
        # Create constraint function
        self.c_fcn = casadi.SXFunction([casadi.vertcat(self.get_xx())], [c])
        self.c_fcn.setOption("name", "NLP constraint function")
        self.c_fcn.init()
        
        # Create solver
        self.solver = casadi.IpoptSolver(self.get_cost(), self.c_fcn)
        
        self._modify_init()
    
    def _modify_init(self):
        PHASE = self._Phases
        DISCR = self._Discretization
        
        xx_init = self.get_xx_init()
        xx_lb = self.get_xx_lb()
        xx_ub = self.get_xx_ub()
        
        #Handle free final time
        if self.md.get_opt_finaltime_free():
            val_ref = self.md.get_value_reference("finalTime")
            init = self.md.get_p_opt_initial_guess()
            lb   = self.md.get_p_opt_min()
            ub   = self.md.get_p_opt_max()
            for i,p in enumerate(init):
                if p[0] == val_ref:
                    xx_init[self.get_var_indices()[PHASE[-1]][DISCR[-1]]['t']] = init[i][1] if init[i][1] != None else N.array(0.0)
                    xx_lb[self.get_var_indices()[PHASE[-1]][DISCR[-1]]['t']] = lb[i][1] if lb[i][1] != None else N.array(-1e20)
                    xx_ub[self.get_var_indices()[PHASE[-1]][DISCR[-1]]['t']] = ub[i][1] if ub[i][1] != None else N.array(1e20)
        
        #Handle free start time
        if self.md.get_opt_starttime_free():
            val_ref = self.md.get_value_reference("startTime")
            init = self.md.get_p_opt_initial_guess()
            lb   = self.md.get_p_opt_min()
            ub   = self.md.get_p_opt_max()
            for i,p in enumerate(init):
                if p[0] == val_ref:
                    xx_init[self.get_var_indices()[0][DISCR[0]]['t']] = init[i][1] if init[i][1] != None else N.array(0.0)
                    xx_lb[self.get_var_indices()[0][DISCR[0]]['t']] = lb[i][1] if lb[i][1] != None else N.array(-1e20)
                    xx_ub[self.get_var_indices()[0][DISCR[0]]['t']] = ub[i][1] if ub[i][1] != None else N.array(1e20)
        
        #Handle free phases
        if self.options['free_phases'] and len(PHASE) > 1 and not self.options['phase_options']:
            #if self.options['phase_bounds'] != None:
            #    for i,x in enumerate(self.options['phase_bounds']):
            #        xx_init[self.get_var_indices()[i+1][DISCR[-1]]['t']]=x[0]
            #        xx_lb[self.get_var_indices()[i+1][DISCR[-1]]['t']] = x[1]
            #        xx_ub[self.get_var_indices()[i+1][DISCR[-1]]['t']] = x[2]
            #else:
            for i in PHASE[:-1]:
                xx_init[self.get_var_indices()[i][DISCR[-1]]['t']] = i*(self.tf-self.t0)/len(PHASE)
                xx_lb[self.get_var_indices()[i][DISCR[-1]]['t']] = N.array(-1e20)
                xx_ub[self.get_var_indices()[i][DISCR[-1]]['t']] = N.array(1e20)
        
        #Handle links
        """
        if self.options['link_options'] != []:
            for j,x in enumerate(self.options['link_bounds']):
                for i in PHASE[:-1]:
                    xx_init[self.get_var_indices()[i][0]['link_x'][j]]=x[0]
                    xx_lb[self.get_var_indices()[i][0]['link_x'][j]] = x[1]
                    xx_ub[self.get_var_indices()[i][0]['link_x'][j]] = x[2]
        """
        
    def _create_collocation_constraints(self):
        
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        APPRO = self._Approximation
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        WTD   = self._WeightsTDiffMatrix
        
        self.h = [] #Equality constraints
        self.g = [] #Inequality constraints
        self.time_points = []
        
        #Create initial constraints
        t = self.vars[0]['t']
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += [t]
        [init_constr] = self.model.get_ode_F0().eval([casadi.vertcat(z)])
        init_constr = list(init_constr.data())
        self.h += init_constr
        
        #Create collocation constraints
        for i in PHASE:
            if DISCR[0] != COLLO[0]:
                self.time_points += [(self.vars[i-1]['t'],i,DISCR[0])]
            for ind,j in enumerate(COLLO):
                dx = []
                for k in range(self.model.get_n_x()):
                    dx += [sum([DIFFM[ind,l]*self.vars[i][l]['x'][k] for l in APPRO])]
                    
                t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                z = []
                z += self.vars[0]['p']
                z += self.vars[i][j]['x']
                z += self.vars[i][j]['u']
                z += [t]
                [Fz] = self.model.get_ode_F().eval([casadi.vertcat(z)])
                dynamic_constr = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*Fz
                dynamic_constr = list(dynamic_constr.data())
                for k in range(self.model.get_n_x()):
                    self.h += [dx[k] - dynamic_constr[k]]

                self.time_points += [(t,i,j)]
            if DISCR[-1] != COLLO[-1]:
                self.time_points += [(self.vars[i]['t'],i,DISCR[-1])]
        """
        #Create linking constraints
        for i in PHASE[:-1]:
            z = []
            #u = []
            for x in range(self.model.get_n_x()):
                z += [self.vars[i][DISCR[-1]]['x'][x] - self.vars[i+1][DISCR[0]]['x'][x] + self.vars[i]['link_x'][x]]
            #for x in range(self.model.get_n_u()):
            #    u += [sum([lagrange_eval(ROOTS,ind,1.0)*self.vars[i][l]['u'][x] for ind,l in enumerate(COLLO)])-sum([lagrange_eval(ROOTS,ind,-1.0)*self.vars[i+1][l]['u'][x] for ind,l in enumerate(COLLO)])]
            #self.h += u    
            self.h += z
        """
        self.linkning_constraints = []
        #Create linkning constraints
        for i in PHASE[:-1]:
            z = []
            for x in range(self.model.get_n_x()):
                z += [self.vars[i][DISCR[-1]]['x'][x] - self.vars[i+1][DISCR[0]]['x'][x]]
            self.linkning_constraints += z
            
        for opt in self.link:
            i = opt[0] #Phase
            x_ind = opt[1] #Variable
            p_ind = opt[2] #Parameter
            z = self.vars[i][DISCR[-1]]['x'][x_ind] - self.vars[i+1][DISCR[0]]['x'][x_ind] + self.vars[0]['p'][p_ind]
            self.linkning_constraints[(i-1)*self.model.get_n_x()+x_ind] = z
        self.h += self.linkning_constraints
        
        #Create constraints on the final x (Linear Equation)
        if self.options["discr"]=="LG":
            final_constr = []
            for j in PHASE:
                for x in range(self.model.get_n_x()):
                    temp = []
                    for i in APPRO:
                        #for ind,k in enumerate(COLLO):
                        #    temp += [WEIGH[ind]*DIFFM[ind,i]*self.vars[j][i]['x'][x]]
                        temp += [WTD[i]*self.vars[j][i]['x'][x]]
                    final_constr += [self.vars[j][DISCR[-1]]['x'][x] - self.vars[j][DISCR[0]]['x'][x] - sum(temp)]
            self.h += final_constr
        #Create constraints on the final x (NonLinear Equation)
        
        """
        final_constr = []
        for i in PHASE:
            dynamic_constr = []
            for ind,j in enumerate(COLLO):
                t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                z = []
                z += self.vars[0]['p']
                z += self.vars[i][j]['x']
                z += self.vars[i][j]['u']
                z += [t]
                dynamic_constr += list((self.vars[i]['t']-self.vars[i-1]['t'])*0.5*float(WEIGH[ind])*self.model.get_ode_F().eval([z])[0])
            sums = []
            for j in range(self.model.get_n_x()):
                sums += [-1.0*sum(dynamic_constr[j::self.model.get_n_x()])]
            for j in range(self.model.get_n_x()):
                final_constr += [self.vars[i][DISCR[-1]]['x'][j] - self.vars[i][DISCR[0]]['x'][j] + sums[j]]
        self.h += final_constr
        """

        #Create boundary constraints (equality)
        boundary_constr = []
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += self.vars[PHASE[-1]][DISCR[-1]]['x']
        [boundary_constr] = self.model.opt_ode_C.eval([casadi.vertcat(z)])
        boundary_constr = list(boundary_constr.data())
        self.h += boundary_constr
        
        #Create boundary constraints (inequality)
        boundary_constr_ineq = []
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += self.vars[PHASE[-1]][DISCR[-1]]['x']
        [boundary_constr_ineq] = self.model.opt_ode_Cineq.eval(
                [casadi.vertcat(z)])
        boundary_constr_ineq = list(boundary_constr_ineq.data())
        self.g += boundary_constr_ineq
        
        #Create inequality constraint
        if self.options['free_phases']:
            for i in PHASE:
                self.g += [self.vars[i-1]['t']-self.vars[i]['t']]
    
    def _create_bolza_functional(self):
        
        PHASE = self._Phases
        APPRO = self._Approximation
        COLLO = self._Collocation
        DISCR = self._Discretization
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        
        # Generate cost function
        self.cost_mayer = 0
        self.cost_lagrange = 0
        
        if self.model.mterm.numel() > 0:
            # Assume Mayer cost
            z = []
            t = self.vars[PHASE[-1]]['t']
            z += self.vars[0]['p']
            z += self.vars[PHASE[-1]][DISCR[-1]]['x']
            z += [t]
            [self.cost_mayer] = self.model.get_opt_ode_J().eval(
                    [casadi.vertcat(z)])
            #self.cost_mayer = list(self.cost_mayer.data())
        #NOTE TEMPORARY!!!!
        #self.cost_mayer=self.vars[PHASE[-1]]['t']
        # Take care of Lagrange cost
        if self.model.lterm.numel() > 0:
            for i in PHASE:
                for ind,j in enumerate(COLLO):
                    t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                    z = []
                    z += self.vars[0]['p']
                    z += self.vars[i][j]['x']
                    z += self.vars[i][j]['u']
                    z += [t]
                    self.cost_lagrange += (self.vars[i]['t']-self.vars[i-1]['t'])/2.0*self.model.get_opt_ode_L().eval([casadi.vertcat(z)])[0][0]*WEIGH[ind]
          
        self.cost = self.cost_mayer + self.cost_lagrange

        # Objective function
        self.cost_fcn = casadi.SXFunction([casadi.vertcat(self.xx)], [self.cost])  
        
        # Hessian
        self.sigma = casadi.ssym('sigma')
        
        self.lam = []
        self.Lag = self.sigma*self.cost
        for i in range(len(self.h)):
            self.lam.append(casadi.ssym('lambda_' + str(i)))
            self.Lag = self.Lag + self.h[i]*self.lam[i]
        for i in range(len(self.g)):
            self.lam.append(casadi.ssym('lambda_' + str(i+len(self.h))))
            self.Lag = self.Lag + self.g[i]*self.lam[i+len(self.h)]
            
        self.Lag_fcn = casadi.SXFunction(
                [casadi.vertcat(self.xx), casadi.vertcat(self.lam),
                 self.sigma], [self.Lag])
        self.Lag_fcn.init()
        #self.H_fcn = None
        self.H_fcn = self.Lag_fcn.hessian(0,0)
    
    def _create_nlp_variables(self):
        
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        
        # Group variables into elements
        self.vars = {}
        # Extended vars
        self.ext_vars = {}
        
        t0 = self.t0
        tf = self.tf
        
        if self.md.get_opt_finaltime_free():
            tf = casadi.ssym("tf")
        if self.md.get_opt_starttime_free():
            t0 = casadi.ssym("t0")
        
        self.vars[0] = {}
        for i in PHASE: #Phases
            for j in DISCR: #Discretization
                xi = [casadi.ssym(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_x()]
                if j==0:
                    self.vars[i] = {}
                self.vars[i][j] = {}
                self.vars[i][j]['x'] = xi
                    
            for j in COLLO: #Collocation
                ui = [casadi.ssym(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_u()]
                self.vars[i][j]['u'] = ui
        
        
        pi = [casadi.ssym(str(x)) for x in self.model.get_p()]
        self.vars[0]['p'] = pi
        
        
        for i in PHASE[:-1]:
            if self.options['free_phases']:
                if self.options['phase_options']:
                    for ind, p in enumerate(self.model.get_p()):
                        if self.options['phase_options'][i-1] == str(p):    
                            self.vars[i]['t'] = self.vars[0]['p'][ind]
                            break
                    else:
                        raise CasadiCollocatorException("Could not find the parameter for the phase bound.")
                else:
                    self.vars[i]['t'] = casadi.ssym("t"+str(i))
            else:
                self.vars[i]['t'] = i*(tf-t0)/len(PHASE)

        self.vars[PHASE[-1]]['t'] = tf
        self.vars[0]['t']         = t0
        
        # Group variables indices in the global
        # variable vector
        self.var_indices = {0:{0:{}}}
        self.xx = []
        
        for i in PHASE: #Phases
            self.var_indices[i] = {}
            
            for j in DISCR: #Discretization
                self.var_indices[i][j] = {}
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['x']
                self.var_indices[i][j]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
                
            for j in COLLO: #Collocation
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['u']
                self.var_indices[i][j]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        pre_len = len(self.xx)
        self.xx += self.vars[0]['p']
        self.var_indices[0][0]['p'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        if self.md.get_opt_finaltime_free(): #Handle free finaltime
            pre_len = len(self.xx)
            self.xx += [self.vars[PHASE[-1]]['t']]
            self.var_indices[PHASE[-1]][DISCR[-1]]['t'] = N.arange(pre_len,len(self.xx),dtype=int)
        if self.md.get_opt_starttime_free(): #Handle free starttime
            pre_len = len(self.xx)
            self.xx += [self.vars[0]['t']]
            self.var_indices[0][0]['t'] = N.arange(pre_len,len(self.xx),dtype=int)
        if self.options['free_phases'] and len(PHASE) > 1: #Handle free phases
            for i in PHASE[:-1]:
                if self.options['phase_options']:
                    for ind, p in enumerate(self.model.get_p()):
                        if self.options['phase_options'][i-1] == str(p):
                            self.var_indices[i][DISCR[-1]]['t'] = self.var_indices[0][0]['p'][ind]
                            break
                else:
                    pre_len = len(self.xx)
                    self.xx += [self.vars[i]['t']]
                    self.var_indices[i][DISCR[-1]]['t'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        
        self.link = [] 
        for all in self.options['link_options']:
            xlink = -1
            plink = -1
            for ind, x in enumerate(self.model.get_x()):
                if all[1] == str(x):
                    xlink = ind
                    break
            for ind, p in enumerate(self.model.get_p()):
                if all[2] == str(p):
                    plink = ind
                    break
            
            if xlink == -1:
                raise CasadiCollocatorException("Could not find the linking variable, ",all[1], ".")
            if plink == -1:
                raise CasadiCollocatorException("Could not find the linking parameter, ",all[2], ".")
            self.link += [(all[0],xlink,plink)]
        
        """
        #Create vector allowing or disallowing discontinuous state
        for i in PHASE[:-1]: #Phases
            self.vars[i]['link_x'] = [casadi.SX(0.0) for x in self.model.get_x()]
            links = []
            for j in self.options['link_options']:
                for l,k in enumerate(self.model.get_x()):
                    if j[0] == str(k):
                        self.vars[i]['link_x'][l] = casadi.SX('link_'+str(k)+'_'+str(i))
                        links += [self.vars[i]['link_x'][l]]
            pre_len = len(self.xx)
            #self.xx += [self.vars[i]['link_x'][l]]
            self.xx += links
            self.var_indices[i][0]['link_x'] = N.arange(pre_len,len(self.xx),dtype=int)
        """
        
        self.n_xx = len(self.xx)
    
    def get_equality_constraint(self):
        return casadi.vertcat(self.h)
    
    def get_inequality_constraint(self):
        return casadi.vertcat(self.g)

    def get_cost(self):
        return self.cost_fcn

    def get_hessian(self):
        return self.H_fcn
    
    def _compute_bounds_and_init(self):
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        APPRO = self._Approximation
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        
        # Create lower and upper bounds
        nlp_lb = self.LOWER*N.ones(len(self.get_xx()))
        nlp_ub = self.UPPER*N.ones(len(self.get_xx()))
        nlp_init = N.zeros(len(self.get_xx()))
        
        md = self.get_model_description()
        ocp = self.ocp
        
        _x_max = md.get_x_max(include_alias = False)
        _u_max = md.get_u_max(include_alias = False)
        _p_max = [(p.getValueReference(), p.getMax()) for p in ocp.pf]
        _x_min = md.get_x_min(include_alias = False)
        _u_min = md.get_u_min(include_alias = False)
        _p_min = [(p.getValueReference(), p.getMin()) for p in ocp.pf]
        _x_start = md.get_x_initial_guess(include_alias = False)
        #_u_start = md.get_u_start(include_alias = False)
        _u_start = md.get_u_initial_guess(include_alias = False)
        _p_start = []
        for p in ocp.pf: #NOTE SHOULD BE CHANGED
            for p_ori in md.get_p_opt_initial_guess():
                if p.getValueReference() == p_ori[0]:
                    _p_start += [p_ori] 
        #_p_start = [(p.getValueReference(), p.getStart()) for p in ocp.p_]
        
        # Remove startTime and finalTime from parameters, should be changed
        i = 0
        for p in ocp.pf:
            if p.getName() == 'startTime' or p.getName() == 'finalTime':
                del _p_max[i]
                del _p_min[i]
                del _p_start[i]
            i += 1
        
        x_max = self.UPPER*N.ones(len(_x_max))
        u_max = self.UPPER*N.ones(len(_u_max))
        p_max = self.UPPER*N.ones(len(_p_max))
        x_min = self.LOWER*N.ones(len(_x_min))
        u_min = self.LOWER*N.ones(len(_u_min))
        p_min = self.LOWER*N.ones(len(_p_min))
        x_start = self.LOWER*N.ones(len(_x_start))
        u_start = self.LOWER*N.ones(len(_u_start))
        p_start = self.LOWER*N.ones(len(_p_start))
        
        #~ for vr, val in _x_min:
            #~ if val != None:
                #~ x_min[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        #~ for vr, val in _x_max:
            #~ if val != None:
                #~ x_max[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        #~ for vr, val in _x_start:
            #~ if val != None:
                #~ x_start[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        #~ 
        #~ for vr, val in _u_min:
            #~ if val != None:
                #~ u_min[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        #~ for vr, val in _u_max:
            #~ if val != None:
                #~ u_max[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        #~ for vr, val in _u_start:
            #~ if val != None:
                #~ u_start[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        #~ 
        #~ for vr, val in _p_min:
            #~ if val != None:
                #~ p_min[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        #~ for vr, val in _p_max:
            #~ if val != None:
                #~ p_max[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        #~ for vr, val in _p_start:
            #~ if val != None:
                #~ p_start[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        
        vr_map = self.model.get_vr_map()
        for vr, val in _x_min:
            if val != None:
                x_min[vr_map[vr][0]] = val
        for vr, val in _x_max:
            if val != None:
                x_max[vr_map[vr][0]] = val
        for vr, val in _x_start:
            if val != None:
                x_start[vr_map[vr][0]] = val

        for vr, val in _u_min:
            if val != None:
                u_min[vr_map[vr][0]] = val
        for vr, val in _u_max:
            if val != None:
                u_max[vr_map[vr][0]] = val
        for vr, val in _u_start:
            if val != None:
                u_start[vr_map[vr][0]] = val
        
        for vr, val in _p_min:
            if val != None:
                p_min[vr_map[vr][0]] = val
        for vr, val in _p_max:
            if val != None:
                p_max[vr_map[vr][0]] = val
        for vr, val in _p_start:
            if val != None:
                p_start[vr_map[vr][0]] = val
        
        for t,i,j in self.get_time_points():
            nlp_lb[self.get_var_indices()[i][j]['x']] = x_min
            nlp_ub[self.get_var_indices()[i][j]['x']] = x_max
            nlp_init[self.get_var_indices()[i][j]['x']] = x_start
            if j==0 and DISCR[0] != COLLO[0]:
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                continue
            nlp_lb[self.get_var_indices()[i][j]['u']] = u_min
            nlp_ub[self.get_var_indices()[i][j]['u']] = u_max
            nlp_init[self.get_var_indices()[i][j]['u']] = u_start
        
        #Add the parameters options
        nlp_lb[self.get_var_indices()[0][0]['p']] = p_min
        nlp_ub[self.get_var_indices()[0][0]['p']] = p_max
        nlp_init[self.get_var_indices()[0][0]['p']] = p_start

        self.xx_lb = nlp_lb
        self.xx_ub = nlp_ub
        self.xx_init = nlp_init

        return (nlp_lb,nlp_ub,nlp_init)
    
    def get_result(self):
        
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        APPRO = self._Approximation
        AROOT = self._ApproximationRoots
        
        dx_opt = N.zeros((len(PHASE)*len(DISCR), self.model.get_n_x()))
        x_opt  = N.zeros((len(PHASE)*len(DISCR), self.model.get_n_x()))
        u_opt  = N.zeros((len(PHASE)*len(DISCR), self.model.get_n_u()))
        w_opt  = N.zeros((len(PHASE)*len(DISCR), 0))
        t_opt  = N.zeros(len(self.get_time_points()))
        p_opt  = N.zeros(self.model.get_n_p())
        
        ts = [i[0] for i in self.get_time_points()]
        self.primal_opt = self.primal_opt.reshape([-1, 1])

        if (self.options['free_phases'] and len(PHASE) > 1) and self.md.get_opt_finaltime_free():
            input_t = [self.vars[i]['t'] for i in PHASE]
            tfcn = casadi.SXFunction([casadi.vertcat(input_t)],[casadi.vertcat(ts)])
            tfcn.init()
            input_res = [self.primal_opt[self.var_indices[i][DISCR[-1]]['t']][0] for i in PHASE]
            tfcn.setInput(N.array(input_res).flatten())
        elif (self.options['free_phases'] and len(PHASE) > 1):
            input_t = [self.vars[i]['t'] for i in PHASE[:-1]]
            tfcn = casadi.SXFunction([casadi.vertcat(input_t)],[casadi.vertcat(ts)])
            tfcn.init()
            input_res = [self.primal_opt[self.var_indices[i][DISCR[-1]]['t']][0] for i in PHASE[:-1]]
            tfcn.setInput(N.array(input_res).flatten())
        elif self.md.get_opt_finaltime_free():
            input_t = self.vars[PHASE[-1]]['t']
            tfcn = casadi.SXFunction([[input_t]],[ts])
            tfcn.init()
            tfcn.setInput(self.primal_opt[self.var_indices[PHASE[-1]][DISCR[-1]]['t']])
        else:
            tfcn = casadi.SXFunction([[]],[ts])
            tfcn.init()
            
        tfcn.evaluate()
        t = N.transpose(N.array([tfcn.output().data()]))
        t_opt = t.flatten()
        
        cnt = 0
        for time,i,j in self.get_time_points():
            #t_opt[cnt] = t
            x_opt[cnt,:]  = self.primal_opt[self.get_var_indices()[i][j]['x']][:,0]
            
            if j==0 and DISCR[0] != COLLO[0]:
                u_opt[cnt,:] = [sum([lagrange_eval(ROOTS,ind,-1.0)*self.primal_opt[self.get_var_indices()[i][l]['u']][k,0] for ind,l in enumerate(COLLO)]) for k in range(self.model.get_n_u())]
                dx_coeff = [lagrange_derivative_eval(AROOT,ind,-1.0) for ind in range(len(APPRO))]
                dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([dx_coeff[ind]*self.primal_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                #dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([lagrange_derivative_eval(AROOT,ind,-1.0)*self.primal_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                cnt = cnt + 1
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                u_opt[cnt,:] = [sum([lagrange_eval(ROOTS,ind,1.0)*self.primal_opt[self.get_var_indices()[i][l]['u']][k,0] for ind,l in enumerate(COLLO)]) for k in range(self.model.get_n_u())]
                dx_coeff = [lagrange_derivative_eval(AROOT,ind,1.0) for ind in range(len(APPRO))]
                dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([dx_coeff[ind]*self.primal_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                #dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([lagrange_derivative_eval(AROOT,ind,1.0)*self.primal_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                cnt = cnt + 1
                continue
            
            u_opt[cnt,:]  = self.primal_opt[self.get_var_indices()[i][j]['u']][:,0]
            dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([DIFFM[j-COLLO[0],l]*self.primal_opt[self.get_var_indices()[i][l]['x']][k,0] for l in APPRO]) for k in range(self.model.get_n_x())]
            cnt = cnt + 1
            
        p_opt[:] = self.primal_opt[self.get_var_indices()[0][0]['p']][:,0]

        return (t,dx_opt,x_opt,u_opt,w_opt,p_opt)
        
    def set_initial_from_file(self,res):
        """ 
        Initialize the optimization vector from an object of either 
        ResultDymolaTextual or ResultDymolaBinary.

        Parameters::
        
            res --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary.
        """
        names = self.md.get_x_variable_names(include_alias=False)
        x_names=[]
        for name in sorted(names):
            x_names.append(name[1])

        names = self.md.get_u_variable_names(include_alias=False)
        u_names=[]
        for name in sorted(names):
            u_names.append(name[1])
            
        names = self.md.get_p_opt_variable_names(include_alias=False)
        p_opt_names=[]
        for name in sorted(names):
            if name == "finalTime" or name == "startTime":
                continue
            p_opt_names.append(name[1])
        
        # Obtain vector sizes
        n_points = 0
        num_name_hits = 0
        if len(x_names) > 0:
            for name in x_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(u_names) > 0:
            for name in u_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass
        else:
            raise Exception(
                "None of the model variables not found in result file.")

        if num_name_hits==0:
            raise Exception(
                "None of the model variables not found in result file.")

        n_points = N.size(traj.t,0)
        n_cols = 1+len(x_names)+len(u_names)

        var_data = N.zeros((n_points,n_cols))
        # Initialize time vector
        var_data[:,0] = res.get_variable_data('time').t

        # If a normalized minimum time problem has been solved,
        # then, the time vector should be rescaled
        #n=[names[1] for names in self.md.get_p_opt_variable_names()]
        #non_fixed_interval = ('finalTime' in n) or ('startTime' in n)            

        #dx_factor = 1.0
        """
        if non_fixed_interval:
            # A minimum time problem has been solved,
            # interval is normalized to [-1,1]
            t0 = self.t0
            tf = self.tf
            dx_factor = tf-t0
            for i in range(N.size(var_data,0)):
                var_data[i,0] = 2.0*var_data[i,0]/(tf-t0)-(tf+t0)/(tf-t0)
                #var_data[i,0] = -t0/(tf-t0) + var_data[i,0]/(tf-t0)
        """
        
        p_opt_data = N.zeros(len(p_opt_names))
        # Get the parameters
        n_p_opt = len(p_opt_names)
        if n_p_opt > 0:
            for i,name in enumerate(p_opt_names):
                try:
                    #ref = self.md.get_value_reference(name)
                    #(z_i, ptype) = jmi._translate_value_ref(ref)
                    #i_pi = z_i - self._model._offs_real_pi.value
                    #i_pi_opt = p_opt_indices.index(i_pi)
                    traj = res.get_variable_data(name)
                    #if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                    #    p_opt_data[i_pi_opt] = traj.x[0]/sc[z_i]
                    #else:
                    p_opt_data[i] = traj.x[0]
                except VariableNotFoundError:
                    print "Warning: Could not find value for parameter " + name
        
        # Initialize variable names
        # Loop over all the names

        # sc_x = self.model.get_x_sf()
        # sc_u = self.model.get_u_sf()

        col_index = 1;
        x_index = 0;
        u_index = 0;
        for name in x_names:
            try:
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x #/sc_x[x_index]
                x_index = x_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                x_index = x_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for state variable " + name
        for name in u_names:
            try:
                traj = res.get_variable_data(name)
                if not res.is_variable(name):
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0] # /sc_u[u_index]
                else:
                    var_data[:,col_index] = traj.x # /sc_u[u_index]
                u_index = u_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                u_index = u_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for input variable " + name
                
        self.var_data = var_data
        self.par_data = p_opt_data 
        
        self._set_initial_from_file(var_data,p_opt_data)
        
    def _set_initial_from_file(self, var_data, par_data):
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        APPRO = self._Approximation
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        
        ts = [i[0] for i in self.get_time_points()]

        if (self.options['free_phases'] and len(PHASE) > 1) and self.md.get_opt_finaltime_free():
            input_t = [self.vars[i]['t'] for i in PHASE]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.xx_init[self.var_indices[i][DISCR[-1]]['t']] for i in PHASE]
            tfcn.setInput(N.array(input_res).flatten())
        elif (self.options['free_phases'] and len(PHASE) > 1):
            input_t = [self.vars[i]['t'] for i in PHASE[:-1]]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.xx_init[self.var_indices[i][DISCR[-1]]['t']] for i in PHASE[:-1]]
            tfcn.setInput(N.array(input_res).flatten())
        elif self.md.get_opt_finaltime_free():
            input_t = self.vars[PHASE[-1]]['t']
            tfcn = casadi.SXFunction([[input_t]],[ts])
            tfcn.init()
            tfcn.setInput(self.xx_init[self.var_indices[PHASE[-1]][DISCR[-1]]['t']])
        else:
            tfcn = casadi.SXFunction([[]],[ts])
            tfcn.init()
            
        tfcn.evaluate()
        t = N.transpose(N.array(tfcn.output()))
        t_opt = t.flatten()
        
        xx_init = self.get_xx_init()

        x_init = N.zeros((len(t_opt), self.model.get_n_x()))
        u_init = N.zeros((len(t_opt)-len(DISCR)+len(COLLO), self.model.get_n_u()))
        
        for i in range(self.model.get_n_x()):
            x_init[:,i] = N.interp(t_opt, var_data[:,0], var_data[:,i+1]).transpose()
        for i in range(self.model.get_n_u()):
            if DISCR[0] != COLLO[0]:
                start = 1
            else:
                start = 0
            if DISCR[-1] != COLLO[-1]:
                end = -1
            else:
                end = len(t_opt)
            u_init[:,i] = N.interp(t_opt[start:end], var_data[:,0], var_data[:,1+self.model.get_n_x()+i]).transpose()
        
        cnt_x = 0
        cnt_u = 0
        
        #Add the initials of the states and controls
        for time,i,j in self.get_time_points():
            xx_init[self.get_var_indices()[i][j]['x']] = x_init[cnt_x,:]
            cnt_x += 1
            if j==0 and DISCR[0] != COLLO[0]:
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                continue
            xx_init[self.get_var_indices()[i][j]['u']] = u_init[cnt_u,:]
            cnt_u += 1
        
        #Add the initial of the parameters
        if len(par_data) > 0:
            xx_init[self.get_var_indices()[0][0]['p']] = par_data

        self.xx_init = xx_init
