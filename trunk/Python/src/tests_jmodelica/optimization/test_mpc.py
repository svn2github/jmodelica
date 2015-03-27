#~ #!/usr/bin/env python 
#~ # -*- coding: utf-8 -*-
#~ 
#~ # Copyright (C) 2014 Modelon AB
#~ #
#~ # This program is free software: you can redistribute it and/or modify
#~ # it under the terms of the GNU General Public License as published by
#~ # the Free Software Foundation, version 3 of the License.
#~ #
#~ # This program is distributed in the hope that it will be useful,
#~ # but WITHOUT ANY WARRANTY; without even the implied warranty of
#~ # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#~ # GNU General Public License for more details.
#~ #
#~ # You should have received a copy of the GNU General Public License
#~ # along with this program. If not, see <http://www.gnu.org/licenses/>.
#~ 
#~ """Tests the mpc module."""
#~ 
#~ import os
#~ import nose
#~ 
#~ from collections import OrderedDict
#~ import numpy as N
#~ from scipy.io.matlab.mio import loadmat
#~ 
#~ from pyjmi.optimization.mpc import MPC
#~ from pyjmi.optimization.casadi_collocation import BlockingFactors
#~ 
#~ from tests_jmodelica import testattr, get_files_path
#~ from pyjmi.common.io import ResultDymolaTextual
#~ from pymodelica import compile_fmu
#~ from pyfmi import load_fmu
#~ from IPython.core.debugger import Tracer; dh = Tracer()
#~ 
#~ try:
    #~ from pyjmi import transfer_to_casadi_interface
    #~ from pyjmi.optimization.casadi_collocation import *
    #~ import casadi
#~ except (NameError, ImportError):
    #~ pass
#~ 
#~ from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError
#~ #Check to see if pyfmi is installed so that we also catch the error generated
#~ #from that package
#~ try:
    #~ from pyfmi.common.io import VariableNotFoundError as fmiVariableNotFoundError
    #~ VariableNotFoundError = (jmiVariableNotFoundError, fmiVariableNotFoundError)
#~ except ImportError:
    #~ VariableNotFoundError = jmiVariableNotFoundError
#~ 
#~ path_to_mos = os.path.join(get_files_path(), 'Modelica')
#~ path_to_data = os.path.join(get_files_path(), 'Data')
#~ 
#~ def assert_results(res, input_name, u_norm_ref, u_norm_rtol=1e-4):
    #~ """Helper function for asserting optimization results."""
    #~ u = res[input_name]
    #~ u_norm = N.linalg.norm(u) / N.sqrt(len(u))
    #~ N.testing.assert_allclose(u_norm, u_norm_ref, u_norm_rtol)
#~ 
#~ class TestMPCClass(object):
    #~ """
    #~ Tests pyjmi.optimization.mpc.
    #~ """
    #~ @classmethod
    #~ def setUpClass(self):
        #~ """Compile the test models."""
        #~ self.cstr_file_path = os.path.join(get_files_path(), 'Modelica', 
                                                                    #~ 'CSTR.mop')
#~ 
        #~ self.c_0_A = 956.271352
        #~ self.T_0_A = 250.051971
        #~ 
        #~ self.algorithm = "LocalDAECollocationAlg"
          #~ 
    #~ def optimize_options(self, op, alg=None):
        #~ if alg is None:
            #~ return op.optimize_options()
        #~ else:
            #~ return op.optimize_options(alg)
#~ 
    #~ @testattr(casadi = True)
    #~ def test_auto_bl_factors(self):
        #~ """
        #~ Test blocking factors generated in the mpc-class.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon)
