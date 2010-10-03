#!/usr/bin/env python 
# -*- coding: utf-8 -*-
""" Module for optimization, simulation and initialization algorithms to be 
used together with jmodelica.jmi.JMUModel.optimize, 
jmodelica.jmi.JMUModel.simulate, jmodelica.fmi.FMUModel.simulate and 
jmodelica.jmi.JMUModel.initialize respectively.
"""

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

#from abc import ABCMeta, abstractmethod
import logging
import numpy as N

import jmodelica
from jmodelica.io import ResultDymolaTextual
from jmodelica.optimization import ipopt
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer
from jmodelica.initialization.kinitsol import KInitSolver

try:
    from jmodelica.simulation.assimulo_interface import JMIDAE, JMIODE, FMIODE, write_data
    from jmodelica.simulation.assimulo_interface import TrajectoryLinearInterpolation
    from assimulo.implicit_ode import *
    from assimulo.explicit_ode import *
    from assimulo import implicit_ode as impl_ode
    from assimulo import explicit_ode as expl_ode

    assimulo_present = True
except:
    logging.warning('Could not load Assimulo module. Check jmodelica.check_packages()')
    assimulo_present = False

try:
    ipopt_present = jmodelica.environ['IPOPT_HOME']
except:
    ipopt_present = False

default_int = int
int = N.int32
N.int = N.int32

class AlgorithmBase(object):
    """ Abstract class which all algorithms that are to be used with 
        jmodelica.jmi.JMUModel.optimize, jmodelica.jmi.JMUModel.simulate, 
        jmodelica.fmi.FMUModel.simulate or jmodelica.jmi.JMUModel.initialize 
        must implement.
    """
#    __metaclass__=ABCMeta
    
#    @abstractmethod
    def __init__(self, model, alg_args): pass
    
#    @abstractmethod
    def solve(self): pass
    
#   @abstractmethod
    def get_result(self): pass
    
    @classmethod
    def get_default_options(self): pass
    
class ResultBase(object):
    """ Base class for an algorithm result. All algorithms used in any 
        of the high-level functions should return an object which extends 
        this class.
    """
    
    def __init__(self, model=None, result_file_name=None, solver=None, 
        result_data=None, options=None):
        """ Create a result object containing the model used in the 
        algorithm, the name of the result file, the solver used in the 
        algorithm, the result data object and the object (dict) holding 
        the options used in the algorithm run.
                       
        Parameters::
        
            model -- 
                The jmi.JMUModel object for the model used in the 
                algorithm.
            result_file_name --
                Name of the file containing the algorithm result created
                on the file system.
            solver --
                The solver object used in the algorithm.
            result_data --
                The result data object created when running the 
                algorithm. Holds the whole result data matrix.
            options --
                The options object with the options that the algorithm 
                was run with.
        """
        self._model = model
        self._result_file_name = result_file_name
        self._solver = solver
        self._result_data = result_data
        self._options = options
    
    def _get_model(self):
        """ Get the model object representing the model that was 
        used in the algorithm.
        
        Returns::
        
            The model object that was used in the algorithm.
        """
        if self._model != None:
            return self._model
        raise Exception("model has not been set")
        
    def _set_model(self, model):
        """ Set the model that was used in the algorithm.
        
        Parameters::
        
            model --
                The model object that was used in the algorithm.
        """
        self._model = model
        
    model = property(fget=_get_model, fset=_set_model)
        
    def _get_result_file(self):
        """ Get the name of the result file created on the file system.
        
        Returns::
        
            The name of the result file.
        """
        if self._result_file_name != None:
            return self._result_file_name
        raise Exception("result file name has not been set")
    
    def _set_result_file(self, file_name):
        """ Set the name of the result file created in the algorithm.
        
        Parameters::
        
            file_name --
                The name of the result file.
            
        """
        self._result_file_name = result_file_name
        
    result_file = property(fget=_get_result_file, fset=_set_result_file)
        
    def _get_solver(self):
        """ Get the solver object repesenting the solver that was used 
        in the algorithm.
        
        Returns::
        
            The solver object that was used in the algorithm.
        """
        if self._solver != None:
            return self._solver
        raise Exception("solver has not been set")

    def _set_solver(self, solver):
        """ Set the solver that was used in the algorithm.
        
        Parameters::
        
            solver --
                The solver that was used in the algorithm.
        """
        self._solver = solver
        
    solver = property(fget=_get_solver, fset=_set_solver)
        
    def _get_result_data(self):
        """ Get the result data matrix created in the algorithm.
        
        Returns::
        
            The result data matrix.
        """
        if self._result_data != None:
            return self._result_data
        raise Exception("result data has not been set")
        
    def _set_result_data(self, result_data):
        """ Set the result data matrix that was created in the algorithm.
        
        Parameters::
        
            result_data --
                The result data matrix.
        """
        self._result_data = result_data
        
    result_data = property(fget=_get_result_data, fset=_set_result_data)
    
    def _get_options(self):
        """ Get the options object holding the options used in the 
        algorithm.
        
        Returns::
        
            The options object.
        """
        if self._options != None:
            return self._options
        raise Exception("options has not been set")
        
    def _set_options(self, options):
        """ Set the options object holding the options used in the 
        algorithm.
        
        Parameters::
        
            options --
                The options object.
        """
        self._options = options
        
    options = property(fget=_get_options, fset=_set_options)

