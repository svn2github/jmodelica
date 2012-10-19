#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""
Module containing the tests for the FMI interface.
"""

import nose
import os
import numpy as N
import sys as S

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi.fmi import FMUModel, FMUException, FMUModelME1, FMUModelCS1, load_fmu
import pyfmi.fmi_algorithm_drivers as ad
from pyfmi.common.core import get_platform_dir

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

#THIS IS NOW DONE BY FMIL
#@testattr(fmi = True)
#def test_unzip():
#    """
#    This tests the functionality of the method unzip_FMU.
#    """
#    #FMU
#    fmu = 'bouncingBall.fmu'
#   
#    #Unzip FMU
#    tempnames = unzip_fmu(archive=fmu, path=path_to_fmus)
#    binarydir = tempnames['binaries_dir']
#    xmlfile = tempnames['model_desc']
#    
#    platform = get_platform_dir()
#    assert binarydir.endswith(platform)
#    assert xmlfile.endswith('.xml')
#    
#    nose.tools.assert_raises(IOError,unzip_fmu,'Coupled')
    

class Test_load_fmu:
    """
    This test the functionality of load_fmu method.
    """
    
    @testattr(fmi = True)
    def test_raise_exception(self):
        
        nose.tools.assert_raises(FMUException, load_fmu, "test.fmu")
        nose.tools.assert_raises(FMUException, FMUModelCS1, "Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus)
        nose.tools.assert_raises(FMUException, FMUModelME1, "Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus)
    
    @testattr(windows = True)
    def test_correct_loading(self):
        
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus)
        assert isinstance(model, FMUModelME1)
        
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus)
        assert isinstance(model, FMUModelCS1)
        

class Test_FMUModelCS1:
    """
    This class tests pyfmi.fmi.FMUModelCS1
    """
    
    @testattr(windows = True)
    def test_simulation_cs(self):
        
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus)
        res = model.simulate(final_time=1.5)
        assert (res["J1.w"][-1] - 3.245091100366517) < 1e-4
        
    @testattr(windows = True)
    def test_types_platform(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus)
        assert model.types_platform == "standard32"
    
