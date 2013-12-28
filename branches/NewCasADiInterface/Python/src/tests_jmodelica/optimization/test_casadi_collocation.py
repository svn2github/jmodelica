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

from collections import OrderedDict
import numpy as N
from scipy.io.matlab.mio import loadmat

from tests_jmodelica import testattr, get_files_path
from pyjmi.common.io import ResultDymolaTextual
from pyjmi.common.xmlparser import XMLException
from pymodelica.compiler import compile_fmux, compile_fmu
from pyfmi import FMUModel,load_fmu
try:
    from casadi_interface import transfer_to_casadi_interface
    from pyjmi.optimization.casadi_collocation import *
    from pyjmi.casadi_interface import CasadiModel
    import casadi
except (NameError, ImportError):
    pass

from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError
#Check to see if pyfmi is installed so that we also catch the error generated
#from that package
try:
    from pyfmi.common.io import VariableNotFoundError as fmiVariableNotFoundError
    VariableNotFoundError = (jmiVariableNotFoundError, fmiVariableNotFoundError)
except ImportError:
    VariableNotFoundError = jmiVariableNotFoundError

path_to_mos = os.path.join(get_files_path(), 'Modelica')
path_to_data = os.path.join(get_files_path(), 'Data')

def assert_results(res, cost_ref, u_norm_ref,
                   cost_rtol=1e-3, u_norm_rtol=1e-4, input_name="u"):
    """Helper function for asserting optimization results."""
    cost = float(res.solver.solver.output(casadi.NLP_SOLVER_F))
    u = res[input_name]
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
        vdp_file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Bounds_Lagrange"
        compile_fmux(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Bounds_Lagrange_Renamed_Input"
        compile_fmux(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Bounds_Mayer"
        compile_fmux(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Constraints_Mayer"
        compile_fmux(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Initial_Equations"
        compile_fmux(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Scaled_Min_Time"
        compile_fmux(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Unscaled_Min_Time"
        compile_fmux(class_path, vdp_file_path)

        class_path = "VDP_pack.VDP_Opt_Min_Time_Nonzero_Start"
        compile_fmux(class_path, vdp_file_path)
        
        cstr_file_path = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        class_path = "CSTR.CSTR"
        compile_fmu(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Bounds_Lagrange"
        compile_fmux(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Bounds_Mayer"
        compile_fmux(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Dependent_Parameter"
        compile_fmux(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Extends"
        compile_fmux(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Scaled_Min_Time"
        compile_fmux(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Unscaled_Min_Time"
        compile_fmux(class_path, cstr_file_path)
        
        pe_file_path = os.path.join(get_files_path(), 'Modelica',
                                    'ParameterEstimation_1.mop')
        class_path = "ParEst.SecondOrder"
        compile_fmu(class_path, pe_file_path)
        
        class_path = "ParEst.ParEstCasADi"
        compile_fmux(class_path, pe_file_path)
        
        qt_file_path = os.path.join(get_files_path(), 'Modelica',
                                    'QuadTankPack.mop')
        class_path = "QuadTankPack.Sim_QuadTank"
        compile_fmu(class_path, qt_file_path)
        
        class_path = "QuadTankPack.QuadTank_ParEstCasADi"
        compile_fmux(class_path, qt_file_path)
        
        class_path = "QuadTankPack.QuadTank_ParEstCasADi_Degenerate"
        compile_fmux(class_path, qt_file_path)
    
    def setUp(self):
        """Load the test models."""
        fmux_vdp_bounds_lagrange = 'VDP_pack_VDP_Opt_Bounds_Lagrange.fmux'
        self.model_vdp_bounds_lagrange = CasadiModel(fmux_vdp_bounds_lagrange,
                                                     verbose=False)
        
        fmux_vdp_bounds_lagrange_renamed = ('VDP_pack_VDP_Opt_Bounds_' +
                                            'Lagrange_Renamed_Input.fmux')
        self.model_vdp_bounds_lagrange_renamed = CasadiModel(
                fmux_vdp_bounds_lagrange_renamed, verbose=False)
        
        
        fmux_vdp_bounds_mayer = 'VDP_pack_VDP_Opt_Bounds_Mayer.fmux'
        self.model_vdp_bounds_mayer = CasadiModel(fmux_vdp_bounds_mayer,
                                                  verbose=False)
        
        fmux_vdp_constraints_mayer = 'VDP_pack_VDP_Opt_Constraints_Mayer.fmux'
        self.model_vdp_constraints_mayer = CasadiModel(
                fmux_vdp_constraints_mayer, verbose=False)
        
        fmux_vdp_initial_equations = 'VDP_pack_VDP_Opt_Initial_Equations.fmux'
        self.model_vdp_initial_equations = CasadiModel(
                fmux_vdp_initial_equations, verbose=False)
        
        fmux_vdp_scaled_min_time = 'VDP_pack_VDP_Opt_Scaled_Min_Time.fmux'
        self.model_vdp_scaled_min_time = CasadiModel(
                fmux_vdp_scaled_min_time, verbose=False)
        
        fmux_vdp_unscaled_min_time = 'VDP_pack_VDP_Opt_Unscaled_Min_Time.fmux'
        self.model_vdp_unscaled_min_time = CasadiModel(
                fmux_vdp_unscaled_min_time, verbose=False)

        fmux_vdp_min_time_nonzero_start = \
                'VDP_pack_VDP_Opt_Min_Time_Nonzero_Start.fmux'
        self.model_vdp_min_time_nonzero_start = CasadiModel(
                fmux_vdp_min_time_nonzero_start, verbose=False)
        
        fmu_cstr = 'CSTR_CSTR.fmu'
        self.model_cstr = load_fmu(fmu_cstr)
        
        fmux_cstr_lagrange = "CSTR_CSTR_Opt_Bounds_Lagrange.fmux"
        self.model_cstr_lagrange = CasadiModel(fmux_cstr_lagrange,
                                               verbose=False)
        
        fmux_cstr_mayer = "CSTR_CSTR_Opt_Bounds_Mayer.fmux"
        self.model_cstr_mayer = CasadiModel(fmux_cstr_mayer, verbose=False)
        
        fmux_cstr_dependent_parameter = \
                "CSTR_CSTR_Opt_Dependent_Parameter.fmux"
        self.model_cstr_dependent_parameter = CasadiModel(
                fmux_cstr_mayer, verbose=False)
        
        fmux_cstr_extends = "CSTR_CSTR_Opt_Extends.fmux"
        self.model_cstr_extends = CasadiModel(fmux_cstr_extends, verbose=False)
        
        fmux_cstr_scaled_min_time = 'CSTR_CSTR_Opt_Scaled_Min_Time.fmux'
        self.model_cstr_scaled_min_time = CasadiModel(
                fmux_cstr_scaled_min_time, verbose=False)
        
        fmux_cstr_unscaled_min_time = 'CSTR_CSTR_Opt_Unscaled_Min_Time.fmux'
        self.model_cstr_unscaled_min_time = CasadiModel(
                fmux_cstr_unscaled_min_time, verbose=False)
        
        fmux_second_order = "ParEst_SecondOrder.fmu"
        self.model_second_order = load_fmu(fmux_second_order)
        
        fmux_second_order_par_est = "ParEst_ParEstCasADi.fmux"
        self.model_second_order_par_est = CasadiModel(
            fmux_second_order_par_est, verbose=False)
        
        fmu_qt_sim = "QuadTankPack_Sim_QuadTank.fmu"
        self.model_qt_sim = load_fmu(fmu_qt_sim)
        
        fmux_qt_par_est = "QuadTankPack_QuadTank_ParEstCasADi.fmux"
        self.model_qt_par_est = CasadiModel(fmux_qt_par_est, verbose=False)
        
        fmux_qt_par_est_degenerate = \
                "QuadTankPack_QuadTank_ParEstCasADi_Degenerate.fmux"
        self.model_qt_par_est_degenerate = CasadiModel(
                fmux_qt_par_est_degenerate, verbose=False)
        
        self.algorithm = "LocalDAECollocationAlg"
    
    @testattr(casadi = True)
    def test_init_traj_sim(self):
        """Test initial trajectories based on an existing simulation."""
        model = self.model_cstr
        model.reset()
        model_opt = self.model_cstr_extends
        model.set(['c_init', 'T_init'], model_opt.get(['c_init', 'T_init']))
        
        # Create input trajectory
        t = [0, 200]
        u = [342.85, 280]
        u_traj = N.transpose(N.vstack((t, u)))
        
        # Generate initial trajectories
        opts = model.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-8*model.nominal_continuous_states
        init_res = model.simulate(final_time=300, input=('Tc', u_traj),
                                  options=opts)
        
        # Optimize
        opts = model_opt.optimize_options(self.algorithm)
        opts['variable_scaling'] = False
        opts['init_traj'] = init_res.result_data
        col = LocalDAECollocator(model_opt, opts)
        xx_init = col.get_xx_init()
        N.testing.assert_allclose(
                xx_init[col.var_indices[opts['n_e']][opts['n_cp']]['x']],
                [435.4425832, 333.42862629],rtol=1e-5)
    
    @testattr(casadi = True)
    def test_init_traj_opt(self):
        """Test optimizing based on an existing optimization reult."""
        model = self.model_vdp_bounds_lagrange
        
        # References values
        cost_ref = 3.19495079586595e0
        u_norm_ref = 2.80997269112246e-1
        
        # Get initial guess
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Optimize using initial guess
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, 5e-2, 5e-2)
    
    @testattr(casadi = True)
    def test_nominal_traj_vdp(self):
        """Test optimizing a VDP using nominal and initial trajectories."""
        model = self.model_vdp_bounds_lagrange
        
        # References values
        cost_ref_traj = 3.19495079586595e0
        u_norm_ref_traj = 2.80997269112246e-1
        cost_ref = 3.1749908234182826e0
        u_norm_ref = 2.848606420347583e-1
        
        # Get nominal and initial trajectories
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref_traj, u_norm_ref_traj)
        try:
            os.remove("vdp_nom_traj_result.txt")
        except OSError:
            pass
        os.rename("VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt",
                  "vdp_nom_traj_result.txt")
        
        # Optimize using only initial trajectories
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['init_traj'] = ResultDymolaTextual("vdp_nom_traj_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Optimize using nominal and initial trajectories
        opts['nominal_traj'] = ResultDymolaTextual("vdp_nom_traj_result.txt")
        opts['nominal_traj_mode'] = {'_default_mode': "affine"}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        col = res.solver
        xx_init = col.get_xx_init()
        N.testing.assert_allclose(
                xx_init[col.var_indices[opts['n_e']][opts['n_cp']]['x']],
                [0.85693481, 0.12910473])
        
        # Test with eliminated continuity variables
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test with eliminated continuity and derivative variables
        opts['eliminate_der_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test disabling scaling
        opts['variable_scaling'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_nominal_traj_cstr(self):
        """Test optimizing a CSTR using nominal and initial trajectories."""
        model = self.model_cstr_lagrange
        
        # References values
        cost_ref_traj = 1.8549259545339369e3
        u_norm_ref_traj = 3.0455503580669716e2
        cost_ref = 1.858428662785409e3
        u_norm_ref = 3.0507636243132043e2
        
        # Get nominal and initial trajectories
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref_traj, u_norm_ref_traj)
        try:
            os.remove("cstr_nom_traj_result.txt")
        except OSError:
            pass
        os.rename("CSTR_CSTR_Opt_Bounds_Lagrange_result.txt",
                  "cstr_nom_traj_result.txt")
        
        # Optimize using only initial trajectories
        n_e = 75
        n_cp = 4
        opts['n_e'] = n_e
        opts['n_cp'] = n_cp
        opts['init_traj'] = ResultDymolaTextual("cstr_nom_traj_result.txt")
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Optimize using nominal and initial trajectories
        opts['nominal_traj'] = ResultDymolaTextual("cstr_nom_traj_result.txt")
        opts['nominal_traj_mode'] = {'_default_mode': 'time-variant'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        col = res.solver
        xx_init = col.get_xx_init()
        N.testing.assert_equal(sum(xx_init == 1.),
                               (n_e * n_cp + 1) * 3 + 2 * n_e)
        
        # Test with eliminated continuity variables
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test with eliminated continuity and derivative variables
        opts['eliminate_der_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test disabling scaling
        opts['variable_scaling'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_nominal_traj_mode(self):
        """Test nominal_traj_mode on the CSTR."""
        model = self.model_cstr_lagrange
        
        # References values
        cost_ref = 1.8549259545339369e3
        u_norm_ref = 3.0455503580669716e2
        
        # Get nominal and initial trajectories
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        try:
            os.remove("cstr_nom_traj_result.txt")
        except OSError:
            pass
        os.rename("CSTR_CSTR_Opt_Bounds_Lagrange_result.txt",
                  "cstr_nom_traj_result.txt")
        
        # Time-variant
        opts['nominal_traj'] = ResultDymolaTextual("cstr_nom_traj_result.txt")
        opts['nominal_traj_mode'] = {'_default_mode': 'time-variant'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Affine
        opts['nominal_traj_mode'] = {'_default_mode': 'affine'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Linear
        opts['nominal_traj_mode'] = {'_default_mode': 'linear'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Attribute
        opts['nominal_traj_mode'] = {'_default_mode': 'attribute'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Check impossible time-variant scaling
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'cstr.der(c)': 'time-variant'}
        N.testing.assert_raises(CasadiCollocatorException, model.optimize,
                                self.algorithm, opts)
        
        # Check changing one variable
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'cstr.c': 'time-variant'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Check alias variables
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'cstr.Tc': 'time-variant'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'u': 'time-variant'}
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'asdf': 'time-variant'}
        N.testing.assert_raises(XMLException, model.optimize, self.algorithm,
                                opts)
    
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
        
        WARNING: This test is very slow when using IPOPT with the linear solver
        MUMPS.
        """
        model = self.model_second_order_par_est
        
        # Reference values
        w_ref = 1.048589
        z_ref = 0.470934
        
        # Measurements
        y_meas = N.array([0.01463904, 0.35424225, 0.94776816, 1.20116167,
                          1.17283905, 1.03631145, 1.0549561, 0.94827652,
                          1.0317119, 1.04010453, 1.08012155])
        t_meas = N.linspace(0., 10., num=len(y_meas))
        data = N.vstack([t_meas, y_meas])
        
        # Measurement data
        Q = N.array([[1.]])
        unconstrained=OrderedDict()
        unconstrained['y'] = data
        measurement_data = MeasurementData(unconstrained=unconstrained, Q=Q)
        
        # Optimize without scaling
        opts = model.optimize_options(self.algorithm)
        opts['measurement_data'] = measurement_data
        opts['variable_scaling'] = False
        opts['n_e'] = 16
        res = model.optimize(self.algorithm, opts)
        
        w_unscaled = res.final('w')
        z_unscaled = res.final('z')
        N.testing.assert_allclose(w_unscaled, w_ref, 1e-2)
        N.testing.assert_allclose(z_unscaled, z_ref, 1e-2)
        
        # Optimize with scaling
        opts['variable_scaling'] = True
        res = model.optimize(self.algorithm, opts)
        w_scaled = res.final('w')
        z_scaled = res.final('z')
        N.testing.assert_allclose(w_scaled, w_ref, 1e-2)
        N.testing.assert_allclose(z_scaled, z_ref, 1e-2)
    
    @testattr(casadi = True)
    def test_parameter_estimation_traj(self):
        """
        Test estimation with and without initial and nominal trajectories.
        """
        sim_model = self.model_second_order
        sim_model.reset()
        opt_model = self.model_second_order_par_est
        
        # Simulate with initial guesses
        sim_model.set('w', 1.3)
        sim_model.set('z', 0.3)
        sim_res = sim_model.simulate(final_time=15.)
        
        # Reference values
        w_ref = 1.048589
        z_ref = 0.470934
        
        # Measurements
        y_meas = N.array([0.01463904, 0.35424225, 0.94776816, 1.20116167,
                          1.17283905, 1.03631145, 1.0549561, 0.94827652,
                          1.0317119, 1.04010453, 1.08012155])
        t_meas = N.linspace(0., 10., num=len(y_meas))
        data = N.vstack([t_meas, y_meas])
        
        # Measurement data
        Q = N.array([[1.]])
        unconstrained = OrderedDict()
        unconstrained['y'] = data
        measurement_data = MeasurementData(unconstrained=unconstrained, Q=Q)
        
        # Optimize without scaling
        opts = opt_model.optimize_options(self.algorithm)
        opts['measurement_data'] = measurement_data
        opts['n_e'] = 16
        opt_res = opt_model.optimize(self.algorithm, opts)
        
        # Assert results
        w = opt_res.final('w')
        z = opt_res.final('z')
        N.testing.assert_allclose(w, w_ref, 1e-2)
        N.testing.assert_allclose(z, z_ref, 1e-2)
        
        # Optimize with trajectories
        opts['init_traj'] = sim_res.result_data
        opts['nominal_traj'] = sim_res.result_data
        traj_res = opt_model.optimize(self.algorithm, opts)
        w_traj = traj_res.final('w')
        z_traj = traj_res.final('z')
        N.testing.assert_allclose(w_traj, w_ref, 1e-2)
        N.testing.assert_allclose(z_traj, z_ref, 1e-2)
    
    @testattr(casadi = True)
    def test_qt_par_est_unconstrained(self):
        """
        Test parameter estimation for the quad tank with unconstrained inputs.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        sim_model = self.model_qt_sim
        sim_model.reset()
        opt_model = self.model_qt_par_est
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = sim_model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u1'] = data_u1
        unconstrained['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained)
        
        # Unconstrained
        opts = opt_model.optimize_options()
        opts['n_e'] = 60
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = opt_model.optimize(self.algorithm, options=opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Unconstrained with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = opt_model.optimize(self.algorithm, options=opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
    
    @testattr(casadi = True)
    def test_qt_par_est_eliminated(self):
        """
        Test parameter estimation for the quad tank with eliminated inputs.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        sim_model = self.model_qt_sim
        sim_model.reset()
        opt_model = self.model_qt_par_est
        opt_model_2 = self.model_qt_par_est_degenerate
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = sim_model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        eliminated['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        
        # Eliminated
        opts = opt_model.optimize_options()
        opts['n_e'] = 30
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Eliminated with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Inconsistent bound on eliminated input
        opt_model.set_min('u1', 5.1)
        N.testing.assert_raises(CasadiCollocatorException,
                                opt_model.optimize, self.algorithm, opts)
        opt_model.set_min('u1', -N.inf)
        
        # Point constraint on eliminated input
        opts2 = opt_model_2.optimize_options()
        opts2['n_e'] = 30
        opts2['init_traj'] = sim_res.result_data
        opts2['measurement_data'] = measurement_data
        N.testing.assert_raises(CasadiCollocatorException,
                                opt_model_2.optimize, self.algorithm, opts2)
        
        # Eliminate state
        Q = N.array([[1.]])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        eliminated['u2'] = data_u2
        eliminated['qt.x2'] = data_x2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        opts['measurement_data'] = measurement_data
        N.testing.assert_raises(VariableNotFoundError,
                                opt_model.optimize, self.algorithm, opts)
    
    @testattr(casadi = True)
    def test_qt_par_est_constrained(self):
        """
        Test parameter estimation for the quad tank with constrained inputs.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        sim_model = self.model_qt_sim
        sim_model.reset()
        opt_model = self.model_qt_par_est
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = sim_model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        constrained = OrderedDict()
        constrained['u1'] = data_u1
        constrained['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           constrained=constrained)
        
        # Constrained
        opts = opt_model.optimize_options()
        opts['n_e'] = 30
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Constrained with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Inconsistent bound on constrained input
        opt_model.set_min('u1', 5.1)
        N.testing.assert_raises(CasadiCollocatorException,
                                opt_model.optimize, self.algorithm, opts)
        opt_model.set_min('u1', -N.inf)
        
        # Constrain state
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        constrained = OrderedDict()
        constrained['u1'] = data_u1
        constrained['u2'] = data_u2
        constrained['qt.x2'] = data_x2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           constrained=constrained)
        opts['measurement_data'] = measurement_data
        N.testing.assert_raises(VariableNotFoundError,
                                opt_model.optimize, self.algorithm, opts)
    
    @testattr(casadi = True)
    def test_qt_par_est_semi_eliminated(self):
        """
        Test parameter estimation for the quad tank with 1 eliminated input.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        sim_model = self.model_qt_sim
        sim_model.reset()
        opt_model = self.model_qt_par_est
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = sim_model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u1'] = data_u1
        eliminated = OrderedDict()
        eliminated['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        
        # Eliminate u2
        opts = opt_model.optimize_options()
        opts['n_e'] = 60
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Eliminate u2 with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Eliminate u1
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u2'] = data_u2
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        opts['nominal_traj'] = None
        opts['measurement_data'] = measurement_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Eliminate u1 with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
    
    @testattr(casadi = True)
    def test_qt_par_est_user_interpolator(self):
        """
        Test parameter estimation for the quad tank with user-defined function.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        sim_model = self.model_qt_sim
        sim_model.reset()
        opt_model = self.model_qt_par_est
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = sim_model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u2 = N.vstack([t_meas, u2])
        linear_u1 = TrajectoryLinearInterpolation(t_meas,
                                                  u1.reshape([-1, 1]))
        user_u1 = linear_u1.eval
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u2'] = data_u2
        eliminated = OrderedDict()
        eliminated['u1'] = user_u1
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        
        # Semi-eliminated with user-defined interpolation function
        opts = opt_model.optimize_options()
        opts['n_e'] = 60
        opts['measurement_data'] = measurement_data
        opt_res = opt_model.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Inconsistent bounds on eliminated input with user-defined function
        opt_model.set_min('u1', 5.1)
        N.testing.assert_raises(CasadiCollocatorException,
                                opt_model.optimize, self.algorithm, opts)
        opt_model.set_min('u1', -N.inf)
    
    @testattr(casadi = True)
    def test_vdp_minimum_time(self):
        """
        Test solving minimum time problems based on the VDP oscillator.
        
        Tests one problem where the time is manually scaled. Tests two where
        the time is automatically scaled by the compiler, where one of them
        starts at time 0 and the other starts at time 5.
        """
        model_scaled = self.model_vdp_scaled_min_time
        model_unscaled = self.model_vdp_unscaled_min_time
        model_nonzero_start = self.model_vdp_min_time_nonzero_start
        
        # References values
        cost_ref = 2.2811590707107996e0
        u_norm_ref = 9.991517452037317e-1
        
        # Scaled, Radau
        opts = model_scaled.optimize_options(self.algorithm)
        opts['discr'] = "LGR"
        res = model_scaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Scaled, Gauss
        opts['discr'] = "LG"
        res = model_scaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        
        # Unscaled, Radau
        opts['discr'] = "LGR"
        res = model_unscaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        
        # Unscaled, Gauss
        opts['discr'] = "LG"
        res = model_unscaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

        # Unscaled, non-zero start, Radau
        opts['discr'] = "LGR"
        res = model_nonzero_start.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        N.testing.assert_allclose(res['time'][[0, -1]], [5., 7.28115907],
                                  rtol=5e-3)
        
        # Unscaled, non-zero start, Gauss
        opts['discr'] = "LG"
        res = model_nonzero_start.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        N.testing.assert_allclose(res['time'][[0, -1]], [5., 7.28128126],
                                  rtol=5e-3)
    
    @testattr(casadi = True)
    def test_cstr_minimum_time(self):
        """
        Test solving minimum time problems based on the CSTR.
        
        Tests both a problem where the time is manually scaled, and one where
        the time is automatically scaled by the compiler.
        """
        model_scaled = self.model_cstr_scaled_min_time
        model_unscaled = self.model_cstr_unscaled_min_time
        
        # References values
        cost_ref = 1.1637020114180874e2
        u_norm_ref = 3.0668821961641106e2
        
        # Scaled, Radau
        opts = model_scaled.optimize_options(self.algorithm)
        opts['discr'] = "LGR"
        res = model_scaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, input_name="Tc")
        
        # Scaled, Gauss
        opts['discr'] = "LG"
        res = model_scaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2,
                       input_name="Tc")
        
        # Unscaled, Radau
        opts['discr'] = "LGR"
        res = model_unscaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2,
                       input_name="Tc")
        
        # Unscaled, Gauss
        opts['discr'] = "LG"
        res = model_unscaled.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2,
                       input_name="Tc")
    
    @testattr(casadi = True)
    def test_path_constraints(self):
        """Test a simple path constraint with and without exact Hessian."""
        model = self.model_vdp_constraints_mayer
        
        # References values
        cost_ref = 5.273481330869811e0
        u_norm_ref = 3.2936323844551e-1
        
        # Without exact Hessian
        opts = model.optimize_options(self.algorithm)
        opts['IPOPT_options']['hessian_approximation'] = "limited-memory"
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # With exact Hessian
        opts['IPOPT_options']['hessian_approximation'] = "exact"
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
        values = N.array([0.5, 0.5, 0.5, 2.0, 2.0, 2.0])
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

        # With renaming
        opts['rename_vars'] = True
        res_renaming = model.optimize(self.algorithm, opts)
        assert_results(res_renaming, cost_ref, u_norm_ref)

        assert(repr(res_renaming.solver.get_equality_constraint()[10]) ==
                "Matrix<SX>((der_x1_1_1-((((1-sq(x2_1_1))*x1_1_1)" +
                "-x2_1_1)+u_1_1)))")
        assert(repr(res_renaming.solver.get_equality_constraint()[20]) ==
                "Matrix<SX>((((((-3*x2_1_0)+(5.53197*x2_1_1))+" +
                "(-7.53197*x2_1_2))+(5*x2_1_3))-(10*der_x2_1_3)))")
    
    @testattr(casadi = True)
    def test_scaling(self):
        """
        Test optimizing the CSTR with and without scaling.

        This test also tests writing both the unscaled and scaled result,
        eliminating derivative variables and setting nominal values
        post-compilation.
        """
        model = self.model_cstr_lagrange
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.0556730059e2
        
        # Unscaled variables, with derivatives
        opts = model.optimize_options(self.algorithm)
        opts['variable_scaling'] = False
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)

        # Scaled variables, unscaled result
        # Eliminated derivatives
        opts['variable_scaling'] = True
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_unscaled = res['cstr.c']

        # Scaled variables, scaled result
        # Eliminated derivatives
        opts['variable_scaling'] = True
        opts['write_scaled_result'] = True
        opts['eliminate_der_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_scaled = res['cstr.c']
        N.testing.assert_allclose(c_unscaled, 1000. * c_scaled,
                                  rtol=0, atol=1e-5)
        
        # Scaled variables, scaled result, with updated nominal value
        # Eliminated derivatives
        model.set_nominal('cstr.c', 500.)
        res = model.optimize(self.algorithm, opts)
        model.set_nominal('cstr.c', 1000.)
        assert_results(res, cost_ref, u_norm_ref)
        c_scaled = res['cstr.c']
        N.testing.assert_allclose(c_unscaled, 500. * c_scaled,
                                  rtol=0, atol=1e-5)
    
    @testattr(casadi = True)
    def test_result_file_name(self):
        """
        Test different result file names.
        """
        model = self.model_vdp_bounds_lagrange
        
        # Default file name
        try:
            os.remove("VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        except OSError:
            pass
        model.optimize(self.algorithm)
        assert(os.path.exists("VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt"))
        
        # Custom file name
        opts = model.optimize_options(self.algorithm)
        opts['result_file_name'] = "vdp_custom_file_name.txt"
        try:
            os.remove("vdp_custom_file_name.txt")
        except OSError:
            pass
        model.optimize(self.algorithm, opts)
        assert(os.path.exists("vdp_custom_file_name.txt"))
    
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
    def test_parameter_setting(self):
        """Test setting parameters post-compilation."""
        # Create new model
        fmux_cstr_dependent_parameter = \
                "CSTR_CSTR_Opt_Dependent_Parameter.fmux"
        model = CasadiModel(fmux_cstr_dependent_parameter, verbose=False)
        N.testing.assert_raises(XMLException, model.set, 'cstr.F', 500)
        
        # Reference values
        cost_ref_low = 1.2391821615924346e3
        u_norm_ref_low = 2.833724580055005e2
        cost_ref_default = 1.8576873858261e3
        u_norm_ref_default = 3.0556730059139556e2
        
        # Test lower EdivR
        model.set('cstr.EdivR', 8200)
        res_low = model.optimize(self.algorithm)
        assert_results(res_low, cost_ref_low, u_norm_ref_low)
        
        # Test default EdviR
        model.set('cstr.EdivR', 8750)
        res_default = model.optimize(self.algorithm)
        assert_results(res_default, cost_ref_default, u_norm_ref_default)
    
    @testattr(casadi = True)
    def test_blocking_factors(self):
        """Test blocking factors."""
        model = self.model_vdp_bounds_lagrange
        
        opts = model.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 3
        opts['blocking_factors'] = N.array(opts['n_e'] * [1])
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 3.3109070531151135e0, 2.8718067708687645e-1,
                       cost_rtol=8e-2, u_norm_rtol=3e-2)
        
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['blocking_factors'] = [1, 2, 1, 1, 2, 13]
        res = model.optimize(self.algorithm, opts)
        assert_results(res, 3.620908059907745e0, 3.049446667587375e-1,
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
    def test_graphs_and_hessian(self):
        """
        Test that results are consistent regardless of graph and Hessian.
        
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
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # SX without exact Hessian and eliminated variables
        opts['IPOPT_options']['hessian_approximation'] = "limited-memory"
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.9 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Expanded MX with exact Hessian and eliminated variables
        opts['graph'] = "MX"
        opts['IPOPT_options']['expand'] = True
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # Expanded MX without exact Hessian and eliminated variables
        opts['IPOPT_options']['hessian_approximation'] = "limited-memory"
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.9 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX with exact Hessian and eliminated variables
        opts['IPOPT_options']['expand'] = False
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX without exact Hessian and eliminated variables
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(casadi = True)
    def test_ipopt_statistics(self):
        """
        Test getting IPOPT statistics
        """
        model = self.model_vdp_bounds_mayer
        
        cost_ref = 3.17619580332244e0
        
        res = model.optimize()
        (return_status, nbr_iter, objective, total_exec_time) = \
                res.solver.get_ipopt_statistics()
        N.testing.assert_string_equal(return_status, "Solve_Succeeded")
        N.testing.assert_array_less([nbr_iter, -nbr_iter], [100, -5])
        N.testing.assert_allclose(objective, cost_ref, 1e-3, 1e-4)
        N.testing.assert_array_less([total_exec_time, -total_exec_time],
                                    [1., 0.])
    
    @testattr(casadi = True)
    def test_input_interpolator(self):
        """
        Test the input interpolator for simulation purposes
        """
        model = self.model_cstr
        model.reset()
        model_opt = self.model_cstr_extends
        model.set(['c_init', 'T_init'], model_opt.get(['c_init', 'T_init']))
        
        # Optimize
        opts = model_opt.optimize_options(self.algorithm)
        opts['n_e'] = 100        
        opt_res = model_opt.optimize(options=opts)
        
        # Simulate
        opt_input = opt_res.solver.get_opt_input()
        opts = model.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-8*model.nominal_continuous_states
        res = model.simulate(start_time=0., final_time=150., input=opt_input, options=opts)
        N.testing.assert_allclose([res.final("T"), res.final("c")],
                                  [284.62140206, 345.22510435], rtol=5e-4)

    @testattr(casadi = True)
    def test_matrix_evaluations(self):
        """
        Test evaluating NLP matrices.
        """
        model = self.model_cstr_lagrange

        # References values
        cost_ref = 1.852527678e3
        u_norm_ref = 3.045679e2

        # Solve
        opts = model.optimize_options()
        opts['n_e'] = 20
        res = model.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)

        # Compute Jacobian condition numbers
        J_init = res.get_J("init")
        J_init_cond = N.linalg.cond(J_init)
        N.testing.assert_allclose(J_init_cond, 2.93e4, rtol=1e-2)
        J_opt = res.get_J("opt")
        J_opt_cond = N.linalg.cond(J_opt)
        N.testing.assert_allclose(J_opt_cond, 2.47e6, rtol=1e-2)

        # Compute Hessian norms
        H_init = res.get_H("init")
        H_init_norm = N.linalg.norm(H_init)
        N.testing.assert_allclose(H_init_norm, 4.36e3, rtol=1e-2)
        H_opt = res.get_H("opt")
        H_opt_norm = N.linalg.norm(H_opt)
        N.testing.assert_allclose(H_opt_norm, 1.47e5, rtol=1e-2)

        # Compute KKT condition numbers
        KKT_init = res.get_KKT("init")
        KKT_init_cond = N.linalg.cond(KKT_init)
        N.testing.assert_allclose(KKT_init_cond, 2.72e8, rtol=1e-2)
        KKT_opt = res.get_KKT("opt")
        KKT_opt_cond = N.linalg.cond(KKT_opt)
        N.testing.assert_allclose(KKT_opt_cond, 9.34e9, rtol=1e-2)

        # Obtain symbolic matrices and matrix functions
        res.get_J("sym")
        res.get_J("fcn")
        res.get_H("sym")
        res.get_H("fcn")
        res.get_KKT("sym")
        res.get_KKT("fcn")

class TestLocalDAECollocator2:
    
    """
    Tests pyjmi.optimization.casadi_collocation.LocalDAECollocator2.
    """
    
    @classmethod
    def setUpClass(self):
        """Compile the test models."""
        vdp_file_path = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        class_path = "VDP_pack.VDP_Opt_Bounds_Lagrange"
        self.vdp_bounds_lagrange_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Bounds_Lagrange_Renamed_Input"
        self.vdp_bounds_lagrange_renamed_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Bounds_Mayer"
        self.vdp_bounds_mayer_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Constraints_Mayer"
        self.vdp_constraints_mayer_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Initial_Equations"
        self.vdp_initial_equations_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Scaled_Min_Time"
        self.vdp_scaled_min_time_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        class_path = "VDP_pack.VDP_Opt_Unscaled_Min_Time"
        self.vdp_unscaled_min_time_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)

        class_path = "VDP_pack.VDP_Opt_Min_Time_Nonzero_Start"
        self.vdp_min_time_nonzero_start_op = \
                transfer_to_casadi_interface(class_path, vdp_file_path)
        
        cstr_file_path = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        class_path = "CSTR.CSTR"
        fmu_cstr = compile_fmu(class_path, cstr_file_path,
                               separate_process=True)
        self.cstr_model = load_fmu(fmu_cstr)
        
        class_path = "CSTR.CSTR_Opt_Bounds_Lagrange"
        self.cstr_lagrange_op = \
                transfer_to_casadi_interface(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Bounds_Mayer"
        self.cstr_mayer_op = \
                transfer_to_casadi_interface(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Dependent_Parameter"
        self.cstr_dependent_parameter_op = \
                transfer_to_casadi_interface(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Extends"
        self.cstr_extends_op = \
                transfer_to_casadi_interface(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Scaled_Min_Time"
        self.cstr_scaled_min_time_op = \
                transfer_to_casadi_interface(class_path, cstr_file_path)
        
        class_path = "CSTR.CSTR_Opt_Unscaled_Min_Time"
        self.cstr_unscaled_min_time_op = \
                transfer_to_casadi_interface(class_path, cstr_file_path)
        
        pe_file_path = os.path.join(get_files_path(), 'Modelica',
                                    'ParameterEstimation_1.mop')
        class_path = "ParEst.SecondOrder"
        fmu_second_order = compile_fmu(class_path, pe_file_path,
                                       separate_process=True)
        self.second_order_model = load_fmu(fmu_second_order)
        
        class_path = "ParEst.ParEstCasADi"
        self.second_order_par_est_op = \
                transfer_to_casadi_interface(class_path, pe_file_path)
        
        qt_file_path = os.path.join(get_files_path(), 'Modelica',
                                    'QuadTankPack.mop')
        class_path = "QuadTankPack.Sim_QuadTank"
        fmu_qt_sim = compile_fmu(class_path, qt_file_path,
                                 separate_process=True)
        self.qt_model = load_fmu(fmu_qt_sim)
        
        class_path = "QuadTankPack.QuadTank_ParEstCasADi"
        self.qt_par_est_op = \
                transfer_to_casadi_interface(class_path, qt_file_path)
        
        class_path = "QuadTankPack.QuadTank_ParEstCasADi_Degenerate"
        self.qt_par_est_degenerate_op = \
                transfer_to_casadi_interface(class_path, qt_file_path)
        
        self.algorithm = "LocalDAECollocationAlg2"
    
    @testattr(new_casadi = True)
    def test_init_traj_sim(self):
        """Test initial trajectories based on an existing simulation."""
        model = self.cstr_model
        model.reset()
        op = self.cstr_extends_op
        model.set(['c_init', 'T_init'], op.get(['c_init', 'T_init']))
        
        # Create input trajectory
        t = [0, 200]
        u = [342.85, 280]
        u_traj = N.transpose(N.vstack((t, u)))
        
        # Generate initial trajectories
        opts = model.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-8*model.nominal_continuous_states
        init_res = model.simulate(final_time=300, input=('Tc', u_traj),
                                  options=opts)
        
        # Optimize
        opts = op.optimize_options(self.algorithm)
        opts['variable_scaling'] = False
        opts['init_traj'] = init_res.result_data
        col = LocalDAECollocator2(op, opts)
        xx_init = col.get_xx_init()
        N.testing.assert_allclose(
                xx_init[col.var_indices[opts['n_e']][opts['n_cp']]['x']],
                [435.4425832, 333.42862629], rtol=1e-5)
    
    @testattr(new_casadi = True)
    def test_init_traj_opt(self):
        """Test optimizing based on an existing optimization reult."""
        op = self.vdp_bounds_lagrange_op
        
        # References values
        cost_ref = 3.19495079586595e0
        u_norm_ref = 2.80997269112246e-1
        
        # Get initial guess
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Optimize using initial guess
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, 5e-2, 5e-2)
    
    @testattr(new_casadi = True)
    def test_nominal_traj_vdp(self):
        """Test optimizing a VDP using nominal and initial trajectories."""
        op = self.vdp_bounds_lagrange_op
        
        # References values
        cost_ref_traj = 3.19495079586595e0
        u_norm_ref_traj = 2.80997269112246e-1
        cost_ref = 3.1749908234182826e0
        u_norm_ref = 2.848606420347583e-1
        
        # Get nominal and initial trajectories
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref_traj, u_norm_ref_traj)
        try:
            os.remove("vdp_nom_traj_result.txt")
        except OSError:
            pass
        os.rename("VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt",
                  "vdp_nom_traj_result.txt")
        
        # Optimize using only initial trajectories
        opts['n_e'] = 75
        opts['n_cp'] = 4
        opts['init_traj'] = ResultDymolaTextual("vdp_nom_traj_result.txt")
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Optimize using nominal and initial trajectories
        opts['nominal_traj'] = ResultDymolaTextual("vdp_nom_traj_result.txt")
        opts['nominal_traj_mode'] = {'_default_mode': "affine"}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        col = res.solver
        xx_init = col.get_xx_init()
        N.testing.assert_allclose(
                xx_init[col.var_indices[opts['n_e']][opts['n_cp']]['x']],
                [0.85693481, 0.12910473])
        
        # Test with eliminated continuity variables
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test with eliminated continuity and derivative variables
        opts['eliminate_der_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test disabling scaling
        opts['variable_scaling'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_nominal_traj_cstr(self):
        """Test optimizing a CSTR using nominal and initial trajectories."""
        op = self.cstr_lagrange_op
        
        # References values
        cost_ref_traj = 1.8549259545339369e3
        u_norm_ref_traj = 3.0455503580669716e2
        cost_ref = 1.858428662785409e3
        u_norm_ref = 3.0507636243132043e2
        
        # Get nominal and initial trajectories
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref_traj, u_norm_ref_traj)
        try:
            os.remove("cstr_nom_traj_result.txt")
        except OSError:
            pass
        os.rename("CSTR_CSTR_Opt_Bounds_Lagrange_result.txt",
                  "cstr_nom_traj_result.txt")
        
        # Optimize using only initial trajectories
        n_e = 75
        n_cp = 4
        opts['n_e'] = n_e
        opts['n_cp'] = n_cp
        opts['init_traj'] = ResultDymolaTextual("cstr_nom_traj_result.txt")
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Optimize using nominal and initial trajectories
        opts['nominal_traj'] = ResultDymolaTextual("cstr_nom_traj_result.txt")
        opts['nominal_traj_mode'] = {'_default_mode': 'time-variant'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        col = res.solver
        xx_init = col.get_xx_init()
        N.testing.assert_equal(sum(xx_init == 1.),
                               (n_e * n_cp + 1) * 3 + 2 * n_e)
        
        # Test with eliminated continuity variables
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test with eliminated continuity and derivative variables
        opts['eliminate_der_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Test disabling scaling
        opts['variable_scaling'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_nominal_traj_mode(self):
        """Test nominal_traj_mode on the CSTR."""
        op = self.cstr_lagrange_op
        
        # References values
        cost_ref = 1.8549259545339369e3
        u_norm_ref = 3.0455503580669716e2
        
        # Get nominal and initial trajectories
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 2
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        try:
            os.remove("cstr_nom_traj_result.txt")
        except OSError:
            pass
        os.rename("CSTR_CSTR_Opt_Bounds_Lagrange_result.txt",
                  "cstr_nom_traj_result.txt")
        
        # Time-variant
        opts['nominal_traj'] = ResultDymolaTextual("cstr_nom_traj_result.txt")
        opts['nominal_traj_mode'] = {'_default_mode': 'time-variant'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Affine
        opts['nominal_traj_mode'] = {'_default_mode': 'affine'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Linear
        opts['nominal_traj_mode'] = {'_default_mode': 'linear'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Attribute
        opts['nominal_traj_mode'] = {'_default_mode': 'attribute'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Check impossible time-variant scaling
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'cstr.der(c)': 'time-variant'}
        N.testing.assert_raises(CasadiCollocatorException, op.optimize,
                                self.algorithm, opts)
        
        # Check changing one variable
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'cstr.c': 'time-variant'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Check alias variables
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'cstr.Tc': 'time-variant'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'u': 'time-variant'}
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        opts['nominal_traj_mode'] = {'_default_mode': 'affine',
                                     'asdf': 'time-variant'}
        N.testing.assert_raises(XMLException, op.optimize, self.algorithm,
                                opts)
    
    @testattr(new_casadi = True)
    def test_cstr(self):
        """
        Test optimizing the CSTR.
        
        Tests both a Mayer cost with Gauss collocation and a Lagrange cost with
        Radau collocation.
        """
        mayer_op = self.cstr_mayer_op
        lagrange_op = self.cstr_lagrange_op
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.050971000653911e2
        
        # Mayer
        opts = mayer_op.optimize_options(self.algorithm)
        opts['discr'] = "LG"
        res = mayer_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Lagrange
        opts['discr'] = "LGR"
        res = lagrange_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)
    
    @testattr(new_casadi = True)
    def test_parameter_estimation(self):
        """
        Test a parameter estimation example with and without scaling.
        
        WARNING: This test is very slow when using IPOPT with the linear solver
        MUMPS.
        """
        op = self.second_order_par_est_op
        
        # Reference values
        w_ref = 1.048589
        z_ref = 0.470934
        
        # Measurements
        y_meas = N.array([0.01463904, 0.35424225, 0.94776816, 1.20116167,
                          1.17283905, 1.03631145, 1.0549561, 0.94827652,
                          1.0317119, 1.04010453, 1.08012155])
        t_meas = N.linspace(0., 10., num=len(y_meas))
        data = N.vstack([t_meas, y_meas])
        
        # Measurement data
        Q = N.array([[1.]])
        unconstrained=OrderedDict()
        unconstrained['y'] = data
        measurement_data = MeasurementData(unconstrained=unconstrained, Q=Q)
        
        # Optimize without scaling
        opts = op.optimize_options(self.algorithm)
        opts['measurement_data'] = measurement_data
        opts['variable_scaling'] = False
        opts['n_e'] = 16
        res = op.optimize(self.algorithm, opts)
        
        w_unscaled = res.final('w')
        z_unscaled = res.final('z')
        N.testing.assert_allclose(w_unscaled, w_ref, 1e-2)
        N.testing.assert_allclose(z_unscaled, z_ref, 1e-2)
        
        # Optimize with scaling
        opts['variable_scaling'] = True
        res = op.optimize(self.algorithm, opts)
        w_scaled = res.final('w')
        z_scaled = res.final('z')
        N.testing.assert_allclose(w_scaled, w_ref, 1e-2)
        N.testing.assert_allclose(z_scaled, z_ref, 1e-2)
    
    @testattr(new_casadi = True)
    def test_parameter_estimation_traj(self):
        """
        Test estimation with and without initial and nominal trajectories.
        """
        model = self.second_order_model
        model.reset()
        op = self.second_order_par_est_op
        
        # Simulate with initial guesses
        sim_model.set('w', 1.3)
        sim_model.set('z', 0.3)
        sim_res = sim_model.simulate(final_time=15.)
        
        # Reference values
        w_ref = 1.048589
        z_ref = 0.470934
        
        # Measurements
        y_meas = N.array([0.01463904, 0.35424225, 0.94776816, 1.20116167,
                          1.17283905, 1.03631145, 1.0549561, 0.94827652,
                          1.0317119, 1.04010453, 1.08012155])
        t_meas = N.linspace(0., 10., num=len(y_meas))
        data = N.vstack([t_meas, y_meas])
        
        # Measurement data
        Q = N.array([[1.]])
        unconstrained = OrderedDict()
        unconstrained['y'] = data
        measurement_data = MeasurementData(unconstrained=unconstrained, Q=Q)
        
        # Optimize without scaling
        opts = op.optimize_options(self.algorithm)
        opts['measurement_data'] = measurement_data
        opts['n_e'] = 16
        opt_res = op.optimize(self.algorithm, opts)
        
        # Assert results
        w = opt_res.final('w')
        z = opt_res.final('z')
        N.testing.assert_allclose(w, w_ref, 1e-2)
        N.testing.assert_allclose(z, z_ref, 1e-2)
        
        # Optimize with trajectories
        opts['init_traj'] = sim_res.result_data
        opts['nominal_traj'] = sim_res.result_data
        traj_res = op.optimize(self.algorithm, opts)
        w_traj = traj_res.final('w')
        z_traj = traj_res.final('z')
        N.testing.assert_allclose(w_traj, w_ref, 1e-2)
        N.testing.assert_allclose(z_traj, z_ref, 1e-2)
    
    @testattr(new_casadi = True)
    def test_qt_par_est_unconstrained(self):
        """
        Test parameter estimation for the quad tank with unconstrained inputs.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        model = self.qt_model
        model.reset()
        op = self.qt_par_est_op
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                 final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u1'] = data_u1
        unconstrained['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained)
        
        # Unconstrained
        opts = op.optimize_options()
        opts['n_e'] = 60
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, options=opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Unconstrained with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = op.optimize(self.algorithm, options=opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
    
    @testattr(new_casadi = True)
    def test_qt_par_est_eliminated(self):
        """
        Test parameter estimation for the quad tank with eliminated inputs.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        model = self.qt_model
        model.reset()
        op = self.qt_par_est_op
        op_2 = self.qt_par_est_degenerate_op
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                 final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        eliminated['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        
        # Eliminated
        opts = op.optimize_options()
        opts['n_e'] = 30
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Eliminated with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Inconsistent bound on eliminated input
        op.set_min('u1', 5.1)
        N.testing.assert_raises(CasadiCollocatorException,
                                op.optimize, self.algorithm, opts)
        op.set_min('u1', -N.inf)
        
        # Point constraint on eliminated input
        opts2 = op_2.optimize_options()
        opts2['n_e'] = 30
        opts2['init_traj'] = sim_res.result_data
        opts2['measurement_data'] = measurement_data
        N.testing.assert_raises(CasadiCollocatorException,
                                op_2.optimize, self.algorithm, opts2)
        
        # Eliminate state
        Q = N.diag([1.])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        eliminated['u2'] = data_u2
        eliminated['qt.x2'] = data_x2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        opts['measurement_data'] = measurement_data
        N.testing.assert_raises(ValueError,
                                op.optimize, self.algorithm, opts)

        # Eliminate non-existing variable
        del eliminated['qt.x2']
        eliminated['does_not_exist'] = data_x2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        opts['measurement_data'] = measurement_data
        N.testing.assert_raises(VariableNotFoundError,
                                op.optimize, self.algorithm, opts)

        # Eliminate input alias
        Q = N.diag([1., 1.])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        eliminated['qt.u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
    
    @testattr(new_casadi = True)
    def test_qt_par_est_constrained(self):
        """
        Test parameter estimation for the quad tank with constrained inputs.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        model = self.qt_model
        model.reset()
        op = self.qt_par_est_op
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                 final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        constrained = OrderedDict()
        constrained['u1'] = data_u1
        constrained['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           constrained=constrained)
        
        # Constrained
        opts = op.optimize_options()
        opts['n_e'] = 30
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Constrained with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-3)
        
        # Inconsistent bound on constrained input
        op.set_min('u1', 5.1)
        N.testing.assert_raises(CasadiCollocatorException,
                                op.optimize, self.algorithm, opts)
        op.set_min('u1', -N.inf)
        
        # Constrain state
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        constrained = OrderedDict()
        constrained['u1'] = data_u1
        constrained['u2'] = data_u2
        constrained['qt.x2'] = data_x2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           constrained=constrained)
        opts['measurement_data'] = measurement_data
        N.testing.assert_raises(VariableNotFoundError,
                                op.optimize, self.algorithm, opts)
    
    @testattr(new_casadi = True)
    def test_qt_par_est_semi_eliminated(self):
        """
        Test parameter estimation for the quad tank with 1 eliminated input.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        model = self.qt_model
        model.reset()
        op = self.qt_par_est_op
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u1 = N.vstack([t_meas, u1])
        data_u2 = N.vstack([t_meas, u2])
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u1'] = data_u1
        eliminated = OrderedDict()
        eliminated['u2'] = data_u2
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        
        # Eliminate u2
        opts = op.optimize_options()
        opts['n_e'] = 60
        opts['init_traj'] = sim_res.result_data
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Eliminate u2 with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Eliminate u1
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u2'] = data_u2
        eliminated = OrderedDict()
        eliminated['u1'] = data_u1
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        opts['nominal_traj'] = None
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Eliminate u1 with nominal trajectories
        opts['nominal_traj'] = sim_res.result_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
    
    @testattr(new_casadi = True)
    def test_qt_par_est_user_interpolator(self):
        """
        Test parameter estimation for the quad tank with user-defined function.
        """
        data = loadmat(path_to_data + '/qt_par_est_data.mat', appendmat=False)
        model = self.qt_model
        model.reset()
        op = self.qt_par_est_op
        a_ref = [0.02656702, 0.02713898]
        
        # Extract data series
        t_meas = data['t'][6000::100, 0] - 60
        y1_meas = data['y1_f'][6000::100, 0]/100
        y2_meas = data['y2_f'][6000::100, 0]/100
        y3_meas = data['y3_d'][6000::100, 0]/100
        y4_meas = data['y4_d'][6000::100, 0]/100
        u1 = data['u1_d'][6000::100, 0]
        u2 = data['u2_d'][6000::100, 0]
        
        # Simulate
        u = N.transpose(N.vstack((t_meas, u1, u2)))
        sim_res = model.simulate(input=(['u1', 'u2'], u), start_time=0.,
                                     final_time=60.)
        
        # Create measurement data
        Q = N.diag([1., 1., 10.])
        data_x1 = N.vstack([t_meas, y1_meas])
        data_x2 = N.vstack([t_meas, y2_meas])
        data_u2 = N.vstack([t_meas, u2])
        linear_u1 = TrajectoryLinearInterpolation(t_meas,
                                                  u1.reshape([-1, 1]))
        user_u1 = linear_u1.eval
        unconstrained = OrderedDict()
        unconstrained['qt.x1'] = data_x1
        unconstrained['qt.x2'] = data_x2
        unconstrained['u2'] = data_u2
        eliminated = OrderedDict()
        eliminated['u1'] = user_u1
        measurement_data = MeasurementData(Q=Q,
                                           unconstrained=unconstrained,
                                           eliminated=eliminated)
        
        # Semi-eliminated with user-defined interpolation function
        opts = op.optimize_options()
        opts['n_e'] = 60
        opts['measurement_data'] = measurement_data
        opt_res = op.optimize(self.algorithm, opts)
        N.testing.assert_allclose(1e4 * N.array([opt_res.final("qt.a1"),
                                                 opt_res.final("qt.a2")]),
                                  a_ref, rtol=1e-4)
        
        # Inconsistent bounds on eliminated input with user-defined function
        op.set_min('u1', 5.1)
        N.testing.assert_raises(CasadiCollocatorException,
                                op.optimize, self.algorithm, opts)
        op.set_min('u1', -N.inf)
    
    @testattr(new_casadi = True)
    def test_vdp_minimum_time(self):
        """
        Test solving minimum time problems based on the VDP oscillator.
        
        Tests one problem where the time is manually scaled. Tests two where
        the time is automatically scaled by the compiler, where one of them
        starts at time 0 and the other starts at time 5.
        """
        scaled_op = self.vdp_scaled_min_time_op
        unscaled_op = self.vdp_unscaled_min_time_op
        nonzero_start_op = \
                self.vdp_min_time_nonzero_start_op
        
        # References values
        cost_ref = 2.2811590707107996e0
        u_norm_ref = 9.991517452037317e-1
        
        # Scaled, Radau
        opts = scaled_op.optimize_options(self.algorithm)
        opts['discr'] = "LGR"
        res = scaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Scaled, Gauss
        opts['discr'] = "LG"
        res = scaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        
        # Unscaled, Radau
        opts['discr'] = "LGR"
        res = unscaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        
        # Unscaled, Gauss
        opts['discr'] = "LG"
        res = unscaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

        # Unscaled, non-zero start, Radau
        opts['discr'] = "LGR"
        res = nonzero_start_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        N.testing.assert_allclose(res['time'][[0, -1]], [5., 7.28115907],
                                  rtol=5e-3)
        
        # Unscaled, non-zero start, Gauss
        opts['discr'] = "LG"
        res = nonzero_start_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        N.testing.assert_allclose(res['time'][[0, -1]], [5., 7.28128126],
                                  rtol=5e-3)
    
    @testattr(new_casadi = True)
    def test_cstr_minimum_time(self):
        """
        Test solving minimum time problems based on the CSTR.
        
        Tests both a problem where the time is manually scaled, and one where
        the time is automatically scaled by the compiler.
        """
        scaled_op = self.cstr_scaled_min_time_op
        unscaled_op = self.cstr_unscaled_min_time_op
        
        # References values
        cost_ref = 1.1637020114180874e2
        u_norm_ref = 3.0668821961641106e2
        
        # Scaled, Radau
        opts = scaled_op.optimize_options(self.algorithm)
        opts['discr'] = "LGR"
        res = scaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, input_name="Tc")
        
        # Scaled, Gauss
        opts['discr'] = "LG"
        res = scaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2,
                       input_name="Tc")
        
        # Unscaled, Radau
        opts['discr'] = "LGR"
        res = unscaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2,
                       input_name="Tc")
        
        # Unscaled, Gauss
        opts['discr'] = "LG"
        res = unscaled_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=1e-2,
                       input_name="Tc")
    
    @testattr(new_casadi = True)
    def test_path_constraints(self):
        """Test a simple path constraint with and without exact Hessian."""
        op = self.vdp_constraints_mayer_op
        
        # References values
        cost_ref = 5.273481330869811e0
        u_norm_ref = 3.2936323844551e-1
        
        # Without exact Hessian
        opts = op.optimize_options(self.algorithm)
        opts['IPOPT_options']['hessian_approximation'] = "limited-memory"
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # With exact Hessian
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_initial_equations(self):
        """Test initial equations with and without eliminated derivatives."""
        op = self.vdp_initial_equations_op
        
        # References values
        cost_ref = 4.7533158101416788e0
        u_norm_ref = 5.18716394291585e-1
        
        # Without derivative elimination
        opts = op.optimize_options(self.algorithm)
        opts['eliminate_der_var'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # With derivative elimination
        opts['eliminate_der_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_element_lengths(self):
        """Test non-uniformly distributed elements."""
        op = self.vdp_bounds_mayer_op
        
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 23
        opts['hs'] = N.array(4 * [0.01] + 2 * [0.05] + 10 * [0.02] +
                             5 * [0.02] + 2 * [0.28])
        res = op.optimize(self.algorithm, opts)
        assert_results(res, 3.174936706809e0, 3.707273799325e-1)
    
    @testattr(new_casadi = True)
    def test_free_element_lengths(self):
        """Test optimized element lengths with both result modes."""
        op = self.vdp_bounds_mayer_op
        
        # References values
        cost_ref = 4.226631156609e0
        u_norm_ref = 3.985402379035029e-1
        
        # Free element lengths data
        c = 0.5
        Q = N.eye(3)
        bounds = (0.5, 2.0)
        free_ele_data = FreeElementLengthsData(c, Q, bounds)
        
        # Set options shared by both result modes
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 20
        opts['hs'] = "free"
        opts['free_element_lengths_data'] = free_ele_data
        
        # Collocation points
        opts['result_mode'] = "collocation_points"
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        indices = range(1, 4) + range(opts['n_e'] - 3, opts['n_e'])
        values = N.array([0.5, 0.5, 0.5, 2.0, 2.0, 2.0])
        N.testing.assert_allclose(20. * res.h_opt[indices], values, 5e-3)
        
        # Element interpolation
        opts['result_mode'] = "element_interpolation"
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=3e-2)
    
    @testattr(new_casadi = True)
    def test_rename_vars(self):
        """
        Test variable renaming.

        This test is by no means thorough.
        """
        op = self.vdp_bounds_mayer_op
        
        # References values
        cost_ref = 1.353983656973385e0
        u_norm_ref = 2.4636859805244668e-1

        # Common options
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 2

        # Without renaming
        opts['rename_vars'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)

        # With renaming
        opts['rename_vars'] = True
        res_renaming = op.optimize(self.algorithm, opts)
        assert_results(res_renaming, cost_ref, u_norm_ref)

        assert(repr(res_renaming.solver.get_equality_constraint()[10]) ==
                "Matrix<SX>((der_x1_1_1-((((1-sq(x2_1_1))*x1_1_1)" +
                "-x2_1_1)+u_1_1)))")
        assert(repr(res_renaming.solver.get_equality_constraint()[20]) ==
                "Matrix<SX>((((((-3*x2_1_0)+(5.53197*x2_1_1))+" +
                "(-7.53197*x2_1_2))+(5*x2_1_3))-(10*der_x2_1_3)))")
    
    @testattr(new_casadi = True)
    def test_scaling(self):
        """
        Test optimizing the CSTR with and without scaling.

        This test also tests writing both the unscaled and scaled result,
        eliminating derivative variables and setting nominal values
        post-compilation.
        """
        op = self.cstr_lagrange_op
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.0556730059e2
        
        # Unscaled variables, with derivatives
        opts = op.optimize_options(self.algorithm)
        opts['variable_scaling'] = False
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)

        # Scaled variables, unscaled result
        # Eliminated derivatives
        opts['variable_scaling'] = True
        opts['write_scaled_result'] = False
        opts['eliminate_der_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_unscaled = res['cstr.c']

        # Scaled variables, scaled result
        # Eliminated derivatives
        opts['variable_scaling'] = True
        opts['write_scaled_result'] = True
        opts['eliminate_der_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        c_scaled = res['cstr.c']
        N.testing.assert_allclose(c_unscaled, 1000. * c_scaled,
                                  rtol=0, atol=1e-5)
        
        # Scaled variables, scaled result, with updated nominal value
        # Eliminated derivatives
        op.set_nominal('cstr.c', 500.)
        res = op.optimize(self.algorithm, opts)
        op.set_nominal('cstr.c', 1000.)
        assert_results(res, cost_ref, u_norm_ref)
        c_scaled = res['cstr.c']
        N.testing.assert_allclose(c_unscaled, 500. * c_scaled,
                                  rtol=0, atol=1e-5)
    
    @testattr(new_casadi = True)
    def test_result_file_name(self):
        """
        Test different result file names.
        """
        op = self.vdp_bounds_lagrange_op
        
        # Default file name
        try:
            os.remove("VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        except OSError:
            pass
        op.optimize(self.algorithm)
        assert(os.path.exists("VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt"))
        
        # Custom file name
        opts = op.optimize_options(self.algorithm)
        opts['result_file_name'] = "vdp_custom_file_name.txt"
        try:
            os.remove("vdp_custom_file_name.txt")
        except OSError:
            pass
        op.optimize(self.algorithm, opts)
        assert(os.path.exists("vdp_custom_file_name.txt"))
    
    @testattr(new_casadi = True)
    def test_result_mode(self):
        """
        Test the two different result modes.
        
        The difference between the trajectories of the three result modes
        should be very small if n_e * n_cp is sufficiently large. Eliminating
        derivative variables is also tested.
        """
        op = self.vdp_bounds_lagrange_op
        
        # References values
        cost_ref = 3.17495094634053e0
        u_norm_ref = 2.84538299160e-1
        
        # Collocation points
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 100
        opts['n_cp'] = 5
        opts['result_mode'] = "collocation_points"
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Element interpolation
        opts['result_mode'] = "element_interpolation"
        opts['eliminate_der_var'] = True
        opts['n_eval_points'] = 15
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)
        
        # Mesh points
        opts['result_mode'] = "mesh_points"
        opts['n_eval_points'] = 20 # Reset to default
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)
    
    @testattr(new_casadi = True)
    def test_parameter_setting(self):
        """
        Test setting parameters post-compilation.
        """
        op = self.cstr_dependent_parameter_op
        
        # Reference values
        cost_ref_low = 1.2391821615924346e3
        u_norm_ref_low = 2.833724580055005e2
        cost_ref_default = 1.8576873858261e3
        u_norm_ref_default = 3.0556730059139556e2
        
        # Test lower EdivR
        op.model.getVariable('cstr.EdivR').setAttribute(
                "bindingExpression", 8200)
        res_low = op.optimize(self.algorithm)
        assert_results(res_low, cost_ref_low, u_norm_ref_low)
        
        # Test default EdviR
        op.model.getVariable('cstr.EdivR').setAttribute(
                "bindingExpression", 8750)
        res_default = op.optimize(self.algorithm)
        assert_results(res_default, cost_ref_default, u_norm_ref_default)

        # Test dependent parameter setting
        N.testing.assert_raises(RuntimeError,
                op.model.getVariable('cstr.F').setAttribute,
                "bindingExpression", 500)
    
    @testattr(new_casadi = True)
    def test_blocking_factors(self):
        """Test blocking factors."""
        op = self.vdp_bounds_lagrange_op
        
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 40
        opts['n_cp'] = 3
        opts['blocking_factors'] = N.array(opts['n_e'] * [1])
        res = op.optimize(self.algorithm, opts)
        assert_results(res, 3.3109070531151135e0, 2.8718067708687645e-1,
                       cost_rtol=8e-2, u_norm_rtol=3e-2)
        
        opts['n_e'] = 20
        opts['n_cp'] = 4
        opts['blocking_factors'] = [1, 2, 1, 1, 2, 13]
        res = op.optimize(self.algorithm, opts)
        assert_results(res, 3.620908059907745e0, 3.049446667587375e-1,
                       cost_rtol=8e-2, u_norm_rtol=3e-2)
    
    @testattr(new_casadi = True)
    def test_eliminate_der_var(self):
        """
        Test that results are consistent regardless of eliminate_der_var.
        """
        mayer_op = self.vdp_bounds_mayer_op
        lagrange_op = self.vdp_bounds_lagrange_op
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref = 2.8723837585e-1
        
        # Keep derivative variables
        opts = lagrange_op.optimize_options(self.algorithm)
        opts["eliminate_der_var"] = False
        res = lagrange_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Mayer, eliminate derivative variables
        opts["eliminate_der_var"] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        res = mayer_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Kagrange, eliminate derivative variables
        res = lagrange_op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_eliminate_cont_var(self):
        """
        Test that results are consistent regardless of eliminate_cont_var.
        
        This is tested for both Gauss and Radau collocation.
        """
        op = self._vdp_bounds_mayerop
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref_radau = 2.8723837585e-1
        u_norm_ref_gauss = 2.852405405154352e-1
        
        # Keep continuity variables, Radau
        opts = op.optimize_options(self.algorithm)
        opts['discr'] = "LGR"
        opts["eliminate_cont_var"] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_radau)
        
        # Eliminate continuity variables, Radau
        opts["eliminate_cont_var"] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Mayer_result.txt")
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_radau)
        
        # Keep continuity variables, Gauss
        opts['discr'] = "LG"
        opts["eliminate_cont_var"] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_gauss)
        
        # Eliminate continuity variables, Gauss
        opts["eliminate_cont_var"] = True
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Mayer_result.txt")
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref_gauss)
    
    @testattr(new_casadi = True)
    def test_quadrature_constraint(self):
        """
        Test that optimization results of the CSTR is consistent regardless of
        quadrature_constraint and eliminate_cont_var for Gauss collocation.
        """
        op = self.cstr_mayer_op
        
        # References values
        cost_ref = 1.8576873858261e3
        u_norm_ref = 3.050971000653911e2
        
        # Quadrature constraint, with continuity variables
        opts = op.optimize_options(self.algorithm)
        opts['discr'] = "LG"
        opts['quadrature_constraint'] = True
        opts['eliminate_cont_var'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Quadrature constraint, without continuity variables
        opts['quadrature_constraint'] = True
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Evaluation constraint, with continuity variables
        opts['quadrature_constraint'] = False
        opts['eliminate_cont_var'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Evaluation constraint, without continuity variables
        opts['quadrature_constraint'] = False
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_n_cp(self):
        """
        Test varying n_e and n_cp.
        """
        op = self.vdp_bounds_mayer_op
        opts = op.optimize_options(self.algorithm)
        
        # n_cp = 1
        opts['n_e'] = 100
        opts['n_cp'] = 1
        res = op.optimize(self.algorithm, opts)
        assert_results(res, 2.58046279958e0, 2.567510746260e-1)
        
        # n_cp = 3
        opts['n_e'] = 50
        opts['n_cp'] = 3
        res = op.optimize(self.algorithm, opts)
        assert_results(res, 3.1761957722665e0, 2.87238440058e-1)
        
        # n_cp = 8
        opts['n_e'] = 20
        opts['n_cp'] = 8
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Mayer_result.txt")
        res = op.optimize(self.algorithm, opts)
        assert_results(res, 3.17620203643878e0, 2.803233013e-1)
        
    @testattr(new_casadi = True)
    def test_graphs_and_hessian(self):
        """
        Test that results are consistent regardless of graph and Hessian.
        
        The test also checks the elimination of derivative and continuity
        variables.
        """
        op = self.vdp_bounds_lagrange_op
        
        # References values
        cost_ref = 3.17619580332244e0
        u_norm_ref = 2.8723837585e-1
        
        # Solve problem to get initialization trajectory
        opts = op.optimize_options(self.algorithm)
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        opts['init_traj'] = ResultDymolaTextual(
                "VDP_pack_VDP_Opt_Bounds_Lagrange_result.txt")
        
        # SX with exact Hessian and eliminated variables
        opts['graph'] = "SX"
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # SX without exact Hessian and eliminated variables
        opts['IPOPT_options']['hessian_approximation'] = "limited-memory"
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = op.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.9 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # Expanded MX with exact Hessian and eliminated variables
        opts['graph'] = "MX"
        opts['IPOPT_options']['expand'] = True
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        sol_with = res.times['sol']
        assert_results(res, cost_ref, u_norm_ref)
        
        # Expanded MX without exact Hessian and eliminated variables
        opts['IPOPT_options']['hessian_approximation'] = "limited-memory"
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = op.optimize(self.algorithm, opts)
        sol_without = res.times['sol']
        nose.tools.assert_true(sol_with < 0.9 * sol_without)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX with exact Hessian and eliminated variables
        opts['IPOPT_options']['expand'] = False
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = True
        opts['eliminate_cont_var'] = True
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
        
        # MX without exact Hessian and eliminated variables
        opts['IPOPT_options']['hessian_approximation'] = "exact"
        opts['eliminate_der_var'] = False
        opts['eliminate_cont_var'] = False
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref)
    
    @testattr(new_casadi = True)
    def test_ipopt_statistics(self):
        """
        Test getting IPOPT statistics
        """
        op = self.vdp_bounds_mayer_op
        
        cost_ref = 3.17619580332244e0
        
        res = op.optimize()
        (return_status, nbr_iter, objective, total_exec_time) = \
                res.solver.get_ipopt_statistics()
        N.testing.assert_string_equal(return_status, "Solve_Succeeded")
        N.testing.assert_array_less([nbr_iter, -nbr_iter], [100, -5])
        N.testing.assert_allclose(objective, cost_ref, 1e-3, 1e-4)
        N.testing.assert_array_less([total_exec_time, -total_exec_time],
                                    [1., 0.])
    
    @testattr(new_casadi = True)
    def test_input_interpolator(self):
        """
        Test the input interpolator for simulation purposes
        """
        model = self.cstr_model
        model.reset()
        op = self.cstr_extends_op
        model.set(['c_init', 'T_init'], op.get(['c_init', 'T_init']))
        
        # Optimize
        opts = op.optimize_options(self.algorithm)
        opts['n_e'] = 100        
        opt_res = op.optimize(options=opts)
        
        # Simulate
        opt_input = opt_res.solver.get_opt_input()
        opts = model.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-8 * model.nominal_continuous_states
        res = model.simulate(start_time=0., final_time=150., input=opt_input,
                             options=opts)
        N.testing.assert_allclose([res.final("T"), res.final("c")],
                                  [284.62140206, 345.22510435], rtol=5e-4)

    @testattr(new_casadi = True)
    def test_matrix_evaluations(self):
        """
        Test evaluating NLP matrices.
        """
        op = self.cstr_lagrange_op

        # References values
        cost_ref = 1.852527678e3
        u_norm_ref = 3.045679e2

        # Solve
        opts = op.optimize_options()
        opts['n_e'] = 20
        res = op.optimize(self.algorithm, opts)
        assert_results(res, cost_ref, u_norm_ref, u_norm_rtol=5e-3)

        # Compute Jacobian condition numbers
        J_init = res.get_J("init")
        J_init_cond = N.linalg.cond(J_init)
        N.testing.assert_allclose(J_init_cond, 2.93e4, rtol=1e-2)
        J_opt = res.get_J("opt")
        J_opt_cond = N.linalg.cond(J_opt)
        N.testing.assert_allclose(J_opt_cond, 2.47e6, rtol=1e-2)

        # Compute Hessian norms
        H_init = res.get_H("init")
        H_init_norm = N.linalg.norm(H_init)
        N.testing.assert_allclose(H_init_norm, 4.36e3, rtol=1e-2)
        H_opt = res.get_H("opt")
        H_opt_norm = N.linalg.norm(H_opt)
        N.testing.assert_allclose(H_opt_norm, 1.47e5, rtol=1e-2)

        # Compute KKT condition numbers
        KKT_init = res.get_KKT("init")
        KKT_init_cond = N.linalg.cond(KKT_init)
        N.testing.assert_allclose(KKT_init_cond, 2.72e8, rtol=1e-2)
        KKT_opt = res.get_KKT("opt")
        KKT_opt_cond = N.linalg.cond(KKT_opt)
        N.testing.assert_allclose(KKT_opt_cond, 9.34e9, rtol=1e-2)

        # Obtain symbolic matrices and matrix functions
        res.get_J("sym")
        res.get_J("fcn")
        res.get_H("sym")
        res.get_H("fcn")
        res.get_KKT("sym")
        res.get_KKT("fcn")

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

        nose.tools.assert_almost_equal(res.final("y1"), 0.5000000000, places=5)
        nose.tools.assert_almost_equal(res.final("y2"), 1.124170946790, places=5)
        nose.tools.assert_almost_equal(res.final("u"), 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)

        nose.tools.assert_almost_equal(res.final("y1"), 0.5000000000, places=5)
        nose.tools.assert_almost_equal(res.final("y2"), 1.124170946790, places=5)
        nose.tools.assert_almost_equal(res.final("u"), 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)

        nose.tools.assert_almost_equal(res.final("y1"), 0.5000000000, places=5)
        nose.tools.assert_almost_equal(res.final("y2"), 1.124170946790, places=5)
        nose.tools.assert_almost_equal(res.final("u"), 0.498341205247, places=5)
    
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

        nose.tools.assert_almost_equal(res.final("y1"), 0.5000000000, places=5)
        nose.tools.assert_almost_equal(res.final("y2"), 1.124170946790, places=5)
        nose.tools.assert_almost_equal(res.final("u"), 0.498341205247, places=5)
        
        #Test LGL points
        opts['discr'] = "LGL"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)

        nose.tools.assert_almost_equal(res.final("y1"), 0.5000000000, places=5)
        nose.tools.assert_almost_equal(res.final("y2"), 1.124170946790, places=5)
        nose.tools.assert_almost_equal(res.final("u"), 0.498341205247, places=5)
        
        #Test LGR points
        opts['discr'] = "LGR"
        opts['init_traj'] = ResultDymolaTextual("TwoState_result.txt")
        res = self.model_two_state.optimize(algorithm="CasadiPseudoSpectralAlg",
                                            options=opts)

        nose.tools.assert_almost_equal(res.final("y1"), 0.5000000000, places=5)
        nose.tools.assert_almost_equal(res.final("y2"), 1.124170946790, places=5)
        nose.tools.assert_almost_equal(res.final("u"), 0.498341205247, places=5)
    
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
        nose.tools.assert_almost_equal(res.final("cost"), 2.3463724e1, places=1)
        
        #Test LGR points
        opts['discr'] = "LGR"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectralAlg",
                                      options=opts)
        nose.tools.assert_almost_equal(res.final("cost"), 2.3463724e1, places=1)
        
        #Test LGL points
        """
        opts['discr'] = "LGL"
        res = self.model_vdp.optimize(algorithm="CasadiPseudoSpectralAlg",
                                      options=opts)
        nose.tools.assert_almost_equal(res.final("cost"), 2.3463724e1, places=1)
        """
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
