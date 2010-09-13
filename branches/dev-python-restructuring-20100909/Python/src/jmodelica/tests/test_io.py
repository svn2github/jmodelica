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

""" Test module for testing the io module
"""

import os
import os.path

import numpy as N
import nose

from jmodelica.tests import testattr
from jmodelica.tests import get_files_path

import jmodelica.jmi as jmi
import jmodelica.xmlparser as xp
import jmodelica.io
from jmodelica.optimization import ipopt
from jmodelica.fmi import *


path_to_fmus = os.path.join(get_files_path(), 'FMUs')

class TestIO:
    """Tests IO"""
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        #oc.set_boolean_option('state_start_values_fixed',True)
        #oc.set_log_level(OptimicaCompiler.LOG_ERROR)
        
        fpath = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        cpath = "VDP_pack.VDP_Opt_Min_Time"

        jmi.compile_jmu(cpath, fpath, compiler_options={'state_start_values_fixed':True})
    
    def setUp(self):
        """ 
        Setup test cases.
        """
        # Load the dynamic library and XML data
        self.fname = "VDP_pack_VDP_Opt_Min_Time.jmu"
        self.vdp = jmi.JMUModel(self.fname)
        
        
    @testattr(ipopt = True)
    def test_dymola_export_import(self):
        """
        Test for export and import the result file on Dymola textual format.
        """
        vdp = self.vdp

        # Initialize the mesh
        n_e = 50 # Number of elements 
        hs = N.ones(n_e)*1./n_e # Equidistant points
        n_cp = 3; # Number of collocation points in each element

        # Create an NLP object
        nlp = ipopt.NLPCollocationLagrangePolynomials(vdp,n_e,hs,n_cp)

        # Create an Ipopt NLP object
        nlp_ipopt = ipopt.CollocationOptimizer(nlp)

        # Solve the optimization problem
        nlp_ipopt.opt_sim_ipopt_solve()
       
        # Get the result
        p_opt, traj = nlp.get_result()

        # Write to file
        nlp.export_result_dymola()

        # Load the file we just wrote
        res = jmodelica.io.ResultDymolaTextual(self.fname[:-len('.jmu')]+'_result.txt')

        # Check that one of the trajectories match.
        assert max(N.abs(traj[:,3]-res.get_variable_data('x1').x))<1e-12, \
               "The result in the loaded result file does not match that of the loaded file."        

        # Check that the value of the cost function is correct
        assert N.abs(p_opt[0]-2.2811587)<1e-5, \
               "The optimal value is not correct."

    @testattr(assimulo = True)
    def test_parameter_alias(self):
        """ Test simulate and write to file when model has parameter alias.
            (Test so that write to file does not crash.)
        """
        model_file = os.path.join(get_files_path(), 'Modelica', 'ParameterAlias.mo')
        jmi.compile_jmu('ParameterAlias', model_file)
        model = jmi.JMUModel('ParameterAlias.jmu')
        model.simulate()

class test_ResultWriterDymola:
    """Tests the class ResultWriterDymola."""
    
    def setUp(self):
        """
        Sets up the test case.
        """
        self._bounce  = FMUModel('bouncingBall.fmu',path_to_fmus)
        self._dq = FMUModel('dq.fmu',path_to_fmus)
        self._bounce.initialize()
        self._dq.initialize()
        
    @testattr(fmi = True)
    def test_work_flow(self):
        """Tests the work flow of write_header, write_point, write_finalize."""
        
        
        bouncingBall = jmodelica.io.ResultWriterDymola(self._bounce)
        
        bouncingBall.write_header()
        bouncingBall.write_point()
        bouncingBall.write_finalize()
        
        res = jmodelica.io.ResultDymolaTextual('bouncingBall_result.txt')
        
        h = res.get_variable_data('h')
        derh = res.get_variable_data('der(h)')
        g = res.get_variable_data('g')
        
        nose.tools.assert_almost_equal(h.x, 1.000000, 5)
        nose.tools.assert_almost_equal(derh.x, 0.000000, 5)
        nose.tools.assert_almost_equal(g.x, 9.810000, 5)
