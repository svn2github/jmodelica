#!/usr/bin/python
# -*- coding: utf-8 -*-
"""Implements single and multiple shooting.

"""

import ctypes
import math
import os

import nose
import numpy as N
import scipy as S
import matplotlib

try:
    from pysundials import cvodes
    from pysundials import nvecserial
except ImportError:
    import cvodes
    import nvecserial
from openopt import NLP
    
import jmodelica.jmi as pyjmi
from jmodelica.jmi import c_jmi_real_t
import pylab as p
import nose


class ShootingException(Exception):
    """ A shooting exception. """
    pass


def _get_example_path():
    """ Get the absolute path to the examples.
    
    @param relpath:
        The path to the example model relative to JMODELICA_HOME.
    
    """
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, '..', 'Python', 'src', 'jmodelica', 'examples', 'files')
    
    
def _load_example_standard_model(libname, mofile=None, optpackage=None):
    try:
        model = JmiOptModel(libname, _get_example_path())
    except IOError:
        if mofile is None or optpackage is None:
            raise
            
        print "The model was not found. Trying to compile it..."
        import jmodelica.optimicacompiler as oc
        curdir = os.getcwd()
        os.chdir(_get_example_path())
        oc.compile_model(os.path.join(_get_example_path(), mofile), optpackage)
        os.chdir(curdir)
        
    model = JmiOptModel(libname, _get_example_path())
    return model


class OptModel:
    """An abstract model on which optimization is done on.
    
    Contains the common functions used to make this class behave as a DAE/ODE
    model.
    
    """
    def getParameters(self):
        """Returns the parameters."""
        raise NotImplementedError()
        
    def setParameters(self, params):
        raise NotImplementedError()
        
    def getStates(self):
        raise NotImplementedError()
        
    def setStates(self, x):
        raise NotImplementedError()
        
    def getDiffs(self):
        raise NotImplementedError()
        
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
        raise NotImplementedError()
        
    def evalJacX(self):
        """Evaluate the jacobian of the function F w.r.t. states x. """
        raise NotImplementedError()
        
    def getSensitivities(self, y):
        """Not supported in this model class.
        
        @remark:
            This method came existence due to GenericSensivityModel that
            exists in my master thesis code base. See remark on
            ::self.getRealModelSize() for more information why this
            method exists.
        """
        raise NotImplementedError('This model does not support'
                                  ' sensitivity analysis implicitly.')
                                   
    def getInputs(self):
        raise NotImplementedError()
        
    def setInputs(self, new_u):
        raise NotImplementedError()
        
    def setTime(self, new_t):
        """ Set the variable t. """
        raise NotImplementedError()
        
    def getTime(self):
        raise NotImplementedError()
        
    def evalCost(self):
        """ Evaluate the optimization cost function, J. """
        raise NotImplementedError()
        
    def isFreeStartTime(self):
        raise NotImplementedError()
        
    def isFreeFinalTime(self):
        raise NotImplementedError()
        
    def isFixedStartTime(self):
        return not self.isFreeStartTime()
        
    def isFixedFinalTime(self):
        return not self.isFreeFinalTime()
        
    def getStartTime(self):
        raise NotImplementedError()
        
    def getFinalTime(self):
        raise NotImplementedError()
        
    def getCostJacobian(self, independent_variables, mask=None):
        """ Returns a partial jacobian of the cost function.
        
        Returns the partial jacobian of the cost function with respect to the
        independent variables independent_variable (JMI_DER_X etc.).
        
        @todo:
            independent_variable should not be a mask. It is not
            pythonesque.
        """
        raise NotImplementedError()
        
    def reset(self):
        raise NotImplementedError()
        

class _DebugOptModel(OptModel):
    """A model defined in Python instead of using a JMI model (JmiOptModel).
    
    This class is used for debugging. Initially created to verify correct
    sensitivity analysis.
    
    Model (ODE):
    
    xdot0 = 1
    xdot1 = p0
    xdot2 = x0 + p0*x1
    
    Parameters:
    p0 = 3
    """
    def __init__(self):
        self.reset()
        
    def reset(self):
        self._params = N.array([3], dtype=pyjmi.c_jmi_real_t)
        self._time = 0
        self._xdiffs = N.array([1, 3, 0], dtype=pyjmi.c_jmi_real_t)
        self._x = N.array([0, 0, 0], dtype=pyjmi.c_jmi_real_t)
    
    def getParameters(self):
        """Returns the parameters."""
        return self._params
        
    def setParameters(self, params):
        self._params[:] = params
        
    def getStates(self):
        return self._x
        
    def setStates(self, x):
        self._x[:] = x
        
    def getDiffs(self):
        return self._xdiffs
        
    def evalF(self):
        """ Evaluate F:
        
        xdot0 = 1
        xdot1 = p0
        xdot2 = x0 + p0*x1
        """
        x = self.getStates()
        xdot = self.getDiffs()
        params = self.getParameters()
        xdot[0] = 1
        xdot[1] = params[0]
        xdot[2] = x[0] + params[0] * x[1]
        
    def evalJacX(self):
        """Evaluate the jacobian of the function F w.r.t. states x. """
        raise NotImplementedError()
                                   
    def getInputs(self):
        return N.array([])
        
    def setInputs(self, new_u):
        inputs = self.getInputs()
        inputs[:] = new_u
        
    def setTime(self, new_t):
        """ Set the variable t. """
        self._time = new_t
        
    def getTime(self):
        return self._time
        
    def evalCost(self):
        """ Evaluate the optimization cost function, J. """
        raise NotImplementedError()
        
    def isFreeStartTime(self):
        return False
        
    def isFreeFinalTime(self):
        return False
        
    def getStartTime(self):
        return 0
        
    def getFinalTime(self):
        return 2
        
    def getCostJacobian(self, independent_variables, mask=None):
        """ Returns a partial jacobian of the cost function.
        
        Returns the partial jacobian of the cost function with respect to the
        independent variables independent_variable (JMI_DER_X etc.).
        
        @todo:
            independent_variable should not be a mask. It is not
            pythonesque.
        """
        raise NotImplementedError()


