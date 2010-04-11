# -*- coding: utf-8 -*-
""" The IPOPT solver module. """
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

import ctypes as ct
from ctypes import byref
import numpy as N
import numpy.ctypeslib as Nct

from jmodelica import jmi

int = N.int32
N.int = N.int32

c_jmi_real_t = ct.c_double

class InitializationOptimizer(object):
    """ An interface to the NLP solver Ipopt. """
    
    def __init__(self, nlp_init):
        
        """ 
        Class for solving a DAE initialization problem my means
        of optimization using IPOPT.
        
        Parameters:
            nlp_init -- NLPInitialization object.
        
        """
        
        self._nlp_init = nlp_init
        self._ipopt_init = ct.c_voidp()
        
        self._set_initOpt_typedefs()
        
        try:
            assert self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_new(byref(self._ipopt_init), 
                                                                         self._nlp_init._jmi_init_opt) == 0, \
                   "jmi_init_opt_ipopt_new returned non-zero"
        except AttributeError, e:
            raise jmi.JMIException("Can not create InitializationOptimizer object. Please recompile model with target='ipopt")
        
        assert self._ipopt_init.value is not None, \
               "jmi struct not returned correctly"
               
    def _set_initOpt_typedefs(self):
        try:
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_new.argtypes = [ct.c_void_p,
                                                                              ct.c_void_p]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_solve.argtypes = [ct.c_void_p]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_string_option.argtypes = [ct.c_void_p,
                                                                                            ct.c_char_p,
                                                                                            ct.c_char_p]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_int_option.argtypes = [ct.c_void_p,
                                                                                         ct.c_char_p,
                                                                                         ct.c_int]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_num_option.argtypes = [ct.c_void_p,
                                                                                         ct.c_char_p,
                                                                                         c_jmi_real_t]
        except AttributeError, e:
            pass        
               
    def init_opt_ipopt_solve(self):
        """ Solve the NLP problem."""
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_solve(self._ipopt_init) is not 0:
            raise jmi.JMIException("Solving IPOPT failed.")
    
    def init_opt_ipopt_set_string_option(self, key, val):
        """
        Set Ipopt string option.
        
        Parameters:
            key -- Name of option.
            val -- Value of option.
            
        """
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_string_option(self._ipopt_init, key, val) is not 0:
            raise jmi.JMIException("Setting string option failed.")
        
    def init_opt_ipopt_set_int_option(self, key, val):
        """
        Set Ipopt integer option.
        
        Parameters:
            key -- Name of option.
            val -- Value of option.
            
        """        
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_int_option(self._ipopt_init, key, val) is not 0:
            raise jmi.JMIException("Setting int option failed.")

    def init_opt_ipopt_set_num_option(self, key, val):
        """
        Set Ipopt double option.
        
        Parameters:
            key -- Name of option.
            val -- Value of option.
            
        """
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_num_option(self._ipopt_init, key, val) is not 0:
            raise jmi.JMIException("Setting num option failed.")