class JMResultBase(ResultBase):
    def __getitem__(self, key):
        val = self.result_data.get_variable_data(key)

        if self.is_variable(key):
            return val.x
        else:
            variability = self.model.get_variability(key)
            if variability == 1 or variability == 2: #Variable is a parameter or constant
                return val.x[0]
            else:
                time = self.result_data.get_variable_data('time')
                return N.array([val.x[0]]*N.size(time.t))
                
        #return self.result_data.get_variable_data(key)

    def is_variable(self, name):
        """
        Returns True if the given name corresponds to a time-varying
        variable.
        
            Parameters::
            
                name --
                    Name of the variable/parameter/constant
                
            Returns::
            
                True if the variable is time-varying.
        """
        return self.result_data.is_variable(name)
    
    def is_negated(self, name):
        """
        Returns True if the given name corresponds to a negated result
        vector.
        
            Parameters::
            
                name --
                    Name of the variable/parameter/constant
                
            Returns::
            
                True if the result should be negated
        """
        return self.result_data.is_negated(name)
    
    def _get_data_matrix(self):
        """
        Returns the result matrix.
                
            Returns::
            
                The result data matrix.
        """
        return self.result_data.get_data_matrix()
        
    data_matrix = property(fget=_get_data_matrix)

    def get_column(self, name):
        """
        Returns the column number in the data matrix where the values
        of the variable are stored.
        
        Parameters::
        
            name --
                Name of the variable/parameter/constant
            
        Returns::
        
            The column number.
        """
        return self.result_data.get_column(name)

class OptionBase(dict):
    """ Base class for an algorithm option class. 
    
    All algorithm option classes should extend this class. 
    
    This class extends the dict class overriding __init__, __setitem__, 
    update and setdefault methods with the purpose of offering a key 
    check for the extending classes.
    
    The extending class can define a set of keys and default values by 
    overriding __init__ or when instantiating the extended class and 
    thereby not allow any other keys to be added to the dict.
    
     * Example overriding __init__:
    
    class MyOptionsClass(OptionBase):
        def __init__(self, *args, **kw):
            mydefaults = {'def1':1, 'def2':2}
            super(MyOptionsClass,self).__init__(mydefaults)
        
            self.update(*args, **kw)
            
    >> opts = MyOptionsClass()
    >> opts['def1'] = 3   // ok
    >> opts.update({'def2':4})   // ok
    >> opts['def3']= 5   // not ok
    
            
     * Example setting defaults in constructor:
     
     class MyOptionsClass(OptionBase):pass
     
    >> opts = MyOptionsClass(def1=1, def2=2)
    >> opts['def1'] = 3   // ok
    >> opts.update({'def2':4})   // ok
    >> opts['def3']= 5   // not ok
    
    >> opts2 = MyOptionsClass()   // this class has no restrictions on keys
    >> opts2['def5'] = 'hello'   //ok
    """
    
    def __init__(self, *args, **kw):
        # create dict
        super(OptionBase,self).__init__(*args, **kw)
        # save keys - these are now the set of allowed keys
        self._keys = super(OptionBase,self).keys()

    def __setitem__(self, key, value):
        if self._keys:
            if not key in self._keys:
                raise UnrecognizedOptionError("The key: %s, is not a valid algorithm option" %str(key))
            
        super(OptionBase,self).__setitem__(key, value)
    
    def update(self, *args, **kw):
        if args:
            if len(args) > 1:
                raise TypeError("update expected at most 1 arguments, got %d" % len(args))
            other = dict(args[0])
            for key in other:
                self[key] = other[key]
        for key in kw:
            self[key] = kw[key]

    def setdefault(self, key, value=None):
        if key not in self:
            self[key] = value
        return self[key]
        
    def _update_keep_dict_defaults(self, *args, **kw):
        """ Go through args/kw and for each value in a key-value-set 
        that is a dict - update the current dict with the new dict (don't 
        overwrite).
        """
        if args:
            if len(args) > 1:
                raise TypeError("update expected at most 1 arguments, got %d" % len(args))
            other = dict(args[0])
            for key in other:
                if not key in self._keys:
                    raise UnrecognizedOptionError("The key: %s, is not a valid algorithm option" %str(key))
                if isinstance(self[key], dict):
                    self[key].update(other[key])
                else:
                    self[key] = other[key]
            
        for key in kw:
            if not key in self._keys:
                raise UnrecognizedOptionError("The key: %s, is not a valid algorithm option" %str(key))
            if isinstance(self[key], dict):
                self[key].update(kw[key])
            else:
                self[key] = kw[key]
        
    #def _update_dict_values(self, *args, **kw):
        #""" Go through args/kw and for each value in a key-value-set 
        #that is a dict - update the current dict with the new dict (don't 
        #overwrite).
        #"""
        #if args:
            #if len(args) > 1:
                #raise TypeError("update expected at most 1 arguments, got %d" % len(args))
            #other = dict(args[0])
            #for key in other:
                #if not key in self._keys:
                    #raise UnrecognizedOptionError("The key: %s, is not a valid algorithm option" %str(key))
                #if isinstance(self[key], dict):
                    #self[key].update(other[key])
                    #other[key]=self[key]
            #args=(other.items(),)
            
        #for key in kw:
            #if not key in self._keys:
                #raise UnrecognizedOptionError("The key: %s, is not a valid algorithm option" %str(key))
            #if isinstance(self[key], dict):
                #self[key].update(kw[key])
                #kw[key] = self[key]
                
        #return args, kw
    
