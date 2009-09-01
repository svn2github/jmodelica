#!/usr/bin/python
# -*- coding: utf-8 -*-
"""Implements single and multiple shooting.

"""

import ctypes
import math
import os
import sys

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
    """Get the absolute path to the examples directory.
    
    """
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, 'Python', 'jmodelica', 'examples', 'files')
    
    
def _load_model(libname, path, mofile=None, optpackage=None):
    """Load and return a JmiOptModel from DLL file residing in path.
    
    If the DLL file does not exist this method tries to build it if mofile and
    optpackage are specified.
    
    Keyword parameters:
    mofile -- the Modelica file used to build the DLL file.
    optpackage -- the Optimica package in the mofile which is to be compiled.
    
    """
    try:
        model = JmiOptModel(libname, path)
    except IOError:
        if mofile is None or optpackage is None:
            raise
            
        print "The model was not found. Trying to compile it..."
        from jmodelica.compiler import OptimicaCompiler
        curdir = os.getcwd()
        os.chdir(path)
        oc = OptimicaCompiler()
        oc.compile_model(os.path.join(path, mofile), optpackage)
        os.chdir(curdir)
        model = JmiOptModel(libname,'./')
        
    return model
    
    
def _load_example_standard_model(libname, mofile=None, optpackage=None):
    """Load and return a JmiOptModel from DLL file residing in the example
       path.
        
    If the DLL file does not exist this method tries to build it if mofile and
    optpackage are specified.
    
    Keyword parameters:
    mofile -- the Modelica file used to build the DLL file.
    optpackage -- the Optimica package in the mofile which is to be compiled.
    
    """
    return _load_model(libname, _get_example_path(), mofile, optpackage)


class OptModel:
    """An abstract model on which optimization is done on.
    
    Contains the common functions used to make this class behave as a DAE/ODE
    model.
    
    """
    def getParameters(self):
        """Getter for the model parameters."""
        raise NotImplementedError()
        
    def setParameters(self, params):
        """Setter for the model parameters."""
        raise NotImplementedError()
        
    def getStates(self):
        """Getter for the model states."""
        raise NotImplementedError()
        
    def setStates(self, x):
        """Setter for the model states."""
        raise NotImplementedError()
        
    def getDiffs(self):
        """Getter for the derivatives.
        
        They are evaluated using self.evalF().
        """
        raise NotImplementedError()
        
    def getModelSize(self):
        """Returns the dimension of the problem."""
        return len(self.getStates())
        
    def getRealModelSize(self):
        """Returns the dimension of the problem. 
                
        In my master thesis code base there exists a class called
        GenericSensivityModel that wraps an existing model creating a pseudo
        problem that solves multiple disturbed instances of this model to be
        able to approximate sensitivities in a different approach than using
        SUNDIALS. This method came into existence to be able to know the size
        of the original problem/model.
        """
        return self.getModelSize()
        
    def evalF(self):
        """Evaluate F.
        
        This evaluation sets the differentials that can be gotten by calling
        the getter self.getDiffs().
        """
        raise NotImplementedError()
        
    def evalJacX(self):
        """Evaluate the jacobian of the function F w.r.t. states x. """
        raise NotImplementedError()
        
    def getSensitivities(self, y):
        """Not supported in this model class.
        
        This method came existence due to GenericSensivityModel that exists in
        my master thesis code base. See remark on ::self.getRealModelSize() for
        more information why this method exists.
        """
        raise NotImplementedError('This model does not support'
                                  ' sensitivity analysis implicitly.')
                                   
    def getInputs(self):
        """Getter for the input/control signal."""
        raise NotImplementedError()
        
    def setInputs(self, new_u):
        """Setter for the input/control signal."""
        raise NotImplementedError()
        
    def setTime(self, new_t):
        """Setter for time the variable t."""
        raise NotImplementedError()
        
    def getTime(self):
        """Getter for time the variable t."""
        raise NotImplementedError()
        
    def evalCost(self):
        """Evaluate the optimization cost function, J."""
        raise NotImplementedError()
        
    def isFreeStartTime(self):
        """Returns True if the start time is free, False otherwise."""
        raise NotImplementedError()
        
    def isFreeFinalTime(self):
        """Returns True if the end time is free, False otherwise."""
        raise NotImplementedError()
        
    def isFixedStartTime(self):
        """Returns False if the start time is free, True otherwise."""
        return not self.isFreeStartTime()
        
    def isFixedFinalTime(self):
        """Returns False if the end time is free, True otherwise."""
        return not self.isFreeFinalTime()
        
    def getStartTime(self):
        """Returns the start time for the simulation."""
        raise NotImplementedError()
        
    def getFinalTime(self):
        """Returns the end time for the simulation."""
        raise NotImplementedError()
        
    def getCostJacobian(self, independent_variables, mask=None):
        """ Returns a partial jacobian of the cost function.
        
        Returns the partial jacobian of the cost function with respect to the
        independent variables independent_variable (JMI_DER_X etc.).
        
        Todo:
        independent_variable should not be a mask. It is not the pythonesque
        way to do it.
        """
        raise NotImplementedError()
        
    def reset(self):
        """Reset everything in the model the it looks reloaded."""
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
    
    See method doctypes for OptModel for method documentation.
    """
    def __init__(self):
        self.reset()
        
    def reset(self):
        self._params = N.array([3], dtype=pyjmi.c_jmi_real_t)
        self._time = 0
        self._xdiffs = N.array([1, 3, 0], dtype=pyjmi.c_jmi_real_t)
        self._x = N.array([0, 0, 0], dtype=pyjmi.c_jmi_real_t)
    
    def getParameters(self):
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
        """Evaluate F:
        
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
        raise NotImplementedError()
                                   
    def getInputs(self):
        return N.array([])
        
    def setInputs(self, new_u):
        inputs = self.getInputs()
        inputs[:] = new_u
        
    def setTime(self, new_t):
        self._time = new_t
        
    def getTime(self):
        return self._time
        
    def evalCost(self):
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
        raise NotImplementedError()


