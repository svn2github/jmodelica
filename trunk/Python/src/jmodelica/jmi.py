# -*- coding: utf-8 -*-
"""Module containing the JMI interface Python wrappers.
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

# References:
#     http://www.python.org/doc/2.5.2/lib/module-ctypes.html
#     http://starship.python.net/crew/theller/ctypes/tutorial.html
#     http://www.scipy.org/Cookbook/Ctypes 


import os.path

import ctypes as ct
from ctypes import byref
import numpy as N
import numpy.ctypeslib as Nct
import xmlparser

# ================================================================
#                         CONSTANTS
# ================================================================

"""Use symbolic evaluation of derivatives (if available)."""
JMI_DER_SYMBOLIC = 1
"""Use automatic differentiation (CppAD) to evaluate derivatives."""
JMI_DER_CPPAD = 2

"""Sparse evaluation of derivatives."""
JMI_DER_SPARSE = 1
"""Dense evaluation (column major) of derivatives"""
JMI_DER_DENSE_COL_MAJOR = 2
"""Dense evaluation (row major) of derivatives."""
JMI_DER_DENSE_ROW_MAJOR = 4

"""Flags for evaluation of Jacobians w.r.t. parameters in the p vector
"""
"""Evaluate derivatives w.r.t. independent constants, \f$c_i\f$."""
JMI_DER_CI = 1
"""Evaluate derivatives w.r.t. dependent constants, \f$c_d\f$."""
JMI_DER_CD = 2
"""Evaluate derivatives w.r.t. independent parameters, \f$p_i\f$."""
JMI_DER_PI = 4
"""Evaluate derivatives w.r.t. dependent constants, \f$p_d\f$."""
JMI_DER_PD = 8

"""Flags for evaluation of Jacobians w.r.t. variables in the v vector
"""
"""Evaluate derivatives w.r.t. derivatives, \f$\dot x\f$."""
JMI_DER_DX = 16
"""Evaluate derivatives w.r.t. differentiated variables, \f$x\f$."""
JMI_DER_X = 32
"""Evaluate derivatives w.r.t. inputs, \f$u\f$."""
JMI_DER_U = 64
"""Evaluate derivatives w.r.t. algebraic variables, \f$w\f$."""
JMI_DER_W = 128
"""Evaluate derivatives w.r.t. time, \f$t\f$."""
JMI_DER_T = 256

"""Flags for evaluation of Jacobians w.r.t. variables in the q vector.
"""
"""Evaluate derivatives w.r.t. derivatives at time points,
\f$\dot x_p\f$.
"""
JMI_DER_DX_P = 512
"""Evaluate derivatives w.r.t. differentiated variables at time points,
\f$x_p\f$.
"""
JMI_DER_X_P = 1024
"""Evaluate derivatives w.r.t. inputs at time points, \f$u_p\f$.
"""
JMI_DER_U_P = 2048
"""Evaluate derivatives w.r.t. algebraic variables at time points,
\f$w_p\f$.
"""
JMI_DER_W_P = 4096

"""Evaluate derivatives w.r.t. all variables, \f$z\f$."""
JMI_DER_ALL = JMI_DER_CI | JMI_DER_CD | JMI_DER_PI | JMI_DER_PD | \
              JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W | \
	          JMI_DER_T | JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | \
	          JMI_DER_W_P


"""Evaluate derivatives w.r.t. all variables in \f$p\f$."""
JMI_DER_ALL_P = JMI_DER_CI | JMI_DER_CD | JMI_DER_PI | JMI_DER_PD

"""Evaluate derivatives w.r.t. all variables in \f$v\f$."""
JMI_DER_ALL_V = JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W | \
                JMI_DER_T

"""Evaluate derivatives w.r.t. all variables in \f$q\f$."""
JMI_DER_ALL_Q = JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P


# ================================================================
#                    ERROR HANDLING / EXCEPTIONS
# ================================================================
class JMIException(Exception):
    """A JMI exception."""
    pass


def fail_error_check(message):
    """A ctypes errcheck that always fails.
    """
    def fail(errmsg):
        raise JMIException(errmsg)
    
    return lambda x, y, z: fail(message)

# ================================================================
#                             CTYPES
# ================================================================

"""Defines the JMI jmi_real_t C-type.

This type is usually a double.