class NLPInitialization(object):
    """
    NLP interface for a DAE initialization optimization
    problem.    
    """    
    def __init__(self, model, stat = 0):
        """
        Constructor where main data structure is created. 
        
        Initial guesses, lower and upper bounds and linearity information is 
        set for optimized parameters, derivatives, states, inputs and 
        algebraic variables. These values are taken from the XML files created 
        at compilation.
        
        Parameters:
            model -- The Model object.
        
        """
        self._jmi_init_opt = ct.c_voidp() 
        self._model = model
        self._jmi_model = model.jmimodel

        self._n_p_free = 0
        self._p_free_indices = N.ones(self._n_p_free,dtype=int)

        self._n_p_opt=model.jmimodel.opt_get_n_p_opt()

        # Initialization
        _p_opt_start = N.zeros(self._n_p_opt) 
        _p_free_start = N.zeros(self._n_p_free) # Not supported
        _dx_start = N.zeros(model._n_real_dx.value)
        _x_start = N.zeros(model._n_real_x.value)
        _u_start = N.zeros(model._n_real_u.value)
        _w_start = N.zeros(model._n_real_w.value)
    
        # Bounds
        _p_opt_lb = N.zeros(self._n_p_opt) 
        _p_free_lb = -1.0e20*N.ones(self._n_p_free) # Not supported
        _dx_lb = -1.0e20*N.ones(model._n_real_dx.value)
        _x_lb = -1.0e20*N.ones(model._n_real_x.value)
        _u_lb = -1.0e20*N.ones(model._n_real_u.value)
        _w_lb = -1.0e20*N.ones(model._n_real_w.value)

        _p_opt_ub = N.zeros(self._n_p_opt) 
        _p_free_ub = 1.0e20*N.ones(self._n_p_free)
        _dx_ub = 1.0e20*N.ones(model._n_real_dx.value)
        _x_ub = 1.0e20*N.ones(model._n_real_x.value)
        _u_ub = 1.0e20*N.ones(model._n_real_u.value)
        _w_ub = 1.0e20*N.ones(model._n_real_w.value)


        # Bounds
        _p_opt_lb = -1.0e20*N.ones(self._n_p_opt)
        _dx_lb = -1.0e20*N.ones(model._n_real_dx.value)
        _x_lb = -1.0e20*N.ones(model._n_real_x.value)
        _u_lb = -1.0e20*N.ones(model._n_real_u.value)
        _w_lb = -1.0e20*N.ones(model._n_real_w.value)
        
        _p_opt_ub = 1.0e20*N.ones(self._n_p_opt)
        _dx_ub = 1.0e20*N.ones(model._n_real_dx.value)
        _x_ub = 1.0e20*N.ones(model._n_real_x.value)
        _u_ub = -1.0e20*N.ones(model._n_real_u.value)
        _w_ub = 1.0e20*N.ones(model._n_real_w.value)

        if stat==0:
            self._model._set_start_values(_p_opt_start, _dx_start, _x_start, _u_start, _w_start)
        else:
            self._model._set_initial_values(_p_opt_start, _dx_start, _x_start, _u_start, _w_start)
        self._model._set_lb_values(_p_opt_lb, _dx_lb, _x_lb, _u_lb, _w_lb)
        self._model._set_ub_values(_p_opt_ub, _dx_ub, _x_ub, _u_ub, _w_ub)
                    
        _linearity_information_provided = 0; # Not supported
        _p_opt_lin = N.ones(self._n_p_opt,dtype=int)
        _p_free_lin = N.ones(self._n_p_free,dtype=int)
        _dx_lin = N.ones(model._n_real_dx.value,dtype=int)
        _x_lin = N.ones(model._n_real_x.value,dtype=int)
        _w_lin = N.ones(model._n_real_w.value,dtype=int)
        
#         self._set_lin_values(_p_opt_lin, _dx_lin, _x_lin,_w_lin)
        
        self._set_typedef_init_opt_new()
#        try:       
        assert model.jmimodel._dll.jmi_init_opt_new(byref(self._jmi_init_opt), model.jmimodel._jmi,
                                                    self._n_p_free,self._p_free_indices,
                                                    _p_opt_start, _p_free_start, _dx_start, _x_start,
                                                    _w_start,
                                                    _p_opt_lb, _p_free_lb, _dx_lb, _x_lb,
                                                    _w_lb,
                                                    _p_opt_ub, _p_free_ub, _dx_ub, _x_ub,
                                                    _w_ub,
                                                    _linearity_information_provided,                
                                                    _p_opt_lin, _p_free_lin, _dx_lin, _x_lin, _w_lin,
                                                    jmi.JMI_DER_CPPAD,stat) is 0, \
                                                    " jmi_opt_lp_new returned non-zero."
        #        except AttributeError,e:
