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
from pyjmi.common.io import ResultDymolaTextual
from pyjmi.jmi_algorithm_drivers import LocalDAECollocationAlg, LocalDAECollocationAlgOptions
from pyjmi.optimization.casadi_collocation import ExternalData

import time, types
import numpy as N
import casadi

from newEstPack import *
from collections import OrderedDict
from scipy.stats import norm
from scipy.stats import chi2
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import get_files_path
from casadi import MX
import cPickle as pickle
import modelicacasadi_wrapper as mc
from scipy.stats import chi2

from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError
from pyjmi import transfer_optimization_problem
from IPython.core.debugger import Tracer; dh = Tracer() #DELETTE BEFORE COMMIT
# TODO: CHECK IF ALL THESE ARE NEEDED??
#Check to see if pyfmi is installed so that we also catch the error generated
#from that package
from pymodelica.common.io import VariableNotFoundError as \
     pymodelicaVariableNotFoundError
try:
    from pyfmi.common.io import VariableNotFoundError as \
         fmiVariableNotFoundError
    VariableNotFoundError = (
        jmiVariableNotFoundError, pymodelicaVariableNotFoundError,
        fmiVariableNotFoundError)
except ImportError:
    VariableNotFoundError = (jmiVariableNotFoundError,
                             pymodelicaVariableNotFoundError)



