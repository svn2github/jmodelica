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
path_to_tests = os.path.join('Python','jmodelica','tests')
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)

class TestNLP_VDP:
    """ Tests for NLPCollocation wrapper methods using the CSTR model.
    
    """
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        # compile cstr
        model_cstr = os.path.join('files','CSTR.mo')
        fpath_cstr = os.path.join(jm_home, path_to_examples, model_cstr)
        cpath_cstr = "CSTR.CSTR_Opt"
        fname_cstr = cpath_cstr.replace('.','_')
        oc.compile_model(cpath_cstr, fpath_cstr, 'ipopt')
    
    def setUp(self):
        """Test setUp. Load the test model."""
        cpath_cstr = "CSTR.CSTR_Opt"
        fname_cstr = cpath_cstr.replace('.','_')        
        self.cstr = jmi.Model(fname_cstr)
        # Initialize the mesh
        n_e = 150 # Number of elements 
        hs = N.ones(n_e)*1./n_e # Equidistant points
        n_cp = 3; # Number of collocation points in each element        
        
        # Create an NLP object
        self.nlp = ipopt.NLPCollocationLagrangePolynomials(self.cstr,n_e,hs,n_cp)
        
        
    @testattr(ipopt = True)    
    def test_opt_sim_get_dimensions(self):
        """ Test NLPCollocation.opt_sim_get_dimensions"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
           
    @testattr(ipopt = True)
    def test_opt_sim_get_interval_spec(self):
        """ Test NLPCollocation.opt_sim_get_interval_spec"""
        start_time=ct.c_double()
        start_time_free=ct.c_int()
        final_time=ct.c_double()
        final_time_free=ct.c_int()        
        self.nlp.opt_sim_get_interval_spec(byref(start_time),byref(start_time_free),byref(final_time),byref(final_time_free))

    @testattr(ipopt = True)
    def test_opt_sim_get_x(self):
        """ Test NLPCollocation.opt_sim_get_x"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        x=self.nlp.opt_sim_get_x()
        nose.tools.assert_equal(len(x),n_x)

    @testattr(ipopt = True)
    def test_opt_sim_getset_initial(self):
        """ Test NLPCollocation.opt_sim_get_initial and NLPCollocation.opt_sim_set_initial"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        x_init=N.zeros(n_x)
        self.nlp.opt_sim_get_initial(x_init)
        self.nlp.opt_sim_set_initial(x_init)
     
    @testattr(ipopt = True)
    def test_opt_sim_getset_bounds(self):
        """ Test NLPCollocation.opt_sim_get_bounds and NLPCollocation.opt_sim_set_bounds"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        x_lb=N.zeros(n_x)
        x_ub=N.zeros(n_x)
        self.nlp.opt_sim_get_bounds(x_lb,x_ub)
        self.nlp.opt_sim_set_bounds(x_lb,x_ub)
    
    @testattr(ipopt = True)    
    def test_opt_sim_f(self):
        """ Test NLPCollocation.opt_sim_f"""
        f=ct.c_double()
        self.nlp.opt_sim_f(byref(f))
    
    @testattr(ipopt = True)   
    def test_opt_sim_df(self):
        """ Test NLPCollocation.opt_sim_df"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        df=N.zeros(n_x)
        self.nlp.opt_sim_df(df)
    
    @testattr(ipopt = True)  
    def test_opt_sim_g(self):
        """ Test NLPCollocation.opt_sim_g"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        res = N.zeros(n_g)
        self.nlp.opt_sim_g(res)
    
    @testattr(ipopt = True)   
    def test_opt_sim_dg(self):
        """ Test NLPCollocation.opt_sim_dg"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        jac=N.zeros(dg_n_nz)
        self.nlp.opt_sim_dg(jac)
    
    @testattr(ipopt = True)    
    def test_opt_sim_dg_nz_indices(self):
        """ Test NLPCollocation.opt_sim_dg_nz_indices"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        irow=N.zeros(dg_n_nz,dtype=int)
        icol=N.zeros(dg_n_nz,dtype=int)
        self.nlp.opt_sim_dg_nz_indices(irow,icol)   
    
    @testattr(ipopt = True)   
    def test_opt_sim_h(self):
        """ Test NLPCollocation.opt_sim_h"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        res=N.zeros(n_h)
        self.nlp.opt_sim_h(res)
    
    @testattr(ipopt = True)   
    def test_opt_sim_dh(self):
        """ Test NLPCollocation.opt_sim_dh"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        jac=N.zeros(dh_n_nz)
        self.nlp.opt_sim_dh(jac)
    
    @testattr(ipopt = True)    
    def test_opt_sim_dh_nz_indices(self):
        """ Test NLPCollocation.opt_sim_dh_nz_indices"""
        (n_x,n_g,n_h,dg_n_nz,dh_n_nz)=self.nlp.opt_sim_get_dimensions()
        irow=N.zeros(dh_n_nz,dtype=int)
        icol=N.zeros(dh_n_nz,dtype=int)
        self.nlp.opt_sim_dh_nz_indices(irow,icol)   
    
    @testattr(ipopt = True)    
    def test_opt_sim_write_file_matlab(self):
        pass
        
    @testattr(ipopt = True)
    def test_opt_sim_get_result(self):
        """ Test NLPCollocation.opt_sim_get_result"""
        timepoints = self.nlp.opt_sim_get_result_variable_vector_length()
        res_dx = timepoints*self.cstr._n_real_dx.value
        res_x = timepoints*self.cstr._n_real_x.value
        res_u = timepoints*self.cstr._n_real_u.value
        res_w = timepoints*self.cstr._n_real_w.value
        
        p_opt=N.zeros(self.cstr._n_p_opt)
        t=N.zeros(timepoints)
        dx=N.zeros(res_dx)
        x=N.zeros(res_x)
        u=N.zeros(res_u)
        w=N.zeros(res_w)
        self.nlp.opt_sim_get_result(p_opt, t, dx, x, u, w)
        
