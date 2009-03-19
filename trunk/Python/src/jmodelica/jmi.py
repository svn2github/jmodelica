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


# ================================================================
#                             CTYPES
# ================================================================
"""Defines the JMI jmi_real_t C-type.

This type is usually a double.

"""
c_jmi_real_t = ct.c_double


# ================================================================
#                           FUNCTIONS
# ================================================================
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
           
    # Setting return type to ctypes.array for some functions
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
        restype = Nct.ndpointer(dtype=c_jmi_real_t, \
                                ndim=1, \
                                shape=length, \
                                flags='C')
        func.restype = ct.POINTER(c_jmi_real_t)
           
    offs_ci = ct.c_int()
    offs_cd = ct.c_int()
    offs_pi = ct.c_int()
    offs_pd = ct.c_int()
    offs_dx = ct.c_int()
    offs_x = ct.c_int()
    offs_u = ct.c_int()
    offs_w = ct.c_int()
    offs_t = ct.c_int()
    offs_dx_p = ct.c_int()
    offs_x_p = ct.c_int()
    offs_u_p = ct.c_int()
    offs_w_p = ct.c_int()
    assert dll.jmi_get_offsets(jmi, \
                               byref(offs_ci), \
                               byref(offs_cd), \
                               byref(offs_pi), \
                               byref(offs_pd), \
                               byref(offs_dx), \
                               byref(offs_x), \
                               byref(offs_u), \
                               byref(offs_w), \
                               byref(offs_t), \
                               byref(offs_dx_p), \
                               byref(offs_x_p), \
                               byref(offs_u_p), \
                               byref(offs_w_p)) \
           is 0, \
           "getting offsets failed"
    
    n_eq_F = ct.c_int()
    assert dll.jmi_dae_get_sizes(jmi, \
                                 byref(n_eq_F)) \
           is 0, \
           "getting DAE sizes failed"
    
    dF_n_nz = ct.c_int()
    assert dll.jmi_dae_dF_n_nz(jmi, \
                               JMI_DER_SYMBOLIC, \
                               byref(dF_n_nz)) \
           is 0, \
           "getting number of non-zeros in the full DAE residual " \
           + "Jacobian failed"
    dF_row = (dF_n_nz.value * ct.c_int)()
    dF_col = (dF_n_nz.value * ct.c_int)()
    
    dJ_n_nz = ct.c_int()
    assert dll.jmi_opt_dJ_n_nz(jmi, \
                               JMI_DER_SYMBOLIC, \
                               byref(dJ_n_nz)) \
           is 0, \
           "getting number of non-zeros in the gradient of the " \
           + "cost function failed"
    dJ_row = (dJ_n_nz.value * ct.c_int)()
    dJ_col = (dJ_n_nz.value * ct.c_int)()
    
    dJ_n_dense = ct.c_int(n_z.value);
    
    dF_n_dense = ct.c_int(n_z.value \
                               * n_eq_F.value)
    
    J = c_jmi_real_t();
    
    #static jmi_opt_sim_t *jmi_opt_sim;
    #static jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;
    jmi_opt_sim = ct.c_void_p()
    jmi_opt_sim_ipopt = ct.c_void_p()
    
    res_F = (n_eq_F.value * c_jmi_real_t)()
    dF_sparse = (dF_n_nz.value * c_jmi_real_t)()
    dF_dense = (dF_n_dense.value * c_jmi_real_t)()
    
    dJ_sparse = (dJ_n_nz.value * c_jmi_real_t)()
    dJ_dense = (dJ_n_dense.value * c_jmi_real_t)()
    
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
    
    res_F = (n_eq_F.value * c_jmi_real_t)()
    dF_sparse = (dF_n_nz.value * c_jmi_real_t)()
    dF_dense = (dF_n_dense.value * c_jmi_real_t)()
    
    dJ_sparse = (dJ_n_nz.value * c_jmi_real_t)()
    dJ_dense = (dJ_n_dense.value * c_jmi_real_t)()
    
    mask = (n_z.value * ct.c_int)()
    
    # Setting parameter types
    dll.jmi_dae_F.argtypes = [ct.c_void_p, \
                              Nct.ndpointer(dtype=c_jmi_real_t, \
                                            ndim=1, \
                                            shape=n_eq_F.value, \
                                            flags='C')]
    dll.jmi_dae_dF_nz_indices.argtypes = [ct.c_void_p, \
                                          ct.c_int, \
                                          ct.c_int, \
                                          Nct.ndpointer(dtype=ct.c_int, \
                                                        ndim=1, \
                                                        shape=n_z.value, \
                                                        flags='C'), \
                                          Nct.ndpointer(dtype=ct.c_int, \
                                                        ndim=1, \
                                                        shape=dF_n_nz.value, \
                                                        flags='C'), \
                                          Nct.ndpointer(dtype=ct.c_int, \
                                                        ndim=1, \
                                                        shape=dF_n_nz.value, \
                                                        flags='C')]
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
#                            CLASSES
# ================================================================
class JMIModel:
    """
    A JMI Model loaded from a DLL.
    
    """
    
    def __init__(self, dll):
        self.dll = dll