class TestDebugOptModel:
    """ Test the JmiOptModel class. """
    
    def setUp(self):
        """ Test setUp. Load the test model
        
        """
        self.m = _DebugOptModel()
        
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
        new_inputs = []
        reset = []
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
        new_params = [1.54]
        reset = [0]
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
        
    def testSimulationWSensivity(self, SMALL=0.3):
        """Testing simulation sensivity."""
        
        FINALTIME = self.m.getFinalTime()
        STARTTIME = self.m.getStartTime()
        DURATION = FINALTIME - STARTTIME
        
        self.m.reset()
        T, ys, sens, params = solve_using_sundials(self.m, FINALTIME, STARTTIME, sensi=True)
        
        assert len(T) == len(ys)
        assert sens is not None
        assert len(T) > 1
        
        # This expected result was calculated by hand
        # See my master thesis for details.
        expected_sens = N.array([[0, 2, 12],
                                 [1, 0, 2 ],
                                 [0, 1, 6 ],
                                 [0, 0, 1 ]])
        N.testing.assert_array_almost_equal(sens, expected_sens)                         
        
        print "INDICES:"
        print "============"
        for indexname in ['pi_start', 'pi_end', 'xinit_start', 'xinit_end', 'u_start', 'u_end']:
            print "%-14s%s" % ("%s:" % indexname, getattr(params, indexname))
        print "============"
        print "SENSIVITIES:"
        print "============"
        print sens
        print "============"
        
        self.m.reset()
        self.m.setStates(self.m.getStates() + SMALL)
        T2, ys2, ignore, ignore2 = solve_using_sundials(self.m, FINALTIME, STARTTIME, sensi=False)
        
        fig = p.figure()
        p.hold(True)
        p.plot(T, ys, label="The non-disturbed solution")
        p.plot(T2, ys2, label="The solution with disturbed initial conditions (SMALL=%s)" % SMALL)
        
        lininterpol = ys[-1] + DURATION * N.dot(N.r_[
                                                    sens[params.xinit_start : params.xinit_end],
                                                    sens[params.u_start : params.u_end]
                                                ].T,
                                                [SMALL]*3)
        p.plot([T2[-1]], [lininterpol], 'xr', label="Expected states linearly interpolated.")
        
        p.legend(loc=0, prop=matplotlib.font_manager.FontProperties(size=8))
        p.hold(False)
        fig.savefig('TestDebugOptModel_testSimulationWSensivity.png')

    def testFixedSimulation(self):
        """Test simulation"""
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed times supported."
        
        self.m.reset()
        self.m.setInputs([0.25])
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        assert len(T) == len(ys)
        
        fig = p.figure()
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestDebugOptModel_testFixedSimulation.png')
        
    def testFixedSimulationIntervals(self):
        """Test simulation between a different time span."""
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed ties supported."
        
        middle_timepoint = (self.m.getFinalTime() + self.m.getStartTime()) / 2.0
        
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), middle_timepoint)
        assert len(T) == len(ys)
        T, ys, sens, ignore = solve_using_sundials(self.m, middle_timepoint, self.m.getStartTime())
        assert len(T) == len(ys)
        
        fig = p.figure()
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestDebugOptModel_testFixedSimulationIntervals.png')
        
    def testReset(self):
        """ Testing resetting the model."""
        self.m.reset()


class JmiOptModel(OptModel):
    """ The standard model.
    
    Contains the common functions used to make this class behave as a DAE/ODE
    model.
    
    """
    def __init__(self, dllname, path):
        self._m = pyjmi.Model(dllname, path)
               
    def getParameters(self):
        """Returns the parameters."""
        return self._m.pi
        
    def setParameters(self, params):
        self._m.pi = params
        
    def getStates(self):
        return self._m.x
        
    def setStates(self, x):
        self._m.x = x
        
    def getDiffs(self):
        return self._m.dx
        
    def evalF(self):
        """ Evaluate F."""
        self._m.jmimodel.ode_f()
        
    def evalJacX(self):
        """ Evaluate the jacobian of the function F w.r.t. states x. """
        jac  = N.array([0] * self.getRealModelSize()**2, dtype=c_jmi_real_t)
        mask = N.array([1] * self.getRealModelSize()**2, dtype=N.int32)
        self._m.jmimodel.jmi_ode_df(pyjmi.JMI_DER_CPPAD,
                                    pyjmi.JMI_DER_DENSE_ROW_MAJOR,
                                    pyjmi.JMI_DER_X,
                                    mask,
                                    jac)
        n = self.getRealModelSize()
        jac = jac.reshape( (n,n) )
        return jac
                                   
    def getInputs(self):
        return self._m.u
        
    def setInputs(self, new_u):
        self._m.u = new_u
        
    def setTime(self, new_t):
        """ Set the variable t. """
        self._m.t = new_t
        
    def getTime(self):
        return self._m.t
        
    def evalCost(self):
        """ Evaluate the optimization cost function, J. """
        return self._m.jmimodel.opt_J()
        
    def isFreeStartTime(self):
        ignore1, start_time_free, ignore2, ignore3 = self._m.jmimodel.opt_get_optimization_interval()
        return start_time_free == 1
        
    def isFixedStartTime(self):
        return not self.isFreeStartTime()
        
    def isFreeFinalTime(self):
        ignore1, ignore2, ignore3, final_time_free = self._m.jmimodel.opt_get_optimization_interval()
        return final_time_free == 1
        
    def isFixedFinalTime(self):
        return not self.isFreeFinalTime()
        
    def getStartTime(self):
        start_time, ignore1, ignore2, ignore3 = self._m.jmimodel.opt_get_optimization_interval()
        return start_time
        
    def getFinalTime(self):
        ignore1, ignore2, final_time, ignore3 = self._m.jmimodel.opt_get_optimization_interval()
        return final_time
        
    def getCostJacobian(self, independent_variables, mask=None):
        """ Returns a partial jacobian of the cost function.
        
        Returns the partial jacobian of the cost function with respect to the
        independent variables independent_variable (JMI_DER_X etc.).
        
        @todo:
            independent_variable should not be a mask. It is not
            pythonesque.
        """
        assert self._m._n_z.value != 0
        if mask is None:
            mask = N.ones(self._m._n_z.value, dtype=int)
        
        n_cols, n_nz = self._m.jmimodel.opt_dJ_dim(pyjmi.JMI_DER_CPPAD,
                                                   pyjmi.JMI_DER_DENSE_ROW_MAJOR,
                                                   independent_variables,
                                                   mask)
        jac = N.zeros(n_nz, dtype=c_jmi_real_t)
        
        self._m.jmimodel.opt_dJ(pyjmi.JMI_DER_CPPAD,
                                pyjmi.JMI_DER_DENSE_ROW_MAJOR,
                                independent_variables,
                                mask,
                                jac)
        return jac.reshape( (1, len(jac)) )
        
    def reset(self):
        self._m.resetModel()


