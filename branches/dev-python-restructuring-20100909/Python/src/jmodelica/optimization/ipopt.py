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
""" The IPOPT solver module. """

from operator import itemgetter

import ctypes as ct
from ctypes import byref
import numpy as N
import numpy.ctypeslib as Nct

from jmodelica import jmi 
from jmodelica import io

from jmodelica.io import VariableNotFoundError

int = N.int32
N.int = N.int32

c_jmi_real_t = ct.c_double

class CollocationOptimizer(object):
    """ An interface to the NLP solver Ipopt. """
    
    def __init__(self, nlp_collocation):
        """ Constructor where main data structure is created. Needs a 
        NLPCollocation implementation instance, for example a 
        NLPCollocationLagrangePolynomials object. The underlying model 
        must have been compiled with support for ipopt.
        
        Parameters::
        
            nlp_collocation -- 
                The NLPCollocation object.
        
        """
        
        self._nlp_collocation = nlp_collocation
        self._ipopt_opt = ct.c_voidp()
        
        self._set_collocationOpt_typedefs()
        
        try:
            assert self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_new(
                byref(self._ipopt_opt), self._nlp_collocation._jmi_opt_sim) == 0, \
                   "jmi_opt_sim_ipopt_new returned non-zero"
        except AttributeError, e:
            raise jmi.JMIException("Can not create JMISimultaneousOptIPOPT \
            object. Please recompile model with target='ipopt")
        
        assert self._ipopt_opt.value is not None, \
               "jmi struct not returned correctly"
               
    def _set_collocationOpt_typedefs(self):
        try:
            self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_new.argtypes = [ct.c_void_p,
                                                                                         ct.c_void_p]
            self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_solve.argtypes = [ct.c_void_p]
            self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_string_option.argtypes = [ct.c_void_p,
                                                                                                       ct.c_char_p,
                                                                                                       ct.c_char_p]
            self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_int_option.argtypes = [ct.c_void_p,
                                                                                                    ct.c_char_p,
                                                                                                    ct.c_int]
            self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_num_option.argtypes = [ct.c_void_p,
                                                                                                    ct.c_char_p,
                                                                                                    c_jmi_real_t]
            self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_get_statistics.argtypes = [ct.c_void_p,
                                                                                         ct.POINTER(ct.c_int),
                                                                                         ct.POINTER(ct.c_int),
                                                                                         ct.POINTER(c_jmi_real_t),
                                                                                         ct.POINTER(c_jmi_real_t)]
        except AttributeError, e:
            pass       
               
    def opt_sim_ipopt_solve(self):
        """ Solve the NLP problem."""
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_solve(self._ipopt_opt) > 1:
            raise jmi.JMIException("Solving IPOPT failed.")
    
    def opt_sim_ipopt_set_string_option(self, key, val):
        """ Set an Ipopt string option.
        
        Parameters::
        
            key -- 
                The name of the option.
            val -- 
                The value of the option.
            
        """
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_string_option(
            self._ipopt_opt, key, val) is not 0: 
                raise jmi.JMIException("The Ipopt string option \
                " + key + " is unknown")
        
    def opt_sim_ipopt_set_int_option(self, key, val):
        """ Set an Ipopt integer option.
        
        Parameters::
        
            key -- 
                The name of the option.
            val -- 
                The value of the option.
            
        """        
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_int_option(
            self._ipopt_opt, key, val) is not 0:
            raise jmi.JMIException("The Ipopt integer option \
            " + key + " is unknown")

    def opt_sim_ipopt_set_num_option(self, key, val):
        """ Set an Ipopt double option.
        
        Parameters::
        
            key -- 
                The name of the option.
            val -- 
                The value of the option.
            
        """
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_num_option(
            self._ipopt_opt, key, val) is not 0:
            raise jmi.JMIException("The Ipopt real option \
            " + key + " is unknown")

    def opt_sim_ipopt_get_statistics(self):
        """ Get statistics from the last optimization run.

        Returns::
        
            return_status -- 
                Return status from IPOPT.
            nbr_iter -- 
                Number of iterations.
            objective -- 
                Final value of objective function.
            total_exec_time -- 
                Execution time.
        """
        return_code = ct.c_int()
        iters = ct.c_int()
        objective = c_jmi_real_t()
        exec_time = c_jmi_real_t()
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_get_statistics(self._ipopt_opt,
                                                                           byref(return_code),
                                                                           byref(iters),
                                                                           byref(objective),
                                                                            byref(exec_time)) is not 0:
            raise jmi.JMIException("Error when retrieve statistics - optimization problem may not be solved.")
        return (return_code.value,iters.value,objective.value,exec_time.value)


