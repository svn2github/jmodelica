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
This file contains code for mapping our JMU Models to the Problem specifications 
required by Assimulo.
"""
import logging

import numpy as N
import numpy.linalg as LIN
import pylab as P

from pyjmi.jmi_io import export_result_dymola
from pyjmi.jmi_io import ResultWriterDymolaSensitivity
import pyjmi.jmi as jmi
from pyjmi.initialization.ipopt import NLPInitialization
from pyjmi.initialization.ipopt import InitializationOptimizer
from pyjmi.common.core import TrajectoryLinearInterpolation

try:
    import assimulo
    assimulo_present = True
except:
    logging.warning(
        'Could not load Assimulo module. Check pyfmi.check_packages()')
    assimulo_present = False

if assimulo_present:
    from assimulo.problem import Implicit_Problem
    from assimulo.problem import Explicit_Problem
    from assimulo.exception import *

class JMIModel_Exception(Exception):
    """
    A JMIModel Exception.
    """
    pass

def write_data(simulator,write_scaled_result=False, result_file_name=''):
    """
    Writes simulation data to a file. Takes as input a simulated model.
    """
    #Determine the result file name
    if result_file_name == '':
        result_file_name=simulator.problem._model.get_name()+'_result.txt'
    
    if isinstance(simulator.problem, JMIDAE):
        
        model = simulator.problem._model
        problem = simulator.problem
        
        t = N.array(simulator.t_sol)
        y = N.array(simulator.y_sol)
        yd = N.array(simulator.yd_sol)
        if simulator.problem.input:
            u_name = [k[1] for k in sorted(model.get_u_variable_names())]
            #u = N.zeros((len(t), len(u_name)))
            u = N.ones((len(t), len(u_name)))*model.real_u
            u_mat = simulator.problem.input[1].eval(t)

            if not isinstance(simulator.problem.input[0],list):
                u_input_name = [simulator.problem.input[0]]
            else:
                u_input_name = simulator.problem.input[0]

            for i,n in enumerate(u_input_name):
                u[:,u_name.index(n)] = u_mat[:,i]/problem._input_nominal[i]
        else:
            u = N.ones((len(t),len(model.real_u)))*model.real_u
        
        # extends the time array with the states columnwise
        data = N.c_[t,yd[:,0:len(model.real_dx)]]
        data = N.c_[data, y[:,0:len(model.real_x)]]
        data = N.c_[data, u]
        data = N.c_[data, y[
            :,len(model.real_x):len(model.real_x)+len(model.real_w)]]

        export_result_dymola(model,data,scaled=write_scaled_result, \
                                file_name=result_file_name)
    elif isinstance(simulator.problem, JMIDAESens):
        
        model = simulator.problem._model
        problem = simulator.problem
        
        t = N.array(simulator.t_sol)
        y = N.array(simulator.y_sol)
        yd = N.array(simulator.yd_sol)
        if simulator.problem.input:
            u_name = [k[1] for k in sorted(model.get_u_variable_names())]
            #u = N.zeros((len(t), len(u_name)))
            u = N.ones((len(t), len(u_name)))*model.real_u
            u_mat = simulator.problem.input[1].eval(t)
            
            if not isinstance(simulator.problem.input[0],list):
                u_input_name = [simulator.problem.input[0]]
            else:
                u_input_name = simulator.problem.input[0]
            
            for i,n in enumerate(u_input_name):
                u[:,u_name.index(n)] = u_mat[:,i]/problem._input_nominal[i]
        else:
            u = N.ones((len(t),len(model.real_u)))*model.real_u
        
        p_names , p_data = simulator.problem.get_sens_result()
        
        # extends the time array with the states columnwise
        data = N.c_[t,yd[:,0:len(model.real_dx)]]
        data = N.c_[data, y[:,0:len(model.real_x)]]
        data = N.c_[data, u]
        data = N.c_[data, y[
            :,len(model.real_x):len(model.real_x)+len(model.real_w)]]

        for i in range(len(p_data)):
            data = N.c_[data, p_data[i]]

        export = ResultWriterDymolaSensitivity(model)
        export.write_header(scaled=write_scaled_result, \
                            file_name=result_file_name)
        map(export.write_point,(row for row in data))
        export.write_finalize()
        
    else:
        raise NotImplementedError

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
 
    
class JMIDAE(Implicit_Problem):
    """
    An Assimulo Implicit Model extended to JMI interface.
    """
    def __init__(self, model, input=None, result_file_name='', start_time=0.0):
        """
        Sets the initial values.
        """
        if input != None and not isinstance(input[0],list):
            input = ([input[0]], input[1])
        
        self._model = model
        self.input = input
        
        #Set start time to the model
        self._model.t = start_time
        
        self.t0 = start_time
        self.y0 = N.append(self._model.real_x,self._model.real_w)
        self.yd0 = N.append(self._model.real_dx,[0]*len(self._model.real_w))
        #Sets the algebraic components of the model
        self.algvar = [1.0]*len(self._model.real_x) + [0.0]*len(self._model.real_w) 
                
        #Used for determine if there are discontinuities
        [f_nbr, g_nbr] = self._model.jmimodel.dae_get_sizes()
        [f0_nbr, f1_nbr, fp_nbr, g0_nbr] = self._model.jmimodel.init_get_sizes()
        
        if f_nbr == 0:
            raise Exception("The JMI framework does not support 'simulation' of 0-dimension systems. Use the FMI framework.")

        if g_nbr > 0:
            #Change the models values of the switches from ints to booleans
            self.sw0 = [bool(x) for x in self._model.sw] 
            self.state_events = self.g_adjust #Activates the event function
        if g0_nbr > 0:
            self.switches_init = [bool(x) for x in self._model.sw_init]
        
        #Construct the input nominal vector
        if self.input != None:
            self._input_nominal = N.array([1.0]*len(self.input[0]))
            if (self._model.get_scaling_method() == jmi.JMI_SCALING_VARIABLES):
                for i in range(len(self.input[0])):
                    val_ref = self._model._xmldoc.get_value_reference(self.input[0][i])
                    for j, nom in enumerate(self._model._xmldoc.get_u_nominal()):
                        if val_ref == nom[0]:
                            if nom[1] == None:
                                self._input_nominal[i] = 1.0
                            else:
                                self._input_nominal[i] = nom[1]

        #Determine the result file name
        if result_file_name == '':
            self.result_file_name = model.get_name()+'_result.txt'
        else:
            self.result_file_name = result_file_name
        
        #Sets default values
        self.max_eIter = 50 #Maximum number of event iterations allowed.
        self.eps = 1e-9 #Epsilon for adjusting the event indicator.
        self.log_events = False #Are we to log the events?
        
        if self._model.has_cppad_derivatives() or self._model.has_cad_derivatives():
            self.jac = self.j #Activates the jacobian
        
        #Sets internal options
        self._initiate_problem = False #Used for initiation
        self._log_initiate_mode = False #Used for logging
        self._log_information = [] #List that handles log information
        self._f_nbr = f_nbr #Number of equations
        self._g_nbr = g_nbr #Number of event indicatiors
        self._g0_nbr = g0_nbr #Number of event indicators at initial time
        self._x_nbr = len(self._model.real_x) #Number of differentiated
        self._w_nbr = len(self._model.real_w) #Number of algebraic
        self._dx_nbr = len(self._model.real_dx) #Number of derivatives
        self._pre = self.y0.copy()
        self._iter = 0
        self._temp_f = N.array([0.]*self._f_nbr)
        self._logLevel = logging.CRITICAL
        self._log = createLogger(model, self._logLevel)
        self._no_initialization = False
        
    def _set_logging_level(self, level):
        if bool(level):
            self._log.setLevel(logging.DEBUG) #Log all entries
        else:
            self._log.setLevel(50) #Log nothing (log nothing below level 50)
    
    def _get_logging_level(self):
        return self._logLevel
        
    log = property(fget=_get_logging_level, fset=_set_logging_level, doc = 
    """
    Property for accessing the logging level. Determines if the logging should 
    be activated (True) or deactivated (False).
    """)
        
    def res(self, t, y, yd, sw=None):
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
        #Used to give independent_vars full control
        z_l = N.array([1]*len(self._model.z),dtype=N.int32) 
        #Derivation with respect to these variables
        independent_vars = [jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_W] 
        sparsity = jmi.JMI_DER_DENSE_ROW_MAJOR
        if self._model.has_cppad_derivatives():
            evaluation_options = jmi.JMI_DER_CPPAD
        else: 
            evaluation_options = jmi.JMI_DER_CAD
            
        #-Evaluating
        #Matrix that hold information about dx and dw
        Jac = N.zeros(self._f_nbr**2) 
        #Output x+w
        self._model.jmimodel.dae_dF(
            evaluation_options, sparsity, independent_vars[1:], z_l, Jac) 
        
        #Matrix that hold information about dx'
        dx = N.zeros(len(self._model.real_dx)*self._f_nbr) 
        #Output dx'
        self._model.jmimodel.dae_dF(
            evaluation_options, sparsity, independent_vars[0], z_l, dx) 
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
        
    def g_init(self,t,y,yd,sw):
        """
        The event indicator function for a DAE problem at initial time.
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
        self._model.jmimodel.init_R0(eventInd)
        
        return eventInd
    
    def g_adjust(self, t, y, yd, sw):
        """
        This function adjusts the event functions according to Martin Otter et 
        al defined in 'Modeling of Mixed Continuous/Discrete Systems in Modelica'.
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
        
        self._log.debug('State event occurred at time: %f'%solver.t)
        nbr_iteration = 0

        while self.max_eIter > nbr_iteration: #Event Iteration
            
            self._log.debug(' Current switches: ' +str(solver.sw))
            self._log.debug(' Event information: '+str(event_info))
            self._log.debug(' Current States: '+str(solver.y))
            self._log.debug(' Current State Derivatives: '+str(solver.yd))
            
            self.event_switch(solver, event_info) #Turns the switches

            b_mode = self.g(
                solver.t, solver.y, solver.yd, solver.sw)
            #Pass in the solver to the problem specified init_mode
            self.init_mode(solver) 
            a_mode = self.g(
                solver.t, solver.y, solver.yd, solver.sw)

            self._log.debug(' Root equations (pre)  : '+str(b_mode))
            self._log.debug(' Root equations (after): '+str(a_mode))

            [event_info, iter] = self.check_eIter(b_mode, a_mode)
                
            if not iter: #Breaks the iteration loop
                break
            
            nbr_iteration += 1
        
    def event_switch(self, solver, event_info):
        """
        This is where we turn the switches. If we have an event, this is where 
        it will be taken care of. ::
        
            event_info is a vector consisting of -1, 0, +1, and is as long as 
            the number of event functions. A -1 symbolises that an event has 
            occured at the specified switch and is decreasing. A 0 symbolises 
            that nothing has happend. A +1 symbolises that an event has occured 
            at the specified switch and is increasing.
            
        This is the default event handling.
        """
        for i in range(len(event_info)): #Loop across all event functions
            if event_info[i] == -1:
                solver.sw[i] = False
            if event_info[i] == 1:
                solver.sw[i] = True
        
    def init_mode(self, solver):
        """
        Initiates the new mode.
        """
        if self._initiate_problem:
            #Check wheter or not it involves event functions
            if self._g_nbr > 0:
                self._model.sw = [int(x) for x in solver.sw]
            if self._g0_nbr > 0:
                self._model.sw_init = [int(x) for x in self.switches_init]

            #Initiate using IPOPT
            init_nlp = NLPInitialization(self._model)
            init_nlp_ipopt = InitializationOptimizer(init_nlp)
            init_nlp_ipopt.init_opt_ipopt_solve()
            
            #Sets the calculated values
            solver.y = N.append(self._model.real_x,self._model.real_w)
            solver.yd = N.append(self._model.real_dx,[0]*len(self._model.real_w)) 
        else:
            self._model.sw = [int(x) for x in solver.sw]
            
            if self.log_events:
                self._log_initiate_mode = True #Logg f evaluations
                i = len(self._log_information) #Where to put the information
            try:
                solver.make_consistent('IDA_YA_YDP_INIT') #Calculate consistency
                self._log.debug(
                    ' Calculation of consistent initial conditions: True')
            except Sundials_Exception as data:
                print data
                print 'Failed to calculate initial conditions. Trying to continue...'
                self._log.debug(
                    ' Calculation of consistent initial conditions: True')
            
            self._log_initiate_mode = False #Stop logging f
                
    def check_eIter(self, before, after):
        """
        Helper function for handle_event to determine if we have event 
        iteration.
        
        Parameters::
        
            Values of the event indicator functions (state_events) before and 
            after we have changed mode of operations.
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
        if not isinstance(max_eIter, int) or max_eIter < 0:
            raise JMIModel_Exception('max_eIter must be a positive integer.')
        self.__max_eIter = max_eIter
        
    def _get_max_eIteration(self):
        return self.__max_eIter

    max_eIter = property(_get_max_eIteration, _set_max_eIteration, doc=
    """
    Property for setting the maximum number of event iterations allowed.
    """)
    
    def _set_input(self, input):
        self.__input = input
        
    def _get_input(self):
        return self.__input

    input = property(_get_input, _set_input, doc = 
    """
    Property for accessing the input. The input must be a 2-tuple with the first 
    object as a list of names of the input variables and with the other as a 
    subclass of the class Trajectory.
    """)
    
    def _set_eps(self, eps):
        if not isinstance(eps, float) or eps < 0.0:
            raise JMIModel_Exception('Epsilon must be a positive float.')
        self.__eps = eps
        
    def _get_eps(self):
        return self.__eps
        
    eps = property(_get_eps,_set_eps, doc=
    """
    Property for accessing the epsilon used for adjusting the event indicators.
    """)
    
    def initialize(self,solver):
        """
        Initiates the problem.
        """
        self._initiate_problem = True
        
        if self._no_initialization == True:
            self._initiate_problem = False
            return
        
        if self._g0_nbr > 0:
            
            self.switches_init = [True]*(self._g0_nbr-self._g_nbr)
            #sw_val = N.array([.0]*len(self._model.sw))
            sw_val = N.array([0.0]*(self._g0_nbr))
            #self._model.jmimodel.dae_R(sw_val)
            self._model.jmimodel.init_R0(sw_val)
            
            for i in range(self._g_nbr):
                if sw_val[i] >= 0.0:
                    solver.sw[i] = True
                else:
                    solver.sw[i] = False
            for i in range(self._g0_nbr-self._g_nbr):
                if sw_val[self._g_nbr+i] >= 0.0:
                    self.switches_init[i] = True
                else:
                    self.switches_init[i] = False
                    
            nbr_iteration = 0
            while self.max_eIter > nbr_iteration: #Event Iteration
                
                b_mode = self.g_init(
                    solver.t, solver.y, solver.yd, solver.sw+self.switches_init)
                #Pass in the solver to the problem specified init_mode
                self.init_mode(solver) 
                
                a_mode = self.g_init(
                    solver.t, solver.y, solver.yd, solver.sw+self.switches_init)

                [event_info, iter] = self.check_eIter(b_mode, a_mode)
                    
                if not iter: #Breaks the iteration loop
                    break
                    
                for i in range(len(event_info)): #Loop across all event functions
                    if i < self._g_nbr:
                        if event_info[i] == -1:
                            solver.sw[i] = False
                        if event_info[i] == 1:
                            solver.sw[i] = True
                    else:
                        if event_info[i] == -1:
                            self.switches_init[i-self._g_nbr] = False
                        if event_info[i] == 1:
                            self.switches_init[i-self._g_nbr] = True
            
                nbr_iteration += 1
        
            #self.handle_event(solver, [[0],False])
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
    An Assimulo Implicit Model extended to JMI interface with support for 
    sensitivities.
    """
    def __init__(self, model, input=None, result_file_name='', start_time=0.0):
        """
        Sets the initial values.
        """
        if input != None and not isinstance(input[0],list):
            input = ([input[0]], input[1])
        
        self._model = model
        self.input = input
        
        #Set start time to the model
        self._model.t = start_time
        
        self.t0 = start_time
        self.y0 = N.append(self._model.real_x,self._model.real_w)
        self.yd0 = N.append(self._model.real_dx,[0]*len(self._model.real_w))
        #Sets the algebraic components of the model
        self.algvar = [1.0]*len(self._model.real_x) + [0.0]*len(self._model.real_w) 
        
        #Used for determine if there are discontinuities
        [f_nbr, g_nbr] = self._model.jmimodel.dae_get_sizes() 
        [f0_nbr, f1_nbr, fp_nbr, g0_nbr] = self._model.jmimodel.init_get_sizes()
        
        if g_nbr > 0:
            raise JMIModel_Exception("Hybrid models with event functions are currently not supported.")
        
        if f_nbr == 0:
            raise Exception("The JMI framework does not support 'simulation' of 0-dimension systems. Use the FMI framework.")

        
        #Construct the input nominal vector
        if self.input != None:
            self._input_nominal = N.array([1.0]*len(self.input[0]))
            if (self._model.get_scaling_method() == jmi.JMI_SCALING_VARIABLES):
                for i in range(len(self.input[0])):
                    val_ref = self._model._xmldoc.get_value_reference(self.input[0][i])
                    for j, nom in enumerate(self._model._xmldoc.get_u_nominal()):
                        if val_ref == nom[0]:
                            if nom[1] == None:
                                self._input_nominal[i] = 1.0
                            else:
                                self._input_nominal[i] = nom[1]
        
        if self._model.has_cppad_derivatives():
            self.jac = self.j #Activates the jacobian
        
        #Default values
        self.export = ResultWriterDymolaSensitivity(model)
        
        #Determine the result file name
        if result_file_name == '':
            self.result_file_name = model.get_name()+'_result.txt'
        else:
            self.result_file_name = result_file_name
        
        #Internal values
        self._parameter_names = [
            name[1] for name in self._model.get_p_opt_variable_names()]
        self._parameter_valref = [
            name[0] for name in self._model.get_p_opt_variable_names()]
        self._parameter_pos = [jmi._translate_value_ref(x)[0] for x in self._parameter_valref]
        self._sens_matrix = [] #Sensitivity matrix
        self._f_nbr = f_nbr #Number of equations
        self._f0_nbr = f0_nbr #Number of initial equations
        self._g_nbr = g_nbr #Number of event indicatiors
        self._x_nbr = len(self._model.real_x) #Number of differentiated
        self._w_nbr = len(self._model.real_w) #Number of algebraic
        self._dx_nbr = len(self._model.real_dx) #Number of derivatives
        self._p_nbr = len(self._parameter_names) #Number of parameters
        self._write_header = True
        self._input_names = [k[1] for k in sorted(model.get_u_variable_names())]

        #Used for logging
        self._logLevel = logging.CRITICAL
        self._log = createLogger(model, self._logLevel)
        
        #Set the start values to the parameters.
        if self._parameter_names:
            self.p0 = N.array([])
            for i,n in enumerate(self._parameter_names):
                self.p0 = N.append(self.p0, self._model.z[self._parameter_pos[i]])
                self._sens_matrix += [[]] 
            self.pbar = N.array([N.abs(x) if N.abs(x) > 0 else 1.0 for x in self.p0])
            self._p_nbr = len(self.p0) #Number of parameters
        else:
            self._p_nbr = 0
            
        #Initial values for sensitivity
        if self._p_nbr > 0:
            self.yS0 = self._sens_init()

        self._log.debug('Number of parameters: ' +str(self._p_nbr))
    
    def _sens_init(self):
        """
        Calculates the initial values of the sensitivity.
        """
        yS0 = N.zeros((self._p_nbr,self._f_nbr))
        
        if self._f0_nbr != self._f_nbr:
            #Evaluating the jacobian
            #-Setting options
            #Used to give independent_vars full control
            z_l = N.array([1]*len(self._model.z),dtype=N.int32) 
            #Derivation with respect to these variables
            independent_vars = [jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_W, 
                                jmi.JMI_DER_PI, jmi.JMI_DER_PD] 
            sparsity = jmi.JMI_DER_DENSE_ROW_MAJOR
            evaluation_options = jmi.JMI_DER_CPPAD#jmi.JMI_DER_SYMBOLIC
            
            #-Evaluating
            #Matrix that hold information about dx and dw
            dFdxw = N.zeros(self._f0_nbr*(self._x_nbr+self._w_nbr)) 
            #Output x+w
            self._model.jmimodel.init_dF0(
                evaluation_options, sparsity, independent_vars[1:3], z_l, dFdxw) 
            
            #Matrix that hold information about dx'
            dFddx = N.zeros(self._x_nbr*self._f0_nbr) 
            #Output dx'
            self._model.jmimodel.init_dF0(
                evaluation_options, sparsity, independent_vars[0], z_l, dFddx) 
            
            #Matrix that hold information about dp
            dFdp = N.zeros(self._p_nbr*self._f0_nbr) 
            #Output dp
            z_l = N.array([0]*len(self._model.z),dtype=N.int32) 
            for i in self._parameter_pos:
                z_l[i] = 1
            self._model.jmimodel.init_dF0(
                evaluation_options, sparsity, independent_vars[3:], z_l, dFdp) 
            
            #-Vector manipulation
            dFdxw = dFdxw.reshape(self._f0_nbr,self._x_nbr+self._w_nbr)[self._f_nbr:,:]
            dFddx = dFddx.reshape(self._f0_nbr,self._dx_nbr)[self._f_nbr:,:]
            dFdp  = dFdp.reshape(self._f0_nbr,self._p_nbr)[self._f_nbr:,:]

            p_order = N.zeros(len(self._parameter_pos),dtype=int)
            p_sort = N.sort(self._parameter_pos)
            for ind,val in enumerate(p_sort):
                p_order[self._parameter_pos.index(val)]=ind
            
            #print "Param order, ", self._model.get_p_opt_variable_names(), p_order
            dFdp = N.transpose(N.transpose(dFdp)[p_order])

            yS0= N.transpose(N.linalg.lstsq(dFdxw,-dFdp)[0])
        
        return yS0
    
    def res(self, t, y, yd, p=None):
        """
        The residual function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y[0:self._x_nbr]
        self._model.real_w = y[self._x_nbr:self._f_nbr]
        self._model.real_dx = yd[0:self._dx_nbr]
        
        #Set the free parameters
        if not p==None:
            for ind, val in enumerate(p):
                self._model.z[self._parameter_pos[ind]] = val
            
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the residual function
        residual = N.array([.0]*self._f_nbr)
        self._model.jmimodel.dae_F(residual)

        return residual
        
    def j(self, c, t, y, yd, sw=None, p=None):
        """
        The jacobian function for an DAE problem.
        """
        #Moving data to the model
        self._model.t = t
        self._model.real_x = y[0:self._x_nbr]
        self._model.real_w = y[self._x_nbr:self._f_nbr]
        self._model.real_dx = yd[0:self._dx_nbr]
        
        #Set the free parameters
        if not p==None:
            for ind, val in enumerate(p):
                self._model.z[self._parameter_pos[ind]] = val
        
        #Sets the inputs, if any
        if self.input!=None:
            self._model.set(self.input[0], self.input[1].eval(t)[0,:])
        
        #Evaluating the jacobian
        #-Setting options
        #Used to give independent_vars full control
        z_l = N.array([1]*len(self._model.z),dtype=N.int32) 
        #Derivation with respect to these variables
        independent_vars = [jmi.JMI_DER_DX, jmi.JMI_DER_X, jmi.JMI_DER_W] 
        sparsity = jmi.JMI_DER_DENSE_ROW_MAJOR
        evaluation_options = jmi.JMI_DER_CPPAD#jmi.JMI_DER_SYMBOLIC
        
        #-Evaluating
        #Matrix that hold information about dx and dw
        Jac = N.zeros(self._f_nbr**2) 
        #Output x+w
        self._model.jmimodel.dae_dF(
            evaluation_options, sparsity, independent_vars[1:], z_l, Jac) 
        
        #Matrix that hold information about dx'
        dx = N.zeros(len(self._model.real_dx)*self._f_nbr) 
        #Output dx'
        self._model.jmimodel.dae_dF(
            evaluation_options, sparsity, independent_vars[0], z_l, dx) 
        dx = dx*c #Scale
        
        #-Vector manipulation
        Jac = Jac.reshape(self._f_nbr,self._f_nbr)
        dx = dx.reshape(self._f_nbr,self._dx_nbr)
        Jac[:,0:self._dx_nbr] += dx

        return Jac
        
    def handle_result(self, solver, t ,y, yd):
        """
        Post processing (stores the time points and the sensitivity result).
        """
        if solver.report_continuously:
            if self._write_header:
                self._write_header = False
                self.export.write_header(file_name=self.result_file_name)
                
            p_data = []
            for i in range(self._p_nbr):
                p_data += [solver.interpolate_sensitivity(t, 0, i)]
            
            # extends the time array with the states columnwise
            data = N.append(t,yd[0:len(self._model.real_dx)])
            data = N.append(data, y[0:len(self._model.real_x)])
            if self.input!=None:
                input_data = N.ones(len(self._input_names))*self._model.real_u
                input_eval = self.input[1].eval(float(t))[0,:]
                for i,n in enumerate(self.input[0]):
                    input_data[self._input_names.index(n)] = input_eval[i]/self._input_nominal[i]
                data = N.append(data, input_data)
            else:
                data = N.append(data,N.ones(len(self._model.real_u))*self._model.real_u)
            data = N.append(data, y[len(self._model.real_x):len(self._model.real_x)+len(self._model.real_w)])
            
            for i in range(len(p_data)):
                data = N.append(data, p_data[i])
            
            self.export.write_point(data)
        else:
            solver.t_sol  += [t]
            solver.y_sol  += [y]
            solver.yd_sol += [yd]
            
            #Store the sensitivity matrix
            for i in range(self._p_nbr):
                self._sens_matrix[i] += [solver.interpolate_sensitivity(t, 0, i)]
    
    def finalize(self, solver):
        if solver.report_continuously:
            self.export.write_finalize()
    
    def get_sens_result(self):
        """
        Returns the sensitivity results together with the names.
        
        Returns::
        
            parameter_names, sensitivity_matrix = JMIDAESens.get_sens_result()
                
            parameters_names -- 
                The names of the parameters for which sensitivities have been 
                calculated.
                                       
            sensitivity_matrix -- 
                A matrix containing the sensitivities for all the parameters. 
                sensitivity_matrix[0], gives the result for the first parameter 
                in the parameters_names list.
        """
        for i in range(self._p_nbr):
            self._sens_matrix[i] = N.array(
                self._sens_matrix[i]).reshape(-1,self._f_nbr)
            
        return self._parameter_names, self._sens_matrix
        
    def _set_logging_level(self, level):
        if bool(level):
            self._log.setLevel(logging.DEBUG) #Log all entries
        else:
            self._log.setLevel(50) #Log nothing (log nothing below level 50)
    
    def _get_logging_level(self):
        return self._logLevel
        
    log = property(fget=_get_logging_level, fset=_set_logging_level, doc = 
    """
    Property for accessing the logging level. Determines if the logging should 
    be activated (True) or deactivated (False).
    """)

