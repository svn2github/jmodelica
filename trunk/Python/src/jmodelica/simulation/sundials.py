#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Multiple shooting.

"""

import ctypes
import math

import numpy as N
import matplotlib
import pylab as p
import nose

try:
    from pysundials import cvodes
    from pysundials import nvecserial
except ImportError:
    import cvodes
    import nvecserial
from openopt import NLP

from jmodelica.simulation import SimulationException

import jmodelica.jmi as pyjmi
from jmodelica.jmi import c_jmi_real_t


class SundialsSimulationException(SimulationException):
    """An exception thrown by the SUNDIALS simulation kit."""
    pass


def solve_using_sundials(model,
                         end_time,
                         start_time=0.0,
                         verbose=False,
                         sensi=False,
                         use_jacobian=False,
                         abstol=1.0e-6, # used to be e-14
                         reltol=1.0e-6,
                         time_step=0.02,
                         return_last=False):
    """Integrate the model model from 0 to end_time.
    
    The model needs to be initialized before calling this function (all states
    needs to be set etc.
    
    The function returns a tuple consisting of:
        1. Time samples. If return_last is True only the last time sample is
           returned.
        2. Corresponding states samples. If return_last is True only the last
           states sample is returned.
        3. Sensitivity matrix. None if sensi==False.
        4. An instance of the PyFData class containing the indices
           for the the sensivity matrix.
    
    See keyword parameter start_time if simulation needs to be conducted
    starting from a different time.
    
    Parameters:
    model -- the model to use. Should be a derived class from OptModel.
    end_time -- the time when the model simulation should end.
    
    Keyword parameters:
    start_time   -- the (optional) time when the model simulation should start.
                    Defaults to 0.0.
    verbose      -- true of verbose output should be printed. Defaults to
                    False.
    sensi        -- true if the built-in sensitivity functionality should be
                    used in SUNDIALS. Defaults to False.
    use_jacobian -- if the jacobian should be used or not. (EXPERIMENTAL!)
    abstol       -- the absolute tolerance. See SUNDIALS' manual for more info.
    reltol       -- the relative tolerance. See SUDNIALS' manual for more info.
    time_step    -- the step size when SUNDIALS should return from it's
                    internal loop. See SUNDIALS' manual for more info.
    return_last  -- see return information.
    
    """
    if verbose:
        print "Input before integration:", model.u
        print "States:", model.x
        print start_time, "to", end_time
    
    import sys
    sys.stdout.flush()
    
    if end_time < start_time:
        raise SundialsSimulationException('End time cannot be before start '
                                          'time.')
    if end_time == start_time:
        raise SundialsSimulationException('End time and start time cannot '
                                          'currently coinside.')
        
    # If this line is not here T[-1] returned will be end_time - time_step
    #end_time = end_time + time_step
    
    def _sundials_f(t, x, dx, f_data):
        """The sundials' RHS evaluation function.
        
        This function basically moves data between SUNDIALS arrays and NumPy
        arrays.
        
        Parameters:
        t      -- the point time on which the evalution is being done.
        x      -- the states.
        dx     -- the derivatives of the states.
        f_data -- contains the model and an array with it's parameters.
        
        See SUNDIALS' manual and/or PySUNDIALS demos for more information.
        """
        data = ctypes.cast(f_data, PUserData).contents
        model = data.model
        model.t = (t - data.t_sim_start) / data.t_sim_duration
        if data.ignore_p == 0:
            p = data.parameters
            sundials_params = p.params
        
        # Copying from sundials space to model space and back again
        if data.ignore_p == 0:
            model.pi = sundials_params[p.pi_start : p.pi_end]
            model.u = sundials_params[p.u_start : p.u_end]
        model.x = x
        model.eval_ode_f()
        dx[:] = model.dx
        
        return 0

    def _Jac(N, J, t, y, fy, jac_data, tmp1, tmp2, tmp3):
        """ Set Jacobian calculated by JMI.
            
            This function is a callback function for (Py)SUNDIALS.
        
        """
        data = ctypes.cast(jac_data, PUserData).contents
        model = data.model
        
        model.t = t
        model.x = y
        J_jmi = model.eval_jac_x()
        
        for row in xrange(len(J_jmi)):
            for col in xrange(len(J_jmi[row])):
                J[row][col] = J_jmi[row][col]
        
        return 0
        
    class UserData(ctypes.Structure):
        """ctypes structure used to move data in (and out of?) the callback
           functions.
        """
        _fields_ = [
            ('parameters', ctypes.py_object), # parameters
            ('model', ctypes.py_object),    # The evaluation model
                                            # (RHS if you will).
            ('ignore_p', ctypes.c_int),     # Whether p should be ignored or
                                            # not used to reduce unnecessary
                                            # copying.
            ('t_sim_start', c_jmi_real_t),  # Start time for simulation.
            ('t_sim_end', c_jmi_real_t),    # End time for simulation.
            ('t_sim_duration', c_jmi_real_t), # Time duration for simulation.
        ]
    PUserData = ctypes.POINTER(UserData) # Pointer type of UserData
    
    # initial y (copying just in case)
    y = cvodes.NVector(model.x.copy())

    # converting tolerances to C types
    abstol = cvodes.realtype(abstol)
    reltol = cvodes.realtype(reltol)

    t0 = cvodes.realtype(start_time)

    cvode_mem = cvodes.CVodeCreate(cvodes.CV_BDF, cvodes.CV_NEWTON)
    cvodes.CVodeMalloc(cvode_mem, _sundials_f, t0, y, cvodes.CV_SS, reltol, 
                       abstol)

    cvodes.CVDense(cvode_mem, len(model.x))

    # Set f_data
    data = UserData()
    data.model = ctypes.py_object(model)
    data.t_sim_start = start_time
    data.t_sim_end   = end_time
    data.t_sim_duration = data.t_sim_end - data.t_sim_start
    if sensi:
        class PyFData(object):
            """The Pythonic FData structure corresponding to the fdata
               structure sent used by SUNDIALS.
            
            An instance of of this structure is referred to by the
            C data structure UserData.
            
            This class can be used to interpret the columns in the
            sensivity matrix.
            
            """
            # Slots is a feature that can be used in new-style Python
            # classes. It basically makes sure that typos are not made
            # (and is also practical for documentational purposes).
            #
            # See:
            # http://www.geocities.com/foetsch/python/new_style_classes.htm
            __slots__ = [
                'params',   # Holds the C type parameter
                            # vector used by SUNDIALS
                            # internal sens. analysis.
                'pi_start', # Start index for where the
                            # independent parameters are
                            # stored in params.
                'pi_end',   # End index for where the
                            # independent parameters are
                            # stored in params.
                'xinit_start',  # Start index for where the
                                # initial values are stored
                                # in params.
                'xinit_end',    # End index for where the
                                # initial values are stored
                                # in params.
                'u_start',  # Start index for where the
                            # optimal control inputs are
                            # stored in params.
                'u_end',    # End index for where the
                            # optimal control inputs are
                            # stored in params.
            ]
        parameters           = PyFData()
        pi_ctype             = cvodes.realtype \
                                * (len(model.pi)
                                    + len(model.x)
                                    + len(model.u))
        parameters.params    = pi_ctype()
        parameters.params[:] = N.concatenate((model.pi,
                                              model.x[:len(model.x)],
                                              model.u,))
        # Indices used by sundials_f(...)
        parameters.pi_start    = 0
        parameters.pi_end      = len(model.pi)
        parameters.xinit_start = parameters.pi_end
        parameters.xinit_end   = parameters.xinit_start + len(model.x)
        parameters.u_start     = parameters.xinit_end
        parameters.u_end       = parameters.u_start + len(model.u)
                                        
        data.parameters  = ctypes.py_object(parameters)
        data.ignore_p = 0
    else:
        data.ignore_p = 1
        parameters = None # Needed for correct return
        
    if use_jacobian:
        raise NotImplementedError('Jacobian cannot be used as of now.')
        cvodes.CVDenseSetJacFn(cvode_mem, _Jac, ctypes.pointer(data))
    cvodes.CVodeSetFdata(cvode_mem, ctypes.pointer(data))
    
    if sensi:
        NP = len(model.pi) # number of model parameters
        NU = len(model.u) # number of control signals/inputs
        NI = len(model.x) # number of initial states from
                                  # which sensitivity is calculated
        NS      = NP + NI + NU # number of sensitivities to be calculated
        NEQ     = len(model.x)
        assert NEQ == NI, "yS must be modified below to handle the" \
                          " inequality NEQ != NI"
        err_con = False # Use sensisitity for error control
        yS      = nvecserial.NVectorArray([[0] * NEQ] * NP
                                            + N.eye(NI).tolist()
                                            + [[0] * NEQ] * NU)
        
        cvodes.CVodeSensMalloc(cvode_mem, NS, cvodes.CV_STAGGERED1, yS)
        cvodes.CVodeSetSensErrCon(cvode_mem, err_con)
        cvodes.CVodeSetSensDQMethod(cvode_mem, cvodes.CV_CENTERED, 0)
        
        model_parameters = model.pi
        cvodes.CVodeSetSensParams(cvode_mem, parameters.params, None, None)
    
    tout = start_time + time_step
    if tout>end_time:
        tout=end_time

    # initial time
    t = cvodes.realtype(t0.value)

    # used for collecting the y's for plotting
    if return_last==False:
        num_samples = int(math.ceil((end_time - start_time) / time_step)) + 1
        T = N.zeros(num_samples, dtype=pyjmi.c_jmi_real_t)
        ylist = N.zeros((num_samples, len(model.x)),
                        dtype=pyjmi.c_jmi_real_t)
        ylist[0] = model.x.copy()
        T[0] = t0.value
        i = 1
    
    while True:
        # run ODE solver
        flag = cvodes.CVode(cvode_mem, tout, y, ctypes.byref(t),
                            cvodes.CV_NORMAL)

        if verbose:
            print "At t = %-14.4e  y =" % t.value, \
                  ("  %-11.6e  "*len(y)) % tuple(y)

        """Used for return."""
        if return_last==False:
            T[i] = t.value
            ylist[i] = N.array(y)
            i = i + 1
            
        if N.abs(tout-end_time)<=1e-6:
            break

        if flag == cvodes.CV_SUCCESS:
            tout += time_step

        if tout>end_time:
            tout=end_time

    if return_last==False:
        assert i <= num_samples, "Allocated a too small array." \
                                 " (%s > %s)" % (i, num_samples)
        num_samples = i
        ylist = ylist[:num_samples]
        T = T[:num_samples]
            
    if sensi:
        cvodes.CVodeGetSens(cvode_mem, t, yS)

    if verbose:
        # collecting lots of information about the execution and present it
        nst     = cvodes.CVodeGetNumSteps(cvode_mem)
        nfe     = cvodes.CVodeGetNumRhsEvals(cvode_mem)
        nsetups = cvodes.CVodeGetNumLinSolvSetups(cvode_mem)
        netf    = cvodes.CVodeGetNumErrTestFails(cvode_mem)
        nni     = cvodes.CVodeGetNumNonlinSolvIters(cvode_mem)
        ncfn    = cvodes.CVodeGetNumNonlinSolvConvFails(cvode_mem)
        nje     = cvodes.CVDenseGetNumJacEvals(cvode_mem)
        nfeLS   = cvodes.CVDenseGetNumRhsEvals(cvode_mem)
        nge     = cvodes.CVodeGetNumGEvals(cvode_mem)
        print "\nFinal Statistics:"
        print "nst = %-6i nfe  = %-6i nsetups = %-6i nfeLS = %-6i nje = %i" % \
              (nst, nfe, nsetups, nfeLS, nje)
        print "nni = %-6ld ncfn = %-6ld netf = %-6ld nge = %ld\n " % \
              (nni, ncfn, netf, nge)
    
    if return_last:
        ylist = N.array(y).copy()
        T = t.value
    else:
        ylist = N.array(ylist)
        T = N.array(T)
    
    if sensi:
        return (T, ylist, N.array(yS), parameters)
    else:
        return (T, ylist, None, parameters)
