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

import numpy as N

import jmi as pyjmi # increased readability
from jmi import JMIException


class GenericJMITests:
    """
    Tests any JMI Model DLL to see that it conforms to the DLL API.
    
    Which DLL to test is set using the members 'self.model_lib' and
    'self.model_path'.
    """
    
    def loadDLL(self, libname, examplepath):
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
        # Path to example collection root directory
        EXAMPLES_PATH = '../../../build/JMI/examples'
        try:
            dll = pyjmi.load_DLL(libname, \
                                 os.path.join(EXAMPLES_PATH, \
                                              examplepath))
        except JMIException, e:
            raise JMIException("%s\nUnable to load test models." \
                               " You have probably not compiled the" \
                               " examples. Please refer to the"
                               " JModelica for more information." % e)
                               
        return dll
    
    def setUp(self):
        self.dll = self.loadDLL(self.model_lib, self.model_path)
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
        assert self.dll.jmi_dae_dF_n_nz(self.jmi, \
                                        pyjmi.JMI_DER_SYMBOLIC, \
                                        byref(self.dF_n_nz)) \
               is 0, \
               "getting number of non-zeros in the full DAE residual " \
               + "Jacobian failed"
        self.dF_row = (self.dF_n_nz.value * ctypes.c_int)()
        self.dF_col = (self.dF_n_nz.value * ctypes.c_int)()
        
        self.dJ_n_nz = ctypes.c_int()
        assert self.dll.jmi_opt_dJ_n_nz(self.jmi, \
                                        pyjmi.JMI_DER_SYMBOLIC, \
                                        byref(self.dJ_n_nz)) \
               is 0, \
               "getting number of non-zeros in the gradient of the " \
               + "cost function failed"
        self.dJ_row = (self.dJ_n_nz.value * ctypes.c_int)()
        self.dJ_col = (self.dJ_n_nz.value * ctypes.c_int)()
        
        self.dJ_n_dense = ctypes.c_int(self.n_z.value);
        
        self.dF_n_dense = ctypes.c_int(self.n_z.value \
                                        * self.n_eq_F.value)
        
        self.J = pyjmi.c_jmi_real_t();
        
        #static jmi_opt_sim_t *jmi_opt_sim;
        #static jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;
        self.jmi_opt_sim = ctypes.c_void_p()
        self.jmi_opt_sim_ipopt = ctypes.c_void_p()
        
        self.res_F = (self.n_eq_F.value * pyjmi.c_jmi_real_t)()
        self.dF_sparse = (self.dF_n_nz.value * pyjmi.c_jmi_real_t)()
        self.dF_dense = (self.dF_n_dense.value * pyjmi.c_jmi_real_t)()
        
        self.dJ_sparse = (self.dJ_n_nz.value * pyjmi.c_jmi_real_t)()
        self.dJ_dense = (self.dJ_n_dense.value * pyjmi.c_jmi_real_t)()
	    
	    # The return types for these functions are set in jmi.py's
	    # function load_DLL(...)
        self.ci = self.dll.jmi_get_ci(self.jmi);
        self.cd = self.dll.jmi_get_cd(self.jmi);
        self.pi = self.dll.jmi_get_pi(self.jmi);
        self.pd = self.dll.jmi_get_pd(self.jmi);
        self.dx = self.dll.jmi_get_dx(self.jmi);
        self.x = self.dll.jmi_get_x(self.jmi);
        self.u = self.dll.jmi_get_u(self.jmi);
        self.w = self.dll.jmi_get_w(self.jmi);
        self.t = self.dll.jmi_get_t(self.jmi);
        self.dx_p_1 = self.dll.jmi_get_dx_p(self.jmi, 0);
        self.x_p_1 = self.dll.jmi_get_x_p(self.jmi, 0);
        self.u_p_1 = self.dll.jmi_get_u_p(self.jmi, 0);
        self.w_p_1 = self.dll.jmi_get_w_p(self.jmi, 0);
        self.dx_p_2 = self.dll.jmi_get_dx_p(self.jmi, 1);
        self.x_p_2 = self.dll.jmi_get_x_p(self.jmi, 1);
        self.u_p_2 = self.dll.jmi_get_u_p(self.jmi, 1);
        self.w_p_2 = self.dll.jmi_get_w_p(self.jmi, 1);
        
        self.res_F = N.zeros(self.n_eq_F.value, dtype=pyjmi.c_jmi_real_t)
        self.dF_sparse = (self.dF_n_nz.value * pyjmi.c_jmi_real_t)()
        self.dF_dense = (self.dF_n_dense.value * pyjmi.c_jmi_real_t)()
        
        self.dJ_sparse = (self.dJ_n_nz.value * pyjmi.c_jmi_real_t)()
        self.dJ_dense = (self.dJ_n_dense.value * pyjmi.c_jmi_real_t)()
        
        self.mask = N.ones(self.n_z.value, dtype=int)
        
    def deleteModel(self):
        """Freeing the JMI structure from memory."""
        assert self.dll.jmi_delete(self.jmi) == 0, \
               "jmi_delete failed"

    def testLoaded(self):
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
               
               
class GenericVDPTestsUsingCTypes(GenericJMITests):
    """Tests that are run on both VDP-models.
    
    """
    def setUp(self):
        GenericJMITests.setUp(self)
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
               
        res_F = N.array(self.res_F)
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
                       
        assert dF_n_nz_test.value is 12 and dF_n_cols_test.value is 3
        

class testVDPWithoutCppADUsingCTypes(GenericVDPTestsUsingCTypes):
    """
    Test loading Van der Pol JMI model DLL (compiled without CPPAD)
    directly with ctypes.
    
    """
    
    def setUp(self):
        self.model_path = 'Vdp'
        self.model_lib = 'vdp'
        GenericVDPTestsUsingCTypes.setUp(self)
        

class testVDPWithCppADUsingCTypes(GenericVDPTestsUsingCTypes):
    """
    Test loading Van der Pol JMI model DLL (compiled with CPPAD)
    directly with ctypes.
    
    """
    
    def setUp(self):
        self.model_path = 'Vdp_cppad'
        self.model_lib = 'vdp_cppad'
        GenericVDPTestsUsingCTypes.setUp(self)
        
        # Initializing CppAD, too
        self.dll.jmi_ad_init(self.jmi)


class testFurutaPendulum(GenericJMITests):
    """Tests the furuta pendulum example.
    
    The furuta pendulum introduces the new ODE interface. Therefor
    focus in this test is on the ODE interface.
    """
    def setUp(self):
        self.model_path = 'FurutaPendulum'
        self.model_lib = 'furuta'
        GenericJMITests.setUp(self)
        
        # Initializing CppAD, too
        self.dll.jmi_ad_init(self.jmi)


class testBasicJMIModelClass:
    """Basic tests for the high level JMIModel class.
    
    """
    def setUp(self):
        self.model = pyjmi.JMIModel(self.model_path, self.model_lib)
        
    def tearDown(self):
        del self.model
        
    def testResidualEvaluation(self):
        pass
