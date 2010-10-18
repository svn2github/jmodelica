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
This file contains code for mapping our JMI Models to the Problem specifications 
required by Assimulo.
"""
import logging

import numpy as N

import jmodelica.jmi as jmi
import jmodelica.io as io

try:
    from assimulo.problem_algebraic import ProblemAlgebraic
except ImportError:
    logging.warning(
        'Could not find Assimulo package. Check jmodelica.check_packages()')


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
    
    def __init__(self,model,x0 = None,constraints=None,use_constraints=False):
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
        
        # find the sizes needed
        self._neqF0, self._neqF1, self._neqFp, self._neqr0 = self._jmi_model.init_get_sizes()
        self._dx_size = self._model._n_real_dx.value
        self._x_size = self._model._n_real_x.value
        self._w_size = self._model._n_real_w.value
        self._u_size = self._model._n_real_u.value
        self._mark = self._dx_size + self._x_size
        
        print "Analysis of initialization problem..."
        print "neq: ", self._neqF0
        print "nvar: ", self._x_size + self._w_size + self._dx_size
        
        if self._neqF0 != (self._x_size + self._w_size + self._dx_size):
            raise JMUAlgebraic_Exception("Model error: nb eqs not equal to nb vars")
        
        # get the data needed for evaluating the jacobian
        self._mask = N.ones(self._model.z.size, dtype=N.int32)
        self._ind_vars = [jmi.JMI_DER_W, jmi.JMI_DER_X, jmi.JMI_DER_DX]
        self._ncol, self._nonzeros = self._jmi_model.init_dF0_dim(
            jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_COL_MAJOR, self._ind_vars, self._mask)
        self._nrow = self._nonzeros / self._ncol
        
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
        self.constraints = constraints
        self.use_constraints = use_constraints
    
    def f(self,input):
        """
        Function used to get the residual of the F0 function in JMI
        
        Parameters::
        
            input --
                A numpy array, the vector input for which the residual will be
                evaluated.
        """
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
        return N.reshape(jac,(self._nrow,self._ncol))
    
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
        if constraints != None:
            if type(constraints).__name__ != 'ndarray':
                raise JMUAlgebraic_Exception(
                    "Constraints must be an numpy.ndarray")
        
        self.use_constraints = use_const
        self.constraints = constraints
        
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
        Fct used to guess the constraints based on the initial guesses of a 
        model.
        """
        res = N.zeros(self._neqF0)
        for i in N.arange(self._dx_size,self._mark):
            if self._x0[i] < 0:
                res[i] = -2.0
            elif self._x0[i] > 0:
                res[i] = 2.0
            else:
                res[i] = 0.0
                
        return res
        
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
    io.export_result_dymola(model,data, file_name=file_name, format=format)