class TestDebugOptModel:
    """Tests for the _DebugOptModel class.
    
    Using the non-Modelica model _DebugOptModel makes it possible to verify
    numerical solutions.
    """
    
    def setUp(self):
        """Test setUp. Load the test model"""
        self.m = _DebugOptModel()
        
    def testModelSize(self):
        """Test _DebugOptModel.getModelSize()"""
        size = self.m.getModelSize()
        nose.tools.assert_equal(size, 3)
        
    def testRealModelSize(self):
        """Test _DebugOptModel.getRealModelSize()."""
        size = self.m.getRealModelSize()
        nose.tools.assert_equal(size, 3)
        
    def testStatesGetSet(self):
        """Test _DebugOptModel.setStates(...) and _DebugOptModel.getStates()"""
        new_states = [1.74, 3.38, 12.45]
        reset = [0, 0, 0]
        self.m.setStates(reset)
        states = self.m.getStates()
        N.testing.assert_array_almost_equal(reset, states)
        self.m.setStates(new_states)
        states = self.m.getStates()
        N.testing.assert_array_almost_equal(new_states, states)
        
    def testDiffs(self):
        """Test _DebugOptModel.setDiffs(...) and _DebugOptModel.getDiffs()"""
        reset = [0, 0, 0]
        diffs = self.m.getDiffs()
        diffs[:] = reset
        diffs2 = self.m.getDiffs()
        N.testing.assert_array_almost_equal(reset, diffs2)
        
        new_diffs = [1.54, 3.88, 45.87]
        diffs[:] = new_diffs
        N.testing.assert_array_almost_equal(new_diffs, diffs2)
        
    def testInputs(self):
        """Test _DebugOptModel.setInputs(...) and _DebugOptModel.getInputs()"""
        new_inputs = []
        reset = []
        self.m.setInputs(reset)
        inputs = self.m.getInputs()
        N.testing.assert_array_almost_equal(reset, inputs)
        self.m.setInputs(new_inputs)
        inputs = self.m.getInputs()
        N.testing.assert_array_almost_equal(new_inputs, inputs)
        
    def testParameters(self):
        """Test _DebugOptModel.setParameters(...) and
           _DebugOptModel.getParameters()
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
        """Test _DebugOptModel.setTime(...) and _DebugOptModel.getTime()"""
        new_time = 0.47
        reset = 0
        self.m.setTime(reset)
        t = self.m.getTime()
        nose.tools.assert_almost_equal(reset, t)
        self.m.setTime(new_time)
        t = self.m.getTime()
        nose.tools.assert_almost_equal(new_time, t)
        
    def testEvaluation(self):
        """Test _DebugOptModel.evalF()"""
        self.m.evalF()
        
    def testSimulationWSensivity(self, SMALL=0.3):
        """Testing simulation sensivity of _DebugOptModel."""
        
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
        """Test simulation of _DebugOptModel"""
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
        """Test simulation between a different time span of _DebugOptModel."""
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
        """Testing resetting the _DebugOptModel model"""
        self.m.reset()


class JmiOptModel(OptModel):
    """A Optimica/Modelica optimization model.
    
    Contains the common functions used to make this class behave as a DAE/ODE
    model paired with an optimization problem.
    
    See method doctypes for OptModel for method documentation.
    
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
        self._m.jmimodel.ode_f()
        
    def evalJacX(self):
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
    """Test the JmiOptModel instance of the Van der Pol oscillator."""
    
    def setUp(self):
        """Test setUp. Load the test model."""
        self.m = _load_example_standard_model('VDP_pack_VDP_Opt','VDP.mo','VDP_pack.VDP_Opt')
        
    def testModelSize(self):
        """Test JmiOptModel.getModelSize()"""
        size = self.m.getModelSize()
        nose.tools.assert_equal(size, 3)
        
    def testRealModelSize(self):
        """Test JmiOptModel.getRealModelSize()."""
        size = self.m.getRealModelSize()
        nose.tools.assert_equal(size, 3)
        
    def testStatesGetSet(self):
        """Test JmiOptModel.setStates(...) and JmiOptModel.getStates()"""
        new_states = [1.74, 3.38, 12.45]
        reset = [0, 0, 0]
        self.m.setStates(reset)
        states = self.m.getStates()
        N.testing.assert_array_almost_equal(reset, states)
        self.m.setStates(new_states)
        states = self.m.getStates()
        N.testing.assert_array_almost_equal(new_states, states)
        
    def testDiffs(self):
        """Test JmiOptModel.setDiffs(...) and JmiOptModel.getDiffs()"""
        reset = [0, 0, 0]
        diffs = self.m.getDiffs()
        diffs[:] = reset
        diffs2 = self.m.getDiffs()
        N.testing.assert_array_almost_equal(reset, diffs2)
        
        new_diffs = [1.54, 3.88, 45.87]
        diffs[:] = new_diffs
        N.testing.assert_array_almost_equal(new_diffs, diffs2)
        
    def testInputs(self):
        """Test JmiOptModel.setInputs(...) and JmiOptModel.getInputs()"""
        new_inputs = [1.54]
        reset = [0]
        self.m.setInputs(reset)
        inputs = self.m.getInputs()
        N.testing.assert_array_almost_equal(reset, inputs)
        self.m.setInputs(new_inputs)
        inputs = self.m.getInputs()
        N.testing.assert_array_almost_equal(new_inputs, inputs)
        
    def testParameters(self):
        """Test JmiOptModel.setParameters(...) and JmiOptModel.getParameters()
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
        """Test JmiOptModel.setTime(...) and JmiOptModel.getTime()"""
        new_time = 0.47
        reset = 0
        self.m.setTime(reset)
        t = self.m.getTime()
        nose.tools.assert_almost_equal(reset, t)
        self.m.setTime(new_time)
        t = self.m.getTime()
        nose.tools.assert_almost_equal(new_time, t)
        
    def testEvaluation(self):
        """Test JmiOptModel.evalF() of JmiOptModel."""
        self.m.evalF()
        
    def testSimulationWSensivity(self, SMALL=0.3):
        """Testing simulation sensivity of JmiOptModel."""
        
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
        """Test simulation of JmiOptModel without plotting.
        
        No plotting is done to compare times against
        self.testFixedSimulationReturnLast().
        """
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed times supported."
        
        self.m.reset()
        self.m.setInputs([0.25])
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        assert len(T) == len(ys)
        
    def testFixedSimulationReturnLast(self):
        """Test simulation of JmiOptModel without plotting.
        
        No plotting is done to compare times against
        self.testFixedSimulation().
        """
        assert self.m.isFixedStartTime(), "Only fixed times supported."
        assert self.m.isFixedFinalTime(), "Only fixed times supported."
        
        self.m.reset()
        self.m.setInputs([0.25])
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime(), return_last=True)
        assert len(ys) > 0
        assert T is not None
        
        
    def testFixedSimulationWithPlot(self):
        """Test simulation of JmiOptModel with result plotting."""
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
        """Test simulation between a different time span of JmiOptModel."""
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
        """ Testing the number of non-zero elements in VDP (JmiOptModel) after
            simulation.
        
        Note:
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
        """Test evaluation of optimization cost function."""
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m._m.setX_P(ys[-1], 0)
        self.m._m.setDX_P(self.m.getDiffs(), 0)
        cost = self.m.evalCost()
        nose.tools.assert_not_equal(cost, 0)
        
    def testOptimizationCostJacobian(self):
        """Test evaluation of optimization cost function jacobian.
        
        Note:
        This test is model specific for the VDP oscillator.
        """
        T, ys, sens, ignore = solve_using_sundials(self.m, self.m.getFinalTime(), self.m.getStartTime())
        self.m._m.setX_P(ys[-1], 0)
        self.m._m.setDX_P(self.m.getDiffs(), 0)
        jac = self.m.getCostJacobian(pyjmi.JMI_DER_X_P)
        N.testing.assert_almost_equal(jac, [[0, 0, 1]])
        
    def testReset(self):
        """Testing resetting the JmiOptModel model."""
        self.m.reset()


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
    print "Input innan integration:", model.getInputs()
    print "States:", model.getStates()
    print start_time, "to", end_time
    
    import sys
    sys.stdout.flush()
    
    if end_time < start_time:
        raise ShootingException('End time cannot be before start time.')
    if end_time == start_time:
        raise ShootingException('End time and start time cannot currently coinside.')
        
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
    if tout>end_time:
        tout=end_time

    # initial time
    t = cvodes.realtype(t0.value)

    # used for collecting the y's for plotting
    if return_last==False:
        T, ylist = [t0.value], [model.getStates().copy()]
    
    
    while True:
        # run ODE solver
        flag = cvodes.CVode(cvode_mem, tout, y, ctypes.byref(t), cvodes.CV_NORMAL)

        if verbose:
            print "At t = %-14.4e  y =" % t.value, \
                  ("  %-11.6e  "*len(y)) % tuple(y)

        """Used for return."""
        if return_last==False:
            T.append(t.value)
            ylist.append(N.array(y))
            
        if N.abs(tout-end_time)<=1e-6:
            break

        if flag == cvodes.CV_SUCCESS:
            tout += time_step

        if tout>end_time:
            tout=end_time

            
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
    
    if return_last:
        ylist = N.array(y).copy()
        T = t.value
    else:
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


