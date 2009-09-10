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
    try:
        import cvodes
        import nvecserial
    except ImportError:
        print "Could not load SUNDIALS."
from openopt import NLP

from jmodelica.simulation import SimulationException
from jmodelica.simulation import Simulator

import jmodelica.jmi as pyjmi
from jmodelica.jmi import c_jmi_real_t


class SundialsSimulationException(SimulationException):
    """An exception thrown by the SUNDIALS simulation kit."""
    pass


class SundialsOdeSimulator(Simulator):
    """An object oriented interface for simulating JModelica.org models."""
    
    def __init__(self, model=None, start_time=None, final_time=None,
                 abstol=1.0e-6, reltol=1.0e-6, time_step=0.2,
                 return_last=False, sensitivity_analysis=False, verbosity=0):
        """Constructor of a TestSundialsOdeSimulator.
        
        Every instance of TestSundialsOdeSimulator needs to have a model to
        simulate. This can be set through this constructor or using the
        set_model(...) setter.
        
        This function also sets some decent default values that can be changed
        by calling the setter methods.
        """
        # Setting defaults
        self.set_absolute_tolerance(abstol)
        self.set_relative_tolerance(reltol)
        self.set_return_last(return_last)
        self._set_solution(None, None)
        self.set_sensitivity_analysis(sensitivity_analysis)
        self._set_sensitivities(None)
        self._set_sensitivity_indices(None)
        self.set_time_step(time_step)
        self.set_verbosity(verbosity)
        if start_time is not None:
            self._start_time = start_time
        elif model.opt_interval_starttime_fixed():
            self._start_time = model.opt_interval_get_start_time()
        else:
            self._start_time = None
        if final_time is not None:
            self._final_time = final_time
        elif model.opt_interval_finaltime_fixed() and final_time is None:
            self._final_time = model.opt_interval_get_final_time()
        else:
            self._final_time = None
            
        if self._final_time is not None and self._start_time is not None and \
            self._start_time >= self._final_time:
                raise SundialsSimulationException('Start time must be before '
                                                  'end time.')
        
        # Setting members
        self.model = model
        
    def set_absolute_tolerance(self, abstol):
        """Set the positive absolute tolerance for simulation.
        
        Currently only a single scalar used for all states is supported.
        
        This function will raise an exception if the tolerance is not positive. 
        
        See the SUNDIALS documentation for more information.
        """
        if abstol <= 0:
            raise SundialsSimulationException("absolute tolerance must be "
                                              "positive.")
        self._abstol = abstol
        
    def get_absolute_tolerance(self):
        """Return the absolute tolerance set for this simulator.
        
        See the SUNDIALS documentation for more information.
        """
        return self._abstol
        
    abstol = property(get_absolute_tolerance, set_absolute_tolerance,
                      doc="The absolute tolerance.")
                      
    def set_relative_tolerance(self, reltol):
        """Set the positive relative tolerance for simulation.
        
        Currently only a single scalar used for all states is supported. 
        
        This function will raise an exception if the tolerance is not positive.
        
        See the SUNDIALS documentation for more information.
        """
        if reltol <= 0:
            raise SundialsSimulationException("relative tolerance must be "
                                              "positive.")
        self._reltol = reltol
        
    def get_relative_tolerance(self):
        """Return the relative tolerance set for this simulator.
        
        See the SUNDIALS documentation for more information.
        """
        return self._reltol
        
    reltol = property(get_relative_tolerance, set_relative_tolerance,
                      doc="The relative tolerance.")
                      
    def set_model(self, model):
        """Set the model on which the simulation should be done on.
        
        The model needs to be of type jmodelica.jmi.Model.
        """
        if model is None:
            raise SundialsSimulationException("model must not be none")
        self._model = model
        
    def get_model(self):
        """Returns the model on which the simulation is being done."""
        return self._model
        
    model = property(get_model, set_model, doc="The model to simulate.")
    
    # verbosity levels
    QUIET = 0
    WHISPER = 1
    NORMAL = 2
    LOUD = 3
    SCREAM = 4
    VERBOSE_VALUES = [QUIET, WHISPER, NORMAL, LOUD, SCREAM]
    def get_verbosity(self):
        """Return the verbosity of the simulator."""
        return self._verbosity
        
    def set_verbosity(self, verbosity):
        """Specify how much output should be given: 0 <= verbosity <= 4.
        
        The verbosity levels can also be specified using the constants:
         * SundialsOdeSimulator.QUIET
         * SundialsOdeSimulator.WHISPER
         * SundialsOdeSimulator.NORMAL
         * SundialsOdeSimulator.LOUD
         * SundialsOdeSimulator.SCREAM
         
        If the verbosity level is set to something not within the interval, an
        error is raised.
        """
        if verbosity not in self.VERBOSE_VALUES:
            raise SundialsSimulationException("invalid verbosity value")
        self._verbosity = verbosity
        
    verbosity = property(get_verbosity, set_verbosity,
                         doc="How explicit the output should be")
        
    def get_solution(self):
        """Return the solution calculated by SundialsOdeSimulator.run().
        
        The solution consists of a tuple (T, Y) where T are the time samples
        and Y contains all the equivalent state samples, one per row.
        """
        return self._T, self._Y
        
    def _set_solution(self, T, Y):
        """Internal function used by SundialsOdeSimulator.run().
        
        Setter for self.get_solution().
        """
        self._T = T
        self._Y = Y
        
    def set_simulation_interval(self, start_time, final_time):
        """Set the interval through the simulation will be made."""
        if start_time >= final_time:
            raise SundialsSimulationException("start time must be earlier "
                                              "than the final time.")
        self._start_time = start_time
        self._final_time = final_time
        
    def get_simulation_interval(self):
        """Return the simulation interval.
        
        The simulation interval consists of a tuple: (start_time, final_time).
        """
        return self._start_time, self._final_time
        
    def get_start_time(self):
        return self._start_time
        
    def get_final_time(self):
        return self._final_time
        
    def get_sensitivities(self):
        """Return the sensitivities calculated at final time by self.run().
        
        The sensitivites are only calculated if
        self.set_sensitivity_analysis(True) is called. Otherwise None is
        returned.
        """
        return self._sens
        
    def _set_sensitivities(self, sens):
        """Internal function used by SundialsOdeSimulator.run().
        
        This sets the sensitivities returned by self.get_sensitivities().
        """
        self._sens = sens
        
    sensitivities = property(get_sensitivities,
                             doc="The calculated sensitivities at final "
                                 "time. This is set by self.run().")
        
    def set_return_last(self, return_last):
        """Set this to True if only the last time point should be returned
           after simulation by self.get_solution(). False otherwise.
        """
        if return_last==1 or return_last==True:
            self._return_last = True
        elif return_last==0 or return_last==False:
            self._return_last = False
        else:
            raise SundialsSimulationException("return_last must be either "
                                              "True, False, 1 or 0.")
                                              
    def get_return_last(self):
        """Returns True if only the last time point should be returned
           after simulation by self.get_solution(), False otherwise.
        """
        return self._return_last
        
    return_last = property(get_return_last, set_return_last,
                           doc="True if only the last time point should be "
                               "returned after simulation by "
                               "self.get_solution(). False otherwise.")
        
    def set_sensitivity_analysis(self, sens_analysis):
        """Set to True if sensitivity analysis should be done while simulating.
        
        The result from the sensivity analysis can be later be extracted by
        self.get_sensitivities().
        """
        if sens_analysis==1 or sens_analysis==True:
            self._sens_analysis = True
        elif sens_analysis==0 or sens_analysis==False:
            self._sens_analysis = False
        else:
            raise SundialsSimulationException("sens_analysis must be either "
                                              "True, False, 1 or 0.")
        
    def get_sensitivity_analysis(self):
        """Getter for self.set_sensitivity_analysis(...)."""
        return self._sens_analysis
        
    sensitivity_analysis = property(get_sensitivity_analysis,
                                    set_sensitivity_analysis,
                                    doc="True if sensitivity analysis should "
                                        "be performed in simulating. False "
                                        "otherwise.")
        
    def set_time_step(self, time_step):
        """Sets the time step returned by self.get_solution()."""
        if time_step <= 0:
            raise SundialsSimulationException("Time step size must be "
                                              "positive.")
        self._time_step = time_step
        
    def get_time_step(self):
        """Returns the time step returned by self.get_solution()."""
        return self._time_step
        
    time_step = property(get_time_step, set_time_step, 
                         doc="The time step size when SUNDIALS should return.")
                                                       
    def get_sensitivity_indices(self):
        """Returns an object that holds information about the indices of the
           the sensivity matrix.
           
        If no sensitivity analysis is done None is returned.
        """
        return self._sens_indices
        
    def _set_sensitivity_indices(self, sens_indices):
        """Internal function used by SundialsOdeSimulator.run().
        
        Setter for self.get_sensitivity_indices().
        """
        self._sens_indices = sens_indices
        
    sensitivity_indices = property(get_sensitivity_indices,
                                   doc="Object that holds information about "
                                       "the indices of the the sensivity "
                                       "matrix.")
                                       
    def _sundials_f(self, t, x, dx, f_data):
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
            data = self._data
            model = data.model
            model.t = (t - data.t_sim_start) / data.t_sim_duration
            if data.ignore_p == 0:
                p = data.parameters
                sundials_params = p.params
                
                model.pi = sundials_params[p.pi_start : p.pi_end]
                model.u = sundials_params[p.u_start : p.u_end]
                
            # Copying from sundials space to model space and back again
            model.x = x
            model.eval_ode_f()
            dx[:] = model.dx
            
            return 0
        
    def run(self):
        """Do the actual simulation.
        
        The input is set using setters/constructor.
        The solution can be retrieved using self.get_solution()
        """
        return_last = self.get_return_last()
        sensi = self.get_sensitivity_analysis()
        time_step = self.get_time_step()
        start_time = self.get_start_time()
        end_time = self.get_final_time()
        verbose = self.get_verbosity()
        model = self.get_model()
        
        if verbose >= self.WHISPER:
            print "Running simulation with interval (%s, %s)." \
                    % (start_time, end_time)
        if verbose >= self.NORMAL:
            print "Input before integration:", model.u
            print "States:", model.x
            print start_time, "to", end_time

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
        
        # initial y (copying just in case)
        y = cvodes.NVector(model.x.copy())

        # converting tolerances to C types
        abstol = cvodes.realtype(self.abstol)
        reltol = cvodes.realtype(self.reltol)

        t0 = cvodes.realtype(start_time)

        cvode_mem = cvodes.CVodeCreate(cvodes.CV_BDF, cvodes.CV_NEWTON)
        cvodes.CVodeMalloc(cvode_mem, self._sundials_f, t0, y, cvodes.CV_SS, reltol, 
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
            
        self._data = data
        
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

            if verbose >= self.SCREAM:
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

        if verbose >= self.LOUD:
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
            self._set_sensitivities(N.array(yS))
            self._set_sensitivity_indices(parameters)
        else:
            self._set_sensitivities(None)
            self._set_sensitivity_indices(None)
        
        self._set_solution(T, ylist)
        
