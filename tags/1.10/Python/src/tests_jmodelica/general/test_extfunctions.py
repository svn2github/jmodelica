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
Module for testing external function support.
"""
import os, subprocess, shutil
from os.path import join as path

import nose

from pymodelica import compile_fmu
from pymodelica.common.core import get_platform_dir, create_temp_dir
from pyfmi import load_fmu
from tests_jmodelica import testattr, get_files_path

class TestExternalStatic:

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.dir = build_ext('add_static')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalStatic.dir, True)
    
    @testattr(stddist = True)
    def test_ExtFuncStatic(self):
        """ 
        Test compiling a model with external functions in a static library.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest1"
        fmu_name = compile_fmu(cpath, TestExternalStatic.fpath)
        model = load_fmu(fmu_name)
    
    @testattr(stddist = True)
    def test_IntegerArrays(self):
        """
        Test a model with external functions containing integer array and literal inputs.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest4"
        fmu_name = compile_fmu(cpath, TestExternalStatic.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        
        nose.tools.assert_equals(res.final('myResult[1]'), 2) 
        nose.tools.assert_equals(res.final('myResult[2]'), 4)
        nose.tools.assert_equals(res.final('myResult[3]'), 6)
        
class TestUtilities:
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
        pass
    
    @testattr(stddist = True)
    def test_ModelicaUtilities(self):
        """ 
        Test compiling a model with external functions using the functions in ModelicaUtilities.
        """
        fpath = path(get_files_path(), 'Modelica', "ExtFunctionTests.mo")
        cpath = "ExtFunctionTests.ExtFunctionTest3"
        jmu_name = compile_fmu(cpath, fpath)
        model = load_fmu(jmu_name)
        #model.simulate()

class TestExternalShared:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.dir = build_ext('add_shared')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalShared.dir, True)
        
    @testattr(stddist = True)
    def test_ExtFuncShared(self):
        """ 
        Test compiling a model with external functions in a shared library.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest1"
        fmu_name = compile_fmu(cpath, TestExternalShared.fpath)
        model = load_fmu(fmu_name)

class TestExternalObject:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.dir = build_ext('ext_objects')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalObject.dir, True)
        
    @testattr(stddist = True)
    def test_ExtObjectDestructor(self):
        """ 
        Test compiling a model with external object functions in a static library.
        """
        cpath = 'ExtFunctionTests.ExternalObjectTests1'
        fmu_name = compile_fmu(cpath, TestExternalObject.fpath)
        model = load_fmu(fmu_name)
        model.simulate()
        model.terminate()
        if (os.path.exists('test_ext_object.marker')):
             os.remove('test_ext_object.marker')
        else:
            assert False, 'External object destructor not called.'
        

def build_ext(target):
    """
    Build a library for an external function.
    """
    platform = get_platform_dir()
    if platform[:-2] == 'win':
        bin = path(os.environ['MINGW_HOME'],'bin')
        make = '%s CC=%s AR=%s' % (path(bin,'mingw32-make'), path(bin,'gcc'), path(bin,'ar'))
        cmd = "gnumake Makefile "+target
    else:
        make = 'make'
        cmd = '%s PLATFORM=%s clean %s' % (make, platform, target)
    
    src = path(get_files_path(), 'Modelica')
    dst = create_temp_dir()
    shutil.copytree(path(src, 'Resources'), path(dst, 'Resources'))
    shutil.copy(path(src, 'ExtFunctionTests.mo'), dst)
    old = os.getcwd()
    os.chdir(path(dst, 'Resources', 'src'))
    subprocess.call(cmd, shell=True)
    os.chdir(old)
    
    return dst
