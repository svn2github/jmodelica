#!/usr/bin/env python 
# -*- coding: utf-8 -*-
""" Module for optimization, simulation and initialization algorithms to be 
used together with jmodelica.optimize, jmodelica.simulate and jmodelica.initialize 
respectively.
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
import warnings
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
    warnings.warn('Could not load Assimulo module. Check jmodelica.check_packages()')
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
        jmodelica.jmi.JMUModel.optimize, jmodelica.jmi.JMUModel.simulate 
        or jmodelica.jmi.JMUModel.initialize must implement.
    """
#    __metaclass__=ABCMeta
    
#    @abstractmethod
    def __init__(self, model, alg_args): pass
    
#    @abstractmethod        
    def set_solver_options(self, solver_args): pass
    
#    @abstractmethod
    def solve(self): pass
    
#   @abstractmethod
    def get_result(self): pass
    
    @classmethod
    def get_default_options(self): pass
    
class ResultBase(object):
    """ Base class for an algorithm result. All algorithms used in any 
        of the high-level functions must return an object which extends 
        this class.
    """
    
    def __init__(self, model=None, result_file_name=None, solver=None, 
        result_data=None):
        """ Create a result object containing the model used in the 
        algorithm, the name of the result file, the solver used in the 
        algorithm and the result data object.
                       
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
        """
        self._model = model
        self._result_file_name = result_file_name
        self._solver = solver
        self._result_data = result_data
    
    def get_model(self):
        """ Get the jmi.JMUModel object representing the model that was 
        used in the algorithm.
        
        Returns::
        
            The jmi.JMUModel object that was used in the algorithm.
        """
        if self._model != None:
            return self._model
        raise Exception("model has not been set")
        
    def set_model(self, model):
        """ Set the jmi.JMUModel that was used in the algorithm.
        
        Parameters::
        
            model --
                The jmi.JMUModel object that was used in the algorithm.
        """
        self._model = model
        
    model = property(fget=get_model, fset=set_model)
        
    def get_result_file_name(self):
        """ Get the name of the result file created on the file system.
        
        Returns::
        
            The name of the result file.
        """
        if self._result_file_name != None:
            return self._result_file_name
        raise Exception("result file name has not been set")
    
    def set_result_name_file(self, file_name):
        """ Set the name of the result file created in the algorithm.
        
        Parameters::
        
            file_name --
                The name of the result file.
            
        """
        self._result_file_name = result_file_name
        
    result_file_name = property(fget=get_result_file_name, fset=set_result_name_file)
        
    def get_solver(self):
        """ Get the solver object repesenting the solver that was used 
        in the algorithm.
        
        Returns::
        
            The solver object that was used in the algorithm.
        """
        if self._solver != None:
            return self._solver
        raise Exception("solver has not been set")

    def set_solver(self, solver):
        """ Set the solver that was used in the algorithm.
        
        Parameters::
        
            solver --
                The solver that was used in the algorithm.
        """
        self._solver = solver
        
    solver = property(fget=get_solver, fset=set_solver)
        
    def get_result_data(self):
        """ Get the result data matrix created in the algorithm.
        
        Returns::
        
            The result data matrix.
        """
        if self._result_data != None:
            return self._result_data
        raise Exception("result data has not been set")
        
    def set_result_data(self, result_data):
        """ Set the result data matrix that was created in the algorithm.
        
        Parameters::
        
            result_data --
                The result data matrix.
        """
        self._result_data = result_data
        
    result_data = property(fget=get_result_data, fset=set_result_data)

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
    
class IpoptInitResult(ResultBase): pass

