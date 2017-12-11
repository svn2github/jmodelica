#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2017 Modelon AB
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

from tests_jmodelica.general.base_simul import *
from tests_jmodelica import testattr
from pyfmi.fmi import FMUException
import nose

def assertString(model, name, value):
    val = model.get_string(model.get_variable_valueref(name))[0]
    assert val==value, "Expected '" + str(value) + "' got '" + str(val) + "'"

def setString(model, name, value):
    model.set_string([model.get_variable_valueref(name)], [value])
    
def setStringAssertFail(model, name):
    try:
        setString(model, name, "something")
        assert False, "Expected exception"
    except FMUException as e:
        assert e.message=="Failed to set the String values.", "Wrong error: '" + e.message + "'"

class TestStringParameter1(SimulationTest):
    """
    Basic test of evaluated string parameter.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('StringTests.mo', 
            'StringTests.TestStringParameterEval1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        assertString(self.model, "ci", "string1")
        assertString(self.model, "cd", "string1")
        assertString(self.model, "ps", "string2")
        assertString(self.model, "pe", "string2")
        assertString(self.model, "pf", "string3")
        assertString(self.model, "pi", "string4")
        assertString(self.model, "pd", "string4")
        setStringAssertFail(self.model, "ci")
        setStringAssertFail(self.model, "cd")
        setStringAssertFail(self.model, "ps")
        setStringAssertFail(self.model, "pe")
        setStringAssertFail(self.model, "pf")
        setString(self.model, "pi", "something")
        setStringAssertFail(self.model, "pd")
    
class TestStringParameter2(SimulationTest):
    """
    Basic test of string parameter.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('StringTests.mo', 
            'StringTests.TestStringParameterScalar1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        assertString(self.model, "pi", "string")
        assertString(self.model, "pd", "string1")
        
        setString(self.model, "pi", "something")
        assertString(self.model, "pi", "something")
        assertString(self.model, "pd", "something1")
        
        setString(self.model, "pi", "somethingelse")
        self.run()
        assertString(self.model, "pi", "somethingelse")
        assertString(self.model, "pd", "somethingelse1")

class TestStringParameter3(SimulationTest):
    """
    Basic test of string parameter.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('StringTests.mo', 
            'StringTests.TestStringParameterArray1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        assertString(self.model, "pi[1]", "str1")
        assertString(self.model, "pi[2]", "str2")
        assertString(self.model, "pd[1]", "str1str1")
        assertString(self.model, "pd[2]", "str2str2")
        
        setString(self.model, "pi[1]", "str3")
        setString(self.model, "pi[2]", "str4")
        assertString(self.model, "pi[1]", "str3")
        assertString(self.model, "pi[2]", "str4")
        assertString(self.model, "pd[1]", "str3str3")
        assertString(self.model, "pd[2]", "str4str4")
        setString(self.model, "pi[2]", "str5")
        self.run()
        assertString(self.model, "pi[1]", "str3")
        assertString(self.model, "pi[2]", "str5")
        assertString(self.model, "pd[1]", "str3str3")
        assertString(self.model, "pd[2]", "str5str5")
