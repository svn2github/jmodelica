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
from pyfmi.fmi import FMUModel, FMUException, FMUModelME1, FMUModelCS1, load_fmu, FMUModelCS2, FMUModelME2, load_fmu2
import pyfmi.fmi_algorithm_drivers as ad
from pyfmi.common.core import get_platform_dir
from pyjmi.log import parse_jmi_log, gather_solves

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_fmus_me1 = os.path.join(path_to_fmus,"ME1.0")
path_to_fmus_cs1 = os.path.join(path_to_fmus,"CS1.0")
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

path_to_fmus_me2 = os.path.join(path_to_fmus,"ME2.0")
path_to_fmus_cs2 = os.path.join(path_to_fmus,"CS2.0")
ME2 = 'bouncingBall2_me.fmu'
CS2 = 'bouncingBall2_cs.fmu'
ME1 = 'bouncingBall.fmu'
CS1 = 'bouncingBall.fmu'
CoupledME2 = 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME2.fmu'
CoupledCS2 = 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS2.fmu'

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
        nose.tools.assert_raises(FMUException, FMUModelCS1, "Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        nose.tools.assert_raises(FMUException, FMUModelME1, "Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)

    @testattr(windows = True)
    def test_correct_loading(self):

        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        assert isinstance(model, FMUModelME1)

        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        assert isinstance(model, FMUModelCS1)


class Test_FMUModelBase:
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        name = compile_fmu("NegatedAlias",os.path.join(path_to_mofiles,"NegatedAlias.mo"))

    def setUp(self):
        """
        Sets up the test case.
        """
        self.negated_alias  = load_fmu('NegatedAlias.fmu')

    @testattr(fmi = True)
    def test_initialize_once(self):
        self.negated_alias.initialize()
        nose.tools.assert_raises(FMUException, self.negated_alias.initialize)

    @testattr(fmi = True)
    def test_set_get_negated_real(self):
        x,y = self.negated_alias.get("x"),self.negated_alias.get("y")
        nose.tools.assert_almost_equal(x,1.0)
        nose.tools.assert_almost_equal(y,-1.0)

        self.negated_alias.set("y",2)

        x,y = self.negated_alias.get("x"),self.negated_alias.get("y")
        nose.tools.assert_almost_equal(x,-2.0)
        nose.tools.assert_almost_equal(y,2.0)

        self.negated_alias.set("x",3)

        x,y = self.negated_alias.get("x"),self.negated_alias.get("y")
        nose.tools.assert_almost_equal(x,3.0)
        nose.tools.assert_almost_equal(y,-3.0)

    @testattr(fmi = True)
    def test_set_get_negated_integer(self):
        x,y = self.negated_alias.get("ix"),self.negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,1.0)
        nose.tools.assert_almost_equal(y,-1.0)

        self.negated_alias.set("iy",2)

        x,y = self.negated_alias.get("ix"),self.negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,-2.0)
        nose.tools.assert_almost_equal(y,2.0)

        self.negated_alias.set("ix",3)

        x,y = self.negated_alias.get("ix"),self.negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,3.0)
        nose.tools.assert_almost_equal(y,-3.0)


