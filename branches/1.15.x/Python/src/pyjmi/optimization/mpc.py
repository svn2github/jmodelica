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
from pyjmi.jmi_algorithm_drivers import MPCAlgResult, LocalDAECollocationAlg
from pyjmi.optimization.casadi_collocation import BlockingFactors
import time
import numpy as N
#~ from IPython.core.debugger import Tracer; dh = Tracer()

class MPC(object):
    """
    Creates an MPC-object which allows a dynamic optimization problem to be 
    updated with measurements of the states.  
    """
    
    def __init__(self, op, options, sample_period, nbr_samp):

        self._create_clock()
        self.op = op
        self.collocator_options = options
        self.sample_period = sample_period  
        self.nbr_samp = nbr_samp

        #Create complete result lists
        self.res_t = []
        self.res_dx = []
        self.res_x = []
        self.res_u = []
        self.res_w = []
        self.res_p = []
        
        #Define some things
        self._sample_nbr = 1
        self._result_file_name_complete = "MPC_results"
        self._start_index = 0
        N.random.seed([7])
        
        #Transcribe the DOP to a nlp
        self._create_nlp_object()
        
        #Save the initialization time
        self.times['init'] = time.clock() - self._startTime
        self.t0_update = time.clock()

    def _create_clock(self):
        """
        Create a dictionary where times for different operations are stored.
        """
        self._startTime = time.clock()
        self.times = {}
        self.times['init'] = 0
        self.times['update'] = 0
        self.times['sol'] = 0
        self.times['post_processing'] = 0
        self.times['tot'] = 0
        self.times['maxTime'] = 0

    def _create_nlp_object(self):
        """
        Transcribes the DOP into a NLP. Grants access to an instance of 
        LocalDAECollocator: op.collocator        
        """
        self._set_blocking_options()
        self.extra_init = time.clock() - self._startTime
        self.alg = LocalDAECollocationAlg(self.op, self.collocator_options)
        self.collocator = self.alg.nlp
        self._get_states_and_initial_value_parameters()
        if not self.collocator._normalize_min_time:
            self._calculate_nbr_values_sample()

    def _set_blocking_options(self):
        """
        Creates blocking factors for the input. Default blocking factors are:
        Constant input through each sample with quadratic penalty 500. 
        """
        if self.collocator_options['blocking_factors'] is None:
            n_e = self.collocator_options['n_e']
            value = n_e/self.nbr_samp
            bl_list = [value for i in range(n_e/value)]
            inputs = self.op.getVariables(self.op.REAL_INPUT)
            for i in range(len(inputs)):
                name = inputs[i].getName()
                factors = {name: bl_list}
                du_quad_pen = {name: 500} #Change to a factor*nominal/initialGuess?
            bf = BlockingFactors(factors = factors, du_quad_pen = du_quad_pen)
            self.collocator_options['blocking_factors'] = bf
                
    def _get_states_and_initial_value_parameters(self):
        """
        Save the indices in the collocators _par_vals vector for the initial 
        values of the measured states + start and final times.
        """
        #Retrieve the names of all the states (excluding cost)
        states = self.collocator.mvar_vectors['x']
        self.state_names = []
        for i in range(len(states)):
            name = states[i].getName()
            if name != 'cost':
                self.state_names.append(name)
                
        #Find and save the indices for each states initial value + startTime 
        #and finalTime. (For min time problems only the startTime is saved)
        self.index = {}    
        for name in self.state_names:
            name_init = "_start_"+name
            self.index[name_init] = self.collocator.var_indices[name_init]
        
        if self.collocator._normalize_min_time:
            self.index['startTime'] = self.collocator.var_indices['startTime']
        else:
            for par in ['startTime', 'finalTime']:
                self.index[par] = self.collocator.var_indices[par]
            
    def _set_warm_start_options(self):
        """
        Sets the warm start options for Ipopt if they have not already been set
        by the user. Default warm start options are:
        'warm_start_init_point' = 'yes'
        'mu_init' = 1e-4
        """  
        if self.collocator_options['IPOPT_options'].get('warm_start_init_point') == None:
            self.collocator.set_solver_option('warm_start_init_point','yes')
        if self.collocator_options['IPOPT_options'].get('mu_init') == None:
            self.collocator.set_solver_option('mu_init',1e-4)
        self.collocator.set_solver_option('expand',False)

    def update_nlp_state(self, state_dict = None):
        """ 
        Updates the initial value for the next sample based on the values in
        state_dict. Moves the optimization time one sample_period forward.
        
        Parameters::
            
            state_dict --
                A dictionary containing the measurements of the states in this
                sample. The measurements will be put through an estimator to 
                estimate their value in the next sample. 
                If None measurements will be generated automatically 
                based on the prediction (previous result) of the state in the 
                next sample.
                Default: None 
        """  
        #Update times and sample number
        self.t0_update = time.clock()
        self.alg._t0 = time.clock()
        self._sample_nbr+=1
        
        #Either send the measurements to a predictor or generate measurements.
        if state_dict is None:
            state_dict = self._generate_measurements()
        else:
            state_dict = self._state_estimation(state_dict)

        #Updates states
        for key in state_dict.keys():
            if not self.index.has_key(key):
                raise Exception("You are not allowed to change %s" %key)
            else:
                self.collocator._par_vals[self.index[key]] = state_dict[key]

    def sample(self):
        """
        Redefines the initial trajectories (for all but the first sample) and 
        solves the NLP. 
        Warm start is initiated the second time sample is called.  
        """
        if self._sample_nbr > 2:
            self._redefine_initial_trajectories()
        elif self._sample_nbr == 2: #Initiate the warm start
            self.collocator.warm_start = True
            self._set_warm_start_options()
            self._redefine_initial_trajectories()
            self.collocator._set_solver_inputs()
        
        #Solve the nlp    
        self.time_update = time.clock() - self.t0_update
        t0_sol = time.clock()
        self.alg.solve()
        self.time_sol = time.clock() - t0_sol
        self.t0_post = time.clock()
        
        #Get the results and extract the results for this 
        self._result_object = self.alg.get_result()
        self._extract_results()
        self._append_to_result_file()
        self._add_times()
        return self.get_opt_input()

    def _redefine_initial_trajectories(self):
        """
        Updates the collocators initial trajectories and times for the next
        optimization.
        """

        self.collocator.init_traj = self._result_object
        try:
            self.collocator.init_traj = self.collocator.init_traj.result_data
        except AttributeError:
            pass
            
        self.collocator._par_vals[self.index['startTime']] +=\
                                                        self.sample_period
        
        if self.collocator._normalize_min_time:
            #Something is very wrong..
            self.collocator.t0 += self.sample_period /(self.result[0][-1]-self.result[0][0])
            self.collocator.tf += self.sample_period /(self.result[0][-1]-self.result[0][0])
            self.collocator.horizon = self.collocator.tf - self.collocator.t0
            time = self.collocator._compute_time_points()
            self.collocator._denormalize_times()
            self.collocator._create_initial_trajectories()        
            self.collocator.time = N.array(time)
            self.collocator._compute_bounds_and_init()
        else:
            self.collocator._par_vals[self.index['finalTime']] +=\
                                                        self.sample_period
            self.collocator.t0 += self.sample_period
            self.collocator.tf += self.sample_period
            time = self.collocator._compute_time_points()
            self.collocator._create_initial_trajectories()        
            self.collocator.time = N.array(time)
            self.collocator._compute_bounds_and_init()
            

    def get_complete_results(self):
        """
        Creates and returns the patched together resultfile from all 
        optimizations.
        """
        self.res_t = N.array(self.res_t).reshape([-1, 1])
        self.res_dx = N.array(self.res_dx).reshape([-1, len(self.res_dx[0])])
        self.res_x = N.array(self.res_x).reshape([-1, len(self.res_x[0])])
        self.res_u = N.array(self.res_u).reshape([-1, len(self.res_u[0])])
        if len(self.res_w[0] >= 1):
            self.res_w = N.array(self.res_w).reshape([-1, len(self.res_w[0])])
        else:
            self.res_w = N.array(self.res_w)
        self.res_p = N.array(self.res_p).reshape([-1, 1])
        
        
        res = (self.res_t, self.res_dx, self.res_x, self.res_u, 
                        self.res_w, self.res_p)

        self.collocator.export_result_dymola(self._result_file_name_complete, 
                                                result=res)

        complete_res = ResultDymolaTextual(self._result_file_name_complete)

        # Create and return result object
        self._result_object_complete = MPCAlgResult(self.op, 
                                self._result_file_name_complete, self.collocator,
                                complete_res, self.collocator_options,
                                self.times, self.nbr_samp, self.sample_period)
        return self._result_object_complete

    def _extract_results(self):
        """
        Extracts the results for the current timeframe from the result file.
        """
        self.result = self.collocator.get_result()
        if self.collocator._normalize_min_time:
            self._calculate_nbr_values_sample()

        t_opt = self.result[0][:self._nbr_values_sample]
        dx_opt = self.result[1][:self._nbr_values_sample][:]
        x_opt = self.result[2][:self._nbr_values_sample][:]
        u_opt = self.result[3][:self._nbr_values_sample][:]
        w_opt = self.result[4][:self._nbr_values_sample][:]
        p_opt = self.result[5]

        self.result_sample = (t_opt, dx_opt, x_opt, u_opt, w_opt, p_opt)

    def _append_to_result_file(self):
        """
        Appends the results from this optimizations first timeframe to the 
        complete results.
        """

        for i in range(self._start_index, len(self.result_sample[1])):
            self.res_t.append(self.result_sample[0][i])
            self.res_dx.append(self.result_sample[1][i])
            self.res_x.append(self.result_sample[2][i])
            self.res_u.append(self.result_sample[3][i])
            self.res_w.append(self.result_sample[4][i])
        self.res_p.append(self.result_sample[5])
        self._start_index = 1
        
    def _add_times(self):
        """
        Adds each samples times to the total times. Also keeps track of the 
        largest total time for one sample. 
        """
        self.times['update'] += self.time_update
        self.times['sol'] += self.time_sol

        time_post = time.clock() - self.t0_post
        self.time_tot = self.time_update + self.time_sol + time_post

        if  self.time_tot > self.times['maxTime']:
            self.times['maxTime'] = self.time_tot
            self.times['maxSample'] = self._sample_nbr

        self.times['tot'] += self.time_tot
        self.times['post_processing'] += time_post
        
    def get_results_this_sample(self, full_result=False):
        """
        Returns the results for the current sample. 
        
        Parameters::
            
            full_result --
            If True the complete resultfile from this sample is returned,
            (a LocalDAECollocationAlgResult-object).        
            If False the results from just this timeframe are extracted from
            the result-object and returned. Note: The returned data is not
            a LocalDAECollocationAlgResult-object.
            Default: False
        """

        if full_result:
            return self._result_object
        else:
            return self.result_sample

    def get_opt_input(self): 
        """
        Returns the optimal inputs for the current timeframe.
        """
        inputs = {}
        for inp in self.collocator.mvar_vectors['unelim_u']:
            inputs[inp.getName()] = self._result_object[inp.getName()][0]
            
        return inputs

    def _generate_measurements(self):   
        """
        Returns an estimated value of the next measurement, based on the result
        of the last optimization. 
        """
        measurements = {}   
        for name in self.state_names:
            name_init = "_start_"+name
            measurements[name_init] = self._result_object[name]\
                                [self._nbr_values_sample-1]*\
                                 N.random.normal(1.0, 0.01, 1)
        return measurements

    def _state_estimation(self, state_dict):
        """ 
        Returns an estimation of the states in the next sample based on the
        measurement of the states in this sample.
        
        Parameters::
            state_dict --
            A dictionary with the measurements for this sample.
        """
        return state_dict
         #Not yet supported
    def _calculate_nbr_values_sample(self):
        """
        Returns the number of values for each timeframe.
        """
        timepoints_sample = []
        i = 0
        if not self.collocator._normalize_min_time:
            timepoints = self.collocator.time
            time = timepoints[i]
            while time <= self.sample_period:
                timepoints_sample.append(time)
                i +=1
                time = timepoints[i]
            self._nbr_values_sample = len(timepoints_sample)
        else:
            time = self.result[0][i]
            while time <= self.sample_period:
                timepoints_sample.append(time)
                i +=1
                time = self.result[0][i]
            self._nbr_values_sample = len(timepoints_sample)
            
    def get_nbr_values_sample(self):
        return self._nbr_values_sample
