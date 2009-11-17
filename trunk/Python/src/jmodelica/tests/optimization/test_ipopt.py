# -*- coding: utf-8 -*-
""" Tests the jmi wrappers for the IPOPT solver module. """
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

import os

import numpy as N
import ctypes as ct
from ctypes import byref
import nose.tools

import jmodelica
from jmodelica.tests import testattr
from jmodelica.compiler import OptimicaCompiler
from jmodelica import jmi
from jmodelica.optimization import ipopt

int = N.int32
N.int = N.int32

jm_home = jmodelica.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python','jmodelica','examples')
oc = OptimicaCompiler()

model = os.path.join('files','CSTR.mo')
fpath = os.path.join(jm_home, path_to_examples, model)
cpath = "CSTR.CSTR_Opt"
fname = cpath.replace('.','_')
oc.compile_model(fpath, cpath, 'ipopt')


class TestNLP:
    """ Tests for NLPCollocation wrapper methods.
    
    """
    
    def setUp(self):
        """Test setUp. Load the test model."""        
        self.cstr = jmi.Model(fname)
        # Initialize the mesh
        n_e = 150 # Number of elements 
        hs = N.ones(n_e)*1./n_e # Equidistant points
        n_cp = 3; # Number of collocation points in each element        
        
        # Create an NLP object
        self.nlp = ipopt.NLPCollocationLagrangePolynomials(self.cstr,n_e,hs,n_cp)
        
        
    @testattr(stddist = True)    
    def test_opt_sim_get_dimensions(self):
        """ Test NLPCollocation.opt_sim_get_dimensions"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
           
    @testattr(stddist = True)
    def test_opt_sim_get_interval_spec(self):
        """ Test NLPCollocation.opt_sim_get_interval_spec"""
        start_time=ct.c_double()
        start_time_free=ct.c_int()
        final_time=ct.c_double()
        final_time_free=ct.c_int()        
        self.nlp.opt_sim_get_interval_spec(byref(start_time),byref(start_time_free),byref(final_time),byref(final_time_free))

    @testattr(stddist = True)
    def test_opt_sim_get_x(self):
        """ Test NLPCollocation.opt_sim_get_x"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        x=self.nlp.opt_sim_get_x()
        nose.tools.assert_equal(len(x),n_x)

    @testattr(stddist = True)
    def test_opt_sim_getset_initial(self):
        """ Test NLPCollocation.opt_sim_get_initial and NLPCollocation.opt_sim_set_initial"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        x_init=N.zeros(n_x)
        self.nlp.opt_sim_get_initial(x_init)
        self.nlp.opt_sim_set_initial(x_init)
 
    @testattr(stddist = True)
    def test_opt_sim_set_initial_from_trajectory(self):
        """ Test NLPCollocation.opt_sim_set_initial_from_trajectory"""
        pass    # already tested in test_jmi
    
    @testattr(stddist = True)
    def test_opt_sim_getset_bounds(self):
        """ Test NLPCollocation.opt_sim_get_bounds and NLPCollocation.opt_sim_set_bounds"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        x_lb=N.zeros(n_x)
        x_ub=N.zeros(n_x)
        self.nlp.opt_sim_get_bounds(x_lb,x_ub)
        self.nlp.opt_sim_set_bounds(x_lb,x_ub)
    
    @testattr(stddist = True)    
    def test_opt_sim_f(self):
        """ Test NLPCollocation.opt_sim_f"""
        f=ct.c_double()
        self.nlp.opt_sim_f(byref(f))
    
    @testattr(stddist = True)   
    def test_opt_sim_df(self):
        """ Test NLPCollocation.opt_sim_df"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        df=N.zeros(n_x)
        self.nlp.opt_sim_df(df)
    
    @testattr(stddist = True)  
    def test_opt_sim_g(self):
        """ Test NLPCollocation.opt_sim_g"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        res = N.zeros(n_g)
        self.nlp.opt_sim_g(res)
    
    @testattr(stddist = True)   
    def test_opt_sim_dg(self):
        """ Test NLPCollocation.opt_sim_dg"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        jac=N.zeros(dg_n_nz)
        self.nlp.opt_sim_dg(jac)
    
    @testattr(stddist = True)    
    def test_opt_sim_dg_nz_indices(self):
        """ Test NLPCollocation.opt_sim_dg_nz_indices"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        irow=N.zeros(dg_n_nz,dtype=int)
        icol=N.zeros(dg_n_nz,dtype=int)
        self.nlp.opt_sim_dg_nz_indices(irow,icol)   
    
    @testattr(stddist = True)   
    def test_opt_sim_h(self):
        """ Test NLPCollocation.opt_sim_h"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        res=N.zeros(n_h)
        self.nlp.opt_sim_h(res)
    
    @testattr(stddist = True)   
    def test_opt_sim_dh(self):
        """ Test NLPCollocation.opt_sim_dh"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        jac=N.zeros(dh_n_nz)
        self.nlp.opt_sim_dh(jac)
    
    @testattr(stddist = True)    
    def test_opt_sim_dh_nz_indices(self):
        """ Test NLPCollocation.opt_sim_dh_nz_indices"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        irow=N.zeros(dh_n_nz,dtype=int)
        icol=N.zeros(dh_n_nz,dtype=int)
        self.nlp.opt_sim_dh_nz_indices(irow,icol)   
    
    @testattr(stddist = True)    
    def test_opt_sim_write_file_matlab(self):
        pass
        
    @testattr(stddist = True)
    def test_opt_sim_get_result(self):
        """ Test NLPCollocation.opt_sim_get_result"""
        timepoints = self.nlp.opt_sim_get_result_variable_vector_length()
        res_dx = timepoints*self.cstr._n_dx.value
        res_x = timepoints*self.cstr._n_x.value
        res_u = timepoints*self.cstr._n_u.value
        res_w = timepoints*self.cstr._n_w.value
        
        p_opt=N.zeros(self.cstr._n_p_opt)
        t=N.zeros(timepoints)
        dx=N.zeros(res_dx)
        x=N.zeros(res_x)
        u=N.zeros(res_u)
        w=N.zeros(res_w)
        self.nlp.opt_sim_get_result(p_opt, t, dx, x, u, w)
        