def _shoot(model, start_time, end_time, sensi=True, time_step=0.2):
    """Performs a single 'shot' (simulation) from start_time to end_time.
    
    Model parameters/states etc. must be set BEFORE calling this method.
    
    The function returns a tuple consisting of:
        1. The cost gradient with respect to initial states and
           input U.
        2. The final ($t_{tp_0}=1$) simulation states.
        3. A dictionary holding the indices for the gradient.
        4. The corresponding sensitivity matrix (if sensi is not False)
    
    if sensi is set to False no sensitivity analysis will be done and the 
    
    Parameters:
    model      -- the model which is to be used in the shot (simulation).
    start_time -- the time when simulation should start.
    end_time   -- the time when the simulation should finish.
    
    Keyword parameters:
    sensi     -- True/False, if sensivity is to be conducted. (default=True)
    time_step -- the time_step to be taken within the integration code.
                 (default=0.2)
        
    Notes:
     * Assumes cost function is only dependent on state X and control signal U.
    
    """
    
    T, last_y, sens, params = solve_using_sundials(model,
                                                   end_time,
                                                   start_time,
                                                   sensi=sensi,
                                                   time_step=time_step,
                                                   return_last=True)
    
    model._m.setX_P(last_y, 0)
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
    
    # TODO: Create a return type instead of returning tuples
    return costgradient, last_y, gradparams, sens_mini


