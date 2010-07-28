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
    platform = sys.platform
    
    #FMU
    fmu = 'bouncingBall.fmu'
    
    #Unzip FMU
    tempnames = unzip_FMU(archive=fmu, path=path_to_fmus)
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
    
    nose.tools.assert_raises(FMIException,unzip_FMU,'Coupled')
    
    #FMU
    fmu = 'dq.fmu'
    
    #Unzip FMU
    tempnames = unzip_FMU(archive=fmu, path=path_to_fmus)
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
        self._bounce  = FMIModel('bouncingBall.fmu',path_to_fmus)
        self._dq = FMIModel('dq.fmu',path_to_fmus)
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
        This tests the functionality of setting/getting t.
        """
        
        assert self._bounce.t == 0.0
        assert self._dq.t == 0.0
        
        self._bounce.t = 1.0
        
        assert self._bounce.t == 1.0
        
        nose.tools.assert_raises(FMIException, self._bounce.set_t, N.array([1.0,1.0]))
        
        
    @testattr(fmi = True)
    def test_real_x(self):
        """
        This tests the property of real_x.
        """
        nose.tools.assert_raises(FMIException, self._bounce.set_cont_state,N.array([1.]))
        nose.tools.assert_raises(FMIException, self._dq.set_cont_state,N.array([1.0,1.0]))
        
        temp = N.array([2.0,1.0])
        self._bounce.real_x = temp
        
        nose.tools.assert_almost_equal(self._bounce.real_x[0],temp[0])
        nose.tools.assert_almost_equal(self._bounce.real_x[1],temp[1])

        
    @testattr(fmi = True)
    def test_real_dx(self):
        """
        This tests the (get)-property of real_dx.
        """
        #Bounce
        real_dx = self._bounce.real_dx
        nose.tools.assert_almost_equal(real_dx[0], 0.00000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)

        self._bounce.real_x = N.array([2.,5.])
        real_dx = self._bounce.real_dx
        nose.tools.assert_almost_equal(real_dx[0], 5.000000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)
        
        #DQ
        real_dx = self._dq.real_dx
        nose.tools.assert_almost_equal(real_dx[0], -1.0000000)
        self._dq.real_x = N.array([5.])
        real_dx = self._dq.real_dx
        nose.tools.assert_almost_equal(real_dx[0], -5.0000000)

    @testattr(fmi = True)
    def test_real_x_nominal(self):
        """
        This tests the (get)-property of real_x_nominal.
        """
        nominal = self._bounce.real_x_nominal
        
        assert nominal[0] == 1.0
        assert nominal[1] == 1.0
        
        nominal = self._dq.real_x_nominal
        
        assert nominal[0] == 1.0
    
    @testattr(fmi = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        assert self._bounce.get_version() == '1.0'
        assert self._dq.get_version() == '1.0'
        
    @testattr(fmi = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of valid platforms.
        """
        assert self._bounce.get_validplatforms() == 'standard32'
        assert self._dq.get_validplatforms() == 'standard32'
        
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
        This tests the (get)-property of event_ind.
        """
        assert len(self._bounce.event_ind) == 1
        assert len(self._dq.event_ind) == 0
        
        event_ind = self._bounce.event_ind
        nose.tools.assert_almost_equal(event_ind[0],1.0000000000)
        self._bounce.real_x = N.array([5.]*2)
        event_ind = self._bounce.event_ind
        nose.tools.assert_almost_equal(event_ind[0],5.0000000000)
    
    @testattr(fmi = True)
    def test_update_event(self):
        """
        This tests the functionality of the method update_event.
        """
        self._bounce.real_x = N.array([1.0,1.0])
        
        self._bounce.update_event()
        
        nose.tools.assert_almost_equal(self._bounce.real_x[0],1.0000000000)
        nose.tools.assert_almost_equal(self._bounce.real_x[1],-0.7000000000)
        
        self._bounce.update_event()
        
        nose.tools.assert_almost_equal(self._bounce.real_x[0],1.0000000000)
        nose.tools.assert_almost_equal(self._bounce.real_x[1],0.49000000000)
        
        eInfo = self._bounce.event_info
        
        assert eInfo.nextEventTime == 0.0
        assert eInfo.upcomingTimeEvent == False
        assert eInfo.iterationConverged == True
        assert eInfo.stateValueReferencesChanged == False
        
    @testattr(fmi = True)
    def test_get_continuous_value_references(self):
        """
        This tests the functionality of the method get_continuous_value_references.
        """
        ref = self._bounce.get_continuous_value_reference()
        
        assert ref[0] == 0
        assert ref[1] == 2
        
        ref = self._dq.get_continuous_value_reference()
        
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