#~ 
        #~ bf = [1]*horizon
        #~ bf_auto = MPC_object.options['blocking_factors'].factors['Tc']
        #~ 
        #~ # Assert that bf and bf_auto are equal
        #~ N.testing.assert_array_equal(bf, bf_auto)
        #~ 
        #~ ##RUN OPTIMATION##
        #~ 
    #~ @testattr(casadi = True)
    #~ def test_du_quad_pen(self):
        #~ """
        #~ Test with blocking_factor du_quad_pen.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ op.set('_start_c', float(self.c_0_A))
        #~ op.set('_start_T', float(self.T_0_A))
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0  
        #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ 
        #~ # Define blocking factors
        #~ bl_list = [1]*horizon
        #~ factors = {'Tc': bl_list}
        #~ du_quad_pen = {'Tc': 50}
        #~ bf = BlockingFactors(factors = factors, du_quad_pen=du_quad_pen)
        #~ opt_opts['blocking_factors'] = bf
        #~ 
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, noise_seed=seed,
                            #~ initial_guess='trajectory')
        #~ 
        #~ # Find timed variable Tc(startTime)
        #~ timed = op.getTimedVariables()
        #~ for var in timed:
            #~ if var.getBaseVariable().getName() == 'Tc':
                    #~ timed_name = var.getName()
                    #~ 
                    #~ 
        #~ # Assert that the correct term has been added to the objective            
        #~ obj = op.getObjective()   
        #~ obj_string = obj.getRepresentation()    
        #~ find = obj_string.find('(Tc_du_quad_pen*(%s-Tc_0))*(%s-Tc_0)' 
                            #~ %(timed_name, timed_name))
        #~ N.testing.assert_(find != -1)
        #~ N.testing.assert_allclose(op.get('Tc_du_quad_pen'), 0.0)
        #~ 
        #~ MPC_object.update_state()
        #~ u_k1 = MPC_object.sample()
        #~ MPC_object.update_state()
        #~ 
        #~ #Assert that Tc_0 equals u_k1
        #~ Tc_0 = MPC_object.collocator._par_vals[MPC_object.index['Tc_0']] 
        #~ N.testing.assert_equal(Tc_0, u_k1[1](0)[0])
        #~ 
        #~ # Assert that Tc_du_quad_pen is changed at start of second sample
        #~ u_k2 = MPC_object.sample()
        #~ dqp =\
            #~ MPC_object.collocator._par_vals[MPC_object.index['Tc_du_quad_pen']] 
        #~ N.testing.assert_equal(dqp, du_quad_pen['Tc'])
        #~ 
        #~ ##RUN OPTIMIZATION##
        
    #~ @testattr(casadi = True)
    #~ def test_du_bounds(self):
        #~ """
        #~ Test with blocking_factor du_bounds.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ op.set('_start_c', float(self.c_0_A))
        #~ op.set('_start_T', float(self.T_0_A))
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ 
        #~ # Define blocking factors
        #~ bl_list = [1]*horizon
        #~ factors = {'Tc': bl_list}
        #~ du_bounds = {'Tc': 50}
        #~ bf = BlockingFactors(factors = factors, du_bounds=du_bounds)
        #~ opt_opts['blocking_factors'] = bf
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, noise_seed=seed,
                            #~ initial_guess='trajectory')
        #~ 
        #~ # Find timed variable Tc(startTime)
        #~ timed = op.getTimedVariables()
        #~ for var in timed:
            #~ if var.getBaseVariable().getName() == 'Tc':
                    #~ timed_name = var.getName()
                    #~ 
        #~ # Assert that the correct point constraints have been added         
        #~ pc = op.getPointConstraints()   
        #~ upper_found = False
        #~ lower_found = False
        #~ for constr in pc:
            #~ dh()
            #~ if constr.getResidual().getRepresentation() == \
                                #~ ("MX(((%s-Tc_0)-Tc_du_bounds))" %timed_name):
                #~ upper_found = True
            #~ elif constr.getResidual().getRepresentation() == \
                                #~ ("MX(((%s-Tc_0)+Tc_du_bounds))" %timed_name):
                #~ lower_found = True
        #~ 
        #~ N.testing.assert_(upper_found)
        #~ N.testing.assert_(lower_found)
        #~ 
        #~ MPC_object.update_state()
        #~ u_k1 = MPC_object.sample()
        #~ MPC_object.update_state()
        #~ 
        #~ #Assert that Tc_0 equals u_k1
        #~ Tc_0 = MPC_object.collocator._par_vals[MPC_object.index['Tc_0']] 
        #~ N.testing.assert_equal(Tc_0, u_k1[1](0)[0])
        #~ 
        #~ # Assert that Tc_du_bound is changed at start of second sample
        #~ u_k2 = MPC_object.sample()
        #~ db = MPC_object.collocator._par_vals[MPC_object.index['Tc_du_bounds']] 
        #~ N.testing.assert_equal(db, du_bounds['Tc'])
        #~ 
        #~ ##RUN OPTIMATION##
