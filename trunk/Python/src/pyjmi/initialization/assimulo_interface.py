#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""
This file contains code for mapping our JMU Models to the Problem specifications 
required by Assimulo.
"""
import logging

import numpy as N
import scipy.sparse as ss

import time

import pyjmi.jmi as jmi
from pyjmi.jmi_io import export_result_dymola

try:
    from assimulo.problem_algebraic import ProblemAlgebraic
except ImportError:
    logging.warning(
        'Could not find Assimulo package. Check pyjmi.check_packages()')


class JMUAlgebraic_Exception(Exception):
    """
    A JMUAlgebraic problem Exception.
    """
    pass

class JMUAlgebraic(ProblemAlgebraic):
    """
    Class derived from ProblemAlgebraic.
    The purpose of this problem class is to ne used as an interface between a 
    JMUmodel and the kinsol.py wrapper around the KINSOL solver from the 
    SUNDIALS package.
    """
    
    def __init__(self,model,x0 = None,use_jac=True):
        """
        Create an instance of the JMIInitProblem
        
        Parameters::
        
            model --
                An instance of the instance jmi.JMUModel.
                
            x0 --
                A numpy array containing the initial guess. If not supplied, an 
                initial guess is read from the model.
        """
        
        # Read the model
        self._model = model
        self._jmi_model = model.jmimodel
        self._use_jac = use_jac
        
        # get offsets to the initialization variables
        offsets = self._model.get_offsets()
        self.dx_offset = offsets[12]
        self.x_offset = offsets[13]
        self.w_offset = offsets[15]
        
        # find the sizes needed
        self._neqF0, self._neqF1, self._neqFp, self._neqr0 = self._jmi_model.init_get_sizes()
        self._dx_size = self._model._n_real_dx.value
        self._x_size = self._model._n_real_x.value
        self._w_size = self._model._n_real_w.value
        self._u_size = self._model._n_real_u.value
        self._mark = self._dx_size + self._x_size
        
        #print "Analysis of initialization problem..."
        #print "neq: ", self._neqF0
        #print "nvar: ", self._x_size + self._w_size + self._dx_size
        
        if self._neqF0 != (self._x_size + self._w_size + self._dx_size):
            raise JMUAlgebraic_Exception("Model error: nb eqs not equal to nb vars")
        
        # This makes sure that the jmi interface is not called if the user has specified
        # that a numerical Jacobian is to be used, 
        if self._use_jac :
            # get the data needed for evaluating the jacobian
            self._mask = N.ones(self._model.z.size, dtype=N.int32)
            self._ind_vars = [jmi.JMI_DER_W, jmi.JMI_DER_X, jmi.JMI_DER_DX]
            self._ncol, self._nonzeros = self._jmi_model.init_dF0_dim(
                jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_COL_MAJOR, self._ind_vars, self._mask)
            self._nrow = self._nonzeros / self._ncol
        
            # get sparse data
            self.sparse_ncol, self.sparse_nonzeros = self._jmi_model.init_dF0_dim(
                jmi.JMI_DER_CPPAD, jmi.JMI_DER_SPARSE, self._ind_vars, self._mask)

            self.rows = N.zeros(self.sparse_nonzeros,dtype = N.int32)
            self.cols = N.zeros(self.sparse_nonzeros,dtype = N.int32)
            self._jmi_model.init_dF0_nz_indices(jmi.JMI_DER_CPPAD, self._ind_vars, self._mask, self.rows, self.cols)
        
        
        # Get initial guess if supplied, otherwise get it from the model
        if x0 != None:
            self._x0 = x0
        else:
            # Get a x0 from the model
            self._x0 = N.zeros(self._neqF0)
            self._x0[0:self._dx_size] = self._model.real_dx
            self._x0[self._dx_size:self._mark] = self._model.real_x
            self._x0[self._mark:self._neqF0] = self._model.real_w
        
        # Set constraints settings
        self.constraints = None
        self.use_constraints = False
        self.set_constraints_usage(self.use_constraints,self.constraints)
        
        # initialize timers
        self.time_f = 0
        self.time_jac_de = 0
        self.time_jac_sp = 0
        
    
    def f(self,input):
        """
        Function used to get the residual of the F0 function in JMI
        
        Parameters::
        
            input --
                A numpy array, the vector input for which the residual will be
                evaluated.
        """
        start = time.clock()
        inp_size = input.shape[0]
    
        # assume that the first variables are w and the latter are x and dx, slice the input
        dx = input[0:self._dx_size]
        x = input[self._dx_size:self._mark]
        w = input[self._mark:inp_size]
    
        # input the values
        self._model.real_dx = dx
        self._model.real_x = x
        self._model.real_w = w
    
        # get size of residual and return the result
        output = N.zeros(self._neqF0)
        self._jmi_model.init_F0(output)
        #print "RHS in assimulo_interface:"
        #print output
        stop = time.clock()
        
        self.time_f += (stop-start)
        #print output
        return output
    
    def set_x0(self,x0):
        """
        Set the initial guess of the system to x0.
        
        Parameters::
        
            x0 --
                A numpy array, the vector x0 is the initial guess for the 
                problem.
        """
        self._x0 = x0
        
    def get_heuristic_x0(self):
        """
        If present, return the initial guess with an heuristic applied:
        All variables with initial guesses set to 0.0 and at the same time
        has the constraint to be => zero are set to 1.0.
        
        Parameters:
            None
        """
        if self.constraints != None:
            x = N.zeros(self._neqF0)
            for i in N.arange(0,self._neqF0):
                if self._x0[i] == 0.0 and (self.constraints[i] == 1.0 or self.constraints[i] == 2.0):
                    x[i] = 1.0
                    self._print_var_info(i)
                elif self._x0[i] == 0.0 and (self.constraints[i] == -1.0 or self.constraints[i] == -2.0):
                    x[i] = -1.0
                    self._print_var_info(i)
                else:
                    x[i] = self._x0[i]
        
            return x
        else:
            return self._x0
        
    def _print_var_info(self,i):
        
        dx_min = self._model._xmldoc.get_dx_min()
        dx_names = self._model.get_dx_variable_names()
        
        x_min = self._model._xmldoc.get_x_min()
        x_names = self._model.get_x_variable_names()
        
        w_min = self._model._xmldoc.get_w_min()
        w_names = self._model.get_w_variable_names()
        
        
        if i < self._dx_size:
            print "der(state): ",dx_names[i][1]
        elif i < self._mark:
            print "state: ",x_names[i-self._dx_size][1]
        else:
            print "algebraic: ",w_names[i-self._mark][1]
            
    def get_x0(self):
        """
        If present, return the initial guess
        
        Parameters:
            None
        """
        
        return self._x0
        
    def jac(self,input):
        """
        Function used to get the jacobian of the F0 function in JMI.
        
        Parameters::
        
            input --
                A numpy array, the vector input for which the jacobian will be
                evaluated.
        """
        if not self._use_jac:
			raise JMUAlgebraic_Exception("JMI jacobian functions called although the KINSOL option use_jac is set to false, aborting initialization.")
			
        start = time.clock()
        inp_size = input.shape[0]
    
        # slice the input
        dx = input[0:self._dx_size]
        x = input[self._dx_size:self._mark]
        w = input[self._mark:inp_size]
    
        # input the values
        self._model.real_dx = dx
        self._model.real_x = x
        self._model.real_w = w
     
        # get the jacobian from the model
        jac = N.zeros(self._nonzeros)
        self._jmi_model.init_dF0(jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_ROW_MAJOR, 
            self._ind_vars, self._mask, jac)
    
        # return output from result 
        stop = time.clock()
        self.time_jac_de += (stop - start)
        
        return N.reshape(jac,(self._nrow,self._ncol))
    
    def sparse_jac(self,input):
        """
        Function used to get the jacobian of the F0 function in JMI.
        It will be returned as a sparse matrix in triplet, or coordinate, format.
        
        Parameters::
        
            input --
                A numpy array, the vector input for which the jacobian will be
                evaluated.
        """
        if not self._use_jac:
			raise JMUAlgebraic_Exception("JMI jacobian functions called although the KINSOL option use_jac is set to false, aborting initialization.")
        start = time.clock()
        
        inp_size = input.shape[0]
    
        # slice the input
        dx = input[0:self._dx_size]
        x = input[self._dx_size:self._mark]
        w = input[self._mark:inp_size]
    
        # input the values
        self._model.real_dx = dx
        self._model.real_x = x
        self._model.real_w = w
        
        # get the jacobian from the model
        val = N.zeros(self.sparse_nonzeros)
        self._jmi_model.init_dF0(jmi.JMI_DER_CPPAD, jmi.JMI_DER_SPARSE, 
            self._ind_vars, self._mask, val)
        
        res = ss.coo_matrix((val,(self.rows-1,self.cols-1)),shape=(self.sparse_ncol,self.sparse_ncol)).tocsc()
        stop = time.clock()
        self.time_jac_sp += (stop - start)
        return res

    def set_constraints_usage(self,use_const,constraints = None):
        """ 
        Set whether to use constraints or not. If constraints are supplied they 
        will be applied (if use_const = True) otherwise constraints will be
        guessed.
            
        Parameters::
        
            use_const --
                Boolean set to True if constraints are to be used at all.
                
            constraints --
                If supplied these will be used. The constraints should be a 
                numpy array of size len(x0) with the following number in the ith 
                position.
                0.0  - no constraint on x[i]
                1.0  - x[i] greater or equal than 0.0
                -1.0 - x[i] lesser or equal than 0.0
                2.0  - x[i] greater  than 0.0
                -2.0 - x[i] lesser than 0.0
                Default: None
        """
        # check for bad input
        if type(use_const).__name__ != 'bool':
            raise JMUAlgebraic_Exception(
                "First argument sent to 'set_constraint_usage' must be a boolean.")
            
        self.use_constraints = use_const
        
        if constraints != None:
            if type(constraints).__name__ != 'ndarray':
                raise JMUAlgebraic_Exception(
                    "Constraints must be an numpy.ndarray")
                
            self.constraints = constraints
        elif self.use_constraints:
            # No constraints supplied but const == True, do the guess
            self.constraints = self._guess_constraints()
            
        else:
            self.constraints = None
        
        
        
    def get_constraints(self):
        """
        Function that returns the users constraints if there are any, no 
        constraints if the option self.no_constraints is set to True. Otherwise 
        the assimulo_interface will try to calculate reasonable constraints.
        
        Returns::
        
            A numpy array, size len(_x0) containing
            the constraints, if constraint[i] is:
                0.0  - no constraint on x[i]
                1.0  - x[i] greater or equal than 0.0
                -1.0 - x[i] lesser or equal than 0.0
                2.0  - x[i] greater  than 0.0
                -2.0 - x[i] lesser than 0.0
        """
        if self.use_constraints:
            if self.constraints != None:
                return self.constraints
            else:
                return self._guess_constraints()
        else:
            return None
        
    def _guess_constraints(self):
        """
        Fct used to guess the constraints based on the min and max values of the model.
        """
        # get min and maxes from the model
        
        dx_min = self._model._xmldoc.get_dx_min()
        dx_max = self._model._xmldoc.get_dx_max()
        
        x_min = self._model._xmldoc.get_x_min()
        x_max = self._model._xmldoc.get_x_max()
        
        w_min = self._model._xmldoc.get_w_min()
        w_max = self._model._xmldoc.get_w_max()
        
        rvars = self._model._xmldoc.get_all_real_variables(include_alias = False)
        w_off = self.w_offset - self._dx_size - self._x_size
        x_off = self.x_offset - self._dx_size
        dx_off = self.dx_offset
        # Create constraint vector with default being no constraint
        res = N.zeros(self._neqF0)

        for var in rvars:
            cat = var.get_variable_category()
            if (cat == 0) or (cat == 1) or (cat == 6):
                if cat == 0:
                    # algebraic variable
                    offset = w_off
                    
                elif cat == 1:
                    # state
                    offset = x_off
                    
                elif cat == 6:
                    # derivative
                    offset = dx_off

                
                type = var.get_fundamental_type()
                ref = var.get_value_reference()
                min = type.get_min()
                max = type.get_max()
                #print "Ref: ",ref, "min: ", min, "max: ", max, "Name: ", var.get_name()
                ref = ref - offset
                if min != None:
                    if max != None:
                        # Max and min
                        if min >= 0.0:
                            res[ref] = 1.0
                        if max <= 0.0:
                            res[ref] = -1.0
                    else:
                        # only min
                        if min >= 0.0:
                            res[ref] = 1.0
                
                elif max != None:
                    # only max
                    if max <= 0.0:
                        res[ref] = -1.0
        
        return res
    
    def get_times(self):
        """
        Method returning the times spent evaluating
        - the residual
        - the Dense Jacobian
        - the Sparse Jacobian
        """
        
        return dict([("f",self.time_f),("J_d",self.time_jac_de),("J_s",self.time_jac_sp)])
    
    def print_var_info(self,i):
        """
        Method printing info on variable at position i
        """
        
        dx_min = self._model._xmldoc.get_dx_min(include_alias=False)
        dx_max = self._model._xmldoc.get_dx_max(include_alias=False)
        dx_names = self._model.get_dx_variable_names(include_alias=False)
        
        x_min = self._model._xmldoc.get_x_min(include_alias=False)
        x_max = self._model._xmldoc.get_x_max(include_alias=False)
        x_names = self._model.get_x_variable_names(include_alias=False)
        
        w_min = self._model._xmldoc.get_w_min(include_alias=False)
        w_max = self._model._xmldoc.get_w_max(include_alias=False)
        w_names = self._model.get_w_variable_names(include_alias=False)
        
        dx_min.sort()
        dx_max.sort()
        dx_names.sort()
        
        x_min.sort()
        x_max.sort()
        x_names.sort()
        
        w_min.sort()
        w_max.sort()
        w_names.sort()

        if i < self._dx_size:			
            print "der(state): ",dx_names[i][1]," = ", self._model.real_dx[i]
            if dx_min[i][1] != None:
                print "with min: ", dx_min[i][1]
            if dx_max[i][1] != None:
                print "with max: ", dx_max[i][1]
            if self.constraints[i] < 0.0:
                print "initially constrained to be negative"
            elif self.constraints[i] > 0.0:
                print "initially constrained to be positive"
            else:
                print "not constrained initially"
        elif i < self._mark:
            print "state: ",x_names[i-self._dx_size][1]," = ", self._model.real_x[i - self._dx_size]
            if x_min[i-self._dx_size][1] != None:
                print "with min: ", x_min[i-self._dx_size][1]
            if x_max[i-self._dx_size][1] != None:
                print "with max: ", x_max[i-self._dx_size][1]
            if self.constraints[i] < 0.0:
                print "initially constrained to be negative"
            elif self.constraints[i] > 0.0:
                print "initially constrained to be positive"
            else:
                print "not constrained initially"
        else:
            print "algebraic variaable: ",w_names[i-self._mark][1]," = ", self._model.real_w[i-self._mark]
            if w_min[i-self._mark][1] != None:
                print "with min: ", w_min[i-self._mark][1]
            if w_max[i-self._mark][1] != None:
                print "with max: ", w_max[i-self._mark][1]
            if self.constraints[i] < 0.0:
                print "initially constrained to be negative"
            elif self.constraints[i] > 0.0:
                print "initially constrained to be positive"
            else:
                print "not constrained initially"
            
    
    def check_constraints(self,to_check):
        """
        Method used to check if the array sent in to_check
        does or does not break the constraints of the model.
        """
        dx_min = self._model._xmldoc.get_dx_min()
        dx_max = self._model._xmldoc.get_dx_max()
        
        x_min = self._model._xmldoc.get_x_min()
        x_max = self._model._xmldoc.get_x_max()
        
        w_min = self._model._xmldoc.get_w_min()
        w_max = self._model._xmldoc.get_w_max()
        
        rvars = self._model._xmldoc.get_all_real_variables(include_alias = False)
        w_off = self.w_offset - self._dx_size - self._x_size
        x_off = self.x_offset - self._dx_size
        dx_off = self.dx_offset
        
        OK = True
        minerrors = []
        maxerrors = []
        
        # Check all variables
        for var in rvars:
            cat = var.get_variable_category()
            if (cat == 0) or (cat == 1) or (cat == 6):
                if cat == 0:
                    # algebraic variable
                    offset = w_off
                    
                elif cat == 1:
                    # state
                    offset = x_off
                    
                elif cat == 6:
                    # derivative
                    offset = dx_off

                
                type = var.get_fundamental_type()
                ref = var.get_value_reference()
                min = type.get_min()
                max = type.get_max()
                name = var.get_name()
                ref = ref - offset
                #print "Value: ",to_check[ref], "min: ", min, "max: ", max, "Name: ", var.get_name()
                
                if min != None:
                    if to_check[ref] < min:
                        OK = False
                        minerrors.append((ref,(min,name)))
                    
                if max != None:
                    if to_check[ref] > max:
                        OK = False
                        maxerrors.append((ref,(max,name)))
                    
        
        # Handle result
        if OK:
            pass
        else:
            print "Result breaks model constraints!"
            if minerrors != []:
                print "min broken at: "
                for err in minerrors:
                    print "variable: ",err[1][1],":", to_check[err[0]], "<", err[1][0], "with min: ",err[1][0]
                   
                
            if maxerrors != []:
                print "max broken at: "
                for err in maxerrors:
                    print "variable: ",err[1][1],":", to_check[err[0]], ">", err[1][0], "with max: ",err[1][0]
                    
        
def write_resdata(problem, file_name='', format='txt'):
    """
    Function that prints out results from a solved problem.
    
    Parameters::
        
        problem--
            Instance of JMUAlgebraic, must be solved.
        
        file_name --
            Name of the result file.
            Default: ''
        
        format --
            A string equal either to 'txt' for output to Dymola textual format 
            or 'mat' for output to Dymola binary Matlab format.
            Default: 'txt'

        Limitations::
        
            Only format='txt' is currently supported.
    """
    if not isinstance(problem, JMUAlgebraic):
        raise JMUAlgebraic_Exception(
            "Problem sent to write_resdata is not an instance of JMUAlgebraic")
    
    model = problem._model
    dx_s = problem._dx_size
    x_s = problem._x_size
    w_s = problem._w_size
    u_s = problem._u_size
    
    # Create data matrix
    data = N.zeros((1,1+dx_s+ \
                    x_s + \
                    u_s + \
                    w_s))
    data[0,:] = model.t
    data[0,1:1+dx_s] = model.real_dx
    data[0,1+dx_s:1+dx_s + x_s] = model.real_x
    data[0,1+dx_s + x_s:1+dx_s + x_s + u_s] = model.real_u
    data[0,1+dx_s + x_s + u_s: \
             1+dx_s + x_s + \
             u_s + w_s] = model.real_w
                        
    # Write result
    export_result_dymola(model,data, file_name=file_name, format=format)