class GreyBox(object):

    """
	GREYBOX FRAMEWORK
    """

    def __init__(self, op, options, measurements, inputs, time, costType="integral", hs = True):
        """

        """
        self.op = op
        self.options = options
        self.measurements = measurements
        self.inputs = inputs
        self.time = time
        self.costType = costType
        
        self.prefix = "GreyBox_"
        self.free_parameters = set()
        
        # if non-constant sample period for measurements
        if hs:
            diffTimePoints = np.diff(time)
            sumTimePoints = np.sum(diffTimePoints)
            self.options['hs'] = diffTimePoints/sumTimePoints
            
        # set parameters for calculating cost, costred and risk
        self.df = 0
        self.n = 0
        N_meas = len(time)
        self.tf = time[-1]
        self.t0 = time[0]
        
        # set start and final time
        startTime = self._add_real_parameter('startTime')
        self.op.set('startTime', self.t0)
        finalTime = self._add_real_parameter('finalTime')
        self.op.set('finalTime', self.tf);
        op.setStartTime(MX(self.t0))
        op.setFinalTime(MX(self.tf))

        # Check if free parameters already in model
        # QUESTION LOOP OVER INTEGER PARAMETERS AS WELL?
        for par in self.op.getVariables(self.op.REAL_PARAMETER_INDEPENDENT):
            if par.hasAttributeSet('free'):
                if par.getAttribute('free'):
                    self.free_parameters.add(par.getName())
                    
        for par in self.op.getVariables(self.op.REAL_PARAMETER_DEPENDENT):
            if par.hasAttributeSet('free'):
                if par.getAttribute('free'):
                    self.free_parameters.add(par.getName())
        
        # set number of collocation elements so their endpoint coincide with measurement points
        self.options['n_e'] = (N_meas-1)
        
        # add parameters for noise convariance of measured variables
        # add input real for measured signals
        if costType == "integral":
            self.options['n_cp'] = 1
            self.weight = options['n_e']/(self.tf-self.t0)
            
            for var in measurements.keys(): 
                # Add parameter for noise convariance, set initial guess to base nominal squared
                r = self._add_real_parameter(self.prefix+'r_'+var)
                base_var = op.getVariable(var)
                value = base_var.getAttribute('nominal').getValue()
                self.op.set(self.prefix+'r_'+var, value**2)
                r.setAttribute('initialGuess', value**2) 
                r.setAttribute('min',0)

                # TODO: allow user defined values as well
                
                # Create real input for measurement data 
                meas = self._add_real_input(self.prefix+'measured_'+var)

                # Add w*(y-y_meas)²/r to Objective Integrand 
                oi = self.op.getObjectiveIntegrand()
                self.op.setObjectiveIntegrand(oi+self.weight*(base_var.getVar()-meas.getVar())**2/r.getVar())
                
                # Add log term and first measurement to objective
                timed_var = self._add_timed_variable(var,time[0])
                obj = self.op.getObjective()
                self.op.setObjective(obj + (N_meas)*log(r.getVar())+(timed_var.getVar()-measurements[var][0])**2/r.getVar())
                
        elif costType =="sum":
            
            # add parameters for noise convariance of measured variables
            # add timed variable for each variable and measurementpoint
            for var in measurements.keys(): 
                
                # Add parameter for noise convariance, set initial guess to base nominal squared
                r = self._add_real_parameter(self.prefix+'r_'+var)
                base_var = op.getVariable(var)
                value = base_var.getAttribute('nominal').getValue()
                self.op.set(self.prefix+'r_'+var, value**2)
                r.setAttribute('initialGuess', value**2)
                r.setAttribute('min',0)
                
                for i in range(0,len(self.time)): 
                    # Add timed variable
                    timed_var = self._add_timed_variable(var,time[i])
                    
                    obj = self.op.getObjective()
                    self.op.setObjective(obj+(timed_var.getVar()-measurements[var][i])**2/r.getVar())
                    
                # add logterm
                obj = self.op.getObjective() 
                self.op.setObjective(obj+(N_meas-1)*log(r.getVar()))
                
            
        else:
            warning("costType not implemented")
            
        self._create_external_data()
        
    def _create_external_data(self):
        """
        Creates an ExternalData object that is loaded into the optimization. 
        The object eliminates the inputs defined when creating the GreyBox object 
        as well as the inputs added for the measured data (if costType='integral').
        """
        dictionary = {}
        
        # add external data for measured variables
        if self.costType == "integral":
            for (name, data) in self.measurements.items():
                dictionary[self.prefix+'measured_'+name] = np.vstack([self.time,data])
        
        # add external data for inputs    
        for (name, data) in self.inputs.items():
            dictionary[name] = np.vstack([self.time,data])
    
        #create mesurement_data object to load into the optimization
        measurement_data = ExternalData(dictionary)
        self.options['external_data'] = measurement_data
        
    def _add_real_input(self, name):
        """
        Adds a new real input to the optimization problem object.
        
        Parameters::
            name --
                The name of the new input. Given as a string
        
        Returns::
            input --
                The added input variable 
        """
        inp = mc.RealVariable(self.op, MX.sym(name), 
        mc.Variable.INPUT, 
        mc.Variable.CONTINUOUS)
        self.op.addVariable(inp)
        return inp
        
    def _add_real_variable(self, name):
        """
        Adds a real variable to the optimization problem object.
        
        Parameters::
            name --
                The name of the new variable. Given as a string
        
        Returns::
            var --
                The added variable
        """
        var = mc.RealVariable(self.op, MX.sym(name), 
        mc.Variable.INTERNAL, 
        mc.Variable.CONTINUOUS)
        self.op.addVariable(var)
        return var
        
    def _add_real_parameter(self, name):
        """
        Adds a real parameter to the optimization problem object.
        
        Parameters::
            name --
                The name of the new parameter.
        
        Returns::
            par --
                The parameter variable
        """
        par = mc.RealVariable(self.op, MX.sym(name), 
        mc.Variable.INTERNAL, 
        mc.Variable.PARAMETER)
        self.op.addVariable(par)
        return par
        
    def _add_timed_variable(self, name,timePoint):
        """
        Adds a timed variable to the optimization problem object.
        
        Parameters::
            name --
                The name of the base variable.
            timePoint --
                The timepoint that the timed variable shall be for .
        
        Returns::
            par --
                The timed variable
        """
        var_symb = MX.sym("%s(%f)" %(name,timePoint))
        base_var = self.op.getVariable(name)
        timed_var= mc.TimedVariable(self.op, var_symb, base_var, MX(timePoint))
        self.op.addTimedVariable(timed_var)
        return timed_var
        
    def identify(self):
        """
        Prints the parameters that are currently free and solves the optimization problem.
        If the solver fails to converge the cost returned will be Inf.
        
        """
        # print currently free parameters
        print ('Identifying with free parameters:')
        print self.free_parameters
        res = self.op.optimize(options=self.options)
        
        # optimize
        returnStatus = res.solver.get_solver_statistics()[0]
        if (returnStatus == 'Solve_Succeeded') or (returnStatus=='Solved_To_Acceptable_Level'):
            cost = res.solver.get_solver_statistics()[2]
        else:
            cost = Inf
        
        # return identification object
        return IdentificationObject(self, frozenset(self.free_parameters), res, cost)
        
    def set_free_parameters(self, parameters):
        """
        Sets the specified parameters as free parameters.
              
        Parameters::
            parameters --
                The parameters to be free in the next optimization.
        """
        # Set previously free parameters to fixed if not in parameters
        fix = self.free_parameters.difference(parameters)
        for name in fix:
            par = self.op.getVariable(name)
            par.setAttribute('free', 0)
        
        # Free parameters that are not already free   
        free = parameters.difference(self.free_parameters)
        for name in free:
            par = self.op.getVariable(name)
            par.setAttribute('free', 1)
            
            # Check if initial guess is set, otherwise set to parameter value
            if not par.hasAttributeSet('initialGuess'):
                par.setAttribute('initialGuess', self.op.get(name))
        
         # update free_parameters to parameters
        self.free_parameters = parameters.copy()
         
 
    def print_optimial_parameters(self, res):  
        """
        Extracts the free parameters values from res and prints them.
        
        Parameters::
            res --
                Result object from which to extract the parameter values.     
        """  
        print(extract_parameter_values(res,self.free_parameters))
        
    def set_initial_trajectory(self, result):
        """
        Sets the initial guess to use for optimizations.
        
        Parameters::
            res --
                Result object to use as initial guess.     
        """    
        self.options['init_traj'] = result
    
    def set_options(self, option, value):  
        """
        Sets the optimization option to value. 
        
        Parameters::
            option --
                The option to set.     
            value --
                The value to set option to.
                
        Note that the framework does not allow the user to change 'n_e', 'n_c' or 'external_data'. 
        The one exception is if costType = 'sum', then 'n_c' may be changed.
        """     
        if option in ['n_e', 'n_c', 'external_data']:
            if not (option == 'n_c' and costType == 'sum'):
                print('You are not allowed to change this option')
        else:
            self.options[option] = value

    def set_variable_attribute(self, name, attribute, value):
        """
        Sets the variable name:s attribute to value. 
        
        Parameters::
            name --
                The name of the variable to set attribute on. 
            attribute --
                The attribute to set.     
            value --
                The value to set attribute to.
        """ 
        var = self.op.getVariable(name)
        var.setAttribute(attribute,value)
        
    def extract_parameter_values(self, result, parameters):
        """
        Extracts and returns parameters values from opt_data.
        
        Parameters::
            result --
                The result object from which to extract the parameter values. 
            parameters --
                List of parameter names to extract values for.     

        Returns an OrderedDict() with parameter names as keys and their values as values.
        """  
        est_parameters = OrderedDict()
		
        for (name) in parameters:
            est_parameters[name] = result.final(name)

        return est_parameters
        