#~ 
    #~ @testattr(casadi = True)
    #~ def test_softening_bounds(self):
        #~ """
        #~ Test the automatic softening of hard variable bounds.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ 
        #~ # Define blocking factors
        #~ bl_list = [1]*horizon
        #~ factors = {'Tc': bl_list}
        #~ bf = BlockingFactors(factors = factors)
        #~ opt_opts['blocking_factors'] = bf
        #~ opt_opts['IPOPT_options']['print_level'] = 0
        #~ 
        #~ cvc = {'T': 1e6}
        #~ originalPathConstraints = op.getPathConstraints()
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                        #~ constr_viol_costs=cvc, noise_seed=seed)
#~ 
        #~ # Assert that an optimization with an initial value outside of bounds
        #~ # succeeds
        #~ MPC_object.update_state({'_start_c': self.c_0_A, '_start_T': 355})
        #~ MPC_object.sample()
        #~ N.testing.assert_('Solve_Succeeded', MPC_object.collocator.
                                        #~ solver_object.getStat('return_status'))
#~ 
    #~ @testattr(casadi = True)
    #~ def test_shift_xx(self):
        #~ """
        #~ Test that the result from the shift operation equals the result from
        #~ extracting initial trajectories from a result file. 
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC_Parameter", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ op.set('_start_c', float(self.c_0_A))
        #~ op.set('_start_T', float(self.T_0_A))
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ 
        #~ # CreateMPC-object and do an optimization
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, noise_seed=seed, 
                        #~ initial_guess='trajectory')
        #~ 
        #~ MPC_object.update_state()
        #~ u_k1 = MPC_object.sample()
        #~ result = MPC_object.get_results_this_sample()
#~ 
        #~ MPC_object.update_state()
        #~ u_k2 = MPC_object.sample()
        #~ MPC_object.set_inittraj(result)
#~ 
        #~ # Assert that the shifted result equals the result from result
        #~ N.testing.assert_array_almost_equal(MPC_object.shifted_xx, 
                                            #~ MPC_object.collocator.xx_init)
#~ 
    #~ @testattr(casadi = True)
    #~ def test_infeasible_return_input(self):
        #~ """
        #~ Test that the input returned from an unsuccessful optimization is the 
        #~ next input in the last successful optimization.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ cvc = {'T': 1e6}
        #~ 
        #~ # Define blocking factors
        #~ bl_list = [1]*horizon
        #~ factors = {'Tc': bl_list}
        #~ bf = BlockingFactors(factors = factors)
        #~ opt_opts['blocking_factors'] = bf
                #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                        #~ constr_viol_costs = cvc, noise_seed=seed, 
                        #~ create_comp_result=False)
#~ 
        #~ MPC_object.update_state({'_start_c': 587.47543496, 
                                    #~ '_start_T': 345.64619542})
        #~ u_k1 = MPC_object.sample()
        #~ result1 = MPC_object.get_results_this_sample(full_result=True)
        #~ 
        #~ # Optimize with infeasible problem
        #~ MPC_object.update_state({'_start_c': 900, '_start_T': 400})
        #~ u_k2= MPC_object.sample()
#~ 
        #~ # Assert that problem was infeasible and that the returned input is
        #~ # the next input from the last succesful optimization
        #~ N.testing.assert_('Infeasible_Problem_Detected', MPC_object.collocator.
                                        #~ solver_object.getStat('return_status'))
        #~ N.testing.assert_equal(u_k2[1](0)[0], result1['Tc'][4])
        #~ 
        #~ # Assert that the returned resultfile is that of the last succesful 
        #~ # optimization 
        #~ result2 = MPC_object.get_results_this_sample()
        #~ N.testing.assert_(result1==result2)
        #~ 
        #~ # Assert that problem was infeasible yet again and that the returned 
        #~ # input is the next (third) input from the last succesful optimization
        #~ MPC_object.update_state({'_start_c': 900, '_start_T': 400})
        #~ u_k3 = MPC_object.sample()
        #~ N.testing.assert_('Infeasible_Problem_Detected', MPC_object.collocator.
                                        #~ solver_object.getStat('return_status'))
        #~ N.testing.assert_equal(u_k3[1](0)[0], result1['Tc'][7])
#~ 
    #~ @testattr(casadi = True)
    #~ def test_infeasible_start(self):
        #~ """
        #~ Test that the MPC class throws an exception if the first optimization 
        #~ is unsuccessful.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ cvc = {'T': 1e6}
        #~ 
        #~ # Define blocking factors
        #~ bl_list = [1]*horizon
        #~ factors = {'Tc': bl_list}
        #~ bf = BlockingFactors(factors = factors)
        #~ opt_opts['blocking_factors'] = bf
                #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                                                #~ constr_viol_costs=cvc)
