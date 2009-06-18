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
import pylab as p
import nose


class ShootingException(Exception):
    """ A shooting exception. """
    pass


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
        """ Returns the dimension of the problem. """
        return len(self.getStates())
        
    def getRealModelSize(self):
        """ Returns the dimension of the problem. 
        
        @remark:
            In my master thesis code base there exists a class called
            GenericSensivityModel that wraps an existing model creating
            a pseudo problem that solves multiple disturbed instances of
            this model to be able to approximate sensitivities in a
            different approach than using SUNDIALS. This method came
            into existence to be able to know the size of the original
            problem/model.
        """
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
        """ Not supported in this model class.
        
        @remark:
            This method came existence due to GenericSensivityModel that
            exists in my master thesis code base. See remark on
            ::self.getRealModelSize() for more information why this
            method exists.
        """
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
        
    def getCostJacobian(self, independent_variables, mask=None):
        """ Returns the jacobian for the cost function with respect to
            the independent variable independent_variable.
            
        @param independent_variable:
            A mask consisting of the independent variables (JMI_DER_X
            etc.) requested.
        @todo:
            independent_variable should not be a mask. It is not
            pythonesque.
        @return:
            The cost gradient/jacobian.
        """
        assert self._jmim._n_z.value != 0
        if mask is None:
            mask = N.ones(self._jmim._n_z.value, dtype=int)
        
        n_cols, n_nz = self._jmim.opt_dJ_dim(JMI_DER_CPPAD,
                                             JMI_DER_DENSE_ROW_MAJOR,
                                             independent_variables,
                                             mask)
        jac = N.zeros(n_nz, dtype=c_jmi_real_t)
        
        self._jmim.opt_dJ(JMI_DER_CPPAD, JMI_DER_DENSE_ROW_MAJOR, independent_variables,
                          mask, jac)
        return jac.reshape( (1, len(jac)) )
        
    def reset(self):
        self._jmim.resetModel()


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
        
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        #p.show()
        
    def testOptJacNonZeros(self):
        """ Testing the numer of non-zero elements in VDP after
            simulation.
            
        @note:
            This test is model specific and not generic as most other
            tests in this class.
        """
        solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        assert self.m._jmim._n_z > 0, "Length of z should be greater than zero."
        print 'n_z.value:', self.m._jmim._n_z.value
        n_cols, n_nz = self.m._jmim.opt_dJ_dim(JMI_DER_CPPAD,
                                               JMI_DER_SPARSE,
                                               JMI_DER_X_P,
                                               N.ones(self.m._jmim._n_z.value,
                                                      dtype=int))
        
        print 'n_nz:', n_nz
        
        assert n_cols > 0, "The resulting should at least of one column."
        assert n_nz > 0, "The resulting jacobian should at least have" \
                         " one element (structurally) non-zero."
        
    def testOptimizationCostEval(self):
        """ Test evaluation of optimization cost function
        """
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m._jmim.setX_P(ys[-1], 0)
        self.m._jmim.setDX_P(self.m.getDiffs(), 0)
        cost = self.m.evalCost()
        nose.tools.assert_not_equal(cost, 0)
        
    def testOptimizationCostJacobian(self):
        """ Test evaluation of optimization cost function jacobian
        
        @note:
            This test is model specific for the VDP oscillator.
        """
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m._jmim.setX_P(ys[-1], 0)
        self.m._jmim.setDX_P(self.m.getDiffs(), 0)
        jac = self.m.getCostJacobian(JMI_DER_X_P)
        N.testing.assert_almost_equal(jac, [[0, 0, 1]])


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
            4. An instance of the PyFData class containing the indices
               for the the sensivity matrix.
               
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
            
                An instance of of this structure is referred to by the
                C data structure UserData.
                
                This class can be used to interpret the columns in the
                sensivity matrix.
                
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
        parameters = None # Needed for correct return
        
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
        return (T, ylist, N.array(yS), parameters)
    else:
        try:
            yS = model.getSensitivities(y)
        except NotImplementedError:
            yS = None
        return (T, ylist, yS, parameters)