class TestJmiOptModel:
    """ Test the JmiOptModel class. """
    
    def setUp(self):
        """ Test setUp. Load the test model
        
        """
        self.m = _load_example_standard_model('VDP_pack_VDP_Opt')
        
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
        
    def testSimulationWSensivity(self, SMALL=0.3):
        """Testing simulation sensivity."""
        
        FINALTIME = 2
        STARTTIME = self.m.getStartTime()
        DURATION = FINALTIME - STARTTIME
        
        self.m.reset()
        self.m.setInputs([0.25])
        T, ys, sens, params = solve_using_sundials(self.m, FINALTIME, STARTTIME, sensi=True)
        
        assert len(T) == len(ys)
        assert sens is not None
        assert len(T) > 1
        
        self.m.reset()
        self.m.setInputs([0.25 + SMALL])
        self.m.setStates(self.m.getStates() + SMALL)
        T2, ys2, ignore, ignore2 = solve_using_sundials(self.m, FINALTIME, STARTTIME, sensi=False)
        
        fig = p.figure()
        p.hold(True)
        p.plot(T, ys, label="The non-disturbed solution")
        p.plot(T2, ys2, label="The solution with disturbed initial conditions (SMALL=%s)" % SMALL)
        
        lininterpol = ys[-1] + DURATION * N.dot(N.r_[
                                                    sens[params.xinit_start : params.xinit_end],
                                                    sens[params.u_start : params.u_end]
                                                ].T,
                                                [SMALL]*4)
        p.plot([T2[-1]], [lininterpol], 'xr', label="Expected states linearly interpolated.")
        
        p.legend(loc=0, prop=matplotlib.font_manager.FontProperties(size=8))
        p.hold(False)
        fig.savefig('TestJmiOptModel_testSimulationWSensivity.png')

    def testFixedSimulation(self):
        """Test simulation"""
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed times supported."
        
        self.m.reset()
        self.m.setInputs([0.25])
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        assert len(T) == len(ys)
        
        fig = p.figure()
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestJmiOptModel_testFixedSimulation.png')
        
    def testFixedSimulationIntervals(self):
        """Test simulation between a different time span."""
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed ties supported."
        
        middle_timepoint = (self.m.getFinalTime() + self.m.getStartTime()) / 2.0
        
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), middle_timepoint)
        assert len(T) == len(ys)
        T, ys, sens, ignore = solve_using_sundials(self.m, middle_timepoint, self.m.getStartTime())
        assert len(T) == len(ys)
        
        fig = p.figure()
        p.plot(T, ys)
        p.title('testFixedSimulation(...) output')
        fig.savefig('TestJmiOptModel_testFixedSimulationIntervals.png')
        
    def testOptJacNonZeros(self):
        """ Testing the numer of non-zero elements in VDP after
            simulation.
            
        @note:
            This test is model specific and not generic as most other
            tests in this class.
        """
        solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        assert self.m._m._n_z > 0, "Length of z should be greater than zero."
        print 'n_z.value:', self.m._m._n_z.value
        n_cols, n_nz = self.m._m.jmimodel.opt_dJ_dim(pyjmi.JMI_DER_CPPAD,
                                                     pyjmi.JMI_DER_SPARSE,
                                                     pyjmi.JMI_DER_X_P,
                                                     N.ones(self.m._m._n_z.value,
                                                      dtype=int))
        
        print 'n_nz:', n_nz
        
        assert n_cols > 0, "The resulting should at least of one column."
        assert n_nz > 0, "The resulting jacobian should at least have" \
                         " one element (structurally) non-zero."
        
    def testOptimizationCostEval(self):
        """ Test evaluation of optimization cost function
        """
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m._m.setX_P(ys[-1], 0)
        self.m._m.setDX_P(self.m.getDiffs(), 0)
        cost = self.m.evalCost()
        nose.tools.assert_not_equal(cost, 0)
        
    def testOptimizationCostJacobian(self):
        """ Test evaluation of optimization cost function jacobian
        
        @note:
            This test is model specific for the VDP oscillator.
        """
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m._m.setX_P(ys[-1], 0)
        self.m._m.setDX_P(self.m.getDiffs(), 0)
        jac = self.m.getCostJacobian(pyjmi.JMI_DER_X_P)
        N.testing.assert_almost_equal(jac, [[0, 0, 1]])
        
    def testReset(self):
        """ Testing resetting the model."""
        self.m.reset()