#~ 
        #~ # Test with infeasible problem
        #~ MPC_object.update_state({'_start_c': 900, '_start_T': 700})
        #~ 
        #~ N.testing.assert_raises(Exception, MPC_object.sample)
#~ 
    #~ @testattr(casadi = True)
    #~ def test_get_results_this_sample(self):
        #~ """
        #~ Test that get_results_this_sample returns the optimization result for
        #~ this optimization.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ op.set('_start_c', float(self.c_0_A))
        #~ op.set('_start_T', float(self.T_0_A))
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ cvc = {'T': 1e6}
        #~ 
        #~ # Define blocking factors
        #~ bl_list = [1]*horizon
        #~ factors = {'Tc': bl_list}
        #~ bf = BlockingFactors(factors = factors)
        #~ opt_opts['blocking_factors'] = bf
                #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                                #~ constr_viol_costs=cvc, noise_seed=seed)
#~ 
        #~ MPC_object.update_state()
        #~ u_k1 = MPC_object.sample()
        #~ result1 = MPC_object.get_results_this_sample()
        #~ N.testing.assert_equal(0, result1['time'][0])
        #~ N.testing.assert_equal(sample_period*horizon, result1['time'][-1])
#~ 
        #~ MPC_object.update_state()
        #~ u_k2 = MPC_object.sample()
        #~ result2 = MPC_object.get_results_this_sample(full_result=True)
        #~ N.testing.assert_equal(sample_period, result2['time'][0])
        #~ N.testing.assert_equal(sample_period*(horizon+1), result2['time'][-1])
#~ 
    #~ @testattr(casadi = True)
    #~ def test_set(self):
        #~ """
        #~ Test the set function for single parameter, list of parameters and 
        #~ array of parameters.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ # Set options collocation
        #~ n_e = 10
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options and create MPC object
        #~ sample_period = 3
        #~ horizon = 10
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon)
        #~ 
        #~ # Set single parameter
        #~ MPC_object.set('c_ref', 0)
#~ 
        #~ ind_c_ref = MPC_object.collocator.var_indices['c_ref']
        #~ N.testing.assert_equal(MPC_object.collocator._par_vals[ind_c_ref], 0)
        #~ 
        #~ # Set array of parameters
        #~ names = N.array(['T_ref', 'Tc_ref'])
        #~ values = N.array([7, 5])
        #~ MPC_object.set(names, values)
        #~ 
        #~ ind_T_ref = MPC_object.collocator.var_indices['T_ref']
        #~ ind_Tc_ref = MPC_object.collocator.var_indices['Tc_ref']
        #~ N.testing.assert_equal(MPC_object.collocator._par_vals[ind_T_ref], 7)
        #~ N.testing.assert_equal(MPC_object.collocator._par_vals[ind_Tc_ref], 5)
        #~ 
        #~ # Set list of parameters
        #~ names = ['T_ref', 'Tc_ref']
        #~ values = [0, 0]
        #~ MPC_object.set(names, values)
        #~ 
        #~ N.testing.assert_equal(MPC_object.collocator._par_vals[ind_T_ref], 0)
        #~ N.testing.assert_equal(MPC_object.collocator._par_vals[ind_Tc_ref], 0)
#~ 
        #~ # Assert result
        #~ MPC_object.update_state({'_start_c': self.c_0_A, 
                                    #~ '_start_T': self.T_0_A})
        #~ MPC_object.sample()
        #~ res = MPC_object.get_results_this_sample(full_result=True)
