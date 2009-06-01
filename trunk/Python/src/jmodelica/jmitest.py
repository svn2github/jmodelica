#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Tests of the JMI interface Python wrappers.

Some of the tests require the JMI examples to be compiled. See README
for more information.
"""
#    Copyright (C) 2009 Modelon AB
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

import unittest
import ctypes
from ctypes import byref
import os.path
import os
import math

import numpy as N
import nose.tools

import jmi as pyjmi # increased readability
from jmi import JMIException

def load_example_DLL(libname, examplepath):
    """Load a test model in the JMI model example folder.
    
    @note This is not a test.
    
    @param libname:
        The name of the DLL filename without suffix.
    @param examplepath:
        The relative path (from the example folder) to the library.
    @return:
        A DLL loaded using ctypes.
    
    Raises a JMIException on failure.
    """
    try:
        dll = pyjmi.load_DLL(libname, get_example_path(examplepath))
    except JMIException, e:
        raise JMIException("%s\nUnable to load test models." \
                           " You have probably not compiled the" \
                           " examples. Please refer to the"
                           " JModelica README for more information." \
                            % e)
                           
    return dll
    
def get_example_path(examplepath):
    """Get the relative path (to where this file resides) to the 
    examples directory.
    
    @param examplepath:
        The example path relative the examples directory.
    """
    # Path to example collection root directory
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You will need to define the JMODELICA_HOME environment variable."
    EXAMPLES_PATH = '%s/JMI/examples' % jmhome
    path = os.path.join(EXAMPLES_PATH, examplepath)
    return path

def test_get_test_path():
    assert os.path.isdir(get_example_path('')), \
           "Could not find example root directory. Do you have the" \
           + " whole repository structure checked out?"

class GenericJMITestsUsingCTypes:
    """
    Tests any JMI Model DLL to see that it conforms to the DLL API.
    
    Which DLL to test is set using the members 'self.model_lib' and
    'self.model_path'.
    """
    
    def setUp(self):
        self.dll = load_example_DLL(self.model_lib, self.model_path)
        self.initModel()
        
    def tearDown(self):
        self.deleteModel()
        
    def initModel(self):
        """Running code to initialize code for all the tests."""
        
        self.jmi = ctypes.c_voidp()
        assert self.dll.jmi_new(byref(self.jmi)) == 0, \
               "jmi_new returned non-zero"
        assert self.jmi.value is not None, \
               "jmi struct not returned correctly"
        
        # Initialize the global variables used throughout the tests.
        self.n_ci = ctypes.c_int()
        self.n_cd = ctypes.c_int()
        self.n_pi = ctypes.c_int()
        self.n_pd = ctypes.c_int()
        self.n_dx = ctypes.c_int()
        self.n_x = ctypes.c_int()
        self.n_u = ctypes.c_int()
        self.n_w = ctypes.c_int()
        self.n_tp = ctypes.c_int()
        self.n_z = ctypes.c_int()
        assert self.dll.jmi_get_sizes(self.jmi, \
                                      byref(self.n_ci), \
                                      byref(self.n_cd), \
                                      byref(self.n_pi), \
                                      byref(self.n_pd), \
                                      byref(self.n_dx), \
                                      byref(self.n_x), \
                                      byref(self.n_u), \
                                      byref(self.n_w), \
                                      byref(self.n_tp), \
                                      byref(self.n_z)) \
               is 0, \
               "getting sizes failed"
        
        self.n_eq_F = ctypes.c_int()
        assert self.dll.jmi_dae_get_sizes(self.jmi, \
                                          byref(self.n_eq_F)) \
               is 0, \
               "getting DAE sizes failed"
        
        self.dF_n_nz = ctypes.c_int()
        if self.dll.jmi_dae_dF_n_nz(self.jmi, pyjmi.JMI_DER_SYMBOLIC, \
                                    byref(self.dF_n_nz)) is 0:
            self.dF_row = (self.dF_n_nz.value * ctypes.c_int)()
            self.dF_col = (self.dF_n_nz.value * ctypes.c_int)()
        else:
            self.dF_n_nz = None
            self.dF_row = None
            self.dF_col = None
        
        self.dJ_n_nz = ctypes.c_int()
        if self.dll.jmi_opt_dJ_n_nz(self.jmi, pyjmi.JMI_DER_SYMBOLIC, \
                                    byref(self.dJ_n_nz)) is 0:
            self.dJ_row = (self.dJ_n_nz.value * ctypes.c_int)()
            self.dJ_col = (self.dJ_n_nz.value * ctypes.c_int)()
        else:
            self.dJ_row = None
            self.dJ_col = None
        
        self.dJ_n_dense = ctypes.c_int(self.n_z.value);
        
        self.J = pyjmi.c_jmi_real_t();
        
        #static jmi_opt_sim_t *jmi_opt_sim;
        #static jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;
        self.jmi_opt_sim = ctypes.c_void_p()
        self.jmi_opt_sim_ipopt = ctypes.c_void_p()
	    
	    # The return types for these functions are set in jmi.py's
	    # function load_DLL(...)
        self.ci = self.dll.jmi_get_ci(self.jmi)
        self.cd = self.dll.jmi_get_cd(self.jmi)
        self.pi = self.dll.jmi_get_pi(self.jmi)
        self.pd = self.dll.jmi_get_pd(self.jmi)
        self.dx = self.dll.jmi_get_dx(self.jmi)
        self.x = self.dll.jmi_get_x(self.jmi)
        self.u = self.dll.jmi_get_u(self.jmi)
        self.w = self.dll.jmi_get_w(self.jmi)
        self.t = self.dll.jmi_get_t(self.jmi)
        self.dx_p_1 = self.dll.jmi_get_dx_p(self.jmi, 0)
        self.x_p_1 = self.dll.jmi_get_x_p(self.jmi, 0)
        self.u_p_1 = self.dll.jmi_get_u_p(self.jmi, 0)
        self.w_p_1 = self.dll.jmi_get_w_p(self.jmi, 0)
        self.dx_p_2 = self.dll.jmi_get_dx_p(self.jmi, 1)
        self.x_p_2 = self.dll.jmi_get_x_p(self.jmi, 1)
        self.u_p_2 = self.dll.jmi_get_u_p(self.jmi, 1)
        self.w_p_2 = self.dll.jmi_get_w_p(self.jmi, 1)
        
        self.res_F = N.zeros(self.n_eq_F.value, dtype=pyjmi.c_jmi_real_t)
        
        self.mask = N.ones(self.n_z.value, dtype=int)
        
    def deleteModel(self):
        """Freeing the JMI structure from memory."""
        assert self.dll.jmi_delete(self.jmi) == 0, \
               "jmi_delete failed"

    def testLoaded(self):
        """Tests if the DLL was successfully loaded."""
        assert isinstance(self.dll, ctypes.CDLL), \
               "lib is not a CDLL instance"
        assert isinstance(self.dll.jmi_new, ctypes._CFuncPtr), \
               "lib.jmi_new is not a ctypes._CFuncPtr instance"
            
    def testJMIInitDest(self):
        """Simple inititialization and destruction tests."""
        
        jmip = ctypes.c_voidp()
        assert self.dll.jmi_new(byref(jmip)) == 0, \
               "jmi_new returned non-zero"
        assert jmip.value is not None, \
               "jmi struct not returned correctly"
        assert self.dll.jmi_delete(jmip) == 0, \
               "jmi_delete failed"
               
    def testGettingOffsets(self):
        """Testing jmi_get_offsets(...)."""
        offs_ci = ctypes.c_int()
        offs_cd = ctypes.c_int()
        offs_pi = ctypes.c_int()
        offs_pd = ctypes.c_int()
        offs_dx = ctypes.c_int()
        offs_x = ctypes.c_int()
        offs_u = ctypes.c_int()
        offs_w = ctypes.c_int()
        offs_t = ctypes.c_int()
        offs_dx_p = ctypes.c_int()
        offs_x_p = ctypes.c_int()
        offs_u_p = ctypes.c_int()
        offs_w_p = ctypes.c_int()
        assert self.dll.jmi_get_offsets(self.jmi, \
                                        byref(offs_ci), \
                                        byref(offs_cd), \
                                        byref(offs_pi), \
                                        byref(offs_pd), \
                                        byref(offs_dx), \
                                        byref(offs_x), \
                                        byref(offs_u), \
                                        byref(offs_w), \
                                        byref(offs_t), \
                                        byref(offs_dx_p), \
                                        byref(offs_x_p), \
                                        byref(offs_u_p), \
                                        byref(offs_w_p)) \
               is 0, \
               "getting offsets failed"
               
               
class GenericVDPTestsUsingCTypes(GenericJMITestsUsingCTypes):
    """Tests that are run on both VDP-models.
    
    """
    def setUp(self):
        GenericJMITestsUsingCTypes.setUp(self)
        self.initModel()
               
    def testSizes(self):
        """Test the sizes return by 'jmi_get_sizes(...)'."""
        assert self.n_ci.value is 0
        assert self.n_cd.value is 0
        assert self.n_pi.value is 3
        assert self.n_pd.value is 0
        assert self.n_dx.value is 3
        assert self.n_x.value is 3
        assert self.n_u.value is 1
        assert self.n_w.value is 1
        assert self.n_tp.value is 2
        assert self.n_z.value is 28
        
    def test_jmi_dae_dF_n_nz(self):
        """Test the function jmi_dae_dF_n_nz(...)."""
        dF_n_nz = ctypes.c_int()
        assert self.dll.jmi_dae_dF_n_nz(self.jmi, \
                                        pyjmi.JMI_DER_SYMBOLIC, \
                                        byref(dF_n_nz)) \
               is 0, \
               "getting number of non-zeros in the full DAE residual " \
                + "Jacobian failed"
    
    def test_1_dae_F(self):
        """Run the test test_1_dae_F also found in @vdp_main.c
        
        @todo This test does for some reason fail on VDP with CPPAD.
        """
        
        SMALL = 10**-10
        FIXED_RES = N.array([-2, 0, 153.1701780775437, 0])
        
        self.pi[0] = 1
        self.pi[1] = 1
        self.pi[2] = 2
        self.dx[0] = 1
        self.dx[1] = 1
        self.dx[2] = 2
        self.x[0] = 1
        self.x[1] = 2
        self.x[2] = 3
        self.u[0] = 4
        self.w[0] = 3
        self.t[0] = 1
        
        assert self.dll.jmi_dae_F(self.jmi, self.res_F) is 0, \
               "could not get residuals"
               
        print 'res_F = FIXED_RES   <=>  ', self.res_F, '=', 
        
        res_F = self.res_F
        assert res_F.size is FIXED_RES.size
        
        err_sum = sum(abs(FIXED_RES - res_F))
        assert err_sum < SMALL, "residuals failed"
    
    def test_2_dae_dF_indices(self):
        """Run the test test_2_dae_dF_indices also found in @vdp_main.c
        """
        print self.n_z.value
        print self.dF_n_nz.value
        mask = N.ones(self.n_z.value, dtype=int)
        dF_row = N.zeros(self.dF_n_nz.value, dtype=int)
        dF_col = N.zeros(self.dF_n_nz.value, dtype=int)
        assert self.dll.jmi_dae_dF_nz_indices(self.jmi, \
                                              pyjmi.JMI_DER_SYMBOLIC, \
                                              pyjmi.JMI_DER_ALL, \
                                              mask, \
                                              dF_row, \
                                              dF_col) \
               is 0, \
               "could not get indices"
               
        print "dF_row: %s" % dF_row
        print "dF_col: %s" % dF_col
               
        dF_row_fix = N.array([2,3,1,2,3,1,2,3,4,1,3,4,1,3,4,3], \
                             dtype=int)
        dF_col_fix = N.array([1,3,4,5,6,7,7,7,7,8,8,8,10,10,11,12], \
                             dtype=int)
        
        assert sum(abs(dF_row - dF_row_fix))==0, "row indices failed"
        assert sum(abs(dF_col - dF_col_fix))==0, "column indices failed"
        
        
    def testCtypesArgTypes(self):
        """Test CTypes argument checking.
        """
        dF_row = N.array([], dtype=pyjmi.c_jmi_real_t)
        dF_col = N.array([], dtype=pyjmi.c_jmi_real_t)
        try:
            assert self.dll.jmi_dae_dF_nz_indices(self.jmi, \
                                                  pyjmi.JMI_DER_SYMBOLIC, \
                                                  pyjmi.JMI_DER_ALL, \
                                                  self.mask, \
                                                  dF_row, \
                                                  dF_col) \
                   is 0, \
                   "could not get indices"
        except ctypes.ArgumentError:
            pass
        else:
            assert False, "type checking failed"
            
    def test_3_dae_dF_dim(self):
        """Run the test test_3_dae_dF_dim also found in @vdp_main.c
        """
        
        dF_n_nz_test = ctypes.c_int()
        dF_n_cols_test = ctypes.c_int()
        self.dll.jmi_dae_dF_dim(self.jmi, pyjmi.JMI_DER_SYMBOLIC, \
                                pyjmi.JMI_DER_DENSE_ROW_MAJOR, pyjmi.JMI_DER_X, \
                                self.mask, byref(dF_n_cols_test), \
                                byref(dF_n_nz_test))
        
        nose.tools.assert_equal(dF_n_nz_test.value, 12)
        nose.tools.assert_equal(dF_n_cols_test.value, 3)
        

class testVDPWithoutADUsingCTypes(GenericVDPTestsUsingCTypes):
    """
    Test loading Van der Pol JMI model DLL (compiled without AD)
    directly with ctypes.
    
    """
    
    def setUp(self):
        self.model_path = 'Vdp'
        self.model_lib = 'vdp'
        GenericVDPTestsUsingCTypes.setUp(self)
        

class testVDPWithADUsingCTypes(GenericVDPTestsUsingCTypes):
    """
    Test loading Van der Pol JMI model DLL (compiled with AD)
    directly with ctypes.
    
    """
    
    def setUp(self):
        self.model_path = 'Vdp_cppad'
        self.model_lib = 'vdp_cppad'
        GenericVDPTestsUsingCTypes.setUp(self)
        
        # Initializing CppAD, too
        self.dll.jmi_ad_init(self.jmi)


class testFurutaPendulum(GenericJMITestsUsingCTypes):
    """Tests the Furuta pendulum example.
    
    The Furuta pendulum introduces the new ODE interface. Therefor
    focus in this test is on the ODE interface.
    """
    def setUp(self):
        self.model_path = 'FurutaPendulum'
        self.model_lib = 'furuta'
        GenericJMITestsUsingCTypes.setUp(self)
        
        # Here initial values for all parameters should be read from
        # xml-files
        self.pi[0] = 0.00354;
        self.pi[1] = 0.00384;
        self.pi[2] = 0.00258;
        self.pi[3] = 0.103;
        self.pi[4] = 0.2;
        self.pi[5] = 0.0;
        self.pi[6] = 0.0;
        self.pi[7] = 0.0;
        
        # Initializing CppAD, too
        self.dll.jmi_ad_init(self.jmi)
        
    def testODERoot1(self):
        """Testing a stable bifurcation of the system.
        
        The pendulum is pointing downwards. No movements.
        """
        # See Doxygen documentation for the meaning of these numbers
        self.x[:] = [0, 0, 0, 0]
        self.u[0] = 0
        
        # Needed in order to be sure the assert below works
        self.dx[:] = [1, 2, 3, 4]
        
        self.dll.jmi_ode_f(self.jmi)
        
        N.testing.assert_almost_equal(self.dx, [0, 0, 0, 0])
        
    def testODERoot2(self):
        """Testing the unstable bifurcation of the system.
        
        The pendulum is strictly pointing upwards. No movements.
        """
        # See Doxygen documentation for the meaning of these numbers
        self.x[:] = [math.pi, 0, 0, 0]
        self.u[0] = 0
        
        # Needed in order to be sure the assert below works
        self.dx[:] = [1, 2, 3, 4]
        
        self.dll.jmi_ode_f(self.jmi)
        
        N.testing.assert_almost_equal(self.dx, [0, 0, 0, 0])
        

class testReturnsNDArray():
    """Tests the (private) function jmi._returns_ndarray(...)
    
    """
    def testDoubleType(self):
        """Test the function using the double data type.
        """
        # The function to test
        returns_ndarray = pyjmi._from_address
        
        ctypes_arr = (4 * ctypes.c_double)(1.2, 1.8, 5.4, 8.32)
        address = ctypes.addressof(ctypes_arr)
        narray = returns_ndarray(address, ctypes.sizeof(ctypes_arr) \
                                           * ctypes.sizeof(ctypes.c_double),
                                 ctypes.c_double)
                                 
        nose.tools.assert_equal(ctypes_arr[0], narray[0])
        nose.tools.assert_equal(ctypes_arr[3], narray[3])
        
        ctypes_arr[0] = 3.78
        nose.tools.assert_equal(ctypes_arr[0], narray[0])
        
        ctypes_arr[3] = 14.79
        nose.tools.assert_equal(ctypes_arr[3], narray[3])
        
        narray[0] = 3.42
        nose.tools.assert_equal(ctypes_arr[0], narray[0])
        
        narray[3] = 9.17
        nose.tools.assert_equal(ctypes_arr[3], narray[3])
        
    def testIntType(self):
        """Test the function using the int data type.
        """
        # The function to test
        returns_ndarray = pyjmi._from_address
        
        ctypes_arr = (4 * ctypes.c_int)(2, 8, 5, 3)
        address = ctypes.addressof(ctypes_arr)
        narray = returns_ndarray(address, ctypes.sizeof(ctypes_arr) \
                                           * ctypes.sizeof(ctypes.c_int),
                                 ctypes.c_int)
                                 
        nose.tools.assert_equal(ctypes_arr[0], narray[0])
        nose.tools.assert_equal(ctypes_arr[3], narray[3])
        
        ctypes_arr[0] = 78
        nose.tools.assert_equal(ctypes_arr[0], narray[0])
        
        ctypes_arr[3] = 179
        nose.tools.assert_equal(ctypes_arr[3], narray[3])
        
        narray[0] = 3427
        nose.tools.assert_equal(ctypes_arr[0], narray[0])
        
        narray[3] = 917
        nose.tools.assert_equal(ctypes_arr[3], narray[3])
    
def test_pointer_to_ndarray_converter():
    """Testing the _PointerToNDArrayConverter class.
    
    """
    converter = pyjmi._PointerToNDArrayConverter(4, ctypes.c_double)
    
    ctypes_arr = (4 * ctypes.c_double)(1.5, 8.7, 6.15, 42.0)
    pointer = ctypes.cast(ctypes_arr, ctypes.POINTER(ctypes.c_double))
    
    # func and param are not used
    narray = converter(pointer, None, None)
    
    nose.tools.assert_equal(len(narray), len(ctypes_arr))
    for elmnt in zip(narray, ctypes_arr):
        nose.tools.assert_equal(elmnt[0], elmnt[1])
    
    ctypes_arr[0] = 4.79
    nose.tools.assert_equal(ctypes_arr[0], narray[0])
    
    narray[0] = 79.75
    nose.tools.assert_equal(ctypes_arr[0], narray[0])
    
    ctypes_arr[0] = 42.79
    nose.tools.assert_equal(ctypes_arr[3], narray[3])
    
    narray[0] = 37.75
    nose.tools.assert_equal(ctypes_arr[3], narray[3])

class GenericJMIModelClassTests:
    """Basic tests for the high level JMIModel class.
    
    """
    def setUp(self):
        self.model = pyjmi.JMIModel(self.model_lib, \
                                    get_example_path(self.model_path))
        
    def tearDown(self):
        del self.model
        
    def genericVectorGetterTest(self, getter):
        """Test changing the value of a getter."""
        vec = getter()
        if len(vec) > 0:
            temp = vec[0]
            vec[0] = 5
            vec = getter()
            nose.tools.assert_equal(vec[0], 5)
            vec[0] = temp
    
    def testGetters(self):
        """Testing each getter."""
        self.genericVectorGetterTest(self.model.getX)
        self.genericVectorGetterTest(self.model.getPI)
        
    def genericVectorSetterTest(self, setter):
        """Asserts that the setter is not setable."""
        print setter
        arr = N.zeros(5684)
        nose.tools.assert_raises(pyjmi.JMIException, setter, arr)
        
    def testSetters(self):
        """Testing each setter."""
        self.genericVectorSetterTest(self.model.setX)
        self.genericVectorSetterTest(self.model.setPI)
    
    def testProperties(self):
        """Test the existence properties."""
        tmp = self.model.x
        tmp = self.model.pi


class testVDPWithoutADUsingJMIModelClass(GenericJMIModelClassTests):
    """Tests on VDP model with CppAD using the JMIModel class.
    
    """
    def setUp(self):
        self.model_path = 'Vdp'
        self.model_lib = 'vdp'
        GenericJMIModelClassTests.setUp(self)


class testVDPWithADUsingJMIModelClass(GenericJMIModelClassTests):
    """Tests on VDP model with CppAD using the JMIModel class.
    
    """
    def setUp(self):
        self.model_path = 'Vdp_cppad'
        self.model_lib = 'vdp_cppad'
        GenericJMIModelClassTests.setUp(self)
        
        # Initializing CppAD, too
        self.model.initAD()


class testFurutaPendulumUsingJMIModelClass(GenericJMIModelClassTests):
    """Tests the Furuta pendulum example using the JMIModel class.
    
    """
    def setUp(self):
        self.model_path = 'FurutaPendulum'
        self.model_lib = 'furuta'
        GenericJMIModelClassTests.setUp(self)
        
        # Here initial values for all parameters should be read from
        # xml-files
        self.model.pi[0] = 0.00354;
        self.model.pi[1] = 0.00384;
        self.model.pi[2] = 0.00258;
        self.model.pi[3] = 0.103;
        self.model.pi[4] = 0.2;
        self.model.pi[5] = 0.0;
        self.model.pi[6] = 0.0;
        self.model.pi[7] = 0.0;
        
        # Initializing CppAD, too
        # Notice how this must be done _after_ setting the independent
        # variables to assert reasonable parameter values.
        self.model.initAD()
