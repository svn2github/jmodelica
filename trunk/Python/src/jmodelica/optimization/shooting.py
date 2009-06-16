#!/usr/bin/python
# -*- coding: utf-8 -*-
"""Implements single and multiple shooting.

"""

import ctypes

import nose
import numpy as N

try:
    from pysundials import cvodes
    from pysundials import nvecserial
except ImportError:
    import cvodes
    import nvecserial
    
from jmodelica.jmi import *


def _get_example_path(relpath):
    """ Get the absolute path to the examples.
    
    @param relpath:
        The path to the example model relative to JMODELICA_HOME.
    
    """
    import os
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, '..', 'Python', 'src', 'jmodelica',
                        'examples', relpath)


def _load_example_jmi_model(relpath, libname):
    """ Loads an example model.
    
        This function is used by the test cases in this file.
    
    """
    try:
        model = JMIModel(libname, _get_example_path(relpath))
    except JMIException, e:
        raise JMIException("%s\nUnable to load test models."
                           " You have probably not compiled the"
                           " examples. Please refer to the"
                           " JModelica README for more information."
                            % e)
    return model
    
    
def _load_example_standard_model(relpath, libname):
    model = StandardModel(libname, _get_example_path(relpath))
    return model


class StandardModel(object):
    """ The standard model. Contains the common functions used to make
        this class behave as a DAE/ODE-model.
    
    """
    def __init__(self, dllname, path):
        self._jmim = JMIModel(dllname, path)
               
    def getParameters(self):
        """Returns the parameters."""
        return self._jmim.pi
        
    def setParameters(self, params):
        self._jmim.pi = params
        
    def getStates(self):
        return self._jmim.x
        
    def setStates(self, x):
        self._jmim.x = x
        
    def getDiffs(self):
        return self._jmim.dx
        
    def getModelSize(self):
        """Returns the dimension of the problem. """
        return len(self.getStates())
        
    def getRealModelSize(self):
        return self.getModelSize()
        
    def evalF(self):
        """ Evaluate F."""
        self._jmim.ode_f()
        
    def evalJacX(self):
        """ Evaluate the jacobian of the function F w.r.t. states x. """
        jac  = N.array([0] * self.getRealModelSize()**2, dtype=c_jmi_real_t)
        mask = N.array([1] * self.getRealModelSize()**2, dtype=N.int32)
        self._jmim.jmi_ode_df(self._jmi,
                                   J.JMI_DER_CPPAD,
                                   J.JMI_DER_DENSE_ROW_MAJOR,
                                   J.JMI_DER_X,
                                   mask,
                                   jac)
        n = self.getRealModelSize()
        jac = jac.reshape( (n,n) )
        return jac
        
    def getSensitivities(self, y):
        """ Not supported in this model. """
        raise NotImplementedError('This model does not support'
                                  ' sensitivity analysis implicitly.')
                                   
    def getInputs(self):
        return self._jmim.u
        
    def setInputs(self, new_u):
        self._jmim.u = new_u
        
    def getAlgebraics(self):
        return self._jmim.w
        
    def setAlgebraics(self, w):
        self._jmim.w = w
        
    def setTime(self, new_t):
        """ Set the variable t. """
        self._jmim.t = new_t
        
    def getTime(self):
        return self._jmim.t
        
    def evalCost(self):
        """ Evaluate the optimization cost function, J. """
        return self._jmim.opt_J()
        
    def isFreeStartTime(self):
        ignore1, start_time_free, ignore2, ignore3 = self._jmim.opt_get_optimization_interval()
        return start_time_free == 1
        
    def isFixedStartTime(self):
        return not self.isFreeStartTime()
        
    def isFreeFinalTime(self):
        ignore1, ignore2, ignore3, final_time_free = self._jmim.opt_get_optimization_interval()
        return final_time_free == 1
        
    def isFixedFinalTime(self):
        return not self.isFreeFinalTime()
        
    def getStartTime(self):
        start_time, ignore1, ignore2, ignore3 = self._jmim.opt_get_optimization_interval()
        return start_time
        
    def getFinalTime(self):
        ignore1, ignore2, final_time, ignore3 = self._jmim.opt_get_optimization_interval()
        return final_time
        
    def getCostJacobian(self):
        mask = N.ones(self._jmim._n_z.value, dtype=int)
        jac = N.zeros(self._jmim._n_z.value, dtype=c_jmi_real_t)
        self._jmim.opt_dJ(JMI_DER_CPPAD, JMI_DER_SPARSE, JMI_DER_DX,
                          mask, jac)
        return jac