def solve_using_sundials(model, end_time,
                         start_time=0.0,
                         verbose=False,
                         sensi=False,
                         use_jacobian=False,
                         abstol=1.0e-6, # used to be e-14
                         reltol=1.0e-6,
                         time_step=0.02):
    """ Solve Lotka-Volterra equation using PySUNDIALS.
    
    @param model:
        The model to use. Should be a derive class from OptModel.
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
    @param abstol:
        The absolute tolerance. See SUNDIALS' manual for more info.
    @param reltol:
        The relative tolerance. See SUDNIALS' manual for more info.
    @param time_step:
        The step size when SUNDIALS should return from it's internal loop. See
        SUNDIALS' manual for more info.
    @return:
        A tuple consisting of:
            1. Time samples.
            2. States samples.
            3. Sensitivity matrix. None if sensi==False.
            4. An instance of the PyFData class containing the indices
               for the the sensivity matrix.
               
    """
    if end_time < start_time:
        raise ShootingException('End time cannot be before start time.')
    if end_time == start_time:
        raise ShootingException('End time and start time cannot currently coinside.')
    
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
    
    # initial y (copying just in case)
    y = cvodes.NVector(model.getStates().copy())

    # converting tolerances to C types
    abstol = cvodes.realtype(abstol)
    reltol = cvodes.realtype(reltol)

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
        raise NotImplementedError('Jacobian cannot be used as of now.')
        cvodes.CVDenseSetJacFn(cvode_mem, _Jac, ctypes.pointer(data))
    cvodes.CVodeSetFdata(cvode_mem, ctypes.pointer(data))
    
    if sensi:
        NP = len(model.getParameters()) # number of model parameters
        NU = len(model.getInputs()) # number of control signals/inputs
        NI = model.getModelSize() # number of initial states from
                                  # which sensitivity is calculated
        NS      = NP + NI + NU # number of sensitivities to be calculated
        NEQ     = model.getModelSize()
        assert NEQ == NI, "yS must be modified below to handle the" \
                          " inequality NEQ != NI"
        err_con = False # Use sensisitity for error control
        yS      = nvecserial.NVectorArray([[0] * NEQ] * NP
                                            + N.eye(NI).tolist()
                                            + [[0] * NEQ] * NU)
        
        cvodes.CVodeSensMalloc(cvode_mem, NS, cvodes.CV_STAGGERED1, yS)
        cvodes.CVodeSetSensErrCon(cvode_mem, err_con)
        cvodes.CVodeSetSensDQMethod(cvode_mem, cvodes.CV_CENTERED, 0)
        
        model_parameters = model.getParameters()
        cvodes.CVodeSetSensParams(cvode_mem, parameters.params, None, None)

    # time step
    time_step = time_step
    
    tout = start_time + time_step

    # initial time
    t = cvodes.realtype(t0.value)

    # used for collecting the y's for plotting
    T, ylist = [t0.value], [model.getStates().copy()]
    
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
            tout += time_step

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
    T = N.array(T)
    
    if sensi:
        return (T, ylist, N.array(yS), parameters)
    else:
        try:
            yS = model.getSensitivities(y)
        except NotImplementedError:
            yS = None
        return (T, ylist, yS, parameters)


def _shoot(model, start_time, end_time, sensi=True):
    """ Does a single 'shot'.
    
    if sensi is set to False no sensitivity analysis will be done and the 
    
    Model parameters/states etc. must be set BEFORE calling this method.
        
    @note:
        Currently written specifically for VDP.
    @note:
        Currently only supports inputs.
    @note:
        Assumes cost function is only dependent on state X.
        
    @param start_time:
        The time when simulation should start.
    @param end_time:
        The time when the simulation should finish.
    @return:
        A tuple consisting of:
            1. The cost gradient with respect to initial states and
               input U.
            2. The final ($t_{tp_0}=1$) simulation states.
            3. A structure holding the indices for the gradient.
            4. The corresponding sensitivity matrix.
            
    """
    T, ys, sens, params = solve_using_sundials(model, end_time, start_time, sensi=sensi)
    
    model._m.setX_P(ys[-1], 0)
    model._m.setDX_P(model.getDiffs(), 0)
    model._m.setU_P(model.getInputs(), 0)
    
    if sensi:
        sens_rows = range(params.xinit_start, params.xinit_end) + range(params.u_start, params.u_end)
        sens_mini = sens[sens_rows]
        gradparams = {
            'xinit_start': 0,
            'xinit_end': params.xinit_end - params.xinit_start,
            'u_start': params.xinit_end - params.xinit_start,
            'u_end': params.xinit_end - params.xinit_start + params.u_end - params.u_start,
        }
    
        cost_jac_x = model.getCostJacobian(pyjmi.JMI_DER_X_P).flatten()
        cost_jac_u = model.getCostJacobian(pyjmi.JMI_DER_U_P).flatten()
        cost_jac = N.concatenate ( [cost_jac_x, cost_jac_u] )
        
        # See my master thesis report for the specifics of these calculations.
        costgradient_x = N.dot(sens[params.xinit_start:params.xinit_end, :], cost_jac_x).flatten() # verified
        costgradient_u = N.dot(sens[params.u_start:params.u_end, :], cost_jac_x).flatten() + cost_jac_u # verified
        
        # The full cost gradient w.r.t. the states and the input
        costgradient = N.concatenate( [costgradient_x, costgradient_u] )
    else:
        costgradient = None
        gradparams = None
        sens_mini = None
    
    last_y = ys[-1,:]
    
    # TODO: Create a return type instead of returning tuples
    return costgradient, last_y, gradparams, sens_mini


def single_shooting(model, initial_u=0.4, GRADIENT_THRESHOLD=0.0001):
    """ Run single shooting.
    
    @note:
        Currently written specifically for VDP.
    @note:
        Currently only supports inputs.
    
    @param model:
        The model to simulate/optimize over.
    @param initial_u:
        The initial input U_0 used to initialize the optimization with.
    @param GRADIENT_THRESHOLD:
        The threshold in when the inf norm of two different gradients
        should consider two gradients same or different.
    @return:
        The optimal u.
        
    """
    start_time = model.getStartTime()
    end_time = model.getFinalTime()
    
    u = model.getInputs()
    u0 = N.array([0.4])
    print "Initial u:", u
    
    gradient = None
    gradient_u = None
    
    def f(cur_u):
        global gradient
        global gradient_u
        model.reset()
        u[:] = cur_u
        print "u is", u
        big_gradient, last_y, gradparams, sens = _shoot(model, start_time, end_time)
        
        model._m.setX_P(last_y, 0)
        model._m.setDX_P(model.getDiffs(), 0)
        model._m.setU_P(model.getInputs(), 0)
        cost = model.evalCost()
        
        gradient_u = cur_u.copy()
        gradient = big_gradient[gradparams['u_start']:gradparams['u_end']]
        
        print "Cost:", cost
        print "Grad:", gradient
        return cost
    
    def df(cur_u):
        if gradient_u is not None and max(gradient_u - cur_u) < GRADIENT_THRESHOLD:
            print "Using existing gradient"
        else:
            print "Recalculating gradient"
            f(cur_u)
            
        return gradient
    
    p = NLP(f, u0, maxIter = 1e3, maxFunEvals = 1e2)
    p.df = df
    p.plot = 1
    p.iprint = 1
    
    u_opt = p.solve('ralg')
    return u_opt


