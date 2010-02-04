#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""
This file contains code for mapping our Models to the Problem specifications
required by Assimulo.
"""

import numpy as N
import jmodelica.io as io
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

try:
    from Assimulo.Problem import Implicit_Problem
    from Assimulo.Problem import Explicit_Problem
    from Assimulo.Sundials import Sundials_Exception
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
            self.event_fcn = self.g_adjust #Activates the event function
            
        #Sets default values
        self.max_eIter = 50 #Maximum number of event iterations allowed.
        self.eps = 1e-9 #Epsilon for adjusting the event indicators
        self._initiate_problem = False
    
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
        
        #Evaluating the switching functions
        eventInd = N.array([.0]*len(sw))
        self._model.jmimodel.dae_R(eventInd)
        
        return eventInd
    
    def g_adjust(self, t, y, yd, sw):
        """
        This function adjusts the event functions according to Martin Otter et al defined
        in 'Modeling of Mixed Continuous/Discrete Systems in Modelica'.
        """
        r = N.array(self.g(t,y,yd,sw))
        rp = N.zeros(len(r))
        eps_adjust = N.zeros(len(r))
        
        for i in range(len(sw)):
            if sw[i]:
                eps_adjust[i]=+self.eps
            else:
                eps_adjust[i]=-self.eps
        
        rp = r + eps_adjust

        return rp
    
    def handle_event(self, solver, event_info):
        """
        This method is called when assimulo finds an event.
        """
        nbr_iteration = 0
            
        while self.max_eIter > nbr_iteration: #Event Iteration
            self.event_switch(solver, event_info) #Turns the switches
            #print self.g(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)
            #print self.g_adjust(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)
            b_mode = self.g(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)
            #b_mode -= self.eps_adjust #Adjust for the appended epsilon
            self.init_mode(solver) #Pass in the solver to the problem specified init_mode
            
            a_mode = self.g(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)
            #a_mode -= self.eps_adjust #Adjust for the appended epsilon
            #print self.g(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)
            
            [event_info, iter] = self.check_eIter(b_mode, a_mode)
            
            if iter:
                if solver.verbosity >= solver.NORMAL:
                    print '\nEvent iteration?: Yes'
                if solver.verbosity >= solver.LOUD:
                    print 'Iteration info: ', event_info
                
            if not iter: #Breaks the iteration loop
                break
            
            nbr_iteration += 1
        
    def event_switch(self, solver, event_info):
        """
        This is where we turn the switches. If we have an event, this is
        where it will be taken care of.
        
            event_info is a vector consisting of -1, 0, +1, and is as long
            as the number of event functions. A -1 symbolises that an event
            has occured at the specified switch and is decreasing. A 0
            symbolises that nothing has happend. A +1 symbolises that an
            event has occured at the specified switch and is increasing.
            
        This is the default event handling.
        """
        for i in range(len(event_info)): #Loop across all event functions
            #if event_info[i] != 0:
            #    solver.switches[i] = not solver.switches[i] #Turn the switch
            if event_info[i] == -1:
                solver.switches[i] = False
            if event_info[i] == 1:
                solver.switches[i] = True
        
        if solver.verbosity >= solver.LOUD:
            print 'New switches: ', solver.switches
        
    def init_mode(self, solver):
        """
        Initiates the new mode.
        """
        self._model.sw = [int(x) for x in solver.switches]
        
        if self._initiate_problem:
            # Create DAE initialization object.
            init_nlp = NLPInitialization(self._model)
            # Create an Ipopt solver object for the DAE initialization system
            init_nlp_ipopt = InitializationOptimizer(init_nlp)
            # Solve the DAE initialization system with Ipopt
            init_nlp_ipopt.init_opt_ipopt_solve()
            
            solver.y[-1] = N.append(self._model.x,self._model.w)
            solver.yd[-1] = N.append(self._model.dx,[0]*len(self._model.w)) 
        else:
            try:
                solver.make_consistency('IDA_YA_YDP_INIT')
            except Sundials_Exception, data:
                print data
                print 'Failed to calculate initial conditions. Trying to continue...'
                
        #print max(self.f(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches))
        
    def check_eIter(self, before, after):
        """
        Helper function for handle_event to determine if we have event
        iteration.
        
            Input: Values of the event indicator functions (event_fcn)
            before and after we have changed mode of operations.
        """
        
        #eIter = [False]*len(before)
        eIter = [0]*len(before)
        iter = False
        
        for i in range(len(before)):
            #if (before[i] < 0.0 and after[i] >= 0.0) or (before[i] >= 0.0 and after[i] < 0.0):
            #    eIter[i] = True
            if (before[i] < 0.0 and after[i] >= 0.0):
                eIter[i] = 1
                iter = True
            if (before[i] >= 0.0 and after[i] < 0.0):
                eIter[i] = -1
                iter = True
                
        return [eIter, iter]

    def reset(self):
        """
        Resets the model to it's default values.
        """
        self._model.reset()
        self._model.t = self.t0 #Set time to the default value
        
        self.y0 = N.append(self._model.x,self._model.w)
        self.yd0 = N.append(self._model.dx,[0]*len(self._model.w))

    def _set_max_eIteration(self, max_eIter):
        """
        Sets the maximum number of iterations allowed in the event iteration.
        """
        if not isinstance(max_eIter, int) or max_eIter < 0:
            raise JMIModel_Exception('max_eIter must be a positive integer.')
        self.__max_eIter = max_eIter
        
    def _get_max_eIteration(self):
        """
        Returns max_eIter.
        """
        return self.__max_eIter
        
    max_eIterdocstring='Maximum number of event iterations allowed.'
    max_eIter = property(_get_max_eIteration, _set_max_eIteration, doc=max_eIterdocstring)

    def _set_eps(self, eps):
        """
        Sets the epsilon used in the event indicators.
        """
        if not isinstance(eps, float) or eps < 0.0:
            raise JMIModel_Exception('Epsilon must be a positive float.')
        self.__eps = eps
        
    def _get_eps(self):
        """
        Returns the epsilon used in the event indicators.
        """
        return self.__eps
    epsdocstring='Value used for adjusting the event indicators'
    eps = property(_get_eps,_set_eps, doc=epsdocstring)

    def initiate(self,solver):
        """
        Initiates the problem.
        """
        self._initiate_problem = True
        
        if hasattr(self, 'switches0'):
            
            sw_val = N.array([.0]*len(self._model.sw))
            self._model.jmimodel.dae_R(sw_val)
            
            for i in range(len(sw_val)):
                if sw_val[i] >= 0.0:
                    solver.switches[i] = True
                else:
                    solver.switches[i] = False
        
            self.handle_event(solver, [0])
        else:
            self.init_mode(solver)
        
        self._initiate_problem = False 