class IdentificationObject(object):

    """
	GREYBOX FRAMEWORK
    """

    def __init__(self, greybox, free_parameters, result, cost):
        """

        """
        self.greybox = greybox
        self.free_parameters = free_parameters
        self.result = result
        self.cost = cost
        
        greybox.set_initial_trajectory(result)
        
    def release(self, parameters):

        # make new set with parameters to be free
        param = self.free_parameters.union(parameters)
        self.greybox.set_free_parameters(param)
        
        return self.greybox.identify()
    
    def compare(self, idObj):
        
        nbrFreeNull = len(self.free_parameters)
        cases = len(idObj)
        resultDict = {}
        for obj in idObj:
            additionalFree = []
            for par in obj.free_parameters:
				if par not in self.free_parameters:
					additionalFree.append(par)
            dof = len(additionalFree)
            
            print("Additional free parameter/-s:")
            for par in additionalFree:
				print(par)
            print("Cost: %f" % obj.cost)
            costred = self.cost-obj.cost
            print("Cost red: %f" % costred)
            risk= self.calculate_risk(costred, dof, cases)
            print("Risk: %f" % risk )
            print("")
            
            if dof == 1:
				name = additionalFree.pop()
				resultDict[name] = {}
				resultDict[name]['cost'] = obj.cost
				resultDict[name]['costred'] = costred
				resultDict[name]['risk'] = risk
				
        return resultDict
        
    def calculate_risk(self, costred, df, n):  
        """
        Calculates and returns the risk of the last optimization.
        
        Parameters::
            costred --
                Cost reduction.
            df --
                Degrees of freedom.
            n --
                Number of combinations.
                
       """  
        risk = 1-chi2.cdf(costred,df)**n    
        return risk
       