#             raise jmi.JMIException("Can not create NLPInitialization object.")
        assert self._jmi_init_opt.value is not None, \
            "jmi_init_opt struct has not returned correctly."
            
        self._set_nlpInit_typedefs()
        
    def _set_typedef_init_opt_new(self):
        try:
            self._jmi_model._dll.jmi_init_opt_new.argtypes = [ct.c_void_p,                          # jmi_init_opt_new
                                                              ct.c_void_p,                          # jmi 
                                                              ct.c_int,                             # n_p_free
                                                              Nct.ndpointer(dtype=ct.c_int,         # p_free_indices
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # p_opt_init
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # p_free_init
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # dx_init
                                                                            ndim=1,
                                                                            shape=self._model._n_real_dx.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # x_init
                                                                            ndim=1,
                                                                            shape=self._model._n_real_x.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # w_init
                                                                            ndim=1,
                                                                            shape=self._model._n_real_w.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # p_opt_lb
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # p_free_lb
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # dx_lb
                                                                            ndim=1,
                                                                            shape=self._model._n_real_dx.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # x_lb
                                                                            ndim=1,
                                                                            shape=self._model._n_real_x.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # w_lb
                                                                            ndim=1,
                                                                            shape=self._model._n_real_w.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # p_opt_ub
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # p_free_ub
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # dx_ub
                                                                            ndim=1,
                                                                            shape=self._model._n_real_dx.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # x_ub
                                                                            ndim=1,
                                                                            shape=self._model._n_real_x.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=c_jmi_real_t,     # w_ub
                                                                            ndim=1,
                                                                            shape=self._model._n_real_w.value,
                                                                            flags='C'),
                                                              ct.c_int,                             # linearity_information_provided
                                                              Nct.ndpointer(dtype=ct.c_int,         # p_opt_lin
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=ct.c_int,         # p_free_lin
                                                                            ndim=1,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=ct.c_int,         # dx_lin
                                                                            ndim=1,
                                                                            shape=self._model._n_real_dx.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=ct.c_int,         # x_lin
                                                                            ndim=1,
                                                                            shape=self._model._n_real_x.value,
                                                                            flags='C'),
                                                              Nct.ndpointer(dtype=ct.c_int,         # w_lin
                                                                            ndim=1,
                                                                            shape=self._model._n_real_w.value,
                                                                            flags='C'),
                                                              ct.c_int,                             # der_eval_alg
                                                              ct.c_int]                             # stat            
        except AttributeError, e:
            pass        
            
    def _set_nlpInit_typedefs(self):
        try:
            self._jmi_model._dll.jmi_init_opt_delete.argtypes = [ct.c_void_p]           
            self._jmi_model._dll.jmi_init_opt_get_dimensions.argtypes = [ct.c_void_p,
                                                                         ct.POINTER(ct.c_int),
                                                                         ct.POINTER(ct.c_int),
                                                                         ct.POINTER(ct.c_int)]    
            self._jmi_model._dll.jmi_init_opt_get_x.argtypes =[ct.c_void_p]
            
            n_real_x = ct.c_int()
            n_h = ct.c_int()
            dh_n_nz = ct.c_int()
            assert self._jmi_model._dll.jmi_init_opt_get_dimensions(self._jmi_init_opt, byref(n_real_x),
                                           byref(n_h), byref(dh_n_nz)) \
            is 0, \
               "getting NLP problem dimensions failed"        

            self._jmi_model._dll.jmi_init_opt_get_initial.argtypes = [ct.c_void_p,
                                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                    ndim=1,
                                                                                    shape=n_real_x.value,
                                                                                    flags='C')]            
            self._jmi_model._dll.jmi_init_opt_set_initial.argtypes =  [ct.c_void_p,
                                                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                     ndim=1,
                                                                                     shape=n_real_x.value,
                                                                                     flags='C')]    
            self._jmi_model._dll.jmi_init_opt_get_bounds.argtypes = [ct.c_void_p,
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                   ndim=1,
                                                                                   shape=n_real_x.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                   ndim=1,
                                                                                   shape=n_real_x.value,
                                                                                   flags='C')]
            self._jmi_model._dll.jmi_init_opt_set_bounds.argtypes = [ct.c_void_p,
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                   ndim=1,
                                                                                   shape=n_real_x.value,
                                                                                   flags='C'),
                                                                     Nct.ndpointer(dtype=c_jmi_real_t,
                                                                                   ndim=1,
                                                                                   shape=n_real_x.value,
                                                                                   flags='C')]
            self._jmi_model._dll.jmi_init_opt_f.argtypes = [ct.c_void_p,
                                                            Nct.ndpointer(dtype=c_jmi_real_t,
                                                                          ndim=1,
                                                                          shape=1,
                                                                          flags='C')]
            self._jmi_model._dll.jmi_init_opt_df.argtypes = [ct.c_void_p,
                                                             Nct.ndpointer(dtype=c_jmi_real_t,
                                                                           ndim=1,
                                                                           shape=n_real_x.value,
                                                                           flags='C')]
            self._jmi_model._dll.jmi_init_opt_h.argtypes = [ct.c_void_p,
                                                            Nct.ndpointer(dtype=c_jmi_real_t,
                                                                          ndim=1,
                                                                          shape=n_h.value,
                                                                          flags='C')]
            self._jmi_model._dll.jmi_init_opt_dh.argtypes = [ct.c_void_p,
                                                             Nct.ndpointer(dtype=c_jmi_real_t,
                                                                           ndim=1,
                                                                           shape=dh_n_nz.value,
                                                                           flags='C')]
            self._jmi_model._dll.jmi_init_opt_dh_nz_indices.argtypes = [ct.c_void_p,
                                                                        Nct.ndpointer(dtype=ct.c_int,
                                                                                      ndim=1,
                                                                                      shape=dh_n_nz.value,
                                                                                      flags='C'),
                                                                        Nct.ndpointer(dtype=ct.c_int,
                                                                                      ndim=1,
                                                                                      shape=dh_n_nz.value,
                                                                                      flags='C')]
            #dll.jmi_opt_sim_write_file_matlab.argtypes = [ct.c_void_p,
            #                                              ct.c_char_p]
            #dll.jmi_opt_sim_get_result.argtypes = [ct.c_void_p,
            #                                       Nct.ndpointer(dtype=c_jmi_real_t,
            #                                                     ndim=1,
            #                                                     flags='C'),
            #                                       Nct.ndpointer(dtype=c_jmi_real_t,
            #                                                     ndim=1,
            #                                                     flags='C'),
            #                                       Nct.ndpointer(dtype=c_jmi_real_t,
            #                                                     ndim=1,
            #                                                     flags='C'),
            #                                       Nct.ndpointer(dtype=c_jmi_real_t,
            #                                                     ndim=1,
            #                                                     flags='C'),
            #                                       Nct.ndpointer(dtype=c_jmi_real_t,
            #                                                     ndim=1,
            #                                                     flags='C'),
            #                                       Nct.ndpointer(dtype=c_jmi_real_t,
            #                                                     ndim=1,
            #                                                     flags='C')]
            # This is not correct, the n_real_x referes to the wrong x vector
            # In this case, n_real_x refers to the size of the optimization vector
            # in the initialization problem not to the number of states.
            # _returns_ndarray(dll.jmi_init_opt_get_x, c_jmi_real_t, n_real_x.value, order='C')
        except AttributeError, e:
            pass                 
        
    def init_opt_get_dimensions(self):
        """ 
        Get the number of variables and the number of constraints in the 
        problem.
        
        Returns:
            Tuple with the number of variables in the NLP problem, equality constraints,
            and non-zeros in the Jacobian of the equality constraints respectively. 
            
        """
        n_real_x = ct.c_int()
        n_h = ct.c_int()
        dh_n_nz = ct.c_int()
        if self._jmi_model._dll.jmi_init_opt_get_dimensions(self._jmi_init_opt, byref(n_real_x), 
                                                        byref(n_h), byref(dh_n_nz)) is not 0:
            raise jmi.JMIException("Getting the number of variables and constraints failed.")
        return n_real_x.value, n_h.value, dh_n_nz.value 
        
    def init_opt_get_x(self):
        """ Return the x vector of the NLP. """
        return self._jmi_model._dll.jmi_init_opt_get_x(self._jmi_init_opt)

    def init_opt_get_initial(self, x_init):
        """ 
        Get the initial point of the NLP.
        
        Parameters:
            x_init -- The initial guess vector. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_get_initial(self._jmi_init_opt, x_init) is not 0:
            raise jmi.JMIException("Getting the initial point failed.")

    def init_opt_set_initial(self, x_init):
        """ Set the initial point of the NLP.

        Parameters:
            x_init --- The initial guess vector.
        """
        if self._jmi_model._dll.jmi_init_opt_set_initial(self._jmi_init_opt, x_init) is not 0:
            raise jmi.JMIException("Setting the initial point failed.")
 
    def init_opt_get_bounds(self, x_lb, x_ub):
        """ 
        Get the upper and lower bounds of the optimization variables.
        
        Parameters:
            x_lb -- The lower bounds vector. (Return)
            x_ub -- The upper bounds vector. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_get_bounds(self._jmi_init_opt, x_lb, x_ub) is not 0:
            raise jmi.JMIException("Getting upper and lower bounds of the optimization variables failed.")

    def init_opt_set_bounds(self, x_lb, x_ub):
        """ 
        Set the upper and lower bounds of the optimization variables.
        
        Parameters:
            x_lb -- The lower bounds vector. (Return)
            x_ub -- The upper bounds vector. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_set_bounds(self._jmi_init_opt, x_lb, x_ub) is not 0:
            raise jmi.JMIException("Getting upper and lower bounds of the optimization variables failed.")

    def init_opt_f(self, f):
        """ 
        Get the cost function value at a given point in search space.
        
        Parameters:
            f -- Value of the cost function. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_f(self._jmi_init_opt, f) is not 0:
            raise jmi.JMIException("Getting the cost function failed.")
        
    def init_opt_df(self, df):
        """ 
        Get the gradient of the cost function value at a given point in search 
        space.
        
        Parameters:
            df -- Value of the gradient of the cost function. (Return)
            
        """
        if self._jmi_model._dll.jmi_init_opt_df(self._jmi_init_opt, df) is not 0:
            raise jmi.JMIException("Getting the gradient of the cost function value failed.")
               
    def init_opt_h(self, res):
        """ 
        Get the residual of the equality constraints h.
        
        Parameters:
            res -- The residual of the equality constraints. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_h(self._jmi_init_opt, res) is not 0:
            raise jmi.JMIException("Getting the residual of the equality constraints failed.")
        
    def init_opt_dh(self, jac):
        """ 
        Get the Jacobian of the residual of the equality constraints.
        
        Parameters:
            jac -- The Jacobian of the residual of the equality constraints. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_dh(self._jmi_init_opt, jac) is not 0:
            raise jmi.JMIException("Getting the Jacobian of the residual of the equality constraints.")
        
    def init_opt_dh_nz_indices(self, irow, icol):
        """ 
        Get the indices of the non-zeros in the equality constraint Jacobian.
        
        Parameters:
            irow -- 
                Row indices of the non-zero entries in the Jacobian of the 
                residual of the equality constraints. (Return)
            icol -- 
                Column indices of the non-zero entries in the Jacobian of the 
                residual of the equality constraints. (Return)
        
        """
        if self._jmi_model._dll.jmi_init_opt_dh_nz_indices(self._jmi_init_opt, irow, icol) is not 0:
            raise jmi.JMIException("Getting the indices of the non-zeros in the equality constraint Jacobian failed.")