class IpoptInitializationAlgOptions(OptionBase):
    """ Options for the IpoptInitialization initialize algorithm. 
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'stat':False,
            'result_file_name':'', 
            'result_format':'txt',
            'IPOPT_options':{}
            }
        super(IpoptInitializationAlgOptions,self).__init__(_defaults)
        self.update(*args, **kw)

class IpoptInitializationAlg(AlgorithmBase):
    """ Initialization of a model using Ipopt. """
    
    def __init__(self, 
                 model, 
                 alg_args={}):
        """ Create algorithm objects.
        
        Parameters::
        
            model -- 
                jmi.JMUModel object representation of the model
            alg_args -- 
                All arguments for the algorithm. See _set_alg_args
                function call for names and default values.        
        """
        
        self.model = model
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
            
        if not ipopt_present:
            raise Exception('Could not find IPOPT. Check jmodelica.check_packages()')

        self.nlp = NLPInitialization(model,self.stat)
        self.nlp_ipopt = InitializationOptimizer(self.nlp)
            
    def _set_alg_args(self,
                      stat=False,
                      result_file_name='', 
                      result_format='txt'):
        """ Set arguments for initialization algorithm.
        
        Parameters::
        
            stat -- 
                Solve a static optimization problem if True.
                Default: False
            result_file_name --
                Name of result file.
                Default: empty string (default generated file name will 
                be used)
            result_format --
                Format of result file.
                Default: 'txt'
        """
        self.stat=stat
        self.result_args = dict(file_name=result_file_name, format=result_format)
                
    def set_solver_options(self, 
                           solver_args):
        """ Set options for the solver.
        
        Parameters::
        
            solver_args --
                Dict with int, real or string options for the solver ipopt.
        """
        for k, v in solver_args.iteritems():
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
        """ Write result to file, load result data and return IpoptInitResult."""
        
        self.nlp.export_result_dymola(**self.result_args)
        # result file name
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return IpoptInitResult(self.model, resultfile, self.nlp_ipopt, res)

    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class, prefilled with default 
        values, for the IpoptInitializationAlg algorithm. (Class method.)
        """
        return IpoptInitializationAlgOptions()

class AssimuloSimResult(ResultBase): pass

class AssimuloFMIAlgOptions(OptionBase):
    """ Options for the AssimuloFMI simulation algorithm. 
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'solver': 'CVode', 
            'num_communication_points':500, 
            'CVode_options':{}
            }
        super(AssimuloFMIAlgOptions,self).__init__(_defaults)
        self.update(*args, **kw)

class AssimuloFMIAlg(AlgorithmBase):
    """Simulation algortihm for FMUs using the Assimulo package."""
    
    def __init__(self,
                 model,
                 alg_args={}):
        """ Create a simulation algorithm using Assimulo.
        
        Parameters::
        
            model -- 
                fmi.FMIModel object representation of the model
            alg_args -- 
                All arguments for the algorithm. See _set_alg_args
                function call for names and default values.
        
        """
        self.model = model
        
        if not assimulo_present:
            raise Exception('Could not find Assimulo package. Check jmodelica.check_packages()')
        
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
        
        if (N.size(self.input_trajectory)==0):
            self.probl = FMIODE(self.model)
        else:
            self.probl = FMIODE(self.model,TrajectoryLinearInterpolation(self.input_trajectory[:,0], \
                                                                        self.input_trajectory[:,1:]))
        
        self.simulator = self.solver(self.probl, t0=self.start_time)
    
    def _set_alg_args(self,
                      start_time=0.0,
                      final_time=1.0,
                      num_communication_points=500,
                      solver='CVode',
                      input_trajectory = N.array([])
                      ):
        """ Set arguments for Assimulo algorithm.
        
        Parameters::
        
            start_time -- 
                Simulation start time.
                Default: 0.0
            final_time --
                Simulation stop time.
                Default: 1.0
            num_communication_points -- 
                Number of points where the solution is returned. If set to 0 the 
                integrator will return at it's internal steps.
                Default: 500               
            solver --
                Set which solver to use with class name as string.
                Default: 'CVode'
            input_trajectory --
                Trajectory data for model inputs. The argument should be a matrix
                where the first column represents time and the following columns
                represents input trajectory data. If the input_trajectory is set
                the property input_names in solver_args must be set and reflect
                the variables for which the input is going to be adjusted.
                Default: An empty matrix, i.e., no input trajectories.
        """
        self.start_time = start_time
        self.final_time = final_time
        self.num_communication_points = num_communication_points
        
        if hasattr(expl_ode, solver):
            self.solver = getattr(expl_ode, solver)
        else:
            raise InvalidAlgorithmArgumentException("The solver: "+solver+ " is unknown.")
            
        self.input_trajectory = input_trajectory
    
    def set_solver_options(self, 
                           solver_args={}):
        """ Set options for the solver.
        
        Parameters::
        
            solver_args --
                Dict with list of solver arguments. Arguments must be a property of 
                the solver. An InvalidSolverArgumentException is raised if an 
                argument can not be found for the chosen solver.
         """
        rtol, atol = self.model.get_tolerances()
        solver_args = solver_args.copy()
        #If the tolerances are not set specifically, they are set according to the 'DefaultExperiment'
        #from the XML file.
        try:
            solver_args['atol']
        except KeyError:
            solver_args['atol'] = atol
        try:
            solver_args['rtol']
        except KeyError:
            solver_args['rtol'] = rtol
        
        #Sets the default CVode solver to BDF using Newton iteration (if not set)
        try:
            solver_args['discr']
        except KeyError:
            solver_args['discr'] = 'BDF'
        try:
            solver_args['iter']
        except KeyError:
            solver_args['iter'] = 'Newton'

        #loop solver_args and set properties of solver
        for k, v in solver_args.iteritems():
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
        """ Runs the simulation. """
        self.simulator.simulate(self.final_time, self.num_communication_points)
 
    def get_result(self):
        """ Write result to file, load result data and return AssimuloSimResult."""
        if not self.probl.write_cont:
            write_data(self.simulator)
        # result file name
        resultfile = self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        # create and return result object
        return AssimuloSimResult(self.model, resultfile, self.simulator, res)
        
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class, prefilled with default 
        values, for the AssimuloFMIAlg algorithm. (Class method.)
        """
        return AssimuloFMIAlgOptions()