#~ 
        #~ T_ref = 242.59043397503004
        #~ c_ref = 956.27669415496121
        #~ assert_results(res, 'T', T_ref)
        #~ assert_results(res, 'c', c_ref)
        #~ 
    #~ @testattr(casadi = True)
    #~ def test_update_with_sim_results(self):
        #~ """
        #~ Test where the states are updated from a simulation result file.
        #~ """
    #~ @testattr(casadi = True)
    #~ def test_update_with_state_dict(self):
        #~ """
        #~ Test where the states are updated from a dictionary containing the 
        #~ estimated states.
        #~ """
    #~ @testattr(casadi = True)
    #~ def test_update_no_input(self):
        #~ """
        #~ Test where update is called with no input, meaning estimates of the
        #~ states are to be extracted from previous optimization result.
        #~ """
    #~ @testattr(casadi = True)
    #~ def test_state_dict_unsupported_parameter(self):
        #~ """
        #~ Test where we are trying to change a parameter that does not correspond
        #~ to an initial state value.
        #~ """
        #~ 
    #~ @testattr(casadi = True)
    #~ def test_worhp(self):
        #~ """
        #~ Test worhp solver
        #~ """
    #~ @testattr(casadi = True)
    #~ def test_element_interpolation(self):
        #~ """ 
        #~ Test result_mode = element_interpolation.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['result_mode'] = 'element_interpolation'
        #~ opt_opts['n_eval_points'] = 4
        #~ opt_opts['IPOPT_options']['print_level'] = 0
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ cvc = {'T': 1e6}
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                        #~ initial_guess='trajectory', constr_viol_costs=cvc, 
                        #~ noise_seed=seed)
        #~ 
        #~ MPC_object.update_state({'_start_c': 587.47543496, 
                                    #~ '_start_T': 345.64619542})
        #~ u_k1 = MPC_object.sample()
        #~ MPC_object.update_state()
        #~ u_k2 = MPC_object.sample()
        #~ 
        #~ # Assert results
        #~ correct_res = N.array([340.18864248, 340.18864248, 340.18864248, 
                                #~ 340.18864248, 304.06596367, 304.06596367, 
                                #~ 304.06596367, 304.06596367])
#~ 
        #~ res = MPC_object.get_complete_results()
        #~ N.testing.assert_array_almost_equal(res['Tc'], correct_res)
#~ 
    #~ @testattr(casadi = True)
    #~ def test_mesh_points(self):
        #~ """ 
        #~ Test result_mode = mesh_points.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['result_mode'] = 'mesh_points'
        #~ opt_opts['IPOPT_options']['print_level'] = 0
#~ 
          #~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ seed = 7
        #~ cvc = {'T': 1e6}
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                        #~ initial_guess='trajectory', constr_viol_costs=cvc, 
                        #~ noise_seed=seed)
        #~ 
        #~ MPC_object.update_state({'_start_c': 587.47543496, 
                                    #~ '_start_T': 345.64619542})
        #~ u_k1 = MPC_object.sample()
        #~ MPC_object.update_state()
        #~ u_k2 = MPC_object.sample()
#~ 
        #~ # Assert results
        #~ correct_res = N.array([ 340.18864248,  340.18864248,  304.06596367,  
                                                            #~ 304.06596367])
        #~ res = MPC_object.get_complete_results()
        #~ N.testing.assert_array_almost_equal(res['Tc'], correct_res)
        #~ 
    #~ @testattr(casadi = True)
    #~ def test_warm_start_options(self):
        #~ """ 
        #~ Test that the warm start options are activated.
        #~ """
        #~ op = transfer_to_casadi_interface("CSTR.CSTR_MPC", 
                                        #~ self.cstr_file_path,
                            #~ compiler_options={"state_initial_equations":True})
        #~ op.set('_start_c', float(self.c_0_A))
        #~ op.set('_start_T', float(self.T_0_A))
        #~ 
        #~ # Set options collocation
        #~ n_e = 50
        #~ opt_opts = op.optimize_options()
        #~ opt_opts['n_e'] = n_e
        #~ opt_opts['IPOPT_options']['print_level'] = 0
#~ 
        #~ # Define some MPC-options
        #~ sample_period = 3
        #~ horizon = 50
        #~ cvc = {'T': 1e6}
        #~ 
        #~ # Create MPC-object
        #~ MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                        #~ initial_guess='trajectory', constr_viol_costs=cvc)
        #~ MPC_object.update_state({'_start_c': 587.47543496, 
                                    #~ '_start_T': 345.64619542})
        #~ u_k1 = MPC_object.sample()
        #~ MPC_object.update_state()
        #~ u_k2 = MPC_object.sample()
#~ 
        #~ N.testing.assert_(MPC_object.collocator.warm_start)
        #~ wsip =\
         #~ MPC_object.collocator.solver_object.getOption('warm_start_init_point')
        #~ mu_init = MPC_object.collocator.solver_object.getOption('mu_init')
        #~ prl = MPC_object.collocator.solver_object.getOption('print_level')
#~ 
        #~ N.testing.assert_(wsip == 'yes')
        #~ N.testing.assert_equal(mu_init, 1e-3)
        #~ N.testing.assert_equal(prl,  0)