"""
c_jmi_real_t = ct.c_double


# ================================================================
#                         LOW LEVEL INTERFACE
# ================================================================

def _from_address(address, nbytes, dtype=float):
    """Converts a C-array to a numpy.array.
    
    Borrowed from:
    http://mail.scipy.org/pipermail/numpy-discussion/2009-March/041323.html
    
    """
    class Dummy(object): pass

    d = Dummy()
    bytetype = N.dtype(N.uint8)

    d.__array_interface__ = {
         'data' : (address, False),
         'typestr' : bytetype.str,
         'descr' : bytetype.descr,
         'shape' : (nbytes,),
         'strides' : None,
         'version' : 3
    }   

    return N.asarray(d).view(dtype)


class _PointerToNDArrayConverter:
    """A callable class used by the function _returns_ndarray(...)
    to convert result from a DLL function pointer to an array.
    
    """
    def __init__(self, shape, dtype, ndim=1, order=None):
        """Set meta data about the array the returned pointer is
        pointing to.
        
        @param shape:
            A tuple containing the shape of the array
        @param dtype:
            The data type that the function result points to.
        @param ndim:
            The optional number of dimensions that the result 
            returns.
        @param order (optional):
            Optional. The same order parameter as can be used in
            numpy.array(...).
        
        """
        assert ndim >= 1
        
        self._shape = shape
        self._dtype = dtype
        self._order = order
        
        if ndim is 1:
            self._num_elmnts = shape
            try:
                # If shape is specified as a tuple
                self._num_elmnts = shape[0]
            except TypeError:
                pass
        else:
            assert len(shape) is ndim
            for number in shape:
                assert number >= 1
            self._num_elmnts = reduce(lambda x,y: x*y, self.shape)
        
    def __call__(self, ret, func, params):
        
        if ret is None:
            raise JMIException("The function returned NULL.")
            
        #ctypes_arr_type = C.POINTER(self._num_elmnts * self._dtype)
        #ctypes_arr = ctypes_arr_type(ret)
        #narray = N.asarray(ctypes_arr)
        
        pointer = ct.cast(ret, ct.c_void_p)
        address = pointer.value
        nbytes = ct.sizeof(self._dtype) * self._num_elmnts
        
        numpy_arr = _from_address(address, nbytes, self._dtype)
        
        return numpy_arr


def _returns_ndarray(dll_func, dtype, shape, ndim=1, order=None):
    """Helper function to set automatic conversion of DLL function
    result to a NumPy ndarray.
    
    """       
    
    # Defining conversion function (actually a callable class)
    conv_function = _PointerToNDArrayConverter(shape=shape,
                                               dtype=dtype,
                                               ndim=ndim,
                                               order=order)
    
    dll_func.restype = ct.POINTER(dtype)
    dll_func.errcheck = conv_function

## This is an api comment.
# @param libname Name of library.
# @param path Path to library.
def load_DLL(libname, path):
    """Loads a model from a DLL file and returns it.
    
    The filepath can be be both with or without file suffixes (as long
    as standard file suffixes are used, that is).
    
    Example inputs that should work:
      >> lib = loadDLL('model')
      >> lib = loadDLL('model.dll')
      >> lib = loadDLL('model.so')
    . All of the above should work on the JModelica supported platforms.
    However, the first one is recommended as it is the most platform
    independent syntax.
    
    @param libname Name of the librarym without prefix.
    @param path    The relative or absolute path to the library.
    
    @see http://docs.python.org/library/ct.html
    
    """
    try:
        dll = Nct.load_library(libname, path)
    except OSError, e:
        raise JMIException("Could not load library '%s' in path '%s'."
                            % (libname, path))
    
    # Initializing the jmi C struct
    jmi = ct.c_voidp()
    assert dll.jmi_new(byref(jmi)) == 0, \
           "jmi_new returned non-zero"
    assert jmi.value is not None, \
           "jmi struct not returned correctly"
    
    # Initialize the global variables used throughout the tests.
    n_ci = ct.c_int()
    n_cd = ct.c_int()
    n_pi = ct.c_int()
    n_pd = ct.c_int()
    n_dx = ct.c_int()
    n_x  = ct.c_int()
    n_u  = ct.c_int()
    n_w  = ct.c_int()
    n_tp = ct.c_int()
    n_z  = ct.c_int()
    assert dll.jmi_get_sizes(jmi,
                             byref(n_ci),
                             byref(n_cd),
                             byref(n_pi),
                             byref(n_pd),
                             byref(n_dx),
                             byref(n_x),
                             byref(n_u),
                             byref(n_w),
                             byref(n_tp),
                             byref(n_z)) \
           is 0, \
           "getting sizes failed"
           
    # Setting return type to numpy.array for some functions
    int_res_funcs = [(dll.jmi_get_ci, n_ci.value),
                     (dll.jmi_get_cd, n_cd.value),
                     (dll.jmi_get_pi, n_pi.value),
                     (dll.jmi_get_pd, n_pd.value),
                     (dll.jmi_get_dx, n_dx.value),
                     (dll.jmi_get_x, n_x.value),
                     (dll.jmi_get_u, n_u.value),
                     (dll.jmi_get_w, n_w.value),
                     (dll.jmi_get_t, 1),
                     (dll.jmi_get_dx_p, n_dx.value),
                     (dll.jmi_get_x_p, n_x.value),
                     (dll.jmi_get_u_p, n_u.value),
                     (dll.jmi_get_w_p, n_w.value),
                     (dll.jmi_get_z, n_z.value)]
    
    for (func, length) in int_res_funcs:
        _returns_ndarray(func, c_jmi_real_t, length, order='C')
        
    n_eq_F = ct.c_int()
    assert dll.jmi_dae_get_sizes(jmi,
                                 byref(n_eq_F)) \
           is 0, \
           "getting DAE sizes failed"
    
    dF_n_nz = ct.c_int()
    if dll.jmi_dae_dF_n_nz(jmi, JMI_DER_SYMBOLIC, byref(dF_n_nz)) \
        is not 0:
        dF_n_nz = None
    
    dJ_n_nz = ct.c_int() 
    if dll.jmi_opt_dJ_n_nz(jmi, JMI_DER_SYMBOLIC, byref(dJ_n_nz)) \
         is not 0:
        dJ_n_nz = None
    
    dJ_n_dense = ct.c_int(n_z.value);
    
    dF_n_dense = ct.c_int(n_z.value * n_eq_F.value)
    
    J = c_jmi_real_t();
    
    jmi_opt_sim       = ct.c_void_p()
    jmi_opt_sim_ipopt = ct.c_void_p()
    
    # The return types for these functions are set in jmi.py's
    # function load_DLL(...)
    ci     = dll.jmi_get_ci(jmi);
    cd     = dll.jmi_get_cd(jmi);
    pi     = dll.jmi_get_pi(jmi);
    pd     = dll.jmi_get_pd(jmi);
    dx     = dll.jmi_get_dx(jmi);
    x      = dll.jmi_get_x(jmi);
    u      = dll.jmi_get_u(jmi);
    w      = dll.jmi_get_w(jmi);
    t      = dll.jmi_get_t(jmi);
    z      = dll.jmi_get_z(jmi)
    
    # Setting parameter types
    # creation, initialization and destruction
    dll.jmi_ad_init.argtypes = [ct.c_void_p]
    dll.jmi_delete.argtypes = [ct.c_void_p]
    
    # setters and getters
    dll.jmi_get_sizes.argtypes = [ct.c_void_p,
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int),
                                  ct.POINTER(ct.c_int)]   
    dll.jmi_get_offsets.argtypes = [ct.c_void_p,
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int),
                                    ct.POINTER(ct.c_int)]
    dll.jmi_get_n_tp.argtypes = [ct.c_void_p,
                                 ct.POINTER(ct.c_int)]    
    dll.jmi_set_tp.argtypes = [ct.c_void_p,
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             shape=n_tp.value,
                                             flags='C')]    
    dll.jmi_get_tp.argtypes = [ct.c_void_p,
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]
    dll.jmi_get_z.argtypes    = [ct.c_void_p]
    dll.jmi_get_ci.argtypes   = [ct.c_void_p]
    dll.jmi_get_cd.argtypes   = [ct.c_void_p]
    dll.jmi_get_pi.argtypes   = [ct.c_void_p]
    dll.jmi_get_pd.argtypes   = [ct.c_void_p]
    dll.jmi_get_dx.argtypes   = [ct.c_void_p]
    dll.jmi_get_dx_p.argtypes = [ct.c_void_p, ct.c_int]
    dll.jmi_get_t.argtypes    = [ct.c_void_p]
    dll.jmi_get_u.argtypes    = [ct.c_void_p]
    dll.jmi_get_u_p.argtypes  = [ct.c_void_p, ct.c_int]
    dll.jmi_get_w.argtypes    = [ct.c_void_p]
    dll.jmi_get_w_p.argtypes  = [ct.c_void_p, ct.c_int]
    dll.jmi_get_x.argtypes    = [ct.c_void_p]
    dll.jmi_get_x_p.argtypes  = [ct.c_void_p, ct.c_int]
 
    # ODE interface
    dll.jmi_ode_f.argtypes  = [ct.c_void_p]
    dll.jmi_ode_df.argtypes = [ct.c_void_p,
                               ct.c_int,
                               ct.c_int,
                               ct.c_int,
                               Nct.ndpointer(dtype=ct.c_int,
                                             ndim=1,
                                             shape=n_z.value,
                                             flags='C'),
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]    
    dll.jmi_ode_df_n_nz.argtypes = [ct.c_void_p,
                                    ct.c_int,
                                    ct.POINTER(ct.c_int)]
    dll.jmi_ode_df_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        shape=n_z.value,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C')]
    dll.jmi_ode_df_dim.argtypes = [ct.c_void_p,
                                   ct.c_int,
                                   ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]    

    # DAE interface
    dll.jmi_dae_get_sizes.argtypes = [ct.c_void_p,
                                      ct.POINTER(ct.c_int)]      
    dll.jmi_dae_F.argtypes = [ct.c_void_p,
                              Nct.ndpointer(dtype=c_jmi_real_t,
                                            ndim=1,
                                            shape=n_eq_F.value,
                                            flags='C')]
    dll.jmi_dae_dF.argtypes = [ct.c_void_p,
                               ct.c_int,
                               ct.c_int,
                               ct.c_int,
                               Nct.ndpointer(dtype=ct.c_int,
                                             ndim=1,
                                             shape=n_z.value,
                                             flags='C'),
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]   
    dll.jmi_dae_dF_n_nz.argtypes = [ct.c_void_p,
                                    ct.c_int,
                                    ct.POINTER(ct.c_int)]
    
    if dF_n_nz is not None:
        dll.jmi_dae_dF_nz_indices.argtypes = [ct.c_void_p,
                                              ct.c_int,
                                              ct.c_int,
                                              Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
                                                shape=n_z.value,
                                                flags='C'),
                                              Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
                                                shape=dF_n_nz.value,
                                                flags='C'),
                                              Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
                                                shape=dF_n_nz.value,
                                                flags='C')]
    else:
        dll.jmi_dae_dF_nz_indices.errcheck = \
                        fail_error_check("Functionality not supported.")                        
    dll.jmi_dae_dF_dim.argtypes = [ct.c_void_p, ct.c_int, ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]
    
    # DAE initialization interface
    dll.jmi_init_get_sizes.argtypes = [ct.c_void_p,
                                       ct.POINTER(ct.c_int),
                                       ct.POINTER(ct.c_int),
                                       ct.POINTER(ct.c_int)]                                          
    dll.jmi_init_F0.argtypes = [ct.c_void_p,
                                Nct.ndpointer(dtype=c_jmi_real_t,
                                              ndim=1,
                                              flags='C')]
    dll.jmi_init_dF0.argtypes = [ct.c_void_p,
                                 ct.c_int,
                                 ct.c_int,
                                 ct.c_int,
                                 Nct.ndpointer(dtype=ct.c_int,
                                               ndim=1,
                                               shape=n_z.value,
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]
    dll.jmi_init_dF0_n_nz = [ct.c_void_p,
                             ct.c_int,
                             ct.POINTER(ct.c_int)]
    dll.jmi_init_dF0_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
                                                shape=n_z.value,
                                                flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C')]
    dll.jmi_init_dF0_dim.argtypes = [ct.c_void_p,
                                     ct.c_int,
                                     ct.c_int,
                                     ct.c_int,
                                     Nct.ndpointer(dtype=ct.c_int,
                                                   ndim=1,
                                                   shape=n_z.value,
                                                   flags='C'),
                                     ct.POINTER(ct.c_int),
                                     ct.POINTER(ct.c_int)]
    dll.jmi_init_F1.argtypes = [ct.c_void_p,
                                Nct.ndpointer(dtype=c_jmi_real_t,
                                              ndim=1,
                                              flags='C')]
    dll.jmi_init_dF1.argtypes = [ct.c_void_p,
                                 ct.c_int,
                                 ct.c_int,
                                 ct.c_int,
                                 Nct.ndpointer(dtype=ct.c_int,
                                               ndim=1,
                                               shape=n_z.value,
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]
    dll.jmi_init_dF1_n_nz = [ct.c_void_p,
                             ct.c_int,
                             ct.POINTER(ct.c_int)]
    dll.jmi_init_dF1_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        shape=n_z.value,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C')]
    dll.jmi_init_dF1_dim.argtypes = [ct.c_void_p,
                                     ct.c_int,
                                     ct.c_int,
                                     ct.c_int,
                                     Nct.ndpointer(dtype=ct.c_int,
                                                   ndim=1,
                                                   shape=n_z.value,
                                                   flags='C'),
                                     ct.POINTER(ct.c_int),
                                     ct.POINTER(ct.c_int)]
    dll.jmi_init_Fp.argtypes = [ct.c_void_p,
                                Nct.ndpointer(dtype=c_jmi_real_t,
                                              ndim=1,
                                              flags='C')]
    dll.jmi_init_dFp.argtypes = [ct.c_void_p,
                                 ct.c_int,
                                 ct.c_int,
                                 ct.c_int,
                                 Nct.ndpointer(dtype=ct.c_int,
                                               ndim=1,
                                               shape=n_z.value,
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]
    dll.jmi_init_dFp_n_nz = [ct.c_void_p,
                             ct.c_int,
                             ct.POINTER(ct.c_int)]
    dll.jmi_init_dFp_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        shape=n_z.value,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C')]
    dll.jmi_init_dFp_dim.argtypes = [ct.c_void_p, ct.c_int, ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]
    
    # Optimization interface
    dll.jmi_opt_set_optimization_interval.argtypes = [ct.c_void_p,
                                                      c_jmi_real_t,
                                                      ct.c_int,
                                                      c_jmi_real_t,
                                                      ct.c_int]    
    dll.jmi_opt_get_optimization_interval.argtypes = [ct.c_void_p,
                                                      ct.POINTER(c_jmi_real_t),
                                                      ct.POINTER(ct.c_int),
                                                      ct.POINTER(c_jmi_real_t),
                                                      ct.POINTER(ct.c_int)]
    dll.jmi_opt_set_p_opt_indices.argtypes = [ct.c_void_p,
                                              ct.c_int,
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C')]    
    dll.jmi_opt_get_n_p_opt.argtypes = [ct.c_void_p,
                                        ct.POINTER(ct.c_int)]    
    dll.jmi_opt_get_p_opt_indices.argtypes = [ct.c_void_p,
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C')]                                                 
    dll.jmi_opt_get_sizes.argtypes = [ct.c_void_p,
                                      ct.POINTER(ct.c_int),
                                      ct.POINTER(ct.c_int),
                                      ct.POINTER(ct.c_int),
                                      ct.POINTER(ct.c_int)]    
    dll.jmi_opt_J.argtypes = [ct.c_void_p,
                              Nct.ndpointer(dtype=c_jmi_real_t,
                                            ndim=1,
                                            flags='C')]   
    dll.jmi_opt_dJ.argtypes = [ct.c_void_p,
                               ct.c_int,
                               ct.c_int,
                               ct.c_int,
                               Nct.ndpointer(dtype=ct.c_int,
                                             ndim=1,
                                             shape=n_z.value,
                                             flags='C'),
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]   
    dll.jmi_opt_dJ_n_nz.argtypes = [ct.c_void_p,
                                    ct.c_int,
                                    ct.POINTER(ct.c_int)]    
    dll.jmi_opt_dJ_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        shape=n_z.value,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C'),
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
                                                        flags='C')]    
    dll.jmi_opt_dJ_dim.argtypes = [ct.c_void_p,
                                   ct.c_int,
                                   ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]    
    dll.jmi_opt_Ceq.argtypes = [ct.c_void_p,
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]    
    dll.jmi_opt_dCeq.argtypes = [ct.c_void_p,
                                 ct.c_int,
                                 ct.c_int,
                                 ct.c_int,
                                 Nct.ndpointer(dtype=ct.c_int,
                                               ndim=1,
                                               shape=n_z.value,
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]   
    dll.jmi_opt_dCeq_n_nz.argtypes = [ct.c_void_p,
                                      ct.c_int,
                                      ct.POINTER(ct.c_int)]   
    dll.jmi_opt_dCeq_nz_indices.argtypes = [ct.c_void_p,
                                            ct.c_int,
                                            ct.c_int,
                                            Nct.ndpointer(dtype=ct.c_int,
                                                          ndim=1,
                                                          shape=n_z.value,
                                                          flags='C'),
                                            Nct.ndpointer(dtype=ct.c_int,
                                                          ndim=1,
                                                          flags='C'),
                                            Nct.ndpointer(dtype=ct.c_int,
                                                          ndim=1,
                                                          flags='C')]
    dll.jmi_opt_dCeq_dim.argtypes = [ct.c_void_p,
                                     ct.c_int,
                                     ct.c_int,
                                     ct.c_int,
                                     Nct.ndpointer(dtype=ct.c_int,
                                                   ndim=1,
                                                   shape=n_z.value,
                                                   flags='C'),
                                     ct.POINTER(ct.c_int),
                                     ct.POINTER(ct.c_int)]    
    dll.jmi_opt_Cineq.argtypes = [ct.c_void_p,
                                  Nct.ndpointer(dtype=c_jmi_real_t,
                                                ndim=1,
                                                flags='C')]    
    dll.jmi_opt_dCineq.argtypes = [ct.c_void_p,
                                   ct.c_int,
                                   ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   Nct.ndpointer(dtype=c_jmi_real_t,
                                                 ndim=1,
                                                 flags='C')]   
    dll.jmi_opt_dCineq_n_nz.argtypes = [ct.c_void_p,
                                        ct.c_int,
                                        ct.POINTER(ct.c_int)]    
    dll.jmi_opt_dCineq_nz_indices.argtypes = [ct.c_void_p,
                                              ct.c_int,
                                              ct.c_int,
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            shape=n_z.value,
                                                            flags='C'),
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C'),
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C')]    
    dll.jmi_opt_dCineq_dim.argtypes = [ct.c_void_p,
                                       ct.c_int,
                                       ct.c_int,
                                       ct.c_int,
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     shape=n_z.value,
                                                     flags='C'),
                                       ct.POINTER(ct.c_int),
                                       ct.POINTER(ct.c_int)]    
    dll.jmi_opt_Heq.argtypes = [ct.c_void_p,
                                Nct.ndpointer(dtype=c_jmi_real_t,
                                              ndim=1,
                                              flags='C')]    
    dll.jmi_opt_dHeq.argtypes = [ct.c_void_p,
                                 ct.c_int,
                                 ct.c_int,
                                 ct.c_int,
                                 Nct.ndpointer(dtype=ct.c_int,
                                               ndim=1,
                                               shape=n_z.value,
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]    
    dll.jmi_opt_dHeq_n_nz.argtypes = [ct.c_void_p,
                                      ct.c_int,
                                      ct.POINTER(ct.c_int)]    
    dll.jmi_opt_dHeq_nz_indices.argtypes = [ct.c_void_p,
                                            ct.c_int,
                                            ct.c_int,
                                            Nct.ndpointer(dtype=ct.c_int,
                                                          ndim=1,
                                                          shape=n_z.value,
                                                          flags='C'),
                                            Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C'),
                                            Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C')]    
    dll.jmi_opt_dHeq_dim.argtypes = [ct.c_void_p,
                                     ct.c_int,
                                     ct.c_int,
                                     ct.c_int,
                                     Nct.ndpointer(dtype=ct.c_int,
                                                   ndim=1,
                                                   shape=n_z.value,
                                                   flags='C'),
                                     ct.POINTER(ct.c_int),
                                     ct.POINTER(ct.c_int)]    
    dll.jmi_opt_Hineq.argtypes = [ct.c_void_p,
                                  Nct.ndpointer(dtype=c_jmi_real_t,
                                                ndim=1,
                                                flags='C')]    
    dll.jmi_opt_dHineq.argtypes = [ct.c_void_p,
                                   ct.c_int,
                                   ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   Nct.ndpointer(dtype=c_jmi_real_t,
                                                 ndim=1,
                                                 flags='C')]   
    dll.jmi_opt_dHineq_n_nz.argtypes = [ct.c_void_p,
                                        ct.c_int,
                                        ct.POINTER(ct.c_int)]   
    dll.jmi_opt_dHineq_nz_indices.argtypes = [ct.c_void_p,
                                              ct.c_int,
                                              ct.c_int,
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            shape=n_z.value,
                                                            flags='C'),
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C'),
                                              Nct.ndpointer(dtype=ct.c_int,
                                                            ndim=1,
                                                            flags='C')]    
    dll.jmi_opt_dHineq_dim.argtypes = [ct.c_void_p,
                                       ct.c_int,
                                       ct.c_int,
                                       ct.c_int,
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     shape=n_z.value,
                                                     flags='C'),
                                       ct.POINTER(ct.c_int),
                                       ct.POINTER(ct.c_int)]
    
    
    # Simultaneous Optimization based on Lagrange polynomials and Radau points
    try:
        dll.jmi_opt_sim_lp_new.argtypes = [ct.c_void_p,
                                       ct.c_void_p,
                                       ct.c_int,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C'),
                                       ct.c_int,
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
                                                     flags='C'),
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C'),
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C'),
                                       c_jmi_real_t,
                                       c_jmi_real_t,
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
                                       c_jmi_real_t,
                                       c_jmi_real_t,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C'),
                                       ct.c_int,
                                       ct.c_int]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_opt_sim_lp_delete.argtypes = [ct.c_void_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_opt_sim_lp_get_pols.argtypes = [ct.c_int,
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

    # Simultaneous Optimization interface
    try:
        dll.jmi_opt_sim_ipopt_new.argtypes = [ct.c_void_p,
                                              ct.c_void_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_opt_sim_ipopt_solve.argtypes = [ct.c_void_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_opt_sim_ipopt_set_string_option.argtypes = [ct.c_void_p,
                                                            ct.c_char_p,
                                                            ct.c_char_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_opt_sim_ipopt_set_int_option.argtypes = [ct.c_void_p,
                                                         ct.c_char_p,
                                                         ct.c_int]
    except AttributeError, e:
        pass

    try:
        dll.jmi_opt_sim_ipopt_set_double_option.argtypes = [ct.c_void_p,
                                                            ct.c_char_p,
                                                            ct.c_double]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_opt_sim_get_result.argtypes = [ct.c_void_p,
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
   
    assert dll.jmi_delete(jmi) == 0, \
           "jmi_delete failed"
    
    return dll


def load_model(filepath):
    """ Returns a JMI model loaded from file.
    
    @param filepath The absolute or relative path to the model file to
                    be loaded.
    @return 
    
    If the model cannot be loaded a JMIException will be raised.
    
    """
    dll = load_DLL(filepath)


def _translate_value_ref(valueref):
    """ Uses a value reference which is a 32 bit unsigned int to get type of 
        variable and index in vector using the protocol: bit 0-28 is index, 
        29-31 is primitive type.
        
        @param valueref: The value reference to translate.
        
        @return: Primitive type and index in the corresponding vector as integers.
    """
    indexmask = 0x0FFFFFFF
    ptypemask = 0xF0000000
    
    index = int(valueref) & indexmask
    ptype = (int(valueref) & ptypemask) >> 28
    
    return (index,ptype)

# ================================================================
#                        HIGH LEVEL INTERFACE
# ================================================================

class JMIModel(object):
    """ A JMI Model loaded from a DLL.

    """
    
    def __init__(self, libname, path='.'):
        self._dll = load_DLL(libname, path)

        self._jmi = ct.c_voidp()
        assert self._dll.jmi_new(byref(self._jmi)) == 0, \
               "jmi_new returned non-zero"
        assert self._jmi.value is not None, \
               "jmi struct not returned correctly"
        
        # The actual array. These must must not be reset (only changed)
        # as they are pointing to a shared memory space used by
        # both the JMI DLL and us. Therefor Python properties are used
        # to ensure that they aren't reset, only modified.
        self._x = self._dll.jmi_get_x(self._jmi);
        self._pi = self._dll.jmi_get_pi(self._jmi);
        self._cd = self._dll.jmi_get_cd(self._jmi)
        self._ci = self._dll.jmi_get_ci(self._jmi)
        self._dx = self._dll.jmi_get_dx(self._jmi)
        self._pd = self._dll.jmi_get_pd(self._jmi)
        self._u = self._dll.jmi_get_u(self._jmi)
        self._w = self._dll.jmi_get_w(self._jmi)
        self._t = self._dll.jmi_get_t(self._jmi)
        self._z = self._dll.jmi_get_z(self._jmi)

        # sizes of all arrays
        self._n_ci = ct.c_int()
        self._n_cd = ct.c_int()
        self._n_pi = ct.c_int()
        self._n_pd = ct.c_int()
        self._n_dx = ct.c_int()
        self._n_x  = ct.c_int()
        self._n_u  = ct.c_int()
        self._n_w  = ct.c_int()
        self._n_tp = ct.c_int()
        self._n_z  = ct.c_int()
        
        self.get_sizes()

        # offsets
        self._offs_ci = ct.c_int()
        self._offs_cd = ct.c_int()
        self._offs_pi = ct.c_int()
        self._offs_pd = ct.c_int()
        self._offs_dx = ct.c_int()
        self._offs_x = ct.c_int()
        self._offs_u = ct.c_int()
        self._offs_w = ct.c_int()
        self._offs_t = ct.c_int()
        self._offs_dx_p = ct.c_int()
        self._offs_x_p = ct.c_int()
        self._offs_u_p = ct.c_int()
        self._offs_w_p = ct.c_int()

        self.get_offsets()

        # set start attributes
        xml_variables_name=libname+'_variables.xml' 
        # assumes libname is name of model and xmlfile is located in the same dir as the dll
        self._set_XMLvariables_doc(xmlparser.XMLVariablesDoc(path+os.sep+xml_variables_name))
        self._set_start_attributes()
        
        # set independent parameter values
        xml_values_name = libname+'_values.xml'
        self._set_XMLvalues_doc(xmlparser.XMLValuesDoc(path+os.sep+xml_values_name))
        self._set_iparam_values()
                
        # set optimizataion interval, time points and optimization indices (if Optimica)
        xml_problvariables_name = libname+'_problvariables.xml'
        try:
            self._set_XMLproblvariables_doc(xmlparser.XMLProblVariablesDoc(path+os.sep+xml_problvariables_name))
            self._set_opt_interval()
            self._set_timepoints()
            self._set_p_opt_indices()
            
        except IOError, e:
            # Modelica model - can not load Optimica specific xml
            pass

        
        self.initAD()
         
    def initAD(self):
        """Initializing Algorithmic Differential package.
        
            Raises a JMIException on failure.
        """
        if self._dll.jmi_ad_init(self._jmi) is not 0:
            raise JMIException("Could not initialize AD.")
               
    def __del__(self):
        """ Freeing jmi data structure.
        
        """
        assert self._dll.jmi_delete(self._jmi) == 0, \
               "jmi_delete failed"
               
    def get_sizes(self):
        """ Gets the sizes of the variable vectors.
        
        """
        retval = self._dll.jmi_get_sizes(self._jmi,
                                 byref(self._n_ci),
                                 byref(self._n_cd),
                                 byref(self._n_pi),
                                 byref(self._n_pd),
                                 byref(self._n_dx),
                                 byref(self._n_x),
                                 byref(self._n_u),
                                 byref(self._n_w),
                                 byref(self._n_tp),
                                 byref(self._n_z))
        if retval is not 0:
            raise JMIException("Getting sizes failed.")
                     
        l = [self._n_ci.value, self._n_cd.value, self._n_pi.value, self._n_pd.value, self._n_dx.value, 
             self._n_x.value, self._n_u.value, self._n_w.value, self._n_tp.value, self._n_z.value]
        return l
    
    def get_offsets(self):
        """ Gets the offsets for the variable types in the z vector.
        
        """
        retval = self._dll.jmi_get_offsets(self._jmi,
                                         byref(self._offs_ci),
                                         byref(self._offs_cd),
                                         byref(self._offs_pi),
                                         byref(self._offs_pd),
                                         byref(self._offs_dx),
                                         byref(self._offs_x),
                                         byref(self._offs_u),
                                         byref(self._offs_w),
                                         byref(self._offs_t),
                                         byref(self._offs_dx_p),
                                         byref(self._offs_x_p),
                                         byref(self._offs_u_p),
                                         byref(self._offs_w_p))
        if retval is not 0:
            raise JMIException("Getting offsets failed.")
        
        l = [self._offs_ci.value, self._offs_cd.value, self._offs_pi.value, self._offs_pd.value, 
             self._offs_dx.value, self._offs_x.value, self._offs_u.value, self._offs_w.value, 
             self._offs_t.value, self._offs_dx_p.value, self._offs_x_p.value, self._offs_u_p.value, 
             self._offs_w_p.value]
        return l
    
    def get_n_tp(self):
        """ Gets the number of time points in the model.
        
        """
        if self._dll.jmi_get_n_tp(self._jmi, byref(self._n_tp)) is not 0:
            raise JMIException("Getting number of time points in the model failed.")
        return self._n_tp.value

    def set_tp(self, tp):
        """ Sets the vector of time points. 
        
        """
        if self._dll.jmi_set_tp(self._jmi, tp) is not 0:
            raise JMIException("Setting vector of time points failed.")
        
    def get_tp(self, tp):
        """ Gets the vector of time points.
        
        """
        if self._dll.jmi_get_tp(self._jmi, tp) is not 0:
            raise JMIException("Getting vector of time points failed.")

    def getX(self):
        """ Gets a reference to the differentiated variables vector.
        
        """
        return self._x
        
    def setX(self, x):
        """ Sets the differentiated variables vector.
        
        """
        self._x[:] = x
        
    x = property(getX, setX, "The differentiated variables vector.")

    def getX_P(self, i):
        """ Gets a reference to the differentiated variables vector corresponding to 
            the i:th time point.
            
        """
        return self._dll.jmi_get_x_p(self._jmi, i)
        
    def setX_P(self, new_x_p, i):
        """ Sets the differentiated variables vector corresponding to the i:th time point.
        
        """
        x_p = self._dll.jmi_get_x_p(self._jmi, i)
        x_p[:] = new_x_p
        
    x_p = property(getX_P, setX_P, "The differentiated variables corresponding to the i:th time point.")
    
    def getPI(self):
        """ Gets a reference to the independent parameters vector.
        
        """
        return self._pi
        
    def setPI(self, pi):
        """ Sets the independent parameters vector.
        
        """
        self._pi[:] = pi
        
    pi = property(getPI, setPI, "The independent parameter vector.")

    def getCD(self):
        """ Gets a reference to the dependent constants vector.
        
        """
        return self._cd
        
    def setCD(self, cd):
        """ Sets the dependent constants vector.
        
        """
        self._cd[:] = cd
        
    cd = property(getCD, setCD, "The dependent constants vector.")

    def getCI(self):
        """ Gets a reference to the independent constants vector.
        
        """
        return self._ci
        
    def setCI(self, ci):
        """ Sets the independent constants vector.
        
        """
        self._ci[:] = ci
        
    ci = property(getCI, setCI, "The independent constants vector.")

    def getDX(self):
        """ Gets a reference to the derivatives vector.
        
        """
        return self._dx
        
    def setDX(self, dx):
        """ Sets the derivatives vector.
        
        """
        self._dx[:] = dx
        
    dx = property(getDX, setDX, "The derivatives vector.")

    def getDX_P(self, i):
        """ Gets a reference to the derivatives variables vector corresponding to 
            the i:th time point.
            
        """
        return self._dll.jmi_get_dx_p(self._jmi,i)
        
    def setDX_P(self, new_dx_p, i):
        """ Sets the derivatives variables vector corresponding to the i:th time point.
        
        """
        dx_p = self._dll.jmi_get_dx_p(self._jmi,i)
        dx_p[:] = new_dx_p
        
    dx_p = property(getDX_P, setDX_P, "The derivatives corresponding to the i:th time point.")

    def getPD(self):
        """ Gets a reference to the dependent parameters vector.
        
        """
        return self._pd
        
    def setPD(self, pd):
        """ Sets the dependent parameters vector.
        
        """
        self._pd[:] = pd
        
    pd = property(getPD, setPD, "The dependent paramenters vector.")

    def getU(self):
        """ Gets a reference to the inputs vector.
        
        """
        return self._u
        
    def setU(self, u):
        """ Sets the inputs vector.
        
        """
        self._u[:] = u
        
    u = property(getU, setU, "The inputs vector.")

    def getU_P(self, i):
        """ Gets a reference to the inputs vector corresponding to the i:th time point.
        
        """
        return self._dll.jmi_get_u_p(self._jmi, i)
        
    def setU_P(self, new_u_p, i):
        """ Sets the inputs vector corresponding to the i:th time point.
        
        """
        u_p = self._dll.jmi_get_u_p(self._jmi, i)
        u_p[:] = new_u_p
        
    u_p = property(getU_P, setU_P, "The inputs corresponding to the i:th time point.")

    def getW(self):
        """ Gets a reference to the algebraic variables vector.
        
        """
        return self._w
        
    def setW(self, w):
        """ Sets the algebraic variables vector.
        
        """
        self._w[:] = w
        
    w = property(getW, setW, "The algebraic variables vector.")

    def getW_P(self, i):
        """ Gets a reference to the algebraic variables vector corresponding to 
            the i:th time point.
            
        """
        return self._dll.jmi_get_w_p(self._jmi, i)
        
    def setW_P(self, new_w_p, i):
        """ Sets the algebraic variables vector corresponding to the i:th time point.
        
        """
        w_p = self._dll.jmi_get_w_p(self._jmi, i)
        w_p[:] = new_w_p
        
    w_p = property(getW_P, setW_P, "The algebraic variables corresponding to the i:th time point.")

    def getT(self):
        """ Gets a reference to the time value.
        
            @note:
                getT returns a NumPy array of length 1.
        """
        return self._t
        
    def setT(self, t):
        """ Sets the time value.
        
            @note:
                Parameter t must be a NumPy array of length 1.
        """
        self._t[:] = t
        
    t = property(getT, setT, "The time value.")
    
    def getZ(self):
        """ Gets a reference to the vector containing all parameters, variables 
            and point-wise evalutated variables vector.
            
        """
        return self._z
        
    def setZ(self, z):
        """ Sets the vector containing all parameters, variables and point-wise 
            evalutated variables vector.
            
        """
        self._z[:] = z
        
    z = property(getZ, setZ, "All parameters, variables and point-wise evaluated variables vector.")   
    
    def ode_f(self):
        """ Evalutates the right hand side of the ODE.
        
        """
        if self._dll.jmi_ode_f(self._jmi) is not 0:
            raise JMIException("Evaluating ODE failed.")
        
    def ode_df(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the right hand side of the ODE.
        
        """
        if self._dll.jmi_ode_df(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluation of Jacobian failed.")
    
    def ode_df_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the Jacobian of the right hand side of the ODE.
        
        """
        n_nz = ct.c_int()
        if self._dll.jmi_ode_df_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting number of non-zeros failed.")
        return n_nz.value
    
    def ode_df_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements in the Jacobian 
            of the right hand side of the ODE.
            
        """
        if self._dll.jmi_ode_df_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting row and column indices failed.")
    
    def ode_df_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Returns the number of columns and non-zero elements in the Jacobian 
            of the right hand side of the ODE.
            
        """
        df_n_cols = ct.c_int()
        df_n_nz = ct.c_int()
        if self._dll.jmi_ode_df_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(df_n_cols), byref(df_n_nz)) is not 0:
            raise JMIException("Getting number of columns and non-zero elements failed.")        
        return df_n_cols.value, df_n_nz.value
    
    def dae_get_sizes(self):
        """ Returns the number of equations of the DAE.
        
        """
        n_eq_F = ct.c_int
        if self._dll.jmi_dae_get_sizes(self._jmi, byref(n_eq_F)) is not 0:
            raise JMIException("Getting number of equations failed.")
        return n_eq_F.value
    
    def dae_F(self, res):
        """ Evaluates the DAE residual.
        
        """
        if self._dll.jmi_dae_F(self._jmi, res) is not 0:
            raise JMIException("Evaluating the DAE residual failed.")
    
    def dae_dF(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the DAE residual function.
        
        """
        if self._dll.jmi_dae_dF(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def dae_dF_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full DAE residual Jacobian.
        
        """
        n_nz = ct.c_int
        if self._dll.jmi_dae_dF_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
    
    def dae_dF_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements in the 
            DAE residual Jacobian.
            
        """
        if self._dll.jmi_dae_dF_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, cols) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def dae_dF_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Returns the number of columns and non-zero elements in the Jacobian 
            of the DAE residual.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_dae_dF_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Returning the number of columns and non-zero elements failed.")        
        return dF_n_cols.value, dF_n_nz.value
    
    def init_get_sizes(self):
        """ The number of equations in the DAE initialization functions.
        
        """
        n_eq_f0 = ct.c_int
        n_eq_f1 = ct.c_int
        n_eq_fp = ct.c_int
        if self._dll.jmi_init_get_sizes(self._jmi, byref(n_eq_f0), byref(n_eq_f1), byref(n_eq_fp)) is not 0:
            raise JMIException("Getting the number of equations failed.")
        return n_eq_f0.value, n_eq_f1.value, n_eq_fp.value
    
    def init_F0(self, res):
        """ Evaluates the F0 residual function of the initialization system.
        
        """
        if self._dll.jmi_init_F0(self._jmi, res) is not 0:
            raise JMIException("Evaluating the F0 residual function failed.")
        
    def init_dF0(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the DAE initialization residual function F0.
        
        """
        if self._dll.jmi_init_dF0(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def init_dF0_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the DAE 
            initialization residual function F0.
            
        """
        n_nz = ct.c_int
        if self._dll.jmi_init_dF0_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
    
    def init_dF0_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements in the 
            Jacobian of the DAE initialization residual function F0.
            
        """
        if self._dll.jmi_init_dF0_nz_indices(self._jmi, eval_alg, independent_vars, mask, row_i, cols_i) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def init_dF0_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Returns the number of columns and non-zero elements in the Jacobian 
            of the DAE initialization residual function F0.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_init_dF0_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Returning the number of columns and non-zero elements failed.")             
        return dF_n_cols.value, dF_n_nz.value

    def init_F1(self, res):
        """ Evaluates the F1 residual function of the initialization system.
        
        """
        if self._dll.jmi_init_F1(self._jmi, res) is not 0:
            raise JMIException("Evaluating the F1 residual function failed.")            
        
    def init_dF1(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the DAE initialization residual function F1.
        
        """
        if self._dll.jmi_init_dF1(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def init_dF1_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the DAE 
            initialization residual function F1.
            
        """
        n_nz = ct.c_int
        if self._dll.jmi_init_dF1_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
    
    def init_dF1_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements in the 
            Jacobian of the DAE initialization residual function F1.
            
        """
        if self._dll.jmi_init_dF1_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, cols) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def init_dF1_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Returns the number of columns and non-zero elements in the Jacobian 
            of the DAE initialization residual function F1.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_init_dF1_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Getting the number of columns and non-zero elements failed.")        
        return dF_n_cols.value, dF_n_nz.value
 
    def init_Fp(self, res):
        """ Evaluates the Fp residual function of the initialization system.
        
        """
        if self._dll.jmi_init_Fp(self._jmi, res) is not 0:
            raise JMIException("Evaluating the Fp residual function failed.")
        
    def init_dFp(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the DAE initialization residual function Fp.
        
        """
        if self._dll.jmi_init_dFp(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def init_dFp_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the DAE 
            initialization residual function Fp.
            
        """
        n_nz = ct.c_int
        if self._dll.jmi_init_dFp_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
    
    def init_dFp_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements in the 
            Jacobian of the DAE initialization residual function Fp.
            
        """
        if self._dll.jmi_init_dFp_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, cols) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def init_dFp_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Returns the number of columns and non-zero elements in the Jacobian 
            of the DAE initialization residual function Fp.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_init_dFp_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Getting the number of columns and non-zero elements failed.")        
        return dF_n_cols.value, dF_n_nz.value
    
    def opt_set_optimization_interval(self, start_time, start_time_free, final_time, final_time_free):
        """ Sets the optimization interval.
        
        """
        if self._dll.jmi_opt_set_optimization_interval(self._jmi, start_time, start_time_free, final_time, final_time_free) is not 0:
            raise JMIException("Setting the optimization interval failed.")
        
    def opt_get_optimization_interval(self):
        """ Gets the optimization interval.
        
        """
        start_time = ct.c_double()
        start_time_free = ct.c_int()
        final_time = ct.c_double()
        final_time_free = ct.c_int()
        if self._dll.jmi_opt_get_optimization_interval(self._jmi, byref(start_time), byref(start_time_free), byref(final_time), byref(final_time_free)) is not 0:
            raise JMIException("Getting the optimization interval failed.")
        return start_time.value, start_time_free.value, final_time.value, final_time_free.value
        
    def opt_set_p_opt_indices(self, n_p_opt, p_opt_indices):
        """ Specifies optimization parameters for the model.
        
        """
        if self._dll.jmi_opt_set_p_opt_indices(self._jmi, n_p_opt, p_opt_indices) is not 0:
            raise JMIException("Specifing optimization parameters failed.")
        
    def opt_get_n_p_opt(self):
        """ Gets the number of optimization parameters.
        
        """
        n_p_opt = ct.c_int()
        if self._dll.jmi_opt_get_n_p_opt(self._jmi, byref(n_p_opt)) is not 0:
            raise JMIException("Getting the number of optimization parameters failed.")
        return n_p_opt.value
        
    def opt_get_p_opt_indices(self, p_opt_indices):
        """ Gets the optimization parameter indices.
        
        """
        if self._dll.jmi_opt_get_p_opt_indices(self._jmi, p_opt_indices) is not 0:
            raise JMIException("Getting the optimization parameters failed.")
        
    def opt_get_sizes(self):
        """ Gets the sizes of the optimization functions.
        
        """
        n_eq_Ceq = ct.c_int()
        n_eq_Cineq = ct.c_int()
        n_eq_Heq = ct.c_int()
        n_eq_Hineq = ct.c_int()
        if self._dll.jmi_opt_get_sizes(self._jmi, byref(n_eq_Ceq), byref(n_eq_Cineq), byref(n_eq_Heq), byref(n_eq_Hineq)) is not 0:
            raise JMIException("Getting the sizes of the optimization functions failed.")
        return n_eq_Ceq.value, n_eq_Cineq.value, n_eq_Heq.value, n_eq_Hineq.value
        
    def opt_J(self, J):
        """ Evaluates the cost function J.
        
        """
        if self._dll.jmi_opt_J(self._jmi, J) is not 0:
            raise JMIException("Evaluation of J failed.")
        
    def opt_dJ(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the gradient of the cost function.
        
        """
        if self._dll.jmi_opt_dJ(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluation of the gradient of the cost function failed.")
        
    def opt_dJ_n_nz(self, eval_alg):
        """ Returns the number of zeros in the gradient of the cost function J.
        
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dJ_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of zeros failed.")
        return n_nz.value
        
    def opt_dJ_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements 
            in the gradient of the cost function J.
            
        """
        if self._dll.jmi_opt_dJ_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")        
        
    def opt_dJ_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Computes the number of columns and non-zero elements in 
            the gradient of the cost function.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_opt_dJ_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return dF_n_cols.value, dF_n_nz.value
        
    def opt_Ceq(self, res):
        """ Evaluates the residual of the equality path constraint Ceq.
        
        """
        if self._dll.jmi_opt_Ceq(self._jmi, res) is not 0:
            raise JMIException("Evaluation of the residual of the equality path constraint Ceq failed.")
        
    def opt_dCeq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the equality path constraint Ceq.
        
        """
        if self._dll.jmi_opt_dCeq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluation of the Jacobian of the equality path constraint Ceq failed.")
        
    def opt_dCeq_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the
            equality path constraint Ceq.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dCeq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
        
    def opt_dCeq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements
            in the Jacobian of the equality path constraint residual Ceq.
            
        """
        if self._dll.jmi_opt_dCeq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dCeq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Computes the number of columns and non-zero elements in the 
            Jacobian of the equality path constraint residual function Ceq.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_opt_dCeq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return dF_n_cols.value, dF_n_nz.value
        
    def opt_Cineq(self, res):
        """ Evaluates the residual of the inequality path constraint Cineq.
        
        """
        if self._dll.jmi_opt_Cineq(self._jmi, res) is not 0:
            raise JMIException("Evaluating the residual of the inequality path constraint Cineq failed.")
        
    def opt_dCineq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the inequality path constraint Cineq.
        
        """
        if self._dll.jmi_opt_dCineq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian of the inequality path constraint Cineq failed.")
        
    def opt_dCineq_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the
            inequality path constraint Cineq.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dCineq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
        
    def opt_dCineq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements
            in the Jacobian of the inequality path constraint residual Cineq.
            
        """
        if self._dll.jmi_opt_dCineq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dCineq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Computes the number of columns and non-zero elements in the 
            Jacobian of the inequality path constraint residual function Cineq.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_opt_dCineq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return dF_n_cols.value, dF_n_nz.value

    def opt_Heq(self, res):
        """ Evaluates the residual of the equality point constraint Heq.
        
        """
        if self._dll.jmi_opt_Heq(self._jmi, res) is not 0:
            raise JMIException("Evaluating the residual of the equality point constraint Heq failed.")
        
    def opt_dHeq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the equality point constraint Heq.
        
        """
        if self._dll.jmi_opt_dHeq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian of the equality point constraint Heq failed.")
        
    def opt_dHeq_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the
            equality point constraint Heq.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dHeq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
        
    def opt_dHeq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements
            in the Jacobian of the equality point constraint residual Heq.
            
        """
        if self._dll.jmi_opt_dHeq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dHeq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Computes the number of columns and non-zero elements in the 
            Jacobian of the equality point constraint residual function Heq.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_opt_dHeq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return dF_n_cols.value, dF_n_nz.value

    def opt_Hineq(self, res):
        """ Evaluates the residual of the inequality point constraint Hineq.
        
        """
        if self._dll.jmi_opt_Hineq(self._jmi, res) is not 0:
            raise JMIException("Evaluating the residual of the inequality point constraint Hineq failed.")
        
    def opt_dHineq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ Evaluates the Jacobian of the inequality point constraint Hineq.
        
        """
        if self._dll.jmi_opt_dHineq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian of the inequality point constraint Hineq failed.")
        
    def opt_dHineq_n_nz(self, eval_alg):
        """ Returns the number of non-zeros in the full Jacobian of the
            inequality point constraint Hineq.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dHineq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return n_nz.value
        
    def opt_dHineq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ Returns the row and column indices of the non-zero elements
            in the Jacobian of the inequality point constraint residual Hineq.
            
        """
        if self._dll.jmi_opt_dHineq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dHineq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ Computes the number of columns and non-zero elements in the 
            Jacobian of the inequality point constraint residual function Hineq.
            
        """
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_opt_dHineq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return dF_n_cols.value, dF_n_nz.value
    
    def _get_XMLvariables_doc(self):
        """ Gets a reference to the XMLDoc instance for model variables set for 
            this JMIModel.
            
        """
        return self._xmlvariables_doc
    
    def _set_XMLvariables_doc(self, doc):
        """ Sets the XMLDoc for model variables for this JMIModel.
        
        """
        self._xmlvariables_doc = doc

    def _get_XMLvalues_doc(self):
        """ Gets a reference to the XMLDoc instance for independent parameter 
            values set for this JMIModel.
            
        """
        return self._xmlvalues_doc
    
    def _set_XMLvalues_doc(self, doc):
        """ Sets the XMLDoc for independent parameter values for this JMIModel.
        
        """
        self._xmlvalues_doc = doc

    def _get_XMLproblvariables_doc(self):
        """ Gets a reference to the XMLDoc instance for optimization problem variables 
            set for this JMIModel.
            
        """
        return self._xmlproblvariables_doc
    
    def _set_XMLproblvariables_doc(self, doc):
        """ Sets the XMLDoc for optimization problem variables for this JMIModel.
        
        """
        self._xmlproblvariables_doc = doc
       
    def _set_start_attributes(self):
        """ Sets start attributes for all variables in this JMIModel. The start attributes are 
            fetched together with the corresponding valueReferences from the XMLDoc instance. 
            The valueReferences are mapped to which primitive type vector and index in vector 
            each start value belongs to using the protocol implemented in _translateValueRef.
            
        """
        xmldoc = self._get_XMLvariables_doc()
        start_attr = xmldoc.get_start_attributes()
        
        #Real variables vector
        z = self.getZ()
        
        keys = start_attr.keys()
        keys.sort(key=int)
        
        for key in keys:
            value = start_attr.get(key)
            
            (i, ptype) = _translate_value_ref(key)
            if(ptype == 0):
                # Primitive type is Real
                z[i] = value
            elif(ptype == 1):
                # Primitive type is Integer
                pass
            elif(ptype == 2):
                # Primitive type is Boolean
                pass
            elif(ptype == 3):
                # Primitive type is String
                pass
            else:
                "Unknown type"
    
    def _set_iparam_values(self):
        """ Sets values for the independent parameters in this JMIModel.
        
        """
        xmldoc = self._get_XMLvalues_doc()
        values = xmldoc.get_iparam_values()
       
        z = self.getZ()
       
        keys = values.keys()
        keys.sort(key=int)
       
        for key in keys:
            value = values.get(key)
            (i, ptype) = _translate_value_ref(key)
           
            if(ptype == 0):
               # Primitive type is Real
               z[i] = value
            elif(ptype == 1):
                # Primitive type is Integer
                pass
            elif(ptype == 2):
                # Primitive type is Boolean
                pass
            elif(ptype == 3):
                # Primitive type is String
                pass
            else:
                "Unknown type"
            
    def _set_opt_interval(self):
        """ Sets the optimization intervals for this JMIModel (if Optimica).
        
        """
        xmldoc = self._get_XMLproblvariables_doc()
        starttime = xmldoc.get_starttime()
        starttimefree = xmldoc.get_starttime_free()
        finaltime = xmldoc.get_finaltime()
        finaltimefree = xmldoc.get_finaltime_free()

        if starttime and finaltime:
            self.opt_set_optimization_interval(float(starttime), int(starttimefree),
                                                        float(finaltime), int(finaltimefree))        
        
    def _set_timepoints(self):       
        """ Sets the optimization timepoints for this JMIModel (if Optimica).
        
        """
        xmldoc = self._get_XMLproblvariables_doc()
        points = []
        for point in xmldoc.get_timepoints():
            points.append(float(point))
         
        self.set_tp(N.array(points))   

        
    def _set_p_opt_indices(self):
        """ Sets the optimization parameter indices for this JMIModel (if Optimica).
        
        """
        xmldoc = self._get_XMLvariables_doc()
        refs = xmldoc.get_p_opt_variable_refs()
        
        if len(refs) > 0:
            n_p_opt = 0
            p_opt_indices = []
            refs.sort(key=int)
            
            for ref in refs:
                (z_i, ptype) = _translate_value_ref(ref)
                p_opt_indices.append(z_i - self._offs_pi.value)
                n_p_opt = n_p_opt +1

            self.opt_set_p_opt_indices(n_p_opt,N.array(p_opt_indices))

class JMISimultaneousOptLagPols(object):
    
    def __init__(self, jmi_model, n_e, hs, n_cp):
        self._jmi_model = jmi_model
        self._jmi_opt_sim = ct.c_voidp()

        # Initialization
        _p_opt_init = N.zeros(jmi_model.opt_get_n_p_opt())
        _dx_init = N.zeros(jmi_model._n_dx.value)
        _x_init = N.zeros(jmi_model._n_x.value)
        _u_init = N.zeros(jmi_model._n_u.value)
        _w_init = N.zeros(jmi_model._n_w.value)
    
        # Bounds
        _p_opt_lb = -1.0e20*N.ones(jmi_model.opt_get_n_p_opt())
        _dx_lb = -1.0e20*N.ones(jmi_model._n_dx.value)
        _x_lb = -1.0e20*N.ones(jmi_model._n_x.value)
        _u_lb = -1.0e20*N.ones(jmi_model._n_u.value)
        _w_lb = -1.0e20*N.ones(jmi_model._n_w.value)
        _t0_lb = 0.; # not yet supported
        _tf_lb = 0.; # not yet supported
        _hs_lb = N.zeros(n_e); # not yet supported
        
        _p_opt_ub = 1.0e20*N.ones(jmi_model.opt_get_n_p_opt())
        _dx_ub = 1.0e20*N.ones(jmi_model._n_dx.value)
        _x_ub = 1.0e20*N.ones(jmi_model._n_x.value)
        _u_ub = 1.0e20*N.ones(jmi_model._n_u.value)
        _w_ub = 1.0e20*N.ones(jmi_model._n_w.value)
        _t0_ub = 0.; # not yet supported
        _tf_ub = 0.; # not yet supported
        _hs_ub = N.zeros(n_e); # not yet supported
                
        # default values
        hs_free = 0
        
        self._set_initial_values(_p_opt_init, _dx_init, _x_init, _u_init, _w_init)
        self._set_lb_values(_p_opt_lb, _dx_lb, _x_lb, _u_lb, _w_lb)
        self._set_ub_values(_p_opt_ub, _dx_ub, _x_ub, _u_ub, _w_ub)
                
        assert self._jmi_model._dll.jmi_opt_sim_lp_new(byref(self._jmi_opt_sim), self._jmi_model._jmi, n_e,
                                  hs, hs_free,
                                 _p_opt_init, _dx_init, _x_init,
                                 _u_init, _w_init,
                                 _p_opt_lb, _dx_lb, _x_lb,
                                 _u_lb, _w_lb, _t0_lb,
                                 _tf_lb, _hs_lb,
                                 _p_opt_ub, _dx_ub, _x_ub,
                                 _u_ub, _w_ub, _t0_ub,
                                 _tf_ub, _hs_ub,
                                 n_cp,JMI_DER_CPPAD) is 0, \
                                 " jmi_opt_lp_new returned non-zero."
        assert self._jmi_opt_sim.value is not None, \
            "jmi_opt_sim_lp struct has not returned correctly."
            
    def __del__(self):
        """ Freeing jmi_opt_sim data structure.
        
        """
        assert self._jmi_model._dll.jmi_opt_sim_lp_delete(self._jmi_opt_sim) == 0, \
               "jmi_delete failed"

    def opt_sim_lp_get_pols(self, n_cp, cp, cpp, Lp_coeffs, Lpp_coeffs, Lp_dot_coeffs, Lpp_dot_coeffs, Lp_dot_vals, Lpp_dot_vals):
        if self._jmi_model._dll.jmi_opt_sim_lp_get_pols(n_cp, cp, cpp, Lp_coeffs, Lpp_coeffs, Lp_dot_coeffs, 
                                                        Lpp_dot_coeffs, Lp_dot_vals, Lpp_dot_vals) is not 0:
            raise JMIException("Getting sim lp pols failed.")
        
    
    def _set_initial_values(self, p_opt_init, dx_init, x_init, u_init, w_init):
        xmldoc = self._jmi_model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_p_opt = z_i - self._jmi_model._offs_pi.value
            p_opt_init[i_p_opt] = values.get(ref)         

        # dx: derivative
        values = xmldoc.get_dx_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_dx = z_i - self._jmi_model._offs_dx.value
            dx_init[i_dx] = values.get(ref) 
        
        # x: differentiate
        values = xmldoc.get_x_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_x = z_i - self._jmi_model._offs_x.value
            x_init[i_x] = values.get(ref)
            
        # u: input
        values = xmldoc.get_u_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_u = z_i - self._jmi_model._offs_u.value
            u_init[i_u] = values.get(ref)
        
        # w: algebraic
        values = xmldoc.get_w_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_w = z_i - self._jmi_model._offs_w.value
            w_init[i_w] = values.get(ref) 

    def _set_lb_values(self, p_opt_lb, dx_lb, x_lb, u_lb, w_lb):
        xmldoc = self._jmi_model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_p_opt = z_i - self._jmi_model._offs_pi.value
            p_opt_lb[i_p_opt] = values.get(ref)         

        # dx: derivative
        values = xmldoc.get_dx_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_dx = z_i - self._jmi_model._offs_dx.value
            dx_lb[i_dx] = values.get(ref) 
        
        # x: differentiate
        values = xmldoc.get_x_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_x = z_i - self._jmi_model._offs_x.value
            x_lb[i_x] = values.get(ref)
            
        # u: input
        values = xmldoc.get_u_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_u = z_i - self._jmi_model._offs_u.value
            u_lb[i_u] = values.get(ref)
        
        # w: algebraic
        values = xmldoc.get_w_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_w = z_i - self._jmi_model._offs_w.value
            w_lb[i_w] = values.get(ref) 

    def _set_ub_values(self, p_opt_ub, dx_ub, x_ub, u_ub, w_ub):
        xmldoc = self._jmi_model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_p_opt = z_i - self._jmi_model._offs_pi.value
            p_opt_ub[i_p_opt] = values.get(ref)         

        # dx: derivative
        values = xmldoc.get_dx_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_dx = z_i - self._jmi_model._offs_dx.value
            dx_ub[i_dx] = values.get(ref) 
        
        # x: differentiate
        values = xmldoc.get_x_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_x = z_i - self._jmi_model._offs_x.value
            x_ub[i_x] = values.get(ref)
            
        # u: input
        values = xmldoc.get_u_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_u = z_i - self._jmi_model._offs_u.value
            u_ub[i_u] = values.get(ref)
        
        # w: algebraic
        values = xmldoc.get_w_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = _translate_value_ref(ref)
            i_w = z_i - self._jmi_model._offs_w.value
            w_ub[i_w] = values.get(ref) 
       
class JMISimultaneousOptIPOPT(object):
    
    def __init__(self, jmi_opt_sim_model):
        self._jmi_opt_sim_model = jmi_opt_sim_model
        self._jmi_opt_sim_ipopt = ct.c_voidp()     
        
        assert self._jmi_opt_sim_model._jmi_model._dll.jmi_opt_sim_ipopt_new(byref(self._jmi_opt_sim_ipopt), 
                                                                             self._jmi_opt_sim_model._jmi_opt_sim) == 0, \
               "jmi_opt_sim_ipopt_new returned non-zero"
        assert self._jmi_opt_sim_ipopt.value is not None, \
               "jmi struct not returned correctly"
    
        
    def opt_sim_ipopt_solve(self):    
        if self._jmi_opt_sim_model._jmi_model._dll.jmi_opt_sim_ipopt_solve(self._jmi_opt_sim_ipopt) is not 0:
            raise JMIException("Solving IPOPT failed.")
    
    def opt_sim_ipopt_set_string_option(self, key, val):
        if self._jmi_opt_sim_model._jmi_model._dll.jmi_opt_sim_ipopt_set_string_option(self._jmi_opt_sim_ipopt, key, val) is not 0:
            raise JMIException("Setting string option failed.")
        
    def opt_sim_ipopt_set_int_option(self, key, val):
        if self._jmi_opt_sim_model._jmi_model._dll.jmi_opt_sim_ipopt_set_int_option(self._jmi_opt_sim_ipopt, key, val) is not 0:
            raise JMIException("Setting int option failed.")

    def opt_sim_ipopt_set_num_option(self, key, val):
        if self._jmi_opt_sim_model._jmi_model._dll.jmi_opt_sim_ipopt_set_num_option(self._jmi_opt_sim_ipopt, key, val) is not 0:
            raise JMIException("Setting num option failed.")
    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

    