class Test_FMUModelME1:
    """
    This class tests pyfmi.fmi.FMUModelME1
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        depPar1 = compile_fmu("DepParTests.DepPar1",os.path.join(path_to_mofiles,"DepParTests.mo"))
        
    def setUp(self):
        """
        Sets up the test case.
        """
        self._bounce  = load_fmu('bouncingBall.fmu',path_to_fmus)
        self._dq = load_fmu('dq.fmu',path_to_fmus)
        self._bounce.initialize()
        self._dq.initialize()
        self.dep = load_fmu("DepParTests_DepPar1.fmu")
        self.dep.initialize()
    
    @testattr(fmi = True)
    def test_init(self):
        """
        This tests the method __init__.
        """
        pass
        
    @testattr(fmi = True)
    def test_model_types_platfrom(self):
        assert self.dep.model_types_platform == "standard32"
    
    @testattr(fmi = True)
    def test_boolean(self):
        """
        This tests the functionality of setting/getting fmiBoolean.
        """
        
        val = self.dep.get(["b1","b2"])
        
        assert val[0]
        assert not val[1]
        
        assert self.dep.get("b1")
        assert not self.dep.get("b2")
        
        self.dep.set("b1", False)
        assert not self.dep.get("b1")
        
        self.dep.set(["b1","b2"],[True,True])
        assert self.dep.get("b1")
        assert self.dep.get("b2")

    @testattr(fmi = True)
    def test_real(self):
        """
        This tests the functionality of setting/getting fmiReal.
        """
        const = self._bounce.get_real([3,4])
        
        nose.tools.assert_almost_equal(const[0],-9.81000000)
        nose.tools.assert_almost_equal(const[1],0.70000000)
        
        const = self._bounce.get(['der(v)','e'])

        nose.tools.assert_almost_equal(const[0],-9.81000000)
        nose.tools.assert_almost_equal(const[1],0.70000000)
    
        self.dep.set("r[1]",1)
        nose.tools.assert_almost_equal(self.dep.get("r[1]"),1.00000)
    
    @testattr(fmi = True)
    def test_integer(self):
        """
        This tests the functionality of setting/getting fmiInteger.
        """

        val = self.dep.get(["N1","N2"])
        
        assert val[0] == 1
        assert val[1] == 1
        
        assert self.dep.get("N1") == 1
        assert self.dep.get("N2") == 1
        
        self.dep.set("N1", 2)
        assert self.dep.get("N1") == 2
        
        self.dep.set(["N1","N2"],[3,2])
        assert self.dep.get("N1") == 3
        assert self.dep.get("N2") == 2
        
        self.dep.set("N1", 4.0)
        assert self.dep.get("N1")==4
        
    @testattr(fmi = True)    
    def test_string(self):
        """
        This tests the functionality of setting/getting fmiString.
        """
        #Cannot be tested with the current models.
        pass 
    
    @testattr(fmi = True)
    def test_t(self):
        """
        This tests the functionality of setting/getting time.
        """
        
        assert self._bounce.time == 0.0
        assert self._dq.time == 0.0
        
        self._bounce.time = 1.0
        
        assert self._bounce.time == 1.0
        
        nose.tools.assert_raises(TypeError, self._bounce._set_time, N.array([1.0,1.0]))
        
        
    @testattr(fmi = True)
    def test_real_x(self):
        """
        This tests the property of the continuous_states.
        """
        nose.tools.assert_raises(FMUException, self._bounce._set_continuous_states,N.array([1.]))
        nose.tools.assert_raises(FMUException, self._dq._set_continuous_states,N.array([1.0,1.0]))
        
        temp = N.array([2.0,1.0])
        self._bounce.continuous_states = temp
        
        nose.tools.assert_almost_equal(self._bounce.continuous_states[0],temp[0])
        nose.tools.assert_almost_equal(self._bounce.continuous_states[1],temp[1])

        
    @testattr(fmi = True)
    def test_real_dx(self):
        """
        This tests the method get_derivative.
        """
        #Bounce
        real_dx = self._bounce.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], 0.00000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)

        self._bounce.continuous_states = N.array([2.,5.])
        real_dx = self._bounce.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], 5.000000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)
        
        #DQ
        real_dx = self._dq.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], -1.0000000)
        self._dq.continuous_states = N.array([5.])
        real_dx = self._dq.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], -5.0000000)

    @testattr(fmi = True)
    def test_real_x_nominal(self):
        """
        This tests the (get)-property of nominal_continuous_states.
        """
        nominal = self._bounce.nominal_continuous_states
        
        assert nominal[0] == 1.0
        assert nominal[1] == 1.0
        
        nominal = self._dq.nominal_continuous_states
        
        assert nominal[0] == 1.0
    
    @testattr(fmi = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        assert self._bounce._get_version() == '1.0'
        assert self._dq._get_version() == '1.0'
        
    @testattr(fmi = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of model_types_platform
        """
        assert self._bounce.model_types_platform == 'standard32'
        assert self._dq.model_types_platform == 'standard32'
        
    @testattr(fmi = True)
    def test_get_tolerances(self):
        """
        This tests the method get_tolerances.
        """
        [rtol,atol] = self._bounce.get_tolerances()
        
        assert rtol == 0.000001
        nose.tools.assert_almost_equal(atol[0],0.000000010)
        nose.tools.assert_almost_equal(atol[1],0.000000010)
        
        [rtol,atol] = self._dq.get_tolerances()
        
        assert rtol == 0.000001
        nose.tools.assert_almost_equal(atol[0],0.000000010)
        
    @testattr(fmi = True)
    def test_event_indicators(self):
        """
        This tests the method get_event_indicators.
        """
        assert len(self._bounce.get_event_indicators()) == 1
        assert len(self._dq.get_event_indicators()) == 0
        
        event_ind = self._bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],1.0000000000)
        self._bounce.continuous_states = N.array([5.]*2)
        event_ind = self._bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],5.0000000000)
    
    @testattr(fmi = True)
    def test_update_event(self):
        """
        This tests the functionality of the method event_update.
        """
        self._bounce.continuous_states = N.array([1.0,1.0])
        
        self._bounce.event_update()
        
        nose.tools.assert_almost_equal(self._bounce.continuous_states[0],1.0000000000)
        nose.tools.assert_almost_equal(self._bounce.continuous_states[1],-0.7000000000)
        
        self._bounce.event_update()
        
        nose.tools.assert_almost_equal(self._bounce.continuous_states[0],1.0000000000)
        nose.tools.assert_almost_equal(self._bounce.continuous_states[1],0.49000000000)
        
        eInfo = self._bounce.get_event_info()
        
        assert eInfo.nextEventTime == 0.0
        assert eInfo.upcomingTimeEvent == False
        assert eInfo.iterationConverged == True
        assert eInfo.stateValueReferencesChanged == False
        
    @testattr(fmi = True)
    def test_get_continuous_value_references(self):
        """
        This tests the functionality of the method get_state_value_references.
        """
        ref = self._bounce.get_state_value_references()
        
        assert ref[0] == 0
        assert ref[1] == 2
        
        ref = self._dq.get_state_value_references()
        
        assert ref[0] == 0
        
    @testattr(fmi = True)
    def test_ode_get_sizes(self):
        """
        This tests the functionality of the method ode_get_sizes.
        """
        [nCont,nEvent] = self._bounce.get_ode_sizes()
        assert nCont == 2
        assert nEvent == 1
        
        [nCont,nEvent] = self._dq.get_ode_sizes()
        assert nCont == 1
        assert nEvent == 0
    
    @testattr(fmi = True)
    def test_get_name(self):
        """
        This tests the functionality of the method get_name.
        """
        assert self._bounce.get_name() == 'bouncingBall'
        assert self._dq.get_name() == 'dq'
    
    @testattr(fmi = True)
    def test_debug_logging(self):
        """
        This test the attribute debugging.
        """
        model = FMUModelME1('bouncingBall.fmu',path_to_fmus,enable_logging=False)
        model.initialize()
        try:
            model.initialize()
        except FMUException:
            pass
        assert len(model.get_log()) == 0 #Get the current log (empty)
        model = FMUModelME1('bouncingBall.fmu',path_to_fmus,enable_logging=False)
        model.initialize()
        model.set_debug_logging(True) #Activates the logging
        try:
            model.initialize()
        except FMUException:
            pass
        assert len(model.get_log()) > 0 #Get the current log (empty)
        model = FMUModelME1('bouncingBall.fmu',path_to_fmus,enable_logging=True)
        model.initialize()
        try:
            model.initialize()
        except FMUException:
            pass
        assert len(model.get_log()) > 0 #Get the current log (empty)
        
    @testattr(fmi = True)
    def test_get_fmi_options(self):
        """
        Test that simulate_options on an FMU returns the correct options 
        class instance.
        """
        assert isinstance(self._bounce.simulate_options(), ad.AssimuloFMIAlgOptions)
        
    @testattr(fmi = True)
    def test_instantiate_jmu(self):
        """ 
        Test that FMUModel can not be instantiated with a JMU file.
        """
        nose.tools.assert_raises(FMUException,FMUModelME1,'model.jmu')
        
        
