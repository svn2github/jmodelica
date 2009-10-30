#!/usr/bin/env python 
# -*- coding: utf-8 -*-
"""Sundials Simulation.

"""

import ctypes
import math

import numpy as N
import matplotlib
import pylab as p
import nose

try:
    from pysundials import cvodes
    from pysundials import ida
    from pysundials import nvecserial
except ImportError:
    try:
        import ida
        import cvodes
        import nvecserial
    except ImportError:
        print "Could not load SUNDIALS."

from jmodelica.simulation import SimulationException
from jmodelica.simulation import ODESimulator, DAESimulator

import jmodelica.jmi as pyjmi
from jmodelica.jmi import c_jmi_real_t


class SundialsSimulationException(SimulationException):
    """An exception thrown by the SUNDIALS simulation kit."""
    pass


class _SensivityIndices(object):
    """Used to interpret the columns in the sensivity matrix.
    
    This class is used by SundialsODESimulator._sundials_f(...) and
    SundialsODESimulator.run().
    """
    # Slots is a feature that can be used in new-style Python
    # classes. It can be used toamke sure that typos are not made
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
    
    def __init__(self, model):
        self.pi_start    = 0
        self.pi_end      = len(model.pi)
        self.xinit_start = self.pi_end
        self.xinit_end   = self.xinit_start + len(model.x)
        self.u_start     = self.xinit_end
        self.u_end       = self.u_start + len(model.u)
        
        pi_ctype = cvodes.realtype * (len(model.pi) + len(model.x) \
                                                            + len(model.u))
        self.params    = pi_ctype()
        self.params[:] = N.concatenate((model.pi,
                                        model.x[:len(model.x)],
                                        model.u,))