class Test_FMUModelCS1:
    """
    This class tests pyfmi.fmi.FMUModelCS1
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        rlc_circuit = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"),target="fmucs")
        rlc_circuit_square = compile_fmu("RLC_Circuit_Square",os.path.join(path_to_mofiles,"RLC_Circuit.mo"),target="fmucs")
        no_state3 = compile_fmu("NoState.Example3",os.path.join(path_to_mofiles,"noState.mo"),target="fmucs")
        simple_input = compile_fmu("Inputs.SimpleInput",os.path.join(path_to_mofiles,"InputTests.mo"),target="fmucs")
        simple_input2 = compile_fmu("Inputs.SimpleInput2",os.path.join(path_to_mofiles,"InputTests.mo"),target="fmucs")
        input_discontinuity = compile_fmu("Inputs.InputDiscontinuity",os.path.join(path_to_mofiles,"InputTests.mo"),target="fmucs")

    def setUp(self):
        """
        Sets up the test case.
        """
        self.rlc  = load_fmu('RLC_Circuit.fmu')
        #self.rlc.initialize()
        self.rlc_square  = load_fmu('RLC_Circuit_Square.fmu')
        self.no_state3 = load_fmu("NoState_Example3.fmu")
        self.simple_input = load_fmu("Inputs_SimpleInput.fmu")
        self.simple_input2 = load_fmu("Inputs_SimpleInput2.fmu")
        self.input_discontinuity = load_fmu("Inputs_InputDiscontinuity.fmu")
        #self.rlc_square.initialize()

    @testattr(stddist = True)
    def test_simulation_no_state(self):
        model = self.no_state3

        #Test CVode
        res = model.simulate(final_time=1.0)
        nose.tools.assert_almost_equal(res.final("x"),1.0)

        #Test Euler
        model.reset()
        model.set("_cs_solver",1)
        res = model.simulate(final_time=1.0)
        nose.tools.assert_almost_equal(res.final("x"),1.0)

    @testattr(stddist = True)
    def test_input_derivatives(self):
        model = self.simple_input

        model.initialize()

        model.set("u", 0.0)
        model.set_input_derivatives("u",2.0, 1)

        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u"),2.0)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),2.0)

        model.set_input_derivatives("u",2.0, 1)
        model.do_step(2, 1)
        nose.tools.assert_almost_equal(model.get("u"),4.0)

    @testattr(stddist = True)
    def test_input_derivatives2(self):
        model = self.simple_input2

        model.initialize()

        model.set_input_derivatives("u1",2.0, 1)
        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u1"),2.0)
        nose.tools.assert_almost_equal(model.get("u2"),0.0)

        model.set_input_derivatives("u2",2.0, 1)
        model.do_step(1,1)
        nose.tools.assert_almost_equal(model.get("u2"),2.0)
        nose.tools.assert_almost_equal(model.get("u1"),2.0)

        model.set_input_derivatives(["u1","u2"], [1.0,1.0],[1,1])
        model.do_step(2,1)
        nose.tools.assert_almost_equal(model.get("u2"),3.0)
        nose.tools.assert_almost_equal(model.get("u1"),3.0)

    @testattr(stddist = True)
    def test_input_derivatives3(self):
        model = self.simple_input

        model.initialize()
        model.set_input_derivatives("u",1.0, 1)
        model.set_input_derivatives("u",-1.0, 2)
        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u"),0.5)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),0.5)

    @testattr(stddist = True)
    def test_input_derivatives4(self):
        model = self.simple_input

        model.initialize()
        model.set_input_derivatives("u",1.0, 1)
        model.set_input_derivatives("u",-1.0, 2)
        model.set_input_derivatives("u",6.0, 3)
        model.do_step(0, 2)
        nose.tools.assert_almost_equal(model.get("u"),8.0)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),8.0)


    @testattr(stddist = True)
    def test_zero_step_size(self):
        model = self.input_discontinuity

        model.initialize()
        model.do_step(0, 1)
        model.set("u", 1.0)
        nose.tools.assert_almost_equal(model.get("x"),0.0)
        model.do_step(1,0)
        nose.tools.assert_almost_equal(model.get("x"),1.0)

    @testattr(fmi = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        assert self.rlc._get_version() == '1.0'

    @testattr(fmi = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of types platform
        """
        assert self.rlc._get_types_platform() == 'standard32'

    @testattr(fmi = True)
    def test_simulation_with_reset_cs_2(self):
        """
        Tests a simulation with reset of an JModelica generated CS FMU.
        """
        res1 = self.rlc.simulate(final_time=30)
        resistor_v = res1['resistor.v']
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3
        self.rlc.reset()
        res2 = self.rlc.simulate(final_time=30)
        resistor_v = res2['resistor.v']
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3

    @testattr(fmi = True)
    def test_simulation_with_reset_cs_3(self):
        """
        Tests a simulation with reset of an JModelica generated CS FMU
        with events.
        """
        res1 = self.rlc_square.simulate()
        resistor_v = res1['resistor.v']
        print resistor_v[-1]
        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3
        self.rlc_square.reset()
        res2 = self.rlc_square.simulate()
        resistor_v = res2['resistor.v']
        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3

    @testattr(fmi = True)
    def test_simulation_using_euler(self):
        """
        Tests a simulation using Euler.
        """
        self.rlc.set("_cs_solver",1)

        res1 = self.rlc_square.simulate()
        resistor_v = res1['resistor.v']

        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3

    @testattr(fmi = True)
    def test_unknown_solver(self):
        self.rlc.set("_cs_solver",2) #Does not exists

        nose.tools.assert_raises(FMUException, self.rlc.simulate)

    @testattr(windows = True)
    def test_simulation_cs(self):

        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        res = model.simulate(final_time=1.5)
        assert (res.final("J1.w") - 3.245091100366517) < 1e-4

    @testattr(windows = True)
    def test_simulation_with_reset_cs(self):

        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        res1 = model.simulate(final_time=1.5)
        assert (res1["J1.w"][-1] - 3.245091100366517) < 1e-4
        model.reset()
        res2 = model.simulate(final_time=1.5)
        assert (res2["J1.w"][-1] - 3.245091100366517) < 1e-4

    @testattr(windows = True)
    def test_default_experiment(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)

        assert N.abs(model.get_default_experiment_start_time()) < 1e-4
        assert N.abs(model.get_default_experiment_stop_time()-1.5) < 1e-4
        assert N.abs(model.get_default_experiment_tolerance()-0.0001) < 1e-4



    @testattr(windows = True)
    def test_types_platform(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        assert model.types_platform == "standard32"

    @testattr(windows = True)
    def test_exception_input_derivatives(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, model.set_input_derivatives, "u",1.0,1)

    @testattr(windows = True)
    def test_exception_output_derivatives(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, model.get_output_derivatives, "u",1)

    @testattr(assimulo = True)
    def test_multiple_loadings_and_simulations(self):
        model = load_fmu("bouncingBall.fmu",path_to_fmus_cs1,enable_logging=False)
        res = model.simulate(final_time=1.0)
        h_res = res.final('h')

        for i in range(40):
            model = load_fmu("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"),enable_logging=False)
            res = model.simulate(final_time=1.0)
        assert N.abs(h_res - res.final('h')) < 1e-4

    @testattr(assimulo = True)
    def test_log_file_name(self):
        model = load_fmu("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"))
        assert os.path.exists("bouncingBall_log.txt")
        model = load_fmu("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"),log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")
        model = FMUModelCS1("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"))
        assert os.path.exists("bouncingBall_log.txt")
        model = FMUModelCS1("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"),log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")

    @testattr(stddist = True)
    def test_result_name_file(self):

        #rlc_name = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"),target="fmucs")
        rlc = FMUModelCS1("RLC_Circuit.fmu")

        res = rlc.simulate()

        #Default name
        assert res.result_file == "RLC_Circuit_result.txt"
        assert os.path.exists(res.result_file)

        rlc = FMUModelCS1("RLC_Circuit.fmu")
        res = rlc.simulate(options={"result_file_name":
                                    "RLC_Circuit_result_test.txt"})

        #User defined name
        assert res.result_file == "RLC_Circuit_result_test.txt"
        assert os.path.exists(res.result_file)

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
        self._bounce  = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        self._dq = load_fmu('dq.fmu',path_to_fmus_me1)
        self._bounce.initialize()
        self._dq.initialize()
        self.dep = load_fmu("DepParTests_DepPar1.fmu")
        self.dep.initialize()

    @testattr(assimulo = True)
    def test_log_file_name(self):
        model = load_fmu("bouncingBall.fmu",path_to_fmus_me1)
        assert os.path.exists("bouncingBall_log.txt")
        model = load_fmu("bouncingBall.fmu",path_to_fmus_me1,log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")
        model = FMUModelME1("bouncingBall.fmu",path_to_fmus_me1)
        assert os.path.exists("bouncingBall_log.txt")
        model = FMUModelME1("bouncingBall.fmu",path_to_fmus_me1,log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")

    @testattr(stddist = True)
    def test_error_xml(self):
        nose.tools.assert_raises(FMUException,load_fmu,"bouncingBall_modified_xml.fmu",path_to_fmus_me1)
        nose.tools.assert_raises(FMUException,FMUModelME1,"bouncingBall_modified_xml.fmu",path_to_fmus_me1)

    @testattr(windows = True)
    def test_default_experiment(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)

        assert N.abs(model.get_default_experiment_start_time()) < 1e-4
        assert N.abs(model.get_default_experiment_stop_time()-1.5) < 1e-4
        assert N.abs(model.get_default_experiment_tolerance()-0.0001) < 1e-4

    @testattr(stddist = True)
    def test_get_variable_by_valueref(self):
        assert "der(v)" == self._bounce.get_variable_by_valueref(3)
        assert "v" == self._bounce.get_variable_by_valueref(2)

        nose.tools.assert_raises(FMUException, self._bounce.get_variable_by_valueref,7)

    @testattr(assimulo = True)
    def test_multiple_loadings_and_simulations(self):
        model = load_fmu("bouncingBall.fmu",path_to_fmus_me1,enable_logging=False)
        res = model.simulate(final_time=1.0)
        h_res = res.final('h')

        for i in range(40):
            model = load_fmu("bouncingBall.fmu",path_to_fmus_me1,enable_logging=False)
            res = model.simulate(final_time=1.0)
        assert N.abs(h_res - res.final('h')) < 1e-4

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
        model = FMUModelME1('bouncingBall.fmu',path_to_fmus_me1,enable_logging=False)
        model.initialize()
        try:
            model.initialize()
        except FMUException:
            pass
        assert len(model.get_log()) == 0 #Get the current log (empty)
        model = FMUModelME1('bouncingBall.fmu',path_to_fmus_me1,enable_logging=False)
        model.initialize()
        model.set_debug_logging(True) #Activates the logging
        try:
            model.initialize()
        except FMUException:
            pass
        assert len(model.get_log()) > 0 #Get the current log (empty)
        model = FMUModelME1('bouncingBall.fmu',path_to_fmus_me1,enable_logging=True)
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
        self.fmu_name = compile_fmu(self._cpath, self._fpath,compiler_options={'compliance_as_warning':True, 'generate_runtime_option_parameters':False})
        self.model = FMUModelME1(self.fmu_name)

    @testattr(stddist = True)
    def test_vars_model(self):
       """
       Test that the value references are correct
       """
       nose.tools.assert_equal(self.model._save_real_variables_val[0],2)

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
       self.model.set('p1',2.0)

       p2 = self.model.get('p2')
       p3 = self.model.get('p3')

       nose.tools.assert_almost_equal(p2,4)
       nose.tools.assert_almost_equal(p3,12)

class Test_Logger:
    """
    This class tests the Python interface to the FMI runtime log
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        m =  compile_fmu('LoggerTest',os.path.join(path_to_mofiles,'LoggerTest.mo'),compiler_log_level='e',
                compiler_options={'generate_only_initial_system':True})

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu('LoggerTest.fmu')
        self.m.set_debug_logging(True)
        self.m.set('_log_level',6)
        self.m.set_fmil_log_level(5)

    @testattr(fmi = True)
    def test_log_file(self):
        """
        Test that the log file is parsable
        """

        self.m.set('u1',3)

        self.m.get('u1')
        self.m.set('y1',0.)
        self.m.initialize()
        self.m.get('u1')
        self.m.set('u1',4)
        self.m.get('u1')
        self.m.get_derivatives()
        self.m.set('y1',0.5)
        self.m.get('x1')
        self.m.set('p',0.5)
        self.m.get('x1')

        d = gather_solves(parse_jmi_log('LoggerTest_log.txt'))

        assert len(d)==8, "Unexpected number of solver invocations"
        assert len(d[0]['block_solves'])==4, "Unexpected number of block solves in first iteration"


class Test_SetDependentParameterError:
    """
    Test that setting dependent parameters results in exception
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        m =  compile_fmu('DependentParameterTest2',os.path.join(path_to_mofiles,'DependentParameterTest.mo'))

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu('DependentParameterTest2.fmu')

    @testattr(fmi = True)
    def test_dependent_parameter_setting(self):
        """
        Test that expeptions are thrown when dependent parameters are set.
        """

        self.m.set('pri',3)
        nose.tools.assert_raises(FMUException,self.m.set, 'prd', 5)
        nose.tools.assert_raises(FMUException,self.m.set, 'cr', 5)
        self.m.set('pii',3)
        nose.tools.assert_raises(FMUException,self.m.set, 'pid', 5)
        nose.tools.assert_raises(FMUException,self.m.set, 'ci', 5)
        self.m.set('pbi',True)
        nose.tools.assert_raises(FMUException,self.m.set, 'pbd', True)
        nose.tools.assert_raises(FMUException,self.m.set, 'cb', True)


class Test_load_fmu2:
    """
    This test the functionality of load_fmu2 method.
    """

    @testattr(windows = True)
    def test_raise_exception(self):
        """
        This method tests the error-handling of load_fmu2
        """
        #nose.tools.assert_raises(FMUException, load_fmu2, 'not_a_fmu.txt', path_to_fmus)          #loading non-fmu file
        nose.tools.assert_raises(FMUException, load_fmu2, 'not_existing_file.fmu', path_to_fmus_me2)  #loading non-existing file
        #nose.tools.assert_raises(FMUException, load_fmu2, 'not_a_.fmu', path_to_fmus)             #loading a non-real fmu
        nose.tools.assert_raises(FMUException, load_fmu2, fmu=ME2, path=path_to_fmus_me2, kind='Teo') #loading fmu with wrong argument
        nose.tools.assert_raises(FMUException, load_fmu2, fmu=ME1, path=path_to_fmus_me1, kind='CS')  #loading ME1-model as a CS-model
        nose.tools.assert_raises(FMUException, load_fmu2, fmu=CS1, path=path_to_fmus_cs1, kind='ME')  #loading CS1-model as ME-model
        nose.tools.assert_raises(FMUException, load_fmu2, fmu=ME2, path=path_to_fmus_me2, kind='CS')  #loading ME2-model as a CS-model
        nose.tools.assert_raises(FMUException, load_fmu2, fmu=CS2, path=path_to_fmus_cs2, kind='ME')  #loading CS2-model as ME-model

    @testattr(windows = True)
    def test_correct_loading(self):
        """
        This method tests the correct loading of FMUs
        """
        model = load_fmu2(fmu = ME1, path = path_to_fmus_me1, kind = 'auto') #loading ME1-model correct
        assert isinstance(model, FMUModelME1)
        model = load_fmu2(fmu = ME1, path = path_to_fmus_me1, kind = 'ME')   #loading ME1-model correct
        assert isinstance(model, FMUModelME1)
        model = load_fmu2(fmu = CS1, path = path_to_fmus_cs1, kind = 'auto') #loading CS1-model correct
        assert isinstance(model, FMUModelCS1)
        model = load_fmu2(fmu = CS1, path = path_to_fmus_cs1, kind = 'CS')   #loading CS1-model correct
        assert isinstance(model, FMUModelCS1)

        model = load_fmu2(fmu = ME2, path = path_to_fmus_me2, kind = 'Auto') #loading ME2-model correct
        assert isinstance(model, FMUModelME2)
        model = load_fmu2(fmu = ME2, path = path_to_fmus_me2, kind = 'me')   #loading ME2-model correct
        assert isinstance(model, FMUModelME2)
        model = load_fmu2(fmu = CS2, path = path_to_fmus_cs2, kind = 'AUTO') #loading CS2-model correct
        assert isinstance(model, FMUModelCS2)
        model = load_fmu2(fmu = CS2, path = path_to_fmus_cs2, kind = 'cs')   #loading CS2-model correct
        assert isinstance(model, FMUModelCS2)

class Test_FMUModelCS2:
    """
    This class tests pyfmi.fmi.FMUModelCS2
    """

#---------Test instantiation and initialization------------

    @testattr(windows = True)
    def test_init(self):
        """
        Test the method __init__ in FMUModelCS2
        """
        #Do the setUp
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)

        assert self._bounce.get_identifier() == 'BouncingBall2'
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=ME2, path=path_to_fmus_me2)
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=CS1, path=path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=ME1, path=path_to_fmus_me1)

    @testattr(windows = True)
    def test_dealloc(self):
        """
        Test the method __dealloc__ in FMUModelCS2
        """
        pass

    @testattr(windows = True)
    def test_instantiate_slave(self):
        """
        Test the method instantiate_slave in FMUModelCS2
        """
        #Do the setUp
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)
        self._bounce.initialize()

        self._bounce.reset_slave() #Test multiple instantiation
        for i in range(0,10):
            name_of_slave = 'slave' + str(i)
            self._bounce.instantiate_slave(name = name_of_slave)

    @testattr(windows = True)
    def test_initialize(self):
        """
        Test the method initialize in FMUModelCS2
        """

        #Do the setUp
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)

        for i in range(10):
            self._bounce.initialize(relTol = 10**-i)  #Initialize multiple times with different relTol
            self._bounce.reset_slave()
        self._bounce.initialize()    #Initialize with default options
        self._bounce.reset_slave()

        self._bounce.initialize(tStart = 4.5)
        nose.tools.assert_almost_equal(self._bounce.time, 4.5)
        self._bounce.reset_slave()

        #Try to simulate past the defined stop
        self._coupledCS2.initialize(tStop=1.0 , StopTimeDefined = True)
        step_size=0.1
        total_time=0
        for i in range(10):
            self._coupledCS2.do_step(total_time, step_size)
            total_time += step_size
        status=self._coupledCS2.do_step(total_time, step_size)
        assert status != 0
        self._coupledCS2.reset_slave()

        #Try to initialize twice when not supported
        self._coupledCS2.initialize()
        nose.tools.assert_raises(FMUException, self._coupledCS2.initialize)

    @testattr(windows = True)
    def test_reset_slave(self):
        """
        Test the method reset_slave in FMUModelCS2
        """

        #Do the setUp
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)
        self._bounce.initialize()
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)
        self._coupledCS2.initialize()

        self._bounce.reset_slave()
        self._bounce.initialize()
        self._coupledCS2.reset_slave()
        self._coupledCS2.initialize()