class TestStandardModel:
    """ Test the GenericModel class. """
    
    def setUp(self):
        """ Test setUp. Load the test model
        
        """
        self.m = _load_example_standard_model('vdp', 'VDP_pack_VDP_Opt')
        
    def testModelSize(self):
        """ Test GenericModel.getModelSize()
        
        """
        size = self.m.getModelSize()
        nose.tools.assert_equal(size, 3)
        
    def testRealModelSize(self):
        """ Test GenericModel.getRealModelSize(). """
        size = self.m.getRealModelSize()
        nose.tools.assert_equal(size, 3)
        
    def testStatesGetSet(self):
        """ Test GenericModel.setStates(...) and
            GenericModel.getStates()
        
        """
        new_states = [1.74, 3.38, 12.45]
        reset = [0, 0, 0]
        self.m.setStates(reset)
        states = self.m.getStates()
        N.testing.assert_array_almost_equal(reset, states)
        self.m.setStates(new_states)
        states = self.m.getStates()
        N.testing.assert_array_almost_equal(new_states, states)
        
    def testDiffs(self):
        """ Test GenericModel.setDiffs(...) and
            GenericModel.getDiffs()
        
        """
        reset = [0, 0, 0]
        diffs = self.m.getDiffs()
        diffs[:] = reset
        diffs2 = self.m.getDiffs()
        N.testing.assert_array_almost_equal(reset, diffs2)
        
        new_diffs = [1.54, 3.88, 45.87]
        diffs[:] = new_diffs
        N.testing.assert_array_almost_equal(new_diffs, diffs2)
        
    def testInputs(self):
        """ Test GenericModel.setInputs(...) and
            GenericModel.getInputs()
        
        """
        new_inputs = [1.54]
        reset = [0]
        self.m.setInputs(reset)
        inputs = self.m.getInputs()
        N.testing.assert_array_almost_equal(reset, inputs)
        self.m.setInputs(new_inputs)
        inputs = self.m.getInputs()
        N.testing.assert_array_almost_equal(new_inputs, inputs)
        
    def testParameters(self):
        """ Test GenericModel.setParameters(...) and
            GenericModel.getParameters()
        
        """
        new_params = [1.54, 19.54, 78.12]
        reset = [0] * 3
        self.m.setParameters(reset)
        params = self.m.getParameters()
        N.testing.assert_array_almost_equal(reset, params)
        self.m.setParameters(new_params)
        params = self.m.getParameters()
        N.testing.assert_array_almost_equal(new_params, params)
        
    def testTimeGetSet(self):
        """ Test GenericModel.setTime(...) and GenericModel.getTime()
        
        """
        new_time = 0.47
        reset = 0
        self.m.setTime(reset)
        t = self.m.getTime()
        nose.tools.assert_almost_equal(reset, t)
        self.m.setTime(new_time)
        t = self.m.getTime()
        nose.tools.assert_almost_equal(new_time, t)
        
    def testEvaluation(self):
        self.m.evalF()

    def testFixedSimulation(self):
        """ Test simulation
        
        """
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed times supported."
        
        solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        
    def testOptimizationCostEval(self):
        """ Test evaluation of optimization cost function
        
        """
        solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m.evalCost()
        
    def testOptimizationCostJacobian(self):
        """ Test evaluation of optimization cost function jacobian
        
        """
        solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m.getCostJacobian()


