#!/usr/bin/env python 
# -*- coding: utf-8 -*-

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

"""
This file contains code for mapping our JMI Models to the Problem 
specifications required by Assimulo.
"""

import logging
import numpy as N
import pylab as P
import jmodelica.io as io
import jmodelica.jmi as jmi
import jmodelica.fmi as fmi
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

try:
    from assimulo.problem import Implicit_Problem
    from assimulo.problem import Explicit_Problem
    from assimulo.sundials import Sundials_Exception
except ImportError:
    logging.warning('Could not find Assimulo package. Check jmodelica.check_packages()')


class JMIModel_Exception(Exception):
    """
    A JMIModel Exception.
    """
    pass
    
class FMIModel_Exception(Exception):
    """
    A FMIModel Exception.
    """
    pass

def write_data(simulator,write_scaled_result=False):
    """
    Writes simulation data to a file.
    
    Takes as input a simulated model.
    """
    if isinstance(simulator._problem, Implicit_Problem):
        
        model = simulator._problem._model
        
        t = N.array(simulator.t)
        y = N.array(simulator.y)
        yd = N.array(simulator.yd)
        if simulator._problem.input:
            u_name = [k[1] for k in model.get_u_variable_names()]
            u = N.zeros((len(t), len(u_name)))
            u_mat = simulator._problem.input[1].eval(t)
            
            if not isinstance(simulator._problem.input[0],list):
                u_input_name = [simulator._problem.input[0]]
            else:
                u_input_name = simulator._problem.input[0]
            
            for i,n in enumerate(u_input_name):
                u[:,u_name.index(n)] = u_mat[:,i]
        else:
            u = N.ones((len(t),len(model.real_u)))*model.real_u
        
        # extends the time array with the states columnwise
        data = N.c_[t,yd[:,0:len(model.real_dx)]]
        data = N.c_[data, y[:,0:len(model.real_x)]]
        data = N.c_[data, u]
        data = N.c_[data, y[:,len(model.real_x):len(model.real_x)+len(model.real_w)]]

        io.export_result_dymola(model,data,scaled=write_scaled_result)
    elif isinstance(simulator._problem, JMIODE):
        model = simulator._problem._model
    
        t = N.array(simulator.t)
        y = N.array(simulator.y)
        if simulator._problem.input:
            u_name = [k[1] for k in model.get_u_variable_names()]
            u = N.zeros((len(t), len(u_name)))
            u_mat = simulator._problem.input[1].eval(t)
            
            if not isinstance(simulator._problem.input[0],list):
                u_input_name = [simulator._problem.input[0]]
            else:
                u_input_name = simulator._problem.input[0]
            
            for i,n in enumerate(u_input_name):
                u[:,u_name.index(n)] = u_mat[:,i]
        else:
            u = N.ones((len(t),len(model.real_u)))*model.real_u
        yd = N.array(map(simulator.f,t,y))

        # extends the time array with the states columnwise
        data = N.c_[t,yd]
        data = N.c_[data, y]
        data = N.c_[data, u]
        
        io.export_result_dymola(model,data,scaled=write_scaled_result)
    else:
        model = simulator._problem._model
        
        t = N.array(simulator._problem._sol_time)
        r = N.array(simulator._problem._sol_real)
        data = N.c_[t,r]
        if len(simulator._problem._sol_int) > 0:
            i = N.array(simulator._problem._sol_int)
            data = N.c_[data,i]
        if len(simulator._problem._sol_bool) > 0:
            b = N.array(simulator._problem._sol_bool).reshape(-1,len(model._save_cont_valueref[2]))
            data = N.c_[data,b]

        export = io.ResultWriterDymola(model)
        export.write_header()
        map(export.write_point,(row for row in data))
        export.write_finalize()
        #fmi.export_result_dymola(model, data)