#---------Test time and steps------------

    @testattr(windows = True)
    def test_the_time(self):
        """
        Test the time in FMUModelCS2
        """

        #Do the setUp
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)
        self._bounce.initialize()

        assert self._bounce._get_time() == 0.0
        assert self._bounce.time == 0.0
        self._bounce._set_time(4.5)
        assert self._bounce._get_time() == 4.5
        self._bounce.time = 3
        assert self._bounce.time == 3.0

        self._bounce.reset_slave()
        self._bounce.initialize(tStart=2.5, tStop=3.0)
        assert self._bounce.time == 2.5

    @testattr(windows = True)
    def test_do_step(self):
        """
        Test the method do_step in FMUModelCS2
        """

        #Do the setUp
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)
        self._bounce.initialize()
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)
        self._coupledCS2.initialize()

        new_step_size = 1e-1
        for i in range(1,30):
            current_time = self._bounce.time
            status = self._bounce.do_step(current_time, new_step_size, True)
            assert status == 0
            nose.tools.assert_almost_equal(self._bounce.time , current_time + new_step_size)


        for i in range(10):
            current_time = self._coupledCS2.time
            status = self._coupledCS2.do_step(current_time, new_step_size, True)
            assert status == 0
            nose.tools.assert_almost_equal(self._coupledCS2.time , current_time + new_step_size)
            self.test_get_status()

    @testattr(windows = True)
    def test_cancel_step(self):
        """
        Test the method cancel_step in FMUModelCS2
        """
        pass


