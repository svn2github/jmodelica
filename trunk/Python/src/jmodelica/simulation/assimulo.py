#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""
This file contains code for wrapping our new Integrator package 
to Jmodelica.
"""

import numpy as N
import jmodelica.io as io

try:
    from Integrator.Explicit_ODE import CVode
    from Integrator.Implicit_ODE import IDA
except ImportError:
    print 'Could not load Integrator package.'

class Simulator_Exception(Exception):
    """
    An exception class for Simulator.
    """
    pass

class Simulator(object):
    """
    An object oriented interface for simulating JModelica.org models.
    """
    
    sup_solvers = ['IDA','CVode'] #Supported solvers.
    
    def __init__(self, model, solver, t0=0.0):
        """
        Initiates the solver.
        """
        self._model = model
        self._model.t = self._t0 = t0
        
        if solver in self.sup_solvers:
            
            if solver == self.sup_solvers[0]: #IDA
                
                y0 = N.append(self._model.x,self._model.w)
                yd0 = N.append(self._model.dx,[0]*len(self._model.w))
                
                self.solver = IDA(self.f_DAE, y0, yd0, self._model.t) #Creates a IDA solver
                self.solver.algvar = [1.0]*len(self._model.x) + [0.0]*len(self._model.w) #Sets the algebraic components of the model
                self.DAE = True #It's an DAE solver
        
            if solver == self.sup_solvers[1]: #CVode
                
                y0 = self._model.x
                
                self.solver = CVode(self.f_ODE, y0, self._model.t) #Creates a CVode solver
                self.DAE = False #It's an ODE solver
        else:
            raise Simulator_Exception('The solver is not supported. '\
            'The supported solvers are the following: %s' %self.sup_solvers)
    
    def reset(self):
        """
        Resets the model to it's default values.
        """
        self._model.reset()
        self._model.t = self._t0 #Set time to the default value
        
        if self.DAE:
            y0 = N.append(self._model.x,self._model.w)
            yd0 = N.append(self._model.dx,[0]*len(self._model.w))
                
            self.solver.re_init(self._model.t, y0, yd0) #re_init a DAE
        else:
            self.solver.re_init(self._model.t, self._model.x) #re_init a ODE
        
    
    def re_init(self, t0, y0, yd0=None, u0=None):
        """
        Re initializes the solver.
        """
        self._model.t = t0
        
        if u0 != None:
            if isinstance(u0, int) or isinstance(u0, float):
                u0 = list([u0])
            if len(u0) == len(self._model.u):
                self._model.u = u0
            else:
                raise Simulator_Exception('u0 must be of the same lenght as the models input'\
                                            ' vector.')
        
        if self.DAE:
            if len(y0) != len(self._model.x)+len(self._model.w):
                raise Simulator_Exception('y0 must be of the same length as the differential'\
                                            ' plus the algebraic variables.')
            if yd0==None:
                raise Simulator_Exception('yd0 must not be None for a DAE.')
            if len(yd0) != len(self._model.dx):
                raise Simulator_Exception('y0d must be of the same length as the derivative'\
                                            ' variables.')
            self._model.x = y0[0:len(self._model.x)]
            self._model.w = y0[len(self._model.x):len(self._model.x)+len(self._model.w)]
            self._model.dx = yd0
            yd0 = N.append(self._model.dx,[0.]*len(self._model.w))
            
            self.solver.re_init(self._model.t, y0, yd0) #re_init a DAE
        else:
            if len(y0) != len(self._model.x):
                raise Simulator_Exception('y0 must be of the same length as the differential'\
                                            ' variables.')
            self._model.x = y0
            self.solver.re_init(self._model.t, self._model.x) #re_init a ODE
    
    def run(self, tfinal, ncp=0):
        """
        This is the method that runs the simulation.
        
            tfinal = Time to integrate to.
            ncp = Number of communication points.
        """
        return self.solver(tfinal,ncp) #Runs the simulation
        
    def plot(self):
        """
        This method plots the solution.
        """
        self.solver.plot()
        
    def write_data(self):
        """
        Writes simulation data to file.
        """
        if self.DAE:
            t = N.array(self.solver.t)
            y = N.array(self.solver.y)
            yd = N.array(self.solver.yd)
            u = N.ones((len(t),len(self._model.u)))*self._model.u
            
            # extends the time array with the states columnwise
            data = N.c_[t,yd[:,0:len(self._model.dx)]]
            data = N.c_[data, y[:,0:len(self._model.x)]]
            data = N.c_[data, u]
            data = N.c_[data, y[:,len(self._model.x):len(self._model.x)+len(self._model.w)]]
            
            io.export_result_dymola(self._model,data)
        else:
            raise Simulator_Exception('Currently not supported for ODEs.')
        

    def f_DAE(self, t, y, yd, sw=None):
        """
        The residual function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y[0:len(self._model.x)]
        self._model.w = y[len(self._model.x):len(y)]
        self._model.dx = yd[0:len(self._model.dx)]

        #Evaluating the residual function
        residual = N.array([.0]*len(y))
        self._model.jmimodel.dae_F(residual)
        
        return residual
    
    def f_ODE(self, t, y, sw=None):
        """
        The rhs (right-hand-side) for an ODE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y
        
        #Evaluating the rhs
        self._model.eval_ode_f()
        rhs = self._model.dx

        return rhs


class IDA_wrapper(object):
    pass
    
    
class CVode_wrapper(object):
    pass
