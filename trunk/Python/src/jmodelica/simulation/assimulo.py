#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""
This file contains code for mapping our Models to the Problem specifications
required by Assimulo.
"""

import numpy as N
import pylab as P
import jmodelica.io as io
import jmodelica.jmi as jmi
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
    def __init__(self, model, jacobian=True):
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
        self.eps = 1e-9 #Epsilon for adjusting the event indicator.
        self.log_events = False #Are we to log the events?
        
        if jacobian: #Use JModelicas jacobian?
            self.jac = self.j #Activates the jacobian
    
        #Sets internal options
        self._initiate_problem = False #Used for initiation
        self._log_initiate_mode = False #Used for logging
        self._log_information = [] #List that handles log information
        self._f_nbr = f_nbr #Number of equations
        self._g_nbr = g_nbr #Number of event indicatiors
        self._x_nbr = len(self._model.x) #Number of differentiated
        self._w_nbr = len(self._model.w) #Number of algebraic
        self._dx_nbr = len(self._model.dx) #Number of derivatives
        self._pre = self.y0.copy()
        self._iter = 0
        self._temp_f = N.array([0.]*self._f_nbr)
        
        
    def f(self, t, y, yd, sw=None):
        """
        The residual function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y[0:self._x_nbr]
        self._model.w = y[self._x_nbr:self._f_nbr]
        self._model.dx = yd[0:self._dx_nbr]

        #Evaluating the residual function
        residual = N.array([.0]*self._f_nbr)
        self._model.jmimodel.dae_F(residual)
        
        #Log information
        if self._log_initiate_mode:
            i = len(self._log_information)
            j = len(self._log_information[i-1][1])
            
            self._log_information[i-1][5][j-1].append(residual.copy())
            
            sum=N.sum(y!=self._pre)
            if sum == 1:
                self._log_information[i-1][2][j-1].append(1e6)
            else:
                W = 1/(1e-6*N.abs(y)+1e-6)
                RES = N.sqrt(N.sum(W*(N.abs(self._pre-y)**2)))
                #self._log_information[i-1][2][j-1].append(N.max(N.abs(residual)))
                self._log_information[i-1][2][j-1].append(RES)
                self._pre = y.copy()
        
        return residual
        
    def j(self, c, t, y, yd, sw=None):
        """
        The jacobian function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y[0:self._x_nbr]
        self._model.w = y[self._x_nbr:self._f_nbr]
        self._model.dx = yd[0:self._dx_nbr]
        
        #Evaluating the jacobian
        #-Setting options
        z_l = N.array([1]*len(self._model.z)) #Used to give independent_vars full control
        independent_vars = [jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_W] #Derivation with respect to these variables
        sparsity = jmi.JMI_DER_DENSE_ROW_MAJOR
        evaluation_options = jmi.JMI_DER_CPPAD#jmi.JMI_DER_SYMBOLIC
        
        #-Evaluating
        Jac = N.zeros(self._f_nbr**2) #Matrix that hold information about dx and dw
        self._model.jmimodel.dae_dF(evaluation_options, sparsity, independent_vars[1:], z_l, Jac) #Output x+w
        
        dx = N.zeros(len(self._model.dx)*self._f_nbr) #Matrix that hold information about dx'
        self._model.jmimodel.dae_dF(evaluation_options, sparsity, independent_vars[0], z_l, dx) #Output dx'
        dx = dx*c #Scale
        
        #-Vector manipulation
        Jac = Jac.reshape(self._f_nbr,self._f_nbr)
        dx = dx.reshape(self._f_nbr,self._dx_nbr)
        Jac[:,0:self._dx_nbr] += dx
        
        return Jac
        
    def g(self, t, y, yd, sw):
        """
        The event indicator function for a DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.x = y[0:self._x_nbr]
        self._model.w = y[self._x_nbr:self._f_nbr]
        self._model.dx = yd[0:self._dx_nbr]
        
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
        
        if self.log_events:
            self._log_information.append([solver.t[-1], [list(event_info)], [[]], [],[], [[]],[]])
        
        while self.max_eIter > nbr_iteration: #Event Iteration
            
            if self.log_events:
                if nbr_iteration > 0: #Used for logging
                    i = len(self._log_information)
                    self._log_information[i-1][1].append(event_info)
                    self._log_information[i-1][2].append([])
                    self._log_information[i-1][5].append([])
                
            self.event_switch(solver, event_info) #Turns the switches

            b_mode = self.g(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)
            self.init_mode(solver) #Pass in the solver to the problem specified init_mode
            a_mode = self.g(solver.t[-1], solver.y[-1], solver.yd[-1], solver.switches)

            #Log information
            if self.log_events:
                i = len(self._log_information)
                self._log_information[i-1][4].append(self._model.sw.copy()) #Switches
                self._log_information[i-1][6].append([b_mode,a_mode])

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
        if self._initiate_problem:
            #Check wheter or not it involves event functions
            if self._g_nbr > 0:
                self._model.sw = [int(x) for x in solver.switches]
                
            #Initiate using IPOPT
            init_nlp = NLPInitialization(self._model)
            init_nlp_ipopt = InitializationOptimizer(init_nlp)
            init_nlp_ipopt.init_opt_ipopt_solve()
            
            #Used for logging
            if self.log_events:
                i = len(self._log_information)
                self._log_information[i-1][3].append(True)
            
            #Sets the calculated values
            solver.y[-1] = N.append(self._model.x,self._model.w)
            solver.yd[-1] = N.append(self._model.dx,[0]*len(self._model.w)) 
        else:
            self._model.sw = [int(x) for x in solver.switches]
            
            if self.log_events:
                self._log_initiate_mode = True #Logg f evaluations
                i = len(self._log_information) #Where to put the information
            try:
                solver.make_consistency('IDA_YA_YDP_INIT') #Calculate consistency
                if self.log_events:
                    self._log_information[i-1][3].append(True) #Success
            except Sundials_Exception, data:
                print data
                print 'Failed to calculate initial conditions. Trying to continue...'
                if self.log_events:
                    self._log_information[i-1][3].append(False) #Failure
            
            self._log_initiate_mode = False #Stop logging f
                
    def check_eIter(self, before, after):
        """
        Helper function for handle_event to determine if we have event
        iteration.
        
            Input: Values of the event indicator functions (event_fcn)
            before and after we have changed mode of operations.
        """
        
        eIter = [0]*len(before)
        iter = False
        
        for i in range(len(before)):
            if N.abs(before[i]) < self.eps:
                if after[i] >= self.eps:
                    eIter[i] = 1
                    iter = True
                if after[i] <= -self.eps:
                    eIter[i] = -1
                    iter = True
            else:
                if (before[i] < 0.0 and after[i] >= self.eps):
                    eIter[i] = 1
                    iter = True
                if (before[i] > 0.0 and after[i] <= -self.eps):
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
        
        if self._g_nbr > 0:
            
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
        
    def print_log_info(self, switches=False):
        """
        Prints the log information from the events.
        """
        for i in range(len(self._log_information)):
            print '\tTime, t = %e'%self._log_information[i][0]
            for j in range(len(self._log_information[i][1])):
                if switches:
                    print '(%d,%d)'%(i,j),'\t\t Switch info: ', self._log_information[i][4][j], 'Newton/LineSearch Result: ', self._log_information[i][3][j]
                else:
                    print '(%d,%d)'%(i,j),'\t\t Event info: ', self._log_information[i][1][j], 'Newton/LineSearch Result: ', self._log_information[i][3][j]                
        print '\nNumber of events: ',len(self._log_information)
        
    def plot_log_info(self, ind, iter=0, show_only_max=True, eq_ind=None):
        """
        Plots the maximum f of the index and iteration.
        """
        if show_only_max and eq_ind==None:
            P.semilogy(self._log_information[ind][2][iter])
        else:
            for i in range(self._f_nbr) if eq_ind==None else eq_ind:
                data_points = []
                for j in range(len(self._log_information[ind][5][iter])):
                    data_points.append(N.abs(self._log_information[ind][5][iter][j][i]) if N.abs(self._log_information[ind][5][iter][j][i])>1e-10 else 1e-10)
                P.semilogy(data_points)
        P.ylim(ymin=1e-6)
        P.show()

    def print_g_info(self, ind, iter=0):
        """
        Prints the values of the event functions, before and after.
        """
        
        print 'Pre: ', self._log_information[ind][6][iter][0]
        print 'After: ', self._log_information[ind][6][iter][1]
        
