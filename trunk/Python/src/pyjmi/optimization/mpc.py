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
import modelicacasadi_wrapper as ci
import casadi

class MPC(object):

    """
    Creates an MPC-object which allows a dynamic optimization problem to be 
    updated with estimates of the states (through measurements).  
    """

    def __init__(self, op, options, sample_period, horizon, constr_viol_costs = {},
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
                
            constr_viol_costs --
                The constraint violation costs to use when automatically 
                softening variable bounds.
                Default: {}

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
        self.constr_viol_costs = constr_viol_costs

        # Create complete result lists
        self.res_t = []
        self.res_dx = []
        self.res_x = []
        self.res_u = []
        self.res_w = []
        self.res_p = []
        
        self.iterations = []
        self.return_status = []

        # Define some things
        self._sample_nbr = 0
        self._mpc_result_file_name = op.getIdentifier()+'_mpc_result.txt'
        self._start_index = 0
        self.test_warm_start = 0
        self.inittraj_set = False
        
        if noise_seed:
            N.random.seed([noise_seed])

        # Check if horizon_time equals finalTime
        if N.abs(op.get('finalTime')-op.get('startTime')-self.horizon_time) >\
                                                                        1e-6:
			self.op.set('finalTime', self.op.get('startTime')+\
                                                            self.horizon_time)
        
        # Soften variable bounds and add u0-parameters for blockingfactors 
        self.extra_param = []
        self.original_model_inputs = self.op.getVariables(self.op.REAL_INPUT)
        self._soften_constraints()
        self._add_u0()

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

    def _add_u0(self):
        """
        Adds neccessary variables to make blocking factors (du_quad_pen and 
        du_bounds) valid first sample.
        """
        bf = self.options['blocking_factors']
        if bf is not None:
            for key in bf.du_quad_pen.keys():
                var_par = casadi.MX.sym("%s_0" %key)
                var =  ci.RealVariable(self.op, var_par, 2, 1) 
                self.op.addVariable(var)
                self.op.set("%s_0" %key, 0)
                self.extra_param.append("%s_0" %key)
                
                # Find or create new timed variable
                var_startTime = self._getTimedVariable(key)
                
                if var_startTime is None:
                    var_startTime = casadi.MX.sym("%s(startTime)" %key)
                    st = self.op.getVariable('startTime').getVar()
                    variable = self.op.getVariable(key)
                    timedVar_startTime = ci.TimedVariable(self.op, var_startTime, variable, st)
                    self.op.addTimedVariable(timedVar_startTime)
                
                # Create new variable 
                du_quad_pen_par= casadi.MX.sym("%s_du_quad_pen" %key)
                du_quad_pen = ci.RealVariable(self.op, du_quad_pen_par, 2, 1)
                self.op.addVariable(du_quad_pen)
                self.op.set("%s_du_quad_pen" %key, 0)
                self.extra_param.append("%s_du_quad_pen" %key)
                
                extra_obj = du_quad_pen_par*(var_startTime-var_par)*(var_startTime-var_par)
                self.op.setObjective(self.op.getObjective() + extra_obj)
            
            # Save all pointconstraints
            pc = []
            for constr in self.op.getPointConstraints():
                pc.append(constr)
            
            for key in bf.du_bounds.keys():
                
                # Find or create new _0 parameter
                var_par = self.op.getVariable("%s_0" %key)
                if var_par is None:
                    var_par = casadi.MX.sym("%s_0" %key)
                    var =  ci.RealVariable(self.op, var_par, 2, 1) 
                    self.op.addVariable(var)
                    self.op.set("%s_0" %key, 0)
                    self.extra_param.append("%s_0" %key)
                else:
                    var_par = var_par.getVar()
                
                # Find or create new timed variable
                var_startTime = self._getTimedVariable(key)
                
                if var_startTime is None:
                    var_startTime = casadi.MX.sym("%s(startTime)" %key)
                    st = self.op.getVariable('startTime').getVar()
                    variable = self.op.getVariable(key)
                    timedVar_startTime = ci.TimedVariable(self.op, var_startTime, variable, st)
                    self.op.addTimedVariable(timedVar_startTime)
                
                # Create new parameter for pointconstraint bound
                du_bounds_par= casadi.MX.sym("%s_du_bounds" %key)
                du_bounds = ci.RealVariable(self.op, du_bounds_par, 2, 1)
                self.op.addVariable(du_bounds)
                self.op.set("%s_du_bounds" %key, 1e50) #BLEV LEDSEN MED INF
                self.extra_param.append("%s_du_bounds" %key)

                # Create new pointconstraints
                bf_constr = var_startTime - var_par
                poc1 = ci.Constraint(bf_constr, du_bounds_par, 1)
                poc2 = ci.Constraint(bf_constr, -du_bounds_par, 2)
                    
                # Append new pointconstraints to list    
                pc.append(poc1)
                pc.append(poc2)
                
            # Set new pointconstraints
            self.op.setPointConstraints(pc)
            
    def _getTimedVariable(self, name):
        """
        Returns the startTime timed variable for variable name if there is one,
        otherwise returns None.
        
        Parameters::

            name --
                The name of the variable whose startTime timed variable we're
                looking for.
        """
        tv = self.op.getTimedVariables()
        for var in tv:
            if var.getBaseVariable() == self.op.getVariable(name):
                if var.getTimePoint() == self.op.getVariable('startTime').getVar():
                    return var.getVar()
        return None

    def _soften_constraints(self):
        """
        Changes hard variable bounds to soft constraints for all variables for
        which the user provided a constraint violation cost when creating the
        MPC object.
        
        The softened constraint is accieved by adding a cost to the objective
        integrand corresponding to the constraint violation cost * the 1-norm 
        for each variable. 
         
        """
        # Save pathconstraints
        path_constr = []
        for constr in self.op.getPathConstraints():
            path_constr.append(constr)

        # Change bounds on variables to soft constraints 
        for name in self.constr_viol_costs.keys():
            var = self.op.getVariable(name)
            
            # Create slack variable
            slack_var= casadi.MX.sym("%s_slack" %name)
            slack = ci.RealVariable(self.op, slack_var, 0, 3) 
            slack.setMin(0)
            slack.setNominal(1e-2)
            self.op.addVariable(slack)
            
            # Add to Objective Integrand 
            oi = self.op.getObjectiveIntegrand()
            self.op.setObjectiveIntegrand(oi+self.constr_viol_costs[name]*slack_var)
            
            var_min = self.op.get_attr(var, "min")
            var_max = self.op.get_attr(var, "max")
            
            # Change bounds
            if var_min != -N.inf:
                var.setMin(-N.inf)
                pac_rh = var_min - slack_var
                pac_soft = ci.Constraint(var.getVar(), pac_rh, 2)
                path_constr.append(pac_soft) 
            if var_max != N.inf:
                var.setMax(N.inf)
                pac_rh = var_max + slack_var
                pac_soft = ci.Constraint(var.getVar(), pac_rh, 1)
                path_constr.append(pac_soft) 

        self.op.setPathConstraints(path_constr)   
                
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
            bl_list = [bf_value]*self.horizon
            factors = {}
            for inp in self.original_model_inputs:
                factors[inp.getName()] = bl_list
            bf = BlockingFactors(factors = factors)
            self.options['blocking_factors'] = bf
        else:
            factors = self.options['blocking_factors'].factors
            for inp in [var for var in self.original_model_inputs if not
                        factors.has_key(var.getName())]:
                n_e = self.options['n_e']
                bf_value = n_e/self.horizon
                bl_list = [bf_value]*self.horizon
                factors[inp.getName()] = bl_list
            du_bounds = self.options['blocking_factors'].du_bounds
            du_quad_pen = self.options['blocking_factors'].du_quad_pen
            bf = BlockingFactors(factors, du_bounds, du_quad_pen)
            self.options['blocking_factors'] = bf

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
                
        # Find and save the index for blocking factor parameters
        for par in self.extra_param:
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
            self.collocator.solver_object.setOption('expand', False)
            if self.options['IPOPT_options'].get('warm_start_init_point')\
                                                                    is None:
                self.collocator.solver_object.\
                                    setOption('warm_start_init_point', 'yes')
            if self.options['IPOPT_options'].get('mu_init') is None:
                self.collocator.solver_object.setOption('mu_init', 1e-4)
            if self.options['IPOPT_options'].get('print_level') is None:
                self.collocator.solver_object.setOption('print_level', 0)
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


        self.collocator._create_initial_trajectories()        

        self.collocator._compute_bounds_and_init()


    def _extract_results(self):
        """
        Extracts the results for the current sample_period from the result file.
        """

        if self.status == 'Solve_Succeeded' or self.status == 'Solved_To_Acceptable_Level':
            start_val = 0
            stop_val = self._nbr_values_sample
        else:
            start_val = self.consec_fails*(self._nbr_values_sample-1)
            stop_val = (self.consec_fails+1)*self._nbr_values_sample-self.consec_fails
   
        t_opt = self.result[0][start_val:stop_val]
        dx_opt = self.result[1][start_val:stop_val][:]
        x_opt = self.result[2][start_val:stop_val][:]
        u_opt = self.result[3][start_val:stop_val][:]
        w_opt = self.result[4][start_val:stop_val][:]
        p_opt = self.result[5]
        
        self.result_sample = (t_opt, dx_opt, x_opt, u_opt, w_opt, p_opt)

    def _append_to_result_file(self):
        """
        Appends the results from this samples first sample_period to the 
        complete results.
        """
        for i in range(len(self.result_sample[1])):
            self.res_t.append(self.result_sample[0][i])
            self.res_dx.append(self.result_sample[1][i])
            self.res_x.append(self.result_sample[2][i])
            self.res_u.append(self.result_sample[3][i])
            self.res_w.append(self.result_sample[4][i])
        self.res_p.append(self.result_sample[5])


    def _add_times(self):
        """
        Adds each samples times to the total times. Also keeps track of the 
        largest total time for one sample. 
        """
        sol_time = self.alg.times['sol']
        update_time = self.alg.times['init']
        if self.status == 'Solve_Succeeded' or self.status == 'Solved_To_Acceptable_Level':
            post_time = self.alg.times['post_processing']
        else:
            post_time = 0
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
        self._opt_input = {}

        for inp in self.original_model_inputs:
            names.append(inp.getName())
            inputs.append(self._result_object[inp.getName()][(self._nbr_values_sample-1)*self.consec_fails+1])
            self._opt_input[inp.getName()] = self._result_object[inp.getName()][(self._nbr_values_sample-1)*self.consec_fails+1]
        def input_function(t):
            return N.array(inputs)

        return (names,input_function)

    def _extract_estimates_prev_opt(self):   
        """
        Returns an estimated value of the states, based on the result
        of the previous optimization. 
        """
        mean = 0
        st_dev = 0.005
        measurements = {} 
        if self._sample_nbr == 1:
            return measurements
        else:
            for name in self.state_names:
                name_init = "_start_"+name
                measurements[name_init] = self._result_object[name]\
                                    [self._nbr_values_sample-1]
                val = N.abs(measurements[name_init])
                measurements[name_init] += N.random.normal(mean, st_dev*val, 1)

        return measurements

    def _shift_xx(self):
        """
        Shifts the result from the previous optimation and gives it as initial 
        guess for the next optimation.
        """
        xx_result = {}
        if self.status == 'Solve_Succeeded' or self.status == 'Solved_To_Acceptable_Level': 
            xx_result['prim'] = self.collocator.primal_opt
            xx_result['dual'] = self.collocator.dual_opt2
        else:
            xx_result['prim'] = self.shifted_xx['prim']
            xx_result['dual'] = self.shifted_xx['dual']

        #~ xx_result['prim'] = self.collocator.named_xx  #Used for debugging 

        # Map with splited order
        split_map = dict()
        split_map['x'] = 0
        split_map['dx'] = 1
        split_map['w'] = 2
        split_map['unelim_u'] = 3

        # Fetch split indices and collocation options
        gsi = self.collocator.global_split_indices
        n_e = self.options['n_e']
        n_cp = self.options['n_cp']

        # Create map for the shifted results
        shifted_xx = {}
        shifted_xx['prim'] = xx_result['prim'][0:0]
        shifted_xx['dual'] = xx_result['dual'][0:0]
        is_x = 1

        # Shift x, dx and w
        for vk in ['x', 'dx', 'w']:
            start=gsi[split_map[vk]]
            end = gsi[split_map[vk]+1]

            n_var = self.collocator.n_var[vk]

            for var in ['prim', 'dual']:
                new_xx = xx_result[var][start+n_var*(n_cp+is_x):end]
                new_xx_extrapolate = xx_result[var][end-n_var:end]
                shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx))

                for i in range(n_cp+is_x):
                    shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx_extrapolate))
            is_x = 0

        # Shift inputs without blocking factors
        n_cont_u = len(self.constr_viol_costs.keys())    #ALL OTHER INPUTS SHOULD HAVE BF
        start_cont_u=gsi[split_map['unelim_u']]
        end_cont_u = start_cont_u + n_cont_u*n_cp*n_e

        for var in ['prim', 'dual']:
            new_xx = xx_result[var][start_cont_u+n_cont_u*n_cp:end_cont_u]
            new_xx_extrapolate = xx_result[var][end_cont_u-n_cont_u:end_cont_u]
            shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx))

            for i in range(n_cp):
                shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx_extrapolate))

        # Shift inputs with blocking factors 
        n_bf_u = self.collocator.n_var['unelim_u'] - n_cont_u
        start_bf_u = end_cont_u

        for name in self.options['blocking_factors'].factors.keys():
            factors = self.options['blocking_factors'].factors[name]

            end_bf_u = start_bf_u + len(factors)

            for var in ['prim', 'dual']:
                new_xx = xx_result[var][start_bf_u+n_bf_u:end_bf_u]
                new_xx_extrapolate = xx_result[var][end_bf_u-n_bf_u:end_bf_u]

                # DO SOMETHING SMARTER?
                shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx))
                shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx_extrapolate))
            start_bf_u = end_bf_u

        # Shift initial controls (without blocking factors)
        start_init_u = gsi[split_map['unelim_u']] + (n_cp-1)*n_cont_u
        end_init_u = start_init_u + n_cont_u

        for var in ['prim', 'dual']:
            new_xx = xx_result[var][start_init_u:end_init_u]
            shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx))

        # Shift initial dx, w
        for vk in ['dx', 'w']:
            n_var = self.collocator.n_var[vk]

            start=gsi[split_map[vk]] + (n_cp-1)*n_var
            end = start+n_var

            for var in ['prim', 'dual']:
                new_xx = xx_result[var][start:end]
                shifted_xx[var] = N.concatenate((shifted_xx[var], new_xx))
                
        # Save the shifted result in the collocator
        self.collocator.dual_opt2 = shifted_xx['dual']
        self.collocator.xx_init = shifted_xx['prim']

        self.shifted_xx = shifted_xx

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
    
            coll_time = self.collocator._compute_time_points()
            self.collocator.time = N.array(coll_time)
    
            for key in [var for var in self.extra_param if var.endswith('_0')]:
                self.collocator._par_vals[self.index[key]] = self._opt_input[key.split('_0')[0]]

    def sample(self):
        """
        Redefines the initial trajectories (for all but the first sample) and 
        solves the NLP. 
        Warm start is initiated the second time sample is called.  
        """
        
        
        if self._sample_nbr > 2:
            if not self.inittraj_set:
                #~ self.set_inittraj(self._result_object)
                self._shift_xx()

        elif self._sample_nbr == 2:          # Initiate the warm start
            self.collocator.warm_start = True
            self._set_warm_start_options()
            if not self.inittraj_set:
                #~ self.set_inittraj(self._result_object)
                self._shift_xx()
            self.collocator._init_and_set_solver_inputs()
            
            # Change w from blocking factors
            for key in [var for var in self.extra_param if var.endswith('_du_quad_pen')]:
                self.collocator._par_vals[self.index[key]] = self.options['blocking_factors'].du_quad_pen[key.split('_du_quad_pen')[0]]
                
            for key in [var for var in self.extra_param if var.endswith('_du_bounds')]:
                self.collocator._par_vals[self.index[key]] = self.options['blocking_factors'].du_bounds[key.split('_du_bounds')[0]]
     
        # Solve the NLP
        self.alg.solve()
        
        self.status = self.collocator.solver_object.getStat('return_status')
        # Get the results and extract the results for this sample
        if self.status == 'Solve_Succeeded' or self.status == 'Solved_To_Acceptable_Level': 
            self._result_object = self.alg.get_result()
            self.result = self.collocator.get_result()
            self.consec_fails = 0
        else:
            self.consec_fails += 1
            if self.consec_fails >= self.options['n_e']:
                pass
                #THROW SOMETHING CAUSE THIS AINT WORKING!
        
        self.t0_post = time.clock()

        self.iterations.append(self.collocator.solver_object.getStat('iter_count'))
        self.return_status.append(self.status)
        
        self._extract_results()
        self._append_to_result_file()
        self.inittraj_set = False
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
            val = N.abs(states["_start_"+name])
            random = N.random.normal(mean, st_dev*val, 1)
            states["_start_"+name] += random

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
        
    def set_inittraj(self, sim_result): 
        """ 
        Sets the initial trajectories for the next optimization.
        
        Parameters::
            
            sim_result --
                The result file from which the initial trajectories are to be
                extracted.
        """
        self.collocator.init_traj = sim_result
        try:
            self.collocator.init_traj = self.collocator.init_traj.result_data
        except AttributeError:
            pass

        self.collocator._create_initial_trajectories()        
        self.collocator._compute_bounds_and_init()

        self.inittraj_set = True

    def set(self, names, values):
        """
        Sets the specified parameters in names to the value in values.
        
        Parameters::
            
            names --
                List of parameter names whose values are to be changed. 
                
                Type: [string] or string
                
            values --
                Corresponding new values for the parameters.
                
                Type: [float] or float
        """
        
        if isinstance(names, list):
            for name in names:   
                index = self.collocator.var_indices[name]
                self.collocator._par_vals[index] = values.pop(0)
        else:
            index = self.collocator.var_indices[names]
            self.collocator._par_vals[index] = values

    def print_solver_stats(self):
        """ 
        Prints the return status and number of iterations for each for each 
        optimization.
        """
        for i, stat in enumerate(self.return_status): 
            print("%s: %s: %s iterations" %(i+1, stat,self.iterations[i]))