class Test_FMI_Compile:
    """
    This class tests pymodelica.compile_fmu compilation functionality.
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        pass
        
    def setUp(self):
        """
        Sets up the test case.
        """
        fpath = os.path.join(path_to_mofiles,'RLC_Circuit.mo')
        fmuname = compile_fmu('RLC_Circuit',fpath)
        
        self._model  = FMUModelME1(fmuname)

    @testattr(fmi = True)
    def test_get_version(self):
        """ Test the version property."""
        nose.tools.assert_equal(self._model.version, "1.0")
        
    @testattr(fmi = True)
    def test_get_model_types_platform(self):
        """ Test the model types platform property. """
        nose.tools.assert_equal(self._model.model_types_platform, "standard32")

    @testattr(fmi = True)
    def test_set_compiler_options(self):
        """ Test compiling with compiler options."""
        libdir = os.path.join(get_files_path(), 'MODELICAPATH_test', 'LibLoc1',
            'LibA')
        co = {"index_reduction":True, "equation_sorting":True,
            "extra_lib_dirs":[libdir]}
        compile_fmu('RLC_Circuit', os.path.join(path_to_mofiles,'RLC_Circuit.mo'),
            compiler_options = co)

class TestDiscreteVariableRefs(object):
    """
    Test that variable references for discrete variables are computed correctly
    """

    def __init__(self):
        self._fpath = os.path.join(get_files_path(), 'Modelica', "DiscreteVar.mo")
        self._cpath = "DiscreteVar"
    
    def setUp(self):
        """
        Sets up the test class.
        """
        self.fmu_name = compile_fmu(self._cpath, self._fpath,compiler_options={'compliance_as_warning':True})
        self.model = FMUModelME1(self.fmu_name)
        
    @testattr(stddist = True)
    def test_vars_model(self):
       """
       Test that the value references are correct
       """
       nose.tools.assert_equal(self.model._save_real_variables_val[0],0)
       nose.tools.assert_equal(self.model._save_real_variables_val[1],2)

class TestDependentParameters(object):
    """
    Test that dependent variables are recomputed when an independent varaible is set.
    """

    def __init__(self):
        self._fpath = os.path.join(get_files_path(), 'Modelica', "DepPar.mo")
        self._cpath = "DepPar.DepPar1"
    
    def setUp(self):
        """
        Sets up the test class.
        """
        self.fmu_name = compile_fmu(self._cpath, self._fpath)
        self.model = FMUModelME1(self.fmu_name)
        
    @testattr(stddist = True)
    def test_parameter_eval(self):
       """
       Test that the parameters are evaluated correctly.
       """
       self.model.set_real([0],2.0)

       p2 = self.model.get_real([1])
       p3 = self.model.get_real([2])

       nose.tools.assert_almost_equal(p2,4)
       nose.tools.assert_almost_equal(p3,12)

