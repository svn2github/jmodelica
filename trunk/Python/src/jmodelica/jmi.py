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

    return N.asarray(d).view( dtype=dtype )


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
    conv_function = _PointerToNDArrayConverter(shape=shape, \
                                               dtype=dtype, \
                                               ndim=ndim, \
                                               order=order)
    
    dll_func.restype = ct.POINTER(dtype)
    dll_func.errcheck = conv_function


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
    n_x = ct.c_int()
    n_u = ct.c_int()
    n_w = ct.c_int()
    n_tp = ct.c_int()
    n_z = ct.c_int()
    assert dll.jmi_get_sizes(jmi, \
                             byref(n_ci), \
                             byref(n_cd), \
                             byref(n_pi), \
                             byref(n_pd), \
                             byref(n_dx), \
                             byref(n_x), \
                             byref(n_u), \
                             byref(n_w), \
                             byref(n_tp), \
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
                     (dll.jmi_get_t, n_tp.value),
                     (dll.jmi_get_dx_p, n_dx.value),
                     (dll.jmi_get_x_p, n_x.value),
                     (dll.jmi_get_u_p, n_u.value),
                     (dll.jmi_get_w_p, n_w.value)]
    for (func, length) in int_res_funcs:
        _returns_ndarray(func, c_jmi_real_t, length, order='C')
    
    n_eq_F = ct.c_int()
    assert dll.jmi_dae_get_sizes(jmi, \
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
    
    dF_n_dense = ct.c_int(n_z.value \
                               * n_eq_F.value)
    
    J = c_jmi_real_t();
    
    #static jmi_opt_sim_t *jmi_opt_sim;
    #static jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;
    jmi_opt_sim = ct.c_void_p()
    jmi_opt_sim_ipopt = ct.c_void_p()
    
    # The return types for these functions are set in jmi.py's
    # function load_DLL(...)
    ci = dll.jmi_get_ci(jmi);
    cd = dll.jmi_get_cd(jmi);
    pi = dll.jmi_get_pi(jmi);
    pd = dll.jmi_get_pd(jmi);
    dx = dll.jmi_get_dx(jmi);
    x = dll.jmi_get_x(jmi);
    u = dll.jmi_get_u(jmi);
    w = dll.jmi_get_w(jmi);
    t = dll.jmi_get_t(jmi);
    dx_p_1 = dll.jmi_get_dx_p(jmi, 0);
    x_p_1 = dll.jmi_get_x_p(jmi, 0);
    u_p_1 = dll.jmi_get_u_p(jmi, 0);
    w_p_1 = dll.jmi_get_w_p(jmi, 0);
    dx_p_2 = dll.jmi_get_dx_p(jmi, 1);
    x_p_2 = dll.jmi_get_x_p(jmi, 1);
    u_p_2 = dll.jmi_get_u_p(jmi, 1);
    w_p_2 = dll.jmi_get_w_p(jmi, 1);
    
    # Setting parameter types
    dll.jmi_dae_F.argtypes = [ct.c_void_p, \
                              Nct.ndpointer(dtype=c_jmi_real_t, \
                                            ndim=1, \
                                            shape=n_eq_F.value, \
                                            flags='C')]
    if dF_n_nz is not None:
        dll.jmi_dae_dF_nz_indices.argtypes = [ct.c_void_p, \
                                              ct.c_int, \
                                              ct.c_int, \
                                              Nct.ndpointer( \
                                                dtype=ct.c_int, \
                                                ndim=1, \
                                                shape=n_z.value, \
                                                flags='C'), \
                                              Nct.ndpointer(
                                                dtype=ct.c_int, \
                                                ndim=1, \
                                                shape=dF_n_nz.value, \
                                                flags='C'), \
                                              Nct.ndpointer(dtype=ct.c_int, \
                                                ndim=1, \
                                                shape=dF_n_nz.value, \
                                                flags='C')]
    else:
        dll.jmi_dae_dF_nz_indices.errcheck = \
                        fail_error_check("Functionality not supported.")
    dll.jmi_dae_dF_dim.argtypes = [ct.c_void_p, ct.c_int, ct.c_int, \
                                   ct.c_int, \
                                   Nct.ndpointer(dtype=ct.c_int, \
                                                 ndim=1, \
                                                 shape=n_z.value, \
                                                 flags='C'), \
                                   ct.POINTER(ct.c_int), \
                                   ct.POINTER(ct.c_int)]
                                          
                                          
                                   
    
    assert dll.jmi_delete(jmi) == 0, \
           "jmi_delete failed"
    
    return dll


def load_model(filepath):
    """Returns a JMI model loaded from file.
    
    @param filepath The absolute or relative path to the model file to
                    be loaded.
    @return 
    
    If the model cannot be loaded a JMIException will be raised.
    
    """
    dll = load_DLL(filepath)
    

# ================================================================
#                        HIGH LEVEL INTERFACE
# ================================================================

class JMIModel(object):
    """
    A JMI Model loaded from a DLL.
    
    @todo:
        Created properties for getters and setters.
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

    def __del__(self):
        """Freeing jmi data structure.
        """
        assert self._dll.jmi_delete(self._jmi) == 0, \
               "jmi_delete failed"
        
    def initAD(self):
        """Inializing Algorithmic Differential package.
        
        Raises a JMIException on failure.
        """
        if self._dll.jmi_ad_init(self._jmi) is not 0:
            raise JMIException("Could not initialize AD.")

    def getX(self):
        return self._x
        
    def setX(self, x):
        raise JMIException("X can only be modified, not set.")
        
    x = property(getX, setX, "The differentiated variables vector.")
    
    def getPI(self):
        return self._pi
        
    def setPI(self, pi):
        raise JMIException("PI can only be modified, not set.")
        
    pi = property(getPI, setPI, "The independent parameter vector.")