class TestNLP_CSTR():
    """ Tests for NLPCollocation wrapper methods using the VDP model. """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        # compile vdp
        model_vdp = os.path.join("files","VDP.mo")
        fpath_vdp = os.path.join(jm_home, path_to_examples, model_vdp)
        cpath_vdp = "VDP_pack.VDP_Opt_Min_Time"
        fname_vdp = cpath_vdp.replace('.','_',1)
        oc.compile_model(cpath_vdp, fpath_vdp, target='ipopt')
    
    def setUp(self):
        """Test setUp. Load the test model."""   
        cpath_vdp = "VDP_pack.VDP_Opt_Min_Time"
        fname_vdp = cpath_vdp.replace('.','_',1)
        self.fname_vdp = fname_vdp   
        self.vdp = jmi.Model(fname_vdp)
        # Initialize the mesh
        n_e = 100 # Number of elements 
        hs = N.ones(n_e)*1./n_e # Equidistant points
        self.hs = hs
        n_cp = 3; # Number of collocation points in each element
        
        # Create an NLP object
        self.nlp = ipopt.NLPCollocationLagrangePolynomials(self.vdp,n_e,hs,n_cp)
        self.nlp_ipopt = ipopt.CollocationOptimizer(self.nlp)

    @testattr(ipopt = True)
    def test_jmi_opt_sim_set_initial_from_trajectory(self):
        """ Test of 'jmi_opt_sim_set_initial_from_trajectory'.
    
        An optimization problem is solved and then the result
        is used to reinitialize the NLP. The variable profiles
        are then retrieved and a check is performed wheather
        they match.
        """
        
        # Solve the optimization problem
        self.nlp_ipopt.opt_sim_ipopt_solve()
        
        # Retreive the number of points in each column in the
        # result matrix
        n_points = self.nlp.opt_sim_get_result_variable_vector_length()
        
        # Create result data vectors
        p_opt = N.zeros(1)
        t_ = N.zeros(n_points)
        dx_ = N.zeros(2*n_points)
        x_ = N.zeros(2*n_points)
        u_ = N.zeros(n_points)
        w_ = N.zeros(0)
        
        # Get the result
        self.nlp.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)
    
        z_ = N.concatenate((t_,dx_,x_,u_))
        hs = N.zeros(1)
    
        self.vdp.jmimodel._dll.jmi_opt_sim_set_initial_from_trajectory(self.nlp._jmi_opt_sim,p_opt,z_,n_points,hs,0.,0.)
        
        p_opt2 = N.zeros(1)
        t_2 = N.zeros(n_points)
        dx_2 = N.zeros(2*n_points)
        x_2 = N.zeros(2*n_points)
        u_2 = N.zeros(n_points)
        w_2 = N.zeros(0)
            
        # Get the result
        self.nlp.opt_sim_get_result(p_opt2,t_2,dx_2,x_2,u_2,w_2)
        
        assert max(N.abs(x_-x_2))<1e-12, \
               "The values used in initialization does not match the values that were read back after initialization."        
    
    @testattr(ipopt = True)
    def test_set_initial_from_dymola(self):
        """ Test of 'jmi_opt_sim_set_initial_from_trajectory'.
    
        An optimization problem is solved and then the result
        is used to reinitialize the NLP. The variable profiles
        are then retrieved and a check is performed wheather
        they match.
        """
        
        # Solve the optimization problem
        self.nlp_ipopt.opt_sim_ipopt_solve()
    
        # Retreive the number of points in each column in the
        # result matrix
        n_points = self.nlp.opt_sim_get_result_variable_vector_length()
    
        # Create result data vectors
        p_opt = N.zeros(1)
        t_ = N.zeros(n_points)
        dx_ = N.zeros(2*n_points)
        x_ = N.zeros(2*n_points)
        u_ = N.zeros(n_points)
        w_ = N.zeros(0)
        
        # Get the result
        self.nlp.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)
    
        # Write to file
        self.nlp.export_result_dymola()
    
        # Load the file we just wrote
        res = jmodelica.io.ResultDymolaTextual(self.fname_vdp+'_result.txt')
    
        self.nlp.set_initial_from_dymola(res,self.hs,0.,0.)
    
        # Create result data vectors
        p_opt_2 = N.zeros(1)
        t_2 = N.zeros(n_points)
        dx_2 = N.zeros(2*n_points)
        x_2 = N.zeros(2*n_points)
        u_2 = N.zeros(n_points)
        w_2 = N.zeros(0)
        
        # Get the result
        self.nlp.opt_sim_get_result(p_opt_2,t_2,dx_2,x_2,u_2,w_2)
    
    
        assert max(N.abs(p_opt-p_opt_2))<1e-3, \
               "The values used in initialization does not match the values that were read back after initialization." 
        assert max(N.abs(dx_-dx_2))<1e-3, \
               "The values used in initialization does not match the values that were read back after initialization." 
        assert max(N.abs(x_-x_2))<1e-3, \
               "The values used in initialization does not match the values that were read back after initialization." 
        assert max(N.abs(u_-u_2))<1e-3, \
               "The values used in initialization does not match the values that were read back after initialization." 
    #    assert max(N.abs(w_-w_2))<1e-3, \
    #           "The values used in initialization does not match the values that were read back after initialization." 
    
    ##     print(p_opt)
    ##     print(p_opt_2)
    
    ##     print(sum(abs(p_opt_2-p_opt)))
    ##     print(sum(abs(dx_2-dx_)))
    ##     print(sum(abs(x_2-x_)))
    ##     print(sum(abs(u_2-u_)))
    ##     print(sum(abs(w_2-w_)))
        
    ##     # Plot
    ##     plt.figure(1)
    ##     plt.clf()
    ##     plt.subplot(211)
    ##     plt.plot(t_,x_[0:n_points])
    ##     plt.hold(True)
    ##     plt.plot(t_2,x_2[0:n_points])
    ##     plt.grid()
    ##     plt.ylabel('x1')
    ##     plt.subplot(212)
    ##     plt.plot(t_,x_[n_points:2*n_points])
    ##     plt.hold(True)
    ##     plt.plot(t_2,x_2[n_points:2*n_points])
    ##     plt.grid()
    ##     plt.ylabel('x2')
    ##     plt.show()