class IpoptInitResult(JMResultBase):
    pass

class IpoptInitializationAlgOptions(OptionBase):
    """
    Options for the IPOPT-based initialization algorithm.

    Initialization algorithm options::

        stat --
            Solve a static optimization problem.
            Default: False

        result_file_name --
            Specifies the name of the file where the optimization
            result is written. Setting this option to an empty
            string results in a default file name that is based
            on the name of the optimization class.
            Default: Empty string
            
        result_format --
            Specifies in which format to write the result. Currently
            only textual mode is supported.
            Default: 'txt'

        write_scaled_result --
            Set this parameter to True to write the result to file without
            taking scaling into account. If the value of scaled is False,
            then the variable scaling factors of the model are used to
            reproduced the unscaled variable values.
            Default: False

    Options are set by using the syntax for dictionaries::

        >>> opts = my_model.initialize_options()
        >>> opts['stat'] = True
        
    In addition, IPOPT options can be provided in the option
    IPOPT_options. For a complete list of IPOPT options, please
    consult the IPOPT documentation available at
    http://www.coin-or.org/Ipopt/documentation/).

    Some commonly used IPOPT options are provided by default::

        max_iter --
           Maximum number of iterations.
           Default: 3000
                      
        derivative_test --
           Check the correctness of the NLP derivatives. Valid values are
           'none', 'first-order', 'second-order', 'only-second-order'.
           Default: 'none'

    IPOPT options are set using the syntax for dictionaries::

        >>> opts['IPOPT_options']['max_iter'] = 200
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'stat':False,
            'result_file_name':'', 
            'result_format':'txt',
            'write_scaled_result':False,
            'IPOPT_options':{'max_iter':3000,
                             'derivative_test':'none'}
            }
        super(IpoptInitializationAlgOptions,self).__init__(_defaults)
        # for those key-value-sets where the value is a dict, don't 
        # overwrite the whole dict but instead update the default dict 
        # with the new values
        self._update_keep_dict_defaults(*args, **kw)

class IpoptInitializationAlg(AlgorithmBase):
    """ Initialization of a model using Ipopt. """
    
    def __init__(self, model, options):
        """
        Create an initialization algorithm using IpoptInitialization.
        
        Parameters::
        
            model -- 
                The jmi.JMUModel object representation of the model.
            options -- 
                The options that should be used in the algorithm. For 
                details on the options, see:
                
                * model.initialize_options('IpoptInitializationAlgOptions')
                
                or look at the docstring with help:
                
                * help(jmodelica.algorithm_drivers.IpoptInitializationAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by IpoptInitializationAlgOptions. An empty
                  dict will thus give all options with default values.
                - IpoptInitializationAlgOptions object.
        """
        self.model = model
        
        # handle options argument
        if isinstance(options, dict) and not \
            isinstance(options, IpoptInitializationAlgOptions):
            # user has passed dict with options or empty dict = default
            self.options = IpoptInitializationAlgOptions(options)
        elif isinstance(options, IpoptInitializationAlgOptions):
            # user has passed IpoptInitializationAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)
            
        # set options
        self._set_options()
            
        if not ipopt_present:
            raise Exception('Could not find IPOPT. Check jmodelica.check_packages()')

        self.nlp = NLPInitialization(model,self.stat)
        self.nlp_ipopt = InitializationOptimizer(self.nlp)
        
        # set solver options
        self._set_solver_options()
        
    def _set_options(self):
        """ Helper function that sets options for the IpoptInitialization 
        algorithm.
        """
        self.stat=self.options['stat']
        self.result_args = dict(
            file_name=self.options['result_file_name'], 
            format=self.options['result_format'],
            write_scaled_result=self.options['write_scaled_result'])
            
        # solver options
        self.solver_options = self.options['IPOPT_options']
                
    def _set_solver_options(self):
        """ Helper function that sets options for the solver.
        """
        for k, v in self.solver_options.iteritems():
            print k
            print v
            if isinstance(v, default_int):
                self.nlp_ipopt.init_opt_ipopt_set_int_option(k, v)
            elif isinstance(v, float):
                self.nlp_ipopt.init_opt_ipopt_set_num_option(k, v)
            elif isinstance(v, str):
                self.nlp_ipopt.init_opt_ipopt_set_string_option(k, v)
                        
    def solve(self):
        """ Solve the initialization problem using ipopt solver. """
        self.nlp_ipopt.init_opt_ipopt_solve()
        
    def get_result(self):
        """ Write result to file, load result data and create an 
        IpoptInitResult object.
        
        Returns::
        
            The IpoptInitResult object.
        """
        self.nlp.export_result_dymola(**self.result_args)
        # result file name
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return IpoptInitResult(self.model, resultfile, self.nlp_ipopt, 
            res, self.options)

    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class for the 
        IpoptInitializationAlg algorithm, prefilled with default values. 
        (Class method.)
        """
        return IpoptInitializationAlgOptions()

class AssimuloSimResult(JMResultBase):
    pass

class AssimuloFMIAlgOptions(OptionBase):
    """
    Options for the solving the FMU using the Assimulo simulation package.
    Currently, the only solver in the Assimulo package that fully supports
    simulation of FMUs is the solver CVode.
    
    Assimulo options::
    
        solver --
            Specifies the simulation algorithm that is to be used.
            Currently the only supported solver is 'CVode'.
            Default 'CVode'
                 
        ncp    --
            Number of communication points. If ncp is zero, the solver
            will return the internal steps taken.
            Default '0'
                 
        ncp    - Number of communication points. If ncp is zero, the solver
                 will return the internal steps taken.
                 
                 Default '0'

        write_scaled_result --
                 Set this parameter to True to write the result to file without
                 taking scaling into account. If the value of scaled is False,
                 then the variable scaling factors of the model are used to
                 reproduced the unscaled variable values.
                 Default: False
                 
    The different solvers provided by the Assimulo simulation package provides
    different options. These options are given in dictionaries with names
    consisting of the solver name concatenated by the string '_option'. The most
    common solver options are documented below, for a complete list of options
    see, http://www.jmodelica.org/assimulo
    
    Options for CVode::
    
        rtol    -- 
            The relative tolerance. The relative tolerance are retrieved from
            the 'default experiment' section in the XML-file and if not
            found are set to 1.0e-4
            Default 1.0e-4
            
        atol    --
            The absolute tolerance.
            Default rtol*0.01*(nominal values of the continuous states)
        
        discr   --
            The discretization method. Can be either 'BDF' or 'Adams'
            Default 'BDF'
        
        iter    --
            The iteration method. Can be either 'Newton' or 'FixedPoint'
            Default 'Newton'
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'solver': 'CVode', 
            'ncp':0,
            'write_scaled_result':False,
            'CVode_options':{'discr':'BDF','iter':'Newton'}
            }
        super(AssimuloFMIAlgOptions,self).__init__(_defaults)
        # for those key-value-sets where the value is a dict, don't 
        # overwrite the whole dict but instead update the default dict 
        # with the new values
        self._update_keep_dict_defaults(*args, **kw)

class AssimuloFMIAlg(AlgorithmBase):
    """Simulation algortihm for FMUs using the Assimulo package."""
    
    def __init__(self,
                 start_time,
                 final_time,
                 input_trajectory,
                 model,
                 options):
        """ Create a simulation algorithm using Assimulo.
        
        Parameters::
        
            model -- 
                fmi.FMUModel object representation of the model.
                
            options -- 
                The options that should be used in the algorithm. For 
                details on the options, see:
                
                * model.simulate_options('AssimuloFMIAlgOptions')
                
                or look at the docstring with help:
                
                * help(jmodelica.algorithm_drivers.AssimuloFMIAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by AssimuloFMIAlgOptions. An empty
                  dict will thus give all options with default values.
                - AssimuloFMIAlgOptions object.
        """
        self.model = model
        
        if not assimulo_present:
            raise Exception('Could not find Assimulo package. Check jmodelica.check_packages()')
        
        # set start time, final time and input trajectory
        self.start_time = start_time
        self.final_time = final_time
        self.input_trajectory = input_trajectory
        
        # handle options argument
        if isinstance(options, dict) and not \
            isinstance(options, AssimuloFMIAlgOptions):
            # user has passed dict with options or empty dict = default
            self.options = AssimuloFMIAlgOptions(options)
        elif isinstance(options, AssimuloFMIAlgOptions):
            # user has passed AssimuloFMIAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)
    
        # set options
        self._set_options()
        
        if (N.size(self.input_trajectory)==0):
            self.probl = FMIODE(self.model)
        else:
            self.probl = FMIODE(self.model,TrajectoryLinearInterpolation(self.input_trajectory[:,0], \
                                                                        self.input_trajectory[:,1:]))
        
        # instantiate solver and set options
        self.simulator = self.solver(self.probl, t0=self.start_time)
        self._set_solver_options()
    
    def _set_options(self):
        """ 
        Helper function that sets options for AssimuloFMI algorithm.
        """
        # no of communication points
        self.ncp = self.options['ncp']

        self.write_scaled_result = self.options['write_scaled_result']
        
        # solver
        solver = self.options['solver']
        if hasattr(expl_ode, solver):
            self.solver = getattr(expl_ode, solver)
        else:
            raise InvalidAlgorithmOptionException("The solver: "+solver+ " is unknown.")
            
        # solver options
        self.solver_options = self.options[solver+'_options']
    
    def _set_solver_options(self):
        """ 
        Helper function that sets options for the solver.
        """
        rtol, atol = self.model.get_tolerances()
        solver_options = self.solver_options.copy()
        #If the tolerances are not set specifically, they are set 
        #according to the 'DefaultExperiment' from the XML file.
        try:
            solver_options['atol']
        except KeyError:
            solver_options['atol'] = atol
        try:
            solver_options['rtol']
        except KeyError:
            solver_options['rtol'] = rtol

        #loop solver_args and set properties of solver
        for k, v in solver_options.iteritems():
            try:
                getattr(self.simulator,k)
            except AttributeError:
                try:
                    getattr(self.probl,k)
                except AttributeError:
                    raise InvalidSolverArgumentException(v)
                setattr(self.probl, k, v)
                continue
            setattr(self.simulator, k, v)
                
    def solve(self):
        """ 
        Runs the simulation. 
        """
        self.simulator.simulate(self.final_time, 
            self.ncp)
 
    def get_result(self):
        """ 
        Write result to file, load result data and create an 
        AssimuloSimResult object.
        
        Returns::
        
            The AssimuloSimResult object.
        """
        if not self.probl.write_cont:
            write_data(self.simulator,self.write_scaled_result)
        # result file name
        resultfile = self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        # create and return result object
        return AssimuloSimResult(self.model, resultfile, self.simulator, 
            res, self.options)
        
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class for the AssimuloFMIAlg 
        algorithm, prefilled with default values. (Class method.)
        """
        return AssimuloFMIAlgOptions()

class AssimuloAlgOptions(OptionBase):
    """
    Options for simulation of a JMU model using the Assimulo simulation package.
    The Assimulo package contain both explicit solvers (CVode) for ODEs and 
    implicit solvers (IDA) for DAEs. The ODE solvers require that the problem
    is written on the form, ydot = f(t,y).
    
    Assimulo options::
    
        solver     --
            Specifies the simulation algorithm that is to be used.
            Default 'IDA'
                 
        ncp        --
            Number of communication points. If ncp is zero, the solver
            will return the internal steps taken.
            Default '0'
                 
        initialize --
            If set to True, an algorithm for initializing the
            differential equation is invoked, otherwise the
            differential equation is assumed to have consistent
            initial conditions. 
            Default is True.
                 
                     Default '0'
                 
        initialize - If set to True, an algorithm for initializing the
                     differential equation is invoked, otherwise the
                     differential equation is assumed to have consistent
                     initial conditions. 
                     
                     Default is True.

        write_scaled_result --
            Set this parameter to True to write the result to file without
            taking scaling into account. If the value of scaled is False,
            then the variable scaling factors of the model are used to
            reproduced the unscaled variable values.
            Default: False

    The different solvers provided by the Assimulo simulation package provides
    different options. These options are given in dictionaries with names
    consisting of the solver name concatenated by the string '_option'. The most
    common solver options are documented below, for a complete list of options
    see, http://www.jmodelica.org/assimulo
    
    Options for IDA::
    
        rtol    --
            The relative tolerance.
            Default 1.0e-6
                  
        atol    --
            The absolute tolerance.
            Default 1.0e-6
        
        maxord  --
            The maximum order of the solver. Can range between 1 to 5.
            Default 5
    
    Options for CVode::
    
        rtol    --
            The relative tolerance. 
            Default 1.0e-6
                
        atol    --
            The absolute tolerance.
            Default 1.0e-6
                  
        discr   --
            The discretization method. Can be either 'BDF' or 'Adams'
            Default 'BDF'
        
        iter    --
            The iteration method. Can be either 'Newton' or 'FixedPoint'
            Default 'Newton'
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'solver': 'IDA', 
            'ncp':0, 
            'initialize':True,
            'write_scaled_result':False,
            'IDA_options':{'atol':1.0e-6,'rtol':1.0e-6,
                           'maxord':5},
            'CVode_options':{'discr':'BDF','iter':'Newton',
                             'atol':1.0e-6,'rtol':1.0e-6}
            }
        # create options with default values
        super(AssimuloAlgOptions,self).__init__(_defaults)
        # for those key-value-sets where the value is a dict, don't 
        # overwrite the whole dict but instead update the default dict 
        # with the new values
        self._update_keep_dict_defaults(*args, **kw)

class AssimuloAlg(AlgorithmBase):
    """ Simulation algorithm using the Assimulo package. """
    
    def __init__(self,
                 start_time,
                 final_time,
                 input_trajectory,
                 model,
                 options):
        """ Create a simulation algorithm using Assimulo.
        
        Parameters::
        
            model -- 
                jmi.Model object representation of the model
                
            options -- 
                The options that should be used in the algorithm. For 
                details on the options, see:
                
                * model.simulate_options('AssimuloAlgOptions')
                
                or look at the docstring with help:
                
                * help(jmodelica.algorithm_drivers.AssimuloAlgOptions)
                
                Valid values are: 
                - A dict which gives AssimuloAlgOptions with default 
                  values on all options except the ones listed in the 
                  dict. Empty dict will thus give all options with 
                  default values.
                - AssimuloAlgOptions object.
        """
        self.model = model
        
        if not assimulo_present:
            raise Exception('Could not find Assimulo package. Check jmodelica.check_packages()')
        
        # set start time, final time and input trajectory
        self.start_time = start_time
        self.final_time = final_time
        self.input_trajectory = input_trajectory
        
        # handle options argument
        if isinstance(options, dict) and not \
            isinstance(options, AssimuloAlgOptions):
            # user has passed dict with options or empty dict = default
            self.options = AssimuloAlgOptions(options)
        elif isinstance(options, AssimuloAlgOptions):
            # user has passed AssimuloAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)
            
        # set options
        self._set_options()
        
        if issubclass(self.solver, Implicit_ODE):
            if (N.size(self.input_trajectory)==0):
                self.probl = JMIDAE(model)
            else:
                self.probl = JMIDAE(model,
                    TrajectoryLinearInterpolation(self.input_trajectory[:,0], \
                                                  self.input_trajectory[:,1:]))
        else:
            if (N.size(self.input_trajectory)==0):
                self.probl = JMIODE(model)
            else:
                self.probl = JMIODE(model,
                    TrajectoryLinearInterpolation(self.input_trajectory[:,0], \
                                                  self.input_trajectory[:,1:]))
        # instantiate solver and set options
        self.simulator = self.solver(self.probl, t0=self.start_time)
        self._set_solver_options()
        
    def _set_options(self):
        """ 
        Helper function that sets options for Assimulo algorithm.
        """
        # no of communication points
        self.ncp = self.options['ncp']
        
        # solver
        solver = self.options['solver']
        if hasattr(impl_ode, solver):
            self.solver = getattr(impl_ode, solver)
        elif hasattr(expl_ode, solver):
            self.solver = getattr(expl_ode, solver)
        else:
            raise InvalidAlgorithmOptionException("The solver: "+solver+ " is unknown.")
            
        # do initialize?
        self.initialize = self.options['initialize']

        # write scaled result?
        self.write_scaled_result = self.options['write_scaled_result']
        
        # solver options
        self.solver_options = self.options[solver+'_options']
        
    def _set_solver_options(self):
        """ 
        Helper functions that sets options for the solver.
        """
        #loop solver_args and set properties of solver
        for k, v in self.solver_options.iteritems():
            try:
                getattr(self.simulator,k)
            except AttributeError:
                try:
                    getattr(self.probl,k)
                except AttributeError:
                    raise InvalidSolverArgumentException(v)
                setattr(self.probl, k, v)
                continue
            setattr(self.simulator, k, v)
                
    def solve(self):
        """ 
        Runs the simulation. 
        """
        # Only run initiate if model has been compiled with CppAD
        # and if alg arg 'initialize' is True.
        if self.model.has_cppad_derivatives() and self.initialize:
            self.simulator.initiate()
        self.simulator.simulate(self.final_time, 
            self.ncp)
 
    def get_result(self):
        """ 
        Write result to file, load result data and create an 
        AssimuloSimResult object.
        
        Returns::
        
            The AssimuloSimResult object.
        """
        write_data(self.simulator)
        # result file name
        resultfile = self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return AssimuloSimResult(self.model, resultfile, self.simulator, 
            res, self.options)
    
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class for the AssimuloAlg 
        algorithm, prefilled with default values. (Class method.)
        """
        return AssimuloAlgOptions()

class CollocationLagrangePolynomialsResult(JMResultBase):
    pass

class CollocationLagrangePolynomialsAlgOptions(OptionBase):
    """
    Options for optimizing JMU models using a collocation
    algorithm. 

    Collocation algorithm options::
    
        n_e --
            Number of elements of the finite element mesh.
            Default: 50
            
        n_cp --
            Number of collocation points in each element. Values
            between 1 and 10 are supported
            Default: 3
            
        hs --
            A vector containing n_e elements representing the finite
            element lengths. The sum of all element should equal to 1.
            Default: numpy.ones(n_e)/n_e (Uniform mesh)
            
        blocking_factors --
            A vector of blocking factors. Blocking factors are
            specified by a vector of integers, where each entry in the
            vector corresponds to the number of elements for which the
            control profile should be kept constant. For example, the
            blocking factor specification [2,1,5] means that u_0=u_1
            and u_3=u_4=u_5=u_6=u_7 assuming that the number of
            elements is 8. Notice that specification of blocking
            factors implies that controls are present in only one
            collocation point (the first) in each element. The number
            of constant control levels in the optimization interval is
            equal to the length of the blocking factor vector. In the
            example above, this implies that there are three constant
            control levels. If the sum of the entries in the blocking
            factor vector is not equal to the number of elements, the
            vector is normalized, either by truncation (if the sum of
            the entries is larger than the number of element) or by
            increasing the last entry of the vector. For example, if
            the number of elements is 4, the normalized blocking
            factor vector in the example is [2,2]. If the number of
            elements is 10, then the normalized vector is [2,1,7].
            Default: None
            
        init_traj --
            Variable trajectory data used for initialization of the
            optimization problem. The data is represented by an object
            of the type jmodelica.io.DymolaResultTextual.
            Default: None
            
        result_mode --
            Specifies the output format of the optimization result.
             - 'default' gives the the optimization result at the
               collocation points.
             - 'element_interpolation' computes the values of the
               variable trajectories using the collocation interpolation
               polynomials. The option 'n_interpolation_points' is used
               to specify the number of evaluation points within each
               finite element.
             - 'mesh_interpolation' computes the values of the variable
               trajectories at points defined by the option
               'result_mesh'.
            Default: 'default'
            
        n_interpolation_points --
            Number of interpolation points in each finite element
            if the result reporting option result_mode is set to
            'element_interpolation'.
            Default: 20
            
        result_mesh --
            A vector of time points at which the the optimization
            result is computed. This option is used if result_mode
            is set to 'mesh_interpolation'.
            Default: None
            
        result_file_name --
            Specifies the name of the file where the optimization
            result is written. Setting this option to an empty
            string results in a default file name that is based
            on the name of the optimization class.
            Default: Empty string
            
        result_format --
            Specifies in which format to write the result. Currently
            only textual mode is supported.
            Default: 'txt'

        write_scaled_result --
            Write the scaled optimization result if set to true.
            This option is only applicable when automatic variable
            scaling is enabled. Only for debugging use.
            Default: False.

    Options are set by using the syntax for dictionaries::

        >>> opts = my_model.optimize_options()
        >>> opts['n_e'] = 100
        
    In addition, IPOPT options can be provided in the option
    IPOPT_options. For a complete list of IPOPT options, please
    consult the IPOPT documentation available at
    http://www.coin-or.org/Ipopt/documentation/).

    Some commonly used IPOPT options are provided by default::

        max_iter --
           Maximum number of iterations.
           Default: 3000
                      
        derivative_test --
           Check the correctness of the NLP derivatives. Valid values are
           'none', 'first-order', 'second-order', 'only-second-order'.
           Default: 'none'

    IPOPT options are set using the syntax for dictionaries::

        >>> opts['IPOPT_options']['max_iter'] = 200

    """
    def __init__(self, *args, **kw):
        _defaults= {
            'n_e':50, 
            'n_cp':3, 
            'hs':None, 
            'blocking_factors':None,
            'init_traj':None,
            'result_mode':'default', 
            'n_interpolation_points':20,
            'result_mesh':None,
            'result_file_name':'', 
            'result_format':'txt',
            'write_scaled_result':False,
            'IPOPT_options':{'max_iter':3000,
                             'derivative_test':'none'}
            }
        super(CollocationLagrangePolynomialsAlgOptions,self).__init__(_defaults)
        # for those key-value-sets where the value is a dict, don't 
        # overwrite the whole dict but instead update the default dict 
        # with the new values
        self._update_keep_dict_defaults(*args, **kw)

class CollocationLagrangePolynomialsAlg(AlgorithmBase):
    """
    The algorithm is based on orthogonal collocation and
    relies on the solver IPOPT for solving a non-linear programming
    problem. 
    """
    
    def __init__(self, 
                 model, 
                 options):
        """
        Create a CollocationLagrangePolynomials algorithm.
        
        Parameters::
              
            model -- 
                jmodelica.jmi.JMUModel model object

            options -- 
                The options that should be used by the algorithm. For 
                details on the options, see:
                
                * model.simulate_options('CollocationLagrangePolynomialsAlgOptions')
                
                or look at the docstring with help:
                
                * help(jmodelica.algorithm_drivers.CollocationLagrangePolynomialsAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by CollocationLagrangePolynomialsAlgOptions. An empty
                  dict will thus give all options with default values.
                - A CollocationLagrangePolynomialsAlgOptions object.
        """
        self.model = model
        
        # handle options argument
        if isinstance(options, dict) and not \
            isinstance(options, CollocationLagrangePolynomialsAlgOptions):
            # user has passed dict with options or empty dict = default
            self.options = CollocationLagrangePolynomialsAlgOptions(options)
        elif isinstance(options, CollocationLagrangePolynomialsAlgOptions):
            # user has passed CollocationLagrangePolynomialsAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)

        if self.options['hs'] == None:
            self.options['hs'] = N.ones(self.options['n_e'])/self.options['n_e']

        # set options
        self._set_options()
            
        if not ipopt_present:
            raise Exception('Could not find IPOPT. Check jmodelica.check_packages()')

        if self.blocking_factors == None:
            self.nlp = ipopt.NLPCollocationLagrangePolynomials(
                model,self.n_e, self.hs, self.n_cp)
        else:
            self.nlp = ipopt.NLPCollocationLagrangePolynomials(
                model,self.n_e, self.hs, self.n_cp, 
                blocking_factors=self.blocking_factors)
        if self.init_traj:
            self.nlp.set_initial_from_dymola(self.init_traj, self.hs, 0, 0) 
            
        self.nlp_ipopt = ipopt.CollocationOptimizer(self.nlp)
        # set solver options
        self._set_solver_options()
        
    def _set_options(self):
        """ Helper function that sets options for the 
        CollocationLagrangePolynomials algorithm.
        """
        self.n_e=self.options['n_e']
        self.n_cp=self.options['n_cp']
        self.hs=self.options['hs']
        self.blocking_factors=self.options['blocking_factors']
        self.init_traj=self.options['init_traj']
        #self.result_mesh=self.options['result_mesh']
        self.result_mode = self.options['result_mode']
        if self.result_mode == 'default':
            self.result_args = dict(
                file_name=self.options['result_file_name'], 
                format=self.options['result_format'],
                write_scaled_result=self.options['write_scaled_result'])
        elif self.result_mode == 'element_interpolation':
            self.result_args = dict(
                file_name = self.options['result_file_name'], 
                format = self.options['result_format'],
                n_interpolation_points = self.options['n_interpolation_points'],
                write_scaled_result=self.options['write_scaled_result'])
        elif self.result_mode == 'mesh_interpolation':
            self.result_args = dict(
                file_name = self.options['result_file_name'], 
                format = self.options['result_format'], 
                mesh = self.options['result_mesh'],
                write_scaled_result=self.options['write_scaled_result'])
        else:
            raise InvalidAlgorithmArgumentException(self.result_mesh)

        # solver options
        self.solver_options = self.options['IPOPT_options']
        
    def _set_solver_options(self):
        """ Helper function that sets options for the solver.
        """
        for k, v in self.solver_options.iteritems():
            if isinstance(v, default_int):
                self.nlp_ipopt.opt_sim_ipopt_set_int_option(k, v)
            elif isinstance(v, float):
                self.nlp_ipopt.opt_sim_ipopt_set_num_option(k, v)
            elif isinstance(v, str):
                self.nlp_ipopt.opt_sim_ipopt_set_string_option(k, v)
                        
    def solve(self):
        """ Solve the optimization problem using ipopt solver. """
        self.nlp_ipopt.opt_sim_ipopt_solve()
        
    def get_result(self):
        """ Write result to file, load result data and create an 
        CollocationLagrangePolynomialsResult object.
        
        Returns::
        
            The CollocationLagrangePolynomialsResult object.
        """
        if self.result_mode=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(**self.result_args)
        elif self.result_mode=='mesh_interpolation':
            self.nlp.export_result_dymola_mesh_interpolation(**self.result_args)
        elif self.result_mode=='default':
            self.nlp.export_result_dymola(**self.result_args)
        else:
             raise InvalidAlgorithmArgumentException(self.resul_mode)
            
        # result file name
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return CollocationLagrangePolynomialsResult(self.model, 
            resultfile, self.nlp_ipopt, res, self.options)
        
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class for the 
        CollocationLagrangePolynomialsAlg algorithm, prefilled with 
        default values. 
        (Class method.)
        """
        return CollocationLagrangePolynomialsAlgOptions()
    
class InvalidAlgorithmOptionException(Exception):
    """ Exception raised when an algorithm options argument is 
    encountered that is not valid.
    """
    def __init__(self, arg):
        self.msg='Invalid algorithm options object: '+str(arg)
        
    def __str__(self):
        return repr(self.msg)

class InvalidSolverArgumentException(Exception):
    """ Exception raised when a solver argument is encountered that does 
        not exist.
    """
    def __init__(self, arg):
        self.msg='Invalid solver argument: '+str(arg)
        
    def __str__(self):
        return repr(self.msg)
    
class KInitSolveResult(JMResultBase):
    pass

class KInitSolveAlgOptions(OptionBase):
    """
    Options for the initialization of a JMU using the KInitSolve
    algorithm based on the KINSOL wrapper in the assimulo package.
    
    KINSOL options::
    
        use_jac --
            Boolean set to True if the jacobian supplied by the JMUmodel
            is to be used in the solving of the initialization problem.
            If set to False a jacobian generated by KINSOL using 
            finite differences is used.
            Default: True
            
        use_constraints --
            Boolean set to True if constraints are to be used. If set to False,
            the initialization will not be constraind even if constraints are
            supplied by the user. If set to True but constraints are not supplied
            please see the documentation of constraints below.
            Default: False
            
        constraints --
            Numpy.array that should be of same size as the number of variables.
            The array contains numbers specifying what type of constraint to use for
            each variable. The array contains the following number in the ith position:
                0.0  -  no constraint on x[i]
                1.0  -  x[i] greater or equal than 0.0
                -1.0 -  x[i] lesser or equal than 0.0
                2.0  -  x[i] greater than 0.0
                -2.0 -  x[i] lesser than 0.0
                
            If no constraints are supplied but use_constraints are set to True
            the solver will 'guess' constraints basically meaning that the sign of a
            variable is kept the same as the sign of the initial guess for the variable.
            Default: None
            
        result_file_name --
            A string containing the name of the file the results should be written to.
            If not specified the name of the model will be used.
            Default: ''
            
        result_format --
            A string specifying the format of the output file.
            So far only '.txt' is supported
            Default: '.txt'
            
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'use_jac':True,
            'use_constraints':False,
            'constraints':None,
            'result_file_name':'', 
            'result_format':'txt'
            }
        super(KInitSolveAlgOptions,self).__init__(_defaults)
        # for those key-value-sets where the value is a dict, don't 
        # overwrite the whole dict but instead update the default dict 
        # with the new values
        self._update_keep_dict_defaults(*args, **kw)
        
class KInitSolveAlg(AlgorithmBase):
    """ Initialization using a solver of non-linear eq-systems"""

    def __init__(self, model, options):
        """ Create algorithm objects.
        
        Parameters::
        
            model -- 
                jmodelica.jmi.JMUModel object representation of the 
                model.
            options -- 
                The options that should be used in the algorithm. For 
                details on the options, see:
                
                * model.simulate_options('KInitSolveAlgOptions')
                
                or look at the docstring with help:
                
                * help(jmodelica.algorithm_drivers.KInitSolveAlgOptions)
                
                Valid values are: 
                - A dict which gives KInitSolveAlgOptions with 
                  default values on all options except the ones listed 
                  in the dict. Empty dict will thus give all options 
                  with default values.
                - KInitSolveAlgOptions object.
        """
        self.model = model
        
        # handle options argument
        if isinstance(options, dict) and not \
            isinstance(options, KInitSolveAlgOptions):
            # user has passed dict with options or empty dict = default
            self.options = KInitSolveAlgOptions(options)
        elif isinstance(options, KInitSolveAlgOptions):
            # user has passed KInitSolveAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)
            
        self.solver = KInitSolver(model)
        # set options
        self._set_options()
        
    def _set_options(self):
        """ Helper function that sets options for the KInitSolve 
        algorithm.
        """
        self.solver.set_jac_usage(self.options['use_jac'])
        self.solver.set_constraints_usage(self.options['use_constraints'],
            self.options['constraints'])
        self.result_args = dict(file_name=self.options['result_file_name'], 
            format=self.options['result_format'])
          
    def _set_solver_options(self, solver_options={}): pass

    def solve(self):
        self.solver.initialize()

    def get_result(self):
        """ Write result to file, load result data and create an 
        NLSInitResult object.
        
        Returns::
        
            The NLSInitResult object.
        """
        self.solver.export_result_dymola(**self.result_args)
        # result file name
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return KInitSolveResult(self.model, resultfile, self.solver, res, 
            self.options)
        
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class for the KInitSolveAlg 
        algorithm, prefilled with default values. (Class method.)
        """
        return KInitSolveAlgOptions()

class UnrecognizedOptionError(Exception): pass
