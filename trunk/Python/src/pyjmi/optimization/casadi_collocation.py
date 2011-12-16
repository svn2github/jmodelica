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
import time
import copy
import types
    
try:
    import casadi
except ImportError:
    logging.warning('Could not find CasADi package, aborting.')
import numpy as N
    
from pyjmi.optimization.polynomial import *
from pyjmi.common import xmlparser
from pyjmi.common.io import VariableNotFoundError
from pyjmi.common.core import TrajectoryLinearInterpolation, TrajectoryUserFunction

class CasADiCollocatorException(Exception):
    """
    A CasADiCollocator Exception.
    """
    pass

class CasADiCollocator(object):
    # Parameters
    #UPPER = 1e20
    #LOWER = -1e20
    UPPER = N.inf
    LOWER = -N.inf
    
    def __init__(self, model):
        # Store model (casadiModel)
        self.model = model
        
        # Compute bounds
        self._compute_bounds_and_init()
        
        # Get constraints
        c_e = self.get_equality_constraint()
        c_i = self.get_inequality_constraint()
        c = casadi.vertcat([c_e, c_i])
        
        # Create constraint function
        self.c_fcn = casadi.SXFunction([self.get_xx()], [c])
        self.c_fcn.setOption("name", "NLP constraint function")
        self.c_fcn.init()
        
        # Create solver
        if self.get_hessian() is None:
            self.solver = casadi.IpoptSolver(self.get_cost(), self.c_fcn)
        else:
            self.solver = casadi.IpoptSolver(self.get_cost(), self.c_fcn,
                                             self.get_hessian())
        
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
        
    def get_constraint_fcn(self):
        """
        Gets the constraint CasADi function.
        """
        return self.c_fcn
        
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
                file_name=self.model.get_name() + '_result.txt'

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
            
            # if some parameters where optimized, store that value.
            for key in self.model.get_p_vr_map().items():
                try:
                    start_values[key[0]] = p_opt[key[1]]
                except KeyError:
                    pass
            # add and calculate the dependent parameters
            for key in self.model.get_pd_val():
                try:
                    start_values[key[1]] = key[2]
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
                    elif aliases[i][1] == 1: # alias
                        f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                    else: # negated alias
                        f.write('1 -%d 0 -1 # ' % cnt_1 + name[1] +'\n')
                else:
                    if aliases[i][1] == 0: # noalias
                        cnt_2 = cnt_2 + 1   
                        f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                    elif aliases[i][1] == 1: # alias
                        f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                    else: #neg alias
                        f.write('2 -%d 0 -1 # ' % cnt_2 + name[1] +'\n')
                
                    
            f.write('\n')

            sc = N.hstack((N.array([1.0]),self.model.get_dx_sf(),self.model.get_x_sf(),self.model.get_u_sf(),self.model.get_w_sf()))
            try:
                rescale = (self.model.enable_scaling and 
                           not self.write_scaled_result)
            except AttributeError:
                rescale = self.model.enable_scaling
            
            # Get objects for parameter rescaling
            p_opt_names = [str(p) for p in self.model.get_p()]
            p_sf = self.model.get_p_sf()
            p_vr_map = self.model.get_p_vr_map()
            
            # Write data
            # Write data set 1
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            f.write("%.14E" % data[0,0])
            str_text = ''
            for i in params:
                if rescale and i[1] in p_opt_names:
                    str_text += " %.14E" % (start_values[i[0]] * 
                                            p_sf[p_vr_map[i[0]]])
                else:
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
                    if ref==0: # Don't scale time
                        str_text = str_text + (" %.14E" % data[i,ref])
                    else:
                        if rescale:
                            str_text = str_text + (" %.14E" % (data[i,ref]*sc[ref]))
                        else:
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

        p_opt[:] = self.nlp_opt[self.get_var_indices()['p_opt']][:, 0]

        cnt = 0
        var_indices = self.get_var_indices()
        for i in xrange(1, self.n_e + 1):
            for k in self.get_time_points()[i]:
                dx_opt[cnt, :] = self.nlp_opt[var_indices[i][k]['dx']][:, 0]
                x_opt[cnt, :] = self.nlp_opt[var_indices[i][k]['x']][:, 0]
                u_opt[cnt, :] = self.nlp_opt[var_indices[i][k]['u']][:, 0]
                w_opt[cnt, :] = self.nlp_opt[var_indices[i][k]['w']][:, 0]
                cnt += 1
        return (t_opt, dx_opt, x_opt, u_opt, w_opt, p_opt)
    
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
        self.solver.setInput(self.get_xx_init(),casadi.NLP_X_INIT)
        
        # Bounds on x
        self.solver.setInput(self.get_xx_lb(),casadi.NLP_LBX)
        self.solver.setInput(self.get_xx_ub(),casadi.NLP_UBX)
        
        # Bounds on the constraints
        n_h = self.get_equality_constraint().numel()
        hublb = n_h * [0]
        n_g = self.get_inequality_constraint().numel()
        gub = n_g * [0]
        glb = n_g * [self.LOWER]
        self.glub = hublb + gub
        self.gllb = hublb + glb
        
        self.solver.setInput(self.gllb,casadi.NLP_LBG)
        self.solver.setInput(self.glub,casadi.NLP_UBG)
        
        """
        print "Optimal control problem: "
        print self.ocp
        
        print "NLP X: ", len(self.get_xx()), self.get_xx()
        print "NLP X UB: ", len(self.get_xx_ub()), self.get_xx_ub()
        print "NLP X LB: ", len(self.get_xx_lb()), self.get_xx_lb()
        
        print "Equality constraints: ", len(h), h
        print "Inequality constraints: ", len(g), g
        
        print "Cost functional: ", self.get_cost()
        """
        # Solve the problem
        t0 = time.clock()
        self.solver.solve()
        
        # Get the result
        self.nlp_opt = N.array(self.solver.output(casadi.NLP_X_OPT))
        sol_time = time.clock() - t0
        return sol_time
    
    def _compute_bounds_and_init(self):
        # Create lower and upper bounds
        nlp_lb = self.LOWER * N.ones(self.get_n_xx())
        nlp_ub = self.UPPER * N.ones(self.get_n_xx())
        nlp_init = N.zeros(self.get_n_xx())
        
        md = self.get_model_description()

        _p_opt_max = md.get_p_opt_max(include_alias = False)
        _dx_max = md.get_dx_max(include_alias = False)
        _x_max = md.get_x_max(include_alias = False)
        _u_max = md.get_u_max(include_alias = False)
        _w_max = md.get_w_max(include_alias = False)
        _p_opt_min = md.get_p_opt_min(include_alias = False)
        _dx_min = md.get_dx_min(include_alias = False)
        _x_min = md.get_x_min(include_alias = False)
        _u_min = md.get_u_min(include_alias = False)
        _w_min = md.get_w_min(include_alias = False)
        _p_opt_start = md.get_p_opt_initial_guess(include_alias = False)
        _dx_start = md.get_dx_initial_guess(include_alias = False)
        _x_start = md.get_x_initial_guess(include_alias = False)
        _u_start = md.get_u_initial_guess(include_alias = False)
        _w_start = md.get_w_initial_guess(include_alias = False)

        p_opt_max = self.UPPER*N.ones(len(_p_opt_max))
        dx_max = self.UPPER*N.ones(len(_dx_max))
        x_max = self.UPPER*N.ones(len(_x_max))
        u_max = self.UPPER*N.ones(len(_u_max))
        w_max = self.UPPER*N.ones(len(_w_max))
        p_opt_min = self.LOWER*N.ones(len(_p_opt_min))
        dx_min = self.LOWER*N.ones(len(_dx_min))
        x_min = self.LOWER*N.ones(len(_x_min))
        u_min = self.LOWER*N.ones(len(_u_min))
        w_min = self.LOWER*N.ones(len(_w_min))
        p_opt_start = self.UPPER*N.ones(len(_p_opt_start))
        dx_start = self.LOWER*N.ones(len(_dx_start))
        x_start = self.LOWER*N.ones(len(_x_start))
        u_start = self.LOWER*N.ones(len(_u_start))
        w_start = self.LOWER*N.ones(len(_w_start))

        for vr, val in _p_opt_min:
            if val != None:
                p_opt_min[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        for vr, val in _p_opt_max:
            if val != None:
                p_opt_max[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        for vr, val in _p_opt_start:
            if val != None:
                p_opt_start[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]

        for vr, val in _dx_min:
            if val != None:
                dx_min[self.model.get_dx_vr_map()[vr]] = val/self.model.get_dx_sf()[self.model.get_dx_vr_map()[vr]]
        for vr, val in _dx_max:
            if val != None:
                dx_max[self.model.get_dx_vr_map()[vr]] = val/self.model.get_dx_sf()[self.model.get_dx_vr_map()[vr]]
        for vr, val in _dx_start:
            if val != None:
                dx_start[self.model.get_dx_vr_map()[vr]] = val/self.model.get_dx_sf()[self.model.get_dx_vr_map()[vr]]

        for vr, val in _x_min:
            if val != None:
                x_min[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_max:
            if val != None:
                x_max[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_start:
            if val != None:
                x_start[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]

        for vr, val in _u_min:
            if val != None:
                u_min[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_max:
            if val != None:
                u_max[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_start:
            if val != None:
                u_start[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]

        for vr, val in _w_min:
            if val != None:
                w_min[self.model.get_w_vr_map()[vr]] = val/self.model.get_w_sf()[self.model.get_w_vr_map()[vr]]
        for vr, val in _w_max:
            if val != None:
                w_max[self.model.get_w_vr_map()[vr]] = val/self.model.get_w_sf()[self.model.get_w_vr_map()[vr]]
        for vr, val in _w_start:
            if val != None:
                w_start[self.model.get_w_vr_map()[vr]] = val/self.model.get_w_sf()[self.model.get_w_vr_map()[vr]]

        nlp_lb[self.get_var_indices()['p_opt']] = p_opt_min
        nlp_ub[self.get_var_indices()['p_opt']] = p_opt_max
        nlp_init[self.get_var_indices()['p_opt']] = p_opt_start
        
        for i in xrange(1, self.n_e + 1):
            for k in self.get_time_points()[i]:
                nlp_lb[self.get_var_indices()[i][k]['dx']] = dx_min
                nlp_ub[self.get_var_indices()[i][k]['dx']] = dx_max
                nlp_init[self.get_var_indices()[i][k]['dx']] = dx_start
                nlp_lb[self.get_var_indices()[i][k]['x']] = x_min
                nlp_ub[self.get_var_indices()[i][k]['x']] = x_max
                nlp_init[self.get_var_indices()[i][k]['x']] = x_start
                nlp_lb[self.get_var_indices()[i][k]['u']] = u_min
                nlp_ub[self.get_var_indices()[i][k]['u']] = u_max
                nlp_init[self.get_var_indices()[i][k]['u']] = u_start
                nlp_lb[self.get_var_indices()[i][k]['w']] = w_min
                nlp_ub[self.get_var_indices()[i][k]['w']] = w_max
                nlp_init[self.get_var_indices()[i][k]['w']] = w_start

        self.xx_lb = nlp_lb
        self.xx_ub = nlp_ub
        self.xx_init = nlp_init

        return (nlp_lb,nlp_ub,nlp_init)

class ParameterEstimationData:
    
    """
    Data used to define the cost function for parameter estimation problems.
    
    Parameters::
    
        Q --
            Weighting matrix.
            
            Type: rank 2 ndarray
        
        measured_variables --
            List of the names of the measured variables.
            
            Type: list of strings
        
        data --
            Object containing the measurement data.
            
            If data is a function, it should take a time point as its argument
            and return an array where element j contains the measured value
            of measured_variables[j] at the given time point.
            
            If data is a matrix,
            data[i][0] should contain measurement point i and
            data[i][j] should contain the measured value of
            measured_variables[j] at measurement point i.
            
            Type: function or rank 2 ndarray
        
        discrete --
            Whether to perform discrete or continuous parameter estimation.
            
            NOTE: Discrete parameter estimation is not yet supported!
            
            Continuous parameter estimation uses the cost function
            
            .. math::
            
                f = \int_{t_0}^{t_f} (y(t) - y_m(t)) \cdot Q \cdot
                (y(t) - y_m(t))\,\mathrm{d}t,
            
            where y is a function created by gluing together the collocation
            polynomials for the measured variables at all the mesh points and
            y_m is a function providing the measured values given time. If the
            parameter data is a matrix, the data is linearly interpolated to
            create the y_m function. If data is a function, then this function
            defines y_m.
            
            Discrete parameter estimation uses the cost function
            
            .. math::
            
                f = \sum_{i = 1}^{n_m} (y(t_i) - y_m(t_i)) \cdot
                Q \cdot y(t_i) - y_m(t_i),
            
            where y is the optimized values of the measured variables and
            y_m is the measured values of the measured variables. This option
            requires the parameter data to be a matrix. It is also required
            that each measurement point coincides with either a collocation
            point or a mesh point.
            
            Type: bool
            Default: False
        
        eps --
            In the case of discrete parameter estimation, the measurement point
            t is considered to coincide with the collocation or mesh point v
            if and only if |t - v| / (t_f - t_0) < eps.
            
            Type: float
            Default: 1e-5
    """

    def __init__(self, Q, measured_variables, data, discrete=False, eps=1e-5):
        self.Q = Q
        self.measured_variables = measured_variables
        self.discrete = discrete
        if isinstance(data, types.FunctionType):
            if discrete:
                raise ValueError("Parameter data must be a matrix if " +
                                 "parameter discrete is True.")
            else:
                self.data = TrajectoryUserFunction(data)
        else:
            if discrete:
                self.data = data
                raise NotImplementedError("Discrete parameter estimation is " +
                                          "not yet supported!")
            else:
                self.data = TrajectoryLinearInterpolation(data[:, 0],
                                                          data[:, 1:])
        self.eps = eps

class FreeElementLengthsData:
    
    """
    Data used to control the element lengths when they are free.
    
    The objective function f is adjusted to penalize large element lengths for
    elements with high state derivatives, resulting in the modified objective
    function \hat{f} defined as follows:
    
    .. math::
        
        \hat{f} = f + c \cdot \sum_{i = 1}^{n_e} \left(h_i^p \cdot 
        \int_{t_i}^{t_{i+1}} \dot{x}^T(t) \cdot Q \cdot
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

class LocalDAECollocator(CasADiCollocator):
    
    """Solves an optimal control problem using local collocation."""
    
    def __init__(self, model, options):
        # Store the model
        self.model = model
        self.ocp = model.get_casadi_ocp()
        
        # Get the options
        self.__dict__.update(options)
        
        # Define element lengths
        self.horizon = self.ocp.tf - self.ocp.t0
        if self.hs != "free":
            self.h = [N.nan] # Element 0
            if self.hs is None:
                self.h += self.n_e * [1. / self.n_e]
            else:
                self.h += self.hs
        
        # Define polynomial for representation of solutions
        if self.discr == "LG":
            self.pol = GaussPol(self.n_cp)
        elif self.discr == "LGR":
            self.pol = RadauPol(self.n_cp)
        else:
            raise ValueError("Unknown discretization scheme %s." % self.discr)
        
        # Get to work
        self._create_NLP()
        
    def _create_NLP(self):
        """
        Wrapper for creating the NLP.
        """
        self._define_collocation()
        self._create_NLP_variables()
        self._rename_variables()
        self._create_constraints()
        self._create_constraint_function()
        self._create_cost_function()
        self._expand_MX()
        self._calc_Lagrangian_Hessian()
        self._compute_bounds_and_init()
        self._create_solver()
    
    def _define_collocation(self):
        """
        Define collocation variables.
        
        The variables are used for either creating the collocation constraints
        or eliminating the derivative variables.
        """
        collocation = {}
        x_i = casadi.symbolic("x_i", self.model.get_n_x(), self.n_cp + 1)
        der_vals_k = casadi.symbolic("der_vals[k]", self.model.get_n_x(),
                                     self.n_cp + 1)
        h_i = casadi.SX("h_i")
        collocation['coll_der'] = casadi.sum(x_i * der_vals_k, 1) / h_i
        
        collocation['x_i'] = x_i
        collocation['der_vals_k'] = der_vals_k
        collocation['h_i'] = h_i
        self._collocation = collocation
    
    def _create_NLP_variables(self, rename=False):
        """
        Create the NLP variables and store them in a nested dictionary.
        """
        # Set model info
        n_var = {'x': self.model.get_n_x(), 'w': self.model.get_n_w()}
        get_var = {'x': self.model.get_x, 'u': self.model.get_u,
                   'w': self.model.get_w}
        if self.blocking_factors is None:
            n_var['u'] = self.model.get_n_u()
        if not self.eliminate_der_var:
            get_var['dx'] = self.model.get_dx
            n_var['dx'] = self.model.get_n_x()
        
        # Count NLP variables
        n_xx = self.model.get_n_p()
        n_xx += (1 + self.n_e * self.n_cp) * N.sum(n_var.values())
        if self.eliminate_der_var:
            n_xx += n_var['x'] # dx_1_0
        if self.blocking_factors is not None:
            n_xx += len(self.blocking_factors) * self.model.get_n_u()
        if not self.eliminate_cont_var:
            n_xx += (self.n_e - 1) * n_var['x']
        if self.discr == "LG":
            n_xx += (self.n_e - 1) * n_var['x']
        if self.hs == "free":
            n_xx += self.n_e
        
        # Create NLP variables
        if self.graph == "MX" or self.graph == 'expanded_MX':
            xx = casadi.MX("xx", n_xx)
        elif self.graph == "SX":
            xx = casadi.symbolic("xx", n_xx)
        else:
            raise ValueError("Unknown CasADi graph %s." % self.graph)
        
        # Get variables with correct names
        if rename:
            xx = self.xx
        
        # Create objects for variable indexing
        var = {}
        var_indices = {}
        index = 0
        
        # Index the parameters
        new_index = index + self.model.get_n_p()
        var_indices['p_opt'] = range(index, new_index)
        index = new_index
        var['p_opt'] = xx[var_indices['p_opt']]
        
        # Index the variables at the collocation points
        for i in xrange(1, self.n_e + 1):
            var_indices[i] = {}
            var[i] = {}
            for k in xrange(1, self.n_cp + 1):
                var_indices[i][k] = {}
                var[i][k] = {}
                for var_type in n_var.keys():
                    new_index = index + n_var[var_type]
                    var_indices[i][k][var_type] = range(index, new_index)
                    index = new_index
                    var[i][k][var_type] = xx[var_indices[i][k][var_type]]
        
        # Index controls separately if blocking_factors is not None
        if self.blocking_factors is not None:
            element = 1
            for factor in self.blocking_factors:
                new_index = index + self.model.get_n_u()
                indices = range(index, new_index)
                for i in xrange(element, element + factor):
                    for k in xrange(1, self.n_cp + 1):
                        var_indices[i][k]['u'] = indices
                        var[i][k]['u'] = xx[var_indices[i][k]['u']]
                index = new_index
                element += factor
        
        # Index state continuity variables
        if self.discr == "LGR":
            for i in xrange(2, self.n_e + 1):
                var_indices[i][0] = {}
                var[i][0] = {}
                
                if self.eliminate_cont_var:
                    var_indices[i][0]['x'] = var_indices[i - 1][self.n_cp]['x']
                    var[i][0]['x'] = var[i - 1][self.n_cp]['x']
                else:
                    new_index = index + n_var['x']
                    var_indices[i][0]['x'] = range(index, new_index)
                    index = new_index
                    var[i][0]['x'] = xx[var_indices[i][0]['x']]
        elif self.discr == "LG":
            for i in xrange(1, self.n_e):
                var_indices[i][self.n_cp + 1] = {}
                var[i][self.n_cp + 1] = {}
                var_indices[i + 1][0] = {}
                var[i + 1][0] = {}
                
                # Index x_{i, n_cp + 1}
                new_index = index + n_var['x']
                var_indices[i][self.n_cp + 1]['x'] = range(index, new_index)
                index = new_index
                var[i][self.n_cp + 1]['x'] = \
                        xx[var_indices[i][self.n_cp + 1]['x']]
                
                # Index x_{i + 1, 0}
                if self.eliminate_cont_var:
                    var_indices[i + 1][0]['x'] = \
                            var_indices[i][self.n_cp + 1]['x']
                    var[i + 1][0]['x'] = var[i][self.n_cp + 1]['x']
                else:
                    new_index = index + n_var['x']
                    var_indices[i + 1][0]['x'] = range(index, new_index)
                    index = new_index
                    var[i + 1][0]['x'] = xx[var_indices[i + 1][0]['x']]
        else:
            raise ValueError("Unknown discretization scheme %s." %
                             self.discr)
        
        # Index the variables for the derivative initial values
        var[1][0] = {}
        var_indices[1][0] = {}
        if self.eliminate_der_var:
            new_index = index + n_var['x']
            var_indices[1][0]['dx'] = range(index, new_index)
            index = new_index
            var[1][0]['dx'] = xx[var_indices[1][0]['dx']]
        
        # Index the variables for the remaining initial values
        for var_type in n_var.keys():
            new_index = index + n_var[var_type]
            var_indices[1][0][var_type] = range(index, new_index)
            index = new_index
            var[1][0][var_type] = xx[var_indices[1][0][var_type]]
            
        # Index initial controls separately if blocking_factors is not None
        if self.blocking_factors is not None:
            var_indices[1][0]['u'] = var_indices[1][1]['u']
            var[1][0]['u'] = xx[var_indices[1][0]['u']]
            
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
        self.var = var
        self.var_indices = var_indices
        
    def _rename_variables(self):
        """
        Renames the NLP variables.
        
        This only works for SX graphs. It's also done in a very inefficient
        manner and should only be used for debugging purposes. The NLP
        variables are essentially created twice; first with incorrect names and
        then recreated with correct names.
        
        The switch for enabling variable renaming exists internally.
        """
        rename_switch = False # Internal switch for variable renaming
        if rename_switch:
            print("Warning: Variable renaming is currently activated.")
            assert self.graph == "SX", \
                   "Variable renaming is only allowed for SX graphs."
            xx = casadi.SXMatrix(self.n_xx, 1, 0)
            var_indices = self.var_indices
            
            for i in range(1, self.n_e+1):
                if self.hs == "free":
                    xx[var_indices['h'][i]] = casadi.SX("h_" + str(i))
                for k in var_indices[i].keys():
                    if (not self.eliminate_der_var and
                        'dx' in var_indices[i][k].keys()):
                        dx = []
                        for j in range(self.model.get_n_x()):
                            dx.append(casadi.SX(str(self.model.get_dx()[j]) +
                                                '_' + str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['dx']] = dx
                    
                    if 'x' in var_indices[i][k].keys():
                        x = []
                        for j in range(self.model.get_n_x()):
                            x.append(casadi.SX(str(self.model.get_x()[j]) +
                                               '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['x']] = x
                    
                    if 'u' in var_indices[i][k].keys():
                        u = []
                        for j in range(self.model.get_n_u()):
                            u.append(casadi.SX(str(self.model.get_u()[j]) +
                                               '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['u']] = u
                    
                    if 'w' in var_indices[i][k].keys():
                        w = []
                        for j in range(self.model.get_n_w()):
                            w.append(casadi.SX(str(self.model.get_w()[j]) +
                                               '_' +  str(i) + '_' + str(k)))
                        xx[var_indices[i][k]['w']] = w
            
            # Derivative initial values
            if self.eliminate_der_var:
                dx = []
                for j in range(self.model.get_n_x()):
                    dx.append(casadi.SX(str(self.model.get_dx()[j]) + '_1_0'))
                xx[var_indices[1][0]['dx']] = dx
            
            self.xx = xx
            self._create_NLP_variables(True)
    
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
        z = casadi.vertcat([self.var['p_opt'],
                            self.var[i][k]['dx'],
                            self.var[i][k]['x'],
                            self.var[i][k]['u'],
                            self.var[i][k]['w'],
                            self.time_points[i][k]])
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
        z = casadi.vertcat([self.var['p_opt'],
                            self.var[i][k]['x'],
                            self.var[i][k]['u'],
                            self.var[i][k]['w'],
                            self.time_points[i][k]])
        return z
    
    def _create_constraints(self):
        """
        Create the constraints and time points.
        """
        # Get a local reference to var
        var = self.var
        
        # Broadcast self.pol.der_vals
        # Note that der_vals is quite different from self.pol.der_vals
        der_vals = []
        self.der_vals = der_vals
        for k in xrange(self.n_cp + 1):
            der_vals_k = [self.pol.der_vals[:, k].reshape([1, self.n_cp + 1])]
            der_vals_k *= self.model.get_n_x()
            der_vals += [casadi.vertcat(der_vals_k)]
        
        # Create collocation and DAE functions
        x_i = self._collocation['x_i']
        der_vals_k = self._collocation['der_vals_k']
        h_i = self._collocation['h_i']
        if self.eliminate_der_var:
            coll_der = self._collocation['coll_der']
            init = casadi.substitute(self.ocp.initial_eq_, self.model.dx,
                                     coll_der)
            dae = casadi.substitute(self.ocp.implicit_fcn_, self.model.dx,
                                    coll_der)
            
            sym_z = []
            sym_z += list(self.model.p)
            sym_z += list(self.model.x)
            sym_z += list(self.model.u)
            sym_z += list(self.model.w)
            sym_z += [self.model.t]
            
            dae_F_t0 = self.model.get_dae_F()
            dae_F = casadi.SXFunction([sym_z, x_i, der_vals_k, h_i], [dae])
            dae_F.init()
        else:
            dx_i_k = casadi.symbolic("dx_i_k", self.model.get_n_x())
            coll_eq = casadi.SXFunction(
                    [x_i, der_vals_k, h_i, dx_i_k],
                    [casadi.sum(x_i * der_vals_k, 1) - h_i * dx_i_k])
            coll_eq.init()
            dae_F = self.model.get_dae_F()
        init_F0 = self.model.get_init_F0()
        
        # Create path constraint functions
        g_e = []
        g_i = []
        path_fcn = self.ocp.path_fcn_
        lb = self.ocp.path_min_
        ub = self.ocp.path_max_
        for i in range(len(path_fcn)):
            if lb[i] == ub[i]:
                g_e += [path_fcn[i] - ub[i]]
            else:
                if lb[i] != -N.inf:
                    g_i += [-path_fcn[i] + lb[i]]
                if ub[i] != N.inf:
                    g_i += [path_fcn[i] - ub[i]]
        if self.eliminate_der_var:
            z = casadi.vertcat([self.model.p,
                                self.model.x,
                                self.model.u,
                                self.model.w,
                                self.model.t])
            g_e = casadi.substitute(g_e, self.model.dx, coll_der)
            g_i = casadi.substitute(g_i, self.model.dx, coll_der)
            g_e_fcn = casadi.SXFunction([z, x_i, der_vals_k, h_i], [g_e])
            g_i_fcn = casadi.SXFunction([z, x_i, der_vals_k, h_i], [g_i])
        else:
            z = casadi.vertcat([self.model.p,
                                self.model.dx,
                                self.model.x,
                                self.model.u,
                                self.model.w,
                                self.model.t])
            g_e_fcn = casadi.SXFunction([z], [g_e])
            g_i_fcn = casadi.SXFunction([z], [g_i])
        g_e_fcn.init()
        g_i_fcn.init()
        
        # Define function evaluation methods based on graph
        if self.graph == 'MX' or self.graph == 'expanded_MX':
            init_F0_eval = init_F0.call
            dae_F_eval = dae_F.call
            if self.eliminate_der_var:
                dae_F_t0_eval = dae_F_t0.call
            else:
                coll_eq_eval = coll_eq.call
            g_e_eval = g_e_fcn.call
            g_i_eval = g_i_fcn.call
            c_e = casadi.MX() 
            c_i = casadi.MX()
        elif self.graph == 'SX':
            init_F0_eval = init_F0.eval
            dae_F_eval = dae_F.eval
            if self.eliminate_der_var:
                dae_F_t0_eval = dae_F_t0.eval
            else:
                coll_eq_eval = coll_eq.eval
            g_e_eval = g_e_fcn.eval
            g_i_eval = g_i_fcn.eval
            c_e = casadi.SXMatrix()
            c_i = casadi.SXMatrix()
        else:
            raise ValueError('Unknown CasADi graph %s.' % graph)
            
        # Calculate time points
        self.time_points = {}
        time = []
        i = 1
        self.time_points[i] = {}
        t = self.ocp.t0
        self.time_points[i][0] = t
        time += [t]
        ti = t # Time at start of element
        for k in xrange(1, self.n_cp + 1):
            t = ti + self.horizon * self.h[i] * self.pol.p[k]
            self.time_points[i][k] = t
            time += [t]
        for i in xrange(2, self.n_e + 1):
            self.time_points[i] = {}
            ti = (self.time_points[i - 1][self.n_cp] +
                  (1. - self.pol.p[self.n_cp]) * self.horizon * self.h[i])
            for k in xrange(1, self.n_cp + 1):
                t = ti + self.horizon * self.h[i] * self.pol.p[k]
                self.time_points[i][k] = t
                time += [t]
        
        # Create list of state matrices
        x_list = [[]]
        self.x_list = x_list
        for i in xrange(1, self.n_e + 1):
            x_i = [var[i][k]['x'] for k in xrange(self.n_cp + 1)]
            x_i = casadi.horzcat(x_i)
            x_list += [x_i]
        
        # Initial conditions
        i = 1
        k = 0
        if self.eliminate_der_var:
            z = self._get_z(i, k)
            [initial_F0] = init_F0_eval([z])
            [initial_F] = dae_F_t0_eval([z])
        else:
            z = self._get_z(i, k)
            [initial_F0] = init_F0_eval([z])
            [initial_F] = dae_F_eval([z])
        c_e = casadi.vertcat([c_e, initial_F0])
        c_e = casadi.vertcat([c_e, initial_F])
        
        # Evaluate u_1_0 based on polynomial u_1
        u_1_0 = 0
        for k in xrange(1, self.n_cp + 1):
            u_1_0 += var[1][k]['u'] * self.pol.eval_basis(k, 0, False)
            
        # Add residual for u_1_0 as constraint
        c_e = casadi.vertcat([c_e, var[1][0]['u'] - u_1_0])
        
        # Collocation and DAE constraints
        if self.eliminate_der_var:
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    z = self._get_z_elim_der(i, k)
                    [dae_constr] = dae_F_eval([z, x_list[i], der_vals[k],
                                               self.horizon * self.h[i]])
                    c_e = casadi.vertcat([c_e, dae_constr])
        else:
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    # Collocation constraint
                    [coll_constr] = coll_eq_eval([x_list[i], der_vals[k], 
                                                  self.horizon * self.h[i],
                                                  var[i][k]['dx']])
                    c_e = casadi.vertcat([c_e, coll_constr])
                    
                    # DAE constraint
                    z = self._get_z(i, k)
                    [dae_constr] = dae_F_eval([z])
                    c_e = casadi.vertcat([c_e, dae_constr])
                
        # Continuity constraints for x_{i, n_cp + 1}
        if self.discr == "LG":
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        x_i_np1 += self.pol.w[k] * var[i][k]['dx']
                    x_i_np1 = (var[i][0]['x'] + 
                               self.horizon * self.h[i] * x_i_np1)
                    
                    # Add residual for x_i_np1 as constraint
                    c_e = casadi.vertcat(
                            [c_e, var[i][self.n_cp + 1]['x'] - x_i_np1])
            else:
                for i in xrange(1, self.n_e):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_np1 += var[i][k]['x'] * self.pol.eval_basis(k, 1,
                                                                        True)
                    
                    # Add residual for x_i_np1 as constraint
                    c_e = casadi.vertcat(
                            [c_e, var[i][self.n_cp + 1]['x'] - x_i_np1])
        
        # Continuity constraints for x_{i, 0}
        if not self.eliminate_cont_var:
            gauss = int(self.discr == "LG")
            for i in xrange(1, self.n_e):
                cont_constr = (var[i][self.n_cp + gauss]['x'] - 
                               var[i + 1][0]['x'])
                c_e = casadi.vertcat([c_e, cont_constr])
                
        # Element length constraints
        if self.hs == "free":
            h_constr = casadi.sum(self.h[1:]) - 1
            c_e = casadi.vertcat([c_e, h_constr])
        
        # Path constraints
        if self.eliminate_der_var:
            for i in xrange(1, self.n_e + 1):
                for k in self.time_points[i]:
                    z = self._get_z_elim_der(i, k)
                    [g_e_constr] = g_e_eval([z, x_list[i], der_vals[k],
                                             self.horizon * self.h[i]])
                    [g_i_constr] = g_i_eval([z, x_list[i], der_vals[k],
                                             self.horizon * self.h[i]])
                    c_e = casadi.vertcat([c_e, g_e_constr])
                    c_i = casadi.vertcat([c_i, g_i_constr])
        else:
            for i in xrange(1, self.n_e + 1):
                for k in self.time_points[i]:
                    z = self._get_z(i, k)
                    [g_e_constr] = g_e_eval([z])
                    [g_i_constr] = g_i_eval([z])
                    c_e = casadi.vertcat([c_e, g_e_constr])
                    c_i = casadi.vertcat([c_i, g_i_constr])
        
        # Store constraints and time as data attributes
        # This code can be simplified once
        # https://sourceforge.net/apps/trac/casadi/ticket/180
        # has been fixed.
        self.c_e = c_e
        if self.graph == 'MX' or self.graph == 'expanded_MX':
            if c_i.isNull():
                self.c_i = casadi.MX(0, 0)
            else:
                self.c_i = c_i
        else:
            self.c_i = c_i
        self.time = N.array(time)
        
    def _create_constraint_function(self):
        """
        Create constraint function and calculate its Jacobian.
        """
        # Concatenate constraints
        c_e = self.get_equality_constraint()
        if c_e.numel() == 0:
            c_e = []
        c_i = self.get_inequality_constraint()
        if c_i.numel() == 0:
            c_i = []
        c = casadi.vertcat([c_e, c_i])
        self.c = c
        
        # Create constraint function
        if self.graph == 'MX' or self.graph == 'expanded_MX':
            c_fcn = casadi.MXFunction([self.get_xx()], [c])
        elif self.graph == 'SX':
            c_fcn = casadi.SXFunction([self.get_xx()], [c])
        else:
            raise ValueError('Unknown CasADi graph %s.' % self.graph)
            
        # Set user provided options and initialize
        for (k, v) in self.CasADi_options_G.iteritems():
            c_fcn.setOption(k, v)
        c_fcn.init()
            
        # Save constraint function as data attribute
        self.c_fcn = c_fcn
        
    def _create_cost_function(self):
        """
        Create the cost function.
        
        If parameter estimation data is available, the cost function will be
        based on that. Otherwise the cost function will be a Bolza functional.
        """
        # Retrieve collocation variables
        if self.eliminate_der_var:
            x_i = self._collocation['x_i']
            der_vals_k = self._collocation['der_vals_k']
            h_i = self._collocation['h_i']
            coll_der = self._collocation['coll_der']
        
        # Calculate cost
        if self.parameter_estimation_data is None:
            self.cost_mayer = 0
            self.cost_lagrange = 0
            
            # Mayer cost
            J = self.model.get_opt_J()
            if J is not None:
                z = self._get_z_elim_der(self.n_e, self.n_cp)
                
                # Use appropriate function evaluation based on graph
                if self.graph == "MX" or self.graph == 'expanded_MX':
                    [self.cost_mayer] = J.call([z])
                elif self.graph == "SX":
                    [self.cost_mayer] = J.eval([z])
                else:
                    raise ValueError("Unknown CasADi graph %s." %
                                     self.graph)
            
            # Lagrange cost
            if self.eliminate_der_var:
                L = self.ocp.lterm
                sym_z = []
                sym_z += list(self.model.p)
                sym_z += list(self.model.x)
                sym_z += list(self.model.u)
                sym_z += list(self.model.w)
                sym_z += [self.model.t]
                
                if len(self.ocp.lterm) > 0:
                    L = casadi.substitute(L[0], self.model.dx, coll_der)
                    L_fcn = casadi.SXFunction([sym_z, x_i, der_vals_k, h_i],
                                              [L])
                    L_fcn.init()
                    
                    # Define function evaluation method based on graph
                    if self.graph == "MX" or self.graph == 'expanded_MX':
                        L_eval = L_fcn.call
                    elif self.graph == "SX":
                        L_eval = L_fcn.eval
                    else:
                        raise ValueError("Unknown CasADi graph %s." %
                                         self.graph)
                    
                    # Evaluate Lagrange cost function on each collocation point
                    for i in xrange(1, self.n_e + 1):
                        for k in xrange(1, self.n_cp + 1):
                            z = self._get_z_elim_der(i, k)
                            self.cost_lagrange += \
                                    (self.horizon * self.h[i] *
                                     L_eval([z, self.x_list[i],
                                             self.der_vals[k],
                                             self.horizon * self.h[i]])[0] *
                                     self.pol.w[k])
            else:
                L = self.model.get_opt_L()
                if L is not None:
                    # Define function evaluation method based on graph
                    if self.graph == "MX" or self.graph == 'expanded_MX':
                        L_eval = L.call
                    elif self.graph == "SX":
                        L_eval = L.eval
                    else:
                        raise ValueError("Unknown CasADi graph %s." %
                                         self.graph)
                    
                    # Evaluate Lagrange cost function on each collocation point
                    for i in xrange(1, self.n_e + 1):
                        for k in xrange(1, self.n_cp + 1):
                            z = self._get_z(i, k)
                            self.cost_lagrange += (self.horizon * self.h[i] *
                                                   L_eval([z])[0] *
                                                   self.pol.w[k])
            
            # Sum up the two cost terms
            self.cost = self.cost_mayer + self.cost_lagrange
        else:
            # Interpolate the parameter estimation data
            data = self.parameter_estimation_data.data
            
            if self.parameter_estimation_data.discrete:
                raise NotImplementedError("Discrete parameter estimation is " +
                                          "not yet supported.")
            else:
                # Create base cost function
                self.cost = 0
                
                # Variable reference maps
                x_vr = copy.deepcopy(self.model.get_x_vr_map())
                x_vr['var_name'] = 'x'
                x_vr['sf'] = self.model.get_x_sf()
                w_vr = copy.deepcopy(self.model.get_w_vr_map())
                w_vr['var_name'] = 'w'
                w_vr['sf'] = self.model.get_w_sf()
                u_vr = copy.deepcopy(self.model.get_u_vr_map())
                u_vr['var_name'] = 'u'
                u_vr['sf'] = self.model.get_u_sf()
                
                # Map of maps
                maps_map = {}
                for v_map in [x_vr, w_vr, u_vr]:
                    for key in v_map.keys():
                        maps_map[key] = v_map
                
                # Create nested dictionary for storage of errors and calculate
                # reference values
                err = {}
                y_ref = {}
                for i in range(1, self.n_e + 1):
                    err[i] = {}
                    y_ref[i] = {}
                    for k in range(1, self.n_cp + 1):
                        err[i][k] = []
                        y_ref[i][k] = data.eval(self.time_points[i][k])[0, :]
                
                # Calculate errors
                measured_variables = \
                        self.parameter_estimation_data.measured_variables
                for j in xrange(len(measured_variables)):
                    val_ref = self.model.xmldoc.get_value_reference(
                            measured_variables[j])
                    for i in range(1, self.n_e + 1):
                        for k in range(1, self.n_cp + 1):
                            v_map = maps_map[val_ref]
                            l = v_map[val_ref]
                            val = self.var[i][k][v_map['var_name']][l]
                            sf = v_map['sf'][l]
                            ref_val = y_ref[i][k][j]
                            err[i][k].append(sf * val - ref_val)
                
                # Calculate cost contribution from each collocation point
                Q = self.parameter_estimation_data.Q
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
                    integrand = N.dot(N.dot(self.var[i][k]['dx'].T, Q),
                                      self.var[i][k]['dx'])
                    length_cost += (h_i ** (1 + a) * integrand * self.pol.w[k])
            self.cost += c * length_cost

        # Define NLP objective function based on graph
        if self.graph == "MX":
            cost_fcn = casadi.MXFunction([self.xx], [self.cost])
        elif self.graph == 'expanded_MX':
            cost_fcn = casadi.MXFunction([self.xx], [self.cost])
        elif self.graph == "SX":
            cost_fcn = casadi.SXFunction([self.xx], [self.cost])
        else:
            raise ValueError("Unknown CasADi graph %s." % graph)
        
        # Set user provided options and initialize
        for (k, v) in self.CasADi_options_F.iteritems():
            cost_fcn.setOption(k, v)
        cost_fcn.init()
        
        # Save cost function as data attribute
        self.cost_fcn = cost_fcn
        
    def _expand_MX(self):
        """
        Expand the MX graphs to SX graphs.
        """
        if self.graph == "expanded_MX":
            # Replace NLP MX objects with SX objects from expansion
            self.xx = casadi.symbolic("xx", self.n_xx)
            
            # Recreate constraints
            self.c_fcn = self.c_fcn.expand([self.xx])
            n_c_e = self.c_e.numel()
            self.c_e = self.c_fcn.outputSX()[:n_c_e]
            self.c_i = self.c_fcn.outputSX()[n_c_e:]
            self.c = casadi.vertcat([self.c_e, self.c_i])
            
            # Reset user provided options and initialize
            for (k, v) in self.CasADi_options_G.iteritems():
                self.c_fcn.setOption(k, v)
            self.c_fcn.init()
            
            # Recreate cost
            self.cost_fcn = self.cost_fcn.expand([self.xx])
            self.cost = self.cost_fcn.outputSX()
            
            # Reset user provided options and initialize
            for (k, v) in self.CasADi_options_F.iteritems():
                self.cost_fcn.setOption(k, v)
            self.cost_fcn.init()
        
    def _calc_Lagrangian_Hessian(self):
        """
        Calculate the exact Hessian of the NLP Lagrangian.
        """
        if self.exact_Hessian:
            # Lagrange multipliers and objective function scaling
            if self.graph == 'MX':
                lam = casadi.MX("lambda", self.c.numel())
                sigma = casadi.MX("sigma")
            elif self.graph == "SX" or self.graph == 'expanded_MX':
                lam = casadi.symbolic("lambda", self.c.numel())
                sigma = casadi.symbolic("sigma")
            else:
                raise ValueError('Unknown CasADi graph %s.' % self.graph)
            
            # Lagrangian
            lag_exp = sigma * self.cost + casadi.inner_prod(lam, self.c)
            if self.graph == 'MX':
                L = casadi.MXFunction([self.xx, lam, sigma], [lag_exp])
            elif self.graph == "SX" or self.graph == 'expanded_MX':
                L = casadi.SXFunction([self.xx, lam, [sigma]], [lag_exp])
            else:
                raise ValueError('Unknown CasADi graph %s.' % self.graph)
                
            # Set user provided options and initialize
            for (k, v) in self.CasADi_options_L.iteritems():
                L.setOption(k, v)
            L.init()
        
            # Calculate Hessian
            self.H_fcn = L.hessian()
        else:
            # Set Hessian of the Lagrangian to a null function
            if self.graph == 'MX':
                self.H_fcn = casadi.MXFunction()
            elif self.graph == "SX" or self.graph == 'expanded_MX':
                self.H_fcn = casadi.SXFunction()
            else:
                raise ValueError('Unknown CasADi graph %s.' % self.graph)
                
    def _compute_bounds_and_init(self):
        """
        Compute bounds and intial guesses for NLP variables.
        """
        # Create lower and upper bounds
        nlp_lb = self.LOWER * N.ones(self.get_n_xx())
        nlp_ub = self.UPPER * N.ones(self.get_n_xx())
        nlp_init = N.zeros(self.get_n_xx())
        
        # Retrieve model data
        vr_map_p = self.model.get_p_vr_map()
        vr_map_x = self.model.get_x_vr_map()
        vr_map_u = self.model.get_u_vr_map()
        vr_map_w = self.model.get_w_vr_map()
        sf_p = self.model.get_p_sf()
        sf_x = self.model.get_x_sf()
        sf_u = self.model.get_u_sf()
        sf_w = self.model.get_w_sf()
        var_indices = self.get_var_indices()
        md = self.get_model_description()
        
        # Get model bounds and initial guesses
        _p_opt_max = md.get_p_opt_max(include_alias=False)
        _x_max = md.get_x_max(include_alias=False)
        _u_max = md.get_u_max(include_alias=False)
        _w_max = md.get_w_max(include_alias=False)
        _p_opt_min = md.get_p_opt_min(include_alias=False)
        _x_min = md.get_x_min(include_alias=False)
        _u_min = md.get_u_min(include_alias=False)
        _w_min = md.get_w_min(include_alias=False)
        _p_opt_init = md.get_p_opt_initial_guess(include_alias=False)
        _x_init = md.get_x_initial_guess(include_alias=False)
        _u_init = md.get_u_initial_guess(include_alias=False)
        _w_init = md.get_w_initial_guess(include_alias=False)
        
        # Set preliminary bounds and initial guesses
        p_opt_max = self.UPPER * N.ones(len(_p_opt_max))
        x_max = self.UPPER * N.ones(len(_x_max))
        u_max = self.UPPER * N.ones(len(_u_max))
        w_max = self.UPPER * N.ones(len(_w_max))
        p_opt_min = self.LOWER * N.ones(len(_p_opt_min))
        x_min = self.LOWER * N.ones(len(_x_min))
        u_min = self.LOWER * N.ones(len(_u_min))
        w_min = self.LOWER * N.ones(len(_w_min))
        p_opt_init = self.UPPER * N.ones(len(_p_opt_init))
        x_init = self.LOWER * N.ones(len(_x_init))
        u_init = self.LOWER * N.ones(len(_u_init))
        w_init = self.LOWER * N.ones(len(_w_init))
        
        # Set scaled bounds and initial guesses for parameters
        for (vr, val) in _p_opt_min:
            if val is not None:
                p_opt_min[vr_map_p[vr]] = val / sf_p[vr_map_p[vr]]
        for (vr, val) in _p_opt_max:
            if val is not None:
                p_opt_max[vr_map_p[vr]] = val / sf_p[vr_map_p[vr]]
        for (vr, val) in _p_opt_init:
            if val is not None:
                p_opt_init[vr_map_p[vr]] = val / sf_p[vr_map_p[vr]]
        
        # Set scaled bounds and initial guesses for states
        for (vr, val) in _x_min:
            if val is not None:
                x_min[vr_map_x[vr]] = val / sf_x[vr_map_x[vr]]
        for (vr, val) in _x_max:
            if val is not None:
                x_max[vr_map_x[vr]] = val / sf_x[vr_map_x[vr]]
        for (vr, val) in _x_init:
            if val is not None:
                x_init[vr_map_x[vr]] = val / sf_x[vr_map_x[vr]]
        
        # Set scaled bounds and initial guesses for controls
        for (vr, val) in _u_min:
            if val is not None:
                u_min[vr_map_u[vr]] = val / sf_u[vr_map_u[vr]]
        for (vr, val) in _u_max:
            if val is not None:
                u_max[vr_map_u[vr]] = val / sf_u[vr_map_u[vr]]
        for (vr, val) in _u_init:
            if val is not None:
                u_init[vr_map_u[vr]] = val / sf_u[vr_map_u[vr]]
        
        # Set scaled bounds and initial guesses for algebraic variables
        for (vr, val) in _w_min:
            if val is not None:
                w_min[vr_map_w[vr]] = val / sf_w[vr_map_w[vr]]
        for (vr, val) in _w_max:
            if val is not None:
                w_max[vr_map_w[vr]] = val / sf_w[vr_map_w[vr]]
        for (vr, val) in _w_init:
            if val is not None:
                w_init[vr_map_w[vr]] = val / sf_w[vr_map_w[vr]]
        
        # Compose bounds and initial guesses
        nlp_lb[var_indices['p_opt']] = p_opt_min
        nlp_ub[var_indices['p_opt']] = p_opt_max
        nlp_init[var_indices['p_opt']] = p_opt_init
        for i in xrange(1, self.n_e + 1):
            for k in self.get_time_points()[i]:
                nlp_lb[var_indices[i][k]['x']] = x_min
                nlp_ub[var_indices[i][k]['x']] = x_max
                nlp_init[var_indices[i][k]['x']] = x_init
                nlp_lb[var_indices[i][k]['u']] = u_min
                nlp_ub[var_indices[i][k]['u']] = u_max
                nlp_init[var_indices[i][k]['u']] = u_init
                nlp_lb[var_indices[i][k]['w']] = w_min
                nlp_ub[var_indices[i][k]['w']] = w_max
                nlp_init[var_indices[i][k]['w']] = w_init
        
        # Handle derivatives independently
        if not self.eliminate_der_var:
            vr_map_dx = self.model.get_dx_vr_map()
            sf_dx = self.model.get_dx_sf()
            _dx_max = md.get_dx_max(include_alias=False)
            _dx_min = md.get_dx_min(include_alias=False)
            _dx_init = md.get_dx_initial_guess(include_alias=False)
            dx_max = self.UPPER * N.ones(len(_dx_max))
            dx_min = self.LOWER * N.ones(len(_dx_min))
            dx_init = self.LOWER * N.ones(len(_dx_init))
            
            for (vr, val) in _dx_min:
                if val is not None:
                    dx_min[vr_map_dx[vr]] = val / sf_dx[vr_map_dx[vr]]
            for (vr, val) in _dx_max:
                if val is not None:
                    dx_max[vr_map_dx[vr]] = val / sf_dx[vr_map_dx[vr]]
            for (vr, val) in _dx_init:
                if val is not None:
                    dx_init[vr_map_dx[vr]] = val / sf_dx[vr_map_dx[vr]]
            
            for i in xrange(1, self.n_e + 1):
                for k in self.get_time_points()[i]:
                    nlp_lb[var_indices[i][k]['dx']] = dx_min
                    nlp_ub[var_indices[i][k]['dx']] = dx_max
                    nlp_init[var_indices[i][k]['dx']] = dx_init
        
        # Compute bounds and initial guesses for element lengths
        if self.hs == "free":
            h_0 = 1. / self.n_e
            h_bounds = self.free_element_lengths_data.bounds
            var_indices = self.get_var_indices()
            for i in xrange(1, self.n_e + 1):
                nlp_lb[var_indices['h'][i]] = h_bounds[0] * h_0
                nlp_ub[var_indices['h'][i]] = h_bounds[1] * h_0
                nlp_init[var_indices['h'][i]] = h_bounds[1] * h_0
        
        self.xx_lb = nlp_lb
        self.xx_ub = nlp_ub
        self.xx_init = nlp_init

        return (nlp_lb, nlp_ub, nlp_init)
    
    def _create_solver(self):
        if self.get_hessian().isNull():
            self.solver = casadi.IpoptSolver(self.get_cost(), self.c_fcn)
        else:
            self.solver = casadi.IpoptSolver(self.get_cost(), self.c_fcn,
                                             self.get_hessian())
        
    def get_equality_constraint(self):
        return self.c_e
    
    def get_inequality_constraint(self):
        return self.c_i
    
    def get_cost(self):
        return self.cost_fcn
    
    def get_hessian(self):
        return self.H_fcn
    
    def get_result(self):
        # Set model info
        n_var = {'dx': self.model.get_n_x(), 'x': self.model.get_n_x(),
                 'u': self.model.get_n_u(), 'w': self.model.get_n_w()}
        cont = {'dx': False, 'x': True, 'u': False, 'w': False}
        var_types = ['x', 'u', 'w']
        if not self.eliminate_der_var:
            var_types = ['dx'] + var_types
        var_opt = {}
        var_indices = self.get_var_indices()
        
        # Get element lengths
        if self.hs == "free":
            h_opt = N.vstack([N.nan, self.horizon * 
                                     self.nlp_opt[var_indices['h'][1:]]])
        else:
            h_opt = self.horizon * N.array(self.h)
        self.h_opt = h_opt
        
        # Create array with discrete times
        if self.result_mode == "collocation_points":
            if self.hs == "free":
                t_start = 0.
                t_opt = [t_start]
                for h in h_opt:
                    for k in xrange(1, self.n_cp + 1):
                        t_opt.append(t_start + 
                                     self.pol.p[k] * h)
                    t_start += h
                t_opt = N.array(t_opt).reshape([-1, 1])
            else:
                t_opt = self.get_time().reshape([-1, 1])
        elif self.result_mode == "element_interpolation":
            t_opt = []
            t_start = 0.
            for i in xrange(1, self.n_e + 1):
                t_end = t_start + h_opt[i]
                t_i = N.linspace(t_start, t_end, self.n_eval_points)
                t_opt = N.hstack([t_opt, t_i])
                t_start = t_opt[-1]
            t_opt = t_opt.reshape([-1, 1])
        else:
            raise ValueError("Unknown result mode %s." % self.result_mode)
        
        # Create arrays for storage of variable trajectories
        for var_type in var_types:
            var_opt[var_type] = N.empty([len(t_opt), n_var[var_type]])
        if self.eliminate_der_var:
            var_opt['dx'] = N.empty([len(t_opt), n_var['x']])
        var_opt['p_opt'] = N.empty(self.model.get_n_p())
        
        # Get optimal parameter values
        var_opt['p_opt'][:] = \
                self.nlp_opt[self.get_var_indices()['p_opt']].reshape(-1)
        
        # Get solution trajectories
        t_index = 0
        time_points = self.get_time_points()
        if self.result_mode == "collocation_points":
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        xx_i_k = self.nlp_opt[var_indices[i][k][var_type]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    t_index += 1
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = self.nlp_opt[var_indices[i][k]['dx']]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1
                
                # Collocation point derivatives
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = 0
                        for l in xrange(self.n_cp + 1):
                            x_i_l = self.nlp_opt[var_indices[i][l]['x']]
                            dx_i_k += (1. / h_opt[i] * x_i_l * 
                                       self.pol.eval_basis_der(
                                               l, self.pol.p[k]))
                        var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                        t_index += 1
        elif self.result_mode == "element_interpolation":
            tau_arr = N.linspace(0, 1, self.n_eval_points)
            for i in xrange(1, self.n_e + 1):
                for tau in tau_arr:
                    # Non-derivatives
                    for var_type in var_types[not self.eliminate_der_var:]:
                        # Evaluate xx_i_tau based on polynomial xx^i
                        xx_i_tau = 0
                        for k in xrange(not cont[var_type], self.n_cp + 1):
                            xx_i_k = self.nlp_opt[var_indices[i][k][var_type]]
                            xx_i_tau += xx_i_k * self.pol.eval_basis(
                                    k, tau, cont[var_type])
                        var_opt[var_type][t_index, :] = xx_i_tau.reshape(-1)
                    
                    # Derivatives
                    dx_i_tau = 0
                    for k in xrange(0, self.n_cp + 1):
                        x_i_k = self.nlp_opt[var_indices[i][k]['x']]
                        dx_i_tau += (1. / h_opt[i] * x_i_k * 
                                     self.pol.eval_basis_der(k, tau))
                    var_opt['dx'][t_index, :] = dx_i_tau.reshape(-1)
                    
                    t_index += 1
        else:
            raise ValueError("Unknown result mode %s." % self.result_mode)
        
        # Return results
        return (t_opt, var_opt['dx'], var_opt['x'], var_opt['u'], var_opt['w'],
                var_opt['p_opt'])
                
    def get_h_opt(self):
        if self.hs == "free":
            return self.h_opt
        else:
            return None
    
    def set_initial_from_file(self, res):
        """ 
        Initialize the optimization vector from an object of either 
        ResultDymolaTextual or ResultDymolaBinary.

        Parameters::
        
            res --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary.
        """
        
        xmldoc = self.model.get_model_description()

        # Obtain the names and sort them in value reference order
        names = xmldoc.get_dx_variable_names(include_alias=False)
        dx_names=[]
        for name in sorted(names):
            dx_names.append(name[1])

        names = xmldoc.get_x_variable_names(include_alias=False)
        x_names=[]
        for name in sorted(names):
            x_names.append(name[1])

        names = xmldoc.get_u_variable_names(include_alias=False)
        u_names=[]
        for name in sorted(names):
            u_names.append(name[1])

        names = xmldoc.get_w_variable_names(include_alias=False)
        w_names=[]
        for name in sorted(names):
            w_names.append(name[1])

        names = xmldoc.get_p_opt_variable_names(include_alias=False)
        p_opt_names=[]
        for name in sorted(names):
            p_opt_names.append(name[1])
        
        # Obtain vector sizes
        n_points = 0
        num_name_hits = 0
        if len(dx_names) > 0:
            for name in dx_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(x_names) > 0:
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

        elif len(w_names) > 0:
            for name in w_names:
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
        
        #print(traj.t)
        
        n_points = N.size(traj.t,0)
        n_cols = 1+len(dx_names)+len(x_names)+len(u_names)+len(w_names)

        var_data = N.zeros((n_points,n_cols))
        # Initialize time vector
        var_data[:,0] = res.get_variable_data('time').t

#         p_opt_data = N.zeros(len(p_opt_names))

#         sc = self._model.jmimodel.get_variable_scaling_factors()

#         # Get the parameters
#         n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
#         if n_p_opt > 0:
#             p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
#             self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
#             p_opt_indices = p_opt_indices.tolist()

#             for name in p_opt_names:
#                 try:
#                     ref = self._model.get_value_reference(name)
#                     (z_i, ptype) = jmi._translate_value_ref(ref)
#                     i_pi = z_i - self._model._offs_real_pi.value
#                     i_pi_opt = p_opt_indices.index(i_pi)
#                     traj = res.get_variable_data(name)
#                     if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
#                         p_opt_data[i_pi_opt] = traj.x[0]/sc[z_i]
#                     else:
#                         p_opt_data[i_pi_opt] = traj.x[0]
#                 except VariableNotFoundError:
#                     print "Warning: Could not find value for parameter " + name
                    
#         #print(N.size(var_data))

#         # Initialize variable names
#         # Loop over all the names

#         sc_dx = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_dx.value:self._model._offs_real_x.value]
#         sc_x = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_x.value:self._model._offs_real_u.value]
#         sc_u = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_u.value:self._model._offs_real_w.value]
#         sc_w = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_w.value:self._model._offs_t.value]

        #scaling = False

        col_index = 1;
        dx_index = 0;
        x_index = 0;
        u_index = 0;
        w_index = 0;
        for name in dx_names:
            try:
                #print(name)
                #print(self.model.get_dx_sf()[dx_index])
                #print(col_index)
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x/self.model.get_dx_sf()[dx_index]
                dx_index = dx_index + 1
                col_index = col_index + 1
            except:
                dx_index = dx_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for derivative variable " + name
        for name in x_names:
            try:
                #print(name)
                #print(self.model.get_x_sf()[x_index])
                #print(col_index)
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x/self.model.get_x_sf()[x_index]
                x_index = x_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                x_index = x_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for state variable " + name

        for name in u_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if not res.is_variable(name):
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0]/self.model.get_u_sf()[u_index]
                else:
                    var_data[:,col_index] = traj.x/self.model.get_u_sf()[u_index]
                u_index = u_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                u_index = u_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for input variable " + name

        for name in w_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if not res.is_variable(name):
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0]/self.model.get_w_sf()[w_index]
                else:
                    var_data[:,col_index] = traj.x/self.model.get_w_sf()[w_index]
                w_index = w_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                w_index = w_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for algebraic variable " + name

        dx_init = N.empty([len(self.get_time()), self.model.get_n_x()])
        x_init = N.empty([len(self.get_time()), self.model.get_n_x()])
        w_init = N.empty([len(self.get_time()), self.model.get_n_w()])
        u_init = N.empty([len(self.get_time()), self.model.get_n_u()])

        # make sure abscissa is increasing
        d = var_data[0,0]
        for i in range(len(var_data[:,0])-1):
            if var_data[i+1,0]<=d:
                var_data[i+1,0] = d + 1e-5
            d = var_data[i+1,0]

        # interpolate
        for i in range(self.model.get_n_x()):
            dx_init[:,i] = N.interp(self.get_time(), var_data[:, 0],
                                    var_data[:,1+i]);

        for i in range(self.model.get_n_x()):
            x_init[:,i] = N.interp(self.get_time(), var_data[:, 0],
                                   var_data[:,1 + self.model.get_n_x() +i]);

        for i in range(self.model.get_n_u()):
            u_init[:,i] = N.interp(self.get_time(), var_data[:, 0],
                                   var_data[:, 1 + 2 * self.model.get_n_x() +
                                               i]);

        for i in range(self.model.get_n_w()):
            w_init[:,i] = N.interp(self.get_time(), var_data[:, 0],
                                   var_data[:, 1 + 2*self.model.get_n_x() + self.model.get_n_u() + i]);

        cnt = 0
        try:
            eliminate_der_var = self.eliminate_der_var
        except AttributeError:
            eliminate_der_var = False
        
        if eliminate_der_var:
            self.get_xx_init()[self.var_indices[1][0]['dx']] = dx_init[cnt,:]
        
        for i in xrange(1, self.n_e + 1):
            for k in self.get_time_points()[i]:
                if (self.model.get_n_x()>0 and not eliminate_der_var):
                    self.get_xx_init()[self.var_indices[i][k]['dx']] = dx_init[cnt,:]
                if (self.model.get_n_x()>0):
                    self.get_xx_init()[self.var_indices[i][k]['x']] = x_init[cnt,:]
                    if i>1: # Initialize element junction states TODO: this is not quite correct, could be improved
                        try:
                            self.get_xx_init()[self.var_indices[i][0]['x']] = x_init[cnt,:]
                        except:
                            pass
                if (self.model.get_n_u()>0):
                    self.get_xx_init()[self.var_indices[i][k]['u']] = u_init[cnt,:]
                if (self.model.get_n_w()>0):
                    self.get_xx_init()[self.var_indices[i][k]['w']] = w_init[cnt,:]
                cnt = cnt + 1

class PseudoSpectral(CasADiCollocator):
    
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
        #Make problem explicit
        model._convert_to_ode()
        
        self.model = model
        self.options = options
        self.md  = model.get_model_description()
        self.ocp = model.get_casadi_ocp()
        
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
        
        # Necessary!
        super(PseudoSpectral,self).__init__(model)
        
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
                xx_init[self.get_var_indices()[i][DISCR[-1]]['t']] = i*(self.ocp.tf-self.ocp.t0)/len(PHASE)
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
        [init_constr] = self.model.get_ode_F0().eval([z])
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
                [Fz] = self.model.get_ode_F().eval([z])
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
        z += [self.vars[0]['t']]
        z += self.vars[PHASE[-1]][DISCR[-1]]['x']
        z += [self.vars[PHASE[-1]]['t']]
        [boundary_constr] = self.model.opt_ode_C.eval([z])
        boundary_constr = list(boundary_constr.data())
        self.h += boundary_constr
        
        #Create boundary constraints (inequality)
        boundary_constr_ineq = []
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += [self.vars[0]['t']]
        z += self.vars[PHASE[-1]][DISCR[-1]]['x']
        z += [self.vars[PHASE[-1]]['t']]
        [boundary_constr_ineq] = self.model.opt_ode_Cineq.eval([z])
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
    
        if self.model.get_opt_J() != None:
            # Assume Mayer cost
            z = []
            t = self.vars[PHASE[-1]]['t']
            z += self.vars[0]['p']
            z += self.vars[PHASE[-1]][DISCR[-1]]['x']
            z += [t]
            [self.cost_mayer] = self.model.get_opt_ode_J().eval([z])
            #self.cost_mayer = list(self.cost_mayer.data())
        #NOTE TEMPORARY!!!!
        #self.cost_mayer=self.vars[PHASE[-1]]['t']
        # Take care of Lagrange cost
        if self.model.get_opt_L() != None:
            for i in PHASE:
                for ind,j in enumerate(COLLO):
                    t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                    z = []
                    z += self.vars[0]['p']
                    z += self.vars[i][j]['x']
                    z += self.vars[i][j]['u']
                    z += [t]
                    self.cost_lagrange += (self.vars[i]['t']-self.vars[i-1]['t'])/2.0*self.model.get_opt_ode_L().eval([z])[0][0]*WEIGH[ind]
          
        self.cost = self.cost_mayer + self.cost_lagrange

        # Objective function
        self.cost_fcn = casadi.SXFunction([self.xx], [[self.cost]])  
        
        # Hessian
        self.sigma = casadi.SX('sigma')
        
        self.lam = []
        self.Lag = self.sigma*self.cost
        for i in range(len(self.h)):
            self.lam.append(casadi.SX('lambda_' + str(i)))
            self.Lag = self.Lag + self.h[i]*self.lam[i]
        for i in range(len(self.g)):
            self.lam.append(casadi.SX('lambda_' + str(i+len(self.h))))
            self.Lag = self.Lag + self.g[i]*self.lam[i+len(self.h)]
            
        self.Lag_fcn = casadi.SXFunction([self.xx, self.lam, [self.sigma]],[[self.Lag]])
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
        
        t0 = self.ocp.t0
        tf = self.ocp.tf
        
        if self.md.get_opt_finaltime_free():
            tf = casadi.SX("tf")
        if self.md.get_opt_starttime_free():
            t0 = casadi.SX("t0")
        
        self.vars[0] = {}
        for i in PHASE: #Phases
            for j in DISCR: #Discretization
                xi = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_x()]
                if j==0:
                    self.vars[i] = {}
                self.vars[i][j] = {}
                self.vars[i][j]['x'] = xi
                    
            for j in COLLO: #Collocation
                ui = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_u()]
                self.vars[i][j]['u'] = ui
        
        
        pi = [casadi.SX(str(x)) for x in self.model.get_p()]
        self.vars[0]['p'] = pi
        
        
        for i in PHASE[:-1]:
            if self.options['free_phases']:
                if self.options['phase_options']:
                    for ind, p in enumerate(self.model.get_p()):
                        if self.options['phase_options'][i-1] == str(p):    
                            self.vars[i]['t'] = self.vars[0]['p'][ind]
                            break
                    else:
                        raise CasADiCollocatorException("Could not find the parameter for the phase bound.")
                else:
                    self.vars[i]['t'] = casadi.SX("t"+str(i))
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
                raise CasADiCollocatorException("Could not find the linking variable, ",all[1], ".")
            if plink == -1:
                raise CasADiCollocatorException("Could not find the linking parameter, ",all[2], ".")
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
        return casadi.SXMatrix(self.h)
    
    def get_inequality_constraint(self):
        return casadi.SXMatrix(self.g)

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
        _p_max = [(p.getValueReference(), p.getMax()) for p in ocp.p_]
        _x_min = md.get_x_min(include_alias = False)
        _u_min = md.get_u_min(include_alias = False)
        _p_min = [(p.getValueReference(), p.getMin()) for p in ocp.p_]
        _x_start = md.get_x_start(include_alias = False)
        #_u_start = md.get_u_start(include_alias = False)
        _u_start = md.get_u_initial_guess(include_alias = False)
        _p_start = []
        for p in ocp.p_: #NOTE SHOULD BE CHANGED
            for p_ori in md.get_p_opt_initial_guess():
                if p.getValueReference() == p_ori[0]:
                    _p_start += [p_ori] 
        #_p_start = [(p.getValueReference(), p.getStart()) for p in ocp.p_]
        
        x_max = self.UPPER*N.ones(len(_x_max))
        u_max = self.UPPER*N.ones(len(_u_max))
        p_max = self.UPPER*N.ones(len(_p_max))
        x_min = self.LOWER*N.ones(len(_x_min))
        u_min = self.LOWER*N.ones(len(_u_min))
        p_min = self.LOWER*N.ones(len(_p_min))
        x_start = self.LOWER*N.ones(len(_x_start))
        u_start = self.LOWER*N.ones(len(_u_start))
        p_start = self.LOWER*N.ones(len(_p_start))
        
        for vr, val in _x_min:
            if val != None:
                x_min[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_max:
            if val != None:
                x_max[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_start:
            if val != None:
                x_start[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]

        for vr, val in _u_min:
            if val != None:
                u_min[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_max:
            if val != None:
                u_max[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_start:
            if val != None:
                u_start[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        
        for vr, val in _p_min:
            if val != None:
                p_min[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        for vr, val in _p_max:
            if val != None:
                p_max[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        for vr, val in _p_start:
            if val != None:
                p_start[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        
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

        if (self.options['free_phases'] and len(PHASE) > 1) and self.md.get_opt_finaltime_free():
            input_t = [self.vars[i]['t'] for i in PHASE]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.nlp_opt[self.var_indices[i][DISCR[-1]]['t']][0] for i in PHASE]
            tfcn.setInput(N.array(input_res).flatten())
        elif (self.options['free_phases'] and len(PHASE) > 1):
            input_t = [self.vars[i]['t'] for i in PHASE[:-1]]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.nlp_opt[self.var_indices[i][DISCR[-1]]['t']][0] for i in PHASE[:-1]]
            tfcn.setInput(N.array(input_res).flatten())
        elif self.md.get_opt_finaltime_free():
            input_t = self.vars[PHASE[-1]]['t']
            tfcn = casadi.SXFunction([[input_t]],[ts])
            tfcn.init()
            tfcn.setInput(self.nlp_opt[self.var_indices[PHASE[-1]][DISCR[-1]]['t']])
        else:
            tfcn = casadi.SXFunction([[]],[ts])
            tfcn.init()
            
        tfcn.evaluate()
        t = N.transpose(N.array([tfcn.output().data()]))
        t_opt = t.flatten()
        
        cnt = 0
        for time,i,j in self.get_time_points():
            #t_opt[cnt] = t
            x_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['x']][:,0]
            
            if j==0 and DISCR[0] != COLLO[0]:
                u_opt[cnt,:] = [sum([lagrange_eval(ROOTS,ind,-1.0)*self.nlp_opt[self.get_var_indices()[i][l]['u']][k,0] for ind,l in enumerate(COLLO)]) for k in range(self.model.get_n_u())]
                dx_coeff = [lagrange_derivative_eval(AROOT,ind,-1.0) for ind in range(len(APPRO))]
                dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([dx_coeff[ind]*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                #dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([lagrange_derivative_eval(AROOT,ind,-1.0)*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                cnt = cnt + 1
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                u_opt[cnt,:] = [sum([lagrange_eval(ROOTS,ind,1.0)*self.nlp_opt[self.get_var_indices()[i][l]['u']][k,0] for ind,l in enumerate(COLLO)]) for k in range(self.model.get_n_u())]
                dx_coeff = [lagrange_derivative_eval(AROOT,ind,1.0) for ind in range(len(APPRO))]
                dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([dx_coeff[ind]*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                #dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([lagrange_derivative_eval(AROOT,ind,1.0)*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                cnt = cnt + 1
                continue
            
            u_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['u']][:,0]
            dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([DIFFM[j-COLLO[0],l]*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for l in APPRO]) for k in range(self.model.get_n_x())]
            cnt = cnt + 1
            
        p_opt[:] = self.nlp_opt[self.get_var_indices()[0][0]['p']][:,0]

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
            t0 = self.ocp.t0
            tf = self.ocp.tf
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

        sc_x = self.model.get_x_sf()
        sc_u = self.model.get_u_sf()

        col_index = 1;
        x_index = 0;
        u_index = 0;
        for name in x_names:
            try:
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x/sc_x[x_index]
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
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0]/sc_u[u_index]
                else:
                    var_data[:,col_index] = traj.x/sc_u[u_index]
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