class AssimuloAlgOptions(OptionBase):
    """ Options for the Assimulo simulation algorithm. 
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'solver': 'IDA', 
            'num_communication_points':500, 
            'initialize':True,
            'IDA_options':{},
            'CVode_options':{}
            }
        super(AssimuloAlgOptions,self).__init__(_defaults)
        self.update(*args, **kw)

class AssimuloAlg(AlgorithmBase):
    """ Simulation algorithm using the Assimulo package. """
    
    def __init__(self, 
                 model, 
                 alg_args={}):
        """ Create a simulation algorithm using Assimulo.
        
        Parameters::
        
            model -- 
                jmi.Model object representation of the model
            alg_args -- 
                All arguments for the algorithm. See _set_alg_args
                function call for names and default values.
        
        """
        self.model = model
        
        if not assimulo_present:
            raise Exception('Could not find Assimulo package. Check jmodelica.check_packages()')
        
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
        
        
        
        if issubclass(self.solver, Implicit_ODE):
            if (N.size(self.input_trajectory)==0):
                self.probl = JMIDAE(model)
            else:
                self.probl = JMIDAE(model,TrajectoryLinearInterpolation(self.input_trajectory[:,0], \
                                                                        self.input_trajectory[:,1:]))
        else:
            if (N.size(self.input_trajectory)==0):
                self.probl = JMIODE(model)
            else:
                self.probl = JMIODE(model,TrajectoryLinearInterpolation(self.input_trajectory[:,0], \
                                                                        self.input_trajectory[:,1:]))
        self.simulator = self.solver(self.probl, t0=self.start_time)
        
    def _set_alg_args(self,
                      start_time=0.0,
                      final_time=1.0,
                      num_communication_points=500,
                      solver='IDA',
                      input_trajectory = N.array([]),
                      initialize=True):
        """ Set arguments for Assimulo algorithm.
        
        Parameters::
        
            start_time -- 
                Simulation start time.
                Default: 0.0
            final_time --
                Simulation stop time.
                Default: 1.0
            num_communication_points -- 
                Number of points where the solution is returned. If set to 0 the 
                integrator will return at it's internal steps.
                Default: 500               
            solver --
                Set which solver to use with class name as string. This determines 
                whether a DAE or ODE problem will be created.
                Default: 'IDA'
            input_trajectory --
                Trajectory data for model inputs. The argument should be a matrix
                where the first column represents time and the following columns
                represents input trajectory data. 
                Default: An empty matrix, i.e., no input trajectories.
            initialize --
                Do initialization if True, skip initialization if False.
                Default: True
        """
        self.start_time = start_time
        self.final_time = final_time
        self.num_communication_points = num_communication_points
        
        if hasattr(impl_ode, solver):
            self.solver = getattr(impl_ode, solver)
        elif hasattr(expl_ode, solver):
            self.solver = getattr(expl_ode, solver)
        else:
            raise InvalidAlgorithmArgumentException("The solver: "+solver+ " is unknown.")
            
        self.input_trajectory = input_trajectory
        self.initialize = initialize
        
    def set_solver_options(self, 
                           solver_args={}):
        """ Set options for the solver.
        
        Parameters::
        
            solver_args --
                Dict with list of solver arguments. Arguments must be a property of 
                the solver. An InvalidSolverArgumentException is raised if an 
                argument can not be found for the chosen solver.
         """
        #loop solver_args and set properties of solver
        for k, v in solver_args.iteritems():
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
        """ Runs the simulation. """
        # Only run initiate if model has been compiled with CppAD
        # and if alg arg 'initialize' is True.
        if self.model.has_cppad_derivatives() and self.initialize:
            self.simulator.initiate()
        self.simulator.simulate(self.final_time, self.num_communication_points)
 
    def get_result(self):
        """ Write result to file, load result data and return AssimuloSimResult."""
        write_data(self.simulator)
        # result file name
        resultfile = self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return AssimuloSimResult(self.model, resultfile, self.simulator, res)
    
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class, prefilled with default 
        values, for the AssimuloAlg algorithm. (Class method.)
        """
        return AssimuloAlgOptions()
    