def _shoot(model, start_time, end_time):
    """ Does a single "shot". Model parameters must be set BEFORE
        calling this method.
        
    @note:
        Currently written specifically for VDP.
    @note:
        Currently only supports inputs.
    @note:
        Assumes cost function is not directly dependent on parameters
        (in this case - input u).
        
    @param start_time:
        The time when simulation should start.
    @param end_time:
        The time when the simulation should finish.
    @return:
        A tuple consisting of:
            1. The cost after simulation.
            2. The cost gradient with respect to input U.
            3. The final ($t_{tp_0}=1$) simulation states.
            
    """
    T, ys, sens, params = solve_using_sundials(model, end_time, start_time, sensi=True)
    u_sens = sens[:][params.u_start:params.u_end]
    model._jmim.setX_P(ys[-1], 0)
    model._jmim.setDX_P(model.getDiffs(), 0)
    
    cost = model.evalCost()
    
    cost_jac = model.getCostJacobian(JMI_DER_X_P)
        
    # This assumes that the cost function does not depend on the u:s
    # which is the case of 
    gradient = N.dot(cost_jac, u_sens.T)
    gradient = gradient.flatten()
    
    last_y = ys[-1][:]
    
    return cost, gradient, last_y


def single_shooting(model, initial_u=0.4):
    """ Run single shooting.
    
    @note:
        Currently written specifically for VDP.
    @note:
        Currently only supports inputs.
    
    @param model:
        The model to simulate/optimize over.
    @param initial_u:
        The initial input U_0 used to initialize the optimization with.
    @return:
        The optimal u.
        
    """
    start_time = model.getStartTime()
    end_time = model.getFinalTime()
    
    u = model.getInputs()
    new_u = N.array([0.4])
    print "Initial u:", u
    
    # Used for plotting.
    Us = []
    costs = []
    
    ITERATIONS = 20
    for ignore in range(ITERATIONS):
        model.reset()
        u[:] = new_u
        print "u is", u
        cost, gradient, last_y = _shoot(model, start_time, end_time)
        
        print "Cost:", cost
        Us.append(u[0])
        costs.append(cost)
        
        new_u = u-0.001*gradient
    
    p.plot(Us, costs)
    p.title('Optimization history.')
    p.show()
    
    return u


def multiple_shooting(model, initials, end_time=None):
    """ Does multiple shooting.
    
    @param model:
        The model to simulate/optimize over.
    @param initials:
        A list of tuples, each corresponding to a segment in the
        multiple shooting algorithm. Each tuple consists of:
            1. The start_time for the segment.
            2. The input U for the segment (being constant throughout
               the segment simulation.
    @return:
        The optimal inputs (Us).
        
    """
    if len(initials) == 0:
        raise ShootingException('Incorrect initial_Us parameter. You must specify at least one segment.')
    if initials[0][0] != model.getStartTime():
        print "Warning: The start time of the first segment should usually coinside with the model start time."
        
    if end_time is None:
        end_time = model.getFinalTime()
        
    start_times, Us = zip(*initial_Us)
    segments = zip(start_times, start_times[1:]+[end_time], Us)
    
    raise NotImplementedError('Multiple shooting is not implemented yet')
    
    # TODO: CREATE A U-VECTOR AND USE THAT ONE
    
    # The following contains some pseudo code.
    while OPTIMIZING:
        for (seg_start_time, seg_end_time, u) in segments:
            model.reset()
            model.setInputs(N.array([u]))
            seg_cost, seg_gradient, seg_last_y = _shoot(model, seg_start_time, seg_end_time)
            
            # SAVE THE RESULTS
            
        # CALCULATE GLOBAL GRADIENT
        # UPDATE U-vector
    

def cost_graph(model):
    """ Plot the cost as a function a constant u (single shooting).
    
    @note:
        Currently written specifically for VDP.
    @note:
        Currently only supports inputs.
    """
    start_time = model.getStartTime()
    end_time = model.getFinalTime()
    
    u = model.getInputs()
    print "Initial u:", u
    
    costs = []
    Us = []
    
    for u_elmnt in N.arange(-0.5, 1, 0.02):
        print "u is", u
        model.reset()
        u[0]=u_elmnt
        T, ys, sens, params = solve_using_sundials(model, end_time, start_time, sensi=True)
        model._jmim.setX_P(ys[-1], 0)
        model._jmim.setDX_P(model.getDiffs(), 0)
        
        cost = model.evalCost()
        print "Cost:", cost
        
        # Saved for plotting
        costs.append(cost)
        Us.append(u_elmnt)
        
        cost_jac = model.getCostJacobian(JMI_DER_X_P)
        
    p.plot(Us, costs)
    p.title("Costs as a function of different constant Us (VDP model)")
    p.show()


def main():
    m = _load_example_standard_model('vdp', 'VDP_pack_VDP_Opt')
    
    # Whether the cost as a function of input U should be plotted
    GEN_PLOT = False
    
    if GEN_PLOT:
        cost_graph(m)
    else:
        opt_u = single_shooting(m)
        print "Optimal u:", opt_u


if __name__ == "__main__":
    main()

