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

"""
Module containing the tests for the FMI interface.
"""

import nose
import os as O
import numpy as N
import sys as S
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica.fmi import *
from jmodelica.core import unzip_unit
import jmodelica.algorithm_drivers as ad

path_to_fmus = O.path.join(get_files_path(), 'FMUs')

@testattr(fmi = True)
def test_unzip():
    """
    This tests the functionality of the method unzip_FMU.
    """
    platform = sys.platform
    
    #FMU
    fmu = 'bouncingBall.fmu'
    
    #Unzip FMU
    tempnames = unzip_unit(archive=fmu, path=path_to_fmus)
    tempdll = tempnames[0]
    tempxml = tempnames[1]
    modelname = tempnames[2]
    
    if platform == 'win32':
        assert tempdll.endswith('.dll')
    elif platform == 'darwin':
        assert tempdll.endswith('.dylib')
    else:
        assert tempdll.endswith('.so')
    assert tempxml.endswith('.xml')
    assert modelname == 'bouncingBall'
    
    nose.tools.assert_raises(IOError,unzip_unit,'Coupled')
    
    #FMU
    fmu = 'dq.fmu'
    
    #Unzip FMU
    tempnames = unzip_unit(archive=fmu, path=path_to_fmus)
    tempdll = tempnames[0]
    tempxml = tempnames[1]
    modelname = tempnames[2]
    
    if platform == 'win32':
        assert tempdll.endswith('.dll')
    elif platform == 'darwin':
        assert tempdll.endswith('.dylib')
    else:
        assert tempdll.endswith('.so')
    assert tempxml.endswith('.xml')
    assert modelname == 'dq'
    

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
        self._bounce  = FMUModel('bouncingBall.fmu',path_to_fmus)
        self._dq = FMUModel('dq.fmu',path_to_fmus)
        self._bounce.initialize()
        self._dq.initialize()
    
    @testattr(fmi = True)
    def test_init(self):
        """
        This tests the method __init__.
        """
        pass
        
    @testattr(fmi = True)
    def test_boolean(self):
        """
        This tests the functionality of setting/getting fmiBoolean.
        """
        #Cannot be tested with the current models.
        pass 

    @testattr(fmi = True)
    def test_real(self):
        """
        This tests the functionality of setting/getting fmiReal.
        """
        const = self._bounce.get_real([3,4])
        
        nose.tools.assert_almost_equal(const[0],-9.81000000)
        nose.tools.assert_almost_equal(const[1],0.70000000)
        
        const = self._bounce.get(['der(v)','e'])

        nose.tools.assert_almost_equal(const[0],-9.81000000)
        nose.tools.assert_almost_equal(const[1],0.70000000)
    
    @testattr(fmi = True)
    def test_integer(self):
        """
        This tests the functionality of setting/getting fmiInteger.
        """
        #Cannot be tested with the current models.
        pass 
        
    @testattr(fmi = True)    
    def test_string(self):
        """
        This tests the functionality of setting/getting fmiString.
        """
        #Cannot be tested with the current models.
        pass 
    
    @testattr(fmi = True)
    def test_t(self):
        """
        This tests the functionality of setting/getting time.
        """
        
        assert self._bounce.time == 0.0
        assert self._dq.time == 0.0
        
        self._bounce.time = 1.0
        
        assert self._bounce.time == 1.0
        
        nose.tools.assert_raises(FMUException, self._bounce._set_time, N.array([1.0,1.0]))
        
        
    @testattr(fmi = True)
    def test_real_x(self):
        """
        This tests the property of the continuous_states.
        """
        nose.tools.assert_raises(FMUException, self._bounce._set_continuous_states,N.array([1.]))
        nose.tools.assert_raises(FMUException, self._dq._set_continuous_states,N.array([1.0,1.0]))
        
        temp = N.array([2.0,1.0])
        self._bounce.continuous_states = temp
        
        nose.tools.assert_almost_equal(self._bounce.continuous_states[0],temp[0])
        nose.tools.assert_almost_equal(self._bounce.continuous_states[1],temp[1])

        
    @testattr(fmi = True)
    def test_real_dx(self):
        """
        This tests the method get_derivative.
        """
        #Bounce
        real_dx = self._bounce.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], 0.00000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)

        self._bounce.continuous_states = N.array([2.,5.])
        real_dx = self._bounce.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], 5.000000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)
        
        #DQ
        real_dx = self._dq.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], -1.0000000)
        self._dq.continuous_states = N.array([5.])
        real_dx = self._dq.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], -5.0000000)

    @testattr(fmi = True)
    def test_real_x_nominal(self):
        """
        This tests the (get)-property of nominal_continuous_states.
        """
        nominal = self._bounce.nominal_continuous_states
        
        assert nominal[0] == 1.0
        assert nominal[1] == 1.0
        
        nominal = self._dq.nominal_continuous_states
        
        assert nominal[0] == 1.0
    
    @testattr(fmi = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        assert self._bounce._get_version() == '1.0'
        assert self._dq._get_version() == '1.0'
        
    @testattr(fmi = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of model_types_platform
        """
        assert self._bounce.model_types_platform == 'standard32'
        assert self._dq.model_types_platform == 'standard32'
        
    @testattr(fmi = True)
    def test_get_tolerances(self):
        """
        This tests the method get_tolerances.
        """
        [rtol,atol] = self._bounce.get_tolerances()
        
        assert rtol == 0.0001
        nose.tools.assert_almost_equal(atol[0],0.0000010)
        nose.tools.assert_almost_equal(atol[1],0.0000010)
        
        [rtol,atol] = self._dq.get_tolerances()
        
        assert rtol == 0.0001
        nose.tools.assert_almost_equal(atol[0],0.0000010)
        
    @testattr(fmi = True)
    def test_event_indicators(self):
        """
        This tests the method get_event_indicators.
        """
        assert len(self._bounce.get_event_indicators()) == 1
        assert len(self._dq.get_event_indicators()) == 0
        
        event_ind = self._bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],1.0000000000)
        self._bounce.continuous_states = N.array([5.]*2)
        event_ind = self._bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],5.0000000000)
    
    @testattr(fmi = True)
    def test_update_event(self):
        """
        This tests the functionality of the method event_update.
        """
        self._bounce.continuous_states = N.array([1.0,1.0])
        
        self._bounce.event_update()
        
        nose.tools.assert_almost_equal(self._bounce.continuous_states[0],1.0000000000)
        nose.tools.assert_almost_equal(self._bounce.continuous_states[1],-0.7000000000)
        
        self._bounce.event_update()
        
        nose.tools.assert_almost_equal(self._bounce.continuous_states[0],1.0000000000)
        nose.tools.assert_almost_equal(self._bounce.continuous_states[1],0.49000000000)
        
        eInfo = self._bounce.get_event_info()
        
        assert eInfo.nextEventTime == 0.0
        assert eInfo.upcomingTimeEvent == False
        assert eInfo.iterationConverged == True
        assert eInfo.stateValueReferencesChanged == False
        
    @testattr(fmi = True)
    def test_get_continuous_value_references(self):
        """
        This tests the functionality of the method get_state_value_references.
        """
        ref = self._bounce.get_state_value_references()
        
        assert ref[0] == 0
        assert ref[1] == 2
        
        ref = self._dq.get_state_value_references()
        
        assert ref[0] == 0
        
    @testattr(fmi = True)
    def test_ode_get_sizes(self):
        """
        This tests the functionality of the method ode_get_sizes.
        """
        [nCont,nEvent] = self._bounce.get_ode_sizes()
        assert nCont == 2
        assert nEvent == 1
        
        [nCont,nEvent] = self._dq.get_ode_sizes()
        assert nCont == 1
        assert nEvent == 0
    
    @testattr(fmi = True)
    def test_get_name(self):
        """
        This tests the functionality of the method get_name.
        """
        assert self._bounce.get_name() == 'bouncingBall'
        assert self._dq.get_name() == 'dq'
    
    @testattr(fmi = True)
    def test_debug_logging(self):
        """
        This test the attribute debugging.
        """
        model = FMUModel('bouncingBall.fmu',path_to_fmus)
        model.initialize()
        model.set_debug_logging(True) #Activates the logging
        assert len(model.get_log()) == 0 #Get the current log (empty)
        model.set_real([0],[1.0]) #Set value which generates log message
        assert len(model.get_log()) > 0 
        
    @testattr(fmi = True)
    def test_get_fmi_options(self):
        """
        Test that simulate_options on an FMU returns the correct options 
        class instance.
        """
        assert isinstance(self._bounce.simulate_options(), ad.AssimuloFMIAlgOptions)