def solve_using_sundials(model, end_time, start_time=0.0, verbose=False, sensi=False, use_jacobian=False):
    """ Solve Lotka-Volterra equation using PySUNDIALS.
    
    @param model:
        The model to use. As of today either of StandardModel type or
        GenericSensitivityModel.
    @param end_time:
        The time when the model simulation should end.
    @param start_time:
        The (optional) time when the model simulation should start.
        Defaults to 0.0.
    @param verbose:
        True of verbose output should be printed. Defaults to False.
    @param sensi:
        True if the built-in sensitivity functionality should be used in
        SUNDIALS. Defaults to False.
    @param use_jacobian:
        If the jacobian should be used or not. (EXPERIMENTAL!)
    @return:
        A tuple consisting of:
            1. Time samples.
            2. States samples.
            3. Sensitivity matrix. None if sensi==False.
    """
    def _sundials_f(t, x, dx, f_data):
        """ Model (RHS) evaluation function.
        
            Moving data between SUNDIALS arrays and NumPy arrays.
            
            f_data contains the model and an array with it's parameters.
        
        """
        data = ctypes.cast(f_data, PUserData).contents
        model = data.model
        model.setTime( (t - data.t_sim_start) / data.t_sim_duration )
        if data.ignore_p == 0:
            p = data.parameters
            sundials_params = p.params
        
        # Copying from sundials space to model space and back again
        if data.ignore_p == 0:
            model.setParameters( sundials_params[p.pi_start : p.pi_end] )
            model.setInputs( sundials_params[p.u_start : p.u_end] )
        model.setStates(x)
        model.evalF()
        dx[:] = model.getDiffs()
        
        return 0

    def _Jac(N, J, t, y, fy, jac_data, tmp1, tmp2, tmp3):
        """ Set Jacobian calculated by JMI.
            
            This function is a callback function for (Py)SUNDIALS.
        
        """
        data = ctypes.cast(jac_data, PUserData).contents
        model = data.model
        
        model.setTime(t)
        model.setStates(y)
        J_jmi = model.evalJacX()
        
        for row in xrange(len(J_jmi)):
            for col in xrange(len(J_jmi[row])):
                J[row][col] = J_jmi[row][col]
        
        return 0
        
    class UserData(ctypes.Structure):
        """
            ctypes structure used to move data in (and out of?) the
            callback functions.
        
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
    
    # initial y
    y = cvodes.NVector(model.getStates())

    # relative tolerance
    abstol = cvodes.realtype(1.0e-6) # used to be e-14

    # absolute tolerance
    reltol = cvodes.realtype(1.0e-6)

    t0 = cvodes.realtype(start_time)

    cvode_mem = cvodes.CVodeCreate(cvodes.CV_BDF, cvodes.CV_NEWTON)
    cvodes.CVodeMalloc(cvode_mem, _sundials_f, t0, y, cvodes.CV_SS, reltol, abstol)

    cvodes.CVDense(cvode_mem, model.getModelSize())

    # Set f_data
    data = UserData()
    data.model = ctypes.py_object(model)
    data.t_sim_start = start_time
    data.t_sim_end   = end_time
    data.t_sim_duration = data.t_sim_end - data.t_sim_start
    if sensi:
        class PyFData(object):
            """ The Pythonic FData structure corresponding to the fdata
                structure sent used by SUNDIALS.
            
                An instance of of this structure is refered to by the
                C data structure UserData.
                
            """
            # Slots is a feature that can be used in new-style Python
            # classes. It basically makes sure that typos are not made
            # (and is also practical for documentational purposes).
            #
            # See: http://www.geocities.com/foetsch/python/new_style_classes.htm
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
                                * (len(model.getParameters()) \
                                    + model.getModelSize()    \
                                    + len(model.getInputs()))
        parameters.params    = pi_ctype()
        parameters.params[:] = N.concatenate((
                                               model.getParameters(),
                                               model.getStates()[:model.getRealModelSize()],
                                               model.getInputs(),
                                            ))
        # Indices used by sundials_f(...)
        parameters.pi_start    = 0
        parameters.pi_end      = len(model.getParameters())
        parameters.xinit_start = parameters.pi_end
        parameters.xinit_end   = parameters.xinit_start + model.getRealModelSize()
        parameters.u_start     = parameters.xinit_end
        parameters.u_end       = parameters.u_start + len(model.getInputs())
                                        
        data.parameters  = ctypes.py_object(parameters)
        data.ignore_p = 0
    else:
        data.ignore_p = 1
        
    if use_jacobian:
        cvodes.CVDenseSetJacFn(cvode_mem, _Jac, ctypes.pointer(data))
    cvodes.CVodeSetFdata(cvode_mem, ctypes.pointer(data))
    
    if sensi:
        NP = len(model.getParameters()) # number of model parameters
        NU = len(model.getInputs()) # number of control signals/inputs
        NI = len(model.getDiffs()) # number of initial states from
                                   # which sensitivity is calculated
        NS      = NP + NI + NU # number of sensitivities to be calculated
        NEQ     = len(model.getDiffs())
        err_con = False # Use sensisitity for error control
        yS      = nvecserial.NVectorArray([[0] * NEQ] * NP
                                            + [[1] * NEQ] * NI
                                            + [[0] * NEQ] * NU)
        
        cvodes.CVodeSensMalloc(cvode_mem, NS, cvodes.CV_STAGGERED1, yS)
        cvodes.CVodeSetSensErrCon(cvode_mem, err_con)
        cvodes.CVodeSetSensDQMethod(cvode_mem, cvodes.CV_CENTERED, 0)
        
        model_parameters = model.getParameters()
        cvodes.CVodeSetSensParams(cvode_mem, parameters.params, None, None)

    # time step
    tout = 0.4

    # initial time
    t = cvodes.realtype(0.0)

    # used for collecting the y's for plotting
    T, ylist = [], []
    
    while True:
        # run ODE solver
        flag = cvodes.CVode(cvode_mem, tout, y, ctypes.byref(t), cvodes.CV_NORMAL)

        if verbose:
            print "At t = %-14.4e  y =" % t.value, \
                  ("  %-11.6e  "*len(y)) % tuple(y)

        """Used for return."""
        T.append(t.value)
        ylist.append(N.array(y))

        if flag == cvodes.CV_SUCCESS:
            tout += 0.02;

        if tout > end_time:
            break
            
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
        print "nst = %-6i nfe  = %-6i nsetups = %-6i nfeLS = %-6i nje = %i"%(nst, nfe, nsetups, nfeLS, nje)
        print "nni = %-6ld ncfn = %-6ld netf = %-6ld nge = %ld\n "%(nni, ncfn, netf, nge)
    
    ylist = N.array(ylist)
    
    if sensi:
        return (T, ylist, N.array(yS))
    else:
        try:
            yS = model.getSensitivities(y)
        except NotImplementedError:
            yS = None
        return (T, ylist, yS)
