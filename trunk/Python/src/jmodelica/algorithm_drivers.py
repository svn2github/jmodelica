""" Module for optimization and simulation algorithms to be used together with 
jmodelica.optimize and jmodelica.simulate
"""
#from abc import ABCMeta, abstractmethod
import warnings
import numpy as N

from jmodelica.optimization import ipopt
#from jmodelica.simulation.sundials import SundialsDAESimulator
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

try:
    from jmodelica.simulation.assimulo import JMIDAE, JMIODE, write_data
    from Assimulo.Implicit_ODE import IDA
    from Assimulo.Explicit_ODE import CVode
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
    
    def __init__(self, model, alg_args={}, start_time=0.0, final_time=10.0, abstol=1.0e-6, reltol=1.0e-6,time_step=0.01):
        self.model = model
        self.alg_args=alg_args
        self.start_time = start_time
        self.final_time = final_time
        self.abstol=abstol
        self.reltol=reltol
        self.time_step=time_step
        
    def set_solver_options(self, solver_args):
        self.solver_args=solver_args
        
    def solve(self):
        if self.alg_args.get('solver')=='ODE':
            probl = JMIODE(self.model, **self.solver_args)
            self.simulator = CVode(probl, t0=self.start_time)
        else:
            probl = JMIDAE(self.model, **self.solver_args)
            self.simulator = IDA(probl, t0=self.start_time)
            
        self.simulator.atol = self.abstol
        self.simulator.rtol = self.reltol
        self.simulator(self.final_time, int((self.final_time-self.start_time)/self.time_step))
    
    def write_result(self):
        write_data(self.simulator)

  
class CollocationLagrangePolynomialsAlg(AlgorithmBase):
    """ Optimization algorithm using CollocationLagrangePolynomials method. """
    
    def __init__(self, model, alg_args):
        """ Create a CollocationLagrangePolynomials algorithm.
        
        model -- 
            jmodelica.jmi.Model model object
        alg_args -- 
            dict with algorithm arguments. This algorithm expects the dict keys n_e, hs and n_cp to be set.
            
        """
        self.nlp = ipopt.NLPCollocationLagrangePolynomials(model,**alg_args)
        self.nlp_ipopt = ipopt.CollocationOptimizer(self.nlp)
        
    def set_solver_options(self, solver_args):
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
    
    def write_result(self, result_mesh='default', result_args={}):
        """ Write result to file. """
        if result_mesh=='element_interpolation':
            self.nlp.export_result_dymola_element_interpolation(**result_args)
        elif result_mesh=='mesh_interpolation':
            self.nlp.export_result_dymola_mesh_interpolation(**result_args)
        else:
            self.nlp.export_result_dymola(**result_args)