#     def init_opt_write_file_matlab(self, file_name):
#         """ 
#         Write the optimization result to file in Matlab format.
        
#         Parameters:
#             file_name -- Name of file to write to.
        
#         """
#         if self._jmi_model._dll.jmi_init_opt_write_file_matlab(self._jmi_init_opt, file_name) is not 0:
#             raise JMIException("Writing the optimization result to file in Matlab format failed.")
        
#     def init_opt_get_result_variable_vector_length(self):
#         """ Return the length of the result variable vectors. """
#         n = ct.c_int()
#         if self._jmi_model._dll.jmi_init_opt_get_result_variable_vector_length(self._jmi_init_opt, byref(n)) is not 0:
#             raise JMIException("Getting the length of the result variable vectors failed.")
#         return n
        
#     def init_opt_get_result(self, p_opt, t, dx, x, u, w):
#         """ 
#         Get the results, stored in column major format.
        
#         Parameters:
#             p_opt -- Vector containing optimal parameter values. (Return)
#             t -- The time vector. (Return)
#             dx -- The derivatives. (Return)
#             x -- The states. (Return)
#             u -- The inputs. (Return)
#             w -- The algebraic variables. (Return)
             
#         """
#         if self._jmi_model._dll.jmi_init_opt_get_result(self._jmi_init_opt, p_opt, t, dx, x, u, w) is not 0:
#             raise JMIException("Getting the results failed.")