def single_shooting(model, initial_u=0.4, GRADIENT_THRESHOLD=0.0001):
    """Run single shooting of model model with a constant u.
    
    The function returns the optimal u.
    
    Notes:
     * Currently written specifically for VDP.
     * Currently only supports inputs.
    
    Parameters:
    model -- the model which is to be simulated. Only models with one control
             signal is supported.
             
    Keyword parameters:
    initial_u -- the initial input U_0 used to initialize the optimization
                 with.
    GRADIENT_THRESHOLD -- the threshold in when the inf norm of two different
                          gradients should consider two gradients same or
                          different.
    
    """
    start_time = model.getStartTime()
    end_time = model.getFinalTime()
    
    u = model.getInputs()
    u0 = N.array([0.4])
    print "Initial u:", u
    
    gradient = None
    gradient_u = None
    
    def f(cur_u):
        """The cost evaluation function."""
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
        """The gradient of the cost function.
        
        NOT USED right now.
        """
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
    return u_opt.xf


def _eval_initial_ys(model, grid, time_step=0.2):
    """Generate a feasible initial guesstimate of the initial states for each
       segment in a grid.
       
    This is done by doing a simulation from start to end and extracting the
    states at the time points between the segments specified in the grid.
    
    Parameters:
    model -- the model which is to be simulated.
    grid  -- the segment grid list. Each element in grid corresponds to a
             segment and contains a tupleconsisting of start and end time of
             that segment.
    
    Keyword parameters:
    time_step -- the time step size used in the integration.
    
    """
    # TODO: Move this to MultipleShooter
    from scipy import interpolate
    _check_grid_consistency(grid)
    
    T, ys, sens, params = solve_using_sundials(model, model.getFinalTime(), model.getStartTime(), time_step=time_step)
    T = N.array(T)
    
    tck = interpolate.interp1d(T, ys, axis=0)
    initials = map(lambda interval: tck(interval[0]).flatten(), grid)
    initials = N.array(initials).flatten()
    return initials
    

