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

""" Tests the jmi wrappers for the IPOPT solver module. """

import os

import numpy as N
import ctypes as ct
from ctypes import byref
import nose.tools

import jmodelica
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica import jmi
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer
from jmodelica import io

int = N.int32
N.int = N.int32


class TestNLPInitWrappers:
    """ Tests for NLPInitialization wrapper methods.
    
    """
    @classmethod
    def setUpClass(cls):
        """Sets up the class."""
        fpath = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        cpath = "CSTR.CSTR_Init"

        jmi.compile_jmu(cpath, fpath, compiler_options={'state_start_values_fixed':False})
        
    def setUp(self):
        """Test setUp. Load the test model.""" 
        cpath = "CSTR.CSTR_Init"
        fname = cpath.replace('.','_')       
        cstr = jmi.JMUModel(fname+'.jmu')    
        self.init_nlp = NLPInitialization(cstr)     
     
    @testattr(ipopt = True)   
    def test_init_opt_get_dimensions(self):
        """ Test NLPInitialization.init_opt_get_dimensions"""
        (nx,n_h,dh_n_nz) = self.init_nlp.init_opt_get_dimensions()

#    @testattr(ipopt = True)
#    def test_init_opt_get_x(self):
#       """ Test NLPInitialization.init_opt_get_x"""
#       (nx,n_h,dh_n_nz) = self.init_nlp.init_opt_get_dimensions()
#       x=self.init_nlp.init_opt_get_x()
#       nose.tools.assert_equal(len(x),nx)
    
    @testattr(ipopt = True)  
    def test_init_opt_getset_initial(self):
        """ Test NLPInitialization.init_opt_get_initial"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        x_init=N.zeros(nx)
        self.init_nlp.init_opt_get_initial(x_init)
        self.init_nlp.init_opt_set_initial(x_init)
    
    @testattr(ipopt = True)           
    def test_init_opt_getset_bounds(self):
        """ Test NLPInitialization.init_opt_get_bounds and init_opt_set_bounds"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        x_lb=N.zeros(nx)
        x_ub=N.zeros(nx)
        self.init_nlp.init_opt_get_bounds(x_lb,x_ub)
        self.init_nlp.init_opt_set_bounds(x_lb,x_ub)       
        
    @testattr(ipopt = True)    
    def test_init_opt_f(self):
        """ Test NLPInitialization.init_opt_f"""
        f=N.zeros(1)
        self.init_nlp.init_opt_f(f)
    
    @testattr(ipopt = True)   
    def test_init_opt_df(self):
        """ Test NLPInitialization.init_opt_df"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        df=N.zeros(nx)
        self.init_nlp.init_opt_df(df)

    @testattr(ipopt = True)   
    def test_init_opt_h(self):
        """ Test NLPInitialization.opt_sim_h"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        res=N.zeros(n_h)
        self.init_nlp.init_opt_h(res)
    
    @testattr(ipopt = True)   
    def test_init_opt_dh(self):
        """ Test NLPInitialization.opt_sim_dh"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        jac=N.zeros(dh_n_nz)
        self.init_nlp.init_opt_dh(jac)
    
    @testattr(ipopt = True)    
    def test_opt_init_opt_dh_nz_indices(self):
        """ Test NLPInitialization.opt_sim_dh_nz_indices"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        irow=N.zeros(dh_n_nz,dtype=int)
        icol=N.zeros(dh_n_nz,dtype=int)
        self.init_nlp.init_opt_dh_nz_indices(irow,icol)