def _eval_initial_ys(model, grid):
    # TODO: Move this to MultipleShooter
    from scipy import interpolate
    _check_grid_consistency(grid)
    
    model.reset()
    T, ys, sens, params = solve_using_sundials(model, model.getFinalTime(), model.getStartTime())
    T = N.array(T)
    
    tck = interpolate.interp1d(T, ys, axis=0)
    initials = map(lambda interval: tck(interval[0]).flatten(), grid)
    initials = N.array(initials).flatten()
    return initials
    

def _check_normgrid_consistency(normgrid):
    # TODO: Move this to MultipleShooter
    """Check normalized grid input parameter for errors.
    
    Raises ShootingException on error.
    """
    if math.fabs(normgrid[0][0]) > 0.001:
        raise ShootingException("Warning: The start time of the first segment should usually coinside with the model start time.")
    if math.fabs(normgrid[-1][1]-1) > 0.001:
        raise ShootingException("Warning: The end time of the last segment should usually coinside with the model end time.")
    _check_grid_consistency(normgrid)


def _check_grid_consistency(grid):
    # TODO: Move this to MultipleShooter
    """Check grid input parameter for errors.
    
    Raises ShootingException on error.
    """
    if not len(grid) >= 1:
        raise ShootingException('You need to specify at least one segment.')
    def check_inequality(a, b):
        if a >= b:
            raise ShootingException('One grid segment is incorrectly formatted.')
    map(check_inequality, *zip(*grid))


