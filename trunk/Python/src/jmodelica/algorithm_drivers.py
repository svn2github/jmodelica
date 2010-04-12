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
        self._set_alg_args(**alg_args)
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
            self.simulator.setattr(self, k, v)
        
    def solve(self):
        self.simulator(self.final_time, self.num_communication_points)
    
    def write_result(self):
        write_data(self.simulator)

  
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
        # set alg_args
        self._set_alg_args(**alg_args)                
        self.nlp = ipopt.NLPCollocationLagrangePolynomials(model,self.n_e, self.hs, self.n_cp)
        self.nlp_ipopt = ipopt.CollocationOptimizer(self.nlp)
        
    def _set_alg_args(self, 
                      n_e=50, 
                      n_cp=3, 
                      hs=N.ones(50)*1./50, 
                      result_mesh='default', 
                      result_file_name='', 
                      result_format='txt'):
        self.n_e=n_e
        self.n_cp=n_cp
        self.hs=hs
        self.result_mesh=result_mesh
        self.result_args = dict(file_name=result_file_name, format=result_format)
        
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
        """ Write result to file. """
        if self.result_mesh=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(**self.result_args)
        elif self.result_mesh=='mesh_interpolation':
            self.nlp.export_result_dymola_mesh_interpolation(**self.result_args)
        else:
            self.nlp.export_result_dymola(**self.result_args)