#---------Test derivatives and status------------

    @testattr(windows = True)
    def test_set_input_derivatives(self):
        """
        Test the method set_input_derivatives in FMUModelCS2
        """

        #Do the setUp
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)

        nose.tools.assert_raises(FMUException, self._coupledCS2.set_input_derivatives, 'J1.phi', 1.0, 0) #this is nou an input-variable
        nose.tools.assert_raises(FMUException, self._coupledCS2.set_input_derivatives, 'J1.phi', 1.0, 1)
        nose.tools.assert_raises(FMUException, self._coupledCS2.set_input_derivatives, 578, 1.0, 1)

    @testattr(windows = True)
    def test_get_output_derivatives(self):
        """
        Test the method get_output_derivatives in FMUModelCS2
        """

        #Do the setUp
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)
        self._coupledCS2.initialize()

        self._coupledCS2.do_step(0.0, 0.02)
        nose.tools.assert_raises(FMUException, self._coupledCS2.get_output_derivatives, 'J1.phi', 1)
        nose.tools.assert_raises(FMUException, self._coupledCS2.get_output_derivatives, 'J1.phi', -1)
        nose.tools.assert_raises(FMUException, self._coupledCS2.get_output_derivatives, 578, 0)

    @testattr(windows = True)
    def test_get_status(self):
        """
        Test the methods get status in FMUModelCS2
        """
        pass