def createLogger(model, minimum_level):
    """
    Creates a logger.
    """
    filename = model.get_name()+'.log'
    
    log = logging.getLogger(filename)
    log.setLevel(minimum_level)

    #ch = logging.StreamHandler()
    ch = logging.FileHandler(filename, mode='w', delay=True)
    ch.setLevel(0)

    formatter = logging.Formatter("%(name)s - %(message)s")
    
    ch.setFormatter(formatter)

    log.addHandler(ch)

    return log

class FMIODE(Explicit_Problem):
    """
    An Assimulo Explicit Model extended to FMI interface.
    """
    def __init__(self, model, input=None):
        """
        Initialize the problem.
        """
        self._model = model
        self.input = input
        self.input_names = []

        self.y0 = self._model.continuous_states
        self.problem_name = self._model.get_name()

        [f_nbr, g_nbr] = self._model.get_ode_sizes()
        
        self._f_nbr = f_nbr
        self._g_nbr = g_nbr
        
        if g_nbr > 0:
            self.state_events = self.g
        self.time_events = self.t
        
        #Default values
        self.write_cont = True #Continuous writing
        self.export = io.ResultWriterDymola(model)
        
        #Internal values
        self._sol_time = []
        self._sol_real = []
        self._sol_int  = []
        self._sol_bool = []
        self._logg_step_event = []
        self._write_header = True
        
        #Stores the first time point
        #[r,i,b] = self._model.save_time_point()
        
        #self._sol_time += [self._model.t]
        #self._sol_real += [r]
        #self._sol_int  += [i]
        #self._sol_bool += b
        
        
    def f(self, t, y, sw=None):
        """
        The rhs (right-hand-side) for an ODE problem.
        """
        #Moving data to the model
        self._model.time = t
        self._model.continuous_states = y
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the rhs
        rhs = self._model.get_derivatives()

        return rhs
        
    def g(self, t, y, sw):
        """
        The event indicator function for a ODE problem.
        """
        #Moving data to the model
        self._model.time = t
        self._model.continuous_states = y
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the event indicators
        eventInd = self._model.get_event_indicators()

        return eventInd
        
    def t(self, t, y, sw):
        """
        Time event function.
        """
        eInfo = self._model.get_event_info()
        
        if eInfo.upcomingTimeEvent == True:
            return eInfo.nextEventTime
        else:
            return None
    
    def _set_write_cont(self, cont):
        """
        Defines if the values should be written to the file continuously
        during the simulation.
        """
        self.__write_cont = cont
        
    def _get_write_cont(self):
        """
        Defines if the values should be written to the file continuously
        during the simulation.
        """
        return self.__write_cont

    write_cont = property(_get_write_cont, _set_write_cont)
    
    def handle_result(self, solver, t, y):
        """
        Post processing (stores the time points).
        """
        #Moving data to the model
        if t != self._model.time:
            #Moving data to the model
            self._model.time = t
            self._model.continuous_states = y
            
            #Sets the inputs, if any
            if self.input!=None:
                self._model.set_real(self.input_names,self.input.eval(t)[0,:])
            
            #Evaluating the rhs (Have to evaluate the values in the model)
            rhs = self._model.get_derivatives()
        
        if self.write_cont:
            if self._write_header:
                self._write_header = False
                self.export.write_header()
            self.export.write_point()
        else:
            #Retrieves the time-point
            [r,i,b] = self._model.save_time_point()

            #Save the time-point
            self._sol_real += [r]
            self._sol_int  += [i]
            self._sol_bool += b
            self._sol_time += [t]
        
    def handle_event(self, solver, event_info):
        """
        This method is called when Assimulo finds an event.
        """
        if self._model.time != solver.t_cur:
            #Moving data to the model
            self._model.time = solver.t_cur
            self._model.continuous_states = solver.y_cur
            
            #Sets the inputs, if any
            if self.input!=None:
                self._model.set(self.input[0], self.input[1].eval(N.array([solver.t_cur]))[0,:])
            
            #Evaluating the rhs (Have to evaluate the values in the model)
            rhs = self._model.get_derivatives()
        
        eInfo = self._model.get_event_info()
        eInfo.iterationConverged = False

        while eInfo.iterationConverged == False:
            self._model.event_update('0')
            eInfo = self._model.get_event_info()

            #Retrieve solutions (if needed)
            if eInfo.iterationConverged == False:
                pass
        
        #Check if the event affected the state values and if so sets them
        if eInfo.stateValuesChanged:
            solver.y_cur = self._model.continuous_states
        
        #Get new nominal values.
        if eInfo.stateValueReferencesChanged:
            solver.atol = 0.01*solver.rtol*self._model.nominal_continuous_states
        
        
    def completed_step(self, solver):
        """
        Method which is called at each successful step.
        """
        #Moving data to the model
        if solver.t_cur != self._model.time:
            self._model.time = solver.t_cur
            self._model.continuous_states = solver.y_cur
            
            #Sets the inputs, if any
            if self.input!=None:
                self._model.set(self.input[0], self.input[1].eval(N.array([solver.t_cur]))[0,:])
            
            #Evaluating the rhs (Have to evaluate the values in the model)
            rhs = self._model.get_derivatives()
        
        if self._model.completed_integrator_step():
            self._logg_step_event += [solver.t_cur]
            self.handle_event(solver,[0]) #Event have been detect, call event iteration.
            return 1 #Tell to reinitiate the solver.
        else:
            return 0
            
    def print_step_info(self):
        """
        Prints the information about step events.
        """
        print '\nStep-event information:\n'
        for i in range(len(self._logg_step_event)):
            print 'Event at time: %e'%self._logg_step_event[i]
        print '\nNumber of events: ',len(self._logg_step_event)
    
    def finalize(self, solver):
        if self.write_cont:
            self.export.write_finalize()
        
    
    def _set_input(self, input):
        """
        Defines the input. The input must be a 2-tuple with the first 
        object as a list of names of the input variables and with the
        other as a subclass of the class Trajectory.
        """
        self.__input = input
        
    def _get_input(self):
        """
        Defines the input. The input must be a 2-tuple with the first 
        object as a list of names of the input variables and with the
        other as a subclass of the class Trajectory.
        """
        return self.__input

    input = property(_get_input, _set_input)
        