class MultipleShooter:
    """Handles Multiple Shooting model optimization."""
    
    def __init__(self, model, initial_u, normgrid=[(0, 1)], initial_y=None, plot=True):
        """Constructor.
        
        @param model:
            The model to simulate/optimize over.
        @param initial_u:
            A list of initial inputs for each segment. If not a list, it is
            assumed to be the same initial input for each segment.
        @param normgrid:
            A list of 2-tuples per segment. The first element in each tuple
            being the segment start time, the second element the segment end
            time. The grid must hold normalized values.
        @param initial_y:
            Can be three things:
             * A list of initial states for all grids. If any of these are
               None they will be replaced by the default model state.
             * None -- using the solution from the default model state.
             * A list of initial states for each segment except the first one.
               If not a list the same initial state will be used for each
               segment.
               
        NOTE that any states set in the model will be reset when initializing
        this class with with that model.
        """
        self.set_model(model)
        self.set_normalized_grid(normgrid)
        self.set_initial_u(initial_u)
        self.set_initial_y(initial_y)
        
    def set_model(self, model):
        """Set the model.
        
        NOTE that any states set in the model will be reset when initializing
        this class with with that model.
        """
        model.reset()
        self._m = model
        
    def get_model(self):
        return self._m    
        
    def set_initial_u(self, initial_u):
        """ Set the initial U's (control signals) for each segment."""
        grid = self.get_grid()
        if len(initial_u) != len(grid):
            raise ShootingException('initial_u parameters must be the same length as grid segments.')
        self._initial_u = N.array(initial_u).reshape( (len(grid), -1) )
        
    def get_initial_u(self):
        """Returns the constant control/input signals, one segment per row."""
        return self._initial_u
        
    def set_initial_y(self, initial_y=None):
        """Set the initial states for the first optimization iteration.
        
        If initial_y is None a simple guessing scheme will be used based on a
        simple simulation using default initial values.
        """
        model = self.get_model()
        grid = self.get_grid()
        
        if initial_y is None:
            initial_y = _eval_initial_ys(model, grid)
        elif len(initial_y) != len(grid):
            raise ShootingException('initial_y states must be the same length as grid segments.')
        self._initial_y = N.array(initial_y).reshape( (len(grid), -1) )
        
    def get_initial_y(self):
        """Returns the initial states, one segment per row."""
        return self._initial_y
        
    def set_normalized_grid(self, grid):
        """ Set the grid containing normalized times between [0, 1].
        
        The method also checks for inconsistencies in the grid.
        """
        _check_normgrid_consistency(grid)
        
        model = self.get_model()
        
        # Denormalize times
        simulation_length = model.getFinalTime() - model.getStartTime()
        def denormalize_time(start_time, end_time):
            start_time = model.getStartTime() + simulation_length * start_time
            end_time = model.getStartTime() + simulation_length * end_time
            return (start_time, end_time)
            
        self.set_grid(map(denormalize_time, *zip(*grid)))
        
    def set_grid(self, grid):
        """ Set the grid.
        
        The grid does not necessarily have to be normalized.
        
        The method also checks for inconsistencies in the grid.
        """
        _check_grid_consistency(grid)
        
        self._grid = grid
        
    def get_grid(self):
        """ Returned the real grid holding the actual simulation times."""
        return self._grid
    
    def _shoot_single_segment(self, u, y0, interval, sensi=True):
        """Shoot a single segment in multiple shooting.
        
        The 'shot' is done between interval[0] and interval[1] with initial
        states y0 and constant input/control signal u.
        """
        model = self.get_model()
        
        if len(y0) != model.getModelSize():
            raise ShootingException('Wrong length to single segment: %s != %s' % (len(y0), model.getModelSize()))
            
        seg_start_time = interval[0]
        seg_end_time = interval[1]
        
        u = u.flatten()
        y0 = y0.flatten()
        
        model.reset()
        model.setInputs(u)
        model.setStates(y0)
        
        seg_cost_gradient, seg_last_y, seg_gradparams, sens = _shoot(model, seg_start_time, seg_end_time, sensi=sensi)
        
        # TODO: Create a return type instead of returning tuples
        return seg_cost_gradient, seg_last_y, seg_gradparams, sens
    
    def f(self, p):
        """The cost evaluation function.
        
        @param p:
            A concatenation of initial states (excluding the first
            segment) and parameters. See _split_opt_x(...) for details.
        """
        model = self.get_model()
        grid = self.get_grid()
        ys, us = _split_opt_x(model, len(grid), p)
        
        costgradient, last_y, gradparams, sens = self._shoot_single_segment(us[-1], ys[-1], grid[-1], sensi=False)
        
        model._m.setX_P(last_y, 0)
        model._m.setDX_P(model.getDiffs(), 0)
        model._m.setU_P(model.getInputs(), 0)
        cost = model.evalCost()
        
        print "Evaluating cost:", cost
        print "Evaluating cost: (u, y, grid) = ", us[-1], ys[-1], grid[-1]
        
        return cost
        
    def df(self, p):
        """Returns the gradient of self.f(p).
        
        In the VDP example it depends on the 
        """
        model = self.get_model()
        grid = self.get_grid()
        ys, us = _split_opt_x(model, len(grid), p)
        costgradient, last_y, gradparams, sens = self._shoot_single_segment(us[-1], ys[-1], grid[-1])
        
        print "Evaluating cost function gradient."
        
        # Comments:
        #  * The cost does not depend on the first initial states.
        #  * The cost does not depend on the first inputs/control signal
        gradient = N.array([0] * len(model.getStates()) * (len(grid) - 1)
                            + list(costgradient[gradparams['xinit_start'] : gradparams['xinit_end']])
                            + [0] * (len(grid) - 1)
                            + list(costgradient[gradparams['u_start'] : gradparams['u_end']]))
        assert len(p) == len(gradient)
        print gradient
        return gradient
        
    def h(self, p): # h(p) = 0
        """Evaluates continuity (equality) constraints.
        
        This function has visually been verified to work in the sense that
        discontinuities lead to a big magnitude of the corresponding elements
        in the system.
        """
        model = self.get_model()
        grid = self.get_grid()
        y0s, us = _split_opt_x(model, len(grid), p)
        
        # Assert that initial states of first gradient are unchanged
        y0s_from_p0 = self.get_initial_y()
        #N.testing.assert_array_almost_equal(y0s_from_p0[0], y0s[0])
        y0s[0,:] = y0s_from_p0[0,:]
        
        def eval_last_ys(u, y0, interval):
            grad, last_y, gradparams, sens = self._shoot_single_segment(u, y0, interval)
            return last_y
        last_ys = N.array(map(eval_last_ys, us[:-1], y0s[:-1], grid[:-1]))
        
        print "Evaluating equality contraints:", (last_ys - y0s[1:])
        
        return (last_ys - y0s[1:])
        
    def dh(self, p):
        """ Evaluates the jacobian of self.h(p).
        
        TODO: Set first initial states to zero (or even better have a mask for
              which parameters that should not be changed).
        """
        print "Evaluating equality contraints gradient."
        
        model = self.get_model()
        grid = self.get_grid()
        y0s, us = _split_opt_x(model, len(grid), p)
        
        def eval_last_ys(u, y0, interval):
            costgrad, last_y, gradparams, sens = self._shoot_single_segment(u, y0, interval)
            return gradparams, sens
        mapresults = map(eval_last_ys, us[:-1], y0s[:-1], grid[:-1])
        gradparams, sens = zip(*mapresults)
        
        NP = len(p)                  # number of elements in p
        NOS = len(model.getStates()) # Number Of States
        NOI = len(model.getInputs()) # Number Of Inputs
        NEQ = (len(grid) - 1) * NOS  # number of equality equations in h(p)
        
        r = N.zeros((NEQ, NP))
        
        for segmentindex in range(len(grid) - 1):
            # Indices
            row_start = segmentindex * NOS
            row_end = row_start + NOS
            xinitsenscols_start = segmentindex * NOS
            xinitsenscols_end = xinitsenscols_start + NOS
            xinitcols_start = segmentindex * NOS + NOS
            xinitcols_end = xinitcols_start + NOS
            usenscols_start = y0s.size + NOI * segmentindex
            usenscols_end = usenscols_start + NOI
            
            # Indices from the sensivity matrix
            sensxinitindices = range(gradparams[segmentindex]['xinit_start'], gradparams[segmentindex]['xinit_end'])
            sensuindices = range(gradparams[segmentindex]['u_start'], gradparams[segmentindex]['u_end'])
            
            if segmentindex != 0:
                # The initial states of first segment is locked.
                r[row_start : row_end, xinitsenscols_start : xinitsenscols_end] = sens[segmentindex][sensxinitindices, :].T
            r[row_start : row_end, xinitcols_start : xinitcols_end] = [[-1, 0, 0],
                                                                       [0, -1, 0],
                                                                       [0, 0, -1]]
            r[row_start : row_end, usenscols_start : usenscols_end] = sens[segmentindex][sensuindices, :].T
        
        return r
        
    def get_p0(self):
        """Returns the vector which is to optimized over."""
        initial_y = self.get_initial_y()
        initial_u = self.get_initial_u()
        p0 = N.concatenate( (N.array(initial_y).flatten(), N.array(initial_u).flatten()) )
        return p0
        
    def runOptimization(self, plot=True):
        """Start/run optimization procedure and the optimum."""
        grid = self.get_grid()
        model = self.get_model()
        
        # Initial try
        p0 = self.get_p0()
        
        # Less than (-0.5 < u < 1)
        # TODO: These are currently hard coded. They shouldn't be.
        NLT = len(grid)
        Alt = N.zeros( (NLT, len(p0)) )
        Alt[:len(grid), len(grid) * model.getModelSize():] = N.eye(len(grid))
        blt = 0.75*N.ones(NLT)
        
        # Get OpenOPT handler
        p = NLP(self.f, p0, maxIter = 1e3, maxFunEvals = 1e3, h=self.h, A=Alt, b=blt, df=self.df, dh=self.dh)
        #p = NLP(self.f, p0, maxIter = 1e2, maxFunEvals = 1e3, h=self.h)
        """Notes:
         * Using only (f) optimization seems to work.
         * Using both (f) and (df) seems to work partly. However, a lot slower
           and converges extremely slow.
        """
        
        if plot:
            p.plot = 1
        p.iprint = 1
        
        # Uncomment these to check gradients against finite difference
        # quotients
        #p.checkdf(maxViolation=0.05)
        #p.checkdh()
        #return
        
        opt = p.solve('ralg')
        
        if plot:
            plot_control_solutions(model, grid, opt.xf)
        
        return opt.xf
        
    def runSteepestDescent(self, plot=True):
        grid = self.get_grid()
        model = self.get_model()
        
        # Initial try
        p0 = self.get_p0()
        x = p0.copy()
        
        p.hold(True)
        for i in range(200):
            p.plot([i], [self.f(x)], 'o')
            x = x - 0.001 * self.df(x)
        p.hold(False)
        p.show()
        
        if plot:
            plot_control_solutions(model, grid, x)
        
        return x
        
    def runQuasiNewtonsMethod(self, plot=True):
        grid = self.get_grid()
        model = self.get_model()
        
        # Initial try
        p0 = self.get_p0()
        
        from scipy.optimize import fmin_bfgs
        #xopt = fmin_bfgs(self.f, p0, fprime=self.df)
        xopt = fmin_bfgs(self.f, p0)
        """This is interesting. It seems that adding fprime does not add to
        the convergence of the optimization."""
        
        if plot:
            plot_control_solutions(model, grid, xopt)

        return xopt
        
        
