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
This file contains code for mapping our JMI Models to the Problem 
specifications required by Assimulo.
"""

import warnings
import numpy as N
import jmodelica.jmi as jmi

try:
    from assimulo.non_linear_problem import NL_Problem
except ImportError:
    warnings.warn('Could not find Assimulo package. Check jmodelica.check_packages()')


class JMIInit_Exception(Exception):
    """
    A JMIModel Exception.
    """
    pass


class JMIInitProblem(NL_Problem):
    
    def __init__(self,model,x0 = None):
        """
        Create an instance of the JMIInitProblem
        
        Parameters:
            model:
                An instance of the instance jmi.model
                
            x0:
                A numpy array containing the initial guess. 
                If not supplied, an initial guess is read from the model.
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
            raise JMIInit_Exception("Model error: nb eqs not equal to nb vars")
        
        # get the data needed for evaluating the jacobian
        self._mask = N.ones(self._model.get_z().size, dtype=N.int32)
        self._ind_vars = [jmi.JMI_DER_W, jmi.JMI_DER_X, jmi.JMI_DER_DX]
        self._ncol, self._nonzeros = self._jmi_model.init_dF0_dim(jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_COL_MAJOR, self._ind_vars, self._mask)
        self._nrow = self._nonzeros / self._ncol
        
        # Get initial guess if supplied, otherwise get it from the model
        if x0 != None:
            self._x0 = x0
        else:
            # Get a x0 from the model
            self._x0 = N.zeros(self._neqF0)
            self._x0[0:self._dx_size] = self._model.get_real_dx()
            self._x0[self._dx_size:self._mark] = self._model.get_real_x()
            self._x0[self._mark:self._neqF0] = self._model.get_real_w()
            

    
    def f(self,input):

        """
        Function used to get the residual of the F0 function in JMI
        Parameters:
            input:
                A numpy array, the vector input for which the residual will be
                evaluated
        """
        inp_size = input.shape[0]
    
        # assume that the first variables are w and the latter are x and dx, slice the input
        dx = input[0:self._dx_size]
        x = input[self._dx_size:self._mark]
        w = input[self._mark:inp_size]
    
        # input the values
        self._model.set_real_dx(dx)
        self._model.set_real_x(x)
        self._model.set_real_w(w)
    
        # get size of residual and return the result
        output = N.zeros(self._neqF0)
        self._jmi_model.init_F0(output)
        return output
    
    def set_x0(self,x0):
        """
        Set the initial guess of the system to x0
        
        Parameters:
            x0:
                A numpy array, the vector x0 is the initial guess for the problem
        
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
        Function used to get the jacobian of the F0 function in JMI
        
        Parameters:
            input:
                A numpy array, the vector input for which the jacobian will be
                evaluated
        """
        inp_size = input.shape[0]
    
        # slice the input
        dx = input[0:self._dx_size]
        x = input[self._dx_size:self._mark]
        w = input[self._mark:inp_size]
    
        # input the values
        self._model.set_real_dx(dx)
        self._model.set_real_x(x)
        self._model.set_real_w(w)
     
        # get the jacobian from the model
        jac = N.zeros(self._nonzeros)
        self._jmi_model.init_dF0(jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_ROW_MAJOR, self._ind_vars, self._mask, jac)
    
        # return output from result
        return N.reshape(jac,(self._nrow,self._ncol))
        