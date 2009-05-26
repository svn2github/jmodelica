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
    
    dll.jmi_set_tp.argtypes = [ct.c_void_p,
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             shape=n_tp.value,
                                             flags='C')]
    
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
    dx_p_1 = dll.jmi_get_dx_p(jmi, 0);
    x_p_1  = dll.jmi_get_x_p(jmi, 0);
    u_p_1  = dll.jmi_get_u_p(jmi, 0);
    w_p_1  = dll.jmi_get_w_p(jmi, 0);
    dx_p_2 = dll.jmi_get_dx_p(jmi, 1);
    x_p_2  = dll.jmi_get_x_p(jmi, 1);
    u_p_2  = dll.jmi_get_u_p(jmi, 1);
    w_p_2  = dll.jmi_get_w_p(jmi, 1);
    z      = dll.jmi_get_z(jmi)
    
    # Setting parameter types
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
                                             flags='C'),
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]
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
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]

    dll.jmi_init_dF0_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
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
                                               flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]

    dll.jmi_init_dF1_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
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
                                 Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
                                                flags='C'),
                                 Nct.ndpointer(dtype=c_jmi_real_t,
                                               ndim=1,
                                               flags='C')]

    dll.jmi_init_dFp_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(
                                                dtype=ct.c_int,
                                                ndim=1,
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
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]

    dll.jmi_ode_f.argtypes  = [ct.c_void_p]
    dll.jmi_ode_df.argtypes = [ct.c_void_p,
                               ct.c_int,
                               ct.c_int,
                               ct.c_int,
                               Nct.ndpointer(dtype=ct.c_int,
                                             ndim=1,
                                             flags='C'),
                               Nct.ndpointer(dtype=c_jmi_real_t,
                                             ndim=1,
                                             flags='C')]

    dll.jmi_ode_df_nz_indices.argtypes = [ct.c_void_p,
                                          ct.c_int,
                                          ct.c_int,
                                          Nct.ndpointer(dtype=ct.c_int,
                                                        ndim=1,
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
                                                 flags='C'),
                                   ct.POINTER(ct.c_int),
                                   ct.POINTER(ct.c_int)]
                                       
    dll.jmi_get_cd.argtypes   = [ct.c_void_p]
    dll.jmi_get_ci.argtypes   = [ct.c_void_p]
    dll.jmi_get_dx.argtypes   = [ct.c_void_p]
    dll.jmi_get_dx_p.argtypes = [ct.c_void_p, ct.c_int]
    dll.jmi_get_pd.argtypes   = [ct.c_void_p]
    dll.jmi_get_pi.argtypes   = [ct.c_void_p]
    dll.jmi_get_t.argtypes    = [ct.c_void_p]
    dll.jmi_get_u.argtypes    = [ct.c_void_p]
    dll.jmi_get_u_p.argtypes  = [ct.c_void_p, ct.c_int]
    dll.jmi_get_w.argtypes    = [ct.c_void_p]
    dll.jmi_get_w_p.argtypes  = [ct.c_void_p, ct.c_int]
    dll.jmi_get_x.argtypes    = [ct.c_void_p]
    dll.jmi_get_x_p.argtypes  = [ct.c_void_p, ct.c_int]
    dll.jmi_get_z.argtypes    = [ct.c_void_p]
    
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

        # set start attributes
        xml_variables_name=libname+'_variables.xml' 
        # assumes libname is name of model and xmlfile is located in the same dir as the dll
        self._set_XMLvariables_doc(xmlparser.XMLVariablesDoc(path+os.sep+xml_variables_name))
        self._set_start_attributes()
        
        # set independent parameter values
        xml_values_name = libname+'_values.xml'
        self._set_XMLvalues_doc(xmlparser.XMLValuesDoc(path+os.sep+xml_values_name))
        self._set_iparam_values()
        
        self.initAD()
                
    def __del__(self):
        """Freeing jmi data structure.
        """
        assert self._dll.jmi_delete(self._jmi) == 0, \
               "jmi_delete failed"
        
    def initAD(self):
        """Initializing Algorithmic Differential package.
        
        Raises a JMIException on failure.
        """
        if self._dll.jmi_ad_init(self._jmi) is not 0:
            raise JMIException("Could not initialize AD.")

    def getX(self):
        """ Gets a reference to the differentiated variables vector.
        """
        return self._x
        
    def setX(self, x):
        """ Sets the differentiated variables vector.
        """
        raise JMIException("X can only be modified, not set.")
        
    x = property(getX, setX, "The differentiated variables vector.")

    def getX_P(self, i):
        """ Gets a reference to the differentiated variables vector corresponding to 
            the i:th time point.
        """
        return self._dll.jmi_get_x_p(self._jmi, i)
        
    def setX_P(self, x_p, i):
        """ Sets the differentiated variables vector corresponding to the i:th time point.
        """

        raise JMIException("X_P can only be modified, not set.")
        
    x_p = property(getX_P, setX_P, "The differentiated variables corresponding to the i:th time point.")
    
    def getPI(self):
        """ Gets a reference to the independent parameters vector.
        """
        return self._pi
        
    def setPI(self, pi):
        """ Sets the independent parameters vector.
        """
        raise JMIException("PI can only be modified, not set.")
        
    pi = property(getPI, setPI, "The independent parameter vector.")

    def getCD(self):
        """ Gets a reference to the dependent constants vector.
        """
        return self._cd
        
    def setCD(self, cd):
        """ Sets the dependent constants vector.
        """

        raise JMIException("CD can only be modified, not set.")
        
    cd = property(getCD, setCD, "The dependent constants vector.")

    def getCI(self):
        """ Gets a reference to the independent constants vector.
        """
        return self._ci
        
    def setCI(self, ci):
        """ Sets the independent constants vector.
        """

        raise JMIException("CI can only be modified, not set.")
        
    ci = property(getCI, setCI, "The independent constants vector.")

    def getDX(self):
        """ Gets a reference to the derivatives vector.
        """
        return self._dx
        
    def setDX(self, dx):
        """ Sets the derivatives vector.
        """
        raise JMIException("DX can only be modified, not set.")
        
    dx = property(getDX, setDX, "The derivatives vector.")

    def getDX_P(self, i):
        """ Gets a reference to the derivatives variables vector corresponding to 
            the i:th time point.  
        """
        return self._dll.jmi_get_dx_p(self._jmi,i)
        
    def setDX_P(self, dx_p, i):
        """ Sets the derivatives variables vector corresponding to the i:th time point.  
        """
        raise JMIException("DX_P can only be modified, not set.")
        
    dx_p = property(getDX_P, setDX_P, "The derivatives corresponding to the i:th time point.")

    def getPD(self):
        """ Gets a reference to the dependent parameters vector.
        """
        return self._pd
        
    def setPD(self, pd):
        """ Sets the dependent parameters vector.
        """
        raise JMIException("PD can only be modified, not set.")
        
    pd = property(getPD, setPD, "The dependent paramenters vector.")

    def getU(self):
        """ Gets a reference to the inputs vector.
        """
        return self._u
        
    def setU(self, u):
        """ Sets the inputs vector.
        """
        raise JMIException("U can only be modified, not set.")
        
    u = property(getU, setU, "The inputs vector.")

    def getU_P(self, i):
        """ Gets a reference to the inputs vector corresponding to the i:th time point.
        """
        return self._dll.jmi_get_u_p(self._jmi, i)
        
    def setU_P(self, u_p, i):
        """ Sets the inputs vector corresponding to the i:th time point.
        """
        raise JMIException("U_P can only be modified, not set.")
        
    u_p = property(getU_P, setU_P, "The inputs corresponding to the i:th time point.")

    def getW(self):
        """ Gets a reference to the algebraic variables vector.
        """
        return self._w
        
    def setW(self, w):
        """ Sets the algebraic variables vector.
        """
        raise JMIException("W can only be modified, not set.")
        
    w = property(getW, setW, "The algebraic variables vector.")

    def getW_P(self, i):
        """ Gets a reference to the algebraic variables vector corresponding to 
            the i:th time point.
        """
        return self._dll.jmi_get_w_p(self._jmi, i)
        
    def setW_P(self, w_p, i):
        """ Sets the algebraic variables vector corresponding to the i:th time point.
        """
        raise JMIException("W_P can only be modified, not set.")
        
    w_p = property(getW_P, setW_P, "The algebraic variables corresponding to the i:th time point.")

    def getT(self):
        """ Gets a reference to the time value.
        """
        return self._t
        
    def setT(self, t):
        """ Sets the time value.
        """
        raise JMIException("T can only be modified, not set.")
        
    t = property(getT, setT, "The time value.")
    
    def getZ(self):
        """ Gets a reference to the vector containing all parameters, variables and point-wise 
            evalutated variables vector.
        """
        return self._z
        
    def setZ(self, z):
        """ Sets the vector containing all parameters, variables and point-wise 
            evalutated variables vector.
        """
        raise JMIException("Z can only be modified, not set.")
        
    z = property(getZ, setZ, "All parameters, variables and point-wise evaluated variables vector.")
    
    def _get_XMLvariables_doc(self):
        """ Gets a reference to the XMLDoc instance for model variables set for this JMIModel.
        """
        return self._xmlvariables_doc
    
    def _set_XMLvariables_doc(self, doc):
        """ Sets the XMLDoc for model variables for this JMIModel.
        """
        self._xmlvariables_doc = doc

    def _get_XMLvalues_doc(self):
        """ Gets a reference to the XMLDoc instance for independent parameter values set for this JMIModel.
        """
        return self._xmlvalues_doc
    
    def _set_XMLvalues_doc(self, doc):
        """ Sets the XMLDoc for independent parameter values for this JMIModel.
        """
        self._xmlvalues_doc = doc
        
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
        keys.sort()
        
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
        keys.sort()
       
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
        
        
        
        
        
        
