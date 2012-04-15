#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
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

"""Tests the casadi_collocation module."""

import os
import nose

import numpy as N
import pylab as P

from tests_jmodelica import testattr, get_files_path
from pyjmi.common.io import ResultDymolaTextual
from pymodelica.compiler import compile_fmux
try:
    from pyjmi.optimization.casadi_collocation import *
    from pyjmi.casadi_interface import CasadiModel
except NameError, ImportError:
    pass
    #logging.warning('Could not load casadi_collocation. Check pyjmi.check_packages()')

path_to_mos = os.path.join(get_files_path(), 'Modelica')

def assert_results(res, cost_ref, u_norm_ref,
                   cost_rtol=1e-3, u_norm_rtol=1e-4):
    """Helper function for asserting optimization results."""
    cost = float(res.solver.solver.output(casadi.NLP_COST))
    u = res["u"]
    u_norm = N.linalg.norm(u) / N.sqrt(len(u))
    N.testing.assert_allclose(cost, cost_ref, cost_rtol)
    N.testing.assert_allclose(u_norm, u_norm_ref, u_norm_rtol)

class TestLocalDAECollocator:
    
    """
    Tests pyjmi.optimization.casadi_collocation.LocalDAECollocator.
    
    The models used for testing are based on the VDP oscillator, CSTR and a
    custom second order system.
    """
    
    @classmethod
    def setUpClass(cls):
        """Compile the test models."""
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Bounds_Lagrange"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Bounds_Mayer"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Constraints_Mayer"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Initial_Equations"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        class_path = "CSTR.CSTR_Opt_Bounds_Lagrange"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        class_path = "CSTR.CSTR_Opt_Bounds_Mayer"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica',
                                 'ParameterEstimation_1.mop')
        class_path = "ParEst.ParEstCasADi"
        compile_fmux(class_path, file_path)
    
    def setUp(self):
        """Load the test models."""
        fmux_vdp_bounds_lagrange = 'VDP_pack_VDP_Opt_Bounds_Lagrange.fmux'
        self.model_vdp_bounds_lagrange = CasadiModel(fmux_vdp_bounds_lagrange,
                                                     verbose=False)
        
        fmux_vdp_bounds_mayer = 'VDP_pack_VDP_Opt_Bounds_Mayer.fmux'
        self.model_vdp_bounds_mayer = CasadiModel(fmux_vdp_bounds_mayer,
                                                  verbose=False)
        
        fmux_vdp_constraints_mayer = 'VDP_pack_VDP_Opt_Constraints_Mayer.fmux'
        self.model_vdp_constraints_mayer = CasadiModel(
                fmux_vdp_constraints_mayer, verbose=False)
        
        fmux_vdp_initial_equations = 'VDP_pack_VDP_Opt_Initial_Equations.fmux'
        self.model_vdp_initial_equations = CasadiModel(
                fmux_vdp_initial_equations, verbose=False)
        
        fmux_cstr_lagrange = "CSTR_CSTR_Opt_Bounds_Lagrange.fmux"
        self.model_cstr_lagrange = CasadiModel(fmux_cstr_lagrange,
                                               verbose=False)
        self.model_cstr_scaled_lagrange = CasadiModel(
                fmux_cstr_lagrange, scale_variables=True,
                scale_equations=False, verbose=False)
        self.model_cstr_scaled_equations_lagrange = CasadiModel(
                fmux_cstr_lagrange, scale_variables=True, scale_equations=True,
                verbose=False)
        
        fmux_cstr_mayer = "CSTR_CSTR_Opt_Bounds_Mayer.fmux"
        self.model_cstr_mayer = CasadiModel(fmux_cstr_mayer, verbose=False)
        
        fmux_second_order = "ParEst_ParEstCasADi.fmux"
        self.model_second_order = CasadiModel(fmux_second_order)
        self.model_second_order_scaled = CasadiModel(fmux_second_order,
                                                     scale_variables=True,
                                                     verbose=False)
        
        self.algorithm = "LocalDAECollocationAlg"
    
    @testattr(casadi = True)
    def test_init_traj(self):
        """Test optimizing based on an existing optimization reult."""
        model = self.model_vdp_bounds_lagrange
        
        # References values
        cost_ref = 3.19495079586595e0
        u_norm_ref = 2.80997269112246e-1
        
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, 5e-2, 5e-2)
        
    @testattr(casadi = True)
    def test_cstr(self):
        """
        Test optimizing the CSTR.
        
        Tests both a Mayer cost with Gauss collocation and a Lagrange cost with
        Radau collocation.
        """
        mayer_model = self.model_cstr_mayer
        lagrange_model = self.model_cstr_lagrange
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.050971000653911e2
        
        # Mayer
        opts = mayer_model.optimize_options(self.algorithm)
        opts['discr'] = "LG"
        res = mayer_model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Lagrange
        opts['discr'] = "LGR"
        res = lagrange_model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)
    
    @testattr(casadi = True)
    def test_parameter_estimation(self):
        """
        Test a parameter estimation example with and without scaling.
        
        WARNING: This test is very slow when using the linear solver MUMPS for
        Ipopt.
        """
        model_unscaled = self.model_second_order
        model_scaled = self.model_second_order_scaled
        
        # Reference values
        w_ref = 1.048589
        z_ref = 0.470934
        
        # Measurements
        y_meas = N.array([0.01463904, 0.35424225, 0.94776816, 1.20116167,
                          1.17283905, 1.03631145, 1.0549561, 0.94827652,
                          1.0317119, 1.04010453, 1.08012155])
        t_meas = N.linspace(0., 10., num=len(y_meas))
        
        # Parameter estimation data
        Q = N.array([[1.]])
        measured_variables=['sys.y']
        data = N.hstack([N.transpose(N.array([t_meas])),
                         N.transpose(N.array([y_meas]))])
        par_est_data = ParameterEstimationData(Q, measured_variables, data)
        
        # Optimize without scaling
        opts = model_unscaled.optimize_options(self.algorithm)
        opts['parameter_estimation_data'] = par_est_data
        res = model_unscaled.optimize(self.algorithm, opts)
        
        w_unscaled = res['sys.w']
        z_unscaled = res['sys.z']
        N.testing.assert_allclose(w_unscaled, w_ref, 1e-2)
        N.testing.assert_allclose(z_unscaled, z_ref, 1e-2)
        
        # Optimize with scaling
        res = model_scaled.optimize(self.algorithm, opts)
        w_scaled = res['sys.w']
        z_scaled = res['sys.z']
        N.testing.assert_allclose(w_scaled, w_ref, 1e-2)
        N.testing.assert_allclose(z_scaled, z_ref, 1e-2)
    
    @testattr(casadi = True)
    def test_path_constraints(self):
        """Test a simple path constraint with and without exact Hessian."""
        model = self.model_vdp_constraints_mayer
        
        # References values
        cost_ref = 5.273481330869811e0
        u_norm_ref = 3.2936323844551e-1
        
        # Without exact Hessian
        opts = model.optimize_options(self.algorithm)
        opts['exact_hessian'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # With exact Hessian
        opts['exact_hessian'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_initial_equations(self):
        """Test initial equations with and without eliminated derivatives."""
        model = self.model_vdp_initial_equations
        
        # References values
        cost_ref = 4.7533158101416788e0
        u_norm_ref = 5.18716394291585e-1
        
        # Without derivative elimination
        opts = model.optimize_options(self.algorithm)
        opts['eliminate_der_var'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # With derivative elimination
        opts['eliminate_der_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_element_lengths(self):
        """Test non-uniformly distributed elements."""
        model = self.model_vdp_bounds_mayer
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 23
        opts['hs'] = N.array(4 * [0.01] + 2 * [0.05] + 10 * [0.02] +
                             5 * [0.02] + 2 * [0.28])
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 3.174936706809e0, 3.707273799325e-1)
    
    @testattr(casadi = True)
    def test_free_element_lengths(self):
        """Test optimized element lengths with both result modes."""
        model = self.model_vdp_bounds_mayer
        
        # References values
        cost_ref = 4.226631156609e0
        u_norm_ref = 3.985402379035029e-1
        
        # Free element lengths data
        c = 0.5
        Q = N.eye(3)
        bounds = (0.5, 2.0)
        free_ele_data = FreeElementLengthsData(c, Q, bounds)
        
        # Set options shared by both result modes
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 20
        opts['hs'] = "free"
        opts['free_element_lengths_data'] = free_ele_data
        
        # Collocation points
        opts['result_mode'] = "collocation_points"
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        indices = range(1, 4) + range(opts['n_e'] - 3, opts['n_e'])
        values = N.array([0.5, 0.5, 0.5, 2.0, 2.0, 2.0]).reshape([-1, 1])
        N.testing.assert_allclose(20. * res.h_opt[indices], values, 5e-3)
        
        # Element interpolation
        opts['result_mode'] = "element_interpolation"
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=3e-2)
    
    @testattr(casadi = True)
    def test_rename_vars(self):
        """
        Test variable renaming.

        This test is by no means thorough.
        """
        model = self.model_vdp_bounds_mayer
        
        # References values
        cost_ref = 1.353983656973385e0
        u_norm_ref = 2.4636859805244668e-1

        # Common options
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 2

        # Without renaming
        opts['rename_vars'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)

        # WIth renameing
        opts['rename_vars'] = True
        res_renaming = model.optimize(self.algorithm, opts)
        assert_results(res_renaming, cost_ref, u_norm_ref)

        assert(repr(res_renaming.solver.get_equality_constraint()[10]) ==
                "Matrix<SX>((der_x1_1_1-((((1-(x2_1_1*x2_1_1))*x1_1_1)" +
                "-x2_1_1)+u_1_1)))")
        assert(repr(res_renaming.solver.get_equality_constraint()[20]) ==
                "Matrix<SX>((((((-3*x2_1_0)+(5.53197*x2_1_1))+" +
                "(-7.53197*x2_1_2))+(5*x2_1_3))-(10*der_x2_1_3)))")
    
    @testattr(casadi = True)
    def test_scaling(self):
        """
        Test optimizing the CSTR with scaled variables and equations.

        This test also tests writing both the unscaled and scaled result as
        well as eliminating derivative variables.
        """
        unscaled_model = self.model_cstr_lagrange
        scaled_model = self.model_cstr_scaled_lagrange
        scaled_equations_model = self.model_cstr_scaled_equations_lagrange
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.0556730059e2
        
        # Unscaled model, with derivatives
        opts = unscaled_model.optimize_options(self.algorithm)
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = False
        res = unscaled_model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)

        # Scaled model, unscaled result, unscaled equations
        # Eliminated derivatives
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = True
        res = scaled_model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_unscaled = res['cstr.c']

        # Scaled model, scaled result, unscaled equations
        # Eliminated derivatives
        opts['write_scaled_result'] = True
        opts['eliminate_der_var'] = True
        res = scaled_model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_scaled = res['cstr.c']
        N.testing.assert_allclose(c_unscaled, 1000. * c_scaled,
                                  rtol=0, atol=1e-5)
        
        # Scaled model, unscaled result, scaled equations, with derivatives
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = False
        res = scaled_equations_model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_unscaled = res['cstr.c']
    
    @testattr(casadi = True)
    def test_result_mode(self):
        """
        Test the two different result modes.
        
        The difference between the trajectories of the three result modes
        should be very small if n_e * n_cp is sufficiently large. Eliminating
        derivative variables is also tested.
        """
        model = self.model_vdp_bounds_lagrange
        
        # References values
        cost_ref = 3.17495094634053e0
        u_norm_ref = 2.84538299160e-1
        
        # Collocation points
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 100
        opts['n_cp'] = 5
        opts['result_mode'] = "collocation_points"
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Element interpolation
        opts['result_mode'] = "element_interpolation"
        opts['eliminate_der_var'] = True
        opts['n_eval_points'] = 15
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)
        
        # Mesh points
        opts['result_mode'] = "mesh_points"
        opts['n_eval_points'] = 20 # Reset to default
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)
    
    @testattr(casadi = True)
    def test_blocking_factors(self):
        """Test blocking factors."""
        model = self.model_vdp_bounds_lagrange
        
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 3
        opts['blocking_factors'] = N.array(opts['n_e'] * [1])
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 4.6794608506686e0, 3.23598449250e-1,
                       cost_rtol=8e-2, u_norm_rtol=3e-2)
        
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['blocking_factors'] = [1, 2, 1, 1, 2, 13]
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 9.508434744576, 4.173168764353e-1,
                       cost_rtol=8e-2, u_norm_rtol=3e-2)
    
    @testattr(casadi = True)
    def test_eliminate_der_var(self):
        """
        Test that results are consistent regardless of eliminate_der_var.
        """
        model_mayer = self.model_vdp_bounds_mayer
        model_lagrange = self.model_vdp_bounds_lagrange
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref = 2.8723837585e-1
        
        # Keep derivative variables
        opts = model_lagrange.optimize_options(self.algorithm)
        opts["eliminate_der_var"] = False
        res = model_lagrange.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Mayer, eliminate derivative variables
        opts["eliminate_der_var"] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        res = model_mayer.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Kagrange, eliminate derivative variables
        res = model_lagrange.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_eliminate_cont_var(self):
        """
        Test that results are consistent regardless of eliminate_cont_var.
        
        This is tested for both Gauss and Radau collocation.
        """
        model = self.model_vdp_bounds_mayer
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref_radau = 2.8723837585e-1
        u_norm_ref_gauss = 2.852405405154352e-1
        
        # Keep continuity variables, Radau
        opts = model.optimize_options(self.algorithm)
        opts['discr'] = "LGR"
        opts["eliminate_cont_var"] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_radau)
        
        # Eliminate continuity variables, Radau
        opts["eliminate_cont_var"] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Mayer_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_radau)
        
        # Keep continuity variables, Gauss
        opts['discr'] = "LG"
        opts["eliminate_cont_var"] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_gauss)
        
        # Eliminate continuity variables, Gauss
        opts["eliminate_cont_var"] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Mayer_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_gauss)
    
    @testattr(casadi = True)
    def test_quadrature_constraint(self):
        """
        Test that optimization results of the CSTR is consistent regardless of
        quadrature_constraint and eliminate_cont_var for Gauss collocation.
        """
        model = self.model_cstr_mayer
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.050971000653911e2
        
        # Quadrature constraint, with continuity variables
        opts = model.optimize_options(self.algorithm)
        opts['discr'] = "LG"
        opts['quadrature_constraint'] = True
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Quadrature constraint, without continuity variables
        opts['quadrature_constraint'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Evaluation constraint, with continuity variables
        opts['quadrature_constraint'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Evaluation constraint, without continuity variables
        opts['quadrature_constraint'] = False
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_n_cp(self):
        """
        Test varying n_e and n_cp.
        """
        model = self.model_vdp_bounds_mayer
        opts = model.optimize_options(self.algorithm)
        
        # n_cp = 1
        opts['n_e'] = 100
        opts['n_cp'] = 1
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 2.58046279958e0, 2.567510746260e-1)
        
        # n_cp = 3
        opts['n_e'] = 50
        opts['n_cp'] = 3
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 3.1761957722665e0, 2.87238440058e-1)
        
        # n_cp = 8
        opts['n_e'] = 20
        opts['n_cp'] = 8
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Mayer_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 3.17620203643878e0, 2.803233013e-1)
        
    @testattr(casadi = True)
    def test_graphs_and_exact_hessian(self):
        """
        Test that results are consistent regardless of graph and exact_hessian.
        
        The test also checks the elimination of derivative and continuity
        variables.
        """
        model = self.model_vdp_bounds_lagrange
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref = 2.8723837585e-1
        
        # Solve problem to get initialization trajectory
        opts = model.optimize_options(self.algorithm)
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        
        # SX with exact Hessian and eliminated variables
        opts['graph'] = "SX"
        opts['exact_hessian'] = True
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # SX without exact Hessian and eliminated variables
        opts['exact_hessian'] = False
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # expanded_MX with exact Hessian and eliminated variables
        opts['graph'] = "expanded_MX"
        opts['exact_hessian'] = True
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # expanded_MX without exact Hessian and eliminated variables
        opts['exact_hessian'] = False
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.5 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX with exact Hessian and eliminated variables
        opts['graph'] = "MX"
        opts['exact_hessian'] = True
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX without exact Hessian and eliminated variables
        opts['exact_hessian'] = False
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
    @testattr(casadi = True)
    def test_casadi_option(self):
        """
        Test the CasADi option numeric_jacobian.
        """
        model = self.model_vdp_bounds_mayer
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref = 2.8723837585e-1
        
        # numeric_jacobian = True
        opts = model.optimize_options(self.algorithm)
        opts['casadi_options_g']['numeric_jacobian'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # numeric_jacobian = False
        opts['casadi_options_g']['numeric_jacobian'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)

class TestPseudoSpectral:
    
    """
    Tests pyjmi.optimization.casadi_collocation.PseudoSpectral.
    """
    
    @classmethod
    def setUpClass(cls):
        """Compile the test models."""
        file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt2"
        compile_fmux(class_path, file_path)
        
        file_path = os.path.join(get_files_path(), 'Modelica', 'TwoState.mop')
        class_path = "TwoState"
        compile_fmux(class_path, file_path)
    
    def setUp(self):
        """Load the test models."""
        fmux_vdp = 'VDP_pack_VDP_Opt2.fmux'
        self.model_vdp = CasadiModel(fmux_vdp, verbose=False)
        
        fmux_two_state = 'TwoState.fmux'
        self.model_two_state = CasadiModel(fmux_two_state, verbose=False)
    
    @testattr(casadi = True)
    def test_two_state(self):
        """Tests the different discretization on the TwoState example."""
        opts = self.model_two_state.optimize_options("CasadiPseudoSpectralAlg")
        opts['n_e'] = 1
        opts['n_cp'] = 30
                
        #Test LG points
        opts['discr'] = "LG"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
    
    @testattr(casadi = True)
    def test_two_state_init_traj(self):
        """
        Tests that the option init_traj is functional.
        
        NOTE: SHOULD ALSO TEST THAT THE NUMBER OF ITERATIONS SHOULD BE SMALLER.
        """
        opts = self.model_two_state.optimize_options("CasadiPseudoSpectralAlg")
        opts['n_e'] = 1
        opts['n_cp'] = 30
        opts['discr'] = "LG"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)

        #Test LG points
        opts['discr'] = "LG"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)
        y1 = res["y1"]
        y2 = res["y2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.5000000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 1.124170946790, places=5)
        nose.tools.assert_almost_equal(u[-1], 0.498341205247, places=5)
    
    @testattr(casadi = True)
    def test_doubleintegrator(self):
        """Tests the different discretization on the DoubleIntegrator example."""
        
        """
        UNCOMMENT WHEN FREE TIME HAVE BEEN FIXED!!!
        
        jn = compile_fmux("DoubleIntegrator", os.path.join(path_to_mos,"DoubleIntegrator.mop"))
        vdp = CasadiModel(jn)
        
        opts = vdp.optimize_options("CasadiPseudoSpectralAlg")
        opts['n_e'] = 8
        opts['n_cp'] = 5
                
        #Test LG points
        opts['discr'] = "LG"
        res = vdp.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = vdp.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        #Test LGL points
        opts['discr'] = "LGL"
        res = vdp.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)
        y1 = res["x1"]
        y2 = res["x2"]
        u = res["u"]
        time = res["time"]
        nose.tools.assert_almost_equal(y1[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(y2[-1], 0.00000000, places=5)
        nose.tools.assert_almost_equal(u[-1], 1.000000000, places=5)
        
        """
        
    @testattr(casadi = True)
    def test_vdp(self):
        """Tests the different discretization options on a modified VDP."""
        opts = self.model_vdp.optimize_options("CasadiPseudoSpectralAlg")
        opts['n_e'] = 1
        opts['n_cp'] = 60
        
        #Test LG points
        opts['discr'] = "LG"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectralAlg",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectralAlg",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectralAlg",
                                      options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        """
        opts['n_e'] = 20
        opts['n_cp'] = 6
        
        #Test LG points
        opts['discr'] = "LG"
        res = vdp.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = vdp.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = vdp.optimize(algorithm="CasadiPseudoSpectralAlg", options=opts)
        cost = res["cost"]
        nose.tools.assert_almost_equal(cost[-1], 2.3463724e1, places=1)
        """