class JMIODE(Explicit_Problem):
    """
    An Assimulo Explicit Model extended to JMI interface.
    
        Not extended with handling for discontinuities.
    
        To use an explicit solver the problem have to be defined
        in specific way, namely: der(x) = f(t,x) in the modelica
        model. See http://www.jmodelica.org/page/10
    """
    
    def __init__(self, model, input=None):
        """
        Sets the initial values.
        """
        self._model = model
        self.input = input
        
        self.y0 = self._model.real_x
        
        if len(self._model.real_w):
            raise JMIModel_Exception('There can be no algebraic variables when using an ODE solver.')
            
        [f_nbr, g_nbr] = self._model.jmimodel.dae_get_sizes() #Used for determine if there are discontinuities
        
        if g_nbr > 0:
            raise JMIModel_Exception('There is no support for discontinuities when using an ODE solver.')
        
        if self._model.has_cppad_derivatives():
            self.jac = self.j #Activates the jacobian
    
    def f(self, t, y, sw=None):
        """
        The rhs (right-hand-side) for an ODE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the rhs
        self._model.eval_ode_f()
        rhs = self._model.real_dx

        return rhs
        
    def j(self, t, y, sw=None):
        """
        The jacobian function for an ODE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the jacobian
        #-Setting options
        z_l = N.array([1]*len(self._model.z),dtype=N.int32) #Used to give independent_vars full control
        independent_vars = [jmi.JMI_DER_X] #Derivation with respect to X
        sparsity = jmi.JMI_DER_DENSE_ROW_MAJOR
        evaluation_options = jmi.JMI_DER_CPPAD #Determine to use CPPAD
        
        #-Evaluating
        Jac = N.zeros(len(y)**2) #Matrix that holds the information
        self._model.jmimodel.ode_df(evaluation_options, sparsity, independent_vars, z_l, Jac) #Output Jac
        
        #-Vector manipulation
        Jac = Jac.reshape(len(y),len(y)) #Reshape to a matrix
        
        return Jac
    
    def g(self, t, y, sw):
        """
        The event indicator function for a ODE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y
        
        #Evaluating the switching functions
        #TODO
        raise JMIModel_Exception('Not implemented.')
   
    def _set_input(self, input):
        self.__input = input
        
    def _get_input(self):
        """
        Defines the input. The input must be a 2-tuple with the first 
        object as a list of names of the input variables and with the
        other as a subclass of the class Trajectory.
        """
        return self.__input
        
    input = property(_get_input, _set_input)
    
    def reset(self):
        """
        Resets the model to it's default values.
        """
        self._model.reset()
        self._model.t = self.t0 #Set time to the default value
        
        self.y0 = self._model.real_x
 
    
class JMIDAE(Implicit_Problem):
    """
    An Assimulo Implicit Model extended to JMI interface.
    """
    def __init__(self, model, input=None):
        """
        Sets the initial values.
        """
        self._model = model
        self.input = input
        
        self.y0 = N.append(self._model.real_x,self._model.real_w)
        self.yd0 = N.append(self._model.real_dx,[0]*len(self._model.real_w))
        self.algvar = [1.0]*len(self._model.real_x) + [0.0]*len(self._model.real_w) #Sets the algebraic components of the model
                
        
        [f_nbr, g_nbr] = self._model.jmimodel.dae_get_sizes() #Used for determine if there are discontinuities
        
        if g_nbr > 0:
            self.switches0 = [bool(x) for x in self._model.sw] #Change the models values of the switches from ints to booleans
            self.state_events = self.g_adjust #Activates the event function
            
        #Sets default values
        self.max_eIter = 50 #Maximum number of event iterations allowed.
        self.eps = 1e-9 #Epsilon for adjusting the event indicator.
        self.log_events = False #Are we to log the events?
        
        if self._model.has_cppad_derivatives():
            self.jac = self.j #Activates the jacobian
        
        #Sets internal options
        self._initiate_problem = False #Used for initiation
        self._log_initiate_mode = False #Used for logging
        self._log_information = [] #List that handles log information
        self._f_nbr = f_nbr #Number of equations
        self._g_nbr = g_nbr #Number of event indicatiors
        self._x_nbr = len(self._model.real_x) #Number of differentiated
        self._w_nbr = len(self._model.real_w) #Number of algebraic
        self._dx_nbr = len(self._model.real_dx) #Number of derivatives
        self._pre = self.y0.copy()
        self._iter = 0
        self._temp_f = N.array([0.]*self._f_nbr)
        self._logLevel = logging.CRITICAL
        self._log = createLogger(model, self._logLevel)
        
    def _set_logging_level(self, level):
        """
        Sets the logging level.
        """
        if bool(level):
            self._log.setLevel(0) #Log all entries
        else:
            self._log.setLevel(50) #Log nothing (log nothing below level 50)
    
    def _get_logging_level(self):
        """
        Activate and deactivate the logging.
        
            Parameter::
            
                level   --
                    Determines if the logging should be activated (True)
                    or deactivated (False).
                    Default False
        """
        return self._logLevel
        
    log = property(fget=_get_logging_level, fset=_set_logging_level)
        
    def f(self, t, y, yd, sw=None):
        """
        The residual function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y[0:self._x_nbr]
        self._model.real_w = y[self._x_nbr:self._f_nbr]
        self._model.real_dx = yd[0:self._dx_nbr]
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])

        #Evaluating the residual function
        residual = N.array([.0]*self._f_nbr)
        self._model.jmimodel.dae_F(residual)
        
        return residual
        
    def j(self, c, t, y, yd, sw=None):
        """
        The jacobian function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y[0:self._x_nbr]
        self._model.real_w = y[self._x_nbr:self._f_nbr]
        self._model.real_dx = yd[0:self._dx_nbr]
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the jacobian
        #-Setting options
        z_l = N.array([1]*len(self._model.z),dtype=N.int32) #Used to give independent_vars full control
        independent_vars = [jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_W] #Derivation with respect to these variables
        sparsity = jmi.JMI_DER_DENSE_ROW_MAJOR
        evaluation_options = jmi.JMI_DER_CPPAD#jmi.JMI_DER_SYMBOLIC
        
        #-Evaluating
        Jac = N.zeros(self._f_nbr**2) #Matrix that hold information about dx and dw
        self._model.jmimodel.dae_dF(evaluation_options, sparsity, independent_vars[1:], z_l, Jac) #Output x+w
        
        dx = N.zeros(len(self._model.real_dx)*self._f_nbr) #Matrix that hold information about dx'
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
        self._model.real_x = y[0:self._x_nbr]
        self._model.real_w = y[self._x_nbr:self._f_nbr]
        self._model.real_dx = yd[0:self._dx_nbr]
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
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
        event_info = event_info[0] #Only look at the state event information
        
        self._log.debug('State event occurred at time: %f'%solver.t_cur)
        nbr_iteration = 0

        while self.max_eIter > nbr_iteration: #Event Iteration
            
            self._log.debug(' Current switches: ' +str(solver.switches))
            self._log.debug(' Event information: '+str(event_info))
            self._log.debug(' Current States: '+str(solver.y_cur))
            self._log.debug(' Current State Derivatives: '+str(solver.yd_cur))
            
            self.event_switch(solver, event_info) #Turns the switches

            b_mode = self.g(solver.t_cur, solver.y_cur, solver.yd_cur, solver.switches)
            self.init_mode(solver) #Pass in the solver to the problem specified init_mode
            a_mode = self.g(solver.t_cur, solver.y_cur, solver.yd_cur, solver.switches)

            self._log.debug(' Root equations (pre)  : '+str(b_mode))
            self._log.debug(' Root equations (after): '+str(a_mode))

            [event_info, iter] = self.check_eIter(b_mode, a_mode)
                
            if not iter: #Breaks the iteration loop
                break
            
            nbr_iteration += 1
        
    def event_switch(self, solver, event_info):
        """
        This is where we turn the switches. If we have an event, this is
        where it will be taken care of. ::
        
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
            
            #Sets the calculated values
            solver.y_cur = N.append(self._model.real_x,self._model.real_w)
            solver.yd_cur = N.append(self._model.real_dx,[0]*len(self._model.real_w)) 
        else:
            self._model.sw = [int(x) for x in solver.switches]
            
            if self.log_events:
                self._log_initiate_mode = True #Logg f evaluations
                i = len(self._log_information) #Where to put the information
            try:
                solver.make_consistent('IDA_YA_YDP_INIT') #Calculate consistency
                self._log.debug(' Calculation of consistent initial conditions: True')
            except Sundials_Exception, data:
                print data
                print 'Failed to calculate initial conditions. Trying to continue...'
                self._log.debug(' Calculation of consistent initial conditions: True')
            
            self._log_initiate_mode = False #Stop logging f
                
    def check_eIter(self, before, after):
        """
        Helper function for handle_event to determine if we have event
        iteration.
        
        Parameters::
        
            Values of the event indicator functions (state_events)
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
        
        self.y0 = N.append(self._model.real_x,self._model.real_w)
        self.yd0 = N.append(self._model.real_dx,[0]*len(self._model.real_w))

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
    
    def _set_input(self, input):
        self.__input = input
        
    def _get_input(self):
        """
        Defines the input. The input must be a 2-tuple with the first 
        object as a list of names of the input variables and with the
        other as a subclass of the class Trajectory.
        """
        return self.__input

    input = property(_get_input, _set_input)
    
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
        
            self.handle_event(solver, [[0],False])
        else:
            self.init_mode(solver)
        
        self._initiate_problem = False 
        
    #def print_log_info(self, switches=False):
    #    """
    #    Prints the log information from the events.
    #    """
    #    for i in range(len(self._log_information)):
    #        print '\tTime, t = %e'%self._log_information[i][0]
    #        for j in range(len(self._log_information[i][1])):
    #            if switches:
    #                print '(%d,%d)'%(i,j),'\t\t Switch info: ', self._log_information[i][4][j], 'Newton/LineSearch Result: ', self._log_information[i][3][j]
    #            else:
    #                print '(%d,%d)'%(i,j),'\t\t Event info: ', self._log_information[i][1][j], 'Newton/LineSearch Result: ', self._log_information[i][3][j]                
    #    print '\nNumber of events: ',len(self._log_information)
        
    #def plot_log_info(self, ind, iter=0, show_only_max=True, eq_ind=None):
    #    """
    #    Plots the maximum f of the index and iteration.
    #    """
    #    if show_only_max and eq_ind==None:
    #        P.semilogy(self._log_information[ind][2][iter])
    #    else:
    #        for i in range(self._f_nbr) if eq_ind==None else eq_ind:
    #            data_points = []
    #            for j in range(len(self._log_information[ind][5][iter])):
    #                data_points.append(N.abs(self._log_information[ind][5][iter][j][i]) if N.abs(self._log_information[ind][5][iter][j][i])>1e-10 else 1e-10)
    #            P.semilogy(data_points)
    #    P.ylim(ymin=1e-6)
    #    P.show()

    #def print_g_info(self, ind, iter=0):
    #    """
    #    Prints the values of the event functions, before and after.
    #    """
    #    
    #    print 'Pre: ', self._log_information[ind][6][iter][0]
    #    print 'After: ', self._log_information[ind][6][iter][1]
        

