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
import time, types
import numpy as N

class MPC(object):

    """
    Creates an MPC-object which allows a dynamic optimization problem to be 
    updated with estimates of the states (through measurements).  
    """

    def __init__(self, op, options, sample_period, horizon, 
                 noise_seed=None):
        """
        Creates the NLP that corresponds to the op we want to solve with MPC.

        Parameters::

            op --
                The optimization problem we want to solve.

            options --
                The collocation options we want to use while solving.

            sample_period --
                The sample period i.e. the time between each optimization.

            horizon --
                The number of samples on the horizon. This is used to define
                the horizon_time. 

            noise_seed --
                The seed to use for adding noise.
                Default: None
        """

        self._create_clock()
        self.op = op
        self.options = options
        self.sample_period = sample_period
        self.horizon = horizon
        self.horizon_time = horizon*sample_period   

        # Create complete result lists
        self.res_t = []
        self.res_dx = []
        self.res_x = []
        self.res_u = []
        self.res_w = []
        self.res_p = []

        # Define some things
        self._sample_nbr = 0
        self._mpc_result_file_name = op.getIdentifier()+'_mpc_result.txt'
        self._start_index = 0
        self.test_warm_start = 0
        
        if noise_seed:
            N.random.seed([noise_seed])

        # Check if horizon_time equals finalTime
        if N.abs(op.get('finalTime')-op.get('startTime')-self.horizon_time) >\
                                                                        1e-6:
			self.op.set('finalTime', self.op.get('startTime')+\
                                                            self.horizon_time)

        # Transcribe the DOP to a nlp
        self._create_nlp_object()

        # Save the initialization time
        self.times['init'] = time.clock() - self._startTime
        self.times['tot'] += self.times['init']
        self.t0_update = time.clock()

    def _create_clock(self):
        """
        Creates a dictionary where times for different operations are stored.
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
        self.alg = LocalDAECollocationAlg(self.op, self.options)
        self.collocator = self.alg.nlp
        self._get_states_and_initial_value_parameters()

    def _set_blocking_options(self):
        """
        Creates blocking factors for the input. Default blocking factors are:
        Constant input through each sample.
        """
 
        if self.options['blocking_factors'] is None:
            n_e = self.options['n_e']
            bf_value = n_e/self.horizon
            bl_list = [bf_value]*(n_e/bf_value)
            inputs = self.op.getVariables(self.op.REAL_INPUT)
            factors = {}
            for i in range(len(inputs)):
                name = inputs[i].getName()
                factors[name] = bl_list
            bf = BlockingFactors(factors = factors)
            self.options['blocking_factors'] = bf
        else: 
            bl_factors = self.options['blocking_factors'].factors
            keys = bl_factors.keys()
            key = keys[0]
            for key2 in keys:
                if bl_factors[key] != bl_factors[key2]:
                    raise Exception("MPC does not support inputs with" +
                                    "different blocking factors")

        self._nbr_values_sample = self.options['n_e']/self.horizon*\
                                  self.options['n_cp']+1

    def _get_states_and_initial_value_parameters(self):
        """
        Saves the indices in the collocators _par_vals vector for the initial 
        values of the measured states + start and final times.
        """

        # Retrieve the names of all the states 
        self.state_names = self.op.get_state_names()

        # Find and save the indices for each states initial value + startTime 
        # and finalTime. 
        self.index = {}    
        for name in self.state_names:
            name_init = "_start_"+name
            self.index[name_init] = self.collocator.var_indices[name_init]

        for par in ['startTime', 'finalTime']:
                self.index[par] = self.collocator.var_indices[par]

    def _set_warm_start_options(self):
        """
        Sets the warm start options for Ipopt if they have not already been set
        by the user. 
        
        Default warm start options are:
            'warm_start_init_point' = 'yes'
            'mu_init' = 1e-4
            'print_level' = 0
        """  

        if self.options['solver'] is 'IPOPT':
            self.options['expand_to_sx'] = 'no'
            if self.options['IPOPT_options'].get('warm_start_init_point')\
                                                                    is None:
                self.collocator.solver_object.\
                                    setOption('warm_start_init_point', 'yes')
            if self.options['IPOPT_options'].get('mu_init') is None:
                self.collocator.solver_object.setOption('mu_init', 1e-4)
            if self.options['IPOPT_options'].get('print_level') is None:
                self.collocator.solver_object.setOption('print_level', 0)
            
            
            if self.test_warm_start:
                push = self.push
                self.collocator.solver_object.setOption('warm_start_bound_push', push)
                self.collocator.solver_object.setOption('warm_start_mult_bound_push', push)
                self.collocator.solver_object.setOption('warm_start_bound_frac', push)
                self.collocator.solver_object.setOption('warm_start_slack_bound_frac', push)
                self.collocator.solver_object.setOption('warm_start_slack_bound_push', push)
                self.collocator.solver_object.setOption('print_level', 3)
        else:

            self.collocator.solver_object.setOption('NLPprint', 0)
            self.collocator.solver_object.setOption('InitialLMest', False)

            
    def _create_state_dict(self, sim_res):
        """
        Extracts the last value from the simulation result object and puts them
        in a dictionary.
        
        Parameters::
            
            sim_res --
                The simulation result object from which the states are to be 
                extracted. 
        """

        states = {}   
        for name in self.state_names:
            states["_start_"+name] = sim_res[name][-1]
        return states

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

        time = self.collocator._compute_time_points()
        self.collocator._create_initial_trajectories()        
        self.collocator.time = N.array(time)
        self.collocator._compute_bounds_and_init()

    def _extract_results(self):
        """
        Extracts the results for the current sample_period from the result file.
        """
        self.result = self.collocator.get_result()

        t_opt = self.result[0][:self._nbr_values_sample]
        dx_opt = self.result[1][:self._nbr_values_sample][:]
        x_opt = self.result[2][:self._nbr_values_sample][:]
        u_opt = self.result[3][:self._nbr_values_sample][:]
        w_opt = self.result[4][:self._nbr_values_sample][:]
        p_opt = self.result[5]
        self.result_sample = (t_opt, dx_opt, x_opt, u_opt, w_opt, p_opt)

    def _append_to_result_file(self):
        """
        Appends the results from this samples first sample_period to the 
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

        sol_time = self.alg.times['sol']
        update_time = self.alg.times['init']
        post_time = self.alg.times['post_processing']
        self.times['update'] += update_time
        self.times['sol'] += sol_time

        time_post = time.clock() - self.t0_post + post_time
        self.time_tot = update_time + sol_time + time_post

        if  self.time_tot > self.times['maxTime']:
            self.times['maxTime'] = self.time_tot
            self.times['maxSample'] = self._sample_nbr

        self.times['tot'] += self.time_tot
        self.times['post_processing'] += time_post

    def _get_opt_input(self):
        """
        Returns the optimal inputs for the current sample_period.
        """

        names = []
        inputs =[]

        for inp in self.collocator.mvar_vectors['unelim_u']:
            names.append(inp.getName())
            inputs.append(self._result_object[inp.getName()][0])

        def input_function(t):
            return N.array(inputs)

        return (names,input_function)

    def _extract_estimates_prev_opt(self):   
        """
        Returns an estimated value of the states, based on the result
        of the previous optimization. 
        """

        measurements = {} 
        if self._sample_nbr == 1:
            return measurements
        else:
            for name in self.state_names:
                name_init = "_start_"+name
                measurements[name_init] = self._result_object[name]\
                                    [self._nbr_values_sample-1]
        return measurements

    def update_state(self, sim_res=None):
        """ 
        Updates the initial value for the next sample based on the estimates in
        state_dict which is defined based on sim_res. 
        Moves the optimization time one sample_period forward.

        Parameters::

            sim_res --
                Either a dictionary containing the estimates of the states in 
                this sample or a simulation result object from which estimates
                of the states are extracted.  
                If None estimates of the states will be extracted automatically 
                from the previous optimization result.
                Default: None 
        """  

        # Update times and sample number
        self.alg._t0 = time.clock()
        self._sample_nbr+=1

        # Check the type of sim_res and do accordingly
        if isinstance(sim_res, dict):
            state_dict = sim_res
        elif sim_res == None:
            state_dict = self._extract_estimates_prev_opt()
        else:
            state_dict = self._create_state_dict(sim_res)

        # Updates states
        for key in state_dict.keys():
            if not self.index.has_key(key):
                raise Exception("You are not allowed to change %s" %key)
            else:
                self.collocator._par_vals[self.index[key]] = state_dict[key]

        # Update times
        if self._sample_nbr > 1:
            self.collocator._par_vals[self.index['startTime']] +=\
                                                        self.sample_period
            self.collocator._par_vals[self.index['finalTime']] +=\
                                                        self.sample_period
            self.collocator.t0 += self.sample_period
            self.collocator.tf += self.sample_period

    def sample(self):
        """
        Redefines the initial trajectories (for all but the first sample) and 
        solves the NLP. 
        Warm start is initiated the second time sample is called.  
        """

        if self._sample_nbr > 2:
            self._redefine_initial_trajectories()
        elif self._sample_nbr == 2:          # Initiate the warm start
            self.collocator.warm_start = True
            self._set_warm_start_options()
            self._redefine_initial_trajectories()
            self.collocator._init_and_set_solver_inputs()

        # Solve the NLP
        self.alg.solve()
        
        # Get the results and extract the results for this sample
        self._result_object = self.alg.get_result()
        self.t0_post = time.clock()

        self._extract_results()
        self._append_to_result_file()
        self._add_times()
        return self._get_opt_input()

    def extract_states_add_noise(self, sim_res, mean=0, st_dev=0.005):
        """
		Extracts the last value of the states from a simulation result object 
        and adds a noise with mean and variance as defined.

        Parameters::

            sim_res --
                The simulation result object from which the states are to be 
                extracted. 

            mean --
                Mean value of the noise.
                Default: 0

            st_dev --
                Factor to be multiplied with the nominal value of each state to
                define the stanard deviation of the noise.
                Default: 0.005
		"""

        states = {}
        for name in self.state_names:
            states["_start_"+name] = sim_res[name][-1]
            val = self.op.get_attr(self.op.getVariable(name), "nominal")
            states["_start_"+name] += N.random.normal(mean, st_dev*val, 1)

        return states

    def get_results_this_sample(self, full_result=False):
        """
        Returns the results for the current sample. 
        
        Parameters::
            
            full_result --
                If True the complete resultfile from this sample is returned,
                (a LocalDAECollocationAlgResult-object).        
                If False the results from just this sample are extracted from
                the result-object and returned. Note: The returned data is not
                a LocalDAECollocationAlgResult-object.
                Default: False
        """

        if full_result:
            return self._result_object
        else:
            return self.result_sample

    def get_complete_results(self):
        """
        Creates and returns the patched together resultfile from all 
        optimizations.
        """

        # Convert the complete restults lists to arrays
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

        self.collocator.export_result_dymola(self._mpc_result_file_name, 
                                                result=res)

        complete_res = ResultDymolaTextual(self._mpc_result_file_name)

        # Create and return result object
        self._result_object_complete = MPCAlgResult(self.op, 
                                self._mpc_result_file_name, self.collocator,
                                complete_res, self.options,
                                self.times, self._sample_nbr,
                                self.sample_period)

        return self._result_object_complete
        
    def def_warm_start(self, push):
        self.test_warm_start = True
        self.push = push
