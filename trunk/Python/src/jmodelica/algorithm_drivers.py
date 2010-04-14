""" Module for optimization and simulation algorithms to be used together with 
jmodelica.optimize and jmodelica.simulate
"""
#from abc import ABCMeta, abstractmethod
import warnings
import numpy as N

from jmodelica.optimization import ipopt
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

try:
    from jmodelica.simulation.assimulo import JMIDAE, JMIODE, write_data
    from Assimulo import Implicit_ODE
    from Assimulo import Explicit_ODE
    from Assimulo.Implicit_ODE import *
    from Assimulo.Explicit_ODE import *
except:
    pass

int = N.int32
N.int = N.int32

class AlgorithmBase:
#    __metaclass__=ABCMeta
    
#    @abstractmethod
    def __init__(self, model, alg_args): pass
    
#    @abstractmethod        
    def set_solver_options(self, solver_args): pass
    
#    @abstractmethod
    def solve(self): pass
    
#    @abstractmethod
    def write_result(self): pass

class AssimuloAlg(AlgorithmBase):
    """ Simulation algorithm using the Assimulo package. """
    
    def __init__(self, 
                 model, 
                 alg_args={}):
        self.model = model
        
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
        
        if issubclass(self.solver, Implicit_ODE):
            probl = JMIDAE(model)
        else:
            probl = JMIODE(model)
        self.simulator = self.solver(probl, t0=self.start_time)
        
    def _set_alg_args(self,
                      start_time=0.0,
                      final_time=1.0,
                      num_communication_points=500,
                      solver=IDA):
        self.start_time=start_time
        self.final_time=final_time
        self.num_communication_points=num_communication_points
        self.solver=solver
        
    def set_solver_options(self, 
                           solver_args={}):
        #loop solver_args and set properties of solver
        for k, v in solver_args.iteritems():
            try:
                setattr(self.simulator, k, v)
            except AttributeError:
                raise InvalidSolverArgumentException(v)
                
    def solve(self):
        self.simulator(self.final_time, self.num_communication_points)
    
    def write_result(self):
        write_data(self.simulator)
        return self.model.get_name()+'_result.txt'

  
class CollocationLagrangePolynomialsAlg(AlgorithmBase):
    """ Optimization algorithm using CollocationLagrangePolynomials method. """
    
    def __init__(self, 
                 model, 
                 alg_args={}):
        """ Create a CollocationLagrangePolynomials algorithm.
        
        model -- 
            jmodelica.jmi.Model model object
        alg_args -- 
            dict with algorithm arguments. This algorithm expects the dict keys n_e, hs and n_cp to be set.
            
        """
        self.model = model
        #try to set algorithm arguments
        try:
            self._set_alg_args(**alg_args)
        except TypeError, e:
            raise InvalidAlgorithmArgumentException(e)
        
        self.nlp = ipopt.NLPCollocationLagrangePolynomials(model,self.n_e, self.hs, self.n_cp)
        if self.res:
            nlp.set_initial_from_dymola(self.res, self.hs, 0, 0) 
            
        self.nlp_ipopt = ipopt.CollocationOptimizer(self.nlp)
            
        
    def _set_alg_args(self, 
                      n_e=50, 
                      n_cp=3, 
                      hs=N.ones(50)*1./50, 
                      res = None,
                      result_mesh='default', 
                      result_file_name='', 
                      result_format='txt',
                      n_interpolation_points=None):
        self.n_e=n_e
        self.n_cp=n_cp
        self.hs=hs
        self.res=res
        self.result_mesh=result_mesh
        if not n_interpolation_points:
            self.result_args = dict(file_name=result_file_name, format=result_format)
        else:
            self.result_args = dict(file_name=result_file_name, format=result_format, n_interpolation_points=n_interpolation_points)
        
    def set_solver_options(self, 
                           solver_args):
        """ Set options for the solver.
        
        solver_args --
            dict with int, real or string options
        """
        for k, v in solver_args.iteritems():
            if isinstance(v, int):
                self.nlp_ipopt.opt_sim_ipopt_set_int_option(k, v)
            elif isinstance(v, float):
                self.nlp_ipopt.opt_sim_ipopt_set_num_option(k, v)
            elif isinstance(v, str):
                self.nlp_ipopt.opt_sim_ipopt_set_string_option(k, v)
                        
    def solve(self):
        """ Solve the optimization problem using ipopt solver. """
        self.nlp_ipopt.opt_sim_ipopt_solve()
    
    def write_result(self):
        """ Write result to file. Returns name of result file."""
        if self.result_mesh=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(**self.result_args)
        elif self.result_mesh=='mesh_interpolation':
            self.nlp.export_result_dymola_mesh_interpolation(**self.result_args)
        elif self.result_mesh=='default':
            self.nlp.export_result_dymola(**self.result_args)
        else:
            raise InvalidAlgorithmArgumentException(self.result_mesh)
        
        # return name of result file
        resultfile = self.result_args['file_name']
        if not resultfile:
            resultfile=self.model.get_name()+'_result.txt'
        return resultfile
        
class InvalidAlgorithmArgumentException(Exception):
    """ Exception raised when an algorithm argument is encountered that does not exists."""
    
    def __init__(self, arg):
        self.msg='Invalid algorithm argument: '+str(arg)
        
    def __str__():
        return self.msg

class InvalidSolverArgumentException(Exception):
    """ Exception raised when a solver argument is encountered that does not exists."""
    
    def __init__(self, arg):
        self.msg='Invalid solver argument: '+str(arg)
        
    def __str__():
        return self.msg
    