def _check_normgrid_consistency(normgrid):
    """Check normalized grid input parameter for errors.
    
    Raises ShootingException on error.
    
    By normalized it means the times are from 0 to 1.
    """
    # TODO: Move this to MultipleShooter
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
        
        Parameters:
        model     -- the model to simulate/optimize over.
        initial_u -- a list of initial inputs for each segment. If not a list,
                     it is assumed to be the same initial input for each
                     segment.
        
        Keyword parameters:
        normgrid --
            A list of 2-tuples per segment. The first element in each tuple
            being the segment start time, the second element the segment end
            time. The grid must hold normalized values.
        initial_y --
            Can be three things:
             * A list of initial states for all grids. If any of these are
               None they will be replaced by the default model state.
             * None -- using the solution from the default model state.
             * A list of initial states for each segment except the first one.
               If not a list the same initial state will be used for each
               segment.
               
        Note:
        Any states set in the model will be reset when initializing this class
        with with that model.
        """
        self.set_model(model)
        self.set_normalized_grid(normgrid)
        self.set_time_step()
        self.set_initial_u(initial_u)
        self.set_initial_y(initial_y)
        
    def set_time_step(self, time_step=0.2):
        """The step length when the integrator should return."""
        self._time_step = time_step
        
    def get_time_step(self):
        return self._time_step
        
    def set_model(self, model):
        """Set the OptModel model.
        
        Note:
        Any states set in the model will be reset when initializing this class
        with with that model.
        """
        model.reset()
        self._m = model
        
    def get_model(self):
        """Get the OptModel model."""
        return self._m    
        
    def set_initial_u(self, initial_u):
        """ Set the initial U's (control signals) for each segment."""
        grid = self.get_grid()
        model = self.get_model()
        if len(initial_u) != len(grid):
            raise ShootingException('initial_u parameters must be the same length as grid segments.')
        self._initial_u = N.array(initial_u).reshape( (len(grid), len(model.getInputs())) )
        
        # Assume the first initial_u is a feasible one
        model.setInputs(self._initial_u[0])
        
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
            initial_y = _eval_initial_ys(model, grid, time_step=self.get_time_step())
        elif len(initial_y) != len(grid):
            raise ShootingException('initial_y states must be the same length as grid segments.')
        self._initial_y = N.array(initial_y).reshape( (len(grid), self.get_model().getModelSize()) )
        
    def get_initial_y(self):
        """Returns the initial states, one segment per row."""
        return self._initial_y[1:]
        
    def get_initial_y_grid0(self):
        """Returns the initial states for the first grid."""
        return self._initial_y[0]
        
    def set_normalized_grid(self, grid):
        """Set the grid containing normalized times (between [0, 1]).
        
        The method also checks for inconsistencies in the grid.
        
        Each element in grid corresponds to a segment and contains a tuple
        consisting of start and end time of that segment.
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
        
        Each element in grid corresponds to a segment and contains a tuple
        consisting of start and end time of that segment.
        """
        _check_grid_consistency(grid)
        
        self._grid = grid
        
    def get_grid(self):
        """Returned the real grid holding the actual simulation times."""
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
        
        seg_cost_gradient, seg_last_y, seg_gradparams, sens = _shoot(model, seg_start_time, seg_end_time, sensi=sensi, time_step=self.get_time_step())
        
        # TODO: Create a return type instead of returning tuples
        return seg_cost_gradient, seg_last_y, seg_gradparams, sens
    
    def f(self, p):
        """Returns the evaluated cost function w.r.t. the vector 'p'.
        
        'p'is a concatenation of initial states (excluding the first segment) 
        and parameters. See _split_opt_x(...) for details.
        """
        model = self.get_model()
        grid = self.get_grid()
        ys, us = _split_opt_x(model, len(grid), p, self.get_initial_y_grid0())
        
        print "p:", p
        
        costgradient, last_y, gradparams, sens = self._shoot_single_segment(us[-1], ys[-1], grid[-1], sensi=False)
        
        model._m.setX_P(last_y, 0)
        model._m.setDX_P(model.getDiffs(), 0)
        model._m.setU_P(model.getInputs(), 0)
        cost = model.evalCost()
        
        print "Evaluating cost:", cost
        print "Evaluating cost: (u, y, grid) = ", us[-1], ys[-1], grid[-1]
        
        return cost
        
    def df(self, p):
        """Returns the evaluated gradient of the cost function w.r.t.
           the vector 'p'.
        
        'p'is a concatenation of initial states (excluding the first segment) 
        and parameters. See _split_opt_x(...) for details.
        """
        model = self.get_model()
        grid = self.get_grid()
        ys, us = _split_opt_x(model, len(grid), p, self.get_initial_y_grid0())
        costgradient, last_y, gradparams, sens = self._shoot_single_segment(us[-1], ys[-1], grid[-1])
        
        print "Evaluating cost function gradient."
        
        if len(grid) == 1:
            gradient = N.array(costgradient[gradparams['u_start'] : gradparams['u_end']])
        else:
            # Comments:
            #  * The cost does not depend on the first initial states.
            #  * The cost does not depend on the first inputs/control signal
            gradient = N.array([0] * len(model.getStates()) * (len(grid) - 2)
                                + list(costgradient[gradparams['xinit_start'] : gradparams['xinit_end']])
                                + [0] * (len(grid) - 1) * len(model.getInputs())
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
        y0s, us = _split_opt_x(model, len(grid), p, self.get_initial_y_grid0())
        
        def eval_last_ys(u, y0, interval):
            grad, last_y, gradparams, sens = self._shoot_single_segment(u, y0, interval)
            return last_y
        last_ys = N.array(map(eval_last_ys, us[:-1], y0s[:-1], grid[:-1]))
        
        print "Evaluating equality contraints:", (last_ys - y0s[1:])
        
        return (last_ys - y0s[1:])
        
    def dh(self, p):
        """Evaluates the jacobian of self.h(p).
        
        This function currently assumes the multiple shooting being conducted
        cannot vary the initial states with respect to the first segment.
        """
        print "Evaluating equality contraints gradient."
        
        model = self.get_model()
        grid = self.get_grid()
        y0s, us = _split_opt_x(model, len(grid), p, self.get_initial_y_grid0())
        
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
            xinitsenscols_start = (segmentindex - 1) * NOS
            xinitsenscols_end = xinitsenscols_start + NOS
            xinitcols_start = segmentindex * NOS
            xinitcols_end = xinitcols_start + NOS
            usenscols_start = (y0s.size - NOS) + NOI * segmentindex
            usenscols_end = usenscols_start + NOI
            
            # Indices from the sensivity matrix
            sensxinitindices = range(gradparams[segmentindex]['xinit_start'], gradparams[segmentindex]['xinit_end'])
            sensuindices = range(gradparams[segmentindex]['u_start'], gradparams[segmentindex]['u_end'])
            
            if segmentindex != 0:
                # The initial states of first segment is locked.
                r[row_start : row_end, xinitsenscols_start : xinitsenscols_end] = sens[segmentindex][sensxinitindices, :].T
            r[row_start : row_end, xinitcols_start : xinitcols_end] = -N.eye(model.getModelSize())
            r[row_start : row_end, usenscols_start : usenscols_end] = sens[segmentindex][sensuindices, :].T
        
        #N.set_printoptions(N.nan)
        #print "dh(p):"
        #print r
        
        return r
        
    def get_p0(self):
        """Returns the initial p-vector which is to optimized over.
        
        The vector is constructed based on self.get_initial_y() and
        self.get_initial_u(). See _split_opt_x(...) for details.
        """
        initial_y = self.get_initial_y()
        initial_u = self.get_initial_u()
        p0 = N.concatenate( (N.array(initial_y).flatten(), N.array(initial_u).flatten()) )
        return p0
        
    def check_gradients():
        """Verify that gradients looks correct.
        
        This function indirectly uses the built in OpenOPT gradient
        verification feature which compares finite different quotients with the
        gives gradient evaluation function.
        """
        self.runOptimization(plot=False, _only_check_gradients=True)
        
    def runOptimization(self, plot=True, _only_check_gradients=False):
        """Start/run optimization procedure and the optimum unless.
        
        Set the keyword parameter 'plot' to False (default=True) if plotting
        should not be conducted.
        """
        grid = self.get_grid()
        model = self.get_model()
        
        # Initial try
        p0 = self.get_p0()

        # Less than (-0.5 < u < 1)
        # TODO: These are currently hard coded. They shouldn't be.
        #NLT = len(grid) * len(model.getInputs())
        #Alt = N.zeros( (NLT, len(p0)) )
        #Alt[:, (len(grid) - 1) * model.getModelSize():] = -N.eye(len(grid) * len(model.getInputs()))
        #blt = -0.5*N.ones(NLT)

        N_xvars = (len(grid) - 1) * model.getModelSize()
        N_uvars = len(grid) * len(model.getInputs())
        N_vars = N_xvars + N_uvars
        Alt = -N.eye(N_vars)
        blt = N.zeros(N_vars)
        blt[0:N_xvars] = -N.ones(N_xvars)*0.001
        blt[N_xvars:] = -N.ones(N_uvars)*1;
        
        # Get OpenOPT handler
        p = NLP(self.f,
                p0,
                maxIter = 1e3,
                maxFunEvals = 1e3,
                A=Alt,
                b=blt,
                df=self.df,
                ftol = 1e-4,
                xtol = 1e-4,
                contol=1e-4)
        if len(grid) > 1:
            p.h  = self.h
            p.dh = self.dh
        
        if plot:
            p.plot = 1
        p.iprint = 1
        
        if _only_check_gradients:
            # Check gradients against finite difference quotients
            p.checkdf(maxViolation=0.05)
            p.checkdh()
            return None
        
        #opt = p.solve('ralg') # does not work - serious convergence issues
        opt = p.solve('scipy_slsqp')
        
        if plot:
            plot_control_solutions(model, grid, opt.xf)
        
        return opt.xf
        
        
def _verify_gradient(f, df, xstart, xend, SMALL=0.1, STEPS=100):
    """Output a comparison plot between f.d. quotient and and df.
    
    The plot is written to the current matplotlib figure within the interval
    [xstart, xend] split into STEPS steps. The finite difference quotient has
    an infitesimal equal to SMALL.
    
    This function was written before I knew about the built in OpenOPT gradient
    verification feature. See MultipleShooter.check_gradient().
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
    """Testing _verify_gradient(...)."""
    fig = p.figure()
    f = lambda x: x**2
    df = lambda x: 2*x
    _verify_gradient(f, df, -10, 10)
    fig.savefig('test_verify_gradient.png')
    

class _PartialEvaluator:
    """Evaluator used to evaluate a {f(x): R^n -> R} by setting all variables to
       fixed values except x_{index} which is varied. Thus a new one
       dimensional function is created.
       
    This function is used by test_gradient_elements().
    """
    def __init__(self, g, dg, xbase, index):
        """Constructor.
        
        Parameters:
        g  -- the function g: R^n -> R
        dg -- the gradient of g, namely dg: R^n -> R^n
        xbase -- the x vector used for all x:s except index.
        index -- the index in x vector which is to be varied.
        """
        self._g = g
        self._dg = dg
        self._xbase = xbase
        self._index = index
        
    def f(self, xi):
        """Evaluate the one dimensional function f.
        
        xi is the value if index index in x before evaluating g.
        """
        xvec = self._xbase.copy()
        xvec[self._index] = xi
        return self._g(xvec)
        
    def df(self, x):
        """Returns the index index in the gradient evaluated using xbase except
           xbase[index]=x.
        """
        xvec = self._xbase.copy()
        xvec[self._index] = x
        return self._dg(xvec)[self._index]


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
    
    m = _load_example_standard_model('VDP_pack_VDP_Opt','VDP.mo','VDP_pack.VDP_Opt')
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


def _split_opt_x(model, gridsize, p, prepend_initials):
    """Split a Multiple Shooting optimization array into its segmented parts.
    
    Based on the OptModel model and grid size gridsize _split_opt_x(...) takes
    an optimization vector p and returns tuple (ys, us) where ys is a matrix
    with the initial states, one segment per row. us are the control signals,
    one row per segment.
    """
    ys = N.concatenate( (prepend_initials, p[0 : (gridsize - 1) * model.getModelSize()]) )
    ys = ys.reshape( (gridsize, model.getModelSize()) )
    us = p[(gridsize - 1) * model.getModelSize() : ]
    us = us.reshape( (gridsize, len(model.getInputs())) ) # Assumes only one input signal
    return ys, us
    

def _plot_control_solution(model, interval, initial_ys, us):
    """Plots a single shooting solution.
    
    Parameters:
    model      -- the model to simulate.
    interval   -- a tuple: (start_time, end_time)
    initial_ys -- the initial states at the beginning of the simulation.
    us         -- the constant control signal(s) used throughout the
                  simulation.
    """
    model.reset()
    model.setStates(initial_ys)
    model.setInputs(us)

    p.figure(1)
    p.subplot(211)
    T, Y, yS, parameters = solve_using_sundials(model, end_time=interval[1], start_time=interval[0])
    p.hold(True)
    for i in range(model.getModelSize()):
        p.plot(T,Y[:,i],label="State #%s" % (i + 1), linewidth=2)

    p.subplot(212)
    p.hold(True)
    for i in range(len(model.getInputs())):
        p.plot(interval, [us[i], us[i]], label="Input #%s" % (i + 1))
    p.hold(False)

    return [T,Y,yS]


def plot_control_solutions(model, grid, opt_p, doshow=True):
    """Plot multiple shooting solution.
    
    Parameters:
    model -- the model to be used in the simulation.
    grid  -- the grid to be used.
    p     -- the optimization vector p to be used. See _split_opt_x(...) for
             more info.
    
    Keyword parameters:
    doshow -- set to False if a plot of the solution not should be shown.
              (default=True).
    
    Note:
    The model will be reset when calling this!
    """
    model.reset()
    initial_ys, us = _split_opt_x(model, len(grid), opt_p, model.getStates())
    
    p.figure()
    p.hold(True)
    map(_plot_control_solution, [model]*len(grid), grid, initial_ys, us)
    p.subplot(211); p.title("Solutions (states)")
    p.subplot(212); p.title("Control/input signals")
    p.hold(False)
    if doshow:
        p.show()


def test_plot_control_solutions():
    """Testing plot_control_solutions(...)."""
    m = _load_example_standard_model('VDP_pack_VDP_Opt','VDP.mo','VDP_pack.VDP_Opt')
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
    us = [ -1.86750972e+00,
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
    m = _load_example_standard_model('VDP_pack_VDP_Opt','VDP.mo','VDP_pack.VDP_Opt')
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
        us = [ -1.86750972e+00, -1.19613740e+00, 3.21955502e+01,
                1.15871750e+00, -9.56876370e-01, 7.82651050e+01,
                -3.35655693e-01, 1.95491165e+00, 1.47923425e+02,
                -2.32963068e+00, -1.65371763e-01, 1.94340923e+02,
                6.82953492e-01, -1.57360749e+00, 2.66717232e+02,
                1.46549806e+00, 1.74702679e+00, 3.29995167e+02,
                -1.19712096e+00, 9.57726717e-01, 3.80947471e+02,
                3.54379487e-01, -1.95842811e+00, 4.52105868e+02,
                2.34170339e+00, 1.77754406e-01, 4.98700011e+02] + [u] * 10
        us = N.array(us)
        plot_control_solutions(m, grid, us, doshow=False)
        
        import time
        time.sleep(3)


def cost_graph(model):
    """Plot the cost as a function a constant u (single shooting) based on the
       model model.
    
    This function was mainly used for testing.
    
    Notes:
     * Currently written specifically for VDP.
     * Currently only supports inputs.
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


def construct_grid(n):
    """Construct and return an equally spaced grid with n segments."""
    times = N.linspace(0, 1, n+1)
    return zip(times[:-1], times[1:])


def main(args=sys.argv):
    """The main method.
    
    Uses command line arguments to know what to do. Run
    $ python shooting.py --help
    to see what you can do.
    """
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option('-w', '--what', default='multiple', type='choice',
        metavar="METHOD",
        choices=['multiple', 'single', 'genplot'],
        help="What this script should do. Can be multiple, single or genplot. (default=%default)")
    parser.add_option('-m', '--model', default='VDP_pack.VDP_Opt',
        metavar="MODELNAME",
        help="The optimica model that should be loaded from within the *.mo file. (default=%default)")
    parser.add_option('-D', '--directory', default=_get_example_path(),
        metavar="PATH",
        help="The directory from which to load the *.mo file. (default=%default)")
    parser.add_option('-f', '--modelfile', default='VDP.mo',
        metavar="FILE",
        help="The *.mo file that contains the Optimica optimzation problem description and/or model. (default=%default)")
    parser.add_option('-d', '--dllfile', default='VDP_pack_VDP_Opt',
        metavar="FILE",
        help="The name of the compiled DLL file that contains the compiled model. If this doesn't exist it will be created from the *.mo file. (default=%default)")
    parser.add_option('-t', '--timestep', default=0.2, type="float",
        help="The step size between each integrator return.")
    
    parser.add_option('-u', '--initial-u', dest='initialu', default=2.5,
        type='float', metavar="U",
        help="The initial guess of control/input signal u in optimization. (default=%default)")
    parser.add_option('-g', '--gridsize', dest='gridsize', default=10,
        type='int', metavar="N",
        help="The grid size to use in multiple shooting. (default=%default)")
    
    parser.add_option('-p', '--predefined-model', dest='predmodel', default=None, type='choice', choices=['vdp', 'quadtank'], help="A set of predefined example models. Using one of these will override --modelfile, --directory, --modelfile and --directory.")
    
    (options, args) = parser.parse_args(args=args)
    
    if options.gridsize <= 0:
        raise ShootingException('Grid size must be greater than zero.')
        
    if options.predmodel == 'vdp':
        options.dllfile = 'VDP_pack_VDP_Opt'
        options.model = 'VDP_pack.VDP_Opt'
        options.directory = _get_example_path()
        options.modelfile = 'VDP.mo'
    elif options.predmodel == 'quadtank':
        options.dllfile = 'QuadTank_pack_QuadTank_Opt'
        options.model = 'QuadTank_pack.QuadTank_Opt'
        options.directory = _get_example_path()
        options.modelfile = 'QuadTank.mo'
        options.timestep = 5
    
    m = _load_model(options.dllfile, options.directory, options.modelfile, options.model)
    
    if options.what == 'genplot':
        # Whether the cost as a function of input U should be plotted
        cost_graph(m)
    elif options.what=='single':
        opt_u = single_shooting(m)
        print "Optimal u:", opt_u
        return opt_u
    elif options.what == 'multiple':
        grid = construct_grid(options.gridsize)
        m.setInputs([options.initialu] * len(m.getInputs())) # needed to be able get a reasonable initial
        initial_u = [[options.initialu] * len(m.getInputs())] * options.gridsize
        shooter = MultipleShooter(m, initial_u, grid)
        shooter.set_time_step(options.timestep)
        optimum = shooter.runOptimization()
        print "Optimal p:", optimum
        return optimum
        
    return None


if __name__ == "__main__":
    # The assignment below allows iPython session to reuse the parameter opt
    opt = main(sys.argv[1:])
