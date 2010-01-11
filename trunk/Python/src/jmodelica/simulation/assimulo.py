#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""
This file contains code for mapping our Models to the Problem specifications
required by Assimulo.
"""

import numpy as N
import jmodelica.io as io

try:
    from Assimulo.Problem import Implicit_Problem
    from Assimulo.Problem import Explicit_Problem
except ImportError:
    print 'Could not load Assimulo package.'


class JMIModel_Exception(Exception):
    """
    A JMIModel Exception.
    """
    pass

def write_data(simulator):
    """
    Writes simulation data to a file.
    
    Takes as input a simulated model.
    """
    if isinstance(simulator._problem, Implicit_Problem):
        
        model = simulator._problem._model
        
        t = N.array(simulator.t)
        y = N.array(simulator.y)
        yd = N.array(simulator.yd)
        u = N.ones((len(t),len(model.u)))*model.u
        
        # extends the time array with the states columnwise
        data = N.c_[t,yd[:,0:len(model.dx)]]
        data = N.c_[data, y[:,0:len(model.x)]]
        data = N.c_[data, u]
        data = N.c_[data, y[:,len(model.x):len(model.x)+len(model.w)]]
        
        io.export_result_dymola(model,data)
    else:
        raise Simulator_Exception('Currently not supported for ODEs.')

class JMIExplicit(Explicit_Problem):
    """
    An Assimulo Explicit Model extended to JMI interface.
    
    Not extended with handling for discontinuities.
    """
    def __init__(self, model):
        """
        Sets the initial values.
        """
        self._model = model
        
        self.y0 = self._model.x
    
    def f(self, t, y, sw=None):
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
        
    def g(self, t, y, sw):
        """
        The event indicator function for a ODE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y
        
        #Evaluating the switching functions
        #TODO
        raise JMIModel_Exception('Not implemented.')
   
    
    def reset(self):
        """
        Resets the model to it's default values.
        """
        self._model.reset()
        self._model.t = self.t0 #Set time to the default value
        
        self.y0 = self._model.x
 
    
class JMIImplicit(Implicit_Problem):
    """
    An Assimulo Implicit Model extended to JMI interface.
    """
    def __init__(self, model):
        """
        Sets the initial values.
        """
        self._model = model
        
        self.y0 = N.append(self._model.x,self._model.w)
        self.yd0 = N.append(self._model.dx,[0]*len(self._model.w))
        self.algvar = [1.0]*len(self._model.x) + [0.0]*len(self._model.w) #Sets the algebraic components of the model
                
        
        [f_nbr, g_nbr] = self._model.jmimodel.dae_get_sizes() #Used for determine if there are discontinuities
        
        if g_nbr > 0:
            self.switches0 = [bool(x) for x in self._model.sw] #Change the models values of the switches from ints to booleans
            self.event_fcn = self.g #Activates the event function
    
    def f(self, t, y, yd, sw=None):
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
        
    def g(self, t, y, yd, sw):
        """
        The event indicator function for a DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y[0:len(self._model.x)]
        self._model.w = y[len(self._model.x):len(y)]
        self._model.dx = yd[0:len(self._model.dx)]
        #self._model.sw = [int(x) for x in sw] #Sets the switches
        
        #Evaluating the switching functions
        eventInd = N.array([.0]*len(sw))
        self._model.jmimodel.dae_R(eventInd)
        
        return eventInd
        
    def init_mode(self, simulator):
        """
        Overrides Assimulos default initiate mode setting.
        """
        self._model.sw = [int(x) for x in simulator.switches]

    def reset(self):
        """
        Resets the model to it's default values.
        """
        self._model.reset()
        self._model.t = self.t0 #Set time to the default value
        
        self.y0 = N.append(self._model.x,self._model.w)
        self.yd0 = N.append(self._model.dx,[0]*len(self._model.w))