class SundialsODESimulator(ODESimulator):
    """An object oriented interface for simulating JModelica.org models."""
    
    def __init__(self, model=None, start_time=None, final_time=None,
                 abstol=1.0e-6, reltol=1.0e-6, time_step=0.2,
                 return_last=False, sensitivity_analysis=False, verbosity=0):
        """Constructor of a TestSundialsODESimulator.
        
        Every instance of TestSundialsODESimulator needs to have a model to
        simulate. This can be set through this constructor or using the
        set_model(...) setter.
        
        This function also sets some decent default values that can be changed
        by calling the setter methods.
        """
        ODESimulator.__init__(self, model, start_time, final_time,
                           abstol, reltol, time_step, return_last, 
                           verbosity)
        
        # Setting defaults
        self._set_sensitivity_indices(None)
        self.set_sensitivity_analysis(sensitivity_analysis)
        self._set_sensitivities(None)
                      
       
       
    def get_sensitivities(self):
        """Return the sensitivities calculated at final time by self.run().
        
        The sensitivites are only calculated if
        self.set_sensitivity_analysis(True) is called. Otherwise None is
        returned.
        """
        return self._sens
        
    def _set_sensitivities(self, sens):
        """Internal function used by SundialsODESimulator.run().
        
        This sets the sensitivities returned by self.get_sensitivities().
        """
        self._sens = sens
        
    sensitivities = property(get_sensitivities,
                             doc="The calculated sensitivities at final "
                                 "time. This is set by self.run().")
        
       
    def set_sensitivity_analysis(self, sens_analysis):
        """Set to True if sensitivity analysis should be done while simulating.
        
        The result from the sensivity analysis can be later be extracted by
        self.get_sensitivities().
        """
        if sens_analysis==1 or sens_analysis==True:
            self._sens_analysis = True
            if self.get_sensitivity_indices() is None:
                # This result cached. Only load if not loaded.
                self._set_sensitivity_indices(_SensivityIndices(self.model))
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
        
    
    def get_sensitivity_indices(self):
        """Returns an object that holds information about the indices of the
           the sensivity matrix.
           
        As soon as sensitivity analysis is activated this object is set.
        """
        return self._sens_indices
        
    def _set_sensitivity_indices(self, sens_indices):
        """Internal function used by SundialsODESimulator.run().
        
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
        
        if start_time == None or end_time == None:
            raise SundialsSimulationException("Start and End-time must be defined.")
        
        if verbose >= self.WHISPER:
            print "Running simulation with interval (%s, %s)." \
                    % (start_time, end_time)
        if verbose >= self.NORMAL:
            print "Input before integration:", model.u
            print "States:", model.x
            print start_time, "to", end_time

        class UserData:
            """ctypes structure used to move data in (and out of?) the callback
               functions.
            """
            def __init__(self):
                self.parameters = None
                self.model = None
                self.ignore_p = None
                self.t_sim_start = None
                self.t_sim_end = None
                self.t_sim_duration = None
            
            __slots__ = [
                'parameters',     # parameters
                'model',          # The evaluation model
                                  # (RHS if you will).
                'ignore_p',       # Whether p should be ignored or
                                  # not used to reduce unnecessary
                                  # copying.
                't_sim_start',    # Start time for simulation.
                't_sim_end',      # End time for simulation.
                't_sim_duration', # Time duration for simulation.
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
        data.model = model
        data.t_sim_start = start_time
        data.t_sim_end   = end_time
        data.t_sim_duration = data.t_sim_end - data.t_sim_start
        if sensi:
            # Sensitivity indices used by sundials_f(...)
            data.parameters = self.get_sensitivity_indices()
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
            cvodes.CVodeSetSensParams(cvode_mem, data.parameters.params, None,
                                      None)
        
        tout = start_time + time_step
        if tout>end_time:
            raise SundialsSimulationException("Start time must be before final time.")

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
        else:
            self._set_sensitivities(None)
        
        self._set_solution(T, ylist)
        


class SundialsDAESimulator(DAESimulator):
    """An object oriented interface for simulation JModelica.org DAE models."""
    
    def __init__(self, model=None, start_time=None, final_time=None,
                abstol=1.0e-6, reltol=1.0e-6, time_step = 0.2,
                return_last=False, sensitivity_analysis=False, verbosity=0):
                    
        DAESimulator.__init__(self, model, start_time, final_time,
                           abstol, reltol, time_step, return_last, 
                           verbosity)
                           
        
        #TODO
        #self._set_sensitivity_indices(None)
        #self.set_sensitivity_analysis(sensitivity_analysis)
        #self._set_sensitivities(None)
    
    def _sundials_res_f(self, t, z, dz, res_vector, f_data):
            """The sundials' Residual evaluation function.
            
            This function basically moves data between SUNDIALS arrays and NumPy
            arrays.
            
            Parameters:
            t               -- the point time on which the evalution is being done.
            z               -- the states.
            dz              -- the derivatives of the states.
            res_vector      -- the output residual_vector F(t,x,dx)
            f_data          -- contains the model and an array with it's parameters.
            
            See SUNDIALS' manual and/or PySUNDIALS demos for more information.
            """

            #Moving data to the model
            model = self.model
            model.t = t #(t - data.t_sim_start) / data.t_sim_duration
            
            model.x = z[0:len(model.x)]
            model.w = z[len(model.x):len(z)]
            
            model.dx = dz[0:len(model.dx)]

            #Evaluating the residual function
            temp = N.array(res_vector)
            model.jmimodel.dae_F(temp)
            res_vector[:] = temp
            
            return 0
        
    def run(self):
        """Do the actual simulation.
        
        The input is set using setters/constructor.
        The solution can be retrieved using self.get_solution()
        """
        return_last = self.get_return_last()
        time_step = self.get_time_step()
        start_time = self.get_start_time()
        end_time = self.get_final_time()
        verbose = self.get_verbosity()
        model = self.get_model()
        #TODO
        #sensi = self.get_sensitivity_analysis()
        if start_time == None or end_time == None:
            raise SundialsSimulationException("Start and End-time must be defined.")

        if verbose >= self.WHISPER:
            print "Running simulation with interval (%s, %s) and time step %s" \
                    % (start_time, end_time, time_step)
        if verbose >= self.NORMAL:
            print "Input before integration:", model.u
            print "States dx:", model.dx
            print "States x:", model.x
            print "States w:", model.w
            

        class UserData:
            """ctypes structure used to move data in (and out of?) the callback
               functions.
            """
            def __init__(self):
                self.parameters = None
                self.model = None
                self.t_sim_start = None
                self.t_sim_end = None
                self.t_sim_duration = None
            
            __slots__ = [
                'parameters',     # Parameters
                'model',          # The evaluation model
                't_sim_start',    # Start time for simulation.
                't_sim_end',      # End time for simulation.
                't_sim_duration', # Time duration for simulation.
            ]
        
        # initial y,ydot (copying just in case)
        y = ida.NVector(N.append(model.x.copy(),model.w.copy()))
        ydot = ida.NVector(N.append(model.dx.copy(),[0]*len(model.w)))
        
        
        # converting tolerances to C types
        abstol = ida.realtype(self.abstol)
        reltol = ida.realtype(self.reltol)

        t0 = ida.realtype(start_time)
        
        
        ida_mem = ida.IDACreate()
        
        ida.IDAMalloc(ida_mem, self._sundials_res_f, t0, y, ydot, ida.IDA_SS, reltol, abstol)
        ida.IDADense(ida_mem, len(model.x)+len(model.w))
        """
        # Set f_data
        data = UserData()
        data.model = model
        data.t_sim_start = start_time
        data.t_sim_end   = end_time
        data.t_sim_duration = data.t_sim_end - data.t_sim_start
        
        self._data = data
        """
        tout = start_time + time_step
        if tout>end_time:
            raise SundialsSimulationException("Start time must be before final time.")

        # initial time
        t = ida.realtype(t0.value)

        # used for collecting the y's for plotting
        if return_last==False:
            num_samples = int(math.ceil((end_time - start_time) / time_step)) + 1
            T = N.zeros(num_samples, dtype=pyjmi.c_jmi_real_t)
            ylist = N.zeros((num_samples, len(model.dx)+len(model.x)+len(model.u)+len(model.w)),
                            dtype=pyjmi.c_jmi_real_t)
            temp = N.array([])
            for j in [model.dx.copy(), model.x.copy(), model.u.copy(), model.w.copy()]:
                if len(j) > 0:
                    temp = N.append(temp, j)
            assert len(model.dx)+len(model.x)+len(model.u)+len(model.w) == len(temp)
            ylist[0] = temp
            T[0] = t0.value
            i = 1
        else:
            ylist = N.zeros((1, len(model.dx)+len(model.x)+len(model.u)+len(model.w)),
                            dtype=pyjmi.c_jmi_real_t)
            

        #ida.IDASetId(ida_mem,ida.NVector(N.append([1.0]*len(model.x),[0.0]*len(model.w))))
        #ida.IDASetSuppressAlg(ida_mem,suppress)
        #ida.IDACalcIC(ida_mem,ida.IDA_YA_YDP_INIT,ida.realtype(t0.value+time_step))
            
        while True:
            # run DAE solver
            flag = ida.IDASolve(ida_mem, tout, ctypes.byref(t), y, ydot, ida.IDA_NORMAL)    

            if verbose >= self.SCREAM:
                print "At t = %-14.4e  y =" % t.value, \
                      ("  %-11.6e  "*len(y)) % tuple(y)

            """Used for return."""
            if return_last==False:
                T[i] = t.value
                temp = N.array([])
                for j in [ydot[:len(model.dx)],y[:len(model.x)],model.u.copy(),y[len(model.x):len(y)]]:
                    if len(j) > 0:
                        temp = N.append(temp,j)
                ylist[i] = temp
                i = i+1
                
            if N.abs(tout-end_time)<=1e-6:
                break

            if flag == ida.IDA_SUCCESS:
                tout += time_step

            if tout>end_time:
                tout=end_time

        if return_last==False:
            assert i <= num_samples, "Allocated a too small array." \
                                     " (%s > %s)" % (i, num_samples)
            num_samples = i
            ylist = ylist[:num_samples]
            T = T[:num_samples]

        if verbose >= self.LOUD:
            # collecting lots of information about the execution and present it
            print "\nFinal Run Statistics: \n"
            print "Number of steps                    = %ld"%ida.IDAGetNumSteps(ida_mem)
            print "Number of residual evaluations     = %ld"%(ida.IDAGetNumResEvals(ida_mem)+ida.IDADenseGetNumResEvals(ida_mem))
            print "Number of Jacobian evaluations     = %ld"%ida.IDADenseGetNumJacEvals(ida_mem)
            print "Number of nonlinear iterations     = %ld"%ida.IDAGetNumNonlinSolvIters(ida_mem)
            print "Number of error test failures      = %ld"%ida.IDAGetNumErrTestFails(ida_mem)
            print "Number of nonlinear conv. failures = %ld"%ida.IDAGetNumNonlinSolvConvFails(ida_mem)
            print "Number of root fn. evaluations     = %ld"%ida.IDAGetNumGEvals(ida_mem)
            print "Gradient" #TODO
        
        if return_last:
            temp = N.array([])
            for j in [ydot[:len(model.dx)],y[:len(model.x)],model.u.copy(),y[len(model.x):len(y)]]:
                if len(j) > 0:
                    temp = N.append(temp, j)
            ylist[0] = temp
            T = N.array([t.value])
        else:
            ylist = N.array(ylist)
            T = N.array(T)
        
        self._set_solution(T, ylist)
        
    
    def get_solution(self, *variables):
        """Return the solution calculated by run().
        
        The solution consists of a tuple (T, Y) where T are the time samples
        and Y contains all the equivalent state samples, one per row. You
        are also given the option to specify which variables you want to 
        extract.
        """
        if len(variables) > 0:
            
            Y = N.array([])
            
            # invert the dictionaries so that the variable name is the key
            invert_der_names = dict([v,k] for k,v in self.get_model().get_derivative_names().iteritems())
            invert_diff_names = dict([v,k] for k,v in self.get_model().get_differentiated_variable_names().iteritems())
            invert_input_names = dict([v,k] for k,v in self.get_model().get_input_names().iteritems())
            invert_alg_names = dict([v,k] for k,v in self.get_model().get_algebraic_variable_names().iteritems())
            
            try:
                der_minimum = N.array(invert_der_names.values(),dtype=N.int16).min()
            except ValueError:
                der_minimum = 0
            try:
                diff_minimum = N.array(invert_diff_names.values(),dtype=N.int16).min()
            except ValueError:
                diff_minimum = 0
            try:
                input_minimum = N.array(invert_input_names.values(),dtype=N.int16).min()
            except ValueError:
                input_minimum = 0
            try:
                alg_minimum = N.array(invert_alg_names.values(),dtype=N.int16).min()
            except ValueError:
                alg_minimum = 0
                
            nbr_derivative = len(self.get_model().dx)
            nbr_differentiated = len(self.get_model().x)
            nbr_input = len(self.get_model().u)
            
            nbr_found = 0
            
            for x in variables:
                # search for the variable in derivative variables
                if invert_der_names.has_key(x):
                    abs_index = N.array(invert_der_names[x],dtype=N.int16)
                    index = abs_index-der_minimum
                    Y = N.append(Y,self._Y[:,index],axis=0)
                    nbr_found = nbr_found+1
                # search for the variable in differentiated variables
                elif invert_diff_names.has_key(x):
                    abs_index = N.array(invert_diff_names[x],dtype=N.int16)
                    index = abs_index-diff_minimum+nbr_derivative
                    Y = N.append(Y,self._Y[:,index],axis=0)
                    nbr_found = nbr_found+1
                # search for the input variables
                elif invert_input_names.has_key(x):
                    abs_index = N-array(invert_diff_names[x],dtype=N.int16)
                    index = abs_index-input_minimum+nbr_derivative+nbr_differentiated
                # search for the variable in algebraic variables    
                elif invert_alg_names.has_key(x):
                    abs_index = N.array(invert_alg_names[x],dtype=N.int16)
                    index = abs_index-alg_minimum+nbr_derivative+nbr_differentiated+nbr_input
                    Y = N.append(Y,self._Y[:,index],axis=0)
                    nbr_found = nbr_found+1
            
            if nbr_found > 0:
                Y=Y.reshape(len(Y)/nbr_found,nbr_found,order='F')
                if self.get_verbosity() >= self.LOUD:
                    print "Found %s number of variables"%nbr_found
            else:
                if self.get_verbosity() >= self.NORMAL:
                    print "No variables found."
        else:
            Y = self._Y
                
        
        return self._T, Y
