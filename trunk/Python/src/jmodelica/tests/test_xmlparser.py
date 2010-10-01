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

""" Test module for testing the xmlparser
"""

import os

import nose
import nose.tools
import numpy as n

from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica import xmlparser

#type defs
int = n.int32
uint = n.uint32

class TestXMLParser:
    """
    Common test class for all the XML tests.
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        # modified cstr xml
        modcstr = os.path.join(get_files_path(), 'XML','CSTR_CSTR_Opt_modified.xml')
        cls.md = xmlparser.ModelDescription(modcstr)
        
    def setUp(self):
        """
        Sets up the test case.
        """
        self.md = TestXMLParser.md

    @testattr(stddist = True)
    def test_get_fmi_version(self):
        """
        Test xmlparser.ModelDescription.get_fmi_version method.
        
        """
        nose.tools.assert_equal(self.md.get_fmi_version(), '1.0')

    @testattr(stddist = True)
    def test_get_model_name(self):
        """
        Test xmlparser.ModelDescription.get_model_name method.
        
        """
        nose.tools.assert_equal(self.md.get_model_name(), 'CSTR.CSTR_Opt')
        
    @testattr(stddist = True)
    def test_get_model_identifier(self):
        """
        Test xmlparser.ModelDescription.get_model_identifier method.
        
        """
        nose.tools.assert_equal(self.md.get_model_identifier(), 'CSTR_CSTR_Opt')

    @testattr(stddist = True)
    def test_get_guid(self):
        """
        Test xmlparser.ModelDescription.get_guid method.
        
        """
        nose.tools.assert_equal(self.md.get_guid(), '123abc')

    @testattr(stddist = True)
    def test_get_description(self):
        """
        Test xmlparser.ModelDescription.get_description method.
        
        """
        nose.tools.assert_equal(self.md.get_description(), 'Modified CSTR')

    @testattr(stddist = True)
    def test_get_author(self):
        """
        Test xmlparser.ModelDescription.get_author method.
        
        """
        nose.tools.assert_equal(self.md.get_author(), 'tester')
        
    @testattr(stddist = True)
    def test_get_version(self):
        """
        Test xmlparser.ModelDescription.get_version method.
        
        """
        nose.tools.assert_equal(self.md.get_version(), 1.0)
        
    @testattr(stddist = True)
    def test_get_generation_tool(self):
        """
        Test xmlparser.ModelDescription.get_generation_tool method.
        
        """
        nose.tools.assert_equal(self.md.get_generation_tool(), 'JModelica')
            
    @testattr(stddist = True)
    def test_get_generation_date_and_time(self):
        """
        Test xmlparser.ModelDescription.get_generation_date_and_time method.
        
        """
        nose.tools.assert_equal(self.md.get_generation_date_and_time(), '2010-05-17T14:08:53')

    @testattr(stddist = True)
    def test_get_variable_naming_convention(self):
        """
        Test xmlparser.ModelDescription.get_variable_naming_convention method.
        
        """
        nose.tools.assert_equal(self.md.get_variable_naming_convention(), 'flat')

    @testattr(stddist = True)
    def test_get_number_of_continuous_states(self):
        """
        Test xmlparser.ModelDescription.get_number_of_continuous_states method.
        
        """
        nose.tools.assert_equal(self.md.get_number_of_continuous_states(), 3)
        
    @testattr(stddist = True)
    def test_get_number_of_event_indicators(self):
        """
        Test xmlparser.ModelDescription.get_number_of_event_indicators method.
        
        """
        nose.tools.assert_equal(self.md.get_number_of_event_indicators(), 0)    

    @testattr(stddist = True)
    def test_get_value_reference(self):
        """
        Test xmlparser.ModelDescription.get_value_reference method.
        """
        variablename = 'cstr.T0'
        vref = 3
        nose.tools.assert_equal(self.md.get_value_reference(variablename), vref)
        
    @testattr(stddist = True)
    def test_is_alias(self):
        """
        Test xmlparser.ModelDescription.is_alias method.
        """
        variablename = 'cstr.T0'
        isalias = False
        nose.tools.assert_equal(self.md.is_alias(variablename), isalias)
        
        variablename = 'cstr.r'
        isalias = True
        nose.tools.assert_equal(self.md.is_alias(variablename), isalias)
        
        variablename = 'cstr.EdivR'
        nose.tools.assert_equal(self.md.is_alias(variablename), isalias)
        
    @testattr(stddist = True)
    def test_is_negated_alias(self):
        """
        Test xmlparser.ModelDescription.is_negated_alias method.
        """
        
        variablename = 'cstr.r'
        isnegalias = True
        nose.tools.assert_equal(self.md.is_negated_alias(variablename), 
            isnegalias)
        
        variablename = 'cstr.EdivR'
        isnegalias = False
        nose.tools.assert_equal(self.md.is_negated_alias(variablename), 
            isnegalias)
            
    @testattr(stddist = True)
    def test_is_constant(self):
        """
        Test xmlparser.ModelDescription.is_constant method.
        """
        
        variablename = 'cstr.F'
        isconst = True
        nose.tools.assert_equal(self.md.is_constant(variablename), 
            isconst)
        
        variablename = 'cstr.T0'
        isconst = False
        nose.tools.assert_equal(self.md.is_constant(variablename), 
            isconst)
            
    @testattr(stddist = True)
    def test_get_aliases(self):
        """
        Test xmlparser.get_aliases_for_variable method.
        """
        
        variablename = 'cstr.F0'
        aliases = ['cstr.c0', 'cstr.r']
        isneg = [False, True]
        
        nose.tools.assert_equal(self.md.get_aliases_for_variable(variablename), 
            (aliases, isneg))
        
    @testattr(stddist = True)
    def test_get_variable_names(self):
        """
        Test xmlparser.ModelDescription.get_variable_names method.
        
        """
        vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
        vnames = ("u", "cstr.F0", "cstr.c0", "cstr.F", "cstr.T0", "cstr.r", 
            "cstr.k0", "cstr.EdivR", "cstr.U", "cstr.rho")
            
        vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
        vnames_noalias = ("u", "cstr.F0", "cstr.F", "cstr.T0", "cstr.k0", 
            "cstr.U", "cstr.rho")
        
        # with alias
        nose.tools.assert_equal(self.md.get_variable_names(), zip(vrefs, vnames))
        
        # without alias
        nose.tools.assert_equal(self.md.get_variable_names(include_alias=False), 
            zip(vrefs_noalias, vnames_noalias))
            
    @testattr(stddist = True)
    def test_get_variable_aliases(self):
        """
        Test xmlparser.ModelDescription.get_variable_aliases method.
        
        """
        vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
        valiases = (xmlparser.NO_ALIAS, xmlparser.NO_ALIAS, xmlparser.ALIAS, 
            xmlparser.NO_ALIAS, xmlparser.NO_ALIAS, xmlparser.NEGATED_ALIAS, 
            xmlparser.NO_ALIAS, xmlparser.ALIAS, xmlparser.NO_ALIAS, 
            xmlparser.NO_ALIAS)
            
        nose.tools.assert_equal(self.md.get_variable_aliases(), zip(vrefs, valiases))
        
    @testattr(stddist = True)
    def test_get_variable_descriptions(self):
        """
        Test xmlparser.ModelDescription.get_variable_descriptions method.
        
        """
        vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
        vdesc = ("", "Inflow", "Concentration of inflow", "Outflow", "", "", 
            "", "", "", "")
            
        vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
        vdesc_noalias = ("", "Inflow", "Outflow", "", "", "", "")
        
        # with alias
        nose.tools.assert_equal(self.md.get_variable_descriptions(), zip(vrefs, vdesc))
        
        # without alias
        nose.tools.assert_equal(self.md.get_variable_descriptions(include_alias=False), 
            zip(vrefs_noalias, vdesc_noalias))
        
    @testattr(stddist = True)
    def test_get_variable_variabilities(self):
        """
        Test xmlparser.ModelDescription.get_variable_variabilities method.
        
        """
        vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
        vvars = (xmlparser.CONTINUOUS, xmlparser.PARAMETER, 
            xmlparser.PARAMETER, xmlparser.CONSTANT, xmlparser.PARAMETER, 
            xmlparser.PARAMETER, xmlparser.DISCRETE, xmlparser.DISCRETE, 
            xmlparser.PARAMETER, xmlparser.CONTINUOUS)
            
        vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
        vvars_noalias = (xmlparser.CONTINUOUS, xmlparser.PARAMETER, 
            xmlparser.CONSTANT, xmlparser.PARAMETER, xmlparser.DISCRETE, 
            xmlparser.PARAMETER, xmlparser.CONTINUOUS)
        
        # with alias
        nose.tools.assert_equal(self.md.get_variable_variabilities(), zip(vrefs, vvars))
        
        # without alias
        nose.tools.assert_equal(self.md.get_variable_variabilities(include_alias=False), 
            zip(vrefs_noalias, vvars_noalias))

        
    @testattr(stddist = True)
    def test_get_variable_nominal_attributes(self):
        """
        Test xmlparser.ModelDescription.get_variable_nominal_attributes method.
        
        """
        vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
        vnom = (3.14, 3.14, None, None, None, 10.0, None, None, None, 5)
            
        vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
        vnom_noalias = (3.14, 3.14, None, None, None, None, 5)
        
        # with alias
        nose.tools.assert_equal(self.md.get_variable_nominal_attributes(), zip(vrefs, vnom))
        
        # without alias
        nose.tools.assert_equal(self.md.get_variable_nominal_attributes(include_alias=False), 
            zip(vrefs_noalias, vnom_noalias))

    @testattr(stddist = True)
    def test_get_variable_start_attributes(self):
        """
        Test xmlparser.ModelDescription.get_variable_start_attributes method.
        
        """
        vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
        vstart = (350.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 0.0)
            
        vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
        vstart_noalias = (350.0, 0.0, 0.0, 0.0, 0.0, 10.0, 0.0)
        
        # with alias
        nose.tools.assert_equal(self.md.get_variable_start_attributes(), zip(vrefs, vstart))
        
        # without alias
        nose.tools.assert_equal(self.md.get_variable_start_attributes(include_alias=False), 
            zip(vrefs_noalias, vstart_noalias))

    @testattr(stddist = True)
    def test_get_p_opt_variable_names(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_variable_names method.
        
        """
        vrefs = (0, 7)
        vnames = ('cstr.F0', 'cstr.U')
            
        vrefs_noalias = (0, 7)
        vnames_noalias = ('cstr.F0', 'cstr.U')
        
        # with alias
        nose.tools.assert_equal(self.md.get_p_opt_variable_names(), zip(vrefs, vnames))
        
        # without alias
        nose.tools.assert_equal(self.md.get_p_opt_variable_names(include_alias=False), 
            zip(vrefs_noalias, vnames_noalias))

    @testattr(stddist = True)
    def test_get_dx_variable_names(self):
        """
        Test xmlparser.ModelDescription.get_dx_variable_names method.
        
        """
        vrefs = (8,)
        vnames = ('cstr.rho',)
            
        vrefs_noalias = (8,)
        vnames_noalias = ('cstr.rho',)
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_variable_names(), zip(vrefs, vnames))
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_variable_names(include_alias=False), 
            zip(vrefs_noalias, vnames_noalias))

    @testattr(stddist = True)
    def test_get_x_variable_names(self):
        """
        Test xmlparser.ModelDescription.get_x_variable_names method.
        
        """
        vrefs = (5,)
        vnames = ('cstr.k0',)
            
        vrefs_noalias = (5,)
        vnames_noalias = ('cstr.k0',)
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_variable_names(), zip(vrefs, vnames))
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_variable_names(include_alias=False), 
            zip(vrefs_noalias, vnames_noalias))
            
    @testattr(stddist = True)
    def test_get_u_variable_names(self):
        """
        Test xmlparser.ModelDescription.get_u_variable_names method.
        
        """
        vrefs = (26,)
        vnames = ('u',)
            
        vrefs_noalias = (26,)
        vnames_noalias = ('u',)
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_variable_names(), zip(vrefs, vnames))
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_variable_names(include_alias=False), 
            zip(vrefs_noalias, vnames_noalias))

    @testattr(stddist = True)
    def test_get_w_variable_names(self):
        """
        Test xmlparser.ModelDescription.get_w_variable_names method.
        
        """
        vrefs = (2,)
        vnames = ('cstr.F',)
            
        vrefs_noalias = (2,)
        vnames_noalias = ('cstr.F',)
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_variable_names(), zip(vrefs, vnames))
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_variable_names(include_alias=False), 
            zip(vrefs_noalias, vnames_noalias))


    @testattr(stddist = True)
    def test_get_p_opt_start(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_start method.
        
        """
        vrefs = (0, 7)
        vstart = (0.0, 10.0)
            
        vrefs_noalias = (0, 7)
        vstart_noalias = (0.0, 10.0)
        
        # with alias
        nose.tools.assert_equal(self.md.get_p_opt_start(), zip(vrefs, vstart))
        
        # without alias
        nose.tools.assert_equal(self.md.get_p_opt_start(include_alias=False), 
            zip(vrefs_noalias, vstart_noalias))

    @testattr(stddist = True)
    def test_get_dx_start(self):
        """
        Test xmlparser.ModelDescription.get_dx_start method.
        
        """
        vrefs = (8,)
        vstart = (0.0,)
            
        vrefs_noalias = (8,)
        vstart_noalias = (0.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_start(), zip(vrefs, vstart))
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_start(include_alias=False), 
            zip(vrefs_noalias, vstart_noalias))

    @testattr(stddist = True)
    def test_get_x_start(self):
        """
        Test xmlparser.ModelDescription.get_x_start method.
        
        """
        vrefs = (5,)
        vstart = (0.0,)
            
        vrefs_noalias = (5,)
        vstart_noalias = (0.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_start(), zip(vrefs, vstart))
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_start(include_alias=False), 
            zip(vrefs_noalias, vstart_noalias))
            
    @testattr(stddist = True)
    def test_get_u_start(self):
        """
        Test xmlparser.ModelDescription.get_u_start method.
        
        """
        vrefs = (26,)
        vstart = (350.0,)
            
        vrefs_noalias = (26,)
        vstart_noalias = (350.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_start(), zip(vrefs, vstart))
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_start(include_alias=False), 
            zip(vrefs_noalias, vstart_noalias))

    @testattr(stddist = True)
    def test_get_w_start(self):
        """
        Test xmlparser.ModelDescription.get_w_start method.
        
        """
        vrefs = (2,)
        vstart = (0.0,)
            
        vrefs_noalias = (2,)
        vstart_noalias = (0.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_start(), zip(vrefs, vstart))
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_start(include_alias=False), 
            zip(vrefs_noalias, vstart_noalias))

    @testattr(stddist = True)
    def test_get_p_opt_initial_guess(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_initial_guess method.
        
        """
        vrefs = (0, 7)
        vinit = (0.0, 5.0)
            
        vrefs_noalias = (0, 7)
        vinit_noalias = (0.0, 5.0)
        
        # with alias
        nose.tools.assert_equal(self.md.get_p_opt_initial_guess(), zip(vrefs, vinit))
        
        # without alias
        nose.tools.assert_equal(self.md.get_p_opt_initial_guess(include_alias=False), 
            zip(vrefs_noalias, vinit_noalias))
        
    @testattr(stddist = True)
    def test_get_dx_initial_guess(self):
        """
        Test xmlparser.ModelDescription.get_dx_initial_guess method.
        
        """
        vrefs = (8,)
        vinit = (0.0,)
            
        vrefs_noalias = (8,)
        vinit_noalias = (0.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_initial_guess(), zip(vrefs, vinit))
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_initial_guess(include_alias=False), 
            zip(vrefs_noalias, vinit_noalias))

    @testattr(stddist = True)
    def test_get_x_initial_guess(self):
        """
        Test xmlparser.ModelDescription.get_x_initial_guess method.
        
        """
        vrefs = (5,)
        vinit = (0.0,)
            
        vrefs_noalias = (5,)
        vinit_noalias = (0.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_initial_guess(), zip(vrefs, vinit))
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_initial_guess(include_alias=False), 
            zip(vrefs_noalias, vinit_noalias))

    @testattr(stddist = True)
    def test_get_u_initial_guess(self):
        """
        Test xmlparser.ModelDescription.get_u_initial_guess method.
        
        """
        vrefs = (26,)
        vinit = (350.0,)
            
        vrefs_noalias = (26,)
        vinit_noalias = (350.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_initial_guess(), zip(vrefs, vinit))
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_initial_guess(include_alias=False), 
            zip(vrefs_noalias, vinit_noalias))

    @testattr(stddist = True)
    def test_get_w_initial_guess(self):
        """
        Test xmlparser.ModelDescription.get_w_initial_guess method.
        
        """
        vrefs = (2,)
        vinit = (None,)
            
        vrefs_noalias = (2,)
        vinit_noalias = (None,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_initial_guess(), zip(vrefs, vinit))
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_initial_guess(include_alias=False), 
            zip(vrefs_noalias, vinit_noalias))

    @testattr(stddist = True)
    def test_get_p_opt_min(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_min method.
        
        """
        vrefs = (0, 7)
        vmin = (None, 0.0)
            
        vrefs_noalias = (0, 7)
        vmin_noalias = (None, 0.0)
        
        # with alias
        nose.tools.assert_equal(self.md.get_p_opt_min(), zip(vrefs, vmin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_p_opt_min(include_alias=False), 
            zip(vrefs_noalias, vmin_noalias))

    @testattr(stddist = True)
    def test_get_dx_min(self):
        """
        Test xmlparser.ModelDescription.get_dx_min method.
        
        """
        vrefs = (8,)
        vmin = (None,)
            
        vrefs_noalias = (8,)
        vmin_noalias = (None,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_min(), zip(vrefs, vmin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_min(include_alias=False), 
            zip(vrefs_noalias, vmin_noalias))

    @testattr(stddist = True)
    def test_get_x_min(self):
        """
        Test xmlparser.ModelDescription.get_x_min method.
        
        """
        vrefs = (5,)
        vmin = (1.5,)
            
        vrefs_noalias = (5,)
        vmin_noalias = (1.5,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_min(), zip(vrefs, vmin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_min(include_alias=False), 
            zip(vrefs_noalias, vmin_noalias))

    @testattr(stddist = True)
    def test_get_u_max(self):
        """
        Test xmlparser.ModelDescription.get_u_max method.
        
        """
        vrefs = (26,)
        vmin = (None,)
            
        vrefs_noalias = (26,)
        vmin_noalias = (None,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_max(), zip(vrefs, vmin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_max(include_alias=False), 
            zip(vrefs_noalias, vmin_noalias))

    @testattr(stddist = True)
    def test_get_w_max(self):
        """
        Test xmlparser.ModelDescription.get_w_max method.
        
        """
        vrefs = (2,)
        vmin = (-5.0,)
            
        vrefs_noalias = (2,)
        vmin_noalias = (-5.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_max(), zip(vrefs, vmin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_max(include_alias=False), 
            zip(vrefs_noalias, vmin_noalias))

    @testattr(stddist = True)
    def test_get_p_opt_max(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_max method.
        
        """
        vrefs = (0, 7)
        vmax = (100.0, 1000.0)
            
        vrefs_noalias = (0, 7)
        vmax_noalias = (100.0, 1000.0)
        
        # with alias
        nose.tools.assert_equal(self.md.get_p_opt_max(), zip(vrefs, vmax))
        
        # without alias
        nose.tools.assert_equal(self.md.get_p_opt_max(include_alias=False), 
            zip(vrefs_noalias, vmax_noalias))

    @testattr(stddist = True)
    def test_get_dx_max(self):
        """
        Test xmlparser.ModelDescription.get_dx_max method.
        
        """
        vrefs = (8,)
        vmax = (500.0,)
            
        vrefs_noalias = (8,)
        vmax_noalias = (500.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_max(), zip(vrefs, vmax))
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_max(include_alias=False), 
            zip(vrefs_noalias, vmax_noalias))

    @testattr(stddist = True)
    def test_get_x_max(self):
        """
        Test xmlparser.ModelDescription.get_x_max method.
        
        """
        vrefs = (5,)
        vmax = (10.0,)
            
        vrefs_noalias = (5,)
        vmax_noalias = (10.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_max(), zip(vrefs, vmax))
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_max(include_alias=False), 
            zip(vrefs_noalias, vmax_noalias))

    @testattr(stddist = True)
    def test_get_u_max(self):
        """
        Test xmlparser.ModelDescription.get_u_max method.
        
        """
        vrefs = (26,)
        vmax = (None,)
            
        vrefs_noalias = (26,)
        vmax_noalias = (None,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_max(), zip(vrefs, vmax))
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_max(include_alias=False), 
            zip(vrefs_noalias, vmax_noalias))

    @testattr(stddist = True)
    def test_get_w_max(self):
        """
        Test xmlparser.ModelDescription.get_w_max method.
        
        """
        vrefs = (2,)
        vmax = (0.0,)
            
        vrefs_noalias = (2,)
        vmax_noalias = (0.0,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_max(), zip(vrefs, vmax))
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_max(include_alias=False), 
            zip(vrefs_noalias, vmax_noalias))

    @testattr(stddist = True)
    def test_get_p_opt_islinear(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_islinear method.
        
        """
        vrefs = (0, 7)
        vlin = (True, True)
            
        vrefs_noalias = (0, 7)
        vlin_noalias = (True, True)
        
        # with alias
        nose.tools.assert_equal(self.md.get_p_opt_islinear(), zip(vrefs, vlin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_p_opt_islinear(include_alias=False), 
            zip(vrefs_noalias, vlin_noalias))

    @testattr(stddist = True)
    def test_get_dx_islinear(self):
        """
        Test xmlparser.ModelDescription.get_dx_islinear method.
        
        """
        vrefs = (8,)
        vlin = (True,)
            
        vrefs_noalias = (8,)
        vlin_noalias = (True,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_islinear(), zip(vrefs, vlin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_islinear(include_alias=False), 
            zip(vrefs_noalias, vlin_noalias))

    @testattr(stddist = True)
    def test_get_x_islinear(self):
        """
        Test xmlparser.ModelDescription.get_x_islinear method.
        
        """
        vrefs = (5,)
        vlin = (False,)
            
        vrefs_noalias = (5,)
        vlin_noalias = (False,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_islinear(), zip(vrefs, vlin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_islinear(include_alias=False), 
            zip(vrefs_noalias, vlin_noalias))

    @testattr(stddist = True)
    def test_get_u_islinear(self):
        """
        Test xmlparser.ModelDescription.get_u_islinear method.
        
        """
        vrefs = (26,)
        vlin = (False,)
            
        vrefs_noalias = (26,)
        vlin_noalias = (False,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_islinear(), zip(vrefs, vlin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_islinear(include_alias=False), 
            zip(vrefs_noalias, vlin_noalias))

    @testattr(stddist = True)
    def test_get_w_islinear(self):
        """
        Test xmlparser.ModelDescription.get_w_islinear method.
        
        """
        vrefs = (2,)
        vlin = (None,)
            
        vrefs_noalias = (2,)
        vlin_noalias = (None,)
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_islinear(), zip(vrefs, vlin))
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_islinear(include_alias=False), 
            zip(vrefs_noalias, vlin_noalias))

    @testattr(stddist = True)
    def test_get_dx_linear_timed_variables(self):
        """
        Test xmlparser.ModelDescription.get_dx_linear_timed_variables method.
        
        """
        lin_tps = [(8,[True])]
            
        lin_tps_noalias = [(8,[True])]
        
        # with alias
        nose.tools.assert_equal(self.md.get_dx_linear_timed_variables(), lin_tps)
        
        # without alias
        nose.tools.assert_equal(self.md.get_dx_linear_timed_variables(
            include_alias=False), lin_tps_noalias)

    @testattr(stddist = True)
    def test_get_x_linear_timed_variables(self):
        """
        Test xmlparser.ModelDescription.get_x_linear_timed_variables method.
        
        """
        lin_tps = [(5,[True, False])]
            
        lin_tps_noalias = [(5,[True, False])]
        
        # with alias
        nose.tools.assert_equal(self.md.get_x_linear_timed_variables(), lin_tps)
        
        # without alias
        nose.tools.assert_equal(self.md.get_x_linear_timed_variables(
            include_alias=False), lin_tps_noalias)

    @testattr(stddist = True)
    def test_get_u_linear_timed_variables(self):
        """
        Test xmlparser.ModelDescription.get_u_linear_timed_variables method.
        
        """
        lin_tps = [(26,[True])]
            
        lin_tps_noalias = [(26,[True])]
        
        # with alias
        nose.tools.assert_equal(self.md.get_u_linear_timed_variables(), lin_tps)
        
        # without alias
        nose.tools.assert_equal(self.md.get_u_linear_timed_variables(
            include_alias=False), lin_tps_noalias)

    @testattr(stddist = True)
    def test_get_w_linear_timed_variables(self):
        """
        Test xmlparser.ModelDescription.get_w_linear_timed_variables method.
        
        """
        lin_tps = [(2,[])]
            
        lin_tps_noalias = [(2,[])]
        
        # with alias
        nose.tools.assert_equal(self.md.get_w_linear_timed_variables(), lin_tps)
        
        # without alias
        nose.tools.assert_equal(self.md.get_w_linear_timed_variables(
            include_alias=False), lin_tps_noalias)
            
    @testattr(stddist = True)
    def test_get_p_opt_value_reference(self):
        """
        Test xmlparser.ModelDescription.get_p_opt_value_reference method.
        
        """
        
        vrefs = [0,7]
        nose.tools.assert_equal(self.md.get_p_opt_value_reference(), vrefs)
        
            
    @testattr(stddist = True)
    def test_get_external_libraries(self):
        """
        Test xmlparser.ModelDescription.get_external_libraries method.
        """
        
        extlib = ['addNumbers1']
        nose.tools.assert_equal(self.md.get_external_libraries(), extlib)

    @testattr(stddist = True)
    def test_get_external_includes(self):
        """
        Test xmlparser.ModelDescription.get_external_includes method.
        """
        
        extincl = ['#include \"addNumbers1.h\"']
        nose.tools.assert_equal(self.md.get_external_includes(), extincl)
        
    @testattr(stddist = True)
    def test_get_external_lib_dirs(self):
        """
        Test xmlparser.ModelDescription.get_external_lib_dirs method.
        """
        
        extlibdirs = ['/Library']
        nose.tools.assert_equal(self.md.get_external_lib_dirs(), extlibdirs)
        
    @testattr(stddist = True)
    def test_get_external_incl_dirs(self):
        """
        Test xmlparser.ModelDescription.get_external_incl_dirs method.
        """
        
        extincldirs = ['/Include']
        nose.tools.assert_equal(self.md.get_external_incl_dirs(), extincldirs)

    @testattr(stddist = True)
    def test_get_opt_starttime(self):
        """
        Test xmlparser.ModelDescription.get_opt_starttime method.
        
        """
        starttime = 0.0
        
        nose.tools.assert_equal(self.md.get_opt_starttime(), starttime)
        
    @testattr(stddist = True)
    def test_get_opt_finaltime(self):
        """
        Test xmlparser.ModelDescription.get_opt_finaltime method.
        
        """
        finaltime = 150.0
        
        nose.tools.assert_equal(self.md.get_opt_finaltime(), finaltime)
        
    @testattr(stddist = True)
    def test_get_opt_starttime_free(self):
        """
        Test xmlparser.ModelDescription.get_opt_starttime_free method.
        
        """
        starttime_free = False
        
        nose.tools.assert_equal(self.md.get_opt_starttime_free(), starttime_free)
        
    @testattr(stddist = True)
    def test_get_opt_finaltime_free(self):
        """
        Test xmlparser.ModelDescription.get_opt_finaltime_free method.
        
        """
        finaltime_free = False
        
        nose.tools.assert_equal(self.md.get_opt_finaltime_free(), finaltime_free)
        
    @testattr(stddist = True)
    def test_get_opt_timepoints(self):
        """
        Test xmlparser.ModelDescription.get_opt_timepoints method.
        
        """
        timepoints = [150.0, 150.0, 150.0]
        
        nose.tools.assert_equal(self.md.get_opt_timepoints(), timepoints)
        
    @testattr(stddist = True)
    def test_get_data_type(self):
        """
        Test xmlparser.ModelDescription.get_data_type method.
        
        """
        nose.tools.assert_equal(self.md.get_data_type('cstr.F0'), xmlparser.REAL)

    @testattr(stddist = True)
    def test_get_variability(self):
        """
        Test xmlparser.ModelDescription.get_variability method.
        
        """
        nose.tools.assert_equal(self.md.get_variability('cstr.F0'), xmlparser.PARAMETER)