#---------Test complete simulation with and without options------------

    @testattr(windows = True)
    def test_simulate(self):
        """
        Test the main features of the method simulate() in FMUmodelCS2
        """
        #Set up for simulation
        self._bounce=load_fmu2(CS2, path_to_fmus_cs2, False)
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)

        #Try simulate the bouncing ball
        res=self._bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        self._bounce.reset_slave()

        for i in range(5):
            res=self._bounce.simulate(start_time=0.1, final_time=1.0)
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e+4  #Give it some marginal
            height = res['HIGHT']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            self._bounce.reset_slave()

        #Try to simulate the coupled-clutches
        res_coupled=self._coupledCS2.simulate()
        sim_time_coupled = res_coupled['time']
        nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
        nose.tools.assert_almost_equal(sim_time_coupled[-1], 1.0)
        self._coupledCS2.reset_slave()


        for i in range(10):
            self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)
            res_coupled = self._coupledCS2.simulate(start_time=0.0, final_time=2.0)
            sim_time_coupled = res_coupled['time']
            nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
            nose.tools.assert_almost_equal(sim_time_coupled[-1],2.0)
            assert sim_time_coupled.all() >= sim_time_coupled[0] - 1e-4   #Check that the time is increasing
            assert sim_time_coupled.all() <= sim_time_coupled[-1] + 1e+4  #Give it some marginal

            #val_J1 = res_coupled['J1.w']
            #val_J2 = res_coupled['J2.w']
            #val_J3 = res_coupled['J3.w']
            #val_J4 = res_coupled['J4.w']

            val=[res_coupled.final('J1.w'), res_coupled.final('J2.w'), res_coupled.final('J3.w'), res_coupled.final('J4.w')]
            if i>0: #check that the results stays the same
                for j in range(len(val)):
                    nose.tools.assert_almost_equal(val[j], val_old[j])
            val_old = val
            self._coupledCS2.reset_slave()

        #Compare to something we know is correct
        cs1_model = load_fmu2('Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu',path_to_fmus_cs1, False)
        res1 = cs1_model.simulate(final_time=10, options={'result_file_name':'result1'})
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)
        res2 = self._coupledCS2.simulate(final_time=10, options={'result_file_name':'result2'})
        diff1 = res1.final("J1.w") - res2.final("J1.w")
        diff2 = res1.final("J2.w") - res2.final("J2.w")
        diff3 = res1.final("J3.w") - res2.final("J3.w")
        diff4 = res1.final("J4.w") - res2.final("J4.w")
        nose.tools.assert_almost_equal(abs(diff1), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff2), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff3), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff4), 0.000, 1)

    @testattr(windows = True)
    def test_simulate_options(self):
        """
        Test the method simultaion_options in FMUModelCS2
        """
        #Do the setUp
        self._coupledCS2 = load_fmu2(CoupledCS2, path_to_fmus_cs2, False)

        #Test the result file
        res=self._coupledCS2.simulate()
        assert res.result_file == 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result.txt'
        assert os.path.exists(res.result_file)

        self._coupledCS2.reset_slave()
        opts = {'result_file_name':'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'}
        res=self._coupledCS2.simulate(options=opts)
        assert res.result_file == 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'
        assert os.path.exists(res.result_file)

        #Test the option in the simulate method
        self._coupledCS2.reset_slave()
        opts={}
        opts['ncp'] = 250
        opts['initialize'] = False
        self._coupledCS2.initialize()
        res=self._coupledCS2.simulate(options=opts)
        assert len(res['time']) == 251













