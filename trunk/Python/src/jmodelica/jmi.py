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


import os

import sys
import ctypes as ct
from ctypes import byref
import numpy as N
import numpy.ctypeslib as Nct
import tempfile
import shutil
import _ctypes
import atexit

import xmlparser
import io

int = N.int32
N.int = N.int32

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
    """A ctypes errcheck that always fails."""
    
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
        """Set meta data about the array the returned pointer is pointing to.
        
        Parameters:
            shape -- a tuple containing the shape of the array
            dtype -- the data type that the function result points to.
            ndim  -- the optional number of dimensions that the result returns.
            order (optional) -- the same order parameter as can be used in
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
    """Sets automatic conversion to ndarray of DLL function results."""
    
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
    
    Parameters:
        libname -- name of the library without prefix.
        path -- the relative or absolute path to the library.
    
    See also http://docs.python.org/library/ct.html
    
    """

    # Don't catch this exception since it hides the acutal source
    # of the error.
    dll = Nct.load_library(libname, path)
    
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
    n_eq_R = ct.c_int()
    assert dll.jmi_dae_get_sizes(jmi,
                                 byref(n_eq_F),byref(n_eq_R)) \
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
                                      ct.POINTER(ct.c_int),
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
    
#    if dF_n_nz is not None:
#        dll.jmi_dae_dF_nz_indices.argtypes = [ct.c_void_p,
#                                              ct.c_int,
#                                              ct.c_int,
#                                              Nct.ndpointer(
#                                                dtype=ct.c_int,
#                                                ndim=1,
#                                                shape=n_z.value,
#                                                flags='C'),
#                                              Nct.ndpointer(
#                                                dtype=ct.c_int,
#                                                ndim=1,
#                                                shape=dF_n_nz.value,
#                                                flags='C'),
#                                              Nct.ndpointer(
#                                                dtype=ct.c_int,
#                                                ndim=1,
#                                                shape=dF_n_nz.value,
#                                                flags='C')]
#    else:
#        dll.jmi_dae_dF_nz_indices.errcheck = \
#                        fail_error_check("Functionality not supported.")      
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
                                                flags='C'),
                                              Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
                                                flags='C')]
                     
    dll.jmi_dae_dF_dim.argtypes = [ct.c_void_p, ct.c_int, ct.c_int,
                                   ct.c_int,
                                   Nct.ndpointer(dtype=ct.c_int,
                                                 ndim=1,
                                                 shape=n_z.value,
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]

    dll.jmi_dae_R.argtypes = [ct.c_void_p,
                              Nct.ndpointer(dtype=c_jmi_real_t,
                                            ndim=1,
                                            shape=n_eq_R.value,
                                            flags='C')]
    
    # DAE initialization interface
    dll.jmi_init_get_sizes.argtypes = [ct.c_void_p,
                                       ct.POINTER(ct.c_int),
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
    dll.jmi_init_dF0_n_nz.argtypes = [ct.c_void_p,
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
    dll.jmi_init_dF1_n_nz.argtypes = [ct.c_void_p,
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
    dll.jmi_init_dFp_n_nz.argtypes = [ct.c_void_p,
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

    dll.jmi_init_R0.argtypes = [ct.c_void_p,
                              Nct.ndpointer(dtype=c_jmi_real_t,
                                            ndim=1,
                                            flags='C')]    
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

    # JMI Simultaneous Optimization interface
    try:
        dll.jmi_opt_sim_get_dimensions.argtypes = [ct.c_void_p,
                                                   ct.POINTER(ct.c_int),
                                                   ct.POINTER(ct.c_int),
                                                   ct.POINTER(ct.c_int),
                                                   ct.POINTER(ct.c_int),
                                                   ct.POINTER(ct.c_int)]    
        dll.jmi_opt_sim_get_interval_spec.argtypes = [ct.c_void_p,
                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                    ndim=1,
                                                                    flags='C'),
                                                      Nct.ndpointer(dtype=ct.c_int,
                                                                    ndim=1,
                                                                    flags='C'),
                                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                                    ndim=1,
                                                                    flags='C'),
                                                      Nct.ndpointer(dtype=ct.c_int,
                                                                    ndim=1,
                                                                    flags='C')]
        dll.jmi_opt_sim_get_x.argtypes =[ct.c_void_p]
        dll.jmi_opt_sim_get_initial.argtypes = [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')]
        
        dll.jmi_opt_sim_set_initial.argtypes =  [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')] 

        dll.jmi_opt_sim_set_initial_from_trajectory.argtypes = [ct.c_void_p,
                                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                                              ndim=1,
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

        dll.jmi_opt_sim_get_bounds.argtypes = [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C'),
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')]
        dll.jmi_opt_sim_set_bounds.argtypes = [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C'),
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')]
        dll.jmi_opt_sim_f.argtypes = [ct.c_void_p,
                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                    ndim=1,
                                                    flags='C')]
        dll.jmi_opt_sim_df.argtypes = [ct.c_void_p,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C')]
        dll.jmi_opt_sim_g.argtypes = [ct.c_void_p,
                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                    ndim=1,
                                                    flags='C')]
        dll.jmi_opt_sim_dg.argtypes = [ct.c_void_p,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C')]
        dll.jmi_opt_sim_dg_nz_indices.argtypes = [ct.c_void_p,
                                                  Nct.ndpointer(dtype=ct.c_int,
                                                                ndim=1,
                                                                flags='C'),
                                                  Nct.ndpointer(dtype=ct.c_int,
                                                                ndim=1,
                                                                flags='C')]
        dll.jmi_opt_sim_h.argtypes = [ct.c_void_p,
                                      Nct.ndpointer(dtype=c_jmi_real_t,
                                                    ndim=1,
                                                    flags='C')]
        dll.jmi_opt_sim_dh.argtypes = [ct.c_void_p,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C')]
        dll.jmi_opt_sim_dh_nz_indices.argtypes = [ct.c_void_p,
                                                  Nct.ndpointer(dtype=ct.c_int,
                                                                ndim=1,
                                                                flags='C'),
                                                  Nct.ndpointer(dtype=ct.c_int,
                                                                ndim=1,
                                                                flags='C')]
        dll.jmi_opt_sim_write_file_matlab.argtypes = [ct.c_void_p,
                                                      ct.c_char_p]
        dll.jmi_opt_sim_get_result_variable_vector_length.argtypes = [ct.c_void_p,
                                                                      ct.POINTER(ct.c_int)]
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
        # This is not correct, the n_x referes to the wrong x vector
        # In this case, n_x refers to the size of the optimization vector
        # not to the number of states.
        # _returns_ndarray(dll.jmi_opt_sim_get_x, c_jmi_real_t, n_x.value, order='C')
    except AttributeError, e:
        pass

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
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
                                                     ndim=1,
                                                     flags='C'),                                           
                                       Nct.ndpointer(dtype=ct.c_int,
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

    # IPOPT interface for simulataneous optimization interface
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
        dll.jmi_opt_sim_ipopt_set_num_option.argtypes = [ct.c_void_p,
                                                            ct.c_char_p,
                                                            c_jmi_real_t]
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

    # JMI DAE initialization based on optimization
    try:
        dll.jmi_init_opt_new.argtypes = [ct.c_void_p, ct.c_void_p, ct.c_int,Nct.ndpointer(dtype=ct.c_int,
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
                             Nct.ndpointer(dtype=c_jmi_real_t,
                                           ndim=1,
                                           flags='C'),
                             Nct.ndpointer(dtype=c_jmi_real_t,
                                           ndim=1,
                                           flags='C'),
                             Nct.ndpointer(dtype=c_jmi_real_t,
                                           ndim=1,
                                           flags='C'),
                             ct.c_int,
                             Nct.ndpointer(dtype=ct.c_int,
                                           ndim=1,
                                           flags='C'),
                             Nct.ndpointer(dtype=ct.c_int,
                                           ndim=1,
                                           flags='C'),
                             Nct.ndpointer(dtype=ct.c_int,
                                           ndim=1,
                                           flags='C'),
                             Nct.ndpointer(dtype=ct.c_int,
                                           ndim=1,
                                           flags='C'),
                             ct.c_int]

        dll.jmi_init_opt_delete.argtypes = [ct.c_void_p]
        
        dll.jmi_init_opt_get_dimensions.argtypes = [ct.c_void_p,
                                                    ct.POINTER(ct.c_int),
                                                    ct.POINTER(ct.c_int),
                                                    ct.POINTER(ct.c_int)]    
        dll.jmi_init_opt_get_x.argtypes =[ct.c_void_p]
        dll.jmi_init_opt_get_initial.argtypes = [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')]
        
        dll.jmi_init_opt_set_initial.argtypes =  [ct.c_void_p,
                                                  Nct.ndpointer(dtype=c_jmi_real_t,
                                                                ndim=1,
                                                                flags='C')] 

        dll.jmi_init_opt_get_bounds.argtypes = [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C'),
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')]
        dll.jmi_init_opt_set_bounds.argtypes = [ct.c_void_p,
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C'),
                                                Nct.ndpointer(dtype=c_jmi_real_t,
                                                              ndim=1,
                                                              flags='C')]
        dll.jmi_init_opt_f.argtypes = [ct.c_void_p,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C')]
        dll.jmi_init_opt_df.argtypes = [ct.c_void_p,
                                        Nct.ndpointer(dtype=c_jmi_real_t,
                                                      ndim=1,
                                                      flags='C')]
        dll.jmi_init_opt_h.argtypes = [ct.c_void_p,
                                       Nct.ndpointer(dtype=c_jmi_real_t,
                                                     ndim=1,
                                                     flags='C')]
        dll.jmi_init_opt_dh.argtypes = [ct.c_void_p,
                                        Nct.ndpointer(dtype=c_jmi_real_t,
                                                      ndim=1,
                                                      flags='C')]
        dll.jmi_init_opt_dh_nz_indices.argtypes = [ct.c_void_p,
                                                   Nct.ndpointer(dtype=ct.c_int,
                                                                 ndim=1,
                                                                 flags='C'),
                                                   Nct.ndpointer(dtype=ct.c_int,
                                                                 ndim=1,
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
        # This is not correct, the n_x referes to the wrong x vector
        # In this case, n_x refers to the size of the optimization vector
        # in the initialization problem not to the number of states.
        # _returns_ndarray(dll.jmi_init_opt_get_x, c_jmi_real_t, n_x.value, order='C')
    except AttributeError, e:
        pass

    # IPOPT interface to DAE initialization optimization
    try:
        dll.jmi_init_opt_ipopt_new.argtypes = [ct.c_void_p,
                                              ct.c_void_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_init_opt_ipopt_solve.argtypes = [ct.c_void_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_init_opt_ipopt_set_string_option.argtypes = [ct.c_void_p,
                                                            ct.c_char_p,
                                                            ct.c_char_p]
    except AttributeError, e:
        pass
    
    try:
        dll.jmi_init_opt_ipopt_set_int_option.argtypes = [ct.c_void_p,
                                                         ct.c_char_p,
                                                         ct.c_int]
    except AttributeError, e:
        pass

    try:
        dll.jmi_init_opt_ipopt_set_num_option.argtypes = [ct.c_void_p,
                                                            ct.c_char_p,
                                                            c_jmi_real_t]
    except AttributeError, e:
        pass
   
    assert dll.jmi_delete(jmi) == 0, \
           "jmi_delete failed"
    
    return dll


def _translate_value_ref(valueref):
    """Translate a ValueReference into variable type and index in z-vector.
    
    Uses a value reference which is a 32 bit unsigned int to get type of 
    variable and index in vector using the protocol: bit 0-28 is index, 29-31 
    is primitive type.
        
    Parameters:
        valueref -- 
            The value reference to translate.
            
    Returns:
        
        Primitive type and index in the corresponding vector as integers.
    
    """
    indexmask = 0x0FFFFFFF
    ptypemask = 0xF0000000
    index = valueref & indexmask
    ptype = (valueref & ptypemask) >> 28
    return (index,ptype)

# list of temporary dll filenames and handles
_temp_dlls = []

def _cleanup():
    """Remove all temporary dll files from file system on interpreter termination.
    
    Helper function which removes all temporary dll files from the file system 
    which have been created by the JMIModel constructor and have not been 
    deleted when Python interpreter is terminated.
    
    Uses the class attribute _temp_dlls which holds a list of all temporary dll 
    file names and handles created during the Python session. 
        
    """
    for tmp in _temp_dlls:
        tmpfile = tmp.get('name')
        if os.path.exists(tmpfile) and os.path.isfile(tmpfile):
            if sys.platform == 'win32':
                _ctypes.FreeLibrary(tmp.get('handle'))
            #else:
            #    _ctypes.dlclose(tmp.get('handle'))
            os.remove(tmpfile)

# _cleanup registered to run on termination       
atexit.register(_cleanup)

# ================================================================
#                        HIGH LEVEL INTERFACE
# ================================================================

class Model(object):
    
    """ High-level interface to a JMIModel. """
    
    def __init__(self, libname, path ='.'):
        """ Constructor. """
        self.jmimodel = JMIModel(libname, path)

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
        
        self._path = os.path.abspath(path)
        self._libname = libname
        self._setDefaultValuesFromMetadata()
        self.jmimodel.initAD()
        self._set_dependent_parameters()

    def reset(self):
        """Reset the internal states of the DLL.
        
        Calling this function is equivalent to reopening the model.
        
        """
        self._setDefaultValuesFromMetadata()
        
    def _setDefaultValuesFromMetadata(self, libname=None, path=None):
        """Load metadata saved in XML files.
        
        Meta data can be things like time points, initial states, initial cost
        etc.
        
        """
        if libname is None:
            libname = self._libname
        if path is None:
            path = self._path
        
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

    def _set_dependent_parameters(self):
        """
        Sets the dependent parameters of the model.
        """
        pd_tmp = N.zeros(self._n_pd.value)
        pd = N.zeros(self._n_pd.value)
        for i in range(self._n_pd.value):
            self.set_pd(pd)
            self.jmimodel.init_Fp(pd_tmp)
            pd[i] = pd_tmp[i]
            pd_tmp[:] = pd
        self.set_pd(pd)

    def get_variable_names(self):
        """
        Extract the names of the variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        return self._get_XMLvariables_doc().get_variable_names()

    def get_derivative_names(self):
        """
        Extract the names of the derivatives in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        return self._get_XMLvariables_doc().get_derivative_names()

    def get_differentiated_variable_names(self):
        """
        Extract the names of the differentiated_variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        return self._get_XMLvariables_doc().get_differentiated_variable_names()

    def get_input_names(self):
        """
        Extract the names of the inputs in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        return self._get_XMLvariables_doc().get_input_names()

    def get_algebraic_variable_names(self):
        """
        Extract the names of the algebraic variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        return self._get_XMLvariables_doc().get_algebraic_variable_names()

    def get_p_opt_names(self):
        """
        Extract the names of the optimized parameters.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        return self._get_XMLvariables_doc().get_p_opt_names()


    def get_variable_descriptions(self):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Dict with ValueReference as key and description as value.
        """
        return self._get_XMLvariables_doc().get_variable_descriptions()

    def get_sizes(self):
        """Get and return a list of the sizes of the variable vectors."""
        self.jmimodel.get_sizes(self._n_ci,
                                self._n_cd,
                                self._n_pi,
                                self._n_pd,
                                self._n_dx,
                                self._n_x,
                                self._n_u,
                                self._n_w,
                                self._n_tp,
                                self._n_z)
        
        l = [self._n_ci.value, self._n_cd.value, self._n_pi.value, self._n_pd.value, self._n_dx.value, 
             self._n_x.value, self._n_u.value, self._n_w.value, self._n_tp.value, self._n_z.value]
        return l
    
    def get_offsets(self):
        """Get and return a list of the offsets for the variable types in the z vector."""
        
        self.jmimodel.get_offsets(self._offs_ci,
                                  self._offs_cd,
                                  self._offs_pi,
                                  self._offs_pd,
                                  self._offs_dx,
                                  self._offs_x,
                                  self._offs_u,
                                  self._offs_w,
                                  self._offs_t,
                                  self._offs_dx_p,
                                  self._offs_x_p,
                                  self._offs_u_p,
                                  self._offs_w_p)
        
        l = [self._offs_ci.value, self._offs_cd.value, self._offs_pi.value, self._offs_pd.value, 
             self._offs_dx.value, self._offs_x.value, self._offs_u.value, self._offs_w.value, 
             self._offs_t.value, self._offs_dx_p.value, self._offs_x_p.value, self._offs_u_p.value, 
             self._offs_w_p.value]
        return l

    def get_n_tp(self):
        """Get the number of time points."""
        
        self.jmimodel.get_n_tp(self._n_tp)
        return self._n_tp.value

    def get_x(self):
        """Return a reference to the differentiated variables vector."""
        return self.jmimodel.get_x()
        
    def set_x(self, x):
        """Set the differentiated variables vector."""
        self.jmimodel._x[:] = x
        
    x = property(get_x, set_x, doc="The differentiated variables vector.")

    def get_x_p(self, i):
        """Returns a reference to the differentiated variables vector
        corresponding to the i:th time point.
        
        """
        return self.jmimodel.get_x_p(i)
        
    def set_x_p(self, new_x_p, i):
        """Sets the differentiated variables vector corresponding to the i:th 
        time point. 
        
        """
        x_p = self.jmimodel.get_x_p(i)
        x_p[:] = new_x_p
    
    def get_pi(self):
        """Returns a reference to the independent parameters vector."""
        return self.jmimodel.get_pi()
        
    def set_pi(self, pi):
        """Sets the independent parameters vector."""
        self.jmimodel._pi[:] = pi
        
    pi = property(get_pi, set_pi, doc="The independent parameter vector.")

    def get_pd(self):
        """Returns a reference to the dependent parameters vector."""
        return self.jmimodel._pd
        
    def set_pd(self, pd):
        """Sets the dependent parameters vector."""
        self.jmimodel._pd[:] = pd
        
    pd = property(get_pd, set_pd, doc="The dependent paramenters vector.")

    def get_cd(self):
        """Returns a reference to the dependent constants vector."""
        return self.jmimodel.get_cd()
        
    def set_cd(self, cd):
        """Sets the dependent constants vector."""
        self.jmimodel._cd[:] = cd
        
    cd = property(get_cd, set_cd, doc="The dependent constants vector.")

    def get_ci(self):
        """Returns a reference to the independent constants vector."""
        return self.jmimodel.get_ci()
        
    def set_ci(self, ci):
        """Sets the independent constants vector."""
        self.jmimodel._ci[:] = ci
        
    ci = property(get_ci, set_ci, doc="The independent constants vector.")

    def get_dx(self):
        """Returns a reference to the derivatives vector."""
        return self.jmimodel.get_dx()
        
    def set_dx(self, dx):
        """Sets the derivatives vector."""
        self.jmimodel._dx[:] = dx
        
    dx = property(get_dx, set_dx, doc="The derivatives vector.")

    def get_dx_p(self, i):
        """Returns a reference to the derivatives variables vector
        corresponding to the i:th time point.
        """
        return self.jmimodel.get_dx_p(i)
        
    def set_dx_p(self, new_dx_p, i):
        """Sets the derivatives variables vector corresponding to the i:th
        time point.
        """
        dx_p = self.jmimodel.get_dx_p(i)
        dx_p[:] = new_dx_p

    def get_u(self):
        """Returns a reference to the inputs vector."""
        return self.jmimodel.get_u()
        
    def set_u(self, u):
        """Sets the inputs vector."""
        self.jmimodel._u[:] = u
        
    u = property(get_u, set_u, doc="The inputs vector.")

    def get_u_p(self, i):
        """Returns a reference to the inputs vector corresponding to the i:th time 
        point.
        """
        return self.jmimodel.get_u_p(i)
        
    def set_u_p(self, new_u_p, i):
        """Sets the inputs vector corresponding to the i:th time point."""
        u_p = self.jmimodel.get_u_p(i)
        u_p[:] = new_u_p

    def get_w(self):
        """Returns a reference to the algebraic variables vector."""
        return self.jmimodel.get_w()
        
    def set_w(self, w):
        """Sets the algebraic variables vector."""
        self.jmimodel._w[:] = w
        
    w = property(get_w, set_w, doc="The algebraic variables vector.")

    def get_w_p(self, i):
        """Returns a reference to the algebraic variables vector corresponding to 
        the i:th time point.
        """
        return self.jmimodel.get_w_p(i)
        
    def set_w_p(self, new_w_p, i):
        """Sets the algebraic variables vector corresponding to the i:th time 
        point.
        """
        w_p = self.jmimodel.get_w_p(i)
        w_p[:] = new_w_p

    def get_t(self):
        """Returns a reference to the time value.
        
        The return value is a NumPy array of length 1.
        """
        return self.jmimodel.get_t()
        
    def set_t(self, t):
        """Sets the time value.
        
        Parameter t must be a NumPy array of length 1.
        """
        self.jmimodel._t[:] = t
        
    t = property(get_t, set_t, doc="The time value.")
    
    def get_z(self):
        """Returns a reference to the vector containing all parameters,
        variables and point-wise evalutated variables vector.
        """
        return self.jmimodel.get_z()
        
    def set_z(self, z):
        """Sets the vector containing all parameters, variables and point-wise 
        evalutated variables vector.
        """
        self.jmimodel._z[:] = z
        
    z = property(get_z, set_z, doc="All parameters, variables and point-wise "
                                   "evaluated variables vector.")   

    def _get_XMLvariables_doc(self):
        """ Return a reference to the XMLDoc instance for model variables. """
        return self._xmlvariables_doc
    
    def _set_XMLvariables_doc(self, doc):
        """ Set the XMLDoc for model variables. """
        self._xmlvariables_doc = doc

    def _get_XMLvalues_doc(self):
        """ Return a reference to the XMLDoc instance for independent parameter values. """
        return self._xmlvalues_doc
    
    def _set_XMLvalues_doc(self, doc):
        """ Set the XMLDoc for independent parameter values. """
        self._xmlvalues_doc = doc

    def _get_XMLproblvariables_doc(self):
        """ Return a reference to the XMLDoc instance for optimization problem variables. """
        return self._xmlproblvariables_doc
    
    def _set_XMLproblvariables_doc(self, doc):
        """ Set the XMLDoc for optimization problem variables. """
        self._xmlproblvariables_doc = doc
       
    def _set_start_attributes(self):
        
        """ 
        Set start attributes for all variables. The start attributes are 
        fetched together with the corresponding valueReferences from the XMLDoc 
        instance. The valueReferences are mapped to which primitive type vector 
        and index in vector each start value belongs to using the protocol 
        implemented in _translateValueRef.
            
        """
        
        xmldoc = self._get_XMLvariables_doc()
        start_attr = xmldoc.get_start_attributes()
        
        #Real variables vector
        z = self.get_z()
        
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
    
    def _set_iparam_values(self, xmldoc=None):
        """ Set values for the independent parameters. """
        if not xmldoc:
            xmldoc = self._get_XMLvalues_doc()
        values = xmldoc.get_iparam_values()
       
        z = self.get_z()
       
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
        """ Set the optimization intervals (if Optimica). """
        xmldoc = self._get_XMLproblvariables_doc()
        starttime = xmldoc.get_starttime()
        starttimefree = xmldoc.get_starttime_free()
        finaltime = xmldoc.get_finaltime()
        finaltimefree = xmldoc.get_finaltime_free()
        if starttime!=None and finaltime!=None:
            self.jmimodel.opt_set_optimization_interval(starttime, int(starttimefree),
                                                        finaltime, int(finaltimefree))
        else:
            print "Could not set optimization interval. Optimization starttime and/or finaltime was None."   

    def _set_timepoints(self):       
        """ Set the optimization timepoints (if Optimica). """        
        xmldoc = self._get_XMLproblvariables_doc()
        start =  xmldoc.get_starttime()
        final = xmldoc.get_finaltime()
        points = []
        for point in xmldoc.get_timepoints():
            norm_point = (point - start) / (final-start)
            points.append(norm_point)         
        self.jmimodel.set_tp(N.array(points))   
        
    def _set_p_opt_indices(self):
        """ Set the optimization parameter indices (if Optimica). """
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
            self.jmimodel.opt_set_p_opt_indices(n_p_opt,N.array(p_opt_indices,dtype=int))

    def get_name(self):
        """ Return the name of the model. """
        return self._libname
    
    def getparameter(self, name):
        """ Get value of a parameter. """
        xmldoc = self._get_XMLvariables_doc()
        valref = xmldoc.get_valueref(name.strip())
        value = None
        if valref != None:
            (z_i, ptype) = _translate_value_ref(valref)
            value = self.get_pi()[z_i - self._offs_pi.value]
        else:
            print "Parameter "+name.strip()+" could not be found in model."
        return value
        
    def setparameter(self, name, value):
        """ Set value of a parameter. """
        xmldoc = self._get_XMLvariables_doc()
        valref = xmldoc.get_valueref(name)
        if valref != None:
            (z_i, ptype) = _translate_value_ref(valref)
            self.get_pi()[z_i - self._offs_pi.value] = value
        else:
            print "Parameter "+name+" could not be found in model."


    def get_value(self, name):
        """ Get value of a variable or parameter.

        Parameters:
            name -- name of variable or parameter.

        Raises Error if name not present in model."""
        
        xmldoc = self._get_XMLvariables_doc()
        valref = xmldoc.get_valueref(name.strip())
        value = None
        if valref != None:
            (z_i, ptype) = _translate_value_ref(valref)
            if xmldoc.is_negated_alias(name):
                value = -(self.get_z()[z_i])
            else:
                value = self.get_z()[z_i]
        else:
            raise Exception("Parameter or variable "+name.strip()+" could not be found in model.")
        return value
        
    def get_values(self, names):
        """ Get values for a list of variables or parameters.
        
        Parameters:
            names -- List of names of variables or parameters
            
        Returns:
            List of values corresponding to the variables/parameters 
            passed as argument.
            
        Raises Error if any of the names is not present in model.
        """
        values = []
        for name in names:
            values.append(self.get_value(name))
        return values
        
    def set_value(self, name, value):
        """ Set get value of a parameter or variable.
        
        Parameters:
            name -- name of variable or parameter.
            value -- parameter or variable value.

        Raises Error if name not present in model."""
        
        xmldoc = self._get_XMLvariables_doc()
        valref = xmldoc.get_valueref(name)
        if valref != None:
            (z_i, ptype) = _translate_value_ref(valref)
            if xmldoc.is_negated_alias(name):
               self.get_z()[z_i] = -(value)
            else:
                self.get_z()[z_i] = value           
        else:
            raise Exception("Parameter or variable "+name+" could not be found in model.")
    
    def set_values(self, names, values):
        """ Set values for several parameters or variables. 
        
        Parameters:
            names -- List of names of parameters or variables
            values -- List of new values for parameters or variables in names.
            
        Raises Error if number of names is not equal to number of values or if 
        any of the names can not be found in the model.    
        """
        if len(names) != len(values):
            raise Exception("Number of names and values must be the same.")
        
        for name, value in zip(names, values):
            self.set_value(name, value)

    
    def load_parameters_from_XML(self, filename="", path="."):
        """ 
        Reset pi vector with values from the XML file created 
        when model was compiled. If an XML file other than this 
        should be used instead set the parameters filename and 
        path (if no path is set file is assumed to be in the 
        current directory).
                
        Parameters:
            filename -- filename of XML file that should be loaded (optional)
            path -- directory where XML file is located (optional)
            
        Raises IOError if file could not be found.
        
        """
        if filename:
                xml_values_name = os.path.join(path, filename)
        else:
            #load original xml
            xml_values_name = os.path.join(path, self.get_name()+'_values.xml')
        
        if os.path.exists(xml_values_name):
            self._set_iparam_values(xmlparser.XMLValuesDoc(xml_values_name))
        else:
            raise IOError("The file: "+xml_values_name+" could not be found.")
        
    def write_parameters_to_XML(self, filename="", path="."):
        """ 
        Write parameter values (real) in pi vector to XML. The default 
        behaviour is to overwrite the XML file created when model was 
        compiled. To write to a new file, set parameters filename and 
        path (if no path is set file is assumed to be in the 
        current directory). 
        
        Parameters:
            filename -- filename of XML file that should be loaded (optional)
            path -- directory where XML file is located (optional)
        """
        pi = self.get_pi()
        parameters = {}
        # get all indep parameters, translate index in z-vector
        # to valueref and save in dict with parameter value as value
        for i in range(len(pi)):
            zi = i+self._offs_pi.value
            # parameter type is real (ptype=0) -> z-vector -> index = valueref
            parameters[zi]=pi[i]
            
        # get all parameters in XMLvaluesdoc, go through them all and 
        # for each, find corresponding parameter in dict created above
        # and set new value saved in dict (which comes from pi vector)
        xmldoc = self._get_XMLvalues_doc()
        elements=xmldoc._doc.findall("/RealParameter")
        for e in elements:
            ref = e.getchildren()[0]
            val = e.getchildren()[1]
            if parameters.has_key(int(ref.text)):
                val.text=str(parameters[int(ref.text)])
        # finally, write to file
        if filename:
            if not os.path.exists(path):
                os.mkdir(path)
            xmldoc._doc.write(os.path.join(path,filename))
        else:
            xmldoc._doc.write(xmldoc._doc.docinfo.URL)
            
    def get_aliases(self, variable):
        """ Return list of all alias variables belonging to the aliased 
            variable along with a list of booleans indicating whether the 
            alias variable should be negated or not.
            
            Raises exception if argument is not an aliased or alias variable.

        """
        return self._get_XMLvariables_doc().get_aliases(variable)
    
    def get_variable_description(self, variable):
        """ Return the description of a variable. """
        return self._get_XMLvariables_doc().get_variable_description(variable)
            
    def opt_interval_starttime_free(self):
        """Evaluate if optimization start time is free.
        
        Evaluates to True if so, False otherwise.
        """
        start_time, start_time_free, final_time, final_time_free = \
                                  self.jmimodel.opt_get_optimization_interval()
        return start_time_free==1
        
    def opt_interval_starttime_fixed(self):
        """Evaluate if optimization start time is fixed.
        
        Evaluates to True if so, False otherwise.
        """
        return not self.opt_interval_starttime_free()
            
    def opt_interval_finaltime_free(self):
        """Evaluate if optimization final time is free.
        
        Evaluates to True if so, False otherwise.
        """
        start_time, start_time_free, final_time, final_time_free = \
                                  self.jmimodel.opt_get_optimization_interval()
        return final_time_free==1
        
    def opt_interval_finaltime_fixed(self):
        """Evaluate if optimization final time is fixed.
        
        Evaluates to True if so, False otherwise.
        """
        return not self.opt_interval_finaltime_free()
        
    def opt_interval_get_start_time(self):
        """Returns the start time of the optimization interval."""
        start_time, start_time_free, final_time, final_time_free = \
                                  self.jmimodel.opt_get_optimization_interval()
        return start_time
        
    def opt_interval_get_final_time(self):
        """Returns the final time of the optimization interval."""
        start_time, start_time_free, final_time, final_time_free = \
                                  self.jmimodel.opt_get_optimization_interval()
        return final_time
        
    def eval_ode_f(self):
        """Evaluate an ODE.
        
        The ODE is of the form:
          dx = f(x, t, ...)
        
        The input variables to f are expected to be set BEFORE calling this
        function. The calculated dx can be accessed in two ways:
         1. By accessing is through the member Model.dx; or
         2. By using return value of this function which is the same.
         
        This function returns Model.dx on success and raises JMIException
        otherwise.
        """
        self.jmimodel.ode_f()
        return self.dx
        
    def opt_eval_J(self):
        """Return the evaluted optimization cost function, J.
        
        All values (such as u, u_p, x_p etc.) are expected to be set before
        calling this function.
        """
        return self.jmimodel.opt_J()
        
    def opt_eval_jac_J(self, independent_variables, mask=None):
        """Evaluate the jacobian of the cost function.
        
        Parameters:
        independent_variables -- the variables witch the jacobian will be based
                                 on.
        mask                  -- (optional) if only some independent variables should be
                                 (re)evaluated.
                                 
        Please refer to the JMI documentation for more info.
        """
        assert self._n_z.value != 0
        if mask is None:
            mask = N.ones(self._n_z.value, dtype=int)
        
        n_cols, n_nz = self.jmimodel.opt_dJ_dim(JMI_DER_CPPAD,
                                                JMI_DER_DENSE_ROW_MAJOR,
                                                independent_variables, mask)
        jac = N.zeros(n_nz, dtype=c_jmi_real_t)
        
        self.jmimodel.opt_dJ(JMI_DER_CPPAD, JMI_DER_DENSE_ROW_MAJOR,
                             independent_variables, mask, jac)
        return jac.reshape( (1, len(jac)) )


class JMIModel(object):
    
    """A JMI Model loaded from a DLL."""
    
    def __init__(self, libname, path='.'):
        """Contructor."""
                
        # detect platform specific shared library file extension
        suffix = ''
        if sys.platform == 'win32':
            suffix = '.dll'
        elif sys.platform == 'darwin':
            suffix = '.dylib'
        else:
            suffix = '.so'

        # create temp dll
        fhandle,self._tempfname = tempfile.mkstemp(suffix=suffix)
        shutil.copyfile(path+os.sep+libname+suffix,self._tempfname)
        os.close(fhandle)
        fname = self._tempfname.split(os.sep)
        fname = fname[len(fname)-1]
        
        #load temp dll
        self._dll = load_DLL(fname,tempfile.gettempdir())

        # save dll file name so that it can be deleted when python
        # exits if not before
        _temp_dlls.append({'handle':self._dll._handle,'name':self._tempfname})

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

        #self.initAD()
        self._platform=sys.platform
                 
    def initAD(self):
        """Initializing Algorithmic Differential package.
        
        Raises a JMIException on failure.
        
        """
        if self._dll.jmi_ad_init(self._jmi) is not 0:
            raise JMIException("Could not initialize AD.")
               
    def __del__(self):
        """DLL load cleanup function.
        
        Freeing jmi data structure. Removing handle and deleting temporary DLL
        file if possible.
        
        """
        import sys
        
        if self._platform == 'win32':
            pass
        else:
            try:
                assert self._dll.jmi_delete(self._jmi) == 0, \
                       "jmi_delete failed"
                if os.path.exists(self._tempfname) and os.path.isfile(self._tempfname):
                    if sys.platform == 'win32':
                        _ctypes.FreeLibrary(self._dll._handle)
                    os.remove(self._tempfname)
            except AttributeError:
                # Error caused if constructor crashes
                pass
               
    def get_sizes(self, n_ci, n_cd, n_pi, n_pd, n_dx, n_x, n_u, n_w, n_tp, n_z):
        """Get the sizes of the variable vectors."""
        
        retval = self._dll.jmi_get_sizes(self._jmi,
                                 byref(n_ci),
                                 byref(n_cd),
                                 byref(n_pi),
                                 byref(n_pd),
                                 byref(n_dx),
                                 byref(n_x),
                                 byref(n_u),
                                 byref(n_w),
                                 byref(n_tp),
                                 byref(n_z))
        if retval is not 0:
            raise JMIException("Getting sizes failed.")                     
            
    def get_offsets(self, offs_ci, offs_cd, offs_pi, offs_pd, offs_dx, offs_x, offs_u, offs_w,
                    offs_t, offs_dx_p, offs_x_p, offs_u_p, offs_w_p):
        """Get the offsets for the variable types in the z vector."""
        
        retval = self._dll.jmi_get_offsets(self._jmi,
                                         byref(offs_ci),
                                         byref(offs_cd),
                                         byref(offs_pi),
                                         byref(offs_pd),
                                         byref(offs_dx),
                                         byref(offs_x),
                                         byref(offs_u),
                                         byref(offs_w),
                                         byref(offs_t),
                                         byref(offs_dx_p),
                                         byref(offs_x_p),
                                         byref(offs_u_p),
                                         byref(offs_w_p))
        if retval is not 0:
            raise JMIException("Getting offsets failed.")        
            
    def get_n_tp(self,n_tp):
        """Get and return the number of time points in the model."""
        
        retval = self._dll.jmi_get_n_tp(self._jmi, byref(n_tp))
        if retval is not 0:
            raise JMIException("Getting number of time points in the model failed.")

    def set_tp(self, tp):
        """Set the vector of time points. 
        
        Todo:
            Assert correct vector length.
        """
        if self._dll.jmi_set_tp(self._jmi, tp) is not 0:
            raise JMIException("Setting vector of time points failed.")
        
    def get_tp(self, tp):
        """Get and return the vector of time points."""
        if self._dll.jmi_get_tp(self._jmi, tp) is not 0:
            raise JMIException("Getting vector of time points failed.")
    
    def get_z(self):
        """Returns a reference to the vector containing all parameters,
        variables and point-wise evalutated variables vector.
        """
        return self._z
    
    def get_ci(self):
        """Returns a reference to the independent constants vector."""
        return self._ci
    
    def get_cd(self):
        """Returns a reference to the dependent constants vector."""
        return self._cd
    
    def get_pi(self):
        """Returns a reference to the independent parameters vector."""
        return self._pi
        
    def get_pd(self):
        """Returns a reference to the dependent parameters vector."""
        return self._pd

    def get_dx(self):
        """Returns a reference to the derivatives vector."""
        return self._dx 
    
    def get_x(self):
        """Return a reference to the differentiated variables vector."""
        return self._x
        
    def get_u(self):
        """Returns a reference to the inputs vector."""
        return self._u
        
    def get_w(self):
        """Returns a reference to the algebraic variables vector."""
        return self._w

    def get_t(self):
        """Returns a reference to the time value.
        
        The return value is a NumPy array of length 1.
        """
        return self._t

    def get_dx_p(self, i):
        """Returns a reference to the derivatives variables vector
        corresponding to the i:th time point.
        """
        return self._dll.jmi_get_dx_p(self._jmi,i)

    def get_x_p(self, i):
        """Returns a reference to the differentiated variables vector
        corresponding to the i:th time point.
        
        """
        return self._dll.jmi_get_x_p(self._jmi, i)

    def get_u_p(self, i):
        """Returns a reference to the inputs vector corresponding to the i:th time 
        point.
        """
        return self._dll.jmi_get_u_p(self._jmi, i)

    def get_w_p(self, i):
        """Returns a reference to the algebraic variables vector corresponding to 
        the i:th time point.
        """
        return self._dll.jmi_get_w_p(self._jmi, i) 
    
    def ode_f(self):
        """Evalutates the right hand side of the ODE.
        
        The results is saved to the internal states and can be accessed by
        accessing 'my_model.x'.
        
        """
        if self._dll.jmi_ode_f(self._jmi) is not 0:
            raise JMIException("Evaluating ODE failed.")
        
    def ode_df(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluates the Jacobian of the right hand side of the ODE.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be
                evaluated (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_ode_df(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluation of Jacobian failed.")
    
    def ode_df_n_nz(self, eval_alg):
        """Get the number of non-zeros in the Jacobian of the right hand side
        of the ODE.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero Jacobian entries.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_ode_df_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting number of non-zeros failed.")
        return int(n_nz.value)
    
    def ode_df_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the 
        Jacobian of the right hand side of the ODE.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_ode_df_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting row and column indices failed.")
    
    def ode_df_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Return the number of columns and non-zero elements in the Jacobian
        of the right hand side of the ODE.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
       
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.
            
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        df_n_cols = ct.c_int()
        df_n_nz = ct.c_int()
        if self._dll.jmi_ode_df_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(df_n_cols), byref(df_n_nz)) is not 0:
            raise JMIException("Getting number of columns and non-zero elements failed.")        
        return int(df_n_cols.value), int(df_n_nz.value)
    
    def dae_get_sizes(self):
        """Returns the number of equations of the DAE."""
        n_eq_F = ct.c_int()
        n_eq_R = ct.c_int()
        if self._dll.jmi_dae_get_sizes(self._jmi, byref(n_eq_F), byref(n_eq_R)) is not 0:
            raise JMIException("Getting number of equations failed.")
        return n_eq_F.value, n_eq_R.value
    
    def dae_F(self, res):
        """Evaluates the DAE residual.
        
        Parameters:
            res -- DAE residual vector. (Return)
            
        """
        if self._dll.jmi_dae_F(self._jmi, res) is not 0:
            raise JMIException("Evaluating the DAE residual failed.")

    def dae_dF(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluate the Jacobian of the DAE residual function.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_dae_dF(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def dae_dF_n_nz(self, eval_alg):
        """Get the number of non-zeros in the full DAE residual Jacobian.

        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero Jacobian entries.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_dae_dF_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
    
    def dae_dF_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Returns the row and column indices of the non-zero elements in the
        DAE residual Jacobian.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the DAE residual Jacobian.
                (Return)
            col --
                Column indices of the non-zeros in the DAE residual Jacobian.
                (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_dae_dF_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def dae_dF_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Get the number of columns and non-zero elements in the Jacobian of 
        the DAE residual.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.
            
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_dae_dF_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Returning the number of columns and non-zero elements failed.")        
        return int(dF_n_cols.value), int(dF_n_nz.value)

    def dae_R(self, res):
        """Evaluates the DAE event indicators.
        
        Parameters:
            res -- DAE residual vector. (Return)
            
        """
        if self._dll.jmi_dae_R(self._jmi, res) is not 0:
            raise JMIException("Evaluating DAE event indicators.")
        
    def init_get_sizes(self):
        """Gets the number of equations in the DAE initialization functions.
        
        Returns:
            The number of equations in F0, F1 and Fp resp.
            
        """
        n_eq_f0 = ct.c_int()
        n_eq_f1 = ct.c_int()
        n_eq_fp = ct.c_int()
        n_eq_r0 = ct.c_int()
        if self._dll.jmi_init_get_sizes(self._jmi, byref(n_eq_f0), byref(n_eq_f1), byref(n_eq_fp), byref(n_eq_r0)) is not 0:
            raise JMIException("Getting the number of equations failed.")
        return n_eq_f0.value, n_eq_f1.value, n_eq_fp.value, n_eq_r0.value
    
    def init_F0(self, res):
        """Evaluates the F0 residual function of the initialization system.
        
        Parameters:
            res -- The residual of F0.
            
        """
        if self._dll.jmi_init_F0(self._jmi, res) is not 0:
            raise JMIException("Evaluating the F0 residual function failed.")
        
    def init_dF0(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluates the Jacobian of the DAE initialization residual function
        F0.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be
                evaluated (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)
                 
        """
        
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_init_dF0(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def init_dF0_n_nz(self, eval_alg):
        """Get the number of non-zeros in the full Jacobian of the DAE 
        initialization residual function F0.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero Jacobian entries in the full Jacobian.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_init_dF0_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
    
    def init_dF0_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the
        Jacobian of the DAE initialization residual function F0.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass       
        if self._dll.jmi_init_dF0_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def init_dF0_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Get the number of columns and non-zero elements in the Jacobian of
        the DAE initialization residual function F0.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.

        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.
            
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        dF0_n_cols = ct.c_int()
        dF0_n_nz = ct.c_int()
        if self._dll.jmi_init_dF0_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF0_n_cols), byref(dF0_n_nz)) is not 0:
            raise JMIException("Returning the number of columns and non-zero elements failed.")             
        return int(dF0_n_cols.value), int(dF0_n_nz.value)

    def init_F1(self, res):
        """Evaluates the F1 residual function of the initialization system.
        
        Parameters:
            res -- The residual of F1.
            
        """
        if self._dll.jmi_init_F1(self._jmi, res) is not 0:
            raise JMIException("Evaluating the F1 residual function failed.")            
        
    def init_dF1(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluates the Jacobian of the DAE initialization residual function
        F1.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)    
                
        """
        
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_init_dF1(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def init_dF1_n_nz(self, eval_alg):
        """Get the number of non-zeros in the full Jacobian of the DAE 
        initialization residual function F1.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero Jacobian entries in the full Jacobian.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_init_dF1_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
    
    def init_dF1_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the
        Jacobian of the DAE initialization residual function F1.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        if self._dll.jmi_init_dF1_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def init_dF1_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Get the number of columns and non-zero elements in the Jacobian of
        the DAE initialization residual function F1.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.

        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.
            
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        dF1_n_cols = ct.c_int()
        dF1_n_nz = ct.c_int()
        if self._dll.jmi_init_dF1_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF1_n_cols), byref(dF1_n_nz)) is not 0:
            raise JMIException("Getting the number of columns and non-zero elements failed.")        
        return int(dF1_n_cols.value), int(dF1_n_nz.value)
 
    def init_Fp(self, res):
        """Evaluates the Fp residual function of the initialization system.
        
        Parameters:
            res -- The residual of Fp.
            
        """
        if self._dll.jmi_init_Fp(self._jmi, res) is not 0:
            raise JMIException("Evaluating the Fp residual function failed.")
        
    def init_dFp(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluates the Jacobian of the DAE initialization residual function
        F1.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        if self._dll.jmi_init_dFp(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian failed.")
    
    def init_dFp_n_nz(self, eval_alg):
        """Get the number of non-zeros in the full Jacobian of the DAE 
        initialization residual function Fp.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero Jacobian entries in the full Jacobian.
            
        """
        n_nz = ct.c_int()
        if self._dll.jmi_init_dFp_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
    
    def init_dFp_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the Jacobian 
        of the DAE initialization residual function Fp.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)
                
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_init_dFp_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, cols) is not 0:
            raise JMIException("Getting the row and column indices failed.")
    
    def init_dFp_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Get the number of columns and non-zero elements in the Jacobian of
        the DAE initialization residual function Fp.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.
            
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        dFp_n_cols = ct.c_int()
        dFp_n_nz = ct.c_int()
        if self._dll.jmi_init_dFp_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dF_n_cols), byref(dF_n_nz)) is not 0:
            raise JMIException("Getting the number of columns and non-zero elements failed.")        
        return int(dFp_n_cols.value), int(dFp_n_nz.value)

    def init_R0(self, res):
        """Evaluates the DAE initialization event indicators.
        
        Parameters:
            res -- DAE residual vector. (Return)
            
        """
        if self._dll.jmi_init_R0(self._jmi, res) is not 0:
            raise JMIException("Evaluating the DAE initialization event indicators.")
    
    def opt_set_optimization_interval(self, start_time, start_time_free, final_time, final_time_free):
        """Set the optimization interval.
        
        Parameters:
            start_time -- Start time of optimization interval.
            start_time_free -- 0 if start time should be fixed or 1 if free.
            final_time -- Final time of optimization interval.
            final_time_free -- 0 if final time should be fixed or 1 if free.
            
        """
        if self._dll.jmi_opt_set_optimization_interval(self._jmi, start_time, start_time_free, final_time, final_time_free) is not 0:
            raise JMIException("Setting the optimization interval failed.")
        
    def opt_get_optimization_interval(self):
        """Gets the optimization interval.
        
        Returns:
            Tuple with: start time of optimization interval, 0 if start time is 
            fixed and 1 if free, final time of optimization interval, 0 if final 
            time is fixed and 1 if free respectively. 
            
        """
        start_time = ct.c_double()
        start_time_free = ct.c_int()
        final_time = ct.c_double()
        final_time_free = ct.c_int()
        if self._dll.jmi_opt_get_optimization_interval(self._jmi, byref(start_time), byref(start_time_free), byref(final_time), byref(final_time_free)) is not 0:
            raise JMIException("Getting the optimization interval failed.")
        return start_time.value, start_time_free.value, final_time.value, final_time_free.value
        
    def opt_set_p_opt_indices(self, n_p_opt, p_opt_indices):
        """ 
        Specify optimization parameters for the model.
        
        Parameters:
            n_p_opt -- Number of parameters to be optimized.
            p_opt_indices -- Indices of parameters to be optimized in pi vector.
             
        """
        if self._dll.jmi_opt_set_p_opt_indices(self._jmi, n_p_opt, p_opt_indices) is not 0:
            raise JMIException("Specifing optimization parameters failed.")
        
    def opt_get_n_p_opt(self):
        """Return the number of optimization parameters."""
        n_p_opt = ct.c_int()
        if self._dll.jmi_opt_get_n_p_opt(self._jmi, byref(n_p_opt)) is not 0:
            raise JMIException("Getting the number of optimization parameters failed.")
        return int(n_p_opt.value)
        
    def opt_get_p_opt_indices(self, p_opt_indices):
        """Get the optimization parameter indices.
        
        Parameters:    
            p_opt_indices -- Indices of parameters to be optimized. (Return)
        
        """
        if self._dll.jmi_opt_get_p_opt_indices(self._jmi, p_opt_indices) is not 0:
            raise JMIException("Getting the optimization parameters failed.")
        
    def opt_get_sizes(self):
        """Get the sizes of the optimization functions.
        
        Returns:
            Tuple with number of equations in the Ceq, Cineq, Heq and Hineq 
            residual respectively. 
        
        """
        n_eq_Ceq = ct.c_int()
        n_eq_Cineq = ct.c_int()
        n_eq_Heq = ct.c_int()
        n_eq_Hineq = ct.c_int()
        if self._dll.jmi_opt_get_sizes(self._jmi, byref(n_eq_Ceq), byref(n_eq_Cineq), byref(n_eq_Heq), byref(n_eq_Hineq)) is not 0:
            raise JMIException("Getting the sizes of the optimization functions failed.")
        return n_eq_Ceq.value, n_eq_Cineq.value, n_eq_Heq.value, n_eq_Hineq.value
        
    def opt_J(self):
        """Evaluate the cost function J."""
        J = N.zeros(1, dtype=c_jmi_real_t)
        if self._dll.jmi_opt_J(self._jmi, J) is not 0:
            raise JMIException("Evaluation of J failed.")
        return J[0]
        
    def opt_dJ(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluate the gradient of the cost function.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The gradient. (Return)
                
        """
        
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dJ(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluation of the gradient of the cost function failed.")
        
    def opt_dJ_n_nz(self, eval_alg):
        """Get the number of non-zeros in the gradient of the cost function J.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero entries in the full gradient.
        
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dJ_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
        
    def opt_dJ_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the gradient 
        of the cost function J.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the gradient. (Return)
            col --
                Column indices of the non-zeros in the gradient. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dJ_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")        
        
    def opt_dJ_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Compute the number of columns and non-zero elements in the gradient
        of the cost function.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.

        """
        
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        dJ_n_cols = ct.c_int()
        dJ_n_nz = ct.c_int()
        if self._dll.jmi_opt_dJ_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dJ_n_cols), byref(dJ_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return int(dJ_n_cols.value), int(dJ_n_nz.value)
        
    def opt_Ceq(self, res):
        """Evaluate the residual of the equality path constraint Ceq.
        
        Parameters:
            res -- The residual.
        
        """
        if self._dll.jmi_opt_Ceq(self._jmi, res) is not 0:
            raise JMIException("Evaluation of the residual of the equality path constraint Ceq failed.")
        
    def opt_dCeq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluate the Jacobian of the equality path constraint Ceq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)
        
        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        if self._dll.jmi_opt_dCeq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluation of the Jacobian of the equality path constraint Ceq failed.")
        
    def opt_dCeq_n_nz(self, eval_alg):
        """Get the number of non-zeros in the full Jacobian of the equality path 
        constraint Ceq.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero entries in the full Jacobian.
        
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dCeq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
        
    def opt_dCeq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the Jacobian 
        of the equality path constraint residual Ceq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dCeq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dCeq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Compute the number of columns and non-zero elements in the Jacobian of 
        the equality path constraint residual function Ceq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        dCeq_n_cols = ct.c_int()
        dCeq_n_nz = ct.c_int()
        if self._dll.jmi_opt_dCeq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dCeq_n_cols), byref(dCeq_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return int(dCeq_n_cols.value), int(dCeq_n_nz.value)
        
    def opt_Cineq(self, res):
        """Evaluate the residual of the inequality path constraint Cineq.
        
        Parameters:
            res -- The residual.        
        
        """
        if self._dll.jmi_opt_Cineq(self._jmi, res) is not 0:
            raise JMIException("Evaluating the residual of the inequality path constraint Cineq failed.")
        
    def opt_dCineq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluate the Jacobian of the inequality path constraint Cineq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)

        """
        
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        if self._dll.jmi_opt_dCineq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian of the inequality path constraint Cineq failed.")
        
    def opt_dCineq_n_nz(self, eval_alg):
        """Get the number of non-zeros in the full Jacobian of the inequality path 
        constraint Cineq.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero entries in the full Jacobian.
                    
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dCineq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
        
    def opt_dCineq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """Get the row and column indices of the non-zero elements in the Jacobian 
        of the inequality path constraint residual Cineq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (JMI_DER_DX or JMI_DER_X).
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dCineq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dCineq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """Compute the number of columns and non-zero elements in the Jacobian of 
        the inequality path constraint residual function Cineq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        dCineq_n_cols = ct.c_int()
        dCineq_n_nz = ct.c_int()
        if self._dll.jmi_opt_dCineq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dCineq_n_cols), byref(dCineq_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return int(dCineq_n_cols.value), int(dCineq_n_nz.value)

    def opt_Heq(self, res):
        """Evaluate the residual of the equality point constraint Heq.
        
        Parameters:
            res -- The residual.        
        
        """
        if self._dll.jmi_opt_Heq(self._jmi, res) is not 0:
            raise JMIException("Evaluating the residual of the equality point constraint Heq failed.")
        
    def opt_dHeq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """Evaluate the Jacobian of the equality point constraint Heq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dHeq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian of the equality point constraint Heq failed.")
        
    def opt_dHeq_n_nz(self, eval_alg):
        """ 
        Get the number of non-zeros in the full Jacobian of the equality point 
        constraint Heq.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero entries in the full Jacobian.
                    
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dHeq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
        
    def opt_dHeq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ 
        Get the row and column indices of the non-zero elements in the Jacobian 
        of the equality point constraint residual Heq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dHeq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dHeq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ 
        Compute the number of columns and non-zero elements in the Jacobian of 
        the equality point constraint residual function Heq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        dHeq_n_cols = ct.c_int()
        dHeq_n_nz = ct.c_int()
        if self._dll.jmi_opt_dHeq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dHeq_n_cols), byref(dHeq_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return int(dHeq_n_cols.value), int(dHeq_n_nz.value)

    def opt_Hineq(self, res):
        """ 
        Evaluate the residual of the inequality point constraint Hineq.
        
        Parameters:
            res -- The residual.        
        
        """
        if self._dll.jmi_opt_Hineq(self._jmi, res) is not 0:
            raise JMIException("Evaluating the residual of the inequality point constraint Hineq failed.")
        
    def opt_dHineq(self, eval_alg, sparsity, independent_vars, mask, jac):
        """ 
        Evaluate the Jacobian of the inequality point constraint Hineq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            jac --
                The Jacobian. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass        
        if self._dll.jmi_opt_dHineq(self._jmi, eval_alg, sparsity, independent_vars, mask, jac) is not 0:
            raise JMIException("Evaluating the Jacobian of the inequality point constraint Hineq failed.")
        
    def opt_dHineq_n_nz(self, eval_alg):
        """ 
        Get the number of non-zeros in the full Jacobian of the inequality point 
        constraint Hineq.
        
        Parameters:
            eval_alg --
                For which Jacobian the number of non-zero elements should be 
                returned: Symbolic (JMI_DER_SYMBOLIC) or CppAD (JMI_DER_CPPAD).
                
        Returns:
            The number of non-zero entries in the full Jacobian.
                    
        """
        n_nz = ct.c_int()
        if self._dll.jmi_opt_dHineq_n_nz(self._jmi, eval_alg, byref(n_nz)) is not 0:
            raise JMIException("Getting the number of non-zeros failed.")
        return int(n_nz.value)
        
    def opt_dHineq_nz_indices(self, eval_alg, independent_vars, mask, row, col):
        """ 
        Get the row and column indices of the non-zero elements in the Jacobian 
        of the inequality point constraint residual Hineq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
            row --
                Row indices of the non-zeros in the Jacobian. (Return)
            col --
                Column indices of the non-zeros in the Jacobian. (Return)

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        if self._dll.jmi_opt_dHineq_nz_indices(self._jmi, eval_alg, independent_vars, mask, row, col) is not 0:
            raise JMIException("Getting the row and column indices failed.")
        
    def opt_dHineq_dim(self, eval_alg, sparsity, independent_vars, mask):
        """ 
        Compute the number of columns and non-zero elements in the Jacobian of 
        the inequality point constraint residual function Hineq.
        
        Parameters:
            eval_alg -- 
                JMI_DER_SYMBOLIC to evaluate a symbolic Jacobian or 
                JMI_DER_CPPAD to evaluate the Jacobian by means of CppAD.
            sparsity --
               Output format of the Jacobian. Use JMI_DER_SPARSE, 
               JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
            independent_vars -- 
                Indicates which columns of the full Jacobian should be evaluated 
                (for example JMI_DER_DX or JMI_DER_X).
                
                Can either be a list of columns or a bitmask of the columns
                or:ed (|) together. Using a list is more prefered as it is more
                Pythonesque.
            mask --
                Vector containing ones for the Jacobian columns that should be 
                included in the Jacobian and zeros for those which should not.
        
        Returns:
            Tuple with number of columns and non-zeros resp. of the resulting 
            Jacobian.

        """
        try:
            independent_vars = reduce(lambda x,y: x | y, independent_vars)
        except TypeError:
            pass
        
        dF_n_cols = ct.c_int()
        dF_n_nz = ct.c_int()
        if self._dll.jmi_opt_dHineq_dim(self._jmi, eval_alg, sparsity, independent_vars, mask, byref(dHineq_n_cols), byref(dHineq_n_nz)) is not 0:
            raise JMIException("Computing the number of columns and non-zero elements failed.")
        return int(dHineq_n_cols.value), int(dHineq_n_nz.value)
    