def _verify_gradient(f, df, xstart, xend, SMALL=0.1, STEPS=100):
    """ Output a comparison plot between f.d. quotient and and df.
    
    The plot os written to the current matplotlib figure within the interval
    [xstart, xend] split into STEPS steps. The finite difference quotient has
    an infitesimal equal to SMALL.
    """
    assert xstart < xend
    
    x = N.arange(xstart, xend, 1.0*(xend - xstart) / STEPS)
    
    # Plot the function evaluated
    p.subplot(211)
    fevals = N.array(map(f,x))
    p.plot(x, fevals, label='The evaluated function')
    p.title('Derivative check ')
    p.legend()
    
    p.subplot(212)
    p.title('Derivative comparison')
    p.hold(True)
    
    # Plot the derivative
    dfs = map(df,x)
    p.plot(x, dfs, label='Given derivative')
    
    # Plot the approximated finite difference
    fevals_delta = N.array(map(f, x+SMALL))
    adfs = (fevals_delta - fevals) / SMALL
    p.plot(x, adfs, label='Approximate derivative')
    
    # Plot the difference between approximated derivative and the given derivative
    p.plot(x, adfs-dfs, label='Der. method difference')
    
    p.hold(False)
    p.legend(prop=matplotlib.font_manager.FontProperties(size=8))
    
    
def test_verify_gradient():
    """ Testing _verify_gradient(...)."""
    fig = p.figure()
    f = lambda x: x**2
    df = lambda x: 2*x
    _verify_gradient(f, df, -10, 10)
    fig.savefig('test_verify_gradient.png')
    

class _PartialEvaluator:
    """Evaluator used to evaluate a one dimensional function by setting
       the other fixes. Used by test_gradient_elements().
       
    TODO: Clearer documentation :-)   
    """
    def __init__(self, f, df, xbase, index):
        self._f = f
        self._df = df
        self._xbase = xbase
        self._index = index
        
    def f(self, x):
        xvec = self._xbase.copy()
        xvec[self._index] = x
        return self._f(xvec)
        
    def df(self, x):
        xvec = self._xbase.copy()
        xvec[self._index] = x
        return self._df(xvec)[self._index]


def test_f_gradient_elements(certainindex=None):
    """Basic testing of gradients (disabled by default).
    
    This tests takes slightly less than an hour to run on my computer unless
    certainindex is defined (whereas only the element of index certainindex
    will be tested). Therefor it is turned off by default. Set run_huge_test
    variable to True to run this test by default.
    
    Also note that this test is not really supposed to test functionality per
    se. It is rather a test that can be used to visually verify that gradients
    behave the way they are expected to.
    """
    run_huge_test = False
    
    if run_huge_test is False and certainindex is None:
        return
    
    m = _load_example_standard_model('VDP_pack_VDP_Opt')
    grid = [(0, 0.1),
            (0.1, 0.2),
            (0.2, 0.3),
            (0.3, 0.4),
            (0.4, 0.5),
            (0.5, 0.6),
            (0.6, 0.7),
            (0.7, 0.8),
            (0.8, 0.9),
            (0.9, 1.0),]
    initial_u = [0.25] * len(grid)
    shooter = MultipleShooter(m, initial_u, grid)
    p0 = shooter.get_p0()
    
    if certainindex is not None:
        indices = [certainindex]
    else:
        indices = range(len(p0))
    
    for index in indices:
        fig = p.figure()
        evaluator = _PartialEvaluator(shooter.f, shooter.df, p0, index)
        p.suptitle('Partial derivative test (of gradient elements, index=%s)' % index)
        _verify_gradient(evaluator.f, evaluator.df, -10, 10)
        fig.savefig('test_f_gradient_elements_%s.png' % index)
        fig.savefig('test_f_gradient_elements_%s.eps' % index)


def test_f_gradient_element_29():
    """Testing part. diff. which corresponds to element 29 in grad(f) in VDP.
    
    This was a failing test in test_f_gradient_elements(None) which is the
    reason why I'm adding it here.
    """
    test_f_gradient_elements(29)


def _split_opt_x(model, gridsize, p):
    ys = p[0 : gridsize * model.getModelSize()]
    ys = ys.reshape( (gridsize, model.getModelSize()) )
    us = p[gridsize * model.getModelSize() : ]
    us = us.reshape( (gridsize, len(model.getInputs())) ) # Assumes only one input signal
    return ys, us
    

