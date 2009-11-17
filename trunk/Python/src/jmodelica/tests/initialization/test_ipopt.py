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
from jmodelica.initialization.ipopt import NLPInitialization

int = N.int32
N.int = N.int32

jm_home = jmodelica.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python','jmodelica','examples')
oc = OptimicaCompiler()

model = os.path.join('files','CSTR.mo')
fpath = os.path.join(jm_home, path_to_examples, model)
cpath = "CSTR.CSTR_Init"
fname = cpath.replace('.','_')
oc.compile_model(fpath, cpath, 'ipopt')


class TestNLPInit:
    """ Tests for NLPCollocation wrapper methods.
    
    """
    
    def setUp(self):
        """Test setUp. Load the test model."""        
        cstr = jmi.Model(fname)    
        self.init_nlp = NLPInitialization(cstr)     
     
    @testattr(stddist = True)   
    def test_init_opt_get_dimensions(self):
        """ Test NLPInitialization.init_opt_get_dimensions"""
        (nx,n_h,dh_n_nz) = self.init_nlp.init_opt_get_dimensions()

#    @testattr(stddist = True)
#    def test_init_opt_get_x(self):
#       """ Test NLPInitialization.init_opt_get_x"""
#       (nx,n_h,dh_n_nz) = self.init_nlp.init_opt_get_dimensions()
#       x=self.init_nlp.init_opt_get_x()
#       nose.tools.assert_equal(len(x),nx)
    
    @testattr(stddist = True)  
    def test_init_opt_getset_initial(self):
        """ Test NLPInitialization.init_opt_get_initial"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        x_init=N.zeros(nx)
        self.init_nlp.init_opt_get_initial(x_init)
        self.init_nlp.init_opt_set_initial(x_init)
    
    @testattr(stddist = True)           
    def test_init_opt_getset_bounds(self):
        """ Test NLPInitialization.init_opt_get_bounds and init_opt_set_bounds"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        x_lb=N.zeros(nx)
        x_ub=N.zeros(nx)
        self.init_nlp.init_opt_get_bounds(x_lb,x_ub)
        self.init_nlp.init_opt_set_bounds(x_lb,x_ub)       
        
    @testattr(stddist = True)    
    def test_init_opt_f(self):
        """ Test NLPInitialization.init_opt_f"""
        f=N.zeros(1)
        self.init_nlp.init_opt_f(f)
    
    @testattr(stddist = True)   
    def test_init_opt_df(self):
        """ Test NLPInitialization.init_opt_df"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        df=N.zeros(nx)
        self.init_nlp.init_opt_df(df)

    @testattr(stddist = True)   
    def test_init_opt_h(self):
        """ Test NLPCollocation.opt_sim_h"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        res=N.zeros(n_h)
        self.init_nlp.init_opt_h(res)
    
    @testattr(stddist = True)   
    def test_init_opt_dh(self):
        """ Test NLPCollocation.opt_sim_dh"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        jac=N.zeros(dh_n_nz)
        self.init_nlp.init_opt_dh(jac)
    
    @testattr(stddist = True)    
    def test_opt_init_opt_dh_nz_indices(self):
        """ Test NLPCollocation.opt_sim_dh_nz_indices"""
        (nx,n_h,dh_n_nz)=self.init_nlp.init_opt_get_dimensions()
        irow=N.zeros(dh_n_nz,dtype=int)
        icol=N.zeros(dh_n_nz,dtype=int)
        self.init_nlp.init_opt_dh_nz_indices(irow,icol)
        