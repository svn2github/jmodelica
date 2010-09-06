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
""" The jfsolver initialization module.
    Written by Johan Ylikiiskilä
"""


from scipy.optimize import fsolve
from numpy import *
import jmodelica.jmi as jmi
from jmodelica.jmi import JMIException
from jmodelica import io


class JFSolver(object):
    """ Class handling the initialization of a DAE using a solver of nl-eqs 
        and the JMIinterface
    """
    
    def __init__(self, model):
        """ Create a solver used to initialize the model
            
        Parameters::
        
            model --
                The model object.
                
        """
        
        print "Initializing JFSolver"
        # get the model and jmimodel, set jacobian usage to model jacobian
        self._model = model
        self._jmi_model = model.jmimodel
        self._use_jac = True
        
        # find the sizes needed
        self._neqF0, self._neqF1, self._neqFp, self._neqr0 = self._jmi_model.init_get_sizes()
        self._dx_size = self._model._n_real_dx.value
        self._x_size = self._model._n_real_x.value
        self._w_size = self._model._n_real_w.value
        self._u_size = self._model._n_real_u.value
        self._mark = self._dx_size + self._x_size
        
        print "Analysis of initialiation problem..."
        print "neq: ", self._neqF0
        print "nvar: ", self._x_size + self._w_size + self._dx_size
        
        if self._neqF0 != (self._x_size + self._w_size + self._dx_size):
            raise JMIException("Initialization Error: nb eqs not equal to nb vars")
            
        # get a guess for solver from the model
        self._x0 = zeros(self._neqF0)
        self._x0[0:self._dx_size] = self._model.get_real_dx()
        self._x0[self._dx_size:self._mark] = self._model.get_real_x()
        self._x0[self._mark:self._neqF0] = self._model.get_real_w()
        
        # get the data needed for evaluating the jacobian
        self._mask = ones(self._model.get_z().size, dtype=int32)
        self._ind_vars = [jmi.JMI_DER_W, jmi.JMI_DER_X, jmi.JMI_DER_DX]
        self._ncol, self._nonzeros = self._jmi_model.init_dF0_dim(jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_COL_MAJOR, self._ind_vars, self._mask)
        self._nrow = self._nonzeros / self._ncol
        
        print "Jacobian dimensions: ", self._ncol, "x", self._nrow
        
    def set_jac_usage(self,use_jac):
        """ Set whether to use the jacobian supplied by the JMIinterface
        or if we are to calculate it numericaly
            
        Parameters::
        
            use_jac --
                Boolean set to True if the jacobian is to be 
                supplied by the JMIinterface
        """
        self._use_jac = use_jac
        
    def initialize(self):
        """ Function that calculates the solution of the F0 = 0
        where F0 is the F0 of the JMIinterface
        
        """
        # call solver
        print "Running JFSolver"
        
        if self._use_jac:
            print "Using model jacobian"
            self._res,self._data,self._flag,self._msg = fsolve(self._wrap_init_F0,self._x0,fprime=self._wrap_init_dF0,full_output=1,col_deriv=1)
        else:
            print "Calculating jacobian in fsolve"
            self._res,self._data,self._flag,self._msg = fsolve(self._wrap_init_F0,self._x0,full_output=1)
        
        # check if a solution is found
        if self._flag != 1:
            raise JMIException("Initialization Error: "+self._msg)
        
        print "Solver data:"
        print "residual: ", self._data['fvec']
        print "nfev:", self._data['nfev']
        if self._use_jac:
            print "njev:", self._data['njev']
        
        
        dx = self._res[0:self._dx_size]
        x = self._res[self._dx_size:self._mark]
        w = self._res[self._mark:self._neqF0]
            
        self._model.set_real_dx(dx)
        self._model.set_real_x(x)
        self._model.set_real_w(w)
            
    def export_result_dymola(self, file_name='', format='txt'):
        """ Export the initialization result in Dymola format. 

        Parameters::
        
            file_name --
                Name of the result file.
            format --
                A string equal either to 'txt' for output to Dymola 
                textual format or 'mat' for output to Dymola binary 
                Matlab format.

        Limitations::
        
            Only format='txt' is currently supported.
        """

        # Create data matrix
        data = zeros((1,1+self._dx_size+ \
                        self._x_size + \
                        self._u_size + \
                        self._w_size))
        data[0,:] = self._model.get_t()
        data[0,1:1+self._dx_size] = self._model.get_real_dx()
        data[0,1+self._dx_size:1+self._dx_size + self._x_size] = self._model.get_real_x()
        data[0,1+self._dx_size + self._x_size:1+self._dx_size + self._x_size + self._u_size] = self._model.get_real_u()
        data[0,1+self._dx_size + self._x_size + self._u_size: \
             1+self._dx_size + self._x_size + \
             self._u_size + self._w_size] = self._model.get_real_w()
                        
        # Write result
        io.export_result_dymola(self._model,data, file_name=file_name, format=format)

        
    def _wrap_init_F0(self,input):
        """ Function used to get the residual of the F0 function for 
        fsolve.
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
        output = zeros(self._neqF0)
        self._jmi_model.init_F0(output)
        return output

    def _wrap_init_dF0(self,input):
        """ Function used to get the jacobian of the F0 function for 
        fsolve.
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
        jac = zeros(self._nonzeros)
        self._jmi_model.init_dF0(jmi.JMI_DER_CPPAD, jmi.JMI_DER_DENSE_COL_MAJOR, self._ind_vars, self._mask, jac)
    
        # return output from result
        return reshape(jac,(self._nrow,self._ncol))
        