class TestNLPInit:
    """ Test evaluation of function in NLPInitialization and solution
    of initialization problems.
    
    """
    @classmethod
    def setUpClass(cls):
        """Sets up the test class."""
        fpath_daeinit = os.path.join(get_files_path(), 'Modelica', 'DAEInitTest.mo')
        cpath_daeinit = "DAEInitTest"
        jmi.compile_jmu(cpath_daeinit, fpath_daeinit, compiler_options={'state_start_values_fixed':True})
        
    def setUp(self):
        """Test setUp. Load the test model."""                    
        # Load the dynamic library and XML data
        cpath_daeinit = "DAEInitTest"
        fname_daeinit = cpath_daeinit.replace('.','_',1)
        self.dae_init_test = jmi.JMUModel(fname_daeinit+'.jmu')

        # This is to check that values set in the model prior to
        # creation of the NLPInitialization object are used as an
        # initial guess.
        self.dae_init_test.set('y1',0.3)
    
        self.init_nlp = NLPInitialization(self.dae_init_test)
        self.init_nlp_ipopt = InitializationOptimizer(self.init_nlp)


    @testattr(ipopt = True)    
    def test_init_opt_get_dimensions(self):
        """ Test NLPInitialization.init_opt_get_dimensions"""
    
        res_n_x = 8
        res_n_h = 8
        res_dh_n_nz = 17
    
        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()
    
        assert N.abs(res_n_x-n_x) + N.abs(res_n_h-n_h) + \
               N.abs(res_dh_n_nz-dh_n_nz)==0, \
               "test_jmi.py: test_init_opt: init_opt_get_dimensions returns wrong problem dimensions." 

    @testattr(ipopt = True)    
    def test_init_opt_get_set_x_init(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()
    
        # Test init_opt_get_x_init
        res_x_init = N.array([0,0,3,4,1,0,0,0])
        x_init = N.zeros(n_x)
        self.init_nlp.init_opt_get_initial(x_init)
        #print x_init
        assert N.sum(N.abs(res_x_init-x_init))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_get_x_init returns wrong values." 
    
        # Test init_opt_set_x_init
        res_x_init = N.ones(n_x)
        x_init = N.ones(n_x)
        self.init_nlp.init_opt_set_initial(x_init)
        self.init_nlp.init_opt_get_initial(x_init)
        assert N.sum(N.abs(res_x_init-x_init))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_get_x_init returns wrong values after setting the initial values with init_opt_get_x_init." 

    @testattr(ipopt = True)    
    def test_init_opt_get_set_bounds(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()

        # Test init_opt_get_bounds
        res_x_lb = -1e20*N.ones(n_x)
        res_x_ub = 1e20*N.ones(n_x)
        x_lb = N.zeros(n_x)
        x_ub = N.zeros(n_x)
        self.init_nlp.init_opt_get_bounds(x_lb,x_ub)
        assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong lower bounds." 
        assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong upper bounds." 
    
        # Test init_opt_set_bounds
        res_x_lb = -5000*N.ones(n_x)
        res_x_ub = 5000*N.ones(n_x)
        x_lb = -5000*N.ones(n_x)
        x_ub = 5000*N.ones(n_x)
        self.init_nlp.init_opt_set_bounds(x_lb,x_ub)
        self.init_nlp.init_opt_get_bounds(x_lb,x_ub)
        assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong lower bounds after calling init_opt_set_bounds." 
        assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong upper bounds after calling init_opt_set_bounds." 

    @testattr(ipopt = True)    
    def test_init_opt_f(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()
    
        # Test init_opt_f
        res_f = N.array([0.0])
        f = N.zeros(1)
        self.init_nlp.init_opt_f(f)
        #print f
        assert N.sum(N.abs(res_f-f))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_f returns wrong value" 

    @testattr(ipopt = True)    
    def test_init_opt_df(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()

        # Test init_opt_df
        res_df = N.array([0.,0,0,0,0,0,0,0])
        df = N.ones(n_x)
        self.init_nlp.init_opt_df(df)
        #print df
        assert N.sum(N.abs(res_df-df))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_df returns wrong value" 

    @testattr(ipopt = True)    
    def test_init_opt_h(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()
        # Test init_opt_h
        res_h = N.array([ -1.98158529e+02,  -2.43197505e-01,   5.12000000e+02,   5.00000000e+00,
                          1.41120008e-01,   0.00000000e+00,   0.00000000e+00,   0.00000000e+00])
        h = N.zeros(n_h)
        self.init_nlp.init_opt_h(h)
        #print h
        assert N.sum(N.abs(res_h-h))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_h returns wrong value" 

    @testattr(ipopt = True)    
    def test_init_opt_dh(self):
        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()

        # Test init_opt_dh
        res_dh = N.array([ -1.,           -1.,         -135.,          192.,           -0.9899925,    -1.,
                           -48.,            0.65364362,   -1.,            0.54030231,   -2.,           -1.,
                           -1.,            0.9899925,   192.,           -1.,           -1.,        ])
        dh = N.ones(dh_n_nz)
        self.init_nlp.init_opt_dh(dh)
        #print dh
        assert N.sum(N.abs(res_dh-dh))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_dh returns wrong value" 

    @testattr(ipopt = True)    
    def test_init_opt_dh_nz_indices(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()

        # Test init_opt_dh_nz_indices
        res_dh_irow = N.array([1, 2, 1, 3, 5, 7, 1, 2, 8, 1, 2, 6, 3, 5, 3, 4, 5])
        res_dh_icol = N.array([1, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8])
        dh_irow = N.zeros(dh_n_nz,dtype=N.int32)
        dh_icol = N.zeros(dh_n_nz,dtype=N.int32)
        self.init_nlp.init_opt_dh_nz_indices(dh_irow,dh_icol)
        assert N.sum(N.abs(res_dh_irow-dh_irow))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_dh_nz_indices returns wrong values for the row indices." 
        assert N.sum(N.abs(res_dh_icol-dh_icol))<1e-3, \
               "test_jmi.py: test_init_opt: init_opt_dh_nz_indices returns wrong values for the column indices" 

    @testattr(ipopt = True)    
    def test_init_opt_solve(self):

        n_x, n_h, dh_n_nz = self.init_nlp.init_opt_get_dimensions()

    
        # self.init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
        
        self.init_nlp_ipopt.init_opt_ipopt_solve()
    
        res_Z = N.array([5.,
                         -198.1585290151921,
                         -0.2431975046920718,
                         3.0,
                         4.0,
                         1.0,
                         2197.0,
                         5.0,
                         -0.92009689684513785,
                         0.])
    
        assert max(N.abs(res_Z-self.dae_init_test.get_z()))<1e-3, \
               "test_jmi.py: test_init_opt: Wrong solution to initialization system." 

    @testattr(ipopt = True)
    def test_statistics(self):
        """ Test of 'jmi_init_opt_get_statistics'.
        """
        # Solve the optimization problem
        self.init_nlp_ipopt.init_opt_ipopt_solve()
        (return_status,iters,cost,time) = self.init_nlp_ipopt.init_opt_ipopt_get_statistics()

        assert return_status==0, "Return status from Ipopt should be 0"
        assert abs(cost-2.4134174e+06)<1, "Wrong value of cost function"

        
    @testattr(ipopt = True)    
    def test_init_opt_write_result(self):

        cpath_daeinit = "DAEInitTest"
        fname_daeinit = cpath_daeinit.replace('.','_',1)
    
        # self.init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
        
        self.init_nlp_ipopt.init_opt_ipopt_solve()

        self.init_nlp.export_result_dymola()
        
        res = io.ResultDymolaTextual(fname_daeinit + "_result.txt")

        res_Z = N.array([5.,
                         -198.1585290151921,
                         -0.2431975046920718,
                         3.0,
                         4.0,
                         1.0,
                         2197.0,
                         5.0,
                         -0.92009689684513785,
                         0.])

        assert N.abs(res_Z[0] - res.get_variable_data("p").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable p." 
        assert N.abs(res_Z[1] - res.get_variable_data("der(x1)").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable der(x1)." 
        assert N.abs(res_Z[2] - res.get_variable_data("der(x2)").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable der(x2)." 
        assert N.abs(res_Z[3] - res.get_variable_data("x1").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable x1." 
        assert N.abs(res_Z[4] - res.get_variable_data("x2").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable x2." 
        assert N.abs(res_Z[5] - res.get_variable_data("u").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable u." 
        assert N.abs(res_Z[6] - res.get_variable_data("y1").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable y1." 
        assert N.abs(res_Z[7] - res.get_variable_data("y2").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable y2." 
        assert N.abs(res_Z[8] - res.get_variable_data("y3").x[0])<1e-3, \
               "test_jmi.py: test_init_opt_write_result: Wrong solution to initialization system for variable y3."
        
    @testattr(ipopt = True)
    def test_invalid_string_option(self):
        """Test that exceptions are thrown when invalid IPOPT options are set."""
        nose.tools.assert_raises(Exception, self.init_nlp_ipopt.init_opt_ipopt_set_string_option, 'invalid_option','val')

    @testattr(ipopt = True)
    def test_invalid_int_option(self):
        """Test that exceptions are thrown when invalid IPOPT options are set."""
        nose.tools.assert_raises(Exception, self.init_nlp_ipopt.init_opt_ipopt_set_int_option, 'invalid_option',1)

    @testattr(ipopt = True)
    def test_invalid_num_option(self):
        """Test that exceptions are thrown when invalid IPOPT options are set."""
        nose.tools.assert_raises(Exception, self.init_nlp_ipopt.init_opt_ipopt_set_num_option, 'invalid_option',1.0)