#     def _set_start_values(self,p_opt_start, p_free_start, dx_start, x_start, w_start):
        
#         """ 
#         Set initial guess values from the Model object
        
#         Parameters:
#             p_free_start -- The free parameters start value vector.
#             dx_start -- The derivatives start value vector.
#             x_start -- The states start value vector.
#             w_start -- The algebraic variable start value vector.
        
#         """
        
#         xmldoc = self._model._get_XMLDoc()

#         # p_free: free variables, not supported
# #        values = xmldoc.get_p_free_initial_guess_values()
#         values = xmldoc.get_p_opt_initial_guess_values(include_alias=False)

#         refs = values.keys()
#         refs.sort(key=int)

#         n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
#         if n_p_opt > 0:
#             p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
#             self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
#             p_opt_indices = p_opt_indices.tolist()
            
#             for ref in refs:
#                 (z_i, ptype) = _translate_value_ref(ref)
#                 i_pi = z_i - self._model._offs_real_pi.value
#                 i_pi_opt = p_opt_indices.index(i_pi)
#                 p_opt_start[i_pi_opt] = values.get(ref)
        
#         # dx: derivative
#         values = xmldoc.get_dx_start_attributes(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_dx = z_i - self._model._offs_real_dx.value
#             #dx_start[i_dx] = values.get(name)
#             dx_start[i_dx] = self._model.get_z()[z_i]
        
