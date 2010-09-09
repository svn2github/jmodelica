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
from assimulo.kinsol import KINSOL
from numpy import *
import jmodelica.jmi as jmi
from jmodelica.jmi import JMIException
from jmodelica import io

from assimulo_interface import JMIInitProblem
from assimulo_interface import JMIInit_Exception


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
        
        # get model and create problem
        self._model = model
        self._problem = JMIInitProblem(model)
        
        # create KINSOL solver
        self._solver = KINSOL()
        
        # find the sizes needed from model (used in export_result_dymola)
        self._neqF0, self._neqF1, self._neqFp, self._neqr0 = model.jmimodel.init_get_sizes()
        self._dx_size = self._model._n_real_dx.value
        self._x_size = self._model._n_real_x.value
        self._w_size = self._model._n_real_w.value
        self._u_size = self._model._n_real_u.value
        self._mark = self._dx_size + self._x_size
        
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
        self._res = self._solver.solve(self._problem)

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


