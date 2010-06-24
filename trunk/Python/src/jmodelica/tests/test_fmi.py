# -*- coding: utf-8 -*-
"""
Module containing the tests for the FMI interface.
"""
#    Copyright (C) 2010 Modelon AB
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


import warnings
import nose
import os as O
import numpy as N
import sys as S
from jmodelica.tests import testattr
from jmodelica.fmi import *

curr_dir = O.path.dirname(O.path.abspath(__file__));
path_to_fmus = O.path.join(curr_dir, 'files', 'FMUs')

@testattr(fmi = True)
def test_unzip():
    """
    This tests the functionality of the method unzip_FMU.
    """
    pass
    

class Test_FMI:
    """
    This class tests jmodelica.fmi.FMIMODEL
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        pass
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    @testattr(fmi = True)
    def test_init(self):
        """
        This tests the method __init__.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)
    def test_fmiBoolean(self):
        """
        This tests the functionality of setting/getting fmiBoolean.
        """
        raise NotImplemetedError

    @testattr(fmi = True)
    def test_fmiReal(self):
        """
        This tests the functionality of setting/getting fmiReal.
        """
        raise NotImplemetedError
    
    @testattr(fmi = True)
    def test_fmiInteger(self):
        """
        This tests the functionality of setting/getting fmiInteger.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)    
    def test_fmiString(self):
        """
        This tests the functionality of setting/getting fmiString.
        """
        raise NotImplemetedError
    
    @testattr(fmi = True)
    def test_t(self):
        """
        This tests the functionality of setting/getting t.
        """
        raise NotImplemetedError
        
        
    @testattr(fmi = True)
    def test_real_x(self):
        """
        This tests the property of real_x.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)
    def test_real_dx(self):
        """
        This tests the (get)-property of real_dx.
        """
        raise NotImplemetedError
        

    @testattr(fmi = True)
    def test_real_x_nominal(self):
        """
        This tests the (get)-property of real_x_nominal.
        """
        raise NotImplemetedError
    
    @testattr(fmi = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of valid platforms.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)
    def test_get_tolerances(self):
        """
        This tests the method get_tolerances.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)
    def test_event_indicators(self):
        """
        This tests the (get)-property of event_ind.
        """
        raise NotImplemetedError
        
    
    @testattr(fmi = True)
    def test_update_event(self):
        """
        This tests the functionality of the method update_event.
        """
        raise NotImplemetedError
        
    @testattr(fmi = True)
    def test_get_continuous_value_references(self):
        """
        This tests the functionality of the method get_continuous_value_references.
        """
        raise NotImplemetedError
        
        
    @testattr(fmi = True)
    def test_ode_get_sizes(self):
        """
        This tests the functionality of the method ode_get_sizes.
        """
        raise NotImplemetedError
    
    @testattr(fmi = True)
    def test_get_name(self):
        """
        This tests the functionality of the method get_name.
        """
        raise NotImplemetedError