#         # x: differentiate
#         values = xmldoc.get_x_start_attributes(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_x = z_i - self._model._offs_real_x.value
#             #x_start[i_x] = values.get(name)
#             x_start[i_x] = self._model.get_z()[z_i]
                    
#         # w: algebraic
#         values = xmldoc.get_w_start_attributes(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             if not (xmldoc.is_alias(name)):
#                 value_ref = xmldoc.get_valueref(name)
#                 (z_i, ptype) = jmi._translate_value_ref(value_ref)
#                 i_w = z_i - self._model._offs_real_w.value
#                 #w_start[i_w] = values.get(name)
#                 w_start[i_w] = self._model.get_z()[z_i]

#     def _set_lb_values(self, p_opt_lb, p_free_lb, dx_lb, x_lb, w_lb):
        
#         """ 
#         Set lower bounds from the XML variables meta data file. 
        
#         Parameters:
#             p_free_lb -- The free parameters lower bounds vector.
#             dx_lb -- The derivatives lower bounds vector.
#             x_lb -- The states lower bounds vector.
#             w_lb -- The algebraic variables lower bounds vector.        
        
#         """
        
#         xmldoc = self._model._get_XMLDoc()

# #         # p_free: free parameters
#         values = xmldoc.get_p_free_lb_values()
        
#         refs = values.keys()
#         refs.sort(key=int)

#         n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
#         if n_p_opt > 0:
#             p_opt_indices = N.zeros(n_p_opt, dtype=int)
      
#             self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
#             p_opt_indices = p_opt_indices.tolist()
          
#             for ref in refs:
#                 (z_i, ptype) = _translate_value_ref(ref)
#                 i_pi = z_i - self._model._offs_real_pi.value
#                 i_pi_opt = p_opt_indices.index(i_pi)
#                 p_opt_lb[i_pi_opt] = values.get(ref)

#         # dx: derivative
#         values = xmldoc.get_dx_lb_values(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_dx = z_i - self._model._offs_real_dx.value
#             dx_lb[i_dx] = values.get(name)
        
#         # x: differentiate
#         values = xmldoc.get_x_lb_values(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_x = z_i - self._model._offs_real_x.value
#             x_lb[i_x] = values.get(name)
                    
#         # w: algebraic
#         values = xmldoc.get_w_lb_values(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_w = z_i - self._model._offs_real_w.value
#             w_lb[i_w] = values.get(name) 

#     def _set_ub_values(self, p_opt_ub, p_free_ub, dx_ub, x_ub, w_ub):
        
#         """ 
#         Set upper bounds from the XML variables meta data file. 
        
#         Parameters:
#             p_free_ub -- The free parameters upper bounds vector.
#             dx_ub -- The derivatives upper bounds vector.
#             x_ub -- The states upper bounds vector.
#             w_ub -- The algebraic variables upper bounds vector.        
        
#         """
        
#         xmldoc = self._model._get_XMLDoc()

# #         # p_free: free parameters
#         values = xmldoc.get_p_opt_ub_values()
        
#         refs = values.keys()
#         refs.sort(key=int)

#         n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
#         if n_p_opt > 0:
#             p_opt_indices = N.zeros(n_p_opt, dtype=int)
      
#             self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
#             p_opt_indices = p_opt_indices.tolist()
          
#             for ref in refs:
#                 (z_i, ptype) = _translate_value_ref(ref)
#                 i_pi = z_i - self._model._offs_real_pi.value
#                 i_pi_opt = p_opt_indices.index(i_pi)
#                 p_opt_ub[i_pi_opt] = values.get(ref)

#         # dx: derivative
#         values = xmldoc.get_dx_ub_values(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_dx = z_i - self._model._offs_real_dx.value
#             dx_ub[i_dx] = values.get(name)
        
#         # x: differentiate
#         values = xmldoc.get_x_ub_values(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_x = z_i - self._model._offs_real_x.value
#             x_ub[i_x] = values.get(name)
            
        
#         # w: algebraic
#         values = xmldoc.get_w_ub_values(include_alias=False)
        
#         #names = values.keys()
#         #names.sort(key=str)
        
#         for name in values.keys():
#             value_ref = xmldoc.get_valueref(name)
#             (z_i, ptype) = jmi._translate_value_ref(value_ref)
#             i_w = z_i - self._model._offs_real_w.value
#             w_ub[i_w] = values.get(name)

