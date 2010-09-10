#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2009 Modelon AB
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
"""Module containing base classes."""


class BaseModel(object):
    """ Abstract base class for JMUModel and FMUModel."""
    
    def __init__(self):
        raise Exception("This is an abstract class it can not be instantiated.")
    
    def optimize(self):
        raise NotImplementedError('This method is currently not supported.')
                               
    def simulate(self):
        raise NotImplementedError('This method is currently not supported.')
    
    def initialize(self):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_real(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_real(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_integer(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_integer(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_boolean(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_boolean(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set_string(self, valueref, value):
        raise NotImplementedError('This method is currently not supported.')                           
    
    def get_string(self, valueref):
        raise NotImplementedError('This method is currently not supported.')
    
    def set(self, variable_name, value):
        """
        Sets the given value(s) to the specified variable name(s)
        into the model. The method both accept a single variable 
        and a list of variables.
        
        Parameters::
            
            variable_name  - The name of the variable(s) as string/list
            value          - The value(s) to set.
            
        Example::
        
            (FMU/JMU)Model.set('damper.d', 1.1)
            (FMU/JMU)Model.set(['damper.d','gear.a'], [1.1, 10])
        """
        if isinstance(variable_name, str):
            self._set(variable_name, value) #Scalar case
        else:
            for i in xrange(len(variable_name)): #A list of variables
                self._set(variable_name[i], value[i])
    
    def get(self, variable_name):
        """
        Returns the value(s) of the specified variable(s). The
        method both accept a single variable and a list of variables.
        
            Parameters::
                
                variable_name - The name of the variable(s) as string/list.
                
            Returns::
            
                The value(s).
                
            Example::
            
                (FMU/JMU)Model.get('damper.d') #Returns the variable d
                (FMU/JMU)Model.get(['damper.d','gear.a']) #Returns a list of the variables
        """
        if isinstance(variable_name, str):
            return self._get(variable_name) #Scalar case
        else:
            ret = []
            for i in xrange(len(variable_name)): #A list of variables
                ret += self._get(variable_name[i])
    
    def _exec_algorithm(self,
                 algorithm, 
                 alg_args, 
                 solver_args):
        """ Helper function which performs all steps of an algorithm run 
        which are common to all algortihms.
        
        Throws exception if algorithm is not a subclass of 
        algorithm_drivers.AlgorithmBase.
        """
        base_path = 'jmodelica.algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'algorithm_drivers')
        AlgorithmBase = getattr(algdrive, 'AlgorithmBase')
        
        if isinstance(algorithm, str):
            algorithm = getattr(algdrive, algorithm)
        
        if not issubclass(algorithm, AlgorithmBase):
            raise Exception(str(algorithm)+
            " must be a subclass of jmodelica.algorithm_drivers.AlgorithmBase")

        # initialize algorithm
        alg = algorithm(self, alg_args)
        # set arguments to solver, if any
        alg.set_solver_options(solver_args)
        # solve optimization problem/simulate
        alg.solve()
        # get and return result
        return alg.get_result()