class TestCollocationEventException:
    """ Check that an exception is thrown when a collocation optimization
    object is created from a model containing event indicators.
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        # compile cstr
        model_cstr = os.path.join('files','IfExpTest.mo')
        fpath_cstr = os.path.join(jm_home, path_to_tests, model_cstr)
        cpath_cstr = "IfExpTestEvents"
        fname_cstr = cpath_cstr.replace('.','_')
        oc.compile_model(cpath_cstr, fpath_cstr, 'ipopt')
    
    def setUp(self):
        """Test setUp. Load the test model."""
        cpath_model = "IfExpTestEvents"
        fname_model = cpath_model.replace('.','_')
        self.model = jmi.Model(fname_model)

    @testattr(ipopt = True)
    def test_exception_thrown(self):
        # Initialize the mesh
        n_e = 150 # Number of elements 
        hs = N.ones(n_e)*1./n_e # Equidistant points
        n_cp = 3; # Number of collocation points in each element        
        
        # Create an NLP object
        try:
            self.nlp = ipopt.NLPCollocationLagrangePolynomials(self.model,n_e,hs,n_cp)
        except Exception as e:
            assert str(e) == "The collocation optimization algorithm does not support models with events. Please consider using the noEvent() operator or rewriting the model.", "Wrong message in thrown exception."
        else:
            assert False, "No exception thrown when creating a collocation optimization object based on a model containing events."