class JMIDAESens(Implicit_Problem):
    """
    An Assimulo Implicit Model extended to JMI interface with support 
    for sensitivities.
    """
    def __init__(self, model):
        """
        Sets the initial values.
        """
        self._model = model
        
        self.y0 = N.append(self._model.real_x,self._model.real_w)
        self.yd0 = N.append(self._model.real_dx,[0]*len(self._model.real_w))
        self.algvar = [1.0]*len(self._model.real_x) + [0.0]*len(self._model.real_w) #Sets the algebraic components of the model
        
        [f_nbr, g_nbr] = self._model.jmimodel.dae_get_sizes() #Used for determine if there are discontinuities
        
        #Internal values
        self._parameter_names = [name[1] for name in self._model.get_p_opt_variable_names()]
        self._sens_matrix = [] #Sensitivity matrix
        self._f_nbr = f_nbr #Number of equations
        self._g_nbr = g_nbr #Number of event indicatiors
        self._x_nbr = len(self._model.real_x) #Number of differentiated
        self._w_nbr = len(self._model.real_w) #Number of algebraic
        self._dx_nbr = len(self._model.real_dx) #Number of derivatives
        
        #Set the start values to the parameters.
        self.p0 = N.array([])
        for n in self._parameter_names:
            self.p0 = N.append(self.p0, self._model.get(n))
            self._sens_matrix += [[]] 
        
        self._p_nbr = len(self.p0) #Number of parameters
        
    def f(self, t, y, yd, p):
        """
        The residual function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y[0:self._x_nbr]
        self._model.real_w = y[self._x_nbr:self._f_nbr]
        self._model.real_dx = yd[0:self._dx_nbr]
        
        #Set the free parameters
        for ind, val in enumerate(p):
            self._model.set(self._parameter_names[ind],val)
        
        #Evaluating the residual function
        residual = N.array([.0]*self._f_nbr)
        self._model.jmimodel.dae_F(residual)
        
        return residual
        
    def handle_result(self, solver, t ,y, yd):
        """
        Post processing (stores the time points and the sensitivity result).
        """
        solver.t += [t]
        solver.y += [y]
        
        #Store the sensitivity matrix
        for i in range(self._p_nbr):
            self._sens_matrix[i] += [solver.interpolate_sensitivity(t, 0, i)]
        
    def get_sens_result(self):
        """
        Returns the sensitivity results together with the names.
        
            Returns::
            
                parameter_names, sensitivity_matrix = JMIDAESens.get_sens_result()
                
                    parameters_names   - The names of the parameters for which sensitivities
                                         have been calculated.
                                       
                    sensitivity_matrix - A matrix containing the sensitivities for all the
                                         parameters.
                                         
                                         sensitivity_matrix[0], gives the result for the first
                                                                parameter in the parameters_names
                                                                list.
        """
        for i in range(self._p_nbr):
            self._sens_matrix[i] = N.array(self._sens_matrix[i]).reshape(-1,self._f_nbr)
            
        return self._parameter_names, self._sens_matrix

class Trajectory:
    """
    Base class for representation of trajectories.
    """
    
    def __init__(self, abscissa, ordinate):
        """
        Default constructor for creating a tracjectory object.

        Parameters::
        
            abscissa -- One dimensional numpy array containing
                        the n abscissa (independent) values
            ordinate -- Two dimensional n x m numpy matrix containing
                        the ordiate values. The matrix has the same
                        number of rows as the abscissa has elements.
                        The number of columns is equal to the number of
                        output variables.
        """
        self._abscissa = abscissa
        self._ordinate = ordinate
        self._n = N.size(abscissa)
        self._x0 = abscissa[0]
        self._xf = abscissa[-1]

        if not N.all(N.diff(self.abscissa)>=0):
            raise Exception("The abscissa must be increasing.")

        small = 1e-8
        double_point_indices = N.nonzero(N.abs(N.diff(self.abscissa))<=small)
        for i in double_point_indices:
            self.abscissa[i+1] = self.abscissa[i+1] + small

    def eval(self,x):
        """
        Evaluate the trajectory at a specifed abscissa.

        Parameters::
        
            x -- One dimensional numpy array, or scalar number,
                 containing n abscissa value(s).

        Returns::
        
            Two dimensional n x m matrix containing the
            ordinate values corresponding to the argument x.
        """
        pass

    def _set_abscissa(self, absscissa):
        """ Set the abscissa of the trajectory."""
        self._abscissa[:] = abscissa

    def _get_abscissa(self):
        """ Get the abscissa of the trajectory."""
        return self._abscissa

    abscissa = property(_get_abscissa, _set_abscissa, doc="Abscissa")

    def _set_ordinate(self, absscissa):
        """ Set the ordinate of the trajectory."""
        self._ordinate[:] = ordinate

    def _get_ordinate(self):
        """ Get the ordinate of the trajectory."""
        return self._ordinate

    ordinate = property(_get_ordinate, _set_ordinate, doc="Ordinate")



class TrajectoryLinearInterpolation(Trajectory):

    def eval(self,x):
        """
        Evaluate the trajectory at a specifed abscissa.

        Parameters::
        
            x -- One dimensional numpy array, or scalar number,
                 containing n abscissa value(s).

        Returns::
        
            Two dimensional n x m matrix containing the
            ordinate values corresponding to the argument x.
        """        
        y = N.zeros([N.size(x),N.size(self.ordinate,1)])
        for i in range(N.size(y,1)):
            y[:,i] = N.interp(x,self.abscissa,self.ordinate[:,i])
        return y