def _plot_control_solution(model, interval, initial_ys, us):
    model.reset()
    model.setStates(initial_ys)
    model.setInputs(us)
    
    T, Y, yS, parameters = solve_using_sundials(model, end_time=interval[1], start_time=interval[0])
    p.plot(T,Y[:,2])
    return T, Y


def plot_control_solutions(model, grid, x, doshow=True):
    initial_ys, us = _split_opt_x(model, len(grid), x)
    
    #p.figure()
    p.hold(True)
    solutions = map(_plot_control_solution, [model]*len(grid), grid, initial_ys, us)
    p.hold(False)
    p.title('The shooting solution')
    if doshow:
        p.show()


def test_plot_control_solutions():
    """ Testing plot_control_solutions(...)"""
    m = _load_example_standard_model('VDP_pack_VDP_Opt')
    m.reset()
    grid = [(0, 0.1),
            (0.1, 0.2),
            (0.2, 0.3),
            (0.3, 0.4),
            (0.4, 0.5),
            (0.5, 0.6),
            (0.6, 0.7),
            (0.7, 0.8),
            (0.8, 0.9),
            (0.9, 1.0),]
    grid = N.array(grid) * (m.getFinalTime() - m.getStartTime()) + m.getStartTime()        
            
    # Used to be: N.array([1, 1, 1, 1]*len(grid))        
    us = [  0.00000000e+00,  1.00000000e+00,  0.00000000e+00, -1.86750972e+00,
           -1.19613740e+00,  3.21955502e+01,  1.15871750e+00, -9.56876370e-01,
            7.82651050e+01, -3.35655693e-01,  1.95491165e+00,  1.47923425e+02,
           -2.32963068e+00, -1.65371763e-01,  1.94340923e+02,  6.82953492e-01,
           -1.57360749e+00,  2.66717232e+02,  1.46549806e+00,  1.74702679e+00,
            3.29995167e+02, -1.19712096e+00,  9.57726717e-01,  3.80947471e+02,
            3.54379487e-01, -1.95842811e+00,  4.52105868e+02,  2.34170339e+00,
            1.77754406e-01,  4.98700011e+02,  2.50000000e-01,  2.50000000e-01,
            2.50000000e-01,  2.50000000e-01,  2.50000000e-01,  1.36333570e-01,
            2.50000000e-01,  2.50000000e-01,  2.50000000e-01,  2.50000000e-01]
    us = N.array(us)
    plot_control_solutions(m, grid, us, doshow=False)


def test_control_solution_variations():
    """Test different variations of control solutions."""
    m = _load_example_standard_model('VDP_pack_VDP_Opt')
    m.reset()
    grid = [(0, 0.1),
            (0.1, 0.2),
            (0.2, 0.3),
            (0.3, 0.4),
            (0.4, 0.5),
            (0.5, 0.6),
            (0.6, 0.7),
            (0.7, 0.8),
            (0.8, 0.9),
            (0.9, 1.0),]
    grid = N.array(grid) * (m.getFinalTime() - m.getStartTime()) + m.getStartTime()    
            
    for u in [-0.5, -0.25, 0, 0.25, 0.5]:
        print "u:", u
        us = [  0.00000000e+00,  1.00000000e+00,  0.00000000e+00, -1.86750972e+00,
                   -1.19613740e+00,  3.21955502e+01,  1.15871750e+00, -9.56876370e-01,
                    7.82651050e+01, -3.35655693e-01,  1.95491165e+00,  1.47923425e+02,
                   -2.32963068e+00, -1.65371763e-01,  1.94340923e+02,  6.82953492e-01,
                   -1.57360749e+00,  2.66717232e+02,  1.46549806e+00,  1.74702679e+00,
                    3.29995167e+02, -1.19712096e+00,  9.57726717e-01,  3.80947471e+02,
                    3.54379487e-01, -1.95842811e+00,  4.52105868e+02,  2.34170339e+00,
                    1.77754406e-01,  4.98700011e+02] + [u] * 10
        us = N.array(us)
        plot_control_solutions(m, grid, us, doshow=False)
        
        import time
        time.sleep(3)


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
        model._m.setX_P(ys[-1], 0)
        model._m.setDX_P(model.getDiffs(), 0)
        model._m.setU_P(model.getInputs(), 0)
        
        cost = model.evalCost()
        print "Cost:", cost
        
        # Saved for plotting
        costs.append(cost)
        Us.append(u_elmnt)
        
        cost_jac = model.getCostJacobian(pyjmi.JMI_DER_X_P)
    
    p.subplot('121')
    p.plot(Us, costs)
    p.title("Costs as a function of different constant Us (VDP model)")
    
    from scipy import convolve
    p.subplot('122')
    dUs = Us
    dcost = convolve(costs, N.array([1, -1])/0.02)[0:-1]
    assert len(dUs) == len(dcost)
    p.plot(dUs, dcost)
    p.title('Forward derivatives')
    
    p.show()


def main():
    m = _load_example_standard_model('VDP_pack_VDP_Opt', "VDP.mo", "VDP_pack.VDP_Opt")
    
    # Whether the cost as a function of input U should be plotted
    GEN_PLOT = False
    
    if GEN_PLOT:
        cost_graph(m)
    else:
        SHOOTING_METHOD = 'multiple'
        if SHOOTING_METHOD=='single':
            opt_u = single_shooting(m)
            print "Optimal u:", opt_u
        elif SHOOTING_METHOD == 'multiple':
            grid = [(0, 0.1),
                    (0.1, 0.2),
                    (0.2, 0.3),
                    (0.3, 0.4),
                    (0.4, 0.5),
                    (0.5, 0.6),
                    (0.6, 0.7),
                    (0.7, 0.8),
                    (0.8, 0.9),
                    (0.9, 1.0),]
            initial_u = [0.25] * len(grid)
            shooter = MultipleShooter(m, initial_u, grid)
            #optimum = shooter.runQuasiNewtonsMethod()
            #optimum = shooter.runSteepestDescent()
            optimum = shooter.runOptimization()
            print "Optimal us:", optimum
        


if __name__ == "__main__":
    main()

