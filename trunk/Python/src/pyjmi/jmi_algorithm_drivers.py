#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
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
Module for optimization, simulation and initialization algorithms to be used 
together with pyjmi.jmi.JMUModel.optimize, pyjmi.jmi.JMUModel.simulate and
pyjmi.jmi.JMUModel.initialize respectively.
"""

#from abc import ABCMeta, abstractmethod
import collections
import logging
import time
import numpy as N

from pyjmi.common.algorithm_drivers import AlgorithmBase, JMResultBase, AssimuloSimResult, OptionBase, InvalidAlgorithmOptionException, InvalidSolverArgumentException
from pyjmi.common.io import ResultDymolaTextual

from pyjmi.optimization import ipopt
from pyjmi.initialization.ipopt import NLPInitialization
from pyjmi.initialization.ipopt import InitializationOptimizer
from pyjmi.common.core import TrajectoryLinearInterpolation
from pyjmi.common.core import TrajectoryUserFunction

try:
    import assimulo
    assimulo_present = True
except:
    logging.warning(
        'Could not load Assimulo module. Check pyjmi.check_packages()')
    assimulo_present = False

if assimulo_present:
    from pyjmi.simulation.assimulo_interface import JMIDAE
    from pyjmi.simulation.assimulo_interface import JMIDAESens
    from pyjmi.simulation.assimulo_interface import write_data
    import assimulo.solvers as solvers
    from assimulo.implicit_ode import Implicit_ODE
    from assimulo.kinsol import KINSOL
    from pyjmi.initialization.assimulo_interface import JMUAlgebraic
    from pyjmi.initialization.assimulo_interface import JMUAlgebraic_Exception
    from pyjmi.initialization.assimulo_interface import write_resdata

try:
    import pyjmi
    ipopt_present = pyjmi.environ['IPOPT_HOME']
except:
    ipopt_present = False

try:
    import casadi
    casadi_present = True
except:
    casadi_present = False
    
if casadi_present:
    from pyjmi.optimization.casadi_collocation import *
    from pyjmi.optimization import casadi_collocation
    from pyjmi.optimization.polynomial import *
    from pyjmi.common.xmlparser import XMLException

default_int = int
int = N.int32
N.int = N.int32


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
            Specifies the name of the file where the optimization result is 
            written. Setting this option to an empty string results in a default 
            file name that is based on the name of the optimization class.
            Default: Empty string
            
        result_format --
            Specifies in which format to write the result. Currently only 
            textual mode is supported.
            Default: 'txt'

        write_scaled_result --
            Set this parameter to True to write the result to file without 
            taking scaling into account. If the value of scaled is False, then 
            the variable scaling factors of the model are used to reproduced the 
            unscaled variable values.
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
    """ 
    Initialization of a model using Ipopt. 
    """
    
    def __init__(self, model, options):
        """
        Create an initialization algorithm using IpoptInitialization.
        
        Parameters::
        
            model -- 
                The jmi.JMUModel object representation of the model.
            options -- 
                The options that should be used in the algorithm. For details on 
                the options, see:
                
                * model.initialize_options('IpoptInitializationAlgOptions')
                
                or look at the docstring with help:
                
                * help(pyjmi.jmi_algorithm_drivers.IpoptInitializationAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by IpoptInitializationAlgOptions. An empty dict will 
                  thus give all options with default values.
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
            raise Exception(
                'Could not find IPOPT. Check pyjmi.check_packages()')

        self.nlp = NLPInitialization(model,self.stat)
        self.nlp_ipopt = InitializationOptimizer(self.nlp)
        
        # set solver options
        self._set_solver_options()
        
    def _set_options(self):
        """ 
        Helper function that sets options for the IpoptInitialization algorithm.
        """
        self.stat=self.options['stat']
        self.result_args = dict(
            file_name=self.options['result_file_name'], 
            format=self.options['result_format'],
            write_scaled_result=self.options['write_scaled_result'])
            
        # solver options
        self.solver_options = self.options['IPOPT_options']
                
    def _set_solver_options(self):
        """ 
        Helper function that sets options for the solver.
        """
        for k, v in self.solver_options.iteritems():
            if isinstance(v, default_int):
                self.nlp_ipopt.init_opt_ipopt_set_int_option(k, v)
            elif isinstance(v, float):
                self.nlp_ipopt.init_opt_ipopt_set_num_option(k, v)
            elif isinstance(v, basestring):
                self.nlp_ipopt.init_opt_ipopt_set_string_option(k, v)
                        
    def solve(self):
        """ 
        Solve the initialization problem using ipopt solver. 
        """
        try:
            self.nlp_ipopt.init_opt_ipopt_solve()
        finally:
            self._write_result()
        
    def _write_result(self):
        """
        Helper method. Write result to file.
        """
        self.nlp.export_result_dymola(**self.result_args)
        
        # Set result file name
        if not self.result_args['file_name']:
            self.result_args['file_name'] = self.model.get_identifier()+'_result.txt'
        
    def get_result(self):
        """ 
        Load result data and create an IpoptInitResult object.
        
        Returns::
        
            The IpoptInitResult object.
        """
        # load result file
        resultfile = self.result_args['file_name']
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return IpoptInitResult(self.model, resultfile, self.nlp_ipopt, 
            res, self.options)

    @classmethod
    def get_default_options(cls):
        """ 
        Get an instance of the options class for the IpoptInitializationAlg 
        algorithm, prefilled with default values. (Class method.)
        """
        return IpoptInitializationAlgOptions()

class AssimuloAlgOptions(OptionBase):
    """
    Options for simulation of a JMU model using the Assimulo simulation package.
    The Assimulo package contain both explicit solvers (CVode) for ODEs and 
    implicit solvers (IDA) for DAEs. The ODE solvers require that the problem
    is written on the form, ydot = f(t,y).
    
    Assimulo options::
    
        solver --
            Specifies the simulation algorithm that is to be used.
            Default 'IDA'
                 
        ncp --
            Number of communication points. If ncp is zero, the solver will 
            return the internal steps taken.
            Default '0'
                 
        initialize --
            If set to True, an algorithm for initializing the differential 
            equation is invoked, otherwise the differential equation is assumed 
            to have consistent initial conditions. 
            Default is True.

        write_scaled_result --
            Set this parameter to True to write the result to file without 
            taking scaling into account. If the value of scaled is False, then 
            the variable scaling factors of the model are used to reproduced the 
            unscaled variable values.
            Default: False
            
        result_file_name --
            Specifies the name of the file where the simulation result is 
            written. Setting this option to an empty string results in a default 
            file name that is based on the name of the model class.
            Default: Empty string
            
        report_continuously --
            Specifies if the result should be written to file at each result
            point. This is necessary is some cases.
            Default: False

    The different solvers provided by the Assimulo simulation package provides
    different options. These options are given in dictionaries with names
    consisting of the solver name concatenated by the string '_option'. The most
    common solver options are documented below, for a complete list of options
    see, http://www.jmodelica.org/assimulo
    
    Options for IDA::
    
        rtol    --
            The relative tolerance.
            Default: 1.0e-6
                  
        atol    --
            The absolute tolerance.
            Default: 1.0e-6
        
        maxord  --
            The maximum order of the solver. Can range between 1 to 5. Note,
            when simulating sensitivities the maximum order is limited to 4.
            This is a temporary restriction.
            Default: 5
            
        sensitivity --
            If set to True, sensitivities for the states with respect to 
            parameters set to free in the model will be calculated.
            Default: False
            
        suppress_alg --
            Suppress the algebraic variables in the error test.
            Default: False
            
        suppress_sens --
            Suppress the sensitivity variables in the error test.
            Default: true
    
    Options for CVode::
    
        rtol    --
            The relative tolerance. 
            Default: 1.0e-6
                
        atol    --
            The absolute tolerance.
            Default: 1.0e-6
                  
        discr   --
            The discretization method. Can be either 'BDF' or 'Adams'.
            Default: 'BDF'
        
        iter    --
            The iteration method. Can be either 'Newton' or 'FixedPoint'.
            Default: 'Newton'
    """
    def __init__(self, *args, **kw):
        _defaults= {
            'solver': 'IDA', 
            'ncp':0, 
            'initialize':True,
            'write_scaled_result':False,
            'result_file_name':'',
            'report_continuously':False,
            'IDA_options':{'atol':1.0e-6,'rtol':1.0e-6,
                           'maxord':5,'sensitivity':False,
                           'suppress_alg':False, 'suppress_sens':True},
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
    """ 
    Simulation algorithm using the Assimulo package. 
    """
    
    def __init__(self,
                 start_time,
                 final_time,
                 input,
                 model,
                 options):
        """ 
        Create a simulation algorithm using Assimulo.
        
        Parameters::
        
            model -- 
                jmi.Model object representation of the model
                
            options -- 
                The options that should be used in the algorithm. For details on 
                the options, see:
                
                * model.simulate_options('AssimuloAlgOptions')
                
                or look at the docstring with help:
                
                * help(pyjmi.jmi_algorithm_drivers.AssimuloAlgOptions)
                
                Valid values are: 
                - A dict which gives AssimuloAlgOptions with default values on 
                  all options except the ones listed in the dict. Empty dict 
                  will thus give all options with default values.
                - AssimuloAlgOptions object.
        """
        self.model = model
        
        #Internal values
        self.sensitivity = False
        
        if not assimulo_present:
            raise Exception(
                'Could not find Assimulo package. Check pyjmi.check_packages()')
        
        # set start time, final time and input trajectory
        self.start_time = start_time
        self.final_time = final_time
        self.input = input
        
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

        input_traj = None
        if self.input:
            if hasattr(self.input[1],"__call__"):
                input_traj=(self.input[0],
                        TrajectoryUserFunction(self.input[1]))
            else:
                input_traj=(self.input[0], 
                        TrajectoryLinearInterpolation(self.input[1][:,0], 
                                                      self.input[1][:,1:]))
            #Sets the inputs, if any
            self.model.set(input_traj[0], input_traj[1].eval(self.start_time)[0,:])
        
        if issubclass(self.solver, Implicit_ODE):
            if not self.input:
                if not self.sensitivity:
                    self.probl = JMIDAE(model,result_file_name=self.result_file_name, start_time=self.start_time)
                else:
                    self.probl = JMIDAESens(model,result_file_name=self.result_file_name, start_time=self.start_time)
            else:
                if not self.sensitivity:
                    self.probl = JMIDAE(model,input_traj, \
                                                      self.result_file_name, start_time=self.start_time)
                else:
                    self.probl = JMIDAESens(model,input_traj, \
                                                      self.result_file_name, start_time=self.start_time)
        else:
            raise Exception("The solver does not support solving an DAE.")
            
        # instantiate solver and set options
        self.simulator = self.solver(self.probl)
        self._set_solver_options()
        
    def _set_options(self):
        """ 
        Helper function that sets options for Assimulo algorithm.
        """
        # no of communication points
        self.ncp = self.options['ncp']
        
        # solver
        solver = self.options['solver']
        if hasattr(solvers, solver):
            self.solver = getattr(solvers, solver)
        else:
            raise InvalidAlgorithmOptionException(
                "The solver: "+solver+ " is unknown.")
            
        # do initialize?
        self.initialize = self.options['initialize']

        # write scaled result?
        self.write_scaled_result = self.options['write_scaled_result']
        
        # result file name
        if self.options['result_file_name'] == '':
            self.result_file_name = self.model.get_identifier()+'_result.txt'
        else:
            self.result_file_name = self.options['result_file_name']
        
        # solver options
        try:
            self.solver_options = self.options[solver+'_options']
        except KeyError: #Default solver options not found
            self.solver_options = {} #Empty dict
        
        # sensitivity
        self.sensitivity = self.solver_options.get('sensitivity',False)
        #self.solver_options.pop('sensitivity',False)

        # report_continuously is currently crucial when solving sensitivity problems
        if self.sensitivity:
            if not self.options["report_continuously"]:
                self.options["report_continuously"] = True
                logging.warning("Reporting continuously is necessary when solving sensitivity problems, "
                                "setting report_continuously to True.")
                
        if self.sensitivity and self.solver_options['maxord']==5:
            logging.warning("Maximum order when using IDA for simulating "
                    "sensitivities is currently limited to 4.")
            self.solver_options['maxord']=4
        
    def _set_solver_options(self):
        """ 
        Helper functions that sets options for the solver.
        """
        #Continouous output
        self.simulator.report_continuously = self.options["report_continuously"]
        
        #loop solver_args and set properties of solver
        for k, v in self.solver_options.iteritems():
            if k == 'sensitivity':
                continue
            try:
                getattr(self.simulator,k)
            except AttributeError:
                try:
                    getattr(self.probl,k)
                except AttributeError:
                    raise InvalidSolverArgumentException(k)
                setattr(self.probl, k, v)
                continue
            setattr(self.simulator, k, v)
                
    def solve(self):
        """ 
        Runs the simulation. 
        """
        if self.sensitivity:
            if self.initialize:
                self.simulator.make_consistent('IDA_YA_YDP_INIT')
        else:
            # Only run initiate if model has been compiled with CppAD
            # and if alg arg 'initialize' is True.
            if self.model.has_cppad_derivatives() and self.initialize:
                pass
            else:
                self.probl._no_initialization = True
        self.simulator.simulate(self.final_time, self.ncp)
 
    def get_result(self):
        """ 
        Write result to file, load result data and create an AssimuloSimResult 
        object.
        
        Returns::
        
            The AssimuloSimResult object.
        """
        if not self.simulator.report_continuously:
            write_data(self.simulator,self.write_scaled_result, self.result_file_name)
        #write_data(self.simulator,self.write_scaled_result,self.result_file_name)
        # load result file
        res = ResultDymolaTextual(self.result_file_name)
        
        # create and return result object
        return AssimuloSimResult(self.model, self.result_file_name, self.simulator, res, 
            self.options)
    
    @classmethod
    def get_default_options(cls):
        """ 
        Get an instance of the options class for the AssimuloAlg algorithm, 
        prefilled with default values. (Class method.)
        """
        return AssimuloAlgOptions()

class CollocationLagrangePolynomialsResult(JMResultBase):

    """
    A JMResultBase object with the additional attribute times.
    
    Attributes::
    
        times --
            A dictionary with the keys 'init', 'sol', 'post_processing' and
            'tot', which measure CPU time consumed during different algorithm
            stages.

            times['init'] is the time spent creating the NLP.
            
            times['sol'] is the time spent solving the NLP (total Ipopt
            time).
            
            times['post_processing'] is the time spent processing the NLP
            solution before it is returned.
            
            times['tot'] is the sum of all the other times.
            
            Type: dict
    """
    
    def __init__(self, model=None, result_file_name=None, solver=None, 
             result_data=None, options=None, times=None):
        super(CollocationLagrangePolynomialsResult, self).__init__(
                model, result_file_name, solver, result_data, options)
        self.times = times

        # Print times
        print("\nTotal time: %.2f seconds" % times['tot'])
        print("Initialization time: %.2f seconds" % times['init'])
        print("Solution time: %.2f seconds" % times['sol'])
        print("Post-processing time: %.2f seconds" % times['post_processing'])

class CollocationLagrangePolynomialsAlgOptions(OptionBase):
    """
    Options for optimizing JMU models using a collocation algorithm. 

    Collocation algorithm options::
    
        n_e --
            Number of elements of the finite element mesh.
            Default: 50
            
        n_cp --
            Number of collocation points in each element. Values between 1 and 
            10 are supported
            Default: 3
            
        hs --
            A vector containing n_e elements representing the finite element 
            lengths. The sum of all element should equal to 1.
            Default: numpy.ones(n_e)/n_e (Uniform mesh)
            
        blocking_factors --
            A vector of blocking factors. Blocking factors are specified by a 
            vector of integers, where each entry in the vector corresponds to 
            the number of elements for which the control profile should be kept 
            constant. For example, the blocking factor specification [2,1,5] 
            means that u_0=u_1 and u_3=u_4=u_5=u_6=u_7 assuming that the number 
            of elements is 8. Notice that specification of blocking factors 
            implies that controls are present in only one collocation point 
            (the first) in each element. The number of constant control levels 
            in the optimization interval is equal to the length of the blocking 
            factor vector. In the example above, this implies that there are 
            three constant control levels. If the sum of the entries in the 
            blocking factor vector is not equal to the number of elements, the
            vector is normalized, either by truncation (if the sum of the 
            entries is larger than the number of element) or by increasing the 
            last entry of the vector. For example, if the number of elements is 
            4, the normalized blocking factor vector in the example is [2,2]. 
            If the number of elements is 10, then the normalized vector is 
            [2,1,7].
            Default: None
            
        init_traj --
            Variable trajectory data used for initialization of the optimization 
            problem. The data is represented by an object of the type 
            pyjmi.common.io.DymolaResultTextual.
            Default: None
            
        result_mode --
            Specifies the output format of the optimization result.
             - 'default' gives the the optimization result at the collocation 
               points.
             - 'element_interpolation' computes the values of the variable 
               trajectories using the collocation interpolation polynomials. The 
               option 'n_interpolation_points' is used to specify the number of 
               evaluation points within each finite element.
             - 'mesh_interpolation' computes the values of the variable
               trajectories at points defined by the option 'result_mesh'.
            Default: 'default'
            
        n_interpolation_points --
            Number of interpolation points in each finite element if the result 
            reporting option result_mode is set to 'element_interpolation'.
            Default: 20
            
        result_mesh --
            A vector of time points at which the the optimization result is 
            computed. This option is used if result_mode is set to 
            'mesh_interpolation'.
            Default: None
            
        result_file_name --
            Specifies the name of the file where the optimization result is 
            written. Setting this option to an empty string results in a default 
            file name that is based on the name of the optimization class.
            Default: Empty string
            
        result_format --
            Specifies in which format to write the result. Currently
            only textual mode is supported.
            Default: 'txt'

        write_scaled_result --
            Write the scaled optimization result if set to true. This option is 
            only applicable when automatic variable scaling is enabled. Only for 
            debugging use.
            Default: False.

    Options are set by using the syntax for dictionaries::

        >>> opts = my_model.optimize_options()
        >>> opts['n_e'] = 100
        
    In addition, IPOPT options can be provided in the option IPOPT_options. For 
    a complete list of IPOPT options, please consult the IPOPT documentation 
    available at http://www.coin-or.org/Ipopt/documentation/).

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
    The algorithm is based on orthogonal collocation and relies on the solver 
    IPOPT for solving a non-linear programming problem. 
    """
    
    def __init__(self, 
                 model, 
                 options):
        """
        Create a CollocationLagrangePolynomials algorithm.
        
        Parameters::
              
            model -- 
                pyjmi.jmi.JMUModel model object

            options -- 
                The options that should be used by the algorithm. For 
                details on the options, see:
                
                * model.simulate_options('CollocationLagrangePolynomialsAlgOptions')
                
                or look at the docstring with help:
                
                * help(pyjmi.jmi_algorithm_drivers.CollocationLagrangePolynomialsAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by CollocationLagrangePolynomialsAlgOptions. An empty
                  dict will thus give all options with default values.
                - A CollocationLagrangePolynomialsAlgOptions object.
        """
        self._t0 = time.clock()
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
            raise Exception(
                'Could not find IPOPT. Check pyjmi.check_packages()')

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
        """ 
        Helper function that sets options for the CollocationLagrangePolynomials 
        algorithm.
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
        """ 
        Helper function that sets options for the solver.
        """
        for k, v in self.solver_options.iteritems():
            if isinstance(v, default_int):
                self.nlp_ipopt.opt_coll_ipopt_set_int_option(k, v)
            elif isinstance(v, float):
                self.nlp_ipopt.opt_coll_ipopt_set_num_option(k, v)
            elif isinstance(v, basestring):
                self.nlp_ipopt.opt_coll_ipopt_set_string_option(k, v)
                        
    def solve(self):
        """ 
        Solve the optimization problem using ipopt solver. 
        """
        times = {}
        solve_t0 = time.clock() - self._t0
        try:
            self.nlp_ipopt.opt_coll_ipopt_solve()
        finally:
            self._write_result()
        times['sol'] = time.clock() - self._t0 - solve_t0
        
        # Calculate times
        times['tot'] = time.clock() - self._t0
        times['init'] = times['tot'] - times['sol']
        
        # Store times as data attribute
        self.times = times
        
    def _write_result(self):
        """
        Helper method. Write result to file.
        """
        if self.result_mode=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(
                **self.result_args)
        elif self.result_mode=='mesh_interpolation':
            self.nlp.export_result_dymola_mesh_interpolation(**self.result_args)
        elif self.result_mode=='default':
            self.nlp.export_result_dymola(**self.result_args)
        else:
             raise InvalidAlgorithmArgumentException(self.result_mode)
            
        # Set result file name
        if not self.result_args['file_name']:
            self.result_args['file_name'] = self.model.get_identifier()+'_result.txt'
        
    def get_result(self):
        """ 
        Load result data and create a CollocationLagrangePolynomialsResult 
        object.
        
        Returns::
        
            The CollocationLagrangePolynomialsResult object.
        """
        # load result file
        resultfile = self.result_args['file_name']
        res = ResultDymolaTextual(resultfile)
        
        # Calculate post-processing and total time
        times = self.times
        times['post_processing'] = time.clock() - self._t0 - times['tot']
        times['tot'] += times['post_processing']
        
        # create and return result object
        return CollocationLagrangePolynomialsResult(
                self.model, resultfile, self.nlp_ipopt, res, self.options,
                self.times)
        
    @classmethod
    def get_default_options(cls):
        """ 
        Get an instance of the options class for the 
        CollocationLagrangePolynomialsAlg algorithm, prefilled with default 
        values. (Class method.)
        """
        return CollocationLagrangePolynomialsAlgOptions()
    
class KInitSolveResult(JMResultBase):
    pass

class KInitSolveAlgOptions(OptionBase):
    """
    Options for the initialization of a JMU using the KInitSolve algorithm based 
    on the KINSOL wrapper in the assimulo package.
    
    KInitSolve options::
            
        use_constraints --
            Boolean set to True if constraints are to be used. If set to False,
            the initialization will not be constraind even if constraints are
            supplied by the user. If set to True but constraints are not 
            supplied please see the documentation of constraints below.
            Default: False
            
        constraints --
            Numpy.array that should be of same size as the number of variables.
            The array contains numbers specifying what type of constraint to use 
            for each variable. The array contains the following number in the 
            ith position:
                0.0  -  no constraint on x[i]
                1.0  -  x[i] greater or equal than 0.0
                -1.0 -  x[i] lesser or equal than 0.0
                2.0  -  x[i] greater than 0.0
                -2.0 -  x[i] lesser than 0.0
                
            If no constraints are supplied but use_constraints are set to True
            the solver will 'guess' constraints basically meaning that the sign 
            of a variable is kept the same as the sign of the initial guess for 
            the variable.
            Default: None
            
        result_file_name --
            A string containing the name of the file the results should be 
            written to. If not specified the name of the model will be used.
            Default: ''
            
        result_format --
            A string specifying the format of the output file. So far only 
            '.txt' is supported
            Default: '.txt'
            
    The solver used by kinitsol is KINSOL, the options for KINSOL is passed in 
    the dictionary KINSOL_options. The options are listed below:
        
    KINSOL options::
        use_jac --
            Boolean set to True if the jacobian supplied by the JMUmodel is to 
            be used in the solving of the initialization problem. If set to 
            False a jacobian generated by KINSOL using finite differences is 
            used.
            Default: True
            
        sparse --
            Boolean set to True if the problem is to be treated as sparse and False
            otherwise. Only works with the KINSOL option use_jac = True!
            Dafault: False
        
        verbosity --
            Integer regulationg the level of information
            output from KINSOL. Must be set to one of:
                0:  no information displayed.
                1:  for each nonlinear iteration display the following information:
                    - the scaled Euclidean ‚Ñì2 norm of the residual evaluated at
                      the current iterate
                    - the scaled norm of the Newton step
                    - the number of function evaluations performed so far.
                2:  display level 1 output and the following values for each iteration:
                    - the 2-norm and infinitynorm of the scaled residual at 
                      the current iterate
                3:  display level 2 output plus additional values used by the global strategy,
                    and statistical information for the linear solver.
            Default: 0
                
                      

    """
    def __init__(self, *args, **kw):
        _defaults= {
            'use_constraints':False,
            'constraints':None,
            'result_file_name':'', 
            'result_format':'txt',
            'KINSOL_options':{'use_jac':True,'sparse':False,'verbosity':0,'reg_param':0.0}
            }
        super(KInitSolveAlgOptions,self).__init__(_defaults)
        # for those key-value-sets where the value is a dict, don't 
        # overwrite the whole dict but instead update the default dict 
        # with the new values
        self._update_keep_dict_defaults(*args, **kw)
        
class KInitSolveAlg(AlgorithmBase):
    """ 
    Initialization using a solver of non-linear eq-systems.
    """

    def __init__(self, model, options):
        """ 
        Create algorithm objects.
        
        Parameters::
        
            model -- 
                pyjmi.jmi.JMUModel object representation of the model.
            options -- 
                The options that should be used in the algorithm. For details on 
                the options, see:
                
                * model.simulate_options('KInitSolveAlgOptions')
                
                or look at the docstring with help:
                
                * help(pyjmi.jmi_algorithm_drivers.KInitSolveAlgOptions)
                
                Valid values are: 
                - A dict which gives KInitSolveAlgOptions with default values on 
                  all options except the ones listed in the dict. Empty dict 
                  will thus give all options with default values.
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
        
        # instantiate problem    
        self.problem = JMUAlgebraic(model,use_jac = self.options['KINSOL_options']['use_jac'])
        
        # set options
        self._set_options()
        
        # connect solver and set solver options
        self.solver = KINSOL(self.problem)
        self._set_solver_options()
        
    def _set_options(self):
        """
        Helper function that sets options for the KInitSolve algorithm.
        """
        self.problem.set_constraints_usage(self.options['use_constraints'],
            self.options['constraints'])
        self.result_args = dict(file_name=self.options['result_file_name'], 
            format=self.options['result_format'])
        
        self.solver_options = self.options['KINSOL_options']
          
    def _set_solver_options(self):
        """
        Helper function that sets options for the KINSOL solver.
        """
        self.solver.set_jac_usage(self.solver_options['use_jac'])
        self.solver.set_verbosity(self.solver_options['verbosity'])
        self.solver.set_sparsity(self.solver_options['sparse'])
        self.solver.set_reg_param(self.solver_options['reg_param'])

    def solve(self):
        """
        Functions calling the solver to solve the problem
        """
        try:
            res = self.solver.solve()
        finally:
            self._write_result()
        
        dx = res[0:self.problem._dx_size]
        x = res[self.problem._dx_size:self.problem._mark]
        w = res[self.problem._mark:self.problem._neqF0]
            
        self.model.real_dx = dx
        self.model.real_x = x
        self.model.real_w = w
        
    def _write_result(self):
        """
        Helper method. Write result to file.
        """
        write_resdata(self.problem)
        
        # Set result file name
        if not self.result_args['file_name']:
            self.result_args['file_name'] = self.model.get_identifier()+'_result.txt'

    def get_result(self):
        """ 
        Load result data and create an NLSInitResult object.
        
        Returns::
        
            The NLSInitResult object.
        """
        # load result file
        resultfile = self.result_args['file_name']
        res = ResultDymolaTextual(resultfile)
        
        # create and return result object
        return KInitSolveResult(self.model, resultfile, self.solver, res, 
            self.options)
        
    @classmethod
    def get_default_options(cls):
        """ 
        Get an instance of the options class for the KInitSolveAlg algorithm, 
        prefilled with default values. (Class method.)
        """
        return KInitSolveAlgOptions()


class LocalDAECollocationPrepareAlg(AlgorithmBase):
    """
    Carries out the setup parts of LocalDAECollocationAlg.
    """
    def __init__(self, op, options):
        """
        Create a LocalDAECollocationPrepareAlg

        Arguments are the same as for LocalDAECollocationAlg.
        """
        self.alg = LocalDAECollocationAlg(op, options)
        self.solver = casadi_collocation.OptimizationSolver(self.alg.nlp)

    def solve(self):
        pass

    def get_result(self):
        return self.solver


class LocalDAECollocationAlg(AlgorithmBase):
    
    """
    The algorithm is based on orthogonal collocation and relies on the solver 
    IPOPT for solving the arising non-linear programming problem.
    """
    
    def __init__(self, op, options):
        """
        Create a LocalDAECollocationAlg algorithm.
        
        Parameters::
              
            op -- 
                OptimizationProblem from CasADiInterface

            options -- 
                The options that should be used by the algorithm. For 
                details on the options, see:
                
                model.optimize_options('LocalDAECollocationAlgOptions')
                
                or look at the docstring with help:
                
                help(pyjmi.jmi_algorithm_drivers.LocalDAECollocationAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by LocalDAECollocationAlgOptions. An empty
                  dict will thus give all options with default values.
                - A LocalDAECollocationAlgOptions object.
        """
        t0_init = time.clock()
        self.op = op
        model = op
        self.model = model

        # Check that model does not contain any unsupported variables
        var_kinds = [(model.BOOLEAN_DISCRETE, "Boolean discrete"),
                     (model.BOOLEAN_INPUT, "Boolean input"),
                     (model.INTEGER_DISCRETE, "integer discrete"),
                     (model.INTEGER_INPUT, "integer input"),
                     (model.REAL_DISCRETE, "real discrete"),
                     (model.STRING_DISCRETE, "string discrete"),
                     (model.STRING_INPUT, "string input")]
        error_str = ''
        for (kind, name) in var_kinds:
            variables = model.getVariables(kind)
            if len(variables) == 1:
                var_name = variables[0].getName()
                error_str += ("The following variable is %s, which " % name +
                              "is not supported: %s.\n\n" % var_name)
            elif len(variables) > 1:
                error_str += ("The following variables are %s, " % name +
                              "which is not supported: ")
                for var in variables[:-1]:
                    error_str += var.getName() + ", "
                error_str += variables[-1].getName() + ".\n\n"

        # Check for unsupported free parameters
        var_kinds = [(model.BOOLEAN_PARAMETER_DEPENDENT,
                      "Boolean parameter dependent"),
                     (model.BOOLEAN_PARAMETER_INDEPENDENT,
                      "Boolean parameter independent"),
                     (model.INTEGER_PARAMETER_DEPENDENT,
                      "integer parameter dependent"),
                     (model.INTEGER_PARAMETER_INDEPENDENT,
                      "integer parameter independent"),
                     (model.STRING_PARAMETER_DEPENDENT,
                      "string parameter dependent"),
                     (model.STRING_PARAMETER_INDEPENDENT,
                      "string parameter independent")]
        for (kind, name) in var_kinds:
            variables = [var for var in model.getVariables(kind)
                         if op.get_attr(var, "free")]
            if len(variables) == 1:
                var_name = variables[0].getName()
                error_str += ("The following parameter is %s and free, "%name +
                              "which is not supported: %s.\n\n" % var_name)
            elif len(variables) > 1:
                error_str += ("The following parameters are %s and " % name +
                              "free, which is not supported: ")
                for var in variables[:-1]:
                    error_str += var.getName() + ", "
                error_str += variables[-1].getName() + ".\n\n"
        if len(error_str) > 0:
            raise Exception(error_str)
        
        # handle options argument
        if isinstance(options, dict):
            # user has passed dict with options or empty dict = default
            self.options = LocalDAECollocationAlgOptions(options)
        elif isinstance(options, LocalDAECollocationAlgOptions):
            # user has passed LocalDAECollocationAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)

        # set options
        self._set_options()
            
        if not casadi_present:
            raise Exception(
                    'Could not find CasADi. Check pyjmi.check_packages()')
        
        self.nlp = LocalDAECollocator(self.op, self.options)
            
        # set solver options
        self._set_solver_options()

        # record the initialization time including initialization within the algorithm object
        self.nlp.times['init'] = time.clock() - t0_init
        
    def _set_options(self):
        """ 
        Set algorithm options and assert their validity.
        """
        self.__dict__.update(self.options)
        defaults = self.get_default_options()
        
        # Check validity of element lengths
        if self.hs != "free" and self.hs is not None:
            self.hs = list(self.hs)
            if len(self.hs) != self.n_e:
                raise ValueError("The number of specified element lengths " +
                                 "must be equal to the number of elements.")
            if not N.allclose(N.sum(self.hs), 1):
                raise ValueError("The sum of all elements lengths must be" +
                                 "(almost) equal to 1.")
        if self.h_bounds != defaults['h_bounds']:
            if self.hs != "free":
                raise ValueError("h_bounds is only used if algorithm " + \
                                 'option hs is set to "free".')
        
        # Check validity of free_element_lengths_data
        if self.free_element_lengths_data is None:
            if self.hs == "free":
                raise ValueError("free_element_lengths_data must be given " + \
                                 'if self.hs == "free".')
        if self.free_element_lengths_data is not None:
            if self.hs != "free":
                raise ValueError("free_element_lengths_data can only be " + \
                                 'given if self.hs == "free".')
        
        # Check validity of discr
        if self.discr == "LGL":
            raise NotImplementedError("Lobatto collocation is currently " + \
                                      "not supported.")
        elif self.discr != "LG" and self.discr != "LGR":
            raise ValueError("Unknown discretization scheme %s." % self.discr)
        
        # Check validity of quadrature_constraint
        if (self.discr == "LG" and self.eliminate_der_var and
            self.quadrature_constraint):
            raise NotImplementedError("quadrature_constraint is not " + \
                                      "compatible with eliminate_der_var.")

        # Check validity of init_dual
        if self.init_dual is not None and self.solver == "IPOPT":
            try:
                warm_start = self.IPOPT_options['warm_start_init_point']
            except KeyError:
                warm_start = False
            if not warm_start:
                print("Warning: The provided initial guess for the dual " +
                      "variables will not be used since warm start is not " +
                      "enabled for IPOPT.")

        # Check validity of blocking_factors
        if self.blocking_factors is not None:
            if isinstance(self.blocking_factors, collections.Iterable):
                if N.sum(self.blocking_factors) != self.n_e:
                    raise ValueError(
                            "The sum of blocking factors does not " +
                            "match the number of collocation elements.")
            elif isinstance(self.blocking_factors, BlockingFactors):
                for (name, facs) in self.blocking_factors.factors.iteritems():
                    var = self.op.getVariable(name)
                    if var is None:
                        raise ValueError('Variable %s not found in ' % name +
                                         'optimization problem.')
                    if var not in self.op.getVariables(self.op.REAL_INPUT):
                        raise ValueError(
                                "Blocking factors provided for variable " +
                                "%s, but %s is not a real " % (name, name) +
                                "input.")

                    # Check that factors correspond to number of elements
                    if N.sum(facs) != self.n_e:
                        raise ValueError(
                                "The sum of blocking factors for variable " +
                                "%s does not match the number of " % name +
                                "collocation elements.")

                    # Check if variable is in optimization problem
                    if var is None:
                        raise ValueError(
                                "Blocking factors provided for variable " +
                                "%s, but variable %s not " % (name, name) +
                                "found in optimization problem.")

                    # Check bound
                    if name in self.blocking_factors.du_bounds:
                        if self.blocking_factors.du_bounds[name] < 0:
                            raise ValueError("du bound for variable %s "%name+
                                             "is negative.")

                    # Replace alias variables
                    if var.isAlias():
                        mvar = var.getModelVariable()
                        self.blocking_factors.factors[mvar.getName()] = facs
                        del self.blocking_factors.factors[name]
                        if name in self.blocking_factors.du_bounds:
                            self.blocking_factors.du_bounds[mvar.getName()] = \
                                    self.blocking_factors.du_bounds[name]
                            del self.blocking_factors.du_bounds[name]
                        if name in self.blocking_factors.du_quad_pen:
                            self.blocking_factors.du_quad_pen[mvar.getName()]=\
                                    self.blocking_factors.du_quad_pen[name]
                            del self.blocking_factors.du_quad_pen[name]
            else:
                raise ValueError('blocking_factors must either be an ' +
                                 'iterable or an instance of BlockingFactors.')
        
        # Check validity of nominal_traj_mode
        for name in self.nominal_traj_mode.keys():
            if name != "_default_mode":
                var = self.op.getVariable(name)
                if var is None:
                    raise ValueError(
                            "Nominal mode provided for variable %s, " % name +
                            "but variable %s not found in " % name +
                            "optimization problem.")
                if var.isAlias():
                    mvar = var.getModelVariable()
                    self.nominal_traj_mode[mvar.getName()] = \
                            self.nominal_traj_mode[name]
                    del self.nominal_traj_mode[name]

        # Check validity of check point
        if self.checkpoint and self.blocking_factors is not None:
            raise NotImplementedError("Checkpoint does not work with " +
                                      "blocking factors.")
        # Solver options
        if self.solver == "IPOPT":
            self.solver_options = self.IPOPT_options
        elif self.solver == "WORHP":
            self.solver_options = self.WORHP_options
        else:
            raise ValueError('Unknown nonlinear programming solver %s.' %
                             self.solver)
        
    def _set_solver_options(self):
        """ 
        Helper function that sets options for the solver.
        """
        for (k, v) in self.solver_options.iteritems():
            self.nlp.set_solver_option(k, v)
            
    def solve(self):
        """ 
        Solve the optimization problem using ipopt solver. 
        """
        self.nlp.solve_and_write_result()

    def get_result(self):
        """ 
        Load result data and create a LocalDAECollocationAlgResult object.
        
        Returns::
        
            The LocalDAECollocationAlgResult object.
        """
        return self.nlp.get_result_object()

    @classmethod
    def get_default_options(cls):
        """ 
        Get an instance of the options class for the LocalDAECollocationAlg
        algorithm, prefilled with default values. (Class method.)
        """
        return LocalDAECollocationAlgOptions()
    
class LocalDAECollocationAlgOptions(OptionBase):
    
    """
    Options for optimizing CasADi models using a collocation algorithm. 

    Collocation algorithm options::
    
        n_e --
            Number of finite elements.
            
            Type: int
            Default: 50
        
        hs --
            Element lengths.
            
            Possible values: None, iterable of floats and "free"
            
            None: The element lengths are uniformly distributed.
            
            iterable of floats: Component i of the iterable specifies the
            length of element i. The lengths must be normalized in the sense
            that the sum of all lengths must be equal to 1.
            
            "free": The element lengths become optimization variables and are
            optimized according to the algorithm option
            free_element_lengths_data.
            WARNING: This option is very experimental and will not always give
            desirable results.
            
            Type: None, iterable of floats or string
            Default: None
        
        free_element_lengths_data --
            Data used for optimizing the element lengths if they are free.
            Should be None when hs != "free".
            
            Type: None or
            pyjmi.optimization.casadi_collocation.FreeElementLengthsData
            Default: None
        
        n_cp --
            Number of collocation points in each element.
            
            Type: int
            Default: 3
        
        discr --
            Determines the collocation scheme used to discretize the problem.
            
            Possible values: "LG" and "LGR".
            
            "LG": Gauss collocation (Legendre-Gauss).
            
            "LGR": Radau collocation (Legendre-Gauss-Radau).
            
            Type: str
            Default: "LGR"
        
        expand_to_sx --
            Whether to expand the CasADi MX graphs to SX graphs. Possible
            values: "NLP", "DAE", "no".

            "NLP": The entire NLP graph is expanded into SX. This will lead to
            high evaluation speed and high memory consumption.

            "DAE": The DAE, objective and constraint graphs for the dynamic
            optimization problem expressions are expanded into SX, but the full
            NLP graph is an MX graph. This will lead to moderate evaluation
            speed and moderate memory consumption.

            "no": All constructed graphs are MX graphs. This will lead to low
            evaluation speed and low memory consumption.
            
            Type: str
            Default: "NLP"

        named_vars --
            If enabled, the solver will create a duplicated set of NLP
            variables which have names corresponding to the Modelica/Optimica
            variable names. Symbolic expressions of the NLP consisting of the
            named variables can then be obtained using the get_named_var_expr
            method of the collocator class.

            This option is only intended for investigative purposes.

            Type: bool
            Default: False
        
        init_traj --
            Variable trajectory data used for initialization of the NLP
            variables.
            
            Type: None or pyjmi.common.io.ResultDymolaTextual or
                  pyjmi.common.algorithm_drivers.JMResultBase
            Default: None

        init_dual --
            Dictionary containing vectors of initial guess for NLP dual
            variables. Intended to be obtained as the solution of an
            optimization problem which has an identical structure, which is
            stored in the dual_opt attribute of the result object.

            The dictionary has two keys, 'g' and 'x', containing vectors of the
            corresponding dual variable intial guesses.

            Note that when using IPOPT, the option warm_start_init_point has to
            be activated for this option to have an effect.

            Type: None or dict
            Default: None

        variable_scaling --
            Whether to scale the variables according to their nominal values or
            the trajectories provided with the nominal_traj option.
            
            Type: bool
            Default: True
        
        nominal_traj --
            Variable trajectory data used for scaling of the NLP variables.
            This option is only applicable if variable scaling is enabled.
            
            Type: None or pyjmi.common.io.ResultDymolaTextual or
                  pyjmi.common.algorithm_drivers.JMResultBase
            Default: None
        
        nominal_traj_mode --
            Mode for computing scaling factors for each variable based on
            nominal trajectories. Four possible modes:
            
            "attribute": Time-invariant, linear scaling based on Nominal
            attribute
            
            "linear": Time-invariant, linear scaling
            
            "affine": Time-invariant, affine scaling
            
            "time-variant": Time-variant, linear scaling
            
            Option is a dictionary with variable names as keys and
            corresponding scaling modes as values. For all variables
            not occuring in the keys of the dictionary, the mode specified by
            the "_default_mode" entry will be used, which by default is
            "linear".
            
            Type: {str: str}
            Default: {"_default_mode": "linear"}
        
        result_file_name --
            Specifies the name of the file where the result is written. Setting
            this option to an empty string results in a default file name that
            is based on the name of the model class.

            Type: str
            Default: ""

        print_condition_numbers --
            Prints the condition numbers of the Jacobian of the constraints and
            of the simplified KKT matrix at the initial and optimal points.
            Note that this is only feasible for very small problems.

            Type: bool
            Default: False
        
        write_scaled_result --
            Return the scaled optimization result if set to True, otherwise
            return the unscaled optimization result. This option is only
            applicable when variable_scaling is enabled and is only intended
            for debugging.
            
            Type: bool
            Default: False
        
        result_mode --
            Specifies the output format of the optimization result.
            
            Possible values: "collocation_points", "element_interpolation" and
            "mesh_points"
            
            "collocation_points": The optimization result is given at the
            collocation points as well as the start and final time point.
            
            "element_interpolation": The values of the variable trajectories
            are calculated by evaluating the collocation polynomials. The
            algorithm option n_eval_points is used to specify the
            evaluation points within each finite element.
            
            "mesh_points": The optimization result is given at the
            mesh points.
            
            Type: str
            Default: "collocation_points"
        
        n_eval_points --
            The number of evaluation points used in each element when the
            algorithm option result_mode is set to "element_interpolation". One
            evaluation point is placed at each element end-point (hence the
            option value must be at least 2) and the rest are distributed
            uniformly.
            
            Type: int
            Default: 20
        
        blocking_factors --
            Blocking factors are used to enforce piecewise constant inputs. The
            inputs may only change values at some of the element boundaries.
            The option is either None (disabled), given as an instance of
            pyjmi.optimization.casadi_collocation.BlockingFactors or as a list
            of blocking factors.

            If the options is a list of blocking factors, then each element in
            the list specifies the number of collocation elements for which all
            of the inputs must be constant. For example, if blocking_factors ==
            [2, 2, 1], then the inputs will attain 3 different values (number
            of elements in the list), and it will change values between
            collocation element number 2 and 3 as well as number 4 and 5. The
            sum of all elements in the list must be the same as the number of
            collocation elements and the length of the list determines the
            number of separate values that the inputs may attain.

            See the documentation of the BlockingFactors class for how to use
            it.
            
            If blocking_factors is None, then the usual collocation polynomials
            are instead used to represent the controls.
            
            Type: None, iterable of ints, or instance of
                  pyjmi.optimization.casadi_collocation.BlockingFactors
            Default: None
        
        quadrature_constraint --
            Whether to use quadrature continuity constraints. This option is
            only applicable when using Gauss collocation. It is incompatible
            with eliminate_der_var set to True.
            
            True: Quadrature is used to get the values of the states at the
            mesh points.
            
            False: The Lagrange basis polynomials for the state collocation
            polynomials are evaluated to get the values of the states at the
            mesh points.
            
            Type: bool
            Default: True
            
        checkpoint --
            checkpoint is used to build the transcribed NLP with packed MX
            functions. Instead of calling the dae residual function, the 
            collocation equation function, and the lagrange term function 
            n_e\cdotn_cp times, the check point scheme builds an MXFunction 
            evaluating n_cp collocation points at the same time, so that the
            packed MXFunction is called only n_e times. This approach improves
            the code generation and it is expected to reduce the memory
            usage for constructing and solving the NLP.
            
            True: LocalDAECollocator builds the NLP with packed functions that
            are called for every element.
            
            False: LocalDAECollocator builds the NLP with common CasADi functions
            that are called for every collocation point in each element.
            
            Type: bool
            Default: False
        
        eliminate_der_var --
            True: The variables representing the derivatives are eliminated
            via the collocation equations and are thus not a part of the NLP,
            with the exception of \dot{x}_{1, 0}, which is not eliminated since
            the collocation equations are not enforced at t_0.
            
            False: The variables representing the derivatives are kept as NLP
            variables and the collocation equations enter as constraints.
            
            Type: bool
            Default: False
        
        eliminate_cont_var --
            True: Let the same variables represent both the values of the
            states at the start of each element and the end of the previous
            element.
            
            False:
            For Radau collocation, the extra variables x_{i, 0}, representing
            the states at the start of each element, are created and then
            constrained to be equal to the corresponding variable at the end of
            the previous element for continuity.
            
            For Gauss collocation, the extra variables x_{i, n_cp + 1},
            representing the states at the end of each element, are created
            and then constrained to be equal to the corresponding variable at
            the start of the succeeding element for continuity.
            
            Type: bool
            Default: False
        
        external_data --
            Data used to penalize, constrain or eliminate certain variables.
            
            Type: None or
            pyjmi.optimization.casadi_collocation.ExternalData
            Default: None

        mutable_external_data --
            True: If the external_data option is used, the external data
            can be changed after discretization, e.g. during warm starting.

            Type: bool
            Default: True

        delayed_feedback --
            Experimental feature used to add delay constraints to the
            optimization problem.

            If not None, should be a dict with mappings
            'delayed_var': ('undelayed_var', delay_ne).
            For each such pair, adds the the constraint that the variable
            'delayed_var' equals the value of the variable 'undelayed_var'
            delayed by delay_ne elements. The initial part of the trajectory
            for 'delayed_var' is fixed to its initial guess given by the
            init_traj option or the initialGuess attribute.

            'delayed_var' will typically be an input.
            This is an experimental feature and is subject to change.

            Type: None or dict
            Default: None

        solver --
            Specifies the nonlinear programming solver to be used. Possible
            choices are 'IPOPT' and 'WORHP'.

            Type: String
            Default: 'IPOPT'

        explicit_hessian --
            Explicitly construct the Lagrangian Hessian, rather than rely on
            CasADi to automatically generate it. This is only done to
            circumvent a bug in CasADi, see #????, which rarely causes the
            automatic Hessian to be incorrect.

            Type: bool
            Default: False

    Options are set by using the syntax for dictionaries::

        >>> opts = my_model.optimize_options()
        >>> opts['n_e'] = 100
    
    Options for the nonlinear programming solver can be provided in the option
    <solver name>_options, using the syntax for dictionaries::
        
        >>> opts['IPOPT_options']['max_iter'] = 500
    """
    
    def __init__(self, *args, **kw):
        _defaults = {
                'n_e': 50,
                'hs': None,
                'free_element_lengths_data': None,
                'h_bounds': (0.7, 1.3),
                'n_cp': 3,
                'discr': "LGR",
                'expand_to_sx': "NLP",
                'named_vars': False,
                'init_traj': None,
                'init_dual': None,
                'variable_scaling': True,
                'nominal_traj': None,
                'nominal_traj_mode': {"_default_mode": "linear"},
                'result_file_name': "",
                'write_scaled_result': False,
                'print_condition_numbers': False,
                'result_mode': "collocation_points",
                'n_eval_points': 20,
                'blocking_factors': None,
                'quadrature_constraint': True,
                'eliminate_der_var': False,
                'eliminate_cont_var': False,
                'external_data': None,
                'mutable_external_data': True,
                'checkpoint': False,
                'delayed_feedback': None,
                'solver': 'IPOPT',
                'explicit_hessian': False,
                'IPOPT_options': {},
                'WORHP_options': {}}
        
        super(LocalDAECollocationAlgOptions, self).__init__(_defaults)
        self._update_keep_dict_defaults(*args, **kw)
            
class MPCAlgResult(JMResultBase):
    def __init__(self, model=None, result_file_name=None, solver=None, 
                 result_data=None, options=None, times=None, nbr_samp=None, 
                 sample_period = None):
        super(MPCAlgResult, self).__init__(
                model, result_file_name, solver, result_data, options)

              
        #Print times 
        print("\nTotal time for %s samples (average time in parenthesis)." 
                %(nbr_samp))
        print("\nInitialization time: %.2f seconds" %times['init'])
        print("\nTotal time: %.2f seconds             (%.3f)" % (times['tot'], 
                times['tot']/(nbr_samp)))
        print("Pre-processing time: %.2f seconds    (%.3f)" % (times['update'],
                times['update']/(nbr_samp)))
        print("Solution time: %.2f seconds          (%.3f)" % (times['sol'], 
                times['sol']/(nbr_samp)))
        print("Post-processing time: %.2f seconds   (%.3f)" % 
                (times['post_processing'], times['post_processing']/(nbr_samp)))
        print("\nLargest total time for one sample (nbr %s): %.2f seconds" %
                (times['maxSample'], times['maxTime']))
        print("The sample period is %.2f seconds\n" %sample_period)