class NLPCollocation(object):
    """ NLP interface for a dynamic optimization problem. Abstract class 
    which provides some methods but can not be instantiated. Use together 
    with an implementation of an algorithm by extending this class.
    """

    def __init__(self):
        """ This is an abstract class and can not be instantiated.
        
        Raises::
        
            JMIException if used.
         """
        raise jmi.JMIException("This class can not be instantiated. ")
    
    def _initialize(self, model):
        self._model = model
        self._jmi_opt_sim = ct.c_voidp()
     
    def _set_nlpCollocation_typedefs(self):
        try:
            self._model.jmimodel._dll.jmi_opt_sim_get_dimensions.argtypes = [ct.c_void_p,
                                                                             ct.POINTER(ct.c_int),
                                                                             ct.POINTER(ct.c_int),
                                                                             ct.POINTER(ct.c_int),
                                                                             ct.POINTER(ct.c_int),
                                                                             ct.POINTER(ct.c_int)]
            n_real_x = ct.c_int()
            n_g = ct.c_int()
            n_h = ct.c_int()
            dg_n_nz = ct.c_int()
            dh_n_nz = ct.c_int()
            assert self._model.jmimodel._dll.jmi_opt_sim_get_dimensions(self._jmi_opt_sim, byref(n_real_x), byref(n_g),
                                           byref(n_h), byref(dg_n_nz), byref(dh_n_nz)) \
            is 0, \
               "getting NLP problem dimensions failed"        

            self._model.jmimodel._dll.jmi_opt_sim_get_n_e.argtypes = [ct.c_void_p,
                                                                      ct.POINTER(ct.c_int)]
            
            self._model.jmimodel._dll.jmi_opt_sim_get_interval_spec.argtypes = [ct.c_void_p,
                                                                                ct.POINTER(c_jmi_real_t),
                                                                                ct.POINTER(ct.c_int),
                                                                                ct.POINTER(c_jmi_real_t),
                                                                                ct.POINTER(ct.c_int)]
            self._model.jmimodel._dll.jmi_opt_sim_get_x.argtypes =[ct.c_void_p]
            self._model.jmimodel._dll.jmi_opt_sim_get_initial.argtypes = [ct.c_void_p,
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        shape=n_real_x.value,
                                                                                        flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_set_initial.argtypes =  [ct.c_void_p,
                                                                           Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                         ndim=1,
                                                                                         shape=n_real_x.value,
                                                                                         flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_set_initial_from_trajectory.argtypes = [ct.c_void_p,
                                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                                        ndim=1,
                                                                                                        shape=self._model._n_p_opt,
                                                                                                        flags='C'),
                                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                                        ndim=1,
                                                                                                        flags='C'),
                                                                                          ct.c_int,
                                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                                        ndim=1,
                                                                                                        flags='C'),
                                                                                          c_jmi_real_t,
                                                                                          c_jmi_real_t]
            self._model.jmimodel._dll.jmi_opt_sim_get_bounds.argtypes = [ct.c_void_p,
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=n_real_x.value,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=n_real_x.value,
                                                                                       flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_set_bounds.argtypes = [ct.c_void_p,
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=n_real_x.value,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=n_real_x.value,
                                                                                       flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_f.argtypes = [ct.c_void_p,
                                                                ct.POINTER(c_jmi_real_t)]
            self._model.jmimodel._dll.jmi_opt_sim_df.argtypes = [ct.c_void_p,
                                                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                                                               ndim=1,
                                                                               shape=n_real_x.value,
                                                                               flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_g.argtypes = [ct.c_void_p,
                                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                                              ndim=1,
                                                                              shape=n_g.value,
                                                                              flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_dg.argtypes = [ct.c_void_p,
                                                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                                                               ndim=1,
                                                                               shape=dg_n_nz.value,
                                                                               flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_dg_nz_indices.argtypes = [ct.c_void_p,
                                                                            Nct.ndpointer(dtype=ct.c_int,
                                                                                          ndim=1,
                                                                                          shape=dg_n_nz.value,
                                                                                          flags='C'),
                                                                            Nct.ndpointer(dtype=ct.c_int,
                                                                                          ndim=1,
                                                                                          shape=dg_n_nz.value,
                                                                                          flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_h.argtypes = [ct.c_void_p,
                                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                                              ndim=1,
                                                                              shape=n_h.value,
                                                                              flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_dh.argtypes = [ct.c_void_p,
                                                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                                                               ndim=1,
                                                                               shape=dh_n_nz.value,
                                                                               flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_dh_nz_indices.argtypes = [ct.c_void_p,
                                                                            Nct.ndpointer(dtype=ct.c_int,
                                                                                          ndim=1,
                                                                                          shape=dh_n_nz.value,
                                                                                          flags='C'),
                                                                            Nct.ndpointer(dtype=ct.c_int,
                                                                                          ndim=1,
                                                                                          shape=dh_n_nz.value,
                                                                                          flags='C')]
            self._model.jmimodel._dll.jmi_opt_sim_write_file_matlab.argtypes = [ct.c_void_p,
                                                                                ct.c_char_p]
            self._model.jmimodel._dll.jmi_opt_sim_get_result_variable_vector_length.argtypes = [ct.c_void_p,
                                                                                                ct.POINTER(ct.c_int)]
            timepoints = ct.c_int()
            assert self._model.jmimodel._dll.jmi_opt_sim_get_result_variable_vector_length(self._jmi_opt_sim, byref(timepoints)) \
            is 0, \
               "getting number of points in the independent time vector failed"

            res_dx = timepoints.value*self._model._n_real_dx.value
            res_x = timepoints.value*self._model._n_real_x.value
            res_u = timepoints.value*self._model._n_real_u.value
            res_w = timepoints.value*self._model._n_real_w.value
            self._model.jmimodel._dll.jmi_opt_sim_get_result.argtypes = [ct.c_void_p,
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=self._model._n_p_opt,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=timepoints.value,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=res_dx,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=res_x,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=res_u,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=res_w,
                                                                                       flags='C')]

            self._model.jmimodel._dll.jmi_opt_sim_get_result_element_interpolation.argtypes = [ct.c_void_p,
                                                                                               ct.c_int,
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=self._model._n_p_opt,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C')]
            
            self._model.jmimodel._dll.jmi_opt_sim_get_result_mesh_interpolation.argtypes = [ct.c_void_p,
                                                                                            Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                                          ndim=1,
                                                                                                          flags='C'),
                                                                                               ct.c_int,
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       shape=self._model._n_p_opt,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C'),
                                                                         Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                       ndim=1,
                                                                                       flags='C')]


            # n_real_x from jmi_opt_sim_get_dimensions
            jmi._returns_ndarray(self._model.jmimodel._dll.jmi_opt_sim_get_x, c_jmi_real_t, n_real_x.value, order='C')
        except AttributeError, e:
            pass
       
    def get_result(self):
        """ Get the optimization result. The result is given for the
        collocation points used in the algorithm.
        
        Returns::
        
            p_opt --
                A vector containing the values of the optimized 
                parameters.
            data --
                A two dimensional array of variable trajectory data. The
                first column represents the time vector. The following
                colums contain, in order, the derivatives, the states,
                the inputs and the algebraic variables. The ordering is
                according to increasing value references.
        """
        
        n_points = self.opt_sim_get_result_variable_vector_length()

        sizes = self._model.get_sizes()
        n_real_dx = sizes[12]
        n_real_x = sizes[13]
        n_real_u = sizes[14]
        n_real_w = sizes[15]
        n_popt = self._model.jmimodel.opt_get_n_p_opt()
        
        # Create result data vectors
        p_opt = N.zeros(n_popt)
        t_ = N.zeros(n_points)
        dx_ = N.zeros(n_real_dx*n_points)
        x_ = N.zeros(n_real_x*n_points)
        u_ = N.zeros(n_real_u*n_points)
        w_ = N.zeros(n_real_w*n_points)
        
        # Get the result
        self.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)

        data = N.zeros((n_points,1+n_real_dx+n_real_x+n_real_u+n_real_w))
        data[:,0] = t_
        for i in range(n_real_dx):
            data[:,i+1] = dx_[i*n_points:(i+1)*n_points]
        for i in range(n_real_x):
            data[:,n_real_dx+i+1] = x_[i*n_points:(i+1)*n_points]
        for i in range(n_real_u):
            data[:,n_real_dx+n_real_x+i+1] = u_[i*n_points:(i+1)*n_points]
        for i in range(n_real_w):
            data[:,n_real_dx+n_real_x+n_real_u+i+1] = w_[i*n_points:(i+1)*n_points]

        # If a normalized minimum time problem has been solved,
        # then, the time vector should be rescaled
        n=[names[1] for names in self._model.get_p_opt_variable_names()]
        non_fixed_interval = ('finalTime' in n) or ('startTime' in n)            

        if non_fixed_interval:
            # A minimum time problem has been solved,
            # interval is normalized to [0,1]
            t0 = self._model.get('startTime')
            tf = self._model.get('finalTime')
            for i in range(N.size(data,0)):
                data[i,0] = t0 + data[i,0]*(tf-t0)

        return p_opt, data

    def get_result_element_interpolation(self,n_interpolation_points=20):
        """ Get the optimization results. The variable trajectories are
        evaluated at n_interpolation points inside each finite element. 
        The interpolation points at which the variables are computed are 
        equally spaced, and includes the element start and end points 
        within each finite element. The collocation interpolation 
        polynomials are used to compute the value of the variable 
        trajectories at each point.

        Parameters::
        
            n_interpolation_points --
                The number of points in each finite element at which the
                solution trajectories are evaluated.
                Default: 20
        
        Returns::
        
            p_opt --
                A vector containing the values of the optimized 
                parameters.
            data --
                A two dimensional array of variable trajectory data. The
                first column represents the time vector. The following
                colums contain, in order, the derivatives, the states,
                the inputs and the algebraic variables. The ordering is
                according to increasing value references.
        """

        n_points = self.opt_sim_get_n_e()*n_interpolation_points

        sizes = self._model.get_sizes()
        n_real_dx = sizes[12]
        n_real_x = sizes[13]
        n_real_u = sizes[14]
        n_real_w = sizes[15]
        n_popt = self._model.jmimodel.opt_get_n_p_opt()
        
        # Create result data vectors
        p_opt = N.zeros(n_popt)
        t_ = N.zeros(n_points)
        dx_ = N.zeros(n_real_dx*n_points)
        x_ = N.zeros(n_real_x*n_points)
        u_ = N.zeros(n_real_u*n_points)
        w_ = N.zeros(n_real_w*n_points)
        
        # Get the result
        self.opt_sim_get_result_element_interpolation(
            n_interpolation_points,p_opt,t_,dx_,x_,u_,w_)
        
        data = N.zeros((n_points,1+n_real_dx+n_real_x+n_real_u+n_real_w))
        data[:,0] = t_
        for i in range(n_real_dx):
            data[:,i+1] = dx_[i*n_points:(i+1)*n_points]
        for i in range(n_real_x):
            data[:,n_real_dx+i+1] = x_[i*n_points:(i+1)*n_points]
        for i in range(n_real_u):
            data[:,n_real_dx+n_real_x+i+1] = u_[i*n_points:(i+1)*n_points]
        for i in range(n_real_w):
            data[:,n_real_dx+n_real_x+n_real_u+i+1] = w_[i*n_points:(i+1)*n_points]

        # If a normalized minimum time problem has been solved,
        # then, the time vector should be rescaled
        n=[names[1] for names in self._model.get_p_opt_variable_names()]
        non_fixed_interval = ('finalTime' in n) or ('startTime' in n)            

        if non_fixed_interval:
            # A minimum time problem has been solved,
            # interval is normalized to [0,1]
            t0 = self._model.get_value('startTime')
            tf = self._model.get_value('finalTime')
            for i in range(N.size(data,0)):
                data[i,0] = t0 + data[i,0]*(tf-t0)

        return p_opt, data

    def get_result_mesh_interpolation(self,mesh):
        """ Get the optimization results. The result is given at a user
        defined mesh of time points. The collocation interpolation
        polynomials are used to compute the value of the variable
        trajectories at eachpoint.

        Parameters::
        
            mesh --
                The vector of time points.
        
        Returns::
        
            p_opt --
                A vector containing the values of the optimized 
                parameters.
            data --
                A two dimensional array of variable trajectory data. The
                first column represents the time vector. The following
                colums contain, in order, the derivatives, the states,
                the inputs and the algebraic variables. The ordering is
                according to increasing value references.
        """

        n_points = len(mesh)

        sizes = self._model.get_sizes()
        n_real_dx = sizes[12]
        n_real_x = sizes[13]
        n_real_u = sizes[14]
        n_real_w = sizes[15]
        n_popt = self._model.jmimodel.opt_get_n_p_opt()
        
        # Create result data vectors
        p_opt = N.zeros(n_popt)
        t_ = N.zeros(n_points)
        dx_ = N.zeros(n_real_dx*n_points)
        x_ = N.zeros(n_real_x*n_points)
        u_ = N.zeros(n_real_u*n_points)
        w_ = N.zeros(n_real_w*n_points)
        
        # Get the result
        self.opt_sim_get_result_mesh_interpolation(mesh,n_points,p_opt,t_,dx_,x_,u_,w_)
        
        data = N.zeros((n_points,1+n_real_dx+n_real_x+n_real_u+n_real_w))
        data[:,0] = t_
        for i in range(n_real_dx):
            data[:,i+1] = dx_[i*n_points:(i+1)*n_points]
        for i in range(n_real_x):
            data[:,n_real_dx+i+1] = x_[i*n_points:(i+1)*n_points]
        for i in range(n_real_u):
            data[:,n_real_dx+n_real_x+i+1] = u_[i*n_points:(i+1)*n_points]
        for i in range(n_real_w):
            data[:,n_real_dx+n_real_x+n_real_u+i+1] = w_[i*n_points:(i+1)*n_points]

        # If a normalized minimum time problem has been solved,
        # then, the time vector should be rescaled
        n=[names[1] for names in self._model.get_p_opt_variable_names()]
        non_fixed_interval = ('finalTime' in n) or ('startTime' in n)            

        if non_fixed_interval:
            # A minimum time problem has been solved,
            # interval is normalized to [0,1]
            t0 = self._model.get_value('startTime')
            tf = self._model.get_value('finalTime')
            for i in range(N.size(data,0)):
                data[i,0] = t0 + data[i,0]*(tf-t0)

        return p_opt, data

    def export_result_dymola(self, file_name='', format='txt'):
        """ Export the optimization result in Dymola format. The 
        function get_result is used to retrieve the solution 
        trajectories. The result is given at the collocation points.

        Parameters::
        
            file_name --
                The name of the result file.
                Default: Empty string.
            format --
                A string equal either to 'txt' for output to Dymola 
                textual format or 'mat' for output to Dymola binary 
                Matlab format.
                Default: 'txt'

        Limitations::
        
            Only format='txt' is currently supported.
        """

        # Get results
        p_opt, data = self.get_result()
        
        # Write result
        io.export_result_dymola(self._model,data, file_name=file_name, format=format)

    def export_result_dymola_element_interpolation(self, n_interpolation_points=20, file_name='', format='txt'):
        """ Export the optimization result in Dymola format. The 
        function export_result_dymola_element_interpolation is used to 
        retrieve the solution trajectories. 
        
        Parameters::
        
            n_interpolation_points --
                The number of points in each finite element at which the 
                result is returned.
                Default: 20
            file_name --
                The name of the result file.
                Default: Empty string.
            format --
                A string equal either to 'txt' for output to Dymola 
                textual format or 'mat' for output to Dymola binary 
                Matlab format.
                Default: 'txt'

        Limitations::
        
            Only format='txt' is currently supported.
        """

        # Get results
        p_opt, data = self.get_result_element_interpolation(
            n_interpolation_points)
        
        # Write result
        io.export_result_dymola(
            self._model,data, file_name=file_name, format=format)

    def export_result_dymola_mesh_interpolation(self, mesh, file_name='', 
        format='txt'):
        """ Export the optimization result in Dymola format. The 
        function export_result_dymola_element_interpolation is used to 
        retrieve the solution trajectories. 

        Parameters::
        
            mesh --
                A vector of time points at wich the result is given. 
            file_name --
                The name of the result file.
                Default: Empty string.
            format --
                A string equal either to 'txt' for output to Dymola 
                textual format or 'mat' for output to Dymola binary 
                Matlab format.
                Default: 'txt'

        Limitations::
        
            Only format='txt' is currently supported.
        """

        # Get results
        p_opt, data = self.get_result_mesh_interpolation(mesh)
        
        # Write result
        io.export_result_dymola(self._model,data, file_name=file_name, format=format)


    def set_initial_from_dymola(self,res, hs_init, start_time_init, final_time_init):
        """ Initialize the optimization vector from an object of either 
        ResultDymolaTextual or ResultDymolaBinary.

        Parameters::
        
            res --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary.
            hs_init -- 
                A vector of length n_e containing initial guesses of the
                normalized lengths of the finite elements. This argument 
                is neglected if the problem does not have free element 
                lengths.
            start_time_init --
                The initial guess of the interval start time. This 
                argument is neglected if the start time is fixed.
            final_time_init --
                The initial guess of the interval final time. This 
                argument is neglected if the final time is fixed.
        """
        # Obtain the names
        names = self._model.get_dx_variable_names(include_alias=False)
        dx_names=[]
        for name in sorted(names):
            dx_names.append(name[1])

        names = self._model.get_x_variable_names(include_alias=False)
        x_names=[]
        for name in sorted(names):
            x_names.append(name[1])


        names = self._model.get_u_variable_names(include_alias=False)
        u_names=[]
        for name in sorted(names):
            u_names.append(name[1])

        names = self._model.get_w_variable_names(include_alias=False)
        w_names=[]
        for name in sorted(names):
            w_names.append(name[1])

        names = self._model.get_p_opt_variable_names(include_alias=False)
        p_opt_names=[]
        for name in sorted(names):
            p_opt_names.append(name[1])
        
        # Obtain vector sizes
        n_points = 0
        num_name_hits = 0
        if len(dx_names) > 0:
            for name in dx_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(x_names) > 0:
            for name in x_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(u_names) > 0:
            for name in u_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(w_names) > 0:
            for name in w_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass
        else:
            raise Exception("None of the model variables not found in result file.")

        if num_name_hits==0:
            raise Exception("None of the model variables not found in result file.")
        
        #print(traj.t)
        
        n_points = N.size(traj.t,0)
        n_cols = 1+len(dx_names)+len(x_names)+len(u_names)+len(w_names)

        var_data = N.zeros((n_points,n_cols))
        # Initialize time vector
        var_data[:,0] = traj.t;

        p_opt_data = N.zeros(len(p_opt_names))

        sc = self._model.jmimodel.get_variable_scaling_factors()

        # Get the parameters
        n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()

            for name in p_opt_names:
                try:
                    ref = self._model.get_value_reference(name)
                    (z_i, ptype) = jmi._translate_value_ref(ref)
                    i_pi = z_i - self._model._offs_real_pi.value
                    i_pi_opt = p_opt_indices.index(i_pi)
                    traj = res.get_variable_data(name)
                    if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                        p_opt_data[i_pi_opt] = traj.x[0]/sc[z_i]
                    else:
                        p_opt_data[i_pi_opt] = traj.x[0]
                except VariableNotFoundError:
                    print "Warning: Could not find value for parameter " + name
                    
        #print(N.size(var_data))

        # Initialize variable names
        # Loop over all the names

        sc_dx = self._model.jmimodel.get_variable_scaling_factors()[self._model._offs_real_dx.value:self._model._offs_real_x.value]
        sc_x = self._model.jmimodel.get_variable_scaling_factors()[self._model._offs_real_x.value:self._model._offs_real_u.value]
        sc_u = self._model.jmimodel.get_variable_scaling_factors()[self._model._offs_real_u.value:self._model._offs_real_w.value]
        sc_w = self._model.jmimodel.get_variable_scaling_factors()[self._model._offs_real_w.value:self._model._offs_t.value]

        col_index = 1;
        dx_index = 0;
        x_index = 0;
        u_index = 0;
        w_index = 0;
        for name in dx_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                    var_data[:,col_index] = traj.x/sc_dx[dx_index]
                else:
                    var_data[:,col_index] = traj.x
                dx_index = dx_index + 1
                col_index = col_index + 1
            except:
                dx_index = dx_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for derivative variable " + name
        for name in x_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                    var_data[:,col_index] = traj.x/sc_x[x_index]
                else:
                    var_data[:,col_index] = traj.x
                x_index = x_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                x_index = x_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for state variable " + name

        for name in u_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                    var_data[:,col_index] = traj.x/sc_u[u_index]
                else:
                    var_data[:,col_index] = traj.x
                u_index = u_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                u_index = u_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for input variable " + name

        for name in w_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if N.size(traj.x)==2:
                    if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                        var_data[:,col_index] = N.ones(n_points)*traj.x[0]/sc_w[w_index]
                    else:
                        var_data[:,col_index] = N.ones(n_points)*traj.x[0]
                else:
                    if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                        var_data[:,col_index] = traj.x/sc_w[w_index]
                    else:
                        var_data[:,col_index] = traj.x
                w_index = w_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                w_index = w_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for algebraic variable " + name

        #print(var_data)
        #print(N.reshape(var_data,(n_cols*n_points,1),order='F')[:,0])
            
        self.opt_sim_set_initial_from_trajectory(p_opt_data,N.reshape(var_data,(n_cols*n_points,1),order='F')[:,0],N.size(var_data,0),
                                                 hs_init,start_time_init,final_time_init)
        
    def opt_sim_get_dimensions(self):
        """ Get the number of variables and the number of constraints in 
        the problem.
        
        Returns::
        
            Tuple with the number of variables in the NLP problem, 
            inequality constraints, equality constraints, non-zeros in 
            the Jacobian of the inequality constraints and non-zeros in 
            the Jacobian of the equality constraints respectively. 
            
        """
        n_real_x = ct.c_int()
        n_g = ct.c_int()
        n_h = ct.c_int()
        dg_n_nz = ct.c_int()
        dh_n_nz = ct.c_int()
        if self._model.jmimodel._dll.jmi_opt_sim_get_dimensions(
            self._jmi_opt_sim, byref(n_real_x), byref(n_g), byref(n_h), 
            byref(dg_n_nz), byref(dh_n_nz)) is not 0:
            raise jmi.JMIException("Getting the number of variables and \
            constraints failed.")
        return n_real_x.value, n_g.value, n_h.value, dg_n_nz.value, dh_n_nz.value

    def opt_sim_get_n_e(self):
        """ Get the number of finite elements.
        
        Returns::
        
            The number of inite elements         
        """
        n_e = ct.c_int()
        if self._model.jmimodel._dll.jmi_opt_sim_get_n_e(
            self._jmi_opt_sim,byref(n_e)) is not 0:
            raise jmi.JMIException("Getting the optimization interval \
            data failed.")
        return n_e.value

    def opt_sim_get_interval_spec(self, start_time, start_time_free, 
        final_time, final_time_free):
        """ Get data that specifies the optimization interval.
        
        Parameters::
        
            start_time -- 
                The optimization interval start time. (Return variable)
            start_time_free -- 
                0 if start time should be fixed or 1 if free. (Return 
                variable)
            final_time -- 
                The optimization final time. (Return variable)
            final_time_free -- 
                0 if start time should be fixed or 1 if free. (Return 
                variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_interval_spec(
            self._jmi_opt_sim, start_time, start_time_free, final_time, 
            final_time_free) is not 0:
            raise jmi.JMIException("Getting the optimization interval \
            data failed.")
        
    def opt_sim_get_x(self):
        """ Get the x vector of the NLP. 
        
        Returns::
        
            The x vector of the NLP.
        """
        return self._model.jmimodel._dll.jmi_opt_sim_get_x(
            self._jmi_opt_sim)

    def opt_sim_get_initial(self, x_init):
        """ Get the initial point of the NLP.
        
        Parameters::
        
            x_init -- 
                The initial guess vector. (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_initial(
            self._jmi_opt_sim, x_init) is not 0:
            raise jmi.JMIException("Getting the initial point failed.")

    def opt_sim_set_initial(self, x_init):
        """ Set the initial point of the NLP.

        Parameters::
        
            x_init --- 
                The initial guess vector.
        """
        if self._model.jmimodel._dll.jmi_opt_sim_set_initial(self._jmi_opt_sim, x_init) is not 0:
            raise jmi.JMIException("Setting the initial point failed.")
 
    def opt_sim_set_initial_from_trajectory(self, p_opt_init, 
        trajectory_data_init, traj_n_points, hs_init, start_time_init, 
        final_time_init):
        """ Set the initial point based on time series trajectories of 
        the variables of the problem.

        Also, initial guesses for the optimization interval and element 
        lengths are provided.

        Parameters::
        
            p_opt_init --
                A vector of size n_p_opt containing initial values for 
                the optimized parameters.
            trajectory_data_init --
                A matrix stored in column major format. The first column 
                contains the time vector. The following column contains, 
                in order, the derivative, state, input, and algebraic
                variable profiles.
            traj_n_points --
                The number of time points in trajectory_data_init.
            hs_init --
                A vector of length n_e containing initial guesses of the
                normalized lengths of the finite elements. This argument 
                is neglected if the problem does not have free element 
                lengths.
            start_time_init --
                The initial guess of interval start time. This argument 
                is neglected if the start time is fixed.
            final_time_init --
                The initial guess of interval final time. This argument 
                is neglected if the final time is fixed.
        """
        # check sum (n_real_x, n_real_dx, n_real_u, n_real_w +1 (time)) mult with traj_n_points = size trajectory_data_init
        sum = self._model._n_real_x.value + self._model._n_real_dx.value \
            + self._model._n_real_u.value + self._model._n_real_w.value + 1
        if sum*traj_n_points != len(trajectory_data_init):
            raise jmi.JMIException("trajectory_data_init vector has the wrong size.")        
        if self._model.jmimodel._dll.jmi_opt_sim_set_initial_from_trajectory(
            self._jmi_opt_sim, \
            p_opt_init, \
            trajectory_data_init, \
            traj_n_points, \
            hs_init, \
            start_time_init, \
            final_time_init) is not 0:
            raise jmi.JMIException("Setting the initial point failed.")

    def opt_sim_get_bounds(self, x_lb, x_ub):
        """ Get the upper and lower bounds of the optimization variables.
        
        Parameters::
        
            x_lb -- 
                The lower bounds vector. (Return variable)
            x_ub -- 
                The upper bounds vector. (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_bounds(
            self._jmi_opt_sim, x_lb, x_ub) is not 0:
            raise jmi.JMIException("Getting upper and lower bounds of \
            the optimization variables failed.")

    def opt_sim_set_bounds(self, x_lb, x_ub):
        """ Set the upper and lower bounds of the optimization variables.
        
        Parameters::
        
            x_lb -- 
                The lower bounds vector. (Return variable)
            x_ub -- 
                The upper bounds vector. (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_set_bounds(
            self._jmi_opt_sim, x_lb, x_ub) is not 0:
            raise jmi.JMIException("Getting upper and lower bounds of \
            the optimization variables failed.")
        
    def opt_sim_f(self, f):
        """ Get the cost function value at a given point in search space.
        
        Parameters::
        
            f -- 
                Value of the cost function. (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_f(self._jmi_opt_sim, f) is not 0:
            raise jmi.JMIException("Getting the cost function failed.")
        
    def opt_sim_df(self, df):
        """ Get the gradient of the cost function value at a given point 
        in search space.
        
        Parameters::
        
            df -- 
                Value of the gradient of the cost function. (Return 
                variable)
            
        """
        if self._model.jmimodel._dll.jmi_opt_sim_df(
            self._jmi_opt_sim, df) is not 0:
            raise jmi.JMIException("Getting the gradient of the cost \
            function value failed.")
        
    def opt_sim_g(self, res):
        """ Get the residual of the inequality constraints g.
        
        Parameters::
        
            res -- 
                The residual of the inequality constraints. (Return 
                variable)
            
        """
        if self._model.jmimodel._dll.jmi_opt_sim_g(
            self._jmi_opt_sim, res) is not 0:
            raise jmi.JMIException("Getting the residual of the \
            inequality constraints failed.")
        
    def opt_sim_dg(self, jac):
        """ Get the Jacobian of the residual of the inequality 
        constraints.
        
        Parameters::
        
            jac -- 
                The Jacobian of the residual of the inequality 
                constraints. (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dg(
            self._jmi_opt_sim, jac) is not 0:
            raise jmi.JMIException("Getting the Jacobian of the residual \
            of the inequality constraints failed.")
        
    def opt_sim_dg_nz_indices(self, irow, icol):
        """ Get the indices of the non-zeros in the inequality 
        constraint Jacobian.
        
        Parameters::
        
            irow -- 
                The row indices of the non-zero entries in the Jacobian 
                of the residual of the inequality constraints. (Return 
                variable)
            icol --- 
                The column indices of the non-zero entries in the 
                Jacobian of the residual of the inequality constraints. 
                (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dg_nz_indices(
            self._jmi_opt_sim, irow, icol) is not 0:
            raise jmi.JMIException("Getting the indices of the non-zeros \
            in the equality constraint Jacobian failed.")
        
    def opt_sim_h(self, res):
        """ Get the residual of the equality constraints h.
        
        Parameters::
        
            res -- 
                The residual of the equality constraints. (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_h(
            self._jmi_opt_sim, res) is not 0:
            raise jmi.JMIException("Getting the residual of the equality \
            constraints failed.")
        
    def opt_sim_dh(self, jac):
        """ Get the Jacobian of the residual of the equality constraints.
        
        Parameters::
        
            jac -- 
                The Jacobian of the residual of the equality constraints. 
                (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dh(
            self._jmi_opt_sim, jac) is not 0:
            raise jmi.JMIException("Getting the Jacobian of the residual \
            of the equality constraints.")
        
    def opt_sim_dh_nz_indices(self, irow, icol):
        """ Get the indices of the non-zeros in the equality constraint 
        Jacobian.
        
        Parameters::
        
            irow -- 
                The row indices of the non-zero entries in the Jacobian 
                of the residual of the equality constraints. (Return 
                variable)
            icol -- 
                The column indices of the non-zero entries in the 
                Jacobian of the residual of the equality constraints. 
                (Return variable)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dh_nz_indices(
            self._jmi_opt_sim, irow, icol) is not 0:
            raise jmi.JMIException("Getting the indices of the non-zeros \
            in the equality constraint Jacobian failed.")
        
    def opt_sim_write_file_matlab(self, file_name):
        """ Write the optimization result to file in Matlab format.
        
        Parameters::
        
            file_name -- 
                The name of file to write to.
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_write_file_matlab(
            self._jmi_opt_sim, file_name) is not 0:
            raise jmi.JMIException("Writing the optimization result to \
            file in Matlab format failed.")
        
    def opt_sim_get_result_variable_vector_length(self):
        """ Get the length of the result variable vectors. 
        
        Returns::
        
            The length of the result variable vectors.
        
        """
        n = ct.c_int()
        if self._model.jmimodel._dll.jmi_opt_sim_get_result_variable_vector_length(
            self._jmi_opt_sim, byref(n)) is not 0:
            raise jmi.JMIException("Getting the length of the result \
            variable vectors failed.")
        return n.value
        
    def opt_sim_get_result(self, p_opt, t, dx, x, u, w):
        """ Get the results, stored in column major format.
        
        Parameters::
        
            p_opt -- 
                The vector containing optimal parameter values. (Return 
                variable)
            t -- 
                The time vector. (Return variable)
            dx -- 
                The derivatives. (Return variable)
            x -- 
                The states. (Return variable)
            u -- 
                The inputs. (Return variable)
            w -- 
                The algebraic variables. (Return variable)
             
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_result(
            self._jmi_opt_sim, p_opt, t, dx, x, u, w) is not 0:
            raise jmi.JMIException("Getting the results failed.")

    def opt_sim_get_result_element_interpolation(self, 
        n_interpolation_points, p_opt, t, dx, x, u, w):
        """ Get the results, stored in column major format.
        
        Parameters::
        
            n_interpolation_points -- 
                The number of time points in each element.
            p_opt -- 
                The vector containing optimal parameter values. (Return 
                variable)
            t -- 
                The time vector. (Return variable)
            dx -- 
                The derivatives. (Return variable)
            x -- 
                The states. (Return variable)
            u -- 
                The inputs. (Return variable)
            w -- 
                The algebraic variables. (Return variable)
             
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_result_element_interpolation(
            self._jmi_opt_sim, n_interpolation_points,p_opt, t, dx, x, u, w) is not 0:
            raise jmi.JMIException("Getting the results failed.")

    def opt_sim_get_result_mesh_interpolation(self, mesh, n_mesh, p_opt, 
        t, dx, x, u, w):
        """ Get the results, stored in column major format.
        
        Parameters::
        
            mesh -- 
                The mesh of time points.
            p_opt -- 
                The vector containing optimal parameter values. (Return 
                variable)
            t -- 
                The time vector. (Return variable)
            dx -- 
                The derivatives. (Return variable)
            x -- 
                The states. (Return variable)
            u -- 
                The inputs. (Return variable)
            w -- 
                The algebraic variables. (Return variable)
             
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_result_mesh_interpolation(
            self._jmi_opt_sim, mesh,n_mesh,p_opt, t, dx, x, u, w) is not 0:
            raise jmi.JMIException("Getting the results failed.")
            

class NLPCollocationLagrangePolynomials(NLPCollocation):
    """ An implementation of a transcription method based on Lagrange 
    polynomials and Radau points. Extends the abstract class 
    NLPCollocation. 
    """
    
    def __init__(self, model, n_e, hs, n_cp, blocking_factors=N.array([],
        dtype=int)):
        """ Constructor where main data structure is created. 
        
        Initial guesses, lower and upper bounds and linearity
        information is set for optimized parameters, derivatives,
        states, inputs and algebraic variables. These values are taken
        from the XML files created at compilation.

        Blocking factors are specified by a vector of integers, where
        each entry in the vector corresponds to the number of elements
        for which the control profile should be kept constant. For
        example, the blocking factor specification [2,1,5] means that
        u_0=u_1 and u_3=u_4=u_5=u_6=u_7 assuming that the
        number of elements is 8. Notice that specification of blocking
        factors implies that controls are present in only one
        collocation point (the first) in each element. The number of
        constant control levels in the optimization interval is equal
        to the length of the blocking factor vector. In the example
        above, this implies that there are three constant control
        levels. If the sum of the entries in the blocking factor
        vector is not equal to the number of elements, the vector is
        normalized, either by truncation (if the sum of the entries is
        larger than the number of element) or by increasing the last
        entry of the vector. For example, if the number of elements is
        4, the normalized blocking factor vector in the example is
        [2,2]. If the number of elements is 10, then the normalized
        vector is [2,1,7].
        
        Parameters::
        
            model -- 
                The jmodelica.jmi.JMUModel object.
            n_e -- 
                The number of finite elements.
            hs -- 
                The vector containing the normalized element lengths.
            n_cp -- 
                The number of collocation points. 
            blocking_factors -- 
                The blocking factor vector.
        """

        if model._n_sw.value>0 or model._n_sw_init.value>0:
            raise Exception("The collocation optimization algorithm does not support models with events. Please consider using the noEvent() operator or rewriting the model.")
        
        if len(hs) != n_e:
            raise jmi.JMIException("arg hs is not of length n_e")
        
        self._model=model
        self._n_e = n_e
        self._n_cp = n_cp
        self._hs=hs
        self.n_p_opt=model.jmimodel.opt_get_n_p_opt()

        self._blocking_factors = N.int32(blocking_factors)
        
        NLPCollocation._initialize(self, model)
        self._set_nlpLagrangePols_typedefs()
        
        # Initialization
        _p_opt_init = N.zeros(self.n_p_opt)
        _dx_init = N.zeros(model._n_real_dx.value)
        _x_init = N.zeros(model._n_real_x.value)
        _u_init = N.zeros(model._n_real_u.value)
        _w_init = N.zeros(model._n_real_w.value)
    
        # Bounds
        _p_opt_lb = -1.0e20*N.ones(self.n_p_opt)
        _dx_lb = -1.0e20*N.ones(model._n_real_dx.value)
        _x_lb = -1.0e20*N.ones(model._n_real_x.value)
        _u_lb = -1.0e20*N.ones(model._n_real_u.value)
        _w_lb = -1.0e20*N.ones(model._n_real_w.value)
        _t0_lb = 0.; # not yet supported
        _tf_lb = 0.; # not yet supported
        _hs_lb = N.zeros(n_e); # not yet supported
        
        _p_opt_ub = 1.0e20*N.ones(self.n_p_opt)
        _dx_ub = 1.0e20*N.ones(model._n_real_dx.value)
        _x_ub = 1.0e20*N.ones(model._n_real_x.value)
        _u_ub = 1.0e20*N.ones(model._n_real_u.value)
        _w_ub = 1.0e20*N.ones(model._n_real_w.value)
        _t0_ub = 0.; # not yet supported
        _tf_ub = 0.; # not yet supported
        _hs_ub = N.zeros(n_e); # not yet supported
                
        # default values
        hs_free = 0
        
        self._model._set_initial_values(_p_opt_init, _dx_init, _x_init, _u_init, _w_init)
        self._model._set_lb_values(_p_opt_lb, _dx_lb, _x_lb, _u_lb, _w_lb)
        self._model._set_ub_values(_p_opt_ub, _dx_ub, _x_ub, _u_ub, _w_ub)

        _linearity_information_provided = 1;
        _p_opt_lin = N.ones(self.n_p_opt,dtype=int)
        _dx_lin = N.ones(model._n_real_dx.value,dtype=int)
        _x_lin = N.ones(model._n_real_x.value,dtype=int)
        _u_lin = N.ones(model._n_real_u.value,dtype=int)        
        _w_lin = N.ones(model._n_real_w.value,dtype=int)
        _dx_tp_lin = N.ones(model._n_real_dx.value*model._n_tp.value,dtype=int)
        _x_tp_lin = N.ones(model._n_real_x.value*model._n_tp.value,dtype=int)
        _u_tp_lin = N.ones(model._n_real_u.value*model._n_tp.value,dtype=int)        
        _w_tp_lin = N.ones(model._n_real_w.value*model._n_tp.value,dtype=int)

        self._model._set_lin_values(_p_opt_lin, _dx_lin, _x_lin, _u_lin,
            _w_lin, _dx_tp_lin, _x_tp_lin, _u_tp_lin, _w_tp_lin)

        try:       
            assert model.jmimodel._dll.jmi_opt_sim_lp_new(
                byref(self._jmi_opt_sim), model.jmimodel._jmi, n_e, hs, 
                hs_free, _p_opt_init, _dx_init, _x_init, _u_init, _w_init,
                _p_opt_lb, _dx_lb, _x_lb,_u_lb, _w_lb, _t0_lb, _tf_lb, 
                _hs_lb, _p_opt_ub, _dx_ub, _x_ub, _u_ub, _w_ub, _t0_ub,
                _tf_ub, _hs_ub, _linearity_information_provided, 
                _p_opt_lin, _dx_lin, _x_lin, _u_lin, _w_lin, _dx_tp_lin, 
                _x_tp_lin, _u_tp_lin, _w_tp_lin, n_cp,
                jmi.JMI_DER_CPPAD,N.size(self._blocking_factors),
                self._blocking_factors) is 0, \
                " jmi_opt_lp_new returned non-zero."
        except AttributeError,e:
             raise jmi.JMIException("Can not create \
             NLPCollocationLagrangePolynomials object. Try recompiling \
             model with target='algorithms'")
        
        assert self._jmi_opt_sim.value is not None, \
            "jmi_opt_sim_lp struct has not returned correctly."
                        
        self._set_nlpCollocation_typedefs()
            
    def __del__(self):
        """ Free jmi_opt_sim data structure. """
        try:
            assert self._model.jmimodel._dll.jmi_opt_sim_lp_delete(
                self._jmi_opt_sim) == 0, \
                   "jmi_delete failed"
        except AttributeError, e:
            pass

    def _set_nlpLagrangePols_typedefs(self):
        try:
            self._model.jmimodel._dll.jmi_opt_sim_lp_new.argtypes = [ct.c_void_p,                                   # jmi_opt_sim
                                                                     ct.c_void_p,                                   # jmi
                                                                     ct.c_int,                                      # n_e
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # hs             
                                                                                   ndim=1,
                                                                                   shape=self._n_e,
                                                                                   flags='C'),
                                                                     ct.c_int,                                      # hs_free               
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # p_opt_init             
                                                                                   ndim=1,
                                                                                   shape=self.n_p_opt,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # dx_init             
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_dx.value,   
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # x_init
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_x.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # u_init              
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_u.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # w_init
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_w.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # p_opt_lb
                                                                                   ndim=1,
                                                                                   shape=self.n_p_opt,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # dx_lb
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_dx.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # x_lb
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_x.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # u_lb
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_u.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # w_lb
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_w.value,
                                                                                   flags='C'),
                                                                     c_jmi_real_t,                                  # t0_lb
                                                                     c_jmi_real_t,                                  # tf_lb
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # hs_lb
                                                                                   ndim=1,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # p_opt_ub
                                                                                   ndim=1,
                                                                                   shape=self.n_p_opt,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # dx_ub
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_dx.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # x_ub
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_x.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # u_ub
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_u.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # w_ub
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_w.value,
                                                                                   flags='C'),
                                                                     c_jmi_real_t,                                  # t0_ub
                                                                     c_jmi_real_t,                                  # tf_ub
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,              # hs_ub
                                                                                   ndim=1,
                                                                                   flags='C'),
                                                                     ct.c_int,                                      # linearity_information_provided
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # p_opt_lin
                                                                                   ndim=1,
                                                                                   shape=self.n_p_opt,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # dx_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_dx.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # x_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_x.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # u_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_u.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # w_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_w.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # dx_tp_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_dx.value*self._model._n_tp.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # x_tp_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_x.value*self._model._n_tp.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # u_tp_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_u.value*self._model._n_tp.value,
                                                                                   flags='C'),                                           
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # w_tp_lin
                                                                                   ndim=1,
                                                                                   shape=self._model._n_real_w.value*self._model._n_tp.value,
                                                                                   flags='C'),                                           
                                                                     ct.c_int,                                      # n_cp
                                                                     ct.c_int,                                      # der_eval_alg
                                                                     ct.c_int,                                      #n_blocking_factors
                                                                     Nct.ndpointer(dtype=ct.c_int,                  # blocking_factors
                                                                                   ndim=1,
                                                                                   shape=N.size(self._blocking_factors),
                                                                                   flags='C')]                                           
   
            self._model.jmimodel._dll.jmi_opt_sim_lp_delete.argtypes = [ct.c_void_p]
            self._model.jmimodel._dll.jmi_opt_sim_lp_eval_pol.argtypes = [c_jmi_real_t,
                                                                          ct.c_int,
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          ct.c_int]
            self._model.jmimodel._dll.jmi_opt_sim_lp_get_pols.argtypes = [ct.c_int,
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                       flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C'),
                                                                          Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                        ndim=1,
                                                                                        flags='C')]
        except AttributeError, e:
            pass
        
    def opt_sim_lp_eval_pol(self, tau, n, pol, k):
        """ Evaluate Lagrange polynomial. 
        
        Parameters::
        
            tau -- 
                The value of independent variable in polynomial 
                evaluation.
            n -- 
                The order of polynomials.
            pol -- 
                The vector containing the polynomial coefficients. 
            k -- 
                Specify evaluation of the k:th Lagrange polynomial.
        """
        if len(pol)!=n*n:
            raise jmi.JMIException("argument pol has the wrong size. Should be n*n.")
        if self._model.jmimodel._dll.jmi_opt_sim_lp_eval_pol(tau, n, pol, k) is not 0:
            raise jmi.JMIException("Evaluating Lagrange polynomial failed.")
        
    
    def opt_sim_lp_get_pols(self, n_cp, cp, cpp, Lp_coeffs, Lpp_coeffs, 
        Lp_dot_coeffs, Lpp_dot_coeffs, Lp_dot_vals, Lpp_dot_vals):
        """ Get the Lagrange polynomials of a specified order.
        
        Parameters::
        
            n_cp -- 
                The number of collocation points.
            cp -- 
                The Radau collocation points for polynomials of order 
                n_cp-1. (Return variable)
            cpp -- 
                The Radau collocation points for polynomials of order 
                n_cp. (Return variable)
            Lp_coeffs -- 
                The polynomial coefficients for polynomials based on the 
                points given by cp. (Return variable)
            Lp_dot_coeffs -- 
                The polynomial coefficients for polynomials based on the 
                points given by cpp. (Return variable)
            Lpp__dot_coeffs -- 
                The polynomial coefficients for the derivatives of the 
                polynomials based on the cp points. (Return variable)
            Lp_dot_vals -- 
                The values of the derivatives of the cp polynomials when 
                evaluated at the Radau collocation points.(Return 
                variable)
            Lpp_dot_vals --  
                The values of the derivatives of the cpp polynomials 
                when evaluated at the collocation points. (Return 
                variable)
            
        """
        self._model.jmimodel._dll.jmi_opt_sim_lp_get_pols.argtypes = [ct.c_int,
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=self._n_cp-1,
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=self._n_cp,
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=self._n_cp*self._n_cp,
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=(self._n_cp+1)*(self._n_cp+1),
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=self._n_cp*(self._n_cp-1),
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=(self._n_cp+1)*self._n_cp,
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=self._n_cp,
                                                                                    flags='C'),
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=self._n_cp+1,
                                                                                    flags='C')]

        if self._model.jmimodel._dll.jmi_opt_sim_lp_get_pols(n_cp, cp, cpp, Lp_coeffs, Lpp_coeffs, Lp_dot_coeffs, 
                                                        Lpp_dot_coeffs, Lp_dot_vals, Lpp_dot_vals) is not 0:
            raise jmi.JMIException("Getting sim lp pols failed.")