class CollocationLagrangePolynomialsResult(ResultBase): pass

class CollocationLagrangePolynomialsAlgOptions(OptionBase):
    """ Options for the CollocationLagrangePolynomials optimization 
    algorithm. 
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'n_e':50, 
            'n_cp':3, 
            'hs':N.ones(50)*1./50, 
            'blocking_factors':None,
            'init_traj':None,
            'result_mesh':'default', 
            'result_file_name':'', 
            'result_format':'txt',
            'n_interpolation_points':None,
            'IPOPT_options':{}
            }
        super(CollocationLagrangePolynomialsAlgOptions,self).__init__(_defaults)
        self.update(*args, **kw)

class CollocationLagrangePolynomialsAlg(AlgorithmBase):
    """ Optimization algorithm using CollocationLagrangePolynomials method. """
    
    def __init__(self, 
                 model, 
                 alg_args={}):
        """ Create a CollocationLagrangePolynomials algorithm.
        
        Parameters::
              
            model -- 
                jmodelica.jmi.JMUModel model object
            alg_args -- 
                Dict with algorithm arguments. See the _set_alg_args function 
                call for names and default values.
            
        """
        self.model = model
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
            
        if not ipopt_present:
            raise Exception('Could not find IPOPT. Check jmodelica.check_packages()')
        
        if self.blocking_factors == None:
            self.nlp = ipopt.NLPCollocationLagrangePolynomials(model,self.n_e, self.hs, self.n_cp)
        else:
            self.nlp = ipopt.NLPCollocationLagrangePolynomials(model,self.n_e, self.hs, self.n_cp, blocking_factors=self.blocking_factors)
        if self.init_traj:
            self.nlp.set_initial_from_dymola(self.init_traj, self.hs, 0, 0) 
            
        self.nlp_ipopt = ipopt.CollocationOptimizer(self.nlp)
            
        
    def _set_alg_args(self, 
                      n_e=50, 
                      n_cp=3, 
                      hs=N.ones(50)*1./50, 
                      blocking_factors=None,
                      init_traj = None,
                      result_mesh='default', 
                      result_file_name='', 
                      result_format='txt',
                      n_interpolation_points=None):
        """ Set arguments for the CollocationLagrangePolynomials algorithm.
        
        Parameters::
        
            n_e -- 
                Number of finite elements.
                Default:50
            n_cp -- 
                Number of collocation points.
                Default: 3
            hs -- 
                Vector containing the normalized element lengths.
                Default: Equidistant points using default n_e.
            blocking_factors --
                Blocking factor vector.
                Default: None (not used)
            init_traj --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary containing variable trajectories used
                to initialize the optimization problem.
                Default: None (i.e. not used, set this argument to activate 
                initialization)
            result_mesh --
                Determines which function will be used to get the solution 
                trajectories. Possible values are, 'element_interpolation', 
                'mesh_interpolation' or 'default'. See optimization.ipopt for 
                more info.
                Default: 'default'
            result_file_name --
                Name of result file.
                Default: empty string (default generated file name will be used)
            result_format --
                Format of result file.
                Default: 'txt'
            n_interpolation_points --
                The number of points in each finite element at which the result
                is returned. Only available for result_mesh = 'element_interpolation'.
                Default: None
        
        """
        self.n_e=n_e
        self.n_cp=n_cp
        self.hs=hs
        self.blocking_factors=blocking_factors
        self.init_traj=init_traj
        self.result_mesh=result_mesh
        if not n_interpolation_points:
            self.result_args = dict(file_name=result_file_name, format=result_format)
        else:
            self.result_args = dict(file_name=result_file_name, format=result_format, n_interpolation_points=n_interpolation_points)
        
    def set_solver_options(self, 
                           solver_args):
        """ Set options for the solver.
        
        Parameters::
        
            solver_args --
                Dict with int, real or string options for the solver ipopt.
        """
        for k, v in solver_args.iteritems():
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
        """ Write result to file, load result data and return CollocationLagrangePolynomialsResult."""
        if self.result_mesh=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(**self.result_args)
        elif self.result_mesh=='mesh_interpolation':
            self.nlp.export_result_dymola_mesh_interpolation(**self.result_args)
        elif self.result_mesh=='default':
            self.nlp.export_result_dymola(**self.result_args)
        else:
             raise InvalidAlgorithmArgumentException(self.result_mesh)
            
        # result file name
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return CollocationLagrangePolynomialsResult(self.model, resultfile, self.nlp_ipopt, res)
        
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class, prefilled with default 
        values, for the CollocationLagrangePolynomialsAlg algorithm. 
        (Class method.)
        """
        return CollocationLagrangePolynomialsAlgOptions()
    
class InvalidAlgorithmArgumentException(Exception):
    """ Exception raised when an algorithm argument is encountered that does 
        not exist.
    """
    
    def __init__(self, arg):
        self.msg='Invalid algorithm argument: '+str(arg)
        
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
    
class KInitSolveResult(ResultBase): pass

class KInitSolveAlgOptions(OptionBase):
    """ Options for the KInitSolve initialize algorithm. 
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
        self.update(*args, **kw)
        
class KInitSolveAlg(AlgorithmBase):
    """ Initialization using a solver of non-linear eq-systems"""

    def __init__(self, model, alg_args={}):
        """ Create algorithm objects.
        
        Parameters::
        
            model -- 
                jmi.Model object representation of the model
            alg_args -- 
                All arguments for the algorithm in the shape 
                of a dictionary. See _set_alg_args
                function call for names and default values.
        """
        
        self.model = model
        self.solver = KInitSolver(model)
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
        
    def _set_alg_args(self,
                      use_jac=True,
                      use_constraints = False,
                      constraints = None,
                      result_file_name='', 
                      result_format='txt'):
        """ Set arguments for initialization algorithm.
        
        Parameters::
        
            use_jac -- 
                Boolean set to True if the jacobian is to be 
                supplied by the JMIinterface
                Default: True
            use_const --
                Boolean set to True if constraints are to be used at all
                Default: False
            constraints = None --
                If supplied these will be used. The constraints should 
                be a numpy array of size len(x0) with the following number
                in the ith position.
                0.0  - no constraint on x[i]
                1.0  - x[i] greater or equal than 0.0
                -1.0 - x[i] lesser or equal than 0.0
                2.0  - x[i] greater  than 0.0
                -2.0 - x[i] lesser than 0.0
                Default: None
            result_file_name --
                Name of result file.
                Default: empty string (default generated file name will be used)
            result_format --
                Format of result file.
                Default: 'txt'
        """
        self.solver.set_jac_usage(use_jac)
        self.solver.set_constraints_usage(use_constraints,constraints)
        self.result_args = dict(file_name=result_file_name, format=result_format)
          
    def set_solver_options(self, solver_args): pass

    def solve(self):
        self.solver.initialize()

    def get_result(self):
        """ Write result to file, load result data and return NLSInitResult."""
        
        self.solver.export_result_dymola(**self.result_args)
        # result file name
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        # load result file
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return KInitSolveResult(self.model, resultfile, self.solver, res)
        
    @classmethod
    def get_default_options(cls):
        """ Get an instance of the options class, prefilled with default 
        values, for the KInitSolveAlg algorithm. (Class method.)
        """
        return KInitSolveAlgOptions()

class UnrecognizedOptionError(Exception): pass
